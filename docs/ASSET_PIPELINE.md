# 组件级资产与 imagegen 生产流程

## 核心规则

资产粒度必须与游戏内对象粒度一致。

如果一个组件拥有多个按钮、Tab、输入状态、滚动状态或警告状态，就必须先
分别定义逻辑资产。允许把这些逻辑资产打包进同一物理图集，但必须记录 UV、
状态行、可拉伸区和 pfUI／原生 Frame 映射。

整张视觉原型只能锁定综合色感和布局方向，不能直接作为完整运行时背景。

## 五类文件

| 类型 | 目录 | 是否进入运行时 | 说明 |
|---|---|---:|---|
| 锁定视觉基准 | `assets/locked/<module>/` | 否 | 用户确认的综合色感与结构参考 |
| 结构／故障参考 | `assets/references/<module>/` | 否 | 香草原型、pfUI 几何、问题复现 |
| 透明源母版 | `assets/source/<module>/` | 否 | 用户确认后保留的无文字高分辨率源 |
| 临时生成与预演 | `generated/` | 否 | Git 忽略，可随时重建 |
| 运行时资源 | `addon/AzerothExpeditionUI/Media/<Module>/` | 是 | 确定性导出的 TGA／BLP／字体 |

未经用户确认的候选、色键 raw、失败稿、调试合成图和可确定性再生的预览默认
不得进入 Git。

## 生成前的组件合同

每批图像生成前必须在模块规范或 tracker 中明确：

1. 组件 ID。
2. pfUI／原生 Frame 或 API 来源。
3. 逻辑对象数量。
4. 每个对象的状态数量。
5. 运行时 UI 尺寸和文字安全区。
6. 源画布、透明方式和对象排布。
7. 九宫格／三段式切线或图集 UV。
8. 允许上传的参考图及每张图的唯一职责。
9. 禁止烘焙的文字、图标和交互结构。
10. 验收截图与回退条件。

缺少任何一项时，不执行生图。

## 固定生图版本

所有生成和修图必须使用仓库内：

```text
.codex/skills/imagegen-0-143-0/SKILL.md
```

对应固定 CLI：`@openai/codex@0.143.0`。禁止改用当前会话内建 imagegen 或
其他未确认模型。

工作顺序：

1. 读取 `ART_DIRECTION.md`、模块规范、组件合同、tracker 和参考图授权。
2. 把用户需求重写为可执行、可验收的专业提示词，保存到
   `prompts/<module>/`。
3. 用户确认提示词后，把该提示词正文原样传给 `$imagegen`；调用技能时不再
   二次润色或改写。
4. 所有 `-i` 输入使用绝对路径，并在执行说明中声明 Image 1、Image 2 等
   参考职责。
5. 原始结果只写入 `generated/<module>/<version>/`。

这同时满足项目“先专业转译”和 imagegen 技能“执行时保持提示词原文”的要求。

## Generate → Review 编排 Skill

所有组件资产的准备、生成、审查、修订、退回、接受、源资产晋级和 runtime
导出，统一由仓库内
[`run-aeui-asset-workflow`](../.codex/skills/run-aeui-asset-workflow/SKILL.md)
编排。它负责生命周期与仓库同步；实际生图仍只由固定
[`imagegen-0-143-0`](../.codex/skills/imagegen-0-143-0/SKILL.md) 执行。

编排子状态为：

```text
contract-draft
  → prompt-draft
  → prompt-authorized
  → candidate-raw
  → candidate-reviewed
  → source-accepted
  → runtime-exported
  → game-validated
  → closure-planned
  → component-closed
```

其中 `prompt-authorized`、`candidate-raw` 和 `candidate-reviewed` 都最多属于
`P3`；只有用户明确接受具体候选后才进入 `P4`。候选被内部或用户退回时，保留
原提示词、执行记录与失败原因，创建新版本，不覆盖已执行正文，也不产生 tracked
source／runtime。`game-validated` 为 `P6` 实机验收；完成终态清理后才进入
`P6-C / component-closed`。

审查顺序必须是：

1. 范围与真实对象身份。
2. 语义、物理结构、观察方向与可运动空间。
3. 透视、图层、轮廓和真实 z-order 重组。
4. 香草结构与跨模块美术一致性。
5. 对象／状态数量、点击与文字安全区、裁切和拉伸合同。
6. 最小／基准／最大尺寸装配。
7. 尺寸、SHA-256、Alpha、色键残留和 atlas 边距。
8. 用户视觉复审。

Alpha、尺寸、色键清理和连通区只能证明技术性质，不能证明书籍能翻页、部件
属于正确图层、按钮对应真实对象或美术已经符合香草魔兽。结构失败时先退回，
不以透明化、锐化或追加装饰掩盖错误。

完整状态机、审查表、同步矩阵与记录模板由该 Skill 的 `references/` 维护；
本文件继续作为仓库层面的权威制度。

## 提示词文件必须包含

- 模块、组件 ID、版本、状态。
- 固定执行器 `imagegen-0-143-0`。
- 生成还是修图。
- 目标逻辑对象及精确数量。
- 参考图列表与单一职责。
- 风格基线的必要摘录。
- 运行时尺寸、源画布和透明方式。
- 状态差异、文字安全区和可拉伸区域。
- 禁止项。
- 输出验收标准。
- 生成结果、确认结果和最终源资产路径。
- 固定执行器会话／结果 ID，以及执行器实际报告的 revised prompt（若存在）。
- 内部失败重试、结构审查结论和下一道门禁。

高层视觉原型提示词必须标注 `prototype-only`，不得被 runtime 脚本直接使用。

## 透明与导出

- 优先要求真透明 RGBA。
- 模型不能稳定输出透明时，使用完全均匀的 `#00FF00` 色键背景。
- 色键转 Alpha 必须由确定性脚本完成，不能用第二轮自由重绘掩盖错误。
- 运行时使用 32 位 TGA、2 的幂画布和至少 4px UV 防渗色边距。
- 只允许拉伸中央纸面、横／竖边中段和控件中央段。
- 端帽、铆钉、缝线、缺口、书页角和符号不得拉伸。

## `P6-C` 完成后收口

`P6` 表示组件已经通过 Turtle WoW 实机验收，但仓库仍可能包含生产过程材料。
每个组件在完全验收后必须经过固定收口节点：

1. 验证最终 prompt／provenance、accepted source／manifest、确定性 exporter、
   runtime／manifest、实现、测试和 P6 证据均完整。
2. 生成组件级精确保留／删除清单，审计共享引用，并取得用户对删除范围的明确
   确认。
3. 清理该组件在 `generated/` 中的 raw、失败候选、透明中间图、预演、debug
   和临时 atlas。
4. 在必要失败结论已经压缩进最终规范／manifest／tracker 后，从当前树移除
   superseded prompt、实验脚本、故障参考和重复过程叙述；历史继续由 Git
   保留。
5. 只保留最终 prompt、source、manifest、exporter、runtime、实现、测试、
   最终组件合同和最小实机证据。
6. 运行链接、manifest、静态和模块 smoke test；同一独立清理提交中把 tracker
   标记为 `P6-C`，下一步置为“已关闭”。

不得在 `P6` 前执行收口，也不得对模块根目录、`assets/`、`prompts/` 或仓库根
使用宽泛递归删除。共享资产、公共工具、锁定基准、第三方来源、许可证和用户
原始文件不属于组件清理范围。

## 验收与登记

每次状态变化必须在同一提交中更新
[`OVERHAUL_TRACKER.md`](implementation/OVERHAUL_TRACKER.md)：

- 源资产路径。
- 原始执行提示词路径。
- runtime 文件与 Lua/XML 路径。
- 当前阶段和最后验证日期。
- 下一道验收门。

只有完成源图检查、确定性导出、静态测试、三种尺寸预演和游戏内验证后，组件
才可标记为 `P6`；完成精确收口、清理和复测后，仓库状态才可标记为 `P6-C`。
