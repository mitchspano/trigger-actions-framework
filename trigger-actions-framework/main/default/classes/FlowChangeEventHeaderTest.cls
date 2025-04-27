/*
   Copyright 2023 Google LLC

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

@IsTest(isParallel=true)
@SuppressWarnings('PMD.ApexDoc')
private with sharing class FlowChangeEventHeaderTest {
	private static FlowChangeEventHeader header = new FlowChangeEventHeader(
		new EventBus.ChangeEventHeader()
	);

	@IsTest
	private static void shouldBeAbleToConstruct() {
		System.Assert.isNotNull(header, 'Unable to construct a FlowChangeEventHeader');
	}

	@IsTest
	private static void shouldBeAbleToGenerateHashCode() {
		System.Assert.isNotNull(header.hashCode(), 'Hash code was not generated');
	}

	@IsTest
	private static void shouldBeAbleToCompare() {
		FlowChangeEventHeader other = new FlowChangeEventHeader(new EventBus.ChangeEventHeader());
		other.changeType = 'CREATE';

		System.Assert.areEqual(
			new FlowChangeEventHeader(new EventBus.ChangeEventHeader()),
			header,
			'Unable to detect identical FlowChangeEventHeader objects'
		);
		System.Assert.areNotEqual(
			header,
			other,
			'Unable to detect different FlowChangeEventHeader objects'
		);
		System.Assert.areNotEqual(
			header,
			null,
			'Unable to detect difference between FlowChangeEventHeader and null'
		);
	}
}