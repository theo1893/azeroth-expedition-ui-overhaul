# Unit Frames 当前进度

## 当前运行时

- Unit Frames contract：`2.1`；SavedVariables `artVersion = 7`。
- 团队 Buff／Debuff 图标接入 Raid A2 A／B 细边框（`P5`），保留原尺寸、间距、
  排列与 Debuff 类型色；单人／小队别名同样生效。待 `/reload` 验证团队 Aura、
  相邻团队血条及禁用回退；框内 Buff／驱散指示器保持 provider 原样。
- 玩家／目标／目标的目标／焦点现为团队 Raid A2 细边框试用：依次固定 A／B／C／D 款，
  精确 route 为 `unitframes.primary-thin-shell`。复用原 2× 纹理，四边外扩
  `2 UI`，同图 `6/62/6 × 6/25/6` 九切片保持边角厚度，适配实际宽高。
  纹理放在 provider 背景层，生命条、能量条、文字、精英龙饰与交互保持原有对象。
- 四框 Buff／Debuff 按钮通过 `unitframes.primary-aura-rim` 复用各自 Raid A2
  细边框，四边外扩 `2 UI`；隐藏原 pfUI backdrop，Debuff 类型色继续由 provider
  传递给细边框。图标、层数、冷却、Tooltip、点击与尺寸保持原有逻辑。
  Aura 锚到完整单位框，保留左右增长方向；按真实 `2 UI` 外扩计算步距，
  边框之间及首排与单位框之间均留 `1 UI` 净间隙，禁用后恢复 pfUI 间距与锚点。
- pfUI 独立 Buff／Debuff 与武器附魔按钮通过 `unitframes.standalone-aura-rim`
  复用同款细边框，隐藏原 backdrop／shadow；图标移到 ARTWORK 保持可见，
  原排列、计时、层数与点击不变。Debuff 类型色和武器品质色由 provider 透传，
  普通 Buff 保持材质本色；禁用恢复原边框、阴影与图标层。
- 玩家 V5／目标 V4 厚外壳实机视觉未通过，当前两条 route 均停用；旧 source
  和 runtime 保留，不把这次细边框试用视为最终美术验收。
- Bars、Raid A2、动态头像配置、姓名板指针与聚焦光环策略保持原有接入。
  TargetTarget、Focus 旧独立厚外壳仍暂停，当前采用细边框。没有改动团队框架的原三切片或高度合同。
- 阶段保持 `P5 / 待实机`；客户端 AddOns 目录链接直接读取仓库 runtime。

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

1. `/reload` 后确认玩家／目标／目标的目标／焦点都变为团队同款细边框，四角无接缝，文字和
   能量条不受遮挡；切换普通／精英目标，检查龙饰与细边框的组合。
2. 检查独立 Buff／Debuff／武器附魔面板的图标、计时、染色与右键取消，
   禁用 Unit Frames 后确认原边框和图标层恢复。再检查四框 Aura 的细边框、小图标净空与 Debuff 类型色；相邻检查冷却、层数
   和 Tooltip，团队框架边框不变。
3. 关闭／重开 `/aeui unitframes`，四框及其 Aura 边框应回退 pfUI／恢复细边框，
   点击和 Aura 不变。`/aeui status` 应显示 `contract=2.1` 与
   `primary-thin-shells=4/4`。

## 下一门禁

等待用户评价四框的细边框实机效果，再决定是否正式采用；不标记 `P6`。
姓名板指针、隐藏血条下团队标记的层序与相关禁用回退仍待完整实机验证。

## 回退

模块／细边框 route 禁用、provider 缺失或尺寸不足时不挂载细边框，并恢复
对应 pfUI backdrop／shadow。姓名板、Bars、动态头像继续按各自 route 局部回退。
