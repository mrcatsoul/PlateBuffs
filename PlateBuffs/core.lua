--[[
Author:		Cyprias, Kader
License:	All Rights Reserved
]]
local folder, core = ...
LibStub("AceAddon-3.0"):NewAddon(core, folder, "AceConsole-3.0", "AceEvent-3.0")

-- global lookup
local Debug = core.Debug

local LibNameplates = LibStub("LibNameplates-1.0", true)
if not LibNameplates then
	error(folder .. " requires LibNameplates-1.0.")
	return
end

local LSM = LibStub("LibSharedMedia-3.0")
if not LSM then
	error(folder .. " requires LibSharedMedia-3.0.")
	return
end

local C_NamePlate = C_NamePlate
local nameplateGuidToToken={}

local UnitIsUnit = UnitIsUnit

-- local
core.title = "Plate Buffs"
core.version = GetAddOnMetadata(folder, "X-Curse-Packaged-Version") or ""
core.titleFull = core.title .. " " .. core.version
core.addonDir = "Interface\\AddOns\\" .. folder .. "\\"

core.LibNameplates = LibNameplates
core.LSM = LSM

local LDS = LibStub("LibDualSpec-1.0", true)

local L = LibStub("AceLocale-3.0"):GetLocale(folder, true)
core.L = L

-- Nameplates with these names are totems. By default we ignore totem nameplates.
local totemList = {
	2484, --Earthbind Totem
	8143, --Tremor Totem
	8177, --Grounding Totem
	8512, --Windfury Totem
	6495, --Sentry Totem
	8170, --Cleansing Totem
	3738, --Wrath of Air Totem
	2062, --Earth Elemental Totem
	2894, --Fire Elemental Totem
	58734, --Magma Totem
	58582, --Stoneclaw Totem
	58753, --Stoneskin Totem
	58739, --Fire Resistance Totem
	58656, --Flametongue Totem
	58745, --Frost Resistance Totem
	58757, --Healing Stream Totem
	58774, --Mana Spring Totem
	58749, --Nature Resistance Totem
	58704, --Searing Totem
	58643, --Strength of Earth Totem
	57722 --Totem of Wrath
}

-- Important spells, add them with huge icons.
local defaultSpells1 = {
	118, --Polymorph
	51514, --Hex
	710, --Banish
	6358, --Seduction
	6770, --Sap
	605, --Mind Control
	33786, --Cyclone
	5782, --Fear
	5484, --Howl of Terror
	6789, --Death Coil
	45438, --Ice Block
	642, --Divine Shield
	8122, --Psychic Scream
	339, --Entangling Roots
	23335, -- Silverwing Flag (alliance WSG flag)
	23333, -- Warsong Flag (horde WSG flag)
	34976, -- Netherstorm Flag (EotS flag)
	2094, --Blind
	33206, --Pain Suppression (priest)
	29166, --Innervate (druid)
	47585, --Dispersion (priest)
	19386 --Wyvern Sting (hunter)
}

-- semi-important spells, add them with mid size icons.
local defaultSpells2 = {
	15487, --Silence (priest)
	10060, --Power Infusion (priest)
	2825, --Bloodlust
	5246, --Intimidating Shout (warrior)
	31224, --Cloak of Shadows (rogue)
	498, --Divine Protection
	47476, --Strangulate (warlock)
	31884, --Avenging Wrath (pally)
	37587, --Bestial Wrath (hunter)
	12472, --Icy Veins (mage)
	49039, --Lichborne (DK)
	48792, --Icebound Fortitude (DK)
	5277, --Evasion (rogue)
	53563, --Beacon of Light (pally)
	22812, --Barkskin (druid)
	67867, --Trampled (ToC arena spell when you run over someone)
	1499, --Freezing Trap
	2637, --Hibernate
	64044, --Psychic Horror
	19503, --Scatter Shot (hunter)
	34490, --Silencing Shot (hunter)
	10278, --Hand of Protection (pally)
	10326, --Turn Evil (pally)
	44572, --Deep Freeze (mage)
	20066, --Repentance (pally)
	46968, --Shockwave (warrior)
	46924, --Bladestorm (warrior)
	16689, --Nature's Grasp (Druid)
	2983, --Sprint (rogue)
	2379, --Swiftness Potion
	6615, --Free Action Potion
	3680, --Lesser Invisibility Potion
	11392, --Invisibility Potion
	17624, --Potion of Petrification
	53762, --Indestructible Potion
	53908, --Potion of Speed
  24364, --Living action pot
  35477, --drums of speed
	1850 --Dash
}

-- used to add spell only by name ( no need spellid )
local defaultSpells3 = {
	5782 -- Fear
}

local regEvents = {
	"PLAYER_TARGET_CHANGED",
	"UPDATE_MOUSEOVER_UNIT",
	"UNIT_AURA",
	"UNIT_TARGET",
}

core.db = {}
local db
local P  --db.profile

core.defaultSettings = {
	profile = {
		spellOpts = {},
		ignoreDefaultSpell = {} -- default spells that user has removed. Seems odd but this'll save space in the DB file allowing PB to load faster.
	}
}

core.buffFrames = {}
core.guidBuffs = {}
core.nametoGUIDs = {}
-- w/o servername
core.buffBars = {}

local buffBars = core.buffBars
local guidBuffs = core.guidBuffs
local nametoGUIDs = core.nametoGUIDs
local buffFrames = core.buffFrames
local defaultSettings = core.defaultSettings

local _
local pairs = pairs
local UnitExists = UnitExists
local GetSpellInfo = GetSpellInfo

local nameToPlate = {}

core.iconTestMode = false

local table_getn = table.getn

local totems = {}
do
	local name, texture, _
	for i = 1, table_getn(totemList) do
		name, _, texture = GetSpellInfo(totemList[i])
		totems[name] = texture
	end
end

--Add default spells to defaultSettings table.
for i = 1, table_getn(defaultSpells1) do
	local spellName = GetSpellInfo(defaultSpells1[i])
	if spellName then
		core.defaultSettings.profile.spellOpts[spellName] = {
			spellID = defaultSpells1[i],
			increase = 2,
			cooldownSize = 14, --++
			show = 1,
			stackSize = 14 --++
		}
	end
end

for i = 1, table_getn(defaultSpells2) do
	local spellName = GetSpellInfo(defaultSpells2[i])
	if spellName then
		core.defaultSettings.profile.spellOpts[spellName] = {
			spellID = defaultSpells2[i],
			increase = 1.5,
			cooldownSize = 14,
			show = 1,
			stackSize = 14
		}
	end
end

for i = 1, table_getn(defaultSpells3) do
	local spellName = GetSpellInfo(defaultSpells3[i])
	if spellName then
		core.defaultSettings.profile.spellOpts[spellName] = {
			spellID = "No SpellID",
			increase = 1.5,
			cooldownSize = 14,
			show = 1,
			stackSize = 14
		}
	end
end

core.Dummy = function() end

function core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("PB_DB", core.defaultSettings, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
	self:RegisterChatCommand("pb", "MySlashProcessorFunc")

	if LDS then LDS:EnhanceDatabase(self.db, self.title) end

	self:BuildAboutMenu()

	local config = LibStub("AceConfig-3.0")
	local dialog = LibStub("AceConfigDialog-3.0")
	config:RegisterOptionsTable(self.title, self.CoreOptionsTable)
	dialog:AddToBlizOptions(self.title, self.titleFull)

	config:RegisterOptionsTable(self.title .. "Who", self.WhoOptionsTable)
	dialog:AddToBlizOptions(self.title .. "Who", L["Who"], self.titleFull)

	config:RegisterOptionsTable(self.title .. "Spells", self.SpellOptionsTable)
	dialog:AddToBlizOptions(self.title .. "Spells", L["Specific Spells"], self.titleFull)

	--config:RegisterOptionsTable(self.title .. "dSpells", self.DefaultSpellOptionsTable) -- 22.4.24
	--dialog:AddToBlizOptions(self.title .. "dSpells", L["Default Spells"], self.titleFull)

	config:RegisterOptionsTable(self.title .. "Rows", self.BarOptionsTable)
	dialog:AddToBlizOptions(self.title .. "Rows", L["Rows"], self.titleFull)

	config:RegisterOptionsTable(self.title .. "About", self.AboutOptionsTable)
	dialog:AddToBlizOptions(self.title .. "About", L.about, self.titleFull)

	--last UI
	local optionsTable = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	config:RegisterOptionsTable(self.title .. "Profile", optionsTable)
	dialog:AddToBlizOptions(self.title .. "Profile", L["Profiles"], self.titleFull)

	if LDS then LDS:EnhanceOptions(optionsTable, self.db) end

	LSM:Register("font", "Friz Quadrata TT CYR", [[Interface\AddOns\AleaUI\media\FrizQuadrataTT_New.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
end

local function GetPlateName(plate)
	return LibNameplates:GetName(plate)
end
core.GetPlateName = GetPlateName

local function GetPlateType(plate)
	return LibNameplates:GetType(plate)
end
core.GetPlateType = GetPlateType

local function IsPlateInCombat(plate)
	return LibNameplates:IsInCombat(plate)
end
core.IsPlateInCombat = IsPlateInCombat

local function GetPlateThreat(plate)
	return LibNameplates:GetThreatSituation(plate)
end
core.GetPlateThreat = GetPlateThreat

local function GetPlateReaction(plate)
	return LibNameplates:GetReaction(plate)
end
core.GetPlateReaction = GetPlateReaction

local function GetPlateGUID(plate)
	return LibNameplates:GetGUID(plate)
end
core.GetPlateGUID = GetPlateGUID

local function PlateIsBoss(plate)
	return LibNameplates:IsBoss(plate)
end
core.PlateIsBoss = PlateIsBoss

local function PlateIsElite(plate)
	return LibNameplates:IsElite(plate)
end
core.PlateIsElite = PlateIsElite

local function GetPlateByGUID(guid)
  return LibNameplates:GetNameplateByGUID(guid)
end
core.GetPlateByGUID = GetPlateByGUID

local function GetPlateByName(name, maxhp)
	return LibNameplates:GetNameplateByName(name, maxhp)
end
core.GetPlateByName = GetPlateByName

local function GetTargetPlate()
	return LibNameplates:GetTargetNameplate()
end
core.GetTargetPlate = GetTargetPlate

do
	local OnEnable = core.OnEnable
	function core:OnEnable(...)
		if OnEnable then
			OnEnable(self, ...)
		end

		db = self.db
		P = db.profile

		for i, event in pairs(regEvents) do
			self:RegisterEvent(event)
		end

		LibNameplates.RegisterCallback(self, "LibNameplates_NewNameplate")
		LibNameplates.RegisterCallback(self, "LibNameplates_FoundGUID")
		LibNameplates.RegisterCallback(self, "LibNameplates_RecycleNameplate")

		if P.playerCombatWithOnly == true or P.npcCombatWithOnly == true then
			LibNameplates.RegisterCallback(self, "LibNameplates_CombatChange")
			LibNameplates.RegisterCallback(self, "LibNameplates_ThreatChange")
		end

		-- Update old options.
		if P.cooldownSize < 2 then --++13.12.23 fixed some litel cringe
      --print(P.cooldownSize,'<',core.defaultSettings.profile.cooldownSize)
			P.cooldownSize = core.defaultSettings.profile.cooldownSize
		end
		if P.stackSize < 2 then --++13.12.23 fixed some litel cringe
			P.stackSize = core.defaultSettings.profile.stackSize
		end

		for plate in pairs(core.buffBars) do
			for i = 1, table_getn(core.buffBars[plate]) do
				core.buffBars[plate][i]:Show() --reshow incase user disabled addon.
			end
		end
	end
end

do
	local prev_OnDisable = core.OnDisable
	function core:OnDisable(...)
		if prev_OnDisable then
			prev_OnDisable(self, ...)
		end

		LibNameplates.UnregisterAllCallbacks(self)

		for plate in pairs(core.buffBars) do
			for i = 1, table_getn(core.buffBars[plate]) do
				core.buffBars[plate][i]:Hide() --makesure all frames stop OnUpdating.
			end
		end
	end
end

-- User has reset proflie, so we reset our spell exists options.
function core:OnProfileChanged(...)
	self:Disable()
	self:Enable()
end

-- /da function brings up the UI options
function core:MySlashProcessorFunc(input)
	InterfaceOptionsFrame_OpenToCategory(self.titleFull)
	InterfaceOptionsFrame_OpenToCategory(self.titleFull)
end

-- note to self, not buffBars
function core:HidePlateSpells(plate)
	if buffFrames[plate] then
		for i = 1, table_getn(buffFrames[plate]) do
			buffFrames[plate][i]:Hide()
		end
	end
end

local function isTotem(name)
	return totems[name]
end

function core:ShouldAddBuffs(plate)
	local plateName = GetPlateName(plate) or "UNKNOWN"
  --print(plateName)
  
	if P.showTotems == false and isTotem(plateName) then
    --print("|cffff0000ShouldAddBuffs false",1)
		return false
	end

	local plateType = GetPlateType(plate)
  
	if (P.abovePlayers == true and plateType == "PLAYER") or (P.aboveNPC == true and plateType == "NPC") then
		if plateType == "PLAYER" and P.playerCombatWithOnly == true and (not IsPlateInCombat(plate)) then
      --print("|cffff0000ShouldAddBuffs false",2)
			return false
		end

		if plateType == "NPC" and P.npcCombatWithOnly == true and (not IsPlateInCombat(plate) and GetPlateThreat(plate) == "LOW") then
      --print("|cffff0000ShouldAddBuffs false",3)
			return false
		end

		local plateReaction = GetPlateReaction(plate)
		if P.aboveFriendly == true and plateReaction == "FRIENDLY" then
			return true
		elseif P.aboveNeutral == true and plateReaction == "NEUTRAL" then
			return true
		elseif P.aboveHostile == true and plateReaction == "HOSTILE" then
			return true
		elseif P.aboveTapped == true and plateReaction == "TAPPED" then
			return true
		end
	end
  
  --print("|cffff0000ShouldAddBuffs false",4)

	return false
end

function core:AddOurStuffToPlate(plate)
	local GUID = GetPlateGUID(plate)
	if GUID then
		self:RemoveOldSpells(GUID)
		self:AddBuffsToPlate(plate, GUID)
		return
	end

	local plateName = GetPlateName(plate) or "UNKNOWN"
	if P.saveNameToGUID == true and nametoGUIDs[plateName] and (GetPlateType(plate) == "PLAYER" or PlateIsBoss(plate)) then
		self:RemoveOldSpells(nametoGUIDs[plateName])
		self:AddBuffsToPlate(plate, nametoGUIDs[plateName])
	elseif P.unknownSpellDataIcon == true then
		self:AddUnknownIcon(plate)
	end
end

function core:LibNameplates_RecycleNameplate(event, plate)
	self:HidePlateSpells(plate)
end

function core:LibNameplates_NewNameplate(event, plate)
	if self:ShouldAddBuffs(plate) == true then
		core:AddOurStuffToPlate(plate)
	end
end

function core:LibNameplates_FoundGUID(event, plate, GUID, unitID)
	if self:ShouldAddBuffs(plate) == true then
		if not guidBuffs[GUID] then
      --print("|cff00ffffLibNameplates_FoundGUID")
			self:CollectUnitInfo(unitID)
		end

		self:RemoveOldSpells(GUID)
		self:AddBuffsToPlate(plate, GUID)
	end
end

function core:HaveSpellOpts(spellName, spellID)
	if not P.ignoreDefaultSpell[spellName] and P.spellOpts[spellName] then
		if P.spellOpts[spellName].grabid then
			if P.spellOpts[spellName].spellID == spellID then
				return P.spellOpts[spellName]
			else
				return false
			end
		else
			return P.spellOpts[spellName]
		end
	end
	return false
end

do
	local UnitGUID = UnitGUID
	local UnitName = UnitName
	local UnitIsPlayer = UnitIsPlayer
	local UnitClassification = UnitClassification
	local table_remove = table.remove
	local table_insert = table.insert
	local UnitBuff = UnitBuff
	local UnitDebuff = UnitDebuff

	function core:CollectUnitInfo(unitID)
		if not unitID or unitID=="player" or UnitIsUnit(unitID, "player") then return end

    --print("CollectUnitInfo",unitID)
    
    --test
    -- if unitID:find("nameplate") and core.TestNameplates then
      -- local np=C_NamePlate.GetNamePlateForUnit(unitID) or GetNameplateByGuidTest(UnitGUID(unitID))

      -- if not np then
        -- return
      -- end
      
      -- if not np.origSavedName then
        -- return
      -- end
      
      -- local name=UnitName(unitID)

      -- if not name then
        -- return
      -- end
      
      -- if np.origSavedName~=name then
        -- --print("|cffff0000PB core: np.origSavedName~=name|r",np.origSavedName,name)
        -- return 
      -- end
      
      -- --print("PB core:",unitID,np.origSavedName,GetPlateGUID(unitID))
    -- end

		local GUID = UnitGUID(unitID)
		if not GUID then return end

		local unitName = UnitName(unitID)
		if unitName and P.saveNameToGUID == true and UnitIsPlayer(unitID) or UnitClassification(unitID) == "worldboss" then
			nametoGUIDs[unitName] = GUID
		end

		if P.watchUnitIDAuras == true then
			guidBuffs[GUID] = guidBuffs[GUID] or {}

			--Remove all the entries.
			for i = table_getn(guidBuffs[GUID]), 1, -1 do
				table_remove(guidBuffs[GUID], i)
			end

			local i = 1
			local name, icon, count, duration, expirationTime, unitCaster, spellId, debuffType

      if P.defaultBuffShow ~= 5 then
        while UnitBuff(unitID, i) do
          name, _, icon, count, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unitID, i)
          icon = icon:upper():gsub("(.+)\\(.+)\\", "")

          local spellOpts = --[[(duration > 0) and]] self:HaveSpellOpts(name, spellId) or nil --++
          if spellOpts and spellOpts.show and P.defaultBuffShow ~= 4 then
            if
              spellOpts.show == 1 or
              (spellOpts.show == 2 and unitCaster == "player") or
              (spellOpts.show == 4 and not UnitCanAttack("player", unitID)) or
              (spellOpts.show == 5 and UnitCanAttack("player", unitID))
            then
              table_insert(guidBuffs[GUID], {
                name = name,
                icon = icon,
                expirationTime = expirationTime,
                startTime = expirationTime - duration,
                duration = duration,
                playerCast = (unitCaster == "player") and 1,
                stackCount = count,
                sID = spellId,
                caster = unitCaster and core:GetFullName(unitCaster)
              })
            end
          else--if duration > 0 then --++
            if
              P.defaultBuffShow == 1 or
              (P.defaultBuffShow == 2 and unitCaster == "player") or
              (P.defaultBuffShow == 4 and unitCaster == "player")
            then
              table_insert(guidBuffs[GUID], {
                name = name,
                icon = icon,
                expirationTime = expirationTime,
                startTime = expirationTime - duration,
                duration = duration,
                playerCast = (unitCaster == "player") and 1,
                stackCount = count,
                sID = spellId,
                caster = unitCaster and core:GetFullName(unitCaster)
              })
            end
          end

          i = i + 1
        end
      end

      if P.defaultDebuffShow ~= 5 then
        i = 1
        while UnitDebuff(unitID, i) do
          name, _, icon, count, debuffType, duration, expirationTime, unitCaster, _, _, spellId = UnitDebuff(unitID, i)
          icon = icon:upper():gsub("INTERFACE\\ICONS\\", "")

          local spellOpts = --[[(duration > 0) and]] self:HaveSpellOpts(name, spellId) or nil --++
          if spellOpts and spellOpts.show and P.defaultDebuffShow ~= 4 then
            if
              spellOpts.show == 1 or
              (spellOpts.show == 2 and unitCaster == "player") or
              (spellOpts.show == 4 and not UnitCanAttack("player", unitID)) or
              (spellOpts.show == 5 and UnitCanAttack("player", unitID))
            then
              table_insert(guidBuffs[GUID], {
                name = name,
                icon = icon,
                expirationTime = expirationTime,
                startTime = expirationTime - duration,
                duration = duration,
                playerCast = (unitCaster == "player") and 1,
                stackCount = count,
                debuffType = debuffType,
                isDebuff = true,
                sID = spellId,
                caster = unitCaster and core:GetFullName(unitCaster)
              })
            end
          else--if duration > 0 then --++
            if
              P.defaultDebuffShow == 1 or
              (P.defaultDebuffShow == 2 and unitCaster == "player") or
              (P.defaultDebuffShow == 4 and unitCaster == "player")
            then
              table_insert(guidBuffs[GUID], {
                name = name,
                icon = icon,
                expirationTime = expirationTime,
                startTime = expirationTime - duration,
                duration = duration,
                playerCast = (unitCaster == "player") and 1,
                stackCount = count,
                debuffType = debuffType,
                isDebuff = true,
                sID = spellId,
                caster = unitCaster and core:GetFullName(unitCaster)
              })
            end
          end
          i = i + 1
        end
      end

			if core.iconTestMode == true then
				for j = table_getn(guidBuffs[GUID]), 1, -1 do
					for t = 1, P.iconsPerBar - 1 do
						table_insert(guidBuffs[GUID], j, guidBuffs[GUID][j]) --reinsert the entry abunch of times.
					end
				end
			end
		end

    if C_NamePlate then
      --self:UpdatePlateByGUID(GUID)
      self:UpdatePlateByUnitID(unitID, GUID)
		elseif unitName and not self:UpdatePlateByGUID(GUID) and (UnitIsPlayer(unitID) or UnitClassification(unitID) == "worldboss") then
			-- LibNameplates can't find a nameplate that matches that GUID. Since the unitID's a player/worldboss which have unique names, add buffs to the frame that matches that name.
			-- Note, this /can/ add buffs to the wrong frame if a hunter pet has the same name as a player. This is so rare that I'll risk it.
      --print("UpdatePlateByNameUpdatePlateByNameUpdatePlateByNameUpdatePlateByName")
			self:UpdatePlateByName(unitName, UnitHealthMax(unitID))
		end
	end
end

function core:PLAYER_TARGET_CHANGED(event, ...)
  if --[[UnitIsUnit("target", "player") or]] not UnitExists("target") then return end
  if C_NamePlate then
    local plate = C_NamePlate.GetNamePlateForUnit("target")
    if not plate or not plate:IsShown() then return end
  end
	self:CollectUnitInfo("target")
end

function core:UNIT_TARGET(event, unitID)
  if --[[UnitIsUnit(unitID .. "target", "player") or]] not UnitExists(unitID .. "target") then return end
  if C_NamePlate then
    local plate = C_NamePlate.GetNamePlateForUnit(unitID .. "target")
    if not plate or not plate:IsShown() then return end
  end
	self:CollectUnitInfo(unitID .. "target")
end

function core:LibNameplates_CombatChange(event, plate, inCombat)
	if core:ShouldAddBuffs(plate) == true then
		core:AddOurStuffToPlate(plate)
	else
		core:HidePlateSpells(plate)
	end
end

function core:LibNameplates_ThreatChange(event, plate, threatSit)
	if core:ShouldAddBuffs(plate) == true then
		core:AddOurStuffToPlate(plate)
	else
		core:HidePlateSpells(plate)
	end
end

function core:UPDATE_MOUSEOVER_UNIT(event, ...)
  if --[[UnitIsUnit("mouseover", "player") or]] not UnitExists("mouseover") then return end
  if C_NamePlate then
    local plate = C_NamePlate.GetNamePlateForUnit("mouseover")
    if not plate or not plate:IsShown() then return end
  end
	self:CollectUnitInfo("mouseover")
end

function core:UNIT_AURA(event, unitID)
  --if UnitIsUnit(unitID, "player") then return end
  if C_NamePlate then
    if unitID:find("nameplate") and C_NamePlate.GetNamePlateForUnit(unitID):IsShown() then
      self:CollectUnitInfo(unitID)
    end
  elseif not UnitIsUnit(unitID, "player") then
    self:CollectUnitInfo(unitID)
  end
end

function core:AddNewSpell(spellName, spellID)
	Debug("AddNewSpell", spellName, spellID)
	P.ignoreDefaultSpell[spellName] = nil
	P.spellOpts[spellName] = {show = 1, spellID = spellID}
	self:BuildSpellUI()
end

function core:RemoveSpell(spellName)
	if self.defaultSettings.profile.spellOpts[spellName] then
		P.ignoreDefaultSpell[spellName] = true
	end
	P.spellOpts[spellName] = nil
	core:BuildSpellUI()
end

function core:UpdatePlateByUnitID(unitID, GUID)
	local plate = C_NamePlate.GetNamePlateForUnit(unitID)
  --print("UpdatePlateByUnitID",plate,unitID,UnitName(unitID))
	if plate and self:ShouldAddBuffs(plate) == true then
		self:AddBuffsToPlate(plate, GUID)
		return true
	end
  --print("|cffff0000UpdatePlateByUnitID - false",plate,unitID,GUID,UnitName(unitID))
	return false
end

function core:UpdatePlateByGUID(GUID)
	local plate = GetPlateByGUID(GUID)
  --print("UpdatePlateByGUID",plate,unitID,UnitName(unitID))
	if plate and self:ShouldAddBuffs(plate) == true then
		self:AddBuffsToPlate(plate, GUID)
		return true
	end
  --print("|cffff0000UpdatePlateByGUID - false",plate,GUID,UnitName(unitID))
	return false
end

-- This will add buff frames to a frame matching a given name.
-- This should only be used for player names because mobs/npcs can share the same name.
function core:UpdatePlateByName(name, maxhp)
  --print("|cffff0000UpdatePlateByName")
	local GUID = nametoGUIDs[name]
	if GUID then
		local plate = GetPlateByName(name, maxhp)
		if plate and self:ShouldAddBuffs(plate) == true then
			core:AddBuffsToPlate(plate, GUID)
			return true
		end
	end
	return false
end

-- This should speed up the look up and the display when it comes
-- to targeted units and their nameplates, hopefully.
function core:UpdateTargetPlate(GUID)
	if UnitExists("target") and UnitGUID("target") == GUID then
		local plate = GetTargetPlate()
		if plate and self:ShouldAddBuffs(plate) == true then
			self:AddBuffsToPlate(plate, GUID)
			return true
		end
	end
	return false
end

function core:GetAllSpellIDs()
	local spells, name = {}, nil

	for i, spellID in pairs(defaultSpells1) do
		name = GetSpellInfo(spellID)
		spells[name] = spellID
	end
	for i, spellID in pairs(defaultSpells2) do
		name = GetSpellInfo(spellID)
		spells[name] = spellID
	end

	for i = 76567, 1, -1 do --76567
		name = GetSpellInfo(i)
		if name and not spells[name] then
			spells[name] = i
		end
	end
	return spells
end

function core:SkinCallback(skin, glossAlpha, gloss, _, _, colors)
	self.db.profile.skin_SkinID = skin
	self.db.profile.skin_Gloss = glossAlpha
	self.db.profile.skin_Backdrop = gloss
	self.db.profile.skin_Colors = colors
end

local tinsert, tremove = table.insert, table.remove

----------------------
-- test
if ( not C_Timer ) then
	local _G = _G
	local Call = pcall
	local Next = next

	local C_Timer = TimerFrame or CreateFrame("Frame", "TimerFrame")
	local ObjPool = {}

	local function Pool(Timer)
		Timer.Ref = nil
		Timer.Callback = nil
		Timer.Iteration = nil
		ObjPool[#ObjPool+1] = Timer
	end

	local function Caller(Self)
		Call(Self.Callback)

		if ( Self.Callback ) then
			local Iteration = Self.Iteration
			if ( Iteration ) then
				if ( Iteration == 1 ) then
					Self.Ref:Cancel()
				else
					Self.Iteration = Iteration - 1
				end
			elseif ( not Self.Ref ) then
				Pool(Self)
			end
		end
	end

	local function New()
		local Index, Timer = Next(ObjPool)

		if ( Timer ) then
			ObjPool[Index] = nil
		else
			local A = C_Timer:CreateAnimationGroup()
			Timer = A:CreateAnimation("Animation")
			Timer:SetScript("OnFinished", Caller)
		end

		return Timer
	end

	local function Cancel(Self)
		if ( Self.__Timer ) then
			Self.__Timer:Stop()
			Pool(Self.__Timer)
			Self.__Timer = nil
		end
	end

	local function IsCancelled(Self)
		return not Self.__Timer
	end

	local function Create(Duration, Callback, Iteration, Ticker)
		local Timer = New()

		Timer.Ref = Ticker and { __Timer = Timer, Cancel = Cancel, IsCancelled = IsCancelled }
		Timer:GetParent():SetLooping(Ticker and "REPEAT" or "NONE")
		Timer.Iteration = Iteration
		Timer.Callback = Callback

		Timer:SetDuration(Duration > 0 and Duration or .1)
		Timer:Play()

		return Timer.Ref
	end

	--[[
		METHOD
	]]

	function C_Timer.After(Duration, Callback, _)
		if ( _ ) then
			Duration = Callback
			Callback = _
		end

		Create(Duration, Callback)
	end

	function C_Timer.NewTimer(Duration, Callback, _)
		if ( _ ) then
			Duration = Callback
			Callback = _
		end

		return Create(Duration, Callback, 1, true)
	end

	function C_Timer.NewTicker(Duration, Callback, Iteration, _)
		if ( _ ) then
			Duration = Callback
			Callback = Iteration
			Iteration = _
		end

		return Create(Duration, Callback, Iteration, true)
	end

	-- Global
	_G.C_Timer = C_Timer
	C_Timer._version = 2
  core.C_Timer=C_Timer
end

core.C_Timer=C_Timer

local hookedPlates = {}

do
  if C_NamePlate then
    -- ++ 13.12.23  
    -- local t=0
    -- local function nameplatesOnUpdate(_, elapsed)
      -- t=t+elapsed
      -- if t < P.scanNameplatesInterval then return end
      -- t=0
    
      -- if not P.useAwesomeWotlkAPI then return end
      -- --print("nameplatesOnUpdate")
      -- for _,nameplateToken in pairs(nameplateGuidToToken) do
        -- core:CollectUnitInfo(nameplateToken)
      -- end
    -- end

    local f=CreateFrame("frame")
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    f:RegisterEvent("ADDON_LOADED")
    --f:RegisterEvent("UNIT_AURA")
    --f:SetScript("OnUpdate", nameplatesOnUpdate) --++ 13.12.23 +nonstop update, maybe this is shitty way idk..
    f:SetScript("OnEvent", function(self,event,...)
      if (event == "NAME_PLATE_UNIT_ADDED") then
        local nameplateToken = ...
        --print(nameplateToken)
        if nameplateToken then
          local nameplate = C_NamePlate.GetNamePlateForUnit(nameplateToken)
          if nameplate then
            nameplate.nameplateToken = nameplateToken
            local guid=UnitGUID(nameplateToken)
            if guid then
              nameplateGuidToToken[guid]=nameplateToken
            end
            if not hookedPlates[nameplate] then
              hookedPlates[nameplate]=true
              nameplate:HookScript("OnShow",function(s)
                core.C_Timer.After(0.1,function()
                  if s.nameplateToken and nameplate:IsShown() then
                    --print("|cff0000ffonshow CollectUnitInfo",s.nameplateToken)
                    core:CollectUnitInfo(s.nameplateToken)
                  end
                end)
              end)
              if nameplate:IsShown() then
                core:CollectUnitInfo(nameplateToken)
                --print("|cff00ffffnot hooked CollectUnitInfo",nameplateToken)
              end
            end
          end
        end
      elseif event == "NAME_PLATE_UNIT_REMOVED" then
        --print(event)
        local nameplateToken = ...
        if nameplateToken then
          local nameplate = C_NamePlate.GetNamePlateForUnit(nameplateToken)
          if nameplate then
            local guid=UnitGUID(nameplateToken)
            if guid then
              nameplateGuidToToken[guid]=nil
            end
            nameplate.plateBuffsDebuffsCount=nil
            nameplate.nameplateToken=nil
          end
        end
      elseif event == "ADDON_LOADED" and arg1=="TestNameplates" then
        core.TestNameplates=true
      end
    end)
  end
end
