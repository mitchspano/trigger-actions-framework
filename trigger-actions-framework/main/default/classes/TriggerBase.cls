/*
   Copyright 2020 Google LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

/**
 * @group Trigger Actions Framework
 * @description The `TriggerBase` class is a base class for all trigger handlers.
 *
 * Trigger handlers are classes that define the logic that should be executed before or after
 * a DML operation on a record.
 * The `TriggerBase` class provides the following functionality:
 *
 * - A way to bypass the execution of specific trigger handlers.
 * - A way to check if a specific trigger handler is bypassed.
 * - A way to clear all bypasses.
 * - A way to offset the number of existing DML rows.
 * - A way to wait to finalize the DML operation.
 * - A way to now finalize the DML operation.
 * ---
 * To use the `TriggerBase` class, you must create a subclass that implements the `TriggerAction` interface.
 * The `TriggerAction` interface defines the methods that should be implemented by trigger actions.
 */
@SuppressWarnings(
	'PMD.StdCyclomaticComplexity,PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.PropertyNamingConventions'
)
public inherited sharing virtual class TriggerBase {
	@TestVisible
	private static final String HANDLER_OUTSIDE_TRIGGER_MESSAGE = 'Trigger handler called outside of Trigger execution';
	@TestVisible
	private static final String CANNOT_FINALIZE = 'Calling `nowFinalize()` is only allowed after `waitToFinalize()` has been called';
	private static final Map<System.TriggerOperation, System.TriggerOperation> CONTEXT_TO_INVERSE = new Map<System.TriggerOperation, System.TriggerOperation>{
		System.TriggerOperation.AFTER_INSERT => System.TriggerOperation.BEFORE_INSERT,
		System.TriggerOperation.AFTER_UPDATE => System.TriggerOperation.BEFORE_UPDATE,
		System.TriggerOperation.AFTER_DELETE => System.TriggerOperation.BEFORE_DELETE
	};

	@TestVisible
	private static Set<String> bypassedObjects = new Set<String>();
	@TestVisible
	private static Integer existingDmlRowsOffset = 0;
	private static Integer rowsLeftToProcess;
	private static TriggerBase.Stack contextStack = new TriggerBase.Stack();
	private String lastProcessedContext;
	private static Boolean suppressFinalizeExecution = false;
	private static TriggerBase instanceToFinalize;

	private static final Map<System.TriggerOperation, Map<Id, Integer>> CONTEXT_TO_UPDATE_COUNT {
		get {
			if (CONTEXT_TO_UPDATE_COUNT == null) {
				CONTEXT_TO_UPDATE_COUNT = new Map<System.TriggerOperation, Map<Id, Integer>>{
					System.TriggerOperation.BEFORE_UPDATE => new Map<Id, Integer>(),
					System.TriggerOperation.AFTER_UPDATE => new Map<Id, Integer>()
				};
			}
			return CONTEXT_TO_UPDATE_COUNT;
		}
		set;
	}

	/**
	 * @description This method returns a map of the IDs of the records that have been seen in the `BEFORE_UPDATE`
	 * context to the number of times they have been seen.
	 *
	 * @return A map of the IDs of the records that have been seen in the `BEFORE_UPDATE` context to
	 * the number of times they have been seen.
	 */
	public static Map<Id, Integer> idToNumberOfTimesSeenBeforeUpdate {
		get {
			return CONTEXT_TO_UPDATE_COUNT.get(System.TriggerOperation.BEFORE_UPDATE);
		}
	}

	/**
	 * @description This method returns a map of the IDs of the records that have been seen
	 * in the `AFTER_UPDATE` context to the number of times they have been seen.
	 *
	 * @return A map of the IDs of the records that have been seen in the `AFTER_UPDATE`
	 * context to the number of times they have been seen.
	 */
	public static Map<Id, Integer> idToNumberOfTimesSeenAfterUpdate {
		get {
			return CONTEXT_TO_UPDATE_COUNT.get(System.TriggerOperation.AFTER_UPDATE);
		}
	}

	private String contextKey {
		get {
			return this.sObjectName + '|' + this.context.name();
		}
	}

	private String inverseContext {
		get {
			return CONTEXT_TO_INVERSE.containsKey(this.context)
				? this.sObjectName + '|' + CONTEXT_TO_INVERSE.get(this.context)
				: '';
		}
	}
	/**
	 * @description This method bypasses the execution of the specified object.
	 *
	 * @param sObjectName The API name of the object to bypass.
	 */
	public static void bypass(String sObjectName) {
		TriggerBase.bypassedObjects.add(sObjectName);
	}

	/**
	 * @description This method clears the bypass for the specified object.
	 *
	 * @param sObjectName The API name of the object to clear the bypass for.
	 */
	public static void clearBypass(String sObjectName) {
		TriggerBase.bypassedObjects.remove(sObjectName);
	}

	/**
	 * @description This method checks if the specified object is bypassed.
	 *
	 * @param sObjectName The API name of the object to check the bypass for.
	 * @return True if the object is bypassed, false otherwise.
	 */
	public static Boolean isBypassed(String sObjectName) {
		return TriggerBase.bypassedObjects.contains(sObjectName);
	}

	/**
	 * @description This method bypasses the execution of the specified object.
	 *
	 * @param sObjectType The sObjectType of the object to bypass.
	 */
	public static void bypass(Schema.sObjectType sObjectType) {
		TriggerBase.bypassedObjects.add(
			sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName()
		);
	}

	/**
	 * @description This method clears the bypass for the specified object.
	 *
	 * @param sObjectType The sObjectType of the object to clear the bypass for.
	 */
	public static void clearBypass(Schema.sObjectType sObjectType) {
		TriggerBase.bypassedObjects.remove(
			sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName()
		);
	}

	/**
	 * @description This method checks if the specified object is bypassed.
	 *
	 * @param sObjectType The sObjectType of the object to check the bypass for.
	 * @return True if the object is bypassed, false otherwise.
	 */
	public static Boolean isBypassed(Schema.sObjectType sObjectType) {
		return TriggerBase.bypassedObjects.contains(
			sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName()
		);
	}

	/**
	 * @description This method clears all bypasses.
	 */
	public static void clearAllBypasses() {
		TriggerBase.bypassedObjects.clear();
	}

	/**
	 * @description This method offsets the number of existing DML rows.
	 */
	public static void offsetExistingDmlRows() {
		existingDmlRowsOffset = Limits.getDMLRows();
	}

	/**
	 * @description This method waits to finalize the DML operation.
	 */
	public static void waitToFinalize() {
		suppressFinalizeExecution = true;
	}

	/**
	 * @description This method now finalizes the DML operation.
	 */
	public static void nowFinalize() {
		if (suppressFinalizeExecution == false) {
			throw new TriggerBaseException(CANNOT_FINALIZE);
		}
		instanceToFinalize?.finalizeDmlOperation();
	}

	/**
	 * @description This method runs the trigger handler.
	 */
	public void run() {
		if (!shouldRun()) {
			return;
		}
		setInstanceToFinalize();
		setRowsLeftToProcess();
		TriggerBase.contextStack.push(this.contextKey);
		if (
			this.context == System.TriggerOperation.BEFORE_INSERT &&
			this instanceof TriggerAction.BeforeInsert
		) {
			((TriggerAction.BeforeInsert) this).beforeInsert(this.triggerNew);
		} else if (
			this.context == System.TriggerOperation.AFTER_INSERT &&
			this instanceof TriggerAction.AfterInsert
		) {
			((TriggerAction.AfterInsert) this).afterInsert(this.triggerNew);
		} else if (
			this.context == System.TriggerOperation.BEFORE_UPDATE &&
			this instanceof TriggerAction.BeforeUpdate
		) {
			this.incrementUpdateCounts(this.context, this.triggerNew);
			((TriggerAction.BeforeUpdate) this)
				.beforeUpdate(this.triggerNew, this.triggerOld);
		} else if (
			this.context == System.TriggerOperation.AFTER_UPDATE &&
			this instanceof TriggerAction.AfterUpdate
		) {
			this.incrementUpdateCounts(this.context, this.triggerNew);
			((TriggerAction.AfterUpdate) this)
				.afterUpdate(this.triggerNew, this.triggerOld);
		} else if (
			this.context == System.TriggerOperation.BEFORE_DELETE &&
			this instanceof TriggerAction.BeforeDelete
		) {
			((TriggerAction.BeforeDelete) this).beforeDelete(this.triggerOld);
		} else if (
			this.context == System.TriggerOperation.AFTER_DELETE &&
			this instanceof TriggerAction.AfterDelete
		) {
			((TriggerAction.AfterDelete) this).afterDelete(this.triggerOld);
		} else if (
			this.context == System.TriggerOperation.AFTER_UNDELETE &&
			this instanceof TriggerAction.AfterUndelete
		) {
			((TriggerAction.AfterUndelete) this).afterUndelete(this.triggerNew);
		}
		checkForEndOfTriggerProcessing();
	}

	private void checkForEndOfTriggerProcessing() {
		if (this.context == System.TriggerOperation.AFTER_UNDELETE) {
			TriggerBase.contextStack.pop();
		}
		if (TriggerBase.contextStack.depth() > 1) {
			String currentContext = TriggerBase.contextStack.pop();
			String previousContext = TriggerBase.contextStack.peek();
			if (previousContext == this.inverseContext) {
				TriggerBase.contextStack.pop();
			} else {
				triggerBase.contextStack.push(currentContext);
			}
		}
		if (TriggerBase.contextStack.isEmpty() && rowsLeftToProcess == 0) {
			rowsLeftToProcess = null;
			existingDmlRowsOffset = getDmlRows();
			if (!suppressFinalizeExecution) {
				instanceToFinalize.finalizeDmlOperation();
				instanceToFinalize = null;
			}
		}
	}

	@SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void finalizeDmlOperation() {
	}

	private void incrementUpdateCounts(
		System.TriggerOperation triggerContext,
		List<SObject> records
	) {
		for (SObject obj : records) {
			Map<Id, Integer> idToUpdateCount = CONTEXT_TO_UPDATE_COUNT.get(
				triggerContext
			);
			Integer updateCount = idToUpdateCount.get(obj.Id);
			if (updateCount == null) {
				updateCount = 0;
			}
			idToUpdateCount.put(obj.Id, ++updateCount);
		}
	}

	private Boolean shouldRun() {
		if (!Trigger.isExecuting && this.context == null) {
			throw new TriggerBaseException(HANDLER_OUTSIDE_TRIGGER_MESSAGE);
		}
		if (TriggerBase.bypassedObjects.contains(this.sObjectName)) {
			return false;
		}
		return true;
	}

	private void setRowsLeftToProcess() {
		if (!TriggerBase.contextStack.isEmpty()) {
			return;
		}
		if (rowsLeftToProcess == null) {
			rowsLeftToProcess = getDMLRows() - existingDmlRowsOffset;
		}
		rowsLeftToProcess = rowsLeftToProcess - triggerSize;
	}

	private void setInstanceToFinalize() {
		if (instanceToFinalize == null) {
			instanceToFinalize = this;
		}
	}

	@TestVisible
	protected virtual Integer getDmlRows() {
		return Limits.getDmlRows();
	}

	@TestVisible
	protected Schema.SObjectType sObjectType {
		get {
			if (sObjectType == null) {
				if (this.triggerNew != null) {
					sObjectType = this.triggerNew[0].getSObjectType();
				} else {
					sObjectType = this.triggerOld[0].getSObjectType();
				}
			}
			return sObjectType;
		}
		private set;
	}

	@TestVisible
	protected String sObjectName {
		get {
			if (sObjectName == null) {
				sObjectName = this.sObjectType.getDescribe(
						SObjectDescribeOptions.DEFERRED
					)
					.getName();
			}
			return sObjectName;
		}
		private set;
	}

	@TestVisible
	protected System.TriggerOperation context {
		get {
			if (context == null) {
				context = Trigger.operationType;
			}
			return context;
		}
		set;
	}

	@TestVisible
	protected List<SObject> triggerNew {
		get {
			if (triggerNew == null) {
				triggerNew = Trigger.new;
			}
			return triggerNew;
		}
		private set;
	}

	@TestVisible
	protected List<SObject> triggerOld {
		get {
			if (triggerOld == null) {
				triggerOld = Trigger.old;
			}
			return triggerOld;
		}
		private set;
	}

	private Integer triggerSize {
		get {
			return triggerNew != null
				? triggerNew.size()
				: triggerOld != null ? triggerOld.size() : 0;
		}
	}

	@TestVisible
	private class Stack {
		private List<String> data = new List<String>();
		/**
		 * @description This method pushes the specified string onto the stack.
		 *
		 * @param s The string to push onto the stack.
		 */
		public void push(String s) {
			data.add(s);
		}

		/**
		 * @description This method returns the top element of the stack without removing it.
		 *
		 * @return The top element of the stack.
		 */
		public String peek() {
			if (this.data.isEmpty()) {
				throw new EmptyStackException();
			}
			return this.data.get(this.data.size() - 1);
		}

		/**
		 * @description This method checks if the stack is empty.
		 *
		 * @return True if the stack is empty, false otherwise.
		 */
		public Boolean isEmpty() {
			return this.data.isEmpty();
		}

		/**
		 * @description This method pops the top element off the stack and returns it.
		 *
		 * @return The top element of the stack.
		 */
		public String pop() {
			if (this.data.isEmpty()) {
				throw new EmptyStackException();
			}
			String response = this.data.get(this.data.size() - 1);
			this.data.remove(this.data.size() - 1);
			return response;
		}

		/**
		 * @description This method returns the number of elements in the stack.
		 *
		 * @return The number of elements in the stack.
		 */
		public Integer depth() {
			return this.data.size();
		}
	}

	@TestVisible
	private class TriggerBaseException extends Exception {
	}

	@TestVisible
	private class EmptyStackException extends Exception {
	}
}
