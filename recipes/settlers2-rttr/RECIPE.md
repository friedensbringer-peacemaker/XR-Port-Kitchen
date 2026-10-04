# Die Siedler II via Return to the Roots

**Portierbarkeit ★★★★★ · XR-Potenzial ★★★★☆ · Reife der Basis ★★★★★**
Stand: im Headset spielbar (2026-09-27, v2.1.0-preview.8). App `xr.settlers25`.

Die Engine stammt von **Return to the Roots** (s25client) und der Android-Port von
**s25rttr-android**. Beide sind GPL-Projekte von Fans, die seit vielen Jahren daran arbeiten. Die
Kitchen ergänzt nur einen OpenXR-Videotreiber und VR-Bedienung. Credits:
[RttR-Mitwirkende](https://github.com/Return-To-The-Roots/s25client/graphs/contributors),
[s25rttr-android](https://github.com/Farmer-Markus/s25rttr-android).

## Kurzfassung (wenn die App gebaut ist, 30–60 min)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

Du brauchst eine Meta Quest mit Entwicklermodus, einen PC oder Mac, ein USB-C-Kabel und
**Die Siedler II Gold Edition** (GOG oder Original-CD).

1. Entwicklermodus einmalig in der Meta-Horizon-App am Handy einschalten, Quest per USB anstecken
   und in der Brille „USB-Debugging zulassen“ bestätigen.
2. `Kitchen.cmd` (Windows) bzw. `Kitchen.command` (Mac) starten → „Die Siedler II“ → APK: ja →
   Ordner mit deinen Spieldaten angeben. Alles sollte grün sein.
3. Deine selbst gebaute APK installieren (macht auch der Assistent).
4. Spieldaten übertragen: `.\kitchen.ps1 push settlers2-rttr "<Gold-Ordner>"` (Mac:
   `./kitchen.sh push …`). Übertragen werden nur `DATA` und `GFX`; vorhandene Daten ersetzt der
   Befehl nur mit `-Replace`.
5. In der Brille: Bibliothek → Unbekannte Quellen → `xr.settlers25`. Beim ersten Start
   `/sdcard/RTTR/S2` wählen und „Zugriff auf alle Dateien“ erlauben.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| `DATA/`, `GFX/` | eigene Gold Edition; GOG-Installer mit `innoextract` entpacken, ohne ihn auszuführen | `/sdcard/RTTR/S2/` |
| Spielstände/Einstellungen | entstehen beim Spielen | `/sdcard/RTTR/.s25rttr` (bleibt bei Updates) |
| s25client @ `a0b85fbf`, s25rttr-android @ `35ef6302` | Snapshots im Port-Repo, 88 Submodule (SDL, Boost, Lua, gl4es …) | in der APK |
| OpenXR-Loader | Khronos, Submodule `third_party/openxr-sdk-source` | in der APK |

Andere Ausgaben (10th Anniversary, Remakes) gelten nicht automatisch als kompatibel (SETUP-002).
</details>

<details>
<summary><b>Aus dem Quellcode bauen (2–4 h beim ersten Mal)</b></summary>

Quellcode (öffentlich): [xr.settlers25](https://github.com/friedensbringer-peacemaker/xr.settlers25)

```bash
git clone --recurse-submodules https://github.com/friedensbringer-peacemaker/xr.settlers25.git
```

Küchengeräte: JDK 17, Android Platform 36, Build-Tools 35, NDK 27.0.12077973, CMake 3.22.1,
Python ≥ 3.9 (Tkinter für die GUI), Git. Windows zusätzlich: echtes `python` im PATH, gettext
(`winget install --id mlocati.GetText`), kurzer Checkout-Pfad.

```bash
python3 scripts/build-quest.py --check --sdk <SDK> --java <JDK17>
python3 scripts/build-quest.py --sdk <SDK> --java <JDK17>
python3 scripts/quest.py install
```

APK: `android/app/build/outputs/apk/debug/XR-Settlers-2.5-Quest.apk`. Alternativ mit GUI:
`Quest-Builder.cmd` / `.command`. Ein Folge-Build dauert etwa 9 Minuten.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 Android-Basis | APK startet als flaches Fenster | ✅ |
| S2 OpenXR-Videotreiber | Spielbild als VR-Fenster (Screenshot) | ✅ docs/VALIDATION.md |
| S3 Controller, VR-Tastatur, Schnellmenü | Partie spielbar | ✅ gespielt; Einzelabnahmen VR-001…024 offen |
| S4 Bildqualität | Text lesbar, kein Flimmern | 🟨 gebaut (VR-013) |
| S5 Zylinder, Passthrough, Tisch | im Headset abgenommen | 🟨 gebaut (VR-011, VR-021, VR-022) |
| S6 Diorama | Gelände mit Höhen | ⬜ geplant |
| S7 Ein-Klick-Build für Dritte | fremder Rechner baut ohne Hilfe | 🟨 Windows-CLI ok, GUI/Linux offen |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Start immer über `xr.settlers25/org.s25rttr.sdl.GameStartActivity`, nie die SDLActivity direkt.
- Vor jedem Test die installierte `versionName` prüfen. Ein versehentlich installierter
  main-Build zeigte riesige Menüs.
- Jeder Rechner hat einen anderen Debug-Schlüssel, dann scheitert `install -r`. Vor dem
  Deinstallieren die Spielstände sichern.
- Ein GitHub-ZIP ohne Submodule ist kein vollständiger Checkout.
- Windows: `sdkmanager.bat` zerlegt Paketnamen mit `;` falsch, `android.exe sdk install` verwenden.
  Außerdem `PYTHONIOENCODING=utf-8` setzen und auf Pfadlängen achten.
- Nach einem Auflösungswechsel Offscreen-FBO und Swapchain gemeinsam neu anlegen.
- Getrennte Menü-Ebenen und ein drehbarer Fenstergriff brachten Regressionen und sind zurückgestellt (VR-010).
- Doppelt vergebene Steuerelement-IDs in einem RTTR-Fenster beendeten das Spiel beim Öffnen (Tisch-Simulator) ◐.
</details>

Port-Repo: [xr.settlers25](https://github.com/friedensbringer-peacemaker/xr.settlers25) · Schritt-für-Schritt-Anleitung:
`docs/wiki/Ersteinrichtung-Schritt-fuer-Schritt.md`
