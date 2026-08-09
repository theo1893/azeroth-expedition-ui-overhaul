# AB.FIELDKIT.V1

## 元数据

- 批次：`AB.FIELDKIT.V1`
- 覆盖逻辑组件：`AB.TRINKET.DOCK`、`AB.TRINKET.SLOT13／14`、
  `AB.TRINKET.MENU`、`AB.CONSUMABLE.RACK`、`AB.CONSUMABLE.POCKET`、
  `AB.CONSUMABLE.POPUP`、`AB.CONSUMABLE.GROUP`
- 模拟版本：`AB-FIELDKIT-SIM-V2`
- 当前操作：`accept`
- 子状态：`dual-source-accepted`
- 项目阶段：`P4`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 当前状态：`dual-source-accepted / P4`；用户于 `2026-08-09` 明确回复
  “接受 AB.TRINKET.KIT.V1 第4稿与 AB.CONSUMABLE.KIT.V1 第1稿”。两个通过全部
  内部门禁的 exact canonical 已逐字节复制进各自 tracked source，并由独立
  manifest 固定 SHA、Alpha、四格映射、执行器／会话 provenance、用户验收边界与
  禁止 runtime 用法。本次接受没有调用 ImageGen、没有切片或接入 runtime
- 模拟用户结论：`AB-FIELDKIT-SIM-V1 consumable direction revision-requested
  2026-08-08`；用户原文：“消耗品5*2不够用. 并且能否按照类型进行分组?”；
  `AB-FIELDKIT-SIM-V2 confirmed 2026-08-09`；用户原文：“接受
  AB-FIELDKIT-SIM-V2”
- 已接受 source：Trinket
  [ActionTrinketKit_Master_v1.png](../../../../assets/source/actionbars/ab-trinket-kit/ActionTrinketKit_Master_v1.png)
  SHA `82dd2260…c012` 与 Consumable
  [ActionConsumableKit_Master_v1.png](../../../../assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png)
  SHA `623f29c5…a2419`；两者分别与 attempt 4／attempt 1 canonical 字节完全一致。
  Trinket attempts 1–3 仍只作为失败 provenance
- 模拟 ImageGen：`0/0`
- 生产执行体：`AB.TRINKET.KIT.V1` 为
  `repair-r3 / transport-amended / source-accepted / stopped-at-4/5`；
  `AB.CONSUMABLE.KIT.V1` 为
  `transport-amended / source-accepted / stopped-at-1/5`
- 生产预算终态：Trinket `4/5`、Consumable `1/5`；原循环在首个通过候选处停止。
  未用的 `1` 次与 `4` 次不会因接受而消耗、重置或带入 P4→P5；若未来改变已接受
  source，必须另立新版本并重新授权
- 外部上传：用户已分别授权把 Character V3 锁定图作为两个执行体各自唯一的
  Image 1 上传；Trinket attempts 1–4 已上传 `4` 次，Consumable attempt 1 已上传
  `1` 次；授权范围
  不含新增输入图，也不复用既有组件授权
- 跨设备 handoff：无；两个 exact accepted bytes 已进入 tracked `assets/source/`，
  P4→P5 不再依赖 ignored candidate／simulation 像素，也没有可消费的旧检查点
- source manifest：
  [Trinket](../../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_SourceManifest_v1.json)／
  [Consumable](../../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_SourceManifest_v1.json)
- 目标：Turtle WoW `1.18.1`，Interface `11200`，`1920×1080`，
  UI Scale `0.81269841269841`

## 当前设备事实与 provider 审计

### 启用状态

- 当前角色的 `AddOns.txt`：TrinketMenu `enabled`，AutoBar `disabled`。
- 两个插件均已安装；本批次不得替用户启用 AutoBar，也不得把其保存配置当成
  当前可见 runtime。
- 当前 AutoBar `_SHARED1` 保存为 `1×24`、`36×36 UI`、gap `3 UI`、
  `alignButtons=5`、popup 向上、锁定；这只用于容量与兼容审计。
- 当前 TrinketMenu 保存为主栏水平、主栏 scale
  `0.9043710231781006`、菜单垂直、菜单 scale `1`、固定 `4` 列、菜单停靠主栏
  右侧且底部对齐、`KeepDocked=ON`、`KeepOpen=OFF`、`MenuOnShift=OFF`、
  `Locked=OFF`、大号冷却数字开启、快捷键文字关闭。
- SavedVariables 不能提供当前背包内的真实候选饰品数量；模拟中的 `1／8／30`
  都是精确合法的 provider 实例，不声称当前角色正好拥有该数量。

### TrinketMenu 真实对象与行为

- 来源：目标设备 `Interface/AddOns/TrinketMenu/TrinketMenu.lua`、
  `TrinketMenu.xml`、`TrinketMenuOpt.xml` 与 Queue 扩展。
- `TrinketMenu_MainFrame`：水平严格 `92×52 UI`，垂直严格 `52×92 UI`。
- `TrinketMenu_Trinket0／1`：两个真实 `36×36 UI ActionButtonTemplate`，绑定
  装备槽 `13／14`；水平时位于 `[8,8,44,44]` 与 `[48,8,84,44]`，垂直时
  位于 `[8,8,44,44]` 与 `[8,48,44,84]`。
- 两槽各有 `18×18 UI` 战斗排队 inset，左上相对 Button 外扩 `2 UI`；排队
  图标、自动排队齿轮、冷却遮罩和冷却文字均为 provider 动态层。
- `TrinketMenu_MenuFrame` 包含 `TrinketMenu_Menu1..30`，候选只来自背包内
  `INVTYPE_TRINKET`，零候选时完全隐藏。
- 菜单 Button 为 `36×36 UI`，步距 `40 UI`。当前 `4` 列、垂直菜单的 Frame
  为 `172 × (12 + ceil(count/4)×40) UI`；`1／8／30` 候选分别是
  `172×52`、`172×92`、`172×332 UI`。
- 自动列数为：`1–4→1`、`5–12→2`、`13–18→3`、`19–24→4`、
  `25–30→5`；手动列数合法范围为 `1–30`。菜单切换 HORIZONTAL 后宽高公式
  互换。
- 当前 `BOTTOMRIGHT→BOTTOMLEFT` 停靠使菜单位于主栏右侧、底部对齐，解锁时
  `xoff=-4 UI`；当前 VERTICAL 菜单先横向填满四列，再向上增加下一行。
- 悬停已装备槽构建菜单；候选左键换入槽 `13`，右键换入槽 `14`。战斗中只
  排队，离开战斗后由插件执行；AEUI 不复制装备扫描、冷却、Queue 或全局 hook。
- 主栏和菜单分别可拖动、缩放；各自右键空白处切换方向。V1 换肤不得吞掉
  这些鼠标语义、resize Button 或 Tooltip。

### AutoBar 真实对象、类别与行为

- 来源：目标设备 `Interface/AddOns/AutoBar/AutoBar.xml`、`Core.lua`、
  `AutoBarProfile.lua` 与 `AutoBarItemList.lua`，版本 `1.31`。
- `AutoBarFrameButton1..24`：最多 `24` 个真实主 Button；默认模板
  `36×36 UI`，当前保存 gap `3 UI`。
- `AutoBarPopupFrame_Button1..12`：最多 `12` 个真实候选 Button；弹出时从
  被悬停主 Button 以相同步距向上、下、左或右形成单列。基准物品通常隐藏其中
  一格，因此常见可见候选少于 `12`，但视觉合同保留全部 `12` 个对象。
- provider 报告的 Frame 公式是
  `displayedColumns×(buttonWidth+gapping)+1` 与
  `displayedRows×(buttonHeight+gapping)+1`；但 `alignButtons=5` 会把子 Button
  相对独立拖动把手居中，Button 可位于 `AutoBarFrame` 自身边界外。
- 因此 runtime 外壳必须在配置变化时读取真实可见 Button 边界，更新一个只读
  decorative Frame；不得假设 `AutoBarFrame:GetRect()` 就是全部内容，也不得
  在维护循环持续改 Parent、Point、Width 或 Height。
- V1 的 `5×2` 可见按钮簇为 `192×75 UI`，加入四周 `6 UI` 装饰余量后为
  `204×87 UI`；用户已明确认为容量不足。V2 使用完整 `4×6`：按钮簇
  `153×231 UI`、卷袋主体 `165×243 UI`；左侧 `40 UI` 标题皮签与 `2 UI`
  间隙使完整视觉边界为 `207×243 UI`。`24×1` 与 `1×24` 外壳仍均为
  `945×48 UI`，不因推荐方向改变而失效。
- `AutoBarPopupFrame` XML 初始 `72×72 UI` 不是弹出链边界。V1 不生成固定整张
  popup 背景；每个真实 popup Button 复用独立薄口袋，并在 `3 UI` 间隙使用
  可旋转短皮带连接。
- 类别、物品选择、背包槽、数量、冷却、可用性、Shift popup、拖动、锁定、
  docking 与 SavedVariables 全归 AutoBar。当前插件禁用时 V1 不创建替代栏。
- `AutoBarProfile.basic` 与职业 profile 已证明一个主 Button 可以持有一个或
  多个真实类别 ID，适合让主槽表达“类别”、popup 表达该类别内实际物品。
  V2 只使用 provider 已有类别 ID，并把槽 `1–8／9–16／17–24` 分为应急／增益／
  工具；职业资源与职业用品按当前职业选取，不写入无关职业类别。
- `AUTOBAR_MAXSLOTCATEGORIES=16`；每个主 Button 的条目可以是类别字符串，也
  可以是 `AutoBarConfigSlot.ButtonOnReceiveDrag` 从背包物品写入的数字 item ID。
  已审计的 `AutoBarItemList.lua` 没有独立 `FLASK` 类别，因此 V2 的“合剂手动”
  只接受用户通过 provider 配置拖入的真实 item ID。视觉层不得按本地化名称、
  图标或物品说明自动猜测合剂。

## 组件合同

### 共同布局

- 默认行为：尊重两插件现有位置、scale、方向、显隐和 SavedVariables。
- 可选一次性“战斗甲板”preset：满容量消费品外壳以 `4×6` 竖向位于主动作栏
  左侧、聊天框与玩家框之间，饰品双槽位于主栏右侧。消费品主体物理
  `[531,673,665,870]`，距聊天框右缘 `5 px`、距玩家框左缘 `16 px`、距主栏
  `48 px`；饰品距主栏 `16 px`，三者底边同为 `y=870 px`。
- preset 只在用户明确应用时写一次位置／行列，不建立维护循环；之后继续由
  原 provider 独立拖动和缩放。
- 主动作栏 `[713,827,1207,870]` 的技能冷却视线不被覆盖；两套菜单均向上／
  向外展开，不压在主技能格上。
- 战斗常驻：两枚已装备饰品；若用户启用 AutoBar，则用户标记的核心消耗品
  保持可见。候选菜单只按 provider 原触发出现。

### `AB.TRINKET.KIT.V1`

- 生产 atlas 含四个独立 normal 层：已装备护套、候选插页、可九宫格伸缩的
  菜单外沿、双护套之间的短连接扣。
- 已装备槽比消耗品口袋略厚：深胡桃旧皮凹面、克制的断续氧化黄铜窄边，顶部
  小扣表示护套而非宝石底座。
- 候选插页更薄、更轻；provider 当前选中／按下状态只用前移、短暖边与既有
  Checked／Highlight 动态层，生产基底不烘焙状态。
- 菜单外沿适配 `52×52` 以上的合法 Frame，包括当前 `172×52～172×332`、
  自动 `212×252`、极端 `1212×52 UI`；中心必须安静可伸缩，不能画固定格线。
- 两个主 Button 和最多三十个候选 Button 的真实图标、冷却、文字、Tooltip、
  排队、选中和命中区均位于资产之上。
- `Locked=OFF` 的 resize／移动反馈本轮保留 provider fallback；不提前生产
  `AB.MOVER／CONFIG`。
- TrinketMenu 缺失时只允许局部 fallback 到真实装备槽 `13／14` 的使用；不
  仿造三十项菜单、Queue 或战斗换装。

### `AB.CONSUMABLE.KIT.V1`

- 生产 atlas 含四个独立 normal 层：主口袋、popup 薄口袋、自适应卷袋外沿、
  可旋转的 `3 UI` 短连接带。
- 外壳是炼金师随身皮革卷袋：暖褐旧皮、可见折边、不完全均匀的短缝线和少量
  暗黄铜扣；综合色重低于主动作栏，不出现十瓶静态药水。
- 每个口袋保持正方形命中几何，中央完整留给真实图标；数量、冷却、缺货、
  family、Tooltip 和按下反馈全部动态。
- 外沿按真实可见 Button 簇重算，支持 `1–24` 个 Button、合法行列、非正方形
  Button 尺寸及 provider scale；推荐实例改为完整
  `4×6 / 24 Button / 36 UI / gap 3 UI`，卷袋主体 `165×243 UI`。
- 推荐 profile 的 `1–8／9–16／17–24` 依次标记为“应急／增益／工具”。三枚
  `40×20 UI` 标题皮签位于主体左侧 `2 UI` 外，底层分隔带只占两组之间的
  `3 UI` gap；全部 `EnableMouse(false)`，不改变任一 AutoBar Button 命中盒。
- 分组装饰必须验证 Button 数 `24`、行列 `4×6` 和 profile 签名；任一条件不
  匹配即全部隐藏，仅保留单一自适应卷袋外壳。不得给用户的 `5×2`、`24×1`、
  `1×24` 或自定义行列贴上错误类别标题。
- 三组每格仍是 AutoBar 的类别 Button：应急覆盖生命／职业资源／双恢复／
  绷带／解毒／行动／机动；增益覆盖战斗药剂／守护药剂／元素防护／卷轴／
  食物／饮料／增益食物／手动合剂 item ID；工具覆盖武器强化／职业用品／炉石／
  坐骑／工程／钓鱼／战场事件／任务物品。精确类别 ID 见 V2 specification；
  不复制数据库、不按名称猜测。
- popup 复用薄口袋与短连接带，不使用固定大面板；支持上下左右和 `1–12` 个
  provider Button。
- 当前 AutoBar 为 disabled，因此 runtime adapter 即使以后存在，也只能在
  `AutoBarFrame` 已存在且插件已自行加载／显示时换肤；不得自动启用。
- AutoBar 缺失／禁用时 V1 显示为空。AEUI 钉选物品 fallback 属于以后独立的
  功能合同，不在本批次凭物品名称猜测分类。

### 动态与禁止烘焙

- 禁止烘焙：物品／饰品图标、名字、具体类别文字、快捷键、数量、冷却数字、
  扇形冷却、排队图标、齿轮、装备品质色、Tooltip、L／R 标签和真实 Button
  状态。“应急／增益／工具”仅由 adapter 在 profile 签名匹配时创建 runtime
  FontString，不进入位图。
- 禁止：珠宝柜、发光宝石底座、固定饰品、固定药瓶、现代玻璃卡片、霓虹外发光、
  宽品质框、厚石台、固定十格或十二格背景。
- z-order：自适应外沿／连接带在底；独立口袋／护套在其上；provider 图标与
  文字再上；Cooldown／Checked／Highlight／Queue／Tooltip 最高。
- Alpha／传输：外部服务只负责纯 `#00FF00` RGB raw；该 raw 不是候选。最终
  审查对象必须由已授权本地确定性流程形成 exact `1024² RGBA`，每个 atlas
  cell 外 Alpha 为零、全透明 RGB 为零、无可见绿色残留。色键只移除从各 cell
  边缘连通的绿色场，不得跨 cell 连通、重绘或让装饰进入 Button hit-safe 区。

## 美术基准继承

### 权威顺序

1. [Character V3 锁定图](../../../../assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png)，
   SHA-256 `b5c36448…c2ba`，及
   [Character 主 Prompt](../../character/ART_BASELINE.md)／
   [Character 子模块 Prompt](../../character/SUBMODULE_ART_BASELINES.md)。
2. [Action Bars 主 Prompt](../ART_BASELINE.md) 与
   [子模块 Prompt](../SUBMODULE_ART_BASELINES.md)。
3. 本文件的真实 provider 几何、对象、状态、safe area 与 fallback 合同。
4. accepted `AB.SLOT.BASE.V1` 仅作相邻 runtime 身份；不得成为两个生产执行体
   的 ImageGen 输入或更高视觉权威。

### 必须继承的视觉 DNA

- 香草二维手绘低分辨率语言、粗厚略不规则轮廓、明确而克制的明暗切面。
- 深胡桃／烟褐旧皮为主体；消耗品比饰品略暖，饰品比消耗品略厚重。
- 暗哑氧化黄铜只作短窄包边、扣件和连接点；不形成连续亮金框。
- 左上短暖光、右下暗压、低饱和、低频磨损；缩到约 `29–36` 物理像素时仍
  退居真实图标之后。

### 明确不继承

- 不继承角色面板的完整窗口轮廓、羊皮属性区、模型背景、装备部位压印、Tabs、
  名牌、关闭扣或布局比例。
- 不继承 `AB.SLOT` 的技能槽身份、现有像素或正方形包边细节；只与其综合色温
  相邻协调。
- `AB-FIELDKIT-SIM-V1／V2` 的所有像素、图标、折线、缝线、标签和颜色块均非
  生产输入。

### 冲突结论

- Character V3 的“经典装备槽”身份与本批次真实插件几何冲突时，以 provider
  的 `36×36` Button、`92×52／52×92` Frame 和菜单公式为物理权威，只继承
  材料 DNA。
- AutoBar `AutoBarFrame` 边界与真实 Button 边界不一致时，以 Button 的真实
  可见／命中边界为外壳计算依据。
- V1 的固定十类／`5×2` 推荐与用户明确容量要求冲突，V2 退回 prompt-draft 后
  改为完整二十四类／`4×6`；`5×2` 只保留兼容模式，不再是推荐默认。
- 分组标题与用户自定义 AutoBar profile 可能冲突：只有精确 profile 签名匹配
  才显示三组 runtime 标题，否则隐藏分组装饰并服从 provider 当前配置。
- “合剂”需求与 AutoBar `1.31` 缺少内建 `FLASK` 类别冲突：以真实 provider
  数据为准，使用其原生的背包物品拖入／数字 item ID 能力，不虚构自动分类。

## 生成前本地模拟

### 文件与命令

- renderer：`tools/render_action_fieldkit_simulation.py`，SHA-256
  `88609c63…35b3`
- 当前 specification：`tools/specs/action_fieldkit_v2_simulation.json`，SHA-256
  `4089ff19…7378`
- 当前 display contract：`tools/specs/action_fieldkit_v2_sim_display_region.json`，
  SHA-256 `5d06d87b…dd69`
- V1 specification／display contract 保留为被修订方向的可复现文字规格；V1
  两张模拟图回归重渲染 SHA 仍精确为 `91a596b9…adce` 与
  `64a39772…5927`。
- Python：`D:\Softwares\miniconda3\python.exe`，`3.13.5`；Pillow `11.3.0`。
- render：
  `python tools/render_action_fieldkit_simulation.py tools/specs/action_fieldkit_v2_simulation.json --repo-root .`
- display：
  `python .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py tools/specs/action_fieldkit_v2_sim_display_region.json --report generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/simulation/AB-FIELDKIT-SIM-V2/display-region-report.json`
- test：`python tests/action_fieldkit_simulation_test.py`

### 输出与检查

- 战斗场景：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/simulation/AB-FIELDKIT-SIM-V2/AB.FIELDKIT.V1.sim-v2.scene.png`，
  `1920×1080 RGB`，SHA-256 `9fe4d159…164d`
- provider 状态板：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/simulation/AB-FIELDKIT-SIM-V2/AB.FIELDKIT.V1.sim-v2.provider-states.png`，
  `1920×1200 RGB`，SHA-256 `16a90762…f467`
- 布局报告：`layout-report.json`，SHA-256 `a06bde15…779f`；
  `72/72 pass`、violations `0`。
- display 报告：`display-region-report.json`，SHA-256 `3ada8c3f…2f89`；
  `16/16 pass`、violations `0`。
- 覆盖：饰品主栏水平／垂直、Queue safe area、候选 `0／1／8／30`、当前
  四列、自动五列、水平菜单、合法三十列；消费品 `1×1／5×2／4×6 分组／
  24×1／1×24`、popup `6／12` 与横／纵增长。
- 场景精确位置：分组卷袋完整视觉 `[497,673,665,870]`，主体
  `[531,673,665,870]`，三枚标签分别为 `[497,676,530,693]`、
  `[497,740,530,756]`、`[497,803,530,819]`；主动作栏
  `[713,827,1207,870]`，饰品 `[1223,832,1291,870]`。聊天框从 `y=824`
  开始，因此最下标签仍提前 `5 px` 结束；主体距聊天框右缘 `5 px`、距玩家框
  `16 px`。
- ImageGen：`0/0`；外部上传：`0`；V2 本地渲染错误 `0`。V1 首次 display contract
  因误用专用于 Quest provider 的 `provider_layout` 键返回 schema error，未
  产生任何外部调用；删除该无关键后同版本通过。

### 内部复核

- 语义：pass。饰品明确是现用 TrinketMenu 的双槽＋候选＋Queue，不是假动作格；
  AutoBar 明确标注为当前禁用的可选 provider。
- 几何：pass。主栏、菜单公式、最大对象数、Popup 上限、三段各八槽、label
  safe area 与极端方向均为真实 provider 几何或明确的非交互装饰边界。
- 布局：pass。`4×6` 在左侧竖向空隙内，不覆盖聊天、玩家框、施法条或主动作栏，
  且仍保持 provider 根 Frame 独立移动／缩放。
- 美术方向：pass for user review。深皮护套、暖褐卷袋、薄候选插页、短连接扣
  与克制黄铜的层级清楚；三枚同材质皮签只提供分组节奏，不形成现代彩色
  Dashboard。模拟不证明最终笔触、Alpha、接缝或九宫格质量。
- 非权威：所有模拟像素不得裁切、切片、晋级、导出、上传或作为 production
  edit／ImageGen reference。

### 用户已确认的可见方向

1. 消耗品改为左侧完整 `4×6 / 24 类`，与饰品双槽共同底边的整体平衡。
2. 每两行八格依次为应急／增益／工具；主槽是类别，悬停 popup 才是该类真实
   物品，避免把二十四格继续当作二十四个固定物品。
3. 三枚 runtime 标题皮签位于命中盒外；配置不匹配时隐藏，不误标用户自定义栏。
4. 合剂槽只接受用户在 AutoBar 配置中显式拖入的真实 item ID，不伪造不存在的
   `FLASK` 类别。
5. 饰品保持当前插件的水平双槽比例，菜单从右侧贴出并按当前四列向上增长。
6. 已装备护套较厚、候选插页较薄；Queue 保持明显但不盖住主图标。
7. 消耗品使用暖褐炼金卷袋，popup 由独立薄口袋形成，不使用固定大面板。
8. AutoBar 当前不启用；未来只有用户主动应用时才写入 `4×6` 分组 profile。

用户方向结论：V1 消耗品方向于 `2026-08-08` 被要求修订；用户于
`2026-08-09` 明确回复“接受 AB-FIELDKIT-SIM-V2”，确认上述八项文字化方向。
该结论不接受任何模拟像素；模拟图仍不得裁切、切片、晋级、导出、上传或作为
production edit／ImageGen reference。若布局、物件隐喻、材质层级、配色、
综合色重、整合关系或交互状态观感发生实质变化，本确认失效并返回新模拟版本。

## 生产正文完整性预检

| 项目 | 结论 | 状态 |
|---|---|---|
| 真实对象、数量、状态、几何和上限 | 两个 provider 均已完整审计 | pass |
| 锁定图与 Prompt provenance | Character V3 图＋主／子 Prompt 完整 | pass |
| 输入图职责 | 每个执行体只有 Character V3 作为拟议 Image 1；只继承材料 DNA | pass |
| raw／canonical canvas、cell 与 Alpha | 两个执行体均使用纯 `#00FF00` RGB raw；本地只做获授权的整图归一、逐 cell 完整 bbox 等比 fit／居中、边缘连通色键转 straight Alpha 与透明 RGB 清零；最终均为 `1024² RGBA` 四格 atlas，cell 与安全区固定 | pass |
| 动态内容与 z-order | 图标、具体类别、冷却、Queue、Tooltip 全排除并归 provider；三组标题为 adapter runtime FontString | pass |
| 最小／典型／最大真实排版 | V2 本地模拟布局 `72/72`、display `16/16 pass` | pass |
| 独立执行预算 | `5 + 5`，最坏 `10` 次；用户于 `2026-08-09` 分别明确授权 | pass |
| 外部上传 | Character V3 已分别获准作为两个执行体各自唯一的 Image 1；不复用旧授权 | pass |
| 用户模拟确认 | `AB-FIELDKIT-SIM-V2` 于 `2026-08-09` 明确确认；只接受八项文字化方向 | pass |

## 最终执行正文 A（`AB.TRINKET.KIT.V1`）

状态：`production-final / executed-attempt-01 / failed / superseded-by-r1`。

```text
Create one production-ready transparent RGBA UI asset atlas for Turtle WoW 1.18.1, component AB.TRINKET.KIT.V1. The output canvas must be exactly 1024 by 1024 pixels and divided into four non-overlapping 512 by 512 cells: A [0,0,512,512] equipped-trinket sheath base; B [512,0,1024,512] candidate-trinket insert base; C [0,512,512,1024] adaptive menu-frame nine-slice master; D [512,512,1024,1024] short joiner clasp used between the paired equipped sheaths. Keep every cell independent, centered, fully visible, and surrounded by at least 80 transparent pixels. No visible pixel may cross a cell boundary. Background outside each object must be true alpha zero; do not use a green key background.

This output is an asset atlas, not an assembled action-bar scene. Do not paint a game screenshot, screen background, action bar, consumable rack, item grid, labels, or multiple repeated runtime instances into any cell.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted bitmap language, deep walnut and smoke-brown aged leather, muted oxidized brass, slightly irregular thick silhouettes, restrained wear, short warm upper-left light, darker lower-right pressure, low saturation, low-frequency value grouping, and believable material thickness. Ignore its character-window outline, parchment attribute panel, model area, equipment layout, tabs, text, icons and all large composition. Runtime geometry below overrides Image 1 whenever they conflict. Render every object in a straight-on orthographic 2D UI view with the same upper-left light and no three-quarter scene perspective.

Cell A is one square leather sheath behind a live 36 by 36 UI trinket ActionButton. It must read as a compact functional sheath, not a generic spell slot: a slightly thicker deep-leather rim, a quiet recessed center completely covered by the live icon, one small muted-brass keeper near the upper edge, and no jewel, socket, gem glow or fixed trinket. It will display at roughly 40 to 44 UI units behind each of the two equipped buttons. Cell B is a visibly lighter and thinner square leather insert for each live 36 by 36 candidate button, with less brass and less depth than Cell A. Cell C is a square, quiet, non-directional nine-slice frame master with narrow broken brass edge segments and a matte stretchable center; it must remain valid around live menu frames from 52 by 52 UI through 172 by 332 UI, 212 by 252 UI and 1212 by 52 UI without creating fixed grid lines, fake pockets or a focal ornament in the center. Cell D is a very short leather-and-brass joiner that can sit in the 4 UI gap between two equipped sheaths in horizontal or vertical orientation; it must rotate cleanly and never enter either 36 by 36 hit area.

The confirmed runtime composition instantiates two Cell A sheaths as a horizontal paired dock on the right of the main action bar, with the pair bottom-aligned to the main bar and to the consumable roll on the opposite side. Cell D joins only the 4 UI gap between the two sheaths. The current typical candidate menu docks to the pair's right side, uses four columns and grows upward; Cell C must also remain valid for the provider's vertical or horizontal menu direction, automatic one-to-five columns, manual one-to-thirty columns, zero-candidate hidden state and up to thirty live candidates. Candidate content expands outward and upward rather than over the main skill icons. These are runtime assembly constraints only; do not render the assembled dock or menu into the atlas.

All four cells contain only the normal static base layer. Do not bake hover, pressed, selected, checked, cooldown, disabled, range, queue, autoqueue, keybinding, text, count, tooltip, equipment quality, item icon, inventory-slot number, left-click or right-click labels. Those are live provider layers. Avoid continuous bright gold bezels, wide quality colors, glossy PBR gradients, fine photographic grain, micro-scratches, dense stitching, perfect machined symmetry, modern glass cards, neon glows, jewel cabinets, altars, stone plinths and decorative elements that would become noise at approximately 29 to 36 physical pixels. Preserve clear alpha separation, calm icon-safe centers, and a visual weight slightly heavier than the consumable pockets but lower than the main action bar. Before finalizing, verify that the canvas contains exactly four isolated front-facing objects in their assigned cells, every object has at least 80 transparent pixels around it, Cell C has a quiet stretchable center, Cell D rotates cleanly, and no dynamic provider content or assembled UI has been painted.
```

### A 的修复边界与预算

- 不可变：四个 cell 身份／数量、最终 canonical `1024² RGBA` canvas、cell 坐标、
  straight Alpha、已授权纯绿 raw 传输、Image 1
  职责、provider 动态排除、饰品护套比消费品略重、全部真实几何。
- 可修复：皮革／黄铜比例、局部轮廓、磨损密度、透明边缘、cell 内位置、九宫格
  中心安静度和连接扣可读性。
- 需要重新授权：新增／替换输入图、上传新图、改变 cell 身份／数量、把模拟或
  AB.SLOT 当输入、改变 canvas／Alpha／动态内容所有权。
- 预算：`4/5`；attempts 1–4 均已返回 countable provider output；attempt 4 已内部
  全门禁通过并按 pass 即停，剩余一次不再使用；用户已接受并晋级 P4 source，
  runtime 仍须独立 P4→P5 操作。

## 修复执行正文 A.r1（`AB.TRINKET.KIT.V1.r1`）

状态：`repair-final / executed-attempt-02 / failed`。

```text
Create one production-ready transparent RGBA UI asset atlas for Turtle WoW 1.18.1, component AB.TRINKET.KIT.V1 repair r1. This is a fresh regeneration after attempt 1 returned an invalid 1254 by 1254 opaque RGB image with a baked checkerboard and insufficient cell margins. The output file itself, not merely its preview, must be exactly 1024 by 1024 pixels in RGBA mode. Alpha outside the four objects must be exactly zero. Never paint, flatten or bake a white, gray, checkerboard, green or any other background into RGB pixels. A transparency checker may appear only in an application preview, never in the delivered PNG pixels.

Divide the exact 1024 by 1024 canvas into four non-overlapping 512 by 512 cells: A [0,0,512,512] equipped-trinket sheath base; B [512,0,1024,512] candidate-trinket insert base; C [0,512,512,1024] adaptive menu-frame nine-slice master; D [512,512,1024,1024] short joiner clasp used between the paired equipped sheaths. Keep every cell independent and centered. Every visible or partially transparent pixel of each object, including antialiasing and shadow, must stay inside the local safe box [80,80,432,432] of its own 512 by 512 cell. Therefore no object may exceed 352 by 352 pixels, and each object must have at least 80 pixels of true alpha-zero padding on all four sides. No visible pixel may cross or touch a cell boundary.

This output is an asset atlas, not an assembled action-bar scene. Do not paint a game screenshot, screen background, action bar, consumable rack, item grid, labels, or multiple repeated runtime instances into any cell.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted bitmap language, deep walnut and smoke-brown aged leather, muted oxidized brass, slightly irregular thick silhouettes, restrained wear, short warm upper-left light, darker lower-right pressure, low saturation, low-frequency value grouping, and believable material thickness. Ignore its character-window outline, parchment attribute panel, model area, equipment layout, tabs, text, icons and all large composition. Runtime geometry below overrides Image 1 whenever they conflict. Render every object in a straight-on orthographic 2D UI view with the same upper-left light and no three-quarter scene perspective.

Cell A is one square leather sheath behind a live 36 by 36 UI trinket ActionButton. It must read as a compact functional sheath, not a generic spell slot: a slightly thicker deep-leather rim, a quiet recessed center completely covered by the live icon, one small muted-brass keeper near the upper edge, and no jewel, socket, gem glow or fixed trinket. It will display at roughly 40 to 44 UI units behind each of the two equipped buttons. Cell B is a visibly lighter and thinner square leather insert for each live 36 by 36 candidate button, with substantially less brass and less depth than Cell A. Keep Cell B's brass broken into only a few short quiet accents; do not form a continuous bright bezel. Cell C is a square, quiet, non-directional nine-slice frame master with narrow broken brass edge segments and a matte stretchable center; it must remain valid around live menu frames from 52 by 52 UI through 172 by 332 UI, 212 by 252 UI and 1212 by 52 UI without creating fixed grid lines, fake pockets or a focal ornament in the center. Keep its corner and edge ornaments short and thin enough that a 52 by 52 runtime frame does not become a solid brass block. Cell D is a very short leather-and-brass joiner that can sit in the 4 UI gap between two equipped sheaths in horizontal or vertical orientation; it must rotate cleanly and never enter either 36 by 36 hit area.

The confirmed runtime composition instantiates two Cell A sheaths as a horizontal paired dock on the right of the main action bar, with the pair bottom-aligned to the main bar and to the consumable roll on the opposite side. Cell D joins only the 4 UI gap between the two sheaths. The current typical candidate menu docks to the pair's right side, uses four columns and grows upward; Cell C must also remain valid for the provider's vertical or horizontal menu direction, automatic one-to-five columns, manual one-to-thirty columns, zero-candidate hidden state and up to thirty live candidates. Candidate content expands outward and upward rather than over the main skill icons. These are runtime assembly constraints only; do not render the assembled dock or menu into the atlas.

All four cells contain only the normal static base layer. Do not bake hover, pressed, selected, checked, cooldown, disabled, range, queue, autoqueue, keybinding, text, count, tooltip, equipment quality, item icon, inventory-slot number, left-click or right-click labels. Those are live provider layers. Avoid continuous bright gold bezels, wide quality colors, glossy PBR gradients, fine photographic grain, micro-scratches, dense stitching, perfect machined symmetry, modern glass cards, neon glows, jewel cabinets, altars, stone plinths and decorative elements that would become noise at approximately 29 to 36 physical pixels. Compared with attempt 1, simplify the dense leather micro-scratches into broader hand-painted value shapes and reduce the amount and brightness of brass, while preserving the successful four object identities and the heavier equipped-sheath versus lighter candidate-insert hierarchy. Preserve clear alpha separation, calm icon-safe centers, and a visual weight slightly heavier than the consumable pockets but lower than the main action bar.

Before finalizing, inspect the actual delivered file properties and pixels: width exactly 1024, height exactly 1024, mode RGBA, transparent background alpha exactly zero, exactly four isolated front-facing objects in their assigned cells, and every object's full visible and antialiased bounds inside its local [80,80,432,432] safe box. Verify that Cell C has a quiet stretchable center, Cell D rotates cleanly, and no dynamic provider content, checkerboard or assembled UI has been painted. If any one of these checks fails, correct it before returning the PNG.
```

`r1` 只修复 attempt 1 已证实的 canvas／Alpha／cell safe margin，以及同一美术包络
内的过密皮纹、偏多黄铜和小尺寸角件重量；四个 cell 身份、Image 1、provider
几何、动态所有权与 `1024² RGBA` 合同均未改变，不需要新授权。

## 固定服务传输约束与已授权修订

- 固定 `@openai/codex@0.143.0` 的两次独立 ImageGen 都完成生成，但会话可取回的
  原始附件均恒为 `1254×1254 RGB`，Alpha 全 `255`，并把透明预览棋盘烘焙进
  RGB；attempt 1／2 SHA 分别为 `fe4b854e…c9e8d`／`85f3f6f0…50b7`。
- attempt 2 已逐字强调 exact `1024² RGBA`、实际文件属性和禁止棋盘，返回格式
  仍完全相同，因此这不是继续强化同一文字即可可靠修复的美术问题。
- 项目既有 AB.SLOT／AB.RAIL 已证明该固定服务可稳定生成纯 `#00FF00` 背景 raw，
  再由本地确定性流程只做整图归一、逐 cell 完整 bbox 等比缩放／居中、从画布
  边缘连通色键转 straight Alpha 与全透明 RGB 清零；不重绘、不锐化、不补像素。
- 修订只改变外部服务的 raw 传输表示；最终供用户审阅和以后可能晋级的
  canonical atlas 仍严格为 `1024×1024 RGBA`、四个 `512²` cell、每格至少
  `80 px` 透明边和同一对象／provider／动态所有权。Trinket 剩余预算仍为 `3`
  次，Consumable 仍为完整 `5` 次，两个账本不混算。
- 用户于 `2026-08-09` 明确授权把 prompt 的“服务直接返回 Alpha”改为“服务
  输出纯 `#00FF00` RGB raw，本地导出最终 Alpha”；允许整图归一、逐 cell 完整
  bbox 等比缩放居中、边缘连通色键转 straight Alpha、透明 RGB 清零；明确
  不重绘、不新增输入图、原预算不重置。
- 确定性实现为 `tools/canonicalize_action_fieldkit_candidate_v1.py`；canonical
  reviewer 只接受 raw／canonical SHA 与 `aeui-action-fieldkit-canonicalization-v1`
  报告完全匹配的 exact atlas。任何 canonical 技术通过仍不能掩盖对象身份、
  `C` 中心、透视或美术失败，也不能在用户接受前进入 source／runtime。

## 修复执行正文 A.r2（`AB.TRINKET.KIT.V1.r2`）

状态：`repair-final / transport-amended / prepared-attempt-03`。

```text
Create one brand-new square RGB transport atlas for Turtle WoW 1.18.1, component AB.TRINKET.KIT.V1 repair r2. This is a fresh regeneration from the single authorized Image 1; do not use either earlier attempt as an image input. The provider raw is not the final transparent candidate. Prefer an exact 1024 by 1024 RGB PNG when the service permits it. If the fixed service unavoidably returns another square provider-native size such as 1254 by 1254, preserve the same proportional four-quadrant composition and do not add a presentation border. The local deterministic pipeline will normalize the complete square to 1024 by 1024, split it into four exact 512 by 512 cells, convert only edge-connected chroma green to straight Alpha, fit each cell's complete visible bounding box proportionally and centered inside its local [80,80,432,432] safe box, and clear RGB under fully transparent pixels. Do not simulate those local operations by cropping, clipping, repainting, duplicating, or preassembling the objects.

Use one perfectly flat, uniform, pixel-level exact RGB #00FF00 field across every pixel outside the four objects, including the entire outer canvas edge and every open area of every quadrant. Return RGB, not transparency. Do not return an Alpha channel, checkerboard, white or gray transparency preview, near-green gradient, green noise, floor, haze, vignette, cast-shadow scene, labels, guides, cell lines, or a framed presentation sheet. Do not use green verdigris, green patina, green leather, green highlights, or any other green material inside an object. Each quadrant must contain exactly one complete isolated object centered with a broad green moat; no object, antialiasing, wear, highlight, shadow, or detached piece may touch or cross the horizontal or vertical quadrant boundary.

The four equal quadrants are fixed in reading order: A top-left is one equipped-trinket sheath base; B top-right is one candidate-trinket insert base; C bottom-left is one adaptive menu-frame nine-slice master; D bottom-right is one short joiner clasp used between the paired equipped sheaths. This is an asset atlas, not an assembled action-bar scene. Do not paint a game screenshot, screen background, action bar, consumable rack, item grid, menu full of repeated pockets, labels, or multiple runtime instances into any quadrant.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted bitmap language, deep walnut and smoke-brown aged leather, muted oxidized brass, slightly irregular thick silhouettes, restrained wear, broad low-frequency value grouping, short warm upper-left light, darker lower-right pressure, low saturation, and believable material thickness. Ignore its character-window outline, parchment attribute panel, model area, equipment arrangement, tabs, text, icons, and full-window composition. The real TrinketMenu geometry and object identities in this prompt override Image 1 wherever they conflict. Render every object as a straight-on orthographic two-dimensional UI asset with one shared upper-left light, no camera tilt, no three-quarter scene perspective, and no cast shadow on the green field.

Cell A is one compact square leather sheath behind a live 36 by 36 UI equipped-trinket ActionButton. Preserve the successful repaired direction: it is the heaviest of the four bases but still subordinate to the main action bar, with a slightly thicker deep-walnut leather rim, a quiet recessed center that the live icon covers, one small muted-brass keeper near the upper edge, restrained broad wear, and no jewel, socket, gem glow, fixed trinket, continuous gold bezel, or dense scratch network. It will display at roughly 40 to 44 UI units behind each of two equipped buttons.

Cell B is one visibly lighter and thinner square leather insert behind a live 36 by 36 UI candidate button. Preserve its successful hierarchy from the repaired direction: less depth, less brass, fewer edge accents, and less visual weight than A. It must still read as a practical trinket insert rather than a generic spell slot, glass card, quality frame, or miniature jewelry cabinet. Keep its center quiet for the provider icon and state layers.

Cell C is one complete filled square non-directional nine-slice menu-frame master. The previous repair failed because C became a hollow outline; do not repeat that result. C must contain a continuous matte smoke-brown leather center spanning the whole interior, with no green hole, window, cutout, transparent-looking opening, empty portal, or exposed background. Around that filled center use only a shallow dark-leather outer boundary and a few narrow broken muted-brass edge segments. Corners and edges must stay quiet and mechanically compatible with menu frames from 52 by 52 UI through 172 by 332 UI, 212 by 252 UI, and 1212 by 52 UI. Do not create fixed grid lines, fake candidate pockets, nested frames, a central emblem, a directional ornament, dense stitching, or corner masses that become solid brass at the smallest menu size. The broad center must be low-frequency and stretchable in both axes.

Cell D is one very short leather-and-muted-brass joiner for only the 4 UI gap between the paired equipped sheaths. Keep the repaired small, simple, low-noise direction. It must be much shorter and visually lighter than A or B, have a calm middle, rotate cleanly between horizontal and vertical use, and never imply a button, jewel, hinge plate, long rail, or element that enters either live 36 by 36 hit area.

The confirmed runtime composition instantiates two A sheaths as a horizontal paired dock on the right of the main action bar, bottom-aligned with that bar and the consumable roll on the opposite side. D joins only their 4 UI gap. The current candidate menu docks to the pair's right side, uses four columns, and grows upward. C must also remain valid for vertical or horizontal menu direction, automatic one-to-five columns, manual one-to-thirty columns, zero-candidate hidden state, and up to thirty live candidates. Candidate content expands outward and upward rather than over the main skill icons. These are runtime assembly constraints only; do not paint the assembled dock, repeated sheaths, candidate grid, or menu into the raw atlas.

All four quadrants contain only one normal static base each. Do not bake hover, pressed, selected, checked, cooldown, disabled, range, queue, autoqueue, keybinding, text, count, tooltip, equipment quality, item icon, inventory-slot number, left-click or right-click labels. Those are live provider layers above this art. Avoid continuous bright gold bezels, wide quality colors, glossy PBR gradients, fine photographic grain, micro-scratches, dense stitch networks, perfect machined symmetry, modern glass cards, neon glows, jewel cabinets, altars, stone plinths, fixed grid cells, and decoration that becomes noise at approximately 29 to 36 physical pixels. Keep A heavier than B; keep C broad, quiet, filled, and stretchable; keep D tiny and rotatable; keep the whole kit slightly heavier than consumable pockets but clearly lighter than the main action bar.

Before returning the RGB raw, inspect every requirement literally: one square RGB file; exactly four isolated front-facing objects in the assigned quadrants; a flat exact #00FF00 field on all canvas and quadrant edges and around every object; no checkerboard or Alpha; no green material or green hole inside any object; no object touching a quadrant boundary; A is the thicker equipped sheath; B is the lighter candidate insert; C is a fully filled matte-center nine-slice master rather than a hollow frame; D is a short rotatable joiner; no dynamic provider content, repeated runtime instances, assembled UI, labels, cell guides, modern glass, neon, stone, jewel, glossy PBR, or dense microtexture is painted.
```

`r2` 只采用用户已授权的 raw→canonical 传输修订，并在原修复包络内恢复 attempt 2
失败的 `C` matte center；A／B／D 身份、降噪方向、四对象数量、唯一 Image 1、
provider 几何、动态所有权与最终 `1024² RGBA` 验收合同均未改变。attempt 3 必须
fresh regenerate；attempt 1／2 不作为输入。

## 修复执行正文 A.r3（`AB.TRINKET.KIT.V1.r3`）

状态：`repair-final / transport-amended / prepared-attempt-04`。

```text
Create one brand-new square RGB transport atlas for Turtle WoW 1.18.1, component AB.TRINKET.KIT.V1 repair r3. This is a fresh regeneration from the single authorized Image 1. Do not use attempts 1, 2, or 3 as image inputs. The provider raw is not the final transparent candidate. Prefer an exact 1024 by 1024 RGB PNG when the service permits it. If the fixed service unavoidably returns another square provider-native size such as 1254 by 1254, preserve the same proportional four-quadrant composition and do not add a presentation border. The local deterministic pipeline will normalize the complete square to 1024 by 1024, split it into four exact 512 by 512 cells, convert only edge-connected chroma green to straight Alpha, fit each cell's complete visible bounding box proportionally and centered inside its local [80,80,432,432] safe box, and clear RGB under fully transparent pixels. Do not simulate those local operations by cropping, clipping, repainting, duplicating, or preassembling the objects.

Use one perfectly flat, uniform, pixel-level exact RGB #00FF00 field across every pixel outside the four objects, including the entire outer canvas edge and every open area of every quadrant. Return RGB, not transparency. Do not return an Alpha channel, checkerboard, white or gray transparency preview, near-green gradient, green noise, floor, haze, vignette, cast-shadow scene, labels, guides, cell lines, or a framed presentation sheet. Do not use green verdigris, green patina, green leather, green highlights, or any other green material inside an object.

The four equal quadrants are fixed in reading order: A top-left is one equipped-trinket sheath base; B top-right is one candidate-trinket insert base; C bottom-left is one adaptive menu-frame nine-slice master; D bottom-right is one short joiner clasp used between the paired equipped sheaths. Each quadrant must contain exactly one complete isolated object and nothing from any neighbouring object. The previous raw failed because Cell C extended across the vertical quadrant boundary and left a separate C-frame strip inside Cell D. Do not repeat that failure. Center every complete object in both axes and fit its full antialiasing, wear, highlight, shadow, and every attached detail inside only the central 68.75 percent of its own quadrant, leaving at least 15.625 percent uninterrupted green moat on all four local sides. On an exact 1024 canvas this means every object stays inside local [80,80,432,432] of its 512 cell. On a provider-native 1254 canvas this means every object stays inside approximately local [98,98,529,529] of its 627 cell. No visible pixel may touch or cross a quadrant boundary, and Cell D must contain only the joiner rather than any strip, edge, or fragment from Cell C.

This is an asset atlas, not an assembled action-bar scene. Do not paint a game screenshot, screen background, action bar, consumable rack, item grid, menu full of repeated pockets, labels, or multiple runtime instances into any quadrant.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted bitmap language, deep walnut and smoke-brown aged leather, muted oxidized brass, slightly irregular thick silhouettes, restrained wear, broad low-frequency value grouping, short warm upper-left light, darker lower-right pressure, low saturation, and believable material thickness. Ignore its character-window outline, parchment attribute panel, model area, equipment arrangement, tabs, text, icons, and full-window composition. The real TrinketMenu geometry and object identities in this prompt override Image 1 wherever they conflict. Render every object as a straight-on orthographic two-dimensional UI asset with one shared upper-left light, no camera tilt, no three-quarter scene perspective, and no cast shadow on the green field.

Cell A is one compact square leather sheath behind a live 36 by 36 UI equipped-trinket ActionButton. Preserve the successful identity and thicker-than-B hierarchy from attempt 3, but simplify it for approximately 29 to 36 physical pixels. Use a deep-walnut leather rim, quiet recessed center, broad matte hand-painted value shapes, and exactly one small muted dark-brass keeper near the upper edge. Do not add brass plates on the left, right, bottom, or corners; do not make the upper keeper large enough to read as a shield or jewel mount. Use no rivet array, jewel, socket, gem glow, fixed trinket, continuous gold bezel, embossed photo-real grain, or dense scratch network. A is the heaviest static base in this atlas but remains subordinate to the main action bar.

Cell B is one visibly lighter and thinner square leather insert behind a live 36 by 36 UI candidate button. Preserve its successful practical insert identity and quiet icon center, while reducing attempt 3's corner metal and fine leather grain. Use substantially less depth and less brass than A: at most one tiny short dark-brass edge accent, never a large corner plate, bright bezel, quality frame, generic spell slot, glass card, or miniature jewelry cabinet.

Cell C is one complete filled square non-directional nine-slice menu-frame master, centered and wholly contained in the bottom-left quadrant. Preserve attempt 3's successful continuous matte smoke-brown leather center; do not revert to the hollow outline from attempt 2. The center must span the entire interior with no green hole, window, cutout, transparent-looking opening, empty portal, or exposed background. Around it use one shallow dark-leather outer boundary and only a few very short near-black oxidized-brass edge traces. Remove the attempt 3 corner plates, corner rivets, long side plates, and long top or bottom metal bars. At the smallest 52 by 52 UI menu, no corner or edge may become a solid brass block. Keep every long stretch region quiet, low-frequency, and non-directional so the same master works from 52 by 52 UI through 172 by 332 UI, 212 by 252 UI, and 1212 by 52 UI. Do not create fixed grid lines, fake candidate pockets, nested frames, a central emblem, directional ornament, dense stitching, or high-frequency leather grain.

Cell D is one very short horizontal leather joiner for only the 4 UI gap between the paired equipped sheaths, centered and wholly contained in the bottom-right quadrant. Preserve the successful small rotatable identity but simplify attempt 3's metal weight: use a calm dark-leather middle and only narrow muted dark-brass tips. Do not use large end-cap plates, three rivets, a jewel, hinge plate, long rail, button silhouette, or any element that enters either live 36 by 36 hit area. It must remain much shorter and lighter than A or B and rotate cleanly for vertical use.

The confirmed runtime composition instantiates two A sheaths as a horizontal paired dock on the right of the main action bar, bottom-aligned with that bar and the consumable roll on the opposite side. D joins only their 4 UI gap. The current candidate menu docks to the pair's right side, uses four columns, and grows upward. C must also remain valid for vertical or horizontal menu direction, automatic one-to-five columns, manual one-to-thirty columns, zero-candidate hidden state, and up to thirty live candidates. Candidate content expands outward and upward rather than over the main skill icons. These are runtime assembly constraints only; do not paint the assembled dock, repeated sheaths, candidate grid, or menu into the raw atlas.

All four quadrants contain only one normal static base each. Do not bake hover, pressed, selected, checked, cooldown, disabled, range, queue, autoqueue, keybinding, text, count, tooltip, equipment quality, item icon, inventory-slot number, left-click or right-click labels. Those are live provider layers above this art. Avoid continuous bright gold bezels, wide quality colors, glossy PBR gradients, fine photographic or embossed grain, micro-scratches, dense stitch networks, perfect machined symmetry, modern glass cards, neon glows, jewel cabinets, altars, stone plinths, fixed grid cells, and decoration that becomes noise at runtime. Keep A heavier than B; keep C broad, quiet, filled, stretchable, and visually lighter than A; keep D tiny and rotatable; keep the whole kit slightly heavier than consumable pockets but clearly lighter than the main action bar.

Before returning the RGB raw, inspect every requirement literally: one square RGB file; exactly four isolated front-facing objects in the assigned quadrants; every complete object centered inside the central 68.75 percent of its own quadrant with at least 15.625 percent green moat on all four local sides; no C fragment or any other object crosses into Cell D; a flat exact #00FF00 field on all canvas and quadrant edges and around every object; no checkerboard or Alpha; no green material or green hole inside any object; A has exactly one small upper keeper and no side plates; B has at most one tiny metal accent and no corner plate; C has a fully filled matte center and no corner plates, rivets, long metal bars, fixed grid, or hollow opening; D is a short leather joiner with narrow tips and no large cap plates or rivet row; no dynamic provider content, repeated runtime instances, assembled UI, labels, cell guides, modern glass, neon, stone, jewel, glossy PBR, or dense microtexture is painted.
```

`r3` 只修复 attempt 3 已证实的跨 cell 物件污染、过大的 raw 占用与同一美术
包络内偏重的黄铜／微纹理。它保留 attempt 3 已恢复的 `C` 连续 matte center、
A／B／D 身份和层级、四对象数量、唯一 Image 1、provider 几何、动态所有权及
最终 canonical 合同。attempt 4 必须 fresh regenerate；attempt 1–3 均不作为输入。

## 最终执行正文 B（`AB.CONSUMABLE.KIT.V1`）

状态：`visual-envelope-authorized / direct-alpha-body-superseded-for-execution /
historical-provenance-only / 0/5`。下列原正文只保留为获授权的视觉／对象合同和
Git provenance，不得再逐字执行其 direct-Alpha 传输段；实际执行只使用其后完整
自包含的 `AB.CONSUMABLE.KIT.V1.transport`。

```text
Create one production-ready transparent RGBA UI asset atlas for Turtle WoW 1.18.1, component AB.CONSUMABLE.KIT.V1. The output canvas must be exactly 1024 by 1024 pixels and divided into four non-overlapping 512 by 512 cells: A [0,0,512,512] main consumable pocket base; B [512,0,1024,512] thinner popup pocket base; C [0,512,512,1024] adaptive alchemist-roll nine-slice frame master that can also frame small non-interactive group tabs; D [512,512,1024,1024] narrow rotatable and length-stretchable connector strip for popup gaps and group divider seams. Keep each object independent, centered, fully visible and surrounded by at least 80 transparent pixels. No visible pixels may connect across cell boundaries. Everything outside each object must be true alpha zero, never chroma-key green.

This output is an asset atlas, not an assembled inventory or action-bar scene. Do not paint a game screenshot, screen background, complete 24-slot grid, action bar, item collection, labels, or repeated runtime instances into any cell.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted low-resolution rendering, warm aged leather, deep walnut shadows, muted oxidized brass, slightly irregular thick silhouettes, short upper-left warmth, restrained lower-right pressure, low saturation, broad readable value shapes and practical wear. Ignore the character-window composition, parchment, model background, equipment arrangement, tabs, text and icons. The real AutoBar button and popup geometry below is mandatory and overrides Image 1 when necessary. Render every object in a straight-on orthographic 2D UI view with the same upper-left light and no three-quarter scene perspective.

Cell A is one independent square opening for a live AutoBar 36 by 36 UI item button: warm brown soft leather folded around a dark quiet center, a shallow pressure mark and sparse uneven stitches kept outside the icon-safe center. It must not resemble the main skill slot or contain a bottle. Its broad edge shapes must remain readable if the provider independently changes button width, height or scale, so do not rely on a circular focal motif or fine directional ornament. Cell B is the same family but thinner and lighter, as if a small insert unfolds from behind the main roll for one live popup candidate. Cell C is a square non-directional nine-slice master for an adaptive field alchemist roll. Use a warm old-leather outer fold, sparse short stitches and very small muted-brass fasteners at safe corners. The center must be quiet and stretchable around the recommended full-capacity 4-by-6 body of 165 by 243 UI, around three separate 40 by 20 UI non-interactive label tabs, and around every other supported real rack from 48 by 48 UI through 204 by 87 UI and the 945 by 48 or 48 by 945 UI extremes. Do not paint fixed pockets, a fixed grid, words or category marks into this frame. Cell D is one narrow connector with a completely quiet stretchable middle: it must rotate for TOP, BOTTOM, LEFT and RIGHT popup chains, fit the provider's 3 UI gap between adjacent popup buttons, and stretch horizontally beneath the buttons to form exactly two subtle divider seams between rows 2 and 3 and rows 4 and 5 of the recommended 4-by-6 profile. It may not contain repeated rivets, words or a directional motif that breaks when stretched.

The confirmed runtime composition instantiates twenty-four Cell A pockets as four columns by six rows on the left of the main action bar, with the 165 by 243 UI roll body bottom-aligned to the main bar and to the paired trinket dock on the opposite side. Contiguous slots 1-8, 9-16 and 17-24 form three two-row groups for Emergency, Buffs and Utility. The three 40 by 20 UI label tabs remain outside every button hit box, and the two divider seams remain beneath the buttons. If button count, 4-by-6 layout or profile signature does not match, all group tabs and divider seams are hidden and Cell C falls back to one unlabeled adaptive shell. Each main button remains a provider category entry; one to twelve real items unfold from it as separate Cell B popup pockets in the provider's TOP, BOTTOM, LEFT or RIGHT direction. The rack and popup expand away from the central skill icons. These are runtime assembly constraints only; do not render the assembled rack, category text or items into the atlas.

All cells are normal static bases only. The recommended profile instantiates twenty-four live buttons as four columns by six rows; contiguous slots 1-8, 9-16 and 17-24 are described only by runtime FontStrings as Emergency, Buffs and Utility. Do not bake those words, colored group blocks, potions, elixirs, flasks, food, drinks, bandages, engineering items, category marks, item names, keybinds, quantities, cooldown wedges or numbers, availability, family selection, tooltip content, hover, pressed, disabled, empty, missing-item or shift state. Those remain adapter or AutoBar-owned. There is no native FLASK category in the audited provider; a flask slot can only contain a real item ID manually inserted by the user, so do not invent a flask category or flask symbol. The three tabs and two seams are mouse-disabled decoration beneath or outside every real button hit box. They must use the same warm leather and restrained dark brass as the roll, never red-blue-green dashboard coding. The visual adapter must not enable AutoBar; when the provider is disabled or absent, no rack or placeholder is shown. Avoid fixed bottle illustrations, modern card grids, glass panels, bright continuous gold frames, quality glows, large clasps, glossy PBR leather, dense fibers, tiny photographic scratches, perfect symmetry, stone bases and visual weight that competes with the main action bar. The final atlas must stay readable and subordinate at approximately 29 to 36 physical pixels per live pocket. Before finalizing, verify that the canvas contains exactly four isolated front-facing objects in their assigned cells, every object has at least 80 transparent pixels around it, Cells C and D retain quiet stretchable centers, Cell D rotates cleanly, and no item, category label, fixed grid, dynamic provider state or assembled UI has been painted.
```

## 传输修订执行正文 B.0（`AB.CONSUMABLE.KIT.V1.transport`）

状态：`production-final / transport-amended / source-accepted / P4 /
stopped-at-1/5`。

```text
Create one brand-new square RGB transport atlas for Turtle WoW 1.18.1, component AB.CONSUMABLE.KIT.V1. This is a fresh generation from the single authorized Image 1. Do not use any Trinket Kit attempt, Field Kit simulation, AB.SLOT, AB.RAIL, or other generated image as an input. The provider raw is not the final transparent candidate. Prefer an exact 1024 by 1024 RGB PNG when the service permits it. If the fixed service unavoidably returns another square provider-native size such as 1254 by 1254, preserve the same proportional four-quadrant composition and do not add a presentation border. The local deterministic pipeline will normalize the complete square to 1024 by 1024, split it into four exact 512 by 512 cells, convert only edge-connected chroma green to straight Alpha, fit each cell's complete visible bounding box proportionally and centered inside its local [80,80,432,432] safe box, and clear RGB under fully transparent pixels. Do not simulate those local operations by cropping, clipping, repainting, duplicating, or preassembling the objects.

Use one perfectly flat, uniform, pixel-level exact RGB #00FF00 field across every pixel outside the four objects, including the entire outer canvas edge and every open area of every quadrant. Return RGB, not transparency. Do not return an Alpha channel, checkerboard, white or gray transparency preview, near-green gradient, green noise, floor, haze, vignette, cast-shadow scene, labels, guides, cell lines, or a framed presentation sheet. Do not use green verdigris, green patina, green leather, green highlights, or any other green material inside an object.

The four equal quadrants are fixed in reading order: A top-left is one main consumable-pocket base; B top-right is one thinner popup-pocket base; C bottom-left is one adaptive alchemist-roll nine-slice frame master that can also frame small non-interactive group tabs; D bottom-right is one narrow rotatable and length-stretchable connector strip for popup gaps and group-divider seams. Each quadrant must contain exactly one complete isolated object and nothing from any neighbouring object. Center every complete object in both axes and fit its full antialiasing, wear, highlight, shadow, stitch, fastener, and every attached detail inside only the central 68.75 percent of its own quadrant, leaving at least 15.625 percent uninterrupted green moat on all four local sides. On an exact 1024 canvas this means every object stays inside local [80,80,432,432] of its 512 cell. On a provider-native 1254 canvas this means every object stays inside approximately local [98,98,529,529] of its 627 cell. No visible pixel may touch or cross a quadrant boundary, and every cell must contain exactly one significant connected object.

This is an asset atlas, not an assembled inventory or action-bar scene. Do not paint a game screenshot, screen background, complete 24-slot grid, action bar, item collection, consumable rack, category board, labels, guides, or repeated runtime instances into any quadrant.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted bitmap language, warm aged leather, deep walnut shadows, muted oxidized brass, slightly irregular thick silhouettes, restrained practical wear, broad low-frequency readable value shapes, short upper-left warmth, darker lower-right pressure, low saturation, and believable material thickness. Ignore its character-window outline, parchment attribute panel, model area, equipment arrangement, tabs, text, icons, and full-window composition. The real AutoBar button and popup geometry in this prompt is mandatory and overrides Image 1 wherever necessary. Render every object as a straight-on orthographic two-dimensional UI asset with one shared upper-left light, no camera tilt, no three-quarter scene perspective, and no cast shadow on the green field.

Cell A is one independent compact square pocket base behind a live AutoBar 36 by 36 UI category button. Use warm smoke-brown soft leather folded around a dark quiet center, one shallow pressure mark, and only a few sparse uneven stitches outside the icon-safe center. It must not resemble the heavier main skill slot, contain a bottle, use a circular focal motif, or rely on fine directional ornament. Its broad edge shapes must remain readable at approximately 29 to 36 physical pixels and if the provider independently changes button width, height, or scale. Keep brass to at most one tiny muted fastener or short trace; do not use a continuous gold bezel, large clasp, rivet array, dense fibers, embossed photo-real grain, or tiny photographic scratches.

Cell B is one independent popup-pocket base from the same family, visibly thinner, lighter, and less decorated than A, behind one live AutoBar popup candidate button. It should read as a small leather insert unfolding from behind the main roll. Keep its center quiet for the live icon and use less depth, stitching, and brass than A. Do not turn it into a quality frame, spell slot, glass card, jewel mount, or miniature container.

Cell C is one complete filled square non-directional nine-slice master for an adaptive field alchemist roll. Use a warm old-leather outer fold, sparse short stitches, and only very small muted dark-brass fasteners at safe corners or short edge positions. The center must be continuous quiet matte smoke-brown leather with no green hole, window, cutout, exposed background, fixed pockets, fixed grid, words, category marks, emblem, or directional ornament. Keep all long stretch regions broad, low-frequency, and non-directional. The same master must remain valid around the recommended full-capacity 4-by-6 body of 165 by 243 UI, three separate 40 by 20 UI non-interactive group-label tabs, the 48 by 48 UI minimum rack, the 204 by 87 UI compact rack, and the 945 by 48 or 48 by 945 UI extremes. No corner or edge may become a solid bright metal block at the smallest supported size.

Cell D is one complete narrow horizontal connector strip with a calm dark-leather middle and restrained dark edge treatment. It must rotate cleanly for TOP, BOTTOM, LEFT, and RIGHT popup chains, fit the provider's 3 UI gap between adjacent popup buttons, and stretch horizontally beneath buttons to form exactly two subtle divider seams between rows 2 and 3 and rows 4 and 5 of the recommended 4-by-6 profile. Its middle must be quiet and length-stretchable. Do not use repeated rivets, words, a directional motif, a large end-cap plate, a jewel, a button silhouette, or decoration that breaks when rotated or stretched.

The confirmed runtime composition instantiates twenty-four A pockets as four columns by six rows on the left of the main action bar, with the 165 by 243 UI roll body bottom-aligned to the main bar and to the paired trinket dock on the opposite side. Contiguous slots 1-8, 9-16, and 17-24 form three two-row groups for Emergency, Buffs, and Utility. The three 40 by 20 UI label tabs remain outside every button hit box, and the two D divider seams remain beneath the buttons. If button count, 4-by-6 layout, or profile signature does not match, all group tabs and divider seams are hidden and C falls back to one unlabeled adaptive shell. Each main button remains a provider category entry; one to twelve real items unfold from it as separate B popup pockets in the provider's TOP, BOTTOM, LEFT, or RIGHT direction. The rack and popup expand away from the central skill icons. These are runtime assembly constraints only; do not paint the assembled rack, repeated pockets, category text, or items into the raw atlas.

All four quadrants contain only one normal static base each. Do not bake Emergency, Buffs, Utility, potions, elixirs, flasks, food, drinks, bandages, engineering items, category marks, item names, keybinds, quantities, cooldown wedges, numbers, availability, family selection, tooltip content, hover, pressed, disabled, empty, missing-item, or shift state. Those are adapter or AutoBar-owned live layers. There is no native FLASK category in the audited provider; do not invent a flask category or flask symbol. The three tabs and two seams are mouse-disabled decoration beneath or outside every real button hit box. The visual adapter must not enable AutoBar; when the provider is disabled or absent, no rack or placeholder is shown. Avoid fixed bottle illustrations, modern card grids, glass panels, bright continuous gold frames, quality glows, large clasps, glossy PBR leather, dense fibers, micro-scratches, perfect machined symmetry, stone bases, and visual weight that competes with the main action bar. Keep the whole Consumable Kit lighter and softer than the Trinket Kit and clearly subordinate to the main action bar.

Before returning the RGB raw, inspect every requirement literally: one square RGB file; exactly four isolated front-facing objects in the assigned quadrants; every complete object centered inside the central 68.75 percent of its own quadrant with at least 15.625 percent green moat on all four local sides; a flat exact #00FF00 field on all canvas and quadrant edges and around every object; no checkerboard or Alpha; no green material or internal green hole; A is one compact main pocket with a quiet center; B is visibly thinner and lighter than A; C has a fully filled quiet matte center and no fixed grid or labels; D is a narrow quiet rotatable stretchable connector; no object touches or crosses a quadrant boundary; no dynamic provider content, repeated runtime instances, assembled UI, labels, cell guides, modern glass, neon, stone, glossy PBR, or dense microtexture is painted.
```

该正文只把已授权原 B 的 direct-Alpha 传输改为用户明确授权的纯绿 RGB raw→
deterministic canonical 路径，并将同一四格身份、AutoBar 几何、分组、动态所有权和
美术边界完整自包含化；不新增输入图、功能或视觉方向。attempt 1 必须 fresh
generate，Character V3 是唯一 Image 1，任何 Trinket／simulation／AB.SLOT／RAIL
像素都不得作为输入。

### B 的修复边界与预算

- 不可变：四个 cell 身份／数量、最终 canonical `1024² RGBA` canvas、cell 坐标、
  straight Alpha、已授权纯绿 raw 传输、Image 1
  职责、AutoBar 数据与动态排除、全部真实 Button／popup 上限、推荐 `4×6`、
  三段各八槽、`165×243 UI` 主体、`40×20 UI` runtime 标题皮签及签名失配回退。
- 可修复：皮革折边、缝线密度、黄铜比例、透明边缘、cell 内位置、九宫格中心
  安静度和连接带旋转可读性。
- 需要重新授权：新增／替换输入图、上传新图、启用 AutoBar、引入 provider
  之外的自动分类／钉选逻辑、改变 cell 身份／数量或把模拟像素当输入。
- 预算：`1/5`；attempt 1 已返回 countable provider output 并内部全门禁通过；按
  pass 即停，剩余四次不再使用；用户已接受并晋级 P4 source，runtime 仍须独立
  P4→P5 操作。

## 尝试与流程错误账本

### `AB.TRINKET.KIT.V1`

| 实际尝试 | 执行体 | 结果 | 结论 |
|---:|---|---|---|
| `1/5` | production final | raw `fe4b854e…c9e8d`；`1254×1254 RGB`、全不透明；四个语义对象存在 | fail：必须重生为 exact `1024² RGBA`、真 Alpha、四 cell 各边至少 `80 px`；执行 `r1` |
| `2/5` | repair `r1` | raw `85f3f6f0…50b7`；仍为 `1254×1254 RGB`、全不透明；B margin pass，A／C fail，C 中心透明 | fail：格式／Alpha 未改善且 C 语义回退；raw 绿色键控→canonical RGBA 传输修订已获授权，完整 `r2` 已准备 |
| `3/5` | repair `r2` | raw `0c6f0bc7…8048`；canonical `6a91a2b5…5e13` 为 exact `1024² RGBA`、绿残留／透明 RGB／最终 margin pass | fail：raw `C` bbox 右边触碰 cell 中线，`D` cell 出现 `C` 边条＋连接扣两个显著组件；完整 `r3` 已准备 |
| `4/5` | repair `r3` | raw `2e4efc1a…19e3a`；canonical／source `82dd2260…c012`；canonical／semantic／art／真实排版／display 全门禁 pass | 用户接受第 4 稿；`source-accepted / P4`；原循环终止，保留 `1` 次未用预算且不执行 attempt 5 |

### `AB.CONSUMABLE.KIT.V1`

| 实际尝试 | 执行体 | 结果 | 结论 |
|---:|---|---|---|
| `1/5` | transport-amended production final | raw `de25567f…b8ba`；canonical／source `623f29c5…a2419`；canonical／semantic／art／真实排版／display 全门禁 pass | 用户接受第 1 稿；`source-accepted / P4`；原循环终止，保留 `4` 次未用预算且不执行 attempts 2–5 |

流程错误：本地 display contract 曾出现一次 schema 使用错误；没有调用外部
ImageGen、没有返回生成结果，不进入任一账本。Trinket attempt 1 的固定子进程
在 ImageGen 已返回图像后，因 Windows child sandbox `helper_unknown_error` 无法把
结果复制到 `./generated`；父会话按 session ID 从固定执行器的
`generated_images` 中只读定位并逐字节复制，source／destination SHA 均为
`fe4b854e…c9e8d`。该错误没有触发重生，但已有 provider output，故 attempt 1
仍严格计入 `1/5`。

## 执行记录

- 日期：`2026-08-08`
- 操作：本地确定性 `simulate`；V2 renderer／specification／display validator
  与测试命令见“生成前本地模拟”。
- 外部输入／上传：无；Character V3 与 accepted Action Slot 均只读本地读取，
  没有上传。
- ImageGen：`0/0`；生产候选、source、runtime、adapter 与 SavedVariables 改动：
  均无。
- 输出：V2 scene `9fe4d159…164d`、provider states `16a90762…f467`、
  layout `a06bde15…779f`、display `3ada8c3f…2f89`。
- 日期：`2026-08-09`
- 操作：用户明确确认 `AB-FIELDKIT-SIM-V2`；把八项可见方向冻结进两个最终
  production body 并重跑正文完整性预检。
- 外部输入／上传／ImageGen：均为 `0`；未启用 AutoBar、未改变 TrinketMenu
  SavedVariables、未产生候选／source／runtime／adapter。
- 日期：`2026-08-09`
- 操作：用户分别授权执行 `AB.TRINKET.KIT.V1` 与 `AB.CONSUMABLE.KIT.V1`，
  各自最多五次实际生成／修复；两个冻结正文均未改写。
- 外部输入／上传：用户分别授权将
  `assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png`
  作为两个执行体各自唯一的 Image 1 上传到外部 ImageGen；没有授权任何第二张
  输入图、模拟像素或既有 `AB.SLOT／AB.RAIL` 资产。
- ImageGen：此检查点仍为 `0/5 + 0/5`；未启用 AutoBar、未改变 TrinketMenu
  SavedVariables、未产生候选／source／runtime／adapter。
- 日期：`2026-08-09`
- 操作：以冻结 production final 原文调用固定
  `@openai/codex@0.143.0 / gpt-5.5 / medium` 执行 Trinket attempt 1；唯一
  Image 1 为已授权 Character V3，session
  `019fe4cc-8302-7b40-a3e4-859a4d3abe18`。
- countable output：raw
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/production/AB.TRINKET.KIT.V1/attempt-01/raw/AB.TRINKET.KIT.V1.attempt-01.raw.png`，
  SHA `fe4b854e…c9e8d`，`1254×1254 RGB`、`1,823,337` bytes；Trinket 账本
  进入 `1/5`，Consumable 保持 `0/5`。
- 只读审查派生：将烘焙棋盘按亮度阈值移除并整张 LANCZOS 归一到 `1024²`
  仅用于观察失败稿；派生 SHA `f56f7211…8a51`，不得晋级。四 cell 归一后最小
  margin 依次为 `51／63／31／119 px`，前三者未达到 `80 px`。
- 真实排版：scene `926f23ca…875f`、supported layouts
  `1474ae4b…a268`、cell review `4a887dd6…2246`；display `16/16 pass`、
  violations `0`，仅证明既定 provider 几何与图层容纳该四对象方向，不覆盖 raw
  canvas／Alpha／margin 硬失败。
- runtime／provider：未产生 source／runtime／adapter；未启用 AutoBar、未改变
  TrinketMenu SavedVariables。完整自包含修复正文 `AB.TRINKET.KIT.V1.r1` 只在
  已授权修复边界内收紧 canvas、Alpha、safe margin、皮纹频率与黄铜重量。
- 日期：`2026-08-09`
- 操作：提交 `r1` 后，以其原文调用同一固定
  `@openai/codex@0.143.0 / gpt-5.5 / medium` 执行 Trinket attempt 2；唯一
  Image 1 仍为已授权 Character V3，session
  `019fe4d6-a99b-7720-8f2a-37b12c2a274e`，没有上传 attempt 1 或其他新图。
- countable output：raw
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/production/AB.TRINKET.KIT.V1/attempt-02/raw/AB.TRINKET.KIT.V1.attempt-02.raw.png`，
  SHA `85f3f6f0…50b7`，`1254×1254 RGB`、`1,257,352` bytes；Trinket 账本
  进入 `2/5`，Consumable 保持 `0/5`。
- 只读审查派生：同一 review-only 棋盘阈值与全画布归一 SHA
  `82274057…6e64`；四 cell 最小 margin 为 `71／88／42／148 px`。B／D 通过
  `80 px`，A／C 仍失败；C 中心全透明，违反 matte stretchable center。
- 真实排版：scene `c56aa652…6f3c`、supported layouts
  `edc8a8f9…4de0`、cell review `eb89ef94…f2dc`；display report
  `75e00719…35d` 为 `16/16 pass`、violations `0`。这些只证明几何层序，不抵消
  raw 技术合同和 C 中心语义失败。
- runtime／provider：未产生 source／runtime／adapter；未启用 AutoBar、未改变
  TrinketMenu SavedVariables。由于同一服务两次返回同样固定传输格式，剩余调用
  在取得绿色键控 raw→canonical RGBA 的合同修订授权前暂停。
- 日期：`2026-08-09`
- 操作：用户明确授权 `AB.TRINKET.KIT.V1` 与 `AB.CONSUMABLE.KIT.V1` 采用纯
  `#00FF00` RGB raw→本地确定性 canonical `1024² RGBA` 的传输修订；允许整图
  归一、逐 cell 完整 bbox 等比缩放居中、边缘连通色键转 straight Alpha、透明
  RGB 清零；不重绘、不新增输入图、原预算不重置。
- 实现：新增 `tools/canonicalize_action_fieldkit_candidate_v1.py`，并要求
  `tools/review_action_fieldkit_candidate_v1.py` 只在 canonicalization report 的
  component／attempt／raw SHA／canonical SHA／status 全匹配时审查 exact canonical。
  `tests/action_fieldkit_candidate_review_test.py` 覆盖 square normalize、逐 cell fit、
  边缘连通与内部隔离绿色不被误删、透明 RGB 及 provenance。
- 预算／输入：Trinket 仍为 `2/5`、剩余 `3`；Consumable 仍为 `0/5`、剩余 `5`。
  Character V3 仍是各执行体唯一 Image 1；attempt 1／2、模拟与其他 source 均不
  作为新输入。完整 `AB.TRINKET.KIT.V1.r2` 已写入并等待执行前提交。
- 日期：`2026-08-09`
- 操作：从 commit `00eccc1` 提取并逐字传输完整 `AB.TRINKET.KIT.V1.r2`，以固定
  `@openai/codex@0.143.0 / gpt-5.5 / medium` fresh generate attempt 3；唯一
  Image 1 仍为已授权 Character V3，session
  `019fe4eb-bda5-7fe2-951a-3fe06e6834c2`、result
  `ig_0225a41ddc276989016a780b72f2b88191baa7123ecfd79afd`。child 的完整 user
  block 无截断、无 wrapper 递归，也没有上传 attempt 1／2。
- countable output：provider cache、child copy 与本地 raw 三者 SHA 完全一致：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/production/AB.TRINKET.KIT.V1/attempt-03/raw/AB.TRINKET.KIT.V1.attempt-03.raw.png`，
  `1254×1254 RGB`、`1,861,550` bytes、SHA `0c6f0bc7…8048`；Trinket 账本进入
  `3/5`，Consumable 保持 `0/5`。图片落盘后 child 的模型缓存刷新超时，父会话
  终止空等；不触发重生、不改变 countable 结论。
- 确定性 canonical：`attempt-03/canonical/AB.TRINKET.KIT.V1.attempt-03.canonical.png`，
  exact `1024×1024 RGBA`、SHA `6a91a2b5…5e13`；透明 `677066`、半透明
  `11830`、不透明 `359680`，可见强绿 `0`、透明 RGB 非零 `0`，四格最终
  minimum margin 均 `80 px`。canonicalization report 仍为 `fail`：原始归一后
  `C` bbox `[97,22,512,416)` 触碰右中线，`D` bbox `[0,24,356,413)` 触碰左中线，
  `D` 有大小 `14397／1814 px` 的两个显著组件，证明 `C` 边条越界进入 `D`。
- 本地 transport 实现复核：不调用 provider，只把边缘连通绿色 predicate 扩展到
  暗色 green spill，并增加原始 keyed bbox 边界与显著组件门禁；合成回归测试通过。
  该修正仍只属于已授权 straight-Alpha 色键与客观 cell 隔离检查，不重绘候选。
- runtime／provider：因 Prompt／cell scope 已致命失败，不生成候选真实排版或
  display report，不进入 reviewer；未产生 source／runtime／adapter，未启用
  AutoBar、未改变 TrinketMenu SavedVariables。完整 `r3` 只在冻结修复边界内
  收小／居中四物件、移除跨 cell 污染，并进一步压低同方向黄铜／微纹理。
- 日期：`2026-08-09`
- 操作：从 commit `898165c` 提取并逐字传输完整 `AB.TRINKET.KIT.V1.r3`，以固定
  `@openai/codex@0.143.0 / gpt-5.5 / medium` fresh generate attempt 4；唯一
  Image 1 为已授权 Character V3，session
  `019fe4f7-4ddb-7d83-8f60-9fda05576647`、result
  `ig_05e65a84ff65cfd0016a780e4181d881919a9ca3c25055af9a`。child user block 完整，
  没有 wrapper 递归，也没有上传 attempts 1–3 或其他图。
- countable output：provider cache 与本地 raw SHA 完全一致：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/production/AB.TRINKET.KIT.V1/attempt-04/raw/AB.TRINKET.KIT.V1.attempt-04.raw.png`，
  `1254×1254 RGB`、`1,680,288` bytes、SHA `2e4efc1a…19e3a`；Trinket 账本进入
  `4/5`，Consumable 保持 `0/5`。图片已返回后 child 再次卡在模型缓存刷新，父会话
  终止空等并逐字节复制 cache；不触发重生、不改变计数。
- 确定性 canonical：`attempt-04/canonical/AB.TRINKET.KIT.V1.attempt-04.canonical.png`，
  exact `1024×1024 RGBA`、SHA `82dd2260…c012`；透明 `646693`、半透明 `16995`、
  不透明 `384888`，visible green `0`、透明 RGB 非零 `0`。A／B／C／D 原始 keyed
  bbox 分别为 `[115,91,444,425)`／`[85,134,361,408)`／`[82,25,487,424)`／
  `[139,220,284,269)`，各自只有一个显著组件且不触边；最终 minimum margin 全为
  `80 px`。canonicalization report `56f04604…156fc` 为 pass。
- 真实排版／display：review scene `6b59893d…53d5`、supported layouts
  `5b506d53…6da2`、cell review `1cd43ebb…c9f`；candidate review
  `c9c8b22d…441f` 为 pass。display report `0c80e08b…a2ac` 为 `16/16 pass`、
  violations `0`，覆盖水平／垂直双槽、候选 `0／1／8／30`、自动五列、水平菜单
  及合法三十列等场景。
- 结论：Prompt／传输、语义、物理、透视、美术、对象、装配、真实排版及技术像素
  逐层均 pass。该 canonical 仅为 `candidate-reviewed / pending-user-acceptance`；
  按工作流立即停止 Trinket 循环，不执行 attempt 5，不产生 source／runtime／adapter，
  不改变 TrinketMenu SavedVariables。
- 日期：`2026-08-09`
- 操作：从 commit `d193dcc` 提取并逐字传输完整
  `AB.CONSUMABLE.KIT.V1.transport`，以固定
  `@openai/codex@0.143.0 / gpt-5.5 / medium` fresh generate Consumable attempt 1；
  唯一 Image 1 为已授权 Character V3，session
  `019fe501-7dff-73e1-a27e-a2c0e2df82ae`、result
  `ig_07e00c4828d25e6b016a7810f1341081919f816c65784c4604`。child user block 完整，
  没有 wrapper 递归，也没有上传 Trinket／simulation／AB.SLOT／AB.RAIL 像素。
- countable output：provider cache 与本地 raw SHA 完全一致：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/production/AB.CONSUMABLE.KIT.V1/attempt-01/raw/AB.CONSUMABLE.KIT.V1.attempt-01.raw.png`，
  `1254×1254 RGB`、`1,573,310` bytes、SHA `de25567f…b8ba`；Consumable 账本进入
  `1/5`。图片已返回后 child 卡在模型缓存刷新，父会话终止空等并逐字节复制 cache；
  不触发重生、不改变计数。
- 确定性 canonical：`attempt-01/canonical/AB.CONSUMABLE.KIT.V1.attempt-01.canonical.png`，
  exact `1024×1024 RGBA`、SHA `623f29c5…a2419`；透明 `670302`、半透明 `17423`、
  不透明 `360851`，visible green `0`、透明 RGB 非零 `0`。A／B／C／D 原始 keyed
  bbox 分别为 `[138,118,396,366)`／`[153,169,326,339)`／`[49,11,462,424)`／
  `[40,186,463,258)`，各自只有一个显著组件且不触边；最终 minimum margin 全为
  `80 px`。canonicalization report `7b3c9383…433e` 为 pass。
- 真实排版／display：review scene `057c45cb…150a`、supported layouts
  `e78b6dc5…9ae5`、cell review `cc56df10…9fd8`；candidate review
  `d3009fd3…0bfa` 为 pass。display report `741c2ef7…3dfa` 为 `16/16 pass`、
  violations `0`，覆盖 `1×1／5×2／4×6／24×1／1×24`、TOP 6、RIGHT 12 及
  同一 Field Kit 邻接场景。
- 结论：Prompt／传输、语义、物理、透视、美术、对象、装配、真实排版及技术像素
  逐层均 pass。该 canonical 仅为 `candidate-reviewed / pending-user-acceptance`；
  按工作流立即停止 Consumable 循环，不执行 attempts 2–5，不产生
  source／runtime／adapter，不启用 AutoBar。
- 日期：`2026-08-09`
- 操作：用户明确回复“接受 AB.TRINKET.KIT.V1 第4稿与
  AB.CONSUMABLE.KIT.V1 第1稿”；执行 `accept`，不调用 ImageGen。Trinket attempt 4
  canonical 以 SHA `82dd2260…c012` byte-exact 晋级为
  `assets/source/actionbars/ab-trinket-kit/ActionTrinketKit_Master_v1.png`；Consumable
  attempt 1 canonical 以 SHA `623f29c5…a2419` byte-exact 晋级为
  `assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png`。
- P4 记录：两个独立 SourceManifest 均固定 `1024×1024 RGBA`、Alpha 统计、四个
  `512²` cell 的 visible bbox／`80 px` minimum margin、raw／canonical／review／
  display provenance、Character V3 权威边界与用户原文。source 与 accepted
  canonical 哈希逐字节一致，没有从 preview／simulation 取材。
- 预算／handoff／runtime：Trinket 循环终止于 `4/5`、Consumable 终止于 `1/5`；
  未用次数不再执行。没有 handoff 可消费；没有切片、TGA、Lua／XML／TOC、adapter、
  AutoBar 启用、profile 应用或 TrinketMenu SavedVariables 变更。当前终态为
  `dual-source-accepted / P4`。

## 审查记录

- 语义／物理：pass；二十四个主 Button 表达二十四个类别入口，实际物品继续在
  AutoBar popup 中出现，三组装饰不冒充 Button。
- 透视／图层：pass；卷袋／分隔在底，口袋在上，provider 图标／文字／冷却最高；
  标题皮签位于命中盒外。
- 美术一致性：pass for user review；暖褐炼金卷袋、深皮饰品护套与克制暗黄铜
  关系成立，三组不使用现代彩色 Dashboard 编码。
- 对象／状态合同：pass；布局 `72/72`、display `16/16`、violations `0`；
  AutoBar disabled 与 TrinketMenu enabled 状态均保持。
- 结论：`dual-source-accepted / P4`。Trinket attempt 4 与 Consumable attempt 1
  都已完成 Prompt／传输、语义、物理、透视、美术、对象、装配、真实排版和技术
  像素全量复核，并由用户在 `2026-08-09` 以原文“接受 AB.TRINKET.KIT.V1 第4稿与
  AB.CONSUMABLE.KIT.V1 第1稿”明确接受。两套 exact canonical 已晋级为 tracked
  source；runtime 仍未发生。
- Trinket attempt 1 语义：pass。四格依次清楚表达已装备护套、较薄候选插页、
  自适应菜单框和可旋转连接扣；没有固定饰品、图标、文字、Queue 或完整场景。
- Trinket attempt 1 美术：fail／可修复。深胡桃皮革与暗黄铜基本继承 Character
  V3，但皮革微划痕过密，B／C 黄铜比例和小尺寸角件偏重；仍在冻结美术包络内。
- Trinket attempt 1 合同／像素：fail。raw 为 `1254² RGB` 且棋盘烘焙、Alpha
  全 `255`；并且归一审查中 A／B／C 最小 margin 仅 `51／63／31 px`。
- Trinket attempt 1 真实排版：pass for geometry。当前水平双槽、竖向双槽、
  候选 `0／1／8／30`、自动五列、水平菜单和合法三十列均能保持 hit box、图标、
  冷却与 Queue 层序；display `16/16`、violations `0`。因 raw 硬失败，整体结论
  仍为 fail，不得晋级。
- Trinket attempt 2 语义：partial fail。A／B／D 身份清楚，B 比 A 更轻，D 可旋转；
  C 退化为空心边框，没有 prompt 要求的 matte stretchable center。
- Trinket attempt 2 美术：pass for repair direction。相比 attempt 1，微划痕和
  黄铜明显收敛，A／B 层级更清楚，小尺寸角件不再形成大金属块。
- Trinket attempt 2 合同／像素：fail。raw 仍为 `1254² RGB`、Alpha 全 `255`、
  棋盘烘焙；A／C 归一最小 margin `71／42 px`，未达到 `80 px`。
- Trinket attempt 2 真实排版：pass for geometry。与 attempt 1 相同的 16 个
  provider 场景均 pass、violations `0`；C 为空心使单候选菜单暴露屏幕背景，
  因此不能仅凭 display 几何晋级。
- Trinket attempt 3 Prompt／传输：partial pass。完整 `r2`、唯一 Character V3
  Image 1、四格身份与纯绿色 raw 合同均正确传输；provider 返回 countable 单图，
  本地 canonical 为 exact `1024² RGBA`，visible green、透明 RGB 和最终 `80 px`
  margin 均 pass。
- Trinket attempt 3 语义／scope：fatal fail。A／B／C／D 的目标身份可读，C 也已
  恢复连续 matte center；但 raw 中 C 的完整物件越过垂直 cell 中线，D cell 同时
  包含 C 边条和连接扣两个显著组件。该原始对象污染不能由授权的逐 cell fit 隐藏。
- Trinket attempt 3 美术：repair direction pass，最终候选 fail。A 仍有偏大的上部
  keeper 与侧板，B 有偏大的黄铜角件，C／D 的角板、铆钉及皮革压纹在实际小尺寸
  下仍偏重、偏 PBR；这些问题可在既定 Character V3 包络内通过减少金属和微纹理
  修复，不改变四对象身份。
- Trinket attempt 3 技术／真实排版：canonical 技术项除原始 cell 隔离和单显著
  组件外均 pass；因 scope 已在 checklist 首个致命层失败，按工作流停止审查，
  不生成 reviewer／display 候选，也不以 canonical 后的强制居中 margin 冒充通过。
  整体结论为 internal fail、`3/5`；不得晋级 source／runtime。
- Trinket attempt 4 Prompt／传输：pass。完整 `r3`、唯一 Character V3 Image 1、
  四格身份及纯绿色 raw 合同均正确传输；provider cache 与本地 raw 哈希一致。
- Trinket attempt 4 语义／物理／透视：pass。A 是较重的已装备护套，B 是更薄的
  候选插页，C 是有连续 matte center 的非方向九宫格框，D 是短小可旋转连接扣；
  四者正投影、互不污染，没有固定饰品、图标、文字、Queue 或组装场景。
- Trinket attempt 4 美术：pass for user review。深胡桃皮革、烟褐中心与克制暗黄铜
  继承 Character V3；A 的单个上 keeper、B 的单个短 accent、C 的短边缘 trace 与
  D 的窄端头在实际 `29–36 px`／菜单拉伸中保持从属，没有形成质量框、PBR 卡片或
  抢夺主动作条层级的噪声。
- Trinket attempt 4 对象／装配／真实排版：pass。四格各一显著组件且原始物件均不
  触 cell 边界；live icon、cooldown、Queue、数量和 hit box 继续由 provider 所有。
  16 个水平／垂直、`0／1／8／30`、自动五列、横向及三十列场景全部 pass，
  violations `0`。
- Trinket attempt 4 技术：pass。canonical exact `1024² RGBA`、四格 minimum margin
  `80 px`、visible green `0`、透明 RGB `0`、provenance 匹配。用户已接受第 4 稿；
  exact bytes 现为 `source-accepted / P4 / 4/5`，第 5 次未使用且原循环终止。
- Consumable attempt 1 Prompt／传输：pass。完整 transport body、唯一 Character V3
  Image 1、四格身份及纯绿色 raw 合同均正确传输；provider cache 与本地 raw 哈希一致。
- Consumable attempt 1 语义／物理／透视：pass。A 是主类别口袋，B 是更薄更轻的
  popup 口袋，C 是有连续 matte center 的非方向卷袋九宫格，D 是窄小可旋转／拉伸
  连接带；四者正投影、互不污染，没有药瓶、物品、类别文字、固定网格或组装场景。
- Consumable attempt 1 美术：pass for user review。烟褐软皮、稀疏绳结与少量暗黄铜
  继承 Character V3，同时比 Trinket Kit 更软、更轻；A 的单枚小扣、B 的无金属薄边、
  C 的四角小扣和 D 的安静中段在 `29–36 px` 及极端拉伸中保持从属，没有现代卡片
  或抢夺主动作条的噪声。
- Consumable attempt 1 对象／装配／真实排版：pass。四格各一显著组件且原始物件
  均不触 cell 边界；live icon、count、cooldown、分类、popup 与 hit box 继续由
  AutoBar 所有。`1×1／5×2／4×6／24×1／1×24`、TOP 6、RIGHT 12 等场景全部
  pass，violations `0`；当前 provider disabled 状态未改变。
- Consumable attempt 1 技术：pass。canonical exact `1024² RGBA`、四格 minimum
  margin `80 px`、visible green `0`、透明 RGB `0`、provenance 匹配。用户已接受
  第 1 稿；exact bytes 现为 `source-accepted / P4 / 1/5`，第 2–5 次未使用且原循环
  终止。

## 尝试摘要

| 版本 | 证据 | 用户结论 | 下一版必须改变／保持 |
|---|---|---|---|
| `AB-FIELDKIT-SIM-V1` | scene `91a596b9…adce`；states `64a39772…5927`；布局 `60/60`；display `15/15` | `consumable revision-requested 2026-08-08`：“消耗品5*2不够用. 并且能否按照类型进行分组?” | 改为足量类别槽并按类型分组；保留真实 AutoBar popup 与 TrinketMenu 合同 |
| `AB-FIELDKIT-SIM-V2` | scene `9fe4d159…164d`；states `16a90762…f467`；布局 `72/72`；display `16/16` | `confirmed 2026-08-09`：“接受 AB-FIELDKIT-SIM-V2”；只接受文字方向 | 最终正文必须保持八项确认条款、provider 所有权与模拟像素禁用边界 |
| `AB.TRINKET.KIT.V1 attempt 1` | raw `fe4b854e…c9e8d`；review scene `926f23ca…875f`；display `16/16` | internal fail；`1/5` | 保持四对象语义；修复 exact `1024² RGBA`、真 Alpha、每 cell `80 px` margin，并降低微纹理／黄铜噪声 |
| `AB.TRINKET.KIT.V1 attempt 2` | raw `85f3f6f0…50b7`；review scene `c56aa652…6f3c`；display `16/16` | internal fail；`2/5` | 保持 A／B／D 与降噪成果；C 恢复 matte center。绿色键控 raw→canonical RGBA 修订已授权，完整 `r2` 已准备 |
| `AB.TRINKET.KIT.V1 attempt 3` | raw `0c6f0bc7…8048`；canonical `6a91a2b5…5e13`；传输技术项 pass，原始 cell 隔离 fail | internal fail；`3/5` | 保持 C 的 filled matte center 与四对象身份；四物件各自收进本格中央 `68.75%`，绝不越线；进一步压低黄铜板、铆钉和微纹理；完整 `r3` 已准备 |
| `AB.TRINKET.KIT.V1 attempt 4` | raw `2e4efc1a…19e3a`；canonical／source `82dd2260…c012`；review scene `6b59893d…53d5`；display `16/16` | 用户于 `2026-08-09` 接受第 4 稿；`source-accepted / P4 / 4/5` | exact source 与 manifest 已 tracked；原循环结束，第 5 次不执行；runtime 需独立 P4→P5 操作 |
| `AB.CONSUMABLE.KIT.V1 attempt 1` | raw `de25567f…b8ba`；canonical／source `623f29c5…a2419`；review scene `057c45cb…150a`；display `16/16` | 用户于 `2026-08-09` 接受第 1 稿；`source-accepted / P4 / 1/5` | exact source 与 manifest 已 tracked；原循环结束，attempts 2–5 不执行；runtime 需独立 P4→P5 操作 |

## 下一门禁

1. 两套 accepted source／manifest 已进入 `assets/source/actionbars/`，均为
   `source-accepted / P4`。下一步若由用户继续，应分别确定四 cell 的 crop／九宫格／
   UV／rotation／stretch runtime 合同，再执行确定性导出与 adapter 接入；本次接受
   不能越过 P4。
2. P4→P5 必须以最终 atlas／adapter／provider 再跑实际展示区域、Lua／repository
   tests 与 fresh-checkout addon package 门禁；所有游戏加载文件都须进入 tracked
   `addon/`，目标设备不得再构建或打补丁。
3. 两个原生产循环已经结束：Trinket 停在 `4/5`、Consumable 停在 `1/5`，接受后
   ImageGen `0`。未使用预算不继续执行；禁止 attempt 6。
4. runtime 集成仍不得自动启用 AutoBar、擅自应用推荐 profile、改写 AutoBar／
   TrinketMenu SavedVariables，或替代 provider 的按钮、动态图标、冷却、Queue、
   Tooltip、拖动、方向和命中区。
