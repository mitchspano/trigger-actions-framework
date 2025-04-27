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
 * @description This class provides an Invocable method that can be used to bypass a trigger action flow, Apex class, or Object trigger.
 *
 * The Invocable method is called `bypass` and it takes a list of `Request` objects as input.
 * Each `Request` object contains the following properties:
 *
 * - `name`: The API name of the trigger action flow, Apex class, or Object trigger to bypass.
 * - `bypassType`: The type of bypass to perform. Valid values are `Apex`, `Flow`, or `Object`.
 *
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class TriggerActionFlowBypass {
	/**
	 * @description This Invocable method bypasses a trigger action flow, Apex class, or Object trigger.
	 *
	 * @param requests A list of `Request` objects.
	 */
	@InvocableMethod(
		category='Trigger Action Flow'
		label='Bypass'
		description='Sets the static bypass to true for this object, apex action, or flow action.'
	)
	public static void bypass(List<Request> requests) {
		TriggerActionFlowBypassProcessor bypassProcessor = new FlowBypassProcessor();
		for (Request myRequest : requests) {
			bypassProcessor.execute(myRequest.bypassType, myRequest.name);
		}
	}

	/**
	 * @description This class represents a request to bypass a trigger action flow, Apex class, or Object trigger.
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

	private class FlowBypassProcessor extends TriggerActionFlowBypassProcessor {
		protected override void processApexBypasses(String name) {
			MetadataTriggerHandler.bypass(name);
		}

		protected override void processFlowBypasses(String name) {
			TriggerActionFlow.bypass(name);
		}

		protected override void processObjectBypasses(String name) {
			TriggerBase.bypass(name);
		}
	}
}