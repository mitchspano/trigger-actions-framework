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

/**
 * @description The `FormulaFilter` class provides functionality to filter lists of SObjects based on a configurable
 * entry criteria formula defined within a `Trigger_Action__mdt` configuration row.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.FieldsSortedAlphabetically')
global class FormulaFilter {
	private static final String ERROR_PREFIX = 'Please check the `SObject_Trigger_Setting__mdt` metadata for the the {0} sObject.';
	@TestVisible
	private static final String MISSING_CLASS_NAME =
		ERROR_PREFIX +
		' The record is missing the `TriggerRecord_Class_Name__c` field.';
	@TestVisible
	private static final String INVALID_CLASS =
		ERROR_PREFIX +
		' There is no such class named {1} which is currently the value specified in the the `TriggerRecord_Class_Name__c` field.';
	@TestVisible
	private static final String INVALID_SUBTYPE =
		ERROR_PREFIX +
		' The {1} class is specified in the the `TriggerRecord_Class_Name__c` field must be global and it must have properties called `record` and `recordPrior` and it must extend the `TriggerRecord` class.';
	@TestVisible
	private static final String INVALID_FILTER =
		'Something is wrong with the filter on the `Trigger_Action__mdt` record with DeveloperName = {0} on the  {1} sObject.' +
		' It could be the case that the {2} class which is specified in the `TriggerRecord_Class_Name__c` referenced on the `SObject_Trigger_Setting__mdt` is not global,' +
		' or it could be that the formula is syntactically invalid : `{3}`';

	private final Trigger_Action__mdt triggerActionConfiguration;
	private final TriggerOperation context;
	private final String sObjectName;

	/**
	 * @description Constructs a new `FormulaFilter` instance with the specified trigger action configuration.
	 * @param triggerActionConfiguration The trigger action configuration containing the entry criteria formula.
	 * @param context The trigger operation context.
	 * @param sObjectName The name of the sObject.
	 */
	public FormulaFilter(
		Trigger_Action__mdt triggerActionConfiguration,
		TriggerOperation context,
		String sObjectName
	) {
		this.triggerActionConfiguration = triggerActionConfiguration;
		this.context = context;
		this.sObjectName = sObjectName;
	}

	/**
	 * @description Filters the given lists of new and old SObjects based on the entry criteria formula.
	 *
	 * This method evaluates the entry criteria formula for each record in the `triggerNew` and `triggerOld`.
	 * If the formula evaluates to true for a record, it is included in the filtered lists.
	 *
	 * @param triggerNew The list of new SObjects to filter.
	 * @param triggerOld The list of old SObjects to filter.
	 * @return A `FormulaFilter.Result` object containing the filtered lists of new and old SObjects.
	 */
	public FormulaFilter.Result filterByEntryCriteria(
		List<SObject> triggerNew,
		List<SObject> triggerOld
	) {
		FormulaFilter.Result result = new FormulaFilter.Result();
		String entryCriteriaFormula = this.triggerActionConfiguration
			?.Entry_Criteria__c;

		if (String.isBlank(entryCriteriaFormula)) {
			result.triggerNew = triggerNew;
			result.triggerOld = triggerOld;
			return result;
		}
		String nameOfType = getNameOfType(
			this.triggerActionConfiguration,
			this.context
		);
		System.Type triggerRecordSubType = getType(nameOfType);
		FormulaEval.FormulaInstance fx = getFormulaInstance(
			triggerRecordSubType,
			entryCriteriaFormula,
			nameOfType
		);

		Integer size = triggerNew != null ? triggerNew.size() : triggerOld.size();
		for (Integer i = 0; i < size; i++) {
			SObject record = triggerNew?.get(i);
			SObject recordPrior = triggerOld?.get(i);
			TriggerRecord toProcess = getTriggerRecord(
				triggerRecordSubType,
				nameOfType
			);
			toProcess.newSobject = record;
			toProcess.oldSobject = recordPrior;
			if ((Boolean) fx.evaluate(toProcess) == true) {
				result.triggerNew.add(record);
				result.triggerOld.add(recordPrior);
			}
		}
		return result;
	}

	private System.Type getType(String className) {
		if (String.isBlank(className)) {
			throw new IllegalArgumentException(
				String.format(MISSING_CLASS_NAME, new List<String>{ this.sObjectName })
			);
		}
		System.Type response = System.Type.forName(className);
		if (response == null) {
			throw new IllegalArgumentException(
				String.format(
					INVALID_CLASS,
					new List<String>{ this.sObjectName, className }
				)
			);
		}
		return response;
	}

	private TriggerRecord getTriggerRecord(
		System.Type triggerRecordSubType,
		String nameOfType
	) {
		TriggerRecord dynamicInstance;
		try {
			dynamicInstance = (TriggerRecord) triggerRecordSubType.newInstance();
		} catch (System.TypeException e) {
			throw new IllegalArgumentException(
				String.format(
					INVALID_SUBTYPE,
					new List<String>{ this.sObjectName, nameOfType }
				)
			);
		}
		return dynamicInstance;
	}

	private FormulaEval.FormulaInstance getFormulaInstance(
		System.Type typeToEvaluate,
		String entryCriteriaFormula,
		String nameOfType
	) {
		FormulaEval.FormulaInstance fx;
		try {
			fx = Formula.builder()
				.withReturnType(FormulaEval.FormulaReturnType.Boolean)
				.withGlobalVariables(FormulaEval.FormulaGlobal.values())
				.withType(typeToEvaluate)
				.withFormula(entryCriteriaFormula)
				.build();
		} catch (System.FormulaValidationException e) {
			throw new IllegalArgumentException(
				String.format(
					INVALID_FILTER,
					new List<String>{
						this.triggerActionConfiguration.DeveloperName,
						this.sObjectName,
						nameOfType,
						entryCriteriaFormula
					}
				)
			);
		}
		return fx;
	}

	private String getNameOfType(
		Trigger_Action__mdt triggerActionConfiguration,
		TriggerOperation context
	) {
		return ((sObject_Trigger_Setting__mdt) this.triggerActionConfiguration.getSObject(
				this.context.name() + '__r'
			))
			?.TriggerRecord_Class_Name__c;
	}

	/**
	 * @description Inner class representing the result of the `filterByEntryCriteria` method.
	 */
	public class Result {
		/**
		 * @description The filtered list of new SObjects.
		 */
		public List<SObject> triggerNew;
		/**
		 * @description The filtered list of old SObjects.
		 */
		public List<SObject> triggerOld;

		private Result() {
			this.triggerNew = new List<SObject>();
			this.triggerOld = new List<SObject>();
		}
	}
}
