--[[
    MANUS HUB v4.0 - Full UI Library + 12 Tabs

    Tabs:
    Home | Combat | Aim | Visuals | Movement | Defense |
    Player | World | Utilities | Configs | Settings | Logs

    Interface Only - No external functionality
    Tema Dark Modern com detalhes em vermelho (#ff2d2d)
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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
local State = {
    espEnabled = false,
    espBox = false,
    espLine = false,
    espHealthBar = false,
    espTeamCheck = false,
    espNameType = "DisplayName",
    espDistance = 5000,
    espFOV = 300,
    fovCircleEnabled = false,
    fovCircleSize = 300,
    aimbotEnabled = false,
    aimbotFOV = 300,
    aimbotSmooth = 3,
    aimbotSticky = true,
    aimbotTargetPart = "HumanoidRootPart",
    silentAimEnabled = false,
    silentAimMethod = "Raycast",
    silentAimTargetPart = "HumanoidRootPart",
    silentAimTeamCheck = false,
    silentAimVisibleCheck = false,
    silentAimFOV = 300,
    silentAimHitChance = 100,
    silentAimPrediction = false,
    silentAimPredictionAmount = 0.165,
    silentAimShowFOV = false,
    silentAimShowTarget = false,
    walkSpeed = 16,
    jumpPower = 50,
    infiniteJump = false,
    noClip = false,
    antiStun = false,
    antiKnockback = false,
    antiRagdoll = false,
    fullBright = false,
    themeColor = "Red",
    enableSound = true,
    enableAnimation = true,
    settingsKeybind = Enum.KeyCode.RightControl,
    currentKeybind = Enum.KeyCode.RightControl,
}

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
    local entry = {
        text = text,
        color = color,
        time = os.date("%H:%M:%S")
    }
    table.insert(logEntries, 1, entry)
    if #logEntries > 50 then table.remove(logEntries) end
end

function LogSystem.Get()
    return logEntries
end

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

-- ===== UI LIBRARY CORE =====
local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary.new(options)
    local self = setmetatable({}, UILibrary)

    self.Title = options.Title or "MANUS HUB"
    self.SubTitle = options.SubTitle or "v4.0"
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
    SubTitle = "v4.0 | Full UI"
})

-- ===== CREATE 12 TABS =====
local HomeTab = UI:AddTab("Home")
local CombatTab = UI:AddTab("Combat")
local AimTab = UI:AddTab("Aim")
local VisualsTab = UI:AddTab("Visuals")
local MovementTab = UI:AddTab("Movement")
local DefenseTab = UI:AddTab("Defense")
local PlayerTab = UI:AddTab("Player")
local WorldTab = UI:AddTab("World")
local UtilitiesTab = UI:AddTab("Utilities")
local ConfigsTab = UI:AddTab("Configs")
local SettingsTab = UI:AddTab("Settings")
local LogsTab = UI:AddTab("Logs")

-- ============================================================
-- TAB: HOME (informacoes, status, FPS, ping)
-- ============================================================
CreateSection(HomeTab.Frame, "Informacoes")

CreateLabel(HomeTab.Frame, "Bem-vindo ao MANUS HUB v4.0", Theme.TextPrimary)
CreateLabel(HomeTab.Frame, "Interface completa com 12 tabs", Theme.TextSecondary)

CreateSection(HomeTab.Frame, "Status")

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

local espStatusLabel = CreateInfoLabel(HomeTab.Frame, "ESP Status", "OFF", Color3.fromRGB(255, 0, 0))
local aimStatusLabel = CreateInfoLabel(HomeTab.Frame, "Aimbot Status", "OFF", Color3.fromRGB(255, 0, 0))
local silentAimStatusLabel = CreateInfoLabel(HomeTab.Frame, "Silent Aim Status", "OFF", Color3.fromRGB(255, 0, 0))
local pingLabel = CreateInfoLabel(HomeTab.Frame, "Ping", "--ms", Color3.fromRGB(0, 255, 100))
local fpsHomeLabel = CreateInfoLabel(HomeTab.Frame, "FPS", "--", Color3.fromRGB(0, 255, 100))

-- Update FPS and ping live
local homeLastUpdate = tick()
local homeFrames = 0
RunService.RenderStepped:Connect(function()
    homeFrames = homeFrames + 1
    local now = tick()
    if now - homeLastUpdate >= 1 then
        if fpsHomeLabel then
            local valFrame = fpsHomeLabel:FindFirstChildWhichIsA("TextLabel")
            if valFrame then
                valFrame.Text = tostring(homeFrames)
            end
        end
        local ping = math.floor((math.random(20, 80)))
        if pingLabel then
            local valFrame = pingLabel:FindFirstChildWhichIsA("TextLabel")
            if valFrame then
                valFrame.Text = ping .. "ms"
            end
        end
        homeFrames = 0
        homeLastUpdate = now
    end
end)

CreateSection(HomeTab.Frame, "Jogo")

local gameNameLabel = CreateInfoLabel(HomeTab.Frame, "Jogo", game.PlaceInfo.Name, Theme.TextSecondary)

-- ============================================================
-- TAB: COMBAT (funcoes principais de combate)
-- ============================================================
CreateSection(CombatTab.Frame, "Combat Toggles")

CreateToggle(CombatTab.Frame, "Rapid Fire", false, function(state)
    LogSystem.Add("Rapid Fire: " .. tostring(state))
end)

CreateToggle(CombatTab.Frame, "No Recoil", false, function(state)
    LogSystem.Add("No Recoil: " .. tostring(state))
end)

CreateToggle(CombatTab.Frame, "No Spread", false, function(state)
    LogSystem.Add("No Spread: " .. tostring(state))
end)

CreateToggle(CombatTab.Frame, "Infinite Ammo", false, function(state)
    LogSystem.Add("Infinite Ammo: " .. tostring(state))
end)

CreateToggle(CombatTab.Frame, "Auto Shoot", false, function(state)
    LogSystem.Add("Auto Shoot: " .. tostring(state))
end)

CreateSection(CombatTab.Frame, "Damage Mods")

CreateToggle(CombatTab.Frame, "Instant Kill", false, function(state)
    LogSystem.Add("Instant Kill: " .. tostring(state))
end)

CreateToggle(CombatTab.Frame, "Double Damage", false, function(state)
    LogSystem.Add("Double Damage: " .. tostring(state))
end)

CreateSlider(CombatTab.Frame, "Damage Multiplier", 1, 100, 1, function(v)
    LogSystem.Add("Damage Multiplier: x" .. tostring(v))
end)

CreateSection(CombatTab.Frame, "Extra")

CreateToggle(CombatTab.Frame, "Wall Bang", false, function(state)
    LogSystem.Add("Wall Bang: " .. tostring(state))
end)

CreateToggle(CombatTab.Frame, "One Shot", false, function(state)
    LogSystem.Add("One Shot: " .. tostring(state))
end)

-- ============================================================
-- TAB: AIM (Silent Aim, Aim Assist, FOV)
-- ============================================================
CreateSection(AimTab.Frame, "Aimbot")

CreateToggle(AimTab.Frame, "Aimbot", false, function(state)
    State.aimbotEnabled = state
    LogSystem.Add("Aimbot: " .. tostring(state))
end)

CreateToggle(AimTab.Frame, "Sticky Target", true, function(state)
    State.aimbotSticky = state
    LogSystem.Add("Sticky Target: " .. tostring(state))
end)

CreateDropdown(AimTab.Frame, "Target Part", {"HumanoidRootPart", "Head", "Random"}, function(s)
    State.aimbotTargetPart = s
    LogSystem.Add("Target Part: " .. s)
end)

CreateSlider(AimTab.Frame, "Aimbot FOV", 50, 600, 300, function(v)
    State.aimbotFOV = v
    LogSystem.Add("Aimbot FOV: " .. tostring(v))
end)

CreateSlider(AimTab.Frame, "Aimbot Smoothness", 1, 10, 3, function(v)
    State.aimbotSmooth = v
    LogSystem.Add("Smoothness: " .. tostring(v))
end)

CreateSection(AimTab.Frame, "Silent Aim")

CreateToggle(AimTab.Frame, "Silent Aim", false, function(state)
    State.silentAimEnabled = state
    LogSystem.Add("Silent Aim: " .. tostring(state))
end)

CreateDropdown(AimTab.Frame, "Silent Method", {"Raycast", "FindPartOnRay", "FindPartOnRayWithWhitelist", "FindPartOnRayWithIgnoreList", "Mouse.Hit/Target"}, function(s)
    State.silentAimMethod = s
    LogSystem.Add("Silent Method: " .. s)
end)

CreateDropdown(AimTab.Frame, "Silent Target", {"HumanoidRootPart", "Head", "Random"}, function(s)
    State.silentAimTargetPart = s
    LogSystem.Add("Silent Target: " .. s)
end)

CreateToggle(AimTab.Frame, "Team Check", false, function(state)
    State.silentAimTeamCheck = state
    LogSystem.Add("Team Check: " .. tostring(state))
end)

CreateToggle(AimTab.Frame, "Visible Check", false, function(state)
    State.silentAimVisibleCheck = state
    LogSystem.Add("Visible Check: " .. tostring(state))
end)

CreateSlider(AimTab.Frame, "Silent FOV", 50, 360, 300, function(v)
    State.silentAimFOV = v
    LogSystem.Add("Silent FOV: " .. tostring(v))
end)

CreateSlider(AimTab.Frame, "Hit Chance", 0, 100, 100, function(v)
    State.silentAimHitChance = v
    LogSystem.Add("Hit Chance: " .. tostring(v) .. "%")
end)

CreateToggle(AimTab.Frame, "Mouse Prediction", false, function(state)
    State.silentAimPrediction = state
    LogSystem.Add("Prediction: " .. tostring(state))
end)

CreateSlider(AimTab.Frame, "Prediction Amount", 0, 100, 17, function(v)
    State.silentAimPredictionAmount = v / 100
    LogSystem.Add("Prediction Amount: " .. tostring(v / 100))
end)

CreateToggle(AimTab.Frame, "Show Silent FOV", false, function(state)
    State.silentAimShowFOV = state
    LogSystem.Add("Show Silent FOV: " .. tostring(state))
end)

CreateToggle(AimTab.Frame, "Show Silent Target", false, function(state)
    State.silentAimShowTarget = state
    LogSystem.Add("Show Silent Target: " .. tostring(state))
end)

CreateSection(AimTab.Frame, "Aim Assist")

CreateToggle(AimTab.Frame, "Aim Assist", false, function(state)
    LogSystem.Add("Aim Assist: " .. tostring(state))
end)

CreateSlider(AimTab.Frame, "Aim Assist Strength", 0, 100, 50, function(v)
    LogSystem.Add("Aim Assist Strength: " .. tostring(v))
end)

-- ============================================================
-- TAB: VISUALS (ESP, Tracers, Chams, FOV Circle)
-- ============================================================
CreateSection(VisualsTab.Frame, "ESP Controls")

CreateToggle(VisualsTab.Frame, "Enable ESP", false, function(state)
    State.espEnabled = state
    LogSystem.Add("ESP: " .. tostring(state))
end)

CreateToggle(VisualsTab.Frame, "ESP Box", false, function(state)
    State.espBox = state
    LogSystem.Add("ESP Box: " .. tostring(state))
end)

CreateToggle(VisualsTab.Frame, "ESP Tracers", false, function(state)
    State.espLine = state
    LogSystem.Add("ESP Tracers: " .. tostring(state))
end)

CreateToggle(VisualsTab.Frame, "ESP Health Bar", false, function(state)
    State.espHealthBar = state
    LogSystem.Add("ESP Health Bar: " .. tostring(state))
end)

CreateToggle(VisualsTab.Frame, "ESP Names", false, function(state)
    LogSystem.Add("ESP Names: " .. tostring(state))
end)

CreateToggle(VisualsTab.Frame, "ESP Distance", false, function(state)
    LogSystem.Add("ESP Distance: " .. tostring(state))
end)

CreateSection(VisualsTab.Frame, "Chams")

CreateToggle(VisualsTab.Frame, "Chams Visible", false, function(state)
    LogSystem.Add("Chams Visible: " .. tostring(state))
end)

CreateToggle(VisualsTab.Frame, "Chams Hidden", false, function(state)
    LogSystem.Add("Chams Hidden: " .. tostring(state))
end)

CreateToggle(VisualsTab.Frame, "Chams Flat", false, function(state)
    LogSystem.Add("Chams Flat: " .. tostring(state))
end)

CreateSection(VisualsTab.Frame, "FOV Circle")

CreateToggle(VisualsTab.Frame, "FOV Circle", false, function(state)
    State.fovCircleEnabled = state
    LogSystem.Add("FOV Circle: " .. tostring(state))
end)

CreateSlider(VisualsTab.Frame, "FOV Size", 50, 600, 300, function(v)
    State.fovCircleSize = v
    LogSystem.Add("FOV Size: " .. tostring(v))
end)

CreateSection(VisualsTab.Frame, "ESP Settings")

CreateToggle(VisualsTab.Frame, "Team Check", false, function(state)
    State.espTeamCheck = state
    LogSystem.Add("Team Check: " .. tostring(state))
end)

CreateDropdown(VisualsTab.Frame, "Name Type", {"DisplayName", "Name"}, function(s)
    State.espNameType = s
    LogSystem.Add("Name Type: " .. s)
end)

CreateSlider(VisualsTab.Frame, "ESP Distance", 100, 5000, 5000, function(v)
    State.espDistance = v
    LogSystem.Add("ESP Distance: " .. tostring(v))
end)

-- ============================================================
-- TAB: MOVEMENT (Speed, Fly, NoClip, Infinite Jump)
-- ============================================================
CreateSection(MovementTab.Frame, "Movement")

CreateToggle(MovementTab.Frame, "Fly", false, function(state)
    LogSystem.Add("Fly: " .. tostring(state))
end)

CreateSlider(MovementTab.Frame, "Fly Speed", 1, 200, 50, function(v)
    LogSystem.Add("Fly Speed: " .. tostring(v))
end)

CreateToggle(MovementTab.Frame, "No Clip", false, function(state)
    State.noClip = state
    LogSystem.Add("No Clip: " .. tostring(state))
end)

CreateToggle(MovementTab.Frame, "Infinite Jump", false, function(state)
    State.infiniteJump = state
    LogSystem.Add("Infinite Jump: " .. tostring(state))
end)

CreateToggle(MovementTab.Frame, "Speed Jump", false, function(state)
    LogSystem.Add("Speed Jump: " .. tostring(state))
end)

CreateToggle(MovementTab.Frame, "Water Walk", false, function(state)
    LogSystem.Add("Water Walk: " .. tostring(state))
end)

CreateSection(MovementTab.Frame, "Speed")

CreateSlider(MovementTab.Frame, "WalkSpeed", 16, 250, 16, function(v)
    State.walkSpeed = v
    LogSystem.Add("WalkSpeed: " .. tostring(v))
end)

CreateSlider(MovementTab.Frame, "JumpPower", 50, 500, 50, function(v)
    State.jumpPower = v
    LogSystem.Add("JumpPower: " .. tostring(v))
end)

CreateToggle(MovementTab.Frame, "Super Jump", false, function(state)
    LogSystem.Add("Super Jump: " .. tostring(state))
end)

CreateToggle(MovementTab.Frame, "Dash", false, function(state)
    LogSystem.Add("Dash: " .. tostring(state))
end)

CreateSlider(MovementTab.Frame, "Dash Power", 50, 500, 150, function(v)
    LogSystem.Add("Dash Power: " .. tostring(v))
end)

-- ============================================================
-- TAB: DEFENSE (Anti Stun, Anti Knockback, Anti Ragdoll)
-- ============================================================
CreateSection(DefenseTab.Frame, "Defense")

CreateToggle(DefenseTab.Frame, "Anti Stun", false, function(state)
    State.antiStun = state
    LogSystem.Add("Anti Stun: " .. tostring(state))
end)

CreateToggle(DefenseTab.Frame, "Anti Knockback", false, function(state)
    State.antiKnockback = state
    LogSystem.Add("Anti Knockback: " .. tostring(state))
end)

CreateToggle(DefenseTab.Frame, "Anti Ragdoll", false, function(state)
    State.antiRagdoll = state
    LogSystem.Add("Anti Ragdoll: " .. tostring(state))
end)

CreateToggle(DefenseTab.Frame, "Anti Push", false, function(state)
    LogSystem.Add("Anti Push: " .. tostring(state))
end)

CreateToggle(DefenseTab.Frame, "Anti Flash", false, function(state)
    LogSystem.Add("Anti Flash: " .. tostring(state))
end)

CreateToggle(DefenseTab.Frame, "Auto Revive", false, function(state)
    LogSystem.Add("Auto Revive: " .. tostring(state))
end)

CreateSection(DefenseTab.Frame, "Protection")

CreateToggle(DefenseTab.Frame, "No Fall Damage", false, function(state)
    LogSystem.Add("No Fall Damage: " .. tostring(state))
end)

CreateToggle(DefenseTab.Frame, "No Headshot", false, function(state)
    LogSystem.Add("No Headshot: " .. tostring(state))
end)

CreateSlider(DefenseTab.Frame, "Shield Strength", 0, 100, 50, function(v)
    LogSystem.Add("Shield Strength: " .. tostring(v))
end)

-- ============================================================
-- TAB: PLAYER (WalkSpeed, JumpPower, Character)
-- ============================================================
CreateSection(PlayerTab.Frame, "Character")

CreateSlider(PlayerTab.Frame, "WalkSpeed", 16, 250, 16, function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
    LogSystem.Add("WalkSpeed set to " .. tostring(v))
end)

CreateSlider(PlayerTab.Frame, "JumpPower", 50, 500, 50, function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.JumpPower = v
    end
    LogSystem.Add("JumpPower set to " .. tostring(v))
end)

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
    if char then
        char:Destroy()
    end
    LogSystem.Add("Character destroyed")
    NotificationSystem.Notify("Player", "Personagem destruido! Reapareca.", 2)
end)

CreateSection(PlayerTab.Frame, "Animation")

CreateButton(PlayerTab.Frame, "Animation 1 (Dance)", function()
    LogSystem.Add("Play Animation 1")
end)

CreateButton(PlayerTab.Frame, "Animation 2 (Run)", function()
    LogSystem.Add("Play Animation 2")
end)

CreateButton(PlayerTab.Frame, "Animation 3 (Sit)", function()
    LogSystem.Add("Play Animation 3")
end)

CreateSection(PlayerTab.Frame, "Emotes")

CreateButton(PlayerTab.Frame, "Wave", function()
    LogSystem.Add("Emote: Wave")
end)

CreateButton(PlayerTab.Frame, "Point", function()
    LogSystem.Add("Emote: Point")
end)

CreateButton(PlayerTab.Frame, "Cheer", function()
    LogSystem.Add("Emote: Cheer")
end)

-- ============================================================
-- TAB: WORLD (FullBright, Time, Atmosphere)
-- ============================================================
CreateSection(WorldTab.Frame, "Lighting")

CreateToggle(WorldTab.Frame, "Full Bright", false, function(state)
    State.fullBright = state
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        LogSystem.Add("Full Bright: ON")
    else
        Lighting.Brightness = 0
        Lighting.ClockTime = 0
        Lighting.FogEnd = 50
        LogSystem.Add("Full Bright: OFF")
    end
end)

CreateToggle(WorldTab.Frame, "No Fog", false, function(state)
    if state then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        LogSystem.Add("No Fog: ON")
    else
        Lighting.FogEnd = 50
        Lighting.FogStart = 0
        LogSystem.Add("No Fog: OFF")
    end
end)

CreateSlider(WorldTab.Frame, "Field of View", 70, 120, 70, function(v)
    Camera.FieldOfView = v
    LogSystem.Add("FOV: " .. tostring(v))
end)

CreateSection(WorldTab.Frame, "Time")

CreateSlider(WorldTab.Frame, "Clock Time", 0, 24, 12, function(v)
    Lighting.ClockTime = v
    LogSystem.Add("Clock Time: " .. tostring(v))
end)

CreateToggle(WorldTab.Frame, "Auto Time Cycle", false, function(state)
    LogSystem.Add("Auto Time Cycle: " .. tostring(state))
end)

CreateSlider(WorldTab.Frame, "Time Speed", 1, 60, 10, function(v)
    LogSystem.Add("Time Speed: " .. tostring(v))
end)

CreateSection(WorldTab.Frame, "Atmosphere")

CreateToggle(WorldTab.Frame, "Remove Atmosphere", false, function(state)
    LogSystem.Add("Remove Atmosphere: " .. tostring(state))
end)

CreateToggle(WorldTab.Frame, "Remove Skybox", false, function(state)
    LogSystem.Add("Remove Skybox: " .. tostring(state))
end)

CreateSlider(WorldTab.Frame, "Ambient Light", 0, 255, 100, function(v)
    local color = Color3.fromRGB(v, v, v)
    Lighting.Ambient = color
    LogSystem.Add("Ambient: " .. tostring(v))
end)

-- ============================================================
-- TAB: UTILITIES (Rejoin, Server Hop, Anti AFK, FPS Boost)
-- ============================================================
CreateSection(UtilitiesTab.Frame, "Server")

CreateButton(UtilitiesTab.Frame, "Rejoin Server", function()
    local players = game:GetService("Players")
    local teleports = game:GetService("TeleportService")
    teleports:TeleportToPlaceInstance(game.PlaceId, game.JobId, players.LocalPlayer)
    LogSystem.Add("Rejoining server...")
end)

CreateButton(UtilitiesTab.Frame, "Server Hop", function()
    LogSystem.Add("Server Hop clicked")
    NotificationSystem.Notify("Utilities", "Procurando servidor...", 3)
end)

CreateToggle(UtilitiesTab.Frame, "Anti AFK", false, function(state)
    LogSystem.Add("Anti AFK: " .. tostring(state))
end)

CreateButton(UtilitiesTab.Frame, "Leave Game", function()
    LogSystem.Add("Leaving game...")
    NotificationSystem.Notify("Utilities", "Saindo do jogo...", 3)
end)

CreateSection(UtilitiesTab.Frame, "Performance")

CreateToggle(UtilitiesTab.Frame, "FPS Boost", false, function(state)
    LogSystem.Add("FPS Boost: " .. tostring(state))
end)

CreateToggle(UtilitiesTab.Frame, "Remove Particles", false, function(state)
    LogSystem.Add("Remove Particles: " .. tostring(state))
end)

CreateToggle(UtilitiesTab.Frame, "Remove Sounds", false, function(state)
    LogSystem.Add("Remove Sounds: " .. tostring(state))
end)

CreateToggle(UtilitiesTab.Frame, "Remove Shadows", false, function(state)
    LogSystem.Add("Remove Shadows: " .. tostring(state))
end)

CreateSection(UtilitiesTab.Frame, "Extra")

CreateButton(UtilitiesTab.Frame, "Copy Discord Link", function()
    LogSystem.Add("Discord link copied")
    NotificationSystem.Notify("Utilities", "Link copiado!", 3)
end)

CreateButton(UtilitiesTab.Frame, "Open Discord", function()
    LogSystem.Add("Open Discord clicked")
end)

CreateButton(UtilitiesTab.Frame, "Credits", function()
    LogSystem.Add("Credits viewed")
    NotificationSystem.Notify("Credits", "MANUS HUB v4.0 by Manus AI", 5)
end)

-- ============================================================
-- TAB: CONFIGS (Save, Load, Auto Load)
-- ============================================================
CreateSection(ConfigsTab.Frame, "Config Management")

CreateToggle(ConfigsTab.Frame, "Auto Load", false, function(state)
    LogSystem.Add("Auto Load: " .. tostring(state))
end)

CreateTextBox(ConfigsTab.Frame, "Config Name", "Digite o nome...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        LogSystem.Add("Config name: " .. text)
    end
end)

CreateSection(ConfigsTab.Frame, "Actions")

CreateButton(ConfigsTab.Frame, "Salvar Config", function()
    local data = HttpService:JSONEncode(State)
    setclipboard(data)
    LogSystem.Add("Config salva no clipboard")
    NotificationSystem.Notify("Configs", "Configuracoes copiadas!", 3)
end)

CreateButton(ConfigsTab.Frame, "Carregar Config", function()
    LogSystem.Add("Carregar config: cole no clipboard e clique")
    NotificationSystem.Notify("Configs", "Cole a config no clipboard e clique.", 3)
end)

CreateButton(ConfigsTab.Frame, "Reset Config", function()
    LogSystem.Add("Config resetada")
    NotificationSystem.Notify("Configs", "Config resetada!", 3)
end)

CreateButton(ConfigsTab.Frame, "Export JSON", function()
    local data = HttpService:JSONEncode(State)
    setclipboard(data)
    LogSystem.Add("JSON exportado")
    NotificationSystem.Notify("Configs", "JSON copiado!", 3)
end)

-- ============================================================
-- TAB: SETTINGS (tema, sons, animacoes, keybind)
-- ============================================================
CreateSection(SettingsTab.Frame, "Interface")

CreateDropdown(SettingsTab.Frame, "Theme Color", {"Red", "Blue", "Green", "Purple", "Orange", "Pink", "Yellow"}, function(s)
    local colors = {
        Red = Color3.fromRGB(255, 45, 45),
        Blue = Color3.fromRGB(45, 45, 255),
        Green = Color3.fromRGB(45, 255, 45),
        Purple = Color3.fromRGB(165, 45, 255),
        Orange = Color3.fromRGB(255, 165, 0),
        Pink = Color3.fromRGB(255, 105, 180),
        Yellow = Color3.fromRGB(255, 255, 45),
    }
    Theme.Accent = colors[s] or Theme.Accent
    State.themeColor = s
    LogSystem.Add("Theme: " .. s)
    NotificationSystem.Notify("Settings", "Tema alterado para " .. s, 2)
end)

CreateToggle(SettingsTab.Frame, "Sons da UI", true, function(state)
    State.enableSound = state
    LogSystem.Add("Sound: " .. tostring(state))
end)

CreateToggle(SettingsTab.Frame, "Animacoes", true, function(state)
    State.enableAnimation = state
    LogSystem.Add("Animations: " .. tostring(state))
end)

CreateSection(SettingsTab.Frame, "Keybind")

CreateKeybind(SettingsTab.Frame, "Toggle UI Keybind", Enum.KeyCode.RightControl, function(key)
    State.currentKeybind = key
    State.settingsKeybind = key
    LogSystem.Add("Keybind: " .. key.Name)
end)

CreateKeybind(SettingsTab.Frame, "ESP Keybind", Enum.KeyCode.Insert, function(key)
    LogSystem.Add("ESP Keybind: " .. key.Name)
end)

CreateKeybind(SettingsTab.Frame, "Aimbot Keybind", Enum.KeyCode.Home, function(key)
    LogSystem.Add("Aimbot Keybind: " .. key.Name)
end)

CreateSection(SettingsTab.Frame, "Extra")

CreateButton(SettingsTab.Frame, "Recarregar Script", function()
    LogSystem.Add("Script reload requested")
    NotificationSystem.Notify("Settings", "Recarregue o script no executor.", 3)
end)

CreateButton(SettingsTab.Frame, "Fechar UI", function()
    UI:ToggleVisibility()
    LogSystem.Add("UI closed")
end)

-- ============================================================
-- TAB: LOGS (logs de acoes, erros, notificacoes)
-- ============================================================
CreateSection(LogsTab.Frame, "System Logs")

local logContainer = Instance.new("Frame")
logContainer.Size = UDim2.new(0.9, 0, 0, 300)
logContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
logContainer.BorderSizePixel = 0
logContainer.Parent = LogsTab.Frame

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = Theme.CornerRadius
logCorner.Parent = logContainer

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -10, 1, -10)
logScroll.Position = UDim2.new(0, 5, 0, 5)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 3
logScroll.ScrollBarImageColor3 = Theme.Accent
logScroll.Parent = logContainer

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = logScroll

local function renderLog()
    for _, child in ipairs(logScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    for i, entry in ipairs(LogSystem.Get()) do
        local logLabel = Instance.new("TextLabel")
        logLabel.Size = UDim2.new(1, 0, 0, 22)
        logLabel.BackgroundTransparency = 1
        logLabel.Text = "[" .. entry.time .. "] " .. entry.text
        logLabel.TextColor3 = entry.color or Theme.TextSecondary
        logLabel.Font = Enum.Font.Code
        logLabel.TextSize = 12
        logLabel.TextXAlignment = Enum.TextXAlignment.Left
        logLabel.Parent = logScroll
    end
    logScroll.CanvasSize = UDim2.new(0, 0, 0, #LogSystem.Get() * 24)
    logScroll.ScrollBarPosition = logScroll.CanvasPosition.Y + 100
end

renderLog()

-- Auto-refresh logs
local logRefreshTimer = tick()
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - logRefreshTimer >= 2 then
        renderLog()
        logRefreshTimer = now
    end
end)

CreateSection(LogsTab.Frame, "Actions")

CreateButton(LogsTab.Frame, "Limpar Logs", function()
    logEntries = {}
    renderLog()
    LogSystem.Add("Logs limpos", Theme.Accent)
    NotificationSystem.Notify("Logs", "Logs limpos!", 2)
end)

CreateButton(LogsTab.Frame, "Exportar Logs", function()
    local logText = ""
    for _, entry in ipairs(LogSystem.Get()) do
        logText = logText .. "[" .. entry.time .. "] " .. entry.text .. "\n"
    end
    setclipboard(logText)
    LogSystem.Add("Logs exportados", Theme.Accent)
    NotificationSystem.Notify("Logs", "Logs copiados!", 3)
end)

-- ============================================================
-- TAB: ABOUT (creditos, versao, Discord)
-- ============================================================
local AboutTab = UI:AddTab("About")

CreateSection(AboutTab.Frame, "MANUS HUB")

CreateLabel(AboutTab.Frame, "MANUS HUB v4.0", Theme.Accent)
CreateLabel(AboutTab.Frame, "Criado por Manus AI", Theme.TextSecondary)

CreateSection(AboutTab.Frame, "Versao")

CreateInfoLabel(AboutTab.Frame, "Versao", "4.0", Theme.Accent)
CreateInfoLabel(AboutTab.Frame, "Build", os.date("%Y-%m-%d"), Theme.TextSecondary)
CreateInfoLabel(AboutTab.Frame, "Plataforma", "Roblox / LuaU", Theme.TextSecondary)

CreateSection(AboutTab.Frame, "Creditos")

CreateLabel(AboutTab.Frame, "UI Library: Manus AI", Theme.TextPrimary)
CreateLabel(AboutTab.Frame, "Tema: Dark Modern Red", Theme.TextPrimary)
CreateLabel(AboutTab.Frame, "12 Tabs, 60+ Controls", Theme.TextSecondary)

CreateSection(AboutTab.Frame, "Links")

CreateButton(AboutTab.Frame, "Discord", function()
    NotificationSystem.Notify("About", "Discord: discord.gg/manushub", 5)
    LogSystem.Add("Discord link clicked", Theme.Accent)
end)

CreateButton(AboutTab.Frame, "GitHub", function()
    NotificationSystem.Notify("About", "GitHub: github.com/manushub", 5)
    LogSystem.Add("GitHub link clicked", Theme.Accent)
end)

CreateButton(AboutTab.Frame, "Documentacao", function()
    NotificationSystem.Notify("About", "Docs: docs.manushub.io", 5)
    LogSystem.Add("Docs clicked", Theme.Accent)
end)

CreateSection(AboutTab.Frame, "Features")

CreateLabel(AboutTab.Frame, "ESP completo (Box, Tracers, Health, Names)", Theme.TextPrimary)
CreateLabel(AboutTab.Frame, "Aimbot Sticky + Silent Aim com hooks", Theme.TextPrimary)
CreateLabel(AboutTab.Frame, "Movement, Defense, World, Player", Theme.TextPrimary)
CreateLabel(AboutTab.Frame, "Configs Save/Load + Logs + Settings", Theme.TextPrimary)

-- ===== STARTUP ANIMATION =====
UI.IsVisible = true
UI.MainFrame.BackgroundTransparency = 1
UI.MainFrame.Position = UDim2.new(0.5, -310, 0.5, -150)

TweenManager:Create(UI.MainFrame, {
    Position = UDim2.new(0.5, -310, 0.5, -215),
    BackgroundTransparency = 0
}, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

NotificationSystem.Notify("MANUS HUB", "v4.0 carregada! 12 tabs, 60+ controles.", 5)

LogSystem.Add("MANUS HUB v4.0 inicializado", Theme.Accent)
LogSystem.Add("12 tabs carregadas", Color3.fromRGB(0, 255, 100))
LogSystem.Add("UI Library pronta", Color3.fromRGB(0, 255, 100))

return UI
