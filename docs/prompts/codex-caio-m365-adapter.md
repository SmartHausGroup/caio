# Codex Detailed Prompt: CAIO M365 Service Registration and Adapter

**Plan reference:** `plan:tai-maia-caio-vfe-m365-integration:caio`  
**Detailed plan:** `plans/tai-maia-caio-vfe-m365-integration/caio-repo-plan.md`  
**Master plan:** M365 repo `plans/tai-maia-caio-vfe-m365-integration/master-plan.md`

---

## Executive summary

Register **M365** as a service in CAIO and implement the **M365 adapter**: receive orchestration requests with MAIA intent (domain=M365, action, params), translate to M365 Provisioning/instruction API calls, return result to caller (TAI). Route M365 intents to this adapter; no change to VFE or other services. MA process not required for this adapter/routing work.

---

## Context and background

- **Flow:** TAI sends intent to CAIO → CAIO routes M365 intents to M365 adapter → adapter calls M365 API → result back to TAI.
- **CAIO role:** Service registry; M365 adapter as client to M365 API; routing by intent.domain = M365.
- **Governance:** Plan-first; change approval before implementation. No implementation without explicit "go."

---

## Current state

- CAIO has orchestration, gateway, and service registry. M365 instruction API contract is defined in M365 repo plan.

---

## Target state

- M365 registered in CAIO service registry (routable for domain M365).
- M365 adapter: accept orchestrate payload with intent; map action+params to M365 API request; perform HTTP call; map response to CAIO result shape.
- Routing: intent.domain = M365 → M365 adapter.
- Auth for M365 API calls (per M365 contract); error mapping (M365 errors → CAIO response).
- Config for M365 API base URL and auth; no hardcoded secrets.
- Tests: unit for adapter and routing; optional integration with mock/staging M365.
- Docs: adapter contract, routing, link to master plan.

---

## Step-by-step implementation (from caio-repo-plan)

1. **Service registration** — Register M365 in CAIO service registry; expose as routable target for intent domain M365.
2. **M365 adapter module** — Implement adapter: receive orchestrate payload with intent; map to M365 API request (per M365 contract); HTTP call to M365; map response to CAIO result.
3. **Routing** — Ensure orchestration layer routes intent.domain = M365 to M365 adapter.
4. **Auth** — Implement auth for M365 API calls (token or credential per M365 contract); document.
5. **Error handling** — Map HTTP and M365 errors to CAIO error format for TAI.
6. **Tests** — Unit tests for adapter mapping and routing; integration test with mock/staging M365 if available.
7. **Docs** — Document M365 service, adapter contract, routing; reference master plan and M365 API contract.

---

## Validation

- CAIO test suite passes.
- Adapter unit tests pass; integration test (if added) passes.
- Send orchestrate request with M365 intent; verify routing to adapter and correct M365 API call and result.

---

## Success criteria (from plan)

- [ ] M365 is a registered service; M365 intents reach the M365 adapter.
- [ ] Adapter correctly calls M365 API and returns result to caller.
- [ ] Plan checklist and tests pass.

---

## References

- `plans/tai-maia-caio-vfe-m365-integration/caio-repo-plan.md`
- M365 instruction API contract (M365 repo plan)
- `.cursor/rules/plan-first-execution.mdc`, `.cursor/rules/rsf-change-approval.mdc`
