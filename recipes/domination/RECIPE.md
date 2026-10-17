# Domination (Gebietseroberung) als Spieltisch

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★☆☆ · Reife der Basis ★★★★☆**
Stand: Entwurf. 0.1.0 ist als 2D-Panel gebaut, aber noch nie auf der Quest gelaufen. App `xr.domination`.

**Domination** von [yura.net](https://sourceforge.net/projects/domination/) ist ein freies
Java-Strategiebrettspiel um Gebietseroberung – Würfelkämpfe, Karten tauschen, Missionen, KI-Gegner,
Karteneditor – mit eigenem Android-Client. Credits: Yura Mamyrin und die Autoren der Karten,
Grafiken und Töne (siehe Upstream).

## Kurzfassung

**Port-Code: noch nicht veröffentlicht.** Dieses Rezept beschreibt Weg, Bausteine und Fallen.

Du brauchst **kein Originalspiel** – Code, Karten, Grafik und Ton kommen aus dem freien Projekt.

1. App bauen (unten), Entwicklermodus einschalten, Quest anstecken.
2. APK installieren (`adb install -r`).
3. In der Bibliothek unter „Unbekannte Quellen“ `xr.domination` starten – Phase 1 läuft als
   2D-Fenster.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| Domination (Spiel, Mobil-UI, Android-Hülle) | GPL-3.0, SourceForge-SVN | in der APK |
| SwingME / AndroidME / UtilME | LGPL-2.1-or-later bzw. LGPL-3.0, AndroidME GPL-2.0-or-later | in der APK |
| Karten, Grafik, Ton | Upstream | in der APK (siehe Recht) |
</details>

<details>
<summary><b>Aus dem Quellcode bauen (1 h)</b></summary>

Port-Code: **noch nicht veröffentlicht**. Der Weg:

1. **Upstream holen:** SourceForge bietet nur SVN. Ein kleines Skript holt einen festen Stand per
   HTTP-Revision (ohne SVN-Client) und prüft ihn mit einem Baum-Hash; der Upstream bleibt
   unverändert und wird nicht eingecheckt.
2. **Eigener Gradle-Aufbau** (Wrapper 8.11, AGP 8.7, JDK 17) um die Upstream-Ordner, statt den
   veralteten Upstream-Build (Gradle 4, AGP 3, Geschwister-Checkouts) zu reparieren.
3. **Aufräumen:** Werbe-, Play-, Firebase- und Amazon-SDKs aus der APK entfernen, automatischen
   Fehlerversand an den Upstream-Server abschalten, die eine GPL-2.0-only-Hilfsdatei ausschließen.
4. **Phase 2 (Konzept):** eigene XR-Darstellung – die Karte als Spieltisch im Passthrough, KI und
   Regeln aus dem unveränderten Java-Kern.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Machbarkeit und Rechtelage | Lizenzen je Teil, Karten, Ton | ✅ 2026-10-03 |
| S1 Android-App als 2D-Panel | Partie gegen KI auf der Quest | 🟨 gebaut, nie auf der Quest |
| L Ladebild L1–L8 | Startbild, Ladeanzeige ≤ 1 s danach | 🟨 L1 gebaut; als 2D-Panel offen, ob es erscheint |
| F Fenster F1–F10 | greifen, verschieben, skalieren | ⬜ nur Fensterleiste von Horizon OS |
| S2 Mixed-Reality-Spieltisch | Partie am Tisch im Raum | ⬜ Konzept |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Der Upstream-Build ist veraltet → eigener Gradle-Aufbau, Upstream per Herkunftsdatei gepinnt.
- Eine Hilfsdatei im UI-Framework ist GPL-2.0-only (unverträglich mit GPL-3 und Apache-2.0), wird
  aber von nichts genutzt → im Build ausschließen.
- Upstream bündelt proprietäre Google-/Amazon-SDKs → entfernen; die Quest hat ohnehin keine Google-Dienste.
- In einer 2D-Panel-App meldet Horizon OS keine Controller-Tasten (A/B/X/Y) – Bedienung nur über
  den Strahl bzw. später die eigene XR-App.
</details>

<details>
<summary><b>Recht</b></summary>

- GPL-3.0 – verträglich mit dem Apache-2.0-OpenXR-Loader (der einzige GPL-2.0-only-Teil ist draußen).
- Der Name des bekannten Vorbild-Brettspiels erscheint nie in App, Paket oder Texten.
- Einzelne mitgelieferte Karten berühren fremde Rechte (eine Fantasy-Welt, ein U-Bahn-Plan,
  Fremdmarken in Kartennamen) – vor einer Veröffentlichung einer APK weglassen.
- Für Musik/Ton und Grafiken nennt der Upstream Urheber, aber keine Lizenz – vor einer
  Veröffentlichung einer APK beim Upstream klären. Community-Karten aus dem Netz nicht mitliefern.
</details>
