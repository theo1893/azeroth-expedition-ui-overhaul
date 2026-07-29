# Chat 核心 V3

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.FRAME`、`CHAT.FRAME.LEFT`、`CHAT.TABS`、`CHAT.INPUT`、
  `CHAT.UNREAD`、`CHAT.TEXT`
- 版本：`CHAT.CORE.V3 / runtime contract v1.6`
- 子状态：`runtime-corrected`
- 项目阶段：`P5`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 当前操作：修正 v1.5 只监听全局缩放事件、遗漏 pfUI 解锁界面对
  `pfChatLeft` 直接缩放的问题；本版本未生图、未修改已接受 source 或
  atlas 像素
- 锁定视觉基准：
  - [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)
    — 游戏内物件身份、紧凑尺度和香草 HUD 综合色感
  - [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)
    — 手绘页边、旧皮革和实体厚度；不继承固定槽、龙饰或对称结构
- 基准 Prompt provenance：
  - [`ART_BASELINE.md`](../ART_BASELINE.md)
  - [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md)
  - 历史执行正文：Git `73da6c5` 中
    `prompts/chat/聊天框模块化资源_执行提示词_v3.md`
- source：
  - [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)
  - [`ChatTabs_Master_v3.png`](../../../../assets/source/chat/v3/ChatTabs_Master_v3.png)
  - [`ChatControls_Master_v3.png`](../../../../assets/source/chat/v3/ChatControls_Master_v3.png)
- source manifest：
  [`ChatV3_SourceManifest_v1.json`](../../../../assets/source/chat/v3/ChatV3_SourceManifest_v1.json)
- runtime manifest：
  [`ChatV3_RuntimeManifest_v1.json`](../../../../assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json)

## 美术基准继承

### 权威顺序

1. 两张 Chat 锁定图及 Chat 主／子模块 Prompt。
2. [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
3. [`SUBMODULES.md`](../SUBMODULES.md) 的真实对象、状态、几何和单左框合同。
4. 三张已接受 V3 source，只承担各自物理组件与材料连续性。

### 必须继承的视觉 DNA

- 屏幕左下角一本长期携带、反复修补的厚战地旧书。
- 纸张第一、深胡桃旧皮革第二、氧化黄铜第三。
- 左上暖光、低饱和暖赭／烟褐色域、二维手绘位图和非镜像磨损。
- 正文阅读区安静连续；Tab 是皮革索引签，输入是浅纸带，未读是小型蜡封。

### 本批组件级转译

- `CHAT.FRAME` 只导出空九宫格书框并挂载到 `pfChatLeft`。
- `CHAT.TABS` 使用一条承托带和同点击几何的四状态三段式 atlas。
- `CHAT.INPUT` 使用普通／聚焦两行三段式 atlas，焦点不改变 Frame 几何。
- `CHAT.UNREAD` 只覆盖 `ChatFrameNTabFlash` 的显示语义。
- `CHAT.TEXT` 继续由 runtime 绘制；频道签可使用霞鹜文楷，正文不替换为书法体。

### 明确不继承

- 不导出旧母版中的公会／背包／延迟或复用底栏字段。
- 不为 `pfChatRight` 生成第二本书。
- 不把文字、Tab、输入、未读、语言按钮、弹出菜单或复制控件烘焙进主框。
- 不继承锁定独立资源中的龙饰、尖顶、固定槽和规则对称金属建筑。

### 冲突审计

- pfUI 原始设计允许右侧 Loot & Spam 框；用户明确只保留一个左侧聊天框。
  裁决为禁用 `C.chat.right.enable`、隐藏 `pfChatRight`，并把五类消息组回收到
  `ChatFrame1`，不能用隐藏造成数据丢失。
- 历史 source 预演包含已退役底栏；当前模块 Prompt 与用户决策优先。
  exporter 不裁切该字段，新预演只显示普通／聚焦输入纸带。
- V3 source 早于当前 manifest 工作流，原始 generation session／result ID
  未留存。manifest 明确记录 `null` 与 provenance gap，不伪造 ID。

## 组件合同

- 逻辑对象与数量：一个左侧书框；一个 Tab 承托带；每个可见左侧 Tab 一套
  三段式状态；一个三段式输入框；每个 Tab 一个独立未读覆盖。
- Tab 状态：normal／hover／selected／disabled。
- 输入状态：normal／focus。
- runtime 几何：书框最小 `440 × 320`；正文 `380 × 248`；四枚 Tab
  基准 `92 × 30`、间距 `3px`、顶部偏移 `2px`，Tab panel 高 `32px`，
  承托带高 `16px` 且顶部偏移 `18px`；超过四枚时按承托区等宽收缩；
  Tab 命中区仅向下扩展 `8px`；输入 `380 × 25`；未读 texture
  `16 × 32`、可见标记约
  `14 × 22`。
- TabText：锚到所属 `ChatFrameNTab` 的 `CENTER`，水平各留 `6px`，高
  `18px`，水平 `CENTER`／垂直 `MIDDLE`。
- 拉伸：书框九宫格；Tab 和输入仅横向三段式；状态切换不改 Parent、Point、
  Width、Height 或点击框。
- 布局所有权：首次 `Apply`，以及 `pfUI.chat.RefreshChat`、
  `FCF_SelectDockFrame`、`FCF_DockUpdate` 和 `FCF_SaveDock` 返回后检查
  合同；只修复发生偏移的 Tab、TabText 或正文锚点。登录／刷新后 `0.5s`
  再执行一次终局装配；周期 `Maintain` 只更新状态 UV。拖动锁期间只记录
  一次待布局，解锁后的下一帧执行一次，不持续抢写。
- 缩放例外：pfUI 解锁模式会直接执行 `pfChatLeft:SetScale`，随后调用
  `pfChatLeft.OnMove`，不保证触发 `UI_SCALE_CHANGED`。adapter 包装真实
  `OnMove` 回调，只在 LocalScale／EffectiveScale 数值变化时立即强制重放
  一次 panel、所有 docked Tab、TabText、正文锚点和命中区；普通拖动不
  强制重放。现有维护节拍只比较 EffectiveScale 边沿，以捕获
  `UIParent:SetScale` 等无事件路径；全局事件仍保留为兜底。
- Alpha：所有 TGA 为 RGBA、2 的幂；Tab cell 和 shelf 含至少 4px atlas
  间隔；source 不直接加载。
- 回退：禁用 AEUI Chat 时保留 pfUI 行为；legacy TGA 在 P6-C 前保留。

## 最终执行正文

本批不调用 ImageGen。对三张已接受 V3 source 只执行以下确定性导出，不重绘、
不补画、不裁切退役底栏字段：

```text
python3 tools/build_chat_v3_runtime_assets.py
  --runtime-dir addon/AzerothExpeditionUI/Media/Chat
  --artifact-dir generated/chat/v3/runtime-artifacts
  --manifest assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json
```

## 执行记录

- exporter：
  [`build_chat_v3_runtime_assets.py`](../../../../tools/build_chat_v3_runtime_assets.py)
- 日期：`2026-07-29`
- ImageGen 会话／结果 ID：本批未生图；接受 source 的历史 ID 未留存，见
  source manifest 的 provenance gap。
- 正式 runtime：
  - `addon/AzerothExpeditionUI/Media/Chat/ChatBookFrameV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatTabAtlasV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatTabShelfV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatInputAtlasV3.tga`
  - `addon/AzerothExpeditionUI/Media/Chat/ChatUnreadSealV3.tga`
- Lua 所有权：
  [`Modules/Chat.lua`](../../../../addon/AzerothExpeditionUI/Modules/Chat.lua)
- raw、atlas contact sheet 和重组预演仅在被忽略的
  `generated/chat/v3/`，不是跨设备资产。

### Runtime contract v1.1 修正

- 实机证据：
  [`04_chat_tabs_p5_game_failure.png`](../../../../assets/references/chat/session-2026-07-29/04_chat_tabs_p5_game_failure.png)
- 首个失败门禁：`runtime-exported → game-validated` 的 Tab 点击几何／视觉
  装配。原生 `FCF_DockUpdate` 在首次 Apply 后按文字宽度重新设置 Tab，
  四枚实际只占承托区约四分之三；选中签使用原生顶端锚点，贴住书框上沿。
- 排除项：重放 exporter 后四状态源裁切、atlas 行、三段 UV、Alpha 与 TGA
  SHA 全部和 manifest 一致；不是 source 或 imagegen 结构失败。
- 修正：
  - 按 `DOCKED_CHAT_FRAMES` 顺序，在 `FCF_DockUpdate` 返回后同一帧恢复
    `92 × 42`、`3px` 间距和 `3px` 顶部偏移；
  - 超过四枚时按 `380px` 可用宽度等宽收缩；
  - AEUI 三段纹理标记为受管 Region，pfUI 通用 Tab Region 高度循环不再
    把它们压回文字高度；
  - 维护循环仍不改写 Tab 几何。
- 未改变：五张正式 runtime TGA 的 SHA、已接受 source、状态 UV 和主框正文
  安全区。

### Runtime contract v1.2 修正

- 实机证据：
  [`05_chat_tabs_p5_height_failure.png`](../../../../assets/references/chat/session-2026-07-29/05_chat_tabs_p5_height_failure.png)
- 第一个失败门禁：`runtime-corrected → game-validated` 的 Tab 纵向尺度。
  该截图后来确认仍由原始 Git HEAD 安装副本产生，不能证明 v1.1 已在游戏
  加载；但用户对原始 `42px` 外接高度的直接否决仍是有效产品反馈。
- 修正：
  - 四状态共同外接高度从 `42px` 降为 `30px`，顶部偏移从 `3px` 降为
    `2px`；
  - panel 从 `45px` 降为 `32px`，承托带从 `23px` 降为 `16px` 并放在
    `y=18px`；
  - 正文上沿从 `44px` 收回到 `32px`，新增空间归还消息区域，不留下空槽；
  - `FCF_DockUpdate` 后仍只执行一次几何恢复，维护循环仍只换状态 UV。
- 未改变：Tab 宽度、间距、四状态语义、点击顺序、五张 runtime TGA 像素与
  SHA、已接受 source 和输入区。

### Runtime contract v1.3 修正

- 有效实机结论：v1.2 正确加载后，点击任意 Tab 会使四枚标签恢复
  `92 × 30` 的紧凑布局，证明最终几何合同有效；但刚进入游戏时仍保留
  pfUI／原生的临时尺寸。选中签文字同时被压成近黑色，标签皮革主体的中下部
  也位于原点击框之外。
- 第一个失败门禁：`runtime-corrected → game-validated` 的启动时序、文字
  可读性与实际命中范围。
- 根因：
  - AEUI 首次 `Apply` 早于登录阶段最后一次 pfUI／原生停靠装配；点击 Tab
    会触发后续停靠更新并恢复 AEUI 几何；
  - v1.2 的 selected 文字色与深色皮革选中签对比不足；
  - Button 外接高度虽然已降为 `30px`，但视觉皮革向下延伸的部分没有纳入
    命中范围。
- 修正：
  - `Apply`、`PLAYER_ENTERING_WORLD` 与 `UI_SCALE_CHANGED` 后安排一次
    `0.5s` 终局装配；到期后仅重做一次 Tab panel、聊天正文与 Tab 状态，
    不把几何写入周期维护；
  - 选中文字改为亮暖金 `RGBA(1.00, 0.88, 0.62, 1.00)`；
  - 保持 `92 × 30` 视觉和排列不变，通过
    `SetHitRectInsets(0, 0, 0, -8)` 只把命中边界向下扩展 `8px`；
  - `/aeui status` 增加 `chat-runtime=1.3`，用于直接确认游戏当前加载的
    运行时合同。
- 未改变：五张正式 runtime TGA、已接受 source、atlas 裁切与 UV、Tab
  状态语义、正文内容和消息路由。

### Runtime contract v1.4 修正

- 实机证据：
  [`07_chat_tab_text_content_overflow.png`](../../../../assets/references/chat/session-2026-07-29/07_chat_tab_text_content_overflow.png)
- 结论：v1.3 仍未通过 `runtime-corrected → game-validated`。截图中四枚
  TabText 沿皮革签上沿排列而非处于 Button 中心；正文左右边距从合同的
  `30px` 退回 pfUI 默认窄边距，底部红字越过书页边缘。
- 触发审计：仅凭截图无法还原用户点中的具体对象，但越界后的锚点形态与
  `pfUI.chat.RefreshChat()` 对全部 docked `ChatFrameN` 写入的默认
  `TOPLEFT/BOTTOMRIGHT` 边距一致。该函数可由停靠保存、聊天框拖动结束、
  channel 设置和登录刷新触发；Tab 切换／`FCF_DockUpdate` 也可能随后改写
  docked 对象。
- 根因：
  - AEUI v1.3 只设置 Tab 字体和颜色，没有接管
    `ChatFrameNTabText` 的 Point、文字安全宽度与垂直对齐；
  - `FCF_SelectDockFrame` 的后置 Hook 只调用状态维护，
    `FCF_DockUpdate` 的后置 Hook 只恢复 Tab，均未恢复正文安全区；
  - AEUI 没有监听 `pfUI.chat.RefreshChat()` 完成后的最终几何。
- 修正：
  - 每枚 TabText 使用所属 Button 的单一 `CENTER` 锚点，水平各留 `6px`、
    文字区高 `18px`，水平 `CENTER`／垂直 `MIDDLE`，并标记为
    `aeuiManaged`，pfUI 后续刷新跳过其默认底边布局；
  - 在 `pfUI.chat.RefreshChat()`、`FCF_SelectDockFrame`、
    `FCF_DockUpdate` 与 `FCF_SaveDock` 返回后统一核对 Tab、TabText 和正文
    `30/30/32/40px` 安全区；
  - 几何完全匹配时不写 Point／Width／Height；拖动锁期间只保留一个 pending
    标志，解锁后的下一帧恢复一次，避免维护循环持续抢写；
  - `/aeui status` 的 runtime 自报升级为 `chat-runtime=1.4`。
- 未改变：五张 runtime TGA 像素与 SHA、已接受 source、atlas UV、频道消息、
  停靠数据、输入和未读语义。

### Runtime contract v1.5 修正

- 有效实机结论：v1.4 改变 UI Scale 后，未交互的默认 Tab 继续以旧屏幕比例
  显示；点击任意 Tab 后，四枚 Tab 才同时应用新比例。
- 第一个失败门禁：`runtime-corrected → game-validated` 的 UI Scale 动态
  装配。
- 根因：v1.4 在 `UI_SCALE_CHANGED` 后仍走“只修复逻辑数值偏移”的路径。
  缩放前后 Tab 的 Width／Height 仍是 `92 × 30 UI px`，Point 也不变，因此
  `PointMatches` 判定无需写入；香草客户端保留了旧屏幕像素缓存。首次点击
  触发 `FCF_*` 对几何的实际写入后，缓存才刷新。
- 修正：
  - `UI_SCALE_CHANGED` 单独标记 `startupLayoutForce`，连续缩放事件合并到
    最后一次后的 `0.5s`；
  - 普通 addon Refresh 既不能推迟已安排的缩放定型时间，也不能清除该
    force 标记；
  - 到期后无条件重放一次 Tab panel、全部 docked Tab、TabText、正文锚点和
    HitRect，即使逻辑 Point／Width／Height 与合同完全相同；
  - 强制状态在成功 reflow 后立即清除，后续普通事件和 `Maintain` 继续只在
    真实偏移时恢复，不形成周期几何写入；
  - `/aeui status` 的 runtime 自报升级为 `chat-runtime=1.5`。
- 未改变：`92 × 30` 逻辑合同、Tab 状态与顺序、正文安全区、五张 runtime
  TGA 像素与 SHA、source、消息／停靠数据。

### Runtime contract v1.6 修正

- 有效实机结论：v1.5 正确加载后改变缩放，默认 Tab 仍不应用新比例；仍需
  点击一次 Tab。v1.5 的静态缓存模拟通过，但没有覆盖用户实际使用的 pfUI
  解锁缩放入口。
- 第一个失败门禁：`runtime-corrected → game-validated` 的 pfUI owner
  局部缩放装配。
- 根因：
  - `addon/pfUI/modules/unlock.lua` 的 `DraggerOnMouseWheel` 直接执行
    `frame:SetScale(scale)`，随后调用 `frame:OnMove()`；该路径不会可靠发送
    `UI_SCALE_CHANGED`；
  - `pfChatLeft.OnMove` 原实现只调用 `pfUI.chat:RefreshChat()`；后者会更新
    正文锚点，但不会保证重新写入逻辑数值仍为 `92 × 30` 的 Tab，因此
    v1.5 的条件恢复仍跳过 Tab；
  - 点击 Tab 后原生 `FCF_*` 实际重写 Tab 几何，才刷新香草客户端的屏幕像素
    表现。
- 修正：
  - adapter 保留并包装 `pfChatLeft.OnMove`；原回调完整返回后比较 owner 的
    `GetScale()` 与 `GetEffectiveScale()`；
  - 只有任一缩放值真正变化时同步强制重放一次全部受管几何；同一 Scale 下
    的普通拖动／保存不会强制重写；
  - 现有 `Maintain` 不增加第二个轮询器，只在原有节拍中比较
    EffectiveScale；检测到 `UIParent:SetScale` 等无事件边沿时同样只强制
    重放一次；
  - `UI_SCALE_CHANGED` 与登录终局装配继续保留；若边沿检测已经同步完成，
    会清除同一缩放的待执行 force，避免重复重放；
  - `/aeui status` 的 runtime 自报升级为 `chat-runtime=1.6`。
- 未改变：Tab 逻辑尺寸、文字／命中区、安全区、五张 runtime TGA 像素与
  SHA、已接受 source、atlas UV、消息与停靠数据。

### 测试客户端部署核验

- 未同步部署截图：
  [`06_chat_tabs_stale_deployment.png`](../../../../assets/references/chat/session-2026-07-29/06_chat_tabs_stale_deployment.png)
- 核验结论：该截图不是 v1.2 失败。截图产生后检查
  `D:\Softwares\TurtleWoWTest\Interface\AddOns`，安装文件仍精确匹配
  Git HEAD：
  - `AzerothExpeditionUI/Modules/Chat.lua` blob
    `e4c6ff291217ab38516bddcb49d8278692e2c5bf`，不含 `TAB_LAYOUT`；
  - `pfUI/modules/chat.lua` blob
    `b6bc6f670e0a6bdfb0b7437e11a81ca91e8e3b99`，不含
    `aeuiManaged` Region 保护。
- 排除项：测试目录只有一个 `AzerothExpeditionUI` 与一个 `pfUI`；两份 TOC
  和全部 Chat TGA 均与仓库一致，不是重复插件或旧媒体。
- 已同步并逐文件校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `8abc5aa6ba2b0a852fb1f9a90e08a32f796ad5a6000dd6f435bc0cef067c0bb0`；
  - `pfUI/modules/chat.lua` SHA-256
    `fdaf6644561226bf23a657d39fc49b3b31cbf849deceeb780b8690fe67dcd2a4`。
- 部署时 `WoW.exe` 正在运行；磁盘副本已正确，但必须 `/reload` 或重启后
  才能形成第一张有效的 v1.2 实机证据。
- v1.3 已再次按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `176eda4650cf4aab504786e39400eb4c5fb4306c24a6e02cbb39aab775dfc193`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` 继续与仓库匹配，SHA-256
    `fdaf6644561226bf23a657d39fc49b3b31cbf849deceeb780b8690fe67dcd2a4`。
- v1.3 部署时 `WoW.exe` 仍在运行；需要 `/reload` 或重启后，通过
  `/aeui status` 中的 `chat-runtime=1.3` 确认新代码已经进入当前会话。
- v1.4 已按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `89bf389b0790a201545717ae45e1935bf0021bee84d40e801c3f081aa5ab33a5`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` SHA-256
    `fa044dabf806707439adaa59623a4df11243c63e82c5fa362bd388e863a87ca6`。
- 同步时检测到两个 `WoW.exe` 进程；磁盘副本已匹配，但相关游戏会话必须
  `/reload` 或重启，并以 `/aeui status` 的 `chat-runtime=1.4` 为加载证据。
- v1.5 已按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `6dd4c5e352e7fbc5b44dd603e261fc15bcbd3a7ff1a44ed2af9f4bab5783027a`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` SHA-256
    `fa044dabf806707439adaa59623a4df11243c63e82c5fa362bd388e863a87ca6`。
- v1.5 同步时仍检测到两个 `WoW.exe` 进程；相关游戏会话必须 `/reload`
  或重启，并以 `/aeui status` 的 `chat-runtime=1.5` 为加载证据。
- v1.6 已按明确文件同步并校验：
  - `AzerothExpeditionUI/Modules/Chat.lua` SHA-256
    `47f569a2ea77b2c16eb2ad548ff0c765c02503944e007787c488c722e3a59617`；
  - `AzerothExpeditionUI/Core/Bootstrap.lua` SHA-256
    `913a84852fab9d727c45d19ab6b0f64f27e3ec18ee16db3a6de666a3a5ca9b24`；
  - `pfUI/modules/chat.lua` SHA-256
    `fa044dabf806707439adaa59623a4df11243c63e82c5fa362bd388e863a87ca6`。
- v1.6 同步时仍检测到两个 `WoW.exe` 进程；磁盘副本已匹配，相关游戏会话
  必须 `/reload` 或重启，并以 `/aeui status` 的
  `chat-runtime=1.6` 为加载证据。

## 审查记录

- 语义／物理：主框、Tab、输入、未读均对应真实 runtime 对象；右框无资产。
- 透视／图层：主框为底层，承托带位于 Tab 后，正文和动态文字在纸面上，
  输入独立覆盖书页下沿。
- 装配：`440 × 320` 无底栏预演保留 `380 × 248` 正文安全区。
- 技术：五张 TGA 均为 RGBA 与 2 的幂；SHA、crop 和 UV 见 runtime manifest。
- 静态测试：Chat smoke、pfUI expedition contract、repository contract、
  asset-workflow contract、quest design contract、Python AST 和
  `git diff --check`。
- 尚未发生：Turtle WoW `1.18.1` 实机验证和 `P6-C` 清理。
- 2026-07-29：用户指出当前正文可读性不足，但明确决定把字体、描边与频道色
  改造延后；本批继续保持现有 `CHAT.TEXT` 呈现，不把该问题混入后续
  `CHAT.COPY` 资产。
- 2026-07-29 首轮实机：**失败，保持 P5**。书框和正文可见；Tab 几何未
  保持 runtime 合同。v1.1 静态修正完成，等待同场景复测。
- 2026-07-29 后续两张截图：安装副本仍为 Git HEAD，故不作为 v1.1／v1.2
  游戏结论；用户对 `42px` 的否决保留为 v1.2 产品输入。
- 2026-07-29 v1.2 正确加载后的复测：点击任意 Tab 后几何正常，但登录初始
  状态、选中文字和皮革主体命中范围未过门禁；v1.3 静态修正完成，等待部署。
- 2026-07-29 v1.3：Chat smoke、pfUI expedition contract、repository
  contract 与 asset-workflow contract 通过；目标目录三份相关 Lua 哈希
  匹配，已部署到测试客户端，等待重载后的实机结论。
- 2026-07-29 v1.3 实机：Tab 外接尺度、selected 文字颜色与主体点击问题已
  不再构成本截图的首个失败门禁；TabText 中心和正文事件后安全区失败，保持
  `P5`。v1.4 已完成代码与合同修正并同步，等待重载复测。
- 2026-07-29 v1.4：新增 pfUI Refresh、Tab 选择、Dock 更新、Dock 保存与
  拖动锁后恢复模拟；Chat smoke、pfUI expedition contract、repository
  contract、asset-workflow contract、Python AST 与 `git diff --check`
  通过；三份目标 Lua 哈希匹配，等待实机重载。
- 2026-07-29 v1.4 缩放复测：改变 UI Scale 后默认 Tab 没有主动刷新屏幕
  比例，点击一次后才生效；保持 `P5`。v1.5 已加入对“逻辑数值不变但必须
  重放”的 smoke 场景。
- 2026-07-29 v1.5：缩放 force 标记、普通 Refresh 不延后、单次全几何
  reflow 与 force 清除断言通过；完整静态测试通过，三份目标 Lua 哈希匹配，
  随后实机确认缩放问题没有变化，仍需点击一次 Tab；v1.5 失败并保持
  `P5`。代码审计确认测试模拟的是全局 `UI_SCALE_CHANGED`，未覆盖 pfUI
  解锁模式的 `pfChatLeft:SetScale → OnMove` 真实入口。
- 2026-07-29 v1.6：新增 owner LocalScale／EffectiveScale 记录、
  `pfChatLeft.OnMove` 后置边沿检测、无事件 EffectiveScale 兜底，以及
  “普通拖动不强制写几何”的 smoke 断言；完整静态测试通过，三份目标 Lua
  哈希匹配并已部署，等待 `/reload` 后实机复测。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一门禁 |
|---|---|---|---|
| V3 runtime contract v1 | source／runtime manifests、五张 TGA、Lua 与 tests | `runtime-exported / P5` | Turtle WoW 实机验证 |
| V3 runtime contract v1.1 | exporter 重放；事件后 Tab 重排与受管 Region 静态测试 | 未获得有效独立实机加载，已由 v1.2 取代 | 改为紧凑纵向合同 |
| V3 runtime contract v1.2 | 用户否决原始 `42px`；`30px` Tab、`16px` 承托带、`32px` 正文上沿；目标目录哈希核验；有效游戏加载 | 点击后几何正确；启动时序、选中文字和命中范围失败，保持 `P5` | 修正初始化、对比度与命中区 |
| V3 runtime contract v1.3 | 登录后单次终局装配；亮暖金 selected 文字；底部命中区扩展 `8px`；runtime 版本自报；有效实机截图 | TabText 未居中；交互后正文退回 pfUI 默认安全区，保持 `P5` | 接管文字锚点与所有已知布局事件 |
| V3 runtime contract v1.4 | TabText 中心合同；pfUI Refresh／选择／停靠后按需恢复完整几何；拖动锁后单次恢复；runtime 版本自报；有效缩放实机反馈 | 缩放后逻辑尺寸未变，条件恢复跳过实际重放；点击后才刷新，保持 `P5` | 为 UI Scale 增加一次强制定型 |
| V3 runtime contract v1.5 | `UI_SCALE_CHANGED` force 标志；连续事件合并；延迟单次全几何重放；force 自动清除；缓存场景 smoke；有效实机反馈 | 未覆盖 pfUI owner 局部缩放入口；实机仍需点击一次 Tab，失败并保持 `P5` | 挂接真实 `pfChatLeft.OnMove` 缩放链 |
| V3 runtime contract v1.6 | owner Scale／EffectiveScale 边沿检测；`pfChatLeft.OnMove` 后置单次强制重放；全局无事件兜底；普通移动零几何写入 smoke；完整静态测试与目标目录哈希核验 | `runtime-corrected / P5`，已部署到测试客户端 | `/reload` 后分别测试 pfUI 局部 Scale 与全局 UI Scale，全程不点击 Tab |
