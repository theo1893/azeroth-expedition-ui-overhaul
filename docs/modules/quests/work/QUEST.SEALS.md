# Quest Log／Tracker 共用漆章

- 已接受漆章批次：`QS-A1`
- 当前事务签批次：`QS-B1`
- 当前接受版本：`QS-A1 V1.r4`
- 已确认历史模拟：`QUEST-SEALS-SIM-V2`；其 Quest Log 顶部悬空位置已于
  `2026-08-03` 被用户否决，Tracker 方向仍有效
- 当前已确认历史模拟：`QUEST-LOG-SEAL-ACTIONS-SIM-V9`
- 已被用户改向的模拟：`QUEST-LOG-SEAL-ACTIONS-SIM-V10 / QS-B1 V2`
- 已确认但资产拓扑被取代的模拟：
  `QUEST-LOG-SEAL-ACTIONS-SIM-V11 / QS-B1 V2`
- 当前已确认模拟：`QUEST-LOG-SEAL-ACTIONS-SIM-V12 / QS-B1 V3`；用户于
  `2026-08-05` 回复“可以”
- 当前已确认布底模拟：`QUEST-LOG-SEAL-SUBSTRATE-SIM-V13 / QS-B1 V4-A`；
  用户于 `2026-08-05` 回复“接受, 用这一套试试效果”
- 最近一次已执行生产正文：`QS-B1 V3-A.r4 / attempt 5`；V3-A 循环已耗尽，
  当前无下一修复正文
- 项目阶段：漆章美术／atlas／Quest Log placement `P5`；menu V3-A
  `user-rejected / repair-budget-exhausted / P3`；menu V4-A
  `prompt-authorized / P3`
- 当前子状态：QS-A1 `runtime-exported / page-placement-integrated`；QS-B1 V2
  `user-superseded-before-attempt-5 / P3 / 4/5`；QS-B1 V3
  `simulation-confirmed / V3-A repair-budget-exhausted / V3-B gated / P3`；V1 保持
  `candidate-rejected / user-rejected / repair-budget-exhausted / P3 / 5/5`
- 固定执行器：`imagegen-0-143-0`
- 模拟 ImageGen：`0/0`
- QS-A1 正式 ImageGen：`5/5`
- QS-B1 V1 ImageGen：`5/5`（已耗尽并由用户否决）
- QS-B1 V2 ImageGen：`4/5`（第 5 次未调用；旧授权不得转用于 V3）
- QS-B1 V3 ImageGen：V3-A `5/5`、V3-B `0/5`（V3-A 未内部通过，故按联合
  授权顺序门禁未执行 V3-B）
- QS-B1 V4-A ImageGen：`0/5`；流程错误 `1`；生成前上传／provider job `0`；
  用户已授权，等待同一 production 正文的 transport retry
- QS-B1 历史流程错误：V1 `1`、V2 `3`；V3 `0`。均按“无生成证据才不占
  额度”记录
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
  与事务菜单先等待本地模拟确认。当前 runtime `1.25` 继续按确认方向只使用既有
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
  文字化布局与综合色结论，不接受模拟像素。随后完成 `QS-B1 V1` 生产正文，
  `QS-B1-INTERACTION V1` 已于 `2026-08-05` 获用户明确接受；`QS-B1 V1`
  也已于 `2026-08-05` 获独立正式生产授权。五次实际生成均已执行；最终
  attempt 5 因 `6.1347:1` 超宽比例、`112×18px` 等比可见区、均匀压纹和
  连续亮边先被内部退回，随后又被用户以“不可接受”明确否决。V1 全部候选
  只能作为负面证据，不得成为 source、runtime、确定性几何例外或后续 edit
  输入。V10 的页外索引签随后被用户用“ScrollChild 内固定火漆＋向下授印
  绶带”明确改向，未获得确认。新的 V11 已按该物理关系完成四状态本地确定性
  预演。用户于 `2026-08-05` 在上一轮明确说明“若接受 V11 可见方向，下一步
  重写完整生产提示词并单独请求正式生图授权”的上下文中回复“继续”，因此
  V11 可见方向已确认；其后 V2 实际生成至 `4/5`，用户以质感差、过度工整和
  单图无法独立隐藏功能为由终止 V2，attempt 5 没有调用。V12 将背景、七张
  透明纹章和七个 Button 所有权分开，用户于 `2026-08-05` 回复“可以”确认
  方向。正式生产进一步用一条连续最大长度空白母版的动态 prefix＋tail 避免
  重复接缝，并把七格印墨工作表在 P4 拆成七张独立 RGBA source。V3-A／V3-B
  完整正文已准备，但当前没有 ImageGen、上传、source 晋级或 runtime 接入
  授权。不得执行 V1 attempt 6 或 V2 attempt 5。
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
| `QUEST.LOG.CHROME.SEAL` | `QuestLogFrame.aeuiQuestChromeSeal`，当前 runtime `1.25` 为 `[576,68,32,32]` 无鼠标 Texture | QS-A1 V1.r4 美术保持 accepted；当前 P5 位置不变。V12 已确认在 parity 成立后把未来 `40×40px` Button 改挂到 `QuestLogDetailScrollChild` 的内容坐标 `[206,0,40,40]`，其视觉 `[210,4,32,32]` 在 scroll `0` 时仍等于 Frame 坐标 `[576,68,32,32]`，随后随正文滚动并由真实 viewport 裁切；V3 具体候选接受、P4／P5 授权与 parity 前不改 runtime |
| `QUEST.LOG.CHROME.SEAL.SUPPORT` | 当前无 runtime 对象 | 不创建书框、包角、皮革／黄铜承托或页外书签。V12 的空白 root 属于下方动态旧布背景，不是另一个悬空支架；收起时只在蜡体下露出 `6px`，并与火漆处于同一 ScrollChild。生产上 root 是连续 `SUBSTRATE.MAX` 的首段 UV，不生成独立重复布片 |
| `QUEST.LOG.CHROME.SEAL.MENU` | 尚无 runtime 对象 | V12 已确认：视觉背景是一条无功能所有权的动态空白旧布，生产上由连续 max master 的前缀＋tail 构成；七个 `32×22px` 行分别叠放七张独立透明纹章，并各由一个真实 Button 代理原 provider。不得把纹章烘焙回背景、合并 UV／manifest ID／hitbox 或使用共享大命中区。hidden 无空洞收拢，disabled 留位；展开只临时覆盖正文最右 `14..24px`，不缩窄／重排正文；尾端在 `108×41px` 奖励槽前保留 `32px`。漆章、背景、纹章和 Button 共同滚动；部分裁切项不保留完整隐藏 hitbox，完全滚出后命中数为 `0`。功能等价前旧八控件继续原子 fail-open |
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
- 下一门禁：在目标客户端验证当前 runtime `1.19` 的页上位置；事务签菜单仍需用户
  独立授权 `QS-B1 V1` 最终生产正文、冻结修复边界与最多五次实际 ImageGen
  调用。授权前不实现菜单、不隐藏旧按钮、不生图。

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

## Quest Log 火漆点击行为 — `QS-B1-INTERACTION V1`

### 元数据与范围

- 日期：`2026-08-05`
- 操作：`prepare`
- 子状态：`interaction-confirmed / P2 / awaiting-production-authorization`
- 复用的已确认视觉：`QUEST-LOG-SEAL-ACTIONS-SIM-V9`；本合同不改变火漆、
  七条事务签、页边遮根、`48px` outset 或 detail／reward 零占用，因此不创建
  新的视觉模拟版本。
- ImageGen：`0/0`；上传：无；新增 source／runtime：`0`。
- 本轮只定义点击、展开、状态同步、动作委托、收起与 fail-open；不生图，
  不实现 Lua，不隐藏现有按钮，也不改变原生／pfQuest 业务逻辑。

### 交互原则

- 火漆是任务书的一级“事务入口”，不是配置弹窗、二级详情页或模态窗口。
  左键只在 `CLOSED` 与 `OPEN` 之间切换；右键在 V1 不注册，保留给未来独立
  配置范围。
- V1 采用即时展开／收起，不使用抽屉缓动、逐条飞入、弹性缩放、发光或声音。
  唯一运动反馈是 Button 原生按下时的 `1px` 右下位移；菜单打开期间火漆固定
  使用既有 pressed 视觉，作为克制的“已开启”反馈。
- 菜单始终是七个独立 Button，不创建整块弹窗、子页面或第二本纸页；详情正文、
  奖励与滚动区域从不切换为事务内容。
- 菜单是非模态的。不得建立全屏透明挡板，也不得吞掉玩家对世界或其他插件的
  第一次点击。

### 可见盒、命中盒与层序

- 火漆视觉仍为 `[576,68,32,32]`；真实 Button 命中盒为
  `[572,64,40,40]`。命中盒完全落在 V9 已冻结的 `40×40px` 保留区内。
- 七条 Texture 的可见盒仍为 V9 的七个 `112×20px` 槽，从 `x=612` 开始。
  交互 Button 命中盒改为各槽右侧可见的 `[628,y,96,20]`：左侧 `16px` 根部
  只由 Texture 延伸到真实页边之下，不接收鼠标。由此点击纸页边缘不会误触
  被遮住的按钮根部；文字安全区 `[630,y+1,80,18]` 完全位于命中盒内。
- 层序保持：QL-A1 shell → detail／reward → 七条事务签 Texture 与 Button →
  无鼠标页边 mask → 火漆 Button。页边 mask 和装饰 Texture 都不接收鼠标。
- 菜单展开时若屏幕右侧不足，先保存任务书当前锚点，再按
  `max(0, frameRight + 48 - (screenRight - 8))` 只做一次临时左移；收起、
  Quest Log 隐藏或进入 fallback 时原样恢复。不得用常驻 `OnUpdate` 争夺几何。

### 状态机

| 状态 | 可见／交互 | 进入条件 | 离开条件 |
|---|---|---|---|
| `FALLBACK` | QS-A1 火漆保持普通无鼠标 Texture；旧八个底部／右页按钮全部可见可用 | 七个代理源、右上 Close、委托能力或静态媒体门禁任一不完整 | 全部 parity 条件成立并重新 Apply |
| `CLOSED` | 火漆为可点击 Button；七条事务签隐藏；旧八个 fallback 被抑制，右上 Close 保留 | parity 成立后的默认态；Quest Log 每次重新打开也从此态开始 | 左键火漆进入 `OPEN`；provider 失配进入 `FALLBACK` |
| `OPEN` | 七项同时出现；火漆保持 pressed；标签和 enabled 已从源对象同步 | 从 `CLOSED` 左键火漆 | 第二次点火漆、Esc、任务选择变化、detail 显隐变化、Quest Log 隐藏、世界点击、任务书空白点击或动作委托 |
| `DISPATCH` | 菜单已先收起并恢复临时位移；不显示 busy／spinner | 点击一个 enabled 事务项 | 调用对应源 Button 的 `:Click("LeftButton")` 后回到 `CLOSED`；源失效或调用失败立即进入 `FALLBACK` |

状态不写入 SavedVariables；登录、`/reload` 和每次重新打开任务书都从
`CLOSED` 或 `FALLBACK` 开始，不恢复上次展开态。

### 七项行为与标签

顺序和分组保持 V9，不增加二级菜单：

| 顺序 | 代理源 | 展示标签 | 点击结果 |
|---:|---|---|---|
| 1 | `QuestFramePushQuestButton` | 镜像源 Button 当前文字 | 先收起，再由源 Button 执行共享 |
| 2 | `QuestLogFrameExpandButton` | adapter 根据真实 detail 状态显示“收起详情”／“展开详情”；不显示原箭头字符 | 先收起，再调用同一 toggle Button |
| 3 | `pfQuest.buttonShow` | 镜像 pfQuest 本地化文字 | 先收起，再调用 pfQuest 显示位置逻辑 |
| 4 | `pfQuest.buttonHide` | 镜像 pfQuest 本地化文字 | 先收起，再调用 pfQuest 隐藏当前任务位置逻辑 |
| 5 | `pfQuest.buttonClean` | 镜像 pfQuest 本地化文字 | 先收起，再调用 pfQuest 清理全部 PFQUEST 节点逻辑 |
| 6 | `pfQuest.buttonReset` | 镜像 pfQuest 本地化文字；不得误改名为仅“重建当前标记” | 先收起，再调用 `pfQuest:ResetAll()` 的既有全量刷新逻辑 |
| 7 | `QuestLogFrameAbandonButton` | 镜像源 Button 当前文字；仅文字／短边使用克制酒红危险色 | 先收起，再调用原 Button；原生放弃确认框成为唯一后续层 |

- 除 detail toggle 的可读动态标签外，adapter 不硬编码、不翻译也不改写源行为
  语义。V1 不增加 Tooltip；七项都有可见文字，且不得以错误的 `this` 上下文
  手工执行源 `OnEnter／OnLeave`。
- 代理只允许调用源 Button 的 `:Click("LeftButton")`；不得复制 OnClick 函数
  正文，也不得直接取出 `GetScript("OnClick")` 后调用，因为 pfQuest／Vanilla
  脚本可能依赖 1.12 的 `this／arg1` 事件上下文。
- 点击 disabled 项不触发动作且菜单保持打开。enabled 状态在打开前、
  `QuestLog_Update`、`QuestLog_UpdateQuestDetails`、EmptyQuestLog 显隐、任务
  选择变化以及每次委托后事件驱动同步；不得用常驻轮询维护。
- 没有选中可执行任务时，分享、显示、隐藏、放弃及原生禁用项保持 disabled；
  火漆菜单本身仍可打开，使 pfQuest 的 Clean／Reset 等全局动作继续可达。
  detail 被收起时火漆仍留在现有右页纸面位置，条目文字变为“展开详情”，避免
  隐藏旧 toggle 后失去重新展开入口。

### 收起规则与非模态边界

- 保证收起：再次点火漆、点击任一 enabled 动作、Esc、Quest Log 关闭／隐藏、
  detail 显隐变化、任务选择变化、点击 WorldFrame 或任务书未被子控件占用的
  空白区域。
- Esc 只隐藏具名的 seal-menu Frame，不关闭整个 Quest Log；原 Quest Log 的
  下一次 Esc 行为仍由客户端处理。
- 不承诺拦截所有第三方 UI Frame 的点击。V1 不通过全屏 mouse catcher 伪造
  “任意位置 click-away”；这避免菜单变成模态层并吞掉其他插件的第一次点击。
- Show Map 等会打开／切换其他页面的动作一律先收起菜单，再交给源 Button，
  因而不会在新页面上遗留悬空事务签。
- 放弃确认被取消时菜单保持收起；玩家需要时重新点击火漆。AEUI 不在确认框
  之后自动重开菜单，也不创建第二个确认层。

### parity、旧按钮迁移与 fail-open

- 原子 parity 条件：七个源 Button 全部存在；每个源对象都保留真实 OnClick
  且支持 `:Click()`；detail toggle 已存在或由 AEUI 按既有合同创建；右上 Close
  可见可用；七项标签可解析；静态 addon package 含 QS-A1 与未来 QS-B1 atlas。
- parity 未全部成立时不做“部分菜单”：火漆不接管鼠标，分享／详情／放弃、
  pfQuest Show／Hide／Clean／Reset 以及底部 Exit fallback 全部原样保留。
- parity 全部成立后才同时抑制旧八个控件。Exit 不进入七项菜单，因为右上真实
  Close 已承担同一关闭职责；若右上 Close 缺失，则 parity 不成立，底部 Exit
  也不得隐藏。
- 被抑制的源 Button 仍保留脚本、enabled 状态和程序化 `:Click()` 能力；adapter
  只移除它们的视觉／鼠标入口。任一源在运行中失效时，菜单立即关闭、临时位移
  恢复、火漆退回装饰 Texture，并一次性恢复全部旧入口。
- late-load 只通过既有 Quest Log／pfQuest 刷新钩子重新评估；不新增维护型
  `OnUpdate`。`/aeui status` 的未来合同必须区分 `fallback／closed／open` 与
  parity 第一失败项，便于目标设备诊断。

### 未来 runtime 验收矩阵

进入 P5 前至少自动验证：无任务／无选择、普通选中任务、detail 收起后重新
展开、pfQuest 后加载、pfQuest 四控件缺一、Show Map 页面切换、Clean／Reset、
共享 disabled／enabled、放弃确认取消／确认、Esc 两阶段收起、WorldFrame 点击、
右缘 `8px` clamp、UI scale 变化、Quest Log 关闭重开，以及所有降级路径恢复
旧八个入口。真实客户端还必须验证标签字体、命中盒不越过页边、没有双重点击、
原生确认只出现一次、原 Button 业务效果与迁移前一致。

### 当前结论与下一门禁

- 用户结论与日期：`confirmed / 2026-08-05`；用户回复“接受”。
- 已冻结为 QS-B1 runtime 验收依据：非模态一级菜单、即时展开且无滑入动画、
  打开期间火漆使用 pressed 视觉、七条可见 Texture／右侧真实命中区分离、
  七项先收起再通过源 Button `:Click("LeftButton")` 委托、原生放弃确认、
  事件驱动 enabled 同步、无全屏挡板和旧八控件原子 fail-open。
- 本次接受只确认交互合同，不接受任何新 source 像素，不授权 ImageGen，
  不授权 Lua 接入，也不授权提前隐藏旧按钮。
- 下一门禁：用户独立授权 `QS-B1 V1` 最终生产正文、固定输入、冻结修复边界
  与最多五次实际 ImageGen 调用。

## Quest Log 克制型书口事务签 — `QS-B1 V1`

### 元数据

- 日期：`2026-08-03`
- 组件：`QUEST.LOG.ACTION.SEAL_MENU.TAB.BASE`
- 子状态：`internal-rejected / repair-prepared / 4/5`
- 项目阶段：`P3`
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`
- 操作：下一次为 `edit`；当前实际 ImageGen：`4/5`
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
- 每条 Texture 的可见盒固定为 `112×20px`；七个槽固定为
  `[612,112,112,20]`、`[612,134,112,20]`、`[612,159,112,20]`、
  `[612,181,112,20]`、`[612,203,112,20]`、`[612,225,112,20]`、
  `[612,250,112,20]`。菜单包络为 `[612,112,112,158]`，基础 Frame
  `676×464`，书外 outset `48px`。交互 Button 命中盒只使用每条右侧可见
  `[628,y,96,20]`；Texture 左侧 `16px` 延伸根部被页边遮住且不接收鼠标。
- 单条相对文字安全区为 `[18,1,80,18]`（`xywh`）；左侧 `16px` 是被真实
  页边遮住的安静根部，最右约 `6px` 只承担轻微削角和外缘磨损。任何文字、
  图标或识别装饰都不得进入源资产。
- 层序固定：QL-A1 shell → detail／奖励 → 七个 Button Texture → 无鼠标的
  QL-A1 真实页边 mask `[604,102,24,180]` → 已接受 QS-A1 漆章 Button。
  mask 复用现有 shell 像素，不生产新的 ImageGen 资产。
- 收起态只显示漆章；展开态显示七个 Button。具体状态、收起触发、enabled
  同步、源 Button `:Click()` 委托、原生放弃确认和 fail-open 以
  已确认的 `QS-B1-INTERACTION V1` 为合同；右键只保留为未来配置入口，
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
base skin. At runtime it will provide the 112 x 20 px visible texture for exactly
seven separate proxy Button objects; each Button uses only the rightmost visible
96 x 20 px as its mouse hit region while the left 16 px texture root extends
under the real page edge and never receives mouse input. The seven proxies cover
Share Quest, Detail Toggle, Show Location, Hide Location, Clean Marks, Reset
Marks, and Abandon Quest. The game owns all labels, icons, enabled states,
tooltips, click logic, and the native abandon confirmation. Do not draw seven
tabs, a menu, a book, a wax seal, any text, any icon, or any state variants.
Render exactly one normal-state base tab.

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
  权威职责；`1024²`／`784×140`／水平正投影；七个独立 Button、固定顺序、
  `112×20px` 可见 Texture 与右侧 `96×20px` 命中几何；八态确定性导出；
  页边遮根；色键／Alpha 策略；全部禁止烘焙与反模式。
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

### 当前门禁

- 当前状态：`candidate-rejected / user-rejected / repair-budget-exhausted / P3 / 5/5`。
- 当前实际生图：`5/5`；流程错误：`1`。
- 已发生：attempt 1 raw、确定性透明审查件、临时八态 atlas、真实排版与右缘
  clamp 预演；均只存在于 ignored `generated/`。尚未发生：source、manifest、
  runtime atlas、Lua/XML 接入或旧按钮隐藏。
- `QS-B1-INTERACTION V1` 已由用户于 `2026-08-05` 确认；该确认没有授权
  ImageGen、Lua 接入或旧按钮隐藏。
- `QS-B1 V1` 已由用户于 `2026-08-05` 以以下原文独立授权：`确认授权 QS-B1
  V1；允许每次上传固定 SHA 的 Image 1/2，
  允许同循环紧邻前次输出仅在冻结边界内作为 Image 3 edit 输入；最多 5 次实际
  ImageGen 调用，流程错误不占额度；允许按合同执行确定性边缘连通色键、透明
  RGB 清零与等比 bbox-fit。`
- 本授权只允许上述固定生产正文、固定 SHA 的 Image 1／2、受限同循环 Image 3
  edit、最多五次实际调用与合同内确定性后处理；不授权 source 晋级、P4／P5、
  Lua 接入或旧按钮隐藏。
- 当前下一门禁：V1 已被用户否决，禁止执行 attempt 6，也不再提出非等比／
  裁切例外。若用户要求继续，先建立 `QS-B1 V2` 的本地确定性模拟，重新确认
  可见菜单方向；之后再准备新的完整生产正文和独立五次预算。

### QS-B1 流程错误记录

| 流程错误 | 正文版本／commit | wrapper chunk | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `QS-B1 V1` / `65f83d5` | `37ebfe` | 固定 CLI 在 `1.85s` 内退出 `1`，仅输出 `Reading prompt from stdin... No prompt provided via stdin.`；没有输出文件、provider result 或生成作业证据。诊断确认 shell 实际构造了单一 `5665` 字节 prompt 参数，但 0.143.0 的 `--image <FILE>...` 把其继续解析为图片参数，导致位置 prompt 缺失 | 只在最后一个固定 Image 2 后增加参数终止符 `--`；正文、输入顺序、SHA、输出路径与授权边界均不变 | pre-generation transport error；不占额度，仍为 `0/5` |

### QS-B1 自主修复循环

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `QS-B1 V1` / `00bb6df` | generate；固定 Image 1／2；无 Image 3 | `019fcfbf-2e24-7d30-a01c-18c7bd5fa4fc`；固定 child 明确报告已生成，退出 `0` | `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-01/raw/QS-B1-V1.attempt-01.png`；`f85cb9fca759f38e4318e0b4503402d9afa33ab9a44357e1acf6d40c7bcf2ee2` | 轮廓／比例合同：raw 可见 bbox `1056×242`、`4.3636:1`，不在 `5.45..5.75`；等比缩小后的 runtime-visible `87×20px`，无法填满固定 `112×20px` 可见槽 | 保留单对象、无文字／图标／书／火漆／铆钉、水平正视、暗胡桃主体和已通过的七槽装配；完整亮铜框、过圆外端、密集微纹理与全局 bevel 需要整体重生，因此 attempt 2 不上传 Image 3 | `internal-rejected / repair-prepared` |

### Attempt 1 执行与完整复审

- 日期：`2026-08-05`。
- 固定输入：Image 1
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`；
  Image 2
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`；
  没有 Image 3。
- prompt 传输：执行器逐字显示完整 `QS-B1 V1`；没有段落丢失或 revised
  prompt 报告。child 的只读工作区使生成文件先落到同 session 的
  `.codex/generated_images`，父流程只做 bit-identical copy；仓库 raw SHA
  如上。
- raw：`1254×1254 RGB`；边缘连通背景 `1,319,050` 像素、`3,496`
  种 RGB、纯 `#00FF00` 比例 `0`；可见 bbox
  `[107,500,1163,742]`，比例 `4.3636:1`。
- 确定性审查器：
  `tools/review_quest_log_action_tab_candidate_v1.py`。只执行边缘连通色键、
  透明 RGB 清零、等比 bbox-fit、临时八态和真实排版；没有非等比变形或重绘。
- 归一化审查件：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-01/review/QS-B1-V1.attempt-01.normalized-review.png`，
  `1024² RGBA`，SHA
  `e88f45b9ac0699a9e659b4d346483b424be5c48bb266398bed3fd7d149599f66`；
  bbox `[207,442,818,582]`、`611×140`，透明 RGB 全零，可见纯绿与绿色
  优势像素均为 `0`。其 `87×20px` 运行时可见 bbox 证明原图比例不能靠
  合法等比 fit 补成 `112×20px`。
- 接触表：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-01/review/QS-B1-V1.attempt-01.contact-sheet.png`，
  SHA `f9498daf14750521c3abdd187d7c1a39b9611bf1ae24b60bdd08fa62c0d33ea3`。
- 100% 真实排版：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-01/review/QS-B1-V1.attempt-01.real-layout.png`，
  SHA `a567a7bb3a951d9c461a87ec9c8b5c4ad2b57c2b7ab0c21c62c519a67d6e4002`；
  使用当前 QL-A1 书体、18 行任务、代表性长详情、四个奖励槽、七个真实中文
  标签及 normal／hover／pressed／disabled／danger 分布。
- 右缘 clamp：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-01/review/QS-B1-V1.attempt-01.right-clamp.png`，
  SHA `31246f82bad56dbaacec381a42cb3b5574d63f00bf81f3f99ee9cb949a5d0012`；
  `1024px` 屏幕中展开宽 `724px`，整书左移后最右边保持 `8px`。
- display-region：七槽、页边遮根、`96×20px` hit、文字安全区、detail／
  reward 零覆盖、Close 避让和右侧 `48px` outset 共 `25/25 pass`。这只
  证明布局合同，没有把母版美术判为通过。
- 视觉第一失败：近矩形比例退化为短粗 `4.3636:1`，左根也有明显圆角，
  右端形成大半径圆帽和多层沟槽，物件更像现代 bevel button，而不是
  `5.6:1` 的长薄书口卷宗签。
- 视觉次要失败：上、下、右形成连续高对比铜金内外框；整个表面充满均匀
  高频皮纹和锐利反光，缺少香草魔兽的大块手绘明暗切面与克制磨损。综合色
  过红、过亮、过精细，抢过任务书和火漆焦点。
- 已通过并必须保留：恰好一个对象；无文字、图标、书、纸页、火漆、铆钉或
  状态组；水平正视；暗胡桃皮革主体与底部厚度可读；七个独立 Button 的真实
  排版、页边 mask、命中盒和功能所有权没有改变。
- 修复决策：`regenerate`。失败覆盖全局比例、两端、表面频率、边框和
  光照，不能冻结一个正确主体后做局部 edit；attempt 2 固定上传 Image 1／2，
  不上传 attempt 1 作为 Image 3。
- source／runtime：无；不得晋级或接入。

### 下一完整执行正文 — `QS-B1 V1.r1`

Create exactly one new isolated 2D hand-painted bitmap UI object for a
vanilla-era World of Warcraft quest log: one long, thin, text-free guild-ledger
transaction index tab made primarily from aged dark-walnut leather. This is one
normal-state reusable base skin, not a complete menu and not a finished modern
button. At runtime the same base will be reduced to a visible 112 x 20 px texture
for exactly seven separate proxy Button objects. Each runtime Button uses only
the rightmost visible 96 x 20 px as its mouse hit region; the leftmost 16 x 20 px
texture root extends under the real book-page edge and never receives mouse
input. The seven proxy functions are Share Quest, Detail Toggle, Show Location,
Hide Location, Clean Marks, Reset Marks, and Abandon Quest. The game owns all
labels, icons, enabled states, tooltips, click logic, and native abandon
confirmation. Render exactly one tab and no other object. Do not draw seven
tabs, a menu, a book, a wax seal, any text, any icon, or any state variants.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit its circa-2004 vanilla WoW
   low-resolution hand-painted bitmap language, broad readable value planes,
   warm upper-left light, muted warm expedition palette, heavy but restrained
   material separation, and sparse edge wear. Ignore its complete book layout,
   parchment pages, long leather plaques, compass, wax seals, ribbons, text,
   buttons, rivets, bright gold ornaments, and all complete UI compositions.
2. Image 2 is a secondary adjacency reference only. Inherit only the current
   accepted quest book's smoked dark-walnut hue, soft hand-painted edge scale,
   upper-left light direction, and restrained wear so this small tab belongs
   beside that exact book. Ignore its complete book silhouette, parchment,
   spine, stitches, brass corners, transparent surroundings, and all directly
   reusable pixels. If the references conflict, Image 1 plus the vanilla
   hand-painted rules wins; Image 2 may only tune local color and paint scale.

Canvas and exact occupancy: output an exact 1024 x 1024 RGB bitmap. Every pixel
outside the object must be one uniform solid #00FF00 chroma-key background, with
no gradient, noise, texture, vignette, checkerboard, haze, color spill, floor,
reflection, contact shadow, or cast shadow. The visible object must be a long
thin 5.6:1 shape occupying target bbox [120,442,904,582], exactly 784 x 140 px.
Its left visible edge begins at x=120, its right visible edge ends at x=904, its
top edge is at y=442, and its bottom edge is at y=582. Keep it horizontal,
unrotated, centered, and fully separated from the green background. Use a
straight-on orthographic front view with no perspective tilt and essentially no
foreshortening. The source must read as 112 x 20 when reduced seven-to-one. Do
not shorten it into a 4:1 or 4.5:1 button, and do not add internal green padding
that would make the visible runtime object narrower than 112 px.

Silhouette and physical construction: make a quiet, heavy, handcrafted long
near-rectangle, never a rounded web control. The long top and bottom edges are
mostly parallel with only one-to-two percent broad hand-painted irregularity.
The left root edge is a plain vertical cut with zero corner radius and no cap,
because the first 16 runtime pixels disappear under the real page edge. The
right outer end is also fundamentally vertical and near-square. Its only corner
treatment is a very shallow chamfer no larger than three percent of the source
height; do not make a semicircular end, rounded cap, capsule, pill, arch, point,
arrow, chevron, notch, fishtail, or bookmark tail. Give the leather restrained
thickness using one broad dark-walnut face, one narrow deep-umber lower edge,
and one short broken warm upper-left paint stroke. The object must not have a
recessed center panel, raised perimeter rail, double bevel, inner groove, or
button-like inset face.

Material frequency and edge treatment: use only two or three broad hand-painted
value planes. The face is low-saturation smoked dark walnut, darker and quieter
than bright red-brown polished leather. Do not fill it with uniform fine grain,
cross-hatching, procedural pores, embossed texture, photorealistic leather, or
many tiny highlights. Use at most three or four broad low-contrast scuffs,
concentrated near the far outer end and lower edge, each large enough to survive
the reduction to 112 x 20. Preserve a broad quiet center for runtime labels.

There must be no complete outline around the object. Do not draw a continuous
gold, copper, brass, orange, or bright leather border; do not draw an inner and
outer frame; do not draw a luminous top rim. Oxidized-brass color may appear
only as two or three very short, broken, dim binding flecks along parts of the
lower edge and far right edge. Their combined length must be less than one
quarter of the perimeter, their brightness must not exceed the restrained
leather mid-highlight, and they must never connect into a frame, cap, plaque,
groove, or polished trim. Edge contrast must remain subordinate to the paper
book and wax seal.

Runtime-safe regions: keep source coordinates [246,449,806,575] quiet and free
of seams, emblems, high-contrast scratches, bright highlights, or ornament so
dynamic labels remain readable. The first 112 source pixels of the visible
object form a straight, plain hidden root. The last 42 source pixels contain
only the shallow corner chamfers and sparse low-contrast wear. Do not bake any
runtime text, icon, glyph, enabled state, Tooltip, danger state, selection state,
or click affordance into this base image. The asset is fixed-size; it will not
be stretched, tiled, mirrored, repeated, or nine-sliced.

Style lock: paint this as a small sprite made for a 2004-era vanilla WoW
interface. Use coarse deliberate brush decisions, broad readable shapes, a warm
muted Azeroth expedition palette, tangible but simple leather thickness, sparse
wear, and modest upper-left light. It must feel like a physical archival docket
tab stored inside the accepted quest journal, not a modern UI component placed
on top of it. It must remain subordinate to the book page and red wax seal. It
must not look photorealistic, vector-clean, procedural, uniformly textured,
glossy, precision-machined, Diablo-3-like, or like a modern brown web button.

Strict exclusions: no book, page, parchment, paper strip, ribbon, strap, wax,
seal, menu panel, button stack, frame, text, letters, numerals, glyphs, icons,
compass, quill, emblem, rune, stitching, holes, rivets, studs, buckles, hinges,
embossing, inset panel, recessed groove, double bevel, continuous metallic
outline, bright gold trim, symmetrical flourish, glow, glass, translucent
black, neon, gemstone, skull, spike, altar, rounded pill, capsule, arrowhead,
pointed bookmark, cast shadow, contact shadow, or loose pixels outside the
single object.

Before returning the image, verify all of the following: exactly one object and
one normal state; exact 1024 x 1024 RGB canvas; one uniform #00FF00 background;
visible bbox exactly 784 x 140 at [120,442,904,582]; visible aspect exactly
5.6:1; straight square-cut left root; near-square right end with only tiny
chamfers; no rounded cap; no inner groove or double bevel; no complete bright
border; no fine procedural leather grain; no text, icon, rivet, book, page,
seal, menu, or state variants. At 112 x 20 it must read as a long restrained
archival leather docket tab, never as a short modern beveled button.

### Attempt 2 执行与完整复审

- 日期：`2026-08-05`；执行前 commit `8b598c1`。
- 固定输入：Image 1／2 的路径、顺序与 SHA 与授权完全相同；按 regenerate
  决策没有上传 Image 3。
- 固定执行器 session：
  `019fcfc9-83a9-7492-8fdf-ca96c2551c8b`；完整 `QS-B1 V1.r1` 已显示，
  没有 prompt 截断或 revised prompt；child 明确报告生成完成，故计为
  `2/5`。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-02/raw/QS-B1-V1.attempt-02.png`，
  SHA `628fdf9a107dba5085bdc76d291d07d5d99418f602b94c8a4f5751950eec689c`；
  `1254×1254 RGB`，可见 bbox `[97,503,1164,752]`、
  `1067×249`、`4.2851:1`。
- 确定性归一化：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-02/review/QS-B1-V1.attempt-02.normalized-review.png`，
  SHA `4e3ca185894e02a099ecb3f92fdefa653dc6aab620df6bb48178b8e6cd5bea28`；
  `1024² RGBA`，bbox `[212,442,812,582]`、`600×140`，透明 RGB
  全零，可见绿色残留 `0`。合法等比缩小后的 runtime-visible 为
  `86×20px`，仍不能满足固定 `112×20px` 槽。
- 接触表：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-02/review/QS-B1-V1.attempt-02.contact-sheet.png`，
  SHA `b666c855df67addbfcd76f056d309be1fcc5f13a73ccd2706bc839ffa67a6ee6`。
- 100% 真实排版：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-02/review/QS-B1-V1.attempt-02.real-layout.png`，
  SHA `c7c4a6a1c26c723583eb49ec2d84a3afee0b2b61818c3a90685d812fbfbc2af2`；
  右缘 clamp SHA
  `236c4aa248d010d6099aecba5e839bc1cf3cfcb5a896fb45a663d66e616549f2`。
  七槽／页边遮根／hit／文字安全区／18 行／四奖励／detail 零覆盖仍为
  `25/25 pass`。
- 第一失败门禁：轮廓比例再次低于 `5.45..5.75`，且比 attempt 1 更短粗；
  这会在固定宽槽左右各产生约 `13px` 透明空段。不能用非等比 runtime 拉伸
  修复。
- 已改善并冻结：恰好一个对象；左根已经直切；右端已经接近方形浅削角；
  完整内外亮框、圆帽和明显 3D groove 已消失；暗胡桃综合色、安静中心、
  下缘厚度和少量磨损在 100% 排版中与书体相容；无动态文字或图标。
- 次要待修：上边仍形成几乎全长的暖亮线，右端仍有连续偏亮竖边；二者在七条
  重复后形成过工整节奏，应打断并压低。
- 修复决策：`edit`。主体身份、端部、材料和综合色已正确，失败可冻结为
  “保留现有正确像素语言，只重绘纵向厚度和两处连续高光”；attempt 3 固定
  上传同 SHA Image 1／2，并且只上传本 attempt 2 raw 作为 Image 3。
- source／runtime：无；不得晋级或接入。

### 下一完整执行正文 — `QS-B1 V1.r2`

Edit Image 3 into exactly one isolated 2D hand-painted bitmap UI object for a
vanilla-era World of Warcraft quest log: one long, thin, text-free guild-ledger
transaction index tab made primarily from aged dark-walnut leather. Image 3 is
the immediately previous candidate and the sole edit target. Preserve its
correct single-object identity, smoked dark-walnut palette, quiet central face,
plain square-cut left root, near-square shallow-chamfered right end, narrow
deep-umber lower thickness, sparse lower-edge wear, lack of an inset panel, and
lack of text, icons, rivets, book parts, wax, or state variants. Repaint its
proportions and edge lighting as specified below; do not create a second object
and do not turn it into a menu or finished modern button.

Runtime identity and ownership: the edited result is one normal-state reusable
base skin. It will be reduced to a visible 112 x 20 px texture shared by exactly
seven separate proxy Button objects. Each Button uses only the rightmost visible
96 x 20 px as its mouse hit region; the leftmost 16 x 20 px texture root extends
under the real book-page edge and never receives mouse input. The seven proxy
functions are Share Quest, Detail Toggle, Show Location, Hide Location, Clean
Marks, Reset Marks, and Abandon Quest. The game owns all labels, icons, enabled
states, tooltips, click logic, and native abandon confirmation. Render exactly
one tab and one normal state. Do not bake any dynamic content or interaction
state into the bitmap.

Reference authority and filtering:
1. Image 1 remains the highest visual authority. Inherit its circa-2004 vanilla
   WoW low-resolution hand-painted bitmap language, broad readable value
   planes, warm upper-left light, muted warm expedition palette, restrained
   material separation, and sparse edge wear. Ignore its full book, parchment,
   long plaques, compass, seals, ribbons, text, buttons, rivets, bright gold
   ornament, and complete compositions.
2. Image 2 remains a secondary adjacency reference only. Inherit only the
   accepted quest book's smoked dark-walnut hue, edge softness, paint scale,
   upper-left light direction, and restrained wear. Ignore the full book
   silhouette, parchment, spine, stitches, brass corners, transparent
   surroundings, and directly reusable pixels.
3. Image 3 is the edit target, not a higher visual authority. Preserve only the
   correct features listed in the first paragraph. Correct its wrong short,
   thick 4.3:1 silhouette, nearly continuous upper highlight, and continuous
   bright right edge. If any input conflicts, Image 1 plus the vanilla
   hand-painted rules wins; Image 2 only tunes adjacency, and Image 3 only
   supplies the frozen correct subject and material base.

Canvas and exact occupancy: output an exact 1024 x 1024 RGB bitmap. Every pixel
outside the object must be one uniform solid #00FF00 chroma-key background, with
no gradient, noise, texture, vignette, checkerboard, haze, spill, floor,
reflection, contact shadow, or cast shadow. On a 1024 canvas, place the visible
object exactly in bbox [120,442,904,582], exactly 784 x 140 px and exactly 5.6:1.
Equivalently, the visible object must occupy 76.5625 percent of the canvas width
and only 13.671875 percent of the canvas height. Keep it centered, horizontal,
unrotated, straight-on, orthographic, and fully separated from the green.
The visible width divided by visible height must be between 5.5 and 5.7. Do not
return a 4:1, 4.3:1, 4.5:1, or otherwise short thick object.

Proportion edit: reduce the visible vertical thickness substantially and
repaint the broad leather planes to fit the new long-thin silhouette. Do not
mechanically squash high-frequency texture; keep the existing broad quiet
center and re-establish one broad face plus one much narrower lower thickness.
The object must fill the full 112 x 20 runtime footprint after proportional
downsampling, with no transparent left or right gutters inside that footprint.
Keep a generous field of green above and below. The top and bottom edges remain
mostly parallel with only one-to-two percent broad hand-painted irregularity.

End geometry: keep the Image 3 left root as a plain vertical square cut with
zero radius, zero cap, and no ornament. Keep the right end fundamentally
vertical and near-square, with only tiny corner chamfers no larger than three
percent of the edited object height. No semicircular end, rounded cap, capsule,
pill, arch, point, arrow, chevron, notch, fishtail, or bookmark tail. Do not add
a recessed center, raised perimeter rail, inner groove, double bevel, or
button-like inset face.

Edge-light edit: remove the almost full-length bright upper line from Image 3.
Replace it with no more than two short, broken, low-contrast warm leather
highlights whose combined length is below twenty percent of the long edge.
Darken and interrupt the bright right vertical edge so it reads as leather
thickness, not a polished metal cap or luminous bevel. There must be no complete
outline around the object. Oxidized-brass color may appear only as two or three
short dim flecks along parts of the lower edge and far right, together covering
less than one quarter of the perimeter and never connecting into a frame.

Material frequency: preserve the improved low-saturation smoked dark-walnut
face from Image 3, but keep it painted in only two or three broad value planes.
No uniform fine grain, cross-hatching, procedural pores, photorealistic leather,
many tiny highlights, glossy polish, or precision-machined bevel. Retain at most
three or four broad low-contrast scuffs near the far right and lower edge.
Preserve a broad quiet center for runtime labels and keep the tab subordinate to
the parchment book and red wax seal.

Runtime-safe regions: keep source coordinates [246,449,806,575] free of seams,
emblems, high-contrast scratches, bright highlights, and ornament. The first
112 source pixels of the visible object are a straight plain hidden root. The
last 42 source pixels contain only tiny chamfers and sparse low-contrast wear.
The asset is fixed-size and must not be stretched, tiled, mirrored, repeated, or
nine-sliced. Do not draw labels, glyphs, icons, enabled state, tooltip, danger
state, selection state, or click affordance.

Style lock: retain a 2004-era vanilla WoW sprite language with coarse deliberate
brush decisions, broad readable shapes, warm muted Azeroth expedition colors,
tangible but simple leather thickness, sparse wear, and modest upper-left
light. The result must feel like a physical archival docket tab stored inside
the accepted quest journal, not a modern UI control laid over it. It must not
look photorealistic, vector-clean, procedural, uniformly textured, glossy,
Diablo-3-like, Skyrim-minimalist, or like a modern brown web button.

Strict exclusions: no book, page, parchment, paper strip, ribbon, strap, wax,
seal, menu panel, button stack, frame, text, letters, numerals, glyphs, icons,
compass, quill, emblem, rune, stitching, holes, rivets, studs, buckles, hinges,
embossing, inset panel, recessed groove, double bevel, continuous metallic
outline, continuous top highlight, bright right cap, bright gold trim,
symmetrical flourish, glow, glass, translucent black, neon, gemstone, skull,
spike, altar, rounded pill, capsule, arrowhead, pointed bookmark, cast shadow,
contact shadow, or loose pixels outside the single object.

Before returning the image, verify: Image 3 was edited rather than surrounded by
new objects; exactly one object and one normal state; exact 1024 x 1024 RGB
canvas; uniform #00FF00 background; exact 784 x 140 visible bbox at
[120,442,904,582]; aspect between 5.5 and 5.7; no transparent horizontal gutters
after fitting to 112 x 20; square-cut left root; near-square right end with only
tiny chamfers; no rounded cap, inset face, groove, double bevel, continuous
highlight, complete border, text, icon, rivet, book, page, seal, menu, or state
variants. The final 112 x 20 sprite must read as one long restrained archival
leather docket tab that preserves Image 3's improved dark-walnut material.

### Attempt 3 执行与完整复审

- 日期：`2026-08-05`；执行前 commit `1d744ae`。
- 实际输入：固定 SHA 的 Image 1／2，以及紧邻 attempt 2 raw
  `628fdf9a107dba5085bdc76d291d07d5d99418f602b94c8a4f5751950eec689c`
  作为唯一 Image 3 edit target；没有其他上传。
- 固定执行器 session：
  `019fcfcd-dd5e-7b21-a104-8644d51e7fe9`；完整 `QS-B1 V1.r2` 已显示，
  无截断或 revised prompt；child 明确报告 edit 已生成，故计为 `3/5`。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-03/raw/QS-B1-V1.attempt-03.png`，
  SHA `e14fac55b0153baa532c77134996c988dd12eac622ad5a125d381beab65645ee`；
  `1254² RGB`，可见 bbox `[99,525,1159,731]`、
  `1060×206`、`5.1456:1`。
- 确定性归一化：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-03/review/QS-B1-V1.attempt-03.normalized-review.png`，
  SHA `9879f0604dee15d2a35f6f602902030e8dc9d952a6ca52a0f4917516c7a37860`；
  bbox `[152,442,872,582]`、`720×140`，透明 RGB／绿色残留均为
  `0`；runtime-visible `103×20px`。比例仍低于 `5.45`，但与
  attempt 2 的 `86×20px` 相比已显著接近。
- 接触表 SHA：
  `3465f2a891e48b3f7723992741245b2350b6fa9a8c3e3e020d6186d1b3881268`；
  100% 真实排版 SHA：
  `e53c3768450e6b408270388fc86db8941b421b008452c08a61e59f1d0c1b90c9`；
  右缘 clamp SHA：
  `fcfd18b6e22ae313435a5f43b789a49518295d267d44b49c153a69b8201842d3`。
- display-region：七槽、页边遮根、hit、标签、detail／reward、18 行、四奖励
  与 `8px` 右缘 clamp 重新检查，仍为 `25/25 pass`。
- 第一失败门禁：raw 比例 `5.1456:1` 仍未进入 `5.45..5.75`；合法等比
  导出不能用非等比拉伸补足剩余 `9px` 水平可见宽。
- 美术复审：整体轮廓、综合色、方形端部和克制边线继续成立，100% 排版比
  attempt 2 更接近 V9 重量；但表面重新出现均匀的高频皮纹，中央至右中的
  斜向亮擦痕穿过动态文字安静区。顶部高光已弱化但仍接近连续。
- 已冻结：单对象、无动态内容、直切左根、浅削角近方右端、暗胡桃低饱和、
  下缘厚度、无内框／圆帽／铆钉／亮金属框，以及所有真实排版几何。
- 修复决策：`edit`。只需把紧邻 attempt 3 的可见高度再降低约 `8%`，
  同时用两三块低频手绘值面覆盖均匀微纹和中央擦痕；不重开构图或对象。
- source／runtime：无；不得晋级或接入。

### 下一完整执行正文 — `QS-B1 V1.r3`

Edit Image 3 into one final isolated 2D hand-painted bitmap UI object for a
vanilla-era World of Warcraft quest log: one long, thin, text-free guild-ledger
transaction index tab made from aged smoked dark-walnut leather. Image 3 is the
immediately previous candidate and the sole edit target. Preserve its correct
single-object identity, horizontal orthographic view, plain square-cut left
root, near-square right end with shallow corner chamfers, dark-walnut palette,
narrow deep-umber lower thickness, quiet restrained outline, sparse lower-edge
wear, and absence of text, icons, rivets, inset panel, book parts, wax, menu, or
state variants. Change only the remaining proportion error, surface-frequency
error, central abrasion, and continuous edge-light error described below.

Runtime identity and ownership: this is one normal-state reusable base skin,
not a complete menu and not a modern finished button. It will be reduced to a
visible 112 x 20 px texture shared by exactly seven separate proxy Button
objects. Each Button uses only the rightmost visible 96 x 20 px as its mouse hit
region; the leftmost 16 x 20 px root goes under the real book-page edge and never
receives mouse input. The seven functions are Share Quest, Detail Toggle, Show
Location, Hide Location, Clean Marks, Reset Marks, and Abandon Quest. The game
owns all labels, icons, enabled states, tooltips, click logic, and native abandon
confirmation. Render exactly one tab and one normal state; bake no dynamic
content or interaction state into the bitmap.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit its circa-2004 vanilla WoW
   low-resolution hand-painted language, broad readable value planes, warm
   upper-left light, muted expedition palette, restrained material separation,
   and sparse edge wear. Ignore its complete book, parchment, plaques, compass,
   seals, ribbons, text, buttons, rivets, bright gold ornament, and full layout.
2. Image 2 only controls adjacency: inherit the accepted quest book's smoked
   dark-walnut hue, edge softness, paint scale, upper-left light, and restrained
   wear. Ignore its complete silhouette, parchment, spine, stitches, brass
   corners, transparent surroundings, and directly reusable pixels.
3. Image 3 is the edit target, not a higher style authority. Preserve only the
   frozen correct features in the first paragraph. Correct its current
   approximately 5.15:1 silhouette, uniform micro-grain, diagonal bright abrasion
   across the central text-safe face, and near-continuous top edge light. Image 1
   plus the vanilla rules wins any conflict; Image 2 only tunes adjacency.

Canvas and exact occupancy: output an exact 1024 x 1024 RGB bitmap. Every pixel
outside the object is one uniform solid #00FF00 chroma-key background with no
gradient, noise, texture, vignette, checkerboard, haze, spill, floor, reflection,
contact shadow, or cast shadow. On a 1024 canvas, the visible object occupies
exact bbox [120,442,904,582], exactly 784 x 140 px and 5.6:1. This equals
76.5625 percent of canvas width and 13.671875 percent of canvas height. Keep the
object centered, horizontal, unrotated, straight-on, orthographic, and separated
from green. Visible width divided by visible height must be between 5.50 and
5.70. Never return a 5.15:1 or shorter, thicker object.

Focused proportion edit: keep Image 3's visible width and end positions, but
reduce its visible height by approximately eight percent around the same
horizontal centerline. Repaint the face and lower thickness to fit this slightly
thinner silhouette; do not merely squeeze its existing micro-texture. The result
must fill the full 112 x 20 runtime footprint after proportional downsampling,
with no transparent left or right gutters. Keep generous green above and below.
The long top and bottom edges remain mostly parallel with only one-to-two percent
broad hand-painted irregularity.

End geometry: preserve Image 3's plain vertical left cut with zero radius, cap,
or ornament. Preserve its fundamentally vertical near-square right end, reducing
the chamfers if needed so each remains no larger than three percent of the new
object height. No semicircular end, rounded cap, capsule, pill, arch, point,
arrow, chevron, notch, fishtail, bookmark tail, recessed center, raised perimeter
rail, inner groove, double bevel, or button-like inset face.

Surface repaint: remove the uniform fine leather pattern visible across Image 3.
Replace it with only two or three broad, softly hand-painted dark-walnut value
planes. Completely remove the diagonal light abrasion that crosses the middle
and right-middle of the face. The entire runtime text-safe center must be calm
and low contrast, with no seam, scratch, swirl, embossed grain, cross-hatching,
procedural pore pattern, or repeated texture. Retain at most three broad,
low-contrast scuffs, only near the far right and lower edge, large enough to
survive reduction to 112 x 20.

Edge-light repaint: break the remaining top light into at most two short dim
warm leather strokes whose combined length is less than fifteen percent of the
long edge. Darken and interrupt the right vertical edge so it reads as leather
thickness, not a metal cap or luminous bevel. Keep the lower deep-umber thickness
narrow. There must be no complete outline. Oxidized-brass color may survive only
as two or three short dim flecks along parts of the lower and far-right edge,
covering less than one quarter of the perimeter and never joining into a frame.

Runtime-safe regions: keep source coordinates [246,449,806,575] free of seams,
emblems, high-contrast scratches, bright highlights, repeated grain, and
ornament. The first 112 source pixels of the visible object remain a straight,
plain hidden root. The last 42 source pixels contain only tiny chamfers and
sparse low-contrast wear. This fixed-size asset must not be stretched, tiled,
mirrored, repeated, or nine-sliced. Do not draw labels, glyphs, icons, enabled
state, tooltip, danger state, selection state, or click affordance.

Style lock: use a 2004-era vanilla WoW sprite language with coarse deliberate
brush decisions, broad readable shapes, warm muted Azeroth expedition colors,
tangible but simple leather thickness, sparse wear, and modest upper-left
light. It must feel like an archival docket tab stored inside the accepted quest
journal and remain subordinate to parchment and the red wax seal. It must not
look photorealistic, vector-clean, procedural, uniformly textured, glossy,
precision-machined, Diablo-3-like, Skyrim-minimalist, or like a modern brown web
button.

Strict exclusions: no book, page, parchment, paper strip, ribbon, strap, wax,
seal, menu panel, button stack, frame, text, letters, numerals, glyphs, icons,
compass, quill, emblem, rune, stitching, holes, rivets, studs, buckles, hinges,
embossing, inset panel, recessed groove, double bevel, uniform micro-grain,
central diagonal abrasion, continuous metallic outline, continuous top
highlight, bright right cap, bright gold trim, symmetrical flourish, glow,
glass, translucent black, neon, gemstone, skull, spike, altar, rounded pill,
capsule, arrowhead, pointed bookmark, cast shadow, contact shadow, or loose
pixels outside the object.

Before returning the image, verify: Image 3 remains the sole edited object;
exactly one object and one normal state; exact 1024 x 1024 RGB canvas; uniform
#00FF00 background; exact 784 x 140 visible bbox at [120,442,904,582]; visible
aspect between 5.50 and 5.70; no transparent horizontal gutters at 112 x 20;
square-cut left root; near-square right end with tiny chamfers; broad quiet
two-or-three-plane leather face; no uniform micro-grain, central abrasion,
continuous highlight, complete border, text, icon, rivet, book, page, seal,
menu, or state variants. The final sprite must preserve Image 3's restrained
dark-walnut identity while becoming visibly thinner and quieter.

### Attempt 4 执行与完整复审

- 日期：`2026-08-05`；执行前 commit `1c70335`。
- 实际输入：固定 Image 1／2；紧邻 attempt 3 raw
  `e14fac55b0153baa532c77134996c988dd12eac622ad5a125d381beab65645ee`
  是唯一 Image 3；无其他上传。
- 固定执行器 session：
  `019fcfd2-a3de-74c2-a6d5-2040e2634f6b`；完整 `QS-B1 V1.r3` 已显示，
  无截断／revised prompt，ImageGen 明确返回结果，计为 `4/5`。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-04/raw/QS-B1-V1.attempt-04.png`，
  SHA `53079531d3b4d6ad50bfa3c16b00057f3233e38ffaaafe50d81da03d6849ae5e`；
  `1254² RGB`，bbox `[100,530,1160,735]`、`1060×205`、
  `5.1707:1`。
- 确定性归一化 SHA：
  `193bdfdb74448eff199917212a9dacaccc79e11f6e22dcd7fc3dd0032617547a`；
  bbox `[150,442,874,582]`、`724×140`，透明 RGB／绿色残留 `0`，
  runtime-visible 仍为 `103×20px`。
- 接触表 SHA：
  `9c5cee6aba2dff3339ca102cf63700cbddf590d1e5340b30370523f21201031c`；
  真实排版 SHA：
  `573ff6b078f2dfbf98169171cec61c4cbbfaaca503f2ca9439f9619d65d1d5ed`；
  clamp SHA：
  `7d8002ed914b741b972cedd49158c1e16200903043b480a80a29747c7a93224a`；
  display-region 再次 `25/25 pass`。
- 第一失败门禁仍为同一比例合同：`5.1707 < 5.45`。attempt 4 相比
  attempt 3 仅减少 `1px` 可见高度，泛化“压薄／低频重绘”策略没有产生
  实质修复。
- 美术复审：单对象、方端、暗胡桃综合色、下缘厚度和 100% 排版重量保持；
  高频纹理比 raw 层面仍明显，但在 `112×20px` 已弱化。中央擦痕对 1×
  动态标签不再形成首要阻塞；客观比例仍必须先通过。
- 策略改变：最终 attempt 5 不再要求开放式重绘。对紧邻 attempt 4 做定量
  silhouette surgery：保持 `1060px` 可见宽，把 `205px` 可见高明确改到
  `187..191px`，等量从上下轮廓去除并用纯绿补回，再重画窄边；其他像素语言
  尽量冻结。仍属于同一对象、画布和比例合同。
- source／runtime：无；不得晋级或接入。

### 最终完整执行正文 — `QS-B1 V1.r4`

Precisely edit Image 3 into exactly one isolated 2D hand-painted bitmap UI
object for a vanilla-era World of Warcraft quest log: one long, thin, text-free
guild-ledger transaction index tab made from aged smoked dark-walnut leather.
Image 3 is the immediately previous candidate and the sole edit target. This is
the final bounded repair call. Preserve Image 3's one-object identity, exact
visible width, horizontal orthographic orientation, square-cut left root,
near-square shallow-chamfered right end, dark-walnut palette, broad quiet face,
narrow deep-umber lower thickness, restrained edge wear, and absence of text,
icons, rivets, inset panel, book, page, wax, menu, or state variants.

Perform a precise silhouette surgery, not another open-ended redesign. Image 3's
current visible object is approximately 1060 pixels wide by 205 pixels high on
its returned 1254 x 1254 canvas. Keep the visible width at 1060 pixels and keep
the left and right endpoints in the same positions. Reduce the visible height
to between 187 and 191 pixels, centered on the same horizontal centerline.
Remove approximately 7 to 9 pixels of object from the top and 7 to 9 pixels from
the bottom, replace those removed exterior pixels with the same uniform green
background, then repaint only the new narrow top and bottom leather boundaries.
The final visible aspect must be between 5.55:1 and 5.67:1. Do not return another
5.15:1 or 5.17:1 object.

Runtime identity and ownership: this edited bitmap is one normal-state reusable
base skin. It will be proportionally reduced to one visible 112 x 20 px texture
shared by exactly seven separate proxy Button objects. Each Button uses only the
rightmost visible 96 x 20 px as its mouse hit region; the leftmost 16 x 20 px
root extends under the real book-page edge and never receives mouse input. The
seven functions are Share Quest, Detail Toggle, Show Location, Hide Location,
Clean Marks, Reset Marks, and Abandon Quest. The game owns all labels, icons,
enabled states, tooltips, click logic, and native abandon confirmation. Render
one tab and one normal state only. Bake no dynamic content or interaction state.

Reference authority:
1. Image 1 remains the highest visual authority for circa-2004 vanilla WoW
   low-resolution hand-painted language, broad value planes, muted warm
   expedition colors, upper-left light, and sparse wear. Ignore its complete
   book, parchment, plaques, compass, seals, ribbons, text, buttons, rivets,
   bright gold ornament, and full composition.
2. Image 2 remains secondary and only tunes adjacency to the accepted quest
   book's smoked dark-walnut hue, edge softness, paint scale, light direction,
   and wear. Ignore its complete book silhouette, pages, spine, stitches, brass
   corners, transparent surroundings, and directly reusable pixels.
3. Image 3 is the sole edit target and supplies the frozen correct object.
   It is not higher style authority. Change its vertical silhouette as
   quantified above; preserve the correct subject, endpoints, palette, end
   geometry, and broad face. Image 1 plus the vanilla rules wins conflicts.

Canvas and background: prefer an exact 1024 x 1024 RGB result with visible bbox
[120,442,904,582], exactly 784 x 140 px. If the edit pipeline retains Image 3's
1254 x 1254 canvas, the accepted equivalent for this call is the explicitly
quantified 1060 x 187..191 visible object centered in the same location; it will
then be proportionally bbox-fit to the canonical 784 x 140 safety box. Every
pixel outside the single object must be the same uniform solid #00FF00
chroma-key background, with no gradient, noise, texture, haze, spill, floor,
reflection, contact shadow, or cast shadow. Keep generous green space around
all sides. Never add transparent or green gutters inside the object's visible
left and right endpoints.

New top and bottom boundaries: after removing equal height from both sides,
repaint each boundary as a quiet, mostly parallel hand-painted leather edge.
The top may contain no more than two short dim warm strokes totaling less than
fifteen percent of its length. The bottom keeps one narrow deep-umber thickness
and only two or three dim wear flecks. Do not create a continuous top highlight,
complete outline, raised rail, inner groove, double bevel, or bright metallic
trim. Do not alter the width to compensate for height.

End geometry: leave the square-cut left root vertical, plain, radius-free, and
unornamented. Keep the right end fundamentally vertical and near-square. Scale
its existing shallow chamfers to the new thinner height so each remains at most
three percent of height. No rounded cap, semicircle, capsule, pill, arch, point,
arrow, chevron, notch, fishtail, bookmark tail, bright right cap, inset face, or
extra end ornament.

Surface preservation and quieting: preserve the existing dark-walnut color and
broad lighting, but place one subtle broad dark glaze over the central text-safe
face so repeated micro-grain and the central diagonal abrasion no longer create
high contrast. Do not invent new texture. The face should read as two or three
broad hand-painted value planes at 112 x 20, with no seam, emblem, repeated
pattern, bright scratch, or decorative focus in the center. Keep at most three
broad low-contrast scuffs near the far right and lower edge.

Runtime-safe regions: the canonical source coordinates [246,449,806,575] must
remain free of seams, emblems, high-contrast scratches, bright highlights,
repeated grain, and ornament. The first 112 canonical source pixels are a
straight plain hidden root. The last 42 contain only tiny chamfers and sparse
wear. The asset is fixed-size and cannot be stretched, tiled, mirrored,
repeated, or nine-sliced. Do not draw labels, glyphs, icons, enabled state,
tooltip, danger state, selection state, or click affordance.

Style lock: retain a 2004-era vanilla WoW sprite language with coarse deliberate
brush decisions, broad readable shapes, warm muted Azeroth expedition colors,
tangible but simple leather thickness, sparse wear, and modest upper-left
light. The tab must feel stored inside the accepted quest journal and remain
subordinate to parchment and the wax seal. It must not look photorealistic,
vector-clean, procedural, glossy, precision-machined, Diablo-3-like,
Skyrim-minimalist, or like a modern brown web button.

Strict exclusions: no additional object, book, page, parchment, paper strip,
ribbon, strap, wax, seal, menu panel, button stack, frame, text, letters,
numerals, glyphs, icons, compass, quill, emblem, rune, stitching, holes, rivets,
studs, buckles, hinges, embossing, inset panel, recessed groove, double bevel,
continuous metallic outline, continuous top highlight, bright right cap,
bright gold trim, glow, glass, translucent black, neon, gemstone, skull, spike,
altar, rounded pill, capsule, arrowhead, pointed bookmark, cast shadow, contact
shadow, or loose pixels outside the object.

Before returning the image, measure the edited visible object. Verify the width
remains approximately 1060 pixels on the retained 1254 canvas and the height is
187 to 191 pixels, or the exact canonical equivalent 784 x 140 on a 1024 canvas.
Verify aspect 5.55 to 5.67; exactly one object and one normal state; uniform
#00FF00 exterior; square left root; near-square shallow-chamfered right end; no
transparent horizontal gutters at 112 x 20; no new objects, text, icon, rivet,
book, page, seal, menu, complete border, continuous highlight, or state
variants. Preserve the accepted dark-walnut identity while changing the
silhouette height by the quantified amount.

### Attempt 5 执行、完整复审与循环终态

- 日期：`2026-08-05`；执行前 commit `1e84d16`。
- 实际输入：固定 Image 1
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`、
  Image 2
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`；
  紧邻 attempt 4 raw
  `53079531d3b4d6ad50bfa3c16b00057f3233e38ffaaafe50d81da03d6849ae5e`
  是唯一 Image 3；无其他上传。
- 固定执行器 session：
  `019fcfd8-d153-7603-b59f-0ee2a979662d`；完整 `QS-B1 V1.r4` 共
  `7604` 字符／`114` 行已由 child 逐字显示，无截断或 revised prompt。
  ImageGen 返回图片并退出 `0`，正式计为 `5/5`。模型缓存字段警告发生在
  已正常启动的固定 child 内，没有阻止 provider 生成，不新增流程错误。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V1/attempt-05/raw/QS-B1-V1.attempt-05.png`，
  SHA `259a5d713e9872f99e91dcb0e8dc39f04f8f5c252ac2e12d416e9baca667751b`；
  child 临时输出、同 session cache 与仓库 raw 三份 SHA 完全一致。
  原图为 `1388×1133 RGB`；边缘连通背景 `1,344,453` 像素、`3,285`
  种 RGB、精确 `#00FF00` 像素为 `0`。可见 bbox
  `[102,470,1286,663]`、`1184×193`，比例 `6.1347:1`。
- attempt 5 确实把高度降到请求区间附近，但把已冻结的可见宽度从
  `1060px` 擅自扩到 `1184px`，增加 `124px`／约 `11.7%`；因此没有得到
  要求的 `5.55..5.67:1`，也越过长期硬门禁 `5.45..5.75` 的上限。
- 合同内确定性处理只执行边缘连通色键、透明 RGB 清零和等比 bbox-fit。
  归一化审查件 SHA
  `eca28df94f59fe3c38cd66e4ac08231312d218a5929216a950bc678010220fcc`，
  `1024² RGBA`、bbox `[120,448,904,576]`、`784×128`；透明 RGB 与可见
  绿色残留均为 `0`。通用 inspector 再次确认同一 bbox、`100,231`
  可见像素和零 green spill。
- 等比缩到固定 `112×20px` Texture 后，实际不透明可见 bbox 仅
  `[0,1,112,19]`，即 `112×18px`，上下各留下约一行透明空白。授权的
  bbox-fit 不允许非等比纵向拉伸、裁掉横向端部或补画像素，因此不能把该失败
  伪装成合格的满槽资产。
- 接触表 SHA：
  `1f00f10113361ccfac34c3e600e8a01f8642f35076815bc6671d06bb6877434e`；
  真实排版 SHA：
  `d42b276361907e2c0b30bf62f3d2ebf4c1a1f3205c7e98d5576e7a0218487e30`；
  右缘 clamp SHA：
  `7ea015fc879aba41bd8d52a8b94f79ebd32980d56765bc02c16d1cd23d373aa9`；
  layout report SHA：
  `a7e2ef34fc595ebe7d74845b6aad79bd4ef79493868d662d00fe52960ed8800c`。
  七项真实标签、18 行任务、详情、四奖励槽、页边遮根和右缘 clamp 仍为
  `25/25 pass`；这只证明布局，不覆盖母版资产失败。
- 美术复审：单对象、直切左根、近方右端、暗胡桃综合色和真实标签可读性均
  保留；但全表面均匀压纹再次增强，顶部形成接近全长的亮铜线，右端也形成
  连续亮边，仍偏向现代 bevel button。即使忽略比例，这些也没有完整满足
  “低频宽笔触、无连续高光／完整边框”的香草风格合同。
- 第一个失败门禁：`raw_aspect_within_5_45_to_5_75 = false`，实测
  `6.1347 > 5.75`。次级视觉失败为均匀微纹与连续顶部／右端亮边。
- 结论：`candidate-rejected`。
- 否决人：`internal-review`。
- 尝试次数：`5/5`；流程错误：`1`。
- 循环终态：`repair-budget-exhausted`。不得执行第六次 ImageGen。
- 本版本保留内容：V9 外侧七槽布局、页边遮根、真实 `96×20px` hitbox、
  右缘 clamp、源 Button 代理合同、页上 QS-A1 火漆位置，以及候选的单对象、
  暗胡桃、直切根部和近方端部方向。
- 下一版本必须改变：必须由用户选择并重新授权新的边界。可选方向是重开一个
  新生产版本，或针对已存在候选明确允许一种能填满 `112×20px` 的非等比／
  裁切几何合同；当前授权只允许等比 bbox-fit，不能代替该决定。
- 本版本无 tracked source、source manifest、runtime atlas、Lua/XML 菜单接入
  或旧按钮隐藏；当前 addon 继续使用全部 fail-open fallback。

### 用户复审结论

- 日期：`2026-08-05`。
- 用户原文：`不可接受`。
- 复审对象：`QS-B1 V1.r4 / attempt 5` 的候选原貌、技术接触表与当前
  QL-A1／QL-A2 书体中的七项真实排版预演。
- 用户结论：`user-rejected`；V1 保持
  `candidate-rejected / repair-budget-exhausted / P3 / 5/5`，不得晋级 P4。
- 用户没有接受 attempt 5 的运行时视觉，也没有授权用非等比拉伸、裁切、
  补画或其他确定性合同例外绕过该结论。
- attempt 1–5 全部只保留为负面证据；下一版本不得上传其中任何一张，也不得
  将其作为 edit input、综合色权威、source 或 runtime。
- 已确认的 V9 外侧展开、七个真实 Button、源 Button 委托、页边遮根与
  fail-open 交互合同没有被本句自动撤销；但最终菜单的可见材质、轮廓、重复
  节奏与视觉重量必须在 `QS-B1 V2` 中重新模拟并由用户重新确认，不能直接
  沿用 V1 候选的七条现代矩形皮革按钮观感。
- 当前下一门禁：`QS-B1 V2 / prompt-draft` 的本地确定性模拟；ImageGen
  `0/0`。用户确认新模拟并独立授权完整 V2 生产正文前不得生图。
- 跨设备：当前继续只依赖 tracked 文本，不依赖任何被否决的 ignored 像素，
  因而不创建 `handoff/`。

## QS-B1 V2 旧卷宗索引签预演 — `QUEST-LOG-SEAL-ACTIONS-SIM-V10`

- 日期：`2026-08-05`。
- 状态：`user-superseded-before-confirmation / P2`。
- 触发条件：用户明确否决 `QS-B1 V1.r4 / attempt 5` 后回复“继续”。本节点只
  允许新的确定性生成前模拟，不构成 ImageGen、上传、source 晋级、runtime
  接入或隐藏旧按钮的授权。
- 目标不是修饰 V1 的矩形皮革母版，而是重新定义菜单物件身份：七项改为从
  真实右页边缘露出的七枚“公会旧卷宗索引签”。每枚仍由一个独立真实 Button
  拥有；没有一张共享 popup 底板，也没有把七项烘焙进单张背景图。
- 保留的交互与结构：页上 QS-A1 火漆仍为 `[576,68,32,32]`，保留／命中区仍为
  `[572,64,40,40]`；七个 provider、原生放弃确认、Esc／书外收起、右缘 clamp、
  原子 fail-open、右上 Close 独立及 detail／奖励零占用均不变。
- 真实 Button 容器继续使用七个 `112×20px` 槽；模拟中的可见签条分别为
  `99／94／108／101／96／105／98px` 宽、`18..19px` 高。它们共用被真实页边
  mask 覆盖的内侧根部，但书外长度、上下毛边和末端断口有克制错落，取消七个
  等长矩形造成的现代卡片节奏。
- 可见语言：烟熏旧档案纸／粗布综合色、宽而低频的明暗块、无完整描边／bevel、
  无黄铜顶线、圆角、箭头、铆钉或独立危险色底板；`放弃任务` 只改为低饱和
  酒红墨色。最终文字仍由游戏 FontString 绘制，模拟没有把文字烘焙进资产。
- 真实内容密度：两侧均使用当前 `676×464px` QL-A1／QL-A2 书体、18 行任务、
  完整详情、4 个奖励槽和 7 个真实功能文案；右侧展开仍只声明 `48px` outset。
- 本地检查：`31/31 pass`，report status `displayable`；内部复审确认无共享
  二级页面、无正文／奖励覆盖、七个独立组件和页边遮根均成立。最终手绘纤维、
  毛边、四态反馈、Tooltip、客户端字体与开合反馈仍为非权威范围。
- 渲染环境：macOS `Darwin`；
  `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，Python `3.12.12`。
- tracked renderer：
  `tools/render_quest_log_seal_actions_simulation_v1.py`，SHA-256
  `3b9d7ac8fa1c4e4a74e3f96cf6c891ea4510d72c53afebcb4523fd5359550f32`。
- tracked spec：
  `tools/specs/quest_log_seal_actions_simulation_v10.json`，SHA-256
  `69a5bedb50970cac22d764ad164fcf7ec3da2a3b0a5e89fbcd5fec53acac9834`。
- ignored board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V10/quest_log_seal_actions_board_v10.png`，
  SHA-256
  `33e681dd3bb4f18f7537198472d136a0b504173a8bfd48b943383748cd9bfffb`。
- ignored report：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V10/quest_log_seal_actions_report_v10.json`，
  SHA-256
  `31c6afbc7f2feeb07bf37524ad32f9c1624f2d076ef9ac32385eaf8f5b07be3c`。
- ImageGen：`0/0`；上传：`0`；本地流程错误：`0`。V1 attempt 1–5 没有作为
  图片输入、edit input、综合色权威或几何来源。
- 跨设备：board／report 可由 tracked renderer、spec 与既有 tracked 输入完全
  重建，不需要临时 `handoff/`。
- 用户改向：V10 尚未获得确认时，用户提出火漆应固定在详情 ScrollChild 的
  右上内容坐标，点击后向下展开一条类似誓约／授印绶带的七段菜单，并允许它
  与任务内容一起滚动、裁切和消失。该物件隐喻、布局、层序和占用关系发生
  实质变化，故 V10 不得继续作为待确认版本，也不得成为 source、runtime、
  edit input 或 V11 像素来源。

## QS-B1 V2 页内火漆授印绶带预演 — `QUEST-LOG-SEAL-ACTIONS-SIM-V11`

### 元数据与用户指向

- 日期：`2026-08-05`。
- 状态：`simulation-confirmed / P2`。
- 用户指向：火漆固定在任务详情滚动内容的右上角；它随任务正文向上滚动并
  消失。点击后向下展开一条带七个纹章点击区的绶带，语义参考动力甲授印绶带
  的“蜡封压住垂直誓约带”，但必须转译为艾泽拉斯远征公会卷宗，禁止骷髅、
  双头鹰、帝国徽记、科幻金属和直接复制战锤符号。用户随后回复“按这个做”。
- 本节点只执行本地确定性几何模拟、文档与合同更新。它不构成 ImageGen、
  上传、source 晋级、runtime 接入、旧按钮隐藏或新生产预算授权。
- V10 状态改为 `user-superseded-before-confirmation`。V1 attempt 1–5 仍是
  负面证据，未作为 V11 图片、edit、综合色或几何输入。

### 物件、组件与视觉合同

- `QUEST.LOG.CHROME.SEAL` 的未来 Button 与绶带都挂在
  `QuestLogDetailScrollChild`，而不是 `QuestLogFrame` 或 viewport 固定层。
  内容坐标命中盒 `[206,0,40,40]`、可见蜡体 `[210,4,32,32]`；scroll `0`
  时仍映射到既有 Frame 坐标 `[572,64,40,40]`／`[576,68,32,32]`，不让当前
  页上位置突然跳动。
- 收起态只在火漆下方露出 `6px` 的折叠绶带根，明确表达“绶带被蜡压住”，
  又不形成新的书签、包角、外框或悬空红色 icon。层序为详情文字／奖励 →
  绶带根／分段／尾端 → QS-A1 火漆；蜡体永远在根部上方。
- 展开态由七个相接的 `32×22px` 分段组成，内容坐标依次为
  `[210,42,32,22]`、`[210,64,32,22]`、`[210,86,32,22]`、
  `[210,108,32,22]`、`[210,130,32,22]`、`[210,152,32,22]`、
  `[210,174,32,22]`；尾端 `[210,196,32,8]`。七段视觉上形成连续的窄幅
  公会授印绶带，但每段必须仍由一个独立真实 Button、独立状态和独立图案
  皮肤拥有；禁止以一张整绶带背景代替七个点击对象。
- 七段依次映射共享、详情开合、显示位置、隐藏位置、清理标记、重建标记、
  放弃任务。可见图案分别采用双羽笔／结约、折页、公会罗盘、遮蔽罗盘、
  清扫地图线、回环路线结和断裂契约线；它们是整段纹章式墨迹，不是现代
  微型 icon。动态动作名保留给 GameTooltip／provider，不烘焙进位图。
- 材料冻结为粗织、做旧的远征公会誓约亚麻布，不再在羊皮与布之间摇摆；
  综合色使用烟熏暖赭、旧棕、深乌墨与只在放弃段出现的克制暗酒红。保持
  香草魔兽低分辨率二维手绘、粗略不规则边、
  大块明暗和左上暖光；禁止规则卡片列、完整金框、圆角 pill、玻璃、霓虹、
  现代 dropdown、暗黑式金属祭坛或照片级布料。

### 真实展示区域与滚动合同

- 真实基础 Frame `676×464`；右页 `QuestLogDetailScrollFrame` viewport
  `[366,64,246,324]`，模拟 ScrollChild `[366,64,246,560]`。列表仍为 18 行，
  奖励仍为四个真实 `108×41px` 双列槽；没有新增页外 outset、第二张纸、
  popup 背板、书框或右缘 clamp。
- 正文正常宽度 `214px`、缩进目标宽 `204px` 均不改变。展开绶带位于详情
  局部 `x=210..242`，只临时覆盖正常正文右缘 `14px`，对旧／未约束到
  `224px` 的行最多覆盖 `24px`；不永久缩窄、不绕排、不重排。菜单在动作、
  再次点蜡、空白点击或 Esc 后收起。
- 绶带尾端内容 y=`204`，首行奖励 y=`236`，中间保留 `32px`；因此不会与
  四个奖励 Button 同时占用相同垂直区域。奖励行距继续为 `4px`。
- 四个真实状态：A `closed / scroll 0`，动作命中数 `0`；B
  `open / scroll 0`，七段全部可见可点；C `open / scroll 52`，第一段只剩
  `12px` 可见且不得保留完整隐藏 hitbox，另外六段可点；D
  `open / scroll 208`，火漆、根、七段和尾端全部滚出，动作命中数必须为 `0`。
  ScrollFrame 裁切不仅作用于 Texture，也必须约束 Button 命中；runtime 若
  无法可靠裁切部分 hitbox，保守禁用任何未完整落入 viewport 的段。
- 交互所有权不变：七项只通过源 Button `:Click("LeftButton")` 委托；放弃
  继续走原生确认；右上 Close 独立；parity 不完整时全部旧入口原子 fail-open。

### 本地模拟、复现与内审

- specification：
  `tools/specs/quest_log_seal_actions_simulation_v11.json`，SHA-256
  `6a396c80d742fb0e9b31e9df245f50358a35891f12382b9f4fa40da5a5ab559e`。
- display-region contract：
  `tools/specs/quest_log_seal_actions_simulation_v11_display_region.json`，
  SHA-256
  `b7f44a4003a2cff5e7d8bcc7e4d8733dbc1fe065c02b72fcfb87ea8f6b57cacf`。
- renderer：`tools/render_quest_log_seal_ribbon_simulation_v1.py`，SHA-256
  `9763f4bc1231b17bb10b316d825bcb924a04bec5fbba3bcf036058fcb705b084`。
- macOS 命令：
  `conda run -n py312 python tools/render_quest_log_seal_ribbon_simulation_v1.py tools/specs/quest_log_seal_actions_simulation_v11.json --repo-root .`。
  实际解释器 `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，Python
  `3.12.12`；本地渲染错误 `0`。
- board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V11/quest_log_seal_actions_board_v11.png`，
  `1520×1220 RGBA`，SHA-256
  `f720f4f84de42ab3addfd600658a57f06206944e8a72436a1d839d3140fda13c`。
- 模拟 report：同目录 `quest_log_seal_actions_report_v11.json`，SHA-256
  `b738ecef1e1acb3cbd06ad8961a8ef82912863a9af996479fc5042adaeaf79ae`；
  `21/21 pass`、status `displayable`。
- display-region report：同目录 `display-region-report-v11.json`，SHA-256
  `65f801f566daf8327b23b36291a1cb03955184eb32edc39074ddb7084cc72e80`；
  `4/4` 场景、violations `0`、status `pass`。
- ImageGen：`0/0`；上传：`0`；新 bitmap source/runtime：`0`。board／report
  可由 tracked renderer、spec 和既有 accepted/runtime 输入确定性重建，
  当前不需要 `handoff/`。
- 内部结论：`user-confirmed-visible-direction`。真实 Frame、18 行、四个 `108×41px`
  奖励、七段独立 Button、ScrollChild 层序、临时正文覆盖、奖励避让、部分
  裁切和完全滚出都可读且满足几何合同。
- 非权威：最终羊皮／粗布纤维、手绘毛边、production Alpha、atlas、四态、
  Tooltip、客户端字体和 1.12 ScrollFrame 的鼠标裁切实现。模拟像素不得成为
  source、runtime、裁切／切片或正式 ImageGen 输入。
- 用户确认：`2026-08-05`；在明确的“确认 V11 后只准备生产正文、仍需另行
  请求正式生图授权”上下文中回复“继续”。确认冻结 ScrollChild 内层序、
  七段比例、滚动裁切、正文临时覆盖和奖励避让；不接受模拟像素为 source。
- 下一门禁：用户独立授权下节完整 `QS-B1 V2` 生产正文、固定 Image 1／2、
  不可变修复边界和最多五次实际 ImageGen 调用；当前不得生图、上传、导出
  source／atlas、修改 addon 或隐藏旧按钮。

## QS-B1 V2 页内公会授印绶带母版 — production preparation

### 元数据、固定输入与当前边界

- 日期：`2026-08-05`。
- 状态：`repair-prepared / P3`。
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`。
- 本版本实际 ImageGen：`4/5`；图片上传：`10`（固定参考 `8`＋紧邻 edit
  input `2`）；流程错误：`3`。这是新的 V2
  预算，不能续用或覆盖已耗尽的 V1 `5/5`。
- 用户生产授权：`2026-08-05`。用户原文：`确认授权 QS-B1 V2；允许每次上传
  固定 SHA 的 Image 1/2，允许同循环紧邻前次输出仅在冻结边界内作为 Image 3
  edit 输入；最多 5 次实际 ImageGen 调用，流程错误不占额度；允许按合同执行
  边缘连通色键、透明 RGB 清零、等比 bbox-fit、九区切片、四态派生与真实排版
  预演。`
- Image 1（最高美术权威）：
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`，SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
- Image 2（受限邻接参考）：
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`，SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
- V11 几何模拟、V1 attempt 1–5、V10、QS-A1 漆章 atlas 均不上传。QS-A1
  只作为 runtime 中已经存在并压住绶带根部的相邻物件，不让模型重复生成。
- 计划 accepted source：
  `assets/source/quests/qs-b1/QuestLogSealRibbon_Master_v2.png`；计划 source
  manifest：`assets/source/quests/qs-b1/QS-B1-V2_SourceManifest_v1.json`。
- 计划 exporter：`tools/build_quest_log_seal_ribbon_v2.py`；计划 runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogSealRibbonStatesV2.tga`；
  计划 runtime manifest：
  `assets/source/quests/qs-b1/QS-B1-V2_RuntimeManifest_v1.json`。上述文件当前
  均不存在，也不在本生产准备节点创建。

### 组件粒度、源画布与切片合同

- 生成对象为一条物理连续的、无火漆的纵向公会誓约亚麻绶带 normal 母版。
  连续母版只解决纤维、边缘和明暗跨段连续性；runtime 所有权仍严格拆成九个
  区域：无鼠标根部、七个独立 Button 分段、无鼠标尾端。禁止把整条母版作为
  一个大命中区，也禁止把七项功能合并成一张不可分割的背景。
- raw 目标为精确 `1024×1024 RGB`，画布外底色统一 `#00FF00`。唯一物件的
  目标可见 bbox 为 `[448,164,576,860]`，即 `128×696px`；正面正投影、无
  旋转、无透视，计划按 `4:1` 缩为 `32×174px` runtime master。
- 九个源区域固定为：root `[448,164,576,212]`（`128×48`）；action 1
  `[448,212,576,300]`；action 2 `[448,300,576,388]`；action 3
  `[448,388,576,476]`；action 4 `[448,476,576,564]`；action 5
  `[448,564,576,652]`；action 6 `[448,652,576,740]`；action 7
  `[448,740,576,828]`（七段各 `128×88`）；tail
  `[448,828,576,860]`（`128×32`）。重组时九片边缘必须无缝恢复成同一物件。
- 每个 action 的图案安全区相对该段为 `[16,12,112,76]`，即 runtime
  `[4,3,28,19]`；不得让识别图案、强高光、裂口或高对比磨损跨越切片线。
  root 顶部 runtime `6px` 将被既有 QS-A1 火漆遮住；root 不画图案。tail
  只允许克制的浅分叉或毛边，不接收鼠标。
- 七段边界每隔源 `88px`／runtime `22px`。边界只用极浅折痕、墨迹留白或
  织物受压变化帮助分区，不能出现七张卡片、独立描边、缝隙、bevel、金属
  隔条或重复铆钉。整条左右外缘和跨段光照必须连续。

### 确定性状态 atlas 与候选展示合同

- exporter 先按固定九区切片。七个 action 的 normal 来自 accepted source；
  hover 保持同一 Alpha／轮廓，只轻微暖亮；pressed 保持同一 Alpha／轮廓，
  只轻微压暗且 Button 在 runtime 右下移动 `1px`；disabled 保持同一 Alpha／
  轮廓，只退灰降对比。root 与 tail 只导出 normal。
- runtime atlas 固定为 `512×256`。七个 action 分别占一列，四态占四行；每格
  `64×32px`，行序 normal／hover／pressed／disabled。每格可见 action
  `32×22px` 居中于 `[column*64+16,row*32+5,32,22]`（`xywh`）。root cell
  `[0,128,64,32]`，可见 `[16,138,32,12]`；tail cell `[64,128,64,32]`，
  可见 `[80,140,32,8]`；其他区域透明，格间 padding 不进入 UV 采样。
- 只允许边缘连通的纯绿色键、透明 RGB 清零，以及候选已通过物件身份、材料、
  九区比例和图案门禁后，对完整 bbox 作一次等比 fit 到 `128×696px`。禁止
  非等比拉伸、裁切、逐段移动、图案重定位、边界 surgery、补画或用后处理
  伪造正确组件结构。任一区域高度错误、切片线错位或图案越出安全区都直接
  退回生成循环。
- 每次候选都必须用该候选而非几何占位图临时切片、派生四态并装入真实
  `676×464px` Quest Log 排版：18 条任务、代表性中文详情、四个真实
  `108×41px` 奖励槽、七段独立 Button。展示 closed／open／scroll 52
  部分裁切／scroll 208 完全滚出，并验证命中区、正文不重排、奖励 `32px`
  避让、图案在 `32×22px` 下可辨和状态反馈。稀疏 contact sheet 不能替代
  真实排版预演。

### 生产正文完整性预检

- 复杂度：`one connected normal master + 9 deterministic slices + 7 independent
  runtime Buttons + deterministic 4-state action atlas`。
- 结论：`pass`。

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 世界内物件身份、对象／状态数量 | 连续的艾泽拉斯公会誓约亚麻绶带；一件 normal 母版、九区、七个动作段；无火漆／书／文字 | pass |
| Image 1／2 inherit、ignore 与冲突裁决 | 分别声明最高年代／笔触权威和受限邻接职责；列出忽略项；Image 1＋任务基线胜出 | pass |
| Canvas、bbox、方向、尺度、光照与层序 | `1024²`、`128×696`、竖直正投影、左上暖光、root 位于既有火漆下 | pass |
| 解剖、材料、边缘、状态和跨片关系 | 粗织旧亚麻、连续外缘／光照、九区尺寸、四态由 exporter 派生 | pass |
| safe area、crop、stretch、repeat 与 seam | 每段 `[16,12,112,76]`、禁止裁切／非等比／平铺、固定切片线与无缝重组 | pass |
| 全局／Quest 美术 DNA 与反模式 | 香草二维手绘、大块低频明暗、克制暖旧综合色；排除现代按钮栈、照片布料和其他 IP 符号 | pass |
| Alpha／色键与最终自检 | 统一 `#00FF00`、边缘连通色键、透明 RGB 清零、object／bbox／九区／禁项复核 | pass |

- 未知但执行必需的值：`无`。
- 去冗余结论：只在开头、技术排除和最终自检重复“一个连续物件但九区切片”、
  “无火漆／文字／书”和精确 bbox／区段三个最高风险门禁；历史否决过程不进入
  执行正文。

### 最终执行正文 — `QS-B1 V2`

Create exactly one isolated, connected vertical guild oath-ribbon master for a
circa-2004 vanilla World of Warcraft quest-log interface. It is one continuous
physical strip of aged coarse-woven linen, pinned beneath an existing wax seal
at runtime. The wax seal is not part of this image. Generate only the ribbon's
normal-state master: one plain root, exactly seven equal action bands, and one
short tail, all physically continuous. A deterministic exporter will slice the
master into exactly nine owned components: one noninteractive root texture,
seven separate real Button textures, and one noninteractive tail texture. Do
not render a screen, book, page, wax seal, menu panel, button stack, labels, or
state variants. Do not merge the future seven hit regions into one runtime
object.

The seven action bands have fixed meanings from top to bottom, expressed only
as broad heraldic ink motifs suitable for a tiny Azeroth guild warrant:
1. two compact paired quills joined by a small binding knot for Share Quest;
2. one folded ledger leaf for Detail Toggle;
3. an open guild compass for Show Location;
4. the same guild compass crossed by one quiet diagonal veil stroke for Hide
   Location;
5. three swept cartographic trail lines for Clean Marks;
6. one winding route returning into a compact knot for Reset Marks;
7. one snapped contract cord with a small central break for Abandon Quest.
These are hand-painted heraldic marks, not modern interface icons. Draw no
letters, words, numerals, tooltips, runes, faction logos, skulls, aquilas,
double-headed eagles, Imperial insignia, science-fiction hardware, or symbols
copied from another franchise. Only the seventh motif may use a restrained,
low-saturation dark-wine ink; its linen body must remain the same as all other
bands.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit its circa-2004 vanilla WoW
   low-resolution 2D hand-painted language, broad low-frequency value planes,
   slightly irregular substantial edges, muted ochre and smoked-brown palette,
   short warm upper-left light, tactile material separation, and sparse
   concentrated wear. Ignore its complete open-book composition, parchment
   pages, leather plaques and straps, compass, wax seal, bookmarks, brass
   corners, rivets, text, buttons, and complete UI layout.
2. Image 2 is an adjacency reference only. Inherit only the accepted quest
   book's local color temperature, paint scale, edge softness, upper-left light
   direction, and restrained wear so the ribbon belongs beside that book.
   Ignore its complete book silhouette, pages, spine, stitches, page gutter,
   brass corners, transparency, and every directly reusable pixel.
If the references conflict, Image 1 plus the vanilla Azeroth quest-ledger rules
wins. Image 2 may only tune local adjacency. Do not imitate a modern Diablo
panel, a minimalist Skyrim overlay, or Warhammer iconography; the physical idea
is only "wax pins a vertical oath strip," translated completely into an
Azeroth expedition-guild document.

Canvas and exact occupancy: output an exact 1024 x 1024 RGB bitmap. Every pixel
outside the one ribbon must be uniform solid #00FF00, with no gradient,
checkerboard, texture, haze, vignette, color spill, cast shadow, or loose
pixels. Place the full connected ribbon vertically, unrotated, in a straight-on
orthographic front view with no tilt or foreshortening. Its exact visible bbox
is [448,164,576,860], 128 x 696 pixels. Keep the entire object inside that bbox
and leave green clearance on every side. It will be reduced exactly four-to-one
to a 32 x 174 pixel runtime master; design no detail that depends on stretching,
tiling, mirroring, or nine-slicing.

The exact vertical anatomy inside that bbox is mandatory:
- plain root: [448,164,576,212], 128 x 48 pixels;
- action band 1: [448,212,576,300], 128 x 88 pixels;
- action band 2: [448,300,576,388], 128 x 88 pixels;
- action band 3: [448,388,576,476], 128 x 88 pixels;
- action band 4: [448,476,576,564], 128 x 88 pixels;
- action band 5: [448,564,576,652], 128 x 88 pixels;
- action band 6: [448,652,576,740], 128 x 88 pixels;
- action band 7: [448,740,576,828], 128 x 88 pixels;
- short tail: [448,828,576,860], 128 x 32 pixels.
The top 24 source pixels of the root, equal to 6 runtime pixels, will sit under
the existing wax seal. Keep the root plain and calm, with no motif. Give the
tail only a shallow restrained fork or a few broad frayed fibers; do not make a
long pointed bookmark tail.

Construction and seams: this is one continuous woven object, not nine separate
cards. Its left and right cloth edges, weave direction, broad shadow plane, and
upper-left illumination must continue naturally through all nine slice zones.
At each 88-pixel action boundary, use only a very shallow fold, a narrow quiet
ink break, or subtle compression of the weave. Every boundary must remain
perfectly reconstructable when adjacent slices touch: no gaps, detached pieces,
individual rectangular outlines, bevels, metal separators, repeated rivets,
or independent shadows. Keep high-contrast fibers, tears, scratches, and bright
highlights away from every slice boundary.

Motif placement is exact: inside each action band, keep the complete heraldic
motif within relative safe box [16,12,112,76], 96 x 64 source pixels. Center it
optically and make it readable after reduction to the runtime safe box
[4,3,28,19], 24 x 16 pixels. No motif stroke, identifying shape, dark-wine mark,
tear, or high-contrast wear may cross a band boundary. Preserve visible linen
around every motif. The marks should feel painted or stamped into an old guild
oath cloth with slightly softened pigment edges, never embossed as metallic
badges and never placed inside modern icon tiles.

Material and paint treatment: use one heavy but flexible strip of aged coarse-
woven linen oath cloth, not parchment, leather, metal, or photographic fabric.
Use smoked warm ochre, muted old brown, deep umber shadow, near-black guild ink,
and only the restrained dark-wine ink on motif seven. Describe the weave with a
few broad painterly fiber groups and two or three large value planes, not dense
procedural microtexture. Use a short warm upper-left highlight and a slightly
deeper lower-right edge. Let the silhouette vary only subtly like a hand-cut
cloth strip; retain enough visual mass to read at 32 pixels wide. Wear should
be sparse and concentrated near the lower tail and a few outer-edge locations.

Style lock: the result must look like an original low-resolution bitmap sprite
painted for a 2004-era vanilla World of Warcraft interface: warm, substantial,
slightly irregular, magical without glow, and subordinate to an open quest
ledger. It must not look vector-clean, photorealistic, procedural, glossy,
minimalist, or like a vertical set of modern web buttons. Avoid thin perfect
outlines, rounded rectangles, pills, card gaps, uniform embossing, tiny line
icons, bright gold trim, polished brass frames, leather button plates, glass,
translucent black, neon, gemstones, spikes, skulls, altars, futuristic metal,
and high-frequency fabric noise.

Strict exclusions: no wax or seal; no book, cover, page, parchment strip,
bookmark, leather strap, frame, popup, backdrop, second surface, or scenery; no
text, letters, numbers, labels, tooltips, UI cursor, or state labels; no separate
hover, pressed, disabled, selected, or danger-state copies; no cast shadow or
detached decoration outside the ribbon; no crop, rotation, perspective,
stretching, repetition, mirrored sections, or disconnected action pieces.

Before returning the image, verify all of the following: exactly one connected
vertical linen ribbon and no other object; exact 1024 x 1024 canvas; uniform
#00FF00 outside it; exact [448,164,576,860] visible bbox; one 48-pixel root,
seven and only seven equal 88-pixel action bands in the stated order, and one
32-pixel tail; every motif remains fully inside its exact safe box; all slice
boundaries reconstruct seamlessly; the root has no motif; only motif seven has
restrained dark-wine ink; no wax, book, text, modern button cards, metallic
frames, photo fabric, or non-Azeroth franchise symbols; the object remains
legible when reduced to 32 x 174 pixels and each motif remains legible within a
32 x 22 pixel action slice.

### 自主修复循环与独立授权边界

- 不可变修复边界：V11 已确认的 ScrollChild 位置／层序／滚动裁切；一条连续
  normal 母版与九区切片；七个独立 Button 和顺序；固定 Image 1／2 及权威
  职责；`1024²`、`128×696`、九区坐标、图案安全区、粗织旧亚麻材料、七个
  纹章语义、色键／Alpha 策略、四态确定性导出与全部禁止项。
- attempt 1 只上传固定 SHA 的 Image 1／2。attempt 2–5 仍必须上传相同顺序、
  相同 SHA 的 Image 1／2；只有紧邻前次候选的物件身份、九区结构和综合色
  已正确，且失败能在冻结边界内局部修复时，才允许额外把该前次输出作为
  Image 3 edit input。否则使用固定 Image 1／2 regenerate。
- 允许的自主修复仅包括：纯绿背景／bbox／居中、低频布料笔触、轮廓轻微
  不规则度、综合色与对比、局部磨损密度、分段边界克制度、图案辨识度和
  安全区内位置，以及删除误生的文字、火漆、现代卡片边、金属件或其他禁项。
- 禁止把 V1 attempt 1–5、V10、V11 模拟、QS-A1 漆章或非紧邻候选作为图片
  输入；禁止改变材料、对象数量、九区尺寸、纹章顺序、runtime owner、滚动
  关系，或用裁切／非等比／逐段搬移／补画规避生成失败。上述改变必须重新
  模拟并获得用户新授权。
- 最多 `5` 次实际 ImageGen generation／edit，含首次。没有生成候选、没有
  provider 生成证据的上传／transport／流程错误不占生图额度；同类流程错误
  针对性修复一次后若复现即暂停。任一候选通过完整内审就立即停止；第五次
  仍不通过则停止等待用户审核。
- 每次调用后都必须先做结构／综合色／反模式内审，再执行确定性色键、临时
  切片／四态和真实排版预演。只有最终候选由用户接受后，才可进入 P4 source
  固化、manifest、exporter、atlas 与 addon P5 接入。
- 本节完整合同已按上述用户原文获得独立授权。下一门禁是把本次
  `prompt-authorized` 状态先提交，再用固定 Image 1／2 原样执行 attempt 1；
  候选通过内部审查也只到 `candidate-reviewed / P3`。用户明确接受具体候选前，
  source／runtime 写入、addon 修改和旧按钮隐藏仍为 `0`。

### attempt 1 执行与完整审查

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---|---|---|---|---|---|---|---|
| `1/5` | `QS-B1 V2` / `c73d30c` | generate；固定 Image 1／2；无 Image 3 | fixed child `019fd057-94bc-7972-96ef-1037c1a347ac`；返回有效图片，退出 `0` | `generated/quests/QS-B1-V2/attempt-01/raw/QS-B1-V2.attempt-01.png`；`55814b16aa520e55894dbec7bf89c5cb6f1b18d39dae4548234f7b64e2bf4622` | 语义／物理解剖：没有独立 plain root 和 short tail，七个图案区被强横缝分成卡片栈；raw 可见 `309×1150`、纵条宽高比 `0.2687`，比目标 `0.1839` 宽 `46.1%`，等比 fit 后只能得到 `128×476` 而非 `128×696` | 保留单一连续亚麻物件、暖赭／深褐综合色、正视方向、七个纹章语义与顺序、无火漆／书／文字；九区结构不正确，故禁止上传本稿为 Image 3，attempt 2 仅固定 Image 1／2 regenerate | `internal-rejected / repair-prepared` |

- raw 尺寸／模式：`1254×1254 RGB`；边缘连通色键后 bbox
  `[473,54,782,1204]`。背景只有 `1` 个精确 `#00FF00` 像素，但允许的边缘
  连通色键能隔离主体；这不是本次第一失败门禁。
- 确定性审查只对 ignored 副本执行边缘连通色键、透明 RGB 清零、等比
  bbox-fit、固定九区切片与四态派生。技术检查 `7/11`；root／tail 无可见像素，
  九片无法无缝恢复为合同物件。没有裁切、非等比拉伸、逐段移动、补画或写入
  source／runtime／addon。
- 真实排版：
  `generated/quests/QS-B1-V2/attempt-01/review/QS-B1-V2.attempt-01.real-layout.png`，
  SHA-256 `2b11a5a3f4c08988734ca9f43f1f4c5d60bee13d8aa60e8a94e7c3a1f128a151`；
  使用真实 `676×464` Frame、`246×324` detail viewport、18 行任务、四个
  `108×41` 奖励槽及 closed／open／scroll 52／scroll 208 四态。几何裁切与
  命中数量仍通过，但候选切片视觉失败，不能进入用户复审。
- 审查流程错误 `1`：首次本地 reviewer 因 NumPy-backed Pillow image 为只读，
  洪泛标记未落盘；没有调用 provider，也没有产生新图片，因此不计生图额度。
  reviewer 已改为在洪泛前脱离只读 buffer，同一 raw 重审成功；该错误没有复现。
- 本次不能使用 Image 3：虽然对象身份、七纹章与综合色正确，但独立 root／tail
  和准确九区结构不正确，不满足用户授权的 edit-input 前置条件。V2.r1 必须
  只上传固定 SHA、固定顺序的 Image 1／2。

### 完整修复执行正文 — `QS-B1 V2.r1`

This is a fresh regenerate, not an edit. Use only Image 1 and Image 2 in their
fixed order. Do not use, imitate, or infer geometry from any previous generated
ribbon candidate. Create exactly one isolated, connected vertical guild
oath-ribbon normal-state master for a circa-2004 vanilla World of Warcraft
quest-log interface. The single physical strip is aged coarse-woven linen and
will be pinned beneath an already existing wax seal at runtime. The wax seal is
not part of this image. The master has exactly nine vertically contiguous
construction zones: one visibly plain root, exactly seven equal action bands,
and one visibly short tail. A deterministic exporter will slice those nine
zones into one noninteractive root texture, seven separate real Button
textures, and one noninteractive tail texture. Generate no screen, book, page,
seal, frame, popup, labels, state variants, or other objects.

Correct the prior failure at the silhouette and anatomy level. The complete
ribbon must be extremely narrow and tall: its overall height is exactly 5.4375
times its width, or width:height = 128:696 = 0.183908. Do not make a broad
bookmark, banner, column of square plaques, or stack of icon cards. Each action
band is wider than it is tall, width:height = 128:88 = 1.4545, and all seven
bands share that same invisible allocation. The plain root is only 48 pixels
tall; the short tail is only 32 pixels tall. Root and tail must both be visibly
present as distinct portions of the same continuous strip even though no dark
divider outlines them. The seven action regions are construction slices, not
seven separately sewn pockets.

The seven action bands have fixed meanings from top to bottom, expressed only
as broad, softened heraldic ink motifs made for a tiny Azeroth guild warrant:
1. two compact paired quills joined by a small binding knot for Share Quest;
2. one folded ledger leaf for Detail Toggle;
3. an open guild compass for Show Location;
4. the same guild compass crossed by one quiet diagonal veil stroke for Hide
   Location;
5. three swept cartographic trail lines for Clean Marks;
6. one winding route returning into a compact knot for Reset Marks;
7. one snapped contract cord with a small central break for Abandon Quest.
These are hand-painted heraldic marks, not modern interface icons. Draw no
letters, words, numerals, tooltips, runes, faction logos, skulls, aquilas,
double-headed eagles, Imperial insignia, science-fiction hardware, or symbols
copied from another franchise. Only motif seven may use restrained,
low-saturation dark-wine ink. Its linen remains identical to the other zones.

Reference authority and filtering are mandatory:
1. Image 1 is the highest visual authority. Inherit its circa-2004 vanilla WoW
   low-resolution 2D hand-painted language, broad low-frequency value planes,
   substantial slightly irregular edges, muted ochre and smoked-brown palette,
   short warm upper-left light, tactile material separation, and sparse
   concentrated wear. Ignore its complete open-book composition, parchment
   pages, leather plaques and straps, compass, wax seal, bookmarks, brass
   corners, rivets, text, buttons, and complete UI layout.
2. Image 2 is an adjacency reference only. Inherit only the accepted quest
   book's local color temperature, paint scale, edge softness, upper-left light
   direction, and restrained wear. Ignore its complete book silhouette, pages,
   spine, stitches, page gutter, brass corners, transparency, and every directly
   reusable pixel.
If references conflict, Image 1 plus the vanilla Azeroth quest-ledger rules
wins. Image 2 only tunes local adjacency. Do not imitate modern Diablo panels,
minimalist Skyrim overlays, Warhammer iconography, web UI, or a vertical mobile
toolbar. The physical idea is only an old guild oath cloth pinned by wax,
translated fully into Azeroth.

Canvas and exact occupancy are mandatory. Output an exact 1024 x 1024 RGB
bitmap. Every pixel outside the one ribbon is uniform solid #00FF00, with no
gradient, checkerboard, texture, haze, vignette, colored glow, spill, cast
shadow, or loose pixel. Place the ribbon unrotated in a straight-on orthographic
front view with no tilt or foreshortening. Its exact visible bbox is
[448,164,576,860], exactly 128 x 696 pixels. In percentage terms, the ribbon is
only 12.5 percent of the canvas width, spans 67.97 percent of the canvas height,
and is centered on x = 512. The green left clearance is 448 pixels and the
green right clearance is 448 pixels. The top clearance is 164 pixels and the
bottom clearance is 164 pixels. Do not enlarge the strip to fill the canvas.
It will be reduced exactly four-to-one into a 32 x 174 pixel runtime master.

Before painting texture, use one invisible construction rectangle of exactly
128 x 696 pixels and allocate its height without drawing guides:
- plain root [448,164,576,212], exactly 128 x 48 pixels;
- action band 1 [448,212,576,300], exactly 128 x 88 pixels;
- action band 2 [448,300,576,388], exactly 128 x 88 pixels;
- action band 3 [448,388,576,476], exactly 128 x 88 pixels;
- action band 4 [448,476,576,564], exactly 128 x 88 pixels;
- action band 5 [448,564,576,652], exactly 128 x 88 pixels;
- action band 6 [448,652,576,740], exactly 128 x 88 pixels;
- action band 7 [448,740,576,828], exactly 128 x 88 pixels;
- short tail [448,828,576,860], exactly 128 x 32 pixels.
The top 24 source pixels of the root will sit under the existing wax seal. The
root must remain unmarked, calm, and continuous with the first action band.
Give the tail only a shallow restrained fork or several broad frayed fibers.
The tail must not become a long V-shaped banner, pointed bookmark, or eighth
action band.

The nine regions must be legible through their contents and allocated space,
not through panel borders. Draw no full-width horizontal seam, stitched cross
seam, dark rule, raised ridge, bevel, gap, outline, metal divider, or repeated
shadow at any internal boundary. In particular, do not build seven square cloth
cards sewn together. Let the same left and right outer cloth edges, vertical
weave direction, broad shadow plane, and upper-left light flow continuously
from root through all seven actions into tail. Internal slice lines should be
visually absent. Separate motifs only with calm linen breathing room. A barely
perceptible broad change of cloth pressure may exist away from the exact cut
line, but it must not read as a horizontal divider after reduction.

Motif placement is exact. Inside each 128 x 88 action band, keep its complete
heraldic motif within relative safe box [16,12,112,76], 96 x 64 source pixels.
Center it optically and make it readable after reduction to runtime safe box
[4,3,28,19], 24 x 16 pixels. No motif stroke, identifying shape, dark-wine
accent, tear, fiber highlight, or high-contrast wear may cross a slice
boundary. Keep visible quiet linen around each motif. Use broad irregular
brush-stamped shapes and softened pigment edges, never precise black vector
outlines, embossed badges, square icon tiles, or identical modern pictogram
frames.

Material and paint treatment: use one heavy yet flexible aged coarse-woven
linen oath cloth, not parchment, leather, metal, or photographic fabric. Use
smoked warm ochre, muted old brown, deep umber shadow, near-black guild ink, and
only the restrained dark-wine ink on motif seven. Describe weave with a few
broad painterly fiber groups and two or three large value planes. Do not cover
the entire strip with sharp procedural crosshatch or uniform high-frequency
microtexture. Use a short warm upper-left highlight and a slightly deeper
lower-right edge. Let the narrow silhouette vary only subtly like hand-cut
cloth while preserving sufficient visual mass at 32 pixels wide. Concentrate
sparse wear near the short tail and a few outer-edge points, never on cut lines.

Style lock: the result must read as an original low-resolution bitmap sprite
painted for a 2004-era vanilla World of Warcraft interface. It is warm,
substantial, slightly irregular, magical without glow, and subordinate to the
accepted open quest ledger. It must not look vector-clean, photorealistic,
procedural, glossy, minimalist, or like a vertical set of modern web buttons.
Avoid thin perfect outlines, rounded rectangles, pills, card gaps, uniform
embossing, tiny technical line icons, bright gold trim, polished brass frames,
leather button plates, glass, translucent black, neon, gemstones, spikes,
skulls, altars, futuristic metal, dense realistic burlap, and modern icon-grid
rhythm.

Strict exclusions: no wax or seal; no book, cover, page, parchment strip,
bookmark, leather strap, frame, popup, backdrop, second surface, scenery, or
visible construction guide; no text, letters, numbers, labels, tooltips, UI
cursor, or state labels; no separate hover, pressed, disabled, selected, or
danger-state copies; no cast shadow or detached decoration outside the ribbon;
no crop, rotation, perspective, stretching, repetition, mirrored sections, or
disconnected action pieces; no plain-root omission; no short-tail omission; no
horizontal card seams; no seven-square-panel stack.

Before returning the image, verify in this order: exactly one connected
vertical linen strip and no other object; exact 1024 x 1024 canvas and uniform
#00FF00 outside it; exact [448,164,576,860] bbox; the object is 5.4375 times
taller than wide rather than a broad bookmark; one visible unmarked 48-pixel
root; seven and only seven 88-pixel action allocations; one visible 32-pixel
short tail; all nine regions remain physically continuous with no horizontal
card seams; every motif is in its safe box and follows the specified order;
only motif seven uses restrained dark-wine; no wax, book, text, modern cards,
metal frame, photographic fabric, or non-Azeroth symbol; the whole master is
legible at 32 x 174 pixels and every action motif at 32 x 22 pixels.

### V2.r1 调用边界

- attempt 2 仍使用用户已授权的固定执行器、同顺序 Image 1／2 与最多 `5` 次
  实际调用总上限；本次调用前累计 `1/5`，成功返回候选后为 `2/5`。
- 不上传 attempt 1：其九区结构失败，不满足 Image 3 edit 前置条件；本次操作
  明确为 `regenerate`。
- 冻结不变：V11 ScrollChild 几何／层序／裁切；九区尺寸；七 Button owner 与
  顺序；粗织旧亚麻身份；七纹章语义；全局与 Quest 美术基线；色键、四态与
  真实排版合同；所有禁项。
- attempt 2 返回后仍从语义／物理结构开始完整审查，并使用候选本身重新生成
  真实排版。通过即停；失败才在剩余 `3` 次额度内制定下一份完整正文。

### attempt 2 执行与完整审查

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---|---|---|---|---|---|---|---|
| `2/5` | `QS-B1 V2.r1` / `bb29988` | regenerate；固定 Image 1／2；无 Image 3 | fixed child `019fd067-eccb-7671-aa39-6de87caa11f4`；provider 返回一张有效图片；复制后因阻止 child 擅自追加第二次生成而由父流程中止，wrapper 退出 `130` | `generated/quests/QS-B1-V2/attempt-02/raw/QS-B1-V2.attempt-02.png`；`fade05990d46671983f931fc2c7e14531d4928c93a4ebb3a87f8046fa9f1fc2a` | bbox／固定九区：raw 可见 `246×1140`、宽高比 `0.2158`，仍比目标 `0.1839` 宽 `17.3%`；等比 fit 后只有 `128×593`，固定 root／tail 为空，不能无缝恢复 `128×696` 九区母版 | 保留连续无横缝亚麻条、空白挂根、七个正确顺序纹章、短毛边尾、暖赭综合色、无火漆／书／文字；这些已满足 Image 3 身份／结构／综合色前置条件，attempt 3 可把本稿作为紧邻 Image 3，仅重绘 bbox 比例、上下占比和九区落位 | `internal-rejected / repair-prepared` |

- raw 尺寸／模式：`1254×1254 RGB`；边缘连通色键后 bbox
  `[500,59,746,1199]`。第 1 张的七卡横缝已经消失，root／七纹章／tail 的物件
  语义在 raw 中成立；失败已从“物件解剖错误”收敛为可编辑的几何落位错误。
- 技术审查 `7/11`。固定九区中 action 1–7 均有可见像素，但 root 与 tail 为
  `0`；综合色、正视层序、七纹章顺序、第四色键隔离和真实 ScrollChild 裁切均
  可保留。没有通过裁切、非等比后处理、逐段搬移或补画伪造通过。
- 真实排版：
  `generated/quests/QS-B1-V2/attempt-02/review/QS-B1-V2.attempt-02.real-layout.png`，
  SHA-256 `3cd5310624edadb1f551d6be11b22319553455c28f495c51d842473feac17ba3`；
  使用真实 `676×464` Frame、`246×324` detail viewport、18 行任务、四个
  `108×41` 奖励槽及四个滚动场景。运行时综合色和纹章可辨性良好，但空 root／
  tail 与错位切片仍是客观阻断，不能因整图观感较好而进入用户复审。
- 本次新增流程错误 `2`，均发生在图片已返回后，不增加生图计数：fixed child
  临时 Python 缺少 Pillow，机械验证失败一次；随后 child 违反 wrapper 意图，
  提议自行追加一次 regenerate。父流程在第二次 provider 调用前发送中断；该
  session 的 generated-images 目录经核对只有一张 PNG。attempt 3 wrapper 将
  明确要求“一次生成后不审查、不修复、不重试，复制并立即停止”。
- Image 3 资格：attempt 2 是紧邻候选；已有一件连续物件、可识别 plain root、
  七个正确顺序动作区、short tail、正确材质／综合色与全部禁项控制。失败只在
  冻结合同内允许修复的 bbox／居中／九区比例，因此允许作为 attempt 3 的
  Image 3 edit input。禁止上传 attempt 1、V1、V10、V11 或 QS-A1。

### 完整修复执行正文 — `QS-B1 V2.r2`

Edit Image 3 as the immediate prior candidate. Do not replace it with a new
unrelated design. Images 1 and 2 remain the fixed higher-authority style
references; Image 3 supplies only the approved object identity, current cloth
painting, current seven motifs, current continuous seam-free construction, and
current warm ochre / umber palette. Preserve those successful properties. Fix
only the frozen geometry and allocation failure described below. Return one
normal-state master and no state variants.

The result is exactly one isolated, connected vertical Azeroth expedition-
guild oath ribbon for a circa-2004 vanilla World of Warcraft quest-log UI. It
is one heavy yet flexible strip of aged coarse-woven linen that will sit under
an existing wax seal at runtime. The wax seal is not part of the image. Its
nine vertically contiguous construction zones are one plain noninteractive
root, exactly seven equal action bands, and one short noninteractive tail. A
deterministic exporter will cut them into nine separately owned textures and
seven real Button hit regions. Do not draw the future hit regions as cards,
panels, outlines, gaps, or stitched pockets.

Preserve from Image 3 without redesign: one straight-on connected cloth strip;
the unmarked linen above the first motif; no horizontal cross seams; the same
broad hand-cut left and right outer edges; the seven existing motif identities
and exact order; near-black ink for motifs 1–6; restrained dark-wine ink only
for motif 7; the short lower fray; muted warm ochre linen, deep umber edge and
upper-left warm light; no wax, book, page, text, labels, metal, other object or
scenery. Keep Image 3's motif drawing vocabulary, but repaint their positions
only as required to put each entire motif inside its exact action safe box.

Correct Image 3's measurable failure. Its current visible aspect is about
0.2158, which is 17.3 percent too wide. Redraw the same cloth noticeably
narrower so its final width:height is exactly 128:696 = 0.183908; equivalently,
the height is exactly 5.4375 times the width. If its height were held constant,
the width would need to be about 85.24 percent of Image 3's current width. This
is an instruction to repaint the silhouette and weave coherently, not to apply
a visible digital squash. The resulting motifs must retain natural proportions
and legibility. Do not keep the current broad bookmark proportion.

Also correct Image 3's vertical allocation. The empty root currently occupies
too much of the strip and the lower empty fray is too tall. Reallocate the same
continuous object by these exact percentages of its visible height, with no
drawn guides or separators:
- plain root: 0.00% through 6.90% of ribbon height;
- action 1: 6.90% through 19.54%; motif center near 13.22%;
- action 2: 19.54% through 32.18%; motif center near 25.86%;
- action 3: 32.18% through 44.83%; motif center near 38.51%;
- action 4: 44.83% through 57.47%; motif center near 51.15%;
- action 5: 57.47% through 70.11%; motif center near 63.79%;
- action 6: 70.11% through 82.76%; motif center near 76.44%;
- action 7: 82.76% through 95.40%; motif center near 89.08%;
- short tail: 95.40% through 100.00% of ribbon height.
Shorten the plain root so motif 1 begins sooner; shorten the post-motif lower
fray so it is only the final 4.60 percent. Keep all seven action allocations
equal. Do not add visible horizontal rules to show those percentages.

The seven fixed action meanings remain, top to bottom:
1. paired quills tied by a compact binding knot for Share Quest;
2. one folded ledger leaf for Detail Toggle;
3. an open guild compass for Show Location;
4. the same compass crossed by one quiet diagonal veil stroke for Hide
   Location;
5. three swept cartographic trail lines for Clean Marks;
6. one winding route returning into a compact knot for Reset Marks;
7. one snapped contract cord with a small central break for Abandon Quest.
Preserve the successful motifs from Image 3, including their hand-painted
softened pigment character. Do not add letters, numerals, runes, faction logos,
skulls, aquilas, double-headed eagles, Imperial insignia, science-fiction
hardware, or another franchise's symbols.

Reference authority remains unchanged:
1. Image 1 is the highest visual authority. Inherit only its circa-2004 vanilla
   WoW low-resolution 2D hand-painted language, broad low-frequency value
   planes, substantial slightly irregular edges, muted ochre / smoked-brown
   palette, short warm upper-left light, tactile material separation, and
   sparse concentrated wear. Ignore its open-book composition, parchment
   pages, leather, straps, compass, wax, bookmarks, brass, rivets, text,
   buttons, and complete UI.
2. Image 2 is adjacency-only authority. Inherit only the accepted quest book's
   local temperature, paint scale, edge softness, light direction, and
   restrained wear. Ignore its silhouette, pages, spine, stitches, gutter,
   corners, transparency, and directly reusable pixels.
3. Image 3 is edit identity authority only. Preserve its one connected linen
   object, current palette, seam-free continuity and seven motifs. Ignore its
   green-field gradient, excessive canvas occupancy, 0.2158 aspect, overlong
   plain top and overlong lower fray. Do not preserve those failures.
If references conflict, Image 1 plus the vanilla Azeroth quest-ledger baseline
wins, then Image 2 for adjacency, while Image 3 wins only for the specifically
preserved object identity and motif painting.

Canvas and occupancy are exact. Output a 1024 x 1024 RGB bitmap. Every pixel
outside the one ribbon is uniform solid #00FF00, with no gradient, texture,
checkerboard, haze, vignette, glow, spill, cast shadow, or loose pixels. Place
the object unrotated in straight-on orthographic front view. Its exact visible
bbox is [448,164,576,860], exactly 128 x 696 pixels. The ribbon occupies only
12.5 percent of canvas width and 67.97 percent of canvas height. Leave exactly
448 pixels of green at both left and right and 164 pixels at both top and
bottom. Do not let the object nearly fill the canvas as Image 3 did. Keep it
centered at x = 512. It must survive one exact four-to-one reduction into a
32 x 174 pixel runtime master without stretching, tiling, or mirroring.

The fixed pixel anatomy within that bbox is mandatory and corresponds exactly
to the percentage allocation above:
- root [448,164,576,212], 128 x 48 pixels;
- action 1 [448,212,576,300], 128 x 88 pixels;
- action 2 [448,300,576,388], 128 x 88 pixels;
- action 3 [448,388,576,476], 128 x 88 pixels;
- action 4 [448,476,576,564], 128 x 88 pixels;
- action 5 [448,564,576,652], 128 x 88 pixels;
- action 6 [448,652,576,740], 128 x 88 pixels;
- action 7 [448,740,576,828], 128 x 88 pixels;
- tail [448,828,576,860], 128 x 32 pixels.
The top 24 pixels of root will be hidden by the existing runtime wax seal. Keep
all 48 root pixels visibly continuous and completely motif-free. Keep all 32
tail pixels visibly continuous; use only a shallow, restrained fray or fork.

Internal slice lines must remain visually absent, preserving Image 3's
successful continuous surface. No full-width horizontal seam, stitch line,
dark rule, ridge, bevel, gap, metal divider, repeated shadow, seven square
patches, or card stack. The same cloth edges, vertical weave, broad light plane,
and lower-right edge shadow flow continuously through all nine zones. Separate
motifs with calm linen breathing room rather than boundaries. High-contrast
wear, tears and fibers stay away from all internal cut coordinates.

Inside each 128 x 88 action zone, keep the complete corresponding motif within
relative safe box [16,12,112,76], 96 x 64 pixels. After reduction this becomes
[4,3,28,19] within a 32 x 22 Button. Center every motif optically. No stroke,
identifying shape, dark-wine mark, tear or high-contrast wear crosses a zone
boundary. Keep quiet visible cloth around every motif. Preserve broad irregular
brush-stamped marks and softened pigment edges. Do not turn them into vector
icons, embossed badges or modern square icon tiles.

Material and style lock: one aged coarse-woven linen strip, never parchment,
leather, metal or photographic fabric. Retain Image 3's smoked warm ochre,
muted old brown, deep umber edge, near-black guild ink and restrained wine
accent. Use a few broad painterly fiber groups and two or three large value
planes, not dense procedural microtexture. Keep the short warm upper-left light
and substantial 2004-era vanilla WoW bitmap weight. It must not become clean
vector art, photoreal burlap, glossy modern UI, a Diablo panel, minimalist
Skyrim overlay, Warhammer emblem, mobile toolbar, web button stack, or generic
fantasy asset.

Strict exclusions: no wax; no book, cover, page, parchment, bookmark, leather,
frame, popup, backdrop, second surface or scenery; no text, labels, cursor or
state names; no hover, pressed, disabled, selected or danger copies; no extra
object, cast shadow, detached decoration or visible guide; no crop, rotation,
perspective, repeated or mirrored section; no disconnected action pieces; no
horizontal seams, cards or square panels; no omitted root or tail; no changed
motif order; no extra eighth action.

Before returning, verify: one connected object; exact 1024 x 1024 RGB canvas;
uniform #00FF00 outside; exact [448,164,576,860] bbox; exact 0.183908 aspect;
root 6.90%, seven equal actions 12.64% each, tail 4.60%; motif centers near the
listed percentages; plain root and short tail both visibly present; no internal
seams; all seven motifs complete and within safe boxes; only motif seven uses
wine; no prohibited object or modern style; readable as 32 x 174 master and
seven 32 x 22 action slices.

### V2.r2 调用边界

- attempt 3 上传固定 Image 1／2，再把 attempt 2 raw（SHA-256
  `fade05990d46671983f931fc2c7e14531d4928c93a4ebb3a87f8046fa9f1fc2a`）
  作为唯一 Image 3；三张图的职责已在正文中完整声明。不得上传其他图片。
- 本次操作是冻结边界内 edit：只修 bbox／居中、整体宽高比、root／action／tail
  高度占比和安全区落位；保留物件身份、综合色、连续无横缝表面和七纹章。
- 当前累计 `2/5`；成功返回一张新图后为 `3/5`。wrapper 必须在一次 generation
  后复制原图并立即停止；禁止 child 自审后追加 regenerate 或 edit。
- 返回后重新执行完整语义、结构、技术、真实排版与展示区域审查。通过即停；
  失败才在剩余 `2` 次额度内改变修复策略。

### attempt 3 执行与完整审查

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---|---|---|---|---|---|---|---|
| `3/5` | `QS-B1 V2.r2` / `93da82e` | edit；固定 Image 1／2；attempt 2 raw 为唯一 Image 3 | fixed child `019fd070-efa7-7371-8c5b-579af5fe118f`；严格只生成一张，复制后正常退出 `0` | `generated/quests/QS-B1-V2/attempt-03/raw/QS-B1-V2.attempt-03.png`；`8b55835dd2206f11509c54596708d8774855ea12c382e6d662e90f5e596cc225` | 组件 safe box：raw 可见 `213×1139`、宽高比 `0.1870`，比例误差已降到 `1.7%`；九片均有像素并连续，但 action 1–6 的 broad-ink 仍进入各段顶部／底部 `12px` 禁入带，固定切片会携带相邻纹章残片；bbox-fit 只能得到 `128×684`，仍非 `128×696` | 保留当前窄条轮廓、九片连续性、空白 root、短 tail、无横缝表面、七纹章身份／顺序／综合色；attempt 4 继续使用本稿为紧邻 Image 3，只把轮廓再收窄约 `1.7%`，并把七纹章重绘为 `80×52` 内框、锚定七个精确中心 | `internal-rejected / repair-prepared` |

- raw 尺寸／模式：`1254×1254 RGB`；边缘连通色键后 bbox
  `[517,57,730,1196]`。目标 aspect `0.183908`，当前 `0.187006`；若保持当前
  高度，只需把可见宽度缩至约当前 `98.34%`。这是局部轮廓修复，不改变物件
  身份或 V11 runtime 几何。
- 技术审查 `9/12`：normalized `1024²`、透明 RGB、九片非空、跨片连续、九片
  runtime 尺寸、四个真实排版场景与命中数量通过；精确 bbox、`≤1%` aspect 和
  七纹章 safe-box 门禁失败。
- broad-ink 诊断在每个 action 的中央 `x=16..112` 内先去除孤立织纹，再检查
  `y=12..76`；action 1–7 的越界比例依次为约 `13.5% / 39.3% / 26.5% /
  11.6% / 13.5% / 7.9% / 0.9%`。这不是用像素阈值替代视觉判断：safe-box
  overlay 同样显示前六个纹章的上下笔画跨线，运行时缩小不能恢复被切断的身份。
- 真实排版：
  `generated/quests/QS-B1-V2/attempt-03/review/QS-B1-V2.attempt-03.real-layout.png`，
  SHA-256 `7738f7fa71c6648a0f4f0eca076174200ed7233858335da0c9f967d38fc84cb7`；
  真实 Frame／18 行／4 奖励槽／四滚动态的总体观感已接近可用，但不允许以整图
  观感覆盖组件切片失败。
- reviewer 已增加 broad-ink safe-box 诊断与可视 overlay；它只生成 ignored
  审查证据，不改变 raw、色键结果、状态图或真实排版像素。最终仍需视觉确认每个
  纹章身份完整、没有被纹理误判。
- Image 3 资格继续成立：attempt 3 是紧邻候选，物件身份、九区连续结构、材质、
  综合色、七纹章顺序和禁项均正确；失败局限于用户授权允许修复的 bbox 与安全区
  内图案位置／辨识度。attempt 4 禁止上传 attempt 2 或任何更旧候选。

### 完整修复执行正文 — `QS-B1 V2.r3`

Edit Image 3, the immediate prior candidate, in place. Images 1 and 2 remain
the fixed higher-authority style references. Preserve Image 3's accepted
single connected linen strip, narrow vertical object identity, unmarked root,
short frayed tail, continuous seam-free weave, hand-cut outer edges, warm ochre
and umber palette, upper-left light, seven motif meanings and order, and lack of
wax, book, text, metal or extra objects. Do not regenerate an unrelated ribbon.
This pass has only two repair jobs: correct the remaining 1.7-percent silhouette
aspect error, and repaint the seven motifs smaller at seven exact centers so no
motif enters a neighboring runtime slice.

Highest-priority motif repair, before all style elaboration: erase and repaint
the seven heraldic motifs on the same continuous cloth. Each motif must fit
entirely inside a stricter centered 80 x 52 pixel inner box, itself safely
inside the authorized 96 x 64 box. Use these exact absolute inner boxes and
centers on the final 1024 canvas:
- action 1 paired quills: box [472,230,552,282], center (512,256);
- action 2 folded ledger leaf: box [472,318,552,370], center (512,344);
- action 3 open guild compass: box [472,406,552,458], center (512,432);
- action 4 veiled guild compass: box [472,494,552,546], center (512,520);
- action 5 swept map trails: box [472,582,552,634], center (512,608);
- action 6 returning route knot: box [472,670,552,722], center (512,696);
- action 7 snapped contract cord: box [472,758,552,810], center (512,784).
Every dark or wine identifying stroke, feather tip, scroll corner, compass
point, veil stroke, trail dot, route loop, knot, cord end and break accent must
remain inside its listed box. Leave at least 18 pixels of calm linen above and
below every motif within its 88-pixel action zone. Leave at least 24 pixels of
calm linen on both sides. Do not let any dark stroke touch an action boundary.

This is a deliberate strategy change from the previous percentage-only edit.
Do not merely shift the entire existing icon column as one group. Independently
scale and center each motif to the exact box above while preserving its current
hand-painted identity. Motifs 1–6 currently cross one or more fixed slice
boundaries; remove those crossing fragments and repaint each complete symbol
inside only its own box. Keep motifs broad and readable at runtime, but compact:
maximum visible motif size is 80 x 52 source pixels, which becomes 20 x 13
runtime pixels. The complete 32 x 22 Button still has calm cloth around it.

The seven meanings and order are frozen:
1. two paired quills joined by one compact binding knot for Share Quest;
2. one folded ledger leaf for Detail Toggle;
3. one open guild compass for Show Location;
4. that compass crossed by one quiet diagonal veil for Hide Location;
5. three swept cartographic trail lines for Clean Marks;
6. one winding route returning into a compact knot for Reset Marks;
7. one snapped contract cord with a small central break for Abandon Quest.
Preserve the successful visual vocabulary of Image 3: broad irregular pigment,
softened painted edges, near-black ink for motifs 1–6 and only restrained dark-
wine ink for motif 7. Do not introduce letters, numerals, runes, faction logos,
skulls, aquilas, double-headed eagles, Imperial insignia, science-fiction
hardware, or any symbol from another franchise.

Second repair job: retain Image 3's current height and make the connected cloth
about 1.66 percent narrower, so the final width is about 98.34 percent of its
current visible width. Redraw the two outer cloth edges and nearby weave
coherently; do not visually squeeze the motifs. The exact target width:height
is 128:696 = 0.183908, so height is 5.4375 times width. Image 3's current aspect
is about 0.187006 and must not be preserved. This small correction must yield a
proportional bbox-fit that occupies the full 128 x 696 target without cropping,
nonuniform deterministic scaling or transparent gaps.

The physical object and component ownership remain fixed. It is exactly one
aged coarse-woven linen oath strip, normal state only, pinned under an existing
wax seal at runtime. The seal is not generated. The continuous master contains
one noninteractive plain root, seven equal action zones owned by seven separate
Buttons, and one noninteractive short tail. The exporter will slice nine
regions; the source must never imply one large hit region or seven independent
cards.

Reference authority and filtering:
1. Image 1 is highest visual authority. Inherit only its 2004-era vanilla WoW
   2D hand-painted bitmap language, broad low-frequency value planes,
   substantial irregular edges, muted ochre / smoked brown, short warm upper-
   left light, tactile separation and sparse wear. Ignore its full book,
   parchment, leather, straps, compass, wax, bookmarks, brass, rivets, text,
   buttons and composition.
2. Image 2 is adjacency-only. Inherit the accepted quest book's temperature,
   paint scale, edge softness, light direction and restrained wear. Ignore its
   silhouette, pages, spine, stitches, gutter, corners, transparency and pixels.
3. Image 3 is edit identity authority. Preserve its connected linen, overall
   painting, palette, no-seam construction and seven motif identities. Ignore
   its remaining 0.187006 aspect and the existing motif sizes / positions that
   cross safe boundaries.
Image 1 plus the Azeroth quest-ledger baseline resolves style conflicts; Image
2 tunes adjacency; Image 3 controls only the explicitly preserved identity.

Canvas contract: exact 1024 x 1024 RGB bitmap. Every pixel outside the one
ribbon is uniform solid #00FF00 with no gradient, texture, checkerboard, haze,
vignette, glow, spill, cast shadow or loose pixel. Straight-on orthographic
front view, no tilt, rotation or foreshortening. Exact visible bbox
[448,164,576,860], 128 x 696 pixels, centered at x = 512. Ribbon occupancy is
12.5 percent of canvas width and 67.97 percent of height; green margins are 448
pixels left/right and 164 pixels top/bottom. Do not let the strip fill the
canvas. It is reduced four-to-one to a 32 x 174 runtime master.

Exact nine-zone anatomy:
- plain root [448,164,576,212], 128 x 48;
- action 1 [448,212,576,300], 128 x 88;
- action 2 [448,300,576,388], 128 x 88;
- action 3 [448,388,576,476], 128 x 88;
- action 4 [448,476,576,564], 128 x 88;
- action 5 [448,564,576,652], 128 x 88;
- action 6 [448,652,576,740], 128 x 88;
- action 7 [448,740,576,828], 128 x 88;
- short tail [448,828,576,860], 128 x 32.
Keep the full root continuous and completely unmarked; its top 24 pixels will
be covered by the existing seal. Keep the full tail continuous with a shallow
restrained fray or fork. Do not lengthen either or create an eighth action.

Preserve Image 3's successful absence of internal separators. No horizontal
seam, cross stitch, rule, ridge, gap, bevel, outline, metal divider, repeated
shadow, square patch, icon tile or card stack. The same outer edges, vertical
weave, broad upper-left light and lower-right shadow flow through all nine
zones. Internal cut coordinates remain visually absent. Keep tears, strong
fibers and high-contrast wear away from all cut lines.

Material and style: heavy but flexible aged coarse-woven linen, not parchment,
leather, metal or photographic fabric. Preserve smoked warm ochre, muted old
brown, deep umber edge, near-black guild ink and the single dark-wine accent.
Use only a few broad painterly fiber groups and two or three large value planes,
not dense procedural microtexture. Keep the substantial, slightly irregular,
low-resolution 2004 vanilla WoW bitmap feeling. No vector-clean pictograms,
photoreal burlap, glossy modern UI, Diablo panel, minimalist Skyrim overlay,
Warhammer emblem, mobile toolbar, web buttons or generic fantasy icon column.

Strict exclusions: no wax; no book, cover, page, parchment, bookmark, leather,
frame, popup, backdrop, second surface or scenery; no text, labels, cursor or
state names; no hover, pressed, disabled, selected or danger copies; no extra
object, cast shadow, detached decoration or guide; no crop, rotation,
perspective, repeated or mirrored section; no disconnected pieces; no internal
card seams; no omitted root or tail; no changed order; no eighth motif.

Before returning, verify in this order: exactly one connected ribbon; exact
1024 x 1024 and uniform #00FF00 outside; exact 128 x 696 bbox and 0.183908
aspect; nine continuous zones; root and tail visibly present; seven motifs each
no larger than 80 x 52 and centered exactly in the seven listed boxes; no dark
or wine stroke outside those boxes; no internal separators; correct seven
meanings and order; only motif seven uses wine; no prohibited content; each
motif remains complete and readable in its own isolated 32 x 22 runtime slice.

### V2.r3 调用边界

- attempt 4 上传固定 Image 1／2，再把 attempt 3 raw（SHA-256
  `8b55835dd2206f11509c54596708d8774855ea12c382e6d662e90f5e596cc225`）
  作为唯一 Image 3。不得上传 attempt 2、attempt 1 或其他图片。
- edit 冻结保留：单物件、九区 owner／顺序、连续无缝亚麻、七纹章身份／顺序、
  综合色、Quest／全局基线、V11 runtime 几何和全部禁项。只修 `1.7%` aspect
  误差、七纹章尺寸和七个安全中心。
- 当前累计 `3/5`；成功返回后为 `4/5`。一次 provider call 后立即复制并停止，
  不允许 child 自检或追加生成。若第 4 张仍失败，最后一次必须再次改变策略；
  不得重复相同正文抽卡。

### attempt 4 执行与完整审查

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---|---|---|---|---|---|---|---|
| `4/5` | `QS-B1 V2.r3` / `0a35e1d` | edit；固定 Image 1／2；attempt 3 raw 为唯一 Image 3 | fixed child `019fd07d-54f2-7221-ab7a-fda047d14b97`；严格一张，正常退出 `0` | `generated/quests/QS-B1-V2/attempt-04/raw/QS-B1-V2.attempt-04.png`；`214a30a0afd769590c32f17b2d65c4778a0f4bbb683565e28f36eb83ced99ac4` | 组件 safe box：整数感知等比 fit 后 bbox 已精确 `128×696`，其余结构／展示门禁通过；但 action 1、2、3、6、7 仍有明显 broad-ink 进入各段上下禁入带，action 2 还包含来自 action 1 的跨片残笔 | 冻结当前精确轮廓／bbox、九片连续性、亚麻、综合色、root／tail 与全部禁项；最后 attempt 5 不再移动轮廓，改为清除七区旧墨迹后，在更小 `64×40` 中央内框分别重绘七个纹章 | `internal-rejected / repair-prepared` |

- raw 尺寸／模式：`1254×1254 RGB`；边缘连通色键后 bbox
  `[520,58,729,1192]`，即 `209×1134`、aspect `0.184303`，相对目标误差
  `0.21%`。整数感知等比 fit 以高度为比例，`209×1134 → 128×696`；两个轴
  来自同一比例后分别按像素四舍五入，既不越过 `128×696`，也不裁切、不逐轴
  指定不同设计比例。normalized bbox 精确 `[448,164,576,860]`。
- reviewer 已从“总取连续最小比例”修正为“分别评估 width／height 等比比例，
  在整数四舍五入后仍不越界的候选中选择最大占用”。attempt 1–3 不因此伪通过；
  attempt 4 的 height-led 候选正好成为 `128×696`。这是流程错误修正，不调用
  provider，不计额度。
- 当前技术审查 `11/12`：仅 `all_action_motifs_stay_inside_vertical_safe_boxes`
  失败。action 1–7 broad-ink 越界比例约为 `15.9% / 51.7% / 6.5% / 0% /
  2.2% / 5.9% / 7.2%`；action 4／5 已通过，但整条母版必须七段全部通过。
- 真实排版：
  `generated/quests/QS-B1-V2/attempt-04/review/QS-B1-V2.attempt-04.real-layout.png`，
  SHA-256 `f719c565e5aa57d65498d315ec7aa8460bef189b4de7afbf3c17ea82b4278e30`；
  frame、信息密度、奖励、四滚动态、命中数、综合色均正确。阻断只来自真实
  Button 切片中的跨区墨迹，不能因其在整条 32px 宽预演中不明显而忽略。
- Image 3 资格：attempt 4 是紧邻候选且除局部墨迹外全部冻结结构、美术与技术
  门禁正确。最后一次 edit 允许清除／重绘安全区内纹章，但不得改变轮廓、bbox、
  亚麻纹理、root、tail、九区 owner、滚动关系或综合色。

### 完整修复执行正文 — `QS-B1 V2.r4`

Edit Image 3, the immediate prior candidate, as a surgical ink-only repair.
Images 1 and 2 remain fixed style references. Image 3's cloth object is now
accepted and frozen: preserve its exact connected silhouette, current height
and width, exact centered position, root, tail, outer edges, continuous weave,
warm ochre / umber palette, upper-left lighting, wear, and green-field layout.
Do not make the ribbon narrower, wider, taller, shorter, or differently placed.
Do not redesign or regenerate the cloth. The only permitted visible changes are
removing all seven current heraldic ink motifs and repainting exactly seven
smaller complete motifs at seven isolated centers.

First, cleanly remove every current dark or wine motif pixel from all seven
action regions, including every fragment that crosses a horizontal slice
boundary. Restore the exposed locations with the same surrounding continuous
linen weave and broad value plane, without creating erased rectangles, blank
stripes, blur patches, horizontal seams, or changes to the cloth silhouette.
In particular, remove the tied-quill fragment currently entering action 2 and
all route / cord fragments near neighboring bands. Preserve no old out-of-box
ink. This erase-and-repaint strategy replaces the prior attempt's incremental
scaling strategy.

Then repaint exactly seven compact heraldic motifs, one per action, and place
every identifying stroke entirely inside these stricter 64 x 40 absolute boxes
on the final 1024 canvas:
- action 1 paired quills: [480,236,544,276], center (512,256);
- action 2 folded ledger leaf: [480,324,544,364], center (512,344);
- action 3 open guild compass: [480,412,544,452], center (512,432);
- action 4 veiled guild compass: [480,500,544,540], center (512,520);
- action 5 three swept map trails: [480,588,544,628], center (512,608);
- action 6 returning route knot: [480,676,544,716], center (512,696);
- action 7 snapped contract cord: [480,764,544,804], center (512,784).
The maximum visible motif size is 64 x 40 source pixels, or 16 x 10 runtime
pixels. Keep at least 24 completely ink-free linen pixels above and below each
motif before its 88-pixel action boundary, and at least 32 ink-free linen pixels
to the left and right. No feather, knot, scroll corner, compass point, diagonal
veil, trail dot, route curve, loop, cord end, break accent, dark antialias pixel
or wine antialias pixel may leave its listed box.

Do not treat the seven boxes as visible cards. They are invisible placement
constraints only. Paint no box edge, guide, horizontal rule, cleaned rectangle,
patch, seam, shadow, stitch or backing behind a motif. The same continuous
linen texture must remain visible between all symbols. Each runtime Button is
created later by slicing; the image itself remains one unbroken oath cloth.

The frozen seven meanings and order are:
1. two short paired quills tied by one very compact binding knot for Share;
2. one compact folded ledger leaf for Detail Toggle;
3. one compact open four-point guild compass for Show Location;
4. the same compact compass crossed by one short quiet diagonal veil for Hide;
5. three compact swept cartographic trail lines for Clean Marks;
6. one compact winding route returning into one small knot for Reset Marks;
7. one compact snapped contract cord with a small central break for Abandon.
Simplify interior strokes as needed to remain readable within 64 x 40: use a
few broad hand-painted shapes rather than many fine lines. Preserve near-black
guild ink for motifs 1–6. Only motif 7 uses restrained low-saturation dark-wine
ink. Do not add any eighth motif, letters, numerals, runes, faction symbols,
skulls, aquilas, double-headed eagles, Imperial marks, science-fiction hardware
or another franchise's icon.

Reference authority:
1. Image 1 is highest style authority. Inherit only the circa-2004 vanilla WoW
   2D hand-painted bitmap language, broad low-frequency paint, substantial
   irregular edges, muted ochre / smoked-brown palette, short warm upper-left
   light, tactile separation and sparse wear. Ignore its book, parchment,
   leather, straps, compass, wax, bookmarks, brass, rivets, text, buttons and
   full composition.
2. Image 2 is adjacency-only. Inherit only accepted quest-book temperature,
   paint scale, edge softness, light direction and restrained wear. Ignore its
   silhouette, pages, spine, stitches, gutter, corners, transparency and pixels.
3. Image 3 is the frozen object authority. Preserve its complete cloth pixels,
   silhouette, bbox, root, tail, continuous texture and palette. Ignore and
   replace only its existing seven motifs and all leaked ink fragments.
Image 1 plus the Azeroth quest-ledger baseline resolves style; Image 2 only
tunes adjacency; Image 3 controls the frozen physical object.

Frozen canvas and silhouette contract: exact 1024 x 1024 RGB bitmap; exactly
one straight-on connected ribbon; uniform solid #00FF00 everywhere outside;
no gradient, texture, checkerboard, haze, vignette, glow, spill, cast shadow or
loose pixel. Preserve the exact visible bbox [448,164,576,860], 128 x 696,
centered at x = 512. Preserve 448 pixels of green left/right and 164 pixels
top/bottom. Preserve the exact width:height 0.183908 and the existing ribbon's
current height-led equal-ratio fit. No crop, stretch, shift, rotation,
perspective, enlargement or reduction.

Frozen anatomy:
- plain root [448,164,576,212], 128 x 48, no motif;
- action 1 [448,212,576,300], 128 x 88;
- action 2 [448,300,576,388], 128 x 88;
- action 3 [448,388,576,476], 128 x 88;
- action 4 [448,476,576,564], 128 x 88;
- action 5 [448,564,576,652], 128 x 88;
- action 6 [448,652,576,740], 128 x 88;
- action 7 [448,740,576,828], 128 x 88;
- short tail [448,828,576,860], 128 x 32, no motif.
Preserve all nine physically continuous zones and the current seamless
reconstruction. Root and tail receive no ink. The existing wax seal is not in
this image and must not be generated.

Frozen material and style: Image 3's heavy flexible aged coarse-woven linen,
smoked warm ochre, muted old brown, deep umber edge, broad upper-left light and
few painterly fiber groups. Do not convert it to parchment, leather, metal,
photographic burlap, vector art, glossy modern UI, Diablo, minimalist Skyrim,
Warhammer, mobile toolbar, web buttons or generic fantasy icons. No wax, book,
page, bookmark, frame, popup, backing, text, cursor, state variants, extra
object, detached decoration, visible guides, internal card seams, metal
dividers, repeated sections or altered action ownership.

Before returning, verify in this order: the cloth silhouette and bbox are
pixel-for-pixel conceptually unchanged; exactly seven old motifs were removed
without erased patches; exactly seven new motifs exist; each entire motif and
all antialias ink lie inside its own listed 64 x 40 box; at least 24 pixels of
ink-free linen remain above and below every motif; no ink crosses any cut line;
the seven meanings and order are correct; only motif 7 is wine; root and tail
remain unmarked; no separator or prohibited object appears; each isolated
32 x 22 runtime action slice contains one complete readable motif and no part
of another motif.

### V2.r4 最终调用边界

- attempt 5 上传固定 Image 1／2，再把 attempt 4 raw（SHA-256
  `214a30a0afd769590c32f17b2d65c4778a0f4bbb683565e28f36eb83ced99ac4`）
  作为唯一 Image 3。不得上传任何其他图片。
- 本次只允许 ink-only erase／repaint。轮廓、bbox、root、tail、材质、综合色、
  九区、V11 runtime 与全部禁项冻结；不得再次改 aspect 或布局。
- 当前累计 `4/5`；返回即为 `5/5`。一次 provider call 后立即复制并停止。若
  第 5 张仍有任一客观门禁失败，必须标记
  `candidate-rejected / repair-budget-exhausted` 并停止等待用户审核；禁止第 6 次。

## QS-B1 V2 用户终止与 V3 分层改向 — `2026-08-05`

用户在 V2 attempt 4 的真实排版方向上提出两个根本问题：其一，绶带质感差且
过于工整；其二，把背景与七项功能纹章烘焙在一张纵向图内，无法按配置隐藏
任意功能。用户明确要求功能资源单独出图，再叠到一条背景上。该反馈改变资产
所有权，不属于 V2.r4 的 ink-only 冻结修复边界，因此：

- `QS-B1 V2` 终止为
  `candidate-rejected / user-superseded-before-attempt-5 / 4/5`；
- `QS-B1 V2.r4` 只保留为历史未执行正文，attempt 5 **没有调用**，也不得再
  调用；V2 既有授权与剩余一次额度不转移给 V3；
- attempt 1–4 均不得成为 V3 source、runtime、纹理参考或 Image 3 edit 输入；
- V2 没有 source、atlas、addon 菜单接入或旧按钮隐藏，当前 fail-open 不变。

## QS-B1 V3：动态空白旧布底＋七个独立透明纹章

- 当前模拟：`QUEST-LOG-SEAL-ACTIONS-SIM-V12`；状态
  `simulation-rendered / awaiting-user-confirmation / P2`。
- spec：
  `tools/specs/quest_log_seal_layered_actions_simulation_v12.json`；renderer：
  `tools/render_quest_log_seal_layered_actions_simulation_v1.py`。
- 真实排版模拟：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-ACTIONS-SIM-V12/quest_log_seal_layered_actions_board_v12.png`；
  本地几何与交互检查 `35/35 pass`，ImageGen `0/0`。
- 展示区域合同：
  `tools/specs/quest_log_seal_actions_simulation_v12_display_region.json`；覆盖
  收起、七项全显、隐藏两项、仅三项且一项 disabled、部分滚动和完全滚出六个
  场景，`6/6 pass`、violations `0`。

### V3 资产所有权

1. 背景只表达一条连续的旧亚麻布，不含任何功能图案、文字、状态或命中区。
   它由无鼠标 `root`、不属于任何功能的无缝 `body variants` 与无鼠标 `tail`
   组成；运行时按可见功能数拼成一个连续背景。该拆分只服务动态长度，视觉上
   不得出现横向接缝、卡片格或重复模块。
2. 共享、详情开合、显示位置、隐藏位置、清理标记、重置标记与放弃任务必须
   各有一张独立透明 normal 纹章母版。七张 source 可在 runtime 中确定性打包
   atlas，但必须保留独立 UV、manifest ID 和真实 Button 所有权；不得把任何
   纹章重新烘焙进背景。
3. `hidden` 从 visible order 中移除并使后续 Button 与背景无空洞收拢；
   `disabled` 保留在排列中，使用派生退色态且不接收点击；hover／pressed／
   disabled 由 accepted normal 母版确定性派生，不重新生成七套轮廓。
4. 漆章、背景和七个 Button 仍属于 `QuestLogDetailScrollChild`，共同随正文
   滚动并由 `[366,64,246,324]` viewport 裁切；部分露出的 Button 禁用完整
   hitbox，完全滚出时命中数为零。正文与奖励不重排。

### V3 质感与“不工整”可检查条款

- 背景使用宽而低频的褶皱、综合色块和不对称污渍；左右手裁边缘只做少量、
  非周期性的偏移。磨损集中在少数受力点，不能铺满均匀颗粒、程序化织纹、
  压花壁纸或全长等亮边。
- 各 body variant 的明暗与纤维走向连续，但缺陷位置不得按 `22px` 功能节距
  重复；拼接后不能读出七格、水平分区或复制粘贴的相同斑点。
- 七个纹章使用不完全着墨的公会印墨：轮廓有克制缺口、边缘轻微渗化、线宽
  不完全一致，并在各自 `32×22px` Button 内采用独立的 `±1px` 视觉重心偏移；
  禁止七枚同尺寸、同中心、同笔压的精确图标柱，也禁止现代矢量 icon。
- 不规则不是随机噪点或破坏可读性：每个纹章的语义轮廓必须在运行时尺寸下
  完整可辨，全部可见墨迹仍留在自己的透明资源安全区内。

V12 模拟像素只验证几何、层序与动态策略，不是 source、runtime 或未来
ImageGen 输入。用户确认 V3 结构和模拟方向后，才可分别准备“空白动态背景”与
“七个透明纹章”生产合同，并重新请求独立的正式生图／上传授权。

## V12 用户确认与 V3 生产拓扑收敛 — `2026-08-05`

- 用户确认原文：`可以`。
- 确认对象：`QUEST-LOG-SEAL-ACTIONS-SIM-V12 / QS-B1 V3`。
- 当前状态：`simulation-confirmed / P3 / V3-A repair-budget-exhausted /
  V3-B gated / user-review-required`。
- 本次确认冻结：空白旧布背景与七个功能纹章分层；七个纹章分别归属于七个
  独立 Button；hidden 项无空洞收拢；disabled 项留位但不命中；漆章、背景和
  Button 均留在 `QuestLogDetailScrollChild`，随正文滚动并被真实 viewport
  裁切；正文与奖励不重排；旧入口在 parity 完整前继续原子 fail-open。
- 本次确认没有接受 V12 模拟像素、最终布料笔触、最终纹章像素、Alpha、状态
  atlas、Tooltip、动画或客户端裁切实现；V12 board／report 仍不得上传给
  ImageGen，也不得晋级 source／runtime。

### 生产拓扑的无视觉变化收敛

V12 用 `root + seamless body variants + tail` 验证动态长度。正式生产将其
收敛为更直接、也更符合用户“一条背景”要求的同视觉实现：

1. ImageGen 只生成一条完全空白、最大七项长度的连续旧亚麻布母版；其内部仍
   按 `root 48px + 7 × body 88px + tail 32px` 保留确定性装配坐标，但不画
   分段线，也不生成三个重复布片。
2. exporter 从同一连续母版取得 `root + 7 段 body capacity` 的最大前缀和
   独立 tail cap。runtime 按 `visible_count` 只显示前
   `12 + visible_count × 22px`，再把 `32×8px` tail 接到当前末端。背景没有
   action ID、纹章、状态或命中区。
3. 该实现不改变 V12 的任何屏幕坐标、可见高度、奖励前 `32px` 留白、滚动
   裁切或交互语义；它只消除 body variant 重复、跨片接缝和 `22px` 周期。
   因而不需要新的几何模拟版本。
4. 七个纹章由另一执行正文生成。provider 可返回一张固定七格的隔离工作表，
   但 P4 必须把七格导出为七张独立 tracked RGBA source、七个 manifest ID
   和七个独立 UV；工作表本身绝不作为 runtime 背景或单一菜单对象加载。

### 两个独立生产执行体

| 执行体 | 生成对象 | 固定输入 | 最多实际调用 | P4 所有权 |
|---|---|---|---:|---|
| `QS-B1 V3-A` | 一条无纹章、无功能含义的连续动态旧布母版 | Image 1 任务详情锁定图；Image 2 QL-A1 accepted shell | `5` | 一张 substrate source；runtime 最大前缀＋tail |
| `QS-B1 V3-B` | 七格互相隔离的 normal 印墨纹章工作表 | Image 1 任务详情锁定图；Image 2 QL-B1 accepted directory marks | `5` | 七张独立 motif source；runtime 七列四态 atlas |

执行顺序固定为 V3-A 后 V3-B。V3-A 未取得可接受候选时停止，不提前执行
V3-B；V3-B 的 ImageGen 输入也不得包含 V3-A 候选，V3-A 只可在本地真实排版
预演中作为相邻背景使用。两段最坏合计 `10` 次实际 ImageGen 调用；流程错误
只有在没有图片、provider result 或生成作业证据时才不占额度。

### V3 联合生产授权 — `2026-08-05`

- 用户授权原文：`确认授权 QS-B1 V3-A 与 V3-B；按顺序先执行 V3-A、通过后再执行 V3-B；允许每段上传合同中的固定 SHA Image 1/2，并允许同段紧邻前次输出仅在冻结边界内作为 Image 3 edit 输入；每段最多 5 次实际 ImageGen 调用，最坏合计 10 次，流程错误不占额度；允许执行合同内的确定性归一化、色键、独立拆分、四态派生及真实排版预演。`
- 授权执行器：只使用 `imagegen-0-143-0 / @openai/codex@0.143.0`；不得改用
  会话内建 imagegen。
- 执行顺序：先 `QS-B1 V3-A`；只有其全部内部门禁通过并停止在
  `candidate-reviewed / P3` 后，才开始 `QS-B1 V3-B`。
- 固定上传：每段各自合同中的固定 SHA Image 1／2；Image 3 只允许为同段、
  紧邻前次输出且仍处于冻结修复边界内的 edit input。不得跨段上传候选，
  不得上传模拟、旧失败稿、review 派生图、runtime atlas 或 addon 截图。
- 实际生图预算：V3-A `5/5`；V3-B `0/5`；最坏 `10`。无图片且无 provider
  result／生成作业证据的流程错误不占额度，但须单独记录。
- 确定性范围：只限合同中的归一化、边缘连通色键、透明 RGB 清零、等比
  bbox-fit、V3-A prefix／tail crop、V3-B 独立 cell 拆分、四态派生、atlas
  装配、metrics、实际展示区域检查与真实排版预演；不得借此修复语义、材料、
  构图或纹章身份。
- 本授权不接受任何尚未生成的候选，不授权 P4 source／manifest、P5 runtime／
  addon 接入，也不授权隐藏旧按钮。

## QS-B1 V3-A — 动态空白旧布母版 production preparation

### 元数据、固定输入与产物合同

- 版本：`QS-B1 V3-A`。
- 状态：`internal-rejected / repair-budget-exhausted / 5/5 / user-review-required`。
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`。
- Image 1（最高视觉权威）：
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`，SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
- Image 2（受限邻接权威）：
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`，SHA-256
  `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
- planned source：
  `assets/source/quests/qs-b1/QuestLogSealMenuSubstrate_Master_v3.png`。
- planned source manifest：
  `assets/source/quests/qs-b1/QS-B1-V3A_SourceManifest_v1.json`。
- planned runtime atlas：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogSealMenuSubstrateV3.tga`。
- planned shared exporter：`tools/build_quest_log_seal_menu_v3.py`；任何文件只在
  具体候选经用户接受并授权 P4 后创建。

唯一生成对象是一条正面正投影的连续空白亚麻布。canonical accepted source
为 `1024×1024 RGBA`，可见 bbox `[448,164,576,860]`、`128×696px`。
内部逻辑比例为 root `128×48`、七段无功能 body capacity 各 `128×88`、tail
`128×32`；这些是裁取坐标，不得在画面上形成横线、格子、相同折痕或重复斑点。

exporter 只在候选通过物件／材料／纹理门禁后执行：边缘连通色键、透明 RGB
清零、完整 bbox 等比 fit 到 `128×696px`，不得裁边、非等比拉伸、旋转、镜像、
补画或局部搬移。runtime atlas 计划为 `128×256 RGBA TGA`：最大前缀
`32×166px` 放在透明安全区 `[16,0,48,166]`；tail `32×8px` 放在
`[80,0,112,8]`。runtime 用 UV 裁取前
`12 + visible_count × 22px`，tail 紧接当前末端；closed 只显示 root，open
才显示 tail。该 prefix／tail crop 不改变 source 像素。

### 完整性预检

- 复杂度：`one continuous blank master + deterministic prefix crop + tail cap`。
- 结论：`pass`。

| 门禁 | 正文证据 | 结论 |
|---|---|---|
| 物件、数量与所有权 | exactly one blank oath-linen strip；无 motif／文字／状态／命中区 | pass |
| 两张参考的 inherit／ignore／冲突顺序 | Image 1 裁决年代与笔触；Image 2 只裁决相邻综合色与绘制尺度 | pass |
| Canvas、bbox、方向、尺度和光照 | `1024²`、`[448,164,576,860]`、正面正投影、左上短暖光 | pass |
| 动态分解与裁取安全 | root／七段 capacity／tail 坐标完整；切线附近无强横向特征 | pass |
| “不工整”材料条款 | 低频不对称褶皱、非周期污渍、少数受力磨损、手裁边缘 | pass |
| 反模式与动态内容排除 | 禁止重复 22px 缺陷、程序化织纹、压花壁纸、现代按钮、所有功能图案 | pass |
| 色键、导出与真实排版 | 固定 chroma／bbox-fit 边界；候选必须进入 7／5／3 项与滚动态真实排版 | pass |

未知但执行必需的值：`无`。

### V3-A attempt 1 执行与审查 — `2026-08-05`

- 执行前 commit：`1d7a9f2`；固定执行器：
  `imagegen-0-143-0 / @openai/codex@0.143.0`；完整 `QS-B1 V3-A` 正文由
  child 逐字回显，无截断或 revised prompt。
- 固定输入：Image 1
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`
  (`03dc589a…53bd`)；Image 2
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`
  (`91f9fece…edd5`)；无 Image 3。
- fixed child／provider result：
  `019fd0fb-be3b-7290-90f3-5676326e7382`；明确只调用一次 ImageGen。child
  的只读 sandbox 无法复制到工作区，但 provider 原图已生成；父流程只复制
  同一字节到 attempt 路径，没有再次生图、修图或确定性改画，因此仍为一次
  可计数输出，不记为“无生成证据”的流程错误。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V3-A/attempt-01/raw/QS-B1-V3-A.attempt-01.png`；
  `1254×1254 RGB`；SHA-256
  `4fc5c208b2d9313e90872e9822af88db073a245a9f08ce53b082ed6988a116ab`。
- 确定性检查：方形 raw 同轴归一化到 `1024²` 后，边缘连通色键得到恰好一个
  连通物件；可见 bbox `[389,69,635,955]`、`246×886`、宽高比
  `0.277652`。目标为 `0.183908`，相对误差 `50.97%`；等比 bbox-fit 只能
  得到 `128×461`、可见 `[448,281,576,742]`，不能覆盖目标
  `[448,164,576,860]`。`32×174` review master 的可见 bbox 仅
  `[0,27,32,147]`，root／tail 和首末动态切点均为空。
- 第一失败门禁：`4. 美术一致性`。raw 表面被全幅、细密、近照片式的均匀
  burlap／微型纤维纹理主导，呈现程序化麻布而非香草魔兽低分辨率手绘的宽面
  明暗、少量低频褶皱与稀疏纤维组；顶部与长边也过于裁切规整。该问题在
  `32px` 宽真实排版中收缩成一条现代、平直、颗粒化的浅色带。
- 次要客观失败：bbox／动态裁取合同。自动技术检查 `5/9 pass`；失败为目标
  bbox、宽高比、runtime 可见 bbox 和全部动态切带覆盖。几何与交互公式仍为
  `26/26 pass`；实际展示区域报告覆盖 closed、7／5／3 项、scroll `52`／
  `208` 六场景，`6/6 pass`、violations `0`，但它只证明 Frame／命中几何，
  不能抵消候选 Alpha 和材料失败。
- review：
  `generated/quests/QUEST-SEALS/QS-B1-V3-A/attempt-01/review/QS-B1-V3-A.attempt-01.review.json`
  (`1aff5dcd…5e70`)；真实排版
  `QS-B1-V3-A.attempt-01.real-layout.png` (`6773bd9f…0897`)；display-region
  report `QS-B1-V3-A.attempt-01.display-region-report.json`
  (`f9327e24…cc9`)；contact sheet `QS-B1-V3-A.attempt-01.contact-sheet.png`
  (`e44175d7…91c`)。V3-B 纹章仍是明确标注的 V12 本地几何占位，不是本次
  生产候选或 ImageGen 输入。
- reviewer：`tools/review_quest_seal_menu_substrate_candidate_v3.py`；macOS
  使用 `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`、Python `3.12.12`。
  先以 `conda run -n py312 python <reviewer> <raw> <review-dir>
  --repo-root <repo> --attempt QS-B1-V3-A.attempt-01 --repo-commit 1d7a9f2
  --session-id 019fd0fb-be3b-7290-90f3-5676326e7382` 生成候选审查与真实排版，
  再以 `validate_display_regions.py <display-contract> --report
  <display-region-report>` 验证实际展示区域。
- 保留区域：恰好一个空白、连续、正面布条；无纹章／文字／蜡／书／状态；
  暖赭烟褐综合色、单一垂直纤维方向和克制短毛边 tail。对象身份、主要层序
  与禁止烘焙均正确。
- 下一决策：`edit`。失败只位于同段允许修复的 bbox、综合色频率、边缘克制度
  与切点连续性，且单物件／空白语义／综合色／主要解剖仍成立，因此 attempt 1
  raw 可作为紧邻唯一 Image 3。attempt 2 必须把宽高比收窄为目标、补满 root
  与 tail，并彻底重绘全幅细密麻布纹为两三块宽面、少量非周期软褶与污渍；
  不得只在原表面叠加几条褶皱。
- 结论：`internal-rejected / repair-prepared / 1/5`；不得进入用户复审、P4、
  source、runtime 或 addon。

| 实际生图 | 正文／执行前 commit | 操作 | session／result | raw／SHA | 第一失败门禁 | 保留与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| `1/5` | `QS-B1 V3-A` / `1d7a9f2` | generate；固定 Image 1／2 | `019fd0fb-be3b-7290-90f3-5676326e7382` | `attempt-01` / `4fc5c208…16ab` | 美术一致性：照片式全幅微织纹；另有 `50.97%` 宽高比误差 | 保留单一空白布、暖赭综合色与短 tail；紧邻 Image 3 edit，重绘比例／低频表面／切带 | `internal-rejected / repair-prepared` |

### V3-A attempt 2 执行与审查 — `2026-08-05`

- 执行前 commit：`7ded993`；执行完整 `QS-B1 V3-A.r1`。固定 Image 1／2
  SHA 不变，并上传 attempt 1 raw (`4fc5c208…16ab`) 作为同段紧邻唯一
  Image 3；child 完整回显正文和三图职责，无截断或 revised prompt。
- fixed child／provider result：
  `019fd106-5813-74d3-be0d-45c7d0a3598f`；明确只调用一次 ImageGen。child
  只读复制失败后，父流程复制同一 provider 字节到本次 attempt；仍计一次
  实际修图，不另记无生成证据流程错误。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V3-A/attempt-02/raw/QS-B1-V3-A.attempt-02.png`；
  `1254×1254 RGB`；SHA-256
  `5bfb32ef85f153ecb62d8c6d489602a349b93fd3d2ffdac553be5a0404f37b3b`。
- 确定性检查：同轴归一化后恰好一个连通物件；bbox
  `[403,114,619,916]`、`216×802`、宽高比 `0.269327`。相对目标误差
  `46.45%`，只比 attempt 1 的 `50.97%` 改善 `4.52` 个百分点；等比 fit
  仍只有 `128×475`、可见 `[448,274,576,749]`。runtime 可见 bbox 仅
  `[0,25,32,149]`；root、tail 与首末切点仍为空，四种动态 tail 接合均无
  可比较重叠像素。
- 第一失败门禁仍为 `4. 美术一致性`。attempt 2 没有重绘掉全幅微纹，反而把
  内部变成更一致、更清晰的细小卷曲线圈／程序化纤维墙纸；在实际尺寸仍读作
  规则现代纹理带，不是香草魔兽手绘旧布。轮廓顶部仍水平裁齐，长边仍近机器
  直切。该首要失败已连续两次出现。
- 次要客观失败仍为 bbox／动态裁取。自动技术检查继续 `5/9 pass`；真实
  Quest Log 公式 `26/26 pass`，display-region 六场景 `6/6 pass`、violations
  `0`，但候选自身仍不能覆盖真实 prefix／tail 像素。
- review：`attempt-02/review/QS-B1-V3-A.attempt-02.review.json`
  (`8c55dbe3…31de`)；真实排版 `QS-B1-V3-A.attempt-02.real-layout.png`
  (`ca22921b…741e`)；display-region report
  `QS-B1-V3-A.attempt-02.display-region-report.json` (`66b5004b…6024`)；contact
  sheet `QS-B1-V3-A.attempt-02.contact-sheet.png` (`a15a642d…cec7`)。
- 保留区域：单一、空白、连续、正面布条；无误生功能内容；暖赭综合色、短
  frayed tail 与一条连续垂直材质方向仍正确。
- 下一决策：`regenerate`。按“相同首要失败连续出现必须改变策略”，attempt 3
  禁止上传 attempt 2 或其他 Image 3，只使用固定 Image 1／2 从零重生。新正文
  把轮廓直接定义为高宽 `5.4375:1` 的极窄长条，并禁止任何可见的连续线圈、
  逐像素纤维、全幅 crosshatch／burlap；cloth 身份只能由宽面明暗、极少数
  粗纤维组、柔软折面和手裁边缘表达。
- 结论：`internal-rejected / repair-prepared / 2/5`；不得进入 V3-B、用户复审、
  P4、source、runtime 或 addon。

| `2/5` | `QS-B1 V3-A.r1` / `7ded993` | edit；固定 Image 1／2＋attempt 1 Image 3 | `019fd106-5813-74d3-be0d-45c7d0a3598f` | `attempt-02` / `5bfb32ef…7b3b` | 同一美术失败：全幅规则卷曲纤维；宽高比误差 `46.45%` | 保留单物件身份；改变策略，只用 Image 1／2 regenerate | `internal-rejected / repair-prepared` |

### V3-A attempt 3 执行与审查 — `2026-08-05`

- 执行前 commit：`343457d`；执行完整 `QS-B1 V3-A.r2`，只上传固定 SHA
  Image 1／2，无 Image 3。child 完整回显正文，明确仅进行一次 regenerate，
  无截断或 revised prompt。
- fixed child／provider：session
  `019fd10d-b73c-75b0-bd58-1fb980d773a6`；result
  `ig_0058e0813ec24bfe016a72f5404ef88191b0d710951b0954c5`。provider 原图
  生成后由父流程复制同一字节到 attempt 路径，实际调用累计 `3/5`。
- raw：`attempt-03/raw/QS-B1-V3-A.attempt-03.png`；`1254×1254 RGB`；
  SHA-256 `737acc4b9a314e08fb9d7dbfca8d0173e8f26bf23b15a2d50297f613ccf84cac`。
- 确定性检查：一个连通物件；归一化 bbox `[411,22,613,996]`、
  `202×974`、宽高比 `0.207392`，相对目标误差 `12.77%`。这比 attempt 2
  的 `46.45%` 显著改善，但等比 fit 仍只有 `128×617`、可见
  `[448,203,576,820]`；runtime bbox `[0,7,32,167]`，因此 top 缺 `7px`、
  bottom 缺 `7px`，tail 顶部只剩 `10` 个重叠像素且 N=1／3／5 的平均 RGB
  跳变约 `135..141`，N=7 无重叠。
- 第一失败门禁仍为 `4. 美术一致性`，但程度已降低。真实排版中窄条轮廓、
  综合色与视觉重量已接近目标；raw 仍以连续细密布纹覆盖中央大部分区域，缺少
  两三块明确的手绘宽面和柔软长褶，因而不能宣称通过“无程序化微纹”条款。
- 次要客观失败：bbox／tail 接合。自动技术检查 `5/9 pass`；布局公式
  `26/26 pass`，display-region `6/6 pass`、violations `0`。真实排版已覆盖
  closed、7／5／3 项、disabled、scroll `52`／`208`，且显示 candidate 本身；
  V3-B 纹章仍只是非权威本地占位。
- review：`attempt-03/review/QS-B1-V3-A.attempt-03.review.json`
  (`c5fddd08…d254`)；真实排版 `QS-B1-V3-A.attempt-03.real-layout.png`
  (`eab5bf34…9a73`)；display-region report
  `QS-B1-V3-A.attempt-03.display-region-report.json` (`98fa2f7e…0101`)；contact
  sheet `QS-B1-V3-A.attempt-03.contact-sheet.png` (`aaad3d58…99a6`)。
- 保留区域：当前窄长、正面、单一空白布身份；暖赭／烟褐综合色；柔和手裁
  两侧、轻微上缘弧度、克制短 tail、少量非周期污渍和无功能图案。主要解剖
  已足以满足同段 Image 3 edit 前置条件。
- 下一决策：`edit`。attempt 4 使用固定 Image 1／2＋紧邻 attempt 3 raw。
  只把可见宽度收窄约 `11.3%`、保持高度与中心，从 `202×974` 收敛到约
  `179×974` 的目标比例；表面改为完全无可辨织纹／线圈／颗粒的宽面手绘，
  增加两条不跨切点的长软褶，不移动既有综合色、污渍节奏或 tail 身份。
- 结论：`internal-rejected / repair-prepared / 3/5`；不得进入 V3-B、用户复审、
  P4、source、runtime 或 addon。

| `3/5` | `QS-B1 V3-A.r2` / `343457d` | regenerate；固定 Image 1／2 | `019fd10d-b73c-75b0-bd58-1fb980d773a6` / `ig_0058e081…54c5` | `attempt-03` / `737acc4b…4cac` | 美术仍有连续微纹；宽高比误差已降至 `12.77%` | 保留窄长轮廓与综合色；紧邻 Image 3 收窄约 `11.3%` 并重绘宽面 | `internal-rejected / repair-prepared` |

### V3-A attempt 4 执行与审查 — `2026-08-05`

- 执行前 commit：`856f8bf`；执行完整 `QS-B1 V3-A.r3`，按授权上传固定 SHA
  Image 1／2 与紧邻 attempt 3 raw 作为唯一 Image 3。child 完整回显正文，
  只进行一次 edit，无自审、重试、revised prompt 或第二次生图。
- fixed child／provider：session
  `019fd115-73d4-7c61-87bd-67e0ea030127`；result
  `ig_01f4cd3c011701cb016a72f737d7908191a6cf2779d8d2ec78`。provider 原图
  生成后由父流程复制同一字节到 attempt 路径；child read-only 导致目标路径
  placement 未执行，但图片与 provider result 均已存在，因此不记流程错误，
  实际调用累计 `4/5`。
- raw：`attempt-04/raw/QS-B1-V3-A.attempt-04.png`；`1254×1254 RGB`；
  SHA-256 `a204cc01654044a881c850d37c8683c1d32cb73cc9c954486cc46ee1c443d5fd`。
- 确定性检查：一个连通物件；归一化 raw bbox `[440,45,586,980]`、
  `146×935`、宽高比 `0.156150`，相对目标误差 `15.09%`。本次收窄过量；
  等比 fit 只有 `109×696`、可见 `[457,164,566,860]`，比目标宽度少 `19px`。
  runtime 可见 bbox 已覆盖完整 `32×174`，八个动态 cut band 均有布料；
  N=1／3／5／7 tail 接合重叠均为 `30px`，平均 RGB 跳变约
  `23.18 / 22.52 / 21.72 / 4.51`，明显优于 attempt 3。
- 第一失败门禁仍为 `4. 美术一致性`：虽然 runtime 缩小时两条长褶和综合色
  可读，raw 仍被同一种连续卷曲细纹覆盖，像规则织物样本而非香草时代手绘
  bitmap；不能以缩小后不明显抵消 source 级合同。次要客观失败为宽度过窄。
- 自动技术检查 `7/9 pass`；布局公式 `26/26 pass`；display-region
  `6/6 pass`、violations `0`。真实排版覆盖 closed、7／5／3 项、disabled、
  scroll `52`／`208`，显示 candidate 本身；V3-B 纹章仍为非权威本地占位。
- review：`attempt-04/review/QS-B1-V3-A.attempt-04.review.json`
  (`82a49308…b120`)；真实排版 `QS-B1-V3-A.attempt-04.real-layout.png`
  (`de56388c…db77`)；display-region report
  `QS-B1-V3-A.attempt-04.display-region-report.json` (`2bb6fa25…3f54`)；contact
  sheet `QS-B1-V3-A.attempt-04.contact-sheet.png` (`e5e98e2a…0e6b`)。
- 保留区域：单一、空白、连续、正面布条；暖赭／烟褐综合色；两条长软褶、
  非周期污渍、柔和不完全对称侧边、浅上缘和克制短 tail；完整高度、动态
  cut band 与 tail 连续性。这些仍满足同段紧邻 Image 3 edit 前置条件。
- 下一决策：最后一次 `edit`。保持 attempt 4 高度、纵向中心、综合色、褶皱
  大位置、污渍节奏、上缘与 tail，只把实际轮廓从 `146×935` 向两侧各扩约
  `13px`，收敛到约 `172×935`（宽度增加约 `17.8%`）；同时用不透明宽笔触
  完全覆盖细密纹路，而不是模糊或在其上叠褶皱。
- 结论：`internal-rejected / final-repair-prepared / 4/5`；不得进入 V3-B、
  用户复审、P4、source、runtime 或 addon。

| `4/5` | `QS-B1 V3-A.r3` / `856f8bf` | edit；固定 Image 1／2＋attempt 3 Image 3 | `019fd115-73d4-7c61-87bd-67e0ea030127` / `ig_01f4cd3c…c78` | `attempt-04` / `a204cc01…d5fd` | 连续细纹仍失败；轮廓收窄过量、误差 `15.09%` | 保留高度／折面／接缝；紧邻 Image 3 加宽 `17.8%` 并以宽笔触覆盖微纹 | `internal-rejected / final-repair-prepared` |

### 完整修复执行正文 — `QS-B1 V3-A.r4`

Edit Image 3 as the immediately previous candidate inside the frozen QS-B1
V3-A contract. Preserve its correct single connected blank-cloth identity,
full visible height, vertical center, front-facing direction, warm ochre and
smoked-brown palette, two broad long folds, sparse irregular stains, soft
nonmatching side edges, shallow top arc and short restrained frayed tail. Do
not add any motif, text, wax, book, button, state, second object or new
component. This is the final constrained silhouette-and-surface correction.

Image 3's normalized visible bbox is 146 x 935, aspect 0.156150. Keep its exact
935-pixel visible height and vertical center, but widen the actual cloth
silhouette symmetrically by about 17.8 percent, approximately thirteen pixels
outward on each side in normalized source coordinates, to approximately
172 x 935 and an aspect of 0.18396. Do not shorten the strip, move its top or
bottom, crop the tail, widen only a local section, or merely alter green margins.
The deterministic proportional fit must occupy exactly 128 x 696 with cloth
touching all four sides of that target visible box.

Completely repaint the interior surface with opaque broad bitmap brushwork.
Do not preserve, blur, soften, reduce, or overlay the existing continuous curled
thread field: cover every one of those fine lines. Use exactly three broad
hand-painted value masses and retain only two long soft asymmetrical folds,
with sparse irregular stains. No individual thread, curl, loop, pore, grain,
tiny fibre, woven cell, maze line, embossed squiggle or repeated micro-mark may
remain recognizable anywhere at source scale. The largest and most numerous
visible marks must be the three broad value masses, not texture. Cloth identity
must come only from broad folds, soft thickness, hand-cut edges, sparse stains
and the short tail.

Create exactly one isolated, connected, completely blank vertical guild oath-
linen substrate for a circa-2004 vanilla World of Warcraft quest-log interface.
This is the noninteractive physical cloth beneath an already existing wax seal
and beneath seven separately generated heraldic motif Buttons. Generate only
the cloth. It owns no function, no hit region, no text, no motif, and no UI
state. Do not generate the wax seal, any heraldry, any icon, any label, any
button, any book page, or a finished screen.

Runtime ownership is strict. A deterministic exporter will use the top of this
single continuous master as a variable-height visual-only prefix and will use
its short bottom tail as a separate visual-only cap. The visible prefix becomes
12 + 22 times the current number of visible actions at runtime; hidden actions
compact the length with no empty slot. Seven independent transparent motifs and
seven independent real Buttons are overlaid later. Therefore the cloth must not
contain any semantic mark, action-sized panel, state cue, hover cue, disabled
cue, danger cue, label, or invisible-looking ornament that implies a function.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit its circa-2004 vanilla WoW
   low-resolution 2D hand-painted bitmap language, substantial slightly
   irregular contours, broad readable light/midtone/shadow planes, muted warm
   ochre and smoked-brown expedition palette, short warm upper-left light,
   tangible material weight, and sparse concentrated wear. Ignore its complete
   open-book composition, parchment pages, leather plaques, compass, wax seal,
   ribbons, text, buttons, reward slots, brass corners, and full layout.
2. Image 2 is a secondary adjacency reference only. Inherit only the accepted
   quest journal's local color temperature, paint scale, edge softness, upper-
   left light direction, and restrained aging so the cloth belongs inside that
   exact runtime book. Ignore the complete book silhouette, paper, spine,
   stitches, page gutter, brass corners, transparent surroundings, and every
   directly reusable pixel.
3. Image 3 is the immediately previous V3-A raw candidate and the only edit
   base. Preserve only its correct object identity, full 935-pixel visible
   height and vertical center, warm muted palette, two broad long folds, sparse
   stain rhythm, soft nonmatching edges, shallow top arc and short tail. Correct
   its measured 0.156150 aspect by widening the actual cloth about 17.8 percent
   to approximately 172 x 935. Completely cover and repaint every continuous
   fine weave, grain, curled thread, maze line and repeated interior texture.
If the references conflict, Image 1 plus the Azeroth quest-ledger baseline wins.
Image 2 may only tune adjacency. Image 3 may preserve only the bounded correct
features above and cannot override target geometry or the art baseline. Do not
copy any complete object or layout from Image 1 or Image 2.

Canvas and occupancy are mandatory. Output an exact 1024 x 1024 RGB bitmap.
Every pixel outside the one cloth object must be uniform solid #00FF00, with no
gradient, checkerboard, texture, haze, vignette, glow, reflection, cast shadow,
color spill, floor, or loose pixel. Place the cloth unrotated in a straight-on
orthographic front view with no tilt or foreshortening. Its exact visible bbox
is [448,164,576,860], exactly 128 x 696 pixels, centered at x=512. Leave 448
pixels of green at both sides and 164 pixels at top and bottom. Do not enlarge
the cloth to fill the canvas. The visible width divided by visible height must
be exactly 0.1839; equivalently, the strip is 5.4375 times as tall as it is wide.
It must look conspicuously narrower and longer than a common banner or fabric
sample. It will be reduced exactly four-to-one into a 32 x 174 pixel canonical
runtime master, with visible cloth reaching the first and last runtime rows
rather than floating inside transparent padding.

Use this invisible construction anatomy without drawing any guide or boundary:
- root [448,164,576,212], 128 x 48 pixels;
- seven consecutive body-capacity zones, each 128 x 88 pixels, at y ranges
  212..300, 300..388, 388..476, 476..564, 564..652, 652..740, and 740..828;
- short tail [448,828,576,860], 128 x 32 pixels.
The top 24 source pixels of the root will be covered by the existing wax seal.
The seven body ranges are only deterministic crop coordinates, not seven
objects and not seven cards. The tail will be detached by the exporter and
placed after the currently visible prefix; keep its upper attachment calm and
materially compatible with every body cutoff. Give the tail only a shallow,
restrained hand-frayed end, never a long point, deep V, fishtail, banner, or
bookmark silhouette.

Physical construction: paint one heavy yet flexible strip of aged expedition-
guild oath linen. It must feel materially thicker and more substantial than a
flat paper strip, but it is cloth, not leather, parchment, metal, stone, or
photographic burlap. Keep one continuous vertical material flow and one
continuous broad lighting logic from root through body to tail, with no visible
thread pattern. The left and
right edges are hand cut with restrained nonmatching deviations: a few broad
one-to-three-pixel runtime-scale inward or outward changes, never a mirrored
wave, sawtooth, scallop, repeated notch, or torn net.

Texture and irregularity are the primary quality gate. Build the surface from
exactly three broad low-frequency value planes, exactly two long asymmetrical
soft folds, three to six irregular smoked stains of different size and spacing,
and only a few concentrated wear points near outer edges and the tail. Let one
fold fade out before another begins. Keep defect positions nonperiodic and
asymmetric. Left and right wear must not mirror. No stain, fibre knot, edge nick,
fold, highlight, or shadow may repeat at the 88-source-pixel / 22-runtime-pixel
action rhythm.

At source scale, use large quiet painted cloth planes without any explicit
fibre group. Do not draw individual thread curls, loops, tiny worms, woven cells
or a continuous photographic burlap field anywhere on the strip. The largest
visible changes must be the broad value planes, soft folds and irregular stains,
never micro-grain. The entire central surface must read as calm opaque bitmap
paint at a glance; reserve material wear for a few soft outer-edge and tail
changes, not interior linework.

Protect every possible dynamic cutoff. Within eight source pixels above and
below y=212, 300, 388, 476, 564, 652, 740, and 828, draw no strong horizontal
crease, tear, dark rule, bright line, stain edge, or silhouette step that would
expose the runtime crop. These quiet cut bands must still share the surrounding
cloth texture and must not read as pale blank stripes. The tail's top eight
source pixels use the same restrained average ochre-brown body value so the
moving butt joint remains quiet without creating a new border.

Material palette: smoked warm ochre, muted old brown, deep umber lower-right
edge, and one short restrained warm upper-left response. Highlights stay warm
and dull, never ivory-white, orange-gold, metallic, or glossy. Shadows remain
painted broad shapes, not ambient-occlusion grooves. Do not show thread or fibre
linework anywhere. Do not cover the surface in uniform
crosshatch, tiny weave cells, pores, repeated grain, sharp realistic threads,
embossing, or procedural noise.

Style lock: the result must read as an original small bitmap sprite painted for
a 2004-era vanilla WoW interface: warm, heavy, handmade, slightly imperfect,
magical without glow, and fully subordinate to the accepted quest book and wax
seal. It must not look vector-clean, photorealistic, uniformly distressed,
precision-cut, modern, minimalist, Diablo-3-like, Skyrim-overlay-like, Warhammer,
mobile-toolbar-like, or like a decorative wallpaper strip.

Strict exclusions: no motif, ink mark, emblem, rune, compass, quill, contract,
map line, text, letter, number, label, Tooltip, button, hit area, icon cell,
horizontal divider, card boundary, stitched cross seam, metal separator, rivet,
state copy, selection, glow, glass, translucent black, neon, gold frame, wax,
seal, book, page, cover, bookmark, leather strap, popup, scenery, cast shadow,
detached decoration, repeated 22-pixel defect, full-length straight highlight,
mirror symmetry, crop, rotation, perspective, or second object.

Before returning, verify in order: exactly one connected blank cloth and no
other object; exact 1024 x 1024 canvas and uniform #00FF00 exterior; exact
[448,164,576,860] bbox; correct root / seven invisible capacity ranges / short
tail proportions; no visible internal segmentation; no motif, text, function,
state, wax, book, or icon; broad low-frequency asymmetrical folds and stains;
no periodic weave or repeated defect; calm but textured dynamic cut bands;
hand-cut edges that are irregular but not noisy; the cloth remains substantial
and natural at 32 x 174 and at every 12 + N*22 visible prefix length. Reject the
result if the silhouette is not visibly 5.4375 times as tall as it is wide, if
any top or bottom transparent padding remains inside the target bbox, or if any
fine uniform weave, curled fibre field or procedural grain dominates the broad
painted surface.

### V3-A attempt 5 执行与终止审查 — `2026-08-05`

- 执行前 commit：`7e1428a`；执行完整 `QS-B1 V3-A.r4`，按授权上传固定 SHA
  Image 1／2 与紧邻 attempt 4 raw 作为唯一 Image 3。child 完整回显正文，
  只进行一次 edit，无自审、重试、revised prompt 或第二次生图。
- fixed child／provider：session
  `019fd11d-158c-7f92-b4d3-0a1ed346075a`；provider 文件／result 证据
  `ig_07201257e617a935016a72f930f6948191b289b38e451f6673`。provider 原图由
  父流程复制同一字节到 attempt 路径；child read-only 未执行目标路径
  placement，但生成证据完整，不记流程错误，实际调用累计 `5/5`。
- raw：`attempt-05/raw/QS-B1-V3-A.attempt-05.png`；`1254×1254 RGB`；
  SHA-256 `db4d8d1fc8995a127f36869641b9fd6c52eac95895fceb921b740551d9bd5e07`。
- 确定性检查：一个连通物件；归一化 raw bbox `[434,44,589,979]`、
  `155×935`、宽高比 `0.165775`，相对目标误差 `9.86%`。宽度比 attempt 4
  增加 `9px`，但仍未达到约 `172px`；等比 fit 为 `115×696`、可见
  `[454,164,569,860]`，比目标宽度少 `13px`。runtime 可见 bbox 覆盖完整
  `32×174`，八个 cut band 均有布料；N=1／3／5／7 tail 接合重叠为
  `28 / 28 / 30 / 30px`，平均 RGB 跳变约
  `23.50 / 18.35 / 21.64 / 2.77`。
- 第一失败门禁仍为 `4. 美术一致性`：raw 全幅仍覆盖连续卷曲细纹／迷宫状
  微纹，且比 attempt 4 更清晰；这直接违反 source 级“宽面手绘、无规则
  织纹／程序化微纹”合同。真实排版缩小后褶皱、综合色和视觉重量可读，但
  缩小后的弱化不能替 source 合同豁免。次要客观失败为实际宽度仍偏窄。
- 自动技术检查 `7/9 pass`；布局公式 `26/26 pass`；display-region
  `6/6 pass`、violations `0`。真实排版覆盖 closed、7／5／3 项、disabled、
  scroll `52`／`208`，显示 candidate 本身；V3-B 纹章仍是非权威本地占位。
- review：`attempt-05/review/QS-B1-V3-A.attempt-05.review.json`
  (`325da6a2…f57f`)；真实排版 `QS-B1-V3-A.attempt-05.real-layout.png`
  (`aa18238f…40cc`)；display-region report
  `QS-B1-V3-A.attempt-05.display-region-report.json` (`e997cd11…c66f`)；contact
  sheet `QS-B1-V3-A.attempt-05.contact-sheet.png` (`b258c48c…0546`)。
- 终止决策：V3-A 五次实际 ImageGen 已耗尽且仍未完整通过。不得继续修复，
  不得把 attempt 4／5 的 runtime 观感自行解释为通过，不得执行 V3-B，也不得
  进入用户候选接受、P4、source、runtime、atlas、addon 或旧按钮隐藏。
- 结论：`internal-rejected / repair-budget-exhausted / 5/5 /
  user-review-required`。下一步必须等待用户对失败证据与新策略作出明确决定。

| `5/5` | `QS-B1 V3-A.r4` / `7e1428a` | edit；固定 Image 1／2＋attempt 4 Image 3 | `019fd11d-158c-7f92-b4d3-0a1ed346075a` / `ig_07201257…6673` | `attempt-05` / `db4d8d1f…5e07` | 连续卷曲微纹仍失败；宽高比误差 `9.86%` | 额度耗尽，停止；V3-B 保持门禁 | `internal-rejected / repair-budget-exhausted / user-review-required` |

### V3-A 自主修复与候选审查边界

- attempt 1 固定上传 V3-A Image 1／2。attempt 2–5 继续上传同路径、同顺序、
  同 SHA 的 Image 1／2；只有紧邻候选仍是单一空白连续亚麻布、综合色和主要
  解剖正确，失败仅限于 bbox、综合色、纹理频率、边缘克制度或局部禁项时，
  才可将该候选作为同段唯一 Image 3 edit input。否则 regenerate。
- 允许自主修复：bbox／居中／纯绿、低频褶皱与污渍分布、边缘不对称、磨损
  密度、综合色／对比、tail 克制度，以及删除误生纹章、文字、横格、亮边、
  规则织纹或现代装饰。不得增加其他参考或改变 V12 几何／所有权。
- 每个候选先审查单物件、空白语义、材料与非周期性，再做确定性色键和等比
  bbox-fit；随后必须用候选本身装入真实 Quest Log，展示 closed、7／5／3 项、
  N=1／3／5／7 tail 接合、scroll 52 和 scroll 208。实际展示区域与命中合同
  仍须全部通过，稀疏接触表不能代替真实排版。
- V2 attempt 1–4、V1 attempt 1–5、V10／V11／V12 模拟图、QS-A1 漆章和任何
  review 派生图都不得上传或成为 edit input。
- 最多 `5` 次实际 ImageGen generation／edit。没有生成证据的流程错误不占
  额度；候选完整通过即停止，第五次仍失败则停止等待用户审核。

## QS-B1 V3-B — 七个独立透明印墨纹章 production preparation

### 元数据、固定输入与产物合同

- 版本：`QS-B1 V3-B`。
- 状态：`prompt-authorized / 0/5 / gated-by-v3a-internal-pass`。
- 固定执行器：`imagegen-0-143-0 / @openai/codex@0.143.0`。
- Image 1（最高视觉权威）：
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`，SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
- Image 2（受限小尺寸墨记参考）：
  `assets/source/quests/ql-b1/QuestLogDirectoryMarks_Master_v1.png`，SHA-256
  `719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44`。
- planned independent sources：
  `QuestLogSealMenuMotif_Share_v3.png`、`_Detail_v3.png`、`_Show_v3.png`、
  `_Hide_v3.png`、`_Clean_v3.png`、`_Reset_v3.png`、`_Abandon_v3.png`，均位于
  `assets/source/quests/qs-b1/`；七个文件必须有独立 SHA、logical ID 与
  acceptance 记录。
- planned source manifest：
  `assets/source/quests/qs-b1/QS-B1-V3B_SourceManifest_v1.json`。
- planned runtime atlas：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogSealMenuMotifStatesV3.tga`。

provider 输出是一张固定七格隔离工作表，目的只是用一次循环保持同批印墨语言。
P4 不保留它作为单一功能资产：exporter 按固定 cell 提取七格，分别色键、清零
透明 RGB、等比 fit，再写成七张独立 RGBA source。不得把一格的像素、Alpha、
状态或 UV 合并给另一格；任意功能隐藏只移除自己的 Button／UV。
raw 只有在方形画布上才可进入固定 cell 审查；若 provider 返回非 `1024²` 的
方形图，只允许先对整张方形画布做一次同轴等比归一化到 `1024²`。非方形 raw
直接退回生成循环，不允许分别拉伸 x／y 来套进 cell。

runtime atlas 固定 `256×128 RGBA TGA`：列 0..6 依次为 share、detail、show、
hide、clean、reset、abandon，列 7 保持透明；每列宽 `32px`。四态使用
`32px` 行节距，行序 normal／hover／pressed／disabled；每格真实可见区为
`[column*32,row*32+5,32,22]`。hover 只轻微暖亮；pressed 只压暗并由 Button
整体右下移 `1px`；disabled 只退灰降对比。四态必须保持同一 Alpha／轮廓，
不得重新生成。

### 固定工作表坐标

画布 `1024×1024`，八个不可见 cell 为：

| cell | 逻辑纹章 | cell `xyxy` | 最大安全盒 `xyxy` | 目标视觉中心 |
|---:|---|---|---|---|
| 1 | share／双羽笔结约 | `[32,160,256,384]` | `[64,208,224,336]` | `(144,264)` |
| 2 | detail／折页 | `[272,160,496,384]` | `[304,208,464,336]` | `(392,272)` |
| 3 | show／开放罗盘 | `[512,160,736,384]` | `[544,208,704,336]` | `(616,272)` |
| 4 | hide／遮蔽罗盘 | `[752,160,976,384]` | `[784,208,944,336]` | `(864,280)` |
| 5 | clean／清扫地图线 | `[32,608,256,832]` | `[64,656,224,784]` | `(152,712)` |
| 6 | reset／回环路线结 | `[272,608,496,832]` | `[304,656,464,784]` | `(376,728)` |
| 7 | abandon／断裂契约线 | `[512,608,736,832]` | `[544,656,704,784]` | `(624,720)` |
| 8 | 必须为空 | `[752,608,976,832]` | — | — |

每格外与每个纹章之间均为同一纯绿背景；cell／safe box 只是坐标合同，不得画
框、分隔线、编号或底板。建议 source 可见尺寸分别约为 `144×96`、`112×112`、
`112×112`、`128×112`、`144×80`、`136×96`、`128×72px`，全部只是等比
上限；差异用于避免七枚同尺寸／同中心的现代图标柱。

### 完整性预检

- 复杂度：`seven isolated normal motifs -> seven independent RGBA sources ->
  deterministic four-state atlas`。
- 结论：`pass`。

| 门禁 | 正文证据 | 结论 |
|---|---|---|
| 数量、身份与独立所有权 | exactly seven logical isolated motifs；固定 cell、语义、顺序；P4 七张 source | pass |
| 参考权威与过滤 | Image 1 裁决年代／综合色；Image 2 只裁决小尺寸墨迹笔触并忽略既有箭头／勾形 | pass |
| Canvas、cell、安全盒和视觉偏移 | `1024²`、4×2 隔离布局、cell 8 空、七个不同中心／尺寸 | pass |
| 纹章解剖、综合色与可读性 | 七个明确 Azeroth 公会文书语义；1–6 深墨、7 暗酒红 | pass |
| 不完全着墨但非噪声 | 克制缺墨、轻微渗化、非恒定线宽；禁止散点、断裂身份和矢量精确度 | pass |
| 动态内容／背景／状态排除 | 无布底、蜡、文字、卡片、状态副本；状态由 exporter 派生 | pass |
| 独立导出、真实排版和实际显示区 | 固定 cell 提取为七文件；必须叠到 V3-A 候选并做真实 UI／滚动审查 | pass |

未知但执行必需的值：`无`。

### 最终执行正文 — `QS-B1 V3-B`

Create one exact seven-cell source worksheet containing exactly seven isolated
normal-state heraldic ink motifs for a circa-2004 vanilla World of Warcraft
quest-log interface. These are seven independent transparent runtime resources,
temporarily arranged on one chroma-key worksheet only for consistent generation.
They will be split into seven separately tracked RGBA source files, seven
independent atlas UVs, and seven independent real Button objects. Generate no
shared cloth, no background ribbon, no wax seal, no button plates, no text, and
no interaction-state copies.

The seven motifs and their fixed meanings are:
1. Share Quest: two short paired quills joined by one compact binding knot;
2. Detail Toggle: one compact folded guild-ledger leaf;
3. Show Location: one open, simple four-point expedition-guild compass;
4. Hide Location: the related compass crossed by one short quiet diagonal veil;
5. Clean Marks: three broad swept cartographic trail lines, visibly clearing;
6. Reset Marks: one winding route returning into one compact route knot;
7. Abandon Quest: one snapped contract cord with a clear small central break.
These are Azeroth expedition-guild warrant marks, not modern UI icons. Do not
add letters, words, numerals, runes, faction logos, skulls, aquilas, double-
headed eagles, Imperial insignia, science-fiction hardware, or any symbol copied
from another franchise.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit its circa-2004 vanilla WoW
   low-resolution 2D hand-painted bitmap language, broad readable shapes,
   substantial slightly irregular contours, muted warm expedition palette,
   restrained upper-left light logic, sparse wear, and nonmodern material
   weight. Ignore its complete book, pages, leather plaques, compass object,
   wax seal, ribbons, text, buttons, reward slots, brass, and full composition.
2. Image 2 is a secondary small-scale ink-mark reference only. Inherit only its
   accepted runtime-size stroke economy, softened painted edge scale, broad
   dark-ink massing, and ability to remain legible when reduced. Ignore its
   existing arrow, circle, check-mark silhouettes, its 2x2 source grid, exact
   positions, transparency, and all directly reusable pixels. Do not copy or
   rotate any existing directory mark into the new motifs.
If the references conflict, Image 1 plus the Azeroth quest-ledger baseline wins.
Image 2 may only tune small-scale stroke handling.

Canvas contract: output an exact 1024 x 1024 RGB bitmap. Every pixel outside
the seven ink motifs must be the same uniform solid #00FF00, with no gradient,
texture, paper, cloth, haze, vignette, checkerboard, glow, contact shadow, color
spill, cell background, or loose speck. The worksheet has an invisible 4 by 2
layout. Draw no guides, boxes, dividers, labels, numbers, captions, or frames.

Place exactly one motif in each of the following first seven invisible cells;
the eighth cell must remain completely empty green:
- cell 1 [32,160,256,384], share motif, all pixels inside safe box
  [64,208,224,336], optical center (144,264), approximate maximum 144 x 96;
- cell 2 [272,160,496,384], detail motif, safe box [304,208,464,336],
  optical center (392,272), approximate maximum 112 x 112;
- cell 3 [512,160,736,384], show motif, safe box [544,208,704,336],
  optical center (616,272), approximate maximum 112 x 112;
- cell 4 [752,160,976,384], hide motif, safe box [784,208,944,336],
  optical center (864,280), approximate maximum 128 x 112;
- cell 5 [32,608,256,832], clean motif, safe box [64,656,224,784],
  optical center (152,712), approximate maximum 144 x 80;
- cell 6 [272,608,496,832], reset motif, safe box [304,656,464,784],
  optical center (376,728), approximate maximum 136 x 96;
- cell 7 [512,608,736,832], abandon motif, safe box [544,656,704,784],
  optical center (624,720), approximate maximum 128 x 72;
- cell 8 [752,608,976,832] contains nothing at all.
Every antialias pixel, pigment bleed, gap edge, feather tip, cord end, trail end,
compass point, veil stroke and route loop must remain inside its own safe box.
No motif may touch or imply another cell.

Paint treatment: each motif is a direct imperfect guild-ink transfer, not an
embossed badge, metal emblem, carved stamp tool, or icon inside a tile. Use a
few broad hand-painted strokes with subtly softened pigment edges. Vary line
width within each mark by a restrained amount. Give each motif one to three
small controlled missing-ink interruptions and one or two slightly heavier
pigment pools at plausible stroke turns. Missing ink may roughen an edge but
must never sever the defining silhouette or make the function ambiguous.
Pigment bleed stays within two to four source pixels and does not form a glow.

Motifs 1 through 6 use near-black smoked guild ink with a deep umber-brown bias,
not pure digital black. Motif 7 alone uses restrained low-saturation dark-wine
ink; it must not become bright red, glowing, bloody, or a full danger panel.
There is no light source on the ink itself, no bevel, rim light, metallic shine,
drop shadow, outer glow, or white highlight.

Deliberate irregularity: honor the seven different optical centers and different
maximum sizes above. Do not mechanically center all seven at identical x/y,
scale them to the same box, use the same stroke pressure, or align every upper
and lower edge into a perfect icon column. The variation is controlled and
handmade, not random: no dust field, splatter cloud, disconnected filler dots,
unreadable scribble, or excessive distress. Each identity must remain complete
when proportionally reduced into its own 32 x 22 runtime Button, with a target
visible size of roughly 14..18 pixels wide and 9..14 pixels high.

Style lock: these must look like seven original low-resolution bitmap marks
painted for a 2004-era vanilla WoW guild ledger: warm, substantial, economical,
slightly imperfect, magical without glow, and materially compatible with the
accepted quest book and blank oath linen. They must not look vector-clean,
font-glyph-like, photorealistic, procedural, corporate, uniformly stamped,
mobile-toolbar-like, Diablo-3-like, Skyrim-minimalist, Warhammer, or generic
modern fantasy icons.

Strict exclusions: no cloth, ribbon, parchment, leather, book, page, wax, seal,
button face, card, circle badge, square tile, metallic frame, gold outline,
rivet, label, letter, number, Tooltip, state name, hover, pressed, disabled,
selected, separate danger background, cast shadow, contact shadow, glow, glass,
translucent black, neon, gemstone, skull, spike, altar, sci-fi hardware, visible
cell guide, eighth motif, repeated copy, mirrored copy, or object outside its
declared safe box.

Before returning, verify in order: exact 1024 x 1024 canvas; uniform #00FF00
outside the motifs; exactly seven logical motifs, one in each of cells 1..7,
and a completely empty eighth cell; fixed meaning and order; every visible and
antialias pixel inside its own safe box; no cloth,
wax, text, plate, state copy, guide, or extra object; motifs 1..6 use deep smoked
ink and only motif 7 uses dark wine; seven sizes, centers and stroke rhythms are
deliberately nonidentical; controlled missing ink and bleed do not damage
semantic readability; all seven remain recognizable in separate 32 x 22 cells.

### V3-B 自主修复与候选审查边界

- attempt 1 固定上传 V3-B Image 1／2。attempt 2–5 继续上传同顺序、同 SHA 的
  Image 1／2；只有紧邻工作表保持七个 cell 各一枚逻辑纹章、固定语义／cell 和总体
  印墨语言，失败仅在个别 safe box、笔触、综合色、辨识或禁项时，才可将其
  作为同段唯一 Image 3 edit input。对象数、语义或多格结构失真则 regenerate。
- 允许自主修复：纯绿、cell 占用、安全盒、个别纹章比例／视觉中心、线宽、
  缺墨／渗化克制度、小尺寸辨识、第四色彩，以及删除误生底板、文字、蜡、
  第八图案、散点或现代图标细节。不得改变七个逻辑 ID／顺序或引用新图片。
- 候选先按固定 cell 生成七张临时透明文件并检查对象数／safe box，再缩到各自
  真实 `32×22px` Button。V3-A 若已通过，则必须把这七张候选叠到 V3-A 的
  真实候选布底；否则不得用 V12 几何像素冒充最终综合色。预演覆盖 7／5／3
  visible、一个 disabled、scroll 52 和 scroll 208，并使用真实 Quest Log
  字体、正文、四奖励槽、QS-A1 火漆和 runtime 层序。
- V3-A 候选只用于本地排版，不上传给 V3-B ImageGen。V1／V2 候选、V10／V11／
  V12 模拟、QS-A1 漆章、QL-B1 runtime atlas 和任何 review 派生图均不得作为
  额外图片输入；V3-B 的 Image 2 只能是固定 QL-B1 accepted source。
- 最多 `5` 次实际 ImageGen generation／edit。没有生成证据的流程错误不占
  额度；候选完整通过即停止，第五次仍失败则停止等待用户审核。

## V3 联合授权边界与当前门禁

- V3-A 与 V3-B 是两个独立执行体，各自最多 `5` 次实际 ImageGen 调用，最坏
  合计 `10` 次；某段通过即停止该段，不为耗满额度继续抽卡。
- 每段只允许各自固定 Image 1／2，以及同段紧邻前次候选在冻结边界内作为
  Image 3。禁止跨段候选作为 ImageGen 输入，禁止上传模拟图、旧失败稿、
  normalized review、真实排版图、runtime atlas 或 addon 截图。
- 合同内确定性后处理只包括：边缘连通色键、透明 RGB 清零、方形画布的同轴
  等比 `1024²` 归一化、等比 bbox-fit、V3-B 固定 cell 拆分、V3-A prefix／
  tail crop、四态派生、atlas 打包、metrics、
  实际展示区域检查和“真实排版＋新 UI”预演。它们不得修复语义、材料、构图、
  图案或不工整程度的失败。
- 当前 ImageGen：V3-A `5/5`；V3-B `0/5`；流程错误 `0`。attempt 5 已上传
  固定 Image 1／2 与同段紧邻 attempt 4 raw；动态切点、tail 接合与真实展示
  几何通过，但连续微纹和实际宽度仍未满足合同，V3-A 以
  `internal-rejected / repair-budget-exhausted` 终止。
- 当前门禁：联合生产授权要求 V3-A 内部通过后才进入 V3-B；该条件未成立，
  因此 V3-B 不得执行。当前等待用户审查失败证据并决定是否另立新版本／新
  策略；不创建 source／manifest／exporter／runtime，不修改 addon，也不隐藏
  旧按钮。

## V3-A 用户否决与 V4-A 暗色非规则布底预演 — `2026-08-05`

### 否决结论与边界

- 用户对 V3-A 五次失败证据的明确结论：`条带切口太整齐了，而且颜色太亮了，
  显得很轻浮`。V3-A 因而补充标记为
  `candidate-rejected / repair-budget-exhausted / user-rejected / 5/5`；
  attempt 1–5 全部只保留为负面证据，不得成为 source、runtime、V4
  reference 或 edit input。
- V12 已确认的真实对象与交互拓扑不撤销：ScrollChild 所有权、页上火漆、
  一张动态空白布底、七张独立透明纹章、七个独立 Button、hidden 收拢、
  disabled 留位、部分滚动禁用 hitbox、完全滚出、奖励前 `32px` 留白和
  fail-open 均保持。
- V3-B 仍为 `0/5` 且不得执行。V3 联合授权不自动授权新的 V4-A 可见方向；
  V4-A 模拟确认后仍须形成并展示新的完整生产正文，再获得独立五次实际
  ImageGen 授权。

### 生成前模拟合同

- 组件／版本：`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.MAX / QS-B1 V4-A /`
  `QUEST-LOG-SEAL-SUBSTRATE-SIM-V13`。
- 子状态：`simulation-reviewed / P2 / awaiting-user-confirmation`；操作
  `simulate`；ImageGen `0/0`；上传 `0`；本地渲染错误 `0`；production
  ImageGen `0/0` 且尚无新预算。
- 最高视觉权威：
  `assets/locked/quests/任务详情面板_视觉基准_v1.png`
  (`03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`)；
  只读继承香草时代手绘年代感、大块明暗、厚重材料与克制磨损。
- 当前 accepted/runtime 邻接：
  `assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`
  (`91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`)
  与 `addon/AzerothExpeditionUI/Media/Quests/QuestToolWaxSealStatesV1.tga`
  (`f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902`)；
  两者只作为真实排版邻接 UI，不被复制为新 source。
- 真实 Frame：`676×464px`；detail viewport `[366,64,246,324]`；火漆视觉
  `[210,4,32,32]`；布根 `[210,30,32,12]`；动作从内容 y=`42` 起，每项
  `32×22px`；tail `32×8px`；奖励首行 y=`236`。覆盖 closed、7／5／3 项、
  disabled、scroll `52` 与 scroll `208` 六个场景，并保留 18 行任务与四个
  `108×41px` 奖励槽。
- 动态装配：本地模拟先构造唯一 `32×174px` 最大母版；open 时只取
  `12 + visible_count × 22px` 前缀，再接同一母版底部 `8px` tail；closed
  只取前 `12px`。不得按动作数重新绘制不同背景，也不得产生功能所有权或
  `22px` 周期缺陷。

### V4-A 可见方向

- 主体从 V3-A 的暖亮赭布压到低饱和烟熏深旧棕：平面角色为主体
  `[70,56,43]`、次亮 `[93,73,52]`、阴影 `[38,31,26]`、污渍
  `[45,34,28]`。禁止金黄、橙亮、象牙白、全长亮边或庆典式鲜亮色。
- 左右侧边只由少量宽幅、互不镜像的偏移构成；控制点避开 `22px` 动作切线，
  不使用机器直边、等距波浪、锯齿、流苏或周期缺口。
- 尾端只有两处不等宽、粗钝的上收缺口；不使用规则锯齿、同长排穗、深 V、
  对称鱼尾或现代 ribbon 切口。
- 上根在火漆下形成轻微不对称压皱；中央亮面只出现两个短而宽的暗赭块，
  不形成贯穿全高的明亮竖带；磨损只落在少量边缘／尾端位置，中央保持哑光、
  安静、厚重。
- 本地纹章仍是 V12 的简单几何占位，只用于确认布底与七个独立 Button 的
  实际层序、对比和动态长度；其最终形态、笔触、Alpha 与四态不在 V13 确认范围。

### 模拟执行、内审与证据

- tracked renderer：
  `tools/render_quest_log_seal_layered_actions_simulation_v2.py`，SHA-256
  `4fc1df9833b0a60f54e6ceccf03646e7002c8bc0fcf647eafe117f10e4fb1c4b`。
- tracked specification：
  `tools/specs/quest_log_seal_substrate_simulation_v13.json`，SHA-256
  `dd5d13cf7b23f18fa9525377f6b03422370b1bbd8274c02174b4692b7e377969`。
- tracked display-region contract：
  `tools/specs/quest_log_seal_actions_simulation_v13_display_region.json`，
  SHA-256
  `9fd5070eda48cb9f1e98b3b745173de7bdbb034093d3aa7f60a5d83879ee364d`。
- macOS 命令：
  `conda run -n py312 python tools/render_quest_log_seal_layered_actions_simulation_v2.py tools/specs/quest_log_seal_substrate_simulation_v13.json --repo-root .`。
  解释器 `/Users/yuanshiyao/miniconda3/envs/py312/bin/python`，Python
  `3.12.12`。
- 真实排版 board：
  `generated/quests/QUEST-SEALS/simulation/QUEST-LOG-SEAL-SUBSTRATE-SIM-V13/quest_log_seal_substrate_board_v13.png`，
  SHA-256 `f38ae81031f5ff50f3d0fcaa20b94a2316f39df1317f2a1d87c362a86ee735d1`。
- 轮廓／综合色 zoom：同目录 `quest_log_seal_substrate_zoom_v13.png`，SHA-256
  `78aa2d8ce58271b6c43bfac9c5ebe516d3c7009162a2cd3cafd7f665208c4ba8`。
- simulation report：同目录 `quest_log_seal_substrate_report_v13.json`，
  SHA-256 `b6680f3e49cf00c42a1aa659a95237bd7a2df22a661f6dfb5f534a17d46c7138`；
  `40/40 pass / displayable`。
- display-region report：同目录 `display-region-report-v13.json`，SHA-256
  `66b8396546c3383c65c2a6eb2506b410fddbd58002c9ad742266a0813a8e4cfa`；
  `6/6 pass`、violations `0`。
- 内部首轮先发现“大块高对比椭圆污渍可能误读成独立按钮底板、亮面仍偏赭亮”，
  随即在同一 0-ImageGen 模拟版本内改为更暗、更低对比的跨段宽面阴影后重渲染；
  最终 V13 不含 action-sized stain plate。该修正没有调用 provider，也没有
  产生 production attempt。
- 内部结论：`displayable`。可据此确认真实比例、页面位置、暗色重量、侧边／
  尾端轮廓、火漆压根关系、动态长度、对象密度、层序与滚动观感；不能据此
  接受最终纤维、手绘微纹、边缘 Alpha、切片接缝、纹章笔触、四态或客户端混合。
- 禁止用途：board／zoom／report 全部位于 ignored `generated/`；不得进入
  `assets/source/`、addon、裁切／切片、runtime，也不得作为未来 ImageGen
  reference 或 edit input。当前可由 tracked renderer／spec 确定性重建，
  不创建跨设备 `handoff/`。
- 用户方向结论：`accepted / simulation-confirmed / P2`。用户于
  `2026-08-05` 回复“接受, 用这一套试试效果”，确认 V13 可见方向中的低饱和
  烟熏深旧棕、少量非周期宽幅侧边、两处不等宽粗钝尾缺口、断续宽面暗光、
  哑光安静中央和既有动态长度。确认不接受模拟像素，也不覆盖最终纤维、边缘
  Alpha、切片接缝或客户端混合门禁。
- 下一门禁改为展示下方 `QS-B1 V4-A` 完整 production 正文、固定输入、确定性
  后处理和最多五次实际 ImageGen 调用边界，并取得独立明确授权。授权前不得
  调用 ImageGen、执行 V3-B、创建 source／manifest／exporter、导出 runtime、
  修改 addon 或隐藏旧按钮。

## QS-B1 V4-A 暗色非规则动态空白布底 — production preparation

### 状态与唯一范围

- 组件：`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.MAX`；版本：`QS-B1 V4-A`。
- 状态：`prompt-prepared / awaiting-production-authorization / P2`；计划操作：
  `generate`；固定执行器：`imagegen-0-143-0`，其内部必须固定使用
  `@openai/codex@0.143.0` 的 imagegen 路径，禁止替换为原生或其他版本生图能力。
- 当前计数：production ImageGen `0/5`；流程错误 `0`；上传 `0`。V13 本地模拟
  另记 `0/0`，不占正式额度。
- 只生产一条无鼠标、无功能语义、无纹章的连续最大长度 normal 布底母版。
  七张独立纹章、七个 Button、状态派生、Tooltip、功能代理和交互不属于本段。
- V12 已确认的 ScrollChild 拓扑、visible-order 收拢、disabled 留位、滚动裁切、
  奖励安全距离与原子 fail-open 全部冻结；本段不得修改 Lua、addon 或 provider。

### 固定输入与权威顺序

1. `Image 1`：`assets/locked/quests/任务详情面板_视觉基准_v1.png`，SHA-256
   `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
   它是最高权威，只继承 2004 年前后香草魔兽二维手绘年代感、大块明暗、材料
   重量、克制磨损、低分辨率可读性与左上暖光。
2. `Image 2`：`assets/source/quests/ql-a1/QuestLogBookShell_Master_v1.png`，
   SHA-256
   `91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5`。
   它只作相邻已接受 UI 的综合色、画笔尺度、边缘软硬、左上光向与磨损密度参考。
3. attempt 1 不上传 `Image 3`。attempt 2–5 只有在下述冻结修复边界内，才允许
   同一循环紧邻前次 raw output 作为唯一 `Image 3` edit input。

若两张参考冲突，以 Image 1 和 Quest 主模块／全局基线为准。不得上传 V13
模拟图、V3-A 五张失败稿、QS-A1 漆章、纹章占位、runtime atlas、review 图、
真实排版 board 或 addon 截图。Image 1／2 中的书、页、书脊、黄铜、火漆、
按钮、文字和完整构图均不是可复制对象。

### 组件与显示区域合同

- 输出画布：精确 `1024×1024 RGB`；物件外每个像素必须为统一纯
  `#00FF00`，无渐变、纹理、雾、暗角、接触影、溢色或游离碎屑。
- 唯一物件必须保持竖直、正交、未旋转、完整可见，精确占据 bbox
  `[448,164,576,860]`，即 `128×696px`。不得裁切、透视、镜像或横向拉伸。
- source 内部逻辑区仅用于后续裁切，不得画出分隔：root
  `[448,164,576,212]`，七段潜在容量依次为 `128×88px`，y 边界
  `212／300／388／476／564／652／740／828`，tail
  `[448,828,576,860]`。
- runtime 等比缩为 `32×174px`。收起态只显示 root `32×12px`；展开态取
  `12 + visible_count × 22px` 的连续前缀，再紧接同一母版底部 `32×8px`
  tail。任何潜在切点前后 `±8 source px` 都必须安静连续。
- 真实 Quest Log 保持 `676×464px`；detail viewport `[366,64,246,324]`；
  content seal `[210,4,32,32]`；布根 `[210,30,32,12]`；动作槽
  `32×22px`；奖励从内容 y=`236` 开始。七项全显时 tail 结束于 y=`204`，
  与奖励保持 `32px` 空隙。

### 最终完整 production prompt（执行时逐字使用）

```text
Create one production-ready raster source asset for a Turtle WoW 1.18.1
Interface 11200 quest-log overhaul. This is only the continuous blank cloth
substrate hanging beneath an existing wax seal inside the right-page scrolling
content. It owns no function and receives no mouse input. Do not draw any wax
seal, icon, motif, text, button, state, book, page, frame, popup, or menu panel.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit only its circa-2004 vanilla
   World of Warcraft low-resolution 2D hand-painted bitmap language, broad
   readable value planes, substantial material weight, muted expedition color,
   restrained upper-left light, sparse wear, and deliberately nonmodern finish.
   Ignore its complete book, pages, leather, brass, wax seal, ribbons, compass,
   buttons, reward slots, text, and full composition.
2. Image 2 is a secondary accepted-adjacency reference. Inherit only its local
   dark-walnut color temperature, coarse paint scale, softened edge handling,
   upper-left light direction, and restrained wear density. Ignore and do not
   reproduce its book, pages, spine, brass, transparency, silhouette, or pixels.
If the references conflict, Image 1 and the Azeroth quest-ledger baseline win.
Neither reference authorizes copying an object or composition.

Canvas and object contract: output an exact 1024 x 1024 RGB bitmap. Draw exactly
one connected, vertical, orthographic, unrotated blank cloth object. Its exact
visible bounding box is [448,164,576,860], width 128 and height 696 pixels. The
entire object must be visible. Every pixel outside it is the same uniform solid
#00FF00 with no gradient, paper, cloth, haze, vignette, checkerboard, glow,
contact shadow, color spill, loose fiber, or separate fragment. Do not crop,
mirror, tilt, bend it in perspective, or stretch one axis independently.

The object is a dark, low-saturation, smoke-aged expedition-guild oath linen:
charcoal brown, dark walnut, and deep umber. It must feel heavy, soft, old,
matte, and used, never festive or decorative. Do not use bright ochre, gold,
orange, ivory, cream, yellow edging, saturated red, or a long bright highlight.
The brightest cloth plane is only modestly lighter than the base. Build the
surface from exactly three broad value masses: a dominant dark middle mass, a
deeper shadow mass, and a restrained dim warm plane. Add exactly two short,
broad, broken dim highlight or fold planes at different heights. They must not
join into a full-height stripe. Add two or three broad low-frequency shadow
folds and three to six large, low-contrast age stains that cross future action
bands. No stain may look like an action-sized oval, button plate, card, badge,
or repeating cell.

The cloth identity comes from broad folds, subtle edge thickness, sparse coarse
fiber clusters at a few stressed edges, and restrained hand-painted wear. Keep
the center quiet, matte, heavy, and readable behind future independent ink
motifs. Do not fill the surface with photographic burlap, uniform weave,
procedural grain, embossed wallpaper, repeated curls, micro-noise, evenly
spaced scratches, or dense distressed texture. There is no cast shadow because
this source will be composited onto a page at runtime.

Silhouette contract: use only four to six broad side deviations over the full
696-pixel height. Left and right sides are controlled but asymmetric and never
mirror each other. Each deviation is a slow hand-cut change, approximately
4 to 12 source pixels in amplitude, not a small tooth. Do not align changes to
the future horizontal cut rows. Do not make straight machine edges, periodic
waves, scallops, sawteeth, fringe, tassels, repeated tears, or a one-defect-per-
action rhythm. At the top, make one slight asymmetric compressed fold and a
small amount of coarse fray that can plausibly sit under an existing wax seal;
do not form a smooth symmetric arch or a second object.

The bottom tail contains exactly two unequal coarse blunt upward notches: one
smaller and shallower, the other wider but still shallow. The remaining bottom
forms a few broad heavy cloth lobes. The two notches are visibly different and
hand-cut, not mirrored or evenly spaced. Do not add a third notch, tiny teeth,
regular sawtooth, equal tassels, a deep V, a symmetrical fishtail, a clean
modern ribbon cut, or detached strands.

Hidden runtime crop contract: the source will later be reduced proportionally
to 32 x 174 pixels. Its top 48 source pixels are a 32 x 12 runtime root. The
next seven possible capacity bands are each 88 source pixels high, corresponding
to seven 32 x 22 runtime action slots. The final 32 source pixels are one shared
32 x 8 runtime tail. Do not draw guides, seams, rows, boxes, horizontal hems,
fold breaks, edge steps, highlights, cracks, stains, or silhouette events on or
near y = 212, 300, 388, 476, 564, 652, 740, or 828. Keep at least eight source
pixels above and below every listed y coordinate visually continuous and quiet.
The upper boundary of the final tail must blend plausibly after any one of the
seven possible prefix endpoints. The source is one continuous material, never
seven stacked cells.

Style lock: an original coarse hand-painted bitmap asset for a 2004-era vanilla
WoW Azeroth expedition ledger. It is materially compatible with an old quest
book but remains a distinct dark cloth accent. It must not look vector-clean,
photorealistic, procedural, mobile-toolbar-like, modern flat UI, Diablo-3-like,
Skyrim-minimalist, Warhammer, gothic sci-fi, ceremonial military regalia, or a
generic modern fantasy ribbon.

Strict exclusions: no wax, seal, stamp, icon, motif, rune, glyph, text, letter,
number, button face, hit region, card, tile, divider, row, state, hover, pressed,
disabled, selected, Tooltip, book, page, spine, leather frame, metal, brass,
rivet, jewel, skull, eagle, aquila, weapon, chain, popup, side panel, paper
shadow, cast shadow, glow, glass, translucent black, photographic fiber field,
uniform microtexture, repeating curl, periodic edge damage, action-sized stain,
bright gold, bright orange, ivory, deep V tail, symmetrical fishtail, equal
tassels, more or fewer than exactly two blunt upward tail notches, detached
fiber, green spill, or object outside the declared bounding box.

Before returning, verify in order: exact 1024 x 1024 RGB canvas; exactly one
connected vertical object; exact [448,164,576,860] visible bounding box; uniform
#00FF00 everywhere outside it; dark low-saturation smoked-brown palette; exactly
three broad value masses; exactly two short broken dim highlight planes; only a
few broad nonperiodic asymmetric side deviations; exactly two unequal coarse
blunt upward tail notches; quiet continuity around all eight future crop rows;
no motif, button, wax, text, book, cast shadow, microtexture, periodic 22-pixel
rhythm, bright color, modern ribbon geometry, or extra object.
```

### Prompt 完整性审计

| 检查项 | 结论 |
|---|---|
| 基线融合 | 已在正文显式写入香草时代、二维手绘、大块明暗、厚重材料、综合色与禁用现代／暗黑／战锤语言；不是只依赖外部引用 |
| 引用优先级 | Image 1 为最高权威，Image 2 仅作邻接综合色和笔触尺度；冲突规则明确 |
| 组件粒度／所有权 | 只生成空白布底；纹章、Button、交互、状态、文字和火漆全部排除 |
| 画布／bbox／对象数 | `1024² RGB`、纯绿、单连通对象、精确 `128×696px` bbox 均已固定 |
| 动态切片／展示区 | root、七容量段、tail、八条安静切线、真实 viewport 和奖励距离均已量化 |
| 用户否决闭环 | 明亮轻浮、规则切口、整段微纹、动作格底板已逐项转成正向限制与严格禁项 |
| 可审查性 | 三块明暗、两段暗亮面、4–6 个宽侧偏移、恰好两处不等钝缺口均可计数 |
| 不确定项 | 最终手绘纤维与边缘 Alpha 必须由候选、缩小图、真实排版和客户端门禁验证，不由模拟替代 |

### 最多五次自主修复与确定性后处理合同

- attempt 1 固定上传 Image 1／2，执行 `generate`。attempt 2–5 仍固定同顺序、
  同 SHA 的 Image 1／2；只有紧邻候选仍是一条单连通布底、总体材料／光向／
  纵向结构正确，失败仅属于以下冻结边界时，才可把它作为唯一 Image 3 执行
  edit：轻微 bbox／比例偏差、残余过密微纹、侧边不够宽或仍过于规律、恰好
  两处尾缺口的粗钝／不等程度、污渍／亮面过强、少量误生禁项或纯绿污染。
- 若候选改变对象数、生成纹章／书页／按钮、材料方向变亮、出现严重透视、
  主轮廓完全错误、缺口数不是可局部修复的两处，或需要改写拓扑，则不上传该
  候选，下一次从固定 Image 1／2 regenerate。
- 每次存在 provider 生成证据才计入一次实际 ImageGen 调用；上传失败、工具错误、
  超时且无生成证据等流程错误单独记录，不占五次额度。候选完整通过即提前停止；
  第五次仍失败则停止并等待用户审核，禁止 attempt 6。
- 冻结项：组件 ID、单物件所有权、Image 1／2、执行器版本、画布、bbox、source／
  runtime 纵向比例、root／七容量段／tail、纯绿策略、动态 prefix＋tail、暗色
  材料方向、恰好两处不等粗钝缺口、禁止内容和真实展示场景。新增输入、改变
  对象数／拓扑／材料方向／画布／provider 映射时必须重新授权。
- 允许的确定性处理仅为：provider 若返回同轴正方形但非 `1024²`，可等比归一
  到 `1024²`；执行边缘连通纯绿色键并把透明像素 RGB 清零；若完整单物件的
  bbox 纵横比相对 `128:696` 的误差不超过 `1%`，可整体等比 bbox-fit 到目标
  中心，整数舍入除外。超过 `1%`、需要非等比拉伸、裁切、补画、局部搬移、
  数字修纹或轮廓手术时一律退回修复循环。
- 通过候选才可确定性导出 source、最大 runtime、prefix／tail crop、metrics
  和 manifest；这些动作仍以用户接受候选进入 P4 为前提，当前不得预先创建。
- 每稿必须先检查单物件、纯绿、bbox、综合色、三块明暗、两段暗亮面、4–6 个
  宽侧偏移、两处不等钝缺口、安静切线、缩到 `32×174px` 的材料可读性和接缝。
  然后用真实 Quest Log 排版覆盖 closed、7、5、3（含一个 disabled）、
  scroll `52`、scroll `208` 六场景；保持 18 行任务、长详情、四个
  `108×41px` 奖励槽、真实字体与当前 QS-A1 火漆。结构／排版报告必须全过，
  display-region 必须 `6/6`、violations `0`。

### 用户正式生产授权与执行门禁

- 用户于 `2026-08-05` 明确授权原文：`确认授权 QS-B1 V4-A；允许每次上传固定
  SHA 的 Image 1/2，允许同循环紧邻前次输出仅在冻结修复边界内作为 Image 3
  edit 输入；最多 5 次实际 ImageGen 调用，流程错误不占额度；允许按合同执行
  同轴 1024² 归一化、边缘连通色键、透明 RGB 清零及纵横比误差 ≤1% 的等比
  bbox-fit。`
- 当前子状态：`prompt-authorized / P3`。授权严格对应上方逐字 production 正文、
  两张固定 SHA 参考、冻结修复边界和最多 `5` 次实际调用；V13 模拟像素、V3-A
  失败稿、其他 reference 与跨段候选仍禁止上传。
- production 当前为 `0/5`，流程错误 `1`。授权版本已由 commit `6cbf715`
  固定；下一门禁为以完全相同正文与固定 Image 1／2 进行一次 transport retry。
- 授权允许生成与内部审查到 `candidate-reviewed / P3`，但不等于用户接受 source。
  循环通过前不创建 source、manifest、exporter 或 runtime，不修改 addon，
  不隐藏或代理旧按钮，也不执行 V3-B。

### V4-A 正式生成与流程错误记录

| 流程错误 | 正文版本／执行前 commit | session／result | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| `E1` | `QS-B1 V4-A` / `6cbf715` | 无 child session／无 provider result | 固定 0.143.0 CLI 在 provider 前返回 `Reading prompt from stdin...`／`No prompt provided via stdin.`；`attempt-01/` 为空，没有候选图、结果 ID 或生成作业证据 | `codex exec -i` 的 `<FILE>...` 参数吞掉了末尾 prompt；保持正文、Image 1／2、顺序、SHA 与输出目录不变，只在最后一个 `-i` 后加入标准 `--` 参数分隔符 | 流程错误，不占额度；仍为 `0/5` |

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| `1/5` | `QS-B1 V4-A` / `6cbf715` | `generate` | child session `019fd163-9fff-7152-aa3c-81334d3b9784`；cache result `ig_0b34145253fd2717016a730b3ccc988191b5bbe69bb43aa202.png` | `attempt-01/QS-B1-V4-A.attempt-01.raw.png`；`1254×1254 RGB`；SHA `3fdc52c3a061e2d6337ff37cfea31ecdc09543b1ef61ecf817164d29d789e97f` | `组件合同／bbox`：同轴归一后可见对象 `264×850px`，aspect `0.310588` 对目标 `0.183908`，误差 `68.882%`，远超 `≤1%`；禁止 bbox-fit | 单连通暗布身份与综合色方向可保留为文字判断；不保留像素。材质同时出现摄影式连续织纹，顶边为近对称吊床弧，尾部一处为过深尖 V，并有横向亮带／圆斑。下一稿固定 Image 1／2 regenerate，不上传本稿 Image 3 | `internal-rejected / 1/5` |

#### Attempt 1 审查证据

- raw 由 child cache 原样复制；child 自身只读 sandbox 的落盘失败发生在生成后，
  不额外增加实际调用，也不改变 raw。当前正式计数 `1/5`，流程错误仍为 `1`。
- 技术 review：
  `generated/quests/QUEST-SEALS/QS-B1-V4-A/attempt-01/review/QS-B1-V4-A.attempt-01.review.json`；
  自动检查 `5/9 pass`，第一失败
  `normalized_visible_bbox_exactly_128x696`；runtime 可见 bbox 只有
  `[0,33,32,141]`，八条切线中 root、尾部与一条中段没有布面覆盖。
- 真实排版：同目录 `QS-B1-V4-A.attempt-01.real-layout.png`，SHA
  `f64f3f23cdee6d6b9cc7ec5f030adb31d4deb0c4aae872757dfa7118c40e4a6a`；
  六场景交互／收拢几何 `26/26 pass`，但错误比例导致布底只占目标中段，不能
  作为可见候选。展示区域几何报告 SHA
  `afe8705c1f4ba942ff86e5b606300e8cce706fb470fa95e1e83f96d9c4925cf2`，
  `6/6 pass`、violations `0`；该结果只证明冻结 viewport／Button 公式，不
  推翻 source bbox 与美术失败。
- 视觉／物理：单条暗色布身份和无额外对象成立；顶边却形成近对称下垂弧，
  不是火漆下的轻微不对称压褶。两处尾缺口中左缺口狭长且过深、尖锐，违反
  “浅、粗、钝”；全幅密集摄影织纹与重复卷曲微噪声违反香草时代粗颗粒二维
  手绘条款。至少三条横向亮带容易在动态 prefix 连接时读成分段接缝。
- 修复决策：不使用 edit。`68.882%` 比例误差和摄影式表面都不属于允许保留
  像素的轻微局部失败；attempt 2 只上传同 SHA Image 1／2，以完整 V4-A.r1
  从锁定权威 regenerate。

### QS-B1 V4-A.r1 完整修复执行正文

```text
Create one production-ready raster source asset for a Turtle WoW 1.18.1
Interface 11200 quest-log overhaul. Generate only the continuous blank cloth
substrate that hangs beneath an existing wax seal inside the right-page
scrolling content. This substrate is visual-only, owns no function, and receives
no mouse input. Draw no wax seal, icon, motif, text, button, state, book, page,
frame, popup, side panel, menu plate, or other object.

Reference authority and filtering:
1. Image 1 is the highest visual authority. Inherit only its circa-2004 vanilla
   World of Warcraft low-resolution 2D hand-painted bitmap language, broad
   readable value planes, substantial material weight, muted expedition color,
   restrained upper-left light, sparse wear, and deliberately nonmodern finish.
   Ignore its complete book, pages, leather, brass, wax seal, ribbons, compass,
   buttons, reward slots, text, and full composition.
2. Image 2 is a secondary accepted-adjacency reference. Inherit only its local
   dark-walnut color temperature, coarse paint scale, softened painted edge,
   upper-left light direction, and restrained wear density. Ignore and do not
   reproduce its book, pages, spine, brass, transparency, silhouette, or pixels.
If the references conflict, Image 1 and the Azeroth quest-ledger baseline win.
Neither reference authorizes copying an object or composition.

Canvas and exact slender geometry: output an exact 1024 x 1024 RGB bitmap.
Draw exactly one connected, vertical, orthographic, unrotated cloth object. Its
exact visible bounding box is [448,164,576,860], exactly 128 pixels wide and
696 pixels high. The height is exactly 5.4375 times the width. This is a very
slender vertical oath strip, not a conventional 1:3 banner. Visible cloth must
reach x=448, x=575, y=164, and y=859 while remaining entirely inside that box.
Do not return a wider or shorter object and do not leave unused vertical space
inside the declared box. The entire object must be visible. Every pixel outside
it is the same uniform solid #00FF00 with no gradient, paper, cloth, haze,
vignette, checkerboard, glow, contact shadow, color spill, loose fiber, or
separate fragment. Do not crop, mirror, tilt, bend it in perspective, or stretch
one axis independently.

The object is dark, low-saturation, smoke-aged expedition-guild oath linen:
charcoal brown, dark walnut, and deep umber. It feels heavy, soft, old, matte,
and used, never festive or decorative. Do not use bright ochre, gold, orange,
ivory, cream, yellow edging, saturated red, or a long bright highlight. The
brightest cloth plane is only modestly lighter than the base. Paint exactly
three broad low-frequency value masses: one dominant dark middle mass, one
deeper shadow mass, and one restrained dim warm mass. Add exactly two short,
broad, broken dim fold planes at different heights. Each is an irregular local
plane, not a stripe across the width, and the two never join vertically. Add
two or three broad low-frequency shadow folds and three to six large diffuse,
low-contrast age stains crossing future action bands. Stains are irregular and
soft, never circular spots, action-sized ovals, button plates, cards, badges,
rows, or repeating cells.

This must be visibly a coarse 2004-era hand-painted bitmap, not a photographed
piece of fabric. Describe cloth with broad brush masses, subtle edge thickness,
and only a few sparse coarse fiber clusters at stressed outer edges. At source
scale there is no individually resolved weave, no all-over thread field, no
burlap photograph, no repeated curly fibers, and no uniform grain. Keep the
central seventy percent matte, calm, heavy, and low-detail so future independent
ink motifs remain readable. Do not fill the surface with photographic burlap,
uniform weave, procedural grain, embossed wallpaper, repeated curls,
micro-noise, evenly spaced scratches, dense distress, or a textile scan. There
is no cast shadow because this source will be composited onto a page at runtime.

Side silhouette: use only four to six broad deviations over the full 696-pixel
height. Left and right sides are controlled but asymmetric and never mirror
each other. Each deviation is a slow hand-cut change about 4 to 10 source
pixels in amplitude and spans a large vertical distance. Do not align a side
change to any future action row. Do not make straight machine edges, periodic
waves, scallops, sawteeth, fringe, tassels, repeated tears, or one defect per
action. The strip must remain slender and mostly vertical, without swelling
into a wide banner.

Top silhouette: the top reaches y=164 and remains nearly horizontal. Give it
one slight asymmetric compressed fold under the future wax seal, with a total
vertical sag no deeper than 8 source pixels, plus one or two restrained coarse
edge irregularities. It must never form a centered U, hammock curve, smooth
symmetrical arch, rolled hem, hanging sleeve, or second object.

Bottom silhouette: the tail reaches y=859 and contains exactly two unequal,
shallow, coarse, blunt upward notches. The first notch is broader and about
10 to 16 source pixels deep; the second is narrower and about 6 to 10 pixels
deep. Both have blunt or softly irregular inner ends, never sharp points. They
are visibly unequal, asymmetrically placed, and separated by broad heavy cloth
lobes. No notch may exceed 18 source pixels in depth. Do not add a third notch,
tiny teeth, a deep or narrow V, regular sawtooth, equal tassels, symmetrical
fishtail, clean modern ribbon cut, long hanging prong, or detached strand.

Hidden runtime crop contract: the source will later be reduced proportionally
to 32 x 174 pixels. Its top 48 source pixels are a 32 x 12 runtime root. The
next seven possible capacity bands are each 88 source pixels high and correspond
to seven 32 x 22 runtime action slots. The final 32 source pixels are one shared
32 x 8 runtime tail. Do not draw guides, seams, rows, boxes, horizontal hems,
cross-width light bars, fold breaks, edge steps, cracks, stains, or silhouette
events on or near y = 212, 300, 388, 476, 564, 652, 740, or 828. Keep at least
eight source pixels above and below every listed y coordinate visually
continuous and quiet. No bright fold may cross one of these rows. The upper
boundary of the final tail must blend plausibly after any one of the seven
possible prefix endpoints. The source is one continuous material, never seven
stacked cells.

Style lock: an original coarse hand-painted bitmap asset for a 2004-era vanilla
WoW Azeroth expedition ledger. It is materially compatible with an old quest
book but remains a distinct dark cloth accent. It must not look vector-clean,
photorealistic, procedurally textured, mobile-toolbar-like, modern flat UI,
Diablo-3-like, Skyrim-minimalist, Warhammer, gothic sci-fi, ceremonial military
regalia, or a generic modern fantasy banner.

Strict exclusions: no wax, seal, stamp, icon, motif, rune, glyph, text, letter,
number, button face, hit region, card, tile, divider, row, state, hover, pressed,
disabled, selected, Tooltip, book, page, spine, leather frame, metal, brass,
rivet, jewel, skull, eagle, aquila, weapon, chain, popup, side panel, paper
shadow, cast shadow, glow, glass, translucent black, photographed fabric,
visible weave, uniform microtexture, repeated curl, periodic edge damage,
action-sized or circular stain, horizontal light bar, bright gold, bright
orange, ivory, centered U-shaped top, deep or sharp V notch, symmetrical
fishtail, equal tassels, more or fewer than exactly two blunt upward tail
notches, detached fiber, green spill, or object outside the declared box.

Before returning, verify in order: exact 1024 x 1024 RGB canvas; exactly one
connected orthographic object; exact [448,164,576,860] visible bounding box;
exact 128:696 or 1:5.4375 slender proportion; uniform #00FF00 everywhere
outside; dark low-saturation smoked-brown palette; broad hand-painted masses
with no visible weave; exactly three broad value masses; exactly two short
broken dim fold planes and no cross-width light bar; only four to six broad
nonperiodic asymmetric side deviations; a nearly horizontal asymmetric top
with no centered U; exactly two unequal shallow coarse blunt tail notches, both
under 18 pixels deep; quiet continuity around all eight future crop rows; no
motif, button, wax, text, book, cast shadow, microtexture, periodic 22-pixel
rhythm, bright color, modern banner geometry, or extra object.
```

### V4-A.r1 执行决定

- 操作：`generate`，不使用 attempt 1 作为 Image 3；固定上传与授权相同 SHA 的
  Image 1／2，顺序不变。
- 冻结项未变：单一 substrate、`1024² RGB`、目标 bbox、root／七容量段／tail、
  动态 prefix＋tail、纯绿色键、暗色材料、双钝缺口、禁止纹章／Button／文字／
  火漆和最多五次实际调用。
- r1 只把授权内可修复项量化：`1:5.4375` 细长比例、顶边最大 `8px` 浅压褶、
  两个尾缺口均浅于 `18px`、无全幅可见织纹、无横向亮带和圆形动作斑。
- 下一次执行前必须提交本节；attempt 2 若返回候选则累计 `2/5`。

#### Attempt 2 执行与审查

- 正文／执行前 commit：`QS-B1 V4-A.r1 / aae767c`；操作 `generate`；固定
  Image 1／2，无 Image 3。child session
  `019fd169-707b-7642-a2e5-6130e64d2c68`；cache result
  `ig_09dc5dbe070ef2cd016a730cb68e2081919029d1385611a43d.png`。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V4-A/attempt-02/QS-B1-V4-A.r1.attempt-02.raw.png`；
  `1254×1254 RGB`；SHA
  `fd15d4c27f6050fd7faf6e6824bab0c9f641b966f8df2edef6b04d6bfb85e271`。
  child 只读 sandbox 仍不能直接复制，但 parent 原样复制同一 cache 文件；不
  追加调用或流程错误。
- 第一失败门禁仍为 `组件合同／bbox`：同轴归一后可见对象 `296×964px`，
  aspect `0.307054` 对目标 `0.183908`，误差 `66.961%`；不得执行 `≤1%`
  bbox-fit。runtime 可见 bbox 仅 `[0,32,32,141]`，root／tail 与一条后段切线
  无布面覆盖；自动检查 `5/9 pass`。
- 视觉失败：尽管双缺口数量和综合色方向成立，两处缺口仍被画成深而窄的尖齿
  间隙；主体仍有满幅摄影式细密织纹，顶部和中段出现大面积近写实折光，不是
  香草 UI 的三块粗手绘色面。对象仍被自动放大为占画布近三成宽、九成四高的
  近景旗帜。
- 真实排版 SHA
  `64399082ae4ef4935cee8a6c8c58b5d83f0be75681b91c92fc188e2ef64661b1`；
  交互／动态收拢公式 `26/26 pass`，但候选像素只覆盖目标中段。display-region
  报告 SHA
  `a3fc86bfc5b7fda914acaeca595089c8cfa81e2a863736759f8c47a97cf45ea1`，
  `6/6 pass`、violations `0`；仍只证明冻结几何。
- 结论：`internal-rejected / 2/5`。连续两次相同首要失败后改变策略：不把
  attempt 2 作为 Image 3；V4-A.r2 从固定 Image 1／2 regenerate，缩短叙述并
  把对象明确成技术 sprite sheet 上的极窄 2D atlas strip，以画布百分比和大块
  平涂约束优先于材料形容词。

### QS-B1 V4-A.r2 完整修复执行正文

```text
Generate one isolated 2D bitmap sprite for a 2004-era vanilla World of Warcraft
quest-log UI. This is a technical sprite-sheet asset, not a scene, illustration,
product photograph, banner presentation, or close-up. Draw exactly one blank,
very narrow, vertical strip of old dark oath cloth. It will sit below a separate
wax seal, but do not draw the seal or any other object.

OUTPUT GEOMETRY — highest priority:
- Exact 1024 x 1024 RGB canvas.
- Uniform solid #00FF00 technical chroma field everywhere outside the cloth.
- Exactly one connected cloth object, centered, orthographic, vertical and flat.
- Exact visible bbox [448,164,576,860]: x 448 through 575 and y 164 through 859.
- Exact visible size 128 x 696. Height is 5.4375 times width.
- The cloth occupies only 12.5% of canvas width and 68% of canvas height.
- Leave huge pure-green margins: 448 px left, 448 px right, 164 px top and
  164 px bottom. Do not zoom in, enlarge the object, fill the canvas, shorten it,
  make a normal wide banner, or leave unused space inside the declared bbox.
- Visible cloth reaches all four bbox limits while never crossing them. No cast
  shadow, floor, page, haze, loose fragment or green spill.

REFERENCE ROLES:
Image 1 is the highest visual authority. Inherit only its circa-2004 vanilla WoW
coarse hand-painted bitmap language, broad readable value shapes, heavy material
weight, muted expedition palette, upper-left light and sparse wear. Ignore its
book, pages, leather, brass, wax, ribbons, compass, buttons, rewards, text and
composition. Image 2 is secondary adjacency only: inherit dark-walnut color
temperature, broad paint scale, softly painted edges and restrained wear. Ignore
its book, spine, pages, brass, transparency, silhouette and pixels. If they
conflict, Image 1 wins.

PAINTED SURFACE:
This is a flat hand-painted UI sprite, not photographed fabric. Use exactly three
large low-frequency painted value shapes: dominant charcoal-brown, deeper umber
shadow, and one restrained dim walnut plane. Use exactly two short broad broken
dim fold planes; neither crosses the full width and neither forms a horizontal
bar. Add two or three broad shadow folds and three to six large diffuse irregular
low-contrast stains spanning more than one future action band. Stains are not
circles, ovals, badges or buttons. Keep the central 70% calm, matte and low-detail.
At source scale show no individual threads, weave, burlap pattern, curly fibers,
uniform grain, repeated scratches, textile scan, micro-noise or photographic
texture. A few coarse painted edge nicks are allowed; dense fiber detail is not.
Palette is low-saturation smoke-aged charcoal brown, dark walnut and deep umber.
No gold, bright ochre, orange, ivory, cream, bright rim, saturated red or glow.

SILHOUETTE:
Keep the strip extremely narrow and mostly vertical. Across the full height use
only four to six broad slow asymmetric side deviations, each 4 to 8 px deep and
spanning a large vertical distance. Left and right never mirror. No periodic
wave, sawtooth, scallop, fringe, repeated tear, straight machine edge, action-row
rhythm or wide banner flare.

The top reaches y=164 and is nearly horizontal. It has one small asymmetric
compressed fold no deeper than 6 px. No centered U, hammock sag, rolled hem or
symmetrical arch.

The bottom reaches y=859. Cut exactly two shallow unequal blunt upward notches
inside the final 32 px tail zone: one broad notch around local x 26..44 and
8..12 px deep, and one differently sized notch around local x 82..104 and
5..8 px deep. Their inner ends are blunt and softly irregular, never pointed.
Keep broad cloth lobes between and beside them. No third notch, deep V, sharp
tooth, long prong, sawtooth, tassel, symmetrical fishtail or detached thread.

DYNAMIC CROP SAFETY:
The sprite reduces to 32 x 174. Local y 0..47 is the root, the next seven bands
are each 88 source pixels, and local y 664..695 is the shared tail. Future source
cut rows are absolute y 212, 300, 388, 476, 564, 652, 740 and 828. Keep at least
8 px above and below each row quiet and continuous: no seam, row, guide, edge
step, crack, horizontal fold, cross-width highlight, stain boundary or silhouette
event. This is one continuous strip, never stacked cells.

COMPONENT EXCLUSIONS:
No wax, seal, icon, motif, glyph, rune, text, number, button, hit area, state,
card, tile, divider, page, book, spine, leather, metal, brass, rivet, jewel,
skull, eagle, chain, popup, side panel, shadow, glow, glass, modern flat UI,
Diablo-3 ornament, Skyrim minimalism, Warhammer or sci-fi regalia. It owns no
function and contains no dynamic content.

FINAL CHECK: exact 1024 square RGB; one object; exact 128 x 696 bbox and huge
green margins; 1:5.4375 extremely slender proportion; dark matte three-shape
hand painting with no visible weave; exactly two short broken dim fold planes;
four to six broad nonperiodic side deviations; nearly straight asymmetric top;
exactly two shallow unequal blunt tail notches inside the final 32 px; all eight
crop rows quiet; no extra object, bright color, photography, icon, text or wax.
```

### V4-A.r2 执行决定

- 操作：`generate`；固定 Image 1／2；不上传 attempt 2 或任何旧候选作为
  Image 3。
- 对象数、参考职责、画布、bbox、暗色材料、动态切片、双钝缺口、禁止内容与
  后处理合同不变。r2 只改变冻结边界内的表达优先级：先声明技术 sprite sheet
  及 `12.5%×68%` 画布占比，再以更少材料形容词约束三块二维平涂。
- 下一次执行前提交本节；attempt 3 若返回候选则累计 `3/5`。

#### Attempt 3 执行与审查

- 正文／执行前 commit：`QS-B1 V4-A.r2 / aec6845`；固定 Image 1／2，
  `generate`，无 Image 3。child session
  `019fd16f-2f9d-7e61-96e3-4dff4331d68b`；cache result
  `ig_000991899a0b1567016a730e2f596481918685bec7e23cf0e9.png`。
- raw：
  `generated/quests/QUEST-SEALS/QS-B1-V4-A/attempt-03/QS-B1-V4-A.r2.attempt-03.raw.png`；
  `1254×1254 RGB`；SHA
  `74cb222c5d17e107ef25db269da05e79bc8a5638408f332e0828433baac4f22b`。
- 第一失败门禁仍为 `组件合同／bbox`，但策略已显著改善：同轴归一后可见
  `206×855px`，aspect `0.240936` 对目标 `0.183908`，误差从 `66.961%`
  降至 `31.009%`；仍远超 `≤1%`，不得 bbox-fit。runtime bbox
  `[0,18,32,156]`，root 和 tail 仍为空；自动检查 `5/9 pass`。
- 美术：综合色、低频大块手绘和中央安静度已明显接近 V13；没有额外对象或
  满幅摄影织纹。仍失败的可见细节为：右上角被画成独立翻折纸角，物理上不属于
  柔软布根；两处尾缺口变成边缘过于光滑、接近规则半圆的冲孔；两段斜亮面
  仍偏强。对象占画布约 `20.1%×83.5%`，没有达到 `12.5%×68%`。
- 真实排版 SHA
  `911c81f84e64fcb8af5271b7e6b460d93e25957a69348965b324cd61bc63a056`；
  几何 `26/26 pass`。display-region 报告 SHA
  `8fc79d4db18b6b480a1e0c2634f95a8464f91c156db42bed7aaf1a3787fc9a19`，
  `6/6 pass`、violations `0`；候选仍未覆盖完整 root／tail，不能用户复审。
- 结论：`internal-rejected / 3/5`。比例仍不是轻微偏差，故不上传 attempt 3
  作为 edit input。V4-A.r3 保持固定两张参考 regenerate；继续沿用有效的
  “技术 sprite／平涂”策略，但把正文压缩到高风险合同并明确禁止折角、平滑
  U 孔和自动近景构图。

### QS-B1 V4-A.r3 完整修复执行正文

```text
Create one small technical UI sprite on a green-screen atlas sheet. This is not
a scene, close-up, banner presentation, photograph, paper strip or illustration.

HARD GEOMETRY — obey literally:
Output 1024 x 1024 RGB. Background is uniform solid #00FF00. Draw exactly one
connected, flat, vertical dark-cloth oath strip. Its exact visible bbox is
[448,164,576,860], width 128 and height 696, ratio 1:5.4375. It occupies only
one eighth of canvas width and about two thirds of canvas height. Keep 448 px
pure green on both left and right and 164 px pure green above and below. Do not
zoom in or make an aesthetically framed hero object. Do not make it wider than
128 or taller than 696. Cloth pixels touch all four bbox limits and never cross
them. One object only, orthographic, unrotated, no perspective, cast shadow,
page, floor, haze, fragments or green spill.

The object is only a narrow flexible strip of smoke-aged expedition-guild oath
linen. It is not a wide flag, normal banner, paper bookmark, leather panel or
scroll. The top is nearly straight with one tiny asymmetric compressed cloth
wrinkle no deeper than 6 px. No folded corner, dog-ear, rolled edge, centered U,
hammock sag or symmetrical arch.

The bottom reaches y=859. Inside only the final 32 px, cut exactly two unequal
shallow blunt irregular bites upward: one about 16..22 px wide and 8..12 px
deep, the other about 20..28 px wide and 5..8 px deep. They are coarse hand-cut
indentations with flattened irregular inner ends, not smooth semicircular U
holes and not pointed V cuts. Keep broad heavy lobes. No third notch, sharp
tooth, deep V, sawtooth, tassel, fishtail, long prong or detached thread.

Use only four to six broad slow side deviations, 4..8 px deep, distributed
nonperiodically over the full height. Left and right are asymmetric. No one-
defect-per-row rhythm, scallop, fringe, repeated tear, exact mirror or flare.

ART STYLE:
Image 1 is highest authority for 2004-era vanilla WoW coarse 2D hand painting,
broad readable value shapes, material weight, muted expedition color, upper-
left light and sparse wear. Ignore its book, pages, leather, metal, wax, text,
buttons and composition. Image 2 is secondary only for dark-walnut temperature,
broad paint scale, soft painted edge and restrained wear. Ignore its book,
spine, pages, brass, transparency, silhouette and pixels. Image 1 wins conflicts.

Paint the cloth as exactly three large low-frequency matte shapes: charcoal-
brown base, deep umber shadow, and one dim walnut plane. Add exactly two short,
broad, broken, low-contrast fold planes. They do not cross the width, do not
touch crop rows and do not look like diagonal slashes. Add 3..6 large diffuse
irregular low-contrast stains. Keep the central 70% quiet and low-detail. This
is a hand-painted bitmap sprite, never photographed fabric: no visible threads,
weave, burlap, textile scan, repeated curls, uniform grain, micro-noise, dense
scratches, bright rim, gold, orange, ivory, saturated red or glow.

DYNAMIC CROP SAFETY:
The source reduces to 32 x 174. Keep absolute y rows 212, 300, 388, 476, 564,
652, 740 and 828, plus 8 px above and below each, visually continuous and quiet.
No seam, guide, cell, edge step, crack, stain boundary, horizontal fold,
cross-width highlight or silhouette event there. The final 32 px is the shared
tail. This is one continuous material, never stacked action cells.

No wax, seal, icon, motif, rune, glyph, text, number, button, state, card, tile,
divider, book, page, spine, leather, metal, jewel, skull, eagle, chain, popup,
side panel, modern flat UI, Diablo, Skyrim, Warhammer or sci-fi element.

FINAL CHECK: 1024 square RGB; one object; exact bbox 128 x 696 at the declared
coordinates; huge green margins; unusually slender 1:5.4375 shape; no folded
corner; exactly two shallow unequal coarse blunt tail bites; four to six broad
nonperiodic side deviations; three matte hand-painted value shapes; two dim
broken folds; no photography, weave, bright stripe, extra object, icon or text;
all eight crop rows quiet.
```

### V4-A.r3 执行决定

- 操作 `generate`；固定 Image 1／2；attempt 3 不作为 Image 3。
- 冻结合同不变。r3 只在授权修复范围内删减会触发“近景 banner／摄影织物”的
  叙述噪声，并显式排除 attempt 3 新出现的 folded corner／smooth U hole。
- 下一次执行前提交本节；attempt 4 若返回候选则累计 `4/5`。
