# AGENTS.md – Arbeitsregeln für Agenten in der XR-Port-Kitchen

Die Kitchen ist die Wissensbasis über alle XR-Ports. Der Code der Ports liegt in deren eigenen
Repos (Pfad steht in `recipe.json` → `port.local_path`). Hier steht, **was** zu tun ist und
**woran** man Erfolg erkennt. Das **Wie im Detail** steht in den Skills.

## Harter Rahmen

1. Keine Spieldateien, ROMs, Installer, Dumps oder daraus erzeugter Code in diesem Repo.
2. Keine Bezugsquellen für fremde Spieldaten nennen; nur legale Kaufwege (GOG, Steam, Original-Datenträger).
3. App-Namen immer `xr.<name>` in Kleinbuchstaben, ohne Marken.
4. Ein Status gilt nur mit Beleg. „Im Headset geprüft“ heißt: vom Nutzer im Headset beobachtet,
   mit Datum und Version. „Gebaut“ oder „installiert“ ist nicht „geprüft“.
5. Keine ungefragten Starts auf der Quest und keine Spielstarts am PC ohne Freigabe; der Nutzer trägt oft das Headset.
6. Agenten committen lokal; pushen darf nur der Parent-Agent nach Prüfung.

## Ein Rezept ausführen

Auftrag wie „Führe Rezept `settlers2-rttr` bis Stufe S4 aus“:

1. `recipe.json` und `RECIPE.md` lesen, dann das `AGENTS.md` im Port-Repo.
2. `kitchen.ps1 check <id>` (Windows) bzw. `kitchen.sh check <id>` ausführen. Fehlende
   Küchengeräte zuerst beheben oder melden.
3. Stufen in Reihenfolge abarbeiten. Jede Stufe endet erst, wenn `done_when` erfüllt und belegt ist.
   Bei `automatable: manual` die Stufe vorbereiten und an den Nutzer übergeben (Testanweisung).
4. Nach jeder Stufe zurückschreiben:
   - `recipe.json`: `status` der Stufe, `evidence`, ggf. `last_verified`, `app.version`
   - `RECIPE.md`: neue Fallen unter „Bekannte Fallen“
   - Wiederverwendbares → `ingredients/CANDIDATES.md` (neue Zeile oder neues Vorkommen)
   - Fehler, der mehr als einen Port trifft oder treffen kann → `docs/HAEUFIGE-FEHLER.md`
     (Zeile Symptom | Ursache | Lösung | Gesehen in, im passenden Abschnitt)
5. Bei einem Fehler zuerst in `docs/HAEUFIGE-FEHLER.md` nachsehen, bevor neu gesucht wird.

## Ein neues Rezept anlegen

0. Zuerst `kitchen catalog <Spiel>` bzw. `catalog/README.md`: Gibt es schon einen Quest-Port (🥽)?
   Welche Basis ist aktiv, welche Lizenz, welcher Weg passt zur Technik? Neue Funde als Zeile in
   `catalog/catalog.tsv` ergänzen und `python catalog/render.py` ausführen (die .md-Seiten nie von Hand ändern).
   Nintendo-Titel, Leak-Projekte und DMCA-gesperrte Projekte gehören nicht in Katalog oder Rezepte.
1. Ordner `recipes/<id>/` (Kleinbuchstaben, Bindestriche), Vorlage: `recipes/_template/`.
2. Machbarkeit zuerst (Skill `xr-port-new-project`): Rechtelage, Open-Source-Basis, Android-/ARM64-Nähe,
   Renderer (GLES/Vulkan/.NET), benötigte Originaldateien. Ergebnis als `status: draft`.
3. Bewertung ehrlich trennen: `portability`, `xr_potential` und `base_maturity` je 1–5,
   mit Begründung in `ratings.note`.
4. `kitchen.ps1 list` und `show <id>` müssen das Rezept fehlerfrei anzeigen.
5. Sobald der Port-Code öffentlich ist: `port.repo` setzen und `build` ergänzen (`repo`, `branch`,
   `submodules`, `steps` als Shell-Befehle im Repo-Ordner, `apk` als Muster relativ zum Repo,
   `note`/`note_en`). `kitchen build <id>` holt und baut damit; ungetestete Wege in `note` kennzeichnen.
6. Sobald der Port im Headset läuft: `PORTING.md` nach `recipes/_template/PORTING.template.md`
   (Eingriffspunkte mit Permalinks auf einen festen Commit, kurze Ausschnitte nur aus eigenem Port-Code,
   „Fertig, wenn“ je Schritt). Vorbild: `recipes/openttd/PORTING.md`.

## Zweisprachig (Deutsch/Englisch)

- Texte der Küchenhilfe nur über `i18n/strings.json` (Schlüssel mit `de` und `en`), nie fest im Skript.
  Beide Küchenhilfen lesen dieselbe Datei; neue Schlüssel immer in beiden Sprachen anlegen.
- Rezepte: `title_en` ist Pflicht (`lint` prüft das); Hinweise für den Assistenten zusätzlich als
  `game.name_en`, `effort.with_apk_en`, `original_assets.hint_en`, `push.note_en`, `push.prepare_en`,
  `build.note_en`.
- `kitchen.ps1` muss als UTF-8 **mit** BOM gespeichert bleiben (sonst zeigt PowerShell 5.1 Umlaute falsch).

## Port-Code veröffentlichen

Vor jeder Veröffentlichung eines Port-Repos `publish-check <repo>` ausführen; Fehler müssen weg,
Hinweise werden bewusst entschieden. Persönliche Muster nie in Regeln oder Skripte schreiben –
sie werden zur Laufzeit ermittelt bzw. stehen in `~/.xr-kitchen/personal-patterns.txt`.

## Ein Küchengerät anlegen

`tools/<id>.json` nach `schema/tool.schema.json`. Für jedes Betriebssystem Kandidaten in
Suchreihenfolge angeben: Umgebungsvariable, gemeinsamer Werkzeugordner (`%XR_TOOLS%` /
`$XR_TOOLS`), zuletzt der Befehlsname im PATH. Versionen bindet das Rezept über `version`
(Präfix) oder `min_version`, nicht das Gerät.

## Prüfen vor dem Commit

```powershell
.\kitchen.ps1 lint
.\kitchen.ps1 list
```

```bash
sh kitchen.sh lint
```

Pfade in Rezepten nur als `<XR-Ordner>/…` bzw. `~/.claude/skills/…`, nie als lokaler
Rechnerpfad (`lint` prüft das).

Beide Küchenhilfen müssen dieselben Rezepte zeigen. JSON-Dateien müssen gültig sein
(`Get-Content x.json -Raw | ConvertFrom-Json`).
