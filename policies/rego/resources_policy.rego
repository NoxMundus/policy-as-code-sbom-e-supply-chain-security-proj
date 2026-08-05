package supply.resources

import rego.v1

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
    msg := sprintf("container %v deve declarar requests.cpu", [container.name])
}

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.memory
    msg := sprintf("container %v deve declarar requests.memory", [container.name])
}

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.cpu
    msg := sprintf("container %v deve declarar limits.cpu", [container.name])
}

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf("container %v deve declarar limits.memory", [container.name])
}
