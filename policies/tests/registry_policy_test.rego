package supply.registry

import rego.v1

test_rejeita_dockerhub if {
    bad := {"spec": {"template": {"spec": {"containers": [{"name": "api", "image": "nginx:1.27"}]}}}}
    result := deny with input as bad
    count(result) > 0
}

test_aceita_ghcr if {
    good := {"spec": {"template": {"spec": {"containers": [{"name": "api", "image": "ghcr.io/acme/api:v1"}]}}}}
    result := deny with input as good
    count(result) == 0
}
