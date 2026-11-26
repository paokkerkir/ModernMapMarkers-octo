MMM = MMM or {}

local MMM_GUI = {}
local isPfUI = IsAddOnLoaded and IsAddOnLoaded("pfUI")
local L = ModernMapMarkers_Locale

local pfDrop
local pfLevelDrop
local isShaguMap
local isPfUIMapOn
local isCartographer

local CART_OFFSET_X = 0
local CART_OFFSET_Y = -10

local cartAlphaHooked = false
local function RestoreMMMAlpha()
    local filterFrame = getglobal("ModernMapMarkersFilter_Blizz")
    local findFrame   = getglobal("ModernMapMarkersFind_Blizz")
    local panel       = getglobal("ModernMapMarkersFind_Panel")
    if filterFrame then filterFrame:SetAlpha(1) end
    if findFrame   then findFrame:SetAlpha(1)   end
    if panel       then panel:SetAlpha(1)       end
    if MMM and MMM.RestorePinAlpha then MMM.RestorePinAlpha() end
end

local function HookCartographerAlpha()
    if cartAlphaHooked then return end
    if not Cartographer_LookNFeel then return end
    cartAlphaHooked = true
    if Cartographer_LookNFeel.SetAlpha then
        local origSetAlpha = Cartographer_LookNFeel.SetAlpha
        Cartographer_LookNFeel.SetAlpha = function(self, value)
            origSetAlpha(self, value)
            RestoreMMMAlpha()
        end
    end
    if Cartographer_LookNFeel.SetOverlayAlpha then
        local origSetOverlayAlpha = Cartographer_LookNFeel.SetOverlayAlpha
        Cartographer_LookNFeel.SetOverlayAlpha = function(self, value)
            origSetOverlayAlpha(self, value)
            RestoreMMMAlpha()
        end
    end
end

local function ResolveCompatState()
    pfDrop         = getglobal("pfQuestMapDropdown")
    pfLevelDrop    = pfDrop and getglobal("pfQuestMapLevelDropdown")
    local stKey    = ShaguTweaks and ShaguTweaks.T and ShaguTweaks.T["WorldMap Window"]
    isShaguMap     = stKey and ShaguTweaks_config and ShaguTweaks_config[stKey] == 1
    isPfUIMapOn    = isPfUI and not (pfUI_config and pfUI_config["disabled"] and pfUI_config["disabled"]["map"] == "1")
    isCartographer = (not pfDrop) and (Cartographer ~= nil)
    if isCartographer then HookCartographerAlpha() end
end

local function PositionDropdowns()
    local filterFrame = getglobal("ModernMapMarkersFilter_Blizz")
    local findFrame   = getglobal("ModernMapMarkersFind_Blizz")
    local findPanel   = getglobal("ModernMapMarkersFind_Panel")
    if not filterFrame then return end
    local strata = WorldMapFrame:GetFrameStrata()
    filterFrame:SetFrameStrata(strata)
    if filterFrame.backdrop then filterFrame.backdrop:SetFrameStrata(strata) end
    if findFrame then
        findFrame:SetFrameStrata(strata)
        if findFrame.backdrop then findFrame.backdrop:SetFrameStrata(strata) end
    end
    if findPanel then
        findPanel:SetFrameStrata(strata)
        if findPanel.backdrop then findPanel.backdrop:SetFrameStrata(strata) end
    end
    filterFrame:ClearAllPoints()
    if pfLevelDrop then
        filterFrame:SetPoint("TOPRIGHT", pfLevelDrop, "BOTTOMRIGHT", 0, 0)
    elseif pfDrop then
        filterFrame:SetPoint("TOPRIGHT", pfDrop, "BOTTOMRIGHT", 0, 0)
    elseif isCartographer and WorldMapDetailFrame then
        filterFrame:SetPoint("TOPRIGHT", WorldMapDetailFrame, "TOPRIGHT", CART_OFFSET_X, CART_OFFSET_Y)
    elseif isPfUIMapOn or isShaguMap then
        filterFrame:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -8, -56)
    else
        filterFrame:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -183, -79)
    end
    if findFrame then
        findFrame:ClearAllPoints()
        findFrame:SetPoint("TOPRIGHT", filterFrame, "BOTTOMRIGHT", 0, 0)
    end
end

function MMM.GetLevelColor(level)
    local delta = level - UnitLevel("player")
    if     delta >= 5  then return 1,    0.1,  0.1
    elseif delta >= 1  then return 1,    0.5,  0.25
    elseif delta >= -4 then return 1,    1,    0
    elseif delta >= -9 then return 0.25, 0.75, 0.25
    else                    return 0.6,  0.6,  0.6
    end
end

local function MakeLvlString(description)
    if not description or description == "" then return "" end
    local lvlLabel = L:GetLocalizedMarkerName("Level") or "Level"
    local _, _, _, maxStr = string.find(description, "^(%d+)-(%d+)$")
    local maxLevel = tonumber(maxStr or description)
    if maxLevel then
        local r, g, b = MMM.GetLevelColor(maxLevel)
        return string.format("%s |cff%02X%02X%02X%s|r", lvlLabel, r * 255, g * 255, b * 255, description)
    end
    return lvlLabel .. " " .. description
end

function MMM_GUI.InitializeWorldMapControls()

    -- Filter Definitions
    local filterOptions = {
        { label = L:GetLocalizedMarkerName("All Markers"),  value = "ALL",       isCheck = true, checked = true  },
        { label = L:GetLocalizedMarkerName("Dungeons"),     value = "DUNGEON",   isCheck = true, checked = true  },
        { label = L:GetLocalizedMarkerName("Raids"),        value = "RAID",      isCheck = true, checked = true  },
        { label = L:GetLocalizedMarkerName("World Bosses"), value = "WORLDBOSS", isCheck = true, checked = true  },
        { label = L:GetLocalizedMarkerName("Transports"), isHeader = true },
        { label = "  " .. L:GetLocalizedMarkerName("Boats"),      value = "BOAT",      isCheck = true, checked = true  },
        { label = "  " .. L:GetLocalizedMarkerName("Zeppelins"),  value = "ZEPPELIN",  isCheck = true, checked = true  },
        { label = "  " .. L:GetLocalizedMarkerName("Trams"),      value = "TRAM",      isCheck = true, checked = true  },
        { label = L:GetLocalizedMarkerName("Transport Faction"), isHeader = true },
        { label = "  " .. L:GetLocalizedMarkerName("Show All"),   value = "ALL",       isCheck = true, checked = true,  isRadio = true, group = "fac" },
        { label = "  " .. L:GetLocalizedMarkerName("Alliance"),   value = "Alliance",  isCheck = true, checked = false, isRadio = true, group = "fac" },
        { label = "  " .. L:GetLocalizedMarkerName("Horde"),      value = "Horde",     isCheck = true, checked = false, isRadio = true, group = "fac" },
    }

    if ModernMapMarkersDB and ModernMapMarkersDB.filters then
        local saved = ModernMapMarkersDB.filters
        for _, item in ipairs(filterOptions) do
            if item.isCheck and item.value then
                if item.isRadio then
                    if saved.FACTION ~= nil then
                        item.checked = (saved.FACTION == item.value)
                    end
                elseif item.value ~= "ALL" and saved[item.value] ~= nil then
                    item.checked = saved[item.value]
                end
            end
        end
        -- Auto-check "All Markers" if all individual filters are on
        local allOn = true
        for _, item in ipairs(filterOptions) do
            if item.isCheck and not item.isRadio and item.value ~= "ALL" then
                if not item.checked then allOn = false; break end
            end
        end
        filterOptions[1].checked = allOn
    end

    function ModernMapMarkers_SyncFilterUI(typeKey, state)
        for _, item in ipairs(filterOptions) do
            if item.isCheck and not item.isRadio and item.value == typeKey then
                item.checked = state
            end
        end
        local allOn = true
        for _, item in ipairs(filterOptions) do
            if item.isCheck and not item.isRadio and item.value ~= "ALL" then
                if not item.checked then allOn = false; break end
            end
        end
        filterOptions[1].checked = allOn
    end

    -- Determine Parent Frame (Standard or pfQuest)
    local dropdownParent = WorldMapFrame

    -- Dynamic dropdown width based on longest button label
    local MIN_DROPDOWN_WIDTH = 110
    local PADDING = 26
    local longestLabel = 0

    local buttonTexts = {
        L:GetLocalizedMarkerName("Filter Markers"),
        L:GetLocalizedMarkerName("Find Marker"),
    }
    for _, text in ipairs(buttonTexts) do
        local len = string.len(text)
        if len > longestLabel then longestLabel = len end
    end

    local dropdownWidth = math.max(MIN_DROPDOWN_WIDTH, longestLabel * 6 + PADDING)
    local dropdownButtonWidth = dropdownWidth + 5

    -- Filter Dropdown
    local filterFrame = CreateFrame("Frame", "ModernMapMarkersFilter_Blizz", dropdownParent, "UIDropDownMenuTemplate")

    filterFrame:SetFrameLevel(dropdownParent:GetFrameLevel() + 3)

    local filterBtn = getglobal(filterFrame:GetName().."Button")
    if filterBtn then
        filterBtn:SetFrameLevel(filterFrame:GetFrameLevel() + 2)
        filterBtn:SetScript("OnMouseDown", function()
            local panel = getglobal("ModernMapMarkersFind_Panel")
            if panel and panel:IsVisible() then
                panel:Hide()
            end
        end)
    end

    -- Positioning
    PositionDropdowns()

    local function InitFilterMenu(level)
        if MMM and MMM.filters then
            local allOn = true
            for _, item in ipairs(filterOptions) do
                if item.isCheck and item.value then
                    if item.isRadio then
                        if MMM.filters.FACTION ~= nil then
                            item.checked = (MMM.filters.FACTION == item.value)
                        end
                    elseif item.value ~= "ALL" then
                        if MMM.filters[item.value] ~= nil then
                            item.checked = (MMM.filters[item.value] == true)
                        end
                        if not item.checked then allOn = false end
                    end
                end
            end
            filterOptions[1].checked = allOn
        end
        for _, itemRaw in ipairs(filterOptions) do
            local item = itemRaw

            if item.isHeader then
                local info = {}
                info.text = item.label
                info.isTitle = 1
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info, level)
            else
                local info = {}
                info.text = string.gsub(item.label, "^%s+", "")
                info.value = item.value
                info.checked = item.checked
                info.keepShownOnClick = 1
                info.func = function()
                    if item.isRadio then
                        if item.checked then return end
                            for _, v in ipairs(filterOptions) do
                            if v.isRadio and v.group == item.group then v.checked = false end
                        end
                        item.checked = true
                        ModernMapMarkers_SetFactionFilter(item.value)
                    else
                        item.checked = not item.checked
                        if item.value == "ALL" then
                            for _, v in ipairs(filterOptions) do
                                if v.isCheck and not v.isRadio and v.value ~= "ALL" then
                                    v.checked = item.checked
                                end
                            end
                            ModernMapMarkers_SetFilter("ALL", item.checked)
                        else
                            ModernMapMarkers_SetFilter(item.value, item.checked)
                            local allOn = true
                            for _, v in ipairs(filterOptions) do
                                if v.isCheck and not v.isRadio and v.value ~= "ALL" then
                                    if not v.checked then allOn = false; break end
                                end
                            end
                            filterOptions[1].checked = allOn
                        end
                    end
                    if item.isRadio or item.value == "ALL" then
                        local ticker = CreateFrame("Frame")
                        ticker:SetScript("OnUpdate", function()
                            this:SetScript("OnUpdate", nil)
                            UIDropDownMenu_Initialize(filterFrame, InitFilterMenu)
                        end)
                    end
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
    UIDropDownMenu_Initialize(filterFrame, InitFilterMenu)

    UIDropDownMenu_SetWidth(dropdownWidth, filterFrame)
    UIDropDownMenu_SetButtonWidth(dropdownButtonWidth, filterFrame)
    UIDropDownMenu_SetText(L:GetLocalizedMarkerName("Filter Markers"), filterFrame)
    UIDropDownMenu_JustifyText("RIGHT", filterFrame)


    -- Find Marker Toggle (UIDropDownMenuTemplate to match filter style)
    local findFrame = CreateFrame("Frame", "ModernMapMarkersFind_Blizz", dropdownParent, "UIDropDownMenuTemplate")
    findFrame:SetFrameLevel(filterFrame:GetFrameLevel())

    local findBtn = getglobal(findFrame:GetName().."Button")
    if findBtn then findBtn:SetFrameLevel(findFrame:GetFrameLevel() + 2) end

    findFrame:SetPoint("TOPRIGHT", filterFrame, "BOTTOMRIGHT", 0, 0)

    UIDropDownMenu_SetWidth(dropdownWidth, findFrame)
    UIDropDownMenu_SetButtonWidth(dropdownButtonWidth, findFrame)
    UIDropDownMenu_SetText(L:GetLocalizedMarkerName("Find Marker"), findFrame)
    UIDropDownMenu_JustifyText("RIGHT", findFrame)

    local stickyAll = false

    if findBtn then
        findBtn:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            if CloseDropDownMenus then CloseDropDownMenus() end
            local panel = getglobal("ModernMapMarkersFind_Panel")
            if panel then
                if panel:IsVisible() then
                    panel:Hide()
                else
                    local c = GetCurrentMapContinent()
                    panel:Show()
                    UpdateFindPanel((not stickyAll and (c == 1 or c == 2 or c == 0)) and c or nil)
                end
            end
        end)
    end

    -- Find Marker Panel
    local PANEL_WIDTH      = 280
    local ROW_HEIGHT       = 16
    local MAX_VISIBLE_ROWS = 14
    local BUTTON_HEIGHT    = 20
    local BUTTON_SPACING   = 2
    local PANEL_PADDING    = 8
    local listAreaTop      = PANEL_PADDING + BUTTON_HEIGHT * 2 + BUTTON_SPACING * 2 + 4

    local FIND_TYPES = {
        { id = "DUNGEON",   label = L:GetLocalizedMarkerName("Dungeons") },
        { id = "RAID",      label = L:GetLocalizedMarkerName("Raids") },
        { id = "WORLDBOSS", label = L:GetLocalizedMarkerName("World Bosses") },
    }

    local findPanel = CreateFrame("Frame", "ModernMapMarkersFind_Panel", WorldMapFrame)
    findPanel:SetFrameLevel(filterFrame:GetFrameLevel() + 5)
    findPanel:SetWidth(PANEL_WIDTH)
    findPanel:SetPoint("TOPRIGHT", findFrame, "BOTTOMRIGHT", -16, 0)
    findPanel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    findPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    findPanel:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    findPanel:Hide()

    local activeContinent = 1
    local activeType      = "DUNGEON"
    local displayList     = {}

    local UpdateButtonStates
    local RefreshFindList

    local function CreateSelectorButton(name, parent, width, text)
        local btn = CreateFrame("Button", name, parent)
        btn:SetWidth(width)
        btn:SetHeight(BUTTON_HEIGHT)
        btn:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("CENTER", 0, 0)
        label:SetText(text)
        btn.label = label
        btn:SetScript("OnEnter", function()
            if not this.isActive then this:SetBackdropColor(0.3, 0.3, 0.3, 1) end
        end)
        btn:SetScript("OnLeave", function()
            if not this.isActive then this:SetBackdropColor(0.15, 0.15, 0.15, 1) end
        end)
        btn.isActive = false
        btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
        btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        return btn
    end

    local function SetButtonActive(btn, active)
        btn.isActive = active
        if active then
            btn:SetBackdropColor(0.2, 0.4, 0.7, 1)
            btn:SetBackdropBorderColor(0.4, 0.6, 1.0, 1)
            btn.label:SetTextColor(1, 1, 1)
        else
            btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
            btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            btn.label:SetTextColor(0.8, 0.8, 0.8)
        end
    end

    -- Continent buttons
    local kalWidth = 86
    local ekWidth  = 124
    local allWidth = PANEL_WIDTH - PANEL_PADDING * 2 - BUTTON_SPACING * 2 - kalWidth - ekWidth

    local btnKalimdor = CreateSelectorButton("MMMFind_Kalimdor", findPanel, kalWidth, L:GetLocalizedZoneName("Kalimdor"))
    btnKalimdor:SetPoint("TOPLEFT", findPanel, "TOPLEFT", PANEL_PADDING, -PANEL_PADDING)

    local btnEK = CreateSelectorButton("MMMFind_EK", findPanel, ekWidth, L:GetLocalizedZoneName("Eastern Kingdoms"))
    btnEK:SetPoint("TOPLEFT", btnKalimdor, "TOPRIGHT", BUTTON_SPACING, 0)

    local btnAll = CreateSelectorButton("MMMFind_All", findPanel, allWidth, L:GetLocalizedMarkerName("All"))
    btnAll:SetPoint("TOPLEFT", btnEK, "TOPRIGHT", BUTTON_SPACING, 0)

    -- Type buttons
    local findTypeButtons = {}
    local numTypes  = table.getn(FIND_TYPES)
    local typeWidth = (PANEL_WIDTH - PANEL_PADDING * 2 - BUTTON_SPACING * (numTypes - 1)) / numTypes
    for i = 1, numTypes do
        local tp  = FIND_TYPES[i]
        local btn = CreateSelectorButton("MMMFind_Type" .. i, findPanel, typeWidth, tp.label)
        if i == 1 then
            btn:SetPoint("TOPLEFT", btnKalimdor, "BOTTOMLEFT", 0, -BUTTON_SPACING)
        else
            btn:SetPoint("TOPLEFT", findTypeButtons[i - 1], "TOPRIGHT", BUTTON_SPACING, 0)
        end
        local t = tp.id
        btn:SetScript("OnClick", function()
            activeType = t
            UpdateButtonStates()
            RefreshFindList()
        end)
        findTypeButtons[i] = btn
    end

    -- Scroll frame for the instance list
    local scrollFrame = CreateFrame("ScrollFrame", "MMMFind_Scroll", findPanel, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", findPanel, "TOPLEFT", PANEL_PADDING, -listAreaTop)
    scrollFrame:SetPoint("BOTTOMRIGHT", findPanel, "BOTTOMRIGHT", -PANEL_PADDING - 22, PANEL_PADDING)

    -- Row buttons
    local rowButtons = {}
    for i = 1, MAX_VISIBLE_ROWS do
        local row = CreateFrame("Button", "MMMFind_Row" .. i, findPanel)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
        row:SetPoint("RIGHT", scrollFrame, "RIGHT", 0, 0)

        local hlTex = row:CreateTexture(nil, "OVERLAY")
        hlTex:SetAllPoints(row)
        hlTex:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        hlTex:SetBlendMode("ADD")
        hlTex:SetAlpha(0.7)
        hlTex:Hide()
        row.hlTex = hlTex

        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
        nameText:SetPoint("RIGHT", row, "RIGHT", -82, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetJustifyV("MIDDLE")
        row.nameText = nameText

        local lvlText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        lvlText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, 0)
        lvlText:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -4, 0)
        lvlText:SetJustifyH("RIGHT")
        lvlText:SetJustifyV("MIDDLE")
        row.lvlText = lvlText

        row:SetScript("OnEnter", function()
            if this.nameRow then this.nameRow.hlTex:Show()
            else this.hlTex:Show() end
        end)
        row:SetScript("OnLeave", function()
            if this.nameRow then this.nameRow.hlTex:Hide()
            else this.hlTex:Hide() end
        end)
        row:SetScript("OnClick", function()
            if this.dataID then
                ModernMapMarkers_FindMarker(this.dataID, this.dataName)
            end
        end)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function()
            local sb = getglobal(scrollFrame:GetName() .. "ScrollBar")
            if sb and scrollFrame:IsVisible() then
                local minVal, maxVal = sb:GetMinMaxValues()
                local nextVal = sb:GetValue() - (arg1 * ROW_HEIGHT)
                if nextVal < minVal then nextVal = minVal end
                if nextVal > maxVal then nextVal = maxVal end
                sb:SetValue(nextVal)
            end
        end)

        row:Hide()
        rowButtons[i] = row
    end

    -- Sort function: level then name
    local function sortLvl(a, b)
        local _, _, alvlStr = string.find(a.description or "", "^(%d+)")
        local _, _, blvlStr = string.find(b.description or "", "^(%d+)")
        local alvl = tonumber(alvlStr) or 0
        local blvl = tonumber(blvlStr) or 0
        if alvl == blvl then return (a.name or "") < (b.name or "") end
        return alvl < blvl
    end

    local function BuildDisplayList()
        local flatData = ModernMapMarkers_GetFlatData()
        local sorted = {}
        for _, data in ipairs(flatData) do
            if (activeContinent == 0 or data.continent == activeContinent) and data.type == activeType then
                table.insert(sorted, data)
            end
        end
        table.sort(sorted, sortLvl)

        displayList = {}
        for _, data in ipairs(sorted) do
            local baseName = L:GetLocalizedMarkerName(data.name)
            local comment
            local nl = string.find(baseName, "\n")
            if nl then
                comment  = string.sub(baseName, nl + 1)
                baseName = string.sub(baseName, 1, nl - 1)
                local _, ce = string.find(comment, "^|c%x%x%x%x%x%x%x%x")
                if ce then comment = string.sub(comment, ce + 1) end
                local rs = string.find(comment, "|r$")
                if rs then comment = string.sub(comment, 1, rs - 1) end
            end
            table.insert(displayList, {
                kind       = "name",
                text       = baseName,
                lvlText    = MakeLvlString(data.description),
                dataID     = data.id,
                dataName   = data.name,
                hasComment = (comment ~= nil),
            })
            if comment then
                table.insert(displayList, { kind = "comment", text = comment })
            end
        end
    end

    local function DrawRows()
        for i = 1, MAX_VISIBLE_ROWS do
            rowButtons[i].hlTex:Hide()
        end

        local offset = FauxScrollFrame_GetOffset(scrollFrame)
        local total  = table.getn(displayList)
        for i = 1, MAX_VISIBLE_ROWS do
            local row = rowButtons[i]
            local idx = offset + i
            if idx <= total then
                local slot = displayList[idx]
                if slot.kind == "name" then
                    row.nameRow = nil
                    row.nameText:ClearAllPoints()
                    row.nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
                    row.nameText:SetPoint("RIGHT", row, "RIGHT", -82, 0)
                    row.nameText:SetTextColor(1, 1, 1)
                    row.nameText:SetText(slot.text)
                    row.lvlText:SetText(slot.lvlText or "")
                    row.dataID   = slot.dataID
                    row.dataName = slot.dataName
                    if slot.hasComment and i < MAX_VISIBLE_ROWS then
                        row.hlTex:ClearAllPoints()
                        row.hlTex:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
                        row.hlTex:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -ROW_HEIGHT)
                    else
                        row.hlTex:ClearAllPoints()
                        row.hlTex:SetAllPoints(row)
                    end
                    row.hlTex:Hide()
                else
                    local parent = displayList[idx - 1]
                    row.nameRow = rowButtons[i - 1]
                    row.nameText:ClearAllPoints()
                    row.nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
                    row.nameText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
                    row.nameText:SetTextColor(0.55, 0.55, 0.55)
                    row.nameText:SetText(slot.text)
                    row.lvlText:SetText("")
                    row.dataID   = parent and parent.dataID or nil
                    row.dataName = parent and parent.dataName or nil
                end
                row:Show()
            else
                row.nameRow  = nil
                row.dataID   = nil
                row.dataName = nil
                row.nameText:SetText("")
                row.nameText:SetTextColor(1, 1, 1)
                row.lvlText:SetText("")
                row.hlTex:ClearAllPoints()
                row.hlTex:SetAllPoints(row)
                row.hlTex:Hide()
                row:Hide()
            end
        end
    end

    UpdateButtonStates = function(continent)
        if continent ~= nil then activeContinent = continent end
        SetButtonActive(btnKalimdor, activeContinent == 1)
        SetButtonActive(btnEK,       activeContinent == 2)
        SetButtonActive(btnAll,      activeContinent == 0)

        local flatData    = ModernMapMarkers_GetFlatData()
        local typeVisible = {}
        for i = 1, numTypes do typeVisible[i] = false end
        for _, d in ipairs(flatData) do
            if activeContinent == 0 or d.continent == activeContinent then
                for i = 1, numTypes do
                    if FIND_TYPES[i].id == d.type then typeVisible[i] = true end
                end
            end
        end

        local valid = false
        for i = 1, numTypes do
            if FIND_TYPES[i].id == activeType and typeVisible[i] then
                valid = true
                break
            end
        end
        if not valid then
            for i = 1, numTypes do
                if typeVisible[i] then
                    activeType = FIND_TYPES[i].id
                    break
                end
            end
        end

        local visible = {}
        for i = 1, numTypes do
            if typeVisible[i] then
                table.insert(visible, findTypeButtons[i])
                findTypeButtons[i]:Show()
            else
                findTypeButtons[i]:Hide()
            end
        end

        local n = table.getn(visible)
        if n > 0 then
            local btnW = (PANEL_WIDTH - PANEL_PADDING * 2 - BUTTON_SPACING * (n - 1)) / n
            for j = 1, n do
                visible[j]:SetWidth(btnW)
                visible[j]:ClearAllPoints()
                if j == 1 then
                    visible[j]:SetPoint("TOPLEFT", btnKalimdor, "BOTTOMLEFT", 0, -BUTTON_SPACING)
                else
                    visible[j]:SetPoint("TOPLEFT", visible[j - 1], "TOPRIGHT", BUTTON_SPACING, 0)
                end
            end
        end

        for i = 1, numTypes do
            SetButtonActive(findTypeButtons[i], FIND_TYPES[i].id == activeType)
        end
    end

    RefreshFindList = function()
        BuildDisplayList()
        local total = table.getn(displayList)
        findPanel:SetHeight(listAreaTop + math.min(total, MAX_VISIBLE_ROWS) * ROW_HEIGHT + PANEL_PADDING + 4)
        FauxScrollFrame_SetOffset(scrollFrame, 0)
        local sb = getglobal(scrollFrame:GetName() .. "ScrollBar")
        if sb then sb:SetValue(0) end
        FauxScrollFrame_Update(scrollFrame, total, MAX_VISIBLE_ROWS, ROW_HEIGHT)
        DrawRows()
    end

    scrollFrame:SetScript("OnVerticalScroll", function()
        FauxScrollFrame_OnVerticalScroll(ROW_HEIGHT, function()
            FauxScrollFrame_Update(scrollFrame, table.getn(displayList), MAX_VISIBLE_ROWS, ROW_HEIGHT)
            DrawRows()
        end)
    end)

    btnKalimdor:SetScript("OnClick", function()
        stickyAll = false
        activeContinent = 1
        UpdateButtonStates()
        RefreshFindList()
    end)

    btnEK:SetScript("OnClick", function()
        stickyAll = false
        activeContinent = 2
        UpdateButtonStates()
        RefreshFindList()
    end)

    btnAll:SetScript("OnClick", function()
        stickyAll = true
        activeContinent = 0
        UpdateButtonStates()
        RefreshFindList()
    end)

    function UpdateFindPanel(continent)
        UpdateButtonStates(continent)
        RefreshFindList()
    end

    -- Close panel when the world map closes
    local origOnHide = WorldMapFrame:GetScript("OnHide")
    WorldMapFrame:SetScript("OnHide", function()
        if origOnHide then origOnHide() end
        findPanel:Hide()
    end)

    UpdateButtonStates()

    -- pfUI Skinning
    if isPfUI and pfUI and pfUI.api then
        if pfUI.api.SkinDropDown then
            pfUI.api.SkinDropDown(filterFrame)
            pfUI.api.SkinDropDown(findFrame)
        end
        if pfUI.api.CreateBackdrop then
            pfUI.api.CreateBackdrop(findPanel)
            findPanel:Hide()
        end
        if pfUI.api.SkinButton then
            pfUI.api.SkinButton(btnKalimdor)
            pfUI.api.SkinButton(btnEK)
            pfUI.api.SkinButton(btnAll)
            for i = 1, numTypes do
                pfUI.api.SkinButton(findTypeButtons[i])
            end
        end
    end

    -- Apply saved visibility state
    if ModernMapMarkersDB and ModernMapMarkersDB.hideDropdowns then
        filterFrame:Hide()
        findFrame:Hide()
    end

end

-- Slash commands
SLASH_MMM1 = "/mmm"
SlashCmdList["MMM"] = function(msg)
    if MMM.EnsureDBInitialized then MMM.EnsureDBInitialized() end
    if type(ModernMapMarkersDB) ~= "table" then
        ModernMapMarkersDB = { filters = {} }
    end
    if ModernMapMarkersDB.showTransportHints == nil then
        ModernMapMarkersDB.showTransportHints = true
    end
    if ModernMapMarkersDB.playPingSound == nil then
        ModernMapMarkersDB.playPingSound = true
    end

    local cmd = string.lower(string.gsub(msg or "", "^%s*(.-)%s*$", "%1"))

    if cmd == "" then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fModern|rMapMarkers commands:")
            DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/mmm menu|r - Toggle map dropdown menus")
            DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/mmm hints|r - Toggle transport click hints")
            DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/mmm sound|r - Toggle map ping sound")
            DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/mmm zones|r - Print zone indexes")
        end
        return
    elseif cmd == "menu" then
        ModernMapMarkersDB.hideDropdowns = not ModernMapMarkersDB.hideDropdowns

        local filterFrame = getglobal("ModernMapMarkersFilter_Blizz")
        local findFrame   = getglobal("ModernMapMarkersFind_Blizz")
        local findPanel   = getglobal("ModernMapMarkersFind_Panel")

        if filterFrame and findFrame then
            if ModernMapMarkersDB.hideDropdowns then
                filterFrame:Hide()
                findFrame:Hide()
                if findPanel then findPanel:Hide() end
                if DEFAULT_CHAT_FRAME then
                    DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fModern|rMapMarkers: " .. L:GetLocalizedMarkerName("Dropdown menus hidden."))
                end
            else
                filterFrame:Show()
                findFrame:Show()
                if DEFAULT_CHAT_FRAME then
                    DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fModern|rMapMarkers: " .. L:GetLocalizedMarkerName("Dropdown menus shown."))
                end
            end
        end
        return
    elseif cmd == "hints" then
        ModernMapMarkersDB.showTransportHints = not ModernMapMarkersDB.showTransportHints
        if MMM.RefreshVisibleTooltip then MMM.RefreshVisibleTooltip() end
        if DEFAULT_CHAT_FRAME then
            local stateText = ModernMapMarkersDB.showTransportHints and "shown." or "hidden."
            DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fModern|rMapMarkers: Transport hints " .. stateText)
        end
        return
    elseif cmd == "sound" then
        ModernMapMarkersDB.playPingSound = not ModernMapMarkersDB.playPingSound
        if DEFAULT_CHAT_FRAME then
            local stateText = ModernMapMarkersDB.playPingSound and "enabled." or "disabled."
            DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fModern|rMapMarkers: Ping sound " .. stateText)
        end
        return
    elseif cmd == "zones" then
        if not DEFAULT_CHAT_FRAME then return end
        for contID = 1, 2 do
            local contName = (contID == 1) and "Kalimdor" or "Eastern Kingdoms"
            DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fModernMapMarkers:|r Zone Indexes for " .. contName .. ":")
            local zones = { GetMapZones(contID) }
            for i, zoneName in ipairs(zones) do
                DEFAULT_CHAT_FRAME:AddMessage("  " .. i .. ": " .. zoneName)
            end
        end
        return
    else
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fModern|rMapMarkers: Unknown command. Type |cFFFFD700/mmm|r for commands.")
        end
        return
    end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("VARIABLES_LOADED")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        L:Initialize()
        ResolveCompatState()
        MMM_GUI.InitializeWorldMapControls()
        this:UnregisterEvent("VARIABLES_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        ResolveCompatState()
        PositionDropdowns()
        if isShaguMap or isPfUIMapOn then
            local deferFrame = CreateFrame("Frame")
            deferFrame:SetScript("OnUpdate", function()
                this:SetScript("OnUpdate", nil)
                PositionDropdowns()
            end)
        end
        this:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

ModernMapMarkers_GUI = MMM_GUI