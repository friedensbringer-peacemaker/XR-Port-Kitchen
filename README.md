# XR-Port-Kitchen

Ein Kochbuch, mit dem man klassische PC- und Konsolenspiele auf die Meta Quest bringt: Menschen
können darin nachschlagen, Agenten können die Rezepte Schritt für Schritt abarbeiten.

> Wir kochen nicht für euch – wir schreiben die Rezepte auf, damit ihr selbst kochen könnt.
> Die Grundzutaten kommen von den Meisterköchen der Open-Source-Reimplementierungen; wir liefern
> den letzten Handgriff vom fertigen Topf bis auf den Teller: das Spiel, das kabellos auf der Quest
> läuft. Und auf jeder Speisekarte steht, aus wessen Küche die Zutaten stammen – mit der
> Sichtbarkeit und dem Respekt, den diese Projekte verdienen.

Die Kitchen tritt nicht gegen Fanprojekte an – ohne sie gäbe es keinen einzigen Port. Jedes Rezept
nennt das Upstream-Projekt, seine Lizenz und seine Mitwirkenden an erster Stelle.

<details>
<summary><b>Die Meisterköche, die uns inspirieren</b> – die Fanprojekte hinter den Rezepten und Ports</summary>

| Projekt | Für | Website | Quellcode |
|---|---|---|---|
| Return to the Roots | Die Siedler II | [rttr.info](https://www.rttr.info) | [GitHub](https://github.com/Return-To-The-Roots/s25client) |
| Generals: Zero Hour XR (Cesarus85) – **Inspiration für die Kitchen** | C&C Generals, Zero Hour | – | [GitHub](https://github.com/Cesarus85/Generals-Zero-Hour-XR), Engine: [TheSuperHackers](https://github.com/TheSuperHackers/GeneralsGameCode) |
| Port Royale (SgtBilko76) – **Inspiration für die Kitchen** | rund 30 Klassiker als Quest-VR-Ports | [portroyale.online](https://portroyale.online) | [GitHub](https://github.com/SgtBilko76?tab=repositories) |
| OpenRA | Command & Conquer, Alarmstufe Rot | [openra.net](https://www.openra.net) | [GitHub](https://github.com/OpenRA/OpenRA) |
| OpenTTD | Transport Tycoon Deluxe | [openttd.org](https://www.openttd.org) | [GitHub](https://github.com/OpenTTD/OpenTTD) |
| CorsixTH | Theme Hospital | [corsixth.com](https://corsixth.com) | [GitHub](https://github.com/CorsixTH/CorsixTH) |
| OpenXcom / OpenXcom Extended | X-COM UFO Defense, Terror from the Deep | [openxcom.org](https://openxcom.org) | [GitHub](https://github.com/OpenXcom/OpenXcom), [OXCE](https://github.com/MeridianOXC/OpenXcom), [Android](https://github.com/MeridianOXC/openxcom-android) |
| Stratagus mit Wargus/War1gus | Warcraft I und II | [stratagus.com](http://stratagus.com) | [Stratagus](https://github.com/Wargus/stratagus), [Wargus](https://github.com/Wargus/wargus), [War1gus](https://github.com/wargus/war1gus) |
| ScummVM | Point-&-Click-Adventures | [scummvm.org](https://www.scummvm.org) | [GitHub](https://github.com/scummvm/scummvm) |
| DOSBox Pure / libretro | DOS-Spiele, Emulator-Cores | [libretro.com](https://www.libretro.com) | [DOSBox Pure](https://github.com/schellingb/dosbox-pure), [libretro](https://github.com/libretro) |
| openage | Age of Empires II | [openage.sft.mx](https://openage.sft.mx) | [GitHub](https://github.com/SFTtech/openage) |
| 0 A.D. | eigenständiges Echtzeit-Strategiespiel | [play0ad.com](https://play0ad.com) | [GitHub-Spiegel](https://github.com/0ad/0ad) |
| KeeperFX | Dungeon Keeper | – | [GitHub](https://github.com/dkfans/keeperfx) |
| DevilutionX | Diablo, Hellfire | [devilutionx.com](https://devilutionx.com) | [GitHub](https://github.com/diasurgical/DevilutionX) |
| JA2 Stracciatella | Jagged Alliance 2 | [Website](https://ja2-stracciatella.github.io) | [GitHub](https://github.com/ja2-stracciatella/ja2-stracciatella) |
| Akhenaten | Pharao, Kleopatra | – | [GitHub](https://github.com/dalerank/Akhenaten) |
| fheroes2 | Heroes of Might & Magic II | – | [GitHub](https://github.com/ihhub/fheroes2) |
| FNA | XNA-Spiele (.NET) | [fna-xna.github.io](https://fna-xna.github.io) | [GitHub](https://github.com/FNA-XNA/FNA) |
| SDL | Grundlage fast aller Ports | [libsdl.org](https://www.libsdl.org) | [GitHub](https://github.com/libsdl-org/SDL) |
| OpenXR (Khronos) | VR-Schnittstelle aller Ports | [khronos.org/openxr](https://www.khronos.org/openxr/) | [GitHub](https://github.com/KhronosGroup/OpenXR-SDK-Source) |

**Weitere Kandidaten** aus dem Engine-Inventar: [OpenRCT2](https://openrct2.io)
([GitHub](https://github.com/OpenRCT2/OpenRCT2)) für RollerCoaster Tycoon 1/2,
[OpenLoco](https://openloco.io) ([GitHub](https://github.com/OpenLoco/OpenLoco)) für Locomotion,
[Widelands](https://www.widelands.org) ([GitHub](https://github.com/widelands/widelands)),
[Julius](https://github.com/bvschaik/julius) und [Augustus](https://github.com/Keriew/augustus) für
Caesar III, [openblack](https://github.com/openblack/openblack) für Black & White,
[OpenKeeper](https://github.com/tonihele/OpenKeeper) für Dungeon Keeper 2.

**Die ausführliche Liste:** Der [Katalog](catalog/README.md) führt rund 1.850 Open-Source-Engines,
Source-Ports, Dekompilierungen und schon vorhandene VR-Ports mit Lizenz, Stand und Link –
aufgeteilt in [Engines](catalog/ENGINES.md), [Source-Ports](catalog/SOURCE-PORTS.md) und
[VR-Ports](catalog/VR-PORTS.md). Eine weitere große Sammlung ist
[osgameclones.com](https://osgameclones.com) ([GitHub](https://github.com/opengaming/osgameclones)).
</details>

### Worum es hier geht – und worum nicht

Die Kitchen ist ein **Community- und Hobbyprojekt**: in der Freizeit entstanden, per
*Vibe Coding* gemeinsam mit KI-Assistenten entwickelt, aus Begeisterung für klassische Spiele und
für das, was die Quest heute kann.

**Den Anstoß gab [Generals: Zero Hour XR](https://github.com/Cesarus85/Generals-Zero-Hour-XR)** von
Cesarus85: Command & Conquer Generals samt Zero Hour als Miniatur-Schlachtfeld auf dem Tisch,
nativ auf der Quest, aufgebaut auf dem offenen Engine-Code der
[TheSuperHackers](https://github.com/TheSuperHackers/GeneralsGameCode)-Community. Zu sehen, wie gut
ein Klassiker so auf der Brille funktioniert, war die Inspiration für diese Kitchen. Genauso
inspiriert hat uns **[Port Royale](https://portroyale.online)** von SgtBilko76
([Repositories](https://github.com/SgtBilko76?tab=repositories)): eine ganze Sammlung kostenloser
Open-Source-VR-Ports, die zeigt, wie viele Klassiker standalone auf der Quest Platz haben.

Ziel ist **nicht**, jedes Spiel zu einem vollwertigen VR-Spiel umzubauen, das alle räumlichen
Möglichkeiten ausreizt – auch wenn das mittelfristig natürlich ebenfalls sehr spannend wäre. Erste
Rezepte probieren schon aus, die Karte als Tisch in den Raum zu stellen. Für das volle VR-Erlebnis
gibt es aber längst großartige Fan- und Community-Projekte, die wir ausdrücklich empfehlen – wer ein
Spiel voll räumlich erleben will, ist dort besser aufgehoben:

- **[Team Beef](https://www.teambeefvr.com)** ([GitHub](https://github.com/Team-Beef-Studios)) – native, kabellose Quest-VR-Umsetzungen von Klassikern
  wie Doom, Quake, Half-Life oder Return to Castle Wolfenstein, kostenlos über SideQuest (mit den
  eigenen Spieldaten, Quellcode auf GitHub). Alle bekannten VR-Ports: [Katalog VR-Ports](catalog/VR-PORTS.md).
- **[Port Royale](https://portroyale.online)** ([GitHub](https://github.com/SgtBilko76)) – rund
  30 kostenlose Open-Source-VR-Ports, die direkt auf der Quest (teils auch Pico) laufen: Unreal
  Tournament, Descent 3, SuperTuxKart, Visual Pinball, Spiele als stereoskopisches 3D-Diorama,
  Emulatoren in echtem Stereo-3D und PC-Spiele mit VR-Mod über
  [WinlatorXR](https://github.com/WinlatorXR). Am nächsten an unserer Idee – nur mit dem Schwerpunkt
  auf echter Räumlichkeit statt auf Maus-Klassikern auf der Leinwand.
- **[UEVR](https://github.com/praydog/UEVR)** – macht viele Unreal-Engine-Spiele am PC VR-fähig.
- **[Nexus Mods](https://www.nexusmods.com)** und GitHub – VR-Mods für zahlreiche PC-Spiele, etwa für
  Cyberpunk 2077 oder Red Dead Redemption 2 (am PC, per Kabel oder Streaming auf die Quest).
- Manche Spiele bringen VR inzwischen selbst mit.

Die Kitchen ergänzt diese Projekte, statt mit ihnen zu konkurrieren.

Hier geht es um die **kleinen Nischen**: liebgewonnene Klassiker der 80er, 90er und 2000er, die die
Quest-Hardware **nativ und kabellos** stemmt – ohne Streaming per Kabel oder Steam Link, ohne
separaten PC, ohne High-End-Grafikkarte. Brille auf, Spiel starten, fertig.

<details>
<summary><b>About this project (English)</b></summary>

The kitchen is a **community hobby project**, built in spare time with *vibe coding* alongside AI
assistants, out of enthusiasm for classic games and for what the Quest can do today. It was inspired by
[Generals: Zero Hour XR](https://github.com/Cesarus85/Generals-Zero-Hour-XR) by Cesarus85, which brings
C&C Generals and Zero Hour natively to the Quest as a tabletop battlefield. Equally inspiring was
[Port Royale](https://portroyale.online) by SgtBilko76 ([repositories](https://github.com/SgtBilko76?tab=repositories)),
a whole collection of free open-source standalone VR ports. It does
**not** aim to turn every game into a full room-scale VR experience (although that is an exciting
goal for later, and first recipes are already experimenting with a tabletop view) – great fan projects already do
that and we recommend them: [Team Beef](https://www.teambeefvr.com) (native Quest VR versions of Doom,
Quake, Half-Life and more via SideQuest), [Port Royale](https://portroyale.online) (about 30 free
open-source standalone VR ports – shooters, racers, stereoscopic dioramas, stereo-3D emulators and
WinlatorXR VR mods; closest to our idea, but focused on true 3D rather than mouse-driven classics), [UEVR](https://github.com/praydog/UEVR) for Unreal Engine
games on PC, and VR mods on [Nexus Mods](https://www.nexusmods.com) and GitHub for games such as
Cyberpunk 2077 or Red Dead Redemption 2; some games now ship VR natively.
Instead it focuses on the **small niches**: beloved classics from the 80s, 90s and 2000s that run
**natively and wirelessly** on the Quest hardware – no link cable or Steam Link, no separate PC,
no high-end graphics card.
</details>

## Schnellstart

### Das brauchst du

| | Was | Hinweis |
|---|---|---|
| 🥽 | **Meta Quest** (2, 3, 3S oder Pro) | mit eingeschaltetem **Entwicklermodus** (einmalig, [Anleitung](#entwicklermodus)) |
| 🔌 | **USB-C-Kabel** | das Ladekabel der Quest reicht, wenn es Daten überträgt |
| 💻 | **Windows-PC oder Mac** | nichts installieren nötig – die Küchenhilfe prüft alles und hilft beim Rest |
| 💾 | **Dein Originalspiel** | eigene Kopie von GOG, Steam oder CD (bei manchen Spielen nicht nötig, siehe [Rezepte](#rezepte)) |
| 📦 | **Die Spiel-App (APK)** | baust du dir selbst – das Rezept und die Küchenhilfe führen dich durch ([In vier Schritten](#in-vier-schritten)) |
| 🔧 | **adb** (Android Debug Bridge) | kleines Hilfsprogramm von Google für die USB-Verbindung zur Quest – **nicht selbst installieren nötig**: Fehlt es, lädt die Küchenhilfe es nach Rückfrage direkt von Google in den Kitchen-Ordner (siehe [Was ist adb?](#was-ist-adb)) |
| 🧰 | *SideQuest (optional)* | **nicht nötig** – die Küchenhilfe erledigt Installieren und Kopieren selbst; wer SideQuest mag, kann es zusätzlich nutzen ([Brauche ich SideQuest?](#brauche-ich-sidequest)) |

**Warum es keine fertigen Spiel-Apps zum Herunterladen gibt:** Die Ports bauen auf
Open-Source-Projekten mit unterschiedlichen Lizenzen auf, und manche Spiele brauchen bei der
Einrichtung deine eigenen Originaldaten. Eine fertige App weiterzugeben ist deshalb rechtlich
heikel. Stattdessen baut sich jeder seine App selbst aus den offenen Quellen und seinem eigenen
Spiel – für sich, auf dem eigenen Rechner. Das klingt aufwendiger, als es ist: Die Rezepte
beschreiben jeden Schritt, und die Küchenhilfe prüft die Werkzeuge, holt Fehlendes nach Rückfrage
und bringt am Ende App und Spieldaten auf die Quest.

### In vier Schritten

1. **Kitchen herunterladen:** [**Download ZIP**](https://github.com/friedensbringer-peacemaker/XR-Port-Kitchen/archive/refs/heads/main.zip) (oder oben auf
   dieser Seite **Code → Download ZIP**) und den ZIP-Ordner entpacken. Für Bastler:
   `git clone https://github.com/friedensbringer-peacemaker/XR-Port-Kitchen.git`
2. **Starten:**
   - **Windows:** im entpackten Ordner **[`Kitchen.cmd`](Kitchen.cmd)** doppelklicken.
   - **Mac:** **[`Kitchen.command`](Kitchen.command)** mit Rechtsklick → *Öffnen* starten (beim ersten Mal fragt macOS
     nach). Klappt das nicht: Terminal öffnen, `sh ` tippen, die Datei ins Fenster ziehen, Enter.
3. **Spiele ankreuzen:** Sprache wählen, dann im Menü die gewünschten Spiele mit **X** ankreuzen
   (eins oder mehrere, Übersicht unter [Rezepte](#rezepte)) und **Enter** drücken.
4. **Dem Assistenten folgen:** Er fragt nach deinem Spielordner, prüft alles, verbindet die Quest,
   baut auf Wunsch die App aus dem öffentlichen Port-Code, installiert sie und überträgt die Spieldaten. Am Ende steht, wo du das Spiel in der Brille findest.
   Klemmt etwas: [Suppe versalzen?](docs/HAEUFIGE-FEHLER.md)

**Lieber mit deinem KI-Agenten?** Claude Code, Codex, Gemini CLI & Co. können die Schritte für dich
erledigen: In [AGENT-START.md](AGENT-START.md) steht ein fertiger Startprompt (Deutsch/Englisch) zum
Kopieren – Spiel und Ordner eintragen, an den Agenten geben, Schritte freigeben.

**Was die Küchenhilfe nachladen kann – immer erst nach deiner Zustimmung:** keine fertigen Spiele,
sondern alles, was du brauchst, um dein Spiel so schnell wie möglich selbst zu portieren: das
Android-Werkzeug `adb` (direkt von Google, nur in den Kitchen-Ordner), den öffentlichen Port-Code
eines Rezepts zum Selbstbauen (von GitHub, neben den Kitchen-Ordner) und neue oder verbesserte
Rezepte samt Küchenhilfe (Taste `U` im Menü, von GitHub). Deine Spieldaten und deine selbst gebaute
App verlassen nie deinen Rechner – sie gehen nur per USB auf deine Quest.

<a id="brauche-ich-sidequest"></a>
**Brauche ich SideQuest?** Nein. [SideQuest](https://sidequestvr.com) ist ein beliebtes Programm mit
Knöpfen, um Apps auf die Quest zu spielen – es benutzt dafür im Hintergrund ebenfalls adb. Die
Küchenhilfe macht dasselbe direkt: App installieren, Spieldaten kopieren, Verbindung prüfen. Wer
SideQuest trotzdem gern nutzt (zum Beispiel, um auf der Brille nach Dateien zu schauen), kann es
**zusätzlich** verwenden. Einzige Falle: SideQuest bringt sein eigenes adb mit, und zwei verschiedene
adb-Programme werfen sich gegenseitig die Verbindung weg. Deshalb **SideQuest schließen, während die
Küchenhilfe arbeitet** – oder in SideQuest unter den Einstellungen dasselbe adb eintragen, das die
Küchenhilfe benutzt (zeigt `D` im Menü an).

### Kleines Wörterbuch – auch ohne Programmierkenntnisse

**Was ist eine APK?**
Eine APK ist eine **App-Datei**, so wie ein Installationsprogramm auf dem PC. Die Meta Quest läuft
intern mit Android (dem System, das auch viele Handys nutzen), und Android-Apps werden als Datei mit
der Endung `.apk` verpackt. Normalerweise holt man Apps aus dem Meta-Store; eine APK kann man aber
auch selbst auf die Brille legen – das nennt man **„Sideloading“**. Genau das machen wir hier: Du
baust dir die App für dein Spiel und spielst sie selbst auf deine Quest.

<a id="was-ist-adb"></a>
**Was ist adb?**
adb (*Android Debug Bridge*) ist ein **kleines Hilfsprogramm von Google, das deinen Computer per
USB-Kabel mit der Quest sprechen lässt**. Damit kann der Computer eine App auf die Brille
installieren und Spieldaten hinüberkopieren – wie ein Übersetzer zwischen PC und Brille. Du musst
adb nie selbst bedienen: Die Küchenhilfe benutzt es im Hintergrund und bietet an, es von Google
herunterzuladen, falls es fehlt. Damit die Quest adb vertraut, braucht sie einmalig den
Entwicklermodus (siehe unten).

**Was ist GitHub?**
GitHub ist eine **Internetseite, auf der Menschen ihre Programme und Anleitungen öffentlich
teilen** – eine Art Bibliothek für Software, in der jeder lesen und herunterladen darf. Auch die
Spiele-Projekte, auf denen unsere Rezepte aufbauen (z. B. OpenTTD oder OpenRA), liegen dort. Diese
Seite hier ist ebenfalls auf GitHub. Du brauchst **kein Konto**: Über den grünen Knopf **Code →
Download ZIP** bekommst du alles als ZIP-Datei. (Programmierer nutzen dafür das Werkzeug `git`, das
ist für dich nicht nötig.)

<details>
<summary><b>Noch ein paar Begriffe</b></summary>

| Begriff | In einfachen Worten |
|---|---|
| **Port** | Ein Spiel, das auf ein anderes Gerät „umgezogen“ wird – hier von PC auf die Quest. |
| **Open Source** | Software, deren Bauplan (Quellcode) offen liegt. Jeder darf ihn lesen, verbessern und nutzen – unter den Regeln seiner Lizenz. |
| **Quellcode** | Der Bauplan eines Programms in Textform. Daraus „baut“ ein Werkzeug die fertige App. |
| **Originaldaten** | Grafiken, Töne und Karten des Originalspiels. Die gehören dem Hersteller – deshalb bringst du sie aus deiner eigenen gekauften Kopie mit. |
| **Entwicklermodus** | Eine Einstellung der Quest, mit der sie Apps außerhalb des Meta-Stores annimmt. Einmal einschalten, fertig. |
| **Rezept** | Die Anleitung für ein bestimmtes Spiel in dieser Kitchen – was du brauchst und welche Schritte nötig sind. |
| **Küchenhilfe** | Das Programm `Kitchen.cmd` / `Kitchen.command`, das dich durch das Rezept führt und die Technik erledigt. |
| **SideQuest** | Ein freiwilliges Zusatzprogramm, um Apps auf die Quest zu spielen. Für die Kitchen nicht nötig. |
| **USB-Debugging** | Die Erlaubnis in der Brille, dass dein Computer über das Kabel mit ihr arbeiten darf. Wird beim ersten Anstecken einmal bestätigt. |
</details>

<a id="entwicklermodus"></a>
<details>
<summary><b>Entwicklermodus der Quest einschalten (einmalig, ca. 5 Minuten)</b></summary>

1. Auf [developer.meta.com](https://developers.meta.com/horizon/) mit deinem Meta-Konto anmelden und
   eine Organisation anlegen (Name beliebig) – das macht dich zum „Entwickler“.
2. In der **Meta-Horizon-App** am Handy: *Menü → Geräte → deine Quest → Headset-Einstellungen →
   Entwicklermodus* einschalten.
3. Quest neu starten, per USB-C an den PC/Mac anschließen und in der Brille **„USB-Debugging
   zulassen“** bestätigen (Haken bei „Immer von diesem Computer zulassen“).

Die Küchenhilfe erkennt, wenn einer dieser Schritte fehlt, und sagt dir, was zu tun ist.
</details>

<details>
<summary><b>Quick start (English)</b></summary>

You need a Meta Quest with **developer mode** enabled, a USB-C cable, a Windows PC or Mac and
**your own copy** of the game (GOG, Steam or CD – some recipes need none). [Download this repository](https://github.com/friedensbringer-peacemaker/XR-Port-Kitchen/archive/refs/heads/main.zip)
(or **Code → Download ZIP**), unzip it and start **`Kitchen.cmd`** (Windows) or **`Kitchen.command`**
(Mac: right-click → Open). Choose English, tick the games you want with **X**, press **Enter** and
follow the guide – it checks everything, connects the Quest, builds the app from the public port
code if you want, installs it and copies your game data. Downloads (adb from Google, kitchen updates) only happen after you agree. There are no
ready-made game apps to download: because of the different open-source licenses and the need for
your own game data, everyone builds their own app – the recipes and the kitchen helper guide you
through it step by step – or hand it to your AI agent with the ready-made start prompt in
[AGENT-START.md](AGENT-START.md). SideQuest is not required (optional; close it while the kitchen helper
runs, because its own adb conflicts with the kitchen's).
</details>

## Rezepte

| Rezept | Aufbauend auf | Portierbarkeit | XR-Potenzial | Originalspiel nötig? | Port-Code | Stand |
|---|---|:---:|:---:|---|---|---|
| [**Die Siedler II**](recipes/settlers2-rttr/RECIPE.md) | Return to the Roots, s25rttr-android | ★★★★★ | ★★★★☆ | ja – Gold Edition (GOG/CD) | [xr.settlers25](https://github.com/friedensbringer-peacemaker/xr.settlers25) | 🟢 im Headset spielbar |
| [**Command & Conquer: Alarmstufe Rot**](recipes/openra-redalert/RECIPE.md) | OpenRA | ★★★☆☆ | ★★★★★ | nein – Freeware-Daten | [xr.openra](https://github.com/friedensbringer-peacemaker/xr.openra) | 🟢 läuft, VR-Funktionen in Abnahme |
| [**Transport Tycoon Deluxe**](recipes/openttd/RECIPE.md) | OpenTTD | ★★★★☆ | ★★★★★ | nein – freie Grafik/Ton/Musik | [xr.openttd](https://github.com/friedensbringer-peacemaker/xr.openttd) | 🟢 im Headset gespielt |
| [**Theme Hospital**](recipes/themehospital-corsixth/RECIPE.md) | CorsixTH | ★★★★☆ | ★★★★☆ | ja – GOG/CD | [xr.corsixth](https://github.com/friedensbringer-peacemaker/xr.corsixth) | 🟢 im Headset gespielt |
| [**X-COM: Terror from the Deep**](recipes/xcom-tftd-oxce/RECIPE.md) | OpenXcom Extended | ★★★★☆ | ★★★★★ | ja – GOG/Steam/CD | [xr.openxcom](https://github.com/friedensbringer-peacemaker/xr.openxcom) | 🟢 im Headset gespielt |
| [**Warcraft II**](recipes/warcraft2-wargus/RECIPE.md) | Wargus + Stratagus | ★★★★☆ | ★★★★☆ | ja – Battle.net Edition (GOG)/CD | [xr.wargus](https://github.com/friedensbringer-peacemaker/xr.wargus) | 🟡 Menü im Headset, VR-Fassung in Arbeit |
| [**Warcraft: Orcs & Humans**](recipes/warcraft1-war1gus/RECIPE.md) | War1gus + Stratagus | ★★★★☆ | ★★★★☆ | ja – GOG/CD | [xr.wargus](https://github.com/friedensbringer-peacemaker/xr.wargus) | 🟡 gebaut, noch nicht im Headset |
| [**DOS-Spiele, z. B. Theme Park**](recipes/dos-xrshell/RECIPE.md) | DOSBox Pure + XRShell | ★★★★★ | ★★☆☆☆ | ja – eigene Kopie | [xr.shell](https://github.com/friedensbringer-peacemaker/xr.shell) | 🟡 in Arbeit |

🟢 im Headset geprüft · 🟡 in Arbeit · Die Sterne bewerten Portierbarkeit und XR-Potenzial
getrennt (siehe [Bewertung](#bewertung-zwei-achsen-statt-einer-note)). „Im Headset gespielt“
bezieht sich auf eine ältere Version; neuere Versionen mit VR-Menüs sind gebaut, aber oft noch
nicht abgenommen. Die genauen Belege stehen im jeweiligen Rezept.

**Als Nächstes denkbar:** RollerCoaster Tycoon 2 (OpenRCT2), Caesar III (Julius/Augustus),
Heroes of Might & Magic II (fheroes2), Dungeon Keeper (KeeperFX), Diablo (DevilutionX).
Neue Rezepte entstehen aus [`recipes/_template/`](recipes/_template/).

**Was gibt es überhaupt?** → [Katalog](catalog/README.md): rund 1.850 Open-Source-Engines,
Source-Ports, Dekompilierungen und schon vorhandene VR-Ports klassischer Spiele – mit Lizenz,
Aktivität, Android-Hinweis und Link, dazu eine Schnellprüfung „geht ein Port?“ und der passende Weg
je Technik. Durchsuchen mit `kitchen catalog <Spiel>`. *(English: [catalog](catalog/README.md) of
~1,850 engines, source ports, decomps and existing VR ports; search with `kitchen catalog <game>`.)*

**Suppe versalzen?** → [Häufige Fehler und ihre Lösung](docs/HAEUFIGE-FEHLER.md): 178
Fehler, die in den bisherigen Ports wirklich aufgetreten sind (Build, Gerät, Bild, Lebenszyklus,
Eingabe, Daten, Leistung, Godot, .NET), jeweils mit Ursache, Lösung und betroffenem Port – plus eine Checkliste
für jeden neuen Port.

## Die vier Ebenen

| Ebene | Ordner | Inhalt | Beispiel |
|---|---|---|---|
| **Rezept** | `recipes/<id>/` | Was gekocht wird: Ausgangsbasis, Stufen mit Erfolgskriterium, XR-Modi, Bewertung, Aufwand, bekannte Fallen | [`settlers2-rttr`](recipes/settlers2-rttr/RECIPE.md) |
| **Zutaten** | [`ingredients/`](ingredients/README.md) + im Rezept | Originaldaten des Spielers, Upstream-Projekte, eigene Patches, wiederverwendbare Bausteine | `xr-common`, XRShell-libretro-Host |
| **Küchengeräte** | `tools/` | Werkzeuge mit Prüfbefehl je Betriebssystem, Mindestversion und Installationshinweis | `adb`, `jdk`, `android-ndk` |
| **Küchenhilfe** | `kitchen.ps1`, `kitchen.sh` | prüft, was fehlt, und bringt die Spieldaten auf die Quest | `Kitchen.cmd` doppelklicken |

Ein Rezept besteht aus zwei Dateien:

- `recipe.json` – maschinenlesbar (Schema: [`schema/recipe.schema.json`](schema/recipe.schema.json)); daraus liest die Küchenhilfe.
- `RECIPE.md` – für Menschen und Agenten: Ablauf, Hintergründe, Fallen. Oben die Kurzfassung für
  Einsteiger, darunter aufklappbare Details für Technik-Interessierte.

Die Rezepte sind **plattformneutral**. Es gibt keine eigenen PowerShell- oder Shell-Rezepte; die
Küchenhilfe übersetzt die Prüfungen für Windows und macOS.

## Küchenhilfe benutzen

### Der Assistent (für alle, Deutsch oder Englisch)

Doppelklick auf **`Kitchen.cmd`** (Windows) bzw. **`Kitchen.command`** (macOS). Beim ersten Start
fragt die Küchenhilfe nach der Sprache. Danach erscheint das Spielemenü – alphabetisch, Ankreuzen
mit **X**:

```
  ╔══════════════════════════════════════════════════════════╗
  ║  XR-Port-Kitchen                                         ║
  ╚══════════════════════════════════════════════════════════╝
  Welche Spiele möchtest du auf die Quest bringen? Ankreuzen mit X:

     1  [ ]  Command & Conquer: Alarmstufe Rot via OpenRA  ✓
     2  [X]  Die Siedler II via Return to the Roots  ✓
     3  [ ]  DOS-Spiele via XRShell + DOSBox Pure (Beispiel: Theme Park)  …
     4  [X]  Theme Hospital via CorsixTH  ✓
     …
  2 von 8 ausgewählt
```

Windows: **↑/↓** bewegen, **Leertaste** oder **X** an-/abwählen, **A** alle, **Enter** los.
Mac: Nummer(n) eintippen (z. B. `2 4`), **Enter** los. Außerdem: **D** Geräte prüfen,
**L** Sprache, **U** Kitchen aktualisieren, **Q** Ende.

Für jedes angekreuzte Spiel führt der Assistent dann in sechs Schritten durch das Rezept:

1. **Originalspiel:** Hast du es? Falls nicht, steht da, wo man es legal bekommt.
2. **Ordner:** Wo liegen deine Spieldaten? Der Ordner wird sofort geprüft; bei Fehlern kannst du einen anderen wählen.
3. **Vorbereiten:** nur wenn das Rezept es braucht (z. B. Warcraft-II-Daten umwandeln).
4. **Werkzeuge:** Sind adb & Co. da? Fehlt adb, bietet die Küchenhilfe den Download von Google an.
5. **Quest:** verbunden? Wenn nicht, mit Hilfe zum Entwicklermodus und erneutem Versuch.
6. **App und Daten:** zeigt die installierte Version, installiert oder aktualisiert die APK
   (Spielstände bleiben) – deine selbst gebaute –,
   überträgt die Daten. Vor dem Ersetzen fragt der Assistent nach.

Am Ende steht, wo man das Spiel in der Brille findet. Die Sprache lässt sich im Menü umschalten
(`l`) oder per `-Lang en` / `--lang en` vorgeben; die Wahl merkt sich die Küchenhilfe in
`~/.xr-kitchen/lang` auf dem eigenen Rechner. Alle Texte stehen in [`i18n/strings.json`](i18n/strings.json);
Rezepte bringen ihre Hinweise zusätzlich als `…_en`-Felder mit.

### Einzelbefehle (für Bastler und Agenten)

**Windows** in PowerShell. Meldet Windows „Ausführung von Skripts ist deaktiviert“, den Aufruf
so voranstellen: `powershell -ExecutionPolicy Bypass -File kitchen.ps1 …` (`Kitchen.cmd` macht das
automatisch).

```powershell
.\kitchen.ps1 list
.\kitchen.ps1 catalog heroes
.\kitchen.ps1 show settlers2-rttr
.\kitchen.ps1 check settlers2-rttr -Assets "D:\Spiele\Siedler2"
.\kitchen.ps1 push settlers2-rttr "D:\Spiele\Siedler2"
.\kitchen.ps1 build openttd
.\kitchen.ps1 doctor
```

**macOS:** `Kitchen.command` doppelklicken oder im Terminal:

```bash
./kitchen.sh list
./kitchen.sh catalog heroes
./kitchen.sh check settlers2-rttr --assets ~/Spiele/Siedler2
./kitchen.sh push settlers2-rttr ~/Spiele/Siedler2
./kitchen.sh build openttd
```

| Befehl | Was er tut |
|---|---|
| `list` | alle Rezepte mit Stand und Sternen |
| `show <rezept>` | Kurzbeschreibung, Upstream-Projekte, XR-Modi, Stufen |
| `check <rezept>` | prüft **Küchengeräte** (Werkzeuge in der richtigen Version), **Zutaten** (liegen die Originaldateien im angegebenen Ordner?) und die **Quest** (per USB verbunden, Debugging erlaubt?). Mit `-Play` / `--play` nur das, was man zum Installieren einer schon gebauten APK braucht. |
| `push <rezept> <quelle>` | bringt deine Spieldaten auf die Quest – Zielordner, Auswahl und Prüfdateien stehen im Rezept |
| `build <rezept>` | baut die App selbst: holt nach Rückfrage den öffentlichen Port-Code (Angaben unter `build` im Rezept) neben den Kitchen-Ordner bzw. aktualisiert ihn, führt die Bauschritte aus (unter Windows in Git Bash), zeigt die fertige APK und bietet an, sie zu installieren. Der erste Bau dauert oft 10–40 Minuten und lädt Werkzeuge der Projekte nach. |
| `doctor` | prüft alle bekannten Küchengeräte |
| `guide <rezept>` | der Assistent für ein bestimmtes Rezept |
| `lint` | prüft alle Rezepte auf die Regeln (Pflichtfelder, App-Name `xr.<name>`, Sterne 1–5, bekannte Küchengeräte, keine lokalen Pfade) |
| `publish-check <repo>` | prüft ein Port-Repo, bevor es öffentlich wird (siehe unten) |
| `publish-prepare <repo>` | erzeugt den bereinigten Zweig `xr-public` und prüft ihn |
| `publish <repo>` | veröffentlicht: beim ersten Mal neues Repo bzw. Fork (`-Name xr.<name>`, `-Fork owner/repo`), danach Updates per normalem Push – fragt vorher nach |

`check` und `push` lesen nur deine eigenen Dateien und schicken sie per USB an deine Quest. Nichts
wird hochgeladen. Für macOS braucht die Küchenhilfe nur Bordmittel (`osascript`); unter Windows
reicht PowerShell 5.1.

### Spieldaten übertragen (`push`)

Alle Rezepte nutzen denselben Weg, statt dass jeder Port ein eigenes Skript mitbringt:

1. Die Quelle wird geprüft: Art (Ordner, Archiv oder Datei), Pflichtordner und bei Bedarf die
   SHA-1-Prüfsumme.
2. Ein Ordner wird zu **einer** tar-Datei gepackt. Ordner einzeln per adb zu übertragen bricht
   unter Windows ab.
3. Die Datei und ein kleines Script gehen nach `/data/local/tmp` und werden auf der Quest entpackt.
   Danach werden die Rechte gesetzt und die Prüfdateien kontrolliert.
4. App-eigener Speicher (z. B. OpenRA) wird per `run-as` beschrieben; das geht nur mit Debug-Builds.

Liegen auf der Quest schon Daten, bricht `push` ab. Ersetzen geht nur mit `-Replace` /
`--replace`; Spielstände liegen in allen Rezepten getrennt und bleiben erhalten. `-DryRun` /
`--dry-run` zeigt vorher, was passieren würde. Weitere Optionen: `-Name`, `-App` (z. B.
`xr.island` statt `xr.shell`), `-Serial` bei mehreren Geräten.

### Port-Code veröffentlichen (`publish-check`)

Der Code der Ports ist eine Zutat wie die Spieldaten – nur dass er auf GitHub darf. Bevor ein
Port-Repo öffentlich wird, prüft `publish-check`:

| Prüfung | Wo |
|---|---|
| keine Spieldaten (Endungen wie `.mpq`, `.z64`, `.iso`, Installer, Originaldateien aus den Rezepten) | aktueller Stand **und** eigene Commits der Historie |
| nichts aus Spieldaten Erzeugtes (`wargus-quest/`, Menü-Skins …) | ebenso |
| keine Schlüssel und Zugangsdaten (`*.keystore`, `local.properties`, `.env` …) | ebenso |
| keine Gerätelogs, Aufnahmen | ebenso |
| keine persönlichen Pfade und E-Mail-Adressen | Inhalt, Historie, Commit-Autoren |
| Lizenzdatei vorhanden | Hauptordner |

Bei Forks (Remote `upstream` oder ein Remote, der nicht zum eigenen GitHub-Konto gehört) prüft sie
nur, was eigene Commits geändert haben – der Upstream-Code mit seinen freien Inhalten bleibt
außen vor. Persönliche Muster (Home-Ordner, Lage des XR-Ordners, Git-E-Mail) ermittelt die
Küchenhilfe auf dem jeweiligen Rechner; sie stehen in keiner Datei. Eigene Ergänzungen dazu
gehören nach `~/.xr-kitchen/personal-patterns.txt` (eine Zeile je Muster, bleibt lokal). Die
Regeln selbst stehen in [`rules/publish-rules.json`](rules/publish-rules.json).

`publish-prepare <repo>` erzeugt daraus den Veröffentlichungszweig `xr-public`: bei Forks der
neueste enthaltene Upstream-Stand plus **ein** Commit mit dem aktuellen eigenen Stand, sonst ein
einzelner Commit ohne Vorgeschichte – Autor ist die GitHub-noreply-Adresse. Die private Historie,
HEAD und der Arbeitsstand bleiben unverändert. Anschließend läuft `publish-check` automatisch auf
dem neuen Zweig. Submodule, deren Commit nur lokal existiert, veröffentlicht man zuerst selbst:
dort `publish-prepare`, den Zweig `xr-public` in ein öffentliches Repo pushen und es als Remote
`public` eintragen. Danach stellt `publish-prepare` im Hauptrepo den Submodul-Verweis und die
Adresse in `.gitmodules` automatisch auf den öffentlichen Stand um. (Flache Klone lassen sich nur
in einen GitHub-Fork des Originals pushen, nicht in ein leeres neues Repo.)

**Updates:** Ist ein Repo schon veröffentlicht (Remote `public`), wird jeder neue Stand ein
Folge-Commit auf den veröffentlichten – ein normaler Push genügt, und wer das Repo geklont hat,
kann einfach `git pull` machen. `publish` erledigt Vorbereiten, Prüfen und Pushen in einem Schritt.

## Bewertung: zwei Achsen statt einer Note

Leicht portierbar heißt nicht automatisch großes XR-Potenzial, und umgekehrt. Jedes Rezept
bewertet deshalb getrennt (je 1–5 Sterne):

| Achse | Frage |
|---|---|
| **Portierbarkeit** | Wie nah ist die Ausgangsbasis an Android/ARM64/GLES und OpenXR? |
| **XR-Potenzial** | Bleibt es eine große Leinwand, oder trägt es Tisch, Diorama oder echtes VR? |
| **Reife der Basis** | Wie aktiv und vollständig ist das Upstream-Projekt? |

Dazu kommen der **Aufwand** zum Einrichten (wenn die App schon gebaut ist) und zum Bauen aus dem Quellcode,
in Minuten, Stunden oder Tagen, und der **Stand**: wann das Rezept zuletzt im Headset geprüft wurde.

XR-Ausbaustufen (gemeinsames Vokabular aller Rezepte):

| Stufe | Bedeutung |
|---|---|
| `screen` | Spiel auf großer virtueller Leinwand (flach oder gewölbt) |
| `passthrough` | dieselbe Leinwand im eigenen Raum (Mixed Reality) |
| `tabletop` | Spielfeld liegt als Tisch vor einem, geneigt oder flach |
| `diorama` | Tisch mit Höhenrelief bzw. 3D-Figuren |
| `full-vr` | echte stereoskopische 3D-Welt mit Kopfbewegung |

## Ordner

Die Rezepte verweisen auf die Port-Projekte mit Platzhaltern:

| Platzhalter | Bedeutung | Beispiel |
|---|---|---|
| `<XR-Ordner>` | der gemeinsame Ordner, in dem die Kitchen, alle Port-Projekte (`XR-Settlers2.5`, `XR-OpenRA` …), `_tools/` und `_shared/` nebeneinander liegen | `C:\XR` oder `~/XR` |
| `<XR-Ordner>/_tools/` | gemeinsame Werkzeuge (Android-SDK, Quest-Logger, innoextract); die Küchenhilfe findet sie automatisch | `C:\XR\_tools\android-sdk` |
| `~/.claude/skills/` | die XR-Skills für Claude Code (das ausführliche Kochwissen) | – |

Empfohlener Aufbau:

```
<XR-Ordner>/
├── XR-Port-Kitchen/      ← dieses Repo
├── XR-Settlers2.5/       ← Port-Projekte, je ein eigenes Repo
├── XR-OpenRA/
├── XR-Logger/            ← xr.logger (Werkzeug-App für die Quest, siehe unten)
├── _tools/               ← android-sdk, quest, innoextract …
└── _shared/              ← xr-common
```

### Logs und Abstürze in der Brille: xr.logger

[XR-Logger](https://github.com/friedensbringer-peacemaker/XR-Logger) ist eine kleine 2D-App für die
Quest. Sie zeigt für jeden eigenen Port die letzten Programm-Enden mit Grund (Absturz, ANR,
Speichermangel), lesbar aufbereitete Absturzberichte (Tombstone, ANR-Trace) und das Log, ohne PC.
Einmal einrichten mit `bash tools/install.sh` im XR-Logger-Ordner (installiert und vergibt per adb
`READ_LOGS` und `DUMP`). Bei Headset-Tests (Stufen mit `automatable: manual`) ist das der schnellste
Weg, nach einem Absturz den Grund zu sehen. Dauerhaft mitschreiben weiterhin am PC mit dem Quest-Logger
unter `_tools/quest`.

## Rechtlicher Rahmen (gilt für jedes Rezept)

1. **Keine Spieldateien in diesem Repo.** Kein ROM, ISO, Installer, MPQ und keine Disk-Images.
   `.gitignore` blockt die üblichen Endungen. Rezepte nennen nur Dateinamen, die der Spieler aus
   seiner **eigenen** Kopie (GOG, Steam, CD) mitbringt.
2. **Keine Kopierschutz-Umgehung**, keine Download-Links zu fremden Spieldaten.
3. **Keine Marken in App-Namen.** Eigene Apps heißen `xr.<name>` in Kleinbuchstaben.
4. **Lizenzen der Upstream-Projekte einhalten** (GPL-Quellcodepflicht, Hinweise, Credits).
5. „Abandonware“ ist kein Rechtsstatus. Im Rezept steht, wer die Rechte hält und wo man das Spiel
   legal kaufen kann.

## Wie die Kitchen mitlernt

Jeder Port soll Wissen hinzufügen und möglichst wenig neue Infrastruktur brauchen. Nach jedem
Arbeitsschritt wird sortiert:

- **spielspezifisch** → `RECIPE.md` des Rezepts (Abschnitt „Bekannte Fallen“)
- **Fehler, die mehrere Ports treffen** → [`docs/HAEUFIGE-FEHLER.md`](docs/HAEUFIGE-FEHLER.md)
- **wiederverwendbar** → [`ingredients/`](ingredients/README.md) (Baustein) oder
  [`ingredients/CANDIDATES.md`](ingredients/CANDIDATES.md) (Kandidat für ein Modul in
  `xr-common` oder einen Skill)

Die Arbeitsregeln für Agenten stehen in [AGENTS.md](AGENTS.md).

## Stand

Version 0.4 (2026-10-03):
- Assistent auf Deutsch und Englisch, der Schritt für Schritt durch ein Rezept führt
- `publish-check` und `publish-prepare` für Port-Repos vor der Veröffentlichung
- acht Rezepte, `lint`
- [Häufige Fehler und ihre Lösung](docs/HAEUFIGE-FEHLER.md) über alle Ports hinweg

Version 0.2 (2026-10-02):
- `push` als gemeinsamer Weg für die Spieldaten aller Rezepte
- neutrale Pfade statt lokaler Rechnerpfade
- Rezeptübersicht auf dieser Startseite

Version 0.1 brachte Gerüst, Schema, Küchenhilfe für Windows und macOS, drei Rezepte.
