# Theme Hospital via CorsixTH

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★★☆ · Reife der Basis ★★★★★**
Stand: im Headset gespielt (2026-09-28, 0.4.0-xr: Hauptmenü, erstes Level, 72 Hz; die
VR-Tastatur in 0.5.0-xr gesehen). 0.8.0-xr ist gebaut (25.364 Prüfungen, 0 Fehler), im Headset
noch nicht geprüft. App `xr.corsixth`.

**CorsixTH** reimplementiert Theme Hospital als MIT-lizenzierte C++/Lua-Engine und wird seit
2009 aktiv gepflegt (v0.70.1 im September 2026). Credits:
[CorsixTH-Mitwirkende](https://github.com/CorsixTH/CorsixTH/graphs/contributors). Der
Android-Fanport von Alan Woolley diente als Referenz.

## Kurzfassung (wenn die App gebaut ist, 30–60 min)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

Du brauchst **Theme Hospital** (GOG oder Original-CD).

1. GOG-Installer mit `innoextract` entpacken (oder vorhandene Installation verwenden).
2. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen.
3. Debug-APK installieren: `adb install -r xr-corsixth-quest3.apk`
4. Spieldaten übertragen:
   ```powershell
   .\kitchen.ps1 push themehospital-corsixth "<Spielordner>"
   ```
5. In der Brille `xr.corsixth` starten.

**Wichtig:** Die App nie deinstallieren, das löscht die Spielstände. Updates immer mit `install -r`.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| `ANIMS`, `DATA`, `LEVELS`, `QDATA`, `SOUND` (Prüfung: `DATA/VBLK-0.TAB`, `LEVELS/EASY00.SAM`) | eigene Kopie | App-intern `/data/data/xr.corsixth/files/hospital` per `run-as` |
| Spielstände, `CorsixTH/config.txt` | entstehen beim Spielen | App-intern (bleiben bei `-Replace`) |
| SDL3 3.4.16, Lua 5.4.8, FluidSynth 2.6.1, FFmpeg n8.0.3 (nur Smacker) | frei | in der APK |

Warum App-intern? Horizon OS lässt adb nicht zuverlässig nach `Android/data` schreiben. Deshalb
geht der Weg über `run-as`, und das klappt nur mit einer Debug-APK.
</details>

<details>
<summary><b>Aus dem Quellcode bauen (2–4 h)</b></summary>

Quellcode (öffentlich, Fork von CorsixTH): [xr.corsixth](https://github.com/friedensbringer-peacemaker/xr.corsixth), Zweig `xr-quest`

```bash
git clone -b xr-quest https://github.com/friedensbringer-peacemaker/xr.corsixth.git
```

Küchengeräte: JDK 17, Android Platform 36, Build-Tools 35, NDK 27.0.12077973, CMake 3.22.1,
Gradle-Wrapper 8.13 (AGP 8.13.2), Git Bash. Alle Versionen stehen in `quest/lib.sh`.

```bash
bash quest/all.sh               # fetch-deps → build-ffmpeg → build (+ apk-gate) → install
```

Unter Windows geht auch ein Doppelklick auf `Quest-Build.cmd` (`--no-install` baut nur).
APK: `Artifacts/xr-corsixth-quest3.apk`. Der erste Windows-Build ist sehr langsam (CMake-Checks).
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 Panel-App | Hauptmenü als flaches Fenster | ✅ |
| S2 OpenXR-Quad, Controller | erstes Level im VR-Fenster | ✅ headset-ok-2026-09-28 |
| S3 VR-Menü, VR-Tastatur, Ladeanzeige | Menü-Pflichtumfang | 🟨 Tastatur gesehen, Menü 0.8.0 ungeprüft |
| S4 Tor G1: 10 Minuten stabil | kein Absturz | 🟨 BUG-006 offen |
| S5 Einrichtungsassistent, Spielstände | Einrichtung ohne adb | ⬜ |
| S6 Zylinder, Tisch, Diorama | – | ⬜ Forschung |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Die Engine hing beim Start, weil das Arbeitsverzeichnis `/` war (`lfs.dir("")`). Abhilfe:
  `chdir` in `xr_startup.cpp`.
- `App:fixConfig` stürzt ab, wenn die Umgebungsvariable `USER` fehlt.
- Das Menü in Spielgrafik erschien nie, weil `eventHandlers.frame` vor dem Laden von
  `xr_menu.lua` gecacht wurde (BUG-004).
- Ohne Intro blieb die Ladeanzeige 45 s stehen (BUG-005).
- Absturz in der Wegfindung nach 16 Minuten (BUG-006, `th_pathfind.cpp:567`, offen).
- Die Debug-Signatur unterscheidet sich je Rechner. Eine Mac-APK lässt sich nicht über eine
  Windows-APK installieren.
- Das Spiel rendert bis zu 108 fps bei 72 Hz (PERF-001).
</details>

Port-Repo: [xr.corsixth](https://github.com/friedensbringer-peacemaker/xr.corsixth) (Zweig `xr-quest`) · Build: `docs/xr/BUILD-QUEST.md`
