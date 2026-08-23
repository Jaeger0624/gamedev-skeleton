# ============================================================
# gen-agent-notes.ps1 - generate project agent-notes distillation
#   (KNOWLEDGE.md + dev-log/DECISION-LOG.md) from the harness lib.
#   Reads: templates/ + $HARNESS packs/verdicts/skeleton.
#   Chinese content comes ONLY from md files read as UTF-8; this
#   script itself stays ASCII-only (PowerShell parses no-BOM .ps1
#   as ANSI - see gen-library-list.ps1 note).
# Usage:
#   pwsh scripts/gen-agent-notes.ps1 -ProjectDir <abs> `
#     [-Harness <abs>] [-Genre story] [-ProjectName <name>]
# ============================================================
param(
  [Parameter(Mandatory = $true)][string]$ProjectDir,
  [string]$Harness = '',
  [string]$Genre = 'story',
  [string]$ProjectName = ''
)
$ErrorActionPreference = 'Stop'
if ($Harness -eq '') { $Harness = Join-Path $env:USERPROFILE '.gamedev-harness' }
if ($ProjectName -eq '') { $ProjectName = [System.IO.Path]::GetFileName($ProjectDir) }
$templateDir = Join-Path $PSScriptRoot 'templates'
if (-not (Test-Path $templateDir)) { throw "templates dir not found: $templateDir" }
$packPath = Join-Path $Harness ("packs\{0}\PACK.md" -f $Genre)
if (-not (Test-Path $packPath)) { throw "pack not found: $packPath" }

# ---- category-scoped slug pools (per design knowledge; extend per genre) ----
$skeletonSlugs = @(
  'narrative-tool-spectrum','control-spectrum','world-narrative','story-recording',
  'story-convergence','apophenia','desk-jumping','insight-chain','emotion-tempo',
  'emotion-two-factor','emotion-composition','emotion-black-box','emotion-trigger-strata',
  'fiction-layer','mechanic-fiction-tension','decision-emotion-future','metagame-information',
  'expectation-setting','motivation-satisfaction','self-set-goal-emergence',
  'plans-as-hypotheses','process-anti-bias','quality-paradox','runnable-prototype',
  'designer-values','decision-effect-spectrum','skill-space','dependency-stack'
)
$verdictSlugs = @(
  'fiction-mechanics-synthesis','narrative-restraint','humor-absorbs-flaws',
  'setting-absorbs-limits','interruptible-pacing','mechanic-serves-experience',
  'human-value-change','player-reports-unreliable','emotional-composite-check',
  'purpose-shapes-design','predictable-ai-default','information-balance-recipe',
  'flow-channel','reality-over-authority','arrogance-three-signals',
  'worst-case-evaluation','confidence-calibration'
)

function Read-Utf8([string]$path) {
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

# ---- assemble verdict excerpt ----
$verdictLines = @()
foreach ($slug in $verdictSlugs) {
  $vf = Join-Path $Harness ("verdicts\{0}.md" -f $slug)
  if (-not (Test-Path $vf)) { continue }
  $txt = Read-Utf8 $vf
  $title = ([regex]::Match($txt, '(?m)^#\s+(.+)$')).Groups[1].Value.Trim()
  $m = [regex]::Match($txt, '\*\*内容\*\*[：:]\s*(.+)')
  $excerpt = ''
  if ($m.Success) {
    $excerpt = $m.Groups[1].Value.Trim()
    if ($excerpt.Length -gt 140) { $excerpt = $excerpt.Substring(0, 140) + '...' }
  }
  if ($title -eq '') { $title = $slug }
  $verdictLines += "- **$($slug)** $title" + $(if ($excerpt -ne '') { " - $excerpt" } else { '' })
}
$verdictBlock = ($verdictLines -join "`n")

# ---- assemble skeleton excerpt (from _INDEX lines) ----
$indexPath = Join-Path $Harness 'skeleton\_INDEX.md'
$indexText = if (Test-Path $indexPath) { Read-Utf8 $indexPath } else { '' }
$skeletonLines = @()
foreach ($slug in $skeletonSlugs) {
  $pat = '\[\s*' + [regex]::Escape($slug) + '\s*\]\([^)]*\)\s*\|\s*([^\n]+)'
  $m = [regex]::Match($indexText, $pat)
  if ($m.Success) {
    $line = $m.Groups[1].Value.Trim()
    $line = $line -replace '\|+$', ''
    $skeletonLines += "- **$slug**$line"
  }
}
$skeletonBlock = ($skeletonLines -join "`n")

# ---- fill templates ----
$packText = Read-Utf8 $packPath
$knowTpl = Read-Utf8 (Join-Path $templateDir 'agent-notes-KNOWLEDGE.md')
$devTpl = Read-Utf8 (Join-Path $templateDir 'dev-log-DECISION.md')
$date = (Get-Date -Format 'yyyy-MM-dd')
$know = $knowTpl.Replace('{{PROJECT}}', $ProjectName).Replace('{{DATE}}', $date).Replace('{{GENRE}}', $Genre).Replace('{{PACK}}', $packText).Replace('{{VERDICTS}}', $verdictBlock).Replace('{{SKELETON}}', $skeletonBlock)
$dev = $devTpl.Replace('{{PROJECT}}', $ProjectName)

# ---- write ----
$notesDir = Join-Path $ProjectDir 'agent-notes'
$devDir = Join-Path $ProjectDir 'dev-log'
New-Item -ItemType Directory -Force -Path $notesDir, $devDir | Out-Null
$knowPath = Join-Path $notesDir 'KNOWLEDGE.md'
$devPath = Join-Path $devDir 'DECISION-LOG.md'
[System.IO.File]::WriteAllText($knowPath, $know, (New-Object System.Text.UTF8Encoding($false)))
[System.IO.File]::WriteAllText($devPath, $dev, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ("OK generated: {0} ({1} verdicts, {2} skeletons) + {3}" -f $knowPath, $verdictLines.Count, $skeletonLines.Count, $devPath)
