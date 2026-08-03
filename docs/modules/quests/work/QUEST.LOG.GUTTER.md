# Quest Log 静态卷宗结构当前工作文件 — QL-A2 V4

## 元数据

- 模块：任务日志／冒险者公会任务卷宗
- 当前涉及：
  `QUEST.LOG.SHELL`、`QUEST.LOG.LIST.PAPER`、
  `QUEST.LOG.DETAIL.PAPER` 与 `QUEST.LOG.GUTTER.*`
- 版本：`QL-A2 V4`
- 子状态：`runtime-exported`
- 项目阶段：`P5`
- 操作：`deterministic-export / static-integration`
- 固定执行器：V4 不调用 ImageGen；`0/0`
- 当前结论：停止 V3.3 的独立页沟小件生成，改为从已接受的 QL-A1 空卷宗
  source 做确定性、固定尺寸的运行时结构导出；静态测试已通过。用户于
  `2026-07-31` 接受当前游戏内书本主体，不再增加第二层框或列表底板
- 用户授权：`2026-07-30` 确认 QL-A1 单一静态背景、`676 × 464`、
  list-only 不缩窄书体、`GUTTER.*` 静态归属，以及继续执行导出与接入
- 目标客户端：Turtle WoW `1.18.1`／Interface `11200`
- 当前稳定对象合同：
  [SUBMODULES.md](../SUBMODULES.md)
- 锁定视觉基准：
  [任务详情面板_视觉基准_v1.png](../../../../assets/locked/quests/任务详情面板_视觉基准_v1.png)
  — SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`
- 已接受结构 source：
  [QuestLogBookShell_Master_v1.png](../../../../assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png)
  — `1514 × 1039 RGBA`，SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`
- source manifest：
  [QL-A1_SourceManifest_v1.json](../../../../assets/source/quests/ql-a1/QL-A1_SourceManifest_v1.json)
- 本机 ignored 尺寸预演：
  `generated/quests/QL-A2/v4/previews/QL-A2_V4_SHELL_676x464.preview.png`
  — `676 × 464 RGBA`，SHA-256
  `3a075d8e094fc8d3b72cf8b5fc4a5a6add020ddbcd6f1e768a841423c5b0e910`
- 新 tracked source：无
- runtime：
  [QuestLogShellV4.tga](../../../../addon/AzerothExpeditionUI/Media/Quests/QuestLogShellV4.tga)
  — `1024 × 512 RGBA`，SHA-256
  `1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e`
- runtime manifest：
  [QL-A1_RuntimeManifest_v1.json](../../../../assets/source/quests/ql-a1/QL-A1_RuntimeManifest_v1.json)
- exporter：
  [build_quest_log_shell_v4.py](../../../../tools/build_quest_log_shell_v4.py)
- adapter：
  [Quests.lua](../../../../addon/AzerothExpeditionUI/Modules/Quests.lua)
  — 当前 runtime contract `1.7`；SHELL 本身不变，新增内容只作用于书本外
  真实控件、隐藏的右页 scrollbar chrome、滚轮连接与 pfQuest 后加载兼容

V4 是新的运行时所有权与导出合同，不延续 V3.3 的生成预算。它只晋级固定
书体结构；QL-B／QL-C／QL-D 的动态对象与交互状态仍未完成。

## V3.3 终态复核与纠错

V3.3 的三个固定执行正文均已在 `5/5` 后终止，合计 `15/15`。完整正文、
会话、result、SHA 与逐次 diff 保留在 Git 历史；当前树只保留会影响 V4
裁决的结论。

| 分段 | 正确的第一失败门禁 | V4 结论 |
|---|---|---|
| B1 underlay＋folds | underlay 成为带重复纹样的深色竖条；fold 仍是有满面压纹的独立纸条，背景也不能直接透明化 | 不再把页沟阴影与两张纸页内缘拆成三个自由漂浮的生成对象 |
| B2 stitch | 单根弧形对象持续表现为树根、木条、角质或编织绳，而不是一针与纸缘发生物理穿入的装订回路 | 不再从完整原型的微小针脚仅凭文字重画孤立对象 |
| B3 top／bottom closures | **语义／物理失败**：原尺寸目视复核可见多圈交叠、装饰性凯尔特／航海绳结和横向杆状尾端；此前“语义通过、只差尺寸”的记录不成立 | 禁止挽救、缩放或晋级 V3.3 B3；V4 不设置外露 top／bottom 装饰结 |

V3.3 的 raw、透明检查稿和 V3.2-A 纸页候选仍只是 ignored 本机中间产物。
它们不成为 V4 输入、source 或美术权威。

## 美术基准继承

### 权威顺序

1. 锁定任务详情图与
   [Quests 主模块 Prompt](../ART_BASELINE.md)共同定义正式公会卷宗身份、
   香草魔兽手绘语言、综合色、材料关系和左上暖光。
2. [全局基线](../../../GLOBAL_ART_BASELINE.md)约束 2004 年前后的厚重轮廓、
   低饱和综合色、材料尺度和反现代边界。
3. [子模块稳定 Prompt](../SUBMODULE_ART_BASELINES.md)约束空卷宗、安静纸面、
   克制内部装订及禁止烘焙的动态内容。
4. [SUBMODULES.md](../SUBMODULES.md)控制真实 Frame、交互对象、状态、层序
   和回退。
5. QL-A1 source 是用户已接受的结构母版，承担实际像素与静态书体结构；
   它不能反向覆盖锁定图与 Prompt，但不需要由 ImageGen 再解释一次。

### 必须继承

- 第一眼仍是一册从内部打开、能翻页的正式公会任务卷宗，不是现代棕色卡片、
  外置封脊、聊天书复制品或暗黑祭坛。
- 保留 QL-A1 中的近等宽物理双页、深胡桃／暗酒红厚封皮、外围页叠、克制
  黄铜包角、凹陷页沟、离散短装订回路与左上暖光。
- 保留香草时代二维手绘位图的粗厚略不规则轮廓、宽面切色、低分辨率可读性
  和一致磨损尺度。
- 左右主要阅读区保持连续、安静、低对比；动态中文与全部交互状态由客户端
  绘制。

### 明确排除

- 不把任务标题、任务行、等级、计数、勾选、选择状态、正文、目标、奖励、
  物品图标、按钮文字或滚动状态烘焙进静态卷宗。
- 不把 Close、Expand、Levels、两套 ScrollBar、目录覆盖、奖励槽或底部
  操作按钮合并进背景；它们继续按真实 Button／Texture 状态单独生产。
- 不继承 V3.2／V3.3 的独立纸条、木质针脚、装饰绳结、绿色背景或错误尺寸。
- 不新增 top／bottom 大结、蜡封、页码、书签、徽章墙或额外黄铜装饰。

### 冲突裁决

- 旧 QL-A2 合同把八个无交互视觉层都当成独立生图对象；用户的组件粒度
  要求针对真实运行时对象与交互状态，并不要求把同一固定背景中的每一道
  阴影都做成独立 Texture。裁决：静态书体归 `QuestLogFrame` 背景所有，
  所有真实交互对象仍独立。
- QL-A1 source manifest 继续禁止客户端直接加载高分辨率 PNG，但已允许
  QL-A2 V4 的全幅确定性导出；runtime 只加载经过验证的 power-of-two TGA。
- pfUI 当前在 list-only 时把 `QuestLogFrame` 从 `676` 缩到 `340` 宽。
  这会让一本打开的书物理折断。V4 提议保留 `676 × 464` 静态书体，只隐藏
  右页动态内容；Expand 功能仍保留，但不再缩窄书体。

## 组件合同 — V4 运行时所有权

| 逻辑 ID | V4 所有权 | 独立位图／状态 |
|---|---|---|
| `QUEST.LOG.SHELL` | `QuestLogFrame` 的单一静态空卷宗背景；承载封皮、包角、外围页叠、两张空纸页和固定页沟 | 一张固定尺寸 runtime atlas |
| `QUEST.LOG.LIST.PAPER` | `QuestLogListScrollFrame` 的左页阅读安全区与布局锚点 | 无独立位图；使用 SHELL 已接受纸面 |
| `QUEST.LOG.DETAIL.PAPER` | `QuestLogDetailScrollFrame` 的右页阅读安全区与布局锚点 | 无独立位图；使用 SHELL 已接受纸面 |
| `QUEST.LOG.GUTTER.UNDERLAY` | SHELL 中央静态凹陷子区域 | 不再创建独立 Texture |
| `QUEST.LOG.GUTTER.LEFT_FOLD`／`RIGHT_FOLD` | SHELL 左右纸页的既有内缘子区域 | 不再创建自由漂浮的 fold Texture |
| `QUEST.LOG.GUTTER.STITCH` | SHELL 中央既有离散装订回路子区域 | 固定高度下不重复、不拉伸、不单独生成 |
| `QUEST.LOG.GUTTER.TOP`／`BOTTOM` | 无外露装饰结；装订在 QL-A1 书页与外围结构下自然结束 | 无独立对象与资产 |

合同已凝结进 `SUBMODULES.md` 与 QL-A1 source／runtime manifest。Close、
ScrollBar、行状态、奖励槽和操作 Button 等后续 QL-B／QL-C／QL-D 粒度
完全不变。

## 状态合同

- `closed`：整个 `QuestLogFrame` 隐藏。
- `empty`：显示完整空卷宗，只有客户端空日志文字；不生成空状态卡片。
- `dual-page`／`selected`：显示完整卷宗；左右动态内容及选择覆盖独立绘制。
- `list-only`：完整卷宗仍保持显示与原宽；只隐藏右页动态内容。Expand
  Button 与 SavedVariables／交互语义保留，不把书体缩成半本。
- 任一纹理、Frame 或兼容对象缺失：局部回退 Blizzard 原生
  `QuestLogFrame`，不阻止 addon 加载。

## 确定性导出合同

### 源与目标

- 唯一像素源：已接受的
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`。
- 源尺寸 `1514 × 1039 RGBA`；目标显示尺寸 `676 × 464 UI px`。
- 按宽度的统一比例约 `0.4465×` 缩放；源高换算后四舍五入恰为 `464px`。
  不裁切、不旋转、不改变书脊中心、不进行自由重画。
- 运行时使用 power-of-two `1024 × 512 RGBA TGA`。把 `676 × 464` 图像放在
  左上角，其余像素保持全透明。
- TexCoord：
  `u=0..0.66015625`、`v=0..0.90625`；显示 Texture 为 `676 × 464`。
- runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogShellV4.tga`。
- runtime manifest：
  `assets/source/quests/ql-a1/QL-A1_RuntimeManifest_v1.json`。
- exporter：
  `tools/build_quest_log_shell_v4.py`；只允许缩放、透明 padding、TGA 转换、
  SHA／Alpha／UV 记录和预演，不允许修复或重画美术。

### 当前预演证据

- ignored preview：
  `generated/quests/QL-A2/v4/previews/QL-A2_V4_SHELL_676x464.preview.png`。
- `676 × 464 RGBA`；SHA-256
  `3a075d8e094fc8d3b72cf8b5fc4a5a6add020ddbcd6f1e768a841423c5b0e910`。
- 透明／半透明／不透明像素：
  `45159／6974／261531`。
- 可见 bbox（右下独占）：`[0,22,676,438]`；可见绿色残留为 `0`。
- 原尺寸目视审查：通过物件身份、书内视角、近等宽双页、页沟物理关系、
  香草手绘语言与综合色；在目标尺寸仍能读出多层页厚和离散装订。
- 静态已验证：TGA header／SHA、UV、Frame 固定尺寸、背景层、原生装饰
  Texture 隐藏、动态文字保留、原按钮脚本保留、详情切换与 empty 状态。
- 尚未验证：Turtle WoW 中的中文安全区、ScrollFrame 实际裁切、按钮命中、
  客户端纹理方向／显存和 list-only 实机表现；这些阻塞 `P6`。

## ImageGen 与修复预算

- V4 没有 ImageGen 执行正文，不调用原生或固定 ImageGen。
- 固定执行器预算：`0/0`；不存在 `.rN` 自主生图循环。
- 若用户否决 QL-A1 在目标尺寸的静态书体，返回新的
  `prompt-draft`，另行建立具体版本、输入与最多五次预算；不得把 V3.3
  的剩余次数视为可复用额度。

## 最终执行正文

不适用。V4 是确定性导出合同，没有交给图像生成器的生产正文。exporter 只
执行本文件“确定性导出合同”中的统一缩放、透明 padding、TGA 转换、
SHA／Alpha／UV 记录和预演。

## 执行记录

- 日期：`2026-07-30`
- 当前操作：完成稳定合同、确定性导出、runtime manifest、AEUI adapter
  与静态 smoke
- 固定执行器调用：`0/0`
- 输入 source：QL-A1 accepted source，SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`
- 预演输出 SHA-256：
  `3a075d8e094fc8d3b72cf8b5fc4a5a6add020ddbcd6f1e768a841423c5b0e910`
- runtime TGA SHA-256：
  `1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e`
- 交互边界：书体 Texture 位于 `BACKGROUND`，不接收鼠标；列表、详情、
  动态文字、原生操作 Button 与脚本继续独立。adapter 只在缺失时创建真实
  `QuestLogFrameExpandButton`，其状态美术仍等待 QL-C。

## 审查记录

- 结论：`通过`静态导出与接入门禁；等待实机。
- 子状态／阶段：`runtime-exported / P5`。
- 已通过：source provenance、物件身份、目标尺寸可读性、动态内容排除、
  交互组件独立性、确定性重建、TGA／UV／manifest 一致性与 Lua smoke。
- 运行时处理：原生／pfUI 真实控件在背景上方继续绘制和接收交互；静态
  Texture 不包含点击区。list-only 只改变右页动态可见性，Frame 始终
  `676 × 464`。
- 下一门禁：Turtle WoW `1.18.1` 实机验证方向、裁切、中文换行、按钮命中、
  empty／dual-page／list-only 与 SavedVariables；未达 `P6`，不清理 work
  或 ignored 中间产物。

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一门禁 |
|---|---|---|---|
| QL-A2 V3.3 | 三段各 `5/5`，合计 `15/15`；原尺寸复核纠正 B3 语义误判 | `candidate-rejected / repair-budget-exhausted` | 不挽救或晋级任何 V3.3 输出 |
| QL-A2 V4 | QL-A1 accepted source → `1024 × 512` TGA；固定执行器 `0/0`；runtime SHA `1b6b21cd…` | `runtime-exported / P5` | Turtle WoW 实机验收 |

QL-A2 在实机前保持本 work。后续 QL-B／QL-C／QL-D 交互资产仍需各自的
组件合同、Prompt 与验收，不能因为背景已接入而标记完成。

## `2026-08-03` runtime `1.17` 详情裁切修复

- 用户实机反馈右页详情未完整展示，奖励会被裁。根因是 runtime `1.3+` 将
  正文宽度收敛为 `214px` 后产生更多换行，但只保证 ScrollChild 最低
  `324px`，没有根据重新排版后的最底部对象更新真实滚动范围；原生双列奖励
  槽宽度也超过当前 `224px` ScrollChild 安静区。
- runtime `1.17` 保持 SHELL、ScrollFrame、原任务数据和 provider 锚点，
  仅把 `QuestLogItem1..MAX_NUM_ITEMS` 收敛为每格 `108px`、名称 `64px`，并在
  每次 `QuestLog_UpdateQuestDetails` 后遍历当前可见标题、正文、目标、奖励
  文字、奖励 Button 与附加奖励 Frame。目标 ScrollChild 高度等于最底对象
  加 `12px`，最低 `324px`、保护上限 `4096px`，随后调用真实
  `UpdateScrollChildRect()`。
- Lua smoke 使用 `512px` 代表性动态内容高、四个显示奖励槽和 `188px` 真实
  range，验证宽度、内容高、滚轮限位和 provider late-load 后重施几何；通过。
- 这只修正布局／滚动合同，不接受 QL-D 最终奖励槽美术，也不能替代 Turtle
  WoW 中 0／1／2／4／6 奖励、长中文正文与 UI scale 的实机 P6 证据。
