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
private class MetadataTriggerHandlerTest {
	private static final String ACCOUNT = 'Account';
	private static final String ACTION_SHOULD_EXECUTE = 'We expect the action to be executed';
	private static final String ACTION_SHOULD_NOT_EXECUTE = 'We expect the action to not be executed';
	private static final String BAR = 'bar';
	private static final String BAR_FINALIZER = 'MetadataTriggerHandlerTest.BarFinalizer';
	private static final String BOGUS_CLASS_NAME = 'Bogus';
	private static final String BYPASS_PERMISSION = 'Bogus_Bypass_Permission';
	private static final String BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY = 'All bypasses should be configured correctly';
	private static final String EXCEPTION_SHOULD_BE_THROWN = 'An exception should be thrown';
	private static final String EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE = 'The exception should have the correct message';
	private static final String EXCEPTION_SHOULD_NOT_BE_THROWN = 'An exception should not be thrown';
	private static final String FINALIZER_WITH_DML = 'MetadataTriggerHandlerTest.FinalizerWithDml';
	private static final String FOO = 'foo';
	private static final String FOO_FINALIZER = 'MetadataTriggerHandlerTest.FooFinalizer';
	private static final String METADATA_SHOULD_BE_POPULATED_PROPERLY = 'The metadata should be populated properly';
	private static final String MY_ACCOUNT = 'My Account';
	private static final String REQUIRED_PERMISSION = 'Bogus_Required_Permission';
	private static final String SAMPLE_FLOW_NAME = 'TriggerActionFlowTest';
	private static final String TEST_AFTER_DELETE = 'MetadataTriggerHandlerTest.TestAfterDelete';
	private static final String TEST_AFTER_INSERT = 'MetadataTriggerHandlerTest.TestAfterInsert';
	private static final String TEST_AFTER_UNDELETE = 'MetadataTriggerHandlerTest.TestAfterUndelete';
	private static final String TEST_AFTER_UPDATE = 'MetadataTriggerHandlerTest.TestAfterUpdate';
	private static final String TEST_BEFORE_DELETE = 'MetadataTriggerHandlerTest.TestBeforeDelete';
	private static final String TEST_BEFORE_INSERT = 'MetadataTriggerHandlerTest.TestBeforeInsert';
	private static final String TEST_BEFORE_UPDATE = 'MetadataTriggerHandlerTest.TestBeforeUpdate';

	private static Account myAccount = new Account(
		Name = MY_ACCOUNT,
		Id = TriggerTestUtility.getFakeId(Schema.Account.SObjectType)
	);
	private static sObject_Trigger_Setting__mdt setting = new sObject_Trigger_Setting__mdt(
		Object_API_Name__c = ACCOUNT,
		Id = TriggerTestUtility.getFakeId(
			Schema.sObject_Trigger_Setting__mdt.SObjectType
		)
	);
	private static MetadataTriggerHandler handler = new MetadataTriggerHandler();
	private static Boolean executed = false;
	private static Exception myException;
	private static Trigger_Action__mdt action = new Trigger_Action__mdt(
		Apex_Class_Name__c = TEST_BEFORE_INSERT,
		Before_Insert__r = setting,
		Before_Insert__c = setting.Id,
		Order__c = 1,
		Bypass_Execution__c = false
	);

	static {
		handler.triggerNew = new List<Account>{ myAccount };
		handler.triggerOld = new List<Account>{ myAccount };
	}

	@IsTest
	private static void beforeInsertShouldSucceed() {
		handler.beforeInsertActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void beforeInsertShouldFailWithIncorrectType() {
		action.Apex_Class_Name__c = TEST_AFTER_INSERT;
		handler.beforeInsertActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.beforeInsert(handler.triggerNew);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_TYPE_ERROR,
				new List<String>{
					TEST_AFTER_INSERT,
					String.valueOf(System.TriggerOperation.BEFORE_INSERT),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void beforeInsertShouldFailWithIncorrectClass() {
		action.Apex_Class_Name__c = BOGUS_CLASS_NAME;
		handler.beforeInsertActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.beforeInsert(handler.triggerNew);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_CLASS_ERROR,
				new List<String>{
					BOGUS_CLASS_NAME,
					String.valueOf(System.TriggerOperation.BEFORE_INSERT),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterInsertShouldSucceed() {
		action.Apex_Class_Name__c = TEST_AFTER_INSERT;
		handler.afterInsertActionMetadata = new List<Trigger_Action__mdt>{ action };

		handler.afterInsert(handler.triggerNew);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void afterInsertShouldFailWithIncorrectType() {
		action.Apex_Class_Name__c = TEST_BEFORE_INSERT;
		handler.afterInsertActionMetadata = new List<Trigger_Action__mdt>{ action };

		try {
			handler.afterInsert(handler.triggerNew);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_TYPE_ERROR,
				new List<String>{
					TEST_BEFORE_INSERT,
					String.valueOf(System.TriggerOperation.AFTER_INSERT),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterInsertShouldFailWithIncorrectClass() {
		action.Apex_Class_Name__c = BOGUS_CLASS_NAME;
		handler.afterInsertActionMetadata = new List<Trigger_Action__mdt>{ action };

		try {
			handler.afterInsert(handler.triggerNew);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_CLASS_ERROR,
				new List<String>{
					BOGUS_CLASS_NAME,
					String.valueOf(System.TriggerOperation.AFTER_INSERT),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void beforeUpdateShouldSucceed() {
		action.Apex_Class_Name__c = TEST_BEFORE_UPDATE;
		handler.beforeUpdateActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		handler.beforeUpdate(handler.triggerNew, handler.triggerOld);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void beforeUpdateShouldFailWithIncorrectType() {
		action.Apex_Class_Name__c = TEST_BEFORE_INSERT;
		handler.beforeUpdateActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.beforeUpdate(handler.triggerNew, handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_TYPE_ERROR,
				new List<String>{
					TEST_BEFORE_INSERT,
					String.valueOf(System.TriggerOperation.BEFORE_UPDATE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void beforeUpdateShouldFailWithIncorrectClass() {
		action.Apex_Class_Name__c = BOGUS_CLASS_NAME;
		handler.beforeUpdateActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.beforeUpdate(handler.triggerNew, handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_CLASS_ERROR,
				new List<String>{
					BOGUS_CLASS_NAME,
					String.valueOf(System.TriggerOperation.BEFORE_UPDATE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterUpdateShouldSucceed() {
		action.Apex_Class_Name__c = TEST_AFTER_UPDATE;
		handler.afterUpdateActionMetadata = new List<Trigger_Action__mdt>{ action };

		handler.afterUpdate(handler.triggerNew, handler.triggerOld);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void afterUpdateShouldFailWithIncorrectType() {
		action.Apex_Class_Name__c = TEST_BEFORE_INSERT;
		handler.afterUpdateActionMetadata = new List<Trigger_Action__mdt>{ action };

		try {
			handler.afterUpdate(handler.triggerNew, handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_TYPE_ERROR,
				new List<String>{
					TEST_BEFORE_INSERT,
					String.valueOf(System.TriggerOperation.AFTER_UPDATE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterUpdateShouldFailWithIncorrectClass() {
		action.Apex_Class_Name__c = BOGUS_CLASS_NAME;
		handler.afterUpdateActionMetadata = new List<Trigger_Action__mdt>{ action };

		try {
			handler.afterUpdate(handler.triggerNew, handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_CLASS_ERROR,
				new List<String>{
					BOGUS_CLASS_NAME,
					String.valueOf(System.TriggerOperation.AFTER_UPDATE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void beforeDeleteShouldSucceed() {
		action.Apex_Class_Name__c = TEST_BEFORE_DELETE;
		handler.beforeDeleteActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		handler.beforeDelete(handler.triggerOld);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void beforeDeleteShouldFailWithIncorrectType() {
		action.Apex_Class_Name__c = TEST_BEFORE_INSERT;
		handler.beforeDeleteActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.beforeDelete(handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_TYPE_ERROR,
				new List<String>{
					TEST_BEFORE_INSERT,
					String.valueOf(System.TriggerOperation.BEFORE_DELETE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void beforeDeleteShouldFailWithIncorrectClass() {
		action.Apex_Class_Name__c = BOGUS_CLASS_NAME;
		handler.beforeDeleteActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.beforeDelete(handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_CLASS_ERROR,
				new List<String>{
					BOGUS_CLASS_NAME,
					String.valueOf(System.TriggerOperation.BEFORE_DELETE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterDeleteShouldSucceed() {
		action.Apex_Class_Name__c = TEST_AFTER_DELETE;
		handler.afterDeleteActionMetadata = new List<Trigger_Action__mdt>{ action };

		handler.afterDelete(handler.triggerOld);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void afterDeleteShouldFailWithIncorrectType() {
		action.Apex_Class_Name__c = TEST_BEFORE_INSERT;
		handler.afterDeleteActionMetadata = new List<Trigger_Action__mdt>{ action };

		try {
			handler.afterDelete(handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_TYPE_ERROR,
				new List<String>{
					TEST_BEFORE_INSERT,
					String.valueOf(System.TriggerOperation.AFTER_DELETE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterDeleteShouldFailWithIncorrectClass() {
		action.Apex_Class_Name__c = BOGUS_CLASS_NAME;
		handler.afterDeleteActionMetadata = new List<Trigger_Action__mdt>{ action };

		try {
			handler.afterDelete(handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_CLASS_ERROR,
				new List<String>{
					BOGUS_CLASS_NAME,
					String.valueOf(System.TriggerOperation.AFTER_DELETE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterUndeleteShouldSucceed() {
		action.Apex_Class_Name__c = TEST_AFTER_UNDELETE;
		handler.afterUndeleteActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		handler.afterUndelete(handler.triggerOld);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void afterUndeleteShouldFailWithIncorrectType() {
		action.Apex_Class_Name__c = TEST_BEFORE_INSERT;
		handler.afterUndeleteActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.afterUndelete(handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_TYPE_ERROR,
				new List<String>{
					TEST_BEFORE_INSERT,
					String.valueOf(System.TriggerOperation.AFTER_UNDELETE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void afterUndeleteShouldFailWithIncorrectClass() {
		action.Apex_Class_Name__c = BOGUS_CLASS_NAME;
		handler.afterUndeleteActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.afterUndelete(handler.triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			myException.getMessage(),
			String.format(
				MetadataTriggerHandler.INVALID_CLASS_ERROR,
				new List<String>{
					BOGUS_CLASS_NAME,
					String.valueOf(System.TriggerOperation.AFTER_UNDELETE),
					ACCOUNT
				}
			),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void nothingToProcessShouldExitEarly() {
		handler.beforeInsertActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		handler.beforeInsert(new List<Account>());

		System.Assert.isFalse(executed, ACTION_SHOULD_NOT_EXECUTE);
	}

	@IsTest
	private static void finalizerShouldSucceed() {
		MetadataTriggerHandler.finalizerHandler = new TestFinalizerHandler();

		handler.finalizeDmlOperation();

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void actionMetadataShouldConstruct() {
		System.Assert.areNotEqual(
			null,
			handler.beforeInsertActionMetadata,
			METADATA_SHOULD_BE_POPULATED_PROPERLY
		);
		System.Assert.areNotEqual(
			null,
			handler.afterInsertActionMetadata,
			METADATA_SHOULD_BE_POPULATED_PROPERLY
		);
		System.Assert.areNotEqual(
			null,
			handler.beforeUpdateActionMetadata,
			METADATA_SHOULD_BE_POPULATED_PROPERLY
		);
		System.Assert.areNotEqual(
			null,
			handler.afterUpdateActionMetadata,
			METADATA_SHOULD_BE_POPULATED_PROPERLY
		);
		System.Assert.areNotEqual(
			null,
			handler.beforeDeleteActionMetadata,
			METADATA_SHOULD_BE_POPULATED_PROPERLY
		);
		System.Assert.areNotEqual(
			null,
			handler.afterDeleteActionMetadata,
			METADATA_SHOULD_BE_POPULATED_PROPERLY
		);
		System.Assert.areNotEqual(
			null,
			handler.afterUndeleteActionMetadata,
			METADATA_SHOULD_BE_POPULATED_PROPERLY
		);
	}

	@IsTest
	private static void bypassShouldSucceed() {
		MetadataTriggerHandler.bypass(TEST_BEFORE_INSERT);

		System.Assert.isTrue(
			MetadataTriggerHandler.bypassedActions.contains(TEST_BEFORE_INSERT),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	@IsTest
	private static void clearBypassShouldSucceed() {
		MetadataTriggerHandler.bypass(TEST_BEFORE_INSERT);
		MetadataTriggerHandler.clearBypass(TEST_BEFORE_INSERT);

		System.Assert.isFalse(
			MetadataTriggerHandler.bypassedActions.contains(TEST_BEFORE_INSERT),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	@IsTest
	private static void isBypassedShouldSucceed() {
		Boolean isBypassed;
		MetadataTriggerHandler.bypass(TEST_BEFORE_INSERT);

		isBypassed = MetadataTriggerHandler.isBypassed(TEST_BEFORE_INSERT);

		System.Assert.isTrue(isBypassed, BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY);
	}

	@IsTest
	private static void clearAllBypassesShouldSucceed() {
		MetadataTriggerHandler.bypass(TEST_BEFORE_INSERT);

		MetadataTriggerHandler.clearAllBypasses();

		System.Assert.areEqual(
			0,
			MetadataTriggerHandler.bypassedActions.size(),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	@IsTest
	private static void bypassWithTypeShouldSucceed() {
		MetadataTriggerHandler.bypass(TestBeforeInsert.class);

		System.Assert.isTrue(
			MetadataTriggerHandler.bypassedActions.contains(TEST_BEFORE_INSERT),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	@IsTest
	private static void clearBypassWithTypeShouldSucceed() {
		MetadataTriggerHandler.bypass(TestBeforeInsert.class);
		MetadataTriggerHandler.clearBypass(TestBeforeInsert.class);

		System.Assert.isFalse(
			MetadataTriggerHandler.bypassedActions.contains(TEST_BEFORE_INSERT),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	@IsTest
	private static void isBypassedWithTypeShouldSucceed() {
		Boolean isBypassed;
		MetadataTriggerHandler.bypass(TestBeforeInsert.class);

		isBypassed = MetadataTriggerHandler.isBypassed(TestBeforeInsert.class);

		System.Assert.isTrue(isBypassed, BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY);
	}

	@IsTest
	private static void actionShouldExecuteIfNoRequiredOrBypassPermissionsAreDefinedForSObjectOrAction() {
		MetadataTriggerHandler.selector = new FakeSelector(
			new List<SObject>{ action }
		);

		MetadataTriggerHandler.permissionMap.clear();

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void actionShouldExecuteIfUserDoesNotHaveBypassPermissionForSObjectOrAction() {
		setting.Bypass_Permission__c = BYPASS_PERMISSION;
		action.Bypass_Permission__c = BYPASS_PERMISSION;
		MetadataTriggerHandler.selector = new FakeSelector(
			new List<SObject>{ action }
		);

		MetadataTriggerHandler.permissionMap.clear();

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isTrue(executed, ACTION_SHOULD_EXECUTE);
	}

	@IsTest
	private static void actionShouldNotExecuteIfUserDoesNotHaveRequiredPermissionForSObject() {
		setting.Required_Permission__c = REQUIRED_PERMISSION;
		MetadataTriggerHandler.selector = new FakeSelector(
			new List<SObject>{ action }
		);
		MetadataTriggerHandler.permissionMap = new Map<String, Boolean>{
			REQUIRED_PERMISSION => false
		};

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isFalse(executed, ACTION_SHOULD_NOT_EXECUTE);
	}

	@IsTest
	private static void actionShouldNotExecuteIfUserDoesNotHaveRequiredPermissionForAction() {
		action.Required_Permission__c = REQUIRED_PERMISSION;
		MetadataTriggerHandler.selector = new FakeSelector(
			new List<SObject>{ action }
		);
		MetadataTriggerHandler.permissionMap = new Map<String, Boolean>{
			REQUIRED_PERMISSION => false
		};

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isFalse(executed, ACTION_SHOULD_NOT_EXECUTE);
	}

	@IsTest
	private static void actionShouldNotExecuteIfUserHasBypassPermissionForSObject() {
		setting.Bypass_Permission__c = BYPASS_PERMISSION;
		MetadataTriggerHandler.selector = new FakeSelector(
			new List<SObject>{ action }
		);
		MetadataTriggerHandler.permissionMap = new Map<String, Boolean>{
			BYPASS_PERMISSION => true
		};

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isFalse(executed, ACTION_SHOULD_NOT_EXECUTE);
	}

	@IsTest
	private static void actionShouldNotExecuteIfUserHasBypassPermissionForAction() {
		action.Bypass_Permission__c = BYPASS_PERMISSION;
		MetadataTriggerHandler.selector = new FakeSelector(
			new List<SObject>{ action }
		);
		MetadataTriggerHandler.permissionMap = new Map<String, Boolean>{
			BYPASS_PERMISSION => true
		};

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isFalse(executed, ACTION_SHOULD_NOT_EXECUTE);
	}

	@IsTest
	private static void theFrameworkShouldSupportSObjectsFromManagedPackages() {
		handler.sObjectName = 'Acme__Explosives__c';

		handler.beforeInsert(handler.triggerNew);

		System.Assert.isFalse(executed, ACTION_SHOULD_NOT_EXECUTE);
	}

	@IsTest
	private static void theFrameworkShouldSupportFlow() {
		action.Apex_Class_Name__c = TriggerActionFlow.class.getName();
		action.Flow_Name__c = SAMPLE_FLOW_NAME;
		action.Allow_Flow_Recursion__c = false;
		MetadataTriggerHandler.bypass(TriggerActionFlow.class.getName());

		handler.beforeInsertActionMetadata = new List<Trigger_Action__mdt>{
			action
		};

		try {
			handler.beforeInsert(handler.triggerNew);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areEqual(null, myException, EXCEPTION_SHOULD_NOT_BE_THROWN);
	}

	public class TestBeforeInsert implements TriggerAction.BeforeInsert {
		public void beforeInsert(List<SObject> triggerNew) {
			MetadataTriggerHandlerTest.executed = true;
		}
	}
	public class TestAfterInsert implements TriggerAction.AfterInsert {
		public void afterInsert(List<SObject> triggerNew) {
			MetadataTriggerHandlerTest.executed = true;
		}
	}
	public class TestBeforeUpdate implements TriggerAction.BeforeUpdate {
		public void beforeUpdate(
			List<SObject> triggerNew,
			List<SObject> triggerOld
		) {
			MetadataTriggerHandlerTest.executed = true;
		}
	}
	public class TestAfterUpdate implements TriggerAction.AfterUpdate {
		public void afterUpdate(
			List<SObject> triggerNew,
			List<SObject> triggerOld
		) {
			MetadataTriggerHandlerTest.executed = true;
		}
	}
	public class TestBeforeDelete implements TriggerAction.BeforeDelete {
		public void beforeDelete(List<SObject> triggerOld) {
			MetadataTriggerHandlerTest.executed = true;
		}
	}
	public class TestAfterDelete implements TriggerAction.AfterDelete {
		public void afterDelete(List<SObject> triggerNew) {
			MetadataTriggerHandlerTest.executed = true;
		}
	}
	public class TestAfterUndelete implements TriggerAction.AfterUndelete {
		public void afterUndelete(List<SObject> triggerNew) {
			MetadataTriggerHandlerTest.executed = true;
		}
	}
	public class TestFinalizerHandler extends FinalizerHandler {
		public override void handleDynamicFinalizers() {
			MetadataTriggerHandlerTest.executed = true;
		}
	}

	private class FakeSelector extends MetadataTriggerHandler.Selector {
		List<SObject> results;
		public FakeSelector(List<SObject> results) {
			this.results = results;
		}
		public override List<SObject> query(String queryString) {
			return this.results;
		}
	}
}
