# 资源工具

所有脚本只做确定性裁切、Alpha、缩放、图集、预演或格式转换，不负责自由
重绘。

| 脚本 | 状态 | 输入／输出 |
|---|---|---|
| `build_chat_book_texture.py` | legacy 必需 | V1 主框母版 → `ChatBookFrame.tga` |
| `build_chat_component_textures.py` | legacy 必需 | V1 母版 → Tab、输入、蜡封 TGA |
| `build_chat_v3_layout_preview.py` | V3 验收 | V3 三张母版 → `440 × 320` 临时预演 |
| `build_chat_v3_runtime_assets.py` | V3 迁移草稿 | V3 三张母版 → 五张临时 runtime 图集、manifest 与预览 |

legacy builder 在 V3 实机迁移完成前不得删除。

V3 脚本默认从 `assets/source/chat/v3/` 读取；可再生输出必须写到被 Git 忽略的
`generated/` 或系统临时目录。只有完成脚本审查、Lua 接入和目标客户端验证
后，才能把 TGA 复制到插件 `Media/Chat/`。

脚本依赖锁见根目录 [`requirements-tools.txt`](../../requirements-tools.txt)。
本次无底栏资源链在 Pillow `12.0.0` 上完成兼容 smoke；正式环境仍应安装锁定
的 `12.2.0`。对 exporter 的任何 crop／UV 变更必须同步
[CHAT_COMPONENT_SPEC.md](../implementation/CHAT_COMPONENT_SPEC.md)、Lua 和
tracker。
