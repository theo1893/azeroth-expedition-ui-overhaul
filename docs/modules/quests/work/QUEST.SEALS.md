# Quest Log／Tracker 共用漆章

- 已接受漆章批次：`QS-A1`
- 当前事务签批次：`QS-B1`
- 当前接受版本：`QS-A1 V1.r4`
- 已确认历史模拟：`QUEST-SEALS-SIM-V2`；其 Quest Log 顶部悬空位置已于
  `2026-08-03` 被用户否决，Tracker 方向仍有效
- 当前已确认模拟：`QUEST-LOG-SEAL-ACTIONS-SIM-V9`
- 当前生产正文：`QS-B1 V1.r1`
- 项目阶段：漆章美术／atlas／Quest Log placement `P5`；menu `P3`
- 当前子状态：QS-A1 `runtime-exported / page-placement-integrated`；QS-B1
  `attempt-01-rejected-internal / repair-prepared`
- 固定执行器：`imagegen-0-143-0`
- 模拟 ImageGen：`0/0`
- QS-A1 正式 ImageGen：`5/5`
- QS-B1 当前实际生图：`1/5`
- 流程错误：`2`
- tracked source：
  `assets/source/quests/qs-a1/QuestToolWaxSeal_Master_v1.png`，SHA-256
  `377dcdc141ee5487884bfc99dbfd82013a8c4d7cb7200a4414feebb81d72ab75`。
- runtime：`QuestToolWaxSealStatesV1.tga`，`256 × 64`、一行四个
  `64 × 64` cell，SHA-256
  `f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902`。
- 用户生产授权：`2026-07-31`；固定 Image 1／2、同循环紧邻前次输出仅可在
  冻结修复边界内作为 Image 3 edit 输入、最多 `5` 次实际 ImageGen 调用，
  流程错误不占额度。
- 用户于 `2026-07-31` 接受 `QS-A1 V1.r4` 的运行时视觉，并明确授权
  确定性色键、透明 RGB 清零与 `1024²` 归一化例外进入 P4／P5。不得再执行
  ImageGen。漆章物件美术和 atlas 不重开；Quest Log 旧锚点已失效，新的承载
  与事务菜单先等待本地模拟确认。当前 runtime `1.19` 继续按确认方向只使用既有
  Texture 的页上位置；QS-B1 仍独立门禁真实 Button 和事务菜单。V1 的外沿
  皮革承托已被物理语义复核淘汰；
  V2 因伪页唇、硬质按钮轮廓与断开的弹窗语义被用户否决；V3 虽改用真实
  shell 页缘和单张纸，却把“右页下方”误解成图层下方，仍从右侧中段横向
  伸出。V4 改为从 detail 下缘竖直夹入，但书签过长，展开态又新增一张大纸，
  导致书页层级和重心突变，已被用户否决。V5 收短书签并让事务操作复用原
  detail 右页，但用户仍否决 detail 内容模式替换；V6 包角／底部事务轨也被
  用户立即改向。V7 按明确指示将火漆直接印在详情页右上纸面，但把七项事务
  放在了页内右侧，仍遮挡正文；V8 改为从右页外缘向书外伸出的卷宗索引签，
  但用户认为其 `136×24px` 尖头、逐条铆钉、亮黄铜和 `72px` 外伸仍过重。
  V9 保留外侧展开与七个真实 Button，只收敛为 `112×20px` 的短书口事务签、
  `48px` 外伸，并移除箭头、逐项铆钉和明亮顶部高光。用户于
  `2026-08-03` 回复“进入下一步”，明确确认 V9 可见方向；确认只冻结下述
  文字化布局与综合色结论，不接受模拟像素。`QS-B1 V1` 生产正文已完成；用户于
  `2026-08-05` 明确授权固定 Image 1／2、受限紧邻 Image 3 edit、最多五次实际
  ImageGen 调用及合同内确定性后处理，正式生产循环进入 `P3 / 0/5`。
  旧 Quest Log／Tracker provider Button 在各自菜单功能等价前继续可见可用。

## 用户接受与 P4／P5 固化

- 用户接受原文：`接受 QS-A1 V1.r4 的运行时视觉，并授权确定性色键、透明
  RGB 清零及 1024² 归一化例外进入 P4/P5。`
- 未修改 r4 原图仍只作为 provenance：`1254 × 1254 RGB`，SHA-256
  `3e972a67a3b27bb28b6b7ef314f0784886d4e16d3de98df022891b08571e4da1`；
  固定输出尺寸与渐变绿背景的历史失败没有被改写为通过。
- accepted candidate 是 r4 经现有审查器确定性色键、可见 bbox 等比缩放、
  居中与透明 RGB 清零后的 `1024 × 1024 RGBA`，原候选 SHA-256
  `d5e5d12e09bd06e9e76f4382eea40b5501f5f6823d58b8693902ab98d8470f75`。
  归一化产生的 `58` 个重采样色键边缘像素按同一合同清为透明：其中 `32`
  个纯绿像素 Alpha 为 `1..4`，另 `26` 个绿色优势像素 Alpha 为 `3..19`。
  由此形成上述 tracked source；可见 bbox 保持
  `[192,200,832,824]`，透明像素下 RGB 全为 `0`，可见绿色残留为 `0`。
- source manifest：
  `assets/source/quests/qs-a1/QS-A1_SourceManifest_v1.json`；runtime manifest：
  `assets/source/quests/qs-a1/QS-A1_RuntimeManifest_v1.json`。
- exporter：`tools/build_quest_tool_wax_seal_v1.py`。normal／hover／pressed／
  disabled 使用同一 `60 × 58` Alpha；hover 只暖亮，pressed 只压暗并为未来
  Button 保留 runtime `1px` 下移合同，disabled 只退灰。当前两处都是无鼠标
  normal Texture，不伪造交互。
- 当前 Quest Log runtime `1.19` 使用 `[576,68,32,32]`，直接与详情页纸面相接，
  并把 `[572,64,40,40]` 保留为无标题／正文／奖励区域；Tracker 使用居中
  `34 × 34`、顶部 outset `18px`，并通过 feature-detect
  `SetClampRectInsets` 补足顶缘限位。`130／230／330px` 均不进入列表区。
- 最窄 `130px` 下，旧 `search` icon 覆盖漆章右下部，`giver／clean` 各触及
  `1px` 边条；这是功能迁移前的显式过渡层序。漆章在父 Frame 的 ARTWORK，
  旧七个 provider Button 仍在其上、保持可见、鼠标与原脚本。不得用 P5
  结果提前隐藏旧按钮。
- 最终展示区域合同：
  `tools/specs/quest_seals_runtime_display_region_v1.json`；ignored 机器报告
  SHA-256
  `7d84d0beb391a850f5ec84f46dd1f61230574bd105f449cd415cc3030f96e3bb`，
  Quest Log 与三种 Tracker 宽度均为 `pass`。真实排版使用最终 atlas 和
  当前旧按钮层序重新生成；不替代目标客户端验证。
- P4／P5 后新增实际 ImageGen：`0`。当前不得进入 `P6`，也不得清理 work
  或五次尝试中间证据。

## 组件合同

| ID | 当前对象 | 目标合同 |
|---|---|---|
| `QUEST.LOG.CHROME.SEAL` | `QuestLogFrame.aeuiQuestChromeSeal`，当前 runtime `1.19` 为 `[576,68,32,32]` 无鼠标 Texture | QS-A1 V1.r4 美术保持 accepted；`32px` 漆章直接压在详情页右上纸面，保留区 `[572,64,40,40]`。QS-B1 完成前不把它伪装成可点击 Button |
| `QUEST.LOG.CHROME.SEAL.SUPPORT` | 无 runtime 对象 | V9 明确不创建书签、包角、皮革／黄铜承托；只允许漆章自身接触阴影落在现有右页纸面 |
| `QUEST.LOG.CHROME.SEAL.MENU` | 尚无 runtime 对象 | V9 已确认：七个独立短书口事务签 Button 从 detail 右边界 `x=612` 向书外伸出，整体 `[612,112,112,158]`；真实页边 mask `[604,102,24,180]` 遮住根部，正文／奖励零占用。QS-B1 只生成一枚无字共用母版并确定性派生八态；功能等价前旧按钮保持 fail-open |
| `QUEST.TRACKER.HUB.SEAL` | adapter-owned 无鼠标 Texture，已由临时 tracker runtime 挂载 | `34 × 34` 顶部中央漆章；宽度 `W` 时 `x=floor((W-34)/2)`、`y=-18`，底边恰好落在 provider `16px` 工具条／列表起点，不移动任务内容 |
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

## 修复执行正文 — QS-A1 V1.r2

状态：`repair-final / authorized-by-bounded-loop`。这是 attempt 2 的完整
执行正文；必须固定上传原 Image 1／2，并把 attempt 1 未修改原图作为
Image 3。不得上传本地色键图、归一化图、排版图或模拟图。

> 对 Image 3 中同一枚“远征公会工具漆章”做一次冻结边界内的修图。最终仍
> 恰好只有一个正面略带内部俯视的圆形旧蜡压印；保留其单物件身份、暗旧酒红
> 综合色、近圆形手压轮廓、四向公会罗盘叠加一笔斜向羽毛笔的唯一中心语义，
> 以及没有书本、纸张、文字、按钮、丝带、火焰或第二个物件的已通过范围。
>
> Image 1 仍是 Quest Log 综合色、实体厚度、左上暖光、有限磨损和 2004 年
> 前后香草魔兽二维手绘年代的最高视觉参考；只继承暗酒红皮革、暖赭纸和旧
> 黄铜之间的色温关系，忽略整本书、书页、书脊、按钮、奖励槽、丝带、文字与
> 布局。Image 2 仍只补充 Tracker 行军便笺的综合色重、小尺寸手绘笔触和
> “罗盘＋羽毛笔”的公会工具语义；忽略整张便笺、纸面、皮带、按钮、任务
> 文字、屏幕场景，也不要复制金属罗盘实体或写实羽毛实体。Image 3 只是本
> 循环紧邻的失败候选；保留上述已通过身份和中心语义，但不要保留其过大
> 占幅、照片级蜡面、镜面白高光、高频颗粒、深雕／凸起徽章感、综合色过红
> 或非纯绿色背景。
>
> 画布固定 1024×1024，背景必须是完全均匀、无纹理、无阴影、无渐变的精确
> #00FF00。把漆章明显缩小并严格居中：可见 bbox 约 640×640，四周至少各留
> 180px 连续纯绿安全边；也可理解为物件只占画布宽高约 62.5%，左右／上下
> 各保留约 18% 空白。不得裁边。全部蜡体、高光和自阴影都收在该安全盒内，
> 不生成投向背景的接触阴影、绿色渐变、反光污染或半透明绿雾。
>
> 将 Image 3 的照片级立体蜡章明确重绘为 2004 年前后香草魔兽低分辨率二维
> 手绘 UI sprite：使用少量宽阔、清晰的暗酒红／旧酒红／深乌棕色块塑造
> 厚度，轮廓粗厚且略不规则，左上只有一段克制的暖色短高光，右下自阴影收在
> 轮廓内。去掉湿亮塑料感、镜面白点、细密凹坑、摄影噪声和均匀写实皮肤
> 纹理；在 1024 源图上也要呈现有意识的手绘笔触与明确明暗切面，而不是
> 写实材质球。
>
> 外圈保持近圆形手压蜡边，只留少量局部堆蜡和最多三处小缺口；减少同心圆
> 层级，避免金属硬币、奖章或现代圆形 icon 的规整边框。中心必须从 Image 3
> 的高浮雕／凸起徽记改成真正的浅压印：只用粗短的四向罗盘和一笔斜向羽毛笔
> 凹痕，以深乌棕色差和一侧窄暗边识别。删除罗盘外围细环、小三角、羽毛内部
> 多段细纹和多余轮廓；罗盘不超过四个主方向，羽毛内部最多两处宽切面。中心
> 符号在缩到 28×28 和 34×34 UI px 时必须先读作“罗盘＋羽毛笔”，不能
> 糊成现代品牌徽标、尖刺星章或金属浮雕。
>
> 综合色回到低饱和暗酒红和旧酒红，凹痕为深乌棕，只允许极少量旧黄铜暖
> 反光；不要鲜亮红、橙色发光、玻璃反射、霓虹、细金线、暗黑 3 式祭坛、
> 尖刺黑铁、上古卷轴极简菜单或照片级古董。不要新增丝带、绳结、吊坠、
> 火焰、烟、火星、封蜡柄、邮封、皮带、外围书框、页角、任务文字、按钮
> 文字、额外徽章或任何承载面。
>
> 最终自检：恰好一枚居中的暗旧酒红蜡章；画布为 1024×1024；可见物件约
> 640×640，四周至少 180px 精确 #00FF00；没有外部投影或背景污染；蜡面是
> 香草魔兽二维手绘色块而非照片材质；中心是简化的浅压印四向罗盘＋斜向
> 羽毛笔，并在 28px／34px 仍可辨识。

## 修复执行正文 — QS-A1 V1.r3

状态：`repair-final / authorized-by-bounded-loop`。这是 attempt 3 的完整
执行正文；固定上传原 Image 1／2，并把 attempt 2 未修改原图作为 Image 3。
不得上传 r1、本地色键图、归一化图、排版图或模拟图。

> 对 Image 3 中已经明显接近目标的同一枚“远征公会工具漆章”做一次严格
> 局部收敛修图。必须保留 Image 3 已通过的全部内容：恰好一个居中、正面
> 略带内部俯视的暗旧酒红蜡章；近圆但略不规则的手压主体；2004 年前后
> 香草魔兽二维手绘的宽阔明暗色块；唯一中心语义为简化四向罗盘叠加一笔
> 斜向羽毛笔；没有书本、纸张、文字、按钮、丝带、火焰、承载面或第二物件。
> 不旋转符号、不增加装饰；只按下文在主体外围增加与同一蜡体连续的受控
> 扩散。
>
> Image 1 继续只裁决 Quest Log 的暗酒红皮革／暖赭纸／旧黄铜色温、厚重
> 实体感、左上暖光、有限磨损和香草魔兽手绘年代；忽略书本、书页、书脊、
> 按钮、奖励槽、文字、丝带与布局。Image 2 继续只裁决 Tracker 的综合色
> 重、小尺寸手绘笔触和“罗盘＋羽毛笔”公会工具语义；忽略便笺、纸面、
> 皮带、按钮、任务文字、屏幕场景、金属罗盘实体与写实羽毛实体。Image 3
> 只提供本循环紧邻候选的已通过漆章造型；不得继承其偏小画布占比、绿色背景
> 渐变和外缘偏亮偏红的残余问题。
>
> 画布固定 1024×1024。不要改变漆章中心点，使主体加外围扩散后的总可见
> bbox 从当前折算约 548×551px 收敛到约 640×640px。可将主体适度等比
> 放大，并让新增扩散计入同一个总 bbox；最终总物件占画布宽高约 62.5%，
> 四边各有约 18% 且至少 180px 的连续安全边。不得裁边、拉伸或改变罗盘与
> 羽毛笔的相对比例。全部高光与自阴影仍收在同一蜡体轮廓内，不生成投向
> 背景的外部接触阴影。
>
> 背景必须重做为单一、像素级平坦的精确 #00FF00 色键平面：左上、右上、
> 左下、右下、四条边和物件周围都必须是相同 RGB(0,255,0)。背景不接收
> 光照，不使用色彩管理式渐变、压缩纹理、暗角、噪点、泛光、阴影、反射或
> 半透明绿雾。绿色不得混入蜡体边缘；物件之外只能有这一种绿色。
>
> 漆章主体保持 Image 3 已通过的低频二维手绘结构和清晰浅压印。只把外圈
> 偏鲜红、偏橙的亮边收敛为更暗、更低饱和的旧酒红；左上高光缩成一段短而
> 暖的赭红色块，不出现米白／粉白镜面线。深乌棕凹痕和右下自阴影保持，
> 不恢复照片级颗粒、湿亮塑料、细密蜡孔、金属浮雕或现代 icon 光泽。
>
> 在现有压印主体周围增加少量真实的火漆受压扩散：以底部、左下和右侧为主，
> 形成约三至五处宽而扁、彼此不完全对称的连体堆蜡／薄扩散瓣，其中两处可
> 轻微越过原圆周，其余只让边缘厚薄不均。扩散必须从主体外缘自然连续挤出，
> 与主体保持同一暗旧酒红蜡材质和同一左上光向；靠近主体较厚，向外逐渐变薄，
> 用一到两级宽阔色块表现，不使用写实液体模拟。不得出现分离蜡滴、飞溅点、
> 放射状泼洒、长尾、丝带形蜡流、第二滩蜡、外部投影或均匀一圈花边。小尺寸
> 下它只应让轮廓更厚重、更像真实压蜡，而不能抢过中央罗盘＋羽毛笔。
>
> 中央四向罗盘与斜向羽毛笔的现有简化程度、方向和线重保持不变；继续读作
> 浅压入蜡面的凹痕，而不是凸起徽章。不要增加外圈、小三角、字母、勾叉、
> 符文、羽毛细丝或第五个罗盘方向。缩到 28×28 与 34×34 UI px 时必须
> 保持当前清晰读法。
>
> 不得新增丝带、绳结、吊坠、火焰、烟、火星、封蜡柄、邮封、皮带、外围
> 书框、页角、任务文字、按钮文字、额外徽章、金属硬币、宝石、玻璃、
> 霓虹、暗黑 3 式祭坛或照片级古董。最终自检：恰好一枚与 Image 3 同核心
> 造型、但外围带三至五处连体受压扩散的香草魔兽二维手绘漆章；背景纯化且
> 外缘降红；主体加扩散在 1024×1024 画布上的总可见 bbox 约 640×640；
> 四周至少 180px 且只有精确 #00FF00；没有分离蜡滴；中心罗盘＋羽毛笔在
> 28px／34px 清晰。

## 修复执行正文 — QS-A1 V1.r4

状态：`repair-final / authorized-by-bounded-loop`。这是 attempt 4 的完整
执行正文；固定上传原 Image 1／2，并把 attempt 3 未修改原图作为 Image 3。
不得上传 r1／r2、本地色键图、归一化图、排版图或模拟图。

> 对 Image 3 中同一枚“远征公会工具漆章”做一次几何与背景收敛修图。保留
> 已通过的核心美术：恰好一枚暗旧酒红蜡章、正面轻微内部俯视、香草魔兽
> 二维手绘的宽阔明暗切面、简化的浅压印四向罗盘＋斜向羽毛笔，以及外围
> 与主体连续的真实受压火漆扩散。没有书本、纸张、文字、按钮、丝带、火焰、
> 承载面、分离蜡滴或第二物件。不得旋转、替换或重新装饰中心符号。
>
> Image 1 继续只裁决 Quest Log 的暗酒红皮革／暖赭纸／旧黄铜色温、厚重
> 实体感、左上暖光、有限磨损和 2004 年前后香草魔兽手绘年代；忽略书本、
> 书页、书脊、按钮、奖励槽、文字、丝带与布局。Image 2 继续只裁决
> Tracker 的综合色重、小尺寸手绘笔触和“罗盘＋羽毛笔”公会工具语义；
> 忽略便笺、纸面、皮带、按钮、任务文字、屏幕场景、金属罗盘实体与写实
> 羽毛实体。Image 3 只提供紧邻候选已通过的蜡体、符号与扩散语言；不得
> 保留其总占幅过大、整体略偏右、右侧扩散过重和绿色背景渐变。
>
> 画布固定 1024×1024。把 Image 3 的整枚蜡体——包括压印主体和所有连体
> 扩散——围绕其自身视觉中心严格等比缩小约 10%，再把总可见 bbox 的几何
> 中心精确放到画布中心。当前折算约 `722×706px`，目标收敛为约
> `640×630px`，允许宽高各在 `615–660px` 内；四边都必须至少保留
> `180px` 安全边。不得裁边、非等比拉伸或改变罗盘、羽毛笔与主体的相对
> 比例。全部明暗仍收在同一蜡体轮廓内，不生成外部接触阴影。
>
> Image 3 的火漆扩散方向成立，但“增加一点”必须是克制的。保留底部、
> 左下和右侧三至五处与主体连成一体的宽扁扩散瓣；把右侧最大凸起和底部
> 堆蜡的外伸量各收回约 20%，让主体圆盘仍占主要视觉面积。扩散靠近主体
> 较厚、向外渐薄，只用一到两级宽阔手绘色块。不得做均匀花边、连续波浪圈、
> 分离蜡滴、飞溅、放射泼洒、长尾、第二滩蜡或写实液体模拟。缩到
> 28×28／34×34 时，只让外轮廓不规则且厚重，不侵入或遮挡中心符号。
>
> 背景必须替换为单一、像素级平坦的精确 #00FF00。画布四角、四边、物件
> 周围和所有空白区域必须逐像素使用同一个 RGB(0,255,0)；背景不接收光照，
> 不得有渐变、暗角、噪点、纹理、压缩色带、泛光、阴影、反射或半透明绿雾。
> 绿色不得污染蜡体边缘；物件之外不得出现第二种颜色。
>
> 漆章保持低饱和暗酒红／旧酒红主体、深乌棕凹痕和左上短暖赭红高光。继续
> 压低米白、粉白、鲜红和橙色亮线；不要恢复照片级微纹理、湿亮塑料、
> 细密蜡孔、金属浮雕、玻璃反射或现代圆 icon 光泽。中央四向罗盘与斜向
> 羽毛笔必须保持 Image 3 的方向、简化程度与粗线重，继续作为浅压入蜡面的
> 凹痕；不要增加外圈、小三角、第五方向、羽毛细丝、字母、勾叉或符文。
>
> 不得新增丝带、绳结、吊坠、火焰、烟、火星、封蜡柄、邮封、皮带、外围
> 书框、页角、任务文字、按钮文字、额外徽章、金属硬币、宝石、霓虹、
> 暗黑 3 式祭坛或照片级古董。最终自检：恰好一枚居中的香草魔兽二维手绘
> 漆章；外围仍有少量连体受压火漆扩散但不形成花边；总 bbox 约
> `640×630px` 且四边至少 `180px`；物件外只有精确 #00FF00；没有分离
> 蜡滴；罗盘＋羽毛笔在 28px／34px 清晰。

## 修复执行正文 — QS-A1 V1.r5

状态：`repair-final / authorized-by-bounded-loop`。这是 attempt 5、也是本
授权循环最后一次实际 ImageGen 调用的完整执行正文。固定上传原 Image 1／2，
并把 attempt 4 未修改原图作为 Image 3。不得上传 r1／r2／r3、本地色键图、
归一化图、排版图或模拟图。

> 对 Image 3 做一次只针对画布与背景的冻结修图。Image 3 中整枚
> “远征公会工具漆章”已经通过视觉、对象、比例、居中、安全边、小尺寸和
> 展示区域审查；必须原样保留恰好这一枚蜡章的全部可见内容：暗旧酒红
> 综合色、正面轻俯视、香草魔兽二维手绘色块、浅压印四向罗盘＋斜向羽毛笔、
> 三至五处与主体连续的克制受压火漆扩散，以及没有书本、纸张、文字、按钮、
> 丝带、火焰、承载面、分离蜡滴或第二物件。不要重画、缩放、移动、旋转、
> 裁切、清理、锐化、增加纹理或改变漆章内部任何像素关系。
>
> Image 1 仍只作为 Quest Log 香草魔兽年代、暗酒红／暖赭／旧黄铜色温、
> 厚重实体、左上暖光和有限磨损的最高参考；忽略完整书本、书页、书脊、
> 按钮、奖励槽、文字、丝带与布局。Image 2 仍只作为 Tracker 综合色重、
> 小尺寸手绘笔触和“罗盘＋羽毛笔”工具语义参考；忽略便笺、纸面、皮带、
> 按钮、任务文字、屏幕场景、金属罗盘实体与写实羽毛实体。它们不得触发对
> Image 3 漆章的重新设计。
>
> 唯一允许的修复是：输出画布必须为精确 1024×1024，并把 Image 3 中漆章
> 之外的全部背景像素替换成同一个精确 RGB(0,255,0)，即 #00FF00。像使用
> 像素编辑器的单色填充桶一样处理整个背景：左上、右上、左下、右下、四条
> 边、漆章周围和所有空白区域逐像素完全相同。不要让场景光照、色彩渐变、
> 暗角、噪点、纹理、压缩色带、泛光、阴影、反射或半透明绿雾作用于背景。
> 物件外不得出现第二种颜色。
>
> 漆章总可见 bbox 保持 Image 3 当前折算约 `594×579px` 的比例和中心位置；
> 这已经落在允许的 `576–704px` 审查范围，四边安全距也已超过 `180px`。
> 不要试图再次接近名义 `640px` 而改变它。保留全部连体扩散，禁止新增或
> 删除波瓣、分离蜡滴、飞溅、长尾、第二滩蜡和外部接触阴影。中心罗盘＋
> 羽毛笔的方向、线重和凹痕必须完全不变。
>
> 不得新增丝带、绳结、吊坠、火焰、烟、火星、封蜡柄、邮封、皮带、外围
> 书框、页角、任务文字、按钮文字、额外徽章、金属硬币、宝石、玻璃、
> 霓虹、暗黑 3 式祭坛或照片级古董。最终自检只回答四件事：画布是否精确
> 1024×1024；漆章是否仍恰好一枚且与 Image 3 相同；物件外是否只有唯一
> RGB(0,255,0)；是否没有改动罗盘、羽毛笔与连体火漆扩散。四项必须全部是。

## 执行记录

- 日期：`2026-07-31`
- attempt 1 会话 ID：`019fb742-e6c0-7d11-b8ec-826a4975e21b`
- attempt 1 生成前仓库提交：
  `f57f792d8be4a3c21e00b65a4d65ee0006c0b680`
- 实际输入：固定 Image 1／2；SHA 与最终正文一致；未上传本地模拟或
  `assets/source/`。
- 输出：未修改原图
  `generated/quests/QUEST-SEALS/QS-A1-V1/attempt-01/raw/QS-A1-V1.r1.png`，
  SHA-256
  `d755d3f730a52a3e475062456d690c9014409496f30e87097b0e17150001602e`。
- 实际生图次数：`1/5`
- 流程错误次数：`0`
- 非阻断执行器警告：模型缓存旧字段 `supports_reasoning_summaries` 缺失、
  两个插件图标越界、模板插件默认 Prompt 数量超限、推荐插件目录响应为空；
  图片已实际生成，故不记流程错误。
- attempt 2 会话 ID：`019fb74d-e9cf-7662-bd96-245d347eea0e`
- attempt 2 生成前仓库提交：
  `a42483884724a7441d4dd8f24ca4af7400e17574`
- attempt 2 实际输入：固定 Image 1／2 加紧邻 r1 未修改原图；未上传本地
  审查派生物。
- attempt 2 输出：未修改原图
  `generated/quests/QUEST-SEALS/QS-A1-V1/attempt-02/raw/QS-A1-V1.r2.png`，
  SHA-256
  `2e856360307d69574ad8ee11f2703fe8d491fb7c3d6461fb26315497e92883cc`。
- 实际生图次数：`2/5`
- 流程错误次数：`0`
- 用户在 attempt 3 前补充：火漆印章周围增加少量火漆扩散以增强真实感。
  r3 将其限制为同一蜡体的三至五处连体受压扩散，计入既定总 bbox；不新增
  分离蜡滴、第二物件或外部承载面。
- attempt 3 会话 ID：`019fb75b-c474-7b03-9613-fe2d4eddfa71`
- attempt 3 生成前仓库提交：
  `0fb2331ad54e6d96e59a7e85a628819a8310f920`
- attempt 3 实际输入：固定 Image 1／2 加紧邻 r2 未修改原图；未上传本地
  审查派生物。
- attempt 3 输出：未修改原图
  `generated/quests/QUEST-SEALS/QS-A1-V1/attempt-03/raw/QS-A1-V1.r3.png`，
  SHA-256
  `14c4112a0ca66e23c269c31f3bb0489cf1fb5a7cb7edb62ed3f6034ab24c97ad`。
- 实际生图次数：`3/5`
- 流程错误次数：`0`
- attempt 4 会话 ID：`019fb766-ff17-7cb0-b175-0b8cd2464a76`
- attempt 4 生成前仓库提交：
  `e032522a5323f61c003fda277af5d3cd0ab13def`
- attempt 4 实际输入：固定 Image 1／2 加紧邻 r3 未修改原图；未上传本地
  审查派生物。
- attempt 4 输出：未修改原图
  `generated/quests/QUEST-SEALS/QS-A1-V1/attempt-04/raw/QS-A1-V1.r4.png`，
  SHA-256
  `3e972a67a3b27bb28b6b7ef314f0784886d4e16d3de98df022891b08571e4da1`。
- 实际生图次数：`4/5`
- 流程错误次数：`0`
- attempt 5 会话 ID：`019fb772-0f97-7603-a66f-cbf2e7f0359e`
- attempt 5 生成前仓库提交：
  `b95e2750263cadf43227f7e63a53719c9073d69a`
- attempt 5 实际输入：固定 Image 1／2 加紧邻 r4 未修改原图；未上传本地
  审查派生物。
- attempt 5 输出：未修改原图
  `generated/quests/QUEST-SEALS/QS-A1-V1/attempt-05/raw/QS-A1-V1.r5.png`，
  SHA-256
  `a672fb4c2e05e9460c04dd6839cc2be9071a207dab0f945b417769d40cc53bc4`。
- attempt 5 在图片实际生成后发生一次 responses stream 断开并自动恢复；
  最终图片存在、子进程退出 `0`，故不记流程错误，也不产生额外生图次数。
- 实际生图次数：`5/5`
- 流程错误次数：`0`
- 循环终态：`budget-exhausted / user-review-required`。不再执行生成，不
  自动接受 source，不修改 runtime。

## 审查记录

- 语义／物理：r1 只有一枚独立漆章，没有书本、纸张、文字、按钮或第二
  物件；罗盘与斜向羽毛笔语义存在，没有冒充 complete／failed 状态。
- 透视／图层：正面轻俯视和左上光向成立，自阴影基本收在物件内；未出现
  额外承载面。
- 美术一致性：`fail`。r1 为湿亮、照片级、高频蜡质和深浮雕／凸起徽记，
  高光接近白色，综合色偏鲜红；缺少香草魔兽二维手绘的宽阔色块、粗笔触和
  克制旧材质。
- 对象／状态合同：单一 base 可确定性派生四态；但中心包含外圈、多个小
  三角和过多羽毛细分，实际尺寸更像现代品牌圆 icon，尚不接受。
- 装配／尺寸：Quest Log `28px`；Tracker `34px`，三宽度公式通过。
- 真实排版：已把 r1 的确定性色键／归一化预览以真实 `26px／32px` 可见
  蜡体装配进完整 Quest Log、二十三行目录、详情、奖励、底部控件与
  十任务／十七目标 Tracker。排版图 SHA-256
  `39c920962e30543c2bf2db154c00cf8d38eea79addc336a0390d0d8988cf501f`；
  组件宽度图 SHA-256
  `e30acda2eb3bb71f64e25d18bb745a2b4c106f1433a6844c908ffa9f25e40d82`。
- 实际展示区域：机器报告 `pass`。Quest Log `[600,-18,28,28]` 与可见
  书体 Alpha 重叠为 `0`；Tracker 在 `130／230／330px` 均居中、底边接
  `y=16`、不覆盖列表，paper outset `0px`、seal 顶部 outset `18px`；
  屏幕顶缘 clamp 仍为 P5 实机 pending。
- 技术像素：`fail`。未修改原图为 `1254×1254 RGB`；色键后 bbox
  `[136,135,1117,1105]`、可见 `981×970`、四边安全距
  `136／135／137／149px`。分类背景有 `5142` 种 RGB，精确
  `#00FF00` 仅 `15` 像素；失败项为固定画布、约 `640px` bbox、
  `180px` 安全边与精确纯绿背景。物件居中和未裁边通过。
- 小尺寸：中心总轮廓尚可见，但罗盘外环、小三角和羽毛细纹在
  `28px／34px` 合并，优先读成复杂圆徽标而不是清晰浅压印工具语义。
- r2 美术一致性：`pass-near-final`。照片级高频纹理和复杂徽标已移除，
  改为宽阔二维手绘色块；四向罗盘＋斜向羽毛笔在 `28px／34px` 均清晰，
  只有外圈高光仍略偏鲜红／偏亮，需一次克制降色。
- r2 技术像素：`fail`。未修改原图仍为执行器固定的 `1254×1254 RGB`；
  色键 bbox `[291,279,962,954]`，折算到 `1024²` 为约
  `[237.63,227.83,785.56,779.02]`，可见约 `547.93×551.20px`，低于
  约 `640px` 目标；居中、安全边与未裁边通过。分类背景有 `5281` 种 RGB，
  精确 `#00FF00` 为 `0` 像素。
- r2 真实排版／展示区域：以确定性 `26px／32px` 可见蜡体装配后，完整
  Quest Log 与十任务／十七目标 Tracker 视觉清晰；排版 SHA-256
  `b88ea7c644ead7124541bc49eefd66a3a51f0e301458098ae242dc27717329d8`，
  三宽度组件图 SHA-256
  `fdb98b71ec0c59d096a1bca2c6fde1bedad1ec3d3b2d2128b1b57f93c4bfd627`。
  Quest Log 书体重叠 `0`，Tracker 三宽度均居中且不覆盖列表，机器
  `display-region pass`；屏幕顶缘 clamp 仍为 P5 实机 pending。
- 结论：`attempt-02-rejected-internal / continue / 2/5`
- r3 语义／美术：`pass-near-final`。保持单物件、二维手绘色块、浅压印
  罗盘＋羽毛笔和小尺寸辨识；新增扩散与主体连续，没有分离蜡滴。原图外围
  扩散比“增加一点”更重，右侧和底部发展成较大的波瓣，需收敛但不删除。
- r3 技术像素：`fail`。原图仍为 `1254×1254 RGB`；色键 bbox
  `[207,204,1091,1068]`，折算到 `1024²` 为约
  `[169.03,166.58,890.90,872.11]`，可见约 `721.86×705.53px`；
  左／上／右／下安全边约 `169.03／166.58／133.10／151.89px`，
  bbox 与 `180px` 安全边均失败。分类背景有 `5173` 种 RGB，精确
  `#00FF00` 为 `0` 像素；物件仍居中容差内且未裁边。
- r3 真实排版／展示区域：确定性归一化后，用户要求的扩散在
  `26px／32px` 只表现为厚重不规则轮廓，没有覆盖中心符号。完整排版
  SHA-256
  `984892b5150facfe37081f2bc97e81706f892a192ffbdabee0cf5eac504fe877`，
  三宽度组件图 SHA-256
  `b356a7a6513caa5f0743e1c5458033238643fc4b93aeb3acc154e5f1a540d8af`；
  机器 `display-region pass`，屏幕顶缘 clamp 仍为 P5 实机 pending。
- 结论：`attempt-03-rejected-internal / continue / 3/5`
- r4 语义／美术：`pass-at-runtime`。保持单一蜡章、用户指定的少量连体
  扩散、二维手绘综合色、浅压印罗盘＋羽毛笔与 `28px／34px` 可读性；
  扩散较 r3 收敛，主体重新成为主要面积，没有分离蜡滴或花边圈。
- r4 技术像素：`fail-two-provider-boundaries`。原图仍为
  `1254×1254 RGB`；色键 bbox `[274,255,1001,964]`，折算到 `1024²`
  为约 `[223.74,208.23,817.40,787.19]`，可见约
  `593.66×578.96px`。bbox 容差、四边至少 `180px`、居中、单物件与未
  裁边均通过；分类背景有 `5864` 种 RGB，精确 `#00FF00` 为 `0` 像素。
  只剩执行器固定 `1254²` 和非单色背景失败。
- r4 真实排版／展示区域：确定性 `26px／32px` 装配下视觉清晰；完整排版
  SHA-256
  `28fb8a0f69ed40200577367b367bf6eecbe758b48ac5a1a261796f104e1c4137`，
  三宽度组件图 SHA-256
  `a0e5cdd4c789116ff8c8c4ed5a3d9f09563814e18f9b5c3fac0a79b9612f3ea2`；
  机器 `display-region pass`，屏幕顶缘 clamp 仍为 P5 实机 pending。
- 结论：`attempt-04-rejected-internal / continue-final-attempt / 4/5`
- r5 语义／美术：与 r4 近似，仍保持单一蜡章、连体火漆扩散、浅压印
  罗盘＋羽毛笔、小尺寸辨识和展示区域；没有引入新物件。r5 未对推荐视觉
  产生有意义改善，综合色比 r4 略亮，故不替代 r4 为推荐审核候选。
- r5 技术像素：`fail-same-two-provider-boundaries`。原图仍为
  `1254×1254 RGB`；色键 bbox 与 r4 完全相同，为
  `[274,255,1001,964]`，折算可见约 `593.66×578.96px`。bbox 容差、
  四边安全边、居中、单物件与未裁边通过；分类背景从 r4 的 `5864` 种 RGB
  增至 `6189` 种，精确 `#00FF00` 仍为 `0` 像素。
- r5 真实排版／展示区域：完整排版 SHA-256
  `619797eeacfdb1109c439f3c3139fded88876215c50b12f8986e002d9220acf2`，
  三宽度组件图 SHA-256
  `8262b095da2e01f0fcf95b6546e74b6ee79290d9abdc52f61d51c941878ed835`；
  机器 `display-region pass`，屏幕顶缘 clamp 仍为 P5 实机 pending。
- 推荐审核候选：r4。原因是 r4 已通过视觉与运行时几何，综合色略克制，
  背景 RGB 种类也少于 r5；r5 仅证明生成器不能执行像素级填充。
- 结论：`budget-exhausted / user-review-required / 5/5`
- 用户结论与日期：V1 方向接受并要求修订位置／`2026-07-31`；
  V2 外置锚点确认／`2026-07-31`
- 用户结论：接受 r4 的运行时视觉与确定性 provider 例外；P4 source 与 P5
  runtime 已完成。下一门禁是在 Turtle WoW `1.18.1` 同时启用 pfQuest／
  pfQuest-turtle 后验证 TGA 方向、两处锚点、顶缘 clamp、旧七按钮点击／
  Tooltip、Tracker 拖动保存与 `130／230／330px` 层序；没有实机证据前不得
  进入 P6。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `QUEST-SEALS-SIM-V1` | 本地 specification、renderer、两张 `1536 × 1024` 预演与机器报告；用户于 `2026-07-31` 接受方向并指出 Quest Log 位置错误；ImageGen `0/0` | `direction-confirmed / quest-log-placement-invalidated` | 保留共享美术与 Tracker；Quest Log 不得落在翻页／书封 |
| `QUEST-SEALS-SIM-V2` | Quest Log `[600,-18,28,28]`；可见书体 Alpha 重叠 `0`；两张预演与机器报告；用户于 `2026-07-31` 回复“进行下一步”；ImageGen `0/0` | `simulation-confirmed` | 展示并独立授权 `QS-A1 V1` 最终生产合同 |
| `QS-A1 V1` | 用户于 `2026-07-31` 明确授权完整正文、固定 Image 1／2、受限同循环 Image 3 edit 与最多 `5` 次实际调用 | `prompt-authorized / 0/5` | 提交授权状态并执行 attempt 1 |
| `QS-A1 V1.r1` | 固定双输入；session `019fb742-e6c0-7d11-b8ec-826a4975e21b`；单物件与显示区域通过；原图尺寸／bbox／安全边／纯绿背景及香草手绘视觉失败；真实排版已审查 | `rejected-internal / 1/5` | r2 保留身份与符号，缩小 bbox、净化背景、改为低频二维手绘蜡面并简化浅压印 |
| `QS-A1 V1.r2` | 固定双输入＋紧邻 r1；session `019fb74d-e9cf-7662-bd96-245d347eea0e`；二维手绘与小尺寸符号显著改善，显示区域通过；折算 bbox 约 `548×551`，背景仍非纯绿，固定源尺寸仍失败；用户在 r3 前明确要求少量周围火漆扩散 | `rejected-internal / 2/5` | r3 保留 r2 核心造型与线重，总 bbox 收敛至约 `640²`，纯化背景、压低鲜红外缘，并增加三至五处连体受压扩散 |
| `QS-A1 V1.r3` | 固定双输入＋紧邻 r2；session `019fb75b-c474-7b03-9613-fe2d4eddfa71`；连体火漆扩散、小尺寸符号与显示区域通过；折算 bbox 约 `722×706`、右下扩散偏重、安全边和纯绿失败 | `rejected-internal / 3/5` | r4 整体缩小约 `10%` 并居中，保留但收敛扩散，背景强制单色 |
| `QS-A1 V1.r4` | 固定双输入＋紧邻 r3；session `019fb766-ff17-7cb0-b175-0b8cd2464a76`；视觉、bbox、安全边、小尺寸与展示区域通过；只剩固定 `1254²` 与非单色绿背景失败 | `rejected-internal / 4/5` | r5 冻结物件，只要求 `1024²` 与单一 `#00FF00` |
| `QS-A1 V1.r5` | 固定双输入＋紧邻 r4；session `019fb772-0f97-7603-a66f-cbf2e7f0359e`；bbox 与显示区域继续通过；仍为 `1254²`，背景 `6189` 种 RGB 且无精确纯绿；视觉无实质改善 | `budget-exhausted / 5/5` | 停止生成；用户审核 r4 并裁决确定性 provider 例外 |

正式生产尝试：`5/5`；流程错误：`0`；接受后新增生成：`0`；当前终态：
`runtime-exported / P5 / game-validation-pending`。

## Quest Log 承载与事务菜单 — `QUEST-LOG-SEAL-ACTIONS-SIM-V1`

### 元数据

- 日期：`2026-08-03`
- 范围：只修订 `QUEST.LOG.CHROME.SEAL` 的承载位置和 Quest Log 底部操作
  收纳；不改变 QS-A1 V1.r4 漆章母版、四态 atlas 或 Tracker 漆章。
- 子状态：`simulation-reviewed / P2 / superseded-before-confirmation`
- 操作：`simulate`
- 模拟方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；本地渲染错误：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v1.json`
- renderer：
  `tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v1.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V1/quest_log_seal_actions_board_v1.png`，SHA-256
  `e5178c74f474613e20b1ec6ec07ed4ee0ccbc83f7207e33af7cad3f2c4f9e59e`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V1/quest_log_seal_actions_report_v1.json`，SHA-256
  `125f5e40342117301b009ae1a0572f2b91be2bc98e5cd5a492695860069ae20a`。
- 用户结论：`superseded-before-confirmation / 2026-08-03`。

### 失效原因与设计裁决

- 旧盒 `[600,-18,28,28]` 虽与 SHELL Alpha 重叠为零，却没有任何承重、
  连接或悬挂结构；用户观察为“浮在任务列表右上方、在空中”。它不再是
  Quest Log 的有效最终 placement，不能仅靠 tooltip 或点击功能挽救。
- 仍保留此前“不得压在纸页、翻页、页沟、书封和包角”的限制。V1 将一块
  `48 × 44px` 短暗皮革事务签从书本右侧外沿护轨伸出，左端压在外沿结构下，
  `32 × 32px` 漆章压在伸出末端；漆章命中盒为 `40 × 40px`。这样默认态有
  清楚的物理承载，又不占用左右页阅读安全区。
- 菜单打开时，一张 `178 × 264px` 暖赭事务笺从承载皮签向书内展开。它只在
  短暂操作期间覆盖右页详情；选择动作、点击书外或按 Esc 后关闭。关闭态不
  遮挡任务列表、详情、奖励或右上 Close。
- 菜单是公会卷宗的附属事务笺，不增加第二本书、外围书框、现代悬浮卡片、
  透明黑玻璃或图标矩阵。模拟中的平面皮革、纸边和缝线只证明物件隐喻与
  综合色，最终微纹理、边缘和客户端字体栅格均非权威。

### 真实对象与交互合同

固定保留独立、不收纳：

- `QuestLogFrameCloseButton`：右上 Close 已承担关闭任务日志；不在菜单重复
  “退出”，避免两条相同路径。
- `QuestLogFrameLevelsCheckButton`、`QuestLogTrack`：继续位于左页顶部并
  保留即时状态反馈。
- `pfQuest.buttonOnline`、`pfQuest.buttonLanguage`：继续位于右页顶部；动态
  ID、语言、OnUpdate 和下拉行为不迁移。

菜单七项按原对象一一代理：

| 菜单项 | provider／原对象 | 委托规则 |
|---|---|---|
| 分享任务 | `QuestFramePushQuestButton` | 调用原 Button 点击路径；镜像 enabled |
| 收起／展开详情 | `QuestLogFrameExpandButton` | 文案跟随详情显隐；只调用原切换行为 |
| 显示任务位置 | `pfQuest.buttonShow` | 保留所选任务 ID、地图打开和原脚本 |
| 隐藏任务位置 | `pfQuest.buttonHide` | 保留原删除单任务节点行为 |
| 清理地图标记 | `pfQuest.buttonClean` | 保留原全局清理语义 |
| 重建地图标记 | `pfQuest.buttonReset` | 保留 `pfQuest:ResetAll()` 原路径 |
| 放弃任务 | `QuestLogFrameAbandonButton` | 菜单关闭后进入原生确认；不得直接执行删除 |

交互流程：

1. 常态只显示外沿事务签和 normal 漆章；左键切换菜单，hover／pressed／
   disabled 直接使用已接受 atlas 对应 cell。
2. 菜单显示时按原 Button 的 `IsEnabled()`／可用性刷新每项；disabled 使用
   退灰文字且不接收点击。菜单不缓存任务 ID、不复制 pfQuest 条件判断。
3. 点选普通项时先关闭菜单，再以原 provider Button 为行为所有者调用其
   OnClick／Click 路径；放弃继续由原生 StaticPopup 二次确认。
4. 点击书外、再次点击漆章、按 Esc、关闭 Quest Log 或任务选择刷新导致对象
   失效时关闭菜单。右键只保留给未来 Quest 模块设置入口，本轮不伪造路由。
5. fail-open 是硬门禁：只要七个代理中任一对象未捕获、pfQuest 尚未加载或
   adapter 自检失败，原底部 Button 全部继续可见可点，漆章保持无鼠标或菜单
   不晋级。只有静态测试与目标客户端逐项证明功能等价后才隐藏原控件视觉和
   命中；对象、脚本和数据本身仍保留。

### 生成前模拟与展示区域审查

- Frame 使用真实 `676 × 464`；左页 `246 × 324`、十八条 `18px` 行；右页
  `246 × 324`，四个 `108 × 32px` 奖励槽；菜单七项。邻接 UI 使用当前
  accepted QL-A1 shell 与 QS-A1 runtime normal cell。
- 关闭／打开两态均为 `100%` UI 像素。机器检查通过：四个奖励槽全部落入
  detail；关闭态漆章不进入页内安全区；皮签与右侧外沿护轨相交；菜单在基础
  Frame 内、避开 Close；`40px` 命中盒完整包含 `32px` 漆章；fail-open
  条件存在。
- 菜单与 detail 的重叠为显式、仅打开态存在的交互层，而不是展示区域错误；
  菜单关闭后右页恢复完整阅读与奖励命中。尚未验证最小屏幕边缘、真实 UI
  scale、Esc 捕获、OnClick 委托和 provider late-load，这些属于实现后 P5／
  P6 门禁。
- 内部结论：`displayable`。可据此确认承载位置、物件隐喻、菜单展开方向、
  七项分组与移除固定底部按钮后的综合色；不得据此接受最终材质像素、切片、
  动画或 runtime。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V1`
- 当前结论：`superseded-before-confirmation`。用户要求先审视火漆在书框外的
  物理语义，并进一步查看“书页间羊皮纸封签”方向；V1 不得进入 runtime。
- 后继版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V2`；菜单对象集合与 fail-open
  合同保留，承载物、位置与层序重新模拟，ImageGen 仍为 `0/0`。
- 确认失效条件：承载物从侧边皮签改为其他物件、漆章位置／尺寸发生实质变化、
  菜单改为另一方向／层级或收纳对象集合变化。

## Quest Log 羊皮纸火漆封签 — `QUEST-LOG-SEAL-ACTIONS-SIM-V2`

### 方向修订

- 用户于 `2026-08-03` 追问：火漆位于外侧书框时，是否仍应使用“火漆”概念。
  物理语义复核结论是：火漆若直接附着在书框／护轨上，没有封住任何文书，
  会退化为红色装饰按钮；V1 的短皮革事务签也仍容易被读成书框附件。
- 用户随后要求按“从书页间伸出的羊皮纸火漆封签”制作视觉展示。因此 V1
  在用户确认前被 `superseded-before-confirmation`；它的七项菜单对象集合和
  fail-open 交互合同继续沿用，但承载隐喻、位置与层序不得进入 runtime。
- V2 把火漆保留为已接受的 QS-A1 V1.r4 资产，但把它的语义收敛为封住一张
  独立任务事务签：封签根部夹在右页层间，页唇位于根部上方；窄身横跨打开的
  封皮后伸出书外；火漆只压在外露的加宽折头上，不直接接触书框、包角或书封。

### 元数据

- 日期：`2026-08-03`
- 子状态：`simulation-rejected / P2 / user-rejected`
- 操作：`simulate`
- 模拟方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v2.json`
- 复用 renderer：
  `tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v2.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V2/quest_log_seal_actions_board_v2.png`，SHA-256
  `a61ac0e3624831103cd9d1db31ffc07a0e55e21dc720b143c9c79196771c8f42`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V2/quest_log_seal_actions_report_v2.json`，SHA-256
  `082f4585bcec49244b1ac16a985177520badc6eec0b0ae166254964cc2e8ba1e`。
- 本地渲染错误：`0`；用户结论：`user-rejected / 2026-08-03`。

### 几何、层序与对象合同

- 基础 Quest Log 仍为真实 `676 × 464`；左／右 ScrollFrame、十八行任务、
  四个 `108 × 32px` 奖励槽和七项菜单代理均与 V1 相同。
- 页面出口 `page_exit=[603,190,34,38]`；封签根部由
  `page_lip=[603,190,24,36]` 覆盖；窄身
  `document_tag=[614,197,80,27]` 横跨外侧封皮并越过书体右边界；外露折头
  `tag_head=[672,189,44,44]` 承载
  `seal_visual=[678,195,32,32]`，命中盒为
  `[674,191,40,40]`。
- 固定层序：QL-A1 SHELL → 封签接触阴影 → 羊皮纸窄身／外露折头 →
  右页页唇覆盖根部 → QS-A1 漆章 → 临时事务菜单。页唇压住根部是“来自
  书页而非安装在书框”的关键可读证据。
- 关闭态只显示封签和漆章；左键后仍由 `190 × 278px` 暖赭事务笺向右页内
  展开，动作、Esc／书外关闭、原 Button proxy、禁用态镜像和放弃原生确认
  完全沿用 V1。旧按钮在功能等价前继续 fail-open。
- 封签视觉最右端到 `x=716`、程序化轮廓到约 `x=720`，相对基础 Frame 形成
  最大约 `44px` 右侧可见 outset；未来 P5 必须同时验证右侧屏幕边缘 clamp、
  UI scale、命中盒和菜单展开，不能只检查基础 Frame。

### 内部审查

- 语义／物理：`fail`，且这是第一失败门禁。用户指出预演图与描述不一致：
  人工绘制的米色“页唇”像贴片而不是真实书页遮挡；封签被分成窄身和多边形
  宽头，综合色更像固定在书框上的硬质钥匙／按钮座；火漆因此仍像安装件，
  没有可靠表达“同一张文书从页间伸出并被封住”。
- 图层／轮廓：`fail`。打开态事务菜单虽然在坐标上与封签相交，但视觉上仍
  是一张断开的矩形弹窗卡片；机器的 bbox 相交不能证明纸张连续、柔性或正确
  的上下遮挡。V2 的几何 `displayable` 结果只保留为负面证据，不得晋级。
- 美术继承：`fail-after-semantics`。暖赭纸、暗酒红蜡、深墨与旧黄铜配色
  虽然继承任务基线，但错误的硬质轮廓和弹窗语义优先于配色，仍不能视为
  香草书卷世界中的可信实体。
- 展示区域机器检查：`displayable`。四个奖励槽在 detail 内；漆章在页内
  安全区外；封签根部、页唇覆盖、越过书体右边界、漆章位于折头内、菜单位于
  Frame 内且避开 Close、`40px` 命中盒包含 `32px` 漆章和 fail-open 条件
  全部通过。
- 非权威：封签纸纤维、页唇最终边缘、折痕／磨损、菜单纸边、客户端字体、
  动画、Tooltip 和屏幕 clamp；模拟像素不得成为 source、runtime 或生产输入。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V2`
- 当前结论：`user-rejected / 2026-08-03`
- 用户结论：`user-rejected`。具体原因是视觉图没有兑现文字描述中的“根部
  夹在书页下、末端位于书框外、火漆压住封签、事务签由同一张纸展开”。
- 后继版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V3`。V3 必须复用真实 QL-A1 shell
  页缘像素建立遮挡，删除独立多边形宽头／按钮座，并让打开态成为一张连续
  羊皮纸；QS-A1 漆章与七项代理／fail-open 合同不变，ImageGen 仍为 `0/0`。

## Quest Log 书页夹层火漆封签 — `QUEST-LOG-SEAL-ACTIONS-SIM-V3`

### 方向修订

- V3 只修复 V2 的第一失败门禁，不扩大功能范围：QS-A1 V1.r4 漆章、七项
  provider 代理、关闭条件、放弃确认和 fail-open 合同全部冻结。
- 封签改为一个 `document_tag_polygon`，从根部到书外末端都是同一张柔性
  羊皮纸；删除 V2 独立绘制的窄身／宽头二段结构和任何按钮座。纸边以低频
  起伏和两条纵向折痕表达弯曲，漆章直接压在同一纸面的外露末端。
- 根部遮挡不再用程序化米色贴片。renderer 从已接受 QL-A1 shell 的相同
  `676 × 464` UV 中重新采样右页边缘像素，只用不规则 page-lip mask 把原图
  像素压回封签根部上方，因此页面、书口和封皮保持原有层次与材质连续性。
- 展开态先绘制一张向右页内摊开的不规则事务签，再在其连接端绘制同一封签
  与漆章。事务签右侧纸尖与封签相交，标题也是纸上折带，不使用独立皮革标题
  栏或现代浮动卡片底板。关闭态仍只显示短封签和火漆。

### 元数据

- 日期：`2026-08-03`
- 子状态：`simulation-rejected / P2 / user-rejected`
- 操作：`simulate`
- 模拟方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v3.json`
- renderer：
  `tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v3.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V3/quest_log_seal_actions_board_v3.png`，SHA-256
  `86642cfdfaeae0326bc7917769b34f7de2b063cc272dce3d879b6be33ef71310`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V3/quest_log_seal_actions_report_v3.json`，SHA-256
  `aec599e88fafb01b317354708b9c43f5fa2872de6c0ec4e24e767e9c39c547ae`。
- 本地渲染错误：`0`；用户结论：`user-rejected / 2026-08-03`。

### 几何、层序与对象合同

- 基础 Frame、十八条任务行、右页详情、四个奖励槽和七项菜单代理继续使用
  V2 的真实密度。封签总包围盒
  `document_tag_bbox=[608,184,112,50]`，其中
  `tag_root_box=[608,184,27,27]` 完全位于
  `page_lip_source_box=[598,176,39,54]` 内；纸身越过基础 Frame 的
  `x=676` 右边界并终止于约 `x=720`。
- 原 shell 页缘像素按不规则 mask 回贴到根部上方；固定层序为 QL-A1 SHELL
  → 事务签展开纸面（仅打开态）→ 单张封签接触阴影／纸面 → 原 shell 页缘
  像素覆盖根部 → QS-A1 漆章。不得把页缘另做一块米色 patch。
- `seal_visual=[684,196,32,32]` 由
  `seal_hitbox=[680,192,40,40]` 包含并落在同一纸张末端；不存在独立宽头
  component。菜单主体为 `[438,80,218,300]`，通过
  `menu_connection_box=[650,184,42,48]` 同时与菜单纸面和封签包围盒相交。
- 预演在整本书两态下方附带两个局部放大窗：C 专门审查原 shell 页缘像素
  是否压住根部；D 专门审查事务签、封签和火漆是否读成一个连续实体。放大窗
  只用于理解层序，不是 source、runtime 或生产 edit 输入。

### 内部审查

- 语义／物理：`fail`，且这是第一失败门禁。用户澄清“从右页下方伸出”指
  detail 右页的空间下缘，封签应像书签一样竖着夹入；V3 却仍从右页右侧中段
  横向伸出。真实页缘遮挡和单张纸连续性虽较 V2 正确，但不能补救错误方位。
- 连续性／层序：`pass-as-negative-evidence`。V3 证明真实 shell 像素可用于
  根部遮挡，也证明菜单可和封签使用同一纸面；这些技术只允许转译到 V4，
  横向位置、右侧 outset 和侧向展开不得保留。
- 展示区域：`displayable`。报告确认 page-lip source 位于 shell、根部完全
  位于遮挡区、封签越过书体、漆章位于末端、menu connection 同时与纸面／
  封签相交、四奖励槽和菜单仍在基础 Frame 安全合同内、Close 未被覆盖、
  `40px` 命中盒包含 `32px` 漆章且 fail-open 保留。
- 非权威：最终羊皮纸纤维、手绘折痕、page-lip runtime UV／mask 细节、菜单
  纸边、动画、Tooltip、客户端字体和屏幕右缘 clamp。模拟像素不得进入
  `assets/source/`、addon runtime 或正式生产输入。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V3`
- 当前结论：`user-rejected / 2026-08-03`
- 用户结论：`user-rejected`。用户明确要求根部位于 detail 板块下部、书签
  竖着卡入，而不是从右页外侧横向伸出。
- 后继版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V4`。保留真实 shell 像素遮挡、
  单张柔性羊皮纸、QS-A1 漆章、七项代理和 fail-open；把根部移到所有奖励
  之后的右页下缘，长轴改为竖直，末端越过底框，事务签由下向上展开。

## Quest Log 右页下缘竖向火漆书签 — `QUEST-LOG-SEAL-ACTIONS-SIM-V4`

### 方向修订

- V4 按用户对空间方位的明确解释重建封签：根部不再位于右页外侧中段，而是
  竖直夹在 detail 右页下缘与书封之间；窄身向下经过书封／底框，外露末端
  完全位于基础书体下方，形成常见任务书签的重力方向。
- 整体仍是一个连续 `document_tag_polygon`。末端只是同一纸张自然变宽并
  承受 QS-A1 漆章，不存在额外按钮座、金属承托或固定在书框上的铆接结构。
- 关闭态继续从已接受 QL-A1 shell 的相同 UV 采样真实下页缘像素覆盖根部；
  打开态表示用户从火漆末端把事务签向上抽出／摊到右页，纸面由下向上连续
  扩宽，底部折线回到竖向书签，不从右侧弹出独立卡片。
- 第一次内部 V4 渲染暴露 page-lip mask 覆盖第四个动态奖励槽。该图没有对外
  提交；最终 specification 把根部下移至四个奖励之后，并新增“页缘遮挡不得
  与任一奖励槽相交”的机器门禁。这是模拟视觉修复，不是 ImageGen 调用。

### 元数据

- 日期：`2026-08-03`
- 子状态：`simulation-rejected / P2 / user-rejected`
- 操作：`simulate`
- 模拟方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v4.json`
- renderer：
  `tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v4.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V4/quest_log_seal_actions_board_v4.png`，SHA-256
  `386d625e67c1a0eae6dfda07cc7c4213d65aa992c91ab1f25752311a5b7ecd20`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V4/quest_log_seal_actions_report_v4.json`，SHA-256
  `874f240d5eaf12bb47fbe2db9428372897288068880d6ff6568471674d3241c7`。
- 本地渲染错误：`0`；内部视觉修复：`1`；用户结论：`user-rejected / 2026-08-03`。

### 几何、层序与对象合同

- 基础 Quest Log 仍为真实 `676 × 464`；左页十八行、右页详情、四个
  `108 × 32px` 奖励槽和七项菜单代理全部保留。
- 竖向书签包围盒
  `document_tag_bbox=[529,385,50,125]`；根部
  `tag_root_box=[540,385,26,25]` 完全位于
  `page_lip_source_box=[512,384,88,38]`，并从 `y=385` 开始，晚于最下奖励
  槽的排他底边 `y=384`。书签越过基础 Frame 的 `y=464` 底边，最末到
  `y=510`，形成 `46px` 下侧可见 outset。
- `seal_visual=[537,474,32,32]` 完全位于书本底框之外，并由
  `seal_hitbox=[533,470,40,40]` 包含。它落在同一纸张的自然末端，不压住
  金属底框、皮革书封、翻页区域、正文或奖励。
- 打开态事务签为 `[380,72,218,326]`，覆盖右页详情是暂时交互层；通过
  `menu_connection_box=[532,382,41,48]` 与竖向书签相交，并沿下页缘折线
  向上展开。关闭态真实 page-lip 覆盖根部；打开态用折线表达纸张已被抽到
  页面上方，不使用侧向弹窗。
- 预演下方 C／D 分别放大关闭态右页下缘夹入关系，以及打开态从下向上的
  连续连接。放大图和全部模拟像素均不可成为 source、runtime 或生产输入。

### 内部审查

- 语义／物理：`fail-after-direction-fix`。根部方位和竖向结构已经正确，
  但为了让漆章完全越过数值 Frame，书签从页缘到末端被拉得过长，用户明确
  评价为“太长、太难看”；它读成吊坠而不是短任务书签。
- 动态内容／层序：`pass-for-simulation`。最终 page-lip source 与四个奖励
  槽均不相交，根部位于全部奖励之后；关闭态不会截断奖励，打开态的覆盖是
  有意且可关闭的菜单层。Close、等级、追踪、在线和语言仍独立。
- 连续性／层级：`fail`，且这是第二个用户明确失败点。打开态虽在几何上与
  书签相连，却新增一张覆盖大半右页的独立纸面，导致原 detail 页、书页边缘
  和书签之间的图层关系改变，综合色突兀、不和谐。bbox 连接不能证明层级
  延续；V4 的二级纸面不得进入 runtime。
- 展示区域：`displayable`。报告同时通过真实 page-lip source、根部包含、
  奖励避让、向下越过 Frame、竖向比例、漆章末端、菜单连接、Close 避让、
  `40px` 命中盒、七项动作和 fail-open 检查。
- 非权威：最终羊皮纸纤维、重力弯曲、手绘折痕、page-lip runtime UV／mask
  微调、动画、Tooltip、客户端字体、底部屏幕 clamp 和真实点击行为。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V4`
- 当前结论：`user-rejected / 2026-08-03`
- 用户结论：`user-rejected`。书签过长、难看；点击后的二级页面改变图层关系，
  与原书本非常不和谐。
- 后继版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V5`。根部方位、真实 shell 遮挡、
  QS-A1 漆章、七项代理和 fail-open 保留；可见书签收短，菜单改为原 detail
  书页上的内容模式切换，禁止新增第二张纸、浮层阴影或额外页面边界。

## Quest Log 短火漆书签与同页事务模式 — `QUEST-LOG-SEAL-ACTIONS-SIM-V5`

### 方向修订

- V5 冻结 V4 已正确的下缘竖向锚点，但把书签从
  `document_tag_bbox=[529,385,50,125]` 收敛为
  `document_tag_bbox=[546,390,46,78]`。相对实际可见书本底边约 `y=432`，
  关闭态露出约 `36px` 纸张与漆章；不再为了越过透明 Frame 边界制造长吊坠。
- QS-A1 漆章仍完整落在同一羊皮纸的自然末端。书签略微覆盖可见底框只是
  穿过书页／书封的空间路径，漆章没有直接压在金属或皮革上；纸张轮廓完整
  包住蜡面，默认态始终有实体支撑和明确焦点。
- 点击后不再“弹出二级页面”。renderer 先用已接受 QL-A1 shell 的原
  `detail=[366,64,246,324]` UV 恢复同一张空白右页，再把七项事务以动态墨字
  写在原页面上。书本外壳、纸张纹理、页边、阴影、z-order 和 Frame 全部
  不变；这是一种 detail 内容模式切换，不是新增纸张或浮层。
- 再次点击火漆、点击书外或 Esc 后恢复正常任务详情。provider Button 仍是
  行为所有者；在七项代理全部等价前，旧按钮继续 fail-open。

### 元数据

- 日期：`2026-08-03`
- 子状态：`simulation-rejected / P2 / user-rejected`
- 操作：`simulate`
- 模拟方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v5.json`
- renderer：
  `tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v5.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V5/quest_log_seal_actions_board_v5.png`，SHA-256
  `ef4010a3b6d36350f5bb231cfac5df1fd96e4630a00639f15e586ff765421961`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V5/quest_log_seal_actions_report_v5.json`，SHA-256
  `fc62895116ad8d0b5ea1f769e1a3afed681d33b6252210dcc01ed317c59ca9ff`。
- 本地渲染错误：`0`；用户结论：`user-rejected`。

### 几何、层序与对象合同

- 基础 Quest Log、十八任务行、详情区、四个奖励槽和七项 provider 代理不变。
  书签根部 `tag_root_box=[555,390,26,20]` 完全位于真实下页缘采样区
  `page_lip_source_box=[530,384,72,30]`，并晚于最下奖励槽的排他底边
  `y=384`；关闭态不会截断任何动态奖励。
- 短书签总高 `78px`，相对 V4 减少 `47px`；综合色可见长度约 `60px`。
  `seal_visual=[554,434,32,32]` 位于
  `tag_head=[546,430,46,38]` 内，`40 × 40px` 命中盒完整包含漆章。
- 同页事务模式严格复用 `menu=[366,64,246,324]`，且该盒与原 detail 完全
  相等。renderer 不绘制第二层 PAPER polygon、阴影、外框或独立标题底板；
  只清除／恢复该页动态内容并绘制标题、分组线和七项墨字。
- 层序固定为 QL-A1 shell → 当前 detail 或同页事务动态内容 → 真实 shell
  下页缘覆盖书签根部 → 短书签／QS-A1 漆章。两种状态只交换动态内容，不改变
  外壳、纸面或装饰层。

### 内部审查

- 语义／比例：`pass-for-simulation`。短书签仍从 detail 下缘竖着夹入，
  但不再形成长吊坠；漆章有完整纸面承托，并只略微越过实际可见书框。
- 图层／综合色：`pass-for-simulation`。打开态保持原右页材质、轮廓、阴影
  和外壳，事务项直接成为该页动态内容；没有第二张纸或突然改变 z-order，
  左右页视觉重量保持稳定。
- 动态内容：`pass-for-simulation`。关闭态四奖励槽完整；打开态是有意的
  detail mode replacement，关闭后恢复原详情。Close、等级、追踪、在线与
  语言继续独立，七项行为继续委托原 Button。
- 展示区域：`displayable`。报告通过真实 page-lip source、奖励避让、短长度、
  越过可见书本底边、漆章承托、menu 与 detail 完全相等、无二级纸面、竖向
  比例、命中盒和 fail-open 检查。
- 非权威：最终纸纤维、短书签重力弯曲、同页内容切换动画、客户端字体栅格、
  Tooltip、屏幕底缘 clamp 和真实点击／焦点恢复。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V5`
- 当前结论：`user-rejected`
- 用户指出 detail 不应变成二级功能页面，并要求重新设计二级交互；随后明确
  指定火漆直接印在详情页右上角书页上。V5 的短书签和 detail 内容替换均不再
  作为后继方向；QS-A1 source／atlas 不受影响。

## Quest Log 包角漆章与下沿事务轨 — `QUEST-LOG-SEAL-ACTIONS-SIM-V6`

- 日期：`2026-08-03`
- 子状态：`simulation-rejected / P2 / user-redirected-before-review`
- 操作：`simulate`；方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v6.json`
- renderer：`tools/render_quest_log_seal_actions_simulation_v1.py`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V6/quest_log_seal_actions_board_v6.png`，SHA-256
  `fcc62bf3eca59e660649ca57adac6843662c77f454d9c910a5eb71b7762f8f3d`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V6/quest_log_seal_actions_report_v6.json`，SHA-256
  `56788f4374ece88a1e758b226bb2317b9e7523ee5a013b3ca89d921bd2f109f3`。
- V6 先证明右页连续纸面四边余量不足以在完全不调整标题／正文的前提下容纳
  `40×40px` 固定命中盒，继而用真实右下黄铜包角与底部事务轨作备选。用户在
  候选展示前即明确改向：漆章应直接印在详情页右上角书页上，功能也不应在
  底部展示。因此 V6 不进入 runtime、不创建 source，也不成为后续美术权威。

## Quest Log 详情页右上火漆与右侧事务列 — `QUEST-LOG-SEAL-ACTIONS-SIM-V7`

### 当前方向

- QS-A1 漆章直接压在详情页右上角连续纸面，不使用书签、黄铜包角、皮革封面
  或任何独立承托。`seal_visual=[576,68,32,32]`；可点击保留区
  `[572,64,40,40]`。
- 原 `detail=[366,64,246,324]` ScrollFrame 尺寸、对象和滚动行为不变。
  标题安全区收为 `[376,72,188,28]`，分隔线止于 `x=560`，只为右上漆章
  留出稳定空间。
- 点击后七项 provider 代理作为七个独立 Button，在右页右侧
  `right_action_menu=[488,108,124,186]` 纵向展开。事务列会临时覆盖右侧
  部分正文，但不会替换、隐藏或重排 detail；末端 `y=294`，早于首行奖励
  `y=316`。
- 再次点击漆章、点选任一动作、点击书外或 Esc 收起。原 Button 始终是行为
  所有者；放弃仍走原生确认，禁用态镜像 provider，全部代理等价前保持
  fail-open。

### 元数据

- 日期：`2026-08-03`
- 子状态：`simulation-rejected / P2 / user-rejected`
- 操作：`simulate`；方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v7.json`
- renderer：`tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v7.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V7/quest_log_seal_actions_board_v7.png`，SHA-256
  `ec69f8112ae451c39b07910c8483fe705024b55c7ceef90cce18ae459167d41d`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V7/quest_log_seal_actions_report_v7.json`，SHA-256
  `e98e721e8d2005a765bde8ec95cc0576ed1c8cf092bd19285ff27de9dd1e741f`。
- 本地渲染错误：`0`；用户结论：`user-rejected`。

### 内部审查与展示区域

- `displayable`：报告通过 `676×464` Frame、18 行、4 奖励槽、右上
  `40×40px` 保留区、标题避让、七 Button 均在右页内、事务列从漆章下方
  起始、`y<316` 奖励避让、Close 避让、命中包含和 fail-open 检查。
- 打开态与 detail 的重叠是显式临时交互遮挡，不是内容替换：底层详情对象、
  ScrollChild 高度、滚动位置、奖励和 shell 均保持。事务列收起后不需要重建
  详情。
- 非权威：最终蜡／纸接触阴影、七按钮四态、按钮微纹理、展开动画、Tooltip、
  客户端字体栅格和真实焦点恢复。模拟像素不得成为 source／runtime 或生产
  ImageGen 输入。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V7`
- 当前结论：`user-rejected`
- 用户保留“漆章印在详情页右上”的位置，但明确否决功能占据书页空间；七项
  功能必须从书页右边外侧展开。V7 的页内事务列不进入 runtime，也不成为
  后续资产权威。

## Quest Log 详情页火漆与外侧卷宗索引签 — `QUEST-LOG-SEAL-ACTIONS-SIM-V8`

### 方案定义

- 火漆位置继承用户明确接受的方位：`seal_visual=[576,68,32,32]` 直接压在
  详情页右上连续纸面，命中／保留区 `[572,64,40,40]`。不创建书签、包角
  或其他承托。
- 七项功能不是一整块弹窗，而是七个独立“卷宗索引签” Button；综合色为暗
  胡桃旧皮革、克制旧黄铜和暖色动态文字，放弃任务使用单独暗酒红危险边。
- 每条从 detail 排他右边界 `x=612` 开始向书外伸出；整体
  `exterior_action_menu=[612,108,136,186]`。它与
  `detail=[366,64,246,324]` 只在边界相切，零面积重叠；四个奖励槽同样零
  重叠。
- `page_edge_mask=[604,96,24,210]` 从已接受 QL-A1 shell 复用真实页边像素，
  晚于按钮背景重新覆盖七条根部；各文字安全区从 `x=632` 起，不受 mask
  遮挡。展开态因此读取为“夹在页边的卷宗索引签”，不是悬浮在书旁。
- 菜单最右到 `x=748`，相对基础 Frame `676px` 产生 `72px` 右侧 outset。
  若屏幕右侧不足，运行时只把整个 Quest Log 按缺口向左平移并记录原锚点；
  收起后精确恢复，不向页内翻折，也不切换到左侧。

### 元数据

- 日期：`2026-08-03`
- 子状态：`simulation-rejected / P2 / user-rejected`
- 操作：`simulate`；方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v8.json`
- renderer：`tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v8.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V8/quest_log_seal_actions_board_v8.png`，SHA-256
  `928714893d9f3234dfea7cc497f95f666bd03e2f37aa309862754a41c3ea9279`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V8/quest_log_seal_actions_report_v8.json`，SHA-256
  `72e001d2ed5bff88ca0fd39e763aa457fdeae33b92ece9dd08f5a404c62b62fd`。
- 本地渲染错误：`0`；用户结论：`user-rejected / 2026-08-03`。

### 内部审查与展示区域

- `displayable`：报告通过 `676×464` 基础 Frame、`72px` 右侧 outset、18 行、
  4 奖励槽、右上火漆、七个 Button、七个文字安全区、真实页边 root mask、
  detail／奖励零重叠、Close 避让、命中包含和 fail-open 检查。
- 层序固定为 QL-A1 shell → detail／奖励 → 外侧索引签 Button → 复用的真实
  页边 mask → QS-A1 火漆。mask 只遮 Button 根部，不覆盖文字或命中主体。
- 非权威：最终索引签材质笔触、Button 四态、黄铜铆点、交错滑出动画、屏幕
  clamp、Tooltip、客户端字体栅格和真实焦点恢复。模拟像素不得成为 source、
  runtime 或生产 ImageGen 输入。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V8`
- 当前结论：`user-rejected`
- 用户反馈：`再克制一点`。外侧展开、页边遮根和零正文占用继续成立，但七条
  `136×24px` 尖头签、逐项亮黄铜铆钉／高光、整条酒红危险项和 `72px`
  外伸在整本任务书上形成过强的徽章列节奏。V8 不进入 runtime。

## Quest Log 详情页火漆与克制型书口事务签 — `QUEST-LOG-SEAL-ACTIONS-SIM-V9`

### 方案定义

- 冻结 V8 已正确的结构：火漆仍为 `[576,68,32,32]`，直接压在详情页右上
  连续纸面；七项仍是七个独立 provider 代理 Button，从 detail 排他右边界
  `x=612` 向书外伸出；真实 QL-A1 页边像素晚于按钮重新覆盖根部，正文、
  ScrollFrame 与四个奖励槽均不被占用。
- 只收敛视觉重量：每条从 `136×24px` 降为 `112×20px`；整体菜单改为
  `exterior_action_menu=[612,112,112,158]`，相对基础 Frame 的书外伸出从
  `72px` 降为 `48px`。共享／详情、四项地图事务、放弃之间分别保留 `3px`
  小分组间距，其余只留 `2px`，不再形成连续厚重按钮墙。
- 轮廓改为短、近矩形、外端仅轻微削角的书口事务签；取消箭头尖端、逐项
  铆钉和明亮顶部黄铜高光。综合色仅保留低饱和暗胡桃旧皮革、低对比旧铜色
  边线和暖旧文字。放弃任务与其他签共用同一暗皮革底，只以克制酒红文字／
  边线表达危险，不整条染红。
- 交互和 fail-open 不变：左键开关；选择／书外点击／Esc 收起；每项只代理
  原 Button 并镜像 enabled；放弃继续走原生确认；七项等价前旧按钮继续显示。

### 元数据

- 日期：`2026-08-03`
- 子状态：`simulation-confirmed / P2 / awaiting-production-authorization`
- 操作：`simulate`；方式：`deterministic-local-geometry`
- ImageGen：`0/0`；上传：无；新增 bitmap source/runtime：`0`
- Python：macOS `conda run -n py312 python`；实际解释器
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，`3.12.12`
- specification：
  `tools/specs/quest_log_seal_actions_simulation_v9.json`
- renderer：`tools/render_quest_log_seal_actions_simulation_v1.py`
- 命令：
  `conda run -n py312 python tools/render_quest_log_seal_actions_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v9.json --repo-root .`
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V9/quest_log_seal_actions_board_v9.png`，SHA-256
  `d639e13a539942550c34e1cc2400b9b11c5374279be606324f09fe57bea6d839`。
- report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V9/quest_log_seal_actions_report_v9.json`，SHA-256
  `58ddce681b587a7124e856b227b0929f771fc50c2c17a80994bfe4cb9f7c4718`。
- 本地渲染错误：`0`；用户结论：`confirmed / 2026-08-03`。

### 内部审查与展示区域

- `displayable`：机器报告 `25/25` 通过。`676×464` 基础 Frame、18 行、
  4 奖励槽、右上火漆、七个 Button／文字安全区、页边 root mask、detail／
  奖励零重叠、Close 避让、命中包含、`48px` right outset 和 fail-open 均成立。
- 视觉内审：`pass-for-user-review`。相较 V8，单条面积减少约 `31.4%`，外伸
  减少 `33.3%`，纵向总高减少约 `15.1%`；正常态没有箭头、铆钉或亮铜高光，
  放弃项只留低饱和酒红提示。七项仍清楚可读，但第一视觉焦点重新回到书页和
  火漆，而不是右侧按钮列。
- 层序仍为 QL-A1 shell → detail／奖励 → 七个短事务签 Button → 真实页边
  mask → QS-A1 火漆。`page_edge_mask=[604,102,24,180]` 遮住每条根部且不
  进入 `action_text_safe`。
- 非权威：最终旧皮革笔触、Button 四态、短距交错滑出、屏幕右缘 clamp、
  Tooltip、客户端字体栅格和真实焦点恢复。模拟像素不得成为 source、runtime
  或正式生产输入。

### 用户方向结论

- 具体模拟版本：`QUEST-LOG-SEAL-ACTIONS-SIM-V9`
- 用户结论与日期：`confirmed / 2026-08-03`；用户回复“进入下一步”。
- 已确认并写回生产正文：`32px` 漆章直接压在详情页右上连续纸面；七个
  `112×20px` 独立 Button 从 `x=612` 向书外展开；两处 `3px` 轻分组间距；
  整体只产生 `48px` 右侧 outset；真实页边遮住每条左侧 `16px` 根部；正文、
  ScrollFrame 与奖励零占用；无尖头、逐项铆钉、明亮顶部高光或整条危险色；
  普通项使用低饱和暗胡桃旧皮革／低对比氧化旧铜边，放弃项只以克制酒红
  文字和一像素边缘提示危险。
- 确认未接受：模拟像素、最终笔触、Alpha、切片、客户端字体栅格、Tooltip、
  动画或屏幕 clamp 实现。模拟图不得成为正式生产输入。
- 下一门禁：先提交 `QS-B1 V1` 已授权正文与冻结边界，再按固定执行器进行
  attempt 1。候选通过并经用户接受前不实现菜单、不隐藏旧按钮。

### `2026-08-04` runtime `1.18` 页上位置修复

- 另一台设备报告“详情没有火漆”；远端审计同时确认默认 `origin/main` 仍停在
  Quests runtime `1.16`／Theme `1.5`，没有当前分支的字体、详情和 V9 页上位置。
- 根据已确认的 V9 几何，runtime `1.18` 直接复用 accepted QS-A1 atlas，把
  无鼠标 Texture 从旧悬空 `[600,-18,28,28]` 移到详情页纸面
  `[576,68,32,32]`；没有新增、修图或重新解释美术资产，ImageGen `0/0`。
- 这次只解耦视觉 placement，不预先实现 QS-B1：漆章仍不接收鼠标，七项事务签
  尚不存在，底部与 pfQuest 原 Button 全部保持 fail-open。
- `/aeui status` 现在报告实际 Quest frame／theme／seal／font／detail scroll
  range；当前测试设备必须先确认 `quest frame=1.19 theme=1.7 seal=detail-page-32`，
  再判断 P5 的三项视觉修复是否生效。

## Quest Log 克制型书口事务签 — `QS-B1 V1`

### 元数据

- 方向确认日期：`2026-08-03`
- 正式生产授权：`2026-08-05`
- 组件：`QUEST.LOG.ACTION.SEAL_MENU.TAB.BASE`
- 子状态：`attempt-01-rejected-internal / repair-prepared`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 操作：`generate / bounded edit`；当前实际 ImageGen：`1/5`
- 生成前模拟：`QUEST-LOG-SEAL-ACTIONS-SIM-V9`，本地确定性几何，ImageGen
  `0/0`；board／report SHA 见上节。
- 多执行正文最坏实际生图数：`5`；流程错误不占生图额度。
- Image 1（最高视觉权威）：
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`，SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
- Image 2（受限邻接参考）：
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`，SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
- planned accepted source：
  `assets/source/quests/qs-b1/QuestLogActionTab_Master_v1.png`；当前不存在。
- planned runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogActionTabStatesV1.tga`；
  当前不存在。

### 美术基准继承与冲突裁决

权威顺序固定为：Image 1 与任务基线 Prompt →
`SUBMODULE_ART_BASELINES.md`／`ART_BASELINE.md` →
`GLOBAL_ART_BASELINE.md` → 真实组件合同 → 仅承担邻接色温与尺度的 Image 2。
Image 2 是已接受的派生空书母版，不能反向覆盖 Image 1 的香草年代、二维手绘
笔触或反模式。

- 从 Image 1 继承：2004 年前后香草魔兽低分辨率二维手绘语言、左上短暖光、
  大块明暗切面、低饱和暖综合色、暗胡桃皮革与暗哑氧化黄铜的材料关系，以及
  少量集中在外缘的磨损。
- 从 Image 1 明确忽略：完整双页书、纸页、长皮带牌匾、指南针、蜡封、书签、
  黄铜包角、铆钉、文字、按钮列及任何完整布局。
- 从 Image 2 只继承：当前 runtime 相邻书体的暗胡桃色温、边缘软硬、绘制
  精度、左上光向与磨损尺度。
- 从 Image 2 明确忽略：完整书形、纸页、装订、页沟、针脚、包角、透明背景
  与任何可直接裁切的现成像素。
- 冲突裁决：V9 的“克制、短、近矩形”高于参考图中的长皮带、尖头书签和亮金
  装饰；旧铜只能形成低对比、不连续的装订边迹，不能形成现代细金框或独立
  金属牌。若两图产生冲突，以 Image 1＋任务／全局基线为美术权威，Image 2
  仅用于邻接匹配。

### 组件、状态与装配合同

- 生成对象只有 `1` 个：无字、无图标的短横向旧皮革书口事务签母版。七项
  provider 行为共享这一物件身份与固定几何，因此不重复生成七张近同图；
  runtime 仍必须创建七个独立 Button，不能把整列菜单烘焙成一张背景。
- 七个真实代理顺序固定为：
  `QuestFramePushQuestButton`、`QuestLogFrameExpandButton`、
  `pfQuest.buttonShow`、`pfQuest.buttonHide`、`pfQuest.buttonClean`、
  `pfQuest.buttonReset`、`QuestLogFrameAbandonButton`。动态中文标签、enabled、
  Tooltip、detail 开合文本和放弃确认全部由 runtime／原 provider 持有。
- 每个 Button 的可见／命中盒固定为 `112×20px`；七个槽固定为
  `[612,112,112,20]`、`[612,134,112,20]`、`[612,159,112,20]`、
  `[612,181,112,20]`、`[612,203,112,20]`、`[612,225,112,20]`、
  `[612,250,112,20]`。菜单包络为 `[612,112,112,158]`，基础 Frame
  `676×464`，书外 outset `48px`。
- 单条相对文字安全区为 `[18,1,80,18]`（`xywh`）；左侧 `16px` 是被真实
  页边遮住的安静根部，最右约 `6px` 只承担轻微削角和外缘磨损。任何文字、
  图标或识别装饰都不得进入源资产。
- 层序固定：QL-A1 shell → detail／奖励 → 七个 Button Texture → 无鼠标的
  QL-A1 真实页边 mask `[604,102,24,180]` → 已接受 QS-A1 漆章 Button。
  mask 复用现有 shell 像素，不生产新的 ImageGen 资产。
- 收起态只显示漆章；展开态显示七个 Button。点击动作、点击书外或 Esc 收起；
  disabled 镜像 provider；放弃继续走原生确认。右键只保留为未来配置入口，
  本批不实现新业务逻辑。
- 任一 provider 未捕获、状态无法镜像或 atlas 缺失时，全部旧按钮保持可见
  可用，事务菜单不接管鼠标；只有七项功能等价同时成立后才隐藏 fallback。
- 右缘不足时，展开态按 `max(0, frameRight + 48 - (screenRight - 8))` 的
  UI 像素短缺量整体左移任务书，收起后恢复原锚点；不得只压缩事务签、覆盖
  书页或把按钮翻到左侧。

### 源画布、确定性导出与状态合同

- raw 目标为精确 `1024×1024 RGB`、单一均匀 `#00FF00` 背景；可见母版目标
  bbox 为 `[120,442,904,582]`，即 `784×140px`、比例 `5.6:1`，水平无旋转。
  允许内部审查的 raw 可见比例范围仅为 `5.45..5.75`，且四边不得裁切。
- 色键只从画布边缘做连通背景提取；不得删除物件内部像素。透明 RGB 清零后，
  在不改变比例、不重绘、不补结构的前提下，把合格 bbox 等比 fit 到
  `784×140px` 安全盒并居中到上述位置。该确定性步骤只解决背景和装配，不得
  把语义、轮廓或材料失败伪装成通过。
- accepted source 计划为 `1024×1024 RGBA`。runtime exporter 从其可见母版
  等比缩小到不超过 `112×20px`，居中放入八个 `128×32px` cell；atlas 为
  `1024×32`，cell 顺序固定为：standard normal／hover／pressed／disabled，
  danger normal／hover／pressed／disabled。每格可见安全盒为
  `[cellX+8,6,112,20]`（`xywh`）。
- 四态保持同一 Alpha／轮廓：normal 使用母版；hover 只轻微暖亮；pressed
  只压暗，文字与 Texture 在 runtime 同步向右下 `1px`；disabled 只退灰降
  对比。danger 四态保持同一暗皮革底，只把 Alpha 内缘的一像素短边迹改为
  低饱和暗酒红，并由 runtime 使用同族酒红文字；不得整条染红。
- 固定 `112×20px` 使用，不做九宫格、横向拉伸、平铺、重复、镜像或非等比
  缩放。八格透明 padding 不进入 UV 采样；每个 Button 只采样本格
  `[cellX+8,6,cellX+120,26]` 的 `112×20px` 可见矩形，格间 padding 只防止
  纹理过滤串色。
- 候选审查必须用最终候选确定性重组临时八态 atlas，并在 `676×464` 当前
  accepted/runtime Quest Log 上以 18 行、代表性长中文详情、四个奖励槽、
  七个真实标签和 normal／hover／pressed／disabled／danger 分布做 100%
  UI 像素预演；必须同时复核 closed/open、右缘 8px clamp、detail／reward
  零覆盖、页边遮根和七个命中盒。稀疏 contact sheet 不构成通过证据。

### 生产正文完整性预检

- 复杂度：`single-object source + deterministic 8-state atlas + 7 runtime Buttons`
- 结论：`pass`

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、数量、runtime 所有权与动态内容排除 | exactly one reusable leather docket tab；七 Button／八态由 runtime 与 exporter 持有；无字无图标 | pass |
| Image 1／2 inherit、ignore 与权威冲突 | 分别声明最高美术职责、受限邻接职责、忽略项与冲突顺序 | pass |
| Canvas、bbox、方向、尺度、光照与遮根关系 | `1024²`、`784×140`、水平正投影、左上暖光、左根／右端职责 | pass |
| 解剖、材料、轮廓、状态与关系 | 近矩形浅削角暗胡桃旧皮革、不连续旧铜边迹；状态确定性派生 | pass |
| 文字安全区、crop、stretch、repeat、seam | 相对 `[18,1,80,18]`、左 `16px` 遮根、固定 `112×20`、禁止拉伸／平铺 | pass |
| 美术 DNA、反模式、色键与最终自检 | 香草二维手绘、具体禁止项、`#00FF00`、object-count／bbox 自检 | pass |

- 未知但执行必需的值：`无`。
- 去冗余结论：只在开头、禁止项和最终自检重复单物件／无文字／无尖头／
  `784×140` 四个最高风险门禁；Git 历史与模拟过程不进入执行正文。

### 最终执行正文 — `QS-B1 V1`

Create one isolated 2D hand-painted bitmap UI object for a vanilla-era World of
Warcraft quest log: one short horizontal guild-ledger transaction index tab made
primarily from aged dark-walnut leather. This is only the reusable, text-free
base skin. At runtime it will skin exactly seven separate 112 x 20 px Button
objects that proxy Share Quest, Detail Toggle, Show Location, Hide Location,
Clean Marks, Reset Marks, and Abandon Quest. The game owns all labels, icons,
enabled states, tooltips, click logic, and the native abandon confirmation. Do
not draw seven tabs, a menu, a book, a wax seal, any text, any icon, or any state
variants. Render exactly one normal-state base tab.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit its circa-2004 vanilla WoW
   low-resolution hand-painted bitmap language, broad readable value planes,
   warm upper-left light, muted warm expedition palette, material separation,
   and sparse edge wear. Ignore its complete book layout, parchment pages, long
   leather plaques, compass, wax seals, ribbons, text, buttons, rivets, bright
   gold ornaments, and all complete UI compositions.
2. Image 2 is a secondary adjacency reference only. Inherit only the current
   accepted quest book's dark-walnut leather hue, edge softness, paint scale,
   upper-left light direction, and restrained wear so this small tab belongs
   beside that exact runtime book. Ignore the complete book silhouette,
   parchment, spine, stitches, brass corners, transparent surroundings, and all
   directly reusable pixels. If the references conflict, Image 1 plus the
   vanilla hand-painted rules wins; Image 2 may only tune local adjacency.

Canvas and occupancy: output an exact 1024 x 1024 RGB bitmap. Every pixel outside
the object must be one uniform solid #00FF00 chroma-key background, with no
gradient, texture, vignette, checkerboard, haze, color spill, or cast shadow.
Place the single object horizontally, unrotated, centered in target visible bbox
[120,442,904,582], exactly 784 x 140 px, a 5.6:1 aspect ratio. Keep the object
fully inside this box with generous empty green space on all four sides. Use a
straight-on orthographic front view with essentially no foreshortening and no
perspective tilt. It will be reduced seven-to-one to a fixed 112 x 20 px runtime
texture; do not design it for stretching, tiling, mirroring, or nine-slicing.

Silhouette and construction: make a quiet, heavy, handcrafted near-rectangle,
not a modern rounded rectangle. The long top and bottom edges are mostly
parallel, with only one-to-two percent hand-painted irregularity. The left root
edge is straight, plain, and structurally calm because the leftmost 16 runtime
pixels will sit behind the real book-page edge. The right outer end remains
nearly square, with only very shallow two-to-three percent corner chamfers. It
must not form a point, arrow, chevron, notch, fishtail, bookmark tail, or tabbed
folder silhouette. Give the leather restrained physical thickness: one broad
dark-walnut face, one narrow deeper-brown lower edge, and a short broken warm
upper-left highlight. Use only two or three broad painted value planes, readable
after downsampling.

Material and detail: use low-saturation smoked dark-walnut leather, deep umber
shadow, and a very thin, discontinuous, low-contrast oxidized-brass-colored
binding trace mainly along parts of the lower edge and far outer end. This trace
is painted into the edge; it is not a separate metal plaque, cap, frame, or
bright outline. Keep it no brighter than the leather's restrained mid-highlight.
Add only a few broad scuffs near the far outer end and lower edge. Keep the
future runtime text-safe region quiet: source coordinates [246,449,806,575]
must contain no ornament, seam, emblem, high-contrast scratch, or highlight.
The first 112 source pixels of the object are the plain hidden root, and the last
42 source pixels are only the shallow chamfer and sparse edge wear.

Style lock: this must read as a small sprite painted for a 2004-era vanilla WoW
interface, sharing the Azeroth expedition journal's warm muted palette, coarse
hand-painted edge decisions, short upper-left highlight, low-frequency wear,
and tangible leather thickness. At 112 x 20 px it should read immediately as one
substantial but restrained archival leather docket tab, subordinate to the book
and wax seal. It must not look photorealistic, vector-clean, procedural, or like
a modern brown web button.

Strict exclusions: no book, page, parchment, paper strip, ribbon, strap, wax,
seal, menu panel, button stack, frame, text, letters, numerals, glyphs, icons,
compass, quill, emblem, rune, stitching, holes, rivets, studs, buckles, hinges,
embossing, bright gold trim, complete metallic border, symmetrical flourish,
glow, glass, translucent black, neon, gemstone, skull, spike, Diablo-style
altar, Skyrim-style minimalist overlay, rounded pill, capsule, arrowhead, or
pointed bookmark. Do not place any shadow or loose pixels outside the object.

Before returning the image, verify: exactly one object; no baked dynamic content
or state variants; exact 1024 x 1024 canvas; uniform #00FF00 outside the object;
one horizontal 784 x 140 target bbox; straight quiet left root; near-square
lightly chamfered right end; no arrow, rivet, text, icon, book, seal, or bright
border; dark-walnut leather remains legible when reduced to 112 x 20 px.

### 自主修复循环与授权边界

- 不可变修复边界：`QS-B1 V1` 组件身份；单一母版对象；固定 Image 1／2 及
  权威职责；`1024²`／`784×140`／水平正投影；七个独立 Button、固定顺序与
  `112×20px` 几何；八态确定性导出；页边遮根；色键／Alpha 策略；全部禁止
  烘焙与反模式。
- 允许的 attempt 2–5 自主修复：在同一正文边界内修正 bbox／居中／纯绿背景、
  轻微轮廓比例、手绘边缘、皮革综合色、明暗对比、磨损密度、旧铜边迹亮度，
  或删除误生的文字、铆钉、尖头和装饰。只有前次物件身份与主体结构正确且
  失败局部可冻结时才允许 edit；否则使用同一固定 Image 1／2 regenerate。
- 输入范围：attempt 1 固定上传 Image 1／2；attempt 2–5 仍固定上传同 SHA 的
  Image 1／2，并且只允许把同循环紧邻前次输出作为 Image 3 edit 输入。不得
  上传 V9 模拟图、QS-A1 漆章、旧失败稿或其他参考。
- 确定性后处理：允许边缘连通色键、透明 RGB 清零、等比 bbox-fit、临时八态
  atlas、metrics 和真实排版预演；均不消耗 ImageGen，且不得非等比变形、
  重绘、补结构或改变综合色方向。
- 必须重新授权：新增／替换参考；改变对象或状态数量、视觉方向、Canvas、
  runtime 几何、provider 映射、菜单位置、页边 mask、危险色策略、Alpha 策略
  或允许烘焙任何文字／图标。
- 最多 `5` 次实际 ImageGen generation／edit，含首次；无候选且无 provider
  生成证据的流程错误不占额度。同一流程错误针对性修复一次后若复现即暂停；
  任一候选完整内审通过即停止，第五次仍失败则停止等待用户审核。

### Attempt 01 — `QS-B1 V1.r1`

- 日期：`2026-08-05`
- 结论：`attempt-01-rejected-internal / edit-immediate-raw / continue / 1/5`
- 固定执行器：`@openai/codex@0.143.0`；model `gpt-5.5`；reasoning
  `medium`；session `019fd1dd-a08d-7a22-ba4d-abd34bdab844`；执行前 repo
  commit `10323d7`。
- 操作：`generate`；上传严格为固定 Image 1／2，SHA-256 分别为
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd` 与
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`；
  Image 3 未上传。完整 `79` 行执行正文 SHA-256
  `9810861d310ddd85fc1a7d81a9312036604bb0fe190cb367d1aefd15ff5077c4`，
  子进程打印的 user block 已逐段包含完整正文与分离执行指令。
- untouched raw：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-01/raw/QS-B1-V1.r1.png`，
  `1254×1254 RGB`，SHA-256
  `f6d22998b5dc8f7c921763970d925aeaac2a91d419fe8ef49c1ce54853aa12b3`。
- 流程错误 02：provider 已完成且只完成一次生成后，固定子进程首次缓存复制命令
  误用 PowerShell 只读变量 `$HOME`；同一子进程只把循环变量改为
  `$codexHome` 后复制同一 provider 输出成功，没有再次调用 ImageGen。因此本次
  仍只计 `1` 次实际生图，流程错误累计 `2`。
- 专用确定性审查器：`tools/review_quest_log_action_tab_candidate_v1.py`；展示区域
  合同：`tools/specs/quest_log_action_tabs_candidate_display_region_v1.json`。
  edge-connected key、透明 RGB 清零、等比 bbox-fit 与临时八态 atlas 都只形成
  ignored review，不是 source 或 runtime。
- 机器源合同：`fail`。raw 可见 bbox `[82,482,1187,766]`、
  `1105×284`、比例 `3.890845:1`，而允许范围为 `5.45..5.75`；raw canvas
  `1254²` 而非 `1024²`；边缘连通背景有 `3464` 种 RGB，纯 `#00FF00` 比例
  `0.0`；等比 fit 后只得到 `545×140` source 可见区，临时 runtime normal
  只有 `78×20px`，不能覆盖 `112×20px` 视觉盒。单一连通物件、四边未裁切和
  透明 RGB 清零通过。
- 几何／展示区域：`pass`。closed `676×464`、open `724×464`、right clamp
  `740×464` 三场景 `0` violation；七个 `112×20px` 命中盒、`48px` outset、
  detail／reward 零覆盖、真实页边遮根 `16px` 与 `8px` 右缘 clamp 均通过。
  display report SHA-256
  `ecd1c5cea82830069ce329a49ef054f1f7f087e3730cfa484b884a53b2bf233c`。
- 完整审查图：review sheet SHA-256
  `6b20fca7733d957ba59fbad92ca15962827fd11d3f7595059d3f43ab6a05ecde`；
  真实排版 board SHA-256
  `d9f7afd07ce1a4307b214042877a16bac41232fe7bf2d08c73674c740a05d3a3`；
  geometry debug SHA-256
  `5bcc1b6720239f1ed4b64cb6bb79557a77084688cb76cfb1e57760a60f11ecab`；
  metrics SHA-256
  `1b789d701f1f1e60c596b7f55fe6598ca7e34e4a6555c7d7751dc4bf6c262b10`。
- 人工视觉复核：单一无字暗胡桃事务签、平直安静左根、无书／漆章／图标／铆钉
  等身份项通过；综合色可继续继承。失败项是整体过厚而不能等比占满 runtime、
  右端圆角／厚斜面过强、整张表面布满写实压花式细碎纹理、文字安全区不安静，
  上下边形成连续高亮描边，均偏离香草年代两三块大明暗切面与克制断续旧铜边迹。
- 修复策略：主体身份正确且失败均在已授权的比例、手绘边缘、皮革综合色、磨损
  密度、旧铜边迹与纯绿背景范围内，attempt 2 使用固定 Image 1／2，并只把本次
  untouched raw 作为紧邻 Image 3 edit 输入；不上传 keyed／normalized／atlas／
  排版图或 V9 模拟图。
- r1 完整修复正文：`93` 行、`6477` UTF-8 bytes，SHA-256
  `501d7ac07676639dc47948c3afbba5eff0e8f7e5f1bba541bfc3668e635f8455`。

### 完整修复执行正文 — `QS-B1 V1.r1`

Edit the immediately previous Image 3 into one isolated 2D hand-painted bitmap
UI object for a vanilla-era World of Warcraft quest log: one short horizontal
guild-ledger transaction index tab made primarily from aged dark-walnut leather.
This remains only the reusable, text-free base skin. At runtime it will skin
exactly seven separate 112 x 20 px Button objects that proxy Share Quest, Detail
Toggle, Show Location, Hide Location, Clean Marks, Reset Marks, and Abandon
Quest. The game owns every label, icon, enabled state, tooltip, click handler,
and native abandon confirmation. Return exactly one corrected normal-state base
tab, not seven tabs, not a menu, and not any state variants.

Reference authority and edit scope:
1. Image 1 is still the highest visual authority. Inherit its circa-2004 vanilla
   WoW low-resolution hand-painted bitmap language, broad readable value planes,
   warm upper-left light, muted warm expedition palette, clear material
   separation, and sparse edge wear. Ignore its book composition, parchment,
   plaques, compass, wax seals, ribbons, text, buttons, rivets, bright gold
   ornaments, and all complete layouts.
2. Image 2 remains a secondary adjacency reference only. Inherit only the
   accepted quest book's dark-walnut hue, soft painted edge scale, upper-left
   light, and restrained wear. Ignore its book silhouette, parchment, spine,
   stitches, brass corners, transparent surroundings, and reusable pixels.
3. Image 3 is the untouched immediate output from attempt 1, SHA-256
   f6d22998b5dc8f7c921763970d925aeaac2a91d419fe8ef49c1ce54853aa12b3.
   Preserve only what it already got right: exactly one horizontal dark-walnut
   leather object, a straight calm left root, no baked text or icon, no rivet,
   no book, no wax seal, and no separate ornament. Correct its canvas,
   background, aspect, outer-end shape, value structure, surface frequency,
   wear, and edge trace exactly as specified below. Do not preserve its wrong
   thickness or procedural microtexture. If references conflict, Image 1 and
   the vanilla hand-painted rules win; Image 2 only tunes adjacency and Image 3
   only freezes the correct identity and calm left-root structure.

Mandatory repair of measured attempt-1 failures: Image 3 was 1254 x 1254 with a
non-uniform green field, and its visible object was 1105 x 284, only 3.890845:1.
Do not merely crop or rescale that thick shape. Repaint the object itself into a
much longer, thinner 5.6:1 docket tab so its silhouette naturally occupies the
required 784 x 140 box and remains substantial at 112 x 20 px. Remove the dense
embossed crosshatch, leather-photo grain, small repetitive scratches, and
continuous bright top and bottom outline. Replace them with only two or three
broad hand-painted value planes, a short broken warm highlight near the upper
left, and a very thin discontinuous low-contrast oxidized-brass-colored trace
restricted mainly to part of the lower edge and far outer end. Make the far
right end nearly square with only shallow two-to-three percent corner chamfers;
remove the current rounded web-button end and deep beveled cap.

Canvas and occupancy: output an exact 1024 x 1024 RGB bitmap. Every pixel outside
the object must be the same literal RGB value #00FF00, including all four
corners and all empty margins. There must be no gradient, texture, vignette,
checkerboard, haze, green variation, color spill, or cast shadow in the
background. Place the one object horizontally, unrotated, centered in visible
bbox [120,442,904,582], exactly 784 x 140 px and 5.6:1. Keep every visible object
pixel inside that box with empty pure green space on all four sides. Use a
straight-on orthographic front view with no perspective tilt or foreshortening.
The runtime will reduce this object seven-to-one to exactly 112 x 20 px; do not
design it for stretching, tiling, mirroring, or nine-slicing.

Silhouette and construction: paint a quiet heavy handcrafted near-rectangle,
not a modern rounded rectangle. The long top and bottom edges are mostly
parallel with only one-to-two percent coarse hand-painted irregularity. Keep the
leftmost 112 source pixels straight, plain, unornamented, and structurally calm
because the first 16 runtime pixels sit behind the real book-page edge. Keep the
far right nearly square; its last 42 source pixels contain only shallow chamfers
and sparse wear. It must not form a rounded pill, point, arrow, chevron, notch,
fishtail, bookmark tail, or folder tab. Show restrained thickness using one
broad dark-walnut face, one narrow deeper-brown lower edge, and one short broken
upper-left highlight. No deep beveled frame and no perimeter ridge.

Material and text-safe quietness: use low-saturation smoked dark-walnut leather,
deep umber shadow, and only the restrained broken edge trace described above.
The leather must look coarsely hand-painted for a small 2004 UI sprite, not
photographic, embossed, procedural, crosshatched, or vector-clean. Concentrate a
few broad scuffs only near the far outer end and lower edge. Source coordinates
[246,449,806,575] are a quiet future text-safe region: keep them free of seam,
ornament, emblem, high-contrast scratch, grain cluster, highlight, or metallic
line. At 112 x 20 px the face must remain broad, calm, legible, and subordinate
to the accepted book and wax seal.

Strict exclusions: no book, page, parchment, paper strip, ribbon, strap, wax,
seal, menu panel, button stack, frame, text, letters, numerals, glyphs, icons,
compass, quill, emblem, rune, stitching, holes, rivets, studs, buckles, hinges,
embossing, photo leather grain, dense crosshatch, bright gold trim, complete
metallic border, continuous bright outline, symmetrical flourish, glow, glass,
translucent black, neon, gemstone, skull, spike, Diablo-style altar,
Skyrim-style minimalist overlay, rounded pill, capsule, arrowhead, pointed
bookmark, shadow, or loose pixels outside the object.

Before returning, verify all of the following against the actual output: exactly
one object and one normal state; no baked dynamic content; exact 1024 x 1024 RGB
canvas; every exterior pixel identical #00FF00; visible bbox exactly
[120,442,904,582], 784 x 140 and 5.6:1; straight quiet left root; near-square
shallow-chamfered right end; no rounded cap; only two or three broad painted
value planes; quiet text-safe center; no dense grain or continuous bright
border; and a full-width substantial leather tab when reduced to 112 x 20 px.

### 当前门禁

- 当前实际生图：`1/5`；流程错误：`2`。
- `2026-08-05` 流程错误 01：首次本地执行正文 SHA 预检误用了当前
  PowerShell／.NET 不支持的静态 `SHA256.HashData`；没有启动固定子进程、没有
  provider 生成证据或 raw，因此不占实际生图额度。紧邻针对性修复改用
  `SHA256.Create().ComputeHash` 后通过。
- 已获用户授权原文（`2026-08-05`）：`确认授权 QS-B1 V1；允许每次上传固定 SHA 的 Image 1/2，
  允许同循环紧邻前次输出仅在冻结边界内作为 Image 3 edit 输入；最多 5 次实际
  ImageGen 调用，流程错误不占额度；允许按合同执行确定性边缘连通色键、透明
  RGB 清零与等比 bbox-fit。`
- 尚未建立：accepted source、manifest、runtime atlas、Lua/XML 接入或旧按钮
  隐藏。attempt 1 的所有派生文件仍只属 ignored review。
- 下一步：提交 attempt 1 全量审查、专用审查器／展示区域合同与上述完全自包含
  修复正文；提交通过后，attempt 2 固定上传 Image 1／2 和且仅和紧邻 untouched
  raw `QS-B1-V1.r1.png` 作为 Image 3 edit 输入。
