# Plan: Phase 19.10 — Live Gateway Verification (Non-Inference Adapters)

**Plan ID:** `phase-19-10-live-gateway-verification`
**Status:** In Progress
**Date:** 2026-01-18
**Owner:** @smarthaus
**Execution Plan Reference:** `plan:EXECUTION_PLAN:19.10`
**North Star Alignment:** `docs/NORTH_STAR.md` — §1.3 Service Orchestration Architecture (Marketplace Agents), INV-CAIO-0002 Correctness.

---

## Objective

Verify that CAIO's Universal Service Gateway can successfully route, execute, and verify requests to **non-inference** external services using real API keys. This proves the gateway architecture works end-to-end for the marketplace ecosystem.

**Scope Note:**
Per ADR-0001, core LLM inference (OpenAI, Anthropic, etc.) is handled by **VFE**. CAIO Gateway handles **tools/marketplace adapters** (Search, Memory, Voice, Image, etc.). This phase *only* tests those non-inference adapters.

---

## Scope

### 19.10.1 Live Verification Test Suite
- **Target:** `tests/integration/test_live_gateway_verification.py`
- **Adapters to Verify:**
  - **Search:** `tavily` (primary), `serper`
  - **Embeddings:** `openai_embeddings`, `cohere_embed`
  - **Voice:** `elevenlabs`, `deepgram`
  - **Image:** `dall-e-3` (via OpenAI adapter logic)
  - **Code:** `github_copilot` (if feasible), `cursor` (if feasible)
- **Mechanism:**
  - Tests check for env var `LIVE_TESTS_ENABLED=1`.
  - Tests check for specific API keys (e.g., `TAVILY_API_KEY`, `OPENAI_API_KEY`).
  - If keys present -> Make REAL HTTP request -> Verify REAL response -> Check Guarantees.
  - If keys missing -> Skip test (do not fail).

### 19.10.2 Guarantee Enforcement Validation
- **Objective:** Verify `GuaranteeEnforcer` correctly parses real metadata from live responses.
- **Check:**
  - Latency tracking (did we get a real duration?).
  - Cost tracking (did we capture tokens/price?).
  - Schema validation (did the response match the contract?).

### 19.10.3 Documentation & Artifacts
- **Output:** `docs/gateway/ADAPTER_VERIFICATION.md`.
- **Content:** Table of verified adapters, date verified, and any known limitations.

---

## Requirements

### Prerequisites
- Phase 19.1 (Gateway Core) complete.
- Phase 19.4 (Tier 3 Adapters) code complete.
- Real API keys for at least **one** provider (recommend: `TAVILY_API_KEY` or `OPENAI_API_KEY` for embeddings).

### Dependencies
- `caio/gateway/executor.py` must be stable.
- `configs/services/external/*.yaml` must be valid.

### Success Criteria
- [ ] `tests/integration/test_live_gateway_verification.py` exists and is runnable.
- [ ] At least **one** live test passes with a real API call (proving the network path).
- [ ] Guarantee enforcement log shows real metrics from that call.
- [ ] Documentation updated to reflect "Live Verified" status.

---

## Execution Steps

1.  **Create Test Suite:** Write `tests/integration/test_live_gateway_verification.py`.
2.  **Implement Adapters:** Ensure `tavily`, `openai_embeddings`, etc., are fully implemented in `caio/gateway/adapters/`.
3.  **Run Verification:** Execute `pytest tests/integration/test_live_gateway_verification.py`.
4.  **Document Results:** Update `docs/gateway/ADAPTER_VERIFICATION.md`.

---

## Risks and Mitigation

| Risk | Mitigation |
|------|------------|
| Cost of live tests | Tests run only on manual trigger (`LIVE_TESTS_ENABLED=1`); strictly limited scope. |
| API Key exposure | Keys read from env vars ONLY; never committed; tests skip if missing. |
| Network flakes | Retries implemented in Gateway Core (Phase 19.1). |

---

## References
- **Execution Plan:** `docs/operations/execution_plan.md`
- **Gateway Docs:** `docs/gateway/README.md`
