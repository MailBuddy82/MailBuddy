local MailBuddy = LibStub("AceAddon-3.0"):NewAddon("MailBuddy", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MailBuddy")
_G["MailBuddy"] = MailBuddy

-- defaults for storage
local defaults = {
	profile = {
		ModuleEnabledState = {
			["*"] = true
		},
		OpenSpeed = 0.50,
		ChatOutput = 1,
		Select = {
			SpamChat = true,
			KeepFreeSpace = 1,
		},
		OpenAll = {
			AHCancelled = true,
			AHExpired = true,
			AHOutbid = true,
			AHSuccess = true,
			AHWon = true,
			NeutralAHCancelled = true,
			NeutralAHExpired = true,
			NeutralAHOutbid = true,
			NeutralAHSuccess = true,
			NeutralAHWon = true,
			Postmaster = true,
			Attachments = true,
			SpamChat = true,
			KeepFreeSpace = 1,
		},
		Express = {
			EnableAltClick = true,
			AutoSend = true,
			BulkSend = true,
			MouseWheel = true,
			MultiItemTooltip = true,
		},
		BlackBook = {
			AutoFill = true,
			contacts = {},
			recent = {},
			AutoCompleteAlts = true,
			AutoCompleteAllAlts = true,
			AutoCompleteRecent = true,
			AutoCompleteContacts = true,
			AutoCompleteFriends = true,
			AutoCompleteGuild = true,
			ExcludeRandoms = true,
			DisableBlizzardAutoComplete = false,
			UseAutoComplete = true,
		},
		QuickAttach = {
			EnableBag0 = true,
			EnableBag1 = true,
			EnableBag2 = true,
			EnableBag3 = true,
			EnableBag4 = true,
		},
	},
	global = {
		BlackBook = {
			alts = {},
		},
	},
}
local _G = getfenv(0)
local t = {}
MailBuddy.keepFreeOptions = {0, 1, 2, 3, 5, 10, 15, 20, 25, 30}

MailBuddy.WOWClassic = false
MailBuddy.WOWBCClassic = false
MailBuddy.WOWRetail = false

-- Use a common frame and setup some common functions for the MailBuddy dropdown menus
local Postal_DropDownMenu = CreateFrame("Frame", "MailBuddy_DropDownMenu")
MailBuddy_DropDownMenu.displayMode = "MENU"
MailBuddy_DropDownMenu.info = {}
MailBuddy_DropDownMenu.levelAdjust = 0
MailBuddy_DropDownMenu.UncheckHack = function(dropdownbutton)
	_G[dropdownbutton:GetName().."Check"]:Hide()
	_G[dropdownbutton:GetName().."UnCheck"]:Hide()
end
MailBuddy_DropDownMenu.HideMenu = function()
	if UIDROPDOWNMENU_OPEN_MENU == MailBuddy_DropDownMenu then
		CloseDropDownMenus()
	end
end

-- Functions for long subject mouseover
local function subjectHoverIn(self)
	local s = _G["MailItem"..self:GetID().."Subject"]
	if s:GetStringWidth() + 25 > s:GetWidth() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(s:GetText())
		GameTooltip:Show()
	end
end
local function subjectHoverOut(self)
	GameTooltip:Hide()
end


---------------------------
-- MailBuddy Core Functions --
---------------------------

function MailBuddy:OnInitialize()

	--print("MailBuddy is Active and Running");

	-- Detect which release of WOW is running and set appropriate flags
	if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC then MailBuddy.WOWClassic = true end
	if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC then MailBuddy.WOWBCClassic = true end
	if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE then MailBuddy.WOWRetail = true end
-- if MailBuddy.WOWClassic then DEFAULT_CHAT_FRAME:AddMessage("MailBuddy WOW Classic", 0.0, 0.69, 0.94) end
-- if MailBuddy.WOWBCClassic then DEFAULT_CHAT_FRAME:AddMessage("MailBuddy WOW BC Classic", 0.0, 0.69, 0.94) end
-- if MailBuddy.WOWRetail then DEFAULT_CHAT_FRAME:AddMessage("MailBuddy WOW Retail", 0.0, 0.69, 0.94) end

	-- Version number
	if not self.version then self.version = GetAddOnMetadata("MailBuddy", "Version") end

	-- Initialize database
	self.db = LibStub("AceDB-3.0"):New("MailBuddy3DB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	-- Enable/disable modules based on saved settings
	for name, module in self:IterateModules() do
		module:SetEnabledState(self.db.profile.ModuleEnabledState[name] or false)
		if module.OnEnable then
			hooksecurefunc(module, "OnEnable", self.OnModuleEnable_Common) -- Posthook
		end
	end

	-- Register events
	self:RegisterEvent("MAIL_CLOSED")

	-- Create the Menu Button
	local MailBuddy_ModuleMenuButton = CreateFrame("Button", "MailBuddy_ModuleMenuButton", MailFrame)
	MailBuddy_ModuleMenuButton:SetWidth(25)
	MailBuddy_ModuleMenuButton:SetHeight(25)
	MailBuddy_ModuleMenuButton:SetPoint("TOPRIGHT", -22, 2)
	MailBuddy_ModuleMenuButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	MailBuddy_ModuleMenuButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round")
	MailBuddy_ModuleMenuButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	MailBuddy_ModuleMenuButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	MailBuddy_ModuleMenuButton:SetScript("OnClick", function(self, button, down)
		if MailBuddy_DropDownMenu.initialize ~= MailBuddy.Menu then
			CloseDropDownMenus()
			MailBuddy_DropDownMenu.initialize = MailBuddy.Menu
		end
		ToggleDropDownMenu(1, nil, MailBuddy_DropDownMenu, self:GetName(), 0, 0)
	end)
	MailBuddy_ModuleMenuButton:SetScript("OnHide", MailBuddy_DropDownMenu.HideMenu)

	-- Create 7 buttons for mouseover on long subject lines
	for i = 1, 7 do
		local b = CreateFrame("Button", "PostalSubjectHover"..i, _G["MailItem"..i])
		b:SetID(i)
		b:SetAllPoints(_G["MailItem"..i.."Subject"])
		b:SetScript("OnEnter", subjectHoverIn)
		b:SetScript("OnLeave", subjectHoverOut)
	end
	self.OnInitialize = nil
end

function MailBuddy:OnProfileChanged(event, database, newProfileKey)
	for name, module in self:IterateModules() do
		if self.db.profile.ModuleEnabledState[name] then
			module:Enable()
		else
			module:Disable()
		end
	end
end

function MailBuddy:OnModuleEnable_Common()
	-- If the module is enabled with the MailFrame open (at mailbox)
	-- run the MAIL_SHOW() event function
	if self.MAIL_SHOW and MailFrame:IsVisible() then
		self:MAIL_SHOW()
	end
end

-- Hides the minimap unread mail button if there are no unread mail on closing the mailbox.
-- Does not scan past the first 100 items since only the first 100 are viewable.
function MailBuddy:MAIL_CLOSED()
	for i = 1, GetInboxNumItems() do
		if not select(9, GetInboxHeaderInfo(i)) then return end
	end
	MiniMapMailFrame:Hide()
end

function MailBuddy:Print(...)
	local text = "|cff33ff99Postal|r:"
	for i = 1, select("#", ...) do
		text = text.." "..tostring(select(i, ...))
	end

	if not self:IsChatFrameActive(self.db.profile.ChatOutput) then
		self.db.profile.ChatOutput = 1
	end
	local chatFrame = _G["ChatFrame"..self.db.profile.ChatOutput]
	if chatFrame then
		chatFrame:AddMessage(text)
	end
end

function MailBuddy:IsChatFrameActive(i)
	local _, _, _, _, _, _, shown = FCF_GetChatWindowInfo(i);
	local chatFrame = _G["ChatFrame"..i]
	if chatFrame then
		if shown or chatFrame.isDocked then
			return true
		end
	end
	return false
end

function MailBuddy.SaveOption(dropdownbutton, arg1, arg2, checked)
	MailBuddy.db.profile[arg1][arg2] = checked
end

function MailBuddy.ToggleModule(dropdownbutton, arg1, arg2, checked)
	MailBuddy.db.profile.ModuleEnabledState[arg1] = checked
	if checked then arg2:Enable() else arg2:Disable() end
end

function MailBuddy.SetOpenSpeed(dropdownbutton, arg1, arg2, checked)
	MailBuddy.db.profile.OpenSpeed = arg1
end

function MailBuddy.SetChatOutput(dropdownbutton, arg1, arg2, checked)
	MailBuddy.db.profile.ChatOutput = arg1
end

function MailBuddy.ProfileFunc(dropdownbutton, arg1, arg2, checked)
	if arg1 == "NewProfile" then
		StaticPopup_Show("POSTAL_NEW_PROFILE")
	else
		MailBuddy.db[arg1](MailBuddy.db, arg2)
	end
	CloseDropDownMenus()
end

StaticPopupDialogs["MAILBUDDY_NEW_PROFILE"] = {
	text = L["New Profile Name:"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	editBoxWidth = 350,  -- Needed in Cata
	OnAccept = function(self)
		MailBuddy.db:SetProfile(strtrim(self.editBox:GetText()))
	end,
	OnShow = function(self)
		self.editBox:SetText(MailBuddy.db:GetCurrentProfile())
		self.editBox:SetFocus()
	end,
	OnHide = StaticPopupDialogs["SET_GUILDPLAYERNOTE"].OnHide,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		MailBuddy.db:SetProfile(strtrim(parent.editBox:GetText()))
		parent:Hide()
	end,
	EditBoxOnEscapePressed = StaticPopupDialogs["SET_GUILDPLAYERNOTE"].EditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

function MailBuddy.Menu(self, level)
	if not level then return end
	local info = self.info
	wipe(info)
	if level == 1 then
		info.isTitle = 1
		info.text = "MailBuddy"
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		info.disabled = nil
		info.isTitle = nil
		info.notCheckable = nil

		info.keepShownOnClick = 1
		info.isNotRadio = 1
		for name, module in MailBuddy:IterateModules() do
			info.text = L[name]
			info.func = MailBuddy.ToggleModule
			info.arg1 = name
			info.arg2 = module
			info.checked = module:IsEnabled()
			info.hasArrow = module.ModuleMenu ~= nil
			info.value = module
			UIDropDownMenu_AddButton(info, level)
		end

		wipe(info)
		info.disabled = 1
		UIDropDownMenu_AddButton(info, level)
		info.disabled = nil

		info.text = L["Opening Speed"]
		info.func = self.UncheckHack
		info.notCheckable = 1
		info.keepShownOnClick = 1
		info.hasArrow = 1
		info.value = "OpenSpeed"
		UIDropDownMenu_AddButton(info, level)

		info.text = L["Chat Output"]
		info.func = self.UncheckHack
		info.notCheckable = 1
		info.keepShownOnClick = 1
		info.hasArrow = 1
		info.value = "ChatOutput"
		UIDropDownMenu_AddButton(info, level)

		info.text = L["Profile"]
		info.func = self.UncheckHack
		info.value = "Profile"
		UIDropDownMenu_AddButton(info, level)

		wipe(info)
		info.notCheckable = 1
		info.text = L["Help"]
		info.func = MailBuddy.About
		UIDropDownMenu_AddButton(info, level)

		info.disabled = 1
		info.text = nil
		info.func = nil
		UIDropDownMenu_AddButton(info, level)

		info.disabled = nil
		info.text = CLOSE
		info.func = self.HideMenu
		info.tooltipTitle = CLOSE
		UIDropDownMenu_AddButton(info, level)

	elseif level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "OpenSpeed" then
			local speed = MailBuddy.db.profile.OpenSpeed
			for i = 0, 0 do
				local s = 0
				info.text = format("%0.2f", s)
				info.func = MailBuddy.SetOpenSpeed
				info.checked = s == speed
				info.arg1 = s
				UIDropDownMenu_AddButton(info, level)
			end
			for i = 0, 13 do
				local s = 0.3 + i*0.05
				info.text = format("%0.2f", s)
				info.func = MailBuddy.SetOpenSpeed
				info.checked = s == speed
				info.arg1 = s
				UIDropDownMenu_AddButton(info, level)
			end
			for i = 0, 8 do
				local s = 1 + i*0.5
				info.text = format("%0.2f", s)
				info.func = MailBuddy.SetOpenSpeed
				info.checked = s == speed
				info.arg1 = s
				UIDropDownMenu_AddButton(info, level)
			end

		elseif UIDROPDOWNMENU_MENU_VALUE == "ChatOutput" then
			local selectedFrame = MailBuddy.db.profile.ChatOutput
			for i = 1, NUM_CHAT_WINDOWS do
				if MailBuddy:IsChatFrameActive(i) then
					info.text = format("%d. %s", i, _G["ChatFrame"..i.."Tab"]:GetText())
					info.func = MailBuddy.SetChatOutput
					info.checked = i == selectedFrame
					info.arg1 = i
					UIDropDownMenu_AddButton(info, level)
				end
			end

		elseif UIDROPDOWNMENU_MENU_VALUE == "Profile" then
			-- Profile stuff
			info.hasArrow = 1
			info.keepShownOnClick = 1
			info.func = self.UncheckHack
			info.notCheckable = 1

			info.text = L["Choose"]
			info.value = "SetProfile"
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Copy From"]
			info.value = "CopyProfile"
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Delete"]
			info.value = "DeleteProfile"
			UIDropDownMenu_AddButton(info, level)

			info.hasArrow = nil
			info.keepShownOnClick = nil
			info.func = MailBuddy.ProfileFunc
			info.arg1 = "NewProfile"
			info.text = L["New Profile"]
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Reset Profile"]
			info.func = MailBuddy.ProfileFunc
			info.arg1 = "ResetProfile"
			info.arg2 = nil
			UIDropDownMenu_AddButton(info, level)

		elseif type(UIDROPDOWNMENU_MENU_VALUE) == "table" and UIDROPDOWNMENU_MENU_VALUE.ModuleMenu then
			-- Submenus for modules
			self.levelAdjust = 1
			UIDROPDOWNMENU_MENU_VALUE.ModuleMenu(self, level)
			self.levelAdjust = 0
			self.module = UIDROPDOWNMENU_MENU_VALUE
		end

	elseif level == 3 then
		if UIDROPDOWNMENU_MENU_VALUE == "SetProfile" then
			local cur = MailBuddy.db:GetCurrentProfile()
			MailBuddy.db:GetProfiles(t)
			table.sort(t)
			info.func = MailBuddy.ProfileFunc
			info.arg1 = "SetProfile"
			for i = 1, #t do
				local s = t[i]
				info.text = s
				info.arg2 = s
				info.checked = cur == s
				UIDropDownMenu_AddButton(info, level)
			end

		elseif UIDROPDOWNMENU_MENU_VALUE == "CopyProfile" or UIDROPDOWNMENU_MENU_VALUE == "DeleteProfile" then
			local cur = MailBuddy.db:GetCurrentProfile()
			MailBuddy.db:GetProfiles(t)
			table.sort(t)
			info.func = MailBuddy.ProfileFunc
			info.arg1 = UIDROPDOWNMENU_MENU_VALUE
			info.notCheckable = 1
			for i = 1, #t do
				local s = t[i]
				if s ~= cur then
					info.text = s
					info.arg2 = s
					UIDropDownMenu_AddButton(info, level)
				end
			end

		elseif self.module and self.module.ModuleMenu then
			self.levelAdjust = 1
			self.module.ModuleMenu(self, level)
			self.levelAdjust = 0
		end

	elseif level > 3 then
		if self.module and self.module.ModuleMenu then
			self.levelAdjust = 1
			self.module.ModuleMenu(self, level)
			self.levelAdjust = 0
		end

	end
end

function MailBuddy:CreateAboutFrame()
	local aboutFrame = MailBuddy.aboutFrame
	if not aboutFrame and Chatter and ChatterCopyFrame then
		aboutFrame = ChatterCopyFrame
		aboutFrame.editBox = Chatter:GetModule("Chat Copy").editBox
	end
	if not aboutFrame or not aboutFrame.editBox then
		aboutFrame = CreateFrame("Frame", "MailBuddyAboutFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		tinsert(UISpecialFrames, "MailBuddyAboutFrame")
		aboutFrame:SetBackdrop({
			bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
			edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 3, right = 3, top = 5, bottom = 3 }
		})
		aboutFrame:SetBackdropColor(0,0,0,1)
		aboutFrame:SetWidth(500)
		aboutFrame:SetHeight(400)
		aboutFrame:SetPoint("CENTER", UIParent, "CENTER")
		aboutFrame:Hide()
		aboutFrame:SetFrameStrata("DIALOG")
		aboutFrame:SetToplevel(true)

		local scrollArea = CreateFrame("ScrollFrame", "PostalAboutScroll", aboutFrame, "UIPanelScrollFrameTemplate")
		scrollArea:SetPoint("TOPLEFT", aboutFrame, "TOPLEFT", 8, -30)
		scrollArea:SetPoint("BOTTOMRIGHT", aboutFrame, "BOTTOMRIGHT", -30, 8)

		local editBox = CreateFrame("EditBox", nil, aboutFrame)
		editBox:SetMultiLine(true)
		editBox:SetMaxLetters(99999)
		editBox:EnableMouse(true)
		editBox:SetAutoFocus(false)
		editBox:SetFontObject(ChatFontNormal)
		editBox:SetWidth(400)
		editBox:SetHeight(270)
		editBox:SetScript("OnEscapePressed", function() aboutFrame:Hide() end)
		aboutFrame.editBox = editBox

		scrollArea:SetScrollChild(editBox)

		local close = CreateFrame("Button", nil, aboutFrame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", aboutFrame, "TOPRIGHT")
	end
	MailBuddy.aboutFrame = aboutFrame
	MailBuddy.CreateAboutFrame = nil -- Kill ourselves
end

function MailBuddy.About()
	if MailBuddy.CreateAboutFrame then MailBuddy:CreateAboutFrame() end
	local version = GetAddOnMetadata("MailBuddy", "Version")
	wipe(t)
	tinsert(t, "|cFFFFCC00"..GetAddOnMetadata("MailBuddy", "Title").." v"..version.."|r")
	tinsert(t, "-----")
	tinsert(t, "")
	for name, module in MailBuddy:IterateModules() do
		tinsert(t, "|cffffcc00"..L[name].."|r")
		if module.description then
			tinsert(t, module.description)
		end
		if module.description2 then
			tinsert(t, "")
			tinsert(t, module.description2)
		end
		tinsert(t, "")
	end
	tinsert(t, "-----")
	tinsert(t, L["Please post bugs at |cFF00FFFFMailBuddy|r. When posting bugs, indicate your locale and MailBuddy's version number v%s."]:format(version))
	tinsert(t, "")
	tinsert(t, "- Zetaprime82 ")
	tinsert(t, "")
	MailBuddy.aboutFrame.editBox:SetText(table.concat(t, "\n"))
	MailBuddy.aboutFrame:Show()
	wipe(t) -- For garbage collection
end

---------------------------
-- Common Mail Functions --
---------------------------

-- Disable Inbox Clicks
local function noop() end
function MailBuddy:DisableInbox(disable)
	if disable then
		if not self:IsHooked("InboxFrame_OnClick") then
			self:RawHook("InboxFrame_OnClick", noop, true)
			for i = 1, 7 do
				_G["MailItem" .. i .. "ButtonIcon"]:SetDesaturated(true)
			end
		end
	else
		if self:IsHooked("InboxFrame_OnClick") then
			self:Unhook("InboxFrame_OnClick")
			for i = 1, 7 do
				_G["MailItem" .. i .. "ButtonIcon"]:SetDesaturated(false)
			end
		end
	end
end

-- Return the type of mail a message subject is
local SubjectPatterns = {
	AHCancelled = gsub(AUCTION_REMOVED_MAIL_SUBJECT, "%%s", ".*"),
	AHExpired = gsub(AUCTION_EXPIRED_MAIL_SUBJECT, "%%s", ".*"),
	AHOutbid = gsub(AUCTION_OUTBID_MAIL_SUBJECT, "%%s", ".*"),
	AHSuccess = gsub(AUCTION_SOLD_MAIL_SUBJECT, "%%s", ".*"),
	AHWon = gsub(AUCTION_WON_MAIL_SUBJECT, "%%s", ".*"),
}
function MailBuddy:GetMailType(msgSubject)
	if msgSubject then
		for k, v in pairs(SubjectPatterns) do
			if msgSubject:find(v) then return k end
		end
	end
	return "NonAHMail"
end

function MailBuddy:GetMoneyString(money)
	local gold = floor(money / 10000)
	local silver = floor((money - gold * 10000) / 100)
	local copper = mod(money, 100)
	if gold > 0 then
		return format(GOLD_AMOUNT_TEXTURE.." "..SILVER_AMOUNT_TEXTURE.." "..COPPER_AMOUNT_TEXTURE, gold, 0, 0, silver, 0, 0, copper, 0, 0)
	elseif silver > 0 then
		return format(SILVER_AMOUNT_TEXTURE.." "..COPPER_AMOUNT_TEXTURE, silver, 0, 0, copper, 0, 0)
	else
		return format(COPPER_AMOUNT_TEXTURE, copper, 0, 0)
	end
end

function MailBuddy:GetMoneyStringPlain(money)
	local gold = floor(money / 10000)
	local silver = floor((money - gold * 10000) / 100)
	local copper = mod(money, 100)
	if gold > 0 then
		return gold..GOLD_AMOUNT_SYMBOL.." "..silver..SILVER_AMOUNT_SYMBOL.." "..copper..COPPER_AMOUNT_SYMBOL
	elseif silver > 0 then
		return silver..SILVER_AMOUNT_SYMBOL.." "..copper..COPPER_AMOUNT_SYMBOL
	else
		return copper..COPPER_AMOUNT_SYMBOL
	end
end

function MailBuddy:CountItemsAndMoney()
	local numAttach = 0
	local numGold = 0
	for i = 1, GetInboxNumItems() do
		local msgMoney, _, _, msgItem = select(5, GetInboxHeaderInfo(i))
		numAttach = numAttach + (msgItem or 0)
		numGold = numGold + msgMoney
	end
	return numAttach, numGold
end
