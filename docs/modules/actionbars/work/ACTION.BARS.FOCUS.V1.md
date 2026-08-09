# ACTION.BARS.FOCUS.V1 当前工作

## 当前状态

- 批次：`AB.FOCUS.LAYOUT.V1`
- 当前版本：`ACTION-BARS-CORE-SIM-V4`
- 子状态：`runtime-exported / pending-game-validation`
- 最高阶段：`P5`
- 操作：`integrate`
- ImageGen：`0/0`
- runtime：AEUI `0.8.9`／`focus-layout-contract=1.3`／
  `fieldkit-contract=1.6`。用户于 `2026-08-09` 明确接受
  `ACTION-BARS-CORE-SIM-V4`；adapter 已接入 accepted 坐标、`0.82` local scale
  与 ArchiTotem 强绑定。仓库未直接修改 pfUI／ArchiTotem 代码或角色
  SavedVariables；只有用户显式执行 focus preset 时才调用 provider 原生方向 API。

## 本次输入与结论

- 用户实机截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-66323032-06ec-4a4d-bdfc-17358a2453e9.png`
  ，`1443×1067 RGB`、SHA-256
  `3c4eeee293c6eb2b2b140a94bab2542834acc4ff8a8b8529e9e9a2aa6a26dc9a`。
- v1.2 已证明 Player／Target 不再覆盖左侧卷袋，但用户明确判定当前战斗核心
  “有点太小”。因此 v1.2 只保留为可回退的 P5 runtime，不进入 P6。
- 截图中的底部独立六按钮＋拖动球对象来自已安装的 `ArchiTotem 1.7`；用户口述
  “atomchi”按真实目录、TOC 与全局 Frame 校正为该 provider，不据名称另造控件。
- 用户确认后的缩放裁决：`0.75 → 0.82` 为线性 `+9.33%`，小于 `10%`；但面积
  增量为约 `+19.54%`，已足以作为“有点太小”的第一版实机修正。`0.85–0.86`
  会继续挤压单位框内缘、卷袋净空与底部卫星栏空间，未在本轮越过已接受 V4。

## 真实 provider 审计

| 对象 | 真实来源 | 当前职责与边界 |
|---|---|---|
| `ArchiTotemFrame` | `Interface/AddOns/ArchiTotem/ArchiTotem.xml` | `280×80 UI` 初始根，Lua 按可见特殊按钮重算宽度；父框关闭鼠标，只有真实 Button 接收输入 |
| `ArchiTotemButton_Earth1／Fire1／Water1／Air1` | `ArchiTotem_ButtonTemplate`，每枚 `40×40 UI` | 四元素当前图腾；左键施放、右键跳过、悬停打开本元素真实候选 |
| 元素候选 | Earth／Fire／Water 各最多 `5`，Air 最多 `7` | 由 provider 按 `direction=up／down` 纵向展开；图标、顺序、倒计时和点击均不接管 |
| `ArchiTotemDragHandle` | 独立 `20×20 UI` Button | 左键拖动整个根、右键锁定、Shift+左键复位；handle 不随 `Apperance.scale` 缩放 |
| `ArchiTotemButton_AllTotems` | `40×40 UI` | 一键依次施放四元素；右键显示特殊按钮 |
| `ArchiTotemButton_Recall` | 可选 `40×40 UI` | provider 的召回与冷却；当前角色显示 |
| `ArchiTotemButton_PresetManager`／`ArchiTotemPresetFrame` | 可选 Button＋独立 `350×450 UI` 对话框 | 当前角色主栏按钮隐藏；管理对话框保持独立居中／拖动，不纳入战斗甲板强绑定 |

当前“大奶黑牛 - Basin of Stars”实值为 `scale="0.8"`、`direction="up"`、
`showrecallbutton=true`、`showpresetmanagerbutton=false`、`locked=false`。闭合可见
脚印按 provider 缩放后为四枚 `32 UI` 元素槽＋未缩放 `20 UI` handle＋一键与
召回两枚 `32 UI`，合计 `212×32 UI`；Air 最大展开态为 `212×224 UI`。provider
自身 `RecalculateWidth` 不计 handle，布局／命中审查必须使用真实可见 union，
不能只信根 Frame 宽度。

## V4 可见布局合同

### 战斗核心可读性

- 全局 pfUI 继续保持 tier 8；不放大全屏、聊天、背包、小地图、Field Kit 或
  Combat Deck。
- 仅把 Player／Target、双方施法、主副手／远程攻击计时、姿态和 DoiteDPS 的
  local display compensation 从 `0.75` 改为 `0.82`，线性显示增加约 `9.3%`、
  面积增加约 `19.5%`。
- Player／Target 外侧总包络保持 V3／v1.2 宽度；两框中心内收，模拟内缘从
  `80 px` 变为 `34 px`，使增大的状态框不重新压住左卷袋。
- runtime 坐标采用反向校准，保持 v1.2 的物理基线：Player／Target
  `BOTTOM x=-153／153, y=613`；双施法 `x=-153／153, y=571`；Swing
  `CENTER y=-78`；姿态 `TOP y=-764`；DoiteDPS
  `TOPLEFT x=1012, y=-512, scale=0.82`。这些数值现由显式
  `/aeui focuslayout apply|comfort` 一次性写入当前角色 provider 配置。
- 左 `4×6` 消耗品卷袋、中央 `12×2` 动作条、右水平双饰品和 Bar 1 的位置／
  scale 完全保持，避免把“战斗信息偏小”错误修成整套 UI 再次遮挡视野。

### ArchiTotem 职业卫星栏

- 角色为萨满且 `ArchiTotemFrame` 存在时，把其真实可见脚印水平居中放在
  Bar 1／XP Rail 下方；不占 AutoBar 类别、不复制为 pfUI Action Button。
- 绑定态扩展现有 `fieldKitBound`：Bar 1 仍是唯一移动根；ArchiTotem 跟随，
  provider 拖动松手回到组合位。`unbind` 恢复首次捕获的自由锚点与原拖动。
- 显式 focus preset 才请求 provider `direction=down`，使候选从主栏向
  屏幕底部展开，不穿过动作格、施法条或单位框。普通 AEUI Apply／refresh 不写
  `ArchiTotem_Options`，用户以后手动改方向时以 provider 配置为准。
- 当前 `0.8` scale、四元素、一键、召回、拖动球、锁定、右键跳过、计时、预设、
  Tooltip 和施放顺序全部保持；预设管理对话框不绑定、不重绘。
- provider 缺失、非萨满、根隐藏或签名不匹配时不显示占位，不阻止 ActionBars
  其余 adapter。

## 本地确定性模拟

- renderer：`tools/render_action_bars_simulation.py`
- specification：`tools/specs/action_bars_core_simulation_v4.json`
- display contract：
  `tools/specs/action_bars_core_simulation_v4_display_region.json`
- Python：`D:/Softwares/miniconda3/python.exe`，Python `3.13.5`
- 命令：

  ```text
  D:/Softwares/miniconda3/python.exe tools/render_action_bars_simulation.py tools/specs/action_bars_core_simulation_v4.json --repo-root . --layout-report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V4/layout-report.json
  D:/Softwares/miniconda3/python.exe .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py tools/specs/action_bars_core_simulation_v4_display_region.json --report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V4/display-region-report.json
  ```

- scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V4/action_bars_core_sim_v4.png`，
  SHA `3307359c…a1867`。
- layout report：同目录 `layout-report.json`，SHA `f7b666d9…ae11`，
  `54/54 pass`、violations `0`。
- display report：同目录 `display-region-report.json`，SHA
  `24600000…fbd6`，`7/7 pass`、violations `0`。
- 最终 runtime display contract：
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `977c161b…6123`；报告
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.3/display-region-report.json`，
  SHA `710be470…4b2`，`7/7 pass`、violations `0`。
- runtime entrypoints：`addon/AzerothExpeditionUI/Modules/ActionBars.lua` SHA
  `24ef344e…f556`，`Core/Bootstrap.lua` SHA `de5b7b17…bc8b`，TOC SHA
  `d7380d52…6db1`；部署目录仍为仓库内 `addon/AzerothExpeditionUI` 与必需的
  `addon/pfUI`，ArchiTotem `1.7` 是已安装的可选 provider，缺失时 fail-open。
- fresh-checkout package：
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.3/addon-package-report.json`，
  SHA `a6a4ec74…16b9`，`status=pass`、violations `0`、
  `build_required_on_target_device=false`；目标设备只需同步并加载仓库内 addon。
- 本次未上传任何图，未调用 ImageGen；接受后只创建布局 adapter／合同，没有
  新增位图 source 或 runtime atlas。`generated/` 像素继续 ignored，不能晋级、
  裁切、上传或作为以后生产输入。

## 内部审查

- 范围／身份：pass。所有可见按钮都对应 ArchiTotem 真实对象；没有制造图腾格、
  药水格、倒计时或推荐数据。
- 几何／展示区：pass。当前闭合、Air 七层最大向下弹出、锁定 handle-gap、召回＋
  组合同时显示和双方施法／DoiteDPS 共 `7` 个真实场景全部装配；最大 popup 底部
  仍留 `3 px` 模拟净空。
- 综合色与视线：pass for user review。放大只发生在战斗读数，甲板与两侧随身栏
  不再二次变大；图腾候选打开时占用底部中央而不是战斗视野或动作格。
- 交互：static pass／pending game。Lua smoke 已验证显式方向请求、普通刷新不改
  provider 方向、拖动松手回位、`unbind` 恢复首次自由锚点、重新绑定及根隐藏
  fail-open；仍不能代替游戏内施放、右键跳过、hover 候选、锁定和 Recall 复测。
- 美术：不在本轮判断。图腾栏仍画作 provider 原控件占位，后期 UI 重绘必须另立
  对象级合同；模拟的平色／图标绝不是 accepted art。

## 下一门禁

目标角色 `/reload` 后显式执行一次 `/aeui focuslayout comfort`，确认
`/aeui status` 含 `version 0.8.9`、`focus-layout-contract=1.3`、
`focus-layout-display-scale=0.82`、`fieldkit-contract=1.6`、
`architotem-dock=bottom` 与 `architotem-direction=down`。随后实机验证满血／掉血、
有／无目标、双方施法、近战双持、远程计时、Aura 超过 `6`、DoiteDPS 锁定／
解锁，以及 ArchiTotem 四元素施放、右键跳过、Air 七层候选、拖动／锁定、Recall、
`unbind／bind` 恢复和缺失／非萨满 fail-open。0.82 可读性实机仍不足时，再以截图
进入独立 `0.85` 对照修订；本轮不盲目继续放大，ImageGen 保持 `0/0`。
