# Selbst portieren: OpenTTD auf die Meta Quest

Diese Seite ist für alle, die den Port **nachbauen, verstehen oder auf ein anderes Spiel
übertragen** wollen. Sie zeigt, an welchen Stellen von OpenTTD eingegriffen wird, wie die
Eingriffe aussehen und woran man erkennt, dass ein Schritt funktioniert.

Wer nur spielen will, braucht diese Seite nicht. Das steht in [RECIPE.md](RECIPE.md).

> **Ausgangsstand:** OpenTTD 15.3 (`14ec60f248`). **Port-Stand:** `xr.openttd-engine` Zweig
> `xr-quest`, Commit [`7172f33`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/commit/7172f33b17721e7d473d1ab628c8baf3286b044d).
> **Gesamter Eingriff auf einen Blick:**
> [Vergleich 15.3 → XR-Port](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/compare/14ec60f248...7172f33b17)
> (28 Dateien, ~3600 Zeilen; davon nur ~150 Zeilen in bestehenden OpenTTD-Dateien).
>
> Die Code-Ausschnitte unten stammen aus `xr.openttd-engine` und stehen wie OpenTTD unter der
> **GPL-2.0**. Sie sind gekürzt; maßgeblich ist immer die verlinkte Datei.

## Die Idee in einem Satz

OpenTTD zeichnet **unverändert** in einen 32-Bit-Pixelpuffer. Ein **neuer Videotreiber `xr`**
schiebt diesen Puffer als Textur auf einen gewölbten Bildschirm im Raum (OpenXR-Zylinder-Ebene)
und verwandelt den Controller-Strahl in die Maus. Der Rest der Engine merkt davon fast nichts.

```
 SDLActivity (Java)                       OpenTTD (C++, libmain.so)
 ────────────────────                     ──────────────────────────────────────────────
 lädt libSDL2.so + libmain.so  ──►  SDL_main()  xr_android_main.cpp
                                       │  Spieldaten aus APK entpacken, chdir, Parameter
                                       ▼
                                    openttd_main(... "-v", "xr" ...)
                                       │
                                       ▼
                                    VideoDriver_XR  (src/video/xr/xr_v.cpp)
                                       ├─ LockVideoBuffer ─► xrWaitFrame   (Takt vom Headset)
                                       ├─ Spiel zeichnet in _screen.dst_ptr (eigener Puffer)
                                       ├─ MakeDirty      ─► geänderter Bereich merken
                                       ├─ Paint/RenderFrame ─► glTexSubImage2D → Swapchain
                                       │                     → Zylinder-Ebene → xrEndFrame
                                       └─ InputLoop      ─► Strahl ∩ Bildschirm → _cursor
```

## Warum gerade so

OpenTTD hat eine saubere **Videotreiber-Schnittstelle** (`src/video/video_driver.hpp`), über die
schon SDL, Cocoa, Win32 und „null“ angebunden sind. Ein weiterer Treiber ist daher der Weg mit
den wenigsten Eingriffen in fremden Code. Andere Engines brauchen andere Wege, siehe
[Übertragen auf andere Spiele](#übertragen-auf-andere-spiele).

## Eingriffspunkte

| # | Datei (Permalink) | Was dort passiert | Art |
|---|---|---|---|
| 1 | [`CMakeLists.txt` L120](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/CMakeLists.txt#L120) | Schalter `XR_QUEST`: eigenes CMake-Modul laden, System-SDL/LZMA/FluidSynth abschalten | geändert |
| 2 | [`CMakeLists.txt` L253](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/CMakeLists.txt#L253) | Programm wird zur Bibliothek `libmain.so` (SDLActivity lädt sie) | geändert |
| 3 | [`cmake/XRQuest.cmake`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/cmake/XRQuest.cmake) | SDL2, liblzma, FluidSynth aus `third_party/` mitbauen, OpenXR-Loader einbinden, `-DWITH_XR_QUEST` | neu |
| 4 | [`src/os/unix/CMakeLists.txt` L19](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/os/unix/CMakeLists.txt#L19) | `unix_main.cpp` weglassen – der Einstieg ist jetzt `SDL_main` | geändert |
| 5 | [`src/video/CMakeLists.txt` L2](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/CMakeLists.txt#L2) | Treiberordner `xr/` einhängen | geändert |
| 6 | [`src/video/xr/xr_android_main.cpp` L180](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_android_main.cpp#L180) | Android-Einstieg: Daten entpacken, Pfade setzen, `openttd_main` mit `-v xr` | neu |
| 7 | [`src/video/xr/xr_v.h`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_v.h) | Klasse `VideoDriver_XR` + Fabrik `FVideoDriver_XR` | neu |
| 8 | [`xr_v.cpp` L292 `InitXr`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_v.cpp#L292) | OpenXR: Instanz, Session, Räume, Aktionen (Controller) | neu |
| 9 | [`xr_v.cpp` L570 `AllocateBackingStore`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_v.cpp#L570) | Eigener Pixelpuffer wird zu OpenTTDs `_screen` | neu |
| 10 | [`xr_v.cpp` L696 `LockVideoBuffer`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_v.cpp#L696) | `xrWaitFrame` – das Headset gibt den Takt vor | neu |
| 11 | [`xr_v.cpp` L1184 `RenderFrame`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_v.cpp#L1184) | Geänderte Pixel hochladen, Zylinder-Ebene, Passthrough, `xrEndFrame` | neu |
| 12 | [`xr_v.cpp` L882 `ProcessControllers`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_v.cpp#L882) | Strahl schneidet Bildschirm → `_cursor`, Trigger → Klick, Stick → Mausrad | neu |
| 13 | [`xr_panel.h`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_panel.h), [`xr_input.h`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_input.h) | Reine Mathematik: Strahl ∩ Zylinder, Glättung, Klickstabilisierung (host-testbar) | neu |
| 14 | [`src/gfx.cpp` L34](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/gfx.cpp#L34) | Mauspfeil ausblendbar und eigene Größe | geändert |
| 15 | [`src/settings_gui.cpp` L602](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/settings_gui.cpp#L602) ff. | Reiter „VR“ in den Spieleinstellungen (Menü im Spiel-Look) | geändert |
| 16 | [`src/toolbar_gui.cpp` L288](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/toolbar_gui.cpp#L288) | Eintrag „VR-Einstellungen“ im Optionen-Menü | geändert |
| 17 | [`src/console_cmds.cpp` L69](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/console_cmds.cpp#L69) | Konsolenbefehl `xr_selftest` (Menüs ohne Headset prüfen) | geändert |

Alle Änderungen an bestehenden Dateien stehen hinter `#ifdef WITH_XR_QUEST` bzw. `if(XR_QUEST)`.
Der normale Desktop-Build bleibt dadurch unverändert, und Upstream-Updates lassen sich leicht
einspielen.

Dazu kommt der **Android-Rahmen** im Port-Repo
[`xr.openttd`](https://github.com/friedensbringer-peacemaker/xr.openttd) (kein OpenTTD-Code):

| Datei | Was dort passiert |
|---|---|
| [`android/src/main/AndroidManifest.xml`](https://github.com/friedensbringer-peacemaker/xr.openttd/blob/main/android/src/main/AndroidManifest.xml) | OpenXR-Rechte und `<queries>` für den Khronos-Loader, `vr.headtracking` required, `vr_only`, Kategorien `com.oculus.intent.category.VR` + `IMMERSIVE_HMD` |
| [`android/src/main/java/xr/openttd/OpenTTDActivity.java`](https://github.com/friedensbringer-peacemaker/xr.openttd/blob/main/android/src/main/java/xr/openttd/OpenTTDActivity.java) | leere Unterklasse von `SDLActivity` – mehr Java braucht es nicht |
| [`android/build.gradle`](https://github.com/friedensbringer-peacemaker/xr.openttd/blob/main/android/build.gradle) | CMake mit `-DXR_QUEST=ON`, SDL-Java-Quellen, OpenXR-Loader als `jniLibs`, freie Spieldaten als `assets` |
| [`tools/fetch-openxr-loader.sh`](https://github.com/friedensbringer-peacemaker/xr.openttd/blob/main/tools/fetch-openxr-loader.sh) | offiziellen Khronos-Loader 1.1.58 holen und Prüfsumme prüfen |

## Schritt für Schritt

Jeder Schritt endet mit einem prüfbaren Ergebnis. Erst weitergehen, wenn es erreicht ist.

### 1. Android-Build, der überhaupt startet

**Ziel:** `libmain.so` baut, die App startet auf der Quest und schreibt ins Logcat.

- Gradle-Projekt mit SDL2-`android-project` als Java-Quelle, eigene Activity = leere
  `SDLActivity`-Unterklasse.
- In CMake das Programm zur gemeinsamen Bibliothek machen:

```cmake
if(XR_QUEST)
    # SDLActivity lädt libmain.so und ruft SDL_main
    add_library(openttd SHARED)
    set_target_properties(openttd PROPERTIES OUTPUT_NAME main)
else()
    add_executable(openttd WIN32)
endif()
```

- Den alten Einstieg (`unix_main.cpp`) für `XR_QUEST` abschalten, eigenen `SDL_main` liefern.
- OpenTTD braucht **Host-Werkzeuge** (`strgen`, `settingsgen`), die auf dem PC laufen:
  `tools/build-host-tools.sh` baut sie vorab, CMake bekommt ihren Pfad.

**Fertig, wenn:** `adb logcat -s OpenTTD` nach dem Start Ausgaben zeigt.

### 2. Daten und Pfade

**Ziel:** Die Engine findet Sprachdateien, Grafik und Konfiguration.

Android hat kein normales Arbeitsverzeichnis. Der Einstieg entpackt deshalb einmal pro Version
die Daten aus der APK in den App-Ordner und setzt alle Pfade dorthin
([`xr_android_main.cpp`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_android_main.cpp#L180)):

```cpp
extern "C" int SDL_main(int, char *[])
{
	const std::filesystem::path base = SDL_AndroidGetExternalStoragePath();
	ExtractGameData(base);                       // APK-assets → /sdcard/Android/data/xr.openttd/files
	setenv("HOME", base.c_str(), 1);
	setenv("XDG_DATA_HOME", base.c_str(), 1);
	setenv("XDG_CONFIG_HOME", base.c_str(), 1);
	chdir(base.c_str());

	std::vector<std::string_view> params = {"openttd", "-c", config_arg,
		"-b", "32bpp-anim", "-v", "xr", "-s", "sdl", "-m", music_arg};
	const int result = openttd_main(params);
	_exit(result);                               // SDL hält den Prozess sonst mit alten Globals am Leben
}
```

**Falle:** Komprimierte APK-Assets wurden anfangs nur teilweise gelesen, die App beendete sich
sofort. Assets vollständig in Schleife lesen (siehe `ReadAsset`).

**Fertig, wenn:** Mit dem Treiber `null` (`-v null`) läuft das Spiel ohne Absturz im Hintergrund.

### 3. Der Videotreiber: Bild in den Raum

**Ziel:** Das Hauptmenü erscheint als Bildschirm vor dir.

Ein neuer Treiber registriert sich selbst über eine statische Fabrik, Priorität und Name `xr`
([`xr_v.h`](https://github.com/friedensbringer-peacemaker/xr.openttd-engine/blob/7172f33b17721e7d473d1ab628c8baf3286b044d/src/video/xr/xr_v.h)):

```cpp
class FVideoDriver_XR : public DriverFactoryBase {
public:
	FVideoDriver_XR() : DriverFactoryBase(Driver::DT_VIDEO, 20, "xr", "OpenXR Video Driver (Meta Quest)") {}
	std::unique_ptr<Driver> CreateInstance() const override { return std::make_unique<VideoDriver_XR>(); }
};
```

Die vier Methoden, auf die es ankommt:

**a) Eigener Puffer wird zum Spielbildschirm** (`AllocateBackingStore`):

```cpp
s.pixels.assign(static_cast<size_t>(w) * h, 0);
_screen.width = w;  _screen.height = h;  _screen.pitch = w;
_screen.dst_ptr = s.pixels.data();
BlitterFactory::GetCurrentBlitter()->PostResize();
GameSizeChanged();
```

**b) Das Headset gibt den Takt vor** (`LockVideoBuffer`): Bevor OpenTTD zeichnet, wartet der
Treiber mit `xrWaitFrame` auf das nächste Bild. Das ersetzt VSync, deshalb erzwingt
`ToggleVsync` immer `true`.

**c) Nur Geändertes hochladen** (`MakeDirty` + `RenderFrame`): OpenTTD meldet geänderte
Rechtecke; der Treiber sammelt sie und lädt nur diesen Ausschnitt hoch.

```cpp
glPixelStorei(GL_UNPACK_ROW_LENGTH, s.width);
glTexSubImage2D(GL_TEXTURE_2D, 0, r.left, r.top, r.right - r.left, r.bottom - r.top,
	GL_RGBA, GL_UNSIGNED_BYTE, s.pixels.data() + r.top * s.width + r.left);
```

Danach wird die Textur nur dann in das nächste Swapchain-Bild kopiert, wenn sich etwas geändert
hat. Das spart auf der Quest viel Leistung.

**d) Ebenen abgeben** (`RenderFrame`, Ende): Passthrough-Ebene (optional, ganz unten), dann der
Bildschirm als `XrCompositionLayerCylinderKHR` (gewölbt) oder `XrCompositionLayerQuad` (flach),
zuletzt eine Projektions-Ebene für den Strahl; alles in `xrEndFrame`.

**Fallen:**
- Nur 32-bpp-Blitter werden unterstützt (`Start` lehnt anderes ab) – deshalb `-b 32bpp-anim`.
- Der Absturz-Handler kann den Puffer aus einem anderen Thread sperren: dort **keine**
  OpenXR-Aufrufe (`main_thread`-Prüfung in `LockVideoBuffer`).
- Swapchain und Textur im **gleichen** Farbformat anlegen (sRGB rein und raus), sonst wirkt das
  Bild ausgewaschen oder zu dunkel.
- Den Strahl nur mit beiden Augen-Views abgeben, sonst verwirft `xrEndFrame` das ganze Bild.

**Fertig, wenn:** Das Hauptmenü ist im Headset scharf als gewölbter Bildschirm zu sehen
(Quest-Screenshot als Beleg).

### 4. Controller als Maus

**Ziel:** Mit dem Strahl zeigen und mit dem Trigger klicken.

`InputLoop` → `ProcessControllers` wird pro Spieltakt aufgerufen. Der Strahl wird in das
Koordinatensystem des Bildschirms umgerechnet, mit dem Zylinder geschnitten (`vrPanel::intersect`)
und der Treffer geglättet. Daraus wird OpenTTDs Mauszeiger gesetzt:

```cpp
const int x = std::clamp(static_cast<int>(s.smooth_u * s.width), 0, s.width - 1);
const int y = std::clamp(static_cast<int>(s.smooth_v * s.height), 0, s.height - 1);
_cursor.in_window = true;
if (_cursor.fix_at) {
	// gesperrter Zeiger (Karte ziehen): nur die Bewegung seit dem letzten Bild weitergeben
	_cursor.UpdateCursorPositionRelative(x - s.last_x, y - s.last_y);
} else {
	_cursor.UpdateCursorPosition(x, y);
}
HandleMouseEvents();
```

Trigger = linke Maustaste, Stick hoch/runter = Mausrad (Zoom). Die Mathematik liegt bewusst in
reinen Header-Dateien (`xr_panel.h`, `xr_input.h`), damit sie am PC getestet werden kann
(`tools/tests/run.sh`).

**Falle:** Ohne **Klickstabilisierung** verrutscht der Zeiger beim Drücken des Triggers um ein paar
Pixel – bei kleinen OpenTTD-Knöpfen trifft man dann daneben. Lösung: Während des Klicks die
Glättung kurz einfrieren (`click_lock_until`).

**Fertig, wenn:** Im Headset ein neues Spiel per Controller begonnen werden kann.

### 5. VR-Einstellungen im Spiel

**Ziel:** Bildschirmgröße, Abstand, Wölbung, Zeiger, Passthrough usw. lassen sich im Spiel ändern.

Statt eines eigenen Overlays bekommt das vorhandene Einstellungsfenster einen Reiter „VR“. Dafür
reichen kleine Weichen in `settings_gui.cpp`, die alles an `xr_settings_gui.cpp` weiterreichen:

```cpp
#ifdef WITH_XR_QUEST
		if (IsXrSettingsWidget(widget)) {
			XrSettingsDraw(r, widget);
			return;
		}
#endif
```

Pflicht für jedes VR-Menü: **Beenden mit Bestätigung** und **Mauszeiger ausblendbar**
(`_cursor_hidden` in `gfx.cpp`). Gespeichert wird in einer eigenen `xr.cfg`.

**Fertig, wenn:** `xr_selftest` in der Konsole meldet `xr_selftest OK`, und im Headset lassen
sich alle Werte ändern und überleben einen Neustart.

### 6. Lebenszyklus

**Ziel:** Brille ab/auf, Quest-Menü und Beenden zerstören nichts.

`PollXrEvents` verarbeitet die Sitzungszustände. Bei Fokusverlust pausiert das Spiel, beim
Beenden über das Quest-Menü wird vorher gespeichert. Ohne laufende Session taktet `xrWaitFrame`
nicht mehr; `MainLoop` schläft dann kurz, sonst läuft die CPU heiß.

**Fertig, wenn:** Spielstand übersteht Beenden über das Quest-Menü, und nach Brille ab/auf
läuft das Spiel weiter (kein ANR).

## Prüfen ohne Headset

| Werkzeug | Was es zeigt |
|---|---|
| `tools/tests/run.sh` | Host-Tests für Strahl/Zylinder-Schnitt, Glättung, Klicklogik |
| `tools/desktop-selftest.sh` | Desktop-Build mit `XR_DESKTOP_PREVIEW`: VR-Reiter am PC prüfen |
| `tools/apk-gate.sh <apk>` | Paketname, Manifest, `.so`-Liste, **keine Originaldaten in der APK** |
| `tools/quest-smoke-test.sh --install <apk>` | Unbeaufsichtigter Gerätetest mit Logcat-Auswertung |
| Logcat-Zeile `xr perf:` | alle 10 s: Bildrate, Wartezeit, Upload-Menge, Auflösung |

## Übertragen auf andere Spiele

Der Treiber-Weg passt, wenn die Engine **in einen eigenen CPU-Puffer zeichnet** und eine
Treiber-Schnittstelle hat. Für andere Engines gibt es andere Einhängepunkte – die Kitchen hat für
jeden ein Vorbild:

| Wie die Engine ihr Bild ausgibt | Einhängepunkt | Vorbild |
|---|---|---|
| eigene Videotreiber-Schnittstelle, CPU-Puffer | neuer Treiber (diese Seite) | OpenTTD, Settlers 2 (RTTR) |
| SDL-Renderer (`SDL_RenderPresent`) | Present per Linker-Wrap abfangen | [Theme Hospital (CorsixTH)](../themehospital-corsixth/RECIPE.md) |
| eigener GL-Renderer | Present-Hook: fertiges Bild vor dem Tauschen übernehmen | [Warcraft II (Wargus)](../warcraft2-wargus/RECIPE.md) |
| Emulator / libretro-Core | Core-Framebuffer als Textur | [DOS (XRShell)](../dos-xrshell/RECIPE.md) |

Immer gleich bleiben: Manifest-Einträge, Khronos-Loader, `xrWaitFrame` als Takt, Strahl ∩
Bildschirm → Mauskoordinate, Pflicht-Menü (Beenden, Zeiger aus), Lebenszyklus. Typische Fehler
dabei stehen in [docs/HAEUFIGE-FEHLER.md](../../docs/HAEUFIGE-FEHLER.md).
