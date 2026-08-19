# Map 子模块定义

本文件只定义地图模块与 pfUI／原生对象的对齐。美术见
[ART_BASELINE.md](ART_BASELINE.md)，状态见 [PROGRESS.md](PROGRESS.md)。

## pfUI 来源

| 文件 | 已证实职责 | 项目处理 |
|---|---|---|
| [`modules/map.lua`](../../../addon/pfUI/modules/map.lua) | WorldMap 布局、缩放／拖动及地图相关呈现 | 当前由 pfUI 正常加载；以后只在 Map 接管范围内替换外壳与控件 |
| [`modules/mapcolors.lua`](../../../addon/pfUI/modules/mapcolors.lua) | 地图颜色行为 | 保留数据／配置，不把颜色烘焙进外框 |
| [`modules/mapreveal.lua`](../../../addon/pfUI/modules/mapreveal.lua) | 未探索区域显示增强 | 保留功能，独立于外壳美术 |
| [`modules/minimap.lua`](../../../addon/pfUI/modules/minimap.lua) | `pfMinimap` 140×140 默认 provider、方形 mask、滚轮缩放、区域／坐标、邮件与战场入口；原生边框、缩放按钮、时间及 `MinimapToggleButton` 被隐藏 | adapter 保留真实内容与行为，替换 provider 外壳、mask 与相邻对象布局 |
| [`modules/tracking.lua`](../../../addon/pfUI/modules/tracking.lua) | 追踪入口与状态 | 保留功能，按真实 Button 换肤 |
| [`modules/addonbuttons.lua`](../../../addon/pfUI/modules/addonbuttons.lua) | 每 5 秒扫描并临时收纳合格插件按钮；`pfMinimapButtons`／`pfMinimapButton`；支持 bottom／left／top／right、rowsize、spacing 与战斗隐藏 | 保留扫描、缓存、点击和恢复逻辑；重做真实开关、动态容器与四向锚点 |
| [`modules/farmmode.lua`](../../../addon/pfUI/modules/farmmode.lua) | 独立 `pfFarmMap` 300×300；迁移 pfQuest 图钉、tracking 与 PVP，并把常驻 `pfMinimap` 压成返回条 | 作为兼容状态；常驻罗盘和插件工具带不得漂浮或复制到 FarmMode |
| [`skins/blizzard/battlefield_minimap.lua`](../../../addon/pfUI/skins/blizzard/battlefield_minimap.lua) | 战场小地图 skin | 独立系统面板，不与常驻罗盘背景合并 |

## 世界地图

| ID | 原生／pfUI 对象 | 合同 |
|---|---|---|
| `MAP.WORLD.FRAME` | `WorldMapFrame`、pfUI `map.lua` | 围绕真实内容区的非交互羊皮卷外壳；卷杆、端帽、卷边按独立切片／九切片重排，不能拉伸整张图 |
| `MAP.WORLD.CONTENT` | `WorldMapButton` | 尺寸由运行时 `GetWidth／GetHeight` 读取；原始地图、`pfMapPin*`、`pfQuestRouteDrawLayer` 与 `pfQuestRouteDisplay` 保持动态并位于外壳之上 |
| `MAP.WORLD.TITLE` | `WorldMapFrameTitle` | Turtle 兼容层当前隐藏；首批不生产，不得在外壳中烘焙标题 |
| `MAP.WORLD.LEVELS` | `WorldMapContinentDropDown`、`WorldMapZoneDropDown`、可选 `WorldMapZoneMinimapDropDown` | 每个真实 Dropdown 独立换肤；可选对象必须 feature-detect，不生成固定网页 Tab |
| `MAP.WORLD.PFQUEST.FILTER` | `pfQuestMapDropdown` | 独立过滤 Dropdown，保持 provider 行为与层级，不并入静态图例 |
| `MAP.WORLD.BACK` | `WorldMapZoomOutButton` | 这是现有层级返回／缩小语义的唯一已证实 Button；四状态独立，禁止制作不存在的加号、滑块或缩放尺 |
| `MAP.WORLD.CLOSE` | `WorldMapFrameCloseButton` | 皮革扣／黄铜搭扣四状态；独立于外壳 |
| `MAP.WORLD.REVEAL` | `pfUI_mapreveal_onmap` | 真实 14×14 Checkbox 与动态文字；独立换肤，不改变地图外壳 |
| `MAP.WORLD.COORDS` | `pfWorldMapButtonCoords` | 动态坐标 FontString，layout-only，不烘焙数值 |
| `MAP.WORLD.COLORS` | `mapcolors.lua` | 行为 `N/A` 美术 |

`Ctrl+滚轮` 对 `WorldMapFrame` 的缩放与 `Shift+滚轮` 透明度继续作为 pfUI 手势，
不制造对应的静态假控件。世界地图完整内容区与 pfQuest 动态图层必须保留。

## 小地图

| ID | 原生／pfUI 对象 | 合同 |
|---|---|---|
| `MAP.MINI.PROVIDER` | `pfMinimap`、其子对象 `Minimap` | 真实内容默认 140×140、可移动并支持滚轮缩放；parent／scale 与保存位置继续由 pfUI 所有，adapter 只在 V3 外壳碰到屏幕边缘时施加不写入配置的最小临时内缩，禁用／FarmMode 时恢复；地图块、玩家箭头和第三方动态图层继续由 provider 所有 |
| `MAP.MINI.MASK` | `Minimap:SetMaskTexture`；pfUI 当前 `img:minimap` 是完全不透明的 8×8 方形 | 由确定性媒体替换为圆形内容 mask；不由 ImageGen 生产；有效内容直径 140，不把外壳 Alpha 当作 mask |
| `MAP.MINI.COMPASS` | pfUI 已清空的 `MinimapBorder` 周围 adapter Texture | `V3` 使用约 204×204 的闭合罗盘外壳包围原生 140×140 内容；外壳只向外生长，不缩小 provider；无按钮、地图、文字或图钉烘焙；右上锚定时必须为外延保留屏幕安全距 |
| `MAP.MINI.INFO.CRADLE` | adapter 静态底材；承载 `pfMinimapZone`／`pfMinimapCoord`／`pfPanelMinimap` 动态内容 | 与罗盘外壳固定为同一件常驻资源的下置“制图信息托架”；上栏地图名、下栏坐标分别按各自内框水平／垂直居中；只提供短而厚实的皮革／黄铜实体承托和两块动态文字安全区，不烘焙文字，不侵入 140×140 地图窗口 |
| `MAP.MINI.INFO.LEGACY_PANEL` | pfUI `pfPanelMinimap`、其动态 FontString 与既有点击／Tooltip | Map 启用且该 panel 配置非 `none` 时，隐藏旧黑色 backdrop，把真实动态文字与交互代理到托架上部；不移动 panel 本体及其相邻 microbar，禁用／FarmMode 时完整恢复 |
| `MAP.MINI.NORTH` | 非交互装饰 Texture | 顶部北向冠件与外壳同缩放、同显隐，可并入常驻外壳；不假定旋转行为 |
| `MAP.MINI.DIRECTIONS` | 非交互方向 Texture／atlas | W／E／S 只作低权重非文字刻痕，北向冠件为唯一强方向件；不接收插件按钮，不侵入内容窗口或信息托架 |
| `MAP.MINI.ZOOM.IN` | `MinimapZoomIn` 当前隐藏；滚轮调用 `Minimap_ZoomIn` | 首批不生产，不恢复不存在于当前 pfUI 展示结构的按钮 |
| `MAP.MINI.ZOOM.OUT` | `MinimapZoomOut` 当前隐藏；滚轮调用 `Minimap_ZoomOut` | 首批不生产，不恢复不存在于当前 pfUI 展示结构的按钮 |
| `MAP.MINI.STATUS.SOCKET` | tracking／mail／battlefield／PVP 周围的 adapter Texture | 小型独立状态插槽；只提供同材质外壳，随真实对象分别显隐，不烘焙动态图标或通知；不能永久画进罗盘底图 |
| `MAP.MINI.TRACKING` | 独立 `pfUITracking` Button，默认 16×16、父级 `UIParent` | 普通／悬停／按下／激活四状态；保留左键取消、右键菜单、Tooltip 与无追踪脉冲；放入独立状态插槽，只换肤和避让 |
| `MAP.MINI.ZONE` | pfUI `pfMinimapZone`；原生 `MinimapZoneTextButton` 当前隐藏 | 动态区域名 layout-only；锚到 `INFO.CRADLE` 上部安全区，不烘焙文字；若 `pfPanelMinimap` 已承担区域等动态内容则避免重复绘制；长地名不能被锁扣或工具卷遮挡 |
| `MAP.MINI.TIME` | `GameTimeFrame` 当前隐藏 | 首批不生产；若以后恢复，动态时间不得烘焙数字 |
| `MAP.MINI.COORDS` | pfUI `pfMinimapCoord` | 动态坐标 layout-only；在 `INFO.CRADLE` 下部安全区居中；`off` 继续隐藏，`on`／`mouseover` 在 V3 中常驻下层，退出 V3 后恢复 provider 的位置、对齐与 hover 语义；不烘焙数值 |
| `MAP.MINI.MAIL` | `MiniMapMailFrame`，当前锚在 `pfMinimap` 右上 | 独立通知覆盖；保留闪烁提示，避让外壳和屏幕边缘 |
| `MAP.MINI.BATTLEFIELD` | `MiniMapBattlefieldFrame`，当前锚在 `Minimap` 右下 | 独立状态 Button；保留左／右键行为，不并入罗盘环 |
| `MAP.MINI.PVP` | `pfUI.minimap.pvpicon` 16×16 | 独立状态覆盖，不并入罗盘环；与战场入口共享避让区但不合并对象 |
| `MAP.MINI.PFQUEST.PINS` | `pfMiniMapPin*`／pfQuest drawlayer | 保持在 `Minimap` 动态内容层；farmmode 时随 provider 迁移 |
| `MAP.MINI.PLAYER_ARROW` | `Minimap` 内匿名 Model；pfUI 只调整 `arrowscale` | provider-owned；不得转为静态贴图或烘焙进 compass |
| `MAP.MINI.VISIBILITY` | 全局 `ToggleMinimap`；可见的 `MinimapToggleButton` 已被 pfUI 隐藏 | 保留收起／展开行为；外壳、相邻对象与工具带必须随 provider 同步隐藏和恢复 |
| `MAP.MINI.ADDONS` | `addonbuttons.lua` | 动态插件 Button adapter，详见下节 |
| `MAP.MINI.FARMMODE` | `pfFarmMap`、`pfFarmMapButton` | FarmMode 期间隐藏常驻 compass／addon tray；不改变 300×300 provider、对象迁移及返回按钮行为 |

## 插件按钮兼容

| 子组件 | pfUI 对象／职责 | 状态 |
|---|---|---|
| `MAP.MINI.ADDONS.SCANNER` | `ScanForButtons`／`IsButtonValid`／`pfUI_cache.abuttons` | 行为-only；保留自动扫描、手动 add／del／reset、忽略表和缺失对象清理 |
| `MAP.MINI.ADDONS.ANCHORS` | `C.abuttons.position` 与 adapter 计算、不可见 | 无位图；支持 bottom／left／top／right，并从 V3 外壳边界之外展开；bottom 锁扣附着信息托架底部，其他方向附着罗盘对应外沿；V4 工具卷受力边与锁扣按可见 Alpha 直接搭接，不得为容纳工具卷改写 `pfMinimap` 保存锚点 |
| `MAP.MINI.ADDONS.ENTRY` | 扫描到的真实插件 Button | provider 保留原始图标、状态与自带边缘；adapter 只排版，不叠加统一逐图标外框 |
| `MAP.MINI.ADDONS.NOTICE` | 插件自己的通知语义 | 无／未读／警告独立覆盖 |
| `MAP.MINI.ADDONS.TOGGLE` | 真实 `pfMinimapButton` | 重绘为罗盘携行结构上的短皮革／黄铜锁扣；收起／展开及悬停／按下状态仍由真实 Button 承载；展开时真实锁扣位于工具卷之上并直接压住连续受力边；0 个合格插件入口时隐藏，不允许漂浮箭头 |
| `MAP.MINI.ADDONS.TRAY` | 真实 `pfMinimapButtons` 容器 | V4 重绘为从锁扣外侧垂落／展开的制图工具卷；九切片支持四向重排，固定区同时决定真实图标安全 padding，宽高由真实按钮数、rowsize 与 spacing 决定；bottom／top 最多三行并沿水平方向增长，left／right 沿垂直方向增长；不绘制假图标、空槽或逐图标统一外框；不再使用独立 connector Texture |

保留插件原始左键、右键、Tooltip 与动态图标；收纳时继续使用 pfUI 的 parent／point／
size／scale／drag／OnUpdate 备份和恢复逻辑，工具卷内不伪造原插件行为，也不隐藏
插件自身携带的边缘。默认罗盘底图不画空槽；`pfQuestIcon` 作为合格的真实插件入口
由同一容器动态承载。默认 `rowsize=6`，4／6／10 个入口按实际数量形成一行或
`6+4` 两行，30 个入口形成横向 `10+10+10` 工具卷，不生成空槽；0 个入口同时
隐藏锁扣和工具卷。旧 V3 connector 仅保留为尚未清理的回退媒体，不参与 V4
运行时、锚点、命中区或显隐。战斗隐藏
继续读取 `C.abuttons.hideincombat`。`pfFarmMap` 300×300 是独立兼容态，只迁移
既有动态对象，不复制常驻罗盘外壳、信息托架或插件工具卷。
