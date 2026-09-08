-- No superwow, no superapi
if not SetAutoloot then
	return
end

SuperAPI.AUTOLOOT_OPTIONS = {
	"始终打开",
	"始终关闭",
	"Shift打开",
	"Shift关闭",
}

SuperAPI.SELECTION_CIRCLE_STYLE = {
	"默认—不完整的圆",
	"完整圆（必须下载纹理）",
	"带有朝向箭头的完整圆（必须下载纹理）",
	"按朝向定向的经典不完整圆",
}

SuperAPI:RegisterDefaults("profile", {
	autoloot = SuperAPI.AUTOLOOT_OPTIONS[3],
	clickthrough = false,
})

SuperAPI.IfShiftAutoloot = function()
	if IsShiftKeyDown() then
		SetAutoloot(1)
	else
		SetAutoloot(0)
	end
end

SuperAPI.IfShiftNoAutoloot = function()
	if IsShiftKeyDown() then
		SetAutoloot(0)
	else
		SetAutoloot(1)
	end
end

SuperAPI.cmdtable = {
	type = "group",
	handler = SuperAPI,
	args = {
		autoloot = {
			type = "text",
			name = "自动拾取（阅读提示信息）",
			desc = "设置自动拾取行为。如果使用【Vanilla Tweaks】的快速拾取功能，所有这些设置将会反转（“始终开启”实际作用会变成“始终关闭”，“按下Shift键切换开启”会变成“按下Shift键切换关闭”等等）。 ",
			order = 10,
			validate = SuperAPI.AUTOLOOT_OPTIONS,
			get = function()
				return SuperAPI.db.profile.autoloot
			end,
			set = function(v)
				SuperAPI.db.profile.autoloot = v
				if v == SuperAPI.AUTOLOOT_OPTIONS[1] then
					-- "Always on"
					SetAutoloot(1)
					SuperAPI.frame:SetScript("OnUpdate", nil)
				elseif v == SuperAPI.AUTOLOOT_OPTIONS[2] then
					-- "Always off"
					SetAutoloot(0)
					SuperAPI.frame:SetScript("OnUpdate", nil)
				elseif v == SuperAPI.AUTOLOOT_OPTIONS[3] then
					-- "Shift to toggle on"
					SetAutoloot(0)
					SuperAPI.frame:SetScript("OnUpdate", SuperAPI.IfShiftAutoloot)
				elseif v == SuperAPI.AUTOLOOT_OPTIONS[4] then
					-- "Shift to toggle off"
					SetAutoloot(1)
					SuperAPI.frame:SetScript("OnUpdate", SuperAPI.IfShiftNoAutoloot)
				end
			end,
		},
		clickthrough = {
			type = "toggle",
			name = "穿透拾取",
			desc = "允许穿透点击，以拾取位于目标下方的物品。",
			order = 20,
			get = function()
				return Clickthrough() == 1
			end,
			set = function(v)
				if v == true then
					Clickthrough(1)
				else
					Clickthrough(0)
				end
				SuperAPI.db.profile.clickthrough = v
			end,
		},
		fov = {
			type = "range",
			name = "视野范围（需要重新加载）",
			desc = "更改游戏的视野范围。需要重新加载（游戏）才能生效。",
			order = 30,
			min = 0.1,
			max = 3.14,
			step = 0.05,
			get = function()
				return GetCVar("FoV")
			end,
			set = function(v)
				SetCVar("FoV", v)
			end,
		},
		selectioncircle = {
			type = "text",
			name = "选择圈样式",
			desc = "更改选中圈的样式。",
			order = 40,
			validate = SuperAPI.SELECTION_CIRCLE_STYLE,
			get = function()
				local selectioncircle = GetCVar("SelectionCircleStyle")
				if selectioncircle then
					return SuperAPI.SELECTION_CIRCLE_STYLE[tonumber(selectioncircle)]
				end
			end,
			set = function(v)
				if v == SuperAPI.SELECTION_CIRCLE_STYLE[1] then
					SetCVar("SelectionCircleStyle", "1")
				elseif v == SuperAPI.SELECTION_CIRCLE_STYLE[2] then
					SetCVar("SelectionCircleStyle", "2")
				elseif v == SuperAPI.SELECTION_CIRCLE_STYLE[3] then
					SetCVar("SelectionCircleStyle", "3")
				elseif v == SuperAPI.SELECTION_CIRCLE_STYLE[4] then
					SetCVar("SelectionCircleStyle", "4")
				end
			end,
		},
		backgroundsound = {
			type = "toggle",
			name = "后台音乐",
			desc = "允许游戏窗口处于后台时仍能播放游戏声音。",
			order = 60,
			get = function()
				return GetCVar("BackgroundSound") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("BackgroundSound", "1")
				else
					SetCVar("BackgroundSound", "0")
				end
			end,
		},
		uncappedsounds = {
			type = "toggle",
			name = "声音上限",
			desc = "通过移除硬编码限制，允许更多游戏声音同时播放。这也会将“软件声音通道”和“最大硬件声音通道”设置为64。如果遇到游戏崩溃的情况，则可能需要将此项关闭。",
			order = 70,
			get = function()
				return GetCVar("UncapSounds") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("UncapSounds", "1")
					SetCVar("SoundSoftwareChannels", "64")
					SetCVar("SoundMaxHardwareChannels", "64")
				else
					SetCVar("UncapSounds", "0")
					SetCVar("SoundSoftwareChannels", "12")
					SetCVar("SoundMaxHardwareChannels", "12")
				end
			end,
		},
		guidcombatlog = {
			type = "toggle",
			name = "唯一标识的战斗日志",
			desc = "将战斗日志更改为显示全局唯一标识符（GUID）而非名称，这会导致许多基于姓名记录的基础版插件无法正常使用，但能够区分同名怪物。",
			order = 80,
			get = function()
				return GetCVar("LootSparkle") == "1"
			end,
			set = function(v)
				if v == true then
					SetCVar("LootSparkle", "1")
				else
					SetCVar("LootSparkle", "0")
				end
			end,
		},
	}
}

local deuce = SuperAPI:NewModule("SuperAPI Options Menu")
deuce.hasFuBar = IsAddOnLoaded("FuBar") and FuBar
deuce.consoleCmd = not deuce.hasFuBar

SuperAPIOptions = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "FuBarPlugin-2.0")
SuperAPIOptions.name = "FuBar - SuperAPI"
SuperAPIOptions:RegisterDB("SuperAPIDB")
SuperAPIOptions.hasIcon = "Interface\\Icons\\inv_misc_book_06"
SuperAPIOptions.defaultMinimapPosition = 180
SuperAPIOptions.independentProfile = true
SuperAPIOptions.hideWithoutStandby = false

SuperAPIOptions.OnMenuRequest = SuperAPI.cmdtable
local args = AceLibrary("FuBarPlugin-2.0"):GetAceOptionsDataTable(SuperAPIOptions)
for k, v in pairs(args) do
	if SuperAPIOptions.OnMenuRequest.args[k] == nil then
		SuperAPIOptions.OnMenuRequest.args[k] = v
	end
end

function SuperAPIOptions:OnEnable()
	-- activate saved settings
	SuperAPI.cmdtable.args.autoloot.set(SuperAPI.db.profile.autoloot)
	SuperAPI.cmdtable.args.clickthrough.set(SuperAPI.db.profile.clickthrough)
end
