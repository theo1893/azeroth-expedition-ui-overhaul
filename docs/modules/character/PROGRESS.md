# Character 详细进度

## 当前结论

- “香草同构角色面板”整体视觉：`P2`，已锁定。
- WoW `1.12.1` FrameXML 与 pfUI 文件级映射：`P1`，已完成基础 PaperDoll
  对象、尺寸和锚点审计。
- `CHAR.FRAME`：`CHAR-V3-A1-SHELL attempt 3` exact pixels 已接受；透明
  `1536×2048` source 直接导出 `768×1024` 的 2× runtime master 与四块高密度
  TGA；Character adapter 仍按原生 `384×512` UI 几何显示，阶段 `P5`，等待实机。
- `CHAR.MODEL.BACK`：`CHAR-V3-B1-MODEL attempt 2` exact pixels 已接受；
  `932×896` source、`466×448` sampled runtime 与 `512×512` 透明 TGA 已提升，
  仍显示为 `233×224` UI 单位，由 Character adapter 接入，阶段 `P5`，等待实机。
- `CHAR.STATS.PAPER`：`CHAR-V3-C1-STATS-PAPER attempt 4` exact pixels 已接受；
  source/runtime 位于 `assets/source/character/stats-paper-v3/`，正式
  `512×256` TGA 以 2× sampled UV 显示 `230×78 @ 67,291`，阶段 `P5`。
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
  `assets/source/character/tabs-v3/`。runtime `1.8` 只替换
  `CharacterFrameTab1..5` 外观，中央段随 provider 真实文字宽度横向伸缩，阶段
  `P5`。
- `CHAR.SLOT.AMMO`：`CHAR-V3-E3-AMMO V1 attempt 5` exact pixels 及
  `1254×1254` 原生容器按 `627` 中线四等分例外已接受；四张 `108×108`
  source 直接降采样为四个 `54×54` runtime state，并装入 `128×128` POT atlas。
  runtime `1.9` 只替换真实 `CharacterAmmoSlot` 的 `27×27` 普通／悬停／按下／
  禁用外壳，中央 `21×21` 图标安全区保持透明，阶段 `P5`。
- `CHAR.SECONDARY.LEAF`：`CHAR-V3-G1-SECONDARY-LEAF V1 attempt 1` exact
  pixels 及 `1254×1254` 原生容器例外已接受；`802×1000` source 直接降采样为
  `602×750` runtime 并装入 `1024×1024` TGA。runtime `2.0` 把同一张档案页
  分别挂载到声望、技能、Honor／PVP 和存在时的 Arena provider 的 `BACKGROUND`，
  仍按 `301×375 @ 25,66` 原生逻辑区显示；列表、文字、状态条、按钮、滚动条和
  页面显隐保持动态，阶段 `P5`。
- 当前运行时：Character runtime `2.0` 接管 `CharacterFrame` 外壳、PaperDoll
  页模型背景、连续属性纸、五个独立抗性槽和 19 个装备槽普通态外框，并隐藏
  可能存在的左上肖像；实时 3D 人物、装备图标／计数／冷却／点击／提示／
  ShaguScore、属性文字／下拉框、抗性图标／数值、Tab 文字／显隐／重排／点击
  继续由 provider 提供。E2-A 只替换 Button 原生交互纹理；E3 Ammo 只替换
  独立 Button 的外壳与原生三态纹理；F1 只以三段 atlas
  替换五个 Tab 的普通／悬停／按下／selected 外观，并把 PanelTemplates 的
  disabled selected 映射为暖色选中态。禁用模块时恢复 pfUI 抗性、装备槽
  backdrop／原三态纹理、Ammo backdrop 和 Tab backdrop。装备槽品质／耐久
  属于后续 E2-B。
  声望／技能／荣誉／PvP／可选竞技场页只增加共用档案页底材，各页 provider
  自己控制叶片显隐；分页内控件尚未重绘。
  Inspect 与 DressUp 仍使用 pfUI 默认 skins。
- 实机确认基础资源均已加载，但底部装备区曾透出 provider，装备槽状态纹理会
  偏离按钮，属性纸也未始终跟随实际属性文字 provider。runtime `1.9` 使用已验收
  模型底材原生裁片封住底部；普通态及三态统一锁定到按钮左上原点的 `37×37`；
  属性纸与底材改为锚定当前可见的原生或 BetterCharacterStats 属性 frame；全部
  已接入位图从 accepted source 直接重导为 `2 texels / UI unit`，没有改变 UI
  几何、拉伸、补画或新增美术，底部三槽及所有动态文字仍由 provider 持有。
- 用户已恢复 Character overhaul；当前只推进基础 `CharacterFrame /
  PaperDollFrame`，右侧第三方装备列表与相邻复用窗口不在本轮生产范围。
- 本地生产架构预演 `CHAR-SIM-V3` 已获用户接受：物件身份锁定为保持香草
  `384×512` 同构布局的“远征装备检阅夹”，左上不保留肖像／种族／职业 icon
  或空徽章底座。外壳、模型底、属性纸与抗性槽均按真实组件独立接入。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `CHAR.FRAME` | `P5` | `CHAR-V3-A1-SHELL attempt 3` exact pixels；2× 四块 power-of-two TGA 原生重组；runtime `1.9` 保持 `384×512` UI 几何 | 实机复核 2K／4K 清晰度、底材连续、层序、四块接缝与禁用回退 |
| `CHAR.MODEL` | `P5` | `CHAR-V3-B1-MODEL attempt 2` exact pixels；2× sampled texture、原生 `233×224 @ 65,78`、精确 UV；旋转 Button 与实时 3D 模型保持独立 | 实机验证人物层序、清晰度、暗色装备可读性及非 PaperDoll 页不泄漏 |
| `CHAR.SLOT` 普通态 | `P5` | E1 attempt 1 exact pixels；`CHAR-SLOT-OPENING-31-V1` 将 A–D 四变体的常驻透明开口与 pfUI `31×31` 图标对齐；19 个 Button 仍为原生 `37×37`，两个饰品槽、2× POT atlas 与禁用回退已接入 | 实机验证装备图标不再拥挤／裁边，并复核边缘清晰度、点击、空槽、ShaguScore、缩放及 pfUI backdrop 恢复 |
| `CHAR.SLOT` 交互态 | `P5` | E2-A Hover attempt 3／Pressed attempt 4／Disabled attempt 2 exact pixels；三张独立 source、`74×74` sampled runtime、`512×128` atlas；runtime `1.9` 保持 ItemButton 原 `37×37` 几何 | 实机验证普通／三态均不漂移、层序、禁用 Alpha、ShaguScore 与 `/aeui character` 回退 |
| `CHAR.SLOT.AMMO` | `P5` | E3 attempt 5 exact pixels；四态独立 `108×108` source、`54×54` sampled runtime 与 `128×128` atlas；runtime `1.9` 保持独立 Ammo Button 原 `27×27` 几何及 `21×21` 动态窗口 | 实机验证图标／数量／冷却、四态、空弹药、层序、0.80 缩放及 `/aeui character` 回退 |
| `CHAR.SLOT` 品质／耐久／空槽 | `P1–P2` | E2-B 品质／耐久暂停；E4 各部位空槽压印边界已定义 | 基础槽与 Ammo 实机稳定后再分别生产，不从普通态烘焙或缩放派生 |
| `CHAR.STATS／RESISTANCE` | `P5` | C1 attempt 4 连续旧纸与 D1 attempt 3 五张抗性槽均使用 2× sampled runtime；runtime `1.9` 让纸面跟随原生／BetterCharacterStats 当前 provider | 实机验证清晰度、纸面与属性文字／下拉框对齐、模型交界、五个动态图标／数值及独立显隐 |
| `CHAR.TABS` | `P5` | F1 V3 attempt 2 exact pixels；四态独立 `176×80` source、2× 三段 runtime、`128×256` POT atlas；原生五个 Button、动态宽度与无宠物页四 Tab 重排继续存活 | 实机验证四／五 Tab、selected 映射、悬停／按下、宽中文／英文、0.80 缩放、接缝及 `/aeui character` 回退 |
| `CHAR.SECONDARY.LEAF` | `P5` | G1 V1 attempt 1 exact pixels；`802×1000` source、`602×750` sampled runtime、`1024×1024` TGA；按可用 provider 独立挂载并随原生页面显隐 | 实机验证四类页面覆盖、文字／状态条层序、切页无泄漏、可选 Arena feature-detect 与禁用回退 |
| `CHAR.REPUTATION／SKILLS／HONOR／ARENA` 控件 | `P1–P2` | 真实列表、状态条、滚动条、复选框、展开按钮和内页 Tabs 边界已定义；共用档案页已独立完成 | 依据实机截图逐类生产，不把动态数据烘焙进档案页 |
| `CHAR.PET／INSPECT／DRESSUP` | `P1` | pfUI skin 对象已审计 | 确认复用与只读差异 |

## 已否决方向

- 横向双栏人物 Dashboard 与永久属性附页。
- 左上大型圆形肖像章。
- 右下大型黄铜龙头、涡卷和宝石底座。
- 底部四装备槽、五个彩色数值格。
- 宽紫品质框、连续外发光和过暗模型背景。

## 下一门禁

1. 游戏设备在实际分辨率／UI Scale 下先验证 2× TGA 清晰度，再检查
   `CHAR.FRAME` 四块接缝、模型背景与实时 3D 人物层序、属性纸
   11 px 叠放、属性文字／下拉框可读性、五个抗性槽图标／数值／提示及独立显隐；
   同时验证 19 个 E1 槽框覆盖正确、`31×31` 图标开口不再拥挤或裁边、两个饰品槽与底部三槽
   分配正确，悬停／按下／禁用纹理按状态触发，点击／提示／冷却／ShaguScore
   仍可用且评分文字不被状态纹理遮住。
2. 在声望、技能、荣誉／PvP 和存在时的 Arena 页验证共用档案页完整覆盖旧内层
   轨道，所有文字、状态条、按钮与滚动条均位于纸面上方；切回 PaperDoll 时不得
   泄漏。再验证 `/aeui character` 禁用回退；禁用后不得遗留档案页、属性纸或
   槽底，pfUI 的抗性 backdrop 与原图标层级必须恢复。本设备不标记 `P6`。
3. 实机同时验证 Character Tabs 的四／五项动态重排、普通／悬停／按下／selected、
   宽文字、0.80 缩放、三段接缝及 pfUI backdrop 回退；同时验证 Ammo 的动态图标、
   三位数量、冷却、普通／悬停／按下／禁用、空弹药与 `27×27` 对位。E1、E2-A
   与 E3 稳定后再生产 E2-B 品质／耐久或 E4 空槽压印；
   Inspect、DressUp 与 Pet 继续单独验证复用差异。
