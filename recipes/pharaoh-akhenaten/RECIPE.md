# Pharao + Kleopatra via Akhenaten

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★★☆ · Reife der Basis ★★★☆☆**
Stand: Entwurf. 0.1.1 lief im Headset (2026-10-03, nur Logbefunde, keine Abnahme); 0.3.0 mit
Ladebild ist gebaut, ungeprüft. App `xr.nile`.

**Akhenaten** von [dalerank](https://github.com/dalerank/Akhenaten) ist ein Fork von
Julius/Augustus (Caesar III), der Pharao samt Kleopatra-Erweiterung nachbaut – C++, SDL2,
AGPL-3.0. Credits: [Akhenaten-Mitwirkende](https://github.com/dalerank/Akhenaten/graphs/contributors)
sowie die Julius- und Augustus-Teams.

## Kurzfassung

**Port-Code: noch nicht veröffentlicht.** Dieses Rezept beschreibt Weg, Bausteine und Fallen.

Du brauchst **Pharao mit der Kleopatra-Erweiterung** (Steam, GOG oder CD, beide Teile und gepatcht).
Spätere Neuauflagen sind ein anderes Produkt; deren Daten passen nicht.

1. Entwicklermodus einschalten, Quest anstecken, APK installieren (`adb install -r`).
2. Spielordner (`Data/`, `AUDIO/`, `BINKS/`) nach `Android/data/xr.nile/files/pharaoh` übertragen
   (tar-Weg wie `kitchen push`), Rechte setzen.
3. In der Brille `xr.nile` starten.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| `Data/` (Pharaoh_*-Pakete, `campaign.txt`), `AUDIO/`, `BINKS/` | eigene Kopie | `/sdcard/Android/data/xr.nile/files/pharaoh` |
| Spielstände | entstehen beim Spielen | im Datenordner (beschreibbar halten) |
| Akhenaten-Fork + XR-Schicht | AGPL-3.0 / eigener Code | in der APK |
| Engine-eigene Daten (Karten/Pakete der Engine) | Upstream | APK-Assets |
| SDL 2.32, SDL2_mixer, freetype, harfbuzz, libpng | frei | in der APK |
</details>

<details>
<summary><b>Aus dem Quellcode bauen (2–4 h)</b></summary>

Port-Code: **noch nicht veröffentlicht**. Der Weg:

1. **Stufe 0:** den Android-Build des Upstreams mit NDK 30 selbst bauen und als 2D-Panel auf der
   Quest testen – zeigt früh Daten-, Pfad- und Schriftprobleme.
2. **Bild:** Akhenaten rendert bereits in eine Ziel-Textur und präsentiert erst danach. Diese Textur
   statt `SDL_RenderPresent` auf das OpenXR-Quad legen.
3. **Eingabe:** Strahl als SDL-Maus, Trigger = links, Griff/B = rechts, Stick = Karte scrollen.
4. **Daten:** fester Datenordner ohne Ordnerwahl; die Engine-eigenen Daten als APK-Assets.
5. **Lebenszyklus:** Pause bei Fokusverlust, Beenden über das Quest-Menü an die Engine weitergeben,
   Einstellungen vor `_exit` sichern.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Upstream-APK als Panel | Hauptmenü als flaches Fenster | ✅ 2026-10-03 |
| S1 Immersive App, OpenXR-Quad | Stadt im VR-Fenster | ✅ im Headset gelaufen (0.1.1), keine Abnahme |
| S2 Controller, VR-Menü | Pflichtumfang | 🟨 gebaut |
| S3 Stabilität, Lebenszyklus | 10 Minuten ohne Einfrieren | 🟨 Fixes gebaut |
| L Ladebild L1–L8 | Startbild, Ladeanzeige ≤ 1 s danach, Restzeit ±30 % | 🟨 gebaut, Headset-Abnahme offen |
| F Fenster F1–F10 | greifen, verschieben, skalieren | 🟨 Griff am Rahmen (nur Position) |
| S4 Diorama | Stadt als Tisch | ⬜ Forschung |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Glyphensalat in Dialogen: SDL 2.32 (GLES2-Renderer) bindet bei `SDL_SetTextureScaleMode` sofort
  die Textur, gepufferte Zeichenbefehle lesen danach aus der falschen → vorher flushen.
- Ein ausführliches Start-Log auf dem UI-Thread löste ein ANR aus.
- Beenden über das Quest-Systemmenü erreichte die Engine nie → bei `EXITING` Engine-Quit auslösen.
- Einfrieren beim Drehen der Karte außerhalb der Stadt.
- Die Engine-Konfiguration wurde bei jedem Start nicht gefunden bzw. ging verloren (Ende per `_exit`).
- Von adb angelegte Datenordner gehören `shell` – Rechte setzen, sonst kann die App nicht speichern.
- Escape bzw. Abbrechen auf der VR-Tastatur kam als Rechtsklick an.
- Der Stick feuerte nach dem Loslassen des Griffs weiter → Sticks erst nach Rückkehr in die Totzone scharf.
</details>

<details>
<summary><b>Recht</b></summary>

- AGPL-3.0 – verträglich mit dem Apache-2.0-OpenXR-Loader. Bei **jeder** Weitergabe einer APK muss
  der vollständige Quellcode (Engine-Fork und XR-Schicht) öffentlich sein.
- Mitgelieferte Bibliotheken (u. a. LAME, OpenH264) vor einer Veröffentlichung einzeln prüfen.
- Spieldaten bringt der Spieler mit (BYOA). Kein Markenname in App-ID oder Label (`xr.nile`).
</details>
