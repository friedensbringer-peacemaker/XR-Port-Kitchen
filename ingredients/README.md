# Zutaten (wiederverwendbare Bausteine)

Hier stehen Bausteine, die mehr als ein Rezept braucht. Rezepte verweisen darauf über
`ingredients.modules` in ihrer `recipe.json`.

Spielspezifische Zutaten wie Originaldaten, Upstream-Projekte und eigene Patches stehen im
Rezept selbst. Spieldaten liegen nie hier.

| ID | Was | Wo | Genutzt von |
|---|---|---|---|
| `quest-tools` | Dauer-Logger, Screenshots und Videos von der Quest holen, Log-Auszug je Aufnahme | `<XR-Ordner>/_tools/quest/` (README dort), Skill `quest-device-workflow` | alle |
| `xr-common` | Gemeinsame C++-Bibliothek (Namespace `xrc`, MIT): Panel-Geometrie, Strahltreffer, Eingabelogik, OpenXR-Bindings, Haptik, Passthrough | `<XR-Ordner>/_shared/xr-common/`, Skill `xr-common-lib` | noch keiner der vier Rezept-Ports (siehe CANDIDATES.md) |
| `xrshell-libretro` | OpenXR-Host für libretro-Cores (DOSBox Pure, snes9x, Mesen, SameBoy) mit Leinwand, Laser-Maus und VR-Menü. Ein neues Emulator-Spiel braucht keinen Code. | `<XR-Ordner>/XR-Ports-Platform/`, Skill `xr-emulator-profiles` | `dos-xrshell`, xr.island, xr.retro, xr.racer3k |
| `xrshell-profiles` | Tastenprofil `xrshell.keys`, Kernoptionen `xrshell.opt`, Menü-Skin `xrshell.theme` je Spiel | `<XR-Ordner>/XR-Ports-Platform/profiles/` | `dos-xrshell` |
| `openxr-videodriver-pattern` | Muster: Die Engine bekommt einen eigenen Videotreiber, der direkt in die OpenXR-Swapchain zeichnet (Quad- oder Zylinder-Layer) | `<XR-Ordner>/XR-Settlers2.5/…/videoDrivers/OpenXR/`, Skill `xr-openxr-integration` | `settlers2-rttr` |
| `readback-bridge-pattern` | Muster: Die Engine rendert offscreen (z. B. .NET), das Bild kommt per asynchronem PBO-Readback in einen nativen OpenXR-Host | `<XR-Ordner>/XR-OpenRA/OpenRA.Quest.XrProbe/`, Skill `xr-openxr-integration` | `openra-redalert` |
| `kitchen-push` | Spieldaten auf die Quest: eine tar-Datei, Entpacken auf dem Gerät, Rechte, Prüfdateien, `run-as` für App-Speicher, Schutz vor Überschreiben | `kitchen.ps1` / `kitchen.sh push`, Angaben in `ingredients.push` jedes Rezepts | alle vier Rezepte |
| `vr-menu-pflicht` | Pflichtumfang jedes VR-Menüs: Beenden mit Bestätigung, Strahl und Spielzeiger ausblendbar, Stick-Bedienung, Persistenz | Skill `xr-vr-menu` | alle |

`<XR-Ordner>` ist der gemeinsame Ordner, in dem alle Port-Projekte, `_tools/` und `_shared/`
nebeneinander liegen (siehe [README](../README.md#ordner)). Die Skills unter `~/.claude/skills/` sind das Kochwissen. Die Kitchen verweist
darauf und kopiert sie nicht. Einstieg ist der Skill `xr-port-playbook`.
