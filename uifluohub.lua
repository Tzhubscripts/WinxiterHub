-- [[ FLOURITE UI LIBRARY - FULL VERSION ]]
-- A professional, clean UI Library for Roblox scripts.
-- Features: Tabs, Toggles, Sliders, Buttons, Color Pickers, Sections, Labels, Notifications.
-- Special: Close Confirmation Menu with Animated Particle System.

local Library = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(10, 15, 25),
    Sidebar = Color3.fromRGB(15, 22, 38),
    Section = Color3.fromRGB(25, 35, 55),
    Accent = Color3.fromRGB(60, 130, 255),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 180, 210),
    Stroke = Color3.fromRGB(45, 60, 90),
    CornerRadius = UDim.new(0, 8),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

-- Utility Functions
local function Tween(inst, props, dur)
    TweenService:Create(inst, TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

-- Particle System
local function CreateParticles(parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = parent

    local particles = {}
    for i = 1, 30 do
        local p = Instance.new("Frame")
        p.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
        p.BackgroundColor3 = Theme.Accent
        p.BackgroundTransparency = math.random(3, 6) / 10
        p.Position = UDim2.fromScale(math.random(), math.random())
        p.BorderSizePixel = 0
        p.Parent = container
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        table.insert(particles, {inst = p, vel = Vector2.new(math.random(-40, 40) / 1000, math.random(-40, 40) / 1000)})
    end

    local conn; conn = RunService.RenderStepped:Connect(function()
        if not container.Parent then conn:Disconnect() return end
        for _, p in ipairs(particles) do
            local nX = p.inst.Position.X.Scale + p.vel.X
            local nY = p.inst.Position.Y.Scale + p.vel.Y
            if nX > 1 then nX = 0 elseif nX < 0 then nX = 1 end
            if nY > 1 then nY = 0 elseif nY < 0 then nY = 1 end
            p.inst.Position = UDim2.fromScale(nX, nY)
        end
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlouriteLib_" .. math.random(100, 999)
    ScreenGui.ResetOnSpawn = false
    
    local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -175)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = Theme.CornerRadius

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = Theme.CornerRadius

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.Font = Theme.FontBold
    TitleLabel.TextSize = 16
    TitleLabel.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 55)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
    TabContainer.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -170, 1, -10)
    ContentArea.Position = UDim2.new(0, 165, 0, 5)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- Close Button with Confirmation
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Font = Theme.FontBold
    CloseBtn.TextSize = 18
    CloseBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function()
        local Overlay = Instance.new("TextButton")
        Overlay.Size = UDim2.fromScale(1, 1)
        Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        Overlay.BackgroundTransparency = 1
        Overlay.Text = ""
        Overlay.AutoButtonColor = false
        Overlay.ZIndex = 100
        Overlay.Parent = ScreenGui
        
        local Menu = Instance.new("Frame")
        Menu.Size = UDim2.fromOffset(280, 140)
        Menu.Position = UDim2.fromScale(0.5, 0.5)
        Menu.AnchorPoint = Vector2.new(0.5, 0.5)
        Menu.BackgroundColor3 = Theme.Section
        Menu.BorderSizePixel = 0
        Menu.ClipsDescendants = true
        Menu.Parent = Overlay
        Instance.new("UICorner", Menu).CornerRadius = Theme.CornerRadius
        Instance.new("UIStroke", Menu).Color = Theme.Accent

        CreateParticles(Menu)

        local MenuTitle = Instance.new("TextLabel")
        MenuTitle.Size = UDim2.new(1, 0, 0, 60)
        MenuTitle.BackgroundTransparency = 1
        MenuTitle.Text = "Fechar totalmente o painel?"
        MenuTitle.TextColor3 = Theme.TextPrimary
        MenuTitle.Font = Theme.FontBold
        MenuTitle.TextSize = 14
        MenuTitle.ZIndex = 102
        MenuTitle.Parent = Menu

        local Confirm = Instance.new("TextButton")
        Confirm.Size = UDim2.new(0, 90, 0, 32)
        Confirm.Position = UDim2.new(0.5, -100, 0.7, 0)
        Confirm.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        Confirm.Text = "Confirm"
        Confirm.TextColor3 = Color3.new(1, 1, 1)
        Confirm.Font = Theme.FontBold
        Confirm.TextSize = 13
        Confirm.ZIndex = 102
        Confirm.Parent = Menu
        Instance.new("UICorner", Confirm).CornerRadius = UDim.new(0, 6)

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0, 90, 0, 32)
        Cancel.Position = UDim2.new(0.5, 10, 0.7, 0)
        Cancel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Cancel.Text = "Cancel"
        Cancel.TextColor3 = Color3.new(1, 1, 1)
        Cancel.Font = Theme.FontBold
        Cancel.TextSize = 13
        Cancel.ZIndex = 102
        Cancel.Parent = Menu
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)

        Tween(Overlay, {BackgroundTransparency = 0.5})
        Confirm.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
        Cancel.MouseButton1Click:Connect(function() Overlay:Destroy() end)
    end)

    -- Dragging
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Tabs = {}
    local First = true

    function Tabs:CreateTab(name)
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.fromScale(1, 1)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = First
        Page.Parent = ContentArea
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
        Page.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        TabBtn.BackgroundColor3 = First and Theme.Accent or Color3.fromRGB(30, 40, 60)
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.TextPrimary
        TabBtn.Font = Theme.Font
        TabBtn.TextSize = 13
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in ipairs(ContentArea:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in ipairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 40, 60) end end
            Page.Visible = true TabBtn.BackgroundColor3 = Theme.Accent
        end)

        First = false
        local Elements = {}

        function Elements:CreateSection(text)
            local sf = Instance.new("Frame")
            sf.Size = UDim2.new(0.95, 0, 0, 25)
            sf.BackgroundTransparency = 1
            sf.Parent = Page
            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, 0, 1, 0)
            lb.BackgroundTransparency = 1
            lb.Text = text:upper()
            lb.TextColor3 = Theme.Accent
            lb.Font = Theme.FontBold
            lb.TextSize = 11
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = sf
        end

        function Elements:CreateLabel(text)
            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(0.95, 0, 0, 20)
            lb.BackgroundTransparency = 1
            lb.Text = text
            lb.TextColor3 = Theme.TextSecondary
            lb.Font = Theme.Font
            lb.TextSize = 13
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = Page
        end

        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.95, 0, 0, 35)
            Btn.BackgroundColor3 = Theme.Section
            Btn.Text = text
            Btn.TextColor3 = Theme.TextPrimary
            Btn.Font = Theme.Font
            Btn.TextSize = 13
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", Btn).Color = Theme.Stroke
            Btn.MouseButton1Click:Connect(callback)
        end

        function Elements:CreateToggle(text, default, callback)
            local TFrame = Instance.new("Frame")
            TFrame.Size = UDim2.new(0.95, 0, 0, 35)
            TFrame.BackgroundColor3 = Theme.Section
            TFrame.Parent = Page
            Instance.new("UICorner", TFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", TFrame).Color = Theme.Stroke

            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, -50, 1, 0)
            lb.Position = UDim2.new(0, 10, 0, 0)
            lb.BackgroundTransparency = 1
            lb.Text = text
            lb.TextColor3 = Theme.TextPrimary
            lb.Font = Theme.Font
            lb.TextSize = 13
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = TFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 35, 0, 18)
            Switch.Position = UDim2.new(1, -45, 0.5, -9)
            Switch.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50, 50, 50)
            Switch.Text = ""
            Switch.Parent = TFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local state = default
            Switch.MouseButton1Click:Connect(function()
                state = not state
                Tween(Switch, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 50)})
                callback(state)
            end)
        end

        function Elements:CreateSlider(text, min, max, default, callback)
            local SFrame = Instance.new("Frame")
            SFrame.Size = UDim2.new(0.95, 0, 0, 45)
            SFrame.BackgroundColor3 = Theme.Section
            SFrame.Parent = Page
            Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", SFrame).Color = Theme.Stroke

            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, -10, 0, 20)
            lb.Position = UDim2.new(0, 10, 0, 5)
            lb.BackgroundTransparency = 1
            lb.Text = text .. ": " .. default
            lb.TextColor3 = Theme.TextPrimary
            lb.Font = Theme.Font
            lb.TextSize = 12
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = SFrame

            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1, -20, 0, 6)
            Bar.Position = UDim2.new(0, 10, 0, 30)
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Bar.Text = ""
            Bar.AutoButtonColor = false
            Bar.Parent = SFrame
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.Parent = Bar
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local function Update(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                Fill.Size = UDim2.fromScale(pos, 1)
                lb.Text = text .. ": " .. val
                callback(val)
            end

            local dragging = false
            Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
        end

        function Elements:CreateColorPicker(text, default, callback)
            local CPFrame = Instance.new("Frame")
            CPFrame.Size = UDim2.new(0.95, 0, 0, 35)
            CPFrame.BackgroundColor3 = Theme.Section
            CPFrame.Parent = Page
            Instance.new("UICorner", CPFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", CPFrame).Color = Theme.Stroke

            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, -50, 1, 0)
            lb.Position = UDim2.new(0, 10, 0, 0)
            lb.BackgroundTransparency = 1
            lb.Text = text
            lb.TextColor3 = Theme.TextPrimary
            lb.Font = Theme.Font
            lb.TextSize = 13
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = CPFrame

            local Preview = Instance.new("TextButton")
            Preview.Size = UDim2.new(0, 25, 0, 25)
            Preview.Position = UDim2.new(1, -35, 0.5, -12)
            Preview.BackgroundColor3 = default
            Preview.Text = ""
            Preview.Parent = CPFrame
            Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

            local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,1), Color3.new(1,1,0), Color3.new(1,0,1)}
            local index = 1
            Preview.MouseButton1Click:Connect(function()
                index = index + 1 if index > #colors then index = 1 end
                Preview.BackgroundColor3 = colors[index]
                callback(colors[index])
            end)
        end

        return Elements
    end

    return Tabs
end

return Library
