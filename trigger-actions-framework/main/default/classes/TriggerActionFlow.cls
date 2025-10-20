/*
   Copyright 2021 Google LLC

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
 * @description This class implements the TriggerAction interface and provides a framework for
 * executing Flows before or after the insert, update, delete, or undelete of records.
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public virtual inherited sharing class TriggerActionFlow implements TriggerAction.BeforeInsert, TriggerAction.AfterInsert, TriggerAction.BeforeUpdate, TriggerAction.AfterUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterDelete, TriggerAction.AfterUndelete {
	@TestVisible
	private static final String RECORD_VARIABLE_NOT_FOUND_ERROR = 'There must be a variable defined in this flow with api name of "record" and type of "record" that is marked as "available for output"';
	@TestVisible
	private static final String FLOW_INTERVIEW_PREFIX = 'Flow.Interview';
	@TestVisible
	private static final String TYPE_MUST_BE_PROVIDED_ERROR = 'Type must be provided to get the flow name.';
	@TestVisible
	private static final String TYPE_MUST_REPRESENT_FLOW_ERROR = 'Type must represent a Flow (e.g., Flow.Interview.MyFlow.class), but got: ';
	@TestVisible
	private static final String FLOW_DOES_NOT_EXIST_ERROR = 'Flow does not exist. Please check that the flow API name is correct.';
	@TestVisible
	private static Set<String> bypassedFlows = new Set<String>();
	@TestVisible
	private static InvocableAction invocableAction = new InvocableAction();
	@TestVisible
	private static TriggerActionFlow.NameExtractor nameExtractor = new TriggerActionFlow.NameExtractor();

	public String flowName;
	public Boolean allowRecursion;

	/**
	 * @description This method bypasses the execution of the Flow for the specified list of records.
	 *
	 * @param flowName The API name of the Flow to bypass.
	 */
	public static void bypass(String flowName) {
		TriggerActionFlow.bypassedFlows.add(flowName);
	}

	/**
	 * @description This method clears the bypass for the specified list of records.
	 *
	 * @param flowName The API name of the Flow to clear the bypass for.
	 */
	public static void clearBypass(String flowName) {
		TriggerActionFlow.bypassedFlows.remove(flowName);
	}

	/**
	 * @description This method checks if the Flow is bypassed for the specified list of records.
	 *
	 * @param flowName The API name of the Flow to check the bypass for.
	 * @return `true` if the Flow is bypassed for the specified list of records, `false` otherwise.
	 */
	public static Boolean isBypassed(String flowName) {
		return TriggerActionFlow.bypassedFlows.contains(flowName);
	}

	/**
	 * @description This method bypasses the execution of the Flow for the specified list of records.
	 *
	 * @param flowType The Type of the Flow to bypass (e.g., Flow.Interview.MyFlow.class).
	 * @throws IllegalArgumentException if the type does not represent a Flow.
	 */
	public static void bypass(System.Type flowType) {
		String flowName = getFlowNameFromType(flowType);
		TriggerActionFlow.bypassedFlows.add(flowName);
	}

	/**
	 * @description This method clears the bypass for the specified list of records.
	 *
	 * @param flowType The Type of the Flow to clear the bypass for (e.g., Flow.Interview.MyFlow.class).
	 * @throws IllegalArgumentException if the type does not represent a Flow.
	 */
	public static void clearBypass(System.Type flowType) {
		String flowName = getFlowNameFromType(flowType);
		TriggerActionFlow.bypassedFlows.remove(flowName);
	}

	/**
	 * @description This method checks if the Flow is bypassed for the specified list of records.
	 *
	 * @param flowType The Type of the Flow to check the bypass for (e.g., Flow.Interview.MyFlow.class).
	 * @return `true` if the Flow is bypassed for the specified list of records, `false` otherwise.
	 * @throws IllegalArgumentException if the type does not represent a Flow.
	 */
	public static Boolean isBypassed(System.Type flowType) {
		String flowName = getFlowNameFromType(flowType);
		return TriggerActionFlow.bypassedFlows.contains(flowName);
	}

	/**
	 * @description This method clears all bypasses for all Flows.
	 */
	public static void clearAllBypasses() {
		TriggerActionFlow.bypassedFlows.clear();
	}

	/**
	 * @description This method extracts the flow name from a Type and validates that it represents a Flow.
	 *
	 * @param flowType The Type to extract the flow name from.
	 * @return The flow API name.
	 * @throws IllegalArgumentException if the type does not represent a Flow.
	 */
	private static String getFlowNameFromType(System.Type flowType) {
		if (flowType == null) {
			throw new IllegalArgumentException(TYPE_MUST_BE_PROVIDED_ERROR);
		}
		String typeName = nameExtractor.extractName(flowType);
		if (typeName == null || !typeName.startsWith(FLOW_INTERVIEW_PREFIX)) {
			throw new IllegalArgumentException(
				TYPE_MUST_REPRESENT_FLOW_ERROR + typeName
			);
		}
		// If the type name is exactly "Flow.Interview", it means the flow doesn't exist
		if (typeName.equals(FLOW_INTERVIEW_PREFIX)) {
			throw new IllegalArgumentException(FLOW_DOES_NOT_EXIST_ERROR);
		}
		return typeName.replace(FLOW_INTERVIEW_PREFIX + '.', '');
	}

	/**
	 * @description This method validates the specified bypass type.
	 *
	 * @param bypassType The bypass type to validate.
	 * @throws IllegalArgumentException if the bypass type is not valid.
	 */
	public static void validateType(String bypassType) {
		if (!TriggerActionConstants.REQUEST_TYPES.contains(bypassType)) {
			throw new IllegalArgumentException(TriggerActionConstants.INVALID_TYPE);
		}
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the insert of the records.
	 *
	 * @param triggerNew The list of records to execute the Flow for.
	 */
	public void beforeInsert(List<SObject> triggerNew) {
		if (flowIsBypassed()) {
			return;
		}
		List<Invocable.Action.Result> results = invokeAction(
			getInterviewInputs(triggerNew, TriggerActionConstants.RECORD_VARIABLE)
		);
		handleInvocableResults(results, triggerNew);
		applyFieldValuesDuringBefore(results, triggerNew);
	}

	/**
	 * @description This method executes the Flow for the specified list of records after the insert of the records.
	 *
	 * @param triggerNew The list of records to execute the Flow for.
	 */
	public void afterInsert(List<SObject> triggerNew) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(triggerNew, TriggerActionConstants.RECORD_VARIABLE)
			),
			triggerNew
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the update of the records.
	 *
	 * @param triggerNew The list of new records that are being updated.
	 * @param triggerOld The list of old records that are being updated.
	 */
	public void beforeUpdate(List<SObject> triggerNew, List<SObject> triggerOld) {
		if (flowIsBypassed()) {
			return;
		}
		List<sObject> recordsNotYetProcessed = new List<sObject>();
		List<sObject> oldRecordsNotYetProcessed = new List<sObject>();
		for (Integer i = 0; i < triggerNew.size(); i++) {
			sObject record = triggerNew[i];
			if (
				TriggerBase.idToNumberOfTimesSeenBeforeUpdate.get(record.id) == 1 ||
				(allowRecursion == true)
			) {
				recordsNotYetProcessed.add(record);
				oldRecordsNotYetProcessed.add(triggerOld[i]);
			}
		}
		if (recordsNotYetProcessed.isEmpty()) {
			return;
		}
		List<Invocable.Action.Result> results = invokeAction(
			getInterviewInputs(recordsNotYetProcessed, oldRecordsNotYetProcessed)
		);
		handleInvocableResults(results, recordsNotYetProcessed);
		applyFieldValuesDuringBefore(results, recordsNotYetProcessed);
	}

	/**
	 * @description This method executes the Flow for the specified list of records after the update of the records.
	 *
	 * @param triggerNew The list of new records that are being updated.
	 * @param triggerOld The list of old records that are being updated.
	 */
	public void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld) {
		if (flowIsBypassed()) {
			return;
		}
		List<sObject> recordsNotYetProcessed = new List<sObject>();
		List<sObject> oldRecordsNotYetProcessed = new List<sObject>();
		for (Integer i = 0; i < triggerNew.size(); i++) {
			sObject record = triggerNew[i];
			if (
				TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(record.id) == 1 ||
				(allowRecursion == true)
			) {
				recordsNotYetProcessed.add(record);
				oldRecordsNotYetProcessed.add(triggerOld[i]);
			}
		}
		if (recordsNotYetProcessed.isEmpty()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(recordsNotYetProcessed, oldRecordsNotYetProcessed)
			),
			recordsNotYetProcessed
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the delete of the records.
	 *
	 * @param triggerOld The list of old records that are being deleted.
	 */
	public void beforeDelete(List<SObject> triggerOld) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(
					triggerOld,
					TriggerActionConstants.RECORD_PRIOR_VARIABLE
				)
			),
			triggerOld
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records after the delete of the records.
	 *
	 * @param triggerOld The list of old records that are being deleted.
	 */
	public void afterDelete(List<SObject> triggerOld) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(
					triggerOld,
					TriggerActionConstants.RECORD_PRIOR_VARIABLE
				)
			),
			triggerOld
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the undelete of the records.
	 *
	 * @param triggerNew The list of records that are being restored.
	 */
	public void afterUndelete(List<SObject> triggerNew) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(triggerNew, TriggerActionConstants.RECORD_VARIABLE)
			),
			triggerNew
		);
	}

	private Boolean flowIsBypassed() {
		if (String.isBlank(flowName)) {
			throw new IllegalArgumentException(
				TriggerActionConstants.INVALID_FLOW_NAME
			);
		}
		return TriggerActionFlow.isBypassed(flowName);
	}

	private List<Invocable.Action.Result> invokeAction(
		List<Map<String, Object>> inputs
	) {
		return invocableAction.invokeAction(this.flowName, inputs);
	}

	private void applyFlowValues(
		sObject stateBeforeFlow,
		sObject stateAfterFlow
	) {
		Boolean hasBeenMutated = false;
		Set<String> recordPopulatedFields = new Set<String>();
		recordPopulatedFields.addAll(
			stateAfterFlow.getPopulatedFieldsAsMap().keySet()
		);
		recordPopulatedFields.addAll(
			stateBeforeFlow.getPopulatedFieldsAsMap().keySet()
		);
		for (String fieldName : recordPopulatedFields) {
			if (stateBeforeFlow.get(fieldName) != stateAfterFlow.get(fieldName)) {
				stateBeforeFlow.put(fieldName, stateAfterFlow.get(fieldName));
				hasBeenMutated = true;
			}
		}
		/**
		 * @description If the record is not mutated, then any errors will persist after the flow is complete,
		 * so there is no need to re-add them
		 */
		if (hasBeenMutated == false) {
			return;
		}
		for (Database.Error err : stateAfterFlow.getErrors()) {
			/**
			 * @description Unfortunately, err.getFields() does not include the field api name after
			 * calling .addError(String fieldApiName, String message) from within a flow,
			 * so when the record is mutated before save,
			 * the exact field location for the error cannot be applied.
			 */
			stateBeforeFlow.addError(err.getMessage());
		}
	}

	/**
	 * @description This method gets the interview inputs for the specified list of new and old records.
	 *
	 * @param triggerNew The list of new records.
	 * @param triggerOld The list of old records.
	 * @return A list of interview inputs.
	 */
	private List<Map<String, Object>> getInterviewInputs(
		List<SObject> triggerNew,
		List<SObject> triggerOld
	) {
		List<Map<String, Object>> result = new List<Map<String, Object>>();
		for (Integer i = 0; i < triggerNew.size(); i++) {
			SObject oldRecord = triggerOld[i];
			SObject newRecord = triggerNew[i];
			result.add(
				new Map<String, Object>{
					TriggerActionConstants.RECORD_PRIOR_VARIABLE => oldRecord,
					TriggerActionConstants.RECORD_VARIABLE => newRecord
				}
			);
		}
		return result;
	}

	protected virtual List<Map<String, Object>> getInterviewInputs(
		List<SObject> records,
		String variableName
	) {
		List<Map<String, Object>> result = new List<Map<String, Object>>();
		for (Integer i = 0; i < records.size(); i++) {
			result.add(new Map<String, Object>{ variableName => records[i] });
		}
		return result;
	}

	private void applyFieldValuesDuringBefore(
		List<Invocable.Action.Result> results,
		List<SObject> triggerNew
	) {
		for (Integer i = 0; i < results.size(); i++) {
			Invocable.Action.Result result = results[i];
			if (result.isSuccess() == true) {
				SObject newRecordWhenFlowIsComplete = (SObject) (result.getOutputParameters()
					.get(TriggerActionConstants.RECORD_VARIABLE));
				if (newRecordWhenFlowIsComplete == null) {
					throw new IllegalArgumentException(
						this.flowName + ': ' + RECORD_VARIABLE_NOT_FOUND_ERROR
					);
				}
				applyFlowValues(triggerNew[i], newRecordWhenFlowIsComplete);
			}
		}
	}

	private void handleInvocableResults(
		List<Invocable.Action.Result> results,
		List<SObject> records
	) {
		for (Integer i = 0; i < results.size(); i++) {
			Invocable.Action.Result result = results[i];
			if (result.isSuccess() == false) {
				records[i].addError(getFormattedErrorMessage(result.getErrors()));
			}
		}
	}

	private String getFormattedErrorMessage(List<Invocable.Action.Error> errors) {
		List<String> messagesAndCodes = new List<String>();
		for (Invocable.Action.Error error : errors) {
			messagesAndCodes.add(error.getCode() + ' - ' + error.getMessage());
		}
		return this.flowName + ': ' + String.join(messagesAndCodes, ', ');
	}

	@TestVisible
	private virtual class InvocableAction {
		/**
		 * @description This method invokes the specified Flow with the specified inputs.
		 *
		 * @param flowApiName The API name of the Flow to invoke.
		 * @param inputs The list of inputs to pass to the Flow.
		 * @return The list of results from the Flow invocation.
		 */
		public virtual List<Invocable.Action.Result> invokeAction(
			String flowApiName,
			List<Map<String, Object>> inputs
		) {
			Invocable.Action action = Invocable.Action.createCustomAction(
				TriggerActionConstants.FLOW_STRING,
				flowApiName
			);
			action.setInvocations(inputs);
			return action.invoke();
		}
	}

	@SuppressWarnings('PMD.ApexDoc')
	@TestVisible
	private virtual class NameExtractor {
		public virtual String extractName(System.Type flowType) {
			return flowType.getName();
		}
	}
}
