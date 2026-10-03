#!/bin/sh
# XR-Port-Kitchen – Doppelklick im Finder öffnet das Menü der Küchenhilfe im Terminal.
cd "$(dirname "$0")" || exit 1
sh ./kitchen.sh "$@"
echo
printf 'Fenster schließen mit Enter … '
read -r _
