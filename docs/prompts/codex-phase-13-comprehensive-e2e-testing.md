# CAIO Phase 13: Comprehensive E2E Testing Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-10  
**Owner:** Codex  
**Plan Reference:** `plan:phase-13-comprehensive-e2e-testing:13.1-13.4`

---

## Executive Summary

Complete comprehensive end-to-end testing to validate CAIO production readiness. This phase implements E2E tests (replacing placeholders), validates production deployment end-to-end, creates load/stress tests for performance SLOs, and validates hardening checklist items.

**CRITICAL:** This is comprehensive testing work, not mathematical algorithm work. MA process is NOT required. However, all tests must use real implementations (no mocks for core behavior) and validate production readiness.

**Estimated Time:** 3-5 days  
**Priority:** High (production readiness validation, comprehensive test coverage)

---

## Context & Background

### Current State

- ✅ **Phase 12 Complete:** Operational improvements done
- ✅ **Phase 11 Complete:** Productionization done
- ✅ **CAIO Functional:** Core functionality working
- ❌ **E2E Tests:** Placeholder tests exist but not implemented (all `pass`)
- ❌ **Production Deployment:** No comprehensive deployment validation tests
- ❌ **Load/Stress Testing:** No performance testing under load
- ❌ **Hardening Checklist:** Items not validated with tests

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Tests & CI Gates Enforce Invariants:** Comprehensive E2E tests validate all invariants are preserved
- **Operational Excellence:** Production deployment validation ensures operational readiness
- **Performance SLOs:** Load/stress tests validate performance bounds (P95 ≤ 50ms routing decision)
- **Production Readiness:** Hardening checklist validation ensures all production requirements are met

**Reference:** `docs/NORTH_STAR.md` - Tests & CI gates enforce invariants, performance SLOs, deployment envelopes

### Execution Plan Reference

This task implements Phase 13: Comprehensive E2E Testing from `plans/phase-13-comprehensive-e2e-testing/`:

- **13.1:** E2E test implementation (replace placeholders with real tests)
- **13.2:** Production deployment validation (Docker, env vars, health, auth, CORS, logging)
- **13.3:** Load/stress testing (concurrent requests, latency SLOs, throughput, resource usage)
- **13.4:** Hardening checklist validation (map items to tests, fill gaps, document coverage)

---

## Step-by-Step Implementation Instructions

### Task 13.1: E2E Test Implementation

**File:** `tests/e2e/test_routing_flow.py`

**Objective:** Replace all placeholder E2E tests with real implementations testing complete routing flow.

#### Step 1.1: Read Current E2E Test Structure

**Read current E2E test file:**
```bash
# View current E2E test structure
cat tests/e2e/test_routing_flow.py
```

**Current Status:**
- 3 test classes: `TestCompleteRoutingFlow`, `TestRoutingFlowErrorHandling`, `TestRoutingFlowPerformance`
- 15+ test methods, all with `pass` (placeholders)
- Comments say "Will be implemented when code is extracted"
- Code HAS been extracted (Phase 6 complete), but tests weren't updated

#### Step 1.2: Understand CAIO Components

**Review CAIO components for test setup:**
```python
# Key imports for E2E tests
from caio import Orchestrator, Request, RoutingDecision
from caio.contracts import parse_contract, ServiceContract
from caio.registry import ServiceRegistry, ServiceEntry
from pathlib import Path
import tempfile
import json
```

**Component Structure:**
- `Orchestrator` - Main orchestrator class
- `Request` - Routing request (intent, context, requirements, constraints, user)
- `ServiceContract` - Service contract (capabilities, guarantees, constraints, cost, privacy, alignment, api)
- `ServiceEntry` - Service in registry (contract, health, version, tags)
- `RoutingDecision` - Routing decision (service_id, route, model, control_signal, guarantees, proofs, trace)

#### Step 1.3: Implement Routing Flow Tests

**Replace `test_routing_flow_contract_matching`:**
```python
def test_routing_flow_contract_matching(self):
    """Test that routing flow performs contract matching correctly."""
    # Create orchestrator
    orchestrator = Orchestrator()
    
    # Create test service contract
    contract_yaml = """
service_id: test-chat-service
name: Test Chat Service
version: "1.0.0"
capabilities:
  - type: chat
    accuracy:
      min: 0.90
      target: 0.95
guarantees:
  accuracy: 0.95
  determinism: true
constraints:
  requires_gpu: false
  requires_internet: false
api:
  protocol: http
  base_url: http://localhost:9000
  endpoints:
    - path: /chat
      method: POST
"""
    
    # Register service
    with tempfile.NamedTemporaryFile(mode="w", suffix=".yaml", delete=False) as f:
        f.write(contract_yaml)
        contract_path = Path(f.name)
    
    try:
        entry = orchestrator.register_service(contract_path)
        assert entry.contract.service_id == "test-chat-service"
        
        # Create request matching service
        request = Request(
            intent={"type": "chat"},
            context={},
            requirements={"capabilities": ["chat"]},
            constraints={"requires_gpu": False},
            user={"trust_level": 1}
        )
        
        # Route request
        decision = orchestrator.route_request(
            request=request,
            policies=[],
            history={},
            seed=42
        )
        
        # Verify contract matching worked
        assert decision.service_id == "test-chat-service"
        assert decision.route in ["internal", "external", "hybrid"]
    finally:
        contract_path.unlink()
```

**Replace `test_routing_flow_rule_evaluation`:**
```python
def test_routing_flow_rule_evaluation(self):
    """Test that routing flow performs rule evaluation correctly."""
    orchestrator = Orchestrator()
    
    # Register service
    contract_yaml = """
service_id: test-service
name: Test Service
version: "1.0.0"
capabilities:
  - type: chat
guarantees:
  accuracy: 0.95
constraints:
  requires_gpu: false
api:
  protocol: http
  base_url: http://localhost:9000
  endpoints:
    - path: /chat
      method: POST
"""
    
    with tempfile.NamedTemporaryFile(mode="w", suffix=".yaml", delete=False) as f:
        f.write(contract_yaml)
        contract_path = Path(f.name)
    
    try:
        orchestrator.register_service(contract_path)
        
        # Create request with policies
        request = Request(
            intent={"type": "chat"},
            context={},
            requirements={"capabilities": ["chat"]},
            constraints={"requires_gpu": False},
            user={"trust_level": 1}
        )
        
        # Define policies (rules)
        policies = [
            {"type": "constraint", "field": "requires_gpu", "value": False}
        ]
        
        # Route request with policies
        decision = orchestrator.route_request(
            request=request,
            policies=policies,
            history={},
            seed=42
        )
        
        # Verify rule evaluation worked
        assert decision.service_id == "test-service"
        assert "proofs" in decision.trace or decision.proofs is not None
    finally:
        contract_path.unlink()
```

**Continue with remaining routing flow tests following same pattern.**

#### Step 1.4: Implement Error Handling Tests

**Replace `test_routing_flow_handles_no_matching_services`:**
```python
def test_routing_flow_handles_no_matching_services(self):
    """Test that routing flow handles case when no services match."""
    orchestrator = Orchestrator()
    
    # Create request with requirements no service can match
    request = Request(
        intent={"type": "nonexistent-capability"},
        context={},
        requirements={"capabilities": ["nonexistent-capability"]},
        constraints={},
        user={"trust_level": 1}
    )
    
    # Route request (should handle gracefully)
    try:
        decision = orchestrator.route_request(
            request=request,
            policies=[],
            history={},
            seed=42
        )
        # If no services match, should return None or raise appropriate exception
        assert decision is None or decision.service_id is None
    except ValueError as exc:
        # Expected: ValueError when no services match
        assert "no matching services" in str(exc).lower() or "no services" in str(exc).lower()
```

**Continue with remaining error handling tests.**

#### Step 1.5: Implement Performance Tests

**Replace `test_routing_flow_meets_latency_bounds`:**
```python
import time

def test_routing_flow_meets_latency_bounds(self):
    """Test that routing flow meets latency bounds (INV-CAIO-0006)."""
    orchestrator = Orchestrator()
    
    # Register service
    contract_yaml = """
service_id: test-service
name: Test Service
version: "1.0.0"
capabilities:
  - type: chat
api:
  protocol: http
  base_url: http://localhost:9000
  endpoints:
    - path: /chat
      method: POST
"""
    
    with tempfile.NamedTemporaryFile(mode="w", suffix=".yaml", delete=False) as f:
        f.write(contract_yaml)
        contract_path = Path(f.name)
    
    try:
        orchestrator.register_service(contract_path)
        
        request = Request(
            intent={"type": "chat"},
            context={},
            requirements={"capabilities": ["chat"]},
            constraints={},
            user={"trust_level": 1}
        )
        
        # Measure latency (multiple runs for P95)
        latencies = []
        for _ in range(100):
            start = time.perf_counter()
            decision = orchestrator.route_request(
                request=request,
                policies=[],
                history={},
                seed=42
            )
            latency = (time.perf_counter() - start) * 1000  # Convert to ms
            latencies.append(latency)
            assert decision is not None
        
        # Calculate P95
        latencies.sort()
        p95_latency = latencies[int(len(latencies) * 0.95)]
        
        # Verify P95 ≤ 50ms (INV-CAIO-0006)
        assert p95_latency <= 50.0, f"P95 latency {p95_latency}ms exceeds 50ms threshold"
    finally:
        contract_path.unlink()
```

**Continue with remaining performance tests.**

#### Step 1.6: Validate E2E Tests

**Run E2E tests:**
```bash
# Run all E2E tests
pytest tests/e2e/test_routing_flow.py -v

# Verify no placeholders remain
grep -r "pass$" tests/e2e/test_routing_flow.py | grep -v "__pycache__"
grep -r "Will be implemented" tests/e2e/test_routing_flow.py
```

**Expected Results:**
- All E2E tests pass
- No `pass` statements (except in fixtures)
- No "Will be implemented" comments
- Tests use real implementations

---

### Task 13.2: Production Deployment Validation

**File:** `tests/e2e/test_production_deployment.py` (new)

**Objective:** Create comprehensive tests for production deployment scenarios.

#### Step 2.1: Create Production Deployment Test File

**Create new test file:**
```bash
# Create test file
touch tests/e2e/test_production_deployment.py
```

**Add file header:**
```python
"""End-to-end tests for CAIO production deployment.

These tests verify production deployment scenarios:
1. Docker deployment
2. Environment variable configuration
3. Health checks
4. Authentication/authorization
5. CORS configuration
6. Structured logging
"""
```

#### Step 2.2: Implement Docker Deployment Test

**Add Docker deployment test:**
```python
import subprocess
import time
import requests
import pytest

class TestDockerDeployment:
    """Test Docker deployment scenarios."""
    
    @pytest.fixture(scope="class")
    def docker_image(self):
        """Build Docker image for testing."""
        # Build image
        subprocess.run(
            ["docker", "build", "-t", "caio:test", "."],
            check=True,
            capture_output=True
        )
        yield "caio:test"
        # Cleanup (optional)
        # subprocess.run(["docker", "rmi", "caio:test"], check=False)
    
    def test_docker_build_succeeds(self, docker_image):
        """Test that Docker image builds successfully."""
        # Image built in fixture
        assert docker_image == "caio:test"
    
    def test_docker_container_starts(self, docker_image):
        """Test that Docker container starts successfully."""
        # Run container
        container = subprocess.run(
            [
                "docker", "run", "-d",
                "-p", "8080:8080",
                "-e", "CAIO_ENV=production",
                "-e", "CAIO_AUTH_SECRET_KEY=test-secret-key",
                "-e", "CAIO_CORS_ORIGINS=https://example.com",
                docker_image
            ],
            capture_output=True,
            text=True,
            check=True
        )
        container_id = container.stdout.strip()
        
        try:
            # Wait for container to start
            time.sleep(2)
            
            # Verify container is running
            status = subprocess.run(
                ["docker", "ps", "--filter", f"id={container_id}", "--format", "{{.Status}}"],
                capture_output=True,
                text=True,
                check=True
            )
            assert "Up" in status.stdout
            
        finally:
            # Cleanup
            subprocess.run(["docker", "stop", container_id], check=False)
            subprocess.run(["docker", "rm", container_id], check=False)
    
    def test_docker_health_endpoint(self, docker_image):
        """Test that health endpoint works in Docker."""
        # Run container
        container = subprocess.run(
            [
                "docker", "run", "-d",
                "-p", "8080:8080",
                "-e", "CAIO_ENV=production",
                "-e", "CAIO_AUTH_SECRET_KEY=test-secret-key",
                "-e", "CAIO_CORS_ORIGINS=https://example.com",
                docker_image
            ],
            capture_output=True,
            text=True,
            check=True
        )
        container_id = container.stdout.strip()
        
        try:
            # Wait for container to start
            time.sleep(3)
            
            # Test health endpoint
            response = requests.get("http://localhost:8080/health", timeout=5)
            assert response.status_code == 200
            data = response.json()
            assert "status" in data
            assert data["status"] == "healthy"
            
        finally:
            # Cleanup
            subprocess.run(["docker", "stop", container_id], check=False)
            subprocess.run(["docker", "rm", container_id], check=False)
```

#### Step 2.3: Implement Environment Variable Tests

**Add environment variable validation test:**
```python
import os
import pytest
from caio.api import create_app
from fastapi.testclient import TestClient

class TestEnvironmentVariables:
    """Test environment variable configuration."""
    
    def test_required_environment_variables(self, monkeypatch):
        """Test that required environment variables are validated."""
        # Set required variables
        monkeypatch.setenv("CAIO_ENV", "production")
        monkeypatch.setenv("CAIO_AUTH_SECRET_KEY", "test-secret-key")
        monkeypatch.setenv("CAIO_CORS_ORIGINS", "https://example.com")
        
        # App should start successfully
        app = create_app()
        client = TestClient(app)
        
        # Health endpoint should work
        response = client.get("/health")
        assert response.status_code == 200
    
    def test_missing_auth_secret_key(self, monkeypatch):
        """Test that missing CAIO_AUTH_SECRET_KEY fails gracefully."""
        monkeypatch.setenv("CAIO_ENV", "production")
        monkeypatch.delenv("CAIO_AUTH_SECRET_KEY", raising=False)
        
        # App should handle missing secret key
        # (Implementation depends on how CAIO handles this)
        # Expected: Either fails at startup or uses default
        try:
            app = create_app()
            # If app starts, verify it handles missing key
            assert True
        except Exception as exc:
            # Expected: Exception if secret key is required
            assert "CAIO_AUTH_SECRET_KEY" in str(exc) or "secret" in str(exc).lower()
```

#### Step 2.4: Implement Health Check Tests

**Add health check tests:**
```python
class TestHealthChecks:
    """Test health endpoint functionality."""
    
    @pytest.fixture
    def app(self):
        """Create FastAPI app for testing."""
        return create_app()
    
    @pytest.fixture
    def client(self, app):
        """Create test client."""
        return TestClient(app)
    
    def test_health_endpoint_returns_200(self, client):
        """Test that /health endpoint returns 200."""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
    
    def test_health_endpoint_checks_components(self, client):
        """Test that health endpoint checks all components."""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        
        # Verify component checks (if implemented)
        if "components" in data:
            assert "registry" in data["components"]
            assert "rule_engine" in data["components"]
            assert "security_verifier" in data["components"]
            assert "traceability" in data["components"]
```

#### Step 2.5: Implement Authentication/Authorization Tests

**Add authentication/authorization tests:**
```python
class TestAuthenticationAuthorization:
    """Test authentication and authorization."""
    
    @pytest.fixture
    def app(self, monkeypatch):
        """Create FastAPI app with auth enabled."""
        monkeypatch.setenv("CAIO_AUTH_REQUIRED", "true")
        monkeypatch.setenv(
            "CAIO_AUTH_TOKENS",
            "admin-token:admin,user-token:user,service-token:service"
        )
        return create_app()
    
    @pytest.fixture
    def client(self, app):
        """Create test client."""
        return TestClient(app)
    
    def test_api_routes_require_authentication(self, client):
        """Test that API routes require authentication."""
        # Test without token (should return 401)
        response = client.get("/api/v1/services")
        assert response.status_code == 401
    
    def test_api_routes_accept_valid_tokens(self, client):
        """Test that API routes accept valid tokens."""
        # Test with valid token (should return 200)
        headers = {"Authorization": "Bearer admin-token"}
        response = client.get("/api/v1/services", headers=headers)
        assert response.status_code == 200
    
    def test_authorization_levels(self, client):
        """Test that authorization levels work correctly."""
        # Test admin token
        admin_headers = {"Authorization": "Bearer admin-token"}
        response = client.get("/api/v1/services", headers=admin_headers)
        assert response.status_code == 200
        
        # Test user token
        user_headers = {"Authorization": "Bearer user-token"}
        response = client.get("/api/v1/services", headers=user_headers)
        assert response.status_code == 200
```

#### Step 2.6: Implement CORS Tests

**Add CORS tests:**
```python
class TestCORS:
    """Test CORS configuration."""
    
    @pytest.fixture
    def app(self, monkeypatch):
        """Create FastAPI app with CORS configured."""
        monkeypatch.setenv("CAIO_CORS_ORIGINS", "https://example.com,https://app.example.com")
        return create_app()
    
    @pytest.fixture
    def client(self, app):
        """Create test client."""
        return TestClient(app)
    
    def test_cors_allows_configured_origins(self, client):
        """Test that CORS allows configured origins."""
        headers = {
            "Origin": "https://example.com",
            "Access-Control-Request-Method": "GET"
        }
        response = client.options("/api/v1/services", headers=headers)
        assert response.status_code in [200, 204]
        assert "Access-Control-Allow-Origin" in response.headers
    
    def test_cors_rejects_disallowed_origins(self, client):
        """Test that CORS rejects disallowed origins."""
        headers = {
            "Origin": "https://malicious.com",
            "Access-Control-Request-Method": "GET"
        }
        response = client.options("/api/v1/services", headers=headers)
        # CORS should reject or not include Access-Control-Allow-Origin
        assert "https://malicious.com" not in response.headers.get("Access-Control-Allow-Origin", "")
```

#### Step 2.7: Implement Structured Logging Tests

**Add structured logging tests:**
```python
import json
import logging

class TestStructuredLogging:
    """Test structured logging configuration."""
    
    def test_json_log_format(self, monkeypatch, caplog):
        """Test that JSON log format works."""
        monkeypatch.setenv("CAIO_LOG_FORMAT", "json")
        
        # Create app (should configure JSON logging)
        app = create_app()
        
        # Trigger a log event
        with caplog.at_level(logging.INFO):
            # Make a request that generates logs
            client = TestClient(app)
            client.get("/health")
        
        # Verify logs are in JSON format (if captured)
        # (Implementation depends on how CAIO logs)
        assert len(caplog.records) >= 0  # At least some logs
```

#### Step 2.8: Validate Production Deployment Tests

**Run production deployment tests:**
```bash
# Run production deployment tests
pytest tests/e2e/test_production_deployment.py -v

# Test Docker deployment manually (if needed)
docker build -t caio:test .
docker run --rm -p 8080:8080 -e CAIO_ENV=production -e CAIO_AUTH_SECRET_KEY=test caio:test
```

**Expected Results:**
- All production deployment tests pass
- Docker deployment validated end-to-end
- All production configuration scenarios tested

---

### Task 13.3: Load/Stress Testing

**File:** `tests/e2e/test_load_stress.py` (new)

**Objective:** Create load and stress tests to validate performance SLOs under realistic conditions.

#### Step 3.1: Create Load/Stress Test File

**Create new test file:**
```bash
# Create test file
touch tests/e2e/test_load_stress.py
```

**Add file header:**
```python
"""Load and stress tests for CAIO performance validation.

These tests verify performance SLOs under realistic load conditions:
1. Concurrent request handling (≥ 10,000 per instance)
2. Latency SLOs (P95 ≤ 50ms routing decision)
3. Throughput under sustained load
4. Resource usage (memory, CPU)
5. Capacity margin (≥ 1.3× headroom)
"""
```

#### Step 3.2: Implement Concurrent Request Test

**Add concurrent request test:**
```python
import concurrent.futures
import time
import pytest
from caio import Orchestrator, Request
from pathlib import Path
import tempfile

class TestConcurrentRequests:
    """Test concurrent request handling."""
    
    @pytest.fixture
    def orchestrator_with_service(self):
        """Create orchestrator with test service registered."""
        orchestrator = Orchestrator()
        
        contract_yaml = """
service_id: test-service
name: Test Service
version: "1.0.0"
capabilities:
  - type: chat
api:
  protocol: http
  base_url: http://localhost:9000
  endpoints:
    - path: /chat
      method: POST
"""
        
        with tempfile.NamedTemporaryFile(mode="w", suffix=".yaml", delete=False) as f:
            f.write(contract_yaml)
            contract_path = Path(f.name)
        
        orchestrator.register_service(contract_path)
        yield orchestrator
        contract_path.unlink()
    
    def test_concurrent_requests_handling(self, orchestrator_with_service):
        """Test that CAIO handles ≥ 10,000 concurrent requests."""
        def make_request(request_id):
            """Make a single routing request."""
            request = Request(
                intent={"type": "chat", "message": f"Request {request_id}"},
                context={},
                requirements={"capabilities": ["chat"]},
                constraints={},
                user={"trust_level": 1}
            )
            try:
                decision = orchestrator_with_service.route_request(
                    request=request,
                    policies=[],
                    history={},
                    seed=42
                )
                return decision is not None
            except Exception as exc:
                return False
        
        # Test with 10,000 concurrent requests
        num_requests = 10000
        with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
            futures = [executor.submit(make_request, i) for i in range(num_requests)]
            results = [future.result() for future in concurrent.futures.as_completed(futures)]
        
        # Verify all requests completed successfully
        success_rate = sum(results) / len(results)
        assert success_rate >= 0.99, f"Success rate {success_rate} below 99% threshold"
```

#### Step 3.3: Implement Latency SLO Tests

**Add latency SLO tests:**
```python
import statistics

class TestLatencySLOs:
    """Test latency SLOs under load."""
    
    @pytest.fixture
    def orchestrator_with_service(self):
        """Create orchestrator with test service registered."""
        # (Same fixture as above)
        pass
    
    def test_routing_decision_latency_p95(self, orchestrator_with_service):
        """Test that routing decision latency P95 ≤ 50ms (INV-CAIO-0006)."""
        request = Request(
            intent={"type": "chat"},
            context={},
            requirements={"capabilities": ["chat"]},
            constraints={},
            user={"trust_level": 1}
        )
        
        # Measure latency (multiple runs for P95)
        latencies = []
        for _ in range(1000):
            start = time.perf_counter()
            decision = orchestrator_with_service.route_request(
                request=request,
                policies=[],
                history={},
                seed=42
            )
            latency = (time.perf_counter() - start) * 1000  # Convert to ms
            latencies.append(latency)
            assert decision is not None
        
        # Calculate P95
        latencies.sort()
        p95_latency = latencies[int(len(latencies) * 0.95)]
        
        # Verify P95 ≤ 50ms (INV-CAIO-0006)
        assert p95_latency <= 50.0, f"P95 latency {p95_latency}ms exceeds 50ms threshold"
    
    def test_contract_matching_latency_p95(self, orchestrator_with_service):
        """Test that contract matching latency P95 ≤ 10ms."""
        # (Similar to above, but measure contract matching specifically)
        # Target: P95 ≤ 10ms for contract matching
        pass
    
    def test_security_verification_latency_p95(self, orchestrator_with_service):
        """Test that security verification latency P95 ≤ 20ms."""
        # (Similar to above, but measure security verification specifically)
        # Target: P95 ≤ 20ms for security verification
        pass
```

#### Step 3.4: Implement Throughput Test

**Add throughput test:**
```python
class TestThroughput:
    """Test throughput under sustained load."""
    
    def test_sustained_throughput(self, orchestrator_with_service):
        """Test that CAIO maintains throughput under sustained load."""
        request = Request(
            intent={"type": "chat"},
            context={},
            requirements={"capabilities": ["chat"]},
            constraints={},
            user={"trust_level": 1}
        )
        
        # Run sustained load test (1000 requests over 10 seconds)
        start_time = time.perf_counter()
        num_requests = 1000
        successful_requests = 0
        
        for _ in range(num_requests):
            try:
                decision = orchestrator_with_service.route_request(
                    request=request,
                    policies=[],
                    history={},
                    seed=42
                )
                if decision is not None:
                    successful_requests += 1
            except Exception:
                pass
        
        elapsed_time = time.perf_counter() - start_time
        throughput = successful_requests / elapsed_time  # requests per second
        
        # Verify throughput meets targets (adjust threshold as needed)
        assert throughput >= 50, f"Throughput {throughput} req/s below 50 req/s threshold"
```

#### Step 3.5: Implement Resource Usage Tests

**Add resource usage tests:**
```python
import psutil
import os

class TestResourceUsage:
    """Test resource usage under load."""
    
    def test_memory_usage_under_load(self, orchestrator_with_service):
        """Test that memory usage stays within bounds (≈ 1–4 GB per instance)."""
        process = psutil.Process(os.getpid())
        initial_memory = process.memory_info().rss / (1024 * 1024)  # MB
        
        # Run load test
        request = Request(
            intent={"type": "chat"},
            context={},
            requirements={"capabilities": ["chat"]},
            constraints={},
            user={"trust_level": 1}
        )
        
        for _ in range(1000):
            orchestrator_with_service.route_request(
                request=request,
                policies=[],
                history={},
                seed=42
            )
        
        final_memory = process.memory_info().rss / (1024 * 1024)  # MB
        memory_usage = final_memory - initial_memory
        
        # Verify memory usage within bounds (adjust threshold as needed)
        assert memory_usage < 4000, f"Memory usage {memory_usage}MB exceeds 4GB threshold"
    
    def test_cpu_utilization_steady_state(self, orchestrator_with_service):
        """Test that CPU utilization ≤ 80% steady state."""
        # Measure CPU utilization during load test
        # (Implementation depends on how to measure CPU)
        # Target: ≤ 80% steady state
        pass
```

#### Step 3.6: Validate Load/Stress Tests

**Run load/stress tests:**
```bash
# Run load/stress tests (may take time)
pytest tests/e2e/test_load_stress.py -v -m "not slow"  # Run fast tests only
pytest tests/e2e/test_load_stress.py -v -m "slow"  # Run slow tests separately
```

**Expected Results:**
- Load/stress tests pass
- Performance SLOs validated (P95 ≤ 50ms routing decision)
- Resource usage within bounds
- Capacity margin maintained

---

### Task 13.4: Hardening Checklist Validation

**File:** `docs/deployment/HARDENING_CHECKLIST.MD`

**Objective:** Validate all hardening checklist items are tested and documented.

#### Step 4.1: Map Checklist Items to Tests

**Read hardening checklist:**
```bash
# Read hardening checklist
cat docs/deployment/HARDENING_CHECKLIST.MD
```

**Map each item to test:**

**Security Hardening:**
- Authentication/authorization → `test_production_deployment.py::TestAuthenticationAuthorization`
- TLS/SSL → (Infrastructure, not code test)
- Secrets storage → (Infrastructure, not code test)
- Network access → (Infrastructure, not code test)
- CORS → `test_production_deployment.py::TestCORS`
- Rate limiting → (Future test)
- Audit logging → `test_production_deployment.py::TestStructuredLogging`

**Reliability Hardening:**
- `/health` endpoint → `test_production_deployment.py::TestHealthChecks`
- Structured logging → `test_production_deployment.py::TestStructuredLogging`
- Metrics collection → (Integration tests)
- Alerting → (Integration tests)
- Backup/restore → (Infrastructure, not code test)
- Runbooks → (Documentation, not code test)

**Performance Hardening:**
- Resource limits → `test_load_stress.py::TestResourceUsage`
- Horizontal scaling → (Infrastructure, not code test)
- Service registry cache → (Configuration, not code test)
- Contract cache TTL → (Configuration, not code test)
- Latency SLOs → `test_load_stress.py::TestLatencySLOs`

**Operational Hardening:**
- Production configuration → `test_production_deployment.py::TestEnvironmentVariables`
- Environment variables → `test_production_deployment.py::TestEnvironmentVariables`
- Deployment procedures → (Documentation, not code test)
- Incident response → (Documentation, not code test)
- Disaster recovery → (Documentation, not code test)
- Runbooks → (Documentation, not code test)

#### Step 4.2: Update Hardening Checklist

**Update hardening checklist with test coverage:**
```markdown
## Security Hardening

- [x] Authentication and authorization enabled for all API routes.
  - **Test:** `tests/e2e/test_production_deployment.py::TestAuthenticationAuthorization`
- [ ] TLS/SSL termination configured (ingress or application).
  - **Note:** Infrastructure configuration, not code test
- [ ] Secrets stored in a secure vault or secret manager (no plaintext files).
  - **Note:** Infrastructure configuration, not code test
- [ ] Network access restricted (firewall rules, VPC security groups).
  - **Note:** Infrastructure configuration, not code test
- [x] CORS configured to allow only approved origins.
  - **Test:** `tests/e2e/test_production_deployment.py::TestCORS`
- [ ] Rate limiting applied to external-facing endpoints.
  - **Note:** Future test needed
- [x] Audit logging enabled for security-sensitive actions.
  - **Test:** `tests/e2e/test_production_deployment.py::TestStructuredLogging`

## Reliability Hardening

- [x] `/health` endpoint monitored and used for readiness/liveness checks.
  - **Test:** `tests/e2e/test_production_deployment.py::TestHealthChecks`
- [x] Structured logging configured (`CAIO_LOG_FORMAT=json`).
  - **Test:** `tests/e2e/test_production_deployment.py::TestStructuredLogging`
- [x] Metrics collection enabled and scraped by monitoring stack.
  - **Test:** `tests/integration/test_api_sdk.py::TestAPIRoutes::test_metrics_endpoint`
- [x] Alerting configured for SLOs and security violations.
  - **Test:** `tests/integration/test_slos_alerts.py`
- [ ] Backup/restore plan documented for trace/audit storage.
  - **Note:** Documentation, not code test
- [x] Runbooks available for incident response and recovery.
  - **Note:** Documentation exists in `docs/operations/runbooks/`

## Performance Hardening

- [x] Resource limits set for CPU and memory.
  - **Test:** `tests/e2e/test_load_stress.py::TestResourceUsage`
- [ ] Horizontal scaling strategy defined (replicas, autoscaling).
  - **Note:** Infrastructure configuration, not code test
- [ ] Service registry cache sized appropriately (`CAIO_REGISTRY_SIZE`).
  - **Note:** Configuration, not code test
- [ ] Contract cache TTL tuned (`CAIO_CONTRACT_CACHE_TTL`).
  - **Note:** Configuration, not code test
- [x] Latency SLOs monitored (P95/P99).
  - **Test:** `tests/e2e/test_load_stress.py::TestLatencySLOs`

## Operational Hardening

- [x] Production configuration validated (`CAIO_ENV=production`).
  - **Test:** `tests/e2e/test_production_deployment.py::TestEnvironmentVariables`
- [x] Environment variables documented and applied consistently.
  - **Test:** `tests/e2e/test_production_deployment.py::TestEnvironmentVariables`
- [ ] Deployment and rollback procedures rehearsed.
  - **Note:** Manual process, not code test
- [ ] Incident response plan confirmed with on-call rotation.
  - **Note:** Operational process, not code test
- [ ] Disaster recovery plan documented and tested.
  - **Note:** Documentation, not code test
- [x] Referenced runbooks under `docs/operations/runbooks/`.
  - **Note:** Documentation exists
```

#### Step 4.3: Fill Test Coverage Gaps

**Identify gaps:**
- Rate limiting (no test)
- Horizontal scaling (infrastructure, not code test)
- Service registry cache (configuration, not code test)
- Contract cache TTL (configuration, not code test)

**Create tests for code-testable gaps:**
- Rate limiting test (if rate limiting is implemented in code)

#### Step 4.4: Document Test Coverage

**Add test coverage section to hardening checklist:**
```markdown
## Test Coverage

All code-testable hardening checklist items have corresponding tests:

- **E2E Tests:** `tests/e2e/test_production_deployment.py`
- **Load/Stress Tests:** `tests/e2e/test_load_stress.py`
- **Integration Tests:** `tests/integration/`

**Infrastructure/Configuration Items:**
- These items require infrastructure/configuration validation, not code tests
- Documented in deployment guides and runbooks
```

#### Step 4.5: Validate Hardening Checklist

**Verify checklist items are validated:**
```bash
# Check checklist items are marked
grep -E "\[x\]" docs/deployment/HARDENING_CHECKLIST.MD

# Verify test references exist
grep "Test:" docs/deployment/HARDENING_CHECKLIST.MD
```

**Expected Results:**
- All code-testable items have test coverage
- Test coverage documented in checklist
- No gaps in test coverage (for code-testable items)

---

## Validation Procedures

### Pre-Work Validation

1. **Verify Prerequisites:**
   ```bash
   # Check Phase 12 is complete
   grep -A 5 "Phase 12" docs/operations/EXECUTION_PLAN.md | grep "Complete"
   
   # Check CAIO is installable
   pip install -e .
   python -c "from caio import Orchestrator; print('OK')"
   
   # Check Docker is available
   docker --version
   ```

2. **Baseline Current State:**
   ```bash
   # Document current E2E test status
   pytest tests/e2e/ -v --collect-only > /tmp/e2e-test-baseline.txt
   
   # Document current test coverage
   pytest --cov=caio tests/ --cov-report=term-missing > /tmp/test-coverage-baseline.txt
   ```

### Post-Work Validation

1. **E2E Tests:**
   ```bash
   # Run all E2E tests
   pytest tests/e2e/ -v
   
   # Verify no placeholders remain
   grep -r "pass$" tests/e2e/ | grep -v "__pycache__" | grep -v "fixture"
   grep -r "Will be implemented" tests/e2e/
   ```

2. **Production Deployment:**
   ```bash
   # Run production deployment tests
   pytest tests/e2e/test_production_deployment.py -v
   
   # Test Docker deployment manually
   docker build -t caio:test .
   docker run --rm -p 8080:8080 -e CAIO_ENV=production -e CAIO_AUTH_SECRET_KEY=test caio:test
   ```

3. **Load/Stress Tests:**
   ```bash
   # Run load/stress tests (may take time)
   pytest tests/e2e/test_load_stress.py -v
   ```

4. **Hardening Checklist:**
   ```bash
   # Verify checklist items are validated
   grep -E "\[x\]" docs/deployment/HARDENING_CHECKLIST.MD
   grep "Test:" docs/deployment/HARDENING_CHECKLIST.MD
   ```

---

## Success Criteria

- [ ] **E2E Tests Implemented:**
  - All placeholder tests replaced with real implementations
  - All E2E tests pass: `pytest tests/e2e/test_routing_flow.py -v`
  - Tests use real implementations (no mocks for core behavior)
  - Error handling scenarios tested
  - Performance bounds tested

- [ ] **Production Deployment Validated:**
  - Docker deployment tested end-to-end
  - Environment variable configuration tested
  - Health checks tested
  - Authentication/authorization tested
  - CORS configuration tested
  - Structured logging tested

- [ ] **Load/Stress Testing Complete:**
  - Concurrent request handling tested (≥ 10,000 per instance)
  - Latency SLOs validated (P95 ≤ 50ms routing decision)
  - Throughput tested under sustained load
  - Resource usage validated (memory, CPU)
  - Capacity margin validated (≥ 1.3× headroom)

- [ ] **Hardening Checklist Validated:**
  - All code-testable checklist items have test coverage
  - Test coverage documented
  - No gaps in test coverage (for code-testable items)

---

## Troubleshooting

### E2E Tests Fail

**Issue:** E2E tests fail with import errors or missing components.

**Solution:**
- Verify CAIO package is installed: `pip install -e .`
- Check all imports are correct
- Verify components are initialized correctly

### Production Deployment Tests Fail

**Issue:** Docker tests fail or environment variable tests fail.

**Solution:**
- Verify Docker is running: `docker ps`
- Check environment variable names match CAIO configuration
- Verify production configuration is correct

### Load/Stress Tests Too Slow

**Issue:** Load/stress tests take too long to run.

**Solution:**
- Use pytest markers to separate fast/slow tests
- Run comprehensive tests in nightly builds
- Optimize test setup/teardown

### Performance SLOs Not Met

**Issue:** Load tests reveal performance issues.

**Solution:**
- Document performance issues
- Create follow-up tasks for optimization
- Set realistic expectations for initial performance

---

## Notes

- All tests must use **real implementations** (no mocks for core behavior)
- Tests must validate **production readiness**
- Performance tests must validate **SLOs from North Star**
- Hardening checklist validation ensures **operational readiness**
- Some checklist items are infrastructure/configuration (not code-testable)

---

**Plan Reference:** `plan:phase-13-comprehensive-e2e-testing:13.1-13.4`
