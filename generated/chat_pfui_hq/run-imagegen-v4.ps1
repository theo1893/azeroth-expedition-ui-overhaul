$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom

$requestPath = 'D:\Git\azeroth-expedition-ui-overhaul\generated\chat_pfui_hq\imagegen_v4-request.txt'
$imageOne = 'D:\Git\azeroth-expedition-ui-overhaul\assets\source\chat\ChatBookFrame_Master_v1.png'
$imageTwo = 'C:\Users\西奥\AppData\Local\Temp\codex-clipboard-932a6522-78f3-40dc-879a-4241863b96f9.png'
$imageThree = 'D:\Git\azeroth-expedition-ui-overhaul\assets\locked\chat\聊天框独立艺术资源_v3.png'

$request = [System.IO.File]::ReadAllText($requestPath, [System.Text.Encoding]::UTF8)

$request |
    & 'C:\Program Files\nodejs\npx.cmd' --yes --package=@openai/codex@0.143.0 -- codex exec --skip-git-repo-check -m gpt-5.5 -c 'model_reasoning_effort="medium"' -i $imageOne -i $imageTwo -i $imageThree

exit $LASTEXITCODE
