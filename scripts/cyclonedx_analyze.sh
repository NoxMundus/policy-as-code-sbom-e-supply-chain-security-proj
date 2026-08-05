#!/usr/bin/env bash
set -euo pipefail

SBOM="${1:-evidence/sbom/sbom.cdx.json}"
OUT="${2:-evidence/cyclonedx-analyze.log}"

mkdir -p "$(dirname "$OUT")"

if command -v cyclonedx >/dev/null 2>&1; then
  cyclonedx analyze --input-file "$SBOM" > "$OUT" 2>&1 || true
elif command -v cyclonedx-cli >/dev/null 2>&1; then
  cyclonedx-cli analyze --input-file "$SBOM" > "$OUT" 2>&1 || true
else
  echo "CycloneDX CLI nao instalado. Evidencia alternativa: validacao de licencas pelo script Python." > "$OUT"
fi

cat "$OUT"
