# ============================================================
# advance-book.ps1 - atomic book.json state transitions
#   - mark sections done/skip by id range list
#   - set readAt, cursor, summary counters
#   - verify JSON parses after write; print summary
# Usage:
#   pwsh scripts/advance-book.ps1 -BookDir <books/<slug> abs> `
#     -Ids "008-024" [-Status done] [-ReadAt 2026-08-23] `
#     [-Cursor 025] [-Rounds 2] [-Accepted 8] [-Deferred 1]
#   Ids format: "008-024" | "008,011,015" | "all"
# NOTE: literals are ASCII-only (see ingest-epub.ps1).
# ============================================================
param(
  [Parameter(Mandatory = $true)][string]$BookDir,
  [Parameter(Mandatory = $true)][string]$Ids,
  [string]$Status = 'done',
  [string]$ReadAt = '',
  [string]$Cursor = '',
  [int]$Rounds = -1,
  [int]$Accepted = -1,
  [int]$Deferred = -1,
  [string]$YieldFile = ''
)
$ErrorActionPreference = 'Stop'
$jsonPath = Join-Path $BookDir 'book.json'
if (-not (Test-Path $jsonPath)) { throw "book.json not found: $jsonPath" }

$book = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($null -eq $book -or $null -eq $book.sections) { throw 'book.json parse failed' }

# resolve id set
$idSet = @{}
if ($Ids -eq 'all') {
  $book.sections | ForEach-Object { $idSet[$_.id] = $true }
} else {
  foreach ($part in ($Ids -split ',')) {
    $part = $part.Trim()
    if ($part -match '^(\d+)-(\d+)$') {
      $lo = [int]$Matches[1]; $hi = [int]$Matches[2]
      for ($n = $lo; $n -le $hi; $n++) { $idSet[('{0:D3}' -f $n)] = $true }
    } elseif ($part -match '^\d+$') {
      $idSet[('{0:D3}' -f [int]$part)] = $true
    } else {
      throw "bad Ids token: $part"
    }
  }
}

$hits = 0
foreach ($s in $book.sections) {
  if ($idSet.ContainsKey($s.id)) {
    $s.status = $Status
    if ($ReadAt -ne '') { $s.readAt = $ReadAt }
    $hits++
  }
}
if ($hits -eq 0) { throw "no sections matched ids: $Ids" }

# optional per-section yield backfill from a UTF-8 JSON data file:
# { "049": { "atoms": [...], "verdicts": [...], "skeleton": [...], "insights": [...], "rejects": [...] }, ... }
# empty arrays are skipped (existing empty arrays are preserved)
if ($YieldFile -ne '') {
  if (-not (Test-Path $YieldFile)) { throw "yield file not found: $YieldFile" }
  $yield = [System.IO.File]::ReadAllText($YieldFile) | ConvertFrom-Json
  foreach ($s in $book.sections) {
    if ($idSet.ContainsKey($s.id)) {
      $y = $yield.PSObject.Properties[$s.id]
      if ($null -ne $y) {
        foreach ($f in @('atoms', 'verdicts', 'skeleton', 'insights', 'rejects')) {
          $val = $y.Value.PSObject.Properties[$f]
          if ($null -ne $val -and $null -ne $val.Value -and @($val.Value).Count -gt 0) {
            $s.yield.$f = @($val.Value)
          }
        }
      }
    }
  }
}

if ($Cursor -ne '') { $book.cursor = @($Cursor) }
if ($Rounds -ge 0) { $book.summary.rounds = $Rounds }
if ($Accepted -ge 0) { $book.summary.accepted = $Accepted }
if ($Deferred -ge 0) { $book.summary.deferred = $Deferred }

$json = $book | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($jsonPath, $json, (New-Object System.Text.UTF8Encoding($false)))

# verify
$check = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$done = ($check.sections | Where-Object { $_.status -eq 'done' }).Count
$unread = ($check.sections | Where-Object { $_.status -eq 'unread' }).Count
Write-Output ("OK advanced={0} done={1} unread={2} cursor={3} rounds={4}/{5}/{6}" -f `
  $hits, $done, $unread, ($check.cursor -join ','), $check.summary.rounds, $check.summary.accepted, $check.summary.deferred)
