# X-COM: Terror from the Deep via OpenXcom Extended

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★★★ · Reife der Basis ★★★★★**
Stand: im Headset gespielt (2026-09-30, 8.7.1-xr.3: Spielbild da und bedienbar; die
Einzelpunkte aus TEST.md sind noch nicht abgehakt). 8.7.1-xr.5 ist gebaut (64/64 Tests), aber
nicht installiert. App `xr.openxcom`.

**OpenXcom** reimplementiert UFO Defense und Terror from the Deep. **OpenXcom Extended (OXCE)**
von Meridian erweitert es, und die OXCE-Gemeinschaft pflegt einen Android-Port. Credits:
[OpenXcom](https://github.com/OpenXcom/OpenXcom),
[OXCE](https://github.com/MeridianOXC/OpenXcom),
[OXCE-Android](https://github.com/MeridianOXC/OpenXcom-Android),
[ursprünglicher Android-Port von sfalexrog](https://github.com/sfalexrog/OpenXcom-Android).

## Kurzfassung (wenn die App gebaut ist, 15–30 min)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

Du brauchst **X-COM: Terror from the Deep** (GOG, Steam oder CD).

1. GOG-Installer mit `innoextract` entpacken.
2. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen, APK installieren.
3. Spieldaten übertragen:
   ```powershell
   .\kitchen.ps1 push xcom-tftd-oxce "<…>\TFTD"
   ```
4. Beim ersten Start „Zugriff auf alle Dateien“ erlauben (oder
   `adb shell appops set --uid xr.openxcom MANAGE_EXTERNAL_STORAGE allow`).

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| `ANIMS`, `FLOP_INT`, `GEODATA`, `GEOGRAPH`, `MAPS`, `ROUTES`, `SOUND`, `TERRAIN`, `UFOGRAPH`, `UNITS` (zusammen ~62 MB, 1121 Dateien; Prüfung: `GEODATA/PALETTES.DAT`, `SOUND/GM.CAT`) | eigene TFTD-Kopie | `/sdcard/openxcom/TFTD` |
| optional UFO Defense (`UFO/…`) | eigene Kopie | `/sdcard/openxcom/UFO` (noch ohne Rezept-Eintrag) |
| `openxcom.log`, `options.cfg`, `xr.cfg` | entstehen beim Spielen | `/sdcard/openxcom/` |

Die GOG-Fassung ist die DOS-Version ohne MIDI-Dateien, die Musik kommt aus `GM.CAT`. Der
Quest-Speicher unterscheidet nicht zwischen Groß- und Kleinschreibung.
</details>

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Quellcode (öffentlich): [xr.openxcom](https://github.com/friedensbringer-peacemaker/xr.openxcom) (Fork von OpenXcom-Android) mit dem Spielcode als Submodul [xr.openxcom-engine](https://github.com/friedensbringer-peacemaker/xr.openxcom-engine) (Fork von OXCE), jeweils Zweig `xr-quest`

```bash
git clone --recurse-submodules -b xr-quest https://github.com/friedensbringer-peacemaker/xr.openxcom.git
```

Küchengeräte: JDK 17, Android Platform 35, NDK 30.0.16248370, CMake, Gradle-Wrapper 9.3.1
(AGP 9.1.1).

```bash
cd xr.openxcom
./gradlew assembleDebug          # in Git Bash OHNE MSYS_NO_PATHCONV
```

APK: `app/build/outputs/apk/debug/app-debug.apk`. Installieren und Spieldaten übertragen erledigt
die Küchenhilfe (`kitchen push xcom-tftd-oxce <TFTD-Ordner>`).
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 2D-Fan-Port | Intro als flaches Fenster | ✅ 2026-09-27 |
| S1 Immersiver Modus | Spielbild als VR-Leinwand, bedienbar | ✅ 2026-09-30 (xr.3) |
| S2 VR-Menü, Optionen, Tastatur, Upscaler | TEST-001, VR-MENU-001 | 🟨 gebaut |
| S3 Tisch-Ansicht, Passthrough | im Headset abgenommen | 🟨 gebaut |
| S4 Einrichtung ohne „Alle Dateien“ | keine Sonderberechtigung | ⬜ SETUP-001 |
| S5 Geoscape als 3D-Globus | Globus im Raum | ⬜ Recherche |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- SDL 2.0.9 fror den Spiel-Thread bei Fokusverlust ein (Horizon OS meldet ihn oft). Abhilfe:
  Fokusverlust ab Android 7 ignorieren.
- Der Preloader mit `noHistory` verschwand nach dem Berechtigungsdialog.
- GL-Zeilen zählen von unten, deshalb stand das Bild auf dem Kopf.
- Die Git-Revision als CMake-Argument löste bei jedem Commit einen Vollbuild von 18 Minuten aus.
- Der Preloader kannte nur UFO-Daten. Für TFTD war ein Patch nötig.
- Testen ohne Brille: `adb shell am broadcast -a com.oculus.vrpowermanager.prox_close`.
</details>

Port-Repo: [xr.openxcom](https://github.com/friedensbringer-peacemaker/xr.openxcom) · Spielcode: [xr.openxcom-engine](https://github.com/friedensbringer-peacemaker/xr.openxcom-engine) (jeweils Zweig `xr-quest`)
