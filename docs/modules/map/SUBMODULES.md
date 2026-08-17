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
| `MAP.MINI.PROVIDER` | `pfMinimap`、其子对象 `Minimap` | 真实内容默认 140×140、可移动并支持滚轮缩放；`pfMinimap` 的 parent／point／scale 与保存位置继续由 pfUI 所有，adapter 只跟随；地图块、玩家箭头和第三方动态图层继续由 provider 所有 |
| `MAP.MINI.MASK` | `Minimap:SetMaskTexture`；pfUI 当前 `img:minimap` 是完全不透明的 8×8 方形 | 由确定性媒体替换为圆形内容 mask；不由 ImageGen 生产；有效内容直径 140，不把外壳 Alpha 当作 mask |
| `MAP.MINI.COMPASS` | pfUI 已清空的 `MinimapBorder` 周围 adapter Texture | 独立于 140×140 内容区的闭合罗盘外壳；无按钮、地图、文字或图钉烘焙；右上锚定时必须为外延保留屏幕安全距 |
| `MAP.MINI.NORTH` | 非交互装饰 Texture | 首批作为可独立定位的北针，不假定旋转行为 |
| `MAP.MINI.DIRECTIONS` | 非交互方向 Texture／atlas | W／E／S 只作低权重刻痕，北针为唯一强方向件；不接收插件按钮，不侵入开关区 |
| `MAP.MINI.ZOOM.IN` | `MinimapZoomIn` 当前隐藏；滚轮调用 `Minimap_ZoomIn` | 首批不生产，不恢复不存在于当前 pfUI 展示结构的按钮 |
| `MAP.MINI.ZOOM.OUT` | `MinimapZoomOut` 当前隐藏；滚轮调用 `Minimap_ZoomOut` | 首批不生产，不恢复不存在于当前 pfUI 展示结构的按钮 |
| `MAP.MINI.TRACKING` | 独立 `pfUITracking` Button，默认 16×16、父级 `UIParent` | 普通／悬停／按下／激活四状态；保留左键取消、右键菜单、Tooltip 与无追踪脉冲；只换肤和避让 |
| `MAP.MINI.ZONE` | pfUI `pfMinimapZone`；原生 `MinimapZoneTextButton` 当前隐藏 | 动态区域名 layout-only；不再增加与插件面板冲突的外置长铭牌，不烘焙文字 |
| `MAP.MINI.TIME` | `GameTimeFrame` 当前隐藏 | 首批不生产；若以后恢复，动态时间不得烘焙数字 |
| `MAP.MINI.COORDS` | pfUI `pfMinimapCoord` | 动态坐标 layout-only；保持 off／on／hover 以及四角配置，不烘焙数值 |
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
| `MAP.MINI.ADDONS.ANCHORS` | `C.abuttons.position` 与 adapter 计算、不可见 | 无位图；支持 bottom／left／top／right，并从 184 外壳边界之外展开；不得为容纳工具带改写 `pfMinimap` 保存锚点，屏幕边距由 pfUI 可移动位置负责 |
| `MAP.MINI.ADDONS.ENTRY` | 扫描到的真实插件 Button | provider 保留原始图标、状态与自带边缘；adapter 只排版，不叠加统一逐图标外框 |
| `MAP.MINI.ADDONS.NOTICE` | 插件自己的通知语义 | 无／未读／警告独立覆盖 |
| `MAP.MINI.ADDONS.TOGGLE` | 真实 16×16 `pfMinimapButton` | 收起普通／悬停／按下与展开普通／悬停／按下；沿配置方向附着于外壳，点击仍只切换真实容器 |
| `MAP.MINI.ADDONS.TRAY` | 真实 `pfMinimapButtons` 容器 | 收起／展开；可四向重排的九切片工具带；宽高由真实按钮数、rowsize 与 spacing 决定 |

保留插件原始左键、右键、Tooltip 与动态图标；收纳时继续使用 pfUI 的 parent／point／
size／scale／drag／OnUpdate 备份和恢复逻辑，工具带内不伪造原插件行为，也不隐藏
插件自身携带的边缘。默认罗盘底图
不画空槽；`pfQuestIcon` 作为合格的真实插件入口由同一容器动态承载。默认
`rowsize=6`，4／6／10 个入口按实际数量形成一行或 `6+4` 两行工具带，不生成空槽；
0 个入口不展示空工具带。战斗隐藏继续读取 `C.abuttons.hideincombat`。`pfFarmMap`
300×300 是独立兼容态，只迁移既有动态对象，不复制常驻罗盘外壳或插件工具带。
