# MetadataTriggerHandler Class

`SUPPRESSWARNINGS`

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
 
The `MetadataTriggerHandler` class also uses the `sObject_Trigger_Setting__mdt` Custom Metadata type to define 
Trigger Action settings for specific sObjects. 
 
Each sObject Trigger Setting must specify the following information: 
 
- `Bypass_Permission__c` : The permission required to bypass the Trigger Action for the specified sObject (optional). 
- `Required_Permission__c` : The permission required to execute the Trigger Action for the specified sObject (optional). 
--- 
 
To use the `MetadataTriggerHandler` class, you must create a Trigger on the desired sObject and specify the 
 `MetadataTriggerHandler` class as the handler. 
You can then define Trigger Actions and sObject Trigger Settings in Custom Metadata to control the behavior of the Trigger. 
 
**Example:** 
 
```apex
trigger AccountTrigger on Account (
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

 
This example will execute all Trigger Actions defined in Custom Metadata for the `Account` sObject.

**Group** Trigger Actions Framework

**Inheritance**

[TriggerBase](TriggerBase.md)

**Implements**

TriggerAction.BeforeInsert, 
TriggerAction.AfterInsert, 
TriggerAction.BeforeUpdate, 
TriggerAction.AfterUpdate, 
TriggerAction.BeforeDelete, 
TriggerAction.AfterDelete, 
TriggerAction.AfterUndelete

## Properties
### `idToNumberOfTimesSeenBeforeUpdate`

*Inherited*

This method returns a map of the IDs of the records that have been seen in the `BEFORE_UPDATE` 
context to the number of times they have been seen.

#### Signature
```apex
public static idToNumberOfTimesSeenBeforeUpdate
```

#### Type
Map&lt;Id,Integer&gt;

---

### `idToNumberOfTimesSeenAfterUpdate`

*Inherited*

This method returns a map of the IDs of the records that have been seen 
in the `AFTER_UPDATE` context to the number of times they have been seen.

#### Signature
```apex
public static idToNumberOfTimesSeenAfterUpdate
```

#### Type
Map&lt;Id,Integer&gt;

## Methods
### `bypass(actionName)`

Bypass the execution of a Trigger Action.

#### Signature
```apex
public static void bypass(String actionName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| actionName | String | The name of the Trigger Action to bypass. |

#### Return Type
**void**

---

### `clearBypass(actionName)`

Clear the bypass for a Trigger Action.

#### Signature
```apex
public static void clearBypass(String actionName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| actionName | String | The name of the Trigger Action to clear the bypass for. |

#### Return Type
**void**

---

### `isBypassed(actionName)`

Check if a Trigger Action is bypassed.

#### Signature
```apex
public static Boolean isBypassed(String actionName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| actionName | String | The name of the Trigger Action to check. |

#### Return Type
**Boolean**

True if the Trigger Action is bypassed, false otherwise.

---

### `bypass(actionType)`

Bypass the execution of a Trigger Action.

#### Signature
```apex
public static void bypass(System.Type actionType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| actionType | System.Type | The Type of the Trigger Action to bypass. |

#### Return Type
**void**

---

### `clearBypass(actionType)`

Clear the bypass for a Trigger Action.

#### Signature
```apex
public static void clearBypass(System.Type actionType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| actionType | System.Type | The Type of the Trigger Action to clear the bypass for. |

#### Return Type
**void**

---

### `isBypassed(actionType)`

Check if a Trigger Action is bypassed.

#### Signature
```apex
public static Boolean isBypassed(System.Type actionType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| actionType | System.Type | The Type of the Trigger Action to check. |

#### Return Type
**Boolean**

True if the Trigger Action is bypassed, false otherwise.

---

### `clearAllBypasses()`

Clear all bypasses for Trigger Actions.

#### Signature
```apex
public static void clearAllBypasses()
```

#### Return Type
**void**

---

### `beforeInsert(triggerNew)`

Execute the Before Insert Trigger Actions.

#### Signature
```apex
public void beforeInsert(List<SObject> triggerNew)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of new records being inserted. |

#### Return Type
**void**

---

### `afterInsert(triggerNew)`

Execute the After Insert Trigger Actions.

#### Signature
```apex
public void afterInsert(List<SObject> triggerNew)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of new records that were inserted. |

#### Return Type
**void**

---

### `beforeUpdate(triggerNew, triggerOld)`

Execute the Before Update Trigger Actions.

#### Signature
```apex
public void beforeUpdate(List<SObject> triggerNew, List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of updated records. |
| triggerOld | List&lt;SObject&gt; | The list of old records before the update. |

#### Return Type
**void**

---

### `afterUpdate(triggerNew, triggerOld)`

Execute the After Update Trigger Actions.

#### Signature
```apex
public void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of updated records. |
| triggerOld | List&lt;SObject&gt; | The list of old records before the update. |

#### Return Type
**void**

---

### `beforeDelete(triggerOld)`

Execute the Before Delete Trigger Actions.

#### Signature
```apex
public void beforeDelete(List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerOld | List&lt;SObject&gt; | The list of records being deleted. |

#### Return Type
**void**

---

### `afterDelete(triggerOld)`

Execute the After Delete Trigger Actions.

#### Signature
```apex
public void afterDelete(List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerOld | List&lt;SObject&gt; | The list of records that were deleted. |

#### Return Type
**void**

---

### `afterUndelete(triggerNew)`

Execute the After Undelete Trigger Actions.

#### Signature
```apex
public void afterUndelete(List<SObject> triggerNew)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of records that were undeleted. |

#### Return Type
**void**

---

### `offsetExistingDmlRows()`

*Inherited*

This method offsets the number of existing DML rows.

#### Signature
```apex
public static void offsetExistingDmlRows()
```

#### Return Type
**void**

---

### `waitToFinalize()`

*Inherited*

This method waits to finalize the DML operation.

#### Signature
```apex
public static void waitToFinalize()
```

#### Return Type
**void**

---

### `nowFinalize()`

*Inherited*

This method now finalizes the DML operation.

#### Signature
```apex
public static void nowFinalize()
```

#### Return Type
**void**

---

### `run()`

*Inherited*

This method runs the trigger handler.

#### Signature
```apex
public void run()
```

#### Return Type
**void**