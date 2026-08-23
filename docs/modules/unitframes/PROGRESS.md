# Unit Frames 当前进度

## 当前运行时

- Bars、Raid 与动态头像配置合同继续运行。Player 由精确 route
  `unitframes.player-shell-v5` 接入 accepted V5 完整单图外壳；Target、
  TargetTarget、Focus 的旧 `unitframes.primary-shell` route 仍撤下并回退 pfUI。
- Unit Frames contract：`1.8`；SavedVariables `artVersion = 6`。
- 本模块只处理已登记的视觉、动态头像开关和相关回退；位置、点击、事件、数值、
  颜色逻辑与未登记 Frame 继续由 pfUI 持有。
- Player V5 accepted logical runtime 为 `254×77 UI`，现从 accepted source 直接
  导出为 `508×154` sampled region，透明补齐到 Turtle WoW 1.12 可加载的
  `512×256` TGA，并以精确 UV 排除补齐区。Lua 在当前 `240×60`
  配置产生的 `240×65` provider 上完整显示这一张图；UI Scale 随父框缩放，
  不切片、不重构、不拉伸 accepted 生皮与维修片。其他尺寸只回退 Player 的
  pfUI 外框。

| 范围 | 阶段 | 当前事实 |
|---|---:|---|
| 动态头像关闭 | `P5` | Player、Target、Focus、Party、Raid、Pet、各级 Target、fallback 共 13 组 portrait 以及两套 Raid Marker tracker 头像关闭；原配置按 profile 备份，禁用模块时恢复 |
| Health／Power fill | `P5` | accepted 灰阶 donor 以 2× runtime 接入 Player、Target、TargetTarget、Focus 与 Raid，由 provider 继续乘经典 Health／Mana／Rage／Energy／Focus 色 |
| Raid A2 外壳 | `P5` | A–D 四种 `148×74` sampled texture 以原 `74×37 UI` 显示并接入 `pfRaid1..40`；标准宽度完整纹理，其他宽度用同图三切片，高度失配局部回退 |
| Player V5 完整外壳 | `P5` | attempt 3 exact source 直接导出为 2×；单张 `508×154` sampled region 通过精确 UV 覆盖原 `254×77 UI` 外壳与 `240×65` provider，pfUI 保留 Bars、文字、颜色、Aura、图标、Hover／Aggro、点击与事件 |
| Player／Target V4 外壳 | `P4 / paused` | 旧 source／runtime 仅保留历史回退；九切片 adapter route 暂停，不再应用于 Player |
| TargetTarget A2 独立外壳 | `P4 / paused` | accepted base／rim 与四态 TGA 保留；九切片 adapter 保留但 route 暂停 |
| Focus A2 独立外壳 | `P4 / paused` | accepted base／rim 与四态 TGA 保留；九切片 adapter 保留但 route 暂停 |

## accepted source 与 runtime

- Bars source／manifest：`assets/source/unitframes/bars-v2/`；runtime：
  `Media/UnitFrames/UnitFrameHealthFillV1.tga`、
  `UnitFramePowerFillV1.tga`；分别为 `128×64` sampled／`64×32 UI` 与
  `128×32` sampled／`64×16 UI`。
- Raid A2 source／manifest：`assets/source/unitframes/raid-a2/`；runtime：
  `RaidMemberShellAV1.tga` 至 `RaidMemberShellDV1.tga`，均为 2× sampled。
- Player V5 source／runtime master／manifest：
  `assets/source/unitframes/player-v5/`；runtime：
  `Media/UnitFrames/UnitFramePlayerShellV5.tga`。
- Player／Target V4 source／runtime manifest：
  `assets/source/unitframes/primary-v4/`；runtime：
  `Media/UnitFrames/UnitFramePlayer*V1.tga`、
  `UnitFrameTarget*V1.tga`。
- TargetTarget A2 与 Focus A2 source／runtime manifest：
  `assets/source/unitframes/secondary-v1/`；runtime：
  `Media/UnitFrames/UnitFrameTargetTarget*V1.tga`、
  `UnitFrameFocus*V1.tga`。

## 下一次实机验证

1. 完整重启客户端后确认 Player、Target、Focus、Party、Raid、Pet、各级 Target、
   fallback 与两套 tracker 都没有 2D／3D 动态头像。
2. 在 `/pfui` 应用一次配置，确认头像不会被 provider 重新启用；随后关闭／重开
   `/aeui unitframes`，确认原 portrait 值与布局能恢复。
3. 验证 2× Health／Power TGA 方向、低血量裁切、Mana／Rage／Energy／Focus 乘色、
   UI Scale 和模块禁用回退。
4. 验证 2× 40 人 Raid A–D 分配、标准／变宽三切片、Aura、Raid Icon、距离、离线、
   复活层序和高度失配回退。
5. 在当前 Player `240×60` 配置（外层 provider `240×65`）检查 2× V5 外壳层序、
   Health／Power 嵌入、两块维修片、动态硬净空、Aura、UI Scale `0.80`、
   `/pfui` 应用配置后的自动重挂，以及 `/aeui unitframes` 禁用回退。
6. 相邻回归确认 Target、TargetTarget 与 Focus 的暂停外壳没有被本批密度迁移
   重新挂载，三者继续显示 pfUI 回退且文字／Bars／Aura／点击均正常。

## 下一门禁

等待 Turtle WoW 实机确认 Player V5 完整单图的层序、Health／Power 嵌入、
Aura／图标净空、UI Scale、配置重挂和禁用回退；Target、TargetTarget、Focus
仍等待各自新修复。静态通过不能标记 `P6`。

## 回退

模块、媒体、精确 route 或 Player canonical provider 尺寸不满足时，只回退对应
pfUI Frame。角色面板、观察和试衣间 3D 模型不属于本模块，始终保持原样。
