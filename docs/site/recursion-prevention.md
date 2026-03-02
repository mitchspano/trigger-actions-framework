# Recursion Prevention

Use `TriggerBase.idToNumberOfTimesSeenBeforeUpdate` and `TriggerBase.idToNumberOfTimesSeenAfterUpdate` to prevent recursively processing the same record(s).

---

## Example

```java
public class TA_Opportunity_RecalculateCategory implements TriggerAction.AfterUpdate {

  public void afterUpdate(List<Opportunity> triggerNew, List<Opportunity> triggerOld) {
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(triggerOld);
    List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
    for (Opportunity opp : triggerNew) {
      if (
        TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(opp.id) == 1 &&
        opp.StageName != oldMap.get(opp.id).StageName
      ) {
        oppsToBeUpdated.add(opp);
      }
    }
    if (!oppsToBeUpdated.isEmpty()) {
      this.recalculateCategory(oppsToBeUpdated);
    }
  }

  private void recalculateCategory(List<Opportunity> opportunities) {
    // do some stuff
    update opportunities;
  }
}
```

The counter maps track how many times each record Id has been seen within a given trigger context for the current transaction. Checking for `== 1` ensures the logic runs only on the first pass.

---

## Available Maps

| Map                                             | Trigger Context |
| ----------------------------------------------- | --------------- |
| `TriggerBase.idToNumberOfTimesSeenBeforeUpdate` | `before update` |
| `TriggerBase.idToNumberOfTimesSeenAfterUpdate`  | `after update`  |

---

## See Also

- [API Reference - TriggerBase](trigger-actions-framework/TriggerBase.md)
- [DML Finalizers](dml-finalizers.md)
