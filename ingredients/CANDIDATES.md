# Kandidaten für gemeinsame Bausteine

Diese Liste sammelt Lösungen, die in mehreren Ports getrennt entstanden sind. Kommt ein Muster
in zwei oder mehr Rezepten vor, wird es ein Modul in `xr-common`, ein Skript-Baustein oder ein
Skill. Danach wandert der Eintrag nach `ingredients/README.md`.

| # | Muster | Vorkommen | Vorschlag | Stand |
|---|---|---|---|---|
| K1 | Eigenes VR-Menü-Modell, „nach Spezifikation `xrc/menu.h`“ nachgebaut | settlers2-rttr (`VrMenuModel.h`), openra-redalert (eigene Logik), XRShell | `xrc/menu.h` wirklich einbinden | offen |
| K2 | Strahl-, Brett- und Pointer-Geometrie je Port neu geschrieben | openra (`BoardGeometry.h`, `BeamGeometry.h`, `PointerTransitions.h`), settlers (`PanelGeometry`) | gegen `xrc` Panel-Geometrie tauschen (Skill `xr-common-lib`, Abschnitt Migration) | offen |
| K3 | ANR durch langes Laden auf dem GL-Thread bzw. durch Lebenszyklus nach Brille ab/auf | openra (Laden in Etappen, PreserveEGLContextOnPause), settlers | Checkliste „Lebenszyklus“ als Stufe in jedem Rezept | offen |
| K4 | Ordner-Push per adb bricht unter Windows ab, Workaround mit tar + run-as/chmod | dos-xrshell (`push-game.sh`), openra (`import-ra-content.sh`), settlers (`quest.py import-data`) | ein gemeinsames `push-data`-Skript in der Kitchen | ✅ `kitchen push` (0.2); Port-Skripte können umgestellt werden |
| K5 | Ein-Klick-Build (`Quest-Build.cmd` / `.command`) mit Werkzeug-Selbstinstallation | openra (`setup-toolchains.sh`), settlers (`build-quest.py --check`) | Prüfteil durch `kitchen check` ersetzen, Installationsteil vereinheitlichen | offen |
| K6 | Systemdialog „App-Name nicht verfügbar“ | settlers, openra | einmal untersuchen und im Skill `xr-openxr-integration` dokumentieren | offen |
| K8 | adb schreibt auf Horizon OS nicht zuverlässig nach `Android/data/<app>` | themehospital (deshalb `run-as`), dos-xrshell und warcraft2 schreiben trotzdem dorthin, openxcom weicht auf `/sdcard/openxcom` + „Alle Dateien“ aus | an der echten Quest klären; falls bestätigt: `run-as` als Standard in `kitchen push`, Rezepte umstellen | offen |
| K9 | Eigene Kopie von `xrc/menu.h` statt Einbindung | themehospital (`xrc_menu.h`), openxcom (`XrMenuLogic.h`, TODO), warcraft2 (`xr_menu_model.h`), openttd (aus Siedler kopiert) | getaggte xr-common-Version, dann alle umstellen (gehört zu K1) | offen |
| K10 | Fokusverlust friert/pausiert das Spiel (Horizon OS meldet ihn oft) | openxcom (SDL 2.0.9), warcraft2 (PauseOnLeave) | Hinweis im Skill `xr-openxr-integration` + Stufe „Lebenszyklus“ (K3) | offen |
| K7 | Versionsnamen vor jedem Test prüfen (falsche APK installiert) | settlers, alle | `kitchen` um `installed <rezept>` erweitern (`adb shell dumpsys package`) | offen |
