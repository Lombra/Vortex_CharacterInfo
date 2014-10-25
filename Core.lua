local Character = Vortex:GetModule("Character")

local frame = Character.ui

local modelFrame = frame.modelFrame

local tl = modelFrame:CreateTexture(nil, "BACKGROUND")
tl:SetSize(212, 245)
tl:SetPoint("TOPLEFT")
tl:SetTexCoord(0.171875, 1, 0.0392156862745098, 1)

local tr = modelFrame:CreateTexture(nil, "BACKGROUND")
tr:SetSize(19, 245)
tr:SetPoint("TOPLEFT", tl, "TOPRIGHT")
tr:SetTexCoord(0, 0.296875, 0.0392156862745098, 1)

local bl = modelFrame:CreateTexture(nil, "BACKGROUND")
bl:SetSize(212, 128)
bl:SetPoint("TOPLEFT", tl, "BOTTOMLEFT")
bl:SetTexCoord(0.171875, 1, 0, 1)

local br = modelFrame:CreateTexture(nil, "BACKGROUND")
br:SetSize(19, 128)
br:SetPoint("TOPLEFT", tl, "BOTTOMRIGHT")
br:SetTexCoord(0, 0.296875, 0, 1)

local backgroundTextures = {
	tl,
	tr,
	bl,
	br,
}

local BackgroundOverlay = modelFrame:CreateTexture(nil, "BORDER")
BackgroundOverlay:SetPoint("TOPLEFT", tl)
BackgroundOverlay:SetPoint("BOTTOMRIGHT", br, 0, 52)
BackgroundOverlay:SetTexture(0, 0, 0)

local brightness = {
	BLOODELF = 0.8,
	NIGHTELF = 0.6,
	SCOURGE = 0.3,
	TROLL = 0.6,
	ORC = 0.6,
	WORGEN = 0.5,
	GOBLIN = 0.6,
}


local name = modelFrame:CreateFontString(nil, nil, "GameFontNormalLarge")
name:SetPoint("TOP", 0, -16)

local guild = modelFrame:CreateFontString(nil, nil, "GameFontHighlightMedium")
guild:SetPoint("TOP", name, "BOTTOM", 0, -8)

local class = modelFrame:CreateFontString(nil, nil, "GameFontHighlight")
class:SetPoint("TOP", guild, "BOTTOM", 0, -8)

local itemLevel = modelFrame:CreateFontString(nil, nil, "GameFontNormal")
itemLevel:SetPoint("TOP", class, "BOTTOM", 0, -16)

local location = modelFrame:CreateFontString(nil, nil, "GameFontHighlight")
location:SetPoint("TOP", itemLevel, "BOTTOM", 0, -16)

local xp = modelFrame:CreateFontString(nil, nil, "GameFontHighlight")
xp:SetPoint("TOP", location, "BOTTOM", 0, -8)


local money = modelFrame:CreateFontString(nil, nil, "GameFontHighlight")
money:SetPoint("BOTTOM", 0, 98)

local lastUpdate = modelFrame:CreateFontString(nil, nil, "GameFontHighlightSmall")
lastUpdate:SetPoint("BOTTOM", 0, 78)
lastUpdate:SetTextColor(0.75, 0.75, 0.75)

local FIRST_NUMBER_CAP = FIRST_NUMBER_CAP:lower()

local function short(amount)
	if tonumber(amount) then
		if amount >= 1e7 then
			amount = (floor(amount / 1e5) / 10)..SECOND_NUMBER_CAP
		elseif amount >= 1e6 then
			amount = (floor(amount / 1e4) / 100)..SECOND_NUMBER_CAP
		elseif amount >= 1e4 then
			amount = (floor(amount / 100) / 10)..FIRST_NUMBER_CAP
		end
	end
	return amount
end

local updateUI = Character.UpdateUI

function Character:UpdateUI(character)
	updateUI(self, character)
	
	local race, fileName = DataStore:GetCharacterRace(character)
	name:SetText(DataStore:GetColoredCharacterName(character) or strmatch(character, "([^.]+)$"))
	
	local guildName, guildRank = DataStore:GetGuildInfo(character)
	guild:SetText(guildName and "<"..DataStore:GetGuildInfo(character)..">")
	
	local level = DataStore:GetCharacterLevel(character)
	class:SetFormattedText(level and TOOLTIP_UNIT_LEVEL_RACE_CLASS or "", level, race, DataStore:GetCharacterClass(character))
	
	itemLevel:SetFormattedText("Item level: |cffffffff%d/%d", DataStore:GetAverageItemLevel(character))
	
	xp:SetShown(level and level < MAX_PLAYER_LEVEL and not DataStore:IsXPDisabled(character))
	if level then
		local restXPRate = DataStore:GetRestXPRate(character)
		if restXPRate > 0 then
			xp:SetFormattedText("%s/%s (%d%%) %d%% rested", short(DataStore:GetXP(character)), short(DataStore:GetXPMax(character)), DataStore:GetXPRate(character), min(100, restXPRate))
		else
			xp:SetFormattedText("%s/%s (%d%%)", short(DataStore:GetXP(character)), short(DataStore:GetXPMax(character)), DataStore:GetXPRate(character))
		end
	end
	
	location:SetText(DataStore:GetLocation(character))
	
	money:SetText(level and GetMoneyString(DataStore:GetMoney(character)))
	
	local lastUpdated = DataStore:GetLastLogout(character)
	lastUpdate:SetText(lastUpdated and lastUpdated > 0 and ("Last updated: "..date("%Y-%m-%d %H:%M", lastUpdated)))
	
	local texture = DressUpTexturePath(fileName)
	for i = 1, 4 do
		backgroundTextures[i]:SetTexture(texture..i)
		backgroundTextures[i]:SetDesaturated(true)
	end
	
	-- HACK - Adjust background brightness for different races
	BackgroundOverlay:SetAlpha(brightness[strupper(fileName or "ORC")] or 0.7)
end