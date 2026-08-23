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
  [Parameter(Mandatory = $true)][string]$BookDir,
  [Parameter(Mandatory = $true)][string]$SettledFile
)
$ErrorActionPreference = 'Stop'
$jsonPath = Join-Path $BookDir 'book.json'
if (-not (Test-Path $jsonPath)) { throw "book.json not found: $jsonPath" }
if (-not (Test-Path $SettledFile)) { throw "settled file not found: $SettledFile" }

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

if ($fail -gt 0) {
  Write-Output ("CONSISTENCY FAILED: {0} mismatch(es) - round NOT settled; fix book.json via advance-book.ps1 then re-run" -f $fail)
  exit 1
}
Write-Output ("CONSISTENCY OK - book.json matches settled manifest (round {0}, range {1})" -f $settledRaw.round, $settledRaw.range)
exit 0
