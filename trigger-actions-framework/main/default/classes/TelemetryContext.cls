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
 * @description Context object providing information about the current trigger execution state.
 * This allows telemetry loggers to access relevant information for logging purposes.
 */
public class TelemetryContext {
	/**
	 * @description The name of the trigger action class being executed
	 */
	public String actionClassName { get; set; }

	/**
	 * @description The trigger operation context (e.g., BEFORE_INSERT, AFTER_UPDATE)
	 */
	public String triggerOperation { get; set; }

	/**
	 * @description The sObject type being processed
	 */
	public String sObjectType { get; set; }

	/**
	 * @description The phase of execution (START or FINISH)
	 */
	public TelemetryPhase phase { get; set; }

	/**
	 * @description Number of records being processed in this execution
	 */
	public Integer recordCount { get; set; }

	/**
	 * @description Default constructor for creating a telemetry context
	 */
	public TelemetryContext() {
	}

	/**
	 * @description Constructor for creating a telemetry context
	 * @param actionClassName The name of the action class
	 * @param triggerOperation The trigger operation
	 * @param sObjectType The sObject type
	 * @param phase The execution phase
	 * @param recordCount Number of records being processed
	 */
	public TelemetryContext(
		String actionClassName,
		String triggerOperation,
		String sObjectType,
		TelemetryPhase phase,
		Integer recordCount
	) {
		this.actionClassName = actionClassName;
		this.triggerOperation = triggerOperation;
		this.sObjectType = sObjectType;
		this.phase = phase;
		this.recordCount = recordCount;
	}
}