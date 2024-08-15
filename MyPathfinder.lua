--[[
MyPathfinder, a World of Warcraft Addon

Tracks your "Pathfinder" progress.
Support for Legion, Warlords of Draenor, Battle for Azeroth, Shadowlands, Dragonflight and War Within

Version:
3.9.0

License:
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
]]
local initialized = false
local MINIMAP_ICON = "Interface\\Icons\\ability_hunter_pathfinding"
local dbDefaults = {
    profile = {
        profileversion = 3,
        minimap = {
            hide = false,
            minimapPos = 180
        }
    }
}
local LibQTip = LibStub("LibQTip-1.0")
local addon = LibStub("AceAddon-3.0"):NewAddon("MyPathfinder", "AceConsole-3.0")
local icon = LibStub("LibDBIcon-1.0")

-- Setup the Title Font. 14
local ssTitleFont = CreateFont("ssTitleFont")
ssTitleFont:SetTextColor(1, 0.823529, 0)

-- Setup the Header Font. 12
local ssHeaderFont = CreateFont("ssHeaderFont")
ssHeaderFont:SetTextColor(1, 0.823529, 0)

-- Setup the Regular Font. 12
local ssRegFont = CreateFont("ssRegFont")
ssRegFont:SetTextColor(1, 0.823529, 0)

local tooltip
local LDB_ANCHOR

local MyDO =
    LibStub("LibDataBroker-1.1"):NewDataObject(
    "MyPathfinder",
    {
        type = "data source",
        text = "Nothing to track!",
        icon = MINIMAP_ICON,
        OnClick = function(self, button, ...)
            MyPathfinder_OnClick(self, button, ...)
        end
    }
)

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyPathfinder", dbDefaults, true)
    output = ""
    icon:Register("MyPathfinder", MyDO, self.db.profile.minimap)

    if not MyPathfinder.Config then
        MyPathfinder.Config = {}
    end
    if MyPathfinder.Config.ShowCompleted == nil then
        MyPathfinder.Config.ShowCompleted = false
    end
    if MyPathfinder.Config.Draenor == nil then
        MyPathfinder.Config.Draenor = false
    end
    if MyPathfinder.Config.Legion == nil then
        MyPathfinder.Config.Legion = false
    end
    if MyPathfinder.Config.Battle == nil then
        MyPathfinder.Config.Battle = false
    end
    if MyPathfinder.Config.Shadow == nil then
        MyPathfinder.Config.Shadow = false
    end
    if MyPathfinder.Config.Zereth == nil then
        MyPathfinder.Config.Zereth = false
    end
    if MyPathfinder.Config.Dragon == nil then
        MyPathfinder.Config.Dragon = false
    end
    if MyPathfinder.Config.War == nil then
        MyPathfinder.Config.War = true
    end
    local race = UnitRace("player")

    MyPathfinder.GetAchievementInfo = function(achievementID)
        local id,
            name,
            points,
            completed,
            month,
            day,
            year,
            description,
            flags,
            icon,
            rewardText,
            isGuild,
            wasEarnedByMe,
            earnedBy,
            isStatistic = GetAchievementInfo(achievementID)
        return completed
    end

    MyPathfinder.GetAchievementName = function(achievementID)
        local id,
            name,
            points,
            completed,
            month,
            day,
            year,
            description,
            flags,
            icon,
            rewardText,
            isGuild,
            wasEarnedByMe,
            earnedBy,
            isStatistic = GetAchievementInfo(achievementID)
        return name
    end
MyPathfinder.GetStorylineInfo = function(storylineID)
		local questLineName,
			questName,
			questLineID,
			questID,
			x,
			y,
			isHidden,
			isLegendary,
			isLocalStory,
			isDaily,
			isCampaign,
			isImportant,
			isAccountCompleted,
			isCombatAllyQuest,
			isMeta,
			inProgress,
			isQuestStart,
			floorLocation = C_QuestLine.GetQuestLineInfo(storylineID)
        return questLineName
    end				
				
    function IsCovenantQuestCompleted()
        local covenantID = C_Covenants.GetActiveCovenantID()
        local questID

        if covenantID == 1 then -- Kyrian
            questID = 62557
        elseif covenantID == 2 then -- Venthyr
            questID = 58407
        elseif covenantID == 3 then -- Night Fae
            questID = 60108
        elseif covenantID == 4 then -- Necrolord
            questID = 62406
        else
            return false -- No valid covenant found
        end

        return C_QuestLog.IsQuestFlaggedCompleted(questID) == true
    end

    function GetFactionRepDetails(factionIndex)
        local factionData = C_Reputation.GetFactionDataByID(factionIndex)
        -- Check if factionData is nil
        if not factionData then
            return "Neutral", "|cFF808080" -- Return a default value if data is nil
        end
        local reaction = factionData.reaction
        local text, color

        if reaction >= 7 then
            text = "Completed"
            color = "|cFF00FF00" -- Green
        elseif reaction == 6 then
            text = "Honored"
            color = "|cFFFFFF00" -- Yellow
        elseif reaction == 5 then
            text = "Friendly"
            color = "|cFFFF4500" -- Orange Red
        elseif reaction == 4 then
            text = "Neutral"
            color = "|cFF808080" -- Grey
        end

        return text, color
    end

    function GetColorForPercent(percent)
        if percent >= 100 then
            return "|cFF00FF00" -- Green
        elseif percent >= 90 then
            return "|cFF32CD32" -- Lime Green
        elseif percent >= 80 then
            return "|cFFADFF2F" -- Green Yellow
        elseif percent >= 60 then
            return "|cFFFFFF00" -- Yellow
        elseif percent >= 50 then
            return "|cFFFFD700" -- Gold
        elseif percent >= 40 then
            return "|cFFFFA500" -- Orange
        elseif percent >= 30 then
            return "|cFFFF4500" -- Orange Red
        else
            return "|cFF808080" -- Grey
        end
    end
    GetQuestName = function(questID)
        local name = C_QuestLog.GetTitleForQuestID(questID)
        if name then
            return name
        else
            return questID
        end
    end

    -- Function to get the quest completion status for a given quest ID
    GetQuestCompleted = function(questID)
        local complete = C_QuestLog.IsQuestFlaggedCompleted(questID)
        local status

        if complete then
            status = "|cFF00FF00Completed|r"
        else
            status = "|cFF808080Incomplete|r"
        end

        return status
    end

    function addQuestLines(quests)
        for i, questID in ipairs(quests) do
            tooltip:AddLine(
                string.format("-- |cffffffff%s", GetQuestName(questID)),
                string.format("%s|r", GetQuestCompleted(questID))
            )
        end
    end
    local faction = UnitFactionGroup("player")

    MyPathfinder.GetAchievementstatus = function(achievementID)
        local criteriaList = {} -- Table to hold all criteria info
        local totalCriteria = GetAchievementNumCriteria(achievementID) -- Get the total number of criteria for the achievement

        for i = 1, totalCriteria do
            local criteriaString, completed, quantity, reqQuantity, charName, criteriaID =
                GetAchievementCriteriaInfo(achievementID, i)
            local percent = 0

            if type(quantity) == "number" then
                if reqQuantity > 0 then
                    percent = (quantity / reqQuantity) * 100 -- Avoid division by zero
                end
            elseif quantity == true then
                percent = 100
            end

            table.insert(
                criteriaList,
                {
                    criteriaString = criteriaString,
                    percent = percent,
                    criteriaID = criteriaID
                }
            )
        end

        return criteriaList
    end

    MyPathfinder.ProcessTooltip = function(item)
        --
		-- WAR WITHIN
		--
		if MyPathfinder.Config.War then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cffDC143CWar Within|r|n|n")
            local tid = 40231
            local id = {40790, 20118, 20598, 19560, 19559}
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(tid)))
            if MyPathfinder.GetAchievementInfo(tid) == false or MyPathfinder.Config.ShowCompleted == true then
                for _, id in ipairs(id) do
                    tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                    local criteriaList = MyPathfinder.GetAchievementstatus(id)
                    for _, criteria in ipairs(criteriaList) do
                        local text
                        if criteria.percent == 100 then
                            text = "|cff00ff00Completed|r" -- Green color for "Completed"
                        else
                            local color = GetColorForPercent(criteria.percent)
                            text = string.format("%s%.0f%%|r", color, criteria.percent)
                        end
                        tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                    end
                end
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
        --
		-- DRAGONFLIGHT
		--
		elseif MyPathfinder.Config.Dragon then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cFF33937FDragonflight|r|n|n")
			local qid = 68795
			local tid = 19307
            local id = {16334, 15394, 16336, 16363, 17739, 16761, 17766, 19309}
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(tid)))
            if C_QuestLog.IsQuestFlaggedCompleted(qid) == false or MyPathfinder.Config.ShowCompleted == true then
                for _, id in ipairs(id) do
                    tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                    local criteriaList = MyPathfinder.GetAchievementstatus(id)
                    for _, criteria in ipairs(criteriaList) do
                        local text
                        if criteria.percent == 100 then
                            text = "|cff00ff00Completed|r" -- Green color for "Completed"
                        else
                            local color = GetColorForPercent(criteria.percent)
                            text = string.format("%s%.0f%%|r", color, criteria.percent)
                        end
                        tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                    end
                end
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
        --
		-- SHADOWLANDS
		--
		elseif MyPathfinder.Config.Shadow then
            --logic
            quest63639 = C_QuestLog.IsQuestFlaggedCompleted(63639)
            quest64556 = C_QuestLog.IsQuestFlaggedCompleted(64556)
            quest63902 = C_QuestLog.IsQuestFlaggedCompleted(63902)
            quest63949 = C_QuestLog.IsQuestFlaggedCompleted(63949)
            quest63727 = C_QuestLog.IsQuestFlaggedCompleted(63727)
            level = C_CovenantSanctumUI.GetRenownLevel()
            isKnown = IsSpellKnown(352177)
            isZereth = MyPathfinder.GetAchievementInfo(15514)
            covenantID = C_Covenants.GetActiveCovenantID()

            if covenantID == 1 then --kyrian
                if C_QuestLog.IsQuestFlaggedCompleted(62557) == true then
                    check1 = true
                end
            elseif covenantID == 2 then --venthyr
                if C_QuestLog.IsQuestFlaggedCompleted(58407) == true then
                    check1 = true
                end
            elseif covenantID == 3 then --nightfae
                if C_QuestLog.IsQuestFlaggedCompleted(60108) == true then
                    check1 = true
                end
            elseif covenantID == 4 then --necrolord
                if C_QuestLog.IsQuestFlaggedCompleted(62406) == true then
                    check1 = true
                end
            end

            -- check1 = MyPathfinder.GetAchievementInfo(14790);
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cFFA330C9Shadowlands|r|n|n")
            tooltip:AddLine("|cff00A2E8Patch 9.0.1 (The Shadowlands)")

            --start of requirements / guide / info section
            if MyPathfinder.GetAchievementInfo(15514) == false or MyPathfinder.Config.ShowCompleted == true then
                tooltip:AddLine("|cfff8b700Prerequisites")
				local chapterIsComplete = MyPathfinder.GetStorylineInfo(1219)
				tooltip:AddLine(tostring(chapterIsComplete))
                if level > 43 then
                    tooltip:AddLine("-- |cffffffffRenown", "|cff13ff29Completed|r")
                    check2 = true
                elseif level > 30 and level < 44 then
                    tooltip:AddLine("-- |cffffffffRenown", "|cfff8b700" .. level .. "/44")
                elseif level > 20 and level < 30 then
                    tooltip:AddLine("-- |cffffffffRenown", "|cfff8b700" .. level .. "/44")
                elseif level > 0 and level < 20 then
                    tooltip:AddLine("-- |cffffffffRenown", "|cffff0000" .. level .. "/44")
                end

                if check1 == true then
                    MyPathfinder.Tooltip(item[14790])
                else
                    tooltip:AddLine("-- |cffffffffCovenant Campaign", RED_FONT_COLOR_CODE .. "Incomplete")
                end

                tooltip:AddLine("|cfff8b700Chains of Domination Quest Line")

                -- Battle of Ardenweald
                if check1 == true and check2 == true then -- preq check
                    if quest63639 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("|cff00A2E8Battle of Ardenweald", GREEN_FONT_COLOR_CODE .. "Completed|r")
                    else
                        tooltip:AddLine("|cff00A2E8Battle of Ardenweald")
                        tooltip:AddLine("-- |cffffffffThe First Move", C_QuestLog.IsQuestFlaggedCompleted(63576))
                        tooltip:AddLine(
                            "-- |cffffffffA Gathering of Covenants",
                            C_QuestLog.IsQuestFlaggedCompleted(63856)
                        )
                        tooltip:AddLine("-- |cffffffffVoices of the Eternal", C_QuestLog.IsQuestFlaggedCompleted(63857))
                        tooltip:AddLine(
                            "-- |cffffffffThe Battle of Ardenweald",
                            C_QuestLog.IsQuestFlaggedCompleted(63578)
                        )
                        tooltip:AddLine("-- |cffffffffCan't Turn Our Backs", C_QuestLog.IsQuestFlaggedCompleted(63638))
                        tooltip:AddLine(
                            "-- |cffffffffThe Heart of Ardenweald",
                            C_QuestLog.IsQuestFlaggedCompleted(63904)
                        )
                        tooltip:AddLine("-- |cffffffffReport to Oribos", quest63639)
                    end
                else
                    tooltip:AddLine(
                        "-- |cffffffffBattle of Ardenweald",
                        RED_FONT_COLOR_CODE .. "Prerequisite InCompleted|r"
                    )
                end

                -- Maw Walkers
                if quest63639 == true and check2 then -- preq check
                    if quest64556 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("|cff00A2E8Maw Walkers", GREEN_FONT_COLOR_CODE .. "Completed|r")
                    else
                        tooltip:AddLine("|cff00A2E8Maw Walkers")
                        tooltip:AddLine("-- |cffffffffOpening the Maw", C_QuestLog.IsQuestFlaggedCompleted(63660))
                        tooltip:AddLine("-- |cffffffffLink to the Maw", C_QuestLog.IsQuestFlaggedCompleted(63661))
                        tooltip:AddLine("-- |cffffffffMysteries of the Maw", C_QuestLog.IsQuestFlaggedCompleted(63662))
                        tooltip:AddLine(
                            "-- |cffffffffKorthia, the City of Secrets",
                            C_QuestLog.IsQuestFlaggedCompleted(63663)
                        )
                        tooltip:AddLine(
                            "-- |cffffffffWho is the Maw Walker?",
                            C_QuestLog.IsQuestFlaggedCompleted(63994)
                        )
                        tooltip:AddLine("-- |cffffffffOpening to Oribos", C_QuestLog.IsQuestFlaggedCompleted(63665))
                        tooltip:AddLine(
                            "-- |cffffffffCharge of the Covenants",
                            C_QuestLog.IsQuestFlaggedCompleted(64007)
                        )
                        tooltip:AddLine("-- |cffffffffSurveying Secrets", C_QuestLog.IsQuestFlaggedCompleted(64555))
                        tooltip:AddLine("-- |cffffffffIn Need of Assistance", quest64556)
                    end
                else
                    tooltip:AddLine("-- |cffffffffMaw Walkers", RED_FONT_COLOR_CODE .. "Prerequisite InCompleted|r")
                end

                -- Focusing the Eye
                if quest64556 == true and quest63639 == true and check2 then -- preq check
                    if quest63902 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("-- |cff00A2E8Focusing the Eye", GREEN_FONT_COLOR_CODE .. "Completed|r")
                    else
                        tooltip:AddLine("-- |cff00A2E8Focusing the Eye")
                        tooltip:AddLine("-- |cffffffffA Show of Gratitude", C_QuestLog.IsQuestFlaggedCompleted(63848))
                        tooltip:AddLine("-- |cffffffffEase of Passage", C_QuestLog.IsQuestFlaggedCompleted(63855))
                        tooltip:AddLine("-- |cffffffffGrab Bag", C_QuestLog.IsQuestFlaggedCompleted(63895))
                        tooltip:AddLine("-- |cffffffffHearing Aid", C_QuestLog.IsQuestFlaggedCompleted(63849))
                        tooltip:AddLine("-- |cffffffffBirds of a Feather", C_QuestLog.IsQuestFlaggedCompleted(63810))
                        tooltip:AddLine("-- |cffffffffThe Caged Bird", C_QuestLog.IsQuestFlaggedCompleted(63754))
                        tooltip:AddLine("-- |cffffffffClaim the Sky", C_QuestLog.IsQuestFlaggedCompleted(63764))
                        tooltip:AddLine(
                            "-- |cffffffffA Hate-Hate Relationship",
                            C_QuestLog.IsQuestFlaggedCompleted(63811)
                        )
                        tooltip:AddLine("-- |cffffffffFury Given Voice", C_QuestLog.IsQuestFlaggedCompleted(63831))
                        tooltip:AddLine("-- |cffffffffThe Chosen Few", C_QuestLog.IsQuestFlaggedCompleted(63844))
                        tooltip:AddLine("-- |cffffffffWrath of Odyn", C_QuestLog.IsQuestFlaggedCompleted(63845))
                        tooltip:AddLine("-- |cffffffffMawsplaining", C_QuestLog.IsQuestFlaggedCompleted(64014))
                        tooltip:AddLine("-- |cffffffffTears of the Damned", C_QuestLog.IsQuestFlaggedCompleted(63896))
                        tooltip:AddLine("-- |cffffffffAnger Management", C_QuestLog.IsQuestFlaggedCompleted(63867))
                        tooltip:AddLine("-- |cffffffffFocusing the Eye", C_QuestLog.IsQuestFlaggedCompleted(63901))
                        tooltip:AddLine("-- |cffffffffGood News, Everyone!", quest63902)
                    end
                else
                    tooltip:AddLine(
                        "-- |cffffffffFocusing the Eye",
                        RED_FONT_COLOR_CODE .. "Prerequisite InCompleted|r"
                    )
                end

                if quest63902 == true then
                    tooltip:AddLine("|cfff8b700World Quests")
                    if quest63949 == true then
                        tooltip:AddLine("-- |cffffffffShaping Fate", GREEN_FONT_COLOR_CODE .. "Completed|r")
                        check3 = true
                    else
                        tooltip:AddLine("-- |cffffffffShaping Fate", RED_FONT_COLOR_CODE .. "Incomplete")
                    end

                    if covenantID == 1 then --kyrian
                        if C_QuestLog.IsQuestFlaggedCompleted(61982) == true then
                            tooltip:AddLine(
                                "-- |cffffffffReplenish the Reservoir",
                                GREEN_FONT_COLOR_CODE .. "Completed|r"
                            )
                        else
                            tooltip:AddLine("-- |cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    elseif covenantID == 2 then --venthyr
                        if C_QuestLog.IsQuestFlaggedCompleted(61981) == true then
                            tooltip:AddLine(
                                "-- |cffffffffReplenish the Reservoir",
                                GREEN_FONT_COLOR_CODE .. "Completed|r"
                            )
                        else
                            tooltip:AddLine("-- |cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    elseif covenantID == 3 then --nightfae
                        if C_QuestLog.IsQuestFlaggedCompleted(61984) == true then
                            tooltip:AddLine(
                                "-- |cffffffffReplenish the Reservoir",
                                GREEN_FONT_COLOR_CODE .. "Completed|r"
                            )
                        else
                            tooltip:AddLine("-- |cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    elseif covenantID == 4 then --necrolord
                        if C_QuestLog.IsQuestFlaggedCompleted(61983) == true then
                            tooltip:AddLine(
                                "-- |cffffffffReplenish the Reservoir",
                                GREEN_FONT_COLOR_CODE .. "Completed|r"
                            )
                        else
                            tooltip:AddLine("-- |cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    end
                else
                    tooltip:AddLine("|cfff8b700World Quests")
                    tooltip:AddLine("-- |cffffffffShaping Fate", RED_FONT_COLOR_CODE .. "Prerequisite Incomplete")
                    tooltip:AddLine(
                        "-- |cffffffffReplenish the Reservoir",
                        RED_FONT_COLOR_CODE .. "Prerequisite Incomplete"
                    )
                end

                tooltip:AddLine("|cfff8b700Chains of Domination Quest Line (Continued)")

                -- The Last Sigil
                if
                    quest63902 == true and quest64556 == true and quest63639 == true and check1 and check2 or
                        MyPathfinder.Config.ShowCompleted == true
                 then -- preq check
                    if quest63727 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("|cff00A2E8The Last Sigil", GREEN_FONT_COLOR_CODE .. "Completed|r")
                    else
                        tooltip:AddLine("|cff00A2E8The Last Sigil")
                        tooltip:AddLine("-- |cffffffffVault of Secrets", C_QuestLog.IsQuestFlaggedCompleted(63703))
                        tooltip:AddLine("-- |cffffffffVengeance for Korthia", C_QuestLog.IsQuestFlaggedCompleted(63704))
                        tooltip:AddLine("-- |cffffffffThe Knowledge Keepers", C_QuestLog.IsQuestFlaggedCompleted(63705))
                        tooltip:AddLine("-- |cffffffffLet the Anima Flow", C_QuestLog.IsQuestFlaggedCompleted(63706))
                        tooltip:AddLine("-- |cffffffffSecrets of the Vault", C_QuestLog.IsQuestFlaggedCompleted(63709))
                        tooltip:AddLine("-- |cffffffffThe Anima Trail", C_QuestLog.IsQuestFlaggedCompleted(63710))
                        tooltip:AddLine("-- |cffffffffBone Tools", C_QuestLog.IsQuestFlaggedCompleted(63711))
                        tooltip:AddLine("-- |cffffffffLost Records", C_QuestLog.IsQuestFlaggedCompleted(63712))
                        tooltip:AddLine("-- |cffffffffHooking Over", C_QuestLog.IsQuestFlaggedCompleted(63713))
                        tooltip:AddLine("-- |cffffffffTo the Vault", C_QuestLog.IsQuestFlaggedCompleted(63714))
                        tooltip:AddLine("-- |cffffffffDefending the Vault", C_QuestLog.IsQuestFlaggedCompleted(63717))
                        tooltip:AddLine("-- |cffffffffKeepers of Korthia", C_QuestLog.IsQuestFlaggedCompleted(63722))
                        tooltip:AddLine("-- |cffffffffInto the Vault", C_QuestLog.IsQuestFlaggedCompleted(63725))
                        tooltip:AddLine("-- |cffffffffUntangling the Sigil", C_QuestLog.IsQuestFlaggedCompleted(63726))
                        tooltip:AddLine("-- |cffffffffThe Primus Returns (Get Flying Here)", quest63727)

                        if quest63727 == true then
                            tooltip:AddLine("|cfff8b700Item")
                            tooltip:AddLine("|cffffffffMemories of Sunless Skies", "|cffffffffUnused|r")
                        end
                    end
                else
                    tooltip:AddLine("|cffffffffThe Last Sigil", RED_FONT_COLOR_CODE .. "Prerequisite InCompleted|r")
                end
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
        --
		-- SHADOWLANDS ZERATH MORTIS
		--
		elseif MyPathfinder.Config.Zereth then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cFFE77324Zereth Mortis|r|n|n")
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(19307)))
            local achievementIDs = {15224, 15509, 15513, 15512, 15515, 15518}

            for _, id in ipairs(achievementIDs) do
                tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                local criteriaList = MyPathfinder.GetAchievementstatus(id)
                for _, criteria in ipairs(criteriaList) do
                    local text
                    if criteria.percent == 100 then
                        text = "|cff00ff00Completed|r" -- Green color for "Completed"
                    else
                        local color = GetColorForPercent(criteria.percent)
                        text = string.format("%s%.0f%%|r", color, criteria.percent)
                    end
                    tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                end
            end
        --
		-- BATTLE FOR AZEROTH
		--
		elseif MyPathfinder.Config.Battle then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cFFE77324Battle for Azeroth|r|n|n")
            local tid = 12989
            local aid = {12988, 13144, 12510, 12593, 12947} --Alliance
            local hid = {12988, 13144, 12509, 12479, 12947} --Horde
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(tid)))
            if MyPathfinder.GetAchievementInfo(13250) == false or MyPathfinder.Config.ShowCompleted == true then
                if faction == "Alliance" then
                    xid = aid
                else
                    xid = hid
                end

                for _, id in ipairs(xid) do
                    tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                    local criteriaList = MyPathfinder.GetAchievementstatus(id)
                    for _, criteria in ipairs(criteriaList) do
                        local text
                        if criteria.percent == 100 then
                            text = "|cff00ff00Completed|r" -- Green color for "Completed"
                        else
                            local color = GetColorForPercent(criteria.percent)
                            text = string.format("%s%.0f%%|r", color, criteria.percent)
                        end
                        tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                    end
                end
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
			tooltip:AddLine(" ")
			local tid = 13250
            local id = {12989, 13776, 13712}
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(tid)))
            if MyPathfinder.GetAchievementInfo(13250) == false or MyPathfinder.Config.ShowCompleted == true then
                for _, id in ipairs(id) do
                    tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                    local criteriaList = MyPathfinder.GetAchievementstatus(id)
                    for _, criteria in ipairs(criteriaList) do
                        local text
                        if criteria.percent == 100 then
                            text = "|cff00ff00Completed|r" -- Green color for "Completed"
                        else
                            local color = GetColorForPercent(criteria.percent)
                            text = string.format("%s%.0f%%|r", color, criteria.percent)
                        end
                        tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                    end
                end
				tooltip:AddLine("|cfff8b700Nazjatar Reputations|r")
                local text, color = GetFactionRepDetails(2373)
                tooltip:AddLine("-- |cffffffff Earn Revered status with the The Unshackled|r", color .. text)
                local text, color = GetFactionRepDetails(2400)
                tooltip:AddLine("-- |cffffffff Earn Revered status with the Waveblade Ankoan|r", color .. text)
				
				tooltip:AddLine("|cfff8b700Rustbolt Resistance Reputation|r")
                local text, color = GetFactionRepDetails(2391)
                tooltip:AddLine("-- |cffffffff Earn Revered status with the Rustbolt Resistance|r", color .. text)
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
        --
		-- LEGION
		--
		elseif MyPathfinder.Config.Legion then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cff13ff29Legion|r (Legacy)|n|n")
            local tid = 11190
            local id = {11188, 11189, 11157, 10672}
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(tid)))
            if MyPathfinder.GetAchievementInfo(tid) == false or MyPathfinder.Config.ShowCompleted == true then
                for _, id in ipairs(id) do
                    tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                    local criteriaList = MyPathfinder.GetAchievementstatus(id)
                    for _, criteria in ipairs(criteriaList) do
                        local text
                        if criteria.percent == 100 then
                            text = "|cff00ff00Completed|r" -- Green color for "Completed"
                        else
                            local color = GetColorForPercent(criteria.percent)
                            text = string.format("%s%.0f%%|r", color, criteria.percent)
                        end
                        tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                    end
                end

                local id = 10994
                tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                local criteria = MyPathfinder.GetAchievementstatus(10746)
                local text
                if criteria and criteria.percent == 100 then
                    text = "|cff00ff00Completed|r"
                else
                    local color = GetColorForPercent(criteria.percent or 0)
                    text = string.format("%s%.0f%%|r", color, criteria.percent or 0)
                end
                tooltip:AddLine("-- |cffffffff Complete your class Order Campaign", text)
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
            tooltip:AddLine(" ")
            local tid = 11446
            local id = {11190, 11543}
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(tid)))
            if MyPathfinder.GetAchievementInfo(tid) == false or MyPathfinder.Config.ShowCompleted == true then
                for _, id in ipairs(id) do
                    tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                    local criteriaList = MyPathfinder.GetAchievementstatus(id)
                    for _, criteria in ipairs(criteriaList) do
                        local text
                        if criteria.percent == 100 then
                            text = "|cff00ff00Completed|r" -- Green color for "Completed"
                        else
                            local color = GetColorForPercent(criteria.percent)
                            text = string.format("%s%.0f%%|r", color, criteria.percent)
                        end
                        tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                    end
                end
                tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(11545)))
                local text, color = GetFactionRepDetails(2045)
                tooltip:AddLine("-- |cffffffff Earn Revered status with the Armies of Legionfall|r", color .. text)
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
        --
		-- DRAENOR
		--
		elseif MyPathfinder.Config.Draenor then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cffe53101Warlords of Draenor|r (Legacy)|n|n")
            local tid = 10018
            local aid = {8935, 10348, 9564, 10350, 9833} --Alliance
            local hid = {8935, 10348, 9562, 10349, 9923} --Horde
            tooltip:AddLine(string.format("|cff00A2E8%s|r", MyPathfinder.GetAchievementName(tid)))
            if MyPathfinder.GetAchievementInfo(tid) == false or MyPathfinder.Config.ShowCompleted == true then
                if faction == "Alliance" then
                    xid = aid
                else
                    xid = hid
                end

                for _, id in ipairs(xid) do
                    tooltip:AddLine(string.format("|cfff8b700%s|r", MyPathfinder.GetAchievementName(id)))
                    local criteriaList = MyPathfinder.GetAchievementstatus(id)
                    for _, criteria in ipairs(criteriaList) do
                        local text
                        if criteria.percent == 100 then
                            text = "|cff00ff00Completed|r" -- Green color for "Completed"
                        else
                            local color = GetColorForPercent(criteria.percent)
                            text = string.format("%s%.0f%%|r", color, criteria.percent)
                        end
                        tooltip:AddLine(string.format("-- |cffffffff%s ", criteria.criteriaString or "Unknown"), text)
                    end
                end
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
        end
    end

    MyPathfinder.Tooltip = function(item)
        if type(item) == "table" then
            if item.Name then
                local color = "|cffffffff"
                if item.Color then
                    color = item.Color
                end

                local sformat = false
                if item.sFormat then
                    sformat = item.sFormat
                end

                local display = "None"
                if item.Display then
                    display = item.Display
                end

                local status = false
                if item.Completed then
                    status = true
                end

                local ebo = false
                if item.earnedBy then
                    if item.earnedBy ~= "" then
                        ebo = true
                    end
                end

                local ebm = false
                if item.wasEarnedByMe then
                    if item.wasEarnedByMe ~= "" then
                        ebm = true
                    end
                end

                local tab = 3
                local spacing = ""
                if item.Tab then
                    tab = item.Tab
                end

                for i = 1, tab, 1 do
                    spacing = spacing .. "   "
                end
            end

            for k, v in pairs(item) do
                MyPathfinder.Tooltip(v)
            end
        end
    end

    MyPathfinder.Update = function()
        local output = ""
        if MyPathfinder.Config.War then
            local p = MyPathfinder.tStatus[40231].Sum
            output = " |cffe333333|r: " .. string.format("%#3.2f%%", p)
        end

        if MyPathfinder.Config.Dragon then
            local p = MyPathfinder.tStatus[15794].Sum
            output = " |cffe333333|r: " .. string.format("%#3.2f%%", p)
        end

        if MyPathfinder.Config.Zereth then
            local p =
                (MyPathfinder.tStatus[15514].Sum + MyPathfinder.tStatus[14790].Sum) /
                (MyPathfinder.tStatus[15514].Count + MyPathfinder.tStatus[14790].Count)
            output = " |cFFE77324B|r: " .. string.format("%#3.2f%%", p)
        end

        if MyPathfinder.Config.Shadow then
            local p =
                (MyPathfinder.tStatus[15514].Sum + MyPathfinder.tStatus[14790].Sum) /
                (MyPathfinder.tStatus[15514].Count + MyPathfinder.tStatus[14790].Count)
            output = " |cFFE77324B|r: " .. string.format("%#3.2f%%", p)
        end

        if MyPathfinder.Config.Battle then
            local p =
                (MyPathfinder.tStatus[13250].Sum + MyPathfinder.tStatus[12989].Sum) /
                (MyPathfinder.tStatus[13250].Count + MyPathfinder.tStatus[12989].Count)
            output = " |cFFE77324B|r: " .. string.format("%#3.2f%%", p)
        end

        if MyPathfinder.Config.Legion then
            local p =
                (MyPathfinder.tStatus[11446].Sum + MyPathfinder.tStatus[11190].Sum) /
                (MyPathfinder.tStatus[11446].Count + MyPathfinder.tStatus[11190].Count)
            output = " |cff13ff29L|r: " .. string.format("%#3.2f%%", p)
        end

        if MyPathfinder.Config.Draenor then
            local p = MyPathfinder.tStatus[10018].Sum / MyPathfinder.tStatus[10018].Count
            output = " |cffe53101D|r: " .. string.format("%#3.2f%%", p)
        end

        MyDO.text = output
    end

    initialized = true

    return true
end

function MyDO:Hide()
    if tooltip then
        tooltip:Clear()
        tooltip:Release()
        tooltip = nil
    end
end

function MyPathfinder_OnClick(self, button, ...)
    if button == "LeftButton" then
        tooltip:Release()
        tooltip = nil

        -- List of configuration states
        local configStates = {"War", "Dragon", "Shadow", "Zereth", "Battle", "Legion", "Draenor"}

        -- Find the current active state
        local currentIndex
        for i, state in ipairs(configStates) do
            if MyPathfinder.Config[state] == true then
                currentIndex = i
                break
            end
        end

        -- Set all states to false
        for _, state in ipairs(configStates) do
            MyPathfinder.Config[state] = false
        end

        -- Activate the next state
        local nextIndex = (currentIndex % #configStates) + 1
        MyPathfinder.Config[configStates[nextIndex]] = true

        MyDO:BuildToolTip(self)
    elseif button == "RightButton" then
        tooltip:Release()
        tooltip = nil

        -- Toggle the ShowCompleted flag
        MyPathfinder.Config.ShowCompleted = not MyPathfinder.Config.ShowCompleted

        MyDO:BuildToolTip(self)
    end
end

function GameTooltip_SetBackdropStyle(self, style)
    if self.TopOverlay then
        if style.overlayAtlasTop then
            self.TopOverlay:SetAtlas(style.overlayAtlasTop, true)
            self.TopOverlay:SetScale(style.overlayAtlasTopScale or 1.0)
            self.TopOverlay:Show()
        else
            self.TopOverlay:Hide()
        end
    end

    if self.BottomOverlay then
        if style.overlayAtlasBottom then
            self.BottomOverlay:SetAtlas(style.overlayAtlasBottom, true)
            self.BottomOverlay:SetScale(style.overlayAtlasBottomScale or 1.0)
            self.BottomOverlay:Show()
        else
            self.BottomOverlay:Hide()
        end
    end
end

function MyDO:OnEnter()
    MyDO:BuildToolTip(self)
end

TOOLTIP_STYLE_TRANS = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
    tile = false,
    tileEdge = false,
    tileSize = 16,
    edgeSize = 19,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
    backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
    backdropColor = TOOLTIP_AZERITE_BACKGROUND_COLOR,
    overlayAtlasTop = "AzeriteTooltip-Topper",
    overlayAtlasTopScale = .75,
    overlayAtlasBottom = "AzeriteTooltip-Bottom"
}

TOOLTIP_STYLE_SOLID = {
    bgFile = "Interface\\Collections\\CollectionsBackgroundTile",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
    tile = false,
    tileEdge = false,
    tileSize = 16,
    edgeSize = 19,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
    backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
    backdropColor = TOOLTIP_AZERITE_BACKGROUND_COLOR,
    overlayAtlasTop = "AzeriteTooltip-Topper",
    overlayAtlasTopScale = .75,
    overlayAtlasBottom = "AzeriteTooltip-Bottom"
}

function MyDO:BuildToolTip(self)
    MyPathfinder.Update() --Update data for tooltip
    tooltip = LibQTip:Acquire("MyPathfinder", 2, "LEFT", "RIGHT")
    tooltip:Clear()

    if (MyPathfinder.Config.Transparent == false) then
        GameTooltip_SetBackdropStyle(tooltip, TOOLTIP_STYLE_SOLID)
    else
        GameTooltip_SetBackdropStyle(tooltip, TOOLTIP_STYLE_TRANS)
    end

    ssHeaderFont:SetFont(GameTooltipHeaderText:GetFont())
    ssRegFont:SetFont(GameTooltipText:GetFont())
    ssTitleFont:SetFont(GameTooltipText:GetFont())
    tooltip:SetHeaderFont(ssHeaderFont)
    tooltip:SetFont(ssRegFont)
    tooltip:SmartAnchorTo(self)
    tooltip:SetAutoHideDelay(0.25, self)
    tooltip:AddHeader("|cffe5cc80MyPathfinder|r|n")

    MyPathfinder.ProcessTooltip(MyPathfinder.Status)

    tooltip:AddLine(
        "|n|cffffffffLeft Click|r to toggle between War Within, Dragonflight, Shadowlands, BFA, WOD, and Legion "
    )

    if MyPathfinder.Config.ShowCompleted == false then
        tooltip:AddLine("|n|cffffffffRight Click|r to |cff00ff00Show|r Completed Requirements")
    else
        tooltip:AddLine("|n|cffffffffRight Click|r to " .. RED_FONT_COLOR_CODE .. "Hide|r Completed Requirements")
    end

    tooltip:UpdateScrolling()
    tooltip:Show()
end

local function EventHandler(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD" and initialized == true) then
        MyPathfinder.Update()
    elseif (event == "UPDATE_FACTION" and initialized == true) then
        --print("UPDATE_FACTION");
        MyPathfinder.Update()
    elseif (event == "ACHIEVEMENT_EARNED" and initialized == true) then
        --print("ACHIEVEMENT_EARNED");
        MyPathfinder.Update()
    elseif (event == "CRITERIA_EARNED" and initialized == true) then
        --print("CRITERIA_EARNED");
        MyPathfinder.Update()
    end
end

local EventListener = CreateFrame("frame", "MyPathfinder")
EventListener:RegisterEvent("VARIABLES_LOADED")
EventListener:RegisterEvent("CRITERIA_EARNED")
EventListener:RegisterEvent("ACHIEVEMENT_EARNED")
EventListener:RegisterEvent("PLAYER_ENTERING_WORLD")
EventListener:RegisterEvent("UPDATE_FACTION")
EventListener:SetScript("OnEvent", EventHandler)
