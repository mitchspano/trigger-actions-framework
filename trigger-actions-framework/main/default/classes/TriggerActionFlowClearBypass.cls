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
 * @description The `TriggerActionFlowClearBypass` class is a utility class that handles the clearing
 * of bypasses for objects, Apex actions, or Flow actions.
 *
 * Bypasses are used to prevent the execution of specific Trigger Actions.
 * The `TriggerActionFlowClearBypass` class provides a way to clear the bypass for a specific object, Apex action, or Flow action.
 *
 * To use the `TriggerActionFlowClearBypass` class, you must first create a list of the objects, Apex actions, or Flow actions that you want to clear the bypasses for.
 * You can then call the `clearBypass` method of the `TriggerActionFlowClearBypass` class and pass the list of objects, Apex actions, or Flow actions as the input parameter.
 *
 * The `clearBypass` method will clear the bypass for the specified objects, Apex actions, or Flow actions.
 */
@SuppressWarnings('PMD.ApexDoc, PMD.CognitiveComplexity')
public inherited sharing class TriggerActionFlowClearBypass {
	/**
	 * @description This method clears the bypass for the specified objects, Apex actions, or Flow actions.
	 *
	 * @param requests A list of the objects, Apex actions, or Flow actions to clear the bypasses for.
	 */
	@InvocableMethod(
		category='Trigger Action Flow'
		label='Clear Bypass'
		description='Sets the static bypass to false for this object, apex action, or flow action.'
	)
	public static void clearBypass(List<Request> requests) {
		TriggerActionFlowBypassProcessor bypassProcesser = new FlowClearBypassProcessor();
		for (Request myRequest : requests) {
			bypassProcesser.execute(myRequest.bypassType, myRequest.name);
		}
	}

	/**
	 * @description The `Request` class is a class that represents a request to clear the bypass for a
	 * specific object, Apex action, or Flow action.
	 *
	 * To use the `Request` class, you must specify the following properties:
	 *
	 * - `name`: The API name of the object, Apex action, or Flow action to clear the bypass for.
	 * - `bypassType`: The type of bypass to clear. Valid values are `Apex`, `Flow`, or `Object`.
	 */
	public class Request {
		@InvocableVariable(
			label='Name'
			description='API Name of the trigger action flow, class, or sObject'
			required=true
		)
		public String name;
		@InvocableVariable(label='Bypass Type' description='Apex, Flow, or Object' required=true)
		public String bypassType;
	}

	/**
	 * @description The `FlowClearBypassProcessor` class is a subclass of the `TriggerActionFlowBypassProcessor`
	 * class that is used to clear bypasses for objects, Apex actions, or Flow actions.
	 *
	 * The `FlowClearBypassProcessor` class overrides the `processApexBypasses`, `processFlowBypasses`,
	 * and `processObjectBypasses` methods of the `TriggerActionFlowBypassProcessor` class to clear the bypasses
	 * for Apex actions, Flow actions, and objects, respectively.
	 */
	private class FlowClearBypassProcessor extends TriggerActionFlowBypassProcessor {
		protected override void processApexBypasses(String name) {
			MetadataTriggerHandler.clearBypass(name);
		}

		protected override void processFlowBypasses(String name) {
			TriggerActionFlow.clearBypass(name);
		}

		protected override void processObjectBypasses(String name) {
			TriggerBase.clearBypass(name);
		}
	}
}