# StockFlow NoSQL MobileFirst Execution Plan

This document defines the execution plan for `StockFlow.NoSQL.MobileFirst`.

## Objective

Build the second portfolio project as a mobile-first inventory system that demonstrates technical versatility by solving the same business domain as `StockFlow.Core` with a fundamentally different stack and data modeling strategy.

## Product Goal

`StockFlow.NoSQL.MobileFirst` should demonstrate:

- document-based data modeling with MongoDB
- API design driven by mobile consumption patterns
- architectural trade-off awareness (relational vs. document)
- Flutter mobile app as the primary client
- ability to reason about when NoSQL is and is not appropriate

## Stack

- Back-end: Spring Boot 3 (Java 21)
- Database: MongoDB
- Mobile: Flutter 3
- Auth: JWT
- API Docs: Springdoc OpenAPI (Swagger UI)
- Tests: JUnit 5 + Mockito

## Execution Principles

- design documents around queries, not normalization
- keep the API surface minimal and mobile-oriented
- document every architectural decision and its rationale
- treat the comparison with `StockFlow.Core` as a first-class deliverable
- do not reproduce all features of `StockFlow.Core` — reproduce only what is needed to make the architectural contrast meaningful

## Implementation Phases

### Phase 1. Domain and Solution Foundation

Goal: define the document model and project structure before any implementation.

Status: in progress

Deliverables:

- domain model documentation
- MongoDB document design rationale
- backend project structure (Spring Boot)
- folder conventions
- planning documentation

Exit criteria:

- document schema is defined
- main collections are named and documented
- execution order is clear

### Phase 2. Backend MVP

Goal: create a functional Spring Boot API backed by MongoDB.

Deliverables:

- Spring Boot project with layered structure
- MongoDB connection and configuration
- `Product` document with embedded `currentBalance`
- `StockMovement` collection
- `AppUser` collection
- endpoints: list products, get product by id, register movement, get movement history, get balance
- atomic balance update on movement registration
- JWT authentication (register, login, protected endpoints)
- Swagger UI with Bearer token support
- seed data for local development

Exit criteria:

- API runs locally
- MongoDB schema matches the domain model
- primary inventory use cases are functional via Swagger

### Phase 3. Testing and API Documentation

Goal: improve confidence and usability of the backend.

Deliverables:

- unit tests for balance update rules
- unit tests for stock exit validation
- Swagger documentation complete
- HTTP request samples

Exit criteria:

- critical business rules have automated coverage
- API surface is explorable locally

### Phase 4. Flutter Mobile App

Goal: provide a mobile app that consumes the Spring Boot API.

Deliverables:

- Flutter project in `mobile/`
- login screen
- product list screen with current balance
- product detail screen
- new movement screen (entry and exit)
- movement history screen

Exit criteria:

- mobile app covers all MVP use cases
- app communicates correctly with the backend

### Phase 5. Polish and Public Release Preparation

Goal: make the repository presentation-ready.

Deliverables:

- final README with architecture diagram
- comparison section (NoSQL vs relational)
- screenshots
- local setup guide
- GitHub Actions CI pipeline

Exit criteria:

- repository communicates the architectural contrast clearly
- project can be built and explored by another developer

## Milestones

### Milestone 1
Domain definition and project structure completed.

### Milestone 2
Backend MVP completed with MongoDB and JWT auth.

### Milestone 3
Tests and API documentation completed.

### Milestone 4
Flutter mobile MVP completed.

### Milestone 5
Repository polished for public presentation.

## Next Action

Implement the Spring Boot backend project structure and MongoDB connection as the first step of Phase 2.
