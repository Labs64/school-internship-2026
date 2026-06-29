<#
.SYNOPSIS
  Windows counterpart of insert-html-content.sh.

.DESCRIPTION
  Finds a placeholder comment <!-- INSERT:<marker> --> in an HTML file and
  replaces it with the contents of another file, wrapped in:

    <!-- BEGIN:<marker> -->
    ...content...
    <!-- END:<marker> -->

  If the BEGIN/END markers already exist in the target file (inserted by a
  previous run), the content between them is replaced with the new content
  instead, so the script can be re-run to update previously inserted content.

.PARAMETER Target
  HTML file to modify (required).

.PARAMETER Source
  File whose contents will be inserted (required).

.PARAMETER Marker
  Marker name (default: CONTENT).

.PARAMETER Output
  Write result to this file instead of editing -Target in place.

.PARAMETER NoBackup
  Do not create a .bak backup when editing in place.

.EXAMPLE
  .\Insert-HtmlContent.ps1 -Target page.html -Source pricing-table.html -Marker PRICING_TABLE
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Target,
    [Parameter(Mandatory = $true)] [string]$Source,
    [string]$Marker = "CONTENT",
    [string]$Output,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) {
    Write-Error "Target file not found: $Target"
    exit 1
}
if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
    Write-Error "Source file not found: $Source"
    exit 1
}

$insertLine = "<!-- INSERT:$Marker -->"
$beginLine  = "<!-- BEGIN:$Marker -->"
$endLine    = "<!-- END:$Marker -->"

$targetLines = Get-Content -LiteralPath $Target
$sourceLines = Get-Content -LiteralPath $Source

$result = New-Object System.Collections.Generic.List[string]
$found = $false
$inBlock = $false

foreach ($line in $targetLines) {
    $trimmed = $line.Trim()

    if (-not $found -and $trimmed -eq $insertLine) {
        $result.Add($beginLine)
        foreach ($l in $sourceLines) { $result.Add($l) }
        $result.Add($endLine)
        $found = $true
        continue
    }

    if (-not $found -and $trimmed -eq $beginLine) {
        $result.Add($beginLine)
        foreach ($l in $sourceLines) { $result.Add($l) }
        $found = $true
        $inBlock = $true
        continue
    }

    if ($inBlock) {
        if ($trimmed -eq $endLine) {
            $result.Add($endLine)
            $inBlock = $false
        }
        continue
    }

    $result.Add($line)
}

if (-not $found) {
    Write-Error "No placeholder '$insertLine' or marker block '$beginLine' .. '$endLine' found in $Target"
    exit 1
}

if ($Output) {
    $result | Set-Content -LiteralPath $Output
    Write-Host "Wrote: $Output"
} else {
    if (-not $NoBackup) {
        Copy-Item -LiteralPath $Target -Destination "$Target.bak" -Force
    }
    $result | Set-Content -LiteralPath $Target
    Write-Host "Updated: $Target"
}
