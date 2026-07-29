# Chat 详细进度

## 当前结论

- 主模块视觉：已锁定。
- 核心批次：`CHAT.CORE.V3 / runtime-exported / P5`。
- 运行时：插件 `0.5.0` 已加载 V3 主框、四状态 Tab、普通／聚焦输入和独立
  未读覆盖；静态测试通过。
- 容器：只保留 `pfChatLeft`。`pfChatRight` 默认强制隐藏，原本分流到右框的
  拾取、经验、荣誉、声望与技能消息组回收到 `ChatFrame1`。
- 尚未完成：language、聊天弹出菜单、URL copy、chatcopy、whisper proxy 的
  最终美术；这些对象保持原生或默认不加载。
- Turtle WoW 实机：未完成，不能标记 `P6`。
- legacy 公会／背包／延迟等信息 panel：默认路由已退役，源码保留。

## 子模块状态

| ID | 阶段 | 当前资产／实现 | 下一门禁 |
|---|---:|---|---|
| `CHAT.FRAME`／`LEFT` | `P5` V3 | `ChatBookFrameV3.tga` 九宫格；唯一左侧实例 | 实机检查接缝、缩放、拖动 |
| `CHAT.FRAME.RIGHT` | `P5` disabled-route | `single_chat_frame=1`；不分配资产 | 验证右框不显示且消息无丢失 |
| `CHAT.TABS` | `P5` V3 | 四状态三段式 atlas；文字运行时绘制 | 实机验证点击、拖动、长名称 |
| `CHAT.INPUT` | `P5` V3 | 普通／聚焦两状态三段式 atlas | 实机验证焦点、IME、输入历史 |
| `CHAT.INPUT.LANGUAGE` | `P1` | 可选原生 Button 已映射 | 实机确认对象、尺寸和语言状态 |
| `CHAT.UNREAD` | `P5` V3 | 独立 `ChatFrameNTabFlash` 覆盖 | 实机验证闪烁配置与选中清除 |
| `CHAT.TEXT` | `P5` layout | `380 × 236`／16 行；正文继续使用高可读字体 | 实机验证长中文、链接与 UI Scale |
| `CHAT.SCROLL.*`／`MENU.BUTTON`／`RESIZE` | `P1` hidden | 原生对象已登记，pfUI 当前隐藏 | 仅在决定恢复时建立资产合同 |
| `CHAT.POPUP.*` | `P1` | 四个原生菜单实例已映射，仍为过渡外观 | 实机拆分 shell、行状态和滚动 |
| `CHAT.URLCOPY.*` | `P1` | pfUI shell／input／close 已映射 | 实机测量并锁定便笺弹窗视觉 |
| `CHAT.COPY.*` | `P5` route／`P1` objects | 功能源码保留，默认不加载；三类可见对象已映射 | 锁定复制入口与覆盖纸面视觉 |
| `CHAT.WHISPER.TOGGLE` | `P5` route／`P1` object | 功能源码保留，默认不加载 | 锁定代理开关视觉 |
| `CHAT.WHISPER.DIALOG` | `P1` shared-owner | 归未来 System 公共弹窗 | System 模块统一拆分 |

## V3 正式运行时

| 文件 | 画布 | 运行时职责 |
|---|---:|---|
| `ChatBookFrameV3.tga` | `1024 × 1024` | 左侧旧书九宫格 |
| `ChatTabAtlasV3.tga` | `512 × 512` | 普通／悬停／选中／禁用 Tab |
| `ChatTabShelfV3.tga` | `1024 × 64` | 连续承托带 |
| `ChatInputAtlasV3.tga` | `1024 × 256` | 普通／聚焦输入纸带 |
| `ChatUnreadSealV3.tga` | `64 × 128` | 未读覆盖 |

源资产与 provenance：
[source manifest](../../../assets/source/chat/v3/ChatV3_SourceManifest_v1.json)。
裁切、UV、画布和 runtime SHA：
[runtime manifest](../../../assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json)。

## 当前证据

- [`build_chat_v3_runtime_assets.py`](../../../tools/build_chat_v3_runtime_assets.py)
- [`chat_module_smoke.lua`](../../../tests/chat_module_smoke.lua)
- [`pfui_expedition_contract_test.lua`](../../../tests/pfui_expedition_contract_test.lua)
- 当前 adapter：[`Modules/Chat.lua`](../../../addon/AzerothExpeditionUI/Modules/Chat.lua)
- 活跃批次：
  [`work/CHAT.CORE.V3.md`](work/CHAT.CORE.V3.md)

`assets/source/chat/v3/previews/` 中旧合成图仍包含已退役底栏，只作为历史 source
证据，不再作为当前运行时验收依据。新的无底栏预演由工具写入被忽略的
`generated/chat/v3/`。

## 下一步

1. 在 Turtle WoW `1.18.1` 验证左框拖动、滚动、Tab 四状态、未读、输入焦点、
   链接、聊天历史与 `540 × 420`／常用 UI Scale。
2. 确认右框始终隐藏，并验证拾取、经验、荣誉、声望与技能消息仍进入左框。
3. 核心批次实机通过后达到 `P6`，但保留 work 与 legacy 回退资产直至用户批准
   `P6-C` 清理清单。
4. 实机可用时另行准备 `CHAT.INPUT.LANGUAGE`、`CHAT.POPUP.*`、
   `CHAT.URLCOPY.*`、`CHAT.COPY.*` 与 `CHAT.WHISPER.TOGGLE` 的组件 Prompt。
