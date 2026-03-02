# Trigger Actions Framework

[![Install (Production)](https://img.shields.io/badge/Install-Production-blue)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tKY000000R0yHYAS)
[![Install (Sandbox)](https://img.shields.io/badge/Install-Sandbox-lightblue)](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tKY000000R0yHYAS)

The **Trigger Actions Framework** allows developers and administrators to partition, order, and bypass record-triggered automations for applications built on Salesforce.com.

The framework supports both **Apex and Flow** - empowering developers and administrators to define automations in the tool of their choice, then plug them together harmoniously.

With granular control of the relative order of execution of Apex vs. Flow and standardized bypass mechanisms, the framework enables an "Automation Studio" view of _all_ automations for a given SObject.

---

## Metadata Driven Trigger Actions

With the Trigger Actions Framework, [custom metadata](https://help.salesforce.com/s/articleView?id=sf.custommetadatatypes_overview.htm&type=5) drives all trigger logic from the setup menu. The custom metadata defines:

- The SObject and context for which an action is supposed to execute
- The order to take those actions within a given context
- Mechanisms to determine if and when the action should be [bypassed](bypass-mechanisms.md)

The related lists on the `SObject_Trigger_Setting__mdt` record provide a consolidated and ordered view of _all_ of the Apex and Flow actions that will be executed when a record is inserted, updated, deleted, or undeleted:

![Automation Studio](images/automationStudio.png)

---

## Key Principles

The framework conforms strongly to:

- **[Open–closed principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)** - add or modify trigger logic without modifying an existing TriggerHandler class body
- **[Single-responsibility principle](https://en.wikipedia.org/wiki/Single-responsibility_principle)** - each action class has a focused, well-scoped responsibility

The work is performed in the `MetadataTriggerHandler` class which implements the [Strategy Pattern](https://en.wikipedia.org/wiki/Strategy_pattern) by fetching all Trigger Action metadata configured in the org for the given trigger context. It uses [reflection](https://en.wikipedia.org/wiki/Reflective_programming) to dynamically instantiate an object that implements a `TriggerAction` interface, then casts the object to the appropriate interface as specified in the metadata and calls the respective context methods in the order specified.

---

## Features at a Glance

| Feature                                             | Description                                              |
| --------------------------------------------------- | -------------------------------------------------------- |
| [Apex Actions](apex-actions.md)                     | Write focused Apex classes for each automation           |
| [Flow Actions](flow-actions.md)                     | Invoke auto-launched Flows with trigger context          |
| [Entry Criteria Formula](entry-criteria.md)         | Dynamic per-record entry conditions via formula          |
| [Bypass Mechanisms](bypass-mechanisms.md)           | Global, transactional, and user-level bypasses           |
| [Recursion Prevention](recursion-prevention.md)     | Built-in counters to guard against recursive DML         |
| [Avoid Repeated Queries](avoid-repeated-queries.md) | Singleton pattern for shared query results               |
| [DML-Less Testing](dml-less-testing.md)             | Fast unit tests with no DML overhead                     |
| [DML Finalizers](dml-finalizers.md)                 | Execute logic exactly once at the end of a DML operation |

---

## Quick Links

- [Getting Started](getting-started.md) - enable the framework on your first SObject
- [API Reference](index.md) - full class and metadata reference
- [Contributing](contributing.md) - how to contribute to the project
