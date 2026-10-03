# Warcraft II via Wargus + Stratagus

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★★☆ · Reife der Basis ★★★★☆**
Stand: in Arbeit. Als flache Panel-App lief es am 2026-09-27 im Headset bis ins Hauptmenü
(0.1.0-s1). Die OpenXR-Versionen ab 0.2 sind gebaut: 0.2.0 bis 0.2.2 stürzten ab bzw. hingen,
die Fixes sind noch ungeprüft. App `xr.wargus2`; Warcraft I gibt es als zweite App `xr.wargus1` aus demselben Repo
(eigenes Rezept: [warcraft1-war1gus](../warcraft1-war1gus/RECIPE.md)).

**Stratagus** ist eine freie RTS-Engine, **Wargus** das Spielmodul für Warcraft II samt dem
Konverter **wartool**, der die eigene Kopie in ein freies Format umwandelt. Beide pflegt die
Wargus-Community seit vielen Jahren. Credits: [Stratagus](https://github.com/Wargus/stratagus),
[Wargus](https://github.com/Wargus/wargus).

## Kurzfassung (wenn die App gebaut ist, 30–60 min)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

Du brauchst die **Warcraft II Battle.net Edition** (GOG) oder die Original-CD.

1. Spiel installieren (bzw. den GOG-Installer mit `innoextract` entpacken).
2. Daten am PC umwandeln (im Port-Repo, Git Bash):
   ```bash
   bash scripts/prepare-data.sh "<Spielordner>"
   ```
   Das Skript baut `wartool`, wandelt Grafik, Töne, Musik und Videos um und legt den Ordner
   `wargus-quest/` an (~288 MB). Es braucht CMake und ffmpeg, unter Windows zusätzlich llvm-mingw.
3. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen, APK installieren.
4. Übertragen:
   ```powershell
   .\kitchen.ps1 push warcraft2-wargus "<…>\wargus-quest"
   ```
5. In der Brille `xr.wargus2` starten.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Spielordner mit `War2Dat.mpq`, `Install.mpq` (BNE) oder `DATA/REZDAT.WAR` (DOS-CD) | eigene Kopie | bleibt am PC |
| `wargus-quest/` (Ordner `graphics`, `sounds`, `music`, `videos`, `scripts`, `maps`, `campaigns`, `timidity`, Marker `extracted`) | Ergebnis von `prepare-data.sh` | `/sdcard/Android/data/xr.wargus2/files/data.Wargus/` |
| Spielstände, Einstellungen | entstehen beim Spielen | `files/user/` (bleibt bei `-Replace`) |
| TiMidity + Freepats | frei, von `prepare-data.sh` beigelegt | im Datenordner |

`push` überträgt keine `.mpq`/`.war`-Archive, Programme oder DLLs, sondern nur die umgewandelten
Daten.
</details>

<details>
<summary><b>Aus dem Quellcode bauen (2–4 h)</b></summary>

Quellcode (öffentlich): [xr.wargus](https://github.com/friedensbringer-peacemaker/xr.wargus) – baut beide Apps (`xr.wargus2`, `xr.wargus1`)

```bash
git clone --recurse-submodules https://github.com/friedensbringer-peacemaker/xr.wargus.git
```

Küchengeräte: JDK 17, Android Platform 34, NDK 30.0.16248370, CMake 3.31.6 (Stratagus verlangt
≥ 3.25), Gradle-Wrapper 8.11.1, ffmpeg, 7z. Windows zusätzlich llvm-mingw (ucrt-x86_64) für
tolua++ und wartool.

```bash
git submodule update --init --recursive
bash scripts/build-native.sh
cd android && ./gradlew assembleStratagusDebug     # oder assembleWar1gusDebug
bash scripts/apk-gate.sh …
```

APK: `android/build/outputs/apk/stratagus/debug/XR-Stratagus-debug.apk`.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Grundlage | Wargus läuft am PC | ✅ |
| S1 Flache Panel-App | Hauptmenü auf der Quest | ✅ headset-ok-2026-09-27 |
| S2 OpenXR-Quad, Controller | Partie im VR-Fenster (TEST-001) | 🟨 Absturz-Fix gebaut, ungeprüft |
| S3 VR-Menü, VR-Tastatur | Menü-Pflichtumfang im Headset | 🟨 gebaut |
| S4 Komfort, Paket | weitergebbare APK | ⬜ |
| S5 Tisch / Diorama | Karte als Tisch | ⬜ Recherche |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- **GL-Symbol-Absturz:** `shaders.cpp` definierte globale Funktionszeiger mit echten GL-Namen
  (`glUseProgram` …). Sie überdeckten libGLESv3, das ergab einen SIGSEGV im ersten Frame. Gelöst
  per Umbenennung im Präprozessor; der Build prüft jetzt auf solche Symbole. Host-Tests ohne
  gelinkte Engine finden so etwas nicht.
- Das mitgelieferte SDL 2.0.22 läuft nicht mit NDK ≥ 27, deshalb eigene SDL-Submodule.
- ExternalProjects brauchen den Toolchain-Wrapper (sonst armv7/API 21). In Ninja zuerst
  `stratagus_lib` bauen.
- wartool trägt bei der Battle.net Edition `.wav` statt `.mid` ein. `prepare-data.sh` korrigiert das.
- `stb_vorbis` spielt Theora-Videos ohne Ton, deshalb `vorbisfile`.
- Stratagus reagiert nur auf `SDL_QUIT`. Bei `SDL_APP_TERMINATING` deshalb sofort beenden.
- Fokus-Events und `PauseOnLeave` ließen das Spiel hängen. Der Fix in 0.2.3 ist ungeprüft.
- Der Log-Ordner verliert das Setgid-Bit, dann kann adb die Logs nicht lesen.
- Andere Ports berichten, dass adb nicht zuverlässig nach `Android/data` schreibt (siehe
  [CANDIDATES K8](../../ingredients/CANDIDATES.md)). Schlägt `push` dort fehl, ist `run-as` der Ausweg.
</details>

## Rechtliches

wartool wandelt nur die eigene Kopie um. Das Ergebnis bleibt privat und wird nie weitergegeben.
Keine Blizzard-Marken in App-Name oder Icon.

Port-Repo: [xr.wargus](https://github.com/friedensbringer-peacemaker/xr.wargus) · Build: `docs/BUILD.md` · Roadmap: `docs/ROADMAP.md`
