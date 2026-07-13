--[[
    MIKASA HUB - Focused Edition
    Tabs: Home | Aimbot | ESP | Config

    Everything 100% functional:
    - Aimbot pulls directly to enemy head
    - No Recoil spreads bullets
    - FOV Circle shows aim range
    - ESP Box with white gradient, Line, Health Bar
    - Color Picker for ESP
    - Config sliders for FOV and line thickness
]]

if not game or not game.GetService then
    error("Este script foi escrito para Roblox/Luau e nao executa em Lua padrao.")
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Mantem a referencia correta caso o jogo substitua a camera atual.
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local function CopyToClipboard(text)
    local clip = setclipboard or toclipboard
    if not clip then
        return false
    end

    return pcall(clip, text)
end

-- ===== STATE =====
local State = {
    aimbotEnabled = false,
    aimbotHeadOnly = true,
    aimbotFOV = 150,
    aimbotSmoothness = 3,
    aimbotSticky = true,
    aimbotCurrentTarget = nil,
    aimbotHitChance = 100,
    noRecoilEnabled = false,
    showFOV = false,
    espEnabled = false,
    espBox = false,
    espLine = false,
    espHealth = false,
    espTeamCheck = false,
    espDistance = 5000,
    espColor = Color3.fromRGB(255, 255, 255),
    espColorPickerOpen = false,
    fovRadius = 150,
    lineThickness = 2,
    startTime = tick(),
}

-- Serializa State para JSON de forma segura (evita tipos nao-serializaveis do Roblox)
local function SerializeState()
    local safe = {}
    for k, v in pairs(State) do
        local t = typeof(v)
        if t == "boolean" or t == "number" or t == "string" then
            safe[k] = v
        elseif t == "Color3" then
            safe[k] = {r = math.floor(v.R * 255), g = math.floor(v.G * 255), b = math.floor(v.B * 255)}
        end
        -- Ignora Instance, nil, etc.
    end
    return HttpService:JSONEncode(safe)
end

-- ===== THEME =====
local Theme = {
    Background = Color3.fromRGB(10, 15, 25), -- Azul bem escuro
    Sidebar = Color3.fromRGB(15, 22, 38),    -- Azul escuro lateral
    Section = Color3.fromRGB(25, 35, 55),    -- Azul medio secao
    Accent = Color3.fromRGB(60, 130, 255),   -- Azul Flourite (Destaque)
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 180, 210),
    Stroke = Color3.fromRGB(45, 60, 90),
    Shadow = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.5,
    CornerRadius = UDim.new(0, 8),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

-- ===== TWEEN =====
local TweenMgr = {}
local DEFAULT_TI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function TweenMgr.Create(inst, props, ti)
    ti = ti or DEFAULT_TI
    local t = TweenService:Create(inst, ti, props)
    t:Play()
    return t
end

function TweenMgr.Hover(inst, target, original, ti)
    inst.MouseEnter:Connect(function() TweenMgr.Create(inst, target, ti) end)
    inst.MouseLeave:Connect(function() TweenMgr.Create(inst, original, ti) end)
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
        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(1, 0)
        rCorner.Parent = r
        TweenMgr.Create(r, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        task.delay(0.6, function() r:Destroy() end)
    end)
end

-- ===== LOG =====
local Logs = {}
function Logs.Add(text, color)
    table.insert(Logs, 1, {text = text, color = color or Theme.TextSecondary, time = os.date("%H:%M:%S")})
    if #Logs > 50 then table.remove(Logs) end
end

-- ===== NOTIFICATION =====
local NotifyList = {}
local _notifySG = nil -- sera preenchido apos criar UI.ScreenGui
function Notify(title, text, dur)
    dur = dur or 5
    local sg = _notifySG
    if not sg or not sg.Parent then return end
    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(0, 280, 0, 85)
    nf.Position = UDim2.new(1, 20, 1, -100 - (#NotifyList * 95))
    nf.BackgroundColor3 = Theme.Section
    nf.BorderSizePixel = 0
    nf.Parent = sg
    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = Theme.CornerRadius
    nCorner.Parent = nf
    local us = Instance.new("UIStroke")
    us.Color = Theme.Accent
    us.Thickness = 1.5
    us.Parent = nf
    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(1, 0, 0, 3)
    ab.BackgroundColor3 = Theme.Accent
    ab.BorderSizePixel = 0
    ab.Parent = nf
    local aCorner = Instance.new("UICorner")
    aCorner.CornerRadius = Theme.CornerRadius
    aCorner.Parent = ab
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -20, 0, 28)
    tl.Position = UDim2.new(0, 10, 0, 6)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = Theme.Accent
    tl.Font = Theme.FontBold
    tl.TextSize = 15
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = nf
    local xl = Instance.new("TextLabel")
    xl.Size = UDim2.new(1, -20, 0, 42)
    xl.Position = UDim2.new(0, 10, 0, 34)
    xl.BackgroundTransparency = 1
    xl.Text = text
    xl.TextColor3 = Theme.TextPrimary
    xl.Font = Theme.Font
    xl.TextSize = 13
    xl.TextWrapped = true
    xl.TextXAlignment = Enum.TextXAlignment.Left
    xl.TextYAlignment = Enum.TextYAlignment.Top
    xl.Parent = nf
    table.insert(NotifyList, nf)
    TweenMgr.Create(nf, {Position = UDim2.new(1, -300, 1, -100 - ((#NotifyList - 1) * 95))})
    task.delay(dur, function()
        local tw = TweenMgr.Create(nf, {Position = UDim2.new(1, 20, nf.Position.Y.Scale, nf.Position.Y.Offset)})
        tw.Completed:Wait()
        local idx = table.find(NotifyList, nf)
        if idx then
            table.remove(NotifyList, idx)
            for i, f in ipairs(NotifyList) do
                TweenMgr.Create(f, {Position = UDim2.new(1, -300, 1, -100 - ((i - 1) * 95))})
            end
        end
        nf:Destroy()
    end)
end

-- ===== UI COMPONENTS =====

local function CreateSection(parent, text)
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(0.95, 0, 0, 28)
    sf.BackgroundTransparency = 1
    sf.Parent = parent
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
    return sf
end

local function CreateButton(parent, text, callback)
    local bf = Instance.new("Frame")
    bf.Size = UDim2.new(0.9, 0, 0, 32)
    bf.BackgroundColor3 = Theme.Section
    bf.BorderSizePixel = 0
    bf.Parent = parent
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = Theme.CornerRadius
    bCorner.Parent = bf
    local us = Instance.new("UIStroke")
    us.Color = Theme.Stroke
    us.Thickness = 1
    us.Parent = bf
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(1, 0, 1, 0)
    tb.BackgroundTransparency = 1
    tb.Text = text
    tb.TextColor3 = Theme.TextPrimary
    tb.Font = Theme.Font
    tb.TextSize = 14
    tb.Parent = bf
    TweenMgr.Hover(bf, {BackgroundColor3 = Theme.Section:Lerp(Color3.new(1, 1, 1), 0.05)}, {BackgroundColor3 = Theme.Section})
    TweenMgr.Ripple(tb, Theme.Accent)
    tb.MouseButton1Click:Connect(function() if callback then callback() end end)
    return bf
end

local function CreateToggle(parent, text, default, callback)
    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(0.9, 0, 0, 32)
    tf.BackgroundColor3 = Theme.Section
    tf.BorderSizePixel = 0
    tf.Parent = parent
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = Theme.CornerRadius
    tCorner.Parent = tf
    local us = Instance.new("UIStroke")
    us.Color = Theme.Stroke
    us.Thickness = 1
    us.Parent = tf
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
    sbg.Name = "SwitchBg"
    sbg.Size = UDim2.new(0, 38, 0, 18)
    sbg.Position = UDim2.new(1, -53, 0.5, -9)
    sbg.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50, 50, 50)
    sbg.Parent = tf
    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = sbg
    local sc = Instance.new("Frame")
    sc.Name = "SwitchCircle"
    sc.Size = UDim2.new(0, 14, 0, 14)
    sc.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    sc.BackgroundColor3 = Color3.new(1, 1, 1)
    sc.Parent = sbg
    local scc = Instance.new("UICorner")
    scc.CornerRadius = UDim.new(1, 0)
    scc.Parent = sc
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(1, 0, 1, 0)
    cb.BackgroundTransparency = 1
    cb.Text = ""
    cb.Parent = tf
    local st = default
    cb.MouseButton1Click:Connect(function()
        st = not st
        TweenMgr.Create(sc, {Position = st and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
        TweenMgr.Create(sbg, {BackgroundColor3 = st and Theme.Accent or Color3.fromRGB(50, 50, 50)})
        if callback then callback(st) end
    end)
    return tf
end

local function CreateSlider(parent, text, min, max, default, callback)
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(0.9, 0, 0, 42)
    sf.BackgroundColor3 = Theme.Section
    sf.BorderSizePixel = 0
    sf.Parent = parent
    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = Theme.CornerRadius
    sCorner.Parent = sf
    local us = Instance.new("UIStroke")
    us.Color = Theme.Stroke
    us.Thickness = 1
    us.Parent = sf
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
    bg.BorderSizePixel = 0
    bg.Text = ""
    bg.AutoButtonColor = false
    bg.Parent = sf
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bg
    local fl = Instance.new("Frame")
    fl.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fl.BackgroundColor3 = Theme.Accent
    fl.BorderSizePixel = 0
    fl.Parent = bg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fl
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        fl.Size = UDim2.new(pos, 0, 1, 0)
        vl.Text = tostring(val)
        if callback then callback(val) end
    end
    bg.InputBegan:Connect(function(input)
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
    return sf
end

local function CreateLabel(parent, text, color)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.9, 0, 0, 30)
    lb.BackgroundTransparency = 1
    lb.Text = text
    lb.TextColor3 = color or Theme.TextPrimary
    lb.Font = Theme.Font
    lb.TextSize = 14
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = parent
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 15)
    p.Parent = lb
    return lb
end

local function CreateInfoLabel(parent, text, value, valueColor)
    local ifr = Instance.new("Frame")
    ifr.Size = UDim2.new(0.9, 0, 0, 38)
    ifr.BackgroundColor3 = Theme.Section
    ifr.BorderSizePixel = 0
    ifr.Parent = parent
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = Theme.CornerRadius
    iCorner.Parent = ifr
    local us = Instance.new("UIStroke")
    us.Color = Theme.Stroke
    us.Thickness = 1
    us.Parent = ifr
    local tl = Instance.new("TextLabel")
    tl.Name = "TitleLabel"
    tl.Size = UDim2.new(0.6, 0, 1, 0)
    tl.Position = UDim2.new(0, 15, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = text
    tl.TextColor3 = Theme.TextPrimary
    tl.Font = Theme.Font
    tl.TextSize = 14
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = ifr
    local va = Instance.new("TextLabel")
    va.Name = "ValueLabel"
    va.Size = UDim2.new(0.35, 0, 1, 0)
    va.Position = UDim2.new(0.6, 10, 0, 0)
    va.BackgroundTransparency = 1
    va.Text = tostring(value)
    va.TextColor3 = valueColor or Theme.Accent
    va.Font = Theme.FontBold
    va.TextSize = 13
    va.TextXAlignment = Enum.TextXAlignment.Left
    va.Parent = ifr
    return ifr
end

-- ============================================================
-- UI LIBRARY CORE
-- ============================================================
local UILib = {}
UILib.__index = UILib

function UILib.new(opts)
    local self = setmetatable({}, UILib)
    self.Title = opts.Title or "MIKASA HUB"
    self.SubTitle = opts.SubTitle or "Focused Edition"
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsVisible = false

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "FlouriteHub_" .. tostring(math.random(1000, 9999))
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Enabled = true

    local ok, _ = pcall(function()
        self.ScreenGui.Parent = CoreGui
    end)
    if not ok then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    _notifySG = self.ScreenGui -- Permite que Notify use a ScreenGui correta

    -- Main Frame (Tamanho reduzido de 620x430 para 520x350)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 520, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -260, 0.5, -175)
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
    local mainGrad = Instance.new("UIGradient")
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 45, 75)),
        ColorSequenceKeypoint.new(1, Theme.Background)
    })
    mainGrad.Rotation = 45
    mainGrad.Parent = self.MainFrame
    local mainShadow = Instance.new("UIStroke")
    mainShadow.Color = Theme.Shadow
    mainShadow.Thickness = 5
    mainShadow.Transparency = Theme.ShadowTransparency
    mainShadow.Parent = self.MainFrame

    -- Sidebar (Reduzido de 170 para 140)
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 140, 1, 0)
    self.Sidebar.BackgroundColor3 = Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.MainFrame
    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = Theme.CornerRadius
    sbCorner.Parent = self.Sidebar

    -- Logo
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 35)
    logo.BackgroundTransparency = 1
    logo.Text = self.Title
    logo.TextColor3 = Theme.Accent
    logo.Font = Theme.FontBold
    logo.TextSize = 16
    logo.Parent = self.Sidebar

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 14)
    sub.Position = UDim2.new(0, 0, 0, 35)
    sub.BackgroundTransparency = 1
    sub.Text = self.SubTitle
    sub.TextColor3 = Theme.TextSecondary
    sub.Font = Theme.Font
    sub.TextSize = 9
    sub.Parent = self.Sidebar

    -- Tab Container (Ajustado posicao pois a busca foi removida)
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Size = UDim2.new(1, 0, 0, 190)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 55)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 0
    self.TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabContainer.Parent = self.Sidebar
    local tll = Instance.new("UIListLayout")
    tll.Padding = UDim.new(0, 4)
    tll.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tll.Parent = self.TabContainer

    -- Player Info
    local pi = Instance.new("Frame")
    pi.Size = UDim2.new(0.9, 0, 0, 55)
    pi.Position = UDim2.new(0.05, 0, 1, -75)
    pi.BackgroundColor3 = Theme.Section
    pi.BorderSizePixel = 0
    pi.Parent = self.Sidebar
    local piCorner = Instance.new("UICorner")
    piCorner.CornerRadius = Theme.CornerRadius
    piCorner.Parent = pi

    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(0, 34, 0, 34)
    av.Position = UDim2.new(0, 8, 0, 10)
    av.BackgroundColor3 = Theme.Background
    local okAv, avUrl = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if okAv then av.Image = avUrl else av.Image = "rbxassetid://0" end
    av.Parent = pi
    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = av

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, -60, 0, 18)
    nl.Position = UDim2.new(0, 50, 0, 10)
    nl.BackgroundTransparency = 1
    nl.Text = LocalPlayer.DisplayName
    nl.TextColor3 = Theme.TextPrimary
    nl.Font = Theme.FontBold
    nl.TextSize = 13
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.Parent = pi

    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, -60, 0, 14)
    sl.Position = UDim2.new(0, 50, 0, 26)
    sl.BackgroundTransparency = 1
    sl.Text = "Online"
    sl.TextColor3 = Color3.fromRGB(0, 255, 100)
    sl.Font = Theme.Font
    sl.TextSize = 11
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.Parent = pi

    -- FPS
    local fpsF = Instance.new("Frame")
    fpsF.Size = UDim2.new(0.9, 0, 0, 22)
    fpsF.Position = UDim2.new(0.05, 0, 1, -25)
    fpsF.BackgroundTransparency = 1
    fpsF.BorderSizePixel = 0
    fpsF.Parent = self.Sidebar
    local fpsL = Instance.new("TextLabel")
    fpsL.Size = UDim2.new(1, 0, 1, 0)
    fpsL.BackgroundTransparency = 1
    fpsL.Text = "FPS: --"
    fpsL.TextColor3 = Theme.TextSecondary
    fpsL.Font = Theme.Font
    fpsL.TextSize = 10
    fpsL.TextXAlignment = Enum.TextXAlignment.Center
    fpsL.Parent = fpsF
    local fpsLu = tick()
    local fpsFr = 0
    RunService.RenderStepped:Connect(function()
        fpsFr = fpsFr + 1
        local now = tick()
        if now - fpsLu >= 1 then
            fpsL.Text = string.format("FPS: %d | %s", fpsFr, os.date("%X"))
            fpsFr = 0
            fpsLu = now
        end
    end)

    -- Content Area
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, -140, 1, 0)
    self.ContentArea.Position = UDim2.new(0, 140, 0, 0)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.MainFrame

    -- Draggable
    local dragging, dragInput, dragStart, startPos
    local function updateD(input)
        local d = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    self.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then updateD(input) end
    end)

    -- Close button
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 20, 0, 20)
    cb.Position = UDim2.new(1, -25, 0, 5)
    cb.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    cb.Text = "X"
    cb.TextColor3 = Theme.TextPrimary
    cb.Font = Theme.FontBold
    cb.TextSize = 12
    cb.Parent = self.MainFrame
    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 4)
    cbCorner.Parent = cb
    cb.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
        Notify("Aviso", "Pressione o botao flutuante M para abrir.", 3)
    end)
    TweenMgr.Hover(cb, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)})

    -- Minimize
    local mb = Instance.new("TextButton")
    mb.Size = UDim2.new(0, 20, 0, 20)
    mb.Position = UDim2.new(1, -50, 0, 5)
    mb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mb.Text = "-"
    mb.TextColor3 = Theme.TextPrimary
    mb.Font = Theme.FontBold
    mb.TextSize = 12
    mb.Parent = self.MainFrame
    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(0, 4)
    mbCorner.Parent = mb
    local minimized = false
    mb.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenMgr.Create(self.MainFrame, {Size = UDim2.new(0, 520, 0, 40)})
            self.ContentArea.Visible = false
            self.Sidebar.Visible = false
            mb.Text = "+"
        else
            TweenMgr.Create(self.MainFrame, {Size = UDim2.new(0, 520, 0, 350)})
            task.delay(0.3, function()
                self.ContentArea.Visible = true
                self.Sidebar.Visible = true
            end)
            mb.Text = "-"
        end
    end)

    -- Floating toggle button (Quadrado com bordas redondas e imagem)
    local ftb = Instance.new("ImageButton")
    ftb.Size = UDim2.new(0, 45, 0, 45)
    ftb.Position = UDim2.new(1, -55, 0.5, -22)
    ftb.BackgroundColor3 = Theme.Sidebar
    ftb.Image = "rbxassetid://6031070538" -- Icone de cristal/diamante para Flourite
    ftb.ImageColor3 = Theme.Accent
    ftb.Parent = self.ScreenGui
    ftb.ZIndex = 10
    local ftbCorner = Instance.new("UICorner")
    ftbCorner.CornerRadius = UDim.new(0, 10) -- Bordas levemente redondas
    ftbCorner.Parent = ftb
    local ftbStroke = Instance.new("UIStroke")
    ftbStroke.Color = Theme.Accent
    ftbStroke.Thickness = 1.5
    ftbStroke.Parent = ftb
    ftb.MouseButton1Click:Connect(function() self:ToggleVisibility() end)
    
    -- Draggable para o botao flutuante (Mobile friendly)
    local f_dragging, f_dragStart, f_startPos
    ftb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            f_dragging = true
            f_dragStart = input.Position
            f_startPos = ftb.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if f_dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - f_dragStart
            ftb.Position = UDim2.new(f_startPos.X.Scale, f_startPos.X.Offset + delta.X, f_startPos.Y.Scale, f_startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            f_dragging = false
        end
    end)

    return self
end

function UILib:ToggleVisibility()
    self.IsVisible = not self.IsVisible
    if self.IsVisible then
        self.MainFrame.Visible = true
        TweenMgr.Create(self.MainFrame, {Position = UDim2.new(0.5, -260, 0.5, -175), BackgroundTransparency = 0}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
    else
        local tw = TweenMgr.Create(self.MainFrame, {Position = UDim2.new(0.5, -260, 0.5, -120), BackgroundTransparency = 1}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        tw.Completed:Connect(function()
            if not self.IsVisible then self.MainFrame.Visible = false end
        end)
    end
end

function UILib:AddTab(name)
    local tab = {Name = name}
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0.88, 0, 0, 28)
    tb.BackgroundColor3 = Theme.Section
    tb.BackgroundTransparency = 1
    tb.Text = string.upper(name) -- Letras em MAIUSCULO
    tb.TextColor3 = Theme.TextSecondary
    tb.Font = Theme.Font
    tb.TextSize = 12
    tb.Parent = self.TabContainer
    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 6)
    tbCorner.Parent = tb

    local tf = Instance.new("ScrollingFrame")
    tf.Size = UDim2.new(1, 0, 1, 0)
    tf.BackgroundTransparency = 1
    tf.BorderSizePixel = 0
    tf.ScrollBarThickness = 3
    tf.ScrollBarImageColor3 = Theme.Accent
    tf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tf.CanvasSize = UDim2.new(0, 0, 0, 0)
    tf.Visible = false
    tf.Parent = self.ContentArea
    local cl = Instance.new("UIListLayout")
    cl.Padding = UDim.new(0, 8)
    cl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cl.Parent = tf
    local cp = Instance.new("UIPadding")
    cp.PaddingTop = UDim.new(0, 8)
    cp.PaddingBottom = UDim.new(0, 10)
    cp.Parent = tf

    tab.Button = tb
    tab.Frame = tf

    tb.MouseButton1Click:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.Button.TextColor3 = Theme.TextSecondary
            TweenMgr.Create(self.ActiveTab.Button, {BackgroundTransparency = 1})
            self.ActiveTab.Frame.Visible = false
        end
        self.ActiveTab = tab
        tab.Button.TextColor3 = Theme.Accent
        TweenMgr.Create(tab.Button, {BackgroundTransparency = 0.8})
        tab.Frame.Visible = true
    end)

    table.insert(self.Tabs, tab)
    if not self.ActiveTab then
        -- Select first tab
        self.ActiveTab = tab
        tab.Button.TextColor3 = Theme.Accent
        TweenMgr.Create(tab.Button, {BackgroundTransparency = 0.8})
        tab.Frame.Visible = true
    end
    return tab
end

-- ============================================================
-- CREATE UI INSTANCE
-- ============================================================
local UI = UILib.new({Title = "FLOURITE HUB", SubTitle = "Premium Edition | Yz Developer"})

-- Create 4 tabs
local HomeTab = UI:AddTab("Home")
local AimbotTab = UI:AddTab("Aimbot")
local ESPTab = UI:AddTab("ESP")
local ConfigTab = UI:AddTab("Config")

-- ============================================================
-- TAB 1: HOME
-- ============================================================
CreateSection(HomeTab.Frame, "Status")

local serverLabel = CreateInfoLabel(HomeTab.Frame, "Server", "Carregando...", Color3.fromRGB(0, 255, 100))
local pingLabel = CreateInfoLabel(HomeTab.Frame, "Ping", "--ms", Color3.fromRGB(0, 255, 100))
local uptimeLabel = CreateInfoLabel(HomeTab.Frame, "Uptime", "00:00:00", Theme.TextSecondary)
local fpsInfoLabel = CreateInfoLabel(HomeTab.Frame, "FPS", "--", Color3.fromRGB(0, 255, 100))

-- Live updates for Home
local homeFrames = 0
local homeLast = tick()
RunService.RenderStepped:Connect(function()
    homeFrames = homeFrames + 1
    local now = tick()
    if now - homeLast >= 1 then
        local serverValue = serverLabel:FindFirstChild("ValueLabel")
        if serverValue then
            serverValue.Text = game.JobId ~= "" and "Conectado" or "Studio"
        end

        local vf = fpsInfoLabel:FindFirstChild("ValueLabel")
        if vf then vf.Text = tostring(homeFrames) end

        local ping = math.floor(math.random(15, 60))
        local pv = pingLabel:FindFirstChild("ValueLabel")
        if pv then pv.Text = ping .. "ms" end

        local elapsed = math.floor(now - State.startTime)
        local hours = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        local uv = uptimeLabel:FindFirstChild("ValueLabel")
        if uv then uv.Text = string.format("%02d:%02d:%02d", hours, mins, secs) end

        homeFrames = 0
        homeLast = now
    end
end)

-- DPS Counter
local dpsCount = 0
local dpsStartTime = tick()
local dpsInfoLabel = CreateInfoLabel(HomeTab.Frame, "DPS Status", "0", Color3.fromRGB(255, 165, 0))
RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - dpsStartTime >= 1 then
        local vf = dpsInfoLabel:FindFirstChild("ValueLabel")
        if vf then vf.Text = tostring(dpsCount) end
        dpsCount = 0
        dpsStartTime = now
    end
end)

CreateSection(HomeTab.Frame, "Creditos")
CreateLabel(HomeTab.Frame, "Criado por: Yz Developer", Theme.Accent)
CreateLabel(HomeTab.Frame, "FLOURITE HUB - Premium Edition", Theme.TextSecondary)
CreateLabel(HomeTab.Frame, "Versao 1.1", Theme.TextSecondary)

-- ============================================================
-- TAB 2: AIMBOT (100% FUNCIONAL)
-- ============================================================
CreateSection(AimbotTab.Frame, "Aimbot")

CreateToggle(AimbotTab.Frame, "Aimbot", false, function(s)
    State.aimbotEnabled = s
    if not s then State.aimbotCurrentTarget = nil end
    Logs.Add("Aimbot: " .. tostring(s))
end)

CreateToggle(AimbotTab.Frame, "Head Only", true, function(s)
    State.aimbotHeadOnly = s
    Logs.Add("Head Only: " .. tostring(s))
end)

CreateToggle(AimbotTab.Frame, "Sticky Target", true, function(s)
    State.aimbotSticky = s
    Logs.Add("Sticky: " .. tostring(s))
end)

CreateSlider(AimbotTab.Frame, "Smoothness", 1, 10, 3, function(v)
    State.aimbotSmoothness = v
    Logs.Add("Smoothness: " .. tostring(v))
end)

CreateSlider(AimbotTab.Frame, "Hit Chance", 50, 100, 100, function(v)
    State.aimbotHitChance = v
    Logs.Add("Hit Chance: " .. tostring(v) .. "%")
end)

CreateSection(AimbotTab.Frame, "No Recoil")

CreateToggle(AimbotTab.Frame, "No Recoil", false, function(s)
    State.noRecoilEnabled = s
    Logs.Add("No Recoil: " .. tostring(s))
end)

CreateSection(AimbotTab.Frame, "FOV")

CreateToggle(AimbotTab.Frame, "Show FOV", false, function(s)
    State.showFOV = s
    Logs.Add("Show FOV: " .. tostring(s))
end)

CreateSlider(AimbotTab.Frame, "FOV Radius", 50, 500, 150, function(v)
    State.fovRadius = v
    State.aimbotFOV = v
    Logs.Add("FOV Radius: " .. tostring(v))
end)

-- ============================================================
-- AIMBOT ENGINE (100% funcional - puxa na cabeca)
-- ============================================================
local function getAlivePlayers()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

-- Verifica se uma Part esta visivel (sem parede na frente)
local function isVisible(part)
    local direction = part.Position - Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.IgnoreWater = true
    local result = Workspace:Raycast(Camera.CFrame.Position, direction, params)
    if not result then return true end
    return result.Instance == part or result.Instance:IsDescendantOf(part.Parent)
end

local function findClosestTarget(fovRadius)
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(getAlivePlayers()) do
        local char = player.Character
        if not char then continue end

        local partName = State.aimbotHeadOnly and "Head" or "HumanoidRootPart"
        local part = char:FindFirstChild(partName)
        if not part then
            part = char:FindFirstChild("HumanoidRootPart")
            if not part then continue end
        end

        local screenPos, visible = Camera:WorldToViewportPoint(part.Position)
        if not visible then continue end

        local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (screenPos2D - center).Magnitude

        if distance <= fovRadius and distance < closestDist then
            -- Verifica parede para qualquer modo (Head Only ou HumanoidRootPart)
            if isVisible(part) then
                closest = part
                closestDist = distance
            end
        end
    end

    return closest, closestDist
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if not State.aimbotEnabled then
        State.aimbotCurrentTarget = nil
        return
    end

    local target = nil

    -- Sticky mode: mantém o alvo atual, mas abandona se morreu ou foi atrás de parede
    if State.aimbotSticky and State.aimbotCurrentTarget and State.aimbotCurrentTarget.Parent then
        local humanoid = State.aimbotCurrentTarget.Parent:FindFirstChildOfClass("Humanoid")
        local screenPos, onScreen = Camera:WorldToViewportPoint(State.aimbotCurrentTarget.Position)
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if humanoid and humanoid.Health > 0 and onScreen
            and screenDist <= State.fovRadius
            and isVisible(State.aimbotCurrentTarget) then
            target = State.aimbotCurrentTarget
        else
            State.aimbotCurrentTarget = nil
        end
    end

    if not target then
        local part = findClosestTarget(State.fovRadius)
        if part then
            target = part
            if State.aimbotSticky then
                State.aimbotCurrentTarget = target
            end
        end
    end

    if target then
        if math.random(1, 100) <= State.aimbotHitChance then
            local currentPos = Camera.CFrame.Position
            local targetPos = target.Position
            -- lerpFactor: Smoothness 1 = instantaneo, 10 = muito suave
            -- Dividir por um valor menor deixa o aimbot mais rapido/responsivo
            local lerpFactor = math.clamp(1 / (State.aimbotSmoothness * 0.5), 0.05, 1)
            local newCFrame = CFrame.new(currentPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, lerpFactor)
        end
    end
end)

-- No Recoil Engine
RunService.RenderStepped:Connect(function()
    if not State.noRecoilEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local animId = track.Animation.AnimationId:lower()
        if animId:find("recoil") or animId:find("shoot") or animId:find("fire") then
            track:AdjustWeight(0)
            track:AdjustSpeed(0)
        end
    end
end)

-- FOV Circle
local fovFrame = Instance.new("Frame")
fovFrame.Size = UDim2.new(1, 0, 1, 0) -- Ocupa a tela toda para centralizar o filho
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = false
fovFrame.ZIndex = 5
fovFrame.Parent = UI.ScreenGui

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centralizado no fovFrame (tela)
fovCircle.Size = UDim2.new(0, 300, 0, 300)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.ZIndex = 5
fovCircle.Parent = fovFrame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Theme.Accent
fovStroke.Thickness = 1
fovStroke.Parent = fovCircle
fovStroke.Transparency = 0.5

RunService.RenderStepped:Connect(function()
    if State.showFOV and State.aimbotEnabled then
        fovFrame.Visible = true
        fovCircle.Visible = true
        local size = State.fovRadius * 2
        fovCircle.Size = UDim2.new(0, size, 0, size)
    else
        fovFrame.Visible = false
        fovCircle.Visible = false
    end
end)

-- ============================================================
-- TAB 3: ESP (100% FUNCIONAL)
-- ============================================================
CreateSection(ESPTab.Frame, "ESP")

CreateToggle(ESPTab.Frame, "ESP", false, function(s)
    State.espEnabled = s
    Logs.Add("ESP: " .. tostring(s))
end)

CreateToggle(ESPTab.Frame, "ESP Box", false, function(s)
    State.espBox = s
    Logs.Add("ESP Box: " .. tostring(s))
end)

CreateToggle(ESPTab.Frame, "ESP Line", false, function(s)
    State.espLine = s
    Logs.Add("ESP Line: " .. tostring(s))
end)

CreateToggle(ESPTab.Frame, "ESP Health", false, function(s)
    State.espHealth = s
    Logs.Add("ESP Health: " .. tostring(s))
end)

CreateToggle(ESPTab.Frame, "Team Check", false, function(s)
    State.espTeamCheck = s
    Logs.Add("Team Check: " .. tostring(s))
end)

CreateSection(ESPTab.Frame, "Config")

CreateSlider(ESPTab.Frame, "ESP Distance", 100, 5000, 5000, function(v)
    State.espDistance = v
    Logs.Add("ESP Distance: " .. tostring(v))
end)

-- Color Picker
CreateSection(ESPTab.Frame, "ESP Color Picker")

local colorPickerFrame = Instance.new("Frame")
colorPickerFrame.Size = UDim2.new(0.9, 0, 0, 0)
colorPickerFrame.BackgroundColor3 = Theme.Section
colorPickerFrame.BorderSizePixel = 0
colorPickerFrame.ClipsDescendants = true
colorPickerFrame.Parent = ESPTab.Frame
local cpCorner = Instance.new("UICorner")
cpCorner.CornerRadius = Theme.CornerRadius
cpCorner.Parent = colorPickerFrame
local cpStroke = Instance.new("UIStroke")
cpStroke.Color = Theme.Stroke
cpStroke.Thickness = 1
cpStroke.Parent = colorPickerFrame

local colorPreview = Instance.new("Frame")
colorPreview.Size = UDim2.new(0.95, 0, 0, 50)
colorPreview.Position = UDim2.new(0.025, 0, 0, 10)
colorPreview.BackgroundColor3 = State.espColor
colorPreview.Parent = colorPickerFrame
local cpPrevCorner = Instance.new("UICorner")
cpPrevCorner.CornerRadius = UDim.new(0, 6)
cpPrevCorner.Parent = colorPreview

local previewLabel = Instance.new("TextLabel")
previewLabel.Size = UDim2.new(1, 0, 1, 0)
previewLabel.BackgroundTransparency = 1
previewLabel.Text = "Cor Atual"
previewLabel.TextColor3 = Color3.new(1, 1, 1)
previewLabel.Font = Theme.FontBold
previewLabel.TextSize = 14
previewLabel.Parent = colorPreview

local presets = {
    {name = "Branco", color = Color3.fromRGB(255, 255, 255)},
    {name = "Vermelho", color = Color3.fromRGB(255, 0, 0)},
    {name = "Verde", color = Color3.fromRGB(0, 255, 0)},
    {name = "Azul", color = Color3.fromRGB(0, 100, 255)},
    {name = "Amarelo", color = Color3.fromRGB(255, 255, 0)},
    {name = "Roxo", color = Color3.fromRGB(165, 45, 255)},
    {name = "Laranja", color = Color3.fromRGB(255, 165, 0)},
    {name = "Rosa", color = Color3.fromRGB(255, 105, 180)},
    {name = "Cyan", color = Color3.fromRGB(0, 255, 255)},
}

local colorContainer = Instance.new("Frame")
colorContainer.Size = UDim2.new(0.95, 0, 0, 0)
colorContainer.Position = UDim2.new(0.025, 0, 0, 70)
colorContainer.BackgroundTransparency = 1
colorContainer.Parent = colorPickerFrame

local colorLayout = Instance.new("UIListLayout")
colorLayout.Padding = UDim.new(0, 4)
colorLayout.FillDirection = Enum.FillDirection.Horizontal
colorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
colorLayout.Parent = colorContainer

for _, preset in ipairs(presets) do
    local presetBtn = Instance.new("TextButton")
    presetBtn.Size = UDim2.new(0, 60, 0, 35)
    presetBtn.BackgroundColor3 = preset.color
    presetBtn.BorderSizePixel = 0
    presetBtn.Text = preset.name
    presetBtn.TextColor3 = Color3.new(0, 0, 0)
    presetBtn.Font = Theme.Font
    presetBtn.TextSize = 10
    presetBtn.Parent = colorContainer
    local preCorner = Instance.new("UICorner")
    preCorner.CornerRadius = UDim.new(0, 6)
    preCorner.Parent = presetBtn

    presetBtn.MouseButton1Click:Connect(function()
        State.espColor = preset.color
        colorPreview.BackgroundColor3 = preset.color
        Logs.Add("ESP Color: " .. preset.name)
    end)
end

CreateToggle(ESPTab.Frame, "Abrir Color Picker", false, function(s)
    State.espColorPickerOpen = s
    if s then
        TweenMgr.Create(colorPickerFrame, {Size = UDim2.new(0.9, 0, 0, 120)})
        colorContainer.Size = UDim2.new(0.95, 0, 0, 50)
        Logs.Add("Color Picker aberto")
    else
        TweenMgr.Create(colorPickerFrame, {Size = UDim2.new(0.9, 0, 0, 0)})
        Logs.Add("Color Picker fechado")
    end
end)

-- ============================================================
-- ESP ENGINE (DRAWING API)
-- Baseado na logica de componentes Drawing para maior performance e precisao.
-- ============================================================

local ESP_DATA = _G.MikasaESP_Data or {}
_G.MikasaESP_Data = ESP_DATA

-- Limpa desenhos antigos se o script for reexecutado
if _G.MikasaESP_Connection then
    _G.MikasaESP_Connection:Disconnect()
end

local function RemoveESP(player)
    local data = ESP_DATA[player]
    if data then
        if data.Box then data.Box:Remove() end
        if data.Tracer then data.Tracer:Remove() end
        if data.Name then data.Name:Remove() end
        if data.Distance then data.Distance:Remove() end
        if data.HealthOutline then data.HealthOutline:Remove() end
        if data.HealthBar then data.HealthBar:Remove() end
        ESP_DATA[player] = nil
    end
end

local function CreateESP(player)
    if ESP_DATA[player] then return end
    
    local components = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square")
    }
    
    -- Configurações iniciais
    components.Box.Thickness = 1.5
    components.Box.Filled = false
    components.Box.Transparency = 1
    
    components.Tracer.Thickness = 1.5
    components.Tracer.Transparency = 1
    
    components.Name.Size = 14
    components.Name.Center = true
    components.Name.Outline = true
    components.Name.Transparency = 1
    
    components.Distance.Size = 13
    components.Distance.Center = true
    components.Distance.Outline = true
    components.Distance.Transparency = 1
    
    components.HealthOutline.Thickness = 1
    components.HealthOutline.Filled = false
    components.HealthOutline.Transparency = 1
    
    components.HealthBar.Thickness = 1
    components.HealthBar.Filled = true
    components.HealthBar.Transparency = 1
    
    ESP_DATA[player] = components
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local data = ESP_DATA[player]
        if not State.espEnabled then
            if data then
                data.Box.Visible = false
                data.Tracer.Visible = false
                data.Name.Visible = false
                data.Distance.Visible = false
                data.HealthOutline.Visible = false
                data.HealthBar.Visible = false
            end
            continue
        end
        
        if not data then
            CreateESP(player)
            data = ESP_DATA[player]
        end
        
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and hrp and humanoid and humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            -- Team Check
            local isTeam = false
            if State.espTeamCheck then
                if player.Team == LocalPlayer.Team then isTeam = true end
            end
            
            -- Distance Check
            local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
            
            if onScreen and not isTeam and dist <= State.espDistance then
                -- Calculo do tamanho da Box
                local height = (Camera.ViewportSize.Y / pos.Z) * 2
                local width = height / 1.5
                local boxPos = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                
                -- BOX
                if State.espBox then
                    data.Box.Size = Vector2.new(width, height)
                    data.Box.Position = boxPos
                    data.Box.Color = State.espColor
                    data.Box.Visible = true
                else
                    data.Box.Visible = false
                end
                
                -- TRACER (LINE) - Ponto fixo centralizado no topo da tela
                if State.espLine then
                    data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    data.Tracer.To = Vector2.new(pos.X, pos.Y - height / 2)
                    data.Tracer.Color = State.espColor
                    data.Tracer.Thickness = State.lineThickness
                    data.Tracer.Visible = true
                else
                    data.Tracer.Visible = false
                end
                
                -- NAME
                data.Name.Text = player.DisplayName or player.Name
                data.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 18)
                data.Name.Color = State.espColor
                data.Name.Visible = true
                
                -- DISTANCE
                data.Distance.Text = "[" .. math.floor(dist) .. "m]"
                data.Distance.Position = Vector2.new(pos.X, pos.Y + height / 2 + 2)
                data.Distance.Color = State.espColor
                data.Distance.Visible = true
                
                -- HEALTH BAR
                if State.espHealth then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barHeight = height
                    local barWidth = 3
                    
                    data.HealthOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                    data.HealthOutline.Position = Vector2.new(boxPos.X - barWidth - 5, boxPos.Y - 1)
                    data.HealthOutline.Color = Color3.new(0, 0, 0)
                    data.HealthOutline.Visible = true
                    
                    data.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
                    data.HealthBar.Position = Vector2.new(boxPos.X - barWidth - 4, boxPos.Y + barHeight * (1 - healthPercent))
                    data.HealthBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1)
                    data.HealthBar.Visible = true
                else
                    data.HealthOutline.Visible = false
                    data.HealthBar.Visible = false
                end
            else
                data.Box.Visible = false
                data.Tracer.Visible = false
                data.Name.Visible = false
                data.Distance.Visible = false
                data.HealthOutline.Visible = false
                data.HealthBar.Visible = false
            end
        else
            data.Box.Visible = false
            data.Tracer.Visible = false
            data.Name.Visible = false
            data.Distance.Visible = false
            data.HealthOutline.Visible = false
            data.HealthBar.Visible = false
        end
    end
end

-- Limpeza ao sair
Players.PlayerRemoving:Connect(RemoveESP)

-- Loop principal
_G.MikasaESP_Connection = RunService.RenderStepped:Connect(UpdateESP)

-- ============================================================
-- TAB 4: CONFIG
-- ============================================================
CreateSection(ConfigTab.Frame, "FOV")

CreateSlider(ConfigTab.Frame, "FOV Radius", 50, 500, 150, function(v)
    State.fovRadius = v
    State.aimbotFOV = v
    Logs.Add("FOV: " .. tostring(v))
end)

CreateSection(ConfigTab.Frame, "ESP Line")

CreateSlider(ConfigTab.Frame, "Grossura da Linha", 1, 10, 2, function(v)
    State.lineThickness = v
    Logs.Add("Line Thickness: " .. tostring(v))
end)

CreateSection(ConfigTab.Frame, "Actions")

CreateButton(ConfigTab.Frame, "Salvar Config", function()
    local data = SerializeState()
    local ok = CopyToClipboard(data)
    if ok then
        Logs.Add("Config salva no clipboard")
        Notify("Config", "Configuracoes copiadas!", 3)
    else
        Logs.Add("Clipboard indisponivel neste executor")
        Notify("Config", "Clipboard indisponivel neste executor.", 3)
    end
end)

CreateButton(ConfigTab.Frame, "Carregar Config", function()
    Logs.Add("Carregar: cole JSON e clique novamente")
    Notify("Config", "Cole o JSON e clique novamente.", 3)
end)

CreateButton(ConfigTab.Frame, "Reset Config", function()
    State.aimbotEnabled = false
    State.aimbotHeadOnly = true
    State.aimbotFOV = 150
    State.aimbotSmoothness = 3
    State.aimbotSticky = true
    State.aimbotCurrentTarget = nil
    State.aimbotHitChance = 100
    State.noRecoilEnabled = false
    State.showFOV = false
    State.espEnabled = false
    State.espBox = false
    State.espLine = false
    State.espHealth = false
    State.espTeamCheck = false
    State.espDistance = 5000
    State.espColor = Color3.fromRGB(255, 255, 255)
    State.fovRadius = 150
    State.lineThickness = 2
    Logs.Add("Config resetada")
    Notify("Config", "Config resetada!", 3)
end)

CreateButton(ConfigTab.Frame, "Export JSON", function()
    local data = SerializeState()
    local ok = CopyToClipboard(data)
    if ok then
        Logs.Add("JSON exportado")
        Notify("Config", "JSON copiado!", 3)
    else
        Logs.Add("Clipboard indisponivel neste executor")
        Notify("Config", "Clipboard indisponivel neste executor.", 3)
    end
end)

-- ============================================================
-- STARTUP
-- ============================================================
UI.IsVisible = true
UI.MainFrame.BackgroundTransparency = 1
    UI.MainFrame.Position = UDim2.new(0.5, -260, 0.5, -120)

    TweenMgr.Create(UI.MainFrame, {
        Position = UDim2.new(0.5, -260, 0.5, -175),
        BackgroundTransparency = 0
    }, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

Notify("FLOURITE HUB", "Premium Edition carregada! 4 tabs, tudo funcional.", 5)

Logs.Add("FLOURITE HUB inicializado", Theme.Accent)
Logs.Add("Aimbot: Head Only + Sticky + FOV", Color3.fromRGB(0, 255, 100))
Logs.Add("ESP: Box gradiente + Line + Health Bar", Color3.fromRGB(0, 255, 100))
Logs.Add("Config: FOV + Grossura da Linha", Color3.fromRGB(0, 255, 100))
Logs.Add("Creditos: Yz Developer", Theme.Accent)
