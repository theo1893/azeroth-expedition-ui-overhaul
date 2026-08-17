# Character 详细进度

## 当前结论

- “香草同构角色面板”整体视觉：`P2`，已锁定。
- WoW `1.12.1` FrameXML 与 pfUI 文件级映射：`P1`，已完成基础 PaperDoll
  对象、尺寸和锚点审计。
- 子组件实机几何、production Prompt、透明 source 与 runtime：未开始。
- 当前运行时：Character、Inspect 与 DressUp 恢复 pfUI 默认 skins；AEUI 尚未
  接管任何 Character 对象。
- 用户已恢复 Character overhaul；当前只推进基础 `CharacterFrame /
  PaperDollFrame`，右侧第三方装备列表与相邻复用窗口不在本轮生产范围。
- 本地几何预演 `CHAR-SIM-V2` 已获用户接受；接受条件为移除左上
  `CharacterFramePortrait` 及任何种族／职业 icon 与空徽章底座。它不构成
  production 像素或 addon 接管授权。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `CHAR.FRAME` | `P2` | V3 锁定图；原生 `384×512`；无左上 icon 的 `CHAR-SIM-V2` 已接受 | 授权首批 production 合同 |
| `CHAR.MODEL` | `P2` visual／`P1` object | 原生 `233×224 @ 65,78`；旋转 Button 已定位 | 确认安静背景与窄边框方向 |
| `CHAR.SLOT*` | `P1–P2` | `19× 37×37` 装备槽与独立 `27×27` Ammo 已定位 | 确认逐对象状态拆分 |
| `CHAR.STATS／RESISTANCE` | `P1–P2` | 属性 `230×78 @ 67,291`；五个抗性格独立 | 确认连续旧纸而非卡片的方向 |
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

1. 审核并授权基础 PaperDoll 首批 production 段及固定输入。
2. 生产期间只用临时 `CURRENT.md` 保存当前合同与候选。
3. source 接受并接入 addon 后执行静态包装检查；本设备不标记 `P6`。
4. 完成基础 Character 后再单独验证 Inspect、DressUp 与 Pet 的复用差异。
