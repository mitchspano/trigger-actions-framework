# Reference Guide

## Custom Objects

### [DML_Finalizer\_\_mdt](custom-objects/DML_Finalizer__mdt.md)

### [Trigger_Action\_\_mdt](custom-objects/Trigger_Action__mdt.md)

### [SObject_Trigger_Setting\_\_mdt](custom-objects/SObject_Trigger_Setting__mdt.md)

## Trigger Actions Framework

### [FinalizerHandler](trigger-actions-framework/FinalizerHandler.md)

The `FinalizerHandler` class is a utility class that handles the execution of dynamic finalizers.

Finalizers are classes that implement the `TriggerAction.DmlFinalizer` interface and are defined in Custom Metadata.
Finalizers can be used to perform custom actions after all DML operations have completed.

The `FinalizerHandler` class provides the following functionality:

- A way to bypass the execution of specific finalizers.
- A way to check if a specific finalizer is bypassed.
- A way to clear all bypasses.
- A way to handle dynamic finalizers.

---

To use the `FinalizerHandler` class, you must first create a Custom Metadata type called `DML_Finalizer__mdt` .
The `DML_Finalizer__mdt` Custom Metadata type must have the following fields:

- `Apex_Class_Name__c` : The name of the Apex class that implements the finalizer.
- `Order__c` : The order in which the finalizer should be executed.
- `Bypass_Execution__c` : A flag that indicates whether or not the finalizer should be bypassed.
- `Bypass_Permission__c` : The permission required to bypass the finalizer.
- `Required_Permission__c` : The permission required to execute the finalizer.

---

Once you have created the `DML_Finalizer__mdt` Custom Metadata type, you can create finalizers by creating records
in the `DML_Finalizer__mdt` object.

To bypass the execution of a specific finalizer, you can call the `bypass` method of the `FinalizerHandler` class.
To check if a specific finalizer is bypassed, you can call the `isBypassed` method of the `FinalizerHandler` class.
To clear all bypasses, you can call the `clearAllBypasses` method of the `FinalizerHandler` class.

To handle dynamic finalizers, you can call the `handleDynamicFinalizers` method of the `FinalizerHandler` class.
The `handleDynamicFinalizers` method will instantiate and execute all finalizers that are not bypassed.

### [FlowChangeEventHeader](trigger-actions-framework/FlowChangeEventHeader.md)

A flow-accessible version of the ChangeEventHeader class for use in
a flow handler of a change data capture event.

### [MetadataTriggerHandler](trigger-actions-framework/MetadataTriggerHandler.md)

The `MetadataTriggerHandler` class is a trigger handler that executes Trigger
Actions defined in Custom Metadata.

This class implements the `TriggerAction` interface for all supported Trigger Operations:

- `BeforeInsert`
- `AfterInsert`
- `BeforeUpdate`
- `AfterUpdate`
- `BeforeDelete`
- `AfterDelete`
- `AfterUndelete`

---

The `MetadataTriggerHandler` class reads from the `Trigger_Action__mdt` Custom Metadata type to
define Trigger Actions.

Each Trigger Action must specify the following information:

- `Apex_Class_Name__c` : The name of the Apex class that implements the Trigger Action.
- `Order__c` : The order in which the Trigger Action should be executed.
- `Flow_Name__c` : The name of the Flow to execute (optional).
- `Bypass_Permission__c` : The permission required to bypass the Trigger Action (optional).
- `Required_Permission__c` : The permission required to execute the Trigger Action (optional).
- `Allow_Flow_Recursion__c` : Whether or not to allow the Flow to recurse (optional).

---

The `MetadataTriggerHandler` class also uses the `SObject_Trigger_Setting__mdt` Custom Metadata type to define
Trigger Action settings for specific SObjects.

Each SObject Trigger Setting must specify the following information:

- `Bypass_Permission__c` : The permission required to bypass the Trigger Action for the specified SObject (optional).
- `Required_Permission__c` : The permission required to execute the Trigger Action for the specified SObject (optional).

---

To use the `MetadataTriggerHandler` class, you must create a Trigger on the desired SObject and specify the
`MetadataTriggerHandler` class as the handler.
You can then define Trigger Actions and SObject Trigger Settings in Custom Metadata to control the behavior of the Trigger.

**Example:**

```apex
trigger AccountTrigger on Account(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	new MetadataTriggerHandler.run();
}
```

This example will execute all Trigger Actions defined in Custom Metadata for the `Account` SObject.

### [TriggerAction](trigger-actions-framework/TriggerAction.md)

The `TriggerAction` class defines the interfaces that should be implemented by Trigger Actions.

Trigger Actions are classes that define the logic that should be executed before or after a DML operation on a record.
The `TriggerAction` class defines the following interfaces:

- `BeforeInsert` : This interface defines the logic that should be executed before a new record is inserted.
- `AfterInsert` : This interface defines the logic that should be executed after a new record is inserted.
- `BeforeUpdate` : This interface defines the logic that should be executed before a record is updated.
- `AfterUpdate` : This interface defines the logic that should be executed after a record is updated.
- `BeforeDelete` : This interface defines the logic that should be executed before a record is deleted.
- `AfterDelete` : This interface defines the logic that should be executed after a record is deleted.
- `AfterUndelete` : This interface defines the logic that should be executed after a record is undeleted.
- `DmlFinalizer` : This interface defines the logic that should be executed after all DML operations have completed.

---

To implement a Trigger Action, you must create a class that implements one or more of the `TriggerAction` interfaces.

### [TriggerActionConstants](trigger-actions-framework/TriggerActionConstants.md)

This class contains constants used by the TriggerAction framework.

### [TriggerActionFlow](trigger-actions-framework/TriggerActionFlow.md)

This class implements the TriggerAction interface and provides a framework for
executing Flows before or after the insert, update, delete, or undelete of records.

### [TriggerActionFlowAddError](trigger-actions-framework/TriggerActionFlowAddError.md)

This class provides an Invocable method that can be used to add an error to an SObject.

The Invocable method is called `addError` and it takes a list of `Request` objects as input.
Each `Request` object contains the following properties:

- `record` : The SObject to add the error to.
- `fieldName` : The API name of the field to add the error to.
- `errorMessage` : The error message to add.

---

If the `fieldName` property is not specified, the error message will be added to the SObject without a field name.

### [TriggerActionFlowBypass](trigger-actions-framework/TriggerActionFlowBypass.md)

This class provides an Invocable method that can be used to bypass a trigger action flow, Apex class, or Object trigger.

The Invocable method is called `bypass` and it takes a list of `Request` objects as input.
Each `Request` object contains the following properties:

- `name` : The API name of the trigger action flow, Apex class, or Object trigger to bypass.
- `bypassType` : The type of bypass to perform. Valid values are `Apex` , `Flow` , or `Object` .

### [TriggerActionFlowBypassProcessor](trigger-actions-framework/TriggerActionFlowBypassProcessor.md)

This abstract class provides a framework for processing bypass requests for
trigger action flows, Apex classes, and Object triggers.

To use this class, you must first create a subclass that implements the
`processApexBypasses` , `processFlowBypasses` , and `procesSObjectBypasses` methods.
You can then use the `execute` method to process bypass requests for the specified
type of bypass.

### [TriggerActionFlowChangeEvent](trigger-actions-framework/TriggerActionFlowChangeEvent.md)

The `TriggerActionFlowChangeEvent` class is a subclass of the `TriggerActionFlow`
class that is used to handle change events.

Change events are events that are generated when a record is created, updated, or deleted.
The `TriggerActionFlowChangeEvent` class provides the ability to access the change event header in the Flow interview.

To use the `TriggerActionFlowChangeEvent` class, you must first create a Flow that accepts a variable of
type `FlowChangeEventHeader` .

You can then use the `TriggerActionFlowChangeEvent` class to invoke the Flow and pass the change event header
as the input variable.

### [TriggerActionFlowClearAllBypasses](trigger-actions-framework/TriggerActionFlowClearAllBypasses.md)

The `TriggerActionFlowClearAllBypasses` class is a utility class that handles the
clearing of all bypasses for objects, Apex actions, or Flow actions.

Bypasses are used to prevent the execution of specific Trigger Actions.
The `TriggerActionFlowClearAllBypasses` class provides a way to clear all bypasses for a specific object, Apex action, or Flow action.

To use the `TriggerActionFlowClearAllBypasses` class, you must first create a list of the objects, Apex actions, or Flow actions that you want to clear the bypasses for.
You can then call the `clearAllBypasses` method of the `TriggerActionFlowClearAllBypasses` class and pass the list of objects, Apex actions, or Flow actions as the input parameter.

The `clearAllBypasses` method will clear all bypasses for the specified objects, Apex actions, or Flow actions.

### [TriggerActionFlowClearBypass](trigger-actions-framework/TriggerActionFlowClearBypass.md)

The `TriggerActionFlowClearBypass` class is a utility class that handles the clearing
of bypasses for objects, Apex actions, or Flow actions.

Bypasses are used to prevent the execution of specific Trigger Actions.
The `TriggerActionFlowClearBypass` class provides a way to clear the bypass for a specific object, Apex action, or Flow action.

To use the `TriggerActionFlowClearBypass` class, you must first create a list of the objects, Apex actions, or Flow actions that you want to clear the bypasses for.
You can then call the `clearBypass` method of the `TriggerActionFlowClearBypass` class and pass the list of objects, Apex actions, or Flow actions as the input parameter.

The `clearBypass` method will clear the bypass for the specified objects, Apex actions, or Flow actions.

### [TriggerActionFlowIsBypassed](trigger-actions-framework/TriggerActionFlowIsBypassed.md)

The `TriggerActionFlowIsBypassed` class is a utility class that handles the checking of
bypasses for objects, Apex actions, or Flow actions.

Bypasses are used to prevent the execution of specific Trigger Actions.
The `TriggerActionFlowIsBypassed` class provides a way to check if the bypass is set
to `true` for a specific object, Apex action, or Flow action.

To use the `TriggerActionFlowIsBypassed` class, you must first create a list of the objects,
Apex actions, or Flow actions that you want to check the bypasses for.
You can then call the `isBypassed` method of the `TriggerActionFlowIsBypassed` class and
pass the list of objects, Apex actions, or Flow actions as the input parameter.

The `isBypassed` method will return a list of booleans indicating whether the bypass is set
to `true` for each of the specified objects, Apex actions, or Flow actions.

### [TriggerBase](trigger-actions-framework/TriggerBase.md)

The `TriggerBase` class is a base class for all trigger handlers.

Trigger handlers are classes that define the logic that should be executed before or after
a DML operation on a record.
The `TriggerBase` class provides the following functionality:

- A way to bypass the execution of specific trigger handlers.
- A way to check if a specific trigger handler is bypassed.
- A way to clear all bypasses.
- A way to offset the number of existing DML rows.
- A way to wait to finalize the DML operation.
- A way to now finalize the DML operation.

---

To use the `TriggerBase` class, you must create a subclass that implements the `TriggerAction` interface.
The `TriggerAction` interface defines the methods that should be implemented by trigger actions.

### [TriggerTestUtility](trigger-actions-framework/TriggerTestUtility.md)

The `TriggerTestUtility` class is a utility class that provides helper methods for writing
Apex test classes for trigger handlers.

The `TriggerTestUtility` class provides the following helper methods:

- `getFakeId` : This method generates a fake ID for the specified SObject type.
