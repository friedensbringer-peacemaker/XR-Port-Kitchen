#!/usr/bin/env python3
"""Erzeugt die Katalog-Seiten (ENGINES.md, SOURCE-PORTS.md, VR-PORTS.md) aus catalog.tsv.

catalog.tsv ist die einzige Quelle: neue Einträge dort ergänzen, dann `python catalog/render.py`.
Renders the catalog pages from catalog.tsv (the single source of truth).
"""
import csv
import sys
import os
from collections import OrderedDict

HERE = os.path.dirname(os.path.abspath(__file__))
csv.field_size_limit(10_000_000)


def load():
    path = os.path.join(HERE, "catalog.tsv")
    # GitHub zeigt die TSV nur als durchsuchbare Tabelle, wenn kein Feld " oder \ enthält
    # (sonst „Illegal quoting“). Anführungszeichen im Text daher typografisch: „…“.
    with open(path, encoding="utf-8") as f:
        for no, line in enumerate(f, 1):
            if '"' in line or "\\" in line:
                sys.exit(f'catalog.tsv Zeile {no}: " oder \\ im Text – bitte „…“ verwenden')
    with open(path, encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f, delimiter="\t", quoting=csv.QUOTE_NONE))


def cell(s):
    return (s or "").replace("|", "/").strip() or "?"


def name(r):
    marks = []
    if r["kitchen"]:
        marks.append(f"📖 [{r['kitchen']}](../recipes/{r['kitchen']}/RECIPE.md)")
    if r["quest_vr"]:
        marks.append(f"🥽 {r['quest_vr']}")
    if "dead" in r["status"] or "eingestellt" in r["status"] or "archiv" in r["status"]:
        marks.append("💤")
    return cell(r["projekt"]) + ((" " + " ".join(marks)) if marks else "")


def link(u):
    u = (u or "").strip()
    first = u.split(" · ")[0].strip()
    return f"<{first}>" if first.startswith("http") else cell(u)


HEADER = """<!-- Erzeugt von catalog/render.py aus catalog.tsv – nicht von Hand bearbeiten. -->
# {title}

{intro}

Legende: 📖 = Rezept in der Kitchen · 🥽 = schon als Quest-VR-Port von anderen vorhanden · 💤 = seit 2022 ohne Commit / eingestellt.
„?“ = nicht bekannt (nicht: „nein“). Erklärung und Bewertung: [README.md](README.md).

"""


def write(fn, title, intro, rows, cols, fmt):
    groups = OrderedDict()
    for r in rows:
        groups.setdefault(r["gruppe"] or "–", []).append(r)
    out = [HEADER.format(title=title, intro=intro)]
    out.append("**Abschnitte:** " + " · ".join(f"{g} ({len(v)})" for g, v in groups.items()) + "\n")
    for g, v in groups.items():
        out.append(f"\n## {g} ({len(v)})\n\n| " + " | ".join(cols) + " |\n|" + "---|" * len(cols) + "\n")
        for r in sorted(v, key=lambda r: r["projekt"].lower()):
            out.append("| " + " | ".join(fmt(r)) + " |\n")
    with open(os.path.join(HERE, fn), "w", encoding="utf-8", newline="\n") as f:
        f.write("".join(out))
    return len(rows)


def main():
    rows = load()
    eng = [r for r in rows if r["bereich"] == "engine"]
    src = [r for r in rows if r["bereich"] in ("source-port", "decomp", "recomp")]
    vr = [r for r in rows if r["bereich"] == "vr-port"]
    n1 = write("ENGINES.md", "Engine-Nachbauten / Engine re-implementations",
               "Open-Source-Nachbauten von Spiel-Engines, die mit den Originaldaten des Spiels laufen. "
               "Open-source engine re-implementations that run with the original game data.",
               eng, ["Engine", "Originalspiel", "Originaldaten", "Sprache/Framework", "Lizenz", "Status", "Android", "Repo"],
               lambda r: [name(r), cell(r["original"]), cell(r["daten"]), cell(r["sprache"]), cell(r["lizenz"]),
                          cell(r["status"]), cell(r["android"]), link(r["url"])])
    n2 = write("SOURCE-PORTS.md", "Source-Ports, Dekompilierungen, Recompilierungen",
               "Ports auf Basis von offiziell freigegebenem Quellcode sowie rekonstruierter Code (Decomp/Recomp). "
               "Ports of officially released source code and reconstructed code (decompilation / static recompilation).",
               src, ["Projekt", "Originalspiel", "Plattform", "Art", "Sprache", "Lizenz/Rechtslage", "Status", "Android/ARM64", "URL"],
               lambda r: [name(r), cell(r["original"]), cell(r["plattform"]), r["bereich"], cell(r["sprache"]),
                          cell(r["lizenz"]), cell(r["status"]), cell(r["android"]), link(r["url"])])
    n3 = write("VR-PORTS.md", "Bestehende VR-Ports / Existing VR ports",
               "Was es für die Quest (und PC-VR) schon gibt – vor einem neuen Port hier nachsehen, um nichts doppelt zu bauen. "
               "What already exists – check here first to avoid duplicate work.",
               vr, ["Projekt", "Spiel", "Engine-Basis", "Art · Entwickler · Vertrieb", "Stand", "URL"],
               lambda r: [cell(r["projekt"]), cell(r["original"]), cell(r["sprache"]), cell(r["android"]),
                          cell(r["status"]), link(r["url"])])
    print(f"ENGINES.md {n1}, SOURCE-PORTS.md {n2}, VR-PORTS.md {n3}")


if __name__ == "__main__":
    main()
