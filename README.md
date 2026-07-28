# Azeroth Expedition UI Overhaul

面向 Turtle WoW `1.18.1` 的香草时代 UI 美术整合项目。

项目目标是在尽量保留 60 级香草魔兽结构、信息密度与操作习惯的前提下，统一 pfUI 与各类单体插件的视觉语言，并增强厚重、史诗、魔幻与长期使用后的旧物质感。

当前仓库首先是一套已经整理好的设计基线，尚未包含可运行插件代码。

## 核心美术语言

- 2004 年前后香草魔兽式手绘位图、厚轮廓与明确明暗切面。
- 深胡桃旧皮革、暖赭羊皮纸与暗哑氧化黄铜。
- 厚重感来自物件结构和材料厚度，不来自大型龙头、祭坛、黑铁尖刺或持续发光。
- 保留香草界面的经典轮廓；避免 pfUI 式规整窄边、现代卡片、玻璃拟态及《暗黑破坏神 3》式装备陈列框。

## 当前已锁定模块

| 模块 | 锁定方向 | 状态 |
|---|---|---|
| 聊天框 | 战地旧书 V1 | 已锁定 |
| 任务详情／追踪 | 公会任务卷宗与行军便笺 V1 | 已锁定 |
| 大地图／小地图 | 远征地图卷与黄铜航向罗盘 V1 | 已锁定 |
| 角色属性面板 | 香草同构角色面板 V1 | 已锁定 |

详细状态与权威文件见 [设计状态索引](docs/DESIGN_STATUS.md)。

## 快速入口

- [整合包总提示词与顶层设计](docs/艾泽拉斯远征手记_UI整合包提示词.md)
- [聊天框视觉规范](docs/modules/chat/聊天框视觉规范_战地旧书_v1.md)
- [任务模块视觉规范](docs/modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md)
- [地图模块视觉规范](docs/modules/map/地图模块视觉规范_远征地图卷与黄铜航向罗盘_v1.md)
- [角色属性模块视觉规范](docs/modules/character/角色属性模块视觉规范_香草同构角色面板_v1.md)
- [字体系统与运行时策略](docs/implementation/FONT_SYSTEM.md)
- [后续实现路线](docs/implementation/IMPLEMENTATION_ROADMAP.md)
- [本次会话决策记录](docs/SESSION_DECISIONS.md)

## 目录结构

```text
addon/AzerothExpeditionUI/   未来插件代码与运行时资源；已包含字体候选
assets/locked/               已锁定的唯一视觉基准
assets/references/           香草结构参考
docs/modules/                各模块正式视觉规范
docs/audits/                 设计审计与能力评估
docs/implementation/         实现路线与技术拆分
prompts/                     锁定提示词和生成稿
source-assets/               未来可编辑母版、切片和导出源
third-party/fonts/           字体许可证、来源与可复现信息
tools/                       未来资源转换、校验和打包工具
```

## 权威优先级

1. `assets/locked/` 中对应模块的视觉基准。
2. `docs/modules/` 中对应模块的锁定规范。
3. `docs/艾泽拉斯远征手记_UI整合包提示词.md` 的跨模块原则。
4. `prompts/` 中的生成提示词。

被否决方案的结论保留在模块规范和 `docs/SESSION_DECISIONS.md` 中；对应的大型探索图和过程对照不进入仓库。

## 下一阶段

从公共材质、字体加载验证与九宫格资源规范开始，再依次实现聊天框、任务模块、地图模块和角色属性面板。战斗 HUD、动作条、单位框架、DPS／仇恨与消耗品监控仍需继续完成顶层设计。

## 发布注意

仓库包含游戏截图、结构参考、基于现有游戏视觉语言生成的概念图，以及采用 SIL Open Font License 1.1 的第三方字体。公开发布、分发或商业使用前，请先阅读 [NOTICE](NOTICE.md) 并完成第三方素材与商标审查。
