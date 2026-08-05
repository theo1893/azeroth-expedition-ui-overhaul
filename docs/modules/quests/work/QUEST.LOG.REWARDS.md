# QL-D Quest Log 奖励槽 V1

## 元数据

- 模块：Quests／Quest Log 右页。
- 批次：`QL-D V1`。
- 组件 ID：`QUEST.LOG.REWARD.SLOT`。
- 子状态：`simulation-proposed / awaiting-user-confirmation`。
- 项目阶段：当前几何／fallback `P6 game-validated`；最终美术 `P2`。
- 固定执行器：若后续获得独立生产授权，只允许
  `imagegen-0-143-0`／`@openai/codex@0.143.0`。
- 当前实际 ImageGen 调用：`0/0`；本轮没有生产授权、没有 source、没有
  runtime 位图。
- 用户问题来源：`2026-08-04` 实机截图确认多奖励重叠／末端裁切、详情与奖励
  字体难读，以及 pfUI 平面黑灰奖励卡片过于现代。
- 实机修复确认：`2026-08-05` 用户确认 Quest 右页的既有 bug 和显示问题均已
  修复；覆盖 FrameXML 锚点错误、奖励间隔／换行、详情末端及原生 NameFrame
  回显。该确认接受当前运行时几何和 fallback 表现，不等于确认 QL-D V1
  最终奖励槽美术方向或授权 ImageGen。

## 美术基准继承

- 锁定视觉基准：
  [`任务详情面板_视觉基准_v1.png`](../../../../assets/locked/quests/任务详情面板_视觉基准_v1.png)，
  SHA-256
  `03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd`。
- 稳定 Prompt provenance：
  [`ART_BASELINE.md`](../ART_BASELINE.md)、
  [`SUBMODULE_ART_BASELINES.md`](../SUBMODULE_ART_BASELINES.md) 的“奖励槽与分隔”、
  [`GLOBAL_ART_BASELINE.md`](../../../GLOBAL_ART_BASELINE.md)。
- 当前邻接 runtime：
  `addon/AzerothExpeditionUI/Media/Quests/QuestLogShellV4.tga`，SHA-256
  `1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e`；
  只提供已接受书页综合色、材料尺度与真实摆放环境。
- 已接受漆章 atlas：
  `addon/AzerothExpeditionUI/Media/Quests/QuestToolWaxSealStatesV1.tga`，SHA-256
  `f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902`；
  只用于还原当前相邻页面，不属于奖励槽生成输入。
- 用户实机截图只用于诊断 provider 输出、阅读密度、重叠与裁切；截图像素没有
  进入模拟稿，也不得成为 source、Image 3 或修图输入。

## 组件合同

- 真实对象：`QuestLogItem1..MAX_NUM_ITEMS`；原 Button、图标、数量、名称、
  品质色、Tooltip、点击脚本和 provider 显隐全部保留。
- Quest Log 奖励只读；状态为 `normal／hover／pressed／disabled`，没有
  `selected`。
- 单格真实命中盒固定 `108 × 41 UI px`；名称安全宽 `64px`；两列间隔
  `8px`，同行间隔 `4px`，分区标题至第一行间隔 `5px`。
- 每个奖励分组由真实标题 FontString 起锚；第偶数项锚到前一项右侧，第奇数项
  锚到前两项下方。0／1／2／4／6 数量均不得依赖 provider 的旧锚点。
- `QuestLogItemReceiveText`／`QuestLogRequiredMoneyText` 保持内在宽度，金额
  Frame 不得被推到 ScrollChild 外。详情末端按最底可见对象及原生
  `QuestLogSpacerFrame` 重算，不能固定为 `324px` 后裁掉奖励。
- 正式位图如获确认，只能绘制容器材料：浅削角旧皮革边框、克制氧化黄铜边、
  左侧深皮革图标凹槽、右侧安静羊皮纸名称面和窄接触阴影。图标、数量、名称、
  品质色、状态文字和发光均不得烘焙。
- 任何媒体缺失时 fail-open 到当前暖纸色程序化 fallback；不能阻止奖励数据、
  鼠标或 Quest Log 加载。

## 当前代码修复

- Quests runtime `1.22` 对选择奖励、法术奖励和固定奖励分别读取真实数量并
  `ClearAllPoints` 后重建双列锚点；每项固定 `108 × 41px`，不再继承 pfUI
  压缩后的旧尺寸或 provider 重叠点。
- 复核确认 pfUI 的正 `4px` offset 实际把 backdrop 向 Button 内缩；runtime
  `1.21` 的 `SetAllPoints(item)` 反而把 fallback 放大到 Button 全边界。runtime
  `1.22` 改用两个显式锚点，把 backdrop 四边各向内收 `4px`；配合 `8px`
  Button 列距，同排卡片之间形成 `16px` 的稳定可见纸面间隔。
- 最新实机截图确认上述 backdrop 修复已执行，但三件选择奖励的首行仍相接；
  这证明 provider 在 AEUI 重排后又把真实 Button 写回了旧锚点／尺寸。runtime
  `1.23` 因此对 `QuestLogItemN.ClearAllPoints`、`SetPoint`、`SetWidth`、
  `SetHeight`／`SetAllPoints` 安装事件驱动几何锁：晚到写入会立即恢复当前分组的
  `108×41px`、`8px` 列距和 `4px` 行距，不新增维护型 OnUpdate。smoke 主动
  模拟 `-8px` 列锚点与 `116×35px` 尺寸回写并要求合同保持。
- 后续实机截图仍显示原生名牌相接，最终定位到作用域所有权事实：AEUI 接管
  `Quest Log` 后 pfUI 的同名 skin 被明确跳过，真实路径没有 `item.backdrop`；
  可见灰褐卡面来自 Blizzard `QuestLogItemNNameFrame`。runtime `1.24` 为每个
  原 Button 创建无鼠标的 adapter-owned 暖纸程序化容器，把真实图标、数量与
  名称迁入容器，隐藏并锁住原生 NameFrame 的晚到 `Show()`，同时保留 Tooltip、
  点击脚本、品质色和 Button 命中区。若 stock 数量 API 在 provider 晚刷新期间
  全部返回 `0`，则以真实可见 `QuestLogItemN` 范围完成最终双列布局兜底。
- runtime `1.24` 实机在 `QuestLogItemReceiveText:SetPoint()` 报出
  `QuestLogItem3 is dependent on this`：AEUI 的组首奖励依赖分组标题，原生 FrameXML 又会把
  `ItemReceiveText` 反向锚到奖励项，数量状态短暂不一致时形成环。runtime
  `1.25` 改成单向锚点树：分组标题仍排在上一对象下方，但每组首个奖励直接
  锚到同一个上一对象，并额外预留 `5 + 14 + 5px` 的标题／间隔高度；奖励项
  不再依赖任一分组标题。smoke 会模拟原生把 ReceiveText 锚回 Item3，并在
  任意锚点环出现时直接失败。
- Quest Visual Theme `1.8` 新增 `detailHeading` 与 `detailBody`：标题为
  Noto Serif SC `14px`、正文／奖励名为 `pfUI.font_default` `12px`，均无
  outline、无 shadow。
- 正式槽资产尚未确认前，runtime `1.25` 的 adapter-owned 容器只使用低透明
  暖纸底和深赭／旧黄铜边；它是可回退的程序化临时视觉，不是最终 source。

## V1 确定性本地模拟

- 规格：
  [`quest_log_reward_slots_simulation_v1.json`](../../../../tools/specs/quest_log_reward_slots_simulation_v1.json)，
  SHA-256
  `dab0f2685367fb66f8ee8c4454443c3ef9f8b6cf9da1120c12d1ce9e879460ff`。
- renderer：
  [`render_quest_log_reward_slots_simulation_v1.py`](../../../../tools/render_quest_log_reward_slots_simulation_v1.py)，
  SHA-256
  `3bf318e405e8dfd3d5730f17735feca25bfaf2280bcf945ddef14eb36d94456a`。
- Python fallback：`D:\Softwares\miniconda3\python.exe`，Python `3.13.5`，
  Pillow `11.3.0`；`py -3` 在当前设备不可用。
- 复现命令：

  ```powershell
  D:\Softwares\miniconda3\python.exe tools\render_quest_log_reward_slots_simulation_v1.py tools\specs\quest_log_reward_slots_simulation_v1.json --repo-root .
  ```

- ignored 输出：
  - `generated/quests/ql-d-reward-slots/simulation/V1/quest_log_reward_slots_sim_v1.png`，
    `676 × 464`，SHA-256
    `72be6792c80aab4485013205bc57314d2633c93baab0ba5960104f13925a6f1a`；
  - `quest_log_reward_slots_sim_v1_review_2x.png`，`1352 × 928`，SHA-256
    `430bf6e76d75a6dad928004b22636905a52ee8bdccf4af5a862d895d3957e235`；
  - 模拟报告 SHA-256
    `dde2a175ed64ce4442c5af316ea1471c601b342e9c8727fa3d355fe4eaae495c`。
- 模拟只展示方向：第一排为二选一，后两排为四件固定奖励；六格依次覆盖
  normal、hover、normal、pressed、normal、disabled。所有示例图标、数量和
  中文名称都是脚本动态绘制，不属于容器像素。
- 模拟像素为非权威 ignored 证据，永远不得晋级 source、作为生成上传或进入
  addon runtime。当前分支可由 tracked spec／renderer 确定性重建，因此没有
  发布 handoff 检查点。

## 展示区域门禁

- 合同：
  [`quest_log_reward_slots_sim_display_region_v1.json`](../../../../tools/specs/quest_log_reward_slots_sim_display_region_v1.json)，
  SHA-256
  `ac7d6dce4243c4b036b17ddf24b560411a7b25126c286a94c6da0fc21fa31f1d`。
- 运行命令：

  ```powershell
  D:\Softwares\miniconda3\python.exe .codex\skills\run-aeui-asset-workflow\scripts\validate_display_regions.py tools\specs\quest_log_reward_slots_sim_display_region_v1.json --report generated\quests\ql-d-reward-slots\simulation\V1\quest_log_reward_slots_display_region_report_v1.json
  ```

- 结果：`pass`；场景为 0／1／2／4／6 奖励，`5/5` 通过，violations `0`，
  first failure `null`。ignored 报告 SHA-256
  `1d1861889095b90decbe57e2a645535b405a0ca2a7f2a529e5fd4b952ffd0bb5`。
- 该结果只证明方向稿几何，不证明最终纹理、客户端 UV、交互或 P6 实机表现。

## 最终执行正文

尚未形成。当前只有本地几何／材料方向模拟，用户尚未确认可见方向，也没有
独立生产授权。确认前不得把模拟描述扩写成可执行 ImageGen 正文。

## 执行记录

- 本轮只运行 tracked renderer 与展示区域 validator；两次命令、解释器、输入
  SHA 和输出 SHA 已记录在上方。
- 实际生成／修图调用 `0`；流程错误 `0`；没有候选 source 或 runtime atlas。

## 审查记录

- 自动几何：0／1／2／4／6 五场景全部通过，违规 `0`。
- 本地目视：六格均落在右页纸面，图标／数量／名称可辨，normal／hover／
  pressed／disabled 有克制差异；容器没有烘焙动态内容。
- 实机审查：用户于 `2026-08-05` 确认当前右页 bug 与显示均已修复，当前
  几何／fallback 进入 `P6 game-validated`。仓库没有新增或虚构本轮截图路径。
- 未完成审查：QL-D V1 用户可见方向、最终小尺寸纹理与正式四态 atlas；这些
  尚未生产，因此不属于本次当前 fallback 的实机验收。

## 尝试摘要

| 尝试 | 类型 | 实际生图 | 结果 |
|---|---|---:|---|
| `QL-D-SIM-V1` | 确定性本地模拟 | `0` | `simulation-proposed / awaiting-user-confirmation`；display-region `5/5 pass` |

## 下一门禁

当前 runtime 几何／fallback 的实机门禁已经通过。下一门禁是用户确认 V1 的
可见方向：是否接受“深色旧皮革浅削角外框 + 左侧黄铜图标凹槽 + 右侧
羊皮纸名称面”，取代当前平面黑灰卡片。确认前不得形成正式生成正文、请求
ImageGen 授权、建立 source／atlas 或接入新位图。

若方向确认，下一步先冻结四态差异、最终 source／atlas 安全盒、固定上传与
最多实际生成次数，再单独请求生产授权。确认不等于生成授权。
