# Azeroth Expedition UI Overhaul

一套面向 Turtle WoW `1.18.1` 的香草时代 UI 美术重构项目。

项目以 pfUI 的成熟功能、数据和兼容层为基础，重新制作聊天、任务、地图、
角色、战斗 HUD 与系统窗口的视觉呈现。目标是在保留 60 级香草魔兽结构、
信息密度和操作习惯的同时，统一各插件的美术语言，并加强厚重、史诗、魔幻和
长期远征后的旧物质感。

主题名称为“艾泽拉斯远征手记”：聊天框是战地旧书，任务界面是公会卷宗，
地图是羊皮地图卷与黄铜罗盘；其他模块继续从香草原型出发，而不是套用现代
HUD。

## 仓库组成

```text
addon/pfUI/                 pfUI 功能底座的项目维护分支
addon/AzerothExpeditionUI/  模块级视觉替换与运行时媒体
addon/DoiteDPS/             输出建议、循环配置、执行入口与独立自检
addon/AzerothExpeditionGroupFinder/  专用频道团队目录与申请闭环
assets/                     锁定基准、参考和确认后的源资产
docs/                       精简的全局与模块设计状态
tools/                      可重复的资产导出与验证工具
third-party/                第三方来源、许可与校验信息
```

测试时将 `addon/pfUI`、`addon/AzerothExpeditionUI`、`addon/DoiteDPS` 与
`addon/AzerothExpeditionGroupFinder` 一同复制到客户端 `Interface/AddOns/`。
组队插件可用 `/aegf` 打开。DoiteDPS 当前提供双手深武器战、防战、
元素萨满与增强萨满 PvP 的独立入口；其循环状态仍由插件自身持有。当前仓库
尚未声明整体开源许可证；第三方与商标边界见 [NOTICE.md](NOTICE.md)。
