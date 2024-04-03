local BattlegroundMapIds = {
    [1460] = true, --wsg
    [1461] = true, --ab
    [1459] = true, --av
}
local HadToShutUp = false;
local RAID_WARNING_EVENT = "CHAT_MSG_RAID_WARNING" -- classic era

local function IsActive()
    return bgRwShutUpConfiguration and bgRwShutUpConfiguration["active"]
end


local RWFrame = RaidWarningFrame --RaidBossEmoteFrame
--[[* Options UI --]]
local identifier = "BG RW ShutUp"
local bgRwFrame = CreateFrame("Frame", "BGRWShutUpFrame")
bgRwFrame.name = identifier
InterfaceOptions_AddCategory(bgRwFrame)

local title = bgRwFrame:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText(identifier)

local optionsButtonEnable = CreateFrame("CheckButton", nil, bgRwFrame, "UICheckButtonTemplate")
optionsButtonEnable:SetPoint("TOPLEFT", 20, -20)
optionsButtonEnable.Text:SetText("Active")
--[[* -]]

local function TryShutUp()
    if (IsActive()) then
        local mapId = C_Map.GetBestMapForUnit("player")
        if mapId == nil then
            -- unable to retrieve mapid, retry
            C_Timer.NewTimer(3, TryShutUp, 1)
            return
        end
        if BattlegroundMapIds[mapId] then
            if not HadToShutUp then     -- might end up here multiple times so try our best to not spam...
                print("|cff707070Shut up please, |cff505050thank you. |cffFF0000<3")
            end
            RWFrame:UnregisterEvent(RAID_WARNING_EVENT)
            HadToShutUp = true
        else
            HadToShutUp = false;
        end
    end
end
local function OnClickActive()
    bgRwShutUpConfiguration["active"] = optionsButtonEnable:GetChecked()
    if (not IsActive()) then
        if (HadToShutUp) then
            RWFrame:UnregisterEvent(RAID_WARNING_EVENT)
            RWFrame:RegisterEvent(RAID_WARNING_EVENT)
        end
        HadToShutUp = false
    else
        TryShutUp()
    end
end
optionsButtonEnable:SetScript("OnClick", OnClickActive)

local function InitializeOptionsUI()
    optionsButtonEnable:SetChecked(IsActive())
end


local function OnAddonLoaded()
    if (not bgRwShutUpConfiguration) then
        bgRwShutUpConfiguration = {
            ["active"] = true
        }
    end
    InitializeOptionsUI()
    TryShutUp()
end

local function ShutUp(self, event, arg1)
    if (event == "ADDON_LOADED") then
        if (arg1 == "BGRWShutUp") then
            OnAddonLoaded()
        end
    else
        TryShutUp()
    end
end

bgRwFrame:RegisterEvent("ADDON_LOADED")
bgRwFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
bgRwFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
bgRwFrame:SetScript("OnEvent", ShutUp)
