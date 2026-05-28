local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ========================================================
-- [[ 1. SISTEM ENGINE UTAMA (RGB & DRAG) ]]
-- ========================================================
local RGBElements = {}

-- Registrasi objek untuk warna pelangi (RGB) yang halus
local function RegisterRGB(instance, property)
    table.insert(RGBElements, {Instance = instance, Property = property})
end

-- Loop RGB menggunakan os.clock() demi akurasi dan transisi yang mulus
RunService.RenderStepped:Connect(function()
    local hue = (os.clock() % 5) / 5 -- Kecepatan transisi (5 detik)
    local rainbowColor = Color3.fromHSV(hue, 0.75, 1)
    
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

-- Utilitas drag frame (Kompatibel PC & Mobile)
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

-- Mendapatkan ScreenGui global untuk menampung Window & Tombol Eksternal
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
-- [[ 2. SISTEM NOTIFIKASI MODERN ]]
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
    
    local TitleLabel = Instance.new("TextLabel", NotifFrame)
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 12, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Notification"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.MontserratBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DescLabel = Instance.new("TextLabel", NotifFrame)
    DescLabel.Size = UDim2.new(1, -20, 0, 32)
    DescLabel.Position = UDim2.new(0, 12, 0, 26)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc or "Description"
    DescLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
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
-- [[ 3. METODE: MEMBUAT WINDOW UTAMA ]]
-- ========================================================
function Library:CreateWindow(titleText, subtitleText)
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        DragLocked = false
    }

    local ScreenGui = GetMainGui()

    -- Jendela Utama UI
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 530, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -265, 0.5, -170)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.5
    RegisterRGB(MainStroke, "Color")

    -- Garis Dekorasi RGB di bagian atas
    local TopAccent = Instance.new("Frame", MainFrame)
    TopAccent.Size = UDim2.new(1, 0, 0, 3)
    TopAccent.BorderSizePixel = 0
    RegisterRGB(TopAccent, "BackgroundColor3")
    Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(0, 10)

    -- Patch penutup sudut bagian bawah garis aksen
    local AccentPatch = Instance.new("Frame", MainFrame)
    AccentPatch.Size = UDim2.new(1, 0, 0, 2)
    AccentPatch.Position = UDim2.new(0, 0, 0, 2)
    AccentPatch.BorderSizePixel = 0
    RegisterRGB(AccentPatch, "BackgroundColor3")

    -- Header (Area Drag)
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    
    -- Mengaktifkan drag pada Header dengan pengecekan DragLocked
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

    -- Label Judul & Subtitle
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

    -- Sidebar (Bagian Kiri)
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 145, 1, -65)
    Sidebar.Position = UDim2.new(0, 12, 0, 53)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = Color3.fromRGB(35, 35, 40)
    SidebarStroke.Thickness = 1

    -- Container Tombol Tab
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -12, 1, -12)
    TabContainer.Position = UDim2.new(0, 6, 0, 6)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 5)

    -- Area Konten Utama (Sisi Kanan)
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -180, 1, -65)
    ContentArea.Position = UDim2.new(0, 168, 0, 53)
    ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    ContentArea.BorderSizePixel = 0
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 8)

    local ContentStroke = Instance.new("UIStroke", ContentArea)
    ContentStroke.Color = Color3.fromRGB(35, 35, 40)
    ContentStroke.Thickness = 1

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end)

    -- Fungsi Mengunci/Membuka Kunci Drag Window Utama
    function Window:SetDragLock(state)
        Window.DragLocked = state
    end

    -- Sistem Toggle Keybind untuk Menyembunyikan Window Utama
    function Window:BindToggleKey(keyCode)
        local debounce = false
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == keyCode and not debounce then
                debounce = true
                local targetVis = not MainFrame.Visible
                if targetVis then
                    MainFrame.Size = UDim2.new(0, 530, 0, 0)
                    MainFrame.Visible = true
                    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), {Size = UDim2.new(0, 530, 0, 340)}):Play()
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
    -- [[ 4. METODE: MEMBUAT TAB BARU ]]
    -- ========================================================
    function Window:CreateTab(tabName, iconAssetId)
        local Tab = {}
        
        -- Frame Scrolling Konten Tab
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

        -- Tombol Tab di Sidebar
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 34)
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

        local TabBtnStroke = Instance.new("UIStroke", TabButton)
        TabBtnStroke.Color = Color3.fromRGB(40, 40, 45)
        TabBtnStroke.Thickness = 1

        local IconLabel
        if iconAssetId then
            IconLabel = Instance.new("ImageLabel", TabButton)
            IconLabel.Size = UDim2.new(0, 16, 0, 16)
            IconLabel.Position = UDim2.new(0, 10, 0.5, -8)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = iconAssetId
            IconLabel.ImageColor3 = Color3.fromRGB(150, 150, 150)
        end

        local TabText = Instance.new("TextLabel", TabButton)
        TabText.Size = UDim2.new(1, iconAssetId and -36 or -16, 1, 0)
        TabText.Position = UDim2.new(0, iconAssetId and 30 or 10, 0, 0)
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
                if Window.CurrentTab.Icon then
                    Window.CurrentTab.Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            
            Window.CurrentTab = {Button = TabButton, Text = TabText, Frame = TabContent, Icon = IconLabel}
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            if IconLabel then
                IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end

        TabButton.MouseButton1Click:Connect(Select)

        if not Window.CurrentTab then
            Select()
        end

        -- ========================================================
        -- [[ 4a. ELEMEN TAB: CREATE BUTTON ]]
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
        -- [[ 4b. ELEMEN TAB: CREATE TOGGLE ]]
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

            local function UpdateVisual(animate)
                local duration = animate and 0.15 or 0
                local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if Toggle.State then
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    TweenService:Create(SwitchBg, info, {BackgroundColor3 = Color3.fromRGB(50, 180, 80)}):Play()
                else
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

            -- Controller eksternal untuk mengubah state toggle dari luar skrip UI
            local toggleController = {}
            function toggleController:Set(state)
                Toggle.State = state
                UpdateVisual(true)
                if callback then task.spawn(function() callback(Toggle.State) end) end
            end
            return toggleController
        end

        -- ========================================================
        -- [[ 4c. ELEMEN TAB: CREATE SLIDER ]]
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
        -- [[ 4d. ELEMEN TAB: CREATE DROPDOWN ]]
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
                    OptionContainer.Size = UDim2.new(1, -24, 0, OptionList.AbsoluteContentSize.Y)
                    targetHeight = 38 + (OptionList.AbsoluteContentSize.Y + 10)
                    rotation = 180
                else
                    OptionContainer.Size = UDim2.new(1, -24, 0, 0)
                end
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation = rotation}):Play()
            end)
        end

        -- ========================================================
        -- [[ 4e. ELEMEN TAB: CREATE TEXTBOX ]]
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
        -- [[ 4f. ELEMEN TAB: CREATE PARAGRAPH ]]
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
-- [[ 5. SISTEM TOMBOL EKSTERNAL DENGAN TAMPILAN MODERN ]]
-- ========================================================
-- Mendesain tombol berbentuk kotak dengan ujung tumpul, transparansi 60% (0.6),
-- serta mendukung pemutakhiran teks dinamis dan dragging.
function Library:CreateExternalButton(id, text, defaultPos, callback)
    local ScreenGui = GetMainGui()

    local ExtBtn = Instance.new("TextButton")
    ExtBtn.Name = "ExternalButton_" .. tostring(id)
    ExtBtn.Size = UDim2.new(0, 44, 0, 44) -- Ukuran kotak proporsional
    ExtBtn.Position = defaultPos or UDim2.new(0, 20, 0.5, 0)
    ExtBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    ExtBtn.BackgroundTransparency = 0.6 -- Transparansi 60% sesuai keinginan Anda
    ExtBtn.Text = text or "A"
    ExtBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExtBtn.Font = Enum.Font.MontserratBold -- Font modern bersih
    ExtBtn.TextSize = 14
    ExtBtn.AutoButtonColor = false
    ExtBtn.Parent = ScreenGui

    -- Sudut tumpul (tidak tajam)
    local Corner = Instance.new("UICorner", ExtBtn)
    Corner.CornerRadius = UDim.new(0, 8)

    -- Stroke luar pelangi (RGB) modern
    local Stroke = Instance.new("UIStroke", ExtBtn)
    Stroke.Thickness = 1.5
    RegisterRGB(Stroke, "Color")

    -- Aktifkan sistem dragging
    EnableDrag(ExtBtn, ExtBtn)

    -- Event Trigger Klik
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

    -- Controller khusus yang dikembalikan ke loader untuk memanipulasi tombol secara instan
    local buttonController = {}
    
    -- Kustomisasi Teks (dari loader)
    function buttonController:SetText(newText)
        ExtBtn.Text = tostring(newText)
    end
    
    -- Kustomisasi Visibilitas
    function buttonController:SetVisible(visible)
        ExtBtn.Visible = visible
    end
    
    -- Kustomisasi Transparansi
    function buttonController:SetTransparency(transparency)
        ExtBtn.BackgroundTransparency = transparency
    end

    -- Kustomisasi Ukuran
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
