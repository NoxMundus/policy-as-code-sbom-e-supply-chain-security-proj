package supply.resources

import rego.v1

test_rejeita_sem_limits if {
    bad := {"spec": {"template": {"spec": {"containers": [{"name": "api", "resources": {"requests": {"cpu": "100m", "memory": "128Mi"}}}]}}}}
    result := deny with input as bad
    count(result) > 0
}

test_aceita_com_resources if {
    good := {"spec": {"template": {"spec": {"containers": [{"name": "api", "resources": {"requests": {"cpu": "100m", "memory": "128Mi"}, "limits": {"cpu": "500m", "memory": "256Mi"}}}]}}}}
    result := deny with input as good
    count(result) == 0
}
