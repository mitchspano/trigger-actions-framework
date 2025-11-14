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
 * @description Interface for telemetry logging implementations within the Trigger Actions Framework.
 * 
 * This interface allows pluggable telemetry logging functionality that can be used to track
 * limits, performance metrics, and other diagnostic information during trigger execution.
 * 
 * Implementations can range from simple System.debug logging to integration with external
 * logging frameworks like Nebula Logger.
 * 
 * Example implementation:
 * ```
 * public class LimitLogger implements ITriggerActionTelemetryLogger {
 *     public void log(TelemetryContext context) {
 *         System.debug('Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
 *     }
 * }
 * ```
 */
public interface ITriggerActionTelemetryLogger {
	/**
	 * @description Log telemetry information using the provided context.
	 * @param context The telemetry context containing information about the current execution state
	 */
	void log(TelemetryContext context);
}