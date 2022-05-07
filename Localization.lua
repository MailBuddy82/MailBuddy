-- MailBuddy Locale File
-- at MailBuddy

local AL3 = LibStub("AceLocale-3.0")
local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = AL3:NewLocale("MailBuddy", "enUS", true, debug)
if L then
L["|cffeda55fAlt-Click|r to send this item to %s."] = true
L["|cffeda55fControl-Click|r to attach similar items."] = true
L["|cffeda55fCtrl-Click|r to return it to sender."] = true
L["|cffeda55fShift-Click|r to take the contents."] = true
L[ [=[|cFFFFCC00*|r A default recipient name can be specified by right clicking on a button.
|cFFFFCC00*|r Which bags are used by this feature can be set in the main menu.]=] ] = true
L[ [=[|cFFFFCC00*|r Feature is not supported for mail sent with money attached or sent COD.
|cFFFFCC00*|r Feature is not supported for mail sent with stackable items attached.
|cFFFFCC00*|r Forward button will be disabled in these cases.]=] ] = true
L[ [=[|cFFFFCC00*|r Selected mail will be batch opened or returned to sender by clicking Open or Return.
|cFFFFCC00*|r You can Shift-Click 2 checkboxes to mass select every mail between the 2 checkboxes.
|cFFFFCC00*|r You can Ctrl-Click a checkbox to mass select or unselect every mail from that sender.
|cFFFFCC00*|r Select will never delete any mail (mail without text is auto-deleted by the game when all attached items and gold are taken).
|cFFFFCC00*|r Select will skip CoD mails and mails from Blizzard.
|cFFFFCC00*|r Disable the Verbose option to stop the chat spam while opening mail.]=] ] = true
L[ [=[|cFFFFCC00*|r Shift-Click to take item/money from mail.
|cFFFFCC00*|r Ctrl-Click to return mail.
|cFFFFCC00*|r Alt-Click to move an item from your inventory to the current outgoing mail (same as right click in default UI).]=] ] = true
L[ [=[|cFFFFCC00*|r Simple filters are available for various mail types.
|cFFFFCC00*|r Shift-Click the Open All button to override the filters and take ALL mail.
|cFFFFCC00*|r OpenAll will never delete any mail (mail without text is auto-deleted by the game when all attached items and gold are taken).
|cFFFFCC00*|r OpenAll will skip CoD mails and mails from Blizzard.
|cFFFFCC00*|r Disable the Verbose option to stop the chat spam while opening mail.]=] ] = true
L[ [=[|cFFFFCC00*|r This module will list your contacts, friends, guild mates, alts and track the last 10 people you mailed.
|cFFFFCC00*|r It will also autocomplete all names in your BlackBook.]=] ] = true
L["A button that collects all attachments and coins from mail."] = true
L["Add check boxes to the inbox for multiple mail operations."] = true
L["Add Contact"] = true
L["Add multiple item mail tooltips"] = true
L["Adds a contact list next to the To: field."] = true
L["AH-related mail"] = true
L["All Alts"] = true
L["Allows you to copy the contents of a mail."] = true
L["Allows you to forward the contents of a mail."] = true
L["Allows you to quickly attach different trade items types to a mail."] = true
L["Alts"] = true
L["Auto-Attach similar items on Control-Click"] = true
L["Autofill last person mailed"] = true
L["Auto-Send on Alt-Click"] = true
L["BlackBook"] = true
L["Block incoming trade requests while in a mail session."] = true
L["CarbonCopy"] = true
L["Chat Output"] = true
L["Choose"] = true
L["Clear list"] = true
L["Cloth"] = true
L["Collected"] = true
L["Contacts"] = true
L["Cooking"] = true
L["Copy From"] = true
L["Copy this mail"] = true
L["Default recipient:"] = true
L["Delete"] = true
L["Devices"] = true
L["Disable Blizzard's auto-completion popup menu"] = true
L["DoNotWant"] = true
L["Elemental"] = true
L["Enable Alt-Click to send mail"] = true
L["Enable for backpack"] = true
L["Enable for bag four"] = true
L["Enable for bag one"] = true
L["Enable for bag three"] = true
L["Enable for bag two"] = true
L["Enchanting"] = true
L["Exclude randoms you interacted with"] = true
L["Explosives"] = true
L["Express"] = true
L["Forward"] = true
L["Friends"] = true
L["Guild"] = true
L["Help"] = true
L["Herb"] = true
L["In Progress"] = true
L["Inscription"] = true
L["Jewelcrafting"] = true
L["Keep free space"] = true
L["Leather"] = true
L["Metal & Stone"] = true
L["Mouse click short cuts for mail."] = true
L["Name auto-completion options"] = true
L["New Profile"] = true
L["New Profile Name:"] = true
L["Non-AH related mail"] = true
L["Not all messages are shown, refreshing mailbox soon to continue Open All..."] = true
L["Not taking more items as there are now only %d regular bagslots free."] = true
L["Open"] = true
L["Open All"] = true
L["Open all Auction cancelled mail"] = true
L["Open all Auction expired mail"] = true
L["Open all Auction successful mail"] = true
L["Open all Auction won mail"] = true
L["Open all mail with attachments"] = true
L["Open all Outbid on mail"] = true
L["Open mail from the Postmaster"] = true
L["OpenAll"] = true
L["Opening Speed"] = true
L["Optional Reagents"] = true
L["Other"] = true
L["Other options"] = true
L["Part %d"] = true
L["Parts"] = true
L["Please post bugs at |cFF00FFFFMailBuddy|r. When posting bugs, indicate your locale and MailBuddy's version number v%s."] = true
L["Prints the amount of money collected during a mail session."] = true
L["Processing Message"] = true
L["Profile"] = true
L["QuickAttach"] = true
L["Rake"] = true
L["Reagent"] = true
L["Recently Mailed"] = true
L["Refreshing mailbox..."] = true
L["Remove Contact"] = true
L["Reset Profile"] = true
L["Return"] = true
L["Select"] = true
L["Set subject field to value of coins sent if subject is blank."] = true
L["Shows a clickable visual icon as to whether a mail will be returned or deleted on expiry."] = true
L["Skipping"] = true
L["Some Messages May Have Been Skipped."] = true
L["Thaumaturge Vashreen"] = true
L["The Postmaster"] = true
L["There are %i more messages not currently shown."] = true
L["There are %i more messages not currently shown. More should become available in %i seconds."] = true
L["Trade Goods"] = true
L["TradeBlock"] = true
L["Use Mr.Plow after opening"] = true
L["Use MailBuddy's auto-complete"] = true
L["Verbose mode"] = true
L["Wire"] = true

    if GetLocale() == "enUS" or GetLocale() == "enGB" then
        return
    end
end