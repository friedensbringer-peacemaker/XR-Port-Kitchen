# Selbst portieren: <Spiel> auf die Meta Quest

Für alle, die den Port nachbauen, verstehen oder auf ein anderes Spiel übertragen wollen.
Wer nur spielen will: [RECIPE.md](RECIPE.md). Vorbild: [OpenTTD](../openttd/PORTING.md).

> **Ausgangsstand:** <Engine> <Version> (`<upstream-commit>`). **Port-Stand:** `<engine-repo>`
> Zweig `<zweig>`, Commit [`<kurz>`](<permalink-commit>).
> **Gesamter Eingriff:** [Vergleich <Version> → XR-Port](<compare-link>) (<n> Dateien, ~<m> Zeilen).
>
> Code-Ausschnitte stehen unter der Lizenz der Engine (<Lizenz>); maßgeblich ist die verlinkte Datei.
> Nur **eigenen** Port-Code zitieren, Engine-Code verlinken statt kopieren.

## Die Idee in einem Satz

<Wie kommt das Spielbild in OpenXR, wie wird der Controller zur Eingabe?> + kleines Ablaufbild.

## Warum gerade so

<Welche Schnittstelle der Engine nutzt der Port, warum ist das der kleinste Eingriff?>

## Eingriffspunkte

| # | Datei (Permalink mit Zeile) | Was dort passiert | neu/geändert |
|---|---|---|---|

Android-Rahmen im Port-Repo (Manifest, Activity, Gradle, Loader-Skript):

| Datei | Was dort passiert |
|---|---|

## Schritt für Schritt

Je Schritt: **Ziel** · was eingebaut wird (kurzer Ausschnitt) · **Fallen** · **Fertig, wenn** (prüfbar).
Übliche Reihenfolge: 1 Android-Build startet · 2 Daten und Pfade · 3 Bild in den Raum ·
4 Controller als Eingabe · 5 VR-Menü (Pflichtumfang) · 6 Lebenszyklus.

## Prüfen ohne Headset

| Werkzeug | Was es zeigt |
|---|---|

## Übertragen auf andere Spiele

Für welche Engines passt dieser Weg, wo nicht? Verweis auf die Tabelle in
[OpenTTD/PORTING.md](../openttd/PORTING.md#übertragen-auf-andere-spiele).
