# ACTION.BARS.FOCUS.V1 当前工作

## 当前状态

- 批次：`AB.FOCUS.LAYOUT.V1`
- 当前版本：`ACTION-BARS-CORE-SIM-V5`
- 子状态：`simulation-reviewed / revision-requested / runtime-unchanged`
- 最高阶段：`P5`
- 操作：`simulate`
- ImageGen：`0/0`
- runtime：AEUI `0.8.9`／`focus-layout-contract=1.3`／
  `fieldkit-contract=1.6` 仍是当前可回退 P5 实现。用户于 `2026-08-09` 的新实机
  截图证明 V4 固定坐标／统一 `0.82` 几何失败；本门禁只生成 V5 确定性布局预览，
  没有修改 adapter、pfUI／ArchiTotem 代码或角色 SavedVariables。V5 获用户确认前
  不进入 runtime 集成。

## 本次输入与结论

- V4 实机失败截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-5b64e0c0-3266-4f55-8aa8-8c1438ba88e4.png`
  ，`1304×1121 RGB`、SHA-256
  `350607ed463d5b0898333d428711505c066ed6eebe48c0400a11ce31d7ad990d`。
- 用户明确指出三项失败：施法栏与攻击栏重叠；战斗框架与动作甲板之间出现大面积
  未利用区域；Player／Target 过大并遮住人物主体。截图同时确认动作条、Field Kit、
  Trinket 与 ArchiTotem 本轮不需要改尺寸。
- 根因是 V4 把 Player／Target、双方施法、Swing、姿态和 DoiteDPS 一并从
  `0.75` 放大到 `0.82`，又把双单位框内缘从 `80 px` 压到 `34 px`，并沿用固定
  反向校准坐标；单项尺寸虽接近合适，组合后的层序、人物净空和甲板相对位置失稳。
- V5 将尺寸与位置解耦：Player／Target 和双方施法回到 `0.75`；Swing、姿态与
  DoiteDPS 保持 `0.82`；恢复 `80 px` 人物中线通道，并把 DoiteDPS → 攻击计时 →
  Aura → 单位框 → 双施法 → 姿态收成甲板相对的紧凑纵栈。当前只待用户确认该
  可见方向，未授权 runtime 坐标。
- 前一张 v1.2 实机截图：
  `C:/Users/西奥/AppData/Local/Temp/codex-clipboard-66323032-06ec-4a4d-bdfc-17358a2453e9.png`
  ，`1443×1067 RGB`、SHA-256
  `3c4eeee293c6eb2b2b140a94bab2542834acc4ff8a8b8529e9e9a2aa6a26dc9a`。
- v1.2 已证明 Player／Target 不再覆盖左侧卷袋，但用户明确判定当前战斗核心
  “有点太小”。因此 v1.2 只保留为可回退的 P5 runtime，不进入 P6。
- 截图中的底部独立六按钮＋拖动球对象来自已安装的 `ArchiTotem 1.7`；用户口述
  “atomchi”按真实目录、TOC 与全局 Frame 校正为该 provider，不据名称另造控件。
- V4 的缩放裁决 `0.75 → 0.82` 为线性 `+9.33%`、面积约 `+19.54%`；新实机
  证据否决的是统一缩放后的组合几何，不是否决攻击计时／DoiteDPS 的可读尺寸。
  因而 V5 不进入 `0.85–0.86`，也不把整组重新缩小。

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

## V4 runtime 与实机结论

### 已实机否决的战斗核心合同

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
- `2026-08-09` 新截图已否决以上单位框内收、统一 `0.82` 和固定坐标的组合；这些
  数值只描述当前可回退 runtime，不再作为下一版候选，也不得标记 game-validated。

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

## V5 待确认可见布局合同

- 全局 pfUI tier 8、Combat Deck、Field Kit、Trinket 和 ArchiTotem 几何保持不变；
  本轮只重排 `AB.FOCUS.LAYOUT.V1` 的战斗信息栈。
- Player／Target 与对应施法条使用 local scale `0.75`；模拟显示框各
  `239×61 px`，两框外包络仍为 `[681,660,1239,721]`，内缘恢复为
  `[920,1000]` 之间 `80 px` 的人物通道。
- DoiteDPS 保持 `0.82`，显示区 `[819,540,1102,581]`；主／副手攻击计时同样
  保持 `0.82`，分别位于 `y=600–611` 与 `614–625`。攻击层底部到 Aura 顶部
  `8 px`，到施法层顶部 `104 px`，不再与施法条争用同一层。
- Aura 为 `y=633–652`，单位框为 `660–721`，双方施法条为 `729–749`，姿态条
  顶部为 `763`，主动作条顶部为 `827`。战斗信息相邻层最大空隙 `19 px`；姿态条
  距主动作条 `64 px`，既保留动作识别空间，也消除截图中的大块闲置区域。
- 若用户确认，runtime 必须在显式 preset 时从当前 Bar 1 的实际中心／顶边推导
  等价 UIParent movable 坐标并一次性保存；不得复用 V4 的固定反向校准常量，普通
  refresh 仍不得持续重写 Parent、Point、Width 或 Height。
- 以上只定义几何方向；动态文字、图标、Aura、施法状态、Swing 进度、DoiteDPS
  推荐数据、单位框交互与 provider 行为全部保持真实运行时对象，不进入位图。

## 本地确定性模拟

- renderer：`tools/render_action_bars_simulation.py`
- specification：`tools/specs/action_bars_core_simulation_v5.json`，SHA
  `790746a5…07cb2`
- display contract：
  `tools/specs/action_bars_core_simulation_v5_display_region.json`，SHA
  `70d1f4fa…9bbd`
- Python：`D:/Softwares/miniconda3/python.exe`，Python `3.13.5`
- 命令：

  ```text
  D:/Softwares/miniconda3/python.exe tools/render_action_bars_simulation.py tools/specs/action_bars_core_simulation_v5.json --repo-root . --layout-report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V5/layout-report.json
  D:/Softwares/miniconda3/python.exe .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py tools/specs/action_bars_core_simulation_v5_display_region.json --report generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V5/display-region-report.json
  D:/Softwares/miniconda3/python.exe tests/action_focus_simulation_test.py
  ```

- scene：
  `generated/actionbars/ACTION-BARS-CORE/simulation/ACTION-BARS-CORE-SIM-V5/action_bars_core_sim_v5.png`，
  `1920×1080`，SHA `4ab387a5…8797`。
- layout report：同目录 `layout-report.json`，SHA `72636dd3…f345`，
  `59/59 pass`、violations `0`；覆盖人物净空左右边、`80 px` 通道、攻击到施法
  `104 px` 分层、相邻信息层最大 `19 px` 与 ArchiTotem 最大向下展开。
- display report：同目录 `display-region-report.json`，SHA
  `ec5fecae…2ea1`，`8/8 pass`、violations `0`；新增独立的 Player／Target、
  双施法、Swing、DoiteDPS 场景，保留 ArchiTotem 四态。
- 回归测试 `tests/action_focus_simulation_test.py` pass。测试锁定 split scale
  `0.75／0.82`、单位框内缘 `80 px`、人物通道边界、`59` 项布局检查与 `8` 个
  display 场景。
- V4 当前可回退 runtime display contract 仍为
  `tools/specs/action_focus_layout_v1_runtime_display_region.json`，SHA
  `977c161b…6123`；报告
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.3/display-region-report.json`，
  SHA `710be470…4b2`，`7/7 pass`、violations `0`。它只证明静态装配完整，新的
  游戏截图已否决其可见几何，不能据此晋级 P6。
- runtime entrypoints 未在 V5 门禁改动：`addon/AzerothExpeditionUI/Modules/ActionBars.lua` SHA
  `24ef344e…f556`，`Core/Bootstrap.lua` SHA `de5b7b17…bc8b`，TOC SHA
  `d7380d52…6db1`；部署目录仍为仓库内 `addon/AzerothExpeditionUI` 与必需的
  `addon/pfUI`，ArchiTotem `1.7` 是已安装的可选 provider，缺失时 fail-open。
- V4 fresh-checkout package：
  `generated/actionbars/ACTION-BARS-CORE/runtime/V1.3/addon-package-report.json`，
  SHA `a6a4ec74…16b9`，`status=pass`、violations `0`、
  `build_required_on_target_device=false`；V5 尚未进入 runtime，所以本门禁不伪造
  新 package 结论。
- 本次只读取用户截图作为失败证据，没有上传或变换它；没有调用 ImageGen，计数
  保持 `0/0`，也没有新增位图 source、runtime atlas、adapter 或 SavedVariables。
  `generated/` V5 像素继续 ignored，只用于当前方向确认，不能切片、晋级、上传或
  作为以后生产输入。

## 内部审查

- 范围／身份：pass。V5 只移动已审计的 Player／Target、双方施法、Swing、姿态、
  DoiteDPS；所有 ArchiTotem 可见按钮仍对应真实 provider 对象，没有制造单位状态、
  图腾格、倒计时或推荐数据。
- 几何／展示区：`59/59 pass`、`8/8 pass`、violations `0`。攻击层与施法层不重叠；
  单位框中间有精确 `80 px` 人物通道；DoiteDPS 到姿态的相邻层最大空隙为
  `19 px`；Combat Deck、两侧 Field Kit 与 ArchiTotem 最大展开边界保持不变。
- 综合色与视线：pass for user review。单位框／施法回落为 `0.75` 以清出人物，
  Swing／DoiteDPS 保持 `0.82` 以维持读数；信息栈整体贴近甲板，不再让尺寸问题与
  位置问题相互放大。
- 交互：not exercised at this gate。V5 尚无 runtime，不能把 V4 Lua smoke 或静态
  display 误记为 V5 游戏交互验证；现有 v1.3 的 provider 方向、拖动、`unbind` 与
  fail-open 行为保持原样。
- 美术：不在本轮判断。图腾栏仍画作 provider 原控件占位，后期 UI 重绘必须另立
  对象级合同；模拟的平色／图标绝不是 accepted art。

## 下一门禁

先由用户确认或否决 exact `ACTION-BARS-CORE-SIM-V5` 可见方向；确认对象只是布局
几何，不是模拟像素。确认前不修改 runtime、不要求 `/reload`，也不写目标角色
SavedVariables。若确认，再进入 `integrate`：升级 focus layout 合同，以 live Bar 1
中心／顶边投影一次性 preset，接入 `0.75` 单位／施法与 `0.82` Swing／姿态／
DoiteDPS，重新跑 Lua smoke、最终 runtime display 与 fresh-checkout package。之后才在
目标角色执行 `/reload`／显式 preset，并验证满血／掉血、有／无目标、双方施法、
近战双持、远程计时、Aura 超过 `6`、DoiteDPS 锁定／解锁，以及 ArchiTotem 施放、
右键、Air 七层、拖动／锁定、Recall、`unbind／bind` 和 fail-open。ImageGen 继续
保持 `0/0`。
