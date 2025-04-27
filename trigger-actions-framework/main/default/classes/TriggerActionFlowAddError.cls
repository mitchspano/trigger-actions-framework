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
 * @description This class provides an Invocable method that can be used to add an error to an sObject.
 *
 * The Invocable method is called `addError` and it takes a list of `Request` objects as input.
 * Each `Request` object contains the following properties:
 *
 * - `record`: The sObject to add the error to.
 * - `fieldName`: The API name of the field to add the error to.
 * - `errorMessage`: The error message to add.
 *
 * ---
 *
 * If the `fieldName` property is not specified, the error message will be added to the sObject without a field name.
 *
 */
public inherited sharing class TriggerActionFlowAddError {
	/**
	 * @description This Invocable method adds an error to an sObject.
	 *
	 * @param requests A list of `Request` objects.
	 */
	@InvocableMethod(
		category='Trigger Action Flow'
		label='Add Error'
		description='Adds an error to an sObject'
	)
	public static void addError(List<Request> requests) {
		for (Request myRequest : requests) {
			if (!String.isBlank(myRequest.fieldName)) {
				myRequest.record.addError(myRequest.fieldName, myRequest.errorMessage);
			} else {
				myRequest.record.addError(myRequest.errorMessage);
			}
		}
	}

	/**
	 * @description This class represents a request to add an error to an sObject.
	 */
	public class Request {
		@InvocableVariable(label='Record' description='Record to add the error to' required=true)
		public SObject record;
		@InvocableVariable(label='Field Name' description='API name of corresponding field')
		public String fieldName;
		@InvocableVariable(label='Error Message' description='Error Message' required=true)
		public String errorMessage;
	}
}