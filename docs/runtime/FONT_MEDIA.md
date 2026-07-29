# Runtime 字体候选清单

`addon/AzerothExpeditionUI/Media/Fonts/` 只保存可由插件本地加载的字体候选；
本文件是它的外部媒体清单。

| 文件 | 角色 | 当前状态 |
|---|---|---|
| `LXGWWenKaiGB-Medium.ttf` | 旧书、任务、卷宗和地图注释 | 静态 TTF，待 Turtle WoW `1.18.1` 实测 |
| `NotoSerifSC-SemiBold.ttf` | 庄重中文面板标题 | `wght=600` 静态 TTF，待 Turtle WoW `1.18.1` 实测 |
| `NotoSansSC-Medium.ttf` | 高密度中文信息二级回退 | `wght=500` 静态 TTF，可选且待实测 |

不要向插件目录复制游戏客户端字体。完整职责和回退规则见
[FONT_SYSTEM.md](../implementation/FONT_SYSTEM.md)，第三方许可证与来源见
[FONTS.md](../legal/FONTS.md)。
