# Chat 核心 V3

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.FRAME`、`CHAT.FRAME.LEFT`、`CHAT.TABS`、`CHAT.INPUT`、
  `CHAT.UNREAD`、`CHAT.TEXT`
- 版本：`CHAT.CORE.V3 / runtime contract v1`
- 子状态：`runtime-exported`
- 项目阶段：`P5`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 当前操作：对已接受 V3 source 进行确定性导出与 Lua 接线；本版本未生图
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
- runtime 几何：书框最小 `440 × 320`；正文 `380 × 236`；Tab
  `92 × 42`；输入 `380 × 25`；未读 texture `16 × 32`、可见标记约
  `14 × 22`。
- 拉伸：书框九宫格；Tab 和输入仅横向三段式；状态切换不改 Parent、Point、
  Width、Height 或点击框。
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

## 审查记录

- 语义／物理：主框、Tab、输入、未读均对应真实 runtime 对象；右框无资产。
- 透视／图层：主框为底层，承托带位于 Tab 后，正文和动态文字在纸面上，
  输入独立覆盖书页下沿。
- 装配：`440 × 320` 无底栏预演保留 `380 × 236` 正文安全区。
- 技术：五张 TGA 均为 RGBA 与 2 的幂；SHA、crop 和 UV 见 runtime manifest。
- 静态测试：Chat smoke、pfUI expedition contract、repository contract 和
  `git diff --check`。
- 尚未发生：Turtle WoW `1.18.1` 实机验证和 `P6-C` 清理。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一门禁 |
|---|---|---|---|
| V3 runtime contract v1 | source／runtime manifests、五张 TGA、Lua 与 tests | `runtime-exported / P5` | Turtle WoW 实机验证 |
