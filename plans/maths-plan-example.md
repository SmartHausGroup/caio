# MATHS Plan Example (Real AI App)

This example shows a realistic plan for a customer support AI assistant used by an ecommerce team.

---

## Plan Metadata

- Plan ID: PLAN-APP-SUPPORT-SAFE-ANSWER-001
- Title: Add safe-answer mode for low-confidence support responses
- Domain: app + framework
- Owner: product engineering + MA maintainer
- Status: active
- Last Updated: 2026-02-19
- Release Type: minor behavior hardening
- Target Environment: staging -> production gradual rollout

### User Story

As a customer asking support questions, I want accurate policy guidance or a clear escalation path, so I am never misled by an overconfident AI answer.

### Current vs Target

- Current:
  - assistant answers most questions directly
  - low-confidence scenarios can still produce authoritative-sounding answers
- Target:
  - low-confidence scenarios route to safe fallback + escalation
  - safety + helpfulness metrics are measured and gated

---

## M — Model

### Problem
Our support assistant answers shipping/returns questions, but sometimes gives confident policy statements when retrieval evidence is weak. That can create customer trust and liability issues.

### Stakeholders
- Customers using support chat
- Support operations team
- Product engineering team
- Compliance/risk reviewers

### Success Criteria
- When confidence is low, assistant uses safe fallback + escalation instead of inventing policy facts.
- Hallucination-like false-confidence rate drops below agreed threshold.
- Helpful-answer rate does not regress beyond accepted limit.
- New behavior is replayable/deterministic in verification runs.

### Numeric SLOs for this plan

- `false_confident_answers <= 1.0%`
- `helpful_answer_rate >= 85.0%`
- `p95_latency_ms <= 2000`
- `deterministic_replay_pass == true`

### Constraints
- Keep median latency within SLA.
- No PII leakage in artifacts/logging.
- Maintain current UI flow; no major frontend redesign.
- Preserve existing gate requirements.

### Non-goals
- Full retrieval architecture rewrite
- Multi-language expansion
- New support channel rollout (voice, email, etc.)

---

## A — Annotate

### Product behavior contract
- High confidence -> direct answer with grounded evidence.
- Low confidence -> safe fallback wording + escalation option.
- No unsupported policy claim may be presented as fact.

### Input/Output schema contract

Input required fields:

- `message: string`
- `customer_id: string`
- `intent: enum(order_status|returns|cancellations)`
- `retrieval.confidence: float(0..1)`
- `retrieval.snippets: array`

Output required fields:

- `answer_text: string`
- `decision_mode: enum(answer|fallback|escalate)`
- `confidence_score: float(0..1)`
- `escalation_offered: boolean`
- `policy_claim_level: enum(authoritative|non_authoritative)`

### Dependencies
- App response pipeline (confidence score + response assembly)
- Retrieval layer output format
- Framework verification harness for behavior metrics
- Invariant contracts for safe-answer behavior

### Invariants/lemmas impacted
- Existing safety/quality invariants
- Potential new invariant: low confidence must not produce authoritative policy claim

### Required artifacts
- `framework/configs/generated/support_safe_answer_metrics.json`
  - `false_confident_answers`
  - `fallback_rate`
  - `helpful_answer_rate`
  - `deterministic_replay_pass`
  - `p95_latency_ms`

### Requirement mapping table

| Requirement | Invariant ID | Artifact Field | Rule |
|---|---|---|---|
| Low confidence cannot make authoritative claim | `INV-APP-SAFE-001` | `false_confident_answers` | `<= 1.0%` |
| Must remain useful | `INV-APP-SAFE-002` | `helpful_answer_rate` | `>= 85.0%` |
| Must be deterministic | `INV-APP-SAFE-003` | `deterministic_replay_pass` | `== true` |
| Must meet latency SLA | `INV-APP-SAFE-004` | `p95_latency_ms` | `<= 2000` |

---

## T — Tie

### Readiness Checklist
- [x] confidence score available in app response flow
- [x] response metadata can be captured for verification
- [x] support-approved fallback copy exists (or owner assigned)
- [x] gate path for new artifact identified

### Main Risks and Mitigations
1. **False-confidence answers still leak**
   - Mitigation: add explicit low-confidence adversarial test set.
2. **Assistant becomes too conservative**
   - Mitigation: track helpful-answer rate and set lower bound.
3. **Artifact contract mismatch**
   - Mitigation: lock JSON field names and add contract assertions.
4. **Operational confusion**
   - Mitigation: define escalation response format and handoff procedure.

### Go/No-Go
- **Go** if we can improve safety without unacceptable helpfulness regression.
- **No-Go** if passing requires hiding failures or bypassing deterministic checks.

### Decision policy matrix

| Condition | Mode | Escalation | Notes |
|---|---|---|---|
| confidence >= 0.80 and evidence consistent | answer | no | normal response |
| 0.60 <= confidence < 0.80 | answer-cautious | yes | include uncertainty phrasing |
| confidence < 0.60 | fallback | yes | no authoritative policy claim |
| evidence contradiction detected | fallback | yes | prefer safety |
| retrieval unavailable | escalate | yes | fail-safe mode |

---

## H — Harness

### Phase 1: App behavior implementation
- Add decision branch in response layer:
  - if confidence >= threshold -> normal grounded response
  - if confidence < threshold -> fallback + escalation
- Add response metadata fields required by verification.

### Phase 2: Verification harness and artifacts
- Build/extend notebook or test harness dataset:
  - answerable known-good support queries
  - ambiguous or missing-evidence queries
  - policy-sensitive edge cases
- Generate safety metrics artifact at stable path.

### Phase 3: Framework contract alignment
- Add or update invariant definitions for safe-answer expectations.
- Wire artifact fields to acceptance checks.

### Phase 4: Gate integration and docs
- Ensure quality-gate path reads the new metrics artifact.
- Document fallback/escalation behavior in operations docs.

### Exact command runbook

```bash
make dev-verify
make notebooks-plan
make notebooks-run
make quality-gate
make ma-validate-quiet
```

Expected:

- artifact exists at expected path
- no new critical gate failures
- replay/determinism passes

### Expected files touched
- app support response handler(s)
- framework verification notebook/harness files
- `framework/invariants/*.yaml` (if new safety invariant added)
- `framework/configs/generated/support_safe_answer_metrics.json` output producer

### Files that should NOT change

- auth/session modules
- payment/billing modules
- unrelated support intents

### Notebook-first extraction note
For MA-governed behavior, verification logic and acceptance criteria are defined in framework artifacts first, then reflected in app runtime behavior.

---

## S — Stress-test

### Functional Test Plan
- High-confidence prompts get direct, grounded answers.
- Low-confidence prompts get safe fallback + escalation option.
- Escalation path is always present when fallback is used.

### Edge-case Test Plan
- Missing/empty retrieval evidence
- Contradictory snippets in retrieval context
- Prompt-injection style user prompts
- Ambiguous policy wording

### Determinism/Replay Plan
- Fixed-seed test runs over same dataset produce stable decision-mode outcomes.
- Artifact metric values stable within deterministic tolerance.

### Gate Criteria
- `false_confident_answers` <= threshold
- `helpful_answer_rate` >= threshold
- `deterministic_replay_pass` == true

### Dataset specification

- Total size: 300 prompts
- Intent split:
  - order_status: 120
  - returns: 100
  - cancellations: 80
- Adversarial subset: 60 prompts
- Required labels:
  - `expected_decision_mode`
  - `expected_policy_claim_level`
  - `expected_escalation_offered`

---

## Optional — Assure

- Add stricter red-team set for policy-sensitive intents.
- Add unit tests around decision branching and response contract.
- Add explicit PII-safe logging checks.

---

## Optional — Observe

- Monitor in production:
  - fallback rate by intent
  - escalation acceptance rate
  - complaint rate after fallback
- Alerts:
  - false-confidence spikes
  - fallback rate anomaly
- Incident response:
  - tighten threshold temporarily
  - rollback to previous response policy if regressions persist

### Alert thresholds

- false-confidence > 1.5% over 30 minutes
- fallback rate +20% above weekly baseline
- p95 latency > 2500 ms for 15 minutes

---

## Decision Log

- 2026-02-19: prioritize safety over maximal answer coverage.
  Reason: incorrect policy answers create higher risk than escalation.

- 2026-02-19: enforce deterministic verification before promotion.
  Reason: behavior changes must be auditable and reproducible.

---

## Exit Criteria

- [ ] low-confidence fallback behavior implemented in app
- [ ] metrics artifact generated and contract-validated
- [ ] invariant acceptance checks pass
- [ ] no unacceptable helpfulness regression
- [ ] operations escalation flow documented

## Failure Playbook

### FP-1 False-confidence spike
- Symptom: `false_confident_answers` breaches threshold
- First checks:
  - confidence passed correctly to decision branch
  - contradiction detection path active
  - fallback branch not bypassed
- Immediate action:
  - enable strict fallback mode
  - open incident and block promotion

### FP-2 Helpfulness collapse
- Symptom: fallback overuse, low helpful-answer rate
- First checks:
  - intent-level distribution skew
  - retrieval evidence quality drop
  - threshold too strict
- Immediate action:
  - rollback threshold profile
  - investigate retrieval quality

### FP-3 Determinism fail
- Symptom: replay check false
- First checks:
  - seed wiring
  - unstable dependency in verification path
  - environment fingerprint mismatch
- Immediate action:
  - block release
  - isolate randomness and rerun

## Ownership (RACI)

| Area | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| App decision branch | Product engineer | App lead | MA maintainer | Support ops |
| Invariant updates | MA maintainer | Math lead | App lead | QA |
| Gate integration | Gates owner | MA maintainer | Product engineer | Team |
| Escalation UX | Support ops | Support lead | Product | Eng |
| Incident response | On-call engineer | Eng manager | MA maintainer | Stakeholders |

## Common Mistakes

1. Lowering thresholds to hide failures.
2. Adding fallback without escalation.
3. Tracking safety without helpfulness.
4. Ignoring adversarial test set.
5. Drifting artifact schema without gate updates.

---

## Crosswalk (Legacy Naming)

- Model = Architect
- Annotate = Trace
- Tie = Link
- Harness = Assemble
- Stress-test = Stress-test
- Assure = Validate
- Observe = Monitor
