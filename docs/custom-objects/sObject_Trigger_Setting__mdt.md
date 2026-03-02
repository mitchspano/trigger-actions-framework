# SObject Trigger Setting

## API Name

`SObject_Trigger_Setting__mdt`

## Fields

### Bypass Execution

Set this to true to bypass all Trigger Actions from being called on this SObject

**API Name**

`Bypass_Execution__c`

**Type**

_Checkbox_

---

### Bypass Permission

Optional. Enter the API name of a permission. If this field has a value, then the triggers on this object will be bypassed if the running user has the custom permission identified.

**API Name**

`Bypass_Permission__c`

**Type**

_Text_

---

### Object API Name

**Required**

Enter the API Name of the object for this trigger. If this object is part of a managed package, do not include the prefix.

**API Name**

`Object_API_Name__c`

**Type**

_Text_

---

### Object Namespace

Enter the namespace object for this trigger.

**API Name**

`Object_Namespace__c`

**Type**

_Text_

---

### Required Permission

Optional. Enter the API name of a permission. If this field has a value, then the triggers on this object will only execute if the running user has the custom permission identified.

**API Name**

`Required_Permission__c`

**Type**

_Text_

---

### TriggerRecord Class Name

Enter the API name of a global class which extends &#x60;TriggerRecord&#x60; and contains two global properties: &#x60;record&#x60;
and &#x60;recordPrior&#x60;. Both of these variables need to match the SObject type for this SObject
Trigger Setting record.

**API Name**

`TriggerRecord_Class_Name__c`

**Type**

_Text_
