$ErrorActionPreference = "Stop"

$destination = "D:\Git\azeroth-expedition-ui-overhaul\generated"
$reference = "D:\Git\azeroth-expedition-ui-overhaul\assets\locked\chat\聊天框视觉基准_v1.png"
$specification = "D:\Git\azeroth-expedition-ui-overhaul\docs\modules\chat\聊天框视觉规范_战地旧书_v1.md"

$verbatim = (
    Get-Content -LiteralPath $specification -Encoding UTF8 |
        Where-Object { $_ -like "> 聊天框严格沿用*" } |
        Select-Object -First 1
).Substring(2)

if ([string]::IsNullOrEmpty($verbatim)) {
    throw "The locked chat image prompt could not be found."
}

$codexInput = '$imagegen ' + $verbatim + @"

Execution instruction: Image 1 is $reference. Save the final image to $destination and output its absolute file path directly. No need to review and verify.
"@

& "C:\Program Files\nodejs\node.exe" "C:\Program Files\nodejs\node_modules\npm\bin\npx-cli.js" --yes "--package=@openai/codex@0.143.0" -- codex exec --skip-git-repo-check -m gpt-5.5 -c 'model_reasoning_effort="medium"' -i $reference -- $codexInput
exit $LASTEXITCODE
