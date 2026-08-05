package supply.sbom_required

import rego.v1

test_rejeita_sem_spdx if {
    bad := {"metadata": {"sbom": {"cyclonedx": true}}}
    result := deny with input as bad
    count(result) > 0
}

test_aceita_com_cyclonedx_e_spdx if {
    good := {"metadata": {"sbom": {"cyclonedx": true, "spdx": true}}}
    result := deny with input as good
    count(result) == 0
}
