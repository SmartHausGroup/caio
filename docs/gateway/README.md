# CAIO Service Gateway

## Overview

The CAIO Service Gateway executes requests against non-inference services that are registered in
the CAIO registry. Inference requests are routed to VFE, which is the unified inference execution
layer for all model calls.

## Responsibilities

- Execute marketplace agent requests using contract-based HTTP adapters.
- Transform CAIO requests to service payloads and normalize responses.
- Enforce guarantees after execution via `GuaranteeEnforcer`.
- Record traceability data for execution events.

## Non-Responsibilities

- Inference execution for LLM providers.
- Model provider adapters for OpenAI, Anthropic, Groq, Mistral, or Cohere.

## Inference Routing

Inference services are routed to VFE by the gateway executor. CAIO orchestrates and validates the
result, while VFE performs the actual inference execution.

## Supported Services

### Tier 1: Core LLM Providers (VFE Routed)

- OpenAI, Anthropic, Groq, Mistral AI, Cohere

### Tier 2: Specialized + Local

- Ollama, LM Studio, Google Gemini, xAI Grok, Perplexity, Hugging Face, Together AI, Replicate,
  Azure OpenAI, AWS Bedrock

### Tier 3: Extended Ecosystem

- Embeddings: OpenAI Embeddings, Cohere Embed, Voyage
- Code: GitHub Copilot API, Cursor API
- Search: Tavily, Serper
- Voice: ElevenLabs, Deepgram
- Image: DALL-E, Stability AI, Midjourney
- Additional LLMs: Meta AI, Google PaLM, Aleph Alpha

## Contract Templates

Contract templates for gateway-compatible services live in `configs/services/external/`. They
follow the flat contract structure (`service_id`, `name`, `version`, `api`, `capabilities`), while
remaining compatible with the nested `service` schema in
`configs/schemas/service_contract.schema.yaml`.

For validation, use the SDK helper (`caio_sdk.validate_contract` or the `caio.sdk` shim) or the public integration
endpoint (`POST /api/v1/integration/validate-contract`), both of which support flat and nested
contract structures.

## Adapter Patterns and Examples

- Adapter patterns: `docs/gateway/ADAPTER_PATTERNS.md`
- Integration examples (by tier): `docs/gateway/examples/`
- Troubleshooting: `docs/gateway/TROUBLESHOOTING.md`
- API versioning & compatibility: `docs/gateway/API_VERSIONING.md`

## Related Components

- `caio/gateway/executor.py` - Gateway execution engine and VFE routing
- `caio/gateway/transformer.py` - Request/response transformation helpers
- `caio/integrations/vfe_client.py` - VFE client integration
