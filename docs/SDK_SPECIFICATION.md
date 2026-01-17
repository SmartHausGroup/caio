# CAIO SDK Specification

**Status**: Rev 1.0  
**Last Updated**: 2025-01-XX  
**Owner**: @smarthaus

---

## Purpose

The CAIO SDK defines both:
1. **Service Implementation Interface**: How to implement a CAIO-compatible service
2. **Contract Specification**: How to define service contracts (YAML schema)

This document specifies both aspects of the SDK.

---

## 1. Service Implementation Interface

### 1.1 Core Interface

All CAIO-compatible services must implement the following interface:

```python
from abc import ABC, abstractmethod
from typing import Any, Dict, Optional
from pathlib import Path

class AIUCPService(ABC):
    """
    Base interface for CAIO-compatible services.
    All services must implement this interface.
    """
    
    @abstractmethod
    def initialize(self, contract_path: Path) -> None:
        """
        Initialize service with contract.
        
        Args:
            contract_path: Path to service contract YAML file
            
        Raises:
            ContractValidationError: If contract is invalid
            ServiceInitializationError: If service fails to initialize
        """
        pass
    
    @abstractmethod
    async def execute(
        self, 
        request: Dict[str, Any], 
        context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Execute request.
        
        Args:
            request: Request data (format defined by contract)
            context: Optional context (user, session, etc.)
            
        Returns:
            Result data (format defined by contract)
            
        Raises:
            ServiceExecutionError: If execution fails
            GuaranteeViolationError: If guarantees are violated
        """
        pass
    
    @abstractmethod
    async def verify_guarantees(
        self,
        result: Dict[str, Any],
        contract: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Verify guarantees are met.
        
        Args:
            result: Execution result
            contract: Service contract
            
        Returns:
            Verification proof with guarantee status
            
        Raises:
            GuaranteeViolationError: If guarantees are violated
        """
        pass
    
    @abstractmethod
    def get_health_status(self) -> Dict[str, Any]:
        """
        Get service health status.
        
        Returns:
            Health status dictionary
        """
        pass
```

### 1.2 Python Implementation Example

```python
from caio_sdk import AIUCPService, ContractValidationError, GuaranteeViolationError
from pathlib import Path
import yaml
import asyncio

class MyService(AIUCPService):
    """Example service implementation."""
    
    def __init__(self):
        self.contract = None
        self.initialized = False
    
    def initialize(self, contract_path: Path) -> None:
        """Initialize service with contract."""
        # Load and validate contract
        with open(contract_path) as f:
            contract = yaml.safe_load(f)
        
        # Validate contract against schema
        if not self._validate_contract(contract):
            raise ContractValidationError("Invalid contract")
        
        self.contract = contract
        self.initialized = True
    
    async def execute(
        self, 
        request: Dict[str, Any], 
        context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Execute request."""
        if not self.initialized:
            raise ServiceInitializationError("Service not initialized")
        
        # Execute service logic
        result = await self._do_work(request, context)
        
        # Verify guarantees
        verification = await self.verify_guarantees(result, self.contract)
        if not verification["all_guarantees_met"]:
            raise GuaranteeViolationError("Guarantees violated")
        
        return result
    
    async def verify_guarantees(
        self,
        result: Dict[str, Any],
        contract: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Verify guarantees are met."""
        proofs = {}
        all_met = True
        
        # Verify accuracy guarantee
        if "accuracy" in contract["service"]["guarantees"]:
            accuracy = result.get("accuracy", 0.0)
            min_accuracy = contract["service"]["guarantees"]["accuracy"]["bound"]["min"]
            proofs["accuracy"] = {
                "met": accuracy >= min_accuracy,
                "value": accuracy,
                "bound": min_accuracy
            }
            if accuracy < min_accuracy:
                all_met = False
        
        # Verify latency guarantee
        if "latency" in contract["service"]["guarantees"]:
            latency = result.get("latency_ms", float("inf"))
            max_latency = contract["service"]["guarantees"]["latency"]["bound"]["max"]
            proofs["latency"] = {
                "met": latency <= max_latency,
                "value": latency,
                "bound": max_latency
            }
            if latency > max_latency:
                all_met = False
        
        return {
            "all_guarantees_met": all_met,
            "proofs": proofs
        }
    
    def get_health_status(self) -> Dict[str, Any]:
        """Get service health status."""
        return {
            "status": "healthy" if self.initialized else "uninitialized",
            "service_id": self.contract["service"]["id"] if self.contract else None
        }
    
    def _validate_contract(self, contract: Dict[str, Any]) -> bool:
        """Validate contract against schema."""
        # Implementation would use JSON schema validation
        return True
    
    async def _do_work(self, request: Dict[str, Any], context: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        """Actual service work."""
        # Service-specific implementation
        return {"result": "success"}
```

### 1.3 SDK Installation

```bash
pip install caio-sdk
```

### 1.4 SDK Requirements

- **Python**: 3.11+
- **Dependencies**: 
  - `pyyaml` (contract parsing)
  - `jsonschema` (contract validation)
  - `asyncio` (async execution)

---

## 2. Contract Specification

### 2.1 Contract Schema

Service contracts are defined in YAML format following the schema defined in `configs/schemas/service_contract.schema.yaml`.

### 2.2 Contract Registration

Services register with CAIO by uploading their contract:

```python
from caio_sdk import CAIOClient

# Initialize CAIO client
client = CAIOClient(base_url="http://caio:8000")

# Register service contract
contract_path = Path("my_service_contract.yaml")
service_id = await client.register_service(contract_path)

print(f"Service registered with ID: {service_id}")
```

### 2.3 Contract Validation

Contracts are validated against the schema before registration:

```python
from caio_sdk import validate_contract

contract_path = Path("my_service_contract.yaml")
is_valid, errors = validate_contract(contract_path)

if not is_valid:
    print(f"Contract validation failed: {errors}")
else:
    print("Contract is valid")
```

---

## 3. Security Requirements

All services must implement:

### 3.1 Authentication

- Services must authenticate requests using JWT tokens
- Token validation is handled by CAIO (services receive authenticated requests)

### 3.2 Authorization

- Services must check user permissions against required permissions
- Authorization is verified before routing

### 3.3 Encryption

- Services handling sensitive data must use end-to-end encryption
- Encryption type specified in contract (`privacy.encryption_type`)

### 3.4 Audit Logging

- Services must log all requests and responses
- Logs must include: request ID, user ID, timestamp, result

---

## 4. Mathematical Guarantees

### 4.1 Guarantee Verification

Services must verify their guarantees:

- **Accuracy**: Measure and verify accuracy bounds
- **Latency**: Measure and verify latency bounds
- **Determinism**: Verify deterministic output (with seed)
- **Throughput**: Measure and verify throughput bounds

### 4.2 Proof Generation

Services must generate mathematical proofs for guarantee verification:

```python
proof = {
    "guarantee": "accuracy",
    "value": 0.97,
    "bound": {"min": 0.95},
    "met": True,
    "verification_method": "test_set_evaluation",
    "test_set_size": 10000,
    "confidence": 0.99
}
```

---

## 5. SDK Examples

### 5.1 Minimal Service

```python
from caio_sdk import AIUCPService
from pathlib import Path

class MinimalService(AIUCPService):
    def initialize(self, contract_path: Path) -> None:
        # Load contract
        pass
    
    async def execute(self, request, context=None):
        return {"result": "ok"}
    
    async def verify_guarantees(self, result, contract):
        return {"all_guarantees_met": True, "proofs": {}}
    
    def get_health_status(self):
        return {"status": "healthy"}
```

### 5.2 Service with Guarantees

See full example in Section 1.2.

---

## 6. Contract Examples

See `configs/schemas/service_contract.example.yaml` for a complete example.

---

## 7. Integration with CAIO

### 7.1 Service Registration Flow

1. **Develop Service**: Implement `AIUCPService` interface
2. **Define Contract**: Create YAML contract following schema
3. **Validate Contract**: Use SDK to validate contract
4. **Register Service**: Upload contract to CAIO
5. **Service Available**: CAIO can now route requests to service

### 7.2 Request Flow

1. **Request Arrives**: CAIO receives request
2. **Service Discovery**: CAIO matches request to service contracts
3. **Rule Application**: CAIO applies rules and constraints
4. **Security Verification**: CAIO verifies security properties
5. **Service Execution**: CAIO routes to selected service
6. **Guarantee Verification**: Service verifies guarantees
7. **Result Returned**: CAIO returns result with proof

---

## References

- **Contract Schema**: `configs/schemas/service_contract.schema.yaml`
- **Contract Example**: `configs/schemas/service_contract.example.yaml`
- **CAIO North Star**: `docs/NORTH_STAR.md`
- **Mathematical Foundation**: `docs/math/CAIO_MASTER_CALCULUS.md`

