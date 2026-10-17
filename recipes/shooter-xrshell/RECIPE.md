# Doom, Wolfenstein 3D und Quake via XRShell (PrBoom, ECWolf, TyrQuake)

**Portierbarkeit ★★★★★ · XR-Potenzial ★★☆☆☆ · Reife der Basis ★★★★☆**
Stand: Entwurf. Doom II (0.3.0) und Quake (0.3.1) liefen im Headset, Doom zuletzt mit 0.3.5
(2026-10-09: 72 fps bei 72 Hz, Spielwechsel, Spielstand, Beenden). 0.3.6 mit Ladeanzeige ist
gebaut, aber nicht abgenommen. App `xr.shooter`.

Die Engines stammen aus der Open-Source-Gemeinde: **[PrBoom](https://github.com/libretro/libretro-prboom)**
(Doom), **[ECWolf](https://github.com/libretro/ecwolf)** (Wolfenstein 3D) und
**[TyrQuake](https://github.com/libretro/tyrquake)** (Quake), alle als libretro-Cores unter
GPL-2.0-oder-später. Sie bauen auf den Quellcode-Freigaben von id Software auf. XRShell liefert
nur Leinwand, Gamepad-Abbildung und VR-Menü.

Das Spiel bleibt ein **Original auf großer Leinwand** mit Gamepad. Wer echtes VR mit Kopf- und
Handbewegung will, findet fertige Quest-Ports anderer Projekte im [Katalog](../../catalog/README.md).

## Kurzfassung (wenn die App gebaut ist, 15–30 min je Spiel)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

1. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen.
2. `adb install -r XRShell-fps-debug.apk` (oder den Assistenten nehmen).
3. Spielordner bauen (im XRShell-Repo), aus der eigenen GOG-/Steam-Kopie:
   ```powershell
   powershell -File tools\prepare-shooter.ps1 -Source <Spielordner oder GOG-Installer>
   ```
   Ohne Kauf geht es mit **Freedoom** oder den **Shareware-Fassungen**.
4. Übertragen, je System ein Ordner:
   ```powershell
   .\kitchen.ps1 push shooter-xrshell "<Ausgabe>\doom"
   ```
5. In der Brille `xr.shooter` starten und das Spiel im VR-Menü (Reiter „Spiele“) wählen.

Bedienung: linker Stick laufen, rechter Stick drehen, rechter Trigger feuern, A benutzen,
B/X Waffe wechseln, linke Menütaste = VR-Menü (Spiel pausiert). Linker Griff = Fenster greifen.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Doom: `DOOM.WAD`, `DOOM2.WAD`, `TNT.WAD`, `PLUTONIA.WAD` | eigene Kopie (GOG/Steam); frei: `freedoom1.wad`, `freedoom2.wad`, Shareware `DOOM1.WAD` | `files/games/doom/<Ordner>/` |
| Wolfenstein 3D: `*.WL6`, Spear of Destiny: `*.SOD` | eigene Kopie; frei: Shareware `*.WL1` | `files/games/wolf3d/<Ordner>/` |
| Quake: `id1/PAK0.PAK`, `id1/PAK1.PAK` | eigene Kopie (Original-`Id1`, nicht die Neuauflage); frei: Shareware `id1/pak0.pak` | `files/games/quake/<Ordner>/id1/` |
| Quake-Musik | Soundtrack der Neuauflage (`rerelease/<dir>/music/trackNN.ogg`) | `<Ordner>/music/` |
| `xrshell.title`, `xrshell.start`, `xrshell.opt` | legt `prepare-shooter.ps1` an | im Spielordner |
| Spielstände | entstehen beim Spielen | `files/saves/` – der Spielordner wird nie beschrieben |

Alle Pfade unter `/sdcard/Android/data/xr.shooter/`. Nur Datendateien kopieren, keine Installer oder EXE.
</details>

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Quellcode (öffentlich): [xr.shell](https://github.com/friedensbringer-peacemaker/xr.shell), Flavor `fps`.
Geprüfter Stand: [`70241bd`](https://github.com/friedensbringer-peacemaker/xr.shell/commit/70241bdd067c0b9546ce6d45b35662e57a333f36).

```bash
git clone https://github.com/friedensbringer-peacemaker/xr.shell.git
cd xr.shell/android
./gradlew assembleFpsDebug
```

Küchengeräte wie bei [dos-xrshell](../dos-xrshell/RECIPE.md): JDK 17, Android Platform 34,
NDK 30.0, CMake 3.22.1, immer den Gradle-Wrapper. Die drei Cores lädt der Build vom
libretro-Buildbot (nightly, arm64-v8a) und packt sie als getrennte `.so` in die APK.
APK: `android/build/outputs/apk/fps/debug/`.

Ausführliche Doku im Port-Repo:
[`docs/SHOOTER.md`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/docs/SHOOTER.md)
(Ordnerlayout, Startdatei-Regel, Kern-Optionen, Belegung, Core-Smoke-Test ohne Brille).
</details>

<details>
<summary><b>Eingriffspunkte im Port-Code</b></summary>

| Was | Wo |
|---|---|
| Startdatei je Spielordner (IWAD-Priorität, `VSWAP.*`, `id1/pak0.pak`) | [`src/game_folders.cpp`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/game_folders.cpp) |
| Gamepad-Belegung je Core, Stick → Steuerkreuz ab 0,9 | [`src/pad_analog.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/pad_analog.h) |
| Kern-Optionen (Auflösung, 48 kHz, Totzone 0, Rumble) | [`src/core_defaults.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/core_defaults.h) |
| Core-Takt mit festen Fristen | [`src/frame_pacer.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/frame_pacer.h) |
| Quest-Bildrate passend zum Core | [`src/refresh_rate.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/refresh_rate.h) |
| Spielordner aus der eigenen Kopie bauen | [`tools/prepare-shooter.ps1`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/tools/prepare-shooter.ps1) |
| PrBoom-Grundeinstellung (72 fps, Ja-Taste) | [`profiles/doom.prboom.cfg`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/profiles/doom.prboom.cfg) |
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 APK bauen | APK am Ausgabepfad | ✅ |
| S2 Spielordner übertragen | Spiel im VR-Menü | ✅ 2026-10-03 (Steam-Kopien Doom, Quake) |
| S3 Erster Start | Titelbild mit Ton | ✅ 2026-10-04 (0.3.0 Doom II, 0.3.1 Quake) |
| S4 Gamepad | ohne Tastatur spielbar, Menüs und Ja/Nein | 🟨 Doom gespielt (0.3.5); Wolfenstein ungeprüft |
| S5 Bildrate | 72,0 fps bei 72 Hz | ✅ 2026-10-09 (0.3.5, Doom) |
| S6 Spielstände | nach Neustart ladbar | ✅ 2026-10-09 (Savestate) |
| L Ladebild L1–L8 | Startbild statt drei Punkten, Ladeanzeige ≤ 1 s danach, Restzeit ±30 % | 🟨 gebaut (0.3.6), Headset-Abnahme offen |
| F Fenster F1–F10 | greifen, verschieben, skalieren ohne Klick ins Spiel | 🟨 teilweise (F5/F6) |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- PrBoom liest **keine** Eingabe, solange das Frontend nach `retro_load_game` nicht
  `retro_set_controller_port_device` mit der Analog-Unterklasse 2 aufruft. TyrQuake ebenso;
  ECWolf kennt nur das RetroPad.
- PrBoom läuft standardmäßig mit 60 fps und ruckelt auf 72 Hz. Die Bildrate ist keine
  Core-Option, sondern `uncapped_framerate = 5` in einer `<IWAD>.prboom.cfg` neben der WAD.
- Die Quest stand auf 90 Hz, während der Core 72 fps lieferte (jedes vierte Bild doppelt).
  Die passende Rate per `XR_FB_display_refresh_rate` anfordern, auch nach Brille ab/auf.
- Ein Core-Takt mit Schlafen summiert die Aufwachverzögerung (71,6 statt 72 fps). Feste Fristen nehmen.
- Die Menüs aller drei Cores reagieren nur aufs Steuerkreuz. Den Stick erst ab 0,9 Ausschlag
  als Steuerkreuz melden, sonst springt in Quake und ECWolf das Lauftempo.
- Doom-Ja/Nein-Abfragen nehmen nur `y`/`n`; `key_menu_enter = y` macht „Bestätigen“ zu „Ja“.
- Breitbild in PrBoom bei 960×600 ist breiter als die 1024×768-Textur – das Bild bleibt stehen.
  Für Breitbild `prboom-resolution = 640x400`.
- Die Quake-Neuauflage (`rerelease/id1/`) wird nicht als Startdatei erkannt; das Original-`Id1` nehmen.
- Spielordner dürfen nicht `id1`, `hipnotic`, `rogue` oder `quoth` heißen (TyrQuake erkennt Pakete am Pfad).
- Quake II (vitaquake2) braucht `SET_HW_RENDER`, das XRShell nicht anbietet.
- DOS-Originale (`DOOM.EXE`, Duke 3D …) laufen alternativ in DOSBox Pure im Pad-Modus, siehe
  [dos-xrshell](../dos-xrshell/RECIPE.md); dort `xrshell.keys` im Pad-Modus nicht zusätzlich auswerten.
</details>

Port-Repo: [xr.shell](https://github.com/friedensbringer-peacemaker/xr.shell) · Skill: `xr-emulator-profiles`
