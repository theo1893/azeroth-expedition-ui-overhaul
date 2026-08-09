# AB.FIELDKIT.V1

## 元数据

- 批次：`AB.FIELDKIT.V1`
- 覆盖逻辑组件：`AB.TRINKET.DOCK`、`AB.TRINKET.SLOT13／14`、
  `AB.TRINKET.MENU`、`AB.CONSUMABLE.RACK`、`AB.CONSUMABLE.POCKET`、
  `AB.CONSUMABLE.POPUP`、`AB.CONSUMABLE.GROUP`
- 模拟版本：`AB-FIELDKIT-SIM-V3`
- 当前操作：`strong Combat Deck binding / game retest`
- 子状态：`runtime-exported / pending-retest`
- 项目阶段：`P5`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 当前状态：`runtime-v1.5 / P5 / pending-retest`。两个 exact canonical 与 TGA
  像素继续由 manifest 固定；runtime-v1.2 已解决线性 popup 遮挡并加入两侧软停靠，
  v1.3 补了卷袋外缘到抽屉的直接子级悬停通道，但实机证明从内侧主格前往右抽屉时
  仍会经过其他主格，其原生 `OnEnter → SetPopupButton` 会立即替换或关闭抽屉。
  v1.4 保留联合悬停区，只在 exact 外置态给不同主格加入 `0.30s` 意图停留；跨格
  离开时保留原抽屉，停留时仍调用捕获的 AutoBar 原方法。原生／签名不匹配／AEUI
  关闭及调度 API 缺失都立即回退；静态回归、display-region 与 fresh-checkout package
  必须重新通过。v1.5 在不改该 guard 的前提下，把 Bar 6、左侧 AutoBar `4×6`
  与右侧 TrinketMenu 双槽直接相对锚到 Bar 1，形成唯一移动根；`unbind` 才恢复
  provider 自由位置，`home` 恢复中心中下基线。P4→v1.5 没有调用 ImageGen
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
- runtime manifest：
  [Trinket](../../../../assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_RuntimeManifest_v1.json)／
  [Consumable](../../../../assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json)
- runtime media：
  [ActionTrinketKitV1.tga](../../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionTrinketKitV1.tga)／
  [ActionConsumableKitV1.tga](../../../../addon/AzerothExpeditionUI/Media/ActionBars/ActionConsumableKitV1.tga)
- 目标：Turtle WoW `1.18.1`，Interface `11200`，`1920×1080`，
  UI Scale `0.81269841269841`

## 当前设备事实与 provider 审计

### 启用状态

- P2 审计时当前角色的 `AddOns.txt` 为 TrinketMenu `enabled`、AutoBar `disabled`；
  用户随后为 P6 检查自行启用 AutoBar，`2026-08-09` 实机截图已证明 provider
  加载并显示。AEUI 从未自动启用它。
- 两个插件均已安装；普通 adapter 刷新不得替用户启用 AutoBar。只有用户主动
  输入 `/aeui autobar apply／restore` 时才允许当前角色 profile 的可逆写入。
- 当前“大奶黑牛 - Basin of Stars”角色 profile 已由用户显式应用为 `4×6／24`、
  `36×36 UI`、gap `3 UI` 与三组推荐类别；`_SHARED1` 的旧 `1×24` 只保留为未激活
  provider 配置。AEUI 普通刷新不重写该 profile。
- 当前 TrinketMenu 保存为主栏水平、主栏 scale
  `0.9043710231781006`、菜单垂直、菜单 scale `1`、固定 `4` 列、菜单停靠主栏
  右侧且底部对齐、`KeepDocked=ON`、`KeepOpen=OFF`、`MenuOnShift=OFF`、
  `Locked=OFF`、大号冷却数字开启、快捷键文字关闭。
- 用户要求按最初构图重排后，目标角色保存为 `pfActionBarMain x=0／y=258／scale=1.2`、
  `pfActionBarTop x=0／y=291／scale=1.2`；AEUI 保存 `fieldKitBound=true`，TrinketMenu
  `MainOrient=HORIZONTAL`，候选仍从主栏右侧向外展开。
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
- TrinketMenu 缺失或未加载时不创建 Button／占位栏；原生装备槽 fallback 若以后
  需要，须另立功能合同，不仿造三十项菜单、Queue 或战斗换装。

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
8. P2 确认时 AutoBar 未启用；AEUI 永不自动启用。只有用户主动执行
   `/aeui autobar apply` 时才写当前角色 `4×6` 分组 profile，并提供 restore。

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
  该 `accept` 操作的终态为 `dual-source-accepted / P4`。
- 日期：`2026-08-09`
- 操作：用户回复“下一步”，以独立授权执行两个 accepted kit 的 P4→P5；调用
  `tools/build_action_fieldkit_v1_runtime.py`，不调用 ImageGen。执行解释器为
  `D:\Softwares\miniconda3\python.exe`（Python `3.13.5`）。
- 确定性转换：每张 source 的四个 `512²` cell 只取完整 visible bbox。A／B／C
  在 premultiplied-alpha 空间各做一次 LANCZOS 等比缩小；细 D 为避免 straight
  LANCZOS 在 Alpha `1` 产生绿色 overshoot，统一做一次 premultiplied-alpha
  HAMMING 等比缩小，并生成一份确定性 `90°` 旋转副本。只清零 Alpha `0` 下的
  RGB；不重绘、不删除可见像素、不镜像、不重着色。exporter SHA
  `40ef49cc…5484`。
- Trinket runtime：`ActionTrinketKitV1.tga`，`512² RGBA / 32-bit`，文件 SHA
  `3614d9a8…f455`、像素 SHA `0961d750…aef`、visible bbox
  `[8,8,504,390)`、visible green `0`、透明 RGB 非零值 `0`。A／B／C／D-H／D-V
  盒为 `[9,8,119,120)`、`[136,8,248,119)`、`[8,138,264,390)`、
  `[264,23,504,104)`、`[407,144,488,384)`；C source cap `45 px`、destination
  cap `6 UI`，D source cap `30 px`。
- Consumable runtime：`ActionConsumableKitV1.tga`，`512² RGBA / 32-bit`，
  文件 SHA `c48f6292…320e`、像素 SHA `658f826f…e30d`、visible bbox
  `[8,9,504,392)`、visible green `0`、透明 RGB 非零值 `0`。A／B／C／D-H／D-V
  盒为 `[8,10,120,118)`、`[136,9,248,119)`、`[8,136,264,392)`、
  `[264,43,504,84)`、`[427,144,468,384)`；C source cap `46 px`、destination
  cap `6 UI`，D source cap `30 px`。
- adapter：`addon/AzerothExpeditionUI/Modules/ActionBars.lua`，Field Kit runtime
  contract `1.0`。AutoBar 仅在 `AutoBarFrameButton1..24`／
  `AutoBarPopupFrame_Button1..12` 下挂 A／B，C 跟随真实可见 Button 边界，D
  连接 popup 与分组 gap；只有 exact `24 / 4×6 / 推荐 profile` 显示三枚非交互
  标题和两条分隔。TrinketMenu 仅在现有 `2+30` Button 下挂 A／B，菜单 Frame
  使用 C 九宫格，双槽使用 D 横／竖连接；关闭时恢复原生 NormalTexture／backdrop。
- provider 完成态钩子：AutoBar `AutoBar_SetupVisual`、`ButtonsUpdate`、
  `UpdatePopupButtons`；TrinketMenu `OrientWindows`、`BuildMenu`。所有回调只刷新
  AEUI 装饰。没有启用 AutoBar、调用 provider 配置／布局函数、写入 profile 或
  SavedVariables，也没有改 Button Parent／Point／Width／Height／hit rect／script、
  图标、数量、冷却、Queue、Tooltip、换装、拖动、缩放、方向或停靠。
- 最终展示／package：tracked Trinket／Consumable display 合同 SHA 分别为
  `fd2e2c58…791c`／`6bef6214…7dd`，最终 `9/9`／`7/7 pass`、violations `0`；
  real-layout SHA `787bd62e…2b7f`，支持布局板 SHA `d31762a2…6f5`／
  `d6b32ea6…834`。fresh-checkout package 报告 SHA `a6a4ec74…16b9`，
  `status=pass`、violations `0`、`build_required_on_target_device=false`。
- 结论：`runtime-exported / P5`。两个原 ImageGen 循环仍终止于 `4/5` 与 `1/5`，
  P4→P5 ImageGen `0`；下一步只需目标客户端实机门禁，不在目标设备生成或打补丁。
- 日期：`2026-08-09`
- 操作：Turtle WoW 首次 Field Kit 实机门禁失败并执行有界 runtime 修复；不调用
  ImageGen、不修改 accepted source／TGA 像素、不重置生产预算。用户提供 AutoBar
  截图 `633×145 RGB`（SHA `23d81a55…823f`）：多个格子的 Count 仍显示而 Icon
  缺失；随后提供 TrinketMenu 截图 `156×82 RGB`（SHA `67dc3bd8…d887`）：两枚
  已装备槽只显示护套而没有饰品 Icon。两者都保留真实 Button／文字层，首个失败
  门禁为 runtime z-order／content conformance，而不是 provider 物品识别或 source。
- 根因：AutoBar／TrinketMenu 继承的 ActionButtonTemplate Icon 位于 Button 的
  `BACKGROUND` 层；runtime-v1 在同一 Button 上后创建 A／B `BACKGROUND` 纹理，
  因同层创建顺序覆盖动态图标。Count／Queue 等较高层仍可见，和两张实机图一致。
- runtime-v1.1：`ApplyPocket` 不再直接在 Button 上创建纹理；每个 AutoBar
  `24+12` 与 TrinketMenu `2+30` Button 新建一个以该 Button 为父、
  `FrameLevel=button:GetFrameLevel()-1`、`EnableMouse(false)`、随 Button 显隐的
  holder，A／B 只在 holder 的 `BACKGROUND` 绘制。Button Parent／Point／Width／
  Height／script／hit rect、Icon draw layer、Cooldown、Count、Queue 和 Tooltip
  全部未改。`fieldkit-contract` 升为 `1.1`，AEUI 升为 `0.8.1`。
- 配置入口：用户表示不知道如何配置 AutoBar，因此新增显式 opt-in 命令而不在
  普通 adapter 刷新中写配置。`/aeui autobar open` 调原生配置页；
  `/aeui autobar apply` 只对 `AutoBar.currentPlayer` 保存一份 plain-table 备份，
  再应用已确认的 `4×6 / 24 / 36 UI / gap 3`、三组类别与向左 popup；槽 `16`
  已存在的纯数字手动物品 ID 会保留。`/aeui autobar restore` 原子恢复应用前副本。
  命令不启用 AutoBar、不改 shared／其他角色 profile、不写 TrinketMenu
  SavedVariables；失败会回滚当前角色配置。
- 静态门禁：accepted source SHA、runtime TGA 文件／像素 SHA 均不变；最终
  display 仍为 Trinket `9/9`、Consumable `7/7`、violations `0`，fresh-checkout
  package `pass`。Lua smoke 新增四类 pocket holder 层序、显式 apply／backup／
  restore 与不改 provider 几何断言。runtime/source/repository 合同同步为
  `pending-retest / P5`；旧 P6 失败不晋级，也不执行 Trinket attempt 5 或
  Consumable attempts 2–5。
- 日期：`2026-08-09`
- 操作：用户确认“CD没问题. 距离红没问题. 按下反馈没问题，动作条功能验证通过”
  后继续检查 Field Kit；runtime-v1.1 的 AutoBar／TrinketMenu Icon 层序已通过。
  用户随后提供 `376×427 RGB` AutoBar popup 截图（SHA `4d29a262…e942`），指出
  原生向左线性展开跨过并拦住部分主格，并明确授权修改；同时要求考虑让最初设计在
  动作条左右两侧的消耗品袋与饰品袋都支持吸附。
- runtime-v1.2 popup：不修改外部 AutoBar 文件。只有 exact `24 Button / 4×6 /
  推荐 profile` 使用 AEUI 外置抽屉；候选 `1–6` 为一列，`7–12` 为列优先两列、
  最多六行，整组位于卷袋之外且不穿过主格。`AUTO` 在卷袋确实处于左侧吸附态时
  向左，在自由浮动时按屏幕左右余量选择；另有 `LEFT／RIGHT／NATIVE` 显式模式。
  非 exact profile 与 `NATIVE` 都恢复 AutoBar 本次更新刚写入的原生 Point／hit rect。
  抽屉只复用 accepted B 候选口袋与 D 竖向 spine；物品顺序、图标、数量、冷却、
  点击、Tooltip、悬停关闭和最多十二个真实 Button 均继续归 provider。
- runtime-v1.2 soft dock：消耗品卷袋默认以视觉右缘在主动作条左侧 `48 UI`、底边
  对齐；饰品双槽默认在主动作条右侧 `16 UI`、底边对齐。两侧阈值均为 `32 UI`，
  每次 provider 拖拽结束独立判断：拖离只释放该侧，靠近再吸附。没有维护循环；只在
  AEUI Apply、provider 布局钩子与 UI scale refresh 重算。AEUI SavedVariables 只保存
  `consumableDocked／trinketDocked`，不由 adapter 写 AutoBar／TrinketMenu 的 provider
  配置。`/aeui fieldkit dock|undock|status` 统一控制两侧，`/aeui autobar popup
  auto|left|right|native` 控制抽屉方向。
- runtime-v1.2 门禁：新增 `AB-FIELDKIT-SIM-V3`，scene SHA `e1027ca9…4e58`、
  provider-states SHA `5a7e528b…4a74`，布局 `89/89`、display `19/19`、violations
  `0`。exporter SHA `1c46278d…7a29`、adapter SHA `0f28c09f…0615`。accepted
  runtime display 为 Trinket `9/9` 与 Consumable `10/10`，violations
  `0`；fresh-checkout package 报告 SHA `a6a4ec74…16b9`、`status=pass`、目标设备
  无需构建。source／TGA 文件与像素 SHA 完全不变，P4→v1.2 ImageGen `0`；当前仍为
  `runtime-exported / P5 / pending-retest`。
- 日期：`2026-08-09`
- 操作：用户提供 `416×415 RGB` AutoBar 外置右抽屉截图（SHA
  `be080504…f1ee3`），确认抽屉位置与内容已出现，但“鼠标移不到右侧弹出栏，弹出
  就消失了”。该实机交互失败使 runtime-v1.2 保持 P5，不得晋级。
- 根因：AutoBar `1.31` 的 `UpdatePopupButtons` 每秒运行 `PopupMouseover`，只把
  `GetMouseFocus():GetParent()` 等于 `AutoBarFrame` 或 `AutoBarPopupFrame` 视为仍在
  popup 内；XML 的 `AutoBarPopupFrame OnLeave` 还会直接隐藏 Frame。外置抽屉 Button
  本身仍是合法直接子级，但卷袋与抽屉之间的空隙不属于这两个 parent，计时器可能在
  鼠标穿越的任一采样点关闭 popup。
- runtime-v1.3：不修改外部 AutoBar 文件，不替换 Button／物品／点击逻辑。外置态
  创建一个透明、`EnableMouse(true)`、直接以 `AutoBarPopupFrame` 为 parent 的通道；
  右侧宽 `10 UI`，分组左侧连同标题净空宽 `52 UI`，垂直覆盖完整卷袋外壳，因此
  从任一主格向抽屉移动时 provider 原计时器始终识别为合法 parent。只在外置态把
  XML Frame `OnLeave` 延后为空操作，关闭仍由 AutoBar 原 `PopupMouseover`／Shift
  计时器负责；`NATIVE`、签名不匹配与 AEUI 关闭都会隐藏通道并恢复捕获的原脚本。
  accepted source、TGA、抽屉可见几何、Icon／Count／Cooldown／Tooltip 与 soft dock
  均未改变；无需新模拟图或 ImageGen。
- runtime-v1.3 门禁：adapter SHA `401e5d88…a250c`，exporter SHA
  `67501b1a…1e1ba`。Lua smoke 明确覆盖左侧 `52 UI`／右侧 `10 UI` 通道、provider
  直接 parent 判定、候选 `1／6／7／12`、外置态延后 `OnLeave`，以及 NATIVE、签名
  不匹配和 AEUI 关闭时恢复原脚本／隐藏通道。原 simulation `89/89`、display
  `19/19` 与 runtime display Trinket `9/9`／Consumable `10/10` 全部 pass、
  violations `0`；fresh-checkout package 报告 SHA `a6a4ec74…16b9`，`status=pass`、
  `build_required_on_target_device=false`。source 与两张 TGA 文件／像素 SHA 不变，
  本次外部生成 `0`。
- 日期：`2026-08-09`
- 操作：用户在 runtime-v1.3 实机复测后明确反馈：“鼠标一旦移动到别的格子上，
  弹出栏就消失了。现在这种设计有很大问题”。该结果否定了“只覆盖卷袋外缘空隙
  即可完成穿越”的交互假设，runtime-v1.3 保持失败记录且不得晋级。
- 根因补充：推荐布局每行有四个 AutoBar 主格。由内侧格前往右抽屉时，鼠标会在
  到达外缘透明通道前进入同一行其他主格；每个主格 XML `OnEnter` 都先设置 Tooltip，
  再立即调用 `AutoBar:SetPopupButton(this)`。目标格无多候选时原方法隐藏 popup，有
  多候选时则替换 active base，因此 provider 的 `PopupMouseover` 即使仍判定鼠标位于
  `AutoBarFrame` 内，也无法阻止抽屉被主动关闭／切换。
- runtime-v1.4：把卷袋主格、透明通道与外置候选视为一个联合悬停区域，但不在主格
  上叠加拦截鼠标的透明 Frame。AEUI 捕获一次 AutoBar 原 `SetPopupButton`，只在 exact
  外置抽屉已显示、鼠标进入“不同主格”时用 provider 自带 AceEvent 安排一次
  `0.30s` 意图提交；进入下一主格会重置意图，进入透明通道／候选则到期丢弃并保持
  原抽屉，持续停在目标主格才调用捕获的原方法。相同 active base、NATIVE、profile
  签名不匹配、AEUI 关闭、非鼠标调用、Frame 已隐藏或 `ScheduleEvent`／
  `CancelScheduledEvent` 缺失都立即委托原方法。没有 `OnUpdate` 维护循环，不替换
  Button script、候选顺序、物品使用、Shift、关闭计时器或 SavedVariables。
- runtime-v1.4 门禁：Lua smoke 新增“主格 2→主格 3→通道”跨格保持、在主格 4
  停留后通过 AutoBar 原方法切换，以及 NATIVE／非 exact 立即委托；既有左右通道、
  `1／6／7／12`、Frame `OnLeave` 恢复、两侧吸附和 provider fail-open 回归继续保留。
  adapter SHA `387df4b8…0519`，exporter SHA `19b6dd78…ca28`；display-region
  Trinket `9/9`／Consumable `10/10`、violations `0`，报告 SHA
  `b6c827f7…b114`／`070673f1…ba2d`；fresh-checkout package SHA
  `a6a4ec74…16b9`、`status=pass`、目标设备无需构建。accepted source、两张 TGA
  与全部可见布局像素不变；P4→v1.4 ImageGen `0`。
- 日期：`2026-08-09`
- 操作：用户提供“大奶黑牛”完整 UI 截图并要求“现在把动作条 + 消耗品栏 +
  饰品栏，强绑定……按照最初的设计进行重排”。截图中主动作条贴近底边，AutoBar
  `4×6` 漂在人物右上，TrinketMenu 垂直双槽则与主栏右端断开。
- 根因：`AzerothExpeditionUIDB.actionbars.consumableDocked／trinketDocked` 都保存为
  `false`；pfUI 主栏仍为 `x=-31／y=35`、上栏 `x=-31／y=68`；TrinketMenu 保存为
  `VERTICAL`。旧 v1.2 允许两边各自拖离，无法保证三者长期保持同一构图。
- runtime-v1.5：引入唯一 `fieldKitBound`。绑定态把 Bar 6 的 `BOTTOM` 相对锚到
  Bar 1 `TOP`，并从 pfUI movable 注册中暂时移除 Bar 6；AutoBar 外壳右缘与 Bar 1
  左缘保持 `48 UI`，TrinketMenu 左缘与 Bar 1 右缘保持 `16 UI`，三者底边对齐。
  侧 provider 拖动完成后只重施相对锚点，不写独立吸附状态；移动 Bar 1 时其余对象
  因直接相对锚定自然跟随。`unbind` 恢复捕获的 Bar 6／provider 原位置和独立 mover；
  `home` 把 Bar 1 居中并写入屏幕高度 `210/1080` 的底部净空。所有写入均为初始化、
  provider 布局回调、拖动结束或显式命令，不使用 `OnUpdate`。
- runtime-v1.5 初始角色迁移：游戏未运行时将“大奶黑牛”主栏保存为 `x=0／y=258`、上栏
  `x=0／y=291`，TrinketMenu 改为 `HORIZONTAL`，AEUI 设置
  `fieldKitBound=true／combatDeckLayoutVersion=1`。这只落实用户指定角色的最初构图，
  runtime 不自动覆盖其他角色的 TrinketMenu 方向或 AutoBar profile。
- runtime-v1.5 门禁：AEUI `0.8.5`，adapter SHA `a49c34d1…047f`；Lua smoke 覆盖
  `12×2` 相对锚、唯一 mover、bind／unbind／home、两侧误拖回位、旧 v1.4 popup
  guard 与 provider fail-open。Trinket／Consumable display `9/9`、`10/10`，violations
  `0`；fresh-checkout package `pass`。TGA 文件／像素 SHA 仍为
  `3614d9a8…f455／0961d750…aef` 与 `c48f6292…320e／658f826f…e30d`；ImageGen `0`。
- 后续共享位置层修订把 addon 升到 AEUI `0.8.6`，当时 `ActionBars.lua` adapter
  SHA 为 `379962c1…9e3798`。该修订只增加显式 Combat Focus 一次性 preset，未改变
  `fieldkit-contract=1.5`、v1.4 popup guard、Field Kit 几何、provider 行为、source
  或 TGA；四份 runtime manifest 当时已同步 adapter／bootstrap／TOC 哈希。
- `2560×1440` 实机截图暴露 `1920×1080` 输出与 pfUI tier 7 叠加后的整体偏大。
  AEUI `0.8.7` 的共享 adapter SHA `474848c5…c35ff3` 增加显式 comfort tier 8，
  当前角色主／副栏保存坐标按新 UIParent 更新为 `y=295／328`；TrinketMenu
  `MainScale` 从 `0.904371` 归一为 `1.0`，抵消全局缩小后饰品槽过小。强绑定、
  `48／16 UI` 间距、popup guard、source／TGA 像素及 provider 行为均不变。
- 上述 v1.1 方案的第二张 `2560×1440` 实机截图 `3a726e58…678f0` 判定为 fail：
  玩家框蓝色主体实测 `374×114 px`，仍覆盖左卷袋上部。原因是 tier 8 虽在
  `1920×1080` client buffer 内达到 pixel-perfect，最终输出仍被显示链放大
  `4/3`；共享 adapter 又用 scale-dependent UIParent 虚拟尺寸推导战斗框架锚点。
  AEUI `0.8.8` 的共享 adapter SHA `094a32e6…bff3a9` 保留 tier 8，只给
  Player／Target、双方施法条、Swing、姿态与 DoiteDPS 使用 `0.75` local display
  compensation，并改用目标显示固定坐标。投影后玩家框约 `280 px` 宽、两框
  内缘约 `80 px`、左卷袋与玩家框约 `3 px` 净空。Combat Deck、Field Kit
  几何／美术、TrinketMenu `MainScale=1.0`、强绑定、popup guard、source／TGA
  像素及 provider 行为均不变；本次 ImageGen `0`。
- 用户接受 `ACTION-BARS-CORE-SIM-V4` 后，AEUI `0.8.9`／
  `fieldkit-contract=1.6` 把已审计的 ArchiTotem `1.7` 根加入同一
  `fieldKitBound`。AutoBar／TrinketMenu 的 runtime-v1.5 atlas、几何、popup guard
  与 manifest 身份不变；新桥只在萨满、真实 provider 可见且签名匹配时把根锚到
  Bar 1 下方，拖动松手回位，`unbind` 恢复首次自由锚点。普通 refresh 不写
  provider 方向，显式 focus preset 才请求 `down`；ImageGen `0`。
- V4 战斗栈随后被新实机截图否决，但上述 Field Kit／ArchiTotem bridge 本身未改。
  用户已明确“确认接入” V5；AEUI `0.8.10`／focus runtime-v1.4 的实机坐标传输
  随后失败；AEUI `0.8.11`／focus runtime-v1.5 的物理屏幕投影、探针与回读又被
  下一张实机截图判定失败。当前 AEUI `0.8.12`／`focus-layout-contract=1.6` 改用
  固定游戏原生坐标；Field Kit atlas、bridge-v1.6 几何、popup guard、Bar 1 绑定
  和 provider 行为继续不变，ImageGen `0/0`。

## 审查记录

- 语义／物理：pass；二十四个主 Button 表达二十四个类别入口，实际物品继续在
  AutoBar popup 中出现，三组装饰不冒充 Button。
- 透视／图层：pass；卷袋／分隔在底，口袋在上，provider 图标／文字／冷却最高；
  标题皮签位于命中盒外。
- 美术一致性：pass for user review；暖褐炼金卷袋、深皮饰品护套与克制暗黄铜
  关系成立，三组不使用现代彩色 Dashboard 编码。
- 对象／状态合同：pass；布局 `72/72`、display `16/16`、violations `0`；
  AutoBar disabled 与 TrinketMenu enabled 状态均保持。
- 结论：`runtime-v1.5 / runtime-exported / P5 / pending-retest`。Trinket attempt 4 与
  Consumable attempt 1
  的 Prompt／传输、语义、物理、透视、美术、对象、装配、真实排版和技术像素
  结论不变；两套 exact canonical 仍是唯一 source。新增 deterministic runtime
  转换、atlas sampling、实际 provider bridge、静态回归与 fresh-checkout package
  已通过；P4→runtime-v1.2 没有新增 ImageGen。首次 Turtle WoW 检查证明
  runtime-v1 的同层装饰遮挡 Icon；v1.1 层序修复已实机通过。随后发现的左向线性
  popup 遮挡由 v1.2 外置抽屉修复，两侧软吸附也在同一有界布局合同内加入；v1.3
  只覆盖外缘空隙，实机因穿越其他主格而失败；v1.4 以不挡主格的短停留意图区分
  “路过”与“换类”；v1.5 再按用户指定把软吸附收敛为主动作条唯一根的强绑定，
  不改变 v1.4 交互或 accepted art。当前仍待实机复测，因此不标记 P6。
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
| `AB.TRINKET.KIT.V1 attempt 4` | raw `2e4efc1a…19e3a`；canonical／source `82dd2260…c012`；review scene `6b59893d…53d5`；display `16/16` | 用户于 `2026-08-09` 接受第 4 稿；`source-accepted / P4 / 4/5` | exact source 与 manifest 已 tracked；原循环结束且第 5 次不执行；独立 runtime-v1 已完成 |
| `AB.CONSUMABLE.KIT.V1 attempt 1` | raw `de25567f…b8ba`；canonical／source `623f29c5…a2419`；review scene `057c45cb…150a`；display `16/16` | 用户于 `2026-08-09` 接受第 1 稿；`source-accepted / P4 / 1/5` | exact source 与 manifest 已 tracked；原循环结束且 attempts 2–5 不执行；独立 runtime-v1 已完成 |
| `AB.FIELDKIT.V1 runtime-v1` | TGA `3614d9a8…f455`／`c48f6292…320e`；像素 `0961d750…aef`／`658f826f…e30d`；display `9/9`＋`7/7`；package pass | 用户“下一步”授权后完成；`runtime-exported / P5` | Turtle WoW 分别验证 AutoBar 与 TrinketMenu 全清单；通过前不标记 P6 |
| `AB.FIELDKIT.V1 runtime-v1.1` | source／TGA 像素不变；四类 A／B pocket holder 下移到 Button FrameLevel `-1`；`/aeui autobar open／apply／restore`；display `9/9`＋`7/7`、package pass | 首次实机发现 AutoBar／TrinketMenu Icon 被同层装饰遮挡；层序修复已实机通过，随后发现原生左向 popup 遮挡主格 | 由 runtime-v1.2 外置抽屉接续，不回退 accepted art 或层序修复 |
| `AB.FIELDKIT.V1 runtime-v1.2` | source／TGA 像素不变；exact `4×6` 外置 `1×1–6／2×4–6` popup drawer；消耗品左／饰品右软吸附；simulation `89/89`、display `19/19`，runtime display `9/9`＋`10/10`、package pass | 用户授权修改 popup 并要求同时考虑两袋吸附；静态门禁通过，`pending-retest / P5` | `/reload` 验证抽屉不遮主格、左右／AUTO／NATIVE、双侧拖离／回吸附与 provider 行为保持 |
| `AB.FIELDKIT.V1 runtime-v1.3` | source／TGA／可见布局不变；外置态增加全卷袋高度的透明直接子级悬停通道，延后 XML Frame `OnLeave`，所有原生回退恢复脚本与隐藏通道 | runtime-v1.2 实机截图确认外缘空隙会提前关闭；用户复测确认穿越其他主格仍触发立即关闭／换类，`game-failed / P5` | 由 runtime-v1.4 接续；保留失败根因，不把透明通道误记为完整修复 |
| `AB.FIELDKIT.V1 runtime-v1.4` | source／TGA／可见布局不变；exact 外置态捕获 AutoBar 原 `SetPopupButton`，不同主格仅在持续停留 `0.30s` 后通过原方法提交；跨格进入通道／候选保持当前抽屉，NATIVE／非 exact／关闭态立即委托 | 用户明确否定 v1.3；跨格保持／停留切换／三类立即回退 smoke，display 与 package 重新通过，`pending-retest / P5` | `/reload` 从内侧格横穿其他主格进入左右抽屉，确认不关闭／不换类；在另一主格停留约 `0.30s` 应切换，完全离开联合区域后正常关闭 |
| `AB.FIELDKIT.V1 runtime-v1.5` | source／TGA／v1.4 popup guard 不变；`fieldKitBound` 把 Bar 6、左 `4×6` 卷袋和右双槽直接锚到 Bar 1；提供 bind／unbind／home，绑定态侧栏误拖松手回位；当前角色写入中心中下与水平双槽 | 用户明确要求三部分强绑定并按最初构图重排；smoke、display `9/9＋10/10`、package pass，`pending-retest / P5` | 启动或 `/reload` 验证左卷袋—中央 `12×2`—右双槽、唯一主栏 mover、显式释放／恢复、外向候选及全部 provider 行为 |
| `AB.FIELDKIT bridge-v1.6` | runtime-v1.5 source／TGA／AutoBar／TrinketMenu 合同不变；可选 ArchiTotem 根加入 Bar 1 唯一 mover，绑定态在主栏下方，拖动回位，`unbind` 恢复；显式 focus preset 请求向下，普通 refresh 只读 | V4 几何被否决但 bridge 保留；focus runtime-v1.4／v1.5 坐标传输均已实机失败，bridge 本身未变；AEUI `0.8.12`／focus runtime-v1.6 只改游戏原生坐标，`pending-game-validation / P5` | 实机验证四元素施放、右键、Air 七层、Recall、拖动／锁定、向下 popup、bind／unbind 及非萨满／缺失 fail-open |

## 下一门禁

1. 两套 accepted source 与 runtime TGA 像素身份不变；视觉 source／runtime
   manifest 保持 `runtime-v1.5`，共享 adapter 已更新到 bridge v1.6／P5。fresh-checkout package
   已通过，目标设备只需拉取并安装 `addon/`，不得再生成、导出或打补丁。
2. Turtle WoW 启动或 `/reload` 后确认 `/aeui status` 含 `version 0.8.12`、
   `fieldkit-contract=1.6`、`fieldkit-binding=bound` 与 `actionbar-stack=12x2-bound`。
   同时确认 `focus-layout-contract=1.6`、`focus-layout-anchor=ui-parent`、
   `focus-layout-coordinate-space=game-native-v1`、
   `focus-layout-unit-scale=0.75`、`focus-layout-readout-scale=0.82`、
   `focus-ui-scale-tier=8`、`architotem-dock=bottom` 与
   `architotem-direction=down`；左卷袋与右双槽维持当前清晰尺寸，
   TrinketMenu 双槽不会因旧 `0.904371` 再次被二次缩小，玩家框不再覆盖卷袋。
   先确认左 `4×6` 卷袋—中央 `12×2` 动作条—右水平双槽在中心中下部共用一个
   Bar 1 mover；拖动两侧 provider 松手应回位，`unbind` 后才独立，`bind` 恢复，
   `home` 重置最初位置；若需撤销 Combat Focus，使用 `/aeui focuslayout restore`
   后 `/reload`。再确认
   AutoBar 主格／popup 的 Item Icon 与 Count、TrinketMenu 双槽／候选的 Icon、
   Cooldown 与 Queue 都在口袋／护套之上。再执行 `/aeui autobar apply` 验证当前
   角色精确 `4×6`／24 格、“应急／增益／工具”和手动数字槽保留；打开候选数
   `1／6／7／12` 的分类，确认外置抽屉分别为单列／双列且不遮挡任何主格；从内侧
   分类打开抽屉后横穿同一行其他主格进入左右抽屉，路过格不得关闭或替换原抽屉；
   在另一分类主格持续停留约 `0.30s` 应切换到该类，移出主格、通道与候选后应由
   provider 正常关闭。
   `/aeui autobar popup auto|left|right|native` 应正确切换向外／强制方向／原生回退；
   执行 `/aeui autobar restore` 验证应用前配置可恢复。随后继续验证任一签名
   不匹配回退、TOP／BOTTOM／LEFT／RIGHT popup、使用、拖动／缩放／显隐，以及
   TrinketMenu 水平／垂直、候选 `0／1／8／30`、自动／手动列数、左右键换槽、
   Queue、Tooltip、方向和八向停靠。
3. `/aeui actionbars` 关闭后应恢复 TrinketMenu 原生 NormalTexture／backdrop，并让
   AutoBar 原生视觉 fail-open；provider 缺失或隐藏时不得出现占位栏。实机全部通过
   后方可记录 P6；截图静态层级与用户交互确认仍须分开取证。
4. 默认确认消耗品卷袋在主栏左侧 `48 UI`、饰品双槽在主栏右侧 `16 UI` 且底边
   对齐。Bar 6 应紧邻 Bar 1 上缘并不再显示独立 pfUI mover；两侧拖离松手即回位，
   不是距离阈值吸附。`status` 应报告 `fieldkit-binding=bound`、两侧方向与 stack；
   重载与 UI scale 变化后整体仍跟随主动作条，不得出现逐帧维护或拖动中的抢位。
5. 两个原生产循环保持 Trinket `4/5`、Consumable `1/5`；P4→runtime-v1.5
   ImageGen `0`，未使用预算不继续执行，禁止 attempt 6。后续实机门禁仍不得由
   AEUI 自动启用 AutoBar、在普通刷新中应用 profile、修改 TrinketMenu
   SavedVariables 或替代 provider 动态层与行为；只有用户主动输入 apply／restore
   命令时才允许当前角色 AutoBar profile 的可逆写入。
