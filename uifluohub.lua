-- [[ MIKASA HUB - OFFICIAL LIBRARY ]]
-- Extracted from the original design for professional use.
-- Features: Animated Confirmation Close Menu, Particle System, and Original UI Components.

local Library = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Original Theme
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

-- Original Tween Manager
local TweenMgr = {}
local DEFAULT_TI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function TweenMgr.Create(inst, props, ti)
    local t = TweenService:Create(inst, ti or DEFAULT_TI, props)
    t:Play()
    return t
end

function TweenMgr.Ripple(inst, color)
    inst.MouseButton1Click:Connect(function()
        local r = Instance.new("Frame")
        r.BackgroundColor3 = color or Color3.new(1, 1, 1)
        r.BackgroundTransparency = 0.6
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.Position = UDim2.new(0.5, 0, 0.5, 0)
        r.Size = UDim2.new(0, 0, 0, 0)
        r.Parent = inst
        Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)
        TweenMgr.Create(r, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        task.delay(0.6, function() r:Destroy() end)
    end)
end

-- Particle System for Confirmation Menu
local function CreateParticles(parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = parent

    local particles = {}
    for i = 1, 25 do
        local p = Instance.new("Frame")
        p.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
        p.BackgroundColor3 = Theme.Accent
        p.BackgroundTransparency = math.random(3, 6) / 10
        p.Position = UDim2.fromScale(math.random(), math.random())
        p.BorderSizePixel = 0
        p.Parent = container
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        table.insert(particles, {inst = p, vel = Vector2.new(math.random(-30, 30) / 1000, math.random(-30, 30) / 1000)})
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
    ScreenGui.Name = "MikasaLibrary_" .. math.random(100, 999)
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
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
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
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -140, 1, 0)
    ContentArea.Position = UDim2.new(0, 140, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- Close Button with Original Visual + Confirmation
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -25, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.TextPrimary
    CloseBtn.Font = Theme.FontBold
    CloseBtn.TextSize = 12
    CloseBtn.Parent = MainFrame
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

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
        local MenuStroke = Instance.new("UIStroke", Menu)
        MenuStroke.Color = Theme.Accent
        MenuStroke.Thickness = 1.5

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
        Confirm.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
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
        Cancel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Cancel.Text = "Cancel"
        Cancel.TextColor3 = Color3.new(1, 1, 1)
        Cancel.Font = Theme.FontBold
        Cancel.TextSize = 13
        Cancel.ZIndex = 102
        Cancel.Parent = Menu
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)

        TweenMgr.Create(Overlay, {BackgroundTransparency = 0.5})
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
    local ActiveTab = nil

    function Tabs:CreateTab(name)
        local tab = {}
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.fromScale(1, 1)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.Parent = ContentArea
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 8)

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.88, 0, 0, 28)
        TabBtn.BackgroundColor3 = Theme.Section
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.TextColor3 = Theme.TextSecondary
        TabBtn.Font = Theme.Font
        TabBtn.TextSize = 12
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        TabBtn.MouseButton1Click:Connect(function()
            if ActiveTab then
                ActiveTab.Button.TextColor3 = Theme.TextSecondary
                ActiveTab.Button.BackgroundTransparency = 1
                ActiveTab.Page.Visible = false
            end
            ActiveTab = {Button = TabBtn, Page = Page}
            TabBtn.TextColor3 = Theme.Accent
            TabBtn.BackgroundTransparency = 0.8
            Page.Visible = true
        end)

        if not ActiveTab then
            ActiveTab = {Button = TabBtn, Page = Page}
            TabBtn.TextColor3 = Theme.Accent
            TabBtn.BackgroundTransparency = 0.8
            Page.Visible = true
        end

        local Elements = {}

        function Elements:CreateSection(text)
            local sf = Instance.new("Frame")
            sf.Size = UDim2.new(0.95, 0, 0, 28)
            sf.BackgroundTransparency = 1
            sf.Parent = Page
            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, 0, 1, 0)
            lb.BackgroundTransparency = 1
            lb.Text = text:upper()
            lb.TextColor3 = Theme.Accent
            lb.Font = Theme.FontBold
            lb.TextSize = 12
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = sf
            local ln = Instance.new("Frame")
            ln.Size = UDim2.new(1, -lb.TextBounds.X - 10, 0, 1)
            ln.Position = UDim2.new(0, lb.TextBounds.X + 10, 0.5, 0)
            ln.BackgroundColor3 = Theme.Stroke
            ln.BorderSizePixel = 0
            ln.Parent = sf
        end

        function Elements:CreateButton(text, callback)
            local bf = Instance.new("Frame")
            bf.Size = UDim2.new(0.9, 0, 0, 32)
            bf.BackgroundColor3 = Theme.Section
            bf.Parent = Page
            Instance.new("UICorner", bf).CornerRadius = Theme.CornerRadius
            local us = Instance.new("UIStroke", bf)
            us.Color = Theme.Stroke
            us.Thickness = 1
            local tb = Instance.new("TextButton")
            tb.Size = UDim2.new(1, 0, 1, 0)
            tb.BackgroundTransparency = 1
            tb.Text = text
            tb.TextColor3 = Theme.TextPrimary
            tb.Font = Theme.Font
            tb.TextSize = 14
            tb.Parent = bf
            TweenMgr.Ripple(tb, Theme.Accent)
            tb.MouseButton1Click:Connect(callback)
        end

        function Elements:CreateToggle(text, default, callback)
            local tf = Instance.new("Frame")
            tf.Size = UDim2.new(0.9, 0, 0, 32)
            tf.BackgroundColor3 = Theme.Section
            tf.Parent = Page
            Instance.new("UICorner", tf).CornerRadius = Theme.CornerRadius
            Instance.new("UIStroke", tf).Color = Theme.Stroke
            
            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, -60, 1, 0)
            lb.Position = UDim2.new(0, 15, 0, 0)
            lb.BackgroundTransparency = 1
            lb.Text = text
            lb.TextColor3 = Theme.TextPrimary
            lb.Font = Theme.Font
            lb.TextSize = 14
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = tf

            local sbg = Instance.new("Frame")
            sbg.Size = UDim2.new(0, 38, 0, 18)
            sbg.Position = UDim2.new(1, -53, 0.5, -9)
            sbg.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50, 50, 50)
            sbg.Parent = tf
            Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)

            local sc = Instance.new("Frame")
            sc.Size = UDim2.new(0, 14, 0, 14)
            sc.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            sc.BackgroundColor3 = Color3.new(1, 1, 1)
            sc.Parent = sbg
            Instance.new("UICorner", sc).CornerRadius = UDim.new(1, 0)

            local cb = Instance.new("TextButton")
            cb.Size = UDim2.fromScale(1, 1)
            cb.BackgroundTransparency = 1
            cb.Text = ""
            cb.Parent = tf

            local state = default
            cb.MouseButton1Click:Connect(function()
                state = not state
                TweenMgr.Create(sc, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                TweenMgr.Create(sbg, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 50)})
                callback(state)
            end)
        end

        function Elements:CreateSlider(text, min, max, default, callback)
            local sf = Instance.new("Frame")
            sf.Size = UDim2.new(0.9, 0, 0, 42)
            sf.BackgroundColor3 = Theme.Section
            sf.Parent = Page
            Instance.new("UICorner", sf).CornerRadius = Theme.CornerRadius
            Instance.new("UIStroke", sf).Color = Theme.Stroke

            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, -30, 0, 18)
            lb.Position = UDim2.new(0, 15, 0, 5)
            lb.BackgroundTransparency = 1
            lb.Text = text
            lb.TextColor3 = Theme.TextPrimary
            lb.Font = Theme.Font
            lb.TextSize = 13
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = sf

            local vl = Instance.new("TextLabel")
            vl.Size = UDim2.new(0, 45, 0, 18)
            vl.Position = UDim2.new(1, -60, 0, 5)
            vl.BackgroundTransparency = 1
            vl.Text = tostring(default)
            vl.TextColor3 = Theme.Accent
            vl.Font = Theme.Font
            vl.TextSize = 13
            vl.TextXAlignment = Enum.TextXAlignment.Right
            vl.Parent = sf

            local bg = Instance.new("TextButton")
            bg.Size = UDim2.new(1, -30, 0, 6)
            bg.Position = UDim2.new(0, 15, 0, 32)
            bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            bg.Text = ""
            bg.AutoButtonColor = false
            bg.Parent = sf
            Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

            local fl = Instance.new("Frame")
            fl.Size = UDim2.fromScale((default - min) / (max - min), 1)
            fl.BackgroundColor3 = Theme.Accent
            fl.Parent = bg
            Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)

            local function update(input)
                local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                fl.Size = UDim2.fromScale(pos, 1)
                vl.Text = tostring(val)
                callback(val)
            end

            local dragging = false
            bg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
        end

        function Elements:CreateColorPicker(text, default, callback)
            local cf = Instance.new("Frame")
            cf.Size = UDim2.new(0.9, 0, 0, 32)
            cf.BackgroundColor3 = Theme.Section
            cf.Parent = Page
            Instance.new("UICorner", cf).CornerRadius = Theme.CornerRadius
            Instance.new("UIStroke", cf).Color = Theme.Stroke

            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(1, -60, 1, 0)
            lb.Position = UDim2.new(0, 15, 0, 0)
            lb.BackgroundTransparency = 1
            lb.Text = text
            lb.TextColor3 = Theme.TextPrimary
            lb.Font = Theme.Font
            lb.TextSize = 14
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = cf

            local cp = Instance.new("TextButton")
            cp.Size = UDim2.new(0, 24, 0, 24)
            cp.Position = UDim2.new(1, -35, 0.5, -12)
            cp.BackgroundColor3 = default
            cp.Text = ""
            cp.Parent = cf
            Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 4)

            local colors = {Color3.new(1,1,1), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(0,1,1)}
            local i = 1
            cp.MouseButton1Click:Connect(function()
                i = i + 1 if i > #colors then i = 1 end
                cp.BackgroundColor3 = colors[i]
                callback(colors[i])
            end)
        end

        function Elements:CreateLabel(text)
            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.new(0.9, 0, 0, 20)
            lb.BackgroundTransparency = 1
            lb.Text = text
            lb.TextColor3 = Theme.TextSecondary
            lb.Font = Theme.Font
            lb.TextSize = 13
            lb.TextXAlignment = Enum.TextXAlignment.Left
            lb.Parent = Page
            Instance.new("UIPadding", lb).PaddingLeft = UDim.new(0, 15)
        end

        return Elements
    end

    return Tabs
end

return Library
