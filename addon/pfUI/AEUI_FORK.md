# Azeroth Expedition pfUI 维护分支

## 用途

本目录保持标准插件名 `pfUI`，可直接复制到 Turtle WoW
`Interface/AddOns/pfUI/`。它继续提供 pfUI 的事件、数据、交互和兼容能力，
同时把公共视觉入口切换为 Azeroth Expedition 的过渡材质基线。

## 上游

- 版本：`8.1.0`
- 提交：`fbc8fb608b79adf32049543ec12fcc020e0acd69`
- 许可：同目录 `LICENSE`（MIT）
- 初始本机差异：见 `UPSTREAM_SNAPSHOT.md`

## 项目修改

| 文件 | 修改范围 | 功能边界 |
|---|---|---|
| `api/expedition.lua` | 新增统一材质、状态条、狮鹫和 legacy panel 挂载策略 | 只写视觉配置；不处理游戏事件或数据 |
| `api/api.lua` | `CreateBackdrop` 选择材质表面并设置不透明度下限 | 保留原 Frame、层级、点击区和调用方 |
| `api/config.lua` | 新安装的视觉默认值 | 非视觉默认值不变 |
| `pfUI.lua` | 配置迁移后应用视觉合同；替换早期 fallback backdrop | 模块加载顺序与事件入口不变 |
| `init/api.xml` | 加载视觉合同 | 不增删 pfUI 功能模块 |
| `pfUI.toc`、`pfUI-tbc.toc` | 标记维护分支版本和上游来源 | SavedVariables 与 Interface 不变 |

`modules/panel.lua` 本身没有删除：公会、背包空间、延迟、时钟、金币、耐久等
widget 和点击函数都仍在。视觉合同仅把默认输出槽设为 `none`，因此聊天框与
小地图下方不再出现强制常驻 panel。

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

## 测试组合

- 只启用 `pfUI`：验证功能底座、公共材质、状态条和狮鹫。
- 同时启用 `pfUI` 与 `AzerothExpeditionUI`：验证聊天旧书等模块级重绘。
- 自动售卖、修理、背包操作、聊天事件、战斗数据与第三方兼容行为不得因视觉
  改造发生变化。
