# Unit Frames 当前进度

## 当前运行时

- Unit Frames contract：`2.3`；SavedVariables `artVersion = 7`。
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

## 目标框架仇恨区（P5）

- 已按用户确认的两排 Debuff 联合预演接入 `unitframes.target-threat`：仅为真实
  `pfUI.uf.target` 底部增加同宽 `12 UI` 仇恨区，使用现有 CastFillV1，百分比字号
  `10 UI`。显示时原 Raid A2 细外缘向下包住仇恨区；目标框主体、生命／资源、
  位置、缩放、命中区和 pfUI-eliteoverlay 龙饰锚点不变。
- 功能启用期间固定预留 `12 UI`，目标下方 Aura 在 pfUI 自己的排列中整体让位；
  当前两排 Debuff 保持 `23 UI／每排 8 个／右起向左`，上方 Buff 不移动。
  数据缺失、过期、脱战、友方和切目标时只隐藏仇恨内容并收回视觉外缘，保留 Aura
  预留，避免跳动。沿用 provider 的图标层级 12、冷却层级 14，高于龙饰的层级 8；
  不接管冷却、层数、Tooltip 或点击。
- 数据、职责语义、70／85 风险档与颜色渐变均复用姓名板同一份 TWT／TMT 缓存，
  不要求世界姓名板实际可见，不新增请求或定时器。有效零值显示 `0%`；填充最多
  `100%`，文字保留真实比例（例如 `115%`）。现有 `/aeui plates mock` 同步预演
  两处显示，状态仍明确标记 MOCK，关闭或重载恢复真实数据。
- `/aeui threat on|off|status` 独立控制目标仇恨区，默认开启；关闭立即取消 Aura
  预留，姓名板继续工作。关闭姓名板职责、Unit Frames 或精确 route 时同步回退。
  `/aeui status` 的 `target-threat=visible|waiting|off` 与 `aura-inset=12|0` 可核对状态。
- 待 `/reload` 后组队战斗验证两处比例／颜色一致、0%／超额数值、切目标与脱战清理，
  以及数据暂缺时两排 Debuff 不回弹；相邻检查倒计时／层数不被龙尾盖住与 Tooltip。
  再用 `/aeui threat off`／`on` 检查恢复原位置与重新让位，并确认关闭 Unit Frames、
  职责模式或缺少 pfUI 目标框时安全回退。仅针对性检查通过，未标记 P6。

## 屏幕中心测距签（P5）

- 已接受并接入薄皮签、粗眼睛／斜杠眼睛；图标全部位于皮签内，保留距离状态色。
  当前实机反馈为过于显眼、数字挤压右铜片；已降低皮签明度／透明度，眼睛按配置的
  85% 显示并降低透明度，右侧完整 `14 UI` 固定端部前保留 `6 UI` 数字净空，待 `/reload` 复核。
  AEUI 开启时不显示“打脸”文字，红色及声音保留；“近战／盲区”与宠物距离不变。
- source／manifest：`assets/source/unitframes/distance-tag-v1/`；runtime 为
  `DistanceTagV1.tga`、`DistanceEyeOpenV1.tga`、`DistanceEyeBlockedV1.tga`，均 2×。
  路由 `unitframes.distance-indicator`，仍随 `/aeui unitframes` 总开关回退；
  `/aeui status` 显示 `distance-tag=true` 表示样式已启用，实际显示依赖 UnitXP 与 pfUI 原开关。
- 用户已手动实测两框之间的测距签布局可用；默认改为完整皮签在两框间水平居中，
  与两框垂直中心对齐，Buff／Debuff 分别在上／下方展开。Action Bars 每角色默认
  版本 `7` 将两框间距设为 `160 UI`，待 `/reload` 复核默认迁移与多排 Buff。
  原生相对锚点随两框布局移动，数字宽度变化时仍按完整皮签居中，前缀向上展开。禁用或缺少
  任一主框时恢复原始 Frame／文本锚点，不改写原位置 SavedVariables。
- 完整重启后检查普通距离、近战正面仅红色数字、背面／猎人盲区、视线遮挡与图标开关；
  无目标／距离读取失败时皮签隐藏，独立宠物读数保留。相邻验证两框光环净空与字体大小；本次位置调整用 `/reload` 复核。
  禁用 Unit Frames 后应恢复原眼睛和 provider 前缀，重新启用后恢复皮签。实机效果待确认。

- 测距签右侧采用已接受的 `16×16 UI` 平面短矛头方向针，替换 pfQuest 透视箭头；
  source／manifest 为 `assets/source/unitframes/distance-direction-v1/`，108 帧直接由
  高分辨率 source 旋转导出为 `512×256` 的 2× 图集。保留眼睛／
  数字／方向三个区域，有方向时增加 20 UI 净空且整签仍居中，沿用原 0.1 秒更新。
  读取 UnitPosition 的玩家／目标坐标与 GetPlayerFacing 或 pfQuestCompat 朝向；
  无坐标、无朝向或平面位置重合时隐藏方向，距离和视线不受影响。SuperWoW 官方
  文档只保证友方单位坐标，不承诺敌对单位总能返回坐标。
- `/reload` 后先以可读坐标的友方验证：前方箭头向上，左侧向左、右侧向右，转身
  与切换目标同步改变；相邻检查长距离读数不压方向针，禁用 Unit Frames 隐藏箭头。

## 姓名板施法与辅助信息（P5）

- `unitframes.nameplate-details` 复用玩家施法条的 CastFillV1／ReadoutShellV1，施法条
  高 12 UI，技能名居左、倒计时居右且独立预留宽度；原进度、引导与中断逻辑不变。
  层序修正后仍有填充超出边框的实机反馈；现改为与玩家施法条一致的双端锚定
  切片，上下沿直接跟随真实 StatusBar，不缓存边框高度。原生填充为 ARTWORK、
  底色为 BACKGROUND，禁用恢复原层序；待 `/reload` 实机确认。
- 技能、Aura 和图腾图标复用 Raid A2 细外框，保留原技能图片、层数、冷却和数量。
  动态创建的 Aura 同样接入；没有添加逐帧图标材质更新。
- 连击点以现有短铜刻痕表示，仍由 provider 的五格显隐表达点数；任务提示位于
  铜夹之外，施法时避开技能图标。公会名启用时放在姓名／目标指针上方，原目标的
  目标文字继续按职责模式隐藏，团队标记及语义色不重绘。
- `/reload` 验证施法／引导／中断、长技能名与时间净空、图标细边和 Aura 冷却；
  相邻检查 Aura 在施法条消失后仍回到完整身份条下方、任务图标不压铜夹。
  `/aeui plates off` 或禁用 Unit Frames 恢复原施法条高度／材质、图标和文本布局。
  连击点、图腾与公会名需在对应功能启用时实机验证；本轮不标记 P6。

## 姓名板行军身份条（P5）

- 已接受并接入常驻皮革端口、贴近名字的薄皮签与条内等级分隔，source／manifest
  位于 `assets/source/unitframes/nameplate-identity-v1/`。四张新素材均直接从 accepted
  高分辨率 source 导出为 2× runtime，原填充、皮革细边、指针与选中铜夹复用。
- 血条高 18 UI；等级字号为 provider 的 85%，等级位按字宽加 4 UI、最低 12 UI。
  总宽度以 pfUI 配置为下限，按完整血量读数加 12 UI 净空扩展；本次接管期间保留
  最大读数宽度，避免数字变化造成抖动。真实 StatusBar 独立显示血量，不遮盖低血填充。
  名字底签按文字宽度加 12 UI、高度加 6 UI 包覆；分隔铜条取有效像素显示为 3×16 UI。
  已针对“名字突出、等级过宽、血量省略、分隔弱”的实机反馈修正，待 `/reload` 复核。
- `/reload` 核对选中／未选中、长名字、60+／未知等级、低血量与完整血量数值；
  相邻检查施法条、光环及团队标记仍对齐完整身份条。友方未选中只名字时不显示皮签。
  `/aeui plates off` 或禁用 Unit Frames 恢复等级外置、原血条宽度与配置。尚待实机验收。

## 姓名板血条材质（P5）

- `unitframes.nameplate-health-fill` 已为真实 `nameplate.health` 复用主施法条的
  `Media/ActionBars/Readouts/CastFillV1.tga`：灰阶哑光颜料、克制横向刷痕，沿用
  `assets/source/actionbars/readouts-v1/` 的 accepted source／manifest，不新增位图。
- 血条高 `18 UI`，复用 ReadoutShellV1 上下各 `1 UI` 的皮革细边，总高 `20 UI`
  对齐现有铜夹；铜夹略降亮度，空血部分为不透明深烟褐底。pfUI 原边框／阴影继续隐藏。
  暗血量色按同一 RGB 比例提高至峰值 `.65`，保持色相与 Alpha；明亮职责色不变。
  血量与数值不变，provider 同步调整姓名板占位和施法图标高度。关闭模式恢复配置高度。仅创建、配置变化和模块应用时绑定，不加逐帧纹理维护。
- `/reload` 后比较满血／半血／低血量与坦克职责色，检查文字在暗部的可读性；
  相邻检查选中铜夹及姓名板施法条。`/aeui plates off` 或禁用 Unit Frames 恢复
  pfUI 当前配置高度、材质及原边框／阴影显隐。重点复核低血量底色、两端接缝、
  文字净空与施法／光环间距；本轮 `/reload` 验证。实机质感待确认。

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
  按用户要求恢复强制目标显示：目标所属类别关闭时临时开启引擎类别，额外非目标
  姓名板保持隐藏；已有敌方／友方姓名板继续显示。取消目标或关闭职责模式恢复
  原开关，保留期间手动 V／Shift-V 变更，不写入保存配置；同类别切换不重复 Show。
  用户已报告人多场景明显掉帧，目前接受这项开销，性能优化暂时搁置。
  待 `/reload` 复核关闭友方时选中／切换／取消目标、已有敌方姓名板与职责模式回退。
  首次 OnShow 先置零 Alpha，跨过一个原生布局周期后完成
  数据／几何／缩放更新再显示，避免旧位置和旧尺寸露出；同步 OnShow、布局门禁
  与后续缩放稳定性检查通过，仍待实机复核。
- 三模式均为未选中友方仅名字／团队标记，选中才显示血条；普通敌方显示血条。
  选中时整体放大至原比例的 `1.15`，保持不透明；不叠加目标光圈。已接受 V2 浅赭金指针（`24×24 UI`）与
  深皮革／短铜端夹（各 `10×20 UI`），按 2× 采样接入，替换粗黄括号。
  铜夹外置 `1 UI`；选中时等级距血条 `14 UI`，取消／禁用恢复 provider `5 UI`。
  血条隐藏时仅保留指针，铜夹隐藏；待密集团战实机确认辨识度。
  友方名字 Alpha 为 `.65`，
  坦克模式普通敌方为 `.85`，治疗／输出普通敌方为 `.75`，琥珀预警为 `.9`；当前目标和危险承伤为 `1`，
  未选中目标时敌方施法或团队标记保持至少 `.9`；已有目标时，治疗／输出非目标敌方使用聚焦层次：普通 `.6`、琥珀 `.85`、危险 `1`，
  施法／团队标记至少 `.85`；无目标恢复普通 `.75`、琥珀 `.9`、危险 `1`；
  坦克及友方仍保留普通 `.45`、重要单位 `.65` 的上限。取消目标恢复原职责透明度。
- 坦克：自己持有为低饱和绿，已确认其他坦克持有为蓝灰，非坦克友方玩家承伤为橙红；
  治疗／输出：普通敌方统一为高亮青蓝 `#36BFE0`，敌人攻击自己时橙红；有效仇恨预警再覆盖为琥珀／橙红，避免原生敌方红色与警告混淆。青蓝只表示未触发警告，不保证仇恨安全。其他坦克来源为 pfUI 既有坦克名单和团队
  坦克标记。仅使用可靠 live unit 信息，施法期间保留已知分类，不声称仇恨百分比。
- 仇恨颜色按最新有效比例作分段 RGB 线性插值：`≤50%` 保持基础青蓝／坦克绿，
  `50–70%` 渐变至琥珀，`70–85%` 渐变至橙红，`≥85%` 保持橙红。
  透明度仍按原 70／85 风险档和目标聚焦规则，不随渐变连续变化；无效／过期数据
  恢复基础承伤色，不新增比例文字，不增加计时器或请求频率。待实机复核中间色、
  选中／取消目标及脱战回退。
- 已按用户接受的预演改为共用外框的上下分区：生命区保持 `18 UI`，下方新增
  `8 UI` 仇恨区，只显示百分比，不显示“仇恨”文字；两区等宽，内部暗线分隔，
  复用 CastFillV1 颜料填充。身份条外缘、端口及选中铜夹包住两区，名字／指针
  不移动；等级保持生命区原位，施法及下方相邻内容跟随外框底边。
  只复用有效比例，显示长度限制在 `0–100%`；有效零值显示空轨，缺失／过期、
  友方、职责关闭和姓名板复用时隐藏，并收回外框新增高度。随真实血条显隐与缩放，
  不新增请求或定时器。共框布局待实机复核，预演通过不代表 P6。
  用户反馈野外组队未见细轨；已修正输出／治疗自己承伤时有效比例被过滤的问题，
  收到自身持有仇恨的有效数据后显示满格危险色。普通队伍回复接收仍待实机状态确认。
  待 `/reload` 后组队战斗验证比例变化、文字净空、切目标／脱战清理，相邻复核
  施法／光环及 `/aeui plates off` 回退。
- 临时 `/aeui plates mock` 为当前敌方目标预演仇恨增长：单人／脱战可用，
  `12s` 从 `0%` 增至 `100%`，满格停留 `2s` 后循环，沿用三档颜色与框内仇恨区。
  不写 SavedVariables、不发送请求或伪造服务器快照；`/aeui plates mock off`、
  关闭职责或 `/reload` 清除，`/aeui plates status` 明示 `threat-mock=ON`。
- 服务器仇恨辅助颜色已接入，待实机：职责启用且组队战斗中，以至多每 `0.5s`
  一次、单个待回复请求获取 TWT；坦克请求附带 TMT 群怪摘要。无需安装 TWThreat。
  当前目标只接收本角色来源、有效请求窗口内的数据，并核对实际承伤者；切目标后
  清空并等待 `1.5s`，名单刷新不重置请求计时，数据 `2s` 过期。协议没有请求 ID／目标 GUID，
  极迟回复仍有同承伤者混淆的限制，不承诺逐帧精确仇恨。
  坦克自己持有的怪：TMT 追赶者达到 `70%` 为琥珀、`85%` 为橙红；缺少群怪摘要
  时当前目标使用已返回的其他玩家仇恨／自己仇恨比值。其他坦克持有仍蓝灰，
  非坦克友方承伤仍橙红。治疗／输出当前目标直接以自己的仇恨／当前承伤者仇恨计算，
  达到 `70%` 为琥珀、`85%` 为橙红，近远程统一；已承伤仍橙红。
  群怪只按完整 GUID 匹配（支持十六进制与精确十进制），不按怪名猜测；缺失、死亡、
  脱战或过期沿用承伤对象判断并隐藏细轨，不显示伪造百分比，不新增数值行。
  用户确认恢复独立请求后 ShaguDPS 正常，姓名板输出模式仍为 `threat-packets=0/0`。
  已移除名单刷新重置计时的路径，并按 ShaguDPS 的规则识别包含 TWT 的前缀及正文中的
  TWTv4 数据段；仍校验发送者、频道、目标与时效。解析分开 TWT 与 TMT 后缀，待实机确认。
  `/aeui plates status` 的 `threat-packets=接受/看到` 与 `threat-source`
  用于实机核对实际前缀／频道／发送者；来源不符时拒收并保留旧判断，不自动放宽校验。
  实机先组队打敌人确认收到数据，再验证多只同名怪、目标切换、脱战清除、三职责颜色；
  相邻复核施法／光环，关闭职责及 ShaguDPS 缺失时验证回退与独立请求。
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
- 姓名板 V2 source／manifest：`assets/source/unitframes/nameplate-target-v2/`；
  runtime 为 `NameplateTargetCueV2.tga` 与 `NameplateTargetClaspLEFTV2.tga`／
  `NameplateTargetClaspRIGHTV2.tga`，保留旧 V1 媒体但不再使用。
- 旧姓名板目标指针 source／manifest：
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
   敌方施法与 V2 目标指针／铜夹；切换目标时放大／淡化即时更新，取消后缩放与透明度恢复；
   原本关闭敌／友姓名板时选中只出现当前目标、取消恢复；等级与血量不被挡住；
   施法临时换目标不得造成丢失仇恨误报。
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
