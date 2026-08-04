# pfQuest 任务追踪核心工作文件 — QT V2

## 元数据

- 模块：任务／pfQuest 游戏内任务追踪
- provider：`pfQuest 7.0.1`；`pfQuest-turtle 7.0.2` 只提供数据
- 当前范围：
  `QUEST.TRACKER.SHELL`、`PAPER.*`
- 暂缓范围：QT-B1 的 `ENTRY.FOCUS`、`ENTRY.TRACKED`、`ENTRY.COMPLETE`，
  以及 QT-A2 的 `HEADER.*` 与七个 provider 工具 Button；保留 provider
  对象和行为合同，不创建这些自定义覆盖层
- 子状态：QT-A1 `runtime-exported-temporary / display-region-blocked`；
  QT-GEO V1 `user-rejected / superseded`；
  QT-GEO V2 `simulation-rendered / awaiting-user-confirmation`；
  QT-B1 `scope-deferred / user-paused`
- 项目阶段：`P5`
- 操作：`export / integrate`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 生成前模拟版本：`QT-SIM V2`（旧材料方向）；
  `QT-GEO V1`（已拒绝的外置装饰端帽）；
  `QT-GEO V2`（直接使用 live tracker 纸面）
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`；无上传、provider session 或独立生图预算
- 本地渲染错误：QT-SIM V2 `0`；QT-GEO V1 `1`，已修复；QT-GEO V2 `0`。
  这些本地脚本执行没有调用 ImageGen
- 模拟路径／SHA：
  `generated/quests/QT/simulation/QT-SIM-V2/quest_tracker_core_local_geometry_v2.png` /
  `cb54d64f78c100fae94d387c280017f522871d144d0b71aa01fdbb8c1deea4a2`
- 模拟用户结论：`confirmed / 2026-07-31`
- 用户确认：用户在看到 `QT-SIM V2` 主图与局部图后以“继续”确认 tracker
  主体方向；该确认只接受下文文字化方向，不接受模拟像素
- 实际 ImageGen：QT-A1 `5/5`、QT-B1 `1/5`；活动累计 `6/10`。QT-A2
  `0/5`、`scope-deferred`，不计入活动预算
- 预算合同：QT-A2 `0/5`；QT-A1／B1 最坏合计仍为
  `10` 次实际生成／修图
- 流程错误：QT-A1 `2`、QT-B1 `1`；不占实际生图额度
- 生产授权：`confirmed / 2026-07-31`。用户明确授权 QT-A1 V1 与 QT-B1
  V1；每段固定 Image 1／2／3；同段前次输出只可在冻结边界内作 edit 输入；
  每段最多 `5` 次实际 ImageGen，最坏合计 `10` 次；无生成证据的流程错误
  不计额度；QT-A2 继续暂缓
- source：`assets/source/quests/qt-a1/QuestTrackerPaperShell_Temporary_v1.png`
  / SHA-256
  `a9d700cd01f26535ae2035bfa3d8c2cedd7337bfb47d3fa9494ba592d259c59b`
- runtime：`addon/AzerothExpeditionUI/Media/Quests/QuestTrackerPaperV1.tga`
  / SHA-256
  `c6b1f64034fa69f01709403e592c3350445c9a6739f4b559242be48831666c61`
- exporter／adapter：`tools/build_quest_tracker_paper_v1.py` /
  `addon/AzerothExpeditionUI/Modules/Quests.lua` runtime contract `1.18`；
  `Quest Visual Theme 1.6`
- 实际展示区域合同：
  `tools/specs/quest_tracker_display_region_v1.json`
- 展示区域报告：
  `generated/quests/QT/QT-A1/display-region-audit/display-region-report.json` /
  SHA-256
  `511dcffcf9bbb93a9e969c75d3dcb1fe10711258be85442044e3450af261801c` /
  `fail / 35 violations`
- 本地验证：atlas 九格采样完整覆盖可见区；exporter 重跑哈希稳定；Python
  编译、quest design contract、repository contract、asset workflow skill
  contract 与 Quest Lua smoke 通过。实际展示区域门禁失败，不能进入 P6
- 用户于 `2026-07-31` 否决 `QT-GEO V1` 的外置端帽：不得在 tracker 外侧
  增加类似书框的边界，当前 tracker 直接展示已经足够。`QT-GEO V2` 已按
  “显示面严格等于 provider live Frame、四边 outsets 全为 0”生成本地预演，
  ImageGen `0/0`
- `2026-08-01` 新增用户实机裁决：隐藏所有条目 `button.icon` 彩色点／问号，
  Tracker 任务名换回 pfUI／pfQuest 旧统一字体并移除 `OUTLINE` 与 shadow；
  不改变 `button.node` 数据、动态字号、条目命中、排序或脚本。随后 runtime
  `1.16` 让任务名与 Quest Log 共用同一高对比深墨难度色 resolver；完成率
  继续使用独立深墨语义色。
- 下一门禁：Turtle WoW `/reload` 后验证接受／放弃任务批次、底部安全区、
  条目 icon 持续隐藏、任务名无描边／阴影及同一任务跨面板颜色一致。
  QT-B1／A2 均保持暂缓。

## 组件合同

### 真实 provider 与状态

源码权威：

- [`pfQuest/tracker.lua`](../../../../addon/pfQuest/tracker.lua)
- [`pfQuest/quest.lua`](../../../../addon/pfQuest/quest.lua)
- [稳定对象合同](../SUBMODULES.md)

`pfQuestMapTracker` 是唯一顶层 Frame，同时通过全局 `tracker` 和
`pfQuest.tracker` 暴露。它保留拖动、锁定、屏幕限位、位置保存、显隐、
WorldMap strata、Tooltip 与原生 QuestWatch 隐藏行为。根宽度动态为
`130..330 UI px`；provider 内容高度为 `16px` 工具条加动态条目总高，
AEUI 显示高度另加 `16px` 底部内容安全区。

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
等级、百分比和节点数据全部动态。用户于 `2026-08-01` 只撤销节点图标的可见
纹理；左键、右键、Ctrl、Shift 的原行为不得改变。

`expand_states` 是 provider 局部表；tracker 没有独立 timer 或 failed
状态。当前活动范围不生成折叠 Button、沙漏或失败蜡封，不从显示文字猜测状态。

### 资产与运行时分配

| 批次 | 生成 source | 未来 runtime 分配 | 禁止烘焙 |
|---|---|---|---|
| `QT-A1 V1` | 一张空的纵向纸面 shell 母版 | 已确定性导出为单张 TGA 的九宫格；根 Frame 动态拼装 | 工具条、按钮、文字、任务行、目标、节点图标、状态 |
| `QT-A2 V1` | `scope-deferred`；当前不生成任何 source | 七个 provider Button 与 `tracker.panel` 原样保留，未来独立重开 | 当前禁止生成、隐藏、重挂、换皮或改变行为 |
| `QT-B1 V1` | `scope-deferred`；当前不生成或挂载三件覆盖层 | adapter 隐藏 provider 的现代半透明行矩形与条目节点 icon，只保留大纸面及文字动态内容 | 完整任务行、任务名、等级、百分比、目标、节点图标 |

可以共用物理 atlas，但 manifest 必须分别记录每个逻辑对象、cell、UV、
运行时尺寸、状态派生和九宫格／三段式规则。客户端不得直接加载高分辨率 PNG。

## 美术基准继承

### 固定输入

| 输入 | SHA-256 | 权威与用途 |
|---|---|---|
| Image 1：[任务追踪面板_视觉基准_v1.png](../../../../assets/locked/quests/任务追踪面板_视觉基准_v1.png) | `3b5c2ca6c1e69c74db5c64978cde351596ece6369d339b7125aee43904eb7d86` | Tracker 行军便笺身份、纵向轮廓、连续纸面、叠页厚度、反馈综合色的最高图像权威；皮带／徽记／按钮属于暂缓 QT-A2，本轮明确忽略 |
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
- 可感知的纸页层厚、自然接触阴影和小尺度磨损；中心阅读区安静低对比；
- 公会远征文书的沉重、耐用和手工感，而不是现代极简或泛棕色透明 HUD。

明确排除：

- Image 1 中任何烘焙文字、示意任务、完整 UI 截图或不可适配的固定高度；
- Image 1 的顶部皮带、铆钉、徽记、工具条和按钮；它们属于暂缓的 QT-A2；
- Image 2 的双页书、中央装订、书脊、右页正文、奖励槽和底部书本按钮；
- Image 3 的黑色透明矩形、青绿色选中、彩虹难度色、现有 tracker icon；
- Skyrim 菜单式细线、Diablo 3 金属祭坛、现代圆角卡片、玻璃拟态、霓虹、
  高光细金框、逐任务独立框和移动端图标按钮。

权威冲突裁决：Image 1 决定 tracker 的纵向行军便笺身份、纸面轮廓和反馈
综合色；真实 provider 决定可变宽高、对象数量和行为；Image 2 只统一材料
语言。QT-SIM V2 的用户确认要求活动纸面从顶部直接开始，因此 QT-A1／B1
正文必须排除 Image 1 的皮带／徽记／按钮，但这不改变七个真实 Button 的
provider 合同。任何固定尺寸效果图都不能覆盖 `130..330px` 动态宽度和任意
高度。

## 生成前模拟实例图 — QT-SIM V2

### 模拟合同

- 状态：`simulation-confirmed / 2026-07-31`
- 目标：只确认 tracker 主体在高密度真实游戏场景下的整体轮廓、连续纸面、
  内容层级、综合色重和反馈节奏；七个工具 Button 不参与本轮方向判断。
- Canvas：`1536 × 1024` 横向游戏画面裁切。
- 目标 Frame：右侧 `QUEST_TRACKING`。历史确定性预演使用
  `330 × 865 UI px` 容量包络表达高密度视觉方向；`2026-07-31` 的源码复算
  证明它不是十任务／十七目标在默认 `12px` 字体下的真实 provider 实例，
  后者实际为 `330 × 420 UI px`。因此该图只保留材料／综合色方向证据，不再
  作为精确 Frame 几何证据。
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
- 历史容量包络／密度：`330 × 865`、右上位置；十个任务、十七条目标、
  一 focus、两 tracked、两 complete 全部可见。该高度不是 provider 公式
  结果，精确几何证据已由后续展示区域复核取代。
- 内部结论：`displayable`。布局、层级、比例和配色角色足以交给用户判断；
  手绘轮廓、纸皮微纹理、磨损、Alpha 和切片均非权威。

### 用户方向结论

- `QT-SIM V1`：`superseded-by-user-priority / 2026-07-31`。用户判断七个
  低频功能 Button 对体验占比很小，更关键的是 tracker 整体；V1 未触发任何
  生产。
- 当前具体模拟版本：`QT-SIM V2`
- 用户结论与日期：`confirmed / 2026-07-31`；用户回复“继续”
- 确认并写回生产正文的可见条款：
  - tracker 主体保持贴近屏幕右侧的纵向行军便笺；历史确认图使用
    `330 × 865 UI px` 容量包络，活动纸面从顶部直接开始。该固定高度不再
    作为 runtime 几何授权，真实高度必须由 provider 公式重新确认；
  - 第一眼必须是单张厚实、耐用、从公会卷宗抽出的野外便笺，不是双页书、
    卷轴、现代任务卡或透明 HUD；顶部略有手工不规则，底部克制撕裂；
  - 两侧和底部以少量错层纸页形成可感知厚度，但不能围成规则边框；中部保持
    一张连续、安静、低对比的暖赭阅读面；
  - 在十个任务、十七条目标的密度下仍不增加逐任务卡片、分隔框或烘焙内容；
    任务名、等级、百分比、目标和节点图标继续全部动态；
  - focus 是从纸面自然消散的低对比墨洗，tracked 是右侧页边的克制暗酒红
    记号，complete 是小型深乌棕墨勾；三者都从属于文字层级；
  - 综合色保持低饱和暖赭纸、烟褐页边、深乌棕墨与少量暗酒红反馈，遵循左上
    暖光和香草魔兽粗厚二维手绘切面；
  - 工具条、皮带、徽记和七个 Button 不在本次确认范围；QT-A2 继续暂缓，
    provider 对象与行为保持。
- 拒绝时必须改变：由用户观察后记录
- 确认失效条件：可见轮廓、纸页厚度、材质层级、配色、综合色重、信息密度
  或反馈节奏发生实质变化
- 下一门禁：最终 QT-A1 V1／QT-B1 V1 生产正文与修复边界授权

## 最终执行正文

### QT-A1 V1

状态：`production / 已授权`

固定上传：Image 1、Image 2、Image 3。只允许同段前一次输出作为后续 edit
输入；不得追加其他图片。

> Create exactly one empty, front-facing vertical field-note paper shell source for a
> Turtle WoW 1.18.1 addon. This is a source master that will later be deterministically
> cut into nine-slice and layered-page-edge runtime textures; it is not a screenshot and
> it is not a fixed runtime background.
>
> Preserve this exact assembled visual direction: at 100% UI scale the result must read
> as one narrow, tall quest-tracker field note docked near the right edge of the game
> screen. The runtime shell must remain coherent across the provider's real
> 130..330 UI-pixel width range and from an empty/short tracker through as many as
> twenty-five dynamic entries. At representative maximum density it must quietly support
> about ten quest titles and seventeen objective lines on one uninterrupted reading
> surface, although no text or rows may appear in this source. The visible paper begins
> directly at its upper edge. Do not attach or imply a toolbar, leather header strap,
> emblem, control rail, or any of the seven deferred provider Buttons.
>
> Canvas: exactly 1024 × 1536 pixels. Place one and only one complete paper object,
> centered, upright, occupying approximately x=276..748 and y=96..1440. Everything
> outside the object must be one flat, perfectly uniform pure chroma green #00FF00 with
> no gradient, noise, cast shadow, vignette, second object, labels, guides, text, or
> swatches.
>
> Object anatomy: a single continuous warm-ochre parchment field note, seen nearly
> straight-on with only a slight internal top-down view. Give the top a sturdy,
> restrained hand-cut irregularity without curling or rolling it. Keep the long middle
> flat, calm, low contrast, and directionally neutral; end the bottom in one natural,
> restrained torn edge. Show two or three thin, offset underlying page layers only along
> the outer side edges and lower edge, so the sheet has tangible vanilla-WoW weight
> without becoming a book or a framed panel. The layered edges must remain subordinate
> to the reading field. Keep left and right edge anatomy compatible and stable enough for
> later nine-slice extraction.
>
> Preserve fixed edge zones and a quiet stretch field: the top 96 source pixels of the
> paper object contain all top-edge wear; the bottom 128 contain the torn footer; the
> leftmost and rightmost 64 pixels contain all side thickness and edge wear. The large
> central rectangle must contain no focal stain, emblem, crease crossing, hole, rivet,
> ornament, directional fiber clump, cast shadow, or feature that would reveal vertical
> or horizontal stretching. The paper may have broad hand-painted tonal variation, but
> no repeated wallpaper motif and no visible seam.
>
> Input roles and art direction: use Image 1 as the highest visual authority for the
> vertical guild-expedition field-note identity, paper silhouette, layered page weight,
> palette, and hand-painted age, but explicitly ignore its baked text, example quest
> content, toolbar, strap, emblem, icons, and fixed-height composition. Use Image 2 only
> for the shared dossier material thickness, circa-2004 vanilla World of Warcraft
> hand-painted 2D bitmap brushwork, warm upper-left light, thick slightly irregular
> contour, readable light/mid/shadow planes, muted warm ochre paper, smoke-brown wear,
> deep umber accents, and restrained old-wine/aged-brass color relationships; ignore its
> double-page book geometry, spine, binding, rewards, and Buttons. Use Image 3 only to
> understand the real three-level text hierarchy, narrow right-side placement, and
> density of roughly ten quests and seventeen objectives; inherit none of its transparent
> black backdrop, typography, colored symbols, current icons, or modern styling.
>
> Do not create a double-page book, book spine, chat book, stone tablet, wooden plank,
> metal plaque, Diablo-style altar, Skyrim menu, modern card, transparent black HUD,
> rolled scroll with curled ends, per-entry bands, buttons, icons, text, quest rows,
> objectives, percentages, seals, compass, quill, timer, header strap, toolbar, emblem,
> or decorative border around the central reading field.
>
> Final self-check: exactly one empty narrow vertical parchment object; the paper starts
> directly at its slightly irregular top; pure #00FF00 everywhere outside it; one calm
> seamless reading field suitable for ten quests and seventeen objectives; restrained
> torn bottom; layered thickness only at side and lower edges; vanilla-WoW hand-painted
> weight; zero text, rows, toolbar, Buttons, or baked dynamic content.

### QT-A2 V1 — scope-deferred

- 用户于 `2026-07-31` 将 `HEADER.*`、皮带／徽记和七个工具 Button 的视觉
  改造暂缓。
- 历史生产正文只保留在 Git history；当前工作树不保留可误执行的正文。
- 实际 ImageGen `0/5`；无生产授权、source、runtime 或 adapter。
- 恢复时必须重新做独立的本地几何预演、完整 Prompt 预检和生产授权，不能
  沿用 `QT-SIM V2` 对 tracker 主体的确认。

### QT-B1 V1 — scope-deferred

- 范围：`ENTRY.FOCUS`、`ENTRY.TRACKED`、`ENTRY.COMPLETE` 三件覆盖层。
- attempt 1 已消耗 `1/5` 次实际 ImageGen；三件身份存在，但真实排版效果
  糟糕，且 cell、综合色、绿边与 native 色键均未通过。
- 用户于 `2026-07-31` 明确要求三件 UI 组件暂停，当前 tracker 只使用
  QT-A1 大块纸面背景和 provider 的动态文字／交互；adapter 不创建、挂载或
  模拟这三件覆盖层，并隐藏 provider 的现代半透明行矩形。
- 当前树不保留可误执行的 V1／V1.r1 Prompt；完整正文、一次生成证据和过程
  错误保留在 Git history。未来恢复必须重新做本地模拟、Prompt 预检与授权，
  不得继续消费旧 V1 的剩余 `4` 次额度。

## 历史生产正文完整性预检（Prompt 完整性预检）

复杂度：QT-A1 `single-object / assembly / repeat / stretch`；QT-B1
`three-object atlas / overlay states / stretch`。

原结论：`pass / production / 已授权`。该结论只解释已经发生的 A1／B1
调用，不构成当前授权；B1 已由用户暂停，当前树不再保存其可执行正文。

| 门禁 | 最终执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | A1 明确一张空纵向行军便笺；B1 明确三件覆盖层及顺序；两段均排除文字、任务行、图标、工具条和 Button | `pass` |
| 每张输入的 inherit／ignore 职责与权威冲突 | 两段分别写明 Image 1／2／3 的职责、禁止继承内容，以及 V2 顶部无工具条与 Image 1 原型的裁决 | `pass` |
| 画布、格位、边距、方向、透视、尺度、光照与层序 | A1 为 `1024 × 1536` 单物件安全盒；B1 为 `1024 × 768` 三固定 cell；正面轻微俯视、左上暖光和覆盖层序明确 | `pass` |
| 逐对象形态、材料、边缘、状态与关系 | A1 定义顶部、连续中段、两侧叠页和撕裂底边；B1 逐件定义 focus／tracked／complete，且三者从属动态文字 | `pass` |
| 文字安全、裁切、拉伸、重复与接缝 | A1 固定四边 zone 与安静 stretch field；B1 focus 三段式中段、对象隔离与真实高密度排版关系明确 | `pass` |
| 美术 DNA、反模式、色键与最终自检 | 两段均包含香草时代手绘、暖赭／烟褐／暗酒红／深墨、纯 `#00FF00`、现代／暗黑／上古卷轴反模式和客观自检 | `pass` |

- 未知但执行必需的值：无。
- 去冗余结论：保留对象数、输入职责、固定尺寸、安全盒、V2 可见方向、
  stretch／seam、色键和反模式的高风险重复；不把会话历史或模拟像素写入
  执行正文。
- QT-A2 不属于本次完整性预检；当前树没有它的可执行 Prompt。

## 历史 Repair envelope 与计数

原 QT-A1／B1 各自最多五次实际 ImageGen 生成／修图，最坏合计 `10` 次；
只有返回图片或 provider 证据证明生成实际运行才计数。用户当前已终止两段
生产循环：A1 已耗尽，B1 在 `1/5` 后被暂停，旧授权的剩余次数不再有效。
QT-A2 保持 `0/5`、`scope-deferred`。

| 正文 | 固定上传 | 实际 ImageGen 上限 | 当前 | 最坏 |
|---|---|---:|---:|---:|
| `QT-A1 V1` | Image 1／2／3；同段前一次输出只可作冻结边界内 edit 输入 | `5` | `5/5 exhausted` | `5` |
| `QT-B1 V1` | Image 1／2／3；同段前一次输出只可作冻结边界内 edit 输入 | `5` | `1/5 user-stopped` | `5` |

历史合计为 `6/10` 次实际生图／修图；流程错误为 QT-A1 `2`、QT-B1 `1`。
恢复 B1 时必须新建版本与新预算，不能沿用旧剩余额度。

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

### 历史用户生产授权

- 日期：`2026-07-31`
- 授权正文：当前 QT-A1 V1 与 QT-B1 V1 完整执行正文，正文像素级内容未在
  授权后改写。
- 固定上传：每段 Image 1／2／3，SHA 与“美术基准继承”表一致。
- edit 边界：只允许同段前次输出作为额外输入，并且只修正上文冻结范围内的
  失败门禁。
- 调用预算：QT-A1 `0/5`、QT-B1 `0/5`，最坏合计 `10` 次实际
  ImageGen；无生成图且无 provider 生成证据的流程错误另表记录。
- 明确排除：QT-A2 继续暂缓；本授权不包含 source 晋级、runtime 导出或
  adapter 创建。
- 用户原文：“确认授权 QT-A1 V1 与 QT-B1 V1；允许每段上传固定 Image
  1/2/3，允许同段前次输出仅在冻结边界内作为 edit 输入；每段最多 5 次实际
  ImageGen 调用，最坏合计 10 次；流程错误不占生图额度；QT-A2 继续暂缓。”
- 当前覆盖决策：用户于 `2026-07-31` 暂停 QT-B1 三件覆盖层并选择大块
  tracker 背景；旧 B1 授权终止。

### 自主修复循环记录

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| A1 1/5 | `QT-A1 V1` / `2a5f74c`（official `55f8330`） | generate | fixed child session `019fb62d-a545-70f3-9ea1-10f1017bb806` | `generated/quests/QT/QT-A1/V1/attempt-01/QT-A1-V1.raw.png` / `f22dc61ea2762ca3ce54fa73436737c8ce19926c4e753149f5d42aa3cfdbbaea` | 组件合同：可见 bbox `[200,45,834,1473]`，不是约定 `[276,96,748,1440]`；原图精确 `#00FF00` 像素为 `0`，背景有 `6576` 个 RGB 值 | 保留单张行军便笺身份、正面透视、暖赭纸、侧／底叠页、撕裂底边与安静中心；以同段 raw 为 Image 4，只修复窄长安全盒、纯色背景和中心重复纹理 | `internal-rejected / repair-prepared` |
| A1 2/5 | `QT-A1 V1.r1` / `42bf38e`（official `92e408a`） | edit | fixed child session `019fb638-0608-7be3-b76c-889f2760d373` | `generated/quests/QT/QT-A1/V1/attempt-02/QT-A1-V1.raw.png` / `e4b6a258ffe4bbf82d4bd6386bf4323df4da983bbe04b8cd218071c94fb1429b` | 美术一致性：中心卷曲纤维被重绘为比 attempt 1 更均匀、更显眼的重复压花／壁纸纹；次要合同失败为 bbox `[291,83,755,1461]` 越出且原图精确 `#00FF00` 为 `0`、背景 `5991` 个 RGB 值 | 保留新的窄长比例、单纸结构和运行时重量；改变策略为保守 source-layout compositing，目标进一步内缩到 `[300,112,724,1408]`，只把中心降为宽缓 tonal variation | `internal-rejected / repair-prepared` |
| A1 3/5 | `QT-A1 V1.r2` / `43d53a1`（official `b4e2b2a`） | edit | fixed child session `019fb63d-2013-70d0-b8b8-465afbc1c61c` | `generated/quests/QT/QT-A1/V1/attempt-03/QT-A1-V1.raw.png` / `7f671feb1e66ebee89189813904c16586f32912999739ce213b5ddab955ebd51` | 美术一致性：压花／壁纸式微纹理继续覆盖完整中心；次要失败为 bbox `[290,77,752,1462]` 与纯色键 `0` exact／`6389` RGB | 不再编辑失败像素；attempt 4 从固定 Image 1／2／3 regenerate，保留冻结物件身份／Canvas／bbox／切片／反模式合同 | `internal-rejected / repair-prepared` |
| A1 4/5 | `QT-A1 V1.r3` / `fc14b70`（official `4d7e806`） | regenerate | fixed child session `019fb641-556a-77b0-bd27-e05a629a9fea` | `generated/quests/QT/QT-A1/V1/attempt-04/qt-a1-field-note-shell-v1.png` / `13aefd716b129fd2f6b629147b77c0033b8c9db6e3f3c1d71c2a96d7dd347474` | 组件合同：美术已恢复为宽缓纸面，但 bbox `[261,82,771,1454]` 越出外盒；技术色键仍为 `0` exact／`6218` RGB | 保留 attempt 4 整个纸张内部、粗厚轮廓、层页和宽缓纸面；最终 edit 只允许统一缩放／重定位到更保守内盒并替换背景 | `internal-rejected / repair-prepared` |
| A1 5/5 | `QT-A1 V1.r4` / `e90ecc7`（official `b4711b9`） | edit | fixed child session `019fb645-e305-7153-bb3e-86742d276bef` | `generated/quests/QT/QT-A1/V1/attempt-05/qt-a1-field-note-shell-v1.png` / `319e084802a44161663e39b7243abd178ef64115d46b8922957b21c57eb38415` | 美术一致性：最终 edit 未保持 attempt 4 的宽缓纸面，重新引入全幅卷曲压花；同时 bbox `[275,132,759,1445]` 与色键 `0` exact／`6929` RGB 仍失败 | 停止；保留 attempt 4 作为本机最佳美术证据、attempt 5 作为预算终态；不得 attempt 6、source 或 runtime | `candidate-rejected / repair-budget-exhausted` |
| B1 1/5 | `QT-B1 V1` / `87e8d64`（official `5064809`） | generate | fixed child session `019fb64e-9e36-7b93-8dbc-b572a13d5373` | `generated/quests/QT/QT-B1/V1/attempt-01/QT-B1-entry-feedback-overlays.png` / `ff6bf0af0642715894b6dcc7344fb3dd966b947ff6b56e3426197697af6c4bae` | 组件合同：等比归一化后 focus、tracked、complete 均越出各自 cell 并在审查裁切中触边；focus 同时为偏黄绿的高对比实色刷带，色键后形成亮绿边，不是从属文字的暖赭淡墨洗 | 用户认为真实排版表现很糟糕，三件覆盖层全部暂停；不再执行旧 V1.r1 | `scope-deferred / user-paused` |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `QT-A1 V1` / `a6a4c12`（official `afd0b1c`） | 无 provider session | 固定 CLI 的 `-i <FILE>...` 吞入末尾位置参数；返回 `Reading prompt from stdin... No prompt provided via stdin.`，无图片、result 或生成证据 | 在第三个输入后增加参数终止符 `--`，继续使用同一已提交正文与三张固定输入 | 不占生图额度；QT-A1 仍为 `0/5` |
| E2 | `QT-A1 V1.r1` / `8575821`（official `e05be00`） | 未启动 fixed child | 本地正文传输校验器只接受 `Create exactly` 开头，而已提交的完整修复正文以合法的 `Edit` 开头；返回 `authorized prompt extraction failed`，无上传、图片、session、result 或 provider 生成证据 | 只扩展本地校验器以接受 `Edit` 开头；正文、Image 1／2／3／4、修复边界与 `1/5` 计数不变 | 不占生图额度；以同一 V1.r1 重试 |
| B1-E1 | `QT-B1 V1.r1` / `4dd278e`（official `9722cb9`） | fixed child session `019fb659-7dae-7333-870a-24d4cb65f12f`，未调用 provider | 固定子进程误读仓库 wrapper 并准备递归启动另一层 `codex`／`npx`；在任何内置 `image_gen` 调用、provider result 或图片出现前主动中断 | 本地 runner 已补执行隔离句；随后用户暂停整段，未重试 | 不占生图额度；QT-B1 保持 `1/5 scope-deferred` |

### QT-A1 V1.r1 — 完整修复正文

状态：`executed / internal-rejected / 2/5`

固定上传：Image 1、Image 2、Image 3，以及同段 QT-A1 V1 attempt 1 raw
作为 Image 4。Image 4 只用于有意保留已经通过的纸张身份、透视、材料、综合色
和撕裂／叠页关系；不得保留其过宽过高的 bbox、非纯色色键或中心重复纹理。

> Edit the existing source in Image 4 into exactly one empty, front-facing, narrow
> vertical field-note paper shell for a Turtle WoW 1.18.1 addon. This is a strict
> source-master repair for deterministic nine-slice and layered-page-edge export. It is
> not a screenshot, a fixed runtime background, a new composition, or a request for
> additional objects.
>
> Preserve from Image 4 the already-correct object identity and art: one upright
> guild-expedition field note; nearly straight-on view with only slight internal
> top-down perspective; warm-ochre parchment; thick circa-2004 vanilla World of
> Warcraft hand-painted 2D light, midtone, and shadow planes; two or three subordinate
> offset page layers along only the outer side and lower edges; a restrained hand-cut
> top; and one natural restrained torn bottom. Preserve the same warm upper-left light,
> smoke-brown wear, deep-umber contour, handmade asymmetry, tangible page weight, and
> calm central reading field. Do not redesign these correct regions into a different
> paper, scroll, book, panel, or modern UI object.
>
> Repair only the failed geometry, background, and stretch-field cleanliness. Canvas
> must remain exactly 1024 × 1536 pixels. The complete visible paper object, including
> all layered side and lower edges, must now fit inside x=276..748 and y=96..1440. No
> visible paper, antialiasing, shadow, fringe, or wear may extend outside that box. Make
> the result visibly narrower and taller in proportion than Image 4 by recomposing the
> paper anatomy inside this box; do not merely squash a wide texture horizontally. Keep
> the object centered and upright. Everything outside the box, and every pixel outside
> the visible object within the box, must be exactly one digital flat RGB color
> #00FF00. Use no near-green variation, gradient, texture, noise, glow, cast shadow,
> vignette, color-management drift, second object, labels, guides, text, or swatches in
> the background.
>
> The repaired object must remain coherent when assembled at 100% UI scale from
> 130..330 UI pixels wide and from a short empty tracker through as many as twenty-five
> dynamic entries. At representative maximum density it must quietly support about ten
> quest titles and seventeen objective lines on one uninterrupted paper surface,
> although this source contains no text, rows, icons, or controls. The visible paper
> begins directly at its slightly irregular upper edge. Do not attach or imply a
> toolbar, leather header strap, emblem, control rail, compass, quill, or any of the
> seven deferred provider Buttons.
>
> Keep the paper anatomy physically plausible: one continuous top sheet with the long
> middle flat, calm, low contrast, and directionally neutral; two or three thin
> underlying sheets visible only as offset thickness along the outer side edges and
> lower edge; no regular frame around the reading field; no curled or rolled top; and
> no independent floating scraps. Keep left and right edge anatomy compatible enough
> for later nine-slice extraction while retaining restrained hand-painted
> irregularity. The layered edges must never become a book cover, leather border,
> bevelled card frame, wooden support, or metal plaque.
>
> Preserve the slicing contract inside the repaired paper object: all top-edge wear is
> confined to the top 96 source pixels of the object; all torn-footer anatomy is
> confined to the bottom 128; all side thickness and edge wear are confined to the
> leftmost and rightmost 64 pixels. The remaining large central rectangle must be one
> calm stretch field. Replace Image 4's recurring small curling fiber pattern with
> broad, quiet, hand-painted tonal variation that has no repeated wallpaper motif, no
> directional clump, no focal stain, emblem, crease crossing, hole, rivet, ornament,
> hard cast shadow, seam, or feature that would reveal horizontal or vertical
> stretching.
>
> Input roles and authority: use Image 1 as the highest visual authority for the
> vertical guild-expedition field-note identity, layered paper silhouette and weight,
> warm parchment palette, and hand-painted age, while ignoring its baked text, example
> quest content, toolbar, strap, emblem, icons, and fixed-height composition. Use Image
> 2 only for shared dossier material thickness, circa-2004 vanilla World of Warcraft
> hand-painted 2D brushwork, warm upper-left light, thick slightly irregular contour,
> readable light/mid/shadow planes, muted warm ochre, smoke-brown wear, deep umber, and
> restrained old-wine/aged-brass relationships; ignore its double-page book geometry,
> spine, binding, rewards, and Buttons. Use Image 3 only to understand the real narrow
> right-side placement, three-level text hierarchy, and density of roughly ten quests
> and seventeen objectives; inherit none of its transparent black backdrop, typography,
> colored symbols, node icons, or modern styling. Use Image 4 only as the target editing
> canvas and to preserve the correct paper identity, perspective, material,
> light, layered-edge relationship, and torn-bottom character named above; explicitly
> replace its oversize bbox, impure green background, and repetitive central texture.
>
> Do not create a double-page book, book spine, chat book, stone tablet, wooden plank,
> metal plaque, Diablo-style altar, Skyrim menu, modern card, transparent black HUD,
> rolled scroll, per-entry band, button, icon, text, quest row, objective, percentage,
> seal, compass, quill, timer, header strap, toolbar, emblem, decorative border, or any
> fourth visual object.
>
> Final self-check: exactly one empty narrow vertical parchment object; exact 1024 ×
> 1536 canvas; the entire object fits inside x=276..748 and y=96..1440; every
> non-object pixel is uniform exact #00FF00; paper starts directly at its restrained
> irregular top; central field is calm and non-repeating; torn bottom is restrained;
> layered thickness appears only at side and lower edges; vanilla-WoW hand-painted
> weight is preserved from Image 4; zero text, rows, toolbar, Buttons, or baked dynamic
> content.

### QT-A1 V1.r2 — 完整修复正文

状态：`executed / internal-rejected / 3/5`

固定上传：Image 1、Image 2、Image 3，以及同段 QT-A1 V1.r1 attempt 2 raw
作为 Image 4。因为 attempt 1／2 连续出现 source 安全盒与色键失败，本次改变
修复策略：不再要求广泛重构纸张，而是对已正确的窄长物件做保守的
source-layout compositing、进一步内缩和背景替换。

> Edit Image 4 into exactly one empty, front-facing, narrow vertical field-note paper
> shell source for a Turtle WoW 1.18.1 addon. Perform a restrained source-layout
> correction, not a broad redesign. The result is a source master for deterministic
> nine-slice and layered-page-edge runtime textures; it is not a screenshot, a fixed
> runtime background, a complete tracker, or a new UI composition.
>
> Preserve the already-correct semantic and visual identity from Image 4: one upright
> guild-expedition field note; nearly straight-on view with only slight internal
> top-down perspective; a single continuous warm-ochre top sheet; two or three thin,
> subordinate offset sheets visible only at the outer side and lower edges; a sturdy
> restrained hand-cut top; one natural restrained torn bottom; smoke-brown wear;
> deep-umber contour; warm upper-left light; and thick circa-2004 vanilla World of
> Warcraft hand-painted 2D light, midtone, and shadow planes. Preserve the narrow,
> tall proportion achieved in Image 4 and its readable paper weight. Do not turn it
> into a scroll, book, framed card, panel, plaque, or different paper object.
>
> Canvas must be exactly 1024 × 1536 pixels. Reposition and uniformly scale the complete
> paper assembly from Image 4 so every visible paper pixel, underlying page edge,
> antialiasing pixel, shadow, fringe, and wear mark fits entirely inside the conservative
> inner target box x=300..724 and y=112..1408. This inner target is deliberately smaller
> than the frozen outer contract box x=276..748 and y=96..1440; do not touch or cross
> either box. Keep the paper centered and upright. Preserve its aspect ratio and
> anatomy while fitting it; do not stretch, squeeze, mirror, rotate, crop, or cut off
> the top, sides, layers, or torn bottom.
>
> Replace the complete background with one digitally flat, perfectly uniform RGB
> #00FF00 field. Every non-object pixel on the 1024 × 1536 canvas must have the identical
> value R=0, G=255, B=0. There must be no near-green variation, color-management drift,
> gradient, texture, noise, glow, cast shadow outside the object, vignette, halo, second
> object, label, text, guide, swatch, or compression contamination. Keep a clean green
> moat between the whole paper assembly and all four sides of the canvas.
>
> The paper must remain coherent when later assembled at 100% UI scale across the real
> provider width range of 130..330 UI pixels and from a short tracker through as many as
> twenty-five dynamic entries. At representative maximum density it must quietly carry
> about ten quest titles and seventeen objective lines on one uninterrupted reading
> surface, but this source contains no text, rows, icons, or controls. The paper begins
> directly at its slightly irregular upper edge. Do not attach or imply a toolbar,
> leather header strap, emblem, control rail, compass, quill, or any of the seven
> deferred provider Buttons.
>
> Keep one physically plausible continuous sheet assembly. Underlying layers appear
> only as restrained thickness at the outer sides and lower edge, never as a regular
> frame. The top does not curl or roll. No page is detached or floating. The left and
> right edge anatomy remains compatible for later nine-slice extraction without
> becoming mechanically mirrored. All materials share the same viewpoint, scale,
> upper-left light, contact shadows, and hand-painted resolution.
>
> Maintain the slicing contract within the fitted object: all top-edge wear stays in the
> top 96 source pixels of the paper object; all torn-footer anatomy stays in its bottom
> 128; all side thickness and edge wear stay in its leftmost and rightmost 64 pixels.
> The remaining central rectangle is a calm stretch field. Reduce Image 4's repeated
> small curling fiber pattern to broad, quiet, low-contrast hand-painted tonal variation.
> The stretch field has no wallpaper repetition, directional clump, focal stain, emblem,
> crease crossing, hole, rivet, ornament, hard cast shadow, seam, or feature that would
> reveal vertical or horizontal stretching.
>
> Input roles and authority: Image 1 remains the highest visual authority for the
> vertical guild-expedition field-note identity, layered paper silhouette and weight,
> warm parchment palette, and hand-painted age; ignore its baked text, example quest
> content, toolbar, strap, emblem, icons, and fixed-height composition. Use Image 2 only
> for shared dossier material thickness, circa-2004 vanilla World of Warcraft
> hand-painted 2D brushwork, warm upper-left light, thick slightly irregular contour,
> readable light/mid/shadow planes, muted warm ochre, smoke-brown wear, deep umber, and
> restrained old-wine/aged-brass relationships; ignore its double-page book geometry,
> spine, binding, rewards, and Buttons. Use Image 3 only to understand the real narrow
> right-side placement, three-level text hierarchy, and density of roughly ten quests
> and seventeen objectives; inherit none of its transparent black backdrop, typography,
> colored symbols, node icons, or modern styling. Use Image 4 as the only editing target
> and preserve its correct narrow paper identity, viewpoint, material, light,
> layered-edge relationship, and torn-bottom character. Correct its remaining outer-box
> overflow, impure green field, and repetitive central micro-pattern without importing
> any new object.
>
> Do not create a double-page book, spine, chat book, stone tablet, wooden plank, metal
> plaque, Diablo-style altar, Skyrim menu, modern card, transparent black HUD, rolled
> scroll, per-entry band, button, icon, text, quest row, objective, percentage, seal,
> compass, quill, timer, header strap, toolbar, emblem, decorative border, or any fourth
> visual object.
>
> Final self-check: exactly one empty narrow vertical parchment assembly on an exact
> 1024 × 1536 canvas; every visible object pixel lies inside x=300..724 and y=112..1408
> and therefore inside the frozen outer box; all remaining pixels are identical exact
> RGB #00FF00; one calm non-repeating stretch field; restrained hand-cut top and torn
> bottom; layered thickness only at side and lower edges; preserved vanilla-WoW
> hand-painted weight; zero text, rows, toolbar, Buttons, or baked dynamic content.

### QT-A1 V1.r3 — 完整修复正文

状态：`executed / internal-rejected / 4/5`

固定上传：只使用原授权的 Image 1、Image 2、Image 3。attempt 2／3 连续 edit
保留了失败的压花式微纹理，因此本次不上传任何同段候选，改为从锁定权威重新
生成；对象、Canvas、安全盒、切片、色键和禁止内容均不改变。

> Create exactly one empty, front-facing, narrow vertical field-note paper shell source
> for a Turtle WoW 1.18.1 addon. Generate a fresh source from Images 1, 2, and 3; do not
> reproduce or infer any previous candidate. This is a source master for deterministic
> nine-slice and layered-page-edge runtime textures, not a screenshot, not a fixed
> runtime background, and not a complete tracker.
>
> Canvas: exactly 1024 × 1536 pixels. Place one and only one complete upright paper
> assembly, centered, wholly inside x=300..724 and y=112..1408. This conservative inner
> box must keep every visible top-sheet pixel, underlying page edge, antialiasing pixel,
> contact shadow, fringe, and wear mark inside the frozen outer contract box
> x=276..748 and y=96..1440. Do not crop any part of the object. Everything outside the
> visible paper assembly must be one flat, perfectly uniform digital RGB #00FF00 field:
> every background pixel exactly R=0, G=255, B=0, with no near-green variation,
> gradient, noise, texture, glow, vignette, shadow outside the object, halo, labels,
> guides, text, swatches, compression contamination, or second object.
>
> Object identity and anatomy: one tall, narrow guild-expedition field note cut from the
> same formal dossier system as the quest log. View it nearly straight-on with only a
> slight internal top-down perspective. The visible top sheet begins directly at a
> sturdy, restrained hand-cut irregular upper edge; it does not curl, roll, or carry a
> header. The long middle is one uninterrupted warm-ochre parchment reading surface.
> The bottom ends in one natural restrained torn edge. Show two or three thin,
> subordinate offset sheets only along the outer side edges and lower edge to create
> tangible page thickness. Those layers never surround the reading field as a regular
> frame and never become leather, wood, or metal. Keep left and right edge anatomy
> compatible for later nine-slice extraction while retaining slight handmade
> asymmetry.
>
> Art language: unmistakable circa-2004 vanilla World of Warcraft hand-painted 2D
> bitmap art. Use a thick, slightly irregular deep-umber contour; broad readable
> light/midtone/shadow planes; warm upper-left light; smoke-brown wear; muted
> warm-ochre paper; restrained old-wine accents only where naturally inherited from the
> dossier family; tangible contact shadows between paper layers; and low-resolution-
> friendly shapes. The result must feel heavy, durable, handmade, and used on a long
> Azeroth expedition. It must not look photorealistic, PBR, procedurally embossed,
> digitally airbrushed, flat-modern, or like a brown website card.
>
> The central stretch field is the highest-risk region. Keep it broad, calm, low
> contrast, directionally neutral, and visually quiet enough for roughly ten quest
> titles and seventeen objective lines at representative maximum density. Paint only
> large soft tonal clouds and sparse irregular fibers. Do not place any repeated
> curling line, arabesque, rosette, embossing, filigree, maze, wallpaper grain, stamped
> motif, evenly distributed micro-crackle, or other high-frequency pattern anywhere in
> the central field. No repeated unit or directional feature smaller than 24 source
> pixels may cover the reading surface. There is no focal stain, emblem, crease
> crossing, hole, rivet, ornament, hard cast shadow, seam, or mark that would reveal
> vertical or horizontal stretching.
>
> Preserve the slicing contract inside the paper object. Confine every top-edge wear
> feature to the top 96 source pixels of the object. Confine all torn-footer anatomy to
> its bottom 128 pixels. Confine all side thickness and edge wear to its leftmost and
> rightmost 64 pixels. The remaining center must support horizontal and vertical
> stretching without a visible seam, repeated rhythm, directional fiber clump, or
> lighting discontinuity.
>
> Runtime relationship: the assembled shell must remain coherent at 100% UI scale
> across the real pfQuest provider width range of 130..330 UI pixels and from a short
> tracker through as many as twenty-five dynamic entries. The paper itself begins at
> the tracker upper edge. It contains no fixed task row and no task-mode-specific art,
> so the same shell supports QUEST_TRACKING, DATABASE_TRACKING, and GIVER_TRACKING.
> The source contains zero text, titles, objectives, levels, percentages, node icons,
> interaction feedback, controls, or empty-state messages.
>
> Input roles and authority: use Image 1 as the highest visual authority for the
> vertical guild-expedition field-note identity, layered page silhouette and weight,
> warm parchment palette, and hand-painted age. Explicitly ignore Image 1's baked text,
> example quest content, toolbar, leather strap, rivets, compass/quill emblem, icons,
> and fixed-height composition; all of those belong outside QT-A1. Use Image 2 only for
> shared dossier material thickness, circa-2004 vanilla World of Warcraft hand-painted
> 2D brushwork, warm upper-left light, thick irregular contour, broad readable tonal
> planes, muted ochre, smoke-brown wear, deep umber, and restrained old-wine/aged-brass
> color relationships. Ignore Image 2's double-page book, central binding, spine,
> rewards, list rows, and Buttons. Use Image 3 only to understand the real narrow
> right-side placement, three-level dynamic text hierarchy, and density of roughly ten
> quests and seventeen objectives. Inherit none of Image 3's transparent black
> backdrop, typography, bright colored symbols, node icons, current focus bar, or
> modern styling.
>
> Do not create a double-page book, book spine, chat book, rolled scroll, stone tablet,
> wooden plank, metal plaque, Diablo-style altar, Skyrim menu, modern card,
> transparent black HUD, per-entry band, decorative frame, text, number, percentage,
> objective bullet, dynamic node icon, focus wash, tracked mark, complete check,
> expand/collapse control, timer, seal, compass, quill, header strap, toolbar, emblem,
> Button, or any second visual object.
>
> Final self-check: exactly one fresh empty narrow vertical parchment assembly; exact
> 1024 × 1536 canvas; the complete visible object remains inside x=300..724 and
> y=112..1408; every remaining pixel is identical exact RGB #00FF00; paper starts
> directly at its restrained irregular top; one broad calm central stretch field with
> no repeated micro-pattern; restrained torn bottom; layered thickness only at side and
> lower edges; clear vanilla-WoW hand-painted weight; zero text, rows, toolbar, Buttons,
> or baked dynamic content.

### QT-A1 V1.r4 — 完整修复正文

状态：`executed / candidate-rejected / repair-budget-exhausted / 5/5`

固定上传：Image 1、Image 2、Image 3，以及同段 QT-A1 V1.r3 attempt 4 raw
作为 Image 4。Image 4 的语义、物理、透视、层序、美术与运行时排版均保留；
最终 edit 只允许整体等比缩放／重定位、外部阴影收敛和纯绿色背景替换，不得
重绘纸张内部。本次是 QT-A1 的第 `5/5` 次实际调用上限。

> Edit Image 4 into exactly one empty, front-facing, narrow vertical field-note paper
> shell source for a Turtle WoW 1.18.1 addon. This is a final strict source-layout and
> background repair. Preserve the complete paper art from Image 4; do not redesign,
> regenerate, repaint, retexture, simplify, embellish, or replace its paper object.
> The result remains a source master for deterministic nine-slice and layered-page-edge
> runtime textures, not a screenshot, fixed runtime background, or complete tracker.
>
> Preserve from Image 4 exactly one upright guild-expedition field note, its nearly
> straight-on slight internal top-down view, its single continuous warm-ochre top sheet,
> its sturdy restrained hand-cut upper edge, its broad quiet central paper field, its
> one restrained torn bottom, and its two or three thin subordinate offset sheets
> visible only along the outer side and lower edges. Preserve the same thick slightly
> irregular deep-umber contour, broad light/midtone/shadow planes, warm upper-left
> light, smoke-brown wear, contact shadows, handmade asymmetry, and circa-2004 vanilla
> World of Warcraft hand-painted 2D bitmap weight. Preserve the absence of repeated
> embossing in the center. Do not alter any internal stain, tear, edge, page-layer
> relationship, light direction, color balance, brushwork, or object identity.
>
> Canvas must remain exactly 1024 × 1536 pixels. Treat the complete visible paper
> assembly from Image 4 as one locked group. Uniformly scale that group down if needed
> and translate it without cropping so every visible paper pixel, underlying layer,
> antialiasing pixel, external contact shadow, fringe, and wear mark fits entirely
> inside x=288..736 and y=140..1396. Preserve the object's aspect ratio. Do not stretch,
> squeeze, mirror, rotate, shear, crop, cut off, or independently move any paper layer.
> Keep the locked group centered and upright. The entire locked group must also remain
> inside the frozen outer contract box x=276..748 and y=96..1440 with a clean buffer on
> all four sides.
>
> Replace every pixel outside the locked paper group with one digitally flat,
> perfectly uniform RGB #00FF00 field. Every non-object pixel on the exact 1024 × 1536
> canvas must be identical R=0, G=255, B=0. Do not preserve Image 4's near-green
> variation. There must be no gradient, texture, noise, color-management drift, glow,
> vignette, halo, shadow extending beyond the fitted object, label, guide, text, swatch,
> compression contamination, or second object. The green moat around the paper must be
> clean and uninterrupted.
>
> Keep the slicing and runtime contract unchanged. All top-edge wear remains in the top
> 96 source pixels of the paper object; all torn-footer anatomy remains in its bottom
> 128; all side thickness and edge wear remain in its leftmost and rightmost 64 pixels.
> The remaining central rectangle remains broad, calm, low contrast, directionally
> neutral, and free of repeated curling lines, arabesques, rosettes, embossing,
> wallpaper grain, stamped motifs, focal stains, crossing creases, holes, rivets,
> ornaments, hard shadows, or seams. It must support horizontal and vertical stretch.
>
> At 100% UI scale the later assembly must remain coherent across the real pfQuest
> width range of 130..330 UI pixels and from a short tracker through as many as
> twenty-five dynamic entries. It must quietly support roughly ten quest titles and
> seventeen objective lines on one uninterrupted paper surface. The source contains no
> text, title, objective, level, percentage, node icon, focus wash, tracked mark,
> complete check, interaction state, or control. The visible paper begins directly at
> its upper edge, with no toolbar, leather strap, emblem, control rail, compass, quill,
> or deferred provider Button.
>
> Input roles and authority: Image 1 remains the highest visual authority for the
> vertical field-note identity, layered page weight, palette, and age; ignore its baked
> content, toolbar, strap, emblem, icons, and fixed-height composition. Image 2 only
> confirms the dossier family's circa-2004 vanilla-WoW hand-painted material thickness,
> warm upper-left light, broad tonal planes, muted ochre, smoke-brown, deep umber, and
> restrained old-wine/aged-brass relationships; ignore its double-page book, binding,
> rewards, and Buttons. Image 3 only confirms narrow right-side placement, dynamic
> three-level text density, and the need for one continuous surface; inherit none of
> its black backdrop, typography, symbols, icons, or current styling. Image 4 is the
> sole editing target and the authority for every paper pixel; only its group placement,
> group scale, external shadow extent, and background may change.
>
> Do not create a double-page book, spine, chat book, rolled scroll, stone tablet,
> wooden plank, metal plaque, altar, Skyrim menu, modern card, transparent HUD,
> decorative frame, per-entry band, text, number, icon, focus wash, tracked mark,
> complete check, timer, seal, compass, quill, strap, toolbar, emblem, Button, or any
> second visual object.
>
> Final self-check: exactly one locked paper assembly from Image 4; exact 1024 × 1536
> canvas; every visible object and shadow pixel inside x=288..736 and y=140..1396;
> identical exact RGB #00FF00 everywhere else; original aspect ratio and all paper
> pixels preserved; one calm non-repeating stretch field; restrained top and torn
> bottom; layers only at side and lower edges; clear vanilla-WoW hand-painted weight;
> zero text, rows, toolbar, Buttons, or baked dynamic content.

## 候选审查与真实排版预演

每次 countable output 先检查：精确对象数、语义、纯色背景、连通域、bbox、
对象间隔、静态切片 seam、材料／香草语言和禁止内容。语义失败优先于尺寸或
色键；不得仅凭透明化成功晋级。

每个达到可预演门禁的候选都必须使用“真实排版 + 新 UI”做确定性模拟，而不是
只展示孤立资产。历史 `130 × 180`／`230 × 500`／`330 × 865`／
`230 × 500` 是人工固定容量画布，已在 `2026-07-31` 展示区域复核中作废为
精确实例证据。默认 `12px` provider 公式的当前必查实例为：

- `200 × 16`：空 tracker，验证工具条和九宫格最小高度；
- `130 × 104`：两任务／四目标；
- `230 × 256`：六任务／十目标；
- `330 × 420`：十任务／十七目标；
- `330 × 516`：provider 上限二十五任务、目标折叠；
- `230 × 136`：六条 `DATABASE_TRACKING`，无 objective FontString；
- `230 × 136`：六条 `GIVER_TRACKING`，无 objective FontString；
- 动态文字、目标、百分比和节点图标使用真实 pfQuest 层级重新排版；
- 预演只装配 QT-A1／B1 候选，不虚构 QT-A2；真实 `16px` 工具条与七个
  provider Button 必须以当前 provider fallback 可见，并明确标记为
  `scope-deferred / non-authoritative`，未来恢复其视觉设计时另做模拟；
- 同时保留一张旧 tracker 与新 tracker 的 100% UI 像素对比，但旧图只作
  结构参照。

通过 P3 内审仍不等于接受。只有用户明确接受具体 source 后才能进入 P4；
只有已接受 source、确定性切片／UV manifest 和 adapter 静态测试完成后才可
进入 P5；Turtle WoW `1.18.1` 实机证据是 P6 的唯一依据。

## 执行记录

- `QT-SIM V1` 在本地完成后被用户调整优先级而替代；没有触发正式生产。
- `QT-SIM V2` 已使用本地确定性几何 renderer 完成；ImageGen `0/0`，无上传、
  provider session 或生成流程错误。主图与局部查看路径、SHA 见模拟章节。
- 用户于 `2026-07-31` 以“继续”确认 `QT-SIM V2` 的 tracker 主体可见方向；
  确认条款已写回 QT-A1／B1 最终正文，模拟像素没有进入任何生产输入。
- 用户于 `2026-07-31` 明确授权当前 QT-A1／B1 V1 正文、固定输入、同段
  edit 边界和每段五次上限；授权后正文未改写。
- QT-A1 首次传输发生一次无生成证据的 CLI 参数错误：授权正文 SHA-256
  `3adadf4655841d25528e7755e5f9bcadf669ca2622113f5b79018c3b8f4ea0c7`、
  `4444` bytes 已正确提取，但 `-i` 的可变参数吞入正文，固定 child 返回
  `No prompt provided via stdin.`。没有图片、provider result 或 session，
  因此作为 E1 单列且不计入 `0/5`；针对性修复只增加 `--` 参数终止符。
- QT-A1 attempt 1 使用同一授权正文与固定 Image 1／2／3 成功触发实际
  ImageGen；fixed child session 为
  `019fb62d-a545-70f3-9ea1-10f1017bb806`。child 的只读 workspace 未复制
  文件到指定目录，但已在固定会话 generated-images 目录返回一张完整图片；
  该原始文件随后未经变换复制为
  `generated/quests/QT/QT-A1/V1/attempt-01/QT-A1-V1.raw.png`。该保存位置
  恢复不新增调用，也不改变本次 `1/5` 计数。
- attempt 1 raw：`1024 × 1536 RGB`，SHA-256
  `f22dc61ea2762ca3ce54fa73436737c8ce19926c4e753149f5d42aa3cfdbbaea`。
  固定 executor 没有报告 revised prompt。
- V1.r1 首次本地传输在启动 fixed child 前被正文校验器拒绝：校验器只接受
  `Create exactly`，而完整修复正文以 `Edit` 开头；无上传、图片、session、
  result 或 provider 证据，作为 E2 单列且不计额度。针对性修复只放宽本地
  开头校验，V1.r1 正文与四张输入不变。
- 确定性审查工具：
  `tools/review_quest_tracker_candidate_v1.py`；使用 Conda `py312`／Python
  `3.12.12`，不调用 ImageGen。透明审查稿 SHA-256
  `4061c106aac1c6b9930f3e0d5aa89e60e5e7916e284564a77ab8da9424b59f9b`。
- attempt 1 的四张 `100%` 候选真实排版预演：
  - `130 × 180 QUEST_TRACKING`：
    `generated/quests/QT/QT-A1/V1/attempt-01/review/real-layout-short-130x180.png` /
    `b00ddbb9038d95b70ffc83e5d6bf2224baf01ef92f351027c3900dec2529637c`
  - `230 × 500 QUEST_TRACKING`：
    `generated/quests/QT/QT-A1/V1/attempt-01/review/real-layout-quest-230x500.png` /
    `d27fa05a3a8ebdc115458f959850e6c1aeca8d70f2fe56f6ae6462e1d453c941`
  - `330 × 865 QUEST_TRACKING`，十任务／十七目标：
    `generated/quests/QT/QT-A1/V1/attempt-01/review/real-layout-dense-330x865.png` /
    `9121f5751e644f2c5fbdded4e314a37d35a64367cc64ee290b6567b77e45484e`
  - `230 × 500 DATABASE_TRACKING`：
    `generated/quests/QT/QT-A1/V1/attempt-01/review/real-layout-database-230x500.png` /
    `6e2c4570c658a1459bd48d4e0afcc7844626267ca85efcd0833d8ab011919106`
  - 四景总览：
    `generated/quests/QT/QT-A1/V1/attempt-01/review/real-layout-overview.png` /
    `d89bfaaa7eee96ad2f4a5f2a31dbd40e20f0517224f98c057c0170f0a0a856aa`
- 上述预演只使用 A1 候选纸面；动态文字和节点按真实 pfQuest 层级重排。
  `16px` 工具条使用仓库内当前七枚 provider TGA，是
  `scope-deferred / non-authoritative` fallback；focus 仍是当前 provider
  fallback，world／相邻 UI 为确定性几何 fallback，均不代表 QT-A2／B1
  已完成。
- QT-A1 attempt 2 使用完整 `V1.r1`、固定 Image 1／2／3 和同段 attempt 1
  raw Image 4 执行 edit。传输正文 SHA-256
  `6f074aab0a8e0783ccd6e45b29989d94cc9ef064b69af74331e13eb8c2eba854`、
  `5928` bytes；fixed child session
  `019fb638-0608-7be3-b76c-889f2760d373`。输出直接保存为
  `generated/quests/QT/QT-A1/V1/attempt-02/QT-A1-V1.raw.png`，
  `1024 × 1536 RGB`，SHA-256
  `e4b6a258ffe4bbf82d4bd6386bf4323df4da983bbe04b8cd218071c94fb1429b`；
  executor 未报告 revised prompt。
- attempt 2 透明审查稿：
  `generated/quests/QT/QT-A1/V1/attempt-02/review/QT-A1.transparent-review.png` /
  `6de8d691e992fdbe2384da999ae3d9e4419f47e9b61a526f33296a938187d342`。
  四张 `100%` 真实排版 SHA 分别为 `130 × 180`
  `a1c4cc7ec51cb4d3e2415a4bbb6bbb2e5f820f851b810e4cb973835ce3a02e39`、
  `230 × 500 QUEST_TRACKING`
  `3933b9f5c91cd6d302851ae348149bc04a80e9d327ec973e54b27e045cefdd5b`、
  `330 × 865`
  `4b27d23b1db3a663ad172cc0a4752a5327a9d2a70e4be15144115b32dc401b9b`
  和 `230 × 500 DATABASE_TRACKING`
  `19fdc0ab35d75c4c5911b6e799df13a7f63cfe57fc433c91aeb415cc9e5154da`；
  总览 SHA
  `573cc78c5a7f574746bf4b7fcbcac2837adc5236827bfa1ef1832611019ad907`。
  权威／非权威范围与 attempt 1 相同。
- QT-A1 attempt 3 使用完整 `V1.r2`、固定 Image 1／2／3 与同段 attempt 2
  raw Image 4 执行 edit。传输正文 SHA-256
  `860f1e5de941f4b3729376976f85a89a49c2a72e28d7666ae3681b7e6b12ad5b`、
  `6106` bytes；fixed child session
  `019fb63d-2013-70d0-b8b8-465afbc1c61c`。raw 为
  `generated/quests/QT/QT-A1/V1/attempt-03/QT-A1-V1.raw.png`，
  `1024 × 1536 RGB`，SHA-256
  `7f671feb1e66ebee89189813904c16586f32912999739ce213b5ddab955ebd51`；
  executor 未报告 revised prompt。
- attempt 3 透明审查稿 SHA-256
  `a3d1102e8536d43e035b5ed506d0330c4b059c7ed1b6800e265bb6b14f8fd7be`。
  四张 `100%` 真实排版 SHA 分别为 `130 × 180`
  `0c51fc47e05f90361f26bfb103eb9361ee132c501ca31ece97f68b3daa5a9f1e`、
  `230 × 500 QUEST_TRACKING`
  `22fa334b71d7f4bc307fb42ac6f7209c594592970430c3de3863c9d090e45f4a`、
  `330 × 865`
  `83b2852fa6cf5af333989cfaf6ffafbb5642fe06e5888be02f832e9800c023e5`
  和 `230 × 500 DATABASE_TRACKING`
  `b0fcc433baa4bd7ad32cc84f7e0563ced162a75b417a2dd8a2a6ae377d9293e8`；
  总览 SHA
  `450a2d3c1d8c9546bbd9686c6dbb61a098c6f21790a2ba8b05ff3e01f675ad12`。
- QT-A1 attempt 4 使用完整 `V1.r3` 和固定 Image 1／2／3 regenerate，
  未上传失败候选。传输正文 SHA-256
  `ae44cac878cfd66ab7cff20124719641e5e17ed6880f75ef33f73d5b8f0d90e8`、
  `6414` bytes；fixed child session
  `019fb641-556a-77b0-bd27-e05a629a9fea`。raw 为
  `generated/quests/QT/QT-A1/V1/attempt-04/qt-a1-field-note-shell-v1.png`，
  `1024 × 1536 RGB`，SHA-256
  `13aefd716b129fd2f6b629147b77c0033b8c9db6e3f3c1d71c2a96d7dd347474`；
  executor 未报告 revised prompt。
- attempt 4 透明审查稿 SHA-256
  `a9d700cd01f26535ae2035bfa3d8c2cedd7337bfb47d3fa9494ba592d259c59b`。
  四张 `100%` 真实排版 SHA 分别为 `130 × 180`
  `856946bf514f4608f1d9a7c714f3cd50a05406af2aae92a457e65c1b79ba3d18`、
  `230 × 500 QUEST_TRACKING`
  `5982bf0ee051c373127703ff1a0e5de8a828d2793e02db3c426d85f43d5e9fa8`、
  `330 × 865`
  `db1b42768a2af2b96cb94b13dcabf94aefbd46695f00d521d639755c58b7c9eb`
  和 `230 × 500 DATABASE_TRACKING`
  `2801353c7224a8987f87591139622d8a30297c0672e16d2e6ba1547b78c61e94`；
  总览 SHA
  `925fac76a736bc0649f2f7c2d5045860bb8eabbcdd541438d1d073d02b111679`。
- QT-A1 attempt 5 使用完整 `V1.r4`、固定 Image 1／2／3 与 attempt 4 raw
  Image 4 执行最终 edit。传输正文 SHA-256
  `a27af6db9f6aa99a3ce626f71721eb41626b83d6d8d546b90e3f85c8c857e77e`、
  `5446` bytes；fixed child session
  `019fb645-e305-7153-bb3e-86742d276bef`。raw 为
  `generated/quests/QT/QT-A1/V1/attempt-05/qt-a1-field-note-shell-v1.png`，
  `1024 × 1536 RGB`，SHA-256
  `319e084802a44161663e39b7243abd178ef64115d46b8922957b21c57eb38415`；
  executor 未报告 revised prompt。
- attempt 5 透明审查稿 SHA-256
  `0563ac5b310d2173db9758da36da1338dde6b8aeb42195f5729472a09fe41a3a`。
  四张 `100%` 真实排版 SHA 分别为 `130 × 180`
  `84dad770df289a538ffa95641f0ec1f1a1ff0cbf4d451121f3b360d0c34b7edb`、
  `230 × 500 QUEST_TRACKING`
  `ac818f2880a46a27825d507ae48d5ca566be1aa2bef95858541cc9d8f0ce5813`、
  `330 × 865`
  `5c98572eed2bac5d1d48f585f492e27e7c73abae13782b8c69a87f5fd31a7230`
  和 `230 × 500 DATABASE_TRACKING`
  `c9ece1d6f928a051d765d7a96243ca94c9bfc7d4eb5c0faad37186186c105d1b`；
  总览 SHA
  `9165eb49a93d162e38a78a57075cf86bd124f8d401c6fce41d3e869a35c9ccff`。
- 实际生图：QT-A1 `5/5`、QT-B1 `1/5`；活动累计 `6/10`；QT-A2
  `0/5 scope-deferred`。
- 流程错误：QT-A1 `2`、QT-B1 `1`；QT-A2 无活动流程。
- 当前终态：QT-A1 raw 生成循环仍为
  `candidate-rejected / repair-budget-exhausted`，但用户随后明确选择大块
  背景，attempt 4 的确定性色键 RGBA 已按临时合同例外晋级并导出为
  `runtime-exported-temporary / P5`；QT-B1 为
  `scope-deferred / user-paused / 1/5`。

## 审查记录

- QT-A1 V1 attempt 1 语义／物理：`pass`。只有一张正面纵向行军便笺，
  顶部无皮带／徽记／工具条，中心无文字／任务行／图标，侧边和底边存在从属
  叠页，底部为克制撕裂。
- 透视／图层：`pass`。顶纸、两侧底纸和下缘共享观察角度与左上暖光；未退化
  为双页书、卷轴或现代卡片。
- 美术一致性：`pass with repair note`。暖赭纸、烟褐磨损、深乌棕轮廓、
  明确手绘切面和低分辨率轮廓与锁定基准一致；中心小尺度卷曲纤维出现重复
  节奏，V1.r1 需降低为宽缓、无方向的 tonal variation。
- 第一失败门禁：`5. 组件合同与状态`。启发式色键后的完整可见 bbox 为
  `[200,45,834,1473]`，宽 `634`、高 `1428`，明显越出冻结的约
  `[276,96,748,1440]`；不能按当前 source zone 安全切片。
- 装配／真实排版：`visual direction pass, contract blocked`。候选经仅用于
  审查的确定性色键和九宫格预演后，在 `130 × 180`、`230 × 500`、
  `330 × 865` 和数据库模式均保持单张连续纸、页边厚度与长中文可读区；
  这证明正确区域值得保留，但不能覆盖 raw bbox 失败。
- 技术像素：`fail`。raw 尺寸／模式正确，SHA 如上；原始图片精确
  `#00FF00` 像素为 `0`，被判为背景的像素包含 `6576` 个 RGB 值。透明审查
  稿仅是 candidate simulation，不是 source，也不把色键失败改写成通过。
- 结论：`internal-rejected / repair-prepared / P3`。不进入用户复审，不
  创建 source/runtime。V1.r1 只保留已通过的纸张身份、透视、材质、层序和
  撕裂／叠页关系；修复目标安全盒、精确纯绿色和中心重复纹理。
- 下一门禁：提交本记录与完整 V1.r1 正文，再以 attempt 1 raw 作为同段
  Image 4 进行冻结边界内 edit。
- QT-A1 V1.r1 attempt 2 语义／物理：`pass`。仍只有一张纵向纸面；无文字、
  工具条、皮带、徽记、按钮或其他烘焙对象；顶纸、侧层和下层关系成立。
- 透视／图层：`pass`。正面轻微俯视、共同左上暖光和层间接触阴影保持；新的
  `464 × 1378` 可见比例已接近所需窄长 tracker。
- 第一失败门禁：`4. 美术一致性`。中心纸面的小型卷曲纤维被重绘为均匀重复
  的压花／壁纸节奏，比 attempt 1 更显眼，违背安静、宽缓、无重复的 stretch
  field；它在原尺寸仍会暴露拉伸和现代规则纹理。
- 次要合同／技术失败：启发式色键 bbox `[291,83,755,1461]` 已显著收窄，
  但顶部、右侧和底部仍越出冻结外盒 `[276,96,748,1440]`。原图精确
  `#00FF00` 像素仍为 `0`，背景包含 `5991` 个 RGB 值。
- 装配／真实排版：`visual direction pass, source blocked`。四种
  `100%` 预演中单张纸身份、边缘厚度、撕裂底边和文字可读区均稳定，窄长
  比例优于 attempt 1；重复微纹理在 runtime 缩小后不突出，但 source
  stretch 合同仍不允许忽略。
- 结论：`internal-rejected / repair-prepared / P3`。不进入用户复审或
  source/runtime。V1.r2 改用保守 source-layout compositing：保留窄长比例、
  单纸结构、层序、综合色和运行时重量；进一步内缩 bbox、替换纯色背景，并
  只把中心纹理降为宽缓 tonal variation。
- 下一门禁：提交本记录与完整 V1.r2 正文，再以 attempt 2 raw 作为同段
  Image 4 执行 attempt 3 edit。
- QT-A1 V1.r2 attempt 3 语义／物理：`pass`。对象数量、正面纵向纸张身份、
  顶纸／侧层／底层关系和禁止烘焙内容均未变化。
- 透视／图层：`pass`。共同观察角度、左上暖光和页层接触阴影保持。
- 第一失败门禁：`4. 美术一致性`。V1.r2 明确要求移除的小型卷曲压花仍近乎
  全幅覆盖中心，且比宽缓纸纤维更像程序化壁纸；连续第二次 edit 未改变该
  失败像素，不能继续用相同 edit 策略。
- 次要合同／技术失败：bbox `[290,77,752,1462]` 仍未进入外盒；精确
  `#00FF00` 像素为 `0`，背景有 `6389` 个 RGB 值。相较 attempt 2，目标
  内缩没有发生。
- 装配／真实排版：`visual direction pass, source blocked`。四景中纸面
  轮廓、厚度、撕裂底边和高密度中文层级仍可读，但 source 中心纹理与安全盒
  不满足可拉伸资产合同。
- 结论：`internal-rejected / repair-prepared / P3`。不进入用户复审或
  source/runtime。为避免继续继承失败纹理，V1.r3 不上传任何候选，改从固定
  Image 1／2／3 regenerate；冻结的对象、Canvas、bbox、切片、色键和禁止项
  不变。
- 下一门禁：提交本记录与完整 V1.r3 正文，以固定三张输入执行 attempt 4
  regenerate。
- QT-A1 V1.r3 attempt 4 语义／物理：`pass`。只有一张纵向行军便笺，顶纸、
  两侧底纸与下缘叠页关系清楚；无工具条、皮带、徽记、文字或状态烘焙。
- 透视／图层：`pass`。正面轻微俯视、左上暖光、粗厚轮廓与页层接触阴影
  一致，未退化为书、卷轴、牌匾或现代卡片。
- 美术一致性：`pass`。regenerate 去除了前两次 edit 的均匀压花节奏，中心
  恢复宽缓低对比的暖赭纸面；深乌棕轮廓、烟褐磨损、底部克制撕裂和香草时代
  低分辨率手绘切面均与锁定基准协调。原尺寸仍有稀疏自然纤维，但没有规则
  重复单元或 focal ornament。
- 第一失败门禁：`5. 组件合同与状态`。可见 bbox
  `[261,82,771,1454]` 越出冻结外盒 `[276,96,748,1440]`，不能直接按约定
  source zone 安全切片。
- 技术像素：`fail`。raw 为正确的 `1024 × 1536 RGB`，但精确
  `#00FF00` 像素为 `0`，背景包含 `6218` 个 RGB 值。
- 装配／真实排版：`pass except source gates`。四种 `100%` 预演中纸面
  保持足够厚重、连续而不形成逐任务卡片；十任务／十七目标和数据库模式均
  可读。当前 provider focus 灰条与七图标继续明确为未完成 fallback。
- 结论：`internal-rejected / repair-prepared / P3`。attempt 4 的纸张
  语义、物理、透视、层序、美术和运行时排版全部作为最终 edit 的保留区域；
  V1.r4 只允许整组等比缩放／重定位、外部阴影收敛和背景替换。
- 下一门禁：提交本记录与完整 V1.r4 正文，以 attempt 4 raw 作为 Image 4
  执行 QT-A1 最终 attempt 5。
- QT-A1 V1.r4 attempt 5 语义／物理：`pass`。对象数、纵向单纸身份、顶纸与
  底层页关系、工具条排除和动态内容排除均保持。
- 透视／图层：`pass`。正面轻微俯视和页层接触成立。
- 第一失败门禁：`4. 美术一致性`。尽管 V1.r4 明确冻结 attempt 4 的纸张
  像素，最终 edit 仍重绘了中心并重新引入均匀、全幅的小型卷曲压花／壁纸
  节奏；它不能作为可横纵拉伸的安静阅读面。
- 次要合同／技术失败：bbox `[275,132,759,1445]` 已在垂直方向明显内缩，
  但左 `1px`、右 `11px`、底 `5px` 仍越出冻结外盒
  `[276,96,748,1440]`。精确 `#00FF00` 像素仍为 `0`，背景包含
  `6929` 个 RGB 值。
- 装配／真实排版：`visual direction pass, source rejected`。四景在 runtime
  缩放后仍可读，但不能以缩小后不明显为理由覆盖 source 美术、bbox 与色键
  失败。
- 结论：`candidate-rejected / repair-budget-exhausted / P3`。QT-A1 已用满
  `5/5`，不得 attempt 6；没有 candidate-reviewed、source、runtime 或
  adapter。attempt 4 是本机最佳美术证据但仍为 rejected candidate，不能
  晋级或成为 B1 生产输入。
- 下一门禁：同步 QT-A1 终态；QT-B1 仍按独立授权从固定 Image 1／2／3
  执行 attempt 1。QT-B1 的真实排版可把 attempt 4 仅作为
  `rejected / non-authoritative A1 visual fallback`，不得当作 source。
- QT-B1 V1 attempt 1 对象数量／身份：`pass`。原图只有三件彼此分离的
  覆盖层，没有文字、任务行、图标、工具条、按钮、底板或第四件对象；
  tracked 是暗酒红竖向布墨页边记号，complete 是单笔深乌棕墨勾。
- 第一失败门禁：`5. 组件合同与状态`。provider 以同一 `4:3` 比例返回
  `1448 × 1086 RGB`；审查工具只为坐标核验等比归一化为冻结的
  `1024 × 768`，不修改 raw。归一化透明审查稿整体 bbox 为
  `[105,143,942,633]`：focus 在 cell 内触及左／右／下边，tracked 触及
  左／上／下边，complete 触及右边，证明三件均越出各自冻结 cell，不能
  安全裁成独立 source。
- 美术一致性：`partial fail`。tracked 的暗酒红布墨材料与 complete 的
  深乌棕单笔形态可保留；focus 却成为偏黄绿、过亮、近乎不透明的宽刷带，
  在候选色键后出现明显亮绿边，并在 `230 × 500` 与 `330 × 865` 的真实
  排版中形成一条抢夺文字层级的荧绿横带，不符合低对比暖赭淡墨洗。
- 技术像素：`fail`。raw SHA-256 为
  `ff6bf0af0642715894b6dcc7344fb3dd966b947ff6b56e3426197697af6c4bae`；
  provider raw 只有 `1` 个精确 `#00FF00` 像素。等比归一化后精确绿色为
  `3` 像素，被色键分类的背景包含 `20489` 个 RGB 值；它不是可复现的
  native 纯色色键。
- 装配／真实排版：`fail with retained evidence`。审查工具使用 QT-A1
  attempt 4 仅作 `rejected / non-authoritative A1 visual fallback`，
  以真实 `130 × 180`、`230 × 500`、`330 × 865` 与数据库模式排版动态
  文字。tracked 与 complete 在 `10 × 14..22`／`12 × 12` 运行时尺寸可读，
  但 focus 的绿边和综合色明显不合格；工具条仍只是 QT-A2 暂缓期的 provider
  fallback。
- 审查证据：固定 Prompt SHA-256
  `66991c20c3391160e4023ee4681239888a9708f2e063fb74041e724213102f4e`，
  `3938` bytes；fixed child session
  `019fb64e-9e36-7b93-8dbc-b572a13d5373`。归一化透明审查稿 SHA-256
  `f6da60fd48f6a6dee8d37bfc6105880a5421dc97d08e44ce97144e2a15bd6fa7`；
  四张真实排版 SHA-256 分别为
  `8669f4a0fb633f8a219393b3313494893e7fdf7c66646ed831e15d1cb42ea87a`、
  `e0a4a703b8678bf654edb4e1996804bc60a98bbd4a4cc29e561fd008cc7cfc5c`、
  `d4a59694d6845eb07228368aa5a538fc01a02cd21c9a49d74f572fe864eed90c`
  和
  `00d2b1721cb76a48b9255b977913e3fa5e5a9d7fff1dd5ad2fde0b6027ae40f5`；
  总览 SHA-256
  `c1ff31782746355c8a3ed46aa8c4d108866c1cf338b81064239494c27e5637b8`。
- 用户决策：`2026-07-31 / scope-deferred`。用户认为三件覆盖层在真实排版
  表现中很糟糕，要求暂停生成，并暂时只使用大块背景 tracker。旧 V1.r1
  不再执行；QT-B1 没有 source/runtime，adapter 也不创建三件覆盖层。
- QT-A1 临时接受例外：用户的“直接使用大块的背景 tracker”明确授权把
  attempt 4 的大纸面方向作为临时 runtime。raw 的 bbox／native 色键失败
  事实不被改写；晋级的是审查工具产生的确定性 RGBA，SHA-256
  `a9d700cd01f26535ae2035bfa3d8c2cedd7337bfb47d3fa9494ba592d259c59b`。
  source manifest 明确记录 `user-accepted-temporary-contract-exception`。
- 确定性导出：exporter
  `tools/build_quest_tracker_paper_v1.py` 从 reviewed Alpha bbox
  `[261,82,771,1454]` 等比缩放为 `190 × 512`，清除两个只在 LANCZOS
  重采样后出现的亮绿色边缘像素，并右侧透明填充到 `256 × 512` TGA。runtime
  SHA-256
  `c6b1f64034fa69f01709403e592c3350445c9a6739f4b559242be48831666c61`，
  可见绿色残留 `0`。
- runtime 装配：`Quests.lua` contract `1.8` 在真实
  `pfQuestMapTracker` 上创建九个 `BACKGROUND` Texture；固定 cap 为
  左／右 `14px`、上 `12px`、下 `16px`，中心随 provider 的动态
  `130..330px` 宽度和内容高度拉伸。provider 黑色 panel Texture 和每行
  半透明矩形被隐藏；当前 runtime `1.19` 继续按用户裁决隐藏节点图标并
  统一 Quest Log／Tracker 高对比深墨任务名难度色；动态
  文字、目标、七工具 Button、Tooltip、
  点击、拖动、模式与 SavedVariables 均保持原对象／脚本。
- 背景-only 真实排版：`--paper-only` 明确不绘制 QT-B1 或 provider 灰色
  focus fallback，并从最终 TGA 的 manifest-locked 九宫格／cap 装配，不再
  从 raw 候选近似切片。`130 × 180`、`230 × 500`、`330 × 865` 与数据库
  模式 SHA-256 分别为
  `658463ae0e59033f80378d4bf5eda440ebd388562d401aff410e7cc447350786`、
  `35ae7e1e5f86a035f886b7a193d29510c0c31e9be72fcca602c964145265ffcc`、
  `ce47ab3a897bbbfac3f43a4e07fac8d278d63e6585f0236510d97cb2046d4374`
  和
  `8c6d79c04bc6f89537bce9543ed2c66b861b9562fd2a00b474dd13f3b7fafefb`；
  总览
  `aad8a8fb800e0932ddd9cf7e2430ba49bf29a0039bf713bdd1fd5c350758a5ea`。
  这些图的固定高度现只保留为历史容量包络，不再构成“真实排版”门禁证据。

## 实际展示区域复核 — 2026-07-31

- 结论：`fail / display-region-blocked / P5`。runtime 文件仍保留，但不能
  进入 P6；本轮没有改写 provider 或 adapter 布局。
- 合同：
  `tools/specs/quest_tracker_display_region_v1.json`。坐标以 tracker 左上为
  原点、右下排他，读取 `pfQuest/tracker.lua` 的默认 `fontsize=12`、
  `panelheight=16`、`entryheight=20` 和
  `height = panel + entries × entryheight + objectives × fontsize`。
- 报告：
  `generated/quests/QT/QT-A1/display-region-audit/display-region-report.json`，
  SHA-256
  `511dcffcf9bbb93a9e969c75d3dcb1fe10711258be85442044e3450af261801c`；
  七个场景全部失败，加一项 provider 边界未冻结，共 `35` 项，第一失败码
  `FRAME_BELOW_NINE_SLICE_MINIMUM`。
- 已通过：runtime atlas `256 × 512` 的九个采样盒无越界、无重叠、无缺口，
  精确覆盖可见区 `[0,0,190,512]`；普通尺寸下九宫格可铺满 Frame。
- 空状态失败：provider 高度为 `16px`，低于 manifest 声明的
  `29px` 最小高度。adapter 会把上／下端帽压为约 `7px`／`8px` 并保留
  `1px` 中心，因此不会留缝，但原 `12px`／`16px` 纸边美术被挤压，不能称为
  按合同显示。
- 内容安全失败：纸面装饰 cap 为左／右 `14px`、上 `12px`、下 `16px`；
  provider 首个节点图标位于 `x=2..14`，完全压在左边缘；标题／目标的右边界
  为 `width-10`，进入右 cap `4px`；最外侧 quest／close 工具 icon 分别越过
  左／右工具安全区 `13px`；最后一条目标在默认字体下进入底部撕裂 cap
  `14px`，数据库最后标题进入 `12px`。
- provider 边界未冻结：`trackerfontsize` 是可输入任意数字的文本配置，
  `tracker.lua` 没有 min／max；单任务 objective 数量也由数据决定且没有
  provider 上限。本次报告只以默认 `12px` 与已声明场景作确定性复核，P6 前
  必须冻结项目支持范围并补测。
- 旧预演失真：两任务／四目标、六任务／十目标、十任务／十七目标和六条
  database 的真实高度分别为 `104`、`256`、`420`、`136px`，而旧图使用
  `180`、`500`、`865`、`500px`，额外制造 `76`、`244`、`445`、`364px`
  不存在的底部留白，遮蔽了最后一行与撕裂底边冲突。
- 修正后的确定性预演：
  `generated/quests/QT/QT-A1/display-region-audit/runtime-real-layout/`；
  `review.json` SHA-256
  `1be7cff5baf0b98f0d60c27a3db30ca0bf1dac93a0dd0f14654aba11ec27d912`，
  总览 SHA-256
  `19466df28049d2063117d78a981f926b8a278ce9c8f649a91b0c608bc4401efa`。
  工具条黑底已按 adapter 真实行为移除，只显示 provider 七枚 icon；数据库
  与任务给予者模式不再虚构 objective 行；另覆盖空状态和二十五条上限。
- 下一步必须先选择并模拟新的几何策略：把纸面装饰端帽移到 provider 内容盒
  外侧，或在不改变 provider 功能的前提下建立真实内边距／重排 live anchors。
  该选择会改变可见比例，需要新的本地几何方向确认；不能直接进入 ImageGen。

## 外置装饰端帽精确几何预演 — QT-GEO V1

### 用户选择与冻结边界

- 用户选择：`2026-07-31 / first-scheme-selected`。采用“外置装饰端帽”，
  不采用 live 内边距／重排 anchors 方案。
- 当前状态：`simulation-rendered / awaiting-user-confirmation`。本节只准备
  可见方向，不构成 runtime 接入授权，也不改变 QT-A1 临时 TGA。
- provider 权威：`pfQuestMapTracker` 根 Frame 继续使用
  `130..330px` 动态宽度、真实高度公式、原 Parent／Point、七个 Button、
  `pfQuestMapButton1..25`、所有文字／图标 anchors、点击区、Tooltip、拖动、
  clamp、模式、`OnUpdate` 与 SavedVariables。
- adapter 提案：新增一个位于 provider 后方、`EnableMouse(false)` 的纯视觉
  shell。live 中心严格等于 provider 根矩形 `[0,0,width,height]`；装饰端帽
  固定在 live 外侧：左 `14px`、右 `14px`、上 `12px`、下 `16px`。
- 装饰规则：四个 cap 与 live 矩形零相交。上／下端帽不再挤进空状态的
  `16px` 高 Frame；左右纸叠层不再覆盖 `x=2..14` 节点图标、
  `x=1..15`／`width-15..width-1` 工具 icon 或 `width-10` 文字右界；
  最后一行也不再进入底部撕裂边。
- 仍未决定：provider 保存到物理屏幕边缘时，外置端帽可能被 viewport 裁切。
  runtime 接入前必须单独验证 screen-edge policy；只能处理视觉壳的显示边界，
  不得改写 provider 数据、hitbox 或 SavedVariables 语义。

### 本地模拟规格与执行

- specification：
  `tools/specs/quest_tracker_external_caps_simulation_v1.json`，SHA-256
  `73a3845aa1c73eba86e4323b5505e0a7c45874aa15958371aa1632f5a0d5babf`。
- renderer：
  `tools/render_quest_tracker_external_caps_simulation_v1.py`，SHA-256
  `771252b38f6652c8301bc590018e609958b1fb0cabbcaebfe066c48fdcd27b5a`。
- 平台／解释器：macOS；Conda `py312`；本机绝对路径不写入
  specification 或模拟像素；实际 `sys.executable` 已验证为该 Conda
  环境的 Python，版本 `3.12.12`。
- primitives：矩形、多边形、线段、椭圆和真实中文字体排版；无生成纹理，
  不读取 QT-A1 source／TGA 像素。
- ImageGen：`0/0`；无上传、provider session、固定执行器调用或生产预算。
- 场景：严格使用 provider 默认 `font_size=12`、`panel_height=16`、
  `entry_height=20`、`objective_step=12` 与
  `height = 16 + entries × 20 + objectives × 12`。覆盖：
  `200 × 16` 空状态、`130 × 104` 短列表、`230 × 256` 典型列表、
  `330 × 420` 高密度十任务／十七目标、`330 × 516` 二十五条折叠上限，
  以及 `230 × 136` 的 database／giver 六条。
- 游戏内代表场景：`1536 × 1024`、100% UI scale；
  `330 × 420` provider live Frame 位于 `x=1166,y=92`，对应视觉壳为
  `358 × 448`。背景与邻接 UI 只用简单几何表示，非任何模块的美术权威。
- 命令：

```bash
conda run -n py312 python \
  tools/render_quest_tracker_external_caps_simulation_v1.py \
  tools/specs/quest_tracker_external_caps_simulation_v1.json \
  --repo-root .
```

### 输出与内部审查

- 游戏内观感图：
  `generated/quests/QT/simulation/QT-GEO-V1/quest_tracker_external_caps_ingame_v1.png`，
  `1536 × 1024 RGBA`，SHA-256
  `ea4d2041090bbfc34087ce01eee410d6bf73c46f6daad6215e4e590cb3388983`。
- 七场景几何板：
  `generated/quests/QT/simulation/QT-GEO-V1/quest_tracker_external_caps_scenarios_v1.png`，
  `1800 × 1240 RGBA`，SHA-256
  `0909bc056bc3a07ee7ad74dc52d3c73b2589afff68f5ff178b24e310fdc81bb4`。
- 机器报告：
  `generated/quests/QT/simulation/QT-GEO-V1/quest_tracker_external_caps_report_v1.json`，
  SHA-256
  `fde561fcfad1d5a85267cf62f6c3489fe159f2bac2dca7d6e5fc5cedf81110c1`。
- 流程错误：首次本地执行因 renderer 把调色板键名 `aged_brass` 误传为颜色
  值而抛出 `ValueError: unsupported color: #aged_brass`；修正单一分支后
  同一 specification 重跑成功。该错误没有候选生图或 provider 证据，
  ImageGen 仍为 `0/0`。
- 几何审查：`pass`。七种真实 Frame 的公式高度全部一致；七个 toolbar
  icon、全部 title／objective／node icon 盒均包含于 live Frame；四个 cap
  均与 live Frame 零相交。空状态保留 `200 × 16` live Frame，同时得到
  `228 × 44` 的完整视觉壳，不再压缩上下端帽。
- 视觉内审：`displayable`。本地几何足以判断端帽外扩后的重量、连续纸面和
  空／短／密集状态比例；扁平色块、纸面纹理、手绘边缘、最终 Alpha、九宫格
  UV 与 screen-edge policy 均非权威。
- 生成文件位于被忽略的 `generated/`，不会提交，不是跨设备 source。只有
  specification、renderer 和本 work 记录进入 Git。

### 用户方向门禁

- 当前具体模拟版本：`QT-GEO V1`
- 用户结论：`user-rejected / 2026-07-31`
- 拒绝原因：用户明确要求不要在 tracker 外侧增加类似书框的边界；直接使用
  当前 tracker 展示已经足够。外置上／下端帽、左右页叠层、外投影和视觉壳
  都从下一版方向中移除。
- 本次只需判断：
  - 装饰端帽完全外置后，空／短／典型／高密度／二十五条状态的整体比例是否
    合理；
  - live 内容直接排在连续纸面上、四周不再牺牲内容空间，是否符合 tracker
    主体方向；
  - 外置左右叠页与上下纸边是否具有足够厚度，又不会把 tracker 重新变成
    规则现代卡片。
- 确认只接受可见方向，不接受模拟像素；模拟图不得进入 source、runtime、
  crop、edit 或 ImageGen reference。
- 下一门禁：建立不含任何外置边界的 `QT-GEO V2` 本地几何版本；仍不调用
  ImageGen。

## 直接使用 live tracker 纸面预演 — QT-GEO V2

### 用户方向与模拟合同

- 用户方向：`2026-07-31 / no-exterior-book-frame`。不在 tracker 外侧增加
  书框、装饰端帽、错层页边、轮廓线或投影；当前 tracker 的内容与纸面直接
  展示。
- 当前状态：`simulation-rendered / awaiting-user-confirmation`。该版本只
  用于确认“无外置边界”的可见方向；不构成 runtime 接入授权。
- provider 与交互冻结：`pfQuestMapTracker` 的 Parent、Point、
  `130..330px` 动态宽度、真实高度公式、七个 Button、
  `pfQuestMapButton1..25`、全部文字／图标 anchors、hitbox、Tooltip、
  拖动、clamp、模式、`OnUpdate` 与 SavedVariables 均不变。
- 唯一显示面严格等于 provider live Frame：
  `[0,0,width,height]`。四边 visual outsets 固定为左／右／上／下
  `0px`；不存在 live Frame 外的可见像素，因此也不存在外置端帽的贴屏裁切。
- 模拟中的酒红轮廓只用于七场景验收板标记 live Frame，不属于最终 UI；
  游戏内观感图不绘制该轮廓。

### 本地规格、执行与证据

- specification：
  `tools/specs/quest_tracker_direct_paper_simulation_v1.json`，SHA-256
  `906ea23c2d77c88208ca546feaa4522d1b742978f113f56265beef63c03e475d`。
  它复用 QT-GEO V1 的 provider 场景与真实中文数据，只覆盖用户改变的视觉
  proposal、输出路径和版本；不继承 V1 的外置端帽。
- renderer：
  `tools/render_quest_tracker_external_caps_simulation_v1.py`，SHA-256
  `e0466cae14513f01866ea768e6858d1886a706d6b24f81f3539292966b55b7a2`。
  同一 renderer 以零 outsets 分支绘制 direct paper，避免另建重复脚本。
- 平台／解释器：macOS；Conda `py312`；实际 `sys.executable` 已验证为该
  Conda 环境 Python，版本 `3.12.12`。
- 命令：

```bash
conda run -n py312 python \
  tools/render_quest_tracker_external_caps_simulation_v1.py \
  tools/specs/quest_tracker_direct_paper_simulation_v1.json \
  --repo-root .
```

- ImageGen：`0/0`；无上传、provider session 或生产预算。
- 本地渲染错误：`0`。
- 游戏内观感图：
  `generated/quests/QT/simulation/QT-GEO-V2/quest_tracker_direct_paper_ingame_v1.png`，
  `1536 × 1024 RGBA`，SHA-256
  `1e865eeb5f679f3b83d49eab7b370ae96d1d4f692d4679d8f590eb35b44e6255`。
- 七场景验收板：
  `generated/quests/QT/simulation/QT-GEO-V2/quest_tracker_direct_paper_scenarios_v1.png`，
  `1800 × 1240 RGBA`，SHA-256
  `f598bf8bc89a336b74bd475782de85896d0c284fe804e0cc8b81b16192fc4ca9`。
- 机器报告：
  `generated/quests/QT/simulation/QT-GEO-V2/quest_tracker_direct_paper_report_v1.json`，
  SHA-256
  `cc90edd7c58e07a0a31fcdd37b6dc8ac23aac3d1df3cfd6ae873ae92f2cb0747`。
- 覆盖场景保持与 provider 合同完全一致：`200 × 16` 空状态、
  `130 × 104` 短列表、`230 × 256` 典型列表、`330 × 420` 十任务／
  十七目标、`330 × 516` 二十五条折叠上限，以及 `230 × 136` 的
  database／giver 六条。
- 几何审查：`pass / 7 of 7`。所有公式高度、toolbar icon、title、
  objective 与 node icon 均落在 live Frame 内；每个场景
  `visual-shell-equals-live`，四个 cap 退化为空区域。
- 视觉内审：`displayable`。游戏内图能够直接判断无书框后的比例、密度与
  综合色重；简单平涂、最终纸张微纹理、Alpha 和客户端混合仍非权威。
- 生成输出位于 ignored `generated/`，不会提交，不是跨设备 source，也不得
  成为 production edit／reference 输入。

### 用户方向门禁

- 当前具体模拟版本：`QT-GEO V2`
- 用户结论：`awaiting`
- 本次只需确认：游戏内图中这种“纸面与 live Frame 完全同尺寸、没有任何
  外置书框或端帽”的直接展示是否就是目标。
- 确认后下一步：把该无边界方向写入稳定子模块合同，修改 adapter 的纸面
  装配并重做七场景展示区域报告；确认前不改 addon runtime。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `QT-SIM V1` | 本地 specification、renderer、主图／局部图 SHA；ImageGen `0/0` | `superseded-by-user-priority` | 移除低优先级工具条，聚焦 tracker 主体 |
| `QT-SIM V2` | 本地 specification、renderer、主图／局部图 SHA；用户于 `2026-07-31` 回复“继续”；ImageGen `0/0` | `direction-confirmed / exact-geometry-superseded / P2` | 材料方向保留；cap／padding 新方案必须按 provider 公式重做本地模拟 |
| `QT-GEO V1` | 外置端帽 specification、deterministic renderer、两张本地预演与七场景机器报告；ImageGen `0/0` | `user-rejected / superseded` | 移除外置书框、端帽、页叠层和投影；直接使用 live tracker |
| `QT-GEO V2` | direct-paper overlay specification、同一 deterministic renderer、两张本地预演与七场景机器报告；ImageGen `0/0` | `simulation-rendered / awaiting-user-confirmation` | 用户确认后才修改 runtime；显示面必须始终等于 live Frame |
| `QT-A1 V1` | raw 循环 `5/5` 失败事实 + attempt 4 确定性 RGBA／manifest／九宫格 TGA／provider 公式展示区域复核 | `runtime-exported-temporary / display-region-blocked / P5` | 先修正 paper cap 与 live 内容的几何合同并重做精确模拟 |
| `QT-B1 V1` | attempt 1 fixed session、raw、归一化透明稿与四景真实排版 SHA | `scope-deferred / user-paused / 1/5` | 不执行旧 V1.r1；未来重开需新模拟、新版本与新授权 |
| `QT-A2 V1` | 无 ImageGen 调用；历史正文仅在 Git history | `scope-deferred / P2` | 未来重开时先做独立模拟和新授权 |

## 下一门禁

静态实现门禁仍通过：exporter 重跑保持 source／TGA 哈希，Python 编译、
quest design contract、repository contract、asset workflow skill contract
与 Lua smoke 通过；smoke 覆盖 pfQuest 晚加载、九个 Texture、动态 resize、
provider `OnUpdate` 保留和刷新幂等。但实际展示区域门禁明确失败，当前保持
`P5 / display-region-blocked`，不能直接进入 Turtle WoW P6 验收。用户已
否决 `QT-GEO V1` 外置端帽，`QT-GEO V2` 已按无外置书框的直接纸面方向完成
本地预演。当前 runtime `1.19` 继续保留批次提交、底部安全区、条目 icon
隐藏及 Tracker 任务名旧统一字体／无描边／shadow，并把 Tracker 任务名与
Quest Log 任务名收敛到同一个 `ResolveQuestNameInk` 难度色入口；完成率仍是
独立状态墨色。下一门禁是 Turtle WoW 比较同一任务的跨面板名称颜色，并验证
这些状态在接受／放弃任务后仍稳定。QT-B1／QT-A2 均保持 scope-deferred，
不再调用 ImageGen。
