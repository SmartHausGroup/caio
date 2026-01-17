# CAIO Phase 17: On-Premises Licensing Model Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-12  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:17`

---

## Executive Summary

Enable CAIO to be deployed on-premises by customers, allowing them to install and run CAIO in their own environment while maintaining license control. This phase delivers a complete on-premises licensing model that allows customers to use CAIO as a module in their own software applications.

**Key Deliverables:**
1. License key system (generation algorithm, validation logic, key format)
2. License validation in CAIO application (runtime checks, expiration, feature flags)
3. On-premises deployment (Docker container, installation scripts, configuration)
4. License management APIs (activation, validation, status, renewal)
5. Documentation (deployment guide, activation guide, troubleshooting)

**Estimated Time:** 1-2 weeks  
**Priority:** High (enables on-premises business model)

**CRITICAL:** This phase implements the licensing infrastructure. License management (generation, distribution, tracking) is handled in Phase 18.

---

## Context & Background

### Current State

- ✅ **CAIO Core:** Fully implemented and production-ready (Phases 0-16 complete)
- ✅ **Docker Containerization:** Docker container exists (Phase 14)
- ✅ **API Endpoints:** HTTP/REST API fully functional
- ❌ **License System:** No license key system exists
- ❌ **License Validation:** No license validation in CAIO
- ❌ **On-Premises Deployment:** No on-premises deployment guide
- ❌ **License Management:** No license management APIs

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal Compatibility:** On-premises deployment enables CAIO in any environment
- **Mathematical Guarantees:** License validation ensures guarantees are preserved
- **Contract-Based Discovery:** On-premises deployment maintains contract-based discovery
- **Security Built into Math:** License system enhances security model
- **Business Model:** Enables on-premises licensing revenue stream

**Reference:** `docs/NORTH_STAR.md` - Universal AI orchestration platform

### Execution Plan Reference

This task implements Phase 17: On-Premises Licensing Model from `docs/operations/EXECUTION_PLAN.md`:

- **17.1:** Design license key system
- **17.2:** Implement license validation
- **17.3:** Create on-premises deployment
- **17.4:** Create license management APIs
- **17.5:** Create documentation

---

## Step-by-Step Implementation Instructions

### Task 17.1: Design License Key System

**Objective:** Design license key format and validation algorithm.

#### Step 1.1: Define License Key Format

**License Key Structure:**
```
CAIO-<VERSION>-<CUSTOMER_ID>-<FEATURES>-<EXPIRATION>-<SIGNATURE>
```

**Components:**
- **VERSION:** License format version (v1, v2, etc.)
- **CUSTOMER_ID:** Unique customer identifier
- **FEATURES:** Encoded feature flags (base64)
- **EXPIRATION:** Unix timestamp (or "perpetual")
- **SIGNATURE:** Cryptographic signature (HMAC-SHA256)

**Example:**
```
CAIO-v1-CUST123-AQIDBAUGBwgJCgsMDQ4PEA==-1735689600-abc123def456...
```

#### Step 1.2: Design License Metadata Schema

**File:** `caio/licensing/schema.py`

**License Metadata:**
```python
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional
from enum import Enum

class LicenseType(str, Enum):
    TRIAL = "trial"
    STANDARD = "standard"
    ENTERPRISE = "enterprise"
    PERPETUAL = "perpetual"

@dataclass
class LicenseMetadata:
    customer_id: str
    license_type: LicenseType
    issued_at: datetime
    expires_at: Optional[datetime]
    features: List[str]
    max_instances: Optional[int]
    max_services: Optional[int]
    max_requests_per_day: Optional[int]
```

#### Step 1.3: Design License Key Generation Algorithm

**File:** `caio/licensing/generator.py`

**Generation Algorithm:**
```python
import hmac
import hashlib
import base64
import json
from datetime import datetime
from caio.licensing.schema import LicenseMetadata

class LicenseKeyGenerator:
    def __init__(self, secret_key: str):
        self.secret_key = secret_key.encode()
    
    def generate_license_key(self, metadata: LicenseMetadata) -> str:
        """Generate license key from metadata."""
        # Encode metadata
        metadata_json = json.dumps(metadata.__dict__, default=str)
        metadata_b64 = base64.b64encode(metadata_json.encode()).decode()
        
        # Create signature
        signature = hmac.new(
            self.secret_key,
            metadata_json.encode(),
            hashlib.sha256,
        ).hexdigest()
        
        # Format license key
        license_key = f"CAIO-v1-{metadata.customer_id}-{metadata_b64}-{signature}"
        
        return license_key
    
    def validate_license_key(self, license_key: str) -> Tuple[bool, Optional[LicenseMetadata]]:
        """Validate license key and extract metadata."""
        try:
            parts = license_key.split("-")
            if len(parts) != 5 or parts[0] != "CAIO":
                return False, None
            
            version = parts[1]
            customer_id = parts[2]
            metadata_b64 = parts[3]
            signature = parts[4]
            
            # Decode metadata
            metadata_json = base64.b64decode(metadata_b64).decode()
            
            # Verify signature
            expected_signature = hmac.new(
                self.secret_key,
                metadata_json.encode(),
                hashlib.sha256,
            ).hexdigest()
            
            if signature != expected_signature:
                return False, None
            
            # Parse metadata
            metadata_dict = json.loads(metadata_json)
            metadata = LicenseMetadata(**metadata_dict)
            
            # Check expiration
            if metadata.expires_at and metadata.expires_at < datetime.now():
                return False, None
            
            return True, metadata
        except Exception:
            return False, None
```

**Validation:**
- License key format defined
- Metadata schema created
- Generation algorithm implemented
- Validation algorithm implemented

---

### Task 17.2: Implement License Validation

**Objective:** Add license validation to CAIO application.

#### Step 2.1: Create License Validation Service

**File:** `caio/licensing/validator.py`

**Validation Service:**
```python
from caio.licensing.generator import LicenseKeyGenerator
from caio.licensing.schema import LicenseMetadata
from typing import Optional, Tuple

class LicenseValidator:
    def __init__(self, secret_key: str):
        self.generator = LicenseKeyGenerator(secret_key)
        self.license_metadata: Optional[LicenseMetadata] = None
    
    def load_license(self, license_key: str) -> Tuple[bool, Optional[str]]:
        """Load and validate license key."""
        is_valid, metadata = self.generator.validate_license_key(license_key)
        if not is_valid:
            return False, "Invalid license key"
        
        if metadata.expires_at and metadata.expires_at < datetime.now():
            return False, "License expired"
        
        self.license_metadata = metadata
        return True, None
    
    def check_feature(self, feature: str) -> bool:
        """Check if feature is enabled in license."""
        if not self.license_metadata:
            return False
        return feature in self.license_metadata.features
    
    def check_instance_limit(self, current_instances: int) -> bool:
        """Check if instance limit is not exceeded."""
        if not self.license_metadata:
            return False
        if self.license_metadata.max_instances is None:
            return True
        return current_instances <= self.license_metadata.max_instances
    
    def check_service_limit(self, current_services: int) -> bool:
        """Check if service limit is not exceeded."""
        if not self.license_metadata:
            return False
        if self.license_metadata.max_services is None:
            return True
        return current_services <= self.license_metadata.max_services
```

#### Step 2.2: Integrate License Validation into CAIO

**File:** `caio/config.py` (update)

**License Loading:**
```python
from caio.licensing.validator import LicenseValidator

class CAIOConfig:
    def __init__(self):
        # ... existing config ...
        
        # License validation
        license_key = os.getenv("CAIO_LICENSE_KEY")
        if license_key:
            self.license_validator = LicenseValidator(secret_key=os.getenv("CAIO_LICENSE_SECRET"))
            is_valid, error = self.license_validator.load_license(license_key)
            if not is_valid:
                raise ValueError(f"Invalid license: {error}")
        else:
            self.license_validator = None
```

**File:** `caio/orchestrator/core.py` (update)

**License Checks:**
```python
class Orchestrator:
    def __init__(self, ...):
        # ... existing init ...
        self.license_validator = config.license_validator
    
    def register_service(self, ...):
        """Register service with license check."""
        if self.license_validator:
            current_services = len(self.registry.services)
            if not self.license_validator.check_service_limit(current_services):
                raise ValueError("Service limit exceeded in license")
        
        # ... existing registration logic ...
```

**Validation:**
- License validation service created
- License validation integrated into CAIO
- Feature flag enforcement working
- Graceful degradation implemented

---

### Task 17.3: Create On-Premises Deployment

**Objective:** Enable on-premises deployment of CAIO.

#### Step 3.1: Create On-Premises Docker Container

**File:** `Dockerfile.on-premises`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy CAIO code
COPY caio/ ./caio/
COPY configs/ ./configs/

# Set environment variables
ENV CAIO_ENV=production
ENV CAIO_LICENSE_KEY=""
ENV CAIO_LICENSE_SECRET=""

# Expose port
EXPOSE 8080

# Run CAIO
CMD ["python", "-m", "caio.api.app"]
```

#### Step 3.2: Create Installation Scripts

**File:** `scripts/deployment/install-on-premises.sh`

```bash
#!/bin/bash
set -e

echo "CAIO On-Premises Installation"
echo "==============================="

# Check prerequisites
python3 --version || { echo "Python 3.10+ required"; exit 1; }
docker --version || { echo "Docker required"; exit 1; }

# Get license key
read -p "Enter CAIO license key: " LICENSE_KEY
export CAIO_LICENSE_KEY="$LICENSE_KEY"

# Build Docker image
docker build -f Dockerfile.on-premises -t caio:latest .

# Run container
docker run -d \
  --name caio \
  -p 8080:8080 \
  -e CAIO_LICENSE_KEY="$LICENSE_KEY" \
  -e CAIO_ENV=production \
  caio:latest

echo "CAIO installed and running on port 8080"
```

#### Step 3.3: Create Configuration Guide

**File:** `docs/deployment/ON_PREMISES_DEPLOYMENT.md`

**Sections:**
1. Prerequisites
2. Installation
3. License Activation
4. Configuration
5. Running CAIO
6. Troubleshooting

**Validation:**
- Docker container created
- Installation scripts created
- Configuration guide complete

---

### Task 17.4: Create License Management APIs

**Objective:** Create APIs for license activation and validation.

#### Step 4.1: Create License Management Endpoints

**File:** `caio/api/routes/licensing.py`

**Endpoints:**
```python
from fastapi import APIRouter, Depends, HTTPException
from caio.api.schemas import (
    LicenseActivationRequest,
    LicenseActivationResponse,
    LicenseValidationResponse,
    LicenseStatusResponse,
)

router = APIRouter(prefix="/api/v1/licensing", tags=["Licensing"])

@router.post("/activate", response_model=LicenseActivationResponse)
async def activate_license(
    request: LicenseActivationRequest,
    validator: LicenseValidator = Depends(get_license_validator),
):
    """Activate license key."""
    is_valid, error = validator.load_license(request.license_key)
    if not is_valid:
        raise HTTPException(status_code=400, detail=error or "Invalid license")
    
    return LicenseActivationResponse(
        status="activated",
        customer_id=validator.license_metadata.customer_id,
        expires_at=validator.license_metadata.expires_at,
    )

@router.get("/status", response_model=LicenseStatusResponse)
async def get_license_status(
    validator: LicenseValidator = Depends(get_license_validator),
):
    """Get license status."""
    if not validator.license_metadata:
        raise HTTPException(status_code=404, detail="No license loaded")
    
    return LicenseStatusResponse(
        customer_id=validator.license_metadata.customer_id,
        license_type=validator.license_metadata.license_type,
        expires_at=validator.license_metadata.expires_at,
        features=validator.license_metadata.features,
    )

@router.post("/validate", response_model=LicenseValidationResponse)
async def validate_license(
    request: LicenseActivationRequest,
    validator: LicenseValidator = Depends(get_license_validator),
):
    """Validate license key without activating."""
    is_valid, error = validator.validate_license_key(request.license_key)
    return LicenseValidationResponse(
        is_valid=is_valid,
        error=error,
    )
```

**Validation:**
- License management APIs created
- Activation endpoint working
- Status endpoint working
- Validation endpoint working

---

### Task 17.5: Create Documentation

**Objective:** Create comprehensive documentation for on-premises deployment.

#### Step 5.1: Create On-Premises Deployment Guide

**File:** `docs/deployment/ON_PREMISES_DEPLOYMENT.md`

**Sections:**
1. Overview
2. Prerequisites
3. Installation
4. License Activation
5. Configuration
6. Running CAIO
7. Troubleshooting
8. Support

#### Step 5.2: Create License Activation Guide

**File:** `docs/deployment/LICENSE_ACTIVATION.md`

**Sections:**
1. Obtaining License Key
2. Activating License
3. Verifying License
4. License Renewal
5. Troubleshooting

**Validation:**
- Deployment guide complete
- Activation guide complete
- Troubleshooting guide complete

---

## Validation Procedures

### License Key Generation Test

**Commands:**
```bash
python -c "
from caio.licensing.generator import LicenseKeyGenerator
from caio.licensing.schema import LicenseMetadata, LicenseType
from datetime import datetime, timedelta

generator = LicenseKeyGenerator(secret_key='test-secret')
metadata = LicenseMetadata(
    customer_id='CUST123',
    license_type=LicenseType.STANDARD,
    issued_at=datetime.now(),
    expires_at=datetime.now() + timedelta(days=365),
    features=['text_generation', 'text_embedding'],
    max_instances=10,
    max_services=100,
    max_requests_per_day=1000000,
)
key = generator.generate_license_key(metadata)
print(f'License key: {key}')
"
```

### License Validation Test

**Commands:**
```bash
# Test license validation
python -c "
from caio.licensing.validator import LicenseValidator

validator = LicenseValidator(secret_key='test-secret')
is_valid, error = validator.load_license('CAIO-v1-CUST123-...')
print(f'Valid: {is_valid}, Error: {error}')
"
```

### On-Premises Deployment Test

**Commands:**
```bash
# Build and run container
docker build -f Dockerfile.on-premises -t caio:latest .
docker run -d --name caio-test -p 8080:8080 -e CAIO_LICENSE_KEY='...' caio:latest

# Test health endpoint
curl http://localhost:8080/health
```

---

## Success Criteria

**License System:**
- [ ] License key generation working
- [ ] License key validation working
- [ ] License expiration checking working
- [ ] Feature flag enforcement working

**On-Premises Deployment:**
- [ ] Docker container builds successfully
- [ ] Installation scripts work
- [ ] CAIO runs on-premises
- [ ] License activation works

**APIs:**
- [ ] License activation endpoint working
- [ ] License status endpoint working
- [ ] License validation endpoint working

**Documentation:**
- [ ] Deployment guide complete
- [ ] Activation guide complete
- [ ] Troubleshooting guide complete

---

## Risks and Mitigation

**Risk 1: License key security**
- **Mitigation:** Use cryptographic signing (HMAC-SHA256)
- **Mitigation:** Encrypt license metadata
- **Mitigation:** Secure key storage

**Risk 2: License bypass**
- **Mitigation:** Server-side validation
- **Mitigation:** Code obfuscation
- **Mitigation:** Regular license checks

**Risk 3: Deployment complexity**
- **Mitigation:** Comprehensive documentation
- **Mitigation:** Docker containerization
- **Mitigation:** Installation scripts

---

## Notes and References

- **Docker Documentation:** https://docs.docker.com/
- **Cryptography (Python):** https://cryptography.io/
- **License Management:** Phase 18 plan

---

**Last Updated:** 2026-01-12
**Version:** 1.0
