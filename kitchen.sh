#!/bin/sh
# XR-Port-Kitchen – Küchenhilfe für macOS (und Linux/Git Bash) / kitchen helper for macOS.
# Braucht auf dem Mac nur Bordmittel (sh, sed, awk, osascript); anderswo python3 zum JSON-Lesen.
#
#   ./kitchen.sh                       # Assistent / guided setup (Deutsch/English)
#   ./kitchen.sh guide settlers2-rttr  # direkt ein Rezept / one recipe directly
#   ./kitchen.sh list
#   ./kitchen.sh show settlers2-rttr
#   ./kitchen.sh check settlers2-rttr --assets ~/Spiele/Siedler2 [--play]
#   ./kitchen.sh push settlers2-rttr ~/Spiele/Siedler2                 # Spieldaten auf die Quest
#   ./kitchen.sh push dos-xrshell ~/quest/1-ThemePark --app xr.island --replace
#   ./kitchen.sh push openra-redalert ra-quickinstall.zip --dry-run    # nur zeigen
#   (weitere Optionen für push: --name N, --serial S)
#   ./kitchen.sh build openttd         # App selbst bauen (holt den öffentlichen Port-Code nach Rückfrage)
#   ./kitchen.sh doctor
#   ./kitchen.sh lint                  # alle Rezepte auf Regeln prüfen
#   ./kitchen.sh publish-check ../XR-OpenRA   # Repo vor dem Veröffentlichen prüfen
#   ./kitchen.sh publish-prepare ../XR-OpenRA [<zweig>] # bereinigten Zweig xr-public erzeugen + prüfen
#   ./kitchen.sh publish ../XR-Foo --name xr.foo [--fork owner/repo]  # erstmals veröffentlichen
#   ./kitchen.sh publish ../XR-CorsixTH       # Update eines veröffentlichten Repos
#   --lang de | en                     # Sprache / language

ROOT=$(cd "$(dirname "$0")" && pwd)
PROBLEMS=0
INTERACTIVE=0
TAB=$(printf '\t')
NL='
'

if [ -z "${XR_TOOLS:-}" ] && [ -d "$ROOT/../_tools" ]; then
    XR_TOOLS=$(cd "$ROOT/../_tools" && pwd); export XR_TOOLS
fi

case "$(uname -s)" in
    Darwin) OS=macos ;;
    MINGW*|MSYS*|CYGWIN*) OS=windows ;;
    *) OS=macos ;;   # Linux: macOS-Kandidaten sind die nächstliegenden
esac

if [ -t 1 ]; then
    C_OK=$(printf '\033[32m'); C_BAD=$(printf '\033[31m'); C_WARN=$(printf '\033[33m')
    C_DIM=$(printf '\033[90m'); C_HEAD=$(printf '\033[36m'); C_END=$(printf '\033[0m')
else
    C_OK=; C_BAD=; C_WARN=; C_DIM=; C_HEAD=; C_END=
fi

# --- JSON lesen -----------------------------------------------------------

flatten() {
    if [ "$(uname -s)" = Darwin ]; then
        osascript -l JavaScript "$ROOT/runner/flatten.js" "$1"
    else
        _fl_f=$1
        command -v cygpath >/dev/null 2>&1 && _fl_f=$(cygpath -m "$1")
        for _fl_py in python3 python; do
            if "$_fl_py" -c "import json" >/dev/null 2>&1; then
                "$_fl_py" "$ROOT/runner/flatten.py" "$_fl_f" | tr -d '\r'
                return
            fi
        done
        echo "python3 fehlt / missing (nur außerhalb von macOS nötig)" >&2
        exit 3
    fi
}

# jv <flach> <pfad>  → Wert
jv() { printf '%s\n' "$1" | awk -F "$TAB" -v k="$2" '$1 == k { sub(/^[^\t]*\t/, ""); print; exit }'; }
# jn <flach> <pfad>  → Anzahl Elemente eines Arrays (0, wenn nicht vorhanden)
jn() { _jn_n=$(jv "$1" "$2.#"); echo "${_jn_n:-0}"; }

# --- Sprache / language ---------------------------------------------------
# Reihenfolge: --lang, KITCHEN_LANG, gemerkte Wahl (~/.xr-kitchen/lang), Systemsprache

LANG_FILE="$HOME/.xr-kitchen/lang"
KLANG=""
LANG_CHOSEN=0
for _a in "$@"; do
    case "$_prev" in --lang) KLANG=$_a ;; esac
    _prev=$_a
done
[ -z "$KLANG" ] && KLANG=${KITCHEN_LANG:-}
[ -z "$KLANG" ] && [ -f "$LANG_FILE" ] && KLANG=$(tr -d ' \r\n' < "$LANG_FILE")
case "$KLANG" in de|en) LANG_CHOSEN=1 ;; *) case "${LANG:-}" in de*) KLANG=de ;; *) KLANG=en ;; esac ;; esac

save_lang() { mkdir -p "$(dirname "$LANG_FILE")" 2>/dev/null && printf '%s\n' "$KLANG" > "$LANG_FILE"; }

# Downloads der Küchenhilfe (Platform-Tools) landen nur im Kitchen-Ordner
KITCHEN_TOOLS="$ROOT/.kitchen-tools"; export KITCHEN_TOOLS
KCFG=$(flatten "$ROOT/kitchen.json")

STR=$(flatten "$ROOT/i18n/strings.json")

# subst <text> <muster> <ersatz>  – wörtliches Ersetzen aller Vorkommen
subst() {
    _sb_s=$1; _sb_o=""
    while :; do
        case "$_sb_s" in
            *"$2"*) _sb_o="$_sb_o${_sb_s%%"$2"*}$3"; _sb_s=${_sb_s#*"$2"} ;;
            *) break ;;
        esac
    done
    printf '%s' "$_sb_o$_sb_s"
}

# T <schlüssel> [argumente …]  – Text in der gewählten Sprache, {0} {1} … ersetzt
T() {
    _t_k=$1; shift
    _t_s=$(jv "$STR" "$_t_k.$KLANG"); [ -z "$_t_s" ] && _t_s=$(jv "$STR" "$_t_k.de"); [ -z "$_t_s" ] && _t_s=$_t_k
    _t_i=0
    for _t_a in "$@"; do
        _t_s=$(subst "$_t_s" "{$_t_i:N1}" "$_t_a")
        _t_s=$(subst "$_t_s" "{$_t_i}" "$_t_a")
        _t_i=$((_t_i + 1))
    done
    printf '%s' "$_t_s"
}

# RT <flach> <pfad>  – Rezepttext; pfad_en, wenn Englisch gewählt und vorhanden
RT() {
    if [ "$KLANG" = en ]; then _rt_v=$(jv "$1" "$2_en"); [ -n "$_rt_v" ] && { printf '%s' "$_rt_v"; return; }; fi
    jv "$1" "$2"
}

ok()   { printf '  %s[%s]%s    %s\n' "$C_OK" "$(T t_ok)" "$C_END" "$1"; }
bad()  { printf '  %s[%s]%s %s\n' "$C_BAD" "$(T t_missing)" "$C_END" "$1"; PROBLEMS=$((PROBLEMS + 1)); }
warn() { printf '  %s[?]%s     %s\n' "$C_WARN" "$C_END" "$1"; }
hint() { printf '          %s→ %s%s\n' "$C_DIM" "$1" "$C_END"; }

ask_yes() {
    printf '%s %s ' "$1" "$(T yn)"; read -r _ay
    case "$_ay" in [jJyY]*) return 0 ;; *) return 1 ;; esac
}

# ask_path <frage>  – liest einen Pfad (Finder-Drag&Drop: Anführungszeichen und "\ " werden bereinigt)
ask_path() {
    printf '%s: ' "$1" >&2; read -r _ap   # Frage auf stderr, sonst landet sie im $(…)-Ergebnis
    printf '%s' "$_ap" | sed "s/^[\"' ]*//; s/[\"' ]*$//; s/\\\\ / /g"
}

stars() { _st_s=""; _st_i=1; while [ $_st_i -le 5 ]; do if [ $_st_i -le "${1:-0}" ]; then _st_s="$_st_s★"; else _st_s="$_st_s☆"; fi; _st_i=$((_st_i + 1)); done; printf '%s' "$_st_s"; }

recipe_ids() { for _ri in "$ROOT"/recipes/*/; do [ -f "$_ri/recipe.json" ] && basename "$_ri"; done; }

load_recipe() {
    if [ -z "$1" ] || [ ! -f "$ROOT/recipes/$1/recipe.json" ]; then
        echo "Rezept/recipe '$1' ?"; recipe_ids | sed 's/^/  /'; exit 2
    fi
    R=$(flatten "$ROOT/recipes/$1/recipe.json")
}

# --- Versionen ------------------------------------------------------------

# ver_cmp a b → -1/0/1
ver_cmp() {
    awk -v a="$1" -v b="$2" 'BEGIN {
        na = split(a, x, /[._-]/); nb = split(b, y, /[._-]/); n = na > nb ? na : nb
        for (i = 1; i <= n; i++) { p = (i <= na) ? x[i] + 0 : 0; q = (i <= nb) ? y[i] + 0 : 0
            if (p < q) { print -1; exit } if (p > q) { print 1; exit } }
        print 0 }'
}

ver_prefix() {
    awk -v a="$1" -v b="$2" 'BEGIN {
        na = split(a, x, /[._-]/); nb = split(b, y, /[._-]/)
        if (na < nb) { print 0; exit }
        for (i = 1; i <= nb; i++) if (x[i] + 0 != y[i] + 0) { print 0; exit }
        print 1 }'
}

# ver_ok version min pin → Exit 0 wenn passend
ver_ok() {
    if [ -z "$1" ]; then [ -z "$2" ] && [ -z "$3" ]; return; fi
    if [ -n "$2" ] && [ "$(ver_cmp "$1" "$2")" = "-1" ]; then return 1; fi
    if [ -n "$3" ] && [ "$(ver_prefix "$1" "$3")" = "0" ]; then return 1; fi
    return 0
}

# extract_ver <text> <regex>  (erste Gruppe)
extract_ver() {
    [ -z "$2" ] && return
    _ev_rx=$(printf '%s' "$2" | sed 's/\\s/[[:space:]]/g')
    case "$_ev_rx" in
        ^*) printf '%s\n' "$1" | sed -nE "s/${_ev_rx}.*/\\1/p" | head -n 1 ;;
        *)  printf '%s\n' "$1" | sed -nE "s/.*${_ev_rx}.*/\\1/p" | head -n 1 ;;
    esac
}

# --- Werkzeugprüfung ------------------------------------------------------

# expand_candidate <text> → expandierter Pfad, leer wenn eine Variable fehlt
expand_candidate() {
    _ec_c=$1
    for _ec_v in $(printf '%s' "$_ec_c" | grep -oE '%[A-Za-z_][A-Za-z0-9_]*%|\$[A-Za-z_][A-Za-z0-9_]*' | tr -d '%$'); do
        eval "_ec_val=\${$_ec_v:-}"
        [ -z "$_ec_val" ] && return
        [ "$OS" = windows ] && command -v cygpath >/dev/null 2>&1 && _ec_val=$(cygpath -u "$_ec_val")
        _ec_c=$(printf '%s' "$_ec_c" | sed "s#%$_ec_v%#$_ec_val#g; s#\\\$$_ec_v#$_ec_val#g")
    done
    [ "$OS" = windows ] && _ec_c=$(printf '%s' "$_ec_c" | tr '\\' '/')
    printf '%s' "$_ec_c"
}

# find_installs <flach-tool> → Zeilen "pfad<TAB>version"
find_installs() {
    TOOL=$1
    _fi_kind=$(jv "$TOOL" "check.$OS.kind"); _fi_args=$(jv "$TOOL" "check.$OS.args")
    _fi_vfile=$(jv "$TOOL" "check.$OS.version_file"); _fi_vrx=$(jv "$TOOL" "check.$OS.version_regex")
    _fi_n=$(jn "$TOOL" "check.$OS.candidates"); _fi_i=0; _fi_seen=""
    while [ $_fi_i -lt "$_fi_n" ]; do
        _fi_e=$(expand_candidate "$(jv "$TOOL" "check.$OS.candidates.$_fi_i")"); _fi_i=$((_fi_i + 1))
        [ -z "$_fi_e" ] && continue
        if [ "$_fi_kind" = dir ]; then
            # shellcheck disable=SC2086
            for _fi_d in $(ls -d $_fi_e 2>/dev/null | sort -r); do
                [ -d "$_fi_d" ] || continue
                _fi_ver=""
                [ -n "$_fi_vfile" ] && [ -f "$_fi_d/$_fi_vfile" ] && _fi_ver=$(extract_ver "$(cat "$_fi_d/$_fi_vfile")" "$_fi_vrx")
                printf '%s\t%s\n' "$_fi_d" "$_fi_ver"
            done
        else
            case "$_fi_e" in
                */*) [ -f "$_fi_e" ] || continue; _fi_exe=$_fi_e ;;
                *) _fi_exe=$(command -v "$_fi_e" 2>/dev/null) || continue ;;
            esac
            case "$_fi_seen" in *"|$_fi_exe|"*) continue ;; esac
            _fi_seen="$_fi_seen|$_fi_exe|"
            # shellcheck disable=SC2086
            _fi_out=$("$_fi_exe" $_fi_args 2>&1)
            printf '%s\t%s\n' "$_fi_exe" "$(extract_ver "$_fi_out" "$_fi_vrx")"
        fi
    done
}

find_adb() { find_installs "$(flatten "$ROOT/tools/adb.json")" | head -n 1 | cut -f 1; }

# check_tool <id> [min] [pin]
check_tool() {
    _ct_id=$1; _ct_min=$2; _ct_pin=$3
    if [ ! -f "$ROOT/tools/$_ct_id.json" ]; then warn "$(T tool_nodef "$_ct_id")"; return; fi
    _ct_t=$(flatten "$ROOT/tools/$_ct_id.json")
    _ct_name=$(jv "$_ct_t" name)
    [ -z "$_ct_min" ] && _ct_min=$(jv "$_ct_t" min_version)
    [ -z "$_ct_pin" ] && _ct_pin=$(jv "$_ct_t" version)
    _ct_need=""
    [ -n "$_ct_pin" ] && _ct_need=$(T need_version "$_ct_pin")
    [ -n "$_ct_min" ] && _ct_need="${_ct_need:+$_ct_need, }$(T need_min "$_ct_min")"
    [ -n "$_ct_need" ] && _ct_need=" ($_ct_need)"
    _ct_inst=$(find_installs "$_ct_t")
    _ct_good=""; _ct_all=""
    while IFS="$TAB" read -r _ct_p _ct_v; do
        [ -z "$_ct_p" ] && continue
        _ct_all="${_ct_all:+$_ct_all, }${_ct_v:-?}"
        if [ -z "$_ct_good" ] && ver_ok "$_ct_v" "$_ct_min" "$_ct_pin"; then _ct_good="$_ct_p$TAB$_ct_v"; fi
    done <<EOF
$_ct_inst
EOF
    if [ -n "$_ct_good" ]; then
        _ct_gp=${_ct_good%%"$TAB"*}; _ct_gv=${_ct_good#*"$TAB"}
        ok "$_ct_name${_ct_gv:+ $_ct_gv}  [$_ct_gp]"
    elif [ -n "$_ct_all" ]; then
        bad "$(T tool_unfit "$_ct_name" "$_ct_need" "$_ct_all")"; hint "$(jv "$_ct_t" "install.$OS")"
    else
        bad "$(T tool_missing "$_ct_name" "$_ct_need")"; hint "$(jv "$_ct_t" "install.$OS")"
    fi
}

# check_recipe_tools <play 0|1>
check_recipe_tools() {
    _rt_i=0; _rt_n=$(jn "$R" tools)
    while [ $_rt_i -lt "$_rt_n" ]; do
        _rt_tid=$(jv "$R" "tools.$_rt_i.id")
        if [ -z "$_rt_tid" ]; then
            check_tool "$(jv "$R" "tools.$_rt_i")" "" ""
        elif [ "$1" = 1 ] && [ "$(jv "$R" "tools.$_rt_i.only_for")" = build ]; then
            :
        else
            check_tool "$_rt_tid" "$(jv "$R" "tools.$_rt_i.min_version")" "$(jv "$R" "tools.$_rt_i.version")"
        fi
        _rt_i=$((_rt_i + 1))
    done
}

# --- Quest und Zutaten ----------------------------------------------------

check_quest() {
    _cq_adb=$(find_adb)
    if [ -z "$_cq_adb" ]; then bad "$(T quest_no_adb)"; return; fi
    _cq_out=$("$_cq_adb" devices -l 2>/dev/null | tr -d '\r')
    _cq_lines=$(printf '%s\n' "$_cq_out" | grep -E '^[^ ]+[[:space:]]+device( |$)')
    if [ -n "$_cq_lines" ]; then
        while read -r _cq_serial _ _cq_rest; do
            _cq_model=$(printf '%s' "$_cq_rest" | sed -nE 's/.*model:([^ ]+).*/\1/p')
            ok "$(T quest_ok "${_cq_model:-?}" "$_cq_serial")"
        done <<EOF
$_cq_lines
EOF
    elif printf '%s\n' "$_cq_out" | grep -q unauthorized; then
        bad "$(T quest_unauth)"; hint "$(T quest_unauth_hint)"
    else
        bad "$(T quest_none)"; hint "$(T quest_none_hint)"
    fi
}

check_assets() {
    _ca_dir=$1
    _ca_nr=$(jn "$R" ingredients.original_assets.required); _ca_na=$(jn "$R" ingredients.original_assets.any_of)
    _ca_hint=$(RT "$R" ingredients.original_assets.hint)
    if [ "$_ca_nr" = 0 ] && [ "$_ca_na" = 0 ]; then
        ok "$(T assets_none)"; [ -n "$_ca_hint" ] && hint "$_ca_hint"; return
    fi
    if [ -z "$_ca_dir" ]; then
        warn "$(T assets_skip)"; [ -n "$_ca_hint" ] && hint "$_ca_hint"; return
    fi
    if [ ! -d "$_ca_dir" ]; then bad "$(T assets_nodir "$_ca_dir")"; return; fi
    _ca_i=0
    while [ $_ca_i -lt "$_ca_nr" ]; do
        _ca_f=$(jv "$R" "ingredients.original_assets.required.$_ca_i"); _ca_i=$((_ca_i + 1))
        if [ -e "$_ca_dir/$_ca_f" ]; then ok "$(T assets_item "$_ca_f")"; else bad "$(T assets_item "$_ca_f")"; fi
    done
    _ca_g=0
    while [ $_ca_g -lt "$_ca_na" ]; do
        _ca_m=$(jn "$R" "ingredients.original_assets.any_of.$_ca_g"); _ca_j=0; _ca_hit=""; _ca_names=""
        while [ $_ca_j -lt "$_ca_m" ]; do
            _ca_f=$(jv "$R" "ingredients.original_assets.any_of.$_ca_g.$_ca_j"); _ca_j=$((_ca_j + 1))
            _ca_names="${_ca_names:+$_ca_names | }$_ca_f"
            [ -z "$_ca_hit" ] && [ -e "$_ca_dir/$_ca_f" ] && _ca_hit=$_ca_f
        done
        if [ -n "$_ca_hit" ]; then ok "$(T assets_item "$_ca_hit")"; else bad "$(T assets_oneof "$_ca_names")"; fi
        _ca_g=$((_ca_g + 1))
    done
}

# --- Befehle: Liste, Anzeige, Prüfung --------------------------------------

cmd_list() {
    echo
    printf '%-24s %-12s %-7s %-7s %s\n' Rezept/recipe Stand Port. XR Titel
    for _cl_id in $(recipe_ids); do
        load_recipe "$_cl_id"
        printf '%-24s %-12s %s   %s   %s\n' "$_cl_id" "$(jv "$R" status)" \
            "$(stars "$(jv "$R" ratings.portability)")" "$(stars "$(jv "$R" ratings.xr_potential)")" "$(RT "$R" title)"
    done
    echo
}

cmd_show() {
    load_recipe "$1"
    echo
    printf '%s%s%s\n' "$C_HEAD" "$(RT "$R" title)" "$C_END"
    _cs_lv=$(jv "$R" last_verified)
    echo "Stand: $(jv "$R" status)${_cs_lv:+ – zuletzt geprüft $_cs_lv}"
    [ -n "$(jv "$R" app.id)" ] && echo "App: $(jv "$R" app.id)  Version $(jv "$R" app.version)"
    echo
    echo "Portierbarkeit  $(stars "$(jv "$R" ratings.portability)")   XR-Potenzial $(stars "$(jv "$R" ratings.xr_potential)")   Reife der Basis $(stars "$(jv "$R" ratings.base_maturity)")"
    _cs_note=$(jv "$R" ratings.note); [ -n "$_cs_note" ] && printf '  %s%s%s\n' "$C_DIM" "$_cs_note" "$C_END"
    echo "Aufwand: mit fertiger APK $(jv "$R" effort.with_apk) · aus dem Quellcode $(jv "$R" effort.from_source)"
    echo
    echo "Spiel: $(jv "$R" game.name) ($(jv "$R" game.rights_holder))"
    echo "Aufbauend auf:"
    _cs_i=0; _cs_n=$(jn "$R" base)
    while [ $_cs_i -lt "$_cs_n" ]; do
        echo "  $(jv "$R" "base.$_cs_i.name") [$(jv "$R" "base.$_cs_i.license")] $(jv "$R" "base.$_cs_i.url")"; _cs_i=$((_cs_i + 1))
    done
    echo
    echo "XR-Modi:"
    for _cs_m in screen passthrough tabletop diorama full-vr; do
        _cs_v=$(jv "$R" "xr_modes.$_cs_m"); [ -n "$_cs_v" ] && printf '  %-12s %s\n' "$_cs_m" "$_cs_v"
    done
    echo
    echo "Stufen:"
    _cs_i=0; _cs_n=$(jn "$R" stages)
    while [ $_cs_i -lt "$_cs_n" ]; do
        case "$(jv "$R" "stages.$_cs_i.status")" in done) _cs_mk="[x]" ;; blocked) _cs_mk="[!]" ;; n/a) _cs_mk="[-]" ;; *) _cs_mk="[ ]" ;; esac
        echo "  $_cs_mk $(jv "$R" "stages.$_cs_i.id")  $(jv "$R" "stages.$_cs_i.title")"; _cs_i=$((_cs_i + 1))
    done
    echo
    printf '%sDetails: recipes/%s/RECIPE.md%s\n' "$C_DIM" "$1" "$C_END"
}

cmd_check() {
    _ck_id=$1; _ck_assets=$2; _ck_play=$3
    load_recipe "$_ck_id"
    PROBLEMS=0
    echo
    printf '%s%s%s\n\n' "$C_HEAD" "$(T check_title "$(RT "$R" title)")" "$C_END"
    if [ "$_ck_play" = 1 ]; then T check_tools_play; else T check_tools; fi; echo
    check_recipe_tools "$_ck_play"
    echo; T check_assets; echo; check_assets "$_ck_assets"
    echo; T check_quest; echo; check_quest
    echo
    if [ "$PROBLEMS" = 0 ]; then printf '%s%s%s\n' "$C_OK" "$(T check_ok "recipes/$_ck_id/RECIPE.md")" "$C_END"
    else printf '%s%s%s\n' "$C_WARN" "$(T check_open "$PROBLEMS")" "$C_END"; fi
}

cmd_doctor() {
    PROBLEMS=0
    echo; printf '%s%s%s\n' "$C_HEAD" "$(T menu_doctor)" "$C_END"
    for _cd_f in "$ROOT"/tools/*.json; do check_tool "$(basename "$_cd_f" .json)" "" ""; done
    echo; T check_quest; echo; check_quest; echo
}

# --- Spieldaten übertragen (push) -----------------------------------------
# Immer genau EINE Datei per adb push (Ordner-Push bricht unter Windows ab), dazu ein kleines
# Gerätescript, das entpackt, Rechte setzt und die Prüfdateien kontrolliert. Für App-eigenen
# Speicher (run_as) läuft das Script per run-as als die App.

TMP_PKG=/data/local/tmp/kitchen-push

die() { printf '%s%s%s%s\n' "$C_BAD" "$(T e_prefix)" "$1" "$C_END" >&2; exit 1; }
safe_name() { printf '%s' "$1" | grep -Eq '^[A-Za-z0-9._+-]+$'; }
safe_path() { printf '%s' "$1" | grep -Eq '^[A-Za-z0-9._/+-]+$'; }

sha1_of() {
    if command -v shasum >/dev/null 2>&1; then shasum -a 1 "$1" | cut -d ' ' -f 1
    else sha1sum "$1" | cut -d ' ' -f 1; fi
}

# adb_run <args…> – mit Seriennummer; Git Bash darf /sdcard/… nicht umschreiben
adb_run() { MSYS_NO_PATHCONV=1 "$ADB_BIN" ${P_SERIAL:+-s "$P_SERIAL"} "$@"; }
local_path() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }

# select_device <rezept-id> – prüft adb und genau ein Gerät (oder --serial)
select_device() {
    ADB_BIN=$(find_adb)
    [ -n "$ADB_BIN" ] || die "$(T e_noadb)"
    if [ -z "$P_SERIAL" ]; then
        _sd_devs=$("$ADB_BIN" devices | tr -d '\r' | awk '$2 == "device" { print $1 }')
        _sd_cnt=$(printf '%s' "$_sd_devs" | grep -c . || true)
        [ "$_sd_cnt" -gt 0 ] || die "$(T e_nodevice "$1")"
        [ "$_sd_cnt" -eq 1 ] || die "$(T e_multidevice "$(echo $_sd_devs)")"
    fi
}

# cmd_push <id> <quelle> – Rückgabe 1, wenn der Nutzer das Ersetzen ablehnt
cmd_push() {
    _p_id=$1; _p_src=$2
    load_recipe "$_p_id"
    _p_spec=$(jv "$R" ingredients.push.target)
    [ -n "$_p_spec" ] || die "$(T e_nospec "$_p_id")"
    [ -n "$_p_src" ] || die "$(T e_nosrc "$_p_id")"
    [ -e "$_p_src" ] || die "$(T e_srcmissing "$_p_src")"
    _p_src=$(cd "$(dirname "$_p_src")" && pwd)/$(basename "$_p_src")

    _p_leaf=$(basename "$_p_src")
    _p_ext=$(printf '%s' "${_p_leaf##*.}" | tr 'A-Z' 'a-z'); [ "$_p_ext" = "$_p_leaf" ] && _p_ext=""
    if [ -d "$_p_src" ]; then _p_kind=dir; elif [ "$_p_ext" = zip ] || [ "$_p_ext" = tar ]; then _p_kind=archive; else _p_kind=file; fi
    _p_want=$(jv "$R" ingredients.push.source)
    if [ -n "$_p_want" ] && [ "$_p_want" != "$_p_kind" ]; then die "$(T e_kind "$(T "kind_$_p_want")")"; fi

    _p_app=${P_APP:-$(jv "$R" app.id)}
    _p_nm=${P_NAME:-$_p_leaf}
    _p_target=$(subst "$(subst "$_p_spec" "{app}" "$_p_app")" "{name}" "$_p_nm")
    case "$_p_spec" in *"{name}"*) safe_name "$_p_nm" || die "$(T e_name "$_p_nm")" ;; esac
    [ -z "$_p_app" ] || safe_name "$_p_app" || die "$(T e_appid "$_p_app")"
    safe_path "$_p_target" || die "$(T e_target_chars "$_p_target")"
    _p_runas=0; [ "$(jv "$R" ingredients.push.run_as)" = true ] && _p_runas=1
    [ $_p_runas = 0 ] || [ -n "$_p_app" ] || die "$(T e_runas_noapp)"
    [ "$_p_kind" != file ] || safe_name "$_p_leaf" || die "$(T e_filename "$_p_leaf")"

    # Schutz vor zu flachen Zielen (rm -rf beim Ersetzen)
    _p_depth=$(printf '%s' "$_p_target" | sed 's#^/##; s#/$##' | awk -F / '{ print NF }')
    if [ "$_p_kind" != file ]; then
        case "$_p_target" in
            /*) case "${_p_target%/}" in
                    /sdcard|/sdcard/Download|/sdcard/Android|/sdcard/Android/data|/sdcard/DCIM|/sdcard/Movies|/sdcard/Pictures|/sdcard/Music|/sdcard/Documents|/sdcard/Oculus)
                        die "$(T e_shallow "$_p_target")" ;;
                esac
                [ "$_p_depth" -ge 3 ] || die "$(T e_shallow "$_p_target")" ;;
            *) [ "$_p_depth" -ge 2 ] || die "$(T e_shallow "$_p_target")" ;;
        esac
    fi

    _p_sha=$(jv "$R" ingredients.push.source_sha1)
    if [ -n "$_p_sha" ] && [ "$_p_kind" != dir ]; then
        _p_h=$(sha1_of "$_p_src")
        [ "$_p_h" = "$(printf '%s' "$_p_sha" | tr 'A-F' 'a-f')" ] || die "$(T e_sha "$_p_h" "$_p_sha")"
        ok "$(T p_sha_ok)"
    fi
    _p_ninc=$(jn "$R" ingredients.push.include); _p_incs=""
    if [ "$_p_kind" = dir ]; then
        _p_k=0
        while [ $_p_k -lt "$_p_ninc" ]; do
            _p_inc=$(jv "$R" "ingredients.push.include.$_p_k"); _p_k=$((_p_k + 1))
            [ -e "$_p_src/$_p_inc" ] || die "$(T e_include "$_p_src" "$_p_inc")"
            _p_incs="${_p_incs:+$_p_incs, }$_p_inc"
        done
    fi

    if [ "$_p_kind" = file ]; then _p_rcheck="$_p_target/$_p_leaf"; else _p_rcheck=$_p_target; fi
    case "$_p_kind" in dir) _p_pext=.tar ;; archive) _p_pext=".$_p_ext" ;; *) _p_pext=.bin ;; esac
    _p_rpkg="$TMP_PKG$_p_pext"

    # --- Gerätescript (mksh/toybox) ---
    _p_script="T='$_p_target'${NL}P='$_p_rpkg'"
    padd() { _p_script="$_p_script$NL$1"; }
    padd 'case "$T" in /*) ;; *) T="$PWD/$T" ;; esac'   # run-as: relativ zum App-Datenordner
    if [ "$_p_kind" = file ]; then
        padd 'mkdir -p "$T" || exit 4'
        padd "rm -f \"\$T/$_p_leaf\""
        padd "cp \"\$P\" \"\$T/$_p_leaf\" || exit 5"
    else
        padd 'rm -rf "$T"'
        padd 'mkdir -p "$T" || exit 4'
        padd 'cd "$T" || exit 4'
        if [ "$_p_ext" = zip ]; then padd 'unzip -o -q "$P" -d . || exit 5'; else padd 'tar -xf "$P" || exit 5'; fi
    fi
    if [ $_p_runas = 0 ]; then
        padd 'd="$T"; while case "$d" in /sdcard/Android/data/?*) true ;; *) false ;; esac; do chmod 0777 "$d" 2>/dev/null; d="${d%/*}"; done'
        if [ "$_p_kind" = file ]; then padd "chmod a+r \"\$T/$_p_leaf\" 2>/dev/null"; else padd 'chmod -R a+rX "$T" 2>/dev/null'; fi
    fi
    padd 'fail=0'
    _p_checks=""
    [ "$_p_kind" = file ] && _p_checks=$_p_leaf
    _p_nv=$(jn "$R" ingredients.push.verify); _p_k=0
    while [ $_p_k -lt "$_p_nv" ]; do _p_checks="$_p_checks$NL$(jv "$R" "ingredients.push.verify.$_p_k")"; _p_k=$((_p_k + 1)); done
    for _p_v in $_p_checks; do
        safe_path "$_p_v" || die "$(T e_verify_chars "$_p_v")"
        padd "if [ -e \"\$T/$_p_v\" ]; then echo \"KITCHEN_OK $_p_v\"; else echo \"KITCHEN_MISSING $_p_v\"; fail=1; fi"
    done
    [ "$_p_kind" != file ] && padd 'echo KITCHEN_LS; ls "${T%/*}"'
    padd '[ $fail = 0 ] || exit 6'

    echo
    printf '%s%s%s\n' "$C_HEAD" "$(T p_title "$(RT "$R" title)")" "$C_END"
    T p_source "$_p_src" "$_p_kind"; echo
    if [ $_p_runas = 1 ]; then _p_where=$(T p_appstore "$_p_app"); else _p_where=""; fi
    if [ "$_p_kind" = file ]; then T p_target "$_p_where$_p_target/$_p_leaf"; else T p_target "$_p_where$_p_target"; fi; echo
    [ -n "$_p_incs" ] && { T p_selection "$_p_incs"; echo; }

    if [ "${P_DRY:-0}" = 1 ]; then
        echo; printf '%s%s%s\n' "$C_WARN" "$(T p_dry)" "$C_END"
        printf '%s%s%s\n' "$C_DIM" "$_p_script" "$C_END"
        return 0
    fi

    select_device "$_p_id"
    if [ $_p_runas = 1 ]; then _p_prefix="run-as $_p_app "; else _p_prefix=""; fi
    _p_ex=$(adb_run shell "${_p_prefix}test -e $_p_rcheck && echo KITCHEN_EXISTS" 2>&1 | tr -d '\r')
    if [ $_p_runas = 1 ] && printf '%s' "$_p_ex" | grep -Eq 'not debuggable|unknown package|is unknown'; then
        die "$(T e_runas "$_p_app")"
    fi
    if printf '%s' "$_p_ex" | grep -q KITCHEN_EXISTS && [ "${P_REPLACE:-0}" != 1 ]; then
        [ "$INTERACTIVE" = 1 ] || die "$(T e_exists "$_p_rcheck")"
        ask_yes "$(T g_push_replace "$_p_rcheck")" || return 1
    fi

    _p_tmp=$(mktemp -d)
    trap 'rm -rf "$_p_tmp"' EXIT
    _p_pkg=$_p_src
    if [ "$_p_kind" = dir ]; then
        _p_pkg=$_p_tmp/push.tar
        T p_packing; echo
        set --
        _p_ne=$(jn "$R" ingredients.push.exclude); _p_k=0
        while [ $_p_k -lt "$_p_ne" ]; do set -- "$@" "--exclude=$(jv "$R" "ingredients.push.exclude.$_p_k")"; _p_k=$((_p_k + 1)); done
        if [ "$_p_ninc" -gt 0 ]; then
            _p_k=0; while [ $_p_k -lt "$_p_ninc" ]; do set -- "$@" "$(jv "$R" "ingredients.push.include.$_p_k")"; _p_k=$((_p_k + 1)); done
        else
            set -- "$@" .
        fi
        COPYFILE_DISABLE=1 tar --format ustar -C "$_p_src" -cf "$_p_pkg" "$@" || die "$(T e_tar "")"
    fi
    _p_size=$(wc -c < "$_p_pkg" | tr -d ' ')
    T p_size "$(awk -v s="$_p_size" 'BEGIN { printf "%.1f", s / 1048576 }')"; echo
    printf '%s\n' "$_p_script" > "$_p_tmp/push.sh"

    T p_copying; echo
    adb_run push "$(local_path "$_p_pkg")" "$_p_rpkg" >/dev/null || die "$(T e_adbpush "")"
    adb_run push "$(local_path "$_p_tmp/push.sh")" "$TMP_PKG.sh" >/dev/null || die "$(T e_adbpush "")"
    adb_run shell "chmod 644 $_p_rpkg $TMP_PKG.sh" >/dev/null 2>&1

    T p_extracting; echo
    _p_out=$(adb_run shell "${_p_prefix}sh $TMP_PKG.sh" 2>&1); _p_code=$?
    adb_run shell "rm -f $_p_rpkg $TMP_PKG.sh" >/dev/null 2>&1

    echo
    _p_listing=0
    while IFS= read -r _p_line; do
        case "$_p_line" in
            KITCHEN_OK\ *) ok "$(T p_on_quest "${_p_line#KITCHEN_OK }")" ;;
            KITCHEN_MISSING\ *) printf '  %s[%s]%s %s\n' "$C_BAD" "$(T t_missing)" "$C_END" "$(T p_on_quest "${_p_line#KITCHEN_MISSING }")" ;;
            KITCHEN_LS) _p_listing=1; T p_listing "${_p_target%/*}"; echo ;;
            "") ;;
            *) if [ $_p_listing = 1 ]; then echo "  $_p_line"; else printf '  %s%s%s\n' "$C_DIM" "$_p_line" "$C_END"; fi ;;
        esac
    done <<EOF
$(printf '%s\n' "$_p_out" | tr -d '\r')
EOF
    case $_p_code in
        0) printf '%s%s%s\n' "$C_OK" "$(T p_done)" "$C_END"; _p_note=$(RT "$R" ingredients.push.note); [ -n "$_p_note" ] && echo "$_p_note" ;;
        4) die "$(T e_mkdir)" ;;
        5) die "$(T e_unpack)" ;;
        6) die "$(T e_verify)" ;;
        *) die "$(T e_code "$_p_code")" ;;
    esac
    return 0
}

# --- Nachladen (nur nach Rückfrage) ----------------------------------------

# download <url> <ziel>
download() {
    mkdir -p "$(dirname "$2")"
    printf '%s%s%s\n' "$C_DIM" "$(T dl_downloading "$1")" "$C_END"
    if curl -fL --progress-bar -o "$2" "$1"; then return 0; fi
    printf '%s%s%s\n' "$C_BAD" "$(T dl_fail "$1")" "$C_END"; rm -f "$2"; return 1
}

# Android Platform-Tools (adb) von Google in den Kitchen-Ordner laden
install_platform_tools() {
    ask_yes "$(T dl_adb_offer "$(jv "$KCFG" platform_tools.terms)")" || return 1
    _ip_zip="$KITCHEN_TOOLS/platform-tools.zip"
    download "$(jv "$KCFG" "platform_tools.$OS")" "$_ip_zip" || return 1
    unzip -q -o "$_ip_zip" -d "$KITCHEN_TOOLS" && rm -f "$_ip_zip"
    if [ -e "$KITCHEN_TOOLS/platform-tools/adb" ] || [ -e "$KITCHEN_TOOLS/platform-tools/adb.exe" ]; then
        ok "$(T dl_done "$KITCHEN_TOOLS/platform-tools")"; return 0
    fi
    printf '%s%s%s\n' "$C_BAD" "$(T dl_fail "$KITCHEN_TOOLS/platform-tools")" "$C_END"; return 1
}

# Kitchen selbst aktualisieren: per git (wenn ein Klon) oder als ZIP von GitHub
self_update() {
    _su_repo=$(jv "$KCFG" repo); _su_branch=$(jv "$KCFG" branch)
    ask_yes "$(T upd_offer "$_su_repo")" || return
    if [ -d "$ROOT/.git" ] && command -v git >/dev/null 2>&1; then
        T upd_git; echo
        if _su_out=$(git -C "$ROOT" pull --ff-only 2>&1); then printf '%s%s%s\n' "$C_OK" "$(T upd_done)" "$C_END"
        else printf '%s%s%s\n' "$C_BAD" "$(T upd_fail "$_su_out")" "$C_END"; fi
        return
    fi
    T upd_zip; echo
    _su_tmp=$(mktemp -d)
    if download "$_su_repo/archive/refs/heads/$_su_branch.zip" "$_su_tmp/k.zip" && unzip -q "$_su_tmp/k.zip" -d "$_su_tmp/x"; then
        _su_src=$(find "$_su_tmp/x" -mindepth 1 -maxdepth 1 -type d | head -n 1)
        cp -R "$_su_src/." "$ROOT/" && printf '%s%s%s\n' "$C_OK" "$(T upd_done)" "$C_END"
    fi
    rm -rf "$_su_tmp"
}

# --- Selbst bauen (build) ---------------------------------------------------
# Holt den öffentlichen Port-Code (build im Rezept), führt die Bauschritte aus und findet die APK.
# Ergebnis steht in BUILT_APK (leer bei Fehler oder Abbruch).

cmd_build() {
    BUILT_APK=""
    _b_repo=$(jv "$R" build.repo)
    [ -n "$_b_repo" ] || { printf '%s%s%s\n' "$C_WARN" "$(T b_none)" "$C_END"; return 1; }
    echo; printf '%s%s%s\n' "$C_HEAD" "$(T b_title "$(RT "$R" title)")" "$C_END"
    _b_note=$(RT "$R" build.note); [ -n "$_b_note" ] && hint "$_b_note"

    # 1. Bauwerkzeuge
    _b_before=$PROBLEMS; PROBLEMS=0
    check_recipe_tools 0
    if [ "$PROBLEMS" -gt 0 ]; then T g_tools_missing; echo; PROBLEMS=$_b_before; return 1; fi
    PROBLEMS=$_b_before

    # 2. Port-Code holen bzw. aktualisieren (neben die Kitchen)
    _b_name=$(basename "$_b_repo" .git)
    _b_dir=$(dirname "$ROOT")/$_b_name
    _b_sub=$(jv "$R" build.submodules)
    if [ -d "$_b_dir/.git" ]; then
        T b_update "$_b_dir"; echo
        git -C "$_b_dir" pull --ff-only
        [ "$_b_sub" = true ] && git -C "$_b_dir" submodule update --init --recursive
    else
        ask_yes "$(T b_clone "$_b_repo" "$_b_dir")" || { T aborted; echo; return 1; }
        _b_branch=$(jv "$R" build.branch)
        set -- clone
        [ -n "$_b_branch" ] && set -- "$@" -b "$_b_branch"
        [ "$_b_sub" = true ] && set -- "$@" --recurse-submodules
        git "$@" "$_b_repo" "$_b_dir" || { printf '%s%s%s\n' "$C_BAD" "$(T b_fail "git clone")" "$C_END"; return 1; }
    fi

    # 3. Bauen – Schritte verkettet in einer Sub-Shell im Repo-Ordner
    _b_steps=""; _b_i=0; _b_n=$(jn "$R" build.steps)
    while [ $_b_i -lt "$_b_n" ]; do
        _b_s=$(jv "$R" "build.steps.$_b_i")
        if [ -z "$_b_steps" ]; then _b_steps=$_b_s; else _b_steps="$_b_steps && $_b_s"; fi
        _b_i=$((_b_i + 1))
    done
    T b_running; echo
    printf '  %s%s%s\n' "$C_DIM" "$_b_steps" "$C_END"
    ( cd "$_b_dir" && sh -c "set -e; $_b_steps" ) || { printf '%s%s%s\n' "$C_BAD" "$(T b_fail "Exit $?")" "$C_END"; hint "$(T b_fail_hint)"; return 1; }

    # 4. APK finden (neueste passende Datei)
    _b_glob=$(jv "$R" build.apk)
    # shellcheck disable=SC2086
    BUILT_APK=$(cd "$_b_dir" && ls -t $_b_glob 2>/dev/null | head -n 1)
    if [ -z "$BUILT_APK" ]; then printf '%s%s%s\n' "$C_BAD" "$(T b_noapk "$_b_glob")" "$C_END"; return 1; fi
    BUILT_APK="$_b_dir/$BUILT_APK"
    ok "$(T b_done "$BUILT_APK")"
}

# --- Assistent: führt Schritt für Schritt durch ein Rezept ----------------

step() { echo; printf '%s%s%s\n' "$C_HEAD" "$(T step "$1" "$2" "$3")" "$C_END"; }

# assets_ok <ordner> – wie check_assets, zählt aber nicht in PROBLEMS dieses Laufs
assets_ok() { _ao_before=$PROBLEMS; check_assets "$1"; _ao_r=$PROBLEMS; PROBLEMS=$_ao_before; [ "$_ao_r" = "$_ao_before" ]; }

cmd_guide() {
    INTERACTIVE=1
    load_recipe "$1"
    _g_id=$1
    _g_need=0
    [ "$(jn "$R" ingredients.original_assets.required)" != 0 ] && _g_need=1
    [ "$(jn "$R" ingredients.original_assets.any_of)" != 0 ] && _g_need=1
    _g_haspush=0; [ -n "$(jv "$R" ingredients.push.target)" ] && _g_haspush=1
    _g_prepare=$(RT "$R" ingredients.push.prepare)
    _g_source=$(jv "$R" ingredients.push.source)
    _g_app=${P_APP:-$(jv "$R" app.id)}
    _g_total=6

    # 0. Rezept vorstellen
    echo
    printf '%s%s%s\n' "$C_HEAD" "$(RT "$R" title)" "$C_END"
    echo "Portierbarkeit/portability $(stars "$(jv "$R" ratings.portability)")   XR $(stars "$(jv "$R" ratings.xr_potential)")"
    _g_lv=$(jv "$R" last_verified); printf '%s%s%s\n' "$C_DIM" "$(T g_status "${_g_lv:-$(jv "$R" status)}")" "$C_END"
    _g_eff=$(RT "$R" effort.with_apk); [ -n "$_g_eff" ] && { T g_effort "$_g_eff"; echo; }
    T g_based_on; echo
    _g_i=0; _g_n=$(jn "$R" base)
    while [ $_g_i -lt "$_g_n" ]; do
        printf '  %s%s [%s] %s%s\n' "$C_DIM" "$(jv "$R" "base.$_g_i.name")" "$(jv "$R" "base.$_g_i.license")" "$(jv "$R" "base.$_g_i.url")" "$C_END"
        _g_i=$((_g_i + 1))
    done
    ask_yes "$(T g_start)" || { T aborted; echo; return; }

    # 1. Originalspiel und Ordner
    step 1 $_g_total "$(T g_game)"
    _g_folder=""
    _g_hint=$(RT "$R" ingredients.original_assets.hint)
    if [ $_g_need = 0 ]; then
        T g_game_none; echo; [ -n "$_g_hint" ] && hint "$_g_hint"
    else
        if ! ask_yes "$(T g_game_have "$(RT "$R" game.name)")"; then
            _g_buy=""; _g_i=0; _g_n=$(jn "$R" game.buy)
            while [ $_g_i -lt "$_g_n" ]; do _g_buy="${_g_buy:+$_g_buy, }$(jv "$R" "game.buy.$_g_i")"; _g_i=$((_g_i + 1)); done
            T g_game_buy "$_g_buy"; echo; return
        fi
        T g_folder; echo; [ -n "$_g_hint" ] && hint "$_g_hint"
        while :; do
            _g_folder=$(ask_path "$(T g_folder_ask)")
            [ -n "$_g_folder" ] || { T aborted; echo; return; }
            if assets_ok "$_g_folder"; then printf '%s%s%s\n' "$C_OK" "$(T g_folder_ok)" "$C_END"; break; fi
            ask_yes "$(T g_folder_retry)" || { T aborted; echo; return; }
        done
    fi

    # 2. Vorbereiten (nur wenn das Rezept es verlangt)
    step 2 $_g_total "$(T g_prepare)"
    _g_src=$_g_folder
    if [ -n "$_g_prepare" ]; then
        echo "$_g_prepare"
        ask_yes "$(T g_prepare_done)" || { T aborted; echo; return; }
        _g_src=$(ask_path "$(T g_prepared_ask)")
        [ -n "$_g_src" ] || { T aborted; echo; return; }
    else
        printf '%s–%s\n' "$C_DIM" "$C_END"
        case "$_g_source" in archive|file) _g_src=$(ask_path "$(T g_prepared_ask)") ;; esac
    fi

    # 3. Werkzeuge (nur Spielen)
    step 3 $_g_total "$(T g_tools)"
    PROBLEMS=0
    check_recipe_tools 1
    if [ "$PROBLEMS" != 0 ] && [ -z "$(find_adb)" ] && install_platform_tools; then
        PROBLEMS=0; check_recipe_tools 1   # fehlte nur adb, ist es jetzt da
    fi
    [ "$PROBLEMS" = 0 ] || { printf '%s%s%s\n' "$C_WARN" "$(T g_tools_missing)" "$C_END"; return; }

    # 4. Quest verbinden (mit Hilfe und Wiederholen)
    step 4 $_g_total "$(T g_quest)"
    while :; do
        PROBLEMS=0; check_quest
        [ "$PROBLEMS" = 0 ] && break
        T g_quest_help; echo
        ask_yes "$(T g_quest_retry)" || { T aborted; echo; return; }
    done
    select_device "$_g_id"

    # 5. App installieren oder aktualisieren
    step 5 $_g_total "$(T g_app)"
    _g_inst=""
    [ -n "$_g_app" ] && _g_inst=$(adb_run shell "dumpsys package $_g_app | grep versionName" 2>/dev/null | tr -d '\r' | sed -nE 's/.*versionName=([^ ]+).*/\1/p' | head -n 1)
    _g_want=1
    if [ -n "$_g_inst" ]; then
        printf '%s%s%s\n' "$C_OK" "$(T g_app_installed "$_g_app" "$_g_inst")" "$C_END"
        ask_yes "$(T g_app_update)" || _g_want=0
    else
        T g_app_missing "$_g_app"; echo
    fi
    if [ $_g_want = 1 ]; then
        _g_apk=$(ask_path "$(T g_app_ask)")
        if [ -z "$_g_apk" ] && [ -z "$_g_inst" ]; then
            # App baut jeder selbst – mit Bauangaben im Rezept kann die Küchenhilfe das übernehmen
            if [ -n "$(jv "$R" build.repo)" ] && ask_yes "$(T b_offer)"; then cmd_build && _g_apk=$BUILT_APK
            else printf '%s%s%s\n' "$C_DIM" "$(T apk_none)" "$C_END"; fi
        fi
        if [ -n "$_g_apk" ]; then
            [ -f "$_g_apk" ] || die "$(T e_srcmissing "$_g_apk")"
            T g_app_installing; echo
            _g_res=$(adb_run install -r "$(local_path "$_g_apk")" 2>&1 | tr -d '\r')
            if printf '%s' "$_g_res" | grep -q Success; then printf '%s%s%s\n' "$C_OK" "$(T g_app_ok)" "$C_END"
            else
                printf '%s%s%s\n' "$C_BAD" "$(T g_app_fail "$_g_res")" "$C_END"
                printf '%s' "$_g_res" | grep -Eq 'INSTALL_FAILED_UPDATE_INCOMPATIBLE|signatures do not match' && { printf '%s%s%s\n' "$C_WARN" "$(T g_app_sig)" "$C_END"; }
                return
            fi
        fi
    fi

    # 6. Daten übertragen
    step 6 $_g_total "$(T g_push)"
    if [ $_g_haspush = 1 ] && [ -n "$_g_src" ]; then
        ask_yes "$(T g_push_confirm)" || { T aborted; echo; return; }
        cmd_push "$_g_id" "$_g_src" || { T aborted; echo; return; }
    elif [ $_g_haspush = 0 ]; then
        T g_push_none; echo
    fi

    echo
    printf '%s%s%s\n' "$C_OK" "$(T g_done)" "$C_END"
    [ -n "$_g_app" ] && { T g_done_start "$_g_app"; echo; }
    printf '%s%s%s\n' "$C_DIM" "$(T g_details "recipes/$_g_id/RECIPE.md")" "$C_END"
}

select_lang() {
    T lang_prompt; echo
    printf '> '; read -r _sl
    case "$_sl" in 2|e*|E*) KLANG=en ;; *) KLANG=de ;; esac
    save_lang
}

# Auswahlmenü im DOS-Stil: Spiele alphabetisch, ankreuzen mit X (einzeln oder mehrere)
menu_list() {   # Zeilen "titel<TAB>id<TAB>status", alphabetisch nach Titel in der gewählten Sprache
    for _ml_id in $(recipe_ids); do
        load_recipe "$_ml_id"
        printf '%s\t%s\t%s\n' "$(RT "$R" title)" "$_ml_id" "$(jv "$R" status)"
    done | sort -f
}

cmd_menu() {
    [ "$LANG_CHOSEN" = 1 ] || select_lang
    _m_sel=" "   # angekreuzte Nummern, z. B. " 3 5 "
    while :; do
        _m_list=$(menu_list); _m_total=$(printf '%s\n' "$_m_list" | grep -c .)
        [ -t 0 ] && [ -t 1 ] && clear
        echo
        printf '  %s╔══════════════════════════════════════════════════════════╗%s\n' "$C_HEAD" "$C_END"
        printf '  %s║  %-56s║%s\n' "$C_HEAD" "$(T menu_title)" "$C_END"
        printf '  %s╚══════════════════════════════════════════════════════════╝%s\n' "$C_HEAD" "$C_END"
        echo "  $(T menu_question)"; echo
        _m_k=0; _m_n=0
        while IFS="$TAB" read -r _m_title _m_id _m_st; do
            [ -n "$_m_id" ] || continue
            _m_k=$((_m_k + 1))
            case "$_m_st" in verified) _m_s="✓✓" ;; playable) _m_s="✓" ;; in-progress) _m_s="…" ;; *) _m_s="–" ;; esac
            case "$_m_sel" in
                *" $_m_k "*) _m_n=$((_m_n + 1)); printf '   %s%2d  [X]  %s  %s%s\n' "$C_OK" "$_m_k" "$_m_title" "$_m_s" "$C_END" ;;
                *) printf '   %2d  [ ]  %s  %s\n' "$_m_k" "$_m_title" "$_m_s" ;;
            esac
        done <<EOF
$_m_list
EOF
        echo
        printf '  %s%s   (%s)%s\n' "$C_DIM" "$(T menu_selected "$_m_n" "$_m_total")" "$(T menu_legend)" "$C_END"
        printf '  %s%s%s\n' "$C_DIM" "$(T menu_hint_plain)" "$C_END"
        printf '  %s: ' "$(T menu_choice)"; read -r _m_in || return
        case "$_m_in" in
            "") if [ $_m_n -gt 0 ]; then break; fi; printf '  %s%s%s\n' "$C_WARN" "$(T menu_none)" "$C_END"; sleep 1; continue ;;
            q*|Q*) return ;;
            d*|D*) cmd_doctor; printf '%s ' "$(T press_enter)"; read -r _ ; continue ;;
            l*|L*) if [ "$KLANG" = de ]; then KLANG=en; else KLANG=de; fi; save_lang; continue ;;
            u*|U*) self_update; return ;;
            a*|A*) if [ $_m_n -lt "$_m_total" ]; then _m_sel=" $(seq -s ' ' 1 "$_m_total") "; else _m_sel=" "; fi; continue ;;
        esac
        for _m_tok in $(printf '%s' "$_m_in" | tr ',;' '  '); do
            case "$_m_tok" in *[!0-9]*|"") continue ;; esac
            [ "$_m_tok" -ge 1 ] && [ "$_m_tok" -le "$_m_total" ] || continue
            case "$_m_sel" in
                *" $_m_tok "*) _m_sel=$(subst "$_m_sel" " $_m_tok " " ") ;;
                *) _m_sel="$_m_sel$_m_tok " ;;
            esac
        done
    done
    # Ausgewählte Rezepte nacheinander durchgehen (in Listenreihenfolge). Erst die IDs sammeln:
    # der Assistent muss von der Tastatur lesen, nicht aus einer umgeleiteten Liste.
    _m_ids=$(printf '%s\n' "$_m_list" | awk -F "$TAB" -v sel="$_m_sel" 'BEGIN { n = split(sel, a, " "); for (i = 1; i <= n; i++) s[a[i]] = 1 }
        NF { k++; if (k in s) print $2 }')
    _m_first=1
    for _m_id in $_m_ids; do
        if [ $_m_first = 0 ]; then load_recipe "$_m_id"; echo; printf '%s%s%s\n' "$C_HEAD" "$(T menu_next_game "$(RT "$R" title)")" "$C_END"; fi
        _m_first=0
        cmd_guide "$_m_id"
    done
}

# --- Rezepte prüfen (lint) ------------------------------------------------

cmd_lint() {
    _l_total=0
    for _l_d in "$ROOT"/recipes/*/; do
        _l_rid=$(basename "$_l_d")
        case "$_l_rid" in _*) continue ;; esac
        _l_errs=""
        le() { _l_errs="$_l_errs$NL$1"; }
        if [ ! -f "$_l_d/recipe.json" ]; then le "recipe.json fehlt"
        else
            R=$(flatten "$_l_d/recipe.json") || { le "kein gültiges JSON"; R=""; }
            for _l_f in id title title_en status ratings.portability effort.from_source tools.# stages.# xr_modes.screen game.name base.#; do
                [ -n "$(jv "$R" "$_l_f")" ] || le "Pflichtfeld '$_l_f' fehlt"
            done
            [ "$(jv "$R" id)" = "$_l_rid" ] || le "id '$(jv "$R" id)' passt nicht zum Ordnernamen"
            case "$(jv "$R" status)" in draft|in-progress|playable|verified) ;; *) le "status '$(jv "$R" status)' unbekannt" ;; esac
            _l_a=$(jv "$R" app.id)
            [ -z "$_l_a" ] || printf '%s' "$_l_a" | grep -Eq '^xr\.[a-z0-9.]+$' || le "App-ID '$_l_a' verletzt die Regel xr.<name>"
            for _l_k in portability xr_potential base_maturity; do
                case "$(jv "$R" "ratings.$_l_k")" in [1-5]) ;; *) le "ratings.$_l_k muss 1–5 sein" ;; esac
            done
            _l_n=$(jn "$R" tools); _l_k=0
            while [ $_l_k -lt "$_l_n" ]; do
                _l_tid=$(jv "$R" "tools.$_l_k.id"); [ -z "$_l_tid" ] && _l_tid=$(jv "$R" "tools.$_l_k")
                [ -f "$ROOT/tools/$_l_tid.json" ] || le "Küchengerät '$_l_tid' hat keine tools/$_l_tid.json"
                _l_k=$((_l_k + 1))
            done
            _l_modes=$(printf '%s\n' "$R" | awk -F "$TAB" '$1 ~ /^xr_modes\./ { sub(/^xr_modes\./, "", $1); print $1 " " $2 }')
            while read -r _l_m _l_v; do
                [ -z "$_l_m" ] && continue
                case "$_l_m" in screen|passthrough|tabletop|diorama|full-vr) ;; *) le "XR-Modus '$_l_m' unbekannt" ;; esac
                case "$_l_v" in done|partial|planned|unsuitable) ;; *) le "XR-Modus $_l_m: Wert '$_l_v' unbekannt" ;; esac
            done <<EOF
$_l_modes
EOF
            if [ -n "$(jv "$R" build.repo)$(jv "$R" build.apk)$(jv "$R" build.steps.#)" ]; then
                case "$(jv "$R" build.repo)" in https://*) ;; *) le "build.repo muss eine https-Adresse sein" ;; esac
                [ "$(jn "$R" build.steps)" -gt 0 ] || le "build.steps fehlt"
                case "$(jv "$R" build.apk)" in "") le "build.apk fehlt" ;; /*|[A-Za-z]:*|..*) le "build.apk muss relativ zum Repo sein" ;; esac
            fi
            grep -Eiq '[A-Z]:\\\\(Users|Oliver)' "$_l_d/recipe.json" && le "enthält einen lokalen Rechnerpfad – <XR-Ordner>/… verwenden"
            [ -f "$_l_d/RECIPE.md" ] || le "RECIPE.md fehlt"
        fi
        if [ -n "$_l_errs" ]; then
            while IFS= read -r _l_line; do [ -n "$_l_line" ] && bad "$_l_rid: $_l_line"; done <<EOF
$_l_errs
EOF
            _l_total=$((_l_total + $(printf '%s\n' "$_l_errs" | sed '/^$/d' | wc -l)))
        else
            ok "$_l_rid"
        fi
    done
    if [ "$_l_total" -gt 0 ]; then printf '%s%s Fehler.%s\n' "$C_BAD" "$_l_total" "$C_END"; exit 1; fi
}

# --- Veröffentlichung prüfen (publish-check) ------------------------------
# Prüft ein Git-Repo, bevor es öffentlich wird: keine Spieldaten, nichts daraus Erzeugtes, keine
# Schlüssel, Logs, persönlichen Pfade oder E-Mail-Adressen – im aktuellen Stand UND in den eigenen
# Commits der Historie. Persönliche Muster werden hier auf dem Rechner ermittelt, nie gespeichert.

# path_forms <pfad> – Schreibweisen eines Pfads (posix, Windows mit \ und /)
path_forms() {
    [ -n "$1" ] || return
    printf '%s\n' "$1"
    if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; cygpath -m "$1"; fi
}

personal_patterns() {
    {
        path_forms "$HOME"
        # Oberster Ordner über dem XR-Ordner (z. B. /d/<Name> oder /Users/<Name>)
        _pp_top=$(dirname "$ROOT")
        while :; do
            _pp_parent=$(dirname "$_pp_top")
            case "$_pp_parent" in /|/[a-zA-Z]|.) break ;; esac
            _pp_top=$_pp_parent
        done
        path_forms "$_pp_top"
        _pp_mail=$(git config --global user.email 2>/dev/null)
        case "$_pp_mail" in *noreply*|"") ;; *) printf '%s\n' "$_pp_mail" ;; esac
        [ -f "$HOME/.xr-kitchen/personal-patterns.txt" ] && grep -v '^#' "$HOME/.xr-kitchen/personal-patterns.txt"
    } | sed 's#[\\/]*$##' | awk 'length($0) >= 4' | sort -u
}

recipe_asset_names() {
    for _ra_id in $(recipe_ids); do
        _ra_r=$(flatten "$ROOT/recipes/$_ra_id/recipe.json")
        printf '%s\n' "$_ra_r" | awk -F "$TAB" '$1 ~ /^ingredients\.(original_assets\.(required|any_of)|push\.include)\.[0-9.]+$/ { print $2 }'
    done | awk -F / '{ print tolower($NF) }' | grep '\.' | sort -u
}

# pub_name <pfad> – gibt "E<TAB>Grund" bzw. "W<TAB>Grund" aus, sonst nichts
pub_name() {
    _pn_p=$1; _pn_leaf=${1##*/}
    _pn_lleaf=$(printf '%s' "$_pn_leaf" | tr 'A-Z' 'a-z')
    case "$_pn_lleaf" in *.*) _pn_ext=".${_pn_lleaf##*.}" ;; *) _pn_ext="" ;; esac
    _pn_i=0; _pn_n=$(jn "$RU" allow)
    while [ $_pn_i -lt "$_pn_n" ]; do
        # shellcheck disable=SC2254
        case "$_pn_p" in $(jv "$RU" "allow.$_pn_i")) return ;; esac; _pn_i=$((_pn_i + 1))
    done
    for _pn_d in $RU_DERIVED; do case "/$_pn_p" in */"$_pn_d"*) printf 'E\taus Spieldaten erzeugt / Originaldaten-Ordner (%s)\n' "$_pn_d"; return ;; esac; done
    for _pn_e in $RU_GAMEEXT; do [ "$_pn_ext" = "$_pn_e" ] && { printf 'E\tSpieldaten-Endung %s\n' "$_pn_e"; return; }; done
    printf '%s\n' "$ASSET_NAMES" | grep -qxF "$_pn_lleaf" && { printf 'E\tOriginaldatei aus einem Rezept\n'; return; }
    for _pn_g in $RU_GAMENAMES; do case "$_pn_leaf" in $_pn_g) printf 'E\tInstaller/Spielstand (%s)\n' "$_pn_g"; return ;; esac; done
    _pn_lower=$(printf '%s' "$_pn_leaf" | tr 'A-Z' 'a-z')
    for _pn_g in $RU_CIRC; do case "$_pn_lower" in $_pn_g) printf 'E\tEntschlüsselung/Kopierschutz-Umgehung (%s) – nie veröffentlichen\n' "$_pn_g"; return ;; esac; done
    for _pn_g in $RU_SECRETS; do case "$_pn_leaf" in $_pn_g) printf 'E\tSchlüssel/Zugangsdaten (%s)\n' "$_pn_g"; return ;; esac; done
    for _pn_g in $RU_LOGS; do case "$_pn_leaf" in $_pn_g) printf 'E\tGerätelog (%s)\n' "$_pn_g"; return ;; esac; done
    for _pn_d in $RU_SHOTS; do case "/$_pn_p" in */"$_pn_d"*) printf 'W\tAufnahmen/Logs-Ordner (%s)\n' "$_pn_d"; return ;; esac; done
    for _pn_e in $RU_MEDIA; do [ "$_pn_ext" = "$_pn_e" ] && { printf 'W\tVideo – Spielgrafik? (%s)\n' "$_pn_e"; return; }; done
    for _pn_e in $RU_BIN; do [ "$_pn_ext" = "$_pn_e" ] && { printf 'W\tBinärdatei (%s) – Herkunft und Lizenz klären\n' "$_pn_e"; return; }; done
}

ru_list() { _rl_i=0; _rl_n=$(jn "$RU" "$1"); while [ $_rl_i -lt "$_rl_n" ]; do jv "$RU" "$1.$_rl_i"; _rl_i=$((_rl_i + 1)); done; }

cmd_publish_check() {
    [ -n "$1" ] || die "Pfad fehlt: ./kitchen.sh publish-check <Repo-Ordner>"
    [ -e "$1" ] || die "'$1' existiert nicht."
    _pc_top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || die "'$1' ist kein Git-Repo."
    RU=$(flatten "$ROOT/rules/publish-rules.json")
    set -f   # Muster aus den Regeln nicht als Dateinamen expandieren
    RU_DERIVED=$(ru_list errors.derived_paths); RU_GAMEEXT=$(ru_list errors.game_data_ext)
    RU_GAMENAMES=$(ru_list errors.game_data_names); RU_SECRETS=$(ru_list errors.secret_names)
    RU_CIRC=$(ru_list errors.circumvention_names)
    RU_LOGS=$(ru_list errors.log_names); RU_SHOTS=$(ru_list warnings.screenshot_paths)
    RU_MEDIA=$(ru_list warnings.media_ext); RU_BIN=$(ru_list warnings.binary_ext)
    ASSET_NAMES=$(recipe_asset_names)
    _pc_pers=$(personal_patterns)
    _pc_tmp=$(mktemp -d); trap 'rm -rf "$_pc_tmp"' EXIT
    : > "$_pc_tmp/err"; : > "$_pc_tmp/warn"
    pe() { printf '%s\n' "$1" >> "$_pc_tmp/err"; }
    pw() { printf '%s\n' "$1" >> "$_pc_tmp/warn"; }
    rg() { git -C "$_pc_top" "$@" 2>/dev/null; }

    echo
    printf '%sVeröffentlichung prüfen: %s%s\n' "$C_HEAD" "$_pc_top" "$C_END"
    rg ls-files > "$_pc_tmp/files"
    echo "  $(wc -l < "$_pc_tmp/files" | tr -d ' ') Dateien im Repo, $(printf '%s\n' "$_pc_pers" | grep -c .) persönliche Muster von diesem Rechner"

    # Upstream: Remote „upstream“ oder jeder Remote, der nicht zum eigenen GitHub-Konto gehört
    _pc_login=$(gh api user -q .login 2>/dev/null)
    _pc_up=""
    for _pc_rem in $(rg remote); do
        [ "$_pc_rem" = public ] && continue   # unser eigenes Veröffentlichungsziel, nie Upstream
        _pc_url=$(rg remote get-url "$_pc_rem")
        if [ "$_pc_rem" = upstream ]; then _pc_up="$_pc_up $_pc_rem"
        elif [ -n "$_pc_login" ] && ! printf '%s' "$_pc_url" | grep -Eq "github\.com[:/]$_pc_login/"; then _pc_up="$_pc_up $_pc_rem"; fi
    done
    set -- HEAD
    if [ -n "$_pc_up" ]; then
        set -- "$@" --not
        for _pc_u in $_pc_up; do set -- "$@" "--remotes=$_pc_u"; done
        _pc_sh=$(rg rev-parse --git-path shallow)
        case "$_pc_sh" in /*|[A-Za-z]:*) ;; *) _pc_sh="$_pc_top/$_pc_sh" ;; esac
        [ -f "$_pc_sh" ] && for _pc_c in $(grep -E '^[0-9a-f]{40}$' "$_pc_sh"); do set -- "$@" "$_pc_c"; done
    fi
    _pc_own=$(rg rev-list "$@" | grep -c .)
    cp "$_pc_tmp/files" "$_pc_tmp/scope"
    if [ -n "$_pc_up" ]; then
        rg log "$@" --name-only --format= | sed '/^$/d' | sort -u > "$_pc_tmp/touched"
        sort -u "$_pc_tmp/files" > "$_pc_tmp/files.sorted"
        comm -12 "$_pc_tmp/files.sorted" "$_pc_tmp/touched" > "$_pc_tmp/scope"
        echo "  Upstream:$_pc_up – geprüft werden $(wc -l < "$_pc_tmp/scope" | tr -d ' ') Dateien, die eigene Commits geändert haben"
    fi

    # 1. Dateinamen und Größen
    while IFS= read -r _pc_f; do
        _pc_hit=$(pub_name "$_pc_f")
        case "$_pc_hit" in E*) pe "$_pc_f – ${_pc_hit#*"$TAB"}" ;; W*) pw "$_pc_f – ${_pc_hit#*"$TAB"}" ;; esac
    done < "$_pc_tmp/scope"
    _pc_mb=$(jv "$RU" max_file_mb)
    (cd "$_pc_top" && find . -path ./.git -prune -o -type f -size +"${_pc_mb}"M -print 2>/dev/null) | sed 's#^\./##' | sort > "$_pc_tmp/big"
    sort "$_pc_tmp/scope" | comm -12 - "$_pc_tmp/big" | while IFS= read -r _pc_f; do
        pw "$_pc_f – groß ($(awk -v s="$(wc -c < "$_pc_top/$_pc_f")" 'BEGIN { printf "%.1f", s / 1048576 }') MB)"
    done

    # 2. Persönliche Pfade/Adressen im Inhalt (nur Dateien im Prüfumfang)
    # eigene Funktion: ihr „set --“ lässt den Commit-Bereich in "$@" des Aufrufers unberührt
    grep_personal() {
        set --
        while IFS= read -r _gp_p; do set -- "$@" -e "$_gp_p"; done <<EOF
$_pc_pers
EOF
        rg grep -I -n -o -F -i "$@"
    }
    if [ -n "$_pc_pers" ]; then
        grep_personal | awk -v scope="$_pc_tmp/scope" 'BEGIN { while ((getline l < scope) > 0) s[l] = 1 }
            { if (match($0, /:[0-9]+:/)) { f = substr($0, 1, RSTART - 1); if (f in s) print f ":" substr($0, RSTART + 1, RLENGTH - 1) " " substr($0, RSTART + RLENGTH) } }' |
            while IFS= read -r _pc_h; do pe "persönlicher Pfad/Adresse: $_pc_h"; done
    fi
    # Vergleich ohne Rücksicht auf \ / und doppelte Trenner (JSON schreibt \\)
    _pc_ign=$(ru_list generic_path_ignore | tr '\\' '/' | tr -s '/' | tr 'A-Z' 'a-z')
    ru_list generic_path_patterns | while IFS= read -r _pc_rx; do
        rg grep -I -n -o -E -e "$_pc_rx" | awk -v scope="$_pc_tmp/scope" 'BEGIN { while ((getline l < scope) > 0) s[l] = 1 }
            { if (match($0, /:[0-9]+:/)) { f = substr($0, 1, RSTART - 1); if (f in s) print f ":" substr($0, RSTART + 1, RLENGTH - 1) " " substr($0, RSTART + RLENGTH) } }' |
            while IFS= read -r _pc_h; do
                _pc_norm=$(printf '%s' "$_pc_h" | tr '\\' '/' | tr -s '/' | tr 'A-Z' 'a-z')
                _pc_skip=0
                while IFS= read -r _pc_ig; do [ -n "$_pc_ig" ] && case "$_pc_norm" in *"$_pc_ig"*) _pc_skip=1 ;; esac; done <<EOF
$_pc_ign
EOF
                [ $_pc_skip = 1 ] || pw "Benutzerpfad: $_pc_h"
            done
    done

    # 3. Lizenzdatei
    _pc_lic=0
    for _pc_l in $(ru_list license_files); do [ -f "$_pc_top/$_pc_l" ] && _pc_lic=1; done
    [ $_pc_lic = 1 ] || pe "keine LICENSE/COPYING-Datei im Hauptordner"

    # 4. Eigene Commits der Historie
    if [ -n "$_pc_up" ]; then echo "  $_pc_own eigene Commits in der Historie (ohne Upstream)"; else echo "  $_pc_own eigene Commits in der Historie"; fi
    if [ "$_pc_own" -gt 0 ]; then
        rg log "$@" --diff-filter=A --name-only --format= | sed '/^$/d' | sort -u | while IFS= read -r _pc_f; do
            grep -qxF "$_pc_f" "$_pc_tmp/files" && continue
            _pc_hit=$(pub_name "$_pc_f")
            case "$_pc_hit" in E*) pe "nur noch in der Historie: $_pc_f – ${_pc_hit#*"$TAB"}" ;; esac
        done
        while IFS= read -r _pc_p; do
            [ -n "$_pc_p" ] || continue
            _pc_c=$(rg log "$@" --format=%h -i "-S$_pc_p")
            [ -n "$_pc_c" ] && pe "persönlicher Pfad/Adresse '$_pc_p' in $(printf '%s\n' "$_pc_c" | grep -c .) Commit(s) der Historie, z. B. $(printf '%s\n' "$_pc_c" | head -n 1)"
        done <<EOF
$_pc_pers
EOF
        rg log "$@" --format='%ae%n%ce' | sort -u | grep -v noreply | sed '/^$/d' | while IFS= read -r _pc_m; do
            pw "Commit-E-Mail sichtbar: $_pc_m – ggf. GitHub-noreply-Adresse verwenden"
        done
    fi

    # 5. Submodule
    _pc_subs=$(rg submodule status | awk '{ print $2 }')
    _pc_ns=$(printf '%s\n' "$_pc_subs" | grep -c .)
    [ "$_pc_ns" -gt 0 ] && pw "$_pc_ns Submodul(e) – eigene Änderungen dort separat prüfen: $(printf '%s\n' "$_pc_subs" | head -n 6 | paste -sd ',' - | sed 's/,/, /g')"
    set +f

    echo
    _pc_ne=$(grep -c . "$_pc_tmp/err"); _pc_nw=$(grep -c . "$_pc_tmp/warn")
    if [ "$_pc_ne" -gt 0 ]; then
        printf '%sFEHLER (%s) – so nicht veröffentlichen:%s\n' "$C_BAD" "$_pc_ne" "$C_END"
        head -n 25 "$_pc_tmp/err" | while IFS= read -r _pc_l; do printf '  %s✗ %s%s\n' "$C_BAD" "$_pc_l" "$C_END"; done
        [ "$_pc_ne" -gt 25 ] && printf '  %s… und %s weitere%s\n' "$C_BAD" "$((_pc_ne - 25))" "$C_END"
    fi
    if [ "$_pc_nw" -gt 0 ]; then
        printf '%sHINWEISE (%s) – prüfen:%s\n' "$C_WARN" "$_pc_nw" "$C_END"
        head -n 25 "$_pc_tmp/warn" | while IFS= read -r _pc_l; do printf '  %s! %s%s\n' "$C_WARN" "$_pc_l" "$C_END"; done
        [ "$_pc_nw" -gt 25 ] && printf '  %s… und %s weitere%s\n' "$C_WARN" "$((_pc_nw - 25))" "$C_END"
    fi
    if [ "$_pc_ne" = 0 ] && [ "$_pc_nw" = 0 ]; then printf '%sSauber – nichts gefunden.%s\n' "$C_OK" "$C_END"
    elif [ "$_pc_ne" = 0 ]; then printf '%sKeine Fehler; Hinweise bitte ansehen.%s\n' "$C_OK" "$C_END"; fi
    [ "$_pc_ne" = 0 ] || exit 1
}

# --- Veröffentlichungszweig vorbereiten (publish-prepare) -----------------
# Erzeugt den Zweig xr-public: bei Forks der neueste enthaltene Upstream-Commit plus EIN Commit
# mit dem aktuellen Stand (HEAD), sonst ein einzelner Commit ohne Vorgeschichte. Autor ist die
# GitHub-noreply-Adresse. Arbeitsstand, HEAD und andere Zweige bleiben unberührt (commit-tree).

cmd_publish_prepare() {
    [ -n "$1" ] && [ -e "$1" ] || die "Pfad fehlt/existiert nicht: ./kitchen.sh publish-prepare <Repo-Ordner>"
    _pp_branch=xr-public
    _pp_src=${2:-HEAD}   # Quelle: ausgecheckter Stand oder angegebener Zweig/Commit (ohne Umschalten)
    _pp_top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || die "'$1' ist kein Git-Repo."
    pg() { git -C "$_pp_top" "$@" 2>/dev/null; }
    pg rev-parse --verify -q "$_pp_src^{commit}" >/dev/null || die "Quelle '$_pp_src' gibt es in diesem Repo nicht."
    if [ "$_pp_src" = HEAD ]; then _pp_cur=$(pg rev-parse --abbrev-ref HEAD); else _pp_cur=$_pp_src; fi
    [ "$_pp_cur" != "$_pp_branch" ] || die "Auf dem Zweig '$_pp_branch' selbst kann nicht vorbereitet werden – anderen Zweig auschecken."
    if [ "$_pp_src" = HEAD ]; then _pp_dirty=$(pg status --porcelain --untracked-files=no | grep -c .); else _pp_dirty=0; fi
    _pp_head=$(pg rev-parse "$_pp_src"); _pp_tree=$(pg rev-parse "$_pp_src^{tree}")

    # noreply-Identität
    _pp_login=$(gh api user -q .login 2>/dev/null)
    _pp_mail=$(pg config user.email)
    case "$_pp_mail" in
        *noreply*) ;;
        *) _pp_id=$(gh api user -q .id 2>/dev/null)
           if [ -n "$_pp_id" ] && [ -n "$_pp_login" ]; then _pp_mail="$_pp_id+$_pp_login@users.noreply.github.com"; else _pp_mail=""; fi ;;
    esac
    _pp_name=${_pp_login:-$(pg config user.name)}
    [ -n "$_pp_mail" ] && [ -n "$_pp_name" ] || die "Keine GitHub-noreply-Adresse ermittelbar (gh anmelden oder user.email auf …@users.noreply.github.com setzen)."

    echo
    printf '%sVeröffentlichungszweig vorbereiten: %s%s\n' "$C_HEAD" "$_pp_top" "$C_END"
    echo "  Quelle: Zweig $_pp_cur @ $(printf '%s' "$_pp_head" | cut -c1-10)"
    [ "$_pp_dirty" -gt 0 ] && warn "$_pp_dirty nicht committete Änderung(en) – sie kommen NICHT mit (nur der letzte Commit zählt)"

    # Upstream-Remotes und Ausschlüsse (wie publish-check)
    _pp_up=""
    for _pp_rem in $(pg remote); do
        [ "$_pp_rem" = public ] && continue   # unser eigenes Veröffentlichungsziel, nie Upstream
        _pp_url=$(pg remote get-url "$_pp_rem")
        if [ "$_pp_rem" = upstream ]; then _pp_up="$_pp_up $_pp_rem"
        elif [ -n "$_pp_login" ] && ! printf '%s' "$_pp_url" | grep -Eq "github\.com[:/]$_pp_login/"; then _pp_up="$_pp_up $_pp_rem"; fi
    done
    _pp_base=""
    if [ -n "$_pp_up" ]; then
        set --
        for _pp_u in $_pp_up; do set -- "$@" "--remotes=$_pp_u"; done
        _pp_sh=$(pg rev-parse --git-path shallow)
        case "$_pp_sh" in /*|[A-Za-z]:*) ;; *) _pp_sh="$_pp_top/$_pp_sh" ;; esac
        [ -f "$_pp_sh" ] && for _pp_c in $(grep -E '^[0-9a-f]{40}$' "$_pp_sh"); do set -- "$@" "$_pp_c"; done
        _pp_bound=$(pg rev-list --boundary "$_pp_src" --not "$@" | sed -n 's/^-//p')
        for _pp_b in $_pp_bound; do
            _pp_newest=1
            for _pp_o in $_pp_bound; do
                [ "$_pp_o" = "$_pp_b" ] && continue
                git -C "$_pp_top" merge-base --is-ancestor "$_pp_o" "$_pp_b" 2>/dev/null || { _pp_newest=0; break; }
            done
            [ $_pp_newest = 1 ] && { _pp_base=$_pp_b; break; }
        done
        if [ -z "$_pp_base" ]; then
            [ -n "$_pp_bound" ] && die "Kein eindeutiger Upstream-Stand gefunden (mehrere Abzweigungen) – bitte Upstream zuerst einmergen."
            echo "  Upstream:$_pp_up – keine eigenen Commits, nichts zu tun"; return
        fi
        echo "  Upstream:$_pp_up – Basis $(pg log -1 --format='%h %ad %s' --date=short "$_pp_base")"
    else
        echo "  Kein Upstream – ein einzelner Commit ohne Vorgeschichte"
    fi

    # Schon veröffentlicht (Remote public)? Dann wird der neue Stand ein Folge-Commit auf den
    # veröffentlichten Zweig – ein normaler Push reicht, die Klone anderer bleiben gültig.
    _pp_ptip=""; _pp_pbr=""
    if pg remote get-url public >/dev/null; then
        _pp_pbr=$(pg config kitchen.publicbranch)
        [ -n "$_pp_pbr" ] || _pp_pbr=$(pg ls-remote --symref public HEAD | sed -n 's#^ref: refs/heads/\([^[:space:]]*\)[[:space:]]*HEAD#\1#p')
        if [ -n "$_pp_pbr" ]; then
            pg fetch -q public "+refs/heads/$_pp_pbr:refs/remotes/public/$_pp_pbr"
            _pp_ptip=$(pg rev-parse --verify -q "refs/remotes/public/$_pp_pbr")
        fi
        # Nur auf Stände aufbauen, die selbst aus publish-prepare stammen (sonst bliebe alte Historie fest)
        if [ -n "$_pp_ptip" ]; then
            case "$(pg log -1 --format=%s "$_pp_ptip")" in
                XR-Port:*) echo "  Veröffentlicht: public/$_pp_pbr @ $(printf '%s' "$_pp_ptip" | cut -c1-10) – neuer Stand wird ein Folge-Commit (Update)" ;;
                *) warn "public/$_pp_pbr stammt nicht aus publish-prepare (alte Historie) – frischer Einzel-Commit; zum Ersetzen ist ein Force-Push nötig"; _pp_ptip="" ;;
            esac
        fi
    fi

    # Submodule, die auf nur lokal vorhandene Commits zeigen
    _pp_subs=$(pg ls-tree -r "$_pp_src" | awk '$1 == "160000" { sub(/^[^\t]*\t/, ""); print }')
    _pp_subwarn=""; _pp_remaps=""
    while IFS= read -r _pp_s; do
        [ -n "$_pp_s" ] || continue
        _pp_sha=$(pg ls-tree "$_pp_src" "$_pp_s" | awk '{ print $3 }')
        if [ ! -e "$_pp_top/$_pp_s/.git" ]; then
            _pp_subwarn="$_pp_subwarn$NL$_pp_s (nicht initialisiert – Herkunft von $(printf '%s' "$_pp_sha" | cut -c1-10) prüfen)"
        # veröffentlicht = in einem Remote-Zweig oder einem Tag enthalten (Releases liegen oft nur als Tag vor)
        elif [ -z "$(git -C "$_pp_top/$_pp_s" for-each-ref --contains "$_pp_sha" refs/remotes refs/tags 2>/dev/null)" ] &&
             ! { _pp_ssf=$(git -C "$_pp_top/$_pp_s" rev-parse --git-path shallow 2>/dev/null)
                 case "$_pp_ssf" in /*|[A-Za-z]:*) ;; *) _pp_ssf="$_pp_top/$_pp_s/$_pp_ssf" ;; esac
                 [ -f "$_pp_ssf" ] && grep -q "$_pp_sha" "$_pp_ssf"; }; then   # Grenz-Commit eines flachen Klons = vom Upstream
            # Schon vorbereitet (gleicher Inhalt in xr-public) und veröffentlicht (Remote public)? → Verweis umstellen
            _pp_sd="$_pp_top/$_pp_s"
            _pp_psha=$(git -C "$_pp_sd" rev-parse --verify -q "refs/heads/$_pp_branch" 2>/dev/null)
            _pp_purl=$(git -C "$_pp_sd" remote get-url public 2>/dev/null)
            _pp_same=0
            [ -n "$_pp_psha" ] && [ "$(git -C "$_pp_sd" rev-parse "$_pp_sha^{tree}" 2>/dev/null)" = "$(git -C "$_pp_sd" rev-parse "$_pp_psha^{tree}" 2>/dev/null)" ] && _pp_same=1
            if [ $_pp_same = 1 ] && [ -n "$_pp_purl" ] && git -C "$_pp_sd" ls-remote public 2>/dev/null | grep -q "^$_pp_psha"; then
                _pp_remaps="$_pp_remaps$NL$_pp_s$TAB$_pp_psha$TAB${_pp_purl%.git}.git"
            elif [ $_pp_same = 1 ]; then
                _pp_subwarn="$_pp_subwarn$NL$_pp_s – Zweig $_pp_branch ist vorbereitet, aber noch nicht als Remote 'public' veröffentlicht"
            else
                _pp_subwarn="$_pp_subwarn$NL$_pp_s @ $(printf '%s' "$_pp_sha" | cut -c1-10) – Commit nur lokal: dort zuerst publish-prepare, dann veröffentlichen (Remote 'public')"
            fi
        fi
    done <<EOF
$_pp_subs
EOF

    # Verweise umstellen: neuer Baum über einen temporären Index (Arbeitsstand bleibt unberührt)
    if [ -n "$_pp_remaps" ]; then
        _pp_idx=$(mktemp); _pp_gm=$(mktemp)
        GIT_INDEX_FILE=$_pp_idx git -C "$_pp_top" read-tree "$_pp_src"
        pg show "$_pp_src:.gitmodules" > "$_pp_gm"
        while IFS="$TAB" read -r _pp_mp _pp_ms _pp_mu; do
            [ -n "$_pp_mp" ] || continue
            GIT_INDEX_FILE=$_pp_idx git -C "$_pp_top" update-index --cacheinfo "160000,$_pp_ms,$_pp_mp"
            _pp_key=$(git config -f "$_pp_gm" --get-regexp '^submodule\..*\.path$' | awk -v p="$_pp_mp" '$2 == p { sub(/\.path$/, ".url", $1); print $1; exit }')
            [ -n "$_pp_key" ] && git config -f "$_pp_gm" "$_pp_key" "$_pp_mu"
            ok "Submodul $_pp_mp → $_pp_mu @ $(printf '%s' "$_pp_ms" | cut -c1-10)"
        done <<EOF
$_pp_remaps
EOF
        _pp_blob=$(git -C "$_pp_top" hash-object -w "$_pp_gm")
        GIT_INDEX_FILE=$_pp_idx git -C "$_pp_top" update-index --cacheinfo "100644,$_pp_blob,.gitmodules"
        _pp_tree=$(GIT_INDEX_FILE=$_pp_idx git -C "$_pp_top" write-tree)
        rm -f "$_pp_idx" "$_pp_gm"
    fi

    if [ -n "$_pp_ptip" ] && [ "$(pg rev-parse "$_pp_ptip^{tree}")" = "$_pp_tree" ]; then
        ok "Keine Änderungen seit der letzten Veröffentlichung (public/$_pp_pbr) – nichts zu tun"
        pg branch -f "$_pp_branch" "$_pp_ptip"
        return 0
    fi
    # Eltern: Folge-Commit auf den veröffentlichten Stand (+ neuer Upstream als zweite Linie) oder Upstream-Basis
    set --
    if [ -n "$_pp_ptip" ]; then
        set -- -p "$_pp_ptip"
        if [ -n "$_pp_base" ] && ! git -C "$_pp_top" merge-base --is-ancestor "$_pp_base" "$_pp_ptip" 2>/dev/null; then set -- "$@" -p "$_pp_base"; fi
    elif [ -n "$_pp_base" ]; then
        set -- -p "$_pp_base"
    fi
    _pp_msgf=$(mktemp)
    {
        if [ -n "$_pp_ptip" ]; then
            printf 'XR-Port: Update von %s (Stand %s)\n\n' "$(basename "$_pp_top")" "$(date +%Y-%m-%d)"
            printf 'Änderungen seit der letzten Veröffentlichung zusammengefasst.\n'
        else
            printf 'XR-Port: öffentlicher Stand von %s\n\n' "$(basename "$_pp_top")"
            printf 'Alle eigenen Änderungen zusammengefasst in einem Commit (Stand %s).\n' "$(date +%Y-%m-%d)"
        fi
        if [ -n "$_pp_base" ]; then
            _pp_first=${_pp_up# }; _pp_first=${_pp_first%% *}
            printf 'Basis: %s @ %s\n' "$(pg remote get-url "$_pp_first")" "$(printf '%s' "$_pp_base" | cut -c1-12)"
        fi
    } > "$_pp_msgf"
    _pp_new=$(GIT_AUTHOR_NAME=$_pp_name GIT_AUTHOR_EMAIL=$_pp_mail GIT_COMMITTER_NAME=$_pp_name GIT_COMMITTER_EMAIL=$_pp_mail \
        git -C "$_pp_top" commit-tree "$_pp_tree" "$@" -F "$_pp_msgf")
    rm -f "$_pp_msgf"
    [ -n "$_pp_new" ] || die "git commit-tree fehlgeschlagen."
    pg branch -f "$_pp_branch" "$_pp_new"
    ok "Zweig $_pp_branch @ $(printf '%s' "$_pp_new" | cut -c1-10) (Autor $_pp_name <$_pp_mail>)"
    printf '%s\n' "$_pp_subwarn" | while IFS= read -r _pp_w; do [ -n "$_pp_w" ] && warn "Submodul: $_pp_w"; done

    # publish-check auf dem neuen Zweig in einem temporären Arbeitsordner
    _pp_wt=$(mktemp -d)/wt
    git -C "$_pp_top" worktree add --detach "$_pp_wt" "$_pp_branch" >/dev/null 2>&1
    sh "$0" publish-check "$_pp_wt"; _pp_code=$?
    git -C "$_pp_top" worktree remove --force "$_pp_wt" >/dev/null 2>&1
    echo
    if [ $_pp_code = 0 ] && [ -z "$_pp_subwarn" ]; then printf '%sBereit zum Veröffentlichen: Zweig %s%s\n' "$C_OK" "$_pp_branch" "$C_END"
    elif [ $_pp_code = 0 ]; then printf '%sZweig %s ist sauber, aber Submodule müssen zuerst veröffentlicht werden (siehe oben).%s\n' "$C_WARN" "$_pp_branch" "$C_END"
    else printf '%sZweig %s ist noch NICHT veröffentlichungsfähig – Fehler oben beheben, committen, erneut vorbereiten.%s\n' "$C_BAD" "$_pp_branch" "$C_END"; exit 1; fi
}

# --- Veröffentlichen (publish) --------------------------------------------
# publish-prepare + Push. Erstveröffentlichung: neues Repo (gh repo create) oder Fork (--fork owner/repo),
# Standardzweig setzen, Remote public + kitchen.publicbranch eintragen. Danach: Update per normalem Push.

cmd_publish() {
    [ -n "$1" ] && [ -e "$1" ] || die "Pfad fehlt: ./kitchen.sh publish <Repo-Ordner> [--name xr.<name>] [--fork owner/repo]"
    _pu_top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || die "'$1' ist kein Git-Repo."
    pug() { git -C "$_pu_top" "$@" 2>/dev/null; }
    _pu_login=$(gh api user -q .login 2>/dev/null)
    [ -n "$_pu_login" ] || die "gh ist nicht angemeldet (gh auth login)."

    sh "$0" publish-prepare "$_pu_top" $P_FROM || die "publish-prepare ist nicht sauber – nichts veröffentlicht."
    _pu_pub=$(pug rev-parse --verify -q refs/heads/xr-public)
    [ -n "$_pu_pub" ] || die "Zweig xr-public fehlt."

    _pu_url=$(pug remote get-url public)
    if [ -n "$_pu_url" ]; then
        _pu_target=$(pug config kitchen.publicbranch); [ -n "$_pu_target" ] || _pu_target=main
        pug fetch -q public "+refs/heads/$_pu_target:refs/remotes/public/$_pu_target"
        _pu_tip=$(pug rev-parse --verify -q "refs/remotes/public/$_pu_target")
        [ "$_pu_tip" != "$_pu_pub" ] || { ok "Schon aktuell: $_pu_url ($_pu_target)"; return 0; }
        if [ -n "$_pu_tip" ] && ! git -C "$_pu_top" merge-base --is-ancestor "$_pu_tip" "$_pu_pub" 2>/dev/null; then
            die "public/$_pu_target ist kein Vorgänger von xr-public – dafür wäre ein Force-Push nötig (bewusst nicht automatisch)."
        fi
        _pu_what="Update von $_pu_url (Zweig $_pu_target)"; _pu_new=0
    else
        [ -n "$P_NAME" ] || die "Für die Erstveröffentlichung --name angeben (Schema: xr.<name>, wie die App-ID)."
        if [ -n "$P_BRANCH" ]; then _pu_target=$P_BRANCH; elif [ -n "$P_FORK" ]; then _pu_target=xr-quest; else _pu_target=main; fi
        _pu_url="https://github.com/$_pu_login/$P_NAME.git"
        gh repo view "$_pu_login/$P_NAME" --json name >/dev/null 2>&1 && die "$_pu_login/$P_NAME existiert schon – anderen Namen wählen oder als Remote 'public' eintragen."
        if [ -n "$P_FORK" ]; then _pu_what="neuer öffentlicher Fork $_pu_login/$P_NAME von $P_FORK (Zweig $_pu_target)"
        else _pu_what="neues öffentliches Repo $_pu_login/$P_NAME (Zweig $_pu_target)"; fi
        _pu_new=1
    fi

    echo; printf '%sVeröffentlichen: %s%s\n' "$C_HEAD" "$_pu_what" "$C_END"
    if [ "$P_YES" != 1 ]; then
        [ -t 0 ] || die "Ohne Rückfrage nur mit --yes."
        ask_yes "Jetzt öffentlich machen?" || { T aborted; echo; return 0; }
    fi

    if [ $_pu_new = 1 ]; then
        if [ -n "$P_FORK" ]; then
            gh repo fork "$P_FORK" --fork-name "$P_NAME" --clone=false >/dev/null 2>&1
            _pu_i=0; while [ $_pu_i -lt 30 ] && ! gh repo view "$_pu_login/$P_NAME" --json name >/dev/null 2>&1; do sleep 4; _pu_i=$((_pu_i + 1)); done
        else
            gh repo create "$_pu_login/$P_NAME" --public --description "${P_DESC:-Teil der XR-Port-Kitchen (Meta Quest).}" >/dev/null 2>&1
        fi
        gh repo view "$_pu_login/$P_NAME" --json name >/dev/null 2>&1 || die "Repo $_pu_login/$P_NAME konnte nicht angelegt werden."
        pug remote add public "$_pu_url"
        pug config kitchen.publicbranch "$_pu_target"
    fi
    git -C "$_pu_top" push public "refs/heads/xr-public:refs/heads/$_pu_target" ||
        die "Push fehlgeschlagen. (Flacher Klon? Dann nur in einen Fork des Originals pushbar: --fork owner/repo)"
    _pu_slug=$(printf '%s' "$_pu_url" | sed 's#^https://github.com/##; s#\.git$##')
    gh repo edit "$_pu_slug" --default-branch "$_pu_target" >/dev/null 2>&1
    [ -n "$P_DESC" ] && [ -n "$P_FORK" ] && gh repo edit "$_pu_slug" --description "$P_DESC" >/dev/null 2>&1
    echo; ok "Öffentlich: https://github.com/$_pu_slug (Zweig $_pu_target)"
    hint "Rezept ergänzen: port.repo = https://github.com/$_pu_slug, port.branch = $_pu_target"
}

# --- Aufruf ---------------------------------------------------------------

_cmd=${1:-menu}; [ $# -gt 0 ] && shift
# --lang wurde oben schon ausgewertet; hier aus den Argumenten entfernen
_args=""; _skip=0
for _a in "$@"; do
    if [ $_skip = 1 ]; then _skip=0; continue; fi
    case "$_a" in --lang) _skip=1; continue ;; esac
    _args="$_args$NL$_a"
done
_IFS=$IFS; IFS=$NL; set -f
# shellcheck disable=SC2086
set -- $_args
set +f; IFS=$_IFS

case "$_cmd" in
    list) cmd_list ;;
    show) cmd_show "$1" ;;
    check)
        _id=$1; [ $# -gt 0 ] && shift; _assets=""; _play=0
        while [ $# -gt 0 ]; do
            case "$1" in --assets) _assets=$2; shift ;; --play) _play=1 ;; esac
            shift
        done
        cmd_check "$_id" "$_assets" "$_play"
        [ "$PROBLEMS" = 0 ] || exit 1 ;;
    doctor) cmd_doctor ;;
    lint) cmd_lint ;;
    guide) cmd_guide "$1" ;;
    build)
        load_recipe "$1"; P_SERIAL=""
        cmd_build || exit 1
        if [ -n "$(find_adb)" ] && ask_yes "$(T b_install)"; then
            select_device "$1"
            _res=$(adb_run install -r "$(local_path "$BUILT_APK")" 2>&1 | tr -d '\r')
            if printf '%s' "$_res" | grep -q Success; then printf '%s%s%s\n' "$C_OK" "$(T g_app_ok)" "$C_END"
            else printf '%s%s%s\n' "$C_BAD" "$(T g_app_fail "$_res")" "$C_END"; exit 1; fi
        fi ;;
    menu) cmd_menu ;;
    publish-check) cmd_publish_check "$1" ;;
    publish-prepare) cmd_publish_prepare "$1" "$2" ;;
    publish)
        _repo=$1; [ $# -gt 0 ] && shift; P_NAME=""; P_FORK=""; P_BRANCH=""; P_DESC=""; P_YES=0; P_FROM=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --name) P_NAME=$2; shift ;;
                --fork) P_FORK=$2; shift ;;
                --branch) P_BRANCH=$2; shift ;;
                --description) P_DESC=$2; shift ;;
                --yes) P_YES=1 ;;
                --*) ;;
                *) P_FROM=$1 ;;
            esac
            shift
        done
        cmd_publish "$_repo" ;;
    push)
        _id=$1; [ $# -gt 0 ] && shift; _src=""; P_NAME=""; P_APP=""; P_SERIAL=""; P_REPLACE=0; P_DRY=0
        while [ $# -gt 0 ]; do
            case "$1" in
                --name) P_NAME=$2; shift ;;
                --app) P_APP=$2; shift ;;
                --serial) P_SERIAL=$2; shift ;;
                --replace) P_REPLACE=1 ;;
                --dry-run) P_DRY=1 ;;
                *) _src=$1 ;;
            esac
            shift
        done
        cmd_push "$_id" "$_src" ;;
    *) sed -n '2,20p' "$0" ;;
esac
