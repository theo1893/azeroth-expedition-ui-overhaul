--Regester new addon object
Mendeleev = AceAddonClass:new({
	name			= MendeleevLocals.Title,
	version			= MendeleevLocals.Version,
	author			= MendeleevLocals.Author,
	authorEmail		= MendeleevLocals.Email ,
	aceCompatible	= "100",
	category		= ACE_CATEGORY_INTERFACE,
})

------------
-- HOOKS ---
------------
local linkFuncs = {
	SetAuctionItem		= GetAuctionItemLink,
	SetBagItem			= GetContainerItemLink,
	SetCraftItem		= function(skill, id) return (id) and GetCraftReagentItemLink(skill, id) or GetCraftItemLink(skill) end,
	SetHyperlink		= function(link) return link end,
	SetInventoryItem	= function(type, slot) return (type) and GetInventoryItemLink(type, slot) or GetContainerItemLink(BANK_CONTAINER,this:GetID()) end,
	SetLootItem			= GetLootSlotLink,
	SetMerchantItem		= GetMerchantItemLink,
	SetQuestItem		= GetQuestItemLink,
	SetQuestLogItem		= GetQuestLogItemLink,
	SetTradePlayerItem	= GetTradePlayerItemLink,
	SetTradeSkillItem	= function(skill, id) return (id) and GetTradeSkillReagentItemLink(skill, id) or GetTradeSkillItemLink(skill) end,
	SetTradeTargetItem	= GetTradeTargetItemLink,
	SetInboxItem		= function(index) return GetItemID(GetInboxItem(index)) end,
	SetLootRollItem		= function(index) return GetLootRollItemLink(index) end,
}

function Mendeleev:SetItemRef(link, text, button)
	self:CallHook("SetItemRef", link, text, button)
	if (not strfind(link, "item") or IsControlKeyDown() or IsShiftKeyDown()) then return; end
	self:ParseTooltip(ItemRefTooltip, link)
end

function Mendeleev:HookTooltips()
	for key, value in linkFuncs do
		local orig, linkFunc = key,value -- I cant leave this out, dont ask me why.
		local func = function(tooltip,a,b,c)
			local r1,r2,r3 = self.Hooks[tooltip][orig].orig(tooltip,a,b,c)
			self:ParseTooltip(tooltip,linkFunc(a,b,c))
			return r1,r2,r3
		end
		self:Hook(GameTooltip,orig,func)
	end
	self:Hook("SetItemRef")
end

--Ace methods
function Mendeleev:Enable()
	self:HookTooltips()
	self.link = ""
	self.TT = {}
	self.linkcache = {}
	setmetatable(self.linkcache, {__mode = "k"})

	self.PT = PeriodicTableEmbed:GetInstance("1")
	self.PTTrade = PTTradeskillsEmbed:GetInstance("1")
end

function Mendeleev:Disable()
	self:UnhookAll()
end

--Mendeleev methods
function Mendeleev:DrawTooltip(frame)
	for _,z in ipairs(self.TT) do
		frame:AddDoubleLine(z.Stringa,z.Stringb,1,1,1,1,1,1)
	end
	frame:Show()
end

function Mendeleev:AddLine(Stringa,Stringb)
	local i = table.getn(self.TT) + 1
	local t = {}
	t.Stringa = Stringa
	t.Stringb = Stringb
	table.insert(self.TT, t)
end

function Mendeleev:ParseTooltip(frame,link,id)
	if(link == nil) then
		return
	end

	local _, _, tid = string.find(link, "item:(%d+):%d+:%d+:%d+")
	local id = tonumber(tid)

	if(link == self.link) then
		self:DrawTooltip(frame)
		return
	elseif(tid == nil) then
		return
	else
		self.link = link
		self.TT = {}
	end

	Mendeleev:DoTooltip(frame,link,id)

	self:DrawTooltip(frame)
end

function Mendeleev:DoTooltip(frame,link,id)
	--Add the fixed Category information, Can be found in MendeleevGlobals.ua
	for _,v in ipairs(MendeleevLocals.infosets) do
		local z = self.PT:ItemInSets(link, v.setindex)
		local filter = v.filter and not self.PT:ItemInSet(link, v.filter)
		if z and not filter then
			local tline, header
			local colour = v.colour or "|cffffffff"
			for t,tt in pairs(z) do
				if v.sets[tt] then
					local val = self.PT:ItemInSet(link, tt)
					local valstr = val and v.useval and v.useval(val, link) or ""
					tline = (not tline and "") or tline..", "
					tline = tline.. v.sets[tt].. valstr
				end

				if( t <= 2) then
					header = v.header
				else
					header = " "
				end
				header = colour..header.."|r"
				
				if (math.mod(t,2) == 0 and tline ~= nil) then
					self:AddLine(header,colour..tline.."|r")
					tline = nil
				end
			end
			if (tline and string.len(tline) > 0) then
				self:AddLine(header,colour..tline.."|r")
			end
			header = nil
		end
	end
	
	--物品副职业用途
	self.rid2data = {}
	self.inTree = {}
	local t = self:GetUsedInTree(id)
	local l = self:GetUsedInList(t[2], 1)
	local header = MendeleevLocals.Category.TradeRep
	local ln = table.getn(l)
	if ln > 15 then ln = 14 end
	for i = 1, ln do
		if header then
			self:AddLine(header)
			header = nil
		end
		self:AddLine(l[i])
	end
	if table.getn(l) > 15 then
		self:AddLine("     ...")
	end
	self.rid2data = nil
	self.inTree = nil
end

local function SortUsedInTree(a,b)
	if (not a or not b) then
		return true
	end
	if (a[3] > b[3]) then
		return true
	end
	if (a[3] < b[3]) then
		return false
	end
	if (a[1] < b[1]) then
		return true
	else
		return false
	end
end

function Mendeleev:GetUsedInTree(id, selfskill)
	local rt = {}
	local z = self.PTTrade:GetRecepieUse(id)
	local skill = selfskill or 0
	if z then
		for x,y in z do
			if not self.rid2data[x] then
				self.rid2data[x] = y
			end
			if y[2] > skill then
				skill = y[2]
			end
			if not self.inTree[x] then
				self.inTree[x] = true
				local data = self:GetUsedInTree(x, y[2])
				table.insert(rt, data)
				self.inTree[x] = nil
				if data[3] > skill then
					skill = data[3]
				end
			else
				table.insert(rt, {x, "...", y[2]})
			end
		end
	end
	table.sort(rt, SortUsedInTree)
	return {id, rt, skill}
end

function Mendeleev:GetUsedInList(tree, level)
	local colour = {
		[0] = "|cffbbbbbb",
		[1] = "|cff00cc00",
		[2] = "|cffffff00",
		[3] = "|cffFF6600",
		[4] = "|cffff0000",
	}

	local list = {}
	for _, v in tree do
		if level < 2 or v[3] > 0 then
			table.insert(list, string.rep("     ", level).."- "..colour[self.rid2data[v[1]][2]]..self.rid2data[v[1]][1].."|r")
			if type(v[2]) == "table" then
				local slist = self:GetUsedInList(v[2], level+1)
				if table.getn(slist) > 0 then
					if v[3] > 0 then
						for _, line in slist do
							table.insert(list, line)
						end
					else
						table.insert(list, string.rep("    ", level+1).."- "..colour[0].."...|r")
					end
				end
			elseif v[2] == "..." then
				table.insert(list, string.rep("    ", level+1).."  ...")
			end
		end
	end
	return list
end

--Register in ace
Mendeleev:RegisterForLoad()
