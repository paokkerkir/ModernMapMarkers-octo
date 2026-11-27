MMM = MMM or {}

local coreFrame = CreateFrame("Frame", "ModernMapMarkersCore", UIParent)
MMM.markers = {}
MMM.Data = {}
MMM.ZoneMarkers = {}
MMM.FlatDropdownData = nil
MMM.ijInstalled = false

-- Localization shorthand
local L = ModernMapMarkers_Locale

-- Filter constants
local ALL_TYPES = { "DUNGEON", "RAID", "WORLDBOSS", "BOAT", "ZEPPELIN", "TRAM" }

-- InstanceJournal Integration
-- MMM markers to hide when IJ is installed (covered by IJ POI entrances)
local IJ_HIDDEN_MARKERS = {
    ["Blackrock Depths"]               = true,
    ["Lower Blackrock Spire"]          = true,
    ["Upper Blackrock Spire"]          = true,
    ["Blackwing Lair"]                 = true,
    ["Molten Core"]                     = true,
    ["Dire Maul - East"]               = true,
    ["Dire Maul - North"]              = true,
    ["Dire Maul - West"]               = true,
    ["Black Morass"]                    = true,
    ["The Deadmines"]                   = true,
    ["Temple of Ahn'Qiraj"]            = true,
    ["Ruins of Ahn'Qiraj"]             = true,
    ["Gnomeregan"]                      = true,
    ["Maraudon"]                        = true,
    ["Scarlet Monastery - Armory"]      = true,
    ["Scarlet Monastery - Cathedral"]   = true,
    ["Scarlet Monastery - Graveyard"]   = true,
    ["Scarlet Monastery - Library"]     = true,
    ["Uldaman - Main Entrance"]         = true,
    ["Uldaman - Back Entrance"]         = true,
    ["Wailing Caverns"]                 = true,
    ["Windhorn Canyon"]                  = true,
    ["Timbermaw Hold"]                   = true,
}

-- Map MMM marker names to IJ database keys for click behavior
-- { db = "DG" or "R", key = IJDB key }
local MMM_TO_IJ = {
    -- Dungeons
    ["Blackfathom Deeps"]                   = { db = "DG", key = "BFD" },
    ["Crescent Grove"]                      = { db = "DG", key = "CG" },
    ["Ragefire Chasm"]                      = { db = "DG", key = "RFC" },
    ["Razorfen Downs"]                      = { db = "DG", key = "RFD" },
    ["Razorfen Kraul"]                      = { db = "DG", key = "RFK" },
    ["Zul'Farrak"]                          = { db = "DG", key = "ZF" },
    ["Shadowfang Keep"]                     = { db = "DG", key = "SFK" },
    ["The Stockade"]                        = { db = "DG", key = "STOCKADES" },
    ["Stormwind Vault"]                     = { db = "DG", key = "SV" },
    ["Stormwind Vault - Horde Entrance"]    = { db = "DG", key = "SV" },
    ["Stratholme"]                          = { db = "DG", key = "STRAT" },
    ["Stratholme - Back Gate"]              = { db = "DG", key = "STRAT" },
    ["Scholomance"]                         = { db = "DG", key = "SCHOLO" },
    ["The Sunken Temple"]                   = { db = "DG", key = "ST" },
    ["Hateforge Quarry"]                    = { db = "DG", key = "HQ" },
    ["Dragonmaw Retreat"]                   = { db = "DG", key = "DMR" },
    ["Karazhan Crypt"]                      = { db = "DG", key = "KC" },
    ["Lower Blackrock Spire"]              = { db = "DG", key = "LBRS" },
    ["Upper Blackrock Spire"]              = { db = "DG", key = "UBRS" },
    ["Gilneas City"]                        = { db = "DG", key = "GC" },
    ["Stormwrought Ruins"]                  = { db = "DG", key = "SWR" },
    ["Stormwrought Ruins - Back Entrance"]  = { db = "DG", key = "SWR" },
    ["Frostmane Hollow"]                    = { db = "DG", key = "FH" },
    ["Windhorn Canyon"]                     = { db = "DG", key = "WHC" },
    -- Raids
    ["Onyxia's Lair"]                       = { db = "R", key = "ONY" },
    ["Emerald Sanctum"]                     = { db = "R", key = "ES" },
    ["Lower Karazhan Halls"]                = { db = "R", key = "KARA10" },
    ["Blackwing Lair"]                      = { db = "R", key = "BWL" },
    ["Tower of Karazhan"]                   = { db = "R", key = "KARA40" },
    ["Naxxramas"]                           = { db = "R", key = "NAXX" },
    ["Zul'Gurub"]                           = { db = "R", key = "ZG" },
    ["Timbermaw Hold"]                      = { db = "R", key = "TH" },
}

-- Keep POI submap zone markers
local IJ_SUBMAP_ZONES = {}

-- Default filters
MMM.filters = {
    DUNGEON   = true,
    RAID      = true,
    BOAT      = true,
    ZEPPELIN  = true,
    TRAM      = true,
    WORLDBOSS = true,
    FACTION   = "ALL"
}

local HOVER_SIZE_MULTIPLIER   = 1.15
local HOVER_ALPHA             = 0.5
local FIND_SIZE_MULTIPLIER    = 1.4
local FIND_HIGHLIGHT_ALPHA    = 0.9
local FIND_HIGHLIGHT_DURATION = 1.75
local SOUND_CLICK             = "Sound\\Interface\\uCharacterSheetOpen.wav"
local SOUND_PING              = "Sound\\Interface\\MapPing.wav"

local CFM_WORLD_BOSS_ID = {
    ["Azuregos"]    = "WBAzuregos",
    ["Lord Kazzak"] = "WBLordKazzak",
    ["Lethon"]      = "WBLethon",
    ["Emeriss"]     = "WBEmeriss",
    ["Taerar"]      = "WBTaerar",
    ["Ysondre"]     = "WBYsondre",
}

local NORMAL_ATLAS_ALIASES = {
    ["ScarletMonasteryArmory"]    = "SMArmory",
    ["ScarletMonasteryCathedral"] = "SMCathedral",
    ["ScarletMonasteryGraveyard"] = "SMGraveyard",
    ["ScarletMonasteryLibrary"]   = "SMLibrary",
    ["TheRuinsofAhnQiraj"]        = { "AhnQirajRuins", "RuinsofAhnQiraj" },
    ["TheTempleofAhnQiraj"]       = { "AhnQirajTemple", "TempleofAhnQiraj" },
}

local ATLASLOOT_WORLD_BOSS = {
    ["Azuregos"]    = "AAzuregos",
    ["Lord Kazzak"] = "KKazzak",
    ["Lethon"]      = "DLethon",
    ["Emeriss"]     = "DEmeriss",
    ["Taerar"]      = "DTaerar",
    ["Ysondre"]     = "DYsondre",
}

-- Dirty-check state for RefreshMarkers
local lastContinent  = nil
local lastZone       = nil
local forceRefresh   = false
local pendingOriginC = nil
local pendingOriginZ = nil
local mmmZoneID      = nil
local mmmAtlasType   = nil
local mmmAtlasZone   = nil

-- Textures
local TEX_BASE = "Interface\\AddOns\\ModernMapMarkers-octo\\Textures\\"
local TEXTURE_MAP = {
    DUNGEON   = TEX_BASE .. "dungeon.tga",
    RAID      = TEX_BASE .. "raid.tga",
    BOAT      = TEX_BASE .. "boat.tga",
    ZEPPELIN  = TEX_BASE .. "zepp.tga",
    TRAM      = TEX_BASE .. "tram.tga",
    WORLDBOSS = TEX_BASE .. "worldboss.tga",
}
local HIGHLIGHT_MAP = {
    DUNGEON   = TEX_BASE .. "dungeon-highlight.tga",
    RAID      = TEX_BASE .. "raid-highlight.tga",
}

-- Zone name cache
local ZONE_CACHE = {}
function MMM:CacheZones()
    ZONE_CACHE[1] = { GetMapZones(1) } -- Kalimdor
    ZONE_CACHE[2] = { GetMapZones(2) } -- Eastern Kingdoms
end

-- Map multi-entrance dungeons to a single zone
local CANONICAL_ZONE = {
    ["Blackrock Depths"]      = "Burning Steppes",
    ["Lower Blackrock Spire"] = "Burning Steppes",
    ["Upper Blackrock Spire"] = "Burning Steppes",
    ["Blackwing Lair"]        = "Burning Steppes",
    ["Molten Core"]           = "Burning Steppes",
    ["Stormwind Vault"]       = "Stormwind City",
    ["Timbermaw Hold"]        = "Azshara",
}

-- Data Parsing
function MMM:BuildData()
    if self.dataBuilt then return end
    if not ModernMapMarkers_Points then return end

    MMM.Data = {}
    MMM.ZoneMarkers = {}

    local index = 1

    for contID, zones in pairs(ModernMapMarkers_Points) do
        MMM.ZoneMarkers[contID] = MMM.ZoneMarkers[contID] or {}

        for zoneName, markers in pairs(zones) do
            MMM.ZoneMarkers[contID][zoneName] = {}

            for _, m in ipairs(markers) do
                local typeUpper = string.upper(m.type or "UNKNOWN")
                if typeUpper == "ZEPP" then typeUpper = "ZEPPELIN" end

                local markerData = {
                    continent   = contID,
                    zoneName    = zoneName,
                    x           = m.x,
                    y           = m.y,
                    name        = m.name,
                    type        = typeUpper,
                    description = m.info,
                    atlasID     = m.atlasID,
                    dest        = m.dest,
                    dest2       = m.dest2,
                    id          = index
                }

                table.insert(MMM.Data, markerData)
                table.insert(MMM.ZoneMarkers[contID][zoneName], markerData)

                index = index + 1
            end
        end
    end
    self.dataBuilt = true
end

-- Get deduplicated data for dropdowns
function ModernMapMarkers_GetFlatData()
    MMM:BuildData()

    if MMM.FlatDropdownData then return MMM.FlatDropdownData end

    local filteredData = {}
    local seenNames = {}

    for _, data in ipairs(MMM.Data) do
        if data.type == "DUNGEON" or data.type == "RAID" or data.type == "WORLDBOSS" then
            local baseName = data.name or ""

            local dashIndex = string.find(baseName, " %- ")
            if dashIndex then
                baseName = string.sub(baseName, 1, dashIndex - 1)
            end

            local existingIndex = seenNames[baseName]
            if not existingIndex then
                local dropData = {}
                for k, v in pairs(data) do dropData[k] = v end
                dropData.name = baseName
                table.insert(filteredData, dropData)
                seenNames[baseName] = table.getn(filteredData)
            else
                local canon = CANONICAL_ZONE[baseName]
                if canon and data.zoneName == canon then
                    local dropData = {}
                    for k, v in pairs(data) do dropData[k] = v end
                    dropData.name = baseName
                    filteredData[existingIndex] = dropData
                end
            end
        end
    end

    MMM.FlatDropdownData = filteredData
    return filteredData
end

local function StopPinHighlight(pin)
    pin:SetScript("OnUpdate", nil)
    pin.findTimer = nil
    if pin.originalSize then
        pin:SetWidth(pin.originalSize)
        pin:SetHeight(pin.originalSize)
    end
    if pin.highlight then
        pin.highlight:SetAlpha(0)
    end
end

local function StartPinHighlight(pin)
    if not pin or not pin.originalSize then return end
    pin.highlight:SetAlpha(0)
    pin.findTimer = 0
    pin:SetScript("OnUpdate", function()
        this.findTimer = this.findTimer + arg1
        local progress = this.findTimer / FIND_HIGHLIGHT_DURATION
        if progress >= 1 then
            StopPinHighlight(this)
        else
            local envelope = 1 - progress
            local pulse    = (math.sin(progress * 3.14159 * 8) + 1) * 0.5
            local sz = this.originalSize
                + (this.originalSize * (FIND_SIZE_MULTIPLIER - 1)) * pulse * envelope
            this:SetWidth(sz)
            this:SetHeight(sz)
            this.highlight:SetAlpha(FIND_HIGHLIGHT_ALPHA * pulse * envelope)
        end
    end)
end

local function MatchesPendingHighlight(pinNameEN, target)
    if not pinNameEN or not target then return false end
    if pinNameEN == target then return true end
    local tLen = string.len(target)
    if string.len(pinNameEN) > tLen and string.sub(pinNameEN, 1, tLen) == target then
        if string.sub(pinNameEN, tLen + 1, tLen + 3) == " - " then
            return true
        end
    end
    return false
end

local function DestMatchesZone(dest, continent, zoneEN)
    return dest and dest[1] == continent and dest[2] == zoneEN
end

-- Drawing Logic
function MMM:RefreshMarkers()
    if not WorldMapFrame:IsVisible() then return end

    self:BuildData()

    local currentContinent = GetCurrentMapContinent()
    local currentZone      = GetCurrentMapZone()

    -- Dirty-check: skip full redraw if zone hasn't changed and no force refresh
    if not forceRefresh
       and currentContinent == lastContinent
       and currentZone == lastZone then
        return
    end

    lastContinent = currentContinent
    lastZone      = currentZone
    forceRefresh  = false

    if currentContinent == 0 or currentZone == 0 then
        self:HideAllMarkers()
        return
    end

    local zoneNames      = ZONE_CACHE[currentContinent]
    local currentZoneName = zoneNames and zoneNames[currentZone]
    if not currentZoneName then
        self:HideAllMarkers()
        return
    end

    -- Translate localized zone name to English key used in MarkerData
    local englishZoneName = L:GetEnglishZoneName(currentZoneName)

    local width  = WorldMapDetailFrame:GetWidth()
    local height = WorldMapDetailFrame:GetHeight()
    if width == 0 or height == 0 then
        self:HideAllMarkers()
        lastContinent = nil
        lastZone      = nil
        return
    end

    local zoneMarkers = MMM.ZoneMarkers[currentContinent] and MMM.ZoneMarkers[currentContinent][englishZoneName]

    local markerIndex = 0

    if zoneMarkers then
        for _, data in ipairs(zoneMarkers) do

            local showMarker = (MMM.filters[data.type] == true)

            -- Hide markers replaced by InstanceJournal
            if showMarker and MMM.ijInstalled then
                if data.type == "WORLDBOSS" then
                    showMarker = false
                elseif IJ_HIDDEN_MARKERS[data.name] then
                    showMarker = false
                end
            end

            -- Check faction filter
            if showMarker and (data.type == "BOAT" or data.type == "ZEPPELIN" or data.type == "TRAM") then
                if MMM.filters.FACTION ~= "ALL"
                   and data.description ~= "Neutral"
                   and data.description ~= MMM.filters.FACTION then
                    showMarker = false
                end
            end

            if showMarker then
                markerIndex = markerIndex + 1
                local marker = self:GetOrCreateMarker(markerIndex)
                StopPinHighlight(marker)

                -- Sizing
                local size = (data.type == "DUNGEON" or data.type == "RAID" or data.type == "WORLDBOSS") and 32 or 24
                marker.originalSize = size
                marker:SetWidth(size)
                marker:SetHeight(size)

                -- Position
                marker:ClearAllPoints()
                marker:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", data.x * width, -data.y * height)

                -- Texture
                local tex = TEXTURE_MAP[data.type] or "Interface\\Minimap\\POIIcons"
                if marker.lastTexture ~= tex then
                    marker.texture:SetTexture(tex)
                    marker.lastTexture = tex
                end

                local hlTex = HIGHLIGHT_MAP[data.type] or tex
                if marker.lastHighlight ~= hlTex then
                    marker.highlight:SetTexture(hlTex)
                    marker.lastHighlight = hlTex
                end
                marker.highlight:SetAlpha(0)

                -- Metadata
                marker.name        = L:GetLocalizedMarkerName(data.name)
                marker.nameEN      = data.name
                marker.description = data.description
                marker.markerType  = data.type
                marker.continent   = data.continent
                marker.zoneName    = data.zoneName
                marker.atlasID     = data.atlasID
                marker.dest        = data.dest
                marker.dest2       = data.dest2

                marker:SetAlpha(1)
                marker:Show()
            end
        end
    end

    -- Hide any excess markers from the previous zone
    self:HideMarkersFrom(markerIndex + 1)

    if MMM.pendingHighlight then
        local target = MMM.pendingHighlight
        MMM.pendingHighlight = nil
        for i = 1, markerIndex do
            local pin = self.markers[i]
            if pin and MatchesPendingHighlight(pin.nameEN, target) then
                StartPinHighlight(pin)
            end
        end
    end

    if pendingOriginC and pendingOriginZ then
        local oc = pendingOriginC
        local oz = pendingOriginZ
        pendingOriginC = nil
        pendingOriginZ = nil
        for i = 1, markerIndex do
            local pin = self.markers[i]
            if pin and (DestMatchesZone(pin.dest, oc, oz) or DestMatchesZone(pin.dest2, oc, oz)) then
                StartPinHighlight(pin)
                break
            end
        end
    end
end

-- Hide all markers in the pool
function MMM:HideAllMarkers()
    self:HideMarkersFrom(1)
end

local function ShowPinTooltip(pin)
    WorldMapTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    WorldMapTooltip:AddLine(pin.name, 1, 0.82, 0)

    if pin.description then
        if pin.markerType == "DUNGEON" or pin.markerType == "RAID" or pin.markerType == "WORLDBOSS" then
            local lvlLabel = L:GetLocalizedMarkerName("Level") or "Level"
            local desc = pin.description
            local _, _, _, maxStr = string.find(desc, "^(%d+)-(%d+)$")
            local maxLevel = tonumber(maxStr or desc)
            if maxLevel and MMM.GetLevelColor then
                local r, g, b = MMM.GetLevelColor(maxLevel)
                desc = string.format("|cff%02X%02X%02X%s|r", r * 255, g * 255, b * 255, desc)
            end
            WorldMapTooltip:AddLine(lvlLabel .. ": " .. desc, 1, 1, 1, 1)
        elseif pin.description == "Alliance" then
            WorldMapTooltip:AddLine(L:GetLocalizedMarkerName("Alliance"), 0.0, 0.47, 1.0, 1)
        elseif pin.description == "Horde" then
            WorldMapTooltip:AddLine(L:GetLocalizedMarkerName("Horde"), 1.0, 0.0, 0.0, 1)
        else
            WorldMapTooltip:AddLine(L:GetLocalizedMarkerName(pin.description), 1, 1, 1, 1)
        end
    end

    -- Click hints
    if pin.atlasID and (AtlasCFM or AtlasTW or (AtlasFrame and ATLAS_DROPDOWNS)) then
        WorldMapTooltip:AddLine("Click: Atlas", 0.5, 0.5, 0.5)
    elseif pin.dest and (not ModernMapMarkersDB or ModernMapMarkersDB.showTransportHints ~= false) then
        if pin.dest2 then
            WorldMapTooltip:AddLine("Left-click: " .. pin.dest[2], 0.5, 0.5, 0.5)
            WorldMapTooltip:AddLine("Right-click: " .. pin.dest2[2], 0.5, 0.5, 0.5)
        else
            WorldMapTooltip:AddLine("Click: Navigate to destination", 0.5, 0.5, 0.5)
        end
    end

    WorldMapTooltip:Show()
end

function MMM.RestorePinAlpha()
    for i = 1, table.getn(MMM.markers) do
        local pin = MMM.markers[i]
        if pin and pin:IsShown() then pin:SetAlpha(1) end
    end
end

function MMM.RefreshVisibleTooltip()
    for i = 1, table.getn(MMM.markers) do
        local pin = MMM.markers[i]
        if pin and pin:IsVisible() and MouseIsOver(pin) then
            ShowPinTooltip(pin)
            return
        end
    end
end

local dbInitialized = false
function MMM.EnsureDBInitialized()
    if dbInitialized then return end
    dbInitialized = true
    if type(ModernMapMarkersDB) ~= "table" then
        ModernMapMarkersDB = {}
    end
    if ModernMapMarkersDB.showTransportHints == nil then
        ModernMapMarkersDB.showTransportHints = true
    end
    if ModernMapMarkersDB.playPingSound == nil then
        ModernMapMarkersDB.playPingSound = true
    end
end

-- Hide markers from startIndex onwards
function MMM:HideMarkersFrom(startIndex)
    for i = startIndex, table.getn(self.markers) do
        if self.markers[i] then
            StopPinHighlight(self.markers[i])
            self.markers[i]:Hide()
        end
    end
end

-- Invalidate dirty-check so next RefreshMarkers does a full redraw
function MMM:InvalidateCache()
    forceRefresh = true
end

-- Get IJ instance from MMM marker English name
function MMM:GetIJInstance(nameEN)
    if not MMM.ijInstalled or not nameEN then return nil end
    local mapping = MMM_TO_IJ[nameEN]
    if not mapping then return nil end
    local dbTable = (mapping.db == "R") and IJDB.R or IJDB.DG
    if not dbTable then return nil end
    return dbTable[mapping.key]
end

local function IsWorldMapFullscreen()
    if BlackoutWorld and BlackoutWorld:IsVisible() then return true end
    return (WorldMapFrame:GetWidth()  / GetScreenWidth()  > 0.9 and
            WorldMapFrame:GetHeight() / GetScreenHeight() > 0.9)
end

local function IsCFMBackend()
    return (AtlasCFM ~= nil) and (AtlasFrame == nil or AtlasFrame == AtlasCFMFrame)
end

local function CFM_FindDropDownIndices(zoneKey)
    if not (AtlasCFM and AtlasCFM.DropDowns) then return nil, nil end
    for t, zones in pairs(AtlasCFM.DropDowns) do
        for z, id in pairs(zones) do
            if id == zoneKey then
                return t, z
            end
        end
    end
    return nil, nil
end

local function CFM_OpenMap(zoneKey)
    if not (AtlasCFM and AtlasCFM.Refresh and AtlasCFMFrame and AtlasCFMOptions) then return false end
    local t, z = CFM_FindDropDownIndices(zoneKey)
    if not t then return false end

    local opts = AtlasCFMOptions
    local savedAutoSelect = opts.AtlasAutoSelect
    opts.AtlasAutoSelect = false
    AtlasCFM.SkipRestore = true
    opts.AtlasType = t
    opts.AtlasZone = z

    if AtlasCFM.UpdateDropdownLabels then
        AtlasCFM.UpdateDropdownLabels()
    end
    AtlasCFM.Refresh()
    AtlasCFMFrame:SetFrameStrata("FULLSCREEN")
    AtlasCFMFrame:Show()

    if AtlasCFMLootItemsFrame then
        AtlasCFMLootItemsFrame.StoredElement = nil
        AtlasCFMLootItemsFrame.StoredMenu    = nil
        AtlasCFMLootItemsFrame.activeElement = nil
        AtlasCFMLootItemsFrame:Hide()
        if AtlasCFM.LootBrowserUI and AtlasCFM.LootBrowserUI.ScrollBarUpdate then
            AtlasCFM.LootBrowserUI.ScrollBarUpdate()
        end
    end

    opts.AtlasAutoSelect = savedAutoSelect
    mmmZoneID = zoneKey
    return true
end

local function NormalAtlas_FindIndices(zoneKey)
    if not ATLAS_DROPDOWNS then return nil, nil, nil end
    local alias = NORMAL_ATLAS_ALIASES[zoneKey]
    for t, zones in pairs(ATLAS_DROPDOWNS) do
        for z, id in pairs(zones) do
            if id == zoneKey then
                return t, z, id
            elseif type(alias) == "string" and id == alias then
                return t, z, id
            elseif type(alias) == "table" then
                for _, cand in ipairs(alias) do
                    if id == cand then return t, z, id end
                end
            end
        end
    end
    return nil, nil, nil
end

local function ParkAtlasOnZone(zoneID)
    if not zoneID or not AtlasOptions or not ATLAS_DROPDOWNS then return false end
    for t, zones in pairs(ATLAS_DROPDOWNS) do
        for z, id in pairs(zones) do
            if id == zoneID then
                AtlasOptions.AtlasType = t
                AtlasOptions.AtlasZone = z
                return true
            end
        end
    end
    return false
end

local function WithContinentSort(callback)
    if not AtlasOptions or not Atlas_PopulateDropdowns then
        callback()
        return
    end
    local savedSortBy = AtlasOptions.AtlasSortBy
    if savedSortBy and savedSortBy ~= 1 then
        local savedType = AtlasOptions.AtlasType
        local savedZone = AtlasOptions.AtlasZone
        AtlasOptions.AtlasSortBy = 1
        Atlas_PopulateDropdowns()
        callback()
        local openedZoneID = ATLAS_DROPDOWNS and ATLAS_DROPDOWNS[AtlasOptions.AtlasType]
                         and ATLAS_DROPDOWNS[AtlasOptions.AtlasType][AtlasOptions.AtlasZone]
        AtlasOptions.AtlasSortBy = savedSortBy
        Atlas_PopulateDropdowns()
        if not ParkAtlasOnZone(openedZoneID) then
            AtlasOptions.AtlasType = savedType
            AtlasOptions.AtlasZone = savedZone
        end
    else
        callback()
    end
end

local atlasToggleHooked = false
local function HookAtlasToggle()
    if atlasToggleHooked then return end
    atlasToggleHooked = true

    if IsCFMBackend() then
        if not (AtlasCFM and AtlasCFM.Refresh and AtlasCFM.ToggleAtlas) then return end

        local original_Refresh = AtlasCFM.Refresh
        AtlasCFM.Refresh = function()
            original_Refresh()
            if mmmZoneID and AtlasCFMOptions and AtlasCFM.DropDowns then
                local currentKey = AtlasCFM.DropDowns[AtlasCFMOptions.AtlasType]
                               and AtlasCFM.DropDowns[AtlasCFMOptions.AtlasType][AtlasCFMOptions.AtlasZone]
                if currentKey ~= mmmZoneID then
                    mmmZoneID = nil
                end
            end
        end

        local original_Toggle = AtlasCFM.ToggleAtlas
        AtlasCFM.ToggleAtlas = function()
            local frame = AtlasCFMFrame
            local willShow = frame and not frame:IsVisible()
            if willShow and mmmZoneID then
                CFM_OpenMap(mmmZoneID)
            else
                original_Toggle()
            end
        end
        if Atlas_Toggle == original_Toggle then
            Atlas_Toggle = AtlasCFM.ToggleAtlas
        end
    elseif not AtlasTW and Atlas_Toggle and AtlasFrame then
        local original_Atlas_Toggle = Atlas_Toggle
        Atlas_Toggle = function()
            local willShow = not AtlasFrame:IsVisible()
            if willShow and mmmAtlasType and AtlasOptions and AtlasOptions.AtlasSortBy ~= 1 then
                local savedType = mmmAtlasType
                local savedZone = mmmAtlasZone
                WithContinentSort(function()
                    AtlasOptions.AtlasType = savedType
                    AtlasOptions.AtlasZone = savedZone
                    original_Atlas_Toggle()
                end)
            else
                original_Atlas_Toggle()
            end
        end

        if AtlasFrameDropDownType_OnClick then
            local original_Type_OnClick = AtlasFrameDropDownType_OnClick
            AtlasFrameDropDownType_OnClick = function()
                mmmZoneID    = nil
                mmmAtlasType = nil
                mmmAtlasZone = nil
                original_Type_OnClick()
            end
        end

        if AtlasFrameDropDown_OnClick then
            local original_Zone_OnClick = AtlasFrameDropDown_OnClick
            AtlasFrameDropDown_OnClick = function()
                mmmZoneID    = nil
                mmmAtlasType = nil
                mmmAtlasZone = nil
                original_Zone_OnClick()
            end
        end
    end
end

local function PrimeAtlasSilently()
    if IsCFMBackend() or AtlasTW then return end
    if not Atlas_Refresh or not AtlasOptions then return end
    WithContinentSort(function()
        AtlasOptions.AtlasType = 1
        AtlasOptions.AtlasZone = 1
        Atlas_Refresh()
    end)
end

local primingScheduled = false
local function ScheduleAtlasPriming()
    if primingScheduled then return end
    primingScheduled = true
    local primerFrame = CreateFrame("Frame")
    primerFrame.timer = 0
    primerFrame:SetScript("OnUpdate", function()
        this.timer = this.timer + arg1
        if this.timer >= 0.5 then
            this:SetScript("OnUpdate", nil)
            PrimeAtlasSilently()
            HookAtlasToggle()
        end
    end)
end

local bossLootDelayFrame = CreateFrame("Frame")
bossLootDelayFrame:Hide()
bossLootDelayFrame:SetScript("OnUpdate", function()
    this.timer = this.timer + arg1
    if this.timer >= 0.1 then
        local lootID   = this.lootID
        local bossName = this.bossName
        this.lootID    = nil
        this.bossName  = nil
        this:Hide()
        if lootID and AtlasLoot_ShowBossLoot then
            pcall(AtlasLoot_ShowBossLoot, lootID, bossName, AtlasFrame)
        end
    end
end)

-- Atlas Integration (supports Atlas-CFM and Atlas-TW)
function MMM:OnMarkerClick(marker, button)
    -- Dungeons, raids, world bosses: open Atlas
    local atlasKey = marker.atlasID
    if atlasKey then
        if IsCFMBackend() then
            -- Atlas-CFM
            if not (AtlasCFM and AtlasCFM.Refresh and AtlasCFMFrame and AtlasCFMOptions) then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Atlas-CFM not loaded.|r")
                return
            end
            PlaySoundFile(SOUND_CLICK)
            if WorldMapFrame:IsVisible() and IsWorldMapFullscreen() then
                HideUIPanel(WorldMapFrame)
            end
            if not CFM_OpenMap(atlasKey) then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Atlas-CFM map not found for \"" .. (marker.name or atlasKey) .. "\".|r")
                return
            end
            local cfmBossID = (marker.markerType == "WORLDBOSS") and CFM_WORLD_BOSS_ID[marker.nameEN] or nil
            if cfmBossID and AtlasCFM.ScrollList and AtlasCFM.DataResolver and AtlasCFM.LootBrowserUI and AtlasCFM.LootCache then
                local zoneID = AtlasCFM.DropDowns
                           and AtlasCFM.DropDowns[AtlasCFMOptions.AtlasType]
                           and AtlasCFM.DropDowns[AtlasCFMOptions.AtlasType][AtlasCFMOptions.AtlasZone]
                for i = 1, table.getn(AtlasCFM.ScrollList) do
                    local entry = AtlasCFM.ScrollList[i]
                    if entry and entry.id == cfmBossID then
                        local lootTable = AtlasCFM.DataResolver.GetLootByElemName(entry.name, zoneID)
                        if lootTable then
                            AtlasCFMLootItemsFrame.StoredElement = entry.name
                            AtlasCFMLootItemsFrame.StoredMenu    = zoneID
                            AtlasCFMLootItemsFrame.activeElement = i
                            AtlasCFMLootItemsFrame:Show()
                            AtlasCFM.LootBrowserUI.ShowScrollBarLoading()
                            AtlasCFM.LootCache.CacheAllItems(lootTable, function()
                                AtlasCFM.LootBrowserUI.HideScrollBarLoading()
                                AtlasCFM.LootBrowserUI.ScrollBarLootUpdate()
                            end)
                            AtlasCFM.LootBrowserUI.ScrollBarUpdate()
                        end
                        break
                    end
                end
            end
            return
        elseif AtlasTW and AtlasTWOptions and AtlasTW.DropDowns then
            -- Atlas-TW (legacy)
            for typeIdx, zoneList in pairs(AtlasTW.DropDowns) do
                for zoneIdx, key in pairs(zoneList) do
                    if key == atlasKey then
                        PlaySoundFile(SOUND_CLICK)
                        if WorldMapFrame:IsVisible() and IsWorldMapFullscreen() then
                            HideUIPanel(WorldMapFrame)
                        end
                        AtlasTWOptions.AtlasType = typeIdx
                        AtlasTWOptions.AtlasZone = zoneIdx
                        AtlasTW.FrameDropDownTypeOnShow()
                        AtlasTW.FrameDropDownOnShow()
                        AtlasTW.Refresh()
                        AtlasFrame:SetFrameStrata("FULLSCREEN")
                        AtlasFrame:Show()
                        return
                    end
                end
            end
        elseif AtlasFrame and AtlasOptions and ATLAS_DROPDOWNS and Atlas_Refresh then
            local opened = false
            WithContinentSort(function()
                local atlasType, atlasZone, resolvedKey = NormalAtlas_FindIndices(atlasKey)
                if atlasType and atlasZone then
                    PlaySoundFile(SOUND_CLICK)
                    if WorldMapFrame:IsVisible() and IsWorldMapFullscreen() then
                        HideUIPanel(WorldMapFrame)
                    end
                    local savedAutoSelect = AtlasOptions.AtlasAutoSelect
                    AtlasOptions.AtlasType = atlasType
                    AtlasOptions.AtlasZone = atlasZone
                    AtlasOptions.AtlasAutoSelect = false
                    Atlas_Refresh()
                    AtlasFrame:SetFrameStrata("FULLSCREEN")
                    AtlasFrame:Show()
                    AtlasOptions.AtlasAutoSelect = savedAutoSelect
                    mmmAtlasType = atlasType
                    mmmAtlasZone = atlasZone
                    mmmZoneID    = resolvedKey
                    opened = true
                end
            end)
            if opened then
                if AtlasQuestFrame then AtlasQuestFrame:Show() end
                if marker.markerType == "WORLDBOSS" and AtlasLoot_ShowBossLoot then
                    local lootID = ATLASLOOT_WORLD_BOSS[marker.nameEN]
                    if lootID then
                        bossLootDelayFrame.timer    = 0
                        bossLootDelayFrame.lootID   = lootID
                        bossLootDelayFrame.bossName = marker.nameEN
                        bossLootDelayFrame:Show()
                    end
                end
                return
            end
        end
    end

    -- Transport: navigate world map to destination zone
    local dest = marker.dest
    if dest then
        local target = dest
        if button == "RightButton" and marker.dest2 then
            target = marker.dest2
        end
        local origC = GetCurrentMapContinent()
        local origZ = GetCurrentMapZone()
        local origZoneNames = ZONE_CACHE[origC]
        local origZoneEN = origZoneNames and origZoneNames[origZ] and L:GetEnglishZoneName(origZoneNames[origZ]) or marker.zoneName

        if not ModernMapMarkersDB or ModernMapMarkersDB.playPingSound ~= false then
            PlaySoundFile(SOUND_PING)
        end

        if target[1] == origC and target[2] == origZoneEN then
            for i = 1, table.getn(self.markers) do
                local pin = self.markers[i]
                if pin and pin:IsVisible() and pin ~= marker
                   and (DestMatchesZone(pin.dest, origC, origZoneEN) or DestMatchesZone(pin.dest2, origC, origZoneEN)) then
                    StartPinHighlight(pin)
                    break
                end
            end
            return
        end

        local zoneIndex = MMM:GetZoneIndex(target[1], target[2])
        if zoneIndex > 0 then
            pendingOriginC = origC
            pendingOriginZ = origZoneEN
            MMM:InvalidateCache()
            SetMapZoom(target[1], zoneIndex)
        end
        return
    end

    if MMM.ijInstalled then
        local instance = MMM:GetIJInstance(marker.nameEN)
        if instance then
            if button == "RightButton" then
                if not IJ_InstanceJournalFrame:IsShown() then
                    IJ_InstanceJournalFrame:Show()
                end
                if instance.Type == IJLib.InstanceType.Raid then
                    IJ_ShowRaids = true
                    PanelTemplates_SetTab(IJ_InstanceJournalFrame, 2)
                else
                    IJ_ShowRaids = false
                    PanelTemplates_SetTab(IJ_InstanceJournalFrame, 1)
                end
                IJ_ShowEncounter(instance)
                if IsWorldMapFullscreen() then HideUIPanel(WorldMapFrame) end
            else
                SetMapZoom(tonumber(instance.MapId), 1)
            end
        end
    end
end

-- Marker Pool
function MMM:GetOrCreateMarker(index)
    if not self.markers[index] then
        local marker = CreateFrame("Button", "ModernMapMarkerIcon"..index, WorldMapButton)
        marker:SetWidth(24)
        marker:SetHeight(24)
        marker:SetFrameLevel(WorldMapButton:GetFrameLevel() + 5)

        local tex = marker:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(marker)
        marker.texture = tex

        local hl = marker:CreateTexture(nil, "OVERLAY")
        hl:SetAllPoints(marker)
        hl:SetBlendMode("ADD")
        hl:SetAlpha(0)
        marker.highlight = hl

        marker:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        marker:SetScript("OnClick", function() MMM:OnMarkerClick(this, arg1) end)

        marker:SetScript("OnEnter", function()
            ShowPinTooltip(this)
            if not this.findTimer and this.originalSize then
                local newSize = this.originalSize * HOVER_SIZE_MULTIPLIER
                this:SetWidth(newSize)
                this:SetHeight(newSize)
                this.highlight:SetAlpha(HOVER_ALPHA)
            end
        end)

        marker:SetScript("OnLeave", function()
            WorldMapTooltip:Hide()
            if not this.findTimer and this.originalSize then
                this:SetWidth(this.originalSize)
                this:SetHeight(this.originalSize)
                this.highlight:SetAlpha(0)
            end
        end)

        self.markers[index] = marker
    end
    return self.markers[index]
end

-- Hooks & API
function ModernMapMarkers_SetFilter(key, state)
    if key == "ALL" then
        for _, t in ipairs(ALL_TYPES) do
            MMM.filters[t] = state
        end
    else
        MMM.filters[key] = state
    end
    MMM:InvalidateCache()
    MMM:RefreshMarkers()
end

function ModernMapMarkers_SetFactionFilter(factionStr)
    MMM.filters.FACTION = factionStr
    MMM:InvalidateCache()
    MMM:RefreshMarkers()
end

function MMM:GetZoneIndex(continentID, zoneName)
    local zones = ZONE_CACHE[continentID] or {}
    -- zoneName is English (from MarkerData), ZONE_CACHE has localized names
    local localizedName = L:GetLocalizedZoneName(zoneName)
    for i, name in ipairs(zones) do
        if name == localizedName then return i end
    end
    -- Fallback: try direct match (for enUS or untranslated zones)
    for i, name in ipairs(zones) do
        if name == zoneName then return i end
    end
    return 0
end

function ModernMapMarkers_FindMarker(dataIndex, matchName)
    MMM:BuildData()
    local data = MMM.Data[dataIndex]
    if not data then return end

    if not WorldMapFrame:IsVisible() then
        ShowUIPanel(WorldMapFrame)
    end

    if not MMM.filters[data.type] then
        MMM.filters[data.type] = true
        if ModernMapMarkers_SyncFilterUI then
            ModernMapMarkers_SyncFilterUI(data.type, true)
        end
    end

    MMM.pendingHighlight = matchName or data.name
    if not ModernMapMarkersDB or ModernMapMarkersDB.playPingSound ~= false then
        PlaySoundFile(SOUND_PING)
    end

    local zoneIndex = MMM:GetZoneIndex(data.continent, data.zoneName)
    if zoneIndex > 0 then
        if GetCurrentMapContinent() == data.continent and GetCurrentMapZone() == zoneIndex then
            MMM:InvalidateCache()
            MMM:RefreshMarkers()
        else
            MMM:InvalidateCache()
            SetMapZoom(data.continent, zoneIndex)
        end
    end
end

local original_WorldMapFrame_Update = WorldMapFrame_Update
function WorldMapFrame_Update()
    if original_WorldMapFrame_Update then
        original_WorldMapFrame_Update()
    end
    MMM:RefreshMarkers()
end

coreFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if ModernMapMarkersDB and ModernMapMarkersDB.filters then
            for k, v in pairs(ModernMapMarkersDB.filters) do
                MMM.filters[k] = v
            end
        else
            -- First load: auto-detect player faction for transport filter
            local faction = UnitFactionGroup("player")
            if faction == "Alliance" or faction == "Horde" then
                MMM.filters.FACTION = faction
            end
        end

        MMM.EnsureDBInitialized()
        L:Initialize()
        MMM:CacheZones()
        MMM:BuildData()

        -- Detect InstanceJournal
        if IJDB and IJLib and IJ_ShowInstanceEntrancesIcon then
            MMM.ijInstalled = true

            -- Build POI submap zone lookup
            if IJDB.POI then
                for _, poi in pairs(IJDB.POI) do
                    if poi.MapContinentId and poi.MapZoneId then
                        local key = tostring(poi.MapContinentId) .. ":" .. tostring(poi.MapZoneId)
                        IJ_SUBMAP_ZONES[key] = true
                    end
                end
            end

            -- Also include instance entrance locations inside other instance maps
            -- (e.g., Molten Core entrance inside BRD submap)
            local instanceMapIds = {}
            local allInstances = {}
            for _, inst in pairs(IJDB.DG or {}) do
                if inst.MapId then instanceMapIds[tostring(inst.MapId)] = true end
                table.insert(allInstances, inst)
            end
            for _, inst in pairs(IJDB.R or {}) do
                if inst.MapId then instanceMapIds[tostring(inst.MapId)] = true end
                table.insert(allInstances, inst)
            end
            for _, inst in ipairs(allInstances) do
                if inst.Entrances then
                    for _, ent in pairs(inst.Entrances) do
                        if ent.MapContinentId and ent.MapZoneId
                           and instanceMapIds[tostring(ent.MapContinentId)] then
                            local key = tostring(ent.MapContinentId) .. ":" .. tostring(ent.MapZoneId)
                            IJ_SUBMAP_ZONES[key] = true
                        end
                    end
                end
            end

            -- Hook IJ entrance markers: hide on world zones, keep in POI submaps
            -- In submaps, reskin entrance pins with MMM dungeon/raid textures
            local original_ShowEntrance = IJ_ShowInstanceEntrancesIcon
            IJ_ShowInstanceEntrancesIcon = function(instance)
                local key = tostring(GetCurrentMapContinent()) .. ":" .. tostring(GetCurrentMapZone())
                if IJ_SUBMAP_ZONES[key] then
                    original_ShowEntrance(instance)

                    -- Determine marker type and apply MMM filter
                    local isRaid = instance.Type == IJLib.InstanceType.Raid
                    local filterKey = isRaid and "RAID" or "DUNGEON"
                    local mmmTex = isRaid and TEXTURE_MAP.RAID or TEXTURE_MAP.DUNGEON

                    local cleanName = string.gsub(instance.Name or "", "%s+", "")
                    local prefix = "IJ_EntrancePin_" .. cleanName

                    for _, pin in ipairs(IJ_CreatedMapInstanceEntrance) do
                        local pinName = pin:GetName() or ""
                        if string.find(pinName, prefix, 1, true) and pin:IsVisible() then
                            -- Hide pin if MMM filter is disabled for this type
                            if not MMM.filters[filterKey] then
                                pin:Hide()
                            end
                            pin.icon:SetTexture(mmmTex)
                            pin.mmmInstance = instance

                            if not pin.mmmReskinned then
                                pin.mmmReskinned = true
                                pin.mmmTexture = mmmTex

                                local mmmHL = instance.Type == IJLib.InstanceType.Raid and HIGHLIGHT_MAP.RAID or HIGHLIGHT_MAP.DUNGEON
                                if mmmHL then
                                    pin:SetHighlightTexture(mmmHL)
                                end

                                local origOnEnter = pin:GetScript("OnEnter")
                                local origOnLeave = pin:GetScript("OnLeave")

                                pin:SetScript("OnEnter", function()
                                    if origOnEnter then origOnEnter() end
                                    this.icon:SetTexture(this.mmmTexture)

                                    -- MMM tooltip for IJ POI submap markers
                                    local inst = this.mmmInstance
                                    if inst then
                                        WorldMapTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                        WorldMapTooltip:AddLine(inst.Name or "", 1, 0.82, 0)
                                        local minLvl = inst.MinLevel or 0
                                        local maxLvl = inst.MaxLevel or 0
                                        local lvlLabel = L:GetLocalizedMarkerName("Level") or "Level"
                                        local rangeStr = minLvl .. "-" .. maxLvl
                                        if maxLvl > 0 and MMM.GetLevelColor then
                                            local r, g, b = MMM.GetLevelColor(maxLvl)
                                            rangeStr = string.format("|cff%02X%02X%02X%s|r", r * 255, g * 255, b * 255, rangeStr)
                                        end
                                        WorldMapTooltip:AddLine(lvlLabel .. ": " .. rangeStr, 1, 1, 1, 1)
                                        WorldMapTooltip:AddLine(L:GetLocalizedMarkerName("Left-Click: View Map"), 0.5, 0.5, 0.5)
                                        WorldMapTooltip:AddLine(L:GetLocalizedMarkerName("Right-Click: Instance Journal"), 0.5, 0.5, 0.5)
                                        WorldMapTooltip:Show()
                                    end
                                end)

                                pin:SetScript("OnLeave", function()
                                    if origOnLeave then origOnLeave() end
                                    this.icon:SetTexture(this.mmmTexture)
                                    WorldMapTooltip:Hide()
                                end)

                                -- Right click for IJ journal
                                pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                                local origOnClick = pin:GetScript("OnClick")
                                pin:SetScript("OnClick", function()
                                    if arg1 == "RightButton" and this.mmmInstance then
                                        local inst = this.mmmInstance
                                        if not IJ_InstanceJournalFrame:IsShown() then
                                            IJ_InstanceJournalFrame:Show()
                                        end
                                        if inst.Type == IJLib.InstanceType.Raid then
                                            IJ_ShowRaids = true
                                            PanelTemplates_SetTab(IJ_InstanceJournalFrame, 2)
                                        else
                                            IJ_ShowRaids = false
                                            PanelTemplates_SetTab(IJ_InstanceJournalFrame, 1)
                                        end
                                        IJ_ShowEncounter(inst)
                                        if IsWorldMapFullscreen() then HideUIPanel(WorldMapFrame) end
                                    else
                                        if origOnClick then origOnClick() end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end

        MMM:InvalidateCache()
        MMM:RefreshMarkers()

    elseif event == "PLAYER_ENTERING_WORLD" then
        ScheduleAtlasPriming()
        this:UnregisterEvent("PLAYER_ENTERING_WORLD")

    elseif event == "PLAYER_LOGOUT" then
        if not ModernMapMarkersDB then ModernMapMarkersDB = {} end
        ModernMapMarkersDB.filters = {}
        for k, v in pairs(MMM.filters) do
            ModernMapMarkersDB.filters[k] = v
        end
    end
end)

coreFrame:RegisterEvent("VARIABLES_LOADED")
coreFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
coreFrame:RegisterEvent("PLAYER_LOGOUT")