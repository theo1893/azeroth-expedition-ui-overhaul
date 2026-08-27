# Gear Planner 子模块美术基线

| ID | 稳定基线 |
|---|---|
| GEAR.FRAME | `GEAR-MAIN-V1` 军需官折叠案板；深胡桃皮革平铺内场、八切片外边、左侧三铰链与独立标题牌。伴随／独立宽度只拉伸登记安全区，不缩放整图 |
| GEAR.PROFILE | 保存为突出的氧化黄铜锁扣；导入／清空／方案管理为较安静皮革工具签；方案名、页数和文字保持动态。首批只锁定 normal 材料，hover／pressed／disabled 暂复用 normal 并由运行时明暗反馈，后续独立生产 |
| GEAR.SLOT | 真实 19 Button 共用三切片皮革标签；icon、槽位名、物品名和品质保持动态。accepted `GEAR-SLOT-STATES-V1` 另提供固定尺寸的强黄铜差异夹签、弱未填夹签与冷灰蓝修订缝带，取代整框 wash／描边；`差异／新增／未填` 与 `*` 仍由运行时绘制，两类 sprite 可叠加，不得烘焙红绿优劣 |
| GEAR.PLAN.COMBINED | 左侧 19 槽与右侧属性纸始终同屏；不能把二者合成一个失去对象边界的整屏背景 |
| GEAR.TOTALS | 独立九切片暖赭统计纸；标题、属性名、当前／配装／变化值、绿红差值和琥珀攻速差值全部动态，使用深墨褐高对比文字 |
| GEAR.COMPANION.RAIL | 保持独立 `40 UI` 窄栏对象，不与 CharacterFrame 或主案板烘焙；四个真实 Button 复用 `GEAR-MAIN-V1` 控件 atlas 的空白深皮革工具签，normal／hover／pressed／selected 由运行时明暗反馈，动态文字与可用性保持独立 |
| GEAR.INSPECT.RAIL | 与 Character 伴随栏同族但保持独立对象；“装／属／比／存”状态不得烘焙到 InspectFrame 或第三方面板 |
| GEAR.INSPECT.SAVE | 真实动态 Button；数据未就绪时由逻辑隐藏，未来美术不得烘焙目标名、槽数或完成状态 |
| GEAR.PICKER | AtlasLoot 搜索、30 格行、分页、来源和 Wishlist 全部保持原生；AEUI 小型“+／已”Button 与目标提示不进入主案板 atlas |
| GEAR.SOURCES | 来源名称、件数与掉率保持 Provider 动态内容，不进入 Gear 静态资产 |

`GEAR-MAIN-V1` 与 `GEAR-SLOT-STATES-V1` runtime 位于
`addon/AzerothExpeditionUI/Media/GearPlanner/`，所有逻辑尺寸与命中区保持原合同，
纹理采样密度为 `2×`。
