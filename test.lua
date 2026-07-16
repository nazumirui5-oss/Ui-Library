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

local isFolderSupported = makefolder and isfolder
if isFolderSupported and not isfolder("Compkiller_Configs") then
    makefolder("Compkiller_Configs")
end

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
        if not isfolder("Compkiller_Configs") then pcall(makefolder, "Compkiller_Configs") end
        if not isfolder("Compkiller_Configs/.icons") then pcall(makefolder, "Compkiller_Configs/.icons") end
        local fileName = iconName .. ".png"
        local localPath = "Compkiller_Configs/.icons/" .. fileName
        if isfile(localPath) then
            return getcustomasset(localPath)
        else
            local url = "https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/icons/compiled/256px/" .. fileName
            local success, content = pcall(function()
                return game:HttpGet(url)
            end)
            if success and content and #content > 0 then
                pcall(writefile, localPath, content)
                return getcustomasset(localPath)
            end
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
        ["info"] = "rbxassetid://10723415903"
    }
    return Fallbacks[iconName] or "rbxassetid://10723375133"
end

-- ========================================================
-- [[ THEME CONFIGURATION ]]
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
        TextSecondary = Color3.fromRGB(100, 170, 195),
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

-- Smooth transition for accent color changes
function Library:SetAccentColor(newColor)
    CurrentTheme.Accent = newColor
    for _, registryItem in ipairs(Library.ThemeRegistry) do
        if registryItem.Properties then
            for prop, key in pairs(registryItem.Properties) do
                if key == "Accent" then
                    TweenService:Create(registryItem.Instance, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = newColor}):Play()
                end
            end
        end
    end
end

local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber(hex:sub(1,2), 16)
        local g = tonumber(hex:sub(3,4), 16)
        local b = tonumber(hex:sub(5,6), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
    end
    return nil
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
            item.Instance.TextSize = math.round(item.BaseSize * multiplier)
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
-- [[ REUSABLE SECTION CREATOR ]]
-- ========================================================
local function CreateSectionInternal(sectionName, leftCol, rightCol, leftList, rightList)
    local Section = {}
    local targetColumn = leftCol
    if leftList.AbsoluteContentSize.Y > rightList.AbsoluteContentSize.Y then
        targetColumn = rightCol
    end

    local SecFrame = Instance.new("Frame", targetColumn)
    SecFrame.Size = UDim2.new(1, 0, 0, 40)
    SecFrame.AutomaticSize = Enum.AutomaticSize.Y
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
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.new(0, 0, 0, 34)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1

    local ContentList = Instance.new("UIListLayout", Content)
    ContentList.Padding = UDim.new(0, 10)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder

    local InsidePadding = Instance.new("UIPadding", Content)
    InsidePadding.PaddingLeft = UDim.new(0, 12)
    InsidePadding.PaddingRight = UDim.new(0, 12)
    InsidePadding.PaddingBottom = UDim.new(0, 12)

    -- Elements
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
                local InfoIcon = Instance.new("ImageLabel", InlineList)
                InfoIcon.Size = UDim2.new(0, 14, 0, 14)
                InfoIcon.BackgroundTransparency = 1
                InfoIcon.Image = GetIcon("info")
                RegisterTheme(InfoIcon, { ImageColor3 = "TextDark" })
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
                InlineBind.TextAlignment = Enum.TextAlignment.Center
                RegisterTheme(InlineBind, { TextColor3 = "TextSecondary", BackgroundColor3 = "SidebarBg" })
                RegisterFont(InlineBind, true)
                RegisterText(InlineBind, 9)
                
                local Border = Instance.new("UIStroke", InlineBind)
                Border.Thickness = 1
                RegisterTheme(Border, { Color = "StrokeColor" })
                
                local Corner = Instance.new("UICorner", InlineBind)
                Corner.CornerRadius = UDim.new(0, 3)
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
            if callback then task.spawn(callback, state) end
        end

        Switch.MouseButton1Click:Connect(function() SetState(not Toggle.State) end)
        SetState(Toggle.State)

        local ctrl = {}
        function ctrl:Set(val) SetState(val) end
        Library.Registry[flag] = { Type = "Toggle", Control = ctrl }
        return ctrl
    end

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

        local BindBtn = Instance.new("TextButton", Elem)
        BindBtn.Size = UDim2.new(0, 46, 0, 18)
        BindBtn.Position = UDim2.new(1, -46, 0.5, -9)
        BindBtn.Text = Keybind.Value.Name
        RegisterTheme(BindBtn, { BackgroundColor3 = "ElementBg", TextColor3 = "TextSecondary" })
        Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 3)
        RegisterFont(BindBtn, true)
        RegisterText(BindBtn, 9)

        local Stroke = Instance.new("UIStroke", BindBtn)
        Stroke.Thickness = 1
        RegisterTheme(Stroke, { Color = "StrokeColor" })

        local listening = false
        BindBtn.MouseButton1Click:Connect(function()
            listening = true
            BindBtn.Text = "..."
        end)

        UserInputService.InputBegan:Connect(function(input)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    Keybind.Value = input.KeyCode
                    Library.Flags[flag] = input.KeyCode
                    BindBtn.Text = input.KeyCode.Name
                    if callback then task.spawn(callback, input.KeyCode) end
                end
            end
        end)

        local ctrl = {}
        function ctrl:Set(val)
            if typeof(val) == "string" then val = Enum.KeyCode[val] end
            Keybind.Value = val
            Library.Flags[flag] = val
            BindBtn.Text = val.Name
        end
        Library.Registry[flag] = { Type = "Keybind", Control = ctrl }
        return ctrl
    end

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
            ApplyValue(math.floor(rawVal + 0.5))
        end

        local sliding = false
        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                UpdateSliderFromMouse(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSliderFromMouse(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)

        ValLabel.FocusLost:Connect(function()
            local num = tonumber(ValLabel.Text)
            ApplyValue(num or Slider.Value)
        end)

        local ctrl = {}
        function ctrl:Set(val) ApplyValue(val) end
        Library.Registry[flag] = { Type = "Slider", Control = ctrl }
        return ctrl
    end

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

                OptBtn.MouseButton1Click:Connect(function()
                    Dropdown.Value = opt
                    Library.Flags[flag] = opt
                    DisplayText.Text = tostring(opt)
                    ListFrame.Visible = false
                    Dropdown.Open = false
                    if callback then task.spawn(callback, opt) end
                end)
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
            DisplayText.Text = #Dropdown.Selected == 0 and "None Selected" or table.concat(Dropdown.Selected, ", ")
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

                OptBtn.MouseButton1Click:Connect(function()
                    local index = table.find(Dropdown.Selected, opt)
                    if index then table.remove(Dropdown.Selected, index) else table.insert(Dropdown.Selected, opt) end
                    Library.Flags[flag] = Dropdown.Selected
                    UpdateDisplayText()
                    PopulateOptions()
                    if callback then task.spawn(callback, Dropdown.Selected) end
                end)
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

    function Section:CreateColorPicker(pickerText, defaultColor, flag, callback)
        local Picker = { Value = defaultColor or Color3.fromRGB(0, 255, 120) }
        Library.Flags[flag] = Picker.Value

        local Elem = Instance.new("Frame", Content)
        Elem.Size = UDim2.new(1, 0, 0, 24)
        Elem.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", Elem)
        Label.Size = UDim2.new(1, -50, 1, 0)
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

        Preview.MouseButton1Click:Connect(function()
            local randomColor = Color3.fromHSV(math.random(), 1, 1)
            Picker.Value = randomColor
            Library.Flags[flag] = randomColor
            Preview.BackgroundColor3 = randomColor
            if callback then task.spawn(callback, randomColor) end
        end)

        local ctrl = {}
        function ctrl:Set(val)
            Picker.Value = val
            Preview.BackgroundColor3 = val
        end
        Library.Registry[flag] = { Type = "ColorPicker", Control = ctrl }
        return ctrl
    end

    function Section:CreateButton(btnText, callback)
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(1, 0, 0, 30)
        Btn.Text = btnText
        Btn.AutoButtonColor = false
        RegisterTheme(Btn, { BackgroundColor3 = "Accent", TextColor3 = "WindowBg" })
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        RegisterFont(Btn, true)
        RegisterText(Btn, 11)

        Btn.MouseButton1Click:Connect(function()
            if callback then task.spawn(callback) end
        end)
    end

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
        Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeParagraph)
        ResizeParagraph()
    end

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
        RegisterTheme(InputBox, { BackgroundColor3 = "ElementBg", TextColor3 = "TextPrimary" })
        Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)
        
        local Stroke = Instance.new("UIStroke", InputBox)
        Stroke.Thickness = 1
        RegisterTheme(Stroke, { Color = "StrokeColor" })
        
        RegisterFont(InputBox, false)
        RegisterText(InputBox, 11)

        InputBox.FocusLost:Connect(function()
            Library.Flags[flag] = InputBox.Text
            if callback then task.spawn(callback, InputBox.Text) end
        end)

        local ctrl = {}
        function ctrl:Set(val)
            InputBox.Text = tostring(val)
            Library.Flags[flag] = val
        end
        Library.Registry[flag] = { Type = "TextBox", Control = ctrl }
        return ctrl
    end

    return SecFrame, Content, LeftColumn, RightColumn, LeftList, RightList, Section
end

-- ========================================================
-- [[ NESTED SUB-TAB AND SECTION CREATION SYSTEM ]]
-- ========================================================
local function SetupTabStructure(TabPage, ColumnContainer, ParentTab)
    ColumnContainer.Size = UDim2.new(1, -20, 0, 0)
    ColumnContainer.Position = UDim2.new(0, 10, 0, 5)
    ColumnContainer.BackgroundTransparency = 1
    ColumnContainer.AutomaticSize = Enum.AutomaticSize.Y

    local LeftColumn = Instance.new("Frame", ColumnContainer)
    LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
    LeftColumn.Position = UDim2.new(0, 0, 0, 0)
    LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
    LeftColumn.BackgroundTransparency = 1

    local LeftList = Instance.new("UIListLayout", LeftColumn)
    LeftList.Padding = UDim.new(0, 12)
    LeftList.SortOrder = Enum.SortOrder.LayoutOrder

    local RightColumn = Instance.new("Frame", ColumnContainer)
    RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
    RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
    RightColumn.AutomaticSize = Enum.AutomaticSize.Y
    RightColumn.BackgroundTransparency = 1

    local RightList = Instance.new("UIListLayout", RightColumn)
    RightList.Padding = UDim.new(0, 12)
    RightList.SortOrder = Enum.SortOrder.LayoutOrder

    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

    ParentTab.SubTabsList = {}

    function ParentTab:CreateSection(sectionName)
        local _, _, _, _, _, _, Section = CreateSectionInternal(sectionName, LeftColumn, RightColumn, LeftList, RightList)
        return Section
    end

    function ParentTab:CreateSubTab(subTabName)
        if not ParentTab.SubTabsContainer then
            ParentTab.SubTabsContainer = Instance.new("Frame", TabPage)
            ParentTab.SubTabsContainer.Size = UDim2.new(1, -20, 0, 32)
            ParentTab.SubTabsContainer.Position = UDim2.new(0, 10, 0, 5)
            ParentTab.SubTabsContainer.BackgroundTransparency = 1

            local SubList = Instance.new("UIListLayout", ParentTab.SubTabsContainer)
            SubList.FillDirection = Enum.FillDirection.Horizontal
            SubList.Padding = UDim.new(0, 8)
            SubList.SortOrder = Enum.SortOrder.LayoutOrder

            ColumnContainer.Visible = false
        end

        local SubTab = { Active = false }

        local SubContainer = Instance.new("Frame", TabPage)
        SubContainer.Size = UDim2.new(1, -20, 0, 0)
        SubContainer.Position = UDim2.new(0, 10, 0, 42)
        SubContainer.BackgroundTransparency = 1
        SubContainer.AutomaticSize = Enum.AutomaticSize.Y
        SubContainer.Visible = false

        local S_LeftColumn = Instance.new("Frame", SubContainer)
        S_LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
        S_LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
        S_LeftColumn.BackgroundTransparency = 1

        local S_LeftList = Instance.new("UIListLayout", S_LeftColumn)
        S_LeftList.Padding = UDim.new(0, 12)
        S_LeftList.SortOrder = Enum.SortOrder.LayoutOrder

        local S_RightColumn = Instance.new("Frame", SubContainer)
        S_RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
        S_RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        S_RightColumn.AutomaticSize = Enum.AutomaticSize.Y
        S_RightColumn.BackgroundTransparency = 1

        local S_RightList = Instance.new("UIListLayout", S_RightColumn)
        S_RightList.Padding = UDim.new(0, 12)
        S_RightList.SortOrder = Enum.SortOrder.LayoutOrder

        local SubBtn = Instance.new("TextButton", ParentTab.SubTabsContainer)
        SubBtn.BackgroundTransparency = 0
        RegisterTheme(SubBtn, { BackgroundColor3 = "ElementBg", TextColor3 = "TextSecondary" })
        SubBtn.Text = subTabName
        SubBtn.AutoButtonColor = false
        RegisterFont(SubBtn, true)
        RegisterText(SubBtn, 11)

        local SubBtnCorner = Instance.new("UICorner", SubBtn)
        SubBtnCorner.CornerRadius = UDim.new(0, 4)

        local SubBtnStroke = Instance.new("UIStroke", SubBtn)
        SubBtnStroke.Thickness = 1
        RegisterTheme(SubBtnStroke, { Color = "StrokeColor" })

        local textWidth = TextService:GetTextSize(subTabName, 11, Library.Settings.Font, Vector2.new(1000, 1000)).X
        SubBtn.Size = UDim2.new(0, textWidth + 24, 1, 0)

        SubTab.Button = SubBtn
        SubTab.Container = SubContainer

        local function SelectSubTab()
            for _, sub in ipairs(ParentTab.SubTabsList) do
                if sub == SubTab then
                    sub.Container.Visible = true
                    TweenService:Create(sub.Button, TweenInfo.new(0.15), {BackgroundColor3 = CurrentTheme.Accent}):Play()
                    TweenService:Create(sub.Button, TweenInfo.new(0.15), {TextColor3 = CurrentTheme.WindowBg}):Play()
                else
                    sub.Container.Visible = false
                    TweenService:Create(sub.Button, TweenInfo.new(0.15), {BackgroundColor3 = CurrentTheme.ElementBg}):Play()
                    TweenService:Create(sub.Button, TweenInfo.new(0.15), {TextColor3 = CurrentTheme.TextSecondary}):Play()
                end
            end
        end

        SubBtn.MouseButton1Click:Connect(SelectSubTab)

        function SubTab:CreateSection(sectionName)
            local _, _, _, _, _, _, Section = CreateSectionInternal(sectionName, S_LeftColumn, S_RightColumn, S_LeftList, S_RightList)
            return Section
        end

        table.insert(ParentTab.SubTabsList, SubTab)
        if #ParentTab.SubTabsList == 1 then
            task.spawn(function()
                task.wait(0.05)
                SelectSubTab()
            end)
        end

        return SubTab
    end
end

-- ========================================================
-- [[ MAIN WINDOW EXTENSION ]]
-- ========================================================
function Library:CreateWindow(titleText, subtitleText, customConfig)
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        CategoryCount = 0
    }

    local config = customConfig or {}
    Library.Settings = {
        Mode = config.Mode or "PC",
        Scale = config.Scale or 1.0,
        Font = config.Font or Enum.Font.GothamMedium,
        BoldFont = config.BoldFont or Enum.Font.GothamBold,
        TextSizeMultiplier = config.TextSizeMultiplier or 1.0
    }

    local cleanTitle = string.gsub(titleText or "Universal", "[%s%p]", "_")
    local ConfigFolder = "Compkiller_Configs/" .. cleanTitle
    if isFolderSupported and not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Nexus_Compkiller_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local successHui, hui = pcall(function() return gethui and gethui() end)
    ScreenGui.Parent = (successHui and hui) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundTransparency = 1
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.5
    RegisterTheme(MainStroke, { Color = "StrokeColor" })

    local UiScale = Instance.new("UIScale", MainFrame)
    UiScale.Scale = Library.Settings.Scale

    local function ApplyUiSettings(mode, scale)
        Library.Settings.Mode = mode
        Library.Settings.Scale = scale
        UiScale.Scale = scale
        
        if mode == "PC" then
            MainFrame.Size = UDim2.new(0, 640, 0, 460)
            MainFrame.Position = UDim2.new(0.5, -320, 0.5, -230)
        elseif mode == "Mobile" then
            MainFrame.Size = UDim2.new(0, 500, 0, 340)
            MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
        end
    end
    ApplyUiSettings(Library.Settings.Mode, Library.Settings.Scale)

    -- Sidebar
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

    -- Content Background
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

    -- Drag Handle Logo
    local LogoArea = Instance.new("Frame", Sidebar)
    LogoArea.Size = UDim2.new(1, 0, 0, 50)
    LogoArea.BackgroundTransparency = 1
    MakeDraggable(LogoArea, MainFrame)

    local LogoIcon = Instance.new("ImageLabel", LogoArea)
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.Position = UDim2.new(0, 15, 0.5, -12)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = "rbxassetid://10723375133"
    RegisterTheme(LogoIcon, { ImageColor3 = "Accent" })

    local TitleLabel = Instance.new("TextLabel", LogoArea)
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 46, 0, 0)
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

    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
    end)

    -- Bottom User Profile Card
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
    -- [[ NOTIFICATION SYSTEM ]]
    -- ========================================================
    function Library:Notify(title, text, duration)
        duration = duration or 5
        if not ScreenGui:FindFirstChild("NotificationArea") then
            local NotifArea = Instance.new("Frame", ScreenGui)
            NotifArea.Name = "NotificationArea"
            NotifArea.Size = UDim2.new(0, 260, 1, -20)
            NotifArea.Position = UDim2.new(1, -280, 0, 10)
            NotifArea.BackgroundTransparency = 1
            
            local NotifLayout = Instance.new("UIListLayout", NotifArea)
            NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            NotifLayout.Padding = UDim.new(0, 10)
            NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
        end
        
        local NotifArea = ScreenGui.NotificationArea
        local NotifFrame = Instance.new("Frame", NotifArea)
        NotifFrame.Size = UDim2.new(1, 0, 0, 0)
        NotifFrame.AutomaticSize = Enum.AutomaticSize.Y
        RegisterTheme(NotifFrame, { BackgroundColor3 = "SectionBg" })
        
        local Corner = Instance.new("UICorner", NotifFrame)
        Corner.CornerRadius = UDim.new(0, 6)
        
        local Stroke = Instance.new("UIStroke", NotifFrame)
        Stroke.Thickness = 1
        RegisterTheme(Stroke, { Color = "StrokeColor" })
        
        local Title = Instance.new("TextLabel", NotifFrame)
        Title.Size = UDim2.new(1, -20, 0, 20)
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.BackgroundTransparency = 1
        Title.Text = title
        RegisterTheme(Title, { TextColor3 = "Accent" })
        RegisterFont(Title, true)
        RegisterText(Title, 11)
        
        local ContentText = Instance.new("TextLabel", NotifFrame)
        ContentText.Size = UDim2.new(1, -20, 0, 0)
        ContentText.Position = UDim2.new(0, 10, 0, 25)
        ContentText.BackgroundTransparency = 1
        ContentText.Text = text
        ContentText.TextWrapped = true
        RegisterTheme(ContentText, { TextColor3 = "TextPrimary" })
        RegisterFont(ContentText, false)
        RegisterText(ContentText, 10)
        
        local constraintSize = Vector2.new(240, 1000)
        local textBounds = TextService:GetTextSize(text, 10, Library.Settings.Font, constraintSize)
        ContentText.Size = UDim2.new(1, -20, 0, textBounds.Y + 5)
        
        local UIPadding = Instance.new("UIPadding", NotifFrame)
        UIPadding.PaddingBottom = UDim.new(0, 10)
        
        NotifFrame.BackgroundTransparency = 1
        Title.TextTransparency = 1
        ContentText.TextTransparency = 1
        Stroke.Transparency = 1
        
        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
        TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(ContentText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
        
        task.delay(duration, function()
            local fadeOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
            TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(ContentText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            fadeOut:Play()
            fadeOut.Completed:Connect(function() NotifFrame:Destroy() end)
        end)
    end

    -- ========================================================
    -- [[ CATEGORY HEADER & TAB CREATION OVERRIDES ]]
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

    function Window:CreateTab(tabName, iconInput)
        local Tab = { Sections = {}, Button = nil, Frame = nil }

        local TabPage = Instance.new("ScrollingFrame", ContentArea)
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 0
        TabPage.Visible = false

        local ColumnContainer = Instance.new("Frame", TabPage)
        SetupTabStructure(TabPage, ColumnContainer, Tab)

        local TabBtn = Instance.new("TextButton", TabScroll)
        TabBtn.Size = UDim2.new(1, -10, 0, 32)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
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
        RegisterTheme(TabIcon, { ImageColor3 = "TextSecondary" })

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

        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                TweenService:Create(TabLabel, TweenInfo.new(0.15), {TextColor3 = CurrentTheme.TextPrimary}):Play()
                TweenService:Create(TabIcon, TweenInfo.new(0.15), {ImageColor3 = CurrentTheme.TextPrimary}):Play()
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                TweenService:Create(TabLabel, TweenInfo.new(0.15), {TextColor3 = CurrentTheme.TextSecondary}):Play()
                TweenService:Create(TabIcon, TweenInfo.new(0.15), {ImageColor3 = CurrentTheme.TextSecondary}):Play()
            end
        end)

        if #Window.Tabs == 1 then
            task.spawn(function() task.wait(0.1) SelectTab() end)
        end
        table.insert(Window.Tabs, Tab)
        return Tab
    end

    -- ========================================================
    -- [[ AUTOMATIC CORE UI TAB WITH SETTINGS & CONFIG SUB-TABS ]]
    -- ========================================================
    task.spawn(function()
        task.wait(0.05)

        local function serializeTable(val)
            if typeof(val) == "string" then return string.format("%q", val)
            elseif typeof(val) == "number" or typeof(val) == "boolean" then return tostring(val)
            elseif typeof(val) == "table" then
                local str = "{\n"
                for k, v in pairs(val) do
                    str = str .. string.format("  [%s] = %s,\n", serializeTable(k), serializeTable(v))
                end
                return str .. "}"
            end
            return "nil"
        end

        local function LoadLuaConfig(path)
            local content = readfile(path)
            local func = loadstring(content)
            if func then
                local success, tbl = pcall(func)
                if success and typeof(tbl) == "table" then return tbl end
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
                        dataToSave[flag] = {math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255)}
                    elseif typeof(value) == "EnumItem" then
                        dataToSave[flag] = tostring(value)
                    else
                        dataToSave[flag] = value
                    end
                end
            end
            local path = ConfigFolder .. "/" .. configName
            if format == "LUA" then
                writefile(path .. ".lua", "return " .. serializeTable(dataToSave))
            else
                writefile(path .. ".json", HttpService:JSONEncode(dataToSave))
            end
        end

        local function LoadConfig(configName)
            if not isFolderSupported then return end
            local luaPath = ConfigFolder .. "/" .. configName .. ".lua"
            local jsonPath = ConfigFolder .. "/" .. configName .. ".json"
            local loadedData = nil
            if isfile(luaPath) then loadedData = LoadLuaConfig(luaPath)
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
                                Library.Registry[flag].Control:Set(Color3.fromRGB(value[1], value[2], value[3]))
                            else
                                Library.Registry[flag].Control:Set(value)
                            end
                        end)
                    end
                end
            end
        end

        local function DeleteConfig(configName)
            if not isFolderSupported then return end
            local luaPath = ConfigFolder .. "/" .. configName .. ".lua"
            local jsonPath = ConfigFolder .. "/" .. configName .. ".json"
            if isfile(luaPath) then delfile(luaPath) end
            if isfile(jsonPath) then delfile(jsonPath) end
        end

        local function GetConfigsList()
            local list = {}
            if listfiles and isfolder and isfolder(ConfigFolder) then
                for _, file in ipairs(listfiles(ConfigFolder)) do
                    local name = string.match(file, "([^/]+)%.[jJ][sS][oO][nN]$") or string.match(file, "([^/]+)%.[lL][uU][aA]$")
                    if name and not table.find(list, name) then table.insert(list, name) end
                end
            end
            if #list == 0 then table.insert(list, "No Configs Found") end
            return list
        end

        -- Create automatic "UI" tab
        Window:CreateCategory("UI Management")
        local CoreUITab = Window:CreateTab("UI", "sliders")

        -- Sub-Tab 1: Settings
        local SettingsSub = CoreUITab:CreateSubTab("Settings")
        local PrefsSec = SettingsSub:CreateSection("Appearance")
        
        PrefsSec:CreateDropdown("Layout Mode", {"PC", "Mobile"}, Library.Settings.Mode, "BuiltIn_Mode", function(mode)
            ApplyUiSettings(mode, Library.Settings.Scale)
        end)
        
        PrefsSec:CreateSlider("UI Scale", 50, 150, math.floor(Library.Settings.Scale * 100), "BuiltIn_Scale", function(scalePerc)
            ApplyUiSettings(Library.Settings.Mode, scalePerc / 100)
        end)
        
        PrefsSec:CreateSlider("Text Size", 80, 150, math.floor(Library.Settings.TextSizeMultiplier * 100), "BuiltIn_Text", function(sizePerc)
            UpdateTextSizes(sizePerc / 100)
        end)

        local AccentSec = SettingsSub:CreateSection("Custom Colors")
        AccentSec:CreateColorPicker("Accent Color", CurrentTheme.Accent, "BuiltIn_AccentColor", function(color)
            Library:SetAccentColor(color)
        end)
        
        AccentSec:CreateTextBox("Accent Hex Code", "#00d5ef", "BuiltIn_HexCode", function(text)
            local parsed = HexToColor3(text)
            if parsed then
                Library:SetAccentColor(parsed)
            end
        end)

        -- Sub-Tab 2: Config
        local ConfigSub = CoreUITab:CreateSubTab("Config")
        local SaveSec = ConfigSub:CreateSection("Save Configuration")
        SaveSec:CreateTextBox("Config Name", "Enter name...", "Sys_Save_Name")
        SaveSec:CreateDropdown("Save Format", {"JSON", "LUA"}, "JSON", "Sys_Save_Format")
        
        local configDropdown
        SaveSec:CreateButton("Save Configuration", function()
            local name = Library.Flags["Sys_Save_Name"]
            local format = Library.Flags["Sys_Save_Format"] or "JSON"
            if name and name ~= "" and name ~= "Enter name..." then
                SaveConfig(name, format)
                if configDropdown then
                    configDropdown:Refresh(GetConfigsList(), name)
                end
            end
        end)

        local ManageSec = ConfigSub:CreateSection("File Manager")
        local initialList = GetConfigsList()
        configDropdown = ManageSec:CreateDropdown("Select File", initialList, initialList[1], "Sys_Selected_File")
        
        ManageSec:CreateButton("Load Selected Config", function()
            local selected = Library.Flags["Sys_Selected_File"]
            if selected and selected ~= "No Configs Found" then LoadConfig(selected) end
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

        -- Welcome Notification triggering
        Library:Notify("Welcome!", "To adjust UI size, hex colors or configs, navigate to the 'UI' tab at the bottom.", 8)
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
    FloatingToggle.Visible = false
    FloatingToggle.ClipsDescendants = true
    RegisterTheme(FloatingToggle, { BackgroundColor3 = "SidebarBg" })

    local ToggleCorner = Instance.new("UICorner", FloatingToggle)
    ToggleCorner.CornerRadius = UDim.new(1, 0)

    local ToggleStroke = Instance.new("UIStroke", FloatingToggle)
    ToggleStroke.Thickness = 1.5
    RegisterTheme(ToggleStroke, { Color = "Accent" })

    local ToggleIconImage = Instance.new("ImageLabel", FloatingToggle)
    ToggleIconImage.Size = UDim2.new(0.65, 0, 0.65, 0)
    ToggleIconImage.Position = UDim2.new(0.175, 0, 0.175, 0)
    ToggleIconImage.BackgroundTransparency = 1
    ToggleIconImage.Image = "rbxassetid://10723375133"
    RegisterTheme(ToggleIconImage, { ImageColor3 = "Accent" })

    MakeDraggable(FloatingToggle, FloatingToggle)

    local function ToggleGui()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = MainFrame.Size, Position = MainFrame.Position}):Play()
            TweenService:Create(FloatingToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.delay(0.2, function() FloatingToggle.Visible = false end)
        else
            local shrink = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
            shrink:Play()
            shrink.Completed:Connect(function()
                if not Window.Visible then MainFrame.Visible = false end
            end)
            FloatingToggle.Visible = true
            TweenService:Create(FloatingToggle, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()
        end
    end

    FloatingToggle.MouseButton1Click:Connect(ToggleGui)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then ToggleGui() end
    end)
    
    function Window:Minimize()
        ToggleGui()
    end

    return Window
end

return Library
