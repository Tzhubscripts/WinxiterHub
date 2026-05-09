local WinxLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function ShowLoading()
    local LoadingGui = Instance.new("ScreenGui")
    local LoadingMain = Instance.new("Frame")
    local LoadingCorner = Instance.new("UICorner")
    local LoadingTitle = Instance.new("TextLabel")
    local LoadingSub = Instance.new("TextLabel")
    local BarBack = Instance.new("Frame")
    local BarFill = Instance.new("Frame")
    local BarCorner = Instance.new("UICorner")
    local FillCorner = Instance.new("UICorner")
    local ParticleContainer = Instance.new("Frame")

    LoadingGui.Name = "WinxLoading"
    LoadingGui.Parent = CoreGui
    
    LoadingMain.Name = "LoadingMain"
    LoadingMain.Parent = LoadingGui
    LoadingMain.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    LoadingMain.Position = UDim2.new(0.5, -150, 0.5, -75)
    LoadingMain.Size = UDim2.new(0, 300, 0, 150)
    LoadingMain.ClipsDescendants = true
    LoadingCorner.CornerRadius = UDim.new(0, 15)
    LoadingCorner.Parent = LoadingMain

    ParticleContainer.Name = "ParticleContainer"
    ParticleContainer.Parent = LoadingMain
    ParticleContainer.BackgroundTransparency = 1
    ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
    ParticleContainer.ZIndex = 1

    local particles = {}
    local numParticles = 15
    for i = 1, numParticles do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, 3, 0, 3)
        p.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        p.BackgroundTransparency = 0.5
        p.BorderSizePixel = 0
        p.Parent = ParticleContainer
        p.ZIndex = 2
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = p
        particles[i] = {obj = p, vel = Vector2.new(math.random(-50, 50)/100, math.random(-50, 50)/100), pos = Vector2.new(math.random(0, 300), math.random(0, 150))}
    end

    local lines = {}
    local connection = RunService.RenderStepped:Connect(function()
        for _, line in pairs(lines) do line:Destroy() end
        lines = {}
        for i, p in pairs(particles) do
            p.pos = p.pos + p.vel
            if p.pos.X < 0 or p.pos.X > 300 then p.vel = Vector2.new(-p.vel.X, p.vel.Y) end
            if p.pos.Y < 0 or p.pos.Y > 150 then p.vel = Vector2.new(p.vel.X, -p.vel.Y) end
            p.obj.Position = UDim2.new(0, p.pos.X, 0, p.pos.Y)
            for j = i + 1, numParticles do
                local p2 = particles[j]
                local dist = (p.pos - p2.pos).Magnitude
                if dist < 60 then
                    local line = Instance.new("Frame")
                    line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    line.BackgroundTransparency = 1 - (1 - dist/60)
                    line.BorderSizePixel = 0
                    line.Size = UDim2.new(0, dist, 0, 1)
                    line.Position = UDim2.new(0, (p.pos.X + p2.pos.X)/2, 0, (p.pos.Y + p2.pos.Y)/2)
                    line.Rotation = math.deg(math.atan2(p2.pos.Y - p.pos.Y, p2.pos.X - p.pos.X))
                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                    line.Parent = ParticleContainer
                    line.ZIndex = 1
                    table.insert(lines, line)
                end
            end
        end
    end)

    LoadingTitle.Parent = LoadingMain
    LoadingTitle.BackgroundTransparency = 1
    LoadingTitle.Position = UDim2.new(0, 0, 0, 30)
    LoadingTitle.Size = UDim2.new(1, 0, 0, 30)
    LoadingTitle.Font = Enum.Font.GothamBold
    LoadingTitle.Text = "WINX HUB LOADING..."
    LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingTitle.TextSize = 20
    LoadingTitle.ZIndex = 3

    LoadingSub.Parent = LoadingMain
    LoadingSub.BackgroundTransparency = 1
    LoadingSub.Position = UDim2.new(0, 0, 0, 55)
    LoadingSub.Size = UDim2.new(1, 0, 0, 20)
    LoadingSub.Font = Enum.Font.Gotham
    LoadingSub.Text = "Desenvolvido por: winxtz"
    LoadingSub.TextColor3 = Color3.fromRGB(255, 0, 0)
    LoadingSub.TextSize = 12
    LoadingSub.ZIndex = 3

    BarBack.Parent = LoadingMain
    BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BarBack.Position = UDim2.new(0.1, 0, 0.7, 0)
    BarBack.Size = UDim2.new(0.8, 0, 0, 10)
    BarBack.ZIndex = 3
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 5)
    BarCorner.Parent = BarBack

    BarFill.Parent = BarBack
    BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.ZIndex = 4
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = BarFill

    local tween = TweenService:Create(BarFill, TweenInfo.new(4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    tween:Play()
    tween.Completed:Wait()
    
    task.wait(0.5)
    connection:Disconnect()
    LoadingGui:Destroy()
end

function WinxLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainGlow = Instance.new("UIStroke")
    local TopBar = Instance.new("Frame")
    local TopBarCorner = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local CloseBtn = Instance.new("TextButton")
    local MinimizeBtn = Instance.new("TextButton")
    local Content = Instance.new("Frame")
    local TabHolder = Instance.new("ScrollingFrame")
    local TabLayout = Instance.new("UIListLayout")
    local ContainerHolder = Instance.new("Frame")
    local ToggleBtn = Instance.new("TextButton")
    local ToggleCorner = Instance.new("UICorner")
    local ToggleStroke = Instance.new("UIStroke")

    ScreenGui.Name = "WinxXiterGuiV11_Ultimate"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ToggleBtn.Name = "ToggleButton"
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
    ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = ""
    ToggleBtn.Active = true
    ToggleBtn.Draggable = true
    ToggleBtn.ClipsDescendants = true
    ToggleCorner.CornerRadius = UDim.new(0, 15)
    ToggleCorner.Parent = ToggleBtn
    ToggleStroke.Color = Color3.fromRGB(255, 0, 0)
    ToggleStroke.Thickness = 2.5
    ToggleStroke.Parent = ToggleBtn

    local IconParticleContainer = Instance.new("Frame", ToggleBtn)
    IconParticleContainer.BackgroundTransparency = 1
    IconParticleContainer.Size = UDim2.new(1, 0, 1, 0)
    
    local iconParticles = {}
    for i = 1, 8 do
        local p = Instance.new("Frame", IconParticleContainer)
        p.Size = UDim2.new(0, 2, 0, 2)
        p.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        p.BackgroundTransparency = 0.4
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        iconParticles[i] = {vel = Vector2.new(math.random(-40, 40)/100, math.random(-40, 40)/100), pos = Vector2.new(math.random(0, 60), math.random(0, 60)), obj = p}
    end

    local iconLines = {}
    RunService.RenderStepped:Connect(function()
        if not ToggleBtn.Parent then return end
        for _, line in pairs(iconLines) do line:Destroy() end
        iconLines = {}
        for i, p in pairs(iconParticles) do
            p.pos = p.pos + p.vel
            if p.pos.X < 0 or p.pos.X > 60 then p.vel = Vector2.new(-p.vel.X, p.vel.Y) end
            if p.pos.Y < 0 or p.pos.Y > 60 then p.vel = Vector2.new(p.vel.X, -p.vel.Y) end
            p.obj.Position = UDim2.new(0, p.pos.X, 0, p.pos.Y)
            for j = i + 1, #iconParticles do
                local p2 = iconParticles[j]
                local dist = (p.pos - p2.pos).Magnitude
                if dist < 25 then
                    local line = Instance.new("Frame", IconParticleContainer)
                    line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    line.BackgroundTransparency = 1 - (1 - dist/25)
                    line.Size = UDim2.new(0, dist, 0, 1)
                    line.Position = UDim2.new(0, (p.pos.X + p2.pos.X)/2, 0, (p.pos.Y + p2.pos.Y)/2)
                    line.Rotation = math.deg(math.atan2(p2.pos.Y - p.pos.Y, p2.pos.X - p.pos.X))
                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                    table.insert(iconLines, line)
                end
            end
        end
    end)

    local IconText = Instance.new("TextLabel", ToggleBtn)
    IconText.Size = UDim2.new(1, 0, 1, 0)
    IconText.BackgroundTransparency = 1
    IconText.Font = Enum.Font.GothamBold
    IconText.Text = "WINX"
    IconText.TextColor3 = Color3.fromRGB(255, 0, 0)
    IconText.TextSize = 16
    IconText.ZIndex = 5

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.ClipsDescendants = true
    Main.Visible = true
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = Main
    MainGlow.Color = Color3.fromRGB(255, 0, 0)
    MainGlow.Thickness = 1.5
    MainGlow.Transparency = 0.5
    MainGlow.Parent = Main

    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBarCorner.CornerRadius = UDim.new(0, 15)
    TopBarCorner.Parent = TopBar

    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title or "Winx Hub | V1"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14.000
    Title.TextXAlignment = Enum.TextXAlignment.Left

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Size = UDim2.new(0, 35, 1, 0)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    CloseBtn.TextSize = 14.000

    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TopBar
    MinimizeBtn.BackgroundTransparency = 1.000
    MinimizeBtn.Position = UDim2.new(1, -70, 0, 0)
    MinimizeBtn.Size = UDim2.new(0, 35, 1, 0)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 14.000

    Content.Name = "Content"
    Content.Parent = Main
    Content.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Content.Position = UDim2.new(0, 130, 0, 35)
    Content.Size = UDim2.new(1, -130, 1, -35)

    TabHolder.Name = "TabHolder"
    TabHolder.Parent = Main
    TabHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TabHolder.Position = UDim2.new(0, 0, 0, 35)
    TabHolder.Size = UDim2.new(0, 130, 1, -35)
    TabHolder.ScrollBarThickness = 0
    TabLayout.Parent = TabHolder
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)

    ContainerHolder.Name = "ContainerHolder"
    ContainerHolder.Parent = Content
    ContainerHolder.BackgroundTransparency = 1
    ContainerHolder.Size = UDim2.new(1, 0, 1, 0)

    ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local tabs = {}
    function tabs:CreateTab(name, order)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Name = name.."Tab"
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.TextSize = 12
        TabBtn.LayoutOrder = order
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Container = Instance.new("ScrollingFrame", ContainerHolder)
        Container.Name = name.."Container"
        Container.BackgroundTransparency = 1
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.Visible = false
        Container.ScrollBarThickness = 2
        local ContainerLayout = Instance.new("UIListLayout", Container)
        ContainerLayout.Padding = UDim.new(0, 8)
        ContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContainerHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(180, 180, 180) end end
            Container.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        end)

        if order == 1 then Container.Visible = true TabBtn.TextColor3 = Color3.fromRGB(255, 0, 0) end

        local elements = {}
        
        function elements:CreateToggle(text, callback)
            local ToggleFrame = Instance.new("Frame", Container)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            ToggleFrame.Size = UDim2.new(0.95, 0, 0, 40)
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
            
            local Label = Instance.new("TextLabel", ToggleFrame)
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local SwitchBG = Instance.new("Frame", ToggleFrame)
            SwitchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SwitchBG.Position = UDim2.new(1, -45, 0.5, -10)
            SwitchBG.Size = UDim2.new(0, 35, 0, 20)
            Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame", SwitchBG)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Position = UDim2.new(0, 2, 0.5, -8)
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local Btn = Instance.new("TextButton", ToggleFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""

            local state = false
            Btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)}):Play()
                callback(state)
            end)
        end

        function elements:CreateSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Container)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            SliderFrame.Size = UDim2.new(0.95, 0, 0, 50)
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 5)
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Font = Enum.Font.Gotham
            Label.Text = text .. ": " .. default
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Bar = Instance.new("Frame", SliderFrame)
            Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Bar.Position = UDim2.new(0, 12, 0, 30)
            Bar.Size = UDim2.new(1, -24, 0, 8)
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", Bar)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local Btn = Instance.new("TextButton", Bar)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""

            local dragging = false
            local function update()
                local pos = math.clamp((Mouse.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Label.Text = text .. ": " .. val
                callback(val)
            end

            Btn.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function() if dragging then update() end end)
        end

        function elements:CreateDropdown(text, options, callback)
            local DropFrame = Instance.new("Frame", Container)
            DropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            DropFrame.Size = UDim2.new(0.95, 0, 0, 40)
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)
            local Label = Instance.new("TextLabel", DropFrame)
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = text .. ": " .. options[1]
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            local Btn = Instance.new("TextButton", DropFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            local index = 1
            Btn.MouseButton1Click:Connect(function()
                index = index + 1
                if index > #options then index = 1 end
                Label.Text = text .. ": " .. options[index]
                callback(options[index])
            end)
        end

        function elements:CreateButton(text, callback)
            local Button = Instance.new("TextButton", Container)
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Button.Size = UDim2.new(0.95, 0, 0, 35)
            Button.Font = Enum.Font.GothamBold
            Button.Text = text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 12
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
            Button.MouseButton1Click:Connect(callback)
        end

        function elements:CreateLabel(text, center)
            local Label = Instance.new("TextLabel", Container)
            Label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Label.Size = UDim2.new(0.95, 0, 0, 30)
            Label.Font = Enum.Font.GothamBold
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 14
            Label.TextXAlignment = center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
            Instance.new("UICorner", Label).CornerRadius = UDim.new(0, 8)
            return Label
        end

        return elements
    end
    return tabs
end

return WinxLib
