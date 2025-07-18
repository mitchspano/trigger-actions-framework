/*
   Copyright 2024 Google LLC

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
@SuppressWarnings(
	'PMD.ApexUnitTestClassShouldHaveRunAs, PMD.AvoidGlobalModifier'
)
@IsTest(IsParallel=true)
global class FormulaFilterTest {
	private static final String ACCOUNT_SOBJECT_NAME = 'Account';
	private static final String EXCEPTION_SHOULD_BE_THROWN = 'An exception should be thrown';
	private static List<Account> triggerNew = new List<Account>{
		new Account(Name = 'Test Account 1'),
		new Account(Name = 'Test Account 2')
	};
	private static List<Account> triggerOld = new List<Account>{
		new Account(Name = 'Test Account 1'),
		new Account(Name = 'Test Account 2')
	};
	private static sObject_Trigger_Setting__mdt sobjectSetting = new sObject_Trigger_Setting__mdt(
		TriggerRecord_Class_Name__c = 'FormulaFilterTest.AccountTriggerRecord'
	);
	private static Trigger_Action__mdt configuration = new Trigger_Action__mdt(
		DeveloperName = 'TA_Test',
		Before_Update__r = sobjectSetting
	);
	private static IllegalArgumentException caught;

	@IsTest
	private static void noFormulaShouldProcessAllRecords() {
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		FormulaFilter.Result result = filter.filterByEntryCriteria(
			triggerNew,
			triggerOld
		);

		System.Assert.areEqual(
			2,
			result.triggerNew.size(),
			'The size of triggerNew should be 2'
		);
		System.Assert.areEqual(
			2,
			result.triggerOld.size(),
			'The size of triggerOld should be 2'
		);
	}

	@IsTest
	private static void emptyStringFormulaShouldProcessAllRecords() {
		configuration.Entry_Criteria__c = '';

		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		FormulaFilter.Result result = filter.filterByEntryCriteria(
			triggerNew,
			triggerOld
		);

		System.Assert.areEqual(
			2,
			result.triggerNew.size(),
			'The size of triggerNew should be 2'
		);
		System.Assert.areEqual(
			2,
			result.triggerOld.size(),
			'The size of triggerNew should be 2'
		);
	}

	@IsTest
	private static void validFormulaShouldFilterContentsOftriggerNew() {
		configuration.Entry_Criteria__c = 'record.Name = "Test Account 1"';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		FormulaFilter.Result result = filter.filterByEntryCriteria(
			triggerNew,
			triggerOld
		);

		System.Assert.areEqual(
			1,
			result.triggerNew.size(),
			'There should be 1 record in triggerNew'
		);
		System.Assert.areEqual(
			'Test Account 1',
			((Account) result.triggerNew[0]).Name,
			'The first record triggerNew should have a name of Test Account 1'
		);
		System.Assert.areEqual(
			1,
			result.triggerOld.size(),
			'There should be 1 record in triggerNew'
		);
		System.Assert.areEqual(
			'Test Account 1',
			((Account) result.triggerOld[0]).Name,
			'The first record triggerNew should have a name of Test Account 1'
		);
	}

	@IsTest
	private static void validFormulaWithNoMatchingRecordsShouldProcessNoRecords() {
		configuration.Entry_Criteria__c = 'record.Name = "FooBar"';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		FormulaFilter.Result result = filter.filterByEntryCriteria(
			triggerNew,
			triggerOld
		);

		System.Assert.isNotNull(result, 'result should not be null');
		System.Assert.isTrue(
			result.triggerNew.isEmpty(),
			'triggerNew should be empty'
		);
		System.Assert.isTrue(
			result.triggerOld.isEmpty(),
			'triggerOld should be empty'
		);
	}

	@IsTest
	private static void emptyClassShouldThrowException() {
		sobjectSetting.TriggerRecord_Class_Name__c = '';
		configuration.Entry_Criteria__c = 'record.Name = "FooBar"';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		try {
			filter.filterByEntryCriteria(triggerNew, triggerOld);
		} catch (IllegalArgumentException e) {
			caught = e;
		}

		System.Assert.isNotNull(caught, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			String.format(
				FormulaFilter.MISSING_CLASS_NAME,
				new List<String>{ ACCOUNT_SOBJECT_NAME }
			),
			caught.getMessage(),
			'The exception message should match the expected error'
		);
	}

	@IsTest
	private static void nullClassShouldThrowException() {
		sobjectSetting.TriggerRecord_Class_Name__c = null;
		configuration.Entry_Criteria__c = 'record.Name = "FooBar"';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		try {
			filter.filterByEntryCriteria(triggerNew, triggerOld);
		} catch (IllegalArgumentException e) {
			caught = e;
		}

		System.Assert.isNotNull(caught, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			String.format(
				FormulaFilter.MISSING_CLASS_NAME,
				new List<String>{ ACCOUNT_SOBJECT_NAME }
			),
			caught.getMessage(),
			'The exception message should match the expected error'
		);
	}

	@IsTest
	private static void nonGlobalShouldThrowException() {
		sobjectSetting.TriggerRecord_Class_Name__c = 'FormulaFilterTest.AccountTriggerRecordPublic';
		configuration.Entry_Criteria__c = 'record.Name = "FooBar"';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		try {
			filter.filterByEntryCriteria(triggerNew, triggerOld);
		} catch (IllegalArgumentException e) {
			caught = e;
		}

		System.Assert.isNotNull(caught, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			String.format(
				FormulaFilter.INVALID_FILTER,
				new List<String>{
					configuration.DeveloperName,
					ACCOUNT_SOBJECT_NAME,
					sobjectSetting.TriggerRecord_Class_Name__c,
					configuration.Entry_Criteria__c
				}
			),
			caught.getMessage(),
			'The exception message should match the expected error'
		);
	}

	@IsTest
	private static void nonTriggerRecordClassShouldThrowException() {
		sobjectSetting.TriggerRecord_Class_Name__c = 'FormulaFilterTest.AccountNonTriggerRecord';
		configuration.Entry_Criteria__c = 'record.Name = "FooBar"';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		try {
			filter.filterByEntryCriteria(triggerNew, triggerOld);
		} catch (IllegalArgumentException e) {
			caught = e;
		}

		System.Assert.isNotNull(caught, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			String.format(
				FormulaFilter.INVALID_SUBTYPE,
				new List<String>{
					ACCOUNT_SOBJECT_NAME,
					sobjectSetting.TriggerRecord_Class_Name__c
				}
			),
			caught.getMessage(),
			'The exception message should match the expected error'
		);
	}

	@IsTest
	private static void nonExistentClassShouldThrowException() {
		sobjectSetting.TriggerRecord_Class_Name__c = 'TotallyBogusClassNameWhichDoesNotExist';
		configuration.Entry_Criteria__c = 'record.Name = "FooBar"';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);
		try {
			filter.filterByEntryCriteria(triggerNew, triggerOld);
		} catch (IllegalArgumentException e) {
			caught = e;
		}

		System.Assert.isNotNull(caught, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			String.format(
				FormulaFilter.INVALID_CLASS,
				new List<String>{
					ACCOUNT_SOBJECT_NAME,
					sobjectSetting.TriggerRecord_Class_Name__c
				}
			),
			caught.getMessage(),
			'The exception message should match the expected error'
		);
	}

	@IsTest
	private static void invalidFormulaSyntaxShouldThrowException() {
		String fx = 'This will not compile!!!';
		configuration.Entry_Criteria__c = fx;
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		try {
			filter.filterByEntryCriteria(triggerNew, triggerOld);
		} catch (IllegalArgumentException e) {
			caught = e;
		}

		System.Assert.isNotNull(caught, EXCEPTION_SHOULD_BE_THROWN);
		System.Assert.areEqual(
			String.format(
				FormulaFilter.INVALID_FILTER,
				new List<String>{
					configuration.DeveloperName,
					ACCOUNT_SOBJECT_NAME,
					sobjectSetting.TriggerRecord_Class_Name__c,
					fx
				}
			),
			caught.getMessage(),
			'The exception message should match the expected error'
		);
	}

	@IsTest
	private static void formulaEvaluatingToNullShouldBeTreatedAsFalse() {
		triggerNew[1].Description = 'example 1';
		configuration.Entry_Criteria__c = 'CONTAINS(record.Description, "example")';
		FormulaFilter filter = new FormulaFilter(
			configuration,
			TriggerOperation.BEFORE_UPDATE,
			ACCOUNT_SOBJECT_NAME
		);

		FormulaFilter.Result result = filter.filterByEntryCriteria(
			triggerNew,
			triggerOld
		);

		System.Assert.areEqual(
			1,
			result.triggerNew.size(),
			'Only 1 record should be processed when CONTAINS evaluates to null for the first record'
		);
		System.Assert.areEqual(
			1,
			result.triggerOld.size(),
			'Only 1 record should be processed when CONTAINS evaluates to null for the first record'
		);
	}

	@SuppressWarnings('PMD.ApexDoc')
	global class AccountTriggerRecord extends TriggerRecord {
		global Account record {
			get {
				return (Account) this.newSObject;
			}
		}
		global Account recordPrior {
			get {
				return (Account) this.oldSObject;
			}
		}
	}

	@SuppressWarnings('PMD.ApexDoc')
	global class AccountNonTriggerRecord {
		global Account record {
			get {
				return new Account();
			}
		}
		global Account recordPrior {
			get {
				return new Account();
			}
		}
	}

	@SuppressWarnings('PMD.ApexDoc')
	public class AccountTriggerRecordPublic extends TriggerRecord {
		public Account record {
			get {
				return (Account) this.newSObject;
			}
		}
		public Account recordPrior {
			get {
				return (Account) this.oldSObject;
			}
		}
	}
}
