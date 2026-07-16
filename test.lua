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
-- [[ COLOR PALETTE (EXACT IMAGE SCHEME) ]]
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
        TextSecondary = Color3.fromRGB(150, 155, 165),
        TextDark = Color3.fromRGB(90, 95, 105)
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

-- ========================================================
-- [[ HYBRID TOUCH & MOUSE DRAGGING ]]
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
        ActiveTab = nil,
        Visible = true
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Nexus_Compkiller_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local successHui, hui = pcall(function() return gethui and gethui() end)
    ScreenGui.Parent = (successHui and hui) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 640, 0, 460)
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -230)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    RegisterTheme(MainFrame, { BackgroundColor3 = "WindowBg" })

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.5
    RegisterTheme(MainStroke, { Color = "StrokeColor" })

    -- Sidebar (Left Area)
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BorderSizePixel = 0
    RegisterTheme(Sidebar, { BackgroundColor3 = "SidebarBg" })

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 8)

    -- Sidebar Masking
    local SidebarMask = Instance.new("Frame", Sidebar)
    SidebarMask.Size = UDim2.new(0, 15, 1, 0)
    SidebarMask.Position = UDim2.new(1, -15, 0, 0)
    SidebarMask.BorderSizePixel = 0
    RegisterTheme(SidebarMask, { BackgroundColor3 = "SidebarBg" })

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
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(TitleLabel, { TextColor3 = "TextPrimary" })

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
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextSize = 11
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(UsernameLabel, { TextColor3 = "TextPrimary" })

    local SubtextLabel = Instance.new("TextLabel", UserCard)
    SubtextLabel.Size = UDim2.new(1, -50, 0, 14)
    SubtextLabel.Position = UDim2.new(0, 44, 0.5, 2)
    SubtextLabel.BackgroundTransparency = 1
    SubtextLabel.Text = subtitleText or "NEVER"
    SubtextLabel.Font = Enum.Font.GothamBold
    SubtextLabel.TextSize = 9
    SubtextLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegisterTheme(SubtextLabel, { TextColor3 = "TextDark" })

    -- Content Frame Workspace
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -170, 1, 0)
    ContentArea.Position = UDim2.new(0, 170, 0, 0)
    ContentArea.BackgroundTransparency = 1

    -- ========================================================
    -- [[ CATEGORY HEADER SYSTEM ]]
    -- ========================================================
    function Window:CreateCategory(categoryName)
        local CatFrame = Instance.new("Frame", TabScroll)
        CatFrame.Size = UDim2.new(1, -10, 0, 24)
        CatFrame.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", CatFrame)
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = categoryName
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        RegisterTheme(Label, { TextColor3 = "TextDark" })
    end

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

        LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeCanvas)
        RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeCanvas)

        local TabBtn = Instance.new("TextButton", TabScroll)
        TabBtn.Size = UDim2.new(1, -10, 0, 32)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false

        local TabBtnCorner = Instance.new("UICorner", TabBtn)
        TabBtnCorner.CornerRadius = UDim.new(0, 6)

        -- Active Indicator Line (Cyan line on the edge of selected tab)
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
        TabIcon.Image = iconAssetId or "rbxassetid://10734741641"
        RegisterTheme(TabIcon, { ImageColor3 = "TextSecondary" })

        local TabLabel = Instance.new("TextLabel", TabBtn)
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Position = UDim2.new(0, 35, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.Font = Enum.Font.GothamMedium
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

        if #Window.Tabs == 1 then
            task.spawn(function()
                task.wait(0.1)
                SelectTab()
            end)
        end

        table.insert(Window.Tabs, Tab)

        -- ========================================================
        -- [[ SECTION CONTAINER CREATION ]]
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
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            RegisterTheme(Title, { TextColor3 = "TextPrimary" })

            local ToggleIcon = Instance.new("ImageLabel", Header)
            ToggleIcon.Size = UDim2.new(0, 12, 0, 12)
            ToggleIcon.Position = UDim2.new(1, -24, 0.5, -6)
            ToggleIcon.BackgroundTransparency = 1
            ToggleIcon.Image = "rbxassetid://10709790644"
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
                local contentHeight = ContentList.AbsoluteContentSize.Y
                SecFrame.Size = UDim2.new(1, 0, 0, contentHeight + 46)
            end

            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)

            local InsidePadding = Instance.new("UIPadding", Content)
            InsidePadding.PaddingLeft = UDim.new(0, 12)
            InsidePadding.PaddingRight = UDim.new(0, 12)
            InsidePadding.PaddingBottom = UDim.new(0, 12)

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
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                -- Inline container for auxiliary features next to toggle
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
                        InfoIcon.Image = "rbxassetid://10723415903"
                        RegisterTheme(InfoIcon, { ImageColor3 = "TextDark" })
                    end

                    if config.gear then
                        local GearIcon = Instance.new("ImageLabel", InlineList)
                        GearIcon.Size = UDim2.new(0, 14, 0, 14)
                        GearIcon.BackgroundTransparency = 1
                        GearIcon.Image = "rbxassetid://10734950309"
                        RegisterTheme(GearIcon, { ImageColor3 = "TextDark" })
                    end

                    if config.keybind then
                        local InlineBind = Instance.new("TextLabel", InlineList)
                        InlineBind.Size = UDim2.new(0, 18, 0, 18)
                        InlineBind.BackgroundTransparency = 0.5
                        InlineBind.Text = tostring(config.keybind)
                        InlineBind.Font = Enum.Font.GothamBold
                        InlineBind.TextSize = 9
                        RegisterTheme(InlineBind, { TextColor3 = "TextSecondary", BackgroundColor3 = "SidebarBg" })
                        
                        local Border = Instance.new("UIStroke", InlineBind)
                        Border.Thickness = 1
                        RegisterTheme(Border, { Color = "StrokeColor" })
                        
                        local Corner = Instance.new("UICorner", InlineBind)
                        Corner.CornerRadius = UDim.new(0, 3)
                    end
                end

                -- Toggle Switch (Pill Button)
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

                -- Moving Circle Knob
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
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                local BindBtn = Instance.new("TextButton", Elem)
                BindBtn.Size = UDim2.new(0, 46, 0, 18)
                BindBtn.Position = UDim2.new(1, -46, 0.5, -9)
                BindBtn.Font = Enum.Font.GothamBold
                BindBtn.TextSize = 9
                BindBtn.Text = Keybind.Value.Name
                RegisterTheme(BindBtn, { BackgroundColor3 = "ElementBg", TextColor3 = "TextSecondary" })
                Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 3)

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
                    if typeof(val) == "string" then
                        val = Enum.KeyCode[val]
                    end
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
                Elem.Size = UDim2.new(1, 0, 0, 38)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, -60, 0, 18)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = sliderText
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                local ValLabel = Instance.new("TextLabel", Elem)
                ValLabel.Size = UDim2.new(0, 40, 0, 18)
                ValLabel.Position = UDim2.new(1, -40, 0, 0)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(Slider.Value)
                ValLabel.Font = Enum.Font.GothamMedium
                ValLabel.TextSize = 11
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                RegisterTheme(ValLabel, { TextColor3 = "TextDark" })

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

                -- Visual Knob Indicator matching the image
                local SliderKnob = Instance.new("Frame", SliderBg)
                SliderKnob.Size = UDim2.new(0, 10, 0, 10)
                SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderKnob.Position = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 0.5, 0)
                SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

                local function UpdateSlider(input)
                    local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    local rawVal = minVal + (percentage * (maxVal - minVal))
                    local finalVal = math.floor(rawVal + 0.5)

                    Slider.Value = finalVal
                    Library.Flags[flag] = finalVal
                    ValLabel.Text = tostring(finalVal)
                    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(percentage, 0, 0.5, 0)
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
                    local perc = (clamped - minVal) / (maxVal - minVal)
                    SliderFill.Size = UDim2.new(perc, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(perc, 0, 0.5, 0)
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
                Elem.Size = UDim2.new(1, 0, 0, 44)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = ddText
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

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
                DisplayText.Font = Enum.Font.GothamMedium
                DisplayText.TextSize = 11
                DisplayText.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(DisplayText, { TextColor3 = "TextSecondary" })

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
                        OptBtn.Font = Enum.Font.GothamMedium
                        OptBtn.TextSize = 10
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
                Elem.Size = UDim2.new(1, 0, 0, 44)
                Elem.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Elem)
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = ddText
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

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
                DisplayText.Font = Enum.Font.GothamMedium
                DisplayText.TextSize = 11
                DisplayText.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(DisplayText, { TextColor3 = "TextSecondary" })

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
                        OptBtn.Font = Enum.Font.GothamMedium
                        OptBtn.TextSize = 10
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
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: COLOR PICKER ]]
            -- ========================================================
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
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Label, { TextColor3 = "TextSecondary" })

                -- Rounded color square matching image
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
                return ctrl
            end

            -- ========================================================
            -- [[ SECTION ELEMENT: BUTTON ]]
            -- ========================================================
            function Section:CreateButton(btnText, callback)
                local Btn = Instance.new("TextButton", Content)
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.Font = Enum.Font.GothamBold
                Btn.TextSize = 11
                Btn.Text = btnText
                Btn.AutoButtonColor = false
                RegisterTheme(Btn, { BackgroundColor3 = "Accent", TextColor3 = "WindowBg" })
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

                Btn.MouseButton1Click:Connect(function()
                    if callback then task.spawn(callback) end
                end)
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
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 11
                Title.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Title, { TextColor3 = "TextPrimary" })

                local Desc = Instance.new("TextLabel", Elem)
                Desc.Size = UDim2.new(1, 0, 1, -16)
                Desc.Position = UDim2.new(0, 0, 0, 16)
                Desc.BackgroundTransparency = 1
                Desc.Text = paraDesc or "Description"
                Desc.Font = Enum.Font.Gotham
                Desc.TextSize = 10
                Desc.TextWrapped = true
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                RegisterTheme(Desc, { TextColor3 = "TextSecondary" })

                local function ResizeParagraph()
                    local constraintSize = Vector2.new(Content.AbsoluteSize.X - 20, 1000)
                    local textBounds = TextService:GetTextSize(paraDesc, 10, Enum.Font.Gotham, constraintSize)
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

    -- ========================================================
    -- [[ 6. MOBILE FLOATING TOGGLE ICON ]]
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
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 640, 0, 460), Position = UDim2.new(0.5, -320, 0.5, -230)}):Play()
            
            TweenService:Create(FloatingToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.delay(0.2, function() FloatingToggle.Visible = false end)
        else
            local shrink = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
            shrink:Play()
            shrink.Completed:Connect(function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
            
            FloatingToggle.Visible = true
            TweenService:Create(FloatingToggle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()
        end
    end

    FloatingToggle.MouseButton1Click:Connect(ToggleGui)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            ToggleGui()
        end
    end)
    
    function Window:Minimize()
        ToggleGui()
    end

    return Window
end

return Library
