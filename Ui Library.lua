local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ========================================================
-- [[ 0. CONFIGURATION & THEME SYSTEM ]]
-- ========================================================
Library.Flags = {}
Library.Elements = {}
Library.ExternalButtons = {} 
Library.LoadedConfigCache = {} 

local PlaceId = game.PlaceId
local SettingsFileName = "LouisHub_UI_Settings_" .. tostring(PlaceId) .. ".json"
local CurrentProfile = "Profile 1"
local AutoLoadEnabled = false

-- Definisi Palet Tema Terpadu dengan Efek Transparansi Kaca
local Themes = {
    ["RGB"] = {
        WindowBg = Color3.fromRGB(15, 15, 18),
        WindowTransparency = 0,
        HeaderBg = Color3.fromRGB(15, 15, 18),
        HeaderTransparency = 1,
        SidebarBg = Color3.fromRGB(18, 18, 22),
        SidebarTransparency = 0,
        ContentBg = Color3.fromRGB(18, 18, 22),
        ContentTransparency = 0,
        ElementBg = Color3.fromRGB(22, 22, 26),
        ElementTransparency = 0,
        ElementStroke = Color3.fromRGB(35, 35, 40),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(140, 140, 150),
        TextDark = Color3.fromRGB(130, 130, 130),
        Accent = Color3.fromRGB(255, 255, 255), -- Dinamis oleh loop RGB
        IsRGB = true,
        BgImage = "", -- Kosong untuk tema RGB
        BgImageTransparency = 1,
        FloatingIconImage = "rbxthumb://type=Asset&id=10734887784&w=150&h=150"
    },
    ["Cute Pastel"] = {
        WindowBg = Color3.fromRGB(255, 235, 243),      -- Pink pastel sebagai dasar bodi
        WindowTransparency = 0,                         -- Dikunci 0 agar gambar di atasnya mendapatkan warna latar pink lembut yang solid
        HeaderBg = Color3.fromRGB(174, 224, 250),      -- Biru pastel
        HeaderTransparency = 0.1,                       -- Transparansi header 10%
        SidebarBg = Color3.fromRGB(255, 215, 230),     -- Pink-lavender pastel
        SidebarTransparency = 0.8,                      -- Diatur 80% transparan agar pola gambar latar belakang di bawahnya terlihat jelas
        ContentBg = Color3.fromRGB(247, 251, 255),     -- Kanvas putih-biru pudar
        ContentTransparency = 0.8,                     -- Diatur 80% transparan agar pola gambar latar belakang di bawahnya terlihat jelas
        ElementBg = Color3.fromRGB(255, 255, 255),     -- Modul tombol putih bersih
        ElementTransparency = 0.15,                     -- Transparansi modul 15% untuk memberikan kedalaman di atas pola gambar
        ElementStroke = Color3.fromRGB(235, 205, 220), 
        TextPrimary = Color3.fromRGB(80, 75, 90),      
        TextSecondary = Color3.fromRGB(115, 120, 140), 
        TextDark = Color3.fromRGB(150, 155, 175),      
        Accent = Color3.fromRGB(255, 130, 170),        
        IsRGB = false,
        BgImage = "rbxthumb://type=Asset&id=118470928936375&w=420&h=420", -- Gambar latar belakang kustom tema pastel
        BgImageTransparency = 0.8, -- Opasitas disesuaikan agar menyatu indah dan tidak menutupi tulisan
        FloatingIconImage = "rbxthumb://type=Asset&id=103242464029137&w=150&h=150" -- Ikon melayang kustom tema pastel
    }
}

local CurrentThemeName = "RGB"
local IsThemeRGB = true
local ThemeRegistry = {}
local RGBElements = {}
local ActiveWindowInstance = nil

-- Mendaftarkan elemen UI agar merespon pergantian warna & transparansi tema secara instan
local function RegisterThemeable(instance, propertyMap)
    table.insert(ThemeRegistry, {
        Instance = instance,
        Properties = propertyMap
    })
    local theme = Themes[CurrentThemeName]
    pcall(function()
        for property, valSelector in pairs(propertyMap) do
            if type(valSelector) == "function" then
                instance[property] = valSelector(theme)
            else
                instance[property] = theme[valSelector]
            end
        end
    end)
end

-- Menerapkan perubahan tema secara langsung ke seluruh elemen terdaftar
local function ApplyTheme(themeName)
    CurrentThemeName = themeName
    local theme = Themes[themeName] or Themes["RGB"]
    IsThemeRGB = theme.IsRGB
    
    -- Perbarui elemen statis & transparan
    for _, item in ipairs(ThemeRegistry) do
        local instance = item.Instance
        if instance and instance:IsDescendantOf(game) then
            pcall(function()
                for property, valSelector in pairs(item.Properties) do
                    if type(valSelector) == "function" then
                        instance[property] = valSelector(theme)
                    else
                        instance[property] = theme[valSelector]
                    end
                end
            end)
        end
    end
    
    -- Atur ulang elemen RGB jika beralih ke tema statis (Cute Pastel)
    if not IsThemeRGB then
        for _, item in ipairs(RGBElements) do
            if item.Instance and item.Instance:IsDescendantOf(game) then
                pcall(function()
                    -- Jaga agar ikon melayang tidak tercampur aksen pink agar warna aslinya terlihat
                    if item.Instance.Name == "Icon" and item.Instance.Parent and item.Instance.Parent.Name == "FloatingToggleIcon" then
                        item.Instance[item.Property] = Color3.fromRGB(255, 255, 255)
                    else
                        item.Instance[item.Property] = theme.Accent
                    end
                end)
            end
        end
    end
    
    -- Segarkan tampilan tab aktif
    if ActiveWindowInstance and ActiveWindowInstance.UpdateAllTabsVisual then
        ActiveWindowInstance:UpdateAllTabsVisual()
    end
    
    Library.Flags["__MetaTheme"] = themeName
    Library:SaveSettings()
end

-- Dual Icon Resolver (Menerjemahkan nama ikon Lucide ke ID aset)
local function resolveIcon(icon)
    if not icon then return "" end
    
    local lucideIcons = {
        ["home"] = "rbxassetid://10723407389",
        ["swords"] = "rbxassetid://10734975692",
        ["eye"] = "rbxassetid://10723346959",
        ["crosshair"] = "rbxassetid://10709818534",
        ["crown"] = "rbxassetid://10709818626",
        ["keyboard"] = "rbxassetid://10723416765",
        ["sliders"] = "rbxassetid://10734963400"
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

-- Pra-Muat Setelan & Tema Terpilih
local function PreloadConfiguration()
    if not isfile or not readfile then return end
    
    if isfile(SettingsFileName) then
        pcall(function()
            local meta = HttpService:JSONDecode(readfile(SettingsFileName))
            if meta and type(meta) == "table" then
                if meta.SelectedProfile then CurrentProfile = meta.SelectedProfile end
                if meta.AutoLoad ~= nil then AutoLoadEnabled = meta.AutoLoad end
                if meta.SelectedTheme then CurrentThemeName = meta.SelectedTheme end
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
    local success, err = pcall(function()
        local meta = {
            SelectedProfile = CurrentProfile,
            AutoLoad = AutoLoadEnabled,
            SelectedTheme = CurrentThemeName
        }
        writefile(SettingsFileName, HttpService:JSONEncode(meta))
    end)
    if not success then
        warn("LouisHub UI: Gagal menyimpan settings. Error: " .. tostring(err))
    end
end

function Library:SaveConfig(quiet)
    if not writefile then return end
    local success, err = pcall(function()
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
    if not success then
        warn("LouisHub UI: Gagal menyimpan config. Error: " .. tostring(err))
    end
end

function Library:LoadConfig(force, preloadOnly)
    if not isfile or not readfile then return end
    
    if isfile(SettingsFileName) then
        local success, err = pcall(function()
            local meta = HttpService:JSONDecode(readfile(SettingsFileName))
            if meta and type(meta) == "table" then
                if meta.SelectedProfile then CurrentProfile = meta.SelectedProfile end
                if meta.AutoLoad ~= nil then AutoLoadEnabled = meta.AutoLoad end
                if meta.SelectedTheme then CurrentThemeName = meta.SelectedTheme end
            end
        end)
        if not success then
            warn("LouisHub UI: Gagal membaca settings. Error: " .. tostring(err))
        end
    end

    if not preloadOnly then
        if Library.Elements["__MetaProfile"] then
            Library.Elements["__MetaProfile"]:Set(CurrentProfile, true, true)
        end
        if Library.Elements["__MetaAutoLoad"] then
            Library.Elements["__MetaAutoLoad"]:Set(AutoLoadEnabled, true, true)
        end
        if Library.Elements["__MetaTheme"] then
            Library.Elements["__MetaTheme"]:Set(CurrentThemeName, true, true)
        end
    end

    if AutoLoadEnabled or force or preloadOnly then
        local fileName = "LouisHub_UI_Config_" .. tostring(PlaceId) .. "_" .. CurrentProfile .. ".json"
        if isfile(fileName) then
            local success, err = pcall(function()
                local decoded = HttpService:JSONDecode(readfile(fileName))
                if decoded and type(decoded) == "table" then
                    Library.LoadedConfigCache = decoded
                    
                    if not preloadOnly then
                        for k in pairs(Library.Flags) do
                            Library.Flags[k] = nil
                        end
                        
                        Library.Flags["__MetaProfile"] = CurrentProfile
                        Library.Flags["__MetaAutoLoad"] = AutoLoadEnabled
                        Library.Flags["__MetaTheme"] = CurrentThemeName
                        
                        local mainGui = GetMainGui()
                        for flag, val in pairs(decoded) do
                            if flag:find("^__Meta") then
                                continue
                            end
                            
                            if Library.Elements[flag] then
                                Library.Elements[flag]:Set(val, true, false)
                            end
                            if flag:find("^ExtBtnPos_") then
                                local btnId = flag:gsub("^ExtBtnPos_", "")
                                local btn = mainGui:FindFirstChild("ExternalButton_" .. btnId)
                                if btn and type(val) == "table" then
                                    btn.Position = UDim2.new(
                                        val.X_Scale or 0, 
                                        val.X_Offset or 0, 
                                        val.Y_Scale or 0, 
                                        val.Y_Offset or 0
                                    )
                                end
                                Library.Flags[flag] = val
                            elseif flag == "StatsHUDPos" and type(val) == "table" then
                                local hud = mainGui:FindFirstChild("Louis_StatsHUD")
                                if hud then
                                    hud.Position = UDim2.new(
                                        val.X_Scale or 0, 
                                        val.X_Offset or 0, 
                                        val.Y_Scale or 0, 
                                        val.Y_Offset or 0
                                    )
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
            if not success then
                warn("LouisHub UI: Gagal membaca config. Error: " .. tostring(err))
            end
        else
            if not preloadOnly then
                for k in pairs(Library.Flags) do
                    Library.Flags[k] = nil
                end
                Library.Flags["__MetaProfile"] = CurrentProfile
                Library.Flags["__MetaAutoLoad"] = AutoLoadEnabled
                Library.Flags["__MetaTheme"] = CurrentThemeName

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
                    Library:Notify("Config System", "Profile is empty. UI reset to default for " .. CurrentProfile, 3)
                end
            end
        end
    end
end

-- ========================================================
-- [[ 1. MAIN ENGINE SYSTEM (DYNAMIC RGB & LEAKLESS DRAG) ]]
-- ========================================================
local function RegisterRGB(instance, property)
    for _, item in ipairs(RGBElements) do
        if item.Instance == instance and item.Property == property then
            return
        end
    end
    table.insert(RGBElements, {Instance = instance, Property = property})
end

local function UnregisterRGB(instance, property)
    for i = #RGBElements, 1, -1 do
        if RGBElements[i].Instance == instance and RGBElements[i].Property == property then
            table.remove(RGBElements, i)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not IsThemeRGB then return end -- Hindari pemrosesan warna jika mode RGB mati
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

-- Sistem Drag Baru yang Sangat Akurat Berdasarkan Titik Sentuh Awal (Offset Delta)
local function EnableDrag(dragFrame, parentFrame, onDragEnd)
    local dragging = false
    local dragInput
    local dragStart = Vector3.new()
    local startPos = UDim2.new()
    
    dragFrame.InputBegan:Connect(function(input)
        if parentFrame:GetAttribute("DragLocked") then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = parentFrame.Position
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                    if endConnection then endConnection:Disconnect() end
                    if onDragEnd then onDragEnd() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            if parentFrame:GetAttribute("DragLocked") then 
                dragging = false
                dragInput = nil
                return 
            end
            local delta = input.Position - dragStart
            parentFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local MainGui
local function GetMainGui()
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
    local t = Themes[CurrentThemeName]
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 0)
    NotifFrame.BackgroundColor3 = t.WindowBg
    NotifFrame.BackgroundTransparency = t.WindowTransparency
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true
    NotifFrame.Parent = Holder
    
    local NotifCorner = Instance.new("UICorner", NotifFrame)
    NotifCorner.CornerRadius = UDim.new(0, 6)
    
    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Thickness = 1
    NotifStroke.Color = t.IsRGB and Color3.new(1,1,1) or t.Accent
    if t.IsRGB then RegisterRGB(NotifStroke, "Color") end

    local NotifAccent = Instance.new("Frame", NotifFrame)
    NotifAccent.Size = UDim2.new(0, 3, 1, 0)
    NotifAccent.Position = UDim2.new(0, 0, 0, 0)
    NotifAccent.BorderSizePixel = 0
    NotifAccent.BackgroundColor3 = t.IsRGB and Color3.new(1,1,1) or t.Accent
    if t.IsRGB then RegisterRGB(NotifAccent, "BackgroundColor3") end
    
    local TitleLabel = Instance.new("TextLabel", NotifFrame)
    TitleLabel.Size = UDim2.new(1, -30, 0, 20)
    TitleLabel.Position = UDim2.new(0, 14, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Notification"
    TitleLabel.TextColor3 = t.TextPrimary
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DescLabel = Instance.new("TextLabel", NotifFrame)
    DescLabel.Size = UDim2.new(1, -30, 0, 32)
    DescLabel.Position = UDim2.new(0, 14, 0, 26)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc or "Description"
    DescLabel.TextColor3 = t.TextSecondary
    DescLabel.Font = Enum.Font.Montserrat
    DescLabel.TextSize = 10
    DescLabel.TextWrapped = true
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    
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
-- [[ 3. REBUILT LOADING SCREEN SYSTEM ]]
-- ========================================================
local function StartLoading(titleText, subtitleText, onComplete)
    local ScreenGui = GetMainGui()
    local t = Themes[CurrentThemeName]
    
    local LoadingGui = Instance.new("Frame", ScreenGui)
    LoadingGui.Name = "Louis_Loading_Screen"
    LoadingGui.Size = UDim2.new(1, 0, 1, 0)
    LoadingGui.BackgroundColor3 = t.IsRGB and Color3.fromRGB(15, 15, 18) or t.WindowBg
    LoadingGui.BackgroundTransparency = t.IsRGB and 0 or t.WindowTransparency
    LoadingGui.BorderSizePixel = 0
    LoadingGui.ZIndex = 9990

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
    pStroke.Color = t.IsRGB and Color3.new(1,1,1) or t.Accent
    if t.IsRGB then RegisterRGB(pStroke, "Color") end

    local UserInfo = Instance.new("TextLabel", ProfileFrame)
    UserInfo.Size = UDim2.new(1, -54, 1, 0)
    UserInfo.Position = UDim2.new(0, 54, 0, 0)
    UserInfo.BackgroundTransparency = 1
    UserInfo.Font = Enum.Font.MontserratBold
    UserInfo.TextColor3 = t.TextPrimary
    UserInfo.TextSize = 10
    UserInfo.TextXAlignment = Enum.TextXAlignment.Left
    UserInfo.RichText = true
    UserInfo.TextTransparency = 1
    UserInfo.ZIndex = 9995
    UserInfo.Text = '<font color="'.. (t.IsRGB and "rgb(180, 180, 180)" or "rgb(100, 100, 110)") ..'">MEMBER:</font>\n' .. LocalPlayer.Name:upper() .. '\n<font size="8" color="'.. (t.IsRGB and "rgb(130, 130, 130)" or "rgb(140, 140, 150)") ..'">ID: ' .. LocalPlayer.UserId .. '</font>'

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
    Title.TextColor3 = t.IsRGB and Color3.new(1,1,1) or t.Accent
    if t.IsRGB then RegisterRGB(Title, "TextColor3") end

    local SubTitle = Instance.new("TextLabel", LoadingGui)
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0.44, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = (subtitleText or "MODERNIZED INTERFACE"):upper()
    SubTitle.TextColor3 = t.TextSecondary
    SubTitle.TextSize = 12
    SubTitle.Font = Enum.Font.MontserratBold
    SubTitle.TextTransparency = 1
    SubTitle.ZIndex = 9995

    local BarBg = Instance.new("Frame", LoadingGui)
    BarBg.Size = UDim2.new(0.4, 0, 0, 4)
    BarBg.Position = UDim2.new(0.3, 0, 0.62, 0)
    BarBg.BackgroundColor3 = t.IsRGB and Color3.fromRGB(25, 25, 30) or t.SidebarBg
    BarBg.BackgroundTransparency = t.IsRGB and 0 or t.SidebarTransparency
    BarBg.ZIndex = 9995
    Instance.new("UICorner", BarBg)
    
    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.ZIndex = 9995
    Instance.new("UICorner", BarFill)
    BarFill.BackgroundColor3 = t.IsRGB and Color3.new(1,1,1) or t.Accent
    if t.IsRGB then RegisterRGB(BarFill, "BackgroundColor3") end

    local SkipBtn = Instance.new("TextButton", LoadingGui)
    SkipBtn.Size = UDim2.new(0, 110, 0, 32)
    SkipBtn.Position = UDim2.new(0.5, -55, 0.8, 0)
    SkipBtn.BackgroundColor3 = t.IsRGB and Color3.fromRGB(22, 22, 26) or t.ElementBg
    SkipBtn.BackgroundTransparency = t.IsRGB and 0 or t.ElementTransparency
    SkipBtn.Text = "SKIP"
    SkipBtn.TextColor3 = t.TextPrimary
    SkipBtn.Font = Enum.Font.MontserratBold
    SkipBtn.TextSize = 12
    SkipBtn.ZIndex = 10000
    SkipBtn.TextTransparency = 1
    
    local SkipCorner = Instance.new("UICorner", SkipBtn)
    SkipCorner.CornerRadius = UDim.new(0, 6)
    local SkipStroke = Instance.new("UIStroke", SkipBtn)
    SkipStroke.Color = t.ElementStroke
    SkipStroke.Thickness = 1

    local beepSound = Instance.new("Sound", LoadingGui)
    beepSound.SoundId = "rbxassetid://1567483853"
    beepSound.Volume = 0.5

    local function ElectricZapEffect()
        for i = 1, 3 do
            local zap = Instance.new("Frame", LoadingGui)
            zap.BackgroundColor3 = t.Accent
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
        
        UnregisterRGB(Title, "TextColor3")
        UnregisterRGB(BarFill, "BackgroundColor3")
        UnregisterRGB(pStroke, "Color")

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
    ActiveWindowInstance = Window

    local ScreenGui = GetMainGui()

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 330)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    RegisterThemeable(MainFrame, { 
        BackgroundColor3 = "WindowBg",
        BackgroundTransparency = "WindowTransparency"
    })

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    -- Wallpaper/Gambar Pola Latar Belakang Kustom
    local BackgroundImage = Instance.new("ImageLabel", MainFrame)
    BackgroundImage.Name = "UIBackgroundPattern"
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ZIndex = -2
    RegisterThemeable(BackgroundImage, {
        Image = "BgImage",
        ImageTransparency = "BgImageTransparency"
    })

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1
    RegisterRGB(MainStroke, "Color")
    RegisterThemeable(MainStroke, { Color = function(t) return t.IsRGB and MainStroke.Color or t.ElementStroke end })

    -- Header Panel
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 46)
    Header.BorderSizePixel = 0
    RegisterThemeable(Header, { 
        BackgroundColor3 = "HeaderBg", 
        BackgroundTransparency = "HeaderTransparency" 
    })
    
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    
    local BottomHeaderMask = Instance.new("Frame", Header)
    BottomHeaderMask.Size = UDim2.new(1, 0, 0.5, 0)
    BottomHeaderMask.Position = UDim2.new(0, 0, 0.5, 0)
    BottomHeaderMask.BorderSizePixel = 0
    BottomHeaderMask.ZIndex = -1
    RegisterThemeable(BottomHeaderMask, { 
        BackgroundColor3 = "HeaderBg", 
        BackgroundTransparency = "HeaderTransparency" 
    })
    
    EnableDrag(Header, MainFrame)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(0, 300, 0, 18)
    TitleLabel.Position = UDim2.new(0, 16, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText or "LOUIS HUB"
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterThemeable(TitleLabel, { TextColor3 = "TextPrimary" })

    local SubtitleLabel = Instance.new("TextLabel", Header)
    SubtitleLabel.Size = UDim2.new(0, 300, 0, 12)
    SubtitleLabel.Position = UDim2.new(0, 16, 0, 26)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = subtitleText or "Rebuilt Edition"
    SubtitleLabel.TextSize = 9
    SubtitleLabel.Font = Enum.Font.MontserratBold
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterThemeable(SubtitleLabel, { TextColor3 = "TextSecondary" })

    local BarBg = Instance.new("Frame", MainFrame)
    BarBg.Size = UDim2.new(1, 0, 0, 1)
    BarBg.Position = UDim2.new(0, 0, 0, 46)
    BarBg.BorderSizePixel = 0
    RegisterRGB(BarBg, "BackgroundColor3")
    RegisterThemeable(BarBg, { 
        BackgroundTransparency = function(t) return t.IsRGB and 0 or 1 end
    })

    -- Sidebar Container
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 140, 1, -58)
    Sidebar.Position = UDim2.new(0, 12, 0, 52)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
    RegisterThemeable(Sidebar, { 
        BackgroundColor3 = "SidebarBg",
        BackgroundTransparency = "SidebarTransparency"
    })
    
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Thickness = 1
    RegisterThemeable(SidebarStroke, { Color = "ElementStroke" })

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
    RegisterThemeable(ContentArea, { 
        BackgroundColor3 = "ContentBg",
        BackgroundTransparency = "ContentTransparency"
    })

    local ContentStroke = Instance.new("UIStroke", ContentArea)
    ContentStroke.Thickness = 1
    RegisterThemeable(ContentStroke, { Color = "ElementStroke" })

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end)

    local ToggleIcon = Instance.new("ImageButton", Header)
    ToggleIcon.Size = UDim2.new(0, 18, 0, 18)
    ToggleIcon.Position = UDim2.new(1, -52, 0, 14)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Image = "rbxthumb://type=Asset&id=6031094670&w=150&h=150"
    RegisterThemeable(ToggleIcon, { ImageColor3 = "TextSecondary" })

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
            local t = Themes[CurrentThemeName]
            TweenService:Create(Sidebar, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = t.SidebarTransparency}):Play()
            TweenService:Create(ContentArea, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = t.ContentTransparency}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        end
    end)

    local CloseBtn = Instance.new("ImageButton", Header)
    CloseBtn.Size = UDim2.new(0, 18, 0, 18)
    CloseBtn.Position = UDim2.new(1, -28, 0, 14)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = "rbxthumb://type=Asset&id=10734898355&w=150&h=150"
    RegisterThemeable(CloseBtn, { ImageColor3 = "TextSecondary" })

    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 75, 75)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        local t = Themes[CurrentThemeName]
        TweenService:Create(CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {ImageColor3 = t.TextSecondary}):Play()
    end)

    -- [[ 4a. FLOATING ICON OPEN CLOSE ]]
    local FloatingToggle = Instance.new("TextButton", ScreenGui)
    FloatingToggle.Name = "FloatingToggleIcon"
    FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
    FloatingToggle.Position = UDim2.new(0.5, -24, 0.5, -24)
    FloatingToggle.BorderSizePixel = 0
    FloatingToggle.Text = ""
    FloatingToggle.Visible = false
    RegisterThemeable(FloatingToggle, { 
        BackgroundColor3 = "ElementBg",
        BackgroundTransparency = "ElementTransparency"
    })

    local ToggleCorner = Instance.new("UICorner", FloatingToggle)
    ToggleCorner.CornerRadius = UDim.new(0, 8)

    local ToggleStroke = Instance.new("UIStroke", FloatingToggle)
    ToggleStroke.Thickness = 1
    RegisterRGB(ToggleStroke, "Color")
    RegisterThemeable(ToggleStroke, { Color = function(t) return t.IsRGB and ToggleStroke.Color or t.Accent end })

    local ToggleIconImage = Instance.new("ImageLabel", FloatingToggle)
    ToggleIconImage.Name = "Icon"
    ToggleIconImage.Size = UDim2.new(0, 38, 0, 38)
    ToggleIconImage.Position = UDim2.new(0.5, -19, 0.5, -19)
    ToggleIconImage.BackgroundTransparency = 1
    ToggleIconImage.ScaleType = Enum.ScaleType.Fit
    RegisterRGB(ToggleIconImage, "ImageColor3")
    RegisterThemeable(ToggleIconImage, {
        Image = "FloatingIconImage",
        ImageColor3 = function(t) return t.IsRGB and ToggleIconImage.ImageColor3 or Color3.fromRGB(255, 255, 255) end
    })

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
        task.delay(0.1, function()
            OpenGui()
        end)
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
            ApplyTheme(CurrentThemeName)
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
                if Window.Visible then
                    CloseGui()
                else
                    OpenGui()
                end
                task.wait(0.3)
                debounce = false
            end
        end)
    end

    function Window:UpdateAllTabsVisual()
        local t = Themes[CurrentThemeName]
        for _, tabInfo in ipairs(Window.Tabs) do
            local isSelected = (Window.CurrentTab and Window.CurrentTab.Button == tabInfo.Button)
            
            TweenService:Create(tabInfo.Button, TweenInfo.new(0.15), {
                BackgroundTransparency = isSelected and t.ElementTransparency or (t.IsRGB and 1 or t.SidebarTransparency),
                BackgroundColor3 = isSelected and t.ElementBg or t.SidebarBg
            }):Play()
            TweenService:Create(tabInfo.ButtonStroke, TweenInfo.new(0.15), {
                Transparency = isSelected and 0 or (t.IsRGB and 1 or t.SidebarTransparency),
                Color = t.ElementStroke
            }):Play()
            TweenService:Create(tabInfo.Text, TweenInfo.new(0.15), {
                TextColor3 = isSelected and t.TextPrimary or t.TextDark
            }):Play()
            tabInfo.Indicator.Visible = isSelected
            if tabInfo.Icon then
                TweenService:Create(tabInfo.Icon, TweenInfo.new(0.15), {
                    ImageColor3 = isSelected and t.TextPrimary or t.TextDark
                }):Play()
            end
        end
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

        local TabBtnStroke = Instance.new("UIStroke", TabButton)
        TabBtnStroke.Thickness = 1

        local TabIndicator = Instance.new("Frame", TabButton)
        TabIndicator.Size = UDim2.new(0, 2.5, 1, -12)
        TabIndicator.Position = UDim2.new(0, 4, 0, 6)
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = false
        RegisterRGB(TabIndicator, "BackgroundColor3")
        RegisterThemeable(TabIndicator, { BackgroundColor3 = function(t) return t.IsRGB and TabIndicator.BackgroundColor3 or t.Accent end })

        local IconLabel
        if iconAssetId then
            IconLabel = Instance.new("ImageLabel", TabButton)
            IconLabel.Size = UDim2.new(0, 14, 0, 14)
            IconLabel.Position = UDim2.new(0, 10, 0.5, -7)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = resolveIcon(iconAssetId)
        end

        local TabText = Instance.new("TextLabel", TabButton)
        TabText.Size = UDim2.new(1, iconAssetId and -34 or -16, 1, 0)
        TabText.Position = UDim2.new(0, iconAssetId and 28 or 10)
        TabText.BackgroundTransparency = 1
        TabText.Text = tabName
        TabText.TextSize = 11
        TabText.Font = Enum.Font.MontserratMedium
        TabText.TextXAlignment = Enum.TextXAlignment.Left

        local tabData = {
            Button = TabButton,
            ButtonStroke = TabBtnStroke,
            Text = TabText,
            Frame = TabContent,
            Icon = IconLabel,
            Indicator = TabIndicator
        }
        table.insert(Window.Tabs, tabData)

        local function Select()
            if Window.CurrentTab then
                local oldTab = Window.CurrentTab
                local fadeOut = TweenService:Create(oldTab.Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 0.95, -16), Position = UDim2.new(0, 8, 0, 12)})
                fadeOut:Play()
                fadeOut.Completed:Connect(function()
                    oldTab.Frame.Visible = false
                end)
            end
            
            TabContent.Size = UDim2.new(1, -16, 0.95, -16)
            TabContent.Position = UDim2.new(0, 8, 0, 12)
            TabContent.Visible = true
            TweenService:Create(TabContent, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0, 8, 0, 8)}):Play()

            Window.CurrentTab = tabData
            Window:UpdateAllTabsVisual()
        end

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Button == TabButton then return end
            local t = Themes[CurrentThemeName]
            TweenService:Create(TabButton, TweenInfo.new(0.15), {
                BackgroundTransparency = t.IsRGB and 0.5 or t.ElementTransparency,
                BackgroundColor3 = t.IsRGB and Color3.fromRGB(20, 20, 24) or t.ElementBg
            }):Play()
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = t.TextPrimary}):Play()
            if IconLabel then
                TweenService:Create(IconLabel, TweenInfo.new(0.15), {ImageColor3 = t.TextPrimary}):Play()
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Button == TabButton then return end
            local t = Themes[CurrentThemeName]
            TweenService:Create(TabButton, TweenInfo.new(0.15), {
                BackgroundTransparency = t.IsRGB and 1 or t.SidebarTransparency,
                BackgroundColor3 = t.SidebarBg
            }):Play()
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = t.TextDark}):Play()
            if IconLabel then
                TweenService:Create(IconLabel, TweenInfo.new(0.15), {ImageColor3 = t.TextDark}):Play()
            end
        end)

        TabButton.MouseButton1Click:Connect(Select)

        if #Window.Tabs == 1 then
            task.spawn(function()
                repeat task.wait() until MainFrame.Visible == true
                Select()
            end)
        end

        -- ========================================================
        -- [[ 5a. TAB ELEMENT: CREATE BUTTON ]]
        -- ========================================================
        function Tab:CreateButton(buttonText, callback)
            local Button = Instance.new("TextButton", TabContent)
            Button.Size = UDim2.new(1, -6, 0, 34)
            Button.Text = ""
            Button.AutoButtonColor = false
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)
            RegisterThemeable(Button, { 
                BackgroundColor3 = "ElementBg",
                BackgroundTransparency = "ElementTransparency"
            })

            local BtnStroke = Instance.new("UIStroke", Button)
            BtnStroke.Thickness = 1
            RegisterThemeable(BtnStroke, { Color = "ElementStroke" })

            local BtnText = Instance.new("TextLabel", Button)
            BtnText.Size = UDim2.new(1, -35, 1, 0)
            BtnText.Position = UDim2.new(0, 12, 0, 0)
            BtnText.BackgroundTransparency = 1
            BtnText.Text = buttonText or "Button"
            BtnText.TextSize = 11
            BtnText.Font = Enum.Font.MontserratMedium
            BtnText.TextXAlignment = Enum.TextXAlignment.Left
            RegisterThemeable(BtnText, { TextColor3 = "TextPrimary" })

            local ArrowIcon = Instance.new("ImageLabel", Button)
            ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
            ArrowIcon.Position = UDim2.new(1, -22, 0.5, -6)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxthumb://type=Asset&id=6031094678&w=150&h=150"
            RegisterThemeable(ArrowIcon, { ImageColor3 = "TextSecondary" })

            Button.MouseEnter:Connect(function()
                local t = Themes[CurrentThemeName]
                TweenService:Create(Button, TweenInfo.new(0.15), {
                    BackgroundColor3 = t.IsRGB and Color3.fromRGB(28, 28, 33) or t.SidebarBg,
                    BackgroundTransparency = t.IsRGB and 0 or t.SidebarTransparency
                }):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15), {ImageColor3 = t.TextPrimary, Position = UDim2.new(1, -20, 0.5, -6)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                local t = Themes[CurrentThemeName]
                TweenService:Create(Button, TweenInfo.new(0.15), {
                    BackgroundColor3 = t.ElementBg,
                    BackgroundTransparency = t.ElementTransparency
                }):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15), {ImageColor3 = t.TextSecondary, Position = UDim2.new(1, -22, 0.5, -6)}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                local t = Themes[CurrentThemeName]
                local press = TweenService:Create(Button, TweenInfo.new(0.05), {
                    BackgroundColor3 = t.IsRGB and Color3.fromRGB(35, 35, 42) or t.ContentBg,
                    BackgroundTransparency = t.IsRGB and 0 or t.ContentTransparency
                })
                press:Play()
                press.Completed:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.1), {
                        BackgroundColor3 = t.IsRGB and Color3.fromRGB(28, 28, 33) or t.SidebarBg,
                        BackgroundTransparency = t.IsRGB and 0 or t.SidebarTransparency
                    }):Play()
                end)
                if callback then task.spawn(callback) end
            end)
        end

        -- ========================================================
        -- [[ 5b. TAB ELEMENT: CREATE TOGGLE ]]
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
            RegisterThemeable(ToggleBtn, { 
                BackgroundColor3 = "ElementBg",
                BackgroundTransparency = "ElementTransparency"
            })

            local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
            ToggleStroke.Thickness = 1
            RegisterThemeable(ToggleStroke, { Color = "ElementStroke" })

            local TextLabel = Instance.new("TextLabel", ToggleBtn)
            TextLabel.Size = UDim2.new(1, -65, 1, 0)
            TextLabel.Position = UDim2.new(0, 12, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = toggleText or "Toggle"
            TextLabel.TextSize = 11
            TextLabel.Font = Enum.Font.MontserratMedium
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegisterThemeable(TextLabel, { TextColor3 = "TextPrimary" })

            local SwitchBg = Instance.new("Frame", ToggleBtn)
            SwitchBg.Size = UDim2.new(0, 32, 0, 16)
            SwitchBg.Position = UDim2.new(1, -44, 0.5, -8)
            SwitchBg.BorderSizePixel = 0
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

            local SwitchBall = Instance.new("Frame", SwitchBg)
            SwitchBall.Size = UDim2.new(0, 12, 0, 12)
            SwitchBall.Position = UDim2.new(0, 2, 0.5, -6)
            SwitchBall.BorderSizePixel = 0
            Instance.new("UICorner", SwitchBall).CornerRadius = UDim.new(1, 0)
            RegisterThemeable(SwitchBall, { BackgroundColor3 = "TextDark" })

            local function UpdateVisual(animate, ignoreSave)
                local duration = animate and 0.2 or 0
                local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local t = Themes[CurrentThemeName]
                
                if Toggle.State then
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    
                    if t.IsRGB then
                        RegisterRGB(SwitchBg, "BackgroundColor3")
                    else
                        UnregisterRGB(SwitchBg, "BackgroundColor3")
                        TweenService:Create(SwitchBg, info, {BackgroundColor3 = t.Accent}):Play()
                    end
                    
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
                        BackgroundColor3 = t.IsRGB and Color3.fromRGB(24, 24, 30) or t.SidebarBg,
                        BackgroundTransparency = t.IsRGB and 0 or t.SidebarTransparency
                    }):Play()
                else
                    UnregisterRGB(SwitchBg, "BackgroundColor3")
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = t.TextDark}):Play()
                    TweenService:Create(SwitchBg, TweenInfo.new(duration), {BackgroundColor3 = t.IsRGB and Color3.fromRGB(35, 35, 40) or t.ElementStroke}):Play()
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
                        BackgroundColor3 = t.ElementBg,
                        BackgroundTransparency = t.ElementTransparency
                    }):Play()
                end

                Library.Flags[actualFlag] = Toggle.State
                if not ignoreSave then
                    Library:SaveConfig(true)
                end
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
        -- [[ 5c. TAB ELEMENT: CREATE SLIDER ]]
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
            RegisterThemeable(SliderFrame, { 
                BackgroundColor3 = "ElementBg",
                BackgroundTransparency = "ElementTransparency"
            })
            
            local SliderStroke = Instance.new("UIStroke", SliderFrame)
            SliderStroke.Thickness = 1
            RegisterThemeable(SliderStroke, { Color = "ElementStroke" })

            local TitleLabel = Instance.new("TextLabel", SliderFrame)
            TitleLabel.Size = UDim2.new(1, -20, 0, 20)
            TitleLabel.Position = UDim2.new(0, 12, 0, 4)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = sliderText .. ": " .. tostring(Slider.Value)
            TitleLabel.TextSize = 11
            TitleLabel.Font = Enum.Font.MontserratMedium
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegisterThemeable(TitleLabel, { TextColor3 = "TextPrimary" })

            local SliderBg = Instance.new("TextButton", SliderFrame)
            SliderBg.Size = UDim2.new(1, -24, 0, 4)
            SliderBg.Position = UDim2.new(0, 12, 1, -12)
            SliderBg.Text = ""
            SliderBg.AutoButtonColor = false
            Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
            RegisterThemeable(SliderBg, { BackgroundColor3 = function(t) return t.IsRGB and Color3.fromRGB(35, 35, 40) or t.SidebarBg end })

            local SliderFill = Instance.new("Frame", SliderBg)
            SliderFill.Size = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 1, 0)
            SliderFill.BorderSizePixel = 0
            Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
            RegisterRGB(SliderFill, "BackgroundColor3")
            RegisterThemeable(SliderFill, { BackgroundColor3 = function(t) return t.IsRGB and SliderFill.BackgroundColor3 or t.Accent end })

            local function UpdateVisuals(val, ignoreSave)
                Slider.Value = math.clamp(val, minVal, maxVal)
                local percentage = (Slider.Value - minVal) / (maxVal - minVal)
                
                TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                TitleLabel.Text = sliderText .. ": " .. tostring(Slider.Value)
                
                Library.Flags[actualFlag] = Slider.Value
                if not ignoreSave then
                    Library:SaveConfig(true)
                end
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
        -- [[ 5d. TAB ELEMENT: CREATE DROPDOWN ]]
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
            RegisterThemeable(DropdownFrame, { 
                BackgroundColor3 = "ElementBg",
                BackgroundTransparency = "ElementTransparency"
            })
            
            local FrameStroke = Instance.new("UIStroke", DropdownFrame)
            FrameStroke.Thickness = 1
            RegisterThemeable(FrameStroke, { Color = "ElementStroke" })

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
            RegisterThemeable(TextLabel, { TextColor3 = "TextPrimary" })

            local ArrowIcon = Instance.new("ImageLabel", DropdownBtn)
            ArrowIcon.Size = UDim2.new(0, 10, 0, 10)
            ArrowIcon.Position = UDim2.new(1, -22, 0.5, -5)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxthumb://type=Asset&id=6031094670&w=150&h=150"
            RegisterThemeable(ArrowIcon, { ImageColor3 = "TextSecondary" })

            local OptionContainer = Instance.new("Frame", DropdownFrame)
            OptionContainer.Size = UDim2.new(1, -24, 0, 0)
            OptionContainer.Position = UDim2.new(0, 12, 0, 36)
            OptionContainer.BackgroundTransparency = 1

            local OptionList = Instance.new("UIListLayout", OptionContainer)
            OptionList.Padding = UDim.new(0, 4)

            local function Refresh()
                for _, v in ipairs(Dropdown.OptionFrames) do v:Destroy() end
                Dropdown.OptionFrames = {}
                local t = Themes[CurrentThemeName]

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton", OptionContainer)
                    OptBtn.Size = UDim2.new(1, 0, 0, 26)
                    OptBtn.BackgroundColor3 = t.IsRGB and Color3.fromRGB(26, 26, 31) or t.SidebarBg
                    OptBtn.BackgroundTransparency = t.IsRGB and 0 or t.SidebarTransparency
                    OptBtn.Text = ""
                    OptBtn.AutoButtonColor = false
                    Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

                    local OptText = Instance.new("TextLabel", OptBtn)
                    OptText.Size = UDim2.new(1, -20, 1, 0)
                    OptText.Position = UDim2.new(0, 10, 0, 0)
                    OptText.BackgroundTransparency = 1
                    OptText.Text = tostring(opt)
                    OptText.TextSize = 10
                    OptText.TextXAlignment = Enum.TextXAlignment.Left

                    if opt == Dropdown.CurrentValue then
                        OptText.TextColor3 = t.IsRGB and Color3.new(1,1,1) or t.TextPrimary
                        OptText.Font = Enum.Font.MontserratBold
                        
                        local Indicator = Instance.new("Frame", OptBtn)
                        Indicator.Size = UDim2.new(0, 2.5, 1, -8)
                        Indicator.Position = UDim2.new(0, 3, 0, 4)
                        Instance.new("UICorner", Indicator)
                        RegisterRGB(Indicator, "BackgroundColor3")
                        RegisterThemeable(Indicator, { BackgroundColor3 = function(th) return th.IsRGB and Indicator.BackgroundColor3 or th.Accent end })
                    else
                        OptText.TextColor3 = t.TextDark
                        OptText.Font = Enum.Font.Montserrat
                    end

                    OptBtn.MouseEnter:Connect(function()
                        local th = Themes[CurrentThemeName]
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {
                            BackgroundColor3 = th.IsRGB and Color3.fromRGB(32, 32, 38) or th.ElementBg,
                            BackgroundTransparency = th.IsRGB and 0 or th.ElementTransparency
                        }):Play()
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        local th = Themes[CurrentThemeName]
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {
                            BackgroundColor3 = th.IsRGB and Color3.fromRGB(26, 26, 31) or th.SidebarBg,
                            BackgroundTransparency = th.IsRGB and 0 or th.SidebarTransparency
                        }):Play()
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown.CurrentValue = opt
                        TextLabel.Text = dropdownText .. " (" .. tostring(opt) .. ")"
                        Dropdown.Open = false
                        
                        local th = Themes[CurrentThemeName]
                        UnregisterRGB(FrameStroke, "Color")
                        FrameStroke.Color = th.ElementStroke
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, 34)}):Play()
                        TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                        
                        Refresh()
                        
                        Library.Flags[actualFlag] = opt
                        if not actualFlag:find("^__Meta") then
                            Library:SaveConfig(true)
                        end
                        
                        if actualCallback then task.spawn(function() actualCallback(opt) end) end
                    end)

                    table.insert(Dropdown.OptionFrames, OptBtn)
                end
            end

            DropdownBtn.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                local targetHeight = 34
                local rotation = 0
                local th = Themes[CurrentThemeName]
                
                if Dropdown.Open then
                    Refresh()
                    if th.IsRGB then
                        RegisterRGB(FrameStroke, "Color")
                    else
                        UnregisterRGB(FrameStroke, "Color")
                        FrameStroke.Color = th.Accent
                    end
                    OptionContainer.Size = UDim2.new(1, -24, 0, OptionList.AbsoluteContentSize.Y)
                    targetHeight = 34 + (OptionList.AbsoluteContentSize.Y + 8)
                    rotation = 180
                else
                    UnregisterRGB(FrameStroke, "Color")
                    FrameStroke.Color = th.ElementStroke
                    OptionContainer.Size = UDim2.new(1, -24, 0, 0)
                end
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = rotation}):Play()
            end)

            if savedVal ~= nil and actualCallback then
                task.spawn(function() actualCallback(Dropdown.CurrentValue) end)
            end

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
        -- [[ 5e. TAB ELEMENT: CREATE TEXTBOX ]]
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
            RegisterThemeable(TextBoxFrame, { 
                BackgroundColor3 = "ElementBg",
                BackgroundTransparency = "ElementTransparency"
            })
            
            local FrameStroke = Instance.new("UIStroke", TextBoxFrame)
            FrameStroke.Thickness = 1
            RegisterThemeable(FrameStroke, { Color = "ElementStroke" })

            local Label = Instance.new("TextLabel", TextBoxFrame)
            Label.Size = UDim2.new(0.45, -12, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = labelText or "Input Text"
            Label.TextSize = 11
            Label.Font = Enum.Font.MontserratMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            RegisterThemeable(Label, { TextColor3 = "TextPrimary" })

            local InputBox = Instance.new("TextBox", TextBoxFrame)
            InputBox.Size = UDim2.new(0.55, -12, 0, 22)
            InputBox.Position = UDim2.new(0.45, 0, 0.5, -11)
            InputBox.Text = savedVal and tostring(savedVal) or ""
            InputBox.PlaceholderText = placeholderText or "Type here..."
            InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
            InputBox.TextSize = 10
            InputBox.Font = Enum.Font.Montserrat
            Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)
            RegisterThemeable(InputBox, { 
                BackgroundColor3 = function(t) return t.IsRGB and Color3.fromRGB(30, 30, 35) or t.SidebarBg end,
                BackgroundTransparency = function(t) return t.IsRGB and 0 or t.SidebarTransparency end,
                TextColor3 = "TextPrimary"
            })

            local InputStroke = Instance.new("UIStroke", InputBox)
            InputStroke.Thickness = 1
            RegisterThemeable(InputStroke, { Color = "ElementStroke" })

            Library.Flags[actualFlag] = InputBox.Text

            InputBox.Focused:Connect(function()
                local t = Themes[CurrentThemeName]
                TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = t.Accent}):Play()
                TweenService:Create(TextBoxFrame, TweenInfo.new(0.15), {
                    BackgroundColor3 = t.IsRGB and Color3.fromRGB(24, 24, 30) or t.SidebarBg,
                    BackgroundTransparency = t.IsRGB and 0 or t.SidebarTransparency
                }):Play()
            end)

            InputBox.FocusLost:Connect(function(enterPressed)
                local t = Themes[CurrentThemeName]
                TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = t.ElementStroke}):Play()
                TweenService:Create(TextBoxFrame, TweenInfo.new(0.15), {
                    BackgroundColor3 = t.ElementBg,
                    BackgroundTransparency = t.ElementTransparency
                }):Play()
                
                Library.Flags[actualFlag] = InputBox.Text
                Library:SaveConfig(true)
                
                if actualCallback then task.spawn(function() actualCallback(InputBox.Text, enterPressed) end) end
            end)

            if savedVal ~= nil and actualCallback then
                task.spawn(function() actualCallback(InputBox.Text, false) end)
            end

            local textboxController = {}
            textboxController.DefaultValue = ""
            function textboxController:Set(val, ignoreSave, ignoreCallback)
                InputBox.Text = tostring(val)
                
                Library.Flags[actualFlag] = val
                if not ignoreSave then
                    Library:SaveConfig(true)
                end
                
                if actualCallback and not ignoreCallback then 
                    task.spawn(function() actualCallback(val, false) end) 
                end
            end

            Library.Elements[actualFlag] = textboxController
            return textboxController
        end

        -- ========================================================
        -- [[ 5f. TAB ELEMENT: CREATE PARAGRAPH ]]
        -- ========================================================
        function Tab:CreateParagraph(titleText, descText)
            local ParagraphFrame = Instance.new("Frame", TabContent)
            ParagraphFrame.Size = UDim2.new(1, -6, 0, 52)
            Instance.new("UICorner", ParagraphFrame).CornerRadius = UDim.new(0, 5)
            RegisterThemeable(ParagraphFrame, { 
                BackgroundColor3 = "ElementBg",
                BackgroundTransparency = "ElementTransparency"
            })
            
            local FrameStroke = Instance.new("UIStroke", ParagraphFrame)
            FrameStroke.Thickness = 1
            RegisterThemeable(FrameStroke, { Color = "ElementStroke" })

            local TitleLabel = Instance.new("TextLabel", ParagraphFrame)
            TitleLabel.Size = UDim2.new(1, -20, 0, 18)
            TitleLabel.Position = UDim2.new(0, 12, 0, 6)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = titleText or "Section Title"
            TitleLabel.Font = Enum.Font.MontserratBold
            TitleLabel.TextSize = 11
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegisterThemeable(TitleLabel, { TextColor3 = "TextPrimary" })

            local DescLabel = Instance.new("TextLabel", ParagraphFrame)
            DescLabel.Size = UDim2.new(1, -20, 1, -26)
            DescLabel.Position = UDim2.new(0, 12, 0, 22)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = descText or "Description text details."
            DescLabel.Font = Enum.Font.Montserrat
            DescLabel.TextSize = 9
            DescLabel.TextWrapped = true
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            RegisterThemeable(DescLabel, { TextColor3 = "TextSecondary" })
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
    -- [[ 5h. NEW: PERMANENT THEME MANAGER TAB ]]
    -- ========================================================
    local ThemeTab = Window:CreateTab("Theme", "rbxthumb://type=Asset&id=10734963400&w=150&h=150")
    
    ThemeTab:CreateParagraph("Theme Manager", "Customize the interface style to adapt to your desired aesthetic immediately.")

    ThemeTab:CreateDropdown("Selected Theme", {"RGB", "Cute Pastel"}, CurrentThemeName, "__MetaTheme", function(selected)
        ApplyTheme(selected)
    end)

    return Window
end

-- ========================================================
-- [[ 6. EXTERNAL UTILITY BUTTON SYSTEM ]]
-- ========================================================
function Library:CreateExternalButton(id, text, defaultPos, callback)
    local ScreenGui = GetMainGui()

    local ExtBtn = Instance.new("TextButton")
    ExtBtn.Name = "ExternalButton_" .. tostring(id)
    
    -- Penyesuaian Lebar Otomatis Terpadu Berdasarkan Isi Teks
    ExtBtn.AutomaticSize = Enum.AutomaticSize.X
    ExtBtn.Size = UDim2.new(0, 0, 0, 40) -- X menyesuaikan otomatis, Y dikunci 40 piksel
    
    local savedPos = Library.LoadedConfigCache and Library.LoadedConfigCache["ExtBtnPos_" .. tostring(id)]
    if savedPos and type(savedPos) == "table" then
        ExtBtn.Position = UDim2.new(
            savedPos.X_Scale or 0, 
            savedPos.X_Offset or 0, 
            savedPos.Y_Scale or 0, 
            savedPos.Y_Offset or 0
        )
    else
        ExtBtn.Position = defaultPos or UDim2.new(0, 20, 0.5, 0)
    end

    ExtBtn.Text = text or "A"
    ExtBtn.Font = Enum.Font.MontserratBold
    ExtBtn.TextSize = 13
    ExtBtn.AutoButtonColor = false
    ExtBtn.Parent = ScreenGui
    RegisterThemeable(ExtBtn, { 
        BackgroundColor3 = "ElementBg",
        BackgroundTransparency = "ElementTransparency",
        TextColor3 = "TextPrimary" 
    })

    local Corner = Instance.new("UICorner", ExtBtn)
    Corner.CornerRadius = UDim.new(0, 6)

    -- Pembatas Tepi Luar (Padding) agar teks tidak menyentuh dinding tombol saat memanjang
    local Padding = Instance.new("UIPadding", ExtBtn)
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke", ExtBtn)
    Stroke.Thickness = 1
    RegisterRGB(Stroke, "Color")
    RegisterThemeable(Stroke, { Color = function(t) return t.IsRGB and Stroke.Color or t.Accent end })

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
    
    function controller:SetVisible(state)
        ExtBtn.Visible = state
    end
    function controller:SetText(val)
        ExtBtn.Text = tostring(val)
    end
    function controller:SetDragLock(locked)
        ExtBtn:SetAttribute("DragLocked", locked)
    end
    function controller:SetSize(size)
        if typeof(size) == "UDim2" then
            ExtBtn.AutomaticSize = Enum.AutomaticSize.None
            ExtBtn.Size = size
        elseif type(size) == "number" then
            ExtBtn.AutomaticSize = Enum.AutomaticSize.None
            ExtBtn.Size = UDim2.new(0, size, 0, size)
        end
    end

    return controller
end

-- ========================================================
-- [[ 7. REAL-TIME STATS HUD (FPS & PING) ]]
-- ========================================================
function Library:CreateStatsHUD()
    local ScreenGui = GetMainGui()
    
    local HudFrame = Instance.new("Frame")
    HudFrame.Name = "Louis_StatsHUD"
    HudFrame.Size = UDim2.new(0, 150, 0, 28)
    
    local savedPos = Library.LoadedConfigCache and Library.LoadedConfigCache["StatsHUDPos"]
    if savedPos and type(savedPos) == "table" then
        HudFrame.Position = UDim2.new(
            savedPos.X_Scale or 0, 
            savedPos.X_Offset or 0, 
            savedPos.Y_Scale or 0, 
            savedPos.Y_Offset or 0
        )
    else
        HudFrame.Position = UDim2.new(1, -20, 0, 50)
    end

    HudFrame.AnchorPoint = Vector2.new(1, 0)
    HudFrame.BorderSizePixel = 0
    HudFrame.Parent = ScreenGui
    HudFrame.Visible = true
    RegisterThemeable(HudFrame, { 
        BackgroundColor3 = "WindowBg",
        BackgroundTransparency = "WindowTransparency"
    })

    local HudCorner = Instance.new("UICorner", HudFrame)
    HudCorner.CornerRadius = UDim.new(0, 6)

    local HudStroke = Instance.new("UIStroke", HudFrame)
    HudStroke.Thickness = 1
    RegisterRGB(HudStroke, "Color")
    RegisterThemeable(HudStroke, { Color = function(t) return t.IsRGB and HudStroke.Color or t.ElementStroke end })

    local StatLabel = Instance.new("TextLabel", HudFrame)
    StatLabel.Size = UDim2.new(1, 0, 1, 0)
    StatLabel.BackgroundTransparency = 1
    StatLabel.Font = Enum.Font.MontserratBold
    StatLabel.TextSize = 10
    StatLabel.RichText = true
    StatLabel.Text = "FPS: ...  •  PING: ... MS"
    RegisterThemeable(StatLabel, { TextColor3 = "TextPrimary" })

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
        if #fpsHistory > maxHistory then
            table.remove(fpsHistory, 1)
        end
        
        local now = os.clock()
        if now - lastTextUpdate >= textUpdateInterval then
            lastTextUpdate = now
            
            local totalTime = 0
            for _, t in ipairs(fpsHistory) do
                totalTime = totalTime + t
            end
            local currentFps = #fpsHistory > 0 and math.round(#fpsHistory / totalTime) or 60
            
            local currentPing = 0
            if LocalPlayer then
                local success, rawPing = pcall(function()
                    return LocalPlayer:GetNetworkPing()
                end)
                if success and rawPing and rawPing > 0 then
                    currentPing = math.round(rawPing * 1000)
                end
            end
            
            local isPastel = (CurrentThemeName == "Cute Pastel")
            local colorFps = isPastel and "rgb(50, 160, 100)" or "rgb(0, 255, 120)"
            local colorPing = isPastel and "rgb(50, 120, 220)" or "rgb(0, 180, 255)"
            
            StatLabel.Text = string.format("FPS: <font color='%s'>%d</font>  •  PING: <font color='%s'>%d MS</font>", colorFps, currentFps, colorPing, currentPing)
        end
    end)

    local hudController = {}
    function hudController:SetVisible(state)
        HudFrame.Visible = state
    end
    
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
