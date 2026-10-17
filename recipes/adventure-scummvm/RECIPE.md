# Point-&-Click-Adventures via XRShell + ScummVM

**Portierbarkeit ★★★★★ · XR-Potenzial ★★☆☆☆ · Reife der Basis ★★★★★**
Stand: Entwurf. Ein Adventure lief am 2026-10-10 im Headset (0.3.1, 60 fps); die Befunde daraus
(Speichern nicht gefunden, Fenster greifen) sind in 0.3.2–0.3.4 umgesetzt, aber noch nicht
abgenommen. App `xr.adventure`.

Die Engines stammen von **[ScummVM](https://www.scummvm.org/)** (GPL-3.0-oder-später), einem der
ältesten und reifsten Open-Source-Projekte für klassische Adventures. XRShell lädt den
libretro-Core von ScummVM und liefert Leinwand, Laser-Maus, Spielauswahl und VR-Menü.

Zum Ausprobieren ohne Kauf eignen sich Spiele, die ihre Rechteinhaber offiziell als Freeware
freigegeben haben, z. B. **Beneath a Steel Sky**, **Flight of the Amazon Queen** und **Lure of the
Temptress** (Download auf der ScummVM-Website). Alle anderen von ScummVM unterstützten Spiele
gehen mit der **eigenen Kopie** (CD, GOG, Steam).

## Kurzfassung (wenn die App gebaut ist, 10–20 min je Spiel)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

1. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen.
2. `adb install -r XRShell-adventure-debug.apk` (oder den Assistenten nehmen).
3. Spielordner vorbereiten: Spieldateien in einen Ordner, dazu eine Datei `<id>.scummvm` mit der
   ScummVM-Spiel-ID als Inhalt (`sky`, `queen`, `lure` …; Vorlagen unter `profiles/` im Port-Repo).
4. Übertragen:
   ```powershell
   .\kitchen.ps1 push adventure-scummvm "<Spielordner>"
   ```
5. In der Brille `xr.adventure` starten und das Spiel im VR-Menü wählen.

Bedienung: Laser = Zeiger, rechter Trigger = Linksklick, B = Rechtsklick, linker oder rechter
Griff = Fenster greifen, X = Bildzoom, Y = Bildschirmtastatur. Speichern und Laden über
VR-Menü → Reiter „Spiel“ → **„Spielmenü öffnen“**.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Spieldateien | eigene Kopie oder offizielle Freeware | `files/games/adventure/<Ordner>/` |
| `<id>.scummvm` | Textdatei mit der ScummVM-Spiel-ID | im Spielordner |
| `xrshell.title`, `xrshell.keys`, `xrshell.opt` | optional: Titel, Tastenprofil, Filter | im Spielordner |
| ScummVM-Systemdateien (`extra/`, `theme/`) | `ScummVM.zip` vom libretro-Buildbot, beim Build geladen | in der APK, beim Start nach `files/system/scummvm/` |
| `scummvm.ini` | legt die App beim ersten Start an (Gerätesprache, Untertitel an) | `files/system/` (app-intern) |
| Spielstände | im ScummVM-Menü gespeichert | `files/saves/` |

Alle Pfade unter `/sdcard/Android/data/xr.adventure/`, außer `files/system/` (app-intern).
</details>

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Quellcode (öffentlich): [xr.shell](https://github.com/friedensbringer-peacemaker/xr.shell), Flavor `adventure`.
Geprüfter Stand: [`70241bd`](https://github.com/friedensbringer-peacemaker/xr.shell/commit/70241bdd067c0b9546ce6d45b35662e57a333f36).

```bash
git clone https://github.com/friedensbringer-peacemaker/xr.shell.git
cd xr.shell/android
./gradlew assembleAdventureDebug
```

Küchengeräte wie bei [dos-xrshell](../dos-xrshell/RECIPE.md). Der Build lädt den ScummVM-Core
und `ScummVM.zip` vom libretro-Buildbot. APK: `android/build/outputs/apk/adventure/debug/`.

Ausführliche Doku im Port-Repo:
[`docs/ADVENTURE.md`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/docs/ADVENTURE.md)
(Sprache, Bildfilter, Maus-Analyse, Spielstände, Core-Test am PC).
</details>

<details>
<summary><b>Eingriffspunkte im Port-Code</b></summary>

| Was | Wo |
|---|---|
| Relative Maus mit Nachkomma-Rest, Fangen nach Größenwechsel | [`src/mouse_relative.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/mouse_relative.h), Host-Test [`tests/test_mouse_relative.cpp`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/tests/test_mouse_relative.cpp) |
| Sprache und `scummvm.ini` | [`src/scumm_setup.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/scumm_setup.h) |
| Vorlage Spiel-ID | [`profiles/beneath-a-steel-sky.scummvm`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/profiles/beneath-a-steel-sky.scummvm) |
| Spielordner aus Original-CDs prüfen und anlegen | [`tools/prepare-adventure.sh`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/tools/prepare-adventure.sh) |
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 APK bauen | APK am Ausgabepfad | ✅ |
| S2 Spielordner übertragen | Spiel in der Spielauswahl | ✅ |
| S3 Erster Start | Bild, Ton, Sprache nach Gerät | ✅ 2026-10-10 (0.3.1, 60 fps) |
| S4 Maus unter dem Laser | auch nach dem ScummVM-Menü | 🟨 Host-Test grün, Headset offen |
| S5 Speichern/Laden | nach Neustart ladbar | 🟨 Knopf „Spielmenü öffnen“ gebaut (0.3.2), Headset offen |
| L Ladebild L1–L8 | Startbild statt drei Punkten, Ladeanzeige ≤ 1 s danach, Restzeit ±30 % | 🟨 gebaut, Headset-Abnahme offen |
| F Fenster F1–F10 | greifen, verschieben, skalieren ohne Klick ins Spiel | 🟨 teilweise (F5/F6, rechter Griff ab 0.3.2) |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Der ScummVM-Core liest die Maus **relativ**. Beim Start setzt ScummVM seinen Zeiger irgendwohin;
  ohne einmaliges Fangen (Zeiger in die Ecke schieben, dann Laserposition als ein Schritt) bleibt
  ein fester Abstand zum Laser.
- Das ScummVM-Menü hat oft eine andere Bildgröße als das Spiel (320×200 → 640×480). Den letzten
  Laserpunkt auf die neue Größe umrechnen und neu fangen, sonst springt der Zeiger.
- Hat das Menü dieselbe Größe wie das Spiel (640×480-Spiele), ist ein Versatz von außen nicht
  erkennbar – im Headset beobachten.
- Am Bildrand nicht fangen: Das Fangen schiebt den Zeiger kurz in die linke obere Ecke, wo manche
  Spiele eine Leiste einblenden.
- Keine Schnellspeicherstände (`retro_serialize_size` = 0). Gespeichert wird im ScummVM-Menü
  (Strg+F5); deshalb der Knopf „Spielmenü öffnen“ im VR-Menü.
- Die Menüsprache braucht `gui_language` in `scummvm.ini`. `translations.dat` steckt schon in
  `ScummVM.zip` (`theme/`) und darf nicht doppelt geladen werden.
- ScummVM-Sprachcodes weichen von Android ab (ja → jp, ko → kr, sv → se, cs → cz, pt-BR → br).
- Baphomets Fluch 1/2 (mit eigener Kopie): nur die Originalfassungen von 1996/97 laufen;
  Director's Cut und Remastered sind andere Engines. CD-Images mit 2336 Byte je Sektor (Mode 2
  ohne Header) sind keine ISO – je Sektor Byte 8–2055 übernehmen, dann normal entpacken.
- Filter HD (xBR) passt zu 320×200-Spielen; 640×480-Spiele mit `xrshell_filter = scharf`.
- Der Core taktet sich selbst; am PC gemessene Bildraten sagen nichts über die Quest. Dort zählt
  die Leistungszeile im Sitzungslog.
</details>

Port-Repo: [xr.shell](https://github.com/friedensbringer-peacemaker/xr.shell) · Skills: `xr-emulator-profiles`, `xr-cursor-mapping`
