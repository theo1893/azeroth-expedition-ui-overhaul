# 战士 DPS 消耗品清单

> 独立知识记录：不属于 Azeroth Expedition UI／overhaul 的指导文件，
> 不参与当前设计、实现、验收或发布决策。

下表固定当前双手武器战的团队副本携带清单。斜杠表示同一用途二选一；没有斜杠
的条目分别携带。物品效果、覆盖和目标类型最终以 1.18.1 客户端 Tooltip／光环为准，
本清单只登记真实物品，不构成任何 UI、循环或自动使用要求。

| 使用阶段 | 物品 | Item ID | 效果／选择规则 |
|---|---|---:|---|
| 生存常驻 | [泰坦合剂](https://database.turtlecraft.gg/?item=13510) | <code>13510</code> | 最大生命值 <code>+1200</code>，持续 <code>120 分钟</code>、死亡保留；同一时间只能有一种合剂 |
| 生存常驻 | [赞扎之魂](https://database.turtlecraft.gg/?item=20079)（血量赞扎） | <code>20079</code> | 耐力、精神各 <code>+50</code>，持续 <code>120 分钟</code>；同一时间只能有一种赞扎药剂 |
| 输出常驻 | [猫鼬药剂](https://database.turtlecraft.gg/?item=13452) | <code>13452</code> | 敏捷 <code>+25</code>、近战暴击 <code>+2%</code>，持续 <code>60 分钟</code> |
| 输出常驻 | [土狼兴奋剂](https://database.turtlecraft.gg/?item=8410) | <code>8410</code> | 力量 <code>+25</code>，持续 <code>60 分钟</code> |
| 输出常驻 | [魂能之力](https://database.turtlecraft.gg/?item=12451) | <code>12451</code> | 力量 <code>+30</code>，持续 <code>30 分钟</code> |
| 输出常驻 | [力量卷轴 IV](https://database.turtlecraft.gg/?item=10310) | <code>10310</code> | 力量 <code>+17</code>，持续 <code>30 分钟</code>；低等级卷轴只作缺货替代 |
| AP 酒 | [冬泉火酒](https://database.turtlecraft.gg/?item=12820)／[黑根酒](https://database.turtlecraft.gg/?item=42014) | <code>12820</code>／<code>42014</code> | 二选一；冬泉火酒为近战 AP <code>+35</code>、持续 <code>20 分钟</code>。黑根酒按当前 Tooltip 使用；官方热修已确认其不与魂能之击叠加 |
| 增益食物 | [沙漠肉丸子](https://database.turtlecraft.gg/?item=20452)／[营养的魔法蘑菇](https://database.turtlecraft.gg/?item=51720) | <code>20452</code>／<code>51720</code> | 二选一；进食至少 <code>10 秒</code>，力量 <code>+20</code>，持续 <code>15 分钟</code> |
| 武器强化 | [元素磨刀石](https://database.turtlecraft.gg/?item=18262)／[神圣磨刀石](https://database.turtlecraft.gg/?item=23122) | <code>18262</code>／<code>23122</code> | 普通目标用元素：近战暴击 <code>+2%</code>、<code>30 分钟</code>；亡灵目标用神圣：对亡灵 AP <code>+100</code>、<code>60 分钟</code> |
| 恶魔特攻 | [屠魔药剂](https://database.turtlecraft.gg/?item=9224) | <code>9224</code> | 仅恶魔目标：AP <code>+265</code>，持续 <code>5 分钟</code> |
| 战前工程 | [侏儒作战小鸡](https://database.turtlecraft.gg/?item=10725) | <code>10725</code> | 工程学 <code>230</code> 的饰品主动；战前装备并召唤一只持续最多 <code>90 秒</code>的作战小鸡，不按普通消耗品处理 |
| 战斗工程 | [地精工兵炸药](https://database.turtlecraft.gg/?item=10646) | <code>10646</code> | 工程学 <code>205</code>；近身 AoE 火焰伤害 <code>450–751</code>，同时自伤 <code>375–626</code>，冷却 <code>5 分钟</code> |

开打检查顺序为“泰坦／赞扎 → 猫鼬／力量组／AP 酒 → 食物 → 磨刀石 →
恶魔特攻（仅对应 Boss）→ 战前小鸡 → 聚怪后工兵”。小鸡属于工程饰品主动，
不按普通消耗品处理；地精工兵炸药是带自伤的战斗工程消耗品。

[Turtle WoW 1.18.1 热修](https://forum.turtlecraft.gg/viewtopic.php?t=24392)
是黑根酒覆盖关系的当前公开依据。其余数值来自对应物品页；若服务器热修改变
Tooltip，应更新本表旧值而不是在下方追加版本流水。
