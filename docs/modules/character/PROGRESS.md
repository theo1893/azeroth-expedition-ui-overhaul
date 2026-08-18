# Character 详细进度

## 当前结论

- “香草同构角色面板”整体视觉：`P2`，已锁定。
- WoW `1.12.1` FrameXML 与 pfUI 文件级映射：`P1`，已完成基础 PaperDoll
  对象、尺寸和锚点审计。
- `CHAR.FRAME`：`CHAR-V3-A1-SHELL attempt 3` exact pixels 已接受；透明
  `1536×2048` source、`384×512` runtime master 与原生四块 TGA 已提升并由
  Character adapter 接入，阶段 `P5`，等待实机。
- `CHAR.MODEL.BACK`：`CHAR-V3-B1-MODEL attempt 2` exact pixels 已接受；
  `932×896` source、`233×224` runtime master 与 `256×256` 透明 TGA 已提升，
  由 Character adapter 接入，阶段 `P5`，等待实机。
- `CHAR.STATS.PAPER`：`CHAR-V3-C1-STATS-PAPER attempt 4` exact pixels 已接受；
  source/runtime 位于 `assets/source/character/stats-paper-v3/`，正式
  `256×128` TGA 以精确 UV 显示 `230×78 @ 67,291`，阶段 `P5`。
- `CHAR.RESISTANCE`：`CHAR-V3-D1-RES-WELLS attempt 3` 运行时视觉及原生
  Alpha 传输／中央安全区 Alpha 钳制例外已接受；五张独立 source/runtime
  位于 `assets/source/character/res-wells-v3/`，五个 `32×32` TGA 分别挂载
  `MagicResFrame1..5`，阶段 `P5`。
- `CHAR.SLOT` 普通态：`CHAR-V3-E1-SLOT-BASE attempt 1` exact pixels 及
  `1254²` 原生容器中线拆分例外已接受；A／B／C／D 四张 `148²` source、
  `37²` runtime 与 `128²` atlas 位于
  `assets/source/character/slot-base-v3/`，稳定分配给 19 个真实装备槽并已接入，
  阶段 `P5`。两个饰品槽包含在内；独立 `27×27` Ammo 不属于 E1。
- `CHAR.SLOT` 交互态：E2-A1 attempt 3、E2-A2 attempt 4、E2-A3 attempt 2
  exact pixels 已接受；悬停／按下／禁用三张独立 `148²` source、`37²`
  runtime 与 `256×64` atlas 位于
  `assets/source/character/slot-states-v3/`，通过 Button 原生三态接入 19 个装备槽，
  阶段 `P5`。品质／耐久 E2-B 仍暂停。
- 当前运行时：Character runtime `1.4` 接管 `CharacterFrame` 外壳、PaperDoll
  页模型背景、连续属性纸、五个独立抗性槽和 19 个装备槽普通态外框，并隐藏
  可能存在的左上肖像；实时 3D 人物、装备图标／计数／冷却／点击／提示／
  ShaguScore、属性文字／下拉框、抗性图标／数值、Tabs 与按钮行为继续由
  provider 提供。E2-A 只替换 Button 原生交互纹理，ShaguScore 保持在其上；
  禁用模块时恢复 pfUI 抗性、装备槽 backdrop 与原三态纹理。装备槽品质／耐久
  属于后续 E2-B，Ammo 属于 E3。
  Inspect 与 DressUp 仍使用 pfUI 默认 skins。
- 用户已恢复 Character overhaul；当前只推进基础 `CharacterFrame /
  PaperDollFrame`，右侧第三方装备列表与相邻复用窗口不在本轮生产范围。
- 本地生产架构预演 `CHAR-SIM-V3` 已获用户接受：物件身份锁定为保持香草
  `384×512` 同构布局的“远征装备检阅夹”，左上不保留肖像／种族／职业 icon
  或空徽章底座。外壳、模型底、属性纸与抗性槽均按真实组件独立接入。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `CHAR.FRAME` | `P5` | `CHAR-V3-A1-SHELL attempt 3` exact pixels；四块 power-of-two TGA 原生重组；runtime `1.0` 已接入 | 实机验证层序、四块接缝、模型／属性净空与禁用回退 |
| `CHAR.MODEL` | `P5` | `CHAR-V3-B1-MODEL attempt 2` exact pixels；原生 `233×224 @ 65,78`、精确 UV；旋转 Button 与实时 3D 模型保持独立 | 实机验证人物层序、暗色装备可读性及非 PaperDoll 页不泄漏 |
| `CHAR.SLOT` 普通态 | `P5` | E1 attempt 1 exact pixels；A–D 四变体、19 个 `37×37` 真实槽、两个饰品槽、POT atlas 与禁用回退已接入 | 实机验证图标层序、点击、空槽、ShaguScore、缩放及 pfUI backdrop 恢复 |
| `CHAR.SLOT` 交互态 | `P5` | E2-A Hover attempt 3／Pressed attempt 4／Disabled attempt 2 exact pixels；三张独立 source、`37×37` runtime、`256×64` atlas 与原生 Button 三态回退已接入 | 实机验证三态触发、层序、禁用 Alpha、ShaguScore 与 `/aeui character` 回退 |
| `CHAR.SLOT` 品质／耐久／空槽／Ammo | `P1–P2` | E2-B 品质／耐久暂停；E3 独立 `27×27` Ammo、E4 各部位空槽压印边界已定义 | 基础槽与 E2-A 实机稳定后再分别生产，不从普通态烘焙或缩放派生 |
| `CHAR.STATS／RESISTANCE` | `P5` | C1 attempt 4 连续旧纸 exact pixels；D1 attempt 3 五张独立抗性槽及两项 Alpha 例外；runtime `1.2` 已接入 | 实机验证纸面与模型 11 px 交界、属性文字／下拉层序、五个动态图标／数值及独立显隐 |
| `CHAR.TABS` | `P1–P2` | 原生五个 Button；无宠物页时动态显示四个 | 确认小型粗糙皮革四态 |
| `CHAR.REPUTATION／SKILLS／HONOR／ARENA` | `P1` | pfUI skin 对象已审计 | 分页实机对象与共享组件合同 |
| `CHAR.PET／INSPECT／DRESSUP` | `P1` | pfUI skin 对象已审计 | 确认复用与只读差异 |

## 已否决方向

- 横向双栏人物 Dashboard 与永久属性附页。
- 左上大型圆形肖像章。
- 右下大型黄铜龙头、涡卷和宝石底座。
- 底部四装备槽、五个彩色数值格。
- 宽紫品质框、连续外发光和过暗模型背景。

## 下一门禁

1. 游戏设备验证 `CHAR.FRAME` 四块接缝、模型背景与实时 3D 人物层序、属性纸
   11 px 叠放、属性文字／下拉框可读性、五个抗性槽图标／数值／提示及独立显隐；
   同时验证 19 个 E1 槽框覆盖正确、图标不被压缩或越框、两个饰品槽与底部三槽
   分配正确，悬停／按下／禁用纹理按状态触发，点击／提示／冷却／ShaguScore
   仍可用且评分文字不被状态纹理遮住。
2. 验证分页隐藏及 `/aeui character` 禁用回退；禁用后不得遗留纸面／槽底，
   pfUI 的抗性 backdrop 与原图标层级必须恢复。本设备不标记 `P6`。
3. E1 与 E2-A 实机稳定后再生产 E2-B 品质／耐久、E3 Ammo、E4 空槽压印或 Character Tabs；
   Inspect、DressUp 与 Pet 继续单独验证复用差异。
