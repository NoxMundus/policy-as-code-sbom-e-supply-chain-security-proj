#!/usr/bin/env bash
set -euo pipefail

IMAGE_REF="${1:-}"
OUT_DIR="${2:-evidence/sbom}"

if [ -z "$IMAGE_REF" ]; then
    echo "Uso: scripts/gera_sbom.sh <imagem> [diretorio_saida]"
    exit 1
fi

mkdir -p "$OUT_DIR"

# Gera o SBOM usando o Syft nos formatos CycloneDX e SPDX
syft "$IMAGE_REF" -o cyclonedx-json="$OUT_DIR/sbom.cdx.json" -o spdx-json="$OUT_DIR/sbom.spdx.json"

# Conta a quantidade de componentes gerados
jq '.components | length' "$OUT_DIR/sbom.cdx.json" > "$OUT_DIR/component-count.txt"

echo "SBOM CycloneDX: $OUT_DIR/sbom.cdx.json"
echo "SBOM SPDX: $OUT_DIR/sbom.spdx.json"
echo "Componentes: $(cat "$OUT_DIR/component-count.txt")"
