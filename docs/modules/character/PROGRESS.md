# Character 详细进度

## 当前结论

- “香草同构角色面板”整体视觉：`P2`，已锁定。
- pfUI 文件级映射：`P1`。
- 子组件实机几何、production Prompt、透明 source 与 runtime：未开始。
- 当前运行时：Character、Inspect 与 DressUp 恢复 pfUI 默认 skins；AEUI 尚未
  接管任何 Character 对象。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `CHAR.FRAME` | `P2` | [V3 锁定图](../../../assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png) | 测量 CharacterFrame 与可切片边界 |
| `CHAR.MODEL` | `P2` visual／`P1` object | 香草结构参考与 V3 背景 | 模型可视区、旋转与开关对象 |
| `CHAR.SLOT*` | `P1–P2` | 经典槽位关系锁定 | 每槽尺寸、状态与品质／耐久覆盖 |
| `CHAR.STATS／RESISTANCE` | `P1–P2` | 双列属性方向锁定 | Turtle WoW 扩展字段与下拉几何 |
| `CHAR.TABS` | `P1–P2` | 四个香草 Tab 方向锁定 | 实际 Tab 数量、点击区和状态 |
| `CHAR.REPUTATION／SKILLS／HONOR／ARENA` | `P1` | pfUI skin 对象已审计 | 分页实机对象与共享组件合同 |
| `CHAR.PET／INSPECT／DRESSUP` | `P1` | pfUI skin 对象已审计 | 确认复用与只读差异 |

## 已否决方向

- 横向双栏人物 Dashboard 与永久属性附页。
- 左上大型圆形肖像章。
- 右下大型黄铜龙头、涡卷和宝石底座。
- 底部四装备槽、五个彩色数值格。
- 宽紫品质框、连续外发光和过暗模型背景。

## 下一步

1. 在 Turtle WoW 记录 `CharacterFrame`、PaperDoll、全部装备槽、模型、
   属性、Tabs、下拉、关闭与旋转对象的尺寸、锚点、层级和状态。
2. 根据 [SUBMODULES.md](SUBMODULES.md) 确认哪些物理 atlas 可共享。
3. 为外壳、模型背景、槽、Tabs 与小控件分别建立 `work/` Prompt。
4. 完成 Character 后再验证 Inspect、DressUp 与 Pet 的复用差异。
