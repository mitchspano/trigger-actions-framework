# Getting Started

## Prerequisites

Install the framework via an Unlocked Package:

- [Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tKY000000R0yHYAS)
- [Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tKY000000R0yHYAS)

---

## Enabling for an SObject

### Step 1 - Create the Trigger

Call `MetadataTriggerHandler` in the trigger body for the SObject you want to enable:

```java
trigger OpportunityTrigger on Opportunity (
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  new MetadataTriggerHandler().run();
}
```

### Step 2 - Create the SObject Trigger Setting

Create a row in the `SObject_Trigger_Setting__mdt` custom metadata type for the SObject:

![New SObject Trigger Setting](images/newSObjectTriggerSetting.png)

![SObject Trigger Settings](images/SObjectTriggerSettings.gif)

That's it! You can now configure individual [Apex Actions](apex-actions.md) and [Flow Actions](flow-actions.md) to run in a defined order for this SObject.

---

## Compatibility with Installed Package SObjects

The framework supports standard objects, custom objects, and objects from installed packages. For objects from an installed package, separate the Object API Name from the Object Namespace on the `SObject_Trigger_Setting__mdt` record:

| Object Namespace | Object API Name |
| ---------------- | --------------- |
| Acme             | Explosives\_\_c |

For example, to use the framework on `Acme__Explosives__c`, configure the record as shown above.

---

## Next Steps

- [Define Apex Actions](apex-actions.md)
- [Define Flow Actions](flow-actions.md)
- [Set Entry Criteria](entry-criteria.md)
- [Configure Bypass Mechanisms](bypass-mechanisms.md)
