# Update Mechanism Architecture

**Status:** Standard Architecture Document  
**Version:** 1.0  
**Last Updated:** 2026-01-15  
**Applies To:** TAI, CAIO, MAIA, NME, RFS, VFE, VEE

---

## Overview

This document defines the standardized update mechanism architecture for all services in the TAI ecosystem. It describes how services manage updates when running standalone versus when embedded in TAI, and how TAI acts as a centralized update manager for embedded services.

**CAIO Context:** CAIO is the Universal AI Orchestration Platform and serves as TAI's embedded governance kernel. CAIO is always embedded in TAI and never runs standalone, but must still implement the standard update mechanism for TAI to manage its updates.

---

## Core Principles

### 1. **Service Independence**
- Each service (CAIO, VFE, RFS, MAIA, NME, VEE) maintains its own update mechanism
- Services can be updated independently when running standalone
- Services expose standardized update APIs for integration

### 2. **Centralized Management (Embedded Mode)**
- When embedded in TAI, TAI acts as the central update manager
- TAI detects updates for all embedded services
- TAI orchestrates sequential updates to avoid conflicts
- TAI provides unified UI for update notifications and execution

### 3. **User Control**
- Users are always notified of available updates
- Users must explicitly approve updates (no auto-updates)
- Users control when services restart after updates
- Clear progress feedback during update process

---

## Architecture Pattern

### Standalone Mode

```
Service (CAIO/VFE/RFS/etc.)
├── Exposes manifest.json (version, update_url)
├── Has own update mechanism
├── Shows update notifications in own UI
└── User updates directly through service UI
```

### Embedded Mode (CAIO's Primary Mode)

```
TAI (Central Manager)
├── Polls embedded services' manifest.json
├── Detects updates via UpdateManager
├── Shows unified update notifications in TAI UI
├── Calls service update API when user approves
├── Manages sequential updates (one at a time)
└── Handles restart notifications (user-controlled)
```

**Note:** CAIO is always embedded in TAI, so all CAIO updates flow through TAI's update management UI.

---

## Service Responsibilities

### Required: Manifest File

CAIO **MUST** expose a `manifest.json` file at the repository root:

```json
{
  "name": "caio",
  "version": "0.1.0",
  "update_url": "https://api.github.com/repos/smarthaus/CAIO/releases/latest",
  "manifest_url": "https://raw.githubusercontent.com/smarthaus/CAIO/main/manifest.json"
}
```

**Fields:**
- `name`: Service identifier ("caio")
- `version`: Current version (semantic versioning)
- `update_url`: URL to fetch latest release/update information
- `manifest_url`: URL to fetch remote manifest for version comparison

**PyPI Package Reference:**
- CAIO is published to PyPI as `smarthaus-caio` (install via `pip install smarthaus-caio`).

### Required: Update API Endpoints

CAIO **MUST** expose the following REST API endpoints when running:

#### `POST /api/v1/update`

Initiates the update process for CAIO.

**Request:**
```json
{
  "target_version": "0.1.1"  // Optional: specific version, or omit for "latest"
}
```

**Response (Streaming or Polling):**
```json
{
  "status": "updating" | "complete" | "failed",
  "progress": 50,  // 0-100 percentage
  "message": "Downloading update package...",
  "requires_restart": true,
  "error": null  // Only present if status is "failed"
}
```

**Implementation Requirements:**
- CAIO downloads update package from `update_url`
- CAIO verifies package integrity (checksums, signatures)
- CAIO installs update (replaces files, runs migrations if needed)
- CAIO reports progress via status updates
- CAIO indicates if restart is required

#### `POST /api/v1/restart`

Restarts CAIO after an update.

**Request:**
```json
{
  "graceful": true  // Optional: graceful shutdown vs immediate
}
```

**Response:**
```json
{
  "status": "restarting" | "restarted" | "failed",
  "message": "CAIO restarting..."
}
```

**Implementation Requirements:**
- CAIO performs graceful shutdown if requested
- CAIO restarts with new version
- CAIO verifies it's running the updated version
- CAIO reports restart status

#### `GET /api/v1/version`

Returns the current running version of CAIO.

**Response:**
```json
{
  "version": "0.1.0",
  "build_date": "2026-01-14T10:30:00Z",
  "commit": "abc123def456"
}
```

---

## TAI's Central Manager Role

### UpdateManager Responsibilities

TAI's `UpdateManager` class handles:

1. **Update Detection**
   - Polls each embedded service's `manifest.json`
   - Compares local vs remote versions
   - Identifies services with available updates

2. **Update Execution**
   - Calls `POST /api/v1/update` for each service sequentially
   - Monitors progress and reports to UI
   - Handles errors and rollback if needed

3. **Restart Management**
   - Notifies user when restart is required
   - Calls `POST /api/v1/restart` when user approves
   - Verifies service is running updated version

### Update Flow (CAIO Embedded in TAI)

```
1. TAI polls CAIO manifest.json
   ↓
2. TAI detects version mismatch
   ↓
3. TAI shows notification: "Update available for CAIO"
   ↓
4. User clicks "Update CAIO" in TAI UI
   ↓
5. TAI calls: POST http://localhost:8003/api/v1/update
   ↓
6. CAIO downloads/installs update
   ↓
7. CAIO returns: {"status": "complete", "requires_restart": true}
   ↓
8. TAI shows: "CAIO updated. Restart required."
   ↓
9. User clicks "Restart CAIO"
   ↓
10. TAI calls: POST http://localhost:8003/api/v1/restart
   ↓
11. CAIO restarts with new version
   ↓
12. TAI verifies: GET /api/v1/version confirms new version
```

### Sequential Update Queue

TAI updates services **one at a time** to avoid:
- Resource conflicts
- Network bandwidth contention
- Installation conflicts
- Confusing user with multiple progress indicators

**Update Order:**
1. TAI Core (if TAI itself needs updating)
2. CAIO (governance kernel - always embedded)
3. Licensed services (VFE, RFS, MAIA, NME, VEE) in order of activation

---

## Implementation Requirements

### For CAIO

1. **Maintain `manifest.json`** at repository root (already exists)
2. **Implement update API endpoints** (`/api/v1/update`, `/api/v1/restart`, `/api/v1/version`)
3. **Implement update mechanism**:
   - Download update package
   - Verify integrity
   - Install update
   - Report progress
4. **Maintain PyPI distribution metadata**:
   - Publish releases under `smarthaus-caio`
   - Keep update instructions aligned with `pip install smarthaus-caio`
5. **Handle restart gracefully**:
   - Save state if needed
   - Graceful shutdown
   - Restart with new version
6. **Update version in manifest.json** after successful update

### Integration with TAI

- CAIO updates are always managed through TAI's UI
- TAI's `CAIOManager` coordinates with update process
- CAIO restart after update uses TAI's lifecycle management

---

## Best Practices

### Security

- **Verify update packages**: Use checksums and signatures
- **HTTPS only**: All update URLs must use HTTPS
- **Authenticated updates**: Require authentication for update API calls
- **Rollback capability**: CAIO should support rollback on failure

### User Experience

- **Clear notifications**: Explain what will be updated and why
- **Progress feedback**: Show download/install progress
- **Error handling**: Clear error messages if update fails
- **Restart control**: Always require user approval for restart

### Reliability

- **Sequential updates**: Never update multiple services simultaneously
- **Health checks**: Verify CAIO is healthy before/after update
- **Version verification**: Confirm CAIO is running updated version
- **Graceful degradation**: CAIO should continue working if update fails

### Testing

- **Update testing**: Test update mechanism in staging environment
- **Rollback testing**: Verify rollback works if update fails
- **Integration testing**: Test TAI's update orchestration with CAIO
- **Version compatibility**: Test updates don't break service contracts

---

## Reference Implementation

### CAIO Update API Example

```python
# caio/api/routes/update.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

class UpdateRequest(BaseModel):
    target_version: str | None = None

class UpdateResponse(BaseModel):
    status: str  # "updating" | "complete" | "failed"
    progress: int  # 0-100
    message: str
    requires_restart: bool
    error: str | None = None

@router.post("/api/v1/update", response_model=UpdateResponse)
async def update_service(request: UpdateRequest):
    """Initiate CAIO update."""
    try:
        # 1. Fetch update package
        # 2. Verify integrity
        # 3. Install update
        # 4. Report progress
        return UpdateResponse(
            status="complete",
            progress=100,
            message="CAIO update installed successfully",
            requires_restart=True
        )
    except Exception as e:
        return UpdateResponse(
            status="failed",
            progress=0,
            message="CAIO update failed",
            requires_restart=False,
            error=str(e)
        )
```

---

## Version History

- **v1.0 (2026-01-14)**: Initial architecture document

---

## Related Documents

- `docs/operations/EXECUTION_PLAN.md` - CAIO execution plan
- `docs/NORTH_STAR.md` - CAIO vision and goals
- `manifest.json` - CAIO manifest file

---

**This document is MANDATORY. CAIO must implement the update mechanism as described here for TAI to manage its updates.**
