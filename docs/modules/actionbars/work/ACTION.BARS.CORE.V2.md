# Action Bars／Field Kit 核心批次 V2

## 元数据

- 模块：Action Bars／Field Kit
- 组件 ID：`AB.RAIL`、`AB.SLOT`、`AB.ENDCAP.GRYPHON`、
  `AB.STANCE`、`AB.PET`、`AB.CONSUMABLE.RACK`、
  `AB.CONSUMABLE.POCKET`、`AB.TRINKET.DOCK`
- 版本：`ACTION-BARS-CORE-SIM-V2`
- 子状态：`simulation-reviewed`
- 项目阶段：`P1`；`P2` 待用户确认 V2 模拟
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 操作：`simulate / redesign`
- 生成前模拟版本：`ACTION-BARS-CORE-SIM-V2`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`
- 模拟脚本／specification：`tools/render_action_bars_simulation.py`／
  `tools/specs/action_bars_core_simulation_v2.json`
- 本地渲染错误：`0`
- 模拟路径／SHA：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V2/action_bars_core_sim_v2.png`／
  `943d6fac246f0ebc98ebf478519da05f18c3e8e35c4279b785034a4c5548e5d0`
- 模拟用户结论：`SIM-V1 rejected 2026-08-08`；`SIM-V2 pending`
- 自动修复预算：以后每个获授权 production 批次最多 5 次实际 ImageGen，含首次
- 当前实际生图：`0/5`
- 流程错误：`0`
- 多执行正文最坏实际生图数：当前未授权且必须先拆为独立资产批次；任何单批
  上限仍为 `5`
- 锁定视觉基准：
  - Image 1：
    [Character V3](../../../../assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png)
    — 只继承方槽的深胡桃皮革、氧化黄铜、左上暖光、粗厚手绘边与克制状态
- 基准提示词 provenance：
  - [Character 主模块 Prompt](../../character/ART_BASELINE.md) 与
    [Character 子模块 Prompt](../../character/SUBMODULE_ART_BASELINES.md) —
    对应 Image 1 的槽体材料和状态职责
  - [Action Bars 主模块 Prompt](../ART_BASELINE.md) — 当前模块物件身份与
    综合色重草案
- 次级参考：无上传图片；pfUI、AutoBar、TrinketMenu 只做只读对象／行为审计
- raw：无
- 透明候选：无
- 重组预演：无
- 真实排版预演：上述 `1920×1080` PNG；真实实例数量为主栏 12、副栏 12、
  姿态 3、辅助栏 12、消耗品 10、饰品 2，共 `51` 个交互对象；图标／字形是
  明示的非权威几何占位
- 实际展示区域合同／报告：
  `tools/specs/action_bars_core_simulation_v2_display_region.json`；
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V2/display-region-report.json`／
  `0fcd883615cf6baf6826bfebf53738b60e26db874de58fcb0155c8d652b7d69a`；
  主栏 `12×1／6×2`、辅助 `4×3`、姿态最小 3、宠物最大 10、消耗品空／典型／
  provider 最大 24、饰品 2，共 `9/9 pass`、violations `0`
- 战斗焦点布局报告：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V2/layout-report.json`／
  `f71449b5b9ab1b9bcbb930a18ffce4583893ab32e72c4e4c02cb10010d4712df`；
  同基线、内缘间距、中心对齐、按钮物理尺寸、纵向净空、底边距和 Chat 邻接
  共 `20/20 pass`、violations `0`
- 最终 source：无

## 跨设备 handoff

- 不存在。当前下一门禁是用户确认 V2 的战斗焦点布局；模拟像素处于 ignored
  `generated/`，不是视觉权威、source 或 addon runtime，也不会进入 `main`
  历史。

## 美术基准继承

### 权威顺序

1. Character V3 与其原始模块 Prompt：槽体材料和绘制语言。
2. [Action Bars 主模块 Prompt](../ART_BASELINE.md) 与
   [子模块 Prompt](../SUBMODULE_ART_BASELINES.md)：本模块物件身份和转译。
3. [全局美术基线](../../../GLOBAL_ART_BASELINE.md)：香草年代、配色、材料和
   反现代化约束。
4. [SUBMODULES.md](../SUBMODULES.md)：真实对象、几何、状态、数据所有权与
   禁止烘焙。
5. 当前模拟：只用于用户确认布局、隐喻、重量与整合，不提供生产像素。

### 必须继承的视觉 DNA

- 2004 年前后香草魔兽二维手绘位图；不是现代 MMO Dashboard。
- 深胡桃旧皮革主结构、暖褐卷袋、氧化黄铜窄沿，左上暖光、低饱和、粗厚略
  不规则轮廓与小尺度真实磨损。
- 动作条首先是经典技能格与成对狮鹫；消耗品首先是炼金师皮革卷袋；饰品是
  两个随身护套。
- 战斗信息优先：真实图标、冷却、键位、数量、范围和资源反馈必须压过装饰。

### 本批组件级转译

- `AB.RAIL` 只承担可伸缩连接，不生成固定十二格大底板。
- `AB.SLOT` 继承 Character V3 方槽材料，但减少装饰并强化高频按压层次。
- `AB.ENDCAP.GRYPHON` 只附着横向主栏，成为低重量左右端帽。
- `AB.CONSUMABLE.*` 把相同皮革／黄铜语言转译为软皮翻边、缝线和口袋，而非
  复制技能槽。
- `AB.TRINKET.DOCK` 用更厚的双护套区分装备槽 `13／14`，不变成珠宝陈列柜。

### 明确不继承

- 不继承 CharacterFrame 外轮廓、属性纸面、装备部位压印、品质框、Tabs 或
  人物模型背景。
- 不继承模拟中的抽象图标、平面色块、邻接 UI、狮鹫解剖或任何像素细节。
- 不从 AutoBar／TrinketMenu 复制源码、分类表、图片或全局 hook。

### 冲突审计

- 固定经典底栏与 pfUI 任意行列冲突：裁决为逐槽状态＋自适应 Rail；成对狮鹫
  仅是 Bar 1 可选端帽。
- 自动分类“各种消耗品”与 Vanilla／Turtle 自定义物品不可可靠枚举冲突：
  AutoBar 配置优先；AEUI fallback 只接受用户钉选或已验证 family，不猜名称。
- 饰品换装愿望与战斗安全冲突：点击使用保持；候选菜单与换装在非战斗处理，
  战斗中不尝试替换装备。
- 风格一致与战斗清晰冲突：状态和图标安全区优先，装饰被限制在外沿和端帽。

## 组件合同

- 逻辑对象与数量：pfUI Bar `1–12`；普通 Action Bar 每条 `1–12` 按钮；姿态／
  宠物最多 `10`；推荐消耗品 `10`、可选 AutoBar provider 支持 `1–24`；饰品
  固定 `2`。
- 每个对象状态：动作槽普通／悬停／按下／激活／禁用，并由 runtime 叠加
  cooldown／range／OOM／equipped／empty／pet-autocast；口袋增加缺货；饰品
  增加已装备／排队，但后两者尚未生产锁定。
- pfUI／Blizzard／provider 映射：详见 [SUBMODULES.md](../SUBMODULES.md)。
- runtime 尺寸：V2 推荐主栏 `icon=36,border=2,spacing=2,12×1`，Frame
  `506×44 UI`；副栏 `30/2/2,12×1`，`434×36 UI`；姿态 `26/2/2,3×1`
  示例 `98×34 UI`；辅助 `28/2/2,4×3`，`138×104 UI`；消耗品
  `32/2/2,5×2`，`192×78 UI`；饰品 `36/2/2,2×1`，`86×44 UI`。
- 推荐战斗焦点落位：目标设备物理屏幕上，主栏 `scale=1.2`、外框
  `[713,827,1207,870]`、Button 约 `39 px`，底边净空 `210 px`；副栏
  `scale=1.1`、姿态栏保持 `scale=1.0`，三者中心均为 `x=960`。消耗品与
  饰品作为独立 Frame 分列主栏左右并随核心区上移，不与 Chat 相交。
- UnitFrame 邻接合同：只提出 pfUI `pfPlayer／pfTarget` 的一次性推荐 preset，
  不在 Action Bars 模块接管其视觉。两框共同
  `width=280,height=72,scale=1.05,ypos=468`；玩家 `BOTTOMRIGHT/x=-49`，目标
  `BOTTOMLEFT/x=49`，映射到物理屏幕
  后同基线 `y=700`、内缘间距 `80 px`。当前 profile 的 `200×46/scale 0.9` 与
  玩家 `y=133`、目标 `y=197` 保留为可回退原值；本模拟未写入 SavedVariables。
- provider 公式：`frame=(icon+2*border+spacing)*columns+spacing`，高度同理；
  Button 为 `icon+2*border`，首格 inset 为 `border+spacing`。
- 源画布与排布：尚未冻结；正式生产前必须按 Rail、Slot、Gryphon、Pouch、
  Pocket、Trinket 分批建立 atlas／透明单件合同。
- 文字／图标安全区：`icon_ui` 的完整中央区域归真实 provider；外框、皮袋翻边
  和装饰不能侵入。
- 拉伸、裁切、UV：Rail／Pouch 外壳必须九宫格或受限重复；端帽独立透明；
  正式 cap、cell 与 UV 待 runtime 测量后冻结。
- Alpha 或色键：正式资产要求直 Alpha 并检查低 Alpha 残色；当前模拟为 RGB
  PNG，不承担该合同。
- 禁止烘焙：技能、宏、物品、饰品、职业／宠物符号、文字、键位、数量、冷却、
  范围、资源、品质、可用性、选择和 Tooltip。
- 验收预演与回退：adapter 只接管成功映射的对象；任何缺失或失败恢复 pfUI／
  AutoBar／TrinketMenu 原视觉与功能。
- 真实排版预演：V2 在完整 `1920×1080` 屏幕绘制 `51` 个 Button，并把
  Player／Target 的生命、能量和代表性 Aura 作为非权威邻接占位；Chat／
  Minimap／XP、姿态、辅助栏、消耗品和饰品分别保留独立 Frame 与 z-order。
- 实际展示区域：九个 UI-unit 场景全部来自上述 provider 公式；Button 命中盒
  在 Frame 内，装饰端帽不属于命中区；报告 `9/9 pass`。

## 生成前模拟实例图

### 模拟合同

- 版本：`ACTION-BARS-CORE-SIM-V2`
- 目标场景与 Frame 真实比例：目标设备 `1920×1080`，UI Scale
  `0.81269841269841`；Frame 由 UI-unit 公式换算到物理屏幕像素。
- 当前 accepted/runtime 邻接 UI：pfUI Chat、UnitFrames、Minimap 与 XP／声望
  只用低对比几何占位，不改变其现行 runtime；UnitFrame 额外展示位置和信息
  密度提案，但视觉仍归未来 Unit Frames／Character 范围。
- 真实对象数量与代表性信息密度：主 12＋副 12＋姿态 3＋辅助 12＋消耗品 10＋
  饰品 2；包含 normal、hover、pressed、active、cooldown、range、OOM、
  equipped、empty 的代表性状态。
- 目标层序与交互状态：场景背景 → 邻接 UI → 自适应 Rail／卷袋／护套 →
  Button → 图标 → provider 状态／键位／数量。
- 用户需要确认：上移后的中下战斗焦点、玩家／目标同基线与 `80 px` 内缘间距、
  主副栏尺寸、左右随身栏，以及默认关闭狮鹫后的综合色重。
- 刻意简化且非权威：平面颜色、抽象图标、头像、Aura、皮革／黄铜纹理、状态
  细节、Alpha、接缝、切片、UV、字体和全部邻接 UI。
- 禁止用途：不得作为 source/runtime、不得裁切／切片／晋级、不得作为
  production edit/reference 输入。

### 本地模拟规格

- 只读参考及职责：Character V3 只读取槽材料；pfUI／AutoBar／TrinketMenu
  只读取对象和布局行为。
- 上传范围：无；不得上传。
- specification 版本：`aeui-action-bars-simulation-v1 / ACTION-BARS-CORE-SIM-V2`
- 几何 primitives 与平面配色角色：圆角矩形表达 Rail／槽／皮袋／单位框，
  线段表达黄铜边与缝线，抽象几何只标示动态内容密度。
- 真实排版数据：见组件合同与 display-region JSON。
- ImageGen：`0/0`
- 本地脚本／命令：
  `python tools/render_action_bars_simulation.py tools/specs/action_bars_core_simulation_v2.json --repo-root . --layout-report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V2/layout-report.json`
- Python 解释器：`D:\Softwares\miniconda3\python.exe`；Python `3.13.5`；
  Pillow `11.3.0`

### 模拟规格正文

在目标 `1920×1080` 游戏画面中下部，以 pfUI 真实 Frame 公式绘制一个推荐但不
强制的战斗实例。玩家与目标框在主角两侧同基线收拢，内缘只留 `80 px`；生命、
能量和代表性 Aura 让状态密度可判断，但不提议由 Action Bars 接管单位框视觉。
其下依次是三格姿态、十二格副栏和 `scale=1.2` 的十二格主栏，主栏 Button 约
`39 px`，底边离屏幕 `210 px`，从而把技能冷却带进中下视线而不遮住角色脚下。

`5×2` 炼金师皮革卷袋与装备槽 `13／14` 的双饰品护套随核心区一同上移，仍是
可独立拖动的 Frame；`4×3` 辅助栏留在左侧并允许脱战淡出。本 preset 默认关闭
狮鹫，以免端帽挤压左右随身栏，但保留在解锁设置中按合法横栏启用。槽、Rail、
卷袋和护套只用深胡桃／暖褐皮革、氧化黄铜和左上暖光的平面近似；图标、头像、
快捷键、数量、冷却和 Aura 均是动态占位。图面必须明确标注为 `ImageGen 0/0`
非生产模拟。

### 模拟执行与内部检查

- 本地脚本／specification：`tools/render_action_bars_simulation.py` SHA
  `ab5a4968d6e88b02a5868113f5d794d2bf058f1c8690d23b220c77c920d99ba8`；spec
  SHA `80068a37649f011763f9e0e1608425d21cd1d1096cdbc302ac7ecada95daf6f5`
- 输出路径／SHA：见元数据。
- ImageGen：`0/0`
- 本地渲染错误：`0`
- 真实 Frame 比例／屏幕位置：中心堆栈、双方状态框与左右随身栏均按 UI Scale
  换算；布局报告 `20/20 pass`，辅助 `4×3` 与底部 Chat 不重叠，XP 在屏幕内。
- 邻接 UI／对象数量／信息密度：`51` 个真实对象容量，九种状态分布；邻接 UI
  低对比且不冒充当前最终像素。
- 物件隐喻／材质／配色／重量：动作甲板、炼金卷袋、双护套三类可辨；中心主栏
  最重，随身栏次之，辅助栏最轻。
- 非权威简化说明：已直接写在图面和 metadata；不可能被误认成 source。
- 内部结论：`displayable`

| 本地渲染错误 | specification 版本 | 命令 | 错误 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| `0` | `ACTION-BARS-CORE-SIM-V2` | 上述命令 | 无 | 按用户要求重构战斗焦点布局；未生成生产像素 | 不涉及 ImageGen |

### 用户方向结论

- 具体模拟版本：`ACTION-BARS-CORE-SIM-V2`
- 用户结论与日期：`SIM-V1 rejected 2026-08-08`；`SIM-V2 pending`
- V1 否决原因：动作条仍贴近屏幕底边，玩家／目标框横向过远且不在同一基线，
  不能把技能冷却和双方状态收进一次扫视。
- 确认并写回生产正文的可见条款：待确认主栏 `y=827／scale=1.2`、玩家／目标框
  同基线与 `80 px` 内缘间距、左右随身栏上移关系、默认关闭狮鹫和综合色重。
- 拒绝时必须改变：按用户指出的布局、大小、密度、显隐、隐喻或材料重新制作
  新的 deterministic simulation；仍不消耗 ImageGen。
- 确认失效条件：可见布局、物件隐喻、材质层级、配色、综合色重或整合关系
  发生实质变化。
- 下一门禁：用户确认 V2 本地模拟；之后才编写并请求授权第一个正式生产正文。

## 生产正文完整性预检

- 复杂度：`assembly／repeat／stretch + states + multiple future atlases`
- 结论：`blocked`；方向未获用户确认，且本批必须拆成多个独立 source 合同，
  不允许把整个屏幕或整套动作区作为一次生成。

| 门禁 | 当前证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | 长期 Prompt 与组件合同已定义 | `pass for simulation` |
| 每张输入图的 inherit／ignore 职责与权威冲突 | Character V3 职责已限定；每批输入列表未冻结 | `blocked for production` |
| 画布、格位、边距、方向、透视、尺度、光照与层序 | runtime 实例已定义；source 画布／atlas 尚未拆分 | `blocked` |
| 逐对象形态、材料、边缘、状态与相互关系 | 方向条款已定义；独立生产状态表待冻结 | `blocked` |
| 文字／图标安全区、裁切、拉伸、平铺、重复与接缝 | 安全区已定义；cap／seam／UV 待测 | `blocked` |
| 美术 DNA、具体反模式、Alpha／色键与最终自检 | 长期 Prompt 已定义；技术像素参数待分批写入 | `blocked` |

- 未知但执行必需的值：各 source canvas、状态 cell 顺序、九宫格 cap、最终
  Alpha、AutoBar popup 与 TrinketMenu 候选菜单最大几何。
- 去冗余结论：当前只保留高风险的 provider 所有权、任意行列、动态内容排除和
  战斗可读性；生产历史不进入长期 Prompt。

## 最终执行正文

未授权、未编写、不得执行。用户确认 V2 后，先按 `AB.SLOT＋RAIL`、
`AB.ENDCAP.GRYPHON`、`AB.CONSUMABLE.*`、`AB.TRINKET.DOCK` 拆成独立完整正文，
逐批预检并另行请求授权。

## 执行记录

- 日期：`2026-08-08`
- 会话／结果 ID：不适用；只执行本地确定性模拟
- 实际输入绝对路径与职责：无上传输入；锁定图只作本地只读美术职责审计
- imagegen 报告的 revised prompt：不适用
- 输出尺寸／模式／SHA-256：`1920×1080 RGB`／
  `943d6fac246f0ebc98ebf478519da05f18c3e8e35c4279b785034a4c5548e5d0`
- Alpha／残色：不适用；模拟禁止晋级
- 实际生图次数：`0/5`
- 流程错误次数：`0`
- 循环终态：不适用；当前为 `simulation-reviewed`

## 审查记录

- 语义／物理：中心动作甲板、软皮卷袋和双护套互不混淆；所有功能槽对应真实
  pfUI／AutoBar／TrinketMenu 或明确 fallback。
- 透视／图层：平视 2D UI；装饰在 Button 下，动态内容和状态在 Button 上。
- 美术一致性：平面模拟已继承深胡桃、暖褐、氧化黄铜和低饱和层级；纹理与
  狮鹫细节故意不作生产判断。
- 对象／状态合同：V2 展示九种关键状态和 `51` 个典型对象；未生成假技能或
  假物品。
- 装配／尺寸：pfUI 公式和 UI Scale 已记录；display-region `9/9 pass`，布局
  `20/20 pass`。
- 真实排版：完整目标屏幕、当前密度与当前邻接 UI 的显式非权威占位；PNG SHA
  见元数据。
- 实际展示区域：合同 SHA
  `cdea511343e4a881e19a45455fd9559a83abacec9ea320a3777962face5febbb`；报告
  SHA `0fcd883615cf6baf6826bfebf53738b60e26db874de58fcb0155c8d652b7d69a`；
  `9` 场景、violations `0`、first failure `null`。
- 战斗焦点布局：报告 SHA
  `f71449b5b9ab1b9bcbb930a18ffce4583893ab32e72c4e4c02cb10010d4712df`；
  `20` 项精确几何检查、violations `0`、first failure `null`。V1 回归重渲染
  SHA 仍为 `fd5e1537…18d0`，旧模拟证据未被渲染器扩展改变。
- 技术像素：PNG `1920×1080 RGB`；仅本地几何模拟，不审查透明边／残色。
- 结论：`simulation-reviewed / displayable`
- 用户结论与日期：`SIM-V1 rejected 2026-08-08`；`SIM-V2 pending`
- 下一门禁：用户确认或继续修订 V2 模拟。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `SIM-V1` | deterministic PNG `fd5e1537…18d0`；display `9/9 pass` | `user-rejected 2026-08-08` | 动作条上移至中下视线；玩家／目标框靠近并同基线 |
| `SIM-V2` | PNG `943d6fac…e5d0`；display `9/9`；layout `20/20` | `simulation-reviewed` | 等待用户确认；若否决只按新的具体可见问题调整，不消耗 ImageGen |
