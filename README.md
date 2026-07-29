# Azeroth Expedition UI Overhaul

面向 Turtle WoW `1.18.1`／Interface `11200` 的 UI 重构项目。pfUI 提供
功能、数据和生命周期基础；本项目在独立插件中大规模重构视觉、布局和呈现
组件，使它们重新接近 60 级香草魔兽的结构、重量和手绘质感。

核心原则是“香草结构优先，材质增强次之”。这不是棕色现代 HUD，也不是
《暗黑破坏神 3》或《上古卷轴 5》的移植主题。

## 当前状态

| 模块 | 设计／资产 | 运行时 |
|---|---|---|
| pfUI 基础 | 8.1.0 项目维护分支已迁入 `addon/pfUI` | 功能底座；未完成界面默认回退香草呈现，待实机 |
| 聊天 | 战地旧书 V3 组件母版已确认 | `0.4.1` 加载无信息底栏的 legacy 资产，V3 待迁移 |
| 任务 | `QL-A1` 空卷宗透明母版达到 `P4`；追踪器保留兼容参考 | 单独确认 `QL-A2` 可拉伸部件；外部追踪插件待后续接入 |
| 地图 | 羊皮大地图与黄铜罗盘视觉已锁定 | 待按真实控件拆分 |
| 角色 | 香草同构纸娃娃视觉已锁定 | 待按真实控件拆分 |
| 战斗／监控／其他 | 已登记模块范围 | 待逐组件设计 |

精确到每个组件的阶段、源资产、原始提示词和 runtime 路径见
[UI 改造进度总表](docs/implementation/OVERHAUL_TRACKER.md)。

## 开发入口

- [文档中心与职责索引](docs/README.md)
- [文档与实现同步工作流](docs/WORKFLOW.md)
- [UI 改造进度总表](docs/implementation/OVERHAUL_TRACKER.md)

项目说明统一位于 `docs/`。`addon/` 只包含运行时代码、媒体和必要许可证；
版本化、可直接执行的提示词作为生产输入保留在 `prompts/`。

## 目录

```text
addon/pfUI/                  可独立安装的 pfUI 项目维护分支
addon/AzerothExpeditionUI/   模块级重绘、runtime 媒体与字体
assets/locked/               用户确认的整体视觉基准
assets/references/           结构、比例或故障参考
assets/source/               用户确认的透明生产母版
docs/                        项目文档唯一集中入口
docs/modules/                模块级美术与结构规范
docs/implementation/         组件合同、进度表与实现说明
docs/runtime/                addon 与 runtime 媒体清单
docs/pfui/                   pfUI 上游基线与维护分支差异
prompts/                     可追溯的原型／生产提示词
third-party/fonts/           字体许可、来源和校验值
tools/                       确定性资源导出与预演脚本
tests/                       静态／smoke test
```

临时生成、色键 raw 和可再生预演应进入被 Git 忽略的 `generated/`。

## 独立测试

把 `addon/` 下的两个目录同时复制到客户端 `Interface/AddOns/`：

```text
Interface/AddOns/pfUI/
Interface/AddOns/AzerothExpeditionUI/
```

`pfUI` 可单独加载以检查功能底座与全局视觉基线；
`AzerothExpeditionUI` 依赖 `pfUI`，用于检查聊天旧书等模块级替换。当前全局
策略不会让尚未完成专属资产的 pfUI 现代动作条、单位框、背包、小地图和
Blizzard skin 进入游戏；这些组件先显示客户端原生版本。只有聊天等已接管
模块使用项目呈现。`/pfui`、解锁和分享等维护工具继续可用，并使用非透明
公共材质；这不代表每个模块的最终专属资产都已经达到 `P6`。

默认路由、回退开关与保留功能清单见
[pfUI 维护分支说明](docs/pfui/PFUI_FORK.md)。

## 资产生产规则

整张效果图只能锁定综合色感，不能直接充当 runtime 背景。每个可交互 Button、
Tab、输入框、滚动条和状态必须先映射到真实 pfUI／原生对象，再生成独立逻辑
资产。逻辑切片可打包进图集，但必须保留 manifest、UV 和状态映射。

所有生图和修图固定使用仓库内 `imagegen-0-143-0` 技能，对应
`@openai/codex@0.143.0`。先将需求重写进版本化提示词文件，确认后再把该正文
原样交给执行器。

## 许可与发布

仓库含 pfUI MIT 维护分支、OFL 字体、游戏结构参考和生成式视觉资产。公开
发布或商业使用前请阅读 [NOTICE](NOTICE.md)，并分别审查代码、字体、截图、
商标和美术资产的权利边界。
