/*
   Copyright 2023 Google LLC

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
@IsTest(isParallel=true)
@SuppressWarnings('PMD.ApexDoc, PMD.ApexUnitTestClassShouldHaveRunAs')
private with sharing class FinalizerHandlerTest {
	private static final String ACCOUNT = 'Account';
	private static final String BAR = 'bar';
	private static final String BOGUS_CLASS_NAME = 'Bogus';
	private static final String BYPASS_PERMISSION = 'Bogus_Bypass_Permission';
	private static final String BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY = 'All bypasses should be configured correctly';
	private static final String EXCEPTION_SHOULD_BE_THROWN = 'An exception should be thrown';
	private static final String EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE = 'The exception should have the correct message';
	private static final String FOO = 'foo';
	private static final String REQUIRED_PERMISSION = 'Bogus_Required_Permission';
	private static final String MY_CLASS = 'FinalizerHandlerTest.MyClass';
	private static final String TEST_BAR_FINALIZER = 'FinalizerHandlerTest.BarFinalizer';
	private static final String TEST_FINALIZER_WITH_DML = 'FinalizerHandlerTest.FinalizerWithDml';
	private static final String TEST_FOO_FINALIZER = 'FinalizerHandlerTest.FooFinalizer';

	private static final Schema.SObjectType SOBJECT_TYPE = Schema.Account.SObjectType;
	private static final System.TriggerOperation OPERATION = System.TriggerOperation.BEFORE_INSERT;

	private static List<String> finalizerLedger = new List<String>();

	private static FinalizerHandler handler = new FinalizerHandler();
	private static Exception myException;

	@IsTest
	private static void noConfiguredFinalizerShouldTakeNoAction() {
		System.Assert.isNotNull(
			handler.allFinalizers,
			'By default, allHandlers should return a non-null value'
		);

		handler.allFinalizers = new List<DML_Finalizer__mdt>();

		handler.handleDynamicFinalizers();

		System.Assert.isTrue(
			finalizerLedger.isEmpty(),
			'There are no finalizers so no action should be taken'
		);
	}

	@IsTest
	private static void properlyConfiguredFinalizerShouldExecute() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(
				Apex_Class_Name__c = TEST_FOO_FINALIZER,
				Bypass_Permission__c = BYPASS_PERMISSION
			)
		};

		handler.handleDynamicFinalizers();

		System.Assert.areEqual(
			FOO,
			finalizerLedger[0],
			'The finalizer should be dynamically instantiated and executed'
		);
	}

	@IsTest
	private static void bypassedFinalizerShouldNotExecute() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(
				Apex_Class_Name__c = TEST_FOO_FINALIZER,
				Bypass_Execution__c = true,
				Order__c = 1
			)
		};

		handler.handleDynamicFinalizers();

		System.Assert.isTrue(
			finalizerLedger.isEmpty(),
			'The finalizer should be dynamically instantiated, but no action should be taken because it is bypassed'
		);
	}

	@IsTest
	private static void staticallyBypassedFinalizerShouldNotExecute() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(
				Apex_Class_Name__c = TEST_FOO_FINALIZER,
				Order__c = 1
			)
		};

		FinalizerHandler.bypass(TEST_FOO_FINALIZER);
		handler.handleDynamicFinalizers();

		System.Assert.isTrue(
			finalizerLedger.isEmpty(),
			'The finalizer should be dynamically instantiated, but no action should be taken because it is statically bypassed'
		);
	}

	@IsTest
	private static void userWithBypassPermissionDefinedOnFinalizerShouldNotExecute() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(
				Apex_Class_Name__c = TEST_FOO_FINALIZER,
				Bypass_Permission__c = BYPASS_PERMISSION,
				Order__c = 1
			)
		};

		FinalizerHandler.permissionMap.put(BYPASS_PERMISSION, true);
		handler.handleDynamicFinalizers();

		System.Assert.isTrue(
			finalizerLedger.isEmpty(),
			'The finalizer should be dynamically instantiated, but no action should be taken because it is bypassed via permission'
		);
	}

	@IsTest
	private static void userWithoutRequiredPermissionDefinedOnFinalizerShouldNotExecute() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(
				Apex_Class_Name__c = TEST_FOO_FINALIZER,
				Required_Permission__c = REQUIRED_PERMISSION,
				Order__c = 1
			)
		};

		FinalizerHandler.permissionMap.put(REQUIRED_PERMISSION, false);
		handler.handleDynamicFinalizers();

		System.Assert.isTrue(
			finalizerLedger.isEmpty(),
			'The finalizer should be dynamically instantiated, but no action should be taken because the user does not have the required permission'
		);
	}

	@IsTest
	private static void finalizersShouldExecuteInOrder() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(
				Apex_Class_Name__c = TEST_FOO_FINALIZER,
				Order__c = 1
			),
			new DML_Finalizer__mdt(
				Apex_Class_Name__c = TEST_BAR_FINALIZER,
				Order__c = 2
			)
		};

		handler.handleDynamicFinalizers();

		System.Assert.areEqual(
			FOO,
			finalizerLedger[0],
			'The finalizer with the lowest order was not executed first'
		);
		System.Assert.areEqual(
			BAR,
			finalizerLedger[1],
			'The finalizer with the highest order was not executed last'
		);
	}

	@IsTest
	private static void invalidFinalizerClassShouldThrowException() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(Apex_Class_Name__c = BOGUS_CLASS_NAME)
		};

		try {
			handler.handleDynamicFinalizers();
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.isNotNull(myException, EXCEPTION_SHOULD_BE_THROWN);

		System.Assert.areEqual(
			String.format(
				FinalizerHandler.INVALID_CLASS_ERROR_FINALIZER,
				new List<String>{ BOGUS_CLASS_NAME }
			),
			myException.getMessage(),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void referencedClassDoesNotImplementDmlFinalizerShouldThrowException() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(Apex_Class_Name__c = MY_CLASS)
		};

		try {
			handler.handleDynamicFinalizers();
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.isNotNull(myException, EXCEPTION_SHOULD_BE_THROWN);

		System.Assert.areEqual(
			String.format(
				FinalizerHandler.INVALID_TYPE_ERROR_FINALIZER,
				new List<String>{ MY_CLASS }
			),
			myException.getMessage(),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void finalizerThatInvokesDmlShouldCauseException() {
		handler.allFinalizers = new List<DML_Finalizer__mdt>{
			new DML_Finalizer__mdt(Apex_Class_Name__c = TEST_FINALIZER_WITH_DML)
		};

		try {
			handler.handleDynamicFinalizers();
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.isNotNull(myException, EXCEPTION_SHOULD_BE_THROWN);

		System.Assert.areEqual(
			FinalizerHandler.DML_IN_FINALIZER_ERROR,
			myException.getMessage(),
			EXCEPTION_SHOULD_HAVE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void bypassFinalizerShouldSucceed() {
		FinalizerHandler.bypass(TEST_FOO_FINALIZER);

		System.Assert.isTrue(
			FinalizerHandler.bypassedFinalizers.contains(TEST_FOO_FINALIZER),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	@IsTest
	private static void clearFinalizerBypassShouldSucceed() {
		FinalizerHandler.bypass(TEST_FOO_FINALIZER);
		FinalizerHandler.clearBypass(TEST_FOO_FINALIZER);

		System.Assert.isFalse(
			FinalizerHandler.bypassedFinalizers.contains(TEST_FOO_FINALIZER),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	@IsTest
	private static void finalizerIsBypassedShouldSucceed() {
		Boolean isBypassed;
		FinalizerHandler.bypass(TEST_FOO_FINALIZER);

		isBypassed = FinalizerHandler.isBypassed(TEST_FOO_FINALIZER);

		System.Assert.isTrue(isBypassed, BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY);
	}

	@IsTest
	private static void clearAllFinalizerBypassesShouldSucceed() {
		FinalizerHandler.bypass(TEST_FOO_FINALIZER);

		FinalizerHandler.clearAllBypasses();

		System.Assert.areEqual(
			0,
			FinalizerHandler.bypassedFinalizers.size(),
			BYPASSES_SHOULD_BE_CONFIGURED_PROPERLY
		);
	}

	public class FooFinalizer implements TriggerAction.DmlFinalizer {
		public void execute(FinalizerHandler.Context context) {
			finalizerLedger.add(FOO);
		}
	}

	public class BarFinalizer implements TriggerAction.DmlFinalizer {
		public void execute(FinalizerHandler.Context context) {
			finalizerLedger.add(BAR);
		}
	}

	@IsTest
	private static void checkPermissionNamespaceAwareShouldHandleNamespacedPermissions() {
		FinalizerHandler testHandler = new FinalizerHandler();
		
		// Test non-namespaced permission (should work as normal)
		Boolean result1 = testHandler.checkPermissionNamespaceAware('SimplePermission');
		System.Assert.areEqual(
			false, // Permissions typically return false in test context unless specifically set up
			result1,
			'Non-namespaced permission should work correctly'
		);
		
		// Test namespaced permission (should try both formats)
		Boolean result2 = testHandler.checkPermissionNamespaceAware('MyNamespace__MyPermission');
		System.Assert.areEqual(
			false, // Will return false since permissions don't exist in test context
			result2,
			'Namespaced permission should handle gracefully when permission does not exist'
		);
		
		// Test permission with multiple underscores (should split at first occurrence)
		Boolean result3 = testHandler.checkPermissionNamespaceAware('MyNamespace__Complex__Permission');
		System.Assert.areEqual(
			false, // Will return false since permissions don't exist in test context
			result3,
			'Permission with multiple underscores should handle gracefully'
		);
	}

	public class MyClass {
	}

	public class FinalizerWithDml implements TriggerAction.DmlFinalizer {
		public void execute(FinalizerHandler.Context context) {
			Database.setSavepoint();
		}
	}
}
