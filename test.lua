local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

Library.Flags = {}
Library.Elements = {}
Library.Registry = {}
Library.ThemeRegistry = {}
Library.TextRegistry = {}
Library.FontRegistry = {}
Library.ThemeCallbacks = {}
Library.ExternalButtons = {}

-- Connection Tracker / Janitor for complete memory leak prevention
local Janitor = { Connections = {} }

function Janitor:Add(connection)
    table.insert(self.Connections, connection)
    return connection
end

function Janitor:Cleanup()
    for _, conn in ipairs(self.Connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    self.Connections = {}
end

-- Create folder if supported
local isFolderSupported = makefolder and isfolder
if isFolderSupported and not isfolder("LouisHubConfig") then
    makefolder("LouisHubConfig")
end

-- ========================================================
-- [[ CONFIGURABLE FLOATING ICON DECAL ]]
-- ========================================================
local FLOATING_ICON_DECAL = "rbxthumb://type=Asset&id=104436283956004&w=150&h=150"

-- ========================================================
-- [[ DYNAMIC GITHUB LUCIDE ICON LOADER ]]
-- ========================================================
local function GetIcon(iconName)
    if not iconName then return "" end
    iconName = iconName:lower()
    
    if string.match(iconName, "^rbxassetid://") or string.match(iconName, "^http") then
        return iconName
    end
    
    if writefile and readfile and isfile and getcustomasset then
        local success, assetPath = pcall(function()
            if not isfolder("LouisHubConfig") then pcall(makefolder, "LouisHubConfig") end
            if not isfolder("LouisHubConfig/.icons") then pcall(makefolder, "LouisHubConfig/.icons") end
            
            local fileName = iconName .. ".png"
            local localPath = "LouisHubConfig/.icons/" .. fileName
            
            if isfile(localPath) then
                return getcustomasset(localPath)
            else
                local url = "https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/icons/compiled/256px/" .. fileName
                local content = game:HttpGet(url)
                if content and #content > 0 then
                    writefile(localPath, content)
                    return getcustomasset(localPath)
                end
            end
        end)
        if success and assetPath then
            return assetPath
        end
    end
    
    local Fallbacks = {
        ["apple"] = "rbxassetid://10734741641",
        ["user"] = "rbxassetid://10723374112",
        ["gear"] = "rbxassetid://10734950309",
        ["cog"] = "rbxassetid://10734950309",
        ["settings"] = "rbxassetid://10734950309",
        ["folder"] = "rbxassetid://10734741211",
        ["sliders"] = "rbxassetid://10734942250",
        ["slider"] = "rbxassetid://10734942250",
        ["info"] = "rbxassetid://10723415903",
        ["chevron-down"] = "rbxassetid://10709790644",
        ["chevrons-left"] = "rbxassetid://10709790644",
        ["chevrons-right"] = "rbxassetid://10709790644",
        ["shield"] = "rbxassetid://10723375133",
        ["crown"] = "rbxassetid://10723375133"
    }
    return Fallbacks[iconName] or "rbxassetid://10723375133"
end

-- ========================================================
-- [[ HEX & COLOR CONVERTERS ]]
-- ========================================================
local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
    end
    return nil
end

local function Color3ToHex(color)
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

-- ========================================================
-- [[ COLOR PALETTE ]]
-- ========================================================
local Themes = {
    ["Compkiller"] = {
        WindowBg = Color3.fromRGB(21, 23, 28),
        SidebarBg = Color3.fromRGB(28, 31, 38),
        SectionBg = Color3.fromRGB(24, 26, 32),
        ElementBg = Color3.fromRGB(32, 36, 45),
        StrokeColor = Color3.fromRGB(38, 41, 49),
        Accent = Color3.fromRGB(0, 213, 239),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(160, 165, 175), -- Neutral grey to prevent blue tint leakage
        TextDark = Color3.fromRGB(110, 115, 125)
    }
}

local CurrentTheme = Themes["Compkiller"]

local function RegisterTheme(instance, propertyMap)
    table.insert(Library.ThemeRegistry, {
        Instance = instance,
        Properties = propertyMap
    })
    for prop, key in pairs(propertyMap) do
        pcall(function()
            instance[prop] = CurrentTheme[key]
        end)
    end
end

local function RegisterThemeCallback(callback)
    table.insert(Library.ThemeCallbacks, callback)
    task.spawn(callback, CurrentTheme.Accent)
end

-- ========================================================
-- [[ TEXT & FONT REGISTRY ]]
-- ========================================================
local function RegisterText(instance, baseSize)
    table.insert(Library.TextRegistry, {
        Instance = instance,
        BaseSize = baseSize
    })
    instance.TextSize = baseSize * (Library.Settings.TextSizeMultiplier or 1.0)
end

local function UpdateTextSizes(multiplier)
    Library.Settings.TextSizeMultiplier = multiplier
    for _, item in ipairs(Library.TextRegistry) do
        pcall(function()
            item.Instance.TextSize = math.floor(item.BaseSize * multiplier + 0.5)
        end)
    end
end

local function RegisterFont(instance, isBold)
    table.insert(Library.FontRegistry, {
        Instance = instance,
        IsBold = isBold
    })
    instance.Font = isBold and Library.Settings.BoldFont or Library.Settings.Font
end

-- ========================================================
-- [[ HYBRID TOUCH & MOUSE DRAGGING ]]
-- ========================================================
local function MakeDraggable(dragTrigger, frameToMove)
    local dragging, dragInput, dragStart, startPos
    
    Janitor:Add(dragTrigger.InputBegan:Connect(function(input)
        -- Kunci posisi serempak jika diaktifkan di tab Setting [1]
        if Library.Settings.DragLocked then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frameToMove.Position
            
            local endConn
            endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    endConn:Disconnect()
                end
            end)
        end
    end))
    
    Janitor:Add(dragTrigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    
    Janitor:Add(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frameToMove.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

-- ========================================================
-- [[ AUTOMATIC PC BACKGROUND KEYBIND LISTENER ]]
-- ========================================================
Janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for flag, item in pairs(Library.Registry) do
            if item.Type == "Keybind" and Library.Flags[flag] == input.KeyCode then
                if item.Callback then
                    task.spawn(item.Callback, input.KeyCode)
                end
            end
        end
    end
end))

-- ========================================================
-- [[ EXTERNAL FLOATING BUTTON MANAGER ]]
-- ========================================================
function Library:CreateExternalButton(text, buttonType, shape, flag, callback)
    local screenGui = game:GetService("CoreGui"):FindFirstChild("Nexus_Compkiller_UI") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Nexus_Compkiller_UI")
    if not screenGui then return end

    if Library.ExternalButtons[flag] then
        Library.ExternalButtons[flag]:Destroy()
        Library.ExternalButtons[flag] = nil
    end

    local ExtBtnFrame = Instance.new("Frame", screenGui)
    ExtBtnFrame.Name = "External_" .. flag
    ExtBtnFrame.BackgroundTransparency = 0.3
    ExtBtnFrame.ZIndex = 50
    RegisterTheme(ExtBtnFrame, { BackgroundColor3 = "SidebarBg" })
    
    -- Automatic Horizontal Scaling to prevent clipping regardless of text length
    ExtBtnFrame.AutomaticSize = Enum.AutomaticSize.X
    ExtBtnFrame.Size = UDim2.new(0, 0, 0, 30)
    ExtBtnFrame.Position = UDim2.new(0.5, -40, 0.3, 0)
    
    local ExtCorner = Instance.new("UICorner", ExtBtnFrame)
    
    -- Dynamically apply the global UI setting shape choice
    local activeShape = Library.Settings.ExternalShape or shape or "Round"
    local function SetShapeCorner(val)
        if val == "Circle" then
            ExtCorner.CornerRadius = UDim.new(1, 0)
        elseif val == "Round" then
            ExtCorner.CornerRadius = UDim.new(0, 8)
        else
            ExtCorner.CornerRadius = UDim.new(0, 0)
        end
    end
    SetShapeCorner(activeShape)
    
    local ExtStroke = Instance.new("UIStroke", ExtBtnFrame)
    ExtStroke.Thickness = 1.3
    RegisterTheme(ExtStroke, { Color = "Accent" })
    
    local Padding = Instance.new("UIPadding", ExtBtnFrame)
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)
    
    local ActBtn = Instance.new("TextButton", ExtBtnFrame)
    ActBtn.Size = UDim2.new(1, 0, 1, 0)
    ActBtn.BackgroundTransparency = 1
    ActBtn.Text = text
    RegisterTheme(ActBtn, { TextColor3 = "TextPrimary" })
    RegisterFont(ActBtn, true)
    RegisterText(ActBtn, 11)
    
    ActBtn.AutomaticSize = Enum.AutomaticSize.X
    MakeDraggable(ExtBtnFrame, ExtBtnFrame)
    
    local state = false
    if buttonType == "Toggle" then
        Janitor:Add(ActBtn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                TweenService:Create(ExtStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255) }):Play()
                TweenService:Create(ActBtn, TweenInfo.new(0.2), { TextColor3 = CurrentTheme.Accent }):Play()
            else
                TweenService:Create(ExtStroke, TweenInfo.new(0.2), { Color = CurrentTheme.Accent }):Play()
                TweenService:Create(ActBtn, TweenInfo.new(0.2), { TextColor3 = CurrentTheme.TextPrimary }):Play()
            end
            if callback then task.spawn(callback, state) end
        end))
    else -- Clicker Type
        Janitor:Add(ActBtn.MouseButton1Click:Connect(function()
            TweenService:Create(ExtBtnFrame, TweenInfo.new(0.1), { BackgroundTransparency = 0.6 }):Play()
            task.delay(0.1, function()
                TweenService:Create(ExtBtnFrame, TweenInfo.new(0.1), { BackgroundTransparency = 0.3 }):Play()
            end)
            if callback then task.spawn(callback) end
        end))
    end
    
    Library.ExternalButtons[flag] = ExtBtnFrame
    return ExtBtnFrame
end

function Library:DestroyExternalButton(flag)
    if Library.ExternalButtons[flag] then
        Library.ExternalButtons[flag]:Destroy()
        Library.ExternalButtons[flag] = nil
    end
end

-- ========================================================
-- [[ BACKEND: PREMIUM TOAST NOTIFICATION MANAGER ]]
-- ========================================================
function Library:CreateNotification(titleText, messageText, duration)
    local screenGui = game:GetService("CoreGui"):FindFirstChild("Nexus_Compkiller_UI") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Nexus_Compkiller_UI")
    if not screenGui then return end
    
    local container = screenGui:FindFirstChild("NotificationContainer")
    if not container then
        container = Instance.new("Frame", screenGui)
        container.Name = "NotificationContainer"
        container.Size = UDim2.new(0, 280, 1, -20)
        container.Position = UDim2.new(1, -290, 0, 10)
        container.BackgroundTransparency = 1
        
        local layout = Instance.new("UIListLayout", container)
        layout.Padding = UDim.new(0, 8)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    end
    
    local toast = Instance.new("Frame", container)
    toast.Size = UDim2.new(1, 0, 0, 0)
    toast.ClipsDescendants = true
    RegisterTheme(toast, { BackgroundColor3 = "SidebarBg" })
    
    local toastCorner = Instance.new("UICorner", toast)
    toastCorner.CornerRadius = UDim.new(0, 6)
    
    local toastStroke = Instance.new("UIStroke", toast)
    toastStroke.Thickness = 1
    RegisterTheme(toastStroke, { Color = "StrokeColor" })
    
    local accentBar = Instance.new("Frame", toast)
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    RegisterTheme(accentBar, { BackgroundColor3 = "Accent" })
    
    local title = Instance.new("TextLabel", toast)
    title.Size = UDim2.new(1, -20, 0, 16)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = titleText or "Notification"
    title.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(title, { TextColor3 = "TextPrimary" })
    RegisterFont(title, true)
    RegisterText(title, 11)
    
    local desc = Instance.new("TextLabel", toast)
    desc.Size = UDim2.new(1, -20, 1, -28)
    desc.Position = UDim2.new(0, 12, 0, 24)
    desc.BackgroundTransparency = 1
    desc.Text = messageText or "System notification message."
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    RegisterTheme(desc, { TextColor3 = "TextSecondary" })
    RegisterFont(desc, false)
    RegisterText(desc, 10)
    
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 64) }):Play()
    toast.BackgroundTransparency = 1
    TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 0.4 }):Play()
    
    task.delay(duration or 4, function()
        local shrink = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 0) })
        shrink:Play()
        TweenService:Create(toast, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
        shrink.Completed:Connect(function()
            toast:Destroy()
        end)
    end)
end

-- ========================================================
-- [[ MAIN WINDOW CREATION ]]
-- ========================================================
function Library:CreateWindow(titleText, subtitleText, customConfig)
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Visible = false,
        CategoryCount = 0,
        SidebarCollapsed = false
    }

    local config = customConfig or {}
    Library.Settings = {
        Mode = config.Mode or "PC",
        Scale = config.Scale or 1.0,
        Font = config.Font or Enum.Font.GothamMedium,
        BoldFont = config.BoldFont or Enum.Font.GothamBold,
        TextSizeMultiplier = config.TextSizeMultiplier or 1.0,
        ExternalShape = "Round",
        DragLocked = false -- Posisi seret awal dibuka (tidak dikunci)
    }

    local cleanTitle = string.gsub(titleText or "Universal", "[%s%p]", "_")
    local ConfigFolder = "LouisHubConfig/" .. cleanTitle
    if isFolderSupported and not isfolder("LouisHubConfig") then
        makefolder("LouisHubConfig")
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Nexus_Compkiller_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local successHui, hui = pcall(function() return gethui and gethui() end)
    ScreenGui.Parent = (successHui and hui) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    -- Clean Memory Leak preventative onDestroy listener
    Janitor:Add(ScreenGui.Destroying:Connect(function()
        Janitor:Cleanup()
    end))

    local MainFrame = Instance.new("Frame")
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundTransparency = 1
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.5
    RegisterTheme(MainStroke, { Color = "StrokeColor" })

    -- PERFORMANCE Floating HUD di Pojok Kanan Atas Layar (Lebar diperbesar 150px agar rapi)
    local HudFrame = Instance.new("Frame", ScreenGui)
    HudFrame.Name = "Nexus_Performance_HUD"
    HudFrame.Size = UDim2.new(0, 150, 0, 24)
    HudFrame.Position = UDim2.new(1, -160, 0, 10)
    HudFrame.BackgroundTransparency = 0.4
    HudFrame.Visible = false -- Tersembunyi dari awal
    RegisterTheme(HudFrame, { BackgroundColor3 = "SidebarBg" })

    local HudCorner = Instance.new("UICorner", HudFrame)
    HudCorner.CornerRadius = UDim.new(0, 6)

    local HudStroke = Instance.new("UIStroke", HudFrame)
    HudStroke.Thickness = 1
    RegisterTheme(HudStroke, { Color = "Accent" }) -- Mengikuti aksen warna

    local HudText = Instance.new("TextLabel", HudFrame)
    HudText.Size = UDim2.new(1, 0, 1, 0)
    HudText.BackgroundTransparency = 1
    HudText.Text = "FPS: Calculating... | Ping: Calculating..."
    HudText.TextXAlignment = Enum.TextXAlignment.Center
    HudText.TextYAlignment = Enum.TextYAlignment.Center
    HudText.TextWrapped = false -- Mencegah teks turun baris meluap keluar kotak
    HudText.ClipsDescendants = true
    RegisterTheme(HudText, { TextColor3 = "TextPrimary" })
    RegisterFont(HudText, true)
    RegisterText(HudText, 10)

    -- Sidebar (Left Area)
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BorderSizePixel = 0
    Sidebar.BackgroundTransparency = 0.4
    RegisterTheme(Sidebar, { BackgroundColor3 = "SidebarBg" })

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 8)

    local SidebarMask = Instance.new("Frame", Sidebar)
    SidebarMask.Size = UDim2.new(0, 15, 1, 0)
    SidebarMask.Position = UDim2.new(1, -15, 0, 0)
    SidebarMask.BorderSizePixel = 0
    SidebarMask.BackgroundTransparency = 0.4
    RegisterTheme(SidebarMask, { BackgroundColor3 = "SidebarBg" })

    -- Latar Belakang Padat Bagian Kanan (Content Area)
    local ContentBg = Instance.new("Frame", MainFrame)
    ContentBg.Size = UDim2.new(1, -170, 1, 0)
    ContentBg.Position = UDim2.new(0, 170, 0, 0)
    ContentBg.BorderSizePixel = 0
    RegisterTheme(ContentBg, { BackgroundColor3 = "WindowBg" })

    local ContentBgCorner = Instance.new("UICorner", ContentBg)
    ContentBgCorner.CornerRadius = UDim.new(0, 8)

    local ContentBgMask = Instance.new("Frame", ContentBg)
    ContentBgMask.Size = UDim2.new(0, 15, 1, 0)
    ContentBgMask.Position = UDim2.new(0, 0, 0, 0)
    ContentBgMask.BorderSizePixel = 0
    RegisterTheme(ContentBgMask, { BackgroundColor3 = "WindowBg" })

    -- Drag Handle Logo Area
    local LogoArea = Instance.new("Frame", Sidebar)
    LogoArea.Size = UDim2.new(1, 0, 0, 50)
    LogoArea.BackgroundTransparency = 1
    MakeDraggable(LogoArea, MainFrame)

    local TitleLabel = Instance.new("TextLabel", LogoArea)
    TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    TitleLabel.Position = UDim2.new(0, 52, 0, 0) -- Digeser sedikit ke kanan mencegah tabrakan dengan logo
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText or "COMPKILLER"
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(TitleLabel, { TextColor3 = "TextPrimary" })
    RegisterFont(TitleLabel, true)
    RegisterText(TitleLabel, 13)

    -- Sidebar Scroll
    local TabScroll = Instance.new("ScrollingFrame", Sidebar)
    TabScroll.Size = UDim2.new(1, -10, 1, -120)
    TabScroll.Position = UDim2.new(0, 5, 0, 55)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabListLayout = Instance.new("UIListLayout", TabScroll)
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Janitor:Add(TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
    end))

    -- Bottom User profile
    local UserCard = Instance.new("Frame", Sidebar)
    UserCard.Size = UDim2.new(1, -20, 0, 50)
    UserCard.Position = UDim2.new(0, 10, 1, -60)
    UserCard.BackgroundTransparency = 1

    local AvatarImg = Instance.new("ImageLabel", UserCard)
    AvatarImg.Size = UDim2.new(0, 32, 0, 32)
    AvatarImg.Position = UDim2.new(0, 5, 0.5, -16)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

    local UsernameLabel = Instance.new("TextLabel", UserCard)
    UsernameLabel.Size = UDim2.new(1, -50, 0, 16)
    UsernameLabel.Position = UDim2.new(0, 44, 0.5, -14)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = LocalPlayer.DisplayName
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(UsernameLabel, { TextColor3 = "TextPrimary" })
    RegisterFont(UsernameLabel, true)
    RegisterText(UsernameLabel, 11)

    local SubtextLabel = Instance.new("TextLabel", UserCard)
    SubtextLabel.Size = UDim2.new(1, -50, 0, 14)
    SubtextLabel.Position = UDim2.new(0, 44, 0.5, 2)
    SubtextLabel.BackgroundTransparency = 1
    SubtextLabel.Text = subtitleText or "NEVER"
    SubtextLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(SubtextLabel, { TextColor3 = "TextDark" })
    RegisterFont(SubtextLabel, true)
    RegisterText(SubtextLabel, 9)

    -- Content Frame Workspace
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -170, 1, 0)
    ContentArea.Position = UDim2.new(0, 170, 0, 0)
    ContentArea.BackgroundTransparency = 1

    -- ========================================================
    -- [[ SIDEBAR COLLAPSE / EXPAND MECHANISM ]]
    -- ========================================================
    local CollapseBtn = Instance.new("ImageButton", Sidebar)
    CollapseBtn.Size = UDim2.new(0, 16, 0, 16)
    -- Di reposisi rapi di bagian tengah vertikal sebelah kanan pembatas sidebar [1]
    CollapseBtn.Position = UDim2.new(1, -26, 0.5, -8)
    CollapseBtn.BackgroundTransparency = 1
    CollapseBtn.Image = GetIcon("chevrons-left")
    RegisterTheme(CollapseBtn, { ImageColor3 = "TextSecondary" })

    local function SetSidebarCollapsed(collapsed)
        Window.SidebarCollapsed = collapsed
        local duration = 0.3
        local ease = Enum.EasingStyle.Quad
        local dir = Enum.EasingDirection.Out
        
        local activeWidth = collapsed and 60 or 170
        
        -- Smoothly tween Sidebar and Content Container widths
        TweenService:Create(Sidebar, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(0, activeWidth, 1, 0) }):Play()
        TweenService:Create(SidebarMask, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(0, 15, 1, 0), Position = UDim2.new(1, -15, 0, 0) }):Play()
        
        TweenService:Create(ContentBg, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(1, -activeWidth, 1, 0), Position = UDim2.new(0, activeWidth, 0, 0) }):Play()
        TweenService:Create(ContentBgMask, TweenInfo.new(duration, ease, dir), { Position = UDim2.new(0, 0, 0, 0) }):Play()
        TweenService:Create(ContentArea, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(1, -activeWidth, 1, 0), Position = UDim2.new(0, activeWidth, 0, 0) }):Play()
        
        -- Transition Logo Area
        if collapsed then
            TitleLabel.Visible = false
            CollapseBtn.Image = GetIcon("chevrons-right")
        else
            TitleLabel.Visible = true
            CollapseBtn.Image = GetIcon("chevrons-left")
        end
        
        -- Transition Profile Card
        if collapsed then
            UsernameLabel.Visible = false
            SubtextLabel.Visible = false
            AvatarImg.Position = UDim2.new(0.5, -16, 0.5, -16)
        else
            UsernameLabel.Visible = true
            SubtextLabel.Visible = true
            AvatarImg.Position = UDim2.new(0, 5, 0.5, -16)
        end
        
        -- Transition Tab Buttons
        for _, tab in ipairs(Window.Tabs) do
            local tabBtn = tab.Button
            local tabIcon = tabBtn:FindFirstChildOfClass("ImageLabel")
            local tabLabel = tabBtn:FindFirstChildOfClass("TextLabel")
            
            if collapsed then
                if tabLabel then tabLabel.Visible = false end
                if tabIcon then tabIcon.Position = UDim2.new(0.5, -8, 0.5, -8) end
            else
                if tabLabel then tabLabel.Visible = true end
                if tabIcon then tabIcon.Position = UDim2.new(0, 12, 0.5, -8) end
            end
        end
        
        -- Transition Category Labels (hide them in compact mode)
        for _, child in ipairs(TabScroll:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "TabBtn" then
                child.Visible = not collapsed
            end
        end
    end

    Janitor:Add(CollapseBtn.MouseButton1Click:Connect(function()
        SetSidebarCollapsed(not Window.SidebarCollapsed)
    end))

    local UiScale = Instance.new("UIScale", MainFrame)
    UiScale.Scale = Library.Settings.Scale

    local TargetSize = UDim2.new(0, 640, 0, 460)
    local TargetPosition = UDim2.new(0.5, -320, 0.5, -230)

    local function ApplyUiSettings(mode, scale)
        Library.Settings.Mode = mode
        Library.Settings.Scale = scale
        UiScale.Scale = scale
        
        if mode == "PC" then
            TargetSize = UDim2.new(0, 640, 0, 460)
            TargetPosition = UDim2.new(0.5, -320, 0.5, -230)
        elseif mode == "Mobile" then
            TargetSize = UDim2.new(0, 520, 0, 350)
            TargetPosition = UDim2.new(0.5, -260, 0.5, -175)
        end

        if Window.Visible then
            MainFrame.Size = TargetSize
            MainFrame.Position = TargetPosition
        end
        
        for _, t in ipairs(Window.Tabs) do
            t.ResizeCanvas()
        end
    end
    ApplyUiSettings(Library.Settings.Mode, Library.Settings.Scale)

    -- ========================================================
    -- [[ MOBILE FLOATING TOGGLE ICON ]]
    -- ========================================================
    local FloatingToggle = Instance.new("TextButton", ScreenGui)
    FloatingToggle.Name = "Nexus_Floating_Toggler"
    FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
    FloatingToggle.Position = UDim2.new(0, 20, 0.5, -24)
    FloatingToggle.BorderSizePixel = 0
    FloatingToggle.Text = ""
    FloatingToggle.Visible = true -- Tampil dari awal (sebelum UI muncul)
    FloatingToggle.ClipsDescendants = true
    RegisterTheme(FloatingToggle, { BackgroundColor3 = "SidebarBg" })

    -- Ikon melayang berbentuk squircle tumpul modern
    local ToggleCorner = Instance.new("UICorner", FloatingToggle)
    ToggleCorner.CornerRadius = UDim.new(0, 12)

    local ToggleStroke = Instance.new("UIStroke", FloatingToggle)
    ToggleStroke.Thickness = 1.5
    RegisterTheme(ToggleStroke, { Color = "Accent" })

    local ToggleIconImage = Instance.new("ImageLabel", FloatingToggle)
    -- Logo kustom diperbesar rasionya di dalam tombol tanpa merubah ukuran bingkai tombol melayang (0.85) [1]
    ToggleIconImage.Size = UDim2.new(0.85, 0, 0.85, 0)
    ToggleIconImage.Position = UDim2.new(0.075, 0, 0.075, 0)
    ToggleIconImage.BackgroundTransparency = 1
    -- Memuat decal kustom kustom Anda dengan rbxthumb (Warna asli penuh tanpa tint) [1]
    ToggleIconImage.Image = FLOATING_ICON_DECAL

    MakeDraggable(FloatingToggle, FloatingToggle)

    local function ToggleGui()
        Window.Visible = not Window.Visible
        
        -- Sesuaikan Target Ukuran Sebelum Dimulai Animasi
        if Library.Settings.Mode == "PC" then
            TargetSize = UDim2.new(0, 640, 0, 460)
            TargetPosition = UDim2.new(0.5, -320, 0.5, -230)
        else
            TargetSize = UDim2.new(0, 500, 0, 340)
            TargetPosition = UDim2.new(0.5, -250, 0.5, -170)
        end

        if Window.Visible then
            MainFrame.Visible = true
            -- Set ukuran ke 0 terlebih dahulu di tengah layar sebelum pop-out dimulai
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = TargetSize, Position = TargetPosition}):Play()
            -- Ikon melayang mengecil/hilang ketika UI dibuka (seperti sistem toggle aslinya)
            TweenService:Create(FloatingToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        else
            local shrink = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
            shrink:Play()
            shrink.Completed:Connect(function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
            
            -- Ikon melayang muncul kembali ketika UI ditutup
            TweenService:Create(FloatingToggle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()
        end
    end

    Janitor:Add(FloatingToggle.MouseButton1Click:Connect(ToggleGui))

    -- Logo Utama Pojok Kiri Atas diperbesar (32x32) dan mengikat fungsi minimize UI kustom Anda [1]
    local LogoIcon = Instance.new("ImageButton", LogoArea)
    LogoIcon.Size = UDim2.new(0, 32, 0, 32)
    LogoIcon.Position = UDim2.new(0, 12, 0.5, -16)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = FLOATING_ICON_DECAL

    Janitor:Add(LogoIcon.MouseButton1Click:Connect(function()
        ToggleGui() -- Klik Logo LouisHub untuk me-minimize UI utama dan memunculkan floating icon kembali [1]
    end))

    Janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            ToggleGui()
        end
    end))

    -- Welcome Notification yang otomatis berbunyi/muncul saat inisialisasi CreateWindow [1]
    task.spawn(function()
        task.wait(0.2)
        Library:CreateNotification("Welcome to LouisHub", "UI Framework executed successfully. Press Insert to minimize.", 5)
    end)

    -- ========================================================
    -- [[ CATEGORY HEADER SYSTEM ]]
    -- ========================================================
    function Window:CreateCategory(categoryName)
        Window.CategoryCount = Window.CategoryCount + 1

        if Window.CategoryCount > 1 then
            local SeparatorFrame = Instance.new("Frame", TabScroll)
            SeparatorFrame.Size = UDim2.new(1, -15, 0, 1)
            SeparatorFrame.BorderSizePixel = 0
            RegisterTheme(SeparatorFrame, { BackgroundColor3 = "Accent" })
            SeparatorFrame.BackgroundTransparency = 0.5
            
            local Spacer = Instance.new("Frame", TabScroll)
            Spacer.Size = UDim2.new(1, 0, 0, 4)
            Spacer.BackgroundTransparency = 1
        end

        local CatFrame = Instance.new("Frame", TabScroll)
        CatFrame.Size = UDim2.new(1, -10, 0, 24)
        CatFrame.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", CatFrame)
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = categoryName
        Label.TextXAlignment = Enum.TextXAlignment.Left
        RegisterTheme(Label, { TextColor3 = "TextDark" })
        RegisterFont(Label, true)
        RegisterText(Label, 14)
    end

    -- ========================================================
    -- [[ TAB CREATION METHOD ]]
    -- ========================================================
    function Window:CreateTab(tabName, iconInput, isPremium)
        local Tab = {
            Sections = {},
            Button = nil,
            Frame = nil
        }

        local TabPage = Instance.new("ScrollingFrame", ContentArea)
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 0
        TabPage.Visible = false

        local ColumnContainer = Instance.new("Frame", TabPage)
        ColumnContainer.Size = UDim2.new(1, -20, 1, 0)
        ColumnContainer.Position = UDim2.new(0, 10, 0, 10)
        ColumnContainer.BackgroundTransparency = 1

        local LeftColumn = Instance.new("Frame", ColumnContainer)
        LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
        LeftColumn.Position = UDim2.new(0, 0, 0, 0)
        LeftColumn.BackgroundTransparency = 1

        local LeftList = Instance.new("UIListLayout", LeftColumn)
        LeftList.Padding = UDim.new(0, 12)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder

        local RightColumn = Instance.new("Frame", ColumnContainer)
        RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        RightColumn.BackgroundTransparency = 1

        local RightList = Instance.new("UIListLayout", RightColumn)
        RightList.Padding = UDim.new(0, 12)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder

        local function ResizeCanvas()
            local leftHeight = LeftList.AbsoluteContentSize.Y
            local rightHeight = RightList.AbsoluteContentSize.Y
            local targetHeight = math.max(leftHeight, rightHeight) + 30
            TabPage.CanvasSize = UDim2.new(0, 0, 0, targetHeight)
            ColumnContainer.Size = UDim2.new(1, -20, 0, targetHeight)
        end
        Tab.ResizeCanvas = ResizeCanvas

        Janitor:Add(LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeCanvas))
        Janitor:Add(RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeCanvas))

        local TabBtn = Instance.new("TextButton", TabScroll)
        TabBtn.Size = UDim2.new(1, -10, 0, 32)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Name = "TabBtn"
        TabBtn.AutoButtonColor = false

        local TabBtnCorner = Instance.new("UICorner", TabBtn)
        TabBtnCorner.CornerRadius = UDim.new(0, 6)

        local TabBtnAccent = Instance.new("Frame", TabBtn)
        TabBtnAccent.Size = UDim2.new(0, 3, 0.6, 0)
        TabBtnAccent.Position = UDim2.new(1, -3, 0.2, 0)
        TabBtnAccent.BorderSizePixel = 0
        TabBtnAccent.BackgroundTransparency = 1
        RegisterTheme(TabBtnAccent, { BackgroundColor3 = "Accent" })

        local TabIcon = Instance.new("ImageLabel", TabBtn)
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, 12, 0.5, -8)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = GetIcon(iconInput)
        
        -- Uniform theme transition callback
        RegisterThemeCallback(function(color)
            if Window.ActiveTab == Tab then
                TweenService:Create(TabIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = color }):Play()
            else
                TabIcon.ImageColor3 = CurrentTheme.TextSecondary
            end
        end)

        local TabLabel = Instance.new("TextLabel", TabBtn)
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Position = UDim2.new(0, 35, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        RegisterTheme(TabLabel, { TextColor3 = "TextSecondary" })
        RegisterFont(TabLabel, false)
        RegisterText(TabLabel, 11)

        Tab.Button = TabBtn
        Tab.Frame = TabPage

        local function SelectTab()
            if Window.ActiveTab == Tab then return end
            
            if Window.ActiveTab then
                local prev = Window.ActiveTab
                prev.Frame.Visible = false
                TweenService:Create(prev.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(prev.Button:FindFirstChildOfClass("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(prev.Button:FindFirstChildOfClass("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = CurrentTheme.TextSecondary}):Play()
                TweenService:Create(prev.Button:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextSecondary}):Play()
            end

            Window.ActiveTab = Tab
            TabPage.Visible = true
            
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
            TweenService:Create(TabBtnAccent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = CurrentTheme.Accent}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextPrimary}):Play()
        end

        Janitor:Add(TabBtn.MouseButton1Click:Connect(SelectTab))

        Janitor:Add(TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                TweenService:Create(TabLabel, TweenInfo.new(0.15), {TextColor3 = CurrentTheme.TextPrimary}):Play()
                TweenService:Create(TabIcon, TweenInfo.new(0.15), {ImageColor3 = CurrentTheme.TextPrimary}):Play()
            end
        end))

        Janitor:Add(TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                TweenService:Create(TabLabel, TweenInfo.new(0.15), {TextColor3 = CurrentTheme.TextSecondary}):Play()
                TweenService:Create(TabIcon, TweenInfo.new(0.15), {ImageColor3 = CurrentTheme.TextSecondary}):Play()
            end
        end))

        -- PERBAIKAN LOGIKA: Masukkan ke Window.Tabs DULU sebelum memeriksa kondisinya!
        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            task.spawn(function()
                task.wait(0.1)
                SelectTab()
            end)
        end

        -- ========================================================
        -- [[ OVERLAY LOCK PREMIUM TAB TEMPLATE (STEP 2 & 11) ]]
        -- ========================================================
        local LockOverlay
        if isPremium then
            LockOverlay = Instance.new("Frame", TabPage)
            LockOverlay.Name = "Premium_Lock_Overlay"
            LockOverlay.Size = UDim2.new(1, 0, 1, 0)
            LockOverlay.Position = UDim2.new(0, 0, 0, 0)
            LockOverlay.BackgroundTransparency = 0.65 -- Exactly 65% transparency as requested
            LockOverlay.ZIndex = 99
            
            -- SAFE PREMIUM ENFORCEMENT: Menghalangi sentuhan mouse agar element di bawah tidak dapat diaktifkan [3]
            LockOverlay.Active = true 
            
            RegisterTheme(LockOverlay, { BackgroundColor3 = "WindowBg" })
            
            local LockCorner = Instance.new("UICorner", LockOverlay)
            LockCorner.CornerRadius = UDim.new(0, 8)
            
            local LockStroke = Instance.new("UIStroke", LockOverlay)
            LockStroke.Thickness = 1.5
            RegisterTheme(LockStroke, { Color = "Accent" })
            
            -- Ikon perisai (shield) tetap dipertahankan khusus untuk visual kunci frame premium [1]
            local LockIcon = Instance.new("ImageLabel", LockOverlay)
            LockIcon.Size = UDim2.new(0, 48, 0, 48)
            LockIcon.Position = UDim2.new(0.5, -24, 0.5, -34)
            LockIcon.BackgroundTransparency = 1
            LockIcon.Image = GetIcon("shield")
            RegisterTheme(LockIcon, { ImageColor3 = "Accent" })
            
            local LockText = Instance.new("TextLabel", LockOverlay)
            LockText.Size = UDim2.new(1, 0, 0, 20)
            LockText.Position = UDim2.new(0, 0, 0.5, 20)
            LockText.BackgroundTransparency = 1
            LockText.Text = "PREMIUM MEMBER ONLY"
            LockText.TextXAlignment = Enum.TextXAlignment.Center
            RegisterTheme(LockText, { TextColor3 = "TextPrimary" })
            RegisterFont(LockText, true)
            RegisterText(LockText, 12)
            
            -- API Method to unlock the premium tab directly from the loader
            function Tab:Unlock()
                if LockOverlay then
                    TweenService:Create(LockOverlay, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(LockIcon, TweenInfo.new(0.3), { ImageTransparency = 1 }):Play()
                    TweenService:Create(LockText, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
                    task.delay(0.3, function()
                        if LockOverlay then
                            LockOverlay:Destroy()
                            LockOverlay = nil
                        end
                    end)
                end
            end
        end

        -- ========================================================
        -- [[ SECTION CONTAINER CREATION ]]
        -- ========================================================
        function Tab:CreateSection(sectionName)
            local Section = { Collapsed = false }
            
            local targetColumn = LeftColumn
            if LeftList.AbsoluteContentSize.Y > RightList.AbsoluteContentSize.Y then
                targetColumn = RightColumn
            end

            local SecFrame = Instance.new("Frame", targetColumn)
            SecFrame.Size = UDim2.new(1, 0, 0, 40)
            SecFrame.ClipsDescendants = true
            RegisterTheme(SecFrame, { BackgroundColor3 = "SectionBg" })

            local SecCorner = Instance.new("UICorner", SecFrame)
            SecCorner.CornerRadius = UDim.new(0, 6)

            local SecStroke = Instance.new("UIStroke", SecFrame)
            SecStroke.Thickness = 1
            RegisterTheme(SecStroke, { Color = "StrokeColor" })

            local Header = Instance.new("Frame", SecFrame)
            Header.Size = UDim2.new(1, 0, 0, 34)
            Header.BackgroundTransparency = 1

            local Title = Instance.new("TextLabel", Header)
            Title.Size = UDim2.new(1, -40, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Text = sectionName
            Title.TextXAlignment = Enum.TextXAlignment.Left
            RegisterTheme(Title, { TextColor3 = "TextPrimary" })
            RegisterFont(Title, true)
            RegisterText(Title, 11)

            local ToggleIcon = Instance.new("ImageLabel", Header)
            ToggleIcon.Size = UDim2.new(0, 12, 0, 12)
            ToggleIcon.Position = UDim2.new(1, -24, 0.5, -6)
            ToggleIcon.BackgroundTransparency = 1
            ToggleIcon.Image = GetIcon("chevron-down")
            RegisterTheme(ToggleIcon, { ImageColor3 = "TextSecondary" })

            local Content = Instance.new("Frame", SecFrame)
            Content.Size = UDim2.new(1, 0, 1, -34)
            Content.Position = UDim2.new(0, 0, 0, 34)
            Content.BackgroundTransparency = 1

            local ContentList = Instance.new("UIListLayout", Content)
            ContentList.Padding = UDim.new(0, 10)
            ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder

            local function UpdateSectionSize()
                if not Section.Collapsed then
                    local contentHeight = ContentList.AbsoluteContentSize.Y
                    SecFrame.Size = UDim2.new(1, 0, 0, contentHeight + 46)
                end
            end

            Janitor:Add(ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize))

            local InsidePadding = Instance.new("UIPadding", Content)
            InsidePadding.PaddingLeft = UDim.new(0, 12)
            InsidePadding.PaddingRight = UDim.new(0, 12)
            InsidePadding.PaddingBottom = UDim.new(0, 12)

            -- ========================================================
            -- [[ ACCORDION COLLAPSE / EXPAND MECHANISM ]]
            -- ========================================================
            local HeaderBtn = Instance.new("TextButton", Header)
            HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""

            local function ToggleSection()
                Section.Collapsed = not Section.Collapsed
                local duration = 0.25
                local ease = Enum.EasingStyle.Quad
                
                if Section.Collapsed then
                    -- Animasi menciut: Elemen di dalam meluncur masuk secara halus ke dalam kepala [1]
                    local shrink = TweenService:Create(SecFrame, TweenInfo.new(duration, ease), { Size = UDim2.new(1, 0, 0, 34) })
                    shrink:Play()
                    TweenService:Create(ToggleIcon, TweenInfo.new(duration, ease), { Rotation = -90 }):Play()
                    
                    shrink.Completed:Connect(function()
                        if Section.Collapsed then
                            Content.Visible = false -- Sembunyikan HANYA setelah penciutan selesai
                        end
                    end)
                else
                    Content.Visible = true -- Langsung tampilkan sebelum memulai ekspansi
                    local contentHeight = ContentList.AbsoluteContentSize.Y
                    TweenService:Create(ToggleIcon, TweenInfo.new(duration, ease), { Rotation = 0 }):Play()
                    TweenService:Create(SecFrame, TweenInfo.new(duration, ease), { Size = UDim2.new(1, 0, 0, contentHeight + 46) }):Play()
                end
                
                -- Smooth canvas sizing during slide
                task.delay(duration, function()
                    ResizeCanvas()
                end)
            end

            Janitor:Add(HeaderBtn.MouseButton1Click:Connect(ToggleSection))
            Janitor:Add(SecFrame:GetPropertyChangedSignal("Size"):Connect(ResizeCanvas))

            -- ========================================================
            -- [[ SECTION ELEMENT: DYNAMIC TOGGLE ]]
            -- ========================================================
            function Section:CreateToggle(toggleText, defaultVal, flag, config, callback)
                local Toggle = { State = defaultVal or false }
                Library.Flags[flag] = Toggle.State

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 24)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -110, 1, 0)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleText
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })
                RegisterFont(Label, false)
                RegisterText(Label, 11)

                local InlineList = Instance.new("Frame", Elem)
                InlineList.Size = UDim2.new(0, 80, 1, 0)
                InlineList.Position = UDim2.new(1, -114, 0, 0)
                InlineList.BackgroundTransparency = 1

                local Layout = Instance.new("UIListLayout", InlineList)
                Layout.FillDirection = Enum.FillDirection.Horizontal
                Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                Layout.VerticalAlignment = Enum.VerticalAlignment.Center
                Layout.Padding = UDim.new(0, 6)

                if config then
                    -- Tombol Info Kustom untuk Menampilkan Modal Pop-up Interaktif
                    if config.info then
                        local InfoIcon = Instance.new("ImageButton", InlineList)
                        InfoIcon.Size = UDim2.new(0, 14, 0, 14)
                        InfoIcon.BackgroundTransparency = 1
                        InfoIcon.Image = GetIcon("info")
                        RegisterTheme(InfoIcon, { ImageColor3 = "TextDark" })
                        
                        -- Mengikat event pengetukan ikon ke jendela modal informasi
                        if typeof(config.info) == "string" then
                            Janitor:Add(InfoIcon.MouseButton1Click:Connect(function()
                                Library:ShowInfoModal(toggleText, config.info)
                            end))
                        end
                    end

                    if config.gear then
                        local GearIcon = Instance.new("ImageLabel", InlineList)
                        GearIcon.Size = UDim2.new(0, 14, 0, 14)
                        GearIcon.BackgroundTransparency = 1
                        GearIcon.Image = GetIcon("settings")
                        RegisterTheme(GearIcon, { ImageColor3 = "TextDark" })
                    end

                    if config.keybind then
                        local InlineBind = Instance.new("TextLabel", InlineList)
                        InlineBind.Size = UDim2.new(0, 18, 0, 18)
                        InlineBind.BackgroundTransparency = 0.5
                        InlineBind.Text = tostring(config.keybind)
                        
                        -- Sesuai perbaikan visual
                        InlineBind.TextXAlignment = Enum.TextXAlignment.Center
                        InlineBind.TextYAlignment = Enum.TextYAlignment.Center
                        
                        RegisterTheme(InlineBind, { TextColor3 = "TextSecondary", BackgroundColor3 = "SidebarBg" })
                        RegisterFont(InlineBind, true)
                        RegisterText(InlineBind, 9)
                        
                        local Border = Instance.new("UIStroke", InlineBind)
                        Border.Thickness = 1
                        RegisterTheme(Border, { Color = "StrokeColor" })
                        
                        local Corner = Instance.new("UICorner", InlineBind)
                        Corner.CornerRadius = UDim.new(0, 3)
                        
                        -- Auto trigger keybind on PC background keyboard inputs
                        local kbCode = typeof(config.keybind) == "string" and Enum.KeyCode[config.keybind] or config.keybind
                        if kbCode then
                            Janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
                                if processed then return end
                                if input.KeyCode == kbCode then
                                    SetState(not Toggle.State)
                                end
                            end))
                        end
                    end

                    -- DYNAMIC PIN SPARK SYSTEM (Pilihan Toggle Pembuat Tombol Melayang Eksternal)
                    if config.external then
                        local PinBtn = Instance.new("ImageButton", InlineList)
                        PinBtn.Size = UDim2.new(0, 14, 0, 14)
                        PinBtn.BackgroundTransparency = 1
                        PinBtn.Image = GetIcon("shield")
                        RegisterTheme(PinBtn, { ImageColor3 = "TextDark" })
                        
                        local pinActive = false
                        Janitor:Add(PinBtn.MouseButton1Click:Connect(function()
                            pinActive = not pinActive
                            if pinActive then
                                TweenService:Create(PinBtn, TweenInfo.new(0.2), { ImageColor3 = CurrentTheme.Accent }):Play()
                                Library:CreateExternalButton(toggleText, config.external.buttonType or "Toggle", Library.Settings.ExternalShape, flag .. "_Ext", function(state)
                                    pcall(function()
                                        local elemCtrl = Library.Registry[flag].Control
                                        elemCtrl:Set(state)
                                    end)
                                end)
                            else
                                TweenService:Create(PinBtn, TweenInfo.new(0.2), { ImageColor3 = CurrentTheme.TextDark }):Play()
                                Library:DestroyExternalButton(flag .. "_Ext")
                            end
                        end))
                    end
                end

                local Switch = Instance.new("TextButton", Elem)
                Switch.Size = UDim2.new(0, 26, 0, 14)
                Switch.Position = UDim2.new(1, -26, 0.5, -7)
                Switch.Text = ""
                Switch.AutoButtonColor = false
                RegisterTheme(Switch, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local SwitchStroke = Instance.new("UIStroke", Switch)
                SwitchStroke.Thickness = 1
                RegisterTheme(SwitchStroke, { Color = "StrokeColor" })

                local Ball = Instance.new("Frame", Switch)
                Ball.Size = UDim2.new(0, 10, 0, 10)
                Ball.Position = UDim2.new(0, 2, 0.5, -5)
                Ball.BorderSizePixel = 0
                RegisterTheme(Ball, { BackgroundColor3 = "TextDark" })
                Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

                local function SetState(state)
                    Toggle.State = state
                    Library.Flags[flag] = state
                    local dur = 0.15
                    if state then
                        TweenService:Create(Ball, TweenInfo.new(dur), {Position = UDim2.new(1, -12, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
                        TweenService:Create(Switch, TweenInfo.new(dur), {BackgroundColor3 = CurrentTheme.Accent}):Play()
                    else
                        TweenService:Create(Ball, TweenInfo.new(dur), {Position = UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = CurrentTheme.TextDark}):Play()
                        TweenService:Create(Switch, TweenInfo.new(dur), {BackgroundColor3 = CurrentTheme.ElementBg}):Play()
                    end
                    
                    -- Sinkronisasi status eksternal
                    if Library.ExternalButtons[flag .. "_Ext"] then
                        local extBtn = Library.ExternalButtons[flag .. "_Ext"]:FindFirstChildOfClass("TextButton")
                        local extStroke = Library.ExternalButtons[flag .. "_Ext"]:FindFirstChildOfClass("UIStroke")
                        if extBtn and extStroke then
                            if state then
                                TweenService:Create(extStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255) }):Play()
                                TweenService:Create(extBtn, TweenInfo.new(0.2), { TextColor3 = CurrentTheme.Accent }):Play()
                            else
                                TweenService:Create(extStroke, TweenInfo.new(0.2), { Color = CurrentTheme.Accent }):Play()
                                TweenService:Create(extBtn, TweenInfo.new(0.2), { TextColor3 = CurrentTheme.TextPrimary }):Play()
                            end
                        end
                    end
                    
                    if callback then task.spawn(callback, state) end
                end

                -- Smooth dynamic Accent Updates for Toggle Active states
                RegisterThemeCallback(function(color)
                    if Toggle.State then
                        TweenService:Create(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = color }):Play()
                    end
                end)

                Janitor:Add(Switch.MouseButton1Click:Connect(function() SetState(not Toggle.State) end))
                SetState(Toggle.State)

                local ctrl = {}
                function ctrl:Set(val) SetState(val) end
                Library.Registry[flag] = { Type = "Toggle", Control = ctrl }
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: KEYBIND (PC & MOBILE COMPATIBLE) ]]
            -- ========================================================
            function Section:CreateKeybind(bindText, defaultBind, flag, callback)
                local Keybind = { Value = defaultBind or Enum.KeyCode.E }
                Library.Flags[flag] = Keybind.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 24)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = bindText
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })
                RegisterFont(Label, false)
                RegisterText(Label, 11)

                -- TextBox ramah Mobile sehingga nama Keybind dapat diketik secara manual
                local BindBtn = Instance.new("TextBox", Elem)
                BindBtn.Size = UDim2.new(0, 46, 0, 18)
                BindBtn.Position = UDim2.new(1, -46, 0.5, -9)
                BindBtn.Text = Keybind.Value.Name
                BindBtn.ClearTextOnFocus = false
                RegisterTheme(BindBtn, { BackgroundColor3 = "ElementBg", TextColor3 = "TextSecondary" })
                Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 3)
                RegisterFont(BindBtn, true)
                RegisterText(BindBtn, 9)

                local Stroke = Instance.new("UIStroke", BindBtn)
                Stroke.Thickness = 1
                RegisterTheme(Stroke, { Color = "StrokeColor" })

                local listening = false

                Janitor:Add(BindBtn.Focused:Connect(function()
                    listening = true
                    BindBtn.Text = "..."
                end))

                -- Dukungan Pengisian Keybind via Fisik Keyboard PC
                Janitor:Add(UserInputService.InputBegan:Connect(function(input)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            BindBtn:ReleaseFocus()
                            
                            Keybind.Value = input.KeyCode
                            Library.Flags[flag] = input.KeyCode
                            BindBtn.Text = input.KeyCode.Name
                            if callback then task.spawn(callback, input.KeyCode) end
                        end
                    end
                end))

                -- Dukungan Pengisian Keybind via Virtual Keyboard Mobile (Menghindari Erors) [1]
                Janitor:Add(BindBtn.FocusLost:Connect(function()
                    if listening then
                        listening = false
                        local rawText = string.gsub(BindBtn.Text, "%s+", "")
                        local success, parsedCode = pcall(function()
                            return Enum.KeyCode[rawText]
                        end)
                        if success and parsedCode then
                            Keybind.Value = parsedCode
                            Library.Flags[flag] = parsedCode
                            BindBtn.Text = parsedCode.Name
                            if callback then task.spawn(callback, parsedCode) end
                        else
                            BindBtn.Text = Keybind.Value.Name
                        end
                    end
                end))

                local ctrl = {}
                function ctrl:Set(val)
                    if typeof(val) == "string" then
                        val = Enum.KeyCode[val]
                    end
                    Keybind.Value = val
                    Library.Flags[flag] = val
                    BindBtn.Text = val.Name
                end
                Library.Registry[flag] = { Type = "Keybind", Control = ctrl }
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: SLIDER + TEXTBOX INPUT ]]
            -- ========================================================
            function Section:CreateSlider(sliderText, minVal, maxVal, defaultVal, flag, callback)
                local Slider = { Value = defaultVal or minVal }
                Library.Flags[flag] = Slider.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 38)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -60, 0, 18)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = sliderText
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })
                RegisterFont(Label, false)
                RegisterText(Label, 11)

                local ValLabel = Instance.new("TextBox", Elem)
                ValLabel.Size = UDim2.new(0, 40, 0, 18)
                ValLabel.Position = UDim2.new(1, -40, 0, 0)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(Slider.Value)
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.ClearTextOnFocus = false
                RegisterTheme(ValLabel, { TextColor3 = "TextDark" })
                RegisterFont(ValLabel, false)
                RegisterText(ValLabel, 11)

                local SliderBg = Instance.new("TextButton", Elem)
                SliderBg.Size = UDim2.new(1, 0, 0, 4)
                SliderBg.Position = UDim2.new(0, 0, 1, -8)
                SliderBg.Text = ""
                SliderBg.AutoButtonColor = false
                RegisterTheme(SliderBg, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

                local SliderFill = Instance.new("Frame", SliderBg)
                SliderFill.Size = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 1, 0)
                SliderFill.BorderSizePixel = 0
                RegisterTheme(SliderFill, { BackgroundColor3 = "Accent" })
                Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

                local SliderKnob = Instance.new("Frame", SliderBg)
                SliderKnob.Size = UDim2.new(0, 10, 0, 10)
                SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderKnob.Position = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 0.5, 0)
                SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

                local function ApplyValue(val)
                    local clamped = math.clamp(val, minVal, maxVal)
                    Slider.Value = clamped
                    Library.Flags[flag] = clamped
                    ValLabel.Text = tostring(clamped)
                    
                    local percentage = (clamped - minVal) / (maxVal - minVal)
                    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(percentage, 0, 0.5, 0)
                    if callback then task.spawn(callback, clamped) end
                end

                local function UpdateSliderFromMouse(input)
                    local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    local rawVal = minVal + (percentage * (maxVal - minVal))
                    local finalVal = math.floor(rawVal + 0.5)
                    ApplyValue(finalVal)
                end

                local sliding = false
                Janitor:Add(SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        UpdateSliderFromMouse(input)
                    end
                end))

                Janitor:Add(UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSliderFromMouse(input)
                    end
                end))

                Janitor:Add(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end))

                Janitor:Add(ValLabel.FocusLost:Connect(function(enterPressed)
                    local num = tonumber(ValLabel.Text)
                    if num then
                        ApplyValue(num)
                    else
                        ValLabel.Text = tostring(Slider.Value)
                    end
                end))

                local ctrl = {}
                function ctrl:Set(val)
                    ApplyValue(val)
                end
                Library.Registry[flag] = { Type = "Slider", Control = ctrl }
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: SINGLE DROPDOWN ]]
            -- ========================================================
            function Section:CreateDropdown(ddText, options, defaultVal, flag, callback)
                local Dropdown = { Value = defaultVal or options[1], Open = false }
                Library.Flags[flag] = Dropdown.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 44)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = ddText
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })
                RegisterFont(Label, false)
                RegisterText(Label, 11)

                local Trigger = Instance.new("TextButton", Elem)
                Trigger.Size = UDim2.new(1, 0, 0, 24)
                Trigger.Position = UDim2.new(0, 0, 1, -24)
                Trigger.Text = ""
                Trigger.AutoButtonColor = false
                RegisterTheme(Trigger, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Trigger).CornerRadius = UDim.new(0, 4)
                local TriggerStroke = Instance.new("UIStroke", Trigger)
                TriggerStroke.Thickness = 1
                RegisterTheme(TriggerStroke, { Color = "StrokeColor" })

                local DisplayText = Instance.new("TextLabel", Trigger)
                DisplayText.Size = UDim2.new(1, -25, 1, 0)
                DisplayText.Position = UDim2.new(0, 10, 0, 0)
                DisplayText.BackgroundTransparency = 1
                DisplayText.Text = tostring(Dropdown.Value)
                DisplayText.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(DisplayText, { TextColor3 = "TextSecondary" })
                RegisterFont(DisplayText, false)
                RegisterText(DisplayText, 11)

                local Arrow = Instance.new("ImageLabel", Trigger)
                Arrow.Size = UDim2.new(0, 10, 0, 10)
                Arrow.Position = UDim2.new(1, -18, 0.5, -5)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = GetIcon("chevron-down")
                RegisterTheme(Arrow, { ImageColor3 = "TextSecondary" })

                local ListFrame = Instance.new("Frame", ScreenGui)
                ListFrame.Size = UDim2.new(0, 100, 0, 0)
                ListFrame.Visible = false
                RegisterTheme(ListFrame, { BackgroundColor3 = "SectionBg" })
                Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
                local Stroke = Instance.new("UIStroke", ListFrame)
                RegisterTheme(Stroke, { Color = "StrokeColor" })

                local ListScroll = Instance.new("ScrollingFrame", ListFrame)
                ListScroll.Size = UDim2.new(1, -4, 1, -4)
                ListScroll.Position = UDim2.new(0, 2, 0, 2)
                ListScroll.BackgroundTransparency = 1
                ListScroll.ScrollBarThickness = 2
                RegisterTheme(ListScroll, { ScrollBarImageColor3 = "Accent" })

                local ListLayout = Instance.new("UIListLayout", ListScroll)
                ListLayout.Padding = UDim.new(0, 3)

                local function PopulateOptions()
                    for _, child in ipairs(ListScroll:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for _, opt in ipairs(options) do
                        local OptBtn = Instance.new("TextButton", ListScroll)
                        OptBtn.Size = UDim2.new(1, 0, 0, 20)
                        OptBtn.BackgroundTransparency = 1
                        OptBtn.Text = tostring(opt)
                        RegisterTheme(OptBtn, { TextColor3 = (opt == Dropdown.Value and "Accent" or "TextSecondary") })
                        RegisterFont(OptBtn, false)
                        RegisterText(OptBtn, 10)

                        Janitor:Add(OptBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value = opt
                            Library.Flags[flag] = opt
                            DisplayText.Text = tostring(opt)
                            ListFrame.Visible = false
                            Dropdown.Open = false
                            if callback then task.spawn(callback, opt) end
                        end))
                    end
                end

                Trigger.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    if Dropdown.Open then
                        PopulateOptions()
                        ListFrame.Size = UDim2.new(0, Trigger.AbsoluteSize.X, 0, math.min(#options * 23 + 4, 100))
                        ListFrame.Position = UDim2.new(0, Trigger.AbsolutePosition.X, 0, Trigger.AbsolutePosition.Y + Trigger.AbsoluteSize.Y + 4)
                        ListScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 23)
                        ListFrame.Visible = true
                    else
                        ListFrame.Visible = false
                    end
                end)

                local ctrl = {}
                function ctrl:Set(val)
                    Dropdown.Value = val
                    DisplayText.Text = tostring(val)
                end
                function ctrl:Refresh(newOptions, defaultVal)
                    options = newOptions
                    Dropdown.Value = defaultVal or newOptions[1] or ""
                    DisplayText.Text = tostring(Dropdown.Value)
                    Library.Flags[flag] = Dropdown.Value
                end
                Library.Registry[flag] = { Type = "Dropdown", Control = ctrl }
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: MULTI-SELECT DROPDOWN ]]
            -- ========================================================
            function Section:CreateMultiDropdown(ddText, options, defaultTable, flag, callback)
                local Dropdown = { Selected = defaultTable or {}, Open = false }
                Library.Flags[flag] = Dropdown.Selected

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 44)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = ddText
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })
                RegisterFont(Label, false)
                RegisterText(Label, 11)

                local Trigger = Instance.new("TextButton", Elem)
                Trigger.Size = UDim2.new(1, 0, 0, 24)
                Trigger.Position = UDim2.new(0, 0, 1, -24)
                Trigger.Text = ""
                Trigger.AutoButtonColor = false
                RegisterTheme(Trigger, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Trigger).CornerRadius = UDim.new(0, 4)
                local TriggerStroke = Instance.new("UIStroke", Trigger)
                TriggerStroke.Thickness = 1
                RegisterTheme(TriggerStroke, { Color = "StrokeColor" })

                local DisplayText = Instance.new("TextLabel", Trigger)
                DisplayText.Size = UDim2.new(1, -25, 1, 0)
                DisplayText.Position = UDim2.new(0, 10, 0, 0)
                DisplayText.BackgroundTransparency = 1
                DisplayText.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(DisplayText, { TextColor3 = "TextSecondary" })
                RegisterFont(DisplayText, false)
                RegisterText(DisplayText, 11)

                local function UpdateDisplayText()
                    if #Dropdown.Selected == 0 then
                        DisplayText.Text = "None Selected"
                    else
                        DisplayText.Text = table.concat(Dropdown.Selected, ", ")
                    end
                end
                UpdateDisplayText()

                local Arrow = Instance.new("ImageLabel", Trigger)
                Arrow.Size = UDim2.new(0, 10, 0, 10)
                Arrow.Position = UDim2.new(1, -18, 0.5, -5)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = GetIcon("chevron-down")
                RegisterTheme(Arrow, { ImageColor3 = "TextSecondary" })

                local ListFrame = Instance.new("Frame", ScreenGui)
                ListFrame.Size = UDim2.new(0, 100, 0, 0)
                ListFrame.Visible = false
                RegisterTheme(ListFrame, { BackgroundColor3 = "SectionBg" })
                Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
                local Stroke = Instance.new("UIStroke", ListFrame)
                RegisterTheme(Stroke, { Color = "StrokeColor" })

                local ListScroll = Instance.new("ScrollingFrame", ListFrame)
                ListScroll.Size = UDim2.new(1, -4, 1, -4)
                ListScroll.Position = UDim2.new(0, 2, 0, 2)
                ListScroll.BackgroundTransparency = 1
                ListScroll.ScrollBarThickness = 2
                RegisterTheme(ListScroll, { ScrollBarImageColor3 = "Accent" })

                local ListLayout = Instance.new("UIListLayout", ListScroll)
                ListLayout.Padding = UDim.new(0, 3)

                local function PopulateOptions()
                    for _, child in ipairs(ListScroll:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for _, opt in ipairs(options) do
                        local isSelected = table.find(Dropdown.Selected, opt) ~= nil

                        local OptBtn = Instance.new("TextButton", ListScroll)
                        OptBtn.Size = UDim2.new(1, 0, 0, 20)
                        OptBtn.BackgroundTransparency = 1
                        OptBtn.Text = tostring(opt)
                        RegisterTheme(OptBtn, { TextColor3 = (isSelected and "Accent" or "TextSecondary") })
                        RegisterFont(OptBtn, false)
                        RegisterText(OptBtn, 10)

                        Janitor:Add(OptBtn.MouseButton1Click:Connect(function()
                            local index = table.find(Dropdown.Selected, opt)
                            if index then
                                table.remove(Dropdown.Selected, index)
                            else
                                table.insert(Dropdown.Selected, opt)
                            end
                            Library.Flags[flag] = Dropdown.Selected
                            UpdateDisplayText()
                            PopulateOptions()
                            if callback then task.spawn(callback, Dropdown.Selected) end
                        end))
                    end
                end

                Trigger.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    if Dropdown.Open then
                        PopulateOptions()
                        ListFrame.Size = UDim2.new(0, Trigger.AbsoluteSize.X, 0, math.min(#options * 23 + 4, 100))
                        ListFrame.Position = UDim2.new(0, Trigger.AbsolutePosition.X, 0, Trigger.AbsolutePosition.Y + Trigger.AbsoluteSize.Y + 4)
                        ListScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 23)
                        ListFrame.Visible = true
                    else
                        ListFrame.Visible = false
                    end
                end)

                local ctrl = {}
                function ctrl:Set(val)
                    Dropdown.Selected = val
                    UpdateDisplayText()
                end
                Library.Registry[flag] = { Type = "MultiDropdown", Control = ctrl }
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: COLOR PICKER + HEX INPUT ]]
            -- ========================================================
            function Section:CreateColorPicker(pickerText, defaultColor, flag, callback)
                local Picker = { Value = defaultColor or Color3.fromRGB(0, 255, 120) }
                Library.Flags[flag] = Picker.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 24)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -120, 1, 0)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = pickerText
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })
                RegisterFont(Label, false)
                RegisterText(Label, 11)

                -- Rounded square preview warna
                local Preview = Instance.new("TextButton", Elem)
                Preview.Size = UDim2.new(0, 16, 0, 16)
                Preview.Position = UDim2.new(1, -16, 0.5, -8)
                Preview.Text = ""
                Preview.BackgroundColor3 = Picker.Value
                Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

                -- TextBox Input Kode Hexadecimal (RGB)
                local HexInput = Instance.new("TextBox", Elem)
                HexInput.Size = UDim2.new(0, 60, 0, 18)
                HexInput.Position = UDim2.new(1, -82, 0.5, -9)
                HexInput.BackgroundTransparency = 0.5
                RegisterTheme(HexInput, { BackgroundColor3 = "SidebarBg", TextColor3 = "TextSecondary" })
                local HexStroke = Instance.new("UIStroke", HexInput)
                HexStroke.Thickness = 0.5
                RegisterTheme(HexStroke, { Color = "StrokeColor" })
                Instance.new("UICorner", HexInput).CornerRadius = UDim.new(0, 3)
                HexInput.Text = Color3ToHex(Picker.Value)
                HexInput.ClearTextOnFocus = false
                RegisterFont(HexInput, false)
                RegisterText(HexInput, 9)

                local function ApplyColor(color)
                    Picker.Value = color
                    Library.Flags[flag] = color
                    Preview.BackgroundColor3 = color
                    HexInput.Text = Color3ToHex(color)
                    if callback then task.spawn(callback, color) end
                end

                Janitor:Add(Preview.MouseButton1Click:Connect(function()
                    local randomColor = Color3.fromHSV(math.random(), 1, 1)
                    ApplyColor(randomColor)
                end))

                Janitor:Add(HexInput.FocusLost:Connect(function()
                    local parsedColor = HexToColor3(HexInput.Text)
                    if parsedColor then
                        ApplyColor(parsedColor)
                    else
                        HexInput.Text = Color3ToHex(Picker.Value)
                    end
                end))

                local ctrl = {}
                function ctrl:Set(val)
                    ApplyColor(val)
                end
                Library.Registry[flag] = { Type = "ColorPicker", Control = ctrl }
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: BUTTON ]]
            -- ========================================================
            function Section:CreateButton(btnText, config, callback)
                local realCallback = callback
                local realConfig = config
                if typeof(config) == "function" then
                    realCallback = config
                    realConfig = nil
                end

                local Btn = Instance.new("TextButton", Content)
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.Text = btnText
                Btn.AutoButtonColor = false
                RegisterTheme(Btn, { BackgroundColor3 = "Accent", TextColor3 = "WindowBg" })
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                RegisterFont(Btn, true)
                RegisterText(Btn, 11)

                -- DYNAMIC PIN SPARK SYSTEM (Pilihan Pin Tombol Melayang Eksternal)
                if realConfig and realConfig.external then
                    local InlineList = Instance.new("Frame", Btn)
                    InlineList.Size = UDim2.new(0, 20, 1, 0)
                    InlineList.Position = UDim2.new(1, -26, 0, 0)
                    InlineList.BackgroundTransparency = 1

                    local Layout = Instance.new("UIListLayout", InlineList)
                    Layout.FillDirection = Enum.FillDirection.Horizontal
                    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    Layout.VerticalAlignment = Enum.VerticalAlignment.Center

                    local PinBtn = Instance.new("ImageButton", InlineList)
                    PinBtn.Size = UDim2.new(0, 14, 0, 14)
                    PinBtn.BackgroundTransparency = 1
                    PinBtn.Image = GetIcon("shield")
                    RegisterTheme(PinBtn, { ImageColor3 = "TextDark" })
                    
                    local pinActive = false
                    Janitor:Add(PinBtn.MouseButton1Click:Connect(function()
                        pinActive = not pinActive
                        if pinActive then
                            TweenService:Create(PinBtn, TweenInfo.new(0.2), { ImageColor3 = CurrentTheme.Accent }):Play()
                            Library:CreateExternalButton(btnText, realConfig.external.buttonType or "Click", Library.Settings.ExternalShape, btnText .. "_Ext", function()
                                if realCallback then task.spawn(realCallback) end
                            end)
                        else
                            TweenService:Create(PinBtn, TweenInfo.new(0.2), { ImageColor3 = CurrentTheme.TextDark }):Play()
                            Library:DestroyExternalButton(btnText .. "_Ext")
                        end
                    end))
                end

                -- Uniform button theme animation callback
                RegisterThemeCallback(function(color)
                    TweenService:Create(Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = color }):Play()
                end)

                Janitor:Add(Btn.MouseButton1Click:Connect(function()
                    if realCallback then task.spawn(realCallback) end
                end))
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: PARAGRAPH ]]
            -- ========================================================
            function Section:CreateParagraph(paraTitle, paraDesc)
                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 50)
                Elem.BackgroundTransparency = 1

                local Title = Instance.new("TextLabel", Elem)
                Title.Size = UDim2.new(1, 0, 0, 16)
                Title.BackgroundTransparency = 1
                Title.Text = paraTitle or "Paragraph"
                Title.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Title, { TextColor3 = "TextPrimary" })
                RegisterFont(Title, true)
                RegisterText(Title, 11)

                local Desc = Instance.new("TextLabel", Elem)
                Desc.Size = UDim2.new(1, 0, 1, -16)
                Desc.Position = UDim2.new(0, 0, 0, 16)
                Desc.BackgroundTransparency = 1
                Desc.Text = paraDesc or "Description"
                Desc.TextWrapped = true
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Desc, { TextColor3 = "TextSecondary" })
                RegisterFont(Desc, false)
                RegisterText(Desc, 10)

                local function ResizeParagraph()
                    local constraintSize = Vector2.new(Content.AbsoluteSize.X - 20, 1000)
                    local textBounds = TextService:GetTextSize(paraDesc, 10, Library.Settings.Font, constraintSize)
                    Elem.Size = UDim2.new(1, 0, 0, textBounds.Y + 22)
                end
                
                Janitor:Add(Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeParagraph))
                ResizeParagraph()

                -- Mengembalikan objek pengontrol paragraf yang valid dengan metode Set terpusat
                local ctrl = {}
                function ctrl:Set(val)
                    paraDesc = val
                    Desc.Text = val
                    ResizeParagraph()
                end
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: TEXTBOX (NO ELLIPSIS TRUNCATION) ]]
            -- ========================================================
            function Section:CreateTextBox(labelText, placeholderText, flag, callback)
                local TextBoxElem = Instance.new("Frame", Content)
                TextBoxElem.Size = UDim2.new(1, 0, 0, 44)
                TextBoxElem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", TextBoxElem)
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.BackgroundTransparency = 1
                Label.Text = labelText
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })
                RegisterFont(Label, false)
                RegisterText(Label, 11)

                local InputBox = Instance.new("TextBox", TextBoxElem)
                InputBox.Size = UDim2.new(1, 0, 0, 24)
                InputBox.Position = UDim2.new(0, 0, 1, -24)
                InputBox.PlaceholderText = placeholderText or "Type here..."
                InputBox.Text = ""
                InputBox.ClearTextOnFocus = false
                
                -- Sesuai perbaikan visual input teks tanpa titik-titik (...)
                InputBox.TextWrapped = false
                InputBox.TextTruncate = Enum.TextTruncate.None
                InputBox.ClipsDescendants = true
                
                RegisterTheme(InputBox, { BackgroundColor3 = "ElementBg", TextColor3 = "TextPrimary" })
                Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)
                
                local Stroke = Instance.new("UIStroke", InputBox)
                Stroke.Thickness = 1
                RegisterTheme(Stroke, { Color = "StrokeColor" })
                
                RegisterFont(InputBox, false)
                RegisterText(InputBox, 11)

                Janitor:Add(InputBox.FocusLost:Connect(function(enterPressed)
                    Library.Flags[flag] = InputBox.Text
                    if callback then task.spawn(callback, InputBox.Text) end
                end))

                local ctrl = {}
                function ctrl:Set(val)
                    InputBox.Text = tostring(val)
                    Library.Flags[flag] = val
                end
                Library.Registry[flag] = { Type = "TextBox", Control = ctrl }
                return ctrl
            end

            table.insert(Tab.Sections, Section)
            return Section
        end

        return Tab
    end

    -- ========================================================
    -- [[ 6. AUTOMATIC EMBEDDED CONFIG & PREFERENCES TAB ]]
    -- ========================================================
    task.spawn(function()
        task.wait(0.05)

        -- Serialisasi Tabel Luau Kompleks
        local function serializeTable(val)
            if typeof(val) == "string" then
                return string.format("%q", val)
            elseif typeof(val) == "number" or typeof(val) == "boolean" then
                return tostring(val)
            elseif typeof(val) == "table" then
                local str = "{\n"
                for k, v in pairs(val) do
                    str = str .. string.format("  [%s] = %s,\n", serializeTable(k), serializeTable(v))
                end
                str = str .. "}"
                return str
            end
            return "nil"
        end

        -- Pembacaan Konfigurasi Lua format return table
        local function LoadLuaConfig(path)
            local content = readfile(path)
            local func, err = loadstring(content)
            if func then
                local success, tbl = pcall(func)
                if success and typeof(tbl) == "table" then
                    return tbl
                end
            end
            return nil
        end

        local function SaveConfig(configName, format)
            if not isFolderSupported then return end
            format = format or "JSON"
            
            local dataToSave = {}
            for flag, value in pairs(Library.Flags) do
                if not string.match(flag, "^Sys_") and not string.match(flag, "^BuiltIn_") then
                    if typeof(value) == "Color3" then
                        dataToSave[flag] = {math.floor(value.R * 255 + 0.5), math.floor(value.G * 255 + 0.5), math.floor(value.B * 255 + 0.5)}
                    elseif typeof(value) == "EnumItem" then
                        dataToSave[flag] = tostring(value)
                    else
                        dataToSave[flag] = value
                    end
                end
            end
            
            local path = ConfigFolder .. "/" .. configName
            if format == "LUA" then
                local serialized = "return " .. serializeTable(dataToSave)
                writefile(path .. ".lua", serialized)
            else
                local encoded = HttpService:JSONEncode(dataToSave)
                writefile(path .. ".json", encoded)
            end
            
            Library:CreateNotification("Config Saved", "Successfully saved configuration: " .. configName, 3)
        end

        local function LoadConfig(configName)
            if not isFolderSupported then return end
            local luaPath = ConfigFolder .. "/" .. configName .. ".lua"
            local jsonPath = ConfigFolder .. "/" .. configName .. ".json"
            local loadedData = nil
            
            if isfile(luaPath) then
                loadedData = LoadLuaConfig(luaPath)
            elseif isfile(jsonPath) then
                local data = readfile(jsonPath)
                local success, decoded = pcall(function() return HttpService:JSONDecode(data) end)
                if success then loadedData = decoded end
            end
            
            if loadedData and typeof(loadedData) == "table" then
                for flag, value in pairs(loadedData) do
                    if Library.Registry[flag] then
                        pcall(function()
                            if Library.Registry[flag].Type == "ColorPicker" and typeof(value) == "table" then
                                local r, g, b = value[1], value[2], value[3]
                                Library.Registry[flag].Control:Set(Color3.fromRGB(r, g, b))
                            else
                                Library.Registry[flag].Control:Set(value)
                            end
                        end)
                    end
                end
                Library:CreateNotification("Config Loaded", "Successfully applied configuration: " .. configName, 3)
            end
        end

        local function DeleteConfig(configName)
            if not isFolderSupported then return end
            local luaPath = ConfigFolder .. "/" .. configName .. ".lua"
            local jsonPath = ConfigFolder .. "/" .. configName .. ".json"
            if isfile(luaPath) then delfile(luaPath) end
            if isfile(jsonPath) then delfile(jsonPath) end
            Library:CreateNotification("Config Deleted", "Successfully deleted configuration: " .. configName, 3)
        end

        local function GetConfigsList()
            local list = {}
            if listfiles and isfolder and isfolder(ConfigFolder) then
                local files = listfiles(ConfigFolder)
                for _, file in ipairs(files) do
                    local name = string.match(file, "([^/]+)%.[jJ][sS][oO][nN]$") or string.match(file, "([^/]+)%.[lL][uU][aA]$")
                    if name and not table.find(list, name) then
                        table.insert(list, name)
                    end
                end
            end
            if #list == 0 then
                table.insert(list, "No Configs Found")
            end
            return list
        end

        -- Automatically create UI Settings category
        Window:CreateCategory("UI Settings")
        
        -- Built-in preferences tab ("Setting")
        local BuiltInTab = Window:CreateTab("Setting", "gear")
        
        local ConfigSec = BuiltInTab:CreateSection("Layout Preferences")
        ConfigSec:CreateDropdown("Layout Mode", {"PC", "Mobile"}, Library.Settings.Mode, "BuiltIn_Mode", function(mode)
            ApplyUiSettings(mode, Library.Settings.Scale)
            Library:CreateNotification("Layout Updated", "UI layout set to " .. mode .. " mode.", 4)
        end)
        
        ConfigSec:CreateSlider("UI Scale", 50, 150, math.floor(Library.Settings.Scale * 100), "BuiltIn_Scale", function(scalePerc)
            ApplyUiSettings(Library.Settings.Mode, scalePerc / 100)
        end)
        
        -- Toggle ON/OFF untuk menampilkan/menyembunyikan Floating Performance HUD
        ConfigSec:CreateToggle("Performance HUD", false, "BuiltIn_ShowHUD", {}, function(state)
            HudFrame.Visible = state
        end)

        -- Kunci Posisi Seret UI Serempak
        ConfigSec:CreateToggle("Lock UI Dragging", false, "BuiltIn_LockDrag", {}, function(state)
            Library.Settings.DragLocked = state
        end)

        -- Pemilihan Bentuk Tombol Eksternal di UI secara Dinamis
        ConfigSec:CreateDropdown("External Button Shape", {"Round", "Circle", "Sharp"}, Library.Settings.ExternalShape, "BuiltIn_ExternalShape", function(val)
            Library.Settings.ExternalShape = val
            for flag, btnFrame in pairs(Library.ExternalButtons) do
                local extCorner = btnFrame:FindFirstChildOfClass("UICorner")
                if extCorner then
                    if val == "Circle" then
                        extCorner.CornerRadius = UDim.new(1, 0)
                    elseif val == "Round" then
                        extCorner.CornerRadius = UDim.new(0, 8)
                    else
                        extCorner.CornerRadius = UDim.new(0, 0)
                    end
                end
            end
        end)

        -- Ikon emoji info ℹ kustom
        ConfigSec:CreateParagraph("ℹ Shape Preferences", "The External Button Shape preferences determine the visual corner geometry of floating action keypads spawned on your screen.")

        local ThemeSec = BuiltInTab:CreateSection("Theme & Typography")
        ThemeSec:CreateSlider("Text Size", 80, 150, math.floor(Library.Settings.TextSizeMultiplier * 100), "BuiltIn_Text", function(sizePerc)
            UpdateTextSizes(sizePerc / 100)
        end)

        -- RGB Theme Accent Color Picker dengan dukungan Hex (Tembus langsung merubah semua elemen aksen cyan)
        ThemeSec:CreateColorPicker("Accent Color", CurrentTheme.Accent, "BuiltIn_AccentColor", function(color)
            CurrentTheme.Accent = color
            for _, item in ipairs(Library.ThemeRegistry) do
                for prop, key in pairs(item.Properties) do
                    if key == "Accent" then
                        pcall(function()
                            TweenService:Create(item.Instance, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { [prop] = color }):Play()
                        end)
                    end
                end
            end
            -- Instantly update selected tab icon color
            if Window.ActiveTab then
                local icon = Window.ActiveTab.Button:FindFirstChildOfClass("ImageLabel")
                if icon then
                    TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = color }):Play()
                end
            end
            -- Execute theme callbacks for dynamic toggle states
            for _, cb in ipairs(Library.ThemeCallbacks) do
                pcall(cb, color)
            end
        end)

        -- PREMIUM DIAGNOSTICS SECTION (DEVELOPER TOOLS)
        local DiagnosticSec = BuiltInTab:CreateSection("Diagnostics")
        local fpsLabel = DiagnosticSec:CreateParagraph("Performance Stats", "FPS: Calculating...\nPing: Calculating...\nMemory: Calculating...")
        
        local fpsCount = 0
        local lastTime = os.clock()
        local currentFps = 60
        local pingVal = 0

        Janitor:Add(RunService.RenderStepped:Connect(function()
            fpsCount = fpsCount + 1
            local now = os.clock()
            if now - lastTime >= 1 then
                currentFps = fpsCount
                fpsCount = 0
                lastTime = now
            end
        end))

        -- Safe diagnostics loop (Real Ping and Framerate updating) [1]
        task.spawn(function()
            while task.wait(1) do
                pcall(function()
                    pingVal = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
                end)
                local memoryUsage = string.format("%.2f MB", collectgarbage("count") / 1024)
                pcall(function()
                    fpsLabel:Set("FPS: " .. tostring(currentFps) .. "\nPing: " .. tostring(pingVal) .. " ms\nMemory Estimate: " .. memoryUsage)
                    HudText.Text = "FPS: " .. tostring(currentFps) .. " | Ping: " .. tostring(pingVal) .. " ms"
                end)
            end
        end)

        local ActionSec = BuiltInTab:CreateSection("Emergency Actions")
        ActionSec:CreateButton("Destroy UI", function()
            ScreenGui:Destroy()
        end)

        -- Built-in File Manager Tab (Ikon Folder)
        local ConfigManagerTab = Window:CreateTab("Configs", "folder")
        
        local SaveSec = ConfigManagerTab:CreateSection("Save Configuration")
        SaveSec:CreateTextBox("Config Name", "Enter name...", "Sys_Save_Name")
        SaveSec:CreateDropdown("Save Format", {"JSON", "LUA"}, "JSON", "Sys_Save_Format")
        
        local configDropdown

        SaveSec:CreateButton("Save Configuration", function()
            local name = Library.Flags["Sys_Save_Name"]
            local format = Library.Flags["Sys_Save_Format"] or "JSON"
            if name and name ~= "" and name ~= "Enter name..." then
                SaveConfig(name, format)
                if configDropdown then
                    local newList = GetConfigsList()
                    configDropdown:Refresh(newList, name)
                end
            end
        end)

        local ManageSec = ConfigManagerTab:CreateSection("File Manager")
        
        local initialList = GetConfigsList()
        configDropdown = ManageSec:CreateDropdown("Select File", initialList, initialList[1], "Sys_Selected_File")
        
        ManageSec:CreateButton("Load Selected Config", function()
            local selected = Library.Flags["Sys_Selected_File"]
            if selected and selected ~= "No Configs Found" then
                LoadConfig(selected)
            end
        end)

        ManageSec:CreateButton("Delete Selected Config", function()
            local selected = Library.Flags["Sys_Selected_File"]
            if selected and selected ~= "No Configs Found" then
                DeleteConfig(selected)
                local newList = GetConfigsList()
                configDropdown:Refresh(newList, newList[1])
            end
        end)

        ManageSec:CreateButton("Refresh File List", function()
            local newList = GetConfigsList()
            configDropdown:Refresh(newList, newList[1])
        end)
        
        -- EXPORT/IMPORT STRINGS FOR EASY SHARE (CLIPBOARD)
        local ShareSec = ConfigManagerTab:CreateSection("Share Config Codes")
        ShareSec:CreateTextBox("Config Share Code", "Paste code here to import, or copy exported code...", "Sys_Share_Code")
        
        ShareSec:CreateButton("Export Current Config Code", function()
            local dataToSave = {}
            for flag, value in pairs(Library.Flags) do
                if not string.match(flag, "^Sys_") and not string.match(flag, "^BuiltIn_") then
                    if typeof(value) == "Color3" then
                        dataToSave[flag] = {math.floor(value.R * 255 + 0.5), math.floor(value.G * 255 + 0.5), math.floor(value.B * 255 + 0.5)}
                    elseif typeof(value) == "EnumItem" then
                        dataToSave[flag] = tostring(value)
                    else
                        dataToSave[flag] = value
                    end
                end
            end
            local encoded = HttpService:JSONEncode(dataToSave)
            setclipboard(encoded)
            Library:CreateNotification("Config Exported", "Configuration copied to clipboard as share code!", 3)
        end)
        
        ShareSec:CreateButton("Import Shared Code", function()
            local rawCode = Library.Flags["Sys_Share_Code"]
            if rawCode and rawCode ~= "" then
                local success, decoded = pcall(function() return HttpService:JSONDecode(rawCode) end)
                if success and typeof(decoded) == "table" then
                    for flag, value in pairs(decoded) do
                        if Library.Registry[flag] then
                            pcall(function()
                                if Library.Registry[flag].Type == "ColorPicker" and typeof(value) == "table" then
                                    local r, g, b = value[1], value[2], value[3]
                                    Library.Registry[flag].Control:Set(Color3.fromRGB(r, g, b))
                                else
                                    Library.Registry[flag].Control:Set(value)
                                end
                            end)
                        end
                    end
                    Library:CreateNotification("Import Success", "Configuration successfully imported from share code!", 3)
                else
                    Library:CreateNotification("Import Failed", "Invalid share code format.", 3)
                end
            end
        end)
    end)

    -- ========================================================
    -- [[ MOBILE FLOATING TOGGLE ICON ]]
    -- ========================================================
    local FloatingToggle = Instance.new("TextButton", ScreenGui)
    FloatingToggle.Name = "Nexus_Floating_Toggler"
    FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
    FloatingToggle.Position = UDim2.new(0, 20, 0.5, -24)
    FloatingToggle.BorderSizePixel = 0
    FloatingToggle.Text = ""
    FloatingToggle.Visible = true -- Tampil dari awal (sebelum UI muncul)
    FloatingToggle.ClipsDescendants = true
    RegisterTheme(FloatingToggle, { BackgroundColor3 = "SidebarBg" })

    -- Ikon melayang berbentuk squircle tumpul modern
    local ToggleCorner = Instance.new("UICorner", FloatingToggle)
    ToggleCorner.CornerRadius = UDim.new(0, 12)

    local ToggleStroke = Instance.new("UIStroke", FloatingToggle)
    ToggleStroke.Thickness = 1.5
    RegisterTheme(ToggleStroke, { Color = "Accent" })

    local ToggleIconImage = Instance.new("ImageLabel", FloatingToggle)
    -- Logo kustom diperbesar rasionya di dalam tombol tanpa merubah ukuran bingkai tombol melayang (0.85)
    ToggleIconImage.Size = UDim2.new(0.85, 0, 0.85, 0)
    ToggleIconImage.Position = UDim2.new(0.075, 0, 0.075, 0)
    ToggleIconImage.BackgroundTransparency = 1
    -- Memuat decal kustom kustom Anda dengan rbxthumb (Warna asli penuh tanpa tint)
    ToggleIconImage.Image = FLOATING_ICON_DECAL

    MakeDraggable(FloatingToggle, FloatingToggle)

    -- Simpan Ukuran Target Dimensi UI Asli untuk Animasi agar Tidak Mengecil ke 0,0,0,0 Permanen
    local TargetSize = UDim2.new(0, 640, 0, 460)
    local TargetPosition = UDim2.new(0.5, -320, 0.5, -230)

    local function ToggleGui()
        Window.Visible = not Window.Visible
        
        -- Sesuaikan Target Ukuran Sebelum Dimulai Animasi
        if Library.Settings.Mode == "PC" then
            TargetSize = UDim2.new(0, 640, 0, 460)
            TargetPosition = UDim2.new(0.5, -320, 0.5, -230)
        else
            TargetSize = UDim2.new(0, 500, 0, 340)
            TargetPosition = UDim2.new(0.5, -250, 0.5, -170)
        end

        if Window.Visible then
            MainFrame.Visible = true
            -- Set ukuran ke 0 terlebih dahulu di tengah layar sebelum pop-out dimulai
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = TargetSize, Position = TargetPosition}):Play()
            -- Ikon melayang mengecil/hilang ketika UI dibuka (seperti sistem toggle aslinya)
            TweenService:Create(FloatingToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        else
            local shrink = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
            shrink:Play()
            shrink.Completed:Connect(function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
            
            -- Ikon melayang muncul kembali ketika UI ditutup
            TweenService:Create(FloatingToggle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()
        end
    end

    FloatingToggle.MouseButton1Click:Connect(ToggleGui)

    -- Logo Utama Pojok Kiri Atas diperbesar (32x32) dan mengikat fungsi minimize UI kustom Anda
    local LogoIcon = Instance.new("ImageButton", LogoArea)
    LogoIcon.Size = UDim2.new(0, 32, 0, 32)
    LogoIcon.Position = UDim2.new(0, 12, 0.5, -16)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = FLOATING_ICON_DECAL

    Janitor:Add(LogoIcon.MouseButton1Click:Connect(function()
        ToggleGui() -- Klik Logo LouisHub untuk me-minimize UI utama dan memunculkan floating icon kembali [1]
    end))

    Janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            ToggleGui()
        end
    end))

    -- Welcome Notification yang otomatis berbunyi/muncul saat inisialisasi CreateWindow
    task.spawn(function()
        task.wait(0.2)
        Library:CreateNotification("Welcome to LouisHub", "UI Framework executed successfully. Press Insert to minimize.", 5)
    end)

    -- ========================================================
    -- [[ BACKEND: INTERACTIVE MODAL DIALOG MANAGER ]]
    -- ========================================================
    function Library:ShowInfoModal(infoTitle, infoText)
        local oldModal = ScreenGui:FindFirstChild("Nexus_Info_Modal")
        if oldModal then oldModal:Destroy() end
        
        local oldOverlay = ScreenGui:FindFirstChild("Nexus_Modal_Overlay")
        if oldOverlay then oldOverlay:Destroy() end
        
        -- Lapisan Latar Belakang Gelap Transparan Premium
        local Overlay = Instance.new("TextButton", ScreenGui)
        Overlay.Name = "Nexus_Modal_Overlay"
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundTransparency = 1
        Overlay.BackgroundColor3 = Color3.fromRGB(10, 12, 15)
        Overlay.Text = ""
        Overlay.ZIndex = 99
        
        local ModalFrame = Instance.new("Frame", ScreenGui)
        ModalFrame.Name = "Nexus_Info_Modal"
        ModalFrame.BackgroundTransparency = 0.1
        ModalFrame.ZIndex = 100
        RegisterTheme(ModalFrame, { BackgroundColor3 = "SidebarBg" })
        
        local Corner = Instance.new("UICorner", ModalFrame)
        Corner.CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke", ModalFrame)
        Stroke.Thickness = 1.5
        RegisterTheme(Stroke, { Color = "Accent" })
        
        local Title = Instance.new("TextLabel", ModalFrame)
        Title.Size = UDim2.new(1, -40, 0, 30)
        Title.Position = UDim2.new(0, 15, 0, 10)
        Title.BackgroundTransparency = 1
        Title.Text = infoTitle or "Information"
        Title.TextXAlignment = Enum.TextXAlignment.Left
        RegisterTheme(Title, { TextColor3 = "TextPrimary" })
        RegisterFont(Title, true)
        RegisterText(Title, 13)
        
        local Desc = Instance.new("TextLabel", ModalFrame)
        Desc.Size = UDim2.new(1, -30, 1, -80)
        Desc.Position = UDim2.new(0, 15, 0, 45)
        Desc.BackgroundTransparency = 1
        Desc.Text = infoText or "No detailed description provided."
        Desc.TextWrapped = true
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextYAlignment = Enum.TextYAlignment.Top
        RegisterTheme(Desc, { TextColor3 = "TextSecondary" })
        RegisterFont(Desc, false)
        RegisterText(Desc, 11)
        
        local CloseBtn = Instance.new("TextButton", ModalFrame)
        CloseBtn.Size = UDim2.new(0, 80, 0, 26)
        CloseBtn.Position = UDim2.new(0.5, -40, 1, -36)
        CloseBtn.Text = "Close"
        CloseBtn.AutoButtonColor = false
        RegisterTheme(CloseBtn, { BackgroundColor3 = "Accent", TextColor3 = "WindowBg" })
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
        RegisterFont(CloseBtn, true)
        RegisterText(CloseBtn, 11)
        
        local function CloseModal()
            TweenService:Create(ModalFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
            local fade = TweenService:Create(Overlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
            fade:Play()
            fade.Completed:Connect(function()
                ModalFrame:Destroy()
                Overlay:Destroy()
            end)
        end
        
        CloseBtn.MouseButton1Click:Connect(CloseModal)
        Overlay.MouseButton1Click:Connect(CloseModal)
        
        -- Animasi Pembesaran Skala Melenting yang Premium
        ModalFrame.Size = UDim2.new(0, 0, 0, 0)
        ModalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(ModalFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 320, 0, 180), Position = UDim2.new(0.5, -160, 0.5, -90) }):Play()
        TweenService:Create(Overlay, TweenInfo.new(0.25), { BackgroundTransparency = 0.6 }):Play()
    end

    return Window
end

return Library
