# Bypass Mechanisms

The framework provides standardized bypass mechanisms to control execution at the SObject level or for a specific action.

---

## Bypass Globally (Setup Menu)

Navigate to the SObject Trigger Setting or Trigger Action metadata record and check the **Bypass Execution** checkbox.

![Bypass SObject](images/setupMenuBypassSObject.png)

![Bypass Action](images/setupMenuBypassAction.png)

These bypasses remain active until the checkbox is unchecked.

---

## Bypass for a Transaction

You can bypass all actions on an SObject or specific Apex/Flow actions for the remainder of the transaction using Apex or Flow.

### Bypass from Apex

The framework provides compile-safe bypass methods that accept type references.

**Bypass SObjects using `Schema.SObjectType`:**

```java
public void updateAccountsNoTrigger(List<Account> accountsToUpdate) {
  TriggerBase.bypass(Schema.Account.SObjectType);
  update accountsToUpdate;
  TriggerBase.clearBypass(Schema.Account.SObjectType);
}
```

**Bypass Apex classes using `System.Type`:**

```java
public void insertOpportunitiesNoRules(List<Opportunity> opportunitiesToInsert) {
  MetadataTriggerHandler.bypass(TA_Opportunity_StageInsertRules.class);
  insert opportunitiesToInsert;
  MetadataTriggerHandler.clearBypass(TA_Opportunity_StageInsertRules.class);
}
```

**Bypass Flows using `Flow.Interview`:**

```java
public void updateContactsNoFlow(List<Contact> contactsToUpdate) {
  TriggerActionFlow.bypass(Flow.Interview.Contact_Flow.class);
  update contactsToUpdate;
  TriggerActionFlow.clearBypass(Flow.Interview.Contact_Flow.class);
}
```

### Bypass from Flow

Use the `TriggerActionFlowBypass.bypass` invocable method. Set the `Bypass Type` to `Apex`, `Object`, or `Flow`, then pass the API name of the SObject, class, or flow into the `Name` field.

|                             Flow                             |               Invocable Action Setup               |
| :----------------------------------------------------------: | :------------------------------------------------: |
| ![Bypass Action in Flow](images/bypass_flow_apex_action.png) | ![Bypass Action Variables](images/bypass_flow.png) |

---

## Clear Bypasses

Apex and Flow bypasses stay active until the transaction ends or until explicitly cleared.

### From Apex

```java
// Clear a specific bypass
TriggerBase.clearBypass(Schema.Account.SObjectType);
MetadataTriggerHandler.clearBypass(TA_Opportunity_StageInsertRules.class);
TriggerActionFlow.clearBypass(Flow.Interview.Contact_Flow.class);

// Clear all bypasses of a given type
TriggerBase.clearAllBypasses();
MetadataTriggerHandler.clearAllBypasses();
TriggerActionFlow.clearAllBypasses();
```

### From Flow

Use the `TriggerActionFlowClearBypass` and `TriggerActionFlowClearAllBypasses` invocable methods. Set the `bypassType` to `Apex`, `Object`, or `Flow` and the `name` field to the API name of what you want to clear.

---

## Bypass for Specific Users

Both `SObject_Trigger_Setting__mdt` and `Trigger_Action__mdt` have `Bypass_Permission__c` and `Required_Permission__c` fields.

### Bypass Permission

Enter the API name of a custom permission in `Bypass_Permission__c`. If the running user has this permission, the trigger/action is **bypassed**. Useful for integration service accounts and one-time data loads.

### Required Permission

Enter the API name of a custom permission in `Required_Permission__c`. The trigger/action **only executes** if the running user has this permission. Useful for releasing new functionality to a subset of users.

---

## See Also

- [API Reference - TriggerBase](trigger-actions-framework/TriggerBase.md)
- [API Reference - MetadataTriggerHandler](trigger-actions-framework/MetadataTriggerHandler.md)
- [API Reference - TriggerActionFlow](trigger-actions-framework/TriggerActionFlow.md)
- [API Reference - TriggerActionFlowBypass](trigger-actions-framework/TriggerActionFlowBypass.md)
