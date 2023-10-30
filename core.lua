local Ukungu = {}
Ukungu.Main = {}
Ukungu.Player = {}
Ukungu.Chat = {}

Ukungu.Chat.prefix = "[Ukungu] "

Ukungu.Player.Status = {
	isLOM = false,
	isOOM = false,
	hasAggro = false,
	isDead = false,
	isNearDeath = false
}

function Ukungu.Player.isHealer()
	local spec = GetSpecialization()
	local role = GetSpecializationRole(spec)
	if role == "HEALER" then
		return true
	else
		return false
	end
end

function Ukungu.Player.isNearDeath()
	local health = UnitHealth("player")
	local maxHealth = UnitHealthMax("player")
	if health < 0.22 * maxHealth then
		return true
	else
		return false
	end
end

function Ukungu.Player.isLOM()
	local mana = UnitPower("player", 0)
	local maxMana = UnitPowerMax("player", 0)
	if mana < 0.3 * maxMana then
		return true
	else
		return false
	end
end

function Ukungu.Player.isOOM()
	local mana = UnitPower("player", 0)
	local maxMana = UnitPowerMax("player", 0)
	if mana < 0.1 * maxMana then
		return true
	else
		return false
	end
end

function Ukungu.Player.hasAggro()
	local status = UnitThreatSituation("player")
	if status == 3 then
		return true
	else
		return false
	end
end

function Ukungu.Player.isDead()
	if UnitIsDead("player") then
		return true
	else
		return false
	end
end

function Ukungu.Player.isInInstance()
	inInstance, _ = IsInInstance()
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

function Ukungu.Main.ticker()
	-- If not in instance or no healer, do nothing
	if Ukungu.Player.isInInstance() == false or Ukungu.Player.isHealer() == false then
		return
	end

	-- Low Mana Status
	if Ukungu.Player.isLOM() and Ukungu.Player.Status.isLOM == false then
		Ukungu.Player.Status.isLOM = true
		Ukungu.Chat.send("Healer is low on mana.")
	end
	-- Reset Low Mana Status
	if Ukungu.Player.isLOM() == false and Ukungu.Player.Status.isLOM == true then
		Ukungu.Player.Status.isLOM = false
	end

	-- Out of Mana
	if Ukungu.Player.isOOM() and Ukungu.Player.Status.isOOM == false then
		Ukungu.Player.Status.isOOM = true
		Ukungu.Chat.send("Healer is out of mana.")
	end
	-- Reset Out of Mana Status
	if Ukungu.Player.isOOM() == false and Ukungu.Player.Status.isOOM == true then
		Ukungu.Player.Status.isOOM = false
	end

	-- Near Death Status
	if Ukungu.Player.isNearDeath() and Ukungu.Player.Status.isNearDeath == false then
		Ukungu.Player.Status.isNearDeath = true
		Ukungu.Chat.send("Healer is near death.")
	end
	-- Reset Near Death Status
	if Ukungu.Player.isNearDeath() == false and Ukungu.Player.Status.isNearDeath == true then
		Ukungu.Player.Status.isNearDeath = false
	end

	-- Dead Status
	if Ukungu.Player.isDead() and Ukungu.Player.Status.isDead == false then
		Ukungu.Player.Status.isDead = true
		Ukungu.Chat.send("Healer is dead.")
	end
	-- Reset Dead Status
	if Ukungu.Player.isDead() == false and Ukungu.Player.Status.isDead == true then
		Ukungu.Player.Status.isDead = false
	end

	-- Aggro Status
	if Ukungu.Player.hasAggro() and Ukungu.Player.Status.hasAggro == false then
		Ukungu.Player.Status.hasAggro = true
		Ukungu.Chat.send("Healer has aggro.")
	end
	-- Reset Aggro Status
	if Ukungu.Player.hasAggro() == false and Ukungu.Player.Status.hasAggro == true then
		Ukungu.Player.Status.hasAggro = false
	end
end

C_Timer.NewTicker(1, Ukungu.Main.ticker)