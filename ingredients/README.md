# Zutaten (wiederverwendbare Bausteine)

Hier stehen Bausteine, die mehr als ein Rezept braucht. Rezepte verweisen darauf über
`ingredients.modules` in ihrer `recipe.json`.

Spielspezifische Zutaten wie Originaldaten, Upstream-Projekte und eigene Patches stehen im
Rezept selbst. Spieldaten liegen nie hier.

| ID | Was | Wo | Genutzt von |
|---|---|---|---|
| `quest-tools` | Dauer-Logger, Screenshots und Videos von der Quest holen, Log-Auszug je Aufnahme | `<XR-Ordner>/_tools/quest/` (README dort), Skill `quest-device-workflow` | alle |
| `xr-common` | Gemeinsame C++-Bibliothek (Namespace `xrc`, MIT): Panel-Geometrie, Strahltreffer, Eingabelogik, OpenXR-Bindings, Haptik, Passthrough | `<XR-Ordner>/_shared/xr-common/`, Skill `xr-common-lib` | CorsixTH (Fenster, Ladebild) und die Ladebild-Welle; die übrigen Rezept-Ports noch mit eigenen Kopien (siehe CANDIDATES.md). Noch nicht öffentlich – erscheint mit dem ersten getaggten Stand |
| `xrshell-libretro` | OpenXR-Host für libretro-Cores (DOSBox Pure, ScummVM, PrBoom, ECWolf, TyrQuake) mit Leinwand, Laser-Maus und VR-Menü. Ein neues Emulator-Spiel braucht keinen Code. | `<XR-Ordner>/XR-Ports-Platform/`, Skill `xr-emulator-profiles` | `dos-xrshell`, xr.island, xr.dosgames, xr.adventure, xr.shooter |
| `xrshell-profiles` | Tastenprofil `xrshell.keys`, Kernoptionen `xrshell.opt`, Menü-Skin `xrshell.theme` je Spiel | `<XR-Ordner>/XR-Ports-Platform/profiles/` | `dos-xrshell` |
| `openxr-videodriver-pattern` | Muster: Die Engine bekommt einen eigenen Videotreiber, der direkt in die OpenXR-Swapchain zeichnet (Quad- oder Zylinder-Layer) | `<XR-Ordner>/XR-Settlers2.5/…/videoDrivers/OpenXR/`, Skill `xr-openxr-integration` | `settlers2-rttr` |
| `readback-bridge-pattern` | Muster: Die Engine rendert offscreen (z. B. .NET), das Bild kommt per asynchronem PBO-Readback in einen nativen OpenXR-Host | `<XR-Ordner>/XR-OpenRA/OpenRA.Quest.XrProbe/`, Skill `xr-openxr-integration` | `openra-redalert` |
| `kitchen-push` | Spieldaten auf die Quest: eine tar-Datei, Entpacken auf dem Gerät, Rechte, Prüfdateien, `run-as` für App-Speicher, Schutz vor Überschreiben | `kitchen.ps1` / `kitchen.sh push`, Angaben in `ingredients.push` jedes Rezepts | alle vier Rezepte |
| `vr-menu-pflicht` | Pflichtumfang jedes VR-Menüs: Beenden mit Bestätigung, Strahl und Spielzeiger ausblendbar, Stick-Bedienung, Persistenz | Skill `xr-vr-menu` | alle |
| `ladebild-standard` | Start ohne „drei Punkte“: L1 Quest-Startbild (`com.oculus.ossplash` + `assets/vr_splash.png`, App-Name und „dauert etwa N s“), L2 Ladeanzeige ab dem ersten XR-Frame an der Stelle des Spielfensters, L3 4–8 Schritte mit Fortschritt, L4 Restzeit aus gemessenen Starts, L5 Lebenszeichen + Hänger-Wächter 3/10/30 s, L6 Systemcheck ✓/⚠/✗ (OpenXR, Controller, Spieldaten, Speicher, Rechte, Akku, letzter Absturz), L7 Fehlerseite mit Abhilfe, Logpfad und „B = trotzdem weiter“, L8 Übergang ohne schwarzes Bild mit Kurzbedienung und Version | Skill `xr-loading-screen`; Logik in `xr-common` (`xrc/load_status.h`, `xrc/syscheck.h`, `xrc/json_file.h`), Startbild-Generator `<XR-Ordner>/_tools/studio/make-splash.py` | gebaut in Wargus (Referenz), CorsixTH, OpenTTD, OpenXcom und weiteren Ports; Headset-Abnahme offen |
| `fenster-standard` | Spielfenster überall gleich greifen: F1 Anfasser erscheinen nahe am Bild, F2 Leiste = verschieben, F3 Eckbogen = skalieren, F4 Griff am Rahmen, F5 linker Griff = Fenster folgt der Hand (nicht in Strategie-Ports mit Zoom auf links), F6 zwei Griffe = skalieren, F7 Stick vor = weiter weg, F8 Griff auf dem Bild greift erst nach 0,60 s oder 3° (kurz = Rechtsklick), F9 Breite/Abstand/Reset, F10 System-Recenter holt das Fenster vor den Kopf | `xr-common` (`xrc/window_handles.h`, `xrc/input/grab.h`, `xrc/window_grab.h` mit `WindowGrabController`), Skill `xr-quest-port` | gebaut in CorsixTH (Referenz); Headset-Abnahme offen |

`<XR-Ordner>` ist der gemeinsame Ordner, in dem alle Port-Projekte, `_tools/` und `_shared/`
nebeneinander liegen (siehe [README](../README.md#ordner)). Die Skills unter `~/.claude/skills/` sind das Kochwissen. Die Kitchen verweist
darauf und kopiert sie nicht. Einstieg ist der Skill `xr-port-playbook`.
