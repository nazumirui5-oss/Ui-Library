local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextService = game:GetService("TextService")

Library.Flags = {}
Library.Elements = {}
Library.ThemeRegistry = {}

-- ========================================================
-- [[ SYSTEM THEME CONFIGURATION ]]
-- ========================================================
local Themes = {
    ["Compkiller"] = {
        WindowBg = Color3.fromRGB(18, 20, 24),
        SidebarBg = Color3.fromRGB(24, 27, 34),
        SectionBg = Color3.fromRGB(15, 17, 20),
        ElementBg = Color3.fromRGB(22, 25, 30),
        StrokeColor = Color3.fromRGB(35, 40, 48),
        Accent = Color3.fromRGB(0, 220, 255),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(140, 145, 155),
        TextDark = Color3.fromRGB(90, 95, 105)
    },
    ["Nordic Dark"] = {
        WindowBg = Color3.fromRGB(26, 30, 38),
        SidebarBg = Color3.fromRGB(33, 37, 47),
        SectionBg = Color3.fromRGB(22, 25, 32),
        ElementBg = Color3.fromRGB(30, 34, 44),
        StrokeColor = Color3.fromRGB(45, 52, 64),
        Accent = Color3.fromRGB(129, 161, 193),
        TextPrimary = Color3.fromRGB(236, 239, 244),
        TextSecondary = Color3.fromRGB(162, 169, 182),
        TextDark = Color3.fromRGB(108, 116, 130)
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

function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, entry in ipairs(Library.ThemeRegistry) do
            if entry.Instance and entry.Instance:IsDescendantOf(game) then
                for prop, key in pairs(entry.Properties) do
                    pcall(function()
                        entry.Instance[prop] = CurrentTheme[key]
                    end)
                end
            end
        end
    end
end

-- ========================================================
-- [[ DRAG HANDLING UTILITY ]]
-- ========================================================
local function MakeDraggable(dragTrigger, frameToMove)
    local dragging, dragInput, dragStart, startPos
    
    dragTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frameToMove.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragTrigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frameToMove.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ========================================================
-- [[ MAIN WINDOW CREATION ]]
-- ========================================================
function Library:CreateWindow(titleText, subtitleText)
    local Window = {
        Tabs = {},
        ActiveTab = nil
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Nexus_UI_Engine"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local successHui, hui = pcall(function() return gethui and gethui() end)
    ScreenGui.Parent = (successHui and hui) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 650, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -240)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    RegisterTheme(MainFrame, { BackgroundColor3 = "WindowBg" })

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1
    RegisterTheme(MainStroke, { Color = "StrokeColor" })

    -- Sidebar (Left)
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BorderSizePixel = 0
    RegisterTheme(Sidebar, { BackgroundColor3 = "SidebarBg" })

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 8)

    -- Prevent sidebar corners from clipping the main frame rounded edges on the right
    local SidebarMask = Instance.new("Frame", Sidebar)
    SidebarMask.Size = UDim2.new(0, 15, 1, 0)
    SidebarMask.Position = UDim2.new(1, -15, 0, 0)
    SidebarMask.BorderSizePixel = 0
    RegisterTheme(SidebarMask, { BackgroundColor3 = "SidebarBg" })

    -- Drag Handle (Logo Area)
    local LogoArea = Instance.new("Frame", Sidebar)
    LogoArea.Size = UDim2.new(1, 0, 0, 50)
    LogoArea.BackgroundTransparency = 1
    MakeDraggable(LogoArea, MainFrame)

    local LogoIcon = Instance.new("ImageLabel", LogoArea)
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.Position = UDim2.new(0, 15, 0.5, -12)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = "rbxassetid://10734887784"
    RegisterTheme(LogoIcon, { ImageColor3 = "Accent" })

    local TitleLabel = Instance.new("TextLabel", LogoArea)
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 45, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText or "COMPKILLER"
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(TitleLabel, { TextColor3 = "TextPrimary" })

    -- Tab Button Scroll Container
    local TabScroll = Instance.new("ScrollingFrame", Sidebar)
    TabScroll.Size = UDim2.new(1, -10, 1, -115)
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

    -- Profile Card (Bottom Left)
    local UserCard = Instance.new("Frame", Sidebar)
    UserCard.Size = UDim2.new(1, -20, 0, 50)
    UserCard.Position = UDim2.new(0, 10, 1, -60)
    UserCard.BackgroundTransparency = 1

    local AvatarImg = Instance.new("ImageLabel", UserCard)
    AvatarImg.Size = UDim2.new(0, 34, 0, 34)
    AvatarImg.Position = UDim2.new(0, 5, 0.5, -17)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

    local UsernameLabel = Instance.new("TextLabel", UserCard)
    UsernameLabel.Size = UDim2.new(1, -50, 0, 16)
    UsernameLabel.Position = UDim2.new(0, 45, 0.5, -15)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = LocalPlayer.DisplayName
    UsernameLabel.Font = Enum.Font.MontserratBold
    UsernameLabel.TextSize = 11
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(UsernameLabel, { TextColor3 = "TextPrimary" })

    local SubtextLabel = Instance.new("TextLabel", UserCard)
    SubtextLabel.Size = UDim2.new(1, -50, 0, 14)
    SubtextLabel.Position = UDim2.new(0, 45, 0.5, 1)
    SubtextLabel.BackgroundTransparency = 1
    SubtextLabel.Text = subtitleText or "NEVER"
    SubtextLabel.Font = Enum.Font.MontserratMedium
    SubtextLabel.TextSize = 9
    SubtextLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(SubtextLabel, { TextColor3 = "TextDark" })

    -- Content Container (Right Side)
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -170, 1, 0)
    ContentArea.Position = UDim2.new(0, 170, 0, 0)
    ContentArea.BackgroundTransparency = 1

    -- ========================================================
    -- [[ TAB CREATION METHOD ]]
    -- ========================================================
    function Window:CreateTab(tabName, iconAssetId)
        local Tab = {
            Sections = {},
            Button = nil,
            Frame = nil
        }

        local TabPage = Instance.new("ScrollingFrame", ContentArea)
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 2
        TabPage.Visible = false
        RegisterTheme(TabPage, { ScrollBarImageColor3 = "Accent" })

        local ColumnContainer = Instance.new("Frame", TabPage)
        ColumnContainer.Size = UDim2.new(1, -20, 1, 0)
        ColumnContainer.Position = UDim2.new(0, 10, 0, 10)
        ColumnContainer.BackgroundTransparency = 1

        local LeftColumn = Instance.new("Frame", ColumnContainer)
        LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
        LeftColumn.Position = UDim2.new(0, 0, 0, 0)
        LeftColumn.BackgroundTransparency = 1

        local LeftList = Instance.new("UIListLayout", LeftColumn)
        LeftList.Padding = UDim.new(0, 10)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder

        local RightColumn = Instance.new("Frame", ColumnContainer)
        RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        RightColumn.BackgroundTransparency = 1

        local RightList = Instance.new("UIListLayout", RightColumn)
        RightList.Padding = UDim.new(0, 10)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder

        local function ResizeCanvas()
            local leftHeight = LeftList.AbsoluteContentSize.Y
            local rightHeight = RightList.AbsoluteContentSize.Y
            local targetHeight = math.max(leftHeight, rightHeight) + 30
            TabPage.CanvasSize = UDim2.new(0, 0, 0, targetHeight)
            ColumnContainer.Size = UDim2.new(1, -20, 0, targetHeight)
        end

        LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeCanvas)
        RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeCanvas)

        local TabBtn = Instance.new("TextButton", TabScroll)
        TabBtn.Size = UDim2.new(1, -10, 0, 36)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false

        local TabBtnCorner = Instance.new("UICorner", TabBtn)
        TabBtnCorner.CornerRadius = UDim.new(0, 6)

        local TabBtnAccent = Instance.new("Frame", TabBtn)
        TabBtnAccent.Size = UDim2.new(0, 3, 0.6, 0)
        TabBtnAccent.Position = UDim2.new(0, 0, 0.2, 0)
        TabBtnAccent.BorderSizePixel = 0
        TabBtnAccent.BackgroundTransparency = 1
        RegisterTheme(TabBtnAccent, { BackgroundColor3 = "Accent" })

        local TabIcon = Instance.new("ImageLabel", TabBtn)
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, 12, 0.5, -8)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = iconAssetId or "rbxassetid://10734741641"
        RegisterTheme(TabIcon, { ImageColor3 = "TextSecondary" })

        local TabLabel = Instance.new("TextLabel", TabBtn)
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Position = UDim2.new(0, 35, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.Font = Enum.Font.MontserratMedium
        TabLabel.TextSize = 11
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        RegisterTheme(TabLabel, { TextColor3 = "TextSecondary" })

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

        if #Window.Tabs == 0 then
            task.spawn(function()
                task.wait(0.1)
                SelectTab()
            end)
        end

        table.insert(Window.Tabs, Tab)

        -- ========================================================
        -- [[ SECTION CREATION METHOD (Compkiller Cards) ]]
        -- ========================================================
        function Tab:CreateSection(sectionName)
            local Section = {}
            
            local targetColumn = LeftColumn
            if LeftList.AbsoluteContentSize.Y > RightList.AbsoluteContentSize.Y then
                targetColumn = RightColumn
            end

            local SecFrame = Instance.new("Frame", targetColumn)
            SecFrame.Size = UDim2.new(1, 0, 0, 40)
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
            Title.Font = Enum.Font.MontserratBold
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            RegisterTheme(Title, { TextColor3 = "TextPrimary" })

            local ToggleIcon = Instance.new("ImageLabel", Header)
            ToggleIcon.Size = UDim2.new(0, 14, 0, 14)
            ToggleIcon.Position = UDim2.new(1, -26, 0.5, -7)
            ToggleIcon.BackgroundTransparency = 1
            ToggleIcon.Image = "rbxassetid://10709790644"
            RegisterTheme(ToggleIcon, { ImageColor3 = "TextSecondary" })

            local Content = Instance.new("Frame", SecFrame)
            Content.Size = UDim2.new(1, 0, 1, -34)
            Content.Position = UDim2.new(0, 0, 0, 34)
            Content.BackgroundTransparency = 1

            local ContentList = Instance.new("UIListLayout", Content)
            ContentList.Padding = UDim.new(0, 6)
            ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder

            local function UpdateSectionSize()
                local contentHeight = ContentList.AbsoluteContentSize.Y
                SecFrame.Size = UDim2.new(1, 0, 0, contentHeight + 46)
            end

            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)

            local InsidePadding = Instance.new("UIPadding", Content)
            InsidePadding.PaddingLeft = UDim.new(0, 10)
            InsidePadding.PaddingRight = UDim.new(0, 10)
            InsidePadding.PaddingBottom = UDim.new(0, 10)

            -- ========================================================
            -- [[ SECTION ELEMENT: TOGGLE ]]
            -- ========================================================
            function Section:CreateToggle(toggleText, defaultVal, flag, callback)
                local Toggle = { State = defaultVal or false }
                Library.Flags[flag] = Toggle.State

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 30)
                RegisterTheme(Elem, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Elem).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -70, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleText
                Label.Font = Enum.Font.MontserratMedium
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                -- Switch Container
                local Switch = Instance.new("TextButton", Elem)
                Switch.Size = UDim2.new(0, 28, 0, 14)
                Switch.Position = UDim2.new(1, -38, 0.5, -7)
                Switch.Text = ""
                Switch.AutoButtonColor = false
                RegisterTheme(Switch, { BackgroundColor3 = "StrokeColor" })
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

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
                        TweenService:Create(Switch, TweenInfo.new(dur), {BackgroundColor3 = CurrentTheme.StrokeColor}):Play()
                    end
                    if callback then task.spawn(callback, state) end
                end

                Switch.MouseButton1Click:Connect(function()
                    SetState(not Toggle.State)
                end)

                SetState(Toggle.State)

                local ctrl = {}
                function ctrl:Set(val) SetState(val) end
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: KEYBIND ]]
            -- ========================================================
            function Section:CreateKeybind(bindText, defaultBind, flag, callback)
                local Keybind = { Value = defaultBind or Enum.KeyCode.E }
                Library.Flags[flag] = Keybind.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 30)
                RegisterTheme(Elem, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Elem).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = bindText
                Label.Font = Enum.Font.MontserratMedium
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                local BindBtn = Instance.new("TextButton", Elem)
                BindBtn.Size = UDim2.new(0, 50, 0, 18)
                BindBtn.Position = UDim2.new(1, -60, 0.5, -9)
                BindBtn.Font = Enum.Font.MontserratBold
                BindBtn.TextSize = 9
                BindBtn.Text = Keybind.Value.Name
                RegisterTheme(BindBtn, { BackgroundColor3 = "StrokeColor", TextColor3 = "TextPrimary" })
                Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 3)

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
                    Keybind.Value = val
                    Library.Flags[flag] = val
                    BindBtn.Text = val.Name
                end
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: SLIDER ]]
            -- ========================================================
            function Section:CreateSlider(sliderText, minVal, maxVal, defaultVal, flag, callback)
                local Slider = { Value = defaultVal or minVal }
                Library.Flags[flag] = Slider.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 42)
                RegisterTheme(Elem, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Elem).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -60, 0, 18)
                Label.Position = UDim2.new(0, 10, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Text = sliderText
                Label.Font = Enum.Font.MontserratMedium
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                local ValLabel = Instance.new("TextLabel", Elem)
                ValLabel.Size = UDim2.new(0, 40, 0, 18)
                ValLabel.Position = UDim2.new(1, -50, 0, 4)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(Slider.Value)
                ValLabel.Font = Enum.Font.MontserratBold
                ValLabel.TextSize = 10
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                RegisterTheme(ValLabel, { TextColor3 = "Accent" })

                local SliderBg = Instance.new("TextButton", Elem)
                SliderBg.Size = UDim2.new(1, -20, 0, 4)
                SliderBg.Position = UDim2.new(0, 10, 1, -10)
                SliderBg.Text = ""
                SliderBg.AutoButtonColor = false
                RegisterTheme(SliderBg, { BackgroundColor3 = "StrokeColor" })
                Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

                local SliderFill = Instance.new("Frame", SliderBg)
                SliderFill.Size = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 1, 0)
                SliderFill.BorderSizePixel = 0
                RegisterTheme(SliderFill, { BackgroundColor3 = "Accent" })
                Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

                local function UpdateSlider(input)
                    local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    local rawVal = minVal + (percentage * (maxVal - minVal))
                    local finalVal = math.floor(rawVal + 0.5)

                    Slider.Value = finalVal
                    Library.Flags[flag] = finalVal
                    ValLabel.Text = tostring(finalVal)
                    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    if callback then task.spawn(callback, finalVal) end
                end

                local sliding = false

                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                local ctrl = {}
                function ctrl:Set(val)
                    local clamped = math.clamp(val, minVal, maxVal)
                    Slider.Value = clamped
                    ValLabel.Text = tostring(clamped)
                    SliderFill.Size = UDim2.new((clamped - minVal) / (maxVal - minVal), 0, 1, 0)
                end
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: SINGLE DROPDOWN ]]
            -- ========================================================
            function Section:CreateDropdown(ddText, options, defaultVal, flag, callback)
                local Dropdown = { Value = defaultVal or options[1], Open = false }
                Library.Flags[flag] = Dropdown.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 42)
                RegisterTheme(Elem, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Elem).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -20, 0, 16)
                Label.Position = UDim2.new(0, 10, 0, 2)
                Label.BackgroundTransparency = 1
                Label.Text = ddText
                Label.Font = Enum.Font.MontserratMedium
                Label.TextSize = 9
                RegisterTheme(Label, { TextColor3 = "TextDark" })

                local Trigger = Instance.new("TextButton", Elem)
                Trigger.Size = UDim2.new(1, -20, 0, 20)
                Trigger.Position = UDim2.new(0, 10, 1, -22)
                Trigger.Text = ""
                Trigger.AutoButtonColor = false
                RegisterTheme(Trigger, { BackgroundColor3 = "SectionBg" })
                Instance.new("UICorner", Trigger).CornerRadius = UDim.new(0, 4)

                local DisplayText = Instance.new("TextLabel", Trigger)
                DisplayText.Size = UDim2.new(1, -25, 1, 0)
                DisplayText.Position = UDim2.new(0, 8, 0, 0)
                DisplayText.BackgroundTransparency = 1
                DisplayText.Text = tostring(Dropdown.Value)
                DisplayText.Font = Enum.Font.MontserratBold
                DisplayText.TextSize = 10
                DisplayText.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(DisplayText, { TextColor3 = "TextPrimary" })

                local Arrow = Instance.new("ImageLabel", Trigger)
                Arrow.Size = UDim2.new(0, 10, 0, 10)
                Arrow.Position = UDim2.new(1, -18, 0.5, -5)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = "rbxassetid://10709790644"
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
                        OptBtn.Font = Enum.Font.MontserratMedium
                        OptBtn.TextSize = 9
                        OptBtn.Text = tostring(opt)
                        RegisterTheme(OptBtn, { TextColor3 = (opt == Dropdown.Value and "Accent" or "TextSecondary") })

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
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: MULTI-SELECT DROPDOWN ]]
            -- ========================================================
            function Section:CreateMultiDropdown(ddText, options, defaultTable, flag, callback)
                local Dropdown = { Selected = defaultTable or {}, Open = false }
                Library.Flags[flag] = Dropdown.Selected

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 42)
                RegisterTheme(Elem, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Elem).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -20, 0, 16)
                Label.Position = UDim2.new(0, 10, 0, 2)
                Label.BackgroundTransparency = 1
                Label.Text = ddText
                Label.Font = Enum.Font.MontserratMedium
                Label.TextSize = 9
                RegisterTheme(Label, { TextColor3 = "TextDark" })

                local Trigger = Instance.new("TextButton", Elem)
                Trigger.Size = UDim2.new(1, -20, 0, 20)
                Trigger.Position = UDim2.new(0, 10, 1, -22)
                Trigger.Text = ""
                Trigger.AutoButtonColor = false
                RegisterTheme(Trigger, { BackgroundColor3 = "SectionBg" })
                Instance.new("UICorner", Trigger).CornerRadius = UDim.new(0, 4)

                local DisplayText = Instance.new("TextLabel", Trigger)
                DisplayText.Size = UDim2.new(1, -25, 1, 0)
                DisplayText.Position = UDim2.new(0, 8, 0, 0)
                DisplayText.BackgroundTransparency = 1
                DisplayText.Font = Enum.Font.MontserratBold
                DisplayText.TextSize = 10
                DisplayText.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(DisplayText, { TextColor3 = "TextPrimary" })

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
                Arrow.Image = "rbxassetid://10709790644"
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
                        OptBtn.Font = Enum.Font.MontserratMedium
                        OptBtn.TextSize = 9
                        OptBtn.Text = tostring(opt)
                        RegisterTheme(OptBtn, { TextColor3 = (isSelected and "Accent" or "TextSecondary") })

                        OptBtn.MouseButton1Click:Connect(function()
                            local index = table.find(Dropdown.Selected, opt)
                            if index then
                                table.remove(Dropdown.Selected, index)
                            else
                                table.insert(Dropdown.Selected, opt)
                            end
                            Library.Flags[flag] = Dropdown.Selected
                            UpdateDisplayText()
                            PopulateOptions() -- Refresh selected text color
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
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: BUTTON ]]
            -- ========================================================
            function Section:CreateButton(btnText, callback)
                local Btn = Instance.new("TextButton", Content)
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.Font = Enum.Font.MontserratBold
                Btn.TextSize = 10
                Btn.Text = btnText
                Btn.AutoButtonColor = false
                RegisterTheme(Btn, { BackgroundColor3 = "Accent", TextColor3 = "SectionBg" })
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

                Btn.MouseButton1Click:Connect(function()
                    if callback then task.spawn(callback) end
                end)
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: COLOR PICKER ]]
            -- ========================================================
            function Section:CreateColorPicker(pickerText, defaultColor, flag, callback)
                local Picker = { Value = defaultColor or Color3.fromRGB(0, 255, 120) }
                Library.Flags[flag] = Picker.Value

                local Elem = Instance.new("Frame", Content)
                Elem.Size = UDim2.new(1, 0, 0, 30)
                RegisterTheme(Elem, { BackgroundColor3 = "ElementBg" })
                Instance.new("UICorner", Elem).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = pickerText
                Label.Font = Enum.Font.MontserratMedium
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                local Preview = Instance.new("TextButton", Elem)
                Preview.Size = UDim2.new(0, 16, 0, 16)
                Preview.Position = UDim2.new(1, -26, 0.5, -8)
                Preview.Text = ""
                Preview.BackgroundColor3 = Picker.Value
                Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 3)

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
                return ctrl
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
                Title.Font = Enum.Font.MontserratBold
                Title.TextSize = 10
                Title.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Title, { TextColor3 = "TextPrimary" })

                local Desc = Instance.new("TextLabel", Elem)
                Desc.Size = UDim2.new(1, 0, 1, -16)
                Desc.Position = UDim2.new(0, 0, 0, 16)
                Desc.BackgroundTransparency = 1
                Desc.Text = paraDesc or "Description"
                Desc.Font = Enum.Font.Montserrat
                Desc.TextSize = 9
                Desc.TextWrapped = true
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Desc, { TextColor3 = "TextSecondary" })

                local function ResizeParagraph()
                    local constraintSize = Vector2.new(Content.AbsoluteSize.X - 20, 1000)
                    local textBounds = TextService:GetTextSize(paraDesc, 9, Enum.Font.Montserrat, constraintSize)
                    Elem.Size = UDim2.new(1, 0, 0, textBounds.Y + 22)
                end
                
                Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeParagraph)
                ResizeParagraph()
            end

            table.insert(Tab.Sections, Section)
            return Section
        end

        return Tab
    end

    return Window
end

return Library
