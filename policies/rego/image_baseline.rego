package supply.image_baseline

import rego.v1

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf("container %v usa tag latest, que e proibida", [container.name])
}

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf("container %v precisa declarar tag explicita", [container.name])
}
