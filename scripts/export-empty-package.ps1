# ============================================================
# export-empty-package.ps1 - H-02 empty framework package export.
#   Copies the PATTERN layer out of the global skeleton into a
#   distributable empty package: format contracts, the 10 fixed
#   cognitive primitives, empty content directories and a README
#   explaining what to clear. Personal content (verdicts / skills /
#   skeleton entries / packs / narrative chain / decisions / sources)
#   is NOT copied - only the empty directory skeleton.
#   Chinese readme lives in UTF-8 template; script stays ASCII-only.
# Usage:
#   pwsh scripts/export-empty-package.ps1 [-OutDir <rel>]
# ============================================================
param(
  [string]$OutDir = 'dist/empty-package'
)
$ErrorActionPreference = 'Stop'
if (-not $env:USERPROFILE) { throw 'USERPROFILE not set' }
$HarnessRoot = Join-Path $env:USERPROFILE '.gamedev-harness'
if (-not (Test-Path $HarnessRoot)) { throw "harness root not found: $HarnessRoot" }
$RepoRoot = Split-Path $PSScriptRoot -Parent
$Out = Join-Path $RepoRoot $OutDir
$TplDir = Join-Path $PSScriptRoot 'templates'

function Read-Utf8([string]$path) {
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}
function Write-Utf8([string]$path, [string]$text) {
  $dir = Split-Path $path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))
}

if (Test-Path $Out) { Remove-Item -Recurse -Force $Out }
New-Item -ItemType Directory -Force -Path $Out | Out-Null

# ---- 1. pattern-layer files copied verbatim from the harness root ----
$copy = @(
  'HARNESS.md',
  'FRAMEWORK-MIND.md',
  'atoms/GOVERNANCE.md',
  'packs/_TEMPLATE.md',
  'pipelines/_FORMAT.md'
)
foreach ($rel in $copy) {
  $src = Join-Path $HarnessRoot ($rel -replace '/', [System.IO.Path]::DirectorySeparatorChar)
  if (-not (Test-Path $src)) { Write-Host "WARN missing pattern file: $rel"; continue }
  $dst = Join-Path $Out ($rel -replace '/', [System.IO.Path]::DirectorySeparatorChar)
  $dstDir = Split-Path $dst -Parent
  if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
  Copy-Item $src $dst -Force
  Write-Host "copy  $rel"
}

# ---- 1b. GOVERNANCE: trim the first-batch atom table (personal content) ----
$gov = Read-Utf8 (Join-Path $Out 'atoms\GOVERNANCE.md')
$govMarker = (Read-Utf8 (Join-Path $TplDir 'empty-package-trim-marker-2.txt')).Trim()
$govAt = $gov.IndexOf($govMarker)
if ($govAt -ge 0) { $gov = $gov.Substring(0, $govAt).TrimEnd() + "`n" }
Write-Utf8 (Join-Path $Out 'atoms\GOVERNANCE.md') $gov
Write-Host 'trim  atoms/GOVERNANCE.md (first-batch atom table)'

# ---- 1c. FRAMEWORK-MIND: de-personalize illustrative examples ----
# Replacement pairs live in an UTF-8 file (script stays ASCII-only):
# each line is "<old>||<new>".
$mind = Read-Utf8 (Join-Path $Out 'FRAMEWORK-MIND.md')
$sanitize = Read-Utf8 (Join-Path $TplDir 'empty-package-sanitize.txt')
foreach ($line in ($sanitize -split "`r?`n")) {
  $parts = $line.Split('||', 2)
  if ($parts.Count -eq 2 -and $parts[0].Trim() -ne '') {
    $mind = $mind.Replace($parts[0], $parts[1])
  }
}
Write-Utf8 (Join-Path $Out 'FRAMEWORK-MIND.md') $mind
Write-Host 'sanitize FRAMEWORK-MIND.md example'

# ---- 1d. GOVERNANCE examples (same sanitize pairs) ----
$gov = Read-Utf8 (Join-Path $Out 'atoms\GOVERNANCE.md')
foreach ($line in ($sanitize -split "`r?`n")) {
  $parts = $line.Split('||', 2)
  if ($parts.Count -eq 2 -and $parts[0].Trim() -ne '') {
    $gov = $gov.Replace($parts[0], $parts[1])
  }
}
Write-Utf8 (Join-Path $Out 'atoms\GOVERNANCE.md') $gov
Write-Host 'sanitize atoms/GOVERNANCE.md examples'

# ---- 2. the 10 fixed cognitive primitives (usage records trimmed) ----
$primitives = @(
  'pattern-recognition','abstraction','layering','causal-reasoning','constraint-solving',
  'backward-reasoning','hypothesis-testing','sequencing','analogy','mental-simulation'
)
foreach ($name in $primitives) {
  $src = Join-Path $HarnessRoot ('atoms' + [System.IO.Path]::DirectorySeparatorChar + $name + '.md')
  if (-not (Test-Path $src)) { Write-Host "WARN missing primitive: $name"; continue }
  $text = Read-Utf8 $src
  # Trim marker text is read from an UTF-8 file (this script stays ASCII-only;
  # Windows PowerShell 5.1 would mis-decode inline non-ASCII here).
  $marker = (Read-Utf8 (Join-Path $TplDir 'empty-package-trim-marker.txt')).Trim()
  $trimAt = $text.IndexOf($marker)
  if ($trimAt -ge 0) { $text = $text.Substring(0, $trimAt).TrimEnd() + "`n" }
  $dst = Join-Path $Out ('atoms' + [System.IO.Path]::DirectorySeparatorChar + $name + '.md')
  Write-Utf8 $dst $text
  Write-Host "trim  atoms/$name.md"
}

# ---- 3. empty content directories (per FRAMEWORK-LAYERING 4.2) ----
$emptyDirs = @(
  'atoms/skills',
  'verdicts',
  'skeleton/game-mechanics',
  'skeleton/fictional-player',
  'skeleton/design-philosophy',
  'packs',
  'pipelines',
  'memory/narrative-chain/archive',
  'decisions',
  'projects',
  'reviews'
)
foreach ($rel in $emptyDirs) {
  $path = Join-Path $Out ($rel -replace '/', [System.IO.Path]::DirectorySeparatorChar)
  New-Item -ItemType Directory -Force -Path $path | Out-Null
  Write-Host "empty $rel/"
}

# ---- 4. empty index skeletons rendered from UTF-8 templates ----
$indexTpl = Join-Path $TplDir 'empty-package-atoms-INDEX.md'
Write-Utf8 (Join-Path $Out 'atoms\_INDEX.md') (Read-Utf8 $indexTpl)
Write-Host 'gen   atoms/_INDEX.md (empty skills table)'
$vFormat = Join-Path $TplDir 'empty-package-verdicts-FORMAT.md'
Write-Utf8 (Join-Path $Out 'verdicts\_FORMAT.md') (Read-Utf8 $vFormat)
Write-Host 'gen   verdicts/_FORMAT.md (empty index table)'
$skelTpl = Join-Path $TplDir 'empty-package-skeleton-INDEX.md'
Write-Utf8 (Join-Path $Out 'skeleton\_INDEX.md') (Read-Utf8 $skelTpl)
Write-Host 'gen   skeleton/_INDEX.md (empty three-block table)'
$decTpl = Join-Path $TplDir 'empty-package-decisions-INDEX.md'
Write-Utf8 (Join-Path $Out 'decisions\_INDEX.md') (Read-Utf8 $decTpl)
Write-Host 'gen   decisions/_INDEX.md (empty)'
$srcTpl = Join-Path $TplDir 'empty-package-sources-INDEX.md'
Write-Utf8 (Join-Path $Out 'sources\_INDEX.md') (Read-Utf8 $srcTpl)
Write-Host 'gen   sources/_INDEX.md (empty)'
$memoryTpl = Join-Path $TplDir 'empty-package-narrative-MAIN.md'
Write-Utf8 (Join-Path $Out 'memory\narrative-chain\_MAIN.md') (Read-Utf8 $memoryTpl)
Write-Host 'gen   memory/narrative-chain/_MAIN.md (format header only)'

# ---- 5. package README ----
$readmeTpl = Join-Path $TplDir 'empty-package-README.md'
Write-Utf8 (Join-Path $Out 'README.md') (Read-Utf8 $readmeTpl)
Write-Host 'gen   README.md'
Write-Host "`nDone -> $Out"
