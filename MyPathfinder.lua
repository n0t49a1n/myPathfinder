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
	OnClick = function(self, button, ...)
		MyPathfinder_OnClick(self,button,...);
	end,
}); --added ;

function addon:OnInitialize()
	
	self.db = LibStub("AceDB-3.0"):New("MyPathfinder", dbDefaults, true)

	icon:Register("MyPathfinder", MyDO, self.db.profile.minimap)

	if not MyPathfinder.Config then
		MyPathfinder.Config = {}
	end	
	if not MyPathfinder.Config.Transparent then
		MyPathfinder.Config.Transparent = true;
	end	
	if MyPathfinder.Config.ShowCompleted == nil then
		MyPathfinder.Config.ShowCompleted = true
	end
	if MyPathfinder.Config.Draenor == nil then
		MyPathfinder.Config.Draenor = false
	end
	if MyPathfinder.Config.Legion == nil then
		MyPathfinder.Config.Legion = false
	end
	if MyPathfinder.Config.Battle == nil then
		MyPathfinder.Config.Battle = true
	end
	if MyPathfinder.Config.Shadow == nil then
		MyPathfinder.Config.Shadow = true
	end
			
	MyPathfinder.tStatus = {
	  [14790] = {
		Sum = 0,
		Count = 0,
		Percent = 0
	  },
	  [13250] = {
	  	Sum = 0,
	  	Count = 0,
	  	Percent = 0
	  },	
	  [12989] = {
	  	Sum = 0,
	  	Count = 0,
	  	Percent = 0
	  },	  
	  [11446] = {
	  	Sum = 0,
	  	Count = 0,
	  	Percent = 0
	  },	  
	  [11190] = {
	  	Sum = 0,
	  	Count = 0,
	  	Percent = 0
	  },	  
	  [10018] = {
	  	Sum = 0,
	  	Count = 0,
	  	Percent = 0
	  }	  	  	  
	}
	
	MyPathfinder.Status = {	
		[15514] = { -- Unlocking the Secrets
			Completed = false,
			Tab = 0,
			Color = "|cffffffff",
			sFormat = true,
			Display = "None",
			skipAdd = true,
				[15224] = {-- 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15513] = {-- 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15515] = {-- 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},	
				[15509] = {-- 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15512] = {-- 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[15518] = {-- 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},					
		},
		[14961] = { -- Chains of Domination
			Completed = false,
			Tab = 0,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			skipAdd = true,					
		},
		[14790] = { -- Covenant Campaign
			Completed = false,
			Tab = 0,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",			
		},
	[12989] = {-- Battle for Azeroth MyPathfinder, Part One
			Completed = false,
			Tab = 1,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "None",
			skipAdd = true,
			
			
			[12988] = {-- Battle for Azeroth Explorer
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[12556] = {-- Explore Tiragarde Sound
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[12558] = {-- Explore Stormsong Valley
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[12561] = {-- Explore Nazmir
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[12557] = {-- Explore Drustvar
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[12559] = {-- Explore Zuldazar
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[12560] = {-- Explore Vol'dun
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				}, 
			
			},	
			[13144] = {-- Wide World of Quests (NYI)
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[13144] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
			
		},
		
		[13250] = {-- Battle for Azeroth MyPathfinder, Part Two
			Completed = false,
			Tab = 1,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "None",
			Header = true,
			skipAdd = true,
			
			[12989] = {-- Battle for Azeroth Part One
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",	
				skipAdd = true,
				[12989] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},		
			},	
			
			[13712] = {-- Explore Nazjatar
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",	
				[13712] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},			
			},
			
			[13776] = {-- Explore Mechagon
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",	
				[13776] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},			
			},
			
			[2391] = {-- Rustbolt Resistance
				Faction = true,
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",	
				[2391] = {
					Faction = true,
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},			
			},
			
		},
						
		[11190] = { --Broken Isles MyPathfinder, Part One
			Completed = false,
			Tab = 1,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "None",
			skipAdd = true,
			
			[11188] = { -- Broken Isles Explorer
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[10665] = { -- Explore Azsuna
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[10667] = { -- Explore Highmountain
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[10669] = { -- Explore Suramar
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[10668] = { -- Explore Stormheim
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[10666] = { -- Explore Val'sharah
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
			[11157] = { --Loremaster of Legion
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[10059] = { --Ain't No Mountain High Enough
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[10763] = { -- Azsuna Matata
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[11124] = { -- Good Suramaritan
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[10698] = { -- That's Val'sharah Folks!
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[10790] = { -- Vrykul Story, Bro
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
			[10994] = { --A Glorious Campaign
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[10994] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "None",
					skipAdd = true,
				},
			},
			[11189] = { -- Variety is the Spice of Life
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[11189] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
			[10672] = { -- Broken Isles Diplomat
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[1900] = {
					Faction = true, 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[1828] = {
					Faction = true, 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[1859] = {
					Faction = true, 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[1883] = {
					Faction = true, 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
					[1948] = {
					Faction = true, 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[1894] = {
					Faction = true, 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			}, 
		},
		[11446] = { -- Broken Isles MyPathfinder, Part Two
			Completed = false,
			Tab = 1,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "None",
			Header = true;
			skipAdd = true,
			[11543] = { -- Explore Broken Shore
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[11543] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
			[11545] = { -- Legionfall Commander
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[2045] = {
					Faction = true, 
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
			[11190] = {
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				skipAdd = true,
				[11190] = {
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			}, 
			
		},
		[10018] = { -- Draenor MyPathfinder
			Completed = false,
			Tab = 1,
			Color = "|cff00A2E8",
			sFormat = true,
			Display = "None",
			skipAdd = true,
			[8935] = { -- Draenor Explorer
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[8937] = { -- Explore Frostfire Ridge
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[8939] = { -- Explore Gorgrond
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[8942] = { -- Explore Nagrand
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[8938] = { -- Explore Shadowmoon Valley
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[8941] = { -- Explore Spires of Arak
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[8940] = { -- Explore Talador
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
			[10348] = { -- Master Treasure Hunter
				Completed = false,
				Tab = 2,
				Color = "|cffffffff",
				sFormat = true,
				Display = "Status",
				[10348] = { -- Master Treasure Hunter
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[9727] = { -- Expert Treasure Hunter
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
				[9726] = { -- Treasure Hunter
					Completed = false,
					Tab = 3,
					Color = "|cfff8b700",
					sFormat = false,
					Display = "Percent",
					skipAdd = true,
				},
			},
		},
	}

	if UnitFactionGroup("player") == "Alliance" then
		
		MyPathfinder.Status[12989][12593] = {-- Kul Tourist
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[12473] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[12497] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[12496] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
		
		MyPathfinder.Status[12989][12947] = { -- Azerothian Diplomat
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[2159] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2164] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2161] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2160] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2162] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2163] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
				},
		}
		
		MyPathfinder.Status[12989][12510] = {-- Ready for War
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[12510] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
		
		MyPathfinder.Status[13250][2400] = { -- Waveblade Ankoan
			Faction = true,
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[2400] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
		
		MyPathfinder.Status[10018][9833] = { -- Alliance Loremaster
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[8845] = { -- As I Walk Throug the Valley of the Shadow of Moon
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8920] = { -- Don't Let the Tala-door Hit You on the Way Out
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8927] = { -- Nagrandeur
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8923] = { -- Putting the Gore in Gorgrond
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8925] = { -- Between Arak and a Hard Place
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			}
		}
		
		MyPathfinder.Status[10018][9564] = { -- Securing Draenor
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[9564] = { 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
						
		MyPathfinder.Status[10018][10350] = { -- Tanaan Diplomat
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[1849] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[1850] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[1847] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
										
	elseif UnitFactionGroup("player") == "Horde" then
		
		MyPathfinder.Status[12989][12479] = {-- Zandalar Forever!
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[12480] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[12478] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[11868] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[12481] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Status",
				skipAdd = true,
			},
			[11861] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			
		}
		
		MyPathfinder.Status[12989][12947] = { -- Azerothian Diplomat
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[2164] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2156] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2157] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2163] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2158] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[2103] = { 
				Faction = true, 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
		
		MyPathfinder.Status[12989][12509] = {-- Ready for War
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[12509] = {
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
								
		MyPathfinder.Status[13250][2373] = { -- The Unshackled
			Faction = true,
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[2373] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
		
		MyPathfinder.Status[10018][9923] = { -- Horde Loremaster
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[8671] = { -- You'll Get Caught Up In The... Frostfire!
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8919] = { -- Don't Let the Tala-door Hit You on the Way Out
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8928] = { -- Nagrandeur
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8924] = { -- Putting the Gore in Gorgrond
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[8926] = { -- Between Arak and a Hard Place
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			}
		}
		
		MyPathfinder.Status[10018][9562] = { -- Securing Draenor
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[9562] = { 
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
		
		MyPathfinder.Status[10018][10349] = { -- Tanaan Diplomat
			Completed = false,
			Tab = 2,
			Color = "|cffffffff",
			sFormat = true,
			Display = "Status",
			[1849] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[1850] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
			[1848] = { 
				Faction = true,
				Completed = false,
				Tab = 3,
				Color = "|cfff8b700",
				sFormat = false,
				Display = "Percent",
				skipAdd = true,
			},
		}
												
	end

	
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
		SortOrder = { [0] = 15514, [1] = 14790, [2] = 12989, [3] = 13250, [4] = 11190, [5] = 11446, [6] = 10018};

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
		SortOrder = { [0] = 15514, [1] = 14790, [2] = 12989, [3] = 13250, [4] = 11190, [5] = 11446, [6] = 10018};
		for soK,soV in ipairs(SortOrder) do
			MyPathfinder.tStatus[soV].Sum = 0;
			MyPathfinder.tStatus[soV].Count = 0;
		end
	end
	
	MyPathfinder.ProcessTitlePercent = function (item)						
		MyPathfinder.Reset();
		SortOrder = { [0] = 15514, [1] = 14790, [2] = 12989, [3] = 13250, [4] = 11190, [5] = 11446, [6] = 10018};
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
				if item.earnedBy then
					if item.earnedBy ~= "" then
						if key == 13250 or key == 12989 then 
							MyPathfinder.tStatus[key].Sum = MyPathfinder.tStatus[key].Sum + 100;
							MyPathfinder.tStatus[key].Count = MyPathfinder.tStatus[key].Count + 1;
						end
						return;
					end
				end							
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
		
		SortOrder = { [1] = 14790, [2] = 12989, [3] = 13250, [4] = 11190, [5] = 11446, [6] = 10018};
			for k1,v1 in ipairs(SortOrder) do
			for k2,v2 in pairs(item) do
				if v1 == k2 then
					if MyPathfinder.Config.Shadow and v1 == 14790 then	
						tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cff6600CCShadowlands|r 9.2 Zereth Mortis|n|n");	
						MyPathfinder.Tooltip(item[15514]);
						tooltip:AddLine(" ");
						tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cff6600CCShadowlands|r 9.1|n|n");				
						quest63639=C_QuestLog.IsQuestFlaggedCompleted(63639);
						quest64556=C_QuestLog.IsQuestFlaggedCompleted(64556);
						quest63902=C_QuestLog.IsQuestFlaggedCompleted(63902);					
						MyPathfinder.Tooltip(item[14790]);	
						MyPathfinder.Tooltip(item[14961])
						-- Battle of Ardenweald
						if quest63639 == false then
						tooltip:AddLine("|cffffffffCH19 Battle of Ardenweald", "|cffff0000False|r|n|n");
						else
						tooltip:AddLine("|cffffffffCH1/9 Battle of Ardenweald","|cff00ff00True|r|n|n");
						end
						-- Maw Walkers
						if quest64556 == false then
						tooltip:AddLine("|cffffffffCH2/9 Maw Walkers", "|cffff0000False|r|n|n");
						else
						tooltip:AddLine("|cffffffffCH2/9 Maw Walkers","|cff00ff00True|r|n|n");
						end
						-- Focusing the Eye
						if quest63902 == false then
						tooltip:AddLine("|cffffffffCH3/9 Focusing the Eye", "|cffff0000False|r|n|n");
						else
						tooltip:AddLine("|cffffffffCH3/9 Focusing the Eye","|cff00ff00True|r|n|n");
						end			
						level = C_CovenantSanctumUI.GetRenownLevel();
						if level > 43 then
						tooltip:AddLine("|cff13ff29Renown Level Complete|r");
						elseif level > 30 and level < 44 then
						tooltip:AddLine("|cffffffffRenown Level|r","|cfff8b700" .. level .. "/44");
						elseif level > 20 and level < 30 then
						tooltip:AddLine("|cffffffffRenown Level|r","|cfff8b700" .. level .. "/44");
						elseif level > 0 and level < 20 then
						tooltip:AddLine("|cffffffffRenown Level|r","|cffff0000" .. level .. "/44");
						end
					elseif MyPathfinder.Config.Battle and (v1 == 12989 or v1 == 13250) then	
						if v1 == 12989 then tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cFFE77324Battle for Azeroth|r|n|n"); end
						MyPathfinder.Tooltip(item[k2]);
					elseif MyPathfinder.Config.Legion and (v1 == 11446 or v1 == 11190) then	
						if v1 == 11190 then tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cff13ff29Legion|r|n|n"); end
						MyPathfinder.Tooltip(item[k2]);
					elseif MyPathfinder.Config.Draenor and v1 == 10018 then	
						tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cffe53101Warlords of Draenor|r|n|n");						
						MyPathfinder.Tooltip(item[k2]);
					end
				end
			end
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
					
					local tab = 3;
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
		if MyPathfinder.Config.Shadow then	
			local p = MyPathfinder.tStatus[14790].Sum / MyPathfinder.tStatus[14790].Count; 
			output = " |cFFE77324B|r: " .. string.format("%#3.2f%%", p);
		end
		if MyPathfinder.Config.Battle then	
			local p = (MyPathfinder.tStatus[13250].Sum + MyPathfinder.tStatus[12989].Sum) / (MyPathfinder.tStatus[13250].Count + MyPathfinder.tStatus[12989].Count); 
			output = " |cFFE77324B|r: " .. string.format("%#3.2f%%", p);
		end
		if MyPathfinder.Config.Legion then
			local p = (MyPathfinder.tStatus[11446].Sum + MyPathfinder.tStatus[11190].Sum) / (MyPathfinder.tStatus[11446].Count + MyPathfinder.tStatus[11190].Count); 
			output = " |cff13ff29L|r: " .. string.format("%#3.2f%%", p);
		end
		if MyPathfinder.Config.Draenor then
			local p = MyPathfinder.tStatus[10018].Sum / MyPathfinder.tStatus[10018].Count; 
			output = " |cffe53101D|r: " .. string.format("%#3.2f%%", p);
		end
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

function MyPathfinder_OnClick(self, button, ...)			
		if button == "LeftButton" then
			tooltip:Release();
    	tooltip = nil;			
			if MyPathfinder.Config.Shadow == true then
				MyPathfinder.Config.Shadow = false;
				MyPathfinder.Config.Battle = true;
				MyPathfinder.Config.Legion = false;
				MyPathfinder.Config.Draenor = false;
			elseif MyPathfinder.Config.Battle == true then
				MyPathfinder.Config.Shadow = false;
				MyPathfinder.Config.Battle = false;
				MyPathfinder.Config.Legion = true;
				MyPathfinder.Config.Draenor = false;
			elseif  MyPathfinder.Config.Legion == true then
				MyPathfinder.Config.Shadow = false;
				MyPathfinder.Config.Battle = false;
				MyPathfinder.Config.Legion = false;
				MyPathfinder.Config.Draenor = true;
			else
				MyPathfinder.Config.Shadow = true;
				MyPathfinder.Config.Battle = false;
				MyPathfinder.Config.Legion = false;
				MyPathfinder.Config.Draenor = false;
			end			
			MyDO:BuildToolTip(self);
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
	tooltip:AddHeader("|cffe5cc80MyPathfinder - Flying Progression Tracker|r|n");		
	MyPathfinder.ProcessTooltip(MyPathfinder.Status);						
	tooltip:AddLine("|n|cff00ff00Left Click|r to toggle between Shadowlands, BFA, WOD, and Legion ");
	tooltip:AddLine("|n" .. RED_FONT_COLOR_CODE .. "Achievements once completed on any character count for account");
	tooltip:AddLine(RED_FONT_COLOR_CODE .. "wide progress. Blizzards earned by is not always accurate!");					
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
