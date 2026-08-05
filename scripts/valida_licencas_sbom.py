#!/usr/bin/env python3
import json
import sys
from pathlib import Path

DENIED = {"GPL-3.0-only", "AGPL-3.0-only", "SSPL-1.0"}

if len(sys.argv) < 2:
    print("Uso: scripts/valida_licencas_sbom.py <sbom.cdx.json>")
    sys.exit(1)

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))

violations = []
for component in data.get("components", []):
    name = component.get("name", "sem-nome")
    for lic in component.get("licenses", []) or []:
        license_obj = lic.get("license", {})
        license_id = license_obj.get("id") or license_obj.get("name")
        if license_id in DENIED:
            violations.append((name, license_id))

if violations:
    print("FALHA: licencas proibidas encontradas")
    for name, license_id in violations:
        print(f"- {name}: {license_id}")
    sys.exit(2)

print("OK: nenhuma licenca proibida encontrada")
sys.exit(0)
