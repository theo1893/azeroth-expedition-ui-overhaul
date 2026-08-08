# AB.FIELDKIT.V1

## 元数据

- 批次：`AB.FIELDKIT.V1`
- 覆盖逻辑组件：`AB.TRINKET.DOCK`、`AB.TRINKET.SLOT13／14`、
  `AB.TRINKET.MENU`、`AB.CONSUMABLE.RACK`、`AB.CONSUMABLE.POCKET`、
  `AB.CONSUMABLE.POPUP`
- 模拟版本：`AB-FIELDKIT-SIM-V1`
- 当前操作：`simulate`
- 当前状态：`simulation-reviewed / P2`；等待用户方向结论
- 当前生产候选：无
- 模拟 ImageGen：`0/0`
- 生产执行体：`AB.TRINKET.KIT.V1` 与 `AB.CONSUMABLE.KIT.V1`，均为
  `production-draft / not-authorized / not-executed`
- 后续实际生成／修复预算：每个独立执行体最多 `5` 次，最坏合计 `10` 次；
  尚未授权
- 外部上传：本阶段 `0`；既有 `AB.SLOT.BASE.V1` 的 Image 1 上传授权不得复用
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

### AutoBar 真实对象与行为

- 来源：目标设备 `Interface/AddOns/AutoBar/AutoBar.xml` 与 `Core.lua`，版本
  `1.31`。
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
- 推荐 `5×2` 的可见按钮簇为 `192×75 UI`，加入四周 `6 UI` 装饰余量后为
  `204×87 UI`；`24×1` 与 `1×24` 外壳均为 `945×48 UI`。
- `AutoBarPopupFrame` XML 初始 `72×72 UI` 不是弹出链边界。V1 不生成固定整张
  popup 背景；每个真实 popup Button 复用独立薄口袋，并在 `3 UI` 间隙使用
  可旋转短皮带连接。
- 类别、物品选择、背包槽、数量、冷却、可用性、Shift popup、拖动、锁定、
  docking 与 SavedVariables 全归 AutoBar。当前插件禁用时 V1 不创建替代栏。

## 组件合同

### 共同布局

- 默认行为：尊重两插件现有位置、scale、方向、显隐和 SavedVariables。
- 可选一次性“战斗甲板”preset：消费品外壳位于主动作栏左侧，饰品双槽位于
  右侧；两者与主栏物理间距各 `16 px`，底边共同为 `y=870 px`。
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
  Button 尺寸及 provider scale；推荐实例仍为 `5×2 / 36 UI / gap 3 UI`。
- popup 复用薄口袋与短连接带，不使用固定大面板；支持上下左右和 `1–12` 个
  provider Button。
- 当前 AutoBar 为 disabled，因此 runtime adapter 即使以后存在，也只能在
  `AutoBarFrame` 已存在且插件已自行加载／显示时换肤；不得自动启用。
- AutoBar 缺失／禁用时 V1 显示为空。AEUI 钉选物品 fallback 属于以后独立的
  功能合同，不在本批次凭物品名称猜测分类。

### 动态与禁止烘焙

- 禁止：物品／饰品图标、名字、类别文字、快捷键、数量、冷却数字、扇形冷却、
  排队图标、齿轮、装备品质色、Tooltip、L／R 标签和真实 Button 状态。
- 禁止：珠宝柜、发光宝石底座、固定饰品、固定药瓶、现代玻璃卡片、霓虹外发光、
  宽品质框、厚石台、固定十格或十二格背景。
- z-order：自适应外沿／连接带在底；独立口袋／护套在其上；provider 图标与
  文字再上；Cooldown／Checked／Highlight／Queue／Tooltip 最高。
- Alpha：每个 atlas cell 外全透明；不得以纯绿色键控代替 Alpha，不得跨 cell
  连通，不得让装饰进入 Button hit-safe 区。

## 美术继承与冲突审计

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
- `AB-FIELDKIT-SIM-V1` 的所有像素、图标、折线、缝线和颜色块均非生产输入。

### 冲突结论

- Character V3 的“经典装备槽”身份与本批次真实插件几何冲突时，以 provider
  的 `36×36` Button、`92×52／52×92` Frame 和菜单公式为物理权威，只继承
  材料 DNA。
- AutoBar `AutoBarFrame` 边界与真实 Button 边界不一致时，以 Button 的真实
  可见／命中边界为外壳计算依据。
- 先前概念图的“固定十类消费品”和“两个静态饰品格”只保留推荐布局语义；
  实际类别、候选数和方向始终由 provider 决定。

## 生成前本地模拟

### 文件与命令

- renderer：`tools/render_action_fieldkit_simulation.py`，SHA-256
  `02cd0af0…f4ed`
- specification：`tools/specs/action_fieldkit_v1_simulation.json`，SHA-256
  `d6b7ceab…6978`
- display contract：`tools/specs/action_fieldkit_v1_sim_display_region.json`，
  SHA-256 `0af5aa2d…e800`
- Python：`D:\Softwares\miniconda3\python.exe`，`3.13.5`；Pillow `11.3.0`。
- render：
  `python tools/render_action_fieldkit_simulation.py tools/specs/action_fieldkit_v1_simulation.json --repo-root .`
- display：
  `python .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py tools/specs/action_fieldkit_v1_sim_display_region.json --report generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/simulation/AB-FIELDKIT-SIM-V1/display-region-report.json`
- test：`python tests/action_fieldkit_simulation_test.py`

### 输出与检查

- 战斗场景：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/simulation/AB-FIELDKIT-SIM-V1/AB.FIELDKIT.V1.sim-v1.scene.png`，
  `1920×1080 RGB`，SHA-256 `91a596b9…dce`
- provider 状态板：
  `generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/simulation/AB-FIELDKIT-SIM-V1/AB.FIELDKIT.V1.sim-v1.provider-states.png`，
  `1920×1200 RGB`，SHA-256 `64a39772…927`
- 布局报告：`layout-report.json`，SHA-256 `c6810632…46bd`；
  `60/60 pass`、violations `0`。
- display 报告：`display-region-report.json`，SHA-256 `83b84b74…682a`；
  `15/15 pass`、violations `0`。
- 覆盖：饰品主栏水平／垂直、Queue safe area、候选 `0／1／8／30`、当前
  四列、自动五列、水平菜单、合法三十列；消费品 `1×1／5×2／24×1／1×24`、
  popup `6／12` 与横／纵增长。
- 场景精确位置：消费品 `[531,799,697,870]`，主动作栏
  `[713,827,1207,870]`，饰品 `[1223,832,1291,870]`；左右间距各 `16 px`。
- ImageGen：`0/0`；外部上传：`0`；本地渲染错误：首次 display contract
  因误用专用于 Quest provider 的 `provider_layout` 键返回 schema error，未
  产生任何外部调用；删除该无关键后同版本通过。

### 内部复核

- 语义：pass。饰品明确是现用 TrinketMenu 的双槽＋候选＋Queue，不是假动作格；
  AutoBar 明确标注为当前禁用的可选 provider。
- 几何：pass。主栏、菜单公式、最大对象数、Popup 上限、safe area 与极端方向
  均为真实 provider 支持值。
- 布局：pass。两套随身栏不覆盖主动作栏，不改变中央冷却扫视链，且保持独立
  移动／缩放。
- 美术方向：pass for user review。深皮护套、暖褐卷袋、薄候选插页、短连接扣
  与克制黄铜的层级清楚；模拟不证明最终笔触、Alpha、接缝或九宫格质量。
- 非权威：所有模拟像素不得裁切、切片、晋级、导出、上传或作为 production
  edit／ImageGen reference。

### 待用户判断的可见方向

1. 消耗品 `5×2` 在主栏左侧、饰品双槽在右侧、共同底边的整体平衡。
2. 饰品保持当前插件的水平双槽比例，菜单从右侧贴出并按当前四列向上增长。
3. 已装备护套较厚、候选插页较薄；Queue 保持明显但不盖住主图标。
4. 消耗品使用暖褐炼金卷袋，popup 由独立薄口袋形成，不使用固定大面板。
5. AutoBar 当前不启用；未来只有用户主动应用时才采用 `5×2` preset。

用户方向结论：`pending`。用户确认只接受上述文字化方向，不接受模拟像素。

## 生产正文完整性预检

| 项目 | 结论 | 状态 |
|---|---|---|
| 真实对象、数量、状态、几何和上限 | 两个 provider 均已完整审计 | pass |
| 锁定图与 Prompt provenance | Character V3 图＋主／子 Prompt 完整 | pass |
| 输入图职责 | 每个执行体只有 Character V3 作为拟议 Image 1；只继承材料 DNA | pass |
| source canvas／cell／Alpha | 两个执行体均为 `1024² RGBA` 四格 atlas，cell 与安全区固定 | pass |
| 动态内容与 z-order | 图标、文字、冷却、Queue、Tooltip 全排除并归 provider | pass |
| 最小／典型／最大真实排版 | 本地模拟与 display `15/15 pass` | pass |
| 独立执行预算 | `5 + 5`，最坏 `10` 次；尚未授权 | pass / blocked by authorization |
| 外部上传 | 本轮没有授权；AB.SLOT 的旧授权不可复用 | blocked |
| 用户模拟确认 | `AB-FIELDKIT-SIM-V1` 尚待确认 | blocked |

## 最终执行正文草案 A（`AB.TRINKET.KIT.V1`）

状态：`production-draft / not-authorized / not-executed`。

```text
Create one production-ready transparent RGBA UI asset atlas for Turtle WoW 1.18.1, component AB.TRINKET.KIT.V1. The output canvas must be exactly 1024 by 1024 pixels and divided into four non-overlapping 512 by 512 cells: A [0,0,512,512] equipped-trinket sheath base; B [512,0,1024,512] candidate-trinket insert base; C [0,512,512,1024] adaptive menu-frame nine-slice master; D [512,512,1024,1024] short joiner clasp used between the paired equipped sheaths. Keep every cell independent, centered, fully visible, and surrounded by at least 80 transparent pixels. No visible pixel may cross a cell boundary. Background outside each object must be true alpha zero; do not use a green key background.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted bitmap language, deep walnut and smoke-brown aged leather, muted oxidized brass, slightly irregular thick silhouettes, restrained wear, short warm upper-left light, darker lower-right pressure, low saturation, low-frequency value grouping, and believable material thickness. Ignore its character-window outline, parchment attribute panel, model area, equipment layout, tabs, text, icons and all large composition. Runtime geometry below overrides Image 1 whenever they conflict.

Cell A is one square leather sheath behind a live 36 by 36 UI trinket ActionButton. It must read as a compact functional sheath, not a generic spell slot: a slightly thicker deep-leather rim, a quiet recessed center completely covered by the live icon, one small muted-brass keeper near the upper edge, and no jewel, socket, gem glow or fixed trinket. It will display at roughly 40 to 44 UI units behind each of the two equipped buttons. Cell B is a visibly lighter and thinner square leather insert for each live 36 by 36 candidate button, with less brass and less depth than Cell A. Cell C is a square, quiet, non-directional nine-slice frame master with narrow broken brass edge segments and a matte stretchable center; it must remain valid around live menu frames from 52 by 52 UI through 172 by 332 UI, 212 by 252 UI and 1212 by 52 UI without creating fixed grid lines, fake pockets or a focal ornament in the center. Cell D is a very short leather-and-brass joiner that can sit in the 4 UI gap between two equipped sheaths in horizontal or vertical orientation; it must rotate cleanly and never enter either 36 by 36 hit area.

All four cells contain only the normal static base layer. Do not bake hover, pressed, selected, checked, cooldown, disabled, range, queue, autoqueue, keybinding, text, count, tooltip, equipment quality, item icon, inventory-slot number, left-click or right-click labels. Those are live provider layers. Avoid continuous bright gold bezels, wide quality colors, glossy PBR gradients, fine photographic grain, micro-scratches, dense stitching, perfect machined symmetry, modern glass cards, neon glows, jewel cabinets, altars, stone plinths and decorative elements that would become noise at approximately 29 to 36 physical pixels. Preserve clear alpha separation, calm icon-safe centers, and a visual weight slightly heavier than the consumable pockets but lower than the main action bar.
```

### A 的修复边界与预算

- 不可变：四个 cell 身份／数量、`1024²` canvas、cell 坐标、Alpha、Image 1
  职责、provider 动态排除、饰品护套比消费品略重、全部真实几何。
- 可修复：皮革／黄铜比例、局部轮廓、磨损密度、透明边缘、cell 内位置、九宫格
  中心安静度和连接扣可读性。
- 需要重新授权：新增／替换输入图、上传新图、改变 cell 身份／数量、把模拟或
  AB.SLOT 当输入、改变 canvas／Alpha／动态内容所有权。
- 预算：`0/5`；本体独立最多五次实际 ImageGen 生成／修图。

## 最终执行正文草案 B（`AB.CONSUMABLE.KIT.V1`）

状态：`production-draft / not-authorized / not-executed`。

```text
Create one production-ready transparent RGBA UI asset atlas for Turtle WoW 1.18.1, component AB.CONSUMABLE.KIT.V1. The output canvas must be exactly 1024 by 1024 pixels and divided into four non-overlapping 512 by 512 cells: A [0,0,512,512] main consumable pocket base; B [512,0,1024,512] thinner popup pocket base; C [0,512,512,1024] adaptive alchemist-roll nine-slice frame master; D [512,512,1024,1024] short rotatable popup connector strap. Keep each object independent, centered, fully visible and surrounded by at least 80 transparent pixels. No visible pixels may connect across cell boundaries. Everything outside each object must be true alpha zero, never chroma-key green.

Image 1 is the locked Character V3 Azeroth Expedition UI reference. Inherit only its classic vanilla hand-painted low-resolution rendering, warm aged leather, deep walnut shadows, muted oxidized brass, slightly irregular thick silhouettes, short upper-left warmth, restrained lower-right pressure, low saturation, broad readable value shapes and practical wear. Ignore the character-window composition, parchment, model background, equipment arrangement, tabs, text and icons. The real AutoBar button and popup geometry below is mandatory and overrides Image 1 when necessary.

Cell A is one independent square opening for a live AutoBar 36 by 36 UI item button: warm brown soft leather folded around a dark quiet center, a shallow pressure mark and sparse uneven stitches kept outside the icon-safe center. It must not resemble the main skill slot or contain a bottle. Cell B is the same family but thinner and lighter, as if a small insert unfolds from behind the main roll for one live popup candidate. Cell C is a square non-directional nine-slice master for an adaptive field alchemist roll. Use a warm old-leather outer fold, sparse short stitches and very small muted-brass fasteners at safe corners. The center must be quiet and stretchable around any real visible button cluster from 48 by 48 UI through the recommended 204 by 87 UI and the supported 945 by 48 or 48 by 945 UI extremes. Do not paint fixed pockets or a fixed ten-slot grid into this frame. Cell D is a short narrow leather connector for the provider's 3 UI gap between popup buttons; it must work after ninety-degree rotation for TOP, BOTTOM, LEFT and RIGHT chains of one to twelve live buttons.

All cells are normal static bases only. Do not bake potions, elixirs, flasks, food, drinks, bandages, engineering items, category marks, item names, keybinds, quantities, cooldown wedges or numbers, availability, family selection, tooltip content, hover, pressed, disabled, empty, missing-item or shift state. Those remain AutoBar-owned. Avoid fixed bottle illustrations, modern card grids, glass panels, bright continuous gold frames, quality glows, large clasps, glossy PBR leather, dense fibers, tiny photographic scratches, perfect symmetry, stone bases and visual weight that competes with the main action bar. The final atlas must stay readable and subordinate at approximately 29 to 36 physical pixels per live pocket.
```

### B 的修复边界与预算

- 不可变：四个 cell 身份／数量、`1024²` canvas、cell 坐标、Alpha、Image 1
  职责、AutoBar 数据与动态排除、全部真实 Button／popup 上限。
- 可修复：皮革折边、缝线密度、黄铜比例、透明边缘、cell 内位置、九宫格中心
  安静度和连接带旋转可读性。
- 需要重新授权：新增／替换输入图、上传新图、启用 AutoBar、引入 AEUI 分类／
  钉选逻辑、改变 cell 身份／数量或把模拟像素当输入。
- 预算：`0/5`；本体独立最多五次实际 ImageGen 生成／修图。

## 尝试与流程错误账本

### `AB.TRINKET.KIT.V1`

| 实际尝试 | 执行体 | 结果 | 结论 |
|---:|---|---|---|
| `0/5` | production draft | 未执行 | 等待模拟确认、正文授权与 Image 1 外部上传授权 |

### `AB.CONSUMABLE.KIT.V1`

| 实际尝试 | 执行体 | 结果 | 结论 |
|---:|---|---|---|
| `0/5` | production draft | 未执行 | 等待模拟确认、正文授权与 Image 1 外部上传授权 |

流程错误：本地 display contract 曾出现一次 schema 使用错误；没有调用外部
ImageGen、没有返回生成结果，不进入任一 `0/5` 账本。

## 下一门禁

1. 向用户展示 `AB-FIELDKIT-SIM-V1` 的战斗场景与 provider 状态板，等待明确
   接受或修订；确认只冻结文字化可见方向。
2. 若确认，写回用户结论并把确认条款冻结进两个最终 production body，再重跑
   prompt completeness。
3. 之后必须分别取得两个执行体的最终正文／最多五次实际生成授权，并分别取得
   Character V3 作为其 Image 1 上传到外部 ImageGen 的明确授权。不得复用
   `AB.SLOT.BASE.V1` 或 `AB.RAIL.V1` 的任何旧授权。
4. 两项授权未齐全前，不调用固定 ImageGen `0.143.0`，不产生候选，不接入
   addon，不启用 AutoBar，也不改变 TrinketMenu SavedVariables。
