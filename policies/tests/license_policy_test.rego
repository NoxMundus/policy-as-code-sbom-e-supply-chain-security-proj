package supply.license

import rego.v1

test_rejeita_gpl3 if {
    bad := {"components": [{"name": "lib-ruim", "licenses": [{"license": {"id": "GPL-3.0-only"}}]}]}
    result := deny with input as bad
    count(result) > 0
}

test_aceita_mit if {
    good := {"components": [{"name": "lib-boa", "licenses": [{"license": {"id": "MIT"}}]}]}
    result := deny with input as good
    count(result) == 0
}
