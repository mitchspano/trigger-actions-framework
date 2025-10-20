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

@SuppressWarnings(
	'PMD.ApexDoc,PMD.ApexUnitTestClassShouldHaveRunAs,PMD.CyclomaticComplexity'
)
@IsTest(isParallel=true)
private class TriggerActionFlowTest {
	private static final String BOGUS = 'Bogus';
	private static final String BYPASSES_SHOULD_BE_POPULATED_CORRECTLY = 'Static bypasses should be populated properly';
	private static final String ERROR_MESSAGE_SHOULD_MATCH = 'The message should be what we expect';
	private static final String ERROR_SHOULD_BE_ADDED = 'There should be an error added to the record';
	private static final String ERROR_SHOULD_NOT_BE_ADDED = 'There should not be an error added to the record';
	private static final String ERROR_NOT_NULLED_AFTER_FLOW = 'Field nulled in Flow was not written back to record variable';
	private static final String EXCEPTION_SHOULD_BE_THROWN = 'An exception should be thrown';
	private static final String EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE = 'The exception should have the correct message';
	private static final String EXCEPTION_SHOULD_NOT_BE_THROWN = 'There should be no exception thrown when this method is called with a valid flow.';
	private static final String FOO = 'Foo';
	private static final String MY_ACCOUNT = 'My Account';
	private static final String NAME_SET_FROM_FLOW = 'The name should be set from the flow';
	private static final String NAME_SHOULD_REMAIN_SAME = 'The name should remain the same as it was';
	private static final String OLD_NAME = 'Old Name';
	private static final String ONE_ERROR = 'There should be exactly one error';
	private static final String SAMPLE_FLOW_NAME = 'TriggerActionFlowTest';
	private static final String TEST = 'Test!';
	private static final String SAMPLE_FLOW_TYPE_NAME =
		TriggerActionFlow.FLOW_INTERVIEW_PREFIX +
		'.' +
		SAMPLE_FLOW_NAME;

	private static Account myAccount = new Account(
		Name = MY_ACCOUNT,
		Id = TriggerTestUtility.getFakeId(Schema.Account.SObjectType)
	);
	private static Account oldAccount = new Account(
		Name = OLD_NAME,
		Id = myAccount.Id
	);
	private static Account myAccountAfterFlow = myAccount.clone(true);
	private static List<SObject> triggerNew = new List<SObject>{ myAccount };
	private static List<SObject> triggerOld = new List<SObject>{ oldAccount };
	private static TriggerActionFlow actionFlow;
	private static Exception myException;

	private static Invocable.Action.Result successResult = new InvocableActionResultBuilder()
		.setSuccess(true)
		.setOutputParameters(
			new Map<String, Object>{
				TriggerActionConstants.RECORD_VARIABLE => myAccountAfterFlow
			}
		)
		.build();

	static {
		actionFlow = new TriggerActionFlow();
		actionFlow.flowName = SAMPLE_FLOW_NAME;
		actionFlow.allowRecursion = true;
		myAccountAfterFlow.Name = FOO;
		myAccountAfterFlow.addError(TEST);
		TriggerActionFlow.invocableAction = new FakeInvocableAction(
			new List<Invocable.Action.Result>{ successResult }
		);
	}

	@IsTest
	private static void shouldDoNothingWhenBypassed() {
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);

		try {
			actionFlow.beforeInsert(triggerNew);
			actionFlow.afterInsert(triggerNew);
			actionFlow.beforeUpdate(triggerNew, triggerOld);
			actionFlow.afterUpdate(triggerNew, triggerOld);
			actionFlow.beforeDelete(triggerOld);
			actionFlow.afterDelete(triggerOld);
			actionFlow.afterUndelete(triggerOld);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.isNull(
			myException,
			'There should be no exception thrown and the System should do nothing when the flow is bypassed'
		);
	}

	@IsTest
	private static void validateTypeShouldThrowExceptionWithInvalidInput() {
		try {
			TriggerActionFlow.validateType(BOGUS);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);

		System.Assert.areEqual(
			TriggerActionConstants.INVALID_TYPE,
			myException.getMessage(),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void emptyFlowNameShouldThrowException() {
		actionFlow.flowName = null;

		try {
			actionFlow.beforeInsert(triggerNew);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);

		System.Assert.areEqual(
			TriggerActionConstants.INVALID_FLOW_NAME,
			myException.getMessage(),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void beforeInsertShouldSucceed() {
		actionFlow.beforeInsert(triggerNew);

		System.Assert.areEqual(FOO, myAccount.Name, NAME_SET_FROM_FLOW);
		System.Assert.areEqual(true, myAccount.hasErrors(), ERROR_SHOULD_BE_ADDED);
		System.Assert.areEqual(1, myAccount.getErrors().size(), ONE_ERROR);
		System.Assert.areEqual(
			TEST,
			myAccount.getErrors()[0].getMessage(),
			ERROR_MESSAGE_SHOULD_MATCH
		);
	}

	@IsTest
	private static void afterInsertShouldSucceed() {
		actionFlow.afterInsert(triggerNew);

		System.Assert.areEqual(
			false,
			myAccount.hasErrors(),
			ERROR_SHOULD_NOT_BE_ADDED
		);
	}

	@IsTest
	private static void beforeUpdateShouldSucceed() {
		actionFlow.beforeUpdate(triggerNew, triggerOld);

		System.Assert.areEqual(FOO, myAccount.Name, NAME_SET_FROM_FLOW);
		System.Assert.areEqual(true, myAccount.hasErrors(), ERROR_SHOULD_BE_ADDED);
		System.Assert.areEqual(1, myAccount.getErrors().size(), ONE_ERROR);
		System.Assert.areEqual(
			TEST,
			myAccount.getErrors()[0].getMessage(),
			ERROR_MESSAGE_SHOULD_MATCH
		);
	}

	@IsTest
	private static void beforeUpdateWithNoRecordsToProcessShouldSucceed() {
		triggerNew.clear();
		triggerOld.clear();

		actionFlow.beforeUpdate(triggerNew, triggerOld);

		System.Assert.areEqual(MY_ACCOUNT, myAccount.Name, NAME_SHOULD_REMAIN_SAME);
	}

	@IsTest
	private static void afterUpdateShouldSucceed() {
		actionFlow.afterUpdate(triggerNew, triggerOld);

		System.Assert.areEqual(
			false,
			myAccount.hasErrors(),
			ERROR_SHOULD_NOT_BE_ADDED
		);
	}

	@IsTest
	private static void afterUpdateWithNoRecordsToProcessShouldSucceed() {
		triggerNew.clear();
		triggerOld.clear();

		actionFlow.afterUpdate(triggerNew, triggerOld);

		System.Assert.areEqual(
			false,
			myAccount.hasErrors(),
			ERROR_SHOULD_NOT_BE_ADDED
		);
	}

	@IsTest
	private static void beforeDeleteShouldSucceed() {
		actionFlow.beforeDelete(triggerOld);

		System.Assert.areEqual(
			false,
			oldAccount.hasErrors(),
			ERROR_SHOULD_NOT_BE_ADDED
		);
	}

	@IsTest
	private static void afterDeleteShouldSucceed() {
		actionFlow.afterDelete(triggerOld);

		System.Assert.areEqual(
			false,
			oldAccount.hasErrors(),
			ERROR_SHOULD_NOT_BE_ADDED
		);
	}

	@IsTest
	private static void afterUndeleteShouldSucceed() {
		actionFlow.afterUndelete(triggerOld);

		System.Assert.areEqual(
			false,
			myAccount.hasErrors(),
			ERROR_SHOULD_NOT_BE_ADDED
		);
	}

	@IsTest
	private static void flowMissingRecordVariableInOutputShouldThrowException() {
		successResult.getOutputParameters().clear();

		try {
			actionFlow.beforeInsert(triggerNew);
		} catch (IllegalArgumentException e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);

		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.RECORD_VARIABLE_NOT_FOUND_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void noRecordMutationsShouldSucceed() {
		successResult.getOutputParameters()
			.put(TriggerActionConstants.RECORD_VARIABLE, myAccount);

		actionFlow.beforeInsert(triggerNew);

		System.Assert.areEqual(
			false,
			myAccount.hasErrors(),
			ERROR_SHOULD_NOT_BE_ADDED
		);
	}

	@IsTest
	private static void nulledFieldInFlowShouldBeTransferredBack() {
		myAccount.BillingStreet = TEST;
		oldAccount.BillingStreet = TEST;
		myAccountAfterFlow = myAccount.clone(true);
		myAccountAfterFlow.BillingStreet = null;

		actionFlow.beforeUpdate(triggerNew, triggerOld);

		System.Assert.isNull(myAccount.BillingStreet, ERROR_NOT_NULLED_AFTER_FLOW);
	}

	@IsTest
	private static void unsuccessfulActionResultShouldBeAddedAsErrorToRecord() {
		TriggerActionFlow.invocableAction = new FakeInvocableAction(
			new List<Invocable.Action.Result>{
				new InvocableActionResultBuilder()
					.setSuccess(false)
					.setOutputParameters(
						new Map<String, Object>{
							TriggerActionConstants.RECORD_VARIABLE => myAccountAfterFlow
						}
					)
					.setErrors(
						new List<Invocable.Action.Error>{
							new InvocableActionErrorBuilder()
								.setCode(TEST)
								.setMessage(FOO)
								.build()
						}
					)
					.build()
			}
		);

		actionFlow.beforeInsert(triggerNew);

		System.Assert.areEqual(true, myAccount.hasErrors(), ERROR_SHOULD_BE_ADDED);
		System.Assert.areEqual(1, myAccount.getErrors().size(), ONE_ERROR);
		System.Assert.areEqual(
			true,
			myAccount.getErrors()[0].getMessage().contains(FOO),
			ERROR_MESSAGE_SHOULD_MATCH
		);
	}

	@IsTest
	private static void bypassShouldSucceed() {
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);

		System.Assert.isTrue(
			TriggerActionFlow.bypassedFlows.contains(SAMPLE_FLOW_NAME),
			BYPASSES_SHOULD_BE_POPULATED_CORRECTLY
		);
	}

	@IsTest
	private static void clearBypassShouldSucceed() {
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);
		TriggerActionFlow.clearBypass(SAMPLE_FLOW_NAME);

		System.Assert.isFalse(
			TriggerActionFlow.bypassedFlows.contains(SAMPLE_FLOW_NAME),
			BYPASSES_SHOULD_BE_POPULATED_CORRECTLY
		);
	}

	@IsTest
	private static void isBypassedShouldSucceed() {
		Boolean isBypassed;
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);

		isBypassed = TriggerActionFlow.isBypassed(SAMPLE_FLOW_NAME);

		System.Assert.isTrue(isBypassed, BYPASSES_SHOULD_BE_POPULATED_CORRECTLY);
	}

	@IsTest
	private static void clearAllBypassesShouldSucceed() {
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);

		TriggerActionFlow.clearAllBypasses();

		System.Assert.areEqual(
			0,
			TriggerActionFlow.bypassedFlows.size(),
			BYPASSES_SHOULD_BE_POPULATED_CORRECTLY
		);
	}

	@IsTest
	private static void bypassWithTypeShouldSucceed() {
		TriggerActionFlow.nameExtractor = new FakeNameExtractor(
			SAMPLE_FLOW_TYPE_NAME
		);
		TriggerActionFlow.bypass(Flow.Interview.TriggerActionFlowTest.class);

		System.Assert.isTrue(
			TriggerActionFlow.bypassedFlows.contains(SAMPLE_FLOW_NAME),
			BYPASSES_SHOULD_BE_POPULATED_CORRECTLY
		);
	}

	@IsTest
	private static void clearBypassWithTypeShouldSucceed() {
		TriggerActionFlow.nameExtractor = new FakeNameExtractor(
			SAMPLE_FLOW_TYPE_NAME
		);
		TriggerActionFlow.bypass(Flow.Interview.TriggerActionFlowTest.class);
		TriggerActionFlow.clearBypass(Flow.Interview.TriggerActionFlowTest.class);

		System.Assert.isFalse(
			TriggerActionFlow.bypassedFlows.contains(SAMPLE_FLOW_NAME),
			BYPASSES_SHOULD_BE_POPULATED_CORRECTLY
		);
	}

	@IsTest
	private static void isBypassedWithTypeShouldSucceed() {
		TriggerActionFlow.nameExtractor = new FakeNameExtractor(
			SAMPLE_FLOW_TYPE_NAME
		);
		Boolean isBypassed;
		TriggerActionFlow.bypass(Flow.Interview.TriggerActionFlowTest.class);

		isBypassed = TriggerActionFlow.isBypassed(
			Flow.Interview.TriggerActionFlowTest.class
		);

		System.Assert.isTrue(isBypassed, BYPASSES_SHOULD_BE_POPULATED_CORRECTLY);
	}

	@IsTest
	private static void bypassWithInvalidTypeShouldThrowException() {
		try {
			TriggerActionFlow.bypass(String.class);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.TYPE_MUST_REPRESENT_FLOW_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void clearBypassWithInvalidTypeShouldThrowException() {
		try {
			TriggerActionFlow.clearBypass(String.class);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.TYPE_MUST_REPRESENT_FLOW_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void isBypassedWithInvalidTypeShouldThrowException() {
		try {
			TriggerActionFlow.isBypassed(String.class);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.TYPE_MUST_REPRESENT_FLOW_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void bypassWithNonExistentFlowShouldThrowException() {
		try {
			TriggerActionFlow.bypass(
				Flow.Interview.SomeBogusClassWhichDoesNotExist.class
			);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.FLOW_DOES_NOT_EXIST_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void bypassWithNullTypeShouldThrowException() {
		try {
			TriggerActionFlow.bypass((System.Type) null);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.TYPE_MUST_BE_PROVIDED_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void clearBypassWithNullTypeShouldThrowException() {
		try {
			TriggerActionFlow.clearBypass((System.Type) null);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.TYPE_MUST_BE_PROVIDED_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void isBypassedWithNullTypeShouldThrowException() {
		try {
			TriggerActionFlow.isBypassed((System.Type) null);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(null, myException, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			true,
			myException.getMessage()
				.contains(TriggerActionFlow.TYPE_MUST_BE_PROVIDED_ERROR),
			EXCEPTION_SHOULD_HAVE_THE_CORRECT_MESSAGE
		);
	}

	@IsTest
	private static void invokeFlowShouldReturnUnsuccessfulResponseWithBogusFlowName() {
		List<Invocable.Action.Result> results = new TriggerActionFlow.InvocableAction()
			.invokeAction(
				BOGUS,
				new List<Map<String, Object>>{ new Map<String, Object>() }
			);

		System.Assert.areEqual(1, results.size(), ONE_ERROR);
		System.Assert.areEqual(
			false,
			results[0].isSuccess(),
			'It should have failed with bogus name'
		);
	}

	private virtual class FakeInvocableAction extends TriggerActionFlow.InvocableAction {
		List<Invocable.Action.Result> result;
		public FakeInvocableAction(List<Invocable.Action.Result> result) {
			this.result = result;
		}
		public override List<Invocable.Action.Result> invokeAction(
			String flowApiName,
			List<Map<String, Object>> inputs
		) {
			return this.result;
		}
	}

	private class InvocableActionResultBuilder {
		private Map<String, Object> outputParameters;
		private Boolean success;
		private Invocable.Action action;
		private List<Invocable.Action.Error> errors;

		public InvocableActionResultBuilder setOutputParameters(
			Map<String, Object> outputParameters
		) {
			this.outputParameters = outputParameters;
			return this;
		}
		@SuppressWarnings('PMD.AvoidBooleanMethodParameters')
		public InvocableActionResultBuilder setSuccess(Boolean success) {
			this.success = success;
			return this;
		}
		public InvocableActionResultBuilder setAction(Invocable.Action action) {
			this.action = action;
			return this;
		}
		public InvocableActionResultBuilder setErrors(
			List<Invocable.Action.Error> errors
		) {
			this.errors = errors;
			return this;
		}

		public Invocable.Action.Result build() {
			Invocable.Action.Result result = (Invocable.Action.Result) JSON.deserialize(
				JSON.serialize(
					new Map<String, Object>{
						'action' => action,
						'errors' => errors,
						'success' => success,
						'outputParameters' => new Map<String, Object>()
					}
				),
				Invocable.Action.Result.class
			);
			result.getOutputParameters().putAll(this.outputParameters);
			return result;
		}
	}

	private class InvocableActionErrorBuilder {
		private String code;
		private String message;

		public InvocableActionErrorBuilder setCode(String code) {
			this.code = code;
			return this;
		}
		public InvocableActionErrorBuilder setmessage(String message) {
			this.message = message;
			return this;
		}

		public Invocable.Action.error build() {
			return (Invocable.Action.error) JSON.deserialize(
				JSON.serialize(
					new Map<String, Object>{ 'code' => code, 'message' => message }
				),
				Invocable.Action.error.class
			);
		}
	}

	private class FakeNameExtractor extends TriggerActionFlow.NameExtractor {
		private String mockTypeName;

		public FakeNameExtractor(String mockTypeName) {
			this.mockTypeName = mockTypeName;
		}

		public override String extractName(System.Type flowType) {
			return this.mockTypeName;
		}
	}
}
