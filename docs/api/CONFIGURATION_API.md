# CAIO Configuration API Reference

## Overview

The Configuration API provides CRUD operations, validation, history, and audit trail for
operational settings (policies, constraints, SLOs, tenant settings).

Base URL: `http://localhost:8000`

## Authentication

Endpoints enforce role-based access control:

- `admin`: create, update, delete, rollback, import
- `admin` or `user`: list, get, validate, audit, export

## Endpoints

### Create Configuration

`POST /configurations`

```json
{
  "tenant_id": "tenant-1",
  "config_type": "policies",
  "config_data": {
    "name": "default-policy",
    "rate_limit": 1000,
    "access_rules": {"allow": ["10.0.0.0/24"]},
    "priority": "normal"
  }
}
```

### List Configurations

`GET /configurations?tenant_id=tenant-1&config_type=policies`

### Get Configuration

`GET /configurations/{config_id}`

### Update Configuration

`PUT /configurations/{config_id}`

```json
{
  "tenant_id": "tenant-1",
  "config_type": "policies",
  "config_data": {
    "name": "default-policy",
    "rate_limit": 2000,
    "access_rules": {"allow": ["10.0.0.0/24"]},
    "priority": "high"
  },
  "change_reason": "Increase rate limit"
}
```

### Delete Configuration

`DELETE /configurations/{config_id}`

### Configuration History

`GET /configurations/{config_id}/history`

### Rollback Configuration

`POST /configurations/{config_id}/rollback/{version}`

### Validate Configuration

`POST /configurations/validate`

### Audit Trail

`GET /configurations/audit?config_id={config_id}&change_type=update`

### Export Configurations

`GET /configurations/export?tenant_id=tenant-1`

### Import Configurations

`POST /configurations/import`

```json
{
  "configurations": [
    {
      "tenant_id": "tenant-1",
      "config_type": "policies",
      "config_data": {
        "name": "default-policy",
        "rate_limit": 1000,
        "access_rules": {"allow": ["10.0.0.0/24"]},
        "priority": "normal"
      }
    }
  ]
}
```
