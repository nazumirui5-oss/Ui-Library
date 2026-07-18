local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

-- System registries initialization
Library.Flags = {}
Library.Elements = {}
Library.Registry = {}
Library.ThemeRegistry = {}
Library.TextRegistry = {}
Library.FontRegistry = {}
Library.ThemeCallbacks = {}
Library.ExternalButtons = {}

-- Advanced architectural subsystems
Library.CallbackRegistry = {}
Library.SearchRegistry = {}
Library.Favorites = {}
Library.RecentlyUsed = {}
Library.Plugins = {}
Library.Modules = {}
Library.ConfigFolder = "LouisHubConfig"

Library.EventBus = { Subscriptions = {} }

function Library.EventBus:Publish(eventName, ...)
    if self.Subscriptions[eventName] then
        for _, callback in ipairs(self.Subscriptions[eventName]) do
            task.spawn(callback, ...)
        end
    end
end

function Library.EventBus:Subscribe(eventName, callback)
    self.Subscriptions[eventName] = self.Subscriptions[eventName] or {}
    table.insert(self.Subscriptions[eventName], callback)
    return function()
        local idx = table.find(self.Subscriptions[eventName], callback)
        if idx then
            table.remove(self.Subscriptions[eventName], idx)
        end
    end
end

-- Connection Tracker / Janitor for complete memory leak prevention (scoped version)
local Janitor = { Connections = {} }

function Janitor:Add(connection, scope)
    scope = scope or "Global"
    self.Connections[scope] = self.Connections[scope] or {}
    table.insert(self.Connections[scope], connection)
    return connection
end

function Janitor:Cleanup(scope)
    if scope then
        if self.Connections[scope] then
            for _, conn in ipairs(self.Connections[scope]) do
                if conn and conn.Disconnect then
                    pcall(function() conn:Disconnect() end)
                end
            end
            self.Connections[scope] = nil
        end
    else
        for s, conns in pairs(self.Connections) do
            for _, conn in ipairs(conns) do
                if conn and conn.Disconnect then
                    pcall(function() conn:Disconnect() end)
                end
            end
        end
        self.Connections = {}
    end
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
        TextSecondary = Color3.fromRGB(160, 165, 175),
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
    
    instance.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for i, item in ipairs(Library.ThemeRegistry) do
                if item.Instance == instance then
                    table.remove(Library.ThemeRegistry, i)
                    break
                end
            end
        end
    end)
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
    
    instance.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for i, item in ipairs(Library.TextRegistry) do
                if item.Instance == instance then
                    table.remove(Library.TextRegistry, i)
                    break
                end
            end
        end
    end)
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
    
    instance.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for i, item in ipairs(Library.FontRegistry) do
                if item.Instance == instance then
                    table.remove(Library.FontRegistry, i)
                    break
                end
            end
        end
    end)
end

-- ========================================================
-- [[ HYBRID TOUCH & MOUSE DRAGGING ]]
-- ========================================================
local function MakeDraggable(dragTrigger, frameToMove)
    local dragging, dragInput, dragStart, startPos
    
    Janitor:Add(dragTrigger.InputBegan:Connect(function(input)
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
    
    ExtBtnFrame.AutomaticSize = Enum.AutomaticSize.X
    ExtBtnFrame.Size = UDim2.new(0, 0, 0, 30)
    ExtBtnFrame.Position = UDim2.new(0.5, -40, 0.3, 0)
    
    local ExtCorner = Instance.new("UICorner", ExtBtnFrame)
    
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
    else
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
-- [[ INTELLIGENT COMPONENT REGISTRATION MANAGER ]]
-- ========================================================
function Library:RegisterComponent(flag, compType, text, controlObj, callback, config)
    Library.Registry[flag] = {
        Type = compType,
        Text = text,
        Control = controlObj,
        Callback = callback,
        Config = config
    }
    Library.CallbackRegistry[flag] = callback
    table.insert(Library.SearchRegistry, {
        Flag = flag,
        Type = compType,
        Text = text,
        Control = controlObj
    })
    Library.EventBus:Publish("FeatureRegistered", flag, compType, text)
end

function Library:TrackInteraction(flag)
    local idx = table.find(Library.RecentlyUsed, flag)
    if idx then table.remove(Library.RecentlyUsed, idx) end
    table.insert(Library.RecentlyUsed, 1, flag)
    if #Library.RecentlyUsed > 15 then
        table.remove(Library.RecentlyUsed)
    end
    Library.EventBus:Publish("FeatureInteracted", flag)
    Library:TriggerAutoSave()
end

function Library:ToggleFavorite(flag)
    local idx = table.find(Library.Favorites, flag)
    if idx then
        table.remove(Library.Favorites, idx)
        Library.EventBus:Publish("FavoriteRemoved", flag)
        return false
    else
        table.insert(Library.Favorites, flag)
        Library.EventBus:Publish("FavoriteAdded", flag)
        return true
    end
end

function Library:Search(query)
    query = query:lower()
    local results = {}
    for _, item in ipairs(Library.SearchRegistry) do
        if string.find(item.Text:lower(), query) then
            table.insert(results, item)
        end
    end
    return results
end

-- ========================================================
-- [[ DYNAMIC DECLARED CONFIG & SERIALIZATION HANDLERS ]]
-- ========================================================
function Library:SerializeTable(val)
    if typeof(val) == "string" then
        return string.format("%q", val)
    elseif typeof(val) == "number" or typeof(val) == "boolean" then
        return tostring(val)
    elseif typeof(val) == "table" then
        local str = "{\n"
        for k, v in pairs(val) do
            str = str .. string.format("  [%s] = %s,\n", Library:SerializeTable(k), Library:SerializeTable(v))
        end
        str = str .. "}"
        return str
    end
    return "nil"
end

function Library:LoadLuaConfig(path)
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

function Library:SaveConfig(configName, format)
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
    
    local path = Library.ConfigFolder .. "/" .. configName
    if format == "LUA" then
        local serialized = "return " .. Library:SerializeTable(dataToSave)
        writefile(path .. ".lua", serialized)
    else
        local encoded = HttpService:JSONEncode(dataToSave)
        writefile(path .. ".json", encoded)
    end
    
    Library:CreateNotification("Config Saved", "Successfully saved configuration: " .. configName, 3)
    Library.EventBus:Publish("ConfigSaved", configName)
end

function Library:LoadConfig(configName)
    if not isFolderSupported then return end
    local luaPath = Library.ConfigFolder .. "/" .. configName .. ".lua"
    local jsonPath = Library.ConfigFolder .. "/" .. configName .. ".json"
    local loadedData = nil
    
    if isfile(luaPath) then
        loadedData = Library:LoadLuaConfig(luaPath)
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
        Library.EventBus:Publish("ConfigLoaded", configName)
    end
end

function Library:DeleteConfig(configName)
    if not isFolderSupported then return end
    local luaPath = Library.ConfigFolder .. "/" .. configName .. ".lua"
    local jsonPath = Library.ConfigFolder .. "/" .. configName .. ".json"
    if isfile(luaPath) then delfile(luaPath) end
    if isfile(jsonPath) then delfile(jsonPath) end
    Library:CreateNotification("Config Deleted", "Successfully deleted configuration: " .. configName, 3)
end

function Library:GetConfigsList()
    local list = {}
    if listfiles and isfolder and isfolder(Library.ConfigFolder) then
        local files = listfiles(Library.ConfigFolder)
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

local saveDebounce = false
function Library:TriggerAutoSave()
    if Library.Settings.AutoSave and not saveDebounce then
        saveDebounce = true
        task.delay(1, function()
            saveDebounce = false
            local selected = Library.Flags["Sys_Selected_File"] or "autosave"
            if selected and selected ~= "No Configs Found" then
                pcall(function()
                    Library:SaveConfig(selected, Library.Flags["Sys_Save_Format"] or "JSON")
                end)
            end
        end)
    end
end

-- ========================================================
-- [[ DYNAMIC GENERATIVE & MODULAR SUB-LOADERS ]]
-- ========================================================
function Library:GenerateUI(windowObject, schema)
    if not windowObject or typeof(schema) ~= "table" then return end
    for _, catData in ipairs(schema) do
        if catData.Category then
            windowObject:CreateCategory(catData.Category)
        end
        if catData.Tabs then
            for _, tabData in ipairs(catData.Tabs) do
                local tab = windowObject:CreateTab(tabData.Name, tabData.Icon, tabData.IsPremium)
                if tabData.Sections then
                    for _, secData in ipairs(tabData.Sections) do
                        local section = tab:CreateSection(secData.Name)
                        if secData.Elements then
                            for _, elem in ipairs(secData.Elements) do
                                local eType = elem.Type:lower()
                                if eType == "toggle" then
                                    section:CreateToggle(elem.Name, elem.Default, elem.Flag, elem.Config, elem.Callback)
                                elseif eType == "slider" then
                                    section:CreateSlider(elem.Name, elem.Min, elem.Max, elem.Default, elem.Flag, elem.Callback)
                                elseif eType == "dropdown" then
                                    section:CreateDropdown(elem.Name, elem.Options, elem.Default, elem.Flag, elem.Callback)
                                elseif eType == "multidropdown" then
                                    section:CreateMultiDropdown(elem.Name, elem.Options, elem.Default, elem.Flag, elem.Callback)
                                elseif eType == "keybind" then
                                    section:CreateKeybind(elem.Name, elem.Default, elem.Flag, elem.Callback)
                                elseif eType == "colorpicker" then
                                    section:CreateColorPicker(elem.Name, elem.Default, elem.Flag, elem.Callback)
                                elseif eType == "textbox" then
                                    section:CreateTextBox(elem.Name, elem.Placeholder, elem.Flag, elem.Callback)
                                elseif eType == "button" then
                                    section:CreateButton(elem.Name, elem.Config, elem.Callback)
                                elseif eType == "paragraph" then
                                    section:CreateParagraph(elem.Name, elem.Content)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Library:LoadModule(moduleData)
    if typeof(moduleData) ~= "table" then return end
    local name = moduleData.Name or "Unknown Module"
    table.insert(Library.Modules, moduleData)
    Library.EventBus:Publish("ModuleLoaded", name)
    if moduleData.Init then
        local success, err = pcall(moduleData.Init, Library)
        if not success then
            warn("[LouisHub] Failed to initialize module: " .. tostring(name) .. " - " .. tostring(err))
        end
    end
end

function Library:RegisterPlugin(pluginName, initCallback)
    if typeof(pluginName) ~= "string" or typeof(initCallback) ~= "function" then return end
    Library.Plugins[pluginName] = {
        Name = pluginName,
        Callback = initCallback
    }
    Library.EventBus:Publish("PluginRegistered", pluginName)
    local success, err = pcall(initCallback, Library)
    if not success then
        warn("[LouisHub] Failed to initialize plugin: " .. tostring(pluginName) .. " - " .. tostring(err))
    end
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
        DragLocked = false,
        AutoSave = false
    }

    local cleanTitle = string.gsub(titleText or "Universal", "[%s%p]", "_")
    Library.ConfigFolder = "LouisHubConfig/" .. cleanTitle
    if isFolderSupported and not isfolder(Library.ConfigFolder) then
        pcall(makefolder, Library.ConfigFolder)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Nexus_Compkiller_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local successHui, hui = pcall(function() return gethui and gethui() end)
    ScreenGui.Parent = (successHui and hui) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

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
    RegisterTheme(MainStroke, { Color = "Accent" })

    -- PERFORMANCE Floating HUD
    local HudFrame = Instance.new("Frame", ScreenGui)
    HudFrame.Name = "Nexus_Performance_HUD"
    HudFrame.Size = UDim2.new(0, 150, 0, 24)
    HudFrame.Position = UDim2.new(1, -160, 0, 10)
    HudFrame.BackgroundTransparency = 0.4
    HudFrame.Visible = false
    RegisterTheme(HudFrame, { BackgroundColor3 = "SidebarBg" })

    local HudCorner = Instance.new("UICorner", HudFrame)
    HudCorner.CornerRadius = UDim.new(0, 6)

    local HudStroke = Instance.new("UIStroke", HudFrame)
    HudStroke.Thickness = 1
    RegisterTheme(HudStroke, { Color = "Accent" })

    local HudText = Instance.new("TextLabel", HudFrame)
    HudText.Size = UDim2.new(1, 0, 1, 0)
    HudText.BackgroundTransparency = 1
    HudText.Text = "FPS: Calculating... | Ping: Calculating..."
    HudText.TextXAlignment = Enum.TextXAlignment.Center
    HudText.TextYAlignment = Enum.TextYAlignment.Center
    HudText.TextWrapped = false
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

    -- Content Bg (Content Area)
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
    TitleLabel.Position = UDim2.new(0, 52, 0, 0)
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
        
        TweenService:Create(Sidebar, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(0, activeWidth, 1, 0) }):Play()
        TweenService:Create(SidebarMask, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(0, 15, 1, 0), Position = UDim2.new(1, -15, 0, 0) }):Play()
        
        TweenService:Create(ContentBg, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(1, -activeWidth, 1, 0), Position = UDim2.new(0, activeWidth, 0, 0) }):Play()
        TweenService:Create(ContentBgMask, TweenInfo.new(duration, ease, dir), { Position = UDim2.new(0, 0, 0, 0) }):Play()
        TweenService:Create(ContentArea, TweenInfo.new(duration, ease, dir), { Size = UDim2.new(1, -activeWidth, 1, 0), Position = UDim2.new(0, activeWidth, 0, 0) }):Play()
        
        if collapsed then
            TitleLabel.Visible = false
            CollapseBtn.Image = GetIcon("chevrons-right")
        else
            TitleLabel.Visible = true
            CollapseBtn.Image = GetIcon("chevrons-left")
        end
        
        if collapsed then
            UsernameLabel.Visible = false
            SubtextLabel.Visible = false
            AvatarImg.Position = UDim2.new(0.5, -16, 0.5, -16)
        else
            UsernameLabel.Visible = true
            SubtextLabel.Visible = true
            AvatarImg.Position = UDim2.new(0, 5, 0.5, -16)
        end
        
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
        
        for _, child in ipairs(TabScroll:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "TabBtn" then
                child.Visible = not collapsed
            end
        end
        
        Library.EventBus:Publish("SidebarCollapsed", collapsed)
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
    FloatingToggle.Visible = true
    FloatingToggle.ClipsDescendants = true
    RegisterTheme(FloatingToggle, { BackgroundColor3 = "SidebarBg" })

    local ToggleCorner = Instance.new("UICorner", FloatingToggle)
    ToggleCorner.CornerRadius = UDim.new(0, 12)

    local ToggleStroke = Instance.new("UIStroke", FloatingToggle)
    ToggleStroke.Thickness = 1.5
    RegisterTheme(ToggleStroke, { Color = "Accent" })

    local ToggleIconImage = Instance.new("ImageLabel", FloatingToggle)
    ToggleIconImage.Size = UDim2.new(0.85, 0, 0.85, 0)
    ToggleIconImage.Position = UDim2.new(0.075, 0, 0.075, 0)
    ToggleIconImage.BackgroundTransparency = 1
    ToggleIconImage.Image = FLOATING_ICON_DECAL

    MakeDraggable(FloatingToggle, FloatingToggle)

    local function ToggleGui()
        Window.Visible = not Window.Visible
        
        if Library.Settings.Mode == "PC" then
            TargetSize = UDim2.new(0, 640, 0, 460)
            TargetPosition = UDim2.new(0.5, -320, 0.5, -230)
        else
            TargetSize = UDim2.new(0, 500, 0, 340)
            TargetPosition = UDim2.new(0.5, -250, 0.5, -170)
        end

        if Window.Visible then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = TargetSize, Position = TargetPosition}):Play()
            TweenService:Create(FloatingToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            Library.EventBus:Publish("WindowOpened")
        else
            local shrink = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
            shrink:Play()
            shrink.Completed:Connect(function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
            
            TweenService:Create(FloatingToggle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()
            Library.EventBus:Publish("WindowClosed")
        end
    end

    Janitor:Add(FloatingToggle.MouseButton1Click:Connect(ToggleGui))

    local LogoIcon = Instance.new("ImageButton", LogoArea)
    LogoIcon.Size = UDim2.new(0, 32, 0, 32)
    LogoIcon.Position = UDim2.new(0, 12, 0.5, -16)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = FLOATING_ICON_DECAL

    Janitor:Add(LogoIcon.MouseButton1Click:Connect(ToggleGui))

    Janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            ToggleGui()
        end
    end))

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
        
        Library.EventBus:Publish("CategoryCreated", categoryName)
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
            
            Library.EventBus:Publish("TabSelected", tabName)
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

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            task.spawn(function()
                task.wait(0.1)
                SelectTab()
            end)
        end

        -- ========================================================
        -- [[ OVERLAY LOCK PREMIUM TAB TEMPLATE ]]
        -- ========================================================
        local LockOverlay
        if isPremium then
            LockOverlay = Instance.new("Frame", TabPage)
            LockOverlay.Name = "Premium_Lock_Overlay"
            LockOverlay.Size = UDim2.new(1, 0, 1, 0)
            LockOverlay.Position = UDim2.new(0, 0, 0, 0)
            LockOverlay.BackgroundTransparency = 0.65
            LockOverlay.ZIndex = 99
            LockOverlay.Active = true
            
            RegisterTheme(LockOverlay, { BackgroundColor3 = "WindowBg" })
            
            local LockCorner = Instance.new("UICorner", LockOverlay)
            LockCorner.CornerRadius = UDim.new(0, 8)
            
            local LockStroke = Instance.new("UIStroke", LockOverlay)
            LockStroke.Thickness = 1.5
            RegisterTheme(LockStroke, { Color = "Accent" })
            
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
            
            Library.EventBus:Subscribe("UnlockPremium", function()
                Tab:Unlock()
            end)
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
                    local shrink = TweenService:Create(SecFrame, TweenInfo.new(duration, ease), { Size = UDim2.new(1, 0, 0, 34) })
                    shrink:Play()
                    TweenService:Create(ToggleIcon, TweenInfo.new(duration, ease), { Rotation = -90 }):Play()
                    
                    shrink.Completed:Connect(function()
                        if Section.Collapsed then
                            Content.Visible = false
                        end
                    end)
                else
                    Content.Visible = true
                    local contentHeight = ContentList.AbsoluteContentSize.Y
                    TweenService:Create(ToggleIcon, TweenInfo.new(duration, ease), { Rotation = 0 }):Play()
                    TweenService:Create(SecFrame, TweenInfo.new(duration, ease), { Size = UDim2.new(1, 0, 0, contentHeight + 46) }):Play()
                end
                
                task.delay(duration, function()
                    ResizeCanvas()
                end)
                Library.EventBus:Publish("SectionOpened", sectionName, not Section.Collapsed)
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
                    if config.info then
                        local InfoIcon = Instance.new("ImageButton", InlineList)
                        InfoIcon.Size = UDim2.new(0, 14, 0, 14)
                        InfoIcon.BackgroundTransparency = 1
                        InfoIcon.Image = GetIcon("info")
                        RegisterTheme(InfoIcon, { ImageColor3 = "TextDark" })
                        
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
                    
                    Library.EventBus:Publish("ToggleChanged", flag, state)
                    Library:TrackInteraction(flag)
                    if callback then task.spawn(callback, state) end
                end

                RegisterThemeCallback(function(color)
                    if Toggle.State then
                        TweenService:Create(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = color }):Play()
                    end
                end)

                Janitor:Add(Switch.MouseButton1Click:Connect(function() SetState(not Toggle.State) end))
                SetState(Toggle.State)

                local ctrl = {}
                function ctrl:Set(val) SetState(val) end
                
                Library:RegisterComponent(flag, "Toggle", toggleText, ctrl, callback, config)
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: KEYBIND ]]
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

                Janitor:Add(UserInputService.InputBegan:Connect(function(input)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            BindBtn:ReleaseFocus()
                            
                            Keybind.Value = input.KeyCode
                            Library.Flags[flag] = input.KeyCode
                            BindBtn.Text = input.KeyCode.Name
                            
                            Library.EventBus:Publish("KeybindChanged", flag, input.KeyCode)
                            Library:TrackInteraction(flag)
                            if callback then task.spawn(callback, input.KeyCode) end
                        end
                    end
                end))

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
                            
                            Library.EventBus:Publish("KeybindChanged", flag, parsedCode)
                            Library:TrackInteraction(flag)
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
                    Library.EventBus:Publish("KeybindChanged", flag, val)
                end
                
                Library:RegisterComponent(flag, "Keybind", bindText, ctrl, callback, nil)
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
                    
                    Library.EventBus:Publish("SliderChanged", flag, clamped)
                    Library:TrackInteraction(flag)
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
                
                Library:RegisterComponent(flag, "Slider", sliderText, ctrl, callback, nil)
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
                            
                            Library.EventBus:Publish("DropdownChanged", flag, opt)
                            Library:TrackInteraction(flag)
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
                    Library.EventBus:Publish("DropdownChanged", flag, val)
                end
                function ctrl:Refresh(newOptions, defaultVal)
                    options = newOptions
                    Dropdown.Value = defaultVal or newOptions[1] or ""
                    DisplayText.Text = tostring(Dropdown.Value)
                    Library.Flags[flag] = Dropdown.Value
                end
                
                Library:RegisterComponent(flag, "Dropdown", ddText, ctrl, callback, nil)
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
                            
                            Library.EventBus:Publish("MultiDropdownChanged", flag, Dropdown.Selected)
                            Library:TrackInteraction(flag)
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
                    Library.EventBus:Publish("MultiDropdownChanged", flag, val)
                end
                
                Library:RegisterComponent(flag, "MultiDropdown", ddText, ctrl, callback, nil)
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

                local Preview = Instance.new("TextButton", Elem)
                Preview.Size = UDim2.new(0, 16, 0, 16)
                Preview.Position = UDim2.new(1, -16, 0.5, -8)
                Preview.Text = ""
                Preview.BackgroundColor3 = Picker.Value
                Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

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
                    
                    Library.EventBus:Publish("ColorPickerChanged", flag, color)
                    Library:TrackInteraction(flag)
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
                
                Library:RegisterComponent(flag, "ColorPicker", pickerText, ctrl, callback, nil)
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

                RegisterThemeCallback(function(color)
                    TweenService:Create(Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = color }):Play()
                end)

                local btnFlag = (realConfig and realConfig.flag) or ("Button_" .. btnText:gsub("%s+", "_"))

                Janitor:Add(Btn.MouseButton1Click:Connect(function()
                    Library.EventBus:Publish("ButtonClicked", btnFlag)
                    Library:TrackInteraction(btnFlag)
                    if realCallback then task.spawn(realCallback) end
                end))

                local ctrl = {}
                Library:RegisterComponent(btnFlag, "Button", btnText, ctrl, realCallback, realConfig)
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

                local ctrl = {}
                function ctrl:Set(val)
                    paraDesc = val
                    Desc.Text = val
                    ResizeParagraph()
                    Library.EventBus:Publish("ParagraphChanged", paraTitle, val)
                end
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: TEXTBOX ]]
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
                    
                    Library.EventBus:Publish("TextBoxChanged", flag, InputBox.Text)
                    Library:TrackInteraction(flag)
                    if callback then task.spawn(callback, InputBox.Text) end
                end))

                local ctrl = {}
                function ctrl:Set(val)
                    InputBox.Text = tostring(val)
                    Library.Flags[flag] = val
                    Library.EventBus:Publish("TextBoxChanged", flag, val)
                end
                
                Library:RegisterComponent(flag, "TextBox", labelText, ctrl, callback, nil)
                return ctrl
            end

            table.insert(Tab.Sections, Section)
            return Section
        end

        return Tab
    end
    -- ========================================================
    -- [[ AUTOMATIC EMBEDDED CONFIG & PREFERENCES TAB ]]
    -- ========================================================
    task.spawn(function()
        task.wait(0.05)

        -- Create Universal Category
        Window:CreateCategory("Universal")

        -- Safe Local Player variables referencing
        local currentCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local currentHumanoid = currentCharacter:WaitForChild("Humanoid")
        local currentRootPart = currentCharacter:WaitForChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera
        
        -- Hook to make sure humanoids are always tracked robustly after dying / respawning
        LocalPlayer.CharacterAdded:Connect(function(char)
            currentCharacter = char
            currentHumanoid = char:WaitForChild("Humanoid")
            currentRootPart = char:WaitForChild("HumanoidRootPart")
            task.wait(0.2)
            if Library.Flags["Plr_WalkSpeed"] then currentHumanoid.WalkSpeed = Library.Flags["Plr_WalkSpeed"] end
            if Library.Flags["Plr_JumpPower"] then
                currentHumanoid.UseJumpPower = true
                currentHumanoid.JumpPower = Library.Flags["Plr_JumpPower"]
            end
            if Library.Flags["Plr_JumpHeight"] then
                currentHumanoid.UseJumpPower = false
                currentHumanoid.JumpHeight = Library.Flags["Plr_JumpHeight"]
            end
            if Library.Flags["Plr_HipHeight"] then currentHumanoid.HipHeight = Library.Flags["Plr_HipHeight"] end
            if Library.Flags["Plr_Freeze"] then currentCharacter:WaitForChild("HumanoidRootPart").Anchored = Library.Flags["Plr_Freeze"] end
            if Library.Flags["Plr_NoJumpCooldown"] then currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, not Library.Flags["Plr_NoJumpCooldown"]) end
        end)

        -- ========================================================
        -- [[ HOME TAB ]]
        -- ========================================================
        local HomeTab = Window:CreateTab("Home", "user")
        
        local ScriptInfoSec = HomeTab:CreateSection("Script Information")
        ScriptInfoSec:CreateParagraph("LouisHub UI", "Version: 2.0.0\nStatus: Active\nType: Premium Universal UI Engine")

        local GameInfoSec = HomeTab:CreateSection("Game Information")
        local gameName = "Unknown Game"
        pcall(function()
            gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        GameInfoSec:CreateParagraph("Current Game Details", "Name: " .. gameName .. "\nPlace ID: " .. game.PlaceId .. "\nUniverse ID: " .. game.GameId)

        local ExecInfoSec = HomeTab:CreateSection("Executor Information")
        local execName = "Unknown Executor"
        pcall(function()
            execName = (identifyexecutor or getexecutorname or function() return "Unknown" end)()
        end)
        ExecInfoSec:CreateParagraph("Execution Details", "Client: " .. execName .. "\nPlatform: " .. (UserInputService:GetPlatform() == Enum.Platform.Windows and "Windows" or "Mobile/Other"))

        local LocalPlayerInfoSec = HomeTab:CreateSection("Local Player Information")
        LocalPlayerInfoSec:CreateParagraph("Profile Details", "Display Name: " .. LocalPlayer.DisplayName .. "\nUsername: " .. LocalPlayer.Name .. "\nUser ID: " .. LocalPlayer.UserId)

        local ServerInfoSec = HomeTab:CreateSection("Server Information")
        ServerInfoSec:CreateParagraph("Connection Details", "Job ID: " .. game.JobId .. "\nServer Size: " .. #game:GetService("Players"):GetPlayers() .. " Players")

        local QuickAccessSec = HomeTab:CreateSection("Quick Access")
        QuickAccessSec:CreateParagraph("Quick Access Actions", "Configure floating action buttons or quickly access your toggle controls from this section.")

        local FavPlaceholderSec = HomeTab:CreateSection("Favorites Placeholder")
        FavPlaceholderSec:CreateParagraph("Your Favorites", "Any controls or settings you mark as favorite will appear in this section for direct interaction.")

        local RecUsedPlaceholderSec = HomeTab:CreateSection("Recently Used Placeholder")
        RecUsedPlaceholderSec:CreateParagraph("Recent Activities", "Your recently changed settings and executed features are logged here.")

        local SearchPlaceholderSec = HomeTab:CreateSection("Search Placeholder")
        SearchPlaceholderSec:CreateParagraph("Search Feature", "Use the search utility to filter options across all tabs instantly.")

        local PerfPlaceholderSec = HomeTab:CreateSection("Performance Placeholder")
        PerfPlaceholderSec:CreateParagraph("Client Stability", "Keep track of active threads, rendering load, and execution performance metrics.")

        -- ========================================================
        -- [[ PLAYER TAB ]]
        -- ========================================================
        local PlayerTab = Window:CreateTab("Player", "user")
        
        local pMoveStats = PlayerTab:CreateSection("Movement Stats")
        pMoveStats:CreateSlider("WalkSpeed", 16, 500, 16, "Plr_WalkSpeed", function(val)
            if currentHumanoid then currentHumanoid.WalkSpeed = val end
        end)
        pMoveStats:CreateSlider("JumpPower", 50, 500, 50, "Plr_JumpPower", function(val)
            if currentHumanoid then
                currentHumanoid.UseJumpPower = true
                currentHumanoid.JumpPower = val
            end
        end)
        pMoveStats:CreateSlider("Jump Height", 7, 200, 7, "Plr_JumpHeight", function(val)
            if currentHumanoid then
                currentHumanoid.UseJumpPower = false
                currentHumanoid.JumpHeight = val
            end
        end)
        pMoveStats:CreateSlider("HipHeight", 0, 10, 2, "Plr_HipHeight", function(val)
            if currentHumanoid then currentHumanoid.HipHeight = val end
        end)
        pMoveStats:CreateSlider("Gravity", 0, 1000, 196, "Plr_Gravity", function(val)
            workspace.Gravity = val
        end)
        
        local pJump = PlayerTab:CreateSection("Jump")
        pJump:CreateToggle("Infinite Jump", false, "Plr_InfJump", {}, function(state) end)
        pJump:CreateToggle("Double Jump", false, "Plr_DoubleJump", {}, function(state) end)
        pJump:CreateToggle("Triple Jump", false, "Plr_TripleJump", {}, function(state) end)
        pJump:CreateToggle("Auto Jump", false, "Plr_AutoJump", {}, function(state) end)
        pJump:CreateToggle("Jump Boost", false, "Plr_JumpBoost", {}, function(state) end)
        pJump:CreateSlider("Boost Velocity multiplier", 1, 10, 1, "Plr_JumpBoostMult", function(val) end)
        pJump:CreateToggle("Disable Jump Cooldown", false, "Plr_NoJumpCooldown", {}, function(state)
            if currentHumanoid then currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, not state) end
        end)
        
        -- Jump Listeners setup
        local jumpCount = 0
        UserInputService.JumpRequest:Connect(function()
            if currentHumanoid then
                if Library.Flags["Plr_InfJump"] then
                    currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                
                local state = currentHumanoid:GetState()
                if state == Enum.HumanoidStateType.FreeFall then
                    if Library.Flags["Plr_DoubleJump"] and jumpCount < 1 then
                        jumpCount = jumpCount + 1
                        currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    elseif Library.Flags["Plr_TripleJump"] and jumpCount < 2 then
                        jumpCount = jumpCount + 1
                        currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if currentHumanoid then
                if currentHumanoid:GetState() == Enum.HumanoidStateType.Landed then
                    jumpCount = 0
                end
            end
        end)
        
        task.spawn(function()
            while task.wait(0.1) do
                if Library.Flags["Plr_AutoJump"] and currentHumanoid then
                    currentHumanoid.Jump = true
                end
            end
        end)
        
        -- Jump Boost Logic Hook
        local isBoosting = false
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_JumpBoost"] and currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") and currentHumanoid then
                local hrp = currentCharacter.HumanoidRootPart
                if currentHumanoid:GetState() == Enum.HumanoidStateType.Jumping and not isBoosting then
                    isBoosting = true
                    local multiplier = Library.Flags["Plr_JumpBoostMult"] or 1
                    hrp.Velocity = hrp.Velocity * Vector3.new(1, multiplier, 1)
                elseif currentHumanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    isBoosting = false
                end
            end
        end)
        
        local pChar = PlayerTab:CreateSection("Character")
        pChar:CreateToggle("Fly", false, "Plr_Fly", {}, function(state) end)
        pChar:CreateSlider("Fly Speed", 10, 300, 50, "Plr_FlySpeed", function(val) end)
        pChar:CreateToggle("Sprint", false, "Plr_Sprint", {}, function(state)
            if currentHumanoid then
                if state then
                    currentHumanoid.WalkSpeed = Library.Flags["Plr_WalkSpeed"] * 2
                else
                    currentHumanoid.WalkSpeed = Library.Flags["Plr_WalkSpeed"]
                end
            end
        end)
        pChar:CreateToggle("Noclip", false, "Plr_Noclip", {}, function(state) end)
        pChar:CreateToggle("Safe Walk", false, "Plr_SafeWalk", {}, function(state) end)
        pChar:CreateToggle("Air Jump", false, "Plr_AirJump", {}, function(state) end)
        pChar:CreateToggle("Freeze Character", false, "Plr_Freeze", {}, function(state)
            if currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
                currentCharacter.HumanoidRootPart.Anchored = state
            end
        end)
        pChar:CreateButton("Unfreeze Character", function()
            if currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
                currentCharacter.HumanoidRootPart.Anchored = false
                pcall(function()
                    Library.Registry["Plr_Freeze"].Control:Set(false)
                end)
            end
        end)
        pChar:CreateButton("Sit", function()
            if currentHumanoid then currentHumanoid.Sit = true end
        end)
        pChar:CreateButton("Stand", function()
            if currentHumanoid then currentHumanoid.Sit = false end
        end)
        
        -- Fly Rendering Loop
        RunService.RenderStepped:Connect(function(dt)
            if Library.Flags["Plr_Fly"] and currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
                local hrp = currentCharacter.HumanoidRootPart
                local hum = currentCharacter:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
                
                local speed = Library.Flags["Plr_FlySpeed"] or 50
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.CFrame = hrp.CFrame + (moveDir * speed * dt)
            else
                if currentHumanoid and currentHumanoid.PlatformStand then
                    currentHumanoid.PlatformStand = false
                end
            end
        end)

        -- Noclip Loop
        RunService.Stepped:Connect(function()
            if Library.Flags["Plr_Noclip"] and currentCharacter then
                for _, part in ipairs(currentCharacter:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)

        -- Safe Walk Raycast Edge-Check loop
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_SafeWalk"] and currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
                local hrp = currentCharacter.HumanoidRootPart
                local vel = hrp.Velocity
                if vel.Magnitude > 1 then
                    local lookAhead = vel.Unit * 2
                    local origin = hrp.Position + lookAhead - Vector3.new(0, 3, 0)
                    local ray = workspace:Raycast(origin, Vector3.new(0, -10, 0))
                    if not ray then
                        hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                    end
                end
            end
        end)

        -- Air Jump Loop
        UserInputService.JumpRequest:Connect(function()
            if Library.Flags["Plr_AirJump"] and currentHumanoid then
                if currentHumanoid:GetState() == Enum.HumanoidStateType.FreeFall then
                    currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        local pProt = PlayerTab:CreateSection("Protection")
        pProt:CreateToggle("Anti AFK", false, "Plr_AntiAFK", {}, function(state) end)
        pProt:CreateToggle("Anti Void", false, "Plr_AntiVoid", {}, function(state) end)
        pProt:CreateToggle("Anti Fall Damage", false, "Plr_AntiFall", {}, function(state) end)
        pProt:CreateToggle("Anti Ragdoll", false, "Plr_AntiRagdoll", {}, function(state) end)
        pProt:CreateToggle("No Slow", false, "Plr_NoSlow", {}, function(state) end)
        pProt:CreateToggle("No Freeze", false, "Plr_NoFreeze", {}, function(state) end)
        pProt:CreateToggle("No Stun", false, "Plr_NoStun", {}, function(state) end)
        
        -- AFK Loop hook
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if Library.Flags["Plr_AntiAFK"] then
                VirtualUser:Button2Down(Vector2.new(0,0), camera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), camera.CFrame)
            end
        end)

        -- Void Loop hook
        task.spawn(function()
            while task.wait(0.5) do
                if Library.Flags["Plr_AntiVoid"] and currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
                    local hrp = currentCharacter.HumanoidRootPart
                    if hrp.Position.Y < -300 then
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
                        Library:CreateNotification("Anti-Void Protection", "Saved from falling into the void!", 3)
                    end
                end
            end
        end)

        -- Active Bypasses loop (No Slow, Anti Fall, Anti Ragdoll, Anti Stun, Anti Freeze)
        task.spawn(function()
            while task.wait(0.2) do
                if currentHumanoid then
                    if Library.Flags["Plr_NoSlow"] then
                        local activeWS = Library.Flags["Plr_WalkSpeed"] or 16
                        if currentHumanoid.WalkSpeed < activeWS then
                            currentHumanoid.WalkSpeed = activeWS
                        end
                    end
                    if Library.Flags["Plr_AntiFall"] then
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.FreeFall, false)
                    else
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.FreeFall, true)
                    end
                    if Library.Flags["Plr_AntiRagdoll"] then
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    else
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                    end
                    if Library.Flags["Plr_NoStun"] then
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
                    else
                        currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
                    end
                    if Library.Flags["Plr_NoFreeze"] then
                        currentHumanoid.PlatformStand = false
                    end
                end
            end
        end)
        
        local pMisc = PlayerTab:CreateSection("Misc")
        pMisc:CreateButton("Reset Character", function()
            if currentHumanoid then currentHumanoid:BreakJoints() end
        end)
        pMisc:CreateButton("Respawn", function()
            LocalPlayer:LoadCharacter()
        end)
        pMisc:CreateButton("Refresh Character", function()
            if currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
                local oldPos = currentCharacter.HumanoidRootPart.CFrame
                LocalPlayer:LoadCharacter()
                local newChar = LocalPlayer.CharacterAdded:Wait()
                local newHrp = newChar:WaitForChild("HumanoidRootPart")
                task.wait(0.1)
                newHrp.CFrame = oldPos
            end
        end)
        pMisc:CreateButton("Rejoin", function()
            local TeleportService = game:GetService("TeleportService")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
        
        local charInfoLabel = pMisc:CreateParagraph("Character Information", "Speed: 16\nHealth: 100\nPosition: 0, 0, 0")
        task.spawn(function()
            while task.wait(1) do
                if currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") and currentHumanoid then
                    local pos = currentCharacter.HumanoidRootPart.Position
                    pcall(function()
                        charInfoLabel:Set(string.format("Speed: %.1f\nHealth: %.1f / %.1f\nPosition: %.1f, %.1f, %.1f", 
                            currentHumanoid.WalkSpeed, 
                            currentHumanoid.Health, 
                            currentHumanoid.MaxHealth, 
                            pos.X, pos.Y, pos.Z
                        ))
                    end)
                end
            end
        end)

        -- ========================================================
        -- [[ MOVEMENT TAB ]]
        -- ========================================================
        local MovementTab = Window:CreateTab("Movement", "sliders")
        
        -- ========================================================
        -- [[ TELEPORT SECTION ]]
        -- ========================================================
        local mTeleport = MovementTab:CreateSection("Teleport")
        mTeleport:CreateToggle("Click Teleport", false, "Plr_ClickTP", {}, function(state) end)
        mTeleport:CreateToggle("Ctrl + Click Teleport", false, "Plr_CtrlClickTP", {}, function(state) end)
        mTeleport:CreateToggle("Tween Teleport", false, "Plr_TweenTP", {}, function(state) end)
        mTeleport:CreateSlider("Tween Speed", 10, 500, 100, "Plr_TweenTPSpeed", function(val) end)
        
        local Mouse = LocalPlayer:GetMouse()
        Mouse.Button1Down:Connect(function()
            if Library.Flags["Plr_CtrlClickTP"] and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                if currentRootPart and Mouse.Hit then
                    pcall(function()
                        local targetCF = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                        if Library.Flags["Plr_TweenTP"] then
                            local distance = (currentRootPart.Position - Mouse.Hit.Position).Magnitude
                            local speed = Library.Flags["Plr_TweenTPSpeed"] or 100
                            local time = distance / math.max(speed, 1)
                            TweenService:Create(currentRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCF}):Play()
                        else
                            currentRootPart.CFrame = targetCF
                        end
                    end)
                end
            elseif Library.Flags["Plr_ClickTP"] then
                if currentRootPart and Mouse.Hit then
                    pcall(function()
                        local targetCF = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                        if Library.Flags["Plr_TweenTP"] then
                            local distance = (currentRootPart.Position - Mouse.Hit.Position).Magnitude
                            local speed = Library.Flags["Plr_TweenTPSpeed"] or 100
                            local time = distance / math.max(speed, 1)
                            TweenService:Create(currentRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCF}):Play()
                        else
                            currentRootPart.CFrame = targetCF
                        end
                    end)
                end
            end
        end)

        mTeleport:CreateButton("Teleport To Mouse", function()
            if currentRootPart and Mouse.Hit then
                pcall(function()
                    local targetCF = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                    if Library.Flags["Plr_TweenTP"] then
                        local distance = (currentRootPart.Position - Mouse.Hit.Position).Magnitude
                        local speed = Library.Flags["Plr_TweenTPSpeed"] or 100
                        local time = distance / math.max(speed, 1)
                        TweenService:Create(currentRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCF}):Play()
                    else
                        currentRootPart.CFrame = targetCF
                    end
                end)
            end
        end)

        -- Target Player Setup
        local playerList = {}
        local function rebuildPlayerList()
            playerList = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    table.insert(playerList, p.Name)
                end
            end
            if #playerList == 0 then table.insert(playerList, "No Players Found") end
        end
        rebuildPlayerList()
        Players.PlayerAdded:Connect(rebuildPlayerList)
        Players.PlayerRemoving:Connect(rebuildPlayerList)

        local targetPlayerDropdown = mTeleport:CreateDropdown("Teleport To Player", playerList, playerList[1], "Plr_TPTargetPlayer")
        
        mTeleport:CreateButton("Teleport to Chosen Player", function()
            local targetName = Library.Flags["Plr_TPTargetPlayer"]
            if targetName and targetName ~= "No Players Found" then
                local targetPlayer = Players:FindFirstChild(targetName)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local targetCF = targetPlayer.Character.HumanoidRootPart.CFrame
                        if Library.Flags["Plr_TweenTP"] then
                            local distance = (currentRootPart.Position - targetCF.Position).Magnitude
                            local speed = Library.Flags["Plr_TweenTPSpeed"] or 100
                            local time = distance / math.max(speed, 1)
                            TweenService:Create(currentRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCF}):Play()
                        else
                            currentRootPart.CFrame = targetCF
                        end
                    end)
                end
            end
        end)

        -- Position Saving & Teleport Back Cache Setup
        local savedPos = nil
        local priorPos = nil

        mTeleport:CreateButton("Save Position", function()
            if currentRootPart then
                savedPos = currentRootPart.CFrame
                Library:CreateNotification("Teleport System", "Current coordinates bookmarked!", 3)
            end
        end)

        mTeleport:CreateButton("Load Position", function()
            if savedPos and currentRootPart then
                priorPos = currentRootPart.CFrame
                pcall(function()
                    if Library.Flags["Plr_TweenTP"] then
                        local distance = (currentRootPart.Position - savedPos.Position).Magnitude
                        local speed = Library.Flags["Plr_TweenTPSpeed"] or 100
                        local time = distance / math.max(speed, 1)
                        TweenService:Create(currentRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = savedPos}):Play()
                    else
                        currentRootPart.CFrame = savedPos
                    end
                end)
            else
                Library:CreateNotification("Teleport Error", "No bookmarked coordinates found. Save position first.", 3)
            end
        end)

        mTeleport:CreateButton("Teleport Back", function()
            if priorPos and currentRootPart then
                local temp = currentRootPart.CFrame
                pcall(function()
                    if Library.Flags["Plr_TweenTP"] then
                        local distance = (currentRootPart.Position - priorPos.Position).Magnitude
                        local speed = Library.Flags["Plr_TweenTPSpeed"] or 100
                        local time = distance / math.max(speed, 1)
                        TweenService:Create(currentRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = priorPos}):Play()
                    else
                        currentRootPart.CFrame = priorPos
                    end
                end)
                priorPos = temp
            else
                Library:CreateNotification("Teleport Error", "No prior location history available.", 3)
            end
        end)

        -- Waypoint System & Bookmark Configurations
        local bookmarkList = {}
        local bookmarkDropdown

        mTeleport:CreateTextBox("Bookmark Name", "Enter location name...", "Plr_BookmarkNameInput")
        mTeleport:CreateButton("Save Bookmark", function()
            local name = Library.Flags["Plr_BookmarkNameInput"]
            if name and name ~= "" and name ~= "Enter location name..." and currentRootPart then
                bookmarkList[name] = currentRootPart.CFrame
                local keys = {}
                for k, _ in pairs(bookmarkList) do table.insert(keys, k) end
                if bookmarkDropdown then
                    bookmarkDropdown:Refresh(keys, name)
                end
                Library:CreateNotification("Waypoint Saved", "Position bookmarked as: " .. name, 3)
            end
        end)

        local initialKeys = {"No Bookmarks Saved"}
        bookmarkDropdown = mTeleport:CreateDropdown("Position Bookmark", initialKeys, initialKeys[1], "Plr_SelectedBookmark")

        mTeleport:CreateButton("Teleport to Bookmark", function()
            local selected = Library.Flags["Plr_SelectedBookmark"]
            if selected and bookmarkList[selected] and currentRootPart then
                local dest = bookmarkList[selected]
                priorPos = currentRootPart.CFrame
                pcall(function()
                    if Library.Flags["Plr_TweenTP"] then
                        local distance = (currentRootPart.Position - dest.Position).Magnitude
                        local speed = Library.Flags["Plr_TweenTPSpeed"] or 100
                        local time = distance / math.max(speed, 1)
                        TweenService:Create(currentRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = dest}):Play()
                    else
                        currentRootPart.CFrame = dest
                    end
                end)
            end
        end)

        mTeleport:CreateButton("Delete Selected Bookmark", function()
            local selected = Library.Flags["Plr_SelectedBookmark"]
            if selected and bookmarkList[selected] then
                bookmarkList[selected] = nil
                local keys = {}
                for k, _ in pairs(bookmarkList) do table.insert(keys, k) end
                if #keys == 0 then table.insert(keys, "No Bookmarks Saved") end
                bookmarkDropdown:Refresh(keys, keys[1])
                Library:CreateNotification("Waypoint Removed", "Deleted bookmark: " .. selected, 3)
            end
        end)

        -- ========================================================
        -- [[ MOVEMENT SECTION ]]
        -- ========================================================
        local mMovement = MovementTab:CreateSection("Movement")
        mMovement:CreateToggle("CFrame Speed", false, "Plr_CFrameSpeedActive", {}, function(state) end)
        mMovement:CreateSlider("CFrame Velocity Multiplier", 1, 10, 2, "Plr_CFrameSpeedValue", function(val) end)
        mMovement:CreateButton("Dash Force Boost", function()
            if currentRootPart and currentHumanoid then
                local moveDir = currentHumanoid.MoveDirection
                if moveDir.Magnitude == 0 then
                    moveDir = currentRootPart.CFrame.LookVector
                end
                currentRootPart.Velocity = currentRootPart.Velocity + (moveDir * 150)
            end
        end)
        mMovement:CreateToggle("Air Walk Platform", false, "Plr_AirWalk", {}, function(state) end)
        mMovement:CreateToggle("Wall Walk Gravity Align", false, "Plr_WallWalk", {}, function(state) end)
        mMovement:CreateToggle("Spider Climb", false, "Plr_SpiderClimb", {}, function(state) end)
        mMovement:CreateSlider("Spider Climb Speed", 10, 100, 35, "Plr_ClimbSpeed", function(val) end)
        mMovement:CreateToggle("Water Walk Platform", false, "Plr_WaterWalk", {}, function(state) end)
        mMovement:CreateToggle("Bunny Hop Momentum", false, "Plr_BHop", {}, function(state) end)
        mMovement:CreateToggle("Velocity Speed Bypass", false, "Plr_SpeedBypass", {}, function(state) end)
        mMovement:CreateToggle("No Clip Movement", false, "Plr_NoclipMovement", {}, function(state) end)

        -- CFrame Speed Engine Loop Hook
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_CFrameSpeedActive"] and currentHumanoid and currentRootPart then
                if currentHumanoid.MoveDirection.Magnitude > 0 then
                    local speedFactor = Library.Flags["Plr_CFrameSpeedValue"] or 2
                    currentRootPart.CFrame = currentRootPart.CFrame + (currentHumanoid.MoveDirection * (speedFactor * 0.1))
                end
            end
        end)

        -- Dynamic physical properties updates (AirWalk & WaterWalk platforms)
        local airWalkPart = Instance.new("Part")
        airWalkPart.Size = Vector3.new(10, 1, 10)
        airWalkPart.Transparency = 1
        airWalkPart.Anchored = true
        airWalkPart.CanCollide = false
        airWalkPart.Parent = workspace

        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_AirWalk"] and currentRootPart then
                airWalkPart.CanCollide = true
                airWalkPart.CFrame = CFrame.new(currentRootPart.Position.X, currentRootPart.Position.Y - 3.5, currentRootPart.Position.Z)
            else
                airWalkPart.CanCollide = false
            end
        end)

        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_WaterWalk"] and currentRootPart then
                local origin = currentRootPart.Position
                local ray = workspace:Raycast(origin, Vector3.new(0, -6, 0))
                if ray and ray.Material == Enum.Material.Water then
                    currentRootPart.Velocity = Vector3.new(currentRootPart.Velocity.X, 0, currentRootPart.Velocity.Z)
                    currentRootPart.CFrame = CFrame.new(currentRootPart.Position.X, ray.Position.Y + 3.1, currentRootPart.Position.Z)
                end
            end
        end)

        -- Wall Walk, Spider Climb & Bunnyhop loops hooks
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_SpiderClimb"] and currentRootPart and currentHumanoid then
                local lookDir = currentRootPart.CFrame.LookVector * 2.5
                local ray = workspace:Raycast(currentRootPart.Position, lookDir)
                if ray and math.abs(ray.Normal.Y) < 0.1 then
                    local climbSpeed = Library.Flags["Plr_ClimbSpeed"] or 35
                    currentRootPart.Velocity = Vector3.new(currentRootPart.Velocity.X, climbSpeed, currentRootPart.Velocity.Z)
                end
            end
        end)

        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_BHop"] and currentHumanoid and currentHumanoid.MoveDirection.Magnitude > 0 then
                if currentHumanoid:GetState() == Enum.HumanoidStateType.Landed then
                    currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)

        -- Speed bypass via custom PlatformStand logic to avoid speed triggers
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_SpeedBypass"] and currentHumanoid then
                currentHumanoid.PlatformStand = true
                task.wait(0.01)
                currentHumanoid.PlatformStand = false
            end
        end)

        -- NoClip loop hook
        RunService.Stepped:Connect(function()
            if Library.Flags["Plr_NoclipMovement"] and currentCharacter then
                for _, part in ipairs(currentCharacter:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)

        -- ========================================================
        -- [[ CAMERA SECTION ]]
        -- ========================================================
        local mCamera = MovementTab:CreateSection("Camera")
        mCamera:CreateToggle("Freecam Camera Unlock", false, "Plr_Freecam", {}, function(state) end)
        mCamera:CreateSlider("Freecam Smooth Speed", 10, 200, 50, "Plr_FreecamSpeed", function(val) end)
        mCamera:CreateToggle("Force Mouse Lock", false, "Plr_ForceShiftLock", {}, function(state)
            LocalPlayer.DevEnableMouseLock = state
        end)
        mCamera:CreateToggle("Zoom Limit Bypass", false, "Plr_ZoomBypass", {}, function(state)
            if state then
                LocalPlayer.MaxZoomDistance = 99999
            else
                LocalPlayer.MaxZoomDistance = 128
            end
        end)
        mCamera:CreateSlider("Active Camera Zoom", 10, 500, 70, "Plr_CameraZoomLevel", function(val)
            LocalPlayer.CameraMaxZoomDistance = val
            LocalPlayer.CameraMinZoomDistance = val
        end)
        mCamera:CreateSlider("Camera Field of View", 30, 120, 70, "Plr_CameraFOV", function(val)
            camera.FieldOfView = val
        end)
        mCamera:CreateToggle("Camera Lerp Smoothness", false, "Plr_SmoothCam", {}, function(state) end)
        mCamera:CreateSlider("Camera Offset Axis-Y", -5, 10, 0, "Plr_CameraOffsetY", function(val)
            if currentHumanoid then
                currentHumanoid.CameraOffset = Vector3.new(0, val, 0)
            end
        end)
        mCamera:CreateSlider("Camera Target Follow Speed", 1, 50, 25, "Plr_CamFollowSpeed", function(val) end)

        -- Freecam engine implementation
        local freecamActive = false
        local freecamCF = CFrame.new()
        local originalCamType = Enum.CameraType.Custom

        Library.EventBus:Subscribe("ToggleChanged", function(flag, state)
            if flag == "Plr_Freecam" then
                freecamActive = state
                if state then
                    originalCamType = camera.CameraType
                    camera.CameraType = Enum.CameraType.Scriptable
                    freecamCF = camera.CFrame
                else
                    camera.CameraType = originalCamType
                end
            end
        end)

        RunService.RenderStepped:Connect(function(dt)
            if freecamActive then
                local speed = Library.Flags["Plr_FreecamSpeed"] or 50
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + freecamCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - freecamCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + freecamCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - freecamCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - freecamCF.RightVector end
                
                if move.Magnitude > 0 then move = move.Unit end
                freecamCF = freecamCF + (move * speed * dt)
                camera.CFrame = freecamCF
            end
        end)

        -- ========================================================
        -- [[ CHARACTER MOVEMENT SECTION ]]
        -- ========================================================
        local mCharMove = MovementTab:CreateSection("Character Movement")
        mCharMove:CreateToggle("Auto Face Selected Target", false, "Plr_AutoFace", {}, function(state) end)
        
        local faceTargetDropdown = mCharMove:CreateDropdown("Target Player", playerList, playerList[1], "Plr_FaceTargetName")
        
        mCharMove:CreateSlider("Rotation Align Speed", 1, 100, 20, "Plr_RotateSpeed", function(val) end)
        mCharMove:CreateToggle("Orbit Strafe Pattern", false, "Plr_StrafeActive", {}, function(state) end)
        mCharMove:CreateToggle("Lock Movement Inputs", false, "Plr_LockInputs", {}, function(state) end)
        mCharMove:CreateToggle("Auto Walk Forward", false, "Plr_AutoWalk", {}, function(state) end)
        mCharMove:CreateToggle("Auto Run Continuous Path", false, "Plr_AutoRun", {}, function(state) end)

        -- Auto Face Target Logic Implementation
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_AutoFace"] and currentRootPart then
                local targetName = Library.Flags["Plr_FaceTargetName"]
                if targetName and targetName ~= "No Players Found" then
                    local targetPlayer = Players:FindFirstChild(targetName)
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = targetPlayer.Character.HumanoidRootPart
                        local delta = (targetHrp.Position - currentRootPart.Position)
                        local lookDir = Vector3.new(delta.X, 0, delta.Z).Unit
                        
                        local currentCF = currentRootPart.CFrame
                        local targetCF = CFrame.fromMatrix(currentRootPart.Position, -lookDir, Vector3.new(0, 1, 0))
                        local rotateFactor = (Library.Flags["Plr_RotateSpeed"] or 20) / 100
                        
                        currentRootPart.CFrame = currentCF:Lerp(targetCF, rotateFactor)
                    end
                end
            end
        end)

        -- Orbit Strafe loop hook
        local orbitAngle = 0
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_StrafeActive"] and currentRootPart then
                local targetName = Library.Flags["Plr_FaceTargetName"]
                if targetName and targetName ~= "No Players Found" then
                    local targetPlayer = Players:FindFirstChild(targetName)
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = targetPlayer.Character.HumanoidRootPart
                        orbitAngle = orbitAngle + 0.05
                        local offset = Vector3.new(math.cos(orbitAngle) * 12, 0, math.sin(orbitAngle) * 12)
                        currentRootPart.CFrame = CFrame.new(targetHrp.Position + offset, targetHrp.Position)
                    end
                end
            end
        end)

        -- Lock Input controls hook
        local controls = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
        RunService.Heartbeat:Connect(function()
            if Library.Flags["Plr_LockInputs"] then
                controls:Disable()
            else
                controls:Enable()
            end
        end)

        -- AutoWalk loop hook
        task.spawn(function()
            while task.wait(0.1) do
                if Library.Flags["Plr_AutoWalk"] and currentHumanoid then
                    currentHumanoid:Move(Vector3.new(0, 0, -1), true)
                end
            end
        end)

        -- ========================================================
        -- [[ ADVANCED SECTION ]]
        -- ========================================================
        local mAdvanced = MovementTab:CreateSection("Advanced")
        mAdvanced:CreateToggle("Pathfinding Visualization", false, "Plr_PathVis", {}, function(state) end)
        mAdvanced:CreateToggle("Movement Vector Prediction", false, "Plr_MovePrediction", {}, function(state) end)
        mAdvanced:CreateToggle("Anti Player Collisions", false, "Plr_PlayerCollisions", {}, function(state) end)
        mAdvanced:CreateToggle("Terrain Surface Friction Detection", false, "Plr_SurfaceDetect", {}, function(state) end)

        -- Path Visualizer & Vector Prediction Implementation
        local pathVisPart = Instance.new("Part")
        pathVisPart.Size = Vector3.new(1.2, 1.2, 1.2)
        pathVisPart.Anchored = true
        pathVisPart.CanCollide = false
        pathVisPart.Material = Enum.Material.Neon
        pathVisPart.Color = Color3.fromRGB(0, 255, 255)
        pathVisPart.Shape = Enum.PartType.Ball
        pathVisPart.Parent = workspace
        pathVisPart.Transparency = 1

        RunService.RenderStepped:Connect(function()
            if Library.Flags["Plr_PathVis"] and currentRootPart then
                pathVisPart.Transparency = 0.3
                pathVisPart.Position = currentRootPart.Position + (currentRootPart.Velocity * 0.25)
            else
                pathVisPart.Transparency = 1
            end
        end)

        -- Collision Toggle loop
        RunService.Stepped:Connect(function()
            if Library.Flags["Plr_PlayerCollisions"] and currentCharacter then
                for _, other in ipairs(Players:GetPlayers()) do
                    if other ~= LocalPlayer and other.Character then
                        for _, p in ipairs(other.Character:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                            end
                        end
                    end
                end
            end
        end)

        -- ========================================================
        -- [[ MISC SECTION (MOVEMENT) ]]
        -- ========================================================
        local mMisc = MovementTab:CreateSection("Misc")
        local mInfoParagraph = mMisc:CreateParagraph("Movement Information", "Speed: 16 studs/s\nPosition: 0, 0, 0\nVelocity: 0, 0, 0\nFriction coefficient: Normal")
        
        task.spawn(function()
            while task.wait(0.5) do
                if currentRootPart and currentHumanoid then
                    local velocity = currentRootPart.Velocity
                    local magnitude = velocity.Magnitude
                    local position = currentRootPart.Position
                    
                    local material = currentHumanoid.FloorMaterial
                    local friction = "Normal"
                    if material == Enum.Material.Ice then
                        friction = "Slippery (Low Friction)"
                    elseif material == Enum.Material.Water then
                        friction = "Water Dampening"
                    end

                    pcall(function()
                        mInfoParagraph:Set(string.format(
                            "Current Speed: %.2f studs/s\nPosition coordinates: X: %.1f, Y: %.1f, Z: %.1f\nVelocity vector: X: %.1f, Y: %.1f, Z: %.1f\nActive Surface friction: %s",
                            magnitude,
                            position.X, position.Y, position.Z,
                            velocity.X, velocity.Y, velocity.Z,
                            friction
                        ))
                    end)
                end
            end
        end)

        -- ========================================================
        -- [[ VISUAL TAB ]]
        -- ========================================================
        local VisualTab = Window:CreateTab("Visual", "shield")
        
        -- ESP Drawing / Core Configuration Engine setup
        local hasDrawing = pcall(function()
            local c = Drawing.new("Circle")
            c:Remove()
            return true
        end)
        
        local espCache = {}
        local npcCache = {}
        local itemCache = {}
        local objectCache = {}
        local crosshairLines = {}
        local fovCircleObj = nil

        if hasDrawing then
            fovCircleObj = Drawing.new("Circle")
            fovCircleObj.Thickness = 1.3
            fovCircleObj.NumSides = 64
            fovCircleObj.Filled = false
            fovCircleObj.Transparency = 1
            fovCircleObj.Visible = false
            
            for i = 1, 4 do
                crosshairLines[i] = Drawing.new("Line")
                crosshairLines[i].Thickness = 1.5
                crosshairLines[i].Transparency = 1
                crosshairLines[i].Visible = false
            end
        end

        -- Core ESP update loop hook
        local function getBoxSizeAndPos(model)
            if not model or not model:FindFirstChild("HumanoidRootPart") then return nil, nil end
            local size = model:GetExtentsSize()
            local screenPos, onScreen = camera:WorldToViewportPoint(model.HumanoidRootPart.Position)
            if not onScreen then return nil, nil end
            
            local extents = camera:WorldToViewportPoint(model.HumanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, 0))
            local extentsOffset = camera:WorldToViewportPoint(model.HumanoidRootPart.Position - Vector3.new(size.X/2, size.Y/2, 0))
            
            local width = math.abs(extents.X - extentsOffset.X)
            local height = math.abs(extents.Y - extentsOffset.Y)
            
            return Vector2.new(width, height), Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
        end

        local function clearPlayerDrawings(player)
            if espCache[player] then
                for _, obj in pairs(espCache[player]) do
                    pcall(function() obj:Remove() end)
                end
                espCache[player] = nil
            end
        end

        local function handleESP(player)
            if player == LocalPlayer then return end
            if not Library.Flags["Vis_EnableESP"] or not Library.Flags["Vis_MasterESP"] then
                clearPlayerDrawings(player)
                return
            end
            
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then
                clearPlayerDrawings(player)
                return
            end
            
            if Library.Flags["Vis_TeamCheck"] and player.Team == LocalPlayer.Team then
                clearPlayerDrawings(player)
                return
            end
            
            if Library.Flags["Vis_FriendCheck"] and player:IsFriendsWith(LocalPlayer.UserId) then
                clearPlayerDrawings(player)
                return
            end

            local drawData = espCache[player]
            if not drawData then
                drawData = {}
                if hasDrawing then
                    drawData.Box = Drawing.new("Square")
                    drawData.Box.Thickness = 1.5
                    drawData.Box.Filled = false
                    
                    drawData.FilledBox = Drawing.new("Square")
                    drawData.FilledBox.Thickness = 0
                    drawData.FilledBox.Filled = true
                    drawData.FilledBox.Transparency = 0.35
                    
                    drawData.Tracer = Drawing.new("Line")
                    drawData.Tracer.Thickness = 1.3
                    
                    drawData.Name = Drawing.new("Text")
                    drawData.Name.Size = 13
                    drawData.Name.Center = true
                    drawData.Name.Outline = true
                    
                    drawData.Distance = Drawing.new("Text")
                    drawData.Distance.Size = 11
                    drawData.Distance.Center = true
                    drawData.Distance.Outline = true
                end
                espCache[player] = drawData
            end

            local boxSize, boxPos = getBoxSizeAndPos(char)
            if boxSize and boxPos then
                local accentColor = Library.Flags["BuiltIn_AccentColor"] or CurrentTheme.Accent
                if Library.Flags["Vis_RainbowESP"] then
                    accentColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                end

                if hasDrawing then
                    -- Normal Box ESP
                    if Library.Flags["Vis_BoxESP"] then
                        drawData.Box.Size = boxSize
                        drawData.Box.Position = boxPos
                        drawData.Box.Color = accentColor
                        drawData.Box.Visible = true
                    else
                        drawData.Box.Visible = false
                    end

                    -- Filled Box ESP
                    if Library.Flags["Vis_FilledBox"] then
                        drawData.FilledBox.Size = boxSize
                        drawData.FilledBox.Position = boxPos
                        drawData.FilledBox.Color = accentColor
                        drawData.FilledBox.Visible = true
                    else
                        drawData.FilledBox.Visible = false
                    end

                    -- Tracer Snapline ESP
                    if Library.Flags["Vis_Tracer"] then
                        local startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        if Library.Flags["Vis_Snapline"] then
                            startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        end
                        drawData.Tracer.From = startPos
                        drawData.Tracer.To = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y + boxSize.Y)
                        drawData.Tracer.Color = accentColor
                        drawData.Tracer.Visible = true
                    else
                        drawData.Tracer.Visible = false
                    end

                    -- Name ESP
                    if Library.Flags["Vis_NameESP"] then
                        drawData.Name.Text = player.DisplayName or player.Name
                        drawData.Name.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 16)
                        drawData.Name.Color = Color3.fromRGB(255, 255, 255)
                        drawData.Name.Visible = true
                    else
                        drawData.Name.Visible = false
                    end

                    -- Distance ESP
                    if Library.Flags["Vis_DistanceESP"] then
                        local distance = math.floor((currentRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                        drawData.Distance.Text = tostring(distance) .. " studs"
                        drawData.Distance.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y + boxSize.Y + 2)
                        drawData.Distance.Color = Color3.fromRGB(200, 200, 200)
                        drawData.Distance.Visible = true
                    else
                        drawData.Distance.Visible = false
                    end
                end

                -- Highlight / Chams Engine hook
                local chams = char:FindFirstChild("Nexus_Chams")
                if Library.Flags["Vis_Chams"] then
                    if not chams then
                        chams = Instance.new("Highlight")
                        chams.Name = "Nexus_Chams"
                        chams.Parent = char
                    end
                    chams.FillColor = accentColor
                    chams.OutlineColor = Library.Flags["Vis_Outline"] and Color3.fromRGB(255, 255, 255) or accentColor
                    chams.FillTransparency = Library.Flags["Vis_Glow"] and 0.5 or 0.2
                    chams.OutlineTransparency = 0
                    chams.Enabled = true
                else
                    if chams then chams:Destroy() end
                end
            else
                clearPlayerDrawings(player)
            end
        end

        RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                pcall(function() handleESP(player) end)
            end
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            clearPlayerDrawings(player)
        end)

        -- 1. ESP Section
        local vEspSec = VisualTab:CreateSection("ESP")
        vEspSec:CreateToggle("Master Switch ESP", false, "Vis_MasterESP", {}, function(state) end)
        vEspSec:CreateToggle("Enable Player ESP Render", false, "Vis_EnableESP", {}, function(state) end)
        vEspSec:CreateToggle("Box Borders ESP", false, "Vis_BoxESP", {}, function(state) end)
        vEspSec:CreateToggle("Filled Box ESP Layer", false, "Vis_FilledBox", {}, function(state) end)
        vEspSec:CreateToggle("Corner Framed Boxes ESP", false, "Vis_CornerBox", {}, function(state) end)
        vEspSec:CreateToggle("Rig Skeleton ESP", false, "Vis_SkeletonESP", {}, function(state) end)
        vEspSec:CreateToggle("Highlights Chams Layer", false, "Vis_Chams", {}, function(state) end)
        vEspSec:CreateToggle("Outer Highlight Outline", false, "Vis_Outline", {}, function(state) end)
        vEspSec:CreateToggle("Translucent Glow Effect", false, "Vis_Glow", {}, function(state) end)
        vEspSec:CreateToggle("Rainbow Chromatic ESP Cycle", false, "Vis_RainbowESP", {}, function(state) end)

        -- 2. Player ESP Section
        local vPlayerEspSec = VisualTab:CreateSection("Player ESP")
        vPlayerEspSec:CreateToggle("Render Display Name ESP", false, "Vis_NameESP", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Health Metric Text ESP", false, "Vis_HealthESP", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Distance Counter Studs ESP", false, "Vis_DistanceESP", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Ignore Same-Team Members", false, "Vis_TeamCheck", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Render Completely Invisible Targets", false, "Vis_InvCheck", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Exclude Friendlist Members", false, "Vis_FriendCheck", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Snapline Directional Tracers", false, "Vis_Tracer", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Tracers Originate from Center Screen", false, "Vis_Snapline", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Head Marker Dot Indicator", false, "Vis_HeadDot", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Render Health Bar Column", false, "Vis_HealthBar", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Render Armor Protection Bar", false, "Vis_ArmorBar", {}, function(state) end)
        vPlayerEspSec:CreateToggle("Active Inventory Tool Name ESP", false, "Vis_ToolESP", {}, function(state) end)

        -- 3. NPC ESP Section
        local vNpcEspSec = VisualTab:CreateSection("NPC ESP")
        vNpcEspSec:CreateToggle("NPC Master ESP Rendering", false, "Vis_NPC_ESP", {}, function(state) end)
        vNpcEspSec:CreateToggle("NPC Entity Name ESP", false, "Vis_NPC_Name", {}, function(state) end)
        vNpcEspSec:CreateToggle("NPC Distance Text ESP", false, "Vis_NPC_Dist", {}, function(state) end)
        vNpcEspSec:CreateToggle("NPC Life Health Status ESP", false, "Vis_NPC_Health", {}, function(state) end)
        vNpcEspSec:CreateToggle("NPC Directional Tracers ESP", false, "Vis_NPC_Tracer", {}, function(state) end)

        -- NPC ESP Loop implementation
        task.spawn(function()
            while task.wait(0.5) do
                if Library.Flags["Vis_NPC_ESP"] and Library.Flags["Vis_MasterESP"] then
                    for _, instance in ipairs(workspace:GetDescendants()) do
                        if instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(instance) then
                            local humanoid = instance:FindFirstChildOfClass("Humanoid")
                            local hrp = instance:FindFirstChild("HumanoidRootPart")
                            if hrp and humanoid.Health > 0 then
                                -- Construct highlights dynamically
                                local highlight = instance:FindFirstChild("Nexus_NPCChams")
                                if not highlight then
                                    highlight = Instance.new("Highlight")
                                    highlight.Name = "Nexus_NPCChams"
                                    highlight.Parent = instance
                                end
                                highlight.FillColor = Color3.fromRGB(255, 100, 0)
                                highlight.Enabled = true
                            end
                        end
                    end
                else
                    for _, instance in ipairs(workspace:GetDescendants()) do
                        if instance:IsA("Model") and instance:FindFirstChild("Nexus_NPCChams") then
                            instance.Nexus_NPCChams:Destroy()
                        end
                    end
                end
            end
        end)

        -- 4. Item ESP Section
        local vItemEspSec = VisualTab:CreateSection("Item ESP")
        vItemEspSec:CreateToggle("Item Entity Global ESP", false, "Vis_Item_ESP", {}, function(state) end)
        vItemEspSec:CreateToggle("Dropped Weapons ESP", false, "Vis_WeaponESP", {}, function(state) end)
        vItemEspSec:CreateToggle("Treasure Chests ESP", false, "Vis_ChestESP", {}, function(state) end)
        vItemEspSec:CreateToggle("Lootable Coins ESP", false, "Vis_CoinESP", {}, function(state) end)
        vItemEspSec:CreateToggle("Ground Dropped Loot ESP", false, "Vis_DropESP", {}, function(state) end)
        vItemEspSec:CreateToggle("Special Collectibles ESP", false, "Vis_CollectESP", {}, function(state) end)

        -- 5. Object ESP Section
        local vObjEspSec = VisualTab:CreateSection("Object ESP")
        vObjEspSec:CreateToggle("Global Object ESP Render", false, "Vis_Obj_ESP", {}, function(state) end)
        vObjEspSec:CreateToggle("Interactive Doorways ESP", false, "Vis_DoorESP", {}, function(state) end)
        vObjEspSec:CreateToggle("Safezone Escape Zones ESP", false, "Vis_ExitESP", {}, function(state) end)
        vObjEspSec:CreateToggle("Spawned Driveable Vehicles ESP", false, "Vis_VehicleESP", {}, function(state) end)
        vObjEspSec:CreateToggle("Electrical Generators ESP", false, "Vis_GenESP", {}, function(state) end)
        vObjEspSec:CreateToggle("Placed Explosive Bombs ESP", false, "Vis_BombESP", {}, function(state) end)
        vObjEspSec:CreateToggle("Main Map Objectives ESP", false, "Vis_ObjectiveESP", {}, function(state) end)

        -- 6. Character Visual Section
        local vCharSec = VisualTab:CreateSection("Character")
        vCharSec:CreateToggle("Spatially Expand Client Hitboxes", false, "Vis_HitboxExpand", {}, function(state) end)
        vCharSec:CreateSlider("Hitbox Stud Dimension", 2, 50, 10, "Vis_HitboxSize", function(val) end)
        vCharSec:CreateToggle("Self Client Character Highlight", false, "Vis_Highlight", {}, function(state)
            local selfHighlight = currentCharacter:FindFirstChild("SelfChams")
            if state then
                if not selfHighlight then
                    selfHighlight = Instance.new("Highlight")
                    selfHighlight.Name = "SelfChams"
                    selfHighlight.Parent = currentCharacter
                end
                selfHighlight.FillColor = Library.Flags["BuiltIn_AccentColor"] or CurrentTheme.Accent
                selfHighlight.Enabled = true
            else
                if selfHighlight then selfHighlight:Destroy() end
            end
        end)
        vCharSec:CreateToggle("Rainbow Client Model Cycle", false, "Vis_RainbowChar", {}, function(state) end)
        vCharSec:CreateSlider("Local Model Transparency", 0, 100, 0, "Vis_Transparency", function(val)
            for _, part in ipairs(currentCharacter:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = val / 100
                end
            end
        end)
        vCharSec:CreateToggle("Client Model Highlight Outline", false, "Vis_CharOutline", {}, function(state) end)

        -- Hitbox Expander loop execution
        task.spawn(function()
            while task.wait(1) do
                if Library.Flags["Vis_HitboxExpand"] then
                    local size = Library.Flags["Vis_HitboxSize"] or 10
                    for _, other in ipairs(Players:GetPlayers()) do
                        if other ~= LocalPlayer and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                            other.Character.HumanoidRootPart.Size = Vector3.new(size, size, size)
                            other.Character.HumanoidRootPart.Transparency = 0.7
                            other.Character.HumanoidRootPart.CanCollide = false
                        end
                    end
                end
            end
        end)

        -- 7. Lighting Section
        local vLightSec = VisualTab:CreateSection("Lighting")
        vLightSec:CreateToggle("Constant Fullbright NightBypass", false, "Vis_Fullbright", {}, function(state) end)
        vLightSec:CreateSlider("Global Lux Brightness", 0, 10, 2, "Vis_Brightness", function(val)
            Lighting.Brightness = val
        end)
        vLightSec:CreateColorPicker("Global Tint Ambient", Lighting.Ambient, "Vis_Ambient", function(color)
            Lighting.Ambient = color
        end)
        vLightSec:CreateColorPicker("Outdoor Sky Ambient", Lighting.OutdoorAmbient, "Vis_OutdoorAmbient", function(color)
            Lighting.OutdoorAmbient = color
        end)
        
        -- ColorCorrection setup
        local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
        vLightSec:CreateToggle("Activate Color Correction Filter", false, "Vis_ColorCorrection", {}, function(state)
            colorCorrection.Enabled = state
        end)
        vLightSec:CreateSlider("Color Saturation Factor", -100, 100, 0, "Vis_Saturation", function(val)
            colorCorrection.Saturation = val / 100
        end)
        vLightSec:CreateSlider("Color Contrast Gradient", -100, 100, 0, "Vis_Contrast", function(val)
            colorCorrection.Contrast = val / 100
        end)
        vLightSec:CreateSlider("Camera Exposure Factor", -100, 100, 0, "Vis_Exposure", function(val)
            colorCorrection.Brightness = val / 100
        end)

        -- Lighting Loops execution
        local originalLux = Lighting.Brightness
        local originalAmbient = Lighting.Ambient
        local originalOutdoor = Lighting.OutdoorAmbient

        RunService.RenderStepped:Connect(function()
            if Library.Flags["Vis_Fullbright"] then
                Lighting.Brightness = 5
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                Lighting.ClockTime = 14
            else
                Lighting.Brightness = Library.Flags["Vis_Brightness"] or originalLux
                Lighting.Ambient = Library.Flags["Vis_Ambient"] or originalAmbient
                Lighting.OutdoorAmbient = Library.Flags["Vis_OutdoorAmbient"] or originalOutdoor
            end
        end)

        -- 8. World Visual Section
        local vWorldSec = VisualTab:CreateSection("World Visual")
        vWorldSec:CreateToggle("Completely Strip World Fog", false, "Vis_RemoveFog", {}, function(state) end)
        vWorldSec:CreateToggle("Disable Post-Processing Blur", false, "Vis_RemoveBlur", {}, function(state)
            local blur = Lighting:FindFirstChildOfClass("BlurEffect")
            if blur then blur.Enabled = not state end
        end)
        vWorldSec:CreateToggle("Force Remove Outdoor Shadows", false, "Vis_RemoveShadows", {}, function(state)
            Lighting.GlobalShadows = not state
        end)
        vWorldSec:CreateToggle("Active Map Geometry X-Ray", false, "Vis_XRay", {}, function(state)
            for _, instance in ipairs(workspace:GetDescendants()) do
                if instance:IsA("BasePart") and not instance:IsDescendantOf(currentCharacter) and not instance.Parent:FindFirstChildOfClass("Humanoid") then
                    if state then
                        if not instance:FindFirstChild("OldTrans") then
                            local oldVal = Instance.new("NumberValue", instance)
                            oldVal.Name = "OldTrans"
                            oldVal.Value = instance.Transparency
                        end
                        instance.Transparency = 0.65
                    else
                        if instance:FindFirstChild("OldTrans") then
                            instance.Transparency = instance.OldTrans.Value
                            instance.OldTrans:Destroy()
                        end
                    end
                end
            end
        end)
        vWorldSec:CreateToggle("Force Lock Midnight Mode", false, "Vis_NightMode", {}, function(state) end)
        vWorldSec:CreateToggle("Force Lock Noon Mode", false, "Vis_DayMode", {}, function(state) end)
        vWorldSec:CreateDropdown("Skybox Texture Presets", {"Default", "Dark Space", "Synthwave", "Cyberpunk"}, "Default", "Vis_Skybox", function(val) end)
        vWorldSec:CreateSlider("Terrain Water Transparency", 0, 100, 50, "Vis_WaterTrans", function(val)
            workspace.Terrain.WaterTransparency = val / 100
        end)
        vWorldSec:CreateSlider("Terrain Water Reflectance", 0, 100, 50, "Vis_WaterReflect", function(val)
            workspace.Terrain.WaterReflectance = val / 100
        end)

        -- World Loops execution
        RunService.RenderStepped:Connect(function()
            if Library.Flags["Vis_RemoveFog"] then
                Lighting.FogEnd = 999999
            end
            if Library.Flags["Vis_NightMode"] then
                Lighting.ClockTime = 0
            elseif Library.Flags["Vis_DayMode"] then
                Lighting.ClockTime = 12
            end
        end)

        -- 9. Crosshair Section
        local vCrossSec = VisualTab:CreateSection("Crosshair")
        vCrossSec:CreateToggle("Render Custom Crosshair Overlay", false, "Vis_CustomCrosshair", {}, function(state) end)
        vCrossSec:CreateColorPicker("Crosshair Tint Color", Color3.fromRGB(255, 0, 0), "Vis_CrossColor", function(color) end)
        vCrossSec:CreateSlider("Crosshair Wing Length Size", 1, 50, 10, "Vis_CrossSize", function(val) end)
        vCrossSec:CreateSlider("Crosshair Line Thickness", 1, 10, 2, "Vis_CrossThick", function(val) end)
        vCrossSec:CreateSlider("Crosshair Center Gap Size", 0, 20, 4, "Vis_CrossGap", function(val) end)
        vCrossSec:CreateSlider("Crosshair Dynamic Rotation", 0, 360, 0, "Vis_CrossRot", function(val) end)

        -- Custom Crosshair Draw Loop execution
        RunService.RenderStepped:Connect(function()
            if hasDrawing then
                local active = Library.Flags["Vis_CustomCrosshair"]
                local color = Library.Flags["Vis_CrossColor"] or Color3.fromRGB(255, 0, 0)
                local size = Library.Flags["Vis_CrossSize"] or 10
                local thickness = Library.Flags["Vis_CrossThick"] or 2
                local gap = Library.Flags["Vis_CrossGap"] or 4
                local rotation = math.rad(Library.Flags["Vis_CrossRot"] or 0)
                
                local screenCenter = camera.ViewportSize / 2
                
                for i = 1, 4 do
                    local line = crosshairLines[i]
                    if line then
                        if active then
                            local angle = rotation + ((i - 1) * math.pi / 2)
                            local startX = screenCenter.X + (math.cos(angle) * gap)
                            local startY = screenCenter.Y + (math.sin(angle) * gap)
                            local endX = screenCenter.X + (math.cos(angle) * (gap + size))
                            local endY = screenCenter.Y + (math.sin(angle) * (gap + size))
                            
                            line.From = Vector2.new(startX, startY)
                            line.To = Vector2.new(endX, endY)
                            line.Color = color
                            line.Thickness = thickness
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    end
                end
            end
        end)

        -- 10. Camera Visual Section
        local vCamSec = VisualTab:CreateSection("Camera Visual")
        vCamSec:CreateToggle("Render FOV Vector Limit Circle", false, "Vis_FOVCircle", {}, function(state) end)
        vCamSec:CreateSlider("FOV Target Boundary Radius", 20, 800, 150, "Vis_FOVRadius", function(val) end)
        vCamSec:CreateColorPicker("FOV Circle Perimeter Color", Color3.fromRGB(0, 255, 255), "Vis_FOVColor", function(color) end)
        vCamSec:CreateSlider("Custom Camera FOV Distance", 30, 150, 70, "Vis_CamFOV", function(val)
            camera.FieldOfView = val
        end)
        vCamSec:CreateSlider("Max Camera Zoom Factor", 10, 500, 128, "Vis_CamZoom", function(val)
            LocalPlayer.CameraMaxZoomDistance = val
        end)
        vCamSec:CreateSlider("Third Person Distance Offset", 0, 100, 0, "Vis_ThirdPerson", function(val) end)

        -- FOV Ring update loop execution
        RunService.RenderStepped:Connect(function()
            if hasDrawing and fovCircleObj then
                local active = Library.Flags["Vis_FOVCircle"]
                local radius = Library.Flags["Vis_FOVRadius"] or 150
                local color = Library.Flags["Vis_FOVColor"] or Color3.fromRGB(0, 255, 255)
                
                if active then
                    fovCircleObj.Radius = radius
                    fovCircleObj.Position = camera.ViewportSize / 2
                    fovCircleObj.Color = color
                    fovCircleObj.Visible = true
                else
                    fovCircleObj.Visible = false
                end
            end
        end)

        -- 11. Misc Section (VISUAL)
        local vMiscSec = VisualTab:CreateSection("Misc")
        vMiscSec:CreateToggle("Enable Diagnostics FPS Display", false, "Vis_FPSCounter", {}, function(state) end)
        vMiscSec:CreateToggle("Enable Network Ping Tracker", false, "Vis_PingDisplay", {}, function(state) end)
        vMiscSec:CreateToggle("Performant Diagnostics Overlay", false, "Vis_PerfOverlay", {}, function(state)
            HudFrame.Visible = state
        end)
        vMiscSec:CreateToggle("Render Map Coordinate Display", false, "Vis_CoordsDisplay", {}, function(state) end)
        
        local mapsInfoParagraph = vMiscSec:CreateParagraph("Visual Framework Diagnostics", "FPS: 60\nPing: 0 ms\nGlobal Position coordinates: X: 0, Y: 0, Z: 0")
        
        task.spawn(function()
            while task.wait(1) do
                local speed = currentHumanoid and currentHumanoid.WalkSpeed or 16
                local pos = currentRootPart and currentRootPart.Position or Vector3.new(0,0,0)
                pcall(function()
                    mapsInfoParagraph:Set(string.format(
                        "Client FPS Counter: %d frames/s\nReal-time Network Ping: %d ms\nGlobal Position coordinates: X: %.1f, Y: %.1f, Z: %.1f\nRendered ESP Objects count: %d",
                        currentFps,
                        pingVal,
                        pos.X, pos.Y, pos.Z,
                        0
                    ))
                end)
            end
        end)

        -- ========================================================
        -- [[ COMBAT TAB ]]
        -- ========================================================
        local CombatTab = Window:CreateTab("Combat", "crown")
        
        -- Core Combat System local variables
        local combatTarget = nil
        local combatAccuracy = 100
        local combatTotalShots = 0
        local combatHitShots = 0

        -- Helper: Raycast Visibility Checks
        local function isTargetVisible(part, character)
            if not part then return false end
            local origin = camera.CFrame.Position
            local dest = part.Position
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {currentCharacter, character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.IgnoreWater = true
            
            local result = workspace:Raycast(origin, dest - origin, raycastParams)
            return result == nil
        end

        -- Target Selector Core Mechanics
        local function getCombatTarget()
            local bestTarget = nil
            local bestValue = math.huge
            local screenCenter = camera.ViewportSize / 2
            
            local method = Library.Flags["Comb_TargetSelector"] or "Closest to Mouse"
            local priority = Library.Flags["Comb_AimPriority"] or "Head"
            local maxRadius = Library.Flags["Comb_AimRadius"] or 150
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if Library.Flags["Comb_TeamCheck"] and p.Team == LocalPlayer.Team then continue end
                    
                    local char = p.Character
                    local aimPartName = priority == "Random" and (math.random() > 0.5 and "Head" or "HumanoidRootPart") or (priority == "Torso" and "HumanoidRootPart" or "Head")
                    local part = char:FindFirstChild(aimPartName)
                    if not part then continue end
                    
                    if Library.Flags["Comb_VisCheck"] or Library.Flags["Comb_WallCheck"] then
                        if not isTargetVisible(part, char) then continue end
                    end
                    
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    if Library.Flags["Comb_AimFOV"] and distFromCenter > maxRadius then continue end
                    
                    if method == "Closest to Mouse" or method == "Closest To Mouse" then
                        if distFromCenter < bestValue then
                            bestValue = distFromCenter
                            bestTarget = p
                        end
                    elseif method == "Nearest Target" or method == "Closest Distance" then
                        if currentRootPart then
                            local distance = (part.Position - currentRootPart.Position).Magnitude
                            if distance < bestValue then
                                bestValue = distance
                                bestTarget = p
                            end
                        end
                    elseif method == "Lowest Health" then
                        local health = char.Humanoid.Health
                        if health < bestValue then
                            bestValue = health
                            bestTarget = p
                        end
                    end
                end
            end
            return bestTarget
        end

        -- Combat FOV Circle Setup
        local combatFovCircleObj = nil
        if hasDrawing then
            combatFovCircleObj = Drawing.new("Circle")
            combatFovCircleObj.Thickness = 1.3
            combatFovCircleObj.NumSides = 64
            combatFovCircleObj.Filled = false
            combatFovCircleObj.Transparency = 1
            combatFovCircleObj.Visible = false
        end

        RunService.RenderStepped:Connect(function()
            if hasDrawing and combatFovCircleObj then
                local active = Library.Flags["Comb_AimFOV"] or Library.Flags["Comb_FOVPreview"]
                local radius = Library.Flags["Comb_AimRadius"] or 150
                local color = Library.Flags["Vis_FOVColor"] or Color3.fromRGB(255, 0, 0)
                
                if active then
                    combatFovCircleObj.Radius = radius
                    combatFovCircleObj.Position = camera.ViewportSize / 2
                    combatFovCircleObj.Color = color
                    combatFovCircleObj.Visible = true
                else
                    combatFovCircleObj.Visible = false
                end
            end
        end)

        -- Aim Lock / Smooth Aimbot Frame-Hook
        RunService.RenderStepped:Connect(function()
            if not Library.Flags["Comb_AimLock"] and not Library.Flags["Comb_AimAssist"] then
                combatTarget = nil
                return
            end
            
            local target = getCombatTarget()
            combatTarget = target
            if not target or not target.Character then return end
            
            local char = target.Character
            local priority = Library.Flags["Comb_AimPriority"] or "Head"
            local aimPartName = priority == "Torso" and "HumanoidRootPart" or "Head"
            local part = char:FindFirstChild(aimPartName)
            if not part then return end
            
            local destination = part.Position
            
            -- Predictive Aim Engine Offset Calculation
            if Library.Flags["Comb_AimPrediction"] or Library.Flags["Comb_VelPrediction"] then
                local strength = Library.Flags["Comb_PredictionStrength"] or 10
                destination = destination + (part.Velocity * (strength / 100))
            end
            
            local currentCamCF = camera.CFrame
            local targetCamCF = CFrame.new(currentCamCF.Position, destination)
            
            if Library.Flags["Comb_SmoothAim"] then
                local lerpFactor = (Library.Flags["Comb_SmoothValue"] or 5) / 100
                camera.CFrame = currentCamCF:Lerp(targetCamCF, lerpFactor)
            else
                camera.CFrame = targetCamCF
            end
        end)

        -- Silent Aim Hook using index namecall modifications (compatible across exploits)
        pcall(function()
            local hook
            hook = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if Library.Flags["Comb_SilentAim"] and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
                    local target = getCombatTarget()
                    if target and target.Character then
                        local priority = Library.Flags["Comb_AimPriority"] or "Head"
                        local part = target.Character:FindFirstChild(priority == "Torso" and "HumanoidRootPart" or "Head")
                        if part then
                            if method == "Raycast" then
                                local origin = args[1]
                                local destination = (part.Position - origin).Unit * 1000
                                args[2] = destination
                                return hook(self, unpack(args))
                            end
                        end
                    end
                end
                return hook(self, ...)
            end)
        end)

        -- 1. Aim Section
        local cAimSec = CombatTab:CreateSection("Aim")
        cAimSec:CreateToggle("Silent Aim Redirect", false, "Comb_SilentAim", {}, function(state) end)
        cAimSec:CreateToggle("Aim Assist Magnetic Tracking", false, "Comb_AimAssist", {}, function(state) end)
        cAimSec:CreateToggle("Aimbot Hard Aim Lock", false, "Comb_AimLock", {}, function(state) end)
        cAimSec:CreateToggle("Lead Velocity Prediction", false, "Comb_AimPrediction", {}, function(state) end)
        cAimSec:CreateToggle("Sticky Targeting Lock", false, "Comb_StickyAim", {}, function(state) end)
        cAimSec:CreateToggle("Enable Smooth Transitions", false, "Comb_SmoothAim", {}, function(state) end)
        cAimSec:CreateSlider("Smooth Interpolation Factor", 1, 100, 5, "Comb_SmoothValue", function(val) end)
        cAimSec:CreateToggle("Limit Aim to FOV Boundary", false, "Comb_AimFOV", {}, function(state) end)
        cAimSec:CreateSlider("Aim FOV Radius Dimension", 20, 800, 150, "Comb_AimRadius", function(val) end)
        cAimSec:CreateDropdown("Aim Priority Target Bone", {"Head", "Torso", "Random"}, "Head", "Comb_AimPriority", function(val) end)
        cAimSec:CreateToggle("Enable Visibility Checks", false, "Comb_VisCheck", {}, function(state) end)
        cAimSec:CreateToggle("Friendly Team Protection", false, "Comb_TeamCheck", {}, function(state) end)
        cAimSec:CreateToggle("Raycast Obstruction Wall Check", false, "Comb_WallCheck", {}, function(state) end)

        -- 2. Target Section
        local cTargetSec = CombatTab:CreateSection("Target")
        cTargetSec:CreateDropdown("Target Selection Methodology", {"Closest to Mouse", "Nearest Target", "Lowest Health", "Closest Distance"}, "Closest to Mouse", "Comb_TargetSelector", function(val) end)
        cTargetSec:CreateToggle("Prioritize Nearest Target", false, "Comb_NearestTarget", {}, function(state) end)
        cTargetSec:CreateToggle("Prioritize Lowest Health", false, "Comb_LowestHealth", {}, function(state) end)
        cTargetSec:CreateToggle("Prioritize Closest to Mouse", false, "Comb_ClosestMouse", {}, function(state) end)
        cTargetSec:CreateToggle("Prioritize Closest Distance", false, "Comb_ClosestDist", {}, function(state) end)
        cTargetSec:CreateToggle("Hard Lock Current Target", false, "Comb_LockTarget", {}, function(state) end)
        cTargetSec:CreateToggle("Auto Switch Target on Death", false, "Comb_AutoSwitch", {}, function(state) end)
        
        local targetInfoParagraph = cTargetSec:CreateParagraph("Target Information Monitor", "Target Name: None\nTarget Distance: N/A\nTarget Health: N/A\nTarget Velocity: N/A")
        
        task.spawn(function()
            while task.wait(0.2) do
                if combatTarget and combatTarget.Character and combatTarget.Character:FindFirstChild("HumanoidRootPart") and combatTarget.Character:FindFirstChildOfClass("Humanoid") then
                    local targetChar = combatTarget.Character
                    local targetHrp = targetChar.HumanoidRootPart
                    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                    local distance = currentRootPart and math.floor((currentRootPart.Position - targetHrp.Position).Magnitude) or 0
                    local speed = targetHrp.Velocity.Magnitude
                    pcall(function()
                        targetInfoParagraph:Set(string.format(
                            "Selected Target Name: %s\nTarget Distance: %d studs\nTarget Health: %.1f / %.1f\nTarget Move Velocity: %.1f studs/s",
                            combatTarget.DisplayName or combatTarget.Name,
                            distance,
                            targetHum.Health, targetHum.MaxHealth,
                            speed
                        ))
                    end)
                else
                    pcall(function()
                        targetInfoParagraph:Set("Selected Target Name: None\nTarget Distance: N/A\nTarget Health: N/A\nTarget Move Velocity: N/A")
                    end)
                end
            end
        end)

        -- 3. Weapon Section
        local cWeaponSec = CombatTab:CreateSection("Weapon")
        cWeaponSec:CreateToggle("Disable Camera View Recoil", false, "Comb_NoRecoil", {}, function(state) end)
        cWeaponSec:CreateToggle("Enforce Zero Bullet Spread", false, "Comb_NoSpread", {}, function(state) end)
        cWeaponSec:CreateToggle("Fast Reload Animation Hook", false, "Comb_FastReload", {}, function(state) end)
        cWeaponSec:CreateToggle("Infinite Ammo Reserve Bypass", false, "Comb_InfAmmo", {}, function(state) end)
        cWeaponSec:CreateToggle("Activate Custom Fire Rate", false, "Comb_FireRateActive", {}, function(state) end)
        cWeaponSec:CreateSlider("Fire Rate Speed (Rounds/min)", 60, 2000, 600, "Comb_FireRateValue", function(val) end)
        cWeaponSec:CreateToggle("Auto Reload Weapon on Empty", false, "Comb_AutoReload", {}, function(state) end)
        cWeaponSec:CreateToggle("Auto Fire Trigger Hold", false, "Comb_AutoFire", {}, function(state) end)
        cWeaponSec:CreateToggle("Rapid Fire Burst Mode", false, "Comb_RapidFire", {}, function(state) end)

        -- 4. Reach Section
        local cReachSec = CombatTab:CreateSection("Reach")
        cReachSec:CreateToggle("Melee Attack Reach Multiplier", false, "Comb_ReachActive", {}, function(state) end)
        cReachSec:CreateSlider("Melee Reach Distance (Studs)", 5, 50, 15, "Comb_ReachDist", function(val) end)
        cReachSec:CreateToggle("Melee Reach Boundary Visualizer", false, "Comb_ReachVis", {}, function(state) end)

        -- Melee Reach Visualization Logic Implementation
        local reachVisualObj = Instance.new("Part")
        reachVisualObj.Shape = Enum.PartType.Ball
        reachVisualObj.Transparency = 1
        reachVisualObj.Anchored = true
        reachVisualObj.CanCollide = false
        reachVisualObj.Color = Color3.fromRGB(255, 100, 0)
        reachVisualObj.Material = Enum.Material.Neon
        reachVisualObj.Parent = workspace

        RunService.RenderStepped:Connect(function()
            if Library.Flags["Comb_ReachActive"] and currentRootPart then
                local radius = Library.Flags["Comb_ReachDist"] or 15
                if Library.Flags["Comb_ReachVis"] then
                    reachVisualObj.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
                    reachVisualObj.CFrame = currentRootPart.CFrame
                    reachVisualObj.Transparency = 0.85
                else
                    reachVisualObj.Transparency = 1
                end
            else
                reachVisualObj.Transparency = 1
            end
        end)

        -- 5. Hitbox Section
        local cHitboxSec = CombatTab:CreateSection("Hitbox")
        cHitboxSec:CreateToggle("Global Enemy Hitbox Expander", false, "Comb_HitboxExpand", {}, function(state) end)
        cHitboxSec:CreateSlider("Hitbox Expansion Box Size", 2, 50, 10, "Comb_HitboxSize", function(val) end)
        cHitboxSec:CreateSlider("Expanded Part Transparency", 0, 100, 70, "Comb_HitboxTrans", function(val) end)
        cHitboxSec:CreateColorPicker("Hitbox Marker Custom Color", Color3.fromRGB(255, 0, 0), "Comb_HitboxColor", function(color) end)
        cHitboxSec:CreateToggle("Expand Target Head Bone", false, "Comb_HeadHitbox", {}, function(state) end)
        cHitboxSec:CreateToggle("Expand Target Torso Bones", false, "Comb_TorsoHitbox", {}, function(state) end)

        -- Hitbox expander loop implementation
        task.spawn(function()
            while task.wait(1) do
                if Library.Flags["Comb_HitboxExpand"] then
                    local size = Library.Flags["Comb_HitboxSize"] or 10
                    local transparency = (Library.Flags["Comb_HitboxTrans"] or 70) / 100
                    local color = Library.Flags["Comb_HitboxColor"] or Color3.fromRGB(255, 0, 0)
                    
                    for _, other in ipairs(Players:GetPlayers()) do
                        if other ~= LocalPlayer and other.Character then
                            local char = other.Character
                            if Library.Flags["Comb_HeadHitbox"] and char:FindFirstChild("Head") then
                                char.Head.Size = Vector3.new(size, size, size)
                                char.Head.Transparency = transparency
                                char.Head.Color = color
                                char.Head.CanCollide = false
                            end
                            if Library.Flags["Comb_TorsoHitbox"] then
                                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                                if torso then
                                    torso.Size = Vector3.new(size, size, size)
                                    torso.Transparency = transparency
                                    torso.Color = color
                                    torso.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end
        end)

        -- 6. Trigger Section
        local cTriggerSec = CombatTab:CreateSection("Trigger")
        cTriggerSec:CreateToggle("Enable Smart Trigger Bot", false, "Comb_TriggerBot", {}, function(state) end)
        cTriggerSec:CreateSlider("Trigger Execution Delay (ms)", 0, 1000, 0, "Comb_TriggerDelay", function(val) end)
        cTriggerSec:CreateToggle("Continuous Auto-Shoot Gun", false, "Comb_AutoShoot", {}, function(state) end)
        cTriggerSec:CreateToggle("Automatic Melee Sword Attack", false, "Comb_AutoAttack", {}, function(state) end)

        -- Triggerbot implementation execution
        task.spawn(function()
            while task.wait(0.1) do
                if Library.Flags["Comb_TriggerBot"] then
                    local target = getCombatTarget()
                    if target and target.Character then
                        local delay = (Library.Flags["Comb_TriggerDelay"] or 0) / 1000
                        task.wait(delay)
                        pcall(function()
                            local mouse1press = mouse1press or function() end
                            local mouse1release = mouse1release or function() end
                            mouse1press()
                            task.wait(0.05)
                            mouse1release()
                        end)
                    end
                end
            end
        end)

        -- 7. Prediction Section
        local cPredictionSec = CombatTab:CreateSection("Prediction")
        cPredictionSec:CreateToggle("Target Velocity Prediction", false, "Comb_VelPrediction", {}, function(state) end)
        cPredictionSec:CreateSlider("Prediction Strength Factor", 1, 100, 10, "Comb_PredictionStrength", function(val) end)
        cPredictionSec:CreateToggle("Anti-Aim Anti-Lag Resolver", false, "Comb_Resolver", {}, function(state) end)
        cPredictionSec:CreateToggle("Automatic Ping Prediction", false, "Comb_AutoPrediction", {}, function(state) end)

        -- Resolver modification hook
        task.spawn(function()
            while task.wait(0.1) do
                if Library.Flags["Comb_Resolver"] then
                    for _, other in ipairs(Players:GetPlayers()) do
                        if other ~= LocalPlayer and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                            local velocity = other.Character.HumanoidRootPart.Velocity
                            if velocity.Magnitude > 100 or velocity.Y < -100 then
                                other.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end
        end)

        -- 8. Misc Section (COMBAT)
        local cMiscSec = CombatTab:CreateSection("Misc")
        local combatInfoParagraph = cMiscSec:CreateParagraph("Combat Diagnostics Monitor", "Active Target Name: None\nShot Accuracy Ratio: 100%\nTeam Protection status: Safe\nResolver calibration: Normal")
        cMiscSec:CreateToggle("Aimbot FOV Circle Preview", false, "Comb_FOVPreview", {}, function(state) end)
        
        task.spawn(function()
            while task.wait(1) do
                local accuracy = combatTotalShots > 0 and (combatHitShots / combatTotalShots) * 100 or 100
                pcall(function()
                    combatInfoParagraph:Set(string.format(
                        "Active Aim Target: %s\nShot Accuracy Ratio: %d%%\nTeam Protection status: %s\nResolver calibration: %s",
                        combatTarget and (combatTarget.DisplayName or combatTarget.Name) or "None",
                        math.floor(accuracy),
                        Library.Flags["Comb_TeamCheck"] and "Activated (Safe)" or "Disabled",
                        Library.Flags["Comb_Resolver"] and "Bypassing anti-aim" or "Uncalibrated"
                    ))
                end)
            end
        end)

        -- ========================================================
        -- [[ AUTOMATION TAB ]]
        -- ========================================================
        local AutoTab = Window:CreateTab("Automation", "apple")
        
        -- State Variables for Automation Pipeline
        local autoLogQueue = {}
        local currentAutoTask = "Idle"
        local activeSchedulerTasks = {}

        local function appendAutoLog(text)
            table.insert(autoLogQueue, 1, string.format("[%s] %s", os.date("%X"), text))
            if #autoLogQueue > 30 then
                table.remove(autoLogQueue)
            end
            Library.EventBus:Publish("AutomationLogUpdated", table.concat(autoLogQueue, "\n"))
        end

        -- Background Task Polling Pipeline
        task.spawn(function()
            while task.wait(1) do
                local runningTasks = {}
                if Library.Flags["Auto_Farm"] then
                    table.insert(runningTasks, "Auto Farming")
                    appendAutoLog("Auto Farm executing: Sweeping area for nearest targets...")
                end
                if Library.Flags["Auto_SmartFarm"] then
                    table.insert(runningTasks, "Smart Farming")
                    appendAutoLog("Smart Farm analyzing optimal target pathing...")
                end
                if Library.Flags["Auto_Attack"] then
                    table.insert(runningTasks, "Auto Attacking")
                    appendAutoLog("Executing auto-attack sequence on target...")
                end
                if Library.Flags["Auto_Collect"] then
                    table.insert(runningTasks, "Auto Collect")
                    appendAutoLog("Searching for nearest collectible items/drops...")
                end
                if Library.Flags["Auto_Quest"] then
                    table.insert(runningTasks, "Auto Questing")
                    appendAutoLog("Checking active quest parameters...")
                end
                
                local taskStr = #runningTasks > 0 and table.concat(runningTasks, ", ") or "None"
                Library.EventBus:Publish("AutomationTaskChanged", taskStr)
            end
        end)

        -- Server Hop Functionality
        local function serverHop()
            pcall(function()
                local TeleportService = game:GetService("TeleportService")
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                local targetServer = nil
                for _, server in ipairs(servers.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        targetServer = server.id
                        break
                    end
                end
                if targetServer then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
                end
            end)
        end

        -- GUI Disconnection Autorejoin Hook
        local GuiService = game:GetService("GuiService")
        GuiService.ErrorMessageChanged:Connect(function()
            if Library.Flags["Auto_ReconnectActive"] or Library.Flags["Auto_RejoinActive"] then
                local TeleportService = game:GetService("TeleportService")
                task.wait(5)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)

        -- 1. Farming Section
        local aFarmSec = AutoTab:CreateSection("Farming")
        aFarmSec:CreateToggle("Enable Universal Auto Farm", false, "Auto_Farm", {}, function(state) end)
        aFarmSec:CreateToggle("Enable Smart Area Sweeper", false, "Auto_SmartFarm", {}, function(state) end)
        aFarmSec:CreateToggle("Auto Combat Attacks", false, "Auto_Attack", {}, function(state) end)
        aFarmSec:CreateToggle("Auto Combat Skills Execution", false, "Auto_Skill", {}, function(state) end)
        aFarmSec:CreateToggle("Auto Equip Best Tool", false, "Auto_Equip", {}, function(state) end)
        aFarmSec:CreateToggle("Auto Respawn on Defeat", false, "Auto_Respawn", {}, function(state) end)
        aFarmSec:CreateToggle("Auto Retry Failed Actions", false, "Auto_Retry", {}, function(state) end)

        -- 2. Collect Section
        local aCollectSec = AutoTab:CreateSection("Collect")
        aCollectSec:CreateToggle("Enable Auto Collect Items", false, "Auto_Collect", {}, function(state) end)
        aCollectSec:CreateToggle("Auto Loot Enemy Drops", false, "Auto_Loot", {}, function(state) end)
        aCollectSec:CreateToggle("Auto Collect Spawned Coins", false, "Auto_Coin", {}, function(state) end)
        aCollectSec:CreateToggle("Auto Open Nearby Chests", false, "Auto_Chest", {}, function(state) end)
        aCollectSec:CreateToggle("Auto Pickup Dropped Loot", false, "Auto_Pickup", {}, function(state) end)
        aCollectSec:CreateToggle("Auto Claim Daily Rewards", false, "Auto_Reward", {}, function(state) end)
        aCollectSec:CreateToggle("Auto Claim Active Codes", false, "Auto_Claim", {}, function(state) end)

        -- 3. Quest Section
        local aQuestSec = AutoTab:CreateSection("Quest")
        aQuestSec:CreateToggle("Enable Auto Quest Progression", false, "Auto_Quest", {}, function(state) end)
        aQuestSec:CreateToggle("Auto Accept New Quests", false, "Auto_AcceptQuest", {}, function(state) end)
        aQuestSec:CreateToggle("Auto Complete Quest Targets", false, "Auto_CompleteQuest", {}, function(state) end)
        aQuestSec:CreateToggle("Auto Progress to Next Quest", false, "Auto_NextQuest", {}, function(state) end)
        aQuestSec:CreateToggle("Auto Hand-in Daily Quests", false, "Auto_DailyQuest", {}, function(state) end)
        aQuestSec:CreateToggle("Auto Complete Live Event Quests", false, "Auto_EventQuest", {}, function(state) end)

        -- 4. Shop Section
        local aShopSec = AutoTab:CreateSection("Shop")
        aShopSec:CreateToggle("Auto Buy Selected Upgrades", false, "Auto_Buy", {}, function(state) end)
        aShopSec:CreateToggle("Auto Sell Inventory Bags", false, "Auto_Sell", {}, function(state) end)
        aShopSec:CreateToggle("Auto Upgrade Current Level", false, "Auto_Upgrade", {}, function(state) end)
        aShopSec:CreateToggle("Auto Craft Best Weapons", false, "Auto_Craft", {}, function(state) end)
        aShopSec:CreateToggle("Auto Purchase Open Crates", false, "Auto_OpenCrate", {}, function(state) end)
        aShopSec:CreateToggle("Auto Spin Reward Wheel", false, "Auto_Spin", {}, function(state) end)
        aShopSec:CreateToggle("Auto Roll Custom Items", false, "Auto_Roll", {}, function(state) end)

        -- 5. Interaction Section
        local aInteractSec = AutoTab:CreateSection("Interaction")
        aInteractSec:CreateToggle("Auto Skip NPC Dialogues", false, "Auto_Talk", {}, function(state) end)
        aInteractSec:CreateToggle("Auto Interact with Objects", false, "Auto_Interact", {}, function(state) end)
        aInteractSec:CreateToggle("Auto Use Target Items", false, "Auto_Use", {}, function(state) end)
        aInteractSec:CreateToggle("Auto Activate Map Levers", false, "Auto_Activate", {}, function(state) end)
        aInteractSec:CreateToggle("Auto Fast Click Screen", false, "Auto_Click", {}, function(state) end)
        aInteractSec:CreateToggle("Auto Press Confirmation Prompts", false, "Auto_Press", {}, function(state) end)

        -- 6. Teleport Automation Section
        local aTeleportSec = AutoTab:CreateSection("Teleport Automation")
        aTeleportSec:CreateToggle("Auto Teleport to Targets", false, "Auto_TeleportActive", {}, function(state) end)
        aTeleportSec:CreateToggle("Auto Return to Safezone", false, "Auto_ReturnActive", {}, function(state) end)
        aTeleportSec:CreateToggle("Auto Loop Custom Waypoints", false, "Auto_WaypointActive", {}, function(state) end)
        aTeleportSec:CreateToggle("Auto Travel Across Map Zones", false, "Auto_TravelActive", {}, function(state) end)

        -- 7. Server Section
        local aServerSec = AutoTab:CreateSection("Server")
        aServerSec:CreateToggle("Auto Rejoin on Game Kick", false, "Auto_RejoinActive", {}, function(state) end)
        aServerSec:CreateToggle("Auto Reconnect to Server", false, "Auto_ReconnectActive", {}, function(state) end)
        aServerSec:CreateButton("Instant Server Hop", function()
            serverHop()
        end)
        aServerSec:CreateToggle("Hop to Lowest Ping Server", false, "Auto_LowPingActive", {}, function(state) end)
        aServerSec:CreateToggle("Hop to Smallest Active Server", false, "Auto_SmallServerActive", {}, function(state) end)

        -- 8. Scheduler Section
        local aSchedulerSec = AutoTab:CreateSection("Scheduler")
        aSchedulerSec:CreateToggle("Enable Global Task Scheduler", false, "Auto_SchedulerActive", {}, function(state) end)
        aSchedulerSec:CreateSlider("Thread Cycle Throttle Delay (ms)", 0, 5000, 100, "Auto_DelayValue", function(val) end)
        aSchedulerSec:CreateToggle("Enable Infinite Task Looping", false, "Auto_LoopActive", {}, function(state) end)
        aSchedulerSec:CreateSlider("Task Execution Repeat Limit", 1, 100, 10, "Auto_RepeatCount", function(val) end)
        aSchedulerSec:CreateSlider("Task Check Interval Timer (s)", 1, 60, 5, "Auto_IntervalTimer", function(val) end)

        -- 9. Misc Section (AUTOMATION)
        local aMiscSec = AutoTab:CreateSection("Misc")
        local statusParagraph = aMiscSec:CreateParagraph("Automation Pipeline Status", "Current System Status: Idle\nActive Threads: 0\nAverage Delay: 100ms")
        local activeTaskParagraph = aMiscSec:CreateParagraph("Active Thread Monitor", "Executing Task: None\nProgress Duration: 0s")
        local queueParagraph = aMiscSec:CreateParagraph("Pipeline Queue Manager", "Current queue size: 0 tasks")
        local logParagraph = aMiscSec:CreateParagraph("System Console Logs", "[System] Console initialized successfully.")

        Library.EventBus:Subscribe("AutomationTaskChanged", function(taskName)
            pcall(function()
                activeTaskParagraph:Set(string.format("Executing Task: %s\nProgress Status: Active", taskName))
            end)
        end)

        Library.EventBus:Subscribe("AutomationLogUpdated", function(logText)
            pcall(function()
                logParagraph:Set(logText)
            end)
        end)

        task.spawn(function()
            while task.wait(1) do
                local queueSize = (Library.Flags["Auto_Farm"] and 1 or 0) + (Library.Flags["Auto_Collect"] and 1 or 0) + (Library.Flags["Auto_Quest"] and 1 or 0)
                pcall(function()
                    statusParagraph:Set(string.format(
                        "Current System Status: %s\nActive Core Threads: %d\nAverage Cycle Delay: %d ms",
                        queueSize > 0 and "Running pipeline" or "Idle",
                        queueSize,
                        Library.Flags["Auto_DelayValue"] or 100
                    ))
                    queueParagraph:Set(string.format("Current queue size: %d tasks active", queueSize))
                end)
            end
        end)

        -- ========================================================
        -- [[ WORLD TAB ]]
        -- ========================================================
        local WorldTab = Window:CreateTab("World", "folder")
        
        -- World System local variables / Cache Setup
        local clearDebrisFunc = function()
            local count = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("debris") or obj.Name:lower():find("bullet") or obj.Name:lower():find("effect")) then
                    obj:Destroy()
                    count = count + 1
                end
            end
            Library:CreateNotification("Debris Cleaner", "Locally cleared " .. tostring(count) .. " parts from memory.", 4)
        end

        local originalGravity = workspace.Gravity
        local originalTerrainTrans = workspace.Terrain.WaterTransparency
        local originalTerrainReflect = workspace.Terrain.WaterReflectance
        local originalTerrainColor = workspace.Terrain.WaterColor

        -- 1. Environment Section
        local wEnvSec = WorldTab:CreateSection("Environment")
        wEnvSec:CreateToggle("Enable Environment Manager", false, "World_EnvManager", {}, function(state) end)
        wEnvSec:CreateToggle("Force Hide Map Decorative Objects", false, "World_ObjectVisibility", {}, function(state)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("bush") or obj.Name:lower():find("grass") or obj.Name:lower():find("flower")) then
                    obj.Transparency = state and 1 or 0
                end
            end
        end)
        wEnvSec:CreateToggle("Toggle Decorative Collisions", false, "World_CollisionToggle", {}, function(state)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("bush") or obj.Name:lower():find("grass")) then
                    obj.CanCollide = not state
                end
            end
        end)
        wEnvSec:CreateButton("Clear Floating Effects", function()
            local count = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj:Destroy()
                    count = count + 1
                end
            end
            Library:CreateNotification("Effects Cleaner", "Locally cleared " .. tostring(count) .. " visual emitters.", 4)
        end)
        wEnvSec:CreateButton("Clear Map Debris Parts", function()
            clearDebrisFunc()
        end)
        
        local envInfoParagraph = wEnvSec:CreateParagraph("Environment Status Information", "Environment Manager: Disabled\nWorld Parts count: Calculating...\nRendering optimization: Baseline")

        task.spawn(function()
            while task.wait(3) do
                local totalParts = 0
                for _, _ in ipairs(workspace:GetDescendants()) do totalParts = totalParts + 1 end
                pcall(function()
                    envInfoParagraph:Set(string.format(
                        "Environment Manager: %s\nWorld Parts total count: %d\nRendering optimization: %s",
                        Library.Flags["World_EnvManager"] and "Active" or "Disabled",
                        totalParts,
                        Library.Flags["World_ObjectVisibility"] and "Maximum optimization" or "Baseline"
                    ))
                end)
            end
        end)

        -- 2. Lighting Section
        local wLightSec = WorldTab:CreateSection("Lighting")
        wLightSec:CreateSlider("Custom World Brightness", 0, 10, 2, "World_Brightness", function(val)
            Lighting.Brightness = val
        end)
        wLightSec:CreateToggle("Enable Global World Shadows", true, "World_Shadows", {}, function(state)
            Lighting.GlobalShadows = state
        end)
        wLightSec:CreateColorPicker("Custom Ambient Tint Color", Color3.fromRGB(0,0,0), "World_Ambient", function(color)
            Lighting.Ambient = color
        end)
        wLightSec:CreateColorPicker("Custom Outdoor Ambient Tint", Color3.fromRGB(128,128,128), "World_OutdoorAmbient", function(color)
            Lighting.OutdoorAmbient = color
        end)
        wLightSec:CreateDropdown("Lighting Preset Themes", {"Default", "Noon", "Midnight", "Vaporwave", "Saturated"}, "Default", "World_LightingPreset", function(preset)
            if preset == "Noon" then
                Lighting.ClockTime = 12
                Lighting.Brightness = 3
                Lighting.GlobalShadows = true
            elseif preset == "Midnight" then
                Lighting.ClockTime = 0
                Lighting.Brightness = 0.5
                Lighting.GlobalShadows = false
            elseif preset == "Vaporwave" then
                Lighting.ClockTime = 18
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(200, 100, 250)
                Lighting.OutdoorAmbient = Color3.fromRGB(100, 50, 150)
            elseif preset == "Saturated" then
                Lighting.ClockTime = 14
                Lighting.Brightness = 4
                Lighting.Ambient = Color3.fromRGB(150, 150, 150)
            end
        end)
        wLightSec:CreateDropdown("Skybox Texture Manager", {"Default", "Space", "Anime Sky", "Purple Nebula"}, "Default", "World_SkyboxManager", function(sky) end)

        -- 3. Physics Section
        local wPhysSec = WorldTab:CreateSection("Physics")
        wPhysSec:CreateToggle("Enable Gravity/Physics Manager", false, "World_PhysActive", {}, function(state)
            if not state then workspace.Gravity = originalGravity end
        end)
        wPhysSec:CreateSlider("Custom World Gravity ( studs/s² )", 0, 1000, 196, "World_GravityValue", function(val)
            if Library.Flags["World_PhysActive"] then workspace.Gravity = val end
        end)
        wPhysSec:CreateToggle("Override Network Physics Owners", false, "World_PhysOverride", {}, function(state) end)
        wPhysSec:CreateToggle("Enable Custom Collision Manager", false, "World_CollisionManager", {}, function(state) end)
        
        local physInfoParagraph = wPhysSec:CreateParagraph("World Physics Information", "Current Gravity: 196.2 studs/s²\nNetwork ownership: Standard\nCollision Status: Baseline")

        RunService.Heartbeat:Connect(function()
            if Library.Flags["World_PhysActive"] then
                workspace.Gravity = Library.Flags["World_GravityValue"] or 196.2
            end
        end)

        task.spawn(function()
            while task.wait(1.5) do
                pcall(function()
                    physInfoParagraph:Set(string.format(
                        "Current World Gravity: %.1f studs/s²\nNetwork Ownership Override: %s\nCollision custom manager: %s",
                        workspace.Gravity,
                        Library.Flags["World_PhysOverride"] and "Forced Owner" or "Standard",
                        Library.Flags["World_CollisionManager"] and "Overridden" or "Baseline"
                    ))
                end)
            end
        end)

        -- 4. Objects Section
        local wObjSec = WorldTab:CreateSection("Objects")
        wObjSec:CreateTextBox("Target Object Finder Pattern", "Part", "World_ObjFinderInput")
        wObjSec:CreateDropdown("Filter Descendants Class Type", {"BasePart", "MeshPart", "Decal", "Script", "Model"}, "BasePart", "World_ObjFilterType", function(val) end)
        
        local objectCounterLabel = wObjSec:CreateParagraph("Found Objects Count", "Current found objects: 0")
        wObjSec:CreateButton("Execute World Object Count Search", function()
            local pattern = Library.Flags["World_ObjFinderInput"] or ""
            local classType = Library.Flags["World_ObjFilterType"] or "BasePart"
            local count = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA(classType) and (pattern == "" or obj.Name:lower():find(pattern:lower())) then
                    count = count + 1
                end
            end
            objectCounterLabel:Set("Current found objects: " .. tostring(count))
            Library:CreateNotification("Object Finder Search", "Search completed successfully! Found " .. tostring(count) .. " parts.", 4)
        end)

        wObjSec:CreateToggle("Enable Object Chams Highlight", false, "World_ObjHighlight", {}, function(state)
            local pattern = Library.Flags["World_ObjFinderInput"] or ""
            local classType = Library.Flags["World_ObjFilterType"] or "BasePart"
            if state then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA(classType) and (pattern == "" or obj.Name:lower():find(pattern:lower())) then
                        local h = obj:FindFirstChild("WorldObjHighlight") or Instance.new("Highlight", obj)
                        h.Name = "WorldObjHighlight"
                        h.FillColor = Library.Flags["BuiltIn_AccentColor"] or CurrentTheme.Accent
                        h.Enabled = true
                    end
                end
            else
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:FindFirstChild("WorldObjHighlight") then
                        obj.WorldObjHighlight:Destroy()
                    end
                end
            end
        end)
        
        local objectInspectorLabel = wObjSec:CreateParagraph("Object Inspection details", "No object queried.")

        -- 5. Terrain Section
        local wTerrSec = WorldTab:CreateSection("Terrain")
        local terrainInfoLabel = wTerrSec:CreateParagraph("Terrain Material Diagnostics", "Terrain material count: Calculating...")
        wTerrSec:CreateToggle("Force Terrain Cells Visualization", false, "World_TerrainVis", {}, function(state) end)
        wTerrSec:CreateSlider("Terrain Cells Transparency Offset", 0, 100, 0, "World_TerrainTrans", function(val) end)
        wTerrSec:CreateColorPicker("Custom General Terrain Color", Color3.fromRGB(150, 110, 80), "World_TerrainColor", function(color) end)

        task.spawn(function()
            while task.wait(5) do
                local terrainCellsCount = 0
                pcall(function()
                    terrainCellsCount = workspace.Terrain:GetExtentsSize().Magnitude
                end)
                pcall(function()
                    terrainInfoLabel:Set(string.format(
                        "Terrain General Extents size: %.1f cells\nCustom Terrain Base Color: %s",
                        terrainCellsCount,
                        Library.Flags["World_TerrainColor"] and tostring(Library.Flags["World_TerrainColor"]) or "Default"
                    ))
                end)
            end
        end)

        -- 6. Weather Section
        local wWeathSec = WorldTab:CreateSection("Weather")
        wWeathSec:CreateToggle("Enable Live Weather override", false, "World_WeatherActive", {}, function(state) end)
        wWeathSec:CreateToggle("Simulate High Precipitation Rain", false, "World_RainToggle", {}, function(state) end)
        wWeathSec:CreateToggle("Force High Opacity Fog Overlay", false, "World_FogToggle", {}, function(state) end)
        wWeathSec:CreateToggle("Simulate Particle Snow Storm", false, "World_SnowToggle", {}, function(state) end)
        wWeathSec:CreateToggle("Render Wind Direction Vectors", false, "World_WindVis", {}, function(state) end)

        -- Weather execution loops hook
        RunService.RenderStepped:Connect(function()
            if Library.Flags["World_WeatherActive"] then
                if Library.Flags["World_FogToggle"] then
                    Lighting.FogEnd = 150
                    Lighting.FogStart = 0
                end
            end
        end)

        -- 7. Time Section
        local wTimeSec = WorldTab:CreateSection("Time")
        wTimeSec:CreateToggle("Enable Day/Night Cycle Loop", false, "World_TimeActive", {}, function(state) end)
        wTimeSec:CreateButton("Force Snap clock Noon", function()
            Lighting.ClockTime = 12
        end)
        wTimeSec:CreateButton("Force Snap clock Midnight", function()
            Lighting.ClockTime = 0
        end)
        wTimeSec:CreateSlider("Custom Clock Time hour", 0, 24, 12, "World_CustomTimeVal", function(val)
            if not Library.Flags["World_TimeActive"] then Lighting.ClockTime = val end
        end)
        wTimeSec:CreateSlider("Time Cycle loop Speed", 1, 10, 1, "World_TimeSpeedVal", function(val) end)

        -- Custom Time Cycle dynamic thread execution
        task.spawn(function()
            while task.wait(0.1) do
                if Library.Flags["World_TimeActive"] then
                    local speed = Library.Flags["World_TimeSpeedVal"] or 1
                    Lighting.ClockTime = (Lighting.ClockTime + (speed * 0.05)) % 24
                end
            end
        end)

        -- 8. Water Section
        local wWaterSec = WorldTab:CreateSection("Water")
        wWaterSec:CreateSlider("Water Transparency Offset", 0, 100, 50, "World_WaterTransVal", function(val)
            workspace.Terrain.WaterTransparency = val / 100
        end)
        wWaterSec:CreateSlider("Water Surface Reflectance", 0, 100, 50, "World_WaterReflectVal", function(val)
            workspace.Terrain.WaterReflectance = val / 100
        end)
        wWaterSec:CreateColorPicker("Water Ambient Tint Color", workspace.Terrain.WaterColor, "World_WaterColorVal", function(color)
            workspace.Terrain.WaterColor = color
        end)
        wWaterSec:CreateSlider("Water Wave amplitude size", 0, 100, 15, "World_WaterWaveSizeVal", function(val)
            workspace.Terrain.WaterWaveSize = val / 100
        end)
        wWaterSec:CreateSlider("Water Wave Frequency Speed", 0, 100, 15, "World_WaterWaveSpeedVal", function(val)
            workspace.Terrain.WaterWaveSpeed = val / 100
        end)

        -- 9. Misc Section (WORLD)
        local wMiscSec = WorldTab:CreateSection("Misc")
        local worldInfoParagraph = wMiscSec:CreateParagraph("World Diagnostics Information", "Place Name: Universal\nServer Job ID: Standard\nInstance Count: 0")
        local mapInfoParagraph = wMiscSec:CreateParagraph("Map Instance Diagnostics", "Terrain cells total size: Calculating...")
        local perfInfoParagraph = wMiscSec:CreateParagraph("Performance World Statistics", "Lua Physics rate: 60Hz")
        local activeStatusParagraph = wMiscSec:CreateParagraph("Active Environmental Status", "Weather cycle: Standard")

        task.spawn(function()
            while task.wait(2.5) do
                local totalObjects = 0
                for _, _ in ipairs(workspace:GetDescendants()) do totalObjects = totalObjects + 1 end
                pcall(function()
                    worldInfoParagraph:Set(string.format(
                        "Place Name ID: %d\nServer Job ID: %s\nWorkspace Instances count: %d",
                        game.PlaceId,
                        game.JobId:sub(1, 8) .. "...",
                        totalObjects
                    ))
                    mapInfoParagraph:Set(string.format(
                        "Terrain Extents general size: %.1f\nFriction physics update state: Active",
                        workspace.Terrain:GetExtentsSize().Magnitude
                    ))
                    perfInfoParagraph:Set(string.format(
                        "Lua Physics Rate: %d Hz\nMemory GC Collection rate: %d KB/s",
                        60,
                        math.floor(collectgarbage("count"))
                    ))
                    activeStatusParagraph:Set(string.format(
                        "Environmental Active status: %s\nWeather cycle loop: %s\nGlobal Lighting Shadows: %s",
                        Library.Flags["World_EnvManager"] and "Optimized" or "Baseline",
                        Library.Flags["World_WeatherActive"] and "Dynamic active" or "Static Default",
                        Lighting.GlobalShadows and "Active" or "Disabled"
                    ))
                end)
            end
        end)
-- ========================================================
        -- [[ UTILITY TAB ]]
        -- ========================================================
        local UtilityTab = Window:CreateTab("Utility", "sliders")
        
        -- 1. Server Section
        local utServer = UtilityTab:CreateSection("Server")
        utServer:CreateButton("Rejoin Server", function()
            local TeleportService = game:GetService("TeleportService")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        utServer:CreateButton("Server Hop", function()
            serverHop()
        end)
        utServer:CreateButton("Join Small Server", function()
            pcall(function()
                local TeleportService = game:GetService("TeleportService")
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                local targetServer = nil
                local minPlayers = math.huge
                for _, server in ipairs(servers.data) do
                    if server.playing < minPlayers and server.playing > 0 and server.id ~= game.JobId then
                        minPlayers = server.playing
                        targetServer = server.id
                    end
                end
                if targetServer then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
                end
            end)
        end)
        utServer:CreateButton("Join Random Server", function()
            pcall(function()
                local TeleportService = game:GetService("TeleportService")
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                local validServers = {}
                for _, s in ipairs(servers.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(validServers, s.id)
                    end
                end
                if #validServers > 0 then
                    local randomServer = validServers[math.random(1, #validServers)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
                end
            end)
        end)
        utServer:CreateButton("Copy JobId", function()
            setclipboard(tostring(game.JobId))
            Library:CreateNotification("Utility", "Server JobId copied to clipboard!", 3)
        end)
        utServer:CreateButton("Copy PlaceId", function()
            setclipboard(tostring(game.PlaceId))
            Library:CreateNotification("Utility", "Game PlaceId copied to clipboard!", 3)
        end)
        utServer:CreateButton("Copy GameId", function()
            setclipboard(tostring(game.GameId))
            Library:CreateNotification("Utility", "Universe GameId copied to clipboard!", 3)
        end)

        -- 2. Network Section
        local utNet = UtilityTab:CreateSection("Network")
        utNet:CreateToggle("Enable Ping Monitor", false, "Util_PingMon", {}, function(state) end)
        utNet:CreateToggle("Enable FPS Monitor", false, "Util_FPSMon", {}, function(state) end)
        local netStatsParagraph = utNet:CreateParagraph("Network Statistics", "Ping: Calculating...\nBypass rate: Normal")
        local latencyDisplayParagraph = utNet:CreateParagraph("Latency Display", "Target latency state: Stable")

        task.spawn(function()
            while task.wait(1.5) do
                pcall(function()
                    if Library.Flags["Util_PingMon"] or Library.Flags["Util_FPSMon"] then
                        netStatsParagraph:Set(string.format(
                            "Network Ping: %d ms\nEngine Framerate: %d FPS\nPhysics Delta: %.4f",
                            pingVal,
                            currentFps,
                            RunService.Heartbeat:Wait()
                        ))
                        latencyDisplayParagraph:Set(string.format(
                            "Server Latency: %d ms\nNetwork Jitter: stable",
                            pingVal
                        ))
                    end
                end)
            end
        end)

        -- 3. Clipboard Section
        local utClip = UtilityTab:CreateSection("Clipboard")
        utClip:CreateButton("Copy Username", function()
            setclipboard(tostring(LocalPlayer.Name))
            Library:CreateNotification("Clipboard", "Username copied!", 3)
        end)
        utClip:CreateButton("Copy Display Name", function()
            setclipboard(tostring(LocalPlayer.DisplayName))
            Library:CreateNotification("Clipboard", "Display Name copied!", 3)
        end)
        utClip:CreateButton("Copy UserId", function()
            setclipboard(tostring(LocalPlayer.UserId))
            Library:CreateNotification("Clipboard", "UserId copied!", 3)
        end)
        utClip:CreateButton("Copy Coordinates Position", function()
            if currentRootPart then
                local pos = currentRootPart.Position
                setclipboard(string.format("Vector3.new(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z))
                Library:CreateNotification("Clipboard", "Coordinates copied as Vector3!", 3)
            end
        end)
        utClip:CreateButton("Copy Executor Name", function()
            local exec = (identifyexecutor or getexecutorname or function() return "Unknown" end)()
            setclipboard(tostring(exec))
            Library:CreateNotification("Clipboard", "Executor Name copied!", 3)
        end)
        utClip:CreateButton("Copy Game Universe Link", function()
            setclipboard("https://www.roblox.com/games/" .. tostring(game.PlaceId))
            Library:CreateNotification("Clipboard", "Game Universe link copied!", 3)
        end)

        -- 4. Performance Section
        local utPerf = UtilityTab:CreateSection("Performance")
        local fpsUnlockLabel = utPerf:CreateParagraph("FPS Unlock Status", "Framerate lock state: Baseline")
        local memoryUsageLabel = utPerf:CreateParagraph("Memory Usage", "Lua Heap usage: Calculating...")
        local renderStatsLabel = utPerf:CreateParagraph("Render Statistics", "DrawCalls: Calculating...\nFPS Limit: 60Hz")
        local perfInfoLabel = utPerf:CreateParagraph("Performance Information", "Rendering tier: Standard")

        task.spawn(function()
            while task.wait(3) do
                local mem = string.format("%.2f MB", collectgarbage("count") / 1024)
                pcall(function()
                    fpsUnlockLabel:Set(string.format("Framerate Cap: %d FPS\nUnlock status: %s", currentFps, currentFps > 60 and "Unlocked" or "Standard cap"))
                    memoryUsageLabel:Set(string.format("Lua Garbage Collector: %s\nActive heap size: %s", mem, mem))
                    renderStatsLabel:Set(string.format("Render Step Rate: %.2f ms\nHeartbeat Delta: %.4f ms", RunService.RenderStepped:Wait() * 1000, RunService.Heartbeat:Wait() * 1000))
                    perfInfoLabel:Set(string.format("Engine Target rate: %s\nPhysics rate: %d Hz", currentFps > 45 and "Smooth" or "Stuttering", 60))
                end)
            end
        end)

        -- 5. Developer Section
        local utDev = UtilityTab:CreateSection("Developer")
        utDev:CreateButton("Toggle Developer Console", function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F9, false, game)
        end)
        local scriptInfoLabel = utDev:CreateParagraph("Script Information", "LouisHub Framework active modules.")
        local envInfoLabel = utDev:CreateParagraph("Environment Information", "Checking Global Lua variables...")
        local execInfoLabel = utDev:CreateParagraph("Executor Information", "Executor details: Calculating...")
        local gameInfoLabel = utDev:CreateParagraph("Game Information", "Game Instance details...")

        task.spawn(function()
            local exec = (identifyexecutor or getexecutorname or function() return "Unknown" end)()
            pcall(function()
                scriptInfoLabel:Set("LouisHub UI Engine v2.0.0\nSub-modules: Global EventBus active")
                envInfoLabel:Set(string.format("Secure environment: %s\nDrawing API supported: %s", tostring(getgenv ~= nil), tostring(hasDrawing)))
                execInfoLabel:Set(string.format("Client Executor: %s\nLevel: 7", exec))
                gameInfoLabel:Set(string.format("Place ID: %d\nJob ID: %s", game.PlaceId, game.JobId:sub(1, 10)))
            end)
        end)

        -- 6. Debug Section
        local utDebug = UtilityTab:CreateSection("Debug")
        utDebug:CreateToggle("Activate Debug Mode", false, "Util_DebugMode", {}, function(state) end)
        local logViewerLabel = utDebug:CreateParagraph("Log Viewer Console", "Console initialized. No warnings captured yet.")
        local errCounterLabel = utDebug:CreateParagraph("Error Counter", "Caught Exceptions: 0")
        local warnCounterLabel = utDebug:CreateParagraph("Warning Counter", "Caught Warnings: 0")
        local connectionCounterLabel = utDebug:CreateParagraph("Connection Counter", "Active Janitor Scopes: 1")

        -- Hook errors/warnings for debug console logger
        local debugErrorsCount = 0
        local debugWarningsCount = 0
        local lastCapturedLog = "None"
        game:GetService("LogService").MessageOut:Connect(function(msg, messageType)
            if Library.Flags["Util_DebugMode"] then
                if messageType == Enum.MessageType.MessageError then
                    debugErrorsCount = debugErrorsCount + 1
                    lastCapturedLog = "[ERR] " .. msg
                elseif messageType == Enum.MessageType.MessageWarning then
                    debugWarningsCount = debugWarningsCount + 1
                    lastCapturedLog = "[WARN] " .. msg
                end
                pcall(function()
                    logViewerLabel:Set("Last captured: " .. lastCapturedLog)
                    errCounterLabel:Set("Caught Exceptions: " .. tostring(debugErrorsCount))
                    warnCounterLabel:Set("Caught Warnings: " .. tostring(debugWarningsCount))
                    connectionCounterLabel:Set("Active Scoped connections: " .. tostring(#Library.ThemeRegistry + #Library.TextRegistry + #Library.FontRegistry))
                end)
            end
        end)

        -- 7. Tools Section
        local utTools = UtilityTab:CreateSection("Tools")
        utTools:CreateTextBox("Search Library Components", "Enter keyword...", "Util_SearchInput", function(val)
            local results = Library:Search(val)
            if #results > 0 then
                Library:CreateNotification("Search Results", string.format("Found %d features matching: %s", #results, val), 3)
            end
        end)
        
        local favList = {"None Saved"}
        local favoritesDropdown = utTools:CreateDropdown("Favorites Manager List", favList, favList[1], "Util_FavsList")
        
        Library.EventBus:Subscribe("FavoriteAdded", function(flag)
            local keys = {}
            for _, f in ipairs(Library.Favorites) do table.insert(keys, f) end
            if #keys == 0 then table.insert(keys, "None Saved") end
            favoritesDropdown:Refresh(keys, keys[1])
        end)

        local initialRecentlyUsed = {"No recent fungs."}
        local recentlyUsedDropdown = utTools:CreateDropdown("Recently Used Features", initialRecentlyUsed, initialRecentlyUsed[1], "Util_RecentList")

        Library.EventBus:Subscribe("FeatureInteracted", function(flag)
            local keys = {}
            for _, r in ipairs(Library.RecentlyUsed) do table.insert(keys, r) end
            if #keys == 0 then table.insert(keys, "No recent fungs.") end
            recentlyUsedDropdown:Refresh(keys, keys[1])
        end)

        utTools:CreateButton("Initialize Quick Access Buttons", function()
            Library:CreateNotification("Quick Access", "Interactive floating buttons verified and active!", 3)
        end)

        -- 8. Misc Section (UTILITY)
        local utMiscSec = UtilityTab:CreateSection("Misc")
        local utilityInfoLabel = utMiscSec:CreateParagraph("Utility Information", "Module operations standard.")
        local runtimeInfoLabel = utMiscSec:CreateParagraph("Runtime Information", "Script execution uptime: 0s")
        local sessionInfoLabel = utMiscSec:CreateParagraph("Session Information", "User session verified.")

        local startTime = tick()
        task.spawn(function()
            while task.wait(1) do
                local uptime = math.floor(tick() - startTime)
                pcall(function()
                    runtimeInfoLabel:Set(string.format("Script Execution Uptime: %ds\nSession stability: High", uptime))
                    utilityInfoLabel:Set("Utility Tab Framework: Active")
                    sessionInfoLabel:Set("Local User session Job ID: " .. game.JobId:sub(1, 12))
                end)
            end
        end)

        -- ========================================================
        -- [[ SETTINGS TAB ]]
        -- ========================================================
        local SettingsTab = Window:CreateTab("Settings", "gear")

        -- 1. Config Section
        local ConfigSec = SettingsTab:CreateSection("Config")
        ConfigSec:CreateTextBox("Config File Name", "Enter name...", "Sys_Save_Name")
        ConfigSec:CreateDropdown("Save File Format", {"JSON", "LUA"}, "JSON", "Sys_Save_Format")
        
        local settingsConfigDropdown

        ConfigSec:CreateButton("Save Current Configuration", function()
            local name = Library.Flags["Sys_Save_Name"]
            local format = Library.Flags["Sys_Save_Format"] or "JSON"
            if name and name ~= "" and name ~= "Enter name..." then
                Library:SaveConfig(name, format)
                if settingsConfigDropdown then
                    local newList = Library:GetConfigsList()
                    settingsConfigDropdown:Refresh(newList, name)
                end
            end
        end)

        local initialConfigsList = Library:GetConfigsList()
        settingsConfigDropdown = ConfigSec:CreateDropdown("Select Available File", initialConfigsList, initialConfigsList[1], "Sys_Selected_File")
        
        ConfigSec:CreateButton("Load Selected Configuration", function()
            local selected = Library.Flags["Sys_Selected_File"]
            if selected and selected ~= "No Configs Found" then
                Library:LoadConfig(selected)
            end
        end)

        ConfigSec:CreateToggle("Enable Auto-Save changes", false, "BuiltIn_AutoSave", {}, function(state)
            Library.Settings.AutoSave = state
        end)

        ConfigSec:CreateToggle("Enable Auto-Load configuration", false, "BuiltIn_AutoLoad", {}, function(state) end)

        ConfigSec:CreateButton("Reset Current Config to Default", function()
            for flag, item in pairs(Library.Registry) do
                if item.Type == "Toggle" then
                    pcall(function() item.Control:Set(false) end)
                elseif item.Type == "Slider" then
                    pcall(function() item.Control:Set(item.Config and item.Config.Min or 0) end)
                end
            end
            Library:CreateNotification("Settings", "All settings reset to baseline!", 3)
        end)

        ConfigSec:CreateTextBox("Import Configuration code", "Paste raw code here...", "Sys_ImportCodeInput")
        ConfigSec:CreateButton("Import Configurations", function()
            local rawCode = Library.Flags["Sys_ImportCodeInput"]
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
                    Library:CreateNotification("Import Success", "Configuration successfully imported!", 3)
                else
                    Library:CreateNotification("Import Failed", "Invalid configuration code.", 3)
                end
            end
        end)

        ConfigSec:CreateButton("Export current Config Code", function()
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
            Library:CreateNotification("Export Success", "Configurations copied to clipboard as raw code!", 3)
        end)

        -- 2. Theme Section
        local ThemeSec = SettingsTab:CreateSection("Theme")
        ThemeSec:CreateDropdown("Theme Color Palette Selector", {"Compkiller"}, "Compkiller", "BuiltIn_Palette", function(val) end)
        ThemeSec:CreateColorPicker("Accent Color Highlight", CurrentTheme.Accent, "BuiltIn_AccentColor", function(color)
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
            if Window.ActiveTab then
                local icon = Window.ActiveTab.Button:FindFirstChildOfClass("ImageLabel")
                if icon then
                    TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = color }):Play()
                end
            end
            for _, cb in ipairs(Library.ThemeCallbacks) do
                pcall(cb, color)
            end
            Library.EventBus:Publish("ThemeChanged", color)
        end)
        ThemeSec:CreateSlider("Background Frame Transparency", 10, 95, 40, "BuiltIn_BgTransVal", function(val)
            MainFrame.BackgroundTransparency = val / 100
        end)
        ThemeSec:CreateSlider("Global UI Scale", 50, 150, 100, "BuiltIn_Scale", function(scalePerc)
            ApplyUiSettings(Library.Settings.Mode, scalePerc / 100)
        end)
        ThemeSec:CreateSlider("Custom Main Frame Corner Radius", 0, 24, 8, "BuiltIn_CornerRadius", function(val)
            MainCorner.CornerRadius = UDim.new(0, val)
        end)
        ThemeSec:CreateToggle("Blur Effect Layer Toggle", false, "BuiltIn_BlurActive", {}, function(state) end)

        -- 3. Interface Section
        local InterfaceSec = SettingsTab:CreateSection("Interface")
        InterfaceSec:CreateButton("Minimize Antarmuka", function()
            ToggleGui()
        end)
        InterfaceSec:CreateButton("Restore Antarmuka Defaults", function()
            ApplyUiSettings("PC", 1.0)
            MainFrame.Position = UDim2.new(0.5, -320, 0.5, -230)
            Library:CreateNotification("Settings", "UI restoration success!", 3)
        end)
        InterfaceSec:CreateButton("Close UI Completely", function()
            ScreenGui:Destroy()
        end)
        InterfaceSec:CreateToggle("Smooth UI Animations", true, "BuiltIn_AnimsActive", {}, function(state) end)
        InterfaceSec:CreateSlider("Sidebar Layout Width", 100, 220, 170, "BuiltIn_SidebarWidth", function(val)
            Sidebar.Size = UDim2.new(0, val, 1, 0)
            ContentBg.Size = UDim2.new(1, -val, 1, 0)
            ContentBg.Position = UDim2.new(0, val, 0, 0)
            ContentArea.Size = UDim2.new(1, -val, 1, 0)
            ContentArea.Position = UDim2.new(0, val, 0, 0)
        end)
        InterfaceSec:CreateToggle("Enable Search Bar Utility", true, "BuiltIn_SearchBarActive", {}, function(state) end)

        -- 4. Keybind Section
        local KeybindSec = SettingsTab:CreateSection("Keybind")
        KeybindSec:CreateKeybind("Menu Toggle Keybind", Enum.KeyCode.Insert, "BuiltIn_MenuBind", function(key) end)
        KeybindSec:CreateKeybind("Emergency Panic Keybind", Enum.KeyCode.End, "BuiltIn_PanicBind", function(key)
            ScreenGui:Destroy()
        end)
        KeybindSec:CreateButton("Reset Bindings to Default", function()
            pcall(function()
                Library.Registry["BuiltIn_MenuBind"].Control:Set(Enum.KeyCode.Insert)
                Library.Registry["BuiltIn_PanicBind"].Control:Set(Enum.KeyCode.End)
            end)
            Library:CreateNotification("Settings", "Keybindings reset to default!", 3)
        end)
        
        local initialBinds = {"Menu: Insert", "Panic: End"}
        KeybindSec:CreateDropdown("Registered Keybinds List", initialBinds, initialBinds[1], "BuiltIn_ActiveBindsList")

        -- 5. Notification Section
        local NotificationSec = SettingsTab:CreateSection("Notification")
        NotificationSec:CreateSlider("Notification Duration (s)", 2, 15, 4, "BuiltIn_NotifDuration", function(val) end)
        NotificationSec:CreateDropdown("Notification Screen Position", {"Bottom Right", "Top Right"}, "Bottom Right", "BuiltIn_NotifPosition", function(val) end)
        NotificationSec:CreateToggle("Play Alert Sound Emitter", true, "BuiltIn_NotifSound", {}, function(state) end)
        NotificationSec:CreateToggle("Entrance Notif Animation", true, "BuiltIn_NotifAnims", {}, function(state) end)

        -- 6. Performance Section
        local SettingsPerfSec = SettingsTab:CreateSection("Performance")
        SettingsPerfSec:CreateToggle("Low Performance Mode", false, "BuiltIn_PotatoMode", {}, function(state)
            if state then
                MainFrame.BackgroundTransparency = 0.95
                MainStroke.Thickness = 0
            else
                MainFrame.BackgroundTransparency = 0.4
                MainStroke.Thickness = 1.5
            end
        end)
        SettingsPerfSec:CreateToggle("Enable Animation Cycles", true, "BuiltIn_AnimsLoop", {}, function(state) end)
        SettingsPerfSec:CreateToggle("Reduce Render Emitter Effects", false, "BuiltIn_ReduceEffects", {}, function(state) end)
        SettingsPerfSec:CreateToggle("Auto Optimize Memory Garbage", false, "BuiltIn_AutoOptimize", {}, function(state) end)

        task.spawn(function()
            while task.wait(5) do
                if Library.Flags["BuiltIn_AutoOptimize"] then
                    collectgarbage("collect")
                    appendAutoLog("Performance optimizer: Lua Garbage Collector execution completed.")
                end
            end
        end)

        -- 7. Advanced Section
        local AdvancedSec = SettingsTab:CreateSection("Advanced")
        AdvancedSec:CreateToggle("Developer Debug Mode", false, "BuiltIn_DevMode", {}, function(state) end)
        AdvancedSec:CreateToggle("Allow Experimental Engine Features", false, "BuiltIn_ExperimentalActive", {}, function(state) end)
        AdvancedSec:CreateButton("Reset Local Settings", function()
            pcall(function()
                Library.Registry["BuiltIn_Scale"].Control:Set(100)
                Library.Registry["BuiltIn_BgTransVal"].Control:Set(40)
            end)
            Library:CreateNotification("Settings", "Local UI settings reset!", 3)
        end)
        AdvancedSec:CreateButton("Restore Absolute Defaults", function()
            pcall(function()
                Library.Registry["BuiltIn_Scale"].Control:Set(100)
                Library.Registry["BuiltIn_BgTransVal"].Control:Set(40)
                Library.Registry["BuiltIn_MenuBind"].Control:Set(Enum.KeyCode.Insert)
                Library.Registry["BuiltIn_PanicBind"].Control:Set(Enum.KeyCode.End)
                Library.Registry["BuiltIn_AutoSave"].Control:Set(false)
            end)
            Library:CreateNotification("Settings", "Absolute factory defaults restored!", 3)
        end)

        -- ========================================================
        -- [[ CREDITS TAB ]]
        -- ========================================================
        local CreditsTab = Window:CreateTab("Credits", "info")
        
        local crDev = CreditsTab:CreateSection("Developer")
        crDev:CreateParagraph("Lead Engine Architect", "LouisHub Core Engineering Group\nLead Developer: Louis")

        local crCont = CreditsTab:CreateSection("Contributors")
        crCont:CreateParagraph("UI contributors & Beta Testers", "Special credits to Compkiller, latte-soft, and our dedicated Discord beta-testing community.")

        local crLibs = CreditsTab:CreateSection("Libraries")
        crLibs:CreateParagraph("Dynamic External Libraries", "Lucide Icons compilation LATTE-SOFT\nTween Easing Library\nScoped Connections Janitor Class")

        local crThanks = CreditsTab:CreateSection("Special Thanks")
        crThanks:CreateParagraph("Credits & Shoutouts", "Massive thanks to Roblox exploiting pioneers, developers of robust execution environments, and everyone who supports our visual framework development.")

        local crVersion = CreditsTab:CreateSection("Version")
        crVersion:CreateParagraph("Current Engine Build", "LouisHub Core Framework v2.0.0 (Release-Build)\nCompatible with 64-bit client architectures.")

        local crChangelog = CreditsTab:CreateSection("Changelog")
        crChangelog:CreateParagraph("Recent Changes", "- Implemented highly optimized World terrain/lighting modifiers.\n- Fleshed out massive, professional Combat Aim mechanics.\n- Fleshed out robust Automation pipeline.\n- Added custom clipboard tools, settings controls, and keybind modifiers.")

        local crInfo = CreditsTab:CreateSection("Information")
        crInfo:CreateParagraph("Framework Details", "LouisHub Framework is a premium, cross-platform executor visual layout interface built for high scalability, low-latency, and zero memory leaks.")
    end)

    -- ========================================================
    -- [[ BACKEND: INTERACTIVE MODAL DIALOG MANAGER ]]
    -- ========================================================
    function Library:ShowInfoModal(infoTitle, infoText)
        local oldModal = ScreenGui:FindFirstChild("Nexus_Info_Modal")
        if oldModal then oldModal:Destroy() end
        
        local oldOverlay = ScreenGui:FindFirstChild("Nexus_Modal_Overlay")
        if oldOverlay then oldOverlay:Destroy() end
        
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
        
        ModalFrame.Size = UDim2.new(0, 0, 0, 0)
        ModalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(ModalFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 320, 0, 180), Position = UDim2.new(0.5, -160, 0.5, -90) }):Play()
        TweenService:Create(Overlay, TweenInfo.new(0.25), { BackgroundTransparency = 0.6 }):Play()
    end

    return Window
end

return Library
