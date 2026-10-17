# Age of Empires II via openage

**Portierbarkeit ★★☆☆☆ · XR-Potenzial ★★★★☆ · Reife der Basis ★☆☆☆☆**
Stand: Entwurf. Eine frühe Fassung (0.4) lief im Headset; 0.6.0-xr.0.12 (Spieloberfläche,
Speichern/Laden) ist installiert, aber nicht geprüft. App `xr.ages`.

**openage** ist eine freie Neuimplementierung der Engine hinter Age of Empires I/II, entwickelt vom
[SFTtech-Team](https://github.com/SFTtech/openage/graphs/contributors) unter GPL-3.0-or-later. Die
Dateiformate wurden durch Reverse Engineering dokumentiert, es gibt keinen dekompilierten
Originalcode. Ein Konverter macht aus der eigenen Kopie ein freies Modpack.

## Kurzfassung

**Port-Code: noch nicht veröffentlicht.** Dieses Rezept beschreibt Weg, Bausteine und Fallen.

**Wichtig vorab:** openage ist upstream noch kein spielbares Spiel. Der Port baut die fehlende
Spiellogik (Sammeln, Kampf, Bauen, Ausbilden, KI) in einem eigenen Fork nach.

Du brauchst **Age of Empires II** (am sinnvollsten HD oder Definitive Edition von Steam, sonst
The Conquerors 1.0c von CD).

1. Daten am PC mit dem openage-Konverter in ein Modpack umwandeln.
2. Entwicklermodus einschalten, Quest anstecken, APK installieren (`adb install -r`).
3. Modpack übertragen (tar-Weg wie `kitchen push`; nach einem Konverterwechsel vollständig ersetzen).
4. In der Brille `xr.ages` starten.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Modpack (PNG/Opus/nyan) | mit dem openage-Konverter aus der eigenen Kopie erzeugt | Datenordner der App |
| openage-Fork mit Spiellogik und GLES-Renderer | GPL-3.0-or-later | in der APK |
| OpenXR-Loader | Apache-2.0 | in der APK |

Die Konvertierung läuft am PC (Python, numpy, Pillow); aufs Gerät kommt nur das Ergebnis.
</details>

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Port-Code: **noch nicht veröffentlicht**. Der Weg:

1. **Desktop-Build** in WSL2 ohne `sudo` (Werkzeuge aus conda-forge), Konverter einmal mit der
   eigenen Kopie laufen lassen.
2. **C++-Einstieg ohne Python:** upstream startet über `python -m openage` und Cython; für Android
   ein eigener Einstieg mit festen Pfaden und ohne Konfig-Umweg.
3. **GLES 3.2 statt GL 3.3 Core:** Shader von `#version 330` nach `300 es`/`320 es`, die
   `#version 120`-Shader neu.
4. **Android/OpenXR:** EGL-Kontext statt Qt-Fenster, Final-Pass in die OpenXR-Swapchain, Controller
   als Maus über `xr-common`, Kamera auf dem Stick, VR-Menü nach Pflichtumfang.
5. **Spiellogik im Fork:** Ressourcen sammeln und abliefern, Kampf, Bauen, Ausbilden, einfache KI,
   Spieloberfläche (Befehle, Auswahl, Minimap), Speichern/Laden.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Machbarkeit und Rechtelage | GPL-3+, Clean-Room, Konvertierung am PC | ✅ 2026-10-03 |
| S1 C++-Einstieg, GLES 3.2 | läuft am PC mit GLES-Kontext | ✅ |
| S2 Android und OpenXR-Bild | Spielbild als VR-Fenster | ✅ im Headset gesehen (0.4) |
| S3 Spiellogik im Fork | Partie gegen KI | 🟨 am PC spielbar, Headset offen |
| S4 VR-Menü, Spieloberfläche | Pflichtumfang | 🟨 gebaut |
| L Ladebild L1–L8 | Startbild, Ladeanzeige ≤ 1 s danach, Restzeit ±30 % | 🟨 eigene Ladeanzeige; Startbild, Restzeit, Systemcheck offen |
| F Fenster F1–F10 | greifen, verschieben, skalieren | 🟨 Anfasser gebaut, Haltezeit noch 0,30 s statt 0,60 s |
| S5 Tischansicht | Karte als Tisch | ⬜ Forschung |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Nach einem Engine-Neustart zeigten wiederverwendete Bild-FBOs alte Inhalte → beim Neustart neu anlegen.
- Der Konverter kann hängen; nach einem Konverterwechsel das Modpack vollständig ersetzen (`--replace`).
- Das Qt-Makro `slots` kollidiert mit Bezeichnern anderer Bibliotheken → `#undef` in einer eigenen
  Übersetzungseinheit.
- Am PC unter WSLg nur Software-Rendering, solange `GALLIUM_DRIVER=d3d12` fehlt.
- Ein Hänger bei der Rahmenauswahl war eine Verklemmung zweier Threads – die letzte Logzeile führte
  in die Irre; Thread-Stacks unter Last ansehen.
- In WSL hängt CMake ewig, solange der Windows-PATH (`/mnt/c/…`) mit durchsucht wird.
</details>

<details>
<summary><b>Recht</b></summary>

- GPL-3.0-or-later – verträglich mit dem Apache-2.0-OpenXR-Loader. Bei Weitergabe einer APK müssen
  Fork und XR-Schicht als Quellcode verfügbar sein.
- Spieldaten bringt der Spieler mit (BYOA); nur das selbst konvertierte Modpack kommt aufs Gerät.
- „Age of Empires“ ist eine Marke von Microsoft – nur beschreibend, nie in App-ID oder Label (`xr.ages`).
- Abgrenzung: das mobile Online-Spiel gleichen Namens ist ein geschlossener Live-Service ohne offene
  Engine – dafür gibt es keinen Port.
</details>
