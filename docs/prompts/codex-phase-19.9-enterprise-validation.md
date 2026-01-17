# Phase 19.9: Enterprise Artifact Validation

**Objective:** Create automated validation scripts for the Enterprise distribution artifacts (Docker image and Python Wheel). These scripts will serve as the "smoke test" for releases.

## Tasks

### Task 1: Docker Validation Script
**File:** `scripts/release/validate_docker.sh`

Create a script that:
1.  Runs `scripts/release/build_docker.sh` to ensure a fresh image.
2.  Starts the container: `docker run -d -p 8085:8080 --name caio-test-19-9 smarthaus/caio:latest`
3.  Waits for the service to become healthy (loop checking `/health` or waiting 10s).
4.  Curls `http://localhost:8085/api/v1/health`.
5.  Asserts response status is 200.
6.  Logs logs if failed.
7.  Stops and removes the container (`docker rm -f caio-test-19-9`).

### Task 2: Wheel Validation Script
**File:** `scripts/release/validate_wheel.sh`

Create a script that:
1.  Runs `scripts/release/build_wheel.sh`.
2.  Creates a temp dir and venv (`python -m venv .venv_test`).
3.  Installs the generated wheel: `pip install dist/*.whl`.
4.  Runs a python smoke test: `python -c "import caio; print('Import successful')"`
5.  Deactivates and removes the venv.

## Success Criteria
- Scripts are executable.
- Running them locally passes (exit code 0).

## Plan Reference
`plan:phase-19-9-enterprise-validation:19.9.1`
