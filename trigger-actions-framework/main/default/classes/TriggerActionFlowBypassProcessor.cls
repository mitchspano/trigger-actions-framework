/*
   Copyright 2022 Google LLC

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
 * @description  This abstract class provides a framework for processing bypass requests for
 * trigger action flows, Apex classes, and Object triggers.
 *
 * To use this class, you must first create a subclass that implements the
 * `processApexBypasses`, `processFlowBypasses`, and `processObjectBypasses` methods.
 * You can then use the `execute` method to process bypass requests for the specified
 *  type of bypass.
 */
public inherited sharing abstract class TriggerActionFlowBypassProcessor {
	/**
	 * @description This method processes a bypass request for the specified type of bypass.
	 *
	 * @param requestType The type of bypass to process. Valid values are `Apex`, `Flow`, or `Object`.
	 * @param requestName The name of the trigger action flow, Apex class, or Object trigger to bypass.
	 */
	public void execute(String requestType, String requestName) {
		if (!TriggerActionConstants.REQUEST_TYPES.contains(requestType)) {
			throw new IllegalArgumentException(TriggerActionConstants.INVALID_TYPE);
		} else if (requestType == TriggerActionConstants.FLOW_STRING) {
			this.processFlowBypasses(requestName);
		} else if (requestType == TriggerActionConstants.APEX_STRING) {
			this.processApexBypasses(requestName);
		} else if (requestType == TriggerActionConstants.OBJECT_STRING) {
			this.processObjectBypasses(requestName);
		}
	}

	protected abstract void processApexBypasses(String requestType);
	protected abstract void processFlowBypasses(String requestType);
	protected abstract void processObjectBypasses(String requestType);
}