# Generate → Review 状态机

主模块阶段以 `docs/PROGRESS.md` 为准，组件阶段以
`docs/modules/<module>/PROGRESS.md` 为准。本表增加同一 `P3` 内部的生产
子状态，防止“已经生图”“技术检查通过”和“用户接受源资产”被混为一谈。

## 子状态

| 子状态 | 项目阶段 | 必备证据 | 允许写入 | 下一门禁 |
|---|---:|---|---|---|
| `contract-draft` | `P0–P2` | 真实对象映射尚未完整 | 模块 `SUBMODULES.md`、`PROGRESS.md`、组件 work | 补齐组件合同 |
| `prompt-draft` | `P1–P2` | 完整合同；锁定图到基线 Prompt 的 provenance；美术继承与冲突表；自包含生产正文完整性预检通过；`production-draft` | 单一组件 work、模块进度 | 用户授权具体版本 |
| `prompt-authorized` | `P3` | 用户看到并明确确认具体版本执行正文、不可变修复边界与五次调用预算；授权版本已提交 | work、模块进度 | 固定执行器第 1 次生图 |
| `candidate-raw` | `P3` | 尝试编号、raw 路径、执行器与会话记录 | 被忽略的 `generated/`；work 执行记录 | 本次完整内部审查 |
| `repair-prepared` | `P3` | 前次失败门禁、保留区域、完整 `.rN` 修复正文、边界复核、累计调用少于 5 次 | 同一 work 与 Git 历史 | 固定执行器下一次调用 |
| `candidate-reviewed` | `P3` | 语义、结构、风格、装配和技术证据；`100%` runtime 尺寸、真实对象数量、现实信息密度和当前 accepted/runtime UI 的真实排版预演 | 被忽略的预演；review 记录 | 用户视觉复审 |
| `candidate-rejected` | 不晋级 | 用户否决，或第 5 次内部审查仍失败；日期与具体失败门禁 | work 尝试摘要、模块进度 | 用户审核后新版本或停止 |
| `source-accepted` | `P4` | 用户明确接受具体候选 | `assets/source/`、manifest | runtime 合同与导出 |
| `runtime-exported` | `P5` | 确定性导出、UV/manifest、Lua/XML、静态测试 | addon runtime、工具、文档 | 目标客户端实机 |
| `game-validated` | `P6` | Turtle WoW `1.18.1` 场景截图与交互证据 | 模块进度的验收记录 | 收口清单 |
| `closure-planned` | `P6` | 最终保留集、精确删除集与共享依赖审计 | work 内临时计划 | 用户确认后执行清理与复测 |
| `component-closed` | `P6-C` | work 与中间产物已清理；最终路径、链接与测试通过 | 四份模块长期文档、manifest 与最终产物 | 终态 |

## 合法转换

```text
contract-draft
  → prompt-draft
  → prompt-authorized
  → candidate-raw (attempt 1)
  → candidate-reviewed
  → source-accepted
  → runtime-exported
  → game-validated
  → closure-planned
  → component-closed
```

以下是回路而非晋级：

```text
candidate-raw (attempt 1–4)
  → internal failure
  → repair-prepared (.rN, same authorized envelope)
  → candidate-raw (next attempt)
candidate-raw (attempt 5)
  → internal failure
  → candidate-rejected / repair-budget-exhausted
candidate-reviewed → user rejection → candidate-rejected → new prompt version
runtime-exported → static/game failure → corrected exporter/runtime, remain P4/P5
```

一个明确授权的执行正文最多进入固定执行器 `5` 次，含首次生成。计数在调用
前递增；传输失败、提示词截断、执行器错误和不可用输出同样占用一次。任何
尝试通过全部内部门禁后立即结束循环，不消耗剩余次数。

## 不可跨越的门禁

- `prompt-draft → prompt-authorized`：必须先验证锁定视觉基准、对应原始提示词、
  组件级继承条款、权威冲突结论和自包含生产正文完整性预检全部通过，再由
  用户看过执行正文后授权具体提示词版本、不可变修复边界和五次调用预算。
  完整性按适用约束判定，不按字数判定；“继续”或“下一步”本身不构成生图
  授权。
- `candidate-raw → repair-prepared`：只允许在同一授权边界内修正。新增对象、
  状态、参考职责、外部输入、视觉方向、画布／runtime 合同或禁止项变化必须
  停止循环并退回 `prompt-draft`。
- `repair-prepared → candidate-raw`：前次执行正文、会话、输出、完整审查和
  下一份 `.rN` 修复正文必须已写入同一 work 并提交；不得复用相同正文进行
  无差别抽卡。
- `candidate-raw → candidate-reviewed`：必须先过语义／物理结构审查；技术指标
  不能替代这一门，且本次必须通过完整审查清单。每个 generate／edit 输出还
  必须有 `100%` runtime 尺寸、真实对象数量、现实信息密度、实际层序和当前
  accepted/runtime UI 的真实排版预演；稀疏样例与 contact sheet 不构成该
  门禁证据。
- `candidate-reviewed → source-accepted`：必须由用户明确接受具体候选。
- `source-accepted → runtime-exported`：必须已知真实 Frame 几何、切片、UV、
  安全区、拉伸规则和状态映射。
- `runtime-exported → game-validated`：必须有目标客户端证据。
- `game-validated → closure-planned`：必须验证最终 source、prompt、
  manifest、runtime、实现和 P6 证据，并列出精确保留／删除清单。
- `closure-planned → component-closed`：必须获得用户对清单的明确确认，完成
  清理、链接检查和全量相关测试；不得用通配符删除共享目录。

## 版本规则

1. 执行前必须提交 work 文件；执行过的正文不可在未形成 Git 历史的情况下
   原地覆盖。
2. 授权正文的首次调用使用原版本；同一修复边界内的自主尝试使用
   `<authorized-version>.r1` 至 `.r4`，不需要逐次用户授权，但每份修复
   正文都必须完整、自包含，不能只写相对上一版的差异，并在执行前提交。
3. 改变对象数量、物件身份、布局、透视、层序、参考职责、画布、验收标准或
   外部输入时，结束循环并创建需用户授权的新主版本或次版本。
4. 每次内部失败都要记录固定执行器会话、结果 ID、输出 SHA、第一失败门禁、
   保留区域、修复决定，以及执行器实际报告的 revised prompt（若存在）。
5. 第 5 次仍失败时才把内部循环标为
   `candidate-rejected / repair-budget-exhausted` 并等待用户审核；当前树
   不为每次尝试保留独立 Markdown。
6. 被拒候选不会因为已有透明背景、正确尺寸或干净色键而自动恢复资格。
7. “接受整体风格”不等于接受每个组件源资产；接受必须指向明确批次和版本。
8. 活跃生产期间在 work 尝试表保留失败结论；完整正文由 Git 历史保存。
   `P6-C` 时把最终 provenance 凝结到子模块基线与 manifest，然后删除 work。
9. `assets/source/` 中的派生母版不能在新提示词中被提升为高于
   `assets/locked/` 与其原始提示词 provenance 的视觉权威；发现权威倒置时
   必须退回 `prompt-draft`。
