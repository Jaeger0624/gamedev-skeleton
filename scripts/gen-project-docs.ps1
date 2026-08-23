# ============================================================
# gen-project-docs.ps1 - generate the reusable project docs
#   skeleton (feed-peanut style: responsibility matrix README +
#   info routing AI work-flow + per-domain overview placeholders).
#   Chinese names live in UTF-8 template lists (DIRS/FILES) so this
#   script itself stays ASCII-only (see gen-agent-notes.ps1 note).
# Usage:
#   pwsh scripts/gen-project-docs.ps1 -ProjectDir <abs> `
#     [-ProjectName <name>] [-TemplateDir <abs>]
# ============================================================
param(
  [Parameter(Mandatory = $true)][string]$ProjectDir,
  [string]$ProjectName = '',
  [string]$TemplateDir = ''
)
$ErrorActionPreference = 'Stop'
if ($ProjectName -eq '') { $ProjectName = [System.IO.Path]::GetFileName($ProjectDir) }
if ($TemplateDir -eq '') { $TemplateDir = Join-Path $PSScriptRoot 'templates' }

function Read-Utf8([string]$path) {
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

# ---- dirs ----
$dirsPath = Join-Path $TemplateDir 'project-docs-DIRS.txt'
if (-not (Test-Path $dirsPath)) { throw "template list not found: $dirsPath" }
foreach ($line in (Get-Content $dirsPath -Encoding UTF8)) {
  $rel = $line.Trim()
  if ($rel -eq '' -or $rel.StartsWith('#')) { continue }
  $target = Join-Path $ProjectDir $rel
  New-Item -ItemType Directory -Force -Path $target | Out-Null
}

# ---- files (target rel path <TAB> template filename) ----
$filesPath = Join-Path $TemplateDir 'project-docs-FILES.txt'
if (-not (Test-Path $filesPath)) { throw "template list not found: $filesPath" }
$generated = @()
foreach ($line in (Get-Content $filesPath -Encoding UTF8)) {
  if ($line.Trim() -eq '' -or $line.Trim().StartsWith('#')) { continue }
  $parts = $line -split "`t", 2
  if ($parts.Count -ne 2) { continue }
  $rel = $parts[0].Trim(); $tpl = $parts[1].Trim()
  $tplPath = Join-Path $TemplateDir $tpl
  if (-not (Test-Path $tplPath)) { throw "template not found: $tplPath" }
  $text = Read-Utf8 $tplPath
  $text = $text.Replace('{{PROJECT}}', $ProjectName)
  $target = Join-Path $ProjectDir $rel
  $targetDir = Split-Path $target -Parent
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
  [System.IO.File]::WriteAllText($target, $text, (New-Object System.Text.UTF8Encoding($false)))
  $generated += $target
}
Write-Output ("OK docs skeleton: {0} files, {1} dirs" -f $generated.Count, ((Get-Content $dirsPath -Encoding UTF8 | Where-Object { $_.Trim() -ne '' -and -not $_.Trim().StartsWith('#') }).Count))
$generated | ForEach-Object { Write-Output ("  " + $_.Replace($ProjectDir + '\', '')) }
