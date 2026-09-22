# BigWigs 功能边界

BigWigs 独立持有副本事件、同步、计时条、文字／声音警告和团队标记；AEUI 不接管
战斗判断。本模块仅维护逻辑，不生产美术资产。

## 外部分支参考

用户提供的另一位开发者维护版本完整保留在
[`third-party/reference-addons/BigWigs/`](../../../third-party/reference-addons/BigWigs/)，
TOC 自报 `Golden / 2.0.0 / revision 30139`。作为组件合并与后续优化参考，
不由客户端加载或加入 AddOns 分发；来源说明见
[参考快照说明](../../../third-party/reference-addons/README.md)。运行版本仍为 `addon/BigWigs/`。

## Golden 预警与团队工具

- `Plugins/Bars.lua` 继续持有 CandyBar 的计时、区间尾段、点击回调与模块清理；
  `VerticalBars.lua` 只镜像倒计时的显示，默认关闭，血量／法力／计数条保持横向。
  BigWigs 面板“插件模块 → 竖向时间轴 → 启用”控制显示，`/bwv on`、`/bwv off`
  与 `/bwv test` 提供相同开关及预演入口；开关保存在原有 BigWigs 配置中。
- `ResistCheck.lua` 使用 BigWigs 原生同步查询队伍／团队成员抗性；物理项读取有效
  护甲，未响应成员单独列出，通报由用户点击触发。
- `WorldBossCooldown.lua` 使用真实世界 Boss 击杀与服务器锁定消息维护每角色记录，
  `/bwcd` 打开面板；七天为参考实现的估算周期，不生成副本 Boss 的个人锁定。
- Core 提供点击条、生命／法力监控条、真实单位查找、团队标记名称与施法减速系数；
  原有死亡事件分发同时保留模块扩展与核心清理。扩展客户端接口存在时读取 GUID／
  施法事件，缺失时保留原生日志和真实单位查询。

## 副本与 Boss 机制

Golden 新增的 Ezzel、Blackwing Alchemist、Twin Golems、Kara Trash 与
Construct Trash 由 TOC 加载；原有 Incindis／Thaurissan 文件也纳入加载。
卡拉赞、黑翼之巢、熔火之心、克苏恩和部分纳克萨玛斯机制合并到原模块名下，
继续使用项目 SavedVariables；象棋的旧屈从开关迁移至拆分后的对应选项。
Anomalus 独立监控面板由自身模块创建、配置与清理。

中文自身 Debuff 起始匹配、Anomalus 精确同步与名字提取、麦迪文灾祸层数和标签、
镣铐碎裂日志回退及木喉修复继续由对应 Boss 模块持有。缺失的旧 TOC／XML 引用已
移除，虫子三兄弟、RespawnTimers、法师助手与常见光环保留项目实现。

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
- `!Libs` 补齐木喉及新增副本 Boss 的英文键和中文名称；不改变其他插件的数据所有权。

禁用单个 Boss／小怪模块使用 BigWigs 原生模块开关；整体关闭使用插件管理器。
不改变其他副本、ShaguDPS 或 AEUI 姓名板的仇恨来源。
