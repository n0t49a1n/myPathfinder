local initialized = false;
local MINIMAP_ICON = "Interface\\Icons\\ability_hunter_pathfinding"
local dbDefaults = {
    profile = {
        profileversion = 3,
        minimap = {
            hide = false,
            minimapPos = 180,
        }
    }
}
local LibQTip = LibStub('LibQTip-1.0');
local addon = LibStub("AceAddon-3.0"):NewAddon("MyPathfinder", "AceConsole-3.0");
local icon = LibStub("LibDBIcon-1.0");

-- Setup the Title Font. 14
local ssTitleFont = CreateFont("ssTitleFont")
ssTitleFont:SetTextColor(1,0.823529,0)

-- Setup the Header Font. 12
local ssHeaderFont = CreateFont("ssHeaderFont")
ssHeaderFont:SetTextColor(1,0.823529,0)

-- Setup the Regular Font. 12
local ssRegFont = CreateFont("ssRegFont")
ssRegFont:SetTextColor(1,0.823529,0)

local tooltip;
local LDB_ANCHOR;

local MyDO = LibStub("LibDataBroker-1.1"):NewDataObject("MyPathfinder", {
	type = "data source", 
	text = "Nothing to track!", 
	icon = MINIMAP_ICON,
}); --added ;

function addon:OnInitialize()
	
	self.db = LibStub("AceDB-3.0"):New("MyPathfinder", dbDefaults, true)
	output="";
	icon:Register("MyPathfinder", MyDO, self.db.profile.minimap)
		
	MyPathfinder.tStatus = {
	  [15514] = {
		Sum = 0,
		Count = 0,
		Percent = 0
	  },
	  [14790] = {
		Sum = 0,
		Count = 0,
		Percent = 0
	  } 	  	  
	}
	
	MyPathfinder.Status = {	-- 9.2
		[15514] = { -- Unlocking the Secrets
			Completed = false,
			Tab = 0,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "Status",
				[15224] = {-- 
					Completed = false,
					Tab = 2,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15513] = {-- 
					Completed = false,
					Tab = 2,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15515] = {-- 
					Completed = false,
					Tab = 2,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},	
				[15509] = {-- 
					Completed = false,
					Tab = 2,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15512] = {-- 
					Completed = false,
					Tab = 2,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15518] = {-- 
					Completed = false,
					Tab = 2,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},					
		},
		[14961] = { -- Chains of Domination
			Completed = false,
			Tab = 0,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "Status",
			skipAdd = true,					
		},
		[14790] = { -- Covenant Campaign
			Completed = false,
			Tab = 0,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "Status",			
		},
	}										
	
	
	MyPathfinder.GetColor = function (value)
		value = value * 2;
		local r = (2 - value);
		local g = value;
		local b = 0;
		
		if r > 1 then r = 1 end
		if g > 1 then g = 1 end
		if b > 1 then b = 1 end

		r = string.format("%i", r * 255);
		g = string.format("%i", g * 255);
		b = string.format("%i", b * 255);

		return "ff" .. string.format("%02x", r) .. string.format("%02x", g) .. string.format("%02x", b);
	end

	MyPathfinder.FilterAch = function(id)
		local _, name, _, completed, _, _, _, _, _, icon, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(id);		
		local quantity = 0
		local required = GetAchievementNumCriteria(id);
		local nQuantity = 0;		
		local nReqQuantity = 0;		

		if required > 0 then
			if ( required == 1 ) then
				nReqQuantity = select(5, GetAchievementCriteriaInfo(id, 1))
				nQuantity = select(4, GetAchievementCriteriaInfo(id, 1))
			end
			for index = 1, required do
				if select(3, GetAchievementCriteriaInfo(id, index)) == true then					
					quantity = quantity + 1;
				end
			end
		end
		return name, completed, icon, quantity, required, nReqQuantity, nQuantity, wasEarnedByMe, earnedBy;
	end

	MyPathfinder.IsFactionRevered = function(factionID)
		local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfoByID(factionID);

		local quantity = barValue;
		local required = 1;
		local nQuantity = barValue;		
		local nReqQuantity = 21000;	
		local icon = 237384;
		
		if barValue > 21000 then
			completed = true;
		else
			completed = false;
		end
		
		return name, completed, icon, quantity, required, nReqQuantity, nQuantity;
	end
	

	MyPathfinder.Traverse = function(table, key)
		local SubReqs = 0;
		local SubQuan = 0;
								
		for k, v in pairs(table) do
									
			if type(v) == "table" then
				
				table[k] = MyPathfinder.Traverse(v, k);

				if table[k].Faction then

					table[k].Name, table[k].Completed, table[k].Icon, table[k].Quantity, table[k].Required, table[k].nReqQuantity, table[k].nQuantity = MyPathfinder.IsFactionRevered(k);

				else

					table[k].Name, table[k].Completed, table[k].Icon, table[k].Quantity, table[k].Required, table[k].nReqQuantity, table[k].nQuantity, table[k].wasEarnedByMe, table[k].earnedBy = MyPathfinder.FilterAch(k);

					table[k].SubReqs = SubReqs + table[k].Required;
			
					if table[k].Completed then
						table[k].SubQuan = table[k].SubReqs;
					else
						table[k].SubQuan = SubQuan + table[k].Quantity;
					end
				end
			end
		end
		return table;
	end
	
	MyPathfinder.Sort = function(table)
		SortOrder = { [0] = 15514, [1] = 14790};

		for k1,v1 in ipairs(SortOrder) do
			for k2,v2 in pairs(table) do
				if v1 == k2 then				
					 return table[k2];
				end
			end
		end
						
	end

	MyPathfinder.GetTitlePercent = function (n, key)		
		local s;
		if n.Completed then
			s = 1;
		elseif n.Required == 0 then
			s = 0;
		else
			if (n.Required == 1 and n.nReqQuantity > 1) then				
				s = 1 * ( n.nQuantity / n.nReqQuantity);
			else
				s = 1 * (n.SubQuan / n.SubReqs);
			end			
		end		
		local Sum = s * 100;		
		MyPathfinder.tStatus[key].Sum = MyPathfinder.tStatus[key].Sum + Sum;
		MyPathfinder.tStatus[key].Count = MyPathfinder.tStatus[key].Count + 1;		
	end
	
	MyPathfinder.Reset = function ()
		SortOrder = { [0] = 15514, [1] = 14790};
		for soK,soV in ipairs(SortOrder) do
			MyPathfinder.tStatus[soV].Sum = 0;
			MyPathfinder.tStatus[soV].Count = 0;
		end
	end
	
	MyPathfinder.ProcessTitlePercent = function (item)						
		MyPathfinder.Reset();
		SortOrder = { [0] = 15514, [1] = 14790};
		for soK,soV in ipairs(SortOrder) do
			for iK,iV in pairs(item) do
				if soV == iK then
					MyPathfinder.TitlePercent(item[iK], soV)
				end
			end
		end
	end
	
	MyPathfinder.TitlePercent = function (item, key)	
		if type(item) == "table" then	
			if item.skipAdd then
				--Skipping loop item doesn't need to be added								
			else										
				if item.Name then
						MyPathfinder.GetTitlePercent(item, key);
				end
			end								
			for iK, iV in pairs(item) do
				MyPathfinder.TitlePercent(iV, key);
			end			
		end
	end
	
	MyPathfinder.GetPercent = function (n)		
		local s;
		if n.Completed then
			s = 1;
		elseif n.Required == 0 then
			s = 0;
		else
			if (n.Required == 1 and n.nReqQuantity > 1) then				
				s = 1 * ( n.nQuantity / n.nReqQuantity);
			else
				s = 1 * (n.SubQuan / n.SubReqs);
			end			
		end
		return "|c" .. MyPathfinder.GetColor(s) .. string.format("%#3.2f%%", s * 100) .. "|r";
	end
	
	MyPathfinder.ProcessTooltip = function (item)
						tooltip:AddLine("|cfff8b700World Of Warcraft: |cff6600CCShadowlands|r|n");	
						tooltip:AddLine("|cff00A2E8Patch 9.2 (Zereth Mortis)");
						MyPathfinder.Tooltip(item[15514]);
						tooltip:AddLine(" ");
						tooltip:AddLine("|cff00A2E8Patch 9.1 (The Shadowlands)");				
						--logic
						quest63639=C_QuestLog.IsQuestFlaggedCompleted(63639);
						quest64556=C_QuestLog.IsQuestFlaggedCompleted(64556);
						quest63902=C_QuestLog.IsQuestFlaggedCompleted(63902);					
						level = C_CovenantSanctumUI.GetRenownLevel();
						if level > 43 then
						tooltip:AddLine("|cff13ff29Renown (Reached Requiremnet)|r");
						elseif level > 30 and level < 44 then
						tooltip:AddLine("|cffffffffRenown Level|r","|cfff8b700" .. level .. "/44");
						elseif level > 20 and level < 30 then
						tooltip:AddLine("|cffffffffRenown Level|r","|cfff8b700" .. level .. "/44");
						elseif level > 0 and level < 20 then
						tooltip:AddLine("|cffffffffRenown Level|r","|cffff0000" .. level .. "/44");
						end
						MyPathfinder.Tooltip(item[14790]);	
						-- Battle of Ardenweald
						if quest63639 == true then
						tooltip:AddLine("|cff00A2E8Battle of Ardenweald (CH1)","|cff00ff00True|r|n|n");
						else
						tooltip:AddLine("|cff00A2E8Battle of Ardenweald (CH1)", "|cffff0000False|r|n|n");
						tooltip:AddLine("|cffffffff--The First Move", C_QuestLog.IsQuestFlaggedCompleted(63576));
						tooltip:AddLine("|cffffffff--A Gathering of Covenants", C_QuestLog.IsQuestFlaggedCompleted(63856));
						tooltip:AddLine("|cffffffff--Voices of the Eternal", C_QuestLog.IsQuestFlaggedCompleted(63857));
						tooltip:AddLine("|cffffffff--The Battle of Ardenweald", C_QuestLog.IsQuestFlaggedCompleted(63578));
						tooltip:AddLine("|cffffffff--Can't Turn Our Backs", C_QuestLog.IsQuestFlaggedCompleted(63638));
						tooltip:AddLine("|cffffffff--The Heart of Ardenweald", C_QuestLog.IsQuestFlaggedCompleted(63904));
						tooltip:AddLine("|cffffffff--Report to Oribos", C_QuestLog.IsQuestFlaggedCompleted(63639));
						end
						-- Maw Walkers
						if quest64556 == true then
						tooltip:AddLine("|cff00A2E8Maw Walkers (CH2)","|cff00ff00True|r|n|n");
						else
						tooltip:AddLine("|cff00A2E8Maw Walkers (CH2)", "|cffff0000False|r|n|n");
						tooltip:AddLine("|cffffffff--Opening the Maw", C_QuestLog.IsQuestFlaggedCompleted(63660));
						tooltip:AddLine("|cffffffff--Link to the Maw", C_QuestLog.IsQuestFlaggedCompleted(63661));
						tooltip:AddLine("|cffffffff--Mysteries of the Maw", C_QuestLog.IsQuestFlaggedCompleted(63662));
						tooltip:AddLine("|cffffffff--Korthia, the City of Secrets", C_QuestLog.IsQuestFlaggedCompleted(63663));
						tooltip:AddLine("|cffffffff--Who is the Maw Walker?", C_QuestLog.IsQuestFlaggedCompleted(63994));
						tooltip:AddLine("|cffffffff--Opening to Oribos", C_QuestLog.IsQuestFlaggedCompleted(63665));
						tooltip:AddLine("|cffffffff--Charge of the Covenants", C_QuestLog.IsQuestFlaggedCompleted(64007));
						tooltip:AddLine("|cffffffff--Surveying Secrets", C_QuestLog.IsQuestFlaggedCompleted(64555));
						tooltip:AddLine("|cffffffff--In Need of Assistance", C_QuestLog.IsQuestFlaggedCompleted(64556));
						end
						-- Focusing the Eye
						if quest63902 == true then
						tooltip:AddLine("|cff00A2E8Focusing the Eye (CH3)","|cff00ff00True|r|n|n");
						else
						tooltip:AddLine("|cff00A2E8Focusing the Eye (CH3)", "|cffff0000False|r|n|n");
						tooltip:AddLine("|cffffffff--A Show of Gratitude", C_QuestLog.IsQuestFlaggedCompleted(63848));
						tooltip:AddLine("|cffffffff--Ease of Passage", C_QuestLog.IsQuestFlaggedCompleted(63855));
						tooltip:AddLine("|cffffffff--Grab Bag", C_QuestLog.IsQuestFlaggedCompleted(63895));
						tooltip:AddLine("|cffffffff--Hearing Aid", C_QuestLog.IsQuestFlaggedCompleted(63849));
						tooltip:AddLine("|cffffffff--Birds of a Feather", C_QuestLog.IsQuestFlaggedCompleted(63810));
						tooltip:AddLine("|cffffffff--The Caged Bird", C_QuestLog.IsQuestFlaggedCompleted(63754));
						tooltip:AddLine("|cffffffff--Claim the Sky", C_QuestLog.IsQuestFlaggedCompleted(63764));
						tooltip:AddLine("|cffffffff--A Hate-Hate Relationship", C_QuestLog.IsQuestFlaggedCompleted(63811));
						tooltip:AddLine("|cffffffff--Fury Given Voice", C_QuestLog.IsQuestFlaggedCompleted(63831));
						tooltip:AddLine("|cffffffff--The Chosen Few", C_QuestLog.IsQuestFlaggedCompleted(63844));
						tooltip:AddLine("|cffffffff--Wrath of Odyn", C_QuestLog.IsQuestFlaggedCompleted(63845));
						tooltip:AddLine("|cffffffff--Mawsplaining", C_QuestLog.IsQuestFlaggedCompleted(64014));
						tooltip:AddLine("|cffffffff--Tears of the Damned", C_QuestLog.IsQuestFlaggedCompleted(63896));
						tooltip:AddLine("|cffffffff--Anger Management", C_QuestLog.IsQuestFlaggedCompleted(63867));
						tooltip:AddLine("|cffffffff--Focusing the Eye", C_QuestLog.IsQuestFlaggedCompleted(63901));
						tooltip:AddLine("|cffffffff--Good News, Everyone!", C_QuestLog.IsQuestFlaggedCompleted(63902));
						end	
						-- The Last Sigil
						if quest63727 == true then
						tooltip:AddLine("|cff00A2E8The Last Sigil (CH4)","|cff00ff00True|r|n|n");
						else
						tooltip:AddLine("|cff00A2E8The Last Sigil (CH4)", "|cffff0000False|r|n|n");
						tooltip:AddLine("|cffffffff--Vault of Secrets", C_QuestLog.IsQuestFlaggedCompleted(63703));
						tooltip:AddLine("|cffffffff--Vengeance for Korthia", C_QuestLog.IsQuestFlaggedCompleted(63704));
						tooltip:AddLine("|cffffffff--The Knowledge Keepers", C_QuestLog.IsQuestFlaggedCompleted(63705));
						tooltip:AddLine("|cffffffff--Let the Anima Flow", C_QuestLog.IsQuestFlaggedCompleted(63706));
						tooltip:AddLine("|cffffffff--Secrets of the Vault", C_QuestLog.IsQuestFlaggedCompleted(63709));
						tooltip:AddLine("|cffffffff--The Anima Trail", C_QuestLog.IsQuestFlaggedCompleted(63710));
						tooltip:AddLine("|cffffffff--Bone Tools", C_QuestLog.IsQuestFlaggedCompleted(63711));
						tooltip:AddLine("|cffffffff--Lost Records", C_QuestLog.IsQuestFlaggedCompleted(63712));
						tooltip:AddLine("|cffffffff--Hooking Over", C_QuestLog.IsQuestFlaggedCompleted(63713));
						tooltip:AddLine("|cffffffff--To the Vault", C_QuestLog.IsQuestFlaggedCompleted(63714));
						tooltip:AddLine("|cffffffff--Defending the Vault", C_QuestLog.IsQuestFlaggedCompleted(63717));
						tooltip:AddLine("|cffffffff--Keepers of Korthia", C_QuestLog.IsQuestFlaggedCompleted(63722));
						tooltip:AddLine("|cffffffff--Into the Vault", C_QuestLog.IsQuestFlaggedCompleted(63725));
						tooltip:AddLine("|cffffffff--Untangling the Sigil", C_QuestLog.IsQuestFlaggedCompleted(63726));
						tooltip:AddLine("|cffffffff--The Primus Returns (Get Flying Here)", C_QuestLog.IsQuestFlaggedCompleted(63727));
						end					
						
	end
	
	MyPathfinder.Tooltip = function (item)	
		if type(item) == "table" then
			
			if item.Name then
				
					local color = "|cffffffff";
					if item.Color then
						color = item.Color;
					end
					
					local sformat = false;
					if item.sFormat then
						sformat = item.sFormat;
					end
					
					local display = "None";
					if item.Display then
						display = item.Display;
					end

					local status = false;
					if item.Completed then
						status = true;
					end
					
					local ebo = false;
					if item.earnedBy then
						if item.earnedBy ~= "" then
							ebo = true;
						end
					end
					
					local ebm = false;
					if item.wasEarnedByMe then
						if item.wasEarnedByMe ~= "" then
							ebm = true;
						end
					end
					
					local Tab = 2;
					local spacing = "";
					if item.Tab then
						tab = item.Tab;
					end
					for i = 1, tab, 1 do
						spacing = spacing .. "   ";
					end
					

					
					if display == "None" then
						tooltip:AddLine(spacing .. color .. item.Name);
					elseif display == "Status" then
						if status == true then
							if item.HideEB then
								tooltip:AddLine(spacing .. color .. item.Name, GREEN_FONT_COLOR_CODE .. "Complete");
							else
								if ebo == true then
									tooltip:AddLine(spacing .. color .. item.Name, "|cff888888Earned By " .. item.earnedBy .. "|r " .. GREEN_FONT_COLOR_CODE .. "Complete");
								elseif ebm == true then
									myname, myrealm = UnitName("player");
									tooltip:AddLine(spacing .. color .. item.Name, "|cff888888Earned By " .. myname .. "|r " .. GREEN_FONT_COLOR_CODE .. "Complete");
								else
									tooltip:AddLine(spacing .. color .. item.Name, GREEN_FONT_COLOR_CODE .. "Complete");
								end
							end
						else
							tooltip:AddLine(spacing .. color .. item.Name, RED_FONT_COLOR_CODE .. "Incomplete");
						end		
					else
						if item.HideEB then
							tooltip:AddLine(spacing .. color .. item.Name, MyPathfinder.GetPercent(item));
						else
							if ebo == true then
								tooltip:AddLine(spacing .. color .. item.Name, "|cff888888Earned By " .. item.earnedBy .. "|r " .. GREEN_FONT_COLOR_CODE .. MyPathfinder.GetPercent(item));
							elseif ebm == true then
								myname, myrealm = UnitName("player");
								tooltip:AddLine(spacing .. color .. item.Name, "|cff888888Earned By " .. myname .. "|r " .. GREEN_FONT_COLOR_CODE .. MyPathfinder.GetPercent(item));
							else
								tooltip:AddLine(spacing .. color .. item.Name, MyPathfinder.GetPercent(item));
							end
						end		
					end							
			end
				
			for k, v in pairs(item) do				
					MyPathfinder.Tooltip(v);
			end
		end
	end
		


	MyPathfinder.Update = function()					
		local output = "";		
		MyPathfinder.Status = MyPathfinder.Traverse(MyPathfinder.Status);
		MyPathfinder.ProcessTitlePercent(MyPathfinder.Status);			
		local p = MyPathfinder.tStatus[15514].Sum / MyPathfinder.tStatus[15514].Count;
		output = " |cFFE77324B|r: " .. string.format("%#3.2f%%", p);
		MyDO.text = output;
	end	
	initialized = true;
	return true;
	
end

function MyDO:Hide()
      if tooltip then
	tooltip:Clear();
        tooltip:Release()
        tooltip = nil
      end
end

--Retrieve and return the players riding skill
function GetRidingSkill()
	for skillIndex = 1, GetNumSkillLines() do
		skillName, _, _, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(skillIndex)
		if skillName == L["Riding"] then
			return skillRank
		end
	end
end

function GameTooltip_SetBackdropStyle(self, style)
	self:SetBackdrop(style);
	self:SetBackdropBorderColor((style.backdropBorderColor or TOOLTIP_DEFAULT_COLOR):GetRGB());
	self:SetBackdropColor((style.backdropColor or TOOLTIP_DEFAULT_BACKGROUND_COLOR):GetRGB());

	if self.TopOverlay then
		if style.overlayAtlasTop then
			self.TopOverlay:SetAtlas(style.overlayAtlasTop, true);
			self.TopOverlay:SetScale(style.overlayAtlasTopScale or 1.0);
			self.TopOverlay:Show();
		else
			self.TopOverlay:Hide();
		end
	end

	if self.BottomOverlay then
		if style.overlayAtlasBottom then
			self.BottomOverlay:SetAtlas(style.overlayAtlasBottom, true);
			self.BottomOverlay:SetScale(style.overlayAtlasBottomScale or 1.0);
			self.BottomOverlay:Show();
		else
			self.BottomOverlay:Hide();
		end
	end

end

function MyDO:OnEnter()		
	MyDO:BuildToolTip(self);		
end

TOOLTIP_STYLE_TRANS = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
	tile = false,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = TOOLTIP_AZERITE_BACKGROUND_COLOR,
	overlayAtlasTop = "AzeriteTooltip-Topper";
	overlayAtlasTopScale = .75,
	overlayAtlasBottom = "AzeriteTooltip-Bottom";
};

TOOLTIP_STYLE_SOLID = {
	bgFile = "Interface\\Collections\\CollectionsBackgroundTile",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
	tile = false,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = TOOLTIP_AZERITE_BACKGROUND_COLOR,
	overlayAtlasTop = "AzeriteTooltip-Topper";
	overlayAtlasTopScale = .75,
	overlayAtlasBottom = "AzeriteTooltip-Bottom";
};

function MyDO:BuildToolTip(self)
	MyPathfinder.Update(); --Update data for tooltip		
	tooltip = LibQTip:Acquire("MyPathfinder", 2, "LEFT", "RIGHT");
	tooltip:Clear();	
				
	if (MyPathfinder.Config.Transparent == false) then
		GameTooltip_SetBackdropStyle(tooltip, TOOLTIP_STYLE_SOLID);
	else
		GameTooltip_SetBackdropStyle(tooltip, TOOLTIP_STYLE_TRANS);
	end	
				
	ssHeaderFont:SetFont(GameTooltipHeaderText:GetFont());
	ssRegFont:SetFont(GameTooltipText:GetFont());
	ssTitleFont:SetFont(GameTooltipText:GetFont());		
	tooltip:SetHeaderFont(ssHeaderFont);
	tooltip:SetFont(ssRegFont);		
	tooltip:SmartAnchorTo(self);
	tooltip:SetAutoHideDelay(0.25, self)										
	tooltip:AddHeader("|cffe5cc80MyPathfinder v" .. GetAddOnMetadata("MyPathfinder", "Version") .. "|r|n");		
	MyPathfinder.ProcessTooltip(MyPathfinder.Status);								
	tooltip:UpdateScrolling();
	tooltip:Show();			
end

local function EventHandler(self, event, ...)	
	if ( event == "VARIABLES_LOADED" and initialized == true ) then
		print("|cffe5cc80MyPathfinder v" .. GetAddOnMetadata("MyPathfinder", "Version") .. " Loaded!|r");	
	elseif ( event == "PLAYER_ENTERING_WORLD" and initialized == true ) then		
		MyPathfinder.Update();
	elseif (event == "UPDATE_FACTION" and initialized == true) then
		--print("UPDATE_FACTION");
		MyPathfinder.Update();
	elseif (event == "ACHIEVEMENT_EARNED" and initialized == true) then
		--print("ACHIEVEMENT_EARNED");
		MyPathfinder.Update();
	elseif (event == "CRITERIA_EARNED" and initialized == true) then
		--print("CRITERIA_EARNED");
		MyPathfinder.Update();
	end
end

local EventListener = CreateFrame("frame", "MyPathfinder");
EventListener:RegisterEvent("VARIABLES_LOADED");
EventListener:RegisterEvent("CRITERIA_EARNED");
EventListener:RegisterEvent("ACHIEVEMENT_EARNED");
EventListener:RegisterEvent("PLAYER_ENTERING_WORLD");
EventListener:RegisterEvent("UPDATE_FACTION");
EventListener:SetScript("OnEvent", EventHandler);
