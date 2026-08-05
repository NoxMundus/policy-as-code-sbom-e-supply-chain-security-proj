#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path
from urllib import request, parse

if len(sys.argv) < 2:
    print("Uso: scripts/consulta_dt.py <sbom.cdx.json>")
    sys.exit(1)

sbom_path = Path(sys.argv[1])
url = os.getenv("DT_URL", "mock")
api_key = os.getenv("DT_API_KEY", "mock")
project_name = os.getenv("DT_PROJECT_NAME", "api-pagamentos")
project_version = os.getenv("DT_PROJECT_VERSION", "local")

if url == "mock" or api_key == "mock":
    print("MOCK Dependency-Track")
    print(json.dumps({
        "status": "mocked",
        "projectName": project_name,
        "projectVersion": project_version,
        "bom": str(sbom_path),
        "message": "SBOM aceito em modo simulado para evidencia do laboratorio"
    }, indent=2))
    sys.exit(0)

payload = {
    "projectName": project_name,
    "projectVersion": project_version,
    "autoCreate": "true",
    "bom": sbom_path.read_text(encoding="utf-8")
}

data = parse.urlencode(payload).encode()
req = request.Request(
    f"{url.rstrip('/')}/api/v1/bom",
    data=data,
    headers={"X-Api-Key": api_key, "Content-Type": "application/x-www-form-urlencoded"},
    method="PUT"
)

with request.urlopen(req, timeout=30) as resp:
    print(resp.status)
    print(resp.read().decode())
