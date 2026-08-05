#!/usr/bin/env bash
set -euo pipefail

MES="${1:-$(date +%Y-%m)}"
REPO="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
IMAGE="ghcr.io/$REPO"
OUT_DIR="relatorios/$MES"

mkdir -p "$OUT_DIR"

echo "Coletando releases de $REPO para o mes $MES"

gh release list --repo "$REPO" --limit 100 --json tagName,publishedAt,isDraft,isPrerelease \
  | jq --arg m "$MES" '[.[] | select(.publishedAt | startswith($m))]' \
  > "$OUT_DIR/releases.json"

echo "tag,assinatura,provenance,sbom_cyclonedx,sbom_spdx" > "$OUT_DIR/conformidade.csv"

jq -r '.[].tagName' "$OUT_DIR/releases.json" | while read -r TAG; do
  [ -z "$TAG" ] && continue
  IMG="$IMAGE:$TAG"

  SIG_OK=$(cosign verify "$IMG" \
    --certificate-identity-regexp "^https://github.com/$REPO/.*" \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com \
    >/dev/null 2>&1 && echo "sim" || echo "nao")

  PROV_OK=$(cosign verify-attestation "$IMG" \
    --type slsaprovenance \
    --certificate-identity-regexp "^https://github.com/$REPO/.*" \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com \
    >/dev/null 2>&1 && echo "sim" || echo "nao")

  CDX_OK=$(gh release view "$TAG" --repo "$REPO" --json assets -q '.assets[].name' \
    | grep -q '^sbom.cdx.json$' && echo "sim" || echo "nao")

  SPDX_OK=$(gh release view "$TAG" --repo "$REPO" --json assets -q '.assets[].name' \
    | grep -q '^sbom.spdx.json$' && echo "sim" || echo "nao")

  echo "$TAG,$SIG_OK,$PROV_OK,$CDX_OK,$SPDX_OK" >> "$OUT_DIR/conformidade.csv"
done

echo "Relatorio gerado em $OUT_DIR/conformidade.csv"
