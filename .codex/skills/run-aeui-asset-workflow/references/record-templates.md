# 生产与审查记录模板

模板用于保证字段齐全；可按模块调整标题，但不要改变已执行提示词正文。

## 生产提示词文件

```markdown
# <模块／批次> <版本>

## 元数据

- 模块：
- 组件 ID：
- 版本：
- 子状态：prompt-draft | prompt-authorized | candidate-raw |
  candidate-reviewed | candidate-rejected | source-accepted |
  closure-planned | component-closed
- 项目阶段：P0–P6-C
- 固定执行器：imagegen-0-143-0 / @openai/codex@0.143.0
- 操作：generate | edit
- 锁定视觉基准：
  - Image 1：<assets/locked 仓库路径> — <最高视觉职责>
- 基准提示词 provenance：
  - <prompts 仓库路径> — <对应哪张锁定基准及其语义职责>
- 次级参考：
  - Image 2：<source/reference 仓库路径> — <受限职责；不得覆盖锁定基准>
- raw：
- 透明候选：
- 重组预演：
- 最终 source：

## 美术基准继承

### 权威顺序

1. <锁定图 + 对应原始提示词>
2. <模块规范>
3. <ART_DIRECTION>
4. <组件合同：对象／几何／状态／禁止烘焙>
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

## 最终执行正文

<用户确认后原样交给固定执行器的正文>

## 执行记录

- 日期：
- 会话／结果 ID：
- 实际输入绝对路径与职责：
- imagegen 报告的 revised prompt：
- 输出尺寸／模式／SHA-256：
- Alpha／残色：
- 内部失败重试：

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
```

`## 美术基准继承` 不是内部笔记。它必须链接锁定基准的真实 prompt
provenance，并且“必须继承”和“冲突裁决”的实质内容必须出现在最终执行正文
中。只写“参考 Image 1 风格”“保持统一”或把派生 source 称为“最高权威”
均不合格。

若 `revised prompt` 很长，允许放在同目录的独立 provenance 文件并从这里链接；
不能只写“模型自动优化”。

## 退回记录

```markdown
- 结论：candidate-rejected
- 否决人：internal-review | user
- 日期：
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

先用本模板向用户展示，不创建永久的逐组件收口文档。执行后只把精简结果写入
tracker、最终 manifest 或组件规范。

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
  - superseded tracked prompts：
  - obsolete references/tools/previews：
  - duplicated process narration：
- 排除清理的共享依赖：
- 用户确认：
- 清理后链接与测试：
- 关闭日期与状态：P6-C / component-closed
```
