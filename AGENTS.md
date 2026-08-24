# Azeroth Expedition UI 项目入口

Codex 进入仓库后先读本文件。这里给出项目边界、文档索引、当前状态和最小
检查入口；不要为普通修复加载全仓库历史。

## 项目边界

- 目标客户端：Turtle WoW `1.18.1`，Interface `11200`。
- 可部署插件位于 `addon/pfUI/` 与 `addon/AzerothExpeditionUI/`。
- pfUI 保留数据、事件、交互、SavedVariables 与兼容能力；AEUI 只重做明确
  登记模块的视觉、布局及必要连接，不改变无关功能。
- 改模块 A 时只修改模块 A 的真实 pfUI／Blizzard／第三方对象。未登记对象
  必须继续由 provider 正常加载并可局部回退。
- `addon/` 只放运行时代码、媒体与分发许可证，不放 Markdown。
- 默认在 `main` 开发；除非用户明确要求，不自动 push。

## 当前状态快照

| 模块 | 当前状态 | 下一步 |
|---|---|---|
| Core／pfUI | AEUI `0.9.0`，scoped ownership `P5`；Gear Planner runtime `0.9-zhCN` 已接入 Character 与 Inspect 两套独立伴随会话并保留独立回退 | 实机验证模块隔离、旧配置迁移、两套伴随栏与配装工具回退 |
| Chat | runtime `1.22 / P5`；Full V1 主框、Dark V2 Tab、Dark V1 输入已接入；右框隐藏，经典颜色透传 | 实机验证 Tab、缩放、输入、频道颜色和左框消息回收 |
| Quests | runtime `1.28`、Theme `1.11`；已完成并挂载的书体、目录、奖励槽、火漆／闭合载体均为 2× runtime；事务菜单未启用 | 完整重启后实机验证双纹理书体接缝、奖励槽、火漆滚动裁切；Tracker 重新确认真实区域 |
| Action Bars | AEUI `0.9.0`；Slot／Rail `P6`；Field Kit `2.9`、Focus `3.0`、Sidebar Group `1.0`、Target Markers `2.3` 均 `P5`；Player／Target 为 `480×48 / 0.8`、底锚点 `408 UI`，保持 `23 UI` Aura 并按 `16×2` 向屏幕两侧展开，两框之间留 `64 UI` 中央视线缝；TargetTarget 保持每排 `8` 枚并向右展开，下方读条与 Combat Deck 原位；三框布局按角色版本应用一次；所有角色 DDPS 统一 `(650,-615)` | 实机验证 `17–32` 个 Aura 的双排向外展开、中央净空、主框与下方三条读条间距及另一角色 v2 默认迁移，再验证皮革标记方阵、坦克／一键 Button、ArchiTotem 分离、AutoBar popup／网格、DDPS 中央视野、姿态尺寸及相邻 provider |
| Map | WorldMap 继续暂停；Minimap runtime `7.6`，mask、V4 non-bottom 托盘与 V7 bottom 收纳袋为高分辨率 runtime；V3 罗盘／扣具／插槽因只保留 1× accepted source 登记明确例外且未伪放大 | 完整重启后实机验证 mask、V4 九切片、V7 徽记压接、袋内净空、0／6／12／22／30 排布、缩放、显隐及回退 |
| Spellbook | accepted `SB-A2-DONOR V1` source/runtime 保留，AEUI adapter 与 Spellbook ownership 暂停；当前回退 pfUI 技能书 | 明天依据 handoff 实机图核对四块 TGA 对位、层序、provider region 与控件净空 |
| Talents | `P1 / paused`；已与 Spellbook 拆分，真实动态节点／分支边界已对齐 | 等用户明确恢复后制作独立 `TL-SIM-V1` |
| Character | `P2–P5 / active`；runtime `2.0`，基础层、属性纸、抗性槽、E1／E2-A 装备槽、F1 Tabs、E3 Ammo 与分页共用档案页均以 2× runtime 接入；Gear Planner `0.9-zhCN` 追加角色与观察伴随栏，`560×555` 配装视图将装备与当前／配装／变化属性对比同屏，原生 UI 几何与动态内容所有权不变 | 实机复核既有 Character 组件，并验证 `984 UI` 配装净空、即时属性对比、角色三视图及观察“装／属／比／存”、分页、Provider 缺失与禁用回退 |
| Gear Planner | runtime `0.9-zhCN / P5`；查询与来源浏览直接使用 AtlasLoot 原生 UI，AEUI 只向兼容物品行追加选入 Button；`560×555` 视图将 19 槽与“当前／配装／变化”属性对比同屏，主手／副手／远程追加静态秒伤与攻速比较，方案管理与 Inspect 会话保持 | 实机验证武器秒伤／攻速、属性对比、实际换装即时刷新、AtlasLoot 原生交互、方案 CRUD／重载、角色／观察相邻回归及 Provider／Gear 禁用回退 |
| Unit Frames | runtime `1.9`；Bars、Raid A2、Player V5 与姓名板 `NP-TARGET-CUE-V1` 已从 accepted source 导出为 2× runtime；团队标记已与血条显隐解耦；Target／TargetTarget／Focus 外壳 route 继续暂停并回退 pfUI | 完整重启后实机验证团战目标指针、隐藏血条＋团队标记堆叠、禁用回退，并相邻回归 Bars、40 人 Raid、Player V5 层序与 UI Scale |

详细状态以 [docs/PROGRESS.md](docs/PROGRESS.md) 和目标模块的
`PROGRESS.md` 为准。

## 文档索引

全局只保留：

- [整体美术基线](docs/GLOBAL_ART_BASELINE.md)
- [模块整体进度](docs/PROGRESS.md)

每个模块只保留四份长期文档：

```text
docs/modules/<module>/
  SUBMODULES.md                 真实对象、状态与功能所有权
  ART_BASELINE.md               主模块稳定美术 Prompt
  SUBMODULE_ART_BASELINES.md    子模块稳定美术 Prompt
  PROGRESS.md                   当前状态、待实机项与回退
```

现有模块目录：[actionbars](docs/modules/actionbars/)、
[chat](docs/modules/chat/)、[quests](docs/modules/quests/)、
[map](docs/modules/map/)、[character](docs/modules/character/)、
[unitframes](docs/modules/unitframes/)、
[spellbook](docs/modules/spellbook/)、[talents](docs/modules/talents/)、
[gearplanner](docs/modules/gearplanner/)。

资产正在生产时，目标模块可临时存在一份 `CURRENT.md`；它只保存当前可执行
Prompt、固定输入、调用计数、当前候选和下一决定，不追加逐稿流水。资产接受或
放弃后立即删除。禁止恢复 `work/` 文档树、决策日志、测试记录或独立路线图。

`README.md` 只作项目介绍。Git 提交历史承担旧 Prompt、失败稿、日期和实现
演进的追溯职责。

## 最小工作路径

仓库工作流由
[run-aeui-asset-workflow](.codex/skills/run-aeui-asset-workflow/SKILL.md)
定义。开始任务时只选一条：

1. 普通 Lua／布局修复：改目标模块，执行
   `conda run -n py312 python tools/check.py quick --module <module>`，随后尽快
   进入游戏验证。
2. 位图改变：先确认真实展示区和简单本地预演，再使用固定
   `imagegen-0-143-0`；接入后执行
   `conda run -n py312 python tools/check.py assets --module <module>`。
3. TOC、加载顺序、多模块或分发变更：执行
   `conda run -n py312 python tools/check.py release`。

普通逻辑修复不得触发全资产导出、全部模拟渲染、历史 Prompt 审计或仓库级
mock 测试。静态检查只能证明语法和包装，不能证明游戏行为；Turtle WoW 实机
结果是最终权威。

## 文档更新触发条件

- 内部实现、锚点算法或一次失败尝试：通常不更新文档。
- 模块阶段、用户实机结论、公开命令／配置、功能所有权或回退方式变化：更新
  目标模块 `PROGRESS.md`，替换旧结论，不追加日期流水。
- 主模块阶段或项目规则变化：再同步 `docs/PROGRESS.md` 与本页状态表。
- 美术 DNA 或真实组件边界变化：才更新对应 baseline 或 `SUBMODULES.md`。

长期文档不得记录命令输出、测试 transcript、逐次 ImageGen 尝试、流程错误、
mutable Lua／TOC SHA 或重复的 source manifest 内容。

## 运行时与资产规则

- 资产粒度必须匹配真实逻辑对象；Button、Tab、输入框、滚动条、状态条、槽位
  和交互状态分别定义。允许共用 atlas，但必须保留明确 UV／manifest。
- 禁止把动态文字、图标、计数、冷却、任务状态或真实按钮烘焙进静态背景。
- 视觉权威依次为：用户锁定图与模块 Prompt、全局美术基线、真实组件合同、
  用户接受的 `assets/source/`、结构参考。
- ImageGen 只能使用仓库 `imagegen-0-143-0` Skill。每个已授权段最多五次实际
  生成；流程错误不计入。模型负责美术 donor，确定性脚本负责精确几何时，必须
  保持二者职责清晰。
- manifest 只固定不可变 source/runtime 媒体；不得固定会频繁变化的 Lua、TOC、
  Bootstrap 或文档哈希。
- UI 逻辑尺寸与纹理采样尺寸必须分离。新导出默认使用 `2 texels / UI unit`；
  Lua 的 Width／Height、锚点和命中区保持 provider 原生几何，只通过更高分辨率
  TGA 与对应 UV 提升清晰度。不得把既有 1× runtime 放大伪装成 2×；必须直接
  从 accepted high-resolution source 导出，并继续满足单边不超过 `1024` 的
  Turtle WoW 限制。确需 1× 时在目标 manifest 明确记录例外。
- Hook 后不得用维护循环持续改写 Parent、Point、Width 或 Height。

## 实机与跨设备

- 每次交付只给出聚焦的实机清单：改动项、一个相邻回归项、必要的禁用／缺失
  provider 回退，以及确有帮助时的 `/aeui status` 值。
- 只有用户实机确认才能标记 `P6`。组件完全验收后直接清除其 `generated/`、
  临时 `handoff/` 和 `CURRENT.md`；不再设置额外 `P6-C` 阶段或关闭测试。
- 跨设备默认只同步 tracked 代码、accepted source、runtime、manifest 与当前
  进度。`generated/` 始终 ignored。确需传递未接受的精确候选时，只临时提交
  `handoff/<module>/<component>/` 的最小像素和 metadata，恢复后立即删除。
