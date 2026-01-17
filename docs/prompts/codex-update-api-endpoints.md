# CAIO Update API Endpoints Implementation

**Status:** Ready for Execution  
**Date:** 2026-01-15  
**Owner:** Codex  
**Plan Reference:** `plan:update-api-endpoints:19.7`
**Architecture Reference:** `docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md`

---

## Executive Summary

Implement the standardized update API endpoints required by the Update Mechanism Architecture. These endpoints enable TAI (and other host applications) to manage CAIO updates when embedded.

**Key Deliverables:**
1. `POST /api/v1/update` - Initiate update process
2. `POST /api/v1/restart` - Restart service after update
3. `GET /api/v1/version` - Get current running version
4. Update service implementation (download, verify, install)
5. Integration with existing CAIO API structure

**Estimated Time:** 2-3 days  
**Priority:** High (required for TAI integration)

---

## Context & Background

### Current State

- ✅ CAIO has health endpoint with version info (`/health`)
- ✅ FastAPI application structure exists (`caio/api/app.py`)
- ✅ Route registration pattern established
- ❌ Missing dedicated `/api/v1/version` endpoint
- ❌ Missing `/api/v1/update` endpoint
- ❌ Missing `/api/v1/restart` endpoint
- ❌ No update mechanism implementation

### North Star Alignment

- **Update & Lifecycle Management:** CAIO must support update mechanism per `UPDATE_MECHANISM_ARCHITECTURE.md`
- **Embedded Governance Role:** CAIO must be manageable by host applications (TAI)

**Reference:** `docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md` - Standard architecture for all services

---

## Step-by-Step Implementation Instructions

### Step 1: Create Update Service Module

**File:** `caio/update/__init__.py` (create directory if needed)

**File:** `caio/update/update_service.py`

**Implementation:**
```python
"""Update service for CAIO package updates."""

import json
import logging
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Optional

import httpx

logger = logging.getLogger(__name__)


class UpdateService:
    """Handles CAIO package updates."""
    
    def __init__(self, manifest_path: str = "manifest.json"):
        """Initialize update service."""
        self.manifest_path = Path(manifest_path)
        self._load_manifest()
        self.update_status: dict = {
            "status": "idle",
            "progress": 0,
            "message": "",
            "requires_restart": False,
            "error": None
        }
    
    def _load_manifest(self) -> None:
        """Load manifest.json."""
        if self.manifest_path.exists():
            with open(self.manifest_path) as f:
                self.manifest = json.load(f)
        else:
            self.manifest = {}
    
    async def download_update(self, target_version: Optional[str] = None) -> dict:
        """
        Download update package.
        
        Args:
            target_version: Specific version to download, or None for latest
            
        Returns:
            dict with download status
        """
        # Implementation: Download from update_url
        # 1. Get update_url from manifest.json
        # 2. Fetch latest release from GitHub API or update_url
        # 3. Download package (tar.gz or wheel)
        # 4. Save to temp directory
        # 5. Report progress
        
    async def verify_package(self, package_path: str) -> bool:
        """
        Verify package integrity.
        
        Args:
            package_path: Path to downloaded package
            
        Returns:
            True if verification passes
        """
        # Implementation: Verify checksums, signatures
        # 1. Check package checksum (SHA256)
        # 2. Verify signature if available
        # 3. Validate package structure
        # 4. Return True/False
        
    async def install_update(self, package_path: str) -> dict:
        """
        Install update package.
        
        Args:
            package_path: Path to verified package
            
        Returns:
            dict with installation status
        """
        # Implementation: Install update
        # 1. Backup current installation
        # 2. Extract package
        # 3. Replace files
        # 4. Run migrations if needed
        # 5. Update manifest.json version
        # 6. Report progress
        
    def get_update_status(self) -> dict:
        """Get current update status."""
        return self.update_status.copy()
```

**Key Requirements:**
- Download from GitHub releases API or `update_url` from manifest.json
- Support both specific version and "latest"
- Verify package integrity (checksums, signatures)
- Backup before installation
- Report progress (0-100%)
- Handle errors gracefully

### Step 2: Create Update API Routes

**File:** `caio/api/routes/update.py`

**Implementation:**
```python
"""Update API routes for CAIO."""

from typing import Optional
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel

from caio.api.middleware.auth import require_roles
from caio.update.update_service import UpdateService

router = APIRouter(prefix="/api/v1", tags=["Update"])

# Initialize update service (singleton)
_update_service = UpdateService()


class UpdateRequest(BaseModel):
    """Update request model."""
    target_version: Optional[str] = None


class UpdateResponse(BaseModel):
    """Update response model."""
    status: str  # "updating" | "complete" | "failed"
    progress: int  # 0-100
    message: str
    requires_restart: bool
    error: Optional[str] = None


class RestartRequest(BaseModel):
    """Restart request model."""
    graceful: bool = True


class RestartResponse(BaseModel):
    """Restart response model."""
    status: str  # "restarting" | "restarted" | "failed"
    message: str


class VersionResponse(BaseModel):
    """Version response model."""
    version: str
    build_date: str
    commit: str


@router.post("/update", response_model=UpdateResponse)
async def update_service(
    request: UpdateRequest,
    _actor=Depends(require_roles("admin")),
):
    """
    Initiate CAIO update process.
    
    Requires admin role.
    """
    try:
        # Start update process
        result = await _update_service.download_update(request.target_version)
        # ... implement full update flow
        return UpdateResponse(
            status="complete",
            progress=100,
            message="Update installed successfully",
            requires_restart=True
        )
    except Exception as e:
        return UpdateResponse(
            status="failed",
            progress=0,
            message="Update failed",
            requires_restart=False,
            error=str(e)
        )


@router.post("/restart", response_model=RestartResponse)
async def restart_service(
    request: RestartRequest,
    _actor=Depends(require_roles("admin")),
):
    """
    Restart CAIO after update.
    
    Requires admin role.
    """
    # Implementation: Graceful shutdown and restart
    # 1. Save state if needed
    # 2. Graceful shutdown if requested
    # 3. Restart process
    # 4. Verify new version is running
    pass


@router.get("/version", response_model=VersionResponse)
async def get_version():
    """
    Get current CAIO version.
    
    Public endpoint (no auth required).
    """
    # Implementation: Read from package metadata or manifest.json
    # 1. Read version from manifest.json
    # 2. Get build_date from package metadata or git
    # 3. Get commit hash from git
    pass
```

**Key Requirements:**
- `POST /api/v1/update` requires admin authentication
- `POST /api/v1/restart` requires admin authentication
- `GET /api/v1/version` is public (no auth)
- All endpoints match `UPDATE_MECHANISM_ARCHITECTURE.md` specification
- Error handling with clear messages

### Step 3: Register Routes in API App

**File:** `caio/api/app.py`

**Changes:**
1. Import update routes:
```python
from caio.api.routes.update import router as update_router
```

2. Register router in `register_routes()` function:
```python
# After other routers
app.include_router(update_router)
```

3. Verify routes are accessible:
- `POST /api/v1/update`
- `POST /api/v1/restart`
- `GET /api/v1/version`

### Step 4: Implement Update Download Logic

**In `UpdateService.download_update()`:**

1. **Get Update URL:**
   - Read `manifest.json`
   - Get `update_url` field
   - If `target_version` specified, construct version-specific URL
   - If not, fetch latest from GitHub releases API

2. **Download Package:**
   - Use `httpx` to download package
   - Save to temp directory
   - Report progress (0-50% during download)

3. **Handle Authentication:**
   - If private repo, use GitHub token from environment
   - Handle authentication errors gracefully

### Step 5: Implement Package Verification

**In `UpdateService.verify_package()`:**

1. **Checksum Verification:**
   - Download checksum file (SHA256)
   - Calculate package checksum
   - Compare with expected checksum

2. **Signature Verification (if available):**
   - Verify GPG signature if provided
   - Validate signature against public key

3. **Package Structure Validation:**
   - Verify package is valid Python package
   - Check required files exist

### Step 6: Implement Update Installation

**In `UpdateService.install_update()`:**

1. **Backup Current Installation:**
   - Create backup of current `caio/` package directory
   - Save to backup location

2. **Install Update:**
   - Extract package
   - Replace files in `caio/` directory
   - Run migrations if needed (future enhancement)

3. **Update Version:**
   - Update `manifest.json` version field
   - Update package metadata if needed

4. **Report Progress:**
   - Update progress (50-100% during installation)
   - Set `requires_restart = True` when complete

### Step 7: Implement Restart Mechanism

**In `update.py` route handler:**

1. **Graceful Shutdown:**
   - If `graceful=True`, save state, close connections
   - Wait for in-flight requests to complete
   - Stop FastAPI server gracefully

2. **Restart Process:**
   - Use systemd, supervisor, or subprocess restart
   - For embedded mode, signal parent process to restart
   - For standalone, use process manager

3. **Verify Restart:**
   - Wait for service to come back up
   - Check `/api/v1/version` to verify new version
   - Return restart status

### Step 8: Implement Version Endpoint

**In `update.py` route handler:**

1. **Read Version:**
   - Read from `manifest.json` (primary source)
   - Fallback to package metadata (`importlib.metadata`)
   - Fallback to hardcoded version

2. **Get Build Date:**
   - From package metadata if available
   - From git commit date if available
   - Fallback to current date

3. **Get Commit Hash:**
   - From git if available
   - From environment variable if set
   - Fallback to "unknown"

### Step 9: Error Handling & Rollback

**Error Scenarios:**

1. **Download Fails:**
   - Network error → Retry with exponential backoff
   - Authentication error → Clear error message
   - Invalid URL → Clear error message

2. **Verification Fails:**
   - Checksum mismatch → Clear error, don't install
   - Signature invalid → Clear error, don't install

3. **Installation Fails:**
   - File permissions → Clear error, rollback from backup
   - Disk space → Clear error, rollback from backup
   - Package corruption → Clear error, rollback from backup

4. **Restart Fails:**
   - Process won't start → Clear error, keep old version running
   - Version mismatch → Clear error, manual restart required

**Rollback Implementation:**
- Restore from backup if installation fails
- Keep previous version running if restart fails
- Clear error messages for troubleshooting

### Step 10: Add Unit Tests

**File:** `tests/api/test_update_routes.py`

**Test Cases:**
- Update endpoint requires admin auth
- Restart endpoint requires admin auth
- Version endpoint is public
- Update flow (download → verify → install)
- Error handling scenarios
- Rollback on failure

### Step 11: Integration Testing

**Manual Testing:**
1. Start CAIO server
2. Call `POST /api/v1/update` with admin auth
3. Monitor progress
4. Verify update completes
5. Call `POST /api/v1/restart`
6. Verify service restarts with new version
7. Call `GET /api/v1/version` to confirm

---

## Validation Procedures

### Testing Commands

```bash
# Run unit tests
pytest tests/api/test_update_routes.py -v

# Run integration tests
pytest tests/integration/test_update_flow.py -v

# Manual testing
# 1. Start CAIO: python -m caio.main
# 2. Test endpoints with curl or Postman
```

### Success Verification

- [ ] `POST /api/v1/update` endpoint exists and requires admin auth
- [ ] `POST /api/v1/restart` endpoint exists and requires admin auth
- [ ] `GET /api/v1/version` endpoint exists and is public
- [ ] Update service downloads packages correctly
- [ ] Update service verifies packages correctly
- [ ] Update service installs updates correctly
- [ ] Restart mechanism works
- [ ] Error handling works (clear error messages)
- [ ] Rollback works on failure
- [ ] All endpoints match `UPDATE_MECHANISM_ARCHITECTURE.md` spec
- [ ] Unit tests pass
- [ ] Integration tests pass

---

## Troubleshooting

### Common Issues

**Issue:** Update download fails with 404
**Solution:** Verify `update_url` in manifest.json is correct, check GitHub releases exist

**Issue:** Package verification fails
**Solution:** Ensure checksums are correct, verify signature if using GPG

**Issue:** Installation fails with permission error
**Solution:** Check file permissions, ensure CAIO has write access to package directory

**Issue:** Restart doesn't work
**Solution:** Check process manager (systemd/supervisor), verify restart script works

---

## Notes

- Follow notebook-first development if this involves mathematical guarantees
- Update endpoints should be admin-only (require `require_roles("admin")`)
- Consider using background tasks for long-running updates (FastAPI BackgroundTasks)
- Progress reporting can be via polling (client polls status) or streaming (SSE/WebSocket)
- Restart mechanism depends on deployment (systemd, supervisor, Docker, embedded)
- For embedded mode, restart may need to signal parent process (TAI) to restart CAIO

---

## Related Documents

- `docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md` - Standard architecture
- `docs/operations/EXECUTION_PLAN.md` - Execution plan
- `docs/NORTH_STAR.md` - North Star vision
- `manifest.json` - CAIO manifest file
- `plans/update-api-endpoints/update-api-endpoints.md` - Detailed plan

---

**Last Updated:** 2026-01-15  
**Version:** 1.0
