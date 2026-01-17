# Tier 3 Integration Example (Extended Ecosystem)

Tier 3 services include embeddings, search, voice, and image providers.

## Example Contract (Tavily Search)

```yaml
service_id: tavily
name: Tavily
version: 1.0.0
api:
  protocol: http
  base_url: https://api.tavily.com
  endpoints:
    - path: /search
      method: POST
capabilities:
  - type: search
    parameters:
      models: [tavily]
```

## Register Contract

```bash
curl -s -X POST http://localhost:8000/api/v1/services/register \
  -H 'Content-Type: application/json' \
  -d '{"contract": {"service_id": "tavily", "name": "Tavily", "version": "1.0.0", "api": {"protocol": "http", "base_url": "https://api.tavily.com", "endpoints": [{"path": "/search", "method": "POST"}]}, "capabilities": [{"type": "search", "parameters": {"models": ["tavily"]}}]}}'
```

## Execute via Gateway

```bash
curl -s -X POST http://localhost:8000/api/v1/orchestrate \
  -H 'Content-Type: application/json' \
  -d '{"requirements": ["search"], "context": {"query": "CAIO service gateway"}}'
```
