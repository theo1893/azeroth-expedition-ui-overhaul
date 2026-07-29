# Generate → Review 状态机

项目阶段仍以 `docs/implementation/OVERHAUL_TRACKER.md` 的 `P0–P6-C` 为准。本表
增加的是同一 `P3` 内部的生产子状态，防止“已经生图”“技术检查通过”和
“用户接受源资产”被混为一谈。

## 子状态

| 子状态 | 项目阶段 | 必备证据 | 允许写入 | 下一门禁 |
|---|---:|---|---|---|
| `contract-draft` | `P0–P2` | 真实对象映射尚未完整 | 组件规范、tracker | 补齐组件合同 |
| `prompt-draft` | `P1–P2` | 完整合同；`production-draft` | 版本化提示词、规范、tracker | 用户授权具体版本 |
| `prompt-authorized` | `P3` | 用户确认执行正文；状态 `production` | 提示词、tracker | 固定执行器生图 |
| `candidate-raw` | `P3` | raw 路径、执行器与会话记录 | 被忽略的 `generated/`；执行记录 | 内部结构审查 |
| `candidate-reviewed` | `P3` | 语义、结构、风格、装配和技术证据 | 被忽略的预演；review 记录 | 用户视觉复审 |
| `candidate-rejected` | 不晋级 | 否决人、日期、具体失败门禁 | 原提示词和 tracker 的失败记录 | 新版本或停止 |
| `source-accepted` | `P4` | 用户明确接受具体候选 | `assets/source/`、manifest | runtime 合同与导出 |
| `runtime-exported` | `P5` | 确定性导出、UV/manifest、Lua/XML、静态测试 | addon runtime、工具、文档 | 目标客户端实机 |
| `game-validated` | `P6` | Turtle WoW `1.18.1` 场景截图与交互证据 | tracker 验收记录 | 收口清单 |
| `closure-planned` | `P6` | 最终保留集、精确删除集与共享依赖审计 | 临时计划；必要的 tracker 待办 | 用户确认后执行清理与复测 |
| `component-closed` | `P6-C` | 中间产物已清理；最终路径、链接与测试通过 | 精简后的规范、manifest、tracker 与最终产物 | 终态 |

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

- `prompt-draft → prompt-authorized`：必须由用户授权具体提示词版本。
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

1. 执行过的提示词正文不可原地覆盖。
2. 改变对象数量、物件身份、布局、透视、层序、参考职责、画布或验收标准时，
   创建新的主版本或次版本。
3. 只更正执行记录、路径或校验值且不改变正文时，可以在原文件中补记。
4. 内部失败也要记录：保存固定执行器会话、结果 ID、失败原因，以及执行器
   实际报告的 revised prompt（若存在）。
5. 被拒候选不会因为已有透明背景、正确尺寸或干净色键而自动恢复资格。
6. “接受整体风格”不等于接受每个组件源资产；接受必须指向明确批次和版本。
7. 活跃生产期间保留失败版本；`P6-C` 收口时可从当前树删除已被最终 provenance
   概括的旧版本，完整历史由 Git 保存。
