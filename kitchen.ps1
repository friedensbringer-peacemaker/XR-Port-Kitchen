<#
.SYNOPSIS
  XR-Port-Kitchen – Küchenhilfe für Windows (PowerShell 5.1, keine Zusatzmodule).
  XR-Port-Kitchen – kitchen helper for Windows (PowerShell 5.1, no extra modules).
.EXAMPLE
  .\kitchen.ps1                                 # Assistent / guided setup (Deutsch/English)
  .\kitchen.ps1 guide settlers2-rttr            # direkt ein Rezept / one recipe directly
  .\kitchen.ps1 list
  .\kitchen.ps1 show settlers2-rttr
  .\kitchen.ps1 check settlers2-rttr -Assets "D:\Spiele\Siedler2"
  .\kitchen.ps1 check settlers2-rttr -Play      # nur, was zum Spielen mit fertiger APK nötig ist
  .\kitchen.ps1 push settlers2-rttr "D:\Spiele\Siedler2"        # Spieldaten auf die Quest
  .\kitchen.ps1 push dos-xrshell "D:\quest\1-ThemePark" -App xr.island -Replace
  .\kitchen.ps1 push openra-redalert ra-quickinstall.zip -DryRun # nur zeigen, was passieren würde
  .\kitchen.ps1 doctor
  .\kitchen.ps1 lint                            # alle Rezepte auf Regeln prüfen
  .\kitchen.ps1 publish-check ..\XR-OpenRA      # Repo vor dem Veröffentlichen prüfen
  .\kitchen.ps1 publish-prepare ..\XR-OpenRA    # bereinigten Zweig xr-public erzeugen + prüfen
  .\kitchen.ps1 publish-prepare ..\XR-Foo main  # dasselbe aus einem anderen Zweig (ohne Umschalten)
  .\kitchen.ps1 publish ..\XR-Foo -Name xr.foo [-Fork owner/repo]   # erstmals veröffentlichen (fragt nach)
  .\kitchen.ps1 publish ..\XR-CorsixTH          # Update eines veröffentlichten Repos (normaler Push)
  -Lang en | de                                 # Sprache / language
#>
param(
    [Parameter(Position = 0)] [string] $Command = "menu",
    [Parameter(Position = 1)] [string] $Recipe,
    [Parameter(Position = 2)] [string] $Source,
    [string] $Assets,
    [switch] $Play,
    [string] $Name,
    [string] $App,
    [string] $Serial,
    [switch] $Replace,
    [switch] $DryRun,
    [string] $Lang,
    [string] $Fork,
    [string] $Branch,
    [string] $Description,
    [switch] $Yes
)

$ErrorActionPreference = "Continue"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$Root = $PSScriptRoot
$script:Problems = 0
$script:Interactive = $false

# Gemeinsamer Werkzeugordner neben der Kitchen (z. B. <XR-Ordner>\_tools), falls nicht gesetzt
if (-not $env:XR_TOOLS) {
    $t = Join-Path (Split-Path $Root -Parent) "_tools"
    if (Test-Path $t) { $env:XR_TOOLS = $t }
}

function Read-Json([string] $Path) {
    Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

# Downloads der Küchenhilfe (Platform-Tools) landen nur im Kitchen-Ordner
$env:KITCHEN_TOOLS = Join-Path $Root ".kitchen-tools"
$KitchenCfg = Read-Json (Join-Path $Root "kitchen.json")

# --- Sprache / language ---------------------------------------------------
# Reihenfolge: -Lang, KITCHEN_LANG, gemerkte Wahl (~/.xr-kitchen/lang), Systemsprache

$script:Strings = Read-Json (Join-Path $Root "i18n\strings.json")
$LangFile = Join-Path $HOME ".xr-kitchen\lang"
$script:L = $null
foreach ($cand in @($Lang, $env:KITCHEN_LANG)) { if ($cand -in "de", "en") { $script:L = $cand; break } }
if (-not $script:L -and (Test-Path $LangFile)) {
    try { $saved = (Get-Content $LangFile -Raw).Trim(); if ($saved -in "de", "en") { $script:L = $saved } } catch {}
}
$script:LangChosen = [bool] $script:L
if (-not $script:L) { $script:L = if ((Get-UICulture).TwoLetterISOLanguageName -eq "de") { "de" } else { "en" } }

function Save-Lang {
    try {
        New-Item -ItemType Directory -Force (Split-Path $LangFile) | Out-Null
        Set-Content -Path $LangFile -Value $script:L -Encoding ASCII
    } catch {}
}

function T([string] $key) {
    $e = $script:Strings.$key
    $s = if ($e) { $e.($script:L) } else { $null }
    if (-not $s -and $e) { $s = $e.de }
    if (-not $s) { $s = $key }
    if ($args.Count) { $s -f $args } else { $s }
}

# Rezepttext in der gewählten Sprache: feld_en, wenn vorhanden
function RT($obj, [string] $field) {
    if (-not $obj) { return $null }
    if ($script:L -eq "en" -and $obj."${field}_en") { return $obj."${field}_en" }
    $obj.$field
}

function Read-YesNo([string] $question) {
    $a = Read-Host "$question $(T 'yn')"
    return ($a -and (T 'yes_chars').Contains($a.Trim().Substring(0, 1)))
}

function Read-Path([string] $prompt) {
    $p = Read-Host $prompt
    if ($p) { $p = $p.Trim().Trim('"', "'", ' ') }
    $p
}

# --- Rezepte und Geräte ---------------------------------------------------

function Get-Recipes {
    Get-ChildItem -Path (Join-Path $Root "recipes") -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "recipe.json") } |
        ForEach-Object { Read-Json (Join-Path $_.FullName "recipe.json") }
}

function Get-RecipeById([string] $Id) {
    $p = Join-Path $Root "recipes\$Id\recipe.json"
    if (-not $Id -or -not (Test-Path $p)) {
        Write-Host "Rezept/recipe '$Id' ?" -ForegroundColor Red
        Get-Recipes | ForEach-Object { Write-Host "  $($_.id)" }
        exit 2
    }
    Read-Json $p
}

function Get-Tool([string] $Id) {
    $p = Join-Path $Root "tools\$Id.json"
    if (-not (Test-Path $p)) { return $null }
    Read-Json $p
}

function Stars([int] $n) { ("★" * $n) + ("☆" * (5 - $n)) }

function Write-Ok([string] $t)   { Write-Host "  [$(T 't_ok')]   $t" -ForegroundColor Green }
function Write-Bad([string] $t)  { Write-Host "  [$(T 't_missing')] $t" -ForegroundColor Red; $script:Problems++ }
function Write-Warn([string] $t) { Write-Host "  [?]    $t" -ForegroundColor Yellow }
function Write-Hint([string] $t) { Write-Host "         → $t" -ForegroundColor DarkGray }

# --- Versionen -------------------------------------------------------------

function Split-Ver([string] $v) {
    @($v -split '[._\-]' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [long] $_ })
}

function Compare-Ver([string] $a, [string] $b) {
    $x = Split-Ver $a; $y = Split-Ver $b
    for ($i = 0; $i -lt [Math]::Max($x.Count, $y.Count); $i++) {
        $p = if ($i -lt $x.Count) { $x[$i] } else { 0 }
        $q = if ($i -lt $y.Count) { $y[$i] } else { 0 }
        if ($p -ne $q) { return [Math]::Sign($p - $q) }
    }
    0
}

function Test-VerPrefix([string] $v, [string] $prefix) {
    $x = Split-Ver $v; $y = Split-Ver $prefix
    if ($x.Count -lt $y.Count) { return $false }
    for ($i = 0; $i -lt $y.Count; $i++) { if ($x[$i] -ne $y[$i]) { return $false } }
    $true
}

function Test-VerOk([string] $v, [string] $min, [string] $pin) {
    if (-not $v) { return -not ($min -or $pin) }
    if ($min -and (Compare-Ver $v $min) -lt 0) { return $false }
    if ($pin -and -not (Test-VerPrefix $v $pin)) { return $false }
    $true
}

# --- Werkzeugprüfung ------------------------------------------------------

function Expand-Candidate([string] $c) {
    $e = [Environment]::ExpandEnvironmentVariables($c)
    if ($e -match '%[A-Za-z_]+%') { return $null }   # Variable nicht gesetzt
    $e
}

function Invoke-Capture([string] $exe, [string] $argLine) {
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $exe
        $psi.Arguments = $argLine
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $errTask = $proc.StandardError.ReadToEndAsync()
        $out = $proc.StandardOutput.ReadToEnd()
        if (-not $proc.WaitForExit(20000)) { $proc.Kill(); return $null }
        $out + $errTask.Result
    } catch { $null }
}

function Get-Version([string] $text, [string] $regex) {
    if (-not $text -or -not $regex) { return $null }
    $m = [regex]::Match($text, $regex, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($m.Success) { $m.Groups[1].Value } else { $null }
}

# Liefert alle gefundenen Installationen: @{ Path; Version }
function Find-ToolInstalls($tool) {
    $spec = $tool.check.windows
    $found = @()
    foreach ($c in $spec.candidates) {
        $e = Expand-Candidate $c
        if (-not $e) { continue }
        if ($spec.kind -eq "dir") {
            $dirs = @()
            if ($e.Contains("*")) {
                $dirs = @(Get-Item -Path $e -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer } |
                          Sort-Object Name -Descending | ForEach-Object { $_.FullName })
            } elseif (Test-Path -LiteralPath $e -PathType Container) {
                $dirs = @($e)
            }
            foreach ($d in $dirs) {
                $ver = $null
                if ($spec.version_file) {
                    $vf = Join-Path $d $spec.version_file
                    if (Test-Path -LiteralPath $vf) { $ver = Get-Version (Get-Content -LiteralPath $vf -Raw) $spec.version_regex }
                }
                $found += @{ Path = $d; Version = $ver }
            }
        } else {
            $exe = $null
            if ($e -match '[\\/]') {
                if (Test-Path -LiteralPath $e -PathType Leaf) { $exe = $e }
            } else {
                $cmd = Get-Command $e -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($cmd) { $exe = $cmd.Source }
            }
            if (-not $exe) { continue }
            if ($found | Where-Object { $_.Path -eq $exe }) { continue }
            $out = Invoke-Capture $exe $spec.args
            $found += @{ Path = $exe; Version = (Get-Version $out $spec.version_regex) }
        }
    }
    $found
}

function Test-ToolRef($ref) {
    if ($ref -is [string]) { $id = $ref; $min = $null; $pin = $null }
    else { $id = $ref.id; $min = $ref.min_version; $pin = $ref.version }
    $tool = Get-Tool $id
    if (-not $tool) { Write-Warn (T 'tool_nodef' $id); return }
    if (-not $min) { $min = $tool.min_version }
    if (-not $pin) { $pin = $tool.version }
    $need = @()
    if ($pin) { $need += (T 'need_version' $pin) }
    if ($min) { $need += (T 'need_min' $min) }
    $needText = if ($need) { " (" + ($need -join ", ") + ")" } else { "" }

    $installs = @(Find-ToolInstalls $tool)
    $good = $installs | Where-Object { Test-VerOk $_.Version $min $pin } | Select-Object -First 1
    if ($good) {
        $v = if ($good.Version) { " $($good.Version)" } else { "" }
        Write-Ok "$($tool.name)$v  [$($good.Path)]"
    } elseif ($installs.Count -gt 0) {
        $list = ($installs | ForEach-Object { if ($_.Version) { $_.Version } else { "?" } }) -join ", "
        Write-Bad (T 'tool_unfit' $tool.name $needText $list)
        Write-Hint $tool.install.windows
    } else {
        Write-Bad (T 'tool_missing' $tool.name $needText)
        Write-Hint $tool.install.windows
    }
}

# --- Quest und Zutaten ----------------------------------------------------

function Find-Adb {
    $installs = @(Find-ToolInstalls (Get-Tool "adb"))
    if ($installs.Count) { $installs[0].Path } else { $null }
}

function Test-Quest {
    $adb = Find-Adb
    if (-not $adb) { Write-Bad (T 'quest_no_adb'); return }
    $out = Invoke-Capture $adb "devices -l"
    $lines = @($out -split "`r?`n" | Where-Object { $_ -match '^\S+\s+(device|unauthorized|offline)\b' })
    $ok = @($lines | Where-Object { $_ -match '\sdevice\b' })
    if ($ok.Count) {
        foreach ($l in $ok) {
            $model = if ($l -match 'model:(\S+)') { $Matches[1] } else { "?" }
            Write-Ok (T 'quest_ok' $model (($l -split '\s+')[0]))
        }
    } elseif ($lines | Where-Object { $_ -match 'unauthorized' }) {
        Write-Bad (T 'quest_unauth')
        Write-Hint (T 'quest_unauth_hint')
    } else {
        Write-Bad (T 'quest_none')
        Write-Hint (T 'quest_none_hint')
    }
}

function Test-Assets($recipe, [string] $dir) {
    $oa = $recipe.ingredients.original_assets
    $req = @($oa.required | Where-Object { $_ }); $any = @($oa.any_of | Where-Object { $_ })
    if (-not $oa -or ($req.Count -eq 0 -and $any.Count -eq 0)) {
        Write-Ok (T 'assets_none')
        if ($oa.hint) { Write-Hint (RT $oa 'hint') }
        return
    }
    if (-not $dir) {
        Write-Warn (T 'assets_skip')
        if ($oa.hint) { Write-Hint (RT $oa 'hint') }
        return
    }
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { Write-Bad (T 'assets_nodir' $dir); return }
    foreach ($r in $req) {
        if (Test-Path -LiteralPath (Join-Path $dir $r)) { Write-Ok (T 'assets_item' $r) } else { Write-Bad (T 'assets_item' $r) }
    }
    foreach ($group in $any) {
        $hit = @($group | Where-Object { Test-Path -LiteralPath (Join-Path $dir $_) }) | Select-Object -First 1
        if ($hit) { Write-Ok (T 'assets_item' $hit) } else { Write-Bad (T 'assets_oneof' ($group -join ' | ')) }
    }
}

# --- Spieldaten übertragen (push) -----------------------------------------
# Immer genau EINE Datei per adb push (Ordner-Push bricht unter Windows ab), dazu ein kleines
# Gerätescript, das entpackt, Rechte setzt und die Prüfdateien kontrolliert. Für App-eigenen
# Speicher (run_as) läuft das Script per run-as als die App.

$TmpPkg = "/data/local/tmp/kitchen-push"
$SafeName = '^[A-Za-z0-9._+-]+$'
$SafePath = '^[A-Za-z0-9._/+-]+$'
$ShallowTargets = @("/sdcard", "/sdcard/Download", "/sdcard/Android", "/sdcard/Android/data", "/sdcard/DCIM",
                    "/sdcard/Movies", "/sdcard/Pictures", "/sdcard/Music", "/sdcard/Documents", "/sdcard/Oculus")

function Fail([string] $t) { Write-Host "$(T 'e_prefix')$t" -ForegroundColor Red; exit 1 }

function Format-Arg([string] $a) { if ($a -match '[\s"]') { '"' + ($a -replace '"', '\"') + '"' } else { $a } }

function Invoke-AdbRaw([string] $adb, [string[]] $a) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $adb
    $psi.Arguments = ($a | ForEach-Object { Format-Arg $_ }) -join " "
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $errTask = $p.StandardError.ReadToEndAsync()
    $out = $p.StandardOutput.ReadToEnd()
    $p.WaitForExit()
    @{ Code = $p.ExitCode; Out = ($out + $errTask.Result) }
}

function Get-Sha1([string] $file) { (Get-FileHash -LiteralPath $file -Algorithm SHA1).Hash.ToLower() }

# Wählt das Gerät; liefert die Argumente für adb (-s …) oder bricht ab
function Get-DeviceArgs($r) {
    $adb = Find-Adb
    if (-not $adb) { Fail (T 'e_noadb') }
    if ($Serial) { return @("-s", $Serial) }
    $devs = @((Invoke-AdbRaw $adb @("devices")).Out -split "`r?`n" | Where-Object { $_ -match '^\S+\s+device(\s|$)' } | ForEach-Object { ($_ -split '\s+')[0] })
    if ($devs.Count -eq 0) { Fail (T 'e_nodevice' $r.id) }
    if ($devs.Count -gt 1) { Fail (T 'e_multidevice' ($devs -join ', ')) }
    @()
}

function Invoke-Push($r, [string] $src) {
    $spec = $r.ingredients.push
    if (-not $spec) { Fail (T 'e_nospec' $r.id) }
    if (-not $src) { Fail (T 'e_nosrc' $r.id) }
    if (-not (Test-Path -LiteralPath $src)) { Fail (T 'e_srcmissing' $src) }
    $src = (Resolve-Path -LiteralPath $src).Path

    # Art der Quelle: Ordner, Archiv (zip/tar) oder einzelne Datei
    $isDir = Test-Path -LiteralPath $src -PathType Container
    $ext = [IO.Path]::GetExtension($src).ToLower()
    $kind = if ($isDir) { "dir" } elseif ($ext -eq ".zip" -or $ext -eq ".tar") { "archive" } else { "file" }
    if ($spec.source -and $spec.source -ne $kind) { Fail (T 'e_kind' (T "kind_$($spec.source)")) }

    $appId = if ($App) { $App } elseif ($r.app) { $r.app.id } else { "" }
    $leaf = Split-Path $src -Leaf
    $nm = if ($Name) { $Name } else { $leaf }
    $target = $spec.target -replace '\{app\}', $appId -replace '\{name\}', $nm
    if ($spec.target -match '\{name\}' -and $nm -notmatch $SafeName) { Fail (T 'e_name' $nm) }
    if ($appId -and $appId -notmatch $SafeName) { Fail (T 'e_appid' $appId) }
    if ($target -notmatch $SafePath) { Fail (T 'e_target_chars' $target) }
    $runAs = [bool] $spec.run_as
    if ($runAs -and -not $appId) { Fail (T 'e_runas_noapp') }
    if ($kind -eq "file" -and $leaf -notmatch $SafeName) { Fail (T 'e_filename' $leaf) }

    # Schutz vor zu flachen Zielen (rm -rf beim Ersetzen)
    $depth = @($target.Trim("/") -split "/").Count
    if ($kind -ne "file") {
        if ($target.StartsWith("/")) {
            if ($depth -lt 3 -or $ShallowTargets -contains $target.TrimEnd("/")) { Fail (T 'e_shallow' $target) }
        } elseif ($depth -lt 2) { Fail (T 'e_shallow' $target) }
    }

    if ($spec.source_sha1 -and $kind -ne "dir") {
        $h = Get-Sha1 $src
        if ($h -ne $spec.source_sha1.ToLower()) { Fail (T 'e_sha' $h $spec.source_sha1) }
        Write-Ok (T 'p_sha_ok')
    }
    if ($kind -eq "dir") {
        foreach ($inc in @($spec.include | Where-Object { $_ })) {
            if (-not (Test-Path -LiteralPath (Join-Path $src $inc))) { Fail (T 'e_include' $src $inc) }
        }
    }

    $remoteCheck = if ($kind -eq "file") { "$target/$leaf" } else { $target }
    $pkgExt = switch ($kind) { "dir" { ".tar" } "archive" { $ext } default { ".bin" } }
    $remotePkg = "$TmpPkg$pkgExt"

    # --- Gerätescript (mksh/toybox) ---
    $q = "'"
    $L = New-Object System.Collections.Generic.List[string]
    $L.Add("T=$q$target$q"); $L.Add("P=$q$remotePkg$q")
    $L.Add('case "$T" in /*) ;; *) T="$PWD/$T" ;; esac')   # run-as: relativ zum App-Datenordner
    if ($kind -eq "file") {
        $L.Add("mkdir -p `"`$T`" || exit 4")
        $L.Add("rm -f `"`$T/$leaf`"")
        $L.Add("cp `"`$P`" `"`$T/$leaf`" || exit 5")
    } else {
        $L.Add("rm -rf `"`$T`"")
        $L.Add("mkdir -p `"`$T`" || exit 4")
        $L.Add("cd `"`$T`" || exit 4")
        if ($ext -eq ".zip") { $L.Add("unzip -o -q `"`$P`" -d . || exit 5") } else { $L.Add("tar -xf `"`$P`" || exit 5") }
    }
    if (-not $runAs) {
        # Von adb angelegte Ordner gehören „shell“ – App braucht Lesezugriff
        $L.Add('d="$T"; while case "$d" in /sdcard/Android/data/?*) true ;; *) false ;; esac; do chmod 0777 "$d" 2>/dev/null; d="${d%/*}"; done')
        if ($kind -eq "file") { $L.Add("chmod a+r `"`$T/$leaf`" 2>/dev/null") } else { $L.Add('chmod -R a+rX "$T" 2>/dev/null') }
    }
    $L.Add("fail=0")
    $checks = @($spec.verify | Where-Object { $_ })
    if ($kind -eq "file") { $checks = @($leaf) + $checks }
    foreach ($v in $checks) {
        if ($v -notmatch $SafePath) { Fail (T 'e_verify_chars' $v) }
        $L.Add("if [ -e `"`$T/$v`" ]; then echo `"KITCHEN_OK $v`"; else echo `"KITCHEN_MISSING $v`"; fail=1; fi")
    }
    if ($kind -ne "file") { $L.Add('echo KITCHEN_LS; ls "${T%/*}"') }
    $L.Add('[ $fail = 0 ] || exit 6')
    $deviceScript = ($L -join "`n") + "`n"

    Write-Host ""
    Write-Host (T 'p_title' (RT $r 'title')) -ForegroundColor Cyan
    Write-Host (T 'p_source' $src $kind)
    $where = if ($runAs) { T 'p_appstore' $appId } else { "" }
    Write-Host (T 'p_target' ("$where$target" + $(if ($kind -eq 'file') { "/$leaf" } else { "" })))
    if ($kind -eq "dir" -and $spec.include) { Write-Host (T 'p_selection' ($spec.include -join ', ')) }

    if ($DryRun) {
        Write-Host ""
        Write-Host (T 'p_dry') -ForegroundColor Yellow
        Write-Host $deviceScript -ForegroundColor DarkGray
        return $true
    }

    $adb = Find-Adb
    $sel = @(Get-DeviceArgs $r)
    $prefix = if ($runAs) { "run-as $appId " } else { "" }
    $exists = Invoke-AdbRaw $adb ($sel + @("shell", "${prefix}test -e $remoteCheck && echo KITCHEN_EXISTS"))
    if ($runAs -and $exists.Out -match "not debuggable|unknown package|is unknown") { Fail (T 'e_runas' $appId) }
    if ($exists.Out -match "KITCHEN_EXISTS" -and -not $Replace) {
        if (-not $script:Interactive) { Fail (T 'e_exists' $remoteCheck) }
        if (-not (Read-YesNo (T 'g_push_replace' $remoteCheck))) { return $false }
    }

    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("kitchen-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    New-Item -ItemType Directory -Path $tmp | Out-Null
    try {
        $pkg = $src
        if ($kind -eq "dir") {
            $pkg = Join-Path $tmp "push.tar"
            $tar = Join-Path $env:SystemRoot "System32\tar.exe"
            if (-not (Test-Path $tar)) { $tar = "tar" }
            $targs = @("--format", "ustar", "-C", $src, "-cf", $pkg)
            foreach ($ex in @($spec.exclude | Where-Object { $_ })) { $targs += "--exclude=$ex" }
            $inc = @($spec.include | Where-Object { $_ })
            if ($inc.Count) { $targs += $inc } else { $targs += "." }
            Write-Host (T 'p_packing')
            $res = Invoke-AdbRaw $tar $targs
            if ($res.Code -ne 0) { Fail (T 'e_tar' $res.Out) }
        }
        Write-Host (T 'p_size' ((Get-Item -LiteralPath $pkg).Length / 1MB))
        $scriptFile = Join-Path $tmp "push.sh"
        [IO.File]::WriteAllText($scriptFile, $deviceScript, (New-Object System.Text.UTF8Encoding $false))

        Write-Host (T 'p_copying')
        $res = Invoke-AdbRaw $adb ($sel + @("push", $pkg, $remotePkg))
        if ($res.Code -ne 0) { Fail (T 'e_adbpush' $res.Out) }
        $res = Invoke-AdbRaw $adb ($sel + @("push", $scriptFile, "$TmpPkg.sh"))
        if ($res.Code -ne 0) { Fail (T 'e_adbpush' $res.Out) }
        $null = Invoke-AdbRaw $adb ($sel + @("shell", "chmod 644 $remotePkg $TmpPkg.sh"))

        Write-Host (T 'p_extracting')
        $run = Invoke-AdbRaw $adb ($sel + @("shell", "${prefix}sh $TmpPkg.sh"))
        $null = Invoke-AdbRaw $adb ($sel + @("shell", "rm -f $remotePkg $TmpPkg.sh"))
    } finally {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host ""
    $listing = $false
    foreach ($line in ($run.Out -split "`r?`n")) {
        if ($line -match '^KITCHEN_OK (.+)$') { Write-Ok (T 'p_on_quest' $Matches[1]) }
        elseif ($line -match '^KITCHEN_MISSING (.+)$') { Write-Bad (T 'p_on_quest' $Matches[1]) }
        elseif ($line -eq "KITCHEN_LS") { $listing = $true; Write-Host (T 'p_listing' $target.Substring(0, $target.LastIndexOf('/'))) }
        elseif ($listing -and $line) { Write-Host "  $line" }
        elseif ($line) { Write-Host "  $line" -ForegroundColor DarkGray }
    }
    switch ($run.Code) {
        0 { Write-Host (T 'p_done') -ForegroundColor Green; if ($spec.note) { Write-Host (RT $spec 'note') } }
        4 { Fail (T 'e_mkdir') }
        5 { Fail (T 'e_unpack') }
        6 { Fail (T 'e_verify') }
        default { Fail (T 'e_code' $run.Code) }
    }
    $true
}

# --- Veröffentlichung prüfen (publish-check) ------------------------------
# Prüft ein Git-Repo, bevor es öffentlich wird: keine Spieldaten, nichts daraus Erzeugtes, keine
# Schlüssel, Logs, persönlichen Pfade oder E-Mail-Adressen – im aktuellen Stand UND in den eigenen
# Commits der Historie. Persönliche Muster werden hier auf dem Rechner ermittelt, nie gespeichert.

function Get-PersonalPatterns {
    $set = New-Object System.Collections.Generic.List[string]
    function Add-PathForms([string] $p) {
        if (-not $p -or $p.Length -lt 4) { return }
        $p = $p.TrimEnd('\', '/')
        $set.Add($p); $set.Add(($p -replace '\\', '/'))
        if ($p -match '^([A-Za-z]):[\\/](.*)$') { $set.Add("/" + $Matches[1].ToLower() + "/" + ($Matches[2] -replace '\\', '/')) }
    }
    # Auf CI-Runnern (GitHub Actions) sind Heim- und Arbeitsordner nicht persönlich
    if ($env:GITHUB_ACTIONS -ne "true") {
        Add-PathForms $env:USERPROFILE
        # Oberster Ordner über dem XR-Ordner (z. B. D:\<Name>) – alles darunter ist rechnerspezifisch;
        # allgemeine Systemordner (C:\Users, C:\Program Files …) nie
        $xr = Split-Path $Root -Parent
        $top = $xr
        while ((Split-Path $top -Parent) -and (Split-Path $top -Parent) -ne [IO.Path]::GetPathRoot($top)) { $top = Split-Path $top -Parent }
        if ((Split-Path $top -Leaf) -notin "Users", "Program Files", "Program Files (x86)", "ProgramData", "Windows", "a") { Add-PathForms $top }
    }
    $mail = (& git config --global user.email 2>$null)
    if ($mail -and $mail -notmatch 'noreply') { $set.Add($mail) }
    $extra = Join-Path $HOME ".xr-kitchen\personal-patterns.txt"
    if (Test-Path $extra) { Get-Content $extra | Where-Object { $_.Trim() -and -not $_.StartsWith("#") } | ForEach-Object { $set.Add($_.Trim()) } }
    $set | Select-Object -Unique
}

function Get-RecipeAssetNames {
    $names = New-Object System.Collections.Generic.List[string]
    foreach ($r in Get-Recipes) {
        $oa = $r.ingredients.original_assets
        $all = @($oa.required) + @($oa.any_of | ForEach-Object { $_ }) + @($r.ingredients.push.include)
        foreach ($x in $all) { if ($x) { $leaf = ($x -split '/')[-1]; if ($leaf -match '\.') { $names.Add($leaf.ToLower()) } } }
    }
    $names | Select-Object -Unique
}

function Test-PublishName([string] $path, $rules, $assetNames) {
    # Liefert @(Schwere, Grund) oder $null
    $p = $path -replace '\\', '/'
    foreach ($a in $rules.allow) { if ($p -like $a) { return $null } }
    $leaf = ($p -split '/')[-1]
    $ext = [IO.Path]::GetExtension($leaf).ToLower()
    $slashed = "/" + $p
    foreach ($d in $rules.errors.derived_paths) { if ($slashed -like "*/$d*") { return @("E", "aus Spieldaten erzeugt / Originaldaten-Ordner ($d)") } }
    if ($rules.errors.game_data_ext -contains $ext) { return @("E", "Spieldaten-Endung $ext") }
    if ($assetNames -contains $leaf.ToLower()) { return @("E", "Originaldatei aus einem Rezept") }
    foreach ($g in $rules.errors.game_data_names) { if ($leaf -like $g) { return @("E", "Installer/Spielstand ($g)") } }
    foreach ($g in $rules.errors.circumvention_names) { if ($leaf -like $g) { return @("E", "Entschlüsselung/Kopierschutz-Umgehung ($g) – nie veröffentlichen") } }
    foreach ($g in $rules.errors.secret_names) { if ($leaf -like $g) { return @("E", "Schlüssel/Zugangsdaten ($g)") } }
    foreach ($g in $rules.errors.log_names) { if ($leaf -like $g) { return @("E", "Gerätelog ($g)") } }
    foreach ($d in $rules.warnings.screenshot_paths) { if ($slashed -like "*/$d*") { return @("W", "Aufnahmen/Logs-Ordner ($d)") } }
    if ($rules.warnings.media_ext -contains $ext) { return @("W", "Video – Spielgrafik? ($ext)") }
    if ($rules.warnings.binary_ext -contains $ext) { return @("W", "Binärdatei ($ext) – Herkunft und Lizenz klären") }
    $null
}

# Upstream eines Repos: Remote „upstream“ oder jeder Remote, der nicht zum eigenen GitHub-Konto
# gehört (Konto zur Laufzeit über gh). Liefert @{ Remotes; Exclude } – Exclude sind die
# rev-list-Argumente, die alles Upstream-Eigene ausschließen (inkl. Grenzen eines flachen Klons).
function Get-UpstreamInfo([string] $top) {
    $login = (& gh api user -q .login 2>$null)
    $remotes = @(foreach ($rem in @(& git -C $top remote 2>$null)) {
        if ($rem -eq "public") { continue }   # unser eigenes Veröffentlichungsziel, nie Upstream
        $url = (& git -C $top remote get-url $rem 2>$null)
        if ($rem -eq "upstream" -or ($login -and $url -and $url -notmatch "github\.com[:/]$([regex]::Escape($login))/")) { $rem }
    })
    $exclude = @()
    if ($remotes.Count) {
        foreach ($u in $remotes) { $exclude += "--remotes=$u" }
        $shallowFile = (& git -C $top rev-parse --git-path shallow 2>$null)
        if ($shallowFile) {
            if (-not [IO.Path]::IsPathRooted($shallowFile)) { $shallowFile = Join-Path $top $shallowFile }
            if (Test-Path $shallowFile) { $exclude += @(Get-Content $shallowFile | Where-Object { $_ -match '^[0-9a-f]{40}$' }) }
        }
    }
    @{ Remotes = $remotes; Exclude = $exclude; Login = $login }
}

function Invoke-PublishCheck([string] $path) {
    if (-not $path) { Fail "Pfad fehlt: .\kitchen.ps1 publish-check <Repo-Ordner>" }
    if (-not (Test-Path $path)) { Fail "'$path' existiert nicht." }
    $top = (& git -C $path rev-parse --show-toplevel 2>$null)
    if (-not $top) { Fail "'$path' ist kein Git-Repo." }
    $top = $top -replace '/', '\'
    $rules = Read-Json (Join-Path $Root "rules\publish-rules.json")
    $assetNames = @(Get-RecipeAssetNames)
    $personal = @(Get-PersonalPatterns)
    $errs = New-Object System.Collections.Generic.List[string]
    $warns = New-Object System.Collections.Generic.List[string]
    function RepoGit { & git -C $top @args 2>$null }

    Write-Host ""
    Write-Host "Veröffentlichung prüfen: $top" -ForegroundColor Cyan
    $files = @(RepoGit ls-files)
    Write-Host "  $($files.Count) Dateien im Repo, $($personal.Count) persönliche Muster von diesem Rechner"

    # Upstream erkennen: Remote „upstream“ oder jeder Remote, der nicht zum eigenen GitHub-Konto
    # gehört (Konto zur Laufzeit über gh). Dann zählen nur Dateien, die eigene Commits angefasst haben.
    $up = Get-UpstreamInfo $top
    $upRemotes = $up.Remotes
    $range = @("HEAD")
    if ($upRemotes.Count) { $range += "--not"; $range += $up.Exclude }
    $own = @(RepoGit rev-list @range)
    $scope = $files
    if ($upRemotes.Count) {
        $touched = @{}; foreach ($f in @(RepoGit log @range --name-only --format=)) { if ($f) { $touched[$f] = $true } }
        $scope = @($files | Where-Object { $touched.ContainsKey($_) })
        Write-Host "  Upstream: $($upRemotes -join ', ') – geprüft werden $($scope.Count) Dateien, die eigene Commits geändert haben"
    }
    $inScope = @{}; foreach ($f in $scope) { $inScope[$f] = $true }

    # 1. Dateinamen und Größen im aktuellen Stand
    $limit = [long] $rules.max_file_mb * 1MB
    foreach ($f in $scope) {
        $hit = Test-PublishName $f $rules $assetNames
        if ($hit) { if ($hit[0] -eq "E") { $errs.Add("$f – $($hit[1])") } else { $warns.Add("$f – $($hit[1])") } }
        $full = Join-Path $top $f
        if ((Test-Path -LiteralPath $full -PathType Leaf) -and (Get-Item -LiteralPath $full).Length -gt $limit) {
            $warns.Add(("{0} – groß ({1:N1} MB)" -f $f, ((Get-Item -LiteralPath $full).Length / 1MB)))
        }
    }

    # 2. Persönliche Pfade/Adressen im Inhalt
    # Treffer als „Datei:Zeile: Fundstelle“ (-o zeigt nur das gefundene Stück)
    function Get-GrepHits([string[]] $gargs) {
        foreach ($line in @(RepoGit grep -I -n -o @gargs)) {
            if ($line -match '^(.+?):(\d+):(.*)$' -and $inScope.ContainsKey($Matches[1])) { "$($Matches[1]):$($Matches[2]): $($Matches[3])" }
        }
    }
    if ($personal.Count) {
        $gargs = @("-F", "-i")
        foreach ($p in $personal) { $gargs += @("-e", $p) }
        foreach ($h in @(Get-GrepHits $gargs)) { $errs.Add("persönlicher Pfad/Adresse: $h") }
    }
    # Vergleich ohne Rücksicht auf \ / und doppelte Trenner (JSON schreibt \\)
    $ignore = @($rules.generic_path_ignore | ForEach-Object { (($_ -replace '\\', '/') -replace '/+', '/').ToLower() })
    foreach ($rx in $rules.generic_path_patterns) {
        foreach ($h in @(Get-GrepHits @("-E", "-e", $rx))) {
            $norm = (($h -replace '\\', '/') -replace '/+', '/').ToLower()
            if ($ignore | Where-Object { $norm.Contains($_) }) { continue }
            $warns.Add("Benutzerpfad: $h")
        }
    }

    # 3. Lizenzdatei
    if (-not ($rules.license_files | Where-Object { Test-Path (Join-Path $top $_) })) { $errs.Add("keine LICENSE/COPYING-Datei im Hauptordner") }

    # 4. Eigene Commits der Historie (alles, was nicht schon beim Upstream liegt)
    Write-Host "  $($own.Count) eigene Commits in der Historie$(if ($upRemotes.Count) { ' (ohne Upstream)' })"
    if ($own.Count) {
        $current = @{}; foreach ($f in $files) { $current[$f] = $true }
        foreach ($f in @(RepoGit log @range --diff-filter=A --name-only --format= | Select-Object -Unique)) {
            if (-not $f -or $current.ContainsKey($f)) { continue }
            $hit = Test-PublishName $f $rules $assetNames
            if ($hit -and $hit[0] -eq "E") { $errs.Add("nur noch in der Historie: $f – $($hit[1])") }
        }
        foreach ($p in $personal) {
            $c = @(RepoGit log @range --format=%h -i "-S$p")
            if ($c.Count) { $errs.Add("persönlicher Pfad/Adresse '$p' in $($c.Count) Commit(s) der Historie, z. B. $($c[0])") }
        }
        $mails = @(RepoGit log @range "--format=%ae%n%ce" | Select-Object -Unique | Where-Object { $_ -and $_ -notmatch 'noreply' })
        foreach ($m in $mails) { $warns.Add("Commit-E-Mail sichtbar: $m – ggf. GitHub-noreply-Adresse verwenden") }
    }

    # 5. Submodule (werden separat veröffentlicht und geprüft)
    $subs = @(RepoGit submodule status | Where-Object { $_ } | ForEach-Object { ($_.Trim() -split '\s+')[1] })
    if ($subs.Count) {
        $list = ($subs | Select-Object -First 6) -join ", "
        $warns.Add("$($subs.Count) Submodul(e) – eigene Änderungen dort separat prüfen: $list$(if ($subs.Count -gt 6) { ', …' })")
    }

    Write-Host ""
    $show = 25
    if ($errs.Count) {
        Write-Host "FEHLER ($($errs.Count)) – so nicht veröffentlichen:" -ForegroundColor Red
        $errs | Select-Object -First $show | ForEach-Object { Write-Host "  ✗ $_" -ForegroundColor Red }
        if ($errs.Count -gt $show) { Write-Host "  … und $($errs.Count - $show) weitere" -ForegroundColor Red }
    }
    if ($warns.Count) {
        Write-Host "HINWEISE ($($warns.Count)) – prüfen:" -ForegroundColor Yellow
        $warns | Select-Object -First $show | ForEach-Object { Write-Host "  ! $_" -ForegroundColor Yellow }
        if ($warns.Count -gt $show) { Write-Host "  … und $($warns.Count - $show) weitere" -ForegroundColor Yellow }
    }
    if (-not $errs.Count -and -not $warns.Count) { Write-Host "Sauber – nichts gefunden." -ForegroundColor Green }
    elseif (-not $errs.Count) { Write-Host "Keine Fehler; Hinweise bitte ansehen." -ForegroundColor Green }
    if ($errs.Count) { exit 1 }
}

# --- Veröffentlichungszweig vorbereiten (publish-prepare) -----------------
# Erzeugt den Zweig xr-public: bei Forks der neueste enthaltene Upstream-Commit plus EIN Commit
# mit dem aktuellen Stand (HEAD), sonst ein einzelner Commit ohne Vorgeschichte. Autor ist die
# GitHub-noreply-Adresse. Arbeitsstand, HEAD und andere Zweige bleiben unberührt (commit-tree).

function Get-NoreplyIdentity([string] $top) {
    $mail = (& git -C $top config user.email 2>$null)
    $name = $null
    $login = (& gh api user -q .login 2>$null)
    if (-not ($mail -match 'noreply')) {
        $id = (& gh api user -q .id 2>$null)
        if ($id -and $login) { $mail = "$id+$login@users.noreply.github.com" } else { $mail = $null }
    }
    $name = if ($login) { $login } else { (& git -C $top config user.name 2>$null) }
    if (-not $mail -or -not $name) { Fail "Keine GitHub-noreply-Adresse ermittelbar (gh anmelden oder user.email auf …@users.noreply.github.com setzen)." }
    @{ Name = $name; Mail = $mail }
}

function Invoke-PublishPrepare([string] $path, [string] $branch, [string] $from) {
    if (-not $branch) { $branch = "xr-public" }
    if (-not $path -or -not (Test-Path $path)) { Fail "Pfad fehlt/existiert nicht: .\kitchen.ps1 publish-prepare <Repo-Ordner>" }
    $top = (& git -C $path rev-parse --show-toplevel 2>$null)
    if (-not $top) { Fail "'$path' ist kein Git-Repo." }
    $top = $top -replace '/', '\'
    function RepoGit { & git -C $top @args 2>$null }
    # Quelle: ausgecheckter Stand oder ein angegebener Zweig/Commit (ohne Umschalten des Arbeitsordners)
    $src = if ($from) { $from } else { "HEAD" }
    if (-not (RepoGit rev-parse --verify -q "$src^{commit}")) { Fail "Quelle '$src' gibt es in diesem Repo nicht." }
    $current = if ($from) { $from } else { (RepoGit rev-parse --abbrev-ref HEAD) }
    if ($current -eq $branch) { Fail "Der Zweig '$branch' selbst kann nicht die Quelle sein." }
    $dirty = if ($from) { @() } else { @(RepoGit status --porcelain --untracked-files=no) }
    $up = Get-UpstreamInfo $top
    $who = Get-NoreplyIdentity $top
    $head = (RepoGit rev-parse $src)
    $tree = (RepoGit rev-parse "$src^{tree}")

    Write-Host ""
    Write-Host "Veröffentlichungszweig vorbereiten: $top" -ForegroundColor Cyan
    Write-Host "  Quelle: Zweig $current @ $($head.Substring(0, 10))"
    if ($dirty.Count) { Write-Warn "$($dirty.Count) nicht committete Änderung(en) – sie kommen NICHT mit (nur der letzte Commit zählt)" }

    # Basis: neuester Upstream-Commit, von dem die eigenen Commits abzweigen
    $base = $null
    if ($up.Remotes.Count) {
        $boundary = @(RepoGit rev-list --boundary $src --not @($up.Exclude) | Where-Object { $_ -like "-*" } | ForEach-Object { $_.Substring(1) })
        foreach ($b in $boundary) {
            $newest = $true
            foreach ($o in $boundary) { if ($o -ne $b) { & git -C $top merge-base --is-ancestor $o $b 2>$null; if ($LASTEXITCODE -ne 0) { $newest = $false; break } } }
            if ($newest) { $base = $b; break }
        }
        if (-not $base -and $boundary.Count) { Fail "Kein eindeutiger Upstream-Stand gefunden (mehrere Abzweigungen) – bitte Upstream zuerst einmergen." }
        if ($base) {
            $baseInfo = (RepoGit log -1 --format="%h %ad %s" --date=short $base)
            Write-Host "  Upstream: $($up.Remotes -join ', ') – Basis $baseInfo"
        } else { Write-Host "  Upstream: $($up.Remotes -join ', ') – keine eigenen Commits, nichts zu tun"; return }
    } else {
        Write-Host "  Kein Upstream – ein einzelner Commit ohne Vorgeschichte"
    }

    # Schon veröffentlicht (Remote „public“)? Dann wird der neue Stand ein Folge-Commit auf den
    # veröffentlichten Zweig – ein normaler Push reicht, die Klone anderer bleiben gültig.
    $pubTip = $null; $pubBranch = $null
    if (RepoGit remote get-url public) {
        $pubBranch = (RepoGit config kitchen.publicbranch)
        if (-not $pubBranch) {
            $sym = @(RepoGit ls-remote --symref public HEAD | Where-Object { $_ -match '^ref: refs/heads/(\S+)\s+HEAD' })
            if ($sym.Count -and $sym[0] -match '^ref: refs/heads/(\S+)') { $pubBranch = $Matches[1] }
        }
        if ($pubBranch) {
            $null = RepoGit fetch -q public "+refs/heads/${pubBranch}:refs/remotes/public/$pubBranch"
            $pubTip = (RepoGit rev-parse --verify -q "refs/remotes/public/$pubBranch")
        }
        # Nur auf Stände aufbauen, die selbst aus publish-prepare stammen – sonst würde eine alte,
        # unbereinigte Historie (z. B. mit privater E-Mail) für immer festgeschrieben
        if ($pubTip -and -not ((RepoGit log -1 --format=%s $pubTip) -like "XR-Port:*")) {
            Write-Warn "public/$pubBranch stammt nicht aus publish-prepare (alte Historie) – frischer Einzel-Commit; zum Ersetzen ist ein Force-Push nötig"
            $pubTip = $null
        }
        if ($pubTip) { Write-Host "  Veröffentlicht: public/$pubBranch @ $($pubTip.Substring(0, 10)) – neuer Stand wird ein Folge-Commit (Update)" }
    }

    # Submodule, die auf nur lokal vorhandene Commits zeigen. Wurde ein solches Submodul selbst schon
    # vorbereitet (Zweig xr-public mit gleichem Inhalt) und veröffentlicht (Remote „public“, Zweig
    # dort vorhanden), wird der Verweis auf den öffentlichen Commit und die öffentliche Adresse umgestellt.
    $localSubs = @()
    $remaps = @()   # @{ Path; Sha; Url }
    foreach ($line in @(RepoGit ls-tree -r $src | Where-Object { $_ -match '^160000 commit ([0-9a-f]{40})\t(.+)$' })) {
        $null = $line -match '^160000 commit ([0-9a-f]{40})\t(.+)$'
        $sha = $Matches[1]; $sub = $Matches[2]
        $subDir = Join-Path $top $sub
        if (-not (Test-Path (Join-Path $subDir ".git"))) { $localSubs += "$sub (nicht initialisiert – Herkunft von $($sha.Substring(0, 10)) prüfen)"; continue }
        # veröffentlicht = in einem Remote-Zweig oder einem Tag enthalten (Releases liegen oft nur als Tag vor)
        $onRemote = @(& git -C $subDir for-each-ref --contains $sha refs/remotes refs/tags 2>$null)
        # Grenz-Commit eines flachen Klons = vom Upstream abgerufen
        $subShallow = (& git -C $subDir rev-parse --git-path shallow 2>$null)
        if ($subShallow -and -not [IO.Path]::IsPathRooted($subShallow)) { $subShallow = Join-Path $subDir $subShallow }
        if (-not $onRemote.Count -and $subShallow -and (Test-Path $subShallow) -and (Select-String -Path $subShallow -SimpleMatch $sha -Quiet)) { $onRemote = @("shallow") }
        if ($onRemote.Count) { continue }
        $pubSha = (& git -C $subDir rev-parse --verify -q "refs/heads/$branch" 2>$null)
        $pubUrl = (& git -C $subDir remote get-url public 2>$null)
        $sameTree = $pubSha -and ((& git -C $subDir rev-parse "$sha^{tree}" 2>$null) -eq (& git -C $subDir rev-parse "$pubSha^{tree}" 2>$null))
        $isPushed = $pubUrl -and $pubSha -and (@(& git -C $subDir ls-remote public 2>$null | Where-Object { $_ -match "^$pubSha\s" }).Count -gt 0)
        if ($sameTree -and $isPushed) { $remaps += @{ Path = $sub; Sha = $pubSha; Url = ($pubUrl -replace '\.git$', '') + ".git" } }
        elseif ($sameTree -and $pubSha) { $localSubs += "$sub – Zweig $branch ist vorbereitet, aber noch nicht als Remote 'public' veröffentlicht" }
        else { $localSubs += "$sub @ $($sha.Substring(0, 10)) – Commit nur lokal: dort zuerst publish-prepare, dann veröffentlichen (Remote 'public')" }
    }

    # Verweise umstellen: neuer Baum über einen temporären Index (Arbeitsstand bleibt unberührt)
    if ($remaps.Count) {
        $idx = [IO.Path]::GetTempFileName()
        $gmFile = [IO.Path]::GetTempFileName()
        $env:GIT_INDEX_FILE = $idx
        try {
            $null = RepoGit read-tree $src
            [IO.File]::WriteAllText($gmFile, ((RepoGit show "${src}:.gitmodules") -join "`n") + "`n", (New-Object System.Text.UTF8Encoding $false))
            foreach ($m in $remaps) {
                $null = RepoGit update-index --cacheinfo "160000,$($m.Sha),$($m.Path)"
                $names = @(& git config -f $gmFile --get-regexp '^submodule\..*\.path$' 2>$null | Where-Object { ($_ -split ' ', 2)[1] -eq $m.Path })
                if ($names.Count) {
                    $key = ($names[0] -split ' ', 2)[0] -replace '\.path$', '.url'
                    & git config -f $gmFile $key $m.Url
                }
                Write-Ok "Submodul $($m.Path) → $($m.Url) @ $($m.Sha.Substring(0, 10))"
            }
            $blob = (RepoGit hash-object -w $gmFile)
            $null = RepoGit update-index --cacheinfo "100644,$blob,.gitmodules"
            $tree = (RepoGit write-tree)
        } finally {
            Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue
            Remove-Item $idx, $gmFile -ErrorAction SilentlyContinue
        }
    }

    $repoName = Split-Path $top -Leaf
    if ($pubTip -and ((RepoGit rev-parse "$pubTip^{tree}") -eq $tree)) {
        Write-Ok "Keine Änderungen seit der letzten Veröffentlichung (public/$pubBranch) – nichts zu tun"
        $null = RepoGit branch -f $branch $pubTip
        return
    }
    $parents = @()
    if ($pubTip) {
        $parents += $pubTip
        # Neuerer Upstream eingemergt? Dann zusätzlich als zweite Eltern-Linie, damit die Herkunft sichtbar bleibt
        if ($base) { & git -C $top merge-base --is-ancestor $base $pubTip 2>$null; if ($LASTEXITCODE -ne 0) { $parents += $base } }
        $msg = "XR-Port: Update von $repoName (Stand $(Get-Date -Format yyyy-MM-dd))`n`nÄnderungen seit der letzten Veröffentlichung zusammengefasst."
    } else {
        if ($base) { $parents += $base }
        $msg = "XR-Port: öffentlicher Stand von $repoName`n`nAlle eigenen Änderungen zusammengefasst in einem Commit (Stand $(Get-Date -Format yyyy-MM-dd))."
    }
    if ($base) { $msg += "`nBasis: $((RepoGit remote get-url $up.Remotes[0])) @ $($base.Substring(0, 12))" }
    # Claude als Mitwirkender: GitHub zählt nur Commit-Autoren. Erstveröffentlichung = Autor Nutzer,
    # jedes Update = Autor Claude (Committer bleibt der Nutzer); der jeweils andere als Co-Autor.
    $claude = [pscustomobject]@{ Name = "Claude"; Mail = "noreply@anthropic.com" }
    if ($pubTip) { $author = $claude; $co = $who } else { $author = $who; $co = $claude }
    $msg += "`n`nCo-Authored-By: $($co.Name) <$($co.Mail)>"
    $env:GIT_AUTHOR_NAME = $author.Name; $env:GIT_AUTHOR_EMAIL = $author.Mail
    $env:GIT_COMMITTER_NAME = $who.Name; $env:GIT_COMMITTER_EMAIL = $who.Mail
    try {
        $msgFile = [IO.Path]::GetTempFileName()
        [IO.File]::WriteAllText($msgFile, $msg, (New-Object System.Text.UTF8Encoding $false))
        $ctArgs = @("commit-tree", $tree, "-F", $msgFile)
        foreach ($p in $parents) { $ctArgs += @("-p", $p) }
        $new = (RepoGit @ctArgs)
    } finally {
        Remove-Item Env:GIT_AUTHOR_NAME, Env:GIT_AUTHOR_EMAIL, Env:GIT_COMMITTER_NAME, Env:GIT_COMMITTER_EMAIL -ErrorAction SilentlyContinue
        Remove-Item $msgFile -ErrorAction SilentlyContinue
    }
    if (-not $new) { Fail "git commit-tree fehlgeschlagen." }
    $null = RepoGit branch -f $branch $new
    Write-Ok "Zweig $branch @ $($new.Substring(0, 10)) (Autor $($author.Name) <$($author.Mail)>)"
    foreach ($s in $localSubs) { Write-Warn "Submodul: $s" }

    # publish-check auf dem neuen Zweig in einem temporären Arbeitsordner
    $wt = Join-Path ([IO.Path]::GetTempPath()) ("kitchen-pub-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $null = & git -C $top worktree add --detach $wt $branch 2>&1
    try {
        powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath publish-check $wt
        $code = $LASTEXITCODE
    } finally {
        $null = & git -C $top worktree remove --force $wt 2>&1
    }
    Write-Host ""
    if ($code -eq 0 -and -not $localSubs.Count) { Write-Host "Bereit zum Veröffentlichen: Zweig $branch" -ForegroundColor Green }
    elseif ($code -eq 0) { Write-Host "Zweig $branch ist sauber, aber Submodule müssen zuerst veröffentlicht werden (siehe oben)." -ForegroundColor Yellow }
    else { Write-Host "Zweig $branch ist noch NICHT veröffentlichungsfähig – Fehler oben beheben, committen, erneut vorbereiten." -ForegroundColor Red; exit 1 }
}

# --- Veröffentlichen (publish) --------------------------------------------
# publish-prepare + Push. Erstveröffentlichung: neues Repo (gh repo create) oder Fork (-Fork owner/repo),
# Standardzweig setzen, Remote „public“ + kitchen.publicbranch eintragen. Danach: Update per normalem Push.

function Invoke-Publish([string] $path) {
    if (-not $path -or -not (Test-Path $path)) { Fail "Pfad fehlt: .\kitchen.ps1 publish <Repo-Ordner> [<Quellzweig>] [-Name xr.<name>] [-Fork owner/repo]" }
    $top = (& git -C $path rev-parse --show-toplevel 2>$null)
    if (-not $top) { Fail "'$path' ist kein Git-Repo." }
    function RepoGit { & git -C $top @args 2>$null }
    $login = (& gh api user -q .login 2>$null)
    if (-not $login) { Fail "gh ist nicht angemeldet (gh auth login)." }

    # 1. Vorbereiten und prüfen (eigener Prozess, damit ein Fehler hier sauber abbricht)
    $ppArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $PSCommandPath, "publish-prepare", $top)
    if ($Source) { $ppArgs += $Source }
    powershell @ppArgs
    if ($LASTEXITCODE -ne 0) { Fail "publish-prepare ist nicht sauber – nichts veröffentlicht." }
    $pub = (RepoGit rev-parse --verify -q "refs/heads/xr-public")
    if (-not $pub) { Fail "Zweig xr-public fehlt." }

    $pubUrl = (RepoGit remote get-url public)
    if ($pubUrl) {
        # 2. Update eines schon veröffentlichten Repos
        $target = (RepoGit config kitchen.publicbranch); if (-not $target) { $target = "main" }
        $null = RepoGit fetch -q public "+refs/heads/${target}:refs/remotes/public/$target"
        $tip = (RepoGit rev-parse --verify -q "refs/remotes/public/$target")
        if ($tip -eq $pub) { Write-Ok "Schon aktuell: $pubUrl ($target)"; return }
        if ($tip) { & git -C $top merge-base --is-ancestor $tip $pub 2>$null; if ($LASTEXITCODE -ne 0) { Fail "public/$target ist kein Vorgänger von xr-public – dafür wäre ein Force-Push nötig (bewusst nicht automatisch)." } }
        $what = "Update von $pubUrl (Zweig $target)"
    } else {
        # 3. Erstveröffentlichung
        if (-not $Name) { Fail "Für die Erstveröffentlichung -Name angeben (Schema: xr.<name>, wie die App-ID)." }
        $target = if ($Branch) { $Branch } elseif ($Fork) { "xr-quest" } else { "main" }
        $pubUrl = "https://github.com/$login/$Name.git"
        if (& gh repo view "$login/$Name" --json name 2>$null) { Fail "$login/$Name existiert schon – anderen Namen wählen oder als Remote 'public' eintragen." }
        $what = if ($Fork) { "neuer öffentlicher Fork $login/$Name von $Fork (Zweig $target)" } else { "neues öffentliches Repo $login/$Name (Zweig $target)" }
    }

    Write-Host ""
    Write-Host "Veröffentlichen: $what" -ForegroundColor Cyan
    if (-not $Yes) {
        if ([Console]::IsInputRedirected) { Fail "Ohne Rückfrage nur mit -Yes." }
        if (-not (Read-YesNo "Jetzt öffentlich machen?")) { Write-Host (T 'aborted'); return }
    }

    if (-not (RepoGit remote get-url public)) {
        if ($Fork) {
            $null = & gh repo fork $Fork --fork-name $Name --clone=false 2>&1
            for ($i = 0; $i -lt 30 -and -not (& gh repo view "$login/$Name" --json name 2>$null); $i++) { Start-Sleep -Seconds 4 }
        } else {
            $desc = if ($Description) { $Description } else { "Teil der XR-Port-Kitchen (Meta Quest)." }
            $null = & gh repo create "$login/$Name" --public --description $desc 2>&1
        }
        if (-not (& gh repo view "$login/$Name" --json name 2>$null)) { Fail "Repo $login/$Name konnte nicht angelegt werden." }
        $null = RepoGit remote add public $pubUrl
        $null = RepoGit config kitchen.publicbranch $target
    }
    & git -C $top push public "refs/heads/xr-public:refs/heads/$target"
    if ($LASTEXITCODE -ne 0) { Fail "Push fehlgeschlagen. (Flacher Klon? Dann nur in einen Fork des Originals pushbar: -Fork owner/repo)" }
    $repoSlug = ($pubUrl -replace '^https://github.com/', '' -replace '\.git$', '')
    $null = & gh repo edit $repoSlug --default-branch $target 2>&1
    if ($Description -and $Fork) { $null = & gh repo edit $repoSlug --description $Description 2>&1 }
    Write-Host ""
    Write-Ok "Öffentlich: https://github.com/$repoSlug (Zweig $target)"
    Write-Hint "Rezept ergänzen: port.repo = https://github.com/$repoSlug, port.branch = $target"
}

# --- Rezepte prüfen (lint) ------------------------------------------------

function Invoke-Lint {
    $total = 0
    foreach ($dir in Get-ChildItem (Join-Path $Root "recipes") -Directory | Where-Object { $_.Name -notlike "_*" }) {
        $errs = New-Object System.Collections.Generic.List[string]
        $p = Join-Path $dir.FullName "recipe.json"
        if (-not (Test-Path $p)) { $errs.Add("recipe.json fehlt") }
        else {
            try { $r = Read-Json $p } catch { $errs.Add("kein gültiges JSON: $_"); $r = $null }
            if ($r) {
                foreach ($f in "id", "title", "status", "game", "base", "ratings", "effort", "ingredients", "tools", "stages", "xr_modes") {
                    if ($null -eq $r.$f) { $errs.Add("Pflichtfeld '$f' fehlt") }
                }
                if ($r.id -ne $dir.Name) { $errs.Add("id '$($r.id)' passt nicht zum Ordnernamen") }
                if ($r.status -notin "draft", "in-progress", "playable", "verified") { $errs.Add("status '$($r.status)' unbekannt") }
                if ($r.app -and $r.app.id -notmatch '^xr\.[a-z0-9.]+$') { $errs.Add("App-ID '$($r.app.id)' verletzt die Regel xr.<name>") }
                foreach ($k in "portability", "xr_potential", "base_maturity") {
                    $v = $r.ratings.$k
                    if ($v -isnot [int] -or $v -lt 1 -or $v -gt 5) { $errs.Add("ratings.$k muss 1–5 sein") }
                }
                foreach ($b in @($r.base)) { if (-not ($b.name -and $b.url -and $b.license)) { $errs.Add("base: name/url/license fehlt bei '$($b.name)'") } }
                foreach ($t in @($r.tools)) {
                    $tid = if ($t -is [string]) { $t } else { $t.id }
                    if (-not (Test-Path (Join-Path $Root "tools\$tid.json"))) { $errs.Add("Küchengerät '$tid' hat keine tools\$tid.json") }
                }
                foreach ($m in $r.xr_modes.PSObject.Properties) {
                    if ($m.Name -notin "screen", "passthrough", "tabletop", "diorama", "full-vr") { $errs.Add("XR-Modus '$($m.Name)' unbekannt") }
                    if ($m.Value -notin "done", "partial", "planned", "unsuitable") { $errs.Add("XR-Modus $($m.Name): Wert '$($m.Value)' unbekannt") }
                }
                foreach ($s in @($r.stages)) {
                    if (-not ($s.id -and $s.title -and $s.done_when)) { $errs.Add("Stufe '$($s.id)': id/title/done_when fehlt") }
                    if ($s.status -notin "done", "open", "blocked", "n/a") { $errs.Add("Stufe '$($s.id)': status '$($s.status)' unbekannt") }
                }
                $ps = $r.ingredients.push
                if ($ps) {
                    if (-not $ps.target) { $errs.Add("push.target fehlt") }
                    elseif (($ps.target -replace '\{app\}', 'x' -replace '\{name\}', 'x') -notmatch $SafePath) { $errs.Add("push.target enthält unerlaubte Zeichen") }
                    if ($ps.source -and $ps.source -notin "dir", "archive", "file") { $errs.Add("push.source '$($ps.source)' unbekannt") }
                }
                if (-not $r.title_en) { $errs.Add("title_en fehlt (englischer Titel für den Assistenten)") }
                $bd = $r.build
                if ($bd) {
                    if ($bd.repo -notmatch '^https://') { $errs.Add("build.repo muss eine https-Adresse sein") }
                    if (-not @($bd.steps).Count) { $errs.Add("build.steps fehlt") }
                    if (-not $bd.apk) { $errs.Add("build.apk fehlt") }
                    elseif ($bd.apk -match '^(/|[A-Za-z]:|\.\.)') { $errs.Add("build.apk muss relativ zum Repo sein") }
                }
                $txt = Get-Content $p -Raw
                if ($txt -match '(?i)[A-Z]:\\\\(Users|Oliver)') { $errs.Add("enthält einen lokalen Rechnerpfad – <XR-Ordner>/… verwenden") }
                if (-not (Test-Path (Join-Path $dir.FullName "RECIPE.md"))) { $errs.Add("RECIPE.md fehlt") }
            }
        }
        if ($errs.Count) { foreach ($e in $errs) { Write-Bad "$($dir.Name): $e" }; $total += $errs.Count }
        else { Write-Ok $dir.Name }
    }
    if ($total) { Write-Host "$total Fehler." -ForegroundColor Red; exit 1 }
}

# --- Befehle --------------------------------------------------------------

function Show-List {
    Write-Host ""
    Write-Host ("{0,-24} {1,-12} {2,-7} {3,-7} {4}" -f "Rezept/recipe", "Stand", "Port.", "XR", "Titel")
    foreach ($r in Get-Recipes) {
        Write-Host ("{0,-24} {1,-12} {2,-7} {3,-7} {4}" -f $r.id, $r.status, (Stars $r.ratings.portability), (Stars $r.ratings.xr_potential), (RT $r 'title'))
    }
    Write-Host ""
}

function Show-Recipe($r) {
    Write-Host ""
    Write-Host (RT $r 'title') -ForegroundColor Cyan
    Write-Host ("Stand: {0}{1}" -f $r.status, $(if ($r.last_verified) { " – zuletzt geprüft $($r.last_verified)" } else { "" }))
    if ($r.app) { Write-Host "App: $($r.app.id)  Version $($r.app.version)" }
    Write-Host ""
    Write-Host ("Portierbarkeit  {0}   XR-Potenzial {1}   Reife der Basis {2}" -f (Stars $r.ratings.portability), (Stars $r.ratings.xr_potential), (Stars $r.ratings.base_maturity))
    if ($r.ratings.note) { Write-Host "  $($r.ratings.note)" -ForegroundColor DarkGray }
    Write-Host "Aufwand: mit fertiger APK $($r.effort.with_apk) · aus dem Quellcode $($r.effort.from_source)"
    Write-Host ""
    Write-Host "Spiel: $($r.game.name) ($($r.game.rights_holder)) – erhältlich: $($r.game.buy -join ', ')"
    Write-Host "Aufbauend auf:"
    foreach ($b in $r.base) { Write-Host "  $($b.name) [$($b.license)] $($b.url)" }
    Write-Host ""
    Write-Host "XR-Modi:"
    foreach ($p in $r.xr_modes.PSObject.Properties) { Write-Host ("  {0,-12} {1}" -f $p.Name, $p.Value) }
    Write-Host ""
    Write-Host "Stufen:"
    foreach ($s in $r.stages) {
        $mark = switch ($s.status) { "done" { "[x]" } "blocked" { "[!]" } "n/a" { "[-]" } default { "[ ]" } }
        Write-Host "  $mark $($s.id)  $($s.title)"
    }
    Write-Host ""
    Write-Host "Details: recipes\$($r.id)\RECIPE.md" -ForegroundColor DarkGray
}

function Invoke-Check($r, [string] $dir, [bool] $playOnly) {
    $script:Problems = 0
    Write-Host ""
    Write-Host (T 'check_title' (RT $r 'title')) -ForegroundColor Cyan
    Write-Host ""
    Write-Host (T $(if ($playOnly) { 'check_tools_play' } else { 'check_tools' }))
    foreach ($t in $r.tools) {
        if ($playOnly -and $t -isnot [string] -and $t.only_for -eq "build") { continue }
        Test-ToolRef $t
    }
    Write-Host ""
    Write-Host (T 'check_assets')
    Test-Assets $r $dir
    Write-Host ""
    Write-Host (T 'check_quest')
    Test-Quest
    Write-Host ""
    if ($script:Problems -eq 0) { Write-Host (T 'check_ok' "recipes\$($r.id)\RECIPE.md") -ForegroundColor Green }
    else { Write-Host (T 'check_open' $script:Problems) -ForegroundColor Yellow }
}

function Invoke-Doctor {
    $script:Problems = 0
    Write-Host ""
    Write-Host (T 'menu_doctor') -ForegroundColor Cyan
    Get-ChildItem (Join-Path $Root "tools") -Filter *.json | ForEach-Object { Test-ToolRef $_.BaseName }
    Write-Host ""
    Write-Host (T 'check_quest')
    Test-Quest
    Write-Host ""
}

# --- Nachladen (nur nach Rückfrage) ----------------------------------------

function Get-Download([string] $url, [string] $dest) {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
        Write-Host (T 'dl_downloading' $url) -ForegroundColor DarkGray
        (New-Object System.Net.WebClient).DownloadFile($url, $dest)   # deutlich schneller als Invoke-WebRequest in PS 5.1
        $true
    } catch {
        Write-Host (T 'dl_fail' $_.Exception.Message) -ForegroundColor Red
        $false
    }
}

# Android Platform-Tools (adb) von Google in den Kitchen-Ordner laden
function Install-PlatformTools {
    if (-not (Read-YesNo (T 'dl_adb_offer' $KitchenCfg.platform_tools.terms))) { return $false }
    $zip = Join-Path $env:KITCHEN_TOOLS "platform-tools.zip"
    if (-not (Get-Download $KitchenCfg.platform_tools.windows $zip)) { return $false }
    Expand-Archive -LiteralPath $zip -DestinationPath $env:KITCHEN_TOOLS -Force
    Remove-Item $zip -ErrorAction SilentlyContinue
    $adb = Join-Path $env:KITCHEN_TOOLS "platform-tools\adb.exe"
    if (Test-Path $adb) { Write-Ok (T 'dl_done' $adb); return $true }
    Write-Host (T 'dl_fail' $adb) -ForegroundColor Red
    $false
}

# Kitchen selbst aktualisieren: per git (wenn ein Klon) oder als ZIP von GitHub
function Invoke-SelfUpdate {
    if (-not (Read-YesNo (T 'upd_offer' $KitchenCfg.repo))) { return }
    if ((Test-Path (Join-Path $Root ".git")) -and (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host (T 'upd_git')
        $out = (& git -C $Root pull --ff-only 2>&1 | Out-String)
        if ($LASTEXITCODE -eq 0) { Write-Host (T 'upd_done') -ForegroundColor Green } else { Write-Host (T 'upd_fail' $out.Trim()) -ForegroundColor Red }
        return
    }
    Write-Host (T 'upd_zip')
    $zip = Join-Path ([IO.Path]::GetTempPath()) "xr-port-kitchen-update.zip"
    if (-not (Get-Download "$($KitchenCfg.repo)/archive/refs/heads/$($KitchenCfg.branch).zip" $zip)) { return }
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("kitchen-upd-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    try {
        Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force
        $src = Get-ChildItem $tmp -Directory | Select-Object -First 1
        Copy-Item -Path (Join-Path $src.FullName "*") -Destination $Root -Recurse -Force
        Write-Host (T 'upd_done') -ForegroundColor Green
    } catch { Write-Host (T 'upd_fail' $_.Exception.Message) -ForegroundColor Red }
    finally { Remove-Item $tmp, $zip -Recurse -Force -ErrorAction SilentlyContinue }
}

# --- Selbst bauen (build) ---------------------------------------------------
# Holt den öffentlichen Port-Code (recipe.build), führt die Bauschritte aus und findet die APK.
# Bauschritte sind Shell-Befehle – unter Windows laufen sie in Git Bash (kommt mit Git).

function Find-Bash {
    foreach ($c in @("$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe", "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe")) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    $cmd = Get-Command bash -CommandType Application -ErrorAction SilentlyContinue | Where-Object { $_.Source -notmatch 'System32' } | Select-Object -First 1
    if ($cmd) { $cmd.Source } else { $null }
}

# Liefert den Pfad der gebauten APK oder $null
function Invoke-Build($r) {
    $b = $r.build
    if (-not $b -or -not $b.repo) { Write-Host (T 'b_none') -ForegroundColor Yellow; return $null }
    Write-Host ""
    Write-Host (T 'b_title' (RT $r 'title')) -ForegroundColor Cyan
    if ($b.note) { Write-Hint (RT $b 'note') }

    # 1. Bauwerkzeuge
    $script:Problems = 0
    foreach ($t in $r.tools) { Test-ToolRef $t }
    $bash = Find-Bash
    if (-not $bash) { Write-Bad (T 'b_nobash') }
    if ($script:Problems) { Write-Host (T 'g_tools_missing') -ForegroundColor Yellow; return $null }

    # 2. Port-Code holen bzw. aktualisieren
    $name = ($b.repo -split '/')[-1] -replace '\.git$', ''
    $dir = Join-Path (Split-Path $Root -Parent) $name
    if (Test-Path (Join-Path $dir ".git")) {
        Write-Host (T 'b_update' $dir)
        & git -C $dir pull --ff-only 2>&1 | Out-Host
        if ($b.submodules) { & git -C $dir submodule update --init --recursive 2>&1 | Out-Host }
    } else {
        if (-not (Read-YesNo (T 'b_clone' $b.repo $dir))) { Write-Host (T 'aborted'); return $null }
        $cloneArgs = @("clone")
        if ($b.branch) { $cloneArgs += @("-b", $b.branch) }
        if ($b.submodules) { $cloneArgs += "--recurse-submodules" }
        & git @cloneArgs $b.repo $dir 2>&1 | Out-Host
        if ($LASTEXITCODE -ne 0) { Write-Host (T 'b_fail' "git clone") -ForegroundColor Red; return $null }
    }

    # 3. Bauen
    # Schritte als Skriptdatei übergeben – PowerShell 5.1 verstümmelt Anführungszeichen in Argumenten
    $steps = @($b.steps) -join " && "
    Write-Host (T 'b_running') -ForegroundColor DarkGray
    Write-Host "  $steps" -ForegroundColor DarkGray
    $sh = Join-Path ([IO.Path]::GetTempPath()) "kitchen-build-$($r.id).sh"
    [IO.File]::WriteAllText($sh, "set -e`n$steps`n", (New-Object System.Text.UTF8Encoding $false))
    $env:CHERE_INVOKING = "1"
    Push-Location $dir
    try { & $bash -l $sh 2>&1 | Out-Host; $code = $LASTEXITCODE }
    finally { Pop-Location; Remove-Item $sh -ErrorAction SilentlyContinue }
    if ($code -ne 0) { Write-Host (T 'b_fail' "Exit $code") -ForegroundColor Red; Write-Hint (T 'b_fail_hint'); return $null }

    # 4. APK finden
    $apk = Get-ChildItem -Path (Join-Path $dir $b.apk) -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $apk) { Write-Host (T 'b_noapk' $b.apk) -ForegroundColor Red; return $null }
    Write-Ok (T 'b_done' $apk.FullName)
    $apk.FullName
}

# --- Assistent: führt Schritt für Schritt durch ein Rezept ----------------

function Write-Step([int] $n, [int] $total, [string] $title) {
    Write-Host ""
    Write-Host (T 'step' $n $total $title) -ForegroundColor Cyan
}

function Test-AssetsQuiet($recipe, [string] $dir) {
    # wie Test-Assets, zählt aber nur die Probleme dieses Schritts
    $before = $script:Problems
    Test-Assets $recipe $dir
    $ok = ($script:Problems -eq $before)
    $script:Problems = $before
    $ok
}

function Get-InstalledVersion([string] $appId, $sel) {
    $adb = Find-Adb
    $out = (Invoke-AdbRaw $adb ($sel + @("shell", "dumpsys package $appId | grep versionName"))).Out
    if ($out -match 'versionName=(\S+)') { return $Matches[1] }
    $null
}

function Invoke-Guide($r) {
    $script:Interactive = $true
    $oa = $r.ingredients.original_assets
    $needAssets = $oa -and ((@($oa.required | Where-Object { $_ }).Count + @($oa.any_of | Where-Object { $_ }).Count) -gt 0)
    $spec = $r.ingredients.push
    $prepare = if ($spec) { RT $spec 'prepare' } else { $null }
    $total = 6
    $appId = if ($App) { $App } elseif ($r.app) { $r.app.id } else { "" }

    # 0. Rezept vorstellen
    Write-Host ""
    Write-Host (RT $r 'title') -ForegroundColor Cyan
    Write-Host ("Portierbarkeit/portability {0}   XR {1}" -f (Stars $r.ratings.portability), (Stars $r.ratings.xr_potential))
    Write-Host (T 'g_status' $(if ($r.last_verified) { $r.last_verified } else { $r.status })) -ForegroundColor DarkGray
    if ($r.effort.with_apk) { Write-Host (T 'g_effort' (RT $r.effort 'with_apk')) }
    Write-Host (T 'g_based_on')
    foreach ($b in $r.base) { Write-Host "  $($b.name) [$($b.license)] $($b.url)" -ForegroundColor DarkGray }
    if (-not (Read-YesNo (T 'g_start'))) { Write-Host (T 'aborted'); return }

    # 1. Originalspiel und Ordner
    Write-Step 1 $total (T 'g_game')
    $folder = $null
    if (-not $needAssets) {
        Write-Host (T 'g_game_none')
        if ($oa -and $oa.hint) { Write-Hint (RT $oa 'hint') }
    } else {
        if (-not (Read-YesNo (T 'g_game_have' (RT $r.game 'name')))) {
            Write-Host (T 'g_game_buy' ($r.game.buy -join ', '))
            return
        }
        Write-Host (T 'g_folder')
        if ($oa.hint) { Write-Hint (RT $oa 'hint') }
        while ($true) {
            $folder = Read-Path (T 'g_folder_ask')
            if (-not $folder) { Write-Host (T 'aborted'); return }
            if (Test-AssetsQuiet $r $folder) { Write-Host (T 'g_folder_ok') -ForegroundColor Green; break }
            if (-not (Read-YesNo (T 'g_folder_retry'))) { Write-Host (T 'aborted'); return }
        }
    }

    # 2. Vorbereiten (nur wenn das Rezept es verlangt, z. B. Daten umwandeln)
    Write-Step 2 $total (T 'g_prepare')
    $pushSource = $folder
    if ($prepare) {
        Write-Host $prepare
        if (-not (Read-YesNo (T 'g_prepare_done'))) { Write-Host (T 'aborted'); return }
        $pushSource = Read-Path (T 'g_prepared_ask')
        if (-not $pushSource) { Write-Host (T 'aborted'); return }
    } else { Write-Host "–" -ForegroundColor DarkGray }
    if ($spec -and $spec.source -in "archive", "file" -and -not $prepare) {
        # z. B. OpenRA-Paket oder ROM-Datei: Quelle ist eine Datei, kein Ordner
        $pushSource = Read-Path (T 'g_prepared_ask')
    }

    # 3. Werkzeuge (nur Spielen)
    Write-Step 3 $total (T 'g_tools')
    for ($try = 0; $try -lt 2; $try++) {
        $script:Problems = 0
        foreach ($t in $r.tools) {
            if ($t -isnot [string] -and $t.only_for -eq "build") { continue }
            Test-ToolRef $t
        }
        if (-not $script:Problems) { break }
        # Fehlt nur adb, kann die Küchenhilfe es (nach Rückfrage) selbst holen
        if ($try -eq 0 -and -not (Find-Adb) -and (Install-PlatformTools)) { continue }
        Write-Host (T 'g_tools_missing') -ForegroundColor Yellow; return
    }

    # 4. Quest verbinden (mit Hilfe und Wiederholen)
    Write-Step 4 $total (T 'g_quest')
    while ($true) {
        $script:Problems = 0
        Test-Quest
        if (-not $script:Problems) { break }
        Write-Host (T 'g_quest_help')
        if (-not (Read-YesNo (T 'g_quest_retry'))) { Write-Host (T 'aborted'); return }
    }
    $sel = @(Get-DeviceArgs $r)

    # 5. App installieren oder aktualisieren
    Write-Step 5 $total (T 'g_app')
    $adb = Find-Adb
    $installed = if ($appId) { Get-InstalledVersion $appId $sel } else { $null }
    $wantApk = $true
    if ($installed) {
        Write-Host (T 'g_app_installed' $appId $installed) -ForegroundColor Green
        $wantApk = Read-YesNo (T 'g_app_update')
    } else { Write-Host (T 'g_app_missing' $appId) }
    if ($wantApk) {
        $apk = Read-Path (T 'g_app_ask')
        if (-not $apk -and -not $installed) {
            # App baut jeder selbst – mit Bauangaben im Rezept kann die Küchenhilfe das übernehmen
            if ($r.build -and (Read-YesNo (T 'b_offer'))) { $apk = Invoke-Build $r }
            else { Write-Host (T 'apk_none') -ForegroundColor DarkGray }
        }
        if ($apk) {
            if (-not (Test-Path -LiteralPath $apk -PathType Leaf)) { Fail (T 'e_srcmissing' $apk) }
            Write-Host (T 'g_app_installing')
            $res = Invoke-AdbRaw $adb ($sel + @("install", "-r", (Resolve-Path -LiteralPath $apk).Path))
            if ($res.Code -eq 0 -and $res.Out -match 'Success') { Write-Host (T 'g_app_ok') -ForegroundColor Green }
            else {
                Write-Host (T 'g_app_fail' $res.Out.Trim()) -ForegroundColor Red
                if ($res.Out -match 'INSTALL_FAILED_UPDATE_INCOMPATIBLE|signatures do not match') { Write-Host (T 'g_app_sig') -ForegroundColor Yellow }
                return
            }
        }
    }

    # 6. Daten übertragen
    Write-Step 6 $total (T 'g_push')
    if ($spec -and $pushSource) {
        if (Read-YesNo (T 'g_push_confirm')) {
            if (-not (Invoke-Push $r $pushSource)) { Write-Host (T 'aborted'); return }
        } else { Write-Host (T 'aborted'); return }
    } elseif (-not $spec) { Write-Host (T 'g_push_none') }

    Write-Host ""
    Write-Host (T 'g_done') -ForegroundColor Green
    if ($appId) { Write-Host (T 'g_done_start' $appId) }
    Write-Host (T 'g_details' "recipes\$($r.id)\RECIPE.md") -ForegroundColor DarkGray
}

function Select-Lang {
    Write-Host (T 'lang_prompt')
    $a = Read-Host ">"
    $script:L = if ($a -eq "2" -or $a -match '^(e|en)') { "en" } else { "de" }
    Save-Lang
}

# Auswahlmenü im DOS-Stil: Spiele alphabetisch, ankreuzen mit X (einzeln oder mehrere).
# Liefert eine Aktion: @{ Action = "go"|"quit"|"doctor"|"lang"|"update"; Recipes = @(...) }
function Select-Recipes($recipes, $checked) {
    $status = @{ "verified" = "✓✓"; "playable" = "✓"; "in-progress" = "…"; "draft" = "–" }
    $interactive = -not [Console]::IsInputRedirected
    $pos = 0
    while ($true) {
        if ($interactive) { Clear-Host }
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host ("  ║  {0,-56}║" -f (T 'menu_title')) -ForegroundColor Cyan
        Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host "  $(T 'menu_question')"
        Write-Host ""
        for ($i = 0; $i -lt $recipes.Count; $i++) {
            $box = if ($checked[$i]) { "[X]" } else { "[ ]" }
            $line = " {0,2}  {1}  {2}  {3}" -f ($i + 1), $box, (RT $recipes[$i] 'title'), $status[$recipes[$i].status]
            if ($interactive -and $i -eq $pos) { Write-Host "  >$line " -ForegroundColor Black -BackgroundColor Cyan }
            elseif ($checked[$i]) { Write-Host "   $line" -ForegroundColor Green }
            else { Write-Host "   $line" }
        }
        $n = @($checked | Where-Object { $_ }).Count
        Write-Host ""
        Write-Host "  $(T 'menu_selected' $n $recipes.Count)   ($(T 'menu_legend'))" -ForegroundColor DarkGray
        Write-Host "  $(T $(if ($interactive) { 'menu_hint' } else { 'menu_hint_plain' }))" -ForegroundColor DarkGray

        if ($interactive) {
            $k = [Console]::ReadKey($true)
            switch ($k.Key) {
                "UpArrow"   { $pos = ($pos - 1 + $recipes.Count) % $recipes.Count; continue }
                "DownArrow" { $pos = ($pos + 1) % $recipes.Count; continue }
                "Spacebar"  { $checked[$pos] = -not $checked[$pos]; continue }
                "X"         { $checked[$pos] = -not $checked[$pos]; continue }
                "A"         { $all = ($n -lt $recipes.Count); for ($i = 0; $i -lt $recipes.Count; $i++) { $checked[$i] = $all }; continue }
                "Enter"     { if ($n) { return @{ Action = "go" } }; Write-Host "  $(T 'menu_none')" -ForegroundColor Yellow; Start-Sleep -Milliseconds 1200; continue }
                "Escape"    { return @{ Action = "quit" } }
                "Q"         { return @{ Action = "quit" } }
                "D"         { return @{ Action = "doctor" } }
                "L"         { return @{ Action = "lang" } }
                "U"         { return @{ Action = "update" } }
                default {
                    $c = [string] $k.KeyChar
                    if ($c -match '^\d$' -and [int] $c -ge 1 -and [int] $c -le $recipes.Count) { $pos = [int] $c - 1; $checked[$pos] = -not $checked[$pos] }
                }
            }
        } else {
            $a = Read-Host (T 'menu_choice')
            switch -Regex ($a) {
                '^\s*$' { if ($n) { return @{ Action = "go" } }; Write-Host "  $(T 'menu_none')" -ForegroundColor Yellow }
                '^[qQ]' { return @{ Action = "quit" } }
                '^[dD]' { return @{ Action = "doctor" } }
                '^[lL]' { return @{ Action = "lang" } }
                '^[uU]' { return @{ Action = "update" } }
                '^[aA]' { $all = ($n -lt $recipes.Count); for ($i = 0; $i -lt $recipes.Count; $i++) { $checked[$i] = $all } }
                default {
                    foreach ($tok in ($a -split '[\s,;]+')) {
                        $v = 0
                        if ([int]::TryParse($tok, [ref] $v) -and $v -ge 1 -and $v -le $recipes.Count) { $checked[$v - 1] = -not $checked[$v - 1] }
                    }
                }
            }
        }
    }
}

function Invoke-Menu {
    if (-not $script:LangChosen) { Select-Lang }
    $checked = $null
    while ($true) {
        $recipes = @(Get-Recipes | Sort-Object { (RT $_ 'title') })
        if (-not $checked -or $checked.Count -ne $recipes.Count) { $checked = New-Object bool[] $recipes.Count }
        $res = Select-Recipes $recipes $checked
        switch ($res.Action) {
            "quit"   { return }
            "doctor" { Invoke-Doctor; if (-not [Console]::IsInputRedirected) { $null = Read-Host (T 'press_enter') } }
            "lang"   { $script:L = if ($script:L -eq "de") { "en" } else { "de" }; Save-Lang }
            "update" { Invoke-SelfUpdate; return }
            "go" {
                $sel = @(for ($i = 0; $i -lt $recipes.Count; $i++) { if ($checked[$i]) { $recipes[$i] } })
                for ($j = 0; $j -lt $sel.Count; $j++) {
                    if ($j -gt 0) { Write-Host ""; Write-Host (T 'menu_next_game' (RT $sel[$j] 'title')) -ForegroundColor Cyan }
                    Invoke-Guide $sel[$j]
                }
                return
            }
        }
    }
}

switch ($Command) {
    "list"   { Show-List }
    "show"   { Show-Recipe (Get-RecipeById $Recipe) }
    "check"  { Invoke-Check (Get-RecipeById $Recipe) $Assets $Play.IsPresent; if ($script:Problems) { exit 1 } }
    "doctor" { Invoke-Doctor }
    "push"   { $null = Invoke-Push (Get-RecipeById $Recipe) $Source }
    "guide"  { Invoke-Guide (Get-RecipeById $Recipe) }
    "build"  {
        $script:Interactive = $true
        $r = Get-RecipeById $Recipe
        $apk = Invoke-Build $r
        if ($apk -and (Find-Adb) -and (Read-YesNo (T 'b_install'))) {
            $sel = @(Get-DeviceArgs $r)
            $res = Invoke-AdbRaw (Find-Adb) ($sel + @("install", "-r", $apk))
            if ($res.Out -match 'Success') { Write-Ok (T 'g_app_ok') } else { Write-Host (T 'g_app_fail' $res.Out.Trim()) -ForegroundColor Red }
        }
        if (-not $apk) { exit 1 }
    }
    "lint"   { Invoke-Lint }
    "publish-check" { Invoke-PublishCheck $Recipe }
    "publish-prepare" { Invoke-PublishPrepare $Recipe $Name $Source }
    "publish" { Invoke-Publish $Recipe }
    "menu"   { Invoke-Menu }
    default  { Get-Help $PSCommandPath -Examples }
}
