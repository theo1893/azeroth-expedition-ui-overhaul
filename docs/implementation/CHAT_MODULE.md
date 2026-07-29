# 聊天模块实现说明

## 功能分工

| 职责 | 提供者 |
|---|---|
| 聊天窗口、Tab 点击、停靠、拖动、滚动、历史、输入和信息 widget | pfUI |
| 书框、正文安全区、Tab／输入状态视觉 | AzerothExpeditionUI |

当前只支持 pfUI，不访问其他聊天插件，也不覆盖 `ChatFrame_OnEvent`、
`SetItemRef` 等行为入口。

## 两套资源状态

### 当前 runtime：0.4.0 legacy

`Modules/Chat.lua` 当前加载七张 legacy TGA：

- 主书框九宫格；
- Tab 普通、悬停、选中和未读覆盖；
- 连续 Tab 承托带；
- 输入纸带。

这些资源已经通过现有 smoke test，是 V3 迁移前的可回退基线。它们并不等于
当前最终美术。

### 候选源资产：V3

`assets/source/chat/v3/` 保存三张透明母版：

- 空主书框；
- 承托带与四状态 Tab；
- 两状态输入条和未读标记。母版里原有的底栏字段切片已停用，不再导出。

V3 已完成标准 `440 × 320` 视觉合成，但尚未生成正式 TGA、修改 Lua 或完成
Turtle WoW 实机验收。详细对象、尺寸和迁移门见
[`CHAT_COMPONENT_SPEC.md`](CHAT_COMPONENT_SPEC.md)。

## 运行时约束

- 最小聊天容器为 `440 × 320 UI px`。
- 正文安全区为 `380 × 236 UI px`。
- 12px 字号、14px 行高至少显示 16 行中文。
- 主框使用九宫格；Tab 和输入条使用独立状态及三段式结构。
- 公会、背包空间、延迟等 legacy 信息 panel 默认隐藏；widget 逻辑不删除。
- Tab 切换只替换纹理／UV，不改变 Parent、Point、Width、Height 或点击框。
- pfUI 拖动期间不重设几何；拖动结束后只同步一次布局。
- 输入聚焦不得让正文区域回流。
- 禁用插件并重载应恢复 pfUI 原外观。

## V3 迁移顺序

1. 在临时目录运行并审查 `tools/build_chat_v3_runtime_assets.py`。
2. 锁定 atlas manifest、九宫格切线和三段式 UV。
3. 更新 `Modules/Chat.lua` 与 smoke test，让五张 V3 物理纹理承担所有逻辑
   状态。
4. 静态验证资源存在、Alpha、尺寸和 Lua 引用。
5. 在目标客户端验证停靠、拖动、Tab 闪烁、输入焦点、窗口缩放和 UI Scale。
6. 用户确认后，在同一提交中更新
   [`OVERHAUL_TRACKER.md`](OVERHAUL_TRACKER.md)。

迁移完成前不得删除 legacy 主框、builder 或 runtime TGA。
