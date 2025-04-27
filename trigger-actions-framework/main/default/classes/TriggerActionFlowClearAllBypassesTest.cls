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

@SuppressWarnings('PMD.ApexDoc, PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(isParallel=true)
private class TriggerActionFlowClearAllBypassesTest {
	private static final String MY_STRING = 'MY_STRING';

	@IsTest
	private static void clearAllBypassObjectShouldSucceedWithValidRequest() {
		TriggerBase.bypass(MY_STRING);

		TriggerActionFlowClearAllBypasses.clearAllBypasses(
			new List<String>{ TriggerActionConstants.OBJECT_STRING }
		);

		System.Assert.isFalse(TriggerBase.isBypassed(MY_STRING), 'The Object should not be bypassed');
	}

	@IsTest
	private static void clearAllBypassApexShouldSucceedWithValidRequest() {
		MetadataTriggerHandler.bypass(MY_STRING);

		TriggerActionFlowClearAllBypasses.clearAllBypasses(
			new List<String>{ TriggerActionConstants.APEX_STRING }
		);

		System.Assert.isFalse(
			MetadataTriggerHandler.isBypassed(MY_STRING),
			'The Apex should be not bypassed'
		);
	}

	@IsTest
	private static void clearAllBypassFlowShouldSucceedWithValidRequest() {
		TriggerActionFlow.bypass(MY_STRING);

		TriggerActionFlowClearAllBypasses.clearAllBypasses(
			new List<String>{ TriggerActionConstants.FLOW_STRING }
		);

		System.Assert.isFalse(
			TriggerActionFlow.isBypassed(MY_STRING),
			'The Flow should not be bypassed'
		);
	}

	@IsTest
	private static void clearAllBypassShouldFailWithInvalidType() {
		Exception myException;

		try {
			TriggerActionFlowClearAllBypasses.clearAllBypasses(new List<String>{ MY_STRING });
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(
			null,
			myException,
			'We should have an exception thrown in this scenario'
		);
		System.Assert.isInstanceOfType(
			myException,
			IllegalArgumentException.class,
			'The exception should be of the correct type'
		);
		System.Assert.areEqual(
			myException.getMessage(),
			TriggerActionConstants.INVALID_TYPE,
			'The exeption should contain the message we are looking for'
		);
	}
}