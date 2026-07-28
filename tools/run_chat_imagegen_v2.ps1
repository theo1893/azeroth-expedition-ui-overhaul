param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('A', 'B', 'C')]
  [string]$Batch,

  [string]$RunName,

  [ValidateSet('v2', 'v3')]
  [string]$PromptVersion = 'v2',

  [string]$StyleReference,

  [string]$LockedBaselineReference,

  [string]$AdditionalEditReference,

  [switch]$UnifiedReferences
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$promptDirectory = Join-Path $repositoryRoot 'prompts\chat'
$promptFile = (
  Get-ChildItem -LiteralPath $promptDirectory -File -Filter ("*_" + $PromptVersion + ".md") |
    Select-Object -First 1
).FullName
if (-not $promptFile) {
  throw "Unable to locate the $PromptVersion chat image prompt document."
}
$promptLines = Get-Content -LiteralPath $promptFile -Encoding UTF8

$headingIndexes = @{}
for ($index = 0; $index -lt $promptLines.Count; $index++) {
  $line = $promptLines[$index]
  if ($line.StartsWith('## ') -and $line.Contains('A')) {
    $headingIndexes['A'] = $index
  } elseif ($line.StartsWith('## ') -and $line.Contains('B')) {
    $headingIndexes['B'] = $index
  } elseif ($line.StartsWith('## ') -and $line.Contains('C')) {
    $headingIndexes['C'] = $index
  }
}

if (-not $headingIndexes.ContainsKey($Batch)) {
  throw "Unable to locate image prompt batch $Batch."
}

$start = $headingIndexes[$Batch] + 1
if ($Batch -eq 'A') {
  $end = $headingIndexes['B'] - 1
} elseif ($Batch -eq 'B') {
  $end = $headingIndexes['C'] - 1
} else {
  $end = $promptLines.Count - 1
}

while ($start -le $end -and [string]::IsNullOrWhiteSpace($promptLines[$start])) {
  $start++
}
while ($end -ge $start -and [string]::IsNullOrWhiteSpace($promptLines[$end])) {
  $end--
}

$promptText = ($promptLines[$start..$end] -join "`n")
if (-not $RunName) {
  $RunName = "batch_" + $Batch.ToLowerInvariant()
}
if ($RunName -notmatch '^[a-z0-9_-]+$') {
  throw 'RunName may only contain lowercase letters, digits, underscores, and hyphens.'
}
$candidateSeries = if ($PromptVersion -eq 'v3') {
  'chat_v3_candidates'
} else {
  'chat_v2_candidates'
}
$destination = Join-Path $repositoryRoot ("generated\" + $candidateSeries + "\" + $RunName)
New-Item -ItemType Directory -Path $destination -Force | Out-Null

$defaultImage1 = (Resolve-Path -LiteralPath (Join-Path $repositoryRoot 'assets\source\chat\ChatBookFrame_Master_v1.png')).Path
$defaultImage2 = (Resolve-Path -LiteralPath (Join-Path $env:LOCALAPPDATA 'Temp\codex-clipboard-932a6522-78f3-40dc-879a-4241863b96f9.png')).Path
$lockedChatDirectory = Join-Path $repositoryRoot 'assets\locked\chat'
$defaultImage3 = (
  Get-ChildItem -LiteralPath $lockedChatDirectory -File -Filter '*_v3.png' |
    Select-Object -First 1
).FullName
if (-not $defaultImage3) {
  throw 'Unable to locate the approved V3 chat material reference.'
}

$inputImages = @()
if ($UnifiedReferences) {
  if (-not $StyleReference -or -not $LockedBaselineReference) {
    throw 'UnifiedReferences requires both StyleReference and LockedBaselineReference.'
  }
  $inputImages += (Resolve-Path -LiteralPath $StyleReference).Path
  $inputImages += (Resolve-Path -LiteralPath $LockedBaselineReference).Path
} else {
  $inputImages += $defaultImage1
  $inputImages += $defaultImage2
  $inputImages += $defaultImage3
  if ($StyleReference) {
    $inputImages += (Resolve-Path -LiteralPath $StyleReference).Path
  }
  if ($LockedBaselineReference) {
    $inputImages += (Resolve-Path -LiteralPath $LockedBaselineReference).Path
  }
}
if ($AdditionalEditReference) {
  $inputImages += (Resolve-Path -LiteralPath $AdditionalEditReference).Path
}

$executionParts = @()
for ($imageIndex = 0; $imageIndex -lt $inputImages.Count; $imageIndex++) {
  $executionParts += "Image $($imageIndex + 1) is $($inputImages[$imageIndex])."
}
$executionParts[0] = "Execution instruction: " + $executionParts[0]
$executionParts += "Save the final image to $destination and output its absolute file path directly."
$executionParts += "No need to review and verify."
$executionInstruction = $executionParts -join ' '

$payload = '$imagegen ' + $promptText + "`n`n" + $executionInstruction

Push-Location $repositoryRoot
try {
  $OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  [Console]::OutputEncoding = $OutputEncoding
  $npxCommand = (Get-Command 'npx.cmd' -ErrorAction Stop).Source
  $cliArguments = @(
    '--yes'
    '--package=@openai/codex@0.143.0'
    '--'
    'codex'
    'exec'
    '--skip-git-repo-check'
    '-m'
    'gpt-5.5'
    '-c'
    'model_reasoning_effort="medium"'
  )
  foreach ($inputImage in $inputImages) {
    $cliArguments += '-i'
    $cliArguments += $inputImage
  }
  $cliArguments += '-'
  $payload | & $npxCommand @cliArguments
  exit $LASTEXITCODE
} finally {
  Pop-Location
}
