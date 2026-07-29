# pfUI 基础与重构架构

## 结论

`AzerothExpeditionUI` 不是独立重写所有魔兽功能，也不是只能给 pfUI 换一张
背景图。pfUI 是功能与生命周期基础；本插件可以在自己的代码目录中对其
视觉、布局和呈现组件进行大规模重构。

## 事实来源

- 运行时代码唯一事实来源：`addon/AzerothExpeditionUI/`
- pfUI 开发参考：`third-party/pfUI/`
- 当前 pfUI 快照：`8.1.0`，来源 HEAD
  `fbc8fb608b79adf32049543ec12fcc020e0acd69`
- pfUI 许可证：MIT；复制或实质改写代码时必须保留其版权和许可声明
- `third-party/pfUI/` 默认只读，不能直接承载项目功能

## 四种重构方式

| 方式 | 使用条件 | 允许行为 | 示例 |
|---|---|---|---|
| `skin` | pfUI 几何和交互已经合适 | 替换纹理、字体、颜色、状态覆盖层 | Tooltip、部分按钮 |
| `adapter` | pfUI 行为可复用，但布局需要调整 | Hook 生命周期、重新锚定、重新分层、组件级换肤 | 当前聊天模块 |
| `replacement` | pfUI 视觉结构与目标差异过大 | 隐藏 pfUI 呈现层，在本插件创建新 Frame；复用 pfUI API、数据和事件 | 单位框架、动作条候选 |
| `extension` | pfUI 没有目标功能 | 新建模块并接入统一组件库 | DPS、仇恨、消耗品监控 |

重构方式必须记录在
[`OVERHAUL_TRACKER.md`](implementation/OVERHAUL_TRACKER.md) 的每个组件行中。

## 组件边界

每个可交互对象必须拥有独立的运行时职责：

- Button 的普通、悬停、按下、选中、禁用状态。
- Tab 的状态贴图、文字安全区和点击几何。
- 输入框的默认、聚焦和禁用状态。
- ScrollBar 的轨道、滑块、上／下按钮。
- 状态条的背景、填充、端帽、刻度和预警覆盖。
- 图标槽的底框、品质内沿、冷却遮罩、数量和缺失状态。

物理图集可以合并多个逻辑切片，但必须有 manifest／UV 映射。不能因为只
加载一张 TGA，就把多个按钮或动态状态烘焙成一张不可交互背景。

## pfUI 依赖边界

- 不覆盖 `ChatFrame_OnEvent`、物品链接、战斗日志等原始行为入口。
- Hook 后不得在低频维护循环中持续改写 Parent、Point、Width、Height。
- 模块必须能够单独启用、禁用并回退到 pfUI 外观。
- pfUI 对象不存在或版本不匹配时，模块失败应局部降级，不能阻止整个插件加载。
- 复制 pfUI 代码进入本插件时，记录上游文件、提交和修改原因。
- 不能让测试客户端中的本机修改反向污染 `third-party/pfUI/` 快照。

## 推荐代码结构

```text
addon/AzerothExpeditionUI/
  Core/
    Bootstrap.lua
    PfUIBridge.lua
    MediaRegistry.lua
    ComponentFactory.lua
  Components/
    NineSlice.lua
    ThreeSlice.lua
    Button.lua
    Tab.lua
    StatusBar.lua
    IconSlot.lua
  Modules/
    Chat.lua
    Quests.lua
    Map.lua
    Character.lua
    ...
  Media/
    <Module>/
```

只在实际实现时创建文件，不建立空壳模块。

## 当前状态

聊天模块是第一个 `adapter`：

- pfUI 继续负责窗口、停靠、拖动、滚动、历史、输入和 Tab 点击。
- 本插件负责书框九宫格、正文安全区、Tab 状态、输入条和底栏皮肤。
- 当前 Lua 仍加载 `0.3.1` 旧运行时资产。
- V3 组件母版已经在 `assets/source/chat/v3/`，但尚未导出并接入运行时。

其他模块必须先完成 pfUI／原生 Frame 清单与逻辑资产表，不能直接从整张视觉
原型开始切图。
