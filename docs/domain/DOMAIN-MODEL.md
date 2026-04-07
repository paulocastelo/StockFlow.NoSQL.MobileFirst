# Domain Model

This document defines the domain model for `StockFlow.NoSQL.MobileFirst`.

## Business Context

`StockFlow.NoSQL.MobileFirst` solves the same inventory problem as `StockFlow.Core` but from a different angle. The system is designed around mobile-first usage patterns and a document-based data model, where operators in the field look up products, check balances, and register movements from their devices without relying on a full relational structure.

## Modeling Philosophy

In `StockFlow.Core`, entities are normalized into separate relational tables. Here, documents are designed around the queries the mobile app actually performs. A product document, for example, can embed its current balance and recent movements directly — reducing round trips and making the mobile experience faster.

## Core Documents

### Product

The central document of the system. Groups all inventory-related data for a single item.

Key fields:

- `id`
- `name`
- `sku`
- `categoryName`
- `unitPrice`
- `isActive`
- `currentBalance` — derived field kept in sync on each movement
- `location` — warehouse zone or physical location (replaces relational category/location tables)

### StockMovement

Represents a stock change event. Can be embedded inside the product document (recent movements) or stored in a separate collection for historical queries.

Key fields:

- `id`
- `productId`
- `type` — Entry (1) or Exit (2)
- `quantity`
- `reason`
- `performedByUserId`
- `occurredAtUtc`

### AppUser

Represents a system user who can authenticate and perform operations.

Key fields:

- `id`
- `fullName`
- `email`
- `passwordHash`
- `isActive`

## Domain Rules

- product name and SKU are required
- SKU must be unique
- stock movement quantity must be greater than zero
- exit cannot reduce balance below zero
- entry adds quantity to currentBalance
- exit subtracts quantity from currentBalance
- currentBalance is updated atomically on each movement registration

## Key Difference From StockFlow.Core

| Aspect | StockFlow.Core | StockFlow.NoSQL.MobileFirst |
|--------|---------------|----------------------------|
| Database | PostgreSQL (relational) | MongoDB (document) |
| Balance | calculated at query time via SUM | stored in the product document |
| Categories | separate normalized table | embedded as `categoryName` string |
| Movement history | separate table, joined at query time | separate collection, indexed by productId |
| API design | CRUD-oriented | mobile-flow-oriented |

## Initial Use Cases

- authenticate user
- list products with current balance
- look up a single product with balance
- register stock entry
- register stock exit
- list movement history by product

## Modeling Decision

Current balance is stored directly in the product document and updated atomically on each movement. This trades write complexity for read performance — a deliberate choice for mobile-first usage where reads are much more frequent than writes.
