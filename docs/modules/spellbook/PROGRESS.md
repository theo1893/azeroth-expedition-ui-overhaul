# Spellbook 详细进度

## 当前结论

- 已完成 pfUI 与 Blizzard 1.12.1 技能书真实对象审计，阶段 `P1`。
- pfUI 当前把原生技能书 Strip 后换成规则半透明 backdrop；本模块只撤销现代
  skin，并保留法术、翻页、冷却、Tooltip、书类／技能系切换和宠物自动施法。
- 已按用户要求从 Talents 完全拆分；本轮只处理 Spellbook。
- `SB-SIM-V1` 已由用户接受并锁定为 P2 视觉基准；真实 384×512 轮廓、两列×
  六行、右侧技能系 Tab 与底部书类／翻页区域保持不变。
- 首批 `SB-A1 V1` 的 5 次实际 ImageGen 调用均因近 `1:1` bbox 失败；用户已授权
  `SB-A2-DONOR V1`，固定 attempt 1（SHA `afb16a7f…334b1`）为唯一只读材料。
- `SB-A2-DONOR V1` 运行时视觉已由用户接受。768×1024 source、384×512
  runtime master 和四块原生 TGA 已提升并接入 AEUI runtime `1.0`，阶段 `P5`。
- pfUI 的现代 Spellbook skin 已通过精确所有权关闭；Blizzard 法术、冷却、
  Tooltip、书类／技能系 Tab、翻页和宠物自动施法继续原样运行。左上原生
  `Spellbook-Icon` 固定隐藏，背景内没有烘焙职业图标。

## 子模块状态

| ID | 阶段 | 当前证据 | 下一门禁 |
|---|---:|---|---|
| `SB.FRAME／PAGE.FIELD` | `P5` | runtime `1.0`；tracked source/runtime、四块 TGA、无损重组和 addon adapter 已完成 | 实机验证 L 打开、缩放、层序与禁用回退 |
| `SB.EMBLEM` | `P5 hidden` | 用户要求移除左上图标；原生 direct Texture 与已知命名对象均由 adapter 隐藏 | 实机确认不同职业／宠物书均不显示图标 |
| `SB.SPELL／AUTOCAST` | `P1 contract` | 37×37 动态图标、文字、冷却与自动施法边界已拆分 | 主框方向通过后做状态级预演 |
| `SB.BOOK.TAB` | `P1 contract` | 3 个真实书类 Tab 已确认 | 确定首批生产是否包含 Tab |
| `SB.SKILL.TAB` | `P1 contract` | 最多 8 个动态图标 Tab 与 Flash 已确认 | 确定首批生产是否包含技能系索引 |
| `SB.PAGE.PREV／NEXT／TEXT／CLOSE` | `P1 contract` | 翻页、动态页码与关闭对象已确认 | 确定首批生产范围 |

## 当前预演审查点

1. 是否仍一眼属于 60 级香草技能书，而不是任务日志复制品或现代技能列表。
2. 页层、中央装订沟和封皮的透视／层序是否可信，书页是否看起来能够翻动。
3. 粗粝、不工整、低饱和和厚重感是否足够，又没有滑向暗黑 3 黑铁神龛。
4. 两列法术、右侧技能系 Tab、底部书类 Tab 与翻页净空是否清楚。

## 下一步

1. 在游戏设备验证 L 打开、384×512 对位、四块接缝、动态法术／标题层序、
   0.80／1.00／1.20 等比缩放，以及左上图标确实隐藏。
2. 使用 `/aeui spellbook` 验证 reload 后能回退 Blizzard 原生技能书，再次启用
   后恢复 SB-A2 外壳；pfUI 其他 skin 不受影响。
3. 主外壳实机通过后，再独立处理法术按钮、书类 Tab、技能系 Tab、翻页和关闭；
   `SB.EMBLEM` 不进入后续生产。
