# 0 A.D. via Pyrogenesis

**Portierbarkeit ★★☆☆☆ · XR-Potenzial ★★★★★ · Reife der Basis ★★★★★**
Stand: Entwurf. Hauptmenü im Headset gesehen (2026-10-01, 0.28.0-xr.0.1, ~60 fps Spiel bei 72 Hz);
0.28.0-xr.0.5.1 mit Ladebild ist gebaut, eine Partie im Headset ist noch nicht geprüft. App `xr.zeroad`.

**0 A.D.** ist ein eigenständiges, freies Echtzeit-Strategiespiel der Antike von
[Wildfire Games](https://play0ad.com) – kein Nachbau eines kommerziellen Spiels. Die Engine heißt
*Pyrogenesis* (C++, Spiellogik, GUI und KI in JavaScript über SpiderMonkey). Credits:
[Wildfire Games und Mitwirkende](https://gitea.wildfiregames.com/0ad/0ad). Die GLES- und
Touch-Patches des Sailfish-Fan-Ports von [smatkovi](https://github.com/smatkovi/0ad-sailfish) waren
die Vorlage für den Android-Build.

## Kurzfassung

**Port-Code: noch nicht veröffentlicht.** Dieses Rezept beschreibt den Weg, die Bausteine und die
Fallen; einen fertigen Bauweg gibt es erst, wenn der Port-Code öffentlich ist.

Du brauchst **kein Originalspiel**: Code und Daten von 0 A.D. sind frei. Die Daten sind aber
3,5 GB groß und kommen deshalb nicht in die APK, sondern werden getrennt übertragen.

1. App bauen (unten), Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen.
2. APK installieren (`adb install -r`, nie deinstallieren).
3. Freie Spieldaten 0.28.0 von Wildfire Games holen und übertragen (tar-Weg wie `kitchen push`).
4. In der Brille `xr.antiquity` starten (App-ID `xr.zeroad`; neutrales Label ohne Spielnamen).

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Spieldaten `mods/public` (0.28.0) | frei, Wildfire Games (CC BY-SA 3.0) | Datenordner der App |
| Pyrogenesis 0.28.0 + Sailfish-Patches + Android-Fixes | GPL-2.0-or-later | in der APK (`libmain.so`) |
| SpiderMonkey (mozjs 128) | MPL-2.0 | in der APK |
| SDL2, Boost, libxml2, ICU, OpenAL, Ogg/Vorbis, enet, fmt, libsodium, libpng | frei | in der APK |
| OpenXR-Loader | Apache-2.0 | in der APK |

Weggelassen: Lobby, Atlas-Editor, miniupnpc, nvtt.
</details>

<details>
<summary><b>Aus dem Quellcode bauen (1–2 Tage beim ersten Mal)</b></summary>

Port-Code: **noch nicht veröffentlicht**. Der Weg, wie er im Port gegangen wurde:

1. **Linux-Host:** SpiderMonkey braucht einen echten Rust-Cross-Build für `aarch64-linux-android`
   und baut nur unter Linux/macOS. Unter Windows: WSL2, Werkzeuge aus conda-forge (kein `sudo`
   nötig), Build-Baum im Linux-Dateisystem.
2. **SpiderMonkey 128** mit einem älteren NDK (r26c) quer bauen, der Rest mit NDK 30.
   `-lstdc++` vor `mozjs` linken. Allein mozjs belegt ~6 GB, der ganze Build ~10 GB.
3. **Abhängigkeiten** für android-arm64 bauen, dann premake mit `--gles --without-lobby
   --without-miniupnpc --without-atlas --without-nvtt`; die Sailfish-Patches 0001–0008 bringen das
   GLES-Backend und die Touch-Schicht zum Laufen.
4. **XR-Schicht:** Present per Wrap abfangen, Bild über ein Offscreen-FBO auf das OpenXR-Quad;
   Controller als Maus, Kamera auf den Sticks statt Kanten-Scrollen; VR-Menü nach Pflichtumfang.
5. **Prüfen vor jeder Quest-Version:** eigener Code mit `-Werror`, Host-Tests, Abgleich der
   GLES-Erweiterungen (jeder optionale Aufruf abgesichert), APK-Prüftor.

Lange WSL-Läufe mit `setsid nohup … &` starten, sonst sterben sie mit dem `wsl.exe`-Aufruf.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Machbarkeit und Rechtelage | Lizenzen geklärt, Namensfrage notiert | ✅ 2026-09-30 |
| S1 Android-Build unter WSL2 | `libmain.so` per Skript | ✅ 2026-10-01 |
| S2 OpenXR-Bild | Hauptmenü im VR-Fenster | ✅ Headset 2026-10-01 (0.1) |
| S3 Karte laden und Partie | Partie gegen KI im Headset | 🟨 Fixes gebaut, Headset offen |
| S4 VR-Menü | Pflichtumfang | 🟨 gebaut, Menü gesehen |
| S5 Leistung | ≥ 30 fps mit 4 KI-Gegnern | ⬜ |
| L Ladebild L1–L8 | Startbild, Ladeanzeige ≤ 1 s danach, Restzeit ±30 % | 🟨 gebaut, Headset-Abnahme offen |
| F Fenster F1–F10 | greifen, verschieben, skalieren | ⬜ heute nur Breite/Abstand |
| S6 Tisch-Diorama | Schlachtfeld als Tisch | ⬜ Forschung |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Absturz beim Kartenladen: `glMapBufferOES` ist im Quest-Treiber NULL (`GL_OES_mapbuffer` fehlt) →
  Ersatzweg über CPU-Puffer und `glBufferSubData`.
- Kamera in der Partie tot: Die Touch-Schicht ist unter Android fest eingeschaltet und blockiert
  die Kamerasteuerung → unter XR abschalten.
- GL-Debug-Ausgabe unter GLES 3.2 nur, wenn `GL_KHR_debug` gemeldet und alle Zeiger geladen sind.
- Eine libc-Schicht aus dem alten Android-Versuch (~2013) lieferte Nullzeiger bei
  `opendir`/`readdir` → entfernen.
- `gui.scale` über ~1,34 schiebt Dialoge aus dem Bild.
- Kein kontextabhängiger Mauszeiger (Angriff/Sammeln): 0.28 zeichnet den Cursor nicht selbst.
- Mehrspieler nur über direkte IP (keine Lobby), ungetestet.
</details>

<details>
<summary><b>Recht</b></summary>

- Code GPL-2.0-or-later (`source/`), MIT (`source/lib/`) – verträglich mit dem Apache-2.0-OpenXR-Loader.
- Daten CC BY-SA 3.0: Namensnennung Wildfire Games, Weitergabe unter gleichen Bedingungen.
- „0 A.D.“ ist der Name des Spiels von Wildfire Games. Die App-ID ist neutral (`xr.zeroad`);
  Label und eine Veröffentlichung vorher mit Wildfire Games abstimmen.
</details>
