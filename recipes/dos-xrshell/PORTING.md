# Selbst portieren: DOS-Spiele mit XRShell auf die Meta Quest

Diese Seite ist für alle, die **ein weiteres DOS-Spiel spielbar machen**, **XRShell verstehen**
oder **einen weiteren libretro-Core einbauen** wollen. Wer nur spielen will: [RECIPE.md](RECIPE.md).

> **Port-Stand:** [`xr.shell`](https://github.com/friedensbringer-peacemaker/xr.shell), Commit
> [`70241bd`](https://github.com/friedensbringer-peacemaker/xr.shell/commit/70241bdd067c0b9546ce6d45b35662e57a333f36).
> XRShell ist **eigener Code unter MIT**. Die Ausschnitte unten sind gekürzt; maßgeblich ist die
> verlinkte Datei. Die Cores (DOSBox Pure, ScummVM, PrBoom, ECWolf, TyrQuake) stehen unter ihren
> eigenen Lizenzen und liegen nie im Repo, sondern werden beim Build vom libretro-Buildbot geholt.

## Der Unterschied zu OpenTTD

Bei [OpenTTD](../openttd/PORTING.md) wird **in die Engine** eingehakt. Hier ist es umgekehrt:
XRShell ist ein kleiner **libretro-Frontend** (wie RetroArch, nur für VR) und lädt den Emulator
als fertige Bibliothek. **Am Spiel und am Emulator wird keine Zeile geändert.**

Darum gibt es zwei Wege:

| Du willst … | Aufwand | Weiter bei |
|---|---|---|
| **ein weiteres DOS-Spiel** spielbar machen | kein Code: Spielordner + zwei Textdateien | [Weg A](#weg-a-ein-neues-dos-spiel-ohne-code) |
| **XRShell verstehen** oder einen **anderen Core** (Shooter, Adventure) einbauen | C++ in XRShell | [Weg B](#weg-b-wie-xrshell-gebaut-ist) |

## Die Idee in einem Satz

XRShell lädt einen libretro-Core per `dlopen`, lässt ihn auf einem eigenen Thread im Takt des
Spiels laufen, übernimmt jedes fertige Bild als Textur auf einen Bildschirm im Raum und gibt den
Controller-Strahl als Maus, die Tasten als Tastatur bzw. Gamepad an den Core zurück.

```
 NativeActivity (kein Java)            XRShell (C++, libxrshell.so)                Core (.so, unverändert)
 ───────────────────────────            ───────────────────────────────            ──────────────────────
 android_main()  main.cpp ──► LibretroAdapter::start(Spiel)
                                 ├─ Core aus APK nach filesDir/cores/ entpacken
                                 ├─ dlopen + dlsym(retro_*)            ───────►  retro_init, retro_load_game
                                 └─ Core-Thread: retro_run im Spieltakt ───────►  retro_run
                                                                        ◄───────  video_refresh (Bild)
                                     Doppelpuffer (Mutex)                ◄───────  audio_batch  → AAudio
                                                                        ───────►  input_state (Maus/Tasten)
 Render-Thread (OpenXR):
   xrWaitFrame/BeginFrame ─► updateTexture() ─► glTexSubImage2D ─► Bildschirm-Quad ─► xrEndFrame
   Strahl ∩ Bildschirm ─► setPointerUV / setMouseButtons / setKey
```

## Weg A: Ein neues DOS-Spiel ohne Code

Ein Spiel besteht für XRShell aus **einem Ordner** = Laufwerk `C:`. Dazu kommen bis zu drei
Textdateien, die du selbst schreibst (Vorlagen in
[`profiles/`](https://github.com/friedensbringer-peacemaker/xr.shell/tree/70241bdd067c0b9546ce6d45b35662e57a333f36/profiles)):

| Datei im Spielordner | Wofür | Format |
|---|---|---|
| `xrshell.opt` | Emulator-Einstellungen (CPU-Takt, Soundkarte, Maus-Modus) und XRShell-Vorgaben (Filter, Griff) | `schlüssel = wert`, libretro-Kernoptionen von DOSBox Pure |
| `xrshell.keys` | freie Controller-Tasten → Spieltasten | `x = LSHIFT`, `right_stick_click = LALT+R` |
| `xrshell.theme` + BMPs | optional: VR-Menü in der Optik des Spiels | siehe Skill `xr-emulator-profiles` |

### Schritt für Schritt

1. **Spiel entpacken** – eigene Kopie, z. B. GOG-Installer mit `innoextract`. Nichts davon ins Repo.
2. **Startdatei prüfen:** DOSBox Pure startet `C:` und zeigt ein Startmenü; eine `AUTOBOOT.DBP`
   legt die Startdatei fest. CD-Spiele: Abbild im Ordner lassen und über das Startmenü einhängen.
3. **`xrshell.opt` anlegen.** Die drei Werte, die fast jedes Spiel braucht
   (Beispiel [`profiles/populous.opt`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/profiles/populous.opt)):

   ```ini
   dosbox_pure_cycles = 7800              # alte Spiele laufen sonst zu schnell
   dosbox_pure_sblaster_type = sb16
   dosbox_pure_mouse_input = direct       # Spielzeiger liegt genau unter dem Laser
   ```

   Ignoriert das Spiel die absolute Mausposition (Zeiger klebt oder springt):
   `dosbox_pure_mouse_input = virtual`.
4. **`xrshell.keys` anlegen**, wenn das Spiel Tasten braucht. Ohne Profil sind A, X, Y, linker
   Trigger und linker Stick wirkungslos (Trigger = Linksklick, B = Rechtsklick gelten immer).
   Format und alle Namen stehen oben in
   [`src/key_profile.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/key_profile.h).
5. **Auf die Quest bringen:**
   [`tools/push-game.sh`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/tools/push-game.sh)
   `<Ordner> <Name> [Tastenprofil]` – überträgt als tar und entpackt auf dem Gerät.
6. **Im Headset prüfen:** Bild, Ton, Maus unter dem Laser, alle nötigen Tasten erreichbar,
   Spielstand übersteht Beenden. Werte lassen sich auch im VR-Menü pro Spiel ändern.

**Fertig, wenn:** Das Spiel lässt sich ohne Tastatur vom Start bis zum Speichern bedienen.

Beispiele mit Begründung je Zeile: [`docs/DOS-SPIELE.md`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/docs/DOS-SPIELE.md)
(Populous, Pirates!, SimCity 2000, Syndicate Wars u. a.).

## Weg B: Wie XRShell gebaut ist

### Eingriffspunkte

Alle Links zeigen auf den festen Commit `70241bd`.

| # | Datei (Permalink) | Was dort passiert |
|---|---|---|
| 1 | [`android/src/main/AndroidManifest.xml` L49](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/android/src/main/AndroidManifest.xml#L49) | `NativeActivity` mit `lib_name = xrshell`, `vr_only`, `headtracking` required, `IMMERSIVE_HMD` – kein Java-Code |
| 2 | [`android/build.gradle` L155](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/android/build.gradle#L155) | Liste der Cores: beim Build vom libretro-Buildbot laden, je App-Variante (Flavor) als `assets/cores/*.so` packen |
| 3 | [`src/main.cpp` L1267 `android_main`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/main.cpp#L1267) | Event-Loop, OpenXR-Frame, Eingabe → Adapter |
| 4 | [`src/core_select.h` L51](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/core_select.h#L51) | Welche Dateiendung startet welchen Core, Maus- oder Pad-Modus, Bibliotheksordner |
| 5 | [`src/libretro_adapter.cpp` L1383 `start`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/libretro_adapter.cpp#L1383) | Core entpacken, `dlopen` (L1502), Callbacks setzen, Spiel laden |
| 6 | [`libretro_adapter.cpp` L191 `environmentCallback`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/libretro_adapter.cpp#L191) | Fragen des Cores beantworten: Pixelformat, System-/Save-Ordner, Kernoptionen aus `xrshell.opt` |
| 7 | [`libretro_adapter.cpp` L1639 Core-Thread](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/libretro_adapter.cpp#L1639) | `retro_run` im vom Core gemeldeten Takt, Pause beim VR-Menü, SRAM sichern |
| 8 | [`libretro_adapter.cpp` L353 `videoRefreshCallback`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/libretro_adapter.cpp#L353) | Bild des Cores in den Doppelpuffer, 16-Bit-Formate nach XRGB8888 |
| 9 | [`libretro_adapter.cpp` L1679 `updateTexture`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/libretro_adapter.cpp#L1679) | Render-Thread: neuestes Bild per `glTexSubImage2D` in die Bildschirm-Textur |
| 10 | [`libretro_adapter.cpp` L953 `queryInputState`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/libretro_adapter.cpp#L953) | Antwort auf `input_state`: Maus, Zeiger (absolut), Tastatur, RetroPad |
| 11 | [`src/quad_renderer.h` L69 `raycastToScreen`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/quad_renderer.h#L69) | Strahl ∩ Bildschirm → Trefferpunkt |
| 12 | [`src/main.cpp` L2137](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/main.cpp#L2137) | Trefferpunkt (mit Klick-Einfrieren und Bildzoom) → `setPointerUV`, Tasten → `setMouseButtons` |
| 13 | [`src/key_profile.h`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/key_profile.h), [`src/pad_mapping.cpp`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/pad_mapping.cpp) | `xrshell.keys` lesen; Controller → RetroPad im Pad-Modus |
| 14 | [`src/vr_menu.cpp`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/vr_menu.cpp) | VR-Menü (CPU-gerasterte Tafel): Ansicht, Zeiger, Bild, Spiel, Steuerung, Beenden |

### Die Kernstücke im Code

**Core laden** – ohne Link-Abhängigkeit, alle Einstiegspunkte per `dlsym`
([`start`](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/src/libretro_adapter.cpp#L1502)):

```cpp
// dlopen aus dem App-Privatverzeichnis: ab Android-31-Target nicht direkt aus dem APK (W^X)
mCoreHandle = dlopen(corePath.c_str(), RTLD_NOW);
auto* set_environment   = reinterpret_cast<set_environment_t>(dlsym(mCoreHandle, "retro_set_environment"));
auto* set_video_refresh = reinterpret_cast<set_video_refresh_t>(dlsym(mCoreHandle, "retro_set_video_refresh"));
auto* set_audio_batch   = reinterpret_cast<set_audio_sample_batch_t>(dlsym(mCoreHandle, "retro_set_audio_sample_batch"));
auto* set_input_state   = reinterpret_cast<set_input_state_t>(dlsym(mCoreHandle, "retro_set_input_state"));
// … retro_init, retro_load_game, retro_get_system_av_info
```

**Spieltakt auf eigenem Thread** – das Spiel läuft mit seinen 60/70 Hz, unabhängig von den
72/90 Hz des Headsets:

```cpp
mCoreThread = std::thread([this, retro_run_fn] {
	while (true) {
		{ // Pause (VR-Menü): schlafen, bis fortgesetzt oder beendet wird
			std::unique_lock<std::mutex> lock(mMutex);
			mCv.wait(lock, [this] { return mStopRequested || !mPaused; });
			if (mStopRequested) break;
		}
		const auto tick = clock::now();
		retro_run_fn();
		const auto frame = std::chrono::duration<double>(1.0 / mTimingFps.load());
		std::unique_lock<std::mutex> lock(mMutex);
		if (mCv.wait_until(lock, tick + frame, [this] { return mStopRequested; })) break;
	}
});
```

**Bild übergeben** – der Core-Thread schreibt nur in den Hintergrundpuffer, der Render-Thread
lädt hoch. GLES-Aufrufe **nur** auf dem Render-Thread:

```cpp
// Core-Thread (videoRefreshCallback): in den hinteren Puffer kopieren, dann umschalten
std::lock_guard<std::mutex> lock(gAdapter->mMutex);
const uint32_t back = 1 - gAdapter->mFront;
std::memcpy(gAdapter->mPixels[back].data(), src, height * pitch);   // bzw. 565 → XRGB8888
gAdapter->mFront = back;
gAdapter->mFrameCounter.fetch_add(1);

// Render-Thread (updateTexture): nur wenn ein neues Bild da ist
if (count == mLastUploaded) return false;
glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, mPixels[front].data());
```

**Strahl als Maus** – `main.cpp` übergibt die Position als Bildschirm-UV (0..1), der Core fragt
sie im eigenen Takt ab:

```cpp
// main.cpp: Trefferpunkt, beim Klicken kurz eingefroren, Bildzoom herausgerechnet
state.adapter.setPointerUV(frameUvFromScreen(screenU, zoomU0, zoomSpan),
                           frameUvFromScreen(screenV, zoomV0, zoomSpan), state.pointerFiltered);
state.adapter.setMouseButtons(left, right);

// libretro_adapter.cpp: Antwort an den Core
case RETRO_DEVICE_MOUSE:   // relativ (Maus-Modus „virtual“)
	case RETRO_DEVICE_ID_MOUSE_X: return mMouseDeltaX;
case RETRO_DEVICE_POINTER: // absolut (Maus-Modus „direct“)
	case RETRO_DEVICE_ID_POINTER_X: return mPointerAbsX;
```

### Einen weiteren Core einbauen

So kamen ScummVM, PrBoom, ECWolf und TyrQuake dazu – jeweils ohne Änderung am Core:

1. **Lizenz prüfen.** Der OpenXR-Loader ist Apache-2.0. Cores unter **reiner GPL-2.0** passen nicht
   dazu; GPL-2.0-oder-später, GPL-3.0, MIT passen. Cores unter nicht-kommerziellen Lizenzen
   gehören nicht in öffentliche Builds.
2. **`android/build.gradle`:** Eintrag in `libretroCores` mit Name, `.so` und den Flavors, in die er
   gepackt wird.
3. **`src/core_select.h`:** `CoreSpec` anlegen – Dateiendungen, `padMode` (Gamepad statt Maus),
   `provideDirs` (System-/Save-Ordner), Bibliotheksordner – und in die Liste `kCores`
   aufnehmen (daraus suchen `coreForFile`/`coreForPath`).
4. **Eingabe:** im Pad-Modus die Belegung in `pad_mapping.cpp`. Manche Cores lesen ohne
   `retro_set_controller_port_device` gar nichts (PrBoom, TyrQuake) → `padDevice` setzen.
5. **Test:** `tests/run-host-tests.sh` (u. a. `test_core_select.cpp`) und
   `tests/core_smoketest.cpp` (lädt den Core ohne App auf der Quest, meldet Bild, Ton, Tempo).

**Fertig, wenn:** Der Core startet sein Spiel im Headset, Ton läuft und Spielstände bleiben erhalten.

### Fallen

- Cores nicht direkt aus dem APK laden: ab Android-31-Target verbietet W^X das. Erst nach
  `filesDir/cores/` entpacken, dann `dlopen`.
- DOSBox Pure hängt Spielordner direkt beschreibbar als `C:` ein – Spielstände landen im Spielordner.
  Ordner beim Übertragen `a+rwX` setzen (macht `push-game.sh`), vor dem Neu-Übertragen sichern.
- Kernoptionen müssen **vor** `retro_set_environment` geladen sein – der Core fragt sehr früh.
- Tastenkombinationen (z. B. `LALT+R`) im Abstand von ~50 ms drücken: der Core liest die Tastatur
  einmal pro Bild und würde den Modifikator sonst verpassen.
- `adb push` eines Ordners bricht unter Windows ab → `push-game.sh` überträgt als tar.
- Weitere Symptome mit Lösung: [`docs/DOS-SPIELE.md` → Symptom → Fix](https://github.com/friedensbringer-peacemaker/xr.shell/blob/70241bdd067c0b9546ce6d45b35662e57a333f36/docs/DOS-SPIELE.md)
  und [docs/HAEUFIGE-FEHLER.md](../../docs/HAEUFIGE-FEHLER.md).

## Prüfen ohne Headset

| Werkzeug | Was es zeigt |
|---|---|
| `tests/run-host-tests.sh` | Host-Tests: Core-Wahl, Spielordner, Tastenprofil, Pad-Belegung, Zeiger, Kartenziehen |
| `tests/run-menu-preview.sh` | VR-Menü als PNG am PC rendern |
| `tests/run-device-tests.sh` | Geometrie, Audio, Menü als ARM64-Binary auf der Quest |
| `tools/pull-logs.sh` | Logs von der Quest holen |
