# Dungeon Keeper via KeeperFX

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★★★ · Reife der Basis ★★★★★**
Stand: Entwurf. Im Headset gespielt (2026-10-03 0.2.0-preview.1 laut Nutzer „funktioniert“,
2026-10-04 0.3.2-preview.1: Level 2 gewonnen). 0.6.0-preview.1 mit Ladebild ist installiert,
ungeprüft. App `xr.dungeonfx`.

**KeeperFX** (Dungeon Keeper Fan eXpansion) vom [dkfans-Team](https://github.com/dkfans/keeperfx)
modernisiert Dungeon Keeper seit 2008: höhere Auflösungen, entkoppelte Bildrate, SDL3, 64 Bit.
Credits: [KeeperFX-Mitwirkende](https://github.com/dkfans/keeperfx/graphs/contributors).

> **Herkunft:** KeeperFX begann als Disassemblierung des Original-Programms. Laut Upstream ist der
> Code inzwischen vollständig neu geschrieben; eine Abmahnung durch den Rechteinhaber ist nicht
> bekannt. Wer das Rezept nutzt, sollte das wissen.

## Kurzfassung

**Port-Code: noch nicht veröffentlicht.** Dieses Rezept beschreibt Weg, Bausteine und Fallen.

Du brauchst **Dungeon Keeper** (GOG Gold, Steam oder CD).

1. GOG-Installer mit `innoextract` entpacken (oder vorhandene Installation verwenden).
2. Den KeeperFX-Datenordner aus der eigenen Kopie zusammenstellen (Originaldateien + Musik).
3. Entwicklermodus einschalten, Quest anstecken, APK installieren (`adb install -r`).
4. Daten in den App-Speicher übertragen (`run-as`, nur mit Debug-APK).
5. In der Brille `xr.dungeonfx` starten.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Originaldateien (`DATA`, `SOUND`, `LEVELS`) und Musik | eigene Kopie | App-intern `files/keeperfx` (per `run-as`) |
| KeeperFX 1.4.0 + XR-Schicht | GPL-2.0-or-later / eigener Code | in der APK |
| SDL3 | Zlib | in der APK |
| OpenXR-Loader | Apache-2.0 | in der APK |
</details>

<details>
<summary><b>Aus dem Quellcode bauen (2–4 h)</b></summary>

Port-Code: **noch nicht veröffentlicht**. Der Weg:

1. **Panel-App:** KeeperFX nativ für arm64 mit SDLActivity, deutsches Hauptmenü und Ton als flaches
   Fenster – zuerst ohne XR.
2. **Bild:** Ausgabe des SDL-Renderers abfangen und auf das OpenXR-Quad legen. Achtung: Linker-Wraps
   greifen nur zwischen Objektdateien, nicht innerhalb von `libSDL3.so`.
3. **Eingabe:** Spielzeiger absolut im Spielthread setzen (nie relativ einspeisen),
   Kanten-Scrollen aus, VR-Menü nach Pflichtumfang.
4. **Ton:** Musik und Sprecher mit absolutem Pfad laden.
5. **Ladebild:** früher XR-Start per Renderer-Wrap, damit das Startbild nicht schwarz endet.

Daneben gibt es eine zweite Variante ohne Engine-Port: die DOS-Fassung in XRShell (Rezept
[`dos-xrshell`](../dos-xrshell/RECIPE.md)).
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Machbarkeit und Herkunft | Lizenz und Herkunft benannt | ✅ |
| S1 Panel-App | Hauptmenü als flaches Fenster | ✅ |
| S2 OpenXR-Bild, Controller | Level im VR-Fenster spielbar | ✅ Headset 2026-10-03/04 (0.2.0, 0.3.2) |
| S3 VR-Menü, Landkarte, Ton | Kampagne von Level zu Level, Musik hörbar | 🟨 Fixes gebaut |
| L Ladebild L1–L8 | Startbild, Ladeanzeige ≤ 1 s danach, Restzeit ±30 % | 🟨 gebaut, Headset-Abnahme offen |
| F Fenster F1–F10 | greifen, verschieben, skalieren | 🟨 Griff am Rahmen (nur Position) |
| S4 Diorama, Besessenheit | Kerker als Tisch, Ich-Perspektive | ⬜ Forschung |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- `char` ist auf ARM vorzeichenlos, der Engine-Code rechnet mit Vorzeichen → `-fsigned-char`.
- Der Spielzeiger lag nicht unter dem Strahl, weil die Engine relative Mausbewegung skaliert →
  Position absolut setzen.
- Musik und Kampagnen-Sprecher stumm: Der Laufzeitordner ist auf Android „.“; ein Wrap auf
  `SDL_mixer` half erst, als auch diese Basis in einen absoluten Pfad (`getcwd`) umgewandelt wurde.
- Nach einem Sieg wurde die Landkarte übersprungen bzw. blieb stehen – die Folge der Menüzustände
  (Statistik → Bestenliste → Landkarte → nächstes Level) prüfen.
- Randscrollen der Landkarte per Strahl verschiebt die Ansicht von der Fahne des nächsten Levels weg.
- Zweiter Start verhält sich anders (viel globaler Zustand) → Prozess beim Spielende beenden.
- Meldungsfenster der Engine sind in der immersiven App unsichtbar → in die Ladeanzeige umleiten.
</details>

<details>
<summary><b>Recht</b></summary>

- GPL-2.0-or-later (alle Dateiköpfe; die LICENSE-Datei enthält den GPL-2.0-Text) – verträglich mit
  dem Apache-2.0-OpenXR-Loader.
- Herkunft aus einer Disassemblierung, laut Upstream vollständig neu geschrieben (siehe oben).
- Spieldaten bringt der Spieler mit (BYOA). Kein Markenname in App-ID oder Label (`xr.dungeonfx`).
</details>
