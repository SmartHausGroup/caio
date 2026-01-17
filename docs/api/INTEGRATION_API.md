# CAIO Integration API

Public integration endpoints for external developers to register and discover
services. These endpoints are unauthenticated to enable open integration.

Base URL: `/api/v1/integration`

## POST /register-service

Registers a service contract.

**Request**
```json
{
  "contract": { "service_id": "my-service", "name": "My Service", "...": "..." },
  "service_id": "optional-override"
}
```

**Response**
```json
{
  "service_id": "my-service",
  "status": "registered",
  "message": "Service my-service registered successfully"
}
```

## POST /discover-services

Discover services based on capabilities, guarantees, and constraints.

**Request**
```json
{
  "capabilities": ["text_generation"],
  "guarantees": {},
  "constraints": {}
}
```

**Response**
```json
{
  "services": [],
  "count": 0
}
```

## POST /validate-contract

Validate a service contract against CAIO schema and invariants.

**Request**
```json
{
  "contract": { "service_id": "my-service", "name": "My Service" }
}
```

**Response**
```json
{
  "is_valid": true,
  "errors": []
}
```

## POST /upload-contract

Upload a YAML contract file and register the service.
