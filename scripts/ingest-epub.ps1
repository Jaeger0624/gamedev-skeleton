# ============================================================
# ingest-epub.ps1  -  epub to book library (books/<slug>/)
#   - extract text per h1..h5 headings + content paragraphs
#   - reorder sections by toc.xhtml sequence (fallback: file order)
#   - write text/001-<title>.md + book.json (UTF-8 no BOM)
#   - verify JSON parses, print stats
# Usage:
#   pwsh scripts/ingest-epub.ps1 -EpubPath <file.epub> -Slug <slug> -Title <中文标题> -Author <中文作者> -Source <说明> -OutDir <books/<slug> abs path>
# NOTE: literals in this script are ASCII-only (PowerShell decodes .ps1 as ANSI without BOM).
# ============================================================
param(
  [Parameter(Mandatory = $true)][string]$EpubPath,
  [Parameter(Mandatory = $true)][string]$Slug,
  [string]$Title = $Slug,
  [string]$Author = '',
  [string]$Source = 'epub',
  [Parameter(Mandatory = $true)][string]$OutDir,
  [switch]$KeepTemp
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (-not (Test-Path $EpubPath)) { throw "epub not found: $EpubPath" }
$tmp = Join-Path $OutDir "_extract_tmp"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($EpubPath, $tmp)

$contents = Get-ChildItem $tmp -Recurse -Filter '*.xhtml' -ErrorAction SilentlyContinue
if ($contents.Count -eq 0) { $contents = Get-ChildItem $tmp -Recurse -Filter '*.html' -ErrorAction SilentlyContinue }
$textDir = Join-Path $OutDir 'text'
New-Item -ItemType Directory -Path $textDir -Force | Out-Null
Get-ChildItem $textDir -Filter '*.md' -ErrorAction SilentlyContinue | Remove-Item -Force

function Get-SafeName([string]$s) {
  $s = $s -replace '[\\/:*?"<>|]', ' ' -replace '\s+', ' '
  return $s.Trim()
}

# --- pass 1: parse headings + paragraphs from every content file ----------
$units = @()   # { title, file, paras }
$files = $contents | Sort-Object Name
foreach ($f in $files) {
  $raw = Get-Content $f.FullName -Raw -Encoding UTF8
  $ms = [regex]::Matches($raw, '<(h[1-5])\b[^>]*>(?:<a[^>]*>)?(.*?)(?:</a>)?</\1>|<p class="[^"]*"[^>]*>(.*?)</p>')
  if ($ms.Count -eq 0) { continue }
  $cur = $null
  foreach ($m in $ms) {
    if ($m.Groups[1].Value) {
      $t = ([regex]::Replace($m.Groups[2].Value, '<[^>]+>', '')).Trim()
      if ($t -eq '') { continue }
      $unit = [pscustomobject]@{ title = $t; file = $f.Name; paras = @() }
      $units += $unit
      $cur = $unit
    } elseif ($m.Groups[3].Value) {
      $p = $m.Groups[3].Value
      $p = [regex]::Replace($p, '<img[^>]*>', '[IMG]')
      $p = ([regex]::Replace($p, '<[^>]+>', '')).Trim()
      if ($p -eq '') { continue }
      if ($cur) { $cur.paras += $p }
    }
  }
}

# --- pass 2: reorder by toc.xhtml if present ------------------------------
$ordered = @()
$tocFile = Get-ChildItem $tmp -Recurse -Filter 'toc.xhtml' | Select-Object -First 1
if ($tocFile) {
  $toc = Get-Content $tocFile.FullName -Raw -Encoding UTF8
  $entries = [regex]::Matches($toc, '<a[^>]*>([^<]{1,80})</a>') | ForEach-Object { $_.Groups[1].Value.Trim() }
  $used = @{}
  foreach ($e in $entries) {
    if ($e -eq '') { continue }
    $cand = $units | Where-Object { $_.title -eq $e -and -not $used[$_.file + '|' + $_.title] } | Select-Object -First 1
    if ($cand) { $used[$cand.file + '|' + $cand.title] = $true; $ordered += $cand }
  }
  $left = $units | Where-Object { -not $used[$_.file + '|' + $_.title] }
  if ($left.Count -gt 0) { Write-Output ("warn: unmatched units: " + $left.Count + " (skipped)") }
} else {
  $ordered = $units
}
if ($ordered.Count -eq 0) { throw 'no units extracted' }

# --- pass 3: write text files + book.json ---------------------------------
$sections = @()
$i = 0
foreach ($u in $ordered) {
  $i += 1
  $secId = '{0:D3}' -f $i
  $fname = '{0}-{1}.md' -f $secId, (Get-SafeName $u.title)
  $content = '# ' + $u.title + "`n`n" + (($u.paras | ForEach-Object { $_ }) -join "`n`n")
  [System.IO.File]::WriteAllText((Join-Path $textDir $fname), $content, (New-Object System.Text.UTF8Encoding($false)))
  $sections += [pscustomobject]@{ id = $secId; title = $u.title; status = 'unread' }
}
$book = [ordered]@{
  slug = $Slug
  title = $Title
  author = $Author
  source = $Source
  addedAt = (Get-Date -Format 'yyyy-MM-dd')
  status = 'discovered'
  sections = @($sections | ForEach-Object { [ordered]@{ id = $_.id; title = $_.title; status = 'unread'; readAt = $null; yield = [ordered]@{ atoms = @(); verdicts = @(); skeleton = @(); insights = @(); rejects = @() } } })
  cursor = @()
  summary = [ordered]@{ rounds = 0; accepted = 0; rejected = 0; deferred = 0 }
}
$json = $book | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $OutDir 'book.json'), $json, (New-Object System.Text.UTF8Encoding($false)))

# --- verify ------------------------------------------------------------------
$check = Get-Content (Join-Path $OutDir 'book.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($null -eq $check -or $check.sections.Count -ne $sections.Count) { throw 'book.json verification failed' }
Write-Output ("OK units={0} files={1} book.json verified (sections {2})" -f $units.Count, $i, $check.sections.Count)
if (Test-Path $tmp) {
  if ($KeepTemp) { Write-Output "temp kept: $tmp" } else { Remove-Item $tmp -Recurse -Force }
}
