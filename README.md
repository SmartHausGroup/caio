# CAIO - Coordinatio Auctus Imperium Ordo

**Universal AI Orchestration Platform**

---

## Quick Start

### Prerequisites

- Python 3.14+ (or 3.11+)
- Jupyter Notebook (for running verification notebooks)
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/SmartHausGroup/CAIO.git
cd CAIO

# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install development dependencies (if available)
pip install pytest pytest-asyncio httpx
```

## Quick Start - Prototype Demo

See CAIO in action with our standalone prototypes:

- Standalone Python Demo: `python caio_prototype_demo.py`
- HTTP API Demo: See `docs/prototype/API_PROTOTYPE.md`

For detailed instructions, see `docs/prototype/README.md`.

## Installation

### Enterprise / Standalone (Primary)

For enterprise or standalone usage (requires license):

**Option A: Docker (Recommended)**
```bash
docker login registry.smarthaus.group
docker pull registry.smarthaus.group/caio:v0.1.0
```

**Option B: Python Wheel (Fallback)**
Install via signed download link (provided with license):
```bash
pip install https://download.smarthaus.group/caio-0.1.0-py3-none-any.whl?token=YOUR_LICENSE_KEY
```

### Internal Development (TAI)

For internal development or TAI integration:

```bash
pip install -e .
```


See `docs/deployment/PACKAGING.md` for packaging and distribution details.

## Integration

- **TAI Integration:** `docs/integration/TAI_INTEGRATION.md`
- **Prototype Demo:** `docs/prototype/README.md`

### Development Setup

```bash
# Run all CI checks locally before pushing
make validate-local

# Or use script directly
./scripts/local/validate.sh development

# Run verification notebooks
make notebooks-plan

# Run MA validation
make ma-validate-quiet
```

### Run Complete CI Replication

```bash
# Replicates entire GitHub Actions workflow locally
make ci-local

# Or specify branch
./scripts/local/ci-replicate.sh staging
```

### Promote Branches Locally

```bash
# Promote development → staging
make promote-local SOURCE=development TARGET=staging

# Promote staging → main
./scripts/local/promote.sh staging main
```

---

## Overview

CAIO (Coordinatio Auctus Imperium Ordo) is a universal AI orchestration platform that provides:
- Mathematical guarantees for all routing decisions
- Contract-based service discovery
- Security built into the math
- Provable and traceable actions
- Hot-swappable service registration

---

## MA Process Status

- ✅ Phase 1-3: Complete (Math → Lemmas → Invariants)
- ✅ Phase 4: Complete (12/12 verification notebooks)
- ✅ Phase 5: Complete (CI infrastructure ready)
- ⏳ Phase 6: Pending (Code implementation)

**Scorecard:** GREEN (12/12 invariants pass)

---

## Documentation

### Core Documentation
- **North Star:** `docs/NORTH_STAR.md` - Strategic vision and mathematical foundations
- **Master Calculus:** `docs/math/CAIO_MASTER_CALCULUS.md` - Mathematical foundations
- **SDK Specification:** `docs/SDK_SPECIFICATION.md` - Service implementation interface

### Development Documentation
- **Developer Guide:** `docs/developer/DEVELOPER_GUIDE.md` - Development setup and guidelines
- **API Reference:** `docs/api/API_REFERENCE.md` - REST API endpoints
- **Configuration API:** `docs/api/CONFIGURATION_API.md` - Configuration dashboard endpoints
- **Configuration:** `docs/configuration/CONFIGURATION.md` - Configuration options

### User Documentation
- **User Guide:** `docs/user/USER_GUIDE.md` - Getting started and usage
- **Configuration Dashboard Guide:** `docs/dashboard/USER_GUIDE.md` - Dashboard setup and usage

### Operations Documentation
- **Local CI:** `docs/LOCAL_CI.md` - Reduce GitHub Actions costs
- **Promotion Workflow:** `docs/PROMOTION_WORKFLOW.md` - Branch promotion process
- **Branch Structure:** `docs/BRANCH_STRUCTURE.md` - Git workflow
- **MA Process:** `docs/MA_PROCESS_STATUS.md` - Mathematical Autopsy process
- **Production Deployment:** `docs/deployment/PRODUCTION_DEPLOYMENT.md` - Production deployment guide
- **Environment Variables:** `docs/deployment/ENVIRONMENT_VARIABLES.md` - Configuration reference
- **Packaging & Distribution:** `docs/deployment/PACKAGING.md` - Packaging and release workflow
- **Hardening Checklist:** `docs/deployment/HARDENING_CHECKLIST.md` - Production hardening checklist
- **TAI Integration:** `docs/integration/TAI_INTEGRATION.md` - TAI integration guide
- **Update Mechanism:** `docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md` - Standard update API and lifecycle management

---

## Update Management API

CAIO exposes standardized update endpoints for embedded lifecycle management:

- `POST /api/v1/update` - Download and install an update package (admin-only)
- `POST /api/v1/restart` - Restart CAIO after update (admin-only)
- `GET /api/v1/version` - Report current running version (public)

These endpoints match the Update Mechanism Architecture used across the TAI ecosystem.

---

## Makefile Targets

```bash
make help              # Show all available targets
make notebooks-plan    # Execute all verification notebooks
make ma-validate-quiet # Run MA validation (notebooks + gates)
make ma-status        # Show MA process status

# Local CI (reduces GitHub Actions costs)
make validate-local    # Run local validation
make promote-local     # Promote branches locally
make ci-local          # Complete CI replication
```

---

## Branch Flow

```
feature/* → development → staging → main
```

- **development**: Integration branch (allows yellow scorecard)
- **staging**: Pre-production (requires green scorecard)
- **main**: Production (requires green scorecard + extra checks)

---

## Cost Reduction Strategy

**Run CI locally before pushing:**
1. `make validate-local` - Run all checks locally
2. Fix any issues
3. Push only when local validation passes
4. GitHub Actions becomes a quick verification step

This reduces GitHub Actions minutes used and provides faster feedback.

---

## License

[Add license here]

---

## Contributing

See `docs/MA_PROCESS_STATUS.md` for development process and MA requirements.

## Development Workflow

Before committing, always run: `pre-commit run --all-files`
