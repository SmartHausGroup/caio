# CAIO Packaging & Distribution Guide

## Enterprise Distribution Strategy

CAIO is distributed to enterprise customers via **Private Docker Images** (primary) or **Secure Wheel Downloads** (fallback). Source code access is NOT provided to customers.

### 1. Docker Distribution (Primary)

Customers pull the image from our private registry:

```bash
docker login registry.smarthaus.group
docker pull smarthaus/caio:v0.1.0
```

**Build Process:**
```bash
./scripts/release/build_docker.sh
```

### 2. Wheel Distribution (Fallback)

Customers install via a presigned/tokenized URL:

```bash
pip install https://download.smarthaus.group/caio-0.1.0-py3-none-any.whl?token=LICENSE_KEY
```

**Build Process:**
```bash
./scripts/release/build_wheel.sh
```

## Internal Development

For internal TAI development, use editable installs or git SSH:

```bash
# Editable (Best for dev)
pip install -e .

# Git SSH (Best for CI)
pip install git+ssh://git@github.com/SmartHausGroup/CAIO.git@development
```
