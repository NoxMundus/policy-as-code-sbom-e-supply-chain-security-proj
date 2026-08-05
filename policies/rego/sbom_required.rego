package supply.sbom_required

import rego.v1

deny contains msg if {
    not input.metadata.sbom.cyclonedx
    msg := "evidencia de SBOM CycloneDX obrigatoria"
}

deny contains msg if {
    not input.metadata.sbom.spdx
    msg := "evidencia de SBOM SPDX obrigatoria"
}
