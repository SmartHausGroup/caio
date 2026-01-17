# CAIO Docker Validation Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-07  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:production-readiness`

---

## Executive Summary

Complete Docker validation for CAIO production readiness. This task validates that the Dockerfile and containerized deployment work correctly, closing the final gap in the production readiness plan.

**CRITICAL:** This is a validation task, not a code change task. No notebook-first workflow required. Simply validate that Docker build/run works and document results.

**Estimated Time:** 10-15 minutes  
**Priority:** High (closes production readiness risk)

---

## Context & Background

### Current State

- ✅ **Dockerfile Created:** `Dockerfile` exists with proper structure
- ✅ **.dockerignore Created:** `.dockerignore` exists with proper exclusions
- ✅ **Production Code:** All production code is ready
- ⚠️ **Docker Validation:** Pending (Docker daemon not running during initial validation)

### Target State

- ✅ Docker build succeeds without errors
- ✅ Docker container runs successfully
- ✅ Health endpoint responds correctly
- ✅ Container logs show proper startup
- ✅ Risk removed from STATUS_PLAN.md

---

## North Star Alignment

**Alignment Check:** ✅ **ALIGNED**

This work aligns with CAIO's North Star:
- **Universal Compatibility:** Makes CAIO deployable in any containerized environment
- **Provability & Traceability:** Validates deployment artifacts work correctly
- **Security Built into Math:** Ensures containerized deployment maintains security guarantees

**Reference:** `docs/NORTH_STAR.md` - Deployment Envelopes & SLOs

---

## Execution Plan Reference

**Plan Item:** `plan:EXECUTION_PLAN:production-readiness`

This task completes the Docker validation step from the production readiness plan, specifically Step 4 (Docker Validation) from `docs/prompts/codex-production-readiness.md`.

---

## Step-by-Step Implementation Instructions

### Step 1: Verify Docker Daemon is Running

**Action:**
```bash
# Check Docker daemon status
docker info
```

**Expected Result:**
- Docker daemon is running
- No errors about daemon not being accessible

**If Docker daemon is not running:**
- **macOS:** Start Docker Desktop application
- **Linux:** Start Docker service: `sudo systemctl start docker`
- **Windows:** Start Docker Desktop application

**Validation:**
```bash
# Should return Docker version info
docker --version
docker info
```

---

### Step 2: Build Docker Image

**Action:**
```bash
# Navigate to CAIO root directory
cd /Users/smarthaus/Projects/GitHub/CAIO

# Build Docker image
docker build -t caio:latest .
```

**Expected Result:**
- Build completes successfully
- No errors during build process
- Image tagged as `caio:latest`

**Common Issues & Fixes:**

1. **Error: "COPY failed: file not found"**
   - **Fix:** Verify `requirements.txt` exists in root directory
   - **Fix:** Verify `caio/`, `configs/`, `invariants/` directories exist

2. **Error: "pip install failed"**
   - **Fix:** Check `requirements.txt` for syntax errors
   - **Fix:** Verify all dependencies are valid

3. **Error: "Module not found"**
   - **Fix:** Verify all required files are copied in Dockerfile
   - **Fix:** Check `.dockerignore` doesn't exclude required files

**Validation:**
```bash
# Verify image was created
docker images | grep caio
```

---

### Step 3: Run Docker Container

**Action:**
```bash
# Run container in detached mode
docker run -d -p 8080:8080 --name caio-test caio:latest

# Or run in foreground to see logs
docker run -p 8080:8080 --name caio-test caio:latest
```

**Expected Result:**
- Container starts successfully
- No immediate errors
- Container is running

**Common Issues & Fixes:**

1. **Error: "port already in use"**
   - **Fix:** Stop existing container: `docker stop caio-test && docker rm caio-test`
   - **Fix:** Use different port: `docker run -p 8081:8080 caio:latest`

2. **Error: "module not found"**
   - **Fix:** Check Dockerfile COPY commands include all required files
   - **Fix:** Verify Python path is correct

3. **Error: "CORS or config validation failed"**
   - **Fix:** Set required environment variables:
     ```bash
     docker run -p 8080:8080 \
       -e CAIO_ENV=production \
       -e CAIO_AUTH_SECRET_KEY=test-secret-key \
       -e CAIO_CORS_ORIGINS='["http://localhost:3000"]' \
       --name caio-test caio:latest
     ```

**Validation:**
```bash
# Check container is running
docker ps | grep caio-test

# Check container logs
docker logs caio-test
```

---

### Step 4: Test Health Endpoint

**Action:**
```bash
# Test health endpoint
curl http://localhost:8080/health
```

**Expected Result:**
- HTTP 200 response
- JSON response with health status
- All components show healthy status

**Expected Response Format:**
```json
{
  "status": "healthy",
  "timestamp": "2026-01-07T...",
  "components": {
    "api": "healthy",
    "orchestrator": "healthy",
    "registry": "healthy"
  }
}
```

**Common Issues & Fixes:**

1. **Error: "Connection refused"**
   - **Fix:** Check container is running: `docker ps`
   - **Fix:** Check port mapping: `docker port caio-test`

2. **Error: "HTTP 503"**
   - **Fix:** Check container logs: `docker logs caio-test`
   - **Fix:** Verify all required environment variables are set

3. **Error: "HTTP 500"**
   - **Fix:** Check container logs for errors
   - **Fix:** Verify all dependencies are installed correctly

**Validation:**
```bash
# Test health endpoint multiple times
curl http://localhost:8080/health
curl http://localhost:8080/health
curl http://localhost:8080/health
```

---

### Step 5: Test API Endpoints (Optional but Recommended)

**Action:**
```bash
# Test service registry endpoint
curl http://localhost:8080/api/v1/services

# Test service registration endpoint (if applicable)
curl -X POST http://localhost:8080/api/v1/services \
  -H "Content-Type: application/json" \
  -d '{"id": "test-service", "name": "Test Service"}'
```

**Expected Result:**
- Endpoints respond correctly
- No errors in container logs

**Validation:**
- All tested endpoints return expected responses
- Container logs show no errors

---

### Step 6: Clean Up Test Container

**Action:**
```bash
# Stop and remove test container
docker stop caio-test
docker rm caio-test

# Optional: Remove test image (keep caio:latest for future use)
# docker rmi caio:latest
```

**Validation:**
```bash
# Verify container is removed
docker ps -a | grep caio-test
```

---

## Validation Procedures

### Pre-Validation Checklist

- [ ] Docker daemon is running
- [ ] Docker CLI is accessible
- [ ] CAIO root directory contains `Dockerfile` and `.dockerignore`
- [ ] All required files exist (`requirements.txt`, `caio/`, `configs/`, `invariants/`)

### Post-Validation Checklist

- [ ] Docker build completes successfully
- [ ] Docker container runs without errors
- [ ] Health endpoint returns HTTP 200
- [ ] Health endpoint returns valid JSON
- [ ] Container logs show no errors
- [ ] Test container is cleaned up

### Success Criteria

✅ **Docker Validation Complete** when:
1. `docker build -t caio:latest .` succeeds
2. `docker run -p 8080:8080 caio:latest` starts container
3. `curl http://localhost:8080/health` returns HTTP 200 with valid JSON
4. Container logs show no errors
5. Risk removed from `docs/operations/STATUS_PLAN.md`

---

## Troubleshooting Guide

### Issue: Docker Daemon Not Running

**Symptoms:**
- `docker info` fails with "Cannot connect to Docker daemon"
- `docker build` fails immediately

**Solution:**
1. **macOS:** Open Docker Desktop application, wait for it to start
2. **Linux:** Run `sudo systemctl start docker`
3. **Windows:** Open Docker Desktop application, wait for it to start
4. Verify: `docker info` should succeed

---

### Issue: Build Fails with "COPY failed"

**Symptoms:**
- Build fails at COPY step
- Error: "COPY failed: file not found"

**Solution:**
1. Verify you're in CAIO root directory: `pwd`
2. Verify file exists: `ls -la requirements.txt`
3. Verify directory exists: `ls -la caio/ configs/ invariants/`
4. Check `.dockerignore` doesn't exclude required files

---

### Issue: Container Exits Immediately

**Symptoms:**
- Container starts then exits
- `docker ps` shows no running container

**Solution:**
1. Check container logs: `docker logs caio-test`
2. Verify environment variables are set correctly
3. Check for import errors in logs
4. Verify all dependencies are installed in Dockerfile

---

### Issue: Health Endpoint Returns 503

**Symptoms:**
- `curl http://localhost:8080/health` returns HTTP 503
- Health response shows components as "unhealthy"

**Solution:**
1. Check container logs: `docker logs caio-test`
2. Verify required environment variables are set:
   - `CAIO_ENV`
   - `CAIO_AUTH_SECRET_KEY`
   - `CAIO_CORS_ORIGINS`
3. Check for initialization errors in logs
4. Verify all components are properly initialized

---

### Issue: Port Already in Use

**Symptoms:**
- `docker run` fails with "port already in use"
- Port 8080 is already bound

**Solution:**
1. Find process using port: `lsof -i :8080` (macOS/Linux) or `netstat -ano | findstr :8080` (Windows)
2. Stop existing container: `docker stop <container-name> && docker rm <container-name>`
3. Or use different port: `docker run -p 8081:8080 caio:latest`

---

## Documentation Updates

After successful validation, update:

1. **STATUS_PLAN.md:**
   - Remove Docker validation risk from "Current Risks" section
   - Add entry to "Recent Work" section
   - Update "Last Status Update" timestamp

2. **CODEX_ACTION_LOG:**
   - Add entry documenting validation success
   - Include plan reference: `plan:EXECUTION_PLAN:production-readiness`
   - Include validation results (build success, health check success)

---

## Notes and References

- **Dockerfile Location:** `Dockerfile` (root directory)
- **.dockerignore Location:** `.dockerignore` (root directory)
- **Production Readiness Plan:** `docs/prompts/codex-production-readiness.md`
- **Status Plan:** `docs/operations/STATUS_PLAN.md`
- **Action Log:** `CODEX_ACTION_LOG`

---

## Expected Outcomes

After completing this validation:

1. ✅ Docker build works correctly
2. ✅ Docker container runs successfully
3. ✅ Health endpoint responds correctly
4. ✅ Production readiness risk is removed
5. ✅ Documentation is updated
6. ✅ Action log is updated

**Production readiness is then 100% complete.**

---

**Last Updated:** 2026-01-07  
**Version:** 1.0

