$ErrorActionPreference = 'Stop'

$repoRoot = 'D:\Git\azeroth-expedition-ui-overhaul'
$workFile = Join-Path $repoRoot 'docs\modules\quests\work\QUEST.LOG.LEFTPAGE.md'
$image2 = Join-Path $repoRoot 'assets\source\quests\ql-a1\QuestLogBookShell_Master_v1.png'
$image3 = Join-Path $repoRoot 'generated\quests\QL-B0\v2\backplates\attempt-03\raw\QL-B0-B_V2_r2_attempt-03_raw.png'
$attemptRoot = Join-Path $repoRoot 'generated\quests\QL-B0\v2\backplates\attempt-05'
$executorRoot = Join-Path $attemptRoot 'executor'
$childRoot = Join-Path $repoRoot 'generated\quests\QL-B0\v2\fixed-b-attempt-05'
$childGenerated = Join-Path $childRoot 'generated'
$promptPath = Join-Path $executorRoot 'stdin.txt'
$stdoutPath = Join-Path $executorRoot 'stdout.log'
$stderrPath = Join-Path $executorRoot 'stderr.log'
$pidPath = Join-Path $executorRoot 'pid.txt'

$nodeExe = 'C:\Program Files\nodejs\node.exe'
$codexJs = Join-Path $env:LOCALAPPDATA 'npm-cache\_npx\e266c27b9a96e5c8\node_modules\@openai\codex\bin\codex.js'
$image1Sha256 = '03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd'
$image1 = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'assets\locked\quests') -File |
    Where-Object { (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant() -eq $image1Sha256 } |
    Select-Object -First 1 -ExpandProperty FullName
if (-not $image1) {
    throw 'Unable to resolve Image 1 by its authorized SHA-256.'
}
$image2Sha256 = '91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5'
if ((Get-FileHash -LiteralPath $image2 -Algorithm SHA256).Hash.ToLowerInvariant() -ne $image2Sha256) {
    throw 'Image 2 does not match the frozen SHA-256.'
}
$image3Sha256 = '5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721'
if (-not (Test-Path -LiteralPath $image3)) {
    throw 'Unable to resolve the same-loop Image 3 edit target.'
}
if ((Get-FileHash -LiteralPath $image3 -Algorithm SHA256).Hash.ToLowerInvariant() -ne $image3Sha256) {
    throw 'Image 3 does not match the frozen same-loop SHA-256.'
}

New-Item -ItemType Directory -Path $executorRoot -Force | Out-Null
New-Item -ItemType Directory -Path $childGenerated -Force | Out-Null

$workText = [System.IO.File]::ReadAllText($workFile, [System.Text.Encoding]::UTF8)
$pattern = '(?ms)^## [^\r\n]*QL-B0-B V2\.r4\r?\n\r?\n(?<body>.*?)\r?\n\r?\n## Repair envelope'
$match = [System.Text.RegularExpressions.Regex]::Match($workText, $pattern)
if (-not $match.Success) {
    throw 'Unable to extract the authorized QL-B0-B V2.r4 execution body.'
}

$verbatimPrompt = $match.Groups['body'].Value
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$bodyBytes = $utf8NoBom.GetBytes($verbatimPrompt)
$sha = [System.Security.Cryptography.SHA256]::Create()
try {
    $bodySha256 = ([System.BitConverter]::ToString($sha.ComputeHash($bodyBytes))).Replace('-', '').ToLowerInvariant()
} finally {
    $sha.Dispose()
}
$expectedBodySha256 = '84f6764d4817c2872dbb8800b17de6044698753bcc96887d880a01a2f57c0a2e'
if ($bodySha256 -ne $expectedBodySha256) {
    throw "V2.r4 prompt SHA mismatch: $bodySha256"
}

$executionInstruction = 'Execution instruction: Image 1 is ' + $image1 + '. Image 2 is ' + $image2 + '. Image 3 is ' + $image3 + '. This Codex process is already @openai/codex@0.143.0. Fulfill the $imagegen edit request inside this process with its built-in image_gen tool. Do not read or invoke the imagegen-0-143-0 wrapper skill, and do not start any codex or npx subprocess. Save the provider output unchanged to ./generated and output its absolute file path directly. Do not review, resize, crop, recolor, chroma-key, or otherwise post-process it.'
$childPrompt = '$imagegen ' + $verbatimPrompt + [Environment]::NewLine + [Environment]::NewLine + $executionInstruction
[System.IO.File]::WriteAllText($promptPath, $childPrompt, $utf8NoBom)
[System.IO.File]::WriteAllText($stdoutPath, '', $utf8NoBom)
[System.IO.File]::WriteAllText($stderrPath, '', $utf8NoBom)

$arguments = @(
    $codexJs,
    'exec',
    '-C', $childRoot,
    '--skip-git-repo-check',
    '-s', 'workspace-write',
    '-m', 'gpt-5.5',
    '-c', 'model_reasoning_effort=medium',
    '-i', $image1,
    '-i', $image2,
    '-i', $image3,
    '--',
    '-'
)

$process = Start-Process `
    -FilePath $nodeExe `
    -ArgumentList $arguments `
    -WorkingDirectory $repoRoot `
    -RedirectStandardInput $promptPath `
    -RedirectStandardOutput $stdoutPath `
    -RedirectStandardError $stderrPath `
    -WindowStyle Hidden `
    -PassThru

[System.IO.File]::WriteAllText($pidPath, [string]$process.Id, $utf8NoBom)

[pscustomobject]@{
    pid = $process.Id
    body_sha256 = $bodySha256
    prompt = $promptPath
    stdout = $stdoutPath
    stderr = $stderrPath
    child_generated = $childGenerated
} | ConvertTo-Json -Compress
