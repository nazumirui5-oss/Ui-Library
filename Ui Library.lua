local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ========================================================
-- [[ 0. CONFIGURATION & ENGINE SYNCHRONIZATION ]]
-- ========================================================
Library.Flags = {}
Library.Elements = {}
Library.ExternalButtons = {} 
Library.LoadedConfigCache = {} 

-- Registrasi Objek untuk Sistem Tema Dinamis
Library.ThemeElements = {
    Background = {},
    Container = {},
    Element = {},
    Stroke = {},
    Text = {},
    TextMuted = {},
    Accent = {}
}
Library.ThemeRefreshCallbacks = {}

local PlaceId = game.PlaceId
local SettingsFileName = "LouisHub_UI_Settings_" .. tostring(PlaceId) .. ".json"
local CurrentProfile = "Profile 1"
local AutoLoadEnabled = false
Library.CurrentThemeName = "RGB" -- Tema default saat pertama kali dijalankan

-- ========================================================
-- [[ 0a. THEME PALETTE DEFINITIONS ]]
-- ========================================================
local Themes = {
    ["RGB"] = {
        Background = Color3.fromRGB(15, 15, 18),
        Container = Color3.fromRGB(18, 18, 22),
        Element = Color3.fromRGB(22, 22, 26),
        ElementHover = Color3.fromRGB(28, 28, 33),
        ElementPress = Color3.fromRGB(35, 35, 42),
        Text = Color3.fromRGB(210, 210, 210),
        TextMuted = Color3.fromRGB(130, 130, 140),
        Stroke = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(255, 255, 255),
        IsRGB = true
    },
    ["Cute Pastel"] = {
        Background = Color3.fromRGB(248, 231, 238),     -- Soft Pastel Pink (Match Gambar)
        Container = Color3.fromRGB(255, 255, 255),      -- Clean White
        Element = Color3.fromRGB(224, 242, 254),        -- Soft Sky Blue (Match Rambut Miku)
        ElementHover = Color3.fromRGB(186, 230, 253),   -- Hover Sky Blue
        ElementPress = Color3.fromRGB(125, 211, 252),   -- Active Sky Blue
        Text = Color3.fromRGB(90, 85, 110),             -- Sweet Dark Slate (Muted Dark)
        TextMuted = Color3.fromRGB(160, 150, 165),       -- Muted Dust Pink
        Stroke = Color3.fromRGB(255, 180, 210),         -- Candy Pink Outer Stroke
        Accent = Color3.fromRGB(120, 215, 240),         -- Highlight Sweet Cyan
        IsRGB = false
    }
}

-- Registry Helper untuk Menempelkan Tema ke Instance Baru
local function RegTheme(instance, category)
    table.insert(Library.ThemeElements[category], instance)
    Library:ApplyThemeToInstance(instance, category)
end

-- Penerap Properti Warna Berdasarkan Kategori Tema
function Library:ApplyThemeToInstance(instance, category)
    local t = Themes[Library.CurrentThemeName]
    if not t then return end

    if category == "Background" then
        instance.BackgroundColor3 = t.Background
    elseif category == "Container" then
        instance.BackgroundColor3 = t.Container
    elseif category == "Element" then
        instance.BackgroundColor3 = t.Element
    elseif category == "Stroke" then
        if t.IsRGB then
            Library:RegisterRGB(instance, "Color")
        else
            Library:UnregisterRGB(instance, "Color")
            instance.Color = t.Stroke
        end
    elseif category == "Text" then
        if instance:IsA("TextLabel") or instance:IsA("TextBox") then
            if t.IsRGB and instance:GetAttribute("RGBText") then
                Library:RegisterRGB(instance, "TextColor3")
            else
                Library:UnregisterRGB(instance, "TextColor3")
                instance.TextColor3 = t.Text
            end
        elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            if t.IsRGB and instance:GetAttribute("RGBText") then
                Library:RegisterRGB(instance, "ImageColor3")
            else
                Library:UnregisterRGB(instance, "ImageColor3")
                instance.ImageColor3 = t.Text
            end
        end
    elseif category == "TextMuted" then
        if instance:IsA("TextLabel") or instance:IsA("TextBox") then
            instance.TextColor3 = t.TextMuted
        elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            instance.ImageColor3 = t.TextMuted
        end
    elseif category == "Accent" then
        if t.IsRGB then
            Library:RegisterRGB(instance, "BackgroundColor3")
        else
            Library:UnregisterRGB(instance, "BackgroundColor3")
            instance.BackgroundColor3 = t.Accent
        end
    end
end

-- Fungsi Pengubah Tema Real-Time (Tanpa Restart)
function Library:SetTheme(themeName)
    if not Themes[themeName] then return end
    Library.CurrentThemeName = themeName
    Library.Flags["__MetaTheme"] = themeName
    
    -- Perbarui semua warna elemen statis yang terdaftar
    for category, list in pairs(Library.ThemeElements) do
        for i = #list, 1, -1 do
            local instance = list[i]
            if instance and instance:IsDescendantOf(game) then
                Library:ApplyThemeToInstance(instance, category)
            else
                table.remove(list, i)
            end
        end
    end
    
    -- Jalankan callback khusus elemen interaktif (seperti toggle, tab aktif, dll.)
    for _, callback in ipairs(Library.ThemeRefreshCallbacks) do
        pcall(callback)
    end
    
    Library:SaveSettings()
end

-- Translator Icon (Lucide & traditional assets)
local function resolveIcon(icon)
    if not icon then return "" end
    local lucideIcons = {
        ["home"] = "rbxassetid://10723407389",
        ["swords"] = "rbxassetid://10734975692",
        ["eye"] = "rbxassetid://10723346959",
        ["crosshair"] = "rbxassetid://10709818534",
        ["crown"] = "rbxassetid://10709818626",
        ["keyboard"] = "rbxassetid://10723416765",
        ["sliders"] = "rbxassetid://10734963400",
        ["palette"] = "rbxassetid://10734963400"
    }
    if type(icon) == "string" and lucideIcons[icon:lower()] then
        icon = lucideIcons[icon:lower()]
    end
    if type(icon) == "string" and icon:find("^rbxthumb://") then
        return icon
    end
    if type(icon) == "number" then
        return "rbxthumb://type=Asset&id=" .. tostring(icon) .. "&w=150&h=150"
    end
    if type(icon) == "string" and icon:find("^rbxassetid://") then
        local id = icon:gsub("^rbxassetid://", "")
        return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150"
    end
    return tostring(icon)
end

-- Membaca data langsung saat script pertama kali dieksekusi
local function PreloadConfiguration()
    if not isfile or not readfile then return end
    if isfile(SettingsFileName) then
        pcall(function()
            local meta = HttpService:JSONDecode(readfile(SettingsFileName))
            if meta and type(meta) == "table" then
                if meta.SelectedProfile then CurrentProfile = meta.SelectedProfile end
                if meta.AutoLoad ~= nil then AutoLoadEnabled = meta.AutoLoad end
                if meta.SelectedTheme then Library.CurrentThemeName = meta.SelectedTheme end
            end
        end)
    end
    local fileName = "LouisHub_UI_Config_" .. tostring(PlaceId) .. "_" .. CurrentProfile .. ".json"
    if isfile(fileName) then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile(fileName))
            if decoded and type(decoded) == "table" then
                Library.LoadedConfigCache = decoded
                for k, v in pairs(decoded) do
                    if not k:find("^__Meta") then
                        Library.Flags[k] = v
                    end
                end
            end
        end)
    end
end

PreloadConfiguration()

function Library:SaveSettings()
    if not writefile then return end
    pcall(function()
        local meta = {
            SelectedProfile = CurrentProfile,
            AutoLoad = AutoLoadEnabled,
            SelectedTheme = Library.CurrentThemeName
        }
        writefile(SettingsFileName, HttpService:JSONEncode(meta))
    end)
end

function Library:SaveConfig(quiet)
    if not writefile then return end
    pcall(function()
        local fileName = "LouisHub_UI_Config_" .. tostring(PlaceId) .. "_" .. CurrentProfile .. ".json"
        local filteredFlags = {}
        for k, v in pairs(Library.Flags) do
            if not k:find("^__Meta") then
                filteredFlags[k] = v
            end
        end
        writefile(fileName, HttpService:JSONEncode(filteredFlags))
        if not quiet then
            Library:Notify("Config System", "Config saved to " .. CurrentProfile, 3)
        end
    end)
end

function Library:LoadConfig(force, preloadOnly)
    if not isfile or not readfile then return end
    if isfile(SettingsFileName) then
        pcall(function()
            local meta = HttpService:JSONDecode(readfile(SettingsFileName))
            if meta and type(meta) == "table" then
                if meta.SelectedProfile then CurrentProfile = meta.SelectedProfile end
                if meta.AutoLoad ~= nil then AutoLoadEnabled = meta.AutoLoad end
                if meta.SelectedTheme then Library.CurrentThemeName = meta.SelectedTheme end
            end
        end)
    end

    if not preloadOnly then
        if Library.Elements["__MetaProfile"] then
            Library.Elements["__MetaProfile"]:Set(CurrentProfile, true, true)
        end
        if Library.Elements["__MetaAutoLoad"] then
            Library.Elements["__MetaAutoLoad"]:Set(AutoLoadEnabled, true, true)
        end
        if Library.Elements["__MetaTheme"] then
            Library.Elements["__MetaTheme"]:Set(Library.CurrentThemeName, true, true)
        end
    end

    if AutoLoadEnabled or force or preloadOnly then
        local fileName = "LouisHub_UI_Config_" .. tostring(PlaceId) .. "_" .. CurrentProfile .. ".json"
        if isfile(fileName) then
            pcall(function()
                local decoded = HttpService:JSONDecode(readfile(fileName))
                if decoded and type(decoded) == "table" then
                    Library.LoadedConfigCache = decoded
                    if not preloadOnly then
                        for k in pairs(Library.Flags) do
                            Library.Flags[k] = nil
                        end
                        Library.Flags["__MetaProfile"] = CurrentProfile
                        Library.Flags["__MetaAutoLoad"] = AutoLoadEnabled
                        Library.Flags["__MetaTheme"] = Library.CurrentThemeName
                        
                        local mainGui = Library:GetMainGui()
                        for flag, val in pairs(decoded) do
                            if flag:find("^__Meta") then continue end
                            if Library.Elements[flag] then
                                Library.Elements[flag]:Set(val, true, false)
                            end
                            if flag:find("^ExtBtnPos_") then
                                local btnId = flag:gsub("^ExtBtnPos_", "")
                                local btn = mainGui:FindFirstChild("ExternalButton_" .. btnId)
                                if btn and type(val) == "table" then
                                    btn.Position = UDim2.new(val.X_Scale or 0, val.X_Offset or 0, val.Y_Scale or 0, val.Y_Offset or 0)
                                end
                                Library.Flags[flag] = val
                            elseif flag == "StatsHUDPos" and type(val) == "table" then
                                local hud = mainGui:FindFirstChild("Louis_StatsHUD")
                                if hud then
                                    hud.Position = UDim2.new(val.X_Scale or 0, val.X_Offset or 0, val.Y_Scale or 0, val.Y_Offset or 0)
                                end
                                Library.Flags[flag] = val
                            end
                        end
                        if force then
                            Library:Notify("Config System", "Successfully loaded " .. CurrentProfile, 3)
                        end
                    end
                end
            end)
        else
            if not preloadOnly then
                for k in pairs(Library.Flags) do
                    Library.Flags[k] = nil
                end
                Library.Flags["__MetaProfile"] = CurrentProfile
                Library.Flags["__MetaAutoLoad"] = AutoLoadEnabled
                Library.Flags["__MetaTheme"] = Library.CurrentThemeName

                for flag, element in pairs(Library.Elements) do
                    if not flag:find("^__Meta") and element.DefaultValue ~= nil then
                        element:Set(element.DefaultValue, true, true)
                    end
                end
                for id, btnData in pairs(Library.ExternalButtons) do
                    if btnData.Instance and btnData.DefaultPosition then
                        btnData.Instance.Position = btnData.DefaultPosition
                    end
                end
                if force then
                    Library:Notify("Config System", "Profile is empty. UI reset to default.", 3)
                end
            end
        end
    end
end

-- ========================================================
-- [[ 1. MAIN ENGINE SYSTEM (DYNAMIC RGB & DRAG) ]]
-- ========================================================
local RGBElements = {}

function Library:RegisterRGB(instance, property)
    for _, item in ipairs(RGBElements) do
        if item.Instance == instance and item.Property == property then
            return
        end
    end
    table.insert(RGBElements, {Instance = instance, Property = property})
end

function Library:UnregisterRGB(instance, property)
    for i = #RGBElements, 1, -1 do
        if RGBElements[i].Instance == instance and RGBElements[i].Property == property then
            table.remove(RGBElements, i)
        end
    end
end

RunService.RenderStepped:Connect(function()
    local t = Themes[Library.CurrentThemeName]
    if not t or not t.IsRGB then return end
    
    local hue = (os.clock() % 4) / 4
    local rainbowColor = Color3.fromHSV(hue, 0.85, 0.95)
    
    for i = #RGBElements, 1, -1 do
        local item = RGBElements[i]
        if item.Instance and item.Instance:IsDescendantOf(game) then
            pcall(function()
                item.Instance[item.Property] = rainbowColor
            end)
        else
            table.remove(RGBElements, i)
        end
    end
end)

-- Peningkatan Sistem Drag: Bebas Kebocoran Memori (Memory Leak Clean)
local function EnableDrag(dragFrame, parentFrame, onDragEnd)
    local dragging, dragInput, dragStart, startPos
    local moveConnection, endConnection

    dragFrame.InputBegan:Connect(function(input)
        if parentFrame:GetAttribute("DragLocked") then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position
            
            -- Menghubungkan listener dinamis saat mulai drag
            moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    local delta = moveInput.Position - dragStart
                    parentFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            
            -- Mematikan koneksi secara total saat drag selesai
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if moveConnection then moveConnection:Disconnect() moveConnection = nil end
                    if endConnection then endConnection:Disconnect() end
                    if onDragEnd then onDragEnd() end
                end
            end)
        end
    end)
end

local MainGui
function Library:GetMainGui()
    if not MainGui then
        MainGui = Instance.new("ScreenGui")
        MainGui.Name = "LouisHub_ModernUI"
        MainGui.ResetOnSpawn = false
        MainGui.IgnoreGuiInset = true
        MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local parent
        if gethui then
            parent = gethui()
        else
            local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
            if success and coreGui then
                parent = coreGui
            else
                parent = LocalPlayer:WaitForChild("PlayerGui")
            end
        end
        MainGui.Parent = parent
    end
    return MainGui
end

-- ========================================================
-- [[ 2. MODERN NOTIFICATION SYSTEM ]]
-- ========================================================
local NotificationGui
local function GetNotificationHolder()
    if not NotificationGui then
        NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "Louis_Notification_System"
        NotificationGui.DisplayOrder = 9999
        
        local parent = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
        NotificationGui.Parent = parent
        
        local Holder = Instance.new("Frame", NotificationGui)
        Holder.Name = "Holder"
        Holder.Size = UDim2.new(0, 280, 1, -40)
        Holder.Position = UDim2.new(1, -300, 0, 20)
        Holder.BackgroundTransparency = 1
        
        local Layout = Instance.new("UIListLayout", Holder)
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.Padding = UDim.new(0, 8)
    end
    return NotificationGui.Holder
end

function Library:Notify(title, desc, duration)
    duration = duration or 4
    local Holder = GetNotificationHolder()
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 0)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true
    NotifFrame.Parent = Holder
    RegTheme(NotifFrame, "Background")
    
    local NotifCorner = Instance.new("UICorner", NotifFrame)
    NotifCorner.CornerRadius = UDim.new(0, 6)
    
    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Thickness = 1
    RegTheme(NotifStroke, "Stroke")

    local NotifAccent = Instance.new("Frame", NotifFrame)
    NotifAccent.Size = UDim2.new(0, 3, 1, 0)
    NotifAccent.Position = UDim2.new(0, 0, 0, 0)
    NotifAccent.BorderSizePixel = 0
    RegTheme(NotifAccent, "Accent")
    
    local TitleLabel = Instance.new("TextLabel", NotifFrame)
    TitleLabel.Size = UDim2.new(1, -30, 0, 20)
    TitleLabel.Position = UDim2.new(0, 14, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Notification"
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegTheme(TitleLabel, "Text")
    
    local DescLabel = Instance.new("TextLabel", NotifFrame)
    DescLabel.Size = UDim2.new(1, -30, 0, 32)
    DescLabel.Position = UDim2.new(0, 14, 0, 26)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc or "Description"
    DescLabel.Font = Enum.Font.Montserrat
    DescLabel.TextSize = 10
    DescLabel.TextWrapped = true
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegTheme(DescLabel, "TextMuted")
    
    TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 65)}):Play()
    
    task.delay(duration, function()
        if NotifFrame and NotifFrame.Parent then
            local fadeOut = TweenService:Create(NotifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end
    end)
end

-- ========================================================
-- [[ 3. LOADING SCREEN SYSTEM ]]
-- ========================================================
local function StartLoading(titleText, subtitleText, onComplete)
    local ScreenGui = Library:GetMainGui()
    
    local LoadingGui = Instance.new("Frame", ScreenGui)
    LoadingGui.Name = "Louis_Loading_Screen"
    LoadingGui.Size = UDim2.new(1, 0, 1, 0)
    LoadingGui.BorderSizePixel = 0
    LoadingGui.ZIndex = 9990
    RegTheme(LoadingGui, "Background")

    local ProfileFrame = Instance.new("Frame", LoadingGui)
    ProfileFrame.Size = UDim2.new(0, 220, 0, 60)
    ProfileFrame.Position = UDim2.new(0, 30, 1, -90)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.ZIndex = 9995

    local ProfileImage = Instance.new("ImageLabel", ProfileFrame)
    ProfileImage.Size = UDim2.new(0, 44, 0, 44)
    ProfileImage.Position = UDim2.new(0, 0, 0.5, -22)
    ProfileImage.BackgroundTransparency = 1
    ProfileImage.ImageTransparency = 1
    ProfileImage.ZIndex = 9995
    
    task.spawn(function()
        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if success then
            ProfileImage.Image = content
        end
    end)
    
    Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)
    local pStroke = Instance.new("UIStroke", ProfileImage)
    pStroke.Thickness = 1.5
    pStroke.Transparency = 1
    RegTheme(pStroke, "Stroke")

    local UserInfo = Instance.new("TextLabel", ProfileFrame)
    UserInfo.Size = UDim2.new(1, -54, 1, 0)
    UserInfo.Position = UDim2.new(0, 54, 0, 0)
    UserInfo.BackgroundTransparency = 1
    UserInfo.Font = Enum.Font.MontserratBold
    UserInfo.TextSize = 10
    UserInfo.TextXAlignment = Enum.TextXAlignment.Left
    UserInfo.RichText = true
    UserInfo.TextTransparency = 1
    UserInfo.ZIndex = 9995
    RegTheme(UserInfo, "Text")
    
    -- Sync text profile dengan format tema
    task.spawn(function()
        while LoadingGui and LoadingGui.Parent do
            local t = Themes[Library.CurrentThemeName]
            local mColor = t.IsRGB and "rgb(180,180,180)" or "rgb(100,100,110)"
            local idColor = t.IsRGB and "rgb(130,130,130)" or "rgb(150,140,150)"
            UserInfo.Text = string.format('<font color="%s">MEMBER:</font>\n%s\n<font size="8" color="%s">ID: %d</font>', mColor, LocalPlayer.Name:upper(), idColor, LocalPlayer.UserId)
            task.wait(1)
        end
    end)

    local Title = Instance.new("TextLabel", LoadingGui)
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Position = UDim2.new(0, 0, 0.35, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.MontserratBold
    Title.TextSize = 34
    Title.RichText = true
    Title.Text = (titleText or "LOUIS HUB"):upper()
    Title.TextTransparency = 1
    Title.ZIndex = 9995
    Title:SetAttribute("RGBText", true)
    RegTheme(Title, "Text")

    local SubTitle = Instance.new("TextLabel", LoadingGui)
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0.44, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = (subtitleText or "MODERNIZED INTERFACE"):upper()
    SubTitle.TextSize = 12
    SubTitle.Font = Enum.Font.MontserratBold
    SubTitle.TextTransparency = 1
    SubTitle.ZIndex = 9995
    RegTheme(SubTitle, "TextMuted")

    local BarBg = Instance.new("Frame", LoadingGui)
    BarBg.Size = UDim2.new(0.4, 0, 0, 4)
    BarBg.Position = UDim2.new(0.3, 0, 0.62, 0)
    BarBg.ZIndex = 9995
    Instance.new("UICorner", BarBg)
    RegTheme(BarBg, "Container")
    
    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.ZIndex = 9995
    Instance.new("UICorner", BarFill)
    RegTheme(BarFill, "Accent")

    local SkipBtn = Instance.new("TextButton", LoadingGui)
    SkipBtn.Size = UDim2.new(0, 110, 0, 32)
    SkipBtn.Position = UDim2.new(0.5, -55, 0.8, 0)
    SkipBtn.Text = "SKIP"
    SkipBtn.Font = Enum.Font.MontserratBold
    SkipBtn.TextSize = 12
    SkipBtn.ZIndex = 10000
    SkipBtn.TextTransparency = 1
    RegTheme(SkipBtn, "Element")
    
    local SkipCorner = Instance.new("UICorner", SkipBtn)
    SkipCorner.CornerRadius = UDim.new(0, 6)
    local SkipStroke = Instance.new("UIStroke", SkipBtn)
    SkipStroke.Thickness = 1
    RegTheme(SkipStroke, "Stroke")

    local beepSound = Instance.new("Sound", LoadingGui)
    beepSound.SoundId = "rbxassetid://1567483853"
    beepSound.Volume = 0.5

    local function ElectricZapEffect()
        for i = 1, 3 do
            local zap = Instance.new("Frame", LoadingGui)
            zap.BackgroundColor3 = Themes[Library.CurrentThemeName].IsRGB and Color3.new(1,1,1) or Themes[Library.CurrentThemeName].Accent
            zap.BorderSizePixel = 0
            zap.Size = UDim2.new(0, math.random(40, 90), 0, 1.5)
            zap.Position = UDim2.new(0.5, math.random(-80, 80), 0.38, math.random(-15, 15))
            zap.Rotation = math.random(0, 360)
            zap.ZIndex = 9995
            task.spawn(function() task.wait(0.1); zap:Destroy() end)
        end
    end

    local skipTriggered = false
    local function ForceExit()
        if skipTriggered then return end
        skipTriggered = true
        beepSound:Stop()
        
        local fadeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(LoadingGui, fadeInfo, {BackgroundTransparency = 1}):Play()
        for _, obj in ipairs(LoadingGui:GetDescendants()) do
            pcall(function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    TweenService:Create(obj, fadeInfo, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
                elseif obj:IsA("ImageLabel") then
                    TweenService:Create(obj, fadeInfo, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
                elseif obj:IsA("Frame") then
                    TweenService:Create(obj, fadeInfo, {BackgroundTransparency = 1}):Play()
                elseif obj:IsA("UIStroke") then
                    TweenService:Create(obj, fadeInfo, {Transparency = 1}):Play()
                end
            end)
        end
        task.delay(0.38, function() 
            LoadingGui:Destroy() 
            if onComplete then onComplete() end
        end)
    end

    SkipBtn.MouseButton1Click:Connect(ForceExit)

    local entryTween = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Title, entryTween, {TextTransparency = 0}):Play()
    TweenService:Create(ProfileImage, entryTween, {ImageTransparency = 0}):Play()
    TweenService:Create(pStroke, entryTween, {Transparency = 0}):Play()
    TweenService:Create(UserInfo, entryTween, {TextTransparency = 0}):Play()
    TweenService:Create(SkipBtn, entryTween, {TextTransparency = 0}):Play()

    task.delay(1, function()
        if skipTriggered then return end
        TweenService:Create(SubTitle, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        for i = 1, 6 do 
            if skipTriggered then break end
            local vis = not SubTitle.Visible
            SubTitle.Visible = vis
            Title.Visible = vis
            if vis then 
                ElectricZapEffect()
                pcall(function() beepSound:Play() end) 
            end
            task.wait(0.2)
        end
        if not skipTriggered then SubTitle.Visible = true; Title.Visible = true end
    end)

    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 5.5)
    
    local waitTime = 0
    while waitTime < 6 and not skipTriggered do
        waitTime = waitTime + 0.1
        task.wait(0.1)
    end
    if not skipTriggered then ForceExit() end
end

-- ========================================================
-- [[ 4. METHODS: CREATE MAIN WINDOW ]]
-- ========================================================
function Library:CreateWindow(titleText, subtitleText)
    Library:LoadConfig(false, true)

    local Window = {
        Tabs = {},
        CurrentTab = nil,
        DragLocked = false,
        Minimized = false,
        Visible = false
    }

    local ScreenGui = Library:GetMainGui()

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 330)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    RegTheme(MainFrame, "Background")

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1
    RegTheme(MainStroke, "Stroke")

    -- Header Panel
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 46)
    Header.BackgroundTransparency = 1
    EnableDrag(Header, MainFrame)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(0, 300, 0, 18)
    TitleLabel.Position = UDim2.new(0, 16, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText or "LOUIS HUB"
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegTheme(TitleLabel, "Text")

    local SubtitleLabel = Instance.new("TextLabel", Header)
    SubtitleLabel.Size = UDim2.new(0, 300, 0, 12)
    SubtitleLabel.Position = UDim2.new(0, 16, 0, 26)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = subtitleText or "Rebuilt Edition"
    SubtitleLabel.TextSize = 9
    SubtitleLabel.Font = Enum.Font.MontserratBold
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegTheme(SubtitleLabel, "TextMuted")

    local BarBg = Instance.new("Frame", MainFrame)
    BarBg.Size = UDim2.new(1, 0, 0, 1)
    BarBg.Position = UDim2.new(0, 0, 0, 46)
    BarBg.BorderSizePixel = 0
    RegTheme(BarBg, "Stroke")

    -- Sidebar Container
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 140, 1, -58)
    Sidebar.Position = UDim2.new(0, 12, 0, 52)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
    RegTheme(Sidebar, "Container")
    
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Thickness = 1
    RegTheme(SidebarStroke, "Stroke")

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -12, 1, -12)
    TabContainer.Position = UDim2.new(0, 6, 0, 6)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 4)

    -- Primary Content Workspace
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -174, 1, -58)
    ContentArea.Position = UDim2.new(0, 162, 0, 52)
    ContentArea.BorderSizePixel = 0
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 6)
    RegTheme(ContentArea, "Container")

    local ContentStroke = Instance.new("UIStroke", ContentArea)
    ContentStroke.Thickness = 1
    RegTheme(ContentStroke, "Stroke")

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end)

    local ToggleIcon = Instance.new("ImageButton", Header)
    ToggleIcon.Size = UDim2.new(0, 18, 0, 18)
    ToggleIcon.Position = UDim2.new(1, -52, 0, 14)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Image = "rbxthumb://type=Asset&id=6031094670&w=150&h=150"
    RegTheme(ToggleIcon, "Text")

    ToggleIcon.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        local targetSize = Window.Minimized and UDim2.new(0, 520, 0, 47) or UDim2.new(0, 520, 0, 330)
        local targetRotation = Window.Minimized and 180 or 0
        
        TweenService:Create(ToggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
        
        if Window.Minimized then
            local sidebarFade = TweenService:Create(Sidebar, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
            local contentFade = TweenService:Create(ContentArea, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
            sidebarFade:Play()
            contentFade:Play()
            
            sidebarFade.Completed:Connect(function()
                if Window.Minimized then
                    Sidebar.Visible = false
                    ContentArea.Visible = false
                end
            end)
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        else
            Sidebar.Visible = true
            ContentArea.Visible = true
            TweenService:Create(Sidebar, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
            TweenService:Create(ContentArea, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        end
    end)

    local CloseBtn = Instance.new("ImageButton", Header)
    CloseBtn.Size = UDim2.new(0, 18, 0, 18)
    CloseBtn.Position = UDim2.new(1, -28, 0, 14)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = "rbxthumb://type=Asset&id=10734898355&w=150&h=150"
    RegTheme(CloseBtn, "Text")

    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 75, 75)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {ImageColor3 = Themes[Library.CurrentThemeName].Text}):Play()
    end)

    -- [[ FLOATING ICON OPEN CLOSE ]]
    local FloatingToggle = Instance.new("TextButton", ScreenGui)
    FloatingToggle.Name = "FloatingToggleIcon"
    FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
    FloatingToggle.Position = UDim2.new(0.5, -24, 0.5, -24)
    FloatingToggle.Text = ""
    FloatingToggle.Visible = false
    RegTheme(FloatingToggle, "Background")

    local ToggleCorner = Instance.new("UICorner", FloatingToggle)
    ToggleCorner.CornerRadius = UDim.new(0, 8)

    local ToggleStroke = Instance.new("UIStroke", FloatingToggle)
    ToggleStroke.Thickness = 1
    RegTheme(ToggleStroke, "Stroke")

    local ToggleIconImage = Instance.new("ImageLabel", FloatingToggle)
    ToggleIconImage.Name = "Icon"
    ToggleIconImage.Size = UDim2.new(0, 24, 0, 24)
    ToggleIconImage.Position = UDim2.new(0.5, -12, 0.5, -12)
    ToggleIconImage.BackgroundTransparency = 1
    ToggleIconImage.Image = "rbxthumb://type=Asset&id=10734887784&w=150&h=150"
    ToggleIconImage.ScaleType = Enum.ScaleType.Fit
    RegTheme(ToggleIconImage, "Accent")

    EnableDrag(FloatingToggle, FloatingToggle)

    local firstTimeOpen = true

    local function OpenGui()
        if not Window.Visible then
            Window.Visible = true
            MainFrame.Visible = true
            
            local shrinkTween = TweenService:Create(FloatingToggle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            shrinkTween:Play()
            shrinkTween.Completed:Connect(function()
                if Window.Visible then
                    FloatingToggle.Visible = false
                end
            end)
            
            MainFrame.Size = UDim2.new(0, 520, 0, 0)
            local targetHeight = Window.Minimized and 47 or 330
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, targetHeight)}):Play()
        end
    end

    local function CloseGui()
        if Window.Visible then
            Window.Visible = false
            
            local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 520, 0, 0)})
            hideTween:Play()
            hideTween.Completed:Connect(function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
            
            if firstTimeOpen then
                firstTimeOpen = false
                FloatingToggle.Position = UDim2.new(0, 20, 0.5, -24)
            end
            
            FloatingToggle.Visible = true
            FloatingToggle.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(FloatingToggle, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()
        end
    end

    FloatingToggle.MouseButton1Click:Connect(function()
        TweenService:Create(FloatingToggle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        task.delay(0.1, function() OpenGui() end)
    end)

    CloseBtn.MouseButton1Click:Connect(CloseGui)

    StartLoading(titleText, subtitleText, function()
        firstTimeOpen = true
        FloatingToggle.Position = UDim2.new(0.5, -24, 0.5, -24)
        FloatingToggle.Size = UDim2.new(0, 0, 0, 0)
        FloatingToggle.Visible = true
        
        TweenService:Create(FloatingToggle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()

        task.spawn(function()
            task.wait(0.5)
            Library:LoadConfig()
        end)
    end)

    function Window:SetDragLock(state)
        Window.DragLocked = state
        MainFrame:SetAttribute("DragLocked", state)
    end

    function Window:BindToggleKey(keyCode)
        local debounce = false
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == keyCode and not debounce then
                debounce = true
                if Window.Visible then CloseGui() else OpenGui() end
                task.wait(0.3)
                debounce = false
            end
        end)
    end

    -- ========================================================
    -- [[ 5. METHODS: CREATE NEW TAB ]]
    -- ========================================================
    function Window:CreateTab(tabName, iconAssetId)
        local Tab = {}
        
        local TabContent = Instance.new("ScrollingFrame", ContentArea)
        TabContent.Size = UDim2.new(1, -16, 1, -16)
        TabContent.Position = UDim2.new(0, 8, 0, 8)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 2
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
        end)

        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 5)
        RegTheme(TabButton, "Element")

        local TabBtnStroke = Instance.new("UIStroke", TabButton)
        TabBtnStroke.Thickness = 1
        RegTheme(TabBtnStroke, "Stroke")

        local TabIndicator = Instance.new("Frame", TabButton)
        TabIndicator.Size = UDim2.new(0, 2.5, 1, -12)
        TabIndicator.Position = UDim2.new(0, 4, 0, 6)
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = false
        RegTheme(TabIndicator, "Accent")

        local IconLabel
        if iconAssetId then
            IconLabel = Instance.new("ImageLabel", TabButton)
            IconLabel.Size = UDim2.new(0, 14, 0, 14)
            IconLabel.Position = UDim2.new(0, 10, 0.5, -7)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = resolveIcon(iconAssetId)
            RegTheme(IconLabel, "TextMuted")
        end

        local TabText = Instance.new("TextLabel", TabButton)
        TabText.Size = UDim2.new(1, iconAssetId and -34 or -16, 1, 0)
        TabText.Position = UDim2.new(0, iconAssetId and 28 or 10)
        TabText.BackgroundTransparency = 1
        TabText.Text = tabName
        TabText.TextSize = 11
        TabText.Font = Enum.Font.MontserratMedium
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        RegTheme(TabText, "TextMuted")

        local function Select()
            if Window.CurrentTab then
                local oldTab = Window.CurrentTab
                local fadeOut = TweenService:Create(oldTab.Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 0.95, -16), Position = UDim2.new(0, 8, 0, 12)})
                fadeOut:Play()
                fadeOut.Completed:Connect(function() oldTab.Frame.Visible = false end)

                TweenService:Create(oldTab.Button, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                TweenService:Create(oldTab.ButtonStroke, TweenInfo.new(0.15), {Transparency = 1}):Play()
                TweenService:Create(oldTab.Text, TweenInfo.new(0.15), {TextColor3 = Themes[Library.CurrentThemeName].TextMuted}):Play()
                oldTab.Indicator.Visible = false
                if oldTab.Icon then
                    TweenService:Create(oldTab.Icon, TweenInfo.new(0.15), {ImageColor3 = Themes[Library.CurrentThemeName].TextMuted}):Play()
                end
            end
            
            TabContent.Size = UDim2.new(1, -16, 0.95, -16)
            TabContent.Position = UDim2.new(0, 8, 0, 12)
            TabContent.Visible = true
            TweenService:Create(TabContent, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0, 8, 0, 8)}):Play()

            Window.CurrentTab = {Button = TabButton, ButtonStroke = TabBtnStroke, Text = TabText, Frame = TabContent, Icon = IconLabel, Indicator = TabIndicator}
            
            TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundTransparency = 0, BackgroundColor3 = Themes[Library.CurrentThemeName].Element}):Play()
            TweenService:Create(TabBtnStroke, TweenInfo.new(0.15), {Transparency = 0}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Themes[Library.CurrentThemeName].Text}):Play()
            TabIndicator.Visible = true
            if IconLabel then
                TweenService:Create(IconLabel, TweenInfo.new(0.15), {ImageColor3 = Themes[Library.CurrentThemeName].Text}):Play()
            end
        end

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Button == TabButton then return end
            TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, BackgroundColor3 = Themes[Library.CurrentThemeName].ElementHover}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Themes[Library.CurrentThemeName].Text}):Play()
            if IconLabel then
                TweenService:Create(IconLabel, TweenInfo.new(0.15), {ImageColor3 = Themes[Library.CurrentThemeName].Text}):Play()
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Button == TabButton then return end
            TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Themes[Library.CurrentThemeName].TextMuted}):Play()
            if IconLabel then
                TweenService:Create(IconLabel, TweenInfo.new(0.15), {ImageColor3 = Themes[Library.CurrentThemeName].TextMuted}):Play()
            end
        end)

        TabButton.MouseButton1Click:Connect(Select)

        if not Window.CurrentTab then Select() end

        -- Sync visual tab saat ada perubahan tema
        table.insert(Library.ThemeRefreshCallbacks, function()
            local t = Themes[Library.CurrentThemeName]
            if Window.CurrentTab and Window.CurrentTab.Button == TabButton then
                TabButton.BackgroundColor3 = t.Element
                TabButton.BackgroundTransparency = 0
                TabText.TextColor3 = t.Text
                if IconLabel then IconLabel.ImageColor3 = t.Text end
            else
                TabButton.BackgroundTransparency = 1
                TabText.TextColor3 = t.TextMuted
                if IconLabel then IconLabel.ImageColor3 = t.TextMuted end
            end
        end)

        -- ========================================================
        -- [[ Tab Element: CREATE BUTTON ]]
        -- ========================================================
        function Tab:CreateButton(buttonText, callback)
            local Button = Instance.new("TextButton", TabContent)
            Button.Size = UDim2.new(1, -6, 0, 34)
            Button.Text = ""
            Button.AutoButtonColor = false
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)
            RegTheme(Button, "Element")

            local BtnStroke = Instance.new("UIStroke", Button)
            BtnStroke.Thickness = 1
            RegTheme(BtnStroke, "Stroke")

            local BtnText = Instance.new("TextLabel", Button)
            BtnText.Size = UDim2.new(1, -35, 1, 0)
            BtnText.Position = UDim2.new(0, 12, 0, 0)
            BtnText.BackgroundTransparency = 1
            BtnText.Text = buttonText or "Button"
            BtnText.TextSize = 11
            BtnText.Font = Enum.Font.MontserratMedium
            BtnText.TextXAlignment = Enum.TextXAlignment.Left
            RegTheme(BtnText, "Text")

            local ArrowIcon = Instance.new("ImageLabel", Button)
            ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
            ArrowIcon.Position = UDim2.new(1, -22, 0.5, -6)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxthumb://type=Asset&id=6031094678&w=150&h=150"
            RegTheme(ArrowIcon, "TextMuted")

            Button.MouseEnter:Connect(function()
                local t = Themes[Library.CurrentThemeName]
                TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = t.ElementHover}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = t.Text, Position = UDim2.new(1, -20, 0.5, -6)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                local t = Themes[Library.CurrentThemeName]
                TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = t.Element}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = t.TextMuted, Position = UDim2.new(1, -22, 0.5, -6)}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                local press = TweenService:Create(Button, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Themes[Library.CurrentThemeName].ElementPress})
                press:Play()
                press.Completed:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Themes[Library.CurrentThemeName].ElementHover}):Play()
                end)
                if callback then task.spawn(callback) end
            end)
        end

        -- ========================================================
        -- [[ Tab Element: CREATE TOGGLE ]]
        -- ========================================================
        function Tab:CreateToggle(toggleText, defaultVal, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = toggleText:gsub("%s+", "")
            elseif not flag then
                actualFlag = toggleText:gsub("%s+", "")
            end

            local savedVal = Library.LoadedConfigCache and Library.LoadedConfigCache[actualFlag]
            local Toggle = {State = (savedVal ~= nil and savedVal) or defaultVal or false}
            Library.Flags[actualFlag] = Toggle.State

            local ToggleBtn = Instance.new("TextButton", TabContent)
            ToggleBtn.Size = UDim2.new(1, -6, 0, 34)
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)
            RegTheme(ToggleBtn, "Element")

            local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
            ToggleStroke.Thickness = 1
            RegTheme(ToggleStroke, "Stroke")

            local TextLabel = Instance.new("TextLabel", ToggleBtn)
            TextLabel.Size = UDim2.new(1, -65, 1, 0)
            TextLabel.Position = UDim2.new(0, 12, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = toggleText or "Toggle"
            TextLabel.TextSize = 11
            TextLabel.Font = Enum.Font.MontserratMedium
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegTheme(TextLabel, "Text")

            local SwitchBg = Instance.new("Frame", ToggleBtn)
            SwitchBg.Size = UDim2.new(0, 32, 0, 16)
            SwitchBg.Position = UDim2.new(1, -44, 0.5, -8)
            SwitchBg.BorderSizePixel = 0
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
            RegTheme(SwitchBg, "Container")

            local SwitchBall = Instance.new("Frame", SwitchBg)
            SwitchBall.Size = UDim2.new(0, 12, 0, 12)
            SwitchBall.Position = UDim2.new(0, 2, 0.5, -6)
            SwitchBall.BorderSizePixel = 0
            Instance.new("UICorner", SwitchBall).CornerRadius = UDim.new(1, 0)
            RegTheme(SwitchBall, "TextMuted")

            local function UpdateVisual(animate, ignoreSave)
                local duration = animate and 0.2 or 0
                local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local t = Themes[Library.CurrentThemeName]
                
                if Toggle.State then
                    TweenService:Create(SwitchBall, info, {
                        Position = UDim2.new(1, -14, 0.5, -6), 
                        BackgroundColor3 = t.IsRGB and Color3.new(1,1,1) or t.Background
                    }):Play()
                    
                    if t.IsRGB then
                        Library:RegisterRGB(SwitchBg, "BackgroundColor3")
                    else
                        Library:UnregisterRGB(SwitchBg, "BackgroundColor3")
                        TweenService:Create(SwitchBg, info, {BackgroundColor3 = t.Accent}):Play()
                    end
                else
                    Library:UnregisterRGB(SwitchBg, "BackgroundColor3")
                    TweenService:Create(SwitchBall, info, {
                        Position = UDim2.new(0, 2, 0.5, -6), 
                        BackgroundColor3 = t.TextMuted
                    }):Play()
                    TweenService:Create(SwitchBg, info, {BackgroundColor3 = t.Stroke}):Play()
                end

                Library.Flags[actualFlag] = Toggle.State
                if not ignoreSave then Library:SaveConfig(true) end
            end

            UpdateVisual(false, true)

            if savedVal ~= nil and actualCallback then
                task.spawn(function() actualCallback(Toggle.State) end)
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                Toggle.State = not Toggle.State
                UpdateVisual(true)
                if actualCallback then task.spawn(function() actualCallback(Toggle.State) end) end
            end)

            table.insert(Library.ThemeRefreshCallbacks, function()
                UpdateVisual(false, true)
            end)

            local toggleController = {}
            toggleController.DefaultValue = defaultVal or false
            function toggleController:Set(state, ignoreSave, ignoreCallback)
                Toggle.State = state
                UpdateVisual(true, ignoreSave)
                if actualCallback and not ignoreCallback then 
                    task.spawn(function() actualCallback(Toggle.State) end) 
                end
            end

            Library.Elements[actualFlag] = toggleController
            return toggleController
        end

        -- ========================================================
        -- [[ Tab Element: CREATE SLIDER ]]
        -- ========================================================
        function Tab:CreateSlider(sliderText, minVal, maxVal, defaultVal, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = sliderText:gsub("%s+", "")
            elseif not flag then
                actualFlag = sliderText:gsub("%s+", "")
            end

            local savedVal = Library.LoadedConfigCache and Library.LoadedConfigCache[actualFlag]
            local Slider = {Value = (savedVal ~= nil and savedVal) or defaultVal or minVal}
            Library.Flags[actualFlag] = Slider.Value
            
            local SliderFrame = Instance.new("Frame", TabContent)
            SliderFrame.Size = UDim2.new(1, -6, 0, 48)
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 5)
            RegTheme(SliderFrame, "Element")
            
            local SliderStroke = Instance.new("UIStroke", SliderFrame)
            SliderStroke.Thickness = 1
            RegTheme(SliderStroke, "Stroke")

            local TitleLabel = Instance.new("TextLabel", SliderFrame)
            TitleLabel.Size = UDim2.new(1, -20, 0, 20)
            TitleLabel.Position = UDim2.new(0, 12, 0, 4)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = sliderText .. ": " .. tostring(Slider.Value)
            TitleLabel.TextSize = 11
            TitleLabel.Font = Enum.Font.MontserratMedium
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegTheme(TitleLabel, "Text")

            local SliderBg = Instance.new("TextButton", SliderFrame)
            SliderBg.Size = UDim2.new(1, -24, 0, 4)
            SliderBg.Position = UDim2.new(0, 12, 1, -12)
            SliderBg.Text = ""
            SliderBg.AutoButtonColor = false
            Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
            RegTheme(SliderBg, "Container")

            local SliderFill = Instance.new("Frame", SliderBg)
            SliderFill.Size = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 1, 0)
            SliderFill.BorderSizePixel = 0
            Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
            RegTheme(SliderFill, "Accent")

            local function UpdateVisuals(val, ignoreSave)
                Slider.Value = math.clamp(val, minVal, maxVal)
                local percentage = (Slider.Value - minVal) / (maxVal - minVal)
                
                TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                TitleLabel.Text = sliderText .. ": " .. tostring(Slider.Value)
                
                Library.Flags[actualFlag] = Slider.Value
                if not ignoreSave then Library:SaveConfig(true) end
            end

            UpdateVisuals(Slider.Value, true)

            if savedVal ~= nil and actualCallback then
                task.spawn(function() actualCallback(Slider.Value) end)
            end

            local sliding = false
            local function Update(input)
                local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local rawVal = minVal + (percentage * (maxVal - minVal))
                local finalVal = math.floor(rawVal + 0.5)
                
                UpdateVisuals(finalVal)
                if actualCallback then task.spawn(function() actualCallback(finalVal) end) end
            end

            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    Update(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            table.insert(Library.ThemeRefreshCallbacks, function()
                UpdateVisuals(Slider.Value, true)
            end)

            local sliderController = {}
            sliderController.DefaultValue = defaultVal or minVal
            function sliderController:Set(val, ignoreSave, ignoreCallback)
                UpdateVisuals(val, ignoreSave)
                if actualCallback and not ignoreCallback then 
                    task.spawn(function() actualCallback(Slider.Value) end) 
                end
            end

            Library.Elements[actualFlag] = sliderController
            return sliderController
        end

        -- ========================================================
        -- [[ Tab Element: CREATE DROPDOWN ]]
        -- ========================================================
        function Tab:CreateDropdown(dropdownText, options, defaultVal, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = dropdownText:gsub("%s+", "")
            elseif not flag then
                actualFlag = dropdownText:gsub("%s+", "")
            end

            local savedVal = Library.LoadedConfigCache and Library.LoadedConfigCache[actualFlag]
            local Dropdown = {
                Open = false,
                CurrentValue = (savedVal ~= nil and savedVal) or defaultVal or options[1],
                OptionFrames = {}
            }
            Library.Flags[actualFlag] = Dropdown.CurrentValue
            
            local DropdownFrame = Instance.new("Frame", TabContent)
            DropdownFrame.Size = UDim2.new(1, -6, 0, 34)
            DropdownFrame.ClipsDescendants = true
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 5)
            RegTheme(DropdownFrame, "Element")
            
            local FrameStroke = Instance.new("UIStroke", DropdownFrame)
            FrameStroke.Thickness = 1
            RegTheme(FrameStroke, "Stroke")

            local DropdownBtn = Instance.new("TextButton", DropdownFrame)
            DropdownBtn.Size = UDim2.new(1, 0, 0, 34)
            DropdownBtn.BackgroundTransparency = 1
            DropdownBtn.Text = ""

            local TextLabel = Instance.new("TextLabel", DropdownBtn)
            TextLabel.Size = UDim2.new(1, -60, 1, 0)
            TextLabel.Position = UDim2.new(0, 12, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = dropdownText .. " (" .. tostring(Dropdown.CurrentValue) .. ")"
            TextLabel.TextSize = 11
            TextLabel.Font = Enum.Font.MontserratMedium
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegTheme(TextLabel, "Text")

            local ArrowIcon = Instance.new("ImageLabel", DropdownBtn)
            ArrowIcon.Size = UDim2.new(0, 10, 0, 10)
            ArrowIcon.Position = UDim2.new(1, -22, 0.5, -5)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxthumb://type=Asset&id=6031094670&w=150&h=150"
            RegTheme(ArrowIcon, "TextMuted")

            local OptionContainer = Instance.new("Frame", DropdownFrame)
            OptionContainer.Size = UDim2.new(1, -24, 0, 0)
            OptionContainer.Position = UDim2.new(0, 12, 0, 36)
            OptionContainer.BackgroundTransparency = 1

            local OptionList = Instance.new("UIListLayout", OptionContainer)
            OptionList.Padding = UDim.new(0, 4)

            local function Refresh()
                for _, v in ipairs(Dropdown.OptionFrames) do v:Destroy() end
                Dropdown.OptionFrames = {}

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton", OptionContainer)
                    OptBtn.Size = UDim2.new(1, 0, 0, 26)
                    OptBtn.Text = ""
                    OptBtn.AutoButtonColor = false
                    Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
                    RegTheme(OptBtn, "Container")

                    local OptText = Instance.new("TextLabel", OptBtn)
                    OptText.Size = UDim2.new(1, -20, 1, 0)
                    OptText.Position = UDim2.new(0, 10, 0, 0)
                    OptText.BackgroundTransparency = 1
                    OptText.Text = tostring(opt)
                    OptText.TextSize = 10
                    OptText.TextXAlignment = Enum.TextXAlignment.Left

                    if opt == Dropdown.CurrentValue then
                        OptText.Font = Enum.Font.MontserratBold
                        RegTheme(OptText, "Text")
                        
                        local Indicator = Instance.new("Frame", OptBtn)
                        Indicator.Size = UDim2.new(0, 2.5, 1, -8)
                        Indicator.Position = UDim2.new(0, 3, 0, 4)
                        Instance.new("UICorner", Indicator)
                        RegTheme(Indicator, "Accent")
                    else
                        OptText.Font = Enum.Font.Montserrat
                        RegTheme(OptText, "TextMuted")
                    end

                    OptBtn.MouseEnter:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Themes[Library.CurrentThemeName].ElementHover}):Play()
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Themes[Library.CurrentThemeName].Container}):Play()
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown.CurrentValue = opt
                        TextLabel.Text = dropdownText .. " (" .. tostring(opt) .. ")"
                        Dropdown.Open = false
                        
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, 34)}):Play()
                        TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                        
                        Refresh()
                        
                        Library.Flags[actualFlag] = opt
                        if not actualFlag:find("^__Meta") then Library:SaveConfig(true) end
                        if actualCallback then task.spawn(function() actualCallback(opt) end) end
                    end)

                    table.insert(Dropdown.OptionFrames, OptBtn)
                end
            end

            DropdownBtn.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                local targetHeight = 34
                local rotation = 0
                
                if Dropdown.Open then
                    Refresh()
                    OptionContainer.Size = UDim2.new(1, -24, 0, OptionList.AbsoluteContentSize.Y)
                    targetHeight = 34 + (OptionList.AbsoluteContentSize.Y + 8)
                    rotation = 180
                else
                    OptionContainer.Size = UDim2.new(1, -24, 0, 0)
                end
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = rotation}):Play()
            end)

            if savedVal ~= nil and actualCallback then
                task.spawn(function() actualCallback(Dropdown.CurrentValue) end)
            end

            table.insert(Library.ThemeRefreshCallbacks, function()
                TextLabel.Text = dropdownText .. " (" .. tostring(Dropdown.CurrentValue) .. ")"
                if Dropdown.Open then Refresh() end
            end)

            local dropdownController = {}
            dropdownController.DefaultValue = defaultVal or options[1]
            function dropdownController:Set(val, ignoreSave, ignoreCallback)
                Dropdown.CurrentValue = val
                TextLabel.Text = dropdownText .. " (" .. tostring(val) .. ")"
                
                Library.Flags[actualFlag] = val
                if not ignoreSave and not actualFlag:find("^__Meta") then
                    Library:SaveConfig(true)
                end
                if actualCallback and not ignoreCallback then 
                    task.spawn(function() actualCallback(val) end) 
                end
            end

            function dropdownController:Refresh(newOptions)
                options = newOptions
                if Dropdown.Open then
                    Refresh()
                    OptionContainer.Size = UDim2.new(1, -24, 0, OptionList.AbsoluteContentSize.Y)
                    local targetHeight = 34 + (OptionList.AbsoluteContentSize.Y + 8)
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                end
            end
            dropdownController.Update = dropdownController.Refresh

            Library.Elements[actualFlag] = dropdownController
            return dropdownController
        end

        -- ========================================================
        -- [[ Tab Element: CREATE TEXTBOX ]]
        -- ========================================================
        function Tab:CreateTextBox(labelText, placeholderText, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = labelText:gsub("%s+", "")
            elseif not flag then
                actualFlag = labelText:gsub("%s+", "")
            end

            local savedVal = Library.LoadedConfigCache and Library.LoadedConfigCache[actualFlag]

            local TextBoxFrame = Instance.new("Frame", TabContent)
            TextBoxFrame.Size = UDim2.new(1, -6, 0, 34)
            Instance.new("UICorner", TextBoxFrame).CornerRadius = UDim.new(0, 5)
            RegTheme(TextBoxFrame, "Element")
            
            local FrameStroke = Instance.new("UIStroke", TextBoxFrame)
            FrameStroke.Thickness = 1
            RegTheme(FrameStroke, "Stroke")

            local Label = Instance.new("TextLabel", TextBoxFrame)
            Label.Size = UDim2.new(0.45, -12, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = labelText or "Input Text"
            Label.TextSize = 11
            Label.Font = Enum.Font.MontserratMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            RegTheme(Label, "Text")

            local InputBox = Instance.new("TextBox", TextBoxFrame)
            InputBox.Size = UDim2.new(0.55, -12, 0, 22)
            InputBox.Position = UDim2.new(0.45, 0, 0.5, -11)
            InputBox.Text = savedVal and tostring(savedVal) or ""
            InputBox.PlaceholderText = placeholderText or "Type here..."
            InputBox.TextSize = 10
            InputBox.Font = Enum.Font.Montserrat
            Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)
            RegTheme(InputBox, "Container")

            local InputStroke = Instance.new("UIStroke", InputBox)
            InputStroke.Thickness = 1
            RegTheme(InputStroke, "Stroke")

            Library.Flags[actualFlag] = InputBox.Text

            InputBox.Focused:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Themes[Library.CurrentThemeName].Accent}):Play()
            end)

            InputBox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Themes[Library.CurrentThemeName].Stroke}):Play()
                Library.Flags[actualFlag] = InputBox.Text
                Library:SaveConfig(true)
                if actualCallback then task.spawn(function() actualCallback(InputBox.Text, enterPressed) end) end
            end)

            if savedVal ~= nil and actualCallback then
                task.spawn(function() actualCallback(InputBox.Text, false) end)
            end

            table.insert(Library.ThemeRefreshCallbacks, function()
                Label.TextColor3 = Themes[Library.CurrentThemeName].Text
                InputBox.TextColor3 = Themes[Library.CurrentThemeName].Text
                InputBox.PlaceholderColor3 = Themes[Library.CurrentThemeName].TextMuted
            end)

            local textboxController = {}
            textboxController.DefaultValue = ""
            function textboxController:Set(val, ignoreSave, ignoreCallback)
                InputBox.Text = tostring(val)
                Library.Flags[actualFlag] = val
                if not ignoreSave then Library:SaveConfig(true) end
                if actualCallback and not ignoreCallback then 
                    task.spawn(function() actualCallback(val, false) end) 
                end
            end

            Library.Elements[actualFlag] = textboxController
            return textboxController
        end

        -- ========================================================
        -- [[ Tab Element: CREATE PARAGRAPH ]]
        -- ========================================================
        function Tab:CreateParagraph(titleText, descText)
            local ParagraphFrame = Instance.new("Frame", TabContent)
            ParagraphFrame.Size = UDim2.new(1, -6, 0, 52)
            Instance.new("UICorner", ParagraphFrame).CornerRadius = UDim.new(0, 5)
            RegTheme(ParagraphFrame, "Container")
            
            local FrameStroke = Instance.new("UIStroke", ParagraphFrame)
            FrameStroke.Thickness = 1
            RegTheme(FrameStroke, "Stroke")

            local TitleLabel = Instance.new("TextLabel", ParagraphFrame)
            TitleLabel.Size = UDim2.new(1, -20, 0, 18)
            TitleLabel.Position = UDim2.new(0, 12, 0, 6)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = titleText or "Section Title"
            TitleLabel.Font = Enum.Font.MontserratBold
            TitleLabel.TextSize = 11
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegTheme(TitleLabel, "Text")

            local DescLabel = Instance.new("TextLabel", ParagraphFrame)
            DescLabel.Size = UDim2.new(1, -20, 1, -26)
            DescLabel.Position = UDim2.new(0, 12, 0, 22)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = descText or "Description text details."
            DescLabel.Font = Enum.Font.Montserrat
            DescLabel.TextSize = 9
            DescLabel.TextWrapped = true
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegTheme(DescLabel, "TextMuted")
        end

        return Tab
    end

    -- ========================================================
    -- [[ 5g. PERMANENT CONFIG MANAGER TAB ]]
    -- ========================================================
    local ConfigTab = Window:CreateTab("Config", "rbxthumb://type=Asset&id=7734053495&w=150&h=150")
    
    ConfigTab:CreateParagraph("Configuration Profiles", "Select a profile, save your modifications, or enable auto-load to restore states upon loading.")

    ConfigTab:CreateDropdown("Selected Profile", {"Profile 1", "Profile 2", "Profile 3", "Profile 4", "Profile 5"}, CurrentProfile, "__MetaProfile", function(selected)
        CurrentProfile = selected
        Library:SaveSettings()
        Library:LoadConfig(true) 
    end)

    ConfigTab:CreateToggle("Auto Load Config", AutoLoadEnabled, "__MetaAutoLoad", function(state)
        AutoLoadEnabled = state
        Library:SaveSettings()
    end)

    ConfigTab:CreateButton("Save Current Config", function()
        Library:SaveConfig(false)
    end)

    ConfigTab:CreateButton("Load Selected Config", function()
        Library:LoadConfig(true)
    end)

    -- ========================================================
    -- [[ 5h. TAB THEME (BARU - DI BAWAH CONFIG) ]]
    -- ========================================================
    local ThemeTab = Window:CreateTab("Theme", "rbxthumb://type=Asset&id=10734963400&w=150&h=150")
    
    ThemeTab:CreateParagraph("Theme Engine", "Select your UI theme. You can switch between traditional dynamic RGB and the new Cute Pastel theme.")
    
    ThemeTab:CreateDropdown("UI Style Version", {"RGB", "Cute Pastel"}, Library.CurrentThemeName, "__MetaTheme", function(selected)
        Library:SetTheme(selected)
    end)

    return Window
end

-- ========================================================
-- [[ 6. EXTERNAL UTILITY BUTTON SYSTEM ]]
-- ========================================================
function Library:CreateExternalButton(id, text, defaultPos, callback)
    local ScreenGui = Library:GetMainGui()

    local ExtBtn = Instance.new("TextButton")
    ExtBtn.Name = "ExternalButton_" .. tostring(id)
    ExtBtn.Size = UDim2.new(0, 40, 0, 40)
    
    local savedPos = Library.LoadedConfigCache and Library.LoadedConfigCache["ExtBtnPos_" .. tostring(id)]
    if savedPos and type(savedPos) == "table" then
        ExtBtn.Position = UDim2.new(savedPos.X_Scale or 0, savedPos.X_Offset or 0, savedPos.Y_Scale or 0, savedPos.Y_Offset or 0)
    else
        ExtBtn.Position = defaultPos or UDim2.new(0, 20, 0.5, 0)
    end

    ExtBtn.Text = text or "A"
    ExtBtn.Font = Enum.Font.MontserratBold
    ExtBtn.TextSize = 13
    ExtBtn.AutoButtonColor = false
    ExtBtn.Parent = ScreenGui
    RegTheme(ExtBtn, "Element")

    local Corner = Instance.new("UICorner", ExtBtn)
    Corner.CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", ExtBtn)
    Stroke.Thickness = 1
    RegTheme(Stroke, "Stroke")

    EnableDrag(ExtBtn, ExtBtn, function()
        Library.Flags["ExtBtnPos_" .. tostring(id)] = {
            X_Scale = ExtBtn.Position.X.Scale,
            X_Offset = ExtBtn.Position.X.Offset,
            Y_Scale = ExtBtn.Position.Y.Scale,
            Y_Offset = ExtBtn.Position.Y.Offset
        }
        Library:SaveConfig(true) 
    end)

    Library.ExternalButtons[id] = {
        Instance = ExtBtn,
        DefaultPosition = defaultPos or UDim2.new(0, 20, 0.5, 0)
    }

    ExtBtn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)

    local controller = {}
    controller.Instance = ExtBtn 
    
    function controller:SetVisible(state) ExtBtn.Visible = state end
    function controller:SetText(val) ExtBtn.Text = tostring(val) end
    function controller:SetDragLock(locked) ExtBtn:SetAttribute("DragLocked", locked) end
    function controller:SetSize(size)
        if typeof(size) == "UDim2" then ExtBtn.Size = size
        elseif type(size) == "number" then ExtBtn.Size = UDim2.new(0, size, 0, size) end
    end

    return controller
end

-- ========================================================
-- [[ 7. REAL-TIME STATS HUD (FPS & PING) ]]
-- ========================================================
function Library:CreateStatsHUD()
    local ScreenGui = Library:GetMainGui()
    
    local HudFrame = Instance.new("Frame")
    HudFrame.Name = "Louis_StatsHUD"
    HudFrame.Size = UDim2.new(0, 150, 0, 28)
    
    local savedPos = Library.LoadedConfigCache and Library.LoadedConfigCache["StatsHUDPos"]
    if savedPos and type(savedPos) == "table" then
        HudFrame.Position = UDim2.new(savedPos.X_Scale or 0, savedPos.X_Offset or 0, savedPos.Y_Scale or 0, savedPos.Y_Offset or 0)
    else
        HudFrame.Position = UDim2.new(1, -20, 0, 50)
    end

    HudFrame.AnchorPoint = Vector2.new(1, 0)
    HudFrame.BorderSizePixel = 0
    HudFrame.Parent = ScreenGui
    HudFrame.Visible = true 
    RegTheme(HudFrame, "Background")

    local HudCorner = Instance.new("UICorner", HudFrame)
    HudCorner.CornerRadius = UDim.new(0, 6)

    local HudStroke = Instance.new("UIStroke", HudFrame)
    HudStroke.Thickness = 1
    RegTheme(HudStroke, "Stroke")

    local StatLabel = Instance.new("TextLabel", HudFrame)
    StatLabel.Size = UDim2.new(1, 0, 1, 0)
    StatLabel.BackgroundTransparency = 1
    StatLabel.Font = Enum.Font.MontserratBold
    StatLabel.TextSize = 10
    StatLabel.RichText = true
    StatLabel.Text = "FPS: ...  •  PING: ... MS"
    RegTheme(StatLabel, "Text")

    EnableDrag(HudFrame, HudFrame, function()
        Library.Flags["StatsHUDPos"] = {
            X_Scale = HudFrame.Position.X.Scale,
            X_Offset = HudFrame.Position.X.Offset,
            Y_Scale = HudFrame.Position.Y.Scale,
            Y_Offset = HudFrame.Position.Y.Offset
        }
        Library:SaveConfig(true) 
    end)

    local fpsHistory = {}
    local maxHistory = 30
    local lastTextUpdate = 0
    local textUpdateInterval = 0.1

    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        if not HudFrame or not HudFrame.Parent then
            connection:Disconnect()
            return
        end
        
        table.insert(fpsHistory, dt)
        if #fpsHistory > maxHistory then table.remove(fpsHistory, 1) end
        
        local now = os.clock()
        if now - lastTextUpdate >= textUpdateInterval then
            lastTextUpdate = now
            local totalTime = 0
            for _, t in ipairs(fpsHistory) do totalTime = totalTime + t end
            local currentFps = #fpsHistory > 0 and math.round(#fpsHistory / totalTime) or 60
            
            local currentPing = 0
            if LocalPlayer then
                local success, rawPing = pcall(function() return LocalPlayer:GetNetworkPing() end)
                if success and rawPing and rawPing > 0 then currentPing = math.round(rawPing * 1000) end
            end
            
            local greenClr = Themes[Library.CurrentThemeName].IsRGB and "rgb(0, 255, 120)" or "rgb(120, 215, 240)"
            local blueClr = Themes[Library.CurrentThemeName].IsRGB and "rgb(0, 180, 255)" or "rgb(255, 180, 210)"
            StatLabel.Text = string.format("FPS: <font color='%s'>%d</font>  •  PING: <font color='%s'>%d MS</font>", greenClr, currentFps, blueClr, currentPing)
        end
    end)

    local hudController = {}
    function hudController:SetVisible(state) HudFrame.Visible = state end
    return hudController
end

-- ========================================================
-- [[ AUTO-INITIALIZATION ON LIBRARY LOAD ]]
-- ========================================================
task.spawn(function()
    local statsHUD = Library:CreateStatsHUD()
    statsHUD:SetVisible(true)
    
    pcall(function()
        Library:LoadConfig()
    end)
end)

return Library
