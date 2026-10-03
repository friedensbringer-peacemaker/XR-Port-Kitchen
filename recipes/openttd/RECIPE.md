# Transport Tycoon Deluxe via OpenTTD

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★★★ · Reife der Basis ★★★★★**
Stand: im Headset gespielt (2026-09-28, preview.3: Start, gewölbter Bildschirm, Strahl, Menüs,
neues Spiel). preview.10 mit VR-Schnellmenü ist gebaut und installiert, der Headset-Test steht aus.
App `xr.openttd`.

**OpenTTD** ist eine seit über 20 Jahren gepflegte GPL-Reimplementierung von Transport Tycoon
Deluxe. Die freien Pakete **OpenGFX, OpenSFX und OpenMSX** ersetzen Grafik, Töne und Musik.
Credits: [OpenTTD-Mitwirkende](https://github.com/OpenTTD/OpenTTD/graphs/contributors),
[OpenTTD-Downloads](https://www.openttd.org/downloads).

## Kurzfassung für Einsteiger (mit fertiger APK, ~5 min)

**Du brauchst kein Originalspiel.** Die freien Pakete stecken schon in der APK.

1. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen.
2. `adb install -r XR-OpenTTD-<version>-debug.apk`
3. In der Brille: Bibliothek → Unbekannte Quellen → `xr.openttd`.

Optional mit der Originalgrafik deiner eigenen Kopie:

```powershell
.\kitchen.ps1 push openttd "<Ordner mit TRG1R.GRF>"
```

Danach im Spiel unter Einstellungen das Basis-Set „Original“ wählen.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| OpenGFX 8.0, OpenSFX 1.0.3, OpenMSX 0.4.2 | frei, cdn.openttd.org; beim Build in die APK gepackt | beim ersten Start nach `files/baseset/` |
| GeneralUser GS 2.0.3 (SoundFont) | frei | in der APK |
| optional `TRG1R.GRF`, `TRGIR.GRF`, `TRGCR.GRF`, `TRGHR.GRF`, `TRGTR.GRF`, `SAMPLE.CAT` | eigene TTD-Kopie (GOG/CD) | `/sdcard/Android/data/xr.openttd/files/baseset/ttd-original/` |
| Spielstände, `openttd.cfg`, `xr.cfg` | entstehen beim Spielen | `files/openttd/save/` bzw. `files/` |

Die Originaldaten landen in einem eigenen Unterordner. So bleiben die freien Pakete erhalten,
und `-Replace` löscht nur die Originaldaten. OpenTTD durchsucht `baseset/` samt Unterordnern;
auf der Quest ist das noch nicht geprüft.
</details>

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Quellcode (öffentlich): [xr.openttd](https://github.com/friedensbringer-peacemaker/xr.openttd) mit der Engine als Submodul [xr.openttd-engine](https://github.com/friedensbringer-peacemaker/xr.openttd-engine) (Fork von OpenTTD, Zweig `xr-quest`)

```bash
git clone --recurse-submodules https://github.com/friedensbringer-peacemaker/xr.openttd.git
```

Küchengeräte: JDK 17, Android Platform 34, NDK 30.0.16248370, CMake 3.31.6 (aus dem SDK),
Gradle-Wrapper 8.11.1. Unter Windows zusätzlich llvm-mingw für die Host-Werkzeuge.

```bash
tools/build-host-tools.sh          # strgen/settingsgen nach .build/host-tools
cd android && ./gradlew assembleDebug
```

APK: `android/build/outputs/apk/debug/XR-OpenTTD-<versionName>-debug.apk`. Prüfungen:
`tools/apk-gate.sh` (Paket, keine Originaldaten), `tools/tests/run.sh`,
`tools/quest-smoke-test.sh --install <apk>`.

**Hinweis (offener Punkt):** Die OpenXR-Loader-`libopenxr_loader.so` liegt nicht im Repo, und
`third_party/openxr/README.md` nennt bisher nur den Weg über den (privaten) Siedler-Port. Für alle
zugänglich ist der offizielle Loader von Khronos (Apache-2.0): das Maven-Paket
`org.khronos.openxr:openxr_loader_for_android:1.1.58` – die `.so` für `arm64-v8a` aus dem AAR
nehmen und nach `third_party/openxr/lib/arm64-v8a/` legen. Ein Skript dafür fehlt noch.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 Android-Unterbau und Build | APK startet | ✅ |
| S2 OpenXR, gewölbter Bildschirm | Spielbild als VR-Leinwand | ✅ headset-ok-2026-09-28 |
| S3 Strahl, Menüs, neues Spiel | Spiel per Controller begonnen | ✅ headset-ok-2026-09-28 |
| S4 Schnellmenü, Passthrough, Bildschärfe | TEST.md 1–12 im Headset | 🟨 preview.10 gebaut |
| S5 Stabilität, Spielstände | Spielstand übersteht Beenden | 🟨 Fixes gebaut |
| S6 Tisch / Modellbahn-Diorama | Karte als Tisch im Raum | ⬜ UX-004 |
| S7 Quellcode veröffentlichen | Quellcode öffentlich, Selbstbau möglich | ✅ 2026-10-03 (die APK baut jeder selbst) |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Komprimierte APK-Assets wurden nur teilweise gelesen. Dadurch fehlten alle Daten, und die App
  beendete sich sofort (STAB-001).
- Beenden über das Quest-Menü verwarf den Spielstand (STAB-002).
- `MSYS_NO_PATHCONV` machte die Signaturprüfung des APK-Gates immer grün. Belege prüfen, nicht
  nur Exit-Codes.
- Der Selbsttest überschrieb die cfg dauerhaft. Testläufe brauchen eine eigene Konfiguration.
- Quellen nie während eines Builds ändern; preview.7 musste deshalb verworfen werden.
- Systemdialoge und Guardian blockieren Tests, wenn die Brille abgelegt ist.
- Die Jukebox zeigt „NoMusic“ (AUDIO-002, offen).
</details>

## Rechtliches

Die freien Pakete dürfen in die APK, Originaldaten nie (`apk-gate.sh` prüft das). Ob die GPL-2.0
der Engine zum Apache-2.0-Loader von OpenXR passt, muss vor einer Veröffentlichung geklärt werden
(REL-001).

Port-Repo: [xr.openttd](https://github.com/friedensbringer-peacemaker/xr.openttd) · Engine: [xr.openttd-engine](https://github.com/friedensbringer-peacemaker/xr.openttd-engine) (Zweig `xr-quest`) · Tests: `TEST.md`
