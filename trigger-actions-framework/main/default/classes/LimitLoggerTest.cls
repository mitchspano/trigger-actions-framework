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
 * @description Test class for the LimitLogger telemetry implementation.
 */
@IsTest
private class LimitLoggerTest {
	
	@IsTest
	static void testLogWithStartPhase() {
		TelemetryContext context = new TelemetryContext();
		context.actionClassName = 'TestTriggerAction';
		context.triggerOperation = 'BEFORE_INSERT';
		context.sObjectType = 'Account';
		context.recordCount = 5;
		context.phase = TelemetryPhase.START;
		
		LimitLogger logger = new LimitLogger();
		
		Test.startTest();
		logger.log(context);
		Test.stopTest();
		
		// Since LimitLogger uses System.debug, we can't directly assert the output
		// but we can verify the method executed without exceptions
		System.assert(true, 'LimitLogger.log should execute without throwing exceptions');
	}
	
	@IsTest
	static void testLogWithEndPhase() {
		TelemetryContext context = new TelemetryContext();
		context.actionClassName = 'TestTriggerAction';
		context.triggerOperation = 'AFTER_UPDATE';
		context.sObjectType = 'Contact';
		context.recordCount = 10;
		context.phase = TelemetryPhase.FINISH;
		
		LimitLogger logger = new LimitLogger();
		
		Test.startTest();
		logger.log(context);
		Test.stopTest();
		
		System.assert(true, 'LimitLogger.log should execute without throwing exceptions');
	}
	
	@IsTest
	static void testLogWithZeroRecords() {
		TelemetryContext context = new TelemetryContext();
		context.actionClassName = 'TestTriggerAction';
		context.triggerOperation = 'BEFORE_DELETE';
		context.sObjectType = 'Opportunity';
		context.recordCount = 0;
		context.phase = TelemetryPhase.START;
		
		LimitLogger logger = new LimitLogger();
		
		Test.startTest();
		logger.log(context);
		Test.stopTest();
		
		System.assert(true, 'LimitLogger.log should handle zero records without throwing exceptions');
	}
	
	@IsTest
	static void testImplementsInterface() {
		ITriggerActionTelemetryLogger logger = new LimitLogger();
		System.assert(logger != null, 'LimitLogger should implement ITriggerActionTelemetryLogger interface');
	}
}