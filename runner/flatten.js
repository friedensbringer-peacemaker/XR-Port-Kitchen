// JSON → flache Zeilen "pfad<TAB>wert" (Arrays zusätzlich "pfad.#<TAB>anzahl").
// Läuft mit dem auf jedem Mac vorhandenen osascript:  osascript -l JavaScript flatten.js datei.json
ObjC.import('Foundation');
function run(argv) {
    var s = $.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null).js;
    var out = [];
    (function walk(p, v) {
        if (v !== null && typeof v === 'object') {
            if (Array.isArray(v)) out.push(p + '.#\t' + v.length);
            Object.keys(v).forEach(function (k) { walk(p ? p + '.' + k : k, v[k]); });
        } else {
            out.push(p + '\t' + String(v).replace(/[\r\n\t]+/g, ' '));
        }
    })('', JSON.parse(s.replace(/^﻿/, '')));   // BOM aus PowerShell-Dateien zulassen
    return out.join('\n');
}
