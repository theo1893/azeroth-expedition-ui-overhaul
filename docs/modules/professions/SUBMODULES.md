# 生产专业真实对象与所有权

## Provider

Turtle WoW 的 `Blizzard_TradeSkillUI` 与 `Blizzard_CraftUI` 持有配方、分类、
搜索过滤、技能等级、材料数量、冷却、制作数量、单次制作接口及取消逻辑。
pfUI 的 `Profession` 皮肤统一排版；AEUI 已加载时复用其远征材质。
Aux 继续持有材料成本和材料右键查询，不改写其脚本或数据。

## 登记对象

| 范围 | 真实对象 | 改造边界 |
|---|---|---|
| 普通生产页 | `TradeSkillFrame` | 覆盖所有使用该窗口的生产专业，包括炼金、锻造、工程、制皮、裁缝、烹饪、急救、熔炼等；按实际 provider 路由而非专业名称判断 |
| 附魔页 | `CraftFrame` | 附魔共用布局；猎人训练等复用该框的功能保留原生显隐与操作 |
| 配方目录 | `*ListScrollFrame`、`Craft1..22`／`TradeSkillSkill1..22`、`*CollapseAllButton` | 22 行、原生难度色、折叠、选中与滚动 |
| 查询与过滤 | `CraftFrameSearchBox`／`TradeSkillSearchBox`、两套 `*MatsCheckButton`／`*SkillCheckButton`、TradeSkill 的类别／部位下拉 | 只调整位置与皮肤，保留原生过滤 |
| 详情 | `*DetailScrollFrame`、`*DetailScrollChildFrame`、名称／图标／需求／说明／冷却 | 原生信息与 pfUI 物品说明；更新后的内容重新计算滚动范围 |
| 材料 | `CraftReagent1..8`／`TradeSkillReagent1..8` 与对应 Name／Count／IconTexture | 固定两列、最多四行；库存、灰态、提示框由 provider 更新 |
| 操作 | `*CreateButton`、`*CancelButton`、TradeSkill 的 CreateAll／Decrement／InputBox／Increment | 固定底部操作区；TradeSkill 制作／全部制作由连续队列接管，其他操作保留 |

没有生产配方页的采集技能不创建空窗口。未启用的 ATSW 等独立替代界面不接管。
仅针对 Turtle 的实际搜索控件启用工作台布局，其他客户端保留 pfUI 兼容分支。

## 连续制作

pfUI 的 `profession-queue` 模块持有 `TradeSkillQueueButton`、依赖规划与短期制作队列。
只使用当前 `TradeSkillFrame` 可枚举的已学物品配方，按 itemID 匹配中间产物；
只读取背包库存，按依赖顺序先选中实际制作配方，再调用原生 `DoTradeSkill(index, count)` 批量完成同一种材料，以原料扣除与产物增量共同确认，兼容缺失的旧版施法结束事件。
制作／全部制作点击由队列接管，数量输入、Aux 逻辑继续保留；队列不写 SavedVariables，重载即结束。

`TradeSkillRawMaterials` 为当前配方详情中的只读基础原料汇总，复用连续制作规划算法。
`pfUIProfessionMaterialsUpdater` 合并选中、数量和库存变化后的显示更新，不触发制作。

`TradeSkillCreateButton` 按填写次数规划，`TradeSkillCreateAllButton` 在单批上限内
计算完整依赖链的最大可制作次数。启用状态按基础材料判断，原生刷新不能在队列运行时开新批。

跨配方交接只在定时器中选好下一配方与数量，随后等待制作按钮的真实点击。
`DoTradeSkill` 只在点击回调中调用；同配方重复由原生批量完成。
