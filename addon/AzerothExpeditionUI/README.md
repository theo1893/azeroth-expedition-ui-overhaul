# Addon implementation placeholder

未来可运行的 Turtle WoW 插件代码放在此目录。

当前已经加入三份字体候选：

- `Media/Fonts/LXGWWenKaiGB-Medium.ttf`：卷宗、旧书、地图注释和短叙事标签。
- `Media/Fonts/NotoSerifSC-SemiBold.ttf`：庄重的中文面板主标题与章节标题。
- `Media/Fonts/NotoSansSC-Medium.ttf`：客户端中文字体不可用时的高密度信息二级回退。

三者均为传统静态 TTF；仍需在 Turtle WoW `1.18.1` 实机验证加载、中文覆盖、UI Scale 和内存占用。在验证通过前，不应覆盖客户端全局字体。

建议最终结构：

```text
AzerothExpeditionUI.toc
Core/
Modules/
Skins/
Media/
  Fonts/
Locales/
Compatibility/
```

在确认客户端 API、插件依赖与发行名称前，不创建占位 `.toc` 或伪实现。

字体职责、回退顺序和许可证入口见：

- [`docs/implementation/FONT_SYSTEM.md`](../../docs/implementation/FONT_SYSTEM.md)
- [`third-party/fonts/`](../../third-party/fonts/)
