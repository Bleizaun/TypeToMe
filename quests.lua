local TypeToMe = TypeToMe or {}
local Helpers = TypeToMe.Helpers

TypeToMeDB = TypeToMeDB or {}

--default settings
TypeToMeDB.enabled = TypeToMeDB.enabled ~= false
TypeToMeDB.items = TypeToMeDB.items ~= false
TypeToMeDB.showStats = TypeToMeDB.showStats ~= false
TypeToMeDB.targetAccuracy = TypeToMeDB.targetAccuracy or 95

local frame = CreateFrame("Frame", "EventFrame")
local slashFrame = CreateFrame("Frame", "SlashEventFrame")
local editBox = CreateFrame("EditBox", nil, frame)

editBox:SetMultiLine(true)
editBox:SetMaxLetters(30)
editBox:SetAutoFocus(false)
editBox:SetFontObject("GameFontNormalLarge")
editBox:Hide()

frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_COMPLETE")
slashFrame:RegisterEvent("ADDON_LOADED")

local questText = ""
local userInput = ""
local outputText = ""
local textType = ""
local questChars = {}
local firstTry = true
local typingStartTime = nil
local typingEndTime = nil
local totalTypingTime = nil
local lastQuestID = 0
local correctCharacters = 0
local incorrectCharacters = 0
local textWidget = nil
local targetAccuracy = TypeToMeDB.targetAccuracy


local function successReward(textType)
    if textType == "qDescription" then
        QuestFrameAcceptButton:Enable()
    elseif textType == "qComplete" then
        QuestFrameCompleteQuestButton:Enable()
    end
    C_Timer.After(0.05, function()
        QuestInfoObjectivesHeader:Show()
        QuestInfoObjectivesText:Show()
        QuestInfoRewardsFrame:Show()
    end)
end

local function SetActiveTextWidget(widget)
    textWidget = widget
end

local function resetEditBox()
    editBox:SetText("")
    editBox:Hide()
    editBox:ClearFocus()
end

local function textOutput()
    if not QuestFrame or not QuestFrame:IsShown() then return end

    local inputChars = Helpers.utf8ToTable(userInput)
    outputText, correctCharacters, incorrectCharacters, inputChars = Helpers.buildOutput(questChars, inputChars)

	userInput = table.concat(inputChars)

    if textWidget then
        textWidget:SetText(outputText)
    end

    if #inputChars == #questChars and (correctCharacters / (correctCharacters + incorrectCharacters)) * 100 >= targetAccuracy then
        if firstTry then
            typingEndTime = GetTime()
            totalTypingTime = typingEndTime - typingStartTime
            Helpers.typingStats(totalTypingTime, incorrectCharacters, correctCharacters)
            firstTry = false
        end
        typingStartTime, typingEndTime, totalTypingTime = nil, nil, nil
        successReward(textType)
    elseif #inputChars == #questChars and (correctCharacters / (correctCharacters + incorrectCharacters)) * 100 < targetAccuracy then
        print(string.format("Accuracy too low - Required: %.2f%% Actual: %.2f%%", TypeToMeDB.targetAccuracy, (correctCharacters / (correctCharacters + incorrectCharacters)) * 100))
    end
end

local function hideObjectiveReward()
    QuestInfoObjectivesHeader:Hide()
    QuestInfoObjectivesText:Hide()
    QuestInfoRewardsFrame:Hide()
end

local function prepareTyping()
    hideObjectiveReward()
    C_Timer.After(0.03, function() --this might prevent rewards being shown the first time a quest is opened after login
        hideObjectiveReward()
        if textType == "qDescription" then
            QuestFrameAcceptButton:Disable() -- this inside delay for mop classic
        elseif textType == "qComplete" then
            QuestFrameCompleteQuestButton:Disable()
        end
    end)    
	editBox:Show()
    editBox:SetFocus()
    questChars = Helpers.utf8ToTable(questText)
    textOutput()
end

frame:SetScript("OnEvent", function(self, event)
    if not TypeToMeDB.enabled then return end
    
    -- if IsInGroup() then
    --     print("TypeToMe - Skipping quest: In group")
    --     return
    -- end
    
    if IsInInstance() then
		print("TypeToMe - Skipping quest: In instance")
		return 
	end
    
    local questID = GetQuestID()
    if not questID or questID == 0 then return end
    
    if lastQuestID ~= questID then
        userInput = ""
        lastQuestID = questID
        firstTry = true
    end

    if event == "QUEST_DETAIL" then
        textType = "qDescription"
		if QuestGetAutoAccept() then -- mop classic works with this retail version of ttm except for questgetautoaccept()...
            print("TypeToMe - Skipping quest: Auto-accept")
			return
		end  
        SetActiveTextWidget(QuestInfoDescriptionText)
        questText = Helpers.normalizeText(GetQuestText())
        prepareTyping()
    elseif event == "QUEST_COMPLETE" then
        textType = "qComplete"
        SetActiveTextWidget(QuestInfoRewardText)
        questText = Helpers.normalizeText(GetRewardText())
        prepareTyping()
    end
end)

editBox:SetScript("OnChar", function(_, char)
    if not TypeToMeDB.enabled then return end
    if not typingStartTime then typingStartTime = GetTime() end
    userInput = userInput .. char
    textOutput()
end)

editBox:SetScript("OnKeyDown", function(_, key)
    if not TypeToMeDB.enabled then return end
    if key == "BACKSPACE" then
        local t = Helpers.utf8ToTable(userInput)
        table.remove(t)
        userInput = table.concat(t)
        textOutput()
    elseif key == "ESCAPE" then
        HideUIPanel(QuestFrame)
    end
end)

QuestFrame:HookScript("OnHide", function()
	resetEditBox()
    -- this ensures objectives are not hidden in the quest log after closing an uncompleted quest frame
    QuestInfoObjectivesHeader:Show()
    QuestInfoObjectivesText:Show()
    -- QuestInfoRewardsFrame:Show()
end)

QuestFrameAcceptButton:HookScript("OnClick", function()
    firstTry = true
    userInput = ""
end)

QuestFrameCompleteQuestButton:HookScript("OnClick", function()
    firstTry = true
    userInput = ""
end)

QuestFrame:HookScript("OnMouseDown", function(self, button)
    editBox:SetFocus()
end)

slashFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "TypeToMe" then
	
		TypeToMeDB.enabled = TypeToMeDB.enabled ~= false
        TypeToMeDB.items = TypeToMeDB.items ~= false
		TypeToMeDB.showStats = TypeToMeDB.showStats ~= false
		TypeToMeDB.targetAccuracy = TypeToMeDB.targetAccuracy or 95
		
        targetAccuracy = TypeToMeDB.targetAccuracy
		
		print("TypeToMe loaded.")
        print(string.format(" | Quest typing: %s", TypeToMeDB.enabled and "ENABLED" or "DISABLED"))
        print(string.format(" | Item typing: %s", TypeToMeDB.items and "ENABLED" or "DISABLED"))
        print(string.format(" | Statistics: %s", TypeToMeDB.showStats and "ENABLED" or "DISABLED"))
		print(string.format(" | Target accuracy: %.2f%%", TypeToMeDB.targetAccuracy))
    end
end)

SLASH_TYPETOME1 = "/typetome"
SlashCmdList["TYPETOME"] = function(msg)
    msg = msg:lower()

    if msg == "default" then
        TypeToMeDB.enabled = true
        TypeToMeDB.items = true
        TypeToMeDB.targetAccuracy = 95
        TypeToMeDB.showStats = true
        targetAccuracy = 95
        userInput = ""
        typingStartTime, typingEndTime, totalTypingTime = nil, nil, nil
        print("TypeToMe settings reset to default.")
        return
    end

    if msg == "quests" then
        TypeToMeDB.enabled = not TypeToMeDB.enabled
        print("TypeToMe quests are now " .. (TypeToMeDB.enabled and "ENABLED" or "DISABLED"))
        resetEditBox()
        QuestInfoObjectivesHeader:Show()
        QuestInfoObjectivesText:Show()
		if QuestFrame:IsShown() and not TypeToMeDB.enabled then
			QuestFrameAcceptButton:Enable()
			QuestFrameCompleteQuestButton:Enable()
            QuestInfoRewardsFrame:Show()
			if textWidget then
                textWidget:SetText(questText)
			end
		end
        userInput = ""
        typingStartTime, typingEndTime, totalTypingTime = nil, nil, nil
        return
    end

    if msg == "items" then
        TypeToMeDB.items = not TypeToMeDB.items
        print("TypeToMe items are now " .. (TypeToMeDB.items and "ENABLED" or "DISABLED"))
        if ItemTextFrame:IsShown() and not TypeToMeDB.items then
            SetActiveTextWidget(ItemTextPageText)
            if textWidget then
                local blpText = ItemTextGetText()
                textWidget:SetText(blpText)
            end
        end
        userInput = ""
        typingStartTime, typingEndTime, totalTypingTime = nil, nil, nil
        return
    end

    if msg == "stats" then
        TypeToMeDB.showStats = not TypeToMeDB.showStats
        print("TypeToMe typing statistics are now " .. (TypeToMeDB.showStats and "ENABLED" or "DISABLED"))
        return
    end

    local newAccuracy = tonumber(msg)
    if newAccuracy then
        if newAccuracy < 0 or newAccuracy > 100 then
            print("Enter a value between 0 and 100")
            return
        end
        targetAccuracy = newAccuracy
        TypeToMeDB.targetAccuracy = targetAccuracy
        print(string.format("TypeToMe target accuracy set to %.2f%%", targetAccuracy))
        return
    end
	
    print("TypeToMe commands:")
    print(" | /typetome quests - Toggle quest typing on/off")
    print(" | /typetome items - Toggle item typing on/off")
    print(" | /typetome stats - Toggle statistics output on/off")
    print(" | /typetome <accuracy> - Set target accuracy (0–100)")
    print(" | /typetome default - Reset all settings")
	print("Current settings:")
	print(string.format(" | Quest typing: %s", TypeToMeDB.enabled and "ENABLED" or "DISABLED"))
    print(string.format(" | Item typing: %s", TypeToMeDB.items and "ENABLED" or "DISABLED"))
    print(string.format(" | Statistics: %s", TypeToMeDB.showStats and "ENABLED" or "DISABLED"))
	print(string.format(" | Target accuracy: %.2f%%", TypeToMeDB.targetAccuracy))
end