# StockFlow NoSQL MobileFirst MVP Scope

This document defines what should be included in the first usable version of `StockFlow.NoSQL.MobileFirst`.

## In Scope

- user login
- product listing with current balance
- single product lookup
- stock entry registration
- stock exit registration
- movement history by product
- API documentation
- basic unit tests

## Current Status

Nothing implemented yet. Phase 1 (domain definition and planning) is in progress.

## Out Of Scope For The First Version

- product and category CRUD (managed externally or via seed data)
- web frontend (mobile-first — the Flutter app is the primary client)
- multi-location stock tracking
- advanced reporting
- offline sync
- push notifications
- barcode or QR integration
- role-based access control beyond simple authentication

## MVP Success Criteria

The MVP is successful when:

- a user can authenticate
- the mobile app can list all products with their current balance
- a stock entry can be registered from the app
- a stock exit can be registered from the app with balance validation
- movement history is visible per product
- the API can be run and understood locally

## Guiding Rule

If a feature does not serve the mobile operator's core flow — look up a product, check its balance, register a movement — it should be postponed.

## Comparison Note

This MVP deliberately covers less surface than `StockFlow.Core`. The goal is not to reproduce all features but to demonstrate that the same business domain can be solved with a different architectural approach and that the trade-offs are understood and documented.
