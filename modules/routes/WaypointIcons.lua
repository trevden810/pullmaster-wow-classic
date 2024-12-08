local AddonName, PullMaster = ...
local WaypointIcons = PullMaster:NewModule("WaypointIcons", "AceEvent-3.0")

local TEXTURE_PATH = "Interface\\AddOns\\PullMaster\\textures\\waypoint"
local TEXTURES = {
    NORMAL = TEXTURE_PATH .. "_normal",
    ACTIVE = TEXTURE_PATH .. "_active",
    HOVER = TEXTURE_PATH .. "_hover"
}

local ICON_SIZE = {
    NORMAL = 24,
    LARGE = 32
}

local IconState = {
    NORMAL = 1,
    ACTIVE = 2,
    HOVER = 3
}

function WaypointIcons:OnInitialize()
    self.frames = {}
    self:RegisterMessage("WAYPOINT_ADDED", "CreateWaypointIcon")
    self:RegisterMessage("WAYPOINT_REMOVED", "RemoveWaypointIcon")
    self:RegisterMessage("WAYPOINT_UPDATED", "UpdateWaypointIcon")
end

function WaypointIcons:CreateWaypointIcon(event, waypointData)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(ICON_SIZE.NORMAL, ICON_SIZE.NORMAL)
    
    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    texture:SetTexture(TEXTURES.NORMAL)
    
    frame.waypointData = waypointData
    frame.texture = texture
    
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        self.texture:SetTexture(TEXTURES.HOVER)
        self:SetSize(ICON_SIZE.LARGE, ICON_SIZE.LARGE)
        WaypointIcons:OnIconHover(self.waypointData)
    end)
    
    frame:SetScript("OnLeave", function(self)
        self.texture:SetTexture(TEXTURES.NORMAL)
        self:SetSize(ICON_SIZE.NORMAL, ICON_SIZE.NORMAL)
        WaypointIcons:OnIconLeave(self.waypointData)
    end)
    
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            WaypointIcons:OnIconClick(self.waypointData)
        end
    end)
    
    self.frames[waypointData.id] = frame
    return frame
end

function WaypointIcons:RemoveWaypointIcon(event, waypointId)
    if self.frames[waypointId] then
        self.frames[waypointId]:Hide()
        self.frames[waypointId] = nil
    end
end

function WaypointIcons:UpdateWaypointIcon(event, waypointData)
    local frame = self.frames[waypointData.id]
    if frame then
        frame.waypointData = waypointData
        local x, y = self:GetWaypointScreenPosition(waypointData)
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        if waypointData.state == IconState.ACTIVE then
            frame.texture:SetTexture(TEXTURES.ACTIVE)
        else
            frame.texture:SetTexture(TEXTURES.NORMAL)
        end
    end
end

function WaypointIcons:GetWaypointScreenPosition(waypointData)
    local x = waypointData.x * GetScreenWidth()
    local y = waypointData.y * GetScreenHeight()
    return x, y
end

function WaypointIcons:OnIconHover(waypointData)
    PullMaster:SendMessage("WAYPOINT_HOVER", waypointData)
    GameTooltip:SetOwner(self.frames[waypointData.id], "ANCHOR_RIGHT")
    GameTooltip:AddLine(string.format("Waypoint %d", waypointData.id))
    if waypointData.note then
        GameTooltip:AddLine(waypointData.note, 1, 1, 1, true)
    end
    GameTooltip:Show()
end

function WaypointIcons:OnIconLeave(waypointData)
    PullMaster:SendMessage("WAYPOINT_LEAVE", waypointData)
    GameTooltip:Hide()
end

function WaypointIcons:OnIconClick(waypointData)
    PullMaster:SendMessage("WAYPOINT_CLICK", waypointData)
end

PullMaster.WaypointIcons = WaypointIcons