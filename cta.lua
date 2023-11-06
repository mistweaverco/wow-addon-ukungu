Ukungu = Ukungu or {}
Ukungu.Core = Ukungu.Core or {}
Ukungu.Core.AddonPanel = Ukungu.Core.AddonPanel or CreateFrame("Frame")
Ukungu.Core.runOnceOnAddonLoaded = Ukungu.Core.runOnceOnAddonLoaded or {}
Ukungu.Core.ticker30 = Ukungu.Core.ticker30 or {}
Ukungu.CTA = Ukungu.CTA or {}
Ukungu.CTA.Player = Ukungu.CTA.Player or {}
Ukungu.CTA.Active = Ukungu.CTA.Active or {}
Ukungu.CTA.Frames = Ukungu.CTA.Frames or {}
Ukungu.CTA.Textures = Ukungu.CTA.Textures or {}
-- Random Dungeon (Dragonflight) & Random Heroic (Dragonflight),
-- because they are the only ones that give bonus rewards
-- See Ukungu.CTA.printRandomDungeons() for full list
Ukungu.CTA.dungeonIDs = { 2350, 2351 }
Ukungu.CTA.DungeonNameCache = {}
Ukungu.CTA.Active.Tank = false
Ukungu.CTA.Active.Healer = false
Ukungu.CTA.Active.DPS = false

function Ukungu.CTA.Player.isInInstance()
	local isInInstance, _ = IsInInstance()
	return isInInstance
end

function Ukungu.CTA.getPlayerRole()
	local spec = GetSpecialization()
	local role = string.lower(GetSpecializationRole(spec))
	return role
end

function Ukungu.CTA.isQueued()
	local queued = GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
	return queued
end

function Ukungu.CTA.printRandomDungeons()
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		print(id .. ": " .. name)
	end
end

function Ukungu.CTA.getDungeonNameByDungeonID(dungeonID)
    if Ukungu.CTA.DungeonNameCache[dungeonID] then
        return Ukungu.CTA.DungeonNameCache[dungeonID]
    end
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
        if (id == dungeonID) then
            Ukungu.CTA.DungeonNameCache[dungeonID] = name
            return name
        end
	end
    return nil
end


function Ukungu.CTA.showShortageMessage(msg)
	print(WrapTextInColorCode("[Ukungu] " .. msg, "ffff0000"))
end

local function tick30()
	if UkunguPCDB.CTA.isDisabled or Ukungu.CTA.Player.isInInstance() or Ukungu.CTA.isQueued() then
		return
	end

	Ukungu.CTA.Active.Tank = false
	Ukungu.CTA.Active.Healer = false
	Ukungu.CTA.Active.DPS = false

	-- for each dungeon DungeonID
	for dungeonIDIndex = 1, #Ukungu.CTA.dungeonIDs do
		local dungeonID = Ukungu.CTA.dungeonIDs[dungeonIDIndex]
		for shortageType = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local _, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(dungeonID, shortageType)
			if itemCount and itemCount > 0 then
                local dungeonName = Ukungu.CTA.getDungeonNameByDungeonID(dungeonID)
				local playerRole = Ukungu.CTA.getPlayerRole()
				if forTank then
					Ukungu.CTA.Active.Tank = true
					if (UkunguPCDB.CTA.filterByRole and playerRole == "tank") or not UkunguPCDB.CTA.filterByRole then
						Ukungu.CTA.showShortageMessage("Tank shortage in " .. dungeonName .. "!")
					end
				end

				if forHealer then
					Ukungu.CTA.Active.Healer = true
					if (UkunguPCDB.CTA.filterByRole and playerRole == "healer") or not UkunguPCDB.CTA.filterByRole then
						Ukungu.CTA.showShortageMessage("Healer shortage in " .. dungeonName .. "!")
					end
				end

				if forDamage then
					Ukungu.CTA.Active.DPS = true
					if (UkunguPCDB.CTA.filterByRole and playerRole == "damager") or not UkunguPCDB.CTA.filterByRole then
						Ukungu.CTA.showShortageMessage("DPS shortage in " .. dungeonName .. "!")
					end
				end
			end
		end
	end
end

local function setupAddonPanel()
	local categoryCallToArms = CreateFrame("Frame", nil, Ukungu.Core.AddonPanel)
	categoryCallToArms.name = "Call to Arms"
	categoryCallToArms.parent = Ukungu.Core.AddonPanel.name
	categoryCallToArms.default = function() end
	categoryCallToArms.refresh = function() end

	InterfaceOptions_AddCategory(categoryCallToArms)

	local addonPanelFilterByRoleCheckbox = CreateFrame("CheckButton", nil, categoryCallToArms, "InterfaceOptionsCheckButtonTemplate")
	addonPanelFilterByRoleCheckbox:SetPoint("TOPLEFT", 20, -20)
	addonPanelFilterByRoleCheckbox.Text:SetText("Filter by role?")
	addonPanelFilterByRoleCheckbox:HookScript("OnClick", function(_, btn, down)
		UkunguPCDB.CTA.filterByRole = addonPanelFilterByRoleCheckbox:GetChecked()
	end)
	addonPanelFilterByRoleCheckbox:SetChecked(UkunguPCDB.CTA.filterByRole)

	local addonPanelInactiveCheckbox = CreateFrame("CheckButton", nil, categoryCallToArms, "InterfaceOptionsCheckButtonTemplate")
	addonPanelInactiveCheckbox:SetPoint("TOPLEFT", 20, -40)
	addonPanelInactiveCheckbox.Text:SetText("Disabled")
	addonPanelInactiveCheckbox:HookScript("OnClick", function(_, btn, down)
		UkunguPCDB.CTA.isDisabled = addonPanelInactiveCheckbox:GetChecked()
	end)
	addonPanelInactiveCheckbox:SetChecked(UkunguPCDB.CTA.isDisabled)

end

local function setupDB()
	UkunguPCDB.CTA = UkunguPCDB.CTA or {}
	if UkunguPCDB.CTA.isDisabled == nil then
		UkunguPCDB.CTA.isDisabled = false
	end
	if UkunguPCDB.CTA.filterByRole == nil then
		UkunguPCDB.CTA.filterByRole = true
	end
end

local function setup()
	-- Create DB if it doesn't exist
	setupDB()
	-- Create AddonPanel
	setupAddonPanel()
end

table.insert(Ukungu.Core.runOnceOnAddonLoaded, setup)
table.insert(Ukungu.Core.ticker30, tick30)
