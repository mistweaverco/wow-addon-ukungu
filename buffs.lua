Ukungu = Ukungu or {}
Ukungu.Core = Ukungu.Core or {}
Ukungu.Core.runOnceOnAddonLoaded = Ukungu.Core.runOnceOnAddonLoaded or {}

Ukungu.Buffs = Ukungu.Buffs or {}
Ukungu.Buffs.Player = Ukungu.Buffs.Player or {}
Ukungu.Buffs.Textures = Ukungu.Buffs.Textures or {}
Ukungu.Buffs.Frames = Ukungu.Buffs.Frames or {}

table.insert(Ukungu.Buffs.Player, {
	name = "Mana Tea",
	description = "Show icon when you have 15 stacks of Mana Tea",
	spell_ids = { 115867 },
	aura_instance_id = nil,
	internal_id = "mana_tea",
	active = false,
	icon = "monk_ability_cherrymanatea",
})

function Ukungu.Buffs.HideBuff(buff)
	Ukungu.Buffs.Frames[buff.internal_id]:Hide()
end

function Ukungu.Buffs.ShowBuff(buff)
	Ukungu.Buffs.Frames[buff.internal_id]:Show()
end

local function setupFrame(buff)
	UkunguPCDB.Buffs.Frame[buff.internal_id] = UkunguPCDB.Buffs.Frame[buff.internal_id] or {}
	local top = UkunguPCDB.Buffs.Frame[buff.internal_id].y or 0
	local left = UkunguPCDB.Buffs.Frame[buff.internal_id].x or 0
	local frameAlignment = "CENTER"

	Ukungu.Buffs.Frames[buff.internal_id] = CreateFrame("frame")
	Ukungu.Buffs.Frames[buff.internal_id]:SetWidth(64)
	Ukungu.Buffs.Frames[buff.internal_id]:SetHeight(64)
	if UkunguPCDB.Buffs.Frame[buff.internal_id].customLocation then
		frameAlignment = "BOTTOMLEFT"
	end
	Ukungu.Buffs.Frames[buff.internal_id]:SetPoint(frameAlignment, left, top)
	Ukungu.Buffs.Frames[buff.internal_id]:SetMovable(true)
	Ukungu.Buffs.Frames[buff.internal_id]:RegisterForDrag("LeftButton")
	Ukungu.Buffs.Frames[buff.internal_id]:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving()
			self.isMoving = true
			UkunguPCDB.Buffs.Frame[buff.internal_id].customLocation = true
		end
	end)
	Ukungu.Buffs.Frames[buff.internal_id]:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing()
			self.isMoving = false
			UkunguPCDB.Buffs.Frame[buff.internal_id].x = self:GetLeft()
			UkunguPCDB.Buffs.Frame[buff.internal_id].y = self:GetTop() - self:GetHeight()
		end
	end)

	Ukungu.Buffs.Textures[buff.internal_id] = Ukungu.Buffs.Frames[buff.internal_id]:CreateTexture(nil, "BACKGROUND")
	Ukungu.Buffs.Textures[buff.internal_id]:SetAllPoints(Ukungu.Buffs.Frames[buff.internal_id])
	Ukungu.Buffs.Textures[buff.internal_id]:SetTexture("Interface\\Icons\\" .. buff.icon)
	Ukungu.Buffs.Frames[buff.internal_id]:Show()
end

local function setupAddonPanel()
	local category = CreateFrame("Frame", nil, Ukungu.Core.AddonPanel)
	category.name = "Buff-Tracking"
	category.parent = Ukungu.Core.AddonPanel.name
	category.default = function() end
	category.refresh = function() end

	InterfaceOptions_AddCategory(category)

	local startTop = -20
	for i, buff in pairs(Ukungu.Buffs.Player) do
		startTop = startTop * i
		local checkbox = CreateFrame("CheckButton", nil, category, "InterfaceOptionsCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", 20, startTop)
		checkbox.Text:SetText(buff.name .. " (" .. buff.description .. ")")
		checkbox:HookScript("OnClick", function(_, btn, down)
			UkunguPCDB.Buffs.Tracking[buff.internal_id].active = checkbox:GetChecked()
		end)
		checkbox:SetChecked(UkunguPCDB.Buffs.Tracking[buff.internal_id].active)
	end
end

local function setupDB()
	UkunguPCDB.Buffs = UkunguPCDB.Buffs or {}
	UkunguPCDB.Buffs.Tracking = UkunguPCDB.Buffs.Tracking or {}
	UkunguPCDB.Buffs.Frame = UkunguPCDB.Buffs.Frame or {}
	for i, buff in pairs(Ukungu.Buffs.Player) do
		UkunguPCDB.Buffs.Tracking[buff.internal_id] = UkunguPCDB.Buffs.Tracking[buff.internal_id] or {
			active = false
		}
	end
end

local function setup()
	setupDB()
	-- Create icons for each player buff
	for i, buff in pairs(Ukungu.Buffs.Player) do
		setupFrame(buff)
	end
	-- Create AddonPanel
	setupAddonPanel()
end

table.insert(Ukungu.Core.runOnceOnAddonLoaded, setup)

local function tick()
	for i, buff in pairs(Ukungu.Buffs.Player) do
		if not UkunguPCDB.Buffs.Tracking[buff.internal_id].active then
			Ukungu.Buffs.HideBuff(buff)
			return
		end
		for j, spell_id in pairs(buff.spell_ids) do
			local aura = C_UnitAuras.GetPlayerAuraBySpellID(spell_id)
			if aura then
				-- Show buff icon if we have 15 stacks of Mana Tea
				if buff.internal_id == "mana_tea" then
					if aura.applications >= 15 then
						buff.active = true
						Ukungu.Buffs.ShowBuff(buff)
						return
					else
						buff.active = true
						Ukungu.Buffs.HideBuff(buff)
						return
					end
				end
			else
				buff.active = false
				Ukungu.Buffs.HideBuff(buff)
			end
		end
	end
end

table.insert(Ukungu.Core.ticker, tick)