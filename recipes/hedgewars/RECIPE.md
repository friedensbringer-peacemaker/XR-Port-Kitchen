# Hedgewars (freies Artillerie-Spiel)

**Portierbarkeit ★★☆☆☆ · XR-Potenzial ★★★☆☆ · Reife der Basis ★★★★☆**
Stand: Entwurf. Ein eigener Build lief am 2026-10-17 immersiv im Headset (0.2.0-preview.4:
72 fps, Steuerung vom Nutzer als gut bewertet). Neuere Fassungen mit VR-Menü sind gebaut, aber nicht
abgenommen. App `xr.hedgehogs`. **Der Port-Code wird nicht veröffentlicht** (siehe Lizenz).

**[Hedgewars](https://www.hedgewars.org/)** ist ein freies rundenbasiertes Artillerie-Spiel mit
Igeln – Engine, Grafik, Ton und Karten sind frei. Das Hedgewars-Team entwickelt es seit 2007
([Quellcode-Spiegel](https://github.com/hedgewars/hw)).

## Warum es keine APK und keinen Port-Code gibt

Hedgewars steht unter **GPL-2.0-only** (ohne „oder später“). Der OpenXR-Loader, den jede Quest-App
mitbringt, steht unter **Apache-2.0**. Diese beiden Lizenzen lassen sich nicht in einem
weitergegebenen Programm verbinden. Wer Hedgewars auf der Quest spielen will, baut es deshalb
**selbst** und nutzt es privat. Dieses Rezept beschreibt den Weg und die Fallen, ohne eigenen Code.

## Weg (selbst bauen, 1–3 Tage beim ersten Mal)

1. **Toolchains:** Free Pascal 3.2.2 mit einem selbst gebauten Cross-Compiler `ppcrossa64` für
   `aarch64-android`, Rust mit `rustup target add aarch64-linux-android`, Android-NDK, CMake.
   Ein Linux (z. B. WSL) ist dafür am einfachsten.
2. **Desktop-Prüfstand zuerst:** `hwengine` unter Linux mit dem **GL2**-Renderweg bauen und ein Spiel
   ohne Qt-Frontend direkt aus einer Spieldatei starten. Die Upstream-Lua-Tests laufen ohne Fenster.
3. **Android-Build:** Engine als `libhwengine.so` (GL2, ohne Touch-Oberfläche), dazu die Rust-Bibliothek
   `hwengine_future`, SDL2 mit ttf/mixer/image/net, PhysFS 3.2 und Lua 5.1 für arm64 / API 29, in einem
   eigenen Gradle-Projekt. Daten aus `share/hedgewars/Data` (~215 MB) in die APK.
4. **OpenXR:** Present-Hook, OpenXR auf dem EGL-Kontext von SDL (GLES 3), Spielbild als Leinwand;
   Laser nur im Waffenmenü und beim Zielen. Skills `xr-openxr-integration`, `xr-quest-port`.
5. **Pflichtumfang:** VR-Menü (Skill `xr-vr-menu`), Ladebild L1–L8 (Skill `xr-loading-screen`),
   Fenster F1–F10.

<details>
<summary><b>Stufen und Belege</b></summary>

| Stufe | Erfolgskriterium | Stand |
|---|---|---|
| S0 Machbarkeit | Weg und Lizenz geklärt | ✅ 2026-10-10 (privat bauen, keine Verteilung) |
| S1 2D-Fenster | APK zeigt Spielbild | ✅ 2026-10-17 (0.1.2) |
| S2 OpenXR-Bild | Spielbild als VR-Leinwand | ✅ 2026-10-17 (0.2.0-preview.4) |
| S3 Controller | Partie ohne Tastatur | ✅ 2026-10-17 (Rückmeldung Nutzer) |
| S4 VR-Menü | Beenden mit Bestätigung, Zeiger ausblendbar | 🟨 gebaut (0.2.0-preview.5) |
| L Ladebild L1–L8 | Startbild statt drei Punkten, Ladeanzeige ≤ 1 s danach, Restzeit ±30 % | 🟨 gebaut; laut Log Ladeanzeige nach 1,5 s, Spiel nach 3,7 s |
| F Fenster F1–F10 | greifen, verschieben, skalieren ohne Klick ins Spiel | 🟨 teilweise (Griff verschiebt, Position gemerkt) |
</details>

<details>
<summary><b>Bekannte Fallen</b></summary>

- Der Android-Build im Upstream (Ant, armv7, alter NDK-gcc) ist als Vorlage unbrauchbar; nur die
  JNI-Ideen taugen. Eigenes Gradle-Projekt für arm64.
- Die Rust-Bibliothek `hwengine_future` (Landschaft, Kartengenerator, KI) ist Pflicht – ohne sie kein
  Spiel. Das heißt zwei Cross-Toolchains (Free Pascal und Rust).
- Der mobile Renderweg nutzt GLES 1.1 (Fixed Function) und passt nicht zur Quest. Den GL2-Weg mit
  ES-2/3-Kontext nehmen.
- Free Pascal braucht `PPC_CONFIG_PATH` und Suchpfade auf Sysroot und crt-Dateien. Das mitgelieferte
  PhysFS 2.1 ist zu alt (3.2 nehmen); CMake 4 braucht `-DCMAKE_POLICY_VERSION_MINIMUM=3.5`.
- `PHYSFS_init` auf Android ohne die Android-Initialisierung → Absturz gleich beim Start.
- Läuft die Engine als Bibliothek, liest sie die Argumente ab Index 0 – sonst „Error opening file
  hwengine“ und Ende.
- Hedgewars liest die Maus relativ und schiebt ohne sichtbaren Zeiger die Kamera. Der Laser setzt den
  Zeiger deshalb nur im Waffenmenü und beim Zielen absolut; sonst bewegt der Stick die Kamera.
- Der erste Start entpackt ~215 MB. Ohne Ladeanzeige wirkt das wie ein Hänger.
- Eine Neuinitialisierung nach dem Wiederherstellen des Fensters ohne GL-Kontext endet beim
  Schließen mit „Shader compilation failed“ – auf der Quest nicht neu initialisieren.
- Im 2D-Panel war die Bedienung mühsam (Bild nur in einer Ecke, Tastenleiste über der Anzeige); der
  direkte Weg zur OpenXR-Leinwand lohnt sich.
</details>

Upstream: [hedgewars.org](https://www.hedgewars.org/) · [github.com/hedgewars/hw](https://github.com/hedgewars/hw) · Skills: `xr-port-new-project`, `xr-openxr-integration`
