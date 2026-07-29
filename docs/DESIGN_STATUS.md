# 设计状态索引

本文只说明视觉锁定状态；组件、源资产、原始提示词和 runtime 的实际阶段以
[`OVERHAUL_TRACKER.md`](implementation/OVERHAUL_TRACKER.md) 为准。整张视觉
基准达到 `P2`，不代表组件资产或插件实现完成。

## 已锁定

### 聊天框：战地旧书 V1

- 规范：[聊天框视觉规范_战地旧书_v1.md](modules/chat/聊天框视觉规范_战地旧书_v1.md)
- 游戏内基准：[聊天框视觉基准_v1.png](../assets/locked/chat/聊天框视觉基准_v1.png)
- 独立艺术母版：[聊天框独立艺术资源_v3.png](../assets/locked/chat/聊天框独立艺术资源_v3.png)
- V3 组件母版：[source/chat/v3](../assets/source/chat/v3/)
- 组件合同：[CHAT_COMPONENT_SPEC.md](implementation/CHAT_COMPONENT_SPEC.md)

不可重新解释为现代半透明聊天面板。厚封皮、多层毛边书页、皮革索引签与纸面文字属于不可变特征。
当前插件仍加载 `0.4.1` legacy 主框／Tab／输入／未读资源；legacy 信息底栏
已退役，V3 源资产尚未接入 runtime。

### 任务模块：公会任务卷宗与行军便笺 V1

- 规范：[任务模块视觉规范_公会任务卷宗与行军便笺_v1.md](modules/quests/任务模块视觉规范_公会任务卷宗与行军便笺_v1.md)
- 任务详情：[任务详情面板_视觉基准_v1.png](../assets/locked/quests/任务详情面板_视觉基准_v1.png)
- 任务追踪：[任务追踪面板_视觉基准_v1.png](../assets/locked/quests/任务追踪面板_视觉基准_v1.png)
- 基准提示词 provenance：[任务模块视觉原型提示词 V1](../prompts/quests/任务模块_视觉原型提示词_v1.md)

任务详情是正式双页卷宗；任务追踪是从卷宗抽出的窄长行军便笺。两者共享材料，但不能复制同一轮廓。

### 地图模块：远征地图卷与黄铜航向罗盘 V1

- 规范：[地图模块视觉规范_远征地图卷与黄铜航向罗盘_v1.md](modules/map/地图模块视觉规范_远征地图卷与黄铜航向罗盘_v1.md)
- 大地图：[大地图羊皮卷_视觉基准_v1.png](../assets/locked/map/大地图羊皮卷_视觉基准_v1.png)
- 小地图：[小地图黄铜罗盘_视觉基准_v1.png](../assets/locked/map/小地图黄铜罗盘_视觉基准_v1.png)
- 提示词：[大地图](../prompts/map/大地图羊皮卷_锁定提示词_v1.md)／[小地图](../prompts/map/小地图黄铜罗盘_锁定提示词_v1.md)

地图 V2 的重型皮革背板和永久插件轨道已明确弃用。

### 角色属性模块：香草同构角色面板 V1

- 规范：[角色属性模块视觉规范_香草同构角色面板_v1.md](modules/character/角色属性模块视觉规范_香草同构角色面板_v1.md)
- V3 基准：[角色属性面板_香草同构收敛_风格确认_v3.png](../assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png)
- 香草结构参考：[香草60级角色面板_结构参考.webp](../assets/references/香草60级角色面板_结构参考.webp)
- 锁定生成稿：[角色属性面板_锁定生成稿_v3.md](../prompts/character/角色属性面板_锁定生成稿_v3.md)

必须保持香草 `CharacterFrame / PaperDollFrame` 的紧凑结构；大型头像章、龙饰、四底槽、彩色数值格和横向现代仪表板已弃用。

## 尚未锁定

以下内容只有顶层描述或场景探索，不能直接当作最终实现依据：

- 玩家、目标、小队与四十人团队框架
- 双头狮鹫动作条、姿态栏、宠物栏和菜单按钮
- DPS、治疗、承伤和仇恨监控
- 消耗品、增益、减益和冷却监控
- 背包、银行、拾取与掷骰
- 法术书、天赋、专业与声望
- 商人、拍卖、邮件与交易
- Tooltip、确认窗口、首领警报和编辑模式
- 完整的主城、五人副本、四十人团本与 PvP HUD 布局

早期探索图和过程对照已经从仓库移除。被否决方案的结论只以模块规范和
`SESSION_DECISIONS.md` 中的文字记录为准。后续生图与修图固定使用
`imagegen-0-143-0`，并且只有组件级 `production` 提示词可进入 runtime
资产流程。
