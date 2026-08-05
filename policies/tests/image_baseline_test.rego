package supply.image_baseline

import rego.v1

test_rejeita_latest if {
    bad := {"spec": {"template": {"spec": {"containers": [{"name": "api", "image": "ghcr.io/acme/api:latest"}]}}}}
    result := deny with input as bad
    count(result) > 0
}

test_aceita_tag_explicita if {
    good := {"spec": {"template": {"spec": {"containers": [{"name": "api", "image": "ghcr.io/acme/api:v1.0.0"}]}}}}
    result := deny with input as good
    count(result) == 0
}
