# api-pagamentos - Projeto final integrador DevSecOps

## 1. Contexto

A `api-pagamentos` e uma aplicacao ficticia usada para demonstrar uma esteira de compliance continuo. O objetivo e cobrir Policy as Code, SBOM, assinatura keyless, provenance SLSA, gate de admissao, auditoria e dashboard.

## 2. Arquitetura

Fluxo principal:

1. Desenvolvedor envia codigo para o GitHub.
2. O workflow `verify.yml` executa testes da aplicacao, `opa test`, build local, SBOM, evidencia `cyclonedx-analyze` e validacao de licencas.
3. Uma tag `v*` dispara o workflow `release.yml`.
4. O pipeline publica imagem no GHCR, gera SBOM CycloneDX e SPDX, executa scan, assina a imagem com Cosign keyless e anexa attestations (SBOM, vuln, SLSA provenance).
5. O cluster Kubernetes usa Sigstore Policy Controller e `ClusterImagePolicy` para bloquear imagens sem assinatura valida.
6. Scripts de auditoria geram relatorio mensal e dashboard de KPIs.

## 3. Controles implementados

| Camada | Controle | Evidencia |
|---|---|---|
| Policy as Code | 6 policies Rego | `opa test policies/` |
| Policy as Code | Testes positivos e negativos | `policies/tests/*_test.rego` |
| Admission Control | ClusterImagePolicy | `k8s/policy-controller-policy.yaml` |
| SBOM | CycloneDX | `sbom.cdx.json` anexado ao release |
| SBOM | SPDX | `sbom.spdx.json` anexado ao release |
| Licencas | Bloqueio GPL-3.0, AGPL-3.0, SSPL | `scripts/valida_licencas_sbom.py` e `cyclonedx-analyze.log` |
| Cadeia | Cosign keyless | `cosign verify` |
| Cadeia | SLSA Provenance | `cosign verify-attestation --type slsaprovenance` |
| Auditoria | Relatorio mensal | `scripts/gera_relatorio.sh` |
| Dashboard | KPIs de compliance | `scripts/gera_dashboard.py` |

## 4. Mapeamento para frameworks

| Controle tecnico | NIST SSDF SP 800-218 | SLSA | ISO 27001 |
|---|---|---|---|
| Branch/PR com validacao OPA | PW.4, PW.7 | Source integrity | A.8.25 Secure development lifecycle |
| Build automatizado no GitHub Actions | PW.6 | Build service | A.8.32 Change management |
| SBOM CycloneDX e SPDX | PS.3, RV.1 | Dependencies metadata | A.8.8 Management of technical vulnerabilities |
| Scan de vulnerabilidades | RV.1, RV.2 | Dependency risk | A.8.8 Management of technical vulnerabilities |
| Cosign keyless via OIDC | PS.2, PS.3 | Provenance and signing | A.8.24 Use of cryptography |
| SLSA Provenance | PS.3 | Provenance | A.5.37 Documented operating procedures |
| ClusterImagePolicy | PW.9, RV.3 | Deployment policy | A.8.9 Configuration management |
| Relatorio mensal | PO.3, RV.1 | Verification evidence | A.5.35 Independent review of information security |
| Dashboard de KPIs | PO.5, RV.1 | Continuous improvement | A.5.36 Compliance with policies |

## 5. Como executar localmente

\`\`\`bash
npm --prefix app install
npm --prefix app test
opa test policies/
docker build -t api-pagamentos:local .
./scripts/gera_sbom.sh api-pagamentos:local evidence/sbom-local
./scripts/cyclonedx_analyze.sh evidence/sbom-local/sbom.cdx.json evidence/cyclonedx-analyze.log
python scripts/valida_licencas_sbom.py evidence/sbom-local/sbom.cdx.json
python scripts/consulta_dt.py evidence/sbom-local/sbom.cdx.json
\`\`\`

## 6. Como gerar release

\`\`\`bash
git tag v1.0.0
git push origin v1.0.0
\`\`\`

## 7. Como verificar assinatura e provenance

\`\`\`bash
export GH_USER="NoxMundus"
export REPO_NAME="api-pagamentos"
export IMAGE="ghcr.io/$GH_USER/$REPO_NAME:v1.0.0"

cosign verify "$IMAGE" \\
  --certificate-identity-regexp "^https://github.com/$GH_USER/$REPO_NAME/.*" \\
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

cosign verify-attestation "$IMAGE" \\
  --type slsaprovenance \\
  --certificate-identity-regexp "^https://github.com/$GH_USER/$REPO_NAME/.*" \\
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
\`\`\`

## 8. Como demonstrar bloqueio de imagem sem assinatura

\`\`\`bash
kubectl run intruso --image=nginx:latest -n producao
\`\`\`

Resultado esperado: admission webhook negando a requisicao por ausencia de assinatura ou attestation aceita.

## 9. KPIs

1. Percentual de releases assinadas.
2. Percentual de releases com provenance SLSA.
3. Percentual de releases com SBOM CycloneDX.
4. Percentual de releases com SBOM SPDX.
5. Quantidade de releases no mes.

## 10. Decisoes de projeto

- A aplicacao e propositalmente simples para concentrar a avaliacao na cadeia DevSecOps.
- OPA e usado para Policy as Code em PR.
- Sigstore Policy Controller e usado para assinatura no admission, pois `ClusterImagePolicy` pertence a esse ecossistema.
- Cosign keyless evita gestao de chaves longas e usa identidade OIDC do GitHub Actions.
- SLSA Provenance cria evidencia verificavel da origem e do processo de build.
- Dependency-Track pode ser real ou mockado conforme permissao do ambiente do estudante.
