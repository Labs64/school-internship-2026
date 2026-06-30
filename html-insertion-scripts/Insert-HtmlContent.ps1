<#
.SYNOPSIS
  Windows counterpart of insert-html-content.sh.

.DESCRIPTION
  Finds every occurrence of the marker pair

    <!-- BEGIN:PricingTable -->
    <!-- END:PricingTable -->

  in an HTML file and inserts the contents of another file between them. If
  content is already present between a pair of markers (from a previous
  run), it is replaced with the new content, so the script can be re-run to
  update previously inserted content. A file may contain multiple marker
  pairs; all of them are updated with the same content.

.PARAMETER Target
  HTML file to modify (required). Must already contain one or more
  <!-- BEGIN:PricingTable --> / <!-- END:PricingTable --> marker pairs.

.PARAMETER Source
  File whose contents will be inserted (required).

.PARAMETER Output
  Write result to this file instead of editing -Target in place.

.PARAMETER NoBackup
  Do not create a .bak backup when editing in place.

.EXAMPLE
  .\Insert-HtmlContent.ps1 -Target page.html -Source pricing-table.html
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Target,
    [Parameter(Mandatory = $true)] [string]$Source,
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

$beginLine = "<!-- BEGIN:PricingTable -->"
$endLine   = "<!-- END:PricingTable -->"

$targetLines = Get-Content -LiteralPath $Target
$sourceLines = Get-Content -LiteralPath $Source

$result = New-Object System.Collections.Generic.List[string]
$found = $false
$inBlock = $false

foreach ($line in $targetLines) {
    $trimmed = $line.Trim()

    if (-not $inBlock -and $trimmed -eq $beginLine) {
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
    Write-Error "Marker pair '$beginLine' .. '$endLine' not found in $Target"
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
