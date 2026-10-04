# Katalog: Was gibt es, und lässt es sich auf die Quest bringen?

*English summary below.*

Dieser Katalog sammelt alles, worauf ein Quest-Port eines klassischen Spiels aufbauen kann:
Open-Source-Nachbauten von Spiel-Engines, Source-Ports von freigegebenem Quellcode, Dekompilierungen
und Recompilierungen – und, damit niemand doppelt baut, die VR-Ports, die es schon gibt.
Ziel: Menschen und Agenten sehen auf einen Blick, **was zur Verfügung steht**, und finden über die
Rezepte der Kitchen heraus, **ob und wie** ein Port geht.

Ein Hobbyprojekt: Es geht darum, alte Klassiker auf der Quest (und kommenden Headsets) spielbar zu
machen – nicht ums Geldverdienen.

## Dateien

| Datei | Inhalt |
|---|---|
| [catalog.tsv](catalog.tsv) | **die eine Quelle** – alle Einträge als Tabelle (Tab-getrennt), für Skripte und Agenten |
| [ENGINES.md](ENGINES.md) | Engine-Nachbauten, die mit den Originaldaten laufen (z. B. OpenRA, OpenTTD, VCMI, Julius), nach Genre |
| [SOURCE-PORTS.md](SOURCE-PORTS.md) | Source-Ports (Doom, Quake, Descent, FreeSpace 2 …), Dekompilierungen, Recompilierungen |
| [VR-PORTS.md](VR-PORTS.md) | was es für die Quest und PC-VR schon gibt (Team Beef, Port Royale, Community …) |
| [render.py](render.py) | erzeugt die drei .md-Seiten aus `catalog.tsv` |

Suchen in der Küchenhilfe:

```bash
sh kitchen.sh catalog heroes
```

```powershell
.\kitchen.ps1 catalog "might and magic"
```

**Markierungen:** 📖 = es gibt ein Rezept in der Kitchen · 🥽 = es gibt schon einen Quest-VR-Port von
anderen (erst dort mitmachen statt neu bauen) · 💤 = seit 2022 ohne Commit oder eingestellt.
„?“ heißt „nicht bekannt“, nicht „nein“ – gerade die Android-Spalte ist oft unvollständig.

## Was bewusst fehlt

- **Nintendo-Spiele** (inkl. aller Decomps/Recomps von Nintendo-Konsolen) – rechtlich besonders heikel,
  deshalb grundsätzlich nicht in der Kitchen.
- **Projekte auf Basis von geleaktem Code**, **DMCA-gesperrte** Projekte und **unveröffentlichte Prototypen** –
  dafür gibt es keine legal erworbene Kopie.
- Reine „inspiriert von“-Klone ohne Originaldaten sind nur vereinzelt drin.

## Ob ein Port geht – Schnellprüfung

1. **Gibt es ihn schon?** In [VR-PORTS.md](VR-PORTS.md) und bei 🥽 nachsehen. Wenn ja: lieber dort beitragen.
2. **Lebt die Basis?** Status `playable` und letzter Commit nach 2024 sind ein gutes Zeichen; 💤 heißt meist: Fork nötig.
3. **Lizenz verträglich?** GPL/MIT/BSD/zlib passen. Nicht-kommerzielle Lizenzen (FreeSpace 2, Descent, Build,
   JA2) sind für eine freie Weitergabe in Ordnung. Ohne Lizenz: Finger weg.
4. **Originaldaten legal erhältlich?** Nur GOG, Steam oder eigener Original-Datenträger. Spiele mit freien Daten
   (z. B. Warzone 2100, Seven Kingdoms, Ur-Quan Masters) lassen sich am einfachsten weitergeben.
5. **Technik** – daraus ergibt sich der Weg (nächster Abschnitt).

## Wie ein Port geht – Weg nach Technik

| Technik der Basis (Spalte „Sprache/Framework“) | Weg | Vorbild-Rezept |
|---|---|---|
| C/C++ mit SDL2/SDL3, Android-Build vorhanden | Android-Build übernehmen, OpenXR-Schicht und VR-Menü einziehen | [openttd](../recipes/openttd/RECIPE.md) (mit PORTING.md), [themehospital-corsixth](../recipes/themehospital-corsixth/RECIPE.md), [xcom-tftd-oxce](../recipes/xcom-tftd-oxce/RECIPE.md) |
| C/C++ mit SDL2, ohne Android-Build | erst Android/arm64 bauen (NDK, CMake), dann wie oben | [settlers2-rttr](../recipes/settlers2-rttr/RECIPE.md), [warcraft2-wargus](../recipes/warcraft2-wargus/RECIPE.md) |
| C#/.NET (MonoGame/FNA/OpenTK) | .NET für Android, Bild per GL an OpenXR übergeben | [openra-redalert](../recipes/openra-redalert/RECIPE.md) |
| Godot | Godot 4 mit OpenXR-Plugin, Renderer `gl_compatibility` | – (siehe „Suppe versalzen?“, Abschnitt Godot) |
| reines DOS-Spiel, keine Engine nötig | DOSBox Pure in XRShell, nur Profil anlegen | [dos-xrshell](../recipes/dos-xrshell/RECIPE.md) (mit PORTING.md) |
| Windows-only, kein Quellcode | Kompatibilitätsschicht (Winlator-Ansatz) – aufwendig, schwächer | – |
| Java, Unity, Rust, Lua/LÖVE | Einzelfall; meist deutlich mehr Aufwand | – |
| x86-only (AVX, D3D12, Xbox-360-Recomps) | auf der Quest (ARM64) derzeit nicht machbar | – |

Danach: neues Rezept aus `recipes/_template/` anlegen (Regeln in [AGENTS.md](../AGENTS.md), Abschnitt
„Ein neues Rezept anlegen“) und bei Fehlern zuerst in [docs/HAEUFIGE-FEHLER.md](../docs/HAEUFIGE-FEHLER.md) nachsehen.

## Katalog ergänzen

Neue Einträge als Zeile in `catalog.tsv` ergänzen (Spalten siehe Kopfzeile; `kitchen` = Rezept-ID,
`quest_vr` = Name des bestehenden Quest-Ports), dann `python catalog/render.py` ausführen und beides committen.
Die .md-Seiten nie von Hand ändern.

**Spalten:** `bereich` (engine, source-port, decomp, recomp, vr-port) · `gruppe` (Genre bzw. Abschnitt) ·
`projekt` · `original` · `plattform` · `sprache` · `lizenz` · `daten` (Originaldaten nötig: ja/teils/frei/?) ·
`status` · `android` · `url` · `kitchen` · `quest_vr`.

## Quellen (Stand 2026-10-04)

[osgameclones.com](https://osgameclones.com/) (Rohdaten [opengaming/osgameclones](https://github.com/opengaming/osgameclones), Typ „remake“) ·
[awesome-game-remakes](https://github.com/radek-sprta/awesome-game-remakes) ·
Wikipedia: [List of game engine recreations](https://en.wikipedia.org/wiki/List_of_game_engine_recreations),
[List of commercial video games with available source code](https://en.wikipedia.org/wiki/List_of_commercial_video_games_with_available_source_code) ·
[readonlymemo.com](https://readonlymemo.com/decompilation-projects-and-n64-recompiled-list/) ·
[heldgames.com](https://heldgames.com/guides/recompiled-games-list) ·
[awesome-game-decompilations](https://github.com/CharlotteCross1998/awesome-game-decompilations) ·
[Team Beef](https://www.teambeefvr.com/) · [Port Royale](https://portroyale.online) · [SideQuest](https://sidequestvr.com).
Der letzte Commit je GitHub-Projekt wurde am 2026-10-04 über die GitHub-API abgefragt; Android- und Statusangaben
stammen teils aus den Quellen und sind nicht einzeln geprüft.

---

## English summary

This catalog lists everything a Quest port of a classic game can build on: open-source engine
re-implementations, source ports of released code, decompilations/recompilations, and the VR ports that
already exist (so nobody builds the same thing twice). Search it with `kitchen catalog <keyword>`;
`catalog.tsv` is the single source of truth, `render.py` regenerates the pages. Nintendo titles, leaked-code
projects, DMCA-affected projects and unreleased prototypes are excluded on purpose. The quick check above
(exists already? alive? licence? legal data? technology) and the "route by technology" table point to the
recipe that serves as a model for a new port. A hobby project – about making old classics playable on the
Quest, not about money.
