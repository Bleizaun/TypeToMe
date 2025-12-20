local TypeToMe = TypeToMe or {}
local Helpers = TypeToMe.Helpers

local frame = CreateFrame("Frame", "blpEventFrame")
local editBox = CreateFrame("EditBox", nil, frame)

editBox:Hide()
editBox:SetMultiLine(true)
editBox:SetMaxLetters(30)
editBox:SetAutoFocus(false)
editBox:SetFontObject("GameFontNormalLarge")
frame:RegisterEvent("ITEM_TEXT_READY")

local blpText = ""
local userInput = ""
local outputText = ""
local textType = ""
local itemChars = {}
local firstTry = true
local typingStartTime = nil
local typingEndTime = nil
local totalTypingTime = nil
local correctCharacters = 0
local incorrectCharacters = 0
local textWidget

local function SetActiveTextWidget(widget)
    textWidget = widget
end

local function successReward(textType)
    if textType == "blpText" then
        userInput = ""
        if ItemTextNextPageButton and ItemTextNextPageButton:IsShown() and ItemTextNextPageButton:IsEnabled() then
            ItemTextNextPageButton:Click()
        else
            HideUIPanel(ItemTextFrame)
        end
    end
end

local function statsAndVisibility(inputChars, itemChars)
    if #inputChars >= #itemChars then
        if firstTry then
            typingEndTime = GetTime()
            totalTypingTime = typingEndTime - typingStartTime
            Helpers.typingStats(totalTypingTime, incorrectCharacters, correctCharacters)
            firstTry = false
        end
        successReward(textType)
    end
end

local function textOutput()
    if not ItemTextFrame or not ItemTextFrame:IsShown() then return end
    local inputChars = Helpers.utf8ToTable(userInput)
    outputText, correctCharacters, incorrectCharacters, inputChars = Helpers.buildOutput(itemChars, inputChars)
	userInput = table.concat(inputChars)
    statsAndVisibility(inputChars, itemChars)
    if textWidget then
        textWidget:SetText(outputText)
    end
end

ItemTextFrame:HookScript("OnMouseDown", function(self, button)
    editBox:SetFocus()
end)

frame:SetScript("OnEvent", function(self, event)
    if not TypeToMeDB.items then return end
    if event == "ITEM_TEXT_READY" then
        editBox:Show()
        editBox:SetFocus()
        SetActiveTextWidget(ItemTextPageText)
        textType = "blpText"
        blpText = Helpers.normalizeText(ItemTextGetText())

        -- Skip pages with HTML content
        if string.find(string.lower(blpText), "<html>", 1, true) then return end

        itemChars = Helpers.utf8ToTable(blpText)
        userInput = ""
        typingStartTime = nil
		typingEndTime = nil 
		totalTypingTime = nil
        correctCharacters = 0
		incorrectCharacters = 0
        firstTry = true
        textOutput()
    end
end)

editBox:SetScript("OnChar", function(_, char)
    if not TypeToMeDB.items then return end
    if not typingStartTime then typingStartTime = GetTime() end
    userInput = userInput .. char
    textOutput()
end)

editBox:SetScript("OnKeyDown", function(_, key)
    if not TypeToMeDB.items then return end
    if key == "BACKSPACE" then
        local t = Helpers.utf8ToTable(userInput)
        table.remove(t)
        userInput = table.concat(t)
        textOutput()
    elseif key == "ESCAPE" then
        HideUIPanel(ItemTextFrame)
    end
end)

ItemTextFrame:HookScript("OnHide", function()
    editBox:SetText("")
    editBox:Hide()
    editBox:ClearFocus()
end)

