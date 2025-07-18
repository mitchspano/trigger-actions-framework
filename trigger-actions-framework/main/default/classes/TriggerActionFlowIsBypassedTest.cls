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
@IsTest(IsParallel=true)
private class TriggerActionFlowIsBypassedTest {
	private static final String MY_STRING = 'MY_STRING';
	private static List<TriggerActionFlowIsBypassed.Request> requests = new List<TriggerActionFlowIsBypassed.Request>();
	private static TriggerActionFlowIsBypassed.Request request = new TriggerActionFlowIsBypassed.Request();
	private static Exception myException;

	@IsTest
	private static void isBypassedObjectShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionConstants.OBJECT_STRING;
		requests.add(request);

		List<Boolean> isBypassed = TriggerActionFlowIsBypassed.isBypassed(requests);

		System.Assert.areEqual(
			1,
			isBypassed.size(),
			'We should only have one result for our request'
		);
		System.Assert.areEqual(
			TriggerBase.isBypassed(MY_STRING),
			isBypassed[0],
			'The result should contain the same result as the TriggerBase'
		);
	}

	@IsTest
	private static void isBypassedApexShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionConstants.APEX_STRING;
		requests.add(request);

		List<Boolean> isBypassed = TriggerActionFlowIsBypassed.isBypassed(requests);

		System.Assert.areEqual(
			1,
			isBypassed.size(),
			'We should only have one result for our request'
		);
		System.Assert.areEqual(
			MetadataTriggerHandler.isBypassed(MY_STRING),
			isBypassed[0],
			'The result should contain the same result as the MetadataTriggerHandler'
		);
	}

	@IsTest
	private static void isBypassedFlowShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionConstants.FLOW_STRING;
		requests.add(request);

		List<Boolean> isBypassed = TriggerActionFlowIsBypassed.isBypassed(requests);

		System.Assert.areEqual(
			1,
			isBypassed.size(),
			'We should only have one result for our request'
		);
		System.Assert.areEqual(
			TriggerActionFlow.isBypassed(MY_STRING),
			isBypassed[0],
			'The result should contain the same result as the TriggerActionFlow'
		);
	}

	@IsTest
	private static void isBypassedShouldFailWithInvalidType() {
		request.Name = MY_STRING;
		request.bypassType = MY_STRING;
		requests.add(request);
		List<Boolean> isBypassed;

		try {
			isBypassed = TriggerActionFlowIsBypassed.isBypassed(requests);
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
