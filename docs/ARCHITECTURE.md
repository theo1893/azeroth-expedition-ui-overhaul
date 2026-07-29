# pfUI 基础与重构架构

## 结论

本项目不是独立重写所有魔兽功能，也不是只能给 pfUI 换一张背景图。
`addon/pfUI/` 是功能与生命周期底座的可安装维护分支；
`addon/AzerothExpeditionUI/` 负责书本、卷宗等模块级替换。两者共同组成
测试和发布单元。

## 事实来源

- pfUI 运行时与公共视觉入口：`addon/pfUI/`
- 模块级替换、项目媒体与字体：`addon/AzerothExpeditionUI/`
- 当前 pfUI 快照：`8.1.0`，来源 HEAD
  `fbc8fb608b79adf32049543ec12fcc020e0acd69`
- pfUI 许可证：MIT；运行时目录保留 `addon/pfUI/LICENSE`
- fork 修改必须登记在 [`PFUI_FORK.md`](pfui/PFUI_FORK.md) 与 overhaul
  tracker

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
- 只修改可见 Frame、布局、材质、字体、状态呈现及其直接连接逻辑；自动售卖、
  修理、背包操作、聊天事件、战斗数据、社交和兼容逻辑保持不变。
- Hook 后不得在低频维护循环中持续改写 Parent、Point、Width、Height。
- 模块必须能够单独启用、禁用；公共基线可通过
  `pfUI_config.appearance.expedition.enabled` 回退。
- 尚未完成组件级重绘的 pfUI 可见替换模块通过
  `vanilla_fallback` 在加载前路由到客户端原生呈现；该路由不能写入或覆盖
  用户的 `pfUI_config.disabled`。
- pfUI 对象不存在或版本不匹配时，模块失败应局部降级，不能阻止整个插件加载。
- 直接改动 pfUI 时记录上游文件、提交、修改原因和功能边界。
- 测试客户端的临时 SavedVariables 与实验改动不得反向污染维护分支。

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

```text
addon/pfUI/
  api/
    expedition.lua       公共视觉合同
    api.lua              pfUI 公共绘制入口
  modules/               保留 pfUI 功能模块
  skins/                 保留并逐步重做可见原生面板
```

pfUI 的上游基线、fork 差异与测试说明统一位于 `docs/pfui/`，不随运行时代码
散放在插件目录。

## 当前状态

聊天模块是第一个 `adapter`：

- pfUI 继续负责窗口、停靠、拖动、滚动、历史、输入和 Tab 点击。
- 本插件负责书框九宫格、正文安全区、Tab 状态和输入条。
- pfUI legacy 信息 widget 源码仍保留，但 panel 呈现模块默认不加载，聊天／
  小地图底栏也不挂载。
- 当前 Lua 仍加载 `0.4.1` legacy 主框／Tab／输入／未读资产。
- V3 组件母版已经在 `assets/source/chat/v3/`，但尚未导出并接入运行时。

尚未获得模块专属资产的游戏界面不再先显示 pfUI 的现代几何：动作条、单位框、
小地图、地图、背包、拾取、Buff、姓名板、Tooltip 和全部 Blizzard skin
默认保留香草／Turtle WoW 原生呈现。pfUI 的非视觉功能与维护工具继续加载；
维护工具和未来 opt-in 模块使用统一的非透明材质 backdrop。这个回退只是安全
的测试基线，不等同于各模块最终资产完成；具体阶段以 tracker 为准。

其他模块必须先完成 pfUI／原生 Frame 清单与逻辑资产表，不能直接从整张视觉
原型开始切图。
