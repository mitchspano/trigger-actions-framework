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
private class TriggerActionFlowBypassTest {
	private static final String MY_STRING = 'MY_STRING';
	private static List<TriggerActionFlowBypass.Request> requests = new List<TriggerActionFlowBypass.Request>();
	private static TriggerActionFlowBypass.Request request = new TriggerActionFlowBypass.Request();
	private static Exception myException;

	@IsTest
	private static void bypassObjectShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionConstants.OBJECT_STRING;
		requests.add(request);

		TriggerActionFlowBypass.bypass(requests);

		System.Assert.isTrue(TriggerBase.isBypassed(MY_STRING), 'The Object should be bypassed');
	}

	@IsTest
	private static void bypassApexShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionConstants.APEX_STRING;
		requests.add(request);

		TriggerActionFlowBypass.bypass(requests);

		System.Assert.isTrue(
			MetadataTriggerHandler.isBypassed(MY_STRING),
			'The Apex should be bypassed'
		);
	}

	@IsTest
	private static void bypassFlowShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionConstants.FLOW_STRING;
		requests.add(request);

		TriggerActionFlowBypass.bypass(requests);

		System.Assert.isTrue(TriggerActionFlow.isBypassed(MY_STRING), 'The Flow should be bypassed');
	}

	@IsTest
	private static void bypassShouldFailWithInvalidType() {
		request.Name = MY_STRING;
		request.bypassType = MY_STRING;
		requests.add(request);

		try {
			TriggerActionFlowBypass.bypass(requests);
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(
			null,
			myException,
			'We should have an exception thrown in this scenario'
		);
		Assert.isInstanceOfType(
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