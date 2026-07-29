# Chat 详细进度

## 当前结论

- 主模块视觉：已锁定。
- pfUI 对象映射：左右框、输入、Tab、未读、URL 复制和隐藏控件已登记；
  language／URL copy／whisper 的最终视觉仍待实机与用户锁定。
- V3 透明源资产：`P4`。
- 当前正式 runtime：插件 `0.4.1` legacy 资源，静态测试达到 `P5`。
- Turtle WoW 实机：未完成。
- legacy 公会／背包／延迟等信息 panel：默认路由已退役，源码保留。

## 子模块状态

| ID | 阶段 | 当前资产／实现 | 下一门禁 |
|---|---:|---|---|
| `CHAT.FRAME` | `P4` V3／`P5` legacy | [V3 主框](../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)；Lua 仍加载 `ChatBookFrame.tga` | 导出 `ChatBookFrameV3.tga`、锁定 UV |
| `CHAT.FRAME.LEFT` | `P5` legacy | `pfChatLeft` 已由 adapter 接管 | V3 接入与实机三尺寸验收 |
| `CHAT.FRAME.RIGHT` | `P1` | `pfChatRight` 已映射，V3 adapter 未接管 | 确认右框启用／隐藏／停靠场景 |
| `CHAT.TABS` | `P4` V3／`P5` legacy | [V3 Tab](../../../assets/source/chat/v3/ChatTabs_Master_v3.png)；legacy 三状态 | 导出四状态 atlas 并验证禁用来源 |
| `CHAT.INPUT` | `P4` V3／`P5` legacy | [V3 控件](../../../assets/source/chat/v3/ChatControls_Master_v3.png)；legacy 未区分焦点 | 接入普通／聚焦两状态 |
| `CHAT.INPUT.LANGUAGE` | `P1` | 可选原生 Button 已映射 | 实机确认是否存在并锁定视觉 |
| `CHAT.UNREAD` | `P4` V3／`P5` legacy | V3 控件母版；legacy `ChatWaxSeal.tga` | 绑定 V3 独立覆盖 |
| `CHAT.TEXT` | `P5` layout | `380 × 236`／16 行预演 | 实机验证长中文与 UI Scale |
| `CHAT.SCROLL.*`／`MENU`／`RESIZE` | `P1` hidden | 真实原生对象已登记，pfUI 当前隐藏 | 仅在决定恢复时建立资产合同 |
| `CHAT.URLCOPY.*` | `P1` | pfUI shell／input／close 已映射，仍为过渡皮肤 | 实机测量并锁定小弹窗视觉 |
| `CHAT.WHISPER` | `P5` route／`P0` final | 未换肤入口默认不加载 | 映射输入、目标、关闭与转发 |

## V3 运行时目标

| 目标文件 | 画布 | 来源 |
|---|---:|---|
| `ChatBookFrameV3.tga` | `1024 × 1024` | V3 主框九宫格 |
| `ChatTabAtlasV3.tga` | `512 × 512` | 四状态 Tab |
| `ChatTabShelfV3.tga` | `1024 × 64` | 连续承托带 |
| `ChatInputAtlasV3.tga` | `1024 × 256` | 普通／聚焦输入 |
| `ChatUnreadSealV3.tga` | `64 × 128` | 未读覆盖 |

当前 Lua 仍加载 `addon/AzerothExpeditionUI/Media/Chat/` 中的 legacy TGA；
V3 接入必须在同一提交更新 exporter、manifest／UV、Lua、媒体与 smoke test。

## 已有证据

- [干净布局预演](../../../assets/source/chat/v3/previews/ChatLayout_Combined_Clean_v3.png)
- [安全区预演](../../../assets/source/chat/v3/previews/ChatLayout_Combined_Debug_v3.png)
- [`build_chat_v3_runtime_assets.py`](../../../tools/build_chat_v3_runtime_assets.py)
- [`chat_module_smoke.lua`](../../../tests/chat_module_smoke.lua)
- 当前 adapter：[`Modules/Chat.lua`](../../../addon/AzerothExpeditionUI/Modules/Chat.lua)

## 下一步

1. 在临时目录复跑 V3 exporter，检查 RGBA、2 的幂、4px 防渗色与接缝。
2. 审查五张目标 TGA 和 UV manifest。
3. 切换 Lua 纹理与状态，不改变聊天行为或点击几何。
4. 运行静态与 Lua tests。
5. 在 Turtle WoW 验证拖动、停靠、滚动、Tab、未读、输入焦点、三种尺寸与
   UI Scale。
6. 用户接受实机效果后达到 `P6`；随后清理 legacy／work 并进入 `P6-C`。
