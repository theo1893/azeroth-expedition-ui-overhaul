# 聊天 runtime 媒体清单

`addon/AzerothExpeditionUI/Media/Chat/` 只保存当前插件实际加载的聊天
runtime 资源；本文件是它的外部媒体清单。

## 0.4.1 legacy

| 文件 | 逻辑职责 |
|---|---|
| `ChatBookFrame.tga` | 主书框九宫格图集 |
| `ChatTabNormal.tga` | 普通 Tab |
| `ChatTabHover.tga` | 悬停 Tab |
| `ChatTabSelected.tga` | 选中 Tab |
| `ChatTabShelf.tga` | 连续承托带 |
| `ChatInputStrip.tga` | 输入条 |
| `ChatWaxSeal.tga` | 未读覆盖 |

`ChatBookFrame.tga` 为 `1024 × 1024`、32 位 TGA，有效图像位于画布上部。
`Modules/Chat.lua` 用九组 UV 构成九宫格。legacy 源母版是
`assets/source/chat/ChatBookFrame_Master_v1.png`；重建脚本为：

- `tools/build_chat_book_texture.py`
- `tools/build_chat_component_textures.py`

不要把频道名、消息或输入文字烘焙进纹理。legacy 信息底栏已从 runtime
删除，builder 不再导出对应字段。

## V3

V3 透明母版位于 `assets/source/chat/v3/`，当前并未被 Lua 加载。
`tools/build_chat_v3_runtime_assets.py` 仍处于迁移前审查阶段。V3 正式接入
前必须同时更新 runtime 媒体、atlas manifest、Lua UV、smoke test、聊天组件
合同和 overhaul tracker。
