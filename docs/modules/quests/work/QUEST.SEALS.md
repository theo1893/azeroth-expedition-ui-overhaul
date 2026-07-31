# Quest Log／Tracker 共用漆章

- 批次：`QS-A1`
- 当前生产版本：`QS-A1 V1`
- 已确认模拟：`QUEST-SEALS-SIM-V2`
- 项目阶段：`P3`
- 当前子状态：`prompt-authorized`
- 固定执行器：`imagegen-0-143-0`
- 模拟 ImageGen：`0/0`
- 正式 ImageGen：`0/5`
- runtime：未修改
- 用户生产授权：`2026-07-31`；固定 Image 1／2、同循环紧邻前次输出仅可在
  冻结修复边界内作为 Image 3 edit 输入、最多 `5` 次实际 ImageGen 调用，
  流程错误不占额度。
- 下一门禁：提交本授权状态后，以固定执行器运行 `QS-A1 V1` attempt 1。

## 组件合同

| ID | 当前对象 | 目标合同 |
|---|---|---|
| `QUEST.LOG.CHROME.SEAL` | 尚无 runtime 对象 | `QuestLogFrame` 上独立的 `28 × 28` 无鼠标 Texture；修订盒为 `[600,-18,28,28]`，位于任务书右上方透明 UI 空间，与 SHELL 可见 Alpha 重叠必须为 `0`。只有取得真实动作后，才允许在同一盒内一对一升级为 Button |
| `QUEST.TRACKER.HUB.SEAL` | 尚无 runtime 对象 | adapter-owned `34 × 34` 顶部中央漆章；宽度 `W` 时 `x=floor((W-34)/2)`、`y=-18`，底边恰好落在 provider `16px` 工具条／列表起点，不移动任务内容 |
| `QUEST.TRACKER.HUB.MENU` | 尚无对象 | 未来独立交互批次；漆章点击后承载七项 provider 行为。本模拟不绘制、不实现，也不把它当成已有 Button |

Tracker 纸面仍严格等于 live `pfQuestMapTracker`，四边 paper outset 都是
`0px`；只有漆章本身产生受控的顶部 `18px` 可见 outset，不形成书框、端帽、
皮带或外围边界。`130／230／330px` 三种宽度均使用同一个居中公式。
provider 的 `SetClampedToScreen(true)` 不一定计入 child outset；P5 必须
feature-detect clamp inset 或在拖动结束／位置恢复时补足 `18px` 顶部屏幕
安全距，并以屏幕顶缘场景复查。不得通过缩小漆章或下压覆盖第一行规避。

现有七个 provider Button 与迁移目标一一对应：

| provider 对象 | 既有职责 | 未来 hub menu 条目 |
|---|---|---|
| `tracker.btnquest` | 当前任务模式 | `QUEST.TRACKER.MODE.QUESTS` |
| `tracker.btndatabase` | 数据库结果模式 | `QUEST.TRACKER.MODE.DATABASE` |
| `tracker.btngiver` | 任务给予者模式 | `QUEST.TRACKER.MODE.GIVERS` |
| `tracker.btnsearch` | 打开数据库浏览器 | `QUEST.TRACKER.ACTION.SEARCH` |
| `tracker.btnclean` | 清空数据库结果 | `QUEST.TRACKER.ACTION.CLEAN` |
| `tracker.btnsettings` | 打开 pfQuest 设置 | `QUEST.TRACKER.ACTION.SETTINGS` |
| `tracker.btnclose` | 隐藏 tracker 并写入配置 | `QUEST.TRACKER.ACTION.CLOSE` |

目标视觉隐藏七枚旧 icon，但 runtime 必须先完成 hub menu 的七项功能等价、
Tooltip、禁用／显隐、模式反馈和原脚本委托，才允许隐藏并禁用旧 Button 的
鼠标。迁移前旧 Button 继续原样可见可用；不得为了先看见漆章而丢失功能。
漆章未来接收鼠标后，其余 tracker 纸面仍承担拖动，位置保存与屏幕限位不变。

`QUEST.LOG.CHROME.SEAL` 是工具／配置候选入口，不是
`QUEST.LOG.STATE.SEAL` 的 complete／failed 状态。两者不能共享状态语义、
任务数据或显示条件。用户已明确禁止它出现在任务书翻页、纸页、书封、包角或
装订结构上；当前锚点产生顶部 `18px` visual outset，P5 必须补足同值屏幕
顶缘安全距。

## 美术基准继承

权威链：

1. 锁定图与产生／语义锁定它们的 Prompt 共同构成最高视觉权威：
   [任务详情面板](../../../../assets/locked/quests/任务详情面板_视觉基准_v1.png)，
   SHA-256
   `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`；
   [任务追踪面板](../../../../assets/locked/quests/任务追踪面板_视觉基准_v1.png)，
   SHA-256
   `3b5c2ca6c1e69c74db5c64978cde351596ece6369d339b7125aee43904eb7d86`；
   对应 provenance 为 [Quests 主模块基线](../ART_BASELINE.md) 与
   [Quests 子模块基线](../SUBMODULE_ART_BASELINES.md)。
2. [全局美术基线](../../../GLOBAL_ART_BASELINE.md)。
3. [真实子模块合同](../SUBMODULES.md) 只裁决对象、几何、状态、层序与禁止
   烘焙，不改写上述视觉 DNA。
4. 本批没有 `assets/source/` 或结构参考输入；本地模拟也不是视觉输入。

必须继承：

- `2004` 年前后香草魔兽的二维手绘 sprite、粗厚略不规则轮廓、明确明暗
  切面与左上暖光；
- 低饱和暗酒红／旧酒红蜡体、深乌棕凹痕、极少量旧黄铜暖色反光；
- 真实蜡体厚度、压印起伏、纸／皮革接触感和克制磨损；
- Quest Log 的正式公会卷宗身份与 Tracker 的行军便笺身份。

组件级转译：

- 两处共用同一枚“远征公会工具漆章”美术母版，中心为极简四向罗盘与一笔
  斜向羽毛笔刻痕；无字母、阵营徽记、任务状态勾叉或发光符文；
- Quest Log 以 `28px` 显示，悬置在右上方透明 UI 空间，与可见书体保持
  明确间隔；不得压在翻页、纸页或书封上；
- Tracker 以 `34px` 显示并成为顶部中央明显视觉焦点；它明显但不发展成
  巨大蜡封、徽章墙或覆盖任务文字的奖章；
- normal／hover／pressed／disabled 必须保持同一轮廓与压印，交互差异由
  确定性亮度、色温、退灰与 `1px` pressed 锚点变化派生。

明确排除：丝带、绳结、吊坠、硬币／金属勋章、宝石、火焰特效、文字、
任务完成／失败符号、皮带、外围书框、现代圆形图标、玻璃高光、霓虹、
暗黑式祭坛、照片级古董蜡。

冲突裁决：主模块基线禁止“巨大蜡封”，用户要求 Tracker 漆章成为明显元素。
本批次以固定 `34px`、只占最小 `130px` 宽度约四分之一、且不进入列表内容
的单枚漆章满足显著性；不得继续放大、增加丝带或复制多枚装饰。

## 生成前模拟实例图

### V1 用户结论

用户于 `2026-07-31` 明确接受 `QUEST-SEALS-SIM-V1` 的共用漆章美术方向、
Quest Log `28px`／Tracker `34px` 相对尺寸、Tracker 顶部中央锚点、旧七
icon 的目标隐藏层级和综合色；同时否决 Quest Log 的
`[625,377,28,28]` 右下位置，因为它落在翻页／书封结构上。V1 因该可见位置
修订不能整体晋级为 `simulation-confirmed`；生产 ImageGen 仍未授权。

### 当前 V2 位置修订

V2 只把 Quest Log 漆章移到 `[600,-18,28,28]`。Tracker、两处尺寸、符号、
综合色、状态节奏和功能迁移边界全部沿用用户已接受的 V1，不重新打开范围。

规格：
[quest_seals_simulation_v2.json](../../../../tools/specs/quest_seals_simulation_v2.json)，
SHA-256
`ebb31e6226c6755cf4cbdb884a414264885b32a0698cc30e0d574025805251d7`。

渲染器：
[render_quest_seals_simulation_v1.py](../../../../tools/render_quest_seals_simulation_v1.py)，
SHA-256
`a9417bd4739781f953ffdb01e19cb5762a5e19790e5b2c070b4db6b1b4239199`。

macOS 命令：

```bash
conda run -n py312 python \
  tools/render_quest_seals_simulation_v1.py \
  tools/specs/quest_seals_simulation_v2.json \
  --repo-root .
```

解释器：
`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，Python `3.12.12`。
本地渲染错误：`0`。ImageGen：`0/0`。模拟使用当前已接受 Quest Log shell
作为邻接 runtime UI，只作周边上下文；没有把模拟像素或 shell 裁切成新资产。

输出：

- 游戏内整体预演：
  `generated/quests/QUEST-SEALS/simulation/QUEST-SEALS-SIM-V2/quest_seals_ingame_v2.png`，
  `1536 × 1024 RGBA`，SHA-256
  `cf05105d8f1ae021e28773be10b282ef6977c365b43c87b6b33c318f1208739e`；
- 组件／宽度合同板：
  `generated/quests/QUEST-SEALS/simulation/QUEST-SEALS-SIM-V2/quest_seals_contract_v2.png`，
  `1536 × 1024 RGBA`，SHA-256
  `a85de786c75dab4cbcd2e02fc0ef8150f802f146578cbd9b884d8a315a6db727`；
- 机器报告：
  `generated/quests/QUEST-SEALS/simulation/QUEST-SEALS-SIM-V2/quest_seals_report_v2.json`，
  SHA-256
  `dd4d40f18841dc8dbf5d6896a3fbb6d64db26d48d3b8ec02f68b530420b1d1e7`。

内部检查：模拟几何 `pass`。Quest Log 漆章与缩放后的 SHELL 可见 Alpha
重叠像素为 `0`，且未与标题、左右阅读安全区、底部两组 Button 或关闭按钮
相交；顶部 visual outset 与未来屏幕安全距均为 `18px`。Tracker 在
`130／230／330px` 三种真实
宽度下均水平居中，底边恰接 `y=16` 列表起点，不覆盖任务内容；paper
outset 仍为零。当前新增 Frame／命中盒均为 `0`，七按钮在功能等价前不会被
runtime 隐藏。顶部 `18px` 屏幕 clamp 只是已定义的 P5 必做门禁，尚无
runtime 实现或实机通过结论。

可由本模拟确认：Quest Log 不接触书体的外置位置，以及 V1 已接受的相对尺寸、
综合色重、共用符号、静态隐藏旧 icon 后的层级和 Tracker 顶部突出程度。

非权威范围：最终蜡质笔触、裂纹、Alpha、像素边缘、source bbox、atlas、
四状态确定性数值、客户端混合和 hub menu 展开形态。模拟图不得成为生图输入、
source 或 runtime。

用户结论：V1 `direction-confirmed / quest-log-placement-invalidated`；
V2 于 `2026-07-31` `simulation-confirmed`。确认条款为：两处共用同一枚
暗旧酒红工具漆章；Quest Log 使用 `28 × 28` 外置盒且不接触书体；
Tracker 使用 `34 × 34` 顶部中央盒并保持明显视觉重量；综合色、共用符号、
旧七 icon 的目标隐藏层级和 `18px` 顶部 outset 沿用 V1。确认只接受这些
文字化方向，不接受模拟像素，也不授权正式 ImageGen。

## 最终执行正文 — QS-A1 V1

状态：`production / authorized 2026-07-31`。必须按本正文原样执行。

固定输入：

1. Image 1：
   `assets/locked/quests/任务详情面板_视觉基准_v1.png`，SHA-256
   `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
   只继承香草魔兽手绘年代、Quest Log 暗酒红皮革／暖赭纸／旧黄铜之间的
   色温、实体厚度、左上暖光和有限磨损；忽略完整书本、纸张、文字、按钮、
   奖励槽、书脊、丝带和布局。
2. Image 2：
   `assets/locked/quests/任务追踪面板_视觉基准_v1.png`，SHA-256
   `3b5c2ca6c1e69c74db5c64978cde351596ece6369d339b7125aee43904eb7d86`。
   只继承 Tracker 行军便笺的综合色重、旧酒红点缀、左上暖光、小尺寸 UI
   笔触，以及“罗盘＋羽毛笔”的公会工具语义；忽略完整 tracker、纸面、
   皮带、金属罗盘实体、写实羽毛实体、任务文字、图标、按钮和屏幕场景。

本地模拟不上传。`assets/source/` 派生物不是视觉权威，也不上传。

完整正文：

> 为 Turtle WoW 1.18.1 的“艾泽拉斯远征手记”任务模块制作恰好一枚独立的
> “远征公会工具漆章”透明源资产。最终只出现一个正面略带内部俯视的圆形旧蜡
> 压印，不出现第二个物件、书本、纸张、面板、按钮、图标底座、文字或场景。
>
> Image 1 是 Quest Log 综合色、实体厚度、左上暖光、有限磨损和 2004 年
> 前后香草魔兽二维手绘年代的最高视觉参考；只继承暗酒红皮革、暖赭纸和旧
> 黄铜之间的色温关系，忽略整本书、书页、书脊、按钮、奖励槽、丝带、文字与
> 布局。Image 2 只补充 Tracker 行军便笺的综合色重、小尺寸手绘笔触和
> “罗盘＋羽毛笔”的公会工具语义；忽略整张便笺、纸面、皮带、按钮、任务
> 文字、屏幕场景，也不要复制其中的金属罗盘实体或写实羽毛实体。两张输入
> 都只用于把同一语义转译为蜡面浅压印，不允许生成输入图里的完整 UI。
>
> 画布固定 1024×1024。背景必须是完全均匀、无纹理、无阴影、无渐变的精确
> #00FF00。唯一漆章水平和垂直居中，可见 bbox 约 640×640，四周至少各留
> 180px 纯绿色安全边。不得裁边。全部蜡体、高光和自阴影必须收在该安全盒；
> 不生成投向纸面或书封的外部接触阴影。背景不得被蜡色、反光、烟雾或半透明
> 绿边污染。
>
> 物件是一枚可作为独立 UI 工具控制的暗旧酒红蜡章，而不是现代圆形
> icon、金属硬币、勋章、宝石、按钮底座或燃烧火球。轮廓接近圆形但保留少量
> 手压不规则边、局部堆蜡和最多三处小缺口；有可读但不过厚的蜡体侧缘、左上
> 暖色短高光、收敛在自身轮廓内的右下深乌棕自阴影和哑光微透蜡质。不要依赖
> 纸张、书封、丝带或其他背景才能读懂。不要光滑塑料、玻璃反射、
> 写实摄影噪声或大量裂纹。
>
> 中央只有一个浅压印：粗短、低分辨率友好的四向公会罗盘，叠加一笔斜向
> 羽毛笔刻痕。压印靠凹凸和深乌棕色差识别，不使用字母、阵营徽记、勾、
> 叉、任务完成／失败符号、发光符文或细密花纹。线重必须保证缩到 28×28
> 与 34×34 UI px 时仍可识别；装饰不得挤满蜡面。
>
> 严格采用 2004 年前后香草魔兽二维手绘 sprite：粗厚略不规则轮廓、明确
> 明暗切面、略夸张实体厚度、左上暖光、低饱和暗酒红／旧酒红、深乌棕凹痕
> 与极少量旧黄铜暖反光。磨损集中在外缘和压印高点。不得出现现代扁平 UI、
> 半透明玻璃、细金线、霓虹、暗黑 3 式祭坛、尖刺黑铁、上古卷轴极简菜单
> 或照片级古董。
>
> 不要丝带、绳结、吊坠、火焰、烟、火星、封蜡柄、邮封、皮带、外围书框、
> 页角、任务文字、按钮文字或额外徽章。最终自检：画面中恰好一枚漆章；
> 物件完整位于约 640×640 中央安全盒；纯 #00FF00 背景连续可色键；中心
> 罗盘加羽毛笔在小尺寸可读；第一眼是香草魔兽公会卷宗使用的厚旧蜡章，
> 不是现代 icon 或金属奖章。

后续确定性导出合同：只从同一 accepted base 派生
normal／hover／pressed／disabled，四态 Alpha 与轮廓完全相同；hover 只
暖亮，pressed 只压暗且由 runtime 锚点下移 `1px`，disabled 只退灰。
计划 runtime 为一行四个 `64 × 64` cell 的 `256 × 64` atlas，每格居中
同一约 `60 × 60` visible content，四边各留约 `2px` 透明采样边，相邻
状态可见像素间至少相隔约 `4px`。完整 cell 映射到 Quest Log
`28 × 28` 与 Tracker `34 × 34` Texture 盒时，目标可见蜡体分别约
`26 × 26` 与 `32 × 32 UI px`，与已确认模拟一致。source 接受后必须按真实
Alpha bbox 复核并只做等比缩放、居中、色键转 Alpha、全透明 RGB 清零与固定
RGB 状态派生；不得自由重画、拉伸、旋转或改变轮廓。

## 生产正文完整性预检

- 复杂度：`single-object / deterministic-derived-states`
- 结论：`pass`

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | 恰好一枚独立工具漆章；无书本、纸张、按钮、文字或场景；四态不由 ImageGen 分画 | `pass` |
| 每张输入图的 inherit／ignore 职责与权威冲突 | 正文逐张声明 Image 1／2 的继承与忽略项，并禁止复制金属罗盘／写实羽毛实体 | `pass` |
| 画布、边距、方向、透视、尺度、光照与层序 | `1024²`、约 `640²` bbox、至少 `180px` 安全边、正面轻俯视、左上暖光、独立对象 | `pass` |
| 形态、材料、边缘与符号 | 暗旧酒红蜡体、不规则压边、有限缺口、浅压印罗盘＋羽毛笔、自阴影 | `pass` |
| crop／stretch／repeat／safe area | 单物件不拉伸不平铺；source 接受后等比归一化，目标可见蜡体 `26px／32px` | `pass` |
| 美术 DNA、反模式、色键与最终自检 | 香草手绘、低饱和旧材质、精确 `#00FF00`；明确禁止现代 icon、金属奖章、玻璃、霓虹与暗黑祭坛 | `pass` |

- 未知但执行必需的值：无。
- 去冗余结论：只保留会阻止完整 UI、金属徽章、现代圆 icon、色键污染和
  小尺寸不可读的高风险重复；过程历史留在本 work，不传给执行器。

## 自主修复循环

- 不可变修复边界：`QUEST.LOG.CHROME.SEAL` 与
  `QUEST.TRACKER.HUB.SEAL` 共用恰好一枚 base；固定 Image 1／2 及上述职责；
  `1024 × 1024` 画布、约 `640 × 640` 中央 bbox、精确绿色背景、罗盘＋
  羽毛笔浅压印、Quest Log `28 × 28`／Tracker `34 × 34` 盒、单 base
  确定性四态、全部禁止项和最多 `5` 次实际 ImageGen 调用均不可变。
- 允许的自主修复：只可修正同一物件的 bbox、居中、纯绿色背景、边缘、
  蜡质、压印清晰度、小尺寸辨识和综合色；attempt 2–5 可以选择 regenerate，
  或把同一循环紧邻前次输出作为额外 Image 3 做冻结区域 edit。使用 edit
  时仍固定上传 Image 1／2，且只能保留已通过的同一漆章区域。
- 必须重新授权：新增或替换外部输入、改变输入职责、对象／状态数量、中心
  符号、画布、runtime 几何、物件身份、视觉方向、功能合同、Alpha／色键
  策略，或加入书页、书封、丝带、皮带、按钮底座和其他外部承载物。
- 预算：最多 `5` 次实际 ImageGen generation／edit，含首次；流程错误在
  没有图片且没有 provider 生成证据时单列，不占额度。任一次内部完整通过
  立即停止；第 5 次仍失败则停止等待用户审核。
- 用户授权原文：`确认授权 QS-A1 V1；允许每次上传固定 SHA 的 Image 1/2，
  允许同循环紧邻前次输出仅在冻结修复边界内作为 Image 3 edit 输入；最多
  5 次实际 ImageGen 调用；流程错误不占生图额度。`

## 执行记录

- 日期：`2026-07-31` 已授权，尚未执行 attempt 1
- 会话／结果 ID：无
- 实际输入：无上传
- 输出：无正式候选
- 实际生图次数：`0/5`
- 流程错误次数：`0`
- 循环终态：未开始；`prompt-authorized`

## 审查记录

- 语义／物理：模拟中的两处漆章均为独立对象；未烘焙背景，未冒充任务状态。
- 透视／图层：正面轻微内部俯视；V1 Quest Log 右下锚点已按用户物理逻辑
  反馈作废，V2 位于可见书体之外；Tracker 位于纸面上缘并在列表层之前结束。
- 美术一致性：本地几何只证明暗酒红、深乌棕、暖赭和旧黄铜的综合色角色；
  最终手绘蜡质仍未生产。
- 对象／状态合同：一个共用 base，未来四态确定性派生；当前无 Button 或
  新命中盒。
- 装配／尺寸：Quest Log `28px`；Tracker `34px`，三宽度公式通过。
- 真实排版：整体游戏场景包含完整 Quest Log、二十三行目录、详情、奖励、
  底部控件与十任务／十七目标 Tracker；路径与 SHA 见模拟章节。
- 实际展示区域：机器报告 `pass`；Tracker paper outset `0px`，seal 顶部
  outset `18px`，不覆盖列表；屏幕顶缘 clamp 为 P5 pending。
- 技术像素：模拟非生产资产，不执行 Alpha／色键／atlas 门禁。
- 结论：`prompt-authorized / P3`
- 用户结论与日期：V1 方向接受并要求修订位置／`2026-07-31`；
  V2 外置锚点确认／`2026-07-31`
- 下一门禁：提交授权版本后执行 attempt 1。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `QUEST-SEALS-SIM-V1` | 本地 specification、renderer、两张 `1536 × 1024` 预演与机器报告；用户于 `2026-07-31` 接受方向并指出 Quest Log 位置错误；ImageGen `0/0` | `direction-confirmed / quest-log-placement-invalidated` | 保留共享美术与 Tracker；Quest Log 不得落在翻页／书封 |
| `QUEST-SEALS-SIM-V2` | Quest Log `[600,-18,28,28]`；可见书体 Alpha 重叠 `0`；两张预演与机器报告；用户于 `2026-07-31` 回复“进行下一步”；ImageGen `0/0` | `simulation-confirmed` | 展示并独立授权 `QS-A1 V1` 最终生产合同 |
| `QS-A1 V1` | 用户于 `2026-07-31` 明确授权完整正文、固定 Image 1／2、受限同循环 Image 3 edit 与最多 `5` 次实际调用 | `prompt-authorized / 0/5` | 提交授权状态并执行 attempt 1 |

正式生产尝试：无。
