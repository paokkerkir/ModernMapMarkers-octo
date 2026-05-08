-- Format: { x=, y=, name=, type=, info=, atlasID=, dest= }
-- type values: "dungeon", "raid", "worldboss", "boat", "zepp", "tram"
-- info: level range string for instances, faction string for transports
-- atlasID: Atlas-TW string map key, nil for transport or unmapped entries
-- dest: {continent, zoneName} destination for transport markers, nil otherwise
-- Marker data ported from TWoW DB 1.17.2 (1172 build)
-- New 1.17.2 instances added: FrostmaneHollow, DragonmawRetreat, WindhornCanyon, StormwroughtRuins
-- NOTE: coordinates for these four are estimated from zone geography -- verify in-game
ModernMapMarkers_Points = {
    [1] = { -- Kalimdor
        ["Ashenvale"] = {
            { x=0.123, y=0.128, name="Blackfathom Deeps",                   type="dungeon",   info="24-32", atlasID="BlackfathomDeeps",          dest=nil },
            { x=0.51,  y=0.78,  name="Crescent Grove",                      type="dungeon",   info="32-38", atlasID="TheCrescentGrove",           dest=nil },
            { x=0.937, y=0.355, name="Emerald Dragon - Spawn Point 1 of 4", type="worldboss", info="60",    atlasID="FourDragons",                dest=nil },
        },
        ["Azshara"] = {
            { x=0.535, y=0.816, name="Azuregos",  type="worldboss", info="60", atlasID="Azuregos", dest=nil },
            { x=0.69,  y=0.094, name="Cla'ckora", type="worldboss", info="60", atlasID="Clackora",  dest=nil },
        },
        ["Darkshore"] = {
            { x=0.324, y=0.44,  name="Boat to Stormwind",         type="boat", info="Alliance", atlasID=nil, dest={2, "Stormwind City"} },
            { x=0.304, y=0.41,  name="Boat to Alah'Thalas",       type="boat", info="Alliance", atlasID=nil, dest={2, "Alah'Thalas"}   },
            { x=0.333, y=0.399, name="Boat to Rut'Theran Village", type="boat", info="Alliance", atlasID=nil, dest={1, "Teldrassil"}    },
        },
        ["Desolace"] = {
            { x=0.29, y=0.629, name="Maraudon",  type="dungeon",   info="46-55", atlasID="Maraudon",  dest=nil },
            { x=0.82, y=0.80,  name="Concavius", type="worldboss", info="60",    atlasID="Concavius", dest=nil },
        },
        ["Durotar"] = {
            { x=0.512, y=0.135, name="Zeppelins to UC & Grom'Gol", type="zepp", info="Horde", atlasID=nil, dest={2, "Tirisfal Glades"}, dest2={2, "Stranglethorn Vale"} },
            { x=0.415, y=0.184, name="Zeppelins to TB & Kargath",  type="zepp", info="Horde", atlasID=nil, dest={1, "Thunder Bluff"},    dest2={2, "Badlands"}           },
            { x=0.598, y=0.236, name="Boat to Revantusk Village",  type="boat", info="Horde", atlasID=nil, dest={2, "The Hinterlands"}   },
        },
        ["Dustwallow Marsh"] = {
            { x=0.53,  y=0.76,  name="Onyxia's Lair",          type="raid", info="60",       atlasID="OnyxiasLair", dest=nil             },
            { x=0.718, y=0.566, name="Boat to Menethil Harbor", type="boat", info="Alliance", atlasID=nil,           dest={2, "Wetlands"} },
        },
        ["Feralas"] = {
            { x=0.648, y=0.303, name="Dire Maul - East",                    type="dungeon",   info="55-58",    atlasID="DireMaulEast",  dest=nil },
            { x=0.624, y=0.249, name="Dire Maul - North",                   type="dungeon",   info="57-60",    atlasID="DireMaulNorth", dest=nil },
            { x=0.604, y=0.311, name="Dire Maul - West",                    type="dungeon",   info="57-60",    atlasID="DireMaulWest",  dest=nil },
            { x=0.512, y=0.108, name="Emerald Dragon - Spawn Point 2 of 4", type="worldboss", info="60",       atlasID="FourDragons",   dest=nil },
            { x=0.311, y=0.395, name="Boat to Forgotten Coast",             type="boat",      info="Alliance", atlasID=nil,             dest=nil },
            { x=0.431, y=0.428, name="Boat to Sardor Isle",                 type="boat",      info="Alliance", atlasID=nil,             dest=nil },
        },
        ["Hyjal"] = {
            { x=0.207, y=0.592, name="Emerald Sanctum", type="raid",      info="60", atlasID="EmeraldSanctum", dest=nil },
            { x=0.336, y=0.398, name="Father Lycan",    type="worldboss", info="60", atlasID=nil,               dest=nil },
        },
        ["Orgrimmar"] = {
            { x=0.53, y=0.486, name="Ragefire Chasm", type="dungeon", info="13-18", atlasID="RagefireChasm", dest=nil },
        },
        ["Silithus"] = {
            { x=0.296, y=0.960, name="Ruins of Ahn'Qiraj",  type="raid", info="60", atlasID="TheRuinsofAhnQiraj",  dest=nil },
            { x=0.282, y=0.956, name="Temple of Ahn'Qiraj", type="raid", info="60", atlasID="TheTempleofAhnQiraj", dest=nil },
        },
        ["Tanaris"] = {
            { x=0.66,  y=0.49,  name="Black Morass", type="dungeon",   info="60",    atlasID="CavernsOfTimeBlackMorass", dest=nil },
            { x=0.389, y=0.184, name="Zul'Farrak",   type="dungeon",   info="44-54", atlasID="ZulFarrak",               dest=nil },
            { x=0.361, y=0.762, name="Ostarius",     type="worldboss", info="60",    atlasID="Ostarius",                dest=nil },
        },
        ["Teldrassil"] = {
            { x=0.552, y=0.949, name="Boat to Auberdine", type="boat", info="Alliance", atlasID=nil, dest={1, "Darkshore"} },
        },
        ["The Barrens"] = {
            { x=0.491, y=0.896, name="Razorfen Downs",    type="dungeon", info="37-46",  atlasID="RazorfenDowns",  dest=nil                          },
            { x=0.431, y=0.863, name="Razorfen Kraul",    type="dungeon", info="29-38",  atlasID="RazorfenKraul",  dest=nil                          },
            { x=0.472, y=0.327, name="Wailing Caverns",   type="dungeon", info="17-24",  atlasID="WailingCaverns", dest=nil                          },
            { x=0.636, y=0.389, name="Boat to Booty Bay", type="boat",    info="Neutral", atlasID=nil,             dest={2, "Stranglethorn Vale"}    },
        },
        ["Thousand Needles"] = {
            { x=0.68, y=0.50, name="Windhorn Canyon", type="dungeon", info="26-30", atlasID="WindhornCanyon", dest=nil },
        },
        ["Thunder Bluff"] = {
            { x=0.165, y=0.230, name="Zeppelin to Orgrimmar", type="zepp", info="Horde", atlasID=nil, dest={1, "Durotar"} },
        },
    },
    [2] = { -- Eastern Kingdoms
        ["Alah'Thalas"] = {
            { x=0.531, y=0.047, name="Boat to Auberdine", type="boat", info="Alliance", atlasID=nil, dest={1, "Darkshore"} },
        },
        ["Balor"] = {
            { x=0.450, y=0.300, name="Stormwrought Ruins",                type="dungeon", info="35-42", atlasID="StormwroughtRuins", dest=nil },
            { x=0.560, y=0.450, name="Stormwrought Ruins - Back Entrance", type="dungeon", info="35-42", atlasID="StormwroughtRuins", dest=nil },
        },
        ["Badlands"] = {
            { x=0.429, y=0.130, name="Uldaman - Main Entrance", type="dungeon", info="41-51", atlasID="Uldaman", dest=nil          },
            { x=0.657, y=0.438, name="Uldaman - Back Entrance", type="dungeon", info="41-51", atlasID="Uldaman", dest=nil          },
            { x=0.075, y=0.480, name="Zeppelin to Orgrimmar",   type="zepp",    info="Horde", atlasID=nil,       dest={1, "Durotar"} },
        },
        ["Blasted Lands"] = {
            { x=0.36, y=0.753, name="Lord Kazzak", type="worldboss", info="60", atlasID="LordKazzak", dest=nil },
        },
        ["Burning Steppes"] = {
            { x=0.328, y=0.362, name="Blackrock Depths",      type="dungeon", info="52-60", atlasID="BlackrockDepths",     dest=nil },
            { x=0.95,  y=0.53,  name="Hateforge Quarry",      type="dungeon", info="52-60", atlasID="HateforgeQuarry",     dest=nil },
            { x=0.321, y=0.386, name="Lower Blackrock Spire", type="dungeon", info="55-60", atlasID="BlackrockSpireLower", dest=nil },
            { x=0.312, y=0.365, name="Upper Blackrock Spire", type="dungeon", info="55-60", atlasID="BlackrockSpireUpper", dest=nil },
            { x=0.273, y=0.363, name="Blackwing Lair",        type="raid",    info="60",    atlasID="BlackwingLair",       dest=nil },
            { x=0.273, y=0.387, name="Molten Core",           type="raid",    info="60",    atlasID="MoltenCore",          dest=nil },
        },
        ["Deadwind Pass"] = {
            { x=0.45,  y=0.75,  name="Karazhan Crypt",          type="dungeon",   info="58-60", atlasID="KarazhanCrypt",   dest=nil },
            { x=0.46,  y=0.70,  name="Lower Karazhan Halls",    type="raid",      info="58-60", atlasID="LowerKarazhan",   dest=nil },
            { x=0.442, y=0.719, name="Upper Karazhan Halls",    type="raid",      info="60",    atlasID="TowerofKarazhan", dest=nil },
            { x=0.471, y=0.751, name="Dark Reaver of Karazhan", type="worldboss", info="60",    atlasID="Reaver",          dest=nil },
        },
        ["Dun Morogh"] = {
            { x=0.248, y=0.337, name="Gnomeregan",      type="dungeon", info="29-38", atlasID="Gnomeregan",      dest=nil },
            { x=0.630, y=0.350, name="Frostmane Hollow", type="dungeon", info="13-20", atlasID="FrostmaneHollow", dest=nil },
        },
        ["Duskwood"] = {
            { x=0.465, y=0.357, name="Emerald Dragon - Spawn Point 3 of 4", type="worldboss", info="60", atlasID="FourDragons", dest=nil },
        },
        ["Eastern Plaguelands"] = {
            { x=0.31,  y=0.14,  name="Stratholme",             type="dungeon",   info="58-60", atlasID="Stratholme", dest=nil },
            { x=0.47,  y=0.24,  name="Stratholme - Back Gate", type="dungeon",   info="58-60", atlasID="Stratholme", dest=nil },
            { x=0.40,  y=0.28,  name="Naxxramas",              type="raid",      info="60",    atlasID="Naxxramas",  dest=nil },
            { x=0.082, y=0.38,  name="Nerubian Overseer",      type="worldboss", info="60",    atlasID="Nerubian",   dest=nil },
        },
        ["Elwynn Forest"] = {
            { x=0.29, y=0.61, name="Stormwind Vault - Horde Entrance", type="dungeon", info="60", atlasID="StormwindVault", dest=nil },
        },
        ["Gilneas"] = {
            { x=0.30, y=0.27, name="Gilneas City", type="dungeon", info="43", atlasID="GilneasCity", dest=nil },
        },
        ["Ironforge"] = {
            { x=0.762, y=0.511, name="Tram to Stormwind", type="tram", info="Alliance", atlasID=nil, dest={2, "Stormwind City"} },
        },
        ["Searing Gorge"] = {
            { x=0.371, y=0.857, name="Blackrock Depths",      type="dungeon", info="52-60", atlasID="BlackrockDepths",     dest=nil },
            { x=0.364, y=0.879, name="Lower Blackrock Spire", type="dungeon", info="55-60", atlasID="BlackrockSpireLower", dest=nil },
            { x=0.355, y=0.855, name="Upper Blackrock Spire", type="dungeon", info="55-60", atlasID="BlackrockSpireUpper", dest=nil },
            { x=0.332, y=0.851, name="Blackwing Lair",        type="raid",    info="60",    atlasID="BlackwingLair",       dest=nil },
            { x=0.336, y=0.879, name="Molten Core",           type="raid",    info="60",    atlasID="MoltenCore",          dest=nil },
        },
        ["Silverpine Forest"] = {
            { x=0.44, y=0.67, name="Shadowfang Keep", type="dungeon", info="22-30", atlasID="ShadowfangKeep", dest=nil },
        },
        ["Stormwind City"] = {
            { x=0.51,  y=0.675, name="The Stockade",     type="dungeon", info="24-31", atlasID="TheStockade",    dest=nil             },
            { x=0.63,  y=0.58,  name="Stormwind Vault",  type="dungeon", info="60",    atlasID="StormwindVault", dest=nil             },
            { x=0.694, y=0.294, name="Tram to Ironforge", type="tram",   info="Alliance", atlasID=nil,           dest={2, "Ironforge"} },
            { x=0.218, y=0.563, name="Boat to Auberdine", type="boat",   info="Alliance", atlasID=nil,           dest={1, "Darkshore"} },
        },
        ["Stranglethorn Vale"] = {
            { x=0.53,  y=0.18,  name="Zul'Gurub",                   type="raid", info="60",      atlasID="ZulGurub",         dest=nil                    },
            { x=0.257, y=0.73,  name="Boat to Ratchet",             type="boat", info="Neutral", atlasID=nil,                dest={1, "The Barrens"}      },
            { x=0.312, y=0.298, name="Zeppelins to UC & Orgrimmar", type="zepp", info="Horde",   atlasID=nil, dest={2, "Tirisfal Glades"}, dest2={1, "Durotar"}        },
        },
        ["Swamp of Sorrows"] = {
            { x=0.69, y=0.55, name="The Sunken Temple", type="dungeon", info="50-60", atlasID="TheSunkenTemple", dest=nil },
        },
        ["The Hinterlands"] = {
            { x=0.632, y=0.217, name="Emerald Dragon - Spawn Point 4 of 4", type="worldboss", info="60",    atlasID="FourDragons", dest=nil },
            { x=0.812, y=0.794, name="Boat to Sparkwater Port",             type="boat",      info="Horde", atlasID=nil,           dest=nil },
        },
        ["Tirisfal Glades"] = {
            { x=0.869, y=0.323, name="Scarlet Monastery - Armory",        type="dungeon", info="32-42", atlasID="ScarletMonasteryArmory",    dest=nil                       },
            { x=0.862, y=0.295, name="Scarlet Monastery - Cathedral",     type="dungeon", info="35-45", atlasID="ScarletMonasteryCathedral", dest=nil                       },
            { x=0.839, y=0.283, name="Scarlet Monastery - Graveyard",     type="dungeon", info="26-36", atlasID="ScarletMonasteryGraveyard", dest=nil                       },
            { x=0.850, y=0.338, name="Scarlet Monastery - Library",       type="dungeon", info="29-39", atlasID="ScarletMonasteryLibrary",   dest=nil                       },
            { x=0.616, y=0.571, name="Zeppelins to Orgrimmar & Grom'Gol", type="zepp",   info="Horde",  atlasID=nil, dest={1, "Durotar"},             dest2={2, "Stranglethorn Vale"} },
        },
        ["Western Plaguelands"] = {
            { x=0.69, y=0.74, name="Scholomance", type="dungeon", info="58-60", atlasID="Scholomance", dest=nil },
        },
        ["Westfall"] = {
            { x=0.423, y=0.726, name="The Deadmines", type="dungeon", info="17-24", atlasID="TheDeadmines", dest=nil },
        },
        ["Wetlands"] = {
            { x=0.068, y=0.613, name="Boat to Theramore Isle",       type="boat",    info="Alliance", atlasID=nil,               dest={1, "Dustwallow Marsh"} },
            { x=0.830, y=0.680, name="Dragonmaw Retreat",            type="dungeon", info="27-33",    atlasID="DragonmawRetreat", dest=nil },
            { x=0.845, y=0.700, name="Dragonmaw Retreat - Back Entrance", type="dungeon", info="27-33", atlasID="DragonmawRetreat", dest=nil },
        },
    }
}
