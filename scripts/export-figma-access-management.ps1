param(
  [Parameter(Mandatory = $true)]
  [string]$FigmaToken,

  [string]$FileKey = 'fZy0Y8eWmYWOxlErRbWd0D',
  [string]$NodeId = '21:2721',
  [string]$OutDir = 'd:/APEX/GitTestSession/fixtures/figma-access-management'
)

$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$Headers = @{ 'X-Figma-Token' = $FigmaToken }

$NodeUrl = "https://api.figma.com/v1/files/$FileKey/nodes?ids=$([uri]::EscapeDataString($NodeId))"
$NodeResp = Invoke-RestMethod -Uri $NodeUrl -Headers $Headers -Method Get
$NodeResp | ConvertTo-Json -Depth 100 | Set-Content "$OutDir/node-21-2721.json" -Encoding utf8

function Get-FrameNodes($n) {
  $items = @()
  if ($null -eq $n) { return $items }

  if ($n.type -eq 'FRAME') {
    $items += [pscustomobject]@{
      id = $n.id
      name = $n.name
    }
  }

  if ($n.children) {
    foreach ($c in $n.children) {
      $items += Get-FrameNodes $c
    }
  }

  return $items
}

$Root = $NodeResp.nodes.$NodeId.document
$Frames = Get-FrameNodes $Root | Sort-Object id -Unique

$Frames | ForEach-Object { "{0}`t{1}" -f $_.id, $_.name } | Set-Content "$OutDir/frame-ids.tsv" -Encoding utf8

if ($Frames.Count -eq 0) {
  "Frames found: 0" | Set-Content "$OutDir/export-summary.txt" -Encoding utf8
  Write-Output 'No frames found under node.'
  exit 0
}

$IdsParam = [string]::Join(',', ($Frames.id | ForEach-Object { [uri]::EscapeDataString($_) }))
$ImgUrl = "https://api.figma.com/v1/images/$FileKey?ids=$IdsParam&format=png&scale=2"
$ImgResp = Invoke-RestMethod -Uri $ImgUrl -Headers $Headers -Method Get
$ImgResp | ConvertTo-Json -Depth 20 | Set-Content "$OutDir/images-map.json" -Encoding utf8

$count = 0
$indexRows = @()

foreach ($id in $ImgResp.images.PSObject.Properties.Name) {
  $url = $ImgResp.images.$id
  if (-not $url) { continue }

  $frame = $Frames | Where-Object { $_.id -eq $id } | Select-Object -First 1
  $name = if ($frame) { $frame.name } else { $id }

  $safeName = ($name -replace '[^a-zA-Z0-9\-_ ]', '') -replace '\s+', '-'
  $safeId = ($id -replace '[:/\\]', '-')
  $fileName = "{0}_{1}.png" -f $safeId, $safeName
  $outFile = Join-Path $OutDir $fileName

  Invoke-WebRequest -Uri $url -OutFile $outFile
  $count++

  $indexRows += [pscustomobject]@{
    FrameId = $id
    FrameName = $name
    ImageFile = $fileName
    PRDRequirement = ''
    Status = ''
    Notes = ''
  }
}

"Frames found: $($Frames.Count)" | Set-Content "$OutDir/export-summary.txt" -Encoding utf8
"Images downloaded: $count" | Add-Content "$OutDir/export-summary.txt"

$indexRows | Export-Csv -Path "$OutDir/review-index.csv" -NoTypeInformation -Encoding utf8

Write-Output "Frames found: $($Frames.Count)"
Write-Output "Images downloaded: $count"
Write-Output "Output: $OutDir"
Write-Output "Index: $OutDir/review-index.csv"
