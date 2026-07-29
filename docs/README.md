# 文档中心

`docs/` 是项目说明文档的唯一集中入口。`addon/` 只承载客户端运行所需的
Lua、XML、TOC、媒体资产和随分发必须保留的许可证，不放 README 或维护说明。

新增、改名或删除文档前，先阅读 [WORKFLOW.md](WORKFLOW.md)。任何新增文档都
必须在本索引登记；同一事实只能有一个权威文件，其他位置使用链接，不复制
第二份状态说明。

## 核心规则与状态

| 文档 | 唯一职责 | 何时更新 |
|---|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | 插件边界、加载顺序、pfUI adapter 和回退架构 | runtime 结构、依赖或加载路由变化 |
| [ART_DIRECTION.md](ART_DIRECTION.md) | 全模块统一美术语言和反模式 | 跨模块视觉基线变化 |
| [ASSET_PIPELINE.md](ASSET_PIPELINE.md) | imagegen、透明化、切片、导出与验收流程 | 资产生产方法或工具链变化 |
| [DESIGN_STATUS.md](DESIGN_STATUS.md) | 已确认、弃用与待确认的视觉方案索引 | 用户确认或否决视觉方向 |
| [SESSION_DECISIONS.md](SESSION_DECISIONS.md) | 影响多个后续任务的长期设计决策 | 出现需要跨会话保留的新决策 |
| [WORKFLOW.md](WORKFLOW.md) | 文档位置、职责和同步工作流 | 文档制度或交付流程变化 |

## 实现与进度

| 文档 | 唯一职责 |
|---|---|
| [OVERHAUL_TRACKER.md](implementation/OVERHAUL_TRACKER.md) | 每个模块／组件的阶段、资产、提示词、runtime 与验证状态；唯一进度事实来源 |
| [IMPLEMENTATION_ROADMAP.md](implementation/IMPLEMENTATION_ROADMAP.md) | 实现顺序、阶段门槛和近期里程碑 |
| [CHAT_COMPONENT_SPEC.md](implementation/CHAT_COMPONENT_SPEC.md) | 聊天真实组件、状态、几何、切片与交互合同 |
| [CHAT_MODULE.md](implementation/CHAT_MODULE.md) | 当前聊天 runtime adapter 的实现说明 |
| [CHAT_V3_SOURCE.md](implementation/CHAT_V3_SOURCE.md) | `assets/source/chat/v3/` 母版与验收证据清单 |
| [FONT_SYSTEM.md](implementation/FONT_SYSTEM.md) | 字体角色、加载、回退和实机验收规则 |

## 模块视觉规范

| 文档 | 唯一职责 |
|---|---|
| [聊天框视觉规范](modules/chat/聊天框视觉规范_战地旧书_v1.md) | 战地旧书模块的锁定视觉语言 |
| [任务模块视觉规范](modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md) | 任务详情卷宗和追踪便笺的锁定视觉语言 |
| [地图模块视觉规范](modules/map/地图模块视觉规范_远征地图卷与黄铜航向罗盘_v1.md) | 羊皮大地图和黄铜罗盘的锁定视觉语言 |
| [角色模块视觉规范](modules/character/角色属性模块视觉规范_香草同构角色面板_v1.md) | 香草同构角色面板的锁定视觉语言 |

## Runtime 与 pfUI

| 文档 | 唯一职责 |
|---|---|
| [AEUI_ADDON.md](runtime/AEUI_ADDON.md) | `addon/AzerothExpeditionUI` 的版本、依赖、命令和目录清单 |
| [CHAT_MEDIA.md](runtime/CHAT_MEDIA.md) | 聊天 runtime 媒体文件到逻辑组件的映射 |
| [FONT_MEDIA.md](runtime/FONT_MEDIA.md) | 插件内字体文件到字体角色的映射 |
| [PFUI_FORK.md](pfui/PFUI_FORK.md) | 项目维护分支相对上游的差异、功能边界、回退开关和测试组合 |
| [PFUI_UPSTREAM_SNAPSHOT.md](pfui/PFUI_UPSTREAM_SNAPSHOT.md) | 导入 pfUI 时的来源、提交和本机差异 |
| [UPSTREAM_README.md](pfui/UPSTREAM_README.md) | 导入时随附的上游 README 归档；不代表当前项目状态 |

## 仓库、法律与证据

| 文档 | 唯一职责 |
|---|---|
| [ASSETS.md](repository/ASSETS.md) | `assets/` 各层级的存储与入库规则 |
| [PROMPTS.md](repository/PROMPTS.md) | `prompts/` 中版本化执行提示词的类型和更新规则 |
| [TOOLS.md](repository/TOOLS.md) | `tools/` 中确定性脚本的输入、输出和稳定状态 |
| [THIRD_PARTY.md](legal/THIRD_PARTY.md) | 第三方材料目录和分发边界 |
| [FONTS.md](legal/FONTS.md) | 第三方字体许可证、来源与 runtime 文件映射 |
| [小地图插件图标承载评估](audits/小地图插件图标承载评估_v1.md) | 小地图插件图标容量的专项审计结论 |
| [2026-07-29 聊天参考清单](provenance/chat/SESSION_2026-07-29.md) | 对应实机参考图片的用途和保留理由 |

## `docs/` 之外的必要文件

以下内容有意不迁入 `docs/`：

- 根目录 `README.md`：仓库入口，只给出状态摘要和文档中心链接。
- 根目录 `AGENTS.md`：Codex 执行约束，必须位于代理能够自动发现的位置。
- 根目录 `NOTICE.md`：分发与权利边界声明。
- `prompts/<module>/*.md`：可直接执行、版本化且需要原样追溯的生产输入，不是
  说明文档。
- `.codex/skills/`：固定 imagegen 执行器包，目录结构由技能加载机制决定。
- `third-party/**/SOURCE.md`、许可证与校验清单：必须和对应第三方文件共同
  分发的来源证据。
- `addon/pfUI/LICENSE`：pfUI 独立分发时必须随插件保留的 MIT 许可证。
