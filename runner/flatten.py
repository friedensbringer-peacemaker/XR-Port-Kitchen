"""JSON → flache Zeilen "pfad<TAB>wert" (Arrays zusätzlich "pfad.#<TAB>anzahl").
Gegenstück zu flatten.js für Linux/Git Bash (macOS nutzt osascript)."""
import json
import re
import sys


def walk(p, v, out):
    if isinstance(v, dict):
        for k, x in v.items():
            walk(f"{p}.{k}" if p else k, x, out)
    elif isinstance(v, list):
        out.append(f"{p}.#\t{len(v)}")
        for i, x in enumerate(v):
            walk(f"{p}.{i}" if p else str(i), x, out)
    else:
        if isinstance(v, bool):
            v = "true" if v else "false"
        s = re.sub(r"[\r\n\t]+", " ", str(v))
        out.append(f"{p}\t{s}")


with open(sys.argv[1], encoding="utf-8-sig") as f:   # -sig: BOM aus PowerShell-Dateien zulassen
    lines = []
    walk("", json.load(f), lines)
sys.stdout.buffer.write(("\n".join(lines) + "\n").encode("utf-8"))
