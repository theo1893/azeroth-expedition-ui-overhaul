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
- 子状态：prompt-draft | simulation-reviewed | simulation-confirmed |
  prompt-authorized | candidate-raw | repair-prepared |
  candidate-reviewed | candidate-rejected | source-accepted | closure-planned |
  component-closed | module-closure-planned | module-closed
- 项目阶段：P0–P6-C
- 固定执行器：imagegen-0-143-0 / @openai/codex@0.143.0
- 操作：simulate | generate | edit
- 生成前模拟版本：
- 生成前模拟方式：deterministic-local-geometry
- 模拟 ImageGen：0/0
- 模拟脚本／specification：
- 本地渲染错误：0
- 模拟路径／SHA：
- 模拟用户结论：pending | confirmed | rejected
- 自动修复预算：最多 5 次实际 ImageGen 生图／修图，含首次
- 当前实际生图：0/5
- 流程错误：0（无候选且无 provider 生成证据，不占生图额度）
- 多执行正文最坏实际生图数：
- 锁定视觉基准：
  - Image 1：<assets/locked 仓库路径> — <最高视觉职责>
- 基准提示词 provenance：
  - <模块 ART_BASELINE／SUBMODULE_ART_BASELINES 路径> — <对应哪张锁定基准及其语义职责>
- 次级参考：
  - Image 2：<source/reference 仓库路径> — <受限职责；不得覆盖锁定基准>
- raw：
- 透明候选：
- 重组预演：
- 真实排版预演：<100% runtime 尺寸；当前 accepted/runtime UI；真实对象
  数量与现实信息密度；路径／SHA；权威与非权威范围>
- 实际展示区域合同／报告：<合同路径；报告路径／SHA；空／最小／典型／最大
  与支持模式；pass／display-region-blocked；首个失败码>
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
- 真实排版预演：<目标 Frame 几何、实际重复数量、代表性动态内容、状态分布、
  z-order、裁切；未完成相邻组件使用真实 fallback 或显式非权威占位>
- 实际展示区域：<source/atlas 可见区、UV、装饰端帽、安静区、live 可见区、
  命中盒；Frame 必须来自 provider 公式，不能使用人工固定高度>

## 生成前模拟实例图

### 模拟合同

- 版本：
- 目标场景与 Frame 真实比例：
- 当前 accepted/runtime 邻接 UI：
- 真实对象数量与代表性信息密度：
- 目标层序与交互状态：
- 用户需要确认：<布局、物件隐喻、材质层级、轮廓、配色、视觉重量、整合>
- 刻意简化且非权威：<Alpha、接缝、切片、独立状态、微纹理等>
- 禁止用途：不得作为 source/runtime、不得裁切／切片／晋级、不得作为生产
  edit/reference 输入

### 本地模拟规格

- 只读参考及职责：
- 上传范围：无；不得上传
- specification 版本：
- 几何 primitives 与平面配色角色：
- 真实排版数据：
- ImageGen：0/0
- 本地脚本／命令：
- Python 解释器：

### 模拟规格正文

<只用于本地几何预演的完整规格；与正式资产 ImageGen 正文分开>

### 模拟执行与内部检查

- 本地脚本／specification：
- 输出路径／SHA：
- ImageGen：0/0
- 本地渲染错误：0
- 真实 Frame 比例／屏幕位置：
- 邻接 UI／对象数量／信息密度：
- 物件隐喻／材质／配色／重量：
- 非权威简化说明：
- 内部结论：displayable | blocked

| 本地渲染错误 | specification 版本 | 命令 | 错误 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| SE1 | `<simulation-version>` |  |  |  | 不涉及 ImageGen |

### 用户方向结论

- 具体模拟版本：
- 用户结论与日期：pending | confirmed | rejected
- 确认并写回生产正文的可见条款：
- 拒绝时必须改变：
- 确认失效条件：可见布局、物件隐喻、材质层级、配色、综合色重或整合关系
  发生实质变化
- 下一门禁：新本地模拟版本 | 最终生产正文授权

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

| 实际生图 | 正文版本／执行前 commit | 操作 | session／result | 输出／SHA | 第一失败门禁 | 保留区域与下一步 | 结论 |
|---:|---|---|---|---|---|---|---|
| 1/5 | `<version>` / `<commit>` | generate |  |  |  |  |  |
| 2/5 | `<version>.r1` / `<commit>` | edit／generate |  |  |  |  |  |

只有候选图或 provider result 证明生成确已执行时才递增实际生图号；不可用
候选仍计数。无候选且无生成证据的流程错误写入下表，不占 `0/5`，修复后使用
同一正文重试。第 1–4 个候选失败后，先把本行和下一份完整 `.rN` 正文提交，
再继续；第 5 个候选失败后停止并记录 `repair-budget-exhausted`。任何一次
完整内审通过后立即停止。

| 流程错误 | 正文版本／commit | session | 错误与无生成证据 | 针对性修复 | 结论 |
|---:|---|---|---|---|---|
| E1 | `<version>` / `<commit>` |  |  |  | 不占生图额度 |

## 执行记录

- 日期：
- 会话／结果 ID：
- 实际输入绝对路径与职责：
- imagegen 报告的 revised prompt：
- 输出尺寸／模式／SHA-256：
- Alpha／残色：
- 实际生图次数：
- 流程错误次数：
- 循环终态：candidate-reviewed | repair-budget-exhausted |
  authority-blocked

## 审查记录

- 语义／物理：
- 透视／图层：
- 美术一致性：
- 对象／状态合同：
- 装配／尺寸：
- 真实排版：<100% runtime 尺寸、真实对象数量、现实信息密度、当前新 UI、
  预演路径／SHA、占位的非权威范围>
- 实际展示区域：<合同／报告路径与 SHA；场景；frame coverage 与 content／
  interaction conformance；第一失败区域>
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

`## 生成前模拟实例图` 只承担生产前方向确认。必须记录本地几何 specification、
脚本命令、ImageGen `0/0`、输出证据、非权威范围和用户对具体版本的结论。
确认结果要转写为生产正文中的可验证条款；模拟像素本身永远不能成为源资产、
runtime 或生产输入。生成前模拟不能代替正式候选生成后的 `100%` runtime
真实排版预演。

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

## P5 插件接入记录

同一组件 work 在 P4→P5 时追加本节；模块 `PROGRESS.md` 只凝结最终路径和
结论。Atlas 存在或 Lua smoke 通过都不能省略 fresh-checkout package 证据。

```markdown
- 状态：runtime-exported / P5 | P4/P5 blocked
- deployable addon 目录：
  - addon/pfUI
  - addon/AzerothExpeditionUI
- runtime 媒体／manifest／SHA：
- adapter：<addon 内文件、真实对象、状态／UV>
- provider／pfUI bridge：<addon 内文件、保留功能、作用域>
- TOC／XML／bootstrap：<入口、顺序、依赖>
- fallback：
- 运行时外部依赖审查：不得引用 assets/source、generated、tools、绝对路径、
  未跟踪文件、软链接或 Junction
- addon package validator：
  - 命令：
  - 报告：generated/<module>/<batch>/addon-package-report.json
  - schema：aeui-addon-package-report-v1
  - status：pass | fail
  - first violation：
  - build_required_on_target_device：false
- 组件 smoke／repository contract：
- 目标设备操作：git pull 后只复制上述 addon 目录到 Interface/AddOns；不生成、
  不导出、不打 patch、不修改 Lua/pfUI
- 尚未发生：Turtle WoW /reload 与交互 P6
```

## 单组件 `P6-C` 收口计划

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

## 整模块 `P6-C` 终局收口

用户明确验收冻结的整模块 P6 范围后使用。本计划可临时写入任一现存 work；
执行后删除全部模块 work，只把下面的稳定结论凝结到模块 `PROGRESS.md`、其余
三份长期模块文档和最终 manifests。整模块验收已构成 verified module-only
中间数据的 standing cleanup authorization，不再请求第二次批准。

```markdown
- 模块：
- 模块验收范围：<逐组件／明确排除项；范围内均 P6 或 component-closed>
- 整模块 P6 验收人／日期：
- P6 实机证据：
  - <迁出 generated 后的 assets/references/<module>/p6/ 路径／SHA／场景>
- 最终保留：
  - 四份长期模块文档：
  - accepted source／manifest：
  - deterministic exporter／runtime／implementation／tests：
  - licenses／user originals／shared dependencies：
- 全量删除：
  - canonical generated：generated/<module>/（整个根；tracked + ignored）
  - module work：docs/modules/<module>/work/（全部内容和目录）
  - legacy generated aliases：
  - exact legacy generated paths：
  - obsolete module-only references／tools／caches／previews：
  - duplicated process narration／stale generated references：
- 保护且排除清理的共享／归属不明路径：
- 授权依据：explicit whole-module P6 acceptance + standing project cleanup rule
- module closure validator：
  - 命令：<validate_module_closure.py；列出全部 --generated-alias 和
    --legacy-generated-path>
  - 临时报告：<generated/<module>/ 之外的临时路径；提交前删除>
  - schema：aeui-module-closure-report-v1
  - status：pass | fail
  - first violation：
- fresh-checkout addon package／runtime tests／repository tests／links／diff-check：
- 模块 PROGRESS 最终标记：P6-C / module-closed
- 独立清理 commit：
```
