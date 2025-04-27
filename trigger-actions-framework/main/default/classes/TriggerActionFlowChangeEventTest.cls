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
@SuppressWarnings('PMD.ApexDoc')
@IsTest(isParallel=true)
private with sharing class TriggerActionFlowChangeEventTest {
	private static IllegalArgumentException caught;

	private static AccountChangeEvent changeEvent = new AccountChangeEvent(
		ChangeEventHeader = new EventBus.ChangeEventHeader()
	);

	private static TriggerActionFlowChangeEvent action = new TriggerActionFlowChangeEvent();
	private static List<Map<String, Object>> response;

	@IsTest
	private static void wrongDataTypeShouldThrowException() {
		try {
			response = action.getInterviewInputs(
				new List<SObject>{ new Account() },
				TriggerActionConstants.RECORD_VARIABLE
			);
		} catch (IllegalArgumentException e) {
			caught = e;
		}

		System.Assert.isNotNull(
			caught,
			'The system failed to add an exception when we are expecting one'
		);
	}

	@IsTest
	private static void emptyInputShouldProduceEmptyFlowInputs() {
		response = action.getInterviewInputs(
			new List<SObject>(),
			TriggerActionConstants.RECORD_VARIABLE
		);

		System.Assert.isNotNull(
			response,
			'The system produced a null input to be passed into the invocable flows'
		);
		System.Assert.areEqual(
			0,
			response.size(),
			'There should be exactly zero maps in the produced invocable inputs'
		);
	}

	@IsTest
	private static void correctInputShouldProduceFlowInputs() {
		response = action.getInterviewInputs(
			new List<SObject>{ changeEvent },
			TriggerActionConstants.RECORD_VARIABLE
		);

		System.Assert.isNotNull(
			response,
			'The system produced a null input to be passed into the invocable flows'
		);
		System.Assert.areEqual(
			1,
			response.size(),
			'There should be exactly one map in the produced invocable inputs'
		);
		System.Assert.isTrue(
			response[0].containsKey(TriggerActionConstants.RECORD_VARIABLE),
			'The map should have a key of "record"'
		);
		System.Assert.areEqual(
			changeEvent,
			response[0].get(TriggerActionConstants.RECORD_VARIABLE),
			'The value for "record" is constructed improperly'
		);
		System.Assert.isTrue(
			response[0].containsKey(TriggerActionFlowChangeEvent.HEADER),
			'The map should have a key of "header"'
		);
		System.Assert.areEqual(
			new FlowChangeEventHeader(changeEvent.ChangeEventHeader),
			response[0].get(TriggerActionFlowChangeEvent.HEADER),
			'The value for "header" is constructed improperly'
		);
	}
}