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

@SuppressWarnings(
	'PMD.ApexDoc,PMD.CyclomaticComplexity,PMD.ApexUnitTestClassShouldHaveRunAs'
)
@IsTest(isParallel=true)
private class TriggerBaseTest {
	private static final String ACCOUNT = 'Account';
	private static final String BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY = 'The bypasses should be configured correctly';
	private static final String FIRST = 'first';
	private static final String NUMBER_OF_TIMES_SEEN_SHOULD_BE_CORRECT = 'The number of time seen should be populated properly';
	private static final String RUN_SUCCESS = 'Run should be successful';
	private static final String SECOND = 'second';
	private static final String SHOULD_BE_FINALIZED = 'The DML operation should be finalized';
	private static final String SHOULD_NOT_BE_FINALIZED = 'The DML operation should not be finalized';
	private static final String THIRD = 'third';

	private static final Account MY_ACCOUNT = new Account(
		Id = TriggerTestUtility.getFakeId(Schema.Account.SObjectType),
		Name = 'My Account'
	);
	private static BaseTest base = new BaseTest();
	private static Exception myException;

	static {
		base.triggerNew = new List<SObject>{ MY_ACCOUNT };
		base.triggerOld = new List<SObject>{ MY_ACCOUNT };
	}

	@IsTest
	private static void sObjectNameShouldBePopulatedFromTriggerNew() {
		base.triggerOld = null;

		String sObjectName = base.sObjectName;

		System.Assert.areEqual(
			sObjectName,
			ACCOUNT,
			'Name should be populated from elements of triggerOld'
		);
	}

	@IsTest
	private static void sObjectNameShouldBePopulatedFromTriggerOld() {
		base.triggerNew = null;

		String sObjectName = base.sObjectName;

		System.Assert.areEqual(
			sObjectName,
			ACCOUNT,
			'Name should be populated from elements of triggerNew'
		);
	}

	@IsTest
	private static void oldAndNewShouldComeFromTrigger() {
		base.triggerNew = null;
		base.triggerOld = null;

		System.Assert.areEqual(
			null,
			base.triggerNew,
			'triggerNew should match Trigger.new'
		);
		System.Assert.areEqual(
			null,
			base.triggerOld,
			'triggerOld should match Trigger.old'
		);
	}

	@IsTest
	private static void beforeInsertShouldSucceed() {
		MY_ACCOUNT.Id = null;
		base.context = System.TriggerOperation.BEFORE_INSERT;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterInsertShouldSucceed() {
		base.context = System.TriggerOperation.AFTER_INSERT;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void beforeUpdateShouldSucceed() {
		base.context = System.TriggerOperation.BEFORE_UPDATE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterUpdateShouldSucceed() {
		base.context = System.TriggerOperation.After_UPDATE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void beforeDeleteShouldSucceed() {
		base.context = System.TriggerOperation.BEFORE_DELETE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterDeleteShouldSucceed() {
		base.context = System.TriggerOperation.AFTER_DELETE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterUndeleteShouldSucceed() {
		base.context = System.TriggerOperation.AFTER_UNDELETE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void idToNumberOfTimesSeenBeforeUpdate() {
		base.context = System.TriggerOperation.BEFORE_UPDATE;

		base.run();
		base.run();

		System.Assert.areEqual(
			2,
			TriggerBase.idToNumberOfTimesSeenBeforeUpdate.get(MY_ACCOUNT.Id),
			NUMBER_OF_TIMES_SEEN_SHOULD_BE_CORRECT
		);
	}

	@IsTest
	private static void idToNumberOfTimesSeenAfterUpdate() {
		base.context = System.TriggerOperation.AFTER_UPDATE;

		base.run();
		base.run();

		System.Assert.areEqual(
			2,
			TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(MY_ACCOUNT.Id),
			NUMBER_OF_TIMES_SEEN_SHOULD_BE_CORRECT
		);
	}

	@IsTest
	private static void runShouldFailWhenCalledOutsideTrigger() {
		try {
			base.run();
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(
			null,
			myException,
			'An exception should be thrown'
		);
		System.Assert.areEqual(
			TriggerBase.HANDLER_OUTSIDE_TRIGGER_MESSAGE,
			myException.getMessage(),
			'The exception should be the one we are looking for'
		);
	}

	@IsTest
	private static void runShouldDoNothingWhenBypassed() {
		MY_ACCOUNT.Id = null;
		TriggerBase.bypass(ACCOUNT);
		base.context = System.TriggerOperation.BEFORE_INSERT;

		base.run();

		System.Assert.isFalse(base.executed, SHOULD_NOT_BE_FINALIZED);
	}

	@IsTest
	private static void inverseContextsShouldFinalizeDmlOperationInsert() {
		base.triggerOld = null;
		base.dmlRows = 1;
		base.context = System.TriggerOperation.BEFORE_INSERT;
		base.run();
		base.context = System.TriggerOperation.AFTER_INSERT;
		base.run();

		System.Assert.isTrue(base.finalized, SHOULD_BE_FINALIZED);
	}

	@IsTest
	private static void inverseContextsShouldFinalizeDmlOperationUpdate() {
		base.dmlRows = 1;
		base.context = System.TriggerOperation.BEFORE_UPDATE;
		base.run();
		base.context = System.TriggerOperation.AFTER_UPDATE;
		base.run();

		System.Assert.isTrue(base.finalized, SHOULD_BE_FINALIZED);
	}

	@IsTest
	private static void inverseContextsShouldFinalizeDmlOperationDelete() {
		base.triggerNew = null;
		base.dmlRows = 1;
		base.context = System.TriggerOperation.BEFORE_DELETE;
		base.run();
		base.context = System.TriggerOperation.AFTER_DELETE;
		base.run();

		System.Assert.isTrue(base.finalized, SHOULD_BE_FINALIZED);
	}

	@IsTest
	private static void inverseContextsShouldFinalizeDmlOperationUndelete() {
		base.triggerOld = null;
		base.dmlRows = 1;
		base.context = System.TriggerOperation.AFTER_UNDELETE;
		base.run();

		System.Assert.isTrue(base.finalized, SHOULD_BE_FINALIZED);
	}

	@IsTest
	private static void bypassShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		System.Assert.isTrue(
			TriggerBase.bypassedObjects.contains(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void clearBypassShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		TriggerBase.clearBypass(ACCOUNT);

		System.Assert.isFalse(
			TriggerBase.bypassedObjects.contains(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void isBypassedShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		System.Assert.isTrue(
			TriggerBase.isBypassed(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void clearAllBypassesShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		TriggerBase.clearAllBypasses();

		System.Assert.areEqual(
			0,
			TriggerBase.bypassedObjects.size(),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void bypassWithSObjectTypeShouldSucceed() {
		TriggerBase.bypass(Schema.Account.SObjectType);

		System.Assert.isTrue(
			TriggerBase.bypassedObjects.contains(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void clearBypassWithSObjectTypeShouldSucceed() {
		TriggerBase.bypass(Schema.Account.SObjectType);

		TriggerBase.clearBypass(Schema.Account.SObjectType);

		System.Assert.isFalse(
			TriggerBase.bypassedObjects.contains(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void isBypassedWithSObjectTypeShouldSucceed() {
		TriggerBase.bypass(Schema.Account.SObjectType);

		System.Assert.isTrue(
			TriggerBase.isBypassed(Schema.Account.SObjectType),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void offsetRowsShouldWork() {
		TriggerBase.offsetExistingDmlRows();

		System.Assert.areEqual(
			0,
			TriggerBase.existingDmlRowsOffset,
			'Offset is not working properly'
		);
	}

	@IsTest
	private static void waitingThenFinalizingShouldWork() {
		try {
			TriggerBase.waitToFinalize();
			TriggerBase.nowFinalize();
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areEqual(
			null,
			myException,
			'There should be no exception when you wait to finalize'
		);
	}

	@IsTest
	private static void finalizingWithoutWaitingShouldThrowError() {
		try {
			TriggerBase.nowFinalize();
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areEqual(
			TriggerBase.CANNOT_FINALIZE,
			myException.getMessage(),
			'There should be an exception when you finalize without waiting'
		);
	}

	@IsTest
	private static void stacksShouldBeAbleToDetermineIftheyAreEmpty() {
		TriggerBase.Stack stack = new TriggerBase.Stack();
		stack.push(FIRST);
		stack.pop();

		System.Assert.isTrue(
			stack.isEmpty(),
			'The stack is empty but unable to identify as such'
		);
	}

	@IsTest
	private static void stackShouldBeFirstInLastOut() {
		TriggerBase.Stack stack = new TriggerBase.Stack();
		stack.push(FIRST);
		stack.push(SECOND);
		stack.push(THIRD);

		String popped = stack.pop();
		popped = stack.pop();

		System.Assert.areEqual(
			FIRST,
			stack.pop(),
			'The first element in the stack is not the last one returned'
		);
	}

	@IsTest
	private static void stackShouldBeLastInFirstOut() {
		TriggerBase.Stack stack = new TriggerBase.Stack();
		stack.push(FIRST);
		stack.push(SECOND);
		stack.push(THIRD);

		System.Assert.areEqual(
			THIRD,
			stack.pop(),
			'The last element in the stack is not the first one returned'
		);
	}

	@IsTest
	private static void peekShouldShowMostRecentlyAdded() {
		TriggerBase.Stack stack = new TriggerBase.Stack();
		stack.push(FIRST);
		stack.push(SECOND);
		stack.push(THIRD);

		System.Assert.areEqual(
			THIRD,
			stack.peek(),
			'The last element in the stack is not peeked'
		);
	}

	@IsTest
	private static void stackDepthShouldBeCalculatedProperly() {
		TriggerBase.Stack stack = new TriggerBase.Stack();
		stack.push(FIRST);
		stack.push(SECOND);
		stack.push(THIRD);

		System.Assert.areEqual(
			3,
			stack.depth(),
			'The stack is not properly calculating its depth'
		);
	}

	@IsTest
	private static void peekingStackWhileEmptyShouldThrowException() {
		TriggerBase.EmptyStackException caught;

		try {
			new TriggerBase.Stack().peek();
		} catch (TriggerBase.EmptyStackException e) {
			caught = e;
		}

		System.Assert.areNotEqual(
			null,
			caught,
			'There should be an exception when you peek an empty stack'
		);
	}

	@IsTest
	private static void poppingStackWhileEmptyShouldThrowException() {
		TriggerBase.EmptyStackException caught;

		try {
			new TriggerBase.Stack().pop();
		} catch (TriggerBase.EmptyStackException e) {
			caught = e;
		}

		System.Assert.areNotEqual(
			null,
			caught,
			'There should be an exception when you pop an empty stack'
		);
	}

	class BaseTest extends TriggerBase implements TriggerAction.BeforeInsert, TriggerAction.AfterInsert, TriggerAction.BeforeUpdate, TriggerAction.AfterUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterDelete, TriggerAction.AfterUndelete {
		public Boolean executed = false;
		public Boolean finalized = false;
		public Integer dmlRows;
		public void beforeInsert(List<SObject> triggerNew) {
			this.executed = true;
		}
		public void afterInsert(List<SObject> triggerNew) {
			this.executed = true;
		}
		public void beforeUpdate(
			List<SObject> triggerNew,
			List<SObject> triggerOld
		) {
			this.executed = true;
		}
		public void afterUpdate(
			List<SObject> triggerNew,
			List<SObject> triggerOld
		) {
			this.executed = true;
		}
		public void beforeDelete(List<SObject> triggerOld) {
			this.executed = true;
		}
		public void afterDelete(List<SObject> triggerNew) {
			this.executed = true;
		}
		public void afterUndelete(List<SObject> triggerNew) {
			this.executed = true;
		}
		public override void finalizeDmlOperation() {
			super.finalizeDmlOperation();
			finalized = true;
		}
		protected override Integer getDmlRows() {
			if (dmlRows != null) {
				return dmlRows;
			}
			return super.getDmlRows();
		}
	}
}
