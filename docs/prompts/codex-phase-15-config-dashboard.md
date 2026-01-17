# CAIO Phase 15: Configuration Dashboard Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-12  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:15`

---

## Executive Summary

Create a web-based configuration dashboard that allows non-technical users to configure CAIO's operational settings (policies, constraints, SLOs, tenant management) without editing YAML files or using the API directly. This dashboard enables self-service configuration for CAIO SaaS customers.

**Key Deliverables:**
1. Frontend dashboard (React or Streamlit) for configuration management
2. Backend REST API endpoints for configuration CRUD operations
3. Configuration database schema with version history
4. Real-time validation of configuration changes
5. Audit trail for all configuration changes
6. Role-based access control for configuration access
7. Configuration export/import functionality
8. Dashboard documentation and user guide

**Estimated Time:** 2-3 weeks  
**Priority:** High (enables self-service configuration for SaaS customers)

**CRITICAL:** This dashboard configures **operational settings** (policies, constraints, SLOs), NOT mathematical coefficients. Mathematical coefficients (α, β, γ, δ, λ, ρ, η) are fixed per `CAIO_MASTER_CALCULUS.md` (MA Doc-First: math is normative).

---

## Context & Background

### Current State

- ✅ **CAIO Core:** Fully implemented and production-ready (Phases 0-13 complete)
- ✅ **API Endpoints:** HTTP/REST API fully functional
- ✅ **Configuration System:** Environment-based configuration in place
- ✅ **Multi-Tenancy:** Tenant isolation implemented (Phase 14)
- ✅ **Policies & Constraints:** Policy engine and constraint system functional
- ❌ **Configuration Dashboard:** No web-based UI exists
- ❌ **Configuration API:** No dedicated configuration management endpoints
- ❌ **Configuration Storage:** No database schema for configuration versioning
- ❌ **Configuration Validation:** No real-time validation UI

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal Compatibility:** Dashboard makes CAIO accessible to non-technical users
- **Mathematical Guarantees:** Dashboard validates configurations before applying, ensuring guarantees are preserved
- **Contract-Based Discovery:** Dashboard allows configuration of service policies and constraints
- **Security Built into Math:** Dashboard enforces role-based access for configuration changes
- **Provability & Traceability:** Dashboard audit trail tracks all configuration changes with proofs

**Reference:** `docs/NORTH_STAR.md` - Universal AI orchestration platform

### Execution Plan Reference

This task implements Phase 15: Configuration Dashboard from `docs/operations/EXECUTION_PLAN.md`:

- **15.1:** Design dashboard architecture
- **15.2:** Create configuration database schema
- **15.3:** Implement backend configuration API
- **15.4:** Implement frontend dashboard
- **15.5:** Implement real-time validation
- **15.6:** Implement audit trail
- **15.7:** Create documentation

---

## Step-by-Step Implementation Instructions

### Task 15.1: Design Dashboard Architecture

**Objective:** Design the dashboard architecture and user experience.

#### Step 1.1: Create Architecture Diagram

**File:** `docs/dashboard/DASHBOARD_ARCHITECTURE.md`

**Components to Document:**

1. **Frontend Layer:**
   - Web-based UI (React or Streamlit)
   - Configuration forms for operational settings
   - Real-time validation feedback
   - Configuration history view
   - Role-based UI (different views for admin vs user)

2. **Backend Layer:**
   - FastAPI configuration endpoints
   - Configuration validation service
   - Configuration storage service
   - Audit logging service

3. **Data Layer:**
   - PostgreSQL database for configurations
   - Configuration version history
   - Audit log storage

4. **Integration Layer:**
   - Integration with CAIO API
   - Integration with CAIO auth system
   - Integration with tenant management (Phase 14)

**Architecture Diagram Format:**
- Use ASCII art or Mermaid diagram
- Show data flow (Browser → Dashboard → API → Database → CAIO Core)
- Show authentication flow
- Label all components

**Example Structure:**
```markdown
# CAIO Configuration Dashboard Architecture

## Overview

CAIO Configuration Dashboard provides web-based UI for configuring operational settings:

```
Browser
  ↓
Configuration Dashboard (React/Streamlit)
  ↓
Configuration API (FastAPI)
  ↓
Configuration Service
  ↓
PostgreSQL Database
  ↓
CAIO Core (Orchestrator)
```

## Component Details

[Detailed descriptions of each component]
```

#### Step 1.2: Define Configuration Scope

**CRITICAL:** Dashboard configures **operational settings**, NOT mathematical coefficients.

**Configurable via Dashboard:**

1. **Service Policies:**
   - Rate limits (requests per minute, requests per hour)
   - Access rules (allowed IPs, blocked IPs, allowed users)
   - Compliance rules (data residency, encryption requirements)
   - Service priorities (high, normal, low)

2. **Constraints:**
   - Max latency (P95, P99 thresholds)
   - Min accuracy (accuracy thresholds)
   - Cost budgets (max cost per request, max cost per day)
   - Resource quotas (CPU, memory, GPU limits)

3. **SLOs (Service Level Objectives):**
   - Latency targets (P95 ≤ 50ms, P99 ≤ 100ms)
   - Availability targets (99.9%, 99.99%)
   - Accuracy thresholds (≥ 0.95, ≥ 0.99)
   - Throughput targets (requests per second)

4. **Tenant Management:**
   - Resource quotas per tenant
   - Feature flags per tenant
   - Service access per tenant
   - Usage limits per tenant

**NOT Configurable via Dashboard:**

- **Master equation coefficients** (α, β, γ, δ, λ, ρ, η) - These are fixed mathematical constants per `CAIO_MASTER_CALCULUS.md`
- **Mathematical invariants** - These are normative and cannot be changed via dashboard
- **Service contracts** - Use existing contract registration system (API or YAML files)
- **Mathematical equations** - Core math is fixed (MA Doc-First principle)

**Reference:** `docs/math/CAIO_MASTER_CALCULUS.md` - Mathematical coefficients are fixed

#### Step 1.3: Create UI/UX Mockups

**File:** `docs/dashboard/UI_MOCKUPS.md`

**Mockup Sections:**

1. **Dashboard Home:**
   - Overview of current configuration
   - Quick stats (active policies, constraints, SLOs)
   - Recent changes

2. **Policies Configuration:**
   - List of policies
   - Add/Edit/Delete policy forms
   - Policy validation feedback

3. **Constraints Configuration:**
   - List of constraints
   - Add/Edit/Delete constraint forms
   - Constraint validation feedback

4. **SLOs Configuration:**
   - List of SLOs
   - Add/Edit/Delete SLO forms
   - SLO validation feedback

5. **Tenant Management:**
   - List of tenants
   - Tenant configuration forms
   - Tenant resource quotas

6. **Configuration History:**
   - Timeline of configuration changes
   - Change details (who, what, when)
   - Rollback capability

**Validation:**
- Architecture diagram complete
- Configuration scope clearly defined
- UI/UX mockups created
- API endpoint specifications defined

---

### Task 15.2: Create Configuration Database Schema

**Objective:** Design and implement database schema for configuration storage.

#### Step 2.1: Design Database Schema

**File:** `caio/database/schema.py` or migration script

**Tables:**

1. **configurations:**
   - Store configuration snapshots
   - Tenant-scoped
   - Versioned

2. **configuration_history:**
   - Version history for configurations
   - Rollback support

3. **configuration_changes:**
   - Audit log of all changes
   - User attribution
   - Change details

**Schema:**
```sql
CREATE TABLE configurations (
    id VARCHAR(255) PRIMARY KEY,
    tenant_id VARCHAR(255),
    config_type VARCHAR(50) NOT NULL,  -- policies, constraints, slos, tenant_settings
    config_data JSONB NOT NULL,
    version INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE configuration_history (
    id VARCHAR(255) PRIMARY KEY,
    configuration_id VARCHAR(255) NOT NULL,
    version INTEGER NOT NULL,
    config_data JSONB NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(255),
    change_reason TEXT,
    FOREIGN KEY (configuration_id) REFERENCES configurations(id)
);

CREATE TABLE configuration_changes (
    id VARCHAR(255) PRIMARY KEY,
    configuration_id VARCHAR(255) NOT NULL,
    change_type VARCHAR(50) NOT NULL,  -- create, update, delete
    old_value JSONB,
    new_value JSONB,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(255),
    change_reason TEXT,
    FOREIGN KEY (configuration_id) REFERENCES configurations(id)
);

CREATE INDEX idx_configurations_tenant ON configurations(tenant_id);
CREATE INDEX idx_configurations_type ON configurations(config_type);
CREATE INDEX idx_configuration_history_config ON configuration_history(configuration_id);
CREATE INDEX idx_configuration_changes_config ON configuration_changes(configuration_id);
```

#### Step 2.2: Create Database Models

**File:** `caio/database/models.py`

**Models:**
```python
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Any, Optional
from enum import Enum

class ConfigType(str, Enum):
    POLICIES = "policies"
    CONSTRAINTS = "constraints"
    SLOS = "slos"
    TENANT_SETTINGS = "tenant_settings"

class ChangeType(str, Enum):
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"

@dataclass
class Configuration:
    id: str
    tenant_id: Optional[str]
    config_type: ConfigType
    config_data: Dict[str, Any]
    version: int
    created_at: datetime
    updated_at: datetime
    created_by: str

@dataclass
class ConfigurationHistory:
    id: str
    configuration_id: str
    version: int
    config_data: Dict[str, Any]
    changed_at: datetime
    changed_by: str
    change_reason: Optional[str]

@dataclass
class ConfigurationChange:
    id: str
    configuration_id: str
    change_type: ChangeType
    old_value: Optional[Dict[str, Any]]
    new_value: Optional[Dict[str, Any]]
    changed_at: datetime
    changed_by: str
    change_reason: Optional[str]
```

**Validation:**
- Database schema designed
- Models created
- Migration scripts ready
- Indexes defined

---

### Task 15.3: Implement Backend Configuration API

**Objective:** Create REST API endpoints for configuration management.

#### Step 3.1: Create Configuration Service

**File:** `caio/services/configuration.py`

**Service Methods:**
```python
class ConfigurationService:
    def create_configuration(
        self,
        tenant_id: Optional[str],
        config_type: ConfigType,
        config_data: Dict[str, Any],
        created_by: str,
    ) -> Configuration:
        """Create a new configuration."""
        pass

    def get_configuration(
        self,
        config_id: str,
        tenant_id: Optional[str] = None,
    ) -> Optional[Configuration]:
        """Get configuration by ID."""
        pass

    def update_configuration(
        self,
        config_id: str,
        config_data: Dict[str, Any],
        updated_by: str,
        change_reason: Optional[str] = None,
    ) -> Configuration:
        """Update configuration (creates new version)."""
        pass

    def delete_configuration(
        self,
        config_id: str,
        deleted_by: str,
        change_reason: Optional[str] = None,
    ) -> bool:
        """Delete configuration."""
        pass

    def list_configurations(
        self,
        tenant_id: Optional[str] = None,
        config_type: Optional[ConfigType] = None,
    ) -> List[Configuration]:
        """List configurations with optional filters."""
        pass

    def get_configuration_history(
        self,
        config_id: str,
    ) -> List[ConfigurationHistory]:
        """Get version history for configuration."""
        pass

    def rollback_configuration(
        self,
        config_id: str,
        version: int,
        rolled_back_by: str,
    ) -> Configuration:
        """Rollback configuration to previous version."""
        pass

    def validate_configuration(
        self,
        config_type: ConfigType,
        config_data: Dict[str, Any],
    ) -> Tuple[bool, List[str]]:
        """Validate configuration data."""
        pass
```

#### Step 3.2: Create Configuration API Endpoints

**File:** `caio/api/routes/configuration.py`

**Endpoints:**
```python
from fastapi import APIRouter, Depends, HTTPException
from caio.services.configuration import ConfigurationService
from caio.api.middleware.auth import require_roles
from caio.api.schemas import (
    ConfigurationCreateRequest,
    ConfigurationUpdateRequest,
    ConfigurationResponse,
    ConfigurationListResponse,
    ConfigurationHistoryResponse,
    ConfigurationValidationResponse,
)

router = APIRouter(prefix="/api/v1/configurations", tags=["Configuration"])

@router.post("/", response_model=ConfigurationResponse)
async def create_configuration(
    request: ConfigurationCreateRequest,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin")),
):
    """Create a new configuration."""
    # Validate configuration
    is_valid, errors = service.validate_configuration(
        request.config_type,
        request.config_data,
    )
    if not is_valid:
        raise HTTPException(
            status_code=400,
            detail=f"Configuration validation failed: {errors}",
        )
    
    # Create configuration
    config = service.create_configuration(
        tenant_id=request.tenant_id,
        config_type=request.config_type,
        config_data=request.config_data,
        created_by=_actor.user_id,
    )
    
    return ConfigurationResponse(**config.__dict__)

@router.get("/{config_id}", response_model=ConfigurationResponse)
async def get_configuration(
    config_id: str,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin", "user")),
):
    """Get configuration by ID."""
    config = service.get_configuration(config_id, tenant_id=_actor.tenant_id)
    if not config:
        raise HTTPException(status_code=404, detail="Configuration not found")
    return ConfigurationResponse(**config.__dict__)

@router.put("/{config_id}", response_model=ConfigurationResponse)
async def update_configuration(
    config_id: str,
    request: ConfigurationUpdateRequest,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin")),
):
    """Update configuration."""
    # Validate configuration
    is_valid, errors = service.validate_configuration(
        request.config_type,
        request.config_data,
    )
    if not is_valid:
        raise HTTPException(
            status_code=400,
            detail=f"Configuration validation failed: {errors}",
        )
    
    # Update configuration
    config = service.update_configuration(
        config_id=config_id,
        config_data=request.config_data,
        updated_by=_actor.user_id,
        change_reason=request.change_reason,
    )
    
    return ConfigurationResponse(**config.__dict__)

@router.delete("/{config_id}")
async def delete_configuration(
    config_id: str,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin")),
):
    """Delete configuration."""
    success = service.delete_configuration(
        config_id=config_id,
        deleted_by=_actor.user_id,
    )
    if not success:
        raise HTTPException(status_code=404, detail="Configuration not found")
    return {"status": "deleted"}

@router.get("/", response_model=ConfigurationListResponse)
async def list_configurations(
    tenant_id: Optional[str] = None,
    config_type: Optional[str] = None,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin", "user")),
):
    """List configurations with optional filters."""
    configs = service.list_configurations(
        tenant_id=tenant_id or _actor.tenant_id,
        config_type=ConfigType(config_type) if config_type else None,
    )
    return ConfigurationListResponse(configurations=configs)

@router.get("/{config_id}/history", response_model=ConfigurationHistoryResponse)
async def get_configuration_history(
    config_id: str,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin", "user")),
):
    """Get configuration version history."""
    history = service.get_configuration_history(config_id)
    return ConfigurationHistoryResponse(history=history)

@router.post("/{config_id}/rollback/{version}")
async def rollback_configuration(
    config_id: str,
    version: int,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin")),
):
    """Rollback configuration to previous version."""
    config = service.rollback_configuration(
        config_id=config_id,
        version=version,
        rolled_back_by=_actor.user_id,
    )
    return ConfigurationResponse(**config.__dict__)

@router.post("/validate", response_model=ConfigurationValidationResponse)
async def validate_configuration(
    request: ConfigurationCreateRequest,
    service: ConfigurationService = Depends(get_configuration_service),
    _actor=Depends(require_roles("admin", "user")),
):
    """Validate configuration without creating it."""
    is_valid, errors = service.validate_configuration(
        request.config_type,
        request.config_data,
    )
    return ConfigurationValidationResponse(
        is_valid=is_valid,
        errors=errors,
    )
```

#### Step 3.3: Create Configuration Validation Logic

**File:** `caio/services/configuration_validator.py`

**Validation Rules:**

1. **Policy Validation:**
   - Rate limits must be positive integers
   - Access rules must be valid IP ranges or user IDs
   - Compliance rules must reference valid compliance standards

2. **Constraint Validation:**
   - Max latency must be positive
   - Min accuracy must be between 0 and 1
   - Cost budgets must be positive
   - Resource quotas must be positive

3. **SLO Validation:**
   - Latency targets must be positive
   - Availability targets must be between 0 and 100
   - Accuracy thresholds must be between 0 and 1
   - Throughput targets must be positive

4. **Tenant Settings Validation:**
   - Resource quotas must be positive
   - Feature flags must be valid boolean values
   - Service access must reference valid service IDs

**Validation Implementation:**
```python
class ConfigurationValidator:
    def validate_policy(self, policy_data: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate policy configuration."""
        errors = []
        
        # Validate rate limits
        if "rate_limit" in policy_data:
            rate_limit = policy_data["rate_limit"]
            if not isinstance(rate_limit, int) or rate_limit <= 0:
                errors.append("Rate limit must be a positive integer")
        
        # Validate access rules
        if "access_rules" in policy_data:
            access_rules = policy_data["access_rules"]
            if not isinstance(access_rules, dict):
                errors.append("Access rules must be a dictionary")
        
        return len(errors) == 0, errors

    def validate_constraint(self, constraint_data: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate constraint configuration."""
        errors = []
        
        # Validate max latency
        if "max_latency" in constraint_data:
            max_latency = constraint_data["max_latency"]
            if not isinstance(max_latency, (int, float)) or max_latency <= 0:
                errors.append("Max latency must be a positive number")
        
        # Validate min accuracy
        if "min_accuracy" in constraint_data:
            min_accuracy = constraint_data["min_accuracy"]
            if not isinstance(min_accuracy, (int, float)) or not (0 <= min_accuracy <= 1):
                errors.append("Min accuracy must be between 0 and 1")
        
        return len(errors) == 0, errors

    def validate_slo(self, slo_data: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate SLO configuration."""
        errors = []
        
        # Validate latency targets
        if "latency_p95" in slo_data:
            latency_p95 = slo_data["latency_p95"]
            if not isinstance(latency_p95, (int, float)) or latency_p95 <= 0:
                errors.append("Latency P95 must be a positive number")
        
        # Validate availability targets
        if "availability" in slo_data:
            availability = slo_data["availability"]
            if not isinstance(availability, (int, float)) or not (0 <= availability <= 100):
                errors.append("Availability must be between 0 and 100")
        
        return len(errors) == 0, errors

    def validate_tenant_settings(self, tenant_data: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate tenant settings configuration."""
        errors = []
        
        # Validate resource quotas
        if "resource_quotas" in tenant_data:
            quotas = tenant_data["resource_quotas"]
            if not isinstance(quotas, dict):
                errors.append("Resource quotas must be a dictionary")
            else:
                for key, value in quotas.items():
                    if not isinstance(value, (int, float)) or value <= 0:
                        errors.append(f"Resource quota {key} must be a positive number")
        
        return len(errors) == 0, errors
```

**Validation:**
- Configuration service implemented
- API endpoints created
- Validation logic implemented
- Error handling complete

---

### Task 15.4: Implement Frontend Dashboard

**Objective:** Create web-based UI for configuration management.

**Choice:** Use Streamlit (faster development, Python-based, integrates with FastAPI)

#### Step 4.1: Create Streamlit Dashboard Structure

**File:** `caio/dashboard/app.py`

**Dashboard Structure:**
```python
import streamlit as st
from caio.api.client import CAIOClient
from caio.services.configuration import ConfigType

# Page configuration
st.set_page_config(
    page_title="CAIO Configuration Dashboard",
    page_icon="⚙️",
    layout="wide",
)

# Initialize CAIO client
@st.cache_resource
def get_caio_client():
    return CAIOClient(base_url=st.secrets["CAIO_API_URL"])

client = get_caio_client()

# Sidebar navigation
st.sidebar.title("CAIO Configuration")
page = st.sidebar.selectbox(
    "Navigation",
    ["Overview", "Policies", "Constraints", "SLOs", "Tenants", "History"],
)

# Main content
if page == "Overview":
    show_overview(client)
elif page == "Policies":
    show_policies(client)
elif page == "Constraints":
    show_constraints(client)
elif page == "SLOs":
    show_slos(client)
elif page == "Tenants":
    show_tenants(client)
elif page == "History":
    show_history(client)
```

#### Step 4.2: Implement Configuration Forms

**File:** `caio/dashboard/forms.py`

**Form Functions:**
```python
def show_policy_form(client: CAIOClient, policy_id: Optional[str] = None):
    """Show policy configuration form."""
    st.header("Policy Configuration")
    
    # Form fields
    policy_name = st.text_input("Policy Name", value=policy_id or "")
    rate_limit = st.number_input("Rate Limit (requests/minute)", min_value=1, value=1000)
    access_rules = st.text_area("Access Rules (JSON)", value="{}")
    
    # Validation
    if st.button("Validate"):
        try:
            access_rules_dict = json.loads(access_rules)
            response = client.validate_configuration(
                config_type=ConfigType.POLICIES,
                config_data={
                    "name": policy_name,
                    "rate_limit": rate_limit,
                    "access_rules": access_rules_dict,
                },
            )
            if response.is_valid:
                st.success("Configuration is valid!")
            else:
                st.error(f"Validation errors: {response.errors}")
        except json.JSONDecodeError:
            st.error("Invalid JSON in access rules")
    
    # Save
    if st.button("Save"):
        try:
            access_rules_dict = json.loads(access_rules)
            if policy_id:
                client.update_configuration(
                    config_id=policy_id,
                    config_data={
                        "name": policy_name,
                        "rate_limit": rate_limit,
                        "access_rules": access_rules_dict,
                    },
                )
            else:
                client.create_configuration(
                    config_type=ConfigType.POLICIES,
                    config_data={
                        "name": policy_name,
                        "rate_limit": rate_limit,
                        "access_rules": access_rules_dict,
                    },
                )
            st.success("Configuration saved!")
        except Exception as e:
            st.error(f"Error saving configuration: {e}")
```

#### Step 4.3: Implement Configuration History View

**File:** `caio/dashboard/history.py`

**History View:**
```python
def show_history(client: CAIOClient):
    """Show configuration history."""
    st.header("Configuration History")
    
    # Filter options
    config_type = st.selectbox(
        "Configuration Type",
        ["All", "Policies", "Constraints", "SLOs", "Tenants"],
    )
    
    # Get history
    if config_type == "All":
        configs = client.list_configurations()
    else:
        configs = client.list_configurations(
            config_type=ConfigType(config_type.lower()),
        )
    
    # Display history
    for config in configs:
        with st.expander(f"{config.config_type} - {config.id}"):
            st.json(config.config_data)
            st.caption(f"Version: {config.version} | Updated: {config.updated_at} | By: {config.created_by}")
            
            # Rollback option
            if st.button(f"Rollback to version {config.version - 1}", key=f"rollback_{config.id}"):
                try:
                    client.rollback_configuration(
                        config_id=config.id,
                        version=config.version - 1,
                    )
                    st.success("Configuration rolled back!")
                except Exception as e:
                    st.error(f"Error rolling back: {e}")
```

**Validation:**
- Dashboard structure created
- Configuration forms implemented
- History view implemented
- Real-time validation working

---

### Task 15.5: Implement Real-Time Validation

**Objective:** Add real-time validation feedback to dashboard forms.

#### Step 5.1: Add Client-Side Validation

**File:** `caio/dashboard/validation.py`

**Client-Side Validation:**
```python
def validate_policy_form(policy_data: Dict[str, Any]) -> Tuple[bool, List[str]]:
    """Client-side validation for policy form."""
    errors = []
    
    if "rate_limit" in policy_data:
        if not isinstance(policy_data["rate_limit"], int) or policy_data["rate_limit"] <= 0:
            errors.append("Rate limit must be a positive integer")
    
    if "access_rules" in policy_data:
        try:
            json.loads(policy_data["access_rules"])
        except json.JSONDecodeError:
            errors.append("Access rules must be valid JSON")
    
    return len(errors) == 0, errors
```

#### Step 5.2: Add Server-Side Validation Integration

**Integration with API:**
```python
# In form submission
if st.button("Validate"):
    # Client-side validation
    is_valid, errors = validate_policy_form(form_data)
    if not is_valid:
        st.error(f"Validation errors: {errors}")
        return
    
    # Server-side validation
    response = client.validate_configuration(
        config_type=ConfigType.POLICIES,
        config_data=form_data,
    )
    if response.is_valid:
        st.success("Configuration is valid!")
    else:
        st.error(f"Server validation errors: {response.errors}")
```

**Validation:**
- Client-side validation implemented
- Server-side validation integrated
- Real-time feedback working

---

### Task 15.6: Implement Audit Trail

**Objective:** Track all configuration changes with user attribution.

#### Step 6.1: Integrate Audit Logging

**File:** `caio/services/audit.py`

**Audit Logging:**
```python
class ConfigurationAuditLogger:
    def log_configuration_change(
        self,
        configuration_id: str,
        change_type: ChangeType,
        old_value: Optional[Dict[str, Any]],
        new_value: Optional[Dict[str, Any]],
        changed_by: str,
        change_reason: Optional[str] = None,
    ):
        """Log configuration change to audit trail."""
        change = ConfigurationChange(
            id=str(uuid.uuid4()),
            configuration_id=configuration_id,
            change_type=change_type,
            old_value=old_value,
            new_value=new_value,
            changed_at=datetime.now(timezone.utc),
            changed_by=changed_by,
            change_reason=change_reason,
        )
        # Save to database
        self.db.save_configuration_change(change)
```

#### Step 6.2: Add Audit Trail View to Dashboard

**File:** `caio/dashboard/audit.py`

**Audit Trail View:**
```python
def show_audit_trail(client: CAIOClient):
    """Show audit trail of configuration changes."""
    st.header("Configuration Audit Trail")
    
    # Filter options
    config_id = st.selectbox("Configuration", ["All"] + [c.id for c in client.list_configurations()])
    change_type = st.selectbox("Change Type", ["All", "Create", "Update", "Delete"])
    
    # Get audit trail
    changes = client.get_audit_trail(
        config_id=config_id if config_id != "All" else None,
        change_type=change_type if change_type != "All" else None,
    )
    
    # Display audit trail
    for change in changes:
        with st.expander(f"{change.change_type} - {change.changed_at}"):
            st.write(f"**Changed by:** {change.changed_by}")
            st.write(f"**Reason:** {change.change_reason or 'N/A'}")
            if change.old_value:
                st.write("**Old Value:**")
                st.json(change.old_value)
            if change.new_value:
                st.write("**New Value:**")
                st.json(change.new_value)
```

**Validation:**
- Audit logging integrated
- Audit trail view implemented
- User attribution working

---

### Task 15.7: Create Documentation

**Objective:** Create comprehensive documentation for the dashboard.

#### Step 7.1: Create Dashboard User Guide

**File:** `docs/dashboard/USER_GUIDE.md`

**Sections:**
1. Getting Started
2. Configuration Types
3. Policy Configuration
4. Constraint Configuration
5. SLO Configuration
6. Tenant Management
7. Configuration History
8. Audit Trail
9. Best Practices
10. Troubleshooting

#### Step 7.2: Create Configuration API Reference

**File:** `docs/api/CONFIGURATION_API.md`

**Sections:**
1. Overview
2. Authentication
3. Endpoints
4. Request/Response Schemas
5. Error Handling
6. Examples

#### Step 7.3: Update Main Documentation

**Files to Update:**
- `README.md` - Add dashboard section
- `docs/api/API_REFERENCE.md` - Add configuration API endpoints

**Validation:**
- User guide complete
- API reference complete
- Main documentation updated

---

## Validation Procedures

### Unit Tests

**File:** `tests/unit/test_configuration_service.py`

**Test Cases:**
- Create configuration
- Get configuration
- Update configuration
- Delete configuration
- List configurations
- Get configuration history
- Rollback configuration
- Validate configuration

### Integration Tests

**File:** `tests/integration/test_configuration_api.py`

**Test Cases:**
- API endpoint authentication
- API endpoint authorization
- Configuration CRUD operations
- Configuration validation
- Configuration history
- Configuration rollback

### E2E Tests

**File:** `tests/e2e/test_configuration_dashboard.py`

**Test Cases:**
- Dashboard access
- Configuration form submission
- Real-time validation
- Configuration history view
- Audit trail view
- Role-based access

**Commands:**
```bash
# Run unit tests
pytest tests/unit/test_configuration_service.py -v

# Run integration tests
pytest tests/integration/test_configuration_api.py -v

# Run E2E tests
pytest tests/e2e/test_configuration_dashboard.py -v

# Run all tests
make test
```

---

## Success Criteria

**Dashboard Functionality:**
- [ ] Dashboard accessible via web browser
- [ ] All operational settings configurable via UI
- [ ] Real-time validation working
- [ ] Configuration changes saved correctly
- [ ] Configuration history viewable
- [ ] Audit trail tracks all changes
- [ ] Role-based access control working
- [ ] Configuration export/import functional

**API Functionality:**
- [ ] All configuration endpoints working
- [ ] Validation endpoints working
- [ ] Audit log endpoints working
- [ ] Error handling complete

**Documentation:**
- [ ] User guide complete
- [ ] API reference complete
- [ ] Main documentation updated

---

## Risks and Mitigation

**Risk 1: Configuration conflicts**
- **Mitigation:** Real-time validation prevents invalid configurations
- **Mitigation:** Version history enables rollback

**Risk 2: Security vulnerabilities**
- **Mitigation:** Role-based access control
- **Mitigation:** Audit trail for all changes
- **Mitigation:** Input validation and sanitization

**Risk 3: Performance issues**
- **Mitigation:** Database indexes on frequently queried fields
- **Mitigation:** Caching for configuration reads
- **Mitigation:** Pagination for large lists

---

## Rollback Plan

If dashboard causes issues:

1. **Disable dashboard access** (remove from ALB target group)
2. **Revert to API-only configuration** (existing functionality)
3. **Fix issues** in development environment
4. **Re-test** thoroughly
5. **Re-deploy** dashboard

---

## Notes and References

- **Streamlit Documentation:** https://docs.streamlit.io/
- **FastAPI Documentation:** https://fastapi.tiangolo.com/
- **PostgreSQL JSONB:** https://www.postgresql.org/docs/current/datatype-json.html
- **CAIO Master Calculus:** `docs/math/CAIO_MASTER_CALCULUS.md` - Mathematical coefficients are fixed
- **CAIO API Reference:** `docs/api/API_REFERENCE.md`

---

**Last Updated:** 2026-01-12
**Version:** 1.0
