# Chat 核心 V3

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.FRAME`、`CHAT.FRAME.LEFT`、`CHAT.TABS`、`CHAT.INPUT`、
  `CHAT.UNREAD`、`CHAT.TEXT`
- 版本：`CHAT.CORE.V3 / runtime contract v1.21`；输入生产版本
  `CHAT.INPUT.DARK.V1.r3 attempt 4 / runtime-exported`；Tab 替换方向
  `CHAT.TABS.DARK.V2.r1 / repair-prepared / attempt-02-ready`；V1 attempt 3
  已由用户否决
- 子状态：核心 `runtime-exported`；输入 `runtime-exported / P5`；Tab 替换
  `repair-prepared / 1/5 / P3`
- 项目阶段：`P5`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 当前操作：Full V1 固定 P4 source 已按全图比例确定性导出到 `1024²`
  `ChatBookFrameFullV1.tga`，通过九个 slice 接管唯一左框；V3 Tab、承托带和
  未读继续复用。保留 pfUI 配置字体、无描边／阴影、`3px` 行距、压光层退役
  与书本自愈；v1.21 移除 AEUI 的基础 RGB、内嵌八位色、pfUI 输出桥和 ChatMOD
  `ORG_AddMessage` wrapper，客户端／pfUI／ChatMOD 成为经典配色的唯一权威。
  该代码收敛阶段 ImageGen `0` 次，不修改外部 ChatMOD 功能／配置。
  用户随后指出 V3 浅金输入纸带在暖黑书页上像现代进度条；
  `CHAT.INPUT.DARK.V1-SIM` 暖烟草抄写纸条本地几何模拟已于 `2026-08-03`
  获得用户方向确认。稳定输入 Prompt 与完整生产正文现已按确认结果凝结；
  用户又于 `2026-08-03` 明确授权固定 Image 1／2／3、冻结修复边界和最多
  五次实际 ImageGen 调用。attempt 1 已实际生成并完成审查；技术与真实排版
  通过，但材料身份首先失败。attempt 2 移除了缝线、皮革卷和长导线，却仍以
  重复压纹表现中段，并保留连续橙金 focus 上缘；attempt 3 的紧邻 edit 又
  保留同一压纹，并进一步强化连续 focus 上缘，证明连续 Image 4 edit 已被
  错误表面锚定。`.r3` 随后只使用固定 Image 1／2／3 从零 regenerate；
  attempt 4 的薄烟熏 rag-paper 两态、共享 Alpha、色键、真实排版和展示区域
  完整内审通过。用户于 `2026-08-03` 接受精确 `.r3 attempt 4` 进入 `P4`；
  `1536 × 1024 RGBA` 透明归一源已复制到 `assets/source/chat/input-dark-v1/`
  并建立 provenance manifest。自主循环停止，attempt 5 不再消费且不转移。
  本次“继续”随后授权下一未阻塞门禁：确定性 exporter 只裁切两个 canonical
  cell，建立共享 Alpha 的 `1024 × 256` `ChatInputDarkV1.tga`；最终 TGA
  RGBA 像素与 P4 审查逻辑 atlas 完全一致，五场景真实排版与 display-region
  均通过。Lua 只把原三枚 slice 的贴图映射切到新 TGA；真实 EditBox 的文字、
  焦点、光标、IME、历史、频道头、键盘事件和命中几何不变。旧 V3 输入 TGA
  仅作 P6-C 前回退。模拟 ImageGen `0/0`、生产 ImageGen `4/5`、P4→P5 导出
  ImageGen `0`、流程错误 `4`；四个流程错误均无候选图或 provider 生成证据
- `2026-08-04`：用户否决 `CHAT.TABS.DARK.V1.r2 attempt 3` 的综合色观感，首个
  失败门禁为轮廓／物件身份：四态被收敛成等高、等宽、直边、近似网页标签的
  规整条块，深色材质本身不能补回旧 Tab 的手工物件感。该候选因此从
  `exception-candidate` 转为 `candidate-rejected / user-rejected`，不再允许
  接受例外、进入 P4 或作为后续 edit 输入。新建 `CHAT.TABS.DARK.V2`，只把
  旧 V3 的斜梯形皮签、外撇端部、不完全平直缝线、夹页／承托物理关系作为
  轮廓权威，同时保留已确认的深色收敛、无浅色 selected、无连续亮金 shelf、
  `92 × 30px` 外接框和既有命中区。V2 已完成纯本地几何预演；未调用
  ImageGen、未上传、未改 addon。用户已于 `2026-08-04` 精确授权 V2 正文、
  固定 Image 1–4、受限紧邻 Image 5 edit 与最多五次实际调用。attempt 1 已
  生成并完成全量审查：视觉方向与真实排版成立，但五对象均越过 source cell，
  首个失败门禁为 cell／隔离。当前累计 `1/5`，完整 `.r1` 已只针对该门禁准备
  attempt 2 edit；addon 仍未修改。
- 已凝结视觉方向：`CHAT-DARK-SIM-V1 / simulation-confirmed / P2` 的 B 方向
  已由 `CHAT.FRAME.FULL.V1.r1 / runtime-exported / P5` 实现；不再作为并行候选
- 已退回生产批次：`CHAT.FRAME.PAPER.V1 / candidate-rejected / P3`；固定
  `@openai/codex@0.143.0` 子进程按授权实际执行 `1/5`，生成前流程错误 `1`。
  attempt 1 的对象、技术、装配、排版与展示区域虽通过内部审查，但用户于
  `2026-08-02` 明确指出暖黑 donor 与未重绘的金色页边／皮革之间仍像拼接；
  首个失败门禁为材料连续性／整体物件身份，剩余 `4` 次不转移给新合同，
  候选未晋级 source、正式 TGA 或 Lua
- 接受并已导出的源：`CHAT.FRAME.FULL.V1.r1 / runtime-exported / attempt-02 / P5`；改为让固定
  V3 母版只承担结构比例参考，并让 ImageGen 在一次完整 edit 中重绘所有可见
  书体像素。纸面、页叠、皮革、黄铜、接触阴影、磨损和暖光共同生成，不再用
  donor／旧母版 mask 进行视觉拼接；Tab、文字、输入与未读仍是独立 runtime
  对象。本地 `CHAT-FULL-SIM-V1` 已以 ImageGen `0/0` 验证 `440 × 320`
  典型／最大排版及五种展示场景。用户于 `2026-08-02` 明确确认该模拟并授权
  完整生产正文、固定 SHA 的唯一 Image 1、新 `0/5` 预算和单一固定子进程。
  attempt 1 在纸／皮身份区分门禁失败；只针对该门禁的完整 `.r1` 随后由
  commit `c28d6b3` 固定。用户于 `2026-08-02` 明确允许 `.r1` 使用剩余预算并
  额外启动一个固定 `npx @openai/codex@0.143.0` 子进程。attempt 2 已实际生成
  `2/5`：完整书体、暖黑纤维纸、页叠、皮革与黄铜形成连续物件；provider 将
  透明区画成 RGB 棋盘，但只使用本候选自身像素的确定性 Alpha 清理已恢复真
  透明。`2026-08-03` macOS 复核又移除了首版透明审查副本中仅存在于
  `alpha=1..26` 外沿的 `95` 个绿键 RGB 残留；Alpha 与不透明像素均未改变，
  最终纯绿／高绿可见像素为 `0/0`。`440 × 320` 空／最小／15 行／16 行和
  `540 × 420` 扩展五场景均通过。用户于 `2026-08-03` 明确接受
  `CHAT.FRAME.FULL.V1.r1 attempt 2` 进入 `P4`；精确透明候选已复制为 tracked
  source 并建立 provenance manifest。后续 deterministic exporter 已生成并
  接入正式 TGA；剩余 `3` 次 ImageGen 永久停止消费且不转移
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
  - [`ChatBookFrame_Full_V1_r1.png`](../../../../assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png)
  - [`ChatInput_Dark_V1_r3.png`](../../../../assets/source/chat/input-dark-v1/ChatInput_Dark_V1_r3.png)
- source manifest：
  [`ChatV3_SourceManifest_v1.json`](../../../../assets/source/chat/v3/ChatV3_SourceManifest_v1.json)；
  [`ChatBookFrame_Full_V1_SourceManifest_v1.json`](../../../../assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_SourceManifest_v1.json)；
  [`ChatInput_Dark_V1_SourceManifest_v1.json`](../../../../assets/source/chat/input-dark-v1/ChatInput_Dark_V1_SourceManifest_v1.json)
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
- 正文阅读区安静连续；Tab 是皮革索引签，输入是夹入页叠的暖烟草抄写纸条，
  未读是小型蜡封。

### 本批组件级转译

- `CHAT.FRAME` 只导出空九宫格书框并挂载到 `pfChatLeft`。
- `CHAT.TABS` 使用一条承托带和同点击几何的四状态三段式 atlas。
- `CHAT.INPUT` 使用普通／聚焦两行三段式 atlas，焦点不改变 Frame 几何。
- `CHAT.UNREAD` 只覆盖 `ChatFrameNTabFlash` 的显示语义。
- `CHAT.TEXT` 继续由 runtime 绘制；频道签可使用霞鹜文楷，正文恢复 pfUI
  配置字体且不使用描边、文字阴影或外发光；基础消息类型与已审计内嵌颜色
  使用同一低饱和深色语义墨色板，保留职业／品质／链接等色相身份；书页不
  增加连续压光或半透明面板。

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
- runtime 几何：书框最小 `440 × 320`；正文 `380 × 248`，受管窗口使用
  `12px` 用户字号基线与 `3px` `SetSpacing` 形成约 `15px` 行高和约 16 行
  中文；正文安全区不增加覆盖层；四枚 Tab 基准 `92 × 30`、间距 `3px`、
  顶部偏移 `2px`，Tab panel 高 `32px`，
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
- 文字颜色：基础消息 RGB 只在与当前 `ChatTypeInfo` 精确匹配时按 Vanilla
  语义角色映射；内嵌颜色优先替换审计白名单中的八位 `|cAARRGGBB` 前缀，
  未知颜色只有在代表纸色上低于 `4.8:1` 时才等比例压低 RGB。相同转换同时
  挂在 pfUI `HookAddMessage` 解析出口与 ChatMOD `ORG_AddMessage` 最终出口，
  以覆盖两种加载顺序；足够深的未知色、`|H...|h` 链接载荷、消息参数和 Alpha
  原样转发；当前 Parent 为左书的全部 Frame 均受管，包括被 pfUI 启发式标为
  `pfCombatLog` 的 Frame，书外 Frame 排除。小队与团队必须分色；九职业目标
  必须保持各自 Vanilla 色相，不得为了任意距离门禁重新分配色域。
- 外部兼容：ChatMOD 1.1 的时间戳、彩色玩家名、等级难度、URL、自身高亮、
  配置与 SavedVariables 保持原有所有权；AEUI 不直接调用或改写 ChatMOD。
- 回退：禁用 AEUI Chat 时保留 pfUI 行为；legacy TGA 在 P6-C 前保留。

## 暗色羊皮纸生成前模拟：`CHAT-DARK-SIM-V1`

### 候选元数据与权威边界

- 组件范围：`CHAT.FRAME`、`CHAT.TABS` 与 `CHAT.TEXT` 的可见综合色重关系；
  不新增逻辑对象、状态、Frame、Tab、输入条或消息类型。
- 子状态：`simulation-confirmed`；用户方向结论 `B confirmed`。
- 项目阶段：候选方向 `P2`；现行 `CHAT.CORE.V3` runtime 仍为 `P5`。
- 操作：`simulate`；方式：`deterministic-local-geometry`。
- 固定正式执行器声明：`imagegen-0-143-0`／`@openai/codex@0.143.0`；本次没有
  启动固定执行器，ImageGen `0/0`，没有外部上传，正式生图预算尚未开启。
- 锁定视觉基准只读且未作为像素输入：
  - [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)，
    SHA-256 `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`
    — 只承担香草 HUD 尺度、战地旧书身份与邻接界面综合色感；
  - [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)，
    SHA-256 `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`
    — 只承担手绘材料厚度与页／皮革／黄铜层级，不继承规则建筑、龙饰或亮纸色。
- Prompt provenance 仍为 [`ART_BASELINE.md`](../ART_BASELINE.md)、
  [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md) 与
  [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。此次确认只进入生产草案，
  在 source 候选被接受前不反向修改这些稳定条款。
- 冲突审计：稳定基线和已接受 source 要求暖赭连续纸面；用户最新方向要求把
  阅读纸面压到接近黑色，以恢复原版频道／职业颜色识别。裁决为先建立独立的
  暖黑烟熏纸候选，不把它伪称为现行基线，也不通过透明黑板覆盖亮纸；若用户
  接受，正式正文必须把它转译为仍可识别的深色纸纤维、毛边页叠和旧皮革关系，
  不能退化成现代半透明黑聊天板。

### 模拟合同

- 版本：`CHAT-DARK-SIM-V1`。
- 目标场景：一张 `1000 × 420` 对照画布中的两个真实聊天实例；A、B 每个都
  严格为 `440 × 320 UI px`，不是固定容量画布冒充 provider Frame。
- 相同运行时几何：四枚 `92 × 30px` Tab、`3px` 间距、共同顶部布局；正文
  安全区 `x=30..410`、`y=32..280`，即 `380 × 248px`。
- 相同排版：12px 中文正文、15px 行高（含 `3px` spacing）、13 条代表消息
  形成 15 条可见行，容量上限 16 行，未截断。内容同时覆盖世界、团队、小队、
  公会、密语、系统、说话、警告、表情、九职业中的代表玩家、物品品质与
  DPSMate 正／负报告色。
- A：代表当前接受纸色 `#CDA155` 和 v1.18 深墨映射；B：暖黑烟熏纸
  `#18120D`、深色页叠／旧皮革／氧化黄铜边，以及接近 Vanilla 的频道和九
  职业识别色。B 的萨满蓝为可读性轻抬后的 `#1684ED`，不是陌生色域。
- 当前 accepted/runtime 邻接 UI 只以几何 primitives 表达：同一旧书轮廓、
  多层页边、连续皮革承托带和四枚索引签；未读取或复制现有 source／TGA 像素。
- 用户需要确认：B 的近黑色纸面是否仍首先像旧书；综合色重是否合适；恢复
  原版职业／频道颜色后是否确实能一眼扫读；是否存在过亮、霓虹或现代黑面板感。
- 刻意简化且非权威：纸纤维、烟熏斑驳、毛边笔触、Alpha、接缝、九宫格切片、
  精确 Tab 状态、字体栅格和最终逐色数值。画布标题、对照说明和抽象世界背景
  也不属于 runtime。
- 禁止用途：模拟 PNG 不得进入 `assets/source/` 或 `addon/`，不得裁切、切片、
  晋级、复用像素，也不得作为正式 ImageGen edit／reference 输入。

### 本地模拟规格、执行与展示区域证据

- specification：
  [`tools/specs/chat_dark_parchment_simulation_v1.json`](../../../../tools/specs/chat_dark_parchment_simulation_v1.json)，
  SHA-256 `122cf98dfedb21810035a26a9efce8e9bbd213541366d5a51e6e842dfedaaefd`。
- renderer：
  [`tools/render_chat_dark_parchment_simulation_v1.py`](../../../../tools/render_chat_dark_parchment_simulation_v1.py)，
  SHA-256 `88f78d340310c80090231ee3ec7d538c5e44645f6eb0d045edcdf931b3ec9b09`。
- 命令：
  `python tools/render_chat_dark_parchment_simulation_v1.py tools/specs/chat_dark_parchment_simulation_v1.json`。
- Python：`D:\Softwares\miniconda3\python.exe`，`3.13.5`。
- 输出：`generated/chat/core/simulation/CHAT-DARK-SIM-V1/chat_dark_parchment_ab_v1.png`，
  `1000 × 420 RGBA`，SHA-256
  `4a8d78c026147a87b5a0a3bde97cdd142344a7441d12ff84957184062990be8f`。
- 指标：`generated/chat/core/simulation/CHAT-DARK-SIM-V1/chat_dark_parchment_ab_v1.metrics.json`，
  SHA-256 `2a841508f610522b7b391759dba59e6633ee7d8bb703645627b2a9cb68a5319d`；
  A／B 均为 15 行且 `truncated=0`。
- 展示区域合同：
  [`tools/specs/chat_dark_parchment_display_region_v1.json`](../../../../tools/specs/chat_dark_parchment_display_region_v1.json)，
  SHA-256 `675d73fe5557da86befde11100eaa613eb195c826b4150d1d6cb9f190650c8d3`。
- 展示区域报告：`generated/chat/core/simulation/CHAT-DARK-SIM-V1/display-region-report.json`，
  SHA-256 `af610b76753f5368232d78bfef8d5acc843e5069120165e056dcae9375a1043e`；
  A／B 两个 `440 × 320` 场景、四枚 Tab 和正文安全区全部 `pass`，首个失败码
  为 `null`。
- ImageGen：`0/0`；上传范围：无；三个 `generated/` 输出均由 `.gitignore`
  排除。

| 本地错误 | 版本 | 可观察错误 | 针对性修复 | 结论 |
|---:|---|---|---|---|
| SE1 | `CHAT-DARK-SIM-V1` | 初始展示区域合同保留了无公式字段的 `provider_layout`，validator 要求 `panel_height` | 删除本组件不适用的 provider 高度公式对象，再以同一几何合同验证 | `pass`；不涉及 ImageGen |

### 内部审查与用户方向门禁

- 真实排版：两个实例均严格使用 `440 × 320`、`380 × 248`、12px／15px 与
  现实高密度中文消息；没有扩大 Frame、减少消息或加描边来制造可读性。
- 语义／物理：B 保留页叠、毛边轮廓、皮革索引签和黄铜边的旧书层级，核心
  阅读面为不透明暖黑纸，不是用半透明黑矩形覆盖亮纸。
- 综合色重：A 的基础频道／职业集中在约 `4.50:1`；B 的最低代表色是萨满蓝
  `4.913:1`，战士 `7.434:1`、术士 `5.566:1`、警告 `5.357:1`，其他展示色
  更高。数值只证明没有明显失败，不能替代用户对扫读和沉浸感的判断。
- 文字：无 `OUTLINE`、无阴影、无逐行底色；A／B 的消息、几何和字体完全
  相同，因此可直接判断背景极性与语义色的关系。
- 刻意省略：第一次内审发现规则长横纹会被误读为消息分隔线，最终模拟完全
  省略微纤维；正式资产必须从锁定美术 DNA 重新表达不规则低频纸纹，不能从
  本模拟补回规则线。
- 内部结论：`displayable / simulation-reviewed`。
- 静态回归：renderer `py_compile`、display-region validator、
  `asset_workflow_skill_test.py`、`repository_contract_test.py`、Chat Lua smoke、
  pfUI scoped ownership contract 与 `git diff --check` 均通过。
- 用户结论：`2026-08-02 / B confirmed`。确认的可见条款是：阅读面为
  `#18120D` 附近的不透明暖黑旧纸；仍首先读作厚重战地旧书；保留当前
  `440 × 320` 书框、`380 × 248` 正文安全区、Tab／输入条几何与
  Vanilla 职业／频道色识别方向。模拟像素仍不被接受。
- 确认失效条件：若后续要改为亮纸、现代黑面板、重新生成整本书、改变
  九宫格／Tab／正文几何或改写材料层级，必须回到新的本地模拟门禁。
- 当前结论：用户随后要求重新生成整本书，已触发上述失效条件。B 的暖黑纸面
  极性、尺寸和独立对象关系继续作为约束，但本次确认不能授权新的整体书框
  生产；新门禁见 `CHAT.FRAME.FULL.V1`。当前不修改 runtime。

## 暖黑纸面生产草案：`CHAT.FRAME.PAPER.V1`

### 产品与几何合同

- 子状态：`prompt-authorized`；项目阶段 `P3`；操作 `generate`；正式授权
  `2026-08-02 confirmed`。
- 生成对象只有一个：一张边到边、不透明的暖黑旧纸材质 donor。它不是
  书、UI 面板、完整书框、atlas 或 runtime 贴图，也不承担任何几何或 Alpha。
- 接受母版固定为
  [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)，
  `1608 × 978 RGBA`，SHA-256
  `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`。
- 母版的画布、Alpha 轮廓、皮革、缝线、页叠深度、黄铜、现有九宫格切线、
  `440 × 320` runtime 装配、四枚 Tab／输入条的独立 atlas 全部冻结。不让
  ImageGen 重画整本书，不修改点击区、UV、安全区或消息容量。
- donor 由确定性工具居中 LANCZOS 适配到 `1608 × 978`，只在固定纸面
  mask 内替换表面像素；使用原母版亮度保留页边、折痕、接触暗部和页叠
  体积。mask 外 RGB 字节不变，整张 Alpha 字节不变。
- 固定装配规格：
  [`tools/specs/chat_dark_paper_assembly_v1.json`](../../../../tools/specs/chat_dark_paper_assembly_v1.json)，
  SHA-256 `d8158d0de876db4d635796529b2e3c5339411db9ea4f45f5e3c925fae33a6e44`。
- 固定装配工具：
  [`tools/build_chat_dark_paper_v1.py`](../../../../tools/build_chat_dark_paper_v1.py)，
  SHA-256 `c098bca607b054e857ad66bf2c47ba80c59af2ee804421c475a7a40c72230e4b`。
- 本地 mask 审查证据：
  `generated/chat/core/CHAT.FRAME.PAPER.V1/assembly/ChatBookPaperMaskV1.overlay.png`，
  SHA-256 `464b12de1a4353287b13faee6e047239b3d445fcfc5bebade8bea6bbe3dd9701`；
  只覆盖纸面与页叠，顶部缝线、外圈皮革、透明轮廓和右下黄铜全部排除。
- 本地装配合同报告：
  `generated/chat/core/CHAT.FRAME.PAPER.V1/local-contract-test/ChatBookPaperAssemblyV1.report.json`，
  SHA-256 `57ebbf1656ea5d8b0ca1698209bac4de10f700438faab01ec59cfbf870539e71`；
  用固定母版作为本地替身 donor 验证装配，输出 `1608 × 978 RGBA`、Alpha
  差异像素 `0`、mask 外 RGB 差异像素 `0`。该候选只是技术测试，不是美术产物。

### 固定外部输入与上传边界

- 唯一上传输入拟为 Image 1：上述已接受 V3 母版及其固定 SHA。它只作为
  手绘笔触尺度、纸纤维颗粒、烟熏／磨损节奏和微观暖光的低权重材质参考。
- 明确忽略 Image 1 的外轮廓、画布几何、Alpha、页叠、缝线、皮革、黄铜、布局和
  亮金纸色；这些全由确定性装配所有。
- 两张 locked 图继续是美术权威，但本执行不上传；只通过下方自包含提示词
  继承其已写入基线的稳定条款。
- `CHAT-DARK-SIM-V1` 的 PNG、指标和任何裁片禁止上传或作为生产输入。
- 原始结果只能写入
  `generated/chat/core/CHAT.FRAME.PAPER.V1/attempt-XX/`；通过对象身份、材料与
  非对称纹理门禁前，不得进入 `assets/source/` 或 `addon/`。

### 自包含生产提示词（授权后原样传入）

```text
Create exactly one edge-to-edge, front-facing material surface for the reading paper of a 2004-era hand-painted fantasy MMORPG battlefield chat book. This output is a surface donor only. It is not a complete UI, not a book, not a frame, not a panel, and not an atlas. The output contains one opaque rectangular swatch of worn parchment material occupying the entire canvas. Do not include a border, page edge, binding, leather, brass, tabs, icons, text, symbols, controls, objects, cutouts, transparent margins, presentation board, or surrounding scene.

Image 1 is a lower-authority material-scale reference from the accepted current chat-book master. Inherit only its hand-painted brush scale, subtle paper fibers, restrained smoky staining, irregular wear rhythm, low-resolution vanilla-era bitmap character, and warm upper-left micro-lighting. Explicitly ignore and do not reproduce Image 1's outer silhouette, geometry, alpha boundary, stacked page edges, stitches, leather, brass corner, layout, or light golden parchment color. Geometry and alpha are owned by deterministic runtime assembly, not by this image.

The material is soot-darkened warm-black parchment, never black leather, metal, stone, wood, cloth, a modern black card, or a translucent dark overlay. Center the base color visually near #18120D. Use restrained fiber-catching variation near #392A1D and the deepest pores or smoke near #0D0906. Preserve a warm brown undertone. Avoid neutral gray, blue-black, pure #000000, or a sepia-gold reading center.

The entire canvas must still read as fibrous paper at normal game scale: subtle irregular fibers, low-frequency smoke and age variation, sparse restrained scuffs, slightly uneven hand-painted marks, and organic nonrepeating tonal drift. Keep the field continuous and quiet enough for dense 12px multicolored chat text with 3px line spacing. Do not create a center glow, vignette, rectangular gradient band, horizontal ruled lines, repeated pattern, tile seam, high-frequency speckle, large stains behind text, scratches, holes, burned edges, blood, runes, ornament, bright highlights, or readable marks.

Use a flat orthographic front view and even edge-to-edge coverage. Do not add perspective, folds, curled corners, cast shadows, thickness, isolated-object silhouette, or blank margin. Micro-highlights may imply warm light from the upper left only at fiber scale; they must not become a panel-wide lighting gradient. Output a clean landscape 1536 x 1024 opaque RGB or RGBA image with no transparency and no chroma-key background.

Final self-check: exactly one full-canvas warm-black parchment surface; paper material is unmistakable; no UI frame or object appears; no regular lines or seams appear; the center stays dark, quiet, and continuous; nothing is baked that could compete with runtime text.
```

### 完整性审计与有界修复包络

- 身份、对象数、输入职责、画布／视角、材料、主色／暗色／高光、光照、纹理频率、
  正文安静区、透明度、禁止烘焙内容、禁止对象和最终自检全部显式；无未声明
  尺寸、动态状态或运行时文字。完整性审计 `pass`。
- 同一生产正文最多五次**实际** ImageGen 生成，当前 `0/5`；工具或进程错误
  单独记录，不占生成次数。每次只处理第一个可观察失败门禁。
- 允许的修复：只可调整纸纤维、烟熏、磨损、暗部或亮部的描述强度；若上一张
  已正确是单一纸面 donor 且没有禁止对象，可在同循环作为 edit 输入。
- 不可变的约束：单一 donor、Image 1 唯一外部输入、暖黑纸材质、色相极性、
  不透明全画布、无 UI／无书框／无边缘／无规则线，以及确定性几何所有权。
- 若需新增或更换外部图、改变对象身份／数量、纸色极性、材料层级、输出职责、
  画布要求或现有几何，立即停止并请求新授权。
- 每个 raw 通过对象范围、结构、材料、一致性、技术与反模式审查后，才可装入固定
  mask；装配候选还必须验证 `1608 × 978 RGBA`、Alpha 零差异、mask 外 RGB
  零差异，并用现有 exporter 生成真实 `440 × 320` 九宫格预演。

### 精确授权记录

- 用户授权日期：`2026-08-02`。
- 授权版本：`CHAT.FRAME.PAPER.V1`。
- 唯一允许上传图：固定 SHA-256 的 V3 母版，作为 Image 1。
- 预算：同一生产正文最多 `5` 次实际 ImageGen 生成／编辑；当前 `0/5`。
- 用户原文：

> 明确授权 `CHAT.FRAME.PAPER.V1`，允许上传固定 SHA-256
> `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`
> 的 `ChatBookFrame_Master_v3.png` 作为 Image 1；同一生产正文最多 5 次实际
> ImageGen 调用。

- E1 后的补充执行机制授权：`2026-08-02 confirmed`。用户原文：

> 明确允许 imagegen-0-143-0 通过 npx 启动 @openai/codex@0.143.0 子进程；
> 允许该子进程上传此前授权的唯一 Image 1，并仅在子进程内调用其自带
> image_gen。不得调用当前会话内建 imagegen，也不得再启动其他 codex/npx 子进程。

### `CHAT.FRAME.PAPER.V1` 自主修复循环

- 固定执行器：`imagegen-0-143-0` / `@openai/codex@0.143.0`。
- 不可变修复边界：单一不透明暖黑旧纸 donor；Image 1 唯一外部输入；
  不生成书、框、边缘、Tab、文字、图标或控件；当前画布、Alpha、九宫格、
  `440 × 320` runtime 几何和 Tab／Input atlas 不变。
- 允许的自主修复：仅修改纸纤维、烟熏、磨损、暗部或亮部的描述强度；
  候选已正确为单一 donor 且无禁止对象时，才可作为同循环 edit 输入。
- 必须重新授权：新增／替换外部图、改变对象或状态数、暖黑纸极性、材料层级、
  画布、几何、Alpha 或 runtime 职责。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `CHAT.FRAME.PAPER.V1` / `aa4ba91` | generate | session `019fc0b0-167a-7ad1-9489-1a07d1f7d066`／cache result `ig_0da97b4f5e55322f016a6ec4b86a80819181fcddbd6b40c4e5.png` | `generated/chat/core/CHAT.FRAME.PAPER.V1/attempt-01/ChatBookPaper_WarmBlack_Surface_1536x1024.raw.png`／`5e45c11b1a8a902e27e1912eac6488bee3f945cd6445bd962a4efdf2fe5c233c` | 无；对象、材料、技术、装配、排版与展示区域全部通过 | 保留完整 donor；停止自主循环并提交用户复审，不消费剩余四次 | `candidate-reviewed / P3`；`1/5` |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `CHAT.FRAME.PAPER.V1` / `6c34ad1` | 未创建 | sandbox approval reviewer 在 PowerShell／`npx` 启动前拒绝；无子进程、无上传、无图片、无 provider result | 用户已补充授权固定 Skill 要求的 `npx @openai/codex@0.143.0` 子进程机制；以同一已提交正文重试 | 不占生图额度；已解除流程授权阻塞，仍为 `0/5` |

### `CHAT.FRAME.PAPER.V1` attempt 1 执行记录

- 日期：`2026-08-02`。
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`；会话
  `019fc0b0-167a-7ad1-9489-1a07d1f7d066`。当前会话未调用内建
  imagegen；已授权子进程没有再启动其他 Codex／npx 子进程。
- 唯一实际输入：
  `D:\Git\azeroth-expedition-ui-overhaul\assets\source\chat\v3\ChatBookFrame_Master_v3.png`，
  SHA-256
  `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`；
  只承担冻结正文声明的低权重材料尺度参考。
- 子进程完整显示了已授权生产正文，没有截断或改写；未报告 revised prompt。
- provider 原始结果：
  `C:\Users\西奥\.codex\generated_images\019fc0b0-167a-7ad1-9489-1a07d1f7d066\ig_0da97b4f5e55322f016a6ec4b86a80819181fcddbd6b40c4e5.png`；
  未经修图复制到本批 ignored raw 路径。
- raw：`1536 × 1024 RGB`，全画布 `1,572,864` 像素均不透明，partial／
  transparent／精确绿底／启发式绿色残留均为 `0`；SHA-256
  `5e45c11b1a8a902e27e1912eac6488bee3f945cd6445bd962a4efdf2fe5c233c`。
- 实际 ImageGen：`1/5`；流程错误：`1`；循环终态：
  `candidate-reviewed`。完整内审通过后已立即停止，未消费剩余四次。

### `CHAT.FRAME.PAPER.V1` attempt 1 审查记录

- 语义／物理：raw 恰为一个边到边、正视、无边框的不透明暖黑旧纸表面；无
  书框、书页外轮廓、皮革件、黄铜件、Tab、文字、符号或控件。无第二对象。
- 透视／图层：平面正投影，无厚度、卷角、孤立投影、透明边或展示场景；低频
  烟熏与纤维连续覆盖全画布，没有中间压光矩形、规则线或平铺接缝。
- 美术一致性：综合色接近 `#18120D` 方向，保留暖棕底色、哑光纤维和克制的
  非镜像磨损；没有中性灰／蓝黑、纯黑、金黄中心或现代黑色面板。raw 单看已
  接近极深烟熏材质，但表面由细纤维而非皮革粒面构成；装回原页叠后，旧书纸面
  身份仍成立。该边界作为用户复审重点，不把内部判断冒充最终接受。
- 对象／状态合同：本批只有一个 donor，无交互状态；动态文字、频道色、职业色、
  四枚 Tab 和输入条仍由现有 runtime／独立 atlas 所有，没有烘焙进候选。
- 装配／尺寸：固定工具把 donor 只装入既定 paper mask，候选为
  `1608 × 978 RGBA`，SHA-256
  `c976bfc0acbea12f7e07a12e59d0949fbad50485b31ef57599dff8312293a20a`；
  Alpha 差异像素 `0`，mask 外 RGB 差异像素 `0`。报告：
  `generated/chat/core/CHAT.FRAME.PAPER.V1/attempt-01/assembly/ChatBookPaperAssemblyV1.report.json`，
  SHA-256
  `f2ef886f66837e8c91e47f92a94e92d80e32e4a3f37eaee9210f158612771dc1`。
- 真实排版：新增确定性审查器
  [`render_chat_dark_paper_candidate_v1.py`](../../../../tools/render_chat_dark_paper_candidate_v1.py)
  与
  [`chat_dark_paper_candidate_preview_v1.json`](../../../../tools/specs/chat_dark_paper_candidate_preview_v1.json)，
  复用正式 exporter 的九宫格和已接受 V3 Tab 像素，在两个真实
  `440 × 320` Frame 中分别装入综合频道典型 `15` 行与团队频道最大 `16` 行；
  两者均无截断，最后基线分别为 `252`／`267`，低于正文底界 `280`。预演：
  `generated/chat/core/CHAT.FRAME.PAPER.V1/attempt-01/review/ChatDarkPaper_candidate_real_layout_v1.png`，
  SHA-256
  `cc6f7ab61cc3a31b3c9a84e1cd1370bfde9651da51685845763c65fc3eb00906`；
  metrics SHA-256
  `0074a515c9a4fe3cfb68364ef00a59e62b3b7f20d917fe96ce8171faa0e2476f`。
  正文只是在候选上方绘制的确定性动态示例；世界背景为非权威几何占位，正文
  字体为中文可用的代表性 fallback，正式 runtime 仍保留 pfUI 配置字体。
- 实际展示区域：合同
  [`chat_dark_paper_candidate_display_region_v1.json`](../../../../tools/specs/chat_dark_paper_candidate_display_region_v1.json)
  覆盖 empty、minimum-one-line、typical-fifteen-lines 与
  maximum-sixteen-lines；`440 × 320` frame coverage、Tab 区和
  `380 × 248` 正文区全部 `pass`，violation `0`、first failure `null`。报告：
  `generated/chat/core/CHAT.FRAME.PAPER.V1/attempt-01/review/display-region-report.json`，
  SHA-256
  `85f5f66d791a94e98e228401cdc8b54df53c4e5c7a7c1bd4de7332f448886210`。
- runtime 等价审查：只写入 ignored review 目录；候选书框 TGA SHA-256
  `9e7400125feb15506af3d44aa72332891a9f7d2158383d542b96132dc7bc695a`，
  其余已接受 atlas 的 review 导出保持原源。没有修改 tracked source、正式
  TGA、Lua、pfUI／ChatMOD 配置或 SavedVariables。
- 内部结论：`candidate-reviewed / P3`。对象身份、材料、像素、装配、真实排版、
  展示区域和反模式门禁通过；停止自主循环。
- 用户结论与日期：`pending`。
- 下一门禁：用户对 attempt 1 原始 donor 与 100% 布局预演明确接受或退回。
  若接受，只晋级 P4 source／manifest；若退回，因为补充授权禁止再启动另一个
  Codex／npx 子进程，先停止并请求新的执行机制授权，绝不改用当前会话内建
  imagegen。

### `CHAT.FRAME.PAPER.V1` 用户复审摘要

- 批次／版本：`CHAT.FRAME.PAPER.V1` attempt 1。
- 用户结论与日期：`2026-08-02 / rejected`。用户观察到中心暖黑纸面仍像贴到
  原有亮金页叠和旧皮革中的独立块，要求整体生成并且不再使用蒙层拼接。
- 当前状态：`candidate-rejected / P3`；实际生成 `1/5`，剩余 `4` 次终止且不
  转移到新合同。
- 已通过：单一暖黑旧纸对象、无禁止烘焙内容、固定 mask 装配、Alpha／mask 外
  字节不变、现有 `440 × 320` 布局、典型／最大消息容量与四场景展示区域。
- 首个失败门禁：材料连续性／整体物件身份。纸面极性虽然正确，但旧母版金色
  页边、接触亮边和暖黑 donor 的边界仍可被读成后贴的矩形表面。
- 保留结论：`#18120D` 附近的暖黑阅读面、现有 `440 × 320`／`380 × 248`
  布局、独立 Tab／Input／Unread、Vanilla 识别色方向。
- 必须改变：纸面、页叠、皮革、黄铜、接触阴影和磨损必须作为一个完整书体
  一次生成；不得再把旧母版与新 donor 通过 mask 混合。
- 尚未发生：正式 runtime 切片、Lua／pfUI 接入、Turtle WoW 实机验证。

## 整本书框生成前模拟与生产草案：`CHAT.FRAME.FULL.V1`

### 产品、对象与几何合同

- 组件：`CHAT.FRAME`；接受版本：`CHAT.FRAME.FULL.V1.r1 attempt 2`；当前子状态
  `source-accepted`；项目阶段 `P4`。历史生产操作为 `edit`；本次接受操作不调用
  ImageGen。
- 正式生成对象只有一个：不含任何动态内容的完整横向战地旧书聊天背景。
  纸面、页叠、皮革封套、少量氧化黄铜修补、接触阴影、磨损和左上暖光必须
  在同一张结果中形成连续物理关系，不能生成 donor、覆盖层或第二块中心面板。
- 运行时继续使用一个 `pfUI.chat.left / pfChatLeft`，基准 Frame
  `440 × 320`；正文安全区固定 `x=30..410`、`y=32..280`，即
  `380 × 248`；书框九宫格 cap 仍为左／上／右／下 `30/28/30/28px`。
- `CHAT.TABS`、承托带、TabText、`CHAT.INPUT`、`CHAT.UNREAD`、消息文字、
  滚动／复制／语言／弹出菜单和所有状态仍由独立 runtime 对象拥有，禁止烘焙
  进书框。顶部只要提供能自然承接现有独立 Tab 的安静书脊／页边。
- 保留 `440 × 320` 与 `540 × 420`；九宫格中段必须低频、连续且可拉伸，
  独特裂口、铆钉、缝线终点和金属修补只能放在四角及固定 cap 内。
- 当前 V3 runtime source、正式 TGA 与 Lua 均保持不变；新 source 进入 `P4`
  不等于切换 runtime。

### 美术继承、输入角色与冲突裁决

- 最高权威仍是两张 Chat 锁定图、Chat 主／子模块 Prompt 与全局 Prompt。
  继承：2004 年代手绘低分辨率位图、厚重且反复修补的战地旧书、不规则页缘、
  深胡桃皮革、低饱和氧化黄铜、左上暖光、非镜像磨损和安静连续阅读面。
- 阅读纸面目标为 `#18120D` 附近的不透明暖黑烟熏纸；页叠从近黑褐、烟草褐
  逐层过渡到纸面，外圈皮革更平滑、更深且有折痕。两者必须靠纤维、厚度、
  接触暗部和边缘磨损区分，不能靠一圈亮金描边切开。
- 拟上传的唯一 Image 1 为现有接受母版
  [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)，
  `1608 × 978 RGBA`，SHA-256
  `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`。
  本版本把它从“低权重材质参考”改为“高权重结构／比例／拓扑参考”：保留横向
  外接比例、完整物件尺度、边框厚度关系、空白中心和不规则总体轮廓；不保留
  亮金纸色、旧像素、旧接缝光照、既有纸／皮边界、Alpha 毛刺或局部装饰细节。
- Image 1 只为新结果提供结构，不作为旧像素底图；正式结果的全部可见书体
  像素都必须由同一次 edit 重新生成。禁止旧母版＋新结果 mask、donor paste、
  multiply overlay、局部换纸或任何视觉合成。
- 两张 locked 图不上传；其稳定视觉条款已经自包含写入下方生产正文。
  `CHAT-DARK-SIM-V1`、`CHAT-FULL-SIM-V1` 及旧 PAPER attempt 的任何 PNG
  均禁止上传或作为生产输入。
- 整体生成与“不使用蒙层”不禁止候选被接受后的纯确定性工程导出：允许对
  单一生成结果做整图画布归一、无旧像素参与的透明边缘清理、等比缩放、裁切、
  九宫格切片和 TGA 转换；不得混入旧母版或其他候选的表面像素。

### 新本地模拟与展示区域证据

- 模拟版本：`CHAT-FULL-SIM-V1`。renderer 只使用确定性几何 primitives，
  不读取 locked、source、runtime 或旧候选像素；书体几何表示“全部材料连续
  生成”，Tab 与文字只表示现有独立 runtime 邻接对象。
- specification：
  [`tools/specs/chat_full_frame_simulation_v1.json`](../../../../tools/specs/chat_full_frame_simulation_v1.json)，
  SHA-256 `c7c864df57b84a23332e320cfb58f0b1cf3c1789ad7bd56956d376f8d1cebd8c`。
- renderer：
  [`tools/render_chat_full_frame_simulation_v1.py`](../../../../tools/render_chat_full_frame_simulation_v1.py)，
  SHA-256 `31700cae314666689c75b3d0fb94a996b7c109ea894d0e8afaabc398c9f97671`。
- 输出：
  `generated/chat/core/simulation/CHAT-FULL-SIM-V1/chat_full_frame_v1.png`，
  `1000 × 390 RGBA`，SHA-256
  `5d73b5afc11ec128c4938967206301f288b3f734cb5c2dc85e146b38c1b8487c`；
  左侧为 15 行综合，右侧为 16 行团队，均严格使用 `440 × 320`。
- 指标：
  `generated/chat/core/simulation/CHAT-FULL-SIM-V1/chat_full_frame_v1.metrics.json`，
  SHA-256 `82458bd324eabbb9bd4f3723534818bebb060dcf5a91138873f4b0b6df374caa`；
  15／16 行末基线分别为 `252/267`，正文底边为 `280`。
- 展示区域合同：
  [`tools/specs/chat_full_frame_display_region_v1.json`](../../../../tools/specs/chat_full_frame_display_region_v1.json)，
  SHA-256 `6fad0528dcff73022e6b8770d033c9704f7569ff715cc298d14bb69af38d9a0f`。
- 展示区域报告：
  `generated/chat/core/simulation/CHAT-FULL-SIM-V1/display-region-report.json`，
  SHA-256 `f7bbc7f1eab5a0dc086addca79329335a15db7459886057810e167a91c05abea`；
  empty、minimum、15 行 typical、16 行 maximum、`540 × 420` expanded 五个
  场景全部 `pass`，violations `0`，first failure `null`。
- 内部结论：`displayable / simulation-reviewed`。模拟只确认对象数量、材料
  层级、综合色重、实际尺寸、消息容量和独立对象关系；最终笔触、毛边、Alpha、
  接缝与微纹理仍由正式候选审查，模拟像素永不晋级。
- 静态回归：renderer `py_compile` 与确定性复渲染 SHA、两个 JSON 解析、
  display-region validator、`asset_workflow_skill_test.py`、
  `repository_contract_test.py`、Chat Lua smoke、pfUI scoped ownership contract
  和目标文件 `git diff --check` 全部通过。
- ImageGen `0/0`；外部上传 `0`；未启动 Codex／npx 子进程。
- 用户方向结论：`2026-08-02 / CHAT-FULL-SIM-V1 confirmed`。确认条款为整本
  书共同变暗、纸面／页叠／皮革作为连续物件生成、保留 `440 × 320` 容量与
  独立 Tab 关系；模拟的规整几何、微纹理、Alpha 和笔触仍不属于接受像素。
- 生产已执行至 attempt 2 并通过内部候选门禁；用户于 `2026-08-03` 明确接受
  该精确候选进入 `P4`。下一门禁是定义并验证确定性 runtime 导出合同；在最终
  atlas／adapter 再次通过展示区域检查前，不得导出正式 TGA、修改 Lua 或标记
  `P5`。

### 完整生产正文（已授权，必须原样执行）

```text
Create one production-ready bitmap asset by editing Image 1 as a whole.

OBJECT AND RESPONSIBILITY
Redraw Image 1 into one complete, coherent, empty fantasy chat-book frame for a
Vanilla-era MMORPG UI. This is exactly one landscape old book object in exactly
one static state. Regenerate every visible book pixel together in the same edit:
the reading paper, stacked page edges, leather cover, restrained oxidized-brass
repairs, contact shadows, wear, stains, and warm lighting. Do not generate a
paper donor, center overlay, insert, patch, or second panel. Do not preserve or
composite any of Image 1's old surface pixels.

IMAGE 1 ROLE
Use Image 1 as a high-weight structural, proportional, and topology reference
only. Preserve its landscape bounding proportions, compact border-to-center
ratio, empty central reading-field topology, complete-object scale, and gently
irregular overall silhouette. Do not preserve its bright golden paper color,
old pixel texture, old seam lighting, old paper/leather boundary, alpha defects,
or local ornaments. The art direction below overrides those visible qualities.

ART DIRECTION
The result must read first as a thick battlefield field book that has been
carried, opened, stained, repaired, and reused for years. Use a 2004-era
hand-painted low-resolution fantasy UI bitmap language: deliberately simplified
forms, broad readable value groups, restrained brush texture, mild pixel-era
edge softness, no photographic detail, and no clean vector symmetry. Make the
book visibly irregular and slightly untidy, with non-mirrored page wear and
repairs. Use warm upper-left illumination with quiet lower-right falloff.

The material hierarchy is: matte fibrous paper first, deep walnut-brown worn
leather second, small muted oxidized-brass repairs third. The central reading
paper is opaque near-black warm soot parchment, visually centered around
#18120D, with subtle warm-brown fibers and sparse irregular smoke staining. It
must remain visibly paper, not black leather, painted wood, a modern black panel,
or a translucent glass overlay. Transition outward through several physical
layers of near-black umber and tobacco-brown page edges. Generate their fibers,
deckled edges, thickness, contact occlusion, and wear together with the paper.
Do not surround the dark paper with a bright gold rim or an abrupt rectangular
seam. The smoother, creased deep-walnut leather should wrap and support the page
stack. Oxidized brass stays low-saturation and sparse, limited to believable
edge or corner repairs.

LAYOUT AND RUNTIME-SAFE REGIONS
Keep the complete book fully visible in a flat, straight-on orthographic UI view.
The output is an empty frame only. Reserve a quiet uninterrupted central reading
field covering approximately x=7%..93% and y=10%..87.5% of the visible book
bounds; it must accommodate a 380x248 text region when the book is displayed at
440x320 UI pixels. Keep the top edge quiet enough for four separately rendered
92x30 leather tabs to be overlaid by the game. Do not draw those tabs or their
shelf into this asset.

The frame will be exported as a nine-slice with 30-pixel left/right and 28-pixel
top/bottom caps at 440x320. Put unique tears, stitch endpoints, rivets, metal
repairs, knots, and corner highlights only near the outer corners and fixed cap
regions. Keep the long horizontal and vertical middle bands low-frequency,
continuous, and stretch-safe. The same frame must remain coherent at 540x420.

FORBIDDEN BAKED CONTENT
Do not include tabs, tab labels, tab shelf, chat text, timestamps, player names,
channel colors, input strip, unread seal, buttons, icons, scroll bars, resize
grips, language controls, popup menus, copy controls, guild/bag/latency/time/gold
panels, a bottom information bar, or a second/right-side chat frame. Do not add
dragons, skulls, horns, spikes, gothic cathedral tracery, modern bevels, glossy
glass, neon, bloom, hard black outlines, perfect bilateral symmetry, readable
letters, runes, logos, watermarks, signatures, or a world scene.

CANVAS, ALPHA, AND OUTPUT
Return one landscape RGBA PNG on a true transparent background. Show exactly one
complete isolated book, centered with at least 24 transparent pixels of clear
margin on every side, with no clipping and no cast shadow extending into the
margin. Do not use green, white, checkerboard, or scenic backgrounds. Do not make
an atlas or contact sheet. The provider may use its native landscape resolution;
the accepted single result will later be deterministically normalized as a whole
to the existing 1608x978 source canvas, then nine-sliced. No old pixels or mask
compositing will be used during normalization.

FINAL SELF-CHECK BEFORE RETURNING
Verify that the image contains exactly one complete empty old-book frame; that
all visible materials look generated as one physically continuous object; that
the near-black center still reads as paper; that no bright old-paper rim creates
a pasted-center effect; that the silhouette and wear are irregular rather than
overly orderly; that the central field and stretch bands stay quiet; that all
runtime text and controls are absent; and that the exterior is truly transparent.
```

### Prompt 完整性审计与新修复包络

- 生产正文已经自包含对象、数量、状态、输入角色、材料、颜色、笔触、光照、
  不规则度、实际显示区域、九宫格 cap、支持尺寸、Alpha、留白、禁止烘焙内容、
  反模式和最终自检；不依赖“同前”“参考项目”或未上传图的隐式语义。
- 唯一有意保留的 provider 不确定性是原始 landscape 像素尺寸；最终整图只做
  确定性画布归一，不把分辨率差异变成美术修复，也不混入其他图片。
- 新批次预算从 `0/5` 开始；`CHAT.FRAME.PAPER.V1` 剩余 `4` 次不转移。工具、
  sandbox、子进程或下载错误仍单独记 `E#`，不占实际生成次数。
- 每次候选按对象身份 → 禁止烘焙内容 → 整体材料连续性 → 纸／皮区分 →
  Alpha／完整外接框 → 九宫格 stretch 区 → `440 × 320` 典型／最大排版 →
  五场景展示区域的顺序审查；只修第一个失败门禁。
- 允许的自主修复只包含：增强“整体一次重绘”约束、压制亮金页圈、提高纸纤维
  与皮革差异、修正过度规则轮廓、清除禁止控件、恢复透明外部、把独特细节移出
  stretch 中段。不得引入旧母版 mask、donor 或当前会话内建 imagegen。
- 通过全部内部门禁后必须停止并提交用户复审；不得自动晋级 source／runtime。
- 用户授权已经同时覆盖：版本 `CHAT.FRAME.FULL.V1`、上述完整正文、固定 SHA
  的唯一 Image 1、最多五次实际调用，以及仅启动一个
  `npx @openai/codex@0.143.0` 子进程并只在该子进程使用其自带 image_gen。

### 精确授权记录与冻结修复包络

- 用户授权日期：`2026-08-02`。
- 授权版本：`CHAT.FRAME.FULL.V1`；对应模拟：`CHAT-FULL-SIM-V1 confirmed`。
- 唯一允许上传的 Image 1：
  `assets/source/chat/v3/ChatBookFrame_Master_v3.png`，SHA-256
  `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`；
  只承担完整生产正文声明的高权重结构／比例／拓扑职责。
- 实际 ImageGen 预算：新批次最多 `5` 次，当前 `2/5`；旧
  `CHAT.FRAME.PAPER.V1` 剩余次数不转移。
- 执行机制：原授权的一个 `npx @openai/codex@0.143.0` 子进程已用于
  attempt 1 并退出。用户现明确允许 `.r1` 额外启动一个固定
  `npx @openai/codex@0.143.0` 子进程；只在这个新增子进程内调用其自带
  `image_gen`。当前会话仍不得调用内建 imagegen，新增子进程不得再启动其他
  Codex／npx 子进程。
- 不可变边界：一个完整空战地旧书、一种 static 状态、唯一 Image 1 及其职责、
  `440 × 320`／`540 × 420`、`380 × 248` 安静区、`30/28/30/28px` 九宫格
  cap、真透明外部、独立 Tab／Input／Unread／文字、全部禁止烘焙内容，以及
  不使用旧像素 mask／donor／视觉合成。
- 允许的自主修复：只在上述冻结边界内强化整体连续重绘、暖黑纸的纸张身份、
  页叠到皮革过渡、非镜像凌乱度、透明外部、stretch 中段安静度或删除误生的
  禁止内容；可在明确保留正确区域时 edit 同循环上一候选，否则仍以唯一
  Image 1 regenerate。任何新输入、对象、状态、布局、画布或视觉方向变化都
  立即停止并重新授权。
- 用户原文：

> 明确确认 CHAT-FULL-SIM-V1，并明确授权 CHAT.FRAME.FULL.V1 的完整生产正文；
> 允许上传固定 SHA-256
> f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057 的
> ChatBookFrame_Master_v3.png 作为唯一 Image 1；允许最多 5 次实际 ImageGen
> 调用；允许仅启动一个 npx @openai/codex@0.143.0 子进程，并仅在该子进程内
> 调用其自带 image_gen。不得调用当前会话内建 imagegen。

- `.r1` 新增执行机制授权日期：`2026-08-02`。用户原文：

> 明确允许 CHAT.FRAME.FULL.V1.r1 使用剩余预算，并额外启动一个固定的 npx
> @openai/codex@0.143.0 子进程；继续使用原固定 SHA 的唯一 Image 1，仍禁止
> 当前会话内建 imagegen。

### `CHAT.FRAME.FULL.V1` 自主修复循环

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `CHAT.FRAME.FULL.V1` / `aa39bd1` | edit | session `019fc246-3bd9-7730-b57a-74a8fe4c7e71`；provider result `ig_0bc4514bd99f52a9016a6f2cb1e2cc819190420510b3116e61` | provider raw `6686274e00358207f98573b7c0bb6c9819394a959d0be662fa39e386ac8f4cdc`；去键 RGBA `f454efa1e9409d40c9f1eafcae84abff05ed72f04975c9f44252e915d728d98b` | 纸／皮身份区分：中央阅读面是规则压纹皮革，不是暖黑纤维纸 | 保留“单一完整连续书体、无烘焙控件”的方向；`.r1` 只强化纸张身份。唯一获准子进程已退出，等待新的执行机制授权 | `candidate-rejected` |
| 2/5 | `CHAT.FRAME.FULL.V1.r1` / `31d35c8` | edit | session `019fc27e-f6fb-7d90-ac30-5fbdfef99c11`；provider result `ig_0008a6d335a216a8016a6f3b35b41481919d0752e2d83926a4` | provider raw `8275b815b19677fda2fe242b79a06557af90032e570841236cab41ec429917b5`；最终确定性透明 RGBA `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673` | 无；provider 棋盘背景属于已允许的纯候选技术清理项，复核后可见纯绿／高绿均为 `0`，全部候选门禁通过 | 保留整张 attempt 2 候选；停止自主循环并提交用户复审，不消费剩余三次 | `candidate-reviewed` |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|

- 当前实际生图：`2/5`；流程错误：`0`；循环终态：
  `candidate-reviewed`，随后由用户接受为 `source-accepted / P4`。剩余 `3` 次
  永久停止消费且不转移；新增的固定
  Codex／npx 子进程已完成 attempt 2 并退出。全部内部门禁通过后已按合同停止，
  不得继续生图或启动其他进程。

### `CHAT.FRAME.FULL.V1` attempt 1 审查记录

- Prompt／传输：固定执行前 commit 为 `aa39bd1`；子进程终端回显包含完整授权
  正文和唯一 Image 1 的绝对路径。实际执行器为 `@openai/codex@0.143.0`，
  session `019fc246-3bd9-7730-b57a-74a8fe4c7e71`；未启动嵌套 Codex／npx，
  当前会话未调用内建 imagegen。
- 输入：唯一上传图仍为
  `assets/source/chat/v3/ChatBookFrame_Master_v3.png`，SHA-256
  `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`。
- 原始输出：provider raw 保存在 ignored 路径
  `generated/chat/core/CHAT.FRAME.FULL.V1/attempt-01/ChatBookFrame_Full_V1_attempt01.provider-raw.png`；
  `1619 × 971 RGB`，绿色键背景，SHA-256
  `6686274e00358207f98573b7c0bb6c9819394a959d0be662fa39e386ac8f4cdc`。
- RGBA 审查副本：子进程只对 provider raw 执行确定性去键，未混入旧母版像素；
  路径
  `generated/chat/core/CHAT.FRAME.FULL.V1/attempt-01/ChatBookFrame_Full_V1_attempt01.rgba.png`，
  `1619 × 971 RGBA`，SHA-256
  `f454efa1e9409d40c9f1eafcae84abff05ed72f04975c9f44252e915d728d98b`；
  opaque／partial／transparent 为 `1,340,051 / 5,666 / 226,332`，可见绿色
  残留为 `0`。
- 门禁 1／对象身份：通过。恰为一张完整、横向、正视、空内容的旧书框，没有
  第二书框、场景或 atlas。
- 门禁 2／禁止烘焙内容：通过。没有 Tab、文字、按钮、滚动条、输入条、底部
  信息栏或右侧聊天框。
- 门禁 3／整体材料连续性：通过。书体、页叠、皮革、缝补和黄铜由同一次生成
  构成，没有旧像素中心蒙层或贴片接缝。
- 门禁 4／纸皮区分：失败，也是首个失败门禁。中央阅读区覆盖了均匀、重复、
  压印式的皮革粒面，并与外层皮革共享质感；缺少哑光纸浆、纤维吸附、烟熏渍
  和纸页毛边等身份线索，无法读作 `#18120D` 附近的暖黑羊皮纸。
- 未作为本轮修复目标的后续证据：可见 Alpha bbox 为
  `[12,33,1590,944]`，四边透明留白为 `12/33/29/27px`，左侧低于合同要求的
  `24px`。由于纸／皮门禁更早失败，本轮未继续九宫格、真实排版或五场景
  display-region 预演。
- 结论：`candidate-rejected / P3`。已接受 V3 source、正式 TGA、Lua、pfUI、
  ChatMOD 和 v1.18 runtime 全部未改变。

### `CHAT.FRAME.FULL.V1.r1` 完整修订正文

`.r1` 只修复首个失败门禁：中央阅读面的纸张身份。对象、唯一输入、材料层级、
布局、安全区、九宫格、Alpha、禁止内容和美术方向均不变；该修订属于已冻结的
自主修复包络，正文已由 commit `c28d6b3` 固定。用户额外授权的固定 0.143.0
子进程已经执行 attempt 2 并退出。

```text
Create one production-ready bitmap asset by editing Image 1 as a whole.

OBJECT AND RESPONSIBILITY
Redraw Image 1 into one complete, coherent, empty fantasy chat-book frame for a
Vanilla-era MMORPG UI. This is exactly one landscape old book object in exactly
one static state. Regenerate every visible book pixel together in the same edit:
the reading paper, stacked page edges, leather cover, restrained oxidized-brass
repairs, contact shadows, wear, stains, and warm lighting. Do not generate a
paper donor, center overlay, insert, patch, or second panel. Do not preserve or
composite any of Image 1's old surface pixels.

IMAGE 1 ROLE
Use Image 1 as a high-weight structural, proportional, and topology reference
only. Preserve its landscape bounding proportions, compact border-to-center
ratio, empty central reading-field topology, complete-object scale, and gently
irregular overall silhouette. Do not preserve its bright golden paper color,
old pixel texture, old seam lighting, old paper/leather boundary, alpha defects,
or local ornaments. The art direction below overrides those visible qualities.
Do not use the previous generated attempt as an input.

FIRST REPAIR PRIORITY: THE CENTER MUST BE PAPER
The central reading field must be unmistakably matte paper both at native
resolution and when reduced to a 440x320 game UI object. It must never look like
embossed leather, tooled hide, padded fabric, painted wood, or a modern black
panel. Build the paper identity with flattened irregular pulp fibers, subtle
directional fiber breaks, broad low-frequency soot absorption, sparse feathered
warm-brown stains, faint dry creases, worn thin spots, and a slightly frayed
deckled boundary where the top leaf meets the stacked page edges. Keep these
marks quiet and non-repeating so chat text remains readable.

Do not place repeating diamonds, scales, stamped motifs, braided impressions,
pebbled hide grain, leather tooling, upholstery texture, stitched seams, knots,
rivets, or metal fittings anywhere inside the central reading field. The paper
surface must have visibly lower micro-contrast and a flatter matte response than
the surrounding leather. Leather grain and leather tooling are allowed only
outside the complete stacked-page boundary.

ART DIRECTION
The result must read first as a thick battlefield field book that has been
carried, opened, stained, repaired, and reused for years. Use a 2004-era
hand-painted low-resolution fantasy UI bitmap language: deliberately simplified
forms, broad readable value groups, restrained brush texture, mild pixel-era
edge softness, no photographic detail, and no clean vector symmetry. Make the
book visibly irregular and slightly untidy, with non-mirrored page wear and
repairs. Use warm upper-left illumination with quiet lower-right falloff.

MATERIAL HIERARCHY
The material hierarchy is matte fibrous paper first, deep walnut-brown worn
leather second, and small muted oxidized-brass repairs third. The opaque central
reading paper is near-black warm soot parchment, visually centered around
#18120D, with subtle warm-brown fibers and sparse irregular smoke staining. It
must remain visibly paper. Transition outward through several physical layers
of near-black umber and tobacco-brown paper edges. Generate their fibers,
deckled edges, thickness, contact occlusion, and wear together with the top
paper leaf. The page stack must clearly sit on and inside the smoother, creased
deep-walnut leather cover.

Do not surround the dark paper with a bright gold rim or an abrupt rectangular
seam. Do not let the leather texture leak across the reading field. Oxidized
brass stays low-saturation and sparse, limited to believable edge or corner
repairs.

LAYOUT AND RUNTIME-SAFE REGIONS
Keep the complete book fully visible in a flat, straight-on orthographic UI view.
The output is an empty frame only. Reserve a quiet uninterrupted central reading
field covering approximately x=7%..93% and y=10%..87.5% of the visible book
bounds; it must accommodate a 380x248 text region when the book is displayed at
440x320 UI pixels. Keep the top edge quiet enough for four separately rendered
92x30 leather tabs to be overlaid by the game. Do not draw those tabs or their
shelf into this asset.

The frame will be exported as a nine-slice with 30-pixel left/right and 28-pixel
top/bottom caps at 440x320. Put unique tears, stitch endpoints, rivets, metal
repairs, knots, and corner highlights only near the outer corners and fixed cap
regions. Keep the long horizontal and vertical middle bands low-frequency,
continuous, and stretch-safe. The same frame must remain coherent at 540x420.

FORBIDDEN BAKED CONTENT
Do not include tabs, tab labels, tab shelf, chat text, timestamps, player names,
channel colors, input strip, unread seal, buttons, icons, scroll bars, resize
grips, language controls, popup menus, copy controls, guild/bag/latency/time/gold
panels, a bottom information bar, or a second/right-side chat frame. Do not add
dragons, skulls, horns, spikes, gothic cathedral tracery, modern bevels, glossy
glass, neon, bloom, hard black outlines, perfect bilateral symmetry, readable
letters, runes, logos, watermarks, signatures, or a world scene.

CANVAS, ALPHA, AND OUTPUT
Return one landscape RGBA PNG on a true transparent background. Show exactly one
complete isolated book, centered with at least 24 transparent pixels of clear
margin on every side, with no clipping and no cast shadow extending into the
margin. Do not use green, white, checkerboard, or scenic backgrounds. Do not make
an atlas or contact sheet. The provider may use its native landscape resolution;
the accepted single result will later be deterministically normalized as a whole
to the existing 1608x978 source canvas, then nine-sliced. No old pixels or mask
compositing will be used during normalization.

FINAL SELF-CHECK BEFORE RETURNING
Verify that the image contains exactly one complete empty old-book frame; that
all visible materials look generated as one physically continuous object; that
the near-black center reads immediately as matte fibrous paper at 440x320 and
cannot plausibly be mistaken for leather; that no repeated embossed or tooled
pattern exists in the reading field; that no bright old-paper rim creates a
pasted-center effect; that the silhouette and wear are irregular rather than
overly orderly; that the central field and stretch bands stay quiet; that all
runtime text and controls are absent; and that the exterior is truly transparent.
```

### `CHAT.FRAME.FULL.V1.r1` attempt 2 审查记录

- Prompt／传输：执行前 commit 为 `31d35c8`；固定子进程收到上方 `.r1` 完整
  正文与唯一 Image 1 的绝对路径。实际执行器为
  `@openai/codex@0.143.0`，session
  `019fc27e-f6fb-7d90-ac30-5fbdfef99c11`，provider result
  `ig_0008a6d335a216a8016a6f3b35b41481919d0752e2d83926a4`。子进程未启动嵌套
  Codex／npx；当前会话未调用内建 imagegen。
- 输入：唯一上传图仍为
  `assets/source/chat/v3/ChatBookFrame_Master_v3.png`，SHA-256
  `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`。
- provider raw：ignored 路径
  `generated/chat/core/CHAT.FRAME.FULL.V1/attempt-02/ChatBookFrame_Full_V1_r1_attempt02.provider-raw.png`；
  `1620 × 971 RGB`，SHA-256
  `8275b815b19677fda2fe242b79a06557af90032e570841236cab41ec429917b5`。
  provider 把透明预览棋盘绘进 RGB；provider cache、子进程副本和仓库审查副本
  字节一致。
- 透明技术清理：
  [`extract_chat_full_frame_candidate_v1.py`](../../../../tools/extract_chat_full_frame_candidate_v1.py)，
  SHA-256 `24c19cc6ec7bc63b3fecd0ac4a7ba4b7f8e787f449ac6410fc7bd00b69cec7ae`，
  只读取 attempt 2 raw；不读取旧 source、旧 mask 或其他候选。它保留中心连通
  书体、填充物件内部中性高光、从候选自身邻域恢复软边颜色，并将完整物件无
  裁切地等比缩放至 `0.975` 后放到 `1608 × 978` 透明画布；缩放后只对仍呈
  绿键优势的可见低 Alpha 外沿像素使用候选自身邻域颜色做确定性替换。输出
  `generated/chat/core/CHAT.FRAME.FULL.V1/attempt-02/review/ChatBookFrame_Full_V1_r1_attempt02.transparent.png`，
  SHA-256 `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673`；
  RGBA 可见 bbox `[24,25,1584,952]`，四边透明留白
  `24/25/24/26px`，opaque／partial／transparent 为
  `1,325,523 / 23,952 / 223,149`。首次 macOS `inspect_candidate.py`
  独立复核发现旧审查副本仍有 `28` 个纯绿与 `95` 个启发式高绿可见像素，
  全部位于 `alpha=1..26` 的物件外沿。修订工具仅替换这 `95` 个像素的 RGB；
  Alpha 变化像素 `0`、不透明 RGB 变化像素 `0`，最终纯绿／高绿为 `0/0`。
  指标 SHA-256 为
  `2cbd326ec518d772d72e6527281caebd977f4d224cc8c5020b4557bc81e36352`；
  蓝色对照底合成未见 Alpha 光晕，满足每边至少 `24px` 合同。该修订没有
  ImageGen、上传、新 provider result、旧 source 像素或额外生图计数。
- 门禁 1／对象身份：通过。恰为一张完整横向战地旧书；正视、单状态、空内容，
  外轮廓由左侧卷脊、非镜像磨损、右侧系绳和右下黄铜修补形成自然凌乱度。
- 门禁 2／禁止烘焙内容：通过。无 Tab、文字、按钮、输入、未读、滚动条、
  底栏、右侧聊天框、图标、标志或世界场景。
- 门禁 3／整体材料连续性：通过。中央纸张、毛边页叠、深胡桃皮革、系绳、
  黄铜与接触暗部属于同一次整体生成，不存在 donor、旧像素 mask、覆盖层或
  中心贴片边界。
- 门禁 4／纸皮身份：通过。阅读面以低频烟熏吸附、扁平不规则纤维、稀疏暖褐
  污渍、干裂和毛边读作哑光暖黑纸；外围皮革保留更平滑、更高微对比的压纹与
  折痕。阅读面没有规则菱格、鳞纹、编织压痕或重复皮革 tooling。
- 门禁 5／美术继承与伸缩区：通过。综合色重、暖左上光、低饱和黄铜、旧书
  厚度和 2004 年手绘位图语言与锁定基线一致；独特点均位于外侧／固定 cap，
  长水平／垂直中段保持低频，未出现明亮金圈或规则对称建筑感。
- 真实装配工具继续使用
  [`render_chat_dark_paper_candidate_v1.py`](../../../../tools/render_chat_dark_paper_candidate_v1.py)，
  SHA-256 `c0ae1d1bc17f5f0736a844f70e255f36ccfd183ed26445e2f948d5c4e63d6ba4`；
  候选 specification 为
  [`chat_full_frame_candidate_preview_v1.json`](../../../../tools/specs/chat_full_frame_candidate_preview_v1.json)，
  SHA-256 `b382aaa2f70f96316e427e5cb30fd25b7213668437c1cd2f5316075ee3593acb`。
  预演只叠加已接受 V3 Tab 与动态代表文字，不把它们写入候选。
- 真实排版输出：
  `generated/chat/core/CHAT.FRAME.FULL.V1/attempt-02/review/ChatFullFrame_candidate_real_layout_v1.png`，
  SHA-256 `3181c94b1dfa2288f45427ae60758bfef389a1f8dc9f45da432bd58ab6699b2d`；
  metrics SHA-256
  `4fd7c2bf4f4d647721901786c2976822c9774fb7c3913748a56558c088b9d46f`；
  空内容 `0` 行、最小内容 `1` 行、典型 `15/15` 行、最大 `16/16` 行、
  `540 × 420` 扩展 `22/22` 行均无截断，末基线分别为
  `42/42/252/267/357`，对应正文底边为 `280/280/280/280/380`。九宫格在
  `440 × 320` 与 `540 × 420` 均无可见拼接缝、重复金属件或 cap 拉伸。
- 展示区域合同：
  [`chat_full_frame_display_region_v1.json`](../../../../tools/specs/chat_full_frame_display_region_v1.json)，
  SHA-256 `00010e8b80412d17c01fc2ddff6fc565789c9707b2c7b913953c095f429505c0`；
  报告
  `generated/chat/core/CHAT.FRAME.FULL.V1/attempt-02/review/CHAT.FRAME.FULL.V1.r1-attempt02.display-region-report.json`，
  SHA-256 `cc4561e63fca73ccb9423dcad4dd82f0bffaf24165c8aa0fd70e1cf888b5dbc3`。
  empty、minimum、15 行 typical、16 行 maximum 和 expanded 五场景全部
  `pass`，violations `0`，first failure `null`。
- `2026-08-03` 本机复核环境：`Darwin`，Python
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`。候选提取
  确定性复跑、`inspect_candidate.py`、五场景 display-region、两个目标工具
  `py_compile`、asset workflow／repository／quest design contract、Chat／
  pfUI／Quest Lua smoke 与 `git diff --check` 全部通过。三条 Lua smoke 首次
  调用遗漏必需的仓库根参数而退出，补为 `lua <test> .` 后全部通过；这是测试
  调用错误，不是 ImageGen 流程错误，也不改变 `2/5` 计数。
- 历史结论：该次内审终态为 `candidate-reviewed / P3`。自主循环在实际
  ImageGen `2/5` 处停止；用户随后于 `2026-08-03` 接受精确候选进入 `P4`。
  接受当时 V3 正式 TGA、Lua 和 v1.18 runtime 保持不变；后续 P5 导出见下节。

### `CHAT.FRAME.FULL.V1.r1` 用户接受记录

- 用户原文：`接受 CHAT.FRAME.FULL.V1.r1 attempt 2 进入 P4。`
- 接受日期：`2026-08-03`；状态：`source-accepted / P4`。
- 最终 source：
  [`ChatBookFrame_Full_V1_r1.png`](../../../../assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png)，
  `1608 × 978 RGBA`，SHA-256
  `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673`。
- provenance manifest：
  [`ChatBookFrame_Full_V1_SourceManifest_v1.json`](../../../../assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_SourceManifest_v1.json)。
- 接受范围只包含精确透明 source 与 provenance；不包含 runtime TGA、Lua／XML、
  `P5` 或 Turtle WoW 实机结论。
- 下一门禁：建立确定性归一／裁切／九宫格或 atlas 合同，以最终 runtime 产物
  复跑真实展示区域门禁并通过静态测试后，才可进入 `P5`。

### `CHAT.FRAME.FULL.V1.r1` P4→P5 导出记录

- 后续指令：用户于 `2026-08-03` 要求“继续”；范围只覆盖确定性 export、
  adapter 接入、最终 runtime 预演与静态验证，不包含 ImageGen、P6 或推送。
- exporter：
  [`build_chat_full_frame_v1_runtime.py`](../../../../tools/build_chat_full_frame_v1_runtime.py)，
  SHA-256 `1011f787af1da38b0ff16376ccafb9bc84f7e8c6c0a2e8dd99164aa1f27f9b53`。
  固定 source 全图按比例缩到 `1024 × 623` 并置于透明 `1024²` atlas；九宫格
  切线为 `137/64/946/548/623`，runtime cap 为 `30/28/30/28px`。
- Lanczos 在轮廓产生的 `50` 个 dominant-green 低 Alpha 振铃像素只清零 RGB；
  最高 Alpha `13/255`，Alpha、主体像素和轮廓不变。最终纯绿／高绿计数 `0/0`。
- 正式 TGA：
  `addon/AzerothExpeditionUI/Media/Chat/ChatBookFrameFullV1.tga`，`1024² RGBA`，
  SHA-256 `becb504fb482cb37c0824e9b8705b4ad76d890a5cac024e83a3cce81517025ae`；
  [runtime manifest](../../../../assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_RuntimeManifest_v1.json)
  固定 contract `1.19`。旧 `ChatBookFrameV3.tga` 只作 P6-C 前回退。
- adapter：九个 texture slice 只挂 `pfUI.chat.left`；右框实例为 `0`。现有 V3
  Tab、shelf、input、unread 不变。暖黑阅读区代理色为 `#30241B`；基础色保留
  Vanilla 身份，未知内嵌色只在低于 `4.8:1` 时做最小提亮，消息和链接载荷不变。
- 最终证据：
  [`ChatFullFrame_runtime_real_layout_v1.png`](../../../../generated/chat/core/CHAT.FRAME.FULL.V1/runtime-v1/ChatFullFrame_runtime_real_layout_v1.png)
  SHA-256 `45af5115e4db28759c604841708a58b4947fa47de23a6c912af04ac5222bebe1`；
  `440 × 320` 空／最小／15 行／16 行和 `540 × 420` 22 行共五场景均通过，
  display-region report SHA-256
  `8bd7c8680da4ff39b88677a8b4476f6bc0a37b5e7c8da4b9f5ccd03340830dc8`，
  violations `0`。
- 静态门禁：exporter 重建一致性、Lua 语法、Chat smoke、repository contract
  均通过；项目状态 `runtime-exported / P5`。下一门禁仅为 Turtle WoW `1.18.1`
  `/reload` P6，当前不得清理 source、证据或 V3 回退。

## 最终执行正文

### 已接受 V3 的确定性导出

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

### Runtime contract v1.7 修正

- 有效实机结论：`2026-07-31` 截图中四枚 AEUI Tab 仍存在，正文消息也仍
  路由到左框，但九宫格书本主体未显示，画面退回 pfUI 的透明容器外观。
- 第一个失败门禁：`runtime-corrected → game-validated` 的主框持续装配。
- 当前证据不能唯一证明是模块 Apply 被前序异常中断，还是书本 Texture／
  BACKGROUND draw layer 被后续刷新剥离；因此修正同时覆盖两个可独立验证的
  失败面，不把推断写成已证实根因。
- 修正：
  - Bootstrap 逐模块 `pcall` 执行 Initialize／Apply；单模块异常只记录在
    `moduleFailures` 并对同一错误打印一次，不再中断其他模块；
  - `Chat:EnsureBookVisible()` 在现有维护节拍与延迟布局恢复前检查书本中心片、
    Tab 承托带、Texture 路径和 runtime 标记；
  - 缺失、隐藏、贴图被清空或版本过期时调用既有 `EnsureBook()`，恢复
    BACKGROUND draw layer、透明 pfUI backdrop、九宫格与承托带；
  - 不增加新的 OnUpdate，不在书本完整时重写几何。
- 静态证据：Lua 5.0 语法、Chat smoke 中的贴图剥离恢复断言、失败模块后
  健康模块继续 Apply 的隔离断言均通过。
- 未改变：Tab 逻辑尺寸、文字／命中区、安全区、五张 runtime TGA 像素与
  SHA、已接受 source、atlas UV、消息与停靠数据。

### Runtime contract v1.8 修正

- 有效实机结论：`2026-08-01` 截图中正文使用 `12px` 中文字体与描边，但
  相邻行几乎粘连。主客户端 `chat-cache.txt` 确认窗口字号为 `12`；pfUI
  SavedVariables 确认区域兼容字体、`OUTLINE` 与 `pfChatLeft` 局部缩放
  `1.1` 均启用。
- 根因：既有组件合同要求 `12px` 字号、约 `14px` 行高，但 v1.7 及以前只
  接管 `ChatFrameN` 安全区，没有调用 `SetSpacing`。中文满字面字体与描边
  占满原生零额外行距，局部缩放只放大字形，不会产生新的行间留白。
- 修正：
  - 只对 AEUI 左框内真实停靠的 `ChatFrameN` 设置 `2 UI px` 行距；
  - 支持有／无 `GetSpacing` 的 Vanilla API；有读取能力时只在偏离合同或
    runtime 版本变化时写入，无读取能力时仅在既有布局事件后重施；
  - pfUI `RefreshChat`、`FCF_SetChatWindowFontSize`、Tab 选择、Dock
    更新／保存与缩放恢复继续共用既有事件驱动路径，不增加维护型 OnUpdate；
  - 用户字号、字体、描边、频道色、消息内容和其他 pfUI 模块保持不变。
- 静态证据：Chat smoke 覆盖初次应用、用户调整字号、pfUI 把 spacing 重置
  为 `0` 后恢复，以及缺少 `GetSpacing` 时的兼容路径。
- 未改变：正文安全区、Tab／输入／未读几何、五张 runtime TGA 像素与 SHA、
  已接受 source、消息路由和停靠数据。

### Runtime contract v1.9 修正

- 有效实机结论：v1.8 已消除相邻中文行的直接粘连，但 `2026-08-01` 后续截图
  仍显示每个中文字被 pfUI 全方向 `OUTLINE` 包围；高饱和频道色、密集黑色
  字圈和正文区纸纤维同时出现，长期阅读产生明显视觉疲劳。
- 根因：pfUI 配置项“Enable Text Shadow”实际把 `ChatFontNormal` 设为
  `OUTLINE`。对于满字面的中文字体，这会把每个字扩成高对比色块；单纯增加
  行距只能分离行，不能降低字内与字间的高频边缘噪声。
- 修正：
  - 只对 AEUI 左框内真实停靠的 `ChatFrameN` 使用项目已有
    `NotoSansSC-Medium.ttf`，从 `GetFont` 保留用户字号，缺少读取 API 时使用
    既有记录或 `12px` 兜底；
  - 调用 `SetFont` 时不传 flags，移除全方向描边；改用
    `RGBA(0.16,0.09,0.04,0.78)`、偏移 `(1,-1)` 的单向深棕阴影；
  - 行距由 `2px` 调整为 `3px`，12px 基线约为 15px 行高和 16 行中文；
  - 在 `380 × 248` 正文安全区内创建内置 `WHITE8X8` 连续压光层，使用
    `RGBA(0.18,0.11,0.06,0.10)`，位于书页之上、聊天文字之下；不新增 TGA，
    不形成黑色面板、边框或逐条消息底色；
  - 压光层进入书本自愈检查；字体、阴影和行距继续沿用 pfUI Refresh、字号
    调整、Tab／Dock 与缩放后的事件式恢复，不增加消息级 Hook 或维护型几何
    改写。
- 静态证据：Chat smoke 覆盖 Noto 字体、空 flags、阴影参数、`3px` 行距、
  压光层层级／锚点／透明度、贴图剥离自愈、字号调整以及 pfUI 重置后恢复；
  同时覆盖缺少 `GetFont`／`GetSpacing` 的兼容路径。
- 未改变：用户字号选择、频道色、物品色、链接、消息字符串与路由、正文安全
  区、Tab／输入／未读几何、五张正式 runtime TGA 像素与 SHA、其他 pfUI
  模块。

### Runtime contract v1.10 修正

- 有效实机结论：v1.9 截图显示浅粉公共频道正文与暖黄羊皮纸的明度过于接近；
  同时安全区 `10%` 暖色压光形成了边界可见的浅暗矩形，削弱整张书页的连续
  材质。用户要求执行频道色方案并恢复 v1.8 使用的旧字体。
- 修正：
  - 删除压光层的创建、锚点和自愈依赖；若旧对象仍存在则清空 texture 并
    隐藏，书页仅显示正式九宫格自身像素；
  - 受管 `ChatFrameN` 不再固定 Noto Sans SC Medium，而从当前 Frame 或
    `pfUI.font_default` 恢复 provider 配置字体；继续保留用户字号、空 font
    flags、单向深棕阴影和 `3px` 行距；
  - 在 pfUI 完成消息解析后、真实 `HookAddMessage` 显示前安装受管 Frame
    wrapper；只当基础 RGB 与当前 `ChatTypeInfo.CHANNEL` 匹配时，将显示参数
    改为 `RGB(0.36,0.16,0.14)`；
  - wrapper 每次调用都确认 AEUI Chat 启用且 Frame 真实停靠在
    `pfUI.chat.left`，因此禁用模块或移出受管左框后不改色；
  - 不调用 `ChangeChatColor`，不写全局 `ChatTypeInfo` 或 SavedVariables，
    不重写消息字符串；时间、玩家职业、物品、链接等内嵌颜色保持原义。
- 静态证据：Chat smoke 覆盖压光层不存在／旧对象退役、pfUI 字体恢复、字号
  调整与 Refresh 后恢复、公共频道局部 RGB 映射、非频道色及消息参数原样转发；
  repository contract 覆盖 runtime 版本和无全局色彩写入。
- 限制：pfUI 在 AEUI 加载前重放到聊天框的历史行已经完成显示，v1.10 不清空
  或重建历史；局部墨色从 wrapper 安装后的新公共频道消息开始生效。
- 未改变：正文安全区、Tab／输入／未读几何、五张正式 runtime TGA 像素与
  SHA、聊天历史存储、路由及其他 pfUI 模块。

### Runtime contract v1.11 修正

- 有效实机结论：v1.10 已恢复 pfUI 旧字体并移除压光层，但截图显示
  `RGBA(0.16,0.09,0.04,0.78)`、偏移 `(1,-1)` 的正文投影在当前旧字体和
  游戏缩放下形成大面积重复字形，用户明确要求取消阴影。
- 修正：
  - 受管 `ChatFrameN` 的 `SetShadowColor` 固定为 `RGBA(0,0,0,0)`，
    `SetShadowOffset` 固定为 `(0,0)`；
  - 字体仍取当前 Frame／`pfUI.font_default`，`SetFont` 继续不传 flags；用户
    字号、`3px` 行距、公共频道深酒红基础色和书页无覆盖层合同全部保持；
  - pfUI Refresh、字号调整、Tab／Dock 与缩放后的既有事件路径会重新清零
    阴影，不增加消息级改写或维护型几何循环。
- 静态证据：Chat smoke 覆盖首次应用、字号调整和 pfUI Refresh 后均为透明
  阴影与零偏移；repository contract 固定 v1.11 的两组零值常量。
- 未改变：消息字符串、全局频道色、内嵌语义色、正文安全区、Tab／输入／未读
  几何、五张正式 runtime TGA 像素与 SHA、聊天历史存储及其他 pfUI 模块。

### Runtime contract v1.12 修正

- 有效实机结论：v1.11 已解决正文重影；`2026-08-01` 最新截图仍显示时间戳、
  职业玩家名、等级难度、物品／URL 与公共正文使用适合深色聊天底板的高明度
  RGB，在暖黄羊皮纸上明度接近或产生发光感。用户要求全部文本颜色统一修正，
  并确认聊天增强 provider 为 ChatMOD；随后明确要求直接实施、不经过 Figma。
- provider 审计：主／测试客户端均为 ChatMOD 1.1 且 `ChatMOD.lua` SHA-256
  一致；主客户端 SavedVariables 启用了彩色玩家名、时间戳、等级、URL 与自身
  高亮。源码确认 `S_AddMessage` 在原始消息进入 pfUI 前写入精确八位颜色码，
  然后沿 pfUI 的 `HookAddMessage` 最终显示链输出。
- 修正：
  - 新增七类基础墨色：正文深酒红 `#4A2A22`、元数据深胡桃 `#3D2C1E`、
    警告深朱红 `#5F1E1B`、正向苔绿黑 `#263919`、队伍靛蓝黑 `#17364E`、
    密语桑葚黑 `#54243A`、强调焦赭 `#51270F`；
  - 只在基础 RGB 与动态 `ChatTypeInfo` 项精确匹配时，按普通／公共、系统、
    公会／收益、队伍／团队、密语、警告、表情语义映射；不写全局表；
  - 对 ChatMOD 1.1 全部字面颜色、九职业色和 Vanilla 物品品质色建立精确
    白名单，时间戳改为深青黑；职业、品质、等级、URL 与自身高亮保留色相
    身份但统一降低明度／饱和度；
  - `NormalizeInlineMessageColors` 只替换 `|cAARRGGBB` 前缀，不解析或重建
    `|H...|h` 链接；未知第三方色原样保留；
  - wrapper 每次确认 AEUI Chat 启用、Frame 停靠于左书且不是 `pfCombatLog`；
    禁用模块、战斗日志与未受管 Frame 完整回退 provider 输出。
- 静态证据：Chat smoke 覆盖基础频道／系统映射、ChatMOD 大写时间戳、职业、
  等级、稀有物品、URL、未知自定义颜色、四类链接载荷、战斗日志隔离与禁用
  回退；repository contract 固定 runtime 版本、精确白名单入口及禁止全局
  `ChatTypeInfo`／`ChangeChatColor` 写入。
- 限制：已显示的聊天历史行不会被 Frame 重新着色；v1.12 从 wrapper 安装后
  的新消息开始生效。未审计的第三方动态色不猜测映射，避免破坏语义。
- 未改变：外部 ChatMOD／pfUI 文件和 SavedVariables、消息事件／历史／路由、
  链接载荷、字体／字号／行距、安全区、Tab／输入／未读几何、五张正式 TGA
  像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.13 修正

- 有效实机结论：v1.12 重载后的截图中，时间戳仍为 ChatMOD 原始亮青
  `#33CCFF`，公共正文和职业名仍为浅粉／高明度职业色；用户直接反馈“看不清”。
  因为 v1.12 目标墨色一个都没有出现在截图中，首个失败门禁是运行时消息链，
  不是色板本身的深浅选择。
- 根因：源码审计暴露两个 v1.12 未覆盖的合法时序。其一，AEUI 首次布局时
  pfUI 的 `HookAddMessage` 可能尚未创建，而 v1.12 的 Maintain 不会再次安装
  颜色 hook；其二，ChatMOD 可先把原生显示函数保存到 Frame 的
  `ORG_AddMessage`，pfUI 随后把 `S_AddMessage` 保存为 `HookAddMessage`，形成
  `pfUI AddMessage → AEUI v1.12 wrapper → S_AddMessage 注入亮色 →
  ORG_AddMessage → 原生显示`。截图本身不能区分是哪一个时序或两者共同发生，
  但两条路径都会让最终亮色绕过白名单，且都已由 v1.13 覆盖。
- 修正：
  - 把受管条件、基础 RGB 与内嵌色转换合并为幂等的
    `ApplyMessagePalette`，供两个出口复用；
  - 保留 pfUI `HookAddMessage` wrapper，同时仅在检测到全局
    `S_AddMessage` 且 Frame 链真实引用它时，包裹该 Frame 的
    `ORG_AddMessage` 最终出口；不误接管其他插件同名字段；
  - wrapper 闭包保存原 provider，重复维护时比较真实函数身份，只安装一次；
    runtime 版本变化只更新标记，不形成递归链；
  - 现有 `Maintain` 节拍只对左框 docked Frame 检查 hook，使 pfUI
    `HookAddMessage` 或 ChatMOD `ORG_AddMessage` 在 AEUI 首次布局之后出现时
    都能被发现；不增加 OnUpdate，不改几何；
  - 两个出口都调用同一受管判断，因此禁用 AEUI、移出左框或
    `pfCombatLog` 时仍完整回退 provider 输出。
- 静态证据：Chat smoke 新增晚出现的 `HookAddMessage`，以及两条相反加载
  顺序：一条复现
  `HookAddMessage → S_AddMessage → ORG_AddMessage` 的 v1.12 旁路，一条复现
  ChatMOD 晚于 pfUI 时回调已包装链；两条都验证亮青／浅粉被最终转换、基础
  正文墨色生效、第二次 Maintain 不重复安装。既有未知色、四类链接、战斗日志
  与禁用回退断言继续通过。
- 未改变：v1.12 色板数值、外部 ChatMOD／pfUI 文件与 SavedVariables、全局
  `ChatTypeInfo`、消息事件／历史／路由、链接载荷、字体／字号／行距、安全区、
  Tab／输入／未读几何、五张正式 TGA 像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.14 修正

- 有效实机结论：用户重启游戏并确认 `/aeui status` 为
  `chat-runtime=1.13`，但新消息截图仍显示 `#33CCFF` 时间戳、浅粉公共正文和
  高明度职业色；这排除了旧会话和 Junction 未更新，证明 v1.13 的两个 hook
  仍没有进入实际显示调用。
- 新增审计：v1.13 的最终 wrapper 只有在 Frame 的 `AddMessage`、
  `HookAddMessage` 或保存的 provider 与全局 `S_AddMessage` 为同一函数对象时
  才安装；ChatMOD／其他增强可通过包装函数保持相同行为而改变函数身份。
  `IsMessagePaletteManaged` 同时要求 `frame.isDocked`，该标志由原生停靠流程
  管理，不应作为消息显示瞬间的视觉所有权门禁。这两项都比稳定的 Parent
  所有权更脆弱。
- 修正：
  - `InstallChatMODFinalColorHook` 对受管 Frame 已存在的 `ORG_AddMessage`
    无条件幂等包装，不再猜测其上游函数身份；闭包仍保存并转发原 provider；
  - 消息作用域改为 Frame 当前 Parent 精确等于 `pfUI.chat.left` 且不是
    `pfCombatLog`，不依赖瞬时 `isDocked`；hook 发现同样按 Parent 执行；
  - `addon/pfUI/modules/chat.lua` 在完成 URL／职业／等级／时间解析、历史保存和
    密语修正后，调用 `ApplyExpeditionMessagePalette`，再进入 provider
    `HookAddMessage`；这是 Chat 模块内的显式最终输出桥，不影响其他 pfUI 模块；
  - 原 AEUI `HookAddMessage` 和 ChatMOD `ORG_AddMessage` wrapper 保留为另外
    两层幂等兜底，任一加载顺序下重复调用不会再次改变已映射墨色；
  - 内嵌颜色 pattern 改为显式八位十六进制字符类，避免依赖目标 Lua 对 `%x`
    类别的实现差异；
  - `ApplyMessagePalette` 记录受管调用和实际变更次数；`/aeui status` 输出
    `chat-color=m#/h#/f#/c#/x#`，其中 `m` 为当前受管 Frame，`h` 为 Hook
    wrapper，`f` 为最终 ORG wrapper，`c` 为受管调用，`x` 为真实颜色变更。
- 静态证据：Chat smoke 覆盖 `isDocked=nil` 但 Parent 仍在左框、ChatMOD 经
  非同一函数对象的 proxy 调用、晚出现 provider、两种加载顺序、hook 幂等、
  计数与 status；pfUI／repository contract 固定最终输出桥和无
  `S_AddMessage` 身份门禁。Lua 语法、Chat／pfUI／Quest smoke、repository／
  quest design／asset workflow 契约均通过。
- 未改变：v1.12 色板数值、ChatMOD 源码／配置／SavedVariables、全局
  `ChatTypeInfo`、pfUI 历史存储内容、未知色、链接载荷、战斗日志、字体／字号／
  行距、安全区、Tab／输入／未读几何、五张正式 TGA 像素与 SHA 以及其他
  pfUI 模块。

### Runtime contract v1.15 修正

- 有效实机结论：用户确认 v1.14 已加载，并在有新消息前后持续得到
  `chat-color=m2/h3/f3/c30/x5`。`h3/f3` 证明三个 Frame 都已装上 AEUI Hook
  和最终出口 wrapper；`m2` 则证明其中一个 Frame 在调用时被受管判断排除。
  新消息到达后 `c/x` 均不增长，说明当前可见“综合”窗口就是被排除的第三帧，
  因而 v1.14 未通过运行时门禁。
- 根因：pfUI `RefreshChat` 会统计各 Frame 的 `messageTypeList`；只要超过五个
  名称包含 `SPELL` 或 `COMBAT` 的消息类型，就设置 `frame.pfCombatLog=true`。
  这是用于布局／隐藏的启发式分类，不是稳定的显示所有权。频道较多的常规
  “综合”窗口也会命中。v1.14 虽按左书 Parent 安装了 Hook，却又在
  `IsMessagePaletteManaged` 中排除 `pfCombatLog`，形成“已挂钩但不转换”的
  精确旁路。
- 修正：
  - `IsMessagePaletteManaged` 只要求 AEUI Chat 启用且 Frame 当前 Parent 精确
    等于 `pfUI.chat.left`，不再把 `pfCombatLog` 启发式标记作为颜色门禁；
  - 左书内所有 Frame 共用同一语义墨色板，包括被 pfUI 标为战斗日志的窗口；
    Parent 不在左书的 Frame 仍完整回退 provider 输出；
  - 保留 pfUI 最终输出直桥、`HookAddMessage` 与 `ORG_AddMessage` 三层路径，
    不更改 pfUI 的战斗日志识别、隐藏、布局或消息路由逻辑；
  - runtime contract 升级至 `1.15`，强制现有 Frame 的版本标记重新装配。
- 静态证据：Chat smoke 把 `pfCombatLog=true` 且 Parent 为左书的 Frame 固定为
  必须转换，继续验证书外／禁用回退、链接与未知色保持；repository contract
  固定 `IsMessagePaletteManaged` 中不得重新加入 `pfCombatLog` 排除。Lua 语法、
  Chat／pfUI／Quest smoke、repository／quest design／asset workflow 契约均
  通过。
- 未改变：v1.12 色板数值、ChatMOD 源码／配置／SavedVariables、全局
  `ChatTypeInfo`、pfUI 的 `pfCombatLog` 分类及其其他用途、历史存储、消息内容、
  未知色、链接载荷、字体／字号／行距、安全区、Tab／输入／未读几何、五张
  正式 TGA 像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.16 修正

- 有效实机结论：v1.15 色板进入游戏后，用户反馈“各个频道／职业的颜色区别
  太小，很难一眼看出来”。这证明消息作用域与最终显示链已足以进入视觉审查，
  但 v1.12 起为了压制亮青／浅粉而采用的色板把多个频道、职业和品质压缩到
  少数接近黑褐的目标色，未通过扫读区分度门禁。
- 色板修正：
  - 七类基础语义分别使用：普通／公共 `#56211F`、系统 `#382D22`、警告
    `#721A17`、公会／正向 `#214513`、队伍 `#143E64`、密语 `#5C235A`、
    表情／强调 `#5D2C04`；时间戳使用独立深青 `#063F4A`；
  - 香草九职业改为九个唯一目标墨色：战士 `#4E3727`、圣骑士 `#6A2447`、
    猎人 `#1E430E`、盗贼 `#493B03`、牧师 `#40382F`、萨满 `#243A73`、
    法师 `#034254`、术士 `#49245F`、德鲁伊 `#672C03`；
  - 物品品质继续保留灰／绿／蓝／紫／橙／金色相，但复用相应可读墨色；链接、
    等级、自身高亮和通用 ChatMOD 色按同一扩展色域重新映射；
  - 优先扩大色相与彩度距离，只有限提升明度；所有通道仍处于深墨范围，不
    恢复原始满亮度颜色、描边、阴影或正文底色。
- 纸面对比审查：正式 `ChatBookFrameV3.tga` 三个阅读区采样框均值约为
  `RGB(204..206, 160..162, 83..86)`，取 `#CDA155` 为代表色；上述七类基础色
  与九职业色的 sRGB 静态对比约为 `4.5:1` 或更高。该数值是纹理上的确定性
  代理，实机仍以常用 UI Scale 下的扫读体验为最终门禁。
- 静态证据：Chat smoke 验证六种可用基础 `ChatTypeInfo` 样本互不合并、九职业
  精确映射且目标色全部唯一，并继续覆盖两种 ChatMOD 加载顺序、链接、未知色、
  `pfCombatLog` 左书作用域与禁用回退；repository contract 固定 runtime 版本、
  九职业源色和九个唯一目标色。Lua 语法、Chat／pfUI／Quest smoke、
  repository／quest design／asset workflow 契约均通过。
- 未改变：左书 Parent 作用域、pfUI 最终输出直桥与 Hook／ORG 两层兜底、
  ChatMOD 源码／配置／SavedVariables、全局 `ChatTypeInfo`、历史存储、消息内容、
  未知第三方色、链接载荷、字体／字号／行距、安全区、Tab／输入／未读几何、
  五张正式 TGA 像素与 SHA 以及其他 pfUI 模块。

### Runtime contract v1.17 修正

- 有效实机结论：v1.16 已让九职业目标值互不相同，但用户仍无法快速区分频道
  和职业，明确指出战士 `#4E3727` 与牧师 `#40382F` 都呈灰色。两色 CIE76
  距离约 `9.5`，因此“颜色唯一 + 纸面对比”不足以保证扫读区分度。
- 七类基础语义重排为：普通／公共 `#4B3321`、系统 `#383B42`、警告
  `#681821`、公会／正向 `#154710`、队伍 `#163C75`、密语 `#50206A`、
  表情／强调 `#682C00`；时间戳继续使用独立深青 `#063F4A`。
- 香草九职业重排为：战士 `#5C2525`、圣骑士 `#6C1F4C`、猎人 `#154710`、
  盗贼 `#473D00`、牧师 `#403A33`、萨满 `#163C75`、法师 `#004452`、
  术士 `#50206A`、德鲁伊 `#682C00`。战士改为明确铁锈红，牧师保留中性灰，
  不再落在相邻暖灰。
- 代表书页 `#CDA155` 上所有基础／职业目标色仍约为 `4.5:1` 或更高；CIE76
  最近距离由九职业 v1.16 的约 `9.5` 提升至约 `23.9`，七类基础最近距离约
  `21.9`。repository contract 同时锁定两组 RGB 最近距离 `>=35` 和逐色
  `>=4.5:1` 对比，避免未来只满足数值唯一。
- 未改变最终输出链、作用域、ChatMOD／pfUI 配置、消息字符串、链接、未知色、
  字体／字号／行距、书页资产或其他 pfUI 模块；旧历史行不会重绘。

### Runtime contract v1.18 修正

- 有效实机结论：v1.17 的任意色差优先策略使团队与小队都显示为钴蓝、战士
  偏成铁锈红，用户无法沿用原版颜色记忆；DPSMate 死亡报告注入的
  `#FF8080`／`#8CFF80` 又绕过未知色白名单，在书页上形成浅粉／浅绿亮字。
- 基础语义改为 Vanilla 默认 RGB 的等比例深色版本：说话 `#3D3D3D`、公共
  `#4D3939`、系统 `#404000`、公会 `#124712`、小队 `#3B3B59`、团队／战场
  `#623100`、密语 `#5A2D5A`、警告 `#751D1D`、表情 `#613118`。团队恢复
  焦橙，小队保留蓝紫，二者不再共用目标色。
- 九职业改为：战士 `#4B3B2A`、圣骑士 `#583243`、猎人 `#354224`、盗贼
  `#423F1B`、牧师 `#333333`、萨满 `#003D7A`、法师 `#22424E`、术士
  `#413959`、德鲁伊 `#633004`。除无彩牧师外，各目标与原始职业色的 HSV
  色相偏差不超过 `0.01` 圈；代表纸色上仍约为 `4.5:1` 或更高。
- 已审计时间戳、URL、品质色与 DPSMate 红／绿报告使用确定性保色相目标值；
  其他未知 `|cAARRGGBB` 由缓存的 sRGB 对比计算处理，低于 `4.8:1` 时只等比例
  压低 RGB，足够深则字节级保留。全部确定性目标色登记为终态，消息重复经过
  pfUI／ChatMOD 多层桥时不会被二次压暗。转换只改显示颜色前缀，不解析或
  重建链接。
- 未改变最终输出链、左书 Parent 作用域、ChatMOD／pfUI 配置、消息／链接载荷、
  Alpha、字体／字号／行距、书页资产、历史或其他 pfUI 模块；旧历史行不重绘。

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
- v1.14 已由用户通过 `/aeui status` 确认加载，但固定计数
  `m2/h3/f3/c30/x5` 证明可见 Frame 被 `pfCombatLog` 启发式排除，未通过
  颜色运行时门禁。v1.15 修复作用域后已进入实机颜色审查，但因频道／职业
  区分度不足被用户退回。v1.16 也因战士／牧师发灰和频道扫读不足被用户退回；
  v1.18 随后取代已被实机退回的 v1.17；该结论现已由 Full V1 contract
  v1.19 取代。下一次具备游戏设备时必须让实际 AddOn 目录加载当前仓库并
  `/reload`，以 `/aeui status` 的 `chat-runtime=1.21` 与
  `chat-color=classic-provider` 为加载证据；任何 AEUI 消息颜色 wrapper 或
  计数都不应再出现。
  尚无 v1.19 实机通过结论。

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
- 2026-07-31 v1.7：用户报告 Tab 与正文仍在但书本主体消失。新增书本
  Texture／版本自愈以及模块 Initialize／Apply 失败隔离；Lua 语法、
  Chat smoke 与隔离断言通过，等待 `/reload` 实机复测。
- 2026-08-01 v1.8：用户确认中文正文行距过小并授权执行。主客户端配置证据
  为字号 `12`、区域字体、`OUTLINE`、局部缩放 `1.1`，而 runtime 未设置
  spacing；现只对受管左框写入 `2px` 行距。Chat smoke 覆盖 pfUI 重置与
  无 `GetSpacing` 的兼容路径，等待 `/reload` 实机复测。
- 2026-08-01 v1.9：用户复测后确认聊天框仍令人眼睛疲劳，并要求直接实施
  舒适阅读方案。受管正文现使用 Noto Sans SC Medium、无全描边的单向深棕
  阴影、`3px` 行距与正文安全区连续暖色压光层；不改频道色、消息字符串或
  用户字号，静态 smoke 已覆盖 pfUI 重置恢复，等待 `/reload` 实机复测。
- 2026-08-01 v1.10：用户实机确认公共频道浅粉正文仍过淡，正文安全区压光
  形成可见矩形并要求恢复旧字体。现已停用压光层、恢复 pfUI 配置字体，并只
  在受管显示入口把公共频道基础 RGB 映射为深酒红；不写全局频道色或消息
  字符串，等待 `/reload` 后以新公共频道消息复测。
- 2026-08-01 v1.11：v1.10 实机截图显示旧字体叠加 `(1,-1)` 投影后出现大面积
  重影。按用户要求将受管正文阴影改为透明、零偏移；旧字体、无描边、`3px`
  行距、深酒红公共频道基础色和无压光书页均保持。
- 2026-08-01 v1.12：用户确认重影已解决并要求修正全部文本颜色，补充聊天增强
  provider 为 ChatMOD，随后明确要求直接实施、不经过 Figma。审计 ChatMOD
  1.1 源码与当前配置后，受管最终显示链加入基础消息语义色和精确内嵌色白名单；
  未知色、链接、战斗日志、外部插件文件／配置与全局颜色表保持原样。实机截图
  随后证明该 wrapper 位于 ChatMOD 实际注色之前，v1.12 未通过运行时门禁。
- 2026-08-01 v1.13：针对“看不清”截图复现真实加载链；保留 v1.12 色板并增加
  ChatMOD `ORG_AddMessage` 最终出口幂等 wrapper，现有维护节拍负责发现晚出现
  的出口。两种相反加载顺序 smoke 均通过；用户确认 v1.13 已加载后，实机
  新消息仍保持原始亮色，因此该版本未通过门禁。
- 2026-08-01 v1.14：移除 `S_AddMessage` 函数身份与 `isDocked` 门禁，以左框
  Parent 作为作用域；在 pfUI Chat 最终输出加入直接色板桥，保留 Hook／ORG
  两层兜底，并通过 `/aeui status` 暴露调用与变更计数。用户实机固定得到
  `m2/h3/f3/c30/x5`，证明第三个已挂钩 Frame 被作用域排除，版本未通过门禁。
- 2026-08-01 v1.15：根据 v1.14 计数移除 `pfCombatLog` 启发式颜色排除；左书
  Parent 成为唯一显示作用域。完整静态回归通过；实机进入颜色审查后，用户
  退回频道／职业区分度。
- 2026-08-01 v1.16：在左书作用域和三层输出链不变的前提下，重排七类基础
  语义、时间戳、九职业与品质色；正式书页采样代理下保持约 `4.5:1` 对比，
  Chat smoke 固定频道互异和九职业一对一。完整静态回归通过，但实机仍因
  战士／牧师发灰和频道区分不足被退回。
- 2026-08-01 v1.17：按色相优先重排基础／职业墨色，战士改铁锈红、牧师改
  中性灰；增加最近色 RGB 距离与纸面对比机器门禁。完整静态回归通过，等待
  实机重载；随后被“插件色仍过亮、团队／小队同色、偏离原版识别色”的实机
  反馈退回。
- 2026-08-01 v1.18：频道与职业改为 Vanilla 原色相的等比例深墨版本；小队／
  团队拆分；DPSMate 常用亮色加入确定性映射，未知亮色增加 `4.8:1` 连续压暗，
  深色自定义值与链接载荷保持；修复多层桥对确定性目标色二次压暗的幂等性
  缺口。Lua 语法、Chat／pfUI／Quest smoke、repository／quest design／asset
  workflow 契约全部通过，等待实机重载。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一门禁 |
|---|---|---|---|
| `CHAT.FRAME.FULL.V1.r1` attempt 2 | 固定 session／result、精确 source SHA、最终 TGA、五场景真实排版与 display-region 报告、source／runtime manifests | `runtime-exported / P5`；实际 ImageGen 仍为 `2/5`，导出阶段 `0` 次，余量终止 | Turtle WoW 实机 P6；不得直接加载完整 source |
| V3 runtime contract v1 | source／runtime manifests、五张 TGA、Lua 与 tests | `runtime-exported / P5` | Turtle WoW 实机验证 |
| V3 runtime contract v1.1 | exporter 重放；事件后 Tab 重排与受管 Region 静态测试 | 未获得有效独立实机加载，已由 v1.2 取代 | 改为紧凑纵向合同 |
| V3 runtime contract v1.2 | 用户否决原始 `42px`；`30px` Tab、`16px` 承托带、`32px` 正文上沿；目标目录哈希核验；有效游戏加载 | 点击后几何正确；启动时序、选中文字和命中范围失败，保持 `P5` | 修正初始化、对比度与命中区 |
| V3 runtime contract v1.3 | 登录后单次终局装配；亮暖金 selected 文字；底部命中区扩展 `8px`；runtime 版本自报；有效实机截图 | TabText 未居中；交互后正文退回 pfUI 默认安全区，保持 `P5` | 接管文字锚点与所有已知布局事件 |
| V3 runtime contract v1.4 | TabText 中心合同；pfUI Refresh／选择／停靠后按需恢复完整几何；拖动锁后单次恢复；runtime 版本自报；有效缩放实机反馈 | 缩放后逻辑尺寸未变，条件恢复跳过实际重放；点击后才刷新，保持 `P5` | 为 UI Scale 增加一次强制定型 |
| V3 runtime contract v1.5 | `UI_SCALE_CHANGED` force 标志；连续事件合并；延迟单次全几何重放；force 自动清除；缓存场景 smoke；有效实机反馈 | 未覆盖 pfUI owner 局部缩放入口；实机仍需点击一次 Tab，失败并保持 `P5` | 挂接真实 `pfChatLeft.OnMove` 缩放链 |
| V3 runtime contract v1.6 | owner Scale／EffectiveScale 边沿检测；`pfChatLeft.OnMove` 后置单次强制重放；全局无事件兜底；普通移动零几何写入 smoke；完整静态测试与目标目录哈希核验 | `runtime-corrected / P5`，已部署到测试客户端 | `/reload` 后分别测试 pfUI 局部 Scale 与全局 UI Scale，全程不点击 Tab |
| V3 runtime contract v1.7 | 书本中心片／承托带／贴图／版本自愈；BACKGROUND 恢复；Bootstrap 逐模块失败隔离；Chat smoke 与 Lua 语法 | `runtime-corrected / P5`，Junction 已指向当前工作树但尚未重载验证 | `/reload` 确认书本主体恢复并记录任何单次模块错误 |
| V3 runtime contract v1.8 | 受管 `ChatFrameN` 使用 `2px SetSpacing`；字号／pfUI 重置恢复；无 `GetSpacing` 兼容；不改用户字号、字体或频道色 | `runtime-corrected / P5`，静态测试通过 | `/reload` 确认 `chat-runtime=1.8` 与中文行距，同时复测书本主体 |
| V3 runtime contract v1.9 | 受管 `ChatFrameN` 使用 Noto Sans SC Medium、空 font flags、单向深棕阴影、`3px SetSpacing` 与安全区 `10%` 暖色压光；无 `GetFont`／`GetSpacing` 兼容；不改用户字号、频道色或消息字符串 | `runtime-corrected / P5`，Chat smoke 通过 | `/reload` 确认 `chat-runtime=1.9`、连续阅读舒适度与各频道语义辨识度 |
| V3 runtime contract v1.10 | 停用安全区压光；恢复 pfUI 配置字体；受管 `HookAddMessage` 仅把 `ChatTypeInfo.CHANNEL` 基础 RGB 映射为 `0.36,0.16,0.14`；不写全局颜色或消息字符串 | `runtime-corrected / P5`，完整静态测试通过 | `/reload` 确认 `chat-runtime=1.10`，以新公共频道消息验证墨色和语义色 |
| V3 runtime contract v1.11 | 受管 `ChatFrameN` 使用透明阴影色与零偏移；保留旧字体、无描边、`3px` 行距、公共频道深酒红与无压光书页 | `runtime-corrected / P5`，完整静态测试通过 | `/reload` 确认 `chat-runtime=1.11` 与正文无重影 |
| V3 runtime contract v1.12 | ChatMOD 1.1／pfUI／原生颜色审计；七类基础语义墨色；时间戳、职业、等级、物品品质、URL、自身高亮精确内嵌色白名单；有效实机截图 | wrapper 位于 ChatMOD 实际注色之前，截图仍为原始亮色；`runtime-failed / P5` | 接管 ChatMOD 的真实最终出口 |
| V3 runtime contract v1.13 | 共享幂等色板转换；pfUI `HookAddMessage` 与 ChatMOD `ORG_AddMessage` 双出口；晚出现 hook 发现；两种相反加载顺序 smoke；有效重启截图 | 用户确认 runtime 正确但新消息仍为原始亮色；`runtime-failed / P5` | 移除脆弱身份／停靠门禁，并建立 pfUI 直接桥 |
| V3 runtime contract v1.14 | Parent 作用域；无身份门禁 ORG wrapper；pfUI Chat 最终输出直桥；显式十六进制 pattern；运行时调用／变更计数；有效实机计数 | `m2/h3/f3/c30/x5` 固定不变；第三个可见 Frame 被启发式排除，`runtime-failed / P5` | 移除 `pfCombatLog` 颜色门禁 |
| V3 runtime contract v1.15 | 左书 Parent 唯一作用域；`pfCombatLog` 启发式不再排除；书外 Frame 回退；版本与回归断言更新；有效实机颜色反馈 | 色板已进入视觉审查，但频道／职业目标色过度压缩；`runtime-failed / P5` | 扩大语义与职业色差，同时保持深墨感 |
| V3 runtime contract v1.16 | 七类基础语义互异；时间戳独立深青；九职业一对一；代表纸色上约 `4.5:1` 静态对比；有效实机反馈 | 战士／牧师仍发灰且频道扫读不足；`runtime-failed / P5` | 增加最近色距离门禁并按色相优先重排 |
| V3 runtime contract v1.17 | 七类基础与九职业按色相优先重排；战士铁锈红／牧师中性灰；RGB 最近距离 `>=35`；代表纸色对比 `>=4.5:1` | `runtime-corrected / P5`，完整静态测试通过 | `/reload` 确认 `chat-runtime=1.17`，重点比较战士／牧师及世界／系统／警告 |
| V3 runtime contract v1.18 | Vanilla 原色相等比例深墨；团队焦橙／小队蓝紫分色；DPSMate 与未知亮色保色相压暗；多层桥终态幂等；链接载荷不变 | `runtime-corrected / P5`，完整静态回归通过 | `/reload` 确认 `chat-runtime=1.18`，重点比较团队／小队、职业原色识别与 DPSMate 红绿报告 |
| Full V1 runtime contract v1.19 | 新暖黑主框九宫格；V3 交互邻件；Vanilla 暖黑纸面色板；低对比色最小提亮；五场景最终 TGA 门禁 | `runtime-exported / P5`，静态回归与 display-region 通过；整体版本已由 v1.20 取代 | 随 v1.20 一并实机验证书框、频道／职业色、Tab、缩放与右框消息回收 |
| Dark Input runtime contract v1.20 | 固定 P4 source 确定性导出；normal／focus 共同 Alpha；三段 UV 与 EditBox 行为不变；五场景最终 TGA 门禁 | `runtime-exported / P5`，静态回归与 display-region 通过 | `/reload` 确认 `chat-runtime=1.20`、输入 normal／focus、文字、光标、IME、历史与键盘行为 |
| Classic color runtime contract v1.21 | 输入与书框资源不变；移除 AEUI 色板、对比度适配、pfUI 直桥及 ChatMOD／Frame wrapper；基础 RGB、内嵌色、Alpha 和链接载荷完全透传 | `runtime-corrected / P5`，静态回归与既有 display-region 几何合同待重放 | `/reload` 确认 `chat-runtime=1.21`、`chat-color=classic-provider`，并比较经典频道／职业／物品／插件色 |

## `CHAT.INPUT.DARK.V1` 暖烟草抄写纸条

### 当前合同与权威边界

- 用户反馈：Full V1 暖黑书体接入后，原 V3 浅金输入纸带在书页下沿形成过亮
  横条，容易被读成现代进度条；输入背景与正文底色关系需要重做。
- 已确认模拟：`CHAT.INPUT.DARK.V1-SIM`；当前操作：`accept`；生产版本：
  `CHAT.INPUT.DARK.V1.r3 attempt 4`；子状态：`source-accepted / P4`。用户于
  `2026-08-03` 先明确接受模拟方向，随后独立授权完整生产版本、固定参考、
  `0/5` 初始预算和循环内 edit 边界。attempt 1／2／3 已调用并计为 `3/5`；
  attempt 3 证明连续 edit 被错误表面锚定，因此 attempt 4 不使用 Image 4，
  只用固定 Image 1／2／3 从零重生成。该候选已完整内审通过并停止循环；用户
  于 `2026-08-03` 接受精确版本进入 `P4`，透明归一源与 manifest 已入库。尚未
  导出 TGA 或修改 Lua。
- 现行正式 runtime 继续是 `ChatInputAtlasV3.tga`／`P5`。本模拟没有否定其
  normal／focus 状态、三段 UV 或功能，只为替换未来可见像素建立方向门禁。
- provider：`pfUI.chat.editbox` 与 `ChatFrameEditBox`；adapter 精确几何为
  owner 左右各 `30px`、底部 `6px`、高 `25px`，最小书框下输入实例
  `380 × 25px`，`540 × 420` 书框下为 `480 × 25px`；文字 inset 为
  `34/22/0/0px`。
- 保留功能：输入激活、普通／聚焦状态、光标、IME、AltArrowKey、输入历史、
  频道头、文字与键盘事件全部由现有 EditBox 动态承担。位图不得包含文字、
  光标、频道名、图标、语言按钮或命中逻辑。
- 状态与粒度：恰为 normal／focus 两个独立无字状态；两者外接 silhouette、
  Alpha、左右端帽、切线和 runtime 点击几何相同。每态由左 `28px` cap、安静
  横向伸缩中段、右 `20px` cap 构成；状态变化只改变材料综合色重。
- Prompt provenance：当前稳定条款为 [`ART_BASELINE.md`](../ART_BASELINE.md)、
  [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md)、
  [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)；历史输入原文为 Git
  `73da6c5:prompts/chat/聊天框模块化资源_执行提示词_v3.md`。本轮已完整读取并
  解析该来源，没有用摘要代替锁定正文。
- 冲突审计：旧稳定 `CHAT.INPUT` 条款把输入定义为浅纸带，且 V3 source 已进入
  P4/P5；用户最新反馈只否决它与暖黑 Full V1 的综合色关系。模拟方向确认后，
  `ART_BASELINE.md` 与 `SUBMODULE_ART_BASELINES.md` 已收敛为暖烟草抄写纸条；
  旧 V3 source 仍是现行正式回退和结构参考，不伪称失效。新候选现已完成用户
  source 接受；只有再通过确定性导出、最终 TGA 真实排版与静态门禁后，才允许
  替换正式 TGA 或修改 Lua 媒体映射。

### 美术继承与组件级转译

- 继承全局／Chat 的 2004 年 Vanilla 手绘位图语言、厚重实体材料、左上暖光、
  低饱和烟褐与不规则磨损；只借用《上古卷轴 5》式暖黑／烟草综合色感，不
  借用其极简菜单、细线框或无材质扁平排版。
- 输入首先读作从战地日志页叠下沿夹入的一张狭长抄写纸条：两至三层薄页叠、
  轻微毛边、短折页、低频烟熏和一条断续墨迹书写导线。它是书页的一部分，
  不是独立面板、搜索框、胶囊按钮或皮革仪表盘。
- 普通态纸面代理 `#403024`，页叠更深；聚焦态纸面代理 `#503A25`，只增加
  局部短暖光、墨迹加深与轻微前移感，不整体变成亮黄。普通／聚焦动态文字
  代理分别为 `#D0BE9A`／`#E1D0AA`，对各自纸面静态对比约
  `6.910:1`／`6.997:1`。
- 相对于正文代理 `#30241B`，普通／聚焦纸面只形成约 `1.195:1`／`1.416:1`
  的低明度分层；识别依靠页叠和接触暗部，不靠一圈完整亮边。不得出现
  full-width 高光、发光、金色滚动条、规则矩形描边或填充进度语义。

### 本地几何模拟与真实装配

- specification：
  [`chat_input_dark_simulation_v1.json`](../../../../tools/specs/chat_input_dark_simulation_v1.json)，
  SHA-256 `3471f4d4bca0f987210f266046e7c85001b53c4e4522182646133486964d230e`。
- renderer：
  [`render_chat_input_dark_simulation_v1.py`](../../../../tools/render_chat_input_dark_simulation_v1.py)，
  SHA-256 `ca90aa5ecba7ddc198f67758d74c1ec8c09dc17a06e70481e8cad6f957c078b4`。
- Python 环境：`Darwin`；
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`；`3.12.12`。
- renderer 先以纯本地几何生成 `1024 × 256` 两行逻辑 atlas，沿用正式切线
  `x=8/121/932/1016`，再按 `28px / stretch / 20px` 三段装配到真实输入区。
  normal／focus 两行使用同一 Alpha mask，运行时 silhouette 字节级相同。
- 游戏内预演：
  `generated/chat/core/CHAT.INPUT.DARK.V1/simulation/CHAT_INPUT_DARK_V1_game_layout.png`，
  `1500 × 870 RGBA`，SHA-256
  `b974cafacc6b8e58ff385514af8512338cedf7392b0283865200f1af7b74b8cc`。
  一格使用正式 V3 聚焦输入作对照；其余五格为候选空内容／普通、最小／聚焦、
  典型 15 行、最大 16 行和 `540 × 420`／22 行。书框、Tab、承托带与消息排版
  均读取当前 tracked runtime；只有候选输入条为本地几何。动态文字和光标只
  存在于预演，不进入逻辑 atlas。
- 逻辑 atlas：
  `generated/chat/core/CHAT.INPUT.DARK.V1/simulation/CHAT_INPUT_DARK_V1_logical_atlas.png`，
  SHA-256 `d7f3b27a0d92b32cc3d81184724fa9f4af6029904a671fe3c296d0cdedeb1523`。
- metrics：
  `generated/chat/core/CHAT.INPUT.DARK.V1/simulation/CHAT_INPUT_DARK_V1.metrics.json`，
  SHA-256 `72346477273fc94c878604822435b8d7a110fc0f4529c86b7b3ecebce1e7297c`；
  normal／focus Alpha 相同，所有消息场景 `truncated=0`。同一命令确定性复跑后
  预演、atlas 与 metrics 三个 SHA 均未变化。
- 展示区域合同：
  [`chat_input_dark_display_region_v1.json`](../../../../tools/specs/chat_input_dark_display_region_v1.json)，
  SHA-256 `753d7eda10f5fb6f834228e3dd1ec2b6dc6c8fc0d46a724e1114f77c88759cdc`。
  报告
  `generated/chat/core/CHAT.INPUT.DARK.V1/simulation/display-region-report.json`，
  SHA-256 `6d495afa5d7911f6b7e04ddeb0ea7ea05380f5a45a7bf389344440f6322fed0c`；
  empty、minimum、typical、maximum、expanded 五场景全部 `pass`，violations
  `0`，first failure `null`。
- ImageGen `0/0`；上传 `0`；所有 `generated/` 输出由 scoped `.gitignore`
  排除，不是跨设备 source、runtime 或生产参考。用户确认方向后，持久事实仍
  以本 work、spec 和 renderer 为准。

| 本地流程错误 | 可观察错误 | 修复 | ImageGen 计数 |
|---:|---|---|---:|
| `SE1` | 初版 focus 内部半透明短光改变了局部 Alpha，严格状态几何断言中止 renderer | 候选两态绘色完成后复用 normal Alpha mask，保持反馈只改 RGB／综合色重 | `0` |
| `SE2` | 一次临时 `python -c` 对比度命令把函数定义写在分号后，触发 `SyntaxError` | 改为只读导入仓库既有 contrast helper；不影响 renderer、输出或合同 | `0` |

### 内部审查与当前门禁

- 对象／语义：通过。恰为一个 EditBox 的两状态背景；无文字烘焙、假按钮、
  状态图标或额外 Frame。
- 物理／图层：通过模拟门禁。纸条位于正文纸面之上、下沿页叠之内；普通态
  后退，聚焦态仅轻抬。没有外加书框、透明黑块或现代矩形容器。
- 真实密度／伸缩：通过。`380 × 25` 与 `480 × 25` 共享固定端帽，中段没有
  不可拉伸装饰；15／16／22 行消息不侵入输入区，输入文字保持在
  `34/22px` inset 内。
- 综合色重：比现行 V3 明显收敛，不再形成亮金横条；普通态接近正文书页，
  聚焦态仍可识别。模拟的折页、纤维、烟熏与毛边只是几何占位，不能作为最终
  笔触或生产像素。
- 刻意未验证：真实手绘材料、Alpha 毛边、ImageGen 对两态同构的服从度、
  最终 atlas 色键清理、TGA 采样和 Turtle WoW 输入焦点／IME／历史。前四项
  属正式生产／P4→P5；最后一项仍属于 P6。
- 内部结论：`displayable / simulation-confirmed`。用户于 `2026-08-03` 接受
  `CHAT.INPUT.DARK.V1-SIM`；下一门禁改为具体生产正文、上传范围、不可变修复
  边界与最多五次实际 ImageGen 调用的独立授权。

### 用户方向结论

- 具体模拟版本：`CHAT.INPUT.DARK.V1-SIM`。
- 用户结论与日期：`confirmed / 2026-08-03`；用户原文：
  “接受 `CHAT.INPUT.DARK.V1-SIM`”。
- 布局：输入仍在现有 Chat 书页下沿，不增加新 Frame、外框、按钮或高度；
  `380 × 25px` 最小实例与 `480 × 25px` 扩展实例保持。
- 物件与材质层级：首先读作夹入页叠的狭长抄写纸条；两至三层薄烟熏纸优先，
  接触暗部与小型折页其次，皮革／线结仅能作为端部微量固定，黄铜可省略。
- 轮廓：normal／focus 共用同一狭长、不规则但克制的纸条轮廓；固定端帽承担
  撕口、折页和线结，中段保持安静可拉伸。
- 配色：normal 以 `#403024` 附近的暖烟草色后退，focus 保持深色并只向
  `#503A25` 附近轻抬；禁止回到浅金纸、纯黑玻璃或高饱和亮边。
- 视觉重量与整合：输入条明显比旧 V3 浅金纸带安静，接近正文暖黑纸面但仍由
  页叠厚度和接触阴影辨认；它属于 Full V1 同一本战地旧书，不像叠在书上的
  现代进度条、搜索框或平板。
- 状态观感：normal 后退；focus 只增加墨线深度、一至两处短烛暖反光、轻微
  材质前移与接触暗部，不移动、不缩放、不整体发黄或发光。
- 仍未确认：真实手绘笔触、生产 Alpha、两态像素同构、色键清理、最终 atlas、
  TGA 采样与游戏交互；模拟像素仍禁止成为 source、runtime 或生产输入。
- 确认失效条件：改变输入所在位置／高度、纸条物件隐喻、两态数量、暖烟草
  配色极性、综合色重、Full V1 整合关系或三段式 runtime 几何时，必须回到
  新的本地模拟版本。只改变不影响可见构图的透明提取与确定性切片无需重做。

### 正式生产合同（`CHAT.INPUT.DARK.V1`，已授权）

- 固定执行器只允许 `imagegen-0-143-0`／`@openai/codex@0.143.0`；操作为
  `generate/edit`。用户已于 `2026-08-03` 开启本版本最多五次实际调用的预算；
  当前实际 ImageGen 为 `4/5`、流程错误 `4`。
- provider raw 画布固定为 `1536 × 1024 RGBA`，背景必须为完全平坦的
  `#00FF00`。对象恰为两条无字纸条：normal 固定 source cell
  `[51,187,1437,363]`，focus 固定 source cell `[51,448,1437,625]`；坐标为
  左上原点、右下排他。每格为 `1386 × 176px`，完整对象和至少 `8px` 透明／
  色键安全边距必须落在各自格内；格外不得出现第三对象或可见散件。
- 确定性候选处理只允许使用本次 raw 自身像素：从两个固定 cell 分别提取完整
  对象，清除绿色背景，按各自外接框等比例归一到同一 `1386 × 176px` cell，
  不复制 simulation、旧 V3 或 Full V1 像素。对齐后以两态 Alpha 的逐像素
  最小值建立共同 Alpha，透明像素 RGB 清零；若该处理会切掉重要页层、端部
  结构或使两态视觉不一致，则候选直接失败，不以修补像素掩盖。
- 透明 source 仍固定为 `1536 × 1024 RGBA` 及上述两格。未来 deterministic
  exporter 从两格各缩放到 `1008 × 120px`，写入 `1024 × 256` atlas：normal
  `[8,4,1016,124]`，focus `[8,132,1016,252]`；横向切线固定为
  `x=8/121/932/1016`。运行时仍使用左 `28px` cap、安静 stretch 中段和右
  `20px` cap，不改变 EditBox `380/480 × 25px`、`34/22px` 文字 inset 或
  normal／focus 交互所有权。
- 固定上传参考与职责已经由用户按路径、顺序和 SHA 授权：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
    最高的 Vanilla 年代、HUD 紧凑尺度、游戏内物件身份和综合色重权威；
  - Image 2：`assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png`，
    SHA-256 `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673`；
    只承担当前同一本书的直接纸／页叠／皮革材料、暖黑烟草配色、磨损尺度、
    左上光向和接触关系；从属于 Image 1 与书面基线；
  - Image 3：`assets/source/chat/v3/ChatControls_Master_v3.png`，SHA-256
    `de0e5c66753ab59be1448f75f0843b37265c98f104381f3529314f494ac52968`；
    只承担输入物件身份、normal／focus 两态数量、狭长比例与端部细节尺度；
    不继承浅金色、退役第三字段、未读标记或任何旧像素。
- 本地 simulation PNG、logical atlas、metrics、current runtime preview、任何
  rejected candidate 和未列出的仓库图均禁止上传或作为 ImageGen 输入。

### 生产正文完整性预检

- 复杂度：`states + assembly/stretch + atlas`。
- 结论：`pass / production-ready / prompt-authorized`。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | `OUTPUT OBJECTS AND OWNERSHIP` 固定两条无字纸条，并排除文字、光标、频道头、按钮、未读和第三字段 | pass |
| 三张输入图的 inherit／ignore 职责与权威冲突 | `AUTHORITY ORDER` 以书面基线和锁定 Image 1 为最高，Image 2 仅材料连续，Image 3 仅结构且显式排除旧色／旧对象 | pass |
| 画布、格位、边距、方向、尺度、光照与层序 | `EXACT SHEET LAYOUT` 固定 `1536 × 1024`、两格坐标、`8px` 安全边距、正交正视与左上暖光 | pass |
| 逐对象形态、材料、边缘、状态与关系 | `PHYSICAL ANATOMY` 与 `STATE CONTRACT` 定义页层、端部、中段、normal／focus 差异和同构关系 | pass |
| 文字安全区、裁切、拉伸、重复与接缝 | `RUNTIME ASSEMBLY` 固定 `380/480 × 25`、`34/22px`、`28/20px` cap、source／atlas 格与切线 | pass |
| 美术 DNA、具体反模式、Alpha／色键与最终自检 | `LOCKED ART DNA`、`FORBIDDEN READS`、`ALPHA` 与 `FINAL SELF-CHECK` 覆盖 | pass |

- 未知但执行必需的值：无。provider session／result 只在实际执行后记录，不是
  生成合同输入。
- 去冗余结论：只重复“两对象同构、纸张优先、安静中段、非进度条、精确格位、
  色键和动态内容排除”等高风险门禁；provenance 日期与历史过程留在 work。

### 不可变自主修复边界（已授权）

- 固定组件与对象：仅 `CHAT.INPUT`；normal／focus 两个无字状态，顺序不变。
- 固定权威与输入：上述 Image 1／2／3 的路径、SHA、顺序和职责不变；首次为
  generate。attempt 2–5 只允许在同一循环内把紧邻前次输出作为 Image 4 edit
  输入，且 Image 1／2／3 仍同时固定；若没有明确可保留区域，则只用固定三图
  regenerate。禁止加入 simulation、旧失败稿或其他 reference。
- 固定可见方向：夹入 Full V1 下沿页叠的暖烟草抄写纸条、纸张优先、normal
  后退、focus 深色轻抬、安静 stretch 中段、无现代输入框／进度条。
- 固定技术合同：`1536 × 1024`、两个 source cell、共同 Alpha、透明 RGB
  清零、`1024 × 256` atlas、两行位置、切线、`28/20px` cap、`380/480 × 25px`
  运行时实例及 `34/22px` inset 全部不变。
- 允许自主修复：只针对本次首个失败门禁强化同一正文中的对象分离、两态同构、
  页层物理、材料综合色重、端帽细节位置、中段安静度、色键纯净度或禁止项；
  每次必须形成完整自包含 `.rN` 正文并在调用前提交。不得以旧图合成、手绘新
  像素或改变合同来挽救候选。
- 预算：最多 `5` 次实际 ImageGen generation／edit，含首次。只有返回图像或
  provider result 等直接生成证据才计数；流程错误不计数，但同一错误经一次
  针对性修复后再次出现必须暂停。任一候选完整内审通过后立即停止。
- 必须重新授权：新增或替换任何上传、改变对象／状态数量、画布／格位、runtime
  几何、物件隐喻、综合色极性、Alpha 策略、允许的 edit 输入或禁止项。

### 完整生产正文（`CHAT.INPUT.DARK.V1`，已授权；attempt 1 原样执行）

```text
Create one production-ready bitmap sprite source for CHAT.INPUT in a World of
Warcraft 1.18.1 Turtle WoW interface overhaul. This is a 2004-era Vanilla MMORPG
HUD asset, not a modern fantasy-game overlay.

LOCKED ART DNA
The written direction in this prompt is the governing project baseline. Preserve
the hand-painted Vanilla bitmap language, compact in-game scale, tangible page
thickness, slightly irregular but functional silhouette, warm upper-left light,
low-saturation warm-black and smoked-tobacco palette, deep-walnut shadows,
restrained oxidized-brass range, non-mirrored wear, and the heavy feeling of a
battlefield journal carried through a long Azeroth expedition. The dark tobacco
gravity may evoke an Elder Scrolls V journey, but never copy its minimalist menu
language, floating typography, thin rules, or flat overlays.

OUTPUT OBJECTS AND OWNERSHIP
Produce exactly two complete, separate, text-free horizontal writing slips on
one sheet, in this order:
1. NORMAL chat-input background.
2. FOCUS chat-input background.

These are only the two bitmap backgrounds of one runtime EditBox. Do not include
any third object, retired status field, unread seal, button, icon, label, cursor,
channel name, example text, language control, input history, hit area, book
frame, neighboring UI, contact-sheet frame, caption, number, or crop guide.
All live text, channel headers, caret, IME, focus, history, and keyboard behavior
remain runtime-owned and must not be baked into either object.

AUTHORITY ORDER AND IMAGE RESPONSIBILITIES
Image 1 is the highest supplied visual authority for Vanilla-era HUD identity,
compact scale, battlefield-journal character, and overall visual weight. Use it
to judge whether the object belongs in the same old Azeroth interface. Do not
copy its whole game scene or any neighboring controls.

Image 2 is a subordinate direct material-continuity reference for the currently
accepted warm-black chat book. Match its smoked paper, visible page-stack depth,
deep-walnut leather relation, wear scale, restrained brass range, contact
shadows, and warm upper-left light so the slips physically belong to that exact
book. Do not copy the complete frame or bake any of its surrounding pixels.

Image 3 is structure-only authority for the compact input-object identity, the
NORMAL/FOCUS count, long shallow proportion, and scale of small asymmetric end
details. Ignore its bright yellow parchment, retired third field, unread marker,
old color balance, background, and every old pixel. The written baseline and
Image 1 override any modern, bright, or conflicting read in Images 2 or 3.

EXACT SHEET LAYOUT
The provider canvas must be exactly 1536 by 1024 pixels, orthographic and
front-facing, with no perspective. Fill every non-object pixel with perfectly
flat chroma-key green #00FF00.

Place the complete NORMAL object only inside the upper source cell whose bounds
are x=51..1437 and y=187..363. Place the complete FOCUS object only inside the
lower source cell whose bounds are x=51..1437 and y=448..625. Coordinates use a
top-left origin and exclusive right/bottom bounds. Each cell is 1386 by 176
pixels. Keep at least 8 pixels of clean #00FF00 around every visible edge inside
each cell. Each visible object should occupy about 1320 to 1362 pixels in width
and 136 to 160 pixels in height. Give both objects the same apparent bounds,
horizontal baseline, source aspect, and transparent padding. Leave the large
space between and outside the cells completely empty green. Do not draw the cell
boundaries, rulers, labels, swatches, shadows, floor, vignette, or scene.

PHYSICAL ANATOMY AND Z-ORDER
Each state must read first as one narrow writing slip inserted into the lower
page stack of a battered field journal, never as a detached UI panel. Build it
from two or three shallow layers of smoked tobacco paper:
- one calm upper writing leaf;
- one slightly darker exposed page layer below it;
- a restrained deckled edge with a few broad, hand-painted irregularities;
- a soft, physically attached contact shadow where the slip tucks into the book;
- at most one small asymmetric folded or tucked paper end.

Paper is the primary material and page thickness must be visible before any
leather or metal. A tiny thread or leather tuck may appear only inside one fixed
end zone. Brass is optional and, if present, must remain below two percent of the
visible object. No decoration may pin down, encircle, or visually seal the whole
slip. All layers share the same front view, light direction, thickness scale,
and insertion logic.

STRETCHABLE CENTER AND FIXED ENDS
The long middle must be calm, low-frequency, horizontally stretchable, and safe
for live Chinese or English input text. Use only subtle irregular fibers, broad
smoked absorption, and a broken dark-brown writing guide. Never use a continuous
full-width rule. Keep every distinctive fold, tear, stitch, knot, thread, curl,
brass speck, vertical seam, strong stain, and short highlight inside the fixed
source end zones: left x=51..207 and right x=1321..1437 within each state cell.
The center x=207..1321 must contain no unique feature whose stretching would be
visible and no high-contrast feature behind live text.

STATE CONTRACT
NORMAL and FOCUS must share the same outer silhouette, Alpha shape, visible
bounds, baseline, page-layer anatomy, left end, stretchable center, right end,
and padding. Do not add, remove, move, lengthen, or curl a page layer between
states. A state change must never imply movement or resizing of the EditBox.

NORMAL is recessed and quiet: smoked tobacco paper around #403024, deeper page
layers, a subtle broken ink guide, and restrained edge catches. It should settle
close to the warm-black reading page while remaining recognizable through page
thickness and contact shadow.

FOCUS remains dark, around #503A25. Change only material response: a mild local
lift, a slightly deeper ink guide, one or two short candle-warm catches confined
to fixed end zones, and a slightly stronger contact shadow. Do not brighten the
whole strip, turn it yellow, add a halo, create a complete outline, or introduce
a new silhouette feature.

RUNTIME ASSEMBLY AND SAFE AREA
The source cells will be deterministically resized to two 1008 by 120 pixel
objects and placed in a 1024 by 256 runtime atlas at:
- NORMAL: x=8..1016, y=4..124;
- FOCUS: x=8..1016, y=132..252.

The fixed atlas x cuts are 8, 121, 932, and 1016. Runtime assembly uses a 28
pixel left cap, a horizontally stretched quiet center, and a 20 pixel right cap.
The final object is 380 by 25 UI pixels in a 440 by 320 chat book and 480 by 25
UI pixels in a supported 540 by 420 chat book. Live text begins 34 pixels from
the runtime left edge and ends 22 pixels before the right edge. Keep that entire
corridor calm. All necessary page-depth cues must remain legible at 100-percent
UI scale without one-pixel noise, razor-thin lines, or high-frequency dirt.

ALPHA, CHROMA KEY, AND OUTPUT CLEANLINESS
Use only perfectly flat #00FF00 behind and between the two objects. Do not create
a checkerboard, fake transparency, near-green gradient, textured green, ambient
scene, floor, cast shadow outside the objects, or green reflected onto their
edges. Keep at least 8 pixels of pure green isolation inside each source cell so
the deterministic pipeline can derive true transparency and a shared two-state
Alpha mask. Do not return premultiplied dark halos or stray detached pixels.

FORBIDDEN MODERN OR INCORRECT READS
No rounded rectangle, capsule, search bar, glass field, transparent black panel,
modern progress bar, health bar, loading fill, complete rectangular border,
full-width bright underline, full-width gold highlight, glossy bevel, web form,
minimalist thin-line menu, black-leather dashboard, Diablo-style metal trough,
bright golden scroll, symmetric ornamental plaque, tablet, detached flat slab,
photorealistic antique, product render, typography, rune, crest, skull, jewel,
glow, or mirrored mechanical ornament.

FINAL SELF-CHECK
Before returning, verify all of the following: the canvas is exactly 1536 by
1024; the background is exactly flat #00FF00; there are exactly two and only two
text-free slips in the exact NORMAL-then-FOCUS cells; both have the same bounds,
silhouette, anatomy, baseline, and padding; paper and page thickness read before
leather or metal; all distinctive details stay in fixed end zones; the middle is
quiet and stretch-safe; NORMAL settles into the warm-black book; FOCUS remains
dark and clear without turning yellow; no line or highlight reads as a progress
indicator; and no runtime content or neighboring UI is baked into the sheet.
```

### 精确生产授权记录

- 授权日期：`2026-08-03`；授权版本：`CHAT.INPUT.DARK.V1`；对应模拟：
  `CHAT.INPUT.DARK.V1-SIM / confirmed`。
- 固定上传：上述固定 SHA、固定顺序与固定职责的 Image 1／2／3。
- 循环内 edit：仅允许同一循环紧邻前次输出作为 Image 4，且只能在冻结修复
  边界内使用；其余图片一律不得上传。
- 预算：最多 `5` 次实际 ImageGen generation／edit，含首次；当前 `4/5`。
  流程错误没有候选图且没有 provider 生成证据时不占额度；当前 `4`。
- 用户原文：

> 确认授权 CHAT.INPUT.DARK.V1；允许上传固定 SHA 的 Image 1/2/3；允许同循环
> 紧邻前次输出仅在冻结边界内作为 Image 4 edit 输入；最多 5 次实际 ImageGen
> 调用，流程错误不占额度。

- 用户已于 `2026-08-03` 接受 `.r3` attempt 4 进入 `P4`；精确透明源与
  manifest 已入库。剩余 `1/5` 永久停止且不转移。下一门禁是独立的确定性
  P4→P5 exporter、最终 TGA 真实排版、display-region 与静态测试；本次接受
  不授权 runtime 或 Lua 修改。

### `CHAT.INPUT.DARK.V1` 自主修复循环

- 当前实际 ImageGen：`4/5`；流程错误：`4`；循环终态：`source-accepted / stopped`。
- attempt 1 只上传固定 Image 1／2／3并执行上方正文。attempt 2–5 的完整
  `.rN` 正文、前次失败证据和 edit／regenerate 决定必须在各自调用前提交。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1 | `CHAT.INPUT.DARK.V1` / `284a168` | generate；固定 Image 1／2／3 | `019fc5dd-d5a9-7ba0-912d-7d08fe738824` | `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-01/CHAT_INPUT_DARK_V1_attempt01_raw.png`；`f70fbd24…079b` | 材料／组件身份：整块缝线皮革槽，不是夹入页叠的烟草纸 | 只保留恰为两个无字长条、普通／聚焦顺序、长浅比例与暖暗综合色；完整 `.r1` 使用本输出作 Image 4 edit，重绘全部可见材料、端部、中段与 focus | 内部失败；计 `1/5`；未晋级 source/runtime |
| 2 | `CHAT.INPUT.DARK.V1.r1` / `3832bcb` | edit；固定 Image 1／2／3＋紧邻 Image 4 | `019fc5e9-bb26-7601-acec-19869234acda` | `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-02/CHAT_INPUT_DARK_V1_attempt02_raw.png`；`43396173…ab3c1` | 材料可读性／拉伸中段：重复卷曲压纹仍像压花皮革；focus 连续橙金上缘 | 保留两个状态、当前轮廓、薄页叠、右侧纸角、无缝线／长导线和暗色顺序；`.r2` 只把中段改为低频纸纤维并把 focus 高光限制为短段 | 内部失败；计 `2/5`；未晋级 source/runtime |
| 3 | `CHAT.INPUT.DARK.V1.r2` / `756e433` | edit；固定 Image 1／2／3＋紧邻 Image 4 | `019fc5f0-d281-7fd1-9785-7e636e686ca3` | `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-03/CHAT_INPUT_DARK_V1_attempt03_raw.png`；`3fa5948a…6095` | 修复服从度／材料可读性：重复卷曲压纹仍覆盖中段，focus 连续上缘反而更亮 | 两态数量、长浅比例、页叠、无缝线／长导线与暗色顺序可保留为书面约束，但不再保留 attempt 3 像素；`.r3` 只用固定 Image 1／2／3 从零 regenerate | 内部失败；计 `3/5`；未晋级 source/runtime |
| 4 | `CHAT.INPUT.DARK.V1.r3` / `880ed27` | regenerate；仅固定 Image 1／2／3 | `019fc5fd-c995-7f50-94af-5ab05aaba66d` | `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-04/CHAT_INPUT_DARK_V1_attempt04_raw.png`；`6caa441c…2518` | 无；全部内部门禁通过 | 两态薄烟熏 rag-paper、页叠、右纸角、平静中段、暗色 focus、共享 Alpha 与真实排版全部保留；立即停止，不生成 attempt 5 | 用户接受精确透明归一结果进入 `P4`；计 `4/5`；未导出 runtime |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `CHAT.INPUT.DARK.V1` / `aa7a374` | 未创建 | 父级 JavaScript 模板在 `npx` 启动前把 shell 变量误作自身变量，抛出 `ReferenceError: aeui_imagegen_token is not defined`；固定子进程未启动，无上传、候选图或 provider result | 不改生产正文或固定输入；改用不经过 JavaScript 模板插值的等价 shell 字符串组装后重试一次 | 不占生图额度；仍为 `0/5` |
| E2 | `CHAT.INPUT.DARK.V1` / `4b4b8e7` | 未创建 | 固定 Codex CLI 返回 `Reading prompt from stdin... No prompt provided via stdin.`；只读参数校验确认完整参数长 `9179` 字符并以 `$imagegen` 开始，CLI help 随后确认 `-i, --image <FILE>...` 是 variadic，末尾 prompt 被吸收为图片参数；无 model／provider result | 不改正文、输入或职责；在最后一个 `-i` 文件后加入标准 `--` 参数终止符，再传同一完整 prompt | 不占生图额度；仍为 `0/5` |
| E3 | `CHAT.INPUT.DARK.V1` / `2cfadcc` | `019fc5d3-fe81-7803-b26c-05128cea76cd` | 固定子进程收到完整授权正文和三张输入，但从仓库根以 `read-only` 启动，重新发现仓库内 wrapper 并准备递归执行另一个 `npx`；父流程在任何 built-in `image_gen`／provider result 前中断 | 依仓库固定 Skill 改到预创建 `generated/` 的空临时目录，以 `-C`／`-s workspace-write` 启动；执行指令明确当前已是固定版本、只用其 built-in `image_gen`、禁止读取 wrapper 或再启动 `codex`／`npx` | 不占生图额度；仍为 `0/5` |
| E4 | `CHAT.INPUT.DARK.V1` / `ca4fc1c` | 未创建 | 空临时目录命令在 `npx` 前由父 `zsh set -u` 报 `imagegen: parameter not set`；原因是执行指令中的第二个 `$imagegen` 未作为 shell 字面量转义；无上传、子进程或 provider result | 保持空目录、三图、正文和执行指令语义，只把该处转义为字面量 `\$imagegen` | 不占生图额度；仍为 `0/5` |

### `CHAT.INPUT.DARK.V1` attempt 1 审查记录

- 固定版本／session：`@openai/codex@0.143.0`；
  `019fc5dd-d5a9-7ba0-912d-7d08fe738824`。固定子进程在空临时目录以
  `workspace-write` 启动，完整 user block、Image 1／2／3 顺序和禁止递归指令
  均得到确认；provider built-in `image_gen` 实际运行，因此计 `1/5`。
- 执行前 commit：`284a16832cb10badaf5d616ed1f95e6b095edd88`；完整
  `CHAT.INPUT.DARK.V1` 正文 SHA-256 `7d215b05…cf3b`，与授权 commit
  `aa7a374` 中的正文相同。
- raw：
  `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-01/CHAT_INPUT_DARK_V1_attempt01_raw.png`；
  `1536 × 1024 RGB`；SHA-256 `f70fbd249dd5f2d092cfd489e08be3268f9b29accf12073e4398ea9d0323079b`。
- 对象／runtime ownership：通过。恰为 normal／focus 两个长浅无字对象，
  没有烘焙文字、按钮、图标、光标或第三组件；顺序正确。
- 首个失败门禁——材料／组件身份：失败。两个对象首先读作带完整缝线边界、
  左侧竖向皮革卷和左右绑带的整块皮革槽；烟草纸纤维、薄页层、毛边和夹入
  书页的物理关系没有成为第一识别。它接近皮革仪表盘，违反纸张第一和禁止
  `black-leather dashboard` 的合同。
- 拉伸安全：失败。安全中段铺满高频压纹／皮革颗粒，并出现近乎全宽的连续
  暗线；在 `380 × 25` 和 `480 × 25` 装配后仍像输入槽下划线／进度轨道，
  不能作为安静可伸缩纸面。
- 状态反馈：失败。focus 从暖暗纸的局部材料响应变成大面积橙褐提亮和连续
  金橙边缘；综合色重明显高于合同，普通／聚焦虽保持整体大小，却不只是短
  暖光、墨迹与接触暗部变化。
- provider 原始技术合同：raw 背景是渐变绿而不是精确 `#00FF00`，对象 raw
  bbox 分别为 `[112,232,1430,424]`、`[112,564,1429,755]`，没有落入书面
  source cell。依据已授权的 candidate-self 确定性例外，审查工具只用本图
  像素执行 green-to-alpha、bbox-fit、逐像素最小共享 Alpha 与透明 RGB 清零；
  该处理不修复材料语义。
- 确定性审查工具：
  `tools/review_chat_input_dark_candidate_v1.py`；SHA-256
  `f12ed3c987c15b960ecd28765057c6f7b2113a56dff032c5b9dc267960e70eb2`。
  首次审查运行暴露授权正文中 focus `[448,625)` 为 `177px`、同时又声明
  两态 `176px` 的一行算术冲突；工具以 `[448,624)` 作为 canonical crop，
  最后一行保持透明。该本地 review error 没有启动 ImageGen，不计流程错误或
  生图额度。
- 透明归一化 source：`b56df81…754f8d`；逻辑 atlas：`c2de87d1…c6e584`。
  两态共享 Alpha 字节级一致，source／atlas 均不触碰 cell 边界、可见纯绿／
  高绿为 `0/0`，透明 RGB 非零值为 `0`。
- 真实排版：
  `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-01/review/attempt-01.real-layout.png`；
  SHA-256 `0e3055d3…35464`。当前 Full V1 书框、V3 Tab、真实动态消息、普通／
  聚焦输入、`380 × 25` 与扩展 `480 × 25` 均装配；empty、minimum、typical、
  maximum、expanded 五场景 display-region `pass`，violations `0`，报告
  `71db5275…b8fb4`。这只证明区域可容纳，不抵消材料身份失败。
- 保留区：只保留两个无字状态、normal 在上／focus 在下、长浅比例、暖暗综合色
  和无第三对象。全部可见表面、边缘、端部、导线、focus 反馈和 raw 落位都需
  重绘；不得把 attempt 1 的皮革颗粒、缝线、绑带或完整边界视作可保留像素。
- 决策：`fail / repair`。在用户已授权的冻结边界内，attempt 2 使用紧邻 raw
  作为 Image 4 edit 输入，并执行下方完整 `.r1`；未晋级 source、TGA 或 Lua。

### 完整修复正文（`CHAT.INPUT.DARK.V1.r1`；attempt 2）

```text
Edit the supplied failed CHAT.INPUT sheet into one production-ready bitmap
sprite source for a World of Warcraft 1.18.1 Turtle WoW interface overhaul.
This remains a 2004-era Vanilla MMORPG HUD asset, not a modern fantasy-game
overlay.

LOCKED ART DNA
The written direction in this prompt is the governing project baseline. Preserve
the hand-painted Vanilla bitmap language, compact in-game scale, tangible page
thickness, slightly irregular but functional silhouette, warm upper-left light,
low-saturation warm-black and smoked-tobacco palette, deep-walnut contact
shadows, non-mirrored wear, and the heavy feeling of a battlefield journal
carried through a long Azeroth expedition. The dark tobacco gravity may evoke
an Elder Scrolls V journey, but never copy its minimalist menu language,
floating typography, thin rules, or flat overlays.

ATTEMPT-1 FAILURE THAT THIS EDIT MUST REPAIR
Image 4 is the immediately previous output from this same authorized loop. It
failed because both states became complete stitched leather troughs with a
vertical laced leather roll, bound corners, embossed leather grain, a nearly
full-width guide, and a bright orange-gold focus rim. It also placed the objects
outside the required source cells and used a gradient green field.

Preserve from Image 4 only these abstract facts: exactly two text-free long
shallow states, NORMAL above FOCUS, broadly warm-dark color order, and no third
object. Repaint every visible pixel of both objects. Do not preserve or imitate
its leather material, pebbled grain, perimeter stitching, lacing, rolled end,
bound corners, complete outline, long line, orange focus rim, raw coordinates,
or gradient background. Image 4 is a correction target, not a style authority.

OUTPUT OBJECTS AND OWNERSHIP
Produce exactly two complete, separate, text-free horizontal writing slips on
one sheet, in this order:
1. NORMAL chat-input background.
2. FOCUS chat-input background.

These are only the two bitmap backgrounds of one runtime EditBox. Do not include
any third object, retired status field, unread seal, button, icon, label, cursor,
channel name, example text, language control, input history, hit area, book
frame, neighboring UI, contact-sheet frame, caption, number, or crop guide.
All live text, channel headers, caret, IME, focus, history, and keyboard behavior
remain runtime-owned and must not be baked into either object.

AUTHORITY ORDER AND IMAGE RESPONSIBILITIES
Image 1 is the highest supplied visual authority for Vanilla-era HUD identity,
compact scale, battlefield-journal character, and overall visual weight. Its
chat-page material demonstrates that old Azeroth paper remains fibrous and
readable even when worn. Darken that paper into the required smoked-tobacco
range; do not turn it into leather.

Image 2 is the subordinate material-continuity reference for the accepted
warm-black chat book. Match its smoky color family, thin page-stack depth,
deep-walnut contact shadows, restrained wear scale, and warm upper-left light.
Its broad dark reading field must not be interpreted as a leather hide. Do not
copy its book frame, spine, perimeter seams, lacing, corner plate, or surrounding
pixels into either input slip.

Image 3 is structure-only authority for the two-state count, long shallow scale,
and compact runtime input identity. Do not copy its bright yellow parchment,
left laced leather column, right binding, complete edge treatment, continuous
guide, retired third field, unread marker, old color balance, background, or any
pixel. It is not a material or endpoint reference.

Image 4 is only the failed edit target defined above. The written baseline and
Images 1 then 2 govern style and material. Image 3 governs only count and broad
proportion. Image 4 governs no visible material.

EXACT SHEET LAYOUT
The output canvas must be exactly 1536 by 1024 pixels, orthographic and
front-facing, with no perspective. Fill every non-object pixel with one perfectly
flat, uniform chroma-key green #00FF00. No green gradient, vignette, texture,
lighting variation, floor, or reflected green is permitted.

Place the complete NORMAL object only inside the upper source allowance whose
bounds are x=51..1437 and y=187..363. Place the complete FOCUS object only inside
the lower source allowance whose bounds are x=51..1437 and y=448..625.
Coordinates use a top-left origin and exclusive right/bottom bounds. Treat both
states as canonical 1386 by 176 pixel cells; keep the final extra allowed lower
row empty green. Keep at least 8 pixels of clean #00FF00 around every visible
edge inside each cell. Each visible object should occupy about 1320 to 1362
pixels in width and 136 to 160 pixels in height. Give both objects the same
apparent bounds, horizontal baseline, source aspect, and padding. Leave the
large space between and outside the cells completely empty green. Do not draw
cell boundaries, rulers, labels, swatches, shadows, floor, or scene.

NON-LEATHER PAPER IDENTITY
Each state must read immediately as one narrow insert cut from dark smoked rag
paper and tucked into the lower page stack of a battered field journal. The
writing leaf is porous matte paper: visible broad paper fibers, soft soot
absorption, faint pulp mottling, and thin torn/deckled edges. It is never shiny,
pebbled, embossed, padded, tooled, stitched, sewn, rolled, belted, or wrapped.

Build each state from two or three shallow paper layers only:
- one calm upper writing leaf of smoked tobacco rag paper;
- one slightly darker thin paper leaf exposed beneath it;
- one restrained deckled lower edge with a few broad irregularities;
- one soft attached contact shadow where the leaves tuck into the book;
- at most one small asymmetric folded paper corner inside a fixed end zone.

Paper must be recognized before any other material. For this repair, use no
visible leather, no stitching, no thread, no corset lacing, no vertical rolled
column, no binding loop, no metal, and no brass. Neither end may become a cap,
handle, bracket, post, or separately framed ornament. The strip must look like
loose layered pages, not a miniature replica of the surrounding book frame.

STRETCHABLE CENTER AND FIXED ENDS
The long middle must be calm, low-frequency, horizontally stretchable, and safe
for live Chinese or English input text. Use only broad, subtle paper fibers and
smoked absorption that can stretch without exposing a unique motif. The center
x=207..1321 within each state cell must contain no seam, stitch, knot, thread,
fold, tear, curl, vertical feature, strong stain, hotspot, border, endpoint, or
high-frequency pebbled grain.

If a writing guide is present, break it into at least three faint dark-brown
fragments. No fragment may exceed fifteen percent of the center width, the
combined fragments must cover less than forty percent of that width, and large
plain gaps must separate them. The guide must never touch an end zone, become a
single nearly continuous line, trace the lower edge, or read as a progress bar.

Keep the optional small folded paper corner and any short local edge catch only
inside the fixed source end zones: left x=51..207 and right x=1321..1437. Do not
place mirrored endpoint ornaments. Leave the live text corridor visually quieter
than both end zones.

STATE CONTRACT
NORMAL and FOCUS must share the same outer silhouette, Alpha shape, visible
bounds, baseline, page-layer anatomy, left end, stretchable center, right end,
and padding. Use the same paper cut and layer positions for both states. Do not
add, remove, move, lengthen, bind, outline, or curl a page layer between states.
A state change must never imply movement or resizing of the EditBox.

NORMAL is recessed and quiet: smoked tobacco rag paper centered near #403024,
slightly deeper lower leaves, restrained edge catches, and a soft attached
shadow. It should settle close to the warm-black reading page while remaining
recognizable through thin paper layers and matte fibers.

FOCUS remains dark, centered near #503A25. Change only material response: a mild
local lift in the paper pulp, a slightly deeper broken ink fragment, one or two
short candle-warm catches confined to fixed end zones, and a modestly stronger
contact shadow. Do not brighten the whole strip. Do not turn any full edge
orange, yellow, gold, or luminous. Do not add a halo, complete outline, new
border, new endpoint, or new silhouette feature.

RUNTIME ASSEMBLY AND SAFE AREA
The source cells will be deterministically normalized to two 1008 by 120 pixel
objects and placed in a 1024 by 256 runtime atlas at:
- NORMAL: x=8..1016, y=4..124;
- FOCUS: x=8..1016, y=132..252.

The fixed atlas x cuts are 8, 121, 932, and 1016. Runtime assembly uses a 28
pixel left cap, a horizontally stretched quiet center, and a 20 pixel right cap.
The final object is 380 by 25 UI pixels in a 440 by 320 chat book and 480 by 25
UI pixels in a supported 540 by 420 chat book. Live text begins 34 pixels from
the runtime left edge and ends 22 pixels before the right edge. Keep that entire
corridor calm. Thin paper layering must remain legible at 100-percent UI scale
without one-pixel noise, razor lines, high-frequency dirt, or a leather trough
silhouette.

ALPHA, CHROMA KEY, AND OUTPUT CLEANLINESS
Use only perfectly flat #00FF00 behind and between the two objects. Do not create
a checkerboard, fake transparency, near-green gradient, textured green, ambient
scene, floor, cast shadow outside the objects, or green reflected onto their
edges. Keep at least 8 pixels of pure green isolation inside each source cell so
the deterministic pipeline can derive true transparency and one shared two-state
Alpha mask. Do not return premultiplied dark halos or detached specks.

FORBIDDEN MODERN OR INCORRECT READS
No stitched leather trough, laced leather roll, leather input bar, pebbled hide,
complete sewn perimeter, bound corner, continuous lower rule, full-width guide,
rounded rectangle, capsule, search bar, glass field, transparent black panel,
modern progress bar, health bar, loading fill, complete rectangular border,
full-width bright underline, full-width gold highlight, glossy bevel, web form,
minimalist thin-line menu, black-leather dashboard, Diablo-style metal trough,
bright golden scroll, symmetric ornamental plaque, tablet, detached flat slab,
photorealistic antique, product render, typography, rune, crest, skull, jewel,
glow, or mirrored mechanical ornament.

FINAL SELF-CHECK
Before returning, verify all of the following: the canvas is exactly 1536 by
1024; the background is one flat #00FF00; there are exactly two and only two
text-free slips in the exact NORMAL-then-FOCUS allowances; both have the same
bounds, silhouette, paper layers, baseline, and padding; porous matte rag paper
and thin page depth read before every other cue; no leather, stitching, lacing,
rolled end, metal, complete border, or long guide survives from Image 4; all
distinctive details stay in fixed end zones; the middle is quiet and stretch
safe; NORMAL settles into the warm-black book; FOCUS remains dark without an
orange or gold rim; no mark reads as a progress indicator; and no runtime
content or neighboring UI is baked into the sheet.
```

### `.r1` 完整性与冻结边界审计

- 完整性：`pass / self-contained / repair-ready`。正文独立包含全局／Chat 视觉
  DNA、对象与状态、四图职责、失败证据、精确画布／cell、材料层级、拉伸区、
  状态差异、Alpha、禁止项和最终自检；没有依赖“同上”或只写增量。
- 不变项：组件身份、两对象／两状态、Image 1→2→3 权威顺序、三张固定 SHA、
  画布、source allowance、atlas、三段切线、runtime 尺寸、文字 inset、禁止
  baked runtime 内容与五次总预算均不变。
- 可修项：使用紧邻 attempt 1 作为已授权 Image 4 edit；只修复已证实的纸／皮
  身份、端部缝线、拉伸中段、focus 色重、原始落位和纯绿背景。
- attempt 2 上传：固定 Image 1／2／3，加 Image 4
  `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-01/CHAT_INPUT_DARK_V1_attempt01_raw.png`
  （SHA-256 `f70fbd24…079b`）；不得上传 normalized、atlas、真实排版或模拟图。
- 下一门禁：提交本完整正文和审查记录，以提交 hash 作为 attempt 2 执行前
  基线；实际输出计为 `2/5` 后必须再次完成同一确定性审查。

### `CHAT.INPUT.DARK.V1.r1` attempt 2 审查记录

- 固定版本／session：`@openai/codex@0.143.0`；
  `019fc5e9-bb26-7601-acec-19869234acda`。完整 `.r1` 与固定 Image 1／2／3、
  紧邻 attempt 1 raw Image 4 均出现在 child user block；built-in `image_gen`
  实际执行，因此累计 `2/5`。
- 执行前 commit：`3832bcb387ca50d8d2faa4d720492a2e3950eed2`；`.r1`
  正文 SHA-256 `8e00464ee0ed94eeaf5cb01a2b18f248d906d771f769c38c87a1beec4acdc8a2`。
- raw：
  `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-02/CHAT_INPUT_DARK_V1_attempt02_raw.png`；
  `1536 × 1024 RGB`；SHA-256 `433961733f1c8e83dc3f5c424d96f704eaac612d226b6b950a0b6a906ccab3c1`。
- 对象／runtime ownership：通过。恰为 normal／focus 两个无字长条；没有
  第三对象、缝线、皮革卷、长导线、文字、图标或按钮。
- 纸页结构：明显改善。上下均有两至三层薄页叠、毛边和右侧单一折角，端部
  不再是独立皮革柱或绑定结构；普通／聚焦整体轮廓和暗色顺序一致。
- 首个失败门禁——材料可读性／拉伸中段：失败。整张写字面铺满密集、重复、
  卷曲的压纹小单元，视觉更像压花／颗粒皮革而不是低频烟熏 rag paper；这些
  高频单元跨越整个 `x=207..1321` 中段，横向拉伸会显露重复与形变。
- 状态反馈：失败。focus 虽不再整体亮黄，但上边缘形成一条几乎连续的橙金
  轮廓；合同只允许固定端区内一至两段短暖光，不能用整条边表达焦点。
- provider raw 技术：背景仍为渐变绿，raw bbox 分别为
  `[107,231,1430,441]`、`[108,568,1430,781]`，仍需 candidate-self bbox-fit。
  四个画布角点在初次 matte 后留下低 Alpha，使 naïve bbox 扩到整张画布；
  审查工具改为每半张图选择“每行可见像素大于 30 的最大连续对象带”，只
  丢弃离散背景角点再取 bbox。该本地 review error 没有启动 ImageGen，不计
  流程错误或生图额度。
- 确定性工具：`tools/review_chat_input_dark_candidate_v1.py`，SHA-256
  `9723cbd31775f090ed8e5d7a2b424e16f093d3a219da7ce3633f2b250f68df0f`。
  normalized source `3a99e4e9…52771`；逻辑 atlas `bf492987…7c2bb`；两态
  Alpha 相同、可见纯绿／高绿为 `0/0`、透明 RGB 非零值为 `0`。
- 真实排版：`attempt-02.real-layout.png`，SHA-256 `67eb3858…4860e`。
  `380 × 25` 普通／聚焦、典型／最大消息与 `480 × 25` 扩展全部使用本候选；
  五场景 display-region `pass`、violations `0`，报告 `e723d06b…37ac4`。
  缩小后不再像进度轨道，但重复压纹和 focus 连续亮边仍存在。
- 保留区：两个对象与顺序、当前共同轮廓、两至三层薄页、毛边、右侧单一纸角、
  无缝线／长导线、暖暗 normal／focus 顺序。只修复写字面微纹频率、综合色材质
  和 focus 连续高光；不得重新引入 attempt 1 的失败结构。
- 决策：`fail / repair`。attempt 3 在冻结边界内使用 attempt 2 raw 作为紧邻
  Image 4 edit；未晋级 source、TGA 或 Lua。

### 完整修复正文（`CHAT.INPUT.DARK.V1.r2`；attempt 3）

```text
Edit the supplied CHAT.INPUT sheet into one production-ready bitmap sprite
source for a World of Warcraft 1.18.1 Turtle WoW interface overhaul. This
remains a 2004-era Vanilla MMORPG HUD asset, not a modern fantasy-game overlay.

LOCKED ART DNA
The written direction in this prompt is the governing project baseline. Preserve
the hand-painted Vanilla bitmap language, compact in-game scale, tangible page
thickness, slightly irregular but functional silhouette, warm upper-left light,
low-saturation warm-black and smoked-tobacco palette, deep-walnut contact
shadows, non-mirrored wear, and the heavy feeling of a battlefield journal
carried through a long Azeroth expedition. The dark tobacco gravity may evoke
an Elder Scrolls V journey, but never copy its minimalist menu language,
floating typography, thin rules, or flat overlays.

ATTEMPT-2 FAILURE AND PRECISE EDIT BOUNDARY
Image 4 is the immediately previous output from this same authorized loop. It
correctly removed all stitches, laced leather columns, bound corners, long
writing rules, metal, and extra objects. It also established two long dark
states with layered deckled page edges and one small right paper dog-ear.

Preserve from Image 4 only: exactly two text-free states; NORMAL above FOCUS;
their common long shallow silhouette and padding; two or three thin lower paper
layers; the irregular deckled edge; the one small right paper dog-ear; the lack
of lacing, stitching, metal, guide line, labels, and third objects; and the warm
dark NORMAL-to-FOCUS order.

Repair two visible failures. First, repaint the entire broad writing surface of
both states. The repeated tiny curls, loops, veins, pebbles, and embossed grain
currently read as tooled leather and are not preservable. Replace them with
calm low-frequency smoked rag paper. Second, remove the nearly continuous
orange-gold top edge from FOCUS and replace it with only short local material
catches. Do not change component count, state order, page-layer silhouette,
dog-ear location, runtime role, or any geometry contract.

OUTPUT OBJECTS AND OWNERSHIP
Produce exactly two complete, separate, text-free horizontal writing slips on
one sheet, in this order:
1. NORMAL chat-input background.
2. FOCUS chat-input background.

These are only the two bitmap backgrounds of one runtime EditBox. Do not include
any third object, retired status field, unread seal, button, icon, label, cursor,
channel name, example text, language control, input history, hit area, book
frame, neighboring UI, contact-sheet frame, caption, number, or crop guide.
All live text, channel headers, caret, IME, focus, history, and keyboard behavior
remain runtime-owned and must not be baked into either object.

AUTHORITY ORDER AND IMAGE RESPONSIBILITIES
Image 1 is the highest supplied visual authority for Vanilla-era HUD identity,
compact scale, battlefield-journal character, and overall visual weight. Its
chat-page material demonstrates worn handmade paper. Darken that identity into
the required smoked-tobacco range without creating leather grain.

Image 2 is the subordinate material-continuity reference for the accepted
warm-black chat book. Match its smoky color family, thin page-stack depth,
deep-walnut contact shadows, restrained wear scale, and warm upper-left light.
Its broad dark reading field must not be interpreted as a leather hide. Do not
copy the book frame, spine, seams, lacing, corner plate, or surrounding pixels.

Image 3 is structure-only authority for the two-state count, long shallow scale,
and compact runtime input identity. Do not copy its bright yellow parchment,
laced leather column, right binding, complete edge treatment, continuous guide,
retired third field, unread marker, color balance, background, or pixels.

Image 4 is the immediate edit target with the limited preserve-and-repaint
boundary stated above. The written baseline and Images 1 then 2 govern style and
material. Image 3 governs only count and broad proportion. Image 4 does not
authorize retention of its repeated embossed surface or continuous focus rim.

EXACT SHEET LAYOUT
The output canvas must be exactly 1536 by 1024 pixels, orthographic and
front-facing, with no perspective. Fill every non-object pixel with one perfectly
flat, uniform chroma-key green #00FF00. No green gradient, vignette, texture,
lighting variation, floor, or reflected green is permitted.

Place the complete NORMAL object only inside x=51..1437 and y=187..363. Place
the complete FOCUS object only inside x=51..1437 and y=448..625. Coordinates use
a top-left origin and exclusive right/bottom bounds. Treat both states as
canonical 1386 by 176 pixel cells and leave the final extra allowed lower row
empty green. Keep at least 8 pixels of clean #00FF00 around every visible edge.
Each visible object should occupy about 1320 to 1362 pixels in width and 136 to
160 pixels in height. Give both objects the same apparent bounds, baseline,
source aspect, and padding. Leave every other pixel empty green. Do not draw
cell boundaries, rulers, labels, swatches, external shadows, floor, or scene.

PAPER SURFACE FREQUENCY CONTRACT
The upper writing leaf must read as porous, matte, handmade smoked rag paper.
Use broad cloudy soot absorption, a few long soft pulp fibers, faint directional
brush variation, and sparse irregular stains whose edges dissolve gradually.
The visual frequency must be low enough that the center looks calm at source
scale and nearly planar at 25 UI pixels high.

Inside the stretchable center x=207..1321, do not draw any repeating motif,
small curl, loop, pebble, scale, vein network, embossed squiggle, stamped grain,
crackle web, leather pore, stitch, seam, knot, fold, tear, vertical mark, hotspot,
or hard-edged stain. No visible texture unit smaller than about 24 source pixels
may repeat across the center. Prefer four to eight broad fiber or soot events
across the entire width, each long and low contrast, with large quiet gaps.

Do not add a writing guide in this revision. Do not outline the writing leaf.
Top and side edges are defined by deckled paper silhouette and contact shadow,
not by a continuous bright stroke. The center must remain visually quieter than
the two fixed end zones and safe beneath live Chinese or English text.

PAPER ANATOMY AND FIXED ENDS
Keep the current two or three shallow paper layers:
- one calm upper smoked-tobacco writing leaf;
- one slightly darker thin paper leaf visible below it;
- one restrained deckled lower edge with broad hand-painted irregularity;
- one soft attached contact shadow where the leaves tuck into the book;
- the existing single small right paper dog-ear inside the fixed right end zone.

Paper must be recognized before every other cue. Use no visible leather,
stitching, thread, lacing, rolled column, binding loop, metal, or brass. Neither
end may become a cap, handle, bracket, post, or separately framed ornament. Do
not add a left dog-ear or mirror the right one. Keep distinctive end detail only
inside left x=51..207 or right x=1321..1437.

STATE CONTRACT
NORMAL and FOCUS must share the same outer silhouette, Alpha shape, visible
bounds, baseline, page-layer anatomy, dog-ear, stretchable center, and padding.
Use the same paper cut and layer positions for both states. Do not add, remove,
move, lengthen, outline, bind, or curl a layer between states. A state change
must never imply movement or resizing of the EditBox.

NORMAL is recessed and quiet: matte smoked rag paper around #403024, slightly
deeper lower leaves, subtle broad fibers, and a soft attached shadow. Edge
catches must be broken, dark, and subordinate.

FOCUS remains dark, around #503A25. Change only material response: a mild local
lift in the broad paper pulp, a modestly stronger contact shadow, and no more
than two separate candle-warm edge catches. Each catch must be shorter than 120
source pixels, both must remain inside fixed end zones, and their combined
length must stay below 200 pixels. Large dark gaps must separate them. Do not
brighten the whole surface or connect highlights across the top, bottom, or
sides. No edge may turn into an orange, yellow, gold, or luminous rim.

RUNTIME ASSEMBLY AND SAFE AREA
The source cells will be deterministically normalized to two 1008 by 120 pixel
objects and placed in a 1024 by 256 runtime atlas at NORMAL x=8..1016,
y=4..124 and FOCUS x=8..1016, y=132..252. The fixed atlas x cuts are 8, 121,
932, and 1016. Runtime assembly uses a 28 pixel left cap, a horizontally
stretched quiet center, and a 20 pixel right cap.

The final object is 380 by 25 UI pixels in a 440 by 320 chat book and 480 by 25
UI pixels in a supported 540 by 420 chat book. Live text begins 34 pixels from
the runtime left edge and ends 22 pixels before the right edge. Thin paper
layers and the right dog-ear must remain legible at 100-percent UI scale while
the center stays calm, non-repeating, and free of one-pixel noise.

ALPHA, CHROMA KEY, AND OUTPUT CLEANLINESS
Use only perfectly flat #00FF00 behind and between the two objects. Do not create
a checkerboard, fake transparency, near-green gradient, textured green, ambient
scene, floor, cast shadow outside the objects, or green reflected onto their
edges. Keep at least 8 pixels of pure green isolation inside each source cell so
the deterministic pipeline can derive true transparency and one shared two-state
Alpha mask. Do not return premultiplied dark halos or detached specks.

FORBIDDEN MODERN OR INCORRECT READS
No repeated curls, loops, pebbles, scales, embossed grain, tooled leather,
crackle web, stitched leather trough, laced roll, leather input bar, complete
sewn perimeter, continuous highlight rim, writing rule, full-width guide,
rounded rectangle, capsule, search bar, glass field, transparent black panel,
modern progress bar, health bar, loading fill, complete rectangular border,
full-width bright underline, full-width gold highlight, glossy bevel, web form,
minimalist thin-line menu, black-leather dashboard, Diablo-style metal trough,
bright golden scroll, symmetric ornamental plaque, tablet, detached flat slab,
photorealistic antique, product render, typography, rune, crest, skull, jewel,
glow, or mirrored mechanical ornament.

FINAL SELF-CHECK
Before returning, verify: canvas 1536 by 1024; one flat #00FF00 background;
exactly two text-free slips in NORMAL-then-FOCUS allowances; identical bounds,
silhouette, layers, dog-ear, baseline, and padding; current thin page structure
preserved; center fully repainted as broad low-frequency matte rag paper with no
repeated micro-pattern; no guide line; no leather, stitching, lacing, metal, or
complete outline; FOCUS has at most two short separated end-zone catches and no
continuous orange-gold rim; center remains stretch safe; no mark reads as a
progress indicator; and no runtime content or neighboring UI is baked in.
```

### `.r2` 完整性与冻结边界审计

- 完整性：`pass / self-contained / repair-ready`。正文包含全部权威、对象、状态、
  画布／cell、材料频率、页叠、端区、focus 定量边界、runtime、Alpha、禁止项与
  自检，不依赖 `.r1` 的省略引用。
- 不变项：组件身份、两对象／两状态、Image 1→2→3 权威顺序、三张固定 SHA、
  画布、source allowance、atlas、切线、runtime 尺寸、文字 inset、动态内容
  ownership 和五次总预算不变。
- 可修项：紧邻 attempt 2 是唯一 Image 4；保留其轮廓、页叠与纸角，只修复已
  证实的重复压纹中段、连续 focus 上缘、渐变绿和 raw 落位。
- attempt 3 上传：固定 Image 1／2／3，加
  `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-02/CHAT_INPUT_DARK_V1_attempt02_raw.png`
  （SHA-256 `43396173…ab3c1`）；不得上传 attempt 1、normalized、atlas、布局或
  模拟图。
- 下一门禁：提交本完整正文与审查记录后执行 attempt 3；实际输出计 `3/5`，
  然后再次运行同一全量审查。

### `CHAT.INPUT.DARK.V1.r2` attempt 3 审查记录

- 固定版本／session：`@openai/codex@0.143.0`；
  `019fc5f0-d281-7fd1-9785-7e636e686ca3`。完整 `.r2`、固定
  Image 1／2／3 与紧邻 attempt 2 raw Image 4 均出现在 child user block；
  built-in `image_gen` 实际执行，因此累计 `3/5`。
- 执行前 commit：`756e433d5518b6f4d908b935393a9894d453e1ed`；`.r2`
  正文 SHA-256 `9b2d0b7a7bb48255d3d32343b48f97a1f5533c2a0e8341ec0c618a66c42a5594`。
- raw：
  `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-03/CHAT_INPUT_DARK_V1_attempt03_raw.png`；
  `1536 × 1024 RGB`；SHA-256
  `3fa5948abc9cba165234228a8e5e9e3d82f19183630552e272c309bbd90a6095`。
- 对象／runtime ownership：通过。画布仍只有 normal／focus 两条无字长条，
  顺序正确；没有第三对象、文字、按钮、图标、光标、缝线、绑带或长导线。
- 首个失败门禁——修复服从度／材料可读性：失败。两条写字面的整段中心仍
  覆盖密集重复的卷曲、环状和压花颗粒；低频烟熏 rag paper 没有成为第一
  识别。focus 的上缘还被画成比 attempt 2 更亮、更连续的橙金线，继续形成
  进度条／现代输入框语义。attempt 2 与 attempt 3 连续出现同一失败，说明
  Image 4 edit 正在锚定错误表面，不能再把 attempt 3 像素作为下一次基础。
- 保留边界改为书面合同而非像素：保留恰为两态、NORMAL 在上、长浅比例、
  两至三层薄页、右侧单一纸角、无缝线／长导线、暖暗状态顺序与全部 runtime
  几何；attempt 4 不上传 Image 4，只用固定 Image 1／2／3 从零 regenerate。
- candidate-self 色键审查第一次使用固定阈值时，把 provider 的偏暗绿底误作
  部分前景，导致无效全画布 bbox。该本地 review error 没有调用 ImageGen，
  不属于生产流程错误。工具随后只从 raw 自身 `32px` 外围估计绿幕范围：
  background score min `193`、transparent threshold `192`、opaque threshold
  `152`；没有修改对象像素、引用其他图片或改变生产合同。
- 确定性工具：`tools/review_chat_input_dark_candidate_v1.py`，SHA-256
  `b6b26041857c643dd18a6fb3fee736beeb9fc214818f576954126885ff6b8f3a`。
  raw 对象带 bbox 为 normal `[102,207,1440,439]`、focus
  `[102,578,1440,810]`；归一 source SHA-256
  `326240d3d52b0345a618ab2fe94f4f7962d40a0456984c6935c65580dcff6aec`；
  逻辑 atlas SHA-256
  `da937438e3096c8a25eaee0274727ef5a3f4b9c8625c584c29a6c87844b5797f`。
  两态逐像素最小 Alpha 相同；可见绿溢色为 `0`，透明 RGB 非零为 `0`。
- 真实排版：`attempt-03.real-layout.png`，SHA-256
  `e54129b6e6ac0a945aa7ff0fc737f621077232669b0ed20498f2fd4bc2d58735`；
  metrics SHA-256
  `ae549fdb4ff702f226cb3a019311368826ae32219962b90f308f1e5a54c9e22a`。
  `380 × 25` 普通／聚焦、典型／最大消息和 `480 × 25` 扩展都使用候选
  atlas；五场景 display-region `pass`、violations `0`，合同 SHA-256
  `9e46561876c3333bebd26b7ca91a2b3faa5203e3be2881fc4a2da433a6d866f6`，
  报告 SHA-256
  `f61614cad9d1dc07b91b3abd19f1898f4dd6948d3f4dbc0a3fb8d33de9d6f267`。
- 决策：`fail / regenerate`。技术归一与展示区域通过不能覆盖首个美术门禁；
  attempt 3 未晋级 source、TGA 或 Lua。attempt 4 使用下方完整 `.r3`，只上传
  用户已授权的固定 Image 1／2／3。

### 完整修复正文（`CHAT.INPUT.DARK.V1.r3`；attempt 4）

```text
Generate one new production-ready bitmap sprite source for CHAT.INPUT in a
World of Warcraft 1.18.1 Turtle WoW interface overhaul. Generate it from the
three supplied reference images only. Do not edit, preserve, trace, or infer
pixels from any previous CHAT.INPUT candidate. This is a 2004-era Vanilla
MMORPG HUD asset, not a modern fantasy-game overlay.

LOCKED ART DNA
The written direction in this prompt is the governing project baseline. The
asset belongs to one heavy battlefield journal carried through a long Azeroth
expedition. Use the hand-painted low-resolution bitmap language of Vanilla-era
World of Warcraft: compact in-game scale, broad readable material groups,
slightly soft painted edges, tangible page thickness, restrained detail,
asymmetric wear, and a functional silhouette. Use warm upper-left candle light,
deep-walnut contact shadows, low-saturation warm-black and smoked-tobacco hues,
and sparse muted warmth. The dark, weighty journey mood may evoke The Elder
Scrolls V, but never borrow its minimalist menus, thin rules, floating text, or
flat modern overlays. Paper must read before leather or metal.

OUTPUT OBJECTS AND RUNTIME OWNERSHIP
Create exactly two complete, separate, text-free horizontal writing slips on
one sprite sheet, in this order:
1. NORMAL chat-input background, above.
2. FOCUS chat-input background, below.

These are two visual states of one runtime EditBox, not two controls. Include no
third object, retired status field, unread seal, button, icon, label, cursor,
channel name, example text, language control, input history, hit area, complete
book frame, neighboring UI, caption, number, ruler, crop guide, or presentation
card. All live text, channel headers, caret, IME, focus, history, input events,
and keyboard behavior remain runtime-owned and must not be baked into the image.

AUTHORITY ORDER AND REFERENCE RESPONSIBILITIES
The written baseline and Image 1 are the highest visual authority. Image 1
governs Vanilla-era HUD identity, compact scale, aged fantasy illustration,
battlefield-journal character, handmade paper identity, and overall visual
weight. Translate those qualities into this small input component; do not copy
complete frame pixels, text, controls, or scene content.

Image 2 is subordinate and governs continuity with the accepted warm-black chat
book: its smoky tobacco color family, matte fibrous paper, thin page-stack
depth, deep-walnut contact occlusion, restrained wear scale, and warm upper-left
lighting. Use it to make the input feel physically inserted into the same book.
Do not copy its complete book frame, spine, seams, lacing, corner plate, metal,
surrounding pixels, or broad rectangular reading field. Never reinterpret its
dark paper as leather hide.

Image 3 is structure-only authority for CHAT.INPUT: exactly two states, a long
shallow in-game proportion, and restrained end-detail scale. Do not copy its
bright yellow parchment, laced leather column, right binding, full-width line,
complete edge treatment, retired third field, unread marker, color balance,
background, or any pixels. The written material and color rules override its
surface appearance. No previous candidate is supplied or authorized as an
image reference for this generation.

EXACT CANVAS AND SHEET LAYOUT
Return exactly one 1536 by 1024 pixel, front-facing orthographic sprite sheet.
Fill every non-object pixel with one perfectly flat, uniform chroma-key green
#00FF00. Do not add perspective, floor, scene, vignette, gradient green,
checkerboard, fake transparency, cast shadow outside the objects, or reflected
green.

Place the complete NORMAL object only inside x=51..1437 and y=187..363, using a
top-left origin and exclusive right/bottom bounds. Place the complete FOCUS
object only inside x=51..1437 and y=448..625. The canonical visible FOCUS object
must fit within the first 176 rows, y=448..624; leave the final allowed lower row
pure green. Treat both canonical cells as 1386 by 176 pixels. Keep at least 8
pixels of clean #00FF00 around every visible edge inside each cell. Each object
should occupy about 1320 to 1362 pixels in width and 136 to 160 pixels in height.
Give both objects the same apparent bounds, baseline, aspect ratio, silhouette,
and padding. Leave the rest of the canvas empty green.

PHYSICAL OBJECT IDENTITY
Each state is one narrow slip of soot-stained handmade rag paper tucked into the
lower page stack of the chat book. It is not a framed panel. Build it from only:
- one calm upper writing leaf of matte smoked-tobacco rag paper;
- one or two slightly darker, very thin paper leaves visible beneath it;
- a restrained deckled lower edge with broad hand-painted irregularity;
- one soft attached contact shadow where the leaves tuck into the book;
- optionally one small right-side paper dog-ear inside the fixed right end zone.

The paper layers must remain shallow, flexible, and visibly page-like. Neither
end may become a cap, post, handle, bracket, rolled column, leather binding, or
separately framed ornament. Use no leather, stitching, thread, lacing, rope,
knot, sewn perimeter, rivet, metal, brass, jewel, or hard structural border.
Do not mirror wear or add a matching left dog-ear. Distinctive silhouette detail
may exist only in the fixed end zones x=51..207 and x=1321..1437.

MATTE RAG-PAPER SURFACE — PRIMARY FAILURE TO AVOID
The broad upper writing leaf must look almost smooth at source scale and calm at
25 UI pixels high. Its identity comes from porous matte absorption and page
depth, not from surface ornament. Use only low-frequency features: broad cloudy
soot absorption, a few long soft pulp fibers, faint directional brush variation,
and sparse irregular stains with dissolved edges. Keep contrast low and leave
large uninterrupted quiet areas.

Across the stretchable center x=207..1321, use no repeating microtexture and no
small repeated unit of any kind. Specifically forbid curls, loops, scrollwork,
pebbles, scales, pores, embossed dots, tooled motifs, vein networks, crackle
webs, squiggles, stamped grain, stippling, decorative filigree, repeated fibers,
or leather-like granulation. Do not place a visible texture event smaller than
about 32 source pixels if it repeats. Prefer no more than four to six broad,
soft, low-contrast soot or pulp variations across the full width, separated by
large quiet gaps. Do not draw a writing guide, underline, seam, crease, fold,
tear, knot, hotspot, vertical marker, or hard-edged stain in the center.

Edges are defined by the irregular paper cut, thin lower leaves, and attached
contact shadow. Do not trace any full edge with a bright or dark line. Do not
outline the object. The middle must remain quieter than both end zones and safe
under live Chinese or English text after horizontal stretching.

STATE CONTRACT
NORMAL and FOCUS must share the same outer silhouette, Alpha shape, visible
bounds, baseline, upper leaf, lower page layers, dog-ear if present, stretchable
center, and padding. Use the same physical paper cut and layer positions for
both states. Do not add, remove, move, lengthen, curl, bind, or outline anything
between states. State change must never imply movement, resizing, filling, or
progress.

NORMAL is recessed and quiet. Center the matte smoked rag paper near #403024,
with slightly deeper lower leaves, broad nearly invisible fibers, restrained
broken edge catches, and a soft attached shadow. It should sit close to the
warm-black reading page while remaining identifiable as a thin paper insertion.

FOCUS remains dark, centered near #503A25. Change only the material response:
a mild local lift in the broad paper pulp, a modestly deeper attached contact
shadow, and at most two very short candle-warm catches confined to the fixed end
zones. Each catch must be shorter than 90 source pixels and their combined
length below 140 pixels, with large dark gaps between them. The entire
stretchable center and at least 80 percent of every long horizontal edge must
remain without warm highlight. Never connect highlights across the top, bottom,
or sides. No full edge may become orange, yellow, gold, luminous, or sharper
than NORMAL. Do not brighten the whole strip.

RUNTIME ASSEMBLY AND TEXT SAFE AREA
The two source cells will be deterministically normalized to 1008 by 120 pixel
objects and placed in a 1024 by 256 runtime atlas at NORMAL x=8..1016,
y=4..124 and FOCUS x=8..1016, y=132..252. Fixed atlas x cuts are 8, 121, 932,
and 1016. Runtime assembly uses a 28 pixel left cap, a horizontally stretched
quiet center, and a 20 pixel right cap.

The final component is 380 by 25 UI pixels in a 440 by 320 chat book and 480 by
25 UI pixels in a supported 540 by 420 chat book. Live text begins 34 pixels
from the runtime left edge and ends 22 pixels before the right edge. Preserve a
calm text corridor. Thin page depth and the optional right dog-ear must remain
legible at 100-percent UI scale without one-pixel noise, sharp repeating marks,
or a trough silhouette.

CHROMA KEY AND OUTPUT CLEANLINESS
Use only perfectly flat #00FF00 behind and between the objects. Maintain at least
8 pixels of pure green isolation so a deterministic candidate-self matte can
derive real transparency. Do not return near-green gradients, green edge spill,
premultiplied dark halos, detached specks, external shadows, or extra debris.
Both states must support one shared Alpha mask after bbox-fit normalization.

FORBIDDEN MODERN OR INCORRECT READS
No tooled or pebbled leather, repeated curled embossing, laced roll, leather
input bar, stitched trough, bound ends, complete sewn perimeter, full-width
guide, continuous highlight rim, bright underline, gold top edge, rounded
rectangle, capsule, search field, glass panel, transparent black overlay,
progress bar, health bar, loading fill, complete rectangular border, glossy
bevel, web form, minimalist thin-line menu, black-leather dashboard,
Diablo-style metal trough, bright golden scroll, symmetric ornamental plaque,
tablet, detached flat slab, photorealistic antique, product render, typography,
rune, crest, skull, horn, spike, jewel, glow, bloom, watermark, signature, or
mirrored mechanical ornament.

FINAL SELF-CHECK
Before returning, verify all of the following: exact 1536 by 1024 canvas; one
flat #00FF00 background; exactly two and only two text-free slips in the exact
NORMAL-then-FOCUS allowances; identical bounds, silhouette, page anatomy,
baseline, and padding; porous matte rag paper and thin page depth read before
every other cue; no leather, stitching, lacing, metal, guide, or complete
outline; the entire center is calm and free of repeated curls, embossed grain,
pebbles, pores, and other micro-pattern; FOCUS has only optional short separated
end-zone catches and no continuous warm edge; the center remains stretch-safe;
no mark reads as a progress indicator; and no runtime content or neighboring UI
is baked into the sheet.
```

### `.r3` 完整性与冻结边界审计

- 完整性：`pass / self-contained / repair-ready`。正文独立包含全局／Chat 美术
  DNA、恰为两对象／两状态、三张输入职责、从零生成决策、精确画布／cell、
  纸页解剖、低频表面、状态差异、runtime／atlas／inset、色键、禁止项与自检；
  不依赖 `.r2`、前次图或“同前”引用。
- 不变项：组件、normal／focus 顺序、Image 1→2→3 的路径／SHA／职责、画布、
  source allowance、atlas、切线、`28/20px` cap、`380/480 × 25px`、
  `34/22px` inset、动态内容 ownership 与五次总预算均不变。
- 可修项：只修 attempt 3 已证实的 edit 锚定、重复压纹、材料第一识别和连续
  focus 上缘；保留轮廓、页叠、纸角、无缝线／长导线与暗色顺序作为文字合同，
  不保留任何失败候选像素。
- attempt 4 上传：只上传固定 Image 1／2／3；不上传 Image 4、attempt 1／2／3、
  normalized、atlas、真实排版或 simulation。操作为 `regenerate`。
- 下一门禁：提交本完整 `.r3` 后，以提交 hash 作为 attempt 4 执行前基线；
  实际 provider 图计为 `4/5`，随后从对象身份开始运行同一全量审查。内部通过
  立即停止并交用户接受；内部失败才允许在剩余一次额度内建立完整 `.r4`。

### `CHAT.INPUT.DARK.V1.r3` attempt 4 审查记录

- 固定版本／session：`@openai/codex@0.143.0`；
  `019fc5fd-c995-7f50-94af-5ab05aaba66d`。child 明确显示
  `OpenAI Codex v0.143.0`，完整 `.r3` 与固定 Image 1／2／3 按顺序进入 user
  block；没有 Image 4，built-in `image_gen` 实际执行，因此累计 `4/5`。
- 执行前 commit：`880ed275f6550935b23843bdd4c2092a191fdd7a`；`.r3`
  正文 SHA-256 `1ef8bd520244f1494aaa1208898b74dc1192bdffc5057478f85aeb1cb9a1fecf`，
  长 `10914` 字符；完整性审计为 `pass / self-contained / repair-ready`。
- raw：
  `generated/chat/core/CHAT.INPUT.DARK.V1/attempt-04/CHAT_INPUT_DARK_V1_attempt04_raw.png`；
  `1536 × 1024 RGB`；SHA-256
  `6caa441c135de0761fcc797a59b00b11a0dd8cf8b325289d3ae29fb1c12f2518`。
- 对象／runtime ownership：通过。恰为 NORMAL 在上、FOCUS 在下的两条完整
  无字纸条；没有第三对象、文字、光标、按钮、图标、未读、语言字段、书框或
  相邻 UI。两态长浅比例、基线、页层、右侧单一纸角和外轮廓一致。
- 物件／材料：通过。两态首先读作两至三层薄烟熏 rag paper，靠 deckled 页缘、
  页叠厚度和附着阴影成立；没有皮革端柱、缝线、绑带、金属、卷轴轴心或完整
  硬边。表面是无规则纤维／烟熏吸收，不再出现 attempt 2／3 的卷曲、环状、
  压花或可数重复单元。源尺度仍保留细纤维，但在 `25px` 实际高度收敛为平静
  哑光纸面，不形成皮革粒面或拉伸重复。
- 状态反馈：通过。NORMAL 深灰烟草并后退；FOCUS 只整体轻抬到深暖烟草，
  长边没有醒目的连续橙金轮廓、发光或进度填充。真实布局中 focus 可辨认但
  仍明显暗于旧 V3 浅金输入纸带；状态切换不改变轮廓或位置。
- provider raw 使用接近纯绿但非精确 `#00FF00` 的自发光绿幕；按既定
  candidate-self 规则从 raw 自身 `32px` 外围估计 matte：background score
  min `219`、transparent threshold `218`、opaque threshold `160`。raw 对象带
  bbox 为 normal `[81,230,1455,450]`、focus `[81,567,1455,787]`；等比
  bbox-fit 后两态均为 `1344 × 154px`，完整对象、页层与右纸角均未裁切。
- 确定性工具：`tools/review_chat_input_dark_candidate_v1.py`，SHA-256
  `b6b26041857c643dd18a6fb3fee736beeb9fc214818f576954126885ff6b8f3a`。
  normalized source SHA-256
  `4df36bc607a024ca0a2355f5d20ff985f61cbf3304073a65e33caa978c50cda0`；
  逻辑 atlas SHA-256
  `8e2a6437b332fe28a34d8eb1d5b48f78073a3238e6b9826108e2f96650edca79`；
  两态共享 Alpha，pre-intersection 差异 `7206` 像素已取逐像素最小值；可见
  绿溢色 `0`，透明 RGB 非零值 `0`。在独立临时目录复跑后，normalized、atlas
  与真实排版三个 PNG SHA 完全相同。
- 真实排版：`attempt-04.real-layout.png`，SHA-256
  `64e2ac242954eee68fc9cdb9730500a3b35d8c19c0b2595eed7a9622e5223749`；
  metrics SHA-256
  `91a752476a73aaa430e7d28e0b17536323beb6c483f8e26bbbc0e1918837ea2e`。
  它复用 tracked Full V1 书框、V3 Tab／承托带和动态代表文字，只替换候选
  input atlas；覆盖旧 V3 对照、空 normal、最小 focus、典型 15 行、最大 16 行
  与 `540 × 420`／22 行横向伸缩。全部文本 `truncated=0`，`34/22px` inset
  和 `380 × 25`／`480 × 25` 输入区保持。
- 展示区域合同 SHA-256
  `9dc11cd490cc9d7bd8067d547ef013210344e3299cdaaf7fa74fd4fb5a9c16b7`；
  报告 SHA-256
  `a399e7ffa584aec0ce40214b871546b61728b92a699a13a4b4a8d4f6a62cfc52`。
  empty、minimum、typical、maximum、expanded 五场景全部 `pass`，violations
  `0`、first failure `null`。
- 内部决策：`pass / candidate-reviewed / P3`。这是本循环首个通过全部对象、
  材料、状态、Alpha、三段拉伸、真实排版与展示区域门禁的候选，故按授权立即
  停止；attempt 5 未调用。该结论随后由下方用户接受记录晋级为
  `source-accepted / P4`；仍未生成正式 TGA，未修改 Lua／pfUI／ChatMOD 或
  SavedVariables。
- 用户结论与日期：`accepted / 2026-08-03`。用户接受的是精确 `.r3 attempt 4`
  的确定性透明归一结果；剩余 `1/5` 终止且不转移。下一门禁为独立的 P4→P5
  确定性导出与最终 runtime 审查，不得把本次接受解释为 TGA／Lua 授权。

### `CHAT.INPUT.DARK.V1.r3 attempt 4` 用户接受记录

- 用户原文：“接受 CHAT.INPUT.DARK.V1.r3 attempt 4 进入 P4。”
- 接受日期：`2026-08-03`；状态：`source-accepted / P4`；操作：`accept`。
- 接受的唯一源：
  [`ChatInput_Dark_V1_r3.png`](../../../../assets/source/chat/input-dark-v1/ChatInput_Dark_V1_r3.png)，
  `1536 × 1024 RGBA`，SHA-256
  `4df36bc607a024ca0a2355f5d20ff985f61cbf3304073a65e33caa978c50cda0`。
- provenance：
  [`ChatInput_Dark_V1_SourceManifest_v1.json`](../../../../assets/source/chat/input-dark-v1/ChatInput_Dark_V1_SourceManifest_v1.json)。
  固定执行器 `imagegen-0-143-0`／`@openai/codex@0.143.0`；session
  `019fc5fd-c995-7f50-94af-5ab05aaba66d`；provider result
  `ig_093073d7aed26787016a702047bcd48191a71c9dbbf2bce523`；生成前 commit
  `880ed275f6550935b23843bdd4c2092a191fdd7a`；完整 `.r3` 正文 SHA-256
  `1ef8bd520244f1494aaa1208898b74dc1192bdffc5057478f85aeb1cb9a1fecf`。
- 技术接受边界：只把候选自身近绿幕确定性转为 Alpha、分别 bbox-fit 两态、
  使用逐像素最小值建立共同 Alpha，并把全透明 RGB 清零；normal／focus 的
  canonical cell 分别为 `[51,187,1437,363]` 与 `[51,448,1437,624]`。
- 预算终态：实际 ImageGen `4/5`，流程错误 `4`；attempt 5 永久停止且不转移。
- 未授权：正式 TGA、exporter、Lua／XML、pfUI／ChatMOD、SavedVariables、P5、
  Turtle WoW 实机结论或 P6-C 清理。现行 `ChatInputAtlasV3.tga` 保持。
- 中间产物：未清理。项目规则要求在 P6 实机通过后先给出精确清理清单，并经
  用户明确批准进入 P6-C；本次 P4 接受不满足该门禁。
- 下一门禁：从上述 tracked source 建立确定性 `1024 × 256` runtime exporter，
  按 normal `[8,4,1016,124]`、focus `[8,132,1016,252]` 与
  `x=8/121/932/1016` 切线导出；用最终 TGA 重跑 `380 × 25`、`480 × 25`
  真实排版与 display-region，再决定是否进入 P5。

### `CHAT.INPUT.DARK.V1` P4→P5 确定性导出

- 触发指令／日期：“继续”／`2026-08-03`。依资产工作流把它解释为当前组件
  下一未阻塞 `export` 门禁；本阶段没有 ImageGen、上传、重生成或自由修图。
- exporter：`tools/build_chat_input_dark_v1_runtime.py`，只接受 SHA-256
  `4df36bc…cda0` 的 `1536 × 1024 RGBA` source；裁切 normal
  `[51,187,1437,363]` 与 focus `[51,448,1437,624]`，各自 LANCZOS 缩放为
  `1008 × 120`，保持逐像素共同 Alpha、清零全透明 RGB，并装入固定
  `1024 × 256` 画布。本操作没有混入 V3、Full V1、模拟或拒绝候选像素，
  没有重绘。
- 最终 atlas：`addon/AzerothExpeditionUI/Media/Chat/ChatInputDarkV1.tga`，
  SHA-256 `43cb9a0173a2f0cf05b43bb01b13a7e2aa8853feb26d4f62ec7b399610f47666`；
  logical PNG SHA-256 `8e2a6437…ca79`，与 P4 审查逻辑 atlas 完全一致。
  normal／focus 共同 Alpha，visible green spill `0`，transparent RGB 非零值
  `0`。状态行保持 `[0,.5]`／`[.5,1]`，三段切线保持
  `8/121/932/1016`，runtime 端帽 `28/20px`、高度 `25px`、文字 inset
  `34/22px`。
- adapter：`Modules/Chat.lua` 的 `TEXTURES.input` 只从
  `ChatInputAtlasV3` 改为 `ChatInputDarkV1`，runtime contract 提升到 `1.20`；
  `StyleInput`／`UpdateInputState` 的 anchor、size、slice、UV 与 focus 判定没有
  改动。输入文字、频道头、光标、IME、历史、AltArrowKey、键盘事件、命中
  几何、pfUI／ChatMOD 与 SavedVariables 不在本次改造范围。
- 最终真实排版：
  `generated/chat/core/CHAT.INPUT.DARK.V1/runtime-v1/ChatInputDarkV1_runtime_real_layout.png`，
  覆盖空 normal、最小 focus、典型 15 行、最大 16 行和 `540 × 420`／22 行；
  书框、Tab、承托带、最终输入 TGA 与动态文字均从 tracked runtime 读取。
  全部场景没有截断，`380 × 25`／`480 × 25` 与文字安全区保持。
- 最终展示区域合同：
  `tools/specs/chat_input_dark_runtime_display_region_v1.json`；报告：
  `generated/chat/core/CHAT.INPUT.DARK.V1/runtime-v1/ChatInputDarkV1_runtime_display-region-report.json`。
  五场景 `pass`，violations `0`，first failure `null`。
- 状态：`runtime-exported / P5`。旧 `ChatInputAtlasV3.tga` 和全部生成／审查
  证据保留到 P6-C；没有清理授权。下一门禁是在 Turtle WoW `1.18.1` 实机
  `/reload` 后确认 `/aeui status` 为 `chat-runtime=1.20`，并逐项验证 normal／
  focus、文字、光标、IME、频道头、输入历史、键盘事件和常用 UI Scale。

## `CHAT.TABS.DARK.V1` 深色皮革索引签替换

### 元数据与当前门禁

- 组件 ID：`CHAT.TABS`、`CHAT.TAB_SHELF`。前者对应四状态
  `ChatFrameNTab`／`ChatFrameNTabText`，后者对应
  `pfUI.chat.left.panelTop` 上的一枚连续承托 Texture；没有新增 Button、Tab、
  文字、配置入口或消息功能。
- 历史生产版本：`CHAT.TABS.DARK.V1 / candidate-rejected / user-rejected`；
  当前生成前模拟：`CHAT.TABS.DARK.SIM.V2 / simulation-confirmed`；项目现行
  runtime 仍为 `CHAT.CORE.V3 1.21 / P5`，新替换方向停在 `P2`。
- 操作：`generate/edit loop closed`。固定执行器为
  `imagegen-0-143-0 / @openai/codex@0.143.0`；模拟 ImageGen `0/0`，生产
  `5/5`，流程错误 `2`。四张固定 SHA 输入和冻结修复边界均按授权执行；额度
  已耗尽，不得执行 attempt 6。
- 用户触发：`2026-08-04` 在实机观察到 Full V1 主框已经更新，但 Tab 仍偏浅；
  仓库审计确认实际加载的是 `ChatTabAtlasV3.tga`／`ChatTabShelfV3.tga`，不是
  原生 pfUI fallback。V3 Tab 于 `2026-07-29` 接入，未随 `2026-08-03` 的
  Full V1／Dark V1 更新重绘；selected 行含大面积浅纸层，承托带有贯穿亮边，
  且 adapter 使用 `SetVertexColor(1,1,1,1)` 原色显示。
- 用户否决：`2026-08-04` 明确指出 attempt 3 “太工整”，要求参考旧 Tab
  样式。该反馈改变可见轮廓，已越出 V1 冻结修复边界；V1 授权与预算均关闭，
  attempt 3 不得再晋级或用于 edit。
- 下一门禁：用户审视 `CHAT.TABS.DARK.SIM.V2` 的本地真实排版预演。接受后才
  重写 V2 完整生产 Prompt、建立新 scaffold／固定输入／`0/5` 预算，并另行
  请求精确生产授权；不接受则仍只修改本地模拟。

### 美术基准继承与冲突裁决

权威顺序：

1. `assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
   `90e30ba4…ee06`，与 `ART_BASELINE.md`／`SUBMODULE_ART_BASELINES.md`：
   香草时代手绘厚重感、左下战地旧书、深皮革索引签和有限暖金响应。
2. `assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
   `272528e6…aab8`：二维位图的实体厚度、材料切面、短促高光与手工误差；其中
   巨型对称框、龙饰、尖冠、整圈亮金和浅色大纸面不属于本组件。
3. `docs/GLOBAL_ART_BASELINE.md`、Chat 主／子模块 Prompt：2004 年前后香草
   轮廓，低饱和烟褐、深胡桃旧皮革、暗哑氧化黄铜，禁止网页 Tab、胶囊、
   现代卡片、半透明黑玻璃和连续细金线。
4. `SUBMODULES.md` 与当前 adapter：四枚 `92 × 30px` Tab、`3px` 间距、
   `2px` 顶部偏移、`16px` 承托带、`18px` 承托带偏移、底部 `8px` 命中扩展，
   四状态同一 Button 几何，文字由 runtime 居中绘制。
5. `assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png`，SHA-256
   `a97d9c5f…c673`：只作为当前邻接书体的深胡桃／暖黑烟褐材料与综合色重参考，
   不改变更高权威的时代语言，也不复制完整书框。
6. `assets/source/chat/v3/ChatTabs_Master_v3.png` 是 V2 的旧式轮廓／四状态物理
   关系权威：继承略斜梯形、外撇下角、手工缝线误差、selected 在同一画布内
   抬升并露出夹页层，以及 Tab 压在承托带前方的关系。用户的实机反馈仍否决
   它的浅金综合色重，因此浅色 selected、大面积亮纸、连续亮边和旧颜色不继承。

本批必须继承：厚旧皮革索引签首先像夹在书页上的实体物件；轮廓稍有手绘误差，
左上暖光；普通态后退，hover 只有一段短暖边，selected 在同一外接框内略抬并
以接触阴影压住承托带，disabled 降低对比。所有状态仍以皮革为主体，不能把
selected 变成浅羊皮纸牌或黄铜铭牌。

明确排除：TabText、频道名、未读蜡封、主框、正文、输入条、滚动／复制／语言／
菜单按钮、图标、状态文字和任何功能性符号。它们继续由各自 runtime 对象持有。

### 组件与生产拆分合同

- 逻辑对象：一枚可横向延展的 `CHAT.TAB_SHELF`；一枚
  `CHAT.TABS` 四状态 atlas，顺序固定为 normal／hover／selected／disabled。
  物理上允许同一透明母版承载五个隔离对象，但 exporter 必须分别裁出 shelf 与
  四个状态，不能把五者烘焙成整张聊天框背景。
- runtime 不变：每枚 Tab `92 × 30px`，横向三段式端帽 `16/16px`；四状态外接
  几何、Button、文字锚点和命中区相同。shelf 装配为 `frameWidth-60 × 16px`，
  `TOPLEFT(30,18)`；它在 Tab 后、主框上，不能覆盖 TabText 或正文。
- 生产画布草案：`1536 × 1024 RGBA`。shelf crop
  `[64,96,1472,232]`；四状态 crop 依次为
  `[64,560,384,716]`、`[416,560,736,716]`、
  `[768,560,1088,716]`、`[1120,560,1440,716]`。对象之间和画布边缘保持纯色键
  隔离，任何对象不得跨 cell。
- 四枚 Tab crop 各 `320 × 156px`，确定性缩放为 `248 × 120px` 后装入现有
  `512²` 四行 atlas。约前后各 `62px` source 只承担固定端帽装饰；中间区域
  低频、无独特缝线终点／裂口／铆钉，可水平延展。文字安全区必须安静、无字、
  无符号、无高对比花纹。
- shelf crop 确定性缩放为 `1016 × 56px` 并装入 `1024 × 64px` atlas；两端可有
  小型接缝，中央必须低频可伸缩。顶部允许不规则暗边与分段极短反光，但禁止
  贯穿全宽的浅纸条或金色导线。
- Alpha 策略：正式候选允许固定纯绿背景，后处理只按候选自身色键确定性清理，
  全透明 RGB 清零；不得把生成前模拟像素、旧 V3 Tab 像素或 Full V1 书框像素
  合成进候选。动态内容禁止烘焙。
- fallback：生产、接受或导出任一门禁前失败时继续加载当前 V3 Tab／shelf；
  本阶段完全不修改 Lua、TGA、TOC、pfUI 或 SavedVariables。

### 生成前模拟 `CHAT.TABS.DARK.SIM.V1`

- renderer：`tools/render_chat_tabs_dark_simulation_v1.py`；specification：
  `tools/specs/chat_tabs_dark_simulation_v1.json`。macOS 命令：
  `conda run -n py312 python tools/render_chat_tabs_dark_simulation_v1.py tools/specs/chat_tabs_dark_simulation_v1.json`。
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`。
- 输出：
  `generated/chat/core/CHAT.TABS.DARK.V1/simulation/CHAT-TABS-DARK-SIM-V1/chat_tabs_dark_sim_v1.png`，
  `1620 × 570 RGBA`，SHA-256 `331499f0…d9a`；metrics SHA-256
  `d9665adf…0c89`。独立 `/private/tmp` 重放得到相同 PNG SHA。
- 三个精确实例：当前 V3 `440 × 320` 对照；候选四状态同屏
  `440 × 320`；候选 `540 × 420`／22 行扩展窗口。书框、输入 TGA、经典
  provider 颜色和动态真实排版来自当前 tracked runtime；候选 shelf／Tab 是
  纯本地 polygon、line 和平面配色。
- 状态节奏：normal `#251810` 后退；hover `#302016` 加一段短暖边；selected
  `#422A1A` 在同一画布内上抬并以短 `#A47A3F` 边光／底部接触暗部识别；
  disabled `#17110D`。shelf `#17100C`，顶部亮边被打断且能在 `380/480px`
  宽度下保持低能量。
- display-region contract：
  `tools/specs/chat_tabs_dark_sim_display_region_v1.json`；报告：
  `generated/chat/core/CHAT.TABS.DARK.V1/simulation/CHAT-TABS-DARK-SIM-V1/display-region-report.json`，
  SHA-256 `72639957…3c9`。三个场景、四个逻辑 state cell、Tab visual、底部扩展
  hit box 与 shelf 区域全部 `pass`，violations `0`。
- ImageGen：`0/0`；外部上传：无；正式预算：未开启。
- 本地错误：SE1 为 Full V1 palette 无 `body` 键导致 `KeyError: 'body'`，已用
  已接受 B-near-black-paper 方向色板补齐未声明角色；SE2 为 `/private/tmp`
  重放 metrics 路径调用 `relative_to(ROOT)` 失败，已改为 repo-relative／absolute
  双路径显示。两者都没有 provider 或生成图片证据，不属于生产流程错误。
- 内部结论：`displayable / simulation-reviewed`。真实比例、四枚真实对象、
  15／22 行密度、邻接新 UI、z-order、全部交互状态、伸缩宽度和综合色重足以
  供用户判断；没有把几何模拟误判为最终笔触、Alpha、接缝或微纹理证明。
- 用户方向结论：`2026-08-04 / confirmed`。用户明确回复“接受”，确认
  `CHAT.TABS.DARK.SIM.V1` 所表达的深胡桃／烟熏皮革主体、selected 不出现浅纸
  底、shelf 不出现连续亮带、四状态只用抬升／短暖光／接触阴影区分，以及
  `440 × 320`／`540 × 420` 下保持现有布局、尺寸和综合色重。
- 确认只冻结上述可见条款，不接受模拟像素。polygon、平涂、字体栅格、磨损、
  缝线、Alpha、精确 atlas 切片和最终手绘纹理继续属于非权威简化。模拟 PNG
  禁止进入 source／runtime、禁止裁切／切片／
  晋级，也禁止作为正式 ImageGen edit／reference 输入。
- 确认失效条件：后续改变材料层级、selected 物件身份、shelf 亮度节奏或整体
  重量时，必须返回 `prompt-draft` 并重新模拟。

### 独立生产技术 scaffold（尚未上传）

- specification：`tools/specs/chat_tabs_dark_production_scaffold_v1.json`；由通用
  本地几何 renderer 生成，不读取或复制模拟像素。
- 输出：
  `generated/chat/core/CHAT.TABS.DARK.V1/production-scaffold/CHAT_TABS_DARK_V1_scaffold.png`，
  `1536 × 1024 RGBA`，SHA-256 `03774a0f…077d`。它只冻结一条 shelf 与四个
  state cell 的位置、外接轮廓和纯绿色键背景；灰阶、明暗和 polygon 边缘没有
  美术权威。
- 用户已确认模拟方向，但仍须看过最终正文并明确授权固定 SHA 上传后，该
  scaffold 才能作为正式 Image 4；本阶段没有上传，也不得把模拟 PNG 替代它。

### 生产正文完整性预检

- 计划固定输入（尚未授权、未上传）：Image 1
  `assets/locked/chat/聊天框视觉基准_v1.png`，SHA `90e30ba4…ee06`；Image 2
  `assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA `272528e6…aab8`；
  Image 3 `assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png`，SHA
  `a97d9c5f…c673`；Image 4
  `generated/chat/core/CHAT.TABS.DARK.V1/production-scaffold/CHAT_TABS_DARK_V1_scaffold.png`，
  SHA `03774a0f…077d`。生成前模拟 PNG 不在上传范围。
- 复杂度：`atlas + states + horizontal-three-slice + stretch`。
- 结论：`production-executed / repair-budget-exhausted`。物件身份、五个逻辑
  对象、四状态顺序、Canvas／cell、端帽／安全区、输入职责、材料与反模式、
  色键和最终自检均已明确；用户确认的深色皮革、无浅纸 selected、无连续亮带
  shelf、抬升／短暖光／接触阴影状态语义均已写入并执行。生产授权已经消费
  完毕，当前只等待候选例外决策。
- 不可变修复边界：组件 ID、对象／状态数量、上述 Canvas／cell、四张输入
  职责、runtime `92 × 30`／`16px` caps、shelf `16px`、Alpha／色键、动态内容
  排除和五次实际 ImageGen 上限。边界内可强化材料、轮廓、短高光和状态差异；
  后续建议授权：每次可重新上传四张固定 SHA 输入；attempt 2–5 仅可把同一循环
  紧邻前次输出作为 Image 5 edit 输入，并且只修复冻结边界内的材料、轮廓、
  状态差异、色键或 cell 合同。新增输入、对象、状态、布局、Canvas、视觉方向
  或 runtime 几何必须停止并重新授权。
- 单一生产正文预算：最多 `5` 次实际 ImageGen generation/edit，含首次；流程
  错误单列且不占额度。当前为 `5/5`，流程错误 `2`，预算已耗尽。
- 下方最终执行正文 UTF-8 body 为 `5584` bytes，SHA-256
  `b6a7b483964bf779eaa1cde9b4c47bc0b9484b8fe1b675a26edda8964b32a0bd`；生产授权
  必须指向该版本，授权后执行前提交，不得静默改写。

### 精确生产授权记录

- 授权人／日期：用户，`2026-08-04`。
- 用户原文：`确认授权 CHAT.TABS.DARK.V1；允许每次上传固定 SHA 的 Image 1/2/3/4；允许同循环紧邻前次输出仅在冻结边界内作为 Image 5 edit 输入；最多 5 次实际 ImageGen 调用；流程错误不占额度。`
- 授权正文：下方 SHA-256
  `b6a7b483964bf779eaa1cde9b4c47bc0b9484b8fe1b675a26edda8964b32a0bd` 的完整
  `CHAT.TABS.DARK.V1` body；执行时必须原样传入，输入角色与保存位置只放在独立
  `Execution instruction`。
- 每次固定上传：Image 1 `90e30ba4…ee06`、Image 2 `272528e6…aab8`、Image 3
  `a97d9c5f…c673`、Image 4 `03774a0f…077d`；生成前模拟 PNG 永不上传。
- attempt 2–5：只有在明确保留前次正确区域时，才允许紧邻前次输出作为
  Image 5 edit 输入；不得使用更早输出、拒绝版本或外部新增输入。
- 实际生图预算：`5/5`；最坏总计 `5`；流程错误 `2`，无生成图且无 provider
  生成证据时单列，不占额度。任何 attempt 客观通过后立即停止；内部通过不等于
  用户接受。
- 执行前 commit：`d8df8d1`；该提交包含本授权记录和下方精确正文。

### `CHAT.TABS.DARK.V1` 自主修复循环

- 当前实际 ImageGen：`5/5`；流程错误：`2`；循环终态：
  `repair-budget-exhausted / user-review-required`。不得生成 attempt 6。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `CHAT.TABS.DARK.V1` / `b3a7852` | generate；固定 Image 1／2／3／4 | session `019fcace-7b01-7c13-a29a-3932e81da97e`／provider cache `ig_081d682ab380e3a0016a715bd7ea2c8191b8b5ad8d4906d223.png` | raw `generated/chat/core/CHAT.TABS.DARK.V1/attempt-01/CHAT_TABS_DARK_V1_attempt01_raw.png`／`8b873a7475d5ac46e09c731983269691c41f7f26d6dfeb2e08d26be27158bbe8`；keyed `…attempt01_keyed.png`／`1d721a9e60f08da9ab89f1bd57216edf9b582b5c49e70267a6a19fbac5c2c8f8` | 组件 cell／隔离合同：透明候选有 `17,910` 个可见像素位于五个声明 cell 之外；shelf 触底，四枚 Tab 均触底并触及／越过右侧；raw 绿幕也不是均匀 `#00FF00` | 保留五对象身份、深胡桃旧皮革、手绘厚度、短暖光、四态综合色重和低亮 shelf；不保留对象位置、尺寸、格位外像素或渐变绿幕。完整 `.r1` 使用紧邻 raw 作为 Image 5 edit，把五对象完整缩回内层绿色隔离区，不裁断端部／底缝 | 内部失败；计 `1/5`；未进入用户复审、source 或 runtime |
| 2/5 | `CHAT.TABS.DARK.V1.r1` / `758335f` | edit；固定 Image 1／2／3／4 + 紧邻 attempt 1 raw Image 5 | session `019fcadd-e641-7611-b53c-0adb9a4f0bbf`／provider cache `ig_06e5b187b9e40f5c016a715fd12b2881919fed83df12f9044b.png` | raw `generated/chat/core/CHAT.TABS.DARK.V1/attempt-02/CHAT_TABS_DARK_V1_r1_attempt02_raw.png`／`0c82fb7ebdff8e46f76f735202cd4a03ddbd8fe33c227a620c7e8878c0d530e2`；keyed `…attempt02_keyed.png`／`4352735f10ebca6d7adeef91ee34da0e63cb3453e74121906fb8a3061a9fb259` | 同一 cell／隔离失败重复：对象虽缩小，但仍有 `54,203` 个可见像素在声明 cell 外；shelf 触底，四 Tab 仍触底并越过右侧，说明前次大轮廓 edit 锚定未解除 | 停止连续 edit；不上传 attempt 2。完整 `.r2` 只用固定 Image 1／2／3／4 regenerate，把 Image 4 的非绿色 polygon 作为逐像素唯一绘制 mask，Image 4 为绿色的像素必须保持纯绿 | 内部失败；计 `2/5`；未进入用户复审、source 或 runtime |
| 3/5 | `CHAT.TABS.DARK.V1.r2` / `2b1a01d` | regenerate；固定 Image 1／2／3／4，无 Image 5 | session `019fcae5-7b4d-7821-ad93-50f848af382c`／provider cache `ig_033f7c278ec1fe6d016a7161c121fc81918b9169596100fd54.png` | raw `generated/chat/core/CHAT.TABS.DARK.V1/attempt-03/CHAT_TABS_DARK_V1_r2_attempt03_raw.png`／`51c9045d08f8fbcdbdbcce532d257925336868676647f94856a4a7541cc260ed`；keyed `…attempt03_keyed.png`／`343cbfd6a2373e87024da23a9f7f7c8dcce36ad59522fc405068dd377966b391` | 冻结 source cell 合同已经通过：cell 外像素 `0`，全部格位隔离通过；但 `.r2` 追加的逐像素 scaffold mask 仍有 `3,460` 个可见边缘像素位于 Image 4 非绿 mask 外 | 保留 attempt 3 全部合格材质、五对象、四态、位置节奏和运行时观感；完整 `.r3` 使用紧邻 raw Image 5，只把五个完整外轮廓等比内缩约 `2–4px` 并居中，禁止其他视觉重绘 | 内部失败；计 `3/5`；未进入用户复审、source 或 runtime |
| 4/5 | `CHAT.TABS.DARK.V1.r3` / `c5e0a15` | edit；固定 Image 1／2／3／4 + 紧邻 attempt 3 raw Image 5 | session `019fcaef-337c-71b3-8292-dcef6a9b7df1`／provider cache `ig_08366a92bf4238f6016a71644251ec819199e37c59741356a0.png` | raw `generated/chat/core/CHAT.TABS.DARK.V1/attempt-04/CHAT_TABS_DARK_V1_r3_attempt04_raw.png`／`cf4227c9fffd2696531fa38b33e37faf784952f4b9d4116cd393067021203347`；keyed `…attempt04_keyed.png`／`c5836ad4436166f4cf8d016ddea383ee1f61907d92c46e88fdcb0e5c1322e71d` | edit 重新引入 cell 越界：`43,099` 个可见像素在声明 cell 外；shelf 触底，四 Tab 触底并越右；strict mask 外为 `88,660` | 彻底停止 edit，不把 attempt 4 或其他失败稿上传。最终 `.r4` 只用固定 Image 1／2／3／4 regenerate；回到不可变 source cell／至少 `4px` 隔离合同，以宽容 inner target bounds 表达，取消仅作为前次修复手段的逐像素 hard-mask 额外门槛 | 内部失败；计 `4/5`；未进入用户复审、source 或 runtime |
| 5/5 | `CHAT.TABS.DARK.V1.r4` / `34c749e` | regenerate；固定 Image 1／2／3／4，无 Image 5 | session `019fcaf7-9154-7932-bc4c-19a6889931db`／provider cache `ig_0a5bf47a8d46be2a016a716662975c819182fd140b4e4ec041.png` | raw `generated/chat/core/CHAT.TABS.DARK.V1/attempt-05/CHAT_TABS_DARK_V1_r4_attempt05_raw.png`／`d4558459b490357a355fa95355c84906e4af79a9d925366a07683f17de165649`；keyed `…attempt05_keyed.png`／`5c1dc039940a12be229fd2f2427f9588d74dcb5f9fc80cc1deb81e5f5f98d001` | source cell／隔离合同失败：`125,257` 个可见像素在声明 cell 外；shelf 触底；normal 触左／底，hover 触底，selected／disabled 触右／底；strict mask 外 `169,424` | 预算耗尽，停止全部调用。不得裁切失败稿晋级；回看五稿时仅 attempt 3 满足原冻结 cell 与运行时门禁，提名为需用户明确接受的确定性合同例外候选 | 内部失败；计 `5/5`；循环关闭，未进入 source 或 runtime |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `CHAT.TABS.DARK.V1` / `d8df8d1` | 未创建 | 固定子进程输出 `Reading prompt from stdin...` 与 `No prompt provided via stdin.`；没有图片、provider result、上传完成或生成作业证据。固定 CLI `codex exec --help` 证明 `-i/--image <FILE>...` 是可变参数，末尾位置正文被最后一个 `-i` 吞作图片路径 | 不改正文、输入、顺序或输出合同；改为把同一已提交正文与独立 `Execution instruction` 从 stdin 传给固定 CLI，四张固定 SHA 图片仍通过 `-i` 上传 | 不占生图额度；仍为 `0/5`；同一正文重试一次 |
| E2 | `CHAT.TABS.DARK.V1` / `56e2055` | `019fcaca-f250-7312-91c4-869f25332f78` | stdin 已完整传入正文，但调用缺少执行器触发前缀与隔离条款；固定子进程在仓库工作目录重新读取同名 wrapper，随后因只读 sandbox 无法创建临时 workspace，最终明确报告 `No ImageGen call ran`；没有图片或 provider result | 不改正文、输入、顺序或输出合同；按仓库固定 Skill 创建空临时工作目录及 `generated/`，使用 `-C <temp> -s workspace-write`，在正文前恢复 `$imagegen` 触发词，并在独立 `Execution instruction` 禁止读取 wrapper、禁止启动 `codex`／`npx` 子进程，要求直接使用当前 0.143.0 内置 `image_gen` | 不占生图额度；仍为 `0/5`；以同一正文重试一次 |

### 完整生产正文 `CHAT.TABS.DARK.V1`（已授权；attempt 1 原样执行）

Create one transparent production master for the World of Warcraft Vanilla-era chat
channel tabs and their shared shelf. This is a component sheet, not a screenshot and not
a complete chat window. The only five visible objects are: one long horizontal leather
tab shelf, then four isolated wordless leather index-tab states in this exact order:
normal, hover, selected, disabled. Do not add any fifth tab, icon, label, rune, button,
book frame, message, input bar, unread seal, or decorative control.

Use Image 1 as the highest overall period and chat-module authority: retain the heavy,
hand-painted 2004-era fantasy UI language and the physical leather channel indexes visible
on the lower-left field journal. Ignore all combat scene content and every unrelated UI
module. Use Image 2 only for the same hand-painted bitmap thickness, material separation,
short highlights, contact shadows, and imperfect artisan edges. Ignore its giant symmetric
frame, dragon, spikes, pale central parchment, full gold outline, and all geometry unrelated
to a small leather tab or shelf. Use Image 3 only for the current accepted chat book's dark
walnut leather, warm-black smoked-brown palette, restrained oxidized brass temperature,
wear scale, top-left warm light, and the visual weight that these tabs must match. Do not
copy or redraw its book body. Use Image 4 as a strict technical scaffold: preserve its
1536 by 1024 canvas, pure-green background, five separated object locations, cell order,
outer bounds, and raised selected silhouette. Completely ignore its grayscale fills and
flat polygon rendering. The scaffold has no artistic authority.

Keep the canvas exactly 1536 by 1024. Keep the background uniformly pure #00FF00 with no
gradient, shadow, noise, texture, or green reflection outside the five objects. Place the
shelf only inside [64,96,1472,232]. Place normal only inside [64,560,384,716], hover only
inside [416,560,736,716], selected only inside [768,560,1088,716], and disabled only inside
[1120,560,1440,716]. Keep every cell isolated by untouched pure-green gaps. No visible
pixel may cross a cell boundary or touch the canvas edge.

All four tabs are the same physical old-leather index tab seen in four interaction states.
They share one external crop, baseline, thickness, cap anatomy, text-safe center, and
runtime hit geometry. Their silhouette is a squat, thick, slightly hand-irregular Vanilla
WoW index tab, not a flat rectangle, rounded web tab, pill, card, metal plaque, or Diablo
altar ornament. Use deep walnut and smoke-brown leather with darker compressed edges,
subtle pores, restrained wear at touched corners, a clear lower contact shadow, and only
small dull oxidized-brass or warm ochre accents. Lighting comes softly from the upper left.
The center remains wordless and quiet enough for runtime text.

Normal is the darkest active state and appears slightly recessed behind the shelf. Hover
keeps the same silhouette and gains only one short, local warm edge response; do not brighten
the whole perimeter. Selected rises slightly inside the same crop and presses naturally in
front of the shelf with a stronger contact shadow and one short muted warm highlight. It
must remain dark leather: do not place pale parchment, cream paper, a broad gold plate, or a
continuous bright strip beneath it. Disabled keeps the full readable silhouette but is
desaturated, lower-contrast, and has no active highlight. State differences must remain
legible after reduction to 92 by 30 pixels without using glow or neon.

The shelf is one thin, continuous, dark-walnut leather support strip viewed from the same
angle and light as the tabs. Its ends may contain small stitches or folds. Its long middle
must stay low-frequency and horizontally stretchable: no unique central buckle, rivet,
tear, seam endpoint, symbol, or repeated high-contrast ornament. The upper edge may have a
few broken, short, low-energy warm catches, but never a full-width pale page layer, bright
gold rail, ruler line, or modern progress-bar edge.

Within each tab cell, reserve approximately the leftmost and rightmost 62 source pixels for
fixed end-cap anatomy. Keep the middle stretch corridor low-frequency and free of unique
stitch endpoints, tears, rivets, letters, icons, and directional highlights. Keep the
runtime text corridor visually quiet; do not paint any character or placeholder glyph.
Materials must read through hand-painted light, midtone, shadow, thickness, wear, and
contact—not through clean vector borders or uniform gradients.

Use a low-saturation palette centered near dark walnut #251810, hover smoke-brown #302016,
selected dark warm leather #422A1A, disabled near-black brown #17110D, shelf #17100C, and
muted oxidized-brass highlights no brighter in area than a few short edge segments near
#A47A3F. These values describe palette roles, not flat fills. Preserve the aged, painted,
slightly uneven Vanilla bitmap character. Do not create transparent black glass, modern
HUD panels, sharp thin gold web borders, full-frame bevels, mirror symmetry, glossy metal,
photo-real antiques, skulls, demonic spikes, dragon ornaments, gemstones, glowing runes,
or permanent magic light.

Final self-check: exactly one shelf plus exactly four wordless state tabs; correct order and
separate cells; selected is dark leather without any pale paper underside; shelf has no
continuous bright rail; no dynamic content; quiet stretch centers; top-left warm light;
pure-green background remains perfectly uniform outside the five objects; no object crosses
its declared bounds.

### `CHAT.TABS.DARK.V1` attempt 1 执行与审查记录

- 日期：`2026-08-04`；固定执行器：`@openai/codex@0.143.0`，model
  `gpt-5.5`，reasoning `medium`；session
  `019fcace-7b01-7c13-a29a-3932e81da97e`；provider cache result
  `ig_081d682ab380e3a0016a715bd7ea2c8191b8b5ad8d4906d223.png`。child user block
  完整显示 `$imagegen`、已授权正文与固定 Image 1／2／3／4；没有递归子进程。
- 实际输入：四张授权绝对路径与 SHA 顺序均未改变；Image 5 未使用。执行器未报告
  revised prompt。
- raw：`1536 × 1024 RGB`，SHA-256
  `8b873a7475d5ac46e09c731983269691c41f7f26d6dfeb2e08d26be27158bbe8`。provider
  使用渐变亮绿而非均匀 `#00FF00`；确定性 `auto-key border + soft matte + despill`
  只使用本候选自身像素得到 `1536 × 1024 RGBA` keyed 候选，SHA-256
  `1d721a9e60f08da9ab89f1bd57216edf9b582b5c49e70267a6a19fbac5c2c8f8`；可见
  pure／dominant green 均为 `0`，透明 `1,255,568`、半透明 `5,179`、不透明
  `312,117`。
- 范围／身份：恰好一条 shelf 与四枚无字 Tab，顺序 normal／hover／selected／
  disabled；没有烘焙文字、图标、按钮、主框、输入框或其他对象，`pass`。
- 语义／物理／图层：均为同一厚旧皮革索引签的四态；selected 保持深皮革并在
  同一格位内抬升，底部接触阴影成立；shelf 与 Tab 视角、暖光和厚度一致，
  `pass`。
- 美术继承：深胡桃／烟熏棕旧皮革、手绘不完全规则边、有限暗哑暖边和低亮
  shelf 与当前 Full V1 书框一致；没有浅纸 selected、现代玻璃／胶囊／网页卡片、
  连续亮金导轨或暗黑式尖冠。`92 × 30px` 真实排版仍有香草时代实体重量，
  `pass`。
- 状态／安全区：四态综合色重可辨，中心无字且足够安静；shelf 中段在 `16px`
  运行时高度下保持低能量，`pass`。但源格位隔离失败：五个对象合计有
  `17,910` 个可见像素位于声明 cell 外；shelf 在 cell 内 bottom margin 为 `0`；
  normal／hover／selected／disabled 的 right／bottom margin 均为 `0`，五格全部
  触发 `<4px` 隔离失败。直接按 cell 裁切会切断底缝、右端折边和接触阴影。
- 真实排版工具：`tools/review_chat_tabs_dark_candidate_v1.py`。它只把 keyed
  候选按声明 cell 裁取、按计划 atlas／三段式规则确定性缩放，再叠加当前 tracked
  Full V1 书框、Dark V1 输入与动态真实文字；候选像素没有被重绘。
- `100%` 真实排版：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-01/review/candidate-real-layout.png`，
  `1060 × 510 RGBA`，SHA-256
  `8ffa2346ba6e31ab6c203fd7c6b06d045ca2e455cdd9e508189122446b837096`；包含
  `440 × 320` 四态／15 行与 `540 × 420`／22 行。候选与当前书框／输入的材质、
  综合色重、文字层序和两种宽度均成立；但预演明确按 cell 裁切，不能解除上述
  源像素越界。
- cell metrics：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-01/review/candidate-review.metrics.json`，
  SHA-256 `f13b07d691d4b3b39b36b857c4917a3c9b5e7824499dcd6034e6095bc906a445`；debug
  图为同目录 `candidate-cell-debug.png`。
- 实际展示区域：同目录 `display-region-contract.json`／
  `display-region-report.json`，报告 SHA-256
  `aa9407a6587ce6a023e49ee70b7e1eedbe98a4b3958744321ac440551a7758e1`；三个
  `440 × 320`／`540 × 420` 场景 `pass`，violations `0`。这只证明真实 Frame、
  Tab／hit／shelf 区域成立，不替代 source cell 隔离。
- 内部结论：`退回 / repair-prepared / P3`。第一失败门禁为组件 cell／隔离合同；
  不允许进入用户视觉复审、`assets/source/` 或 runtime。实际 ImageGen `1/5`，
  流程错误 `2`，剩余 `4` 次。
- `.r1` 修复决定：使用紧邻 attempt 1 raw 作为已授权 Image 5 edit。只保留其
  正确五对象、皮革材料、四态综合色重、短暖光和低亮 shelf；重建五对象完整
  外轮廓并缩回各自内层 safe bounds，至少留下 `16px` 纯绿色键隔离；不得通过
  裁掉端部、底缝或接触阴影伪造合格。固定 Image 1／2／3／4、Canvas、cell、
  runtime、状态顺序、视觉方向和禁止项不变。
- `.r1` 完整正文：`7396` UTF-8 bytes，SHA-256
  `40164ebbdccb69356374638bba70461f1efb61e210189a14dd02f7a474cd8db3`；执行前
  commit：包含本记录与完整正文的下一次 Git commit。

### 完整修复正文 `CHAT.TABS.DARK.V1.r1`（attempt 2；执行前必须原样传入）

Edit one production master for the World of Warcraft Vanilla-era chat channel tabs and
their shared shelf. This is a component sheet, not a screenshot and not a complete chat
window. The only five visible objects are exactly one long horizontal leather tab shelf,
then four isolated wordless leather index-tab states in this exact order: normal, hover,
selected, disabled. Do not add any fifth tab, icon, label, rune, button, book frame,
message, input bar, unread seal, or decorative control.

Use Image 1 as the highest overall period and chat-module authority: retain the heavy,
hand-painted 2004-era fantasy UI language and the physical leather channel indexes visible
on the lower-left field journal. Ignore all combat scene content and every unrelated UI
module. Use Image 2 only for hand-painted bitmap thickness, material separation, short
highlights, contact shadows, and imperfect artisan edges. Ignore its giant symmetric
frame, dragon, spikes, pale central parchment, full gold outline, and all geometry unrelated
to a small leather tab or shelf. Use Image 3 only for the current accepted chat book's dark
walnut leather, warm-black smoked-brown palette, restrained oxidized-brass temperature,
wear scale, top-left warm light, and matching visual weight. Do not copy or redraw its book
body. Use Image 4 as the strict technical scaffold: preserve its 1536 by 1024 canvas,
pure-green background role, five separated locations, cell order, inner object scale, outer
bounds, and raised selected silhouette. Ignore its grayscale fills and flat polygon
rendering; it has no artistic authority.

Image 5 is the immediately previous output from this same authorized loop. Preserve only
its successful visible art: exactly one shelf and four wordless tabs, the deep old-walnut
leather, smoke-brown midtones, compressed dark edges, hand-painted thickness, restrained
wear, short muted warm responses, selected dark-leather identity, disabled low contrast,
and the shelf's low brightness. Do not preserve Image 5's object positions or occupied
bounds. Its shelf crosses the bottom of its cell, all four tabs cross the bottom and right
of their cells, and its green background is not uniform. Move and proportionally reduce
each complete object, reconstructing full outer edges and contact shadows where required,
so no visible part is clipped or left outside the safe bounds below. Do not merely crop the
existing five objects at a boundary.

Keep the canvas exactly 1536 by 1024. Make every pixel outside the five complete objects
uniform pure #00FF00 with no gradient, shadow, noise, texture, reflection, vignette, or
color variation. The declared cells remain shelf [64,96,1472,232], normal
[64,560,384,716], hover [416,560,736,716], selected [768,560,1088,716], and disabled
[1120,560,1440,716]. In this repair, keep the complete visible shelf inside the stricter
inner safe bounds [80,112,1456,216]. Keep the complete normal tab inside
[80,576,368,700], hover inside [432,576,720,700], selected inside
[784,566,1072,700], and disabled inside [1136,576,1424,700]. These inner bounds leave at
least 16 pure-green pixels between each object and the corresponding declared cell edge;
the selected tab may rise ten pixels higher only within its stated inner bounds. No
visible pixel, antialiasing fringe, shadow, stitch, fold, leather edge, or glow may cross
an inner safe bound. Preserve complete silhouettes rather than clipping them.

All four tabs remain the same physical old-leather index tab seen in four interaction
states. They share the same declared cell size, baseline, thickness, cap anatomy,
text-safe center, and runtime hit geometry. Their silhouette is squat, thick, and slightly
hand-irregular in the Vanilla WoW manner, not a flat rectangle, rounded web tab, pill,
card, metal plaque, or Diablo altar ornament. Use deep walnut and smoke-brown leather with
darker compressed edges, subtle pores, restrained wear at touched corners, a complete
lower contact shadow, and only small dull oxidized-brass or warm-ochre accents. Lighting
comes softly from the upper left. Keep the center wordless, low-frequency, and quiet enough
for runtime text.

Normal is the darkest active state and appears slightly recessed behind the shelf. Hover
keeps the same complete silhouette and gains only one short local warm edge response; do
not brighten the whole perimeter. Selected rises slightly inside the same declared cell
and presses naturally in front of the shelf with a stronger complete contact shadow and
one short muted warm highlight. It remains dark leather: do not place pale parchment,
cream paper, a broad gold plate, or a continuous bright strip beneath it. Disabled keeps
the full readable silhouette but is desaturated, lower-contrast, and has no active
highlight. State differences must remain legible after reduction to 92 by 30 pixels
without glow, neon, or a different object size.

The shelf remains one thin, continuous, dark-walnut leather support strip viewed from the
same angle and light as the tabs. Its complete left and right ends may retain small stitches
or folds, but both ends and the complete lower contact edge must remain inside
[80,112,1456,216]. Its long middle stays low-frequency and horizontally stretchable: no
unique central buckle, rivet, tear, seam endpoint, symbol, or repeated high-contrast
ornament. The upper edge may have only a few broken, short, low-energy warm catches, never
a full-width pale page layer, bright gold rail, ruler line, or modern progress-bar edge.

Within each tab's complete silhouette, keep the left and right end-cap anatomy intact and
roughly equal. The middle stretch corridor must remain low-frequency and free of unique
stitch endpoints, tears, rivets, letters, icons, and directional highlights. Do not move
one end outside its inner safe bounds to make the tab appear wider. Do not crop side
stitches, bottom seams, rounded corners, raised selected edges, or contact shadows. Keep
all runtime text corridors unpainted; do not add any character or placeholder glyph.

Use a low-saturation palette centered near dark walnut #251810, hover smoke-brown #302016,
selected dark warm leather #422A1A, disabled near-black brown #17110D, shelf #17100C, and
muted oxidized-brass highlights occupying only a few short edge segments near #A47A3F.
These are palette roles, not flat fills. Preserve the aged, painted, slightly uneven
Vanilla bitmap character of the successful Image 5 materials. Do not create transparent
black glass, modern HUD panels, sharp thin gold web borders, full-frame bevels, mirror
symmetry, glossy metal, photo-real antiques, skulls, demonic spikes, dragon ornaments,
gemstones, glowing runes, or permanent magic light.

Final self-check before output: the canvas is exactly 1536 by 1024; there is exactly one
shelf plus exactly four wordless state tabs; order is normal, hover, selected, disabled;
all five complete silhouettes, antialiasing, shadows, stitches, and folds remain wholly
inside their stated inner safe bounds with at least 16 pixels of untouched pure #00FF00
isolation to every declared cell edge; no edge is cropped; selected is dark leather with
no pale paper underside; shelf has no continuous bright rail; there is no dynamic content;
stretch centers are quiet; light comes from the upper left; every background pixel outside
the five objects is perfectly uniform pure #00FF00.

### `CHAT.TABS.DARK.V1.r1` attempt 2 执行与审查记录

- 日期：`2026-08-04`；固定执行器 session
  `019fcadd-e641-7611-b53c-0adb9a4f0bbf`；provider cache result
  `ig_06e5b187b9e40f5c016a715fd12b2881919fed83df12f9044b.png`。完整 `.r1`、固定
  Image 1／2／3／4 与紧邻 attempt 1 raw Image 5 均出现在 child user block；无
  截断、无递归、无 revised prompt 报告。
- raw：`1536 × 1024 RGB`，SHA-256
  `0c82fb7ebdff8e46f76f735202cd4a03ddbd8fe33c227a620c7e8878c0d530e2`；同一
  确定性 chroma 流程得到 RGBA keyed，SHA-256
  `4352735f10ebca6d7adeef91ee34da0e63cb3453e74121906fb8a3061a9fb259`；透明
  `1,250,295`、半透明 `6,011`、不透明 `316,558`，可见 pure／dominant green
  均为 `0`。
- 范围、物件身份、物理／图层、美术继承和四态语义继续 `pass`：五对象无字，
  仍是同一深胡桃旧皮革索引签；selected 没有浅纸底，shelf 没有连续亮轨；与
  Full V1 书体匹配。没有新增现代控件或动态内容。
- 首要失败仍是 source cell／隔离合同，而且比 attempt 1 更明确：透明候选有
  `54,203` 个可见像素在五个声明 cell 外。shelf 在 cell 内 bottom margin `0`；
  四枚 Tab 的 right／bottom margin 全部 `0`。attempt 1 Image 5 的大外轮廓在 edit
  中仍被保留，精确 inner-safe-bounds 指令未落实；不得继续同一路径抽卡。
- `100%` 真实排版：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-02/review/candidate-real-layout.png`，
  SHA-256 `e6a3ef07d028d539920c652652fe74b3ba23aa8ee77f124001bf8d7939c638fb`；
  `440 × 320`／15 行与 `540 × 420`／22 行的综合色感、文字层序和邻接 UI 仍
  成立，但预演同样按声明 cell 裁切，不能修复 source 越界。
- metrics：同目录 `candidate-review.metrics.json`，SHA-256
  `6ef97da24b5febf9d6d50e1121565013c170776394a37dc97d5ad0b02ee9f368`。实际展示
  区域报告 `display-region-report.json`，SHA-256
  `e2997aa63f06178b2157715eb0f71890c3b2e0b3b6d933e2f00ad95779fc5e7f`；三个场景
  `pass`、violations `0`，但不替代失败的 source cell 门禁。
- 内部结论：`退回 / repair-prepared / P3`；实际 ImageGen `2/5`，流程错误
  `2`，剩余 `3` 次。不得进入用户复审、source 或 runtime。
- `.r2` 策略改变：`regenerate`，只上传固定 Image 1／2／3／4；不上传 attempt
  1／2 或其他 Image 5。Image 4 从“坐标参考”强化为逐像素二值绘制 mask：只有
  Image 4 的灰色 polygon 内允许产生物件像素；Image 4 的纯绿像素在输出中必须
  仍为纯绿。这样解除连续 edit 的大轮廓锚定，同时不改变任何冻结对象、Canvas、
  cell、状态、runtime 或美术方向。
- `.r2` 完整正文：`6374` UTF-8 bytes，SHA-256
  `1478ce499d0a6e36a6097fbb617dd6ea487084ce80a52542a8c603055e5d9dc0`；执行前
  commit：包含本记录与完整正文的下一次 Git commit。

### 完整修复正文 `CHAT.TABS.DARK.V1.r2`（attempt 3；执行前必须原样传入）

Generate one production master for the World of Warcraft Vanilla-era chat channel tabs
and their shared shelf. This is a component sheet, not a screenshot and not a complete
chat window. The only five visible objects are exactly one long horizontal leather tab
shelf, then four isolated wordless leather index-tab states in this exact order: normal,
hover, selected, disabled. Do not add any fifth tab, icon, label, rune, button, book frame,
message, input bar, unread seal, or decorative control.

Use Image 1 as the highest overall period and chat-module authority. Inherit its heavy,
hand-painted 2004-era fantasy UI language and the physical leather channel indexes on the
lower-left field journal. Ignore combat content and all unrelated UI. Use Image 2 only for
hand-painted bitmap thickness, material separation, short highlights, contact shadows,
and imperfect artisan edges. Ignore its giant symmetric frame, dragon, spikes, pale central
parchment, full gold outline, and unrelated geometry. Use Image 3 only for the accepted
chat book's dark-walnut leather, warm-black smoked-brown palette, restrained oxidized-brass
temperature, wear scale, upper-left warm light, and matching visual weight. Do not copy or
redraw its book body.

Use Image 4 as a strict pixel-position mask as well as the only geometry scaffold. Keep its
canvas exactly 1536 by 1024, keep exactly its five non-green polygon islands, and keep their
order and outer silhouettes. Every pixel that is pure green in Image 4 must remain uniform
pure #00FF00 in the output. Paint leather only inward from the existing gray polygon pixels
of Image 4. Never expand an object by one pixel into Image 4's green area. Keep shadows,
antialiasing, stitches, folds, highlights, wear, and every visible edge inside the non-green
polygon masks. Replace the gray fills with finished art, but do not move, enlarge, extend,
or add to the five masks. It is acceptable to soften or hand-irregularize an edge only by
removing pixels inward; never add pixels outward. No Image 5 is supplied or permitted for
this regeneration.

The declared source cells remain shelf [64,96,1472,232], normal [64,560,384,716], hover
[416,560,736,716], selected [768,560,1088,716], and disabled [1120,560,1440,716]. Image
4's five gray polygons already sit safely inside those cells, with pure-green isolation.
The final art must occupy only those gray polygon masks. The background outside them must
be perfectly uniform pure #00FF00: no gradient, vignette, noise, texture, shadow, green
reflection, or color variation. No visible pixel may cross a declared cell or touch the
canvas edge. Do not place any full-width floor, shared shadow, or connecting strip between
the four lower tab cells.

All four tabs are the same physical old-leather index tab in four interaction states. They
share one external cell size, baseline, thickness, cap anatomy, quiet text center, and
runtime hit geometry. Their silhouette follows Image 4: squat, thick, and slightly
hand-irregular in the Vanilla WoW manner, not a flat rectangle, rounded web tab, pill,
card, metal plaque, or Diablo altar ornament. Use deep walnut and smoke-brown leather with
darker compressed edges, subtle pores, restrained wear at touched corners, a lower contact
shadow contained inside the mask, and only small dull oxidized-brass or warm-ochre accents.
Lighting comes softly from the upper left. Keep every center wordless, low-frequency, and
quiet enough for runtime text.

Normal is the darkest active state and appears slightly recessed. Hover keeps the same
masked silhouette and gains only one short local warm edge response; do not brighten the
whole perimeter. Selected uses Image 4's already raised third polygon, with a stronger
contained contact shadow and one short muted warm highlight. It remains dark leather: no
pale parchment, cream paper, broad gold plate, or continuous bright strip beneath it.
Disabled keeps the full readable masked silhouette but is desaturated, lower-contrast,
and has no active highlight. State differences must remain legible after reduction to
92 by 30 pixels without glow, neon, or changing the mask size.

The shelf is one thin, continuous dark-walnut leather support strip inside Image 4's long
upper polygon. Its ends may have small stitches or folds contained inside that mask. Its
long middle must stay low-frequency and horizontally stretchable: no unique central buckle,
rivet, tear, seam endpoint, symbol, or repeated high-contrast ornament. The upper edge may
have only a few broken, short, low-energy warm catches. Never create a full-width pale page
layer, bright gold rail, ruler line, or modern progress-bar edge. Do not cast any shelf
shadow below the polygon mask.

Within each tab mask, keep the left and right end-cap anatomy intact and roughly equal.
Keep the middle stretch corridor free of unique stitch endpoints, tears, rivets, letters,
icons, and directional highlights. Do not paint any character or placeholder glyph. Keep
all stitches, bottom seams, rounded corners, selected edges, and contact shadows wholly
inside the mask. Materials must read through hand-painted light, midtone, shadow, thickness,
wear, and contact, not clean vector borders or uniform gradients.

Use a low-saturation palette centered near dark walnut #251810, hover smoke-brown #302016,
selected dark warm leather #422A1A, disabled near-black brown #17110D, shelf #17100C, and
muted oxidized-brass highlights occupying only a few short edge segments near #A47A3F.
These are palette roles, not flat fills. Preserve aged, painted, slightly uneven Vanilla
bitmap character. Do not create transparent black glass, modern HUD panels, sharp thin gold
web borders, full-frame bevels, mirror symmetry, glossy metal, photo-real antiques, skulls,
demonic spikes, dragon ornaments, gemstones, glowing runes, or permanent magic light.

Final self-check: canvas exactly 1536 by 1024; exactly one shelf and four wordless tabs;
correct normal, hover, selected, disabled order; every visible object pixel exists only
where Image 4 is non-green; every Image 4 pure-green pixel remains exactly pure #00FF00;
no shared shadow or object crosses a cell; all five silhouettes are complete and uncut;
selected remains dark leather without pale paper; shelf has no continuous bright rail;
no dynamic content; quiet stretch centers; upper-left warm light.

### `CHAT.TABS.DARK.V1.r2` attempt 3 执行与审查记录

- 日期：`2026-08-04`；固定执行器 session
  `019fcae5-7b4d-7821-ad93-50f848af382c`；provider cache result
  `ig_033f7c278ec1fe6d016a7161c121fc81918b9169596100fd54.png`。完整 `.r2` 与固定
  Image 1／2／3／4 出现在 child user block；没有 Image 5、截断、递归或 revised
  prompt 报告。
- raw：`1536 × 1024 RGB`，SHA-256
  `51c9045d08f8fbcdbdbcce532d257925336868676647f94856a4a7541cc260ed`；确定性
  chroma 后 RGBA keyed SHA-256
  `343cbfd6a2373e87024da23a9f7f7c8dcce36ad59522fc405068dd377966b391`；透明
  `1,286,152`、半透明 `5,345`、不透明 `281,367`，可见 pure／dominant green
  均为 `0`。
- source cell 合同首次完整 `pass`：声明 cell 外可见像素 `0`；shelf 的
  left／top／right／bottom margin 为 `15/18/15/15px`；normal 为
  `15/15/13/13px`，hover `14/14/13/13px`，selected `14/5/13/14px`，disabled
  `14/15/14/13px`。五对象均有至少 `4px` 防渗隔离，完整端部、底缝和阴影未被
  cell 裁断。
- 范围／物件身份、物理／图层、美术继承、四态、文字安全区和 shelf 伸缩语义
  均 `pass`：恰好五对象；深胡桃旧皮革与 Full V1 书体协调；selected 仍为深色
  皮革且抬升；hover／selected 的局部暖响应克制；disabled 降对比；无浅纸、
  连续亮轨、现代网页 Tab、动态文字或其他烘焙内容。
- `.r2` 自身追加的逐像素策略仍有窄边失败：相对 Image 4 的非绿色 polygon
  hard mask，有 `3,460` 个可见抗锯齿／外轮廓像素位于 mask 外；它们全部仍在
  原冻结 cell 内，但不能静默忽略已执行 `.r2` 的客观 self-check。
- `100%` 真实排版：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-03/review/candidate-real-layout.png`，
  SHA-256 `7b79ac2b26061cea10999a522bccc1328870b656033e494f94d20416c63dc89a`；
  `440 × 320`／15 行、`540 × 420`／22 行均与当前 tracked Full V1 书框和 Dark V1
  输入协调，综合色重、文字层序、四态辨识和两种宽度成立。
- metrics：同目录 `candidate-review.metrics.json`，SHA-256
  `ac4c7fa57cc72bd80611c03412b25e9417ee3a64cb82058fa158813d7f03486e`；实际展示
  区域报告 `display-region-report.json`，SHA-256
  `b569edd3da73d735693a24ab7c68fa5af0265eee1c61f400294d39ac323e7511`；三个场景
  `pass`、violations `0`。
- 内部结论：`退回 / repair-prepared / P3`，仅因 `.r2` strict scaffold-mask
  edge；实际 ImageGen `3/5`，流程错误 `2`，剩余 `2` 次。不得提前进入用户复审、
  source 或 runtime。
- `.r3` 决定：使用紧邻 attempt 3 raw 作为授权 Image 5 edit，冻结全部已通过的
  对象身份、材料纹理、状态配色、短高光、无字中心、shelf 与整体位置；只把每个
  完整轮廓等比缩小并居中到比 Image 4 mask 再内收 `2–4px` 的目标 bounds。不得
  裁边或重绘成另一套 Tab。
- `.r3` 完整正文：`6356` UTF-8 bytes，SHA-256
  `856992b3d03442a4dff24c667843a15186b66bce2e8072b600e7eda38b9378aa`；执行前
  commit：包含本记录与完整正文的下一次 Git commit。

### 完整修复正文 `CHAT.TABS.DARK.V1.r3`（attempt 4；执行前必须原样传入）

Edit one production master for the World of Warcraft Vanilla-era chat channel tabs and
their shared shelf. This is a component sheet, not a screenshot and not a complete chat
window. The only five visible objects are exactly one long horizontal leather tab shelf,
then four isolated wordless leather index-tab states in this exact order: normal, hover,
selected, disabled. Do not add any fifth tab, icon, label, rune, button, book frame,
message, input bar, unread seal, or decorative control.

Use Image 1 as the highest overall period and chat-module authority: retain the heavy,
hand-painted 2004-era fantasy UI language and the physical leather channel indexes visible
on the lower-left field journal. Ignore combat content and unrelated UI. Use Image 2 only
for hand-painted bitmap thickness, material separation, short highlights, contact shadows,
and imperfect artisan edges. Ignore its giant symmetric frame, dragon, spikes, pale central
parchment, full gold outline, and unrelated geometry. Use Image 3 only for the accepted
chat book's dark-walnut leather, warm-black smoked-brown palette, restrained oxidized-brass
temperature, wear scale, upper-left warm light, and matching visual weight. Do not copy or
redraw its book body. Use Image 4 only as the strict 1536 by 1024 geometry scaffold and
non-green polygon mask; ignore its gray fills as art.

Image 5 is the immediately previous output from this authorized loop. It is the visual
donor for this narrow edit. Preserve its exact successful art direction and recognizable
surface treatment: exactly one shelf and four wordless tabs; dark old-walnut leather;
smoke-brown midtones; compressed dark edges; inset seams; restrained stitches; subtle wear;
upper-left warm light; short muted hover and selected responses; selected remaining dark
leather; disabled low contrast; low-brightness shelf; no modern or unrelated object. Do
not redesign the tabs, change materials, replace their edge anatomy, add ornament, remove
state distinctions, or alter their order.

The only correction is a small proportional inward fit. Rebuild each complete Image 5
object at the same center and visual proportions, including all antialiasing, shadows,
stitches, folds, seams, highlights, and wear, but keep every visible pixel inside these
stricter target bounds: shelf [84,118,1452,212], normal [84,580,364,696], hover
[436,580,716,696], selected [788,570,1068,696], disabled [1140,580,1420,696]. Fill most
of each target bound without crossing it. Scale the complete object inward; do not crop,
erase one side, flatten the bottom seam, cut a stitch, or leave a detached shadow. Keep
normal, hover, and disabled on one baseline. Keep selected raised ten pixels within its
own target bound. Do not move any object to a different cell.

The declared cells remain shelf [64,96,1472,232], normal [64,560,384,716], hover
[416,560,736,716], selected [768,560,1088,716], and disabled [1120,560,1440,716]. The
stricter target bounds above sit inside Image 4's non-green masks and leave additional
pure-green isolation. No visible object pixel, antialiasing fringe, shadow, stitch, fold,
seam, highlight, wear mark, or glow may cross a target bound. Every other canvas pixel must
be exactly uniform pure #00FF00 with no gradient, vignette, noise, texture, reflection,
shared floor, or color variation. Keep the canvas exactly 1536 by 1024.

All four tabs remain the same physical old-leather index tab in four interaction states.
They share cell size, baseline, thickness, cap anatomy, quiet text center, and runtime hit
geometry. Preserve Image 5's squat, thick, slightly hand-irregular Vanilla WoW silhouette;
do not turn it into a flat rectangle, rounded web tab, pill, card, metal plaque, or Diablo
altar ornament. Keep the complete lower contact shadow inside each target bound. Keep the
center wordless, low-frequency, and quiet enough for runtime text.

Normal remains the darkest active state and slightly recessed. Hover retains only its one
short local warm response, never a bright full perimeter. Selected retains its raised dark
leather body, stronger contained contact shadow, and one short muted warm highlight; no
pale parchment, cream paper, broad gold plate, or continuous bright strip. Disabled retains
the full silhouette with desaturated lower contrast and no active highlight. Preserve
legibility at 92 by 30 pixels without glow, neon, or different runtime geometry.

The shelf remains one thin continuous dark-walnut leather support strip. Preserve its
small end stitches or folds and low-energy surface, but fit all of them inside
[84,118,1452,212]. Its long middle remains low-frequency and horizontally stretchable:
no unique central buckle, rivet, tear, seam endpoint, symbol, or repeated high-contrast
ornament. Keep only broken short warm catches, never a full-width pale page layer, bright
gold rail, ruler line, modern progress-bar edge, or shadow outside the target bound.

Keep left and right tab end-cap anatomy intact and roughly equal. Keep each middle stretch
corridor free of unique stitch endpoints, tears, rivets, letters, icons, and directional
highlights. Do not paint any character or placeholder glyph. Materials continue to read
through hand-painted light, midtone, shadow, thickness, wear, and contact rather than clean
vector borders or uniform gradients.

Keep the low-saturation Image 5 palette centered near dark walnut #251810, hover
smoke-brown #302016, selected dark warm leather #422A1A, disabled near-black brown
#17110D, shelf #17100C, and only small muted oxidized-brass accents near #A47A3F. Do not
create transparent black glass, modern HUD panels, thin gold web borders, full-frame
bevels, mirror symmetry, glossy metal, photo-real antiques, skulls, demonic spikes, dragon
ornaments, gemstones, glowing runes, or permanent magic light.

Final self-check: canvas exactly 1536 by 1024; exactly one shelf and four wordless tabs in
normal, hover, selected, disabled order; every complete visible object and edge effect stays
inside its stated stricter target bound; no object is cropped; all other pixels are uniform
pure #00FF00; selected remains raised dark leather without pale paper; shelf has no
continuous bright rail; no dynamic content; quiet stretch centers; upper-left warm light;
Image 5's accepted material and state language are otherwise unchanged.

### `CHAT.TABS.DARK.V1.r3` attempt 4 执行与审查记录

- 日期：`2026-08-04`；固定执行器 session
  `019fcaef-337c-71b3-8292-dcef6a9b7df1`；provider cache result
  `ig_08366a92bf4238f6016a71644251ec819199e37c59741356a0.png`。完整 `.r3`、固定
  Image 1／2／3／4 和紧邻 attempt 3 raw Image 5 均完整传入；无截断、递归或
  revised prompt 报告。
- raw：`1536 × 1024 RGB`，SHA-256
  `cf4227c9fffd2696531fa38b33e37faf784952f4b9d4116cd393067021203347`；确定性
  chroma 后 RGBA keyed SHA-256
  `c5836ad4436166f4cf8d016ddea383ee1f61907d92c46e88fdcb0e5c1322e71d`；透明
  `1,238,309`、半透明 `5,571`、不透明 `328,984`，可见 pure／dominant green
  均为 `0`。
- 五对象、材料、四态和邻接书框综合色感仍可辨，但首要 cell 门禁再次失败：
  `43,099` 个可见像素在声明 cell 外；shelf bottom margin `0`；normal／hover／
  selected／disabled 的 right／bottom margin 全为 `0`。Image 5 edit 把大轮廓
  锚定重新带回，未执行 `.r3` target bounds；strict scaffold mask 外像素增至
  `88,660`。
- `100%` 真实排版：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-04/review/candidate-real-layout.png`，
  SHA-256 `71df248488c1eab45fbc41ed50b3a2dd418461c2d3f5d0fb9beb224bd87314ae`；
  当前书框／输入、`440 × 320` 和 `540 × 420` 动态排版本身仍可装配，但本预演
  明确裁至声明 cell，不能恢复被截的 source 外缘。
- metrics：同目录 `candidate-review.metrics.json`，SHA-256
  `46bd8b2280d3d41603ac4c936d2de43f108e28a24d8e004335d63cee736124ed`；实际展示
  区域报告 `display-region-report.json`，SHA-256
  `0b4fff717f4979620ba5e365f8513b89b786d111273bdb8c89cf466f97fbef4e`；三个场景
  `pass`、violations `0`，不替代 cell 失败。
- 内部结论：`退回 / repair-prepared / P3`；实际 ImageGen `4/5`，流程错误
  `2`，只余最终 `1` 次。不得进入用户复审、source 或 runtime。
- `.r4` 最终策略：只用固定 Image 1／2／3／4 从零 regenerate，不上传任何
  Image 5。Image 4 保持五对象位置／比例参考；验收回到原不可变合同：完整可见
  像素必须位于声明 cell 并留至少 `4px` 隔离。用比 cell 内缩 `8–12px` 的宽容
  target bounds 指导模型，不再把上次为解除锚定而增加的逐像素 hard-mask 当成
  独立终态合同。对象、状态、Canvas、runtime、视觉权威、Alpha／色键和禁止项
  全部不变。
- `.r4` 完整正文：`6144` UTF-8 bytes，SHA-256
  `7217f12ae73de60c5294579b2d905da7ad5cf9f841608ef47e82ca2480b74296`；执行前
  commit：包含本记录与完整正文的下一次 Git commit。

### 完整修复正文 `CHAT.TABS.DARK.V1.r4`（attempt 5；执行前必须原样传入）

Generate one production master for the World of Warcraft Vanilla-era chat channel tabs
and their shared shelf. This is a component sheet, not a screenshot and not a complete
chat window. The only five visible objects are exactly one long horizontal leather tab
shelf, then four isolated wordless leather index-tab states in this exact order: normal,
hover, selected, disabled. Do not add any fifth tab, icon, label, rune, button, book frame,
message, input bar, unread seal, or decorative control.

Use Image 1 as the highest overall period and chat-module authority. Inherit its heavy,
hand-painted 2004-era fantasy UI language and physical leather channel indexes on the
lower-left field journal. Ignore combat content and unrelated UI. Use Image 2 only for
hand-painted bitmap thickness, material separation, short highlights, contact shadows,
and imperfect artisan edges. Ignore its giant symmetric frame, dragon, spikes, pale central
parchment, full gold outline, and unrelated geometry. Use Image 3 only for the accepted
chat book's dark-walnut leather, warm-black smoked-brown palette, restrained oxidized-brass
temperature, wear scale, upper-left warm light, and matching visual weight. Do not copy or
redraw its book body. Use Image 4 as the strict 1536 by 1024 technical layout scaffold for
five separated locations, proportions, cell order, and the raised selected silhouette.
Ignore its gray flat fills as art. No Image 5 is supplied or permitted.

Keep the canvas exactly 1536 by 1024. The declared cells are shelf [64,96,1472,232],
normal [64,560,384,716], hover [416,560,736,716], selected [768,560,1088,716], and
disabled [1120,560,1440,716]. Keep each complete object, including antialiasing, contact
shadow, stitches, folds, seams, highlights, and wear, inside these comfortable inner target
bounds: shelf [76,108,1460,220], normal [76,572,372,704], hover [428,572,724,704],
selected [780,568,1076,704], disabled [1132,572,1428,704]. Fill most of each inner target
bound without crossing it. These targets leave at least 8 pixels of pure-green isolation
inside every declared cell. Do not crop an object at a target edge, connect lower cells,
or cast a shared shadow between them.

Every canvas pixel outside the five complete objects must be uniform pure #00FF00 with no
gradient, vignette, noise, texture, reflection, shared floor, or color variation. No visible
pixel may cross a declared cell or touch the canvas edge. The five objects may use softly
antialiased hand-painted edges, but all such pixels must remain inside their inner target
bounds. Preserve each entire silhouette by drawing it small enough; never hide overflow
through clipping.

All four tabs are the same physical old-leather index tab in four interaction states. They
share one external cell size, baseline, thickness, cap anatomy, quiet text center, and
runtime hit geometry. Follow Image 4's squat, thick, slightly hand-irregular Vanilla WoW
silhouette, not a flat rectangle, rounded web tab, pill, card, metal plaque, or Diablo
altar ornament. Use deep walnut and smoke-brown leather with compressed dark edges, subtle
pores, restrained touched-corner wear, a lower contact shadow contained inside each inner
target, and only small dull oxidized-brass or warm-ochre accents. Lighting comes softly
from the upper left. Keep every center wordless, low-frequency, and quiet enough for
runtime text.

Normal is the darkest active state and appears slightly recessed. Hover keeps the same
complete silhouette and gains only one short local warm response; do not brighten the
whole perimeter. Selected uses the raised third location, remains inside
[780,568,1076,704], and has a stronger contained contact shadow plus one short muted warm
highlight. It remains dark leather: no pale parchment, cream paper, broad gold plate, or
continuous bright strip beneath it. Disabled keeps the full silhouette but is desaturated,
lower-contrast, and has no active highlight. State differences remain legible after
reduction to 92 by 30 pixels without glow, neon, or different runtime geometry.

The shelf is one thin continuous dark-walnut leather support strip inside
[76,108,1460,220]. Its ends may have small stitches or folds inside that target. Its long
middle stays low-frequency and horizontally stretchable: no unique central buckle, rivet,
tear, seam endpoint, symbol, or repeated high-contrast ornament. The upper edge may have
only a few broken, short, low-energy warm catches. Never create a full-width pale page
layer, bright gold rail, ruler line, modern progress-bar edge, or shadow outside the target.

Keep left and right tab end-cap anatomy intact and roughly equal. Keep each middle stretch
corridor free of unique stitch endpoints, tears, rivets, letters, icons, and directional
highlights. Do not paint any character or placeholder glyph. Keep all seams, rounded
corners, selected edges, and contact shadows inside the target bounds. Materials must read
through hand-painted light, midtone, shadow, thickness, wear, and contact, not clean vector
borders or uniform gradients.

Use a low-saturation palette centered near dark walnut #251810, hover smoke-brown #302016,
selected dark warm leather #422A1A, disabled near-black brown #17110D, shelf #17100C, and
only small muted oxidized-brass accents near #A47A3F. Preserve aged, painted, slightly
uneven Vanilla bitmap character. Do not create transparent black glass, modern HUD panels,
thin gold web borders, full-frame bevels, mirror symmetry, glossy metal, photo-real
antiques, skulls, demonic spikes, dragon ornaments, gemstones, glowing runes, or permanent
magic light.

Final self-check: canvas exactly 1536 by 1024; exactly one shelf and four wordless tabs in
normal, hover, selected, disabled order; every complete visible object and edge effect is
inside its stated inner target and therefore inside its declared cell with at least 8
pure-green pixels of isolation; no object is cropped; all other pixels are uniform pure
#00FF00; selected is raised dark leather without pale paper; shelf has no continuous bright
rail; no dynamic content; quiet stretch centers; upper-left warm light.

### `CHAT.TABS.DARK.V1.r4` attempt 5 执行与审查记录

- 日期：`2026-08-04`；固定执行器 session
  `019fcaf7-9154-7932-bc4c-19a6889931db`；provider cache result
  `ig_0a5bf47a8d46be2a016a716662975c819182fd140b4e4ec041.png`。完整 `.r4` 与固定
  Image 1／2／3／4 均完整传入；没有 Image 5、截断、递归或 revised prompt
  报告。本次是授权内第 `5/5` 次实际 ImageGen。
- raw：`1536 × 1024 RGB`，SHA-256
  `d4558459b490357a355fa95355c84906e4af79a9d925366a07683f17de165649`；确定性
  chroma 后 RGBA keyed SHA-256
  `5c1dc039940a12be229fd2f2427f9588d74dcb5f9fc80cc1deb81e5f5f98d001`；透明
  `1,231,600`、半透明 `14,019`、不透明 `327,245`。
- 首要 source cell／隔离门禁失败：声明 cell 外可见像素 `125,257`，strict
  scaffold mask 外 `169,424`。shelf margin 为 `12/68/11/0px`，触底；normal
  为 `0/52/16/0px`，触左／底；hover 为 `4/52/7/0px`，触底；selected 为
  `18/30/0/0px`，触右／底；disabled 为 `42/52/0/0px`，触右／底。五对象全部
  被列为 isolation failure，不能通过裁切或忽略格位外像素晋级。
- `100%` 真实排版：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-05/review/candidate-real-layout.png`，
  SHA-256 `ba9149b28c2aaea76616bf152642062915fbe11e156e727ab8e5e7dd8da2f0f9`；
  当前书框／输入、`440 × 320`／15 行与 `540 × 420`／22 行场景可装配，但预演
  按声明 cell 裁取，不能修复 source 外缘缺失。
- metrics：同目录 `candidate-review.metrics.json`，SHA-256
  `fecb1025d3675954f3e8aef9453a7e7082033c09809f7a838a0e0dc0223bd99f`；实际展示
  区域报告 `display-region-report.json`，SHA-256
  `9c01a358c03241001926d9cbc786617884060e85966b65bb94fa1dc52e767e19`；三个场景
  `pass`、violations `0`，不替代 source cell 失败。
- 内部结论：`退回 / repair-budget-exhausted / P3`；实际 ImageGen `5/5`，流程
  错误 `2`。授权批次关闭，不得执行 attempt 6；attempt 5 不进入用户候选、
  source、TGA 或 runtime。

### 循环终态与用户复审候选

- 五次实际生成中，attempt 3 是唯一满足原冻结生产合同且可供用户审视的版本：
  声明 cell 外可见像素 `0`；shelf／normal／hover／selected／disabled 的最小
  边距分别为 `15/13/13/5/13px`，均达到至少 `4px` 隔离；对象身份、深胡桃旧
  皮革、四态、无浅纸 selected、无连续亮带 shelf、真实 `440 × 320`／
  `540 × 420` 排版和三个 display-region 场景全部通过。
- attempt 3 没有被内部直接接受，因为 `.r2` 当次正文为修复前两稿的大轮廓锚定，
  额外要求逐像素服从 Image 4 非绿 polygon hard-mask；其有 `3,460` 个抗锯齿／
  外轮廓边缘像素超出该临时 mask，但这些像素全部仍位于原冻结 cell 内。该差异
  不能由 Codex 静默豁免，只能由用户明确接受为确定性合同例外。
- 待审 source 候选：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-03/CHAT_TABS_DARK_V1_r2_attempt03_keyed.png`，
  SHA-256 `343cbfd6a2373e87024da23a9f7f7c8dcce36ad59522fc405068dd377966b391`。
- 待审真实排版：
  `generated/chat/core/CHAT.TABS.DARK.V1/attempt-03/review/candidate-real-layout.png`，
  SHA-256 `7b79ac2b26061cea10999a522bccc1328870b656033e494f94d20416c63dc89a`。
- 历史状态曾为 `exception-candidate / user-review-required / P3`；用户于
  `2026-08-04` 明确否决其过于规整的轮廓，现已转为
  `candidate-rejected / user-rejected / P3`。attempt 3 不得进入 P4、不得导出
  TGA、不得修改 Lua，也不得作为 V2 的 edit 输入。现行 V3 runtime 保留。

## `CHAT.TABS.DARK.V2` 旧式皮革索引签轮廓收敛

### 否决边界与新方向

- 用户原文：`不行. 这个tab的样式太工整了. 参考一下旧的tab样式`。
- V1 第一个失败门禁：`silhouette / physical-object identity`。attempt 3 虽通过
  cell、隔离、排版和展示区域，但四枚 Tab 的直边矩形、等高顶线、镜像端帽和
  规则内框先被读成现代网页标签；这不是颜色或微纹理修复可以解决的问题。
- V2 继承旧 V3 的物理语法而不复制旧像素：紧凑斜梯形皮革索引签、手切波动
  顶边、向外踢出的下角、不等距缝线、单侧修补结、selected 在不改变外接框时
  略抬并露出一小段被烟熏压暗的夹页层。四枚标签仍是同一造型家族，不变成
  四个不同按钮。
- 继续冻结：深胡桃／烟褐皮革为主，selected 不得出现大面积浅纸，shelf 不得
  出现贯穿亮金线；runtime 每枚 `92 × 30px`、间距 `3px`、底部 `8px` 命中
  扩展、shelf `frameWidth-60 × 16px @ TOPLEFT(30,18)` 均不变。动态文字仍由
  runtime 居中绘制。
- V2 尚未有生产 Prompt、scaffold、上传输入、ImageGen 预算或 source/runtime；
  V1 的五次生成和两次流程错误不转移到 V2。

### 生成前模拟 `CHAT.TABS.DARK.SIM.V2`

- renderer：`tools/render_chat_tabs_dark_simulation_v1.py`；specification：
  `tools/specs/chat_tabs_dark_simulation_v2.json`。macOS 使用已验证解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，Python `3.12.12`；命令：
  `conda run -n py312 python tools/render_chat_tabs_dark_simulation_v1.py tools/specs/chat_tabs_dark_simulation_v2.json`。
- 输出：
  `generated/chat/core/CHAT.TABS.DARK.V2/simulation/CHAT-TABS-DARK-SIM-V2/chat_tabs_dark_sim_v2.png`，
  `1620 × 570 RGBA`，SHA-256
  `eeb1c2944ec3794fe462dc6d1812a13ae0c34a2c43508291f38043c8d66ecc86`；metrics
  SHA-256 `c8f810fdda8f456004570078c571ec0012a51247e816673463598f77522ffc11`。
  `/private/tmp` 独立重放得到同一 PNG SHA。
- 三个真实实例：左侧使用当前 tracked V3 runtime，只作为旧式轮廓／物理关系
  对照；中间为 V2 四状态 `440 × 320`；右侧为 V2 `540 × 420`／22 行扩展。
  Full V1 主框、Dark V1 输入、真实中文排版和经典 provider 颜色都来自当前
  tracked runtime。V2 Tab／shelf 只用本地 polygon／line／平面色表达方向。
- display-region contract：
  `tools/specs/chat_tabs_dark_sim_display_region_v2.json`；报告：
  `generated/chat/core/CHAT.TABS.DARK.V2/simulation/CHAT-TABS-DARK-SIM-V2/display-region-report.json`，
  SHA-256 `95e1c76a134d560e4f9eaaaf9541708f17724a6d902cdfb61407d88cfd090cfc`。
  三场景全部 `pass`，violations `0`。
- ImageGen：`0/0`；外部上传：`0`；addon／TGA／Lua／TOC／SavedVariables：未改。
- 内部结论：`displayable / simulation-reviewed / P2`。本图只能让用户判断轮廓、
  状态重量、Tab 与 shelf／主框的图层关系及真实尺度；polygon 边缘、平涂、
  缝线像素、Alpha 和磨损不是最终美术证据，禁止进入 source/runtime 或作为
  ImageGen 输入。
- 模拟展示时的门禁曾是用户确认／否决；用户已在本轮回复“继续”完成方向
  确认。当前门禁改为下方精确 V2 生产正文的独立授权。

### 用户方向确认

- 具体模拟版本：`CHAT.TABS.DARK.SIM.V2`。
- 用户结论／日期：`2026-08-04 / confirmed`；用户在看到左侧旧 V3 轮廓对照、
  中间 `440 × 320` 四状态与右侧 `540 × 420` 扩展实例后回复“继续”。
- 已冻结并写入生产正文的可见条款：Tab 必须首先像夹进战地旧书上沿的手切
  皮革索引签；恢复旧 V3 的略斜梯形、外撇下角、不齐顶边、非机械缝线和
  selected 夹页／承托关系；综合色仍为深胡桃烟褐，selected 只露少量压暗
  夹页而非浅纸牌，shelf 不出现贯穿亮金线；四枚 `92 × 30px`、原间距、原
  命中区和书框层序不变。
- 未接受内容：模拟 polygon、平涂、字体栅格、缝线像素、Alpha、atlas 切片和
  微观磨损；模拟 PNG 继续禁止裁切、晋级或上传为生产输入。
- 确认失效条件：改回规整矩形牌、浅色 selected、连续亮金 shelf，或改变
  Tab／shelf 的可见物件身份、综合色、尺寸、层序和交互状态语义时，必须重新
  模拟。仅完善 source cell、色键和切片合同不使本确认失效。
- 下一门禁已推进为：用户审视并独立授权下方精确
  `CHAT.TABS.DARK.V2` 生产正文、四张固定输入、冻结修复边界和最多五次实际
  ImageGen 调用。

### V2 美术继承与固定输入职责

权威顺序与组件级转译：

1. `assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
   `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`，以及
   `ART_BASELINE.md`／`SUBMODULE_ART_BASELINES.md`：最高时代、物件身份和
   游戏内综合色权威。继承 2004 年前后香草二维手绘位图、紧凑索引签、粗厚
   手工边、左上暖光和战地旧书关系；忽略图中其他战斗 HUD、角色、动作条、
   地图、任务追踪和动态文字。
2. `assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
   `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`，及同一
   Chat Prompt provenance：只继承二维位图实体厚度、材料切面、短促暖光、
   手绘误差和磨损尺度；不继承巨型框、龙饰、尖冠、规则槽、镜像建筑和浅色
   大纸面。本图不作为本次上传输入，其稳定 DNA 已完整写入正文。
3. `docs/GLOBAL_ART_BASELINE.md`：香草原结构先于 overhaul 装饰；深胡桃旧
   皮革、暖赭烟褐纸、少量氧化黄铜；禁止现代网页 Tab、玻璃、胶囊、精密
   工业网格和暗黑 3 式黑铁尖冠。
4. `SUBMODULES.md` 与当前 adapter：一枚可横向延展 shelf、四状态 Tab，固定
   `92 × 30px`／`3px` 间距／`2px` 顶偏移／`8px` 底部命中扩展，shelf 为
   `frameWidth-60 × 16px @ TOPLEFT(30,18)`；文字由 runtime 居中绘制。
5. `assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png`，SHA-256
   `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673`：只提供
   当前相邻书体的深胡桃皮革、暖黑烟褐、纤维／磨损尺度和左上暖光连续性；
   不能提供 Tab 几何，也不能把完整书框画入 sheet。
6. `assets/source/chat/v3/ChatTabs_Master_v3.png`，SHA-256
   `8172d9d5145ac16ed23913fb7fbf75e626e0976d6bb33b27a555de4c55853023`：只提供
   用户重新指定的旧式轮廓和物理关系——斜梯形、外撇下角、不齐缝线、
   selected 抬起并露夹页、Tab 压在 shelf 前；忽略其浅色 selected、连续
   金亮页边、旧综合色和过亮缝线。
7. `CHAT_TABS_DARK_V2_scaffold.png`：只冻结 `1536 × 1024` canvas、五个逻辑
   cell、对象顺序和纯绿隔离；灰阶、polygon、明暗和精确边缘没有美术权威。
   V2 生成前模拟 PNG 不在上传范围。

V1 attempt 1–5 全部只作为负面证据：尤其禁止 attempt 3 的四个规则直边矩形、
完整内框、镜像端帽和机器式等距缝线。任何 V1 raw／keyed／review 图都不上传，
也不得作为 V2 edit 输入。

### V2 组件与 source／runtime 合同

- 逻辑对象固定为五个：一枚 `CHAT.TAB_SHELF`；normal、hover、selected、
  disabled 四枚无字 `CHAT.TABS` 状态。sheet 之外没有其他对象。
- 源画布固定 `1536 × 1024 RGBA/RGB`，纯色键背景 `#00FF00`。cell：shelf
  `[64,96,1472,232]`；normal `[64,560,384,716]`；hover
  `[416,560,736,716]`；selected `[768,560,1088,716]`；disabled
  `[1120,560,1440,716]`。每个对象必须完整留在自己的 cell，任何非绿像素
  不得跨 cell；对象与 cell 边至少保留 `4px`，目标为 `8px` 以上。
- 四个 Tab crop 均为 `320 × 156px`，确定性缩放为 `248 × 120px` 后装入
  `512²` 四行 atlas，再以三段式绘制为 `92 × 30px`。约前／后各 `62px`
  source 只承担端帽、外撇角、修补结和独特磨损；中间约 `196px` 必须低频、
  无文字、无符号、无独特裂口或缝线终点并可横向延展。
- 每个 Tab 的中央文字走廊保持平静：最终 runtime 水平各留 `6px`，文字区高
  `18px`；高对比缝线、结、铆钉和裂口只放端帽。四态使用同一 `92 × 30px`
  Button、文字中心和点击几何；selected 的抬升／夹页必须发生在不变画布内。
- shelf crop 为 `1408 × 136px`，确定性缩放至 `1016 × 56px` 后装入
  `1024 × 64px` atlas，在 runtime 横向延展为 `frameWidth-60 × 16px`。两端
  可以有小型修补，中央必须低频连续且无唯一标记；不允许连续亮金导线。
- z-order 固定：Full V1 主框在后，shelf 在其上，四枚 Tab 在 shelf 前，动态
  TabText 最前；未读、正文和输入仍由现有独立对象持有。
- Alpha 策略：生成时允许纯 `#00FF00` 色键；候选通过后只按候选自身像素做
  确定性色键转 Alpha，全透明 RGB 清零。不得把 scaffold、模拟、旧 V3 或
  Full V1 像素合成进候选。
- 禁止烘焙：任何文字、频道名、图标、符号、未读标、书框、正文、输入条、
  按钮、滚动／复制／语言控件、背景场景、标签或 sheet 说明。
- fallback：P4/P5 前继续加载 `ChatTabAtlasV3.tga`／`ChatTabShelfV3.tga`；
  本阶段不修改 Lua、TGA、TOC、pfUI、ChatMOD 或 SavedVariables。

### V2 独立生产技术 scaffold（尚未上传）

- specification：`tools/specs/chat_tabs_dark_production_scaffold_v2.json`；renderer：
  `.codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py`；macOS
  命令：`conda run -n py312 python .codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py tools/specs/chat_tabs_dark_production_scaffold_v2.json --repo-root .`。
- 输出：
  `generated/chat/core/CHAT.TABS.DARK.V2/production-scaffold/CHAT_TABS_DARK_V2_scaffold.png`，
  `1536 × 1024 RGBA`，SHA-256
  `f02fba2d8bf4bc3a7b117d1245a794d4288c81c54c3f93e50290e5fefd9565a9`。
- 非绿像素全部位于五个声明 cell，cell 外为 `0`。scaffold bbox／cell 边距：
  shelf `[80,110,1457,217]`，最小 `14px`；normal `[76,570,373,703]`，最小
  `10px`；hover `[428,569,725,703]`，最小 `9px`；selected
  `[780,566,1073,705]`，最小 `6px`；disabled `[1132,572,1429,705]`，最小
  `11px`。这些 polygon 只表达不规则皮签与 selected 夹页的技术占位，不是
  必须逐像素服从的 hard mask。
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`。
- ImageGen `0/0`；上传 `0`。只有用户授权下方精确正文后，scaffold 才可作为
  固定 Image 4；V2 模拟 PNG 永不上传。

### `CHAT.TABS.DARK.V2` 生产正文完整性预检

- 复杂度：`atlas + four states + horizontal-three-slice + stretch`。
- 结论：`pass / production-draft`。未知但执行必需的值：无。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | 首段与 inventory 固定为一条 shelf＋四态无字皮签，并逐项排除书框、文字、图标和其他控件 | pass |
| 每张输入图的 inherit／ignore 职责与权威冲突 | Image 1–4 分别锁定时代身份、材料连续性、旧轮廓关系与技术 cell；每张均写明忽略项，文字基线优先 | pass |
| 画布、格位、边距、方向、透视、尺度、光照与层序 | 精确 `1536×1024`、五 cell、纯绿隔离、正交前视、左上暖光及 shelf／Tab 层序全部显式 | pass |
| 逐对象形态、材料、边缘、状态与相互关系 | shelf 与 normal／hover／selected／disabled 分段描述，selected 压暗夹页和旧式外撇轮廓可验证 | pass |
| 文字安全区、裁切、拉伸、重复与接缝 | `320×156` Tab crop、`62/196/62px` 三段职责、runtime `6px/18px` 文字走廊与 shelf 低频中心均明确 | pass |
| 美术 DNA、具体反模式、Alpha／色键与最终自检 | 香草手绘、深胡桃／烟褐、左上暖光、非机械误差、现代规则牌反模式及纯绿最终检查完整 | pass |

- 去冗余结论：保留对象数、cell、旧式轮廓、状态语义、三段伸缩、纯绿色键和
  规整网页牌反模式的高风险重复；删除 V1 逐次过程、commit 和用户情绪描述，
  它们不进入执行正文。
- 原始授权正文 UTF-8 body 为 `11075` bytes，SHA-256：
  `14bce5c3f0b0d5ed931bc8bddcd68a5e50257c0e8f9e5a8455031b24e483392f`。授权必须指向该正文版本；
  输入绝对路径、固定 SHA 复核和输出保存指令继续放在独立 execution
  instruction，不改正文。
- attempt 1 首个失败门禁只涉及 source cell／隔离；当前完整、自包含
  `CHAT.TABS.DARK.V2.r1` 修复正文为 `13541` UTF-8 bytes，SHA-256
  `5ac686a1635dfdfa31bdce2e763d11008d7f90667ae76c9b3ca1f1ff7bfe95ed`。它只新增
  已授权紧邻 Image 5 的保留职责、五个 inner target containment box、原位置
  残影清理和空间修复自检，没有改变对象、状态、输入权威、Canvas、cell、
  runtime、综合色方向、Alpha、z-order 或动态内容排除。

### 完整生产正文 `CHAT.TABS.DARK.V2.r1`（冻结边界内完整修复正文；attempt 2）

```text
Edit Image 5 into one production-ready modular 2D hand-painted sprite sheet for the channel tabs of a World of Warcraft Vanilla-era battlefield chat journal. This is a bounded spatial repair of the immediately previous candidate, not a new visual direction. Preserve its accepted five-object art, material family, handmade silhouettes, state relationships, lighting, and wear; repair only object scale, placement, cell isolation, vacated green background, and any edge pixels required by that spatial correction. This is a component sheet, not a screenshot, not a complete chat window, and not a presentation board. The only five visible objects are exactly: one long shared tab shelf, then four isolated wordless leather index-tab states in this exact order: normal, hover, selected, disabled. Do not add a fifth tab, a duplicate shelf, a book frame, a message area, an input strip, an unread marker, a button, an icon, a label, a rune, a caption, or any other object.

The written art direction in this prompt is the highest authority. The first read must be a compact set of hand-cut leather channel indexes physically inserted into the upper page edge of a battered field journal from a 2004-era hand-painted fantasy MMORPG. They must feel made, repaired, and repeatedly handled inside Azeroth, not like modern dark UI tabs recolored brown. Use a flat orthographic front view, chunky low-resolution bitmap-minded painting, slightly coarse brush edges, controlled handmade error, clear material thickness, warm light from the upper left, low-saturation warm-brown contrast, and short contact shadows. The objects must remain readable when reduced to the real game sizes stated below.

Image 1 is the highest supplied visual reference for period identity, compact HUD weight, and the physical relationship between a Vanilla-era chat book and its channel indexes. Inherit its 2004-era hand-painted bitmap language, restrained footprint, thick readable silhouettes, warm directional light, and the sense that the tabs belong to an in-world field journal. Ignore every character, combat scene, unit frame, action bar, map, quest tracker, message, label, and unrelated UI object in Image 1. Do not reproduce its complete screenshot or bake any runtime content.

Image 2 is a lower-authority material-continuity reference for the currently accepted chat book. Inherit only its deep walnut worn leather, warm soot-brown paper, fibrous wear scale, subdued edge highlights, contact shadows, asymmetry, and upper-left light. Ignore its complete book silhouette, reading surface, binding, brass corner, page layout, alpha boundary, and canvas composition. Do not draw any part of the complete frame into this sheet, and do not treat Image 2 as higher visual authority than the written Vanilla-era baseline or Image 1.

Image 3 is a lower-authority structural reference for the old tab language specifically requested by the user. Inherit only these physical and silhouette traits: compact slightly skewed trapezoidal leather index markers; mildly uneven hand-cut crowns; lower corners that kick outward instead of forming a clean rectangle; sparse imperfect stitching; a selected leather marker that lifts inside the same canvas and exposes a small page layer at its base; and a shared page-and-leather shelf sitting behind all tabs. Explicitly ignore Image 3's pale selected-page slab, bright golden continuous page edge, old light palette, over-bright seams, and any exact old pixel. Do not copy, crop, trace, or reconstruct Image 3 pixel-for-pixel.

Image 4 is a technical scaffold only. It is authoritative for the 1536 x 1024 canvas, the five declared cells, their order, approximate occupancy, and pure-green separation. Its gray values, polygon edges, symmetry, lighting, and surface are not art references and must not appear in the final art. Keep every object completely inside its own cell, but replace the crude polygons with coherent hand-painted physical objects. Image 4 is not a pixel-perfect hard mask: preserve the cell contract and inner margins, not its exact polygon boundary.

Image 5 is the immediately previous output and the sole edit target. Preserve its correct visible art: the one dark layered shelf; the four coherent deep-walnut hand-cut leather tabs; their mildly uneven crowns, kicked lower corners, sparse repair stitching, short warm upper-left response, selected smoked under-page tongue, disabled recession, and non-modern material rendering. Do not redesign, restyle, simplify, sharpen, add ornament, change state semantics, or turn the tabs back into regular rectangles. Treat each of the five isolated objects as its own rigid painted sprite: uniformly scale it down as needed and translate it into its declared inner target, retaining its proportions and complete silhouette. Remove every old object, shadow, fringe, or thread pixel from its former position and replace all vacated pixels with the same flat green background. Do not crop the Image 5 objects at cell edges and do not keep a ghost, duplicate, or residual shadow outside the repaired objects.

Use this material hierarchy. The tabs are primarily deep walnut worn leather near #28180E, with warmer handled planes around #442A19, structural dark-brown seams near #24170F, and restrained soot-dark recesses. The shelf combines a dark leather binding below with thin smoked warm-brown page layers above. The selected under-page tongue may use a subdued smoked ochre-brown around #674923, never pale cream, bright parchment, or gold. Stitching is aged thread or leather cord, not a continuous metal border. Oxidized brass around #80602D may appear only as a tiny repair accent and must occupy less than five percent of any tab. Highlights are short, matte, broken, and warm; no glossy gold, white rim light, neon, or full-length bright line.

The shared shelf is one thin horizontal physical support behind the four tabs. It must read as an uneven dark stack of compressed page edges resting on a worn leather binding, with two or three low-contrast deckled layers, shallow contact shadow, and at most a small asymmetric stitch repair at each fixed end. It must not become a straight gold separator, a framed status bar, a row of four slots, a metal rail, or a second panel. Keep the long center low-frequency and horizontally stretchable: no unique knot, tear, rivet, seam endpoint, repeating dash pattern, or bright feature in the stretch center. Any distinctive repair belongs only near the fixed ends. The top edge may undulate softly, but it must remain thin and quiet at 16 runtime pixels.

The four tab states are members of one handmade leather-index family. Their common underlying object is a compact skewed trapezoid with a softly uneven crown, clipped hand-cut shoulders, outward-kicked lower corners, a broad calm leather center, and a shallow attachment edge that visibly meets the shelf. Do not fill the rectangular source cell with a rectangular plaque. Do not use ruler-straight parallel top and bottom edges, mirrored bevels, perfectly matching end caps, a complete inset rectangular frame, evenly spaced machine stitches, repeated corner ornaments, or identical cloned wear. Controlled asymmetry must feel functional: vary stitch spacing, crown waviness, and one small repair from side to side while keeping all states recognizably the same physical tab family and preserving their common canvas, left and right limits, text center, and bottom baseline.

Normal is recessed, dark, matte, and visually pressed into the shelf. It retains the full readable silhouette but has the lowest active contrast. Hover keeps the same geometry and material; add only one short candle-warm response along part of the upper or shoulder edge plus a slightly clearer contact plane. Do not light the complete perimeter. Selected remains a leather tab, not a parchment card or brass nameplate. Lift the leather body visually by about four to six runtime pixels inside the unchanged canvas, deepen the contact shadow where it crosses the shelf, and expose only a narrow two-to-three-runtime-pixel smoked page tongue at the base. That page tongue must be dark ochre-brown, irregular, compressed, and subordinate to the leather; it must never become the large pale paper slab seen in Image 3. Disabled keeps the common silhouette but is darker, lower-contrast, slightly desaturated, and still physically legible; do not erase it into a flat black rectangle.

Live channel names are drawn later by the game. Keep every tab wordless and symbol-free. At final runtime each tab is 92 x 30 UI pixels, with a centered text region 18 pixels high and at least 6 pixels of horizontal safety on both sides. In each 320 x 156 source crop, keep the broad center quiet and low-frequency. Confine knots, crossed repairs, high-contrast stitches, sharp tears, rivets, and distinctive wear to the fixed end zones. Approximately the first 62 source pixels and last 62 source pixels are fixed end-cap territory; the middle approximately 196 source pixels must survive horizontal extension without duplicated details, visible seams, or a stretched ornament. Material texture may continue through the middle only as subtle non-directional low-frequency leather grain.

Use this exact 1536 x 1024 sheet contract. The shelf cell is [64,96,1472,232]. The normal cell is [64,560,384,716]. The hover cell is [416,560,736,716]. The selected cell is [768,560,1088,716]. The disabled cell is [1120,560,1440,716]. The shelf crop is 1408 x 136 source pixels. Every tab crop is 320 x 156 source pixels. Keep every non-green object pixel inside its declared cell and leave at least 4 source pixels of perfectly pure green between the complete object and every cell edge; aim for 8 pixels or more. Do not let cast shadows, loose threads, highlights, antialiasing haze, or page fibers cross a cell boundary. Do not crop any kicked corner, stitch loop, selected page tongue, or shelf end.

For this repair, contain the complete visible bounding box of each object, including antialiasing, cast shadow, loose thread, page fiber, and highlight, inside these right-and-bottom-exclusive inner target limits: shelf [80,110,1457,217]; normal [76,570,373,703]; hover [428,569,725,703]; selected [780,566,1073,705]; disabled [1132,572,1429,705]. These target limits are containment rectangles, not shape masks: keep Image 5's irregular physical contours and transparent-looking green cutouts rather than filling the rectangles. No non-green pixel may exist outside the five declared cells. In particular, move the shelf upward so its leather binding and page stack both fit completely above y=217; move and uniformly reduce all four tabs so their bottom stitches, kicked corners, selected page tongue, and shadows finish above their target bottom limits. Keep the common tab center, left-right proportions, and bottom baseline compatible across states.

The exporter will scale each tab crop to a 248 x 120 logical atlas cell and render it at 92 x 30 UI pixels with fixed left and right three-slice caps. It will scale the shelf into a 1016 x 56 atlas strip and render it behind the tabs at frameWidth minus 60 by 16 UI pixels. Therefore all four states must share compatible external proportions, center alignment, and baseline; state switching must not appear to move the Button or its live text. The shelf must remain behind the tabs, and the selected tab must overlap it through contact and occlusion rather than through a glowing outline.

Paint the objects in a restrained Vanilla-era raster style. Preserve deliberate brush variation and material-specific wear, but avoid photographic antique rendering, high-frequency noise, modern product-rendering polish, vector-clean edges, smooth web gradients, glass, translucent acrylic, rounded pills, dark translucent cards, thin gold web borders, modern dashboard panels, precision industrial grids, Diablo III black spikes, skulls, demonic horns, giant crests, dragon heads, gems, glowing runes, and Elder Scrolls-like minimalist black overlays. In particular, reject the failed modern-tab anatomy: four equal rectangular leather plates with straight edges, complete inner frames, mirrored ends, and machine-perfect stitching.

Place the five complete objects on one perfectly flat, uniform chroma-key green background exactly #00FF00. The entire background outside the objects, including all cell gaps and canvas edges, must be the same exact #00FF00 with no gradient, checkerboard, texture, floor, vignette, ambient shadow, green haze, or presentation frame. Do not output fake transparency. Do not include captions, numbers, cell outlines, guides, or debug labels. Object edges may be naturally antialiased against the green for deterministic keying, but no visible green may contaminate the leather or page interiors.

Final self-check before returning the image: exactly five and only five isolated wordless objects; one shelf plus normal, hover, selected, disabled in the declared cells and order; every complete visible bounding box is inside its stated inner target limit with pure-green isolation and no old-position residue; all objects remain complete rather than clipped; tabs retain Image 5's irregular hand-cut leather-book-index art rather than becoming rectangular UI buttons; selected stays dark leather with only a narrow smoked page tongue; shelf has no continuous bright rail; text centers and three-slice middle zones remain quiet; no runtime text or unrelated UI is baked; canvas is exactly 1536 x 1024 on uniform #00FF00.
```

### V2 固定上传与生产授权边界

- 已授权的固定输入：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
  - Image 2：`assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png`，SHA
    `a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673`；
  - Image 3：`assets/source/chat/v3/ChatTabs_Master_v3.png`，SHA
    `8172d9d5145ac16ed23913fb7fbf75e626e0976d6bb33b27a555de4c55853023`；
  - Image 4：`generated/chat/core/CHAT.TABS.DARK.V2/production-scaffold/CHAT_TABS_DARK_V2_scaffold.png`，
    SHA `f02fba2d8bf4bc3a7b117d1245a794d4288c81c54c3f93e50290e5fefd9565a9`。
- 精确生产授权记录：
  - 授权人／日期：用户，`2026-08-04`；授权版本：`CHAT.TABS.DARK.V2`；授权
    正文 UTF-8 `11075` bytes，SHA-256
    `14bce5c3f0b0d5ed931bc8bddcd68a5e50257c0e8f9e5a8455031b24e483392f`；
  - 用户原文：`确认授权 CHAT.TABS.DARK.V2；允许每次上传固定 SHA 的 Image 1/2/3/4；允许同循环紧邻前次输出仅在冻结边界内作为 Image 5 edit 输入；最多 5 次实际 ImageGen 调用；流程错误不占额度。`
  - 本次授权只允许固定 `imagegen-0-143-0`／`@openai/codex@0.143.0`；attempt 1
    原样传输上述正文并只上传固定 Image 1–4。attempt 2–5 仅在冻结边界内、
    明确保留正确区域时，才可把同循环紧邻前次输出作为 Image 5 edit 输入。
  - 执行前复核：四张输入 SHA 与上表完全一致；macOS 使用
    `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`／Python `3.12.12`；
    当前实际生图 `0/5`，流程错误 `0`。
- 不可变修复边界：`CHAT.TABS`／`CHAT.TAB_SHELF`；五对象与顺序；上述四张
  输入及职责；`1536 × 1024` canvas、五 cell、纯绿色键；source crop、
  `92 × 30` Tab／`16px` shelf、三段式／文字安全区／z-order；旧式不规则
  皮签方向、深胡桃烟褐、压暗 selected 夹页、无连续亮金 shelf；动态内容排除。
- 允许自主修复：最多五次实际 ImageGen 中，可在完整自包含 `.rN` 正文里只
  修复第一个失败门禁的物件解剖、手工轮廓、材料连续性、四态辨识、cell 内
  缩放／隔离、纯绿色键或微观磨损；可在明确保留正确区域时使用同循环紧邻
  前次输出作为 Image 5 edit 输入，否则只用固定 Image 1–4 regenerate。
- 必须重新授权：新增／替换参考或上传图；使用更早／外部失败稿；改变对象数、
  状态、顺序、视觉方向、画布、cell、runtime 尺寸、层序、三段式、Alpha
  策略、provider 或允许烘焙内容。
- 预算：当前 `1/5` 次实际 ImageGen generation/edit，含首次；流程／传输／权限／
  上传／落盘错误若没有图片且没有 provider 生成证据则单列，不占额度。同一
  流程错误针对性修复一次后仍重复则暂停。任何候选完整内审通过立即停止；
  attempt 5 仍失败则 `candidate-rejected / repair-budget-exhausted`。
- 当前状态：`repair-prepared / attempt-02-ready / P3`。原授权正文与记录由
  commit `19706f9` 固定；attempt 1 已完整审查但未进入 source／runtime，addon
  未修改。
- 下一门禁：提交 attempt 1 失败记录与上述完整 `.r1`，再上传固定 Image 1–4
  和紧邻 attempt 1 raw Image 5 执行一次 bounded edit。只有新候选或 provider
  生成证据才递增为 `2/5`。

### V2 自主修复循环

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `CHAT.TABS.DARK.V2` / `19706f9`（执行 HEAD `a5196ae`） | generate；固定 Image 1／2／3／4 | session `019fcb68-8fee-79c0-b0d1-db978c62248d`／provider cache `ig_0d1defc3d27c45fd016a7183515d7081918e9c95bc850fe4bd.png` | raw `…attempt01_raw.png`／`3cd3a237569d92d995d604b53785fb2cff8f4a0303ad722d879874e2d7864ebe`；keyed `…attempt01_keyed.png`／`eb02fe7c1d25fc667c78827858cd938042bbc2f42952048291b8d6032e6b7ab4` | source cell／隔离：cell 外 `103677` 个可见像素；shelf 左／右／底触边，四 Tab 均触底且各有横向触边 | 保留五对象、旧式不规则皮签、材料、四态与真实排版；`.r1` 仅以紧邻 raw Image 5 做独立等比缩放／移位并清除原位残影 | 内部失败；计 `1/5` |
| 2/5 | `CHAT.TABS.DARK.V2.r1` / `327cbfb` | edit；固定 Image 1／2／3／4 + 紧邻 attempt 1 raw Image 5 |  |  |  |  | `ready` |
| 3/5 | `CHAT.TABS.DARK.V2.r2` /  | edit／generate |  |  |  |  |  |
| 4/5 | `CHAT.TABS.DARK.V2.r3` /  | edit／generate |  |  |  |  |  |
| 5/5 | `CHAT.TABS.DARK.V2.r4` /  | edit／generate |  |  |  |  |  |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|

- 循环终态：`active / 1/5 / repair-prepared`；任何候选全部门禁通过即停止并进入
  `candidate-reviewed / P3`，不自动创建 source 或修改 runtime。

### `CHAT.TABS.DARK.V2` attempt 1 执行与审查记录

- 日期：`2026-08-04`；固定执行器：`imagegen-0-143-0`／
  `@openai/codex@0.143.0`，model `gpt-5.5`，reasoning `medium`；session 与
  provider cache result 如上表。child 完整回显 `$imagegen`、原授权正文与
  Image 1／2／3／4 的绝对路径；未上传 Image 5，未报告 revised prompt，且
  provider 明确完成一次 generation。模型 cache 警告没有阻止 generation，
  不属于无候选流程错误。
- 输入复核：四张实际上传图的顺序、路径和 SHA 与授权完全一致；原始正文仍为
  `11075` bytes／`14bce5c3…e483392f`。实际 ImageGen 累计 `1/5`，流程错误 `0`。
- raw：`generated/chat/core/CHAT.TABS.DARK.V2/attempt-01/CHAT_TABS_DARK_V2_attempt01_raw.png`，
  `1536 × 1024 RGB`，SHA-256
  `3cd3a237569d92d995d604b53785fb2cff8f4a0303ad722d879874e2d7864ebe`。
  provider 生成偏亮渐变绿而非完全 `#00FF00`；raw 仅有 `2` 个 exact-green
  像素。
- candidate-self Alpha：`tools/key_chat_tabs_dark_candidate_v1.py` 只复用候选
  自身 `32px` border 与既定 soft matte／despill 规则；background score min
  `218`，transparent threshold `217`，opaque threshold `160`。keyed 为
  `1536 × 1024 RGBA`，SHA-256
  `eb02fe7c1d25fc667c78827858cd938042bbc2f42952048291b8d6032e6b7ab4`；透明
  `1268758`、半透明 `2594`、不透明 `301512`。透明 RGB 已清零；后处理没有
  使用 scaffold、模拟、旧 V3 或 Full V1 像素。
- 范围／身份：恰好一条 shelf 与 normal／hover／selected／disabled 四枚无字
  Tab；无完整书框、文字、图标、按钮、输入、未读或其他对象，`pass`。
- 语义／物理／图层：四枚均首先读作同一族手切旧皮革索引签；不齐 crown、
  外撇下角、端部手缝、selected 抬升与压暗夹页、shelf 页叠／皮革承托关系均
  成立，透视与左上暖光一致，`pass`。
- 美术一致性：深胡桃／烟褐、低饱和暖边、粗厚二维位图轮廓和非机械磨损与
  Full V1 连续；没有浅色 selected、完整规则内框、镜像端帽、网页玻璃牌、
  暗黑尖冠或烘焙动态内容。shelf 顶页边仍应在完整装配后关注是否过亮，但不是
  本次首个失败门禁。
- source cell／隔离：`fail`。keyed 全局可见 bbox 为
  `[38,197,1498,734]`，声明 cell 外可见像素 `103677`。shelf 在本 cell 内
  margin 为 left `0`／right `0`／bottom `0`；normal 为 left `0`／bottom `0`；
  hover 为 left `0`／right `0`／bottom `0`；selected 四边分别为
  `0/1/0/0`；disabled 为 right `0`／bottom `0`。按 cell 直接裁切会切断 shelf
  皮革 binding、Tab 底缝、外撇角、selected 夹页和阴影。V2 scaffold 不是
  hard mask，因此 strict-mask overflow 只作诊断，不是独立门禁。
- 真实排版：`tools/review_chat_tabs_dark_candidate_v1.py` 现支持明确传入 V2
  simulation、scaffold、display contract 与 component；它只按声明 cell 裁切
  keyed 候选并执行计划 atlas／三段式缩放，再叠加当前 tracked Full V1、Dark
  V1 输入与动态真实文字。`100%` 预演为
  `generated/chat/core/CHAT.TABS.DARK.V2/attempt-01/review/candidate-real-layout.png`，
  `1060 × 510 RGBA`，SHA-256
  `8e8fbf91dee9c13a8ba3dec0f6acf438c8c9ddbb6246109e473db16b14a205f3`；包含
  `440 × 320`／15 行四态与 `540 × 420`／22 行扩展。综合色、文字层序和真实
  尺度可读，但预演已裁掉越界像素，不能解除 source 失败。
- metrics：同目录 `candidate-review.metrics.json`，SHA-256
  `fed6d3105cfbedf6aafabaaba7377b652afccb16d6d7eb83f9caebdcc8f1b66e`；cell debug
  直观显示五个对象均越界。display-region report SHA-256
  `b93a9de4f4bb6d6d961916817c2b1650ca318c316a464409438df7cc30a24bcf`，
  三个真实 provider 场景 `pass`，violations `0`；该结论只证明 Frame、Tab
  visual／hit 与 shelf 区域公式，不替代 source isolation。
- 结论：`internal fail / repair`。第一失败门禁为 source cell／隔离；不进入
  用户复审、P4 source 或 runtime。正确视觉区域清晰可保留，因此按用户授权
  只把本轮紧邻 raw 作为 Image 5 edit；完整 `.r1` 的 SHA 如上，下一次执行前
  必须先提交本记录、两项确定性审查工具变更和 `.r1`。
