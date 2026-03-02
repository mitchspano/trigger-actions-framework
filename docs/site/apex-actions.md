# Actions

## Defining an Apex Action

To define a specific action, write an individual class that implements the applicable interface(s) from `TriggerAction`:

```java
public class TA_Opportunity_StageInsertRules implements TriggerAction.BeforeInsert {

  @TestVisible
  private static final String PROSPECTING = 'Prospecting';
  @TestVisible
  private static final String INVALID_STAGE_INSERT_ERROR =
    'The Stage must be \'Prospecting\' when an Opportunity is created';

  public void beforeInsert(List<Opportunity> triggerNew) {
    for (Opportunity opp : triggerNew) {
      if (opp.StageName != PROSPECTING) {
        opp.addError(INVALID_STAGE_INSERT_ERROR);
      }
    }
  }
}
```

## Registering the Action

Create a row in the `Trigger_Action__mdt` custom metadata type to invoke the action in the specified order on the SObject:

![New Trigger Action](images/newTriggerAction.png)

![New Trigger Action GIF](images/newTriggerAction.gif)

---

## Available Interfaces

| Interface                     | Method Signature                                                        |
| ----------------------------- | ----------------------------------------------------------------------- |
| `TriggerAction.BeforeInsert`  | `void beforeInsert(List<SObject> triggerNew)`                           |
| `TriggerAction.AfterInsert`   | `void afterInsert(List<SObject> triggerNew)`                            |
| `TriggerAction.BeforeUpdate`  | `void beforeUpdate(List<SObject> triggerNew, List<SObject> triggerOld)` |
| `TriggerAction.AfterUpdate`   | `void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld)`  |
| `TriggerAction.BeforeDelete`  | `void beforeDelete(List<SObject> triggerOld)`                           |
| `TriggerAction.AfterDelete`   | `void afterDelete(List<SObject> triggerOld)`                            |
| `TriggerAction.AfterUndelete` | `void afterUndelete(List<SObject> triggerNew)`                          |
| `TriggerAction.DmlFinalizer`  | `void execute(FinalizerHandler.Context context)`                        |

A single class can implement multiple interfaces.

---

## Working with Trigger Maps

To avoid downcasting from `Map<Id, SObject>`, construct a new map from `triggerNew` and `triggerOld` directly:

```java
public void beforeUpdate(List<Opportunity> triggerNew, List<Opportunity> triggerOld) {
  Map<Id, Opportunity> newMap = new Map<Id, Opportunity>(triggerNew);
  Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(triggerOld);
  // ...
}
```

---

## Inner Class Actions

Actions can also be inner classes. When the action class is an inner class, the `Apex_Class_Name__c` value on the `Trigger_Action__mdt` row should be `OuterClass.InnerClass`. For example:

```java
public class TA_Opportunity_Queries {
  // ...
  public class Service implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Opportunity> triggerNew) {
      // ...
    }
  }
}
```

In this case, `Apex_Class_Name__c` would be `TA_Opportunity_Queries.Service`.

---

## See Also

- [Flow Actions](flow-actions.md)
- [Avoid Repeated Queries](avoid-repeated-queries.md)
- [DML-Less Trigger Testing](dml-less-testing.md)
- [API Reference - TriggerAction](trigger-actions-framework/TriggerAction.md)
