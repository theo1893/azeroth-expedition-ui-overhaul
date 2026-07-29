# Chat 复制纸页 V1.2

## 元数据

- 模块：Chat
- 组件 ID：`CHAT.COPY.TOGGLE`、`CHAT.COPY.SURFACE`、`CHAT.COPY.TEXT`
- 版本：`CHAT.COPY.V1.2`
- 子状态：`prompt-authorized`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 操作：A 为确定性派生；B1／B2 为 `edit`
- 功能来源：
  [`addon/pfUI/modules/chatcopy.lua`](../../../../addon/pfUI/modules/chatcopy.lua)
- 锁定视觉基准：
  - [`聊天框视觉基准_v1.png`](../../../../assets/locked/chat/聊天框视觉基准_v1.png)
    — 战地旧书身份、香草 HUD 中的紧凑比例和低干扰控件尺度
  - [`聊天框独立艺术资源_v3.png`](../../../../assets/locked/chat/聊天框独立艺术资源_v3.png)
    — 二维手绘页边、纸张厚度和材料精度；其完整框架结构明确排除
- 基准 Prompt provenance：
  - [`ART_BASELINE.md`](../ART_BASELINE.md)
  - [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md)
  - Git `73da6c5` 中
    `prompts/chat/聊天框模块化资源_执行提示词_v3.md`
- 确定性派生依据：
  - [`ChatBookFrame_Master_v3.png`](../../../../assets/source/chat/v3/ChatBookFrame_Master_v3.png)
    — 只在本地提取已接受的安静纸面，确定性生成 A；它只承担已部署纸色、
    笔触与磨损连续性，不高于两张锁定图及其 Prompt
  - A 通过内部审查后的确定性候选
    — 只在本地构造 B1／B2 的双页夹结构 scaffold，保证三个对象共享纸色
- 已授权的外部 ImageGen 实际输入：
  - A：不调用 ImageGen，也不上传图片
  - B1：只上传
    `generated/chat/copy/v1_2/inputs/CHAT.COPY.TOGGLE.CLOSED.SCAFFOLD.V1_2.png`
  - B2：上传内部通过并经过确定性 mask 的
    `generated/chat/copy/v1_2/b1/CHAT.COPY.TOGGLE.CLOSED.V1_2.candidate.png`
    与
    `generated/chat/copy/v1_2/inputs/CHAT.COPY.TOGGLE.OPEN.SCAFFOLD.V1_2.png`
  - 两张完整锁定图与两张完整 V3 source 均不直接上传；它们继续通过本文件
    和基线 Prompt 提供项目权威，但不得再诱导执行器复制完整 UI 结构
- V1.2 raw：无；已授权、尚未执行
- V1.2 透明候选：无
- V1.2 重组预演：无
- V1.1 失败 raw：继续只保留在被忽略的
  `generated/chat/copy/v1_1/`，只作反例，不进入 V1.2 输入
- 最终 source：无；必须经用户明确接受后才能进入
  `assets/source/chat/copy/`

## 美术基准继承

### 权威顺序

1. 两张 Chat 锁定图，以及 Chat 主／子模块 Prompt 和历史 V3 provenance。
2. [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
3. [`SUBMODULES.md`](../SUBMODULES.md) 的真实 pfUI 对象、状态、几何和禁止
   烘焙合同。
4. 已接受 V3 source 只承担已部署纸色、笔触与磨损连续性。
5. V1／V1.1 失败候选只提供反例，不进入 V1.2 的任何编辑输入。

### 必须继承的视觉 DNA

- 组件必须像同一本长期携带、反复修补的战地旧书上的附加抄录纸与页夹。
- 纸张第一、深胡桃旧皮革第二、黄铜最多只是一枚暗哑连接点；使用
  `#B8955C` 旧书页、`#D2B77E` 克制高光、`#76512E` 页影、
  `#28180E` 深皮革、`#80602D` 暗哑黄铜和 `#24170F` 墨褐结构线。
- 左上暖光、低饱和暖赭色域、略不规则二维手绘边缘、非镜像磨损和清楚的
  纸页厚度必须与当前 V3 聊天书一致。
- 阅读区域连续、安静、低对比；高频磨损只允许出现在抄录纸外缘和页夹。

### 本批组件级转译

- `CHAT.COPY.SURFACE` 是覆盖正文区域的连续抄录纸面。V1.2 不再让
  ImageGen 决定它的外轮廓：直接从已接受 V3 主框提取安静纸面并确定性
  缩放到严格 `380:248` 的三倍源尺寸。它保持完整消息容量，不再增加第二
  纸叶、毛边或任何可能跨越九宫格 stretch zone 的独特细节。
- `CHAT.COPY.TOGGLE` 只生成关闭、开启两个持久物理状态。关闭时两张短纸叶
  收拢；开启时上层纸叶在同一外接框内稍微扇开。悬停继续由 pfUI／adapter
  对同一物理纹理调整 Alpha。两状态的画布、外接框、下层纸叶与夹具由
  确定性 scaffold／mask 锁定；ImageGen 只负责纸叶与皮夹的手绘表面。
- `CHAT.COPY.TEXT` 始终由真实 `pfChatCopyBoxN` 绘制。本批不改变正文或
  复制文字的字体、字号、颜色、选择和光标。

### 明确不继承

- 不继承游戏基准中其他模块的动作条、单位框、任务追踪或侧边按钮。
- 不继承独立艺术资源的龙饰、尖顶、顶部四槽、木柱、宝石或完整金属框。
- 不复刻 V3 主框、Tab、输入纸带、蜡封、底栏字段或动态文字。
- 不生成现代“双文档”图标、方形按钮牌、滚动条、关闭按钮、搜索框、
  Tooltip 或 ChatMenu 外壳。

### 冲突审计

- V1 的授权正文已经明确排除完整框架，但同时上传四张完整 UI 图；ImageGen
  的 revised prompt 仍把 A 改成第二聊天框，把 B 改成现代文档按钮。
  V1.1 的裁决是保留完整书本的书面视觉权威，却只向外部模型提供每次调用
  唯一目标对象的隔离编辑引导。
- V1.1 的 A 虽然通过单纸身份审查，但固定执行器的 revised prompt 删除了
  精确比例、固定边和 stretch-zone 条款，并主动增加底边撕裂。V1.2 不再
  试图用更强文字要求模型遵守像素几何，而是把 A 的全部几何从 ImageGen
  所有权中移除；V1.1 raw 不作为 edit 输入。
- V1.1 同时把 `24px` 九宫格固定边后的中心误写为 `1080 × 696`。正确关系
  是九宫格 stretch center 为 `1092 × 696`；`1080 × 696` 是另一个合同，
  即 `30px` 左右文字内边距和 `24px` 上下文字内边距后的文本安全区。
- pfUI 的真实 `pfChatCopyButton` 只有关闭／开启两种持久纹理，并用
  `OnEnter`／`OnLeave` 调整 Alpha；当前实现没有独立 pressed 或 disabled
  纹理。V1 的七状态表高于真实 provider 所有权。V1.2 保持两个物理 source，
  悬停由 runtime 派生，不生产不存在的状态。
- `pfChatCopyButton` 原始 `16 × 16` 位置与第四枚 Tab 冲突。V1.2 仍保留同一
  Button 和左右键逻辑，只把视觉放在书本右侧页边，不覆盖 Tab 或正文。
- pfUI 原始 `95%` 黑色复制覆盖层与连续纸面冲突；V1.2 只替换其背景 Region，
  不改变历史缓存、滚动、选择、Escape 或消息转发。
- 用户已延后 `CHAT.TEXT` 可读性改造；V1.2 不借本批修改正文字体或频道色。

## 组件合同

### 真实对象与功能

- 一个全局 `pfChatCopyButton`：
  - 左键切换所有非战斗日志复制纸面的显示状态。
  - 右键继续显示／隐藏原生 `ChatMenu`。
  - 持久状态只有 `off` 与 `on`；`hover` 是同一纹理的 runtime Alpha。
- 每个非战斗日志 `ChatFrameN`：
  - 一个 `ChatFrameScrollN`，共享 A 的九宫格物理资产。
  - 一个 `pfChatCopyBoxN`，继续作为可选择多行 EditBox。
- 保留 100 条历史、颜色码、滚动、选择、Escape 两段式退出和
  `ChatFrameN.AddMessage` 转发。

### Runtime 几何与状态

- `CHAT.COPY.TOGGLE`：
  - 两个物理状态：`off`、`on`。
  - 视觉范围统一为 `22 × 26 UI px`；锚到 `pfChatLeft` 右侧页边
    `RIGHT → RIGHT, x=-14, y=-8`。
  - 命中区向四边各扩展 `3px`，最终 `28 × 32 UI px`。
  - normal／hover 共用相同 UV；hover 只改变 Alpha，不改变纹理、Point、
    Width、Height 或外接轮廓。
  - 当前 provider 不拥有独立 pressed／disabled 纹理，V1.2 不生成。
- `CHAT.COPY.SURFACE`：
  - 与所属 `ChatFrameN` 同尺寸；最小书框下为 `380 × 248 UI px`。
  - 九宫格固定边 `8px`；中间边段与中心可水平、垂直拉伸。
  - `pfChatCopyBoxN` 使用左右 `10px`、上下 `8px` 安全内边距。
  - 隐藏状态不占用额外可见空间。
- 维护约束：只在首次装配和已知布局事件后按需恢复 Anchor；周期维护不得
  持续改写 Parent、Point、Width 或 Height。

### 确定性本地输入

- A 确定性候选：
  1. 验证 `ChatBookFrame_Master_v3.png` 为 `1608 × 978 RGBA` 且
     SHA-256 为
     `f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057`。
  2. 取半开区间 `(270,130)–(1338,827)`，得到 `1068 × 697` 的已接受
     安静纸面；相较 V1.1 向上平移 `30px`，明确排除其底边撕裂。该区域
     不含封皮、Tab、金属框、页夹或动态内容。
  3. Lanczos 缩放为精确 `1140 × 744 RGBA`，对应最小 runtime
     `380 × 248` 的三倍。Alpha 全部保持 `255`；不添加毛边、第二纸叶、
     描线、阴影、色键或生成像素。
  4. 九宫格 source 固定边为四边各 `24px`，切线为
     `x=24/1116`、`y=24/720`；其 stretch center 是
     `1092 × 696`。复制文字安全区另按 source 左右各 `30px`、上下各
     `24px` 检查，得到 `1080 × 696`。
  5. 写入
     `generated/chat/copy/v1_2/a/CHAT.COPY.SURFACE.V1_2.candidate.png`；
     在通过原尺寸、`380 × 248`，以及 `540 × 420` 书框所对应的
     `480 × 348` 正文尺寸拉伸预演前，
     不创建 tracked source。
- B1／B2 结构 scaffold：
  1. 只有 A 通过范围、对象身份与纸面安全区审查后才创建。
  2. 在 `1024 × 1024` 纯 `#00FF00` 画布的
     `(336,304)–(688,720)` 内构造一个 `352 × 416`、比例精确服从
     `22:26` 的共同外接框；它同时是后续确定性 Alpha mask。
  3. closed scaffold 包含两张紧密重叠的短纸叶与一个横跨上缘的短深皮革
     夹；open scaffold 只把上层纸叶的下缘与右缘小幅扇开。两者的下层纸叶、
     夹具、共同锚点和外接框逐像素相同。
  4. 两张纸叶只使用 A 候选的纸面采样；深皮革只使用 V3 已接受色域。
     scaffold 定义结构和材料分区，不是最终 source。
- B2 编辑输入：使用内部通过并经 closed scaffold mask 锁定的 B1 透明
  candidate 作为 Image 1，open scaffold 作为 Image 2。ImageGen 只重绘
  上层纸叶的开合表面；确定性装配继续保留 B1 的下层纸叶与夹具，并应用
  open scaffold 的外轮廓 mask。

### 输出、裁切与验收

- A：只有一张精确 `1140 × 744 RGBA` 的确定性矩形候选；不产生 A raw，
  不经过色键或 Alpha 清理。九宫格固定边与文字安全区按上节的两套独立
  切线检查，不再混用。
- B1／B2 raw：各自一张 `1024 × 1024` 单物件图；共同外接框、锚点、光源
  和缩放必须相同。不得合成多状态 contact sheet 交给 ImageGen。
- B1／B2 调用输出纯 `#00FF00` 平整背景；raw 必须先通过对象身份、物理
  和美术门禁，再转为真透明并应用对应 scaffold mask。mask 是预先声明的
  几何所有者，不得拿来把错误对象伪装成合格候选。
- A 只允许九宫格；B1／B2 后续确定性合成两个 UV cell，状态切换不改几何。
- 禁止烘焙：聊天消息、玩家名、颜色码、选择高亮、光标、Tab、输入条、
  未读、现代复制图标、状态标签、按钮牌、ChatMenu 和任何完整聊天框结构。
- 验收预演：
  - 在 `440 × 320` 当前 V3 主框中分别重组 off／on；
  - on 预演显示 `380 × 248` 抄录纸和安全区，不烘焙真实聊天内容；
  - A 另以 `380 × 248` 和 `540 × 420` 书框对应的 `480 × 348` 正文尺寸
    检查九宫格 stretch zone，不接受接缝、重复突变或纸纹频率漂移；
  - 以 `22 × 26` 和 `28 × 32` 调试覆盖分别检查视觉与命中区。
- 回退：任何资产、Frame 或状态缺失时 `chatcopy` 继续不加载；不得恢复
  pfUI 黑色覆盖层作为 AEUI 局部替代。

## 最终执行正文

状态：`production`。用户于 `2026-07-29` 明确授权
`CHAT.COPY.V1.2`，并明确允许上传 B1 closed scaffold、通过 mask 的 B1
candidate 与 B2 open scaffold。A 不调用 ImageGen；B1／B2 必须按
A 确定性构建 → 内部门禁 → B1 → 内部门禁／mask → B2 的顺序，把以下英文
正文逐字交给固定执行器。

### A：确定性连续抄录纸面

以下是确定性构建合同，不是 ImageGen Prompt：

```text
Input only assets/source/chat/v3/ChatBookFrame_Master_v3.png at its recorded
SHA-256. Crop the half-open rectangle (270,130)-(1338,827), resize that exact
accepted quiet parchment sample to 1140 by 744 RGBA with Lanczos resampling,
and preserve fully opaque alpha. Add no generated pixels, border, deckle,
second leaf, shadow, outline, stain, text, or control.

Treat source x=24 and x=1116, y=24 and y=720 as the nine-slice cuts. The
nine-slice stretch center is 1092 by 696. Separately, reserve 30 source pixels
at left and right and 24 source pixels at top and bottom for the copy-text
safe area, producing 1080 by 696. Do not conflate those two rectangles.

Write only an ignored candidate under generated/chat/copy/v1_2/a/. Do not
promote it to assets/source, export a runtime TGA, or modify Lua until the
candidate and its real-size stretch previews are explicitly accepted.
```

### B1：关闭状态双页夹编辑

```text
Edit Image 1, the isolated closed two-leaf structure scaffold, into exactly
one production-ready closed transcription page clip for the real
pfChatCopyButton in Turtle WoW 1.18.1. Image 1 is the geometry authority.
Preserve its 1024 by 1024 canvas, one-object scope, vertical 22:26 outer box
at (336,304)-(688,720), common anchor, material regions, and flat green
separation. Paint through the scaffold-owned regions, place nothing outside
that box, and do not turn the object into a square button or toolbar icon.

This object belongs to the same battered Azeroth Expedition battlefield
journal as the accepted V3 chat book. Render a compact 2004-era hand-painted
bitmap with upper-left warm light, low-saturation smoked parchment, broad
readable value groups, slightly crooked hand-cut edges, non-mirrored practical
wear, and no photographic fiber detail. Use two short overlapping parchment
leaves near #B8955C and #D2B77E, restrained separation near #76512E, one small
worn deep-walnut leather clamp near #28180E, and dark structural accents near
#24170F. Paper is primary, leather is secondary, and brass is absent unless a
single pinhead is physically necessary.

The two leaves are closed and overlap closely under the short top clamp. The
clamp must visibly hold both leaves, while two paper edges remain readable.
Keep the lower leaf, upper leaf, and clamp as parts of one connected physical
object. Use no long cord, hanging ornament, detached part, loose symbol, or
one-pixel noise. Use only broad shapes and short highlights that remain
legible when reduced to 22 by 26 UI pixels and when hover changes only Alpha.

Include no duplicate-document pictogram, clipboard, quill, book symbol,
letter, line, arrow, rune, jewel, wax seal, text, label, square plaque,
beveled button frame, continuous metal border, glow, or other UI object.
Reject a modern copy icon, website toolbar button, symmetrical gold badge,
polished brass control, photoreal stationery, machine-perfect folds, and
high-frequency texture.

Return exactly one isolated object on one perfectly flat uniform #00FF00
background. Preserve the 1024 by 1024 canvas. Use no checkerboard, gradient,
floor, vignette, cast shadow on green, cell border, label, or extra object.
```

### B2：开启状态局部编辑

```text
Edit Image 1, the internally reviewed closed transcription page clip, into
its open persistent state for the same real pfChatCopyButton. Image 2 is the
open-state geometry scaffold and is authoritative only for the changed upper
leaf silhouette. This is a local state edit, not a redesign. Preserve exactly
the same 1024 by 1024 canvas, vertical 22:26 outer box at
(336,304)-(688,720), common anchor, lower leaf, top leather clamp, paper
material, palette, brushwork, wear scale, upper-left light, and one-object
scope.

Change only the upper paper leaf. Follow Image 2 to fan its free lower and
right edge outward slightly around the existing top clamp, while keeping it
completely inside the unchanged outer box. The lower leaf and clamp must
remain visually identical to Image 1 and in exactly the same positions. The
clamp must still hold both leaves; no part may detach, lengthen, or move the
shared anchor. The open state must differ through this small physical overlap
change, not through a symbol, color swap, glow, border, decoration, or new
object.

Keep the same compact 2004-era hand-painted bitmap language: low-saturation
smoked parchment, deep-walnut worn leather, broad value groups, restrained
non-mirrored wear, and no photographic fiber detail. The state difference
must remain readable at 22 by 26 UI pixels without introducing one-pixel
noise.

Add no duplicate-document pictogram, clipboard, quill, book symbol, text,
letter, line, arrow, rune, jewel, wax seal, square plaque, button frame,
continuous metal border, glow, label, or extra object.

Return exactly one isolated object on one perfectly flat uniform #00FF00
background. Preserve the 1024 by 1024 canvas and unchanged outer box. Use no
checkerboard, gradient, floor, vignette, cast shadow on green, cell border, or
label.
```

## 执行记录

- 日期：`2026-07-29`；已授权，尚未执行
- 授权 Prompt commit：本次 `prompt-authorized` 提交；生成记录阶段补入
  精确 commit 哈希
- A：待授权版本提交后确定性构建；无 ImageGen 会话
- B1／B2 会话／结果 ID：无
- 实际输入绝对路径与职责：待按本文件合同创建并在执行前记录
- imagegen 报告的 revised prompt：无
- 输出尺寸／模式／SHA-256：无
- Alpha／残色：未检查
- 内部失败重试：无

## 审查记录

- 范围／对象身份：Prompt 预检通过。A 只对应 `ChatFrameScrollN` 背景；
  B1／B2 各自只对应同一个 `pfChatCopyButton` 的持久状态。
- 语义／物理：Prompt 预检通过。B 的两张纸叶由同一上沿皮夹连接；open
  只改变上层纸叶的重叠关系。
- 透视／图层：A 是复制文字下方的连续纸面；B 是书本右侧页边上的独立
  Button。两者不覆盖 Tab 或输入条。
- 美术一致性：两张锁定图与书面 Prompt 继续最高；A 只复用已接受 V3
  纸面，B 的执行正文完整写入左上暖光、低饱和纸／皮革色域、手绘位图、
  非镜像磨损和照片级反模式。
- 对象／状态合同：V1.2 已把 A 的外接框、九宫格切线和 stretch zone
  完全移出 ImageGen 所有权，并区分 `1092 × 696` stretch center 与
  `1080 × 696` text-safe center。B 保持 off／on 两个状态，hover 仍由
  runtime Alpha 派生。
- 装配／尺寸：合同已定义 `380 × 248`、`22 × 26`、`28 × 32` 命中区、
  B 共用外接框和真实层序预演；候选尚未构建。
- 技术像素：待执行。
- 结论：`prompt-authorized / P3`
- 用户结论与日期：`2026-07-29`，明确授权 `CHAT.COPY.V1.2`，并允许上传
  B1 closed scaffold、通过 mask 的 B1 candidate 和 B2 open scaffold
- 下一门禁：先提交本授权版本；随后确定性构建并内审 A。A 通过后才创建并
  上传 B1 closed scaffold；B1 通过对象、物理、美术和 mask 门禁后，才上传
  通过 mask 的 B1 candidate 与 B2 open scaffold 执行 B2。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| V1 | commit `69ada1f`；session `019fae2a…`／`019fae2c…` | `candidate-rejected` | 不上传完整 UI；A 单物件 edit；B 按真实持久状态拆分 |
| V1.1 | commit `8b0a4e3`；A session `019fae4d…`／result `ig_0d80…`；B1／B2 因门禁停止 | `candidate-rejected` | A 必须锁死外接框；四条边的 stretch zone 不得由模型生成独特缺口；降低照片式纤维与中性光漂移 |
| V1.2 | A 改为已接受 V3 纸面的确定性派生；B1／B2 使用分状态 scaffold／mask；用户授权三项外部输入 | `prompt-authorized / P3` | 按 A → B1 → B2 的内部门禁串行执行 |
