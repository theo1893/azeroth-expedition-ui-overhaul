# BigWigs (ElesionWoW "Golden" 定制 fork) 开发约定

## TMH / 自定义团本 boss 模块
- 模块声明必须用**完整单位名**：`BigWigs:ModuleDeclaration("完整boss名", "Timbermaw Hold")`，并 `module.enabletrigger = module.translatedName`（参考 Karrsh/Perotharn）。
- 原因：`CheckForEngage` 用 `UnitName("target") == module.enabletrigger` **精确**匹配（Core.lua:723），且 `module:ToString()` 返回模块名（=完整 boss 名），`CheckForBossDeath` 的 `UNITDIESOTHER` 分支靠它匹配击杀。名字写短了会导致模块**永不启用** + 击杀不检测。
- 战斗日志触发器可保留 boss 名的**子串**（如「提里奥克…」在「吞噬者提里奥克…」中仍能 `string.find` 命中），更稳。
- 标记玩家用 `GetAvailableRaidMark(nil,true)` + `SetRaidTargetForPlayer` + `RestorePreviousRaidTargetForPlayer`（还原到改前 mark，含 0 即清除）。
- 自标在 emote 里显示「你」→ `resolveName` 转本地名；覆盖默认 `CHAT_MSG_COMBAT_HOSTILE_DEATH` 时必须手动调用 `BigWigs:CheckForBossDeath(msg, self)` 保留 boss 击杀检测。

## 自定义 boss emote 的 %t 坑
- 本 fork 部分自定义 boss emote，第一个目标名在日志里是字面 **%t**（boss 当前目标未被文本替换），其余目标名正常。
- 解析 `%t`：遍历 boss1~4 找到该 boss，取 `UnitName("boss"..i.."target")`。
- 注意：若 boss 不在 boss1~4 单位框上（如户外世界 boss 未占框），该解析返回 nil，需另加 targettarget 等兜底。

## 兼容性
- 1.12 / Turtle 客户端 Lua 5.0：不用 `string.match`/`string.gmatch`/`!=`/`//`（`~=` 正确）；`string.find` 捕获可用。
