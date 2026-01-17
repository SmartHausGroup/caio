# Gateway Adapter Patterns

## Overview

Gateway adapters translate CAIO requests into service-specific payloads, execute the call, and
normalize the response back into CAIO-compatible outputs. All adapters inherit from
`caio.gateway.base.BaseAdapter` and should stay thin: transformation logic belongs in
`caio/gateway/transformer.py`.

## Base Adapter Responsibilities

- `transform_request(request, endpoint)` converts a CAIO request into the service payload.
- `transform_response(response)` converts a service response into a CAIO response.
- `execute(request, endpoint)` handles HTTP calls and response normalization.

## Common Patterns

### OpenAI-Compatible APIs

Many providers (e.g., Together AI, Azure OpenAI) accept OpenAI-style payloads. Reuse the shared
transformers and only override what is provider-specific (auth headers, model naming, URL paths).

### Search Providers

Search services typically accept query + optional filters and return a list of results. Normalize
results into `{"results": [...], "source": "<provider>"}` to keep downstream handling consistent.

### Voice Providers

Voice services often require binary or base64 payloads. Use adapter-specific request serializers and
keep response normalization focused on transcript + metadata (duration, confidence).

### Image Providers

Image services return image URLs or base64 images. Normalize into `{"images": [...], "format":
"url|base64"}` and ensure metadata includes requested dimensions and style parameters.

## Contract Alignment

- Adapter `service_id` must match the contract `service_id`.
- Contract `capabilities` should describe the adapter’s primary function (text generation, search,
  embeddings, voice, image).
- Contract `api.base_url` and endpoint paths must match adapter execution targets.

## References

- `docs/gateway/README.md`
- `configs/services/external/` (contract templates)
- `configs/schemas/service_contract.schema.yaml` (contract schema)
