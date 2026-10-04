# Warcraft: Orcs & Humans via War1gus + Stratagus

**Portierbarkeit ★★★★☆ · XR-Potenzial ★★★★☆ · Reife der Basis ★★★☆☆**
Stand: gebaut (0.3.0-xr), noch nicht installiert oder gestartet. App `xr.wargus1` – die zweite App
aus demselben Repo wie [Warcraft II](../warcraft2-wargus/RECIPE.md).

**War1gus** ist das Stratagus-Spielmodul für Warcraft I, mit dem Konverter **war1tool**, der die
eigene Kopie in ein freies Format umwandelt. Credits: [War1gus](https://github.com/Wargus/war1gus),
[Stratagus](https://github.com/Wargus/stratagus).

## Kurzfassung (wenn die App gebaut ist, 30–60 min)

**Zuerst die App selbst bauen** – wegen der Lizenzen gibt es sie nicht fertig zum Herunterladen.
Wie das geht, steht unten unter „Aus dem Quellcode bauen“. Danach geht es so weiter:

1. Daten am PC umwandeln (im Port-Repo, Git Bash):
   ```bash
   bash scripts/prepare-data-war1.sh "<Spielordner mit DATA/DATA.WAR>"
   ```
2. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen, APK installieren.
3. Übertragen:
   ```powershell
   .\kitchen.ps1 push warcraft1-war1gus "<…>\war1gus-quest"
   ```
4. In der Brille `xr.wargus1` starten.

<details>
<summary><b>Aus dem Quellcode bauen</b></summary>

Quellcode (öffentlich): [xr.wargus](https://github.com/friedensbringer-peacemaker/xr.wargus) – ein Build liefert beide Apps.

```bash
git clone --recurse-submodules https://github.com/friedensbringer-peacemaker/xr.wargus.git
```

Bauen wie im [Warcraft-II-Rezept](../warcraft2-wargus/RECIPE.md) beschrieben; die Warcraft-I-App
einzeln mit `cd android && ./gradlew assembleWar1gusDebug`. APK:
`android/build/outputs/apk/war1gus/debug/XR-War1gus-debug.apk`.
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S1 Zweite App aus demselben Build | APK gebaut | ✅ 0.3.0-xr |
| S2 Daten umwandeln | war1gus-quest mit Marker `extracted` | ✅ |
| S3 Erster Start auf der Quest | Hauptmenü im VR-Fenster | ⬜ |
| S4 Bedienung | Partie mit Controllern spielbar | ⬜ |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Bei War1gus ist Kanten-Scrollen fest an – das Datenskript schaltet es ab.
- Nur VR-taugliche Auflösungen anbieten (640×400, 800×500, 960×600).
- Alles Weitere wie bei Warcraft II (gleiche Engine und XR-Schicht).
- Gebäude außer dem Rathaus brauchen eine angrenzende Straße – das Spiel sagt nicht warum. Hinweis auf dem Ladebild.
</details>

## Rechtliches

war1tool wandelt nur die eigene Kopie um; das Ergebnis bleibt privat und wird nie weitergegeben.
Keine Blizzard-Marken in App-Name oder Icon.

Port-Repo: [xr.wargus](https://github.com/friedensbringer-peacemaker/xr.wargus)
