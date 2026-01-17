# Adapter Verification Status

## Live Verification (Phase 19.10)

**Last Updated:** 2026-01-17  
**Plan Reference:** `plan:EXECUTION_PLAN:19.10`

### Non-Inference Adapters (CAIO Scope)

#### Embeddings

- ⚠️ OpenAI Embeddings — Pending live verification (requires `OPENAI_API_KEY`)
- ⚠️ Cohere Embed — Pending live verification (requires `COHERE_API_KEY`)
- ⚠️ Voyage AI — Pending live verification (requires `VOYAGE_API_KEY`)

#### Code

- ⚠️ GitHub Copilot — Pending live verification (requires `GITHUB_COPILOT_TOKEN`,
  `GITHUB_COPILOT_ORG`)
- ⚠️ Cursor — Pending live verification (requires `CURSOR_API_KEY`)

#### Search

- ⚠️ Tavily — Pending live verification (requires `TAVILY_API_KEY`)
- ⚠️ Serper — Pending live verification (requires `SERPER_API_KEY`)

#### Voice

- ⚠️ ElevenLabs — Pending live verification (requires `ELEVENLABS_API_KEY`,
  `ELEVENLABS_VOICE_ID`)
- ⚠️ Deepgram — Pending live verification (requires `DEEPGRAM_API_KEY`)

#### Image

- ⚠️ DALL-E — Pending live verification (requires `OPENAI_API_KEY`)
- ⚠️ Stability AI — Pending live verification (requires `STABILITY_API_KEY`)
- ⚠️ Midjourney — Pending live verification (requires `MIDJOURNEY_API_KEY`)

### Inference Adapters (VFE Scope)

Per ADR-0001, inference adapters are in VFE, not CAIO:

- Gemini, Grok, Ollama, LM Studio, Perplexity, Hugging Face, Together, Replicate, Azure OpenAI,
  AWS Bedrock, Meta AI, Google PaLM, Aleph Alpha

## Running Live Tests

```bash
# Enable live tests
export LIVE_TESTS_ENABLED=1

# Set API keys (examples)
export OPENAI_API_KEY="sk-..."
export COHERE_API_KEY="..."
export VOYAGE_API_KEY="..."
export GITHUB_COPILOT_TOKEN="..."
export GITHUB_COPILOT_ORG="your-org"
export CURSOR_API_KEY="..."
export TAVILY_API_KEY="..."
export SERPER_API_KEY="..."
export ELEVENLABS_API_KEY="..."
export ELEVENLABS_VOICE_ID="..."
export DEEPGRAM_API_KEY="..."
export STABILITY_API_KEY="..."
export MIDJOURNEY_API_KEY="..."

# Run live tests
pytest tests/integration/test_live_gateway_verification.py -v -m live
```

**Safety:** Tests only run when `LIVE_TESTS_ENABLED=1` is set.
