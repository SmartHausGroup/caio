# CAIO Production Deployment Guide

## Prerequisites

- Python 3.11+ (or Docker)
- A configured environment file or exported environment variables
- Access to required ports (default: 8080)

## Configuration

Production deployments must set the minimum required environment variables:

- `CAIO_ENV=production`
- `CAIO_AUTH_SECRET_KEY` (required in production)
- `CAIO_CORS_ORIGINS` (comma-separated list; no wildcard in production)

See `docs/deployment/ENVIRONMENT_VARIABLES.md` for the full list.

## Run Locally (Non-Docker)

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

export CAIO_ENV=production
export CAIO_AUTH_SECRET_KEY="your-secret"
export CAIO_CORS_ORIGINS="https://your-domain.example"

uvicorn caio.api.app:app --host 0.0.0.0 --port 8080
```

## Docker Deployment

Build the image:

```bash
docker build -t caio:latest .
```

Run the container:

```bash
docker run --rm -p 8080:8080 \
  -e CAIO_ENV=production \
  -e CAIO_AUTH_SECRET_KEY="your-secret" \
  -e CAIO_CORS_ORIGINS="https://your-domain.example" \
  caio:latest
```

## Health Checks

- `GET /health` returns a status payload with component checks.
- HTTP status code is `200` when healthy and `503` when unhealthy.

## Logging

Logging is configured at startup via `CAIO_LOG_LEVEL` and `CAIO_LOG_FORMAT`.
Use `json` for structured logs in production.

## Troubleshooting

- If the service refuses to start in production, verify `CAIO_AUTH_SECRET_KEY` and `CAIO_CORS_ORIGINS`.
- If `/health` returns `unhealthy`, inspect the `components` map for the failing subsystem.
- For SLO alerts, verify `CAIO_SLO_*` thresholds and `CAIO_ALERT_WEBHOOK` if configured.

## Related Documentation

- `docs/deployment/PACKAGING.md`
- `docs/deployment/HARDENING_CHECKLIST.md`
- `docs/deployment/ENVIRONMENT_VARIABLES.md`
