# Avoid Repeated Queries

Multiple trigger actions on the same SObject may require results from the same query. Use the **Singleton pattern** to fetch and store query results once, then reuse them across multiple action classes.

---

## Example - Query Class

```java
public class TA_Opportunity_Queries {
  private static TA_Opportunity_Queries instance;

  private TA_Opportunity_Queries() {
  }

  public static TA_Opportunity_Queries getInstance() {
    if (TA_Opportunity_Queries.instance == null) {
      TA_Opportunity_Queries.instance = new TA_Opportunity_Queries();
    }
    return TA_Opportunity_Queries.instance;
  }

  public Map<Id, Account> beforeAccountMap { get; private set; }

  public class Service implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Opportunity> triggerNew) {
      TA_Opportunity_Queries.getInstance().beforeAccountMap = getAccountMapFromOpportunities(
        triggerNew
      );
    }

    private Map<Id, Account> getAccountMapFromOpportunities(
      List<Opportunity> triggerNew
    ) {
      Set<Id> accountIds = new Set<Id>();
      for (Opportunity myOpp : triggerNew) {
        accountIds.add(myOpp.AccountId);
      }
      return new Map<Id, Account>(
        [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
      );
    }
  }
}
```

## Setup

Configure the query class as the **first action** in the trigger context. All subsequent actions can then access results via `TA_Opportunity_Queries.getInstance()`.

![Queries Setup](images/queriesSetup.png)

When registering an inner class as the action, set `Apex_Class_Name__c` to the fully-qualified name `TA_Opportunity_Queries.Service`:

![Queries Service](images/queriesService.png)

---

## Example - Consuming the Query Results

```java
public class TA_Opportunity_StandardizeName implements TriggerAction.BeforeInsert {
  public void beforeInsert(List<Opportunity> triggerNew) {
    Map<Id, Account> accountIdToAccount = TA_Opportunity_Queries.getInstance()
      .beforeAccountMap;
    for (Opportunity myOpp : triggerNew) {
      String accountName = accountIdToAccount.get(myOpp.AccountId)?.Name;
      myOpp.Name = accountName != null
        ? accountName + ' | ' + myOpp.Name
        : myOpp.Name;
    }
  }
}
```

---

## See Also

- [Apex Actions](apex-actions.md)
- [API Reference - MetadataTriggerHandler](trigger-actions-framework/MetadataTriggerHandler.md)
