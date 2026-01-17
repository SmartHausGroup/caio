# CAIO Production Readiness Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-07  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:production-readiness`

---

## Executive Summary

CAIO is mathematically validated (GREEN scorecard, 58/58 tests passing) and functionally complete (all 8 phases done), but requires production hardening before deployment. This plan addresses 10 critical gaps across configuration, security, deployment, and code quality.

**CRITICAL:** This plan follows **notebook-first development** and **MA Doc-First methodology**. ALL code changes must be made in notebooks first, tested/validated there, then extracted to Python files. NO direct Python file edits are allowed.

**Estimated Time:** 3-4 hours  
**Priority:** High (blocks production deployment)

---

## Context & Background

### Current State

- ✅ **Mathematical Validation:** GREEN scorecard (12/12 invariants passing)
- ✅ **Test Suite:** 58/58 tests passing
- ✅ **Code Implementation:** All 8 phases complete
- ✅ **Documentation:** North Star, math, runbooks complete
- ⚠️ **Production Readiness:** 10 gaps identified

### Target State

- ✅ Production-ready API application with proper exports
- ✅ Secure CORS configuration (environment-based)
- ✅ No deprecation warnings
- ✅ Containerized deployment (Dockerfile)
- ✅ Production configuration management
- ✅ Production deployment documentation
- ✅ Environment variable management
- ✅ Production logging configuration
- ✅ Health check validation
- ✅ Production-ready error handling

---

## North Star Alignment

**Alignment Check:** ✅ **ALIGNED**

This work aligns with CAIO's North Star:
- **Mathematical Guarantees:** Maintains all invariants (no changes to math)
- **Security Built into Math:** Fixes CORS security gap
- **Provability & Traceability:** Enhances production observability
- **Universal Compatibility:** Makes CAIO deployable in any environment

**Reference:** `docs/NORTH_STAR.md` - Security Calculus, Deployment Envelopes & SLOs

---

## Execution Plan Reference

**Plan Reference:** `plan:EXECUTION_PLAN:production-readiness`

This work addresses production deployment requirements that are implicit in Phase 8 (Security & Traceability Operations) but not explicitly documented. It completes the production readiness checklist.

---

## MANDATORY: Notebook-First Development Workflow

**CRITICAL RULE:** ALL code changes MUST follow this workflow:

1. **Find or Create Notebook:**
   - Identify which notebook contains the code (or create new one)
   - Notebooks are the source of truth for implementation code

2. **Update Code in Notebook:**
   - Write code DIRECTLY in notebook cells
   - **NEVER import from codebase** (e.g., `from caio.api.app import create_app`)
   - Copy implementation code into notebook if needed
   - Test and validate in notebook

3. **Test in Notebook:**
   - Run notebook cells to verify code works
   - Ensure all assertions pass
   - Verify invariants still pass (if applicable)

4. **Extract Code from Notebook:**
   ```bash
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/<notebook>.ipynb \
       --output caio/<module>.py \
       --functions <function_name> \
       --classes <class_name>
   ```

5. **Verify Extraction:**
   - Check that Python file matches notebook code
   - Run tests to ensure extracted code works
   - Run notebook again to ensure it still passes

**FORBIDDEN:**
- ❌ Direct edits to Python files in `caio/` directory
- ❌ Importing from codebase into notebooks
- ❌ Skipping notebook validation before extraction

**Reference:** `.cursor/rules/notebook-first-mandatory.mdc` for complete rules

---

## MA Process Check

**Question:** Do these changes require MA process (Math → Invariants → Code)?

**Answer:** ❌ **NO** - These are production hardening changes that:
- Do not change mathematical operations or algorithms
- Do not affect performance guarantees
- Do not modify invariants or lemmas
- Are configuration, deployment, and code quality improvements

**Exception:** If any change affects mathematical guarantees or invariants, STOP and complete MA process first.

---

## Gap Analysis

### Gap 1: API App Export Pattern

**Issue:** `caio/api/app.py` has `create_app()` factory but no direct `app` export.

**Current Code:**
```python
def create_app() -> FastAPI:
    # ... creates and configures app
    return app
```

**Problem:** Deployment scripts expect `from caio.api.app import app`, but only `create_app` exists.

**Impact:** Deployment scripts will fail or need modification.

**Notebook:** `notebooks/math/api_app.ipynb`

**Fix Required:**
- Update notebook to add `app = create_app()` at module level
- Extract to `caio/api/app.py`
- Verify imports work: `from caio.api.app import app`

---

### Gap 2: CORS Configuration Security

**Issue:** CORS middleware allows all origins (`allow_origins=["*"]`) with a TODO comment.

**Current Code:**
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to specific origins
    # ...
)
```

**Problem:** Security risk - allows any origin to make requests.

**Impact:** Production security vulnerability.

**Notebook:** `notebooks/math/api_app.ipynb`

**Fix Required:**
- Update notebook to read `CAIO_CORS_ORIGINS` environment variable
- Default to `["*"]` in development, require explicit origins in production
- Extract to `caio/api/app.py`

---

### Gap 3: Deprecation Warnings (datetime.utcnow)

**Issue:** 6 instances of deprecated `datetime.utcnow()` causing 16 deprecation warnings.

**Locations:**
1. `caio/api/routes/audit.py:89` → `notebooks/ops/traceability_audit.ipynb`
2. `caio/traceability/storage.py:76` → `notebooks/math/traceability.ipynb`
3. `caio/api/routes/orchestrate.py:78` → `notebooks/math/api_routes.ipynb`
4. `caio/api/routes/orchestrate.py:105` → `notebooks/math/api_routes.ipynb`
5. `caio/monitoring/alerts.py:25` → `notebooks/ops/slos_alerts.ipynb`
6. `caio/api/routes/trace.py:44` → `notebooks/math/api_routes.ipynb`

**Problem:** `datetime.utcnow()` is deprecated in Python 3.12+ and will be removed.

**Impact:** Future Python compatibility issues, test warnings.

**Notebooks to Update:**
- `notebooks/ops/traceability_audit.ipynb`
- `notebooks/math/traceability.ipynb`
- `notebooks/math/api_routes.ipynb`
- `notebooks/ops/slos_alerts.ipynb`

**Fix Required:**
- Replace all `datetime.utcnow()` with `datetime.now(timezone.utc)`
- Add `from datetime import timezone` where needed
- Extract to respective Python files

---

### Gap 4: Missing Dockerfile

**Issue:** No `Dockerfile` exists for containerized deployment.

**Problem:** No standard way to containerize CAIO for production.

**Impact:** Cannot deploy in containerized environments (Kubernetes, Docker Compose, etc.).

**Fix Required:**
- Create `Dockerfile` directly (notebook-first doesn't apply to infrastructure files)
- Create `.dockerignore` directly
- Document in deployment guide

---

### Gap 5: Missing Production Configuration Management

**Issue:** No environment-based configuration system.

**Problem:** Hardcoded values, no way to configure for different environments.

**Impact:** Cannot deploy to staging/production with different configs.

**Notebook:** Create `notebooks/ops/config_management.ipynb`

**Fix Required:**
- Create new notebook with configuration module
- Implement `CAIOConfig` class using `pydantic-settings`
- Test configuration loading in notebook
- Extract to `caio/config.py`
- Update `caio/api/app.py` notebook to use config

---

### Gap 6: Missing Production Deployment Documentation

**Issue:** README shows development setup but no production deployment guide.

**Problem:** No clear instructions for deploying CAIO in production.

**Impact:** Operators don't know how to deploy safely.

**Fix Required:**
- Create `docs/deployment/PRODUCTION_DEPLOYMENT.md` directly (documentation)
- Update `README.md` to link to deployment guide

---

### Gap 7: Missing Environment Variable Management

**Issue:** No centralized environment variable documentation or validation.

**Problem:** Operators don't know what environment variables are needed.

**Impact:** Deployment failures due to missing variables.

**Fix Required:**
- Create `docs/deployment/ENVIRONMENT_VARIABLES.md` directly (documentation)
- Create `.env.example` directly (configuration template)
- Add validation in config notebook (Gap 5)

---

### Gap 8: Missing Production Logging Configuration

**Issue:** No production logging configuration (structured logging, log levels, etc.).

**Problem:** Logs may not be suitable for production monitoring.

**Impact:** Difficult to debug production issues, poor observability.

**Notebook:** Create `notebooks/ops/logging_config.ipynb`

**Fix Required:**
- Create new notebook with logging configuration
- Implement structured JSON logging for production
- Test logging in notebook
- Extract to `caio/logging_config.py`
- Update `caio/api/app.py` notebook to use logging config

---

### Gap 9: Missing Health Check Endpoint Validation

**Issue:** Health check endpoint exists but may not validate all critical components.

**Problem:** Health check may report healthy when critical components are down.

**Impact:** False positives in health monitoring.

**Notebook:** `notebooks/math/api_routes.ipynb` (health route)

**Fix Required:**
- Update notebook to add component validation
- Test health endpoint in notebook
- Extract to `caio/api/routes/health.py`

---

### Gap 10: Missing Production-Ready Error Handling

**Issue:** Error handling may not be production-ready (error messages, status codes, etc.).

**Problem:** May leak sensitive information or not handle errors gracefully.

**Impact:** Security risks, poor user experience.

**Notebook:** `notebooks/math/api_app.ipynb` (error handlers)

**Fix Required:**
- Update notebook to review and improve error handlers
- Test error handling in notebook
- Extract to `caio/api/app.py`

---

## Step-by-Step Implementation Instructions

### Step 1: Fix API App Export Pattern (Notebook-First)

**Notebook:** `notebooks/math/api_app.ipynb`

**Action:**
1. Open `notebooks/math/api_app.ipynb`
2. Find the `create_app()` function definition
3. Add a new cell after `create_app()` definition:
   ```python
   # Create default app instance for direct import
   app = create_app()
   ```
4. Add docstring explaining the pattern
5. **Test in notebook:**
   ```python
   # Test that app is created
   assert app is not None
   assert hasattr(app, 'get')
   print("✅ App instance created successfully")
   ```
6. **Extract to Python file:**
   ```bash
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_app.ipynb \
       --output caio/api/app.py \
       --functions create_app \
       --variables app
   ```
7. **Verify extraction:**
   ```bash
   python -c "from caio.api.app import app; print('OK')"
   ```

**Validation:**
```bash
python -c "from caio.api.app import app; print('OK')"
```

---

### Step 2: Fix CORS Configuration (Notebook-First)

**Notebook:** `notebooks/math/api_app.ipynb`

**Action:**
1. Open `notebooks/math/api_app.ipynb`
2. Find the CORS middleware configuration in `create_app()`
3. **Update notebook to add environment variable reading:**
   ```python
   import os
   
   # Read CORS origins from environment
   cors_origins_str = os.getenv("CAIO_CORS_ORIGINS", "*")
   cors_origins = [origin.strip() for origin in cors_origins_str.split(",")]
   
   # Security check: production must specify origins
   if cors_origins == ["*"] and os.getenv("CAIO_ENV") == "production":
       raise ValueError(
           "CAIO_CORS_ORIGINS must be set in production. "
           "Cannot use wildcard '*' in production environment."
       )
   ```
4. Update CORS middleware to use `cors_origins` variable
5. **Test in notebook:**
   ```python
   # Test with default (development)
   import os
   os.environ.pop("CAIO_CORS_ORIGINS", None)
   os.environ.pop("CAIO_ENV", None)
   test_app = create_app()
   assert test_app is not None
   print("✅ CORS default (development) works")
   
   # Test with specific origins
   os.environ["CAIO_CORS_ORIGINS"] = "http://localhost:3000,http://localhost:8080"
   test_app2 = create_app()
   assert test_app2 is not None
   print("✅ CORS with specific origins works")
   
   # Test production security check
   os.environ["CAIO_ENV"] = "production"
   os.environ.pop("CAIO_CORS_ORIGINS", None)
   try:
       create_app()
       assert False, "Should have raised ValueError"
   except ValueError as e:
       assert "CAIO_CORS_ORIGINS" in str(e)
       print("✅ Production security check works")
   ```
6. **Extract to Python file:**
   ```bash
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_app.ipynb \
       --output caio/api/app.py \
       --functions create_app
   ```
7. **Verify extraction:**
   ```bash
   export CAIO_CORS_ORIGINS="http://localhost:3000"
   python -c "from caio.api.app import create_app; app = create_app(); print('OK')"
   ```

**Validation:**
- Test with `CAIO_CORS_ORIGINS="http://localhost:3000,http://localhost:8080"`
- Test with `CAIO_ENV=production` and no `CAIO_CORS_ORIGINS` (should fail)

---

### Step 3: Fix Deprecation Warnings (Notebook-First)

**Notebooks to Update:**
1. `notebooks/ops/traceability_audit.ipynb` → `caio/api/routes/audit.py`
2. `notebooks/math/traceability.ipynb` → `caio/traceability/storage.py`
3. `notebooks/math/api_routes.ipynb` → `caio/api/routes/orchestrate.py`, `caio/api/routes/trace.py`
4. `notebooks/ops/slos_alerts.ipynb` → `caio/monitoring/alerts.py`

**Action for Each Notebook:**

1. **Open notebook** (e.g., `notebooks/ops/traceability_audit.ipynb`)
2. **Find all `datetime.utcnow()` calls:**
   - Search for `datetime.utcnow()` in notebook
3. **Update imports:**
   ```python
   from datetime import datetime, timezone
   ```
4. **Replace all instances:**
   ```python
   # Before
   timestamp = datetime.utcnow().isoformat()
   
   # After
   timestamp = datetime.now(timezone.utc).isoformat()
   ```
5. **Test in notebook:**
   ```python
   # Verify timezone-aware datetime
   from datetime import datetime, timezone
   dt = datetime.now(timezone.utc)
   assert dt.tzinfo is not None
   assert dt.tzinfo == timezone.utc
   iso_str = dt.isoformat()
   assert "Z" in iso_str or "+00:00" in iso_str
   print("✅ Timezone-aware datetime works")
   ```
6. **Extract to Python file:**
   ```bash
   # For traceability_audit.ipynb
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/ops/traceability_audit.ipynb \
       --output caio/api/routes/audit.py \
       --functions get_audit_traces get_audit_proofs get_audit_violations
   
   # For traceability.ipynb
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/traceability.ipynb \
       --output caio/traceability/storage.py \
       --classes Traceability \
       --functions store_trace get_trace
   
   # For api_routes.ipynb
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/orchestrate.py \
       --functions orchestrate_endpoint
   
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/trace.py \
       --functions trace_endpoint
   
   # For slos_alerts.ipynb
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/ops/slos_alerts.ipynb \
       --output caio/monitoring/alerts.py \
       --functions check_slos send_alert
   ```
7. **Verify extraction:**
   ```bash
   pytest tests/ -v  # Should show 0 deprecation warnings
   ```

**Validation:**
```bash
pytest tests/ -v  # Should show 0 deprecation warnings
```

---

### Step 4: Create Dockerfile (Direct File Creation)

**Files:** `Dockerfile`, `.dockerignore`

**Action:**
1. Create `Dockerfile`:
   ```dockerfile
   FROM python:3.11-slim

   WORKDIR /app

   # Install dependencies
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt

   # Install FastAPI and uvicorn for production
   RUN pip install --no-cache-dir fastapi uvicorn[standard]

   # Copy CAIO code
   COPY caio/ ./caio/
   COPY configs/ ./configs/
   COPY invariants/ ./invariants/

   # Expose API port
   EXPOSE 8080

   # Health check
   HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
     CMD python -c "import requests; requests.get('http://localhost:8080/health')"

   # Run API
   CMD ["uvicorn", "caio.api.app:app", "--host", "0.0.0.0", "--port", "8080"]
   ```

2. Create `.dockerignore`:
   ```
   __pycache__/
   *.pyc
   *.pyo
   *.pyd
   .venv/
   venv/
   .git/
   .gitignore
   *.md
   tests/
   notebooks/
   logs/
   .pytest_cache/
   htmlcov/
   site/
   ```

**Validation:**
```bash
docker build -t caio:latest .
docker run -p 8080:8080 caio:latest
curl http://localhost:8080/health
```

---

### Step 5: Create Production Configuration Management (Notebook-First)

**Notebook:** Create `notebooks/ops/config_management.ipynb`

**Action:**
1. **Create new notebook:** `notebooks/ops/config_management.ipynb`
2. **Write configuration module in notebook:**
   ```python
   """
   CAIO Production Configuration Management
   
   Environment-based configuration using pydantic-settings.
   """
   
   from pydantic_settings import BaseSettings, SettingsConfigDict
   from typing import List, Optional
   
   class CAIOConfig(BaseSettings):
       """CAIO configuration loaded from environment variables."""
       
       # API Settings
       api_host: str = "0.0.0.0"
       api_port: int = 8080
       cors_origins: str = "*"
       env: str = "development"
       
       # Security Settings
       auth_secret_key: str = ""  # Required in production
       auth_algorithm: str = "HS256"
       
       # Logging
       log_level: str = "INFO"
       log_format: str = "json"  # json or text
       
       model_config = SettingsConfigDict(env_prefix="CAIO_", case_sensitive=False)

       def cors_origin_list(self) -> List[str]:
           origins = [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]
           return origins or ["*"]
       
       def validate_production(self) -> None:
           """Validate required settings for production."""
           if self.env == "production":
               if not self.auth_secret_key:
                   raise ValueError("CAIO_AUTH_SECRET_KEY is required in production")
               if self.cors_origin_list() == ["*"]:
                   raise ValueError("CAIO_CORS_ORIGINS must be set in production (cannot use '*')")
   ```
3. **Test in notebook:**
   ```python
   # Test default configuration
   config = CAIOConfig()
   assert config.api_host == "0.0.0.0"
   assert config.api_port == 8080
   assert config.env == "development"
   print("✅ Default configuration works")
   
   # Test production validation
   import os
   os.environ["CAIO_ENV"] = "production"
   os.environ["CAIO_AUTH_SECRET_KEY"] = "test-secret"
   os.environ["CAIO_CORS_ORIGINS"] = "http://localhost:3000"
   prod_config = CAIOConfig()
   prod_config.validate_production()
   print("✅ Production configuration validation works")
   ```
4. **Extract to Python file:**
   ```bash
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/ops/config_management.ipynb \
       --output caio/config.py \
       --classes CAIOConfig
   ```
5. **Update `notebooks/math/api_app.ipynb` to use config:**
   - Import `CAIOConfig` in notebook
   - Use config for CORS origins, API host/port
   - Extract updated `api_app.ipynb` to `caio/api/app.py`
6. **Verify extraction:**
   ```bash
   python -c "from caio.config import CAIOConfig; c = CAIOConfig(); print('OK')"
   ```

**Validation:**
- Test with missing required variables (should fail)
- Test with all variables set (should work)

---

### Step 6: Create Production Deployment Documentation (Direct File Creation)

**Files:** `docs/deployment/PRODUCTION_DEPLOYMENT.md`

**Action:**
1. Create `docs/deployment/` directory if it doesn't exist
2. Create `docs/deployment/PRODUCTION_DEPLOYMENT.md`:
   ```markdown
   # CAIO Production Deployment Guide
   
   ## Prerequisites
   - Python 3.11+ (or 3.14+)
   - Docker (optional, for containerized deployment)
   - Environment variables configured
   
   ## Quick Start
   [Deployment steps]
   
   ## Configuration
   [Environment variables, config files]
   
   ## Docker Deployment
   [Docker commands, docker-compose example]
   
   ## Health Checks
   [Health check endpoints, monitoring]
   
   ## Security
   [Security considerations, best practices]
   
   ## Troubleshooting
   [Common issues and solutions]
   ```
3. Update `README.md` to link to deployment guide

**Validation:**
- Documentation is complete and accurate
- All links work

---

### Step 7: Create Environment Variable Documentation (Direct File Creation)

**Files:** `docs/deployment/ENVIRONMENT_VARIABLES.md`, `.env.example`

**Action:**
1. Create `docs/deployment/ENVIRONMENT_VARIABLES.md`:
   - List all environment variables
   - Required vs optional
   - Default values
   - Example values
   - Security notes

2. Create `.env.example`:
   ```
   # CAIO Production Configuration
   CAIO_ENV=production
   CAIO_API_HOST=0.0.0.0
   CAIO_API_PORT=8080
   CAIO_CORS_ORIGINS=http://localhost:3000,http://localhost:8080
   CAIO_AUTH_SECRET_KEY=your-secret-key-here
   CAIO_LOG_LEVEL=INFO
   CAIO_LOG_FORMAT=json
   ```

**Validation:**
- Documentation is complete
- `.env.example` has all required variables

---

### Step 8: Create Production Logging Configuration (Notebook-First)

**Notebook:** Create `notebooks/ops/logging_config.ipynb`

**Action:**
1. **Create new notebook:** `notebooks/ops/logging_config.ipynb`
2. **Write logging configuration in notebook:**
   ```python
   """
   CAIO Production Logging Configuration
   
   Structured JSON logging for production, text logging for development.
   """
   
   import logging
   import json
   from datetime import datetime, timezone
   from typing import Any, Dict
   
   class JsonFormatter(logging.Formatter):
       """JSON formatter for structured logging."""
       
       def format(self, record: logging.LogRecord) -> str:
           log_data: Dict[str, Any] = {
               "timestamp": datetime.now(timezone.utc).isoformat(),
               "level": record.levelname,
               "logger": record.name,
               "message": record.getMessage(),
           }
           if record.exc_info:
               log_data["exception"] = self.formatException(record.exc_info)
           return json.dumps(log_data)
   
   def setup_logging(log_level: str = "INFO", log_format: str = "json") -> None:
       """Setup logging configuration."""
       level = getattr(logging, log_level.upper(), logging.INFO)
       
       if log_format == "json":
           handler = logging.StreamHandler()
           handler.setFormatter(JsonFormatter())
       else:
           handler = logging.StreamHandler()
           handler.setFormatter(
               logging.Formatter(
                   "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
               )
           )
       
       logging.basicConfig(
           level=level,
           handlers=[handler],
           force=True  # Override any existing configuration
       )
   ```
3. **Test in notebook:**
   ```python
   # Test JSON logging
   setup_logging(log_level="INFO", log_format="json")
   logger = logging.getLogger("test")
   logger.info("Test message")
   print("✅ JSON logging works")
   
   # Test text logging
   setup_logging(log_level="DEBUG", log_format="text")
   logger.debug("Debug message")
   print("✅ Text logging works")
   ```
4. **Extract to Python file:**
   ```bash
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/ops/logging_config.ipynb \
       --output caio/logging_config.py \
       --classes JsonFormatter \
       --functions setup_logging
   ```
5. **Update `notebooks/math/api_app.ipynb` to use logging:**
   - Import `setup_logging` in notebook
   - Call `setup_logging()` in `create_app()`
   - Extract updated `api_app.ipynb` to `caio/api/app.py`
6. **Verify extraction:**
   ```bash
   python -c "from caio.logging_config import setup_logging; setup_logging(); print('OK')"
   ```

**Validation:**
- Logging works in both JSON and text formats
- Logs are structured correctly

---

### Step 9: Validate Health Check Endpoint (Notebook-First)

**Notebook:** `notebooks/math/api_routes.ipynb`

**Action:**
1. Open `notebooks/math/api_routes.ipynb`
2. Find the health check endpoint implementation
3. **Update notebook to add component validation:**
   ```python
   @api_router.get("/health")
   async def health_endpoint():
       """Health check endpoint with component validation."""
       health_status = {
           "status": "healthy",
           "components": {}
       }
       
       # Check orchestrator
       try:
           from caio.orchestrator.core import Orchestrator
           # Verify orchestrator can be instantiated
           health_status["components"]["orchestrator"] = "ok"
       except Exception as e:
           health_status["status"] = "unhealthy"
           health_status["components"]["orchestrator"] = f"error: {str(e)}"
       
       # Check service registry
       try:
           from caio.registry.service_registry import ServiceRegistry
           # Verify registry is accessible
           health_status["components"]["registry"] = "ok"
       except Exception as e:
           health_status["status"] = "unhealthy"
           health_status["components"]["registry"] = f"error: {str(e)}"
       
       # Check traceability storage
       try:
           from caio.traceability.storage import Traceability
           # Verify traceability is accessible
           health_status["components"]["traceability"] = "ok"
       except Exception as e:
           health_status["status"] = "unhealthy"
           health_status["components"]["traceability"] = f"error: {str(e)}"
       
       status_code = 200 if health_status["status"] == "healthy" else 503
       return health_status
   ```
4. **Test in notebook:**
   ```python
   # Test health endpoint
   health_response = await health_endpoint()
   assert "status" in health_response
   assert "components" in health_response
   print("✅ Health endpoint returns correct structure")
   ```
5. **Extract to Python file:**
   ```bash
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/health.py \
       --functions health_endpoint
   ```
6. **Verify extraction:**
   ```bash
   curl http://localhost:8080/health
   ```

**Validation:**
- Test health endpoint with all components working
- Test with component failures (should report unhealthy)

---

### Step 10: Review Production Error Handling (Notebook-First)

**Notebook:** `notebooks/math/api_app.ipynb`

**Action:**
1. Open `notebooks/math/api_app.ipynb`
2. Find all error handler functions
3. **Update notebook to improve error handling:**
   ```python
   from fastapi import Request, status
   from fastapi.responses import JSONResponse
   from datetime import datetime, timezone
   import logging
   
   logger = logging.getLogger(__name__)
   
   @api.exception_handler(Exception)
   async def global_exception_handler(request: Request, exc: Exception):
       """Global exception handler for production."""
       # Log error (without sensitive data)
       logger.error(
           f"Unhandled exception: {type(exc).__name__}",
           exc_info=exc,
           extra={"path": request.url.path, "method": request.method}
       )
       
       # Return structured error response
       return JSONResponse(
           status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
           content={
               "error": "InternalServerError",
               "message": "An internal error occurred",
               "detail": str(exc) if os.getenv("CAIO_ENV") == "development" else None,
               "timestamp": datetime.now(timezone.utc).isoformat()
           }
       )
   ```
4. **Test in notebook:**
   ```python
   # Test error handler
   test_request = Request(scope={"type": "http", "path": "/test"})
   test_exc = ValueError("Test error")
   response = await global_exception_handler(test_request, test_exc)
   assert response.status_code == 500
   assert "error" in response.body.decode()
   print("✅ Error handler works correctly")
   ```
5. **Extract to Python file:**
   ```bash
   python scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_app.ipynb \
       --output caio/api/app.py \
       --functions global_exception_handler
   ```
6. **Verify extraction:**
   - Test error handling with various exceptions
   - Verify no sensitive data in error messages

**Validation:**
- Error responses are structured
- No sensitive data in error messages
- Appropriate HTTP status codes

---

## Validation Procedures

### Pre-Implementation Validation

1. **Current State Baseline:**
   ```bash
   # Run tests and capture warnings
   pytest tests/ -v > test_baseline.txt 2>&1
   
   # Check scorecard
   make ma-validate-quiet
   
   # Verify imports
   python -c "from caio.api.app import create_app; print('OK')"
   ```

### Post-Implementation Validation

1. **Test Suite:**
   ```bash
   # All tests must pass with 0 deprecation warnings
   pytest tests/ -v
   ```

2. **Mathematical Validation:**
   ```bash
   # Scorecard must remain GREEN
   make ma-validate-quiet
   ```

3. **Import Validation:**
   ```bash
   # API app must import correctly
   python -c "from caio.api.app import app; print('OK')"
   ```

4. **Docker Validation:**
   ```bash
   # Docker build and run must work
   docker build -t caio:latest .
   docker run -p 8080:8080 caio:latest
   curl http://localhost:8080/health
   ```

5. **Configuration Validation:**
   ```bash
   # Config must load and validate
   python -c "from caio.config import CAIOConfig; c = CAIOConfig(); print('OK')"
   ```

6. **CORS Validation:**
   ```bash
   # Test CORS with different origins
   export CAIO_CORS_ORIGINS="http://localhost:3000"
   python -c "from caio.api.app import app; print('OK')"
   ```

---

## Success Criteria

### Must Have (Blocking)

- [ ] All 58 tests pass with 0 deprecation warnings
- [ ] Scorecard remains GREEN (all invariants passing)
- [ ] API app imports correctly: `from caio.api.app import app`
- [ ] CORS configuration is environment-based and secure
- [ ] Dockerfile builds and runs successfully
- [ ] Production deployment documentation exists
- [ ] Environment variables documented
- [ ] All code changes made in notebooks first, then extracted

### Should Have (Recommended)

- [ ] Production configuration management implemented
- [ ] Production logging configuration implemented
- [ ] Health check validates all critical components
- [ ] Error handling is production-ready

---

## Risks & Mitigation

### Risk 1: Breaking Changes

**Risk:** Changes may break existing functionality.

**Mitigation:**
- Run full test suite after each change
- Verify scorecard remains GREEN
- Test imports and API endpoints
- Follow notebook-first workflow (test in notebook before extraction)

### Risk 2: Configuration Complexity

**Risk:** Too many environment variables may confuse operators.

**Mitigation:**
- Provide clear documentation
- Use sensible defaults
- Validate and fail fast with helpful error messages

### Risk 3: Docker Image Size

**Risk:** Docker image may be large.

**Mitigation:**
- Use slim Python base image
- Multi-stage build if needed
- Exclude unnecessary files with `.dockerignore`

### Risk 4: Notebook Extraction Issues

**Risk:** Code extraction from notebooks may fail or produce incorrect code.

**Mitigation:**
- Test extraction script before use
- Verify extracted code matches notebook
- Run tests after extraction
- Keep notebooks as source of truth

---

## Rollback Plan

If issues arise:

1. **Revert Changes:**
   ```bash
   git revert <commit-hash>
   ```

2. **Verify Baseline:**
   ```bash
   pytest tests/ -v
   make ma-validate-quiet
   ```

3. **Document Issues:**
   - Update this plan with lessons learned
   - Create follow-up tasks for fixes

---

## Notes & References

### Related Documents

- **North Star:** `docs/NORTH_STAR.md`
- **Execution Plan:** `docs/operations/execution_plan.md`
- **Status Plan:** `docs/operations/STATUS_PLAN.md`
- **Runbooks:** `docs/operations/runbooks/`
- **Notebook-First Rule:** `.cursor/rules/notebook-first-mandatory.mdc`

### Related Code

- **API App:** `notebooks/math/api_app.ipynb` → `caio/api/app.py`
- **API Routes:** `notebooks/math/api_routes.ipynb` → `caio/api/routes/*.py`
- **Health Check:** `notebooks/math/api_routes.ipynb` → `caio/api/routes/health.py`
- **Traceability:** `notebooks/math/traceability.ipynb` → `caio/traceability/storage.py`
- **Audit:** `notebooks/ops/traceability_audit.ipynb` → `caio/api/routes/audit.py`
- **Alerts:** `notebooks/ops/slos_alerts.ipynb` → `caio/monitoring/alerts.py`

### Extraction Script

- **Script:** `scripts/notebooks/extract_code.py`
- **Usage:** See Step 1 for example

### External References

- FastAPI Deployment: https://fastapi.tiangolo.com/deployment/
- Docker Best Practices: https://docs.docker.com/develop/dev-best-practices/
- Python datetime timezone: https://docs.python.org/3/library/datetime.html#datetime.timezone

---

## Implementation Order

1. **Fix Deprecation Warnings** (Step 3) - Quick wins, no risk, multiple notebooks
2. **Fix API App Export** (Step 1) - Simple, low risk
3. **Fix CORS Configuration** (Step 2) - Security fix, medium risk
4. **Create Configuration Management** (Step 5) - Foundation for other work
5. **Create Logging Config** (Step 8) - Observability
6. **Create Dockerfile** (Step 4) - Deployment capability
7. **Create Documentation** (Steps 6-7) - Operator guidance
8. **Validate Health Check** (Step 9) - Reliability
9. **Review Error Handling** (Step 10) - User experience

---

## Critical Reminders

**MANDATORY WORKFLOW FOR ALL CODE CHANGES:**

1. ✅ Update notebook first (write code directly, NO imports from codebase)
2. ✅ Test in notebook (run cells, verify assertions)
3. ✅ Extract from notebook to Python file (use extraction script)
4. ✅ Verify extraction (run tests, check imports)
5. ❌ NEVER edit Python files directly
6. ❌ NEVER import from codebase into notebooks

**This plan is ready for execution. Follow the steps in order, validate after each step, and ensure all success criteria are met before considering production-ready.**
