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
 * @description This class contains constants used by the TriggerAction framework.
 */
public class TriggerActionConstants {
	public static final String APEX_STRING = 'Apex';
	public static final String FLOW_STRING = 'Flow';
	public static final String OBJECT_STRING = 'Object';
	public static final String RECORD_PRIOR_VARIABLE = 'recordPrior';
	public static final String RECORD_VARIABLE = 'record';
	public static final String INVALID_FLOW_NAME = 'You must provide the name of a flow to execute';
	public static final String INVALID_TYPE = 'The bypassType must equal Object, Apex, or Flow';
	public static final Set<String> REQUEST_TYPES = new Set<String>{
		TriggerActionConstants.APEX_STRING,
		TriggerActionConstants.FLOW_STRING,
		TriggerActionConstants.OBJECT_STRING
	};
}