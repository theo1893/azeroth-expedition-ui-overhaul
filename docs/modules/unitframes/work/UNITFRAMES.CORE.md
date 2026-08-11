# Unit Frames 主单位框批次 UF-PRIMARY／UF-A1 V2

## 元数据

- 模块：`unitframes`
- 组件 ID：`UF.PLAYER.SHELL`、`UF.TARGET.SHELL`、
  `UF.TARGETTARGET.SHELL`、`UF.FOCUS.SHELL`、`UF.BAR.*`、`UF.STATE.*`
- 当前版本：`UF-A1 V2-A V1`／`UF-A1 V2-B V1`／`UF-A2 V1`／`UF-B1 V1`
- 子状态：UF-A1 V2 `prompt-authorized`；UF-A1 V1
  `candidate-rejected / repair-budget-exhausted / user-rejected`；UF-A2／UF-B1
  `prompt-authorized / paused`
- 项目阶段：UF-A1 V2 `P3`；UF-A2／UF-B1 保持 `P3 / paused`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：`generate`；已确认“独立四件 source → 标准宽度单 shell／可变宽度
  三切片”，V2-A／V2-B 正文与生产授权边界均已冻结
- 生成前模拟：`UF-A1-V2-SIM-V2`／deterministic-local-geometry；ImageGen
  `0/0`
- 本地渲染错误：历史主模拟确认后复跑 `1` 次 sandbox 写权限错误；V2 首次
  本地执行有 `1` 次 Python `false`／`False` 拼写错误，针对性修正后同一几何
  合同重跑；随后有 `1` 次 sandbox 写权限错误，获准写入 ignored `generated/`
  后以同一命令通过。三者均不属于 ImageGen。
- 自动修复预算：UF-A1 V1 历史终态 `5/5`；V2-A 已执行 `1/5`、V2-B
  `0/5`，最坏合计 `10` 次；UF-A2／UF-B1 各 `0/5` 并
  继续暂停
- 流程错误：`2`（A1 `E1` 为 stdin transport；A1 `E2` 为 npm sandbox
  `EPERM`；二者均无图片或 provider result，不占实际生图额度）
- 历史正式生产授权：`2026-08-11`；用户授权 A1→A2→B1 顺序、A1／A2 固定
  Image 1／2、同段紧邻前稿 edit 输入、B1 首次无图、每段最多 `5` 次实际
  ImageGen、最坏 `15` 次、流程错误不占额度、禁止跨段复用，以及合同内的
  固定分区、边缘连通色键、透明 RGB 清零、纵横比误差不超过 `1%` 的等比
  bbox-fit 和真实排版预演。
- V2 正式生产授权：`authorized / 2026-08-11`。按 A→B 顺序；每段每次只上传
  固定 SHA 的 Image 1／2，attempt 1 无 Image 3；同段紧邻前稿仅可在冻结边界
  内作为 Image 3 edit 输入；每段最多五次实际 ImageGen，流程错误不占额度，
  禁止跨段复用像素；允许合同内的确定性拆分、色键、等比 bbox-fit、真实排版
  和缩放预演。
- V2 用户授权原文：`确认授权 UF-A1 V2-A V1 与 UF-A1 V2-B V1；按 A→B 顺序
  执行；每段每次允许上传固定 SHA 的 Image 1/2，首次无 Image 3，仅允许同段
  紧邻前稿在冻结边界内作为 Image 3 edit 输入；每段最多 5 次实际 ImageGen，
  最坏合计 10 次；流程错误不占额度；禁止跨段复用像素；允许合同内的确定性
  拆分、色键、等比 bbox-fit、真实排版和缩放预演。`
- V2-SIM.V2 本地执行授权：`2026-08-11`；用户在讨论缩放风险并确认“标准
  单 shell／可变宽度三切片”方案后原文“按照这个方案执行”。该授权仅覆盖
  本地几何预演、校验与文档，不扩展为 production 或 addon 接入授权。
- V2-SIM.V2 用户方向确认：`confirmed / 2026-08-11`；用户在看到缩放矩阵、
  装配板及 `6/6` 展示区域结果后原文“确认”。确认只冻结文字化结构方向，
  不接受几何模拟像素，不构成 V2-A／V2-B 正式生图授权。
- 用户授权原文：`确认授权 UF-A1 V1、UF-A2 V1、UF-B1 V1；按 A1→A2→B1
  顺序执行；A1/A2 每次允许上传固定 SHA 的 Image 1/2，首次无 Image 3，仅允许
  同段紧邻前次输出在冻结修复边界内作为 Image 3 edit 输入；B1 首次不上传
  图片，仅允许同段紧邻前次输出作为后续 Image 1 edit 输入；每段最多 5 次实际
  ImageGen 调用，最坏合计 15 次，流程错误不占额度；禁止跨段复用像素；允许
  固定分区拆分、边缘连通色键、透明 RGB 清零、纵横比误差不超过 1% 的等比
  bbox-fit 与真实排版预演。`
- 锁定视觉基准：当前没有 Unit Frames 专属锁定图。
- 次级风格参考：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`：
    只提供香草时代绘制尺度、短黄铜高光、厚轮廓与综合色重；明确忽略其完整
    屏幕布局、圆形头像和单位框示意结构。
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`：
    只提供深胡桃材料、左上暖光、手工误差与磨损节奏；明确忽略书页、书脊、
    木柱、龙饰、完整书框与大面积金边。
- Prompt provenance：`docs/GLOBAL_ART_BASELINE.md`、本模块
  `ART_BASELINE.md` 与 `SUBMODULE_ART_BASELINES.md`。

## 美术基准继承

### 权威顺序

1. `docs/GLOBAL_ART_BASELINE.md` 与用户本轮“项目一致、粗犷随性、不太工整”。
2. 本模块 `ART_BASELINE.md`／`SUBMODULE_ART_BASELINES.md`。
3. `SUBMODULES.md` 的真实对象、几何、动态内容与禁止烘焙合同。
4. 两张 Chat 锁定图只承担上列受限跨模块视觉职责。
5. pfUI 当前媒体只提供 provider 接口与尺寸，不提供现代视觉方向。

### 必须继承的视觉 DNA

- 2004 年香草魔兽二维手绘位图、粗厚可读的低分辨率轮廓；
- 左上暖光、低饱和烟褐／深胡桃／氧化黄铜、短促且断续的高光；
- 不完全平直、不镜像、维修导致的真实不规则，而不是全表面随机噪声；
- 动态内容区安静，装饰只在外缘、端帽、连接和状态边缘。

### 本批组件级转译

- Chat 的“旧书厚重”转译为“手工包边的行军身份牌厚重”，不复制书本物件；
- 玩家／目标采用同族非镜像端帽；紧凑框用减法，不直接缩小大框；
- Focus 的独特识别来自被真实压住的褪色靛蓝猎踪布结；
- HP／Power 保留动态颜色，只增加低频哑光颜料纹。

### 明确不继承

书页、书脊、频道 Tab、蜡封、木柱、龙饰、地图罗盘、任务卷宗、动作条双头
狮鹫，以及 Chat 的完整框架轮廓均不属于本批资源。

### 冲突审计

- Chat 独立资源的大面积金属建筑感与全局“单位框不得成为战争圣龛”冲突：
  以全局和本模块 Prompt 为准，只保留少量断续黄铜。
- Chat 游戏内基准包含圆形头像，而当前 profile `portrait=off`：以真实 provider
  为准，不生成圆形假头像槽。
- 另一台设备位置尚未同步：位置不进入生产合同；只锁定资源尺寸和内外安全区。

## 组件合同

- UF-A1 V2 source：Player／Target 各拆为 `LEFT_CAP 7×42`、
  `TOP_RAIL 200×6`、`BOTTOM_RAIL 200×6`、`RIGHT_CAP 7×42` 四个独立对象，
  共八件。默认 `W=200` 时由确定性 builder 预合成为每角色一张 `214×42`
  RGBA shell，运行时只挂载一张纹理，因此内部 Texture 接缝为 `0`。
- 只有 `W≠200` 时启用三切片：固定左右端帽，中央带同时承载上下轨与透明
  中部；中央带在两端各外扩 `1 logical px`，位于端帽下层。重叠只发生在
  `y 0..6`／`y 36..42` 的装饰角，不进入 `200×30` 动态安全区。这是装饰件
  之间的抗取整连接，不是 UF-A1 V1 被拒绝的“装饰覆盖内容区”例外。
- 高度固定为 `42`，禁止纵向拉伸；需要其他高度时必须另立规格。
- UF-A2 仍为 TargetTarget／Focus 两张独立静态 shell；UF-B1 仍为两条共享
  bar fill；Hover／Aggro 由最终接受 shell Alpha 确定性派生。
- Runtime 尺寸：Player／Target `214×42`；TargetTarget `112×34`；Focus
  `112×39`；Health `64×32`；Power `64×16`。
- 动态安全区：各 shell 中央完整保留对应 `200×25 + 200×4` 或
  `100×20/25 + 100×1` provider 区域。
- UF-A1 V2 的 Player／Target 安静区固定为 `x 7..207 / y 6..36`；四件装饰
  Alpha 与该 `200×30` 区域的交集必须严格为 `0`，不得再申请覆盖例外。
- 禁止烘焙：文字、数字、颜色语义、头像、单位类型、Buff／Debuff、图标、
  预测治疗、状态标记、点击或配置控件。
- Alpha：正式 shell 真透明；生产阶段使用纯 `#00FF00` 外部色键并在 P4 前
  只做边缘连通色键与透明 RGB 清零。Bar fill 为不透明灰阶。
- 装配：shell 只作鼠标无关覆盖层；标准路径使用单纹理 composite，可变宽度
  的层序为动态条 → 中央带 → 固定端帽 → 运行时文字／图标；所有物理盒均从
  同一逻辑原点计算，装饰盒起点向下取整、终点向上取整，安全区反向内收。
  bar fill 继续由现有 StatusBar 裁切；状态 rim 不扩大命中盒。
- 回退：任一媒体缺失时局部恢复 pfUI 当前 backdrop／bar／glow。

## 生成前模拟实例图

### 模拟合同

- 版本：`UF-PRIMARY-SIM-V1`
- 真实资源尺寸：四框按 `214×42`、`214×42`、`112×34`、`112×39` 绘制；
  放大审阅图明确标记为 `2×`。
- 代表性动态内容：玩家、敌对目标、目标的目标、Focus；HP／Power、名称、
  数值、四枚目标 Aura、Aggro 与 Hover 状态。
- 邻接 UI：简化战地旧书 Chat 与双头狮鹫动作条，均为非权威几何占位。
- 屏幕位置：因另一设备布局未同步而明确非权威；不进入资源合同。
- 用户需要确认：行军身份牌隐喻、非镜像不规则轮廓、材料层级、Focus 靛蓝
  布结、综合色重、装饰克制度。
- 刻意简化：手绘笔触、皮革／黄铜微纹理、Alpha、切片、接缝和最终状态 rim。
- 禁止用途：模拟图不得成为 source、runtime、裁切／切片或生产输入。

### 本地模拟执行

- 规格：`tools/specs/unitframes_primary_simulation_v1.json`
- 渲染器：`tools/render_unitframes_primary_simulation_v1.py`
- 命令：`conda run -n py312 python tools/render_unitframes_primary_simulation_v1.py`
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- ImageGen：`0/0`
- 初始本地渲染错误：`0`
- 确认后复跑：首次因当前 sandbox 无法写入 ignored `generated/`，返回
  `PermissionError: [Errno 1] Operation not permitted`；随后仅提升同一命令的
  文件写权限重跑成功。scene／zoom／report SHA 均与确认前完全一致，不消耗
  ImageGen 或正式生产流程错误额度。
- 输出与 SHA：
  - scene：
    `generated/unitframes/primary/simulation/V1/unitframes-primary-v1.scene.png`；
    `107b2a71cf29938bf69f8a871c8fcdcae50a561a9b438a929f2a7d684264861c`；
    `1600×900 RGBA`。
  - zoom：
    `generated/unitframes/primary/simulation/V1/unitframes-primary-v1.zoom.png`；
    `d5e76afef373c96a93571ddf9d6a1116e6428a1aec86b53046c8cb73ac1a4e48`；
    `1200×620 RGBA`。
- 实际展示区域合同：
  `tools/specs/unitframes_primary_simulation_display_region_v1.json`，SHA
  `e9546270234d3097bd8b43eacce71c05099888222ed09d8788f19db7d1de5d21`；报告
  `generated/unitframes/primary/simulation/V1/display-region-report.json`，SHA
  `9d22e5e2c50e0c25b7ad0dbb5dfb11562f71b2e097a730285458c281de7b82ad`；
  `4/4 pass`，violations `0`。
- 内部结论：`displayable`。四框使用真实资源尺寸与代表性动态内容；所有文字、
  HP／Power 和 Button hitbox 均落在安全区。玩家／目标端帽非镜像，紧凑框采用
  减法，Focus 布结有实体压接；Target Aggro 与 Focus Hover 均为断续短边。
  几何图不证明正式笔触、微纹理、Alpha 或远端屏幕位置。

### 用户方向结论

- 具体模拟版本：`UF-PRIMARY-SIM-V1`
- 用户结论与日期：`confirmed / 2026-08-11`
- 用户原文：`接受 UF-PRIMARY-SIM-V1`
- 确认并写回生产正文的可见条款：
  - 四个框首先读作同一工匠体系、长期携带并手工修补的粗犷行军身份牌，不能
    读作现代卡片、黑铁圣龛、书本缩略件或规整金框。
  - 深胡桃旧皮革是主结构，烟褐内衬承托动态条，氧化黄铜只形成短促、断续、
    不对称的夹片与铆钉；左上暖光和低饱和综合色必须与现有 Chat 同年代。
  - Player 左端修补偏重；Target 右端破损压片偏重；二者从零独立绘制且不得
    镜像。TargetTarget／Focus 用减法形成紧凑身份牌，不能缩放大框。
  - Focus 只使用一段褪色靛蓝猎踪布结识别；布结被皮革夹层和一枚暗铜钉真实
    压住，不漂浮、不发光、不侵入内容走廊。
  - 外轮廓只做低频歪斜，端部、铆钉、缺口与修补位置不等；粗犷来自使用和
    维修逻辑，不是随机噪声。中央动态内容区持续安静。
  - Hover／Aggro 只呈现两三段断续短边响应，不形成整框霓虹；当前无头像
    profile 不生成圆形假头像槽。
- 非确认项：模拟图像素、微纹理、手绘笔触、Alpha、切片、最终贴图接缝及
  另一台设备的屏幕位置。
- 确认失效条件：物件隐喻、材料主次、非镜像结构、Focus 识别件、综合色重或
  与现有 UI 的整合关系发生实质变化。
- 下一门禁：用户看过并明确授权三段最终生产正文；本方向确认不等于正式
  ImageGen 授权。

## 生产正文完整性预检

- 复杂度：三个独立 atlas／state 执行正文。
- 当前结论：`pass`；模拟确认条款、固定参考职责、对象／状态、画布、边界、
  runtime 几何、动态排除、色键和最终自检均已进入各自完整正文。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 身份、范围、对象数量与动态排除 | A1／A2 均固定上下两件空外壳；B1 固定两条无色 donor；文字、头像、图标、状态与颜色语义逐项排除 | pass |
| 图片输入职责与冲突 | A1／A2 逐张定义 Image 1／2 的 inherit／ignore，并声明文字合同优先；B1 明确无图片输入 | pass |
| Canvas、格位、方向、尺度、光照与层序 | 三段均固定画布、上下半区、隔离带、正视二维方向、左上暖光和目标 bbox 比例 | pass |
| 逐对象轮廓、材料与关系 | 非镜像 Player／Target、减法紧凑框、Focus 实体压接布结及两条不同密度颜料纹均单列 | pass |
| 安静区、裁切、拉伸与接缝 | 四壳完整保留真实 bar stack；两 donor 禁止中心焦点、重复接缝和全宽划痕 | pass |
| 美术 DNA、反模式、色键与自检 | 香草手绘、低饱和材料层级、低频维修不规则、纯绿隔离与每段客观末检均明确 | pass |

- `UF-A1`：两个对象、固定两格、同尺寸但非镜像、动态内容排除、色键与
  `214×42` 等比 bbox-fit 已明确。
- `UF-A2`：两个不同高度对象、固定两格、Focus 布结、紧凑减法与各自安全区
  已明确。
- `UF-B1`：两条灰阶不透明 donor、运行时着色、横向拉伸与重复节奏已明确。
- 未知但执行必需的值：无；远端屏幕位置不影响本批资源生成。
- 去冗余结论：保留对象数量、输入职责、动态排除、物理压接、非镜像、
  safe-area、色键与反现代门禁的必要重复；不把模拟历史或情绪描述塞入正文。

## 最终执行正文

状态：`production / authorized 2026-08-11`。以下三段已完整吸收
`UF-PRIMARY-SIM-V1` 的确认结论并获得用户逐项授权；首次调用必须原样执行。
模拟图不得上传或成为生产输入。

### `UF-A1 V1` — Player／Target 大外壳

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Never copy either reference's object geometry. If an image conflicts with this
text, follow this text.

Create one production-ready 1536 by 1024 bitmap sheet containing exactly two
separate horizontal unit-frame shell objects on a perfectly uniform pure
#00FF00 background. The upper 1536 by 512 cell is the Player shell and the
lower 1536 by 512 cell is the Target shell. Draw no other object. Show both as
front-facing orthographic 2D game-UI assets with no scene, camera tilt or
perspective foreshortening. Each shell must remain fully inside its own half,
with at least 96 pixels of pure-green isolation from the canvas edges and cell
boundary. Give each an approximately 5.10:1 visible bbox suitable for
proportional, non-distorting fit to exactly 214 by 42 runtime pixels.

These are empty physical shells around an existing pfUI bar stack, not complete
unit frames. Leave the entire central live-content corridor visually open and
quiet for a 200 by 25 health bar plus a 200 by 4 power bar. Do not draw any
fill, portrait, name, level, number, icon, aura, status text, classification,
button or glow. The dynamic bars and text are drawn by the game.

Both objects are restrained, hand-repaired Azeroth expedition field badges:
compact equipment carried through a long campaign, not decorative fantasy
plaques. Use thick deep-walnut worn leather as the main structure, a soot-brown
inner liner, a few short pieces of dull oxidized brass and two or three coarse
repair stitches. Use circa-2004 Vanilla WoW hand-painted bitmap language,
low-resolution readable masses, warm upper-left light, short broken highlights
and real contact shadows. The long edges may wander gently only at low
frequency. Unequal ends, rivets, nicks and repairs must look caused by use and
field maintenance, never by all-over random noise.

The Player shell has a slightly heavier, crooked brass clamp and two coarse
stitches at the left end, while its right end is mostly worn leather with one
off-centre rivet. The Target shell must be redrawn independently rather than
mirrored: its right end carries a visibly damaged short brass compression plate
and its left end is mainly a polished leather fold. Keep both central corridors
calm and the ornament subordinate to live combat information.

Do not make complete continuous gold outlines, matching corner ornaments,
perfect rounded rectangles, web cards, glass panels, industrial rivet grids,
black-iron shrines, skulls, horns, large crests, portrait wells, book pages,
book spines, wax seals, dragons, gemstones, neon or photoreal antiques. Outside
the two objects every pixel must be pure #00FF00, including the open central
corridors and the isolation band. Before returning, verify exactly two shells,
correct upper Player/lower Target order, no baked dynamic content, no mirror
duplication, no edge contact and no non-green pixel outside the two cells.

### `UF-A2 V1` — TargetTarget／Focus 紧凑外壳

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Never copy either reference's object geometry. If an image conflicts with this
text, follow this text.

Create one production-ready 1024 by 1024 bitmap sheet containing exactly two
separate compact horizontal unit-frame shell objects on a perfectly uniform
pure #00FF00 background. The upper 1024 by 512 cell is TargetTarget and the
lower 1024 by 512 cell is Focus. Draw both as front-facing orthographic 2D
game-UI assets with no scene, camera tilt or perspective foreshortening. Keep
at least 72 pixels of pure-green isolation from canvas edges and the cell
boundary. The upper visible bbox must be approximately 3.294:1 for
proportional, non-distorting fit to exactly 112 by 34 runtime pixels; the lower
must be approximately 2.872:1 for fit to exactly 112 by 39. Do not draw any
other object.

These shells surround real pfUI bars. Keep the full central corridor quiet for
a 100 by 20 plus 100 by 1 bar stack in TargetTarget and a 100 by 25 plus 100 by
1 stack in Focus. Draw no bar fill, portrait, text, number, icon, aura, status,
classification, click control or glow.

Use a restrained hand-repaired Azeroth expedition field-badge identity:
deep-walnut worn leather, soot-brown liner, restrained oxidized brass, warm
upper-left light, thick readable silhouette, real contact depth and
low-frequency hand-cut irregularity in circa-2004 Vanilla WoW bitmap language.
The irregularity must follow wear and repair rather than random noise. These
are compact purpose-built objects, not scaled copies of the large shells.
TargetTarget is the quietest member: thin worn leather, only two or three short
brass traces, unequal ends and no centre ornament.

Focus uses the same restrained compact structure but has one small faded-indigo
hunter's tracking cloth knot emerging from the upper-right leather seam. The
cloth must be physically trapped under the leather and one dull brass rivet;
it may not float, glow or intrude into the live-content corridor. This cloth is
the sole focus identifier. Do not use a gem, rune ring, wax seal or blue neon
outline.

Forbid continuous gold trim, matched corners, perfect rounded cards, glass,
industrial grids, black-iron altars, skulls, horns, book parts, large crests,
portraits, text and dynamic game content. Outside and inside the open shell
corridors every background pixel must remain pure #00FF00. Verify exactly two
objects, upper/lower identity, distinct proportions, physical cloth attachment,
quiet corridors, isolation margins and no edge contact.

### `UF-B1 V1` — Health／Power 无色填充纹

No reference images are supplied for this body; everything required is stated
below. Create one production-ready 1024 by 1024 bitmap sheet with exactly two
separate horizontal opaque grayscale paint-texture swatches on a perfectly
uniform pure #00FF00 background. The upper 1024 by 512 cell contains only the
Health fill donor at approximately 2:1 visible bbox for proportional,
non-distorting fit to exactly 64 by 32. The lower 1024 by 512 cell contains only
the Power fill donor at approximately 4:1 for fit to exactly 64 by 16. Show both
front-facing with at least 80 pixels of pure-green isolation from canvas edges
and the cell boundary. Each swatch must be a plain rectangle with no frame,
cap, text, icon, colour meaning or glow.

Both swatches are neutral grayscale because pfUI supplies health, reaction,
class and power colours at runtime. Use matte hand-painted mineral pigment with
subtle low-frequency horizontal brush drag and slight pigment accumulation.
Health is a little coarser and deeper; Power is narrower, calmer and slightly
denser. Keep the middle overwhelmingly quiet so horizontal stretch and
StatusBar clipping never reveal a focal motif or repeating seam.

The material must read as a Vanilla-era painted bar surface, not leather,
parchment, brushed metal, glass or fabric. No diagonal stripe, bevel shine,
central hotspot, gradient gloss, noise carpet, scratches crossing the entire
width, transparent holes or chromatic tint. Maintain fully opaque swatches,
pure #00FF00 everywhere else and at least a broad green gap between them.
Verify exactly two neutral swatches, upper Health/lower Power order, no colour
cast, no dynamic content, no edge contact and no non-green pixels outside them.

## 自主修复循环

- 不可变边界：上述三段各自的组件 ID、对象数量与顺序、参考图职责、Canvas、
  runtime 尺寸、正视方向、动态内容排除、材料主次、色键和最多五次实际生图。
- 固定上传：`UF-A1 V1` 与 `UF-A2 V1` 的每次调用都只允许上传本文件固定 SHA
  的 Image 1／2，顺序和职责不变；`UF-B1 V1` 的首次调用不上传图片。
- 允许修复：同段内调整占用率、低频端帽不规则、材料粗细、磨损／修补位置、
  Focus 布结的物理接触和纯绿隔离。A1／A2 只有明确保留正确区域时，才允许把
  同段紧邻前次输出作为 Image 3 edit 输入；B1 同条件下作为 Image 1 edit
  输入。不得跨段复用像素。
- 允许的确定性候选处理：按固定上下半区拆分；只做边缘连通 `#00FF00`
  色键、透明 RGB 清零和各对象等比 bbox-fit。源 bbox 与目标比例误差超过 `1%`
  时必须退回，禁止非等比压缩。正式候选每次都要以真实 runtime 尺寸、真实
  动态文字／条／状态和当前邻接 UI 生成排版预演；这些处理不构成 P4 接受。
- 必须重新授权：新增／删除对象、改变物件身份、使用新参考、改变 Canvas／
  runtime 几何、改成头像结构、改变综合色方向或跨段复用像素。

## 执行记录

- 日期：`2026-08-11`
- 操作：本地确定性几何模拟；未启动固定 ImageGen 子进程。
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- 规格／渲染器：`tools/specs/unitframes_primary_simulation_v1.json`／
  `tools/render_unitframes_primary_simulation_v1.py`
- 输出：本文件“生成前模拟实例图”所列 scene／zoom。
- 实际 ImageGen：`0/0`；流程错误：`0`。
- 循环终态：`simulation-confirmed`；正式生产循环尚未开始。

## 正式生产循环

### `UF-A1 V1`

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `UF-A1 V1` / `d902e2b` | generate | child `019fee93-168d-7360-85c0-e7d02095deff`／result `ig_019be3007b694521016a7a83ee64d88191aa391033b667c3df` | raw `generated/unitframes/primary/UF-A1/V1/attempt-01/raw/UF-A1_V1_attempt-01.png`／SHA `80d928ac…33d3` | 组件合同：两框纵横比与动态安全走廊失败 | 保留深胡桃材质、克制装饰和 Player 左／Target 右非镜像关系；用 Image 3 edit 修正比例、隔离、开口与内缘 | failed；进入 `V1.r1` |
| 2/5 | `UF-A1 V1.r1` / `c89e4f5` | edit | child `019fee9c-00fb-7a23-88c0-505b2f4cc403`／result `ig_07ff1b0e8d890a18016a7a863faedc8191b62e96b3d6bc4427` | raw `generated/unitframes/primary/UF-A1/V1/attempt-02/raw/UF-A1_V1_r1_attempt-02.png`／SHA `6b2af557…0346` | 组件合同：纵横比、安全走廊及 Player 隔离再次失败 | 保留同族材料与非镜像语义；改变策略，不再使用 Image 3，按更薄轨道和窄端帽从固定参考 regenerate | failed；进入 `V1.r2` |
| 3/5 | `UF-A1 V1.r2` / `7a7c3ce` | regenerate | child `019feea5-6b2c-7ae1-88fd-94cae36e8cc0`／result `ig_0e5284289500fcb2016a7a889e347c8191ab40c73932895364` | raw `generated/unitframes/primary/UF-A1/V1/attempt-03/raw/UF-A1_V1_r2_attempt-03.png`／SHA `d7a42d40…7f5f` | 组件合同：两框过扁，比例约 `7.63:1`／`7.73:1`，运行时安全走廊失败 | 冻结明显改善的薄轨、深胡桃材质与非镜像语义；以 Image 3 edit 重新拉开上下轨并延长侧轨，禁止非等比拉伸 | failed；进入 `V1.r3` |
| 4/5 | `UF-A1 V1.r3` / `0a3a1f5` | edit | child `019feea9-d3aa-7721-bb18-6fc4e6e031b6`／result `ig_09f4ff58c55329aa016a7a89c2fe5081918864d16ddd3300ed` | raw `generated/unitframes/primary/UF-A1/V1/attempt-04/raw/UF-A1_V1_r3_attempt-04.png`／SHA `abc6810f…bae9` | 组件合同：比例改善但仍过扁，端柱过宽且安全走廊失败 | 冻结材质和身份差异；以 Image 3 edit 横向缩短约 5%、延长侧轨约 10–15%、两端柱缩窄超过一半 | failed；进入最终 `V1.r4` |
| 5/5 | `UF-A1 V1.r4` / `448a8dd` | edit | child `019feeae-61b4-7c62-990d-bd20c8536b88`／result `ig_00ccd1c003ebf324016a7a8aeaa7f88191a46c8937c7e3a9b3` | raw `generated/unitframes/primary/UF-A1/V1/attempt-05/raw/UF-A1_V1_r4_attempt-05.png`／SHA `56ae9ae5…06a3` | 展示区域合同：比例通过，但端柱侵入动态走廊且横向隔离不足 | 保留第 5 稿完整候选供用户审计；不得继续同版生图、不得 source/runtime；A2/B1 按五次规则暂停 | `candidate-rejected / repair-budget-exhausted` |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `UF-A1 V1` / `d902e2b` | unified exec `99073`；无 child session／result | 固定 child 在读取 prompt 前退出：`No prompt provided. Either specify one as an argument or pipe the prompt into stdin.`；无图片、无 provider result、无生成证据 | 保持提交正文和 Image 1／2 完全不变，只把同一参数从 argv transport 改为 CLI 明示的 stdin transport | 不占 `0/5`；以同一正文重试 |
| E2 | `UF-A1 V1.r2` / `7a7c3ce` | unified exec `42462`；无 child session／result | sandbox 内 npm 请求 registry／写 npm log 返回 `EPERM`；无图片、无 provider result、无生成证据 | 保持提交正文和 Image 1／2／无 Image 3 完全不变，仅按权限规则在获准环境复跑同一固定命令 | 不占 `2/5`；以同一正文重试后正常生成 attempt 3 |

#### Attempt 1 审查

- 输入：固定 Image 1 SHA `90e30ba…ee06`、Image 2 SHA `272528e6…aab8`；无
  Image 3。正文来自提交 `d902e2b`，stdin transport 完整回显；fixed child 未
  报告 revised prompt。
- 原始输出：`1536×1024 RGB`；SHA
  `80d928ac1f07d090da2b28b5eeede38055683dab58cf3909f8c71b3d282533d3`。
- 范围／语义：恰有上下两张空外壳，没有文字、头像、图标或状态；Player 左端
  黄铜修补较重、Target 右端破损压片较重，二者没有镜像复用。通过。
- 物理／美术：深胡桃皮革、少量黄铜、粗线结和接触阴影成立，装饰克制；但
  内开口过窄且呈规则胶囊圆角，粗犷维修逻辑不足。该项必须在几何修复时一并
  收敛，不能保留其规整内缘。
- 第一失败门禁：Player keyed bbox `1343×280`，比例误差 `5.864486%`；Target
  `1295×266`，误差 `4.451549%`，均超过授权 `1%`。Player 下隔离 `88px`，
  低于 `96px`。等比装入 `214×42` 后两框分别只有 `201×42`／`204×42`，真实
  `200×30` 动态走廊分别被 `3875`／`3599` 个可见 Alpha 像素侵入。
- 确定性处理：固定两格；外边缘与声明的中央内容孔连通色键；一像素 despill；
  透明 RGB 清零；只做等比 fit，无非等比压缩。
- 技术报告：
  `generated/unitframes/primary/UF-A1/V1/attempt-01/review-report.json`；
  `overall_technical_pass=false`。
- 真实排版：
  `generated/unitframes/primary/UF-A1/V1/attempt-01/real-layout-preview.png`，SHA
  `e9e6a6a9f3a87ea53f8c961f8b2b39fdd8588178db5e38526e561ce2e0139073`；
  Player／Target 候选为 `100%` runtime，动态条与文字为真实几何；屏幕锚点、
  TargetTarget／Focus 和动作条为明确非权威 fallback。预演可见端帽挤压条形区。
- 结论：`failed / attempt 1 of 5`；不允许用户复审、source 或 runtime。

#### `UF-A1 V1.r1` 完整修复正文

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Image 3 is the immediately preceding UF-A1 attempt. Preserve only its deep-
walnut material handling, restrained amount of ornament, Player-left versus
Target-right non-mirrored identity and coarse field-repair feeling. Do not
preserve its too-tall proportions, narrow inner holes, pill-shaped inner
corners, cell placement or exact silhouette. If any image conflicts with this
text, follow this text.

Edit into one production-ready 1536 by 1024 bitmap sheet containing exactly two
separate horizontal unit-frame shell objects on a perfectly uniform pure
#00FF00 background. The upper 1536 by 512 cell is the Player shell and the
lower 1536 by 512 cell is the Target shell. Draw no other object. Show both as
front-facing orthographic 2D game-UI assets with no scene, camera tilt or
perspective foreshortening.

Make each complete visible shell bbox approximately 1320 pixels wide by 259
pixels high, a 5.0965:1 ratio within one percent of the required 5.10:1. Centre
each inside its own half: keep every visible Player pixel approximately within
x 108..1428 and local y 125..384, and every visible Target pixel within the
same safe envelope in its lower cell. Keep at least 96 pixels of uniform green
between every object and the canvas edges or horizontal cell boundary. The
result must support proportional, non-distorting fit to exactly 214 by 42
runtime pixels.

These are empty physical shells around an existing pfUI bar stack, not complete
unit frames. In each shell, the pure-green inner opening must occupy at least
93.5 percent of the shell bbox width and 71.5 percent of its height so the
entire runtime corridor x 7..207 and y 6..36 remains transparent for a 200 by
25 health bar, a one-pixel gap and a 200 by 4 power bar. Keep end clamps,
stitches, leather folds and every opaque edge completely outside that corridor.
Do not make the opening a perfect pill: use subtly unequal, hand-cut inner
corners and low-frequency edge drift while retaining the full safe corridor.
Do not draw any fill, portrait, name, level, number, icon, aura, status text,
classification, button or glow. Dynamic bars and text are drawn by the game.

Both objects are restrained, hand-repaired Azeroth expedition field badges:
compact equipment carried through a long campaign, not decorative fantasy
plaques. Use thick deep-walnut worn leather as the main structure, a soot-brown
inner liner, a few short pieces of dull oxidized brass and two or three coarse
repair stitches. Use circa-2004 Vanilla WoW hand-painted bitmap language,
low-resolution readable masses, warm upper-left light, short broken highlights
and real contact shadows. The long edges may wander gently only at low
frequency. Unequal ends, rivets, nicks and repairs must look caused by use and
field maintenance, never by all-over random noise.

The Player shell has a slightly heavier crooked brass clamp and two coarse
stitches at the left end, but compress that end treatment enough to preserve
the full inner opening. Its right end is mostly worn leather with one off-
centre rivet. Redraw the Target independently rather than mirroring: its right
end carries a visibly damaged short brass compression plate, compressed clear
of the safe corridor, while its left end is mainly a polished leather fold.
Keep both centres calm and all ornament subordinate to live combat information.

Do not make complete continuous gold outlines, matching corner ornaments,
perfect rounded rectangles, web cards, glass panels, industrial rivet grids,
black-iron shrines, skulls, horns, large crests, portrait wells, book pages,
book spines, wax seals, dragons, gemstones, neon or photoreal antiques. Outside
the two shells and inside both open content corridors every pixel must be pure
#00FF00. Before returning, verify exactly two shells, correct upper Player and
lower Target order, 5.10:1 bboxes within one percent, at least 96 pixels of
isolation, full green runtime corridors, no baked dynamic content, no mirror
duplication, no edge contact and no non-green pixels outside the two cells.

#### Attempt 2 审查

- 输入：固定 Image 1／2 与同段 attempt 1 作为 Image 3；完整 `V1.r1` 正文来自
  `c89e4f5`。child 完整回显正文，未启动递归 child；未报告 revised prompt。
- 原始输出：`1536×1024 RGB`；SHA
  `6b2af5579a9d78e1d4729d76ccb1f24c7cebc0d494b464b0dd11a7a15a280346`。
- 语义／美术：仍为两张同族非镜像身份牌，Player 左端和 Target 右端的维修
  关系清楚，材质与综合色可保留。内缘仍过于规则、皮革轨过厚、端帽横向占用
  过大，继续遮挡真实条形区。
- 第一失败门禁：Player keyed bbox `1352×279`、比例误差 `4.893981%`，Target
  `1313×271`、误差 `4.910853%`；Player 下隔离 `85px`。真实 `200×30`
  走廊分别被 `3761`／`3550` 个可见 Alpha 像素侵入。相同首要失败连续两次，
  按有界循环必须改变修复策略。
- 技术报告：
  `generated/unitframes/primary/UF-A1/V1/attempt-02/review-report.json`；
  `overall_technical_pass=false`。
- 真实排版：
  `generated/unitframes/primary/UF-A1/V1/attempt-02/real-layout-preview.png`，SHA
  `c782bb728e77feecea977e34b4cae4bc33a887874e2bdd124cadd593203763b7`；
  100% runtime 下两端装饰仍压住条端，未达到候选复审条件。
- 执行环境说明：本次 fixed child 在仓库 read-only workdir 内生成并返回 cache
  PNG，父流程原样复制到 ignored raw。生成已经发生，因此正常计为 `2/5`；
  后续按仓库 wrapper 新规则改用空临时 `-C` 与 `workspace-write`，只修复落盘和
  wrapper 发现路径，不改变授权正文、输入或计数。
- 结论：`failed / attempt 2 of 5`；不允许用户复审、source 或 runtime。

#### `UF-A1 V1.r2` 完整修复正文

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Do not use or imitate either preceding UF-A1 output: their frames are too tall,
their end blocks are too wide and their inner holes are too narrow. Generate
new geometry from the written contract. If an image conflicts with this text,
follow this text.

Create one production-ready 1536 by 1024 bitmap sheet containing exactly two
separate, very slender horizontal unit-frame shell objects on a perfectly
uniform pure #00FF00 background. The upper 1536 by 512 cell is the Player shell
and the lower 1536 by 512 cell is the Target shell. Draw no other object. Show
both as front-facing orthographic 2D game-UI assets with no scene, camera tilt
or perspective foreshortening.

The final visible bbox of each shell must be approximately 1320 pixels wide by
259 pixels high, 5.0965:1 and within one percent of the required 5.10:1. Keep
all painted details inside x 108..1428 and local y 125..384 in each cell, with
at least 96 pixels of uniform green to every canvas edge and the horizontal
cell boundary. Construct the main leather rails even thinner, inside a local
vertical band no more than 225 pixels high, so low-frequency worn protrusions
may remain inside the final 259-pixel bbox without making it too tall. This
must proportionally fit exactly 214 by 42 runtime pixels with no deformation.

These are thin perimeter overlays around existing pfUI bars, not bulky plaques.
The pure-green inner opening must be at least 1235 pixels wide and 186 pixels
high. Each left or right opaque end structure may occupy no more than 42 pixels
between the outer bbox and the green opening. Each top or bottom leather rail,
including liner and shadow, may occupy no more than 36 pixels. The complete
runtime corridor x 7..207 and y 6..36 must therefore remain transparent for a
200 by 25 health bar, a one-pixel gap and a 200 by 4 power bar. No stitch,
rivet, clamp, fold, shadow or leather protrusion may enter that corridor.
Do not turn the opening into a perfect pill: use slightly unequal hand-cut
inner corners and subtle low-frequency edge drift, while preserving the full
rectangular safe area. Draw no fill, portrait, name, level, number, icon, aura,
status text, classification, button or glow.

Both objects are restrained, hand-repaired Azeroth expedition field badges:
compact campaign equipment, not decorative fantasy plaques. Deep-walnut worn
leather is the main structure, soot-brown liner is secondary, and dull oxidized
brass appears only as tiny interrupted repairs. Use circa-2004 Vanilla WoW
hand-painted bitmap language, low-resolution readable masses, warm upper-left
light, short broken highlights and real contact shadows. Irregularity must be
low-frequency and caused by use and field maintenance, never all-over noise.

The Player shell has a tiny crooked brass clamp and two coarse stitch marks
confined to its leftmost 42-pixel end strip; its right end is mostly worn
leather with one off-centre rivet. Draw the Target independently, never mirror
it: confine a damaged short brass compression plate to its rightmost 42-pixel
end strip, while the left end is only a polished leather fold. These end marks
must remain legible but much narrower than the earlier attempts. Keep the long
centre visually calm and subordinate to combat information.

Do not make wide U-shaped end caps, continuous gold outlines, matching corner
ornaments, perfect rounded rectangles, web cards, glass panels, industrial
rivet grids, black-iron shrines, skulls, horns, large crests, portrait wells,
book parts, wax seals, dragons, gemstones, neon or photoreal antiques. Outside
the two shells and inside both open content corridors every pixel must be pure
#00FF00. Before returning, verify exactly two shells, upper Player and lower
Target order, final 5.10:1 bboxes within one percent, at least 96 pixels of
isolation, inner openings at least 1235 by 186, end structures no wider than
42 pixels, rails no thicker than 36 pixels, no baked dynamic content, no
mirror duplication and no edge contact.

#### Attempt 3 审查

- 输入：固定 Image 1／2；按策略变更不使用 Image 3。完整 `V1.r2` 正文来自
  `7a7c3ce`，fixed child 完整回显正文、未递归启动固定 child，未报告 revised
  prompt。
- 原始输出：`1536×1024 RGB`；SHA
  `d7a42d40435a75118523f3e97cf5f3db7ade107ff39e42f0b11e92ab46307f5f`。
- 语义／美术：薄轨、深胡桃磨损、Player 左端缝线／Target 右端黄铜压片和
  克制中心均明显优于前两稿；没有动态文字、条、图标或镜像复用。这些区域可
  冻结。背景并非逐像素纯 `#00FF00`，但外部和中央色键均保持连通，确定性
  pipeline 可无损职责地清除；不把该技术偏差作为第一失败门禁。
- 第一失败门禁：Player keyed bbox `1381×181`、比例误差 `49.744411%`；Target
  `1383×179`、误差 `51.636819%`。等比 fit 后均只有 `214×28`，上下各留
  `7px`，导致运行时安全走廊分别被 `2640`／`2619` 个可见 Alpha 像素侵入；
  Player 左／右隔离 `77`／`78px`、Target 左／右 `79`／`74px`，亦低于
  `96px`。本稿从“过厚”越过目标成为“过扁”，下一稿必须通过重建几何而非
  拉伸来命中中间值。
- 确定性处理：固定两格；外边缘与中央孔连通色键；一像素 despill；透明 RGB
  清零；只做等比 bbox-fit，无非等比缩放。
- 技术报告：
  `generated/unitframes/primary/UF-A1/V1/attempt-03/review-report.json`；
  `overall_technical_pass=false`。
- 真实排版：
  `generated/unitframes/primary/UF-A1/V1/attempt-03/real-layout-preview.png`，SHA
  `7fc9ce8a56c5940dc6f69974597ac87d478935ad525967d8ef8c8bb57bd33143`；
  候选 shell 为 `100%` runtime，真实 bar 几何显示外框上下轨落入条形内容区。
- 结论：`failed / attempt 3 of 5`；不允许用户复审、source 或 runtime。

#### `UF-A1 V1.r3` 完整修复正文

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Image 3 is the immediately preceding UF-A1 attempt. Preserve only its thin
deep-walnut rails, restrained brass quantity, calm long centres, hand-painted
wear, Player-left stitch repair and Target-right compression-plate identity.
Its two shells are much too flat at about 7.7:1, too wide in their cells and
have short side rails. Do not preserve those dimensions or positions. If any
image conflicts with this written contract, follow this text.

Edit Image 3 into one production-ready 1536 by 1024 bitmap sheet containing
exactly two separate horizontal unit-frame shell objects on a perfectly
uniform pure #00FF00 background. The upper 1536 by 512 cell is the Player shell
and the lower 1536 by 512 cell is the Target shell. Draw no other object. Keep
both front-facing orthographic 2D game-UI assets with no scene, tilt,
perspective, dynamic content or cast shadow extending outside their bboxes.

Rebuild the geometry; never stretch or non-uniformly scale the preceding
pixels. Give each complete visible shell an exclusive bbox exactly 1320 pixels
wide by 259 pixels high, ratio 5.0965:1 and within one percent of 5.10:1.
Position the upper visible bbox at x 108..1428 and y 126..385. Position the
lower visible bbox at x 108..1428 and global y 638..897, the same local
y 126..385 in its cell. These exclusive-coordinate envelopes leave at least
96 pixels of pure green on all four sides and around the horizontal cell
boundary. Do not retain Image 3's current upper-low and lower-high placement.

The change must look like a physical reconstruction: move the upper rail
upward, move the lower rail downward and repaint longer upright side rails
between them. Keep the rail material itself thin; do not make leather bands
thicker merely to increase total height. In each 1320 by 259 bbox, reserve a
completely pure-green inner opening from local x 42 through 1278 and local
y 36 through 223, at least 1236 by 187 pixels. No opaque or shadow pixel may
enter that rectangle. Thus each left and right end structure is at most
42 pixels wide and each top and bottom rail, including liner and shadow, is at
most 36 pixels high. After proportional fit to exactly 214 by 42 runtime
pixels, the whole x 7..207 and y 6..36 content corridor must be transparent
for a 200 by 25 health bar, one-pixel gap and 200 by 4 power bar.

Preserve the preceding attempt's irregular but restrained field-made quality.
The long rails may have subtle low-frequency drift, broken highlights and a
few material joins, but the guaranteed inner rectangle must remain clear.
Keep the Player's crooked left stitch repair wholly inside its leftmost
42-pixel strip; reduce or repaint it rather than letting it intrude. Keep its
right end as worn leather with one off-centre rivet. Repaint the Target
independently: keep its damaged brass compression plate wholly inside its
rightmost 42-pixel strip and its left end as a polished leather fold. Never
mirror the two frames and never turn the opening into a perfect pill.

Use deep-walnut worn leather, soot-brown liner and only tiny interrupted dull
oxidized brass, in circa-2004 Vanilla WoW hand-painted bitmap language. Use
warm upper-left illumination, thick readable low-resolution masses, short
broken highlights and believable contact depth. Irregularity must remain
low-frequency and caused by travel and field repair, not all-over texture
noise. The long centres stay visually quiet and subordinate to combat data.

Draw no fill, portrait, name, level, number, icon, aura, status text,
classification, button or glow. Do not add wide U-shaped end caps, continuous
gold outlines, matching corners, perfect rounded rectangles, web cards, glass,
industrial rivet grids, black-iron shrines, skulls, horns, crests, portrait
wells, pages, spines, wax seals, dragons, gemstones, neon or photoreal
antiques. Outside the two rebuilt shells and inside both declared openings
every pixel must be pure #00FF00. Before returning, verify exactly two shells,
upper Player and lower Target order, exact 1320 by 259 bboxes within the stated
envelopes, 5.10:1 within one percent, inner openings at least 1236 by 187,
end strips no wider than 42, rails no thicker than 36, no non-uniform stretch,
no baked dynamic content, no mirror duplication and no edge contact.

#### Attempt 4 审查

- 输入：固定 Image 1／2 与同段 attempt 3 raw 作为 Image 3；完整 `V1.r3` 正文
  来自 `0a3a1f5`。child 完整回显正文和三张图映射，未启动递归 fixed child，
  未报告 revised prompt。
- 原始输出：`1536×1024 RGB`；SHA
  `abc6810fcf6d6c7713b3be4097121e12d585f12365a1eabd20e0e827bc16bae9`。
- 语义／美术：保留了第 3 稿的薄皮革轨、低频磨损与左右非镜像维修；Player
  缝线和 Target 压片清楚，但 Target 黄铜片仍过大，二者端柱仍像宽端帽。
- 第一失败门禁：Player bbox `1380×237`、比例误差 `14.278954%`；Target
  `1381×225`、误差 `20.461059%`，虽较 attempt 3 改善但仍超过 `1%`。等比
  fit 只有 `214×37`／`214×35`，安全走廊仍有 `1640`／`1990` 个可见 Alpha
  像素。Player 左／右隔离 `76`／`80px`，Target `78`／`77px`，均显示横向
  仍需收进约 `32px/侧`；Target 上隔离 `101px` 已通过，其余位置仍需按声明
  envelope 重排。
- 技术报告：
  `generated/unitframes/primary/UF-A1/V1/attempt-04/review-report.json`；
  `overall_technical_pass=false`。
- 真实排版：
  `generated/unitframes/primary/UF-A1/V1/attempt-04/real-layout-preview.png`，SHA
  `7ce9d80545e4d764d401fd784bd7f45398a3914b07d0fefc66d6e1f528033c83`；
  100% runtime 可见两框仍贴压实际 bar 末端，不可作为审美例外跳过合同。
- 结论：`failed / attempt 4 of 5`；进入最后一次有界修复，不允许 source 或
  runtime。

#### `UF-A1 V1.r4` 完整修复正文

The written requirements below are controlling. Image 1 is a secondary
reference only for circa-2004 Vanilla WoW bitmap scale, thick readable masses,
short dull-brass highlights and overall visual weight; ignore its whole-screen
layout, portrait circles and every unit-frame example. Image 2 is a secondary
reference only for deep-walnut material depth, warm upper-left illumination,
hand-made edge error and the frequency of believable wear; ignore its pages,
spine, columns, dragons, book silhouette and extensive gold architecture.
Image 3 is the immediately preceding UF-A1 attempt. Preserve its deep-walnut
material, thin horizontal rails, low-frequency wear, calm centres, Player-left
stitch identity and Target-right brass-repair identity. Do not preserve its
too-wide canvas occupancy, 5.82:1 and 6.14:1 proportions, short side rails,
wide end posts, large Target brass plate or vertical positions. This written
contract overrides every image.

Perform a restrained geometry edit, not a new stylistic design. Return one
production-ready 1536 by 1024 bitmap sheet with exactly two separate empty
unit-frame shells on a uniform pure #00FF00 background: Player in the upper
1536 by 512 cell and independently drawn Target in the lower cell. Keep them
front-facing orthographic 2D, with no scene, perspective or other objects.

Apply exactly these three structural corrections while repainting the affected
junctions naturally:

1. Shorten each complete shell horizontally by about five percent and centre
   it, moving both outer side assemblies inward until the visible bbox begins
   at x 108 and ends before x 1428. The final exclusive width is 1320 pixels.
2. Without thickening either horizontal leather rail, move the top rail upward
   and the bottom rail downward. Repaint and lengthen both upright side rails
   so the Player bbox is y 126..385 and the Target bbox is global y 638..897.
   Each final exclusive height is 259 pixels. Player and Target must therefore
   both be 1320 by 259, ratio 5.0965:1 and within one percent of 5.10:1.
3. Cut the left and right end posts to less than half their current width. Each
   opaque side assembly, including stitch, fold, rivet, brass, liner and shadow,
   is at most 42 pixels wide. Shrink the Target brass plate by more than half;
   it is a small damaged repair strip, never a square plaque. Each top or bottom
   rail including liner and shadow is at most 36 pixels high.

The guaranteed pure-green hole inside each 1320 by 259 bbox runs from local
x 42 through 1278 and local y 36 through 223, at least 1236 by 187 pixels.
Nothing may cross this hole: no leather tip, corner curl, stitch, rivet, brass,
highlight or shadow. This maps proportionally to the exact runtime transparent
corridor x 7..207 and y 6..36 within a 214 by 42 shell, surrounding a 200 by
25 health bar, a one-pixel gap and a 200 by 4 power bar. Do not solve this by
stretching pixels, thickening rails, cropping an end, filling the hole or
making a perfect pill. Reconstruct the side rails and corner joints.

Preserve the established restrained field-made art: deep-walnut worn leather,
soot-brown liner and tiny interrupted dull oxidized brass in circa-2004
Vanilla WoW hand-painted bitmap language. Use warm upper-left illumination,
readable low-resolution masses, short broken highlights, believable contact
depth and only subtle low-frequency edge drift. Keep the Player's two crooked
stitches entirely inside the narrow left 42-pixel post and one off-centre
rivet in its narrow right post. Draw the Target independently, with a polished
leather fold in its narrow left post and the reduced damaged brass repair
inside its narrow right post. Never mirror them. Keep long centres quiet.

Draw no fill, portrait, name, level, number, icon, aura, status text,
classification, button or glow. Do not add wide U-shaped caps, continuous gold
outlines, matching corners, perfect rounded rectangles, web cards, glass,
industrial rivet grids, black-iron shrines, skulls, horns, crests, portrait
wells, book parts, wax seals, dragons, gemstones, neon or photoreal antiques.
Outside the two shells and inside both holes every pixel must be pure #00FF00.
Before returning, measure and verify both bboxes are 1320 by 259 within the
declared cell positions, both ratios are within one percent of 5.10:1, every
side post is no wider than 42 pixels, every horizontal rail is no thicker than
36 pixels, both 1236 by 187 openings are fully clear, isolation is at least
96 pixels, and there is no baked content, mirror duplication or edge contact.

#### Attempt 5 审查

- 输入：固定 Image 1／2 与同段 attempt 4 raw 作为 Image 3；完整 `V1.r4` 正文
  来自 `448a8dd`。child 完整回显正文和三张输入映射，未递归启动 fixed child，
  未报告 revised prompt。
- 执行：child `019feeae-61b4-7c62-990d-bd20c8536b88`；provider result
  `ig_00ccd1c003ebf324016a7a8aeaa7f88191a46c8937c7e3a9b3`。
- 原始输出：`1536×1024 RGB`；SHA
  `56ae9ae5f24f0a89537c0d0d55b885a3849e08abfe586a7a88b0c43692e106a3`。
- 语义／美术：恰有 Player／Target 两张空壳，无动态内容或镜像复用；深胡桃
  薄轨、低频磨损、Player 左缝线与 Target 右黄铜修复保持一致，粗犷度和邻接
  Chat 语言可成立。Target 黄铜片与两侧端柱仍比合同要求更宽。
- 已通过门禁：Player bbox `1390×273`，比例误差 `0.071891%`；Target
  `1387×271`，误差 `0.448322%`。二者均小于授权的 `1%`，可只用等比
  bbox-fit 完整填入 `214×42`，无非等比缩放；中央孔与外部背景均可由连通
  色键清除，中央 seed 通过。
- 第一失败门禁：运行时 `x 7..207 / y 6..36` 安全走廊仍分别有 `872`／`818`
  个可见 Alpha 像素，说明宽端柱实际压住 provider 血条两端。Player 横向隔离
  `68`／`78px`，Target `73`／`76px`，低于 `96px`；其余垂直隔离通过。
- 确定性处理：固定两格；边缘／中央孔连通色键；一像素 despill；透明 RGB
  清零；只做等比 bbox-fit；没有裁掉端柱、非等比拉伸或涂改候选。
- 技术报告：
  `generated/unitframes/primary/UF-A1/V1/attempt-05/review-report.json`；
  `overall_technical_pass=false`。
- 真实排版：
  `generated/unitframes/primary/UF-A1/V1/attempt-05/real-layout-preview.png`，SHA
  `147e9d98f70481317dae0950721402c416ccece78a05670dc6bc388cce8e5252`；
  Player／Target shell 为 `100%` runtime，动态条和文字使用真实 provider
  几何；可见两端装饰压住条形端部。屏幕锚点、A2 紧凑框和动作条仍为明确
  非权威 fallback。
- 结论：`candidate-rejected / P3 / repair-budget-exhausted`。UF-A1 已用尽
  `5/5`，不允许第 6 次同版调用，不允许晋级 source／runtime。按有界循环
  规则暂停 UF-A2／UF-B1，等待用户审核第 5 稿的明确合同例外，或授权新的
  UF-A1 版本／模拟方向。
- 用户结论：`rejected / 2026-08-11`；原文“不接受例外”。用户明确拒绝端柱
  覆盖动态走廊和横向隔离不足的一次性合同例外；attempt 5 不再具有进入 P4
  的路径，只作为失败证据与新版本负面约束保留。

## `UF-A1 V2-SIM.V1` — 四件式外缘结构重启

### 运行时审计结论

- 当前 profile 的 Player／Target 均为 `width=200`、`height=25`、
  `pheight=4`、`pspace=-1`、`portrait=off`；`f.hp.bar` 与 `f.power.bar` 继续
  承担动态裁切，真实 Button／文字／图标和事件均不改变。
- 维持用户已确认的 `214×42` 外接尺寸，不通过扩大外框规避问题。唯一可用
  装饰域是左 `7×42`、上 `200×6`、下 `200×6`、右 `7×42` 四条互斥区域；
  中央 `x 7..207 / y 6..36` 必须完整留给 `200×25` HP、`1px` 间隔、
  `200×4` Power 与原 Button。
- V1 失败来自让模型一次绘制整张中空外壳，端柱厚度与整体比例被绑在同一
  对象里。V2 改为每个角色四件独立 source：固定端帽与横向轨道分别生成、
  审查和装配；粗犷身份差异只存在于固定端帽，长中心保持安静。
- Player：左端帽承担歪夹片／粗缝线，右端帽只保留不居中铆钉；Target 从零
  绘制，左端帽为磨亮折边，右端帽为窄破损黄铜压片。八件不得镜像，V1 所有
  失败稿像素均不得成为模拟、生产 reference、edit、source 或 runtime 输入。

### 本地模拟合同与执行

- 版本：`UF-A1-V2-SIM-V1`；状态：
  `superseded-as-runtime / retained-as-source-granularity-evidence`。
- specification：`tools/specs/unitframes_a1_v2_simulation_v1.json`，SHA
  `9c00c26c9d6d224459e1f082ec52f53917c83f315c1996bd9a18c95da50fd59b`。
- 展示区域合同：
  `tools/specs/unitframes_a1_v2_simulation_display_region_v1.json`，SHA
  `3886a61363793d54368ebe2ddc30a463682388c92e050666c69ac780548646a4`。
- 渲染器：`tools/render_unitframes_a1_v2_simulation_v1.py`，SHA
  `e1937e68004d48b2caa738781db02008b1b4d6afd84794033125d86157be8564`。
- 命令：`conda run -n py312 python tools/render_unitframes_a1_v2_simulation_v1.py`；
  随后运行工作流 `validate_display_regions.py`。Python 为
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`／`3.12.12`。
- ImageGen：`0/0`；未上传任何图片，未启动 provider，未产生 production
  候选。
- 真实排版预演：
  `generated/unitframes/primary/UF-A1/V2/simulation/V1/uf-a1-v2-sim-v1.scene.png`，
  SHA `4ff48b8fac3a0b880ed4de830c2d3426003a4585fd08aa1d07cb50e48fbb7233`；
  Player／Target 为 `100%` runtime，动态条、文字、Aura 数量与 shell 层序按
  当前 provider 几何绘制。屏幕位置、Chat／动作条邻接和远端布局非权威。
- 结构审阅板：
  `generated/unitframes/primary/UF-A1/V2/simulation/V1/uf-a1-v2-sim-v1.assembly.png`，
  SHA `756e1550b51294fa825db58a813d44476de3909ad3e932f810be46d3d44cf220`；
  3×图只使用最近邻放大帮助审视运行时像素，不改变合同尺寸。
- 几何自检报告：
  `generated/unitframes/primary/UF-A1/V2/simulation/V1/uf-a1-v2-sim-v1.report.json`，
  SHA `9672ce1a9d06da1428c53ff747c2a8280c48eb8e037c0dd9998178b118a88f1f`；
  Player／Target 均为四件、件间重叠 `0px`、装饰进入 content-safe `0px`、
  每件越出声明盒 `0px`。
- 展示区域报告：
  `generated/unitframes/primary/UF-A1/V2/simulation/V1/display-region-report.json`，
  SHA `38a6bb5ebcbaff8118c2f9cfcb9aaf9cb922bea825e4928423eb8476c976df11`；
  Player normal／Target aggro `2/2 pass`，violations `0`。

| 本地渲染错误 | 版本 | 错误 | 针对性修复 | 结论 |
|---:|---|---|---|---|
| SE1 | `UF-A1-V2-SIM-V1` | Python 布尔量误写为 JSON `false`，返回 `NameError`；尚未写图 | 只改为 `False`，不改变任何几何、配色或输出合同 | 普通渲染错误；不涉及 ImageGen |
| SE2 | `UF-A1-V2-SIM-V1` | sandbox 无权新建 ignored `generated/.../V2`，返回 `PermissionError`；尚未写图 | 获准后以同一命令和同一 specification 重跑 | 普通环境错误；不涉及 ImageGen |

## `UF-A1 V2-SIM.V2` — 缩放安全的 source → runtime 合同

### 为什么替代 V2-SIM.V1

- V2-SIM.V1 证明八件 source 可以完全避开动态区，但若把四件直接作为四张
  运行时 Texture 挂载，非整数 UI Scale 可能令共享边界采用不同物理像素取整，
  产生一像素缝隙或双线。V2-SIM.V1 因此只保留为 source 粒度证据，不再作为
  runtime 挂载方案。
- V2-SIM.V2 不改变资产粒度：Player／Target 仍各自生成四个独立 source。
  改变的是 P4／P5 的确定性导出方式，不复用任何 V1 失败候选像素。

### 最终装配提案

- 标准宽度：每角色四个已接受 source 预合成为一张 `214×42` RGBA shell；
  addon 每角色只挂载一张 Texture，任意整体 UI 缩放都不会暴露内部纹理边界。
- 可变宽度：仅当内容宽度不是 `200` 时启用三切片。左、右端帽固定为
  `7×42`；中央带宽为 `W+2`，包含横向缩放后的上轨、下轨和透明中部，并在
  左右各向端帽下方伸入 `1 logical px`。端帽后绘制、覆盖中央带接头。
- 取整：所有物理盒从同一逻辑原点计算；装饰盒 `floor(start)`／`ceil(end)`，
  安全区 `ceil(start)`／`floor(end)`。因此 `0.71×` 下右侧实际可能形成 `2px`
  物理重叠，但只位于装饰角，安全区仍为零侵入。
- 纹理过滤防护：atlas 至少保留 `2px` padding，中央带端点做 `1px` extrusion；
  关键身份特征不得依赖单个 runtime 像素。高度固定 `42`，禁止纵向拉伸。

### 本地执行与证据

- 状态：`simulation-confirmed / production-authorized`；ImageGen `0/0`，没有上传、
  provider 会话、production source、runtime 或 addon 改动。
- specification：`tools/specs/unitframes_a1_v2_simulation_v2.json`，SHA
  `a7a15ccb22f5c677bd98f6b2231fce85734562c1654638e830533c9a5d6534b0`。
- 展示区域合同：
  `tools/specs/unitframes_a1_v2_simulation_display_region_v2.json`，SHA
  `c035253da71d0d0f91b1819239be7f47eb81a501a6a89756b71673ac76aa3e0c`。
- 渲染器：`tools/render_unitframes_a1_v2_simulation_v2.py`，SHA
  `0bf4708974ba8cf5ccb4fb3906a3ffe10a4239d3dafa0ff73788d02d2076edbd`。
- 标准单 shell 缩放矩阵：
  `generated/unitframes/primary/UF-A1/V2/simulation/V2/uf-a1-v2-sim-v2.scale-matrix.png`，
  SHA `6040d50d6412011318a075c45ed59643de1fd789f05f9a648fa58ade5d65cd0d`；
  Player／Target 均覆盖 `0.64`、`0.71`、`0.80`、`0.90`、`1.00`、`1.15`。
  每格 runtime Texture 数量 `1`、内部接缝 `0`、安全区不透明装饰像素 `0`。
- source → runtime／可变宽度三切片板：
  `generated/unitframes/primary/UF-A1/V2/simulation/V2/uf-a1-v2-sim-v2.runtime-contract.png`，
  SHA `81d45b0b24b15405cf4cc877ca9058b78ec9c48b925f2d35194b65e2935495e5`；
  `W=160/200/240` 在 `0.71×` 与 `1.00×` 下左右接头空洞均为 `0px`，安全区
  不透明／半透明装饰像素均为 `0`。
- 几何报告 SHA
  `59fae38dd5b143509d3efdeb72cca8f9fab8ca87369e8130f31655c07df7521e`，
  `status=pass`／violations `0`。标准路径在 `0.64`、`0.71`、`1.15` 的安全区
  边缘分别存在双线性采样形成的低 Alpha fringe，但所有 `alpha>=128` 的装饰
  侵入均为 `0`；这只是假定的 bilinear 近似，不声称等同 Turtle WoW GPU。
- 展示区域报告 SHA
  `759316cf3b521c7f00ea57cc674d79c6117967aa2cc4e756c61b6dadf3568775`，
  标准 `W=200` 与可变 `W=160/240`、Player／Target 共 `6/6 pass`，
  violations `0`。
- 连续两次以 macOS `conda run -n py312 python` 重建，以上四个输出 SHA 完全
  一致，确定性复现通过。

### 用户方向结论

- 具体模拟版本：`UF-A1-V2-SIM-V2`。
- 用户结论与日期：`confirmed / 2026-08-11`；用户原文：`确认`。
- 已冻结的可见／结构条款：
  - Player／Target 继续分别由四个独立 source 提供粗犷、非镜像的身份差异；
    不把八件合并成一个不可审查的生产图对象。
  - 默认 `W=200` 的游戏内外观由每角色一张完整 `214×42` shell 承担，整体
    UI Scale 不暴露 source 接缝。
  - 可变宽度才使用固定端帽＋中央带三切片；中央带只在上下装饰角进入端帽
    下方，不能遮挡 HP、Power、文字或 Button 安全区。
  - 取整、extrusion、padding 和 z-order 属于确定性 builder 责任；端帽身份
    细节不得依赖单个 runtime 像素。
  - 逻辑高度固定为 `42`；需要新高度时另立规格，不纵向拉伸本批资源。
- 未被接受的内容：模拟图像素、几何平色、最终手绘笔触、皮革／黄铜微纹理、
  正式 Alpha、source、runtime、addon 接入与 Turtle WoW 实机表现。
- 确认失效条件：source 对象数量、默认单 shell 构图、可变宽度三切片层序、
  内容安全区、固定高度，或已确认的行军身份牌材料／视觉重量发生实质变化。
- 下一门禁：用户看过并明确授权 `UF-A1 V2-A V1` 与 `UF-A1 V2-B V1` 两段
  最终生产正文、固定上传范围、修复边界及各自最多五次实际 ImageGen。

### V2 生产正文完整性预检

- 复杂度：`UF-A1 V2-A = four independent fixed caps / column atlas`；
  `UF-A1 V2-B = four independent horizontal rails / band atlas`；P4／P5 另有
  deterministic source-to-runtime builder，标准宽度输出两张单 shell，可变宽度
  输出三切片所需的固定端帽与带 extrusion 的中央带。
- 当前结论：`pass / final-production-body / authorized 2026-08-11`。模拟确认的
  source 粒度、标准单 shell、可变宽度三切片、固定高度和动态安全区已写回
  两段正文并重新核对；对象数量、参考职责、精确画布、bbox、运行时尺寸、
  接缝、色键、禁止烘焙和验收条件均自包含。当前按 A→B 合同执行。

| 门禁 | V2-A／V2-B 中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象数量与动态内容排除 | V2-A 四端帽、V2-B 四横轨逐件命名；明确无文字、条形填充、图标、状态与头像 | pass |
| 每张输入图职责与权威冲突 | Image 1 只负责香草尺度／综合色，Image 2 只负责材料／磨损；完整书框结构均忽略 | pass |
| 画布、格位、边距、方向、透视、尺度、光照与层序 | `1536×1024`；四列 `128×768` 端帽、四带 `1200×36` 横轨；正交正视、左上暖光 | pass |
| 逐对象形态、材料、边缘、状态与相互关系 | Player 左修补／右安静，Target 左磨亮／右损伤；上下轨独立、不镜像、不复用 | pass |
| 安静区、裁切、拉伸、重复与接缝 | bbox-fit 目标 `7×42`／`200×6`；标准宽度预合成单 shell；可变宽度中央带在装饰角下方各 extrusion／overlap `1px`；动态区覆盖仍为 `0px` | pass |
| 美术 DNA、反模式、Alpha／色键与最终自检 | 深胡桃／烟褐／断续暗铜、2004 手绘、纯绿背景、边缘连通色键及完整反现代禁止项 | pass |

### `UF-A1 V2-A V1` 最终生产正文 — 四个固定端帽

> `production / authorized 2026-08-11`。首次调用必须使用本提交中的
> 完整正文、固定 Image 1／2，且不得上传模拟图或任何 UF-A1 V1 失败稿。

```text
Create exactly four independent, empty unit-frame side-cap source components as a
single orthographic 2D production sheet for a Turtle WoW 1.18.1 / Vanilla-era
pfUI overhaul. The components are not complete frames, not portraits and not
generic ornaments. They are the fixed-width left and right terminal pieces
that a deterministic runtime builder will assemble with two separate horizontal
rails around live status bars. At standard width the builder precomposes all
four pieces into one shell texture. At variable width it places a center band
one logical pixel beneath each cap at the upper and lower decorative corners.

Use Image 1 only for circa-2004 Vanilla WoW painted scale, thick low-resolution
readability, short dull-brass highlights and the overall dark, weighty colour
balance. Ignore its screen layout, circular portraits, complete unit-frame
examples, chat text and every book-shaped structure. Use Image 2 only for
deep-walnut worn leather, soot-brown liner, warm upper-left illumination,
believable hand repair, low-frequency wear and slight field-made irregularity.
Ignore its pages, spine, wooden posts, dragons, book silhouette and extensive
metal architecture. The global and Unit Frames written baselines outrank both
images whenever they conflict.

Return one 1536 by 1024 RGB image on a perfectly uniform pure #00FF00
background. Divide the canvas into four non-overlapping vertical columns, each
384 by 1024 pixels, ordered strictly from left to right:

1. Player left cap.
2. Player right cap.
3. Target left cap.
4. Target right cap.

Draw exactly one object in each column and no other object. Each visible object
has an exclusive alpha-ready bounding box exactly 128 pixels wide by 768 pixels
high, ratio 1:6, centred at y 128..896. Their x ranges are respectively
128..256, 512..640, 896..1024 and 1280..1408. Keep at least 128 pixels of pure
green isolation around every object. Do not let shadow, highlight, stitch,
rivet or antialiasing touch a column edge or another object. These bboxes will
be edge-connected chroma-keyed, transparent-RGB-cleared and proportionally
fitted without distortion to four independent 7 by 42 runtime cells. The left
and right caps remain fixed size; they are never horizontally stretched.

All four objects are front-facing orthographic 2D hand-painted bitmap pieces,
with no perspective and no scene. Each is a narrow, weighty strip of deep-
walnut repaired leather over a soot-brown liner, with only tiny interrupted
dull oxidized-brass accents. Use warm upper-left light, broad readable masses,
one-pixel-minded edge hierarchy, short broken highlights and restrained contact
shadow. Irregularity comes from use and repair: the outer silhouette may drift
slightly at a few low-frequency points, while the inner joining edge remains
nearly straight and physically usable. Do not add random noise across the
whole surface.

The Player left cap is the heaviest repair: one crooked narrow brass clamp and
two or three coarse, uneven stitches held completely inside the cap. Its right
edge is the inner joining edge. The stitches must look pulled through leather,
not printed on top, and must not protrude outside the bbox. The Player right cap
is quieter and independently drawn: worn leather, a shallow fold and one small
off-centre dark-brass rivet. Its left edge is the inner joining edge. Do not
mirror or copy the Player left cap.

The Target left cap is independently painted with a rubbed, slightly polished
leather fold and almost no metal. Its right edge is the inner joining edge. The
Target right cap carries one narrow damaged oxidized-brass repair strip, with a
small dent or split and an uneven attachment, entirely inside the cap. It must
remain a thin repair, never a square plaque or broad U-shaped end post. Its left
edge is the inner joining edge. Do not bake red hostility, creature type,
elite status, skull, horn, crest or faction symbolism into either Target cap.

For every cap, the upper and lower ends must contain solid leather contact
mass suitable for butt-joining a 6-pixel runtime top or bottom rail. Along the
inner joining edge, keep the top and bottom contact zones opaque and quiet;
do not place a loose curl, protruding stitch, brass spike or cast shadow across
that edge. The first inward source pixel at each upper and lower contact must
be visually safe for the runtime builder to cover with a one-logical-pixel
center-band extrusion underneath the cap. Do not place identity-critical detail
only in that cover corridor. The long middle edge beside the live bar must stay dark and calm so
text and colour remain readable immediately next to it.

Draw no health or power fill, text, number, name, level, icon, aura, portrait,
button, cursor, glow, hover state, aggro state or background panel. Do not draw
a complete frame, U-shaped bracket, matching mirrored pair, continuous gold
outline, symmetrical rounded card, glass, gradient gloss, bevelled web panel,
industrial rivet grid, black-iron shrine, Diablo-style skull architecture,
book part, wax seal, map ornament, gemstone, neon or photoreal antique.

Outside the four side caps every pixel must remain pure #00FF00. Before
returning, verify: exactly four objects in the declared order; every bbox is
128 by 768 within one percent of 1:6; each object is isolated; all four are
independently painted; inner joining edges are usable; no object touches a
canvas or column boundary; no baked dynamic content exists; and no pixel from
any rejected UF-A1 V1 output has been used or imitated as an edit source.
```

### `UF-A1 V2-B V1` 最终生产正文 — 四条独立横轨

> `production / authorized 2026-08-11`。V2-A 与 V2-B 是不同生产段，
> 禁止跨段复用生成像素；首次调用必须使用本提交中的完整正文与固定 Image 1／2。

```text
Create exactly four independent, empty horizontal unit-frame rail source components
as one orthographic 2D production sheet for a Turtle WoW 1.18.1 / Vanilla-era
pfUI overhaul. They are narrow top and bottom rails consumed by a deterministic
source-to-runtime builder with separate fixed side caps around live status bars.
At standard width the builder precomposes four sources into one shell texture;
at variable width it horizontally resamples each rail, extrudes one endpoint
pixel under each fixed cap and packs both rails into one transparent center
band. They are not complete frames, status
bar fills, dividers, decorative banners or generic material swatches.

Use Image 1 only for circa-2004 Vanilla WoW painted scale, thick low-resolution
readability, short dull-brass highlights and the overall dark, weighty colour
balance. Ignore its complete UI layout, circular portraits, chat text, unit-
frame examples and book structures. Use Image 2 only for deep-walnut worn
leather, soot-brown liner, warm upper-left illumination, believable field wear
and low-frequency hand-made error. Ignore its pages, spine, wooden posts,
dragons, complete book silhouette and broad metal construction. The global and
Unit Frames written baselines outrank both images whenever they conflict.

Return one 1536 by 1024 RGB image on a perfectly uniform pure #00FF00
background. Divide the canvas into four horizontal bands, each 1536 by 256
pixels, ordered strictly from top to bottom:

1. Player top rail.
2. Player bottom rail.
3. Target top rail.
4. Target bottom rail.

Draw exactly one object in each band and no other object. Each visible object
has an exclusive alpha-ready bounding box exactly 1200 pixels wide by 36 pixels
high, ratio 33.3333:1, centred at x 168..1368. Their y ranges are respectively
110..146, 366..402, 622..658 and 878..914. All remaining pixels are pure green.
Keep the four rails fully isolated, with no shadow, scratch, highlight or
antialiasing outside its declared band. These bboxes will be edge-connected
chroma-keyed, transparent-RGB-cleared and proportionally fitted without
distortion to four independent 200 by 6 runtime cells. Runtime rails may only
be extended horizontally; they are never vertically stretched.

All four rails are front-facing orthographic 2D hand-painted bitmap pieces,
with no scene and no perspective. Each is a thin but weighty strip of deep-
walnut worn leather over a soot-brown inner lip, with tiny interrupted dull
oxidized-brass traces. Use warm upper-left illumination, readable broad colour
masses, dark restrained lower contact shadow, short broken highlights and only
two or three low-frequency silhouette deviations across the long span. Keep
the middle visually quiet. Do not fill the strip with random scratches or make
the edge mathematically straight, but never create large waves that consume
the live bar area when fitted to six pixels high.

The Player top rail has a slightly drier upper edge and two sparse, unequal
brass rubs. The Player bottom rail is darker, more compressed and has a
different wear rhythm, including one short repaired abrasion; it must not be a
vertical flip or reused copy of the top rail. The Target top rail is independently
painted with a more rubbed leather ridge toward the right but no enemy-red
colour. The Target bottom rail is independently painted, darker and slightly
more damaged toward the right, echoing the Target right repair without adding
a plaque or emblem. No rail may be mirrored or pixel-reused from another rail.

Both ends of every rail are assembly interfaces. For at least the first and
last 24 source pixels, keep a solid, quiet leather contact band across the
central portion of the 36-pixel thickness. Do not taper either end to a point,
round it into a pill, add a curl, cast a shadow beyond the bbox or place a
raised rivet on the joining edge. The two ends must visually butt against the
separately generated fixed caps without a modern bevel seam. The outermost
source pixel at each end must be safe to duplicate once as an extrusion beneath
the cap; no identity-critical stitch, rivet, notch or highlight may depend on
that single pixel. Long scratches,
brass lines and highlights must stop before the join and must never become a
continuous gold border.

Draw no health or power fill, text, number, name, level, icon, aura, portrait,
button, cursor, glow, hover state, aggro state or background panel. Do not draw
side posts, a complete rectangular frame, U-shaped bracket, continuous gold
outline, perfect rounded card, glass, gradient gloss, polished bevel, web panel,
industrial rivet grid, black-iron shrine, Diablo-style skull architecture,
book part, wax seal, map ornament, gemstone, neon or photoreal antique.

Outside the four rails every pixel must remain pure #00FF00. Before returning,
verify: exactly four objects in the declared order; every bbox is 1200 by 36
within one percent of 33.3333:1; all four are isolated and independently
painted; both joining ends remain usable; there is no baked dynamic content;
no object touches a canvas or band boundary; and no pixel from any rejected
UF-A1 V1 output or from V2-A has been used as an edit or construction source.
```

### V2-A／V2-B 已授权生产合同

- 执行顺序：先 `UF-A1 V2-A V1`，其内部通过后再执行
  `UF-A1 V2-B V1`。二者是独立五次循环，单段通过即停。
- 实际生图预算：V2-A 最多 `5` 次、V2-B 最多 `5` 次，最坏合计 `10` 次；
  只有返回图片或 provider result 证明生成实际发生时才计数。流程、传输、
  上传、权限或落盘错误若无生成证据则另表记录，不占额度。
- 固定 Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA
  `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
  只提供 2004 香草位图尺度、粗厚可读质量、短黄铜高光和综合色重。
- 固定 Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA
  `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`；
  只提供深胡桃材料、左上暖光、手工误差和磨损节奏。
- 每段每次都只允许上传上述固定 SHA 的 Image 1／2。attempt 1 不上传 Image 3；
  只有同段紧邻前次输出且明确保留正确区域时，
  才允许作为下一次 Image 3 edit 输入。禁止跨段复用、禁止上传模拟图、禁止
  使用任一 UF-A1 V1 失败候选。
- 不可变修复边界：组件／对象数量与顺序、参考职责、Canvas／格位／bbox、
  `7×42` 端帽与 `200×6` 横轨 source 尺寸、标准单 shell／可变宽度三切片
  builder、`42px` 固定高度、动态内容排除、色键、综合色方向和最多五次额度。
- 允许的自主修复：同段内调整低频轮廓误差、皮革／黄铜材料表达、磨损／
  缝线／压片位置、端部接触带、纯绿隔离和 bbox 占用；可在 regenerate 与
  有界 edit 之间选择。不得改变可见设计方向或新增输入。
- 允许的确定性处理：固定分区拆分、边缘连通 `#00FF00` 色键、透明 RGB 清零、
  纵横比误差不超过 `1%` 的等比 bbox-fit、在 ignored `generated/` 下提取八张
  独立透明 candidate component、标准宽度单 shell 预合成、可变宽度中央带
  extrusion／三切片装配、状态 rim 派生、atlas padding 和真实排版／缩放矩阵
  预演。这些处理不构成 P4 接受；用户接受前不得写入 `assets/source/`。
- 必须重新授权：新增／删除对象、改变参考或上传、跨段复用像素、修改 source
  或 runtime 几何、允许纵向拉伸、恢复内容区覆盖、改变物件身份／综合色方向，
  或任何超出上述修复边界的变更。

## UF-A1 V2 正式生产循环

### V2-A 四端帽

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `UF-A1 V2-A V1` / `79fe840` | generate | child `019feeec-3e39-71c2-bc12-bcd8771834fd`／result `ig_048116956da78c3b016a7a9ac273488191884f77edb16f767f` | raw `generated/unitframes/primary/UF-A1/V2-A/V1/attempt-01/raw/UF-A1_V2-A_V1_attempt-01.provider-native-01.png`／SHA `33b3f7f1…f1c2` | 固定分区／比例：四件比例误差 `13.625866–16.397229%`，隔离仅 `79–116px` | 保留四件顺序、非镜像身份、深胡桃综合色和已通过的端部接触；使用同段 Image 3 重建精确 bbox，并把照片级微纹理收敛为香草手绘块面 | failed；进入 `V1.r1` |

#### V2-A Attempt 1 完整审查

- 输入与传输：固定 Image 1 SHA `90e30ba…ee06`、Image 2 SHA
  `272528e6…aab8`；无 Image 3。完整 fenced 正文来自提交 `79fe840`，正文 SHA
  `2c1ba0de…29d`；child 完整回显正文与两图顺序，没有 revised prompt。
- 原始输出：`1536×1024 RGB`；SHA
  `33b3f7f1bbd6425887a939af637e2c20c902e8131e22225383ac2c3474a1f1c2`；
  provider-native 与 child-saved SHA 完全一致，故计为 V2-A `1/5`。
- 范围／语义：恰有四件竖向端帽，顺序正确；Player 左端横向夹片与粗缝线、
  Player 右端折边／铆钉、Target 左端磨亮折边、Target 右端破损黄铜片均可辨；
  无文字、头像、条形填充、状态或额外对象。四件彼此不是镜像。通过。
- 物理／装配：四件均为单一物理主体；运行时内接边上下接触覆盖率
  `0.571429–0.714286`，高于 `0.25` 门槛；以非权威 fallback 横轨重组时四角
  接触均至少 `3/6` 行，标准与 `W=160/200/240` 内容安全区侵入均为 `0px`。
  这些正确区域可保留。
- 第一失败门禁：Player 左 keyed bbox `168×866`，目标比例误差
  `16.397229%`；其余三件均约 `164×866`，误差 `13.625866%`。四件 top／bottom
  隔离均仅 `79px`，左右隔离为 `104–116px`，均低于声明 `128px`。不得依靠
  非等比压缩或裁掉细节晋级。
- 美术一致性：深胡桃、烟褐、断续暗铜、左上暖光和角色身份差异成立；但表面
  微纹理偏照片级，四件外形仍像规则长方皮板，Player 左横夹片和 Target 右
  黄铜片略显宽。下一稿在修正 bbox 的同时必须用更少、更大的香草手绘块面，
  加强低频维修不规则，并保持内接边可用。
- 技术／预演：review report SHA `4dcf390b…8de6`；technical contact SHA
  `34d5e2a8…57a6`；`100%` 真实排版 SHA `64697980…9f15`；缩放／宽度预演 SHA
  `4de7abbb…aa3`。展示区域沿用已确认的真实 provider 合同，报告 SHA
  `759316cf…775`，`6/6 pass`；该几何通过不能覆盖本稿比例／隔离失败。
- 结论：`failed / attempt 1 of 5`。不允许用户复审、source 或 runtime；允许
  把本稿作为同段紧邻 Image 3，仅保留上述正确区域并执行 `V1.r1`。

### `UF-A1 V2-A V1.r1` 完整修复正文

```text
The written requirements below are controlling. Image 1 is a fixed secondary
reference only for circa-2004 Vanilla WoW painted scale, thick low-resolution
readability, short dull-brass highlights and the overall dark, weighty colour
balance. Ignore its screen layout, circular portraits, complete unit frames,
chat content and all book geometry. Image 2 is a fixed secondary reference only
for deep-walnut worn leather, soot-brown depth, warm upper-left illumination,
believable field repair and low-frequency wear. Ignore its pages, spine,
wooden posts, dragons, book silhouette and broad metal architecture. Image 3
is only the immediately preceding UF-A1 V2-A cap sheet. Preserve from Image 3
only the correct four-object order, independent Player-versus-Target identities,
deep-walnut and restrained brass colour family, usable upper/lower joining mass,
and the specific Player-left stitch / Player-right rivet / Target-left fold /
Target-right damaged-strip relationships. Do not preserve Image 3's oversized
168x866 and 164x866 bboxes, 79-to-116-pixel isolation, exact silhouettes,
rectangular board-like regularity, broad brass pieces or photoreal microtexture.
Never use or imitate any rejected UF-A1 V1 whole-frame output. This text and the
global and Unit Frames written baselines outrank every image when they conflict.

Edit into one 1536 by 1024 RGB production sheet on a perfectly uniform pure
#00FF00 background. It contains exactly four independent front-facing
orthographic 2D side-cap source components and no other objects. The canvas is
four non-overlapping columns of 384 by 1024 pixels, ordered strictly left to
right as Player left cap, Player right cap, Target left cap and Target right
cap. These are fixed terminal pieces for separate top and bottom rails around
live pfUI status bars; they are not complete frames, portraits, U-brackets,
background panels or generic decorative strips.

Reconstruct every cap inside its exact exclusive bbox rather than stretching,
cropping or squeezing existing pixels. Erase every current object pixel,
shadow, highlight and antialiasing outside the following four rectangles back
to uniform #00FF00:

1. Player left cap: x 128..256, y 128..896.
2. Player right cap: x 512..640, y 128..896.
3. Target left cap: x 896..1024, y 128..896.
4. Target right cap: x 1280..1408, y 128..896.

Each visible alpha-ready bbox must therefore be exactly 128 by 768 pixels,
ratio 1:6 within one percent, with at least 128 pixels of pure-green isolation
to its canvas and column boundaries. The painted mass must genuinely occupy
the declared bbox; do not fake the measurement with detached dots or a remote
shadow. These four bboxes will be edge-connected chroma-keyed, transparent-RGB
cleared and proportionally fitted without distortion to four independent 7 by
42 runtime cells. The caps are fixed size and are never horizontally stretched.

Use a circa-2004 Vanilla WoW hand-painted bitmap treatment designed to survive
at only seven runtime pixels wide. Replace photographic pores and dense cracks
with a few broad readable leather colour masses, short broken highlights and
two or three deliberate wear transitions. Deep-walnut repaired leather is the
main structure; soot-brown liner supplies depth; dull oxidized brass is a tiny
interrupted repair only. Use warm upper-left light and restrained contact
shadow. The outer silhouette may drift at only a few low-frequency points so
it feels hand-cut and field-repaired, while each inner joining edge stays
nearly straight, dark and physically usable. Do not fill the surface with
random noise and do not make four matching perfect rectangles.

The Player left cap remains the heaviest repair, but repaint its brass as one
small crooked narrow clamp rather than a broad strap. Keep two or three coarse,
uneven stitches visibly pulled through the leather and completely inside the
bbox. Its right edge is the quiet inner joining edge. The Player right cap is
redrawn independently as calmer worn leather with a shallow fold and one small
off-centre dark-brass rivet; its left edge is the inner joining edge. Never
mirror or copy the Player left cap.

The Target left cap is independently painted with a rubbed leather fold and
almost no metal; its right edge is the inner joining edge. The Target right
cap keeps one narrow damaged oxidized-brass repair strip with a small dent or
split and uneven attachment, but the strip must be markedly narrower than in
Image 3 and never become a plaque or broad end post. Its left edge is the inner
joining edge. Do not add red hostility, faction, creature, elite, skull, horn
or crest symbolism.

For every cap, the upper and lower ends contain solid leather contact mass for
a six-pixel runtime top or bottom rail. Along the inner joining edge, keep the
top and bottom contact zones opaque and quiet. No curl, stitch, brass spike or
shadow may protrude across that edge. The first inward source pixel at each
contact must remain visually safe for one logical pixel of center-band
extrusion beneath the cap, and no identity-critical mark may live only in that
cover corridor. The long middle edge beside the live bar stays dark and calm.

Draw no health or power fill, text, number, name, level, icon, aura, portrait,
button, cursor, hover, aggro, glow or background panel. Forbid complete frames,
U-shaped brackets, mirrored pairs, continuous gold outlines, matching corner
ornaments, perfect rounded cards, glass, gradient gloss, web bevels, industrial
rivet grids, black-iron shrines, Diablo-style architecture, book parts, wax
seals, maps, gemstones, neon and photoreal antiques. Outside the four rebuilt
caps every pixel remains uniform #00FF00. Before returning, verify exactly four
objects in the declared order; four genuine 128x768 bboxes within one percent
of 1:6; at least 128 pixels of isolation; independent silhouettes; usable inner
joining contacts; broad Vanilla-era painted masses rather than photo texture;
no edge contact, extra object, baked dynamic content or rejected V1 pixel use.
```

## 审查记录

- 结构／交互：八件 source 保持独立；标准宽度由 builder 输出每角色一张完整
  shell，可变宽度才使用三切片与装饰角下方 `1px` 重叠。HP／Power／文字与
  Button 完整保留，没有 V1 的宽 U 形端帽或内容区覆盖例外；真实 Frame、
  命中盒、锚点、Aura 与状态更新逻辑均未修改。
- 可见方向：维持已确认的深胡桃旧皮革、烟褐内衬、断续暗铜、Player 左／
  Target 右非镜像维修关系。用户已确认标准单 shell／可变宽度三切片不会改变
  该可见方向；几何图中的平色、像素笔触和微纹理仍明确非权威。
- 正式生产已冻结并授权为两个独立执行段：`UF-A1 V2-A V1` 生成四个固定端帽，
  `UF-A1 V2-B V1` 生成四条横轨；每段各自最多五次实际 ImageGen，不跨段复用
  像素。两个完整正文已于 `2026-08-11` 获得用户明确生图授权。
- 用户方向结论：`confirmed / 2026-08-11`。本地模拟像素不得晋级
  source/runtime，也不得成为 ImageGen reference 或 edit 输入。

## UF-PRIMARY-SIM-V1 历史审查记录

- 语义／物理：四框均为包住现有动态条的身份牌外壳；没有假头像槽、浮动
  黄铜件或悬空 Focus 布结。
- 透视／图层：外壳、内衬、动态条与短边状态反馈层序清楚；端帽装饰不进入
  provider 内容走廊。
- 美术一致性：几何图已表达深胡桃皮革、断续暗铜、非镜像修补与减法紧凑件；
  正式手绘纹理仍属非权威。
- 对象／状态合同：四张 shell、两条 fill、两类确定性 rim 的职责完整；预演
  显示 Player normal、Target aggro、TargetTarget normal、Focus hover。
- 实际展示区域：合同与报告 SHA 如上；`4/4 pass`，violations `0`。
- 结论：`displayable / simulation-confirmed`；确认方向已写入三段最终生产
  正文。当前仍不允许进入 source、runtime 或正式 ImageGen。
- 用户结论：`confirmed / 2026-08-11`，原文“接受 UF-PRIMARY-SIM-V1”。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `UF-PRIMARY-SIM-V1` | deterministic scene／zoom；SHA 与 display-region `4/4` 如上；ImageGen `0/0` | `simulation-confirmed` | 可见方向已写入 A1／A2／B1；等待三段正式生产授权 |
| `UF-A1 V1` | fixed ImageGen `5/5`；attempt 5 ratio `2/2 pass`，安全走廊 `0/2 pass`；真实排版 SHA `147e9d98…5252`；用户于 `2026-08-11` 明确拒绝例外 | `candidate-rejected / repair-budget-exhausted / user-rejected` | 建立新的 UF-A1 版本；不得复用失败稿像素，不得第 6 次同版生图 |
| `UF-A1-V2-SIM-V1` | deterministic scene／assembly；八件 source 互斥且动态区覆盖 `0px`；display-region `2/2 pass`；ImageGen `0/0` | `superseded-as-runtime / retained-as-source-granularity-evidence` | 不直接把四件挂为四张 runtime Texture；由 V2-SIM.V2 接管缩放合同 |
| `UF-A1-V2-SIM-V2` | 标准单 shell 覆盖 `0.64–1.15×`、内部 Texture 接缝 `0`；可变 `W=160/200/240` 在 `0.71/1.00×` 接头空洞 `0px`、内容侵入 `0px`；display-region `6/6 pass`；双次重建 SHA 一致；用户于 `2026-08-11` 明确确认；ImageGen `0/0` | `prompt-authorized / P3` | V2-A／V2-B 已授权；先执行四端帽，内部通过后执行四横轨 |

## 下一门禁

`UF-A1-V2-SIM-V2` 已确认，稳定子模块定义、`UF-A1 V2-A V1`／
`UF-A1 V2-B V1` 最终正文、builder 合同和两段最多五次的修复边界均已授权。
下一门禁是先执行 V2-A，逐稿完成固定分区、连通色键、等比 bbox-fit、端部接触、
真实排版与缩放审查；V2-A 内部通过后才执行 V2-B。两段合并后全部内部门禁
通过，才可达到 `candidate-reviewed / P3` 并交用户复审。用户接受前不得产出
tracked source/runtime、不得修改 addon。UF-A2／UF-B1 继续暂停。
