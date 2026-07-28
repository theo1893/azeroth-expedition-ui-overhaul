# 聊天模块 V3 源资源

## 透明母版

- `ChatBookFrame_Master_v3.png`
  - A：凌乱、不对称的战地旧书空主框。
- `ChatTabs_Master_v3.png`
  - B：连续承托页边，以及普通、悬停、选中、禁用四个独立无字 Tab。
- `ChatControls_Master_v3.png`
  - C：普通／聚焦输入纸带、可复用底栏字段和未读蜡封书签。

三张母版均为真 RGBA，保留原始高分辨率。它们没有直接加载到游戏，也
没有升级为 `assets\locked\`。

## `raw/`

保存 imagegen 的均匀绿色色键输出，便于将来重新检查或改进去背景：

- `ChatBookFrame_Chroma_v3.png`
- `ChatTabs_Chroma_v3.png`
- `ChatControls_Chroma_v3.png`

不要把这些绿色背景文件直接转换为游戏 TGA。

## `previews/`

- `ChatLayout_Combined_Clean_v3.png`
  - 默认底栏状态和输入状态的干净合成。
- `ChatLayout_Combined_Debug_v3.png`
  - 标出 `380 × 236` 正文安全区的校验版本。

每个内框都是精确 `440 × 320 UI px`。预览中的频道名、聊天内容和状态
文字只是运行时排版样例，没有烘焙进 A/B/C 母版。

## 当前状态

- 美术生成与透明化完成。
- 440 × 320 容量校验完成，可放 16 行 12px 中文消息。
- pfUI 运行时接入已于 2026-07-29 按用户要求暂停。
- 恢复时先复核 `tools\build_chat_v3_runtime_assets.py`，再导出 TGA 和修改
  `addon\AzerothExpeditionUI\Modules\Chat.lua`。
