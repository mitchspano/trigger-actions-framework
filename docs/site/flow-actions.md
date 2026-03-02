# Flow Actions

The Trigger Actions Framework can invoke a Flow by name and control the order of that flow's execution amongst other trigger actions in a given context - including interleaving it with Apex automations.

---

## Defining a Flow

To make your flows usable as trigger actions, they must be **auto-launched flows** with the following flow resource variables:

| Variable Name | Variable Type | Available for Input | Available for Output | Description                                        | Available Contexts       |
| ------------- | ------------- | ------------------- | -------------------- | -------------------------------------------------- | ------------------------ |
| `record`      | record        | yes                 | yes                  | the new version of the record in the DML operation | insert, update, undelete |
| `recordPrior` | record        | yes                 | no                   | the old version of the record in the DML operation | update, delete           |

Here is an example of a trigger action flow that checks if a record's name has changed and sets the record's description to a default value:

![Sample Flow](images/sampleFlow.png)

## Registering the Flow Action

Insert a `Trigger_Action__mdt` record with:

- `Apex_Class_Name__c` = `TriggerActionFlow`
- `Flow_Name__c` = the API name of the flow

You can select the `Allow_Flow_Recursion__c` checkbox to allow flows to run recursively (advanced).

![Flow Trigger Action](images/flowTriggerAction.png)

---

## Recursion Depth Warning

> **Trigger Action Flows and Recursion Depth**
>
> - Trigger Action Flows are executed using the [`Invocable.Action` class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Invocable_Action.htm) and are subject to an undocumented "maximum recursion depth of 3" - lower than the usual [trigger depth limit of 16](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm).
> - This limit can be reached when Trigger Action Flows perform DML operations that cascade across multiple objects with their own Trigger Action Flows.
> - **Safe use cases:** Same-record updates, `addError` calls, and workflow email alerts.
> - **How to avoid issues:** Define [Entry Criteria](entry-criteria.md) on all Flow actions to reduce unnecessary executions and lower the likelihood of hitting the limit.

---

## Flow Actions for Change Data Capture Events

Trigger Action Flows can also process Change Data Capture events with two minor modifications:

### Adjust the Flow Variables

| Variable Name | Variable Type                          | Available for Input | Available for Output | Description                                                                                                                                                                               |
| ------------- | -------------------------------------- | ------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `record`      | record                                 | yes                 | no                   | the changeEvent object                                                                                                                                                                    |
| `header`      | `FlowChangeEventHeader` (Apex Defined) | yes                 | no                   | a flow-accessible version of the [`ChangeEventHeader` object](https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_event_fields_header.htm) |

### Adjust the Trigger_Action\_\_mdt Record

Create a trigger action record with `Apex_Class_Name__c` equal to `TriggerActionFlowChangeEvent` (instead of `TriggerActionFlow`) and set `Flow_Name__c` to the flow's API name.

---

## Comparison with Record Triggered Flows

Salesforce provides a native way to run a Flow from a trigger context: native **Record Triggered Flows**. There are differences between the native offering and this framework's **Trigger Action Flows**. Understanding the trade-offs helps you pick the right tool.

### Performance

The table below shows elapsed time (ms) for 200 Account record updates across three scenarios:

| Scenario              | Run 1 | Run 2 | Run 3 | Run 4 |  Average |
| --------------------- | ----: | ----: | ----: | ----: | -------: |
| No automation         |  1581 |  1359 |  1223 |  1919 | **1472** |
| Record Triggered Flow |  1404 |  1471 |  1407 |  2028 | **1580** |
| Trigger Action Flow   |  1694 |  1455 |  2162 |  1626 | **1740** |

Trigger Action Flows carry a small overhead, but remain fully viable for production automations.

### Feature Comparison

| Feature                                               | Record Triggered Flow | Trigger Action Flow |
| ----------------------------------------------------- | :-------------------: | :-----------------: |
| Entry criteria / conditional execution                |          ✅           |         ✅          |
| Custom error messages on records                      |          ✅           |         ✅          |
| Granular ordering with Apex automations               |          ❌           |         ✅          |
| Bypass mechanisms (global, transactional, user-based) |          ❌           |         ✅          |
| After Delete context                                  |          ❌           |         ✅          |
| After Undelete context                                |          ❌           |         ✅          |
| Time-based scheduled actions                          |          ✅           |         ❌          |
| Workflow outbound messaging                           |          ✅           |         ❌          |

**Use a Record Triggered Flow** when you need time-based scheduling, outbound messaging, or a standalone automation with no ordering dependencies.

**Use a Trigger Action Flow** when you need precise ordering relative to Apex, bypass control, or coverage of the full set of trigger contexts.

---

## See Also

- [Apex Actions](apex-actions.md)
- [Entry Criteria Formula](entry-criteria.md)
- [Bypass Mechanisms](bypass-mechanisms.md)
- [API Reference - TriggerActionFlow](trigger-actions-framework/TriggerActionFlow.md)
- [API Reference - TriggerActionFlowChangeEvent](trigger-actions-framework/TriggerActionFlowChangeEvent.md)
