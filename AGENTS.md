# Azeroth Expedition UI 仓库约束

## 项目边界

- 目标客户端：Turtle WoW `1.18.1`，Interface `11200`。
- `addon/AzerothExpeditionUI/` 是项目运行时代码的唯一事实来源。
- pfUI 是功能、数据和生命周期底座。允许在本插件内大规模重构其视觉层、
  布局层和呈现组件；不要求局限于简单换肤。
- `third-party/pfUI/` 是固定的开发参考快照，默认只读。不要直接把项目功能
  写进该目录，也不要让本机测试客户端的改动反向污染快照。
- 复制或实质改写 pfUI 代码时，记录上游文件、提交和修改原因，并保留 MIT
  版权与许可声明。
- 每个模块必须能够独立启用、禁用并回退；局部兼容失败不能阻止整个插件加载。

架构边界见 `docs/ARCHITECTURE.md`。

## 权威文件

发生冲突时，按以下优先级裁决：

1. `assets/locked/<module>/` 中用户确认的视觉基准。
2. `docs/modules/<module>/` 中对应模块规范。
3. `docs/ART_DIRECTION.md` 的跨模块规则。
4. `docs/implementation/<MODULE>_COMPONENT_SPEC.md` 中的组件与几何合同。
5. `assets/source/<module>/` 中已确认的透明母版。
6. `assets/references/` 中明确标注用途的结构或故障参考。

组件状态、资产来源、原始提示词和 runtime 路径以
`docs/implementation/OVERHAUL_TRACKER.md` 为唯一进度事实来源。任何状态变化
必须在同一 Git 提交中更新 tracker。

## 组件级资产

- 资产粒度必须与游戏内逻辑对象一致。
- 每个 Button、Tab、输入框、滚动条、状态条和图标槽都要分别定义对象、状态、
  点击几何、文字安全区和可拉伸区。
- 可以把多个逻辑资产打包到同一物理图集，但必须提供 manifest／UV 映射。
- 不得把真实按钮、状态、动态文字、图标、滚动条或固定槽位烘焙进整张背景。
- 生成前先完成 pfUI／原生 Frame 映射；找不到稳定对象时，不制作“看起来像”
  的假控件。
- 运行时 TGA 使用 32 位 RGBA、2 的幂画布，并给 UV 留出防渗色边距。
- 可再生预览、色键 raw、失败稿和调试图放在被 Git 忽略的 `generated/`，
  不进入 `assets/source/`。

完整流程见 `docs/ASSET_PIPELINE.md`。

## 固定生图执行器

所有位图生成和修图必须使用仓库内：

```text
.codex/skills/imagegen-0-143-0/SKILL.md
```

其固定实现为 `@openai/codex@0.143.0`。禁止改用会话内建 imagegen 或其他
未确认的模型／版本。

执行顺序：

1. 完整阅读该 `SKILL.md` 和它直接要求的参考说明。
2. 读取本模块的锁定基准、视觉规范、组件合同、tracker 和参考授权。
3. 将用户需求重写成专业、可执行、可验收的版本化提示词，保存在
   `prompts/<module>/`。
4. 用户确认后，把提示词文件中的最终正文原样传给 `$imagegen`；执行时不再
   二次改写。
5. 原始结果只写入 `generated/<module>/<version>/`。
6. 检查对象数量、尺寸、Alpha、残色、状态共同画布、文字安全区和 100% 游戏
   尺寸预演。
7. 用户确认后才把透明母版加入 `assets/source/`；明确锁定后才进入
   `assets/locked/`。
8. 使用确定性脚本导出 runtime，并同步更新 tracker。

若模型不能可靠输出真透明背景，要求完全均匀的 `#00FF00` 色键；用确定性流程
转 Alpha，不以自由重绘掩盖背景错误。

## 聊天模块当前边界

- 只接入 pfUI；用户未扩大范围前，不处理其他聊天插件。
- pfUI 继续负责窗口、Tab、停靠、拖动、滚动、历史、输入和底栏行为。
- 插件 `0.3.1` 仍加载 legacy 聊天资源。
- V3 A／B／C 透明母版位于 `assets/source/chat/v3/`，已通过
  `440 × 320` 预演，但尚未导出或接入游戏。
- 恢复迁移时先复核 `tools/build_chat_v3_runtime_assets.py`、manifest 和
  Lua UV；不得把 V3 的 `P4` 误标为 runtime 完成。
- 聊天组件合同见 `docs/implementation/CHAT_COMPONENT_SPEC.md`。

## 运行时实现约束

- 不覆盖 `ChatFrame_OnEvent`、物品链接、战斗日志等行为入口。
- Hook 后不得在维护循环中持续改写 Parent、Point、Width 或 Height。
- 组件纹理缺失、pfUI 对象不存在或版本不匹配时，应局部降级并给出诊断。
- 只创建当前实现确实需要的代码和资源，不建立空壳模块。
- 修改后至少运行静态资源检查、脚本检查和已有 smoke test；只有目标客户端
  实机通过后才能标记 `P6`。
