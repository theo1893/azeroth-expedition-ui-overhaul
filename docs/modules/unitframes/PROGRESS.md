# Unit Frames 当前进度

## 当前运行时

- Unit Frames contract：`2.2`；SavedVariables `artVersion = 7`。
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
- Bars、Raid A2、动态头像配置保持原有接入；姓名板新增三职责显示，关闭模式时恢复 pfUI 原有显示与聚焦光环规则。
  TargetTarget、Focus 旧独立厚外壳仍暂停，当前采用细边框。没有改动团队框架的原三切片或高度合同。
- 阶段保持 `P5 / 待实机`；客户端 AddOns 目录链接直接读取仓库 runtime。

## 姓名板三职责模式（P5）

- `/aeui plates tank|healer|dps` 即时切换坦克／治疗／输出；默认输出。
  `/aeui plates off` 即时恢复 pfUI 配置并隐藏 AEUI 个人目标指针；
  `/aeui plates status` 显示保存值、实际模式与 provider 可用性。
- `/aeui config` 打开 pfUI 中的 AEUI 常用／布局／模块与回退页；常用页和
  原「姓名板」页共用职责选择。职责模式开启时，旧透明度、目标缩放／光圈、
  血条显隐、仇恨色覆盖和旧 Aura 筛选选项收起；关闭后原值和搜索入口恢复。
  坦克名单、敌友开关、点击穿透、字号与仍生效的 Aura 黑白名单继续可编辑。
  动态头像接管生效时也收起头像相关选项，关闭 Unit Frames 接管后恢复。
- 模式按 `角色名 - 服务器`
  保存在 `AzerothExpeditionUIDB.unitframes.nameplateProfiles`，不改写 pfUI 配置。
  世界敌友姓名板总开关继续由 pfUI／客户端控制。
- 三模式均为未选中友方仅名字／团队标记，选中才显示血条；普通敌方显示血条。
  不放大目标、不叠加目标光圈，复用固定个人目标指针。友方名字 Alpha 为 `.65`，
  普通敌方为 `.85`，治疗模式普通敌方为 `.65`；当前目标和危险承伤为 `1`，
  敌方施法或团队标记保持至少 `.9`。
- 坦克：自己持有为低饱和绿，已确认其他坦克持有为蓝灰，非坦克友方玩家承伤为橙红；
  治疗／输出：只有敌人攻击自己时橙红。其他坦克来源为 pfUI 既有坦克名单和团队
  坦克标记。仅使用可靠 live unit 信息，施法期间保留已知分类，不声称仇恨百分比。
- 目标敌方 Aura 最多 `6` 个，非目标敌方最多 `2` 个，选中友方最多 `4` 个，
  未选中友方为 `0`；共用固定单行区域。明确登记的中英文控制／免疫优先，
  再显示当前敌方目标上自己的 Debuff；友方选中时 Debuff 优先于 Buff。
  原敌友光环开关和 Debuff 黑白名单仍生效，缺少 live 数据时不猜测状态。
- 危险施法分类未启用；施法沿用 provider 数据与普通施法条。模式开启时允许
  非目标施法条，名字模式不更新隐藏施法条。目标／团队框继续承载完整信息。
- 指针纹理仅创建／版本变化时绑定，友方名字模式跳过隐藏血条与 Aura；血量事件
  合并到下一更新周期，目标切换即时处理。原生姓名颜色缓存独立于职业显示色。

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

姓名板优先验证：

1. 同一人群／镜头比较友方姓名板关闭与打开后的帧率、卡顿，选中／取消选中友方时
   血条立即出现／隐藏，名字和团队标记保留；不得有隐藏施法条带来的额外高频更新。
2. 依次切换三模式，核对坦克承伤分类、治疗／输出自身受攻击颜色、普通敌方对比度、
   敌方施法与目标指针；施法临时换目标不得造成丢失仇恨误报。
3. 检查 `6／2／4／0` 光环数量、控制／免疫优先级、光环结束后的清除；相邻检查
   目标框、团队框仍可查看详细状态以及姓名板点击／鼠标穿透行为。
4. `/aeui plates off`、重新启用、`/aeui unitframes` 禁用与恢复，以及另一角色的
   模式隔离；未加载 AEUI 或 provider 时保留各自原生路径。
5. 配置页保持打开时切换职责，确认旧选项与搜索同步收起／恢复、没有空行；
   关闭 Unit Frames 后头像设置恢复。AEUI 常用入口与原命令行为一致。

此前细边框待验收项继续保留：

1. `/reload` 后确认玩家／目标／目标的目标／焦点都变为团队同款细边框，四角无接缝，文字和
   能量条不受遮挡；切换普通／精英目标，检查龙饰与细边框的组合。
2. 检查独立 Buff／Debuff／武器附魔面板的图标、计时、染色与右键取消，
   禁用 Unit Frames 后确认原边框和图标层恢复。再检查四框 Aura 的细边框、小图标净空与 Debuff 类型色；相邻检查冷却、层数
   和 Tooltip，团队框架边框不变。
3. 关闭／重开 `/aeui unitframes`，四框及其 Aura 边框应回退 pfUI／恢复细边框，
   点击和 Aura 不变。`/aeui status` 应显示 `contract=2.2` 与
   `primary-thin-shells=4/4`。

## 下一门禁

等待用户评价四框的细边框实机效果，再决定是否正式采用；不标记 `P6`。
姓名板三职责模式、实际帧率改善、目标指针与隐藏血条下团队标记仍待完整实机验证。

## 回退

模块／细边框 route 禁用、provider 缺失或尺寸不足时不挂载细边框，并恢复
对应 pfUI backdrop／shadow。姓名板、Bars、动态头像继续按各自 route 局部回退。
