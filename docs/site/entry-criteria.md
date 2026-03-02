# Entry Criteria Formula

Individual trigger actions can have their own dynamic entry criteria defined as a simple formula. This feature uses the [`FormulaEval` namespace](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_namespace_formulaeval.htm) within Apex.

> If the entry criteria field is null, the system acts as if there are no entry criteria and processes all records.

---

## SObject Setup

### Step 1 - Define a TriggerRecord Class

Define a class that extends `TriggerRecord` for the specific SObject type. This class must be **global** and contains two global properties: `record` and `recordPrior`, which get their values from `newSObject` and `oldSObject` downcast to the proper concrete SObject type.

Example for `Account`:

```java
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
```

### Step 2 - Register the TriggerRecord Class

Enter the API name of that class in the `SObject_Trigger_Setting__mdt.TriggerRecord_Class_Name__c` field on the `SObject_Trigger_Setting__mdt` record for that SObject.

### Step 3 - Define the Formula

On the `Trigger_Action__mdt` record, define a formula in the `Entry_Criteria__c` field. The formula operates on an instance of the `TriggerRecord` class at runtime to determine if a record should be processed.

Example:

```
record.Name = "Bob" && recordPrior.Name = "Joe"
```

The automation will only execute for records where the name used to be "Joe" and is now changed to "Bob".

![Entry Criteria](images/Entry_Criteria.png)

---

## Caveats

> **Field Traversal Limitations:** The `record` and `recordPrior` objects within the formula are limited to fields directly available on the record itself. Cross-object traversal such as `record.RecordType.DeveloperName` is **not supported**.

---

## Benefits

Using Entry Criteria reduces unnecessary processing and also helps avoid the [Flow recursion depth limit](flow-actions.md#recursion-depth-warning). Define entry criteria on all Flow actions whenever possible.

---

## See Also

- [Flow Actions](flow-actions.md)
- [Apex Actions](apex-actions.md)
- [Custom Metadata - Trigger_Action\_\_mdt](custom-objects/Trigger_Action__mdt.md)
