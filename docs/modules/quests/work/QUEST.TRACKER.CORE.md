# pfQuest 任务追踪核心工作文件 — QT V1

## 元数据

- 模块：任务／pfQuest 游戏内任务追踪
- provider：`pfQuest 7.0.1`；`pfQuest-turtle 7.0.2` 只提供数据
- 当前范围：
  `QUEST.TRACKER.SHELL`、`PAPER.*`、`HEADER.*`、七个工具 Button、
  `ENTRY.FOCUS`、`ENTRY.TRACKED`、`ENTRY.COMPLETE`
- 子状态：`simulation-reviewed`
- 项目阶段：`P2`
- 操作：`simulate`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 生成前模拟版本：`QT-SIM V1`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`；无上传、provider session 或独立生图预算
- 本地渲染错误：`0`
- 模拟路径／SHA：
  `generated/quests/QT/simulation/QT-SIM-V1/quest_tracker_local_geometry_v1.png` /
  `ff20cc9bd92d68bd0e41df4bb4970c367ced3a1488c7b3855f20a531d5e68405`
- 模拟用户结论：`pending`
- 用户确认：尚无；不得执行以下生产正文
- 实际 ImageGen：QT-A1 `0/5`、QT-A2 `0/5`、QT-B1 `0/5`；
  最坏合计 `15` 次实际生成／修图
- 流程错误：QT-A1 `0`、QT-A2 `0`、QT-B1 `0`；不占实际生图额度
- source／runtime／adapter：均无
- 下一门禁：用户审阅并确认或否决 `QT-SIM V1` 本地几何预演；正式资产三段
  仍不得执行

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

真实工具 Button 共七个：

1. `tracker.btnquest`
2. `tracker.btndatabase`
3. `tracker.btngiver`
4. `tracker.btnsearch`
5. `tracker.btnclean`
6. `tracker.btnsettings`
7. `tracker.btnclose`

前三个分别切换 `QUEST_TRACKING`、`DATABASE_TRACKING`、
`GIVER_TRACKING`，具有 selected；七个都保留原 Button、Tooltip 与 OnClick。

真实条目是 `tracker.buttons`／`pfQuestMapButton1..25`。每条拥有
`button.bg`、`button.icon`、`button.text` 和零到多个
`button.objectives[i]`；`button.tracked`、`button.perc`、
`pfMap.highlight` 是当前可用的覆盖状态。条目高度、排序、文字、目标数、
等级、百分比和节点图标全部动态。左键、右键、Ctrl、Shift 的原行为不得改变。

`expand_states` 是 provider 局部表；tracker 没有独立 timer 或 failed
状态。V1 不生成折叠 Button、沙漏或失败蜡封，不从显示文字猜测状态。

### 资产与运行时分配

| 批次 | 生成 source | 未来 runtime 分配 | 禁止烘焙 |
|---|---|---|---|
| `QT-A1 V1` | 一张空的纵向纸面 shell 母版 | 确定性切为 paper 九宫格和独立叠页边；根 Frame 动态拼装 | 工具条、按钮、文字、任务行、目标、节点图标、状态 |
| `QT-A2 V1` | 一条空短皮带、一个徽记、七个工具图标和一个可复用 selected 压片 | 皮带三段式；徽记独立 Texture；七个 Button 各自独立 UV；selected 压片只挂前三个模式 Button | 文字、整条工具栏截图、假 Button、动态模式标签 |
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

## 生成前模拟实例图 — QT-SIM V1

### 模拟合同

- 状态：`simulation-reviewed / 待用户确认`
- 目标：在正式拆分 QT-A1／A2／B1 source 前，先确认高密度真实游戏场景下的
  整体轮廓、材料层级、综合色重和阅读关系。
- Canvas：`1536 × 1024` 横向游戏画面裁切。
- 目标 Frame：右侧 `QUEST_TRACKING`；最终确定性预演按
  `330 × 865 UI px`、`100%` UI 像素呈现，顶部保留真实 `16px` 工具条。
- 真实密度：七个工具 Button 全部出现；十个任务、至少十七条目标；
  一条 focus、两条 tracked、两条 complete；任务名、等级、百分比和目标保持
  provider 的三层动态信息结构。
- 当前邻接 UI：用简单几何表示码头、水面、角色和香草动作条的非权威
  fallback；没有已接受的 tracker runtime。预演不虚构其他 AEUI 模块。
- 用户需要确认：单张行军便笺是否足够厚重但仍像香草魔兽；顶部短皮带与纸面
  比例；连续纸面在高密度文字下是否可读；暗酒红／旧黄铜强调是否克制；
  七按钮、focus、tracked、complete 是否与内容层级协调。
- 刻意简化且非权威：全部手绘笔触与材质微纹理、九宫格接缝、Alpha、精确
  atlas cell、各 Button 全状态、每枚 icon 的最终像素和 world background。
- 禁止用途：模拟图只写入 `generated/quests/QT/simulation/QT-SIM-V1/`；
  不得作为 source／runtime、不得裁切／切片／晋级，也不得作为 QT-A1／A2／
  B1 的 edit 或 reference 输入。

### 本地模拟规格

- 只读参考：Image 1／2 只提供物件隐喻、材料层级和平面配色角色；Image 3
  只提供真实信息密度和三层文字结构。三张参考图均不上传、不粘贴、不裁切，
  也不进入模拟像素。
- 上传范围：无。
- specification：
  `tools/specs/quest_tracker_simulation_v1.json`，SHA-256
  `d472b6a114ad1acc5cce36ec2e731e9f3d315d6ffcb5f6fbad8f6f04fcd8741c`。
- renderer：
  `.codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py`，
  SHA-256
  `9801ecb384de79aeb4b2a01f989fc4a14044fd719990329ec9a52f04b6fb4793`。
- 几何 primitives：矩形、多边形、线段、椭圆和真实字体排版；无生成纹理。
- 平面配色角色：暖赭纸、烟褐页边、暗酒红状态、旧黄铜工具强调、深乌棕文字。
- ImageGen：`0/0`；不需要模拟执行授权。

### 模拟规格正文

在 `1536 × 1024` 本地画布上用简单几何建立非权威码头游戏场景，把
`330 × 865` tracker 放在 `x=1166..1496`、`y=72..937`。tracker 只用平面
多边形表达一张叠页行军便笺、薄的 16px 皮革工具条和克制的纸页厚度；不模拟
最终笔触或纹理。工具条实例化全部七个真实 Button，并用暗酒红压片表示
`QUEST_TRACKING` selected。纸面使用真实中文排版放置十个任务和十七条目标，
实例化一条无边框 focus 墨洗、两条 tracked 页边记号和两枚 complete 墨勾。
每个任务仍直接排在同一连续纸面，不增加卡片、独立边框、滚动条或 provider
不存在的控件。

### 本地渲染命令

macOS：

```bash
conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py \
  tools/specs/quest_tracker_simulation_v1.json \
  --repo-root .
```

实际解释器：Conda `py312` 环境（`sys.executable` 已验证），Python
`3.12.12`。绝对仓库路径不写入 specification 或模拟像素。

### 模拟执行与内部检查

- 本地 renderer：
  `.codex/skills/run-aeui-asset-workflow/scripts/render_geometric_mockup.py`
- 主预演：
  `generated/quests/QT/simulation/QT-SIM-V1/quest_tracker_local_geometry_v1.png`，
  `1536 × 1024 RGBA`，SHA-256
  `ff20cc9bd92d68bd0e41df4bb4970c367ced3a1488c7b3855f20a531d5e68405`
- 局部查看：
  `generated/quests/QT/simulation/QT-SIM-V1/quest_tracker_local_geometry_v1_zoom.png`，
  `398 × 912 RGBA`，SHA-256
  `9bb96b68ce8d3cdaeded869daceb664d1a4b761603b8c586dad93002599b2da2`
- ImageGen：`0/0`
- 本地渲染错误：`0`
- 真实 Frame／密度：`330 × 865`、右上位置；七个 Button、十个任务、
  十七条目标、一 focus、两 tracked、两 complete 全部可见。
- 内部结论：`displayable`。布局、层级、比例和配色角色足以交给用户判断；
  手绘轮廓、纸皮微纹理、磨损、Alpha、切片和精确 icon 像素均非权威。

### 用户方向结论

- 具体模拟版本：`QT-SIM V1`
- 用户结论与日期：`pending`
- 确认并写回生产正文的可见条款：尚无
- 拒绝时必须改变：由用户观察后记录
- 确认失效条件：可见轮廓、纸面／皮带比例、材质层级、配色、综合色重、
  工具条节奏或高密度阅读关系发生实质变化
- 下一门禁：用户确认或否决 `QT-SIM V1`

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

### QT-A2 V1

状态：`production-draft / 未授权`

固定上传：Image 1、Image 2。Image 3 不上传。只允许同段前一次输出作为后续
edit 输入；不得追加其他图片。

> Create a source atlas containing exactly ten separate art objects for the toolbar of a
> Turtle WoW 1.18.1 quest tracker. These are independent runtime-owned pieces, not a
> toolbar screenshot and not one merged UI panel.
>
> Canvas: exactly 1536 × 1024 pixels. Background must be one flat, perfectly uniform pure
> chroma green #00FF00 with no gradient, noise, cast shadow, labels, text, guides, cell
> borders, swatches, or extra objects. Every object must be fully separated from every
> other object by at least 48 pixels of pure green.
>
> Object 1 occupies the upper band x=128..1408, y=96..304: one empty horizontal dark
> smoke-brown and deep-wine old-leather strap, front-facing, with a restrained worn brass
> rivet near each end. Its end caps carry all silhouette and wear detail; its long central
> 70 percent is quiet and uniform enough to be cut into a stretchable middle. No holes,
> icon slots, text, stitched grid, buckle, hanging tails, or buttons.
>
> Objects 2 through 10 occupy nine fixed cells from y=480..736. The cells are
> x=96..224, 248..376, 400..528, 552..680, 704..832, 856..984, 1008..1136,
> 1160..1288, and 1312..1440. Center one object in each cell; keep each visible bounding
> box at or below 96 × 96 pixels so adjacent visible objects remain separated by at least
> 56 pixels of pure green. Use this exact left-to-right order: (2) crossed small quill
> and four-point compass emblem; (3) current
> quests glyph, a compact folded guild task sheet; (4) database glyph, two stacked
> catalog folios; (5) quest-giver glyph, a restrained hand-painted exclamation marker
> attached to a tiny notice; (6) search glyph, a stout old-brass magnifier; (7) clean
> glyph, a short stiff archive brush; (8) settings glyph, a compact worn brass cog; (9)
> close glyph, two crossed dark-metal strokes forming a heavy X; (10) one empty reusable
> selected-mode press plate, a small dark-wine leather lozenge with restrained brass edge
> light. Each glyph is exactly one object with a transparent-ready isolated silhouette;
> none has a square app-icon background. The selected press plate contains no glyph.
>
> All nine lower objects are designed to remain legible when downsampled into 14 × 14 UI
> pixel Button art. Use thick, simplified, low-frequency shapes, strong negative space,
> one clear silhouette, and no hairline engraving. The seven functional glyphs are seven
> distinct logical Button assets even though they share this atlas. Generate only their
> base normal art; hover, pressed, disabled, and the three mode selected states will be
> derived deterministically from the same alpha silhouettes and the reusable selected
> press plate. Do not draw multiple state copies.
>
> Inherit the locked circa-2004 vanilla World of Warcraft hand-painted 2D language from
> Images 1 and 2: thick slightly irregular contour, clear upper-left warm light, muted
> smoke-brown and deep-wine leather, old brass rather than bright gold, deep umber ink,
> restrained hand wear, and tangible material thickness. The objects belong to the same
> guild expedition dossier as the quest book but must remain compact field-tool symbols.
>
> Do not create modern outline icons, mobile-app tiles, neon cyan selection, glossy 3D
> renders, photorealistic antiques, thin Skyrim menu symbols, Diablo metal spikes,
> circular HUD rings, labels, letters, numbers, quest text, a whole tracker panel, a
> double-page book, fake Button hit areas, or any eleventh object.
>
> Final self-check: exactly ten separated objects in the declared order; one stretchable
> empty leather strap; one emblem; seven semantically distinct toolbar glyphs; one empty
> selected press plate; pure #00FF00 isolation; no text, no merged toolbar, and clear
> readability at 14 × 14.

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

- 三段分别覆盖对象身份、对象数量与顺序、Canvas、安全盒、视角、材料、光照、
  状态派生、动态内容排除、切片／拉伸、色键和最终自检。
- Image 1／2／3 的权威与 inherit／ignore 职责已分别写入执行正文。
- 未知的折叠、timer、failed 状态已停止在组件合同，没有伪造精度。
- 生产拆分按独立缩放和交互所有权完成，不按模型方便性把完整 tracker 合成一图。

## Repair envelope 与计数

每段独立最多五次实际 ImageGen 生成／修图；只有返回图片或 provider 证据证明
生成实际运行才计数。上传、权限、包装、传输、保存或流程错误单列，不占
`0/5`。

同段自主修复只允许：

- 修正既有对象的轮廓、综合色、材料可读性、色键纯度、指定安全盒、对象间隔、
  seam／stretch 安全性和低分辨率可读性；
- 在不改变对象身份、数量、顺序、Canvas 和参考图角色的前提下选择 regenerate
  或 edit；
- 仅使用同段前一次输出作为 edit 输入，并只修改失败门禁。

不得自行改变：

- 三段边界、对象／状态数量、Canvas、provider 映射或真实动态行为；
- Image 1／2／3 的权威顺序与上传范围；
- 将文字、任务行、节点图标、按钮或不存在的 timer／failed／collapse 状态
  加入资产；
- 新增第六次实际调用、跨段借用候选、晋级 source、导出 runtime 或创建 adapter。

任一段五次仍未通过，停止并等待用户审核，不以其他段剩余额度补充。

## 候选审查与真实排版预演

每次 countable output 先检查：精确对象数、语义、纯色背景、连通域、bbox、
对象间隔、静态切片 seam、材料／香草语言和禁止内容。语义失败优先于尺寸或
色键；不得仅凭透明化成功晋级。

每个达到可预演门禁的候选都必须使用“真实排版 + 新 UI”做确定性模拟，而不是
只展示孤立资产：

- `130 × 180`：空状态和七个工具 Button 的最窄宽度；
- `230 × 500`：`QUEST_TRACKING`，至少六个任务、展开目标、追踪与完成状态；
- `330 × 865`：接近当前实机最高密度，最多可见内容、长中文换行；
- `DATABASE_TRACKING` 和 `GIVER_TRACKING` 各一张代表性预演；
- 动态文字、目标、百分比和节点图标使用真实 pfQuest 层级重新排版；所有
  Button 使用候选 atlas 的真实 UV 和未来显示尺寸；
- 同时保留一张旧 tracker 与新 tracker 的 100% UI 像素对比，但旧图只作
  结构参照。

通过 P3 内审仍不等于接受。只有用户明确接受具体 source 后才能进入 P4；
只有已接受 source、确定性切片／UV manifest 和 adapter 静态测试完成后才可
进入 P5；Turtle WoW `1.18.1` 实机证据是 P6 的唯一依据。

## 执行记录

- `QT-SIM V1` 已使用本地确定性几何 renderer 完成；ImageGen `0/0`，无上传、
  provider session 或生成流程错误。主图与局部查看路径、SHA 见模拟章节。
- 三段正式资产均尚未执行；无 raw、透明候选或 revised prompt。
- 实际生图：QT-A1 `0/5`、QT-A2 `0/5`、QT-B1 `0/5`。
- 流程错误：三段均为 `0`。
- 当前终态：`simulation-reviewed`，等待用户确认方向。

## 审查记录

- 已完成：provider 语义、组件粒度、权威冲突、本地模拟规格与内部可读性
  检查、生产正文完整性和真实排版预演合同。
- 尚未发生：用户对 `QT-SIM V1` 的方向确认。
- 尚未发生：候选语义／物理、美术、装配与技术像素审查。
- 当前结论：`simulation-reviewed / P2`，不能授权正式生产或晋级 P3。
- 下一门禁：用户确认或否决 `QT-SIM V1`。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `QT-SIM V1` | 本地 specification、renderer、主图／局部图 SHA；ImageGen `0/0` | `simulation-reviewed / P2` | 等待用户确认；不得跳过到正式生产 |
| `QT-A1/A2/B1 V1` | 三段自包含生产预检；无 ImageGen 调用 | `prompt-draft / P2` | 先取得模拟确认，再请求独立生产授权 |

## 下一门禁

等待用户查看并确认或否决 `QT-SIM V1`。该预演只确认布局、比例、信息密度、
综合色重、平面配色角色和交互状态节奏；不确认最终手绘笔触、材料微纹理、
磨损、Alpha、切片或 icon 像素。

用户确认模拟方向后，把确认条款写回三段生产正文并重新预检，再单独请求
QT-A1／A2／B1 的正式授权、固定上传、同段 edit repair envelope 和每段
最多五次实际 ImageGen 调用。模拟方向确认不能代替正式生产授权。
