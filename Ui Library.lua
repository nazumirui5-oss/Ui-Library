local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ========================================================
-- [[ 1. UTILITAS UTAMA (RGB & DRAG) ]]
-- ========================================================
local RGBElements = {}

-- Mendaftarkan objek agar warnanya berubah pelangi (RGB)
local function RegisterRGB(instance, property)
    table.insert(RGBElements, {Instance = instance, Property = property})
end

-- Loop RGB otomatis menggunakan RenderStepped
RunService.RenderStepped:Connect(function()
    local hue = (tick() % 4) / 4 -- Kecepatan transisi (4 detik)
    local rainbowColor = Color3.fromHSV(hue, 0.7, 1) -- Saturation 0.7 agar warna lebih modern
    
    for i = #RGBElements, 1, -1 do
        local item = RGBElements[i]
        if item.Instance and item.Instance.Parent then
            pcall(function()
                item.Instance[item.Property] = rainbowColor
            end)
        else
            table.remove(RGBElements, i) -- Hapus jika objek sudah dihancurkan
        end
    end
end)

-- Utilitas drag frame
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

-- ========================================================
-- [[ 2. GLOBAL SYSTEM: NOTIFICATION TOAST ]]
-- ========================================================
local NotificationGui
local function GetNotificationHolder()
    if not NotificationGui then
        NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "RGB_Notification_System"
        NotificationGui.DisplayOrder = 9999 -- Pastikan berada paling depan di layar
        NotificationGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
        
        local Holder = Instance.new("Frame", NotificationGui)
        Holder.Name = "Holder"
        Holder.Size = UDim2.new(0, 260, 1, -40)
        Holder.Position = UDim2.new(1, -280, 0, 20)
        Holder.BackgroundTransparency = 1
        
        local Layout = Instance.new("UIListLayout", Holder)
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.Padding = UDim.new(0, 8)
    end
    return NotificationGui.Holder
end

function Library:Notify(title, desc, duration)
    duration = duration or 4.5
    local Holder = GetNotificationHolder()
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 0) -- Dimulai dari tinggi 0 untuk animasi masuk
    NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true
    NotifFrame.Parent = Holder
    
    local NotifCorner = Instance.new("UICorner", NotifFrame)
    NotifCorner.CornerRadius = UDim.new(0, 6)
    
    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Thickness = 1
    NotifStroke.Parent = NotifFrame
    RegisterRGB(NotifStroke, "Color") -- Garis tepi RGB
    
    -- Judul Notifikasi
    local TitleLabel = Instance.new("TextLabel", NotifFrame)
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 10, 0, 6)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Notification"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Isi Pesan Notifikasi
    local DescLabel = Instance.new("TextLabel", NotifFrame)
    DescLabel.Size = UDim2.new(1, -20, 0, 30)
    DescLabel.Position = UDim2.new(0, 10, 0, 24)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc or "Description text."
    DescLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 10
    DescLabel.TextWrapped = true
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Animasi Masuk (Tinggi membesar secara elastis)
    TweenService:Create(NotifFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)}):Play()
    
    -- Menunggu durasi sebelum menghilang
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
-- [[ 3. METHOD: CREATE WINDOW ]]
-- ========================================================
function Library:CreateWindow(titleText, subtitleText)
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RGB_Modern_Library"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

    -- Jendela Utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 330)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    -- RGB Stroke (Garis Tepi)
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame
    RegisterRGB(MainStroke, "Color") -- Daftarkan garis tepi ke RGB engine

    -- Garis Aksen RGB di bagian paling atas window
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 3)
    AccentLine.Position = UDim2.new(0, 0, 0, 0)
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = MainFrame
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 8)
    AccentCorner.Parent = AccentLine
    RegisterRGB(AccentLine, "BackgroundColor3")

    -- Pembatas agar sudut tajam bagian bawah aksen tertutup
    local AccentPatch = Instance.new("Frame")
    AccentPatch.Size = UDim2.new(1, 0, 0, 2)
    AccentPatch.Position = UDim2.new(0, 0, 0, 2)
    AccentPatch.BorderSizePixel = 0
    AccentPatch.Parent = MainFrame
    RegisterRGB(AccentPatch, "BackgroundColor3")

    -- Drag Area (Header)
    local DragHeader = Instance.new("Frame")
    DragHeader.Size = UDim2.new(1, 0, 0, 45)
    DragHeader.BackgroundTransparency = 1
    DragHeader.Parent = MainFrame
    EnableDrag(DragHeader, MainFrame)

    -- Label Judul
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 300, 0, 20)
    TitleLabel.Position = UDim2.new(0, 15, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText or "RGB LIBRARY"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = DragHeader

    -- Label Subtitle
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 300, 0, 15)
    SubLabel.Position = UDim2.new(0, 15, 0, 26)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = subtitleText or "v1.0.0"
    SubLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    SubLabel.TextSize = 10
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = DragHeader

    -- Sidebar untuk Tab (Sisi Kiri)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -55)
    Sidebar.Position = UDim2.new(0, 10, 0, 48)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 6)
    SidebarCorner.Parent = Sidebar

    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = Color3.fromRGB(35, 35, 40)
    SidebarStroke.Thickness = 1
    SidebarStroke.Parent = Sidebar

    -- Container Tab Button
    local TabButtonContainer = Instance.new("ScrollingFrame")
    TabButtonContainer.Size = UDim2.new(1, -10, 1, -10)
    TabButtonContainer.Position = UDim2.new(0, 5, 0, 5)
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.ScrollBarThickness = 0
    TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtonContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabButtonContainer

    -- Container Konten Utama (Sisi Kanan)
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -170, 1, -55)
    ContentArea.Position = UDim2.new(0, 160, 0, 48)
    ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainFrame

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 6)
    ContentCorner.Parent = ContentArea

    local ContentStroke = Instance.new("UIStroke")
    ContentStroke.Color = Color3.fromRGB(35, 35, 40)
    ContentStroke.Thickness = 1
    ContentStroke.Parent = ContentArea

    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
    end)

    -- ========================================================
    -- [[ 4. WINDOW METHODS: TOGGLE KEYBIND ]]
    -- ========================================================
    function Window:BindToggleKey(keyCode)
        local debounce = false
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == keyCode and not debounce then
                debounce = true
                
                local targetVisibility = not MainFrame.Visible
                if targetVisibility == true then
                    MainFrame.Size = UDim2.new(0, 520, 0, 0)
                    MainFrame.Visible = true
                    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), {Size = UDim2.new(0, 520, 0, 330)}):Play()
                else
                    local t = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.In, Enum.EasingDirection.Quad), {Size = UDim2.new(0, 520, 0, 0)})
                    t:Play()
                    t.Completed:Connect(function()
                        if not MainFrame.Visible then
                            MainFrame.Visible = false
                        end
                    end)
                end
                
                task.wait(0.25)
                debounce = false
            end
        end)
    end

    -- ========================================================
    -- [[ 4b. MOBILE FRIENDLY: FLOATING TOGGLE BUTTON ]]
    -- ========================================================
    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Name = "FloatingToggleBtn"
    FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
    FloatingBtn.Position = UDim2.new(0, 20, 0.4, 0) 
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    FloatingBtn.Text = "L" 
    FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatingBtn.Font = Enum.Font.GothamBold
    FloatingBtn.TextSize = 18
    FloatingBtn.AutoButtonColor = false
    FloatingBtn.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner", FloatingBtn)
    FloatCorner.CornerRadius = UDim.new(1, 0) 

    local FloatStroke = Instance.new("UIStroke", FloatingBtn)
    FloatStroke.Thickness = 1.5
    RegisterRGB(FloatStroke, "Color") 

    EnableDrag(FloatingBtn, FloatingBtn)

    local toggleDebounce = false
    FloatingBtn.MouseButton1Click:Connect(function()
        if toggleDebounce then return end
        toggleDebounce = true
        
        local targetVisibility = not MainFrame.Visible
        if targetVisibility == true then
            MainFrame.Size = UDim2.new(0, 520, 0, 0)
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), {Size = UDim2.new(0, 520, 0, 330)}):Play()
        else
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.In, Enum.EasingDirection.Quad), {Size = UDim2.new(0, 520, 0, 0)})
            t:Play()
            t.Completed:Connect(function()
                if not MainFrame.Visible then
                    MainFrame.Visible = false
                end
            end)
        end
        
        task.wait(0.25)
        toggleDebounce = false
    end)

    -- ========================================================
    -- [[ 5. METHOD: CREATE TAB ]]
    -- ========================================================
    function Window:CreateTab(tabName, iconAssetId)
        local Tab = {}
        
        -- Frame Konten Tab (ScrollingFrame)
        local TabContentFrame = Instance.new("ScrollingFrame")
        TabContentFrame.Size = UDim2.new(1, -16, 1, -16)
        TabContentFrame.Position = UDim2.new(0, 8, 0, 8)
        TabContentFrame.BackgroundTransparency = 1
        TabContentFrame.ScrollBarThickness = 2
        TabContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContentFrame.Visible = false
        TabContentFrame.Parent = ContentArea

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContentFrame

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
        end)

        -- Tombol Tab di Sidebar
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        TabButton.Text = "" 
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabButtonContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 5)
        TabBtnCorner.Parent = TabButton

        local TabBtnStroke = Instance.new("UIStroke")
        TabBtnStroke.Color = Color3.fromRGB(40, 40, 45)
        TabBtnStroke.Thickness = 1
        TabBtnStroke.Parent = TabButton

        -- Ikon Gambar (Opsional)
        local IconLabel
        if iconAssetId then
            IconLabel = Instance.new("ImageLabel")
            IconLabel.Size = UDim2.new(0, 16, 0, 16)
            IconLabel.Position = UDim2.new(0, 8, 0.5, -8)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = iconAssetId
            IconLabel.ImageColor3 = Color3.fromRGB(150, 150, 150)
            IconLabel.Parent = TabButton
        end

        -- Label Teks Tab
        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, iconAssetId and -34 or -16, 1, 0)
        TabText.Position = UDim2.new(0, iconAssetId and 28 or 8, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = tabName
        TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabText.TextSize = 11
        TabText.Font = Enum.Font.GothamMedium
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = TabButton

        -- Ganti Tab
        local function Select()
            if Window.CurrentTab then
                Window.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                Window.CurrentTab.Text.TextColor3 = Color3.fromRGB(150, 150, 150)
                Window.CurrentTab.Frame.Visible = false
                if Window.CurrentTab.Icon then
                    Window.CurrentTab.Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            
            Window.CurrentTab = {Button = TabButton, Text = TabText, Frame = TabContentFrame, Icon = IconLabel}
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContentFrame.Visible = true
            if IconLabel then
                IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end

        TabButton.MouseButton1Click:Connect(Select)

        if not Window.CurrentTab then
            Select()
        end

        -- ========================================================
        -- [[ 5a. TAB ELEMENTS: CREATE BUTTON ]]
        -- ========================================================
        function Tab:CreateButton(buttonText, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -6, 0, 36)
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            Button.Text = "" 
            Button.AutoButtonColor = false
            Button.Parent = TabContentFrame

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 5)
            BtnCorner.Parent = Button

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(45, 45, 50)
            BtnStroke.Thickness = 1
            BtnStroke.Parent = Button

            local BtnText = Instance.new("TextLabel")
            BtnText.Size = UDim2.new(1, -20, 1, 0)
            BtnText.Position = UDim2.new(0, 10, 0, 0)
            BtnText.BackgroundTransparency = 1
            BtnText.Text = buttonText or "Button"
            BtnText.TextColor3 = Color3.fromRGB(220, 220, 220)
            BtnText.TextSize = 12
            BtnText.Font = Enum.Font.GothamMedium
            BtnText.TextXAlignment = Enum.TextXAlignment.Left
            BtnText.Parent = Button

            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Size = UDim2.new(0, 14, 0, 14)
            ArrowIcon.Position = UDim2.new(1, -22, 0.5, -7)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://6031094678" 
            ArrowIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            ArrowIcon.Parent = Button

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                local pressTween = TweenService:Create(Button, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
                pressTween:Play()
                pressTween.Completed:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
                end)

                if callback then
                    task.spawn(callback)
                end
            end)
        end

        -- ========================================================
        -- [[ 5b. TAB ELEMENTS: CREATE TOGGLE ]]
        -- ========================================================
        function Tab:CreateToggle(toggleText, defaultVal, callback)
            local Toggle = {State = defaultVal or false}

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1, -6, 0, 36)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Parent = TabContentFrame

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 5)
            ToggleCorner.Parent = ToggleBtn

            local ToggleStroke = Instance.new("UIStroke")
            ToggleStroke.Color = Color3.fromRGB(45, 45, 50)
            ToggleStroke.Thickness = 1
            ToggleStroke.Parent = ToggleBtn

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -60, 1, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = toggleText or "Toggle"
            TextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TextLabel.TextSize = 12
            TextLabel.Font = Enum.Font.GothamMedium
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = ToggleBtn

            local SwitchBg = Instance.new("Frame")
            SwitchBg.Size = UDim2.new(0, 34, 0, 18)
            SwitchBg.Position = UDim2.new(1, -44, 0.5, -9)
            SwitchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            SwitchBg.BorderSizePixel = 0
            SwitchBg.Parent = ToggleBtn

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg

            local SwitchBall = Instance.new("Frame")
            SwitchBall.Size = UDim2.new(0, 14, 0, 14)
            SwitchBall.Position = UDim2.new(0, 2, 0.5, -7)
            SwitchBall.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            SwitchBall.BorderSizePixel = 0
            SwitchBall.Parent = SwitchBg

            local BallCorner = Instance.new("UICorner")
            BallCorner.CornerRadius = UDim.new(1, 0)
            BallCorner.Parent = SwitchBall

            local function UpdateToggleVisual(animate)
                local duration = animate and 0.15 or 0
                local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if Toggle.State then
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    TweenService:Create(SwitchBg, info, {BackgroundColor3 = Color3.fromRGB(60, 160, 60)}):Play()
                else
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    TweenService:Create(SwitchBg, info, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
                end
            end

            UpdateToggleVisual(false)

            ToggleBtn.MouseButton1Click:Connect(function()
                Toggle.State = not Toggle.State
                UpdateToggleVisual(true)
                if callback then
                    task.spawn(function() callback(Toggle.State) end)
                end
            end)
        end

        -- ========================================================
        -- [[ 5c. TAB ELEMENTS: CREATE SLIDER ]]
        -- ========================================================
        function Tab:CreateSlider(sliderText, minVal, maxVal, defaultVal, callback)
            local Slider = {Value = defaultVal or minVal}
            
            local SliderBtn = Instance.new("Frame")
            SliderBtn.Size = UDim2.new(1, -6, 0, 48) 
            SliderBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            SliderBtn.Parent = TabContentFrame
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 5)
            SliderCorner.Parent = SliderBtn

            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = Color3.fromRGB(45, 45, 50)
            SliderStroke.Thickness = 1
            SliderStroke.Parent = SliderBtn

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -20, 0, 20)
            TitleLabel.Position = UDim2.new(0, 10, 0, 4)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = sliderText .. ": " .. tostring(Slider.Value)
            TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TitleLabel.TextSize = 12
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SliderBtn

            local SliderBg = Instance.new("TextButton")
            SliderBg.Size = UDim2.new(1, -20, 0, 6)
            SliderBg.Position = UDim2.new(0, 10, 1, -14)
            SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            SliderBg.Text = ""
            SliderBg.AutoButtonColor = false
            SliderBg.Parent = SliderBtn

            local BgCorner = Instance.new("UICorner")
            BgCorner.CornerRadius = UDim.new(1, 0)
            BgCorner.Parent = SliderBg

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Slider.Value - minVal) / (maxVal - minVal), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBg
            RegisterRGB(SliderFill, "BackgroundColor3") 

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill

            local sliding = false
            local function UpdateSlider(input)
                local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local rawValue = minVal + (percentage * (maxVal - minVal))
                local finalValue = math.floor(rawValue + 0.5) 
                
                Slider.Value = finalValue
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                TitleLabel.Text = sliderText .. ": " .. tostring(finalValue)
                
                if callback then
                    task.spawn(function() callback(finalValue) end)
                end
            end

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
        end

        -- ========================================================
        -- [[ 5d. TAB ELEMENTS: CREATE DROPDOWN ]]
        -- ========================================================
        function Tab:CreateDropdown(dropdownText, options, defaultVal, callback)
            local Dropdown = {
                Open = false,
                CurrentValue = defaultVal or options[1],
                OptionFrames = {}
            }
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, -6, 0, 36)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            DropdownFrame.ClipsDescendants = true 
            DropdownFrame.Parent = TabContentFrame
            
            local FrameCorner = Instance.new("UICorner")
            FrameCorner.CornerRadius = UDim.new(0, 5)
            FrameCorner.Parent = DropdownFrame

            local FrameStroke = Instance.new("UIStroke")
            FrameStroke.Color = Color3.fromRGB(45, 45, 50)
            FrameStroke.Thickness = 1
            FrameStroke.Parent = DropdownFrame

            local DropdownBtn = Instance.new("TextButton")
            DropdownBtn.Size = UDim2.new(1, 0, 0, 36)
            DropdownBtn.BackgroundTransparency = 1
            DropdownBtn.Text = ""
            DropdownBtn.Parent = DropdownFrame

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -60, 1, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = dropdownText .. " (" .. tostring(Dropdown.CurrentValue) .. ")"
            TextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TextLabel.TextSize = 12
            TextLabel.Font = Enum.Font.GothamMedium
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = DropdownBtn

            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
            ArrowIcon.Position = UDim2.new(1, -22, 0.5, -6)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://6031094670" 
            ArrowIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            ArrowIcon.Parent = DropdownBtn

            local OptionContainer = Instance.new("Frame")
            OptionContainer.Size = UDim2.new(1, -20, 0, 0)
            OptionContainer.Position = UDim2.new(0, 10, 0, 38)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.Parent = DropdownFrame

            local OptionList = Instance.new("UIListLayout")
            OptionList.Padding = UDim.new(0, 4)
            OptionList.Parent = OptionContainer

            local function RefreshDropdown()
                for _, v in ipairs(Dropdown.OptionFrames) do v:Destroy() end
                Dropdown.OptionFrames = {}

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 28)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                    OptBtn.Text = ""
                    OptBtn.AutoButtonColor = false
                    OptBtn.Parent = OptionContainer

                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 4)
                    OptCorner.Parent = OptBtn

                    local OptText = Instance.new("TextLabel")
                    OptText.Size = UDim2.new(1, -20, 1, 0)
                    OptText.Position = UDim2.new(0, 10, 0, 0)
                    OptText.BackgroundTransparency = 1
                    OptText.Text = tostring(opt)
                    OptText.TextSize = 11
                    OptText.TextXAlignment = Enum.TextXAlignment.Left
                    OptText.Parent = OptBtn

                    if opt == Dropdown.CurrentValue then
                        OptText.TextColor3 = Color3.fromRGB(255, 255, 255)
                        OptText.Font = Enum.Font.GothamBold
                        local ActiveIndicator = Instance.new("Frame")
                        ActiveIndicator.Size = UDim2.new(0, 3, 1, -8)
                        ActiveIndicator.Position = UDim2.new(0, 2, 0, 4)
                        ActiveIndicator.Parent = OptBtn
                        RegisterRGB(ActiveIndicator, "BackgroundColor3")
                        Instance.new("UICorner", ActiveIndicator)
                    else
                        OptText.TextColor3 = Color3.fromRGB(160, 160, 160)
                        OptText.Font = Enum.Font.Gotham
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
                        
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -6, 0, 36)}):Play()
                        TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        
                        RefreshDropdown()

                        if callback then
                            task.spawn(function() callback(opt) end)
                        end
                    end)

                    table.insert(Dropdown.OptionFrames, OptBtn)
                end
            end

            DropdownBtn.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                local targetHeight = 36
                local rotation = 0
                
                if Dropdown.Open then
                    RefreshDropdown()
                    targetHeight = 36 + (OptionList.AbsoluteContentSize.Y + 8)
                    rotation = 180
                end
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation = rotation}):Play()
            end)
        end

        -- ========================================================
        -- [[ 5e. TAB ELEMENTS: CREATE TEXTBOX ]]
        -- ========================================================
        function Tab:CreateTextBox(labelText, placeholderText, callback)
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Size = UDim2.new(1, -6, 0, 36)
            TextBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            TextBoxFrame.Parent = TabContentFrame
            
            local FrameCorner = Instance.new("UICorner")
            FrameCorner.CornerRadius = UDim.new(0, 5)
            FrameCorner.Parent = TextBoxFrame

            local FrameStroke = Instance.new("UIStroke")
            FrameStroke.Color = Color3.fromRGB(45, 45, 50)
            FrameStroke.Thickness = 1
            FrameStroke.Parent = TextBoxFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, -10, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = labelText or "Input Text"
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 12
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TextBoxFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0.5, -10, 0, 24)
            InputBox.Position = UDim2.new(0.5, 0, 0.5, -12)
            InputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            InputBox.Text = ""
            InputBox.PlaceholderText = placeholderText or "Type here..."
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
            InputBox.TextSize = 11
            InputBox.Font = Enum.Font.Gotham
            InputBox.ClearTextOnFocus = false
            InputBox.Parent = TextBoxFrame

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = InputBox

            local InputStroke = Instance.new("UIStroke")
            InputStroke.Color = Color3.fromRGB(50, 50, 55)
            InputStroke.Thickness = 1
            InputStroke.Parent = InputBox

            InputBox.FocusLost:Connect(function(enterPressed)
                if callback then
                    task.spawn(function() callback(InputBox.Text, enterPressed) end)
                end
            end)
        end

        -- ========================================================
        -- [[ 5f. TAB ELEMENTS: CREATE PARAGRAPH ]]
        -- ========================================================
        function Tab:CreateParagraph(titleText, descText)
            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Size = UDim2.new(1, -6, 0, 52)
            ParagraphFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            ParagraphFrame.BackgroundTransparency = 0.5
            ParagraphFrame.Parent = TabContentFrame

            local FrameCorner = Instance.new("UICorner")
            FrameCorner.CornerRadius = UDim.new(0, 5)
            FrameCorner.Parent = ParagraphFrame

            local FrameStroke = Instance.new("UIStroke")
            FrameStroke.Color = Color3.fromRGB(35, 35, 40)
            FrameStroke.Thickness = 1
            FrameStroke.Parent = ParagraphFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -20, 0, 18)
            TitleLabel.Position = UDim2.new(0, 10, 0, 6)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = titleText or "Section Title"
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextSize = 11
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = ParagraphFrame

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(1, -20, 1, -28)
            DescLabel.Position = UDim2.new(0, 10, 0, 22)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = descText or "Keterangan tambahan..."
            DescLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextSize = 10
            DescLabel.TextWrapped = true
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Parent = ParagraphFrame
        end

        return Tab
    end

    return Window
end

return Library
