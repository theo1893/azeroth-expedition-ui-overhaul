# Azeroth Expedition UI

这是可直接放入 Turtle WoW `Interface/AddOns` 的 UI 重写插件。

当前首个可运行模块是聊天框：

- `pfUI` 继续负责聊天窗口、滚动、历史、停靠和底栏功能。
- 本插件只接入 pfUI 的主聊天框、Tab、输入框与左底栏。
- 暂不接入其他聊天单体插件，也不改变它们的框体、锚点或父级。
- 本插件只提供“战地旧书”材质、正文安全区、Tab、输入框与底栏的视觉适配。
- 不修改或分叉任何第三方插件源码；禁用本插件并重载即可完整回退。

`0.3.1` 恢复了上一版 pfUI-only 战地旧书美术，并保留组件级渲染结构：

- 每个聊天页签拥有独立的普通、悬停、选中与未读蜡封状态。
- pfUI 左底栏拆成三个独立皮革段。
- 输入框使用独立纸带资源。
- 主书框使用 `1024 × 1024` 纹理，有效书框占顶部 586 像素。
- 主书框使用九宫格渲染，四角保持比例、边缘只单向伸缩。
- Tab、底栏与输入条运行时资源提升到 2× 分辨率。
- Tab 切换完成后立即刷新贴图；周期维护不修改框体几何。

被否决的 imagegen-v4 不再参与运行时构建。下一轮美术生成前会先锁定资源
拆分、透明边界、九宫格基线和 pfUI 控件锚点。

运行依赖：

- 必需：`pfUI`

聊天模块命令：

- `/aeui status`：显示当前版本与聊天皮肤状态。
- `/aeui refresh`：重新应用视觉适配。
- `/aeui chat`：启用或禁用聊天皮肤并重载界面。

当前已经加入三份字体候选：

- `Media/Fonts/LXGWWenKaiGB-Medium.ttf`：卷宗、旧书、地图注释和短叙事标签。
- `Media/Fonts/NotoSerifSC-SemiBold.ttf`：庄重的中文面板主标题与章节标题。
- `Media/Fonts/NotoSansSC-Medium.ttf`：客户端中文字体不可用时的高密度信息二级回退。

三者均为传统静态 TTF；仍需在 Turtle WoW `1.18.1` 实机验证加载、中文覆盖、UI Scale 和内存占用。在验证通过前，不应覆盖客户端全局字体。

当前结构：

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

字体职责、回退顺序和许可证入口见：

- [`docs/implementation/FONT_SYSTEM.md`](../../docs/implementation/FONT_SYSTEM.md)
- [`third-party/fonts/`](../../third-party/fonts/)
