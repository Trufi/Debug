function init()
    local nameAddonToDebug = 'TrufiGCD'

    local debugFrame = CreateFrame('Frame', nil, UIParent)

    DebugCharacter = DebugCharacter or {}
    DebugCharacter.frame = DebugCharacter.frame or {}
    DebugCharacter.frame.offset = DebugCharacter.frame.offset or {0, 0}
    DebugCharacter.frame.point = DebugCharacter.frame.point or 'CENTER'

    debugFrame:SetPoint(DebugCharacter.frame.point, DebugCharacter.frame.offset[1], DebugCharacter.frame.offset[2])
    debugFrame:SetWidth(150)
    debugFrame:SetHeight(145)

    debugFrame:SetMovable(true)
    debugFrame:EnableMouse(true)

    local function stopDrag(...)
        debugFrame.StopMovingOrSizing(...)
        DebugCharacter.frame.point, _, _, DebugCharacter.frame.offset[1], DebugCharacter.frame.offset[2] = debugFrame:GetPoint()
    end

    debugFrame:RegisterForDrag('LeftButton')
    debugFrame:SetScript('OnDragStart', debugFrame.StartMoving)
    debugFrame:SetScript('OnDragStop', debugFrame.StopMovingOrSizing)
    debugFrame:SetScript('OnDragStop', stopDrag)

    local debugFrameTexture = debugFrame:CreateTexture(nil, 'BACKGROUND')
    debugFrameTexture:SetAllPoints(debugFrame)
    debugFrameTexture:SetTexture(0, 0, 0)
    debugFrameTexture:SetAlpha(0.6)

    local text = ''
    local textFrame = debugFrame:CreateFontString(nil, 'BACKGROUND')
    textFrame:SetFont('Fonts\\FRIZQT__.TTF', 11)
    textFrame:SetPoint('TOP', 0, -5)

    -- memory usage
    local memory = {}

    function memory:create()
    end

    function memory:update()
        UpdateAddOnMemoryUsage()
        self.current = math.ceil(GetAddOnMemoryUsage(nameAddonToDebug))

        self.min = math.min(self.min or self.current, self.current)
        self.max = math.max(self.max or self.current, self.current)

        text = text .. 'Memory usage:\nMin: ' .. self.min .. ' kB\nMax: ' .. self.max .. ' kB\nCurrent: ' .. self.current .. ' kB\n\n'
    end

    memory:create()

    -- CPU usage
    -- need CVar scriptProfile = 1
    -- go to Config-cache.wtf and add SET scriptProfile "1"
    -- or /console scriptProfile setting
    local cpu = {}

    function cpu:create()
        self.text = debugFrame:CreateFontString(nil, 'BACKGROUND')
        self.text:SetFont('Fonts\\FRIZQT__.TTF', 11)
        self.text:SetPoint('TOP', 0, -85)
    end

    function cpu:update()
        UpdateAddOnCPUUsage()
        self.current = math.ceil(GetAddOnCPUUsage(nameAddonToDebug) * 10000) / 10000

        self.min = math.min(self.min or self.current, self.current)
        self.max = math.max(self.max or self.current, self.current)

        text = text .. 'CPU usage:\nCurrent: ' .. self.current .. '\nMin: ' .. self.min .. '\nMax: ' .. self.max .. '\n\n'
    end

    cpu:create()

    -- update all
    local timeUpdateInterval = 1
    local lastTimeUpdate = 0

    local function update()
        local currentTime = GetTime()

        if currentTime - lastTimeUpdate < timeUpdateInterval then return end

        text = nameAddonToDebug .. '\n\n'

        memory:update()
        cpu:update()

        ResetCPUUsage()

        textFrame:SetText(text)

        lastTimeUpdate = currentTime
    end

    debugFrame:SetScript('OnUpdate', update)
end

local loadFrame = CreateFrame('Frame', nil, UIParent)
loadFrame:RegisterEvent('ADDON_LOADED')
loadFrame:SetScript('OnEvent', function(self, event, name) 
    if event == 'ADDON_LOADED' and name == 'Debug'then
        init()

        loadFrame:Hide()
        loadFrame:SetScript('OnEvent', nil)
        loadFrame:SetParent(nil)
        loadFrame = nil
    end
end)
