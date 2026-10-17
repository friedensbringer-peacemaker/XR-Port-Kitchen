# Half-Life via Lambda1VR (Team Beef, Xash3D-FWGS)

**Portierbarkeit ★★★★★ · XR-Potenzial ★★★★★ · Reife der Basis ★★★★☆**
Stand: Entwurf. Lambda1VR 1.7.4 ist installiert; der erste Start (2026-10-17) lief laut Log bis
in die OpenXR-Sitzung und rendert. Gespielt im Headset ist noch nichts. Kein eigener Port-Code.

Für Half-Life gibt es schon einen fertigen Quest-Port mit echter VR-Steuerung:
**[Lambda1VR](https://github.com/Team-Beef-Studios/Lambda1VR)** von Team Beef (GPL-3.0), aufgebaut auf
der Engine **[Xash3D-FWGS](https://github.com/FWGS/xash3d-fwgs)** und der Spiellogik
**[hlsdk-portable](https://github.com/FWGS/hlsdk-portable)**. Die Kitchen baut ihn nicht nach. Dieses
Rezept beschreibt nur, wie man ihn mit der **eigenen Steam-Kopie** einrichtet.

**Lizenzhinweis:** Die Spiellogik (hlsdk) steht unter der Half-Life-1-SDK-Lizenz von Valve und ist
**nur nicht-kommerziell** nutzbar. Die Engine ist GPL-3.0.

## Kurzfassung (20–40 min)

1. Entwicklermodus einschalten, Quest anstecken, USB-Debugging bestätigen.
2. Die Release-APK aus dem Lambda1VR-Repo laden (oder nach dessen Anleitung selbst bauen), die
   SHA-256 mit dem Wert auf GitHub vergleichen und installieren: `adb install -r <apk>`.
3. Lambda1VR **einmal starten**, „Zugriff auf alle Dateien“ erlauben, wieder beenden. Dabei
   entsteht `/sdcard/xash/`.
4. Den Ordner `valve` aus der eigenen Steam-Installation übertragen:
   ```powershell
   .\kitchen.ps1 push halflife-lambda1vr "<Half-Life-Ordner>\valve"
   ```
5. In der Brille Lambda1VR starten.

<details>
<summary><b>Zutaten im Detail</b></summary>

| Zutat | Herkunft | Ziel auf der Quest |
|---|---|---|
| `valve/` (u. a. `liblist.gam`, `halflife.wad`, `maps/`, `models/`) | eigene Steam-Kopie (Bibliothek → Half-Life → Verwalten → Lokale Dateien) | `/sdcard/xash/valve/` |
| `valve_hd/` (optional, HD-Modelle) | dieselbe Steam-Kopie | als Überlagerung über `valve/` entpacken |
| Sprachordner (optional, z. B. `valve_german/`) | dieselbe Steam-Kopie | als Überlagerung über `valve/` entpacken (eingerichtet, im Headset ungeprüft) |
| Spielstände | entstehen beim Spielen | `/sdcard/xash/valve/save/` (bleiben bei Deinstallation) |
| `commandline.txt` (optional) | `xash3d -game valve -log` | `/sdcard/xash/` – schreibt `engine.log` |
</details>

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Machbarkeit | fertiger Port statt Neubau | ✅ 2026-10-10 |
| S1 Lambda1VR installieren | App startet, `/sdcard/xash` existiert | ✅ 2026-10-17 (1.7.4) |
| S2 Spieldaten übertragen | `liblist.gam`, `halflife.wad` unter `/sdcard/xash/valve` | ✅ 2026-10-17 |
| S3 Erster Start | Menü und erstes Level im Headset | 🟨 laut Log Start und Rendern ok, im Headset noch nicht beobachtet |

Ladebild (L) und Fenster (F) sind Sache des Ports; Lambda1VR ist immersives VR ohne Spielfenster.
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Ohne „Zugriff auf alle Dateien“ findet Lambda1VR die Spieldaten nicht.
- `/sdcard/xash` entsteht erst beim ersten Start der App (so beschreibt es die Lambda1VR-Anleitung).
- Ordner einzeln per `adb push` brechen unter Windows ab. `kitchen push` packt deshalb ein tar und
  entpackt es auf dem Gerät.
- 1.7.4 stürzte beim Beenden **nach** dem OpenXR-Shutdown ab (Nullzeiger beim Protokollieren). Die
  Einstellungen waren zu dem Zeitpunkt schon gespeichert.
- `engine.log` entsteht nur mit `-log` in `/sdcard/xash/commandline.txt`.
- Die `config.cfg` aus der Steam-Kopie überschreibt eine vorhandene Konfiguration. Reste früherer
  Installationen unter `/sdcard/xash` vorher sichern.
- Die APK nur aus dem offiziellen Release (SHA-256 prüfen) oder selbst bauen, nie von Spiegelseiten.
</details>

Upstream: [Lambda1VR](https://github.com/Team-Beef-Studios/Lambda1VR) · [Xash3D-FWGS](https://github.com/FWGS/xash3d-fwgs) · Skill: `quest-device-workflow`
