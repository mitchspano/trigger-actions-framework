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
 * @description Basic implementation of ITriggerActionTelemetryLogger that logs Salesforce limits
 * to the debug log. This implementation tracks SOQL queries, DML statements, CPU time, and heap size.
 * 
 * This logger is designed for debugging and development purposes and should not be enabled
 * in production environments as it may impact performance.
 * 
 * Example usage:
 * Configure this class in the Trigger_Action__mdt.Telemetry_Logger_Class__c field to enable
 * telemetry logging for specific trigger actions.
 */
public class LimitLogger implements ITriggerActionTelemetryLogger {
	
	/**
	 * @description Logs current Salesforce limits to the debug log with context information.
	 * @param context The telemetry context containing execution information
	 */
	public void log(TelemetryContext context) {
		String phaseLabel = context.phase == TelemetryPhase.START ? 'START' : 'FINISH';
		
		String message = String.format(
			'[{0}] {1} on {2}.{3} ({4} records) - Queries: {5}/{6}, DML: {7}/{8}, CPU: {9}/{10}ms, Heap: {11}/{12}bytes',
			new List<String>{
				phaseLabel,
				context.triggerOperation,
				context.sObjectType,
				context.actionClassName,
				String.valueOf(context.recordCount),
				String.valueOf(Limits.getQueries()),
				String.valueOf(Limits.getLimitQueries()),
				String.valueOf(Limits.getDmlStatements()),
				String.valueOf(Limits.getLimitDmlStatements()),
				String.valueOf(Limits.getCpuTime()),
				String.valueOf(Limits.getLimitCpuTime()),
				String.valueOf(Limits.getHeapSize()),
				String.valueOf(Limits.getLimitHeapSize())
			}
		);

		System.debug(LoggingLevel.DEBUG, message);
	}
}