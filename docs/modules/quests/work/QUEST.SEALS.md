# Quest Log／Tracker 共用漆章

- 批次：`QS-A1`
- 当前版本：`QUEST-SEALS-SIM-V1`
- 项目阶段：`P2`
- 当前子状态：`simulation-reviewed / awaiting-user-confirmation`
- 固定执行器：`imagegen-0-143-0`
- ImageGen：`0/0`
- runtime：未修改
- 下一门禁：用户确认或否决本模拟中的可见方向；确认后才冻结生产正文并请求
  独立的 ImageGen 生产授权。

## 组件合同

| ID | 当前对象 | 目标合同 |
|---|---|---|
| `QUEST.LOG.CHROME.SEAL` | 尚无 runtime 对象 | `QuestLogFrame` 上独立的 `28 × 28` 无鼠标 Texture；相对 Frame 盒为 `[625,377,28,28]`，不烘焙进 `QUEST.LOG.SHELL`。只有取得真实动作后，才允许在同一盒内一对一升级为 Button |
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
任务数据或显示条件。

## 美术基准继承

权威链：

1. [全局美术基线](../../../GLOBAL_ART_BASELINE.md)。
2. [Quests 主模块基线](../ART_BASELINE.md)。
3. [Quests 子模块基线](../SUBMODULE_ART_BASELINES.md)。
4. 锁定图
   [任务详情面板](../../../../assets/locked/quests/任务详情面板_视觉基准_v1.png)，
   SHA-256
   `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`；
   [任务追踪面板](../../../../assets/locked/quests/任务追踪面板_视觉基准_v1.png)，
   SHA-256
   `3b5c2ca6c1e69c74db5c64978cde351596ece6369d339b7125aee43904eb7d86`。

必须继承：

- `2004` 年前后香草魔兽的二维手绘 sprite、粗厚略不规则轮廓、明确明暗
  切面与左上暖光；
- 低饱和暗酒红／旧酒红蜡体、深乌棕凹痕、极少量旧黄铜暖色反光；
- 真实蜡体厚度、压印起伏、纸／皮革接触感和克制磨损；
- Quest Log 的正式公会卷宗身份与 Tracker 的行军便笺身份。

组件级转译：

- 两处共用同一枚“远征公会工具漆章”美术母版，中心为极简四向罗盘与一笔
  斜向羽毛笔刻痕；无字母、阵营徽记、任务状态勾叉或发光符文；
- Quest Log 以 `28px` 显示，克制地压在右下纸页／封皮交界；
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

规格：
[quest_seals_simulation_v1.json](../../../../tools/specs/quest_seals_simulation_v1.json)，
SHA-256
`1013ceff241cc935f374215682ec9ae1ba6bb4e70346e8a2471a5431b1505d52`。

渲染器：
[render_quest_seals_simulation_v1.py](../../../../tools/render_quest_seals_simulation_v1.py)，
SHA-256
`32fbd1b73a9b42ad971b7c72c98e1eae3197592bd5a91b06299867a189432fbb`。

macOS 命令：

```bash
conda run -n py312 python \
  tools/render_quest_seals_simulation_v1.py \
  tools/specs/quest_seals_simulation_v1.json \
  --repo-root .
```

解释器：
`/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，Python `3.12.12`。
本地渲染错误：`0`。ImageGen：`0/0`。模拟使用当前已接受 Quest Log shell
作为邻接 runtime UI，只作周边上下文；没有把模拟像素或 shell 裁切成新资产。

输出：

- 游戏内整体预演：
  `generated/quests/QUEST-SEALS/simulation/QUEST-SEALS-SIM-V1/quest_seals_ingame_v1.png`，
  `1536 × 1024 RGBA`，SHA-256
  `d8a37476f70801f43759fd7c907a7ef48b84ec715cf6bc76ef46eb996f12d991`；
- 组件／宽度合同板：
  `generated/quests/QUEST-SEALS/simulation/QUEST-SEALS-SIM-V1/quest_seals_contract_v1.png`，
  `1536 × 1024 RGBA`，SHA-256
  `0dc1511de3ed70095ad078759b78a4d1ae0fac838a8429c014f8551a8cca67fa`；
- 机器报告：
  `generated/quests/QUEST-SEALS/simulation/QUEST-SEALS-SIM-V1/quest_seals_report_v1.json`，
  SHA-256
  `5b8fb70e9d4925588a675da30aaa3919305f77f6e59de3706e164aa5a64c7f6c`。

内部检查：模拟几何 `pass`。Quest Log 漆章位于 Frame 内，未与左右阅读安全区、
底部两组 Button 或关闭按钮相交。Tracker 在 `130／230／330px` 三种真实
宽度下均水平居中，底边恰接 `y=16` 列表起点，不覆盖任务内容；paper
outset 仍为零。当前新增 Frame／命中盒均为 `0`，七按钮在功能等价前不会被
runtime 隐藏。顶部 `18px` 屏幕 clamp 只是已定义的 P5 必做门禁，尚无
runtime 实现或实机通过结论。

可由本模拟确认：位置、相对尺寸、综合色重、共用符号、静态隐藏旧 icon 后的
层级，以及 Tracker 漆章从顶部突出的受控程度。

非权威范围：最终蜡质笔触、裂纹、Alpha、像素边缘、source bbox、atlas、
四状态确定性数值、客户端混合和 hub menu 展开形态。模拟图不得成为生图输入、
source 或 runtime。

用户结论：`awaiting`。

## 最终执行正文 — QS-A1 V1

状态：`production-draft / not-authorized`。模拟未确认前不可执行。

固定输入：

1. Image 1：
   `assets/locked/quests/任务详情面板_视觉基准_v1.png`。只继承香草魔兽
   手绘年代、Quest Log 暗酒红皮革／暖赭纸／旧黄铜之间的色温与材料厚度；
   忽略完整书本、文字、按钮、奖励槽、书脊和布局。
2. Image 2：
   `assets/locked/quests/任务追踪面板_视觉基准_v1.png`。只继承 Tracker
   行军便笺的综合色重、旧酒红点缀、左上暖光和小尺寸 UI 笔触；忽略完整
   tracker、任务文字、纸面、图标、按钮和屏幕场景。

本地模拟不上传。`assets/source/` 派生物不是视觉权威，也不上传。

完整正文：

> 为 Turtle WoW 1.18.1 的“艾泽拉斯远征手记”任务模块制作恰好一枚独立的
> “远征公会工具漆章”透明源资产。最终只出现一个正面略带内部俯视的圆形旧蜡
> 压印，不出现第二个物件、书本、纸张、面板、按钮、图标底座、文字或场景。
>
> 画布固定 1024×1024。背景必须是完全均匀、无纹理、无阴影、无渐变的精确
> #00FF00。唯一漆章水平和垂直居中，可见 bbox 约 640×640，四周至少各留
> 180px 纯绿色安全边。不得裁边。漆章及其克制接触阴影必须全部位于该安全盒，
> 背景不得被蜡色、反光或半透明绿边污染。
>
> 物件是一枚真实压在公会卷宗纸页或皮革上的暗旧酒红蜡章，而不是现代圆形
> icon、金属硬币、勋章、宝石、按钮底座或燃烧火球。轮廓接近圆形但保留少量
> 手压不规则边、局部堆蜡和最多三处小缺口；有可读但不过厚的蜡体侧缘、左上
> 暖色短高光、右下深乌棕接触阴影和哑光微透蜡质。不要光滑塑料、玻璃反射、
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
同一 `40 × 40` content；Quest Log 显示 `28 × 28`，Tracker 显示
`34 × 34`。这些数值在 source 接受后还需以真实 Alpha bbox 复核，不能用
自由重画完成导出。

完整性预检：对象／状态数量、输入职责、画布、bbox、视角、材料、压印、
小尺寸安全、时代语言、色键、禁止项和最终自检均已明确。尚未授权；固定
`imagegen-0-143-0` 的最多五次实际生图预算仍为 `0/5`。允许的循环修复只
包括同一物件的 bbox、纯绿色背景、边缘、蜡质、压印清晰度和综合色；不得
改变对象数量、中心符号、输入职责、画布、runtime 尺寸、功能合同或加入
新参考图。

## 执行记录

- 日期：未执行
- 会话／结果 ID：无
- 实际输入：无上传
- 输出：无正式候选
- 实际生图次数：`0/5`
- 流程错误次数：`0`
- 循环终态：未开始；等待模拟确认与独立生产授权

## 审查记录

- 语义／物理：模拟中的两处漆章均为独立对象；未烘焙背景，未冒充任务状态。
- 透视／图层：正面轻微内部俯视；Quest Log 贴合右下纸页／封皮交界，
  Tracker 位于纸面上缘并在列表层之前结束。
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
- 结论：`simulation-reviewed / awaiting-user-confirmation`
- 用户结论与日期：`awaiting`
- 下一门禁：用户确认具体模拟版本。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| `QUEST-SEALS-SIM-V1` | 本地 specification、renderer、两张 `1536 × 1024` 预演与机器报告；ImageGen `0/0` | `simulation-reviewed / awaiting-user-confirmation` | 由用户确认；若否决，按具体位置、尺寸或综合色反馈建立新模拟 |

正式生产尝试：无。
