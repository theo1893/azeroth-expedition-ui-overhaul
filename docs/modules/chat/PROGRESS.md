# Chat 详细进度

## 当前结论

- 主模块视觉：已锁定。
- 核心批次：`CHAT.CORE.V3 / runtime-corrected / P5`；runtime contract
  v1.6 已否定 v1.5 对全局 `UI_SCALE_CHANGED` 的单一路径假设，改为挂接
  pfUI 解锁缩放真实调用链 `pfChatLeft:SetScale → pfChatLeft.OnMove`；
  LocalScale／EffectiveScale 真正变化时强制重放一次，普通拖动不写几何；
  完整静态测试通过并已同步到 `TurtleWoWTest`。
- 运行时：插件 `0.5.0` 已加载 V3 主框、四状态 Tab、普通／聚焦输入和独立
  未读覆盖；静态测试通过。
- 容器：只保留 `pfChatLeft`。`pfChatRight` 默认强制隐藏，原本分流到右框的
  拾取、经验、荣誉、声望与技能消息组回收到 `ChatFrame1`。
- 尚未完成：language、聊天弹出菜单、URL copy、chatcopy、whisper proxy 的
  最终美术；这些对象保持原生或默认不加载。
- 用户决定暂时延后 `CHAT.TEXT` 的字体、描边和频道色可读性改造；本轮不修改
  正文呈现。下一项已选择复用 pfUI `chatcopy` 逻辑。固定 ImageGen 0.143.0
  已按用户授权分别执行 `CHAT.COPY.V1` A／B，但 A 错生为完整第二聊天框，
  B 错生为四个现代方形文档按钮；两者均在范围与对象身份门禁被内部退回。
  `CHAT.COPY.V1.1 / candidate-rejected / P3` 已按用户授权用固定
  ImageGen 0.143.0 执行到 A：单纸对象身份和安静中心通过，但主体外接比例
  相对 `380:248` 偏差 `+1.70%`，上下边中段的独特缺口、撕裂和卷边违反
  九宫格 stretch-zone 合同；照片式纸纤维与中性光也是次要美术漂移。
  因此未做 Alpha、预演或 source，B1 scaffold／B1 raw／B2 均未创建或
  上传。当前活跃版本已升级为
  `CHAT.COPY.V1.2 / candidate-rejected / P3`：A 不再调用 ImageGen，而从已接受
  V3 安静纸面确定性派生精确 `1140 × 744` 候选，分别锁定
  `1092 × 696` 九宫格 stretch center 与 `1080 × 696` 文字安全区；
  B1／B2 使用同一 `22:26` 外接框的 closed／open scaffold 与确定性 mask，
  ImageGen 只承担纸叶和皮夹表面。用户已于 `2026-07-29` 明确授权
  `CHAT.COPY.V1.2`，并允许上传 B1 closed scaffold、通过 mask 的 B1
  candidate 与 B2 open scaffold。A 的确定性候选和两种九宫格预演通过内部
  审查；B1 固定执行器的两次完整调用均输出 `1254 × 1254`，把对象放大到
  scaffold 外，并把纯绿底改成渐变。第一个失败门禁是 B1 画布／外接框／
  色键结构，故未做 mask，B2 没有上传或调用。chatcopy 继续默认不加载。
- Turtle WoW 实机：原始 runtime 截图确认 `FCF_DockUpdate` 覆盖停靠几何，
  且用户否决 `42px` 外接高度。随后两张复测截图仍由未同步的 Git HEAD
  安装副本产生，未加载 v1.1／v1.2，因此不构成版本验收。v1.2 正确部署后
  确认点击 Tab 可恢复紧凑尺寸，但登录首帧不会自动完成；同时选中文字过暗、
  点击区偏上。v1.3 复测后 Tab 尺度和选中文字已可进入下一轮，但新截图显示
  TabText 仍沿用 pfUI 底边锚点，且某次交互后的正文退回 pfUI 默认边距并越出
  书页。v1.4 继续复测发现改变缩放后默认 Tab 仍需点击一次才生效；v1.5
  虽增加 `UI_SCALE_CHANGED` 强制重放，但实机确认问题没有变化。代码审计
  随后确认 pfUI 解锁模式缩放直接调用 `pfChatLeft:SetScale` 与
  `pfChatLeft.OnMove`，并不走 v1.5 监听的全局事件。当前仍为 `P5`，不能
  标记 `P6`。
- legacy 公会／背包／延迟等信息 panel：默认路由已退役，源码保留。

## 子模块状态

| ID | 阶段 | 当前资产／实现 | 下一门禁 |
|---|---:|---|---|
| `CHAT.FRAME`／`LEFT` | `P5` V3 | `ChatBookFrameV3.tga` 九宫格；唯一左侧实例 | 实机检查接缝、缩放、拖动 |
| `CHAT.FRAME.RIGHT` | `P5` disabled-route | `single_chat_frame=1`；不分配资产 | 验证右框不显示且消息无丢失 |
| `CHAT.TABS` | `P5` V3 / r1.6 | `92 × 30` 四状态 atlas；TabText 居中；挂接 `pfChatLeft.OnMove` 的真实局部缩放边沿，并以 EffectiveScale 边沿检测兜底；普通拖动不强制重排 | 复测 pfUI 解锁滚轮与全局 UI Scale 均无需点击即可同步比例 |
| `CHAT.INPUT` | `P5` V3 | 普通／聚焦两状态三段式 atlas | 实机验证焦点、IME、输入历史 |
| `CHAT.INPUT.LANGUAGE` | `P1` | 可选原生 Button 已映射 | 实机确认对象、尺寸和语言状态 |
| `CHAT.UNREAD` | `P5` V3 | 独立 `ChatFrameNTabFlash` 覆盖 | 实机验证闪烁配置与选中清除 |
| `CHAT.TEXT` | `P5` layout / r1.4 | `380 × 248`／17 行；`30/30/32/40px` 安全区在 pfUI 刷新、Tab 切换和停靠后按需恢复 | 复测切换、拖动、保存停靠后不越出书页 |
| `CHAT.SCROLL.*`／`MENU.BUTTON`／`RESIZE` | `P1` hidden | 原生对象已登记，pfUI 当前隐藏 | 仅在决定恢复时建立资产合同 |
| `CHAT.POPUP.*` | `P1` | 四个原生菜单实例已映射，仍为过渡外观 | 实机拆分 shell、行状态和滚动 |
| `CHAT.URLCOPY.*` | `P1` | pfUI shell／input／close 已映射 | 实机测量并锁定便笺弹窗视觉 |
| `CHAT.COPY.*` | `P3` V1.2 candidate-rejected | A 的确定性纸面通过；B1 两次都改变画布、外接框和绿底；未 mask，未执行 B2；pfUI 逻辑保持未加载 | 新版本必须把 ImageGen 降为表面 donor，不再要求其保真像素坐标 |
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
- Chat copy 草案：
  [`work/CHAT.COPY.V1.md`](work/CHAT.COPY.V1.md)
- 首轮实机失败证据：
  [`04_chat_tabs_p5_game_failure.png`](../../../assets/references/chat/session-2026-07-29/04_chat_tabs_p5_game_failure.png)
- 第二轮高度失败证据：
  [`05_chat_tabs_p5_height_failure.png`](../../../assets/references/chat/session-2026-07-29/05_chat_tabs_p5_height_failure.png)
- 未同步部署证据：
  [`06_chat_tabs_stale_deployment.png`](../../../assets/references/chat/session-2026-07-29/06_chat_tabs_stale_deployment.png)
- v1.3 文字／正文布局失败证据：
  [`07_chat_tab_text_content_overflow.png`](../../../assets/references/chat/session-2026-07-29/07_chat_tab_text_content_overflow.png)

`assets/source/chat/v3/previews/` 中旧合成图仍包含已退役底栏，只作为历史 source
证据，不再作为当前运行时验收依据。新的无底栏预演由工具写入被忽略的
`generated/chat/v3/`。

## 下一步

1. 在已同步 v1.6 的测试客户端执行 `/reload`；确认 `/aeui status` 报告
   `chat-runtime=1.6`。
2. 打开 pfUI 解锁界面，在 `pfChatLeft` 拖动层上连续滚轮切换至少三档局部
   Scale；全程不点击 Tab，确认每档四枚 Tab 都立即应用新比例。
3. 再切换至少两档全局 UI Scale；不点击 Tab，确认 EffectiveScale 边沿兜底
   同样只重放一次并应用新比例。
4. 检查四枚 Tab 文字是否同时水平、垂直居中，并从皮革主体中下部切换频道。
5. 依次切换 Tab、尝试拖动后松开、触发停靠保存，确认正文始终保留
   `30/30/32/40px` 安全区且不会越出书页。
6. 再验证左框滚动、Tab 四状态、未读、输入焦点、链接、聊天历史与
   `540 × 420`／常用 UI Scale。
7. 确认右框始终隐藏，并验证拾取、经验、荣誉、声望与技能消息仍进入左框。
8. 核心批次实机通过后达到 `P6`，但保留 work 与 legacy 回退资产直至用户批准
   `P6-C` 清理清单。
9. 以 [`CHAT.COPY.V1.2`](work/CHAT.COPY.V1.md) 的失败证据为输入，准备新
   版本合同：A 的确定性纸面保持不变；B 的几何、外接框、状态差与 Alpha
   必须完全归本地确定性工具，ImageGen 只能提供可裁取的纸／皮革表面，
   不再承担画布尺寸、绝对坐标、共同锚点或 mask 对齐。新正文需用户另行
   明确授权后才能执行。
10. `CHAT.INPUT.LANGUAGE`、`CHAT.POPUP.*`、`CHAT.URLCOPY.*` 与
    `CHAT.WHISPER.TOGGLE` 在取得实机几何后另行准备组件 Prompt。
