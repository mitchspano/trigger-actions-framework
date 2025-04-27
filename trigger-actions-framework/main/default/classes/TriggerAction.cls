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
 * @description The `TriggerAction` class defines the interfaces that should be implemented by Trigger Actions.
 *
 * Trigger Actions are classes that define the logic that should be executed before or after a DML operation on a record.
 * The `TriggerAction` class defines the following interfaces:
 *
 * - `BeforeInsert`: This interface defines the logic that should be executed before a new record is inserted.
 * - `AfterInsert`: This interface defines the logic that should be executed after a new record is inserted.
 * - `BeforeUpdate`: This interface defines the logic that should be executed before a record is updated.
 * - `AfterUpdate`: This interface defines the logic that should be executed after a record is updated.
 * - `BeforeDelete`: This interface defines the logic that should be executed before a record is deleted.
 * - `AfterDelete`: This interface defines the logic that should be executed after a record is deleted.
 * - `AfterUndelete`: This interface defines the logic that should be executed after a record is undeleted.
 * - `DmlFinalizer`: This interface defines the logic that should be executed after all DML operations have completed.
 * ---
 * To implement a Trigger Action, you must create a class that implements one or more of the `TriggerAction` interfaces.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public class TriggerAction {
	/**
	 * @description This interface defines the logic that should be executed before
	 * a new record is inserted.
	 */
	public interface BeforeInsert {
		/**
		 * @description This method is called before a new record is inserted.
		 *
		 * @param triggerNew The list of new records that are being inserted.
		 */
		void beforeInsert(List<SObject> triggerNew);
	}

	/**
	 * @description This interface defines the logic that should be executed after a new record is inserted.
	 */
	public interface AfterInsert {
		/**
		 * @description This method is called after a new record is inserted.
		 *
		 * @param triggerNew The list of new records that were inserted.
		 */
		void afterInsert(List<SObject> triggerNew);
	}

	/**
	 * @description This interface defines the logic that should be executed before a record is updated.
	 */
	public interface BeforeUpdate {
		/**
		 * @description This method is called before a record is updated.
		 *
		 * @param triggerNew The list of new records that are being updated.
		 * @param triggerOld The list of old records that are being updated.
		 */
		void beforeUpdate(List<SObject> triggerNew, List<SObject> triggerOld);
	}

	/**
	 * @description This interface defines the logic that should be executed after a record is updated.
	 */
	public interface AfterUpdate {
		/**
		 * @description This method is called after a record is updated.
		 *
		 * @param triggerNew The list of new records that were updated.
		 * @param triggerOld The list of old records that were updated.
		 */
		void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld);
	}

	/**
	 * @description This interface defines the logic that should be executed before a record is deleted.
	 */
	public interface BeforeDelete {
		/**
		 * @description This method is called before a record is deleted.
		 *
		 * @param triggerOld The list of old records that are being deleted.
		 */
		void beforeDelete(List<SObject> triggerOld);
	}

	/**
	 * @description This interface defines the logic that should be executed after a record is deleted.
	 */
	public interface AfterDelete {
		/**
		 * @description This method is called after a record is deleted.
		 *
		 * @param triggerOld The list of old records that were deleted.
		 */
		void afterDelete(List<SObject> triggerOld);
	}

	/**
	 * @description This interface defines the logic that should be executed after a record is undeleted.
	 */
	public interface AfterUndelete {
		/**
		 * @description This method is called after a record is undeleted.
		 *
		 * @param triggerNew The list of new records that were undeleted.
		 */
		void afterUndelete(List<SObject> triggerNew);
	}

	/**
	 * @description This interface defines the logic that should be executed after all DML operations have completed.
	 */
	public interface DmlFinalizer {
		/**
		 * @description This method is called after all DML operations have completed.
		 *
		 * @param context The context of the finalizer.
		 */
		void execute(FinalizerHandler.Context context);
	}
}