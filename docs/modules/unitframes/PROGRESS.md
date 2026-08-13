# Unit Frames 当前进度

## 当前运行时

- Bars、Raid 与动态头像配置合同继续运行；本批 Player／Target／TargetTarget／
  Focus 外壳的 `unitframes.primary-shell` route 已暂时撤下，客户端恢复接入前的
  pfUI 外框。accepted source、runtime 与 adapter 均保留待下一轮修复。
- Unit Frames contract：`1.6`；SavedVariables `artVersion = 5`。
- 本模块只处理已登记的视觉、动态头像开关和相关回退；位置、点击、事件、数值、
  颜色逻辑与未登记 Frame 继续由 pfUI 持有。
- Player／Target、TargetTarget、Focus 与 Raid 外壳的 accepted 逻辑像素保持不变；
  runtime 已透明补齐为 Turtle WoW 1.12 可加载的 2 次幂 TGA，并以精确 UV 排除
  补齐区。实机已确认外壳恢复可见，非 2 次幂容器导致的静默拒绝已解决。
- 暂停前实机图中，大框与次级框在现有放大布局下仍主要呈现为低对比深色矩形，
  接受外壳的端部维修和轮廓身份不够清楚；左侧次级框的名称与生命文字也发生
  挤压。先检查 base／rim 层序、Alpha、九切片与真实尺寸，不重新生成 source。

| 范围 | 阶段 | 当前事实 |
|---|---:|---|
| 动态头像关闭 | `P5` | Player、Target、Focus、Party、Raid、Pet、各级 Target、fallback 共 13 组 portrait 以及两套 Raid Marker tracker 头像关闭；原配置按 profile 备份，禁用模块时恢复 |
| Health／Power fill | `P5` | accepted 灰阶 donor 接入 Player、Target、TargetTarget、Focus 与 Raid，由 provider 继续乘经典 Health／Mana／Rage／Energy／Focus 色 |
| Raid A2 外壳 | `P5` | A–D 四种粗旧维修差异接入 `pfRaid1..40`；标准宽度完整纹理，其他宽度用同图三切片，高度失配局部回退 |
| Player／Target V4 外壳 | `P4 / paused` | 两张完整 source 已导出为 base／rim／Hover／Aggro；九切片 adapter 保留但 route 暂停 |
| TargetTarget A2 独立外壳 | `P4 / paused` | accepted base／rim 与四态 TGA 保留；九切片 adapter 保留但 route 暂停 |
| Focus A2 独立外壳 | `P4 / paused` | accepted base／rim 与四态 TGA 保留；九切片 adapter 保留但 route 暂停 |

## accepted source 与 runtime

- Bars source／manifest：`assets/source/unitframes/bars-v2/`；runtime：
  `Media/UnitFrames/UnitFrameHealthFillV1.tga`、
  `UnitFramePowerFillV1.tga`。
- Raid A2 source／manifest：`assets/source/unitframes/raid-a2/`；runtime：
  `RaidMemberShellAV1.tga` 至 `RaidMemberShellDV1.tga`。
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
3. 验证 Health／Power TGA 方向、低血量裁切、Mana／Rage／Energy／Focus 乘色、
   UI Scale 和模块禁用回退。
4. 验证 40 人 Raid A–D 分配、标准／变宽三切片、Aura、Raid Icon、距离、离线、
   复活层序和高度失配回退。
5. 在当前 `240×60` Combat Focus 和次级框布局中检查 base／rim 层序、Alpha 与
   九切片，恢复端部维修和不规则轮廓的可读性；修正左侧次级框名称／生命文字
   净空，再验证其他宽高、UI Scale、Hover／Aggro 和禁用回退。
6. 验证 TargetTarget A2 在 canonical `100×22` 与当前放大布局中仍保持次级重量，
   九切片不拉坏端部维修，文字／Bars／Aura／点击不被覆盖，禁用时恢复 pfUI。
7. 验证 Focus A2 在 canonical `100×27` 与当前 `240×60` 布局中，右上猎踪布结
   不被中央拉伸、不碰 Aura，FocusCastbar 仍在下方，Hover／Aggro、点击和禁用
   回退正常。

## 下一门禁

等待 Turtle WoW 实机确认 Player／Target、TargetTarget 与 Focus 的九切片、
状态层序、Aura／FocusCastbar 净空及禁用回退；静态通过不能标记 `P6`。

## 回退

模块、媒体或精确 route 缺失时只回退对应 pfUI Frame。角色面板、观察和试衣间
3D 模型不属于本模块，始终保持原样。
