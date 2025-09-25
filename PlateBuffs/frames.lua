local folder, core = ...

if not core.LibNameplates then
	return
end

local MSQ, Group = core.MSQ or LibStub("LibButtonFacade", true) or LibStub("Masque", true)
core.MSQ = MSQ

local LSM = core.LSM or LibStub("LibSharedMedia-3.0", true)
core.LSM = LSM

local Testreversepos = false

local L = core.L or LibStub("AceLocale-3.0"):GetLocale(folder, true)
local _G = _G
local pairs = pairs
local GetTime = GetTime
local CreateFrame = CreateFrame
local table_remove = table.remove
local table_sort = table.sort
local type = type
local table_getn = table.getn
local Debug = core.Debug
local DebuffTypeColor = DebuffTypeColor
local select = select
local string_gsub = string.gsub

local P = {}
local nametoGUIDs = core.nametoGUIDs
local buffBars = core.buffBars
local buffFrames = core.buffFrames
local guidBuffs = core.guidBuffs

core.unknownIcon = "Inv_misc_questionmark"

local defaultSettings = core.defaultSettings
defaultSettings.profile.skin_SkinID = "Blizzard"
defaultSettings.profile.skin_Gloss = false
defaultSettings.profile.skin_Backdrop = false
defaultSettings.profile.skin_Colors = {}

-- NEW API ---------

local GetPlateName = core.GetPlateName
local GetPlateGUID = core.GetPlateGUID

-------------------

do
	local OnEnable = core.OnEnable or core.noop
	function core:OnEnable()
		OnEnable(self)
		P = self.db.profile --this can change on profile change.
		MSQ = core.MSQ or LibStub("LibButtonFacade", true) or LibStub("Masque", true)
		if MSQ and MSQ.RegisterSkinCallback then -- LibButtonFacade-specific
			MSQ:RegisterSkinCallback(folder, self.SkinCallback, self)
			MSQ:Group(folder):Skin(self.db.profile.skin_SkinID, self.db.profile.skin_Gloss, self.db.profile.skin_Backdrop, self.db.profile.skin_Colors)
		elseif MSQ then -- Masque-specific
			Group = MSQ:Group(folder)
		end
	end
end

local function GetTexCoordFromSize(frame, size, size2)
	local gap = P.textureSize or 0.1

	local arg = size / size2
	local abj
	if arg > 1 then
		abj = 1 / size * ((size - size2) / 2)

		frame:SetTexCoord(0 + gap, 1 - gap, (0 + abj + gap), (1 - abj - gap))
	elseif arg < 1 then
		abj = 1 / size2 * ((size2 - size) / 2)

		frame:SetTexCoord((0 + abj + gap), (1 - abj - gap), 0 + gap, 1 - gap)
	else
		frame:SetTexCoord(0 + gap, 1 - gap, 0 + gap, 1 - gap)
	end
	return false
end

local function getTexturePath(textureName)
  local TexturePath = LSM:Fetch("statusbar", textureName) --or STATUSBAR_TEXTURE
  return TexturePath
end

-- Update a spell frame's texture size.
local function UpdateBuffSize(frame, size, size2)
	size, size2 = size or 24, size2 or 24
	local d, d2
	local msqbs = frame.msqborder.bordersize or size
	local msqns = frame.msqborder.normalsize or size

	d = (size * msqbs) / msqns
	d2 = (size2 * msqbs) / msqns
  
  --print(d,d2,frame.msqborder.bgtexture)

	if frame.msqborder.bgtexture then
		frame.msqborder:SetWidth(d)
		frame.msqborder:SetHeight(d2)
		frame.cd:SetPoint("TOP", frame.icon, "BOTTOM", 0.5, 0) --++
	else
		frame.msqborder:SetWidth(d)
		frame.msqborder:SetHeight(d2)
		frame.cd:SetPoint("TOP", frame.icon, "BOTTOM", 0, 0)
	end

	frame.icon:SetWidth(size)
	frame.icon:SetHeight(size2)
	GetTexCoordFromSize(frame.texture, size, size2)
	frame:SetWidth(size + (P.intervalX or 12))

	if P.showCooldown then
		frame:SetHeight(size2 + P.cooldownSize + (P.intervalY or 12))
	else
		frame:SetHeight(size2 + (P.intervalY or 12))
	end
end

-- Set cooldown text size.
local function UpdateBuffCDSize(buffFrame, size)
	local font = P.cooldownFont and LSM:Fetch("font", P.cooldownFont) or "Fonts\\FRIZQT__.TTF"
	--buffFrame.cd:SetFont(font, size, "NORMAL")
  buffFrame.cd:SetFont(font, size, P.fontFlags or "OUTLINE") --++22.4.24
  --print(P.fontFlags,"1")
  --buffFrame.cd:SetShadowOffset(1,-1)
  if P.fontShadow then --++22.4.24
    buffFrame.cd:SetShadowOffset(1,-1)
  else
    buffFrame.cd:SetShadowOffset(0,0)
  end
  --print(size)
  if buffFrame.cdbg then
    buffFrame.cdbg:SetHeight(buffFrame.cd:GetStringHeight())
  end
	if not P.legacyCooldownTexture and buffFrame.cd2 then
    --print(P.fontFlags,"2")
		buffFrame.cd2:SetFont(font, size, P.fontFlags or "OUTLINE") --++22.4.24
    --buffFrame.cd2:SetFont(font, size)
    --buffFrame.cd2:SetShadowOffset(1,-1)
    if P.fontShadow then --++22.4.24
      buffFrame.cd2:SetShadowOffset(1,-1)
    else
      buffFrame.cd2:SetShadowOffset(0,0)
    end
    --print(1)
	end
end

-- Set the stack text size.
local function SetStackSize(buffFrame, size)
  local font = --[[P.cooldownFont and LSM:Fetch("font", P.cooldownFont) or]] "Fonts\\FRIZQT__.TTF"
	--buffFrame.stack:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")
  buffFrame.stack:SetFont(font, size, P.fontFlags or "OUTLINE") --++22.4.24
  --print(P.fontFlags,"3")
  if P.fontShadow then --++22.4.24
    buffFrame.stack:SetShadowOffset(1,-1)
  else
    buffFrame.stack:SetShadowOffset(0,0)
  end
end

-- Called when spell frames are shown.
local function iconOnShow(self)
	self:SetAlpha(1)

  if self.cdbg then
    self.cdbg:Hide()
  end
	self.cd:Hide()
  if self.cdtexture then --test
    self.cdtexture:Hide()
  end
	self.stack:Hide()
	self.border:Hide()
	-- if not P.legacyCooldownTexture and self.cd2 then --test
		-- self.cd2:Hide()
	-- end

	self.skin:Hide()
	self.msqborder:Hide()
  
  --local borderTexture = LSM:Fetch("border", P.borderTexture)
  local borderTexture = P.borderTexture
  --print('borderTexture:',borderTexture)

	if borderTexture == "Masque" and MSQ then
		Group = Group or MSQ:Group(folder)
		if Group then
			local skinID = Group.SkinID or Group.db and Group.db.SkinID
			local SkinData = skinID and MSQ:GetSkin(skinID)
			if SkinData then
				local ntexture, bordersize, normalsize, borderoffsetX, borderoffsetY
				local btcoord, itcoord = nil, nil
				if SkinData.Template then
					bordersize = MSQ:GetSkin(SkinData.Template).Border.Height
					normalsize = MSQ:GetSkin(SkinData.Template).Icon.Height
				else
					bordersize = SkinData.Border.Height
					normalsize = SkinData.Icon.Height
				end

				ntexture = SkinData.Normal.Texture

				self.msqborder.bgtexture = ntexture
				self.msqborder.bordersize = bordersize
				self.msqborder.normalsize = normalsize

				self.skin:SetTexture(ntexture)
			end
		end
	else
		self.msqborder.bgtexture = borderTexture
		self.msqborder.bordersize = 42
		self.msqborder.normalsize = 36

		self.skin:SetTexture(borderTexture)
	end

	if P.showCooldown and self.expirationTime > 0 then -- P.showCooldown=Show cooldown text under the spell icon
    if self.cdbg then
      self.cdbg:Show()
    end
		self.cd:Show()
		if not P.legacyCooldownTexture and self.cd2 then
			self.cd2:Hide()
		end
	else
    if self.cdbg then
      self.cdbg:Hide()
    end
		self.cd:Hide()
		if not P.legacyCooldownTexture --[[and P.showCooldownTexture]] and self.cd2 then
			self.cd2:Show()
		end
	end
	if P.showCooldownTexture then
    if self.cdtexture then
      self.cdtexture:Show()
      if P.legacyCooldownTexture and self.cdtexture.SetCooldown then
        self.cdtexture:SetCooldown(self.startTime or GetTime(), self.duration)
      end
    end
	else
    if self.cdtexture then --test
      self.cdtexture:Hide()
    end
	end

	local iconSize = P.iconSize
	local iconSize2 = P.iconSize2
	local cooldownSize = P.cooldownSize
	local stackSize = P.stackSize
	local customSize = 1
	local spellName = self.spellName or "X"
	local spellID = self.sID or 0
	local spellOpts = core:HaveSpellOpts(spellName, spellID)

	if spellOpts then
		iconSize = spellOpts.iconSize or iconSize
		iconSize2 = spellOpts.iconSize2 or iconSize2

		customSize = spellOpts.increase or 1

		cooldownSize = spellOpts.cooldownSize or cooldownSize
		stackSize = spellOpts.stackSize or stackSize
	end

	UpdateBuffCDSize(self, cooldownSize)

	if P.showStacks and self.stackCount and self.stackCount > 1 then
		self.stack:SetText(self.stackCount)

		self.stack:Show()
		SetStackSize(self, stackSize)
	end

  if (P.blackBorderForAll) then --++13.12.23
    self.skin:SetVertexColor(0, 0, 0)
    self.skin:Show()
    self.msqborder:Show()
	elseif self.isDebuff then
		local colour = self.debuffType or ""
    --print(colour)
		if colour then
			if P.colorByType then
        local color
				if colour == "Magic" then
					color = P.color2
				end
				if colour == "Curse" then
					color = P.color3
				end
				if colour == "Disease" then
					color = P.color4
				end
				if colour == "Poison" then
					color = P.color5
				end
				if colour == "none" or colour == "" then
					color = P.color1
				end

				self.skin:SetVertexColor(color[1], color[2], color[3])
				self.skin:Show()
				self.msqborder:Show()
			else
				self.skin:SetVertexColor(P.color1[1], P.color1[2], P.color1[3])
				self.skin:Show()
				self.msqborder:Show() --??wtf idk
			end
		end
	else
		self.skin:SetVertexColor(P.color6[1], P.color6[2], P.color6[3])
		self.skin:Show()
		self.msqborder:Show()
	end

	if self.playerCast and P.biggerSelfSpells then
		UpdateBuffSize(self, (iconSize * 1.2 * customSize), (iconSize2 * 1.2 * customSize))
	else
		UpdateBuffSize(self, iconSize * customSize, iconSize2 * customSize)
	end
end

-- Called when spell frames are shown.
local function iconOnHide(self)
	self.stack:Hide()
  if self.cdbg then
    self.cdbg:Hide()
  end
	self.cd:Hide()
	self.msqborder:Hide()
	self.skin:Hide()
  if self.cdtexture then --test
    self.cdtexture:Hide()
  end
	if not P.legacyCooldownTexture then
		if self.cd2 then
			self.cd2:Hide()
		end
    if self.cdtexture then --test
      self.cdtexture:SetHeight(0.00001)
    end
	end
	self:SetAlpha(1)
	UpdateBuffSize(self, P.iconSize, P.iconSize2)
end

-- Fires for spell frames.
local function iconOnUpdate(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed
	if self.lastUpdate > 0.1 then --abit fast for cooldown flash.
		self.lastUpdate = 0
		if self.expirationTime > 0 then
			local rawTimeLeft = self.expirationTime - GetTime()
			local timeLeft
			if rawTimeLeft < P.decimalDisplayedBelowXSeconds then --++ 13.12.23
				timeLeft = core:Round(rawTimeLeft, P.digitsnumber)
			else
				timeLeft = core:Round(rawTimeLeft)
			end

			if P.showCooldown then
        if (not P.showCooldownText or rawTimeLeft > P.showCooldownTextLessThanXSeconds) then --++ 13.12.23
          self.cd:SetTextColor(0,0,0,0) -- zero alpha or empty string, doesnt matter i guess
        else
          if P.textColoringRedToGreen then
            self.cd:SetTextColor(core:RedToGreen(timeLeft, self.duration))
          else
            --self.cd:SetTextColor(0.9,0.9,0.8)
            self.cd:SetTextColor(1,1,0.9)
          end
        end
        self.cd:SetText(core:SecondsToString(timeLeft, 1))
        if self.cdbg then
          self.cdbg:SetWidth(self.cd:GetStringWidth())
        end
			end
			if not P.legacyCooldownTexture  then
				if self.cd2 then
					self.cd2:SetText(core:SecondsToString(timeLeft, 1))
          if (not P.showCooldownText or rawTimeLeft > P.showCooldownTextLessThanXSeconds) then --++ 13.12.23
            self.cd2:SetTextColor(0,0,0,0) -- zero alpha or empty string, doesnt matter i guess
          elseif P.textColoringRedToGreen then
            self.cd2:SetTextColor(core:RedToGreen(timeLeft, self.duration))
          else
            --self.cd2:SetTextColor(0.9,0.9,0.8)
            self.cd2:SetTextColor(1,1,0.9)
          end
				end
        --print(P.showCooldownTexture)
				if P.showCooldownTexture and self.cdtexture and not self.cdtexture.SetCooldown then
					self.cdtexture:SetHeight(max(0.00001, ((self.duration - timeLeft) / self.duration) * P.iconSize2))
				end
			end

			if (timeLeft / (self.duration + 0.01)) < P.blinkTimeleft and timeLeft < 60 then --buff only has 20% timeleft and is less then 60 seconds.
				local f = GetTime() % 1
				if f > 0.5 then
					f = 1 - f
				end

				self:SetAlpha(f * 3)
			end

			if GetTime() > self.expirationTime then
				self:Hide()

				local GUID = GetPlateGUID(self.realPlate)
				if GUID then
					core:RemoveOldSpells(GUID)
					core:AddBuffsToPlate(self.realPlate, GUID)
				else
					local plateName = GetPlateName(self.realPlate)
					if plateName and nametoGUIDs[plateName] then
						core:RemoveOldSpells(nametoGUIDs[plateName])
						core:AddBuffsToPlate(self.realPlate, nametoGUIDs[plateName])
					end
				end
			end
    else
      self.cd:Hide()
      self.cd2:Hide()
		end
	end
end

function core:RemoveOldSpells(GUID)
	for i = (P.numBars * P.iconsPerBar), 1, -1 do
		if guidBuffs[GUID] and guidBuffs[GUID][i] then
			if
				guidBuffs[GUID][i].expirationTime and
				guidBuffs[GUID][i].expirationTime > 0 and
				GetTime() > guidBuffs[GUID][i].expirationTime
			then
				table_remove(guidBuffs[GUID], i)
			end
		end
	end
end

local function SetBarSize(barFrame, width, height)
	barFrame:SetWidth(width)
	barFrame:SetHeight(height)
end

local function CreateBuffFrame(parentFrame, realPlate)
	local f = CreateFrame("Frame", "MainFrame", parentFrame)
	f.realPlate = realPlate
	f:SetFrameStrata("BACKGROUND")

	f.icon = CreateFrame("Frame", "MainFrameIcon", f)
	f.icon:SetPoint("TOP", f)

	f.texture = f.icon:CreateTexture(nil, "BACKGROUND")
	f.texture:SetAllPoints(true)

	f.cd = f:CreateFontString(nil, "overlay", "ChatFontNormal")
	f.cd:SetText("")
	f.cd:SetPoint("TOP", f.icon, "BOTTOM")

	--Make the text easier to see.
  if P.showCdBgTexture then --++13.12.23
    f.cdbg = f:CreateTexture(nil, "BACKGROUND")
    f.cdbg:SetTexture(0, 0, 0, .75)
    f.cdbg:SetPoint("CENTER", f.cd)
  end

	if P.legacyCooldownTexture then
		f.cdtexture = CreateFrame("Cooldown", "MainFrameTexture", f.icon, "CooldownFrameTemplate")
		f.cdtexture:SetAllPoints(true)
		f.cdtexture:SetReverse(true)
	elseif P.showCooldownTexture then --test
		f.cdtexture = f.icon:CreateTexture(nil, "BORDER")
		f.cdtexture:SetPoint("TOPLEFT")
		f.cdtexture:SetPoint("TOPRIGHT")
		f.cdtexture:SetHeight(0.00001)
		f.cdtexture:SetTexture([[Interface\Buttons\WHITE8X8]])
		f.cdtexture:SetVertexColor(0, 0, 0, 0.65)
	end
  
  --test
  if not P.legacyCooldownTexture then
    f.cd2 = f.icon:CreateFontString(nil, "overlay", "ChatFontNormal")
    f.cd2:SetText("")
    --f.cd2:SetAllPoints(true)----
    f.cd2:SetPoint("center", f.icon, "center", 1, 0)--++
    f.cd2:Hide()
    --print('CreateFontString')
  end

	f.border = f.icon:CreateTexture(nil, "BORDER")
	f.border:SetAllPoints(f.icon)

	core:SetFrameLevel(f)

	f.stack = f.icon:CreateFontString(nil, "overlay", "ChatFontNormal")
	f.stack:SetText("")
	f.stack:SetPoint("BOTTOMRIGHT", f.icon, "BOTTOMRIGHT", -1, 3)

	f.lastUpdate = 0
	f.expirationTime = 0
	f:SetScript("OnShow", iconOnShow)
	f:SetScript("OnHide", iconOnHide)

	f:SetScript("OnUpdate", iconOnUpdate)
	f.stackCount = 0

  if f.cdbg then
    f.cdbg:Hide()
  end
	f.cd:Hide()
	f.border:Hide()
  if f.cdtexture then --test
    f.cdtexture:Hide()
  end
	f.stack:Hide()

	f.msqborder = CreateFrame("Frame", "MainFrameMSQBorders", f.icon)
	f.msqborder:SetPoint("CENTER", f.icon, "CENTER")
	f.msqborder:SetFrameLevel(f.icon:GetFrameLevel())
	f.skin = f.msqborder:CreateTexture(nil, "BORDER")
	f.skin:SetAllPoints(f.msqborder)
	--	f.skin:SetBlendMode("ADD")
	f.skin:Hide()

	f.msqborder.bordersize = 1 --??
	f.msqborder.normalsize = 1

	f.msqborder.bgtexture = nil
	f.msqborder:Hide()

	return f
end

-- Show/Hide bar background texture.
function core:UpdateBarsBackground()
	for plate in pairs(buffBars) do
		for b in pairs(buffBars[plate]) do
			if P.showBarBackground == true then
				buffBars[plate][b].barBG:Show()
			else
				buffBars[plate][b].barBG:Hide()
			end
		end
	end
end

-- Create and return a bar frame.
local function CreateBarFrame(parentFrame, realPlate)
	local f = CreateFrame("frame", nil, parentFrame)
	f.realPlate = realPlate

	f:SetFrameStrata("BACKGROUND")

	f:SetWidth(1)
	f:SetHeight(1)

	--Make the text easier to see.
	f.barBG = f:CreateTexture(nil, "BACKGROUND")
	f.barBG:SetAllPoints(true)

	f.barBG:SetTexture(1, 1, 1, 0.3)
	if P.showBarBackground == true then
		f.barBG:Show()
	else
		f.barBG:Hide()
	end

	f:Show()
	return f
end

-- Build all our bar frames for a plate.
-- We anchor these to the plate and our spell frames to the bar.
local function BuildPlateBars(plate, visibleFrame)
	buffBars[plate] = buffBars[plate] or {}
	if not buffBars[plate][1] then
		buffBars[plate][1] = CreateBarFrame(visibleFrame, plate)
	end
	buffBars[plate][1]:ClearAllPoints()
	buffBars[plate][1]:SetPoint(P.barAnchorPoint, visibleFrame, P.plateAnchorPoint, P.barOffsetX, P.barOffsetY)
	buffBars[plate][1]:SetParent(visibleFrame)

	local barPoint = P.barAnchorPoint
	local parentPoint = P.plateAnchorPoint
	if P.barGrowth == 1 then --up
		barPoint = string_gsub(barPoint, "TOP", "BOTTOM")
		parentPoint = string_gsub(parentPoint, "BOTTOM", "TOP")
	else
		barPoint = string_gsub(barPoint, "BOTTOM,", "TOP")
		parentPoint = string_gsub(parentPoint, "TOP", "BOTTOM")
	end

	if P.numBars > 1 then
		for r = 2, P.numBars do
			if not buffBars[plate][r] then
				buffBars[plate][r] = CreateBarFrame(visibleFrame, plate)
			end
			buffBars[plate][r]:ClearAllPoints()

			buffBars[plate][r]:SetPoint(barPoint, buffBars[plate][r - 1], parentPoint, 0, 0)
			buffBars[plate][r]:SetParent(visibleFrame)
		end
	end
end

local function GetBarChildrenSize(n, ...)
	local frame
	local totalWidth = 1
	local totalHeight = 1
	if n > P.iconsPerBar then
		n = P.iconsPerBar
	end
	for i = 1, n do
		frame = select(i, ...)
		if P.shrinkBar == true then
			if frame:IsShown() then
				totalWidth = totalWidth + frame:GetWidth()

				if frame:GetHeight() > totalHeight then
					totalHeight = frame:GetHeight()
				end
			end
		else
			totalWidth = totalWidth + frame:GetWidth()

			if frame:GetHeight() > totalHeight then
				totalHeight = frame:GetHeight()
			end
		end
	end
	return totalWidth, totalHeight
end

-- Update a bar's size taking into account all the spell frame's height and width.
local function UpdateBarSize(barFrame)
	if barFrame:GetNumChildren() == 0 then return end

	local totalWidth, totalHeight = GetBarChildrenSize(barFrame:GetNumChildren(), barFrame:GetChildren())

	barFrame:SetWidth(totalWidth)
	barFrame:SetHeight(totalHeight)
end

local function UpdateAllBarSizes(plate)
	for r = 1, P.numBars do
		UpdateBarSize(buffBars[plate][r])
	end
end

function core:UpdateAllPlateBarSizes()
	for plate in pairs(buffBars) do
		UpdateAllBarSizes(plate)
	end
end

-- Show spells on a plate linked to a GUID.
function core:AddBuffsToPlate(plate, GUID)
  --print(GUID)
  local num
  
	if not buffFrames[plate] or not buffFrames[plate][P.iconsPerBar] then
		self:BuildBuffFrame(plate)
	end

	local t, f
	if guidBuffs[GUID] then
		table_sort(guidBuffs[GUID], function(a, b)
			if (a and b) then
				if a.playerCast ~= b.playerCast then
					return (a.playerCast or 0) > (b.playerCast or 0)
				elseif a.expirationTime == b.expirationTime then
					return a.name < b.name
				else
					return (a.expirationTime or 0) < (b.expirationTime or 0)
				end
			end
		end)

		for i = 1, P.numBars * P.iconsPerBar do
			if buffFrames[plate][i] then
				if guidBuffs[GUID][i] then
					buffFrames[plate][i].spellName = guidBuffs[GUID][i].name or ""
					buffFrames[plate][i].sID = guidBuffs[GUID][i].sID or ""
					buffFrames[plate][i].expirationTime = guidBuffs[GUID][i].expirationTime or 0
					buffFrames[plate][i].duration = guidBuffs[GUID][i].duration or 1
					buffFrames[plate][i].startTime = guidBuffs[GUID][i].startTime or GetTime()
					buffFrames[plate][i].stackCount = guidBuffs[GUID][i].stackCount or 0
					buffFrames[plate][i].isDebuff = guidBuffs[GUID][i].isDebuff
					buffFrames[plate][i].debuffType = guidBuffs[GUID][i].debuffType
					buffFrames[plate][i].playerCast = guidBuffs[GUID][i].playerCast

					buffFrames[plate][i].texture:SetTexture("Interface\\Icons\\" .. guidBuffs[GUID][i].icon)
					buffFrames[plate][i]:Show()
					--make sure OnShow fires.
					iconOnShow(buffFrames[plate][i])

					iconOnUpdate(buffFrames[plate][i], 1)
          num = num and num+1 or 1
				else
					buffFrames[plate][i]:Hide()
				end
			end
		end

		UpdateAllBarSizes(plate)
	end
  
  if core.TestNameplates then
    --print("PB frames:",num,GetPlateName(plate))
    plate.plateBuffsDebuffsCount=num
  end
end

-- Display a question mark icon since we don't know the GUID of the plate/mob.
function core:AddUnknownIcon(plate)
	if not buffFrames[plate] then
		self:BuildBuffFrame(plate, nil, true)
	end

	local i = 1 --eaiser for me to copy/paste code elsewhere.
	buffFrames[plate][i].spellName = false
	buffFrames[plate][i].expirationTime = 0
	buffFrames[plate][i].duration = 1
	buffFrames[plate][i].stackCount = 0
	buffFrames[plate][i].isDebuff = false
	buffFrames[plate][i].debuffType = false
	buffFrames[plate][i].playerCast = false

	buffFrames[plate][i].texture:SetTexture("Interface\\Icons\\" .. core.unknownIcon)

	if buffFrames[plate][i]:IsShown() then
		buffFrames[plate][i]:Hide()
	end
	buffFrames[plate][i]:Show()

	UpdateAllBarSizes(plate)
end

function core:UpdateAllFrameLevel()
	for plate in pairs(self.buffFrames) do
		for i = 1, table_getn(self.buffFrames[plate]) do
			self:SetFrameLevel(self.buffFrames[plate][i])
		end
	end
end

function core:SetFrameLevel(frame)
	Debug("SetFrameLevel", frame, self.db.profile.frameLevel)
	frame:SetFrameLevel(self.db.profile.frameLevel)
	-- frame.cdtexture:SetFrameLevel(self.db.profile.frameLevel + 1)
end

-- This will reset all the anchors on the spell frames.
function core:ResetAllPlateIcons()
	for plate in pairs(buffFrames) do
		core:BuildBuffFrame(plate, true)
	end
end

-- Create our buff frames on a plate.
function core:BuildBuffFrame(plate, reset, onlyOne)
	local visibleFrame = plate
	if not buffBars[plate] then
		BuildPlateBars(plate, visibleFrame)
	end

	if not buffBars[plate][P.numBars] then --user increased the size.
		BuildPlateBars(plate, visibleFrame)
	end

	buffFrames[plate] = buffFrames[plate] or {}

	if reset then
		for i = 1, table_getn(buffFrames[plate]) do
			buffFrames[plate][i]:Hide()
		end
	end

	local total = 1 --total number of spell frames
	if not buffFrames[plate][total] then
		buffFrames[plate][total] = CreateBuffFrame(buffBars[plate][1], plate)
	end
	buffFrames[plate][total]:SetParent(buffBars[plate][1])

	buffFrames[plate][total]:ClearAllPoints()

	if Testreversepos then
		buffFrames[plate][total]:SetPoint("TOP", buffBars[plate][1])
	else
		buffFrames[plate][total]:SetPoint("BOTTOMLEFT", buffBars[plate][1])
	end

	if onlyOne then return end

	local prevFrame = buffFrames[plate][total]
	for i = 2, P.iconsPerBar do
		total = total + 1
		if not buffFrames[plate][total] then
			buffFrames[plate][total] = CreateBuffFrame(buffBars[plate][1], plate)
		end
		buffFrames[plate][total]:SetParent(buffBars[plate][1])

		buffFrames[plate][total]:ClearAllPoints()

		buffFrames[plate][total]:SetPoint("BOTTOMLEFT", prevFrame, "BOTTOMRIGHT", -P.intervalY)

		prevFrame = buffFrames[plate][total]
	end

	if P.numBars > 1 then
		for r = 2, P.numBars do
			for i = 1, P.iconsPerBar do
				total = total + 1

				if not buffFrames[plate][total] then
					buffFrames[plate][total] = CreateBuffFrame(buffBars[plate][r], plate)
				end
				buffFrames[plate][total]:SetParent(buffBars[plate][r])

				buffFrames[plate][total]:ClearAllPoints()
				if i == 1 then
					buffFrames[plate][total]:SetPoint("BOTTOMLEFT", buffBars[plate][r])
				else
					buffFrames[plate][total]:SetPoint("BOTTOMLEFT", prevFrame, "BOTTOMRIGHT", -P.intervalY)
				end

				prevFrame = buffFrames[plate][total]
			end
		end
	end

	if not plate.PlateBuffsIsHooked then
		plate.PlateBuffsIsHooked = true
		plate:HookScript("OnSizeChanged", function(self, w, h) core:ResetPlateBarPoints(self) end)
	end
end

-- Reset a bar's anchor point.
function core:ResetBarPoint(barFrame, plate)
	barFrame:ClearAllPoints()
	barFrame:SetParent(plate)
	barFrame:SetPoint(P.barAnchorPoint, plate, P.plateAnchorPoint, P.barOffsetX, P.barOffsetY)
end

-- Reset all icon sizes. Called when user changes settings.
function core:ResetIconSizes()
	local iconSize
	local iconSize2
	local customincreaze = 1

	local frame
	for plate in pairs(self.buffFrames) do
		for i = 1, table_getn(self.buffFrames[plate]) do
			frame = self.buffFrames[plate][i]

			local spellOpts = self:HaveSpellOpts(frame.name, frame.sID)
			if frame:IsShown() and spellOpts then
				iconSize = spellOpts.iconSize
				iconSize2 = spellOpts.iconSize2
				customincreaze = spellOpts.customincreaze or 1
			else
				iconSize = P.iconSize
				iconSize2 = P.iconSize2
			end
			frame.icon:SetWidth(iconSize * customincreaze)
			frame.icon:SetHeight(iconSize2 * customincreaze)
			GetTexCoordFromSize(frame.texture, iconSize * customincreaze, iconSize2 * customincreaze)
			--Update the frame as a whole, this takes into account the size of the cooldown size.
			frame:SetWidth((iconSize * customincreaze) + P.intervalX)

			if P.showCooldown == true then
				frame:SetHeight((iconSize2 * customincreaze) + P.cooldownSize + P.intervalY)
			else
				frame:SetHeight((iconSize2 * customincreaze) + P.intervalY)
			end
		end
	end
end

-- Reset cooldown text sizes. Called when user changes settings.
function core:ResetCooldownSize()
	for plate in pairs(buffFrames) do
		for i = 1, table_getn(buffFrames[plate]) do
			local spellOpts = self:HaveSpellOpts(buffFrames[plate][i].spellName)
			UpdateBuffCDSize(
				buffFrames[plate][i],
				buffFrames[plate][i].spellName and spellOpts and spellOpts.cooldownSize or P.cooldownSize
			)
		end
	end
end

-- Update stack text size.
function core:ResetStackSizes()
	for plate in pairs(buffFrames) do
		for i = 1, table_getn(buffFrames[plate]) do
			local spellOpts = self:HaveSpellOpts(buffFrames[plate][i].spellName)
			SetStackSize(
				buffFrames[plate][i],
				buffFrames[plate][i].spellName and spellOpts and spellOpts.stackSize or P.stackSize
			)
		end
	end
end

-- Reset all bar anchors.
function core:ResetAllBarPoints()
	local barPoint = P.barAnchorPoint
	local parentPoint = P.plateAnchorPoint

	if P.barGrowth == 1 then --up
		barPoint = string_gsub(barPoint, "TOP", "BOTTOM")
		parentPoint = string_gsub(parentPoint, "BOTTOM", "TOP")
	else
		barPoint = string_gsub(barPoint, "BOTTOM,", "TOP")
		parentPoint = string_gsub(parentPoint, "TOP", "BOTTOM")
	end

	for plate in pairs(buffBars) do
		self:ResetPlateBarPoints(plate)
	end
end

-- Reset bar anchors for a particular plate.
function core:ResetPlateBarPoints(plate)--
	if buffBars[plate][1] then
    print("ResetPlateBarPoints1",plate.nameplateToken)
		self:ResetBarPoint(buffBars[plate][1], plate)
	end

	for r = 2, table_getn(buffBars[plate]) do
    print("ResetPlateBarPoints2",plate.nameplateToken)
		buffBars[plate][r]:ClearAllPoints()
		buffBars[plate][r]:SetPoint(P.barAnchorPoint, buffBars[plate][r - 1], P.plateAnchorPoint, 0, 0)
	end
end

-- When we change number of icons to show we hide all icons.
-- This will reshow the buffs again in their new locations.
function core:ShowAllKnownSpells()
	local GUID
	for plate in pairs(buffFrames) do
		GUID = GetPlateGUID(plate)
		if GUID then
			self:AddBuffsToPlate(plate, GUID)
		else
			local plateName = GetPlateName(plate)
			if plateName and nametoGUIDs[plateName] then
				self:AddBuffsToPlate(plate, nametoGUIDs[plateName])
			end
		end
	end
end
