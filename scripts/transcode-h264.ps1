param(
  [Parameter(Mandatory = $true)]
  [string[]]$Inputs,

  [int]$Crf = 22,
  [ValidateSet('ultrafast','superfast','veryfast','faster','fast','medium','slow','slower','veryslow')]
  [string]$Preset = 'medium'
)

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
  Write-Error 'ffmpeg not found in PATH. Please install ffmpeg first.'
  exit 1
}

foreach ($inputPath in $Inputs) {
  if (-not (Test-Path $inputPath)) {
    Write-Warning "Skip missing file: $inputPath"
    continue
  }

  $resolved = (Resolve-Path $inputPath).Path
  $directory = Split-Path $resolved -Parent
  $baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolved)
  $extension = [System.IO.Path]::GetExtension($resolved)
  $outputPath = Join-Path $directory ("{0}_h264{1}" -f $baseName, $extension)

  Write-Host "Transcoding: $resolved"
  Write-Host "Output:     $outputPath"

  ffmpeg -y -i "$resolved" -c:v libx264 -pix_fmt yuv420p -movflags +faststart -preset $Preset -crf $Crf -an "$outputPath"

  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed: $resolved"
    exit $LASTEXITCODE
  }
}

Write-Host 'Done.'
