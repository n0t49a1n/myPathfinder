--[[
MyPathfinder, a World of Warcraft Addon

Tracks your "Pathfinder" progress.
Support for Legion, Warlords of Draenor, Battle for Azeroth, Shadowlands and Dragonflight

Version:
3.8.8

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
    if MyPathfinder.Config.Dragon == nil then
        MyPathfinder.Config.Dragon = true
    end
    local race = UnitRace("player");
    MyPathfinder.tStatus = {
        [15794] = {
            Sum = 0,
            Count = 0,
            Percent = 0
        },
        [15514] = {
            Sum = 0,
            Count = 0,
            Percent = 0
        },
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
        [15794] = {
            -- A New Friend
            Completed = false,
            Tab = 0,
            Color = "|cffffffff",
            sFormat = true,
            Display = "Status",
            skipAdd = true
        },
        [15514] = {
            -- Unlocking the Secrets
            Completed = false,
            Tab = 0,
            Color = "|cffffffff",
            sFormat = true,
            Display = "None",
            skipAdd = true,
            [15224] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [15513] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [15515] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [15509] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [15512] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [15518] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        },
        [14961] = {
            -- Chains of Domination
            Completed = false,
            Tab = 0,
            Color = "|cffffffff",
            sFormat = true,
            Display = "Status",
            skipAdd = true
        },
        [14790] = {
            -- Covenant Campaign
            Completed = false,
            Tab = 0,
            Color = "|cffffffff",
            sFormat = true,
            Display = "Status"
        },
        [12989] = {
            -- Battle for Azeroth MyPathfinder, Part One
            Completed = false,
            Tab = 1,
            Color = "|cff00A2E8",
            sFormat = true,
            Display = "None",
            skipAdd = true,
            [12988] = {
                -- Battle for Azeroth Explorer
                Completed = false,
                Tab = 2,
                Color = "|cffffffff",
                sFormat = true,
                Display = "Status",
                [12556] = {
                    -- Explore Tiragarde Sound
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [12558] = {
                    -- Explore Stormsong Valley
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [12561] = {
                    -- Explore Nazmir
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [12557] = {
                    -- Explore Drustvar
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [12559] = {
                    -- Explore Zuldazar
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [12560] = {
                    -- Explore Vol'dun
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                }
            },
            [13144] = {
                -- Wide World of Quests (NYI)
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
                    skipAdd = true
                }
            }
        },
        [13250] = {
            -- Battle for Azeroth MyPathfinder, Part Two
            Completed = false,
            Tab = 1,
            Color = "|cff00A2E8",
            sFormat = true,
            Display = "None",
            Header = true,
            skipAdd = true,
            [13712] = {
                -- Explore Nazjatar
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
                    skipAdd = true
                }
            },
            [13776] = {
                -- Explore Mechagon
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
                    skipAdd = true
                }
            },
            [2391] = {
                -- Rustbolt Resistance
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
                    skipAdd = true
                }
            }
        },
        [11190] = {
            --Broken Isles MyPathfinder, Part One
            Completed = false,
            Tab = 1,
            Color = "|cff00A2E8",
            sFormat = true,
            Display = "None",
            skipAdd = true,
            [11188] = {
                -- Broken Isles Explorer
                Completed = false,
                Tab = 2,
                Color = "|cffffffff",
                sFormat = true,
                Display = "Status",
                [10665] = {
                    -- Explore Azsuna
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [10667] = {
                    -- Explore Highmountain
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [10669] = {
                    -- Explore Suramar
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [10668] = {
                    -- Explore Stormheim
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [10666] = {
                    -- Explore Val'sharah
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                }
            },
            [11157] = {
                --Loremaster of Legion
                Completed = false,
                Tab = 2,
                Color = "|cffffffff",
                sFormat = true,
                Display = "Status",
                [10059] = {
                    --Ain't No Mountain High Enough
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [10763] = {
                    -- Azsuna Matata
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [11124] = {
                    -- Good Suramaritan
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [10698] = {
                    -- That's Val'sharah Folks!
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [10790] = {
                    -- Vrykul Story, Bro
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                }
            },
            [10994] = {
                --A Glorious Campaign
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
                    skipAdd = true
                }
            },
            [11189] = {
                -- Variety is the Spice of Life
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
                    skipAdd = true
                }
            },
            [10672] = {
                -- Broken Isles Diplomat
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
                    skipAdd = true
                },
                [1828] = {
                    Faction = true,
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [1859] = {
                    Faction = true,
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [1883] = {
                    Faction = true,
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [1948] = {
                    Faction = true,
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [1894] = {
                    Faction = true,
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                }
            }
        },
        [11446] = {
            -- Broken Isles MyPathfinder, Part Two
            Completed = false,
            Tab = 1,
            Color = "|cff00A2E8",
            sFormat = true,
            Display = "None",
            Header = true,
            skipAdd = true,
            [11543] = {
                -- Explore Broken Shore
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
                    skipAdd = true
                }
            },
            [11545] = {
                -- Legionfall Commander
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
                    skipAdd = true
                }
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
                    skipAdd = true
                }
            }
        },
        [10018] = {
            -- Draenor MyPathfinder
            Completed = false,
            Tab = 1,
            Color = "|cff00A2E8",
            sFormat = true,
            Display = "None",
            skipAdd = true,
            [8935] = {
                -- Draenor Explorer
                Completed = false,
                Tab = 2,
                Color = "|cffffffff",
                sFormat = true,
                Display = "Status",
                [8937] = {
                    -- Explore Frostfire Ridge
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [8939] = {
                    -- Explore Gorgrond
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [8942] = {
                    -- Explore Nagrand
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [8938] = {
                    -- Explore Shadowmoon Valley
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [8941] = {
                    -- Explore Spires of Arak
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [8940] = {
                    -- Explore Talador
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                }
            },
            [10348] = {
                -- Master Treasure Hunter
                Completed = false,
                Tab = 2,
                Color = "|cffffffff",
                sFormat = true,
                Display = "Status",
                [10348] = {
                    -- Master Treasure Hunter
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [9727] = {
                    -- Expert Treasure Hunter
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                },
                [9726] = {
                    -- Treasure Hunter
                    Completed = false,
                    Tab = 3,
                    Color = "|cfff8b700",
                    sFormat = false,
                    Display = "Percent",
                    skipAdd = true
                }
            }
        }
    }

    if UnitFactionGroup("player") == "Alliance" then
        MyPathfinder.Status[12989][12593] = {
            -- Kul Tourist
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
                skipAdd = true
            },
            [12497] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [12496] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }

        MyPathfinder.Status[12989][12947] = {
            -- Azerothian Diplomat
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
                skipAdd = true
            },
            [2164] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2161] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2160] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2162] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2163] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }

        MyPathfinder.Status[12989][12510] = {
            -- Ready for War
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
                skipAdd = true
            }
        }

        MyPathfinder.Status[13250][2400] = {
            -- Waveblade Ankoan
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
                skipAdd = true
            }
        }

        MyPathfinder.Status[10018][9833] = {
            -- Alliance Loremaster
            Completed = false,
            Tab = 2,
            Color = "|cffffffff",
            sFormat = true,
            Display = "Status",
            [8845] = {
                -- As I Walk Throug the Valley of the Shadow of Moon
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8920] = {
                -- Don't Let the Tala-door Hit You on the Way Out
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8927] = {
                -- Nagrandeur
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8923] = {
                -- Putting the Gore in Gorgrond
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8925] = {
                -- Between Arak and a Hard Place
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }

        MyPathfinder.Status[10018][9564] = {
            -- Securing Draenor
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
                skipAdd = true
            }
        }

        MyPathfinder.Status[10018][10350] = {
            -- Tanaan Diplomat
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
                skipAdd = true
            },
            [1850] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [1847] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }
    elseif UnitFactionGroup("player") == "Horde" then
        MyPathfinder.Status[12989][12479] = {
            -- Zandalar Forever!
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
                skipAdd = true
            },
            [12478] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [11868] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [12481] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Status",
                skipAdd = true
            },
            [11861] = {
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }

        MyPathfinder.Status[12989][12947] = {
            -- Azerothian Diplomat
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
                skipAdd = true
            },
            [2156] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2157] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2163] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2158] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [2103] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }

        MyPathfinder.Status[12989][12509] = {
            -- Ready for War
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
                skipAdd = true
            }
        }

        MyPathfinder.Status[13250][2373] = {
            -- The Unshackled
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
                skipAdd = true
            }
        }

        MyPathfinder.Status[10018][9923] = {
            -- Horde Loremaster
            Completed = false,
            Tab = 2,
            Color = "|cffffffff",
            sFormat = true,
            Display = "Status",
            [8671] = {
                -- You'll Get Caught Up In The... Frostfire!
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8919] = {
                -- Don't Let the Tala-door Hit You on the Way Out
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8928] = {
                -- Nagrandeur
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8924] = {
                -- Putting the Gore in Gorgrond
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [8926] = {
                -- Between Arak and a Hard Place
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }

        MyPathfinder.Status[10018][9562] = {
            -- Securing Draenor
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
                skipAdd = true
            }
        }

        MyPathfinder.Status[10018][10349] = {
            -- Tanaan Diplomat
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
                skipAdd = true
            },
            [1850] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            },
            [1848] = {
                Faction = true,
                Completed = false,
                Tab = 3,
                Color = "|cfff8b700",
                sFormat = false,
                Display = "Percent",
                skipAdd = true
            }
        }
    end

    MyPathfinder.GetColor = function(value)
        value = value * 2
        local r = (2 - value)
        local g = value
        local b = 0

        if r > 1 then
            r = 1
        end
        if g > 1 then
            g = 1
        end
        if b > 1 then
            b = 1
        end

        r = string.format("%i", r * 255)
        g = string.format("%i", g * 255)
        b = string.format("%i", b * 255)

        return "ff" .. string.format("%02x", r) .. string.format("%02x", g) .. string.format("%02x", b)
    end

    MyPathfinder.FilterAch = function(id)
        local _, name, _, completed, _, _, _, _, _, icon, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(id)
        local quantity = 0
        local required = GetAchievementNumCriteria(id)
        local nQuantity = 0
        local nReqQuantity = 0

        if required > 0 then
            if (required == 1) then
                nReqQuantity = select(5, GetAchievementCriteriaInfo(id, 1))
                nQuantity = select(4, GetAchievementCriteriaInfo(id, 1))
            end

            for index = 1, required do
                if select(3, GetAchievementCriteriaInfo(id, index)) == true then
                    quantity = quantity + 1
                end
            end
        end

        return name, completed, icon, quantity, required, nReqQuantity, nQuantity, wasEarnedByMe, earnedBy
    end

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

    MyPathfinder.IsFactionRevered = function(factionID)
        local name,
            description,
            standingID,
            barMin,
            barMax,
            barValue,
            atWarWith,
            canToggleAtWar,
            isHeader,
            isCollapsed,
            hasRep,
            isWatched,
            isChild,
            factionID,
            hasBonusRepGain,
            canBeLFGBonus = GetFactionInfoByID(factionID)

        local quantity = barValue
        local required = 1
        local nQuantity = barValue
        local nReqQuantity = 21000
        local icon = 237384

        if barValue > 21000 then
            completed = true
        else
            completed = false
        end

        return name, completed, icon, quantity, required, nReqQuantity, nQuantity
    end

    MyPathfinder.Traverse = function(table, key)
        local SubReqs = 0
        local SubQuan = 0

        for k, v in pairs(table) do
            if type(v) == "table" then
                table[k] = MyPathfinder.Traverse(v, k)

                if table[k].Faction then
                    table[k].Name,
                        table[k].Completed,
                        table[k].Icon,
                        table[k].Quantity,
                        table[k].Required,
                        table[k].nReqQuantity,
                        table[k].nQuantity = MyPathfinder.IsFactionRevered(k)
                else
                    table[k].Name,
                        table[k].Completed,
                        table[k].Icon,
                        table[k].Quantity,
                        table[k].Required,
                        table[k].nReqQuantity,
                        table[k].nQuantity,
                        table[k].wasEarnedByMe,
                        table[k].earnedBy = MyPathfinder.FilterAch(k)

                    table[k].SubReqs = SubReqs + table[k].Required

                    if table[k].Completed then
                        table[k].SubQuan = table[k].SubReqs
                    else
                        table[k].SubQuan = SubQuan + table[k].Quantity
                    end
                end
            end
        end

        return table
    end

    MyPathfinder.Sort = function(table)
        SortOrder = {
            [0] = 15794,
            [1] = 15514,
            [2] = 14790,
            [3] = 13250,
            [4] = 12989,
            [5] = 11446,
            [6] = 11190,
            [7] = 10018
        }

        for _, v1 in ipairs(SortOrder) do
            for k2, _ in pairs(table) do
                if v1 == k2 then
                    return table[k2]
                end
            end
        end
    end

    MyPathfinder.GetTitlePercent = function(n, key)
        local s

        if n.Completed then
            s = 1
        elseif n.Required == 0 then
            s = 0
        else
            if (n.Required == 1 and n.nReqQuantity > 1) then
                s = 1 * (n.nQuantity / n.nReqQuantity)
            else
                s = 1 * (n.SubQuan / n.SubReqs)
            end
        end

        local Sum = s * 100
        MyPathfinder.tStatus[key].Sum = MyPathfinder.tStatus[key].Sum + Sum
        MyPathfinder.tStatus[key].Count = MyPathfinder.tStatus[key].Count + 1
    end

    MyPathfinder.Reset = function()
        SortOrder = {
            [0] = 15794,
            [1] = 15514,
            [2] = 14790,
            [3] = 13250,
            [4] = 12989,
            [5] = 11446,
            [6] = 11190,
            [7] = 10018
        }

        for _, v in ipairs(SortOrder) do
            MyPathfinder.tStatus[v].Sum = 0
            MyPathfinder.tStatus[v].Count = 0
        end
    end

    MyPathfinder.ProcessTitlePercent = function(item)
        MyPathfinder.Reset()
        SortOrder = {
            [0] = 15794,
            [1] = 15514,
            [2] = 14790,
            [3] = 13250,
            [4] = 12989,
            [5] = 11446,
            [6] = 11190,
            [7] = 10018
        }

        for soK, soV in ipairs(SortOrder) do
            for iK, iV in pairs(item) do
                if soV == iK then
                    MyPathfinder.TitlePercent(item[iK], soV)
                end
            end
        end
    end

    MyPathfinder.TitlePercent = function(item, key)
        if type(item) == "table" then
            if not item.skipAdd then
                if item.Name then
                    MyPathfinder.GetTitlePercent(item, key)
                end
            end

            for iK, iV in pairs(item) do
                MyPathfinder.TitlePercent(iV, key)
            end
        end
    end

    MyPathfinder.GetPercent = function(n)
        local s

        if n.Completed then
            s = 1
        elseif n.Required == 0 then
            s = 0
        else
            if (n.Required == 1 and n.nReqQuantity > 1) then
                s = 1 * (n.nQuantity / n.nReqQuantity)
            else
                s = 1 * (n.SubQuan / n.SubReqs)
            end
        end

        return "|c" .. MyPathfinder.GetColor(s) .. string.format("%#3.2f%%", s * 100) .. "|r"
    end

    MyPathfinder.ProcessTooltip = function(item)
        if MyPathfinder.Config.Dragon then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cFF33937FDragonflight|r|n|n")
            tooltip:AddLine("|cff00A2E8Dragonriding")
            -- The Dragonscale Expedition (storyline 1289)
            if UnitFactionGroup("player") == "Horde" then
                --H
                s1289q01 = C_QuestLog.IsQuestFlaggedCompleted(65435) --The Dragon Isles Await
                s1289q02 = C_QuestLog.IsQuestFlaggedCompleted(65437) --Aspectral Invitation
                s1289q03 = C_QuestLog.IsQuestFlaggedCompleted(65443) --Expeditionary Coordination
                s1289q04 = C_QuestLog.IsQuestFlaggedCompleted(72256) --Dark Talons
                s1289q05 = C_QuestLog.IsQuestFlaggedCompleted(65439) --Whispers on the Winds
                s1289q06 = C_QuestLog.IsQuestFlaggedCompleted(69944) --Chasing Storms
                s1289q07 = C_QuestLog.IsQuestFlaggedCompleted(65444) --To the Dragon Isles
                s1289q08 = C_QuestLog.IsQuestFlaggedCompleted(65452) --Explorers in Peril
                s1289q09 = C_QuestLog.IsQuestFlaggedCompleted(65453) --Primal Pests
                s1289q10 = C_QuestLog.IsQuestFlaggedCompleted(65451) --Practice Materials
                s1289q11 = C_QuestLog.IsQuestFlaggedCompleted(69910) --Where is Wrathion?
                --A + H
                s1289q12 = C_QuestLog.IsQuestFlaggedCompleted(69911) --Excuse the Mess
                s1289q13 = C_QuestLog.IsQuestFlaggedCompleted(69912) --My First Real Emergency!
                s1289q14 = C_QuestLog.IsQuestFlaggedCompleted(66101) --From Such Great Heights
                s1289q15 = C_QuestLog.IsQuestFlaggedCompleted(69914) --The Djaradin Have Awoken
                --H
                s1289q16 = C_QuestLog.IsQuestFlaggedCompleted(70198) --The Call of the Isles
            else
                --A
                s1289q01 = C_QuestLog.IsQuestFlaggedCompleted(65436) --The Dragon Isles Await
                s1289q02 = C_QuestLog.IsQuestFlaggedCompleted(66577) --Aspectral Invitation
                s1289q03 = C_QuestLog.IsQuestFlaggedCompleted(66589) --Expeditionary Coordination
                s1289q04 = C_QuestLog.IsQuestFlaggedCompleted(72240) --The Obsidian Warders
                s1289q05 = C_QuestLog.IsQuestFlaggedCompleted(66596) --Whispers on the Winds
                s1289q06 = C_QuestLog.IsQuestFlaggedCompleted(70050) --Chasing Storms
                s1289q07 = C_QuestLog.IsQuestFlaggedCompleted(67700) --To the Dragon Isles
                s1289q08 = C_QuestLog.IsQuestFlaggedCompleted(70122) --Explorers in Peril
                s1289q09 = C_QuestLog.IsQuestFlaggedCompleted(70123) --Primal Pests
                s1289q10 = C_QuestLog.IsQuestFlaggedCompleted(70124) --Practice Materials
                s1289q11 = C_QuestLog.IsQuestFlaggedCompleted(70125) --Where is Wrathion?
                --A + H
                s1289q12 = C_QuestLog.IsQuestFlaggedCompleted(69911) --Excuse the Mess
                s1289q13 = C_QuestLog.IsQuestFlaggedCompleted(69912) --My First Real Emergency!
                s1289q14 = C_QuestLog.IsQuestFlaggedCompleted(66101) --From Such Great Heights
                s1289q15 = C_QuestLog.IsQuestFlaggedCompleted(69914) --The Djaradin Have Awoken
                --A
                s1289q16 = C_QuestLog.IsQuestFlaggedCompleted(70197) --The Call of the Isles
            end

            if C_QuestLog.IsQuestFlaggedCompleted(70197) or C_QuestLog.IsQuestFlaggedCompleted(70198) == true then
                -- Dragons in Distress (storyline 1299)
                s1299q01 = C_QuestLog.IsQuestFlaggedCompleted(65760) --Reporting for Duty
                s1299q02 = C_QuestLog.IsQuestFlaggedCompleted(65989) --Invader Djaradin
                s1299q03 = C_QuestLog.IsQuestFlaggedCompleted(65990) --Deliver Whelps From Evil
                s1299q04 = C_QuestLog.IsQuestFlaggedCompleted(65991) --Time for a Reckoning
                s1299q05 = C_QuestLog.IsQuestFlaggedCompleted(65993) --Killjoy
                s1299q06 = C_QuestLog.IsQuestFlaggedCompleted(65992) --Blacktalon Intel
                s1299q07 = C_QuestLog.IsQuestFlaggedCompleted(65995) --The Obsidian Citadel
                s1299q08 = C_QuestLog.IsQuestFlaggedCompleted(65996) --Veteran Reinforcements
                s1299q09 = C_QuestLog.IsQuestFlaggedCompleted(65997) --Chasing Sendrax
                s1299q10 = C_QuestLog.IsQuestFlaggedCompleted(65998) --Future of the Flights
                s1299q11 = C_QuestLog.IsQuestFlaggedCompleted(65999) --Red in Tooth and Claw
                s1299q12 = C_QuestLog.IsQuestFlaggedCompleted(66000) --Library of Alexstrasza
                s1299q13 = C_QuestLog.IsQuestFlaggedCompleted(66001) --A Last Hope
            end
            if C_QuestLog.IsQuestFlaggedCompleted(66001) == true then
                -- In Defense of Life (storyline 1300)
                s1300q01 = C_QuestLog.IsQuestFlaggedCompleted(66114) --For the Benefit of the Queen
                s1300q02 = C_QuestLog.IsQuestFlaggedCompleted(66115) --The Mandate of the Red
                s1300q03 = C_QuestLog.IsQuestFlaggedCompleted(68795) --Dragonriding
            end
            --start of requirements / guide / info section
            if MyPathfinder.GetAchievementInfo(15794) == false or MyPathfinder.Config.ShowCompleted == true then
                tooltip:AddLine("|cfff8b700The Dragonscale Expedition Storyline")
                if s1289q16 == true then
                    tooltip:AddLine("|cffffffffThe Dragonscale Expedition Storyline", GREEN_FONT_COLOR_CODE .. "Complete|r")
                else
                    if race == "Dracthyr" then
                    --skip
                    else
                    tooltip:AddLine("|cffffffff--The Dragon Isles Await", s1289q01)
                    end
                    tooltip:AddLine("|cffffffff--Aspectral Invitation", s1289q02)
                    tooltip:AddLine("|cffffffff--Expeditionary Coordination", s1289q03)
                    if UnitFactionGroup("player") == "Horde" then
                        tooltip:AddLine("|cffffffff--Dark Talons", s1289q04)
                    else
                        tooltip:AddLine("|cffffffff--The Obsidian Warders", s1289q04)
                    end
                    tooltip:AddLine("|cffffffff--Whispers on the Winds", s1289q05)
                    tooltip:AddLine("|cffffffff--Chasing Storms", s1289q06)
                    tooltip:AddLine("|cffffffff--To the Dragon Isles", s1289q07)
                    tooltip:AddLine("|cffffffff--Primal Pests", s1289q08)
                    tooltip:AddLine("|cffffffff--Explorers in Peril", s1289q09)
                    tooltip:AddLine("|cffffffff--Practice Materials", s1289q10)
                    tooltip:AddLine("|cffffffff--Where is Wrathion?", s1289q11)
                    tooltip:AddLine("|cffffffff--Excuse the Mess", s1289q12)
                    tooltip:AddLine("|cffffffff--My First Real Emergency!", s1289q13)
                    tooltip:AddLine("|cffffffff--From Such Great Heights", s1289q14)
                    tooltip:AddLine("|cffffffff--The Djaradin Have Awoken", s1289q15)
                    tooltip:AddLine("|cffffffff--The Call of the Isles", s1289q16)
                end
                tooltip:AddLine("")
                tooltip:AddLine("|cfff8b700Dragons in Distress Storyline")
                if s1289q16 == true then
                    if s1299q13 == true then
                        tooltip:AddLine("|cffffffffDragons in Distress Storyline", GREEN_FONT_COLOR_CODE .. "Complete|r")
                    else
                        tooltip:AddLine("|cffffffff--Reporting for Duty", s1299q01)
                        tooltip:AddLine("|cffffffff--Invader Djaradin", s1299q02)
                        tooltip:AddLine("|cffffffff--Deliver Whelps From Evil", s1299q03)
                        tooltip:AddLine("|cffffffff--Time for a Reckoning", s1299q04)
                        tooltip:AddLine("|cffffffff--Killjoy", s1299q05)
                        tooltip:AddLine("|cffffffff--Blacktalon Intel", s1299q06)
                        tooltip:AddLine("|cffffffff--The Obsidian Citadel", s1299q07)
                        tooltip:AddLine("|cffffffff--Veteran Reinforcements", s1299q08)
                        tooltip:AddLine("|cffffffff--Chasing Sendrax", s1299q09)
                        tooltip:AddLine("|cffffffff--Future of the Flights", s1299q10)
                        tooltip:AddLine("|cffffffff--Red in Tooth and Claw", s1299q11)
                        tooltip:AddLine("|cffffffff--Library of Alexstrasza", s1299q12)
                        tooltip:AddLine("|cffffffff--A Last Hope", s1299q13)
                    end
                else
                    tooltip:AddLine("|cffffffffThe Dragonscale Expedition Storyline", RED_FONT_COLOR_CODE .. "Incomplete")
                end
                tooltip:AddLine("")
                tooltip:AddLine("|cfff8b700In Defense of Life Storyline")
                if s1299q13 == true then
                    if s1300q3 == true then
                        tooltip:AddLine("|cffffffffStoryline", GREEN_FONT_COLOR_CODE .. "Complete|r")
                    else
                        tooltip:AddLine("|cffffffff--For the Benefit of the Queen", s1300q01)
                        tooltip:AddLine("|cffffffff--The Mandate of the Red", s1300q02)
                        tooltip:AddLine("|cffffffff--Dragonriding", s1300q03)
                    end
                else
                    tooltip:AddLine("|cffffffffDragons in Distress Storyline", RED_FONT_COLOR_CODE .. "Incomplete")
                end
                tooltip:AddLine("")
                tooltip:AddLine("|cfff8b700Dragonriding")
                MyPathfinder.Tooltip(item[15794])
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end
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

                if level > 43 then
                    tooltip:AddLine("|cffffffffRenown", "|cff13ff29Complete|r")
                    check2 = true
                elseif level > 30 and level < 44 then
                    tooltip:AddLine("|cffffffffRenown", "|cfff8b700" .. level .. "/44")
                elseif level > 20 and level < 30 then
                    tooltip:AddLine("|cffffffffRenown", "|cfff8b700" .. level .. "/44")
                elseif level > 0 and level < 20 then
                    tooltip:AddLine("|cffffffffRenown", "|cffff0000" .. level .. "/44")
                end

                if check1 == true then
                    MyPathfinder.Tooltip(item[14790])
                else
                    tooltip:AddLine("|cffffffffCovenant Campaign", RED_FONT_COLOR_CODE .. "Incomplete")
                end

                tooltip:AddLine("|cfff8b700Chains of Domination Quest Line")

                -- Battle of Ardenweald
                if check1 == true and check2 == true then -- preq check
                    if quest63639 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("|cff00A2E8Battle of Ardenweald", GREEN_FONT_COLOR_CODE .. "Complete|r")
                    else
                        tooltip:AddLine("|cff00A2E8Battle of Ardenweald")
                        tooltip:AddLine("|cffffffff--The First Move", C_QuestLog.IsQuestFlaggedCompleted(63576))
                        tooltip:AddLine(
                            "|cffffffff--A Gathering of Covenants",
                            C_QuestLog.IsQuestFlaggedCompleted(63856)
                        )
                        tooltip:AddLine("|cffffffff--Voices of the Eternal", C_QuestLog.IsQuestFlaggedCompleted(63857))
                        tooltip:AddLine(
                            "|cffffffff--The Battle of Ardenweald",
                            C_QuestLog.IsQuestFlaggedCompleted(63578)
                        )
                        tooltip:AddLine("|cffffffff--Can't Turn Our Backs", C_QuestLog.IsQuestFlaggedCompleted(63638))
                        tooltip:AddLine(
                            "|cffffffff--The Heart of Ardenweald",
                            C_QuestLog.IsQuestFlaggedCompleted(63904)
                        )
                        tooltip:AddLine("|cffffffff--Report to Oribos", quest63639)
                    end
                else
                    tooltip:AddLine("|cff888888Battle of Ardenweald", RED_FONT_COLOR_CODE .. "Prerequisite Incomplete|r")
                end

                -- Maw Walkers
                if quest63639 == true and check2 then -- preq check
                    if quest64556 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("|cff00A2E8Maw Walkers", GREEN_FONT_COLOR_CODE .. "Complete|r")
                    else
                        tooltip:AddLine("|cff00A2E8Maw Walkers")
                        tooltip:AddLine("|cffffffff--Opening the Maw", C_QuestLog.IsQuestFlaggedCompleted(63660))
                        tooltip:AddLine("|cffffffff--Link to the Maw", C_QuestLog.IsQuestFlaggedCompleted(63661))
                        tooltip:AddLine("|cffffffff--Mysteries of the Maw", C_QuestLog.IsQuestFlaggedCompleted(63662))
                        tooltip:AddLine(
                            "|cffffffff--Korthia, the City of Secrets",
                            C_QuestLog.IsQuestFlaggedCompleted(63663)
                        )
                        tooltip:AddLine("|cffffffff--Who is the Maw Walker?", C_QuestLog.IsQuestFlaggedCompleted(63994))
                        tooltip:AddLine("|cffffffff--Opening to Oribos", C_QuestLog.IsQuestFlaggedCompleted(63665))
                        tooltip:AddLine(
                            "|cffffffff--Charge of the Covenants",
                            C_QuestLog.IsQuestFlaggedCompleted(64007)
                        )
                        tooltip:AddLine("|cffffffff--Surveying Secrets", C_QuestLog.IsQuestFlaggedCompleted(64555))
                        tooltip:AddLine("|cffffffff--In Need of Assistance", quest64556)
                    end
                else
                    tooltip:AddLine("|cff888888Maw Walkers", RED_FONT_COLOR_CODE .. "Prerequisite Incomplete|r")
                end

                -- Focusing the Eye
                if quest64556 == true and quest63639 == true and check2 then -- preq check
                    if quest63902 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("|cff00A2E8Focusing the Eye", GREEN_FONT_COLOR_CODE .. "Complete|r")
                    else
                        tooltip:AddLine("|cff00A2E8Focusing the Eye")
                        tooltip:AddLine("|cffffffff--A Show of Gratitude", C_QuestLog.IsQuestFlaggedCompleted(63848))
                        tooltip:AddLine("|cffffffff--Ease of Passage", C_QuestLog.IsQuestFlaggedCompleted(63855))
                        tooltip:AddLine("|cffffffff--Grab Bag", C_QuestLog.IsQuestFlaggedCompleted(63895))
                        tooltip:AddLine("|cffffffff--Hearing Aid", C_QuestLog.IsQuestFlaggedCompleted(63849))
                        tooltip:AddLine("|cffffffff--Birds of a Feather", C_QuestLog.IsQuestFlaggedCompleted(63810))
                        tooltip:AddLine("|cffffffff--The Caged Bird", C_QuestLog.IsQuestFlaggedCompleted(63754))
                        tooltip:AddLine("|cffffffff--Claim the Sky", C_QuestLog.IsQuestFlaggedCompleted(63764))
                        tooltip:AddLine(
                            "|cffffffff--A Hate-Hate Relationship",
                            C_QuestLog.IsQuestFlaggedCompleted(63811)
                        )
                        tooltip:AddLine("|cffffffff--Fury Given Voice", C_QuestLog.IsQuestFlaggedCompleted(63831))
                        tooltip:AddLine("|cffffffff--The Chosen Few", C_QuestLog.IsQuestFlaggedCompleted(63844))
                        tooltip:AddLine("|cffffffff--Wrath of Odyn", C_QuestLog.IsQuestFlaggedCompleted(63845))
                        tooltip:AddLine("|cffffffff--Mawsplaining", C_QuestLog.IsQuestFlaggedCompleted(64014))
                        tooltip:AddLine("|cffffffff--Tears of the Damned", C_QuestLog.IsQuestFlaggedCompleted(63896))
                        tooltip:AddLine("|cffffffff--Anger Management", C_QuestLog.IsQuestFlaggedCompleted(63867))
                        tooltip:AddLine("|cffffffff--Focusing the Eye", C_QuestLog.IsQuestFlaggedCompleted(63901))
                        tooltip:AddLine("|cffffffff--Good News, Everyone!", quest63902)
                    end
                else
                    tooltip:AddLine("|cff888888Focusing the Eye", RED_FONT_COLOR_CODE .. "Prerequisite Incomplete|r")
                end

                if quest63902 == true then
                    tooltip:AddLine("|cfff8b700World Quests")
                    if quest63949 == true then
                        tooltip:AddLine("|cffffffffShaping Fate", GREEN_FONT_COLOR_CODE .. "Complete|r")
                        check3 = true
                    else
                        tooltip:AddLine("|cffffffffShaping Fate", RED_FONT_COLOR_CODE .. "Incomplete")
                    end

                    if covenantID == 1 then --kyrian
                        if C_QuestLog.IsQuestFlaggedCompleted(61982) == true then
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", GREEN_FONT_COLOR_CODE .. "Complete|r")
                        else
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    elseif covenantID == 2 then --venthyr
                        if C_QuestLog.IsQuestFlaggedCompleted(61981) == true then
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", GREEN_FONT_COLOR_CODE .. "Complete|r")
                        else
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    elseif covenantID == 3 then --nightfae
                        if C_QuestLog.IsQuestFlaggedCompleted(61984) == true then
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", GREEN_FONT_COLOR_CODE .. "Complete|r")
                        else
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    elseif covenantID == 4 then --necrolord
                        if C_QuestLog.IsQuestFlaggedCompleted(61983) == true then
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", GREEN_FONT_COLOR_CODE .. "Complete|r")
                        else
                            tooltip:AddLine("|cffffffffReplenish the Reservoir", RED_FONT_COLOR_CODE .. "Incomplete")
                        end
                        check4 = true
                    end
                else
                    tooltip:AddLine("|cfff8b700World Quests")
                    tooltip:AddLine("|cff888888Shaping Fate", RED_FONT_COLOR_CODE .. "Prerequisite Incomplete")
                    tooltip:AddLine("|cff888888Replenish the Reservoir", RED_FONT_COLOR_CODE .. "Prerequisite Incomplete")
                end

                tooltip:AddLine("|cfff8b700Chains of Domination Quest Line (Continued)")

                -- The Last Sigil
                if
                    quest63902 == true and quest64556 == true and quest63639 == true and check1 and check2 or
                        MyPathfinder.Config.ShowCompleted == true
                 then -- preq check
                    if quest63727 == true and MyPathfinder.Config.ShowCompleted == false then -- complete check
                        tooltip:AddLine("|cff00A2E8The Last Sigil", GREEN_FONT_COLOR_CODE .. "Complete|r")
                    else
                        tooltip:AddLine("|cff00A2E8The Last Sigil")
                        tooltip:AddLine("|cffffffff--Vault of Secrets", C_QuestLog.IsQuestFlaggedCompleted(63703))
                        tooltip:AddLine("|cffffffff--Vengeance for Korthia", C_QuestLog.IsQuestFlaggedCompleted(63704))
                        tooltip:AddLine("|cffffffff--The Knowledge Keepers", C_QuestLog.IsQuestFlaggedCompleted(63705))
                        tooltip:AddLine("|cffffffff--Let the Anima Flow", C_QuestLog.IsQuestFlaggedCompleted(63706))
                        tooltip:AddLine("|cffffffff--Secrets of the Vault", C_QuestLog.IsQuestFlaggedCompleted(63709))
                        tooltip:AddLine("|cffffffff--The Anima Trail", C_QuestLog.IsQuestFlaggedCompleted(63710))
                        tooltip:AddLine("|cffffffff--Bone Tools", C_QuestLog.IsQuestFlaggedCompleted(63711))
                        tooltip:AddLine("|cffffffff--Lost Records", C_QuestLog.IsQuestFlaggedCompleted(63712))
                        tooltip:AddLine("|cffffffff--Hooking Over", C_QuestLog.IsQuestFlaggedCompleted(63713))
                        tooltip:AddLine("|cffffffff--To the Vault", C_QuestLog.IsQuestFlaggedCompleted(63714))
                        tooltip:AddLine("|cffffffff--Defending the Vault", C_QuestLog.IsQuestFlaggedCompleted(63717))
                        tooltip:AddLine("|cffffffff--Keepers of Korthia", C_QuestLog.IsQuestFlaggedCompleted(63722))
                        tooltip:AddLine("|cffffffff--Into the Vault", C_QuestLog.IsQuestFlaggedCompleted(63725))
                        tooltip:AddLine("|cffffffff--Untangling the Sigil", C_QuestLog.IsQuestFlaggedCompleted(63726))
                        tooltip:AddLine("|cffffffff--The Primus Returns (Get Flying Here)", quest63727)

                        if quest63727 == true then
                            tooltip:AddLine("|cfff8b700Item")
                            tooltip:AddLine("|cffffffffMemories of Sunless Skies", "|cff888888Unused|r")
                        end
                    end
                else
                    tooltip:AddLine("|cff888888The Last Sigil", RED_FONT_COLOR_CODE .. "Prerequisite Incomplete|r")
                end
            else
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            end

            tooltip:AddLine(" ")
            tooltip:AddLine("|cff00A2E8Patch 9.2 (Zereth Mortis)")

            if isZereth == true and MyPathfinder.Config.ShowCompleted == false then
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            else
                tooltip:AddLine("|cfff8b700Prerequisites")
                if quest63727 == true or MyPathfinder.Config.ShowCompleted == true then -- preq check
                    tooltip:AddLine("|cffffffffPatch 9.0.1", GREEN_FONT_COLOR_CODE .. "Complete|r")
                    tooltip:AddLine("|cfff8b700Achievments")
                    MyPathfinder.Tooltip(item[15514])
                else
                    tooltip:AddLine("|cff888888Patch 9.0.1", RED_FONT_COLOR_CODE .. "Incomplete")
                end
            end
        elseif MyPathfinder.Config.Battle then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cFFE77324Battle for Azeroth|r|n|n")
            tooltip:AddLine("|cff00A2E8Patch 8.0.1")

            if MyPathfinder.GetAchievementInfo(12989) == true and MyPathfinder.Config.ShowCompleted == false then
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            else
                MyPathfinder.Tooltip(item[12989])
            end

            tooltip:AddLine(" ")
            tooltip:AddLine("|cff00A2E8Patch 8.2")

            if MyPathfinder.GetAchievementInfo(13250) == true and MyPathfinder.Config.ShowCompleted == false then
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            else
                MyPathfinder.Tooltip(item[13250])
            end
        elseif MyPathfinder.Config.Legion then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cff13ff29Legion|r (Legacy)|n|n")
            tooltip:AddLine("|cff00A2E8Patch 7.0.3")

            if MyPathfinder.GetAchievementInfo(11190) == true and MyPathfinder.Config.ShowCompleted == false then
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            else
                MyPathfinder.Tooltip(item[11190])
            end

            tooltip:AddLine(" ")
            tooltip:AddLine("|cff00A2E8Patch 7.2")

            if MyPathfinder.GetAchievementInfo(11446) == true and MyPathfinder.Config.ShowCompleted == false then
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            else
                MyPathfinder.Tooltip(item[11446])
            end
        elseif MyPathfinder.Config.Draenor then
            tooltip:AddLine("|n|cfff8b700World Of Warcraft: |cffe53101Warlords of Draenor|r (Legacy)|n|n")
            tooltip:AddLine("|cff00A2E8Patch 6.2")

            if MyPathfinder.GetAchievementInfo(10018) == true and MyPathfinder.Config.ShowCompleted == false then
                tooltip:AddLine(GREEN_FONT_COLOR_CODE .. "Completed|r")
            else
                MyPathfinder.Tooltip(item[10018])
            end
        end
    end

    --[4] = 11446, [5] = 11190, [6] = 10018};
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

                if display == "None" then
                    tooltip:AddLine(spacing .. color .. item.Name)
                elseif display == "Status" then
                    if status == true then
                        if item.HideEB then
                            tooltip:AddLine(spacing .. color .. item.Name, GREEN_FONT_COLOR_CODE .. "Complete")
                        else
                            if ebo == true then
                                tooltip:AddLine(
                                    spacing .. color .. item.Name,
                                    "|cff888888Earned By " ..
                                        item.earnedBy .. "|r " .. GREEN_FONT_COLOR_CODE .. "Complete"
                                )
                            elseif ebm == true then
                                myname, myrealm = UnitName("player")
                                tooltip:AddLine(
                                    spacing .. color .. item.Name,
                                    "|cff888888Earned By " .. myname .. "|r " .. GREEN_FONT_COLOR_CODE .. "Complete"
                                )
                            else
                                tooltip:AddLine(spacing .. color .. item.Name, GREEN_FONT_COLOR_CODE .. "Complete")
                            end
                        end
                    else
                        tooltip:AddLine(spacing .. color .. item.Name, RED_FONT_COLOR_CODE .. "Incomplete")
                    end
                else
                    if item.HideEB then
                        tooltip:AddLine(spacing .. color .. item.Name, MyPathfinder.GetPercent(item))
                    else
                        if ebo == true then
                            tooltip:AddLine(
                                spacing .. color .. item.Name,
                                "|cff888888Earned By " ..
                                    item.earnedBy .. "|r " .. GREEN_FONT_COLOR_CODE .. MyPathfinder.GetPercent(item)
                            )
                        elseif ebm == true then
                            myname, myrealm = UnitName("player")
                            tooltip:AddLine(
                                spacing .. color .. item.Name,
                                "|cff888888Earned By " ..
                                    myname .. "|r " .. GREEN_FONT_COLOR_CODE .. MyPathfinder.GetPercent(item)
                            )
                        else
                            tooltip:AddLine(spacing .. color .. item.Name, MyPathfinder.GetPercent(item))
                        end
                    end
                end
            end

            for k, v in pairs(item) do
                MyPathfinder.Tooltip(v)
            end
        end
    end

    MyPathfinder.Update = function()
        local output = ""
        MyPathfinder.Status = MyPathfinder.Traverse(MyPathfinder.Status)
        MyPathfinder.ProcessTitlePercent(MyPathfinder.Status)

        if MyPathfinder.Config.Dragon then
            local p = MyPathfinder.tStatus[15794].Sum
            output = " |cffe333333|r: " .. string.format("%#3.2f%%", p)
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
        if MyPathfinder.Config.Dragon == true then
            MyPathfinder.Config.Dragon = false
            MyPathfinder.Config.Shadow = true
            MyPathfinder.Config.Battle = false
            MyPathfinder.Config.Legion = false
            MyPathfinder.Config.Draenor = false
        elseif MyPathfinder.Config.Shadow == true then
            MyPathfinder.Config.Dragon = false
            MyPathfinder.Config.Shadow = false
            MyPathfinder.Config.Battle = true
            MyPathfinder.Config.Legion = false
            MyPathfinder.Config.Draenor = false
        elseif MyPathfinder.Config.Battle == true then
            MyPathfinder.Config.Dragon = false
            MyPathfinder.Config.Shadow = false
            MyPathfinder.Config.Battle = false
            MyPathfinder.Config.Legion = true
            MyPathfinder.Config.Draenor = false
        elseif MyPathfinder.Config.Legion == true then
            MyPathfinder.Config.Dragon = false
            MyPathfinder.Config.Shadow = false
            MyPathfinder.Config.Battle = false
            MyPathfinder.Config.Legion = false
            MyPathfinder.Config.Draenor = true
        else
            MyPathfinder.Config.Dragon = true
            MyPathfinder.Config.Shadow = false
            MyPathfinder.Config.Battle = false
            MyPathfinder.Config.Legion = false
            MyPathfinder.Config.Draenor = false
        end

        MyDO:BuildToolTip(self)
    end

    if button == "RightButton" then
        tooltip:Release()
        tooltip = nil

        if MyPathfinder.Config.ShowCompleted == true then
            MyPathfinder.Config.ShowCompleted = false
        else
            MyPathfinder.Config.ShowCompleted = true
        end

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
    tooltip:AddHeader("|cffe5cc80MyPathfinder v" .. GetAddOnMetadata("MyPathfinder", "Version") .. "|r|n")

    MyPathfinder.ProcessTooltip(MyPathfinder.Status)

    tooltip:AddLine("|n|cffffffffLeft Click|r to toggle between Dragonflight, Shadowlands, BFA, WOD, and Legion ")

    if MyPathfinder.Config.ShowCompleted == false then
        tooltip:AddLine("|n|cffffffffRight Click|r to |cff00ff00Show|r Completed Requirements")
    else
        tooltip:AddLine("|n|cffffffffRight Click|r to " .. RED_FONT_COLOR_CODE .. "Hide|r Completed Requirements")
    end

    tooltip:UpdateScrolling()
    tooltip:Show()
end

local function EventHandler(self, event, ...)
    if (event == "VARIABLES_LOADED" and initialized == true) then
        print("|cffe5cc80MyPathfinder v" .. GetAddOnMetadata("MyPathfinder", "Version") .. " Loaded!|r")
    elseif (event == "PLAYER_ENTERING_WORLD" and initialized == true) then
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
