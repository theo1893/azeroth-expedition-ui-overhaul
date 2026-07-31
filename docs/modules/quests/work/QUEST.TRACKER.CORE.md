# pfQuest 任务追踪核心工作文件 — QT V2

## 元数据

- 模块：任务／pfQuest 游戏内任务追踪
- provider：`pfQuest 7.0.1`；`pfQuest-turtle 7.0.2` 只提供数据
- 当前范围：
  `QUEST.TRACKER.SHELL`、`PAPER.*`、`ENTRY.FOCUS`、`ENTRY.TRACKED`、
  `ENTRY.COMPLETE`
- 暂缓范围：`HEADER.*` 与七个 provider 工具 Button；保留对象和行为合同，
  本轮不设计资产、不进入预演、不改 runtime
- 子状态：`simulation-reviewed`
- 项目阶段：`P2`
- 操作：`simulate`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 生成前模拟版本：`QT-SIM V2`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`；无上传、provider session 或独立生图预算
- 本地渲染错误：`0`
- 模拟路径／SHA：
  `generated/quests/QT/simulation/QT-SIM-V2/quest_tracker_core_local_geometry_v2.png` /
  `cb54d64f78c100fae94d387c280017f522871d144d0b71aa01fdbb8c1deea4a2`
- 模拟用户结论：`pending`
- 用户确认：尚无；不得执行以下生产正文
- 实际 ImageGen：当前活动的 QT-A1 `0/5`、QT-B1 `0/5`；最坏合计
  `10` 次实际生成／修图。QT-A2 `0/5`、`scope-deferred`，不计入活动预算
- 流程错误：QT-A1 `0`、QT-B1 `0`；不占实际生图额度
- source／runtime／adapter：均无
- 下一门禁：用户审阅并确认或否决 `QT-SIM V2` Tracker 核心本地几何预演；
  QT-A1／B1 仍不得执行，QT-A2 保持暂缓

## 组件合同

### 真实 provider 与状态

源码权威：

- [`pfQuest/tracker.lua`](../../../../addon/pfQuest/tracker.lua)
- [`pfQuest/quest.lua`](../../../../addon/pfQuest/quest.lua)
- [稳定对象合同](../SUBMODULES.md)

`pfQuestMapTracker` 是唯一顶层 Frame，同时通过全局 `tracker` 和
`pfQuest.tracker` 暴露。它保留拖动、锁定、屏幕限位、位置保存、显隐、
WorldMap strata、Tooltip 与原生 QuestWatch 隐藏行为。根宽度动态为
`130..330 UI px`；根高度为 `16px` 工具条加动态条目总高。

真实工具 Button 共七个，但均处于本轮 `scope-deferred`：

1. `tracker.btnquest`
2. `tracker.btndatabase`
3. `tracker.btngiver`
4. `tracker.btnsearch`
5. `tracker.btnclean`
6. `tracker.btnsettings`
7. `tracker.btnclose`

前三个分别切换 `QUEST_TRACKING`、`DATABASE_TRACKING`、
`GIVER_TRACKING`，具有 selected；七个都保留原 Button、Tooltip 与 OnClick。
暂缓只改变当前设计优先级，不授权隐藏、删除、重挂、换皮或改写脚本。

真实条目是 `tracker.buttons`／`pfQuestMapButton1..25`。每条拥有
`button.bg`、`button.icon`、`button.text` 和零到多个
`button.objectives[i]`；`button.tracked`、`button.perc`、
`pfMap.highlight` 是当前可用的覆盖状态。条目高度、排序、文字、目标数、
等级、百分比和节点图标全部动态。左键、右键、Ctrl、Shift 的原行为不得改变。

`expand_states` 是 provider 局部表；tracker 没有独立 timer 或 failed
状态。当前活动范围不生成折叠 Button、沙漏或失败蜡封，不从显示文字猜测状态。

### 资产与运行时分配

| 批次 | 生成 source | 未来 runtime 分配 | 禁止烘焙 |
|---|---|---|---|
| `QT-A1 V1` | 一张空的纵向纸面 shell 母版 | 确定性切为 paper 九宫格和独立叠页边；根 Frame 动态拼装 | 工具条、按钮、文字、任务行、目标、节点图标、状态 |
| `QT-A2 V1` | `scope-deferred`；当前不生成任何 source | 七个 provider Button 与 `tracker.panel` 原样保留，未来独立重开 | 当前禁止生成、隐藏、重挂、换皮或改变行为 |
| `QT-B1 V1` | 一条 focus 墨洗、一个 tracked 页边墨记、一个 complete 墨勾 | focus 横向三段式；tracked／complete 为无鼠标覆盖 | 完整任务行、任务名、等级、百分比、目标、节点图标 |

可以共用物理 atlas，但 manifest 必须分别记录每个逻辑对象、cell、UV、
运行时尺寸、状态派生和九宫格／三段式规则。客户端不得直接加载高分辨率 PNG。

## 美术基准继承

### 固定输入

| 输入 | SHA-256 | 权威与用途 |
|---|---|---|
| Image 1：[任务追踪面板_视觉基准_v1.png](../../../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | `3b5c2ca6c1e69c74db5c64978cde351596ece6369d339b7125aee43904eb7d86` | Tracker 物件隐喻、纵向轮廓、纸面／皮带／页边关系和总体配色的最高图像权威 |
| Image 2：[任务详情面板_视觉基准_v1.png](../../../../assets/locked/quests/任务详情面板_视觉基准_v1.png) | `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd` | 只继承同一公会卷宗系统的材料厚度、笔触、左上暖光和暗酒红／旧黄铜综合色；忽略双页书几何 |
| Image 3：[pfQuest tracker 当前结构](../../../../assets/references/quests/session-2026-07-31/01_external_quest_tracker_current_state.png) | `88ecd502e190311c8709a6fd15e2cde6d1f5f288a749e5f5b318f7038e188504` | 只证明真实信息密度、三层文字和纵向增长；忽略透明黑底、字体、彩色标记和全部现有美术 |

Image 1 与 Image 2 的 Prompt provenance 是
[Quests 主模块美术基线](../ART_BASELINE.md)；该 Prompt 显式继承
[全局美术基线](../../../GLOBAL_ART_BASELINE.md)。稳定子件转译见
[SUBMODULE_ART_BASELINES.md](../SUBMODULE_ART_BASELINES.md)。

必须继承的视觉 DNA：

- 2004 年前后香草魔兽二维手绘位图；粗厚、略不规则但清晰的轮廓和明确明暗
  切面，不是照片级 PBR；
- 左上暖光，低饱和暖赭纸、烟褐旧皮、暗酒红强调、克制旧黄铜和深乌棕墨；
- 可感知的纸页层厚、皮革压痕、铆钉实体和小尺度磨损；中心阅读区安静低对比；
- 公会远征文书的沉重、耐用和手工感，而不是现代极简或泛棕色透明 HUD。

明确排除：

- Image 1 中任何烘焙文字、示意任务、完整 UI 截图或不可适配的固定高度；
- Image 2 的双页书、中央装订、书脊、右页正文、奖励槽和底部书本按钮；
- Image 3 的黑色透明矩形、青绿色选中、彩虹难度色、现有 tracker icon；
- Skyrim 菜单式细线、Diablo 3 金属祭坛、现代圆角卡片、玻璃拟态、霓虹、
  高光细金框、逐任务独立框和移动端图标按钮。

权威冲突裁决：Image 1 决定 tracker 的纵向行军便笺身份；真实 provider
决定可变宽高和对象数量；Image 2 只统一材料语言。任何固定尺寸效果图都不能
覆盖 `130..330px` 动态宽度、任意高度和七个真实 Button 的合同。

## 生成前模拟实例图 — QT-SIM V2

### 模拟合同

- 状态：`simulation-reviewed / 待用户确认`
- 目标：只确认 tracker 主体在高密度真实游戏场景下的整体轮廓、连续纸面、
  内容层级、综合色重和反馈节奏；七个工具 Button 不参与本轮方向判断。
- Canvas：`1536 × 1024` 横向游戏画面裁切。
- 目标 Frame：右侧 `QUEST_TRACKING`；确定性预演按约 `330 × 865 UI px`、
  `100%` UI 像素呈现，纸面从顶部直接开始。
- 真实密度：十个任务、十七条目标；一条 focus、两条 tracked、两条
  complete；任务名、等级、百分比和目标保持 provider 的三层动态信息结构。
- 暂缓边界：预演不绘制 `tracker.panel`、16px 工具条、皮带、徽记或七个
  Button。这只是在视觉评审中移除低优先级对象，不授权 runtime 隐藏、删除、
  重挂或改变它们。
- 当前邻接 UI：用简单几何表示码头、水面、角色和香草动作条的非权威
  fallback；没有已接受的 tracker runtime。预演不虚构其他 AEUI 模块。
- 用户需要确认：单张行军便笺是否足够厚重但仍像香草魔兽；纸页轮廓和边缘
  厚度；连续纸面在高密度文字下是否可读；focus、tracked、complete 是否
  与内容层级协调。
- 刻意简化且非权威：全部手绘笔触与材质微纹理、九宫格接缝、Alpha、精确
  atlas cell、最终边缘磨损和 world background；暂缓按钮的最终视觉完全不由
  本图决定。
- 禁止用途：模拟图只写入 `generated/quests/QT/simulation/QT-SIM-V2/`；
  不得作为 source／runtime、不得裁切／切片／晋级，也不得作为 QT-A1／B1
  的 edit 或 reference 输入。

### 本地模拟规格

- 只读参考：Image 1／2 只提供物件隐喻、材料层级和平面配色角色；Image 3
  只提供真实信息密度和三层文字结构。三张参考图均不上传、不粘贴、不裁切，
  也不进入模拟像素。
- 上传范围：无。
- specification：
  `tools/specs/quest_tracker_simulation_v2.json`，SHA-256
  `3961a538bae7debf770e4e036e6ac643c2e1ed5ca3c1b9ce959bc61bc5c362fe`。
- renderer：
  `.codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py`，
  SHA-256
  `9801ecb384de79aeb4b2a01f989fc4a14044fd719990329ec9a52f04b6fb4793`。
- 几何 primitives：矩形、多边形、线段、椭圆和真实字体排版；无生成纹理。
- 平面配色角色：暖赭纸、烟褐页边、暗酒红状态、旧黄铜工具强调、深乌棕文字。
- ImageGen：`0/0`；不需要模拟执行授权。

### 模拟规格正文

在 `1536 × 1024` 本地画布上用简单几何建立非权威码头游戏场景，把
约 `330 × 865` tracker 放在 `x=1166..1496`、`y=72..937`。tracker 只用
平面多边形表达一张从上缘直接开始、底部轻微撕裂、两侧可见叠页厚度的行军
便笺；不模拟最终笔触或纹理，不绘制工具条、皮带、徽记或按钮。纸面使用真实
中文排版放置十个任务和十七条目标，实例化一条无边框 focus 墨洗、两条
tracked 页边记号和两枚 complete 墨勾。每个任务仍直接排在同一连续纸面，
不增加卡片、独立边框、滚动条或 provider 不存在的控件。

### 本地渲染命令

macOS：

```bash
conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py \
  tools/specs/quest_tracker_simulation_v2.json \
  --repo-root .
```

实际解释器：Conda `py312` 环境（`sys.executable` 已验证），Python
`3.12.12`。绝对仓库路径不写入 specification 或模拟像素。

### 模拟执行与内部检查

- 本地 renderer：
  `.codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py`
- 主预演：
  `generated/quests/QT/simulation/QT-SIM-V2/quest_tracker_core_local_geometry_v2.png`，
  `1536 × 1024 RGBA`，SHA-256
  `cb54d64f78c100fae94d387c280017f522871d144d0b71aa01fdbb8c1deea4a2`
- 局部查看：
  `generated/quests/QT/simulation/QT-SIM-V2/quest_tracker_core_local_geometry_v2_zoom.png`，
  `398 × 912 RGBA`，SHA-256
  `a49b3913591f32b305e18b9802cb3317a1a329f8692af99e7580b679b1f8f360`
- ImageGen：`0/0`
- 本地渲染错误：`0`
- 真实 Frame／密度：约 `330 × 865`、右上位置；十个任务、十七条目标、
  一 focus、两 tracked、两 complete 全部可见。
- 内部结论：`displayable`。布局、层级、比例和配色角色足以交给用户判断；
  手绘轮廓、纸皮微纹理、磨损、Alpha 和切片均非权威。

### 用户方向结论

- `QT-SIM V1`：`superseded-by-user-priority / 2026-07-31`。用户判断七个
  低频功能 Button 对体验占比很小，更关键的是 tracker 整体；V1 未触发任何
  生产。
- 当前具体模拟版本：`QT-SIM V2`
- 用户结论与日期：`pending`
- 确认并写回生产正文的可见条款：尚无
- 拒绝时必须改变：由用户观察后记录
- 确认失效条件：可见轮廓、纸页厚度、材质层级、配色、综合色重、信息密度
  或反馈节奏发生实质变化
- 下一门禁：用户确认或否决 `QT-SIM V2`

## 最终执行正文

### QT-A1 V1

状态：`production-draft / 未授权`

固定上传：Image 1、Image 2、Image 3。只允许同段前一次输出作为后续 edit
输入；不得追加其他图片。

> Create exactly one empty, front-facing vertical field-note paper shell source for a
> Turtle WoW 1.18.1 addon. This is a source master that will later be deterministically
> cut into nine-slice and layered-page-edge runtime textures; it is not a screenshot and
> it is not a fixed runtime background.
>
> Canvas: exactly 1024 × 1536 pixels. Place one and only one complete paper object,
> centered, upright, occupying approximately x=276..748 and y=96..1440. Everything
> outside the object must be one flat, perfectly uniform pure chroma green #00FF00 with
> no gradient, noise, cast shadow, vignette, second object, labels, guides, text, or
> swatches.
>
> Object anatomy: a single continuous warm-ochre parchment field note, seen nearly
> straight-on with only a slight internal top-down view. The top edge is sturdy and
> quietly finished; the long middle is flat, calm, low contrast, and directionally
> neutral; the bottom ends in one natural restrained torn edge. Show two or three thin,
> offset underlying page layers only along the outer side edges and lower edge, so the
> sheet has tangible vanilla-WoW thickness without becoming a book. Keep left and right
> edge anatomy compatible and stable enough for later nine-slice extraction.
>
> Preserve fixed edge zones and a quiet stretch field: the top 96 source pixels of the
> paper object contain all top-edge wear; the bottom 128 contain the torn footer; the
> leftmost and rightmost 64 pixels contain all side thickness and edge wear. The large
> central rectangle must contain no focal stain, emblem, crease crossing, hole, rivet,
> ornament, directional fiber clump, cast shadow, or feature that would reveal vertical
> or horizontal stretching. The paper may have broad hand-painted tonal variation, but
> no repeated wallpaper motif and no visible seam.
>
> Art direction must inherit Images 1 and 2: circa-2004 vanilla World of Warcraft
> hand-painted 2D bitmap art, thick slightly irregular silhouette, readable light and
> shadow planes, warm light from upper left, muted warm ochre paper, smoke-brown edge
> grime, deep umber ink-scale accents, restrained wear, and visibly layered material
> thickness. It must feel like a durable guild expedition note pulled from the accepted
> quest dossier. Use Image 3 only to understand how much dynamic text will later occupy
> the quiet paper; inherit none of its current black backdrop, typography, colored
> symbols, or icons.
>
> Do not create a double-page book, book spine, chat book, stone tablet, wooden plank,
> metal plaque, Diablo-style altar, Skyrim menu, modern card, transparent black HUD,
> rolled scroll with curled ends, per-entry bands, buttons, icons, text, quest rows,
> objectives, percentages, seals, compass, quill, timer, or decorative border around the
> central reading field.
>
> Final self-check: exactly one empty vertical parchment object; pure #00FF00 everywhere
> outside it; calm seamless central stretch field; fixed top and torn bottom; layered
> page thickness only at edges; vanilla-WoW hand-painted weight; zero text, UI controls,
> or baked dynamic content.

### QT-A2 V1 — scope-deferred

- 用户于 `2026-07-31` 将 `HEADER.*`、皮带／徽记和七个工具 Button 的视觉
  改造暂缓。
- 历史生产正文只保留在 Git history；当前工作树不保留可误执行的正文。
- 实际 ImageGen `0/5`；无生产授权、source、runtime 或 adapter。
- 恢复时必须重新做独立的本地几何预演、完整 Prompt 预检和生产授权，不能
  沿用 `QT-SIM V2` 对 tracker 主体的确认。

### QT-B1 V1

状态：`production-draft / 未授权`

固定上传：Image 1、Image 2、Image 3。只允许同段前一次输出作为后续 edit
输入；不得追加其他图片。

> Create exactly three separate interaction-feedback art objects for real pfQuest
> tracker entry Buttons. These are overlays above one continuous parchment, not task-row
> cards and not a complete tracker screenshot.
>
> Canvas: exactly 1024 × 768 pixels. Background must be one flat, perfectly uniform pure
> chroma green #00FF00 with no gradient, noise, cast shadow, labels, text, guides,
> swatches, or extra objects. Arrange three isolated objects in this exact order:
>
> 1. Top cell x=152..872, y=96..196: one long, very low-contrast horizontal warm-umber
>    ink wash for `ENTRY.FOCUS`, with a visible bounding box no larger than
>    720 × 100 source pixels. It has softly dissipating irregular
>    ends, a calm nearly uniform middle that can be three-sliced horizontally, no border,
>    no corners, no enclosed card silhouette, and enough transparency-ready negative
>    space for dynamic title and objective text.
> 2. Bottom-left cell x=192..384, y=440..632: one short dark-wine cloth-and-ink
>    page-edge mark for
>    `ENTRY.TRACKED`, a compact vertical tab that touches only a page edge. It is not an
>    arrow, flag, full-row ribbon, badge plate, or Button.
> 3. Bottom-right cell x=640..832, y=440..632: one small complete-state mark for
>    `ENTRY.COMPLETE`, made from a
>    single confident deep-umber hand-painted ink check. It has no circle, wax seal,
>    green color, red color, metal base, text, or failure counterpart.
>
> Each object must have its own clean silhouette and at least 64 pixels of pure green
> separation from the others. Generate one base object for each role. Hover intensity and
> other allowed runtime variations will be derived deterministically; do not create
> duplicate states.
>
> Inherit Images 1 and 2 as the same circa-2004 vanilla World of Warcraft guild dossier:
> thick low-resolution-friendly hand-painted shapes, slight human irregularity, warm
> upper-left light, muted deep-wine cloth, warm umber ink, restrained wear, and no
> photorealism. Use Image 3 only to preserve real text density and entry hierarchy;
> inherit none of its black row highlight, cyan, rainbow markers, typography, or node
> icons.
>
> Do not draw a parchment background, whole task row, per-entry card, frame, text,
> numbers, percentage, objective bullets, dynamic node icon, expand/collapse control,
> timer, hourglass, failure seal, quest-type badge, toolbar icon, book, modern rounded
> rectangle, translucent black HUD, neon glow, or fourth object.
>
> Final self-check: exactly three separated overlays in the declared order; focus is a
> borderless stretchable ink wash; tracked is a small page-edge mark; complete is one
> ink check; pure #00FF00 isolation; no baked text, icon, row card, timer, or invented
> state.

## 生产正文完整性预检（Prompt 完整性预检）

结论：`pass / production-draft`。

- 当前两段 QT-A1／B1 分别覆盖对象身份、对象数量与顺序、Canvas、安全盒、
  视角、材料、光照、
  状态派生、动态内容排除、切片／拉伸、色键和最终自检。
- Image 1／2／3 的权威与 inherit／ignore 职责已分别写入执行正文。
- 未知的折叠、timer、failed 状态已停止在组件合同，没有伪造精度。
- 生产拆分按独立缩放和交互所有权完成，不按模型方便性把完整 tracker 合成一图。
- QT-A2 不属于本次完整性预检；当前树没有它的可执行 Prompt。

## Repair envelope 与计数

当前活动的 QT-A1／B1 各自最多五次实际 ImageGen 生成／修图，活动最坏合计
`10` 次；只有返回图片或 provider 证据证明生成实际运行才计数。上传、权限、
包装、传输、保存或流程错误单列，不占 `0/5`。QT-A2 保持 `0/5`，
`scope-deferred` 不参与预算。

同段自主修复只允许：

- 修正既有对象的轮廓、综合色、材料可读性、色键纯度、指定安全盒、对象间隔、
  seam／stretch 安全性和低分辨率可读性；
- 在不改变对象身份、数量、顺序、Canvas 和参考图角色的前提下选择 regenerate
  或 edit；
- 仅使用同段前一次输出作为 edit 输入，并只修改失败门禁。

不得自行改变：

- QT-A1／B1 边界、对象／状态数量、Canvas、provider 映射或真实动态行为；
- Image 1／2／3 的权威顺序与上传范围；
- 将文字、任务行、节点图标、按钮或不存在的 timer／failed／collapse 状态
  加入资产；
- 恢复或代做 QT-A2 的皮带、徽记、图标或 selected 压片；
- 新增第六次实际调用、跨段借用候选、晋级 source、导出 runtime 或创建 adapter。

任一段五次仍未通过，停止并等待用户审核，不以其他段剩余额度补充。

## 候选审查与真实排版预演

每次 countable output 先检查：精确对象数、语义、纯色背景、连通域、bbox、
对象间隔、静态切片 seam、材料／香草语言和禁止内容。语义失败优先于尺寸或
色键；不得仅凭透明化成功晋级。

每个达到可预演门禁的候选都必须使用“真实排版 + 新 UI”做确定性模拟，而不是
只展示孤立资产：

- `230 × 500`：`QUEST_TRACKING`，至少六个任务、展开目标、focus、tracked
  与 complete 状态；
- `330 × 865`：接近当前实机最高密度，最多可见内容和长中文换行；
- 动态文字、目标、百分比和节点图标使用真实 pfQuest 层级重新排版；
- 预演只装配 QT-A1／B1 候选，不虚构 QT-A2；七个 provider Button 的原
  对象和行为不因预演消失，未来恢复其视觉设计时必须另做包含工具条的模拟；
- 同时保留一张旧 tracker 与新 tracker 的 100% UI 像素对比，但旧图只作
  结构参照。

通过 P3 内审仍不等于接受。只有用户明确接受具体 source 后才能进入 P4；
只有已接受 source、确定性切片／UV manifest 和 adapter 静态测试完成后才可
进入 P5；Turtle WoW `1.18.1` 实机证据是 P6 的唯一依据。

## 执行记录

- `QT-SIM V1` 在本地完成后被用户调整优先级而替代；没有触发正式生产。
- `QT-SIM V2` 已使用本地确定性几何 renderer 完成；ImageGen `0/0`，无上传、
  provider session 或生成流程错误。主图与局部查看路径、SHA 见模拟章节。
- 当前活动的 QT-A1／B1 均尚未执行；无 raw、透明候选或 revised prompt。
- 实际生图：QT-A1 `0/5`、QT-B1 `0/5`；QT-A2 `0/5 scope-deferred`。
- 流程错误：QT-A1／B1 均为 `0`；QT-A2 无活动流程。
- 当前终态：`simulation-reviewed`，等待用户确认方向。

## 审查记录

- 已完成：provider 语义、组件粒度、权威冲突、本地模拟规格与内部可读性
  检查、生产正文完整性和真实排版预演合同。
- 尚未发生：用户对 `QT-SIM V2` 的方向确认。
- 尚未发生：候选语义／物理、美术、装配与技术像素审查。
- 当前结论：`simulation-reviewed / P2`，不能授权正式生产或晋级 P3。
- 下一门禁：用户确认或否决 `QT-SIM V2`。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `QT-SIM V1` | 本地 specification、renderer、主图／局部图 SHA；ImageGen `0/0` | `superseded-by-user-priority` | 移除低优先级工具条，聚焦 tracker 主体 |
| `QT-SIM V2` | 本地 specification、renderer、主图／局部图 SHA；ImageGen `0/0` | `simulation-reviewed / P2` | 等待用户确认；不得跳过到正式生产 |
| `QT-A1/B1 V1` | 两段自包含生产预检；无 ImageGen 调用 | `prompt-draft / P2` | 先取得 V2 模拟确认，再请求独立生产授权 |
| `QT-A2 V1` | 无 ImageGen 调用；历史正文仅在 Git history | `scope-deferred / P2` | 未来重开时先做独立模拟和新授权 |

## 下一门禁

等待用户查看并确认或否决 `QT-SIM V2`。该预演只确认 tracker 主体的布局、
比例、信息密度、综合色重、平面配色角色和交互反馈节奏；不确认最终手绘
笔触、材料微纹理、磨损、Alpha 或切片，也不确认七个工具 Button。

用户确认模拟方向后，把确认条款写回 QT-A1／B1 生产正文并重新预检，再单独
请求这两段的正式授权、固定上传、同段 edit repair envelope 和每段最多五次
实际 ImageGen 调用。QT-A2 保持暂缓；模拟方向确认不能代替正式生产授权。
