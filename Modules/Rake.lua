local MailBuddy = LibStub("AceAddon-3.0"):GetAddon("MailBuddy")
local MailBuddy_Rake = MailBuddy:NewModule("Rake", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MailBuddy")
MailBuddy_Rake.description = L["Prints the amount of money collected during a mail session."]

local money
local flag = false

function MailBuddy_Rake:OnEnable()
	self:RegisterEvent("MAIL_SHOW")
end

-- Disabling modules unregisters all events/hook automatically
--function MailBuddy_Rake:OnDisable()
--end

function MailBuddy_Rake:MAIL_SHOW()
	if not flag then
		money = GetMoney()
		self:RegisterEvent("MAIL_CLOSED")
		flag = true
	end
end

function MailBuddy_Rake:MAIL_CLOSED()
	flag = false
	self:UnregisterEvent("MAIL_CLOSED")
	money = GetMoney() - money
	if money > 0 then
		MailBuddy:Print(L["Collected"].." "..MailBuddy:GetMoneyString(money))
	end
end
