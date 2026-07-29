# Azeroth Expedition UI

可直接放入 Turtle WoW `Interface/AddOns` 的 UI 重构插件，目标 Interface 为
`11200`。

pfUI 是功能底座；本插件可以在不修改 pfUI 快照的前提下重构其呈现层。当前
首个可运行模块是 pfUI-only 聊天框。

## 当前版本

`0.3.1` 继续使用 legacy 战地旧书 runtime：

- pfUI 负责聊天行为、停靠、拖动、滚动、历史、输入与底栏。
- 本插件提供主框九宫格、Tab 三状态、未读覆盖、输入条和三个底栏字段。
- 周期维护只更新视觉，不持续改写 Frame 几何。
- 禁用本插件并重载即可回到 pfUI 原外观。

V3 组件母版已经确认，但尚未接入游戏；不要依据源资产目录误判插件已经使用
V3。迁移状态见
[`docs/implementation/CHAT_COMPONENT_SPEC.md`](../../docs/implementation/CHAT_COMPONENT_SPEC.md)。

## 依赖与命令

必需依赖：`pfUI`。

- `/aeui status`：显示版本与聊天皮肤状态。
- `/aeui refresh`：重新应用视觉适配。
- `/aeui chat`：启用或禁用聊天皮肤并重载界面。

## 字体候选

- `Media/Fonts/LXGWWenKaiGB-Medium.ttf`：卷宗、旧书、地图注释和短叙事标签。
- `Media/Fonts/NotoSerifSC-SemiBold.ttf`：庄重中文面板标题。
- `Media/Fonts/NotoSansSC-Medium.ttf`：高密度信息的中文二级回退。

三者尚需在 Turtle WoW `1.18.1` 实机验证；在验证前不得覆盖客户端全局字体。
职责、回退和许可见
[`FONT_SYSTEM.md`](../../docs/implementation/FONT_SYSTEM.md) 与
[`third-party/fonts/`](../../third-party/fonts/)。

## 结构

```text
AzerothExpeditionUI.toc
Core/
  Bootstrap.lua
Modules/
  Chat.lua
Media/
  Chat/
  Fonts/
```

只在实现真实模块时增加文件，不建立空壳目录。
