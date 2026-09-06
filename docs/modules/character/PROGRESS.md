# Character 详细进度

## 当前结论

- 本轮角色页材质、布局、分页滚动及 PvP 高亮处理均为 overhaul 的所有角色
  默认行为，直接使用统一 Character runtime；不按角色保存外观覆盖。
  `character.enabled` 默认开启，保存在账号级 `AzerothExpeditionUIDB`，
  `/aeui character` 为账号共用的整体回退开关。
- PvP 实机反馈显示荣誉进度条底框伸出纸页，竞技场队伍底框覆盖纸面。
  已仅隐藏 HonorFrameProgressBar／ArenaFramePointsBar 与 ArenaTeam1..5／
  ArenaFrameTeam1..5 的 pfUI backdrop、独立 border 和 shadow；进度填充、队伍
  内容、原生框体与交互保持可用，禁用 Character 时恢复原 Alpha。等待切换
  荣誉／竞技场、已有队伍内容与禁用回退实机复核。实机确认仅替换 Button
  HighlightTexture 未消除黄色悬停框；当前取消矩形悬停绘制，同时覆盖队伍自身
  backdrop、HIGHLIGHT 纹理及命名 Highlight region／child，并在原 OnEnter 完成后
  清除其重新显示的高亮。保留原悬停逻辑与点击，禁用时恢复原底框与 Alpha，
  等待鼠标移入／移出复核。
- Character runtime `2.1 / P5`：依据七项实机反馈，称号／左右属性下拉、
  声望／技能折叠件与滚动条、状态条、荣誉／竞技场二级 Tabs 已接入现有
  Gear Planner 皮革／黄铜 donor；状态条复用 Unit Frames 填充，保留 provider
  数值、颜色与点击。共享下拉列表只在角色下拉打开时接管，其他菜单恢复原底材。
- StatCompareSelfFrame 与 S_ItemTip_InspectFrame 的角色伴随页改为不透明皮革
  与固定边角包框，包含等级小框与装备部位签；随实际 provider 尺寸伸展，
  离开角色 PaperDoll 或禁用 Character 时恢复，观察会话仍由原 provider 持有。
- 实机反馈仍有声望表头越过纸页上边、技能“全部”换行、PvP 数值贴右边。
  已修正为声望表头位于纸内 `y=76`、分组折叠件至少距纸左边 `8 UI`，
  技能“全部”移至纸内右上 `70×18` 独立区并保留至少 `48 UI` 文字宽度；
  PvP 同时处理子 Frame 内的 RIGHT 锚点数值，保持行高并留出 `14 UI` 右边距。
  声望“阵营／关系”和技能“全部”跟随 FauxScrollFrame 的首屏内容：offset
  非零时隐藏，回到顶部恢复；在真实 OnVerticalScroll／ScrollBar OnValueChanged
  provider 脚本执行完成后更新显隐，并使用原生 FauxScrollFrame_GetOffset，避免
  技能刷新重新显示“全部”。声望首屏列表额外下移 `12 UI`，后续页恢复原行位置，
  不累积偏移。等待 `/reload` 后复核滚动／回顶、首行间距与折叠，再验证禁用回退。
- 声望名称／技能名称与数值列、折叠件基线和荣誉右侧数值内边距采用上述修正；
  共用纸页从 `301×375` 改为 `301×382 @ 25,66`，上下 `8 UI` 边缘保留，
  仅伸展中间纸面以覆盖底部间隙。accepted source 与 runtime 媒体没有修改。
- 当前待实机：`/reload` 后复核上述控件、左右侧栏、下拉菜单与三类分页底边；
  相邻复核装备点击／提示、技能详情与声望详情；用 `/aeui character` 检查回退。
  本轮代码检查不代表游戏验收，阶段保持 `P5`。

- “香草同构角色面板”整体视觉：`P2`，已锁定。
- WoW `1.12.1` FrameXML 与 pfUI 文件级映射：`P1`，已完成基础 PaperDoll
  对象、尺寸和锚点审计。
- `CHAR.FRAME`：`CHAR-V3-A1-SHELL attempt 3` exact pixels 已接受；透明
  `1536×2048` source 直接导出 `768×1024` 的 2× runtime master 与四块高密度
  TGA；Character adapter 仍按原生 `384×512` UI 几何显示，阶段 `P5`，等待实机。
- `CHAR.MODEL.BACK`：`CHAR-V3-B1-MODEL attempt 2` exact pixels 已接受；
  `932×896` source、`466×448` sampled runtime 与 `512×512` 透明 TGA 已提升，
  原生 3D provider 仍为 `233×224 @ 65,78`；Character adapter 只把同一底材的
  安静中央段横向三切片显示为 `243×227 @ 69,75`，按实机视觉边界覆盖
  `x=69..312 / y=75..302` 的中央开口，阶段 `P5`，等待实机。
- `CHAR.STATS.PAPER`：`CHAR-V3-C1-STATS-PAPER attempt 4` exact pixels 已接受；
  source/runtime 位于 `assets/source/character/stats-paper-v3/`，正式
  `512×256` TGA 保持不变；adapter 以纵向三切片显示 `230×85 @ 76,291`，匹配
  BetterCharacterStats 六行实际 `81 UI` 内容底界，属性 provider 仍为
  `230×78 @ 76,291`；整组中心为 `x=191`，与中央底材中心 `x=190.5`
  对齐，阶段 `P5`。
- `CHAR.RESISTANCE`：`CHAR-V3-D1-RES-WELLS attempt 3` 运行时视觉及原生
  Alpha 传输／中央安全区 Alpha 钳制例外已接受；五张独立 source/runtime
  位于 `assets/source/character/res-wells-v3/`，五个 `64×64` TGA 各采样
  `64×58` 像素并显示为 `32×29`，分别挂载 `MagicResFrame1..5`，阶段 `P5`。
- `CHAR.SLOT` 普通态：`CHAR-V3-E1-SLOT-BASE attempt 1` exact pixels 及
  `1254²` 原生容器中线拆分例外已接受；A／B／C／D 四张 `148²` source、
  `74²` sampled runtime 与 `256²` atlas 位于
  `assets/source/character/slot-base-v3/`，稳定分配给 19 个真实装备槽并已接入，
  阶段 `P5`。实机发现旧 `29×29` 透明开口会遮住 pfUI 的 `31×31` 动态图标
  边缘；`CHAR-SLOT-OPENING-31-V1` 已仅通过 Alpha／透明 RGB 清理把四个 E1
  source/runtime 开口扩大为 `31×31`，仍保持 `37×37` Button、锚点、UV 与
  命中区不变，等待复核。两个饰品槽包含在内；独立 `27×27` Ammo 不属于 E1。
- `CHAR.SLOT` 交互态：E2-A1 attempt 3、E2-A2 attempt 4、E2-A3 attempt 2
  exact pixels 已接受；悬停／按下／禁用三张独立 `148²` source、`74²`
  sampled runtime 与 `512×128` atlas 位于
  `assets/source/character/slot-states-v3/`，通过 Button 原生三态接入 19 个装备槽，
  阶段 `P5`。品质／耐久 E2-B 仍暂停。
- `CHAR.TABS`：`CHAR-V3-F1-TABS V3 attempt 2` exact pixels 已接受；四态
  `176×80` source、十二个 2× 三段样本与 `128×256` POT atlas 位于
  `assets/source/character/tabs-v3/`。accepted source 保持不变；component runtime
  `2.1` 从同一 source 确定性重导每态 `56 texels` 高的三段样本，把真实
  `CharacterFrameTab1..5` 从 `20` 提升到 `28 UI` 高。当前可见项共享 pfUI
  Character backdrop 有效宽度，每项至少为 `64 UI` 或真实文字宽度加 `32 UI`；
  中文四项约为 `83 UI` 宽，有宠物页的五项约为 `66 UI`，阶段 `P5`。
- `CHAR.SLOT.AMMO`：`CHAR-V3-E3-AMMO V1 attempt 5` exact pixels 及
  `1254×1254` 原生容器按 `627` 中线四等分例外已接受；四张 `108×108`
  source 直接降采样为四个 `54×54` runtime state，并装入 `128×128` POT atlas。
  runtime `1.9` 只替换真实 `CharacterAmmoSlot` 的 `27×27` 普通／悬停／按下／
  禁用外壳，中央 `21×21` 图标安全区保持透明，阶段 `P5`。
- `CHAR.SECONDARY.LEAF`：`CHAR-V3-G1-SECONDARY-LEAF V1 attempt 1` exact
  pixels 及 `1254×1254` 原生容器例外已接受；`802×1000` source 直接降采样为
  `602×750` runtime 并装入 `1024×1024` TGA。runtime `2.0` 把同一张档案页
  分别挂载到声望、技能、Honor／PVP 和存在时的 Arena provider 的 `BACKGROUND`，
  以三切片覆盖 `301×382 @ 25,66` 视觉区；列表、文字、状态条、按钮、滚动条和
  页面显隐保持动态，阶段 `P5`。
- 当前运行时：Character runtime `2.1` 接管 `CharacterFrame` 外壳、PaperDoll
  页模型背景、连续属性纸、五个独立抗性槽和 19 个装备槽普通态外框，并隐藏
  可能存在的左上肖像；实时 3D 人物、装备图标／计数／冷却／点击／提示／
  ShaguScore、属性文字／下拉框、抗性图标／数值、Tab 文字／显隐／重排／点击
  继续由 provider 提供。模型／底部底材覆盖外壳中央开口
  `x=69..312 / y=75..444`，
  属性纸只拉伸中央纸面以容纳六行文字，并与属性 provider 共同对齐到
  `x=76..306`；左右装备列按 `x=20 / x=327` 对称锚定，
  所有 provider 尺寸与命中区不变。E2-A 只替换 Button 原生交互纹理；E3 Ammo
  只替换独立 Button 的外壳与原生三态纹理；F1 以三段 atlas
  替换五个 Tab 的普通／悬停／按下／selected 外观，把 PanelTemplates 的
  disabled selected 映射为暖色选中态，并让当前四／五个可见真实 Button 以
  `28 UI` 高度自适应铺满底部有效宽度。禁用模块时恢复 pfUI 抗性、装备槽
  backdrop／原三态纹理、Ammo backdrop 和 Tab backdrop。装备槽品质／耐久
  属于后续 E2-B。
  声望／技能／荣誉／PvP／可选竞技场页采用共用档案页及独立控件材质，各页 provider
  自己控制叶片、列表与控件显隐。
  Inspect 与 DressUp 仍使用 pfUI 默认 skins。
- 最新实机图显示，属性组原 `230 UI @ x=67` 的中心为 `x=182`，相对当前
  `x=69..312` 中央底材的中心 `x=190.5` 明显偏左。adapter 已把原生
  `CharacterAttributesFrame`、可选 `BetterCharacterAttributesFrame` 与属性纸同步右移
  `9 UI` 到 `x=76`，整组中心为 `x=191`，在底材内左右余量约为 `7 / 6 UI`。
  纸面尺寸与 y 位置、中央底材、模型 provider 和装备 Button 几何均未改动，
  等待同设备复核属性组居中与绿幕左右边。
- 最新 Tab 实机图及重启复核确认：首次进入或 `/reload` 后整行回退为 pfUI 黑底，
  点击数次才逐步出现皮革外观；切到声望时页面和字体更新，但 selected 皮革态仍
  留在角色页。客户端错误记录已把共同根因定位为
  `CharacterFrameTab1 doesn't have a "OnEnable" script`：Turtle 1.12 Tab 不支持
  `OnEnable／OnDisable`，安装过程在第一个按钮中断并触发 pfUI 回退，异常前安装的
  部分点击脚本才造成“点击后偶尔恢复”的表现。adapter 已移除这两个无效 Hook；
  其余可重装脚本、两帧一次性收口，以及以实际可见的 PaperDoll／Reputation／
  Skill／Honor／PvP／Arena provider 为优先的 selected 映射保持不变。accepted
  source 与 provider 功能均未改变，等待同设备复核首次显示和逐页单击切态。
- Gear Planner runtime `1.2-zhCN` 已把 `CharacterFrame / PaperDollFrame` 登记为
  角色伴随栏宿主：BetterCharacterStats 继续位于中心，S_ItemTip、StatCompare 与
  AEUI Gear Planner 作为“装备／属性／配装／双栏”互斥视图。`40 UI` 栏使用完整文本，
  双 Provider 与净空满足时新会话默认打开“双栏”。控制器是
  Character／PaperDoll 子对象，不包装角色页 OnShow／OnHide；只在显示、分页切换、
  Provider 加载或 StatCompare 自身刷新后做有限的一次性锚定。配装视图扩展为
  `560×555`，19 槽与“当前／配装／变化”属性对比同屏，水平合同为 `996 UI`；
  第三方当前装备视图在
  有效宽度至少 `1072 UI` 且左右净空足够时仍可选双栏，配装视图不重复双开
  StatCompare。Character runtime 仍为 `2.0`，既有外壳与动态内容所有权不变，
  阶段 `P5` 等待实机。
- 同一 runtime 以独立会话接入 `InspectFrame / InspectPaperDollFrame`：“装／属”
  默认互斥，“比”只在左右净空足够时显示目标／自身 StatCompare 并隐藏 S_ItemTip，
  “存”只在观察数据就绪后把目标 itemID 快照新建为观察参考方案。非 PaperDoll
  分页全部收起，不在只读观察页展开完整 Gear Planner。
- 本地生产架构预演 `CHAR-SIM-V3` 已获用户接受：物件身份锁定为保持香草
  `384×512` 同构布局的“远征装备检阅夹”，左上不保留肖像／种族／职业 icon
  或空徽章底座。外壳、模型底、属性纸与抗性槽均按真实组件独立接入。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `CHAR.FRAME` | `P5` | `CHAR-V3-A1-SHELL attempt 3` exact pixels；2× 四块 power-of-two TGA 原生重组；runtime `1.9` 保持 `384×512` UI 几何 | 实机复核 2K／4K 清晰度、底材连续、层序、四块接缝与禁用回退 |
| `CHAR.MODEL` | `P5` | `CHAR-V3-B1-MODEL attempt 2` exact pixels；2× sampled texture；底材显示为 `243×227 @ 69,75`，实时 3D provider 保持原生 `233×224 @ 65,78` | 实机验证绿幕左右边完整贴合、三切片无接缝，并复核人物层序、暗色装备可读性及非 PaperDoll 页不泄漏 |
| `CHAR.SLOT` 普通态 | `P5` | E1 attempt 1 exact pixels；`CHAR-SLOT-OPENING-31-V1` 将 A–D 四变体的常驻透明开口与 pfUI `31×31` 图标对齐；19 个 Button 仍为原生 `37×37`，两个饰品槽、2× POT atlas 与禁用回退已接入 | 实机验证装备图标不再拥挤／裁边，并复核边缘清晰度、点击、空槽、ShaguScore、缩放及 pfUI backdrop 恢复 |
| `CHAR.SLOT` 交互态 | `P5` | E2-A Hover attempt 3／Pressed attempt 4／Disabled attempt 2 exact pixels；三张独立 source、`74×74` sampled runtime、`512×128` atlas；runtime `1.9` 保持 ItemButton 原 `37×37` 几何 | 实机验证普通／三态均不漂移、层序、禁用 Alpha、ShaguScore 与 `/aeui character` 回退 |
| `CHAR.SLOT.AMMO` | `P5` | E3 attempt 5 exact pixels；四态独立 `108×108` source、`54×54` sampled runtime 与 `128×128` atlas；runtime `1.9` 保持独立 Ammo Button 原 `27×27` 几何及 `21×21` 动态窗口 | 实机验证图标／数量／冷却、四态、空弹药、层序、0.80 缩放及 `/aeui character` 回退 |
| `CHAR.SLOT` 品质／耐久／空槽 | `P1–P2` | E2-B 品质／耐久暂停；E4 各部位空槽压印边界已定义 | 基础槽与 Ammo 实机稳定后再分别生产，不从普通态烘焙或缩放派生 |
| `CHAR.STATS／RESISTANCE` | `P5` | C1 attempt 4 连续旧纸与 D1 attempt 3 五张抗性槽均使用 2× sampled runtime；纸面以纵向三切片显示 `230×85 @ 76,291`，属性 provider 为 `230×78 @ 76,291` | 实机验证属性组在中央底材内居中、第六行完整留在纸面内、三切片无接缝，并复核下拉框、模型交界、五个动态图标／数值及独立显隐 |
| `CHAR.TABS` | `P5` | F1 V3 attempt 2 exact pixels；accepted source 不变，component runtime `2.1` 重导 `56 texels / 28 UI` 四态三段样本；已按客户端错误记录移除 1.12 不支持的 `OnEnable／OnDisable`，保留晚加载脚本重装、两帧一次性收口与可见页面 selected 映射 | 首次进游戏及 `/reload` 后立即显示四／五个皮革 Tab、无 pfUI 黑底；逐项单击验证 selected 唯一跟随当前页，再复核悬停／按下、0.80 缩放、接缝与禁用回退 |
| `CHAR.SECONDARY.LEAF` | `P5` | G1 V1 attempt 1 exact pixels；`802×1000` source、`602×750` sampled runtime、`1024×1024` TGA；按可用 provider 独立挂载并随原生页面显隐 | 实机验证四类页面覆盖、文字／状态条层序、切页无泄漏、可选 Arena feature-detect 与禁用回退 |
| `CHAR.COMPANION` | `P5` | Gear Planner `1.2-zhCN`；Character／PaperDoll 子控制器、`40 UI`“装备／属性／配装／双栏”深皮革伴随栏、按真实 Provider 宽度判断的默认双栏、`560×555` 装备／属性对比同屏配装视图；不改 Provider Parent／尺寸／数据 | 实机验证按 C 默认双栏、角色栏按钮、`996 UI` 配装净空、四项互斥、当前／配装／变化列、分页显隐、ESC、Provider 缺失及 Character／Gear Planner 禁用回退 |
| `CHAR.INSPECT.COMPANION` | `P5` | 独立 Inspect／PaperDoll 子控制器、`28 UI`“装／属／比／存”栏、单 Provider 默认、显式双方比较、数据就绪快照与 Provider 状态恢复已接入 | 实机验证观察首次加载、目标切换、装／属互斥、宽／窄屏“比”、分页收口、17／19 槽快照、方案箭头、缺失 Provider 与 Gear 禁用回退 |
| `CHAR.REPUTATION／SKILLS／HONOR／ARENA` 控件 | `P5` | runtime `2.1`；独立皮革／黄铜控件与动态填充、文字对齐、382 UI 高三切片纸页已接入 | 实机复核折叠／滚动、二级 Tabs、数值颜色、详情及禁用回退 |
| `CHAR.PET／INSPECT 外壳／DRESSUP` | `P1` | 基础 pfUI skin 对象已审计；Inspect 伴随逻辑单独登记为 P5 | 确认复用与只读视觉差异 |

## 已否决方向

- 横向双栏人物 Dashboard 与永久属性附页。
- 左上大型圆形肖像章。
- 右下大型黄铜龙头、涡卷和宝石底座。
- 底部四装备槽、五个彩色数值格。
- 宽紫品质框、连续外发光和过暗模型背景。

## 下一门禁

1. 游戏设备在实际分辨率／UI Scale 下先验证中央绿灰底材四边完整贴合
   `x=69..312 / y=75..444` 外壳视觉开口且三切片没有接缝；同时验证属性纸、两套属性
   provider 与标题整组位于 `x=76..306`，相对中央底材居中；右装备列位置与属性纸匹配
   已获本轮实机确认。再检查 `CHAR.FRAME` 四块接缝、模型背景与实时 3D 人物层序、属性纸
   11 px 顶部叠放、属性文字／下拉框可读性、五个抗性槽图标／数值／提示及独立显隐；
   同时验证 19 个 E1 槽框覆盖正确、`31×31` 图标开口不再拥挤或裁边、两个饰品槽与底部三槽
   分配正确，悬停／按下／禁用纹理按状态触发，点击／提示／冷却／ShaguScore
   仍可用且评分文字不被状态纹理遮住。
2. 在声望、技能、荣誉／PvP 和存在时的 Arena 页验证共用档案页完整覆盖旧内层
   轨道，所有文字、状态条、按钮与滚动条均位于纸面上方；切回 PaperDoll 时不得
   泄漏。再验证 `/aeui character` 禁用回退；禁用后不得遗留档案页、属性纸或
   槽底，pfUI 的抗性 backdrop 与原图标层级必须恢复。本设备不标记 `P6`。
3. 首次进游戏及 `/reload` 后不点击任何 Tab，验证四／五项立即以 `28 UI` 高度
   铺满底部且没有 pfUI 黑色 backdrop；随后各单击一次角色／声望／技能／PvP，确认
   暖色 selected 皮革态只随当前页面移动，悬停／按下仍正确。再复核宽文字、
   `0.80` 缩放、三段接缝，以及 `/aeui character` 禁用后恢复 pfUI 原宽高与 backdrop；
   同时验证 Ammo 的动态图标、
   三位数量、冷却、普通／悬停／按下／禁用、空弹药与 `27×27` 对位。E1、E2-A
   与 E3 稳定后再生产 E2-B 品质／耐久或 E4 空槽压印；
   Inspect、DressUp 与 Pet 继续单独验证复用差异。
4. 按 `C` 打开 PaperDoll，验证 `40 UI` 栏完整显示“装备／属性／配装／双栏”，只显示
   已加载 Provider；双 Provider 与净空满足时默认打开“双栏”，切换不改变
   BetterCharacterStats；执行 `/aeui gear` 应直接激活配装方案。
   再验证 `996 UI` 配装视图中装备与当前／配装／变化属性对比同屏，且不额外双开
   StatCompare；在第三方
   当前装备视图验证 ≥`1072 UI` 可选双栏。逐页切换确认伴随栏不泄漏到声望／
   技能／PvP，并验证 ESC、S_ItemTip／StatCompare 缺失、
   `/aeui character` 与 `/aeui gear off` 回退。
5. 观察其他玩家，验证默认只保留一个右侧 Provider；“装／属”互斥，“比”只在
   左右净空足够时显示双方属性且不再显示 S_ItemTip。切换 Honor／Arena／Talent
   后必须完全收口，返回装备页重新出现；“存”应等待数据就绪并新建观察参考，
   `<／>` 可切回原方案。
