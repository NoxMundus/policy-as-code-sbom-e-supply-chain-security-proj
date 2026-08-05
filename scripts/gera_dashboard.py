#!/usr/bin/env python3
import csv
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print("Uso: scripts/gera_dashboard.py relatorios/YYYY-MM/conformidade.csv")
    sys.exit(1)

csv_path = Path(sys.argv[1])
rows = list(csv.DictReader(csv_path.open(encoding="utf-8")))
total = len(rows)

def pct(field):
    if total == 0:
        return 0
    yes = sum(1 for r in rows if r.get(field) == "sim")
    return round(100 * yes / total, 1)

kpis = {
    "Releases no mes": total,
    "% imagens assinadas": pct("assinatura"),
    "% com provenance": pct("provenance"),
    "% com SBOM CycloneDX": pct("sbom_cyclonedx"),
    "% com SBOM SPDX": pct("sbom_spdx"),
}

cards = "".join(f"<div class='card'><h2>{k}</h2><p>{v}</p></div>" for k, v in kpis.items())

lines = "".join(
    f"<tr><td>{r['tag']}</td><td>{r['assinatura']}</td><td>{r['provenance']}</td>"
    f"<td>{r['sbom_cyclonedx']}</td><td>{r['sbom_spdx']}</td></tr>"
    for r in rows
)

html = f"""
<!doctype html>
<html lang='pt-BR'>
<head>
<meta charset='utf-8'>
<title>Dashboard api-pagamentos</title>
<style>
  body {{ font-family: Arial, sans-serif; margin: 32px; background:#f6f8fb; color:#172033; }}
  h1 {{ color:#0f3b69; }}
  .grid {{ display:grid; grid-template-columns: repeat(5, 1fr); gap:16px; }}
  .card {{ background:white; border-radius:16px; padding:18px; box-shadow:0 4px 14px rgba(0,0,0,.08); }}
  .card h2 {{ font-size:14px; color:#526170; }}
  .card p {{ font-size:28px; font-weight:bold; margin:4px 0; color:#0f766e; }}
  table {{ width:100%; border-collapse:collapse; margin-top:24px; background:white; }}
  th,td {{ padding:10px; border-bottom:1px solid #d8dee9; text-align:left; }}
  th {{ background:#0f3b69; color:white; }}
</style>
</head>
<body>
<h1>Dashboard de Compliance - api-pagamentos</h1>
<div class='grid'>{cards}</div>
<table>
  <thead><tr><th>Tag</th><th>Assinatura</th><th>Provenance</th><th>SBOM CycloneDX</th><th>SBOM SPDX</th></tr></thead>
  <tbody>{lines}</tbody>
</table>
</body>
</html>
"""

out = csv_path.parent / "dashboard.html"
out.write_text(html, encoding="utf-8")
print(out)
