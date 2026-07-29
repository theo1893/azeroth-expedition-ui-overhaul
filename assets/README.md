# 视觉资产目录

## `locked/`

保存用户确认的整体视觉与结构基准。它们不直接进入游戏：

- `chat/`：战地旧书。
- `quests/`：任务卷宗与行军便笺。
- `map/`：羊皮大地图与黄铜罗盘。
- `character/`：香草同构角色面板。

整张基准只决定综合色感和结构方向，不能充当包含多个控件的 runtime 背景。

## `references/`

保存香草结构、比例或故障参考，不是可发布贴图。每个会话目录必须用 README
说明文件用途；被否决方案的结论写入文档后，不继续保留大型反例。

## `source/`

保存用户确认的高分辨率透明生产母版。当前包括：

- `source/chat/ChatBookFrame_Master_v1.png`：仍用于重建 legacy runtime。
- `source/chat/v3/`：V3 主框、Tab 和控件母版，以及两张必要验收预览。

只保存不可由其他仓库文件确定性重建的生产源和必要验收证据。色键 raw、失败
候选、调试导出和临时 atlas 进入被 Git 忽略的 `generated/`。

## 入库要求

- 文件名包含模块、职责和版本。
- 无文字母版与运行时文字分离。
- 每个可交互对象和状态有明确组件 ID。
- 九宫格／三段式切片有 manifest 或脚本坐标。
- 源资产、原始提示词和 runtime 路径登记到
  `docs/implementation/OVERHAUL_TRACKER.md`。
- runtime 资源只能由确定性脚本输出到插件 `Media/`。
