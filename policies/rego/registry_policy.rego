package supply.registry

import rego.v1

allowed_registries := {"ghcr.io/"}

deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not startswith_allowed(container.image)
    msg := sprintf("imagem %v nao vem de registry permitido", [container.image])
}

startswith_allowed(image) if {
    some registry in allowed_registries
    startswith(image, registry)
}
