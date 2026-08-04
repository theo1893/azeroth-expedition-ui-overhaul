# 仓库同步与文档生命周期

本文件是项目资产工作流落到仓库的详细规则。普通项目文档不复制这些流程。

## 固定位置

| 内容 | 位置 | Git |
|---|---|---:|
| 全局美术 Prompt | `docs/GLOBAL_ART_BASELINE.md` | tracked |
| 主模块总览 | `docs/PROGRESS.md` | tracked |
| 真实子模块合同 | `docs/modules/<module>/SUBMODULES.md` | tracked |
| 主模块美术 Prompt | `docs/modules/<module>/ART_BASELINE.md` | tracked |
| 子模块稳定 Prompt | `docs/modules/<module>/SUBMODULE_ART_BASELINES.md` | tracked |
| 主模块详细状态 | `docs/modules/<module>/PROGRESS.md` | tracked |
| 未完成组件当前工作 | `docs/modules/<module>/work/<component>.md` | tracked until `P6-C` |
| 综合色感／结构锁定图 | `assets/locked/<module>/` | tracked |
| 结构／故障参考 | `assets/references/<module>/` | tracked only while required |
| 用户接受的透明母版 | `assets/source/<module>/<component>/` | tracked |
| 生成前模拟、raw、失败稿、透明候选、候选真实排版预演 | `generated/<module>/...` | ignored；整模块 `P6-C` 时整树删除 |
| 运行时媒体 | `addon/AzerothExpeditionUI/Media/<Module>/` | tracked |

`addon/` 只承载运行时文件与必须随包分发的许可证，不加入 Markdown。
仓库根 `README.md` 只介绍项目。文档索引与当前总体快照只放 `AGENTS.md`。
所有新中间产物必须进入 canonical `generated/<module>/`；不得再创建
`generated/chat_*`、`generated/verification/<module>-*` 等模块别名根。历史遗留
路径在模块终局收口时按明确所有权逐项删除。

## 四份长期模块文档

一个主模块启动时必须同时建立：

1. `SUBMODULES.md`：严格对齐 pfUI／Blizzard／provider 的全部真实对象。
2. `ART_BASELINE.md`：继承全局 Prompt 的主模块唯一美术 Prompt。
3. `SUBMODULE_ART_BASELINES.md`：每个已定义子模块的稳定 Prompt 条款。
4. `PROGRESS.md`：资产、代码、测试、阶段与下一门禁。

不得新增路线图、决策日志、审计报告、媒体清单、文档索引或独立
`prompts/` 树。法律、第三方 `SOURCE.md`、许可证、JSON manifest 与 Skill
references 不属于项目说明文档。

## 单一组件 work

同一未完成组件或紧密耦合批次只保留一个 work 文件。它同时包含：

- 当前版本与子状态；
- 锁定图与 Prompt provenance；
- 真实组件合同；
- 生成前本地几何模拟的规格、脚本命令、输出证据、用户结论与文字化的可见
  方向；
- 自包含生产正文的紧凑完整性预检；
- 当前可执行正文；
- 执行与审查记录；
- 紧凑尝试摘要；
- 下一门禁。

首次生产执行前先提交用户授权的 work，使精确生产正文进入 Git 历史。本地
模拟可在提交前确定性渲染，但必须在展示时把版本规格、脚本命令、输出 SHA 与
内审结论写回同一 work。自主修复循环中，每次失败后在同一文件补齐执行／审查
记录和下一份完整 `.rN` 修复正文，并在下一次调用前提交。不要为模拟版本、
V1、V2、V3、每次 attempt、review、audit、preview 或 revised prompt 分别
建立永久 Markdown。

## 生成前模拟同步

- 正式资产生成前必须先产生一个可供用户确认的模拟实例图。它沿用真实 Frame
  比例、当前 accepted/runtime 邻接 UI、代表性对象数量与信息密度，但可以
  简化 Alpha、接缝、切片、独立状态和微纹理。
- 模拟规格、目标场景、真实对象数量、状态分布、简单几何与平面配色角色必须
  写入同一组件 work。使用本地确定性脚本直接渲染，不需要逐版本执行授权。
- 每个模拟版本的实际 ImageGen 固定为 `0/0`；不得上传参考图或启动 provider，
  也没有独立生图预算。本地脚本错误只作为普通渲染错误记录。
- 模拟输出固定写入
  `generated/<module>/<batch>/simulation/<version>/`，并记录 specification、
  脚本命令、Python 解释器、路径、SHA、ImageGen `0/0`、本地错误和内部可读性
  结论；不得 commit 图片本身。
- 用户确认具体模拟版本后，把可见布局、材质层级、轮廓、配色、视觉重量、
  整合关系与交互状态观感写回 work 的生产正文，再请求独立的正式生产授权。
- 模拟确认只接受方向，不接受像素。模拟图不得复制到 `assets/source/`，
  不得裁切、切片、导出为 runtime，也不得作为正式资产的 edit/reference
  输入。可见方向实质变化时必须创建并重新确认新的模拟版本。

## 五次自主修复同步

- 一个用户明确授权的执行正文最多产生固定 ImageGen `5` 次实际生图／修图，
  含首次。多段独立执行正文必须在授权前分别列出预算和最坏实际生图数。
- 每次实际生图使用独立的 ignored attempt 路径，例如
  `generated/<module>/<batch>/<version>/attempt-01/`；不得覆盖前次 raw、
  candidate、Alpha 中间图或重组预演。
- 第 1 次使用已提交的授权正文。第 2–5 次只能使用同一修复边界内的完整
  `.rN` 正文；提交中同时保存前次失败记录和下次执行正文。
- work 的循环表必须记录实际生图序号、正文／commit、session／result、
  输出 SHA、第一失败门禁、保留区域、edit／regenerate 决定和结论。
- 没有候选图且没有 provider 生成证据的目录、权限、CLI、递归、传输、上传、
  连接或落盘错误进入独立流程错误表，不占实际生图次数；记录错误证据与
  针对性修复后，以同一已提交正文重试。同一错误修复一次后仍重复则暂停诊断，
  不得无限重试。
- 中间失败只更新 work；模块 `PROGRESS.md` 在内部通过、第五次耗尽或出现
  需要新授权的边界阻塞时再同步，避免复制五份流水。
- 内部通过只达到 `candidate-reviewed / P3`。第五次仍失败才达到
  `candidate-rejected / repair-budget-exhausted`。两种情况都不得自动创建
  tracked source、manifest 或 runtime。

## 按操作同步

| 操作 | 必须同步 | 禁止 |
|---|---|---|
| `prepare` | 组件 work、自包含正文完整性预检；必要时 `SUBMODULES.md` 与模块进度 | 写 raw、source 或 runtime |
| `simulate` | 本地几何规格、可复现脚本命令、ImageGen `0/0`、work 执行证据、内部检查与用户方向结论 | 调用 ImageGen／上传参考图；把模拟当 source/runtime/生产输入；未确认模拟就进入生产 |
| `generate` | 已提交的授权正文／`.rN` 修复正文；work 实际生图与流程错误记录 | 超过五次实际生图；commit raw／失败图／预演 |
| `review` | 每次尝试的 work 审查证据；真实 provider 尺寸的展示区域合同／报告路径与 SHA；循环终态同步模块进度 | 用像素指标替代视觉结论；用固定容量画布冒充实际 Frame |
| `revise` | 同一 work 的尝试表、完整 `.rN` 正文与边界复核 | 丢失旧版本 Git 证据；用修复名义改变合同 |
| `reject` | work 的版本、原因、日期、主体；模块进度 | 创建 source 或 runtime |
| `accept` | source、manifest、work、子模块基线、模块进度 | 把完整原型直接当 runtime |
| `export` | exporter、UV/crop manifest、runtime、Lua/XML/TOC、tests、最终 atlas／adapter／provider 的展示区域复查、fresh-checkout addon package 报告、模块进度 | 自由重绘确定性导出结果；以背景覆盖代替内容安全；把接入或补丁留给游戏设备 |
| `game-validate` | 模块进度的场景、版本、交互与结论 | 无实机证据标 `P6` |
| `close` | 精确保留／删除清单；四份长期文档与 manifest；组件或整模块清理提交；整模块关闭校验 | `P6` 前清理、遗留活跃 work 或删除共享／归属不明路径 |

主模块阶段变化时，同一提交同步 `docs/PROGRESS.md` 与 `AGENTS.md` 顶部快照。
只有跨模块美术基线真正改变时才更新 `docs/GLOBAL_ART_BASELINE.md`。

## P5 本机插件接入与跨设备可用门禁

`source-accepted` 之后的 export 必须在当前开发设备完成运行时接入，不得只交付
母版、TGA 或一段待移植代码。目标是让另一台设备从 fresh checkout／`git pull`
得到同一 `addon/` 后，无需继续开发即可直接安装：

1. 游戏实际加载的媒体只写入所属 addon，通常是
   `addon/AzerothExpeditionUI/Media/<Module>/`。`assets/source/`、`generated/`、
   `.codex/` 与 `tools/` 只服务开发和复现，Lua／XML／TOC 不得在运行时引用。
2. 同一提交完成 adapter、真实 provider／pfUI scoped bridge、状态／UV 映射、
   fallback、TOC／XML／bootstrap 加载顺序和组件 smoke；不能要求目标设备再
   应用 patch、复制单个临时文件或手工修改 pfUI。
3. `addon/` 内所有运行时文件必须进入 Git，不得使用未跟踪文件、被忽略产物、
   绝对本机路径、软链接、Junction 或 provider cache。路径大小写必须与磁盘和
   TOC／XML 完全一致，保证 Windows 客户端可直接加载。
4. runtime manifest 中指向 `addon/` 的每个文件必须存在并匹配 SHA-256；新增
   AEUI `Core/*.lua`／`Modules/*.lua` 必须进入 TOC。依赖 addon 必须随仓库提供，
   或在 handoff 中明确列入必须安装的已有依赖。
5. 在选定 OS 解释器下运行：

   ```text
   conda run -n py312 python \
     .codex/skills/run-aeui-asset-workflow/scripts/validate_addon_package.py \
     /absolute/path/to/repository \
     --report /absolute/path/to/generated/<module>/<batch>/addon-package-report.json
   ```

   macOS 必须仍使用 `py312`；其他系统遵守主 Skill 的解释器策略。报告 schema
   为 `aeui-addon-package-report-v1`，必须 `status=pass` 且
   `build_required_on_target_device=false`。

6. 当前 work 与模块 `PROGRESS.md` 记录：deployable addon 目录、媒体、adapter、
   provider bridge、TOC/bootstrap、fallback、manifest、验证命令和结果。handoff
   必须明确说明目标设备只需拉取并把这些目录放入 `Interface/AddOns`，以及仍需
   `/reload`／实机 P6 的部分。

任一项失败时仍停在 P4/P5 修正态；即使贴图、Lua smoke 或 display-region
单项通过，也不能称为 `runtime-exported`、跨设备已接入或远端可直接使用。

## `P6-C` 终态收口

`P6` 表示游戏内验收，`P6-C` 表示仓库完成收口。收口计划临时写在现有 work，
不创建新的 closure Markdown。单组件关闭和整模块关闭是两个不同终态。

### 单组件关闭

组件到达 P6 后，列出精确 keep/delete 清单并由用户明确确认；再删除该组件的
模拟、raw、失败候选、透明中间图、contact sheet、真实排版预演、debug／临时
atlas、该组件的 work 文件和仅服务该组件的过时引用／工具。凝结稳定事实并标记
`P6-C / component-closed`。其他未完成组件的 work 与中间数据不受影响。

### 整模块关闭

用户明确验收一个冻结的整模块 P6 范围后，必须立即进入模块终局清理；该验收
与本项目 standing rule 已构成 verified module-only 中间数据的删除授权，无需
再索取第二次批准。执行顺序固定为：

1. 在模块 `PROGRESS.md` 写明“模块验收范围”和最小“P6 实机证据”。范围内每个
   组件必须已有实机证据或已 `component-closed`。暂缓／排除项只保留为稳定
   合同；删除其活跃 work 和候选，未来恢复时重新建 work。
2. 验证最终 keep set，并先把必须长期保留、目前却位于 `generated/` 的少量 P6
   截图／记录迁到 `assets/references/<module>/p6/`，记录 SHA。`generated/` 不能
   充当最终证据库。
3. 把最终 Prompt／provenance、对象／状态／几何／UV／回退、运行时路径与验收
   结论凝结到四份长期模块文档和最终 manifest；移除逐次尝试流水、过期下一步
   和过程叙述。
4. 审计 canonical `generated/<module>/`、全部模块 work、模块专属 cache／预演／
   脚本／故障参考，以及 canonical 之外的 legacy generated 路径。用组件 ID、
   文件引用、SHA 与 Git 历史证明归属；共享或归属不明路径必须排除并单独请求
   裁决，不能推定为模块专属。
5. 清空整个 `generated/<module>/`，包括 tracked 与 ignored 数据；删除全部
   `docs/modules/<module>/work/` 内容和目录、已验证的 legacy 模块中间路径及
   其他确定的模块专属中间数据。使用经过校验的字面路径，不使用未解析变量、
   通配符或共享父目录。完整历史由 Git 保留，ignored 数据优先移入废纸篓。
6. 运行模块关闭校验、fresh-checkout addon package、相关 runtime／repository
   tests、Markdown links 与 `git diff --check`。在模块 `PROGRESS.md` 写入
   `P6-C / module-closed`、关闭日期、保留路径、aliases／legacy 路径和校验结果，
   并使用独立清理提交。

模块终局保留集仅包括：

- 四份长期模块文档中的最终稳定合同与最小 P6 结论；
- 用户接受的 `assets/source/<module>/`、最终 manifest、仍需的 deterministic
  exporter、deployable runtime、实现与 tests；
- `assets/references/<module>/p6/` 中最小且已哈希的最终实机证据；
- 活跃锁定基准、许可证、用户原始文件和确实由其他模块引用的共享资产／工具。

模块终局删除集至少包括：

- 整个 canonical `generated/<module>/`，无论文件 tracked、ignored、隐藏或为
  本地 cache；
- 全部模块 `work/` 数据和空目录；
- canonical 外经审计属于该模块的旧 generated 根／文件；
- 已被最终实现取代且只服务该模块的模拟器、实验脚本、debug／验证副本和故障
  参考；
- 长期文档中指向上述中间路径的 live Markdown links，以及 manifests 中仍生效的
  中间路径字段。

关闭校验是只读命令，不负责删除。macOS 示例：

```text
conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/validate_module_closure.py \
  /absolute/path/to/repository <module> \
  --generated-alias <legacy-token> \
  --legacy-generated-path generated/<exact-legacy-path> \
  --report /private/tmp/aeui-<module>-closure-report.json
```

报告 schema 为 `aeui-module-closure-report-v1`，必须 `status=pass`。临时报告在
提交结论后删除，不放回 `generated/<module>/`。关闭校验至少证明：四份长期
文档存在；模块进度有验收范围、P6 证据和 `P6-C / module-closed`；整个 work
目录不存在；canonical／声明的 legacy／alias generated 数据及 Git index 条目
均不存在；长期模块文档不再包含指向 `generated/` 的 live links，manifests
不再保留 `generated/` 路径字段。纯文本关闭清单可记录已经删除的字面路径。

除已明确验收的整模块 canonical 根外，任何阶段都不得对 `generated/`、
`assets/`、`docs/modules/` 或仓库根执行宽泛递归删除。收口后不保留空
`work/` 占位目录。

## Source manifest 最低字段

- schema/version；
- module、component/batch、accepted version；
- source path、width、height、mode、SHA-256；
- Alpha／色键检查；
- 固定执行器版本、会话和结果 ID；
- 锁定图、主模块／子模块 Prompt 路径与参考职责；
- 用户接受日期；
- 逻辑对象和状态映射；
- 禁止 runtime 用法；
- exporter／crop／UV 合同状态。

## 提交与同步

1. 开始前检查工作树并保留无关修改。
2. 本地模拟渲染后把 specification、命令、路径、SHA 和内审写入同一 work。
   每次生产实际生图前提交当前完整执行正文；无候选流程错误仍写入同一 work，
   修复后以同一正文重试；循环内候选失败只更新同一 work，循环终态再同步
   模块进度、manifest 或实现。
3. 确认 `generated/` 仍被忽略。
4. 先检测当前 OS，再运行 `git diff --check`、文档拓扑／链接测试、相关合同
   测试与 Lua smoke。任何 P5 export 还必须运行
   `validate_addon_package.py`，并在文件全部 tracked／staged 后重新确认 fresh
   checkout 门禁。macOS 必须使用 `conda run -n py312 python` 执行所有 Python
   脚本与 Skill validator，不得静默回退到系统 `python3`；Linux 使用活跃项目
   环境的 `python3`，Windows PowerShell 优先 `py -3`，否则使用活跃项目环境的
   `python`。记录实际 `sys.executable` 与版本。
5. 提交信息指出模块、批次和状态变化。
6. 明确报告仅本机、已提交或已推送；除非用户要求，不自动 push。
7. `P6-C` 使用独立清理提交，便于审阅与恢复。整模块关闭还必须在提交前运行
   `validate_module_closure.py`；明确的整模块 P6 验收即授权 verified
   module-only delete set，不再请求第二次批准。

## 回退

- 候选失败：记录到 work，创建新版本；不动已接受 source。
- runtime 失败：回退到该模块之前的安全 runtime 或原生 Frame；不改
  SavedVariables、数据或非视觉功能。
- provider 未知：停在 `P0–P2`；不生产假资产或空 adapter。
