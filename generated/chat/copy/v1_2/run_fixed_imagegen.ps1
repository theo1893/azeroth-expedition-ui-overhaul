param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("B1", "B2")]
  [string]$Section,

  [Parameter(Mandatory = $true)]
  [string]$RepoRoot,

  [Parameter(Mandatory = $true)]
  [string]$AuthorizedCommit,

  [Parameter(Mandatory = $true)]
  [string]$Input1,

  [string]$Input2,

  [Parameter(Mandatory = $true)]
  [string]$ChildCwd
)

$ErrorActionPreference = "Stop"

$gitObject = "${AuthorizedCommit}:docs/modules/chat/work/CHAT.COPY.V1.md"
$bodyLines = & git -C $RepoRoot show --no-textconv $gitObject
if ($LASTEXITCODE -ne 0) {
  throw "Unable to read authorized work file from $gitObject"
}
$body = [string]::Join("`n", $bodyLines)

$headingPrefix = "### $Section"
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

$resolvedInputs = @((Resolve-Path -LiteralPath $Input1).Path)
if ($Section -eq "B2") {
  if (-not $Input2) {
    throw "B2 requires both the masked B1 candidate and B2 open scaffold."
  }
  $resolvedInputs += (Resolve-Path -LiteralPath $Input2).Path
}

$promptBytes = [System.Text.Encoding]::UTF8.GetBytes($prompt)
$sha = [System.Security.Cryptography.SHA256]::Create()
$promptHash = [System.BitConverter]::ToString(
  $sha.ComputeHash($promptBytes)
).Replace("-", "").ToLowerInvariant()

New-Item -ItemType Directory -Force -Path $ChildCwd | Out-Null
if (Get-ChildItem -Force -LiteralPath $ChildCwd | Select-Object -First 1) {
  throw "Fixed child working directory must be empty: $ChildCwd"
}

$roleLines = for ($index = 0; $index -lt $resolvedInputs.Count; $index++) {
  "Image $($index + 1) is $($resolvedInputs[$index])."
}
$executionInstruction =
  "Execution instruction: " +
  ([string]::Join(" ", $roleLines)) +
  " Save the final image to ./generated and output its absolute file path directly. No need to review and verify."
$childPrompt = '$imagegen ' + $prompt + "`n`n" + $executionInstruction

Write-Output "AEUI_AUTHORIZED_COMMIT=$AuthorizedCommit"
Write-Output "AEUI_PROMPT_SECTION=$Section"
Write-Output "AEUI_PROMPT_SHA256=$promptHash"
for ($index = 0; $index -lt $resolvedInputs.Count; $index++) {
  Write-Output "AEUI_INPUT_$($index + 1)=$($resolvedInputs[$index])"
}
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
  'model_reasoning_effort="medium"'
)
foreach ($inputPath in $resolvedInputs) {
  $arguments += "-i"
  $arguments += $inputPath
}
$arguments += "--"
$arguments += "-"

$childPrompt | & npx.cmd @arguments
exit $LASTEXITCODE
