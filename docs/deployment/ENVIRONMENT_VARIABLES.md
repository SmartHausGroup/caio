# CAIO Environment Variables

This document lists environment variables used by CAIO. Defaults apply when unset unless noted.

## Required (Production)

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_ENV` | Environment name (`development` or `production`) | `development` |
| `CAIO_AUTH_SECRET_KEY` | Secret key for auth signing | (required in production) |
| `CAIO_CORS_ORIGINS` | Comma-separated origins (no `*` in production) | `*` |

## API Configuration

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_API_HOST` | Bind host | `0.0.0.0` |
| `CAIO_API_PORT` | Bind port | `8080` |

## Authentication

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_AUTH_SECRET_KEY` | JWT/signing secret key | `""` |
| `CAIO_AUTH_ALGORITHM` | JWT/signing algorithm | `HS256` |

## Licensing

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_LICENSE_KEY` | License key string (`CAIO-v2-...`) | empty |
| `CAIO_LICENSE_PUBLIC_KEY` | Public key PEM or file path for validation | empty |
| `CAIO_LICENSE_REQUIRED` | Enforce license checks | `false` |
| `CAIO_LICENSE_PRIVATE_KEY` | Private key PEM or file path (operator-only CLI) | empty |

## Logging

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_LOG_LEVEL` | Log level (e.g., `INFO`, `DEBUG`) | `INFO` |
| `CAIO_LOG_FORMAT` | Log format (`json` or `text`) | `json` |

## Rate Limiting

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_RATE_LIMIT_ENABLED` | Enable rate limiting middleware | `false` |
| `CAIO_RATE_LIMIT_REQUESTS` | Allowed requests per window | `100` |
| `CAIO_RATE_LIMIT_WINDOW_SECONDS` | Sliding window size in seconds | `60` |
| `CAIO_RATE_LIMIT_KEY` | Key strategy (`ip`, `token`, `license`) | `ip` |
| `CAIO_RATE_LIMIT_EXEMPT_PATHS` | Comma-separated exempt paths | `/health,/metrics,/docs,/openapi.json,/redoc` |

## Traceability Storage

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_TRACE_STORAGE` | Storage backend (`file` or `sqlite`) | `file` |
| `CAIO_TRACE_STORAGE_DIR` | Trace storage directory | `logs/traceability` |

## SLOs & Alerts

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_SLO_LATENCY_P95_MS` | Latency P95 threshold (ms) | `200` |
| `CAIO_SLO_LATENCY_P99_MS` | Latency P99 threshold (ms) | `400` |
| `CAIO_SLO_CORRECTNESS_MIN` | Minimum correctness rate | `1.0` |
| `CAIO_SLO_SECURITY_VIOLATION_MAX` | Maximum security violation rate | `0.0` |
| `CAIO_SLO_TRACE_COMPLETENESS_MIN` | Minimum trace completeness rate | `1.0` |
| `CAIO_ALERT_WEBHOOK` | Alert webhook URL | empty |

## Notebook/CI

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_NOTEBOOK_SEED` | Seed for deterministic notebooks | `42` |
