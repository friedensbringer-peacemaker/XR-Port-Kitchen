# DOS-Spiele via XRShell + DOSBox Pure (Beispiel: Theme Park)

**Portierbarkeit ★★★★★ · XR-Potenzial ★★☆☆☆ · Reife der Basis ★★★★☆**
Stand: XRShell lief am 2026-09-27 im Headset (Bild, Ton, Menü v1, damals mit dem SNES-Core). Der
DOS-Pfad ist seit Menü v2 nicht erneut im Headset geprüft. App `xr.shell`.

Dieses Rezept ist der **Generalschlüssel** für DOS-Spiele ohne eigene Engine-Reimplementierung.
Jedes Spiel läuft ohne Code-Änderung. Pro Spiel braucht es nur einen Spielordner, ein Tastenprofil
und auf Wunsch einen Menü-Skin. Die Emulation stammt von
**[DOSBox Pure](https://github.com/schellingb/dosbox-pure)** (GPL-2.0) aus dem
libretro-Ökosystem. XRShell liefert Leinwand, Laser-Maus und VR-Menü.

Wenn es für ein Spiel eine native Engine gibt (z. B. CorsixTH, OpenTTD), ist das eigene Rezept
dafür meist besser: Es bringt mehr XR-Potenzial und schärfere Grafik.

## Kurzfassung (wenn die App gebaut ist, 15–30 min)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

1. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen.
2. `Kitchen.cmd` → „DOS-Spiele via XRShell“ → Ordner mit dem entpackten Spiel angeben.
3. `adb install -r XRShell-shell-debug.apk`
4. Spielordner vorbereiten und übertragen (im XRShell-Repo):
   ```powershell
   powershell -File tools\prepare-theme-park.ps1 -Source <entpackter-GOG-Ordner> -Language 1
   ```
   ```powershell
   .\kitchen.ps1 push dos-xrshell "<Zielordner>\1-ThemePark"
   ```
   Der Ordnername wird zum Namen unter `game/`. Für eine andere XRShell-App `-App xr.island`
   angeben; ein vorhandenes Spiel ersetzt `-Replace`.
5. In der Brille `xr.shell` starten. Der alphabetisch erste Ordner in `game/` wird Laufwerk C:.

Bedienung: Trigger = Linksklick, B/Griff = Rechtsklick, rechter Stick = Pfeiltasten,
Y = Bildschirmtastatur, X = Bildzoom.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Spielordner (= C:) | eigene Kopie; GOG-Installer mit `innoextract` entpacken | `/sdcard/Android/data/xr.shell/files/game/<Name>/` |
| `xrshell.keys` | Tastenprofil `eingabe = TASTE[+TASTE]`, Vorlagen in `profiles/` | im Spielordner |
| `xrshell.opt` | libretro-Kernoptionen (Standard `dosbox_pure_mouse_input = virtual`) | im Spielordner |
| `xrshell.theme` + BMPs | Menü in Spieloptik, aus den eigenen Spieldaten erzeugt | im Spielordner |
| Spielstände | entstehen beim Spielen | `files/saves/<Name>.pure.zip`, bleiben beim Neu-Pushen erhalten |
| DOSBox-Pure-Core | libretro-Buildbot, nightly arm64-v8a, beim Build geladen | in der APK, beim Start nach `filesDir/cores/` |

Theme-Park-Prüfung: `GAME/MAIN.EXE`, `GAME/DATA/MPALETTE.DAT`, `THEME.CD/`.
</details>

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Quellcode (öffentlich): [xr.shell](https://github.com/friedensbringer-peacemaker/xr.shell)

```bash
git clone https://github.com/friedensbringer-peacemaker/xr.shell.git
```

Küchengeräte: JDK 17, Android Platform 34, NDK 30.0.16248370, CMake 3.22.1, immer den
Gradle-Wrapper (8.11.1) verwenden, nie ein systemweites `gradle`.

```powershell
cd android
.\gradlew.bat assembleShellDebug
```

APK: `android/build/outputs/apk/shell/debug/XRShell-shell-debug.apk`. Weitere Flavors:
`island` (`xr.island`, nur DOSBox Pure), `retro` (`xr.retro`: snes9x, Mesen, SameBoy),
`racer3k` (`xr.racer3k`).
</details>

<details>
<summary><b>Windows-3.x-Spiele</b></summary>

Für Win-3.x-Spiele braucht es zusätzlich eine eigene Windows-3.1-Lizenz. Der Aufwand beträgt
mehrere Stunden: Windows 3.1 erst am PC in DOSBox-X einrichten, dann mit
`dosbox_pure_mouse_input = direct` und `vmwmouse.drv` packen, damit der Cursor genau unter dem
Laser liegt. Vorbild: `<XR-Ordner>/XR-HolidayIsland` (`xr.island`), Skill `xr-emulator-profiles` §5.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 APK bauen | APK am Ausgabepfad | ✅ |
| S2 Installieren | App unter „Unbekannte Quellen“ | ✅ 2026-09-27 (racer3k) |
| S3 Spielordner übertragen | `push-game.sh` listet den Ordner | ✅ |
| S4 Erster Start | DOSBox-Bild statt Schachbrett | 🟨 seit Menü v2 nicht erneut geprüft |
| S5 Tasten und Maus | ohne Tastatur bedienbar | ⬜ Profile ungeprüft |
| S6 Ton | Effekte und Musik | ⬜ im Headset nur mit snes9x geprüft |
| S7 Bildqualität | gestochen scharf | ✅ 2026-09-27 (snes9x) |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- `adb push` eines Ordners bricht unter Windows (adb 37) ab. `push-game.sh` packt deshalb ein tar
  und entpackt es auf dem Gerät.
- Git Bash: `MSYS_NO_PATHCONV=1` für Gerätepfade setzen, lokale Pfade mit `cygpath -m` übergeben.
- Von adb angelegte Ordner gehören dem Nutzer `shell`. `push-game.sh` setzt die Rechte deshalb selbst.
- Es startet nur der alphabetisch erste Ordner. Eine Datei direkt in `game/` hat Vorrang.
- CD-Images nur über das Startmenü oder `AUTOBOOT.DBP` einhängen. `DOSBOX.BAT` hängt keine CD ein.
- General MIDI braucht `C:\DOSBOX.SF2`. Ohne die Datei SB16-FM verwenden.
- Core-Wahl nach Lizenz: Cores mit reiner GPLv2-Lizenz passen nicht zum OpenXR-Loader (Apache-2.0).
</details>

Port-Repo: [xr.shell](https://github.com/friedensbringer-peacemaker/xr.shell) · Skill: `xr-emulator-profiles`
