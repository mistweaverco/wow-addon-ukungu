Ukungu = Ukungu or {}
Ukungu.Core = Ukungu.Core or {}
Ukungu.Core.AddonPanel = Ukungu.Core.AddonPanel or CreateFrame("Frame")
Ukungu.Core.ticker = Ukungu.Core.ticker or {}

Ukungu.Chat = Ukungu.Chat or {}
Ukungu.Chat.Player = Ukungu.Chat.Player or {}
Ukungu.Chat.prefix = Ukungu.Chat.prefix or "[Ukungu] "
Ukungu.Chat.Player.Status = Ukungu.Chat.Player.Status or {
	isLOM = false,
	isOOM = false,
	hasAggro = false,
	isDead = false,
	isNearDeath = false,
}

function Ukungu.Chat.Player.isHealer()
	local spec = GetSpecialization()
	local role = GetSpecializationRole(spec)
	if role == "HEALER" then
		return true
	else
		return false
	end
end

function Ukungu.Chat.Player.isNearDeath()
	local health = UnitHealth("player")
	local maxHealth = UnitHealthMax("player")
	if health < 0.25 * maxHealth then
		return true
	else
		return false
	end
end

function Ukungu.Chat.Player.isLOM()
	local mana = UnitPower("player", 0)
	local maxMana = UnitPowerMax("player", 0)
	if mana < 0.3 * maxMana then
		return true
	else
		return false
	end
end

function Ukungu.Chat.Player.isOOM()
	local mana = UnitPower("player", 0)
	local maxMana = UnitPowerMax("player", 0)
	if mana < 0.1 * maxMana then
		return true
	else
		return false
	end
end

function Ukungu.Chat.Player.hasAggro()
	local status = UnitThreatSituation("player")
	if status == 3 then
		return true
	else
		return false
	end
end

function Ukungu.Chat.Player.isDead()
	if UnitIsDead("player") then
		return true
	else
		return false
	end
end

function Ukungu.Chat.Player.isInInstance()
	local inInstance, _ = IsInInstance()
	if inInstance then
		return true
	else
		return false
	end
end

function Ukungu.Chat.isInRaid()
	local isInRaid = IsInRaid()
	return isInRaid
end

function Ukungu.Chat.isInInstance()
	local isInGroup = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
	return isInGroup
end

function Ukungu.Chat.isInParty()
	local isInGroup = IsInGroup(LE_PARTY_CATEGORY_HOME)
	return isInGroup
end

function Ukungu.Chat.send(msg)
	if msg == nil then
		return
	end
	if Ukungu.Chat.isInRaid() then
		SendChatMessage(Ukungu.Chat.prefix .. msg, "RAID")
	elseif Ukungu.Chat.isInInstance() then
		SendChatMessage(Ukungu.Chat.prefix .. msg, "INSTANCE_CHAT")
	elseif Ukungu.Chat.isInParty() then
		SendChatMessage(Ukungu.Chat.prefix .. msg, "PARTY")
	end
end

local function setupAddonPanel()
	local category = CreateFrame("Frame", nil, Ukungu.Core.AddonPanel)
	category.name = "Chat warnings"
	category.parent = Ukungu.Core.AddonPanel.name
	category.default = function() end
	category.refresh = function() end

	InterfaceOptions_AddCategory(category)

	local isDisabledCheckbox = CreateFrame("CheckButton", nil, category, "InterfaceOptionsCheckButtonTemplate")
	isDisabledCheckbox:SetPoint("TOPLEFT", 20, -20)
	isDisabledCheckbox.Text:SetText("Disabled")
	isDisabledCheckbox:HookScript("OnClick", function(_, btn, down)
		UkunguPCDB.Chat.isDisabled = isDisabledCheckbox:GetChecked()
	end)
	isDisabledCheckbox:SetChecked(UkunguPCDB.Chat.isDisabled)
end

local function tick()
	-- If disabled, not in instance or no healer, do nothing
	if UkunguPCDB.Chat.isDisabled or Ukungu.Chat.Player.isInInstance() == false or Ukungu.Chat.Player.isHealer() == false then
		return
	end

	-- Low Mana Status
	if Ukungu.Chat.Player.isLOM() and Ukungu.Chat.Player.Status.isLOM == false then
		Ukungu.Chat.Player.Status.isLOM = true
		Ukungu.Chat.send("Healer is low on mana.")
	end
	-- Reset Low Mana Status
	if Ukungu.Chat.Player.isLOM() == false and Ukungu.Chat.Player.Status.isLOM == true then
		Ukungu.Chat.Player.Status.isLOM = false
	end

	-- Out of Mana
	if Ukungu.Chat.Player.isOOM() and Ukungu.Chat.Player.Status.isOOM == false then
		Ukungu.Chat.Player.Status.isOOM = true
		Ukungu.Chat.send("Healer is out of mana.")
	end
	-- Reset Out of Mana Status
	if Ukungu.Chat.Player.isOOM() == false and Ukungu.Chat.Player.Status.isOOM == true then
		Ukungu.Chat.Player.Status.isOOM = false
	end

	-- Near Death Status
	if Ukungu.Chat.Player.isNearDeath() and Ukungu.Chat.Player.Status.isNearDeath == false then
		Ukungu.Chat.Player.Status.isNearDeath = true
		Ukungu.Chat.send("Healer is near death.")
	end
	-- Reset Near Death Status
	if Ukungu.Chat.Player.isNearDeath() == false and Ukungu.Chat.Player.Status.isNearDeath == true then
		Ukungu.Chat.Player.Status.isNearDeath = false
	end

	-- Dead Status
	if Ukungu.Chat.Player.isDead() and Ukungu.Chat.Player.Status.isDead == false then
		Ukungu.Chat.Player.Status.isDead = true
		Ukungu.Chat.send("Healer is dead.")
	end
	-- Reset Dead Status
	if Ukungu.Chat.Player.isDead() == false and Ukungu.Chat.Player.Status.isDead == true then
		Ukungu.Chat.Player.Status.isDead = false
	end

	-- Aggro Status
	if Ukungu.Chat.Player.hasAggro() and Ukungu.Chat.Player.Status.hasAggro == false then
		Ukungu.Chat.Player.Status.hasAggro = true
		Ukungu.Chat.send("Healer has aggro.")
	end
	-- Reset Aggro Status
	if Ukungu.Chat.Player.hasAggro() == false and Ukungu.Chat.Player.Status.hasAggro == true then
		Ukungu.Chat.Player.Status.hasAggro = false
	end
end

local function setupDB()
	UkunguPCDB.Chat = UkunguPCDB.Chat or {}
	if UkunguPCDB.Chat.isDisabled == nil then
		UkunguPCDB.Chat.isDisabled = false
	end
end

local function setup()
	-- Create DB if it doesn't exist
	setupDB()
	-- Create AddonPanel
	setupAddonPanel()
end

table.insert(Ukungu.Core.runOnceOnAddonLoaded, setup)
table.insert(Ukungu.Core.ticker, tick)