# Generate → Review 状态机

主模块阶段以 `docs/PROGRESS.md` 为准，组件阶段以
`docs/modules/<module>/PROGRESS.md` 为准。本表增加同一 `P3` 内部的生产
子状态，防止“已经生图”“技术检查通过”和“用户接受源资产”被混为一谈。

## 子状态

| 子状态 | 项目阶段 | 必备证据 | 允许写入 | 下一门禁 |
|---|---:|---|---|---|
| `contract-draft` | `P0–P2` | 真实对象映射尚未完整 | 模块 `SUBMODULES.md`、`PROGRESS.md`、组件 work | 补齐组件合同 |
| `prompt-draft` | `P1–P2` | 完整合同；锁定图到基线 Prompt 的 provenance；美术继承与冲突表；`production-draft` | 单一组件 work、模块进度 | 用户授权具体版本 |
| `prompt-authorized` | `P3` | 用户看到并明确确认具体版本执行正文；授权版本已提交 | work、模块进度 | 固定执行器生图 |
| `candidate-raw` | `P3` | raw 路径、执行器与会话记录 | 被忽略的 `generated/`；work 执行记录 | 内部结构审查 |
| `candidate-reviewed` | `P3` | 语义、结构、风格、装配和技术证据 | 被忽略的预演；review 记录 | 用户视觉复审 |
| `candidate-rejected` | 不晋级 | 否决人、日期、具体失败门禁 | work 尝试摘要、模块进度 | 新版本或停止 |
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
  → candidate-raw
  → candidate-reviewed
  → source-accepted
  → runtime-exported
  → game-validated
  → closure-planned
  → component-closed
```

以下是回路而非晋级：

```text
candidate-raw → internal failure → new prompt/edit version
candidate-reviewed → user rejection → candidate-rejected → new prompt version
runtime-exported → static/game failure → corrected exporter/runtime, remain P4/P5
```

## 不可跨越的门禁

- `prompt-draft → prompt-authorized`：必须先验证锁定视觉基准、对应原始提示词、
  组件级继承条款和权威冲突结论完整，再由用户看过执行正文后授权具体提示词
  版本。“继续”或“下一步”本身不构成生图授权。
- `candidate-raw → candidate-reviewed`：必须先过语义／物理结构审查；技术指标
  不能替代这一门。
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
2. 改变对象数量、物件身份、布局、透视、层序、参考职责、画布或验收标准时，
   创建新的主版本或次版本。
3. 拒绝后先提交执行与审查记录，再在同一 work 文件中升级当前版本；当前树
   不为每次尝试保留独立 Markdown。
4. 内部失败也要记录：保存固定执行器会话、结果 ID、失败原因，以及执行器
   实际报告的 revised prompt（若存在）。
5. 被拒候选不会因为已有透明背景、正确尺寸或干净色键而自动恢复资格。
6. “接受整体风格”不等于接受每个组件源资产；接受必须指向明确批次和版本。
7. 活跃生产期间在 work 尝试表保留失败结论；完整正文由 Git 历史保存。
   `P6-C` 时把最终 provenance 凝结到子模块基线与 manifest，然后删除 work。
8. `assets/source/` 中的派生母版不能在新提示词中被提升为高于
   `assets/locked/` 与其原始提示词 provenance 的视觉权威；发现权威倒置时
   必须退回 `prompt-draft`。
