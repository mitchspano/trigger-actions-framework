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

/**
 * @group Trigger Actions Framework
 * @description The `FinalizerHandler` class is a utility class that handles the execution of dynamic finalizers.
 *
 * Finalizers are classes that implement the `TriggerAction.DmlFinalizer` interface and are defined in Custom Metadata.
 * Finalizers can be used to perform custom actions after all DML operations have completed.
 *
 * The `FinalizerHandler` class provides the following functionality:
 *
 * - A way to bypass the execution of specific finalizers.
 * - A way to check if a specific finalizer is bypassed.
 * - A way to clear all bypasses.
 * - A way to handle dynamic finalizers.
 * ---
 * To use the `FinalizerHandler` class, you must first create a Custom Metadata type called `DML_Finalizer__mdt`.
 * The `DML_Finalizer__mdt` Custom Metadata type must have the following fields:
 *
 * - `Apex_Class_Name__c`: The name of the Apex class that implements the finalizer.
 * - `Order__c`: The order in which the finalizer should be executed.
 * - `Bypass_Execution__c`: A flag that indicates whether or not the finalizer should be bypassed.
 * - `Bypass_Permission__c`: A comma-separated list of custom permissions. The finalizer is bypassed when the running user has any one of them (optional).
 * - `Required_Permission__c`: A comma-separated list of custom permissions. The finalizer executes only when the running user has any one of them (optional).
 * ---
 * Once you have created the `DML_Finalizer__mdt` Custom Metadata type, you can create finalizers by creating records
 * in the `DML_Finalizer__mdt` object.
 *
 * To bypass the execution of a specific finalizer, you can call the `bypass` method of the `FinalizerHandler` class.
 * To check if a specific finalizer is bypassed, you can call the `isBypassed` method of the `FinalizerHandler` class.
 * To clear all bypasses, you can call the `clearAllBypasses` method of the `FinalizerHandler` class.
 *
 * To handle dynamic finalizers, you can call the `handleDynamicFinalizers` method of the `FinalizerHandler` class.
 * The `handleDynamicFinalizers` method will instantiate and execute all finalizers that are not bypassed.
 */
public with sharing virtual class FinalizerHandler {
	@TestVisible
	private static final String DML_IN_FINALIZER_ERROR = 'DML is not allowed within the finalizer context.';
	@TestVisible
	private static final String INVALID_TYPE_ERROR_FINALIZER = 'Please check the DML Finalizer Custom Metadata. The {0} class does not implement the TriggerAction.DmlFinalizer interface.';
	@TestVisible
	private static final String INVALID_CLASS_ERROR_FINALIZER = 'Please check the DML Finalizer Custom Metadata. The {0} class does not exist.';
	private static final String COMMA = ',';

	@TestVisible
	private static Set<String> bypassedFinalizers = new Set<String>();

	@TestVisible
	private static Map<String, Boolean> permissionMap = new Map<String, Boolean>();

	/**
	 * @description Bypass the execution of a specific finalizer.
	 * @param finalizer The name of the finalizer to bypass.
	 */
	public static void bypass(String finalizer) {
		FinalizerHandler.bypassedFinalizers.add(finalizer);
	}

	/**
	 * @description Clear the bypass for a specific finalizer.
	 * @param finalizer The name of the finalizer to clear the bypass for.
	 */
	public static void clearBypass(String finalizer) {
		FinalizerHandler.bypassedFinalizers.remove(finalizer);
	}

	/**
	 * @description Check if a specific finalizer is bypassed.
	 * @param finalizer The name of the finalizer to check.
	 * @return True if the finalizer is bypassed, false otherwise.
	 */
	public static Boolean isBypassed(String finalizer) {
		return FinalizerHandler.bypassedFinalizers.contains(finalizer);
	}

	/**
	 * @description Clear all bypasses.
	 */
	public static void clearAllBypasses() {
		FinalizerHandler.bypassedFinalizers.clear();
	}

	/**
	 * @description Handle dynamic finalizers. Instantiates and executes finalizers based on metadata.
	 */
	public virtual void handleDynamicFinalizers() {
		Context context = new Context();
		this.allFinalizers.sort(new FinalizerSorter());
		for (DML_Finalizer__mdt finalizerMetadata : this.allFinalizers) {
			if (finalizerMetadata.Bypass_Execution__c) {
				return;
			}
			populatePermissionMap(finalizerMetadata.Bypass_Permission__c);
			populatePermissionMap(finalizerMetadata.Required_Permission__c);
			if (
				!isBypassed(
					finalizerMetadata.Bypass_Permission__c,
					finalizerMetadata.Required_Permission__c
				)
			) {
				callReferencedFinalizer(finalizerMetadata, context);
			}
		}
	}

	/**
	 * @description Dynamically instantiates and executes a finalizer based on metadata.
	 * @param finalizerMetadata The metadata of the finalizer to execute.
	 * @param context The context to pass to the finalizer's `execute` method.
	 */
	private void callReferencedFinalizer(
		DML_Finalizer__mdt finalizerMetadata,
		Context context
	) {
		Object dynamicInstance;
		String className = finalizerMetadata.Apex_Class_Name__c;
		if (FinalizerHandler.isBypassed(className)) {
			return;
		}
		TriggerAction.DmlFinalizer finalizer;
		try {
			dynamicInstance = Type.forName(className).newInstance();
			finalizer = (TriggerAction.DmlFinalizer) dynamicInstance;
		} catch (System.NullPointerException e) {
			handleFinalizerException(INVALID_CLASS_ERROR_FINALIZER, className);
		} catch (System.TypeException e) {
			handleFinalizerException(INVALID_TYPE_ERROR_FINALIZER, className);
		}
		Integer dmlOperationsBefore = Limits.getDmlStatements();
		finalizer.execute(context);
		if (limits.getDmlStatements() > dmlOperationsBefore) {
			throw new FinalizerException(DML_IN_FINALIZER_ERROR);
		}
	}

	private void handleFinalizerException(String errorFormat, String className) {
		throw new FinalizerException(
			String.format(errorFormat, new List<String>{ className })
		);
	}

	/**
	 * @description Check if the finalizer is bypassed.
	 *
	 * The finalizer is bypassed when the running user has any one of the bypass permissions,
	 * or when required permissions are defined and the running user has none of them.
	 *
	 * @param bypassPermissions A comma-separated list of bypass permissions for the finalizer.
	 * @param requiredPermissions A comma-separated list of required permissions for the finalizer.
	 * @return True if bypassed, false otherwise.
	 */
	private Boolean isBypassed(
		String bypassPermissions,
		String requiredPermissions
	) {
		return hasAnyPermission(bypassPermissions) ||
			(String.isNotBlank(requiredPermissions) &&
			!hasAnyPermission(requiredPermissions));
	}

	/**
	 * @description Populate the permission map with each permission in a comma-separated list.
	 * @param permissionNames A comma-separated list of custom permission API names.
	 */
	private void populatePermissionMap(String permissionNames) {
		for (String permissionName : splitPermissions(permissionNames)) {
			if (!permissionMap.containsKey(permissionName)) {
				permissionMap.put(
					permissionName,
					FeatureManagement.checkPermission(permissionName)
				);
			}
		}
	}

	/**
	 * @description Split a comma-separated list of permission names into non-blank names. All whitespace is removed first, so names may be separated by a comma or a comma and a space.
	 * @param permissionNames A comma-separated list of custom permission API names.
	 * @return The list of individual permission names. Empty when the input is blank.
	 */
	private static List<String> splitPermissions(String permissionNames) {
		List<String> result = new List<String>();
		if (String.isBlank(permissionNames)) {
			return result;
		}
		for (
			String permissionName : permissionNames.deleteWhitespace().split(COMMA)
		) {
			if (String.isNotBlank(permissionName)) {
				result.add(permissionName);
			}
		}
		return result;
	}

	/**
	 * @description Check if the running user has any one permission in a comma-separated list.
	 * @param permissionNames A comma-separated list of custom permission API names.
	 * @return True if the user has at least one of the permissions, false otherwise.
	 */
	private static Boolean hasAnyPermission(String permissionNames) {
		for (String permissionName : splitPermissions(permissionNames)) {
			if (permissionMap.get(permissionName) == true) {
				return true;
			}
		}
		return false;
	}

	@TestVisible
	private List<DML_Finalizer__mdt> allFinalizers {
		get {
			this.allFinalizers = this.allFinalizers ??
				DML_Finalizer__mdt.getAll().values();
			return this.allFinalizers;
		}
		private set;
	}

	private class FinalizerSorter implements Comparator<DML_Finalizer__mdt> {
		/**
		 * @description Compares this `FinalizerSorter` object to another object.
		 *
		 * @param first The DML_Finalizer__mdt in the first position.
		 * @param second The DML_Finalizer__mdt in the next position.
		 * @return A negative integer, zero, or a positive integer to move items forward or backwards in the list of DML_Finalizer__mdt.
		 */
		public Integer compare(
			DML_Finalizer__mdt first,
			DML_Finalizer__mdt second
		) {
			Decimal difference = (first.Order__c - second.Order__c);
			return difference < 0 ? -1 : difference == 0 ? 0 : 1;
		}
	}

	/**
	 * @description Context to be passed to the implementation's `.execute` methodis object's definition is empty. We are establishing the interface
	 * to include the context to help future-proof the interface's specifications.
	 */
	public class Context {
	}

	/**
	 * @description Finalizer exception.
	 */
	private class FinalizerException extends Exception {
	}
}
