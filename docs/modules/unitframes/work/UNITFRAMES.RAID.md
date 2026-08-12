# Unit Frames Raid 团队框架工作记录

## 元数据

- 模块：Unit Frames
- 组件 ID：`UF.RAID.*`
- 方向版本：`UF-RAID-SIM-V1`
- 正式生产版本：`UF-RAID-A1 V1 final.r2 / repair-prepared`
- 子状态：`repair-prepared / attempt-3-pending`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 当前操作：`generate`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`
- 自动修复预算：`UF-RAID-A1 V1 final` 最多 5 次实际 ImageGen，含首次；
  流程错误不计额度
- 当前实际生图：`2/5`；剩余 `3`
- 流程错误：`1`
- 多执行正文最坏实际生图数：`5`；本批只有一段正式正文
- 最新 raw：`generated/unitframes/raid/A1/V1/attempt-02/uf-raid-a1-v1-attempt-02-raw.png`，
  SHA `6e2b9686…8696`；无 candidate／source／runtime
- 锁定视觉基准：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA-256
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
    只继承 2004 年位图尺度、材料厚度、暖光与粗糙磨损。
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA-256
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`；
    只继承深胡桃旧皮革、手工误差和克制的暗铜响应。
- 次级现有 runtime：`UnitFrameHealthFillV1.tga`／`UnitFramePowerFillV1.tga`；
  模拟按真实像素使用，但 addon 尚未把它们路由给 Raid。

## 美术基准继承

### 权威顺序

1. 上述两张 Chat 锁定图及其在 Unit Frames 主／子模块 Prompt 中声明的受限职责；
2. `docs/modules/unitframes/ART_BASELINE.md`；
3. `docs/GLOBAL_ART_BASELINE.md`；
4. `docs/modules/unitframes/SUBMODULES.md` 的真实对象、几何和动态所有权；
5. 已接受 Health／Power source，只负责条形颜料材质，不反向定义外壳。

### 必须继承的视觉 DNA

- 物件身份仍属于“远征队行军身份牌”：旧马鞍带、盾牌背带、帐篷捆扎皮被
  拆下重用，皮革承担结构，黄铜只作少量修补。
- 低饱和烟褐／深胡桃色、左上暖光、早期 WoW 宽块面和低频手工误差；不靠
  均匀毛孔、规则针脚或对称铆钉制造做旧。
- 粗犷感在 40 个对象组成的整体编队中成立；单个成员条必须轻薄，不能把每个
  `70×33` Button 变成一个厚重卡片。

### 本批组件级转译

- 每个成员是夹在远征点名册编队中的短皮革名条，不是独立书页、书签或缩小的
  Player／Target 外壳。
- 使用 `A/B/C/D` 四个完整外壳变体，按 `pfRaid` 槽位确定性分配；缺口、补针、
  暗铆钉和短修补位置不同，但综合色重相同。换人不改变槽位外观。
- 外夹边只在 Button 外露约 `2px`，中心由真实 Health／Power、名称与状态占据；
  40 人密度下不增加一圈共享书框、金属框或半透明底板。
- Hover／Aggro 只响应两三段破边；Range／Offline 继续由 pfUI Alpha 表达。

### 明确不继承

- 不继承 Chat 的书页、书脊、频道签、蜡封、立柱、龙纹或完整书框；
- 不继承主单位框的较厚端部、身份夹片比例或 `214×42` 轮廓；
- 不新增《暗黑破坏神 3》黑铁祭坛、现代玻璃卡片、整框霓虹或规则工业网格。

### 冲突审计

- 全局“厚重”与 40 人信息密度冲突：厚重由整组暗色材料和真实状态密度产生，
  单成员外夹边保持 2px；不得把重量误译为 40 个厚框。
- “不工整”与可读性冲突：只在外轮廓、染色、短补针和四变体分布中产生低频
  差异；Health／Power、安全区、名称中心与点击盒仍精确对齐。
- 原 pfUI 完整矩形 Glow 与本项目语言冲突：保留状态逻辑，未来只替换绘制层。

## provider 审计与边界

- `addon/pfUI/modules/raid.lua` 创建 `pfRaid1..pfRaid40`，每个均来自
  `pfUI.uf:CreateUnitFrame("Raid", i, C.unitframes.raid)`；全部是真实 Secure
  Button，并登记 ClickCast。
- 当前仓库 profile：`maxraid=40`、`raidlayout=10x4`、`raidfill=VERTICAL`、
  `raidpadding=5`、`border=1`、`width=70`、`height=30`、`pheight=2`、
  `pspace=-1`、`portrait=off`。
- `UpdateFrameSize()` 得到 Button `70×33`；HP 为 `70×30`，Power 为 `70×2`，
  中间 `1px`；布局 pitch 为 `77×40`。40 个 Button bbox 为 `763×153`；计入
  `2px` 外壳和最高 Raid Icon 后的视觉包络为 `767×159`。
- Cluster 固定从屏幕左下 `x=2` 开始；因此左侧外扩最多 `2px`，否则首列会被
  屏幕裁切。模拟使用 `74×37` 外壳，不修改 Cluster Point。
- `raidforgroup` 可把同一对象用于五人队，`selfinraid` 可用于单人；二者当前
  profile 均关闭。`raidgrouplabel` 当前关闭，但 provider 最多已有 8 个
  `Group N` FontString 对象。
- `addon/pfUI/modules/group.lua` 的 Party／PartyTarget／PartyPet 以及
  `modules/raidmarkers.lua` 的 Raid Marker 血条列表均不属于本批。

## 组件合同

| 逻辑对象 | runtime 数量 | 本批处理 | 动态所有权／禁止烘焙 |
|---|---:|---|---|
| `UF.RAID.MEMBER.SHELL.A-D` | 40 选 4 | 四个完整背景外壳；每个标准 art box `74×37` | 不烘焙名称、血量、职业色、状态、图标或点击 |
| `UF.RAID.BAR.HEALTH.FILL` | 40 | 模拟复用已接受 `64×32` donor；确认后再扩展 adapter scope | 数值、宽度、颜色、动画与治疗预测归 pfUI |
| `UF.RAID.BAR.POWER.FILL` | 40 | 模拟复用已接受 `64×16` donor；真实显示高 `2px` | Mana／Rage／Energy／Focus 色与裁切归 pfUI |
| `UF.RAID.STATE.RIM` | 每框按需 | 未来从接受外壳 Alpha 确定性派生短边 mask | Hover／Aggro／Combat 事件归 pfUI；禁止整框光圈 |
| `UF.RAID.STATE.PIP` | 每框最多 1 | provider 选项启用时使用小型破颜料角标；不单独 ImageGen | `squareaggro`／`squarecombat` 判定归 pfUI |
| `UF.RAID.AURA.RIM` | 每框最多 6＋驱散图标 | 只增加 1px 烟黑承托；图标本体不重绘 | Aura、层数、冷却、驱散类型与 Tooltip 归 pfUI |
| Vanilla 功能 glyph | 每框按需 | 队长、主拾取、Raid Target、复活保留动态身份 | 不烘焙进外壳；后续只允许增加暗色承托 |
| `UF.RAID.GROUP.LABEL.BACKING` | 最多 8 | 已审计，因当前关闭而暂停 production | `Group N` 文字继续是 FontString |

### 尺寸、拉伸与层序

- 标准外壳相对真实 Button 外扩 `left/right/top/bottom=2px`；外壳必须
  `EnableMouse(false)`，Button 命中盒仍为 `70×33`。
- 标准高度固定为 `33px`。整体 UI Scale 由共同 Parent 同步缩放，不会产生
  拼接错位；若用户只改变 Width，接受完整 source 可确定性派生横向三切片，
  唯一修补必须留在固定端部。Height 偏离当前合同则局部 fail-open，不纵向
  强拉美术。
- 层序由低到高：外壳／烟褐 liner → HP／Power 背景 → 动态 fill／治疗预测 →
  名称 → Buff／Debuff／Raid Icon／复活 → 短边状态响应。任何 art 不接管鼠标。
- 原 `CreateBackdrop` 透明方块与 `glow2` 只会在 P5 adapter 成立后针对 Raid
  隐藏／替换；其他 UnitFrame 保持原状。

## 生成前模拟实例图

### 模拟合同

- 版本：`UF-RAID-SIM-V1`
- 目标场景：当前 profile 的完整 40 人团队、真实屏幕锚点、Chat／经典动作条／
  罗盘邻接；审阅板另含四变体、状态层、可选 Group Label 与 100% 重复密度。
- 真实对象数量：`40`；不是稀疏 contact sheet。
- 状态分布：Hover、Aggro、Range、Offline、Dead、Incoming Heal、Resurrection、
  Buff、Magic／Poison、Leader、Master Looter 与三个 Raid Marker。
- 当前 accepted/runtime：Health／Power 使用 addon 内现有 TGA 的真实像素；
  新外壳、状态边缘与相邻 UI 均为简单几何占位。
- 用户需要确认：不增加共享外框；薄皮革点名名条隐喻；四变体力度；暗色配色；
  单框与 40 人整体的重量；状态是否清楚且不过度现代。
- 非权威：最终笔触、Alpha、source extraction、production canvas、atlas packing、
  Group Label 成品和目标设备 SavedVariables。
- 禁止用途：模拟像素不得成为 source/runtime，不得作为生产 edit/reference 输入。

### 本地模拟规格与执行

- specification：`tools/specs/unitframes_raid_simulation_v1.json`
- renderer：`tools/render_unitframes_raid_simulation_v1.py`
- Python：`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- 命令：`conda run -n py312 python tools/render_unitframes_raid_simulation_v1.py`
- scene：
  `generated/unitframes/raid/simulation/V1/unitframes-raid-sim-v1.scene.png`，
  SHA-256 `41468266052da80579f1194f028a83adf7dc81afce6f458d617a0ea246325519`。
- review：
  `generated/unitframes/raid/simulation/V1/unitframes-raid-sim-v1.review.png`，
  SHA-256 `10158347dd9ba002cb07f3519d8a42174547340ee79ff176fce9e9608e08eca2`。
- ImageGen：`0/0`；本地渲染错误：`0`。
- 内部结论：`displayable`。40 人密度、四变体分布、已接受条纹理、状态层和
  相邻 UI 可共同读取；没有额外共享外框。

### 实际展示区域门禁

- 合同：`tools/specs/unitframes_raid_simulation_display_region_v1.json`
- 报告：`generated/unitframes/raid/simulation/V1/display-region-report.json`，
  SHA-256 `ddb3fc51b7c3ef2e1590ecc145b4668ed3d23c5e627600dfa2d0a424a8ce6dd0`。
- 结果：`7/7 pass`，violations `0`，first failure `null`。
- 覆盖：单成员普通／重状态、40 人 Vertical／Horizontal、20 人、五人复用、
  `width=90` 横向变化；Height 变更明确不在本合同内并 fail-open。

### 用户方向结论

- 具体模拟版本：`UF-RAID-SIM-V1`
- 用户结论与日期：`confirmed / 2026-08-12`
- 模拟像素接受：`false`
- 正式生产授权：`true / UF-RAID-A1 V1 final / 2026-08-12`
- 已确认并写回正式正文的可见条款：
  - 维持真实 `40` 个 `pfRaid` Button 与 `10×4 VERTICAL` 密度，不增加覆盖
    整团的共享外框、底板或装饰背景；
  - 每个成员是薄的手裁旧皮革点名名条，四变体重量一致；粗犷与厚重来自
    40 个暗色物件形成的编队，而不是把每个对象做成厚卡片；
  - 使用低饱和烟褐、深胡桃、少量氧化暗铜与左上暖光；继承 Chat 的年代、
    笔触、材料厚度与磨损节奏，但不复制书本轮廓；
  - 既有 Health／Power 材质、名称、状态、Aura 与 Vanilla glyph 保持动态，
    Hover／Aggro 未来只用断续短边反馈。
- 确认失效条件：改变共享外框结论、成员物件隐喻、四变体数量、综合色重、
  配色、真实编队密度或动态状态层级时，必须返回新模拟版本。
- 授权原文：用户确认每次上传固定 SHA 的 Image 1／2，attempt 1 无 Image 3；
  仅允许同循环紧邻前次完整 production sheet 在冻结修复边界内作为 Image 3
  edit 输入；最多 5 次实际 ImageGen，流程错误不占额度；允许合同内固定四格
  拆分、边缘连通色键、透明 RGB 清零、bbox 归一化、`74×37` runtime、
  `6/62/6` 三切片派生及真实排版预演。
- 下一门禁：以已提交的 `UF-RAID-A1 V1 final` 原文调用固定执行器 attempt 1，
  然后执行完整内部审查；不得自动晋级 source。

## `UF-RAID-A1 V1 final` 正式生产合同

### 生产粒度与打包

- 一段正式正文只生成 `UF.RAID.MEMBER.SHELL.A-D` 四个完整背景外壳，物理上
  放在同一 `1536×1024` 生产 sheet，逻辑上仍是四个独立 source；固定格位可
  确定性拆分，不会把 40 个 Secure Button 合并为一张交互背景。
- `UF.RAID.STATE.RIM`／`STATE.PIP`／`AURA.RIM` 在接受外壳后确定性派生，不
  单独 ImageGen；Health／Power 在接受本批后复用现有已接受 source；当前关闭
  的 Group Label backing 继续暂停。因此本批只有一段正文，最坏总计 `5` 次
  实际 ImageGen。
- 机器合同：`tools/specs/unitframes_raid_production_v1.json`。

### Canvas、格位与 source 几何

- 输出：`1536×1024 RGB`，纯 `#00FF00` 背景，正面正交视角，无标签、网格、
  尺寸字或 UI 效果图。
- 固定 cell：A `[0,0,768,512]`；B `[768,0,1536,512]`；
  C `[0,512,768,1024]`；D `[768,512,1536,1024]`。
- 各完整外壳目标可见 bbox 均为 `592×296`：A `[88,108,680,404]`；
  B `[856,108,1448,404]`；C `[88,620,680,916]`；
  D `[856,620,1448,916]`。每格恰好一个连通实体，不跨格、无独立碎屑。
- 每格提取并归一化为一个 `592×296 RGBA` source，确定性缩至完整
  `74×37` runtime。normalized source 中真实 Button 为 `[16,16,576,280]`，
  Health `[16,16,576,256]`，`8px` 间隔 `[16,256,576,264]`，Power
  `[16,264,576,280]`；名称安静区 `[40,48,552,232]`。
- 横向 width 变化只从同一完整 source 派生 `48/496/48` source 三切片，即
  runtime `6/62/6`；变体唯一识别细节必须完全留在左右固定 `48px` source
  cap。高度固定，不纵向拉伸；整体 UI Scale 由共同 Parent 一起缩放。

### 色键、后处理与客观门禁

- 外壳是完整不透明的“皮革夹边＋烟褐 liner”背景板，不是空心皮环；纯绿只
  存在于每个物件外轮廓之外。liner 会位于真实动态条下方，必须安静、低对比。
- 允许：固定格位拆分、边缘连通绿幕转 Alpha、透明 RGB 清零、每格单物件 bbox
  提取、在 ratio error 与 X／Y anisotropy 均 `≤8%` 时归一化为 `592×296`、
  完整纹理缩放、atlas padding／extrusion、三切片与状态短边 mask 派生。
- 禁止：Python 补画／移动／复制／镜像修补，跨格复用像素，删除结构来挽救
  失败物件，或改变 provider Frame、点击、事件、Roster 和动态内容。
- 技术门禁：每格 `1` 个前景连通实体；四边最小隔离 `64/80/64/80`；目标比例
  `2:1`、ratio error `≤8%`、归一化 anisotropy `≤8%`；detached fleck、内部
  绿洞与可见绿溢色均为 `0`。技术通过不能替代语义和美术审查。

## 生产正文完整性预检

- 复杂度：`atlas / four independent sources / repeat / horizontal-stretch`。
- 结论：`pass-final`；执行必需但未知的值：无。

| 门禁 | `UF-RAID-A1 V1 final` 中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、数量与动态排除 | 第 1、4、8、9 段冻结四个点名名条与全部禁止烘焙项 | pass |
| Image 1／2 inherit／ignore 与权威冲突 | 第 7 段逐图声明职责，并规定文字高于输入图 | pass |
| Canvas、格位、bounds、视角、光照与层序 | 第 2、3、4 段给出四格绝对坐标、bbox、正交视角和背景板层序 | pass |
| 逐对象轮廓、材料、磨损与四变体关系 | 第 5、6 段冻结统一重量与 A／B／C／D 身份 | pass |
| 安静区、crop、repeat、三切片和接缝 | 第 4、5 段给出 normalized source、动态区和 `48/496/48` | pass |
| 年代、反模式、色键与最终自检 | 第 6、8、9 段冻结 2004 手绘 DNA、禁用现代语言并逐项自检 | pass |

- 去冗余结论：只重复“恰好四物件／固定格位／完整背景板而非空心框／变体细节
  只在端帽／禁止动态内容”五项高风险约束；provenance 历史不写进模型正文。

## 最终执行正文

### `UF-RAID-A1 V1 final` — 四变体完整成员背景外壳

```text
Create one production sheet containing exactly four complete empty raid-member
background shells for Turtle WoW 1.18.1 and a Vanilla-era pfUI overhaul.
Return one 1536 by 1024 RGB bitmap on a perfectly uniform pure #00FF00
background. This is a source-asset sheet, not a gameplay screenshot, raid
window, concept board, contact-sheet presentation or assembled forty-player
panel. Draw no title, label, letter, number, grid line, guide, legend or fifth
object.

Use a fixed two-by-two cell layout. Cell A is x0..767/y0..511. Cell B is
x768..1535/y0..511. Cell C is x0..767/y512..1023. Cell D is
x768..1535/y512..1023. Put exactly one front-facing orthographic horizontal
shell in each cell. Aim each visible shell at exactly 592 by 296 source pixels:
A x88..679/y108..403, B x856..1447/y108..403, C
x88..679/y620..915, and D x856..1447/y620..915. Keep broad uninterrupted pure
green isolation around every object. Nothing may touch a cell edge, cross a
cell boundary, cast a shadow outside its own bbox or exist as a detached fleck.

Each cell is one complete solid background plate, not a hollow ring and not a
pile of separate border pieces. The plate is one physically connected object:
a thin hand-cut dark-walnut leather clamp edge wrapped around a quiet opaque
soot-brown liner that fills the entire interior. Pure green exists only outside
the outer silhouette; there is no green opening, transparent hole, internal
cutout, second slot or detached repair inside a plate. The liner sits behind
live Health and Power bars, so keep it matte, continuous, very low contrast and
free of symbols or sharp focal marks.

Every cell will be extracted to one 592 by 296 RGBA source and downsampled by
eight to one complete 74 by 37 runtime texture. At that runtime size the real
pfUI Secure Button occupies x2..71/y2..34, Health x2..71/y2..31, a one-pixel
gap y32, and Power x2..71/y33..34. The live name occupies the quiet central
area. Do not paint any simulated bar, fill amount, class colour, status colour,
name or icon. At full health only about two runtime pixels of the leather edge
remain visible around the live Button; therefore keep the individual shell
thin. The liner must still look intentional when an unfilled part of a live
StatusBar reveals it.

Design each complete source so it can later be divided horizontally into fixed
48-pixel left cap, quiet 496-pixel centre and fixed 48-pixel right cap, equal to
6/62/6 at runtime. Put every unique notch, stitch, rivet, patch or brass repair
entirely inside a fixed end cap. Keep the long centre extremely quiet, with
only broad low-frequency dye and soot variation; no unique mark may cross a
slice boundary, and no repeated stitch, cord, embossing or seam may run along
the centre. Height is fixed and will never be vertically stretched.

All four shells belong to one expedition muster set and must have the same
outer scale, liner area, darkness, visual weight and light direction. Their
differences are low-frequency and useful only to prevent forty industrially
identical repeats. A has one blunt hand-cut notch at the upper-left and two
short unequal repair stitches at lower-right. B has one off-centre dark rivet
at upper-right and a more repeatedly rubbed lower edge. C has one short
attached leather patch at the left edge and no bright metal. D has one short
skewed dark oxidized-brass repair at upper-right and one small split at
lower-left. Keep every repair attached to the plate, sparse and subordinate.
No variant may be more ornate, brighter or thicker than the others.

The world object is a compact expedition roster slip cut from discarded saddle
leather, shield straps or tent bindings and clipped behind one raid-member row.
It is not a miniature Player frame, book page, bookmark, scroll, furniture
trim, luxury leather label or modern card. Use deep soot-dark walnut and smoke
brown, very low saturation, sparse tarnished umber brass, and warm upper-left
light. Paint it like circa-2004 Vanilla World of Warcraft UI art: broad chunky
value blocks, readable material thickness, matte broken highlights and
deliberate low-resolution hand-painted edges. Ruggedness comes from slow
unequal cut thickness, uneven dye, smoke, mud rub, pressure wear and a few
repairs with believable tension. It does not come from random noisy waviness,
uniform pores or a procedural texture carpet.

The written requirements outrank both input images. Use Image 1 only for its
circa-2004 Vanilla WoW painted scale, broad low-resolution readability,
restrained warm contrast and believable material thickness. Ignore its screen
composition, text, portraits, book, pages, spine, channel tabs, wax seals and
complete frame geometry. Use Image 2 only for deep-walnut depth, warm
upper-left light, contact shadow, restrained dull-brass response, rough wear
and hand-made error. Ignore its pages, spine, columns, dragons, broad book
construction and large metal ornaments. Do not copy pixels, shapes or book
parts from either image. Do not use the geometric simulation, existing bar
textures, rejected unit-frame candidates or any unlisted image as a visual
source.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, symmetrical gold border, continuous metal rim, rounded
web card, transparent black glass, modern bevel, glossy meter, neon, full-frame
glow, black-iron shrine, spikes, skulls, horns, faction emblem, class emblem,
gem, magic rune, photoreal antique, regular lacing, equal-distance stitches,
symmetric rivets, repeated pebble embossing, orange piping, upholstery and
precision industrial geometry. Draw no portrait, Health or Power fill, text,
number, class colour, reaction colour, aura, buff, debuff, raid marker,
leader icon, master-looter icon, resurrection icon, combat mark, aggro mark,
hover state, button highlight or click feedback.

Before returning, verify visibly: one 1536 by 1024 RGB sheet; exactly four and
only four connected solid plates in fixed A/B/C/D cells; one plate near 592 by
296 in each cell; broad pure-green isolation with no detached flecks; no green
hole inside any plate; identical scale, liner area and weight; unique details
only in fixed end caps; thin rough hand-cut Vanilla craft; deep walnut and
soot-brown palette with restrained dull brass; quiet stretchable centres; no
shared raid panel, book geometry, modern industrial repetition or baked live
content.
```

## 自主修复循环

- 当前：`repair-prepared`；attempt 1／2 已退回，实际 ImageGen `2/5`，剩余
  `3`；流程错误 `1`。
- attempt 1 固定上传：
  - Image 1：`assets/locked/chat/聊天框视觉基准_v1.png`，SHA
    `90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06`；
  - Image 2：`assets/locked/chat/聊天框独立艺术资源_v3.png`，SHA
    `272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8`；
  - attempt 1 无 Image 3；模拟图与既有／失败 UnitFrame 像素禁止上传。
- attempt 2–5：每次仍固定 Image 1／2；只有明确保留合格格位时，才允许同一
  循环紧邻前次的完整 production sheet 作为 Image 3 edit 输入。每次从完整
  清单重新审查；同一首要失败不得重复相同策略。
- 不可变修复边界：四个组件 ID、四物件数量、A／B／C／D 格位与 Canvas、
  Image 1／2 路径／SHA／职责、已确认物件隐喻与综合色方向、完整背景板拓扑、
  runtime／安全区／三切片合同、动态排除和无共享 Raid 外框。
- 允许自主修复：固定格内 occupancy、低频手裁轮廓、磨损／染色／烟熏、liner
  对比、暗铜克制度、四变体端帽细节与绿幕隔离；可以按门禁选择 edit 或从固定
  Image 1／2 regenerate。
- 必须重新授权：新增或减少对象／状态／参考图，改变格位／Canvas／物件身份／
  配色／共享外框结论／runtime 几何／完整背景板拓扑，跨循环或跨段复用像素，
  把 Party／RaidMarker／Group Label 加入本批，或允许动态内容烘焙。
- 预算：最多 `5` 次实际 ImageGen；只有返回图或 provider generation 证据才
  计数。无图且无生成证据的流程错误单列，不占额度；内部通过即停，第五次仍
  有客观失败则 `candidate-rejected / repair-budget-exhausted`。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `UF-RAID-A1 V1 final` / `1c9f021` | generate | session `019ff4da-2586-7cc1-8174-8de62fab3f64`／result `ig_08eef8f9236c6505016a7c1f562d3081919a559bfb4db7deb9` | raw `88c8b1a0…7152` | 美术一致性：连续编绳／压纹边、规则圆角与家具皮具感；其次四格 ratio／isolation 失败 | 保留四格、实体背景板、深胡桃综合色、左上暖光与 A/B/C/D 身份；`.r1` 同时修正手裁边和绝对 bbox | internal-fail |
| 2/5 | `UF-RAID-A1 V1 final.r1` / `a741f91` | edit | session `019ff4e5-8c60-7fb2-a18f-49dda781d752`／result `ig_071317d2c8000f24016a7c22463e648191a391e53f1306efca` | raw `6e2b9686…8696` | 同一美术失败持续：连续压纹边、规则圆角、均匀皮纹；ratio／isolation 仍失败 | 停止沿用像素；`.r2` 从固定 Image 1／2 regenerate，保留合同但重建材料／轮廓 | internal-fail |
| 3/5 | `UF-RAID-A1 V1 final.r2` / pending repair commit | regenerate | — | — | — | attempt 3 不上传 Image 3 | repair-prepared |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 1 | `UF-RAID-A1 V1 final.r1` / `a741f91` | `019ff4e5…d752` | provider 图已生成并复制；child 后续使用无 Pillow 的系统 Python 做尺寸确认失败 | 不重生；以 `sips` 确认 `1536×1024 RGB` 并继续审查 | 不额外占生图额度；attempt 2 仍只计一次 |

### Attempt 1 执行与内部审查

- 固定执行器：`@openai/codex@0.143.0`；完整 user block 已确认未截断，没有
  wrapper 递归；Image 1／2 SHA 与授权一致，attempt 1 无 Image 3。
- session：`019ff4da-2586-7cc1-8174-8de62fab3f64`；provider result：
  `ig_08eef8f9236c6505016a7c1f562d3081919a559bfb4db7deb9`；执行器未报告 revised
  prompt。模型缓存 `base_instructions` 日志为不阻塞 warning，生成已真实完成，
  因而本次计 `1/5`，不登记为流程错误。
- raw：`1536×1024 RGB`，SHA-256
  `88c8b1a08c053aebf91a37416cbdbfb8bd28d53817d8d6fb7a42136886287152`。
- reviewer：`tools/review_unitframes_raid_candidate_v1.py`；技术报告
  `generated/unitframes/raid/A1/V1/attempt-01/review/technical-report.json`，SHA
  `e3b15de7…2e9f`；contact SHA `b7db933a…b94f`；40 人真实排版 SHA
  `2215fb21…e0ff`。后者使用真实 `40×`、成员 `74×37`、Button `70×33` 与
  `767×159` 包络；因本稿 ratio 失败，只能使用等比留白的诊断 runtime，不能
  冒充 candidate/source。

审查顺序与结论：

1. 范围／语义：通过。恰好四格、每格一个连通实体背景板、无动态文字／条／
   图标烘焙；A 缺口＋右下补针、B 暗铆钉、C 左补片、D 右暗铜修补均可辨认。
2. 物理／层序：通过。修补贴在皮革上，liner 是外壳内部底层，四物件均为正面
   正交视角；没有共享 Raid Panel。
3. 第一失败门禁——美术一致性：四件均形成连续隆起的编绳／压纹滚边、近完美
   等半径圆角和均匀家具皮革表面；D 的金属片与 C 的补片过大。它们违背
   “旧马鞍／盾带手裁、长段裸边、非工业重复”的锁定条款。
4. 组件／装配次级失败：A/B/C/D bbox 分别 `674×275`、`668×276`、
   `670×280`、`668×279`；ratio error `22.55%/21.01%/19.64%/19.71%`，
   anisotropy `18.40%/17.37%/16.42%/16.47%`，均超过 `8%`。四格 padding
   分别 `[70,186,24,51]`、`[29,186,71,50]`、`[69,51,29,181]`、
   `[29,51,71,182]`，均至少一边低于 `64/80/64/80`。
5. 技术通过项：四格各 `1` 个 Alpha32 连通体，visible green spill `0`，raw
   尺寸／模式正确；这些通过项不能挽救美术与比例失败。

- 内部结论：`internal-fail / repair-prepared`；不得交用户接受、不得写
  `assets/source/`、不得导出 runtime。下一步使用同段紧邻 attempt 1 完整 sheet
  作 Image 3，执行下列完整 `.r1` 有界 edit。

### `UF-RAID-A1 V1 final.r1` — attempt 2 自包含手裁边与绝对格位修复

```text
Edit Image 3 into one corrected production sheet containing exactly four
complete empty raid-member background shells for Turtle WoW 1.18.1 and a
Vanilla-era pfUI overhaul. Return one 1536 by 1024 RGB bitmap on a perfectly
uniform pure #00FF00 background. This is a bounded edit of the immediately
preceding full sheet from this same production loop. Do not create a gameplay
screenshot, raid panel, concept board, labels, letters, numbers, grid lines,
guides, a fifth object or separate loose parts.

Preserve only Image 3's successful structure and identity: exactly four cells;
one front-facing orthographic solid background plate in each cell; a dark
walnut leather edge around one quiet opaque soot-brown liner; one connected
physical mass per plate; consistent warm upper-left light; low saturation; and
the recognizable A/B/C/D repair identities. Do not preserve Image 3's current
object positions, panoramic 2.39-to-2.45 ratios, continuous raised braided
border, embossed piping, equal-radius rounded corners, uniform upholstery
finish or oversized repair hardware.

Use the same fixed two-by-two cells: A x0..767/y0..511, B
x768..1535/y0..511, C x0..767/y512..1023, and D
x768..1535/y512..1023. Redraw and recenter each complete visible plate into its
absolute target bbox, exactly 592 by 296 pixels: A x88..679/y108..403, B
x856..1447/y108..403, C x88..679/y620..915, and D
x856..1447/y620..915. Each object must become visibly less panoramic and
slightly taller than Image 3: reduce its current width by about 76 to 82 pixels
and increase its current height by about 16 to 21 pixels. Do not merely crop an
existing wide plate. Keep at least 64 pure-green pixels left and right and at
least 80 pure-green pixels above and below every object inside its own cell.
Nothing may touch or cross a cell edge, cast an external shadow, or exist as a
detached fleck.

Each object remains one complete solid opaque background plate, not a hollow
ring. Pure green exists only outside the outer silhouette; there is no green
opening, transparent hole, internal cutout, second slot or detached repair.
Fill the whole interior with the same quiet matte soot-brown liner, because
live Health and Power bars will be drawn above it. Keep the liner continuous,
low contrast and free of emblems, hard scratches, bar-like gradients or focal
marks.

Replace the current industrial perimeter on all four plates. Remove every
continuous rope, braid, lacing, pebble emboss, raised piping and machine-rolled
lip. Remove the perfect repeated rounded-rectangle silhouette and equal corner
radii. Redraw a thin attached leather clamp edge about 12 to 20 source pixels
wide: long mostly bare stretches, slow unequal hand-cut thickness changes,
four differently worn corner joins, a few matte broken highlights and no
repeating rhythm. The edge may be subtly blunt or chipped but must not become
randomly wavy. It must read as discarded saddle, shield-strap or tent-binding
leather cut and repaired in an Azeroth expedition camp, not upholstery,
furniture trim, a luxury label or an industrial product.

The final 592 by 296 source for each role will be divided horizontally into a
48-pixel left cap, quiet 496-pixel centre and 48-pixel right cap, then reduced
to one 74 by 37 runtime texture. Keep every unique identity feature completely
inside those fixed end caps. In A, keep one blunt upper-left notch only inside
x88..135 and two short unequal lower-right stitches only inside x632..679. In
B, keep one small off-centre dark rivet and its characteristic extra rub only
inside x1400..1447; the long lower centre keeps only the same quiet family wear
as the other variants. In C, shrink the attached left leather patch and its
unequal stitches entirely into x88..135; use no bright metal. In D, shrink the
skewed oxidized-brass repair entirely into x1400..1447 and keep the small
lower-left split entirely inside x856..903. No detail may cross a cap boundary.
No variant may be brighter, thicker or more ornate than another.

Keep the centre of each plate deliberately uneventful. Use broad low-frequency
smoke and dye changes only. Do not place a unique scratch, seam, stitch,
fastener, patch, hotspot or ornament across the central 496-pixel stretch band.
At 74 by 37, live bars, names, auras and status icons must remain dominant and
the perimeter must read as only a thin rough support.

Paint with circa-2004 Vanilla World of Warcraft UI language: broad chunky
hand-painted value blocks, deliberate low-resolution readability, matte
material thickness and restrained warm contrast. Use deep soot-dark walnut,
smoke brown and only sparse tarnished umber brass under warm upper-left light.
Ruggedness comes from unequal cut pressure, uneven dye, smoke, mud rub, missing
repair holes and believable local tension. Avoid random noise, photo texture,
uniform pores, orange leather, polished metal and glossy modern bevels.

The written requirements outrank all three input images. Use Image 1 only for
circa-2004 Vanilla WoW painted scale, broad low-resolution readability,
restrained warm contrast and material thickness; ignore its screen, text,
portraits, book, pages, spine, tabs, wax seals and full-frame geometry. Use
Image 2 only for deep-walnut depth, warm upper-left light, contact shadow,
restrained dull-brass response, rough wear and hand-made error; ignore pages,
spine, columns, dragons, broad book construction and large metal ornaments.
Use Image 3 only for its same-loop four-cell topology, solid plate anatomy,
deep-walnut palette, light direction and A/B/C/D identity anchors. Explicitly
discard its current bbox positions, wide ratios, furniture-like rounded form,
continuous embossed border and oversized C/D attachments. Do not use the
geometric simulation, accepted bar textures, rejected primary unit-frame
pixels or any unlisted image.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, continuous metal rim, symmetrical gold border, rounded
web card, black glass, glossy meter, neon, full-frame glow, black-iron shrine,
spikes, skulls, horns, faction or class emblems, gems, runes, photoreal
antiques, regular lacing, equal-distance stitches, symmetric rivets, pebble
embossing, orange piping, upholstery and precision industrial geometry. Draw
no portrait, Health or Power fill, name, number, class or reaction colour,
aura, buff, debuff, raid marker, leader or loot icon, resurrection icon,
combat, aggro, hover, button highlight or click feedback.

Before returning, verify visibly: exactly four and only four connected solid
plates; fixed A/B/C/D cells; each plate exactly 592 by 296 in its declared
absolute bbox; at least 64/80/64/80 pure-green cell padding; no detached fleck
or internal green hole; thin 12-to-20-pixel hand-cut perimeter; no continuous
braid, embossed piping or equal rounded corners; A/B/C/D identity entirely
inside fixed 48-pixel end caps; quiet stretchable centres; identical scale,
liner area, darkness and light; rough low-saturation Vanilla craft; and no
baked live content.
```

### Attempt 2 执行与内部审查

- 固定执行器 user block 完整；Image 1／2 与授权 SHA 一致，Image 3 是同循环
  attempt 1 完整 raw `88c8b1a0…7152`，未上传其他像素。session
  `019ff4e5-8c60-7fb2-a18f-49dda781d752`；provider result
  `ig_071317d2c8000f24016a7c22463e648191a391e53f1306efca`；未报告 revised
  prompt。raw `1536×1024 RGB`，SHA `6e2b9686…8696`。
- child 在生成／复制完成后用缺少 Pillow 的系统 Python 做尺寸确认失败，随后
  以 `sips` 成功确认。它是流程错误 `1`，没有第二张 provider 图；attempt 2
  仍只计一次实际 ImageGen。
- 报告：`generated/unitframes/raid/A1/V1/attempt-02/review/technical-report.json`，
  SHA `7c4a475b…c7d2`；contact SHA `afd38756…5e2f`；40 人真实排版 SHA
  `8862a384…d972`。
- 范围／物理仍通过：四个完整实体背景板、四身份、动态排除、正交视角和 liner
  层序未破坏。
- 第一失败仍是美术一致性：模型把连续压纹滚边、等半径圆角和均匀细碎皮纹
  原样保留，只降低了局部高光；A／C／D 端部附件依旧像规则家具修补件。相同
  首要失败连续出现，必须改变策略，不能继续拿本稿 edit。
- 次级几何：A/B/C/D bbox `679×287`、`675×288`、`678×290`、`675×289`；
  ratio error `18.29%/17.19%/16.90%/16.78%`，anisotropy
  `15.46%/14.67%/14.45%/14.37%`；padding `[65,189,24,36]`、
  `[29,188,64,36]`、`[63,60,27,162]`、`[28,60,65,163]`。虽比 attempt 1
  略收敛，仍不可执行授权 bbox normalize。
- 内部结论：`internal-fail / repair-prepared`。attempt 3 改为只用固定 Image 1／2
  从零 regenerate；不上传 attempt 2 或任何其他 Image 3，以摆脱连续工业滚边。

### `UF-RAID-A1 V1 final.r2` — attempt 3 自包含从零重建

```text
Create from scratch one production sheet containing exactly four complete
empty raid-member background shells for Turtle WoW 1.18.1 and a Vanilla-era
pfUI overhaul. Return one 1536 by 1024 RGB bitmap on a perfectly uniform pure
#00FF00 background. This attempt deliberately regenerates from the two fixed
visual references only. Do not reconstruct, imitate or retain any previous
raid-shell attempt. Do not create a gameplay screenshot, assembled raid panel,
concept board, title, label, letter, number, grid line, guide, fifth object or
loose component.

Use a strict two-by-two cell layout. Cell A is x0..767/y0..511. Cell B is
x768..1535/y0..511. Cell C is x0..767/y512..1023. Cell D is
x768..1535/y512..1023. In each cell draw exactly one complete front-facing
orthographic solid plate. Centre it with equal green bands on opposing sides.
Each plate is exactly 592 pixels wide and 296 pixels high, visibly a true 2:1
rectangle like two equal squares placed side by side, never a panoramic strip.
Use these absolute bboxes: A x88..679/y108..403; B
x856..1447/y108..403; C x88..679/y620..915; D
x856..1447/y620..915. That means each cell keeps about 88 pure-green pixels at
both left and right and about 108 pure-green pixels at top and bottom. Do not
expand a plate to fill most of its cell. Nothing touches or crosses a cell
edge, casts an outside shadow or appears as a detached fleck.

Each object is one solid opaque raid-row background plate: one quiet soot-brown
liner filling the complete interior, held by a very thin attached raw-hide
clamp edge. It is not a hollow frame, separate border kit, carved plaque,
furniture cushion or picture frame. Pure green occurs only outside the outer
silhouette. There is no internal green hole, transparent opening, second slot,
raised inset panel, horizontal divider or fake StatusBar. The liner is matte,
continuous, low contrast and nearly featureless because live Health, Power,
names, auras and state icons will cover it.

Make the perimeter fundamentally different from industrial leather goods. It
is the exposed hand-cut rim of one salvaged leather backing, only 12 to 20
source pixels thick, not an added cord or moulding. Use mostly flat, blunt,
near-square corner joins with four unequal wear patterns. Long sections are
bare and visually quiet. A few broken matte edge highlights may appear, but no
highlight continues around a corner and no two sides share a repeating rhythm.
Show slow hand-cut thickness variation, tiny nicks and pressure wear without
making a wavy cartoon outline. Draw absolutely no continuous piping, rope,
braid, lacing, rolled lip, embossed bead, pebble border, machine seam, regular
stitch track, perfect rounded rectangle or equal corner radius.

The final 592 by 296 plate becomes one 74 by 37 runtime texture and supports a
48/496/48 horizontal source split, equal to 6/62/6 at runtime. All unique
repair anatomy stays inside a fixed 48-pixel end cap. The central 496-pixel
band has only broad low-frequency soot and dye variation, with no unique
scratch, seam, stitch, patch, rivet, hotspot or ornament. Height is fixed and
will never be stretched.

All four objects have identical outer dimensions, liner area, darkness,
material thickness and warm upper-left light. Differences are sparse and
low-frequency. A has one blunt upper-left cut notch in its left cap and only
two short unequal lower-right repair stitches in its right cap. B has one
small off-centre dark rivet in its right cap and a slightly more rubbed patch
of raw leather at that same end; do not extend wear across the centre. C has
one very short attached leather repair within its left cap, held by two or
three irregular missing-hole stitches, and no bright metal. D has one small
skewed cracked oxidized-brass repair within its right cap and one tiny split
within its left cap. A repair occupies less than half of its cap height. No
variant is brighter, thicker, rounder or more ornate than another.

The world object is a compact expedition muster slip made from discarded
saddle leather, a shield strap or a tent binding, trimmed by hand in an
Azeroth camp. It is not a miniature Player frame, book page, bookmark, scroll,
luxury leather tag or modern card. Paint in circa-2004 Vanilla World of
Warcraft UI language: broad chunky hand-painted value blocks, deliberate
low-resolution readability, matte physical depth and restrained warm
contrast. Use deep soot-dark walnut, smoke brown and only tiny tarnished umber
brass accents. Ruggedness comes from unequal cut pressure, uneven dye, smoke,
mud rub, missing stitch holes and local repair tension—not uniform pores,
procedural grain, photo texture or random noise.

The written requirements outrank both input images. Use Image 1 only for
circa-2004 Vanilla WoW painted scale, broad low-resolution readability,
restrained warm contrast and believable material thickness. Ignore its screen
composition, text, portraits, book, pages, spine, tabs, wax seals and complete
frame geometry. Use Image 2 only for deep-walnut depth, warm upper-left light,
contact shadow, restrained dull-brass response, rough wear and hand-made
error. Ignore its pages, spine, columns, dragons, broad book construction and
large metal ornaments. Do not copy their book shapes or pixels. No geometric
simulation, bar texture, rejected unit-frame candidate or previous raid-shell
image is an input or visual source for this attempt.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, continuous metal rim, symmetrical gold border, rounded
web card, transparent black glass, glossy meter, neon, full-frame glow,
black-iron shrine, spikes, skulls, horns, faction or class emblems, gems,
runes, photoreal antiques, upholstery, furniture trim, industrial moulding,
continuous rope, braid, lacing, piping, rolled lips, equal-distance stitches,
symmetric rivets, pebble embossing, orange leather and precision geometry.
Draw no portrait, Health or Power fill, name, number, class or reaction
colour, aura, buff, debuff, raid marker, leader or loot icon, resurrection
icon, combat, aggro, hover, button highlight or click feedback.

Before returning, verify visibly: one 1536 by 1024 RGB sheet; exactly four and
only four solid connected plates; one true 592 by 296, 2:1 plate centred in
each fixed cell; roughly equal 88-pixel left/right and 108-pixel top/bottom
green bands; no detached flecks or internal holes; one flat 12-to-20-pixel
hand-cut raw-hide rim rather than an added border; blunt unequal corners; zero
continuous piping, braid, embossing or regular seam; four sparse identities
inside fixed end caps; quiet stretchable centres; identical weight and light;
rough low-saturation Vanilla craft; and no baked live content.
```

### Attempt 3 执行与内部审查

- 固定执行器 user block 完整；仅上传授权 Image 1／2，SHA 均一致；按修复策略
  未上传 Image 3。session `019ff4eb-de51-7fe1-98cb-570447d68de3`；provider
  result `ig_0ddc4352582d4a90016a7c23de41148191a5febff072277aa0`；raw
  `1536×1024 RGB`，SHA `41c9d561…e760`。
- 报告：`generated/unitframes/raid/A1/V1/attempt-03/review/technical-report.json`，
  SHA `759240e7…f5df`；contact SHA `3d9345ff…264b`；40 人真实排版 SHA
  `daac9c12…96ce`。
- 成功项：从零重建消除了前两稿的家具式圆角和编绳滚边；四件都成为同族的
  深胡桃、低饱和、实体外壳，A/B/C/D 身份可辨；四格 ratio error
  `3.92%/3.92%/3.63%/3.47%`、anisotropy 同值，均已低于 `8%`；各格仅
  `1` 个 Alpha32 连通体且 green spill `0`。
- 第一失败门禁——真实排版美术：外沿仍形成几乎连续的暖色锯齿亮线，内衬有
  均匀重复的细碎云纹；D 的亮黄修补件占右端过多。缩到 `74×37` 后，边线和
  D 补片仍会先于动态生命／法力内容抢焦点，不符合聊天框基准的克制粗粝感。
- 装配失败：A/B/C/D bbox `638×332`、`638×332`、`638×331`、`639×331`；
  A/B 的底边留白仅 `55`，C/D 的顶边留白仅 `56`，而 A/C 右侧仅 `39`、
  B/D 左侧仅 `39/38`。四件都被吸向整张 sheet 的中央十字；没有满足每格
  `64/80/64/80` 的最低留白，故不得执行 bbox normalize。
- 内部结论：`internal-fail / repair-prepared`。attempt 4 使用同段紧邻 attempt 3
  完整 raw `41c9d561…e760` 作为 Image 3；保留已经成功的粗粝实体与身份，只
  做格位收缩／外移、亮边中断、内衬降频和 D 补片收敛。

### `UF-RAID-A1 V1 final.r3` — attempt 4 自包含格位与低频材质修复

```text
Edit Image 3 into one corrected production sheet containing exactly four
complete empty raid-member background shells for Turtle WoW 1.18.1 and a
Vanilla-era pfUI overhaul. Return one 1536 by 1024 RGB bitmap on a perfectly
uniform pure #00FF00 background. This is a bounded edit of the immediately
preceding complete sheet from this same production loop. Do not create a
gameplay screenshot, raid panel, concept board, label, letter, number, grid,
guide, fifth object or separate loose component.

Preserve Image 3's successful art direction and topology: exactly four fixed
cells; one front-facing orthographic connected solid plate per cell; deep
soot-dark walnut leather; one quiet opaque liner; blunt unequal hand-cut
corners; sparse A/B/C/D end-cap identities; restrained warm upper-left light;
low saturation; and no baked live content. Do not replace these objects with
rounded cards, furniture trim, book pages, metal frames or a new metaphor.

Correct Image 3's sheet-centre attraction. The current plates are roughly 638
by 331 or 332 and all lean toward the central cross. Reduce every whole plate
to exactly 592 by 296 without cropping it, and move it away from the global
sheet centre into the exact centred bbox of its own 768 by 512 cell. A must be
x88..679/y108..403. B must be x856..1447/y108..403. C must be
x88..679/y620..915. D must be x856..1447/y620..915. Relative to Image 3,
shrink each object about 7 percent horizontally and 11 percent vertically;
move A about 26 pixels left and 35 pixels up, B 26 pixels right and 35 pixels
up, C 26 pixels left and 35 pixels down, and D 27 pixels right and 35 pixels
down. Keep at least 64 pure-green pixels left and right and at least 80
pure-green pixels above and below each object inside its cell. Make the
vertical green gutter between the two columns at least 128 pixels and the
horizontal green gutter between the two rows at least 160 pixels. Do not add
green inside an object, detach an end repair, cast an outside shadow or cross
a cell edge.

Each plate remains one complete opaque raid-row backing, not a hollow frame.
Pure green occurs only beyond the outer silhouette. Keep the whole interior
filled by one matte soot-brown liner because live Health, Power, names, auras
and state icons will be drawn above it. Do not draw a second inset panel,
divider, fake StatusBar, transparent opening or green hole.

Repair the current perimeter without changing its physical construction. The
attached raw-hide rim stays thin, flat and roughly 12 to 20 source pixels, but
remove the nearly unbroken amber jagged highlight that now traces all four
sides. Darken the rim toward soot walnut. Leave long matte stretches and only
four or five sparse broken dull-umber edge catches per object; no catch may
continue around a corner, and no pair may repeat at equal spacing. Flatten any
remaining beaded or craggy rhythm. Preserve slow unequal cut thickness, tiny
nicks and four differently worn blunt joins, but do not make a noisy sawtooth,
continuous piping, braid, rope, embossed lip or regular seam.

Repair the liner texture. Remove Image 3's evenly distributed small cloudy
rosettes, repeated mottling and procedural-looking grain. Replace them with
only two or three very broad, low-frequency, hand-painted soot or dye value
fields per plate, each roughly 80 to 180 source pixels across, with soft lost
edges and less than subtle contrast. The centre must look quiet at 74 by 37:
no repeated motif, uniform pores, pebble grain, sharp scratch, seam, stitch,
rivet, hotspot, emblem or ornament across its central 496-pixel stretch band.

The normalized 592 by 296 source will use a 48/496/48 horizontal split and
become one 74 by 37 runtime texture. Keep all unique anatomy completely inside
the 48-pixel end caps after the object is recentered. A keeps one small blunt
upper-left notch in its left cap and two short unequal lower-right stitches in
its right cap. B keeps one tiny off-centre dark rivet and a modest raw rub only
in its right cap. C keeps one short dark attached leather repair and irregular
missing-hole stitches only in its left cap, with no bright metal. D keeps one
small skewed cracked oxidized-brass repair only in its right cap and one tiny
split only in its left cap. Reduce D's current yellow patch to less than half
the cap width and less than half its height; darken it to tarnished umber so it
never becomes the brightest object. No unique feature may cross a cap boundary.

All four plates retain identical dimensions, liner area, darkness, material
thickness, scale and light. Paint in circa-2004 Vanilla World of Warcraft UI
language: broad chunky hand-painted value blocks, deliberate low-resolution
readability, matte depth and restrained warm contrast. Ruggedness comes from
unequal cut pressure, uneven dye, smoke, mud rub, missing stitch holes and
local repair tension—not precision geometry, random noise, photo texture,
uniform pores, orange leather, polished metal or glossy modern bevels.

The written requirements outrank all inputs. Use Image 1 only for circa-2004
Vanilla WoW painted scale, broad low-resolution readability, restrained warm
contrast and material thickness; ignore its screen, text, portraits, book,
pages, spine, tabs, wax seals and full-frame geometry. Use Image 2 only for
deep-walnut depth, warm upper-left light, contact shadow, restrained dull-brass
response, rough wear and hand-made error; ignore pages, spine, columns,
dragons, broad book construction and large metal ornaments. Use Image 3 only
for its same-loop four-cell topology, solid plate construction, successful
dark rough craft direction and A/B/C/D identity. Explicitly discard Image 3's
current oversized and centre-biased bboxes, continuous amber outline, repeated
cloudy liner grain and oversized bright D repair. No other image or prior
candidate is a source.

Forbid a shared raid frame, outer raid panel, parchment card, page edge,
bookbinding, wax seal, continuous metal rim, symmetrical gold border, rounded
web card, black glass, glossy meter, neon, glow, black-iron shrine, spikes,
skulls, horns, faction or class emblems, gems, runes, photoreal antiques,
upholstery, furniture trim, industrial moulding, continuous rope, braid,
lacing, piping, rolled lip, equal-distance stitches, symmetric rivets, pebble
embossing and orange edge light. Draw no portrait, Health or Power fill, name,
number, class or reaction colour, aura, buff, debuff, raid marker, leader or
loot icon, resurrection icon, combat, aggro, hover, highlight or click state.

Before returning, verify visibly: exactly four and only four solid connected
plates; fixed A/B/C/D cells; every complete plate centred at exactly 592 by 296
with at least 64/80/64/80 pure-green cell padding; at least 128 green pixels
between columns and 160 between rows; no detached fleck or internal green hole;
thin mostly dark raw-hide rims with broken rather than continuous highlights;
no repeated liner grain; identities contained by fixed end caps; D patch small
and dull; quiet stretchable centres; matched visual weight; rough low-saturation
Vanilla craft; and no baked live content.
```
