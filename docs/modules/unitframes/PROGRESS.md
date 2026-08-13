# Unit Frames 当前进度

## 当前运行时

- Unit Frames contract：`1.2`。
- 本模块只处理已登记的视觉、动态头像开关和相关回退；位置、点击、事件、数值、
  颜色逻辑与未登记 Frame 继续由 pfUI 持有。

| 范围 | 阶段 | 当前事实 |
|---|---:|---|
| 动态头像关闭 | `P5` | Player、Target、Focus、Party、Raid、Pet、各级 Target、fallback 共 13 组 portrait 以及两套 Raid Marker tracker 头像关闭；原配置按 profile 备份，禁用模块时恢复 |
| Health／Power fill | `P5` | accepted 灰阶 donor 接入 Player、Target、TargetTarget、Focus 与 Raid，由 provider 继续乘经典 Health／Mana／Rage／Energy／Focus 色 |
| Raid A2 外壳 | `P5` | A–D 四种粗旧维修差异接入 `pfRaid1..40`；标准宽度完整纹理，其他宽度用同图三切片，高度失配局部回退 |
| Player／Target V4 外壳 | `P4 source-accepted` | 两张完整透明 source 已接受；当前 Combat Focus 为 `240×60`，V4 runtime 合同为 `214×42`，兼容方案确认前不导出、不接入 |
| TargetTarget／Focus 独立外壳 | `paused` | 尚无 accepted source，不从旧失败稿继续 |

## accepted source 与 runtime

- Bars source／manifest：`assets/source/unitframes/bars-v2/`；runtime：
  `Media/UnitFrames/UnitFrameHealthFillV1.tga`、
  `UnitFramePowerFillV1.tga`。
- Raid A2 source／manifest：`assets/source/unitframes/raid-a2/`；runtime：
  `RaidMemberShellAV1.tga` 至 `RaidMemberShellDV1.tga`。
- Player／Target V4 accepted source／manifest：
  `assets/source/unitframes/primary-v4/`。目前没有对应 runtime 文件。

## 下一次实机验证

1. `/reload` 后确认 Player、Target、Focus、Party、Raid、Pet、各级 Target、
   fallback 与两套 tracker 都没有 2D／3D 动态头像。
2. 在 `/pfui` 应用一次配置，确认头像不会被 provider 重新启用；随后关闭／重开
   `/aeui unitframes`，确认原 portrait 值与布局能恢复。
3. 验证 Health／Power TGA 方向、低血量裁切、Mana／Rage／Energy／Focus 乘色、
   UI Scale 和模块禁用回退。
4. 验证 40 人 Raid A–D 分配、标准／变宽三切片、Aura、Raid Icon、距离、离线、
   复活层序和高度失配回退。

## V4 下一门禁

先决定 `214×42` 外壳如何服务现有 `240×60` Combat Focus：优先保持完整源图，
只允许等比整体缩放或从同一 source 三切片变宽，禁止独立纵向拉伸。用本地真实
排版预演确认 Player／Target、状态条、文本、Aura 和相邻动作条净空后，再导出
runtime；普通逻辑修复不得顺带推进 V4。

## 回退

模块、媒体或精确 route 缺失时只回退对应 pfUI Frame。角色面板、观察和试衣间
3D 模型不属于本模块，始终保持原样。
