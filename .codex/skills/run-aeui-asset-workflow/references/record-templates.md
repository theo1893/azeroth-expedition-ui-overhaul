# 生产与审查记录模板

模板用于保证字段齐全；可按模块调整标题，但不要改变已执行提示词正文。

## 组件 work 文件

路径固定为
`docs/modules/<module>/work/<COMPONENT-OR-BATCH>.md`。同一未完成组件只保留
一份 work；每次执行前先提交，失败版本的完整正文由 Git 历史保存。

```markdown
# <模块／批次> <版本>

## 元数据

- 模块：
- 组件 ID：
- 版本：
- 子状态：prompt-draft | prompt-authorized | candidate-raw |
  repair-prepared | candidate-reviewed | candidate-rejected | source-accepted |
  closure-planned | component-closed
- 项目阶段：P0–P6-C
- 固定执行器：imagegen-0-143-0 / @openai/codex@0.143.0
- 操作：generate | edit
- 自动修复预算：最多 5 次固定执行器调用，含首次
- 当前尝试：0/5
- 多执行正文最坏总调用数：
- 锁定视觉基准：
  - Image 1：<assets/locked 仓库路径> — <最高视觉职责>
- 基准提示词 provenance：
  - <模块 ART_BASELINE／SUBMODULE_ART_BASELINES 路径> — <对应哪张锁定基准及其语义职责>
- 次级参考：
  - Image 2：<source/reference 仓库路径> — <受限职责；不得覆盖锁定基准>
- raw：
- 透明候选：
- 重组预演：
- 最终 source：

## 美术基准继承

### 权威顺序

1. <锁定图 + 对应原始提示词>
2. <模块 ART_BASELINE.md／SUBMODULE_ART_BASELINES.md>
3. <docs/GLOBAL_ART_BASELINE.md>
4. <模块 SUBMODULES.md：对象／几何／状态／禁止烘焙>
5. <接受 source 或结构参考的受限职责>

### 必须继承的视觉 DNA

- <物件身份、香草时代轮廓、笔触、材料关系、配色、光照、磨损尺度>

### 本批组件级转译

- <把完整原型语言转译到本批每个逻辑对象的方式>

### 明确不继承

- <属于其他 runtime 对象的按钮、文字、书签、滚动条、装饰或完整布局>

### 冲突审计

- <冲突来源 A / 来源 B / 裁决 / 写入执行正文的约束>

## 组件合同

- 逻辑对象与数量：
- 每个对象状态：
- pfUI／Blizzard／provider 映射：
- runtime 尺寸：
- 源画布与排布：
- 文字／图标安全区：
- 拉伸、裁切、UV：
- Alpha 或色键：
- 禁止烘焙：
- 验收预演与回退：

## 生产正文完整性预检

- 复杂度：single-object | states | atlas | assembly／repeat／stretch
- 结论：pass | blocked

| 门禁 | 执行正文中的证据 | 结论 |
|---|---|---|
| 物件身份、精确范围、对象／状态数量与动态内容排除 | <正文段落摘要> | pass／blocked |
| 每张输入图的 inherit／ignore 职责与权威冲突 | <正文段落摘要> | pass／blocked |
| 画布、格位、边距、方向、透视、尺度、光照与层序 | <正文段落摘要> | pass／blocked |
| 逐对象形态、材料、边缘、状态与相互关系 | <正文段落摘要> | pass／blocked |
| 文字／图标安全区、裁切、拉伸、平铺、重复与接缝 | <正文段落摘要或 N/A 原因> | pass／blocked |
| 美术 DNA、具体反模式、Alpha／色键与最终自检 | <正文段落摘要> | pass／blocked |

- 未知但执行必需的值：<无；或返回组件合同，不得猜测>
- 去冗余结论：<保留哪些高风险重复；删除哪些无约束力的形容词／过程历史>

## 最终执行正文

<用户确认后原样交给固定执行器的正文>

## 自主修复循环

- 不可变修复边界：<组件 ID、对象／状态数量、权威顺序、参考职责、画布、
  runtime 几何、Alpha、禁止烘焙>
- 允许的自主修复：<可改变的构图／结构／材料措辞；edit 或 regenerate；
  是否允许把同一循环前次输出作为 edit 输入>
- 必须重新授权：<新增参考／上传、对象、状态、视觉方向、画布、provider 或
  其他合同变化>

| 尝试 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `<version>` / `<commit>` | generate |  |  |  |  |  |
| 2/5 | `<version>.r1` / `<commit>` | edit／generate |  |  |  |  |  |

每次固定执行器调用前先递增尝试号。调用失败、提示词截断和不可用输出也占用
一次。第 1–4 次失败后，先把本行和下一份完整 `.rN` 正文提交，再继续；第 5
次失败后停止并记录 `repair-budget-exhausted`。任何一次完整内审通过后立即
停止，不使用剩余次数。

## 执行记录

- 日期：
- 会话／结果 ID：
- 实际输入绝对路径与职责：
- imagegen 报告的 revised prompt：
- 输出尺寸／模式／SHA-256：
- Alpha／残色：
- 调用次数：
- 循环终态：candidate-reviewed | repair-budget-exhausted |
  authority-blocked

## 审查记录

- 语义／物理：
- 透视／图层：
- 美术一致性：
- 对象／状态合同：
- 装配／尺寸：
- 技术像素：
- 结论：
- 用户结论与日期：
- 下一门禁：

## 尝试摘要

| 版本 | 执行／审查证据 | 结论 | 下一版必须改变 |
|---|---|---|---|
| <Vn> | <commit、session、result、hash> | <accepted/rejected> | <具体结构或美术条款> |
```

`## 美术基准继承` 不是内部笔记。它必须链接锁定基准的真实 prompt
provenance，并且“必须继承”和“冲突裁决”的实质内容必须出现在最终执行正文
中。只写“参考 Image 1 风格”“保持统一”或把派生 source 称为“最高权威”
均不合格。

`## 生产正文完整性预检` 不以字数判定。所有适用门禁都必须能指向最终执行
正文中的明确条款；不适用项要写出原因，执行必需但未知的值会阻塞生产。
`.rN` 必须重新形成完整、自包含正文，不能只记录相对上一版的差异。

若 `revised prompt` 很长，仍放在同一 work 文件的折叠或附录段；不要为它新增
永久 Markdown。不能只写“模型自动优化”。

## 退回记录

```markdown
- 结论：candidate-rejected
- 否决人：internal-review | user
- 日期：
- 尝试次数：<n>/5
- 循环终态：repair-budget-exhausted | user-rejected | authority-blocked
- 第一个失败门禁：
- 可观察证据：
- 本版本保留内容：
- 下一版本必须改变：
- 本版本无 tracked source／runtime：
```

## 用户复审摘要

```markdown
- 批次／版本：
- 当前状态：candidate-reviewed / P3
- 已通过：<结构、装配、技术等>
- 请重点确认：<综合色感或具体物件语义>
- 若接受：晋级 P4，仅加入透明 source 与 manifest
- 尚未发生：runtime 切片、Lua/XML 接入、Turtle WoW 实机验证
```

## `P6-C` 收口计划

先用本模板向用户展示，临时写入现有 work，不创建新的收口文档。执行后只把
精简结果写入 `SUBMODULES.md`、`SUBMODULE_ART_BASELINES.md`、模块
`PROGRESS.md` 和最终 manifest，并删除 work。

```markdown
- 组件 ID：
- P6 实机证据：
- 最终保留：
  - final prompt/provenance：
  - accepted source/manifest：
  - exporter/runtime/manifest：
  - implementation/tests：
- 明确删除：
  - ignored generated：
  - component work：
  - obsolete references/tools/previews：
  - duplicated process narration：
- 排除清理的共享依赖：
- 用户确认：
- 清理后链接与测试：
- 关闭日期与状态：P6-C / component-closed
```
