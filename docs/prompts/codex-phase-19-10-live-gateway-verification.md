# Codex Prompt: Phase 19.10 - Live Gateway Verification (Non-Inference Adapters Only)

**Plan Reference:** `plan:EXECUTION_PLAN:19.10`  
**Detailed Plan:** `plans/phase-19-10-live-gateway-verification/phase-19-10-live-gateway-verification.md`  
**North Star Alignment:** Aligned with CAIO orchestration role (ADR-0001) — CAIO orchestrates, VFE executes inference  
**Status:** Approved for execution

---

## Executive Summary

Create a live verification test suite for CAIO's **non-inference marketplace adapters only**. Per ADR-0001, inference adapters are in VFE, so this phase only verifies embeddings, code, search, voice, and image adapters.

**Scope:** 12 non-inference adapters (embeddings: 3, code: 2, search: 2, voice: 2, image: 3)

**Success:** Test suite created with safety gates, at least 8 adapters verified with live API calls (where API keys available), documentation updated.

---

## Context

### Architecture (ADR-0001)

**CAIO's Role:** Universal AI Controller (orchestrates services)  
**VFE's Role:** Unified Inference Engine (executes ALL inference)

**Current State:**
- Tier 1 adapters (OpenAI, Anthropic, Groq, Mistral, Cohere) — **MIGRATED TO VFE** ✅
- Tier 2/3 inference adapters (Gemini, Grok, Ollama, etc.) — **SHOULD BE IN VFE** (out of scope)
- Tier 3 non-inference adapters — **Correctly in CAIO** (this phase's scope)

### Problem

Enterprise customers need confidence that CAIO's marketplace adapters work with real services. Currently:
- Tests are mocked or skipped
- No live verification performed
- No documentation of verification status

---

## Implementation Instructions

### Step 1: Create Live Verification Test Suite

**File:** `tests/integration/test_live_gateway_verification.py`

**Requirements:**
1. Use `@pytest.mark.live` marker to isolate live tests
2. Require `LIVE_TESTS_ENABLED=1` environment variable to run
3. Skip tests if API keys are missing (with clear messages)
4. Test each adapter with minimal API calls (cost-conscious)
5. Group tests by adapter type (embeddings, code, search, voice, image)

**Template:**
```python
"""Live verification tests for CAIO non-inference marketplace adapters.

Per ADR-0001, inference adapters are in VFE. This test suite only verifies
non-inference adapters (embeddings, code, search, voice, image).

Usage:
    LIVE_TESTS_ENABLED=1 pytest tests/integration/test_live_gateway_verification.py -v -m live
"""

import pytest
import os
from caio.gateway.executor import GatewayExecutor
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request

# Safety gate: Only run if explicitly enabled
pytestmark = pytest.mark.skipif(
    os.getenv("LIVE_TESTS_ENABLED") != "1",
    reason="Live tests require LIVE_TESTS_ENABLED=1 environment variable"
)

@pytest.mark.live
class TestLiveEmbeddingsAdapters:
    """Live verification for embeddings adapters."""
    
    @pytest.fixture
    def executor(self):
        """Create gateway executor."""
        return GatewayExecutor()
    
    @pytest.mark.skipif(
        not os.getenv("OPENAI_API_KEY"),
        reason="OPENAI_API_KEY required for OpenAI Embeddings verification"
    )
    def test_openai_embeddings_live(self, executor):
        """Verify OpenAI Embeddings adapter with live API."""
        # Load contract
        contract_path = "configs/services/external/openai-embeddings.yaml"
        contract = ServiceContract.from_file(contract_path)
        
        # Create minimal request
        request = Request(
            prompt="test embedding",
            intent="embedding",
            user="test-user"
        )
        
        # Execute via gateway
        # ... implementation ...
        
        # Verify response structure
        assert "embedding" in response or "data" in response
    
    # ... similar for cohere-embed, voyage

@pytest.mark.live
class TestLiveCodeAdapters:
    """Live verification for code adapters."""
    # ... github-copilot, cursor

@pytest.mark.live
class TestLiveSearchAdapters:
    """Live verification for search adapters."""
    # ... tavily, serper

@pytest.mark.live
class TestLiveVoiceAdapters:
    """Live verification for voice adapters."""
    # ... elevenlabs, deepgram

@pytest.mark.live
class TestLiveImageAdapters:
    """Live verification for image adapters."""
    # ... dalle, stability, midjourney
```

### Step 2: Verify Each Adapter Type

**Embeddings (3 adapters):**
- `openai-embeddings` → Requires `OPENAI_API_KEY`
- `cohere-embed` → Requires `COHERE_API_KEY`
- `voyage` → Requires `VOYAGE_API_KEY`

**Code (2 adapters):**
- `github-copilot` → Requires `GITHUB_TOKEN` or `GITHUB_COPILOT_API_KEY`
- `cursor` → Requires `CURSOR_API_KEY`

**Search (2 adapters):**
- `tavily` → Requires `TAVILY_API_KEY`
- `serper` → Requires `SERPER_API_KEY`

**Voice (2 adapters):**
- `elevenlabs` → Requires `ELEVENLABS_API_KEY`
- `deepgram` → Requires `DEEPGRAM_API_KEY`

**Image (3 adapters):**
- `dalle` → Requires `OPENAI_API_KEY`
- `stability` → Requires `STABILITY_API_KEY`
- `midjourney` → Requires `MIDJOURNEY_API_KEY`

**Implementation Notes:**
- Load contract from `configs/services/external/{adapter-name}.yaml`
- Create minimal request (single embedding, short code completion, simple search query, short TTS text, simple image prompt)
- Execute via `GatewayExecutor`
- Verify response structure matches expected format
- Handle errors gracefully (rate limits, invalid keys, etc.)

### Step 3: Update Documentation

**File:** `docs/gateway/ADAPTER_VERIFICATION.md` (create if missing)

**Content:**
```markdown
# Adapter Verification Status

## Live Verification (Phase 19.10)

**Last Updated:** 2026-01-17

### Non-Inference Adapters (CAIO Scope)

#### Embeddings
- ✅ OpenAI Embeddings — Verified (requires `OPENAI_API_KEY`)
- ⚠️ Cohere Embed — Requires `COHERE_API_KEY` (not verified)
- ⚠️ Voyage AI — Requires `VOYAGE_API_KEY` (not verified)

#### Code
- ⚠️ GitHub Copilot — Requires `GITHUB_TOKEN` (not verified)
- ⚠️ Cursor — Requires `CURSOR_API_KEY` (not verified)

#### Search
- ⚠️ Tavily — Requires `TAVILY_API_KEY` (not verified)
- ⚠️ Serper — Requires `SERPER_API_KEY` (not verified)

#### Voice
- ⚠️ ElevenLabs — Requires `ELEVENLABS_API_KEY` (not verified)
- ⚠️ Deepgram — Requires `DEEPGRAM_API_KEY` (not verified)

#### Image
- ✅ DALL-E — Verified (requires `OPENAI_API_KEY`)
- ⚠️ Stability AI — Requires `STABILITY_API_KEY` (not verified)
- ⚠️ Midjourney — Requires `MIDJOURNEY_API_KEY` (not verified)

### Inference Adapters (VFE Scope)

Per ADR-0001, inference adapters are in VFE, not CAIO:
- Gemini, Grok, Ollama, LM Studio, Perplexity, Hugging Face, Together, Replicate, Azure OpenAI, AWS Bedrock, Meta AI, Google PaLM, Aleph Alpha

## Running Live Tests

```bash
# Enable live tests
export LIVE_TESTS_ENABLED=1

# Set API keys (example)
export OPENAI_API_KEY="sk-..."
export COHERE_API_KEY="..."

# Run live tests
pytest tests/integration/test_live_gateway_verification.py -v -m live
```

**Safety:** Tests only run when `LIVE_TESTS_ENABLED=1` is set.
```

**File:** `tests/integration/README.md` (create if missing)

**Content:**
```markdown
# Integration Tests

## Live Gateway Verification

Live verification tests for CAIO's non-inference marketplace adapters.

**Requirements:**
- `LIVE_TESTS_ENABLED=1` environment variable
- API keys for adapters you want to verify

**Usage:**
```bash
LIVE_TESTS_ENABLED=1 pytest tests/integration/test_live_gateway_verification.py -v -m live
```

**Safety Gates:**
- Tests skip if `LIVE_TESTS_ENABLED` is not set
- Tests skip if API keys are missing
- Minimal API calls to reduce costs
```

### Step 4: Verify Test Suite Works

**Validation:**
1. Run tests without `LIVE_TESTS_ENABLED` → Should skip
2. Run tests with `LIVE_TESTS_ENABLED=1` but no API keys → Should skip with clear messages
3. Run tests with `LIVE_TESTS_ENABLED=1` and API keys → Should execute and verify adapters

**Commands:**
```bash
# Test 1: Should skip (safety gate)
pytest tests/integration/test_live_gateway_verification.py -v -m live

# Test 2: Should skip (no API keys)
LIVE_TESTS_ENABLED=1 pytest tests/integration/test_live_gateway_verification.py -v -m live

# Test 3: Should execute (with API keys)
LIVE_TESTS_ENABLED=1 OPENAI_API_KEY="sk-..." pytest tests/integration/test_live_gateway_verification.py -v -m live -k "openai"
```

---

## Validation Plan

### Success Criteria

1. **Test Suite Created:**
   - ✅ `tests/integration/test_live_gateway_verification.py` exists
   - ✅ Uses `@pytest.mark.live` markers
   - ✅ Requires `LIVE_TESTS_ENABLED=1` to run
   - ✅ Tests skip gracefully when API keys missing

2. **Adapters Verified:**
   - ✅ At least 8 of 12 non-inference adapters verified (where API keys available)
   - ✅ Tests pass for verified adapters
   - ✅ Tests skip with clear messages for adapters without API keys

3. **Documentation Updated:**
   - ✅ `docs/gateway/ADAPTER_VERIFICATION.md` created/updated
   - ✅ `tests/integration/README.md` created/updated
   - ✅ Verification status documented

### Validation Commands

```bash
# Run linting
make lint-all

# Run unit tests (should pass)
make test

# Run live tests (requires API keys)
LIVE_TESTS_ENABLED=1 pytest tests/integration/test_live_gateway_verification.py -v -m live
```

---

## Important Notes

### What's IN Scope

**Non-inference adapters (12 total):**
- Embeddings: OpenAI Embeddings, Cohere Embed, Voyage AI
- Code: GitHub Copilot, Cursor
- Search: Tavily, Serper
- Voice: ElevenLabs, Deepgram
- Image: DALL-E, Stability AI, Midjourney

### What's OUT of Scope

**Inference adapters (should be in VFE):**
- Gemini, Grok, Ollama, LM Studio, Perplexity, Hugging Face, Together, Replicate, Azure OpenAI, AWS Bedrock, Meta AI, Google PaLM, Aleph Alpha

**Do NOT verify inference adapters in this phase.** They belong in VFE per ADR-0001.

### Safety First

- Tests only run when `LIVE_TESTS_ENABLED=1` is set
- Tests skip if API keys are missing
- Minimal API calls to reduce costs
- Clear error messages for missing keys

---

## References

- **Detailed Plan:** `plans/phase-19-10-live-gateway-verification/phase-19-10-live-gateway-verification.md`
- **ADR-0001:** `docs/adr/ADR-0001-unified-inference-architecture.md`
- **Execution Plan:** `docs/operations/EXECUTION_PLAN.md` (Phase 19.10)
- **North Star:** `docs/NORTH_STAR.md` (Section 1.3 - CAIO Orchestration Role)
- **Gateway Executor:** `caio/gateway/executor.py`
- **Contract Templates:** `configs/services/external/`

---

## Execution Instructions

1. Read the detailed plan: `plans/phase-19-10-live-gateway-verification/phase-19-10-live-gateway-verification.md`
2. Create the test suite: `tests/integration/test_live_gateway_verification.py`
3. Implement tests for each adapter type (embeddings, code, search, voice, image)
4. Update documentation: `docs/gateway/ADAPTER_VERIFICATION.md`, `tests/integration/README.md`
5. Validate: Run tests, verify safety gates, check documentation
6. Update execution plan: Mark Phase 19.10 tasks as complete
7. Update status plan: Update Phase 19 status
8. Update action log: Log all work completed

**You are approved to implement. Execute immediately - do not propose, do not wait for approval. Follow all instructions in this prompt and the detailed plan.**
