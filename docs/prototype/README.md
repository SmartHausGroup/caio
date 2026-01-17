# CAIO Prototype Demos

This directory contains prototype demonstrations of CAIO functionality.

## Overview

Two prototypes are available:
1. Standalone Python Prototype (programmatic API)
2. HTTP API Prototype (curl examples)

## Prerequisites

- Python 3.10+
- CAIO installed (`pip install -e .`) or run from repository root
- For HTTP API prototype: CAIO server running with an auth token

## Standalone Python Prototype

Run the standalone Python prototype:

```bash
python caio_prototype_demo.py
```

This demonstrates:
- Orchestrator instantiation
- Service registration
- Request orchestration
- Routing decision display (guarantees, proofs, trace)

If imports fail, run from repo root or use:

```bash
PYTHONPATH=. python caio_prototype_demo.py
```

## HTTP API Prototype

See `API_PROTOTYPE.md` for HTTP API examples with curl.

## Expected Outputs

Both prototypes should show:
- Service registration success
- Routing decision with guarantees
- Mathematical proofs
- Traceability details

## Troubleshooting

See `API_PROTOTYPE.md` troubleshooting section for common issues and fixes.
