# Plan: CAIO Repo — M365 Service Registration and Adapter

**Plan ID:** `caio-repo-plan` (parent: `tai-maia-caio-vfe-m365-integration`)
**Status:** Draft (Pending Approval)
**Date:** 2026-02-06
**Owner:** SmartHaus
**Master plan:** M365 repo `plans/tai-maia-caio-vfe-m365-integration/master-plan.md`
**Execution plan reference:** `plan:tai-maia-caio-vfe-m365-integration:caio`
**North Star alignment:** CAIO docs (orchestration, gateway, service registry).

**MA process:** This plan is **adapter and routing work** (no new mathematical operations or algorithms). MA process is **not required** unless a later task is deemed mathematical/algorithmic (e.g. new scoring or routing logic with formal guarantees). If such work is added, follow `.cursor/rules/ma-process-mandatory.mdc` and `.cursor/rules/notebook-first-mandatory.mdc`.

---

## Objective

Register **M365** as a service in CAIO and implement an **M365 adapter** that (1) receives orchestration requests containing MAIA intent (domain=M365, action, params), (2) translates them into calls to the M365 Provisioning/instruction API, (3) returns the result to the caller (TAI). CAIO routes “M365” intents to this adapter; no change to SAID or other services.

---

## Scope (CAIO repo only)

- **In scope:** M365 service registration in CAIO; M365 adapter module (client to M365 API); routing by intent (domain/action) to M365; request/response mapping; auth (e.g. token pass-through or CAIO-managed credential); tests and docs.
- **Out of scope:** M365 API implementation; TAI voice; MAIA intent logic; SAID changes; implementation of MAIA or TAI.

---

## Prerequisites

- M365 instruction/command API contract defined and available (see M365 repo plan).
- Agreed intent shape from MAIA (domain, action, params) for M365.
- Master plan approved.

---

## Requirements

### Functional

- [ ] M365 registered as a CAIO service (discoverable, routable).
- [ ] M365 adapter: accept orchestration request with intent (domain=M365, action, params); map to M365 API call; return structured result (or error).
- [ ] Routing: when intent indicates domain M365, route to M365 adapter (not SAID or other backends).
- [ ] Auth: support calling M365 API with appropriate credentials (pass-through from caller or CAIO-managed; per M365 contract).
- [ ] Errors: map M365 API errors to CAIO response; propagate to TAI.

### Non-functional

- [ ] Adapter is testable (unit and/or integration with mock or staging M365).
- [ ] Config for M365 API base URL and auth; no hardcoded secrets.
- [ ] Docs: adapter contract, routing rule, and link to master plan.

---

## Detailed tasks

1. **Service registration** — Register M365 in CAIO service registry (config or code); expose as routable target for intent domain M365.
2. **M365 adapter module** — Implement adapter that: (a) receives orchestrate payload with intent, (b) maps action + params to M365 API request (per M365 contract), (c) performs HTTP call to M365, (d) maps response to CAIO result shape.
3. **Routing** — Ensure orchestration layer routes requests with intent.domain = M365 (and optionally action) to M365 adapter.
4. **Auth** — Implement auth for M365 API calls (token or credential per M365 contract); document in adapter docs.
5. **Error handling** — Map HTTP and M365 error responses to CAIO error format; ensure TAI can receive clear success/failure.
6. **Tests** — Unit tests for adapter (mapping, routing); integration test with mock or staging M365 if available.
7. **Docs** — Document M365 service, adapter contract, routing, and reference to master plan and M365 API contract.

---

## Validation procedures

- Run CAIO test suite; all pass.
- Adapter unit tests pass; integration test (if added) passes against mock/staging M365.
- Manual or automated: send orchestrate request with M365 intent; verify routing to adapter and correct M365 API call (and result).

---

## Success criteria

- [ ] M365 is a registered service in CAIO; orchestration requests with M365 intent reach the M365 adapter.
- [ ] Adapter correctly calls M365 API and returns result to caller.
- [ ] Plan checklist and tests pass.

---

## Dependencies

- M365 instruction API contract (from M365 repo plan).
- MAIA intent schema for M365 (domain, action, params) agreed.
- Master plan approved.

---

## Status updates

- Update this plan with task checkboxes and status.
- Log completion in CAIO action log with plan reference `plan:tai-maia-caio-vfe-m365-integration:caio`.
