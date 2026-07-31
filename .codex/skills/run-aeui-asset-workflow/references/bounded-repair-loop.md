# 五次实际生图自主修复循环

每个明确授权的执行正文最多使用 `5` 次实际 ImageGen generation／edit。
attempt 1 是首次候选，因此最多还有四次 `.rN` 修复。

只有以下情况递增计数：

- 固定 child 返回了生成／编辑后的图片；
- 固定 child 返回 provider result ID 或其他直接证据，证明生成作业实际运行。

已生成但不可用、语义错误、畸形、尺寸错误或提示词截断的图仍计数。目录准备、
依赖启动、CLI、sandbox、生成前 wrapper 递归、生成前 prompt 拒绝、上传、
连接或保存错误，在没有图片和 provider 生成证据时属于 process error。将其
写入独立 ledger，修正 transport，并以同一已提交正文重试，不改变 `0/5`。
证据不明时先停止核实。同一 process error 经一次针对性修复后再次发生，必须
暂停诊断，不能借“不计数”无限重试。

每次 countable output 后：

1. 按 review checklist 从头完成视觉、语义、结构、真实排版和展示区域检查。
2. 全部门禁通过时立即停止，记录 `candidate-reviewed / P3` 并交用户复审；
   内部通过不是用户接受，不能创建 tracked source／runtime。
3. attempt 1–4 失败时记录首个失败门禁、证据、保留区和下一修复决策。只有
   明确保留正确区域时使用 edit，否则从锁定权威 regenerate。
4. 写出完整、自包含的 `<authorized-version>.rN`；禁止只写
   “same as before except”。允许在冻结边界内强化结构、构图、材料或技术
   条款，并按 work 授权使用同一循环的前次输出；不得新增 reference 或改变
   冻结合同。
5. 在下一次调用前，把失败记录和新完整正文写入同一 work 并提交。不得为每次
   attempt 新建 Markdown。
6. 新增对象、状态、参考职责、外部输入、视觉方向、Canvas 或其他 envelope
   变化时立即停止，返回 `prompt-draft` 获取新授权；剩余额度不扩大权限。
7. 第 5 个实际候选仍失败时停止，记录
   `candidate-rejected / P3 / repair-budget-exhausted`，保留五次记录并等待
   用户审核。

确定性 crop、Alpha 清理、metrics 和 preview assembly 不消耗 ImageGen。
process error 也不消耗，但两类均需记录且都不重置计数。任何确定性或流程恢复
都不能掩盖语义、解剖、透视、组件身份或美术语言失败。
