# DML Finalizers

A **DML Finalizer** is a piece of code that executes **exactly one time** at the very end of a DML operation.

This is different from the final action within a given trigger context, which can be executed multiple times due to cascading DML operations or batch sizes over 200. DML Finalizers are ideal for:

- Enqueuing a Queueable job
- Inserting a collection of gathered logs

> **DML Finalizers are experimental.** If you encounter issues, please [open an issue](https://github.com/mitchspano/trigger-actions-framework/issues) on GitHub.

---

## Defining a Finalizer

Implement the `TriggerAction.DmlFinalizer` interface. Use public static variables/methods so that trigger actions can register data to be processed during the finalizer's execution:

```java
public with sharing class OpportunityCategoryCalculator
  implements Queueable, TriggerAction.DmlFinalizer {

  private static List<Opportunity> toProcess = new List<Opportunity>();
  private List<Opportunity> currentlyProcessing;

  public static void registerOpportunities(List<Opportunity> toRecalculate) {
    toProcess.addAll(toRecalculate);
  }

  public void execute(FinalizerHandler.Context context) {
    if (!toProcess.isEmpty()) {
      this.currentlyProcessing = toProcess;
      System.enqueueJob(this);
      toProcess.clear();
    }
  }

  public void execute(System.QueueableContext qc) {
    // do some stuff
  }
}
```

## Registering the Finalizer

Create a corresponding row in `DML_Finalizer__mdt` to invoke the finalizer in the specified order:

![DML Finalizer](images/dmlFinalizer.png)

## Using the Finalizer from a Trigger Action

```java
public with sharing class TA_Opportunity_RecalculateCategory
  implements TriggerAction.AfterUpdate {

  public void afterUpdate(
    List<Opportunity> triggerNew,
    List<Opportunity> triggerOld
  ) {
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(triggerOld);
    List<Opportunity> toRecalculate = new List<Opportunity>();
    for (Opportunity opp : triggerNew) {
      if (opp.Amount != oldMap.get(opp.Id).Amount) {
        toRecalculate.add(opp);
      }
    }
    if (!toRecalculate.isEmpty()) {
      OpportunityCategoryCalculator.registerOpportunities(toRecalculate);
    }
  }
}
```

---

## Bypassing Finalizers

Use the `Bypass_Execution__c` checkbox on the `DML_Finalizer__mdt` record to bypass globally. Use `Bypass_Permission__c` / `Required_Permission__c` for user-level control.

For transactional bypasses:

```java
FinalizerHandler.bypass(OpportunityCategoryCalculator.class);
FinalizerHandler.clearBypass(OpportunityCategoryCalculator.class);
FinalizerHandler.isBypassed(OpportunityCategoryCalculator.class);
FinalizerHandler.clearAllBypasses();
```

---

## Caveats

### No Further DML Allowed

Finalizers cannot call additional DML operations - otherwise they couldn't guarantee their final nature. A runtime error is thrown if a finalizer calls DML.

### Independent of SObject

All configured finalizers in the org are invoked at the end of **any** DML operation, regardless of which SObject triggered it.

### Empty Context

The `FinalizerHandler.Context` object currently has no properties. It is established to future-proof the interface.

### Universal Adoption Required

The framework must be enabled on **every SObject** that supports triggers and will have DML performed on it during a transaction. If DML is performed on an SObject whose trigger does not use the framework, finalization cannot be detected.

### Offsetting DML Row Counts

Detection relies on `Limits.getDmlRows()`. Certain operations (like `Database.setSavepoint()`) or SObjects without trigger support (like `CaseTeamMember`) can throw off the count. Use `TriggerBase.offsetExistingDmlRows()` before the first DML operation to compensate:

```java
Savepoint sp = Database.setSavepoint(); // adds to Limits.getDmlRows()
TriggerBase.offsetExistingDmlRows();
insert accounts;
```

```java
insert caseTeamMembers; // no trigger support - counts are off
TriggerBase.offsetExistingDmlRows();
update cases;
```

> Consider upvoting [this idea](https://ideas.salesforce.com/s/idea/a0B8W00000GdpidUAB/total-dml-size-trigger-context-variable) to add a native DML size context variable.

### Wait to Finalize

When multiple sequential DML operations should share a single finalization, use `waitToFinalize()` and `nowFinalize()`:

```java
@AuraEnabled
public static void foo() {
  TriggerBase.waitToFinalize();
  Account acme = new Account(Name = 'Acme');
  insert acme;
  Account acmeExplosives = new Account(
    Name = 'Acme-Explosives',
    ParentId = acme.Id
  );
  insert acmeExplosives;
  TriggerBase.nowFinalize(); // single finalizer called here
}
```

### Handle Multiple Finalizer Invocations

When `waitToFinalize` is infeasible (e.g., Composite API calls), guard your finalizer against multiple invocations by clearing collections after processing:

```java
public void execute(FinalizerHandler.Context context) {
  if (!toProcess.isEmpty()) {
    this.currentlyProcessing = toProcess;
    System.enqueueJob(this);
    toProcess.clear(); // always clear after processing
  }
}
```

---

## See Also

- [API Reference - FinalizerHandler](trigger-actions-framework/FinalizerHandler.md)
- [API Reference - TriggerBase](trigger-actions-framework/TriggerBase.md)
- [Custom Metadata - DML_Finalizer\_\_mdt](custom-objects/DML_Finalizer__mdt.md)
