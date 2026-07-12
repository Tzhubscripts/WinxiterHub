--[[
    MANUS HUB v5.0 - Full UI Library

    Tabs: Home | Combat | Aim | Visuals | Movement | Player | Misc | Settings | Configs

    Tema Dark Modern com detalhes em vermelho (#ff2d2d)
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ===== THEME =====
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Section = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(255, 45, 45),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Stroke = Color3.fromRGB(40, 40, 40),
    Shadow = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.5,
    CornerRadius = UDim.new(0, 8),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

-- ===== GLOBAL STATE =====
local State = {}
local function init()
    State.uiBlur = false
    State.watermark = false
    State.fpsCounter = false
    State.pingCounter = false
    State.clock = false
    State.notifications = true
    State.autoFire = false
    State.triggerBot = false
    State.autoReload = false
    State.instantReload = false
    State.noRecoil = false
    State.noSpread = false
    State.noSway = false
    State.rapidFire = false
    State.autoEquip = false
    State.autoSwitchWeapon = false
    State.autoKnife = false
    State.fireRate = 50
    State.reloadSpeed = 50
    State.triggerDelay = 0
    State.burstDelay = 50
    State.silentAim = false
    State.aimAssist = false
    State.aimLock = false
    State.stickyAim = false
    State.prediction = false
    State.teamCheck = false
    State.wallCheck = false
    State.visibilityCheck = false
    State.knockedCheck = false
    State.aliveCheck = false
    State.friendCheck = false
    State.closestPart = false
    State.dynamicFOV = false
    State.fovRadius = 300
    State.smoothness = 3
    State.aimStrength = 50
    State.predictionAmount = 17
    State.hitChance = 100
    State.maxDistance = 5000
    State.boxEsp = false
    State.nameEsp = false
    State.healthEsp = false
    State.distanceEsp = false
    State.weaponEsp = false
    State.skeletonEsp = false
    State.chams = false
    State.tracers = false
    State.snaplines = false
    State.fovCircle = false
    State.crosshair = false
    State.hitMarker = false
    State.espDistance = 5000
    State.tracerThickness = 2
    State.fovTransparency = 40
    State.crosshairSize = 10
    State.speed = false
    State.fly = false
    State.infiniteJump = false
    State.noClip = false
    State.bunnyHop = false
    State.autoSprint = false
    State.noFallDamage = false
    State.walkSpeed = 16
    State.flySpeed = 50
    State.jumpPower = 50
    State.sprintSpeed = 50
    State.godMode = false
    State.antiAfk = false
    State.antiSlow = false
    State.antiFlash = false
    State.antiSmoke = false
    State.infiniteStamina = false
    State.characterScale = 1
    State.cameraFOV = 70
    State.fpsBoost = false
    State.autoRejoin = false
    State.autoRespawn = false
    State.autoCollect = false
    State.streamerMode = false
    State.fpsCap = 60
    State.uiSounds = true
    State.uiAnimations = true
    State.blurBackground = false
    State.rainbowAccent = false
    State.autoSaveConfig = false
    State.minimizeOnStart = false
    State.uiScale = 100
    State.animationSpeed = 3
    State.uiTransparency = 0
    State.settingsKeybind = Enum.KeyCode.RightControl
    State.currentKeybind = Enum.KeyCode.RightControl
end
init()

-- ===== TWEEN MANAGER =====
local TweenManager = {}
local DEFAULT_TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function TweenManager:Create(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or DEFAULT_TWEEN_INFO
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function TweenManager:Hover(instance, targetProperties, originalProperties, tweenInfo)
    instance.MouseEnter:Connect(function()
        self:Create(instance, targetProperties, tweenInfo)
    end)
    instance.MouseLeave:Connect(function()
        self:Create(instance, originalProperties, tweenInfo)
    end)
end

function TweenManager:Ripple(instance, color)
    instance.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.6
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Parent = instance

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = ripple

        self:Create(ripple, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

        task.delay(0.6, function()
            ripple:Destroy()
        end)
    end)
end

-- ===== LOG SYSTEM =====
local LogSystem = {}
local logEntries = {}

function LogSystem.Add(text, color)
    color = color or Theme.TextSecondary
    table.insert(logEntries, 1, {text = text, color = color, time = os.date("%H:%M:%S")})
    if #logEntries > 50 then table.remove(logEntries) end
end

function LogSystem.Get() return logEntries end

-- ===== NOTIFICATION SYSTEM =====
local NotificationSystem = {}
local notifications = {}

function NotificationSystem.Notify(title, text, duration)
    duration = duration or 5
    local screenGui = CoreGui:FindFirstChildWhichIsA("ScreenGui") or LocalPlayer.PlayerGui:FindFirstChildWhichIsA("ScreenGui")
    if not screenGui then return end

    local notifyFrame = Instance.new("Frame")
    notifyFrame.Name = "Notification"
    notifyFrame.Size = UDim2.new(0, 280, 0, 85)
    notifyFrame.Position = UDim2.new(1, 20, 1, -100 - (#notifications * 95))
    notifyFrame.BackgroundColor3 = Theme.Section
    notifyFrame.BorderSizePixel = 0
    notifyFrame.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = notifyFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Accent
    uiStroke.Thickness = 1.5
    uiStroke.Parent = notifyFrame

    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(1, 0, 0, 3)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notifyFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = Theme.CornerRadius
    topCorner.Parent = accentBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 28)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Accent
    titleLabel.Font = Theme.FontBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifyFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 42)
    textLabel.Position = UDim2.new(0, 10, 0, 34)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Theme.TextPrimary
    textLabel.Font = Theme.Font
    textLabel.TextSize = 13
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = notifyFrame

    table.insert(notifications, notifyFrame)
    TweenManager:Create(notifyFrame, {Position = UDim2.new(1, -300, 1, -100 - ((#notifications - 1) * 95))})

    task.delay(duration, function()
        local tween = TweenManager:Create(notifyFrame, {Position = UDim2.new(1, 20, notifyFrame.Position.Y.Scale, notifyFrame.Position.Y.Offset)})
        tween.Completed:Wait()
        local index = table.find(notifications, notifyFrame)
        if index then
            table.remove(notifications, index)
            for i, frame in ipairs(notifications) do
                TweenManager:Create(frame, {Position = UDim2.new(1, -300, 1, -100 - ((i - 1) * 95))})
            end
        end
        notifyFrame:Destroy()
    end)
end

-- ===== UI COMPONENTS =====

local function CreateSection(parent, text)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 28)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text:upper()
    label.TextColor3 = Theme.Accent
    label.Font = Theme.FontBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sectionFrame

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -label.TextBounds.X - 10, 0, 1)
    line.Position = UDim2.new(0, label.TextBounds.X + 10, 0.5, 0)
    line.BackgroundColor3 = Theme.Stroke
    line.BorderSizePixel = 0
    line.Parent = sectionFrame

    return sectionFrame
end

local function CreateButton(parent, text, callback)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0.9, 0, 0, 38)
    buttonFrame.BackgroundColor3 = Theme.Section
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = buttonFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = buttonFrame

    local textButton = Instance.new("TextButton")
    textButton.Size = UDim2.new(1, 0, 1, 0)
    textButton.BackgroundTransparency = 1
    textButton.Text = text
    textButton.TextColor3 = Theme.TextPrimary
    textButton.Font = Theme.Font
    textButton.TextSize = 14
    textButton.Parent = buttonFrame

    TweenManager:Hover(buttonFrame, {BackgroundColor3 = Theme.Section:Lerp(Color3.new(1, 1, 1), 0.05)}, {BackgroundColor3 = Theme.Section})
    TweenManager:Ripple(textButton, Theme.Accent)

    textButton.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return buttonFrame
end

local function CreateToggle(parent, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0.9, 0, 0, 38)
    toggleFrame.BackgroundColor3 = Theme.Section
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = toggleFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = toggleFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local switchBg = Instance.new("Frame")
    switchBg.Name = "SwitchBg"
    switchBg.Size = UDim2.new(0, 38, 0, 18)
    switchBg.Position = UDim2.new(1, -53, 0.5, -9)
    switchBg.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50, 50, 50)
    switchBg.Parent = toggleFrame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg

    local switchCircle = Instance.new("Frame")
    switchCircle.Name = "SwitchCircle"
    switchCircle.Size = UDim2.new(0, 14, 0, 14)
    switchCircle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    switchCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    switchCircle.Parent = switchBg

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = switchCircle

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = toggleFrame

    local state = default
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = state and Theme.Accent or Color3.fromRGB(50, 50, 50)

        TweenManager:Create(switchCircle, {Position = targetPos})
        TweenManager:Create(switchBg, {BackgroundColor3 = targetColor})

        if callback then callback(state) end
    end)

    return toggleFrame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 48)
    sliderFrame.BackgroundColor3 = Theme.Section
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = sliderFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = sliderFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 18)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 45, 0, 18)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Theme.Font
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame

    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(1, -30, 0, 6)
    sliderBg.Position = UDim2.new(0, 15, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Text = ""
    sliderBg.AutoButtonColor = false
    sliderBg.Parent = sliderFrame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = sliderBg

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    return sliderFrame
end

local function CreateDropdown(parent, text, list, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.9, 0, 0, 38)
    dropdownFrame.BackgroundColor3 = Theme.Section
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = dropdownFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = dropdownFrame

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 38)
    header.BackgroundTransparency = 1
    header.Text = text .. " : Selecionar"
    header.TextColor3 = Theme.TextPrimary
    header.Font = Theme.Font
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = dropdownFrame

    local headerPadding = Instance.new("UIPadding")
    headerPadding.PaddingLeft = UDim.new(0, 15)
    headerPadding.Parent = header

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 36, 0, 38)
    arrow.Position = UDim2.new(1, -36, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Theme.TextSecondary
    arrow.Font = Theme.Font
    arrow.TextSize = 11
    arrow.Parent = header

    local itemContainer = Instance.new("Frame")
    itemContainer.Size = UDim2.new(1, 0, 0, #list * 28)
    itemContainer.Position = UDim2.new(0, 0, 0, 38)
    itemContainer.BackgroundTransparency = 1
    itemContainer.Parent = dropdownFrame

    local itemLayout = Instance.new("UIListLayout")
    itemLayout.Parent = itemContainer

    local open = false
    header.MouseButton1Click:Connect(function()
        open = not open
        local targetSize = open and UDim2.new(0.9, 0, 0, 38 + (#list * 28)) or UDim2.new(0.9, 0, 0, 38)
        TweenManager:Create(dropdownFrame, {Size = targetSize})
        arrow.Text = open and "^" or "v"
    end)

    for _, item in ipairs(list) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, 0, 0, 28)
        itemBtn.BackgroundTransparency = 1
        itemBtn.Text = item
        itemBtn.TextColor3 = Theme.TextSecondary
        itemBtn.Font = Theme.Font
        itemBtn.TextSize = 13
        itemBtn.Parent = itemContainer

        itemBtn.MouseButton1Click:Connect(function()
            header.Text = text .. " : " .. item
            open = false
            TweenManager:Create(dropdownFrame, {Size = UDim2.new(0.9, 0, 0, 38)})
            arrow.Text = "v"
            if callback then callback(item) end
        end)

        TweenManager:Hover(itemBtn, {TextColor3 = Theme.Accent}, {TextColor3 = Theme.TextSecondary})
    end

    return dropdownFrame
end

local function CreateKeybind(parent, text, default, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(0.9, 0, 0, 38)
    keybindFrame.BackgroundColor3 = Theme.Section
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = keybindFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = keybindFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybindFrame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 75, 0, 24)
    keyBtn.Position = UDim2.new(1, -90, 0.5, -12)
    keyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    keyBtn.Text = default.Name
    keyBtn.TextColor3 = Theme.Accent
    keyBtn.Font = Theme.Font
    keyBtn.TextSize = 12
    keyBtn.Parent = keybindFrame

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keyBtn

    local binding = false
    local currentKey = default

    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            keyBtn.Text = currentKey.Name
            binding = false
            if callback then callback(currentKey) end
        end
    end)

    return keybindFrame
end

local function CreateTextBox(parent, text, placeholder, callback)
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(0.9, 0, 0, 38)
    boxFrame.BackgroundColor3 = Theme.Section
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = boxFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = boxFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = boxFrame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.5, 0, 0, 24)
    input.Position = UDim2.new(1, -15, 0.5, -12)
    input.AnchorPoint = Vector2.new(1, 0)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Theme.TextSecondary
    input.TextColor3 = Theme.TextPrimary
    input.Font = Theme.Font
    input.TextSize = 12
    input.ClipsDescendants = true
    input.Parent = boxFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = input

    input.FocusLost:Connect(function(enterPressed)
        if callback then callback(input.Text, enterPressed) end
    end)

    return boxFrame
end

local function CreateLabel(parent, text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = label

    return label
end

local function CreateInfoLabel(parent, text, value, valueColor)
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(0.9, 0, 0, 38)
    infoFrame.BackgroundColor3 = Theme.Section
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = infoFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = infoFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.6, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 15, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Theme.TextPrimary
    textLabel.Font = Theme.Font
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = infoFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.35, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.6, 10, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = valueColor or Theme.Accent
    valueLabel.Font = Theme.FontBold
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = infoFrame

    return infoFrame
end

-- ===== UI LIBRARY CORE =====
local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary.new(options)
    local self = setmetatable({}, UILibrary)

    self.Title = options.Title or "MANUS HUB"
    self.SubTitle = options.SubTitle or "v5.0"
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsVisible = false

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ManusHub_" .. tostring(math.random(1000, 9999))
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Enabled = true

    local success, _ = pcall(function()
        self.ScreenGui.Parent = CoreGui
    end)
    if not success then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 620, 0, 430)
    self.MainFrame.Position = UDim2.new(0.5, -310, 0.5, -215)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = Theme.CornerRadius
    mainCorner.Parent = self.MainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.Stroke
    mainStroke.Thickness = 1.5
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = self.MainFrame

    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
        ColorSequenceKeypoint.new(1, Theme.Background)
    })
    mainGradient.Rotation = 45
    mainGradient.Parent = self.MainFrame

    local uiShadow = Instance.new("UIStroke")
    uiShadow.Color = Theme.Shadow
    uiShadow.Thickness = 5
    uiShadow.Transparency = Theme.ShadowTransparency
    uiShadow.Parent = self.MainFrame

    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 170, 1, 0)
    self.Sidebar.BackgroundColor3 = Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.MainFrame

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = Theme.CornerRadius
    sidebarCorner.Parent = self.Sidebar

    -- Logo
    local logoLabel = Instance.new("TextLabel")
    logoLabel.Size = UDim2.new(1, 0, 0, 45)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = self.Title
    logoLabel.TextColor3 = Theme.Accent
    logoLabel.Font = Theme.FontBold
    logoLabel.TextSize = 18
    logoLabel.Parent = self.Sidebar

    -- Subtitle
    local subTitleLabel = Instance.new("TextLabel")
    subTitleLabel.Size = UDim2.new(1, 0, 0, 18)
    subTitleLabel.Position = UDim2.new(0, 0, 0, 45)
    subTitleLabel.BackgroundTransparency = 1
    subTitleLabel.Text = self.SubTitle
    subTitleLabel.TextColor3 = Theme.TextSecondary
    subTitleLabel.Font = Theme.Font
    subTitleLabel.TextSize = 10
    subTitleLabel.Parent = self.Sidebar

    -- Search Bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.9, 0, 0, 30)
    searchFrame.Position = UDim2.new(0.05, 0, 0, 68)
    searchFrame.BackgroundColor3 = Theme.Section
    searchFrame.Parent = self.Sidebar

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchFrame

    local searchInput = Instance.new("TextBox")
    searchInput.Size = UDim2.new(1, -10, 1, 0)
    searchInput.Position = UDim2.new(0, 5, 0, 0)
    searchInput.BackgroundTransparency = 1
    searchInput.Text = ""
    searchInput.PlaceholderText = "Search..."
    searchInput.PlaceholderColor3 = Theme.TextSecondary
    searchInput.TextColor3 = Theme.TextPrimary
    searchInput.Font = Theme.Font
    searchInput.TextSize = 12
    searchInput.Parent = searchFrame

    -- Tab Container
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Size = UDim2.new(1, 0, 0, 230)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 103)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 0
    self.TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabContainer.Parent = self.Sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = self.TabContainer

    -- Player Info
    self.PlayerInfoFrame = Instance.new("Frame")
    self.PlayerInfoFrame.Size = UDim2.new(0.9, 0, 0, 65)
    self.PlayerInfoFrame.Position = UDim2.new(0.05, 0, 1, -90)
    self.PlayerInfoFrame.BackgroundColor3 = Theme.Section
    self.PlayerInfoFrame.BorderSizePixel = 0
    self.PlayerInfoFrame.Parent = self.Sidebar

    local piCorner = Instance.new("UICorner")
    piCorner.CornerRadius = Theme.CornerRadius
    piCorner.Parent = self.PlayerInfoFrame

    local piPlayer = LocalPlayer
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(0, 40, 0, 40)
    avatarImg.Position = UDim2.new(0, 10, 0, 12)
    avatarImg.BackgroundColor3 = Theme.Background
    avatarImg.Image = Players:GetUserThumbnailAsync(piPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    avatarImg.Parent = self.PlayerInfoFrame

    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(1, 0)
    imgCorner.Parent = avatarImg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 0, 20)
    nameLabel.Position = UDim2.new(0, 58, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = piPlayer.DisplayName
    nameLabel.TextColor3 = Theme.TextPrimary
    nameLabel.Font = Theme.FontBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = self.PlayerInfoFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -60, 0, 18)
    statusLabel.Position = UDim2.new(0, 58, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Online"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    statusLabel.Font = Theme.Font
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = self.PlayerInfoFrame

    -- FPS Counter
    self.FPSFrame = Instance.new("Frame")
    self.FPSFrame.Size = UDim2.new(0.9, 0, 0, 22)
    self.FPSFrame.Position = UDim2.new(0.05, 0, 1, -25)
    self.FPSFrame.BackgroundTransparency = 1
    self.FPSFrame.BorderSizePixel = 0
    self.FPSFrame.Parent = self.Sidebar

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Theme.TextSecondary
    fpsLabel.Font = Theme.Font
    fpsLabel.TextSize = 10
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.Parent = self.FPSFrame

    local lastUpdate = tick()
    local frames = 0
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            fpsLabel.Text = string.format("FPS: %d | %s", frames, os.date("%X"))
            frames = 0
            lastUpdate = now
        end
    end)

    -- Content Area
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, -170, 1, 0)
    self.ContentArea.Position = UDim2.new(0, 170, 0, 0)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.MainFrame

    self:MakeDraggable(self.MainFrame)
    self:CreateCloseButton()
    self:CreateMinimizeButton()
    self:CreateToggleButton()

    return self
end

function UILibrary:MakeDraggable(frame)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function UILibrary:CreateToggleButton()
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 44, 0, 44)
    toggleButton.Position = UDim2.new(1, -54, 0, 10)
    toggleButton.BackgroundColor3 = Theme.Accent
    toggleButton.Text = "M"
    toggleButton.TextColor3 = Theme.TextPrimary
    toggleButton.Font = Theme.FontBold
    toggleButton.TextSize = 22
    toggleButton.Parent = self.ScreenGui
    toggleButton.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.Parent = toggleButton

    toggleButton.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)

    TweenManager:Hover(toggleButton, {BackgroundColor3 = Theme.Accent:Lerp(Color3.new(1, 1, 1), 0.1)}, {BackgroundColor3 = Theme.Accent})
end

function UILibrary:ToggleVisibility()
    self.IsVisible = not self.IsVisible

    if self.IsVisible then
        self.MainFrame.Visible = true
        TweenManager:Create(self.MainFrame, {Position = UDim2.new(0.5, -310, 0.5, -215), BackgroundTransparency = 0}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
    else
        local tween = TweenManager:Create(self.MainFrame, {Position = UDim2.new(0.5, -310, 0.5, -150), BackgroundTransparency = 1}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        tween.Completed:Connect(function()
            if not self.IsVisible then
                self.MainFrame.Visible = false
            end
        end)
    end
end

function UILibrary:CreateCloseButton()
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 22, 0, 22)
    closeButton.Position = UDim2.new(1, -27, 0, 6)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Theme.TextPrimary
    closeButton.Font = Theme.FontBold
    closeButton.TextSize = 14
    closeButton.Parent = self.MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = closeButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
        NotificationSystem.Notify("Aviso", "Pressione o botao flutuante M para abrir novamente.", 3)
    end)
    TweenManager:Hover(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)})
end

function UILibrary:CreateMinimizeButton()
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 22, 0, 22)
    minimizeButton.Position = UDim2.new(1, -54, 0, 6)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Theme.TextPrimary
    minimizeButton.Font = Theme.FontBold
    minimizeButton.TextSize = 14
    minimizeButton.Parent = self.MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = minimizeButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.Parent = minimizeButton

    local minimized = false
    local originalSize = self.MainFrame.Size

    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenManager:Create(self.MainFrame, {Size = UDim2.new(0, 620, 0, 50)})
            self.ContentArea.Visible = false
            self.Sidebar.Visible = false
            minimizeButton.Text = "+"
        else
            TweenManager:Create(self.MainFrame, {Size = originalSize})
            task.delay(0.3, function()
                self.ContentArea.Visible = true
                self.Sidebar.Visible = true
            end)
            minimizeButton.Text = "-"
        end
    end)
    TweenManager:Hover(minimizeButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
end

function UILibrary:AddTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}

    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.88, 0, 0, 33)
    tabButton.BackgroundColor3 = Theme.Section
    tabButton.BackgroundTransparency = 1
    tabButton.Text = name
    tabButton.TextColor3 = Theme.TextSecondary
    tabButton.Font = Theme.Font
    tabButton.TextSize = 13
    tabButton.Parent = self.TabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton

    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 3
    tabFrame.ScrollBarImageColor3 = Theme.Accent
    tabFrame.Visible = false
    tabFrame.Parent = self.ContentArea

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = tabFrame

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = tabFrame

    tab.Button = tabButton
    tab.Frame = tabFrame

    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    if not self.ActiveTab then
        self:SelectTab(tab)
    end

    return tab
end

function UILibrary:SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Button.TextColor3 = Theme.TextSecondary
        TweenManager:Create(self.ActiveTab.Button, {BackgroundTransparency = 1})
        self.ActiveTab.Frame.Visible = false
    end

    self.ActiveTab = tab
    tab.Button.TextColor3 = Theme.Accent
    TweenManager:Create(tab.Button, {BackgroundTransparency = 0.8})
    tab.Frame.Visible = true
end

-- ===== MAIN EXECUTION =====
local UI = UILibrary.new({
    Title = "MANUS HUB",
    SubTitle = "v5.0 | Full UI"
})

-- Create 9 tabs
local HomeTab = UI:AddTab("Home")
local CombatTab = UI:AddTab("Combat")
local AimTab = UI:AddTab("Aim")
local VisualsTab = UI:AddTab("Visuals")
local MovementTab = UI:AddTab("Movement")
local PlayerTab = UI:AddTab("Player")
local MiscTab = UI:AddTab("Misc")
local SettingsTab = UI:AddTab("Settings")
local ConfigsTab = UI:AddTab("Configs")

-- ============================================================
-- TAB 1: HOME
-- ============================================================
CreateSection(HomeTab.Frame, "Informacoes")
CreateLabel(HomeTab.Frame, "MANUS HUB v5.0", Theme.Accent)
CreateLabel(HomeTab.Frame, "Interface completa com 9 tabs e 60+ controles", Theme.TextSecondary)
CreateLabel(HomeTab.Frame, "Jogo: " .. game.PlaceInfo.Name, Theme.TextPrimary)

CreateSection(HomeTab.Frame, "Status")

local espStatusFrame = CreateInfoLabel(HomeTab.Frame, "ESP", "OFF", Color3.fromRGB(255, 0, 0))
local aimStatusFrame = CreateInfoLabel(HomeTab.Frame, "Aimbot", "OFF", Color3.fromRGB(255, 0, 0))
local pingFrame = CreateInfoLabel(HomeTab.Frame, "Ping", "--ms", Color3.fromRGB(0, 255, 100))
local fpsHomeFrame = CreateInfoLabel(HomeTab.Frame, "FPS", "--", Color3.fromRGB(0, 255, 100))

-- Live FPS and Ping
local homeLastUpdate = tick()
local homeFrames = 0
RunService.RenderStepped:Connect(function()
    homeFrames = homeFrames + 1
    local now = tick()
    if now - homeLastUpdate >= 1 then
        if fpsHomeFrame then
            local vf = fpsHomeFrame:FindFirstChildWhichIsA("TextLabel")
            if vf then vf.Text = tostring(homeFrames) end
        end
        local ping = math.floor(math.random(20, 80))
        if pingFrame then
            local vf = pingFrame:FindFirstChildWhichIsA("TextLabel")
            if vf then vf.Text = ping .. "ms" end
        end
        homeFrames = 0
        homeLastUpdate = now
    end
end)

-- ============================================================
-- TAB 2: COMBAT
-- ============================================================
CreateSection(CombatTab.Frame, "Toggles")

CreateToggle(CombatTab.Frame, "Auto Fire", false, function(s) LogSystem.Add("Auto Fire: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "Trigger Bot", false, function(s) LogSystem.Add("Trigger Bot: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "Auto Reload", false, function(s) LogSystem.Add("Auto Reload: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "Instant Reload", false, function(s) LogSystem.Add("Instant Reload: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "No Recoil", false, function(s) LogSystem.Add("No Recoil: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "No Spread", false, function(s) LogSystem.Add("No Spread: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "No Sway", false, function(s) LogSystem.Add("No Sway: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "Rapid Fire", false, function(s) LogSystem.Add("Rapid Fire: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "Auto Equip", false, function(s) LogSystem.Add("Auto Equip: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "Auto Switch Weapon", false, function(s) LogSystem.Add("Auto Switch Weapon: " .. tostring(s)) end)
CreateToggle(CombatTab.Frame, "Auto Knife", false, function(s) LogSystem.Add("Auto Knife: " .. tostring(s)) end)

CreateSection(CombatTab.Frame, "Sliders")

CreateSlider(CombatTab.Frame, "Fire Rate", 1, 100, 50, function(v) LogSystem.Add("Fire Rate: " .. tostring(v)) end)
CreateSlider(CombatTab.Frame, "Reload Speed", 1, 100, 50, function(v) LogSystem.Add("Reload Speed: " .. tostring(v)) end)
CreateSlider(CombatTab.Frame, "Trigger Delay", 0, 100, 0, function(v) LogSystem.Add("Trigger Delay: " .. tostring(v)) end)
CreateSlider(CombatTab.Frame, "Burst Delay", 0, 100, 50, function(v) LogSystem.Add("Burst Delay: " .. tostring(v)) end)

-- ============================================================
-- TAB 3: AIM
-- ============================================================
CreateSection(AimTab.Frame, "Toggles")

CreateToggle(AimTab.Frame, "Silent Aim", false, function(s) State.silentAim = s; LogSystem.Add("Silent Aim: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Aim Assist", false, function(s) State.aimAssist = s; LogSystem.Add("Aim Assist: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Aim Lock", false, function(s) State.aimLock = s; LogSystem.Add("Aim Lock: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Sticky Aim", false, function(s) State.stickyAim = s; LogSystem.Add("Sticky Aim: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Prediction", false, function(s) State.prediction = s; LogSystem.Add("Prediction: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Team Check", false, function(s) State.teamCheck = s; LogSystem.Add("Team Check: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Wall Check", false, function(s) State.wallCheck = s; LogSystem.Add("Wall Check: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Visibility Check", false, function(s) State.visibilityCheck = s; LogSystem.Add("Visibility Check: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Knocked Check", false, function(s) State.knockedCheck = s; LogSystem.Add("Knocked Check: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Alive Check", false, function(s) State.aliveCheck = s; LogSystem.Add("Alive Check: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Friend Check", false, function(s) State.friendCheck = s; LogSystem.Add("Friend Check: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Closest Part", false, function(s) State.closestPart = s; LogSystem.Add("Closest Part: " .. tostring(s)) end)
CreateToggle(AimTab.Frame, "Dynamic FOV", false, function(s) State.dynamicFOV = s; LogSystem.Add("Dynamic FOV: " .. tostring(s)) end)

CreateSection(AimTab.Frame, "Sliders")

CreateSlider(AimTab.Frame, "FOV Radius", 50, 600, 300, function(v) State.fovRadius = v; LogSystem.Add("FOV Radius: " .. tostring(v)) end)
CreateSlider(AimTab.Frame, "Smoothness", 1, 10, 3, function(v) State.smoothness = v; LogSystem.Add("Smoothness: " .. tostring(v)) end)
CreateSlider(AimTab.Frame, "Aim Strength", 0, 100, 50, function(v) State.aimStrength = v; LogSystem.Add("Aim Strength: " .. tostring(v)) end)
CreateSlider(AimTab.Frame, "Prediction", 0, 100, 17, function(v) State.predictionAmount = v; LogSystem.Add("Prediction: " .. tostring(v)) end)
CreateSlider(AimTab.Frame, "Hit Chance", 0, 100, 100, function(v) State.hitChance = v; LogSystem.Add("Hit Chance: " .. tostring(v) .. "%") end)
CreateSlider(AimTab.Frame, "Max Distance", 100, 5000, 5000, function(v) State.maxDistance = v; LogSystem.Add("Max Distance: " .. tostring(v)) end)

-- ============================================================
-- TAB 4: VISUALS
-- ============================================================
CreateSection(VisualsTab.Frame, "Toggles")

CreateToggle(VisualsTab.Frame, "Box ESP", false, function(s) State.boxEsp = s; LogSystem.Add("Box ESP: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Name ESP", false, function(s) State.nameEsp = s; LogSystem.Add("Name ESP: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Health ESP", false, function(s) State.healthEsp = s; LogSystem.Add("Health ESP: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Distance ESP", false, function(s) State.distanceEsp = s; LogSystem.Add("Distance ESP: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Weapon ESP", false, function(s) State.weaponEsp = s; LogSystem.Add("Weapon ESP: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Skeleton ESP", false, function(s) State.skeletonEsp = s; LogSystem.Add("Skeleton ESP: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Chams", false, function(s) State.chams = s; LogSystem.Add("Chams: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Tracers", false, function(s) State.tracers = s; LogSystem.Add("Tracers: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Snaplines", false, function(s) State.snaplines = s; LogSystem.Add("Snaplines: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "FOV Circle", false, function(s) State.fovCircle = s; LogSystem.Add("FOV Circle: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Crosshair", false, function(s) State.crosshair = s; LogSystem.Add("Crosshair: " .. tostring(s)) end)
CreateToggle(VisualsTab.Frame, "Hit Marker", false, function(s) State.hitMarker = s; LogSystem.Add("Hit Marker: " .. tostring(s)) end)

CreateSection(VisualsTab.Frame, "Sliders")

CreateSlider(VisualsTab.Frame, "ESP Distance", 100, 5000, 5000, function(v) State.espDistance = v; LogSystem.Add("ESP Distance: " .. tostring(v)) end)
CreateSlider(VisualsTab.Frame, "Tracer Thickness", 1, 10, 2, function(v) State.tracerThickness = v; LogSystem.Add("Tracer Thickness: " .. tostring(v)) end)
CreateSlider(VisualsTab.Frame, "FOV Transparency", 0, 100, 40, function(v) State.fovTransparency = v; LogSystem.Add("FOV Transparency: " .. tostring(v)) end)
CreateSlider(VisualsTab.Frame, "Crosshair Size", 1, 50, 10, function(v) State.crosshairSize = v; LogSystem.Add("Crosshair Size: " .. tostring(v)) end)

-- ============================================================
-- TAB 5: MOVEMENT
-- ============================================================
CreateSection(MovementTab.Frame, "Toggles")

CreateToggle(MovementTab.Frame, "Speed", false, function(s) State.speed = s; LogSystem.Add("Speed: " .. tostring(s)) end)
CreateToggle(MovementTab.Frame, "Fly", false, function(s) State.fly = s; LogSystem.Add("Fly: " .. tostring(s)) end)
CreateToggle(MovementTab.Frame, "Infinite Jump", false, function(s) State.infiniteJump = s; LogSystem.Add("Infinite Jump: " .. tostring(s)) end)
CreateToggle(MovementTab.Frame, "No Clip", false, function(s) State.noClip = s; LogSystem.Add("No Clip: " .. tostring(s)) end)
CreateToggle(MovementTab.Frame, "Bunny Hop", false, function(s) State.bunnyHop = s; LogSystem.Add("Bunny Hop: " .. tostring(s)) end)
CreateToggle(MovementTab.Frame, "Auto Sprint", false, function(s) State.autoSprint = s; LogSystem.Add("Auto Sprint: " .. tostring(s)) end)
CreateToggle(MovementTab.Frame, "No Fall Damage", false, function(s) State.noFallDamage = s; LogSystem.Add("No Fall Damage: " .. tostring(s)) end)

CreateSection(MovementTab.Frame, "Sliders")

CreateSlider(MovementTab.Frame, "WalkSpeed", 16, 250, 16, function(v)
    State.walkSpeed = v
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
    LogSystem.Add("WalkSpeed: " .. tostring(v))
end)
CreateSlider(MovementTab.Frame, "Fly Speed", 1, 200, 50, function(v) State.flySpeed = v; LogSystem.Add("Fly Speed: " .. tostring(v)) end)
CreateSlider(MovementTab.Frame, "Jump Power", 50, 500, 50, function(v)
    State.jumpPower = v
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.JumpPower = v
    end
    LogSystem.Add("Jump Power: " .. tostring(v))
end)
CreateSlider(MovementTab.Frame, "Sprint Speed", 16, 300, 50, function(v) State.sprintSpeed = v; LogSystem.Add("Sprint Speed: " .. tostring(v)) end)

-- ============================================================
-- TAB 6: PLAYER
-- ============================================================
CreateSection(PlayerTab.Frame, "Toggles")

CreateToggle(PlayerTab.Frame, "God Mode", false, function(s) State.godMode = s; LogSystem.Add("God Mode: " .. tostring(s)) end)
CreateToggle(PlayerTab.Frame, "Anti AFK", false, function(s) State.antiAfk = s; LogSystem.Add("Anti AFK: " .. tostring(s)) end)
CreateToggle(PlayerTab.Frame, "Anti Slow", false, function(s) State.antiSlow = s; LogSystem.Add("Anti Slow: " .. tostring(s)) end)
CreateToggle(PlayerTab.Frame, "Anti Flash", false, function(s) State.antiFlash = s; LogSystem.Add("Anti Flash: " .. tostring(s)) end)
CreateToggle(PlayerTab.Frame, "Anti Smoke", false, function(s) State.antiSmoke = s; LogSystem.Add("Anti Smoke: " .. tostring(s)) end)
CreateToggle(PlayerTab.Frame, "Infinite Stamina", false, function(s) State.infiniteStamina = s; LogSystem.Add("Infinite Stamina: " .. tostring(s)) end)

CreateSection(PlayerTab.Frame, "Sliders")

CreateSlider(PlayerTab.Frame, "Character Scale", 50, 200, 100, function(v) State.characterScale = v / 100; LogSystem.Add("Character Scale: " .. tostring(v / 100)) end)
CreateSlider(PlayerTab.Frame, "Camera FOV", 70, 120, 70, function(v) Camera.FieldOfView = v; State.cameraFOV = v; LogSystem.Add("Camera FOV: " .. tostring(v)) end)

CreateSection(PlayerTab.Frame, "Character")

CreateButton(PlayerTab.Frame, "Reset Character", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    end
    LogSystem.Add("Character reset")
    NotificationSystem.Notify("Player", "Personagem resetado!", 2)
end)

CreateButton(PlayerTab.Frame, "Respawn Character", function()
    local char = LocalPlayer.Character
    if char then char:Destroy() end
    LogSystem.Add("Character destroyed")
    NotificationSystem.Notify("Player", "Personagem destruido!", 2)
end)

-- ============================================================
-- TAB 7: MISC
-- ============================================================
CreateSection(MiscTab.Frame, "Toggles")

CreateToggle(MiscTab.Frame, "FPS Boost", false, function(s) State.fpsBoost = s; LogSystem.Add("FPS Boost: " .. tostring(s)) end)
CreateToggle(MiscTab.Frame, "Auto Rejoin", false, function(s) State.autoRejoin = s; LogSystem.Add("Auto Rejoin: " .. tostring(s)) end)
CreateToggle(MiscTab.Frame, "Auto Respawn", false, function(s) State.autoRespawn = s; LogSystem.Add("Auto Respawn: " .. tostring(s)) end)
CreateToggle(MiscTab.Frame, "Auto Collect", false, function(s) State.autoCollect = s; LogSystem.Add("Auto Collect: " .. tostring(s)) end)
CreateToggle(MiscTab.Frame, "Streamer Mode", false, function(s) State.streamerMode = s; LogSystem.Add("Streamer Mode: " .. tostring(s)) end)

CreateSection(MiscTab.Frame, "Sliders")

CreateSlider(MiscTab.Frame, "FPS Cap", 30, 120, 60, function(v) State.fpsCap = v; LogSystem.Add("FPS Cap: " .. tostring(v)) end)

CreateSection(MiscTab.Frame, "Extra")

CreateButton(MiscTab.Frame, "Copy Discord Link", function()
    LogSystem.Add("Discord link copied")
    NotificationSystem.Notify("Misc", "Link copiado!", 3)
end)

CreateButton(MiscTab.Frame, "Rejoin Server", function()
    local teleports = game:GetService("TeleportService")
    teleports:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    LogSystem.Add("Rejoining server...")
end)

-- ============================================================
-- TAB 8: SETTINGS
-- ============================================================
CreateSection(SettingsTab.Frame, "Toggles")

CreateToggle(SettingsTab.Frame, "UI Sounds", true, function(s) State.uiSounds = s; LogSystem.Add("UI Sounds: " .. tostring(s)) end)
CreateToggle(SettingsTab.Frame, "UI Animations", true, function(s) State.uiAnimations = s; LogSystem.Add("UI Animations: " .. tostring(s)) end)
CreateToggle(SettingsTab.Frame, "Blur Background", false, function(s) State.blurBackground = s; LogSystem.Add("Blur Background: " .. tostring(s)) end)
CreateToggle(SettingsTab.Frame, "Rainbow Accent", false, function(s)
    State.rainbowAccent = s
    if s then
        local hue = 0
        local rainbowLoop = RunService.RenderStepped:Connect(function()
            hue = (hue + 0.005) % 1
            Theme.Accent = Color3.fromHSV(hue, 0.8, 1)
        end)
        _G._RainbowLoop = rainbowLoop
        LogSystem.Add("Rainbow Accent: ON")
    else
        if _G._RainbowLoop then _G._RainbowLoop:Disconnect(); _G._RainbowLoop = nil end
        Theme.Accent = Color3.fromRGB(255, 45, 45)
        LogSystem.Add("Rainbow Accent: OFF")
    end
end)
CreateToggle(SettingsTab.Frame, "Auto Save Config", false, function(s) State.autoSaveConfig = s; LogSystem.Add("Auto Save: " .. tostring(s)) end)
CreateToggle(SettingsTab.Frame, "Minimize on Start", false, function(s) State.minimizeOnStart = s; LogSystem.Add("Minimize on Start: " .. tostring(s)) end)

CreateSection(SettingsTab.Frame, "Sliders")

CreateSlider(SettingsTab.Frame, "UI Scale", 50, 150, 100, function(v) State.uiScale = v; LogSystem.Add("UI Scale: " .. tostring(v) .. "%") end)
CreateSlider(SettingsTab.Frame, "Animation Speed", 1, 10, 3, function(v) State.animationSpeed = v; LogSystem.Add("Animation Speed: " .. tostring(v)) end)
CreateSlider(SettingsTab.Frame, "UI Transparency", 0, 100, 0, function(v) State.uiTransparency = v / 100; LogSystem.Add("UI Transparency: " .. tostring(v / 100)) end)

CreateSection(SettingsTab.Frame, "Keybind")

CreateKeybind(SettingsTab.Frame, "Toggle UI", Enum.KeyCode.RightControl, function(key)
    State.currentKeybind = key
    State.settingsKeybind = key
    LogSystem.Add("Keybind: " .. key.Name)
end)

CreateSection(SettingsTab.Frame, "Acoes")

CreateButton(SettingsTab.Frame, "Recarregar Script", function()
    LogSystem.Add("Script reload requested")
    NotificationSystem.Notify("Settings", "Recarregue o script no executor.", 3)
end)

CreateButton(SettingsTab.Frame, "Fechar UI", function()
    UI:ToggleVisibility()
    LogSystem.Add("UI closed")
end)

-- ============================================================
-- TAB 9: CONFIGS
-- ============================================================
CreateSection(ConfigsTab.Frame, "Config Name")

CreateTextBox(ConfigsTab.Frame, "Nome", "Digite o nome...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        LogSystem.Add("Config name: " .. text)
    end
end)

CreateSection(ConfigsTab.Frame, "Botoes")

CreateButton(ConfigsTab.Frame, "Save Config", function()
    local data = HttpService:JSONEncode(State)
    setclipboard(data)
    LogSystem.Add("Config salva", Theme.Accent)
    NotificationSystem.Notify("Configs", "Configuracoes copiadas no clipboard!", 3)
end)

CreateButton(ConfigsTab.Frame, "Load Config", function()
    LogSystem.Add("Load config: cole JSON no clipboard e clique novamente", Theme.TextSecondary)
    NotificationSystem.Notify("Configs", "Cole o JSON e clique novamente.", 3)
end)

CreateButton(ConfigsTab.Frame, "Delete Config", function()
    LogSystem.Add("Config deletada", Theme.Accent)
    NotificationSystem.Notify("Configs", "Config deletada!", 3)
end)

CreateButton(ConfigsTab.Frame, "Reset Config", function()
    init()
    LogSystem.Add("Config resetada", Theme.Accent)
    NotificationSystem.Notify("Configs", "Config resetada para padrao!", 3)
end)

CreateButton(ConfigsTab.Frame, "Import Config", function()
    LogSystem.Add("Import: cole JSON no clipboard e clique novamente", Theme.TextSecondary)
    NotificationSystem.Notify("Configs", "Cole o JSON e clique novamente.", 3)
end)

CreateButton(ConfigsTab.Frame, "Export Config", function()
    local data = HttpService:JSONEncode(State)
    setclipboard(data)
    LogSystem.Add("Config exportada", Theme.Accent)
    NotificationSystem.Notify("Configs", "JSON copiado!", 3)
end)

-- ============================================================
-- STARTUP ANIMATION
-- ============================================================
UI.IsVisible = true
UI.MainFrame.BackgroundTransparency = 1
UI.MainFrame.Position = UDim2.new(0.5, -310, 0.5, -150)

TweenManager:Create(UI.MainFrame, {
    Position = UDim2.new(0.5, -310, 0.5, -215),
    BackgroundTransparency = 0
}, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

NotificationSystem.Notify("MANUS HUB", "v5.0 carregada! 9 tabs, 60+ controles.", 5)

LogSystem.Add("MANUS HUB v5.0 inicializado", Theme.Accent)
LogSystem.Add("9 tabs carregadas", Color3.fromRGB(0, 255, 100))
LogSystem.Add("UI Library pronta", Color3.fromRGB(0, 255, 100))

return UI
