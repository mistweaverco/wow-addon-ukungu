Ukungu = Ukungu or {}
Ukungu.Core = Ukungu.Core or {}
Ukungu.Core.AddonPanel = Ukungu.Core.AddonPanel or CreateFrame("Frame")
Ukungu.Core.ticker = Ukungu.Core.ticker or {}
Ukungu.Core.ticker30 = Ukungu.Core.ticker30 or {}
Ukungu.Core.runOnceOnAddonLoaded = Ukungu.Core.runOnceOnAddonLoaded or {}


function Ukungu.Core.tick()
	for _, tick in pairs(Ukungu.Core.ticker) do
		tick()
	end
end

function Ukungu.Core.tick30()
	for _, tick in pairs(Ukungu.Core.ticker30) do
		tick()
	end
end

function Ukungu.Core.onAddonCopartmentClick()
	InterfaceOptionsFrame_OpenToCategory(Ukungu.Core.AddonPanel)
end

function Ukungu.Core.setupAddonCompartment()
	AddonCompartmentFrame:RegisterAddon({
		text = "Ukungu",
		icon = "Interface\\Icons\\spell_monk_mistweaver_spec",
		notCheckable = true,
		func = Ukungu.Core.onAddonCopartmentClick,
	})
end

function Ukungu.Core.setupAddonPanel()
	Ukungu.Core.AddonPanel.name = "Ukungu"
	Ukungu.Core.AddonPanel.okay = function() end
	Ukungu.Core.AddonPanel.cancel = function() end
	Ukungu.Core.AddonPanel.default = function() end
	Ukungu.Core.AddonPanel.refresh = function() end
	InterfaceOptions_AddCategory(Ukungu.Core.AddonPanel)
end

local function onAddonLoaded()
	UkunguDB = UkunguDB or {}
	UkunguPCDB = UkunguPCDB or {}

	Ukungu.Core.setupAddonPanel();
	Ukungu.Core.setupAddonCompartment();

	for _, ro in pairs(Ukungu.Core.runOnceOnAddonLoaded) do
		ro()
	end


	C_Timer.NewTicker(1, Ukungu.Core.tick)
	C_Timer.NewTicker(30, Ukungu.Core.tick30)
end

local frame = CreateFrame("Frame")

-- trigger event with /reloadui or /rl
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(this, event, addonName, ...)
	if event == "ADDON_LOADED" and addonName == "Ukungu" then
		onAddonLoaded()
	end
end)

SLASH_UKUNGU1 = "/ukungu"

SlashCmdList.UKUNGU = function(msg, editBox)
	InterfaceOptionsFrame_OpenToCategory(Ukungu.Core.AddonPanel)
end
