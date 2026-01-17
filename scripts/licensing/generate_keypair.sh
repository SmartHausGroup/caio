#!/usr/bin/env bash
set -euo pipefail

# Generate an RSA keypair for CAIO license signing.
# Usage: ./scripts/licensing/generate_keypair.sh [output_dir]

OUTPUT_DIR="${1:-./keys}"
PRIVATE_KEY="${OUTPUT_DIR}/private.pem"
PUBLIC_KEY="${OUTPUT_DIR}/public.pem"

mkdir -p "${OUTPUT_DIR}"
umask 077

if [[ -f "${PRIVATE_KEY}" || -f "${PUBLIC_KEY}" ]]; then
  echo "Key files already exist in ${OUTPUT_DIR}. Aborting." >&2
  exit 1
fi

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "${PRIVATE_KEY}"
openssl rsa -in "${PRIVATE_KEY}" -pubout -out "${PUBLIC_KEY}"

echo "Generated keys:"
echo "  Private: ${PRIVATE_KEY}"
echo "  Public : ${PUBLIC_KEY}"
