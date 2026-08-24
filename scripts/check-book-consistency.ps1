# ============================================================
# check-book-consistency.ps1 - reading round settlement check
#   Verifies book.json yiel fields against a round settlement
#   manifest (settled.json). The manifest is the single source
#   of truth for "what this round produced"; book.json must
#   match it exactly, otherwise the round is NOT settled.
# Usage:
#   pwsh scripts/check-book-consistency.ps1 `
#     -BookDir <books/<slug> abs>` -SettledFile <abs settled.json>
# settled.json shape:
# {
#   "round": 13, "date": "2026-08-24", "range": "199-217",
#   "checks": { "199": "done", ... },             // status overrides
#   "yield": { "199": { atoms:[], verdicts:[], skeleton:[], insights:[], rejects:[] } },
#   "summary": { "rounds":15, "accepted":.., "deferred":.. },
#   "cursor": ["218"]
# }
# ============================================================
param(
  [string]$BookDir,
  [string]$SettledFile,
  [string]$Harness = '',
  [switch]$CheckPackAdoption
)
$ErrorActionPreference = 'Stop'
if ($Harness -eq '') { $Harness = Join-Path $env:USERPROFILE '.gamedev-harness' }

# -CheckPackAdoption 模式独立运行收录检查（不需 book/settled）。
if (-not $CheckPackAdoption) {
if ($BookDir -eq '' -or $SettledFile -eq '') { throw "BookDir and SettledFile required unless -CheckPackAdoption is set" }
$jsonPath = Join-Path $BookDir 'book.json'
if (-not (Test-Path $jsonPath)) { throw "book.json not found: $jsonPath" }
if (-not (Test-Path $SettledFile)) { throw "settled file not found: $SettledFile" }

# G-20 (2026-08-24): settled yield entity slug -> harness file system lookup.
# Supports plain slug ('decision-scope') and prefixed slug ('game-mechanics/balance').
function Get-HarnessFile([string]$root, [string]$slug) {
  $cand = Join-Path $root ($slug -replace '/', '\')
  if (Test-Path $cand) { return $cand }
  $base = [System.IO.Path]::GetFileNameWithoutExtension($slug)
  if ($base -eq '') { return '' }
  $hits = Get-ChildItem -Path $root -Filter "$base.md" -Recurse -ErrorAction SilentlyContinue
  foreach ($h in $hits) { if ($h.BaseName -eq $base) { return $h.FullName } }
  return ''
}

function Normalize-List($val) {
  if ($null -eq $val) { return @() }
  return ,@($val | ForEach-Object { [string]$_ } | Sort-Object)
}

$book = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$settledRaw = [System.IO.File]::ReadAllText($SettledFile) | ConvertFrom-Json

$fail = 0
$notes = @()

# by id map in book.json
$byId = @{}
foreach ($s in $book.sections) { $byId[$s.id] = $s }

# 1. status / readAt checks
foreach ($entry in $settledRaw.checks.PSObject.Properties) {
  $id = $entry.Name; $wantStatus = $entry.Value
  if (-not $byId.ContainsKey($id)) { Write-Output ("FAIL section-missing: {0}" -f $id); $fail++; continue }
  $s = $byId[$id]
  if ($s.status -ne $wantStatus) {
    Write-Output ("FAIL status {0}: book={1} settled={2}" -f $id, $s.status, $wantStatus); $fail++
  }
}

# 2. yield field checks (set equality; order-insensitive)
$yields = $settledRaw.yield
if ($null -ne $yields) {
  foreach ($entry in $yields.PSObject.Properties) {
    $id = $entry.Name
    if (-not $byId.ContainsKey($id)) { Write-Output ("FAIL yield-section-missing: {0}" -f $id); $fail++; continue }
    $s = $byId[$id]
    foreach ($f in @('atoms', 'verdicts', 'skeleton', 'insights', 'rejects')) {
      $wantProp = $entry.Value.PSObject.Properties[$f]
      $want = @()
      if ($null -ne $wantProp -and $null -ne $wantProp.Value) { $want = Normalize-List $wantProp.Value }
      $gotProp = $s.yield.PSObject.Properties[$f]
      $got = @()
      if ($null -ne $gotProp -and $null -ne $gotProp.Value) { $got = Normalize-List $gotProp.Value }
      $w = ($want -join '|'); $g = ($got -join '|')
      if ($w -ne $g) {
        Write-Output ("FAIL yield {0}.{1}: got [{2}] want [{3}]" -f $id, $f, $g, $w); $fail++
      }
    }
  }
}

# 3. summary / cursor checks
if ($null -ne $settledRaw.summary) {
  foreach ($k in @('rounds', 'accepted', 'deferred')) {
    $sp = $settledRaw.summary.PSObject.Properties[$k]
    if ($null -ne $sp -and $null -ne $sp.Value -and [double]$book.summary.PSObject.Properties[$k].Value -ne [double]$sp.Value) {
      Write-Output ("FAIL summary.{0}: book={1} settled={2}" -f $k, $book.summary.PSObject.Properties[$k].Value, $sp.Value); $fail++
    }
  }
}
if ($null -ne $settledRaw.cursor -and @($settledRaw.cursor).Count -gt 0) {
  $wc = ($book.cursor -join ','); $sc = (@($settledRaw.cursor) -join ',')
  if ($wc -ne $sc) { Write-Output ("FAIL cursor: book={0} settled={1}" -f $wc, $sc); $fail++ }
}

# 4. sink check (G-20, 2026-08-24): every atoms/verdicts/skeleton slug in settled
#    yield must exist as a real file in the harness (defense against "wrote the
#    field but never created the library file" drift - round 13 case).
$sinkFail = 0
$sinkChecked = 0
if (Test-Path $Harness) {
  $layerRoots = @{
    atoms    = (Join-Path $Harness 'atoms\skills')
    verdicts = (Join-Path $Harness 'verdicts')
    skeleton = (Join-Path $Harness 'skeleton')
  }
  foreach ($entry in $yields.PSObject.Properties) {
    foreach ($f in @('atoms', 'verdicts', 'skeleton')) {
      $prop = $entry.Value.PSObject.Properties[$f]
      if ($null -eq $prop -or $null -eq $prop.Value) { continue }
      foreach ($slug in @($prop.Value)) {
        $s = [string]$slug
        if ($s -eq '') { continue }
        $root = $layerRoots[$f]
        if (-not (Test-Path $root)) {
          Write-Output ("FAIL sink-root-missing: {0}" -f $root); $sinkFail++; continue
        }
        $sinkChecked++
        $path = Get-HarnessFile $root $s
        if ($path -eq '') {
          Write-Output ("FAIL sink {0}.{1}: slug [{2}] missing in harness ({3})" -f $entry.Name, $f, $s, $root)
          $sinkFail++
        }
      }
    }
  }
  if ($sinkFail -gt 0) { $fail += $sinkFail } else { Write-Output ("SINK OK - {0} settled entities found in harness" -f $sinkChecked) }
} else {
  Write-Output ("WARN harness dir not found: {0} (sink check skipped)" -f $Harness)
}

if ($fail -gt 0) {
  Write-Output ("CONSISTENCY FAILED: {0} mismatch(es) - round NOT settled; fix book.json via advance-book.ps1 then re-run" -f $fail)
  exit 1
}
Write-Output ("CONSISTENCY OK - book.json matches settled manifest (round {0}, range {1})" -f $settledRaw.round, $settledRaw.range)
}

# 5. pack adoption reverse check (B级, 2026-08-25): library entities not adopted
#    by ANY genre pack list -> "待归属" report (INFO only; adoption is a human
#    judgment - global verdicts may legitimately stay unadopted).
if ($CheckPackAdoption) {
  if (-not (Test-Path $Harness)) { Write-Output ("WARN harness dir not found: {0} (adoption check skipped)" -f $Harness); exit 0 }
  function Get-PackFenceSlugs([string]$text, [string]$lang) {
    $slugs = @{}
    $fence = '```'
    $m = [regex]::Match($text, '(?ms)^' + $fence + $lang + '\s*$' + '(.*?)' + $fence)
    if (-not $m.Success) { return $slugs }
    foreach ($line in ($m.Groups[1].Value -split '\r?\n')) {
      $t = $line.Trim()
      if ($t -eq '' -or $t.StartsWith('#')) { continue }
      if ($lang -eq 'verdicts') {
        if ($t -match '^([a-z0-9][a-z0-9-]*)@(formal|candidate)$') { $slugs[$Matches[1]] = $true }
      } else {
        foreach ($part in ($t -split '\|')) {
          if ($part -match '^(?:core|divergent):(.+)$') {
            foreach ($s in ($Matches[1] -split ',')) { $s = $s.Trim(); if ($s -ne '') { $slugs[$s] = $true } }
          }
        }
      }
    }
    return $slugs
  }
  $adopted = @{}
  $packRoot = Join-Path $Harness 'packs'
  if (Test-Path $packRoot) {
    foreach ($dir in (Get-ChildItem $packRoot -Directory)) {
      if ($dir.Name -eq '_TEMPLATE') { continue }
      $packFile = Join-Path $dir.FullName 'PACK.md'
      if (-not (Test-Path $packFile)) { continue }
      $text = [System.IO.File]::ReadAllText($packFile)
      foreach ($lang in @('verdicts', 'atoms')) {
        foreach ($k in (Get-PackFenceSlugs $text $lang).Keys) { $adopted[$k] = $true }
      }
    }
  }
  # library sets
  $libV = @{}
  foreach ($f in (Get-ChildItem (Join-Path $Harness 'verdicts') -Filter '*.md' -ErrorAction SilentlyContinue)) { if ($f.BaseName -ne '_FORMAT') { $libV[$f.BaseName] = $true } }
  $libA = @{}
  $skillDir = Join-Path $Harness 'atoms\skills'
  if (Test-Path $skillDir) { foreach ($f in (Get-ChildItem $skillDir -Filter '*.md')) { $libA[$f.BaseName] = $true } }
  $unV = @($libV.Keys | Where-Object { -not $adopted.ContainsKey($_) } | Sort-Object)
  $unA = @($libA.Keys | Where-Object { -not $adopted.ContainsKey($_) } | Sort-Object)
  foreach ($s in $unV) { Write-Output ("PACK-ADOPTION-VERDICT 未收录: {0}" -f $s) }
  foreach ($s in $unA) { Write-Output ("PACK-ADOPTION-ATOM 未收录: {0}" -f $s) }
  Write-Output ("PACK-ADOPTION: {0} 判据 / {1} 原子 未收录于任何品类清单（待归属或全局适用未声明——人工判定，非错误）" -f $unV.Count, $unA.Count)
  exit 0
}
exit 0
