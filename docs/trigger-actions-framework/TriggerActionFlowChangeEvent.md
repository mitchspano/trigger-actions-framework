# TriggerActionFlowChangeEvent Class

The `TriggerActionFlowChangeEvent` class is a subclass of the `TriggerActionFlow` 
class that is used to handle change events. 
 
Change events are events that are generated when a record is created, updated, or deleted. 
The `TriggerActionFlowChangeEvent` class provides the ability to access the change event header in the Flow interview. 
 
To use the `TriggerActionFlowChangeEvent` class, you must first create a Flow that accepts a variable of 
type `FlowChangeEventHeader` . 
 
You can then use the `TriggerActionFlowChangeEvent` class to invoke the Flow and pass the change event header 
as the input variable.

**Group** Trigger Actions Framework

**Inheritance**

[TriggerActionFlow](TriggerActionFlow.md)

## Fields
### `flowName`

*Inherited*

#### Signature
```apex
public flowName
```

#### Type
String

---

### `allowRecursion`

*Inherited*

#### Signature
```apex
public allowRecursion
```

#### Type
Boolean

## Methods
### `bypass(flowName)`

*Inherited*

This method bypasses the execution of the Flow for the specified list of records.

#### Signature
```apex
public static void bypass(String flowName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| flowName | String | The API name of the Flow to bypass. |

#### Return Type
**void**

---

### `clearBypass(flowName)`

*Inherited*

This method clears the bypass for the specified list of records.

#### Signature
```apex
public static void clearBypass(String flowName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| flowName | String | The API name of the Flow to clear the bypass for. |

#### Return Type
**void**

---

### `isBypassed(flowName)`

*Inherited*

This method checks if the Flow is bypassed for the specified list of records.

#### Signature
```apex
public static Boolean isBypassed(String flowName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| flowName | String | The API name of the Flow to check the bypass for. |

#### Return Type
**Boolean**

,[object Object], if the Flow is bypassed for the specified list of records, ,[object Object], otherwise.

---

### `bypass(flowType)`

*Inherited*

This method bypasses the execution of the Flow for the specified list of records.

#### Signature
```apex
public static void bypass(System.Type flowType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| flowType | System.Type | The Type of the Flow to bypass (e.g., Flow.Interview.MyFlow.class). |

#### Return Type
**void**

#### Throws
IllegalArgumentException: if the type does not represent a Flow.

---

### `clearBypass(flowType)`

*Inherited*

This method clears the bypass for the specified list of records.

#### Signature
```apex
public static void clearBypass(System.Type flowType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| flowType | System.Type | The Type of the Flow to clear the bypass for (e.g., Flow.Interview.MyFlow.class). |

#### Return Type
**void**

#### Throws
IllegalArgumentException: if the type does not represent a Flow.

---

### `isBypassed(flowType)`

*Inherited*

This method checks if the Flow is bypassed for the specified list of records.

#### Signature
```apex
public static Boolean isBypassed(System.Type flowType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| flowType | System.Type | The Type of the Flow to check the bypass for (e.g., Flow.Interview.MyFlow.class). |

#### Return Type
**Boolean**

,[object Object], if the Flow is bypassed for the specified list of records, ,[object Object], otherwise.

#### Throws
IllegalArgumentException: if the type does not represent a Flow.

---

### `clearAllBypasses()`

*Inherited*

This method clears all bypasses for all Flows.

#### Signature
```apex
public static void clearAllBypasses()
```

#### Return Type
**void**

---

### `validateType(bypassType)`

*Inherited*

This method validates the specified bypass type.

#### Signature
```apex
public static void validateType(String bypassType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| bypassType | String | The bypass type to validate. |

#### Return Type
**void**

#### Throws
IllegalArgumentException: if the bypass type is not valid.

---

### `beforeInsert(triggerNew)`

*Inherited*

This method executes the Flow for the specified list of records before the insert of the records.

#### Signature
```apex
public void beforeInsert(List<SObject> triggerNew)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of records to execute the Flow for. |

#### Return Type
**void**

---

### `afterInsert(triggerNew)`

*Inherited*

This method executes the Flow for the specified list of records after the insert of the records.

#### Signature
```apex
public void afterInsert(List<SObject> triggerNew)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of records to execute the Flow for. |

#### Return Type
**void**

---

### `beforeUpdate(triggerNew, triggerOld)`

*Inherited*

This method executes the Flow for the specified list of records before the update of the records.

#### Signature
```apex
public void beforeUpdate(List<SObject> triggerNew, List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of new records that are being updated. |
| triggerOld | List&lt;SObject&gt; | The list of old records that are being updated. |

#### Return Type
**void**

---

### `afterUpdate(triggerNew, triggerOld)`

*Inherited*

This method executes the Flow for the specified list of records after the update of the records.

#### Signature
```apex
public void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of new records that are being updated. |
| triggerOld | List&lt;SObject&gt; | The list of old records that are being updated. |

#### Return Type
**void**

---

### `beforeDelete(triggerOld)`

*Inherited*

This method executes the Flow for the specified list of records before the delete of the records.

#### Signature
```apex
public void beforeDelete(List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerOld | List&lt;SObject&gt; | The list of old records that are being deleted. |

#### Return Type
**void**

---

### `afterDelete(triggerOld)`

*Inherited*

This method executes the Flow for the specified list of records after the delete of the records.

#### Signature
```apex
public void afterDelete(List<SObject> triggerOld)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerOld | List&lt;SObject&gt; | The list of old records that are being deleted. |

#### Return Type
**void**

---

### `afterUndelete(triggerNew)`

*Inherited*

This method executes the Flow for the specified list of records before the undelete of the records.

#### Signature
```apex
public void afterUndelete(List<SObject> triggerNew)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| triggerNew | List&lt;SObject&gt; | The list of records that are being restored. |

#### Return Type
**void**