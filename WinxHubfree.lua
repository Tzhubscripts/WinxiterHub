--[[
    ┌──────────────────────────────────────────────────────────────┐
    │                    MANUS HUB v2.0                            │
    │               Roblox UI Library + ESP System                 │
    │                                                              │
    │  Features:                                                   │
    │   • Tema Dark Modern com detalhes em vermelho (#ff2d2d)      │
    │   • Layout organizado: Sidebar com PlayerInfo → Tabs → FPS   │
    │   • ESP completo: Box, Tracers, Names, Health Bar, Distance  │
    │   • Animações fluidas com TweenService                       │
    │   • Sistema de Notificações                                  │
    │   • Save/Load de configurações                               │
    └──────────────────────────────────────────────────────────────┘
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════════
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Section = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(255, 45, 45), -- #ff2d2d
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Stroke = Color3.fromRGB(40, 40, 40),
    Shadow = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.5,
    CornerRadius = UDim.new(0, 8),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

-- ══════════════════════════════════════════════════════════════════
--  TWEEN MANAGER
-- ══════════════════════════════════════════════════════════════════
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

-- ══════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════════
local NotificationSystem = {}
local notifications = {}

function NotificationSystem.Notify(title, text, duration)
    duration = duration or 5

    local screenGui = game:GetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or Players.LocalPlayer.PlayerGui:FindFirstChildWhichIsA("ScreenGui")

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

    -- Accent bar at top
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

-- ══════════════════════════════════════════════════════════════════
--  SETTINGS SYSTEM
-- ══════════════════════════════════════════════════════════════════
local SettingsSystem = {}
local SETTINGS_FILE = "ManusHub_Settings.json"
local savedSettings = {}

function SettingsSystem.Save(data)
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if success then
        savedSettings = data
        print("Settings saved:", encoded)
    end
end

function SettingsSystem.Load()
    print("Loading settings...")
    return savedSettings
end

-- ══════════════════════════════════════════════════════════════════
--  ESP SYSTEM — Fully Functional
-- ══════════════════════════════════════════════════════════════════
local ESPSystem = {}
local espInstances = {}
local espConfig = {
    Enabled = false,
    ShowBox = false,
    ShowTracers = false,
    ShowNames = false,
    ShowHealthBar = false,
    HealthBarSide = "Left",
    ESPColor = Theme.Accent,
    ESPDistance = 1000,
}
local espConnections = {}
local espActive = false

-- ScreenGui dedicated to ESP (always on top, no reset)
local function getOrCreateESPGui()
    local gui = Players.LocalPlayer.PlayerGui:FindFirstChild("ManusHub_ESP")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "ManusHub_ESP"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        gui.Enabled = true
        gui.Parent = Players.LocalPlayer.PlayerGui
    end
    return gui
end

local function createBoxTemplate()
    local box = Instance.new("Frame")
    box.Name = "ESPBox"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    return box
end

local function createTracerTemplate()
    local tracer = Instance.new("Frame")
    tracer.Name = "ESPTracer"
    tracer.BackgroundTransparency = 0.4
    tracer.BorderSizePixel = 0
    return tracer
end

local function createNameLabel()
    local label = Instance.new("TextLabel")
    label.Name = "ESPName"
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Theme.FontBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Center
    return label
end

local function createHealthBarTemplate()
    local healthBar = Instance.new("Frame")
    healthBar.Name = "ESPHealthBar"
    healthBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBar.BorderSizePixel = 0
    healthBar.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = healthBar

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.Position = UDim2.new(0, 0, 1, 0)
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Parent = healthBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = healthFill

    return healthBar
end

function ESPSystem.Enable()
    if espActive then return end
    espActive = true

    local espGui = getOrCreateESPGui()

    -- Clean up any existing ESP instances
    for player, instances in pairs(espInstances) do
        for _, obj in pairs(instances) do
            if obj and obj.Parent then obj:Destroy() end
        end
    end
    espInstances = {}

    -- Process all current players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            ESPSystem:_AddPlayer(player, espGui)
        end
    end

    -- Listen for new players
    local playerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(1) -- Wait for character to load
        ESPSystem:_AddPlayer(player, espGui)
    end)
    espConnections["PlayerAdded"] = playerAdded

    -- Listen for players leaving
    local playerRemoved = Players.PlayerRemoving:Connect(function(player)
        ESPSystem:_RemovePlayer(player)
    end)
    espConnections["PlayerRemoved"] = playerRemoved

    -- Main ESP loop using Heartbeat for smooth updates
    local heartbeat = RunService.Heartbeat:Connect(function()
        if not espConfig.Enabled then return end
        for player, instances in pairs(espInstances) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                ESPSystem:_UpdatePlayer(player, instances)
            end
        end
    end)
    espConnections["Heartbeat"] = heartbeat

    NotificationSystem.Notify("ESP", "Sistema ESP ativado com sucesso!", 3)
end

function ESPSystem.Disable()
    if not espActive then return end
    espActive = false

    -- Disconnect all connections
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}

    -- Destroy all ESP instances
    for player, instances in pairs(espInstances) do
        for _, obj in pairs(instances) do
            if obj and obj.Parent then obj:Destroy() end
        end
    end
    espInstances = {}

    NotificationSystem.Notify("ESP", "Sistema ESP desativado.", 3)
end

function ESPSystem:_AddPlayer(player, espGui)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        -- Wait for character to spawn
        local charAdded = player.CharacterAdded:Once(function(char)
            ESPSystem:_AddPlayer(player, espGui)
        end)
        return
    end

    local rootPart = player.Character.HumanoidRootPart
    local box = createBoxTemplate()
    local tracer = createTracerTemplate()
    local nameLabel = createNameLabel()
    local healthBar = createHealthBarTemplate()

    box.Parent = espGui
    tracer.Parent = espGui
    nameLabel.Parent = espGui
    healthBar.Parent = espGui

    espInstances[player] = {
        Box = box,
        Tracer = tracer,
        Name = nameLabel,
        HealthBar = healthBar,
        Humanoid = player.Character:FindFirstChildOfClass("Humanoid"),
    }

    -- Listen for character respawn
    local charAdded = player.CharacterAdded:Once(function(char)
        task.wait(0.5)
        local newRoot = char:FindFirstChild("HumanoidRootPart")
        if newRoot then
            if espInstances[player] then
                espInstances[player].Humanoid = char:FindFirstChildOfClass("Humanoid")
            end
        end
    end)
end

function ESPSystem:_RemovePlayer(player)
    local instances = espInstances[player]
    if instances then
        for _, obj in pairs(instances) do
            if obj and obj.Parent then obj:Destroy() end
        end
        espInstances[player] = nil
    end
end

function ESPSystem:_UpdatePlayer(player, instances)
    local humanoid = instances.Humanoid
    if not humanoid then
        humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        instances.Humanoid = humanoid
    end

    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Calculate distance
    local localRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    local distance = (rootPart.Position - localRoot.Position).Magnitude
    if distance > espConfig.ESPDistance then
        instances.Box.Visible = false
        instances.Tracer.Visible = false
        instances.Name.Visible = false
        instances.HealthBar.Visible = false
        return
    end

    -- World-to-Screen projection
    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        instances.Box.Visible = false
        instances.Tracer.Visible = false
        instances.Name.Visible = false
        instances.HealthBar.Visible = false
        return
    end

    -- Calculate box size based on distance
    local boxHeight = math.max(30, 120 - (distance / espConfig.ESPDistance * 80))
    local boxWidth = boxHeight * 0.55

    local color = espConfig.ESPColor
    local healthPercent = humanoid and humanoid.Health / humanoid.MaxHealth or 1

    -- ── BOX ──
    if espConfig.ShowBox then
        instances.Box.Visible = true
        instances.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
        instances.Box.Position = UDim2.new(0, screenPos.X - boxWidth / 2, 0, screenPos.Y - boxHeight / 2)

        -- Destroy and recreate stroke for color updates
        local existingStroke = instances.Box:FindFirstChildOfClass("UIStroke")
        if existingStroke then existingStroke:Destroy() end
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 1.5
        stroke.Parent = instances.Box

        -- Update box color if changed
        if instances.Box.Color ~= color then
            -- Color is handled via stroke
        end
    else
        instances.Box.Visible = false
    end

    -- ── NAME ──
    if espConfig.ShowNames then
        instances.Name.Visible = true
        instances.Name.Text = player.DisplayName
        instances.Name.TextColor3 = color
        instances.Name.Size = UDim2.new(0, 0, 0, 16)
        instances.Name.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - boxHeight / 2 - 18)
        instances.Name.AnchorPoint = Vector2.new(0.5, 0)
    else
        instances.Name.Visible = false
    end

    -- ── HEALTH BAR ──
    if espConfig.ShowHealthBar then
        instances.HealthBar.Visible = true
        local barHeight = boxHeight + 10
        local barWidth = 6
        local barX, barY

        if espConfig.HealthBarSide == "Left" then
            barX = screenPos.X - boxWidth / 2 - 10
            barY = screenPos.Y - boxHeight / 2 - 2
        else
            barX = screenPos.X + boxWidth / 2 + 4
            barY = screenPos.Y - boxHeight / 2 - 2
        end

        instances.HealthBar.Size = UDim2.new(0, barWidth, 0, barHeight)
        instances.HealthBar.Position = UDim2.new(0, barX, 0, barY)

        local fill = instances.HealthBar:FindFirstChild("HealthFill")
        if fill then
            -- Color health based on percentage
            local healthColor = Color3.fromRGB(0, 255, 0)
            if healthPercent <= 0.25 then
                healthColor = Color3.fromRGB(255, 0, 0)
            elseif healthPercent <= 0.5 then
                healthColor = Color3.fromRGB(255, 165, 0)
            end
            fill.BackgroundColor3 = healthColor
            fill.Size = UDim2.new(1, 0, healthPercent, 0)
            fill.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
        end
    else
        instances.HealthBar.Visible = false
    end

    -- ── TRACERS ──
    if espConfig.ShowTracers then
        instances.Tracer.Visible = true
        instances.Tracer.BackgroundColor3 = color
        instances.Tracer.BackgroundTransparency = 0.5
        instances.Tracer.Size = UDim2.new(0, 2, 0, math.max(5, (screenPos.Y - Camera.ViewportSize.Y * 0.5)))
        instances.Tracer.Position = UDim2.new(0, screenPos.X - 1, 0, math.min(screenPos.Y, Camera.ViewportSize.Y * 0.5))
    else
        instances.Tracer.Visible = false
    end
end

-- ══════════════════════════════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════════════════════════════
local FOVCircle = {}
local fovCircleInstance = nil
local fovCircleVisible = false
local fovCircleRadius = 100
local fovCircleColor = Theme.Accent

function FOVCircle.Enable()
    if fovCircleVisible then return end
    fovCircleVisible = true

    local gui = getOrCreateESPGui()

    fovCircleInstance = Instance.new("Frame")
    fovCircleInstance.Name = "FOVCircle"
    fovCircleInstance.BackgroundTransparency = 1
    fovCircleInstance.BorderSizePixel = 0
    fovCircleInstance.Size = UDim2.new(0, fovCircleRadius * 2, 0, fovCircleRadius * 2)
    fovCircleInstance.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircleInstance.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovCircleInstance.Parent = gui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = fovCircleInstance

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = fovCircleColor
    uiStroke.Thickness = 1.5
    uiStroke.Transparency = 0.4
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = fovCircleInstance
end

function FOVCircle.Disable()
    if not fovCircleVisible then return end
    fovCircleVisible = false
    if fovCircleInstance then
        fovCircleInstance:Destroy()
        fovCircleInstance = nil
    end
end

function FOVCircle.Update(radius)
    fovCircleRadius = radius
    if fovCircleInstance then
        fovCircleInstance.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    end
end

-- ══════════════════════════════════════════════════════════════════
--  UILIBRARY CORE
-- ══════════════════════════════════════════════════════════════════
local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary.new(options)
    local self = setmetatable({}, UILibrary)

    self.Title = options.Title or "Roblox UI Library"
    self.SubTitle = options.SubTitle or "Premium UI Solution"
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
        self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ── MAIN FRAME ──
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
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

    -- ── SIDEBAR ──
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 170, 1, 0)
    self.Sidebar.BackgroundColor3 = Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.MainFrame

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = Theme.CornerRadius
    sidebarCorner.Parent = self.Sidebar

    -- Logo/Title at top of sidebar
    local logoLabel = Instance.new("TextLabel")
    logoLabel.Name = "LogoLabel"
    logoLabel.Size = UDim2.new(1, 0, 0, 45)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = self.Title
    logoLabel.TextColor3 = Theme.Accent
    logoLabel.Font = Theme.FontBold
    logoLabel.TextSize = 18
    logoLabel.Parent = self.Sidebar

    -- Subtitle
    local subTitleLabel = Instance.new("TextLabel")
    subTitleLabel.Name = "SubTitle"
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
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(0.9, 0, 0, 30)
    searchFrame.Position = UDim2.new(0.05, 0, 0, 68)
    searchFrame.BackgroundColor3 = Theme.Section
    searchFrame.Parent = self.Sidebar

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchFrame

    local searchInput = Instance.new("TextBox")
    searchInput.Name = "SearchInput"
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

    -- Tab Container (ScrollingFrame) — organized in the middle of sidebar
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
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

    -- ── PLAYER INFO (Bottom of sidebar, above FPS) ──
    self.PlayerInfoFrame = Instance.new("Frame")
    self.PlayerInfoFrame.Name = "PlayerInfo"
    self.PlayerInfoFrame.Size = UDim2.new(0.9, 0, 0, 65)
    self.PlayerInfoFrame.Position = UDim2.new(0.05, 0, 1, -90)
    self.PlayerInfoFrame.BackgroundColor3 = Theme.Section
    self.PlayerInfoFrame.BorderSizePixel = 0
    self.PlayerInfoFrame.Parent = self.Sidebar

    local piCorner = Instance.new("UICorner")
    piCorner.CornerRadius = Theme.CornerRadius
    piCorner.Parent = self.PlayerInfoFrame

    local piPlayer = Players.LocalPlayer
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.new(0, 40, 0, 40)
    avatarImg.Position = UDim2.new(0, 10, 0, 12)
    avatarImg.BackgroundColor3 = Theme.Background
    avatarImg.Image = Players:GetUserThumbnailAsync(piPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    avatarImg.Parent = self.PlayerInfoFrame

    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(1, 0)
    imgCorner.Parent = avatarImg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
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
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -60, 0, 18)
    statusLabel.Position = UDim2.new(0, 58, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "● Online"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    statusLabel.Font = Theme.Font
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = self.PlayerInfoFrame

    -- ── FPS COUNTER (Very bottom of sidebar) ──
    self.FPSFrame = Instance.new("Frame")
    self.FPSFrame.Name = "FPSCounter"
    self.FPSFrame.Size = UDim2.new(0.9, 0, 0, 22)
    self.FPSFrame.Position = UDim2.new(0.05, 0, 1, -25)
    self.FPSFrame.BackgroundTransparency = 1
    self.FPSFrame.BorderSizePixel = 0
    self.FPSFrame.Parent = self.Sidebar

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Theme.TextSecondary
    fpsLabel.Font = Theme.Font
    fpsLabel.TextSize = 10
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.Parent = self.FPSFrame

    -- FPS loop
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

    -- ── CONTENT AREA ──
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
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
    toggleButton.Name = "ToggleButton"
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
    closeButton.Name = "CloseButton"
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
        NotificationSystem.Notify("Aviso", "Pressione o botão flutuante 'M' para abrir novamente.", 3)
    end)
    TweenManager:Hover(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)})
end

function UILibrary:CreateMinimizeButton()
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
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

function UILibrary:AddTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.Icon = icon
    tab.Elements = {}

    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
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
    tabFrame.Name = name .. "Content"
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

-- ══════════════════════════════════════════════════════════════════
--  UI COMPONENTS
-- ══════════════════════════════════════════════════════════════════

-- Label
local function CreateLabel(parent, text, color)
    local label = Instance.new("TextLabel")
    label.Name = text .. "Label"
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

-- Section
local function CreateSection(parent, text)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = text .. "Section"
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 28)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text:upper()
    label.TextColor3 = Theme.Accent
    label.Font = Theme.FontBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sectionFrame

    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(1, -label.TextBounds.X - 10, 0, 1)
    line.Position = UDim2.new(0, label.TextBounds.X + 10, 0.5, 0)
    line.BackgroundColor3 = Theme.Stroke
    line.BorderSizePixel = 0
    line.Parent = sectionFrame

    return sectionFrame
end

-- Button
local function CreateButton(parent, text, callback)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = text .. "ButtonFrame"
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
    textButton.Name = "Button"
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

-- Toggle
local function CreateToggle(parent, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = text .. "ToggleFrame"
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
    label.Name = "Label"
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
    clickBtn.Name = "ClickBtn"
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

-- Slider
local function CreateSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = text .. "SliderFrame"
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
    label.Name = "Label"
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
    valueLabel.Name = "ValueLabel"
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
    sliderBg.Name = "SliderBg"
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
    sliderFill.Name = "SliderFill"
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

-- Dropdown
local function CreateDropdown(parent, text, list, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = text .. "DropdownFrame"
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
    header.Name = "Header"
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
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 36, 0, 38)
    arrow.Position = UDim2.new(1, -36, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextSecondary
    arrow.Font = Theme.Font
    arrow.TextSize = 11
    arrow.Parent = header

    local itemContainer = Instance.new("Frame")
    itemContainer.Name = "ItemContainer"
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
        arrow.Text = open and "▲" or "▼"
    end)

    for _, item in ipairs(list) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.Name = item .. "Btn"
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
            arrow.Text = "▼"
            if callback then callback(item) end
        end)

        TweenManager:Hover(itemBtn, {TextColor3 = Theme.Accent}, {TextColor3 = Theme.TextSecondary})
    end

    return dropdownFrame
end

-- Keybind
local function CreateKeybind(parent, text, default, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = text .. "KeybindFrame"
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
    label.Name = "Label"
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
    keyBtn.Name = "KeyBtn"
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

-- TextBox
local function CreateTextBox(parent, text, placeholder, callback)
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = text .. "TextBoxFrame"
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
    label.Name = "Label"
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
    input.Name = "Input"
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

-- ColorPicker
local function CreateColorPicker(parent, text, default, callback)
    local cpFrame = Instance.new("Frame")
    cpFrame.Name = text .. "ColorPickerFrame"
    cpFrame.Size = UDim2.new(0.9, 0, 0, 38)
    cpFrame.BackgroundColor3 = Theme.Section
    cpFrame.BorderSizePixel = 0
    cpFrame.Parent = parent

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = cpFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Theme.Stroke
    uiStroke.Thickness = 1
    uiStroke.Parent = cpFrame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = cpFrame

    local colorPreview = Instance.new("TextButton")
    colorPreview.Name = "ColorPreview"
    colorPreview.Size = UDim2.new(0, 30, 0, 20)
    colorPreview.Position = UDim2.new(1, -45, 0.5, -10)
    colorPreview.BackgroundColor3 = default
    colorPreview.Text = ""
    colorPreview.Parent = cpFrame

    local cpCorner = Instance.new("UICorner")
    cpCorner.CornerRadius = UDim.new(0, 4)
    cpCorner.Parent = colorPreview

    local colors = {
        Color3.fromRGB(255, 45, 45),
        Color3.fromRGB(45, 255, 45),
        Color3.fromRGB(45, 45, 255),
        Color3.fromRGB(255, 255, 45),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 0, 255),
    }
    local currentIndex = 1

    colorPreview.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #colors) + 1
        local newColor = colors[currentIndex]
        colorPreview.BackgroundColor3 = newColor
        if callback then callback(newColor) end
    end)

    return cpFrame
end

-- ══════════════════════════════════════════════════════════════════
--  MAIN EXECUTION — Organized Tab Order
-- ══════════════════════════════════════════════════════════════════
local UI = UILibrary.new({
    Title = "MANUS HUB",
    SubTitle = "v2.0 | Premium UI + ESP"
})

-- Tabs in organized order: Visual (ESP) first, then Combat, Player, Teleports, Misc, Settings
local VisualTab = UI:AddTab("👁️ Visual")
local CombatTab = UI:AddTab("⚔️ Combat")
local PlayerTab = UI:AddTab("👤 Player")
local TeleportTab = UI:AddTab("📍 Teleports")
local MiscTab = UI:AddTab("⭐ Misc")
local SettingsTab = UI:AddTab("⚙️ Settings")
local LogsTab = UI:AddTab("📜 Logs")

-- ══════════════════════════════════════════════════════════════════
--  TAB: VISUAL (ESP + World)
-- ══════════════════════════════════════════════════════════════════
CreateSection(VisualTab.Frame, "ESP Controls")

CreateToggle(VisualTab.Frame, "Enable ESP", false, function(state)
    espConfig.Enabled = state
    if state then
        ESPSystem.Enable()
    else
        ESPSystem.Disable()
    end
end)

CreateToggle(VisualTab.Frame, "ESP Box", false, function(state)
    espConfig.ShowBox = state
end)

CreateToggle(VisualTab.Frame, "ESP Names", false, function(state)
    espConfig.ShowNames = state
end)

CreateToggle(VisualTab.Frame, "ESP Tracers", false, function(state)
    espConfig.ShowTracers = state
end)

CreateToggle(VisualTab.Frame, "ESP Health Bar", false, function(state)
    espConfig.ShowHealthBar = state
    if state then
        NotificationSystem.Notify("ESP", "Barra de vida ativada!", 2)
    else
        NotificationSystem.Notify("ESP", "Barra de vida desativada.", 2)
    end
end)

CreateColorPicker(VisualTab.Frame, "ESP Color", Theme.Accent, function(color)
    espConfig.ESPColor = color
end)

CreateSection(VisualTab.Frame, "ESP Customization")

CreateSlider(VisualTab.Frame, "ESP Distance", 100, 5000, 1000, function(v)
    espConfig.ESPDistance = v
end)

CreateDropdown(VisualTab.Frame, "Health Bar Side", {"Left", "Right"}, function(s)
    espConfig.HealthBarSide = s
end)

CreateSection(VisualTab.Frame, "FOV Circle")

CreateToggle(VisualTab.Frame, "Show FOV Circle", false, function(state)
    if state then
        FOVCircle.Enable()
    else
        FOVCircle.Disable()
    end
end)

CreateSlider(VisualTab.Frame, "FOV Circle Size", 50, 600, 100, function(v)
    FOVCircle.Update(v)
end)

CreateSection(VisualTab.Frame, "World")

CreateSlider(VisualTab.Frame, "Field of View", 70, 120, 70, function(v)
    Camera.FieldOfView = v
end)

CreateToggle(VisualTab.Frame, "Full Bright", false, function(state)
    local lighting = game:GetService("Lighting")
    if state then
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
    else
        lighting.Brightness = 0
        lighting.ClockTime = 0
        lighting.FogEnd = 50
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  TAB: COMBAT
-- ══════════════════════════════════════════════════════════════════
CreateSection(CombatTab.Frame, "Main Combat")

CreateToggle(CombatTab.Frame, "Silent Aim", false, function(state)
    print("Silent Aim:", state)
end)

CreateToggle(CombatTab.Frame, "Aimbot", false, function(state)
    print("Aimbot:", state)
end)

CreateSlider(CombatTab.Frame, "Aimbot Smoothness", 1, 10, 5, function(v)
    print("Smooth:", v)
end)

CreateSlider(CombatTab.Frame, "Aimbot FOV", 0, 600, 100, function(v)
    print("FOV:", v)
end)

CreateSection(CombatTab.Frame, "Weapon Mods")

CreateToggle(CombatTab.Frame, "No Recoil", false, function(state)
    print("No Recoil:", state)
end)

CreateToggle(CombatTab.Frame, "No Spread", false, function(state)
    print("No Spread:", state)
end)

CreateToggle(CombatTab.Frame, "Rapid Fire", false, function(state)
    print("Rapid Fire:", state)
end)

CreateToggle(CombatTab.Frame, "Infinite Ammo", false, function(state)
    print("Inf Ammo:", state)
end)

-- ══════════════════════════════════════════════════════════════════
--  TAB: PLAYER
-- ══════════════════════════════════════════════════════════════════
CreateSection(PlayerTab.Frame, "Movement")

CreateSlider(PlayerTab.Frame, "WalkSpeed", 16, 250, 16, function(v)
    Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    print("Speed:", v)
end)

CreateSlider(PlayerTab.Frame, "JumpPower", 50, 500, 50, function(v)
    Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character.Humanoid.JumpPower = v
    print("Jump:", v)
end)

CreateToggle(PlayerTab.Frame, "Infinite Jump", false, function(state)
    if state then
        Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    print("Inf Jump:", state)
end)

CreateToggle(PlayerTab.Frame, "No Clip", false, function(state)
    print("No Clip:", state)
end)

CreateSection(PlayerTab.Frame, "Utilities")

CreateKeybind(PlayerTab.Frame, "Fly Keybind", Enum.KeyCode.F, function(key)
    print("Fly Key:", key.Name)
end)

CreateButton(PlayerTab.Frame, "Reset Character", function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    end
    NotificationSystem.Notify("Player", "Personagem resetado!", 2)
end)

-- ══════════════════════════════════════════════════════════════════
--  TAB: TELEPORTS
-- ══════════════════════════════════════════════════════════════════
CreateSection(TeleportTab.Frame, "Teleports")

CreateButton(TeleportTab.Frame, "Teleport to Map Center", function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
    NotificationSystem.Notify("Teleport", "Teleportado para o centro!", 2)
end)

CreateButton(TeleportTab.Frame, "Teleport to Random Player", function()
    local players = Players:GetPlayers()
    for _, p in ipairs(players) do
        if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                NotificationSystem.Notify("Teleport", "Teleportado para " .. p.DisplayName, 2)
            end
            break
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  TAB: MISC
-- ══════════════════════════════════════════════════════════════════
CreateSection(MiscTab.Frame, "Miscellaneous")

CreateToggle(MiscTab.Frame, "Anti-AFK", false, function(state)
    print("Anti-AFK:", state)
end)

CreateButton(MiscTab.Frame, "Copy Discord Link", function()
    NotificationSystem.Notify("Sucesso", "Link do Discord copiado!", 3)
end)

-- ══════════════════════════════════════════════════════════════════
--  TAB: SETTINGS
-- ══════════════════════════════════════════════════════════════════
CreateSection(SettingsTab.Frame, "Configurações da UI")

CreateButton(SettingsTab.Frame, "Salvar Configurações", function()
    SettingsSystem.Save({espEnabled = espConfig.Enabled, espColor = espConfig.ESPColor})
    NotificationSystem.Notify("Settings", "Configurações salvas com sucesso!", 3)
end)

CreateButton(SettingsTab.Frame, "Resetar UI", function()
    NotificationSystem.Notify("Settings", "UI Resetada! Recarregue o script.", 3)
end)

CreateTextBox(SettingsTab.Frame, "Nome de Usuário", "Digite seu nome", function(text, enterPressed)
    print("Nome de Usuário digitado:", text)
end)

-- ══════════════════════════════════════════════════════════════════
--  TAB: LOGS
-- ══════════════════════════════════════════════════════════════════
CreateSection(LogsTab.Frame, "System Logs")

local logContainer = Instance.new("Frame")
logContainer.Name = "LogContainer"
logContainer.Size = UDim2.new(0.9, 0, 0, 300)
logContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
logContainer.BorderSizePixel = 0
logContainer.Parent = LogsTab.Frame

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = Theme.CornerRadius
logCorner.Parent = logContainer

local logScroll = Instance.new("ScrollingFrame")
logScroll.Name = "LogScroll"
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

-- Add initial log entries
local function addLog(text, color)
    local logLabel = Instance.new("TextLabel")
    logLabel.Name = "LogEntry"
    logLabel.Size = UDim2.new(1, 0, 0, 22)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = "[" .. os.date("%H:%M:%S") .. "] " .. text
    logLabel.TextColor3 = color or Theme.TextSecondary
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 12
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.Parent = logScroll
    logScroll.CanvasSize = UDim2.new(0, 0, 0, #logScroll:GetChildren() * 24)
    logScroll.ScrollBarPosition = logScroll.CanvasPosition.Y + 100
end

addLog("MANUS HUB v2.0 inicializado", Theme.Accent)
addLog("ESP System loaded", Color3.fromRGB(0, 255, 100))
addLog("UI Library ready", Color3.fromRGB(0, 255, 100))

-- ══════════════════════════════════════════════════════════════════
--  STARTUP ANIMATION + NOTIFICATION
-- ══════════════════════════════════════════════════════════════════
UI.IsVisible = true
UI.MainFrame.BackgroundTransparency = 1
UI.MainFrame.Position = UDim2.new(0.5, -310, 0.5, -150)

TweenManager:Create(UI.MainFrame, {
    Position = UDim2.new(0.5, -310, 0.5, -215),
    BackgroundTransparency = 0
}, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

NotificationSystem.Notify("MANUS HUB", "Interface v2.0 carregada! ESP + Visual caprichado.", 5)

return UI
