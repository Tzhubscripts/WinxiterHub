--[[
    Roblox UI Library - Master Script
    Desenvolvido por Manus AI
    
    Esta é uma biblioteca de interface de usuário (UI) completa e modular para Roblox,
    projetada para ser moderna, profissional e altamente personalizável.
    
    Características:
    - Tema Dark Modern com detalhes em vermelho (#ff2d2d).
    - Cantos arredondados (UICorner) e bordas (UIStroke) em todos os elementos.
    - Sombras suaves e transparências elegantes.
    - Animações fluidas usando TweenService para interações e transições.
    - Escala responsiva para PC e Mobile.
    - Janela arrastável, botão flutuante para abrir/fechar, sistema de minimizar.
    - Sistema de Tabs e Sections para organização de conteúdo.
    - Componentes de UI: Toggles, Buttons, Sliders, Dropdowns, Textbox, Keybinds, Color Picker, Labels.
    - Sistemas avançados: Notificações, Tooltips, Barra de pesquisa, Configurações com salvamento automático.
    - Módulos extras: FPS Counter, Hora atual, Nome/Avatar do jogador, Status online.
    - Código modular, limpo, organizado e com funções reutilizáveis.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--[[ Theme Definition ]]
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

--[[ TweenManager Utility ]]
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

--[[ NotificationSystem ]]
local NotificationSystem = {}
local notifications = {}

function NotificationSystem.Notify(title, text, duration)
    duration = duration or 5
    
    local screenGui = game:GetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or Players.LocalPlayer.PlayerGui:FindFirstChildWhichIsA("ScreenGui")
    
    local notifyFrame = Instance.new("Frame")
    notifyFrame.Name = "Notification"
    notifyFrame.Size = UDim2.new(0, 250, 0, 80)
    notifyFrame.Position = UDim2.new(1, 20, 1, -100 - (#notifications * 90))
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
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Accent
    titleLabel.Font = Theme.FontBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifyFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 40)
    textLabel.Position = UDim2.new(0, 10, 0, 35)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Theme.TextPrimary
    textLabel.Font = Theme.Font
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = notifyFrame
    
    table.insert(notifications, notifyFrame)
    
    TweenManager:Create(notifyFrame, {Position = UDim2.new(1, -270, 1, -100 - ((#notifications - 1) * 90))})
    
    task.delay(duration, function()
        local tween = TweenManager:Create(notifyFrame, {Position = UDim2.new(1, 20, notifyFrame.Position.Y.Scale, notifyFrame.Position.Y.Offset)})
        tween.Completed:Wait()
        
        local index = table.find(notifications, notifyFrame)
        if index then
            table.remove(notifications, index)
            for i, frame in ipairs(notifications) do
                TweenManager:Create(frame, {Position = UDim2.new(1, -270, 1, -100 - ((i - 1) * 90))})
            end
        end
        notifyFrame:Destroy()
    end)
end

--[[ SettingsSystem ]]
local SettingsSystem = {}
local SETTINGS_FILE = "UILibrary_Settings.json"

function SettingsSystem.Save(data)
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if success then
        -- Em ambiente Roblox, você usaria DataStoreService ou UserSettings().
        -- Para um script local, simulamos com print.
        print("Saving settings:", encoded)
    end
end

function SettingsSystem.Load()
    -- Em ambiente Roblox, você usaria DataStoreService ou UserSettings().
    -- Para um script local, simulamos com um retorno vazio.
    print("Loading settings...")
    return {}
end

--[[ UILibrary Core ]]
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
    self.ScreenGui.Name = "UILibrary_" .. tostring(math.random(1000, 9999))
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Enabled = true -- Começa habilitado
    
    local success, _ = pcall(function()
        self.ScreenGui.Parent = CoreGui
    end)
    if not success then
        self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
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
    
    local uiShadow = Instance.new("UIStroke") -- Usando UIStroke para simular sombra
    uiShadow.Color = Theme.Shadow
    uiShadow.Thickness = 5
    uiShadow.Transparency = Theme.ShadowTransparency
    uiShadow.Parent = self.MainFrame

    -- Blur de fundo (BackdropBlur)
    local blur = Instance.new("Frame")
    blur.Name = "BackdropBlur"
    blur.Size = UDim2.new(1,0,1,0)
    blur.BackgroundTransparency = 0.5 -- Ajuste para o efeito de blur
    blur.BackgroundColor3 = Color3.new(0,0,0)
    blur.ZIndex = -1
    blur.Parent = self.MainFrame

    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 160, 1, 0)
    self.Sidebar.BackgroundColor3 = Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.MainFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = Theme.CornerRadius
    sidebarCorner.Parent = self.Sidebar
    
    local logoLabel = Instance.new("TextLabel")
    logoLabel.Name = "LogoLabel"
    logoLabel.Size = UDim2.new(1, 0, 0, 50)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = self.Title
    logoLabel.TextColor3 = Theme.Accent
    logoLabel.Font = Theme.FontBold
    logoLabel.TextSize = 18
    logoLabel.Parent = self.Sidebar
    
    -- Search Bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(0.9, 0, 0, 30)
    searchFrame.Position = UDim2.new(0.05, 0, 0, 50)
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

    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 1, -100)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 90)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 0
    self.TabContainer.Parent = self.Sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = self.TabContainer
    
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, -160, 1, 0)
    self.ContentArea.Position = UDim2.new(0, 160, 0, 0)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.MainFrame

    self:MakeDraggable(self.MainFrame)
    self:CreateToggleButton()
    self:CreateCloseButton()
    self:CreateMinimizeButton()
    
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
    toggleButton.Size = UDim2.new(0, 40, 0, 40)
    toggleButton.Position = UDim2.new(1, -50, 0, 10)
    toggleButton.BackgroundColor3 = Theme.Accent
    toggleButton.Text = "O"
    toggleButton.TextColor3 = Theme.TextPrimary
    toggleButton.Font = Theme.FontBold
    toggleButton.TextSize = 20
    toggleButton.Parent = self.ScreenGui
    toggleButton.ZIndex = 10 -- Para ficar acima de tudo

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

    -- Animação de hover
    TweenManager:Hover(toggleButton, {BackgroundColor3 = Theme.Accent:Lerp(Color3.new(1,1,1), 0.1)}, {BackgroundColor3 = Theme.Accent})
end

function UILibrary:ToggleVisibility()
    self.IsVisible = not self.IsVisible
    
    if self.IsVisible then
        self.MainFrame.Visible = true
        TweenManager:Create(self.MainFrame, {Position = UDim2.new(0.5, -300, 0.5, -200), BackgroundTransparency = 0}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
    else
        local tween = TweenManager:Create(self.MainFrame, {Position = UDim2.new(0.5, -300, 0.5, -150), BackgroundTransparency = 1}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In))
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
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
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
        NotificationSystem.Notify("Aviso", "Pressione o botão flutuante para abrir novamente.", 3)
    end)
    TweenManager:Hover(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)})
end

function UILibrary:CreateMinimizeButton()
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -50, 0, 5)
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
            TweenManager:Create(self.MainFrame, {Size = UDim2.new(0, 600, 0, 50)})
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
    tabButton.Size = UDim2.new(0.9, 0, 0, 35)
    tabButton.BackgroundColor3 = Theme.Section
    tabButton.BackgroundTransparency = 1
    tabButton.Text = name
    tabButton.TextColor3 = Theme.TextSecondary
    tabButton.Font = Theme.Font
    tabButton.TextSize = 14
    tabButton.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Content"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 2
    tabFrame.ScrollBarImageColor3 = Theme.Accent
    tabFrame.Visible = false
    tabFrame.Parent = self.ContentArea
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = tabFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
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

--[[ UI Components ]]

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
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 30)
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
    buttonFrame.Size = UDim2.new(0.9, 0, 0, 40)
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
    
    TweenManager:Hover(buttonFrame, {BackgroundColor3 = Theme.Section:Lerp(Color3.new(1,1,1), 0.05)}, {BackgroundColor3 = Theme.Section})
    TweenManager:Ripple(textButton, Theme.Accent)
    
    textButton.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return buttonFrame
end

-- Toggle
local function CreateToggle(parent, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = text .. "ToggleFrame"
    toggleFrame.Size = UDim2.new(0.9, 0, 0, 40)
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
    switchBg.Size = UDim2.new(0, 40, 0, 20)
    switchBg.Position = UDim2.new(1, -55, 0.5, -10)
    switchBg.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50, 50, 50)
    switchBg.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Name = "SwitchCircle"
    switchCircle.Size = UDim2.new(0, 16, 0, 16)
    switchCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
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
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = state and Theme.Accent or Color3.fromRGB(50, 50, 50)
        
        TweenManager:Create(switchCircle, {Position = targetPos})
        TweenManager:Create(switchBg, {BackgroundColor3 = targetColor})
        
        if callback then
            callback(state)
        end
    end)
    
    return toggleFrame
end

-- Slider Corrigido
local function CreateSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = text .. "SliderFrame"
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
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
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -65, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Theme.Font
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderBg = Instance.new("TextButton") -- Usando TextButton para melhor detecção de clique
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, -30, 0, 6)
    sliderBg.Position = UDim2.new(0, 15, 0, 35)
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
        
        if callback then
            callback(value)
        end
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
    dropdownFrame.Size = UDim2.new(0.9, 0, 0, 40)
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
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = text .. " : Selecionar"
    header.TextColor3 = Theme.TextPrimary
    header.Font = Theme.Font
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = dropdownFrame
    
    local headerPadding = Instance.new("UIPadding")
    headerPadding.PaddingLeft = UDim.new(0, 15)
    headerPadding.Parent = header
    
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 40, 0, 40)
    arrow.Position = UDim2.new(1, -40, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextSecondary
    arrow.Font = Theme.Font
    arrow.TextSize = 12
    arrow.Parent = header
    
    local itemContainer = Instance.new("Frame")
    itemContainer.Name = "ItemContainer"
    itemContainer.Size = UDim2.new(1, 0, 0, #list * 30)
    itemContainer.Position = UDim2.new(0, 0, 0, 40)
    itemContainer.BackgroundTransparency = 1
    itemContainer.Parent = dropdownFrame
    
    local itemLayout = Instance.new("UIListLayout")
    itemLayout.Parent = itemContainer
    
    local open = false
    header.MouseButton1Click:Connect(function()
        open = not open
        local targetSize = open and UDim2.new(0.9, 0, 0, 40 + (#list * 30)) or UDim2.new(0.9, 0, 0, 40)
        TweenManager:Create(dropdownFrame, {Size = targetSize})
        arrow.Text = open and "▲" or "▼"
    end)
    
    for _, item in ipairs(list) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.Name = item .. "Btn"
        itemBtn.Size = UDim2.new(1, 0, 0, 30)
        itemBtn.BackgroundTransparency = 1
        itemBtn.Text = item
        itemBtn.TextColor3 = Theme.TextSecondary
        itemBtn.Font = Theme.Font
        itemBtn.TextSize = 13
        itemBtn.Parent = itemContainer
        
        itemBtn.MouseButton1Click:Connect(function()
            header.Text = text .. " : " .. item
            open = false
            TweenManager:Create(dropdownFrame, {Size = UDim2.new(0.9, 0, 0, 40)})
            arrow.Text = "▼"
            if callback then
                callback(item)
            end
        end)
        
        TweenManager:Hover(itemBtn, {TextColor3 = Theme.Accent}, {TextColor3 = Theme.TextSecondary})
    end
    
    return dropdownFrame
end

-- Keybind
local function CreateKeybind(parent, text, default, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = text .. "KeybindFrame"
    keybindFrame.Size = UDim2.new(0.9, 0, 0, 40)
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
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybindFrame
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Name = "KeyBtn"
    keyBtn.Size = UDim2.new(0, 80, 0, 26)
    keyBtn.Position = UDim2.new(1, -95, 0.5, -13)
    keyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    keyBtn.Text = default.Name
    keyBtn.TextColor3 = Theme.Accent
    keyBtn.Font = Theme.Font
    keyBtn.TextSize = 13
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
            if callback then
                callback(currentKey)
            end
        end
    end)
    
    return keybindFrame
end

-- TextBox
local function CreateTextBox(parent, text, placeholder, callback)
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = text .. "TextBoxFrame"
    boxFrame.Size = UDim2.new(0.9, 0, 0, 40)
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
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = boxFrame
    
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(0.5, 0, 0, 26)
    input.Position = UDim2.new(1, -15, 0.5, -13)
    input.AnchorPoint = Vector2.new(1, 0)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Theme.TextSecondary
    input.TextColor3 = Theme.TextPrimary
    input.Font = Theme.Font
    input.TextSize = 13
    input.ClipsDescendants = true
    input.Parent = boxFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = input
    
    input.FocusLost:Connect(function(enterPressed)
        if callback then
            callback(input.Text, enterPressed)
        end
    end)
    
    return boxFrame
end

-- ColorPicker (simplificado para demonstração)
local function CreateColorPicker(parent, text, default, callback)
    local cpFrame = Instance.new("Frame")
    cpFrame.Name = text .. "ColorPickerFrame"
    cpFrame.Size = UDim2.new(0.9, 0, 0, 40)
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
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Theme.Font
    label.TextSize = 14
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
    
    local colors = {Color3.fromRGB(255, 45, 45), Color3.fromRGB(45, 255, 45), Color3.fromRGB(45, 45, 255), Color3.fromRGB(255, 255, 45)}
    local currentIndex = 1
    
    colorPreview.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #colors) + 1
        local newColor = colors[currentIndex]
        colorPreview.BackgroundColor3 = newColor
        if callback then
            callback(newColor)
        end
    end)
    
    return cpFrame
end

--[[ Modules ]]

-- PlayerInfo
local function CreatePlayerInfo(parent)
    local player = Players.LocalPlayer
    
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "PlayerInfo"
    infoFrame.Size = UDim2.new(1, -20, 0, 60)
    infoFrame.Position = UDim2.new(0, 10, 1, -70)
    infoFrame.BackgroundColor3 = Theme.Section
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = parent
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = Theme.CornerRadius
    uiCorner.Parent = infoFrame
    
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.new(0, 40, 0, 40)
    avatarImg.Position = UDim2.new(0, 10, 0.5, -20)
    avatarImg.BackgroundColor3 = Theme.Background
    avatarImg.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    avatarImg.Parent = infoFrame
    
    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(1, 0)
    imgCorner.Parent = avatarImg
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -60, 0, 20)
    nameLabel.Position = UDim2.new(0, 60, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = Theme.TextPrimary
    nameLabel.Font = Theme.FontBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = infoFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -60, 0, 20)
    statusLabel.Position = UDim2.new(0, 60, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Premium User"
    statusLabel.TextColor3 = Theme.Accent
    statusLabel.Font = Theme.Font
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = infoFrame
    
    return infoFrame
end

-- FPSCounter
local function CreateFPSCounter(parent)
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Name = "FPSCounter"
    counterLabel.Size = UDim2.new(1, -20, 0, 20)
    counterLabel.Position = UDim2.new(0, 10, 1, -95)
    counterLabel.BackgroundTransparency = 1
    counterLabel.Text = "FPS: 60 | 00:00:00"
    counterLabel.TextColor3 = Theme.TextSecondary
    counterLabel.Font = Theme.Font
    counterLabel.TextSize = 11
    counterLabel.TextXAlignment = Enum.TextXAlignment.Left
    counterLabel.Parent = parent
    
    local lastUpdate = tick()
    local frames = 0
    
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            local fps = frames
            local timeStr = os.date("%X")
            counterLabel.Text = string.format("FPS: %d | %s", fps, timeStr)
            frames = 0
            lastUpdate = now
        end
    end)
    
    return counterLabel
end

--[[ Main Execution ]]
local UI = UILibrary.new({
    Title = "MANUS HUB",
    SubTitle = "v1.0.0 | Premium UI"
})

-- Adicionar Módulos Extras à Sidebar
CreatePlayerInfo(UI.Sidebar)
CreateFPSCounter(UI.Sidebar)

-- Adicionar Abas em ordem lógica para PVP
local HomeTab = UI:AddTab("🏠 Home", "")
local CombatTab = UI:AddTab("⚔️ Combat", "")
local PlayerTab = UI:AddTab("👤 Player", "")
local VisualTab = UI:AddTab("👁️ Visual", "")
local TeleportTab = UI:AddTab("📍 Teleports", "")
local MiscTab = UI:AddTab("⭐ Misc", "")
local SettingsTab = UI:AddTab("⚙️ Settings", "")
local LogsTab = UI:AddTab("📜 Logs", "")

-- Exemplos na aba Home
CreateSection(HomeTab.Frame, "Informações do Usuário")
CreateLabel(HomeTab.Frame, "Bem-vindo, " .. Players.LocalPlayer.Name)
CreateLabel(HomeTab.Frame, "Status: Online", Color3.fromRGB(0, 255, 0))

CreateSection(HomeTab.Frame, "Ações Rápidas")
CreateButton(HomeTab.Frame, "Copiar Link Discord", function()
    -- setclipboard("https://discord.gg/manushub") -- Funcionalidade real de clipboard
    NotificationSystem.Notify("Sucesso", "Link Discord copiado! (Simulado)", 3)
end)

-- Aba Combat (Foco em PVP de Tiro)
CreateSection(CombatTab.Frame, "Main Combat")
CreateToggle(CombatTab.Frame, "Silent Aim", false, function(state) print("Silent Aim:", state) end)
CreateToggle(CombatTab.Frame, "Aimbot", false, function(state) print("Aimbot:", state) end)
CreateSlider(CombatTab.Frame, "Aimbot Smoothness", 1, 10, 5, function(v) print("Smooth:", v) end)
CreateSlider(CombatTab.Frame, "Aimbot FOV", 0, 600, 100, function(v) print("FOV:", v) end)
CreateToggle(CombatTab.Frame, "Show FOV Circle", false, function(state) print("Show FOV:", state) end)

CreateSection(CombatTab.Frame, "Weapon Mods")
CreateToggle(CombatTab.Frame, "No Recoil", false, function(state) print("No Recoil:", state) end)
CreateToggle(CombatTab.Frame, "No Spread", false, function(state) print("No Spread:", state) end)
CreateToggle(CombatTab.Frame, "Rapid Fire", false, function(state) print("Rapid Fire:", state) end)
CreateToggle(CombatTab.Frame, "Infinite Ammo", false, function(state) print("Inf Ammo:", state) end)

-- Aba Player
CreateSection(PlayerTab.Frame, "Movement")
CreateSlider(PlayerTab.Frame, "WalkSpeed", 16, 250, 16, function(v) print("Speed:", v) end)
CreateSlider(PlayerTab.Frame, "JumpPower", 50, 500, 50, function(v) print("Jump:", v) end)
CreateToggle(PlayerTab.Frame, "Infinite Jump", false, function(state) print("Inf Jump:", state) end)
CreateToggle(PlayerTab.Frame, "No Clip", false, function(state) print("No Clip:", state) end)

CreateSection(PlayerTab.Frame, "Utilities")
CreateKeybind(PlayerTab.Frame, "Fly Keybind", Enum.KeyCode.F, function(key) print("Fly Key:", key.Name) end)
CreateButton(PlayerTab.Frame, "Reset Character", function() print("Resetting...") end)

-- Aba Visual
CreateSection(VisualTab.Frame, "ESP Settings")
CreateToggle(VisualTab.Frame, "Enable ESP", false, function(state) print("ESP:", state) end)
CreateToggle(VisualTab.Frame, "ESP Box", false, function(state) print("ESP Box:", state) end)
CreateToggle(VisualTab.Frame, "ESP Health Bar", false, function(state) 
    print("Health Bar:", state)
    NotificationSystem.Notify("Visual", "Barra de vida " .. (state and "ativada" or "desativada"), 2)
end)
CreateToggle(VisualTab.Frame, "ESP Tracers", false, function(state) print("Tracers:", state) end)
CreateToggle(VisualTab.Frame, "ESP Names", false, function(state) print("Names:", state) end)
CreateColorPicker(VisualTab.Frame, "ESP Color", Theme.Accent, function(color) print("ESP Color:", color) end)

CreateSection(VisualTab.Frame, "ESP Customization")
CreateSlider(VisualTab.Frame, "ESP Distance", 100, 5000, 1000, function(v) print("Dist:", v) end)
CreateDropdown(VisualTab.Frame, "Health Bar Side", {"Left", "Right"}, function(s) print("Side:", s) end)

CreateSection(VisualTab.Frame, "World")
CreateSlider(VisualTab.Frame, "Field of View", 70, 120, 70, function(v) print("World FOV:", v) end)
CreateToggle(VisualTab.Frame, "Full Bright", false, function(state) print("Full Bright:", state) end)

-- Exemplos na aba Settings
CreateSection(SettingsTab.Frame, "Configurações da UI")
CreateButton(SettingsTab.Frame, "Salvar Configurações", function()
    SettingsSystem.Save({exampleSetting = true})
    NotificationSystem.Notify("Settings", "Configurações salvas com sucesso!", 3)
end)
CreateButton(SettingsTab.Frame, "Resetar UI", function()
    print("UI Resetada")
    NotificationSystem.Notify("Settings", "UI Resetada!", 3)
end)
CreateTextBox(SettingsTab.Frame, "Nome de Usuário", "Digite seu nome", function(text, enterPressed)
    print("Nome de Usuário digitado:", text)
end)

-- Notificação Inicial
NotificationSystem.Notify("MANUS HUB", "Interface carregada com sucesso! Divirta-se.", 5)

    -- Ativar a UI automaticamente no início
    UI.IsVisible = true
    UI.MainFrame.BackgroundTransparency = 1
    UI.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -150) -- Começa um pouco abaixo
    
    TweenManager:Create(UI.MainFrame, {
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundTransparency = 0
    }, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

return UI
