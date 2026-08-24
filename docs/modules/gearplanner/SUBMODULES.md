# Gear Planner 子模块定义

本模块提供两套互相隔离的宿主连接：绑定 `CharacterFrame / PaperDollFrame` 的
角色伴随栏与配装方案视图，以及绑定 `InspectFrame / InspectPaperDollFrame` 的
只读观察伴随栏。角色页或几何不受支持时配装器回退为独立窗口；观察页不受支持时
完全交还第三方 Provider。AtlasLoot 持有物品目录、原生查询、来源浏览与掉率；
AEUI 只在用户先选定配装槽位后，向当前 AtlasLoot 物品行追加独立的“+”
子 Button。通用物品属性由 BonusScanner 扫描；主手／副手／远程的静态攻速与
秒伤优先只读
Nampower 物品记录，并以 AEUI 独立隐藏 Tooltip 作兼容回退，公共 GameTooltip 仍只
负责悬停展示。
模块不接管 Character／Inspect 几何、BetterCharacterStats 数据、
AtlasLoot 原按钮脚本、Wishlist 或装备监听。

## Provider 与真实对象

| ID | Provider／对象 | 功能所有权 |
|---|---|---|
| GEAR.SOURCE.ATLASLOOT | `AtlasLootDefaultFrame`、`AtlasLootItemsFrame`、`AtlasLootItem_1..30`、AtlasLoot 数据与原生查询 | AtlasLoot 持有数据库、SearchResult、分页、来源浏览、Wishlist 及物品行交互；AEUI 只读建立槽位索引，并在原生物品页刷新后更新自己的选入子 Button |
| GEAR.STATS.BONUSSCANNER | BonusScanner:ScanItem() | BonusScanner 持有 Turtle Tooltip 解析；AEUI 立即复制单件结果并排除可识别的套装阈值行 |
| GEAR.STATS.WEAPON | Nampower `GetItemStats()`；`AzerothExpeditionUIGearPlannerWeaponScanner` | AEUI 只读物品 `minDamage`／`maxDamage`／`delay` 计算主手、副手、远程静态秒伤与攻速；Nampower 不可用或字段不完整时只扫描自己的隐藏 Tooltip，不修改公共 GameTooltip |
| GEAR.STATS.FALLBACK | 无通用数值 provider | BonusScanner 缺失时保留装备选择与来源功能；通用属性为空，可解析的武器行继续显示 |
| GEAR.CURRENT | `GetInventoryItemLink()`、`GetInventorySlotInfo()`、`UNIT_INVENTORY_CHANGED` | Blizzard 持有当前穿戴；AEUI 只读基础 itemID，用于导入方案与当前装备属性基线，不写真实装备 |
| GEAR.SAVED | AzerothExpeditionUIDB.gearplanner.characters | AEUI 按服务器／角色保存多套方案、活动方案、已明确保存的槽位选择与观察来源 metadata；未保存草稿不进入 SavedVariables |
| GEAR.HOST.CHARACTER | `CharacterFrame`、`PaperDollFrame` | Blizzard／Character 模块持有角色页与分页；Gear Planner 只挂载自己的子控制器和伴随栏，不改写主框几何 |
| GEAR.HOST.BETTERSTATS | `BetterCharacterAttributesFrame` | BetterCharacterStats 继续持有中心属性；它不进入伴随栏 |
| GEAR.COMPANION.CURRENT | `S_ItemTip_InspectFrame` | S_ItemTip 持有装备明细、尺寸、刷新与交互；AEUI 只在角色页可见时一次性锚定并协调显隐 |
| GEAR.COMPANION.STATS | `StatCompareSelfFrame` | StatCompare 持有属性扫描、动态尺寸、拖动与保存；AEUI 只在 Provider 显示完成后一次性锚定并协调显隐 |
| GEAR.HOST.INSPECT | `InspectFrame`、`InspectPaperDollFrame` | Blizzard／pfUI 持有观察页、目标单位、装备槽与分页；AEUI 只挂载子控制器和窄栏 |
| GEAR.INSPECT.GEAR | `S_ItemTip_InspectFrame` | 观察上下文中显示目标装备；与角色页使用同一 Provider，但状态捕获与恢复完全分离 |
| GEAR.INSPECT.TARGET | `StatCompareTargetFrame` | StatCompare 持有目标属性内容与动态尺寸；AEUI 只在“属／比”视图协调显隐和锚点 |
| GEAR.INSPECT.SELF | `StatCompareSelfFrame` | 只在用户显式选择“比”且左侧净空足够时显示自己的属性 |
| GEAR.INSPECT.SNAPSHOT | `InspectFrame.unit`、`GetInventoryItemLink()` | Blizzard 持有观察数据；AEUI 只在 `INSPECT_READY` 或 S_ItemTip 完成更新后复制 itemID 快照 |

## AEUI 运行时对象

| ID | 对象 | 合同 |
|---|---|---|
| GEAR.COMPANION.RAIL | `AzerothExpeditionUICharacterCompanionRail` | CharacterFrame 子对象；角色 PaperDoll 每次打开时默认只显示窄栏，当前可用的“装／属／配／双”均为可再次点击收起的互斥视图入口 |
| GEAR.INSPECT.CONTROLLER | `AzerothExpeditionUIInspectCompanionController`、PaperDoll 子控制器 | 与 Character companion 独立；监听 Inspect／PaperDoll 显隐、分页和数据就绪，不包装原生脚本 |
| GEAR.INSPECT.RAIL | `AzerothExpeditionUIInspectCompanionRail` | InspectFrame 右侧 `28 UI` 窄栏；按条件显示“装／属／比／存” |
| GEAR.INSPECT.SAVE | “存” Button | 数据就绪后把目标 19 槽 itemID 快照新建并激活为观察参考方案；不自动打开完整配装窗口，不覆盖原方案 |
| GEAR.FRAME | AzerothExpeditionUIGearPlannerFrame | 伴随模式保持 `UIParent` Parent，以 `560×555` 锚到角色页右侧；角色页禁用、缺失或非 `384×512` 时恢复 `760×555` 独立可移动窗口 |
| GEAR.PROFILE | 当前活动方案数据、会话草稿、“保存”、导入／清空、`<／>` 与“方案管理” | 打开配装时从已保存方案复制运行时草稿；选装、导入和清空只改草稿，只有点击“保存”才整体写回槽位。关闭／收起或切换活动方案会丢弃未保存草稿；管理窗继续支持使用、新建、复制、重命名、分页与二次确认删除；不自动改穿角色装备 |
| GEAR.SLOT | 19 个 AzerothExpeditionUIGearPlannerSlot* | 左键设定当前配装目标并打开 AtlasLoot 原生浏览器，Shift 左键把已选装备链接贴入聊天输入框，Ctrl 左键打开已选来源；右键恢复该槽的已保存基线，Alt 右键才清空草稿槽位。相对当前装备的“更换／新增／未填”继续使用黄铜差异态；相对已保存方案的未保存槽位另用冷灰蓝描边、左缘短标与 `*`，两类状态可同时存在 |
| GEAR.PLAN.COMBINED | 19 槽与属性对比区 | 伴随及独立模式都同时显示装备与“当前／配装／变化”；任何槽位、活动方案或玩家实际装备变化均同步刷新属性和槽位差异态 |
| GEAR.PICKER | AtlasLoot 原生查询／浏览 UI、30 个按需显示的 AEUI 选入子 Button、目标提示与“结束选装” | 物品名、itemID、Boss、副本、选项、分页和来源跳转全部由 AtlasLoot 原生 UI 处理；AEUI 仅在与当前槽位兼容的物品行右侧显示“+”，已选物品显示“已” |
| GEAR.TOTALS | Gear Planner 右侧属性区 | 同时汇总 BonusScanner 通用静态属性与三武器槽静态秒伤／攻速，按行比较当前和配装；普通数值及秒伤按增减用绿／红，攻速变化固定琥珀色，缺少对应武器时显示破折号与“新增／移除” |
| GEAR.SOURCES | AtlasLoot 原生来源行、普通点击与已选槽 Ctrl 左键 | AtlasLoot 原生行继续负责 SearchResult／Wishlist 到 Boss 来源的跳转；AEUI 只保存选入物品的来源 metadata，不创建或修改 SearchResult |

## 槽位与约束

- 使用 Head、Neck、Shoulder、Back、Chest、Shirt、Tabard、Wrist、Hands、
  Waist、Legs、Feet、Finger0／1、Trinket0／1、MainHand、SecondaryHand、
  Ranged 共 19 个原生槽位。
- AtlasLoot 的 #s*#、#h*#、#w*# 标记负责第一层候选分类。
- 双手武器选入主手时清空副手；在已有双手武器时选入副手会清空主手。
- 右键恢复主手或副手时将两槽作为一组恢复到本次打开时的已保存基线，避免恢复后制造
  双手武器与副手并存的非法草稿。
- Ring 与 Trinket 候选分别复用于两个实例槽；模块不自动判定唯一装备。

## 功能不变量

- 只用 `hooksecurefunc` 在 `AtlasLoot_ShowItemsFrame` 完成后刷新 AEUI 子 Button；
  不替换 AtlasLoot 物品行的 OnClick，不改其 Parent、Point、尺寸、
  SearchResult、Wishlist 或 SavedVariables。Shift 链接、Ctrl 试穿、Alt Wishlist 及
  普通来源跳转继续完全由 AtlasLoot 持有。
- 选装期间只临时下调 `GEAR.FRAME` 自身 strata，使 AtlasLoot 原生窗口保持前景；
  退出选装后恢复 Gear 原 strata，不改 AtlasLoot 的 strata 或几何。
- 不 Hook 或覆盖 BonusScanner 的脚本、Parent、Point 或 SavedVariables。
- 不 Reparent、缩放或改写 S_ItemTip／StatCompare 的数据与交互；只在 Character、
  Inspect 及其 PaperDoll 显示／分页、Provider 加载、观察数据就绪或 Provider 自己
  刷新后执行有限的一次性锚定，不使用维护循环。
- 不修改玩家真实装备、背包、Wishlist、AtlasLoot QuickLook 或 CharacterFrame 几何。
- Gear 槽位 Shift 左键只把方案物品链接插入 WIM 或 Blizzard 聊天输入框；没有活动
  输入框时可用原生 `ChatFrame_OpenChat` 打开待发送文本，不自动发送消息。相同 itemID
  保持普通态；不同物品或新增装备使用明显黄铜描边与浅底色，当前有装备但方案未填只用
  较弱“未填”提示，不以红绿暗示配装优劣。
- 槽位编辑以当前已保存方案为单一基线，不保留 A→B→C 的多步历史；C 上右键直接恢复
  A。未保存判断只比较 19 槽 itemID，物品缓存补全名称／图标不会制造伪脏状态。
  “保存 (n)”只在存在未保存槽位时可用并一次提交全部草稿；关闭窗口、Esc、收起“配”、
  切换到其他伴随视图、切换活动方案、禁用模块或 `/reload` 都不自动提交。
- 属性对比以玩家当前 19 槽为基线，方案中未填槽位按空槽计算；“导入当前装备”
  后差值应归零。`UNIT_INVENTORY_CHANGED` 只在 Gear 视图可见时重新计算当前列，
  不使用维护循环。
- 角色 PaperDoll 每次会话默认收起所有伴随视图；“装／属／配／双”采用同一互斥
  状态机，点击非当前入口会原子切换，重复点击当前入口、配装窗口关闭 Button 或 Esc
  只收起伴随内容而不关闭 CharacterFrame。SavedVariables 中的上次入口不自动展开。
  配装视图整体合同为
  `384 + 8 + (28 + 4 + 560) = 984 UI`，内部装备与属性始终同屏。第三方当前装备
  与 StatCompare 在有效宽度至少 `1060 UI` 且角色页左右实际净空足够时组成独立
  “双”视图；切到“装／属／配”或收起时同时退出双栏，配装视图不启用重复双栏。
- S_ItemTip／StatCompare 缺失时省略对应入口；Character 模块禁用、对象缺失或
  几何不受支持时，`/aeui gear` 回退独立窗口。禁用 Gear Planner 时恢复本次角色页
  与观察页会话捕获的 Provider 锚点与显隐。
- 观察页默认只显示目标装备或目标属性；“比”只在 StatCompare 双 Provider 与左右
  实际净空同时满足时出现，并隐藏 S_ItemTip。切到观察页其他分页时释放观察会话，
  不把完整 Gear Planner 挂到 InspectFrame。
- “存”只在观察数据就绪后出现；快照新建为独立方案并设为当前活动方案，原方案仍由
  `<／>` 切换保留。重复保存完全相同且未编辑的快照只激活既有方案。
- 方案删除要求二次确认且至少保留一套；复制方案只复制槽位内容，不伪造新的观察
  快照身份。
- AtlasLoot 缺失时窗口仍可打开、导入、清空并保存方案，但点击槽位会
  明确提示原生浏览器不可用，不再回退自建候选窗口；BonusScanner 缺失时通用属性
  为空，武器行仍尝试用 Nampower／隐藏 Tooltip 解析，方案内已有装备、导入与保存
  继续工作。
- 首版不把套装阈值、触发／使用效果、附魔、随机词缀、天赋或 Buff 计入总值。
