# Mit deinem KI-Agenten kochen

Du willst nicht selbst durch die Schritte klicken? Dann gib die Arbeit an einen KI-Agenten ab, der
auf deinem eigenen Rechner arbeiten darf – zum Beispiel **Claude Code**, **OpenAI Codex CLI**,
**Gemini CLI** oder einen Agenten in deinem Code-Editor. Er liest das Rezept, prüft die Werkzeuge,
baut die App und spielt sie per USB auf deine Quest. Du bestätigst nur die Schritte, die etwas
herunterladen, installieren oder auf der Brille starten.

Ein reiner Chat (ohne Zugriff auf deinen Rechner) kann dich ebenfalls Schritt für Schritt anleiten –
die Befehle führst du dann selbst aus.

## So geht's

1. **Vorbereiten:** Quest im Entwicklermodus, per USB-C angesteckt (siehe
   [README → Entwicklermodus](README.md#entwicklermodus)). Dein Originalspiel liegt entpackt auf dem
   Rechner (bei manchen Rezepten nicht nötig, siehe [Rezepte](README.md#rezepte)).
2. **Agenten starten** – am besten in einem leeren Ordner, in dem die Kitchen landen soll.
3. **Startprompt unten kopieren**, die drei Angaben in `<…>` ausfüllen und abschicken.
4. **Mitlesen und freigeben:** Der Agent fragt vor Downloads, Installationen und Starts auf der Brille.

## Startprompt (Deutsch)

```text
Du hilfst mir, ein klassisches Spiel mit der XR-Port-Kitchen auf meine Meta Quest zu bringen.

Meine Angaben:
- Spiel: <Name des Spiels, oder „zeig mir die Liste“>
- Ordner mit meinen eigenen Spieldaten: <Pfad, oder „keine“>
- Rechner: <Windows / macOS>

Vorgehen:
1. Hol dir die Kitchen: git clone https://github.com/friedensbringer-peacemaker/XR-Port-Kitchen.git
   (oder nutze den Ordner, falls er schon da ist) und lies README.md, AGENTS.md und
   docs/HAEUFIGE-FEHLER.md.
2. Such das passende Rezept (kitchen list bzw. kitchen catalog <Spiel>) und lies
   recipes/<rezept>/RECIPE.md und recipe.json, bei Bedarf PORTING.md.
3. Prüfe Werkzeuge, Spieldaten und Quest: Windows `.\kitchen.ps1 check <rezept> -Assets "<Pfad>"`,
   macOS `./kitchen.sh check <rezept> --assets "<Pfad>"`. Fehlendes erst nach meiner Zustimmung holen.
4. Bau die App mit `kitchen build <rezept>`, installiere sie nach Rückfrage und übertrage meine
   Spieldaten mit `kitchen push <rezept> "<Pfad>"`.
5. Sag mir am Ende, wo ich das Spiel in der Brille finde (Bibliothek → Unbekannte Quellen).

Regeln:
- Meine Spieldaten bleiben auf meinem Rechner und meiner Quest – nichts hochladen, nichts ins Repo.
- Keine Bezugsquellen für Spieldaten nennen und keinen Kopierschutz umgehen.
- Vor jedem Download, jeder Installation und jedem Start auf der Quest fragen. Apps nie
  deinstallieren (das löscht Spielstände), außer ich sage es ausdrücklich.
- Bei Fehlern zuerst in docs/HAEUFIGE-FEHLER.md nachsehen.
- Ehrlich berichten: „gebaut“ und „installiert“ ist nicht „funktioniert“ – ob es läuft, sehe ich in
  der Brille.
```

## Start prompt (English)

```text
Help me bring a classic game to my Meta Quest using the XR-Port-Kitchen.

My details:
- Game: <game name, or "show me the list">
- Folder with my own game data: <path, or "none">
- Computer: <Windows / macOS>

Steps:
1. Get the kitchen: git clone https://github.com/friedensbringer-peacemaker/XR-Port-Kitchen.git
   (or use the folder if it already exists) and read README.md, AGENTS.md and
   docs/HAEUFIGE-FEHLER.md (German; translate as needed).
2. Find the matching recipe (kitchen list or kitchen catalog <game>) and read
   recipes/<recipe>/RECIPE.md and recipe.json, plus PORTING.md if needed.
3. Check tools, game data and the Quest: Windows `.\kitchen.ps1 check <recipe> -Assets "<path>"`,
   macOS `./kitchen.sh check <recipe> --assets "<path>"`. Fetch missing tools only after I agree.
4. Build the app with `kitchen build <recipe>`, install it after asking me and copy my game data
   with `kitchen push <recipe> "<path>"`.
5. Tell me where to find the game in the headset (Library → Unknown Sources).

Rules:
- My game data stays on my computer and my Quest – never upload it or add it to a repository.
- Never name download sources for game data and never bypass copy protection.
- Ask before every download, installation and launch on the Quest. Never uninstall apps (that
  deletes saves) unless I explicitly say so.
- On errors, check docs/HAEUFIGE-FEHLER.md first.
- Report honestly: "built" or "installed" is not "works" – I will see in the headset whether it runs.
```

## Gut zu wissen

- **Erster Bau dauert:** oft 10–40 Minuten, weil die Projekte Werkzeuge nachladen.
- **Ein adb:** SideQuest während der Arbeit schließen (eigenes adb, siehe [README](README.md#brauche-ich-sidequest)).
- **Neues Spiel ohne Rezept?** Der [Katalog](catalog/README.md) zeigt, ob es eine Open-Source-Basis
  gibt, und die [PORTING-Vorlage](recipes/_template/PORTING.template.md) bzw. die Beispiele
  [OpenTTD](recipes/openttd/PORTING.md) und [DOS/XRShell](recipes/dos-xrshell/PORTING.md) zeigen,
  wie ein Port gebaut ist. Für ein neues Rezept gelten die Regeln in [AGENTS.md](AGENTS.md).
