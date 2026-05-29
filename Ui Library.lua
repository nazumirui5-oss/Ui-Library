local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ========================================================
-- [[ 1. MAIN ENGINE SYSTEM (DYNAMIC RGB & DRAG) ]]
-- ========================================================
local RGBElements = {}

-- Register an instance property to cycle smoothly through the rainbow spectrum
local function RegisterRGB(instance, property)
    table.insert(RGBElements, {Instance = instance, Property = property})
end

-- Unregister an instance property from the rainbow cycle
local function UnregisterRGB(instance, property)
    for i = #RGBElements, 1, -1 do
        if RGBElements[i].Instance == instance and RGBElements[i].Property == property then
            table.remove(RGBElements, i)
        end
    end
end

-- Fast and highly saturated RGB loop utilizing os.clock()
RunService.RenderStepped:Connect(function()
    local hue = (os.clock() % 4) / 4 -- Transition cycle speed (4 seconds)
    local rainbowColor = Color3.fromHSV(hue, 1, 1) -- Maximum saturation & brightness
    
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

-- Drag utility compatible with both PC mouse inputs and Mobile touch inputs
local function EnableDrag(dragFrame, parentFrame)
    local dragging, dragInput, dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parentFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Fetches or initializes the global ScreenGui container
local MainGui
local function GetMainGui()
    if not MainGui then
        MainGui = Instance.new("ScreenGui")
        MainGui.Name = "LouisHub_ModernUI"
        MainGui.ResetOnSpawn = false
        MainGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
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
        NotificationGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
        
        local Holder = Instance.new("Frame", NotificationGui)
        Holder.Name = "Holder"
        Holder.Size = UDim2.new(0, 280, 1, -40)
        Holder.Position = UDim2.new(1, -300, 0, 20)
        Holder.BackgroundTransparency = 1
        
        local Layout = Instance.new("UIListLayout", Holder)
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.Padding = UDim.new(0, 10)
    end
    return NotificationGui.Holder
end

function Library:Notify(title, desc, duration)
    duration = duration or 4
    local Holder = GetNotificationHolder()
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true
    NotifFrame.Parent = Holder
    
    local NotifCorner = Instance.new("UICorner", NotifFrame)
    NotifCorner.CornerRadius = UDim.new(0, 8)
    
    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Thickness = 1.2
    RegisterRGB(NotifStroke, "Color")

    -- Vibrant left-side RGB accent strip
    local NotifAccent = Instance.new("Frame", NotifFrame)
    NotifAccent.Size = UDim2.new(0, 4, 1, 0)
    NotifAccent.Position = UDim2.new(0, 0, 0, 0)
    NotifAccent.BorderSizePixel = 0
    RegisterRGB(NotifAccent, "BackgroundColor3")
    
    local TitleLabel = Instance.new("TextLabel", NotifFrame)
    TitleLabel.Size = UDim2.new(1, -30, 0, 20)
    TitleLabel.Position = UDim2.new(0, 16, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Notification"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DescLabel = Instance.new("TextLabel", NotifFrame)
    DescLabel.Size = UDim2.new(1, -30, 0, 32)
    DescLabel.Position = UDim2.new(0, 16, 0, 26)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc or "Description"
    DescLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    DescLabel.Font = Enum.Font.Montserrat
    DescLabel.TextSize = 10
    DescLabel.TextWrapped = true
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 65)}):Play()
    
    task.delay(duration, function()
        if NotifFrame and NotifFrame.Parent then
            local fadeOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end
    end)
end

-- ========================================================
-- [[ 3. METHODS: CREATE MAIN WINDOW ]]
-- ========================================================
function Library:CreateWindow(titleText, subtitleText)
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        DragLocked = false,
        Minimized = false
    }

    local ScreenGui = GetMainGui()

    -- Main UI Container Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 530, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -265, 0.5, -170)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)

    -- Full Outer RGB Stroke
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.5
    RegisterRGB(MainStroke, "Color")

    -- Header Panel (Drag & Collapse Area)
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    
    -- Drag handling on Header with DragLocked verification
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if not Window.DragLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if not Window.DragLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and not Window.DragLocked then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Header Title & Subtitle Labels
    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(0, 300, 0, 22)
    TitleLabel.Position = UDim2.new(0, 18, 0, 12)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText or "LOUIS HUB"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SubtitleLabel = Instance.new("TextLabel", Header)
    SubtitleLabel.Size = UDim2.new(0, 300, 0, 15)
    SubtitleLabel.Position = UDim2.new(0, 18, 0, 30)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = subtitleText or "Rebuilt Edition"
    SubtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    SubtitleLabel.TextSize = 10
    SubtitleLabel.Font = Enum.Font.Montserrat
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Clean Horizontal RGB Separator Line (Replaced Overlapping Accent Panels)
    local HeaderSeparator = Instance.new("Frame", MainFrame)
    HeaderSeparator.Size = UDim2.new(1, 0, 0, 1)
    HeaderSeparator.Position = UDim2.new(0, 0, 0, 50)
    HeaderSeparator.BorderSizePixel = 0
    RegisterRGB(HeaderSeparator, "BackgroundColor3")

    -- Sidebar Container (Left Panel)
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 145, 1, -65)
    Sidebar.Position = UDim2.new(0, 12, 0, 57)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = Color3.fromRGB(35, 35, 40)
    SidebarStroke.Thickness = 1

    -- Tab Selection Scroll Area
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -12, 1, -12)
    TabContainer.Position = UDim2.new(0, 6, 0, 6)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 5)

    -- Primary Content Workspace (Right Panel)
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -180, 1, -65)
    ContentArea.Position = UDim2.new(0, 168, 0, 57)
    ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    ContentArea.BorderSizePixel = 0
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 8)

    local ContentStroke = Instance.new("UIStroke", ContentArea)
    ContentStroke.Color = Color3.fromRGB(35, 35, 40)
    ContentStroke.Thickness = 1

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end)

    -- Interactive Open/Close (Minimize) Button with Rotation Effects
    local ToggleIcon = Instance.new("ImageButton", Header)
    ToggleIcon.Size = UDim2.new(0, 20, 0, 20)
    ToggleIcon.Position = UDim2.new(1, -32, 0, 15)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Image = "rbxassetid://6031094670" -- Modern V-arrow icon
    ToggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    ToggleIcon.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        local targetSize = Window.Minimized and UDim2.new(0, 530, 0, 51) or UDim2.new(0, 530, 0, 340)
        local targetRotation = Window.Minimized and 180 or 0
        
        TweenService:Create(ToggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
        
        if Window.Minimized then
            Sidebar.Visible = false
            ContentArea.Visible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        else
            local expandTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
            expandTween:Play()
            expandTween.Completed:Connect(function()
                if not Window.Minimized then
                    Sidebar.Visible = true
                    ContentArea.Visible = true
                end
            end)
        end
    end)

    -- Lock or unlock window dragging
    function Window:SetDragLock(state)
        Window.DragLocked = state
    end

    -- External keybind registration to hide/reveal the UI
    function Window:BindToggleKey(keyCode)
        local debounce = false
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == keyCode and not debounce then
                debounce = true
                local targetVis = not MainFrame.Visible
                if targetVis then
                    MainFrame.Size = Window.Minimized and UDim2.new(0, 530, 0, 51) or UDim2.new(0, 530, 0, 0)
                    MainFrame.Visible = true
                    local sizeGoal = Window.Minimized and UDim2.new(0, 530, 0, 51) or UDim2.new(0, 530, 0, 340)
                    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), {Size = sizeGoal}):Play()
                else
                    local t = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.In, Enum.EasingDirection.Quad), {Size = UDim2.new(0, 530, 0, 0)})
                    t:Play()
                    t.Completed:Connect(function()
                        if not MainFrame.Visible then
                            MainFrame.Visible = false
                        end
                    end)
                end
                task.wait(0.3)
                debounce = false
            end
        end)
    end

    -- ========================================================
    -- [[ 4. METHODS: CREATE NEW TAB ]]
    -- ========================================================
    function Window:CreateTab(tabName, iconAssetId)
        local Tab = {}
        
        -- Scrolling Container for Tab Items
        local TabContent = Instance.new("ScrollingFrame", ContentArea)
        TabContent.Size = UDim2.new(1, -16, 1, -16)
        TabContent.Position = UDim2.new(0, 8, 0, 8)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 2
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
        end)

        -- Sidebar Tab Selection Button
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 34)
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

        local TabBtnStroke = Instance.new("UIStroke", TabButton)
        TabBtnStroke.Color = Color3.fromRGB(40, 40, 45)
        TabBtnStroke.Thickness = 1

        -- Tiny vertical active RGB status indicator inside the tab selection button
        local TabIndicator = Instance.new("Frame", TabButton)
        TabIndicator.Size = UDim2.new(0, 3, 1, -12)
        TabIndicator.Position = UDim2.new(0, 4, 0, 6)
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = false
        RegisterRGB(TabIndicator, "BackgroundColor3")

        local IconLabel
        if iconAssetId then
            IconLabel = Instance.new("ImageLabel", TabButton)
            IconLabel.Size = UDim2.new(0, 16, 0, 16)
            IconLabel.Position = UDim2.new(0, 12, 0.5, -8)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = iconAssetId
            IconLabel.ImageColor3 = Color3.fromRGB(150, 150, 150)
        end

        local TabText = Instance.new("TextLabel", TabButton)
        TabText.Size = UDim2.new(1, iconAssetId and -38 or -18, 1, 0)
        TabText.Position = UDim2.new(0, iconAssetId and 32 or 12)
        TabText.BackgroundTransparency = 1
        TabText.Text = tabName
        TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabText.TextSize = 12
        TabText.Font = Enum.Font.MontserratMedium
        TabText.TextXAlignment = Enum.TextXAlignment.Left

        local function Select()
            if Window.CurrentTab then
                Window.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                Window.CurrentTab.Text.TextColor3 = Color3.fromRGB(150, 150, 150)
                Window.CurrentTab.Frame.Visible = false
                Window.CurrentTab.Indicator.Visible = false
                if Window.CurrentTab.Icon then
                    Window.CurrentTab.Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            
            Window.CurrentTab = {Button = TabButton, Text = TabText, Frame = TabContent, Icon = IconLabel, Indicator = TabIndicator}
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            TabIndicator.Visible = true
            if IconLabel then
                IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end

        TabButton.MouseButton1Click:Connect(Select)

        if not Window.CurrentTab then
            Select()
        end

        -- ========================================================
        -- [[ 4a. TAB ELEMENT: CREATE BUTTON ]]
        -- ========================================================
        function Tab:CreateButton(buttonText, callback)
            local Button = Instance.new("TextButton", TabContent)
            Button.Size = UDim2.new(1, -6, 0, 38)
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            Button.Text = ""
            Button.AutoButtonColor = false

            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            local BtnStroke = Instance.new("UIStroke", Button)
            BtnStroke.Color = Color3.fromRGB(45, 45, 50)
            BtnStroke.Thickness = 1

            local BtnText = Instance.new("TextLabel", Button)
            BtnText.Size = UDim2.new(1, -35, 1, 0)
            BtnText.Position = UDim2.new(0, 12, 0, 0)
            BtnText.BackgroundTransparency = 1
            BtnText.Text = buttonText or "Button"
            BtnText.TextColor3 = Color3.fromRGB(220, 220, 220)
            BtnText.TextSize = 12
            BtnText.Font = Enum.Font.MontserratMedium
            BtnText.TextXAlignment = Enum.TextXAlignment.Left

            local ArrowIcon = Instance.new("ImageLabel", Button)
            ArrowIcon.Size = UDim2.new(0, 14, 0, 14)
            ArrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://6031094678"
            ArrowIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                local press = TweenService:Create(Button, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
                press:Play()
                press.Completed:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
                end)
                if callback then task.spawn(callback) end
            end)
        end

        -- ========================================================
        -- [[ 4b. TAB ELEMENT: CREATE TOGGLE ]]
        -- ========================================================
        function Tab:CreateToggle(toggleText, defaultVal, callback)
            local Toggle = {State = defaultVal or false}

            local ToggleBtn = Instance.new("TextButton", TabContent)
            ToggleBtn.Size = UDim2.new(1, -6, 0, 38)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false

            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
            local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
            ToggleStroke.Color = Color3.fromRGB(45, 45, 50)
            ToggleStroke.Thickness = 1

            local TextLabel = Instance.new("TextLabel", ToggleBtn)
            TextLabel.Size = UDim2.new(1, -65, 1, 0)
            TextLabel.Position = UDim2.new(0, 12, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = toggleText or "Toggle"
            TextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TextLabel.TextSize = 12
            TextLabel.Font = Enum.Font.MontserratMedium
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SwitchBg = Instance.new("Frame", ToggleBtn)
            SwitchBg.Size = UDim2.new(0, 36, 0, 20)
            SwitchBg.Position = UDim2.new(1, -48, 0.5, -10)
            SwitchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            SwitchBg.BorderSizePixel = 0
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

            local SwitchBall = Instance.new("Frame", SwitchBg)
            SwitchBall.Size = UDim2.new(0, 14, 0, 14)
            SwitchBall.Position = UDim2.new(0, 3, 0.5, -7)
            SwitchBall.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            SwitchBall.BorderSizePixel = 0
            Instance.new("UICorner", SwitchBall).CornerRadius = UDim.new(1, 0)

            -- Dynamic visual updates incorporating a dynamic RGB background when turned ON
            local function UpdateVisual(animate)
                local duration = animate and 0.15 or 0
                local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if Toggle.State then
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    RegisterRGB(SwitchBg, "BackgroundColor3") -- Dynamic active background color
                else
                    UnregisterRGB(SwitchBg, "BackgroundColor3")
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    TweenService:Create(SwitchBg, info, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
                end
            end

            UpdateVisual(false)

            ToggleBtn.MouseButton1Click:Connect(function()
                Toggle.State = not Toggle.State
                UpdateVisual(true)
                if callback then task.spawn(function() callback(Toggle.State) end) end
            end)

            -- Controller interface to allow external state updates
            local toggleController = {}
            function toggleController:Set(state)
                Toggle.State = state
                UpdateVisual(true)
                if callback then task.spawn(function() callback(Toggle.State) end) end
            end
            return toggleController
        end

        -- ========================================================
        -- [[ 4c. TAB ELEMENT: CREATE SLIDER ]]
        -- ========================================================
        function Tab:CreateSlider(sliderText, minVal, maxVal, defaultVal, callback)
            local Slider = {Value = defaultVal or minVal}
            
            local SliderFrame = Instance.new("Frame", TabContent)
            SliderFrame.Size = UDim2.new(1, -6, 0, 52)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
            local SliderStroke = Instance.new("UIStroke", SliderFrame)
            SliderStroke.Color = Color3.fromRGB(45, 45, 50)
            SliderStroke.Thickness = 1

            local TitleLabel = Instance.new("TextLabel", SliderFrame)
            TitleLabel.Size = UDim2.new(1, -20, 0, 20)
            TitleLabel.Position = UDim2.new(0, 12, 0, 5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = sliderText .. ": " .. tostring(Slider.Value)
            TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TitleLabel.TextSize = 12
            TitleLabel.Font = Enum.Font.MontserratMedium
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SliderBg = Instance.new("TextButton", SliderFrame)
            SliderBg.Size = UDim2.new(1, -24, 0, 6)
            SliderBg.Position = UDim2.new(0, 12, 1, -16)
            SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            SliderBg.Text = ""
            SliderBg.AutoButtonColor = false
            Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

            local SliderFill = Instance.new("Frame", SliderBg)
            SliderFill.Size = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 1, 0)
            SliderFill.BorderSizePixel = 0
            Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
            RegisterRGB(SliderFill, "BackgroundColor3")

            local sliding = false
            local function Update(input)
                local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local rawVal = minVal + (percentage * (maxVal - minVal))
                local finalVal = math.floor(rawVal + 0.5)
                
                Slider.Value = finalVal
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                TitleLabel.Text = sliderText .. ": " .. tostring(finalVal)
                
                if callback then task.spawn(function() callback(finalVal) end) end
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
        end

        -- ========================================================
        -- [[ 4d. TAB ELEMENT: CREATE DROPDOWN ]]
        -- ========================================================
        function Tab:CreateDropdown(dropdownText, options, defaultVal, callback)
            local Dropdown = {
                Open = false,
                CurrentValue = defaultVal or options[1],
                OptionFrames = {}
            }
            
            local DropdownFrame = Instance.new("Frame", TabContent)
            DropdownFrame.Size = UDim2.new(1, -6, 0, 38)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            DropdownFrame.ClipsDescendants = true
            
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)
            local FrameStroke = Instance.new("UIStroke", DropdownFrame)
            FrameStroke.Color = Color3.fromRGB(45, 45, 50)
            FrameStroke.Thickness = 1

            local DropdownBtn = Instance.new("TextButton", DropdownFrame)
            DropdownBtn.Size = UDim2.new(1, 0, 0, 38)
            DropdownBtn.BackgroundTransparency = 1
            DropdownBtn.Text = ""

            local TextLabel = Instance.new("TextLabel", DropdownBtn)
            TextLabel.Size = UDim2.new(1, -60, 1, 0)
            TextLabel.Position = UDim2.new(0, 12, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = dropdownText .. " (" .. tostring(Dropdown.CurrentValue) .. ")"
            TextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TextLabel.TextSize = 12
            TextLabel.Font = Enum.Font.MontserratMedium
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ArrowIcon = Instance.new("ImageLabel", DropdownBtn)
            ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
            ArrowIcon.Position = UDim2.new(1, -24, 0.5, -6)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://6031094670"
            ArrowIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

            local OptionContainer = Instance.new("Frame", DropdownFrame)
            OptionContainer.Size = UDim2.new(1, -24, 0, 0)
            OptionContainer.Position = UDim2.new(0, 12, 0, 40)
            OptionContainer.BackgroundTransparency = 1

            local OptionList = Instance.new("UIListLayout", OptionContainer)
            OptionList.Padding = UDim.new(0, 5)

            local function Refresh()
                for _, v in ipairs(Dropdown.OptionFrames) do v:Destroy() end
                Dropdown.OptionFrames = {}

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton", OptionContainer)
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                    OptBtn.Text = ""
                    OptBtn.AutoButtonColor = false
                    Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 5)

                    local OptText = Instance.new("TextLabel", OptBtn)
                    OptText.Size = UDim2.new(1, -20, 1, 0)
                    OptText.Position = UDim2.new(0, 12, 0, 0)
                    OptText.BackgroundTransparency = 1
                    OptText.Text = tostring(opt)
                    OptText.TextSize = 11
                    OptText.TextXAlignment = Enum.TextXAlignment.Left

                    if opt == Dropdown.CurrentValue then
                        OptText.TextColor3 = Color3.fromRGB(255, 255, 255)
                        OptText.Font = Enum.Font.MontserratBold
                        
                        local Indicator = Instance.new("Frame", OptBtn)
                        Indicator.Size = UDim2.new(0, 3, 1, -10)
                        Indicator.Position = UDim2.new(0, 4, 0, 5)
                        Instance.new("UICorner", Indicator)
                        RegisterRGB(Indicator, "BackgroundColor3")
                    else
                        OptText.TextColor3 = Color3.fromRGB(160, 160, 160)
                        OptText.Font = Enum.Font.Montserrat
                    end

                    OptBtn.MouseEnter:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(38, 38, 43)}):Play()
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown.CurrentValue = opt
                        TextLabel.Text = dropdownText .. " (" .. tostring(opt) .. ")"
                        Dropdown.Open = false
                        
                        UnregisterRGB(FrameStroke, "Color")
                        FrameStroke.Color = Color3.fromRGB(45, 45, 50)
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -6, 0, 38)}):Play()
                        TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        
                        Refresh()
                        if callback then task.spawn(function() callback(opt) end) end
                    end)

                    table.insert(Dropdown.OptionFrames, OptBtn)
                end
            end

            DropdownBtn.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                local targetHeight = 38
                local rotation = 0
                
                if Dropdown.Open then
                    Refresh()
                    RegisterRGB(FrameStroke, "Color") -- Highlight frame dynamically during open state
                    OptionContainer.Size = UDim2.new(1, -24, 0, OptionList.AbsoluteContentSize.Y)
                    targetHeight = 38 + (OptionList.AbsoluteContentSize.Y + 10)
                    rotation = 180
                else
                    UnregisterRGB(FrameStroke, "Color")
                    FrameStroke.Color = Color3.fromRGB(45, 45, 50)
                    OptionContainer.Size = UDim2.new(1, -24, 0, 0)
                end
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation = rotation}):Play()
            end)
        end

        -- ========================================================
        -- [[ 4e. TAB ELEMENT: CREATE TEXTBOX ]]
        -- ========================================================
        function Tab:CreateTextBox(labelText, placeholderText, callback)
            local TextBoxFrame = Instance.new("Frame", TabContent)
            TextBoxFrame.Size = UDim2.new(1, -6, 0, 38)
            TextBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            
            Instance.new("UICorner", TextBoxFrame).CornerRadius = UDim.new(0, 6)
            local FrameStroke = Instance.new("UIStroke", TextBoxFrame)
            FrameStroke.Color = Color3.fromRGB(45, 45, 50)
            FrameStroke.Thickness = 1

            local Label = Instance.new("TextLabel", TextBoxFrame)
            Label.Size = UDim2.new(0.45, -12, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = labelText or "Input Text"
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 12
            Label.Font = Enum.Font.MontserratMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local InputBox = Instance.new("TextBox", TextBoxFrame)
            InputBox.Size = UDim2.new(0.55, -12, 0, 26)
            InputBox.Position = UDim2.new(0.45, 0, 0.5, -13)
            InputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            InputBox.Text = ""
            InputBox.PlaceholderText = placeholderText or "Type here..."
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
            InputBox.TextSize = 11
            InputBox.Font = Enum.Font.Montserrat
            InputBox.ClearTextOnFocus = false

            Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 5)
            local InputStroke = Instance.new("UIStroke", InputBox)
            InputStroke.Color = Color3.fromRGB(50, 50, 55)
            InputStroke.Thickness = 1

            InputBox.FocusLost:Connect(function(enterPressed)
                if callback then task.spawn(function() callback(InputBox.Text, enterPressed) end) end
            end)
        end

        -- ========================================================
        -- [[ 4f. TAB ELEMENT: CREATE PARAGRAPH ]]
        -- ========================================================
        function Tab:CreateParagraph(titleText, descText)
            local ParagraphFrame = Instance.new("Frame", TabContent)
            ParagraphFrame.Size = UDim2.new(1, -6, 0, 56)
            ParagraphFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            ParagraphFrame.BackgroundTransparency = 0.5
            
            Instance.new("UICorner", ParagraphFrame).CornerRadius = UDim.new(0, 6)
            local FrameStroke = Instance.new("UIStroke", ParagraphFrame)
            FrameStroke.Color = Color3.fromRGB(35, 35, 40)
            FrameStroke.Thickness = 1

            local TitleLabel = Instance.new("TextLabel", ParagraphFrame)
            TitleLabel.Size = UDim2.new(1, -20, 0, 20)
            TitleLabel.Position = UDim2.new(0, 12, 0, 6)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = titleText or "Section Title"
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.Font = Enum.Font.MontserratBold
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local DescLabel = Instance.new("TextLabel", ParagraphFrame)
            DescLabel.Size = UDim2.new(1, -20, 1, -30)
            DescLabel.Position = UDim2.new(0, 12, 0, 24)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = descText or "Description text details."
            DescLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
            DescLabel.Font = Enum.Font.Montserrat
            DescLabel.TextSize = 10
            DescLabel.TextWrapped = true
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        end

        return Tab
    end

    return Window
end

-- ========================================================
-- [[ 5. EXTERNAL UTILITY BUTTON SYSTEM ]]
-- ========================================================
function Library:CreateExternalButton(id, text, defaultPos, callback)
    local ScreenGui = GetMainGui()

    local ExtBtn = Instance.new("TextButton")
    ExtBtn.Name = "ExternalButton_" .. tostring(id)
    ExtBtn.Size = UDim2.new(0, 44, 0, 44)
    ExtBtn.Position = defaultPos or UDim2.new(0, 20, 0.5, 0)
    ExtBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    ExtBtn.BackgroundTransparency = 0.6
    ExtBtn.Text = text or "A"
    ExtBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExtBtn.Font = Enum.Font.MontserratBold
    ExtBtn.TextSize = 14
    ExtBtn.AutoButtonColor = false
    ExtBtn.Parent = ScreenGui

    local Corner = Instance.new("UICorner", ExtBtn)
    Corner.CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", ExtBtn)
    Stroke.Thickness = 1.5
    RegisterRGB(Stroke, "Color")

    EnableDrag(ExtBtn, ExtBtn)

    ExtBtn.MouseButton1Click:Connect(function()
        local origTrans = ExtBtn.BackgroundTransparency
        TweenService:Create(ExtBtn, TweenInfo.new(0.05), {BackgroundTransparency = 0.4}):Play()
        task.delay(0.08, function()
            TweenService:Create(ExtBtn, TweenInfo.new(0.1), {BackgroundTransparency = origTrans}):Play()
        end)
        
        if callback then
            task.spawn(callback)
        end
    end)

    -- Controller returns for external programmatic modifications
    local buttonController = {}
    
    function buttonController:SetText(newText)
        ExtBtn.Text = tostring(newText)
    end
    
    function buttonController:SetVisible(visible)
        ExtBtn.Visible = visible
    end
    
    function buttonController:SetTransparency(transparency)
        ExtBtn.BackgroundTransparency = transparency
    end

    function buttonController:SetSize(size)
        if typeof(size) == "UDim2" then
            ExtBtn.Size = size
        elseif type(size) == "number" then
            ExtBtn.Size = UDim2.new(0, size, 0, size)
        end
    end

    return buttonController
end

return Library
