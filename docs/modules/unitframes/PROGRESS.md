# Unit Frames 当前进度

## 当前运行时

- Bars、Raid 与动态头像配置合同继续运行。Player 由精确 route
  `unitframes.player-shell-v5` 接入 accepted V5 完整单图外壳；Target、
  TargetTarget、Focus 的旧 `unitframes.primary-shell` route 仍撤下并回退 pfUI。
- 世界姓名板新增精确 route `unitframes.nameplate-target-cue`：直接复用 pfUI
  `nameplate.istarget` 显示个人头顶指针；provider 团队标记与血条显隐解耦。
- pfUI 姓名板可选“聚焦光环显示”已复用 Combat Focus 敌友策略；同一 `16` 格
  Debuff 优先、Buff 填余位，关闭后恢复原前 `16` 个 Debuff。
- Unit Frames contract：`1.9`；SavedVariables `artVersion = 7`。
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
| 世界姓名板个人目标指针 | `P5` | `NP-TARGET-CUE-V1` 候选 3 exact visible pixels 已接受；`40×48` sampled region 显示为 `20×24 UI`，读取 pfUI `nameplate.istarget`，顶部团队标记存在时自动向上堆叠 |
| 世界姓名板聚焦光环 | `P5` | 复用现有 `nameplate.debuffs[1..16]`；敌对保留自己的／固定关键 Debuff 与全部 Buff，友方保留全部真实 Buff／Debuff，关闭“聚焦光环显示”恢复原逻辑；策略缺失 fail-open |
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
- 姓名板目标指针 source／manifest：
  `assets/source/unitframes/nameplate-target-cue-v1/`；runtime：
  `Media/UnitFrames/NameplateTargetCueV1.tga`，`64×64` 容器内读取
  `(12,8)-(52,56)` 的 2× sampled region。
- Player／Target V4 source／runtime manifest：
  `assets/source/unitframes/primary-v4/`；runtime：
  `Media/UnitFrames/UnitFramePlayer*V1.tga`、
  `UnitFrameTarget*V1.tga`。
- TargetTarget A2 与 Focus A2 source／runtime manifest：
  `assets/source/unitframes/secondary-v1/`；runtime：
  `Media/UnitFrames/UnitFrameTargetTarget*V1.tga`、
  `UnitFrameFocus*V1.tga`。

## 下一次实机验证

1. 在敌对单位密集场景中连续切换目标，确认只有当前选中姓名板显示浅金指针，
   指针始终在姓名上方且不放大、不覆盖任何血条。
2. 关闭 pfUI 血条显示，给目标设置团队标记，确认姓名、个人指针和团队标记仍
   同时可见；团队标记配置在顶部时，个人指针稳定堆在其上方。
3. 关闭／重开 `/aeui unitframes`，确认只撤下／恢复个人指针，pfUI 姓名板、
   团队标记、点击和目标切换不受影响。
4. 在敌对与友方姓名板分别验证聚焦 Aura；再关闭 pfUI“聚焦光环显示”，确认
   立即恢复原前 `16` 个 Debuff，黑白名单与敌友显隐开关仍有效。
5. 相邻回归验证 2× Bars、40 人 Raid 和 Player V5；并确认 Target、TargetTarget、
   Focus 暂停外壳仍回退 pfUI。

## 下一门禁

等待 Turtle WoW 实机确认姓名板个人指针在团战、隐藏血条、顶部团队标记、
模块禁用四种状态下的可见性与层序，并继续确认 Player V5 的层序、Bars、Aura、
UI Scale 和回退。Target、TargetTarget、Focus 仍等待各自新修复；静态通过
不能标记 `P6`。

## 回退

模块、媒体、精确 route 或 Player canonical provider 尺寸不满足时，只回退对应
pfUI Frame；姓名板 route 缺失时只隐藏个人目标指针，provider 姓名板和团队
标记继续运行。“聚焦光环显示”关闭、Action Bars route 禁用或策略缺失时使用
pfUI 原姓名板 Debuff 路径。角色面板、观察和试衣间 3D 模型不属于本模块，
始终保持原样。
