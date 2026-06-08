local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

Library.Flags = {}
Library.Elements = {}
Library.ExternalButtons = {}
local ConfigFileName = "LouisHub_UI_Config.json"

function Library:SaveConfig()
    if not writefile then return end
    pcall(function()
        writefile(ConfigFileName, HttpService:JSONEncode(Library.Flags))
    end)
end

function Library:LoadConfig()
    if not isfile or not readfile then return end
    if isfile(ConfigFileName) then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile(ConfigFileName))
            for flag, val in pairs(decoded) do
                Library.Flags[flag] = val
                if Library.Elements[flag] then
                    Library.Elements[flag]:Set(val, true)
                elseif type(flag) == "string" and flag:sub(1, 7) == "ExtBtn_" then
                    local btnId = flag:sub(8)
                    local targetBtn = Library.ExternalButtons[btnId] or Library.ExternalButtons[tonumber(btnId)]
                    if targetBtn and type(val) == "table" and val.ScaleX and val.OffsetX and val.ScaleY and val.OffsetY then
                        targetBtn.Position = UDim2.new(val.ScaleX, val.OffsetX, val.ScaleY, val.OffsetY)
                    end
                end
            end
        end)
    end
end

local RGBElements = {}

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
    local hue = (os.clock() % 4) / 4
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    
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

local function EnableDrag(dragFrame, parentFrame, onDragEnd)
    local dragging, dragInput, dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if parentFrame:GetAttribute("DragLocked") then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if connection then
                        connection:Disconnect()
                    end
                    if onDragEnd then
                        onDragEnd(parentFrame.Position)
                    end
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if parentFrame:GetAttribute("DragLocked") then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if parentFrame:GetAttribute("DragLocked") then 
                dragging = false 
                return 
            end
            local delta = input.Position - dragStart
            parentFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
        MainGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    end
    return MainGui
end

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

local function StartLoading(titleText, subtitleText, onComplete)
    local ScreenGui = GetMainGui()
    
    local LoadingGui = Instance.new("Frame", ScreenGui)
    LoadingGui.Name = "Louis_Loading_Screen"
    LoadingGui.Size = UDim2.new(1, 0, 1, 0)
    LoadingGui.Position = UDim2.new(0, 0, 0, 0)
    LoadingGui.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    LoadingGui.BackgroundTransparency = 0
    LoadingGui.BorderSizePixel = 0
    LoadingGui.ZIndex = 9990

    local ProfileFrame = Instance.new("Frame", LoadingGui)
    ProfileFrame.Size = UDim2.new(0, 220, 0, 60)
    ProfileFrame.Position = UDim2.new(0, 20, 1, -80)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.ZIndex = 9995

    local ProfileImage = Instance.new("ImageLabel", ProfileFrame)
    ProfileImage.Size = UDim2.new(0, 48, 0, 48)
    ProfileImage.Position = UDim2.new(0, 0, 0.5, -24)
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
    pStroke.Thickness = 2
    pStroke.Transparency = 1
    RegisterRGB(pStroke, "Color")

    local UserInfo = Instance.new("TextLabel", ProfileFrame)
    UserInfo.Size = UDim2.new(1, -58, 1, 0)
    UserInfo.Position = UDim2.new(0, 58, 0, 0)
    UserInfo.BackgroundTransparency = 1
    UserInfo.Font = Enum.Font.MontserratBold
    UserInfo.TextColor3 = Color3.new(1, 1, 1)
    UserInfo.TextSize = 11
    UserInfo.TextXAlignment = Enum.TextXAlignment.Left
    UserInfo.RichText = true
    UserInfo.TextTransparency = 1
    UserInfo.ZIndex = 9995
    UserInfo.Text = '<font color="rgb(200, 200, 200)">MEMBER:</font>\n' .. LocalPlayer.Name:upper() .. '\n<font size="9" color="rgb(150, 150, 150)">ID: ' .. LocalPlayer.UserId .. '</font>'

    local Title = Instance.new("TextLabel", LoadingGui)
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Position = UDim2.new(0, 0, 0.35, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.MontserratBold
    Title.TextSize = 38
    Title.RichText = true
    Title.Text = (titleText or "LOUIS HUB"):upper()
    Title.TextTransparency = 1
    Title.ZIndex = 9995
    RegisterRGB(Title, "TextColor3")

    local SubTitle = Instance.new("TextLabel", LoadingGui)
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0.45, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = (subtitleText or "MODERNIZED INTERFACE"):upper()
    SubTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
    SubTitle.TextSize = 14
    SubTitle.Font = Enum.Font.MontserratBold
    SubTitle.TextTransparency = 1
    SubTitle.ZIndex = 9995

    local BarBg = Instance.new("Frame", LoadingGui)
    BarBg.Size = UDim2.new(0.5, 0, 0, 6)
    BarBg.Position = UDim2.new(0.25, 0, 0.65, 0)
    BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    BarBg.ZIndex = 9995
    Instance.new("UICorner", BarBg)
    
    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.ZIndex = 9995
    Instance.new("UICorner", BarFill)
    RegisterRGB(BarFill, "BackgroundColor3")

    local SkipBtn = Instance.new("TextButton", LoadingGui)
    SkipBtn.Size = UDim2.new(0, 120, 0, 36)
    SkipBtn.Position = UDim2.new(0.5, -60, 0.82, 0)
    SkipBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SkipBtn.Text = "SKIP"
    SkipBtn.TextColor3 = Color3.new(1, 1, 1)
    SkipBtn.Font = Enum.Font.MontserratBold
    SkipBtn.TextSize = 14
    SkipBtn.ZIndex = 10000
    SkipBtn.TextTransparency = 1
    
    local SkipCorner = Instance.new("UICorner", SkipBtn)
    SkipCorner.CornerRadius = UDim.new(0, 8)
    local SkipStroke = Instance.new("UIStroke", SkipBtn)
    SkipStroke.Color = Color3.fromRGB(45, 45, 50)
    SkipStroke.Thickness = 1

    local beepSound = Instance.new("Sound", LoadingGui)
    beepSound.SoundId = "rbxassetid://1567483853"
    beepSound.Volume = 0.6

    local function ElectricZapEffect()
        for i = 1, 3 do
            local zap = Instance.new("Frame", LoadingGui)
            zap.BackgroundColor3 = Color3.new(1, 1, 1)
            zap.BorderSizePixel = 0
            zap.Size = UDim2.new(0, math.random(50, 120), 0, 2)
            zap.Position = UDim2.new(0.5, math.random(-100, 100), 0.38, math.random(-20, 20))
            zap.Rotation = math.random(0, 360)
            zap.ZIndex = 9995
            task.spawn(function() task.wait(0.12); zap:Destroy() end)
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

        local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
        task.delay(0.45, function() 
            LoadingGui:Destroy() 
            if onComplete then onComplete() end
        end)
    end

    SkipBtn.MouseButton1Click:Connect(ForceExit)

    local entryTween = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Title, entryTween, {TextTransparency = 0}):Play()
    TweenService:Create(ProfileImage, entryTween, {ImageTransparency = 0}):Play()
    TweenService:Create(pStroke, entryTween, {Transparency = 0}):Play()
    TweenService:Create(UserInfo, entryTween, {TextTransparency = 0}):Play()
    TweenService:Create(SkipBtn, entryTween, {TextTransparency = 0}):Play()

    task.delay(1.2, function()
        if skipTriggered then return end
        TweenService:Create(SubTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        for i = 1, 6 do 
            if skipTriggered then break end
            local vis = not SubTitle.Visible
            SubTitle.Visible = vis
            Title.Visible = vis
            if vis then 
                ElectricZapEffect()
                pcall(function() beepSound:Play() end) 
            end
            task.wait(0.25)
        end
        if not skipTriggered then SubTitle.Visible = true; Title.Visible = true end
    end)

    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 6)
    
    local waitTime = 0
    while waitTime < 6.5 and not skipTriggered do
        waitTime = waitTime + 0.1
        task.wait(0.1)
    end
    if not skipTriggered then ForceExit() end
end

function Library:CreateWindow(titleText, subtitleText)
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        DragLocked = false,
        Minimized = false,
        Visible = false
    }

    local ScreenGui = GetMainGui()

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 530, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -265, 0.5, -170)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.5
    RegisterRGB(MainStroke, "Color")

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if MainFrame:GetAttribute("DragLocked") or Window.DragLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if MainFrame:GetAttribute("DragLocked") or Window.DragLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if MainFrame:GetAttribute("DragLocked") or Window.DragLocked then
                dragging = false
                return
            end
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

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

    local HeaderSeparator = Instance.new("Frame", MainFrame)
    HeaderSeparator.Size = UDim2.new(1, 0, 0, 1)
    HeaderSeparator.Position = UDim2.new(0, 0, 0, 50)
    HeaderSeparator.BorderSizePixel = 0
    RegisterRGB(HeaderSeparator, "BackgroundColor3")

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 145, 1, -65)
    Sidebar.Position = UDim2.new(0, 12, 0, 57)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = Color3.fromRGB(35, 35, 40)
    SidebarStroke.Thickness = 1

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -12, 1, -12)
    TabContainer.Position = UDim2.new(0, 6, 0, 6)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 5)

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

    local ToggleIcon = Instance.new("ImageButton", Header)
    ToggleIcon.Size = UDim2.new(0, 20, 0, 20)
    ToggleIcon.Position = UDim2.new(1, -60, 0, 15)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Image = "rbxassetid://6031094670"
    ToggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    ToggleIcon.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        local targetSize = Window.Minimized and UDim2.new(0, 530, 0, 51) or UDim2.new(0, 530, 0, 340)
        local targetRotation = Window.Minimized and 180 or 0
        
        TweenService:Create(ToggleIcon, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
        
        if Window.Minimized then
            local sidebarFade = TweenService:Create(Sidebar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
            local contentFade = TweenService:Create(ContentArea, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
            sidebarFade:Play()
            contentFade:Play()
            
            sidebarFade.Completed:Connect(function()
                if Window.Minimized then
                    Sidebar.Visible = false
                    ContentArea.Visible = false
                end
            end)
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        else
            Sidebar.Visible = true
            ContentArea.Visible = true
            TweenService:Create(Sidebar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
            TweenService:Create(ContentArea, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
            
            local expandTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize})
            expandTween:Play()
        end
    end)

    local CloseBtn = Instance.new("ImageButton", Header)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -32, 0, 15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = "rbxassetid://10734898355"
    CloseBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)

    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 75, 75)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    local FloatingToggle = Instance.new("TextButton", ScreenGui)
    FloatingToggle.Name = "FloatingToggleIcon"
    FloatingToggle.Size = UDim2.new(0, 52, 0, 52)
    FloatingToggle.Position = UDim2.new(0.5, -26, 0.5, -26)
    FloatingToggle.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    FloatingToggle.BorderSizePixel = 0
    FloatingToggle.Text = ""
    FloatingToggle.Visible = false

    local ToggleCorner = Instance.new("UICorner", FloatingToggle)
    ToggleCorner.CornerRadius = UDim.new(0, 10)

    local ToggleStroke = Instance.new("UIStroke", FloatingToggle)
    ToggleStroke.Thickness = 1.5
    RegisterRGB(ToggleStroke, "Color")

    local ToggleIconImage = Instance.new("ImageLabel", FloatingToggle)
    ToggleIconImage.Name = "Icon"
    ToggleIconImage.Size = UDim2.new(0, 26, 0, 26)
    ToggleIconImage.Position = UDim2.new(0.5, -13, 0.5, -13)
    ToggleIconImage.BackgroundTransparency = 1
    ToggleIconImage.Image = "rbxassetid://10734887784"
    ToggleIconImage.ScaleType = Enum.ScaleType.Fit
    RegisterRGB(ToggleIconImage, "ImageColor3")

    EnableDrag(FloatingToggle, FloatingToggle)

    local firstTimeOpen = true

    local function OpenGui()
        if not Window.Visible then
            Window.Visible = true
            MainFrame.Visible = true
            
            local shrinkTween = TweenService:Create(FloatingToggle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            shrinkTween:Play()
            shrinkTween.Completed:Connect(function()
                if Window.Visible then
                    FloatingToggle.Visible = false
                end
            end)
            
            MainFrame.Size = UDim2.new(0, 530, 0, 0)
            local targetHeight = Window.Minimized and 51 or 340
            TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 530, 0, targetHeight)}):Play()
        end
    end

    local function CloseGui()
        if Window.Visible then
            Window.Visible = false
            
            local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 530, 0, 0)})
            hideTween:Play()
            hideTween.Completed:Connect(function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
            
            if firstTimeOpen then
                firstTimeOpen = false
                FloatingToggle.Position = UDim2.new(0, 25, 0.5, -26)
            end
            
            FloatingToggle.Visible = true
            FloatingToggle.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(FloatingToggle, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 52, 0, 52)}):Play()
        end
    end

    FloatingToggle.MouseButton1Click:Connect(function()
        TweenService:Create(FloatingToggle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 44, 0, 44)}):Play()
        task.delay(0.1, function()
            OpenGui()
        end)
    end)

    CloseBtn.MouseButton1Click:Connect(CloseGui)

    StartLoading(titleText, subtitleText, function()
        firstTimeOpen = true
        FloatingToggle.Position = UDim2.new(0.5, -26, 0.5, -26)
        FloatingToggle.Size = UDim2.new(0, 0, 0, 0)
        FloatingToggle.Visible = true
        
        TweenService:Create(FloatingToggle, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 52, 0, 52)}):Play()

        task.spawn(function()
            task.wait(1)
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
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
        end)

        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 34)
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

        local TabBtnStroke = Instance.new("UIStroke", TabButton)
        TabBtnStroke.Color = Color3.fromRGB(40, 40, 45)
        TabBtnStroke.Thickness = 1

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
                local oldTab = Window.CurrentTab
                local fadeOut = TweenService:Create(oldTab.Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 0.9, -16), Position = UDim2.new(0, 8, 0, 18)})
                fadeOut:Play()
                fadeOut.Completed:Connect(function()
                    oldTab.Frame.Visible = false
                end)

                TweenService:Create(oldTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 33)}):Play()
                TweenService:Create(oldTab.Text, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                oldTab.Indicator.Visible = false
                if oldTab.Icon then
                    TweenService:Create(oldTab.Icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end
            
            TabContent.Size = UDim2.new(1, -16, 0.9, -16)
            TabContent.Position = UDim2.new(0, 8, 0, 18)
            TabContent.Visible = true
            TweenService:Create(TabContent, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0, 8, 0, 8)}):Play()

            Window.CurrentTab = {Button = TabButton, Text = TabText, Frame = TabContent, Icon = IconLabel, Indicator = TabIndicator}
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TabIndicator.Visible = true
            if IconLabel then
                TweenService:Create(IconLabel, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end

        TabButton.MouseButton1Click:Connect(Select)

        if not Window.CurrentTab then
            Select()
        end

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
                TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -21, 0.5, -7)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(150, 150, 150), Position = UDim2.new(1, -24, 0.5, -7)}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                local press = TweenService:Create(Button, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
                press:Play()
                press.Completed:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
                end)
                if callback then task.spawn(callback) end
            end)
        end

        function Tab:CreateToggle(toggleText, defaultVal, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = toggleText:gsub("%s+", "")
            elseif not flag then
                actualFlag = toggleText:gsub("%s+", "")
            end

            local Toggle = {State = defaultVal or false}
            Library.Flags[actualFlag] = Toggle.State

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

            local function UpdateVisual(animate, ignoreSave)
                local duration = animate and 0.25 or 0
                local info = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                
                if Toggle.State then
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    RegisterRGB(SwitchBg, "BackgroundColor3")
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(28, 28, 35)}):Play()
                else
                    UnregisterRGB(SwitchBg, "BackgroundColor3")
                    TweenService:Create(SwitchBall, info, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    TweenService:Create(SwitchBg, TweenInfo.new(duration, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                end

                Library.Flags[actualFlag] = Toggle.State
                if not ignoreSave then
                    Library:SaveConfig()
                end
            end

            UpdateVisual(false, true)

            ToggleBtn.MouseButton1Click:Connect(function()
                Toggle.State = not Toggle.State
                UpdateVisual(true)
                if actualCallback then task.spawn(function() actualCallback(Toggle.State) end) end
            end)

            local toggleController = {}
            function toggleController:Set(state, ignoreSave)
                Toggle.State = state
                UpdateVisual(true, ignoreSave)
                if actualCallback then task.spawn(function() actualCallback(Toggle.State) end) end
            end

            Library.Elements[actualFlag] = toggleController
            return toggleController
        end

        function Tab:CreateSlider(sliderText, minVal, maxVal, defaultVal, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = sliderText:gsub("%s+", "")
            elseif not flag then
                actualFlag = sliderText:gsub("%s+", "")
            end

            local Slider = {Value = defaultVal or minVal}
            Library.Flags[actualFlag] = Slider.Value
            
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

            local function UpdateVisuals(val, ignoreSave)
                Slider.Value = math.clamp(val, minVal, maxVal)
                local percentage = (Slider.Value - minVal) / (maxVal - minVal)
                
                TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                TitleLabel.Text = sliderText .. ": " .. tostring(Slider.Value)
                
                Library.Flags[actualFlag] = Slider.Value
                if not ignoreSave then
                    Library:SaveConfig()
                end
            end

            UpdateVisuals(Slider.Value, true)

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
            function sliderController:Set(val, ignoreSave)
                UpdateVisuals(val, ignoreSave)
                if actualCallback then task.spawn(function() actualCallback(Slider.Value) end) end
            end

            Library.Elements[actualFlag] = sliderController
            return sliderController
        end

        function Tab:CreateDropdown(dropdownText, options, defaultVal, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = dropdownText:gsub("%s+", "")
            elseif not flag then
                actualFlag = dropdownText:gsub("%s+", "")
            end

            local Dropdown = {
                Open = false,
                CurrentValue = defaultVal or options[1],
                OptionFrames = {}
            }
            Library.Flags[actualFlag] = Dropdown.CurrentValue
            
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
                        TweenService:Create(OptBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(38, 38, 43)}):Play()
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown.CurrentValue = opt
                        TextLabel.Text = dropdownText .. " (" .. tostring(opt) .. ")"
                        Dropdown.Open = false
                        
                        UnregisterRGB(FrameStroke, "Color")
                        FrameStroke.Color = Color3.fromRGB(45, 45, 50)
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, 38)}):Play()
                        TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                        
                        Refresh()
                        
                        Library.Flags[actualFlag] = opt
                        Library:SaveConfig()
                        
                        if actualCallback then task.spawn(function() actualCallback(opt) end) end
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
                    RegisterRGB(FrameStroke, "Color")
                    OptionContainer.Size = UDim2.new(1, -24, 0, OptionList.AbsoluteContentSize.Y)
                    targetHeight = 38 + (OptionList.AbsoluteContentSize.Y + 10)
                    rotation = 180
                else
                    UnregisterRGB(FrameStroke, "Color")
                    FrameStroke.Color = Color3.fromRGB(45, 45, 50)
                    OptionContainer.Size = UDim2.new(1, -24, 0, 0)
                end
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = rotation}):Play()
            end)

            local dropdownController = {}
            function dropdownController:Set(val, ignoreSave)
                Dropdown.CurrentValue = val
                TextLabel.Text = dropdownText .. " (" .. tostring(val) .. ")"
                
                Library.Flags[actualFlag] = val
                if not ignoreSave then
                    Library:SaveConfig()
                end
                
                if actualCallback then task.spawn(function() actualCallback(val) end) end
            end

            function dropdownController:Refresh(newOptions)
                options = newOptions
                if Dropdown.Open then
                    Refresh()
                    OptionContainer.Size = UDim2.new(1, -24, 0, OptionList.AbsoluteContentSize.Y)
                    local targetHeight = 38 + (OptionList.AbsoluteContentSize.Y + 10)
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, targetHeight)}):Play()
                end
            end
            dropdownController.Update = dropdownController.Refresh

            Library.Elements[actualFlag] = dropdownController
            return dropdownController
        end

        function Tab:CreateTextBox(labelText, placeholderText, flag, callback)
            local actualFlag = flag
            local actualCallback = callback
            
            if type(flag) == "function" then
                actualCallback = flag
                actualFlag = labelText:gsub("%s+", "")
            elseif not flag then
                actualFlag = labelText:gsub("%s+", "")
            end

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

            InputBox.Focused:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(120, 120, 130)}):Play()
                TweenService:Create(TextBoxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 35)}):Play()
            end)

            InputBox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 55)}):Play()
                TweenService:Create(TextBoxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                
                Library.Flags[actualFlag] = InputBox.Text
                Library:SaveConfig()
                
                if actualCallback then task.spawn(function() actualCallback(InputBox.Text, enterPressed) end) end
            end)

            local textboxController = {}
            function textboxController:Set(val, ignoreSave)
                InputBox.Text = tostring(val)
                
                Library.Flags[actualFlag] = val
                if not ignoreSave then
                    Library:SaveConfig()
                end
                
                if actualCallback then task.spawn(function() actualCallback(val, false) end) end
            end

            Library.Elements[actualFlag] = textboxController
            return textboxController
        end

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

function Library:CreateExternalButton(id, text, defaultPos, callback)
    local ScreenGui = GetMainGui()

    local ExtBtn = Instance.new("TextButton")
    ExtBtn.Name = "ExternalButton_" .. tostring(id)
    ExtBtn.Size = UDim2.new(0, 44, 0, 44)
    
    local savedPos = Library.Flags["ExtBtn_" .. tostring(id)]
    local finalPos = defaultPos
    if savedPos and type(savedPos) == "table" and savedPos.ScaleX then
        finalPos = UDim2.new(savedPos.ScaleX, savedPos.OffsetX, savedPos.ScaleY, savedPos.OffsetY)
    end
    ExtBtn.Position = finalPos or UDim2.new(0, 20, 0.5, 0)
    
    ExtBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    ExtBtn.BackgroundTransparency = 0.6
    ExtBtn.Text = text or "A"
    ExtBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExtBtn.Font = Enum.Font.MontserratBold
    ExtBtn.TextSize = 14
    ExtBtn.AutoButtonColor = false
    ExtBtn.Parent = ScreenGui

    Library.ExternalButtons[tostring(id)] = ExtBtn
    Library.ExternalButtons[id] = ExtBtn

    local Corner = Instance.new("UICorner", ExtBtn)
    Corner.CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", ExtBtn)
    Stroke.Thickness = 1.5
    RegisterRGB(Stroke, "Color")

    EnableDrag(ExtBtn, ExtBtn, function(finalPos)
        Library.Flags["ExtBtn_" .. tostring(id)] = {
            ScaleX = finalPos.X.Scale,
            OffsetX = finalPos.X.Offset,
            ScaleY = finalPos.Y.Scale,
            OffsetY = finalPos.Y.Offset
        }
        Library:SaveConfig()
    end)

    ExtBtn.MouseButton1Click:Connect(function()
        local origTrans = ExtBtn.BackgroundTransparency
        TweenService:Create(ExtBtn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.4}):Play()
        task.delay(0.08, function()
            TweenService:Create(ExtBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = origTrans}):Play()
        end)
        
        if callback then
            task.spawn(callback)
        end
    end)

    local buttonController = {}
    buttonController.Instance = ExtBtn

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

    function buttonController:SetDragLock(state)
        ExtBtn:SetAttribute("DragLocked", state)
    end

    return buttonController
end

return Library
