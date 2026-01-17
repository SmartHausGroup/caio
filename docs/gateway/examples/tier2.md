# Tier 2 Integration Example (Specialized + Local)

Tier 2 services use the gateway adapters directly for execution.

## Example Contract (Perplexity)

```yaml
service_id: perplexity
name: Perplexity
version: 1.0.0
api:
  protocol: http
  base_url: https://api.perplexity.ai
  endpoints:
    - path: /chat/completions
      method: POST
capabilities:
  - type: text_generation
    parameters:
      models: [pplx-70b-online]
```

## Register Contract

```bash
curl -s -X POST http://localhost:8000/api/v1/services/register \
  -H 'Content-Type: application/json' \
  -d '{"contract": {"service_id": "perplexity", "name": "Perplexity", "version": "1.0.0", "api": {"protocol": "http", "base_url": "https://api.perplexity.ai", "endpoints": [{"path": "/chat/completions", "method": "POST"}]}, "capabilities": [{"type": "text_generation", "parameters": {"models": ["pplx-70b-online"]}}]}}'
```

## Execute via Gateway

```bash
curl -s -X POST http://localhost:8000/api/v1/orchestrate \
  -H 'Content-Type: application/json' \
  -d '{"requirements": ["text_generation"], "context": {"prompt": "Summarize current trends"}}'
```
