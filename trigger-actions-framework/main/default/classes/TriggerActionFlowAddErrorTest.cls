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
private class TriggerActionFlowAddErrorTest {
	private static final String MY_STRING = 'MY_STRING';
	private static final String NAME = 'Name';
	private static List<TriggerActionFlowAddError.Request> requests = new List<TriggerActionFlowAddError.Request>();
	private static TriggerActionFlowAddError.Request request = new TriggerActionFlowAddError.Request();

	@IsTest
	private static void addErrorShouldSucceedWithValidRequest() {
		Account account = new Account();
		request.errorMessage = MY_STRING;
		request.record = account;
		requests.add(request);

		TriggerActionFlowAddError.addError(requests);

		System.Assert.isTrue(
			account.hasErrors(),
			'The Account should have an error'
		);
		System.Assert.areEqual(
			1,
			account.getErrors().size(),
			'There should only be one error'
		);
		System.Assert.areEqual(
			MY_STRING,
			account.getErrors()[0].getMessage(),
			'The error should contain the message we are looking for'
		);
	}

	@IsTest
	private static void addErrorShouldAddAnErrorAtTheFieldSpecified() {
		Account account = new Account();
		request.errorMessage = MY_STRING;
		request.fieldName = NAME;
		request.record = account;
		requests.add(request);

		TriggerActionFlowAddError.addError(requests);

		System.Assert.isTrue(
			account.hasErrors(),
			'The Account should have an error'
		);
		System.Assert.areEqual(
			1,
			account.getErrors().size(),
			'There should only be one error'
		);
		System.Assert.areEqual(
			MY_STRING,
			account.getErrors()[0].getMessage(),
			'The error should contain the message we are looking for'
		);
	}
}
