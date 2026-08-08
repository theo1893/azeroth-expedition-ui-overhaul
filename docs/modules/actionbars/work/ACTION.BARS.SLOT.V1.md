# Action Bars 动作槽基底 V1

## 元数据

- 模块：`actionbars`
- 组件 ID：`AB.SLOT`
- 版本：`AB.SLOT.BASE.V1`
- 子状态：`candidate-reviewed`
- 项目阶段：`P3 / candidate-reviewed`
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
- 用户生产授权：`confirmed 2026-08-08`；“授权执行 AB.SLOT.BASE.V1，并同意
  最多 5 次实际生成/修复。”
- 用户外部上传授权：`confirmed 2026-08-08`；“我授权将
  assets/locked/character/角色属性面板*香草同构收敛*风格确认_v3.png 上传至
  外部 ImageGen 服务，作为 AB.SLOT.BASE.V1 的 Image 1。”；该唯一匹配目标
  已解析为仓库精确路径
  `assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png`
- 自动修复预算：最多 `5` 次实际 ImageGen 生图／修图，含首次
- 当前实际生图：`5/5`；预算已用尽，不得自动执行 attempt 6
- 流程错误：`2`（`E1` 为固定子进程启动前的数据出境审查阻止；`E2` 为
  attempt 2 生成完成后的本地色键脚本参数错误；二者均未产生额外 provider
  生成，不占生图额度）
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
- raw：
  `generated/actionbars/AB.SLOT/AB.SLOT.BASE.V1/attempt-05/AB.SLOT.BASE.V1.r4.raw.png`，
  SHA-256 `0a0cae74fbb48bf233037425b0b58e080e5ea322aa677361de1925a6001011b8`
- 透明候选：仅供审查的确定性色键副本
  `generated/actionbars/AB.SLOT/AB.SLOT.BASE.V1/attempt-05/AB.SLOT.BASE.V1.r4.transparent-review-t20.png`，
  SHA-256 `e9089484d86c7f8af21266ed18ecc18672375e4c3afdd6562b54661453fd532d`
- 确定性归一审查：只执行 crop、Alpha、等比缩放、居中与精确色键复合；不重绘、
  不锐化、不是 source/runtime。`1024² RGBA` SHA-256
  `6d4a4d16e9a9c11248f0c63636e916e462d5d64f548335f26252e19e0b787dc0`；
  `1024² RGB #00FF00` SHA-256
  `f42d013451dffcb0a133497b485dcf5e9323dba8d3b2edc65649ae7f8b922c81`
- 重组预演：本批无 atlas／九宫格；只建立 `128×128` 全物件 review master，
  SHA-256 `2958f5e28621fd5cbc4e2d40da9b311f12e603dd58d8183f8758db463c50cbee`，
  不得作为 source/runtime
- 真实排版预演：attempt 5 已覆盖 `1×1`、`12×1`、`6×2`、`4×3`、`1×12`；
  目标设备全屏 `1920×1080` 预演 SHA-256
  `94c35f94a8d1d07f5fb1ed9f011c851e70341119c77f4a0f426899118cdf7756`；
  五模式板 SHA-256
  `39da034257eda4c8380e8a25f7a036e3a8a8a808793b1a9c3b06e4696df96820`。
  候选像素只用于 `AB.SLOT` base，动态图标／文字／状态为确定性 provider 内容；
  周边 V3 是已确认方向模拟，仍非权威 runtime 像素
- 实际展示区域合同／报告：attempt 5 合同 SHA-256
  `1c8432fb7ce1630d26fc30cc1101a44dd142d6a81c65298aa77f470ba2b3139d`；
  报告 SHA-256 `f461808e63e7b9fcd2e69228dfc7818b0aa64408882b0684e0385421398a0c7d`，
  `5/5 pass`、violations `0`
- 最终 source：无

## 跨设备 handoff

- 不建立。本轮用户复审在当前设备直接查看 ignored 的 attempt 5 确定候选；默认
  分支不得提交短期 handoff。若之后必须转交另一设备复审，需先按资产工作流在
  短期协作分支发布同一像素的最小检查点；不得把 V3 模拟复制进 `handoff/`。

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
- 下一门禁：提交完整 `AB.SLOT.BASE.V1.r1` 后，固定执行器从唯一已授权
  Character V3 Image 1 重新生成 attempt 2

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

以下代码块中的正文已于 `2026-08-08` 获用户明确授权，是原样交给固定执行器的
唯一初始正文；不得在执行时改写、翻译、扩写或附加创意内容。

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
| `1/5` | `AB.SLOT.BASE.V1` / `a26355d` | generate | child session `019fe064-635a-7581-b0f4-457269bb675c` | raw `518f8cf7…41e87` | 门禁 4／美术一致性：PBR／现代倒角与高频写实皮纹 | 保持单物件、正面、居中、无动态内容与深胡桃／暗黄铜色系；从 Image 1 regenerate，缩小物件、简化笔触并修正 Canvas／色键 | internal-rejected |
| `2/5` | `AB.SLOT.BASE.V1.r1` / `9e1e82f` | generate | child session `019fe073-f5ba-7033-b9be-58d9be04ed1f` | raw `82542910…739d1` | 门禁 4／美术一致性：仍为写实 PBR 双倒角与精密金属高光 | 保持更安静的中央值域、单物件、正面、无动态内容；从固定 Image 1 regenerate，把参考限制为配色关系并按低分辨率 sprite 粗粒度重绘 | internal-rejected |
| `3/5` | `AB.SLOT.BASE.V1.r2` / `34f03cb` | generate | child session `019fe07c-84d3-7750-8a99-01107a4ad91f` | raw `989bb567…3c08` | 门禁 5／组件合同：粗粒度手绘已通过，但外圈约占物件 `10%`，侵入目标 `5%` 安静区，且略纵长 | 保持低分辨率块面、综合色、单物件、接近正确的占屏与无动态内容；从固定 Image 1 regenerate，把完整 rim 减半并严格正方居中 | internal-rejected |
| `4/5` | `AB.SLOT.BASE.V1.r3` / `864987a` | generate | child session `019fe085-1944-7d73-8f03-2d13062d640e` | raw `bef74f6f…e0027` | 门禁 4／美术一致性：黄铜回退为高饱和亮金且几乎环绕全周，成为主视觉 | 保持粗粒度块面、平静中心、单物件与无动态内容；从固定 Image 1 regenerate，改用褐色主导的扁平 sprite／最多两条可见边带策略 | internal-rejected |
| `5/5` | `AB.SLOT.BASE.V1.r4` / `882c5fb` | generate | child session `019fe08a-b8e8-7db1-a286-b507bc74acd7` | raw `0a0cae74…011b8` | 无；确定性 canonical 审查通过全部门禁 | 保留褐色主导、低频安静中心、断续暗黄铜、单物件和正方居中；停止生成并交用户复审 exact canonical | `candidate-reviewed / P3` |

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| `E1` | `AB.SLOT.BASE.V1` / `a26355d` | 无；pre-launch approval rejection | 执行环境要求明确授权把指定 Character V3 锁定图上传至外部 ImageGen；固定子进程未启动，无图、无 provider 结果 | 用户已于 `2026-08-08` 明确授权该具体文件与用途；以同一正文重试 | 已解决；不占生图额度；`0/5` |
| `E2` | `AB.SLOT.BASE.V1.r1` / `9e1e82f` | attempt 2 已生成后；无额外 provider 调用 | 首次本地色键命令误用旧式位置参数与 `--output`，脚本只返回 usage，未写输出 | 改用脚本声明的 `--input／--out` 参数并以相同阈值重跑 | 已解决；不占生图额度；仍为 `2/5` |

## 修复执行正文 — `AB.SLOT.BASE.V1.r1`

以下为 attempt 1 完整审查后、同一授权边界内的自包含重新生成正文。只继续使用
已授权 Character V3 作为 Image 1；attempt 1 仅提供负面审查证据，不作为图片
输入。执行前必须先提交本版本。

```text
Create one production bitmap asset for Azeroth Expedition UI, component AB.SLOT.BASE.V1.r1: exactly one reusable normal/empty base for an ordinary pfUI action button. This is a fresh regeneration from the locked visual authority, not an edit of the previous candidate. It is one compact square action-slot base that sits behind a live spell or item icon. It is not an inventory icon, not a complete action bar, not a rail, not a state atlas, not a presentation board, and not a mock game screenshot.

Image 1 is the locked Character V3 visual authority for material language only. Inherit its vanilla-era hand-painted value grouping, deep walnut and smoke-brown aged leather, restrained dark oxidized brass, low saturation, short warm light from the upper left, darker pressure along the lower right, small-scale handmade wear, and deliberately illustrated low-resolution UI character. Do not inherit Image 1's 1254 by 1254 canvas size, full character-panel composition, character, equipment or item icons, purple quality glow, paper or wood panel background, text, numbers, tabs, buttons, slot count, panel proportions, decorative placement, or any complete UI layout. If Image 1 conflicts with this component contract, preserve its material DNA but obey this prompt's exact 1024 canvas, single-slot geometry, quiet icon area, light visual weight, and exclusions.

Create a brand-new exact 1024 by 1024 RGB output canvas regardless of Image 1's dimensions. Do not return 1254 by 1254 or preserve the reference canvas. Place exactly one front-facing square slot centered at x=512, y=512, with no perspective tilt and no camera depth. Every visible object pixel, including antialiasing, wear, highlight, and compact contact line, must remain inside the right-and-bottom-exclusive containment box [192,192,832,832). Make the centered outer silhouette approximately [200,200,824,824), exactly about 624 by 624 pixels. Compared with an object that would normalize to about [149,144,875,882], reduce the complete object uniformly by roughly fifteen percent and recenter it; do not crop it. Leave the entire rest of the canvas as uninterrupted chroma-key background. Do not draw coordinates, guides, cell lines, labels, captions, or a presentation frame.

Build the slot from outside to inside as one coherent but lightly weighted physical object: a compact dark contact line contained within the silhouette; a narrow deep-walnut leather backing edge; one restrained dark oxidized-brass lip; then a shallow recessed dark-leather center. Keep the outer silhouette square and stable with subtly hand-cut, slightly softened or clipped corners and no protruding ornament. Confine the complete readable rim and all material transitions to the narrow band between the approximate outer silhouette [200,200,824,824) and the quiet zone [232,232,792,792), about 32 source pixels per side. The brass is a thin functional lip, not a continuous bright double bevel, thick jewelry frame, full metal plate, or modern engine-generated border. Use brown-black oxidation with a few simplified hand-painted value breaks, one short rubbed warm highlight on the upper-left edge, and a darker lower-right pressure edge. Remove long continuous specular lines, micro-scratches, glossy edge shine, precision-machined symmetry, and green verdigris. Do not add rivets, gems, runes, emblems, corner badges, filigree, chains, wings, claws, scrollwork, or repeated ornamental motifs.

Treat [232,232,792,792) as a 560 by 560 quiet icon-cover zone. Fill it with a nearly flat deep smoke-brown leather recess using only broad, low-frequency hand-painted value variation. Remove dense realistic grain, crack networks, crossing scratches, pores, sharp creases, embossed marks, stitches, rivets, holes, glow, vignette, and any decorative focal point. At full source size this zone must already read as quiet, not merely become quiet after reduction. Keep all border transitions outside it because the live icon will cover this center. The rim must remain legible after the accepted object is reduced to a 128 by 128 texture and displayed from roughly 24 to 52 UI units, including about 39 physical pixels, without competing with the live icon, keybind, count, or cooldown.

Render classic vanilla World of Warcraft 2D hand-painted interface art, not a realistic material render. Use compact illustrated value shapes, slightly imperfect controlled brushwork, restrained edge variation, low-frequency texture, and functional wear that groups cleanly at small sizes. It must not look photorealistic, PBR-rendered, beveled by a modern UI engine, glossy, glassy, plastic, machined, vector-clean, cyber-neon, gothic, demonic, monumental, stone-carved, jewel-encrusted, or like a modern MMO dashboard tile. Do not use a large cast shadow, ambient scene lighting, floor plane, vignette, depth-of-field, or environmental background.

Do not bake any spell icon, item icon, class symbol, hotkey, count, macro name, cooldown sweep, timer, text, number, range-red state, mana-blue state, unusable-gray state, equipped-green state, selected class color, hover glow, active glow, pressed displacement, disabled state, rail, gryphon, consumable pocket, trinket, unit frame, cast bar, swing timer, or DoiteDPS content into this asset. This output contains only the one normal/empty base.

Outside the one slot, use one perfectly flat, uniform, pixel-level exact #00FF00 chroma-key background, including all four canvas edges and all space around the object. Do not use near-green such as #02FA02. The green background must have no gradient, texture, noise, checkerboard, transparency simulation, haze, bloom, floor, shadow, border, or alternate green. Do not allow green spill into the leather or brass, and do not place any green patina inside the object.

Before returning the image, check every item literally: the output file is exactly 1024 by 1024 RGB rather than the reference size; there is exactly one centered square action-slot base; the complete object is reduced and fits inside [192,192,832,832), aiming at [200,200,824,824); the central [232,232,792,792) zone uses broad quiet hand-painted leather with no high-frequency realistic grain or scratch network; the outer rim is compact, narrow, fully intact, darkly oxidized, and illustrated rather than glossy or PBR; the upper-left warm light and lower-right dark pressure are short and restrained; no dynamic UI content or neighboring component is present; no modern, gothic, stone, jewel, neon, glass, machined, or photorealistic language appears; and every background pixel outside the object is the same exact #00FF00.
```

## 修复执行正文 — `AB.SLOT.BASE.V1.r2`

以下为 attempt 2 完整审查后、同一授权边界内的自包含重新生成正文。仍只使用
已授权 Character V3 作为 Image 1；两个失败候选只提供文字化负面证据，不作为
图片输入。执行前必须先提交本版本。

```text
Create one production bitmap asset for Azeroth Expedition UI, component AB.SLOT.BASE.V1.r2: exactly one reusable normal/empty base for one ordinary pfUI action button. This is a fresh regeneration from the locked visual authority. It is one small, understated square border and shallow empty recess that will sit behind a live spell or item icon. It is not an inventory icon, not a complete action bar, not a rail, not a state atlas, not a presentation board, and not a mock game screenshot.

Image 1 is the locked Character V3 visual authority, but for this action-slot asset inherit only its palette relationship and directional value logic: deep walnut and smoke brown, a very small amount of muted dark brass, low saturation, short warm emphasis from the upper left, darker pressure toward the lower right, and a handmade vanilla-era mood. Image 1's rendering fidelity is explicitly not authoritative here. Do not copy its realistic leather grain, micro-scratches, material sharpness, continuous metal highlights, thick panel frame, equipment-slot construction, purple glow, character, icons, paper, wood panels, text, numbers, tabs, buttons, layout, proportions, or 1254 canvas. Treat Image 1 like a palette swatch, not a texture sample. The final action-slot must be much simpler, lighter, flatter, coarser, and quieter than any panel or equipment slot visible in Image 1.

Create a brand-new exact 1024 by 1024 RGB canvas. Do not preserve or return Image 1's 1254 by 1254 dimensions. Place exactly one front-facing square action-slot base at the exact canvas center with no perspective, camera depth, or tilt. The object must occupy only about 60 to 61 percent of the canvas width and height: aim for the right-and-bottom-exclusive outer silhouette [200,200,824,824), about 624 by 624 pixels. Leave at least about 19 percent of the canvas as clean green margin on every side. All visible antialiasing, wear, paint, and compact contact pixels must stay inside [192,192,832,832). A normalized silhouette near [146,133,882,876] is a known failure because it occupies about 72 percent of the canvas; do not repeat it. Make the whole object visibly smaller, do not crop it, and do not fill the canvas.

Design the asset as if a classic World of Warcraft interface artist painted the final sprite directly at 64 by 64 or 128 by 128 pixels, then enlarged it cleanly for review without inventing finer detail. Use broad, matte, low-resolution painted value clusters and a few controlled irregular brush decisions. At 1024 review size, do not create hairline highlights, pores, realistic fibers, dense grain, cracks, micro-scratches, noise, or any texture feature that would disappear at 128 by 128. Avoid smooth PBR gradients, ray-traced material response, embossed depth, polished edges, precision-machined symmetry, and modern engine bevels. This must look like practical old game UI sprite art, not a premium rendered object and not a realistic photograph of leather and metal. Keep slightly imperfect hand-painted edges, but do not make them vector-clean or cartoon-flat.

From outside to inside, use only four restrained readable zones: a compact dark-brown contact edge contained inside the silhouette; a narrow deep-walnut backing; one single broken muted-ochre dark-brass lip; and a shallow nearly flat smoke-brown recess. The entire border from outer silhouette to quiet center must fit within the approximately 32-pixel band between [200,200,824,824) and [232,232,792,792). The brass lip should behave like roughly one or two texels in the final 128 by 128 sprite, with only two or three short ochre value accents near the upper-left side. It must not trace the entire perimeter with a bright line. Do not make a second inner metal line, a frame-within-a-frame, a thick leather picture frame, a jewelry border, or a full metal plate. Use brown-black painted oxidation rather than shine. Keep the corners square, compact, slightly hand-cut, and softly clipped without protruding ornaments. Do not add rivets, gems, runes, emblems, badges, filigree, chains, wings, claws, scrollwork, stitches, or repeated motifs.

Treat [232,232,792,792) as a strict 560 by 560 quiet icon-cover zone. It must be an intentionally blank-looking, nearly flat deep smoke-brown recess made from only two or three broad low-contrast painted value masses. Do not fill it with a leather texture. No grain network, scratches, pores, cracks, creases, embossing, symbol, seam, hole, glow, vignette, edge line, or focal detail may appear there. The live icon will cover this zone. The empty base should therefore feel visually incomplete by itself and become correct only when a dynamic icon is placed over it. At the confirmed main-bar display size of about 39 physical pixels, the border must remain a subtle two-to-four-pixel support and must not compete with the icon, keybind, count, or cooldown.

Do not bake any spell icon, item icon, class symbol, hotkey, count, macro name, cooldown sweep, timer, text, number, range-red state, mana-blue state, unusable-gray state, equipped-green state, selected class color, hover glow, active glow, pressed displacement, disabled state, rail, gryphon, consumable pocket, trinket, unit frame, cast bar, swing timer, or DoiteDPS content into this asset. This output contains only the one normal/empty base.

Outside the one slot, use one perfectly flat, uniform, pixel-level exact #00FF00 chroma-key background across all four edges and all surrounding space. Do not use near-green values such as #03F903, #02FA02, or #02F902. The green background must have no gradient, texture, noise, checkerboard, transparency simulation, haze, bloom, floor, shadow, border, or alternate green. Do not allow green spill into the painted object and do not place green patina inside it.

Before returning the image, inspect it literally at both full size and imagined 128 by 128 size: the file is exactly 1024 by 1024 RGB; there is exactly one centered front-facing square base; the complete silhouette occupies only 60 to 61 percent of the canvas and fits inside [192,192,832,832), aiming at [200,200,824,824); the strict [232,232,792,792) center is nearly flat and blank; the complete border is only about 32 source pixels per side; there is one broken muted painted brass lip rather than continuous bright double bevels; all texture decisions are coarse vanilla-era sprite brush shapes rather than realistic micro-material; no dynamic content or neighboring component is present; no PBR, glossy, machined, gothic, stone, jewel, neon, glass, photorealistic, or modern-dashboard language appears; and every background pixel outside the object is the same exact #00FF00.
```

## 修复执行正文 — `AB.SLOT.BASE.V1.r3`

以下为 attempt 3 完整审查后、同一授权边界内的自包含重新生成正文。仍只使用
已授权 Character V3 作为 Image 1；三个失败候选只提供文字化审查证据，不作为
图片输入。执行前必须先提交本版本。

```text
Create one production bitmap asset for Azeroth Expedition UI, component AB.SLOT.BASE.V1.r3: exactly one reusable normal/empty base for one ordinary pfUI action button. This is a fresh regeneration from the locked visual authority, not an edit. It is one compact, understated square action-slot border with a shallow empty center that will sit behind a live spell or item icon. It is not an inventory icon, not a complete action bar, not a rail, not a state atlas, not a presentation board, and not a mock game screenshot.

Image 1 is the locked Character V3 visual authority only for the palette relationship and directional value logic: deep walnut, smoke brown, a restrained amount of muted dark brass, low saturation, short warm emphasis near the upper left, darker pressure toward the lower right, handmade age, and vanilla-era mood. Do not inherit Image 1's realistic rendering fidelity, leather grain, micro-scratches, polished metal, continuous highlights, thick panel frame, equipment-slot construction, purple glow, character, icons, paper, wood panels, text, numbers, tabs, buttons, layout, proportions, or 1254 canvas. Treat Image 1 as a palette swatch, never as a texture sample. The action-slot must be visually much lighter and simpler than the panel.

Use the already-established low-resolution art direction described here: construct the object from broad matte painted value clusters, coarse controlled brush shapes, and slightly irregular hand-cut edges, as though the final sprite were authored directly at 64 by 64 or 128 by 128 pixels. Keep this practical old-game sprite character. Do not regress to photorealistic leather, fine pores, realistic fibers, dense grain, scratches, cracks, smooth PBR shading, glossy highlights, precision-machined symmetry, embossed depth, vector-clean geometry, or modern engine bevels. At 1024 review size, no material mark should be finer than a shape that remains readable at 128 by 128. Use only a few large low-frequency value masses per material.

Create a brand-new exact 1024 by 1024 RGB canvas. Place exactly one front-facing square action-slot base at the exact center with no perspective, camera depth, or tilt. The complete visible silhouette must be truly square: equal width and height within one percent, not a portrait rectangle. Aim at the right-and-bottom-exclusive outer box [200,200,824,824), exactly about 624 by 624 pixels, with equal green margins on all four sides. Keep every visible antialiasing, paint, wear, and compact contact pixel inside [192,192,832,832). A normalized visible box near [209,185,815,813] is close in width but is a known failure because its top is too high and its height exceeds its width by about four percent. Move the object down to exact center, make it square, preserve the approximately 60 to 61 percent canvas occupancy, and do not enlarge or crop it.

The decisive repair is the border proportion. The strict quiet icon-cover zone [232,232,792,792) is 560 by 560 pixels and must remain entirely inside the shallow center without any border, highlight, material transition, or hard shadow entering it. Relative to the approximately 624-pixel outer square, that center occupies about 90 percent of the object's width and height. Therefore the complete rim from the outer silhouette to the quiet center is only about 32 source pixels, or about five percent of the object's width, on every side. Do not make a 60-to-80-pixel rim, a broad segmented outer leather belt, or a center that occupies only about 80 percent of the object.

Fit all physical transitions inside that narrow 32-pixel band. From outside to inside use: a three-to-four-pixel dark contact edge contained within the silhouette; roughly twelve-to-fourteen pixels of deep-walnut backing; one single six-to-eight-pixel broken muted-ochre dark-brass lip; and a short six-to-eight-pixel dark inner pressure step. These are approximate painted widths, but their combined visible thickness must never exceed the 32-pixel band. The brass must read as roughly one texel at the final 128 by 128 size. Use only two or three short, dim ochre dabs near the upper-left corner and upper edge; do not trace the full perimeter with a bright line. Do not add a second metal line, double bevel, frame-within-a-frame, thick picture frame, jewelry border, full metal plate, rivets, gems, runes, emblems, badges, filigree, chains, wings, claws, scrollwork, stitches, or repeated motifs. Keep corners compact, square, softly clipped, and hand-painted without protruding ornament.

Fill the complete [232,232,792,792) quiet zone with an intentionally blank-looking deep smoke-brown recess. Use only two or three broad matte value masses with very low contrast. Do not place a diagonal lighting sweep or a center vignette across it. Do not add leather texture, grain network, scratches, pores, cracks, creases, embossing, symbols, seams, holes, glow, edge line, highlight, or focal detail. The empty base should feel intentionally incomplete by itself because the live icon covers this area. At the confirmed main-bar size of about 39 physical pixels, only a subtle two-to-four-pixel support should remain visible around the icon, while the icon, keybind, count, and cooldown stay dominant.

Do not bake any spell icon, item icon, class symbol, hotkey, count, macro name, cooldown sweep, timer, text, number, range-red state, mana-blue state, unusable-gray state, equipped-green state, selected class color, hover glow, active glow, pressed displacement, disabled state, rail, gryphon, consumable pocket, trinket, unit frame, cast bar, swing timer, or DoiteDPS content into this asset. This output contains only the one normal/empty base.

Outside the one slot, use one perfectly flat, uniform, pixel-level exact #00FF00 chroma-key background across all four edges and all surrounding space. Do not use near-green values such as #03FA04, #03F903, #02FA02, or #02F902. The green background must have no gradient, texture, noise, checkerboard, transparency simulation, haze, bloom, floor, shadow, border, or alternate green. Do not allow green spill into the painted object and do not place green patina inside it.

Before returning the image, inspect it literally at full size and imagined 128 by 128 size: the file is exactly 1024 by 1024 RGB; there is exactly one centered front-facing square base; width and height match within one percent; the complete silhouette fits inside [192,192,832,832), aiming at [200,200,824,824); the strict [232,232,792,792) center is fully quiet and occupies about 90 percent of the object; every border transition fits inside the 32-pixel band; the brass is one short broken muted painted lip rather than a continuous bright or double bevel; the coarse low-resolution vanilla sprite treatment is retained; no dynamic content or neighboring component is present; no PBR, glossy, machined, gothic, stone, jewel, neon, glass, photorealistic, or modern-dashboard language appears; and every background pixel outside the object is the same exact #00FF00.
```

## 修复执行正文 — `AB.SLOT.BASE.V1.r4`

以下为 attempt 4 完整审查后、同一授权边界内的最后一份自包含重新生成正文。
仍只使用已授权 Character V3 作为 Image 1；四个失败候选只提供文字化审查证据，
不作为图片输入。执行前必须先提交本版本；这是授权预算内 attempt 5。

```text
Create one production bitmap asset for Azeroth Expedition UI, component AB.SLOT.BASE.V1.r4: exactly one reusable normal/empty base for one ordinary pfUI action button. Generate a fresh flat game-UI sprite from the locked visual authority. The asset is one small, quiet square support behind a live spell or item icon. It is not a framed illustration, not a display object, not an inventory icon, not a complete action bar, not a rail, not a state atlas, not a presentation board, and not a mock game screenshot.

Image 1 is the locked Character V3 visual authority only for a narrow palette relationship: deep walnut, smoke brown, a tiny amount of dark ochre-brown brass, low saturation, short upper-left warmth, lower-right dark pressure, handmade age, and vanilla-era mood. Do not copy Image 1's high material fidelity, realistic leather, micro-scratches, polished metal, bright gold, continuous highlights, thick panel construction, equipment-slot frames, purple glow, character, icons, paper, wood panels, text, numbers, tabs, buttons, layout, proportions, or 1254 canvas. The action-slot must be brown-dominant and much simpler, flatter, darker, lighter in visual weight, and less decorative than any slot or frame in Image 1.

Treat this strictly as a low-resolution albedo-style UI sprite, not a three-dimensional object render. Paint it as if authored directly at 64 by 64 or 128 by 128 pixels using broad matte value clusters, a few coarse controlled brush shapes, and slightly irregular hand-cut edges. Do not use PBR material response, smooth bevel shading, ambient occlusion, glossy reflection, photographic leather, fibers, pores, dense grain, scratches, cracks, embossed depth, precision-machined symmetry, vector-clean lines, ray-traced lighting, or product-shot polish. No detail may exist merely because the review canvas is large. Every painted decision must remain simple and legible when reduced to 128 by 128.

Create a brand-new exact 1024 by 1024 RGB canvas. Put exactly one front-facing square tile at the exact center with no perspective, camera depth, tilt, cast shadow, floor, or scene lighting. The complete visible silhouette must occupy only about 60 to 61 percent of both canvas dimensions and must be square within one percent. Aim for the right-and-bottom-exclusive box [200,200,824,824), about 624 by 624 pixels, with equal dominant green margins on every side. Keep all antialiasing and paint inside [192,192,832,832). Do not create a close-up, hero crop, or a tile occupying roughly 77 percent of the canvas; a normalized box near [119,116,906,909] is a known failure. The green background must visually dominate the canvas around the small centered tile.

Start conceptually from one nearly flat 624-pixel smoke-brown square. Its 560 by 560 central area [232,232,792,792) must look almost uninterrupted and must occupy about 90 percent of the tile width and height. Keep every edge treatment inside the remaining approximately 32 pixels per side. Use at most two visually dominant border bands, not a stack of nested frames: one very narrow dark-walnut backing band and one extremely thin, broken dark ochre-brown brass trace. Any contact edge or inner pressure step must merge quietly into those dark brown shapes and must not read as additional bands. Do not create a thick outer belt, inner picture frame, double bevel, frame-within-a-frame, jewelry border, full metal plate, or broad recessed wall.

Brown must dominate the border. The brass trace may occupy only a small minority of the rim and less than roughly fifteen percent of the full perimeter. Keep it in dark brown-ochre values comparable to #4A3820 through #6A522D, with at most one tiny muted accent no brighter than about #8A6A35 near the upper-left. These colors are descriptive targets, not text to draw. Never use saturated yellow, bright gold, orange-gold, a luminous top edge, a full glowing outline, or metal corner blocks. The brass must not form a complete rectangle. Do not add rivets, gems, runes, emblems, badges, filigree, chains, wings, claws, scrollwork, stitches, segmented armor plates, or repeated motifs. Corners remain compact, square, softly clipped, and understated.

Fill all of [232,232,792,792) with a deliberately blank-looking deep smoke-brown recess made from only two or three broad matte values. Keep contrast very low and do not place a diagonal light sweep, vignette, radial gradient, hard inner shadow, border line, or highlight inside it. Do not add leather texture, grain, scratches, pores, cracks, creases, embossing, symbol, seam, hole, glow, or focal detail. The empty base is supposed to look incomplete alone because the live icon covers it. At about 39 physical pixels, only a subtle two-to-four-pixel dark-brown support with a rare dim ochre fleck should remain visible around the icon; the icon, keybind, count, and cooldown must dominate.

Do not bake any spell icon, item icon, class symbol, hotkey, count, macro name, cooldown sweep, timer, text, number, range-red state, mana-blue state, unusable-gray state, equipped-green state, selected class color, hover glow, active glow, pressed displacement, disabled state, rail, gryphon, consumable pocket, trinket, unit frame, cast bar, swing timer, or DoiteDPS content into this asset. This output contains only the one normal/empty base.

Outside the one tile, use one perfectly flat, uniform, pixel-level exact #00FF00 chroma-key background across all four edges and all surrounding space. Do not use near-green values such as #03FA08, #03FA04, #03F903, #02FA02, or #02F902. The green background must have no gradient, texture, noise, checkerboard, transparency simulation, haze, bloom, shadow, border, or alternate green. Do not allow green spill into the painted tile and do not place green patina inside it.

Before returning the image, inspect it literally at full size and imagined 128 by 128 size: the file is exactly 1024 by 1024 RGB; exactly one front-facing square base is centered; it occupies only 60 to 61 percent of the canvas and fits inside [192,192,832,832), aiming at [200,200,824,824); the [232,232,792,792) center occupies about 90 percent of the tile and is uninterrupted, blank-looking, and low contrast; the complete edge treatment stays inside 32 pixels per side; there are at most two visible border bands; brown dominates; brass is dark, broken, rare, and never yellow or continuous; the coarse matte vanilla sprite language survives; no dynamic content or neighboring component appears; no PBR, glossy, machined, gothic, stone, jewel, neon, glass, photorealistic, or modern-dashboard language appears; and every background pixel outside the tile is the same exact #00FF00.
```

## 执行记录

- 日期：`2026-08-08`
- 会话／结果 ID：fixed child session
  `019fe08a-b8e8-7db1-a286-b507bc74acd7`；provider cache result
  `ig_0628ea921d87290a016a76ec4138488191be112946bf47f1e7.png`
- 实际输入绝对路径与职责：attempt 5 仍只上传
  `D:\Git\azeroth-expedition-ui-overhaul\assets\locked\character\角色属性面板_香草同构收敛_风格确认_v3.png`，
  只承担正文声明的材料职责
- imagegen 报告的 revised prompt：未另行报告；child 打印的完整 `user` 正文
  `6695` 字符，UTF-8 SHA-256
  `cda4edaf9a8e8f2ea63f4ad47e30554e26425d1f9db8c815fe2afab4515267d9`，
  无截断、无 wrapper 递归
- 输出尺寸／模式／SHA-256：`1254×1254 RGB PNG`／
  `0a0cae74fbb48bf233037425b0b58e080e5ea322aa677361de1925a6001011b8`；
  provider cache、child copy 与本地 raw 三者一致
- Alpha／残色：raw 无 Alpha；边界自动采样为 `#03FA05` 而非精确
  `#00FF00`。首次 threshold `12` 副本仍有 `2` 个极低 Alpha 边缘像素使 bbox
  触边；不调用 provider，仅把同一确定性色键的 transparent threshold 收紧为
  `20` 后重跑。最终仅供审查使用固定
  `remove_chroma_key.py --auto-key border --soft-matte --transparent-threshold 20
  --opaque-threshold 96 --spill-cleanup` 的同算法参数族；透明 `796469`、partial
  `3510`、opaque `772537`，可见 bbox `[181,176,1065,1054]`，强绿色残留 `0`
- 实际生图次数：`5/5`；预算已耗尽，不得 attempt 6
- 流程错误次数：`2`
- 循环终态：`candidate-reviewed / P3`

## 审查记录

- 语义／物理：通过。恰好一个正面、居中、完整的方形动作槽基底；无技能、文字、
  状态、Rail 或相邻组件。物件内外和凹面关系成立。
- 透视／图层：通过。正交前视、共享左上光；候选只承担 icon 下方 base。动态
  icon、cooldown、highlight、active、equipped、range、OOM 与按下均由预演层覆盖。
- 美术一致性：通过。深褐旧皮／胡桃色为主，暗黄铜只以顶边、左边、角部和底边
  的断续短段出现；无连续亮金环、PBR 双倒角或现代仪表板质感。低频块面、左上
  暖光与右下暗压和 Character V3 的材料 DNA 一致，同时在动作槽尺度保持轻量。
- 对象／状态合同：通过。单物件／单 normal base、无假 disabled cell；完整 rim
  已收为细窄暗木／旧皮边带，中央保持安静并给动态图标让位。canonical 安静区
  `[232,232,792,792)` 的 luma `stddev 2.9659`、HF mean `0.5018`、extrema
  `8–154`，未见高对比纹章、铆钉或烘焙状态。
- 装配／尺寸：provider raw 仍为 `1254²`，其透明审查 bbox
  `[181,176,1065,1054]`，按 `1024²` 归一为 `[148,144,870,861]`；保留为未经
  隐藏的 provider provenance。只做 crop／Alpha／等比缩放／居中的 exact
  canonical review 为 `1024² RGBA`、bbox `[200,202,824,822]`，长宽差小于
  `1%` 且完整落入安全盒；该副本和 `128²` master 均只用于复审，不是
  source/runtime。
- 真实排版：脚本 `tools/review_action_slot_base_candidate_v1.py`（SHA-256
  `52425da8290724793a683d75efea926713b98d7abcf8a87797198b3ed0b43d63`）与 spec
  `9fd73383…798f4`；候选审查报告 `6b0e4799…c037`。全屏 `1920×1080` 与五种
  exact provider 场景均已目视；`20／26／30／39／42 px` 外框中图标、键位、
  cooldown 与状态可放置；空槽安静、带图标时边框退为支持层，candidate rim
  没有扩大 hit rect。周边 V3 仍是明确非权威方向模拟。
- 实际展示区域：生成合同 `1c8432fb…3139d`；报告 `f461808e…a0c7d`，
  `1×1／12×1／6×2／4×3／1×12` 共 `5/5 pass`、violations `0`；Frame、full UV、
  动态图标安全区和 hit rect 均一致。
- 技术像素：provider raw 的非精确尺寸与近绿色背景均保留在 provenance；只供
  审查的确定性 canonical 输出为精确 `1024² RGB`，背景透明区
  `661720/661720` 为 `#00FF00`，RGBA 版 strong green spill `0`。canonical
  SHA 分别为 `f42d0134…2c81` 与 `6d4a4d16…7dc0`；归一过程不重绘、不锐化、
  不改变可见构图。
- 审查顺序：Prompt／传输 → scope／identity → physical logic → perspective／
  layering → art consistency → component／state → crop／assembly → technical，
  全部通过；通过后立即停止有界循环。
- 结论：`candidate-reviewed / P3`；exact canonical 候选可交用户复审，但在用户
  明确接受前不得创建 source、manifest、runtime 或接管路由。
- 用户结论与日期：V3 `confirmed 2026-08-08`；生产正文与最多五次实际生成／
  修复 `authorized 2026-08-08`；指定锁定图的外部 ImageGen 上传
  `authorized 2026-08-08`
- 下一门禁：用户复审 SHA-256
  `6d4a4d16e9a9c11248f0c63636e916e462d5d64f548335f26252e19e0b787dc0`
  的 exact canonical attempt 5。接受后才晋级 source／export；拒绝则记录结论并
  停止，因为 `5/5` 已耗尽，除非用户另行明确授权新预算，否则不得 attempt 6

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `SIM-V1` | deterministic PNG `fd5e1537…18d0`；display `9/9` | `user-rejected 2026-08-08` | 动作条上移；玩家／目标靠近并同基线 |
| `SIM-V2` | PNG `943d6fac…e5d0`；display `9/9`；layout `20/20` | `user-revision-requested 2026-08-08` | 加入施法、攻击计时和 DoiteDPS；重排 Aura |
| `SIM-V3` | PNG `b2761b67…c87e8`；新增 display `9/9`；layout `46/46`；V2 回归一致 | `user-confirmed 2026-08-08` | 不改变已确认布局；进入首批组件 Prompt 门禁 |
| `AB.SLOT.BASE.V1` | child `019fe064…675c`；raw `518f8cf7…41e87`；display `5/5 pass` | `internal-rejected 1/5` | 改为香草二维手绘低频材质；去连续 PBR 倒角和写实皮纹；精确 `1024²`、缩小约 `15%`、纯 `#00FF00` |
| `AB.SLOT.BASE.V1.r1` | child `019fe073…ed1f`；raw `82542910…739d1`；display `5/5 pass` | `internal-rejected 2/5` | 参考图只继承配色关系；按原生 `64／128 px` sprite 粗粒度重绘；物件仅占 Canvas `60–61%` |
| `AB.SLOT.BASE.V1.r2` | child `019fe07c…d91f`；raw `989bb567…3c08`；display `5/5 pass` | `internal-rejected 3/5` | 保持已通过的粗粒度手绘与占屏；完整 rim 从约 `10%` 收至 `5%`，安静区占物件约 `90%`，外轮廓严格正方居中 |
| `AB.SLOT.BASE.V1.r3` | child `019fe085…640e`；raw `bef74f6f…e0027`；display `5/5 pass` | `internal-rejected 4/5` | 保持粗粒度中心；改用褐色主导的扁平 sprite 与最多两条边带，黄铜少于周长 `15%` 且不得亮黄；恢复 `60–61%` 占屏 |
| `AB.SLOT.BASE.V1.r4` | child `019fe08a…acd7`；raw `0a0cae74…011b8`；canonical RGBA `6d4a4d16…7dc0`；display `5/5 pass` | `candidate-reviewed 5/5 / P3` | 用户复审 exact canonical；接受后晋级 source，拒绝则停止且不得 attempt 6 |
