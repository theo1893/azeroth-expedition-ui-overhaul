-- ArchiTotem 核心模块
-- 包含主要的游戏逻辑和事件处理

if SUPERWOW_VERSION then
	SLASH_UTB1 = "/tooltip"
	SlashCmdList["UTB"] = function() end
end

local _G = getfenv()
local L = ArchiTotemLocale
local version = GetAddOnMetadata("ArchiTotem", "Version")
local author = GetAddOnMetadata("ArchiTotem", "Author")

local _, class = UnitClass("player")
local CLOCK_UPDATE_RATE = 0.1

-- 全局变量
ArchiTotemCasted = nil
ArchiTotemCastedTotem = nil
ArchiTotemCastedElement = nil
ArchiTotemCastedButton = nil
ArchiTotemActiveTotem = {}

-- 图腾掌握天赋加成（持续时间系数，0.2 即 +20%）
ArchiTotem_TotemicMasteryBonus = 0
ArchiTotem_ImprovedFireTotemsRank = 0

local friendlyDurationTotems = {
	["Tremor Totem"] = true, ["Strength of Earth Totem"] = true,
	["Stoneskin Totem"] = true, ["Frost Resistance Totem"] = true,
	["Flametongue Totem"] = true, ["Mana Spring Totem"] = true,
	["Healing Stream Totem"] = true, ["Fire Resistance Totem"] = true,
	["Poison Cleansing Totem"] = true, ["Disease Cleansing Totem"] = true,
	["Tranquil Air Totem"] = true, ["Grounding Totem"] = true,
	["Windfury Totem"] = true, ["Grace of Air Totem"] = true,
	["Nature Resistance Totem"] = true, ["Windwall Totem"] = true,
}

-- Base data stays unchanged, so repeated updates cannot compound bonuses.
function ArchiTotem_GetEffectiveDuration(totem)
	local duration = math.max(0, tonumber(totem.duration) or 0)
	if totem.name == "Fire Nova Totem" then
		return math.max(0, duration - (ArchiTotem_ImprovedFireTotemsRank or 0))
	end
	if friendlyDurationTotems[totem.name] then
		return duration * (1 + (ArchiTotem_TotemicMasteryBonus or 0))
	end
	return duration
end

local function UpdateImprovedFireTotems()
	if not GetNumTalentTabs or not GetNumTalents or not GetTalentInfo then return end
	local tabs = GetNumTalentTabs() or 0
	if tabs == 0 then return end
	local rank = 0
	for tab = 1, tabs do
		for index = 1, (GetNumTalents(tab) or 0) do
			local name, _, _, _, points = GetTalentInfo(tab, index)
			if name == "Improved Fire Totems" or name == "强化火焰图腾" or
				name == "強化火焰圖騰" then
				rank = math.max(rank, math.min(2, math.max(0, tonumber(points) or 0)))
			end
		end
	end
	ArchiTotem_ImprovedFireTotemsRank = rank
end
-- 当前是否处于“图腾掌握”有效状态（nil 表示未初始化，用于触发首次提示）
ArchiTotem_TotemicMasteryActive = nil
-- 首次进入时的天赋检测兜底（延迟一次执行，防止时序过早）
ArchiTotem_TalentsInitPending = true
ArchiTotem_TalentsInitDeadline = nil

-- 登录后天赋检测的轮询重试控制（避免过早调用 GetTalentInfo 返回空）
ArchiTotem_TalentsRetryActive = false
ArchiTotem_TalentsRetryNext = nil
ArchiTotem_TalentsRetryDeadline = nil
ArchiTotem_TalentsPollInterval = 0.5 -- 秒

-- 支持多语言匹配的天赋名称
local TOTEMIC_MASTERY_NAMES = {
	["Totemic Mastery"] = true,
	["图腾掌握"] = true,
	["图腾精通"] = true,
}

-- 模糊匹配：兼容多种翻译/写法（避免仅精确等于失败）
local function ArchiTotem_IsTotemicMasteryName(name)
	if not name then return false end
	if TOTEMIC_MASTERY_NAMES[name] then return true end
	-- 英文模糊：包含 Totem/ Totemic 与 Mastery
	local lname = tostring(name)
	if string.find(lname, "Totem") and string.find(lname, "Master") then
		return true
	end
	-- 中文模糊：包含 “图腾” 且 包含 “掌/精通/统御”等关键词
	if string.find(lname, "图腾") and (string.find(lname, "掌") or string.find(lname, "精通") or string.find(lname, "统御")) then
		return true
	end
	return false
end

-- 可能的“图腾掌握”天赋位置候选（tab=1元素/2增强/3恢复；index为列内序号），不同版本/私服可能不同
local TOTEMIC_MASTERY_CANDIDATES = {
	{ tab = 3, index = 8 },  -- 用户环境扫描结果
	{ tab = 3, index = 5 },  -- 恢复系常见位置（示例）
	{ tab = 3, index = 4 },
	{ tab = 3, index = 2 },
	{ tab = 2, index = 5 },  -- 增强系（兼容潜在改动）
}

-- 判断天赋 API 是否已可用：至少能拿到任意一个天赋的 name
local function ArchiTotem_IsTalentAPIReady()
	if not GetNumTalentTabs or not GetNumTalents or not GetTalentInfo then
		return false
	end
	local numTabs = GetNumTalentTabs()
	if not numTabs or numTabs <= 0 then return false end
	for tab = 1, numTabs do
		local n = GetNumTalents(tab)
		if n and n > 0 then
			local name = select(1, GetTalentInfo(tab, 1))
			if name ~= nil and name ~= "" then
				return true
			end
		end
	end
	return false
end

-- 启动一次登录后的天赋检测轮询（带超时）
function ArchiTotem_ScheduleTalentDetection(reason, timeoutSec)
	-- 如果已经在轮询，或已经有明确状态（非nil），就不要重复安排
	if ArchiTotem_TalentsRetryActive or ArchiTotem_TotemicMasteryActive ~= nil then
		return
	end
	ArchiTotem_TalentsRetryActive = true
	ArchiTotem_TalentsRetryNext = GetTime() + (ArchiTotem_TalentsPollInterval or 0.5)
	ArchiTotem_TalentsRetryDeadline = GetTime() + (timeoutSec or 15)
	ArchiTotem_TalentsInitPending = false -- 使用新轮询取代旧的一次性兜底
	if ArchiTotem_Options and ArchiTotem_Options["Debug"] then
		ArchiTotem_Print(string.format("[天赋] 启动轮询（原因=%s，超时=%ds）", tostring(reason), timeoutSec or 15), "debug")
	end
end

-- 打印“图腾掌握”当前状态
function ArchiTotem_PrintTotemicMasteryStatus()
	local mode = "自动"
	if ArchiTotem_Options and ArchiTotem_Options.ForceTotemicMastery ~= nil then
		mode = (ArchiTotem_Options.ForceTotemicMastery and "强制开启" or "强制关闭")
	elseif ArchiTotem_Options and ArchiTotem_Options.TotemicMasteryTab and ArchiTotem_Options.TotemicMasteryIndex then
		mode = string.format("索引: %d:%d", ArchiTotem_Options.TotemicMasteryTab, ArchiTotem_Options.TotemicMasteryIndex)
	end
	if ArchiTotem_TotemicMasteryActive then
		ArchiTotem_Print("图腾掌握：已启用（+20% 持续时间） [" .. mode .. "]")
	else
		ArchiTotem_Print("图腾掌握：未启用 [" .. mode .. "]")
	end
end

-- 刷新天赋加成（有图腾掌握则 +20% 持续时间）
function ArchiTotem_UpdateTalents()
	if class ~= "SHAMAN" then
		ArchiTotem_TotemicMasteryBonus = 0
		ArchiTotem_ImprovedFireTotemsRank = 0
		return
	end
	UpdateImprovedFireTotems()
	local hasTalent = false

	-- 0) 手动强制：/at talent totemic on|off 方式预留（下文命令实现）
	if ArchiTotem_Options and ArchiTotem_Options.ForceTotemicMastery ~= nil then
		hasTalent = (ArchiTotem_Options.ForceTotemicMastery == true)
		ArchiTotem_TotemicMasteryBonus = hasTalent and 0.20 or 0
		local prev = ArchiTotem_TotemicMasteryActive
		ArchiTotem_TotemicMasteryActive = hasTalent
		if prev ~= hasTalent then
			ArchiTotem_PrintTotemicMasteryStatus()
		end
		if ArchiTotem_Options["Debug"] then
			ArchiTotem_Print("[天赋] ForceTotemicMastery=" .. tostring(hasTalent))
		end
		return
	end

	-- 1) 优先：如果设置里手动指定了 tab+index，则优先用它
	if ArchiTotem_Options and ArchiTotem_Options.TotemicMasteryTab and ArchiTotem_Options.TotemicMasteryIndex then
		local tab = ArchiTotem_Options.TotemicMasteryTab
		local index = ArchiTotem_Options.TotemicMasteryIndex
		local name, _, _, _, rank = GetTalentInfo(tab, index)
		if name and ArchiTotem_IsTotemicMasteryName(name) and (rank or 0) > 0 then
			hasTalent = true
			if ArchiTotem_Options["Debug"] then
				ArchiTotem_Print(string.format("[天赋] 使用手动索引 tab=%d index=%d 命中：%s (rank=%d)", tab, index, name, rank), "debug")
			end
		else
			if ArchiTotem_Options["Debug"] then
				ArchiTotem_Print(string.format("[天赋] 手动索引 tab=%d index=%d 未命中或未点天赋（name=%s）", tab, index, tostring(name)), "debug")
			end
		end
	end

	-- 2) 若未命中：按已知位置候选快速判断（参考 Cat 的“按索引判断”思路）
	for _, pos in ipairs(TOTEMIC_MASTERY_CANDIDATES) do
		if GetTalentInfo then
			local name, _, _, _, rank = GetTalentInfo(pos.tab, pos.index)
			if name and ArchiTotem_IsTotemicMasteryName(name) and (rank or 0) > 0 then
				hasTalent = true
				if ArchiTotem_Options and ArchiTotem_Options["Debug"] then
					ArchiTotem_Print(string.format("[天赋] 在tab=%d index=%d 检测到：%s (rank=%d)", pos.tab, pos.index, name, rank), "debug")
				end
				break
			end
		end
	end

	-- 3) 兜底：全量扫描所有天赋名（模糊匹配）
	if not hasTalent then
		local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 0
		for tab = 1, numTabs do
			local numTalents = GetNumTalents(tab) or 0
			for i = 1, numTalents do
				local name, _, _, _, rank = GetTalentInfo(tab, i)
				if name and ArchiTotem_IsTotemicMasteryName(name) and (rank or 0) > 0 then
					hasTalent = true
					if ArchiTotem_Options and ArchiTotem_Options["Debug"] then
						ArchiTotem_Print(string.format("[天赋] 扫描命中 tab=%d index=%d：%s (rank=%d)", tab, i, name, rank), "debug")
					end
					break
				end
			end
			if hasTalent then break end
		end
	end
	ArchiTotem_TotemicMasteryBonus = hasTalent and 0.20 or 0
	local prev = ArchiTotem_TotemicMasteryActive
	ArchiTotem_TotemicMasteryActive = hasTalent
	if prev ~= hasTalent then
		ArchiTotem_PrintTotemicMasteryStatus()
	end
	if ArchiTotem_Options and ArchiTotem_Options["Debug"] then
		ArchiTotem_Print("[天赋] 图腾掌握检测：" .. (hasTalent and "+20%" or "未激活"), "debug")
	end
end

-- 工具函数
function ArchiTotem_Print(msg, type)
	if class ~= "SHAMAN" then
		return
	end

	local prefix
	if type == "error" then
		prefix = "|CFF20B2AA[ArchiTotem] |CFFFF0000[ERROR]|r  "
	elseif type == "debug" then
		prefix = "|CFF20B2AA[ArchiTotem] |CFF0000CD[DEBUG]|r  "
	else
		prefix = "|CFF20B2AA[ArchiTotem]|r  "
	end
	return DEFAULT_CHAT_FRAME:AddMessage(prefix .. msg)
end

function ArchiTotem_IsShaman()
	return class == "SHAMAN"
end

function ArchiTotem_Noop()
	return
end

-- 主加载函数
function ArchiTotem_OnLoad()
	if class ~= "SHAMAN" then
		ArchiTotem_Options = nil
		ArchiTotem_TotemData = nil
		this:UnregisterAllEvents()
		ArchiTotemFrame:Hide()
		return
	end

	-- 初始化数据
	ArchiTotem_InitializeOptions()
	ArchiTotem_InitializeTotemData()
	ArchiTotem_CheckCompatibility()
	
	-- 确保图腾元素数组存在
	if not ArchiTotem_TotemElements then
		ArchiTotem_TotemElements = {"Earth", "Fire", "Water", "Air"}
	end

	-- 设置拖拽
	this:RegisterForDrag("RightButton")
	for _, popout in ipairs(ArchiTotem_PopoutButtons) do
		_G[popout]:SetScript("OnDragStart", ArchiTotem_Noop)
		_G[popout]:SetScript("OnDragStop", ArchiTotem_Noop)
	end

	-- 注册事件
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("SPELLCAST_STOP")
	this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	this:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
	this:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	this:RegisterEvent("PLAYER_ENTERING_WORLD")
	this:RegisterEvent("PLAYER_LOGIN")
	this:RegisterEvent("PLAYER_ALIVE")
	this:RegisterEvent("SPELLS_CHANGED")
	-- 天赋变化事件（加点/洗点）
	this:RegisterEvent("PLAYER_TALENT_UPDATE")
	this:RegisterEvent("CHARACTER_POINTS_CHANGED")

	-- 注册命令
	SLASH_ARCHITOTEM1 = "/architotem"
	SLASH_ARCHITOTEM2 = "/at"
	SlashCmdList["ARCHITOTEM"] = ArchiTotem_Command

	DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff图腾助手 已加载|r /at")

	-- 确保UI显示状态正确
	ArchiTotem_UpdateShown()

	-- 初始化预设管理器
	ArchiTotem_InitPresetManager()

	-- 初始化拖拽手柄
	ArchiTotem_LoadFramePosition()
	ArchiTotem_UpdateDragHandleVisibility()

	-- 调试信息
	if ArchiTotem_Options and ArchiTotem_Options["Debug"] then
		if ArchiTotem_OnUpdate then
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[DEBUG] ArchiTotem_OnUpdate 函数存在|r")
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[ERROR] ArchiTotem_OnUpdate 函数不存在|r")
		end
	end
end

-- 确保图腾数据完整性
function ArchiTotem_EnsureDataIntegrity()
	if not ArchiTotem_TotemData then
		return false
	end
	
	local currentTime = GetTime()
	
	-- 检查并修复所有图腾数据
	for buttonName, totemData in pairs(ArchiTotem_TotemData) do
		if totemData then
			-- 确保 casted 字段存在
			if totemData.casted == nil then
				totemData.casted = currentTime - (totemData.cooldown or 0)
			end
			
			-- 确保 cooldown 字段存在
			if totemData.cooldown == nil then
				totemData.cooldown = 0
			end
			
			-- 确保 duration 字段存在
			if totemData.duration == nil then
				totemData.duration = 0
			end
		end
	end
	
	return true
end

-- 事件处理
function ArchiTotem_OnEvent(event)
	if event == "VARIABLES_LOADED" then
		-- 确保数据完整性
		ArchiTotem_EnsureDataIntegrity()
		-- 启动天赋检测轮询（避免过早调用返回空）
		ArchiTotem_ScheduleTalentDetection("VARIABLES_LOADED", 20)
		
		ArchiTotem_ClearAllCooldowns()
		ArchiTotem_UpdateTextures()
		ArchiTotem_UpdateShown()
		ArchiTotem_SetDirection(ArchiTotem_Options["Apperance"].direction)
		ArchiTotem_SetScale(ArchiTotem_Options["Apperance"].scale)
		ArchiTotem_Order(ArchiTotem_Options["Order"].first, ArchiTotem_Options["Order"].second,
			ArchiTotem_Options["Order"].third, ArchiTotem_Options["Order"].forth)
			
		-- 确保组合按钮的显示状态选项存在
		if ArchiTotem_Options["Apperance"].showpresetmanagerbutton == nil then
			ArchiTotem_Options["Apperance"].showpresetmanagerbutton = true
		end
		
		-- 确保召回按钮的显示状态选项存在
		if ArchiTotem_Options["Apperance"].showrecallbutton == nil then
			ArchiTotem_Options["Apperance"].showrecallbutton = false
		end
		
		-- 检查是否是第一次使用，如果是则应用PVE预设
		if ArchiTotem_Options["Apperance"].isFirstTime == true then
			ArchiTotem_Options["Apperance"].isFirstTime = false
			ArchiTotem_SetPreset("pve")
			ArchiTotem_Print("欢迎使用图腾大师！已自动设置为PVE组合")
			ArchiTotem_Print("使用 /at 查看所有命令，右键点击组合按钮打开管理界面")
		end
		
		-- 再次调用更新显示状态，确保按钮位置正确
		ArchiTotem_UpdateShown()
		
		-- 初始化拖拽手柄位置和可见性
		ArchiTotem_LoadFramePosition()
		ArchiTotem_UpdateDragHandleVisibility()
		
	elseif event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER" then
		ArchiTotemCasted = 0
	elseif event == "CHAT_MSG_SPELL_SELF_BUFF" then
		-- 检测图腾召回技能的使用
		if arg1 then
			-- 检测中文和英文的图腾召回消息
			-- if string.find(arg1, "图腾召回") or string.find(arg1, "Totemic Recall") or 
			--    string.find(arg1, "获得了.*点法力值") or string.find(arg1, "gain.*Mana from Totemic Recall") then
			-- 	-- 触发召回按钮的冷却
			-- 	if ArchiTotem_TotemData["ArchiTotemButton_Recall"] then
			-- 		ArchiTotem_TotemData["ArchiTotemButton_Recall"].cooldownstarted = GetTime()
			-- 		ArchiTotem_TotemData["ArchiTotemButton_Recall"].cooldown = 6
			-- 		ArchiTotem_Print("检测到图腾召回，触发召回按钮冷却")
			-- 	end
			-- end
		end
	elseif event == "SPELL_UPDATE_COOLDOWN" then
		if ArchiTotem_SyncRecallCooldown then ArchiTotem_SyncRecallCooldown() end
	elseif event == "SPELLCAST_STOP" then
		if ArchiTotemCasted == 1 then
			ArchiTotemActiveTotem[ArchiTotemCastedElement] = ArchiTotemCastedTotem
			ArchiTotemActiveTotem[ArchiTotemCastedElement].casted = GetTime()
			ArchiTotem_TotemData[ArchiTotemCastedButton].cooldownstarted = GetTime()

			ArchiTotem_UpdateAllCooldowns(ArchiTotemCastedButton)

			if ArchiTotem_Options["Apperance"].bottomoncast == true then
				local buttonNumber = tonumber(string.sub(ArchiTotemCastedButton, -1, -1))
				if buttonNumber > 1 then
					local topbutton, bottombutton
					for i = buttonNumber, 2, -1 do
						topbutton = string.sub(ArchiTotemCastedButton, 1, -2) .. i
						bottombutton = string.sub(ArchiTotemCastedButton, 1, -2) .. (i - 1)
						ArchiTotem_Switch(topbutton, bottombutton)
						if ArchiTotem_TotemData[topbutton].cooldownstarted == nil then
							local duration = 1.5
							CooldownFrame_SetTimer(_G[topbutton .. "Cooldown"], GetTime(), duration, 1)
						end
					end
					local duration = ArchiTotem_TotemData[bottombutton].cooldown
					if duration == 0 then duration = 1.5 end
					CooldownFrame_SetTimer(_G[bottombutton .. "Cooldown"], GetTime(), duration, 1)
				end
			end
			ArchiTotemCasted = nil
			ArchiTotemCastedTotem = nil
			ArchiTotemCastedButton = nil
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- 进入世界后再次安排轮询检测
		ArchiTotem_ScheduleTalentDetection("PLAYER_ENTERING_WORLD", 20)
	elseif event == "PLAYER_LOGIN" then
		-- 登录完成后安排轮询检测
		ArchiTotem_ScheduleTalentDetection("PLAYER_LOGIN", 20)
	elseif event == "PLAYER_ALIVE" then
		-- 部分客户端该事件更晚，可以再安排一次兜底轮询
		ArchiTotem_ScheduleTalentDetection("PLAYER_ALIVE", 20)
	elseif event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED" then
		-- 天赋变更，刷新图腾掌握加成
		ArchiTotem_UpdateTalents()
	elseif event == "SPELLS_CHANGED" then
		-- 技能书变更通常发生在登录后，可能意味着天赋/法术数据已就绪
		ArchiTotem_ScheduleTalentDetection("SPELLS_CHANGED", 20)
	end
end

-- 获取法术ID
function ArchiTotem_GetSpellId(spell)
	local localizeSpell = L[spell]
	local spellID = 0
	for id = 1, 360 do
		local spellName = GetSpellName(id, BOOKTYPE_SPELL)
		if spellName and string.find(spellName, localizeSpell) then
			spellID = id
		end
	end
	return spellID
end

-- 图腾施放函数
function ArchiTotem_CastTotem()
	ArchiTotemCasted = 1
	ArchiTotemCastedTotem = ArchiTotem_TotemData[this:GetName()]
	ArchiTotemCastedElement = string.sub(this:GetName(), 18, -2)
	ArchiTotemCastedButton = this:GetName()

	if ArchiTotemCastedTotem.casted == nil then 
		ArchiTotemCastedTotem.casted = GetTime() - ArchiTotemCastedTotem.cooldown 
	end
	
	local mincooldown = ArchiTotemCastedTotem.cooldown
	if mincooldown < 1.5 then mincooldown = 1.5 end
	local localizeSpell = L[ArchiTotem_TotemData[this:GetName()].name]
	CastSpellByName(localizeSpell)
end

-- 交换图腾位置
function ArchiTotem_Switch(arg1, arg2)
	local temp = ArchiTotem_TotemData[arg1]
	ArchiTotem_TotemData[arg1] = ArchiTotem_TotemData[arg2]
	ArchiTotem_TotemData[arg2] = temp
	
	_G[arg1 .. "CooldownText"]:Hide()
	_G[arg1 .. "CooldownBg"]:Hide()
	_G[arg2 .. "CooldownText"]:Hide()
	_G[arg2 .. "CooldownBg"]:Hide()
	
	-- 安全地设置冷却时间，检查数据完整性
	if ArchiTotem_TotemData[arg1] and ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg1].name) ~= 0 then
		local _, duration1 = GetSpellCooldown(ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg1].name), BOOKTYPE_SPELL)
		-- 确保 casted 时间存在
		if ArchiTotem_TotemData[arg1].casted == nil then
			ArchiTotem_TotemData[arg1].casted = GetTime() - (ArchiTotem_TotemData[arg1].cooldown or 0)
		end
		-- 确保持续时间有效
		if duration1 and duration1 > 0 then
			CooldownFrame_SetTimer(_G[arg1 .. "Cooldown"], ArchiTotem_TotemData[arg1].casted, duration1, 1)
		end
	end
	
	if ArchiTotem_TotemData[arg2] and ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg2].name) ~= 0 then
		local _, duration2 = GetSpellCooldown(ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg2].name), BOOKTYPE_SPELL)
		-- 确保 casted 时间存在
		if ArchiTotem_TotemData[arg2].casted == nil then
			ArchiTotem_TotemData[arg2].casted = GetTime() - (ArchiTotem_TotemData[arg2].cooldown or 0)
		end
		-- 确保持续时间有效
		if duration2 and duration2 > 0 then
			CooldownFrame_SetTimer(_G[arg2 .. "Cooldown"], ArchiTotem_TotemData[arg2].casted, duration2, 1)
		end
	end
	
	ArchiTotem_UpdateTextures()
	
	-- 实时更新图腾组合管理界面
	ArchiTotem_UpdatePresetManagerDisplay()
end

-- 清除所有冷却时间
function ArchiTotem_ClearAllCooldowns()
	for k, v in ArchiTotem_TotemData do
		v.cooldownstarted = nil
	end
end

-- 更新冷却时间
function ArchiTotem_UpdateCooldown(Buttonname, duration)
	if ArchiTotem_Options["Debug"] then 
		ArchiTotem_Print("+++++" .. Buttonname .. "+++++", "debug") 
	end
	
	local cooldown = _G[Buttonname .. "Cooldown"]
	if cooldown ~= nil then
		local start = GetTime()
		if duration == 0 then duration = 1.5 end
		local enable = 1
		if ArchiTotem_Options["Debug"] then 
			ArchiTotem_Print(start .. "-" .. duration .. "-" .. enable) 
		end
	else
		if ArchiTotem_Options["Debug"] then 
			ArchiTotem_Print("+++++" .. Buttonname .. " NOT FOUND") 
		end
	end
end

-- 更新所有冷却时间
function ArchiTotem_UpdateAllCooldowns(_)
	for k, v in ArchiTotem_TotemData do
		if v.casted == nil then v.casted = GetTime() - v.cooldown end
		local duration = 1.5
		if GetTime() > (v.casted + v.cooldown) then
			if ArchiTotemCastedButton == k then 
				duration = v.cooldown 
			else 
				duration = 1.5 
			end
			ArchiTotem_UpdateCooldown(k, duration)
		end
	end
end

-- 更新循环
function ArchiTotem_OnUpdate(arg1)
	this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + arg1

	if this.TimeSinceLastUpdate > CLOCK_UPDATE_RATE then
		if ArchiTotem_SyncRecallCooldown then ArchiTotem_SyncRecallCooldown() end
		-- 登录后短时轮询：等待天赋 API 就绪，再进行一次权威检测并提示
		if ArchiTotem_TalentsRetryActive and GetTime() >= (ArchiTotem_TalentsRetryNext or 0) then
			ArchiTotem_TalentsRetryNext = GetTime() + (ArchiTotem_TalentsPollInterval or 0.5)
			if ArchiTotem_IsTalentAPIReady() then
				ArchiTotem_TalentsRetryActive = false
				ArchiTotem_TalentsInitPending = false
				ArchiTotem_UpdateTalents()
				if ArchiTotem_PrintTotemicMasteryStatus then
					ArchiTotem_PrintTotemicMasteryStatus()
				end
			elseif GetTime() >= (ArchiTotem_TalentsRetryDeadline or 0) then
				-- 超时后依旧执行一次检测，防止永不提示
				ArchiTotem_TalentsRetryActive = false
				ArchiTotem_TalentsInitPending = false
				ArchiTotem_UpdateTalents()
				if ArchiTotem_PrintTotemicMasteryStatus then
					ArchiTotem_PrintTotemicMasteryStatus()
				end
			end
		end
		-- 友方增益持续时间和火焰新星激活延迟分别应用对应天赋。
		for k, v in ArchiTotemActiveTotem do
			local effectiveDuration = ArchiTotem_GetEffectiveDuration(v)
			local timeLeft = (v.casted or 0) + effectiveDuration - GetTime()

			if timeLeft <= 0 then
				ArchiTotemActiveTotem[k] = nil
				_G[k .. "DurationText"]:Hide()
			else
				local minutes = math.floor(timeLeft / 60)
				local seconds = math.floor(timeLeft - (minutes * 60))
				_G[k .. "DurationText"]:Show()
				local secondsStr = tostring(seconds)
				if seconds < 10 then
					secondsStr = "0" .. secondsStr
				end
				_G[k .. "DurationText"]:SetText(tostring(minutes) .. ":" .. secondsStr)
			end
		end
		
		-- 处理所有图腾的冷却时间
		for k, v in ArchiTotem_TotemData do
			if ArchiTotem_Options["Apperance"].shownumericcooldowns == true then
				if v.cooldownstarted == nil then
					-- 无冷却
					-- 如果是召回按钮，确保按钮文字显示
					if k == "ArchiTotemButton_Recall" then
						local buttonText = _G["RecallButtonText"]
						if buttonText then
							buttonText:Show()
						end
					end
				else
					if GetTime() > (v.cooldownstarted + v.cooldown) then
						_G[k .. "CooldownText"]:Hide()
						_G[k .. "CooldownBg"]:Hide()
						v.cooldownstarted = nil
						-- 如果是召回按钮，冷却结束后重新显示按钮文字
						if k == "ArchiTotemButton_Recall" then
							local buttonText = _G["RecallButtonText"]
							if buttonText then
								buttonText:Show()
							end
						end
					else
						_G[k .. "CooldownBg"]:Show()
						_G[k .. "CooldownText"]:Show()
						local totalSeconds = (v.cooldown + (v.cooldownstarted - GetTime()))
						local minutes = math.floor(totalSeconds / 60)
						local seconds = math.floor(totalSeconds - (minutes * 60))
						if minutes > 0 then
							local secondsStr = tostring(seconds)
							if seconds < 10 then
								secondsStr = "0" .. tostring(seconds)
							end
							_G[k .. "CooldownText"]:SetText(tostring(minutes) .. ":" .. secondsStr)
						else
							_G[k .. "CooldownText"]:SetText(tostring(seconds))
						end
						-- 如果是召回按钮，倒计时显示时隐藏按钮文字
						if k == "ArchiTotemButton_Recall" then
							local buttonText = _G["RecallButtonText"]
							if buttonText then
								buttonText:Hide()
							end
						end
					end
				end
			end
		end
		this.TimeSinceLastUpdate = 0
	end
end

-- 拖拽手柄相关函数
function ArchiTotem_DragHandle_OnLoad()
	-- 设置初始可见性
	ArchiTotem_UpdateDragHandleVisibility()

	-- 调试信息（仅在 Debug 下提示）
	if ArchiTotem_Options and ArchiTotem_Options["Debug"] then
		local dragHandle = getglobal("ArchiTotemDragHandle")
		if dragHandle then
			ArchiTotem_Print("[DEBUG] 拖拽手柄已加载", "debug")
		else
			ArchiTotem_Print("错误：无法找到拖拽手柄对象", "error")
		end
	end
end

function ArchiTotem_DragHandle_OnDragStart()
	-- 拖拽整个 ArchiTotemFrame 而不是手柄本身
	local mainFrame = getglobal("ArchiTotemFrame")
	if mainFrame then
		mainFrame:StartMoving()
	end
end

function ArchiTotem_DragHandle_OnDragStop()
	-- 停止拖拽整个 ArchiTotemFrame
	local mainFrame = getglobal("ArchiTotemFrame")
	if mainFrame then
		mainFrame:StopMovingOrSizing()
		-- 保存位置
		ArchiTotem_SaveFramePosition()
	end
end

function ArchiTotem_DragHandle_OnClick(button)
	if button == "RightButton" then
		-- 右键切换锁定状态
		ArchiTotem_ToggleLock()
	elseif button == "LeftButton" and IsShiftKeyDown() then
		-- Shift+左键重置位置
		ArchiTotem_ResetFramePosition()
	end
end

function ArchiTotem_DragHandle_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText("ArchiTotem 拖拽手柄", 1, 1, 1)
	GameTooltip:AddLine("拖拽移动整个界面", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("Shift+左键: 重置位置", 0.8, 0.8, 0.8)
	if ArchiTotem_Options and ArchiTotem_Options.locked then
		GameTooltip:AddLine("状态: 已锁定", 1, 0.2, 0.2)
	else
		GameTooltip:AddLine("状态: 未锁定", 0.2, 1, 0.2)
	end
	GameTooltip:Show()
end

function ArchiTotem_UpdateDragHandleVisibility()
	local dragHandle = getglobal("ArchiTotemDragHandle")
	if not ArchiTotem_Options then
		if ArchiTotem_Options and ArchiTotem_Options["Debug"] then
			ArchiTotem_Print("警告：ArchiTotem_Options 不存在", "debug")
		end
		return
	end
	
	if not dragHandle then
		ArchiTotem_Print("错误：无法找到拖拽手柄对象", "error")
		return
	end
	
	if ArchiTotem_Options.locked then
		dragHandle:Hide()
	else
		dragHandle:Show()
	end
end

function ArchiTotem_ToggleLock()
	if not ArchiTotem_Options then
		return
	end
	
	ArchiTotem_Options.locked = not ArchiTotem_Options.locked
	ArchiTotem_UpdateDragHandleVisibility()
	
	if ArchiTotem_Options.locked then
		ArchiTotem_Print("图腾界面已锁定，拖拽手柄已隐藏")
	else
		ArchiTotem_Print("图腾界面已解锁，拖拽手柄已显示")
	end
end

function ArchiTotem_SaveFramePosition()
	local mainFrame = getglobal("ArchiTotemFrame")
	if not ArchiTotem_Options or not mainFrame then
		return
	end
	
	local point, _, relativePoint, xOfs, yOfs = mainFrame:GetPoint()
	ArchiTotem_Options.framePosition = {
		point = point,
		relativePoint = relativePoint,
		xOffset = xOfs,
		yOffset = yOfs
	}
end

function ArchiTotem_LoadFramePosition()
	local mainFrame = getglobal("ArchiTotemFrame")
	if not ArchiTotem_Options or not ArchiTotem_Options.framePosition or not mainFrame then
		return
	end
	
	local pos = ArchiTotem_Options.framePosition
	mainFrame:ClearAllPoints()
	mainFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOffset, pos.yOffset)
end

function ArchiTotem_ResetFramePosition()
	local mainFrame = getglobal("ArchiTotemFrame")
	if not mainFrame then
		return
	end
	
	mainFrame:ClearAllPoints()
	mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	ArchiTotem_SaveFramePosition()
	ArchiTotem_Print("图腾界面位置已重置到屏幕中央")
end

function ArchiTotem_TestDragHandle()
	local dragHandle = getglobal("ArchiTotemDragHandle")
	ArchiTotem_Print("=== 拖拽手柄调试信息 ===")
	
	if dragHandle then
		ArchiTotem_Print("拖拽手柄对象存在")
		ArchiTotem_Print("当前可见状态: " .. tostring(dragHandle:IsVisible()))
		ArchiTotem_Print("当前显示状态: " .. tostring(dragHandle:IsShown()))
		
		-- 强制显示
		dragHandle:Show()
		ArchiTotem_Print("已强制显示拖拽手柄")
		
		-- 检查位置
		local point, _, relativePoint, x, y = dragHandle:GetPoint()
		if point then
			ArchiTotem_Print("位置: " .. point .. " -> " .. relativePoint .. " (" .. x .. ", " .. y .. ")")
		else
			ArchiTotem_Print("无法获取位置信息")
		end
	else
		ArchiTotem_Print("错误：拖拽手柄对象不存在", "error")
	end
	
	if ArchiTotem_Options then
		ArchiTotem_Print("锁定状态: " .. tostring(ArchiTotem_Options.locked))
	else
		ArchiTotem_Print("ArchiTotem_Options 不存在")
	end
	
	ArchiTotem_Print("=== 调试信息结束 ===")
end
