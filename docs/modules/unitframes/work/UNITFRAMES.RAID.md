# Unit Frames Raid 团队框架工作记录

## 元数据

- 模块：Unit Frames
- 组件 ID：`UF.RAID.*`
- 方向版本：`UF-RAID-SIM-V1`
- 正式生产版本：`UF-RAID-A1 V1 final / production-draft`
- 子状态：`simulation-confirmed / production-authorization-pending`
- 项目阶段：`P2`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 当前操作：`prepare`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`
- 自动修复预算：`UF-RAID-A1 V1 final` 最多 5 次实际 ImageGen，含首次；
  流程错误不计额度
- 当前实际生图：`0/5`；尚未授权或调用
- 流程错误：`0`
- 多执行正文最坏实际生图数：`5`；本批只有一段正式正文
- raw／candidate／source／runtime：无
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
- 正式生产授权：`false`
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
- 下一门禁：用户看过并明确授权 `UF-RAID-A1 V1 final` 正文、冻结修复边界与
  最多 5 次实际 ImageGen；当前不得上传或生图。

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

- 当前未启动；`UF-RAID-A1 V1 final` 实际 ImageGen `0/5`；流程错误 `0`。
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
| 0/5 | `UF-RAID-A1 V1 final` / pending authorization commit | 未调用 | — | — | — | 等待精确生产授权 | production-draft |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| 0 | — | — | 无 | — | 不占生图额度 |
