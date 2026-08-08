# Action Bars 动作槽基底 V1

## 元数据

- 模块：`actionbars`
- 组件 ID：`AB.SLOT`
- 版本：`AB.SLOT.BASE.V1`
- 子状态：`prompt-draft`
- 项目阶段：`P2 / simulation-confirmed`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 操作：`generate`
- 生成前模拟版本：`ACTION-BARS-CORE-SIM-V3`
- 生成前模拟方式：`deterministic-local-geometry`
- 模拟 ImageGen：`0/0`
- 模拟脚本／specification：`tools/render_action_bars_simulation.py`／
  `tools/specs/action_bars_core_simulation_v3.json`
- 本地渲染错误：`0`
- 模拟路径／SHA：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V3/action_bars_core_sim_v3.png`／
  `b2761b672057c55a9358eba09859a00e60a7ee807d1c546d7ca1b14ca53c87e8`
- 模拟用户结论：`SIM-V1 rejected 2026-08-08`；
  `SIM-V2 user-revision-requested 2026-08-08`；
  `SIM-V3 confirmed 2026-08-08`
- 自动修复预算：最多 `5` 次实际 ImageGen 生图／修图，含首次
- 当前实际生图：`0/5`
- 流程错误：`0`（无候选且无 provider 生成证据时不占生图额度）
- 多执行正文最坏实际生图数：`5`；仅一个初始正文，后续 `.rN` 必须保持本文件
  的不可变边界
- 锁定视觉基准：
  - Image 1：
    `assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png`，
    `1254×1254 RGB`，SHA-256
    `b5c364482adaace09af9b5196d2e8d4f7ef79d3b21706e189d94c106ba6ec2ba`；
    只锁定槽体的香草手绘材料、综合色、左上暖光与磨损尺度
- 基准提示词 provenance：
  - `docs/modules/character/ART_BASELINE.md` 与
    `docs/modules/character/SUBMODULE_ART_BASELINES.md`：解释 Image 1 的深胡桃
    旧皮、克制氧化黄铜、低饱和与装备槽材料关系
  - `docs/modules/actionbars/ART_BASELINE.md` 与
    `docs/modules/actionbars/SUBMODULE_ART_BASELINES.md`：把该材料转译为高频点击的
    普通动作槽
  - `docs/GLOBAL_ART_BASELINE.md`：香草时代、二维手绘、字体与反模式总约束
- 次级参考：无；V3 模拟、旧模拟、provider 截图和本地 scaffold 均不得上传
- raw：待授权后写入
  `generated/actionbars/AB.SLOT/AB.SLOT.BASE.V1/attempt-01/`
- 透明候选：待生成后仅在 ignored 审查副本上执行确定性色键
- 重组预演：待候选通过 source 门禁后生成；本批无 atlas／九宫格
- 真实排版预演：待候选出现后，以 Bar `1–10` 的真实按钮数量、合法行列、
  `20／28／30／36／48 UI` 图标尺寸、空槽与动态状态覆盖生成 `100%` runtime
  场景；相邻 Rail、狮鹫、消耗品和饰品继续使用真实 provider fallback 或明确
  非权威占位
- 实际展示区域合同／报告：合同见下文；报告待候选出现后生成，当前不宣称 pass
- 最终 source：无

## 跨设备 handoff

- 不建立。下一门禁只依赖本 tracked work 文件中的确定正文，不依赖 ignored
  像素；不得把 V3 模拟复制进 `handoff/`。

## 美术基准继承

### 权威顺序

1. Character V3 锁定图及 Character 主／子模块 Prompt，只承担槽体材料 DNA。
2. Action Bars 主／子模块 Prompt，承担动作槽身份、轻量化和战斗可读性转译。
3. `docs/GLOBAL_ART_BASELINE.md`，承担香草时代语言和全局反模式。
4. `docs/modules/actionbars/SUBMODULES.md`，承担真实对象、尺寸、状态层序与禁止
   烘焙合同。
5. 无既有 Action Bars source；V3 模拟只承担已确认的整体布局方向，不是像素
   或 ImageGen 输入权威。

### 必须继承的视觉 DNA

- 香草魔兽二维手绘、低分辨率可读的轮廓与非 PBR 表面。
- 深胡桃／烟褐旧皮凹面、克制的暗旧氧化黄铜窄沿、左上短暖光、右下暗压边。
- 低饱和、少量不规则磨损与手工作感；磨损不能变成噪点、污泥或高频刮花。
- 材料必须在约 `19–42` 物理像素的实际显示范围仍能被识别，但不得抢过技能
  图标、冷却和数字。

### 本批组件级转译

- 只生成一枚 Bar `1–10` 共用的普通／空槽基底，不生成 Rail、端帽、姿态槽、
  宠物槽、消耗品口袋、饰品护套或任何状态 atlas。
- Character 装备槽的黄铜厚度收窄为动作槽的短边唇；中央约 `90%` 线性尺寸
  变为安静、低细节、可由真实技能图标覆盖的深皮凹面。
- 同一方形纹理统一缩放到 provider 的逐按钮 backdrop；不锁定按钮数、行数、
  水平／竖向或用户 scale。

### 明确不继承

- Image 1 的整张角色面板、人物、装备图标、紫色品质光、纸面／木框、属性文字、
  页签、按钮、面板比例、槽数量与装饰位置。
- V1／V2／V3 模拟中的平面色、假图标、假文字、单位框像素、Rail、皮袋或
  屏幕背景。
- 现代仪表板、玻璃拟态、霓虹、石雕、哥特祭坛、珠宝宝座、机械栅格、完整
  金属板和高亮宝石。

### 冲突审计

- Character 装备槽的厚重展示感与动作槽高频可读性冲突：以 Action Bars 合同
  裁决，保留材料但收窄边沿、移除品质光和珠宝感。
- 早期“普通／悬停／按下／激活／禁用四／五态 atlas”想法与真实 pfUI 对象
  冲突：以 `actionbar.lua` 为准，本批只做 base；highlight、active、equipped、
  icon tint、cooldown 与按键动画继续独立。
- V3 模拟可确认整体重量和约 `39px` 主按钮，但其像素不是美术权威：执行正文
  只写回尺寸／可读性条款，不上传模拟图。

## 组件合同

- 逻辑对象与数量：恰好 `1` 枚普通动作槽基底。
- 每个对象状态：只有 `normal／empty base` 一态。没有独立 hover、pressed、
  active 或 disabled cell；这些由以后独立的 `AB.SLOT.STATE` 合同和现有 provider
  动态层表达。
- pfUI／provider 映射：Bar `1–10` 的
  `pfActionBar<BarName>Button1..12.backdrop`，真实创建名包括 Main、Paging、
  Right、Vertical、Left、Top 与 StanceBar1..4；`addon/pfUI/modules/actionbar.lua`
  当前审计 SHA-256
  `5fd2fa29ec3f2534c090f4081ffbb96be57147eb181848111cccbf962626f74f`。
- runtime 层序：基底位于 `f.icon` 下；`f.equipped`、`f.cd`、`f.animation`、
  `f.highlight`、`f.active`、`f.macro`、`f.keybind` 与 `f.count` 保持动态并位于其上。
- runtime 尺寸：外框严格使用 provider 的 `icon_size + 2×border`；V3 典型
  `border=2 UI`。审查外框为 `24／32／34／40／52 UI`，其中主栏
  `36 UI icon + 2×2 UI border`、`scale=1.2`、UI Scale
  `0.81269841269841`，物理约 `39px`。
- 源画布与排布：精确 `1024×1024 RGB`，一个正面方槽居中；全部可见物件像素
  必须位于右／下不含的 `[192,192,832,832)` 安全盒，目标外轮廓约
  `[200,200,824,824)`，包含全部阴影与抗锯齿；画布边至少保留 `192px` 纯绿。
- 文字／图标安全区：`[232,232,792,792)` 为 `560×560` 中央安静区；允许深皮
  低细节底色，但不得有高对比纹样、铆钉、铭文或任何动态内容。该区在运行时
  由真实 `f.icon` 覆盖。
- 拉伸、裁切、UV：本批是单一方形等比缩放，不作九宫格、不平铺、不组成
  atlas。候选接受后，确定性 exporter 以完整可见 bbox 的最长边构造正方 crop，
  保持比例和中心，导出单张 `128×128` straight-alpha 运行时纹理并采样全 UV；
  不裁掉阴影、边唇或角部。
- Alpha／色键：raw 外部背景必须为像素级统一 `#00FF00`；以后只从画布边缘
  提取连通色键、转 straight Alpha 并把全透明 RGB 清零。物件内部禁止绿色
  铜锈，避免与色键冲突。
- 禁止烘焙：技能／物品图标、职业符号、按键、数量、宏名、冷却、范围红、
  法力蓝、不可用灰、装备绿、选中职业色、文本、数字、Rail、端帽与屏幕背景。
- 验收预演与回退：候选通过语义／物理、美术一致性、组件合同、技术像素和
  实际展示区域后才可请用户复审；source 接受前不创建接管路由。缺图、尺寸越界
  或 adapter 错误时保留 pfUI 原 backdrop。
- 真实排版预演：至少覆盖 `1×1`、`12×1`、`6×2`、`4×3`、`1×12`，普通／空槽、
  hover、active、equipped、range、OOM 与 cooldown 的代表性动态分布；状态层
  仍使用 provider 真实对象，不把未完成相邻组件伪装为最终像素。
- 实际展示区域：source 的完整可见 Alpha bbox、运行时 `128×128` 全 UV 与
  Button backdrop 外框必须一致；中央 live icon 覆盖区、快捷键／数量／宏名、
  cooldown、外框可见边和 provider 现有 hit rect 分别检查。美术纹理不得扩大
  命中区；Frame 尺寸必须来自 `icon_size` 与实际 actionbar border。

## 生成前模拟实例图

### 模拟合同

- 版本：`ACTION-BARS-CORE-SIM-V3`
- 目标场景与 Frame 真实比例：目标设备 `1920×1080`、UI Scale
  `0.81269841269841`；DoiteDPS、SwingTimer、Player／Target、Castbar 与动作栏
  均按 provider UI unit 换算。
- 当前 accepted/runtime 邻接 UI：pfUI Chat 与原 provider UnitFrames；本模块
  尚无 accepted source/runtime。
- 真实对象数量与代表性信息密度：主／副／姿态／辅助 Bar、`51` 个典型动作／
  物品容量、双方状态、双施法、双攻击计时与 DoiteDPS Ready／Forecast／资源。
- 目标层序与交互状态：DoiteDPS `y=514–551` → 攻击计时 `570–593` → Aura
  `612–631` → Player／Target `639–700` → 双施法 `708–728` → 姿态 `744` →
  副栏 `783` → 主栏 `827–870`；主栏与单位框最重，邻接读数逐级减轻。
- 用户确认：整体布局、战斗扫视路径、物件隐喻、材料层级、配色、视觉重量与
  左右随身栏整合。
- 刻意简化且非权威：所有平面色、图标、文字、纹理、Alpha、接缝、UV、槽状态
  与相邻 UI 像素。
- 禁止用途：不得作为 source/runtime、不得裁切／切片／晋级、不得作为生产
  edit/reference 输入。

### 本地模拟规格与结果

- specification：`tools/specs/action_bars_core_simulation_v3.json`，SHA-256
  `bf4f5c1fe358af257a21c1966660c2a08ec6f0fbea89a31790c8a63f337829f8`
- 脚本：`tools/render_action_bars_simulation.py`，SHA-256
  `c0dfe1b76014edd889e448b3d27d26e151ea9d22eb020f51385a9a534346dfba`
- 命令：
  `python tools/render_action_bars_simulation.py tools/specs/action_bars_core_simulation_v3.json --repo-root . --layout-report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V3/layout-report.json`
- ImageGen：`0/0`；本地渲染错误：`0`
- 输出：见元数据；PNG `1920×1080 RGB`
- display-region：
  `tools/specs/action_bars_core_simulation_v3_display_region.json`；报告 SHA-256
  `137c2908a7e1f45b388e4a2924c5ad24782fe53ef678a5bf060d4ac3501f253e`，
  新增战斗读数 `9/9 pass`、violations `0`
- 布局报告 SHA-256：
  `e794be514fd9a75552149be013e93a909320635fc2be82a5eafc1a8563ba9bd3`，
  `46/46 pass`、violations `0`
- 内部结论：`displayable`
- 用户结论：`SIM-V3 confirmed 2026-08-08`；若上述可见关系实质变化，确认失效
- 下一门禁：`AB.SLOT.BASE.V1` 最终生产正文授权

## 生产正文完整性预检

- 复杂度：`single-object`
- 结论：`pass`

| 门禁 | 最终执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | 明确一枚普通／空槽基底、一态，逐项排除状态、动态文字／图标与相邻组件 | `pass` |
| 每张输入图的 inherit／ignore 职责与权威冲突 | Image 1 的材料／光照／磨损继承、整面板／图标／品质光忽略及合同优先级完整 | `pass` |
| 画布、格位、边距、方向、透视、尺度、光照与层序 | 精确 `1024²`、单安全盒、中央坐标、正交前视、左上光与基底层序完整 | `pass` |
| 逐对象形态、材料、边缘、状态与相互关系 | 外接触线、旧皮托底、黄铜窄唇、内凹面、四角和单 normal 状态逐层说明 | `pass` |
| 文字／图标安全区、裁切、拉伸、平铺、重复与接缝 | `560²` 安静区、等比单纹理、无九宫格／平铺／atlas、全 bbox 保留完整 | `pass` |
| 美术 DNA、具体反模式、Alpha／色键与最终自检 | 香草二维手绘、低饱和旧材质、具体禁项、纯 `#00FF00` 与逐项自检完整 | `pass` |

- 未知但执行必需的值：无。候选实际 bbox／Alpha 是生成后的审查结果，不是执行
  前未知合同。
- 去冗余结论：保留单物件计数、Image 1 职责、bbox、安全区、综合色、边沿厚度、
  色键和禁止动态内容的高风险重复；删除模拟历史、形容词堆叠和 Rail／状态细节。

## 最终执行正文 — `AB.SLOT.BASE.V1`

以下代码块中的正文是待用户明确授权后原样交给固定执行器的唯一初始正文；
不得在执行时改写、翻译、扩写或附加创意内容。

```text
Create one production bitmap asset for Azeroth Expedition UI, component AB.SLOT.BASE.V1: exactly one reusable normal/empty base for an ordinary pfUI action button. This is a compact square action-slot base that sits behind a live spell or item icon. It is not an inventory icon, not a complete action bar, not a rail, not a state atlas, not a presentation board, and not a mock game screenshot.

Image 1 is the locked Character V3 visual authority for material language only. Inherit its vanilla-era hand-painted treatment, deep walnut and smoke-brown aged leather, restrained dark oxidized brass, low saturation, short warm light from the upper left, darker pressure along the lower right, small-scale handmade wear, and readable low-resolution value grouping. Do not inherit Image 1's full character-panel composition, character, equipment or item icons, purple quality glow, paper or wood panel background, text, numbers, tabs, buttons, slot count, panel proportions, decorative placement, or any complete UI layout. If Image 1 conflicts with this component contract, preserve its material DNA but obey this prompt's single-slot geometry, quiet icon area, light visual weight, canvas, and exclusions.

Use an exact 1024 by 1024 RGB canvas. Place exactly one front-facing square slot centered at x=512, y=512, with no perspective tilt and no camera depth. Every visible object pixel, including antialiasing, edge wear, highlight, and any compact contact shadow, must remain inside the right-and-bottom-exclusive containment box [192,192,832,832). Aim for a centered outer silhouette approximately [200,200,824,824), about 624 by 624 pixels. Leave the entire canvas outside the object as uninterrupted chroma-key background. Do not draw coordinates, guides, cell lines, labels, captions, or a presentation frame.

Build the slot from outside to inside as one coherent physical object: a very compact dark contact line contained within the silhouette; a narrow deep-walnut leather backing edge; one restrained dark oxidized-brass lip with a short warm rubbed highlight on the upper-left edge and a darker lower-right edge; then a shallow recessed dark-leather center. Keep the outer silhouette square and stable with subtly hand-cut, slightly softened or clipped corners, but no protruding ornament. The brass must be a narrow functional lip, not a thick jewelry frame or a full metal plate. Use brown-black oxidation only, with no green verdigris. Do not add rivets, gems, runes, emblems, corner badges, filigree, chains, wings, claws, scrollwork, or repeated ornamental motifs.

Treat [232,232,792,792) as a 560 by 560 quiet icon-cover zone. It may contain a nearly flat deep-leather recess with restrained broad value variation and very subtle hand-painted grain, because the live icon will cover it, but it must contain no high-contrast mark, border, embossed symbol, stitch, rivet, scratch cluster, hole, glow, vignette, or decorative focal point. Keep all material transitions and the readable slot rim outside this quiet zone. The border must remain legible after the accepted object is reduced to a 128 by 128 texture and displayed from roughly 24 to 52 UI units, including the confirmed main-bar case of about 39 physical pixels, without competing with the live icon or cooldown.

Render this as classic vanilla World of Warcraft 2D hand-painted interface art: compact value shapes, slightly imperfect but controlled brushwork, low-frequency texture, and functional wear. It must not look photorealistic, PBR-rendered, beveled by a modern UI engine, glossy, glassy, plastic, machined, vector-clean, cyber-neon, gothic, demonic, monumental, stone-carved, jewel-encrusted, or like a modern MMO dashboard tile. Do not use a large cast shadow, ambient scene lighting, floor plane, vignette, depth-of-field, or environmental background.

Do not bake any spell icon, item icon, class symbol, hotkey, count, macro name, cooldown sweep, timer, text, number, range-red state, mana-blue state, unusable-gray state, equipped-green state, selected class color, hover glow, active glow, pressed displacement, disabled state, rail, gryphon, consumable pocket, trinket, unit frame, cast bar, swing timer, or DoiteDPS content into this asset. This output contains only the one normal/empty base.

Outside the one slot, use one perfectly flat, uniform, pixel-level exact #00FF00 chroma-key background, including all four canvas edges and all space around the object. The green background must have no gradient, texture, noise, checkerboard, transparency simulation, haze, bloom, floor, shadow, border, or alternate green. Do not allow green spill into the leather or brass, and do not place any green patina inside the object.

Before returning the image, check all of the following: the canvas is exactly 1024 by 1024 RGB; there is exactly one centered square action-slot base; all visible pixels fit inside [192,192,832,832); the central [232,232,792,792) zone is quiet and free of high-contrast details; the outer rim is compact, narrow, and fully intact; the upper-left warm light and lower-right dark pressure are restrained; no dynamic UI content or neighboring component is present; no modern, gothic, stone, jewel, neon, glass, or photorealistic language appears; and every background pixel outside the object is the same exact #00FF00.
```

## 自主修复循环

- 不可变修复边界：组件 `AB.SLOT`；版本家族 `AB.SLOT.BASE.V1(.rN)`；一个
  normal／empty base；仅固定 Image 1；Image 1 inherit／ignore 职责；`1024²`
  Canvas；单安全盒与中央安静区；正交前视；Character V3 材料转译；纯
  `#00FF00`；runtime 尺寸、层序、动态内容排除和全部反模式。
- 允许的自主修复：最多五次实际生成总额内，按首个失败门禁调整对象在安全盒内
  的等比大小／居中、边沿厚度、中央安静度、皮革／黄铜综合色、左上／右下明暗、
  磨损密度和纯绿色键。可以在明确保留已通过区域时编辑紧邻前一候选，或只用
  同一固定 Image 1 重新生成；每次都必须形成完整、自包含 `.rN` 正文并先提交。
- 必须重新授权：新增／替换输入图；上传 V3 模拟或任一 scaffold；增加对象／状态；
  把 Rail、端帽、状态 overlay、姿态／宠物、消耗品或饰品并入；改变视觉方向、
  Canvas、安全盒、中央安静区、provider、runtime 映射、Alpha 策略或允许的
  动态内容。
- 预算：首次生成计 `1/5`；不可用但已生成的图也计数；无图且无 provider 生成
  证据的流程错误不计。第 `1–4` 个候选失败后才可按上述边界准备下一版；任一
  候选完整内审通过立即停止；第 `5` 个仍失败则记录
  `repair-budget-exhausted`，不得 attempt 6。

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| `1/5` | `AB.SLOT.BASE.V1` / pending authorization | generate |  |  |  |  | pending |
| `2/5` | `AB.SLOT.BASE.V1.r1` / not prepared | edit／generate |  |  |  |  | unavailable until attempt 1 review |
| `3/5` | `AB.SLOT.BASE.V1.r2` / not prepared | edit／generate |  |  |  |  | unavailable |
| `4/5` | `AB.SLOT.BASE.V1.r3` / not prepared | edit／generate |  |  |  |  | unavailable |
| `5/5` | `AB.SLOT.BASE.V1.r4` / not prepared | edit／generate |  |  |  |  | unavailable |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
|  |  |  |  |  |  |

## 执行记录

- 日期：未执行
- 会话／结果 ID：无
- 实际输入绝对路径与职责：授权后固定为
  `D:\Git\azeroth-expedition-ui-overhaul\assets\locked\character\角色属性面板_香草同构收敛_风格确认_v3.png`，
  只承担正文声明的材料职责
- imagegen 报告的 revised prompt：无
- 输出尺寸／模式／SHA-256：无
- Alpha／残色：无
- 实际生图次数：`0/5`
- 流程错误次数：`0`
- 循环终态：`authority-blocked`

## 审查记录

- 语义／物理：真实 `AB.SLOT` base 与 provider 状态层已拆开；Prompt 未生成假
  Button、假技能或相邻组件。
- 透视／图层：Prompt 固定正交前视；base 在 icon 下，动态状态在上。
- 美术一致性：Character V3 的槽材料职责和 Action Bars 轻量化冲突已写入正文。
- 对象／状态合同：单物件／单 normal base；当前只完成文本预检。
- 装配／尺寸：`1024²` raw、安全盒、中央安静区、未来 `128²` 等比单纹理与
  `24–52 UI` 外框已定义；候选像素待生成。
- 真实排版：V3 整体方向已确认；正式候选的逐按钮真实排版尚未执行。
- 实际展示区域：合同已定义，报告待候选；当前不能标记 pass。
- 技术像素：待生成。
- 结论：`prompt-draft / complete / not authorized`
- 用户结论与日期：V3 `confirmed 2026-08-08`；生产正文 `pending authorization`
- 下一门禁：用户明确授权 `AB.SLOT.BASE.V1` 正文与最多五次实际生成／修复预算

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `SIM-V1` | deterministic PNG `fd5e1537…18d0`；display `9/9` | `user-rejected 2026-08-08` | 动作条上移；玩家／目标靠近并同基线 |
| `SIM-V2` | PNG `943d6fac…e5d0`；display `9/9`；layout `20/20` | `user-revision-requested 2026-08-08` | 加入施法、攻击计时和 DoiteDPS；重排 Aura |
| `SIM-V3` | PNG `b2761b67…c87e8`；新增 display `9/9`；layout `46/46`；V2 回归一致 | `user-confirmed 2026-08-08` | 不改变已确认布局；进入首批组件 Prompt 门禁 |
| `AB.SLOT.BASE.V1` | 单物件正文完整性 `6/6 pass`；ImageGen `0/5` | `prompt-draft` | 等待明确授权；不得提前生图 |
