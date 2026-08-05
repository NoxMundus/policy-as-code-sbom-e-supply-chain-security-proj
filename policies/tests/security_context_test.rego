package supply.security_context

import rego.v1

test_rejeita_root if {
    bad := {"spec": {"template": {"spec": {"automountServiceAccountToken": false, "containers": [{"name": "api", "securityContext": {"runAsNonRoot": false, "allowPrivilegeEscalation": false, "readOnlyRootFilesystem": true}}]}}}}
    result := deny with input as bad
    count(result) > 0
}

test_aceita_contexto_seguro if {
    good := {"spec": {"template": {"spec": {"automountServiceAccountToken": false, "containers": [{"name": "api", "securityContext": {"runAsNonRoot": true, "allowPrivilegeEscalation": false, "readOnlyRootFilesystem": true}}]}}}}
    result := deny with input as good
    count(result) == 0
}
