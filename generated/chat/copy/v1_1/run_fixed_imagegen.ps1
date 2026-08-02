param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("A", "B1", "B2")]
  [string]$Section,

  [Parameter(Mandatory = $true)]
  [string]$RepoRoot,

  [Parameter(Mandatory = $true)]
  [string]$InputPath,

  [Parameter(Mandatory = $true)]
  [string]$ChildCwd
)

$ErrorActionPreference = "Stop"

$workFile = Join-Path $RepoRoot "docs\modules\chat\work\CHAT.COPY.V1.md"
$body = Get-Content -Raw -Encoding utf8 -LiteralPath $workFile

$headingPrefix = switch ($Section) {
  "A"  { "### A" }
  "B1" { "### B1" }
  "B2" { "### B2" }
}

$pattern = "(?m)^" + [regex]::Escape($headingPrefix) +
  "[^\r\n]*\r?\n\r?\n\x60{3}text\r?\n(?<prompt>.*?)\r?\n\x60{3}"
$match = [regex]::Match(
  $body,
  $pattern,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

if (-not $match.Success) {
  throw "Unable to extract authorized prompt section: $Section"
}

$prompt = $match.Groups["prompt"].Value
$promptBytes = [System.Text.Encoding]::UTF8.GetBytes($prompt)
$sha = [System.Security.Cryptography.SHA256]::Create()
$promptHash = [System.BitConverter]::ToString(
  $sha.ComputeHash($promptBytes)
).Replace("-", "").ToLowerInvariant()

New-Item -ItemType Directory -Force -Path $ChildCwd | Out-Null
if (Get-ChildItem -Force -LiteralPath $ChildCwd | Select-Object -First 1) {
  throw "Fixed child working directory must be empty: $ChildCwd"
}

$executionInstruction = @"
Execution instruction: Image 1 is $InputPath. Save the final image to ./generated and output its absolute file path directly. No need to review and verify.
"@

$childPrompt = '$imagegen ' + $prompt + "`r`n`r`n" +
  $executionInstruction.TrimEnd()

Write-Output "AEUI_PROMPT_SECTION=$Section"
Write-Output "AEUI_PROMPT_SHA256=$promptHash"
Write-Output "AEUI_INPUT_PATH=$InputPath"
Write-Output "AEUI_CHILD_CWD=$ChildCwd"

$arguments = @(
  "--yes",
  "--package=@openai/codex@0.143.0",
  "--",
  "codex",
  "exec",
  "-C",
  $ChildCwd,
  "--skip-git-repo-check",
  "-m",
  "gpt-5.5",
  "-c",
  'model_reasoning_effort="medium"',
  "-i",
  $InputPath,
  "--",
  $childPrompt
)

& npx.cmd @arguments
exit $LASTEXITCODE
