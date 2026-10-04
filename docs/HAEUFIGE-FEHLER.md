# Suppe versalzen? – Häufige Fehler und ihre Lösung

Die meisten Hobby-Köche haben schon mal eine Suppe versalzen, den fremden Herd nicht angekriegt
oder den Braten zu früh aus dem Ofen geholt. Beim Portieren ist das nicht anders: Die meisten Pannen
passieren nicht einmal, sondern in fast jedem Port wieder – und meistens gibt es einen bewährten
Handgriff, der die Suppe rettet.

Hier steht, was in unserer Hobbyküche bisher angebrannt ist – quer durch alle Quest-Ports, von
Siedler II/RttR, OpenRA, OpenTTD, CorsixTH, OpenXcom, Stratagus und XRShell/DOSBox Pure bis zu
.NET-, SDL3-, Godot- und Winlator-Projekten. Jede Zeile ist eine Panne, die wirklich passiert ist,
samt dem Handgriff, mit dem das Gericht am Ende doch noch auf den Tisch kam. Gelesen wird wie in
der Küche: **Symptom** = was komisch schmeckt, **Ursache** = was beim Kochen schiefging,
**Lösung** = wie man es rettet (oder beim nächsten Mal gleich richtig macht).

Spalte **Gesehen in**: Siedler = settlers2-rttr, RA = openra-redalert, TTD = openttd,
TH = themehospital-corsixth, XCOM = xcom-tftd-oxce, WC2/WC1 = warcraft2-wargus/warcraft1-war1gus,
DOS = dos-xrshell (XRShell). Weitere XRShell-Apps: RETRO (Konsolen), FPS (Shooter), ADV (ScummVM),
DK1 (DOS-Strategie). Ports ohne eigenes Rezept: FARM (Farm-Sim, .NET/MonoGame), TERRA (FNA),
LAWN (SDL2-Portierung), MERCS (SDL3/Rust), NILE (SDL2-Aufbauspiel), HACKER (SDL), DIABLO
(DevilutionX), DKFX (KeeperFX), 0AD (0 A.D.), AGES (openage), GEMS (SDL-Renderer-Spiel),
ISLAND/FLEET (eigene Godot-Prototypen), LOGGER (Log-App), WINLATOR (Windows-Spiel über Winlator).

**◐** = Ursache belegt, Lösung gebaut und am PC/Gerät getestet, im Headset noch nicht bestätigt.

## Die Baustellen, die (fast) jeder Port lösen musste

*Die Grundzutaten, ohne die kein Gericht gelingt – egal, welches Rezept man kocht.*

| # | Baustelle | Worum es geht | Abschnitt |
|---|---|---|---|
| 1 | **Spielbild in OpenXR** | Das Bild der Engine muss in eine OpenXR-Swapchain – je nach Engine per eigenem Videotreiber, abgefangenem Present, Readback oder libretro-Frontend | [Bild](#c-bild-in-openxr) |
| 2 | **Lebenszyklus** | Brille ab/auf, Laden, Beenden: ohne Sonderbehandlung gibt es ANRs, Hänger oder verlorene Spielstände | [Lebenszyklus](#d-lebenszyklus-anr-beenden) |
| 3 | **Controller als Maus** | Strahl, Klick, Ziehen, Scrollen – plus Abschalten von Engine-Gewohnheiten wie Kanten-Scrollen | [Eingabe](#e-eingabe) |
| 4 | **Daten aufs Gerät** | Originaldaten ohne Verlust und mit den richtigen Rechten auf die Quest bringen | [Gerät](#b-gerät-installation-daten) |
| 5 | **Windows-Toolchain** | SDK/NDK, Git Bash, Pfade – fast jeder Port scheiterte zuerst am Build unter Windows | [Toolchain](#a-toolchain-und-build) |
| 6 | **Bildqualität & Leistung** | Flimmern, Unschärfe, zu kleiner Text, zu wenig Bilder pro Sekunde | [Leistung](#g-leistung-und-bildqualität) |
| 7 | **VR-Menü-Pflichtumfang** | Beenden mit Bestätigung, Zeiger ausblendbar, Stick-Bedienung, Persistenz (Skill `xr-vr-menu`) | – |
| 8 | **Nachweis** | „Gebaut“ ist nicht „im Headset geprüft“ – mehrere Fehlschlüsse kamen von zu optimistischen Prüfungen | [Prozess](#h-prozess-und-nachweis) |
| 9 | **Bildrate** | Spielrate und Anzeigerate passend wählen (72/90/120 Hz), Takt ohne Drift | [Leistung](#g-leistung-und-bildqualität) |

---

## A. Toolchain und Build

*Der Herd geht nicht an.* Bevor überhaupt gekocht wird, müssen die Küchengeräte laufen – unter
Windows war das bei fast jedem Port die erste Hürde.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| SDK „verschwindet“, andere Programme finden es nicht | Claude Desktop läuft als MSIX-Sandbox und leitet `%LOCALAPPDATA%` um | SDK in einen festen gemeinsamen Ordner (`<XR-Ordner>/_tools/android-sdk`), `ANDROID_HOME` als Benutzervariable | alle (Windows) |
| `sdkmanager` installiert falsche/keine Pakete | `sdkmanager.bat` zerlegt Paketnamen am `;` | `cmdline-tools/latest/bin/android.exe sdk install "ndk;…"` | Siedler, alle |
| Gradle bricht mit Java-Fehler ab | Java 8 liegt im PATH vor JDK 17 | `JAVA_HOME` auf JDK 17 setzen | alle (Windows) |
| Gradle 9 bricht den Build | systemweites `gradle` (Homebrew) statt Wrapper | immer `./gradlew` bzw. `gradlew.bat`; hat das Upstream-Projekt keinen Wrapper, einen einchecken | XRShell (Mac), LAWN |
| `ALooper_pollAll` nicht gefunden | mitgeliefertes SDL 2.0.22 ist zu alt für NDK ≥ 27 | eigene SDL-2.32-Submodule; im eigenen Code `ALooper_pollOnce` | WC2, XRShell |
| ExternalProject baut für armv7/API 21 | ExternalProjects erben nur `CMAKE_TOOLCHAIN_FILE` | Toolchain-Wrapper (`quest-arm64.toolchain.cmake`) | WC2 |
| CMake-Symlinks scheitern | Windows ohne Entwicklermodus | betroffene Hilfstools abschalten (`ENABLE_APP OFF`) | Siedler (bzip2) |
| Pfad wird zu `…/D:/…` | absolute Pfade an `${CMAKE_BINARY_DIR}/` angehängt | Laufwerk/Root vorher abstreifen | Siedler |
| OpenXR-Loader-Codegen scheitert | nur der Store-Platzhalter `python3` im PATH | echtes Python in den PATH | Siedler |
| Builder-Ausgabe unlesbar | Konsole in cp1252 | `PYTHONIOENCODING=utf-8` | Siedler |
| `msgfmt` fehlt bzw. Build bricht spät ab | gettext nicht installiert; `find_package(Gettext)` braucht `msgfmt` **und** `msgmerge` | `winget install mlocati.GetText`; Vorprüfung testet beide als Fehler | Siedler |
| Build scheitert an Pfadlänge | tiefe Checkout-Pfade unter Windows | kurzer Checkout-Pfad | Siedler |
| Host-Tools (strgen, wartool, tolua++) fehlen | werden für den Host gebraucht, nicht für Android | llvm-mingw portabel (`ucrt-x86_64`, `-static`) | TTD, WC2 |
| Jeder Commit löst 18-min-Vollbuild aus | Git-Revision als CMake-Argument | Revision nicht in Compile-Definitionen | XCOM |
| Build ist kaputt, obwohl der Code stimmt | Quellen wurden während des Builds geändert | Build nur auf ruhendem Stand; Version verwerfen | TTD (preview.7) |
| „Ausführung von Skripts ist deaktiviert“ | Windows-Ausführungsrichtlinie blockiert `.ps1` | `Kitchen.cmd` doppelklicken oder `powershell -ExecutionPolicy Bypass -File kitchen.ps1 …` | Kitchen |
| PowerShell-Skript bricht mit „Unerwartetes Token“ ab | typografische Anführungszeichen („ “ ”) in einem Text mit doppelten Anführungszeichen – PowerShell wertet sie als Anführungszeichen | in Code-Texten nur ' oder " verwenden; deutsche Anführungszeichen nur in einfachen Anführungszeichen oder in Textdateien | Kitchen |
| Umlaute in PowerShell-Ausgaben kaputt | Skript ohne BOM gespeichert, PowerShell 5.1 liest es als ANSI | `.ps1` als UTF-8 **mit** BOM speichern | Kitchen |
| Dateien „geändert“ ohne Inhaltsänderung | `autocrlf` nach `sed -i` | `git update-index --refresh`; `.gitattributes`; in Forks Zeilenenden wie Upstream lassen (sonst unlesbarer Diff) | alle, DIABLO |
| Selbstbau scheitert: `libopenxr_loader.so` fehlt | Loader nicht im Repo, nur von einem anderen Port kopiert | offizielles Khronos-Paket `org.khronos.openxr:openxr_loader_for_android` (Maven Central) per Skript holen, Prüfsumme prüfen | TTD |
| GitHub-ZIP baut nicht | Submodule fehlen im ZIP | `git clone --recurse-submodules` | Siedler |
| Engine mit SpiderMonkey/Mozilla-Build bzw. Rust-Cross-Build baut unter Windows nicht | braucht Linux/macOS-Host; kein `sudo` für Pakete | WSL2 ohne `sudo`: Werkzeuge aus conda-forge, Build-Baum im Linux-Dateisystem, Quellen spiegeln | 0AD, AGES |
| Langer WSL-Build stirbt mitten im Lauf | Hintergrundjobs enden mit dem `wsl.exe`-Aufruf bzw. der Sitzung | `setsid nohup … &` im selben `bash -c`, Fortschritt in eine Logdatei | 0AD, AGES |
| CMake in WSL hängt ewig | der Windows-PATH (`/mnt/c/…`) wird über 9p durchsucht | alle `/mnt/*`-Einträge aus `PATH` filtern | AGES |
| Abbruchbefehl beendet die eigene Shell; `wsl.exe` hängt mit `ERROR_TIMEOUT` | `pkill -f <muster>` trifft die eigene Kommandozeile; WSL-VM hängt | PIDs gezielt beenden; bei `ERROR_TIMEOUT` `wsl --shutdown` | AGES, 0AD |
| Deploy-Skript installiert jedes Mal neu | unter `set -o pipefail` scheitert `adb … \| grep -q` an SIGPIPE | Ausgabe erst in eine Variable lesen (`\r` entfernen), dann prüfen | WINLATOR |
| Seltsames Verhalten von `char`-Code auf der Quest | `char` ist auf ARM vorzeichenlos | `-fsigned-char` | DKFX |
| Unter-Builds (SDL3, openal-soft …) scheitern | brauchen `ninja` im PATH bzw. CMake ≥ 3.26; fmt braucht mit NDK r30 `-include cstdlib` | SDK-CMake 3.31 samt `ninja` in den PATH der Build-Skripte; `-include cstdlib` | MERCS, FARM, DKFX |
| Rust-Teil baut unter Windows nicht | kein Visual Studio installiert | `rustup` mit Host `x86_64-pc-windows-gnu` und Ziel `aarch64-linux-android`, cargo-Pfad im Skript | MERCS |
| Linker-Wrap (`--wrap`) greift nicht | `--wrap` wirkt nur auf Aufrufe aus **anderen** Objektdateien – nicht innerhalb derselben Bibliothek (z. B. `SDL_RenderPresent` in `libSDL2.so`) | Wraps in eigene Übersetzungseinheit; bei SDL-Renderer-Spielen `SDL_RenderFlush` + `SDL_GL_SwapWindow` selbst aufrufen | DKFX, GEMS |
| Native Tests auf der Quest liefen nie | AGP legt das Testprogramm unter `build/intermediates/cxx/…` ab | Pfad im Testskript korrigieren und prüfen, dass Tests wirklich liefen (Anzahl > 0) | TH |
| Gradle/AAPT2 stürzt sporadisch ab, ohne Codeänderung | mehrere schwere Builds gleichzeitig auf demselben Rechner | erneut bauen; schwere Builds nicht parallel | ISLAND |
| Windows-3.1-INI „incomplete“ nach Skriptänderung | Git-Bash-`sed` hat die CRLF-Zeilenenden entfernt | Windows-Konfigs byte-genau ändern (CRLF behalten), mit dem echten Lader prüfen | DOS (Win 3.1) |
| PowerShell-5.1-Wrapper übergibt verstümmelte Anführungszeichen | PS 5.1 maskiert Argumente für native Programme falsch | Befehl in eine temporäre `.sh` schreiben und über Git Bash ausführen | Kitchen |

## B. Gerät, Installation, Daten

*Die Zutaten kommen nicht in den Topf.* Alles ist vorbereitet, aber auf dem Weg vom Brett in den
Topf (vom PC auf die Quest) geht etwas verloren oder landet im falschen Topf.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| adb trennt ständig, „server killed“ | zwei adb-Versionen beenden sich gegenseitig den Server – oft SideQuest, das ein eigenes adb mitbringt | genau **ein** adb für alle Projekte; SideQuest schließen oder dort dasselbe adb einstellen | alle |
| `adb push` eines Ordners bricht ab | Windows-adb 37 | Ordner als **eine** tar-Datei übertragen, auf dem Gerät entpacken (`kitchen push`) | DOS, WC2 |
| `/sdcard/…` wird zu `C:/Program Files/Git/sdcard` | Git Bash schreibt Pfade um | `MSYS_NO_PATHCONV=1` für adb – aber **nicht** für gradlew (bricht dort); lokale Pfade dann als `D:/…` übergeben (`cygpath -m`) | alle |
| App kann übertragene Daten nicht lesen | von adb angelegte Ordner gehören dem Nutzer `shell` | Rechte setzen (`chmod`), macht `kitchen push` | DOS |
| Schreiben nach `Android/data/<app>` klappt nicht zuverlässig | Horizon OS schränkt adb dort ein | in den App-Speicher per `run-as` (nur Debug-APK) oder eigener Ordner mit „Alle Dateien“ | TH, XCOM |
| `install -r` scheitert mit Signaturfehler | jeder Rechner (bzw. jede Godot-Editoreinstellung) hat einen eigenen Debug-Schlüssel | **nicht** deinstallieren (löscht Spielstände) – erst Spielstände sichern; gemeinsamen Debug-Schlüssel fest im Projekt/Export-Preset, Signatur vor dem Install prüfen | Siedler, TH, ISLAND |
| Testergebnis ergibt keinen Sinn | versehentlich ein alter oder anderer Build installiert (z. B. abgebrochene Installation) | vor jedem Test `versionName` prüfen (`dumpsys package`); Version + Commit sichtbar in der App anzeigen | Siedler, FLEET |
| App startet nicht, Systemdialog erscheint | Horizon OS fängt den Start ab (Brille schläft, Controller-Update) | Brille wecken, Controller aktualisieren; Start nicht blind wiederholen | RA, TTD |
| Test ohne Brille bleibt hängen | Brille im Ruhezustand, Guardian/Systemdialoge | `adb shell am broadcast -a com.oculus.vrpowermanager.prox_close` | XCOM, TTD |
| „App-Name nicht verfügbar“ in der Systemleiste | Horizon-OS-Eigenheit | aus der App nicht zu verhindern – ignorieren | Siedler, RA |
| Falsches Spiel startet | XRShell nimmt eine Datei in `game/` vor dem alphabetisch ersten Ordner | Ordner benennen (`1-…`), keine losen Dateien | DOS |
| adb kann von der App geschriebene Logs/Einstellungen nicht lesen | Gegenrichtung der Rechte-Falle: Ordner ohne Setgid, App-umask 027 | Ordner `0775`/`02770` und Dateien `0664` ausdrücklich setzen | DOS, RETRO, FPS, WC2 |
| `adb push` scheitert mit „remote fchown failed“ | App nie gestartet, Paketordner gehört `shell` | App einmal starten (legt `files/` an) oder nach `/data/local/tmp` pushen und hineinkopieren | DOS, 0AD |
| `INSTALL_FAILED_VERSION_DOWNGRADE` | anderer Rechner/Arbeitsstand hat dieselbe App mit höherem `versionCode` installiert | `versionCode` bei jeder weitergegebenen APK erhöhen; klären, wer die App baut; nie deinstallieren | DOS |
| `adb devices` leer, obwohl Windows das ADB-Interface zeigt | adb-Server hängt | `adb kill-server`, `adb start-server` – nur, wenn gerade niemand sonst adb nutzt (beendet laufende Logger/Übertragungen) | XCOM, alle |
| Logger hat Lücken oder läuft doppelt | logd verwirft alte Einträge ohne Dauer-Logger; Beenden der Hülle stoppt `adb logcat` nicht | vor jedem Test prüfen, dass genau **ein** Dauer-Logger läuft; Kindprozesse gezielt beenden | LAWN, alle |
| `screencap` liefert 0 Byte oder kein Spielbild | Brille schläft; System-Screenshots enthalten immersive Ebenen nicht immer | Brille wecken (`prox_close`, danach `automation_disable`); Bildbefunde per Screenshot aus der Brille | alle |
| Screenshot heißt nicht nach dem Port | Dateiname nach der App mit Shell-Fokus | nach Uhrzeit zuordnen | FARM |
| Engine-Meldungen fehlen in logcat | `stdout`/`stderr` landen auf Android nirgends | `__android_log_print` bzw. `pipe` + `dup2` + Pumpthread nach logcat | TH, Siedler, TTD |
| Logs/Abstürze der eigenen Apps auf der Quest selbst ansehen | fremde Logs brauchen `READ_LOGS` und `DUMP` | `pm grant <app> android.permission.READ_LOGS` (und `DUMP`) per adb; einen dauerhaft laufenden logcat-Prozess nutzen | LOGGER |
| Eigener logcat-Parser erkennt Quest-Zeilen nicht | `-v threadtime -v uid` hat auf der Quest keinen Doppelpunkt hinter der UID | Parser an echter Gerätezeile testen | LOGGER |

## C. Bild in OpenXR

*Der Teller bleibt leer.* Das Spiel läuft, aber nichts kommt beim Gast an – schwarz, verdreht oder
in falschen Farben angerichtet.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| SIGSEGV direkt beim Start | Stack des `android_main`-Threads nur ~1 MB, große Puffer auf dem Stack | große Puffer auf den Heap (`std::vector`, `make_unique`) | XRShell |
| SIGSEGV im ersten Frame | Engine definiert globale Funktionszeiger mit GL-Namen (`glUseProgram`) – überdecken libGLESv3 | betroffene Datei per Präprozessor umbenennen; Build-Prüfung `llvm-nm … \| grep ' [BbDd] gl'` | WC2 |
| Schwarzes Bild | Spielbild landet nicht im richtigen FBO/Swapchain-Bild | eigenes Offscreen-FBO, erst dann in die Swapchain kopieren | XRShell (racer3k) |
| Farben vertauscht | Pixelformat der Engine ≠ Texturformat | Kanäle beim Hochladen tauschen bzw. passendes Format | XRShell |
| Bild steht auf dem Kopf | GL-Zeilen zählen von unten; Engine dreht erst beim Blit | beim Kopieren vertikal spiegeln; an bekanntem Layout prüfen, nicht an Zahlen | XCOM, RA |
| Nur ein Ausschnitt oder Streifen | Texturausschnitt/`mediump` bei großen Bildern | richtigen Ausschnitt; `highp` bzw. `texelFetch` | XRShell |
| Bild flackert nach eigenem GL-Zugriff | SDL cached den GL-Zustand | GL-Zustand um jeden eigenen Zugriff sichern/wiederherstellen | TH, TTD |
| Absturz nach Auflösungswechsel | FBO und Swapchain nicht gemeinsam neu angelegt | immer beide zusammen neu, alte Ressourcen erst nach Erfolg freigeben | Siedler |
| Welt dreht falsch mit dem Kopf | falsche View-Matrix | View = invertierte Augenpose, Projektion aus `XrFovf` (asymmetrisch) | XRShell |
| `xrCreateInstance`/`xrCreateSession` scheitern | `xrInitializeLoaderKHR` nicht der erste Aufruf bzw. Grafikanforderungen nicht abgefragt | Loader-Init mit VM/Activity zuerst; `xrGetOpenGLESGraphicsRequirementsKHR` vor `xrCreateSession`; ohne Instanz den Zahlencode loggen | alle |
| OpenXR startet nicht/kein Bild, obwohl die Engine läuft | Engine fordert über SDL einen GLES-2-Kontext an | `SDL_GL_SetAttribute` per Wrap auf GLES 3 umbiegen; GLES-2-Shader laufen weiter | LAWN |
| Intro/Film schwarz, Spiel sichtbar | Engine hat für Filme eine zweite Present-Stelle | vorher **alle** Present-/Swap-Stellen suchen (`SDL_RenderPresent`, `SDL_GL_SwapWindow`, `SDL_UpdateTexture`, `eglSwapBuffers`) | WC2 |
| Nur ein vergrößerter Ausschnitt im Fenster | Spiel schaltet auf Vollbild und übernimmt die echte Panelauflösung | der Engine eine virtuelle Anzeige fester Größe melden, Fläche per `setFixedSize` | FARM, HACKER |
| Bild bleibt stehen, Log „passt nicht“ | Frame größer als die Bildschirm-Textur wird verworfen | Renderauflösung passend zur Textur wählen (z. B. 640×400 für 16:9) | FPS, DOS |
| SIGSEGV mit `pc 0` beim ersten dynamischen Puffer-Upload | optionale GLES-Erweiterung fehlt im Quest-Treiber (`GL_OES_mapbuffer`) | Ersatzweg über `glBufferSubData`; Build-Prüfung, dass optionale Erweiterungsaufrufe abgesichert sind; Erweiterungsliste loggen | 0AD |
| Absturz bei GL-Debug-Ausgabe unter GLES 3.2 | Debug-Zeiger werden nur über `GL_KHR_debug` geladen | Debug-Ausgabe nur, wenn die Erweiterung gemeldet und alle Zeiger geladen sind | 0AD |
| Vertauschte Glyphen in Dialogen (SDL2-Renderer) | `SDL_SetTextureScaleMode` bindet die Textur sofort, gepufferte Befehle lesen aus der falschen | Wrapper: vorher flushen, Bindung verwerfen ◐ | NILE |
| Fenster startet an alter/falscher Position | Kopfpose in den ersten Frames noch ungültig | erst zentrieren, wenn Position **und** Orientierung gültig sind, sonst jeden Frame neu versuchen; nur Yaw übernehmen | Siedler, ISLAND |

## D. Lebenszyklus, ANR, Beenden

*Die Suppe kocht über.* Kurz weggeschaut (Brille abgesetzt), zu lange auf dem Herd gelassen (Laden)
oder den Topf falsch vom Feuer genommen (Beenden) – und schon ist die Sauerei da.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| ANR nach Brille ab/auf | GLSurfaceView gibt den EGL-Kontext frei, Neuaufbau dauert ~9 s | `PreserveEGLContextOnPause = true`; Gegentest per Standby + Aufwecken | RA |
| ANR beim Laden | lange Schritte (> 5 s) auf dem GL-/UI-Thread | Laden in Etappen pro Frame (z. B. 10 Karten je Frame), Ladeanzeige sofort | RA |
| Spiel friert bei Fokusverlust ein | SDL 2.0.9 hält den Spiel-Thread an; Horizon OS meldet Fokusverlust oft (auch beim Screenshot) | Fokusverlust ignorieren bzw. nur pausieren | XCOM, Siedler |
| Spiel hängt nach Rückkehr | Fokus-Events + `PauseOnLeave` der Engine | Fokus-Events verwerfen, `PauseOnLeave=false` (im Headset bestätigt) | WC2 |
| Beenden dauert 10 s oder zeigt Dialog | Engine kennt nur `SDL_QUIT` | Event-Filter, bei `SDL_APP_TERMINATING` sofort beenden (`_exit`) | WC2 |
| Spielstand weg nach Beenden über das Quest-Menü | Beenden ohne Speichern | beim Beenden-Ereignis speichern | TTD |
| Spielstände nach Neuinstallation weg | Spielstände lagen im Spielordner bzw. App wurde deinstalliert | Spielstände getrennt ablegen (`saves/`), nie deinstallieren; wo das nicht geht (DOSBox Pure schreibt direkt in den Spielordner), beim Neu-Übertragen sichern | DOS, TH |
| Zweiter Start verhält sich anders | Android hält den Prozess nach „Beenden“ am Leben | Engine-Init idempotent machen – oder bei Engines mit viel globalem Zustand den Prozess beim Spielende beenden | RA, FARM, DKFX |
| Nach Absturz fehlen Umgebungsvariablen | Android startet die Activity im frischen Prozess neu (mit dem ursprünglichen Intent) | Variablen (`HOME`, `XDG_CONFIG_HOME`, `USER`) in der Activity setzen und per `Os.getenv` lesen; höchstens eine Umleitung pro Prozess, sonst Startschleife ◐ | TH, Siedler |
| Engine hängt beim Start | Arbeitsverzeichnis ist `/` | vor dem Engine-Start `chdir` in den Datenordner | TH |
| Absturz in der Konfiguration | Umgebungsvariable `USER` fehlt | `USER` setzen | TH |
| Wirkt wie ein Freeze, ist aber ein Absturz | letzter Frame bleibt stehen; ein eigener Signal-Handler der Engine kehrt nach SIGSEGV zurück und wiederholt die Anweisung endlos | bei Ausnahme ein deutliches Fehlerbild aufs Quad legen; Signal-Handler beendet den Prozess | RA, Siedler, NILE |
| ANR („Input dispatching timed out“) 5 s nach jedem Beenden | `android_main` kehrte nach `ANativeActivity_finish` sofort zurück | nach dem Beenden-Wunsch Ereignisse weiter abholen bis `APP_CMD_DESTROY` ◐ | DOS, DK1 |
| Beenden über das Quest-Menü erreicht die Engine nie bzw. Prozess läuft Minuten weiter | Quit nur bei laufender Session geprüft; XR-Session nach Spielende nicht abgemeldet | bei `EXITING`/`LOSS_PENDING` Engine-Quit auslösen; beim Spielende `xrRequestExitSession`, dann geordnet abbauen ◐ | NILE, LAWN |
| Einstellungen der Engine gehen bei jedem Start verloren | Engine speichert nur beim regulären Ende, die App endet per `_exit` | vor `_exit` sichern; zusätzlich beim Schließen des VR-Menüs und bei Fokusverlust ◐ | NILE |
| Spiel läuft bei abgesetzter Brille weiter (Ton, Rumble, Spielzeit) | Pause hing nur am eigenen Menü; ohne Session dreht die Schleife leer | eigener Pausengrund „Fokus/Session“: Ton und Rumble aus, Spielstand sichern; ohne Session mit Timeout pollen ◐ | DOS, FPS, RETRO |
| Ton hörbar, aber nichts zu sehen | App gestartet, während die Brille lag – Inhalt irgendwo im Raum platziert | bei Fokus-Rückkehr nicht verankerte Inhalte neu vor den Nutzer stellen bzw. Richtungshinweis | FLEET, ISLAND |
| App beendet sich lautlos oder hängt beim Start | Engine-Fehler erscheinen als MessageBox/Dialog – in der immersiven App unsichtbar, der modale Dialog hält die Schleife an | Meldungsfenster per Wrap in die VR-Ladeanzeige umleiten bzw. eigenes Hinweis-Panel | NILE, FARM, TERRA, DKFX |
| Absturz beim Spielwechsel oder Beenden (libretro) | `dlclose` direkt nach `retro_deinit`, während ein Core-Thread noch auslief | Core nach `retro_init` nicht mehr entladen | DOS |
| Absturz beim Beenden (SDL-Renderer-Spiel) | Texturen erst nach dem Renderer zerstört | Spielobjekte vor `SDL_DestroyRenderer` freigeben | GEMS |

## E. Eingabe

*Das Besteck passt nicht.* Das Essen steht auf dem Tisch, aber man kommt mit Gabel und Messer
(Controller statt Maus) nicht richtig ran.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| Karte scrollt ständig von selbst | Kanten-Scrollen der Engine – der Strahl verlässt das Fenster dauernd | Kanten-Scrollen immer abschalten | alle Strategie-Ports |
| Klick landet daneben | Zielpunkt zittert beim Drücken | Zielpunkt ~85 ms nach Triggerdruck einfrieren | alle |
| Taste „klebt“ nach Menü/Fokuswechsel | gehaltene Eingaben werden nicht gelöst | bei Fokus-/Tracking-/Handwechsel alles lösen, erst nach Loslassen wieder aktiv; Sticks erst nach Rückkehr in die Totzone wieder scharf | alle, NILE, FARM |
| Doppelklick funktioniert nicht | Klick-Handler wurde jeden Frame neu angelegt | Zustand über Frames behalten; 500 ms / 24 px | RA |
| Fenster verschiebt sich beim Scrollen | Fenster-Griff auf der Zeigerhand | Fensterverstellung auf den Griff der anderen Hand | Siedler |
| Strg-/Shift-Klick unmöglich | Modifikator-Tasten fehlen | pro Spiel belegen (OpenTTD: X = Strg, OpenRA: B = Shift) | TTD, RA |
| Knöpfe tippen Zeichen in Textfelder | X/Y/A/B erzeugen Tastendrücke | in Textfeldern nie Zeichen aus Controller-Tasten | alle |
| Tipp aus dem Tastenprofil kommt nicht an | Tastendruck zu kurz – Engines werten die Eingaben eines Updates gemeinsam aus | Haltezeit ≥ 50–80 ms, Tipps nacheinander aus einer Warteschlange | DOS, FARM |
| Win-3.x-Cursor liegt neben dem Laser | relative Maus | `mouse_input = direct` + `vmwmouse.drv` (direct ist nicht universell, siehe Rezept DOS) | DOS (Win 3.x) |
| Spielzeiger driftet langsam vom Strahl weg | relative Deltas pro Abfrage abgeschnitten, Position als float gemerkt | Deltas ganzzahlig gegen die zuletzt gesendete Position rechnen; Start-/Randabgleich | DOS, DK1, LAWN |
| Zeiger springt bei Auflösungs- oder Menüwechsel | „neu − alt“ aus zwei Pixelräumen | letzten Laserpunkt beim Größenwechsel umrechnen; Eingaben bis zum ersten neuen Frame verwerfen | DOS, ADV, DK1 |
| Spielzeiger liegt nicht unter dem Strahl (SDL-Engine) | Engine skaliert relative Mausbewegung | Maus nie relativ einspeisen, Position absolut im Spielthread setzen | DKFX |
| Spiel-Mauszeiger unsichtbar oder doppelt | Engine nutzt den System-Cursor, den Android nicht ins abgegriffene Bild zeichnet; VR-Zielpunkt und Spielpfeil gleichzeitig an | Cursor per Wrap erkennen und selbst zeichnen (bzw. Software-Cursor); Zielpunkt aus, wenn das Spiel einen Pfeil zeigt | LAWN, NILE, DIABLO, DOS |
| Taste/Maustaste hängt bei viel Eingabe | Warteschlange verwarf beim Überlauf auch Loslass-Ereignisse | nur Bewegung/Rad zusammenfassen, Tasten nie verwerfen | NILE, DOS |
| VR-Tastatur nimmt nur ein Zeichen bzw. tippt falsche Zeichen | nur `TEXT_INPUT` ohne Tastendruck gesendet; Emulator übersetzt nach Tastenposition (Y/Z, Umlaute) | je Zeichen Taste runter → Text → Taste hoch; Layout nach der Gast-Tastaturbelegung; Host-Test „jede Taste kommt an“ ◐ | TH, DOS |
| VR-Tastatur ist ab dem ersten Bild offen | SDL2 schaltet Texteingabe beim Video-Init ein | Tastatur nur auf das Engine-Ereignis „Textfeld aktiv“ öffnen | NILE |
| Dauerdruck auf ‹ ›/−/+ wiederholt viel zu schnell | Wiederholung an Bildrate gekoppelt | zeitbasiert: erste Wiederholung nach 0,45 s, dann alle 0,12 s ◐ | TH, TTD |
| Pad-Spiel reagiert auf keine Eingabe (libretro) | `retro_set_controller_port_device` nach dem Laden fehlte | Port-Gerät nach `retro_load_game` setzen | FPS, DOS |
| Tempo springt bei halbem Stickausschlag | Stick gleichzeitig analog und als Steuerkreuz gemeldet | Steuerkreuz erst ab 0,9 Ausschlag (loslassen < 0,75) | FPS |
| In einer 2D-Panel-App kommen A/B/X/Y nicht an | Horizon OS meldet 2D-Apps keine Controller als Eingabegerät | Tasten über Bildschirm-Knöpfe, Bluetooth-Gamepad/-Maus – oder eine eigene XR-App | WINLATOR |

## F. Daten und Inhalte

*Falsche Zutat erwischt.* Zucker statt Salz: Die Daten sind da, aber nicht in der Form, die die
Engine erwartet – oder eine Zutat fehlt ganz.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| App beendet sich sofort, alle Daten fehlen | komprimierte APK-Assets nur teilweise gelesen | Assets unkomprimiert packen bzw. vollständig lesen | TTD |
| Hauptmenü hängt | `liblua51.so` fehlt (`DllNotFoundException`) | native Bibliothek mit dem NDK selbst bauen, APK-Gate prüft die Exporte | RA |
| Spiel erkennt Daten nicht | Preloader kannte nur die UFO-Daten, nicht TFTD | Preloader patchen | XCOM |
| Keine Musik | Konverter trägt `.wav` statt `.mid` ein | im Vorbereitungsskript korrigieren | WC2 |
| Videos ohne Ton | `stb_vorbis` spielt Theora-Ogg ohne Ton | `vorbisfile` verwenden | WC2 |
| Keine MIDI-Musik | GOG-Fassung ohne MIDI-Dateien bzw. ohne SoundFont | Musik aus `GM.CAT` bzw. `DOSBOX.SF2` beilegen | XCOM, DOS |
| CD-Spiel startet ohne CD | CD nur über Startmenü/AUTOBOOT eingehängt | Start über `AUTOBOOT.DBP`, Image auf C: | DOS |
| Einstellungen stürzen ab | String-ID 0xFFFF | Abfrage absichern | TTD |
| Menü in Spieloptik erscheint nie | Frame-Handler vor dem Laden des Menü-Skripts gecacht | Reihenfolge der Initialisierung korrigieren | TH |
| Startfilm/Musik hängt, Engine-Thread 100 % CPU | `SDL_mixer` öffnet relative Pfade auf Android nur in den Assets | Musik/Filme immer mit absolutem Pfad laden (per Wrap, ohne Upstream-Patch) | WC2, WC1 |
| Absturz beim Start einer Zufallskarte | Engine schreibt in den Datenordner, den die App nicht beschreiben darf | Schreibziele (Zufallskarte, Caches) ins Benutzerverzeichnis umbiegen ◐ | WC2, WC1 |
| Normale Spielstände (Batteriespeicher) nach dem Beenden weg | Konsolen-Cores schreiben SRAM nicht selbst | `retro_get_memory_data` laden und atomar sichern (alle ~2 s bei Änderung, bei Pause und vor dem Entladen) ◐ | RETRO |
| Spielstand eines anderen Spiels überschrieben | Ablage nur nach Dateiname ohne System; Punkte im Ordnernamen als Endung abgeschnitten | `saves/<system>/<Spiel>`, Endung nur bei Dateien entfernen; Altdateien einmalig übernehmen | RETRO |
| Minuszeichen und ‹ › im Menü in Spielgrafik fehlen | Bitmap-Schriften der Spiele haben kein „−“ (U+2212) und oft kein ‹ › | ASCII-„-“ bzw. vorhandene Glyphen nutzen (vorbeugend) | TTD, XCOM, TH, WC2 |

## G. Leistung und Bildqualität

*Lauwarm und matschig serviert.* Es schmeckt im Prinzip, aber es ruckelt, flimmert oder ist so
klein angerichtet, dass man die Hälfte nicht erkennt.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| Nur 12–13 Bilder/s | synchroner GPU-Readback | asynchrone PBOs, Upload nur bei neuem Bild; langfristig direkt in die Swapchain | RA |
| Pixel flimmern bei Kopfbewegung | Nearest-Filter; bei 3D-Szenen Texturen ohne Mipmaps, Bitmap-Schrift, feine Shader-Muster | Sharp-Bilinear, ~1,4× Supersampling, 4× MSAA; 3D: Mipmaps, Schrift als MSDF, Kanten per `fwidth` glätten | XRShell, Siedler, FLEET, ISLAND |
| Text zu klein | Fenster vergrößert statt Renderauflösung erhöht | höhere Renderauflösung/GUI-Skalierung | Siedler, TTD |
| Unscharf, blass | RGBA8 statt sRGB-Kette; keine Compositor-Ebene | sRGB durchgängig; Bild als eigene Ebene | XRShell |
| Akku/Wärme ohne Nutzen | Spiel rendert 108 fps bei 72 Hz | an die XR-Rate takten | TH |
| Ruckeln nur im Menü | Menü wird jeden Frame bzw. bei jedem Hover komplett neu gezeichnet und hochgeladen; Statuszeile erzwingt Dauer-Redraws | Teil-Redraw, nur den geänderten Streifen hochladen, Statuszeile höchstens alle 2 s (gemessen 5,9 → 0,65 ms) | alle mit eigenem Menü, NILE, FARM |
| Absturz nach 16 Minuten | Fehler in der Wegfindung (offen) | erst mit 10-Minuten-Stabilitätstest auffindbar – als Abnahmetor einplanen | TH |
| 71,6 statt 72 fps, jedes vierte Bild doppelt | Quest 3 läuft standardmäßig mit 90 Hz | per `XR_FB_display_refresh_rate` die niedrigste Rate wählen, die ein Vielfaches der Spielrate ist (70-Hz-DOS → 72 Hz, 60 fps → 120 Hz) | FPS, DOS |
| Angeforderte Bildwiederholrate wirkt nicht, Liste leer | die Runtime meldet direkt nach Sitzungsstart 0 Raten | Rückfall auf 72/80/90/120 Hz; nur anfragen, wenn die Rate abweicht | RETRO, FPS |
| Nach Brille ab/auf wieder 90 Hz | die Runtime startet jede Session mit ihrer Standardrate | bei `SESSION_STATE_READY` und `DISPLAY_REFRESH_RATE_CHANGED` neu anfordern ◐ | FPS, DOS |
| Spieltakt driftet trotz passender Anzeigerate | Frist je Durchlauf `now() + Periode` – Aufwachverzögerungen summieren sich | feste Fristen (`next += period`); nach Pause/Rückstand neu aufsetzen, nie in Salven aufholen ◐ | FPS |
| Spiel zu schnell/langsam nach Videomoduswechsel im Spiel | Run-Loop behielt die Bildrate vom Start | Takt nach jedem `retro_run` aus `SET_SYSTEM_AV_INFO` übernehmen | FPS, DOS |
| Gleichmäßiges Ruckeln bei PAL-Spielen | 50 fps; die Quest 3 bietet keine 100 Hz | NTSC-Fassungen bevorzugen | RETRO |
| Emulator zu langsam, obwohl die GPU Luft hat | Quest bleibt ohne Anforderung auf niedriger CPU-Stufe | `xrPerfSettingsSetPerformanceLevelEXT(CPU, SUSTAINED_HIGH)` nach `xrBeginSession` | DOS |
| Ruckeln bei DOS-Emulation trotz passender Rate | Zyklen-Limit 100 % – `retro_run` p95 16 ms > 13,9 ms Budget bei 72 Hz | `dosbox_pure_cycle_limit` 0,85; vorab auf dem Gerät messen | DOS |
| 3D-Shooter wirkt verschmiert | Pixel-Art-Filter (xBR) auf perspektivischen Texturen | für 3D Sharp-Bilinear, xBR nur für 2D-Pixel-Art; Filter pro Spiel | FPS, DOS |
| Spiel läuft nur mit ~10 fps, solange das Fenster nicht zentriert ist | Spielbilder werden in diesen Zuständen nicht abgenommen → Timeout je Bild | Bilder immer abnehmen, nur ohne Session drosseln ◐ | NILE |
| Leistungszeile zeigt im Menü 0 fps | nur geänderte Bilder gezählt | Spiel-fps und XR-Rate getrennt ausgeben | XCOM |

## H. Prozess und Nachweis

*Nicht abgeschmeckt.* Das Rezept sagt „fertig“, aber probiert hat niemand – die häufigste Ursache
für Enttäuschungen beim Servieren. Erst was im Headset beobachtet wurde, gilt als gekostet.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| „Signatur ok“ war falsch | `MSYS_NO_PATHCONV` machte die Prüfung immer grün | Belege prüfen, nicht nur Exit-Codes | TTD |
| Absturz im Headset, obwohl Tests grün; jede Headset-Runde findet genau einen neuen Startfehler | Host-Tests ohne echte Engine bzw. Lade-Kette | Desktop-Prüfstand mit derselben Lade-Kette und eigener Spielkopie bis ins Spiel, vor jedem Quest-Build (fand bei TERRA drei Fehler auf einmal) | WC2, TTD, TERRA |
| Einstellungen nach Testlauf verstellt | Selbsttest überschrieb die cfg dauerhaft | Tests mit eigener Konfiguration | TTD |
| Regressionen nach Menü-Umbau | separate Menü-Ebenen, drehbarer Fenstergriff | zurückgestellt; kleine Schritte mit Rückroll-Tag | Siedler |
| Funktion „fertig“, aber nie gesehen | „gebaut“ / „installiert“ als „geprüft“ gemeldet; Autor und Prüfer sind dieselbe Instanz | Stand dreistufig führen: gebaut → installiert → im Headset beobachtet (mit Datum/Version); unabhängiger QS-Schritt prüft Behauptungen gegen Belege | alle |
| App „hängt“ ohne Absturz, Ursache unklar | ein stehender Engine-Thread hinterlässt keinen Stapel | Hänger-Wächter: kommt 3/10/30 s kein Bild, Aufrufstapel und Thread-Zustand ins Sitzungslog | WC2, NILE |
| Absturz lässt sich nachträglich nicht klären | logcat-Ringpuffer überschrieben, Test ohne USB | eigenes Sitzungslog als Datei auf der Brille (für adb lesbar) plus Leistungszeile, ab dem ersten Headset-Test | WC2, XCOM, DOS |
| Fehler in Kernoptionen, Startregeln oder Tempo fallen erst im Headset auf | Cores liefen nur in der App mit Brille | Core-Smoke-Test: echter Core + echte Daten auf der Quest ohne App, mit Eingabe-Skript und Zeitmessung | DOS, FPS |
| Hänger, bei dem die letzte Logzeile wie die Ursache aussieht | in Wahrheit Verklemmung zweier Threads | Thread-Stacks unter Last per `gdb`; Prüfläufe nie unbegrenzt warten lassen | AGES |
| Prüfsumme im CHANGELOG passt nicht zur APK | Prüfsumme stammte aus einem Build vor dem Commit | Prüfsummen nur aus einem sauberen Neubau des Commit-Stands | WC2 |
| Host-Tests scheitern sporadisch | feste Temp-Dateinamen, parallele Läufe teilen sich TEMP | Prozess-ID/Zufallssuffix, danach aufräumen | DOS |
| Änderungen verschwinden, Branch plötzlich gewechselt | mehrere Arbeitsstände im selben Ordner | jede Aufgabe in einem eigenen `git worktree`; fremde, nicht committete Änderungen nie stashen/verwerfen | DOS, alle |
| App springt dem Tester mitten im Test ins Gesicht, falscher Build | Installieren/Starten während jemand die Brille trägt | im Testblock nichts installieren oder starten; erst lokal fertig, dann den Test ankündigen | WC2, Siedler |

## I. Recht und Veröffentlichung

*Den Einkaufszettel mit der Hausadresse weitergegeben.* Wer sein Rezept teilt, gibt nur das Rezept
weiter – nicht die Zutaten aus der eigenen Speisekammer (Spieldaten) und nicht private Notizen
(Pfade, E-Mail-Adressen).

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| Persönliche Pfade/E-Mail im Repo, „push declined due to email privacy“ | Doku, Skript-Standardwerte, Commit-Autor; private Historie direkt veröffentlicht | Variablen/Platzhalter (`<XR-Ordner>`), noreply-Adresse; öffentlich nur Squash-Commits aus einem bereinigten Zweig (`publish-check` + `publish-prepare`) | alle |
| Spieldaten-Nähe im Code | aus Spieldaten erzeugte Dateien (z. B. Menü-Skins in Spieloptik) | nur Generator-Skripte veröffentlichen, nie die Ergebnisse | DOS |
| Lizenzdatei fehlt | Port-Repo ohne COPYING | Lizenz des Upstream-Projekts übernehmen | TTD, WC2, XCOM |
| Lizenzfrage OpenXR-Loader | GPL-2.0-only-Engine mit Apache-2.0-Loader | vor Weitergabe einer APK klären; Quellcode + Selbstbau ist unkritisch. GPL-2.0-oder-später und GPL-3.0 sind verträglich; nicht-kommerzielle Komponenten nur kostenlos weitergeben; Lizenztabelle (THIRD-PARTY) je Port | TTD, DOS, RETRO, FPS |
| Push ins private Arbeits-Repo landet öffentlich | Repo umbenannt; ein alter Klon nutzt den alten Namen, GitHub leitet auf das jetzt öffentliche Repo weiter | nach jeder Umbenennung alle Klone umstellen; Sichtbarkeit vor dem Push bei GitHub prüfen | RA |
| Altlasten in öffentlichen Repos (Grafiken, Namen) | Prüfung vor Veröffentlichung sieht nur den aktuellen Stand | regelmäßiger, nur lesender Watcher über Historie, Releases und Pages aller öffentlichen Repos | alle |
| Screenshot/Video verrät Privates oder löst Content-ID aus | Passthrough zeigt den Raum, Originalmusik läuft mit | Logs und Aufnahmen nie ins Repo; für Galerie/Videos Passthrough aus, Spielmusik aus | alle |
| Geklontes Fan-Repo enthält gerippte Assets | Fan-Ports bündeln oft Originaldaten | Sparse-Checkout mit Ausschlüssen (Git Bash: `MSYS_NO_PATHCONV=1`) | alle |
| Spielmarke im App-Namen | naheliegender Spielname übernommen | generischer Begriff als App-ID/Label; Spielname nur beschreibend in der Doku | DK1, DOS |

## J. Godot auf der Quest

*Fertiggericht aus der Tüte.* Godot nimmt viel ab, hat auf der Quest aber eigene Tücken.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| App läuft fehlerfrei mit 72 fps, OpenXR fokussiert, in der Brille aber kein Bild | Mobile-Renderer (Vulkan) mit Godot 4.7 + Meta-Plugin – Log ohne Fehler | `rendering_method = "gl_compatibility"` (auch `.mobile`) | ISLAND |
| App findet Daten unter `/sdcard/…` nicht | Godot sperrt `/sdcard` | `/storage/emulated/0/Android/data/<paket>/files`; von adb angelegte Ordner per `chmod -R a+rwX` freigeben | ISLAND |
| Spielfeld steht falsch im Raum, Skriptfehler je Bild | `XRCamera3D` hat kein Tracking-Flag; die Kopfpose ist anfangs nur der Szenen-Startwert | Tracking über den `XRServer`-Tracker „head“ abfragen; erst nach echter Pose platzieren | ISLAND |
| Kommandozeilen-Export kehrt nicht zurück | Godot beendet sich nach dem Export oft nicht; `--install-android-build-template` allein hängt | Template-Option nur mit `--export-debug`; Export mit Frist, Erfolg = APK neu geschrieben | ISLAND, FLEET |
| PC-Lauf/Export hängt oder zeigt OpenXR-Warnung | OpenXR startet am PC, die PC-Runtime hängt ohne Brille | PC-Läufe mit `--xr-mode off`; OpenXR nur unter Android; `startup_alert=false` | ISLAND, FLEET |

## K. .NET/Mono, FNA und MonoGame

*Fremde Küche.* .NET-Spiele bringen eine eigene Lade- und JIT-Kette mit – Fehler zeigen sich
einzeln, nacheinander, erst auf dem Gerät.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| App stirbt sofort mit `UnsatisfiedLinkError … n_onCreate` | Marshal Methods; nach inkrementellem Release-Build fehlen Symbole | `AndroidEnableMarshalMethods=false`, sauberer Neubau; APK-Gate prüft die JNI-Registrierung | FARM |
| `TypeLoadException`/`MethodAccessException` beim Start | nachgebaute Engine weicht vom Original ab (Typ-Art, Sichtbarkeit) | alle Referenzen der Spiel-DLL offline gegen die Engine prüfen (Typ-Art, Sichtbarkeit) – als Build-Abbruch | FARM, TERRA |
| `MissingMethodException`/doppelte Typen bei eingebetteten DLLs | `Assembly.Load(byte[])` lädt je Anfrage eine neue Kopie | eigener `AssemblyLoadContext.Resolving`-Handler, jede DLL genau einmal | TERRA |
| Menüs verschoben, UI-Viewport 0×0 | Spiel erkennt den Hauptthread an `!IsBackground`, der SDL-Thread gilt als Hintergrund | SDL-Thread vor `Program.Main` als Vordergrund-Thread markieren | FARM |
| `NoSuitableGraphicsDeviceException` (MonoGame unter GLES) | Desktop-GL-Aufrufe (`glPolygonMode`, `glDrawBuffer`) gibt es unter GLES 3.0 nicht | Desktop-Zweige mit `&& !GLES` absichern; alle geladenen GL-Funktionen offline gegen GLES 3.0 prüfen | FARM |
| Build-/Laufzeitfallen von .NET for Android | `*.java` im Projekt wird automatisch gebunden; Trimming entfernt per Reflection genutzte APIs; Typ-Konstruktor öffnet Socket ohne `INTERNET`; MSBuild-Knoten hängen | Java außerhalb des Projekts; `PublishTrimmed=false`; `INTERNET` ins Manifest; `-nodeReuse:false` | FARM, TERRA |

---

## Checkliste für jeden neuen Port

*Mise en place:* Was ein guter Koch vor dem ersten Handgriff bereitlegt. Diese Punkte gehören von
Anfang an in den Plan – sie mussten bisher in fast jedem Port nachgerüstet werden
(die Vorlage `recipes/_template/` enthält sie als Stufen):

1. **Gemeinsames SDK, ein adb**, `JAVA_HOME`, Gradle-Wrapper – vor dem ersten Build `kitchen check`.
2. **Erst flach, dann XR:** die App zuerst als normales Android-Fenster auf der Quest starten.
3. **Große Puffer auf den Heap**, GL-Zustand sichern, keine globalen GL-Symbole (`llvm-nm`-Prüfung im Build).
4. **Lebenszyklus testen:** Brille ab/auf, Laden < 5 s je Frame, Beenden < 10 s, Spielstand beim Beenden sichern.
5. **Kanten-Scrollen aus**, Klickstabilisierung, Eingaben bei Fokuswechsel lösen.
6. **Daten mit `kitchen push`**, Spielstände getrennt, nie deinstallieren.
7. **Vor jedem Headset-Test:** Versionsnummer prüfen, genau ein Dauer-Logger läuft, niemand sonst installiert oder startet; Stand nur mit Headset-Beleg als „geprüft“ führen.
8. **Vor der Veröffentlichung** `publish-check` und `publish-prepare`; Sichtbarkeit vor jedem Push prüfen.
9. **Erst lokal prüfen:** Desktop-Prüfstand mit echter Lade-Kette bzw. Smoke-Test auf dem Gerät vor jeder neuen Quest-Version.
10. **Diagnose einbauen:** Sitzungslog als Datei, Leistungszeile, Hänger-Wächter; ungestrippte `.so` je Version aufheben (Tombstones symbolisieren).
11. **VR-Menü-Pflichtumfang** von Anfang an: Beenden mit Bestätigung, Strahl/Zielpunkt/Spielzeiger abschaltbar, Zeiger-Versatz, Stick-Bedienung.
12. **Bildrate** an die Spielrate anpassen und bei jedem Session-Start neu anfordern.

Neue versalzene Suppen, die mehr als einen Port betreffen, gehören hierher; spielspezifische in das
jeweilige Rezept (Abschnitt „Bekannte Fallen“).
