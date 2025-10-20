# TriggerBase Class
`virtual`

`SUPPRESSWARNINGS`

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

**Group** Trigger Actions Framework

## Properties
### `idToNumberOfTimesSeenBeforeUpdate`

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

This method returns a map of the IDs of the records that have been seen 
in the `AFTER_UPDATE` context to the number of times they have been seen.

#### Signature
```apex
public static idToNumberOfTimesSeenAfterUpdate
```

#### Type
Map&lt;Id,Integer&gt;

## Methods
### `bypass(sObjectName)`

This method bypasses the execution of the specified object.

#### Signature
```apex
public static void bypass(String sObjectName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjectName | String | The API name of the object to bypass. |

#### Return Type
**void**

---

### `clearBypass(sObjectName)`

This method clears the bypass for the specified object.

#### Signature
```apex
public static void clearBypass(String sObjectName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjectName | String | The API name of the object to clear the bypass for. |

#### Return Type
**void**

---

### `isBypassed(sObjectName)`

This method checks if the specified object is bypassed.

#### Signature
```apex
public static Boolean isBypassed(String sObjectName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjectName | String | The API name of the object to check the bypass for. |

#### Return Type
**Boolean**

True if the object is bypassed, false otherwise.

---

### `bypass(sObjectType)`

This method bypasses the execution of the specified object.

#### Signature
```apex
public static void bypass(Schema.sObjectType sObjectType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjectType | Schema.sObjectType | The sObjectType of the object to bypass. |

#### Return Type
**void**

---

### `clearBypass(sObjectType)`

This method clears the bypass for the specified object.

#### Signature
```apex
public static void clearBypass(Schema.sObjectType sObjectType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjectType | Schema.sObjectType | The sObjectType of the object to clear the bypass for. |

#### Return Type
**void**

---

### `isBypassed(sObjectType)`

This method checks if the specified object is bypassed.

#### Signature
```apex
public static Boolean isBypassed(Schema.sObjectType sObjectType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjectType | Schema.sObjectType | The sObjectType of the object to check the bypass for. |

#### Return Type
**Boolean**

True if the object is bypassed, false otherwise.

---

### `clearAllBypasses()`

This method clears all bypasses.

#### Signature
```apex
public static void clearAllBypasses()
```

#### Return Type
**void**

---

### `offsetExistingDmlRows()`

This method offsets the number of existing DML rows.

#### Signature
```apex
public static void offsetExistingDmlRows()
```

#### Return Type
**void**

---

### `waitToFinalize()`

This method waits to finalize the DML operation.

#### Signature
```apex
public static void waitToFinalize()
```

#### Return Type
**void**

---

### `nowFinalize()`

This method now finalizes the DML operation.

#### Signature
```apex
public static void nowFinalize()
```

#### Return Type
**void**

---

### `run()`

This method runs the trigger handler.

#### Signature
```apex
public void run()
```

#### Return Type
**void**