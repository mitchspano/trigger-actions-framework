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
 * @description The `TriggerActionFlowIsBypassed` class is a utility class that handles the checking of
 * bypasses for objects, Apex actions, or Flow actions.
 *
 * Bypasses are used to prevent the execution of specific Trigger Actions.
 * The `TriggerActionFlowIsBypassed` class provides a way to check if the bypass is set
 * to `true` for a specific object, Apex action, or Flow action.
 *
 * To use the `TriggerActionFlowIsBypassed` class, you must first create a list of the objects,
 * Apex actions, or Flow actions that you want to check the bypasses for.
 * You can then call the `isBypassed` method of the `TriggerActionFlowIsBypassed` class and
 * pass the list of objects, Apex actions, or Flow actions as the input parameter.
 *
 * The `isBypassed` method will return a list of booleans indicating whether the bypass is set
 * to `true` for each of the specified objects, Apex actions, or Flow actions.
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class TriggerActionFlowIsBypassed {
	/**
	 * @description This method checks if the bypass is set to `true` for the specified objects,
	 * Apex actions, or Flow actions.
	 *
	 * @param requests A list of the objects, Apex actions, or Flow actions to check the bypasses for.
	 * @return A list of booleans indicating whether the bypass is set to `true` for each of the
	 * specified objects, Apex actions, or Flow actions.
	 */
	@InvocableMethod(
		category='Trigger Action Flow'
		label='Is Bypassed'
		description='Returns if the bypass for this object, apex action, or flow action is set to true.'
	)
	public static List<Boolean> isBypassed(List<Request> requests) {
		List<Boolean> results = new List<Boolean>();
		FlowIsBypassedProcesser bypassProcesser = new FlowIsBypassedProcesser();
		for (Request myRequest : requests) {
			bypassProcesser.execute(myRequest.bypassType, myRequest.name);
			results.add(bypassProcesser.getHasBeenBypassed());
		}
		return results;
	}

	/**
	 * @description The `Request` class is a class that represents a request to check if the bypass is set to `true` for a specific object, Apex action, or Flow action.
	 *
	 * To use the `Request` class, you must specify the following properties:
	 *
	 * - `name`: The API name of the object, Apex action, or Flow action to check the bypass for.
	 * - `bypassType`: The type of bypass to check. Valid values are `Apex`, `Flow`, or `Object`.
	 */
	public class Request {
		@InvocableVariable
		public String name;
		@InvocableVariable
		public String bypassType;
	}

	private class FlowIsBypassedProcesser extends TriggerActionFlowBypassProcessor {
		private Boolean hasBeenBypassed = false;

		/**
		 * @description This method returns the value of the `hasBeenBypassed` property.
		 *
		 * @return The value of the `hasBeenBypassed` property.
		 */
		public Boolean getHasBeenBypassed() {
			return this.hasBeenBypassed;
		}

		protected override void processApexBypasses(String name) {
			this.hasBeenBypassed = MetadataTriggerHandler.isBypassed(name);
		}

		protected override void processFlowBypasses(String name) {
			this.hasBeenBypassed = TriggerActionFlow.isBypassed(name);
		}

		protected override void processObjectBypasses(String name) {
			this.hasBeenBypassed = TriggerBase.isBypassed(name);
		}
	}
}