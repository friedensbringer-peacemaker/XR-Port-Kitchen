<!-- Erzeugt von catalog/render.py aus catalog.tsv – nicht von Hand bearbeiten. -->
# Source-Ports, Dekompilierungen, Recompilierungen

Ports auf Basis von offiziell freigegebenem Quellcode sowie rekonstruierter Code (Decomp/Recomp). Ports of officially released source code and reconstructed code (decompilation / static recompilation).

Legende: 📖 = Rezept in der Kitchen · 🥽 = schon als Quest-VR-Port von anderen vorhanden · 💤 = seit 2022 ohne Commit / eingestellt.
„?“ = nicht bekannt (nicht: „nein“). Erklärung und Bewertung: [README.md](README.md).

**Abschnitte:** id Software / Raven / Apogee / 3D Realms (Ego-Shooter-Kern) (52) · Weitere Shooter, Action, Sims (41) · Strategie / RPG / Taktik (20) · Klassische PC-/DOS-Spiele (Decomp, Reverse Engineering, statische Recompilierung) (62) · SNES / NES / Mega Drive / GBA / DS (Decomp & Recomp) (2) · PlayStation 1 / PlayStation 2 (15) · GameCube / Wii / Original Xbox (2) · Xbox 360 – XenonRecomp / ReXGlue (19) · Mobile-/PC-Remaster-Decomps (RSDK u. a.) (10)

## id Software / Raven / Apogee / 3D Realms (Ego-Shooter-Kern) (52)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| BStone | Blake Stone: Aliens of Gold / Planet Strike | DOS | source-port | C++/SDL2 | GPL (2013), Daten nötig | aktiv | – | <https://github.com/bibendovsky/bstone> |
| BuildGDX / NuBuildGDX | Duke3D, Blood, Shadow Warrior, Witchaven 1/2, TekWar, Redneck Rampage u. a. | DOS | source-port | Java/libGDX | gemischt (TekWar-Quellen geleakt), Daten nötig | aktiv (NuBuildGDX) | offiziell (libGDX-Android) ? | <https://github.com/atsb/NuBuildGDX> |
| CatacombGL | Catacomb 3-D-Reihe | DOS | source-port | C++/OpenGL | GPL, Daten nötig (GOG) | aktiv | – | <https://github.com/ArnoAnsems/CatacombGL> |
| Chocolate Doom (inkl. Chocolate Heretic/Hexen/Strife) | Doom, Heretic, Hexen, Strife | DOS | source-port | C/SDL2 | GPL; Strife-Teil per Reverse Engineering, Daten nötig | stabil | inoffiziell | <https://github.com/chocolate-doom/chocolate-doom> |
| Chocolate Heretic / GZDoom | Heretic, Hexen | DOS | source-port | C/C++ | GPL (2008 neu lizenziert), WAD nötig | aktiv | wie Doom-Ports | <https://github.com/chocolate-doom/chocolate-doom> |
| Crispy Doom | Doom/Heretic/Hexen/Strife | DOS | source-port | C/SDL2 | GPL, WAD nötig | aktiv | PortMaster | <https://github.com/fabiangreffrath/crispy-doom> |
| Daikatana 1.3 | Daikatana | Win | source-port | C | Code von Romero an Community, nicht frei lizenziert | stabil | – | <https://www.daikatananews.net> |
| dhewm3 🥽 Doom3Quest | Doom 3 / RoE | Win | source-port | C++/SDL2/OpenGL | GPL (2011), PK4 nötig | aktiv | – (Android-Fork d3es) | <https://github.com/dhewm/dhewm3> |
| Doom 3DO Source | Doom (3DO) | 3DO | decomp | C/ARM-ASM | MIT (Rebecca Heineman, 2014) | Archiv | – | <https://github.com/Olde-Skuul/doom3do> |
| Doom Retro | Doom | DOS | source-port | C/SDL2 | GPL, WAD nötig | aktiv | – | <https://github.com/bradharding/doomretro> |
| Doom3Quest | Doom 3 | Win | source-port | C++/GLES/OpenXR | GPL, PK4 nötig | stabil | **Quest-VR** | <https://github.com/Team-Beef-Studios/Doom3Quest> |
| DSDA-Doom | Doom (Boom/MBF21-Kompat.) | DOS | source-port | C/SDL2/OpenGL | GPL, WAD nötig | aktiv | PortMaster | <https://github.com/kraflab/dsda-doom> |
| ECWolf | Wolfenstein 3D, Spear of Destiny, Super 3D Noah's Ark | DOS | source-port | C++/SDL2 | Code GPL (1995 id-Release), Daten nötig | stabil | inoffiziell (Delta Touch) | <https://maniacsvault.net/ecwolf/> |
| EDuke32 | Duke Nukem 3D | DOS | source-port | C/C++/SDL2 | Code GPL + Build-Lizenz (nicht-kommerziell), GRP nötig | aktiv | inoffiziell | <https://voidpoint.io/terminx/eduke32> |
| ET: Legacy | Wolfenstein: Enemy Territory | Win | source-port | C/SDL2 | GPL (2010); ET selbst Freeware | aktiv | offiziell (APK, neuere Versionen) ? | <https://github.com/etlegacy/etlegacy> |
| Eternity Engine | Doom/Heretic | DOS | source-port | C++/SDL2 | GPL, WAD nötig | aktiv | – | <https://github.com/team-eternity/eternity> |
| GZDoom / UZDoom | Doom, Doom II, Heretic, Hexen, Strife | DOS | source-port | C++/OpenGL/Vulkan | GPL, WAD nötig; 2025 Community-Abspaltung UZDoom | aktiv | inoffiziell (Delta Touch); **Quest-VR** (QuestZDoom) | <https://github.com/ZDoom/gzdoom> |
| Hammer of Thyrion (uHexen2) | Hexen II | Win | source-port | C/SDL | GPL (2000), PAK nötig | stabil | inoffiziell | <https://uhexen2.sourceforge.net> |
| ioquake3 🥽 Quake3Quest | Quake III Arena / Team Arena | Win | source-port | C/SDL2 | GPL (2005), PAK nötig | aktiv | inoffiziell; Quest-VR (ioq3quest/„Quake3Quest“) | <https://github.com/ioquake/ioq3> |
| iortcw 🥽 RTCWQuest | Return to Castle Wolfenstein | Win | source-port | C/SDL2 | GPL (2010), PK3 nötig | aktiv | – | <https://github.com/iortcw/iortcw> |
| Ironwail | Quake | DOS/Win | source-port | C/OpenGL 4.3 | GPL, PAK nötig | aktiv | – | <https://github.com/andrei-drexler/ironwail> |
| JKXR | Jedi Outcast / Jedi Academy | Win | source-port | C++/OpenXR | GPL, Daten nötig | aktiv | **Quest-VR** | <https://github.com/Team-Beef-Studios/JKXR> |
| LAB3D/SDL | Ken's Labyrinth | DOS | source-port | C/SDL | Quellcode nicht-kommerziell (Silverman), Spiel Freeware | ruhend | – | <http://www.advsys.net/ken/klab.htm> |
| Lambda1VR | Half-Life | Win | decomp | C/OpenXR | wie Xash3D, Daten nötig | stabil | **Quest-VR** | <https://github.com/Team-Beef-Studios/Lambda1VR> |
| lilium-voyager | Star Trek Voyager: Elite Force (Holomatch-MP) | Win | source-port | C | Spielcode aus GDK/GPL-Engine, Daten nötig | ruhend | – | <https://github.com/zturtleman/lilium-voyager> |
| LZWolf | Wolfenstein 3D / SoD | DOS | source-port | C++/SDL2 | GPL, Daten nötig | aktiv | – | <https://bitbucket.org/linuxwolf6/lzwolf> |
| Odamex | Doom (Multiplayer) | DOS | source-port | C++/SDL2 | GPL, WAD nötig | aktiv | – | <https://github.com/odamex/odamex> |
| OpenJK 🥽 JKXR | Star Wars Jedi Knight II: Jedi Outcast / Jedi Academy | Win | source-port | C/C++/SDL2 | GPL (2013), Daten nötig; Marke Lucasfilm | aktiv | inoffiziell | <https://github.com/JACoders/OpenJK> |
| openPREY | Prey (2006) | Win | source-port | C++ | Prey-Quellcode nie offiziell frei, nur SDK → Grauzone | aktiv | – | <https://github.com/themuffinator/openPREY> |
| openQ4 | Quake 4 | Win | source-port | C++ | Engine GPL, Spiellogik aus SDK → Grauzone, Daten nötig | aktiv | – | <https://github.com/themuffinator/openQ4> |
| PrBoom+ 💤 | Doom | DOS | source-port | C/SDL | GPL, WAD nötig | archiviert (→ DSDA) | inoffiziell | <https://github.com/coelckers/prboom-plus> |
| Q2PRO | Quake II | Win | source-port | C | GPL, PAK nötig | aktiv | – | <https://github.com/skullernet/q2pro> |
| Quake II Rerelease Game Source | Quake II (2023 Remaster) | Win/Konsolen | decomp | C++ | GPL (id/Nightdive 2023), Remaster-Daten nötig | stabil | – | <https://github.com/id-Software/quake2-rerelease-dll> |
| Quake2Quest | Quake II | Win | source-port | C/GLES/OpenXR | GPL, PAK nötig | stabil | **Quest-VR** | <https://github.com/Team-Beef-Studios/Quake2Quest> |
| QuakeQuest | Quake | DOS/Win | source-port | C/GLES/OpenXR | GPL, PAK nötig | stabil | **Quest-VR** | <https://github.com/Team-Beef-Studios/QuakeQuest> |
| Quakespasm | Quake | DOS/Win | source-port | C/SDL2/OpenGL | GPL (1999), PAK nötig | aktiv | PortMaster | <https://github.com/sezero/quakespasm> |
| QuestZDoom | Doom/Heretic/Hexen/Strife (über GZDoom/LZDoom) | DOS | source-port | C++/OpenXR/GLES | GPL, WAD nötig | aktiv | **Quest-VR** | <https://github.com/Team-Beef-Studios/QuestZDoom> |
| Raze 🥽 RazeXR | Duke 3D, Shadow Warrior, Blood, PowerSlave/Exhumed, Redneck Rampage | DOS | source-port | C++ | GPL (Build-Code relizenziert), Daten nötig | aktiv | **Quest-VR** (RazeXR) | <https://github.com/ZDoom/Raze> |
| RazeXR | Build-Spiele (s. Raze) | DOS | source-port | C++/OpenXR | GPL, Daten nötig | aktiv | **Quest-VR** | <https://github.com/Team-Beef-Studios/RazeXR> |
| RBDOOM-3-BFG | Doom 3 BFG Edition | Win/Konsolen | source-port | C++/Vulkan | GPL (2012), BFG-Daten nötig | aktiv | – | <https://github.com/RobertBeckebans/RBDOOM-3-BFG> |
| Reflection Keen | Keen Dreams, Catacomb 3-D/Abyss/Armageddon/Apocalypse, Wolf3D-Ableger | DOS | source-port | C/SDL2 | GPL (Flat Rock 2014), Daten nötig | aktiv | inoffiziell | <https://github.com/NY00123/refkeen> |
| RTCWQuest | Return to Castle Wolfenstein | Win | source-port | C/GLES/OpenXR | GPL, PK3 nötig | stabil | **Quest-VR** | <https://github.com/Team-Beef-Studios/RTCWQuest> |
| Serious Engine (Croteam) / SeriousSamClassic | Serious Sam: TFE/TSE | Win | source-port | C++/SDL2 | GPL-2.0 (2016), Daten nötig | aktiv (Community-Forks) | inoffiziell | <https://github.com/tx00100xt/SeriousSamClassic> |
| Source SDK 2013 / TF2 SDK | Half-Life 2-Mods, Team Fortress 2 | Win | decomp | C++ | Valve-SDK-Lizenz (TF2-Code 2025 freigegeben) | aktiv | – | <https://github.com/ValveSoftware/source-sdk-2013> |
| Taradino (ROTT-Port) | Rise of the Triad | DOS | source-port | C/SDL2 | GPL (2002), Daten nötig | aktiv | – | <https://github.com/fabiangreffrath/taradino> |
| vkQuake | Quake | DOS/Win | source-port | C/Vulkan | GPL, PAK nötig | aktiv | – | <https://github.com/Novum/vkQuake> |
| VoidSW | Shadow Warrior (1997) | DOS | source-port | C/SDL2 | Code GPL+Build-Lizenz (2005), GRP nötig | stabil | – | <https://voidpoint.io/terminx/eduke32> |
| Wolf4SDL | Wolfenstein 3D / SoD | DOS | source-port | C/SDL | Wolf3D-Lizenz/GPL, Daten nötig | ruhend | inoffiziell | <https://github.com/11001011101001011/Wolf4SDL> |
| Woof! | Doom (MBF) | DOS | source-port | C/SDL2 | GPL, WAD nötig | aktiv | PortMaster | <https://github.com/fabiangreffrath/woof> |
| Xash3D FWGS + hlsdk | Half-Life (+ Mods) | Win | decomp | C/SDL2 | Engine eigenständig GPL, Spielcode Valve-SDK-Lizenz, Daten nötig | aktiv | offiziell (APK); **Quest-VR** (Lambda1VR) | <https://github.com/FWGS/xash3d-fwgs> |
| Yamagi Quake II 🥽 Quake2Quest | Quake II | Win | source-port | C/SDL2/GL/Vulkan | GPL (2001), PAK nötig | aktiv | PortMaster | <https://github.com/yquake2/yquake2> |
| Zandronum | Doom (Multiplayer, ZDoom-basiert) | DOS | source-port | C++ | GPL, WAD nötig | aktiv | – | <https://zandronum.com> |

## Weitere Shooter, Action, Sims (41)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| Abuse (SDL) | Abuse | DOS | source-port | C++/SDL2 | Public Domain (Crack dot Com), Daten teils frei | stabil | – | <https://github.com/Xenoveritas/abuse> |
| Aerofoil | Glider PRO | Mac | source-port | C++/SDL2 | GPL-2 (Calhoun 2016), Daten frei | ruhend | offiziell (APK) | <https://github.com/elasota/Aerofoil> |
| Aleph One | Marathon 1/2/Infinity | Mac | source-port | C++/SDL2 | GPL-3; Marathon-Daten frei von Bungie | aktiv | – (iOS ja) | <https://github.com/Aleph-One-Marathon/alephone> |
| AmnesiaTheDarkDescent / AmnesiaAMachineForPigs | Amnesia TDD / AMfP | Win | decomp | C++ | GPL-3 (Frictional 2020), Daten nötig | Archiv (Community-Forks) | – | <https://github.com/FrictionalGames/AmnesiaTheDarkDescent> |
| Aquaria OSE | Aquaria | Win | source-port | C++/SDL | GPL-2 (2010), Daten nötig | aktiv | inoffiziell | <https://github.com/AquariaOSE/Aquaria> |
| Arx Libertatis | Arx Fatalis | Win | source-port | C++/SDL2/OpenGL | GPL-3 (Arkane 2011), Daten nötig | aktiv | – | <https://github.com/arx/ArxLibertatis> |
| Avara (avaraline) | Avara | Mac | source-port | C++/SDL2 | MIT (2016) | aktiv | – | <https://github.com/avaraline/Avara> |
| AvP (Linux-Port) | Aliens versus Predator (2000) Gold | Win | source-port | C/SDL | Rebellion-Lizenz nicht-kommerziell, Daten nötig | ruhend | inoffiziell | <https://github.com/neuromancer/avp> |
| Cortex Command Community Project | Cortex Command | Win | source-port | C++ | AGPL-3 (2019), Daten mitgeliefert | aktiv | – | <https://github.com/cortex-command-community/Cortex-Command-Community-Project> |
| Delver | Delver | Win | decomp | Java/libGDX | zlib (2018), Daten nötig | Community | offiziell möglich (libGDX) | <https://github.com/Interrupt/delverengine> |
| Descent 3 (Community) | Descent 3 | Win | source-port | C++/SDL2 | GPL-3 (2024), Daten nötig | aktiv | – (ARM64-Linux/macOS-Builds) | <https://github.com/DescentDevelopers/Descent3> |
| DXX-Rebirth | Descent, Descent II | DOS | source-port | C++/SDL2/OpenGL | eigene Parallax-Lizenz (nicht-kommerziell)/GPL, HOG nötig | aktiv | inoffiziell | <https://github.com/dxx-rebirth/dxx-rebirth> |
| EECH | Enemy Engaged: Comanche vs Hokum | Win | source-port | C | Razorworks-Lizenz, Daten nötig | ruhend | – | <https://sourceforge.net/projects/eech/> |
| FreeAllegiance | Allegiance | Win | source-port | C++/DirectX | MIT (Microsoft 2004/2018) | aktiv | – | <https://github.com/FreeAllegiance/Allegiance> |
| freegish | Gish | Win | source-port | C/SDL | GPL-2 (2010), Daten nötig | ruhend | inoffiziell | <https://github.com/freegish/freegish> |
| FS2Open (FreeSpace 2 Source Code Project) | FreeSpace 2 | Win | source-port | C++/OpenGL | Volition-Lizenz nicht-kommerziell, VP nötig | aktiv | – | <https://github.com/scp-fs2open/fs2open.github.com> |
| GNU FreeDink / Dink Smallwood HD | Dink Smallwood | Win | source-port | C++ | Zlib-artige Lizenz; Spiel Freeware | stabil | offiziell (HD-Version) | <https://www.gnu.org/software/freedink/> |
| HomeworldSDL | Homeworld | Win | source-port | C/SDL2 | Relic-Lizenz nicht-kommerziell, BIG nötig | aktiv | – | <https://github.com/HomeworldSDL/HomeworldSDL> |
| HPL1 / Penumbra in ScummVM | Penumbra: Overture | Win | source-port | C++ | GPL-3, Daten nötig | aktiv | offiziell (ScummVM-APK) | <https://www.scummvm.org> |
| Lugaru (OSS) | Lugaru | Win/Mac | source-port | C++/SDL2 | GPL-2 Code, Daten CC BY-SA (frei!) | ruhend | – | <https://gitlab.com/osslugaru/lugaru> |
| Machines: Wired for War | Machines | Win | decomp | C++ | GPL-3 (Nightdive 2020), Daten frei verfügbar | Community | – | <https://github.com/markol/machines> |
| Micropolis | SimCity (1989) | Unix/DOS | source-port | C/C++ | GPL-3 (EA 2008), ohne Marke „SimCity“ | ruhend | – | <https://github.com/SimHacker/micropolis> |
| OpenTyrian | Tyrian 2.1 | DOS | source-port | C/SDL2 | GPL-2; Tyrian 2.1 Freeware | stabil | inoffiziell | <https://github.com/opentyrian/opentyrian> |
| OpenW3D (W3D Hub) | C&C Renegade | Win | source-port | C++ | GPL-3 (EA 2025), Daten nötig | WIP | – | <https://github.com/w3dhub/OpenW3D ?> |
| Overgrowth | Overgrowth | Win | decomp | C++ | Apache-2.0 (Wolfire 2022), Daten nötig | Community | – | <https://github.com/WolfireGames/overgrowth> |
| Pangea-Ports (Jorio): Nanosaur, Nanosaur II, Bugdom, Bugdom 2, Otto Matic, Mighty Mike, Cro-Mag Rally, Billy Frontier | diverse Pangea-Spiele | Mac | source-port | C/SDL2/OpenGL | Pangea-Lizenz (CC BY-NC-SA), Daten enthalten | aktiv | – | <https://github.com/jorio> |
| Perimeter | Perimeter | Win | source-port | C++/SDL2 | GPL-3 (2021), Daten nötig | aktiv | – | <https://github.com/KD-lab-Open-Source/Perimeter> |
| Postal (GPL-Release) | Postal | Win | decomp | C++/SDL | GPL-2 (RWS 2016), Daten nötig | Archiv | – | <https://bitbucket.org/gopostal/postal-1-open-source> |
| Prince of Persia (Apple II) Source | Prince of Persia | Apple II | decomp | 6502-ASM | von Mechner veröffentlicht (keine OSS-Lizenz) | Archiv | – | <https://github.com/jmechner/Prince-of-Persia-Apple-II> |
| Raptor (Port) | Raptor: Call of the Shadows | DOS | source-port | C/SDL2 | GPL-2 (2023), Daten nötig | aktiv | inoffiziell ? | <https://github.com/skynettx/raptor> |
| Red Dog | Red Dog: Superior Firepower | Dreamcast | decomp | C | MIT (Godbolt 2022) | Archiv | – | <https://github.com/mattgodbolt/reddog> |
| Rogue Legacy (Source) | Rogue Legacy | Win/Konsolen | source-port | C#/FNA | nicht-OSS, Daten nötig | Archiv | – | <https://github.com/flibitijibibo/RogueLegacy1> |
| Shockolate | System Shock (Mac-Code) | DOS/Mac | source-port | C/SDL2 | GPL-3 (Nightdive 2018), Daten nötig | ruhend/aktiv (Forks) | inoffiziell (system-shock-android) | <https://github.com/Interrupt/systemshock> |
| Star Ruler 2 | Star Ruler 2 | Win | decomp | C++/AngelScript | MIT, Assets CC BY-NC | Community | – | <https://github.com/BlindMindStudios/StarRuler2-Source> |
| Storm Engine | Sea Dogs, Age of Pirates 2, Captain Blood | Win | source-port | C++ | GPL-3 (2021/22), Daten nötig | aktiv | – | <https://github.com/storm-devs/storm-engine> |
| The Ur-Quan Masters | Star Control II | DOS/3DO | source-port | C/SDL | GPL-2; Inhalte CC BY-NC-SA (frei) | aktiv | inoffiziell (APK) | <https://sc2.sourceforge.net> |
| Toki Tori 2+ Engine | Toki Tori 2+, Rive | Win | decomp | C++ | GPL-2 (2021), Daten nötig | Archiv | – | <https://github.com/TwoTribesGames/TT2 ?> |
| Tread Marks | Tread Marks | Win | decomp | C++ | GPL-3 (2017) | ruhend | – | <https://github.com/SeumasMcNally/TreadMarks ?> |
| Urban Chaos (MuckyFoot) / OpenChaos | Urban Chaos | Win/PS1 | decomp | C++ | MIT (2017), Daten nötig | WIP | – | <https://github.com/dizzy2003/MuckyFoot-UrbanChaos> |
| Vangers | Vangers | Win | source-port | C++/SDL2 | GPL-3 (K-D Lab 2016), Daten nötig | aktiv | – | <https://github.com/KranX/Vangers> |
| VVVVVV | VVVVVV | Win | source-port | C++/SDL2 | Nicht-kommerziell, data.zip nötig (Make & Play frei) | aktiv | offiziell (Store-App) | <https://github.com/TerryCavanagh/VVVVVV> |

## Strategie / RPG / Taktik (20)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| 7kaa | Seven Kingdoms: Ancient Adversaries | Win | source-port | C++/SDL2 | GPL-2 (Enlight 2009), Daten frei | aktiv | – | <https://github.com/the3dfxdude/7kaa> |
| CnC_Remastered_Collection | C&C TD/RA (Remaster-DLLs) | Win | decomp | C++ | GPL-3 + Zusatzbedingungen, nur Mod-DLL | Archiv | – | <https://github.com/electronicarts/CnC_Remastered_Collection> |
| Colobot: Gold Edition | Colobot | Win | source-port | C++/SDL2 | GPL-3 | aktiv | – | <https://github.com/colobot/colobot> |
| Conquest: Frontier Wars (GOG-Source) | Conquest: Frontier Wars | Win | decomp | C++/DirectX | mit Spielkauf mitgeliefert, nicht-OSS | Archiv | – | <https://www.gog.com/game/conquest_frontier_wars> |
| CTP2 (Apolyton) | Call to Power II | Win | source-port | C++/SDL | Activision-Lizenz nicht-kommerziell, Daten nötig | ruhend | – | <https://github.com/civctp2/civctp2> |
| Fish Fillets NG | Fish Fillets | DOS | source-port | C++/SDL | GPL-2 | ruhend | inoffiziell | <https://fillets.sourceforge.net> |
| Generals XR (Cesarus85) | C&C Generals Zero Hour | Win | source-port | C++/OpenXR | GPL-3 Basis, Daten nötig | aktiv | **Quest-VR** | <https://github.com/Cesarus85 (Repo „Generals XR“) ?> |
| GeneralsGameCode (TheSuperHackers) | C&C Generals / Zero Hour | Win | source-port | C++ (VC6→modern) | GPL-3 (EA 2025), Daten nötig | aktiv | – | <https://github.com/TheSuperHackers/GeneralsGameCode> |
| JA2 1.13 | Jagged Alliance 2 | Win | source-port | C++ | SFI-SCLA, Daten nötig | aktiv | – | <https://github.com/1dot13/source> |
| JA2 Stracciatella | Jagged Alliance 2 (+ Unfinished Business) | Win | source-port | C++/Rust/SDL2 | Strategy-First-SFI-SCLA (nicht-kommerziell), Daten nötig | aktiv | offiziell (Launcher-APK) | <https://github.com/ja2-stracciatella/ja2-stracciatella> |
| Little Big Adventure 2 Classic (Community) | LBA 1 / LBA 2 | DOS/Win | source-port | C/C++/SDL | GPL-2 (2.21, 2021), Daten nötig | aktiv | – | <https://github.com/2point21/lba2-classic-community> |
| MechCommander 2 (Linux/Omnitech-Port) | MechCommander 2 | Win | source-port | C++/SDL/OpenGL | Microsoft Shared Source, Daten im Release | ruhend | – | <https://github.com/alariq/mc2> |
| Meridian 59 (Server/Client) | Meridian 59 | Win | decomp | C | GPL-2 | Community | – | <https://github.com/Meridian59/Meridian59> |
| OpenClonk | Clonk-Reihe | Win | source-port | C++ | ISC, Assets CC BY | aktiv | – | <https://github.com/openclonk/openclonk> |
| Planet Blupi | Planet Blupi | Win | source-port | C++/SDL2 | GPL-3 (Epsitec 2017) | stabil | inoffiziell | <https://github.com/blupi-games/planetblupi> |
| Ryzom Core | Ryzom | Win | source-port | C++ | AGPL-3, Assets CC BY-SA | aktiv | – | <https://github.com/ryzom/ryzomcore> |
| ScummVM (Engines mit Original-Quellcode) | Beneath a Steel Sky, Broken Sword 1/2, Flight of the Amazon Queen, Lure of the Temptress, Feeble Files, Inherit the Earth, Discworld 1/2, Labyrinth of Time, Nightlong, Faery Tale II, Tony Tough, Sherlock Holmes (Serrated Scalpel/Rose Tattoo), MoonBase Commander, The Space Bar | DOS/Win/Amiga | source-port | C++/SDL2 | GPL; BASS/FotAQ/Lure als Freeware mit Daten | aktiv | offiziell (ScummVM-APK) | <https://github.com/scummvm/scummvm> |
| Siege of Avalon (Open SoA) | Siege of Avalon | Win | source-port | Delphi | LGPL (2003) | ruhend | – | <https://github.com/SteveNew/Siege-of-Avalon-Open-Source> |
| Vanilla Conquer | C&C Tiberian Dawn, Red Alert | DOS/Win | source-port | C++/SDL2 | GPL-3 (EA 2020, Remastered-DLL-Code), Daten nötig | aktiv | inoffiziell | <https://github.com/TheAssemblyArmada/Vanilla-Conquer> |
| Warzone 2100 | Warzone 2100 | Win/PS1 | source-port | C++/SDL2/Vulkan | GPL-2, Daten frei | aktiv | – | <https://github.com/Warzone2100/warzone2100> |

## Klassische PC-/DOS-Spiele (Decomp, Reverse Engineering, statische Recompilierung) (62)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| arcanum-ce | Arcanum | Win | decomp | C++/SDL3 | Daten nötig | aktiv | – ? | <https://github.com/alexbatalov/arcanum-ce> |
| BioMenaceDecomp | Bio Menace | DOS | decomp | C | Daten nötig (Spiel Freeware) | WIP | – | <https://github.com/lethal-guitar/BioMenaceDecomp> |
| Call of Duty 4 / Black Ops Decomp (SwagSoftware) | CoD4: MW, CoD: Black Ops | Win | decomp | C++ | Grauzone, Activision-Risiko hoch | WIP | – | (siehe Wikipedia „reconstructed“) |
| Cannonball | OutRun | Arcade | decomp | C++/SDL2 | MAME-ROM nötig | stabil | inoffiziell/PortMaster | <https://github.com/djyt/cannonball> |
| cdcEngine (TR Legend / DX:HR) | Tomb Raider: Legend, Deus Ex: Human Revolution | Win | decomp | C++ | Grauzone | WIP | – | <https://github.com/TheIndra55/cdcEngine> |
| Chasm-Reverse | Chasm: The Rift | DOS | decomp | C++/SDL2 | GPL-3, Daten nötig | aktiv | – | <https://github.com/Panzerschrek/Chasm-Reverse> |
| CircleShootApp | Zuma Deluxe | Win | decomp | C++ | Grauzone, Daten nötig | WIP | – | <https://github.com/alula/CircleShootApp> |
| CMR2Decomp | Colin McRae Rally 2.0 | Win/PS1 | decomp | C++ | Grauzone | WIP | – | <https://github.com/CMR2Decomp/CMR2Decomp> |
| Cosmore | Cosmo's Cosmic Adventure | DOS | decomp | C | Daten nötig | stabil | – | <https://github.com/smitelli/cosmore> |
| Creatures 2 Decomp | Creatures 2 | Win | decomp | C++ | Grauzone | WIP | – | <https://github.com/xylolfrei/CREATURES-II-DECOMPILATION-PROJECT> |
| CSBwin | Dungeon Master / Chaos Strikes Back | Atari ST | decomp | C | Grauzone (geduldet) | ruhend | – | <http://dmweb.free.fr> |
| CSE2 💤 | Cave Story (Freeware 2004) | Win | decomp | C/C++ | Freeware-Daten, Code Grauzone | archiviert | inoffiziell | <https://github.com/gameblabla/CSE2> |
| dest | Stronghold (1993) | DOS | decomp | C | Grauzone | WIP | – | <https://github.com/NancyAurum/dest> |
| dethrace | Carmageddon | DOS/Win | decomp | C/SDL2 | GPL-3, Daten nötig (Demo frei) | aktiv | inoffiziell (Web/Handheld) | <https://github.com/dethrace-labs/dethrace> |
| DevilutionX (aus devilution) | Diablo / Hellfire | Win | decomp | C++/SDL2 | Decomp-Code „Unlicense“, Rechtslage Grauzone; DIABDAT.MPQ nötig (Shareware frei) | aktiv | offiziell (APK, PortMaster) | <https://github.com/diasurgical/DevilutionX> |
| Duke2Reconstructed | Duke Nukem II | DOS | decomp | C/ASM | Daten nötig (Shareware frei) | stabil | – (Schwesterprojekt RigelEngine = Reimpl.) | <https://github.com/lethal-guitar/Duke2Reconstructed> |
| F-15 SE II Reconstruction | F-15 Strike Eagle II | DOS | decomp | C/ASM | Grauzone | WIP | – | (siehe Wikipedia „reconstructed“) |
| fallout1-ce | Fallout | Win | decomp | C++/SDL2 | Sustainable Use License, Daten nötig | aktiv | offiziell (APK) | <https://github.com/alexbatalov/fallout1-ce> |
| fallout2-ce (aus fallout2-re) | Fallout 2 | Win | decomp | C++/SDL2 | Sustainable Use License, Daten nötig | aktiv | offiziell (APK, iOS) | <https://github.com/alexbatalov/fallout2-ce> |
| FlatOut-2-decomp | FlatOut 2 | Win | decomp | C++ | Grauzone | WIP | – | <https://github.com/ZackWilde27/FlatOut-2-decomp> |
| GLFrontier / JJFFE | Frontier: Elite II / First Encounters | DOS/Amiga | decomp | C | Grauzone, Daten nötig | ruhend | – | <https://github.com/pcercuei/glfrontier ?> |
| gta-reversed | GTA San Andreas | Win | decomp | C++ | Grauzone, Daten nötig | WIP | – | <https://github.com/gta-reversed/gta-reversed> |
| gta2_re | GTA 2 | Win | decomp | C++ | Grauzone, Daten nötig | WIP | – | <https://github.com/CriminalRETeam/gta2_re> |
| Halo: CE Decomp + Port | Halo: Combat Evolved | Xbox | decomp | C/SDL3/GLES3 | Xbox-Disc-Image nötig; Matching-Grad umstritten | aktiv (laut heldgames 09/2026) | **offiziell (Android arm64, Android 9+, GLES3)** | <https://github.com/punpckhdq/halo> |
| hode | Heart of Darkness | Win/PS1 | decomp | C++/SDL2 | Daten nötig | stabil | inoffiziell | <http://cyxdown.free.fr/hode/> |
| isle / isle-portable | LEGO Island | Win | decomp | C++/SDL3 | Grauzone, Daten nötig | aktiv | inoffiziell (Android-Fork mjkoo) | <https://github.com/isledecomp/isle-portable> |
| jazzjackrabbit2-decompiled | Jazz Jackrabbit 2 | Win | decomp | C++ | Grauzone (Alternative: Jazz² Resurrection = Reimpl.) | WIP | – | <https://github.com/Mustafa1177/jazzjackrabbit2-decompiled> |
| KeeperFX | Dungeon Keeper | DOS/Win | decomp | C | GPL-3, Daten nötig | aktiv | – | <https://github.com/dkfans/keeperfx> |
| libRealSpace | Strike Commander | DOS | decomp | C++ | Grauzone, Daten nötig | WIP | – | <https://github.com/fabiensanglard/libRealSpace> |
| M-HT SR (Static Recompilations) | Albion, X-COM: UFO Defense, X-COM: TFTD, Warcraft: Orcs & Humans, Septerra Core | DOS/Win | recomp | C/SDL | MIT (Recompiler), Daten nötig | aktiv | **ja (ARM Linux: Pandora/Pyra, auch Win/Linux)** | <https://github.com/M-HT/SR> |
| mafia-re | Mafia | Win | decomp | C++ | Grauzone | WIP | – | <https://github.com/Marvisak/mafia-re> |
| magic-carpet-2-hd (remc2) | Magic Carpet 2 | DOS | recomp | C++/SDL2 | Grauzone, Daten nötig | aktiv | – | <https://github.com/thobbsinteractive/magic-carpet-2-hd> |
| NBlood | Blood | DOS | decomp | C++ | GPL + Build-Lizenz, Daten nötig | aktiv | inoffiziell | <https://github.com/NBlood/NBlood> |
| Omnispeak | Commander Keen 4–6 | DOS | decomp | C99/SDL2 | GPL-2, Daten nötig (Keen 4 Shareware frei) | aktiv | – | <https://github.com/sulix/omnispeak> |
| OpenBarnyard | Barnyard | Win | decomp | C++ | Grauzone | WIP | – | <https://github.com/InfiniteC0re/OpenBarnyard> |
| openblack + bw1-decomp | Black & White | Win | decomp | C++ | GPL-3, Daten nötig | aktiv | – | <https://github.com/openblack/openblack> |
| OpenBW | StarCraft: Brood War | Win | decomp | C++ | MIT, Daten nötig | ruhend | – | <https://github.com/OpenBW/openbw> |
| OpenDUNE | Dune II | DOS | decomp | C | GPL-2, Daten nötig | ruhend | inoffiziell | <https://github.com/OpenDUNE/OpenDUNE> |
| OpenFodder | Cannon Fodder 1/2 | DOS/Amiga | decomp | C++/SDL2 | GPL-3, Daten nötig (Demo frei) | aktiv | inoffiziell | <https://github.com/OpenFodder/openfodder> |
| OpenJKDF2 | Star Wars Jedi Knight: Dark Forces II (+ MotS) | Win | decomp | C/SDL2 | 0BSD-Code, Daten nötig; Marke Lucasfilm | aktiv | – (Switch/Web/Linux) | <https://github.com/shinyquagsire23/OpenJKDF2> |
| OpenJPOG | Jurassic Park: Operation Genesis | Win | decomp | C++ | Grauzone | WIP | – | <https://github.com/AdventureT/OpenJPOG> |
| OpenLoco | Chris Sawyer's Locomotion | Win | decomp | C++ | MIT, Daten nötig | aktiv | – | <https://github.com/OpenLoco/OpenLoco> |
| OpenRCT2 | RollerCoaster Tycoon 1/2 | Win | decomp | C++ | GPL-3, Daten nötig | aktiv | offiziell (Android-Builds) | <https://github.com/OpenRCT2/OpenRCT2> |
| OpenTestDriveUnlimited | Test Drive Unlimited | Win/X360 | decomp | C++ | Grauzone | WIP | – | <https://github.com/opentestdriveunlimited/OpenTestDriveUnlimited> |
| OpenTTD 📖 [openttd](../recipes/openttd/RECIPE.md) | Transport Tycoon Deluxe | DOS | decomp | C++ | GPL-2, OpenGFX frei oder Originaldaten | aktiv | inoffiziell (APK) | <https://github.com/OpenTTD/OpenTTD> |
| otii | Oregon Trail II | Win | decomp | C | Grauzone | WIP | – | <https://github.com/katstasaph/otii> |
| PCExhumed (im NBlood-Repo) | PowerSlave / Exhumed (DOS) | DOS | decomp | C++ | GPL-2, Daten nötig | aktiv | – | <https://github.com/NBlood/NBlood> |
| Project R | San Francisco Rush: The Rock / Rush 2049 | Arcade | decomp | C++ | Arcade-Dumps nötig | aktiv | – | <https://t3hd0gg.com/project-r/> |
| raw / rawgl | Another World | DOS/Amiga | decomp | C++/SDL2 | Daten nötig | stabil | inoffiziell | <https://github.com/cyxx/rawgl> |
| re-plants-vs-zombies / PvZ-Portable-Basis | Plants vs. Zombies GOTY | Win | decomp | C++ | Grauzone, Daten nötig | aktiv | inoffiziell (u. a. eigene Quest-Basis xr.lawn) | <https://github.com/Bamcane/re-plants-vs-zombies> |
| re47 | Hitman: Codename 47 | Win | decomp | C++ | Grauzone | WIP | – | <https://github.com/0danny/re47> |
| real-war-decomp | Real War | Win | decomp | C | Grauzone | WIP | – | <https://github.com/Francessco121/real-war-decomp> |
| Rednukem (im NBlood-Repo) | Redneck Rampage / Rides Again | DOS | decomp | C++ | wie NBlood | aktiv | – | <https://github.com/NBlood/NBlood> |
| REminiscence | Flashback | DOS/Amiga | decomp | C++/SDL2 | GPL, Daten nötig | stabil | inoffiziell | <http://cyxdown.free.fr/reminiscence/> |
| SDLPoP | Prince of Persia (DOS) | DOS | decomp | C/SDL2 | GPL-3, Daten nötig | aktiv | inoffiziell | <https://github.com/NagyD/SDLPoP> |
| skifree_decomp | SkiFree | Win | decomp | C | Grauzone | stabil | – | <https://github.com/yuv422/skifree_decomp> |
| Snipes (Port) | Snipes | DOS | decomp | C/C++ | erlaubt | stabil | – | <https://github.com/Davidebyzero/Snipes> |
| SpaceCadetPinball | 3D Pinball for Windows – Space Cadet | Win | decomp | C++/SDL2 | Daten aus Windows XP nötig | stabil | inoffiziell (Android-Fork) | <https://github.com/k4zmu2a/SpaceCadetPinball> |
| StarCraft / Diablo II (Pandora) | StarCraft, Diablo II | Win | recomp | C | inoffiziell, Daten nötig | ruhend | ja (Pandora ARM) | (Pandora-Repo, siehe Wikipedia „reconstructed“) |
| swars | Syndicate Wars | DOS | decomp | C/SDL | GPL-3, Daten nötig | aktiv | – | <https://github.com/swfans/swars> |
| th06 / ReC98 | Touhou 6 / Touhou 1–5 (PC-98) | Win/PC-98 | decomp | C/C++/ASM | Grauzone (ZUN duldet Fans) | aktiv | – | <https://github.com/happyhavoc/th06> |
| TRX (TR1X / TR2X) | Tomb Raider I & II (+ Erweiterungen) | Win/DOS | source-port | C/SDL2 | Grauzone, GOG/Steam-Daten nötig | aktiv | – | <https://github.com/LostArtefacts/TRX> |

## SNES / NES / Mega Drive / GBA / DS (Decomp & Recomp) (2)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| Sonic 1/2 Disassemblies (Sonic Retro) | Sonic 1/2/3&K, Knuckles' Chaotix, Kid Chameleon | Mega Drive/32X | decomp | 68k-ASM | eigenes ROM nötig | stabil | – | <https://github.com/sonicretro> |
| SOR2 New Era (Kontext) | Streets of Rage 2 | Mega Drive | decomp | – | fanmade | aktiv | – | <https://www.sor2newera.com> |

## PlayStation 1 / PlayStation 2 (15)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| Croc / Spyro / Crash / CTR / Frogger / Twisted Metal / MediEvil / Ape Escape Decomps | diverse | PS1 | decomp | C | eigenes ISO nötig | WIP | – | <https://github.com/CharlotteCross1998/awesome-game-decompilations> |
| MediEvilRecomp | MediEvil | PS1 | recomp | C | eigenes ISO nötig | Beta | – | <https://github.com/BlackLabelHQ/MediEvilRecomp> |
| mgs_reversing | Metal Gear Solid | PS1 | decomp | C | eigenes ISO nötig | WIP | – | <https://github.com/FoxdieTeam/mgs_reversing> |
| MikuPan | Fatal Frame | PS2 | decomp | C | eigenes ISO nötig | WIP | – | <https://github.com/Mikompilation/MikuPan> |
| OpenGOAL | Jak and Daxter, Jak II, Jak 3 | PS2 | decomp | C++/GOAL | eigenes ISO nötig | aktiv (v0.3.3) | **nein** (x86-64 + AVX Pflicht) | <https://github.com/open-goal/jak-project> |
| PSXDOOM-RE | Doom (PS1) | PS1 | decomp | C | eigenes ISO nötig | stabil | – | <https://github.com/Erick194/PSXDOOM-RE> |
| PsyDoom | Doom / Final Doom (PS1) | PS1 | decomp | C++/Vulkan | eigenes ISO nötig | aktiv (v1.2 preview) | – | <https://github.com/BodbDearg/PsyDoom> |
| RecompOne / PS2Recomp (Werkzeuge) | – | PS1/PS2 | recomp | C++ | MIT/OSS | WIP | – | <https://github.com/ran-j/PS2Recomp> |
| REDRIVER2 | Driver 2 | PS1 | decomp | C/SDL2 | eigenes ISO nötig | stabil (RC2) | inoffiziell | <https://github.com/OpenDriver2/REDRIVER2> |
| Severed Chains | Legend of Dragoon | PS1 | decomp | Java | eigenes ISO nötig | aktiv | – | <https://github.com/Legend-of-Dragoon-Modding/Severed-Chains> |
| Silent Hill 1/2/3 Decomps | Silent Hill-Reihe | PS1/PS2 | decomp | C | eigenes ISO nötig | WIP–fast fertig | – | <https://github.com/Vatuu/silent-hill-decomp> |
| sly1 / Ratchet & Clank / Kingdom Hearts / SSX / Ico / SotC Decomps | diverse | PS2 | decomp | C/C++ | eigenes ISO nötig | WIP | – | <https://github.com/CharlotteCross1998/awesome-game-decompilations> |
| sotn-decomp / SymphonyRecomp | Castlevania: Symphony of the Night | PS1 | recomp | C | eigenes ISO nötig; AGPL-3 (Decomp) | WIP/Beta | – | <https://github.com/Xeeynamo/sotn-decomp> |
| soul-re | Legacy of Kain: Soul Reaver | PS1 | decomp | C | eigenes ISO nötig | WIP | – | <https://github.com/fmil95/soul-re> |
| spidey-decomp | Spider-Man (2000) | PS1/PC | decomp | C++ | eigenes ISO nötig | WIP | – | <https://github.com/krystalgamer/spidey-decomp> |

## GameCube / Wii / Original Xbox (2)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| halo (punpckhdq) | Halo: Combat Evolved | Xbox | decomp | C/SDL3 | Disc-Image nötig | aktiv | **offiziell Android arm64** | <https://github.com/punpckhdq/halo> |
| JSRF-Decompilation | Jet Set Radio Future | Xbox | decomp | C++ | eigenes Image nötig | WIP | – | <https://codeberg.org/KeybadeBlox/JSRF-Decompilation> |

## Xbox 360 – XenonRecomp / ReXGlue (19)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| AC6_recomp | Ace Combat 6 | Xbox 360 | recomp | C++ | eigenes Image nötig | spielbar | nein | <https://github.com/sal063/AC6_recomp> |
| Armored-core-ReAnswered | Armored Core: For Answer | Xbox 360 | recomp | C++ | eigenes Image nötig | WIP | nein | <https://github.com/flashfire199/Armored-core-ReAnswered> |
| band3_recomp / re-gh2 | Rock Band 3 / Guitar Hero II | Xbox 360 | recomp | C++ | eigenes Image nötig | WIP | nein | <https://github.com/ihatecompvir/band3_recomp> |
| Crackdown2-Recomp | Crackdown 2 | Xbox 360 | recomp | C++ | eigenes Image nötig | WIP | nein | <https://github.com/matty45/Crackdown2-Recomp> |
| Fable2Recomp | Fable II | Xbox 360 | recomp | C++/D3D12 | eigenes Image nötig | spielbar (laut Entwickler durchspielbar) | nein | <https://github.com/Fable2Recomp/Fable2Recomp> |
| halo3_cache_release_recomp | Halo 3 (Delta-Build) | Xbox 360 | recomp | C++ | **Prototyp-Leak** | WIP | nein | <https://github.com/twist84/halo3_cache_release_recomp> |
| KameoRePowered | Kameo: Elements of Power | Xbox 360 | recomp | C++ | eigenes Image nötig | WIP (v0.2.1) | nein | <https://github.com/birabittoh/KameoRePowered> |
| LostOdysseyRecomp | Lost Odyssey | Xbox 360 | recomp | C++ | eigenes Image nötig | spielbar (experimentell) | nein | <https://github.com/freefrank/LostOdysseyRecomp> |
| NaughtyBear_ReStuff | Naughty Bear | Xbox 360 | recomp | C++ | eigenes Image nötig | WIP (v1.5.1) | nein | <https://github.com/MaxDeadBear/NaughtyBear_ReStuff> |
| Ninja's Dawn (NG2 Recomp) | Ninja Gaiden II | Xbox 360 | recomp | C++ | eigenes Image nötig | spielbar | nein | <https://github.com/TheSaltTrader/Ninja-s-Dawn---A-Ninja-Gaiden-2-Recompilation-Project> |
| Project 2099 | Spider-Man: Edge of Time | Xbox 360 | recomp | C++/D3D12 | eigenes Image nötig | Beta | nein | (heldgames Spider-Man-Übersicht) |
| Re-Cherry | Lollipop Chainsaw | Xbox 360 | recomp | C++ | eigenes Image nötig | WIP | nein | <https://github.com/MaxDeadBear/Re-Cherry> |
| re:Blue | Blue Dragon | Xbox 360 | recomp | C++ | eigenes Image nötig | aktiv (v1.2.1) | nein | <https://github.com/zolaware/reblue> |
| reDAHM | Destroy All Humans! Path of the Furon | Xbox 360 | recomp | C++ | eigenes Image nötig | WIP | nein | <https://github.com/masterspike52/reDAHM> |
| ReXGlue SDK (Werkzeug) | – | Xbox 360 | recomp | C++ | OSS | aktiv | – | (siehe readonlymemo, ReXGlue) |
| TheSimpsonsGameRecomp | The Simpsons Game | Xbox 360 | recomp | C++ | eigenes Image nötig | aktiv (v0.0.6, Steam Deck primär) | nein (Android geplant) | <https://github.com/YesterMester/TheSimpsonsGameRecomp> |
| TiP-Recomp | Viva Piñata: Trouble in Paradise | Xbox 360 | recomp | C++ | eigenes Image nötig | aktiv (v1.13) | nein | <https://github.com/SolarCookies/TiP-Recomp> |
| UnleashedRecomp | Sonic Unleashed | Xbox 360 | recomp | C++/Vulkan/D3D12 | eigenes Disc-Image nötig | stabil (v1.0.3) | nein (x86) | <https://github.com/hedge-dev/UnleashedRecomp> |
| XenonRecomp (Werkzeug) | – | Xbox 360 | recomp | C++ | MIT | aktiv | – | <https://github.com/hedge-dev/XenonRecomp> |

## Mobile-/PC-Remaster-Decomps (RSDK u. a.) (10)

| Projekt | Originalspiel | Plattform | Art | Sprache | Lizenz/Rechtslage | Status | Android/ARM64 | URL |
|---|---|---|---|---|---|---|---|---|
| FNaF-Decomp / FlappyBird-Decomp / Cuphead-decomp / Geometry Dash | diverse Mobile/Indie | Mobile/PC | decomp | div. | Grauzone, teils aktiv laufende kommerzielle Titel | WIP | – | <https://github.com/CharlotteCross1998/awesome-game-decompilations> |
| Minecraft LCE / mcpe-engine | Minecraft Legacy Console / Pocket Edition | X360/Switch/Mobile | decomp | C++ | Mojang-Recht, Grauzone | WIP | – | <https://github.com/GRAnimated/MinecraftLCE> |
| OpenTower | Pizza Tower | Win (GameMaker) | decomp | GML | Grauzone | WIP | – | <https://github.com/femloy/OpenTower> |
| skccport | Sonic & Knuckles Collection (1997) | Win | decomp | C | eigene Daten nötig | WIP | – | <https://git.sr.ht/~benoitren/skccport> |
| Sonic 1/2 (2013) Decompilation (RSDKv4) | Sonic the Hedgehog 1 & 2 (Mobile-Remaster) | Android/iOS | decomp | C++/SDL2 | Data.rsdk aus eigener Kopie nötig | stabil | offiziell (Android), PortMaster | <https://github.com/Rubberduckycooly/Sonic-1-2-2013-Decompilation> |
| Sonic CD (2011) Decompilation (RSDKv3) | Sonic CD | Win/Mobile | decomp | C++/SDL2 | Data.rsdk nötig | stabil | offiziell (Android), PortMaster | <https://github.com/Rubberduckycooly/Sonic-CD-11-Decompilation> |
| Sonic CD (PC 1996) Decomp | Sonic CD (Gems/PC) | Win | decomp | C | eigene Daten nötig | WIP | – | <https://git.sr.ht/~benoitren/soniccddecompilation> |
| Sonic Mania Decompilation (RSDKv5) | Sonic Mania (+ Plus) | Win/Konsolen | decomp | C++/SDL2 | Data.rsdk nötig | stabil | offiziell (Android), PortMaster | <https://github.com/Rubberduckycooly/Sonic-Mania-Decompilation> |
| TerrariaOGC | Terraria (Konsolen-Fassung) | X360/Konsolen | decomp | C# | Grauzone | WIP | – | <https://github.com/PPrism/TerrariaOGC> |
| Undertale-Decomp | Undertale | Win (GameMaker) | decomp | GML | **2019 entfernt (Takedown)** | entfernt | – | (nicht mehr verfügbar) |
