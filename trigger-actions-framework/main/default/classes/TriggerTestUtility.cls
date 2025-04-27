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

/**
 * @group Trigger Actions Framework
 * @description The `TriggerTestUtility` class is a utility class that provides helper methods for writing
 * Apex test classes for trigger handlers.
 *
 * The `TriggerTestUtility` class provides the following helper methods:
 *
 * - `getFakeId`: This method generates a fake ID for the specified sObject type.
 */
@IsTest
public class TriggerTestUtility {
	private static Integer myNumber = 1;

	/**
	 * @description This method generates a fake ID for the specified sObject type.
	 *
	 * @param sObjectType The sObject type to generate a fake ID for.
	 * @return A fake ID for the specified sObject type.
	 */
	public static Id getFakeId(Schema.SObjectType sObjectType) {
		String result = String.valueOf(myNumber++);
		return (Id) (sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() +
		'0'.repeat(12 - result.length()) +
		result);
	}
}