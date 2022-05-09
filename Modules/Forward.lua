local MailBuddy = LibStub("AceAddon-3.0"):GetAddon("MailBuddy")
local MailBuddy_Forward = MailBuddy:NewModule("Forward", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MailBuddy")
MailBuddy_Forward.description = L["Allows you to forward the contents of a mail."]
MailBuddy_Forward.description2 = L[ [[|cFFFFCC00*|r Feature is not supported for mail sent with money attached or sent COD.
|cFFFFCC00*|r Feature is not supported for mail sent with stackable items attached.
|cFFFFCC00*|r Forward button will be disabled in these cases.]] ]

local MailBuddyForwardTable = {}

function MailBuddy_Forward:MailBuddy_Forward_ForwardMailItemsEvent(event,...)
	MailBuddy_Forward_ForwardMailItems(2)
end

-- Create Forward button and hook OnClick event
function MailBuddy_Forward:OnEnable()
	if not MailBuddyForwardButton then
		MailBuddyForwardButton = CreateFrame("Button", "OpenMailForwardButton", OpenMailFrame, "UIPanelButtonTemplate")
		MailBuddyForwardButton:SetWidth(82)
		MailBuddyForwardButton:SetHeight(22)
		MailBuddyForwardButton:SetPoint("RIGHT", "OpenMailReplyButton", "LEFT", 0, 0)
		MailBuddyForwardButton:SetText(L["Forward"])
		MailBuddyForwardButton:SetScript("OnClick", function() MailBuddy_Forward_OpenMail_Forward() end)
		MailBuddyForwardButton:SetFrameLevel(MailBuddyForwardButton:GetFrameLevel() + 1)
	end
	if OpenMailForwardButton then OpenMailForwardButton:Show() end
	self:SecureHook("InboxFrame_OnClick", MailBuddy_Forward_OpenMailFrameUpdated)
end

-- Disabling modules unregisters all events/hook automatically
function MailBuddy_Forward:OnDisable()
	MailBuddy_Forward:UnregisterAllEvents()
	if OpenMailForwardButton then OpenMailForwardButton:Hide() end
end

-- Check if table contains a specific value
local function contains(table, val)
   for i=1,#table do
      if table[i] == val then 
         return true
      end
   end
   return false
end

-- Check if a mail message contains any stackable item attachments 
local function ContainsStackableItem(messageindex)
	local hasItem, itemID, itemIndex, itemStackCount
	hasItem = select(8, GetInboxHeaderInfo(messageindex))
	if hasItem == nil then return false end
	for itemIndex = 1, ATTACHMENTS_MAX_SEND do
		itemID = select(2, GetInboxItem(messageindex, itemIndex))
		if itemID ~= nil then
			itemStackCount = select(8,GetItemInfo(itemID))
			if itemStackCount > 1 then return true end
		end
	end
	return false
end

-- Calculate current bag free space
local function FreeBagSpace()
	local bagID
	local FreeSpace = 0
	for bagID = 0, 4, 1 do
		local numberOfFreeSlots, bagType = GetContainerNumFreeSlots(bagID)
		FreeSpace = FreeSpace + numberOfFreeSlots
	end
	return FreeSpace
end

-- Uses Containers free space tables to find and return location of latest item added to inventory
local function MailBuddy_Inventory_Change(action)
	local bagID, Key
	local TempTable = {}
	if action == 1 then	-- take snap shot of current container free space tables and store
		wipe(MailBuddyForwardTable)
		for bagID = 0, 4, 1 do
			table.insert(MailBuddyForwardTable, GetContainerFreeSlots(bagID))
		end
		return 0, 0
	end
	if action == 2 then	-- take new snap shot of current container free space tables and compared with stored one
		wipe(TempTable)
		for bagID = 0, 4, 1 do
			TempTable = GetContainerFreeSlots(bagID)
			for Key = 1, #PostalForwardTable[bagID + 1], 1 do
				if not contains(TempTable, MailBuddyForwardTable[bagID + 1][Key]) then
					return bagID, MailBuddyForwardTable[bagID + 1][Key]
				end
			end
		end
	end
end

-- Enable/Disable Forward button as appropriate for current selected mail
function MailBuddy_Forward_OpenMailFrameUpdated()
	if not OpenMailFrame:IsVisible() then return end
	OpenMailForwardButton:Enable()
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(InboxFrame.openMailID)
	if hasItem == nil then hasItem = 0 end
	-- Disable if mail contains money or was sent COD
	if money > 0 or CODAmount > 0 then OpenMailForwardButton:Disable() end
	-- Disable if mail attachments exceed current free bag space
	if FreeBagSpace() - hasItem < 0 then OpenMailForwardButton:Disable() end
	-- Disable if mail attachments are of stackable items
	if ContainsStackableItem(InboxFrame.openMailID) then OpenMailForwardButton:Disable() end
end

-- Generate Forward mail
function MailBuddy_Forward_OpenMail_Forward()
	MailFrameTab_OnClick(nil, 2)
	SendMailNameEditBox:SetText("")
	local subject = OpenMailSubject:GetText()
	local bodyText, stationeryID1, stationeryID2, isTakeable, isInvoice = GetInboxText(InboxFrame.openMailID);
	local prefix = "FW: "
	if (strsub(subject, 1, strlen(prefix)) ~= prefix) then
		subject = prefix..subject
	end
	if subject then SendMailSubjectEditBox:SetText(subject) end
	if bodyText then SendMailBodyEditBox:SetText(bodyText) end
	SendMailNameEditBox:SetFocus()
	MailBuddy_Forward_ForwardMailItems(1)
end

-- Deal with attachments that need forwarded
function MailBuddy_Forward_ForwardMailItems(action)
	local bagID, itemID, itemIndex, hasItem
	hasItem = select(8, GetInboxHeaderInfo(InboxFrame.openMailID))
	if action == 1 then
		if hasItem == nil then return end
		for itemIndex = 1, ATTACHMENTS_MAX_SEND do
			itemID = select(2, GetInboxItem(InboxFrame.openMailID, itemIndex))
			if itemID then
				MailBuddy_Inventory_Change(1)
				MailBuddy_Forward:RegisterEvent("BAG_UPDATE_DELAYED","MailBuddy_Forward_ForwardMailItemsEvent")
				TakeInboxItem(InboxFrame.openMailID, itemIndex)
				return
			end
		end
	end
	if action == 2 then
		MailBuddy_Forward:UnregisterEvent("BAG_UPDATE_DELAYED","MailBuddy_Forward_ForwardMailItemsEvent")
		bagID, itemIndex = MailBuddy_Inventory_Change(2)
		PickupContainerItem(bagID, itemIndex)
		ClickSendMailItemButton()
		MailBuddy_Forward_ForwardMailItems(1)
		return
	end
end
