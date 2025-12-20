TypeToMe = TypeToMe or {}
TypeToMe.Helpers = TypeToMe.Helpers or {}

function TypeToMe.Helpers.utf8ToTable(str)
    local t = {}
    for ch in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        t[#t+1] = ch
    end
    return t
end

function TypeToMe.Helpers.buildOutput(textChars, inputChars)
    local outputText = ""
    local correctCharacters = 0
    local incorrectCharacters = 0
    for i = 1, math.max(#textChars, #inputChars) do
        local expected = textChars[i] or " "
        local typed = inputChars[i] or ""
        if typed == "" then
            outputText = outputText .. "|cff555555" .. expected .. "|r"
        elseif typed == expected then
            outputText = outputText .. "|cff000000" .. expected .. "|r"
            correctCharacters = correctCharacters + 1
        else
            if expected == " " then
                outputText = outputText .. "|cffcc1111·|r"
            elseif expected == "\n" then
                outputText = outputText .. "|cffcc1111•|r\n"
            else
                outputText = outputText .. "|cffcc1111" .. expected .. "|r"
            end
            incorrectCharacters = incorrectCharacters + 1
        end
    end
    return outputText, correctCharacters, incorrectCharacters, inputChars
end

function TypeToMe.Helpers.normalizeText(text)
    if not text then return "" end
    return text
        :gsub("–", "-")
        :gsub("—", "-")
        :gsub("−", "-")
        :gsub("“", "\"")
        :gsub("”", "\"")
        :gsub("‘", "'")
        :gsub("’", "'")
        :gsub("…", "...")
        :gsub("|n", "\n")
        :gsub("\r", "\n")
        -- :gsub("\n\n", "\n") -- this fixes extra new lines in letters but breaks quests
        :gsub("\n\n+", "\n\n")
		
		--the following might not be the best idea
		:gsub("  ", " ")
		:gsub (" \n", "\n")
		-- :gsub ("\194\160", "\n")
end

function TypeToMe.Helpers.typingStats(totalTypingTime, incorrectCharacters, correctCharacters)
    if not TypeToMeDB or not TypeToMeDB.showStats then return end
    local totalChars = correctCharacters + incorrectCharacters
    local accuracy = totalChars > 0 and (correctCharacters / totalChars) * 100 or 0
    local wpm = totalTypingTime > 0 and (totalChars * 60) / (5 * totalTypingTime) or 0
    print(string.format(
        "%.2f words per minute (%d characters in %.2f seconds; %.2f%% accuracy).",
        wpm, totalChars, totalTypingTime, accuracy
    ))
end
