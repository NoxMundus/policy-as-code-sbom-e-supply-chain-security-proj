package supply.license

import rego.v1

denied_licenses := {"GPL-3.0-only", "AGPL-3.0-only", "SSPL-1.0"}

deny contains msg if {
    component := input.components[_]
    license := component.licenses[_].license.id
    denied_licenses[license]
    msg := sprintf("componente %v viola licenca proibida %v", [component.name, license])
}
