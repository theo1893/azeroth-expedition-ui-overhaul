# Azeroth Expedition pfUI 维护分支

## 用途

运行时目录 `addon/pfUI/` 保持标准插件名 `pfUI`，可直接复制到 Turtle WoW
`Interface/AddOns/pfUI/`。它继续提供 pfUI 的事件、数据、交互和兼容能力，
同时把公共视觉入口切换为 Azeroth Expedition 的过渡材质基线。尚未完成
组件级重绘的游戏界面默认使用香草／Turtle WoW 原生呈现，不再加载 pfUI 的
现代替换层。

## 上游

- 版本：`8.1.0`
- 提交：`fbc8fb608b79adf32049543ec12fcc020e0acd69`
- 许可：[addon/pfUI/LICENSE](../../addon/pfUI/LICENSE)（MIT）
- 初始本机差异：见 [PFUI_UPSTREAM_SNAPSHOT.md](PFUI_UPSTREAM_SNAPSHOT.md)

## 项目修改

| 文件 | 修改范围 | 功能边界 |
|---|---|---|
| `api/expedition.lua` | 新增统一材质、状态条、原生回退清单和 legacy panel 挂载策略 | 只决定呈现层路由与视觉配置；不处理游戏事件或数据 |
| `api/api.lua` | `CreateBackdrop` 选择材质表面并设置不透明度下限 | 保留原 Frame、层级、点击区和调用方 |
| `api/config.lua` | 新安装的视觉默认值 | 非视觉默认值不变 |
| `pfUI.lua` | 配置迁移后应用视觉合同；模块／skin 加载前执行呈现路由 | 注册顺序、事件入口与模块实现保留 |
| `modules/turtle-wow.lua` | 团队框与扩展 skin 检查实际路由状态 | 原生回退时不再隐藏 Turtle WoW 团队框；其他兼容逻辑不变 |
| `init/api.xml` | 加载视觉合同 | 不增删 pfUI 功能模块 |
| `pfUI.toc`、`pfUI-tbc.toc` | 标记维护分支版本和上游来源 | SavedVariables 与 Interface 不变 |

## 默认加载策略

| 当前呈现 | pfUI 模块范围 | 结果 |
|---|---|---|
| 项目接管 | `chat` | pfUI 保留聊天事件、停靠、输入与历史；`AzerothExpeditionUI` 绘制战地旧书 |
| 香草／Turtle WoW 原生 | 动作条、小地图、地图、单位框、团队框、施法、Buff、姓名板、经验条、背包、拾取、Roll、Tooltip | 不执行对应 pfUI 现代替换模块，原生 Frame 不会先被隐藏 |
| 香草／Turtle WoW 原生 | Character、Quest Log、Talents、Spellbook、Merchant 等全部 Blizzard skin | 不执行 pfUI skin，保持原生结构，等待组件级资源完成后逐项接管 |
| 项目公共材质 | `/pfui`、解锁、配置分享等维护工具 | 功能保留；可见公共 backdrop 使用非透明皮革／黄铜过渡材质 |
| 原功能 | 自动售卖／修理、任务物品识别、售价、装备比较、宏、社交、截图、Turtle WoW 与 SuperWoW 兼容 | 继续加载，不因呈现回退而删除 |

`modules/panel.lua` 本身没有删除：公会、背包空间、延迟、时钟、金币、耐久等
widget 和点击函数都仍在。默认路由不加载该呈现模块，并且输出槽仍被固定为
`none`，所以聊天框和小地图下方不会出现常驻信息 panel。需要比对上游时仍可
显式恢复。

## 回退开关

高级排查时可以在 SavedVariables 中设置：

```lua
pfUI_config.appearance.expedition.enabled = "0"
```

这会让公共 backdrop 回到 pfUI 原逻辑。若只为兼容测试临时恢复旧信息 panel：

```lua
pfUI_config.appearance.expedition.legacy_info_panels = "1"
```

随后在 pfUI 配置中选择需要的 widget 并重载界面。项目默认和正式视觉验收
仍要求该值为 `"0"`。

若要只对比 pfUI 原生替换层，同时保留项目公共材质：

```lua
pfUI_config.appearance.expedition.vanilla_fallback = "0"
pfUI_config.appearance.expedition.native_blizzard_skins = "0"
```

两个开关互相独立，修改后需要 `/reload`。它们不会写入
`pfUI_config.disabled`，因此不会永久改坏用户原有的模块启用设置。

## 测试组合

- 只启用 `pfUI`：验证功能底座、香草回退、原生双头狮鹫和维护工具公共材质。
- 同时启用 `pfUI` 与 `AzerothExpeditionUI`：验证聊天旧书等模块级重绘。
- 背包、拾取、动作条和单位框由客户端原生实现接管；它们的基础操作必须
  正常。自动售卖、修理、聊天事件、战斗数据、任务物品、售价与平台兼容等
  非呈现行为不得因视觉改造发生变化。

实机第一轮按以下顺序检查：

1. 登录后确认原生主动作条的左右双头狮鹫、玩家／目标框、小地图与 Buff 正常。
2. 打开 `C`、`L`、`N`、`M`、法术书、背包与系统菜单，确认都是原生结构，
   没有 pfUI 半透明方块 skin。
3. 拾取物品并触发一次 Roll；确认原生拾取、需求／贪婪／放弃均可交互。
4. 进入五人队伍和团队环境，确认 Turtle WoW 原生队伍／团队框没有被隐藏。
5. 同时启用两个插件后执行 `/aeui status`；预期包含
   `route=native-first` 与 `blizzard-skins=native`，并确认左下聊天为旧书、
   下方没有公会／背包／延迟 panel。
6. 验证自动售卖／修理、任务物品提示、售价、装备比较、宏和现有平台扩展；
   这些是保留功能，不应因呈现路由改变。
