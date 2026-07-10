local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local PremiumUI = {}
PremiumUI.__index = PremiumUI

-- Configurações Globais
local CONFIG = {
    MAIN_COLOR = Color3.fromRGB(255, 45, 45), -- Vermelho vibrante para destaques
    BACKGROUND_COLOR = Color3.fromRGB(15, 15, 20), -- Dark background
    SECONDARY_BACKGROUND_COLOR = Color3.fromRGB(20, 20, 28), -- Cor para TopBar e Sidebar
    TEXT_COLOR = Color3.fromRGB(200, 200, 200),
    ACCENT_COLOR = Color3.fromRGB(255, 80, 80), -- Cor para hover/ativo
    BORDER_COLOR = Color3.fromRGB(50, 50, 60),
    CORNER_RADIUS = 18,
    STROKE_THICKNESS = 1.5,
    BLUR_INTENSITY = 10,
    WINDOW_SIZE = UDim2.new(0, 700, 0, 480),
    WINDOW_POSITION = UDim2.new(0.5, -350, 0.5, -240),
    TOPBAR_HEIGHT = 50,
    SIDEBAR_WIDTH = 180,
    CLOSE_ICON_ID = "rbxassetid://10747384394", -- Ícone de fechar
    MINIMIZE_ICON_ID = "rbxassetid://6031024344", -- Exemplo de ícone de minimizar
    OPEN_BUTTON_SIZE = UDim2.new(0, 50, 0, 50),
    OPEN_BUTTON_POSITION = UDim2.new(0, 10, 0, 10),
}

-- Funções Auxiliares
local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createUIStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency
    stroke.Parent = parent
    return stroke
end

local function applyHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
    end)
end

local function applyClickEffect(button)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08), {Size = button.Size * 0.95}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08), {Size = button.Size * (1/0.95)}):Play()
    end)
end

-- Construtor da UI Library
function PremiumUI.new(name)
    local self = setmetatable({}, PremiumUI)

    self.Name = name or "PremiumUI"
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = self.Name
    self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = CONFIG.WINDOW_SIZE
    self.MainFrame.Position = CONFIG.WINDOW_POSITION
    self.MainFrame.BackgroundColor3 = CONFIG.BACKGROUND_COLOR
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Active = true -- Necessário para arrastar
    self.MainFrame.Draggable = true -- Habilita arrastar

    createUICorner(self.MainFrame, CONFIG.CORNER_RADIUS)
    createUIStroke(self.MainFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS, 0.6)

    -- Background Blur Effect
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "BackgroundBlur"
    blurEffect.Size = CONFIG.BLUR_INTENSITY
    blurEffect.Parent = self.ScreenGui
    blurEffect.Enabled = false -- Desabilitado por padrão, ativado ao abrir a UI

    -- Top Bar
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, CONFIG.TOPBAR_HEIGHT)
    self.TopBar.Position = UDim2.new(0, 0, 0, 0)
    self.TopBar.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.MainFrame
    self.TopBar.Active = true -- Necessário para arrastar
    self.TopBar.Draggable = true -- Habilita arrastar

    createUICorner(self.TopBar, CONFIG.CORNER_RADIUS)

    -- Top Bar Title
    self.TopBarTitle = Instance.new("TextLabel")
    self.TopBarTitle.Name = "Title"
    self.TopBarTitle.Size = UDim2.new(1, -(CONFIG.TOPBAR_HEIGHT * 2), 1, 0)
    self.TopBarTitle.Position = UDim2.new(0, CONFIG.TOPBAR_HEIGHT / 2, 0, 0)
    self.TopBarTitle.BackgroundTransparency = 1
    self.TopBarTitle.Text = self.Name:upper()
    self.TopBarTitle.TextColor3 = CONFIG.MAIN_COLOR
    self.TopBarTitle.Font = Enum.Font.GothamBold
    self.TopBarTitle.TextSize = 22
    self.TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.TopBarTitle.Parent = self.TopBar

    -- Close Button (integrado do exemplo do usuário)
    self.CloseButton = Instance.new("ImageButton")
    self.CloseButton.Parent = self.TopBar
    self.CloseButton.Size = UDim2.new(0,32,0,32)
    self.CloseButton.Position = UDim2.new(1,-45,0.5,-16)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Image = CONFIG.CLOSE_ICON_ID
    self.CloseButton.ImageColor3 = CONFIG.TEXT_COLOR
    applyRippleEffect(self.CloseButton)

    self.CloseButton.MouseEnter:Connect(function()
        TweenService:Create(self.CloseButton,TweenInfo.new(0.15),{
            Size = UDim2.new(0,36,0,36),
            ImageColor3 = CONFIG.ACCENT_COLOR
        }):Play()
    end)

    self.CloseButton.MouseLeave:Connect(function()
        TweenService:Create(self.CloseButton,TweenInfo.new(0.15),{
            Size = UDim2.new(0,32,0,32),
            ImageColor3 = CONFIG.TEXT_COLOR
        }):Play()
    end)

    self.CloseButton.MouseButton1Click:Connect(function()
        -- Adicionar confirmação antes de fechar
        local confirmDialog = Instance.new("Frame")
        confirmDialog.Size = UDim2.new(0, 250, 0, 100)
        confirmDialog.Position = UDim2.new(0.5, -125, 0.5, -50)
        confirmDialog.BackgroundColor3 = CONFIG.BACKGROUND_COLOR
        confirmDialog.BorderSizePixel = 0
        confirmDialog.Parent = self.ScreenGui
        createUICorner(confirmDialog, 10)
        createUIStroke(confirmDialog, CONFIG.MAIN_COLOR, 1, 0.5)

        local confirmText = Instance.new("TextLabel")
        confirmText.Size = UDim2.new(1, -20, 0.5, 0)
        confirmText.Position = UDim2.new(0, 10, 0, 5)
        confirmText.BackgroundTransparency = 1
        confirmText.Text = "Deseja realmente fechar?"
        confirmText.TextColor3 = CONFIG.TEXT_COLOR
        confirmText.Font = Enum.Font.Gotham
        confirmText.TextSize = 16
        confirmText.Parent = confirmDialog

        local yesButton = Instance.new("TextButton")
        yesButton.Size = UDim2.new(0.4, 0, 0, 30)
        yesButton.Position = UDim2.new(0.1, 0, 0.6, 0)
        yesButton.BackgroundColor3 = CONFIG.MAIN_COLOR
        yesButton.BorderSizePixel = 0
        yesButton.Text = "Sim"
        yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesButton.Font = Enum.Font.GothamBold
        yesButton.TextSize = 16
        yesButton.Parent = confirmDialog
        createUICorner(yesButton, 8)
        applyHoverEffect(yesButton, CONFIG.MAIN_COLOR, CONFIG.ACCENT_COLOR)
        applyClickEffect(yesButton)
        applyRippleEffect(yesButton)

        local noButton = Instance.new("TextButton")
        noButton.Size = UDim2.new(0.4, 0, 0, 30)
        noButton.Position = UDim2.new(0.5, 10, 0.6, 0)
        noButton.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
        noButton.BorderSizePixel = 0
        noButton.Text = "Não"
        noButton.TextColor3 = CONFIG.TEXT_COLOR
        noButton.Font = Enum.Font.GothamBold
        noButton.TextSize = 16
        noButton.Parent = confirmDialog
        createUICorner(noButton, 8)
        applyHoverEffect(noButton, CONFIG.SECONDARY_BACKGROUND_COLOR, CONFIG.BORDER_COLOR)
        applyClickEffect(noButton)
        applyRippleEffect(noButton)

        yesButton.MouseButton1Click:Connect(function()
            TweenService:Create(self.MainFrame,TweenInfo.new(
                0.25,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),{
                Size = UDim2.new(0,0,0,0),
                Position = UDim2.new(0.5,0,0.5,0),
                BackgroundTransparency = 1
            }):Play()

            blurEffect.Enabled = false
            confirmDialog:Destroy()
            task.wait(0.25)
            self.ScreenGui:Destroy()
        end)

        noButton.MouseButton1Click:Connect(function()
            confirmDialog:Destroy()
        end)
    end)

    -- Minimize Button
    self.MinimizeButton = Instance.new("ImageButton")
    self.MinimizeButton.Parent = self.TopBar
    self.MinimizeButton.Size = UDim2.new(0,32,0,32)
    self.MinimizeButton.Position = UDim2.new(1,-85,0.5,-16)
    self.MinimizeButton.BackgroundTransparency = 1
    self.MinimizeButton.Image = CONFIG.MINIMIZE_ICON_ID
    self.MinimizeButton.ImageColor3 = CONFIG.TEXT_COLOR
    applyRippleEffect(self.MinimizeButton)

    self.MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(self.MinimizeButton,TweenInfo.new(0.15),{
            Size = UDim2.new(0,36,0,36),
            ImageColor3 = CONFIG.MAIN_COLOR
        }):Play()
    end)

    self.MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(self.MinimizeButton,TweenInfo.new(0.15),{
            Size = UDim2.new(0,32,0,32),
            ImageColor3 = CONFIG.TEXT_COLOR
        }):Play()
    end)

    self.MinimizeButton.MouseButton1Click:Connect(function()
        if self.MainFrame.Visible then
            TweenService:Create(self.MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(self.MainFrame.Position.X.Scale, self.MainFrame.Position.X.Offset + self.MainFrame.Size.X.Offset / 2, self.MainFrame.Position.Y.Scale, self.MainFrame.Position.Y.Offset + self.MainFrame.Size.Y.Offset / 2)}):Play()
            blurEffect.Enabled = false
            task.wait(0.2)
            self.MainFrame.Visible = false
        else
            self.MainFrame.Visible = true
            blurEffect.Enabled = true
            TweenService:Create(self.MainFrame, TweenInfo.new(0.2), {Size = CONFIG.WINDOW_SIZE, Position = CONFIG.WINDOW_POSITION}):Play()
        end
    end)

    -- Floating Open/Close Button
    self.FloatingButton = Instance.new("ImageButton")
    self.FloatingButton.Name = "FloatingButton"
    self.FloatingButton.Size = CONFIG.OPEN_BUTTON_SIZE
    self.FloatingButton.Position = CONFIG.OPEN_BUTTON_POSITION
    self.FloatingButton.BackgroundColor3 = CONFIG.MAIN_COLOR
    self.FloatingButton.BorderSizePixel = 0
    self.FloatingButton.Image = "rbxassetid://6031024344" -- Exemplo de ícone para o botão flutuante
    self.FloatingButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    self.FloatingButton.Parent = self.ScreenGui
    createUICorner(self.FloatingButton, CONFIG.CORNER_RADIUS / 2)
    createUIStroke(self.FloatingButton, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS, 0.6)
    applyHoverEffect(self.FloatingButton, CONFIG.MAIN_COLOR, CONFIG.ACCENT_COLOR)
    applyClickEffect(self.FloatingButton)
    applyRippleEffect(self.FloatingButton)

    self.FloatingButton.MouseButton1Click:Connect(function()
        if self.MainFrame.Visible then
            TweenService:Create(self.MainFrame,TweenInfo.new(
                0.25,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),{
                Size = UDim2.new(0,0,0,0),
                Position = UDim2.new(0.5,0,0.5,0),
                BackgroundTransparency = 1
            }):Play()
            blurEffect.Enabled = false
            task.wait(0.25)
            self.MainFrame.Visible = false
        else
            self.MainFrame.Visible = true
            blurEffect.Enabled = true
            TweenService:Create(self.MainFrame,TweenInfo.new(
                0.25,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),{
                Size = CONFIG.WINDOW_SIZE,
                Position = CONFIG.WINDOW_POSITION,
                BackgroundTransparency = 0
            }):Play()
        end
    end)

    -- Sidebar (Lateral Tab System)
    self.SideBar = Instance.new("Frame")
    self.SideBar.Name = "SideBar"
    self.SideBar.Size = UDim2.new(0, CONFIG.SIDEBAR_WIDTH, 1, -CONFIG.TOPBAR_HEIGHT)
    self.SideBar.Position = UDim2.new(0, 0, 0, CONFIG.TOPBAR_HEIGHT)
    self.SideBar.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    self.SideBar.BorderSizePixel = 0
    self.SideBar.Parent = self.MainFrame
    createUICorner(self.SideBar, CONFIG.CORNER_RADIUS - 5)
    createUIStroke(self.SideBar, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS, 0.6)

    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 1, 0)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 0)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.SideBar

    self.UIListLayout_Tabs = Instance.new("UIListLayout")
    self.UIListLayout_Tabs.FillDirection = Enum.FillDirection.Vertical
    self.UIListLayout_Tabs.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.UIListLayout_Tabs.Padding = UDim.new(0, 10)
    self.UIListLayout_Tabs.Parent = self.TabContainer

    self.Tabs = {}
    self.TabContents = Instance.new("Frame")
    self.TabContents.Name = "TabContents"
    self.TabContents.Size = UDim2.new(1, -CONFIG.SIDEBAR_WIDTH, 1, -CONFIG.TOPBAR_HEIGHT)
    self.TabContents.Position = UDim2.new(0, CONFIG.SIDEBAR_WIDTH, 0, CONFIG.TOPBAR_HEIGHT)
    self.TabContents.BackgroundTransparency = 1
    self.TabContents.Parent = self.MainFrame

    -- Inicialmente esconde a MainFrame
    self.MainFrame.Visible = false

    return self
end

-- Exemplo de uso:
-- local myUI = PremiumUI.new("Meu Hub Incrível")
-- myUI.MainFrame.Visible = true -- Para mostrar a UI inicialmente, ou usar o FloatingButton

return PremiumUI


-- Funções para criar componentes de UI
function PremiumUI:createTab(name, iconAssetId)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabButton"
    tabButton.Size = UDim2.new(0.9, 0, 0, 45)
    tabButton.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.Parent = self.TabContainer
    createUICorner(tabButton, CONFIG.CORNER_RADIUS / 2)
    createUIStroke(tabButton, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local tabIcon = Instance.new("ImageLabel")
    tabIcon.Name = "Icon"
    tabIcon.Size = UDim2.new(0, 28, 0, 28)
    tabIcon.Position = UDim2.new(0, 10, 0.5, -14)
    tabIcon.Image = iconAssetId
    tabIcon.BackgroundTransparency = 1
    tabIcon.ImageColor3 = CONFIG.TEXT_COLOR
    tabIcon.Parent = tabButton

    local tabText = Instance.new("TextLabel")
    tabText.Name = "Text"
    tabText.Size = UDim2.new(1, -50, 1, 0)
    tabText.Position = UDim2.new(0, 45, 0, 0)
    tabText.BackgroundTransparency = 1
    tabText.Text = name
    tabText.TextColor3 = CONFIG.TEXT_COLOR
    tabText.Font = Enum.Font.Gotham
    tabText.TextSize = 16
    tabText.TextXAlignment = Enum.TextXAlignment.Left
    tabText.Parent = tabButton

    local tabContentFrame = Instance.new("Frame")
    tabContentFrame.Name = name .. "Content"
    tabContentFrame.Size = UDim2.new(1, 0, 1, 0)
    tabContentFrame.Position = UDim2.new(0, 0, 0, 0)
    tabContentFrame.BackgroundTransparency = 1
    tabContentFrame.Visible = false
    tabContentFrame.Parent = self.TabContents

    self.Tabs[name] = {Button = tabButton, Content = tabContentFrame}

    applyHoverEffect(tabButton, CONFIG.SECONDARY_BACKGROUND_COLOR, CONFIG.ACCENT_COLOR)

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Content.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR}):Play()
            tab.Button.Icon.ImageColor3 = CONFIG.TEXT_COLOR
            tab.Button.Text.TextColor3 = CONFIG.TEXT_COLOR
        end
        tabContentFrame.Visible = true
        TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.MAIN_COLOR}):Play()
        tabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        tabText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return tabContentFrame
end

function PremiumUI:createSection(parent, titleText)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = titleText:gsub(" ", "") .. "Section"
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 150)
    sectionFrame.Position = UDim2.new(0.025, 0, 0.025, 0)
    sectionFrame.BackgroundColor3 = CONFIG.BACKGROUND_COLOR
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Parent = parent
    createUICorner(sectionFrame, CONFIG.CORNER_RADIUS / 2)
    createUIStroke(sectionFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "Title"
    sectionTitle.Size = UDim2.new(1, 0, 0, 30)
    sectionTitle.Position = UDim2.new(0, 0, 0, 0)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = titleText
    sectionTitle.TextColor3 = CONFIG.MAIN_COLOR
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextSize = 18
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.TextWrapped = true
    sectionTitle.Parent = sectionFrame

    local UIListLayout_Section = Instance.new("UIListLayout")
    UIListLayout_Section.FillDirection = Enum.FillDirection.Vertical
    UIListLayout_Section.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UIListLayout_Section.Padding = UDim.new(0, 5)
    UIListLayout_Section.Parent = sectionFrame

    return sectionFrame
end

function PremiumUI:createToggle(parent, labelText, defaultValue)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = labelText:gsub(" ", "") .. "Toggle"
    toggleFrame.Size = UDim2.new(0.95, 0, 0, 35)
    toggleFrame.Position = UDim2.new(0.025, 0, 0, 0)
    toggleFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    createUICorner(toggleFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(toggleFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = labelText
    toggleLabel.TextColor3 = CONFIG.TEXT_COLOR
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 60, 0, 25)
    toggleButton.Position = UDim2.new(1, -70, 0.5, -12.5)
    toggleButton.BackgroundColor3 = defaultValue and CONFIG.MAIN_COLOR or CONFIG.BORDER_COLOR
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = defaultValue and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.Parent = toggleFrame
    createUICorner(toggleButton, 15)

    local isToggled = defaultValue
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = CONFIG.MAIN_COLOR, Text = "ON"}):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = CONFIG.BORDER_COLOR, Text = "OFF"}):Play()
        end
    end)

    return toggleFrame, function() return isToggled end
end

function PremiumUI:createButton(parent, buttonText, callback)
    local button = Instance.new("TextButton")
    button.Name = buttonText:gsub(" ", "") .. "Button"
    button.Size = UDim2.new(0.95, 0, 0, 35)
    button.Position = UDim2.new(0.025, 0, 0, 0)
    button.BackgroundColor3 = CONFIG.MAIN_COLOR
    button.BorderSizePixel = 0
    button.Text = buttonText
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = parent
    createUICorner(button, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(button, CONFIG.MAIN_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)
    applyHoverEffect(button, CONFIG.MAIN_COLOR, CONFIG.ACCENT_COLOR)
    applyClickEffect(button)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end

    return button
end

function PremiumUI:createSlider(parent, labelText, minValue, maxValue, defaultValue, step, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = labelText:gsub(" ", "") .. "Slider"
    sliderFrame.Size = UDim2.new(0.95, 0, 0, 40)
    sliderFrame.Position = UDim2.new(0.025, 0, 0, 0)
    sliderFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = parent
    createUICorner(sliderFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(sliderFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "Label"
    sliderLabel.Size = UDim2.new(0.4, 0, 1, 0)
    sliderLabel.Position = UDim2.new(0, 10, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = labelText .. ": " .. defaultValue
    sliderLabel.TextColor3 = CONFIG.TEXT_COLOR
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "Bar"
    sliderBar.Size = UDim2.new(0.5, 0, 0, 10)
    sliderBar.Position = UDim2.new(0.45, 0, 0.5, -5)
    sliderBar.BackgroundColor3 = CONFIG.BORDER_COLOR
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = sliderFrame
    createUICorner(sliderBar, 5)

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = CONFIG.MAIN_COLOR
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar

    local sliderHandle = Instance.new("ImageLabel")
    sliderHandle.Name = "Handle"
    sliderHandle.Size = UDim2.new(0, 20, 0, 20)
    sliderHandle.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0.5, -10)
    sliderHandle.Image = CONFIG.MINIMIZE_ICON_ID -- Usando um ícone genérico por enquanto
    sliderHandle.ImageColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BackgroundTransparency = 1
    sliderHandle.ZIndex = 2
    sliderHandle.Parent = sliderBar

    local isDragging = false
    local currentValue = defaultValue

    local function updateSlider(x)
        local barWidth = sliderBar.AbsoluteSize.X
        local newX = math.clamp(x - sliderBar.AbsolutePosition.X, 0, barWidth)
        local percentage = newX / barWidth
        currentValue = minValue + (maxValue - minValue) * percentage
        currentValue = math.round(currentValue / step) * step
        currentValue = math.clamp(currentValue, minValue, maxValue)

        sliderFill.Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0)
        sliderHandle.Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -10, 0.5, -10)
        sliderLabel.Text = labelText .. ": " .. tostring(currentValue)

        if callback then
            callback(currentValue)
        end
    end

    sliderHandle.MouseButton1Down:Connect(function()
        isDragging = true
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    return sliderFrame, function() return currentValue end
end

function PremiumUI:createDropdown(parent, labelText, options, defaultValue, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = labelText:gsub(" ", "") .. "Dropdown"
    dropdownFrame.Size = UDim2.new(0.95, 0, 0, 35)
    dropdownFrame.Position = UDim2.new(0.025, 0, 0, 0)
    dropdownFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = parent
    createUICorner(dropdownFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(dropdownFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "Label"
    dropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = labelText .. ":"
    dropdownLabel.TextColor3 = CONFIG.TEXT_COLOR
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.TextSize = 14
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownFrame

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(0.4, 0, 0, 25)
    dropdownButton.Position = UDim2.new(0.55, 0, 0.5, -12.5)
    dropdownButton.BackgroundColor3 = CONFIG.BORDER_COLOR
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = defaultValue
    dropdownButton.TextColor3 = CONFIG.TEXT_COLOR
    dropdownButton.Font = Enum.Font.GothamBold
    dropdownButton.TextSize = 12
    dropdownButton.Parent = dropdownFrame
    createUICorner(dropdownButton, 5)
    applyHoverEffect(dropdownButton, CONFIG.BORDER_COLOR, CONFIG.ACCENT_COLOR)
    applyClickEffect(dropdownButton)

    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Altura será ajustada dinamicamente
    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
    optionsFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ClipsDescendants = true
    optionsFrame.Visible = false
    optionsFrame.Parent = dropdownFrame
    createUICorner(optionsFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(optionsFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local UIListLayout_Options = Instance.new("UIListLayout")
    UIListLayout_Options.FillDirection = Enum.FillDirection.Vertical
    UIListLayout_Options.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UIListLayout_Options.Padding = UDim.new(0, 2)
    UIListLayout_Options.Parent = optionsFrame

    local currentSelection = defaultValue

    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option .. "Option"
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = CONFIG.TEXT_COLOR
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 14
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.TextScaled = true
        optionButton.Parent = optionsFrame
        applyHoverEffect(optionButton, CONFIG.SECONDARY_BACKGROUND_COLOR, CONFIG.ACCENT_COLOR)
        applyClickEffect(optionButton)

        optionButton.MouseButton1Click:Connect(function()
            currentSelection = option
            dropdownButton.Text = option
            optionsFrame.Visible = false
            if callback then
                callback(option)
            end
        end)
    end

    dropdownButton.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
        if optionsFrame.Visible then
            optionsFrame.Size = UDim2.new(1, 0, 0, #options * 27) -- Ajusta a altura dinamicamente
        else
            optionsFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end)

    return dropdownFrame, function() return currentSelection end
end

function PremiumUI:createKeybind(parent, labelText, defaultKey, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = labelText:gsub(" ", "") .. "Keybind"
    keybindFrame.Size = UDim2.new(0.95, 0, 0, 35)
    keybindFrame.Position = UDim2.new(0.025, 0, 0, 0)
    keybindFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = parent
    createUICorner(keybindFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(keybindFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Name = "Label"
    keybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    keybindLabel.Position = UDim2.new(0, 10, 0, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = labelText .. ":"
    keybindLabel.TextColor3 = CONFIG.TEXT_COLOR
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.TextSize = 14
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindFrame

    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "Button"
    keybindButton.Size = UDim2.new(0, 70, 0, 25)
    keybindButton.Position = UDim2.new(1, -80, 0.5, -12.5)
    keybindButton.BackgroundColor3 = CONFIG.BORDER_COLOR
    keybindButton.BorderSizePixel = 0
    keybindButton.Text = defaultKey.Name
    keybindButton.TextColor3 = CONFIG.TEXT_COLOR
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.TextSize = 12
    keybindButton.Parent = keybindFrame
    createUICorner(keybindButton, 5)
    applyHoverEffect(keybindButton, CONFIG.BORDER_COLOR, CONFIG.ACCENT_COLOR)
    applyClickEffect(keybindButton)

    local isListening = false
    local currentKey = defaultKey

    keybindButton.MouseButton1Click:Connect(function()
        if not isListening then
            isListening = true
            keybindButton.Text = "Press Key..."
            keybindButton.TextColor3 = CONFIG.MAIN_COLOR
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if not gameProcessedEvent and isListening then
                    currentKey = input.KeyCode
                    keybindButton.Text = currentKey.Name
                    keybindButton.TextColor3 = CONFIG.TEXT_COLOR
                    isListening = false
                    if callback then
                        callback(currentKey)
                    end
                    connection:Disconnect()
                end
            end)
        end
    end)

    return keybindFrame, function() return currentKey end
end

function PremiumUI:createLabel(parent, labelText, textSize, textColor, textXAlignment)
    local label = Instance.new("TextLabel")
    label.Name = labelText:gsub(" ", "") .. "Label"
    label.Size = UDim2.new(0.95, 0, 0, textSize + 10)
    label.Position = UDim2.new(0.025, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = textColor or CONFIG.TEXT_COLOR
    label.Font = Enum.Font.Gotham
    label.TextSize = textSize or 14
    label.TextXAlignment = textXAlignment or Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = parent
    return label
end

-- Inicialização das abas
local HomeTabContent = PremiumUI:createTab("Home", "rbxassetid://6031024344") -- Ícone de casa
local CombatTabContent = PremiumUI:createTab("Combat", "rbxassetid://6031024344") -- Ícone de espada
local FarmTabContent = PremiumUI:createTab("Farm", "rbxassetid://6031024344") -- Ícone de trigo
local PlayerTabContent = PremiumUI:createTab("Player", "rbxassetid://6031024344") -- Ícone de pessoa
local VisualTabContent = PremiumUI:createTab("Visual", "rbxassetid://6031024344") -- Ícone de olho
local InventoryTabContent = PremiumUI:createTab("Inventory", "rbxassetid://6031024344") -- Ícone de mochila
local TeleportsTabContent = PremiumUI:createTab("Teleports", "rbxassetid://6031024344") -- Ícone de teletransporte
local SettingsTabContent = PremiumUI:createTab("Settings", "rbxassetid://6031024344") -- Ícone de engrenagem
local LogsTabContent = PremiumUI:createTab("Logs", "rbxassetid://6031024344") -- Ícone de log
local MiscTabContent = PremiumUI:createTab("Misc", "rbxassetid://6031024344") -- Ícone de estrela

-- Exemplo de conteúdo para a aba Home
local homeSection = PremiumUI:createSection(HomeTabContent, "Bem-vindo!")
PremiumUI:createLabel(homeSection, "Esta é a sua UI premium. Explore as opções!", 14, CONFIG.TEXT_COLOR, Enum.TextXAlignment.Center)
PremiumUI:createButton(homeSection, "Ativar Recurso", function() print("Recurso Ativado!") end)
local toggle, getToggleValue = PremiumUI:createToggle(homeSection, "Modo Deus", false)

local settingsSection = PremiumUI:createSection(SettingsTabContent, "Configurações Gerais")
local slider, getSliderValue = PremiumUI:createSlider(settingsSection, "Velocidade", 10, 100, 50, 5, function(value) print("Velocidade: " .. value) end)
local dropdown, getDropdownValue = PremiumUI:createDropdown(settingsSection, "Tema", {"Dark", "Light", "Red"}, "Dark", function(value) print("Tema selecionado: " .. value) end)
local keybind, getKeybindValue = PremiumUI:createKeybind(settingsSection, "Ativar Fly", Enum.KeyCode.F, function(key) print("Keybind para Fly: " .. key.Name) end)

-- Adicionar um ScrollFrame para o conteúdo das abas
function PremiumUI:addScrollFrame(parent)
    local scrollFrame = Instance.new("ScrollFrame")
    scrollFrame.Name = "ContentScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será ajustado dinamicamente
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = CONFIG.MAIN_COLOR
    scrollFrame.Parent = parent

    local UIListLayout_Scroll = Instance.new("UIListLayout")
    UIListLayout_Scroll.FillDirection = Enum.FillDirection.Vertical
    UIListLayout_Scroll.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UIListLayout_Scroll.Padding = UDim.new(0, 10)
    UIListLayout_Scroll.Parent = scrollFrame

    -- Ajustar CanvasSize dinamicamente
    scrollFrame.ChildAdded:Connect(function()
        local contentHeight = 0
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                contentHeight = contentHeight + child.Size.Y.Offset + UIListLayout_Scroll.Padding.Offset
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    end)

    return scrollFrame
end

-- Aplicar ScrollFrame a todas as abas
for _, tabInfo in pairs(PremiumUI.Tabs) do
    local scroll = PremiumUI:addScrollFrame(tabInfo.Content)
    -- Mover os elementos existentes para dentro do ScrollFrame
    for _, child in pairs(tabInfo.Content:GetChildren()) do
        if child ~= scroll then
            child.Parent = scroll
        end
    end
end

-- Exemplo de uso da UI (para testar, descomente e execute em um LocalScript no Roblox Studio)
-- local myUI = PremiumUI.new("Meu Hub Incrível")
-- myUI.FloatingButton.Visible = true -- Garante que o botão flutuante esteja visível

return PremiumUI

function PremiumUI:createTextbox(parent, labelText, placeholderText, defaultValue, callback)
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Name = labelText:gsub(" ", "") .. "Textbox"
    textboxFrame.Size = UDim2.new(0.95, 0, 0, 35)
    textboxFrame.Position = UDim2.new(0.025, 0, 0, 0)
    textboxFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    textboxFrame.BorderSizePixel = 0
    textboxFrame.Parent = parent
    createUICorner(textboxFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(textboxFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local textboxLabel = Instance.new("TextLabel")
    textboxLabel.Name = "Label"
    textboxLabel.Size = UDim2.new(0.3, 0, 1, 0)
    textboxLabel.Position = UDim2.new(0, 10, 0, 0)
    textboxLabel.BackgroundTransparency = 1
    textboxLabel.Text = labelText .. ":"
    textboxLabel.TextColor3 = CONFIG.TEXT_COLOR
    textboxLabel.Font = Enum.Font.Gotham
    textboxLabel.TextSize = 14
    textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textboxLabel.Parent = textboxFrame

    local textbox = Instance.new("TextBox")
    textbox.Name = "Input"
    textbox.Size = UDim2.new(0.6, 0, 0, 25)
    textbox.Position = UDim2.new(0.35, 0, 0.5, -12.5)
    textbox.BackgroundColor3 = CONFIG.BORDER_COLOR
    textbox.BorderSizePixel = 0
    textbox.Text = defaultValue or ""
    textbox.PlaceholderText = placeholderText or "Enter text..."
    textbox.PlaceholderColor3 = CONFIG.TEXT_COLOR * 0.5
    textbox.TextColor3 = CONFIG.TEXT_COLOR
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 12
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.Parent = textboxFrame
    createUICorner(textbox, 5)

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            if callback then
                callback(textbox.Text)
            end
        end
    end)

    return textboxFrame, function() return textbox.Text end
end

-- Adicionando um exemplo de Textbox na aba Home
PremiumUI:createTextbox(homeSection, "Nome", "Seu nome aqui", "", function(text) print("Nome digitado: " .. text) end)


local function applyRippleEffect(button)
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 10 -- Garante que o ripple apareça acima do botão
        ripple.Parent = button
        createUICorner(ripple, 999) -- Torna o frame circular

        local maxRadius = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5

        TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, maxRadius, 0, maxRadius),
            Position = UDim2.new(0, x - button.AbsolutePosition.X - maxRadius/2, 0, y - button.AbsolutePosition.Y - maxRadius/2),
            BackgroundTransparency = 1
        }):Play()

        game:GetService("Debris"):AddItem(ripple, 0.5)
    end)
end

-- Aplicar Ripple Effect aos botões existentes
-- É necessário modificar as funções createButton, createToggle, createDropdown, createKeybind para chamar applyRippleEffect
-- Por enquanto, vou adicionar um exemplo de como seria aplicado:
-- applyRippleEffect(self.CloseButton)
-- applyRippleEffect(self.MinimizeButton)
-- applyRippleEffect(self.FloatingButton)

-- Reaplicando o ripple effect nas funções de criação de componentes
-- (Isso exigiria reescrever as funções, mas para fins de demonstração, vou apenas indicar onde seria adicionado)
-- Nas funções createButton, createToggle, createDropdown, createKeybind, após a criação do botão, adicionar:
-- applyRippleEffect(button)

-- Para o botão de fechar e minimizar, já que são ImageButtons, o ripple pode ser um pouco diferente.
-- Vou ajustar o código do CloseButton e MinimizeButton para incluir o ripple.

-- Ajustando o CloseButton para incluir o ripple
-- (Este trecho será inserido no lugar do código existente do CloseButton)
-- (O mesmo para MinimizeButton)

-- Vou adicionar um placeholder para o ripple effect nos botões de exemplo na aba Home e Settings
-- PremiumUI:createButton(homeSection, "Ativar Recurso", function() print("Recurso Ativado!") end)
-- applyRippleEffect(homeSection.ActionButton) -- Exemplo de como seria aplicado

-- Para evitar reescrever as funções já criadas, vou criar uma nova versão das funções de criação de componentes
-- que já incluem o ripple effect. No entanto, para manter o código limpo e modular, o ideal seria refatorar as funções existentes.
-- Por enquanto, vou apenas adicionar a função e indicar que ela deve ser chamada nos botões.

-- Refatorando applyClickEffect para incluir o ripple
local originalApplyClickEffect = applyClickEffect
applyClickEffect = function(button)
    originalApplyClickEffect(button)
    applyRippleEffect(button)
end

-- Aplicando o ripple effect aos botões já criados na inicialização
applyRippleEffect(self.CloseButton)
applyRippleEffect(self.MinimizeButton)
applyRippleEffect(self.FloatingButton)


function PremiumUI:createColorPicker(parent, labelText, defaultValue, callback)
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name = labelText:gsub(" ", "") .. "ColorPicker"
    colorPickerFrame.Size = UDim2.new(0.95, 0, 0, 35)
    colorPickerFrame.Position = UDim2.new(0.025, 0, 0, 0)
    colorPickerFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    colorPickerFrame.BorderSizePixel = 0
    colorPickerFrame.Parent = parent
    createUICorner(colorPickerFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(colorPickerFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local colorPickerLabel = Instance.new("TextLabel")
    colorPickerLabel.Name = "Label"
    colorPickerLabel.Size = UDim2.new(0.6, 0, 1, 0)
    colorPickerLabel.Position = UDim2.new(0, 10, 0, 0)
    colorPickerLabel.BackgroundTransparency = 1
    colorPickerLabel.Text = labelText .. ":"
    colorPickerLabel.TextColor3 = CONFIG.TEXT_COLOR
    colorPickerLabel.Font = Enum.Font.Gotham
    colorPickerLabel.TextSize = 14
    colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorPickerLabel.Parent = colorPickerFrame

    local colorDisplay = Instance.new("Frame")
    colorDisplay.Name = "ColorDisplay"
    colorDisplay.Size = UDim2.new(0, 25, 0, 25)
    colorDisplay.Position = UDim2.new(1, -35, 0.5, -12.5)
    colorDisplay.BackgroundColor3 = defaultValue
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Parent = colorPickerFrame
    createUICorner(colorDisplay, 5)
    createUIStroke(colorDisplay, CONFIG.BORDER_COLOR, 1, 0.5)

    local colorPickerButton = Instance.new("TextButton")
    colorPickerButton.Name = "Button"
    colorPickerButton.Size = UDim2.new(0, 70, 0, 25)
    colorPickerButton.Position = UDim2.new(1, -110, 0.5, -12.5)
    colorPickerButton.BackgroundColor3 = CONFIG.BORDER_COLOR
    colorPickerButton.BorderSizePixel = 0
    colorPickerButton.Text = "Pick"
    colorPickerButton.TextColor3 = CONFIG.TEXT_COLOR
    colorPickerButton.Font = Enum.Font.GothamBold
    colorPickerButton.TextSize = 12
    colorPickerButton.Parent = colorPickerFrame
    createUICorner(colorPickerButton, 5)
    applyHoverEffect(colorPickerButton, CONFIG.BORDER_COLOR, CONFIG.ACCENT_COLOR)
    applyClickEffect(colorPickerButton)
    applyRippleEffect(colorPickerButton)

    local currentColor = defaultValue

    colorPickerButton.MouseButton1Click:Connect(function()
        -- Implementar um Color Picker mais complexo aqui (popup com paleta, slider HSL, etc.)
        -- Por simplicidade, para esta demonstração, vamos apenas mudar para uma cor aleatória ou predefinida.
        -- Em um ambiente real, você criaria um Frame popup com uma paleta de cores.
        local newColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        currentColor = newColor
        colorDisplay.BackgroundColor3 = newColor
        if callback then
            callback(newColor)
        end
    end)

    return colorPickerFrame, function() return currentColor end
end

-- Adicionando um exemplo de Color Picker na aba Settings
PremiumUI:createColorPicker(settingsSection, "Cor da UI", CONFIG.MAIN_COLOR, function(color) print("Cor selecionada: " .. tostring(color)) end)


-- Sistema de Notificações
function PremiumUI:createNotificationSystem()
    local notificationsFrame = Instance.new("Frame")
    notificationsFrame.Name = "NotificationsFrame"
    notificationsFrame.Size = UDim2.new(0, 250, 0, 0) -- Altura 0, será ajustada dinamicamente
    notificationsFrame.Position = UDim2.new(1, -260, 0, 60)
    notificationsFrame.BackgroundTransparency = 1
    notificationsFrame.BorderSizePixel = 0
    notificationsFrame.ClipsDescendants = true
    notificationsFrame.Parent = self.ScreenGui

    local UIListLayout_Notifications = Instance.new("UIListLayout")
    UIListLayout_Notifications.FillDirection = Enum.FillDirection.Vertical
    UIListLayout_Notifications.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout_Notifications.VerticalAlignment = Enum.VerticalAlignment.Bottom
    UIListLayout_Notifications.Padding = UDim.new(0, 10)
    UIListLayout_Notifications.Parent = notificationsFrame

    local function showNotification(message, duration, notificationType)
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.Size = UDim2.new(0, 250, 0, 50)
        notification.Position = UDim2.new(1, 0, 0, 0) -- Começa fora da tela
        notification.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
        notification.BorderSizePixel = 0
        notification.Parent = notificationsFrame
        createUICorner(notification, CONFIG.CORNER_RADIUS / 3)
        createUIStroke(notification, CONFIG.MAIN_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

        local notificationText = Instance.new("TextLabel")
        notificationText.Name = "Text"
        notificationText.Size = UDim2.new(1, -20, 1, 0)
        notificationText.Position = UDim2.new(0, 10, 0, 0)
        notificationText.BackgroundTransparency = 1
        notificationText.Text = message
        notificationText.TextColor3 = CONFIG.TEXT_COLOR
        notificationText.Font = Enum.Font.Gotham
        notificationText.TextSize = 14
        notificationText.TextWrapped = true
        notificationText.TextXAlignment = Enum.TextXAlignment.Left
        notificationText.Parent = notification

        -- Animação de entrada
        TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

        -- Ajustar a altura do frame de notificações
        local currentHeight = notificationsFrame.Size.Y.Offset
        local newHeight = currentHeight + notification.Size.Y.Offset + UIListLayout_Notifications.Padding.Offset
        TweenService:Create(notificationsFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 250, 0, newHeight)}):Play()

        task.delay(duration, function()
            -- Animação de saída
            TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.3)
            notification:Destroy()

            -- Reajustar a altura do frame de notificações
            local remainingHeight = 0
            for _, child in pairs(notificationsFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name == "Notification" then
                    remainingHeight = remainingHeight + child.Size.Y.Offset + UIListLayout_Notifications.Padding.Offset
                end
            end
            TweenService:Create(notificationsFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 250, 0, remainingHeight)}):Play()
        end)
    end

    return showNotification
end

-- Inicializa o sistema de notificações
local notify = PremiumUI:createNotificationSystem()

-- Adicionando um botão de teste para notificações na aba Home
PremiumUI:createButton(homeSection, "Mostrar Notificação", function()
    notify("Isso é uma notificação de teste!", 3, "info")
end)


function PremiumUI:createSearchBar(parent, placeholderText, callback)
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchBar"
    searchFrame.Size = UDim2.new(0.95, 0, 0, 35)
    searchFrame.Position = UDim2.new(0.025, 0, 0, 0)
    searchFrame.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = parent
    createUICorner(searchFrame, CONFIG.CORNER_RADIUS / 3)
    createUIStroke(searchFrame, CONFIG.BORDER_COLOR, CONFIG.STROKE_THICKNESS / 2, 0.8)

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.new(0, 20, 0, 20)
    searchIcon.Position = UDim2.new(0, 10, 0.5, -10)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://6031024344" -- Exemplo de ícone de pesquisa
    searchIcon.ImageColor3 = CONFIG.TEXT_COLOR
    searchIcon.Parent = searchFrame

    local searchTextBox = Instance.new("TextBox")
    searchTextBox.Name = "SearchInput"
    searchTextBox.Size = UDim2.new(1, -40, 1, 0)
    searchTextBox.Position = UDim2.new(0, 35, 0, 0)
    searchTextBox.BackgroundTransparency = 1
    searchTextBox.PlaceholderText = placeholderText or "Pesquisar..."
    searchTextBox.PlaceholderColor3 = CONFIG.TEXT_COLOR * 0.5
    searchTextBox.TextColor3 = CONFIG.TEXT_COLOR
    searchTextBox.Font = Enum.Font.Gotham
    searchTextBox.TextSize = 14
    searchTextBox.TextXAlignment = Enum.TextXAlignment.Left
    searchTextBox.Parent = searchFrame

    searchTextBox.Changed:Connect(function(property)
        if property == "Text" then
            if callback then
                callback(searchTextBox.Text)
            end
        end
    end)

    return searchFrame, function() return searchTextBox.Text end
end

-- Adicionando um exemplo de Search Bar na aba Home
PremiumUI:createSearchBar(homeSection, "Pesquisar recursos...", function(text) print("Pesquisando: " .. text) end)


-- Sistema de Tooltips
function PremiumUI:createTooltip(uiElement, tooltipText)
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 0, 0, 0) -- Tamanho inicial 0, será ajustado
    tooltip.BackgroundTransparency = 1
    tooltip.BorderSizePixel = 0
    tooltip.Text = tooltipText
    tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
    tooltip.Font = Enum.Font.Gotham
    tooltip.TextSize = 12
    tooltip.TextWrapped = true
    tooltip.TextXAlignment = Enum.TextXAlignment.Center
    tooltip.TextYAlignment = Enum.TextYAlignment.Center
    tooltip.ZIndex = 100 -- Garante que o tooltip apareça acima de tudo
    tooltip.Parent = self.ScreenGui -- Parent no ScreenGui para evitar clipping

    local tooltipBackground = Instance.new("Frame")
    tooltipBackground.Name = "Background"
    tooltipBackground.Size = UDim2.new(1, 10, 1, 10) -- Padding para o texto
    tooltipBackground.Position = UDim2.new(0, -5, 0, -5)
    tooltipBackground.BackgroundColor3 = CONFIG.SECONDARY_BACKGROUND_COLOR
    tooltipBackground.BackgroundTransparency = 0.1
    tooltipBackground.BorderSizePixel = 0
    tooltipBackground.Parent = tooltip
    createUICorner(tooltipBackground, 5)
    createUIStroke(tooltipBackground, CONFIG.BORDER_COLOR, 1, 0.5)

    tooltip.Visible = false

    uiElement.MouseEnter:Connect(function()
        tooltip.Visible = true
        tooltip.Text = tooltipText -- Atualiza o texto caso seja dinâmico
        -- Ajusta o tamanho do tooltip com base no texto
        local textSize = TweenService:Create(tooltip, TweenInfo.new(0.1), {TextSize = tooltip.TextSize}):Play()
        local textBounds = game:GetService("TextService"):GetTextSize(tooltip.Text, tooltip.TextSize, tooltip.Font, Vector2.new(200, 100))
        tooltip.Size = UDim2.new(0, textBounds.X + 20, 0, textBounds.Y + 10)

        -- Posiciona o tooltip acima do elemento
        local elementAbsolutePosition = uiElement.AbsolutePosition
        local elementAbsoluteSize = uiElement.AbsoluteSize
        local tooltipAbsoluteSize = tooltip.AbsoluteSize

        tooltip.Position = UDim2.new(0, elementAbsolutePosition.X + elementAbsoluteSize.X / 2 - tooltipAbsoluteSize.X / 2,
                                     0, elementAbsolutePosition.Y - tooltipAbsoluteSize.Y - 10)

        TweenService:Create(tooltip, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    end)

    uiElement.MouseLeave:Connect(function()
        TweenService:Create(tooltip, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.2)
        tooltip.Visible = false
    end)

    return tooltip
end

-- Adicionando um tooltip de exemplo ao botão "Ativar Recurso" na aba Home
PremiumUI:createTooltip(homeSection.ActionButton, "Clique para ativar o recurso principal.")


-- Adicionando informações na TopBar
function PremiumUI:addTopBarInfo()
    -- FPS Counter
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSCounter"
    fpsLabel.Size = UDim2.new(0, 60, 1, 0)
    fpsLabel.Position = UDim2.new(0, self.TopBarTitle.Size.X.Offset + self.TopBarTitle.Position.X.Offset + 10, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = CONFIG.TEXT_COLOR
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextSize = 14
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = self.TopBar

    game:GetService("RunService").RenderStepped:Connect(function()
        fpsLabel.Text = "FPS: " .. math.floor(1 / game:GetService("RunService").Heartbeat:Wait())
    end)

    -- Hora Atual
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "CurrentTime"
    timeLabel.Size = UDim2.new(0, 80, 1, 0)
    timeLabel.Position = UDim2.new(0, fpsLabel.Position.X.Offset + fpsLabel.Size.X.Offset + 10, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = CONFIG.TEXT_COLOR
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 14
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = self.TopBar

    local function updateTime()
        local currentTime = os.date("%H:%M:%S")
        timeLabel.Text = "Hora: " .. currentTime
    end
    updateTime()
    game:GetService("RunService").Heartbeat:Connect(updateTime)

    -- Nome do Jogador e Avatar
    local playerInfoFrame = Instance.new("Frame")
    playerInfoFrame.Name = "PlayerInfo"
    playerInfoFrame.Size = UDim2.new(0, 150, 1, 0)
    playerInfoFrame.Position = UDim2.new(1, -self.CloseButton.Position.X.Offset - self.CloseButton.Size.X.Offset - 10, 0, 0)
    playerInfoFrame.BackgroundTransparency = 1
    playerInfoFrame.Parent = self.TopBar

    local playerAvatar = Instance.new("ImageLabel")
    playerAvatar.Name = "Avatar"
    playerAvatar.Size = UDim2.new(0, 30, 0, 30)
    playerAvatar.Position = UDim2.new(0, 0, 0.5, -15)
    playerAvatar.BackgroundTransparency = 1
    playerAvatar.Image = Players.LocalPlayer.Thumbnail.Url -- Obtém o avatar do jogador
    playerAvatar.Parent = playerInfoFrame
    createUICorner(playerAvatar, 999) -- Avatar circular

    local playerNameLabel = Instance.new("TextLabel")
    playerNameLabel.Name = "Name"
    playerNameLabel.Size = UDim2.new(1, -40, 0.5, 0)
    playerNameLabel.Position = UDim2.new(0, 35, 0, 0)
    playerNameLabel.BackgroundTransparency = 1
    playerNameLabel.Text = Players.LocalPlayer.Name
    playerNameLabel.TextColor3 = CONFIG.TEXT_COLOR
    playerNameLabel.Font = Enum.Font.GothamBold
    playerNameLabel.TextSize = 14
    playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerNameLabel.Parent = playerInfoFrame

    local playerStatusLabel = Instance.new("TextLabel")
    playerStatusLabel.Name = "Status"
    playerStatusLabel.Size = UDim2.new(1, -40, 0.5, 0)
    playerStatusLabel.Position = UDim2.new(0, 35, 0.5, 0)
    playerStatusLabel.BackgroundTransparency = 1
    playerStatusLabel.Text = "Online"
    playerStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Verde para online
    playerStatusLabel.Font = Enum.Font.Gotham
    playerStatusLabel.TextSize = 12
    playerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerStatusLabel.Parent = playerInfoFrame

    -- Discord Button
    local discordButton = Instance.new("ImageButton")
    discordButton.Name = "DiscordButton"
    discordButton.Size = UDim2.new(0, 30, 0, 30)
    discordButton.Position = UDim2.new(1, -self.MinimizeButton.Position.X.Offset - self.MinimizeButton.Size.X.Offset - 10, 0.5, -15)
    discordButton.BackgroundTransparency = 1
    discordButton.Image = "rbxassetid://6031024344" -- Placeholder para ícone do Discord
    discordButton.ImageColor3 = CONFIG.TEXT_COLOR
    discordButton.Parent = self.TopBar
    createUICorner(discordButton, 5)
    applyHoverEffect(discordButton, Color3.fromRGB(0,0,0), Color3.fromRGB(114, 137, 218)) -- Cor do Discord
    applyRippleEffect(discordButton)
    discordButton.MouseButton1Click:Connect(function()
        -- game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Discord", Text = "Link copiado para a área de transferência!"})
        -- setclipboard("https://discord.gg/yourinvite") -- Necessita de permissão de script ou módulo externo
        notify("Link do Discord copiado! (Funcionalidade de copiar para clipboard requer permissões)", 3, "info")
    end)

    -- Copy Link Button
    local copyLinkButton = Instance.new("ImageButton")
    copyLinkButton.Name = "CopyLinkButton"
    copyLinkButton.Size = UDim2.new(0, 30, 0, 30)
    copyLinkButton.Position = UDim2.new(1, -discordButton.Position.X.Offset - discordButton.Size.X.Offset - 10, 0.5, -15)
    copyLinkButton.BackgroundTransparency = 1
    copyLinkButton.Image = "rbxassetid://6031024344" -- Placeholder para ícone de copiar link
    copyLinkButton.ImageColor3 = CONFIG.TEXT_COLOR
    copyLinkButton.Parent = self.TopBar
    createUICorner(copyLinkButton, 5)
    applyHoverEffect(copyLinkButton, Color3.fromRGB(0,0,0), CONFIG.ACCENT_COLOR)
    applyRippleEffect(copyLinkButton)
    copyLinkButton.MouseButton1Click:Connect(function()
        -- setclipboard("https://yourwebsite.com/yourscript") -- Necessita de permissão de script ou módulo externo
        notify("Link do script copiado! (Funcionalidade de copiar para clipboard requer permissões)", 3, "info")
    end)
end

-- Chamar a função para adicionar as informações na TopBar após a criação da UI
-- myUI:addTopBarInfo() -- Exemplo de como seria chamado

-- Adicionando a chamada para addTopBarInfo dentro do construtor PremiumUI.new
local originalNew = PremiumUI.new
function PremiumUI.new(name)
    local self = originalNew(name)
    self:addTopBarInfo()
    return self
end

-- Sistema de Temas (simplificado para demonstração)
function PremiumUI:applyTheme(themeName)
    if themeName == "Dark" then
        CONFIG.MAIN_COLOR = Color3.fromRGB(255, 45, 45)
        CONFIG.BACKGROUND_COLOR = Color3.fromRGB(15, 15, 20)
        CONFIG.SECONDARY_BACKGROUND_COLOR = Color3.fromRGB(20, 20, 28)
        CONFIG.TEXT_COLOR = Color3.fromRGB(200, 200, 200)
        CONFIG.ACCENT_COLOR = Color3.fromRGB(255, 80, 80)
        CONFIG.BORDER_COLOR = Color3.fromRGB(50, 50, 60)
    elseif themeName == "Light" then
        CONFIG.MAIN_COLOR = Color3.fromRGB(0, 120, 255)
        CONFIG.BACKGROUND_COLOR = Color3.fromRGB(240, 240, 240)
        CONFIG.SECONDARY_BACKGROUND_COLOR = Color3.fromRGB(255, 255, 255)
        CONFIG.TEXT_COLOR = Color3.fromRGB(50, 50, 50)
        CONFIG.ACCENT_COLOR = Color3.fromRGB(50, 150, 255)
        CONFIG.BORDER_COLOR = Color3.fromRGB(200, 200, 200)
    elseif themeName == "Red" then
        CONFIG.MAIN_COLOR = Color3.fromRGB(255, 0, 0)
        CONFIG.BACKGROUND_COLOR = Color3.fromRGB(10, 0, 0)
        CONFIG.SECONDARY_BACKGROUND_COLOR = Color3.fromRGB(20, 0, 0)
        CONFIG.TEXT_COLOR = Color3.fromRGB(255, 200, 200)
        CONFIG.ACCENT_COLOR = Color3.fromRGB(255, 50, 50)
        CONFIG.BORDER_COLOR = Color3.fromRGB(80, 0, 0)
    end
    -- Aplicar as novas cores aos elementos existentes (requer refatoração para ser dinâmico)
    -- Por enquanto, apenas atualiza as configurações globais.
    notify("Tema \"" .. themeName .. "\" aplicado!", 2, "info")
end

-- Sistema de Configurações e Auto-save (simplificado)
local SETTINGS_KEY = "PremiumUILibrary_Settings"

function PremiumUI:saveSettings(settingsTable)
    local success, err = pcall(function()
        game:GetService("DataStoreService"):GetDataStore(SETTINGS_KEY):SetAsync(LocalPlayer.UserId, settingsTable)
    end)
    if success then
        notify("Configurações salvas com sucesso!", 2, "success")
    else
        warn("Erro ao salvar configurações: ", err)
        notify("Erro ao salvar configurações!", 3, "error")
    end
end

function PremiumUI:loadSettings()
    local settings = {}
    local success, data = pcall(function()
        settings = game:GetService("DataStoreService"):GetDataStore(SETTINGS_KEY):GetAsync(LocalPlayer.UserId)
    end)
    if success and data then
        notify("Configurações carregadas com sucesso!", 2, "success")
        return data
    else
        warn("Erro ao carregar configurações ou nenhuma encontrada: ", err)
        notify("Nenhuma configuração encontrada ou erro ao carregar!", 3, "warning")
        return {}
    end
end

-- Exemplo de uso na aba Settings
PremiumUI:createButton(settingsSection, "Salvar Configurações", function()
    local currentSettings = {
        theme = getDropdownValue(), -- Supondo que o dropdown de tema retorne o valor atual
        speed = getSliderValue(), -- Supondo que o slider de velocidade retorne o valor atual
        godMode = getToggleValue(), -- Supondo que o toggle de modo deus retorne o valor atual
        -- Adicione todas as configurações que deseja salvar aqui
    }
    PremiumUI:saveSettings(currentSettings)
end)

PremiumUI:createButton(settingsSection, "Carregar Configurações", function()
    local loadedSettings = PremiumUI:loadSettings()
    -- Aplicar as configurações carregadas (requer lógica para cada componente)
    if loadedSettings.theme then
        PremiumUI:applyTheme(loadedSettings.theme)
        -- Atualizar o dropdown visualmente
    end
    -- ... e assim por diante para outros componentes
    notify("Configurações carregadas e aplicadas (se houver)!", 3, "info")
end)

-- Sistema para adicionar novas abas facilmente (já implementado via createTab)
-- Sistema para adicionar novos módulos facilmente (já implementado via funções createSection, createToggle, etc.)

-- Exemplo de como criar uma nova aba e adicionar um módulo:
-- local NewTabContent = myUI:createTab("Novo", "rbxassetid://6031024344")
-- local newSection = myUI:createSection(NewTabContent, "Módulo Novo")
-- myUI:createToggle(newSection, "Recurso Novo", true)

-- Finalizando o construtor para garantir que todas as inicializações ocorram
-- O código acima já sobrescreve PremiumUI.new, então não é necessário fazer mais nada aqui.
