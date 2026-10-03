# Suppe versalzen? – Häufige Fehler und ihre Lösung

Jeder Koch hat schon mal eine Suppe versalzen, den Herd nicht angekriegt oder den Braten zu früh
aus dem Ofen geholt. Beim Portieren ist das nicht anders: Die meisten Pannen passieren nicht
einmal, sondern in fast jedem Port wieder – und meistens gibt es einen bewährten Handgriff, der die
Suppe rettet.

Diese Seite ist die Sammlung dieser Handgriffe aus allen bisherigen Quest-Ports (Siedler II/RttR,
OpenRA, OpenTTD, CorsixTH, OpenXcom, Stratagus, XRShell/DOSBox Pure). Jede Zeile
ist ein Fehler, der wirklich aufgetreten ist – mit Ursache und der Lösung, die am Ende zu einer
lauffähigen Version geführt hat. Lesart wie beim Kochen: **Symptom** = was komisch schmeckt,
**Ursache** = was beim Kochen schiefging, **Lösung** = wie man es rettet (oder beim nächsten Mal
gleich richtig macht).

Spalte **Gesehen in**: Siedler = settlers2-rttr, RA = openra-redalert, TTD = openttd,
TH = themehospital-corsixth, XCOM = xcom-tftd-oxce, WC2 = warcraft2-wargus, DOS = dos-xrshell
(XRShell).

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

---

## A. Toolchain und Build

*Der Herd geht nicht an.* Bevor überhaupt gekocht wird, müssen die Küchengeräte laufen – unter
Windows war das bei fast jedem Port die erste Hürde.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| SDK „verschwindet“, andere Programme finden es nicht | Claude Desktop läuft als MSIX-Sandbox und leitet `%LOCALAPPDATA%` um | SDK in einen festen gemeinsamen Ordner (`<XR-Ordner>/_tools/android-sdk`), `ANDROID_HOME` als Benutzervariable | alle (Windows) |
| `sdkmanager` installiert falsche/keine Pakete | `sdkmanager.bat` zerlegt Paketnamen am `;` | `cmdline-tools/latest/bin/android.exe sdk install "ndk;…"` | Siedler, alle |
| Gradle bricht mit Java-Fehler ab | Java 8 liegt im PATH vor JDK 17 | `JAVA_HOME` auf JDK 17 setzen | alle (Windows) |
| Gradle 9 bricht den Build | systemweites `gradle` (Homebrew) statt Wrapper | immer `./gradlew` bzw. `gradlew.bat` | XRShell (Mac) |
| `ALooper_pollAll` nicht gefunden | mitgeliefertes SDL 2.0.22 ist zu alt für NDK ≥ 27 | eigene SDL-2.32-Submodule; im eigenen Code `ALooper_pollOnce` | WC2, XRShell |
| ExternalProject baut für armv7/API 21 | ExternalProjects erben nur `CMAKE_TOOLCHAIN_FILE` | Toolchain-Wrapper (`quest-arm64.toolchain.cmake`) | WC2 |
| CMake-Symlinks scheitern | Windows ohne Entwicklermodus | betroffene Hilfstools abschalten (`ENABLE_APP OFF`) | Siedler (bzip2) |
| Pfad wird zu `…/D:/…` | absolute Pfade an `${CMAKE_BINARY_DIR}/` angehängt | Laufwerk/Root vorher abstreifen | Siedler |
| OpenXR-Loader-Codegen scheitert | nur der Store-Platzhalter `python3` im PATH | echtes Python in den PATH | Siedler |
| Builder-Ausgabe unlesbar | Konsole in cp1252 | `PYTHONIOENCODING=utf-8` | Siedler |
| `msgfmt` fehlt | gettext nicht installiert | `winget install mlocati.GetText` | Siedler |
| Build scheitert an Pfadlänge | tiefe Checkout-Pfade unter Windows | kurzer Checkout-Pfad | Siedler |
| Host-Tools (strgen, wartool, tolua++) fehlen | werden für den Host gebraucht, nicht für Android | llvm-mingw portabel (`ucrt-x86_64`, `-static`) | TTD, WC2 |
| Jeder Commit löst 18-min-Vollbuild aus | Git-Revision als CMake-Argument | Revision nicht in Compile-Definitionen | XCOM |
| Build ist kaputt, obwohl der Code stimmt | Quellen wurden während des Builds geändert | Build nur auf ruhendem Stand; Version verwerfen | TTD (preview.7) |
| „Ausführung von Skripts ist deaktiviert“ | Windows-Ausführungsrichtlinie blockiert `.ps1` | `Kitchen.cmd` doppelklicken oder `powershell -ExecutionPolicy Bypass -File kitchen.ps1 …` | Kitchen |
| PowerShell-Skript bricht mit „Unerwartetes Token“ ab | typografische Anführungszeichen („ “ ”) in einem Text mit doppelten Anführungszeichen – PowerShell wertet sie als Anführungszeichen | in Code-Texten nur ' oder " verwenden; deutsche Anführungszeichen nur in einfachen Anführungszeichen oder in Textdateien | Kitchen |
| Umlaute in PowerShell-Ausgaben kaputt | Skript ohne BOM gespeichert, PowerShell 5.1 liest es als ANSI | `.ps1` als UTF-8 **mit** BOM speichern | Kitchen |
| Dateien „geändert“ ohne Inhaltsänderung | `autocrlf` nach `sed -i` | `git update-index --refresh`; `.gitattributes` | alle |
| Selbstbau scheitert: `libopenxr_loader.so` fehlt | Loader nicht im Repo, nur von einem anderen Port kopiert | offizielles Khronos-Paket `org.khronos.openxr:openxr_loader_for_android` (Maven Central) per Skript holen, Prüfsumme prüfen | TTD |
| GitHub-ZIP baut nicht | Submodule fehlen im ZIP | `git clone --recurse-submodules` | Siedler |

## B. Gerät, Installation, Daten

*Die Zutaten kommen nicht in den Topf.* Alles ist vorbereitet, aber auf dem Weg vom Brett in den
Topf (vom PC auf die Quest) geht etwas verloren oder landet im falschen Topf.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| adb trennt ständig, „server killed“ | zwei adb-Versionen beenden sich gegenseitig den Server – oft SideQuest, das ein eigenes adb mitbringt | genau **ein** adb für alle Projekte; SideQuest schließen oder dort dasselbe adb einstellen | alle |
| `adb push` eines Ordners bricht ab | Windows-adb 37 | Ordner als **eine** tar-Datei übertragen, auf dem Gerät entpacken (`kitchen push`) | DOS, WC2 |
| `/sdcard/…` wird zu `C:/Program Files/Git/sdcard` | Git Bash schreibt Pfade um | `MSYS_NO_PATHCONV=1` für adb – aber **nicht** für gradlew (bricht dort) | alle |
| App kann übertragene Daten nicht lesen | von adb angelegte Ordner gehören dem Nutzer `shell` | Rechte setzen (`chmod`), macht `kitchen push` | DOS |
| Schreiben nach `Android/data/<app>` klappt nicht zuverlässig | Horizon OS schränkt adb dort ein | in den App-Speicher per `run-as` (nur Debug-APK) oder eigener Ordner mit „Alle Dateien“ | TH, XCOM |
| `install -r` scheitert mit Signaturfehler | jeder Rechner hat einen eigenen Debug-Schlüssel | **nicht** deinstallieren (löscht Spielstände) – erst Spielstände sichern; gemeinsamen Debug-Schlüssel verwenden | Siedler, TH |
| Testergebnis ergibt keinen Sinn | versehentlich ein alter oder anderer Build installiert | vor jedem Test `versionName` prüfen (`dumpsys package`) | Siedler |
| App startet nicht, Systemdialog erscheint | Horizon OS fängt den Start ab (Brille schläft, Controller-Update) | Brille wecken, Controller aktualisieren; Start nicht blind wiederholen | RA, TTD |
| Test ohne Brille bleibt hängen | Brille im Ruhezustand, Guardian/Systemdialoge | `adb shell am broadcast -a com.oculus.vrpowermanager.prox_close` | XCOM, TTD |
| „App-Name nicht verfügbar“ in der Systemleiste | Horizon-OS-Eigenheit | aus der App nicht zu verhindern – ignorieren | Siedler, RA |
| Falsches Spiel startet | XRShell nimmt eine Datei in `game/` vor dem alphabetisch ersten Ordner | Ordner benennen (`1-…`), keine losen Dateien | DOS |

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

## D. Lebenszyklus, ANR, Beenden

*Die Suppe kocht über.* Kurz weggeschaut (Brille abgesetzt), zu lange auf dem Herd gelassen (Laden)
oder den Topf falsch vom Feuer genommen (Beenden) – und schon ist die Sauerei da.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| ANR nach Brille ab/auf | GLSurfaceView gibt den EGL-Kontext frei, Neuaufbau dauert ~9 s | `PreserveEGLContextOnPause = true`; Gegentest per Standby + Aufwecken | RA |
| ANR beim Laden | lange Schritte (> 5 s) auf dem GL-/UI-Thread | Laden in Etappen pro Frame (z. B. 10 Karten je Frame), Ladeanzeige sofort | RA |
| Spiel friert bei Fokusverlust ein | SDL 2.0.9 hält den Spiel-Thread an; Horizon OS meldet Fokusverlust oft | Fokusverlust ignorieren bzw. nur pausieren | XCOM |
| Spiel hängt nach Rückkehr | Fokus-Events + `PauseOnLeave` der Engine | Fokus-Events verwerfen, `PauseOnLeave=false` | WC2 |
| Beenden dauert 10 s oder zeigt Dialog | Engine kennt nur `SDL_QUIT` | Event-Filter, bei `SDL_APP_TERMINATING` sofort beenden (`_exit`) | WC2 |
| Spielstand weg nach Beenden über das Quest-Menü | Beenden ohne Speichern | beim Beenden-Ereignis speichern | TTD |
| Spielstände nach Neuinstallation weg | Spielstände lagen im Spielordner bzw. App wurde deinstalliert | Spielstände getrennt ablegen (`saves/`), nie deinstallieren | DOS, TH |
| Zweiter Start verhält sich anders | Android hält den Prozess nach „Beenden“ am Leben | Engine-Init idempotent machen | RA |
| Nach Absturz fehlen Umgebungsvariablen | Android startet die Activity im frischen Prozess neu | Variablen (`HOME`, `XDG_CONFIG_HOME`, `USER`) in der Activity setzen | TH |
| Engine hängt beim Start | Arbeitsverzeichnis ist `/` | vor dem Engine-Start `chdir` in den Datenordner | TH |
| Absturz in der Konfiguration | Umgebungsvariable `USER` fehlt | `USER` setzen | TH |
| Wirkt wie ein Freeze, ist aber ein Absturz | letzter Frame bleibt stehen | bei Ausnahme ein deutliches Fehlerbild aufs Quad legen | RA, Siedler |

## E. Eingabe

*Das Besteck passt nicht.* Das Essen steht auf dem Tisch, aber man kommt mit Gabel und Messer
(Controller statt Maus) nicht richtig ran.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| Karte scrollt ständig von selbst | Kanten-Scrollen der Engine – der Strahl verlässt das Fenster dauernd | Kanten-Scrollen immer abschalten | alle Strategie-Ports |
| Klick landet daneben | Zielpunkt zittert beim Drücken | Zielpunkt ~85 ms nach Triggerdruck einfrieren | alle |
| Taste „klebt“ nach Menü/Fokuswechsel | gehaltene Eingaben werden nicht gelöst | bei Fokus-/Tracking-/Handwechsel alles lösen, erst nach Loslassen wieder aktiv | alle |
| Doppelklick funktioniert nicht | Klick-Handler wurde jeden Frame neu angelegt | Zustand über Frames behalten; 500 ms / 24 px | RA |
| Fenster verschiebt sich beim Scrollen | Fenster-Griff auf der Zeigerhand | Fensterverstellung auf den Griff der anderen Hand | Siedler |
| Strg-/Shift-Klick unmöglich | Modifikator-Tasten fehlen | pro Spiel belegen (OpenTTD: X = Strg, OpenRA: B = Shift) | TTD, RA |
| Knöpfe tippen Zeichen in Textfelder | X/Y/A/B erzeugen Tastendrücke | in Textfeldern nie Zeichen aus Controller-Tasten | alle |
| Tipp aus dem Tastenprofil kommt nicht an | Tastendruck zu kurz | Haltezeit ≥ 50 ms | DOS |
| Win-3.x-Cursor liegt neben dem Laser | relative Maus | `mouse_input = direct` + `vmwmouse.drv` | DOS (Win 3.x) |

## F. Daten und Inhalte

*Falsche Zutat erwischt.* Zucker statt Salz: Die Daten sind da, aber nicht in der Form, die die
Engine erwartet – oder eine Zutat fehlt ganz.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| App beendet sich sofort, alle Daten fehlen | komprimierte APK-Assets nur teilweise gelesen | Assets unkomprimiert packen bzw. vollständig lesen | TTD |
| Hauptmenü hängt | `liblua51.so` fehlt (`DllNotFoundException`) | native Bibliothek mitbauen und mitliefern | RA |
| Spiel erkennt Daten nicht | Preloader kannte nur die UFO-Daten, nicht TFTD | Preloader patchen | XCOM |
| Keine Musik | Konverter trägt `.wav` statt `.mid` ein | im Vorbereitungsskript korrigieren | WC2 |
| Videos ohne Ton | `stb_vorbis` spielt Theora-Ogg ohne Ton | `vorbisfile` verwenden | WC2 |
| Keine MIDI-Musik | GOG-Fassung ohne MIDI-Dateien bzw. ohne SoundFont | Musik aus `GM.CAT` bzw. `DOSBOX.SF2` beilegen | XCOM, DOS |
| CD-Spiel startet ohne CD | CD nur über Startmenü/AUTOBOOT eingehängt | Start über `AUTOBOOT.DBP`, Image auf C: | DOS |
| Einstellungen stürzen ab | String-ID 0xFFFF | Abfrage absichern | TTD |
| Menü in Spieloptik erscheint nie | Frame-Handler vor dem Laden des Menü-Skripts gecacht | Reihenfolge der Initialisierung korrigieren | TH |

## G. Leistung und Bildqualität

*Lauwarm und matschig serviert.* Es schmeckt im Prinzip, aber es ruckelt, flimmert oder ist so
klein angerichtet, dass man die Hälfte nicht erkennt.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| Nur 12–13 Bilder/s | synchroner GPU-Readback | asynchrone PBOs, Upload nur bei neuem Bild; langfristig direkt in die Swapchain | RA |
| Pixel flimmern bei Kopfbewegung | Nearest-Filter | Sharp-Bilinear, ~1,4× Supersampling, 4× MSAA | XRShell, Siedler |
| Text zu klein | Fenster vergrößert statt Renderauflösung erhöht | höhere Renderauflösung/GUI-Skalierung | Siedler, TTD |
| Unscharf, blass | RGBA8 statt sRGB-Kette; keine Compositor-Ebene | sRGB durchgängig; Bild als eigene Ebene | XRShell |
| Akku/Wärme ohne Nutzen | Spiel rendert 108 fps bei 72 Hz | an die XR-Rate takten | TH |
| Ruckeln nur im Menü | Menü wird jeden Frame komplett neu gezeichnet | Teil-Redraw (Skill `xr-vr-menu`) | alle mit eigenem Menü |
| Absturz nach 16 Minuten | Fehler in der Wegfindung (offen) | erst mit 10-Minuten-Stabilitätstest auffindbar – als Abnahmetor einplanen | TH |

## H. Prozess und Nachweis

*Nicht abgeschmeckt.* Das Rezept sagt „fertig“, aber probiert hat niemand – die häufigste Ursache
für Enttäuschungen beim Servieren. Erst was im Headset beobachtet wurde, gilt als gekostet.

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| „Signatur ok“ war falsch | `MSYS_NO_PATHCONV` machte die Prüfung immer grün | Belege prüfen, nicht nur Exit-Codes | TTD |
| Absturz im Headset, obwohl Tests grün | Host-Tests linkten die Engine nicht mit | einen Test, der die echte Bibliothek lädt | WC2 |
| Einstellungen nach Testlauf verstellt | Selbsttest überschrieb die cfg dauerhaft | Tests mit eigener Konfiguration | TTD |
| Regressionen nach Menü-Umbau | separate Menü-Ebenen, drehbarer Fenstergriff | zurückgestellt; kleine Schritte mit Rückroll-Tag | Siedler |
| Funktion „fertig“, aber nie gesehen | „gebaut“ / „installiert“ als „geprüft“ gemeldet | Stand dreistufig führen: gebaut → installiert → im Headset beobachtet (mit Datum/Version) | alle |

## I. Recht und Veröffentlichung

*Den Einkaufszettel mit der Hausadresse weitergegeben.* Wer sein Rezept teilt, gibt nur das Rezept
weiter – nicht die Zutaten aus der eigenen Speisekammer (Spieldaten) und nicht private Notizen
(Pfade, E-Mail-Adressen).

| Symptom | Ursache | Lösung | Gesehen in |
|---|---|---|---|
| Persönliche Pfade/E-Mail im Repo | Doku, Skript-Standardwerte, Commit-Autor | Variablen/Platzhalter (`<XR-Ordner>`), noreply-Adresse; vor Veröffentlichung `publish-check` + `publish-prepare` | alle |
| Spieldaten-Nähe im Code | aus Spieldaten erzeugte Dateien (z. B. Menü-Skins in Spieloptik) | nur Generator-Skripte veröffentlichen, nie die Ergebnisse | DOS |
| Lizenzdatei fehlt | Port-Repo ohne COPYING | Lizenz des Upstream-Projekts übernehmen | TTD, WC2, XCOM |
| Lizenzfrage OpenXR-Loader | GPL-2.0-only-Engine mit Apache-2.0-Loader | vor Weitergabe einer APK klären; Quellcode + Selbstbau ist unkritisch | TTD |

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
7. **Versionsnummer vor jedem Test prüfen**; Stand nur mit Headset-Beleg als „geprüft“ führen.
8. **Vor der Veröffentlichung** `publish-check` und `publish-prepare`.

Neue versalzene Suppen, die mehr als einen Port betreffen, gehören hierher; spielspezifische in das
jeweilige Rezept (Abschnitt „Bekannte Fallen“).
