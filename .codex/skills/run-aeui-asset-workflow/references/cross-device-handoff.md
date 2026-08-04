# 跨设备工作检查点

本规则只解决一个问题：另一台设备需要继续审查同一张模拟／候选，或下一次
ImageGen edit 必须读取上一轮的精确像素时，怎样在不提交整个 `generated/` 的
前提下完成无损交接。

`generated/` 继续被 Git 忽略。可重建的 raw、失败稿、分层缓存、批量预演与
报告不进入版本历史。只有下一门禁不可替代的最小字节集合，才临时发布到：

```text
handoff/<module>/<component>/
  manifest.json
  payloads/<role>.<ext>
```

`handoff/` 是临时、tracked、可校验的运输层，不是视觉权威、源资产或 addon
运行时。一个组件只能有一个当前检查点；新检查点替换旧检查点，不能累计。

## 何时必须发布

准备在另一台设备继续、准备 push 后换设备、或需要把当前工作移交给另一名
协作者时，只要下一步依赖 ignored 像素，就必须先发布检查点。允许的稳定状态
与最小 payload 如下：

| 状态 | 必需 role | 可选 role | 实际 ImageGen 上限 |
|---|---|---|---:|
| `simulation-reviewed` | `review-preview` | `review-zoom` | `0` |
| `candidate-reviewed` | `candidate`, `real-layout-preview` | `technical-preview` | `5` |
| `candidate-rejected` | `candidate`, `real-layout-preview` | `technical-preview` | `5` |
| `repair-prepared` | `edit-input` | `real-layout-preview`, `technical-preview` | `5` |

以下情况不发布：仍是 prompt／合同草稿；下一步只依赖 tracked 文本；输出可由
已提交脚本确定性重建且不需要复审同一像素；已经进入 `assets/source/`；已经
完整接入 `addon/`。P5 测试设备只需要 tracked addon，不应读取 `handoff/`。

每个组件最多 `3` 个 payload；单文件最多 `16 MiB`；合计最多 `32 MiB`。超限
表示组件交接范围过大，必须重新选择真正决定下一门禁的文件，不能放宽限制或
提交整个 attempt 目录。

## 发布顺序

1. 把当前状态、完整执行正文／修复正文、尝试预算、审查结论和下一门禁写入
   唯一组件 work。
2. 在短期协作分支上工作，不能直接在 `main`、`master` 或 origin 默认分支发布
   临时像素。发布器会拒绝 detached HEAD、受保护分支和存在 tracked 改动的
   工作树。
3. 先提交全部 tracked 状态。发布器还会单独确认 work 已 tracked 且无 staged
   或 unstaged 修改，从而保证 manifest 中的 work SHA 与 `base_commit` 可复核。
4. 从 `generated/` 选择最小 payload，通过发布器复制到 `handoff/`。不要手工
   编写 manifest，也不要把 `generated/` 本身加入 Git。
5. `git add` 该组件的 handoff，运行精确目标验证；验证通过后单独提交并 push
   当前协作分支。

`publish` 返回的报告只验证刚写出的字节，固定包含
`git_tracking_verified: false`。完成 `git add` 后再次运行 `validate`，只有
`status: pass` 且 `git_tracking_verified: true` 才构成可 push 的检查点；漏加
任一 manifest／payload 会返回 `UNTRACKED_CHECKPOINT_FILE`。

macOS：

```bash
conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/manage_cross_device_handoff.py \
  publish . --module <module> --component <component> \
  --state candidate-reviewed --work-file docs/modules/<module>/work/<work>.md \
  --prompt-version <version> --next-gate '<next-gate>' \
  --attempts-used <n> --attempt-limit 5 --process-errors <n> \
  --payload candidate=generated/<module>/<batch>/<candidate> \
  --payload real-layout-preview=generated/<module>/<batch>/<preview>

git add handoff/<module>/<component>

conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/manage_cross_device_handoff.py \
  validate . --module <module> --component <component>
```

Linux 使用已激活项目环境的 `python3`，Windows PowerShell 使用 `py -3`（不可用
时使用项目环境的 `python`），参数不变。已有检查点只能在确认当前检查点本身
有效后通过 `publish ... --replace` 原子替换。发布失败不得留下半个新检查点；
`.stage-*`／`.backup-*` 目录出现时验证必须失败并要求人工检查。

## 接收与恢复

1. 拉取同一协作分支，不要只复制图片或只摘取 work commit。
2. 对目标组件运行 `validate`。它必须确认 payload SHA／大小、work SHA、状态
   role、预算、路径边界以及 `base_commit` 仍是当前 HEAD 的祖先。
3. 同时阅读 manifest 指向的 work，并从 `next_gate` 继续。`source_path` 只是原
   设备 provenance，远端不存在对应 ignored 文件是正常的。
4. payload 只读使用。若状态是 `repair-prepared`，只有 `edit-input` 可以在已
   冻结修复边界内成为下一次 edit 输入；其他 payload 只用于复审。
5. 两台设备都修改了 work 时，先解决 tracked 文本冲突，再由继续工作的设备
   用新 work commit 重新发布检查点；禁止合并两份候选或手改 SHA。

临时 handoff commit 不得通过普通 merge／fast-forward 进入默认分支，否则图片
即使随后删除也会永久留在默认分支历史。组件不再需要 handoff 后，先提交删除；
最终只把不含 `handoff/` 的净结果 squash merge 到默认分支，或只 cherry-pick
明确的非 handoff 提交。确认净结果已进入默认分支后再删除远端短期协作分支。
删除远端分支是外部破坏性动作，仍需用户明确要求；本工作流不会自动执行。

全仓检查不指定过滤器：

```bash
conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/manage_cross_device_handoff.py \
  validate .
```

没有 `handoff/` 时全仓验证通过；指定的模块／组件不存在时精确验证失败，防止
把“没有收到检查点”误当成“检查点有效”。

## 消费与清理

检查点一旦不再是下一门禁的必要输入，就在同一阶段提交中删除：

- 模拟方向已确认并完整转写到 work；
- 用户接受候选，精确母版与 manifest 已进入 `assets/source/`；
- 用户拒绝后已进入不复用该像素的新主版本；
- repair edit 已产生下一候选并发布了替代检查点；
- 组件或整模块关闭。

删除 `handoff/<module>/<component>/` 不等于删除本地 `generated/`。本地中间数据
仍按 P6/P6-C 清理规则处理。整模块 `P6-C` 必须不存在
`handoff/<module>/`；关闭校验会把残留检查点视为失败。

## Manifest 契约

发布器生成 schema `aeui-cross-device-handoff-v1`，验证报告 schema
`aeui-cross-device-handoff-report-v1`。Manifest 至少固定：模块／组件、稳定
状态、prompt 版本、已提交 work 路径与 SHA、发布前 HEAD、实际生图预算、流程
错误数、协作分支、下一门禁、payload role／路径／来源／SHA／字节／媒体类型，
以及以下不可变语义：

- `authoritative: false`
- `may_be_runtime_input: false`
- `may_be_source_without_explicit_acceptance: false`
- `replace_instead_of_accumulate: true`
- `remove_by_source_acceptance_or_p6_closure: true`

任何 source 晋级、runtime 导出或 P6 结论仍必须经过原有独立门禁；handoff 的
存在不能替代用户验收、display-region、fresh-checkout package 或实机证据。
