# DML-Less Trigger Testing

Performing DML operations is computationally intensive and slows down unit tests. The Trigger Actions Framework makes it easy to test trigger logic **without any DML**.

---

## TriggerTestUtility

The `TriggerTestUtility` class generates fake record Ids so you can construct SObject records for testing without inserting them:

```java
@IsTest
public class TriggerTestUtility {
  static Integer myNumber = 1;

  public static Id getFakeId(Schema.SObjectType SObjectType) {
    String result = String.valueOf(myNumber++);
    return (Id) (SObjectType.getDescribe().getKeyPrefix() +
    '0'.repeat(12 - result.length()) +
    result);
  }
}
```

---

## Example Test

```java
@IsTest
private static void invalidStageChangeShouldPreventSave() {
  List<Opportunity> triggerNew = new List<Opportunity>();
  List<Opportunity> triggerOld = new List<Opportunity>();

  // Generate a fake Id - no DML required
  Id myRecordId = TriggerTestUtility.getFakeId(Opportunity.SObjectType);

  triggerNew.add(
    new Opportunity(
      Id = myRecordId,
      StageName = Constants.OPPORTUNITY_STAGENAME_CLOSED_WON
    )
  );
  triggerOld.add(
    new Opportunity(
      Id = myRecordId,
      StageName = Constants.OPPORTUNITY_STAGENAME_QUALIFICATION
    )
  );

  // Directly invoke the action - no trigger framework overhead
  new TA_Opportunity_StageChangeRules().beforeUpdate(triggerNew, triggerOld);

  // Use getErrors() to assert addError results without DML
  System.assertEquals(
    true,
    triggerNew[0].hasErrors(),
    'The record should have errors'
  );
  System.assertEquals(
    1,
    triggerNew[0].getErrors().size(),
    'There should be exactly one error'
  );
  System.assertEquals(
    triggerNew[0].getErrors()[0].getMessage(),
    String.format(
      TA_Opportunity_StageChangeRules.INVALID_STAGE_CHANGE_ERROR,
      new List<String>{
        Constants.OPPORTUNITY_STAGENAME_QUALIFICATION,
        Constants.OPPORTUNITY_STAGENAME_CLOSED_WON
      }
    ),
    'The error should be the one we are expecting'
  );
}
```

Zero DML operations - all logic covered.

---

## Key Techniques

| Technique                        | Description                                                            |
| -------------------------------- | ---------------------------------------------------------------------- |
| `TriggerTestUtility.getFakeId()` | Generate a valid-format fake Id without inserting a record             |
| `SObject.hasErrors()`            | Check if `addError()` was called on a record                           |
| `SObject.getErrors()`            | Retrieve error messages added via `addError()`                         |
| Direct method invocation         | Call the action class method directly, bypassing the trigger framework |

---

## See Also

- [API Reference - TriggerTestUtility](trigger-actions-framework/TriggerTestUtility.md)
- [Apex Actions](apex-actions.md)
