# Tier 1 Integration Example (VFE-Routed Inference)

Tier 1 inference providers are routed through VFE. The gateway still uses the contract metadata
for discovery, but execution happens via the VFE client.

## Example Contract (OpenAI)

```yaml
service_id: openai
name: OpenAI
version: 1.0.0
api:
  protocol: http
  base_url: https://api.openai.com
  endpoints:
    - path: /v1/chat/completions
      method: POST
capabilities:
  - type: text_generation
    parameters:
      models: [gpt-4, gpt-4o]
```

## Register Contract

```bash
curl -s -X POST http://localhost:8000/api/v1/services/register \
  -H 'Content-Type: application/json' \
  -d '{"contract": {"service_id": "openai", "name": "OpenAI", "version": "1.0.0", "api": {"protocol": "http", "base_url": "https://api.openai.com", "endpoints": [{"path": "/v1/chat/completions", "method": "POST"}]}, "capabilities": [{"type": "text_generation", "parameters": {"models": ["gpt-4o"]}}]}}'
```

## Route a Request

```bash
curl -s -X POST http://localhost:8000/api/v1/orchestrate \
  -H 'Content-Type: application/json' \
  -d '{"requirements": ["text_generation"], "context": {"prompt": "Hello"}}'
```
