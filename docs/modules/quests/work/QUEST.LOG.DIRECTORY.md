# Quest Log 左页目录 QL-B1 V1

## 元数据

- 模块：Quests / Quest Log 左页目录。
- 组件 ID：
  - `QUEST.LOG.REGION.TOGGLE`
  - `QUEST.LOG.LIST.CHECK`
- 版本：`QL-B1 V1`。
- 子状态：`game-validated / user-confirmed`。
- 项目阶段：`P6`（当前活动 runtime 范围）。
- 固定执行器：`imagegen-0-143-0` /
  `@openai/codex@0.143.0`。
- 操作：`deterministic-export / runtime-integration`；ImageGen attempt 1–5
  记录仍见循环表。
- 自动修复预算：最多 `5` 次固定执行器调用，含首次。
- 当前尝试：`5/5`（预算耗尽，无剩余调用）。
- 多执行正文最坏总调用数：`5`。
- 生成授权：`2026-07-30` 明确授权 `QL-B1 V1`；允许每次上传固定 SHA 的
  Image 1／Image 2，允许同一循环前次输出仅在冻结边界内作为 edit 输入，
  最多 `5` 次固定 `imagegen-0-143-0` 调用。
- 用户接受：`2026-07-30` 明确接受 `QL-B1 V1.r3` 的运行时视觉，并允许按
  已声明的确定性逐格裁切、等比缩放、居中与 Alpha 规则进入 `P4/P5`。
- 实机确认：`2026-08-05` 用户确认 Quest 左页的既有 bug 和显示问题均已
  修复；覆盖当前 18 行字体、无描边／零 shadow、类型墨色和活动地区箭头。
  runtime 已隐藏的行末追踪圈与酒红选择书签不属于此次验收范围。
- 锁定视觉基准：
  - Image 1：
    `assets/locked/quests/任务详情面板_视觉基准_v1.png`
    （SHA-256
    `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`）
    ——最高视觉职责：香草时代手绘位图、墨记重量、旧暖色材料关系和公会
    卷宗语义。
- 基准提示词 provenance：
  - `docs/modules/quests/ART_BASELINE.md` ——任务模块的正式公会卷宗身份。
  - `docs/modules/quests/SUBMODULE_ART_BASELINES.md` ——左页目录连续纸面、墨箭头
    与墨圈／墨勾规则。
  - `docs/GLOBAL_ART_BASELINE.md` ——香草时代二维手绘、配色、光照和反模式。
- 次级参考：
  - Image 2：
    `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`
    （SHA-256
    `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`）
    ——只负责最终接触纸面的暖赭色关系、时代和磨损尺度；不得覆盖 Image 1
    的视觉权威，也不得把完整书体画进输出。
- raw：
  - attempt 5 native：
    `generated/quests/QL-B1/v1/attempt-05/raw/QL-B1_V1_r3_native_1254.png`
    （ignored，SHA-256
    `995764a5ab7e18136d3f3153a7184daf5d9da65d153917369c83595205606c5f`）。
  - attempt 5 normalized executor output：
    `generated/quests/QL-B1/v1/attempt-05/raw/QL-B1_V1_r3_normalized_1024.png`
    （ignored，SHA-256
    `73f719d44a55b01d0ef8bc6f2c07343679a10b155d612941ca72d16869527596`）。
- 透明候选：
  `generated/quests/QL-B1/v1/attempt-05/transparent/QL-B1_V1_r3_transparent.png`
  （ignored，SHA-256
  `719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44`）。
- 重组预演：
  - `generated/quests/QL-B1/v1/attempt-05/previews/QL-B1_V1_r3_contact.png`
  - `generated/quests/QL-B1/v1/attempt-05/previews/QL-B1_V1_r3_runtime_preview.png`
- 最终 source：
  `assets/source/quests/ql-b1/QuestLogDirectoryMarks_Master_v1.png`
  （tracked，SHA-256
  `719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44`）。
- source manifest：
  `assets/source/quests/ql-b1/QL-B1_SourceManifest_v1.json`。
- runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogDirectoryMarksV1.tga`
  （`64 × 16 RGBA`，SHA-256
  `e734bbf59da00f7fbc9c75649d33eaf635b5a0c19e1737128dfdce0db58eee8f`）。
- runtime manifest：
  `assets/source/quests/ql-b1/QL-B1_RuntimeManifest_v1.json`。
- exporter：`tools/build_quest_log_directory_marks_v1.py`。
- 真实排版预演：
  `generated/quests/QL-B1/v1/accepted/previews/QL-B1_V1_r3_real_layout_676x464.png`
  （ignored，`676 × 464`／100% runtime，SHA-256
  `c0e5bdffc5ce09872c0da0709a3269245ef424f4dde03335d59ded335dc5fdd5`）。

## 当前批次边界

QL-B 目录状态按运行时语义和物件尺度拆分：

| 批次 | 组件 | 当前状态 |
|---|---|---|
| `QL-B0` | 当前 18 个活动 `QuestLogTitleN` 的创建、排布、文字安全区和状态刷新；`19..23` 只作 provider 兼容 | `2026-08-05` 用户实机确认当前活动布局与字体；`P6` |
| `QL-B1` | 地区展开／收起墨箭头；accepted 圈资产由当前 runtime 隐藏／受限复用 | V1.r3 当前活动范围 `game-validated / P6` |
| `QL-B2` | 当前任务暗酒红窄织物书签及其交互状态 | 等待 QL-B1 视觉尺度确认 |
| `QL-B3` | Elite／Dungeon／Raid／PvP 类型章、Timed 沙漏章、Complete／Failed 蜡封 | 等待 QL-B1 视觉尺度确认 |

`QUEST.LOG.COLLAPSE.ALL` 是独立 Button，必须和 QL-C 的按钮四状态一起生产，
不属于 QL-B1。`QUEST.LOG.LIST.ROW` 是真实选择 Button，但连续纸面上不生成
逐行卡片；普通、悬停、按下、禁用主要由动态 FontString 颜色、顶点色和独立
状态覆盖表达。

## 美术基准继承

### 权威顺序

1. Image 1 与
   `ART_BASELINE.md`／`SUBMODULE_ART_BASELINES.md` 中对应的任务卷宗 Prompt。
2. `docs/GLOBAL_ART_BASELINE.md`。
3. `SUBMODULES.md` 的真实对象、状态、层序、几何与禁止烘焙合同。
4. Image 2 作为已接受书体的受限材料／接触面参考。

### 必须继承的视觉 DNA

- 2004 年前后香草魔兽二维手绘位图，不是现代矢量图标。
- 粗厚、略不规则但轮廓明确的低分辨率友好形态；缩到 `10–12 UI px` 后仍能
  一眼识别。
- 低饱和深乌棕墨色、少量暖黑与旧赭边缘变化；不使用纯白、霓虹、蓝色冷光
  或现代高饱和状态色。
- 正面平视、无透视、无悬浮卡片、无玻璃和无照片级材质。
- 展开／收起必须是同一枚手绘墨箭头的方向变化；未追踪／已追踪必须共享同一
  墨圈，后者只增加清晰墨勾。

### 本批组件级转译

- `REGION.TOGGLE`：地区标题行左侧的小型墨箭头。`collapsed` 向右，
  `expanded` 向下；只是行内状态 Texture，不新增 Button 或命中区。
- `LIST.CHECK`：任务行末端的墨圈。`untracked` 是略淡但仍可见的空圈，
  `tracked` 在完全相同的圈内增加粗短墨勾；不是复选框面板，也不拥有点击。
- 两组符号共享笔触重量、墨色和磨损尺度，但箭头与墨圈不能互相变形或增加
  装饰。

### 明确不继承

- 不继承 Image 1 的完整书体、逐行卡片、长条标题牌、指南针、黄铜外框、
  奖励区、页码、文字和底部大蜡封。
- 不继承 Image 2 的封皮、纸页、书脊、装订、包角或任何背景像素。
- 不在本批输出选择书签、类型章、计时沙漏、完成／失败蜡封、滚动条、
  Collapse All、按钮底座或文字。

### 冲突审计

- Image 1 左页含完整矩形任务卡；组件合同要求连续纸面。裁决：只继承其
  香草手绘重量、暖旧配色与公会卷宗语义，明确排除所有行卡和边框。
- Image 1 有较多黄铜装饰；QL-B1 是纸面墨记。裁决：不用金属，只使用深乌棕
  墨迹，避免小尺寸下变成现代金色 icon。
- Image 2 是高分辨率接受 source，但视觉权威低于锁定图与 Prompt。裁决：
  只取纸面接触时的色温和年代，不复制其书体结构。
- 原生／pfUI 的 `+`、`-` 和复选框容易显得现代。裁决：用方向明确的手绘
  三角墨箭头与开放墨圈，不生成规则方框、印刷字符或文本符号。

## 组件合同

### 真实对象与状态

| 输出格 | 组件／状态 | 运行时来源 | 交互所有权 |
|---:|---|---|---|
| 1 | `REGION.TOGGLE / collapsed` | `QuestLogTitleN` 且 `isHeader`、`isCollapsed` | 整条 `QuestLogTitleN` |
| 2 | `REGION.TOGGLE / expanded` | `QuestLogTitleN` 且 `isHeader`、非 `isCollapsed` | 整条 `QuestLogTitleN` |
| 3 | `LIST.CHECK / untracked` | `QuestLogTitleNCheck`、`not IsQuestWatched(questIndex)` | 无独立点击 |
| 4 | `LIST.CHECK / tracked` | `QuestLogTitleNCheck`、`IsQuestWatched(questIndex)` | 无独立点击 |

Turtle WoW `1.18.1` 的目标调用按香草返回顺序读取
`GetQuestLogTitle(questIndex)` 的 `isHeader`、`isCollapsed`；绝对
`questIndex` 为显示行 ID 加 `FauxScrollFrame_GetOffset`。对象缺失或 API
不可用时隐藏 AEUI 覆盖并保留原生行为。

### 几何与运行时合同

- pfUI 功能底座要求 `QUESTS_DISPLAYED = 23`，原生只有
  `QuestLogTitle1..6`；QL-B0 必须用 `QuestLogTitleButtonTemplate` 创建
  `7..23`，保留每条原生脚本和整行点击。
- QL-A2 左页安全区是 `246 × 324 UI px`。目录候选几何保留 23 行，
  每行 `224 × 15 UI px`、纵向步进 `14px`，总占高 `323px`；右侧
  `22px` 留给 QL-C 滚动条与间距。该几何要先通过 Lua smoke，再等待实机。
- 地区墨箭头显示尺寸：`12 × 12 UI px`。
- 追踪墨圈显示尺寸：`10 × 10 UI px`。
- 已确定性导出为一个 `64 × 16` RGBA TGA：四个
  `16 × 16` cell 依次为 collapsed、expanded、untracked、tracked；对象在
  cell 内居中并保留透明 padding。runtime 采样各格内部的实际 `12px`／
  `10px` content box，使目标对象不会被整个 `16px` cell 再次缩小。
- 原始生成画布：`1024 × 1024`，严格 `2 × 2` 等格，每格
  `512 × 512`。每件物体只能位于本格中心 `224 × 224px` 安全盒内。
- Alpha：生成阶段使用全画布均匀 `#00FF00` 色键；对象不得含绿色。候选阶段
  用固定脚本去色键并验证真 Alpha。禁止棋盘格、纸面或伪透明。
- 裁切：按四格固定坐标拆分；每格只允许确定性透明边界裁切、等比归一化和
  居中，不允许重画、镜像或改变方向。
- 验收预演：四格透明 contact sheet，加一张按真实 `12px`／`10px` 尺寸叠加
  到 QL-A2 左页 23 行样例上的预演。
- 禁止烘焙：任务名、地区名、等级、数量、文字颜色、选择、类型、完成／失败、
  计时、书页、行背景、按钮或滚动条。

## 生产正文完整性预检

- 复杂度：`states / atlas`。
- 结论：`pass`。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | “输出清单”固定四格；“绝对禁止”排除其余 UI | pass |
| 每张输入图的 inherit／ignore 职责与权威冲突 | “输入图职责”分别限定 Image 1／2 | pass |
| 画布、格位、边距、方向、透视、尺度、光照与层序 | `1024²`、四格坐标、`224²` 安全盒、正面无透视 | pass |
| 逐对象形态、材料、边缘、状态与相互关系 | 箭头严格旋转关系；墨圈严格增量关系 | pass |
| 文字／图标安全区、裁切、拉伸、平铺、重复与接缝 | 固定格位、独立物件、不得触边／拉伸／连接 | pass |
| 美术 DNA、具体反模式、Alpha／色键与最终自检 | 香草手绘条款、现代反模式、纯绿色色键和六项自检 | pass |

- 未知但执行必需的值：无。QL-B0 行布局仍需实机验证，但不改变本批四件
  独立小符号的对象、状态或 runtime cell 合同。
- 去冗余结论：保留四格顺序、同源形态、低分辨率可读性和色键要求的必要
  重复；不把历史失败过程、提交号或仓库路径写进创作描述。

## 最终执行正文

使用固定 ImageGen v0.143.0 生成一张可拆分为游戏 UI sprite 的四状态源图。
这不是完整界面概念图，也不是一本书的截图；输出只能包含四枚彼此独立的小型
手绘墨记。

输入图职责：

- Image 1 是最高视觉权威。只继承它所体现的 2004 年前后香草魔兽二维手绘
  位图语言：粗厚而略不规则的轮廓、明确的明暗切面、低饱和暖旧配色、公会
  任务卷宗的沉重年代感，以及缩小后仍清楚的图形重量。忽略并且绝不复制它的
  完整书体、矩形任务卡、长标题牌、指南针、黄铜外框、奖励区、页码、文字和
  大蜡封。
- Image 2 只是已接受任务书页的次级材料参考。只继承暖赭旧纸旁边适用的深
  乌棕墨色、年代和磨损尺度。忽略并且绝不复制封皮、纸页、书脊、装订、包角
  或任何背景结构。Image 2 不得覆盖 Image 1 的视觉权威。

画布与排布：

- 输出恰好一张 `1024 × 1024` 正方形栅格图。
- 严格分成 `2 × 2` 四个逻辑格，每格 `512 × 512`；不要画格线、分隔线、
  标签或边框。
- 左上格 `x=0..511, y=0..511`：地区标题 `collapsed` 墨箭头。
- 右上格 `x=512..1023, y=0..511`：地区标题 `expanded` 墨箭头。
- 左下格 `x=0..511, y=512..1023`：`untracked` 空墨圈。
- 右下格 `x=512..1023, y=512..1023`：`tracked` 墨圈加墨勾。
- 每枚物体必须在本格正中心，全部可见像素只能落在本格中心
  `224 × 224px` 的安全盒内；四周留宽阔、完全干净的色键区。物体不得触碰
  格边、不得跨格、不得彼此连接，四件视觉占用和笔触重量要一致。
- 全画布背景必须是完全均匀、无纹理、无渐变、无阴影、无压缩噪点的纯
  `#00FF00`。物体内部和抗锯齿边缘不得使用任何绿色。不要透明棋盘格，不要
  纸张底色。

四件物体的共同美术：

- 正面平视的二维手绘 UI sprite，无透视、无倾斜、无三维厚度、无投影到
  背景；所有明暗只存在于墨迹自身内部。
- 使用低饱和深乌棕、暖黑和极少量旧赭干笔边缘，像冒险者公会卷宗上反复使用
  的手绘墨记。轮廓粗厚、略有手工误差，但不能毛躁成污点。
- 形态必须为低分辨率友好：未来缩到 `10–12 UI px` 时，方向、空心和勾选
  仍可一眼辨认。不要微型花纹、细线雕刻、复杂裂纹或依赖高分辨率的细节。
- 延续香草魔兽的夸张但实用的图形重量，不做现代扁平矢量、极简线性 icon、
  App checkbox、玻璃拟态、霓虹描边、PBR 金属、照片级墨水、暗黑 3 尖刺
  祭坛或上古卷轴式极简菜单。

逐格结构：

1. 左上 `collapsed`：一枚紧凑的实心手绘三角墨箭头，明确指向右方。允许
   中心有一处很小的暖赭干笔断面来表现旧墨，但不能形成字母、加号、减号、
   菱形徽章或金属箭镞。
2. 右上 `expanded`：必须是左上同一枚箭头严格顺时针旋转九十度后的形态，
   明确指向下方。轮廓面积、笔触粗细、磨损位置和综合色重必须与左上相同；
   不得另画成不同箭头，不得增加第二枚箭头。
3. 左下 `untracked`：一个近圆但略有手绘误差的开放墨圈，线条粗短、闭合
   清楚、内部完全空。它不是方形复选框、按钮底座、印章或硬币。
4. 右下 `tracked`：保留左下完全相同的墨圈，只在圈内增加一笔粗短、方向
   明确的手绘勾。墨勾从左下向右上收笔，不能越出墨圈太多；除这笔勾外，
   圈的大小、位置、磨损和墨色不得变化。

绝对禁止出现任何文字、数字、字母、罗马数字、`+`、`-`、完整书页、皮革、
黄铜、卡片、面板、行背景、按钮、滚动条、书签、类型徽章、沙漏、蜡封、
任务名、发光、外框、格线、水印、说明图例或第五件物体。

输出前逐项自检：画布是否只有四件；四格顺序是否正确；右箭头与下箭头是否
确为同一形态旋转；空圈与勾选圈是否只差一笔墨勾；所有像素是否留在各自
`224 × 224px` 安全盒；背景是否为完全均匀的纯 `#00FF00` 且没有任何额外
UI 或文字。任何一项不满足都不要输出。

## 自主修复循环

- 不可变修复边界：
  - 组件 ID、四个状态、四格顺序和对象数量；
  - Image 1／2 的权威顺序与受限职责；
  - `1024 × 1024`、`2 × 2`、每格 `512 × 512` 和中心 `224 × 224`
    安全盒；
  - 右／下箭头的严格旋转关系、空圈／勾选圈的严格增量关系；
  - 深乌棕墨迹、纯 `#00FF00` 色键、禁止烘焙和 runtime cell 合同。
- 允许的自主修复：
  - 在上述边界内强化轮廓、方向、状态一致性、墨迹材料、占用、居中和纯色
    背景措辞；
  - 可在 `generate` 与局部 `edit` 之间选择；
  - 允许把同一循环的前次输出作为额外 edit 输入，但只能修复已声明的四格，
    同时每次仍上传固定 SHA 的 Image 1／Image 2。
- 必须重新授权：
  - 新增或删除对象／状态、改变格位或画布、改变 runtime 尺寸、改变视觉
    隐喻、改用金属／皮革、增加新外部参考、交换参考职责或改变色键策略。

| 尝试 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `QL-B1 V1` / `48ee8ec` | generate | session `019fb1d9-0792-7110-8156-2aed5644d5c7`；无 result | 无输出／无 SHA | 0. 执行正文与传输一致性：保存目录不可写 | 保持完整视觉合同；预建子进程输出目录并使用 `workspace-write`，仅固定 Image 1／2 重生 | transport-error；计入预算 |
| 2/5 | `QL-B1 V1.r1` / `6fdf109` | generate | outer session `019fb1dc-57c5-77a0-b3ce-a884d61e0c99` | 无输出／无 SHA | 0. 执行正文与传输一致性：同名包装 skill 触发递归委托 | 完整提示词和固定两图均已正确传入；中断递归，不保留输出 | executor-recursion；计入预算 |
| 3/5 | `QL-B1 V1.r1` 非预期递归重放 / `453450d` | generate | observed nested task/session `019fb1dc-58df-7a43-83d0-97d674a5229a` | 无输出／无 SHA | 0. 执行正文与传输一致性：非预期嵌套固定调用 | 主进程发送 `Ctrl-C`，无候选；后续明确禁止二次委托 | interrupted；按最保守口径计入预算 |
| 4/5 | `QL-B1 V1.r2` / `21871a0` | generate | session `019fb1e0-9914-74f2-ab21-a3af62713f58`；generated-image `ig_0003fcc8d237f171016a6afa0f7e9c8191b71f23127c34cfc5` | raw `cc14b469…`；transparent `79e5bf71…` | 2. 语义／状态同源关系：箭头非严格旋转，圈并非只差墨勾 | 保留四格顺序、对象身份、方向、综合色和无额外物；以本稿作 Image 3，只修冻结四格 | rejected；进入最终修复 |
| 5/5 | `QL-B1 V1.r3` / `f99d17a` | edit | session `019fb1e8-db9a-7010-86d1-98008548e4d6`；generated-image `ig_007a38bf53929826016a6afc3030688191af04ac2e61682f6d` | normalized raw `73f719d4…`；transparent `719445d1…` | 2. 语义／状态同源关系仍失败；基本复刻 attempt 4 | 保留小尺寸可辨与综合色作为负面证据；不再调用，不晋级 | rejected；repair-budget-exhausted |

## QL-B1 V1.r3 完整修复执行正文

使用固定 ImageGen v0.143.0 编辑 Image 3，生成一张可拆分为游戏 UI sprite
的四状态源图。这不是完整界面概念图，也不是一本书的截图；输出只能包含
四枚彼此独立的小型手绘墨记。Image 3 中正确的四格顺序、四个对象身份、
右／下方向、深乌棕综合色和没有额外 UI 的范围必须保留；其画布尺寸、物件
占用、形态同源关系、立体材质和背景色必须按下文修复。

输入图职责：

- Image 1 是最高视觉权威。只继承它所体现的 2004 年前后香草魔兽二维手绘
  位图语言：粗厚而略不规则的轮廓、明确的明暗切面、低饱和暖旧配色、公会
  任务卷宗的沉重年代感，以及缩小后仍清楚的图形重量。忽略并且绝不复制它的
  完整书体、矩形任务卡、长标题牌、指南针、黄铜外框、奖励区、页码、文字和
  大蜡封。
- Image 2 只是已接受任务书页的次级材料参考。只继承暖赭旧纸旁边适用的深
  乌棕墨色、年代和磨损尺度。忽略并且绝不复制封皮、纸页、书脊、装订、包角
  或任何背景结构。Image 2 不得覆盖 Image 1 的视觉权威。
- Image 3 是同一授权循环的 attempt 4 edit 输入。只保留它的四格顺序、
  四对象范围、基本方向、深乌棕综合色和粗厚可读性。必须修复它的
  `1254 × 1254` 错误画布、过大且偏心的圆圈、彼此独立重画的两枚箭头、
  不完全相同的两枚外圈、皮革／木雕式凸边和非纯绿色背景。Image 3 不是
  视觉权威，不能覆盖 Image 1／2。

画布与排布：

- 输出恰好一张 `1024 × 1024` 正方形栅格图；不得沿用 Image 3 的
  `1254 × 1254` 尺寸，不得添加画布外缘或自动留边。
- 严格分成 `2 × 2` 四个逻辑格，每格 `512 × 512`；不要画格线、分隔线、
  标签或边框。
- 左上格 `x=0..511, y=0..511`：地区标题 `collapsed` 墨箭头。
- 右上格 `x=512..1023, y=0..511`：地区标题 `expanded` 墨箭头。
- 左下格 `x=0..511, y=512..1023`：`untracked` 空墨圈。
- 右下格 `x=512..1023, y=512..1023`：`tracked` 墨圈加墨勾。
- 每枚物体必须在本格正中心，全部可见像素只能落在本格中心
  `224 × 224px` 的安全盒内；为避免再次越界，每枚实际可见包围盒控制在
  最多 `190 × 190px` 并严格居中。四周留宽阔、完全干净的色键区。物体
  不得触碰格边、不得跨格、不得彼此连接，四件视觉占用和笔触重量要一致。
- 全画布背景必须是完全均匀、无纹理、无渐变、无阴影、无压缩噪点的纯
  `#00FF00`。物体内部和抗锯齿边缘不得使用任何绿色。不要透明棋盘格，不要
  纸张底色。

四件物体的共同美术：

- 正面平视的二维手绘 UI sprite，无透视、无倾斜、无三维厚度、无投影到
  背景。四枚物体必须读成压在纸面上的平面墨迹，不得读成皮革片、木雕、
  金属牌或有厚度的 token；删除 Image 3 的双层凸边、倒角、内嵌面、
  材料颗粒和接触阴影。只允许一层粗墨轮廓内有极少量干笔色差。
- 使用低饱和深乌棕、暖黑和极少量旧赭干笔边缘，像冒险者公会卷宗上反复使用
  的手绘墨记。轮廓粗厚、略有手工误差，但不能毛躁成污点。
- 形态必须为低分辨率友好：未来缩到 `10–12 UI px` 时，方向、空心和勾选
  仍可一眼辨认。不要微型花纹、细线雕刻、复杂裂纹或依赖高分辨率的细节。
- 延续香草魔兽的夸张但实用的图形重量，不做现代扁平矢量、极简线性 icon、
  App checkbox、玻璃拟态、霓虹描边、PBR 金属、照片级墨水、暗黑 3 尖刺
  祭坛或上古卷轴式极简菜单。

逐格结构：

1. 左上 `collapsed`：一枚紧凑的实心手绘三角墨箭头，明确指向右方。允许
   中心有一处很小的暖赭干笔断面来表现旧墨，但不能形成字母、加号、减号、
   菱形徽章或金属箭镞。
2. 右上 `expanded`：先逐像素复制左上箭头的完整轮廓、内部干笔缺口和
   磨损，再把这个副本严格顺时针旋转九十度，明确指向下方。不得独立重画；
   旋转回去后必须能与左上完全重合，不得增加第二枚箭头。
3. 左下 `untracked`：一个近圆但略有手绘误差的开放墨圈，线条粗短、闭合
   清楚、内部完全空。它不是方形复选框、按钮底座、印章或硬币。
4. 右下 `tracked`：先逐像素复制左下的完整空墨圈，位置和尺度不变，再只
   在圈内增加一笔粗短、方向明确的手绘勾。不得重新生成或改画外圈；移除
   墨勾后，右下外圈必须与左下外圈完全重合。墨勾从左下向右上收笔，不能
   越出墨圈太多。

绝对禁止出现任何文字、数字、字母、罗马数字、`+`、`-`、完整书页、皮革、
黄铜、卡片、面板、行背景、按钮、滚动条、书签、类型徽章、沙漏、蜡封、
任务名、发光、外框、格线、水印、说明图例或第五件物体。

输出前逐项自检：画布是否只有四件；四格顺序是否正确；右箭头与下箭头是否
确为同一形态旋转；空圈与勾选圈是否只差一笔墨勾；所有像素是否留在各自
`224 × 224px` 安全盒且实际包围盒不超过 `190 × 190px`；四件是否都只是
无凸边、无厚度的平面墨迹；背景是否为完全均匀的纯 `#00FF00` 且没有任何
额外 UI 或文字。任何一项不满足都不要输出。

## 执行记录

- 日期：`2026-07-30`；attempt 1 保存环境失败；attempt 2 触发递归，递归
  固定调用按 attempt 3 计数并由主进程中断；attempt 4 生成后退回；
  attempt 5 编辑后仍失败，循环终止。
- 会话／结果 ID：
  - attempt 1：session
    `019fb1d9-0792-7110-8156-2aed5644d5c7`；无 result。
  - attempt 2：outer session
    `019fb1dc-57c5-77a0-b3ce-a884d61e0c99`；无 result。
  - attempt 3：observed nested task/session
    `019fb1dc-58df-7a43-83d0-97d674a5229a`；无 result；由主进程中断。
  - attempt 4：session
    `019fb1e0-9914-74f2-ab21-a3af62713f58`；generated-image
    `ig_0003fcc8d237f171016a6afa0f7e9c8191b71f23127c34cfc5`。
  - attempt 5：session
    `019fb1e8-db9a-7010-86d1-98008548e4d6`；generated-image
    `ig_007a38bf53929826016a6afc3030688191af04ac2e61682f6d`。
- 实际输入绝对路径与职责：
  - Image 1：
    `assets/locked/quests/任务详情面板_视觉基准_v1.png`
    （执行时从当前工作副本解析为绝对路径）
    ——最高视觉权威，固定 SHA
    `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
  - Image 2：
    `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`
    （执行时从当前工作副本解析为绝对路径）
    ——受限纸面色温／年代参考，固定 SHA
    `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
- attempt 5 允许的 Image 3：
  `generated/quests/QL-B1/v1/attempt-04/raw/QL-B1_V1_r2_raw.png`
  （执行时从当前工作副本解析为绝对路径）
  ——仅为同一循环的冻结边界内 edit 输入，SHA
  `cc14b469ff5594a973c804510b11df6cb0b496e94f2b4daadb2b1abd5208eebd`。
- imagegen 报告的 revised prompt：无；attempt 4／5 均完整回显对应正文，
  没有报告改写后的 Prompt。attempt 5 遵循正文外执行说明，把工具原生
  `1254²` 输出整幅无裁切缩放为 `1024²`。
- 输出尺寸／模式／SHA-256：
  - attempt 1–3：无输出。
  - attempt 4 raw：`1254 × 1254 RGB`，
    `cc14b469ff5594a973c804510b11df6cb0b496e94f2b4daadb2b1abd5208eebd`。
  - attempt 4 transparent：`1254 × 1254 RGBA`，
    `79e5bf71d84b89fec507f6a3fb5b751d7895aa15fa32d09ec302eafca1e1f302`。
  - attempt 5 native raw：`1254 × 1254 RGB`，
    `995764a5ab7e18136d3f3153a7184daf5d9da65d153917369c83595205606c5f`。
  - attempt 5 normalized raw：`1024 × 1024 RGB`，
    `73f719d44a55b01d0ef8bc6f2c07343679a10b155d612941ca72d16869527596`。
  - attempt 5 transparent：`1024 × 1024 RGBA`，
    `719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44`。
- Alpha／残色：
  - attempt 4 经固定 helper 去除自动采样色 `#04F906` 后，透明／半透明／
    不透明像素为 `1420536／5914／146066`；可见绿色残留为 `0`。
  - attempt 5 经固定 helper 去除自动采样色 `#04F909` 后，透明／半透明／
    不透明像素为 `936446／4792／107338`；可见绿色残留为 `0`。normalized
    raw 只有 `135` 个精确 `#00FF00` 像素，仍非均匀纯色色键。
- 调用次数：`5/5`（attempt 5 调用前已计数）。
- 循环终态：`candidate-rejected / repair-budget-exhausted`。attempt 1 为
  `transport-error: Operation not permitted`；attempt 2／3 为
  `executor-recursion / interrupted`；attempt 4／5 为内部美术与合同退回。
- P4/P5 确定性执行：
  - 用户接受后没有新增 ImageGen 调用；固定执行器仍为 `5/5`。
  - exporter 逐格读取固定坐标、按可见 Alpha bbox 裁切、LANCZOS 等比缩放、
    居中、清理全透明像素的 RGB，并写入 `64 × 16` TGA；不旋转、镜像、
    重画或改变任何状态。
  - runtime atlas SHA-256：
    `e734bbf59da00f7fbc9c75649d33eaf635b5a0c19e1737128dfdce0db58eee8f`；
    透明／半透明／不透明像素：`632／292／100`；可见绿色残留 `0`。
  - adapter runtime contract `1.1` 创建／复用 `QuestLogTitle1..23`，固定
    `224 × 15` 行盒与 `14px` 步进；四种状态由
    `GetQuestLogTitle`、`FauxScrollFrame_GetOffset` 与
    `IsQuestWatched` 动态驱动。原行 Button、点击脚本、选择和滚动逻辑不变。
  - QL-B1 的覆盖 Texture 不接收鼠标；pfUI 的现代 `+`／`-` 小面板和原生
    check 可见纹理在 AEUI 状态刷新后隐藏，真实行为与状态源仍保留。
  - 当前 adapter runtime contract `1.6` 额外把同一 untracked／tracked
    墨圈 cell 复用于顶部 pfUI 等级与任务追踪 CheckButton；只改变纹理与
    尺寸，不改变原 `OnClick`、checked 状态或 SavedVariables。
  - 真实排版预演使用 QL-A2 当前 runtime shell、全部 23 个行槽、霞鹜文楷
    任务行、代表性中文任务名／等级／地区／追踪状态和右页真实密度。QL-C
    未完成按钮只作 manifest 明示的简化非权威占位。

## 审查记录

- 语义／物理：attempt 5 仍保留四个对象身份、顺序和基本方向；但右箭头与
  下箭头的轮廓、边缘起伏、内面和磨损不能旋转重合，tracked 外圈与
  untracked 外圈也不是“同一外圈只增加墨勾”。edit 基本延续 attempt 4，
  没有完成逐像素同源关系。这仍是第一个失败门禁。
- 透视／图层：对象互相独立且未跨格；但双层凸边、内嵌面和接触阴影把墨记
  画成有厚度的皮革／木雕 token，不是正面平面墨迹；attempt 5 未修复。
- 美术一致性：综合色、粗厚轮廓、手工误差与小尺寸可读性接近锁定基准；
  但材质身份偏离子模块 Prompt，外沿倒角和均匀内面也带有现代图标的精修感。
- 对象／状态合同：恰好四件、无文字和其他 UI；状态增量关系未通过。
- 装配／尺寸：真实 `12px`／`10px` 叠加预演中方向、空圈和墨勾仍可辨。
  normalized 画布已为 `1024²`，但四个可见 bbox 分别是
  `203 × 202`、`204 × 204`、`258 × 257`、`260 × 258px`；全部超过
  V1.r3 的 `190²` 目标，两枚圆还超过 `224²` 冻结安全盒。collapsed 右缘、
  expanded 左缘与两枚圆也越出各格中心安全盒，未严格居中。
- 技术像素：normalized raw `RGB`、SHA `73f719d4…`，背景自动采样为
  `#04F909` 而非均匀 `#00FF00`。透明稿 `RGBA`、SHA `719445d1…`，
  `936446` 全透明、`4792` 半透明、`107338` 不透明，无可见绿色残留，
  四格均未触 cell 边。
- 内部结论：attempt 5 曾因状态同源、平面墨迹身份、源安全盒与原始色键
  合同失败而退回，`5/5` 预算已经耗尽；这些历史事实不改写为“内部通过”。
- 用户结论与日期：`2026-07-30` 明确接受 `QL-B1 V1.r3` 的运行时视觉。
  用户接受以真实 `12px`／`10px` 下的可读性和综合色为准，覆盖此前把
  “像素级同源”“源安全盒”和“raw 精确纯绿”作为 P4 阻塞项的内部裁决；
  透明母版无可见绿色残留，允许以确定性逐格裁切、等比缩放、居中与 Alpha
  清理解决源占用差异。该接受不声称失败门禁已经客观通过。
- 当前结论：`game-validated / P6 / user-confirmed`（当前活动 runtime）。P4 source、确定性 exporter、
  `64 × 16` TGA、UV manifest、23 行 adapter、字体和 Lua／Python 静态
  测试已形成；不再调用 ImageGen。
- 真实排版：100% runtime 预演已覆盖全部 23 个行槽、代表性中文任务内容、
  四种状态分布、QL-A2 最新卷宗背景及实际层序；箭头、空圈与墨勾在密集排版
  下仍可辨，未侵入右侧 `22px` 滚动区。该预演不是 Turtle WoW 证据。
- 实机结论：用户于 `2026-08-05` 确认 Quest 左页既有 bug 与显示均已修复；
  当前 18 行字体、无描边／零 shadow、类型墨色和活动地区箭头门禁关闭。
  runtime 已隐藏的行末追踪圈及酒红书签不在本次验收范围。
- 下一门禁：组件／整模块收口前保留本 work；未来修改左页 runtime 时用上述
  条目作为回归清单，不再调用本版本 ImageGen。

## 2026-08-01 runtime 呈现覆盖

- 上述 `23 × 15px`、行末 untracked／tracked 圈和可见左页滚动条继续作为
  QL-B1 V1 资产生产与首次接入历史，不再是当前显示合同。
- 用户根据实机图明确要求提高整页字号、移除任务描边、统一完成／地下城等
  状态字体、隐藏行末圈和 scrollbar。Quests runtime `1.16`／Quest Visual
  Theme `1.5` 因此只显示 `QuestLogTitle1..18`，每行 `246 × 18px`、步进
  `18px`，文字从 `x=18` 起并使用 `226px` 安全宽；全部行内 FontString
  使用 `12px` 霞鹜文楷、空 flags 和透明／零偏移 shadow。
- `QuestLogTitle19..23` 仍由 adapter 创建并保留 ID／脚本以兼容 pfUI／
  pfQuest，但每次 provider 最终刷新后隐藏。任务行原生 check 与历史
  `aeuiQuestListCheck` 均隐藏，不创建替代图标；accepted atlas 的两枚圈继续
  供顶部真实等级／追踪 CheckButton 使用。
- 左右页 scrollbar chrome 都隐藏并禁用鼠标；左页通过隐藏的真实 Slider
  与 FauxScrollFrame offset 接收滚轮，右页通过 ScrollFrame range 接收滚轮。
  任务名在 Quest Log 与 Tracker 共同调用 `ResolveQuestNameInk`，完成／失败／
  地下城／进度只保留自己的状态墨色。Theme `1.5` 将实机中过淡的五档难度色
  压为高对比深墨，并把任务类型／完成／失败分别归一化为深紫／深绿／深红；
  adapter 同时处理模板拆分 FontString 和标题后的内联色码。该覆盖没有修改
  source、atlas、manifest 或 provider 行为，也没有调用 ImageGen。
- 当时的新门禁：Turtle WoW 验证 18 行实际基线、状态 FontString、长列表
  滚轮首尾、行末圈／scrollbar／19..23 不回生，以及同一任务跨 Quest Log／
  Tracker 的名称颜色一致；当前左页 bug／显示范围已由 `2026-08-05` 用户
  实机结论关闭，Tracker 独立门禁仍保留。

## `2026-08-04` runtime `1.18` 字体恢复验证

- 另一台设备报告左页仍使用不同字体；远端审计确认默认 `origin/main` 仍为
  Quests runtime `1.16`／Theme `1.5`，该版本确实会把任务行强制为霞鹜文楷。
- 当前分支 runtime `1.18` 在 provider 刷新后继续恢复全部活动行与模板拆分
  FontString 为 `pfUI.font_default`、`12px OUTLINE`、零额外 shadow，并通过
  最多两次下一帧有限重排覆盖 pfQuest 的晚写入；待办完成后停止，不常驻改写。
- `/aeui status` 会返回实际解析到的 Quest frame、theme 和 font 路径。目标
  客户端只有在看到 `quest frame=1.18 theme=1.6` 且 font 指向 pfUI 默认字体后，
  才能把画面作为本版 P5 验收证据。

## `2026-08-04` runtime `1.19` 无描边修复

- 最新实机截图确认 runtime `1.18` 的 `12px OUTLINE` 在任务纸面形成粗黑阴影，
  中文笔画被描边吞没；这不是额外 shadow 回生，而是主题 flags 本身造成。
- Theme `1.7` 保持 `pfUI.font_default`、`12px` 和既有语义墨色，但把任务名与
  拆分状态 FontString 的 flags 置空，并继续把 shadow color／offset 清零。
  provider 后写入仍由原有最多两帧有限重排恢复，不新增维护循环。
- Lua smoke 已覆盖 18 条活动行、模板拆分状态、pfQuest online 文本和晚写入
  FontString 均为无描边／零 shadow。下一份实机证据必须先确认
  `quest frame=1.19 theme=1.7`。

## `2026-08-04` runtime `1.22` 类型标签写入锁

- runtime `1.20`／`1.21` 对内联标签与 `QuestLogTitleNTag` 做过刷新后的单次
  着色，但实机证明原生选中、悬停／离开或 pfQuest 的更晚写入仍会把
  （团队／精英／地下城）恢复成难度色。
- runtime `1.22` 以屏幕上真实、非空的 Tag FontString 为权威，在它自身的
  `SetTextColor` 上安装事件驱动语义锁；普通刷新、选中、悬停／离开及 provider
  后写都只能落回任务类型深紫。锁不轮询、不改写行 Button 的原生难度色
  `r/g/b`，内联半角／全角括号标签继续由显式色码处理。
- `/aeui status` 新增 `tag=semantic-setter-lock`。下一份实机证据必须同时看到
  `quest frame=1.22 theme=1.8`，并复测普通、选中、悬停、离开四种状态。
- 随后的 runtime `1.22` 实机截图已确认左页类型文字颜色修复；runtime `1.23`
  原样保留该锁，本轮不再改动已验证的类型色实现。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `QL-B1 V1` | commit `13edad9`；session `019fb1d9-0792-7110-8156-2aed5644d5c7`；无输出 | transport-error；`1/5` 已消耗 | 不改美术正文；修复子进程写入环境 |
| `QL-B1 V1.r1` | commits `6fdf109`／`453450d`；outer session `019fb1dc-57c5-77a0-b3ce-a884d61e0c99`；observed nested `019fb1dc-58df-7a43-83d0-97d674a5229a`；无输出 | executor-recursion；attempt 2／3 均计入 | 不改美术正文；禁止当前固定进程二次委托 |
| `QL-B1 V1.r2` | commit `21871a0`；session `019fb1e0-9914-74f2-ab21-a3af62713f58`；raw `cc14b469…`；transparent `79e5bf71…` | rejected：状态同源、平面墨迹、画布、占用与色键失败 | 以本稿为 Image 3 做最后一次冻结边界内 edit |
| `QL-B1 V1.r3` | commit `f99d17a`；session `019fb1e8-db9a-7010-86d1-98008548e4d6`；transparent/source `719445d1…`；runtime `e734bbf5…`；真实排版 `c0e5bdff…`；`2026-08-05` 用户实机确认 | internal rejected；用户接受运行时视觉；当前活动范围 `game-validated / P6` | 组件／整模块收口前保留 work；不再生图 |
