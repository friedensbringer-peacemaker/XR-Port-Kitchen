# Command & Conquer: Alarmstufe Rot via OpenRA

**Portierbarkeit ★★★☆☆ · XR-Potenzial ★★★★★ · Reife der Basis ★★★★★**
Stand: läuft auf der Quest (Partie per Log bestätigt, 0.3.1 am 2026-09-28). App `xr.openra`.
Funktionen seit 0.3.0 sind größtenteils gebaut, aber nicht im Headset bestätigt.

**OpenRA** ist eine GPL-3.0-Reimplementierung der Westwood-RTS-Engine in C#. Hinter ihr steht eine
große Community. Die Kitchen ergänzt einen .NET-Android-Host, einen nativen OpenXR-Host und
VR-Bedienung. Credits: [OpenRA-Mitwirkende](https://github.com/OpenRA/OpenRA/graphs/contributors).

## Kurzfassung für Einsteiger

**Du brauchst kein Originalspiel.** EA hat die Daten von Alarmstufe Rot als Freeware freigegeben.
Das Build-Skript lädt das offizielle Quick-Install-Paket über OpenRAs Mirrorliste (13 MB,
SHA-1-geprüft). Die Musik ist nicht frei und kann optional aus einer eigenen Kopie kommen.

Es gibt noch **keine weitergebbare APK** (REL-001). Heute heißt der Weg deshalb: selbst bauen, aber
mit einem Doppelklick.

1. Git installieren (Windows: Git Bash wird gebraucht).
2. Port-Repo klonen und `Quest-Build.cmd` doppelklicken. Der erste Lauf dauert 15–40 Minuten und
   lädt ca. 6 GB Werkzeuge nach `.toolchains/` (ohne Admin-Rechte).
3. Mit angeschlossener Quest installiert das Skript die App und spielt die Daten ein. Einzeln
   geht das auch mit `.\kitchen.ps1 push openra-redalert Artifacts\content\ra-quickinstall.zip`
   (prüft die SHA-1 und entpackt per `run-as` in den App-Speicher).
4. In der Brille: Bibliothek → Unbekannte Quellen → `xr.openra`.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel |
|---|---|---|
| `ra-quickinstall.zip` | OpenRA-Mirrorliste, SHA-1 `44241f68…300b` (`quest/fetch-ra-content.sh`) | App-intern `files/Content/ra/v2/` per `run-as xr.openra` |
| `scores.mix` (Musik, optional) | eigene Kopie | `quest/import-music.sh <pfad>` |
| OpenRA `bleed` @ `f3ec7f8e15` | Fork `xr-openra` | in der APK |
| OpenAL Soft 1.24.3, Lua 5.1.5 | nativ gebaut (`quest/build-openal.sh`, `quest/build-lua.sh`) | `.so` in der APK |
| OpenXR-Loader 1.1.58 | Khronos | in der APK |

Dune 2000 und Tiberian Sun sind nur per YAML-Lint geprüft.
</details>

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Küchengeräte: JDK 17, .NET SDK 10 mit Android-Workload, Android Platform 36, Build-Tools 36,
NDK 27.0.12077973, CMake 3.22.1 + Ninja, adb. `quest/setup-toolchains.sh` holt alles selbst.

```bash
bash quest/all.sh            # setup-toolchains → fetch-ra-content → build → install
bash quest/all.sh --no-install
```

APK: `Artifacts/xr-openra-quest3.apk`. `build.sh` prüft Manifest, `.so`-Liste und Signatur.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 Android-Probe ohne XR | Spiel tickt auf der Quest | ✅ 2026-09-26 |
| S2 OpenXR-Quad | Fläche im Headset sichtbar | ✅ 2026-09-26 |
| S3 Ein-Befehl-Build | Doppelklick baut und installiert | ✅ 0.2.6 |
| S4 Stabilität | Brille ab/auf und Laden ohne ANR | ✅ 0.2.7 / 0.4.4 per Log |
| S5 VR-Menü, Kontrollgruppen, VR-Tastatur | im Headset bedienbar (TEST-001) | 🟨 gebaut |
| S6 ≥ 30 Bilder/s | Leistungszeile in einer Partie | 🟨 PERF-001 gebaut, nicht gemessen |
| S7 Passthrough, Tisch | im Headset abgenommen | 🟨 Passthrough gebaut, Tisch offen |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Synchroner GPU-Readback schafft nur 12–13 Bilder/s. Abhilfe: asynchrone PBOs und ein Upload
  nur dann, wenn ein neues Bild da ist.
- Laden auf dem GL-Thread über 5 s löst einen ANR aus. Abhilfe: in Etappen laden (Kartenliste: 10
  Karten pro Frame).
- Ohne `PreserveEGLContextOnPause` dauert der Neuaufbau nach Brille ab/auf 9 s und endet im ANR.
- Fehlt `liblua51.so`, hängt das Hauptmenü (`DllNotFoundException`).
- Horizon OS fängt den Start ab, wenn die Quest schläft oder die Controller ein Update brauchen.
- Doppelklick-Handler nicht in jedem Frame neu anlegen, sonst geht der Zustand verloren.
- Eine gebaute APK mit importierten Daten nicht weitergeben.
</details>

Port-Repo: `<XR-Ordner>/XR-OpenRA` (Branch `xr-openra`) · Build-Doku: `docs/xr/BUILD-QUEST.md`
