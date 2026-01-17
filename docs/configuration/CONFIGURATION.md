# CAIO Configuration

**Status**: Active  
**Last Updated**: 2025-01-XX  
**Owner**: @smarthaus

---

## Overview

This document describes configuration options for CAIO, including environment variables, configuration files, and runtime settings.

**Note:** Configuration options are planned for Phase 6 implementation. This document describes expected functionality.

---

## Environment Variables

### CAIO_URL

**Default:** `http://localhost:8003`

Base URL for CAIO API server.

```bash
export CAIO_URL=http://localhost:8003
```

---

### CAIO_NOTEBOOK_SEED

**Default:** `42`

Seed for deterministic notebook execution (required for MA process).

```bash
export CAIO_NOTEBOOK_SEED=42
```

---

### CAIO_LOG_LEVEL

**Default:** `INFO`

Logging level (`DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`).

```bash
export CAIO_LOG_LEVEL=INFO
```

---

### CAIO_ENABLE_TRACING

**Default:** `true`

Enable traceability (generate trace records for all routing decisions).

```bash
export CAIO_ENABLE_TRACING=true
```

---

### CAIO_TRACE_RETENTION_DAYS

**Default:** `30`

Number of days to retain trace records.

```bash
export CAIO_TRACE_RETENTION_DAYS=30
```

---

## Configuration Files

### Service Contracts

Service contracts are YAML files that define service capabilities, guarantees, constraints, and costs.

**Location:** `configs/schemas/service_contract.schema.yaml`

**Example:** `configs/schemas/service_contract.example.yaml`

**Schema:** Service contracts must conform to the schema defined in `configs/schemas/service_contract.schema.yaml`.

---

### Policy Rules

Policy rules define routing constraints and security policies.

**Location:** `configs/policies/` (planned)

**Format:** YAML

**Example:**
```yaml
rules:
  - name: require_encryption
    type: security
    constraint: encryption_required == true
    action: reject
  
  - name: max_latency
    type: performance
    constraint: latency_ms <= 1000
    action: filter
```

---

### Master Equation Weights

Master equation weights control the optimization function.

**Location:** `configs/master_equation_weights.json` (planned)

**Format:** JSON

**Example:**
```json
{
  "alpha": 0.3,
  "beta": 0.2,
  "gamma": 0.2,
  "delta": 0.1,
  "lambda": 0.1,
  "rho": 0.05,
  "eta": 0.05
}
```

**Weights:**
- `alpha`: Intent score weight
- `beta`: Alignment score weight
- `gamma`: RFS link score weight
- `delta`: Wave field score weight
- `lambda`: Cost penalty weight
- `rho`: Risk penalty weight
- `eta`: Latency penalty weight

---

## Runtime Configuration

### Service Registry

**Configuration:**
- **Storage:** In-memory (default) or database (planned)
- **Persistence:** Optional persistence to disk (planned)

### Security

**Configuration:**
- **Authentication:** API keys or OAuth2 (planned)
- **Authorization:** Role-based access control (planned)
- **Encryption:** TLS/HTTPS (planned)

### Performance

**Configuration:**
- **Request Timeout:** Default 30 seconds
- **Max Concurrent Requests:** Configurable per service
- **Rate Limiting:** 100 requests/minute (planned)

---

## Configuration Validation

Configuration is validated at startup:

1. **Service Contracts:** Validated against schema
2. **Policy Rules:** Validated for syntax and conflicts
3. **Master Equation Weights:** Validated for sum = 1.0
4. **Environment Variables:** Validated for required values

---

## Configuration Examples

### Development Configuration

```bash
# .env (development)
CAIO_URL=http://localhost:8003
CAIO_LOG_LEVEL=DEBUG
CAIO_ENABLE_TRACING=true
CAIO_TRACE_RETENTION_DAYS=7
CAIO_NOTEBOOK_SEED=42
```

### Production Configuration

```bash
# .env (production)
CAIO_URL=https://caio.example.com
CAIO_LOG_LEVEL=INFO
CAIO_ENABLE_TRACING=true
CAIO_TRACE_RETENTION_DAYS=90
CAIO_NOTEBOOK_SEED=42
```

---

## References

- **API Reference:** `docs/api/API_REFERENCE.md`
- **SDK Specification:** `docs/SDK_SPECIFICATION.md`
- **Developer Guide:** `docs/developer/DEVELOPER_GUIDE.md`

