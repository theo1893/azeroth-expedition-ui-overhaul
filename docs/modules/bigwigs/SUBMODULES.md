# BigWigs 功能边界

BigWigs 独立持有副本事件、同步、计时条、文字／声音警告和团队标记；AEUI 不接管
战斗判断。本模块仅维护逻辑，不生产美术资产。

## 常见光环

`Plugins/CommonAuras.lua` 持有团队关键技能的施法识别、同步、独立显示开关和计时条。
树皮术／德鲁伊狂暴使用施法者命名，灵魂连接使用真实受术者命名；复用现有 BigWigs
同步频道与 CandyBar，不由 AEUI 接管，也不改变其他关键技能的判断。

## 木喉要塞（Timbermaw Hold）

运行时位于 `addon/BigWigs/Raids/TMH/`，由 BigWigs TOC 加载。

- Boss：Karrsh、Kronn、Loktanag、Partath、Ormanos、Rotgrowl、Ursol、Selenaxx、
  Perotharn、Trioch。
- 小怪：TimbermawTrash；自动转火沿用源模块选项，默认关闭。
- Support：只为木喉模块查找当前目标／团队成员目标中的真实单位。
- 共享依赖：现有 BigWigs Core、CandyBar 2.2、AceEvent 2.0 和 `!Libs` 的
  Babble-Boss 2.2／Babble-Zone 2.2；沿用现有计时条与音效。
- `!Libs` 仅补齐木喉 Boss 的英文键和中文名称；BigWigs 核心仅补齐副本菜单名称。

禁用单个 Boss／小怪模块使用 BigWigs 原生模块开关；整体关闭使用插件管理器。
不改变其他副本、ShaguDPS 或 AEUI 姓名板的仇恨来源。
