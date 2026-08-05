package supply.security_context

import rego.v1

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.runAsNonRoot == true
    msg := sprintf("container %v deve usar runAsNonRoot=true", [container.name])
}

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.allowPrivilegeEscalation == false
    msg := sprintf("container %v deve usar allowPrivilegeEscalation=false", [container.name])
}

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem == true
    msg := sprintf("container %v deve usar readOnlyRootFilesystem=true", [container.name])
}

deny contains msg if {
    not input.spec.template.spec.automountServiceAccountToken == false
    msg := "automountServiceAccountToken deve ser false"
}
