-- Xeioa GUI Library
-- Version 1.0.0
-- Creator: Jupiter.exe

local XeioaLib = {}
XeioaLib.__index = XeioaLib

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function CreateInstance(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function AddGradient(frame, color1, color2, rotation)
    local grad = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(255, 80, 160)),
            ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(20, 20, 30))
        }),
        Rotation = rotation or 135
    }, frame)
    return grad
end

local function AddCorner(frame, radius)
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, frame)
end

local function AddStroke(frame, color, thickness)
    CreateInstance("UIStroke", {
        Color = color or Color3.fromRGB(255, 80, 160),
        Thickness = thickness or 1,
        Transparency = 0.5
    }, frame)
end

function XeioaLib:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Xeioa Hub"
    local HubName = config.HubName or "Xeioa Hub v1.0 | Jupiter.exe"
    local ProfilePicture = config.ProfilePicture or ""
    local LoadingTitle = config.LoadingTitle or "Xeioa"
    local LoadingSubtitle = config.LoadingSubtitle or "Loading..."

    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "XeioaLib_" .. HttpService:GenerateGUID(false):sub(1, 8),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })

    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer.PlayerGui
    end

    -- Loading Screen
    local LoadingScreen = CreateInstance("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(8, 8, 12),
        BorderSizePixel = 0,
        ZIndex = 100
    }, ScreenGui)

    AddGradient(LoadingScreen, Color3.fromRGB(15, 8, 20), Color3.fromRGB(5, 5, 10), 135)

    local LoadingNoise = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0.97,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 101
    }, LoadingScreen)

    local LoadingCenter = CreateInstance("Frame", {
        Size = UDim2.new(0, 320, 0, 200),
        Position = UDim2.new(0.5, -160, 0.5, -100),
        BackgroundTransparency = 1,
        ZIndex = 102
    }, LoadingScreen)

    local LogoGlow = CreateInstance("Frame", {
        Size = UDim2.new(0, 100, 0, 100),
        Position = UDim2.new(0.5, -50, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        BackgroundTransparency = 0.6,
        ZIndex = 102
    }, LoadingCenter)
    AddCorner(LogoGlow, 50)

    local LogoInner = CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        ZIndex = 103
    }, LogoGlow)

    local LoadingTitleLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 110),
        BackgroundTransparency = 1,
        Text = LoadingTitle,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 28,
        Font = Enum.Font.GothamBold,
        ZIndex = 103
    }, LoadingCenter)

    local LoadingSubLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 148),
        BackgroundTransparency = 1,
        Text = LoadingSubtitle,
        TextColor3 = Color3.fromRGB(255, 100, 170),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ZIndex = 103
    }, LoadingCenter)

    local BarBg = CreateInstance("Frame", {
        Size = UDim2.new(0, 280, 0, 4),
        Position = UDim2.new(0.5, -140, 1, -20),
        BackgroundColor3 = Color3.fromRGB(30, 20, 35),
        ZIndex = 103
    }, LoadingScreen)
    AddCorner(BarBg, 2)

    local BarFill = CreateInstance("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        ZIndex = 104
    }, BarBg)
    AddCorner(BarFill, 2)
    AddGradient(BarFill, Color3.fromRGB(255, 80, 160), Color3.fromRGB(200, 40, 110), 90)

    -- Animate loading bar
    task.spawn(function()
        Tween(BarFill, { Size = UDim2.new(1, 0, 1, 0) }, 2.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
        local pulse = true
        task.spawn(function()
            while pulse do
                Tween(LogoGlow, { BackgroundTransparency = 0.3 }, 0.8, Enum.EasingStyle.Sine)
                task.wait(0.8)
                Tween(LogoGlow, { BackgroundTransparency = 0.7 }, 0.8, Enum.EasingStyle.Sine)
                task.wait(0.8)
            end
        end)
        task.wait(2.8)
        pulse = false
        Tween(LoadingScreen, { BackgroundTransparency = 1 }, 0.5)
        for _, d in ipairs(LoadingScreen:GetDescendants()) do
            if d:IsA("GuiObject") then
                Tween(d, { BackgroundTransparency = 1 }, 0.5)
                if d:IsA("TextLabel") then
                    Tween(d, { TextTransparency = 1 }, 0.5)
                end
            end
        end
        task.wait(0.6)
        LoadingScreen:Destroy()
    end)

    -- Main Window
    local Window = CreateInstance("Frame", {
        Name = "XeioaWindow",
        Size = UDim2.new(0, 620, 0, 420),
        Position = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = Color3.fromRGB(10, 8, 14),
        ClipsDescendants = true,
        ZIndex = 10
    }, ScreenGui)
    AddCorner(Window, 12)
    AddStroke(Window, Color3.fromRGB(255, 60, 140), 1.5)

    local WindowBG = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(15, 10, 22),
        ZIndex = 10
    }, Window)
    AddGradient(WindowBG, Color3.fromRGB(22, 10, 30), Color3.fromRGB(8, 8, 14), 150)

    -- Top Bar
    local TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(18, 10, 28),
        ZIndex = 11
    }, Window)
    AddGradient(TopBar, Color3.fromRGB(30, 12, 42), Color3.fromRGB(14, 8, 22), 90)

    local TopBarStroke = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        BackgroundTransparency = 0.6,
        ZIndex = 12
    }, TopBar)

    local TitleLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    }, TopBar)

    -- Minimize button
    local MinimizeBtn = CreateInstance("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -66, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        BackgroundTransparency = 0.7,
        Text = "—",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 13
    }, TopBar)
    AddCorner(MinimizeBtn, 6)

    local CloseBtn = CreateInstance("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(200, 30, 80),
        BackgroundTransparency = 0.5,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 13
    }, TopBar)
    AddCorner(CloseBtn, 6)

    MakeDraggable(Window, TopBar)

    -- Profile Header
    local ProfileBar = CreateInstance("Frame", {
        Name = "ProfileBar",
        Size = UDim2.new(1, 0, 0, 64),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(14, 8, 20),
        ZIndex = 11
    }, Window)
    AddGradient(ProfileBar, Color3.fromRGB(20, 8, 30), Color3.fromRGB(10, 8, 16), 90)

    local AvatarFrame = CreateInstance("Frame", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 10, 0.5, -22),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        ZIndex = 12
    }, ProfileBar)
    AddCorner(AvatarFrame, 22)
    AddStroke(AvatarFrame, Color3.fromRGB(255, 80, 160), 2)

    local Avatar = CreateInstance("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. (LocalPlayer.UserId) .. "&w=150&h=150",
        ZIndex = 13
    }, AvatarFrame)
    AddCorner(Avatar, 22)

    local PlayerNameLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 200, 0, 22),
        Position = UDim2.new(0, 62, 0, 10),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    }, ProfileBar)

    local PlayerUserLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 200, 0, 18),
        Position = UDim2.new(0, 62, 0, 32),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Color3.fromRGB(255, 100, 170),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    }, ProfileBar)

    local ProfileStroke = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        BackgroundTransparency = 0.75,
        ZIndex = 12
    }, ProfileBar)

    -- Main Body
    local Body = CreateInstance("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -168),
        Position = UDim2.new(0, 0, 0, 108),
        BackgroundTransparency = 1,
        ZIndex = 11
    }, Window)

    -- Sidebar
    local Sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 130, 1, 0),
        BackgroundColor3 = Color3.fromRGB(14, 8, 22),
        ZIndex = 11
    }, Body)
    AddGradient(Sidebar, Color3.fromRGB(18, 8, 28), Color3.fromRGB(10, 6, 16), 180)

    local SidebarStroke = CreateInstance("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        BackgroundTransparency = 0.75,
        ZIndex = 12
    }, Sidebar)

    local TabList = CreateInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -8),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 12
    }, Sidebar)

    CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    }, TabList)

    -- Content Area
    local ContentArea = CreateInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 130, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 11
    }, Body)

    -- Footer / HubName
    local Footer = CreateInstance("Frame", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = Color3.fromRGB(12, 6, 18),
        ZIndex = 12
    }, Window)
    AddGradient(Footer, Color3.fromRGB(20, 8, 30), Color3.fromRGB(10, 6, 16), 90)

    local FooterStroke = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        BackgroundTransparency = 0.7,
        ZIndex = 13
    }, Footer)

    local FooterLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = HubName,
        TextColor3 = Color3.fromRGB(255, 100, 170),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ZIndex = 13
    }, Footer)

    -- Mobile Toggle Button
    local MobileBtn = CreateInstance("TextButton", {
        Name = "MobileOpenBtn",
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0, 16, 1, -80),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 20,
        Visible = IsMobile
    }, ScreenGui)
    AddCorner(MobileBtn, 24)
    AddStroke(MobileBtn, Color3.fromRGB(255, 120, 180), 2)

    local GlowEffect = CreateInstance("Frame", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundColor3 = Color3.fromRGB(255, 60, 140),
        BackgroundTransparency = 0.7,
        ZIndex = 19
    }, MobileBtn)
    AddCorner(GlowEffect, 28)

    -- State
    local Minimized = false
    local Visible = true
    local StoredSize = Window.Size
    local ActiveTab = nil
    local Tabs = {}

    -- Minimize logic
    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            StoredSize = Window.Size
            Tween(Window, { Size = UDim2.new(0, 620, 0, 44) }, 0.3)
            Body.Visible = false
            Footer.Visible = false
            ProfileBar.Visible = false
            MinimizeBtn.Text = "▲"
        else
            Body.Visible = true
            Footer.Visible = true
            ProfileBar.Visible = true
            Tween(Window, { Size = StoredSize }, 0.3)
            MinimizeBtn.Text = "—"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Visible = false
        Tween(Window, { BackgroundTransparency = 1, Size = UDim2.new(0, 620, 0, 0) }, 0.3)
        for _, d in ipairs(Window:GetDescendants()) do
            if d:IsA("GuiObject") then
                Tween(d, { BackgroundTransparency = 1 }, 0.25)
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    Tween(d, { TextTransparency = 1 }, 0.25)
                end
            end
        end
        task.wait(0.35)
        Window.Visible = false
        if IsMobile then MobileBtn.Visible = true end
    end)

    MobileBtn.MouseButton1Click:Connect(function()
        Visible = not Visible
        Window.Visible = Visible
        if Visible then
            Window.Size = UDim2.new(0, 360, 0, 500)
            Window.Position = UDim2.new(0.5, -180, 0.05, 0)
            MobileBtn.Text = "✕"
        else
            MobileBtn.Text = "X"
        end
    end)

    -- Mobile sizing
    if IsMobile then
        Window.Size = UDim2.new(0, 360, 0, 500)
        Window.Position = UDim2.new(0.5, -180, 0.05, 0)
        Sidebar.Size = UDim2.new(0, 100, 1, 0)
        ContentArea.Size = UDim2.new(1, -100, 1, 0)
        ContentArea.Position = UDim2.new(0, 100, 0, 0)
    end

    -- Tab System
    local function SwitchTab(tabName)
        for name, tabData in pairs(Tabs) do
            if name == tabName then
                tabData.Content.Visible = true
                Tween(tabData.Button, { BackgroundColor3 = Color3.fromRGB(255, 60, 140), BackgroundTransparency = 0.3 }, 0.2)
                tabData.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tabData.Content.Visible = false
                Tween(tabData.Button, { BackgroundColor3 = Color3.fromRGB(255, 60, 140), BackgroundTransparency = 0.85 }, 0.2)
                tabData.Button.TextColor3 = Color3.fromRGB(200, 160, 190)
            end
        end
        ActiveTab = tabName
    end

    local WindowObj = {}

    function WindowObj:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Tab"
        local TabIcon = tabConfig.Icon or ""

        local TabBtn = CreateInstance("TextButton", {
            Size = UDim2.new(1, -12, 0, 34),
            BackgroundColor3 = Color3.fromRGB(255, 60, 140),
            BackgroundTransparency = 0.85,
            Text = (TabIcon ~= "" and TabIcon .. "  " or "") .. TabName,
            TextColor3 = Color3.fromRGB(200, 160, 190),
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            ZIndex = 13
        }, TabList)
        AddCorner(TabBtn, 7)

        local TabContent = CreateInstance("ScrollingFrame", {
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(255, 60, 140),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 12
        }, ContentArea)

        local ContentLayout = CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }, TabContent)

        CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6)
        }, TabContent)

        Tabs[TabName] = { Button = TabBtn, Content = TabContent }

        TabBtn.MouseButton1Click:Connect(function()
            SwitchTab(TabName)
        end)

        TabBtn.MouseEnter:Connect(function()
            if ActiveTab ~= TabName then
                Tween(TabBtn, { BackgroundTransparency = 0.7 }, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if ActiveTab ~= TabName then
                Tween(TabBtn, { BackgroundTransparency = 0.85 }, 0.15)
            end
        end)

        if not ActiveTab then
            SwitchTab(TabName)
        end

        local TabObj = {}

        local function MakeSection(sectionName)
            local SectionFrame = CreateInstance("Frame", {
                Size = UDim2.new(1, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(18, 10, 28),
                BackgroundTransparency = 0.3,
                ZIndex = 13
            }, TabContent)
            AddCorner(SectionFrame, 8)
            AddStroke(SectionFrame, Color3.fromRGB(255, 60, 140), 1)

            CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8)
            }, SectionFrame)

            local SectionLayout = CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, SectionFrame)

            if sectionName and sectionName ~= "" then
                local SectionTitle = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = sectionName,
                    TextColor3 = Color3.fromRGB(255, 80, 150),
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 14
                }, SectionFrame)
            end

            return SectionFrame
        end

        function TabObj:AddSection(sectionName)
            local Section = MakeSection(sectionName)
            local SectionObj = {}

            function SectionObj:AddToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local ToggleName = toggleConfig.Name or "Toggle"
                local Default = toggleConfig.Default or false
                local Callback = toggleConfig.Callback or function() end

                local State = Default

                local ToggleFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    ZIndex = 14
                }, Section)

                local ToggleLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -54, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ToggleName,
                    TextColor3 = Color3.fromRGB(220, 200, 215),
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 14
                }, ToggleFrame)

                local PillBg = CreateInstance("TextButton", {
                    Size = UDim2.new(0, 44, 0, 24),
                    Position = UDim2.new(1, -44, 0.5, -12),
                    BackgroundColor3 = State and Color3.fromRGB(255, 60, 140) or Color3.fromRGB(35, 20, 45),
                    Text = "",
                    ZIndex = 14
                }, ToggleFrame)
                AddCorner(PillBg, 12)

                local PillKnob = CreateInstance("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = State and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex = 15
                }, PillBg)
                AddCorner(PillKnob, 9)

                local function UpdateToggle(newState, skipCallback)
                    State = newState
                    if State then
                        Tween(PillBg, { BackgroundColor3 = Color3.fromRGB(255, 60, 140) }, 0.2)
                        Tween(PillKnob, { Position = UDim2.new(1, -21, 0.5, -9) }, 0.2, Enum.EasingStyle.Back)
                    else
                        Tween(PillBg, { BackgroundColor3 = Color3.fromRGB(35, 20, 45) }, 0.2)
                        Tween(PillKnob, { Position = UDim2.new(0, 3, 0.5, -9) }, 0.2, Enum.EasingStyle.Back)
                    end
                    if not skipCallback then Callback(State) end
                end

                PillBg.MouseButton1Click:Connect(function()
                    UpdateToggle(not State)
                end)

                if Default then UpdateToggle(true, true) end

                local ToggleObj = {}
                function ToggleObj:Set(val) UpdateToggle(val, true) end
                function ToggleObj:Get() return State end
                return ToggleObj
            end

            function SectionObj:AddButton(btnConfig)
                btnConfig = btnConfig or {}
                local BtnName = btnConfig.Name or "Button"
                local Callback = btnConfig.Callback or function() end

                local Btn = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Color3.fromRGB(255, 60, 140),
                    BackgroundTransparency = 0.5,
                    Text = BtnName,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    Font = Enum.Font.GothamSemibold,
                    ZIndex = 14
                }, Section)
                AddCorner(Btn, 7)
                AddStroke(Btn, Color3.fromRGB(255, 80, 160), 1)

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, { BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(255, 80, 160) }, 0.15)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, { BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(255, 60, 140) }, 0.15)
                end)
                Btn.MouseButton1Down:Connect(function()
                    Tween(Btn, { Size = UDim2.new(1, -4, 0, 28) }, 0.08)
                end)
                Btn.MouseButton1Up:Connect(function()
                    Tween(Btn, { Size = UDim2.new(1, 0, 0, 30) }, 0.12)
                end)
                Btn.MouseButton1Click:Connect(Callback)
            end

            function SectionObj:AddLabel(text)
                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    Text = text or "",
                    TextColor3 = Color3.fromRGB(180, 150, 175),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 14
                }, Section)
            end

            function SectionObj:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local SliderName = sliderConfig.Name or "Slider"
                local Min = sliderConfig.Min or 0
                local Max = sliderConfig.Max or 100
                local Default = sliderConfig.Default or Min
                local Callback = sliderConfig.Callback or function() end

                local Value = Default

                local SliderFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 46),
                    BackgroundTransparency = 1,
                    ZIndex = 14
                }, Section)

                local SliderHeader = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    ZIndex = 14
                }, SliderFrame)

                CreateInstance("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = SliderName,
                    TextColor3 = Color3.fromRGB(220, 200, 215),
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 14
                }, SliderHeader)

                local ValueLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(Value),
                    TextColor3 = Color3.fromRGB(255, 100, 170),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 14
                }, SliderHeader)

                local Track = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundColor3 = Color3.fromRGB(35, 20, 45),
                    ZIndex = 14
                }, SliderFrame)
                AddCorner(Track, 3)

                local Fill = CreateInstance("Frame", {
                    Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 60, 140),
                    ZIndex = 15
                }, Track)
                AddCorner(Fill, 3)
                AddGradient(Fill, Color3.fromRGB(255, 80, 160), Color3.fromRGB(200, 40, 100), 90)

                local Knob = CreateInstance("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((Value - Min) / (Max - Min), -7, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex = 16
                }, Track)
                AddCorner(Knob, 7)

                local Dragging = false

                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Value = math.round(Min + (Max - Min) * pos)
                    ValueLabel.Text = tostring(Value)
                    Tween(Fill, { Size = UDim2.new(pos, 0, 1, 0) }, 0.05)
                    Tween(Knob, { Position = UDim2.new(pos, -7, 0.5, -7) }, 0.05)
                    Callback(Value)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return XeioaLib
