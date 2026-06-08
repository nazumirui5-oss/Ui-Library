-- [[ LOUIS HUB FREE - PROTECTED EDITION ]]
-- AUTH: Louis | LAYERS: 1, 3, 4 (Handshake, Key, Anti-Tamper)
-- VERSION: 13.5.2 (Security Sync Update - No Whitelist)

return function(AccessKey)
    -- [[ PROTEKSI 4: ANTI-TAMPER ]]
    local function IntegrityCheck()
        local test = tostring(game.HttpGet)
        if not test:find("function") or test:find("custom") or test:find("hook") then
            game.Players.LocalPlayer:Kick("LOUIS HUB: Security Violation (Hook Detected)")
            return false
        end
        return true
    end
    if not IntegrityCheck() then return end

    -- [[ PROTEKSI 3: KUNCI FUNGSI ]]
    if AccessKey ~= "LouisVIP_Secret_Key_9922" then 
        game.Players.LocalPlayer:Kick("LOUIS HUB: Bypass Detected (Key Error)")
        return 
    end

    -- [[ PROTEKSI 1: SESSION HANDSHAKE (Updated to genv) ]]
    local MyID = game.Players.LocalPlayer.UserId
    if not getgenv().LouisVerify or getgenv().LouisVerify() ~= "LouisVIP_Validated_" .. MyID then
        game.Players.LocalPlayer:Kick("LOUIS HUB: Illegal Execution (Handshake Failed)")
        return
    end

    -- [[ PROTEKSI 2: TELAH DIHAPUS ]]
    -- (Bagian Whitelist URL dan pengecekan GitHub sudah dibuang sepenuhnya)

    -- ========================================================
    -- [[ ULTIMATE ANTI-DEBUG & SPY PROTECTOR + WEBHOOK ]]
    -- ========================================================
    local SecurityRunning = true
    local w1 = "https://discord.com/api/webhooks/"
    local w2 = "1499859204670750952/"
    local w3 = "333FbG7tb63jvKPPgD_zhHt7tn0cA1Y4T3-WLG16xQPY0uc-uozPcvnnSKS32dgzzt0P"
    local WebhookURL = w1 .. w2 .. w3

    local function SendSecurityAlert(toolName)
        local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if request then
            pcall(function()
                request({
                    Url = WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = game:GetService("HttpService"):JSONEncode({
                        ["embeds"] = {{
                            ["title"] = "⚠️ SECURITY BREACH DETECTED!",
                            ["description"] = "A user tried to spy on Louis Hub FREE scripts.",
                            ["color"] = 0xFF0000,
                            ["fields"] = {
                                {["name"] = "👤 User", ["value"] = game.Players.LocalPlayer.Name, ["inline"] = true},
                                {["name"] = "🆔 ID", ["value"] = tostring(game.Players.LocalPlayer.UserId), ["inline"] = true},
                                {["name"] = "🔍 Detected Tool", ["value"] = toolName, ["inline"] = false},
                                {["name"] = "🛡️ Action", ["value"] = "Auto-Kick Executed", ["inline"] = true}
                            },
                            ["footer"] = {["text"] = "Louis Hub v13.5.2 | Anti-Tamper System"},
                            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
                        }}
                    })
                })
            end)
        end
    end

    local function UltimateSecurity()
        local LP = game:GetService("Players").LocalPlayer
        local CoreGui = game:GetService("CoreGui")
        
        local BlacklistNames = {
            "SimpleSpy", "Hydroxide", "TurtleSpy", "RemoteSpy", "Explorer", 
            "Dex", "DarkDex", "Adonis", "V.G Hub Spy", "OwlHub Spy", 
            "Postman", "ScriptDumper", "SaveInstance", "RbxSpy"
        }

        local function ScanDeeper()
            for _, name in pairs(BlacklistNames) do
                if CoreGui:FindFirstChild(name) then return true, name end
            end
            for _, obj in pairs(CoreGui:GetChildren()) do
                if obj:IsA("ScreenGui") and not obj:IsA("PluginGui") then
                    local data = tostring(obj):lower()
                    if data:find("spy") or data:find("remote") or data:find("debug") then
                        return true, obj.Name
                    end
                end
            end
            return false
        end

        task.spawn(function()
            while SecurityRunning do
                local detected, toolFound = false, ""
                pcall(function() 
                    local found, name = ScanDeeper()
                    if found then 
                        detected = true 
                        toolFound = name
                    end 
                end)
                
                if detected then
                    SecurityRunning = false
                    SendSecurityAlert(toolFound)
                    task.wait(0.1)
                    LP:Kick("\n[LOUIS HUB SECURITY]\nUnauthorized Debugging Tool Detected: " .. toolFound)
                    break
                end
                task.wait(3)
            end
        end)
    end
    UltimateSecurity()

    -- ========================================================
    -- [[ KODE UTAMA LOUIS HUB FREE ]]
    -- ========================================================
    
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    -- ==========================================
    -- [[ 2. CORE SETTINGS ]]
    -- ==========================================

    _G.MainColor = Color3.fromRGB(15, 15, 20)
    _G.AccentColor = Color3.fromRGB(0, 180, 255)
    _G.FollowEnabled = false
    _G.PredictEnabled = false 
    _G.HJEnabled = false 
    _G.FaceClassic = false 
    _G.FacePro = false 
    _G.FlickEnabled = false 
    _G.FlickActive = false
    _G.FlickStrength = 45
    _G.AutoJumpEnabled = false
    _G.WallHopDist = 2.5 
    _G.WHNormal = true 
    _G.WHInstant = false
    _G.PotatoEnabled = false

    -- FITUR BARU NON-PREMIUM GLOBALS
    _G.FOVEnabled = false
    _G.FOVValue = 70
    _G.FreezeEnabled = false
    
    -- INFINITE JUMP STATE
    _G.InfJumpEnabled = false
    _G.MaxJumpCount = 5
    _G.CurrentJumpCount = 0

    -- AUTO HOLD BOMB STATE
    _G.AutoHoldEnabled = false
    _G.AutoHoldActive = false

    -- ROTATING CROSSHAIR STATE (FREE INTEGRATION)
    _G.CrosshairEnabled = false
    _G.CurrentCrosshairStyle = 1
    _G.CrosshairRotationSpeed = 110 -- Derajat per detik

    -- SCREEN RESOLUTION (STRETCH RES) STATE (FREE INTEGRATION)
    _G.ResolutionEnabled = false
    _G.ResolutionValue = 1.00

    -- GLOBAL NILAI UKURAN (1-200)
    _G.UIScaleValue = 100
    _G.ExtScaleValue = 100

    -- FITUR BARU AUTO WALK
    _G.AutoWalkEnabled = false
    _G.AutoWalkActive = false
    _G.AutoWalkRetreatSpeed = 22

    -- FITUR BARU AUTO & MANUAL PASS BOMB
    _G.AutoPassEnabled = false
    _G.PassTargetMode = "Without Bomb" -- Pilihan: "Without Bomb" atau "With Bomb"
    _G.PassMaxDistance = 100 -- Default maksimum jarak dalam stud (1-200)
    _G.PassExternalVisible = false -- Visibility eksternal tombol oper bom

    local faceSpeed = 0.18
    local lockedTarget = nil 
    local lastHadBomb = false
    local retreatTimer = 0
    local autoWalkRetreatTimer = 0
    local targetMemory = 0 
    local bombTimer = 0 
    local isLocked = false
    local isMinimized = true 
    local hudMinimized = false
    local canWallJump = true
    local jumpDebounce = false
    local isTweening = false

    -- Performance Throttling
    local lastRaycastCheck = 0
    local lastTargetSearch = 0
    local raycastInterval = 0.1
    local searchInterval = 0.25
    local isVisibleCached = false

    -- Camera Rotation Cache
    local lastCameraRotation = Camera.CFrame
    local flickSensitivity = 0.45
    local isSticking = false
    local previewContainers = {} -- Menyimpan preview crosshair di menu untuk diputar

    local function ApplyPotato()
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 250
            Lighting.Brightness = 2
            local s = settings()
            s.Rendering.QualityLevel = 1
            s.Physics.AllowSleep = true
        end)
        task.defer(function()
            local function Clean(v)
                if not v:IsA("BasePart") and not v:IsA("MeshPart") then 
                    if v:IsA("Decal") or v:IsA("Texture") or v:IsA("Light") then v:Destroy()
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
                    return 
                end
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
                v.Reflectance = 0
                if v:IsA("MeshPart") then v.TextureID = "" end
            end
            for _, v in ipairs(workspace:GetDescendants()) do pcall(Clean, v) end
        end)
    end

    -- ==========================================
    -- [[ NOTIFICATION SYSTEM ]]
    -- ==========================================
    local function NotifyPremium()
        local sg = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(0, 200, 0, 40)
        f.Position = UDim2.new(0.5, -100, 0, -50)
        f.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Instance.new("UICorner", f)
        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1,1,1)
        t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.Text = "THIS FEATURE IS FOR PREMIUM ONLY!"
        f:TweenPosition(UDim2.new(0.5, -100, 0, 50), "Out", "Back", 0.4)
        task.delay(2, function()
            f:TweenPosition(UDim2.new(0.5, -100, 0, -50), "In", "Back", 0.4, true, function() sg:Destroy() end)
        end)
    end

    -- ==========================================
    -- [[ 1. LOADING SCREEN ]]
    -- ==========================================

    local function startLoading()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        if playerGui:FindFirstChild("LouisFREE_Loading") then
            playerGui.LouisFREE_Loading:Destroy()
        end

        local loadingGui = Instance.new("ScreenGui", playerGui)
        loadingGui.Name = "LouisFREE_Loading"
        loadingGui.IgnoreGuiInset = true
        loadingGui.DisplayOrder = 999999

        local bg = Instance.new("Frame", loadingGui)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.3
        bg.BorderSizePixel = 0

        local profileFrame = Instance.new("Frame", bg)
        profileFrame.Size = UDim2.new(0, 250, 0, 70)
        profileFrame.Position = UDim2.new(0, 20, 1, -90)
        profileFrame.BackgroundTransparency = 1

        local profileImage = Instance.new("ImageLabel", profileFrame)
        profileImage.Size = UDim2.new(0, 55, 0, 55)
        profileImage.Position = UDim2.new(0, 0, 0.5, -27)
        profileImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        profileImage.BorderSizePixel = 0
        profileImage.ImageTransparency = 1 
        profileImage.BackgroundTransparency = 1
        
        task.spawn(function()
            local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            profileImage.Image = content
        end)
        
        Instance.new("UICorner", profileImage).CornerRadius = UDim.new(1, 0)
        local pStroke = Instance.new("UIStroke", profileImage)
        pStroke.Thickness = 2
        pStroke.Color = Color3.fromRGB(0, 180, 255)
        pStroke.Transparency = 1 

        local userInfo = Instance.new("TextLabel", profileFrame)
        userInfo.Size = UDim2.new(1, -65, 1, 0)
        userInfo.Position = UDim2.new(0, 65, 0, 0)
        userInfo.BackgroundTransparency = 1
        userInfo.Font = Enum.Font.GothamBold
        userInfo.TextColor3 = Color3.new(1, 1, 1)
        userInfo.TextSize = 12
        userInfo.TextXAlignment = Enum.TextXAlignment.Left
        userInfo.RichText = true
        userInfo.TextTransparency = 1 
        userInfo.Text = '<font color="rgb(200, 200, 200)">FREE MEMBER:</font>\n' .. LocalPlayer.Name:upper() .. '\n<font size="10" color="rgb(150, 150, 150)">ID: ' .. LocalPlayer.UserId .. '</font>'

        local title = Instance.new("TextLabel", bg)
        title.Size = UDim2.new(1, 0, 0.2, 0)
        title.Position = UDim2.new(0, 0, 0.3, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 65
        title.RichText = true
        title.Text = 'LOUIS HUB <font color="rgb(255, 255, 255)">FREE</font>'
        title.TextColor3 = Color3.fromRGB(0, 180, 255)
        title.TextTransparency = 1

        local welcome = Instance.new("TextLabel", bg)
        welcome.Size = UDim2.new(1, 0, 0.1, 0)
        welcome.Position = UDim2.new(0, 0, 0.45, 0)
        welcome.BackgroundTransparency = 1
        welcome.Text = "WELCOME MY FREE MEMBERS"
        welcome.TextColor3 = Color3.new(1, 1, 1)
        welcome.TextSize = 22
        welcome.Font = Enum.Font.GothamMedium
        welcome.TextTransparency = 1

        local subTitle = Instance.new("TextLabel", bg)
        subTitle.Size = UDim2.new(1, 0, 0.1, 0)
        subTitle.Position = UDim2.new(0, 0, 0.45, 0)
        subTitle.BackgroundTransparency = 1
        subTitle.Text = "TIME BOMB DUELS SCRIPT"
        subTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        subTitle.TextSize = 24
        subTitle.Font = Enum.Font.GothamBold
        subTitle.TextTransparency = 1

        local barBg = Instance.new("Frame", bg)
        barBg.Size = UDim2.new(0.3, 0, 0.008, 0)
        barBg.Position = UDim2.new(0.35, 0, 0.62, 0)
        barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", barBg)
        
        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", barFill)

        local skipBtn = Instance.new("TextButton", bg)
        skipBtn.Size = UDim2.new(0, 100, 0, 30)
        skipBtn.Position = UDim2.new(0.5, -50, 0.9, 0)
        skipBtn.BackgroundTransparency = 1
        skipBtn.Text = "SKIP"
        skipBtn.TextColor3 = Color3.new(1, 1, 1)
        skipBtn.Font = Enum.Font.GothamBold
        skipBtn.TextSize = 16
        skipBtn.ZIndex = 1000

        local introSound = Instance.new("Sound", bg)
        introSound.SoundId = "rbxassetid://131070686"
        introSound.Volume = 2

        local beepSound = Instance.new("Sound", bg)
        beepSound.SoundId = "rbxassetid://1567483853"
        beepSound.Volume = 0.6

        local function electricZapEffect()
            for i = 1, 3 do
                local zap = Instance.new("Frame", bg)
                zap.BackgroundColor3 = Color3.new(1, 1, 1)
                zap.BorderSizePixel = 0
                zap.Size = UDim2.new(0, math.random(50, 150), 0, 2)
                zap.Position = UDim2.new(0.5, math.random(-150, 150), 0.35, math.random(-40, 40))
                zap.Rotation = math.random(0, 360)
                task.spawn(function() task.wait(0.12); zap:Destroy() end)
            end
        end

        local skipTriggered = false
        local function forceExit()
            if skipTriggered then return end
            skipTriggered = true
            introSound:Stop()
            beepSound:Stop()
            local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(bg, fadeInfo, {BackgroundTransparency = 1}):Play()
            for _, obj in ipairs(bg:GetDescendants()) do
                pcall(function()
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        TweenService:Create(obj, fadeInfo, {TextTransparency = 1}):Play()
                    elseif obj:IsA("ImageLabel") then
                        TweenService:Create(obj, fadeInfo, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
                    elseif obj:IsA("Frame") then
                        TweenService:Create(obj, fadeInfo, {BackgroundTransparency = 1}):Play()
                    elseif obj:IsA("UIStroke") then
                        TweenService:Create(obj, fadeInfo, {Transparency = 1}):Play()
                    end
                end)
            end
            task.delay(0.45, function() loadingGui:Destroy() end)
        end

        skipBtn.MouseButton1Click:Connect(forceExit)
        introSound:Play()

        task.spawn(function()
            TweenService:Create(title, TweenInfo.new(1), {TextTransparency = 0}):Play()
            TweenService:Create(welcome, TweenInfo.new(1), {TextTransparency = 0}):Play()
            TweenService:Create(profileImage, TweenInfo.new(1), {ImageTransparency = 0, BackgroundTransparency = 0}):Play()
            TweenService:Create(pStroke, TweenInfo.new(1), {Transparency = 0}):Play()
            TweenService:Create(userInfo, TweenInfo.new(1), {TextTransparency = 0}):Play()
            task.wait(2.5)
            if skipTriggered then return end
            TweenService:Create(welcome, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
            task.wait(0.8)
            if skipTriggered then return end
            TweenService:Create(subTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
            for i = 1, 6 do 
                if skipTriggered then break end
                local vis = not subTitle.Visible
                subTitle.Visible = vis
                title.Visible = vis
                if vis then electricZapEffect(); beepSound:Play() end
                task.wait(0.25)
            end
            if not skipTriggered then subTitle.Visible = true; title.Visible = true end
        end)

        barFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 7)
        local waitTime = 0
        while waitTime < 7.5 and not skipTriggered do
            waitTime = waitTime + 0.1
            task.wait(0.1)
        end
        if not skipTriggered then forceExit() end
    end

    startLoading()

    -- ==========================================
    -- [[ 3. MAIN SCRIPT GUI ]]
    -- ==========================================

    local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
    ScreenGui.Name = "LouisHub_FREE_Edition"
    ScreenGui.ResetOnSpawn = false

    -- [[ FLOATING TOGGLE (L BUTTON) ]]
    local MainVisible = false
    local ToggleBtnMain = Instance.new("TextButton", ScreenGui)
    ToggleBtnMain.Name = "FloatingToggle"
    ToggleBtnMain.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtnMain.Position = UDim2.new(0, 20, 0.5, -25)
    ToggleBtnMain.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleBtnMain.Text = "L"
    ToggleBtnMain.TextColor3 = _G.AccentColor
    ToggleBtnMain.Font = Enum.Font.GothamBlack
    ToggleBtnMain.TextSize = 25
    ToggleBtnMain.AutoButtonColor = false
    Instance.new("UICorner", ToggleBtnMain).CornerRadius = UDim.new(1, 0)
    local ToggleStroke = Instance.new("UIStroke", ToggleBtnMain)
    ToggleStroke.Color = _G.AccentColor
    ToggleStroke.Thickness = 2
    ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Floating Button Dragging
    local t_dragging, t_dragStart, t_startPos
    ToggleBtnMain.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then t_dragging = true; t_dragStart = i.Position; t_startPos = ToggleBtnMain.Position end end)
    UserInputService.InputChanged:Connect(function(i) if t_dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - t_dragStart; ToggleBtnMain.Position = UDim2.new(t_startPos.X.Scale, t_startPos.X.Offset + d.X, t_startPos.Y.Scale, t_startPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then t_dragging = false end end)

    -- [[ HUD ELEMENTS ]]
    local HUDMain = Instance.new("Frame", ScreenGui)
    HUDMain.Size = UDim2.new(0, 125, 0, 45)
    HUDMain.Position = UDim2.new(1, -140, 0.15, 0)
    HUDMain.BackgroundTransparency = 1
    HUDMain.Visible = false 

    local HUDFrame = Instance.new("Frame", HUDMain)
    HUDFrame.Size = UDim2.new(1, -20, 1, 0)
    HUDFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    HUDFrame.BackgroundTransparency = 0.6
    HUDFrame.ClipsDescendants = true
    Instance.new("UICorner", HUDFrame).CornerRadius = UDim.new(0, 6)

    local FPSLabel = Instance.new("TextLabel", HUDFrame)
    FPSLabel.Size = UDim2.new(0, 60, 0.4, 0); FPSLabel.Position = UDim2.new(0, 5, 0, 4)
    FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.new(1, 1, 1)
    FPSLabel.Font = Enum.Font.GothamBold; FPSLabel.TextSize = 9; FPSLabel.TextXAlignment = Enum.TextXAlignment.Left

    local PingLabel = Instance.new("TextLabel", HUDFrame)
    PingLabel.Size = UDim2.new(0, 60, 0.4, 0); PingLabel.Position = UDim2.new(0, 5, 0.4, 0)
    PingLabel.BackgroundTransparency = 1; PingLabel.TextColor3 = _G.AccentColor
    PingLabel.Font = Enum.Font.GothamBold; PingLabel.TextSize = 9; PingLabel.TextXAlignment = Enum.TextXAlignment.Left

    local GraphFrame = Instance.new("Frame", HUDFrame)
    GraphFrame.Size = UDim2.new(0, 35, 0, 35); GraphFrame.Position = UDim2.new(1, -75, 0, 5); GraphFrame.BackgroundTransparency = 1

    local bars = {}
    for i = 1, 10 do
        local b = Instance.new("Frame", GraphFrame)
        b.Size = UDim2.new(0, 2, 0, 10); b.Position = UDim2.new(0, i*3, 1, -10)
        b.BackgroundColor3 = _G.AccentColor; b.BorderSizePixel = 0; bars[i] = b
    end

    local PotatoToggle = Instance.new("TextButton", HUDFrame)
    PotatoToggle.Size = UDim2.new(0, 30, 0, 25); PotatoToggle.Position = UDim2.new(1, -35, 0.5, -12.5)
    PotatoToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30); PotatoToggle.Text = "🍃"; PotatoToggle.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", PotatoToggle)
    local PotatoStroke = Instance.new("UIStroke", PotatoToggle)
    PotatoStroke.Color = Color3.fromRGB(100, 100, 100)
    PotatoStroke.Thickness = 1.5

    local HUDToggleBtn = Instance.new("TextButton", HUDMain)
    HUDToggleBtn.Size = UDim2.new(0, 15, 1, 0); HUDToggleBtn.Position = UDim2.new(1, -15, 0, 0)
    HUDToggleBtn.BackgroundColor3 = Color3.new(0,0,0); HUDToggleBtn.BackgroundTransparency = 0.8; HUDToggleBtn.Text = ">"
    HUDToggleBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", HUDToggleBtn)

    HUDToggleBtn.MouseButton1Click:Connect(function()
        hudMinimized = not hudMinimized
        HUDFrame:TweenSize(hudMinimized and UDim2.new(0, 0, 1, 0) or UDim2.new(1, -20, 1, 0), "Out", "Quad", 0.3, true)
        HUDToggleBtn.Text = hudMinimized and "<" or ">"
    end)

    -- [[ MAIN FRAME SETUP ]]
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 140, 0, 0)
    MainFrame.Position = UDim2.new(0.5, -70, 0.2, 0)
    MainFrame.BackgroundColor3 = _G.MainColor; MainFrame.Active = true; MainFrame.ClipsDescendants = true
    MainFrame.Visible = false 
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = _G.AccentColor; Stroke.Thickness = 1.5

    -- UIScale objek untuk mengukur seluruh UI secara dinamis
    local MainUIScale = Instance.new("UIScale", MainFrame)
    MainUIScale.Scale = 1.0

    local function createBtn(txt, pos, size, color)
        local b = Instance.new("TextButton", MainFrame)
        b.Size = size; b.Position = pos; b.BackgroundColor3 = color or Color3.fromRGB(30, 30, 35); b.TextColor3 = Color3.new(1,1,1)
        b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 6.5; b.ClipsDescendants = true
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4); return b
    end

    local function createLabel(txt, pos, size)
        local l = Instance.new("TextLabel", MainFrame)
        l.Size = size or UDim2.new(0, 128, 0, 10); l.Position = pos
        l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = Color3.fromRGB(200, 200, 200)
        l.TextSize = 7; l.Font = Enum.Font.GothamBold; return l
    end

    local function createLine(pos)
        local l = Instance.new("Frame", MainFrame)
        l.Size = UDim2.new(0, 128, 0, 1); l.Position = pos
        l.BackgroundColor3 = Color3.fromRGB(45, 45, 55); l.BorderSizePixel = 0; return l
    end

    local HubLabel = createLabel("LOUIS HUB FREE V13.5.2", UDim2.new(0, 6, 0, 4), UDim2.new(0, 128, 0, 12))
    HubLabel.TextColor3 = _G.AccentColor; HubLabel.TextSize = 6.5

    local ToggleBtn = createBtn("[Q] AUTO: OFF", UDim2.new(0, 6, 0, 18), UDim2.new(0, 98, 0, 20))
    local LockBtn = createBtn("🔓", UDim2.new(0, 108, 0, 18), UDim2.new(0, 26, 0, 20))

    -- [[ MENU INFO & SOSMED ]]
    local InfoBtn = createBtn("i", UDim2.new(0, 108, 0, 4), UDim2.new(0, 26, 0, 12), Color3.fromRGB(45, 45, 55))
    InfoBtn.TextSize = 8
    InfoBtn.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold

    local InfoFrame = Instance.new("Frame", MainFrame)
    InfoFrame.Size = UDim2.new(1, -12, 0, 0)
    InfoFrame.Position = UDim2.new(0, 6, 0, 45)
    InfoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    InfoFrame.BorderSizePixel = 0
    InfoFrame.ClipsDescendants = true
    InfoFrame.Visible = false
    InfoFrame.ZIndex = 10
    Instance.new("UICorner", InfoFrame)
    local InfoStroke = Instance.new("UIStroke", InfoFrame)
    InfoStroke.Color = _G.AccentColor
    InfoStroke.Thickness = 1

    local function createInfoLabel(txt, pos, color)
        local l = Instance.new("TextLabel", InfoFrame)
        l.Size = UDim2.new(1, 0, 0, 12); l.Position = pos; l.BackgroundTransparency = 1; l.Text = txt
        l.TextColor3 = color or Color3.new(1,1,1); l.Font = Enum.Font.GothamBold; l.TextSize = 7; return l
    end

    createInfoLabel("--- SOCIAL MEDIA ---", UDim2.new(0, 0, 0, 5), _G.AccentColor)

    local function createSocialBtn(name, link, pos, color)
        local b = createBtn(name, pos, UDim2.new(1, -10, 0, 18), color)
        b.Parent = InfoFrame; b.TextSize = 6; b.ZIndex = 11
        b.MouseButton1Click:Connect(function()
            setclipboard(link)
            local oldText = b.Text; b.Text = "COPIED TO CLIPBOARD!"; task.wait(1.5); b.Text = oldText
        end)
    end

    createSocialBtn("DISCORD SERVER", "https://discord.gg/P2FEVBz2PG", UDim2.new(0, 5, 0, 25), Color3.fromRGB(88, 101, 242))
    createSocialBtn("TIKTOK: @louistimebombduels", "https://www.tiktok.com/@louistimebombduels", UDim2.new(0, 5, 0, 48), Color3.fromRGB(0, 0, 0))
    createSocialBtn("TIKTOK: @chillajakaliye_", "https://www.tiktok.com/@chillajakaliye_", UDim2.new(0, 5, 0, 71), Color3.fromRGB(0, 0, 0))

    local CloseInfo = createBtn("BACK TO MENU", UDim2.new(0, 5, 1, -22), UDim2.new(1, -10, 0, 18), Color3.fromRGB(40, 40, 45))
    CloseInfo.Parent = InfoFrame; CloseInfo.ZIndex = 11

    local infoOpen = false
    InfoBtn.MouseButton1Click:Connect(function()
        infoOpen = not infoOpen
        if infoOpen then
            InfoFrame.Visible = true
            InfoFrame:TweenSize(UDim2.new(1, -12, 1, -55), "Out", "Quad", 0.3, true)
        else
            InfoFrame:TweenSize(UDim2.new(1, -12, 0, 0), "In", "Quad", 0.3, true, function() InfoFrame.Visible = false end)
        end
    end)

    CloseInfo.MouseButton1Click:Connect(function()
        infoOpen = false
        InfoFrame:TweenSize(UDim2.new(1, -12, 0, 0), "In", "Quad", 0.3, true, function() InfoFrame.Visible = false end)
    end)

    -- MEMBUAT CONTENT FRAME MENJASI SCROLLING FRAME AGAR MUAT DI DALAM GUI LAMA
    local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
    ContentFrame.Size = UDim2.new(1, 0, 1, -61)
    ContentFrame.Position = UDim2.new(0, 0, 0, 45)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Visible = false
    ContentFrame.ScrollBarThickness = 0
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 850) -- Canvas diperluas untuk menampung fitur baru

    -- [[ BUTTONS WITH PREMIUM TAGS ]]
    local ModeBtn = createBtn("[E] MODE: CLASSIC (PREMIUM)", UDim2.new(0, 6, 0, 0), UDim2.new(0, 128, 0, 20)); ModeBtn.Parent = ContentFrame
    local FlickBtn = createBtn("[Z] FLICK: OFF", UDim2.new(0, 6, 0, 25), UDim2.new(0, 62, 0, 20)); FlickBtn.Parent = ContentFrame
    local HJBtn = createBtn("[X] HJ: OFF (PREMIUM)", UDim2.new(0, 72, 0, 25), UDim2.new(0, 62, 0, 20)); HJBtn.Parent = ContentFrame

    -- FLICK STRENGTH SLIDER (5-90) (FREE / UNLOCKED)
    local FlickSliderLabel = createLabel("FLICK STRENGTH (5-90)", UDim2.new(0, 6, 0, 50))
    FlickSliderLabel.Parent = ContentFrame
    local FlickSliderFrame = Instance.new("Frame", ContentFrame)
    FlickSliderFrame.Size = UDim2.new(0, 128, 0, 12)
    FlickSliderFrame.Position = UDim2.new(0, 6, 0, 62)
    FlickSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", FlickSliderFrame)
    
    local FlickSliderFill = Instance.new("Frame", FlickSliderFrame)
    FlickSliderFill.BackgroundColor3 = _G.AccentColor
    Instance.new("UICorner", FlickSliderFill)
    
    local FlickSliderText = Instance.new("TextLabel", FlickSliderFrame)
    FlickSliderText.Size = UDim2.new(1, 0, 1, 0)
    FlickSliderText.BackgroundTransparency = 1
    FlickSliderText.TextColor3 = Color3.new(1, 1, 1)
    FlickSliderText.TextSize = 7
    FlickSliderText.Font = Enum.Font.GothamBold

    local function syncFlickSlider(val)
        FlickSliderFill.Size = UDim2.new(math.clamp((val - 5) / 85, 0, 1), 0, 1, 0)
        FlickSliderText.Text = string.format("%.0f DEGREES", val)
    end
    syncFlickSlider(_G.FlickStrength)

    FlickSliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moveConn; moveConn = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                    local pos = math.clamp((move.Position.X - FlickSliderFrame.AbsolutePosition.X) / FlickSliderFrame.AbsoluteSize.X, 0, 1)
                    _G.FlickStrength = math.floor(5 + (pos * 85))
                    syncFlickSlider(_G.FlickStrength)
                end
            end)
            UserInputService.InputEnded:Connect(function(ended)
                if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
                    moveConn:Disconnect()
                end
            end)
        end
    end)

    -- TOMBOL AUTO JUMP (PREMIUM) & TOMBOL AUTO WALK (FREE)
    local AutoJumpBtn = createBtn("[C] JUMP: PREMIUM", UDim2.new(0, 6, 0, 80), UDim2.new(0, 62, 0, 20)); AutoJumpBtn.Parent = ContentFrame
    local AutoWalkBtn = createBtn("[T] AUTO WALK: OFF", UDim2.new(0, 72, 0, 80), UDim2.new(0, 62, 0, 20)); AutoWalkBtn.Parent = ContentFrame

    -- TOMBOL MULTI JUMP & AUTO HOLD BOMB (FREE / UNLOCKED)
    local InfJumpBtn = createBtn("[K] INF JUMP: OFF", UDim2.new(0, 6, 0, 105), UDim2.new(0, 62, 0, 20)); InfJumpBtn.Parent = ContentFrame
    local AutoHoldBtn = createBtn("[J] AUTO HOLD: OFF", UDim2.new(0, 72, 0, 105), UDim2.new(0, 62, 0, 20)); AutoHoldBtn.Parent = ContentFrame
    
    -- SLIDER JUMP LIMIT (2-10) (FREE / UNLOCKED)
    createLabel("MAX JUMPS (2-10)", UDim2.new(0, 6, 0, 130)).Parent = ContentFrame
    local JumpSliderFrame = Instance.new("Frame", ContentFrame)
    JumpSliderFrame.Size = UDim2.new(0, 128, 0, 12)
    JumpSliderFrame.Position = UDim2.new(0, 6, 0, 142)
    JumpSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", JumpSliderFrame)
    
    local JumpSliderFill = Instance.new("Frame", JumpSliderFrame)
    JumpSliderFill.BackgroundColor3 = _G.AccentColor
    Instance.new("UICorner", JumpSliderFill)
    
    local JumpSliderText = Instance.new("TextLabel", JumpSliderFrame)
    JumpSliderText.Size = UDim2.new(1, 0, 1, 0)
    JumpSliderText.BackgroundTransparency = 1
    JumpSliderText.TextColor3 = Color3.new(1, 1, 1)
    JumpSliderText.TextSize = 7
    JumpSliderText.Font = Enum.Font.GothamBold

    local function syncJumpSlider(val)
        JumpSliderFill.Size = UDim2.new(math.clamp((val - 2) / 8, 0, 1), 0, 1, 0)
        JumpSliderText.Text = string.format("%d JUMPS", val)
    end
    syncJumpSlider(_G.MaxJumpCount)

    JumpSliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moveConn; moveConn = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                    local pos = math.clamp((move.Position.X - JumpSliderFrame.AbsolutePosition.X) / JumpSliderFrame.AbsoluteSize.X, 0, 1)
                    _G.MaxJumpCount = math.floor(2 + (pos * 8))
                    syncJumpSlider(_G.MaxJumpCount)
                end
            end)
            UserInputService.InputEnded:Connect(function(ended)
                if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
                    moveConn:Disconnect()
                end
            end)
        end
    end)

    local InfJumpWarning = createLabel("WARNING: This feature has a risk of getting banned if you use this feature too often", UDim2.new(0, 6, 0, 157), UDim2.new(0, 128, 0, 20))
    InfJumpWarning.TextColor3 = Color3.fromRGB(255, 75, 75)
    InfJumpWarning.TextWrapped = true
    InfJumpWarning.TextSize = 5.5
    InfJumpWarning.Parent = ContentFrame

    -- Shift 45px ke bawah untuk seluruh elemen di scrolling frame
    createLine(UDim2.new(0, 6, 0, 182)).Parent = ContentFrame 
    createLabel("FACES MODE", UDim2.new(0, 6, 0, 188)).Parent = ContentFrame
    local ClassicBtn = createBtn("[G] CLASSIC: OFF (PREMIUM)", UDim2.new(0, 6, 0, 200), UDim2.new(0, 62, 0, 20)); ClassicBtn.Parent = ContentFrame
    local ProBtn = createBtn("[H] PRO: OFF (PREMIUM)", UDim2.new(0, 72, 0, 200), UDim2.new(0, 62, 0, 20)); ProBtn.Parent = ContentFrame

    createLine(UDim2.new(0, 6, 0, 226)).Parent = ContentFrame
    createLabel("WALLHOP MODE", UDim2.new(0, 6, 0, 232)).Parent = ContentFrame
    local WHNormalBtn = createBtn("NORMAL (PREMIUM)", UDim2.new(0, 6, 0, 244), UDim2.new(0, 62, 0, 20), _G.WHNormal and _G.AccentColor or nil); WHNormalBtn.Parent = ContentFrame
    local WHInstantBtn = createBtn("INSTANT (PREMIUM)", UDim2.new(0, 72, 0, 244), UDim2.new(0, 62, 0, 20)); WHInstantBtn.Parent = ContentFrame

    createLabel("WALLHOP DISTANCE (PREMIUM)", UDim2.new(0, 6, 0, 269)).Parent = ContentFrame
    local SliderFrame = Instance.new("Frame", ContentFrame); SliderFrame.Size = UDim2.new(0, 128, 0, 12); SliderFrame.Position = UDim2.new(0, 6, 0, 281); SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", SliderFrame)
    local SliderFill = Instance.new("Frame", SliderFrame); SliderFill.BackgroundColor3 = _G.AccentColor; Instance.new("UICorner", SliderFill)
    local SliderText = Instance.new("TextLabel", SliderFrame); SliderText.Size = UDim2.new(1, 0, 1, 0); SliderText.BackgroundTransparency = 1; SliderText.TextColor3 = Color3.new(1, 1, 1); SliderText.TextSize = 7; SliderText.Font = Enum.Font.GothamBold

    -- CAMERA SETTINGS (FREE / NON-PREMIUM)
    createLine(UDim2.new(0, 6, 0, 300)).Parent = ContentFrame
    createLabel("CAMERA SETTINGS", UDim2.new(0, 6, 0, 306)).Parent = ContentFrame
    
    local FOVBtn = createBtn("[I] FOV: OFF", UDim2.new(0, 6, 0, 318), UDim2.new(0, 128, 0, 20)); FOVBtn.Parent = ContentFrame

    -- SLIDER FOV (1-200)
    local FOVSliderFrame = Instance.new("Frame", ContentFrame); FOVSliderFrame.Size = UDim2.new(0, 128, 0, 12); FOVSliderFrame.Position = UDim2.new(0, 6, 0, 343); FOVSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", FOVSliderFrame)
    local FOVSliderFill = Instance.new("Frame", FOVSliderFrame); FOVSliderFill.BackgroundColor3 = _G.AccentColor; Instance.new("UICorner", FOVSliderFill)
    local FOVSliderText = Instance.new("TextLabel", FOVSliderFrame); FOVSliderText.Size = UDim2.new(1, 0, 1, 0); FOVSliderText.BackgroundTransparency = 1; FOVSliderText.TextColor3 = Color3.new(1, 1, 1); FOVSliderText.TextSize = 7; FOVSliderText.Font = Enum.Font.GothamBold

    -- FREEZE / LAG SYSTEM (FREE / NON-PREMIUM)
    createLine(UDim2.new(0, 6, 0, 360)).Parent = ContentFrame
    createLabel("FREEZE / LAG SIMULATOR", UDim2.new(0, 6, 0, 366)).Parent = ContentFrame
    local FreezeBtn = createBtn("[O] FREEZE BUTTON: OFF", UDim2.new(0, 6, 0, 378), UDim2.new(0, 128, 0, 20)); FreezeBtn.Parent = ContentFrame

    -- ========================================================
    -- [[ INTEGRATED ROTATING CROSSHAIR SETTINGS (FREE 1-5 ONLY) ]]
    -- ========================================================
    createLine(UDim2.new(0, 6, 0, 403)).Parent = ContentFrame
    createLabel("ROTATING CROSSHAIR SETTINGS", UDim2.new(0, 6, 0, 409)).Parent = ContentFrame
    local CrosshairBtn = createBtn("[U] CROSSHAIR: OFF", UDim2.new(0, 6, 0, 421), UDim2.new(0, 128, 0, 20)); CrosshairBtn.Parent = ContentFrame

    local CrosshairScroll = Instance.new("ScrollingFrame", ContentFrame)
    CrosshairScroll.Size = UDim2.new(0, 128, 0, 120)
    CrosshairScroll.Position = UDim2.new(0, 6, 0, 446)
    CrosshairScroll.BackgroundTransparency = 0.92
    CrosshairScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CrosshairScroll.BorderSizePixel = 0
    CrosshairScroll.CanvasSize = UDim2.new(0, 0, 0, 450)
    CrosshairScroll.ScrollBarThickness = 2
    CrosshairScroll.ScrollBarImageColor3 = _G.AccentColor

    local Grid = Instance.new("UIGridLayout", CrosshairScroll)
    Grid.CellSize = UDim2.new(0, 56, 0, 50)
    Grid.CellPadding = UDim2.new(0, 6, 0, 6)

    -- [[ CUSTOM CENTER ROTATING CROSSHAIR (FREE INTEGRATION) ]]
    local CrosshairGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
    CrosshairGui.Name = "LouisHub_FREE_Crosshair"
    CrosshairGui.ResetOnSpawn = false
    CrosshairGui.IgnoreGuiInset = true
    CrosshairGui.DisplayOrder = 10000000

    local CrosshairContainer = Instance.new("Frame", CrosshairGui)
    CrosshairContainer.Size = UDim2.new(0, 60, 0, 60)
    CrosshairContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrosshairContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairContainer.BackgroundTransparency = 1
    CrosshairContainer.Visible = false

    -- DETIL PEMBUATAN 15 MODEL CROSSHAIR
    local function buildCrosshair(container, styleId, m)
        container:ClearAllChildren()
        
        -- Style 1: Neon Cyan Quad-Dash
        if styleId == 1 then
            local color = Color3.fromRGB(0, 255, 255)
            local function makeLine(p, s, a)
                local f = Instance.new("Frame", container)
                f.Size = s; f.Position = p; f.AnchorPoint = a
                f.BackgroundColor3 = color; f.BorderSizePixel = 0
            end
            makeLine(UDim2.new(0.5, 0, 0.5, -12 * m), UDim2.new(0, 2 * m, 0, 8 * m), Vector2.new(0.5, 1))
            makeLine(UDim2.new(0.5, 0, 0.5, 12 * m), UDim2.new(0, 2 * m, 0, 8 * m), Vector2.new(0.5, 0))
            makeLine(UDim2.new(0.5, -12 * m, 0.5, 0), UDim2.new(0, 8 * m, 0, 2 * m), Vector2.new(1, 0.5))
            makeLine(UDim2.new(0.5, 12 * m, 0.5, 0), UDim2.new(0, 8 * m, 0, 2 * m), Vector2.new(0, 0.5))

        -- Style 2: Hot Pink Tri-Spike
        elseif styleId == 2 then
            local color = Color3.fromRGB(255, 0, 127)
            for i = 1, 3 do
                local line = Instance.new("Frame", container)
                line.Size = UDim2.new(0, 2 * m, 0, 8 * m)
                line.Position = UDim2.new(0.5, 0, 0.5, 0)
                line.AnchorPoint = Vector2.new(0.5, 1.8)
                line.Rotation = (i - 1) * 120
                line.BackgroundColor3 = color; line.BorderSizePixel = 0
            end

        -- Style 3: Hollow Circle Yellow
        elseif styleId == 3 then
            local circle = Instance.new("Frame", container)
            circle.Name = "Circle"
            circle.Size = UDim2.new(0, 24 * m, 0, 24 * m)
            circle.Position = UDim2.new(0.5, 0, 0.5, 0)
            circle.AnchorPoint = Vector2.new(0.5, 0.5)
            circle.BackgroundTransparency = 1
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            local s = Instance.new("UIStroke", circle)
            s.Thickness = math.max(1.5, 2 * m); s.Color = Color3.fromRGB(255, 255, 0)

        -- Style 4: Neon Green Square Brackets
        elseif styleId == 4 then
            local color = Color3.fromRGB(0, 255, 0)
            local offsets = {{-10 * m, -10 * m}, {6 * m, -10 * m}, {-10 * m, 6 * m}, {6 * m, 6 * m}}
            for _, o in ipairs(offsets) do
                local f = Instance.new("Frame", container)
                f.Name = "Bracket"
                f.Size = UDim2.new(0, 4 * m, 0, 4 * m)
                f.Position = UDim2.new(0.5, o[1], 0.5, o[2])
                f.BackgroundColor3 = color; f.BorderSizePixel = 0
                f:SetAttribute("OrigOffset", Vector2.new(o[1]/m, o[2]/m))
            end

        -- Style 5: Sunset Orange Dual-Arc
        elseif styleId == 5 then
            local color = Color3.fromRGB(255, 128, 0)
            local left = Instance.new("Frame", container)
            left.Size = UDim2.new(0, 2 * m, 0, 16 * m); left.Position = UDim2.new(0.5, -12 * m, 0.5, 0)
            left.AnchorPoint = Vector2.new(0.5, 0.5); left.BackgroundColor3 = color; left.BorderSizePixel = 0
            Instance.new("UICorner", left).CornerRadius = UDim.new(1, 0)

            local right = Instance.new("Frame", container)
            right.Size = UDim2.new(0, 2 * m, 0, 16 * m); right.Position = UDim2.new(0.5, 12 * m, 0.5, 0)
            right.AnchorPoint = Vector2.new(0.5, 0.5); right.BackgroundColor3 = color; right.BorderSizePixel = 0
            Instance.new("UICorner", right).CornerRadius = UDim.new(1, 0)

        -- Style 6: Purple Shuriken
        elseif styleId == 6 then
            local color = Color3.fromRGB(170, 0, 255)
            local offsets = {{0, -12 * m}, {0, 12 * m}, {-12 * m, 0}, {12 * m, 0}}
            for _, o in ipairs(offsets) do
                local s = Instance.new("Frame", container)
                s.Size = UDim2.new(0, 5 * m, 0, 5 * m)
                s.Position = UDim2.new(0.5, o[1], 0.5, o[2])
                s.AnchorPoint = Vector2.new(0.5, 0.5); s.Rotation = 45
                s.BackgroundColor3 = color; s.BorderSizePixel = 0
            end

        -- Style 7: Ice Blue Octagon Dots
        elseif styleId == 7 then
            local color = Color3.fromRGB(150, 220, 255)
            for i = 1, 8 do
                local angle = (i - 1) * 45
                local rad = math.rad(angle)
                local dist = 12 * m
                local d = Instance.new("Frame", container)
                d.Name = "Dot"
                d.Size = UDim2.new(0, 3 * m, 0, 3 * m)
                d.Position = UDim2.new(0.5, dist * math.cos(rad), 0.5, dist * math.sin(rad))
                d.AnchorPoint = Vector2.new(0.5, 0.5); d.BackgroundColor3 = color; d.BorderSizePixel = 0
                Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
                d:SetAttribute("Index", i)
            end

        -- Style 8: Hazard Warning (Orange Stripes)
        elseif styleId == 8 then
            local color = Color3.fromRGB(255, 100, 0)
            for i = 1, 3 do
                local w = Instance.new("Frame", container)
                w.Size = UDim2.new(0, 4 * m, 0, 10 * m)
                w.Position = UDim2.new(0.5, 0, 0.5, 0)
                w.AnchorPoint = Vector2.new(0.5, 1.6); w.Rotation = (i - 1) * 120
                w.BackgroundColor3 = color; w.BorderSizePixel = 0
            end

        -- Style 9: Target Ring with Corner Markers
        elseif styleId == 9 then
            local color = Color3.fromRGB(255, 0, 0)
            local circle = Instance.new("Frame", container)
            circle.Name = "Circle"
            circle.Size = UDim2.new(0, 14 * m, 0, 14 * m); circle.Position = UDim2.new(0.5, 0, 0.5, 0)
            circle.AnchorPoint = Vector2.new(0.5, 0.5); circle.BackgroundTransparency = 1
            local st = Instance.new("UIStroke", circle); st.Thickness = 1; st.Color = color
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local offsets = {{-12 * m, -12 * m}, {10 * m, -12 * m}, {-12 * m, 10 * m}, {10 * m, 10 * m}}
            for _, o in ipairs(offsets) do
                local f = Instance.new("Frame", container)
                f.Name = "Corner"
                f.Size = UDim2.new(0, 2 * m, 0, 2 * m); f.Position = UDim2.new(0.5, o[1], 0.5, o[2])
                f.BackgroundColor3 = color; f.BorderSizePixel = 0
                f:SetAttribute("OrigOffset", Vector2.new(o[1]/m, o[2]/m))
            end

        -- Style 10: Cyber Hexagon Magenta
        elseif styleId == 10 then
            local color = Color3.fromRGB(255, 0, 255)
            for i = 1, 6 do
                local angle = (i - 1) * 60
                local rad = math.rad(angle)
                local dist = 13 * m
                local line = Instance.new("Frame", container)
                line.Name = "HexLine"
                line.Size = UDim2.new(0, 2 * m, 0, 5 * m)
                line.Position = UDim2.new(0.5, dist * math.cos(rad), 0.5, dist * math.sin(rad))
                line.AnchorPoint = Vector2.new(0.5, 0.5); line.Rotation = angle
                line.BackgroundColor3 = color; line.BorderSizePixel = 0
                
                line:SetAttribute("BaseAngle", angle)
                line:SetAttribute("SpeedMult", (i % 2 == 0) and -1 or 1.2)
            end

        -- Style 11: Vibrant Red Double-Cross (Expanding target style)
        elseif styleId == 11 then
            local color = Color3.fromRGB(255, 50, 50)
            for i = 1, 4 do
                local angle = (i - 1) * 90
                local rad = math.rad(angle)
                local line = Instance.new("Frame", container)
                line.Name = "Line"
                line.Size = UDim2.new(0, 2 * m, 0, 6 * m)
                line.Position = UDim2.new(0.5, 14 * m * math.cos(rad), 0.5, 14 * m * math.sin(rad))
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.Rotation = angle
                line.BackgroundColor3 = color; line.BorderSizePixel = 0
                line:SetAttribute("OrigOffset", Vector2.new(14 * math.cos(rad), 14 * math.sin(rad)))
            end

        -- Style 12: Golden Concentric Dual-Rings
        elseif styleId == 12 then
            local color = Color3.fromRGB(255, 215, 0)
            local inner = Instance.new("Frame", container)
            inner.Name = "Inner"
            inner.Size = UDim2.new(0, 12 * m, 0, 12 * m)
            inner.Position = UDim2.new(0.5, 0, 0.5, 0)
            inner.AnchorPoint = Vector2.new(0.5, 0.5)
            inner.BackgroundTransparency = 1
            Instance.new("UICorner", inner).CornerRadius = UDim.new(1, 0)
            local s1 = Instance.new("UIStroke", inner)
            s1.Thickness = 1.5; s1.Color = color

            local outer = Instance.new("Frame", container)
            outer.Name = "Outer"
            outer.Size = UDim2.new(0, 24 * m, 0, 24 * m)
            outer.Position = UDim2.new(0.5, 0, 0.5, 0)
            outer.AnchorPoint = Vector2.new(0.5, 0.5)
            outer.BackgroundTransparency = 1
            Instance.new("UICorner", outer).CornerRadius = UDim.new(1, 0)
            local s2 = Instance.new("UIStroke", outer)
            s2.Thickness = 1; s2.Color = color

        -- Style 13: Green Sweeper (Radar style pointer)
        elseif styleId == 13 then
            local color = Color3.fromRGB(0, 255, 128)
            local ring = Instance.new("Frame", container)
            ring.Size = UDim2.new(0, 22 * m, 0, 22 * m)
            ring.Position = UDim2.new(0.5, 0, 0.5, 0)
            ring.AnchorPoint = Vector2.new(0.5, 0.5)
            ring.BackgroundTransparency = 1
            Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
            local s = Instance.new("UIStroke", ring)
            s.Thickness = 1; s.Color = color; s.Transparency = 0.5

            local line = Instance.new("Frame", container)
            line.Name = "SweepLine"
            line.Size = UDim2.new(0, 1.5 * m, 0, 10 * m)
            line.Position = UDim2.new(0.5, 0, 0.5, 0)
            line.AnchorPoint = Vector2.new(0.5, 1)
            line.BackgroundColor3 = color; line.BorderSizePixel = 0

        -- Style 14: Orange Helix (Hazard Orbital Spinner)
        elseif styleId == 14 then
            local color = Color3.fromRGB(255, 140, 0)
            for i = 1, 3 do
                local angle = (i - 1) * 120
                local rad = math.rad(angle)
                local arc = Instance.new("Frame", container)
                arc.Name = "ArcPart"
                arc.Size = UDim2.new(0, 8 * m, 0, 2.5 * m)
                arc.Position = UDim2.new(0.5, 10 * m * math.cos(rad), 0.5, 10 * m * math.sin(rad))
                arc.AnchorPoint = Vector2.new(0.5, 0.5)
                arc.Rotation = angle + 45
                arc.BackgroundColor3 = color; arc.BorderSizePixel = 0
                Instance.new("UICorner", arc)
                arc:SetAttribute("BaseAngle", angle)
            end

        -- Style 15: Cyber HUD Tech focus (Square corners + Dot)
        elseif styleId == 15 then
            local color = Color3.fromRGB(0, 180, 255)
            local dot = Instance.new("Frame", container)
            dot.Size = UDim2.new(0, 3 * m, 0, 3 * m)
            dot.Position = UDim2.new(0.5, 0, 0.5, 0)
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.BackgroundColor3 = color; dot.BorderSizePixel = 0
            Instance.new("UICorner", dot)

            local bracketPositions = {
                {-8 * m, -8 * m}, {8 * m, -8 * m},
                {-8 * m, 8 * m}, {8 * m, 8 * m}
            }
            for _, p in ipairs(bracketPositions) do
                local b = Instance.new("Frame", container)
                b.Name = "HUDBracket"
                b.Size = UDim2.new(0, 4 * m, 0, 4 * m)
                b.Position = UDim2.new(0.5, p[1], 0.5, p[2])
                b.AnchorPoint = Vector2.new(0.5, 0.5)
                b.BackgroundColor3 = color; b.BorderSizePixel = 0
                b:SetAttribute("OrigOffset", Vector2.new(p[1]/m, p[2]/m))
            end
        end
    end

    -- ANIMASI DETAIL DYNAMIC CROSSHAIR
    local function updateCrosshairAnimation(container, styleId, m, t)
        local rotAngle = (t * _G.CrosshairRotationSpeed) % 360
        container.Size = UDim2.new(0, 60 * m, 0, 60 * m)
        container.Rotation = rotAngle

        if styleId == 1 then
            container.Rotation = rotAngle
        elseif styleId == 2 then
            container.Rotation = -rotAngle
        elseif styleId == 3 then
            local pulsate = 1 + math.sin(t * 6) * 0.15
            container.Size = UDim2.new(0, 60 * m * pulsate, 0, 60 * m * pulsate)
            container.Rotation = rotAngle
            local circ = container:FindFirstChild("Circle")
            if circ then
                local st = circ:FindFirstChildOfClass("UIStroke")
                if st then
                    local colorFactor = (math.sin(t * 4) + 1) / 2
                    st.Color = Color3.fromRGB(255, math.floor(255 * (1 - colorFactor)), 0)
                end
            end
        elseif styleId == 4 then
            container.Rotation = -rotAngle * 0.5
            local expand = 1 + math.sin(t * 8) * 0.25
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "Bracket" then
                    local orig = child:GetAttribute("OrigOffset")
                    if orig then
                        child.Position = UDim2.new(0.5, orig.X * expand * m, 0.5, orig.Y * expand * m)
                    end
                end
            end
        elseif styleId == 5 then
            container.Rotation = rotAngle
            local pulsate = 1 + math.sin(t * 10) * 0.12
            container.Size = UDim2.new(0, 60 * m * pulsate, 0, 60 * m * pulsate)
        elseif styleId == 6 then
            local oscillate = math.sin(t * 4) * 85
            container.Rotation = oscillate
        elseif styleId == 7 then
            container.Rotation = -rotAngle
            local cycle = (math.sin(t * 3.5) + 1) / 2
            local col1 = Color3.fromRGB(150, 220, 255):Lerp(Color3.fromRGB(255, 100, 100), cycle)
            local col2 = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(100, 255, 100), cycle)
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "Dot" then
                    local index = child:GetAttribute("Index") or 1
                    child.BackgroundColor3 = (index % 2 == 0) and col1 or col2
                end
            end
        elseif styleId == 8 then
            container.Rotation = -rotAngle * 1.3
            local pulsate = 1 + math.sin(t * 5) * 0.14
            container.Size = UDim2.new(0, 60 * m * pulsate, 0, 60 * m * pulsate)
        elseif styleId == 9 then
            container.Rotation = rotAngle * 0.3
            local expand = 1 + math.sin(t * 7) * 0.32
            local r = math.floor(math.sin(t * 2) * 127 + 128)
            local g = math.floor(math.sin(t * 2 + 2) * 127 + 128)
            local b = math.floor(math.sin(t * 2 + 4) * 127 + 128)
            local rainbow = Color3.fromRGB(r, g, b)
            
            local circ = container:FindFirstChild("Circle")
            if circ then
                local st = circ:FindFirstChildOfClass("UIStroke")
                if st then st.Color = rainbow end
            end
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "Corner" then
                    child.BackgroundColor3 = rainbow
                    local orig = child:GetAttribute("OrigOffset")
                    if orig then
                        child.Position = UDim2.new(0.5, orig.X * expand * m, 0.5, orig.Y * expand * m)
                    end
                end
            end
        elseif styleId == 10 then
            container.Rotation = 0
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "HexLine" then
                    local base = child:GetAttribute("BaseAngle") or 0
                    local speed = child:GetAttribute("SpeedMult") or 1
                    local childRot = base + (rotAngle * speed)
                    local rad = math.rad(childRot)
                    local dist = 13 * m
                    child.Position = UDim2.new(0.5, dist * math.cos(rad), 0.5, dist * math.sin(rad))
                    child.Rotation = childRot
                    local cycle = (math.sin(t * 5 + childRot) + 1) / 2
                    child.BackgroundColor3 = Color3.fromRGB(255, 0, 255):Lerp(Color3.fromRGB(0, 255, 255), cycle)
                end
            end
        elseif styleId == 11 then
            container.Rotation = rotAngle * 0.8
            local pulse = 1 + math.sin(t * 8) * 0.2
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "Line" then
                    local orig = child:GetAttribute("OrigOffset")
                    if orig then
                        child.Position = UDim2.new(0.5, orig.X * pulse * m, 0.5, orig.Y * pulse * m)
                    end
                end
            end
        elseif styleId == 12 then
            container.Rotation = 0
            local inner = container:FindFirstChild("Inner")
            local outer = container:FindFirstChild("Outer")
            if inner then inner.Rotation = rotAngle end
            if outer then outer.Rotation = -rotAngle * 0.5 end
        elseif styleId == 13 then
            container.Rotation = 0
            local sweep = container:FindFirstChild("SweepLine")
            if sweep then sweep.Rotation = rotAngle * 1.5 end
        elseif styleId == 14 then
            container.Rotation = -rotAngle * 1.2
            local breathe = 1 + math.sin(t * 4) * 0.15
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "ArcPart" then
                    local base = child:GetAttribute("BaseAngle") or 0
                    local rad = math.rad(base)
                    child.Position = UDim2.new(0.5, 10 * m * breathe * math.cos(rad), 0.5, 10 * m * breathe * math.sin(rad))
                end
            end
        elseif styleId == 15 then
            container.Rotation = rotAngle * 0.2
            local scale = 1 + math.sin(t * 6) * 0.3
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "HUDBracket" then
                    local orig = child:GetAttribute("OrigOffset")
                    if orig then
                        child.Position = UDim2.new(0.5, orig.X * scale * m, 0.5, orig.Y * scale * m)
                    end
                end
            end
        end
    end

    -- Inisialisasi 15 tombol di scrolling frame
    for i = 1, 15 do
        local btn = Instance.new("TextButton", CrosshairScroll)
        btn.Name = "CrosshairStyle_" .. i
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        btn.Text = ""
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

        local stroke = Instance.new("UIStroke", btn)
        stroke.Thickness = 1.5
        stroke.Color = (_G.CurrentCrosshairStyle == i) and _G.AccentColor or Color3.fromRGB(45, 45, 55)

        local prevContainer = Instance.new("Frame", btn)
        prevContainer.Size = UDim2.new(0, 30, 0, 30)
        prevContainer.Position = UDim2.new(0.5, 0, 0.5, -6)
        prevContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        prevContainer.BackgroundTransparency = 1

        buildCrosshair(prevContainer, i, 0.6) -- Preview scaling
        table.insert(previewContainers, prevContainer)

        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, 0, 0, 12); lbl.Position = UDim2.new(0, 0, 1, -14)
        lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold

        -- Proteksi Premium: Gaya 1-5 gratis, Gaya 6-15 dikunci sebagai Premium
        if i > 5 then
            lbl.Text = "Style " .. i .. "\n(PREMIUM)"
            lbl.TextColor3 = Color3.fromRGB(255, 75, 75)
            lbl.TextSize = 5
        else
            lbl.Text = "Style " .. i
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            lbl.TextSize = 6.5
        end

        btn.MouseButton1Click:Connect(function()
            if i > 5 then
                NotifyPremium()
                return
            end
            _G.CurrentCrosshairStyle = i
            for _, child in ipairs(CrosshairScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    local st = child:FindFirstChildOfClass("UIStroke")
                    if st then
                        st.Color = (child.Name == "CrosshairStyle_" .. i) and _G.AccentColor or Color3.fromRGB(45, 45, 55)
                    end
                end
            end
            if _G.CrosshairEnabled then
                buildCrosshair(CrosshairContainer, i, 1.0)
            end
        end)
    end

    -- ========================================================
    -- [[ INTEGRATED SCREEN RESOLUTION SYSTEM (FREE / UNLOCKED) ]]
    -- ========================================================
    createLine(UDim2.new(0, 6, 0, 575)).Parent = ContentFrame
    createLabel("SCREEN RESOLUTION SYSTEM", UDim2.new(0, 6, 0, 581)).Parent = ContentFrame
    local ResBtn = createBtn("[Y] RESOLUTION: OFF", UDim2.new(0, 6, 0, 593), UDim2.new(0, 128, 0, 20)); ResBtn.Parent = ContentFrame

    local ResSliderFrame = Instance.new("Frame", ContentFrame)
    ResSliderFrame.Size = UDim2.new(0, 128, 0, 12)
    ResSliderFrame.Position = UDim2.new(0, 6, 0, 618)
    ResSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", ResSliderFrame)
    
    local ResSliderFill = Instance.new("Frame", ResSliderFrame)
    ResSliderFill.BackgroundColor3 = _G.AccentColor
    Instance.new("UICorner", ResSliderFill)
    
    local ResSliderText = Instance.new("TextLabel", ResSliderFrame)
    ResSliderText.Size = UDim2.new(1, 0, 1, 0)
    ResSliderText.BackgroundTransparency = 1
    ResSliderText.TextColor3 = Color3.new(1, 1, 1)
    ResSliderText.TextSize = 7
    ResSliderText.Font = Enum.Font.GothamBold

    local function syncResSlider(val)
        ResSliderFill.Size = UDim2.new(math.clamp((val - 0.01) / 1.99, 0, 1), 0, 1, 0)
        ResSliderText.Text = string.format("SCALE: %.2fx", val)
    end
    syncResSlider(_G.ResolutionValue)

    local resDragging = false
    ResSliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resDragging = true
            local percentage = math.clamp((input.Position.X - ResSliderFrame.AbsolutePosition.X) / ResSliderFrame.AbsoluteSize.X, 0, 1)
            _G.ResolutionValue = 0.01 + (percentage * 1.99)
            syncResSlider(_G.ResolutionValue)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((input.Position.X - ResSliderFrame.AbsolutePosition.X) / ResSliderFrame.AbsoluteSize.X, 0, 1)
            _G.ResolutionValue = 0.01 + (percentage * 1.99)
            syncResSlider(_G.ResolutionValue)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resDragging = false
        end
    end)

    -- ========================================================
    -- [[ INTEGRATED AUTO & MANUAL PASS BOMB (FREE) ]]
    -- ========================================================
    createLine(UDim2.new(0, 6, 0, 635)).Parent = ContentFrame
    createLabel("AUTO & MANUAL PASS BOMB SYSTEM", UDim2.new(0, 6, 0, 641)).Parent = ContentFrame
    local AutoPassBtn = createBtn("[P] AUTO PASS: OFF", UDim2.new(0, 6, 0, 653), UDim2.new(0, 128, 0, 20)); AutoPassBtn.Parent = ContentFrame
    local PassModeBtn = createBtn("TARGET: WITHOUT BOMB", UDim2.new(0, 6, 0, 678), UDim2.new(0, 128, 0, 20)); PassModeBtn.Parent = ContentFrame
    
    -- ON/OFF BUTTON UNTUK MEMUNCULKAN TOMBOL EKSTERNAL PASS BOMB
    local PassShowBtn = createBtn("SHOW PASS BTN: OFF", UDim2.new(0, 6, 0, 703), UDim2.new(0, 128, 0, 20)); PassShowBtn.Parent = ContentFrame

    -- SLIDER AREA STUD UNTUK PASS BOMB (1-200 STUD)
    createLabel("PASS AREA RANGE (1-200 STUD)", UDim2.new(0, 6, 0, 728)).Parent = ContentFrame
    local PassSliderFrame = Instance.new("Frame", ContentFrame)
    PassSliderFrame.Size = UDim2.new(0, 128, 0, 12)
    PassSliderFrame.Position = UDim2.new(0, 6, 0, 740)
    PassSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", PassSliderFrame)
    
    local PassSliderFill = Instance.new("Frame", PassSliderFrame)
    PassSliderFill.BackgroundColor3 = _G.AccentColor
    Instance.new("UICorner", PassSliderFill)
    
    local PassSliderText = Instance.new("TextLabel", PassSliderFrame)
    PassSliderText.Size = UDim2.new(1, 0, 1, 0)
    PassSliderText.BackgroundTransparency = 1
    PassSliderText.TextColor3 = Color3.new(1, 1, 1)
    PassSliderText.TextSize = 7
    PassSliderText.Font = Enum.Font.GothamBold

    local function syncPassSlider(val)
        PassSliderFill.Size = UDim2.new(math.clamp((val - 1) / 199, 0, 1), 0, 1, 0)
        PassSliderText.Text = string.format("MAX RANGE: %.0f STUD", val)
    end
    syncPassSlider(_G.PassMaxDistance)

    local passDistDragging = false
    PassSliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            passDistDragging = true
            local percentage = math.clamp((input.Position.X - PassSliderFrame.AbsolutePosition.X) / PassSliderFrame.AbsoluteSize.X, 0, 1)
            _G.PassMaxDistance = math.floor(1 + (percentage * 199))
            syncPassSlider(_G.PassMaxDistance)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if passDistDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((input.Position.X - PassSliderFrame.AbsolutePosition.X) / PassSliderFrame.AbsoluteSize.X, 0, 1)
            _G.PassMaxDistance = math.floor(1 + (percentage * 199))
            syncPassSlider(_G.PassMaxDistance)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            passDistDragging = false
        end
    end)

    -- SYSTEM SCALE SETTINGS (Posisi digeser ke bawah)
    createLine(UDim2.new(0, 6, 0, 765)).Parent = ContentFrame
    createLabel("SCALE SETTINGS", UDim2.new(0, 6, 0, 771)).Parent = ContentFrame

    -- SLIDER UKURAN UI (1-200%)
    local UIScaleSliderFrame = Instance.new("Frame", ContentFrame)
    UIScaleSliderFrame.Size = UDim2.new(0, 128, 0, 12)
    UIScaleSliderFrame.Position = UDim2.new(0, 6, 0, 783)
    UIScaleSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", UIScaleSliderFrame)

    local UIScaleSliderFill = Instance.new("Frame", UIScaleSliderFrame)
    UIScaleSliderFill.BackgroundColor3 = _G.AccentColor
    Instance.new("UICorner", UIScaleSliderFill)

    local UIScaleSliderText = Instance.new("TextLabel", UIScaleSliderFrame)
    UIScaleSliderText.Size = UDim2.new(1, 0, 1, 0)
    UIScaleSliderText.BackgroundTransparency = 1
    UIScaleSliderText.TextColor3 = Color3.new(1, 1, 1)
    UIScaleSliderText.TextSize = 7
    UIScaleSliderText.Font = Enum.Font.GothamBold

    local function syncUIScaleSlider(val)
        UIScaleSliderFill.Size = UDim2.new(math.clamp((val - 1) / 199, 0, 1), 0, 1, 0)
        UIScaleSliderText.Text = string.format("UI SIZE: %.0f%%", val)
        MainUIScale.Scale = val / 100
    end
    syncUIScaleSlider(_G.UIScaleValue)

    local uiScaleDragging = false
    UIScaleSliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            uiScaleDragging = true
            local percentage = math.clamp((input.Position.X - UIScaleSliderFrame.AbsolutePosition.X) / UIScaleSliderFrame.AbsoluteSize.X, 0, 1)
            _G.UIScaleValue = math.floor(1 + (percentage * 199))
            syncUIScaleSlider(_G.UIScaleValue)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if uiScaleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((input.Position.X - UIScaleSliderFrame.AbsolutePosition.X) / UIScaleSliderFrame.AbsoluteSize.X, 0, 1)
            _G.UIScaleValue = math.floor(1 + (percentage * 199))
            syncUIScaleSlider(_G.UIScaleValue)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            uiScaleDragging = false
        end
    end)

    -- SLIDER UKURAN TOMBOL EKSTERNAL (1-200%)
    local ExtScaleSliderFrame = Instance.new("Frame", ContentFrame)
    ExtScaleSliderFrame.Size = UDim2.new(0, 128, 0, 12)
    ExtScaleSliderFrame.Position = UDim2.new(0, 6, 0, 807)
    ExtScaleSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", ExtScaleSliderFrame)

    local ExtScaleSliderFill = Instance.new("Frame", ExtScaleSliderFrame)
    ExtScaleSliderFill.BackgroundColor3 = _G.AccentColor
    Instance.new("UICorner", ExtScaleSliderFill)

    local ExtScaleSliderText = Instance.new("TextLabel", ExtScaleSliderFrame)
    ExtScaleSliderText.Size = UDim2.new(1, 0, 1, 0)
    ExtScaleSliderText.BackgroundTransparency = 1
    ExtScaleSliderText.TextColor3 = Color3.new(1, 1, 1)
    ExtScaleSliderText.TextSize = 7
    ExtScaleSliderText.Font = Enum.Font.GothamBold

    -- Dynamic External UI Scale Object
    local ExternalUIScale
    local AutoHoldUIScale
    local FlickExternalUIScale
    local PassExternalUIScale
    local AutoWalkExternalUIScale

    local function syncExtScaleSlider(val)
        ExtScaleSliderFill.Size = UDim2.new(math.clamp((val - 1) / 199, 0, 1), 0, 1, 0)
        ExtScaleSliderText.Text = string.format("EXT SIZE: %.0f%%", val)
        if ExternalUIScale then
            ExternalUIScale.Scale = val / 100
        end
        if AutoHoldUIScale then
            AutoHoldUIScale.Scale = val / 100
        end
        if FlickExternalUIScale then
            FlickExternalUIScale.Scale = val / 100
        end
        if PassExternalUIScale then
            PassExternalUIScale.Scale = val / 100
        end
        if AutoWalkExternalUIScale then
            AutoWalkExternalUIScale.Scale = val / 100
        end
    end

    local extScaleDragging = false
    ExtScaleSliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            extScaleDragging = true
            local percentage = math.clamp((input.Position.X - ExtScaleSliderFrame.AbsolutePosition.X) / ExtScaleSliderFrame.AbsoluteSize.X, 0, 1)
            _G.ExtScaleValue = math.floor(1 + (percentage * 199))
            syncExtScaleSlider(_G.ExtScaleValue)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if extScaleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((input.Position.X - ExtScaleSliderFrame.AbsolutePosition.X) / ExtScaleSliderFrame.AbsoluteSize.X, 0, 1)
            _G.ExtScaleValue = math.floor(1 + (percentage * 199))
            syncExtScaleSlider(_G.ExtScaleValue)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            extScaleDragging = false
        end
    end)

    local CloseBar = createBtn("▼ OPEN MENU ▼", UDim2.new(0, 0, 1, -16), UDim2.new(1, 0, 0, 16), Color3.new(0,0,0))
    CloseBar.BackgroundTransparency = 1; CloseBar.TextSize = 6

    CloseBar.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        MainFrame:TweenSize(isMinimized and UDim2.new(0, 140, 0, 58) or UDim2.new(0, 140, 0, 280), "Out", "Quad", 0.25, true)
        CloseBar.Text = isMinimized and "▼ OPEN MENU ▼" or "▲ CLOSE MENU ▲"
        task.wait(0.2); ContentFrame.Visible = not isMinimized
    end)

    ToggleBtnMain.MouseButton1Click:Connect(function()
        MainVisible = not MainVisible
        if MainVisible then
            MainFrame.Visible = true; HUDMain.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = isMinimized and UDim2.new(0, 140, 0, 58) or UDim2.new(0, 140, 0, 280)}):Play()
            TweenService:Create(ToggleBtnMain, TweenInfo.new(0.3), {BackgroundColor3 = _G.MainColor}):Play()
        else
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 140, 0, 0)})
            t:Play(); t.Completed:Connect(function() if not MainVisible then MainFrame.Visible = false end end)
            HUDMain.Visible = false
            TweenService:Create(ToggleBtnMain, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        end
    end)

    -- ========================================================
    -- [[ 4. CORE ENGINE LOGIC ]]
    -- ========================================================

    local function hasBomb(p) 
        if not p.Character then return false end
        return p.Character:FindFirstChild("Bomb") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Bomb")) 
    end

    -- DETEKSI SISA DETIK TIMER BOM
    local function getBombTime()
        local char = LocalPlayer.Character
        if not char then return nil end
        
        -- Cari BillboardGui/TextLabel di dalam karakter (Head, Tool, dll.)
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local cleanTxt = obj.Text:match("[%d%.]+")
                if cleanTxt then
                    local num = tonumber(cleanTxt)
                    if num and num > 0 and num <= 30 then
                        return num
                    end
                end
            end
        end
        
        -- Cari di PlayerGui (jika ada HUD sisa waktu di layar)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, obj in ipairs(playerGui:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Visible then
                    local cleanTxt = obj.Text:match("^%d+%.?%d*$")
                    if cleanTxt then
                        local num = tonumber(cleanTxt)
                        if num and num > 0 and num <= 30 then
                            return num
                        end
                    end
                end
            end
        end
        return nil
    end

    local function isAlive(p) 
        return p and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and p.Character:FindFirstChild("HumanoidRootPart") 
    end

    local function isTeammate(p)
        if not p or not p.Character then return false end
        if p.Team ~= nil and p.Team == LocalPlayer.Team then return true end
        for _, v in pairs(p.Character:GetDescendants()) do 
            if v:IsA("Highlight") and (v.FillColor.G > 0.5 or v.OutlineColor.G > 0.5) then return true end 
        end
        return false
    end

    local function canSeePlayerSticky(p)
        if not p.Character or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
        local char = p.Character; local origin = LocalPlayer.Character.HumanoidRootPart.Position
        local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local partsToCheck = {"Head", "HumanoidRootPart"}
        for _, partName in ipairs(partsToCheck) do
            local part = char:FindFirstChild(partName)
            if part then
                local direction = part.Position - origin
                local success, r = pcall(function() return Workspace:Raycast(origin, direction, params) end)
                if success and (not r or r.Instance:IsDescendantOf(char)) then return true end
            end
        end
        return false
    end

    -- SYSTEM PENYEMBUNYI CURSOR SHIFTLOCK ROBLOX (BYPASS)
    local TRANSPARENT_ICON = "rbxassetid://0"
    local successHook, _ = pcall(function()
        local old_newindex
        old_newindex = hookmetamethod(game, "__newindex", function(self, key, value)
            if self == Mouse and key == "Icon" and _G.CrosshairEnabled then
                return old_newindex(self, key, TRANSPARENT_ICON)
            end
            return old_newindex(self, key, value)
        end)
    end)

    if not successHook then
        RunService.PostSimulation:Connect(function()
            if _G.CrosshairEnabled then
                if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
                    if Mouse.Icon ~= TRANSPARENT_ICON then
                        Mouse.Icon = TRANSPARENT_ICON
                    end
                end
            else
                if Mouse.Icon == TRANSPARENT_ICON then
                    Mouse.Icon = ""
                end
            end
        end)
    end

    -- LOGIKA TWEEN UNTUK PASS BOMB (TELEPORT CEPAT & KEMBALI INSTAN KE TEMPAT AWAL)
    local function teleportTween(targetPart)
        if isTweening or not targetPart then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        isTweening = true
        
        -- SIMPAN POSISI AWAL SEBELUM MELAKUKAN TELEPORT OPER BOM
        local startCFrame = hrp.CFrame
        local startPos = hrp.Position
        local endPos = targetPart.Position
        local dist = (startPos - endPos).Magnitude
        
        -- Kecepatan ultra tinggi (230 studs per detik) yang aman tapi mendekati instan
        local speed = 230 
        local duration = math.clamp(dist / speed, 0.05, 0.75)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        -- Berikan sedikit offset z: 1.2 stud agar tidak tersangkut di dalam tubuh musuh
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPart.CFrame * CFrame.new(0, 0, 1.2)})
        tween:Play()
        tween.Completed:Connect(function()
            -- Delay singkat agar server mendeteksi sentuhan bomb, lalu paksa teleport kembali ke posisi awal
            task.wait(0.05)
            hrp.CFrame = startCFrame
            isTweening = false
        end)
    end

    local function triggerManualPass()
        if isTweening then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local rootPos = char.HumanoidRootPart.Position
        
        local bestTarget = nil
        local minDist = math.huge
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isAlive(p) and not isTeammate(p) then
                local isMatch = false
                if _G.PassTargetMode == "Without Bomb" then
                    isMatch = not hasBomb(p)
                else
                    isMatch = hasBomb(p)
                end
                
                if isMatch then
                    local d = (rootPos - p.Character.HumanoidRootPart.Position).Magnitude
                    -- TAMBAHAN JARAK AREA STUD (1-200 STUD) KHUSUS PASS BOMB
                    if d <= _G.PassMaxDistance and d < minDist then
                        minDist = d
                        bestTarget = p
                    end
                end
            end
        end
        
        if bestTarget then
            teleportTween(bestTarget.Character.HumanoidRootPart)
        end
    end

    RunService.Heartbeat:Connect(function(dt)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local root = LocalPlayer.Character.HumanoidRootPart; local hum = LocalPlayer.Character.Humanoid
        local amIHolder = hasBomb(LocalPlayer)
        
        -- Reset Jump count if grounded
        if hum and hum.FloorMaterial ~= Enum.Material.Air then
            _G.CurrentJumpCount = 0
        end

        -- FOV Camera Sync Loop
        if _G.FOVEnabled then
            Camera.FieldOfView = _G.FOVValue
        end

        -- Memutar dan menganimasikan crosshair secara real-time
        local elapsed = tick()
        if _G.CrosshairEnabled and CrosshairContainer.Visible then
            updateCrosshairAnimation(CrosshairContainer, _G.CurrentCrosshairStyle, 1.0, elapsed)
        end
        if MainVisible and not isMinimized then
            for i, prev in ipairs(previewContainers) do
                if prev then
                    updateCrosshairAnimation(prev, i, 0.6, elapsed)
                end
            end
        end

        if hum.FloorMaterial == Enum.Material.Air and root.Velocity.Magnitude > 100 then root.Velocity = root.Velocity.Unit * 100 end
        if amIHolder then bombTimer += dt else bombTimer = 0 end

        -- Wall Walk Logic Terkait Dihapus Sepenuhnya
        isSticking = false

        if tick() - lastRaycastCheck >= raycastInterval then
            if lockedTarget then isVisibleCached = canSeePlayerSticky(lockedTarget) end
            lastRaycastCheck = tick()
        end

        if not lastHadBomb and amIHolder then
            retreatTimer = 0; local minDist = 15; local tagger = nil
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isAlive(p) then
                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < minDist then minDist = d; tagger = p end
                end
            end
            if tagger then lockedTarget = tagger; targetMemory = 2 end 
        end

        if lockedTarget and (not isAlive(lockedTarget) or isTeammate(lockedTarget) or (amIHolder and hasBomb(lockedTarget))) then lockedTarget = nil end
        if isVisibleCached then targetMemory = 1.2 elseif targetMemory > 0 then targetMemory -= dt end

        if tick() - lastTargetSearch >= searchInterval then
            local minDist = math.huge; local best = nil; local closestDist = math.huge; local closestPlayer = nil
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isAlive(p) and not isTeammate(p) then
                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < closestDist then closestDist = d; closestPlayer = p end
                    if (amIHolder and not hasBomb(p)) or (not amIHolder) then
                        if canSeePlayerSticky(p) then if d < minDist then minDist = d; best = p end end
                    end
                end
            end
            if closestPlayer and closestDist <= 7 then
                lockedTarget = closestPlayer; targetMemory = 1.2
            elseif not lockedTarget or (targetMemory <= 0 and not isVisibleCached) or (amIHolder and bombTimer > 7) then
                if best then lockedTarget = best; targetMemory = 1.2 end
            end
            lastTargetSearch = tick()
        end

        -- LOGIKA DETEKSI TRANSISI BOMB UNTUK AUTO WALK MUNDUR
        if lastHadBomb and not amIHolder then 
            hum.WalkSpeed = 16
            retreatTimer = _G.HJEnabled and 3.8 or 2.5
            if _G.HJEnabled then task.spawn(function() hum:ChangeState(3); task.wait(0.4); hum:ChangeState(3) end) end
            if _G.AutoWalkActive then
                autoWalkRetreatTimer = 2.5 -- Trigger mundur
            end
        end

        -- LOGIKA OTOMATIS OPER BOM (AUTO PASS BOMB) DENGAN BATASAN JARAK STUD
        if _G.AutoPassEnabled and amIHolder and not isTweening then
            local rootPos = root.Position
            local bestTarget = nil
            local minDist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isAlive(p) and not isTeammate(p) and not hasBomb(p) then
                    local d = (rootPos - p.Character.HumanoidRootPart.Position).Magnitude
                    -- FILTERING BERDASARKAN MAKSIMUM STUD PASS BOMB
                    if d <= _G.PassMaxDistance and d < minDist then
                        minDist = d
                        bestTarget = p
                    end
                end
            end
            if bestTarget then
                teleportTween(bestTarget.Character.HumanoidRootPart)
            end
        end

        -- KENDALI PERGERAKAN (AUTO CHASE / AUTO WALK)
        if _G.AutoWalkActive then
            if amIHolder then
                -- AUTO WALK SAAT MEMBAWA BOMB (MENGEJAR MUSUH)
                if lockedTarget and isAlive(lockedTarget) then
                    local tRoot = lockedTarget.Character.HumanoidRootPart; local dist = (root.Position - tRoot.Position).Magnitude
                    if dist <= 12 then hum.WalkSpeed = 25 else hum.WalkSpeed = 16 end
                    
                    local targetPos = tRoot.Position
                    local speed = 25
                    local moveDir = (targetPos - root.Position).Unit
                    
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    
                    local rayOrigin = root.Position + Vector3.new(0, -1.2, 0)
                    local raycastResult = Workspace:Raycast(rayOrigin, moveDir * 6, params)
                    if raycastResult and raycastResult.Instance.CanCollide then
                        local angles = {30, -30, 60, -60, 90, -90, 120, -120}
                        for _, angle in ipairs(angles) do
                            local worldAltDir = (CFrame.lookAt(root.Position, targetPos) * CFrame.Angles(0, math.rad(angle), 0)).LookVector
                            local altRay = Workspace:Raycast(rayOrigin, worldAltDir * 6, params)
                            if not altRay or not altRay.Instance.CanCollide then
                                moveDir = worldAltDir
                                break
                            end
                        end
                    end
                    
                    local nextPos = root.Position + (moveDir * speed * dt)
                    local groundRay = Workspace:Raycast(nextPos + Vector3.new(0, 5, 0), Vector3.new(0, -12, 0), params)
                    local targetY = root.Position.Y
                    if groundRay then
                        targetY = groundRay.Position.Y + 3.0
                    end
                    
                    root.CFrame = CFrame.new(Vector3.new(nextPos.X, targetY, nextPos.Z), Vector3.new(targetPos.X, targetY, targetPos.Z))
                    hum:Move(Vector3.new(0, 0, 0))
                else
                    hum.WalkSpeed = 16
                end
            else
                -- AUTO WALK SAAT TIDAK MEMBAWA BOMB: "MENJAUHIN YANG PEGANG BOMB" (TIDAK MENGGUNAKAN MUNDUR)
                local bombHolder = nil
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and isAlive(p) and hasBomb(p) then
                        bombHolder = p
                        break
                    end
                end
                
                if bombHolder then
                    local targetPos = bombHolder.Character.HumanoidRootPart.Position
                    local speed = _G.AutoWalkRetreatSpeed or 22
                    local moveDir = (root.Position - targetPos).Unit -- Arah menjauhi pemegang bom
                    
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    
                    local rayOrigin = root.Position + Vector3.new(0, -1.2, 0)
                    local raycastResult = Workspace:Raycast(rayOrigin, moveDir * 6, params)
                    if raycastResult and raycastResult.Instance.CanCollide then
                        local angles = {30, -30, 60, -60, 90, -90, 120, -120}
                        for _, angle in ipairs(angles) do
                            local worldAltDir = (CFrame.lookAt(root.Position, root.Position + moveDir) * CFrame.Angles(0, math.rad(angle), 0)).LookVector
                            local altRay = Workspace:Raycast(rayOrigin, worldAltDir * 6, params)
                            if not altRay or not altRay.Instance.CanCollide then
                                moveDir = worldAltDir
                                break
                            end
                        end
                    end
                    
                    local nextPos = root.Position + (moveDir * speed * dt)
                    local groundRay = Workspace:Raycast(nextPos + Vector3.new(0, 5, 0), Vector3.new(0, -12, 0), params)
                    local targetY = root.Position.Y
                    if groundRay then
                        targetY = groundRay.Position.Y + 3.0
                    end
                    
                    root.CFrame = CFrame.new(Vector3.new(nextPos.X, targetY, nextPos.Z), Vector3.new(targetPos.X, targetY, targetPos.Z))
                    hum:Move(Vector3.new(0, 0, 0))
                else
                    -- Fallback standar jika tidak ada pemegang bom terdeteksi
                    if lockedTarget and isAlive(lockedTarget) then
                        local tRoot = lockedTarget.Character.HumanoidRootPart
                        hum:MoveTo(root.Position + (root.Position - tRoot.Position).Unit * 22)
                    end
                end
            end
        else
            -- SISTEM CHASE / FOLLOW ORIGINAL (MENGGUNAKAN HUMANOID:MOVETO DENGAN FUNGSI MUNDUR SEPERTI BIASA)
            if lockedTarget and isAlive(lockedTarget) then
                local tRoot = lockedTarget.Character.HumanoidRootPart; local dist = (root.Position - tRoot.Position).Magnitude
                if amIHolder and dist <= 12 then hum.WalkSpeed = 25 else hum.WalkSpeed = 16 end
                
                if _G.FollowEnabled and retreatTimer <= 0 then 
                    local targetPos = _G.PredictEnabled and (tRoot.Position + (tRoot.Velocity * 0.13)) or tRoot.Position
                    hum:MoveTo(targetPos) 
                elseif _G.FollowEnabled then
                    retreatTimer -= dt; hum:MoveTo(root.Position + (root.Position - tRoot.Position).Unit * 22)
                end
            else 
                hum.WalkSpeed = 16 
            end
        end

        -- LOGIKA FLICK (Menggunakan slider kekuatan Flick)
        if _G.FlickActive and amIHolder and isAlive(lockedTarget) and (root.Position - lockedTarget.Character.HumanoidRootPart.Position).Magnitude <= 4 then
            local str = _G.FlickStrength or 45
            Camera.CFrame *= CFrame.Angles(math.rad(math.random(-str/2, str/2)), math.rad(math.random(-str, str)), 0)
        end

        -- LOGIKA ROTASI DAN AUTO HOLD BOMB (Membelakangi Musuh Jika Memegang Bom, Menghadap Jika sisa 1 Detik)
        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter and isAlive(lockedTarget) then
            if _G.AutoHoldActive and amIHolder then
                hum.AutoRotate = false
                local remaining = getBombTime()
                local lookDir
                if remaining and remaining <= 1.05 then
                    -- Menghadap langsung ke arah musuh (Timer <= 1 detik)
                    lookDir = Vector3.new(lockedTarget.Character.HumanoidRootPart.Position.X, root.Position.Y, lockedTarget.Character.HumanoidRootPart.Position.Z)
                else
                    -- Membelakangi musuh
                    lookDir = root.Position + (root.Position - lockedTarget.Character.HumanoidRootPart.Position).Unit
                end
                root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, lookDir), 0.3)
            elseif _G.FaceClassic or _G.FacePro then
                hum.AutoRotate = false
                local lookDir = amIHolder and Vector3.new(lockedTarget.Character.HumanoidRootPart.Position.X, root.Position.Y, lockedTarget.Character.HumanoidRootPart.Position.Z) or (root.Position + (root.Position - lockedTarget.Character.HumanoidRootPart.Position).Unit)
                root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, lookDir), _G.FacePro and 0.3 or faceSpeed)
            else
                hum.AutoRotate = true
            end
        else
            if _G.AutoHoldActive and amIHolder and isAlive(lockedTarget) then
                hum.AutoRotate = false
                local remaining = getBombTime()
                local lookDir
                if remaining and remaining <= 1.05 then
                    -- Menghadap langsung ke arah musuh (Timer <= 1 detik)
                    lookDir = Vector3.new(lockedTarget.Character.HumanoidRootPart.Position.X, root.Position.Y, lockedTarget.Character.HumanoidRootPart.Position.Z)
                else
                    -- Membelakangi musuh
                    lookDir = root.Position + (root.Position - lockedTarget.Character.HumanoidRootPart.Position).Unit
                end
                root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, lookDir), 0.3)
            else
                hum.AutoRotate = true
            end
        end

        lastHadBomb = amIHolder
    end)

    local function handleAutoJump()
        if _G.AutoJumpEnabled and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            if LocalPlayer.Character and LocalPlayer.Character.Humanoid and LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then 
                LocalPlayer.Character.Humanoid.Jump = true 
            end
        end
    end
    UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(handleAutoJump)

    -- INTEGRASI WALLHOP & INFINITE JUMP
    UserInputService.JumpRequest:Connect(function()
        isSticking = false 

        -- Custom Multi-Jump Logic dengan Debounce
        if _G.InfJumpEnabled and not jumpDebounce then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                jumpDebounce = true
                if hum.FloorMaterial == Enum.Material.Air then
                    if _G.CurrentJumpCount < _G.MaxJumpCount - 1 then
                        _G.CurrentJumpCount = _G.CurrentJumpCount + 1
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                else
                    _G.CurrentJumpCount = 0
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                task.spawn(function()
                    task.wait(0.2) -- Debounce untuk mencegah penumpukan tinggi lompatan
                    jumpDebounce = false
                end)
            end
        end

        if not LocalPlayer.Character or not canWallJump then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart; local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character}
        if _G.WHInstant and Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * _G.WallHopDist, params) then
            -- Locked
        elseif _G.WHNormal then
            for i = 0, 7 do
                local dir = (hrp.CFrame * CFrame.Angles(0, math.rad(i*45), 0)).LookVector
                local r = Workspace:Raycast(hrp.Position, dir * _G.WallHopDist, params)
                if r and r.Instance.CanCollide then
                    if not _G.PremiumUser then break end -- Blocked
                end
            end
        end
    end)

    local function syncSlider(val)
        SliderFill.Size = UDim2.new(math.clamp((val - 1) / 9, 0, 1), 0, 1, 0); SliderText.Text = string.format("%.1f STUDS (PREMIUM)", val)
    end
    syncSlider(_G.WallHopDist)

    -- SYNC SLIDER FOV (1-200)
    local function syncFOVSlider(val)
        FOVSliderFill.Size = UDim2.new(math.clamp((val - 1) / 199, 0, 1), 0, 1, 0)
        FOVSliderText.Text = string.format("FOV: %.0f", val)
    end
    syncFOVSlider(_G.FOVValue)

    -- FOV SLIDER DRAGGING INTERACTION
    local fovDragging = false
    FOVSliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fovDragging = true
            local percentage = math.clamp((input.Position.X - FOVSliderFrame.AbsolutePosition.X) / FOVSliderFrame.AbsoluteSize.X, 0, 1)
            _G.FOVValue = math.floor(1 + (percentage * 199))
            syncFOVSlider(_G.FOVValue)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if fovDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((input.Position.X - FOVSliderFrame.AbsolutePosition.X) / FOVSliderFrame.AbsoluteSize.X, 0, 1)
            _G.FOVValue = math.floor(1 + (percentage * 199))
            syncFOVSlider(_G.FOVValue)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fovDragging = false
        end
    end)

    task.spawn(function()
        local lastTime = tick(); local frames = 0
        RunService.RenderStepped:Connect(function()
            frames += 1
            if tick() - lastTime >= 1 then
                FPSLabel.Text = "FPS: " .. frames; PingLabel.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
                for i = 1, 9 do bars[i].Size = bars[i+1].Size; bars[i].Position = UDim2.new(0, i*3, 1, -bars[i].Size.Y.Offset) end
                local newH = math.clamp(frames/3, 5, 30); bars[10].Size = UDim2.new(0, 2, 0, newH); bars[10].Position = UDim2.new(0, 30, 1, -newH)
                frames = 0; lastTime = tick()
            end
        end)
    end)

    -- LOOP RENDER STEPPED KHUSUS UNTUK RESOLUTION (STRETCH RES) SYSTEM
    RunService.RenderStepped:Connect(function()
        if _G.ResolutionEnabled and _G.ResolutionValue ~= 1.00 then
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, _G.ResolutionValue, 0, 0, 0, 1)
        end
    end)

    -- ========================================================
    -- [[ 5. TOMBOL EKSTERNAL FREEZE, FLICK, AUTO HOLD, PASS, & AUTO WALK ]]
    -- ========================================================
    
    -- TOMBOL FREEZE
    local FreezeExternalBtn = Instance.new("TextButton", ScreenGui)
    FreezeExternalBtn.Name = "FreezeExternalButton"
    FreezeExternalBtn.Size = UDim2.new(0, 70, 0, 30)
    FreezeExternalBtn.Position = UDim2.new(0.5, -155, 0.8, 0)
    FreezeExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FreezeExternalBtn.Text = "FREEZE"
    FreezeExternalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FreezeExternalBtn.Font = Enum.Font.GothamBold
    FreezeExternalBtn.TextSize = 11
    FreezeExternalBtn.ZIndex = 100
    FreezeExternalBtn.Visible = false
    Instance.new("UICorner", FreezeExternalBtn).CornerRadius = UDim.new(0, 5)
    local FreezeStroke = Instance.new("UIStroke", FreezeExternalBtn)
    FreezeStroke.Color = _G.AccentColor
    FreezeStroke.Thickness = 1.5

    -- UIScale objek untuk tombol eksternal agar membesar proporsional
    ExternalUIScale = Instance.new("UIScale", FreezeExternalBtn)
    ExternalUIScale.Scale = 1.0

    -- Tombol Memberhentikan Freeze
    local StopFreezeExternalBtn = Instance.new("TextButton", FreezeExternalBtn)
    StopFreezeExternalBtn.Name = "StopFreezeExternalButton"
    StopFreezeExternalBtn.Size = UDim2.new(1, 0, 1, 0)
    StopFreezeExternalBtn.Position = UDim2.new(0, 0, 1, 5) -- Di bawah tombol Freeze dengan jarak 5 pixel
    StopFreezeExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StopFreezeExternalBtn.Text = "STOP FREEZE"
    StopFreezeExternalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopFreezeExternalBtn.Font = Enum.Font.GothamBold
    StopFreezeExternalBtn.TextSize = 9
    StopFreezeExternalBtn.ZIndex = 100
    Instance.new("UICorner", StopFreezeExternalBtn).CornerRadius = UDim.new(0, 5)
    local StopFreezeStroke = Instance.new("UIStroke", StopFreezeExternalBtn)
    StopFreezeStroke.Color = Color3.fromRGB(255, 50, 50) -- Indikator Merah untuk menghentikan
    StopFreezeStroke.Thickness = 1.5

    -- TOMBOL FLICK EKSTERNAL
    local FlickExternalBtn = Instance.new("TextButton", ScreenGui)
    FlickExternalBtn.Name = "FlickExternalButton"
    FlickExternalBtn.Size = UDim2.new(0, 70, 0, 30)
    FlickExternalBtn.Position = UDim2.new(0.5, -75, 0.8, 0)
    FlickExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FlickExternalBtn.Text = "FLICK"
    FlickExternalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlickExternalBtn.Font = Enum.Font.GothamBold
    FlickExternalBtn.TextSize = 11
    FlickExternalBtn.ZIndex = 100
    FlickExternalBtn.Visible = false
    Instance.new("UICorner", FlickExternalBtn).CornerRadius = UDim.new(0, 5)
    local FlickExternalStroke = Instance.new("UIStroke", FlickExternalBtn)
    FlickExternalStroke.Color = _G.AccentColor
    FlickExternalStroke.Thickness = 1.5

    FlickExternalUIScale = Instance.new("UIScale", FlickExternalBtn)
    FlickExternalUIScale.Scale = 1.0

    -- TOMBOL AUTO HOLD BOMB
    local AutoHoldExternalBtn = Instance.new("TextButton", ScreenGui)
    AutoHoldExternalBtn.Name = "AutoHoldExternalButton"
    AutoHoldExternalBtn.Size = UDim2.new(0, 70, 0, 30)
    AutoHoldExternalBtn.Position = UDim2.new(0.5, 5, 0.8, 0)
    AutoHoldExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    AutoHoldExternalBtn.Text = "HOLD BOMB"
    AutoHoldExternalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoHoldExternalBtn.Font = Enum.Font.GothamBold
    AutoHoldExternalBtn.TextSize = 10
    AutoHoldExternalBtn.ZIndex = 100
    AutoHoldExternalBtn.Visible = false
    Instance.new("UICorner", AutoHoldExternalBtn).CornerRadius = UDim.new(0, 5)
    local AutoHoldStroke = Instance.new("UIStroke", AutoHoldExternalBtn)
    AutoHoldStroke.Color = _G.AccentColor
    AutoHoldStroke.Thickness = 1.5

    AutoHoldUIScale = Instance.new("UIScale", AutoHoldExternalBtn)
    AutoHoldUIScale.Scale = 1.0

    -- TOMBOL MANUAL PASS BOMB EKSTERNAL
    local PassExternalBtn = Instance.new("TextButton", ScreenGui)
    PassExternalBtn.Name = "PassExternalButton"
    PassExternalBtn.Size = UDim2.new(0, 70, 0, 30)
    PassExternalBtn.Position = UDim2.new(0.5, 85, 0.8, 0)
    PassExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    PassExternalBtn.Text = "PASS BOMB"
    PassExternalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PassExternalBtn.Font = Enum.Font.GothamBold
    PassExternalBtn.TextSize = 10
    PassExternalBtn.ZIndex = 100
    PassExternalBtn.Visible = _G.PassExternalVisible -- Visibility diatur secara default sesuai state on/off di UI
    Instance.new("UICorner", PassExternalBtn).CornerRadius = UDim.new(0, 5)
    local PassExternalStroke = Instance.new("UIStroke", PassExternalBtn)
    PassExternalStroke.Color = _G.AccentColor
    PassExternalStroke.Thickness = 1.5

    PassExternalUIScale = Instance.new("UIScale", PassExternalBtn)
    PassExternalUIScale.Scale = 1.0

    -- TOMBOL AUTO WALK EKSTERNAL
    local AutoWalkExternalBtn = Instance.new("TextButton", ScreenGui)
    AutoWalkExternalBtn.Name = "AutoWalkExternalButton"
    AutoWalkExternalBtn.Size = UDim2.new(0, 70, 0, 30)
    AutoWalkExternalBtn.Position = UDim2.new(0.5, 165, 0.8, 0)
    AutoWalkExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    AutoWalkExternalBtn.Text = "AUTO WALK"
    AutoWalkExternalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoWalkExternalBtn.Font = Enum.Font.GothamBold
    AutoWalkExternalBtn.TextSize = 10
    AutoWalkExternalBtn.ZIndex = 100
    AutoWalkExternalBtn.Visible = false
    Instance.new("UICorner", AutoWalkExternalBtn).CornerRadius = UDim.new(0, 5)
    local AutoWalkExternalStroke = Instance.new("UIStroke", AutoWalkExternalBtn)
    AutoWalkExternalStroke.Color = _G.AccentColor
    AutoWalkExternalStroke.Thickness = 1.5

    AutoWalkExternalUIScale = Instance.new("UIScale", AutoWalkExternalBtn)
    AutoWalkExternalUIScale.Scale = 1.0

    -- Hubungkan slider inisialisasi awal dengan nilai global saat ini
    syncExtScaleSlider(_G.ExtScaleValue)

    -- Tombol Freeze Draggable (Terhubung dengan Lock/Unlock 'isLocked')
    local fe_dragging, fe_dragStart, fe_startPos
    FreezeExternalBtn.InputBegan:Connect(function(i) 
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not isLocked then 
            fe_dragging = true
            fe_dragStart = i.Position
            fe_startPos = FreezeExternalBtn.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if fe_dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local d = i.Position - fe_dragStart
            FreezeExternalBtn.Position = UDim2.new(fe_startPos.X.Scale, fe_startPos.X.Offset + d.X, fe_startPos.Y.Scale, fe_startPos.Y.Offset + d.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            fe_dragging = false 
        end 
    end)

    -- Tombol Flick Draggable
    local fl_dragging, fl_dragStart, fl_startPos
    FlickExternalBtn.InputBegan:Connect(function(i) 
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not isLocked then 
            fl_dragging = true
            fl_dragStart = i.Position
            fl_startPos = FlickExternalBtn.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if fl_dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local d = i.Position - fl_dragStart
            FlickExternalBtn.Position = UDim2.new(fl_startPos.X.Scale, fl_startPos.X.Offset + d.X, fl_startPos.Y.Scale, fl_startPos.Y.Offset + d.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            fl_dragging = false 
        end 
    end)

    -- Tombol Auto Hold Draggable
    local ah_dragging, ah_dragStart, ah_startPos
    AutoHoldExternalBtn.InputBegan:Connect(function(i) 
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not isLocked then 
            ah_dragging = true
            ah_dragStart = i.Position
            ah_startPos = AutoHoldExternalBtn.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if ah_dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local d = i.Position - ah_dragStart
            AutoHoldExternalBtn.Position = UDim2.new(ah_startPos.X.Scale, ah_startPos.X.Offset + d.X, ah_startPos.Y.Scale, ah_startPos.Y.Offset + d.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            ah_dragging = false 
        end 
    end)

    -- Tombol Pass Bomb Draggable
    local pe_dragging, pe_dragStart, pe_startPos
    PassExternalBtn.InputBegan:Connect(function(i) 
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not isLocked then 
            pe_dragging = true
            pe_dragStart = i.Position
            pe_startPos = PassExternalBtn.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if pe_dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local d = i.Position - pe_dragStart
            PassExternalBtn.Position = UDim2.new(pe_startPos.X.Scale, pe_startPos.X.Offset + d.X, pe_startPos.Y.Scale, pe_startPos.Y.Offset + d.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            pe_dragging = false 
        end 
    end)

    -- Tombol Auto Walk Draggable
    local aw_dragging, aw_dragStart, aw_startPos
    AutoWalkExternalBtn.InputBegan:Connect(function(i) 
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not isLocked then 
            aw_dragging = true
            aw_dragStart = i.Position
            aw_startPos = AutoWalkExternalBtn.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if aw_dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local d = i.Position - aw_dragStart
            AutoWalkExternalBtn.Position = UDim2.new(aw_startPos.X.Scale, aw_startPos.X.Offset + d.X, aw_startPos.Y.Scale, aw_startPos.Y.Offset + d.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            aw_dragging = false 
        end 
    end)

    local isFreezing = false
    local activeAnchoredParts = {}

    local function stopFreeze()
        if not isFreezing then return end
        for _, part in ipairs(activeAnchoredParts) do
            pcall(function() part.Anchored = false end)
        end
        table.clear(activeAnchoredParts)
        FreezeExternalBtn.Text = "FREEZE"
        FreezeExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        isFreezing = false
    end

    FreezeExternalBtn.MouseButton1Click:Connect(function()
        if isFreezing then return end
        isFreezing = true
        FreezeExternalBtn.Text = "LAGGING..."
        FreezeExternalBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)

        local char = LocalPlayer.Character
        table.clear(activeAnchoredParts)
        
        -- Simulasi lag (anchor karakter di tempat)
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored then
                    part.Anchored = true
                    table.insert(activeAnchoredParts, part)
                end
            end
        end

        -- Tunggu maksimal 3.5 detik atau sampai dihentikan secara manual
        local elapsed = 0
        while elapsed < 3.5 and isFreezing do
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end

        if isFreezing then
            stopFreeze()
        end
    end)

    StopFreezeExternalBtn.MouseButton1Click:Connect(stopFreeze)

    -- Interaksi Tombol Eksternal Flick
    FlickExternalBtn.MouseButton1Click:Connect(function()
        _G.FlickActive = not _G.FlickActive
        if _G.FlickActive then
            FlickExternalBtn.Text = "FLICKING..."
            FlickExternalBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            FlickExternalBtn.Text = "FLICK"
            FlickExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)

    -- Interaksi Tombol Eksternal Auto Hold
    AutoHoldExternalBtn.MouseButton1Click:Connect(function()
        _G.AutoHoldActive = not _G.AutoHoldActive
        if _G.AutoHoldActive then
            AutoHoldExternalBtn.Text = "HOLDING..."
            AutoHoldExternalBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            AutoHoldExternalBtn.Text = "HOLD BOMB"
            AutoHoldExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)

    -- Interaksi Tombol Eksternal Manual Pass
    PassExternalBtn.MouseButton1Click:Connect(triggerManualPass)

    -- Interaksi Tombol Eksternal Auto Walk
    AutoWalkExternalBtn.MouseButton1Click:Connect(function()
        _G.AutoWalkActive = not _G.AutoWalkActive
        if _G.AutoWalkActive then
            AutoWalkExternalBtn.Text = "WALKING..."
            AutoWalkExternalBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            AutoWalkExternalBtn.Text = "AUTO WALK"
            AutoWalkExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)

    -- ==========================================
    -- [[ FUNCTION TRIGGERS FOR BUTTONS ]]
    -- ==========================================
    local function toggleFollow()
        _G.FollowEnabled = not _G.FollowEnabled
        ToggleBtn.Text = _G.FollowEnabled and "[Q] AUTO: ON" or "[Q] AUTO: OFF"
        ToggleBtn.BackgroundColor3 = _G.FollowEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35) 
    end

    local function toggleFlick()
        _G.FlickEnabled = not _G.FlickEnabled
        FlickBtn.Text = _G.FlickEnabled and "[Z] FLICK: ON" or "[Z] FLICK: OFF"
        FlickBtn.BackgroundColor3 = _G.FlickEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35) 
        FlickExternalBtn.Visible = _G.FlickEnabled
        
        if not _G.FlickEnabled then
            _G.FlickActive = false
            FlickExternalBtn.Text = "FLICK"
            FlickExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end

    local function toggleFOV()
        _G.FOVEnabled = not _G.FOVEnabled
        FOVBtn.Text = _G.FOVEnabled and "[I] FOV: ON" or "[I] FOV: OFF"
        FOVBtn.BackgroundColor3 = _G.FOVEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35)
        if not _G.FOVEnabled then
            Camera.FieldOfView = 70 -- Reset default
        end
    end

    local function toggleFreeze()
        _G.FreezeEnabled = not _G.FreezeEnabled
        FreezeBtn.Text = _G.FreezeEnabled and "[O] FREEZE BUTTON: ON" or "[O] FREEZE BUTTON: OFF"
        FreezeBtn.BackgroundColor3 = _G.FreezeEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35)
        FreezeExternalBtn.Visible = _G.FreezeEnabled
    end

    local function toggleInfJump()
        _G.InfJumpEnabled = not _G.InfJumpEnabled
        InfJumpBtn.Text = _G.InfJumpEnabled and "[K] INF JUMP: ON" or "[K] INF JUMP: OFF"
        InfJumpBtn.BackgroundColor3 = _G.InfJumpEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35) 
    end

    local function toggleAutoHold()
        _G.AutoHoldEnabled = not _G.AutoHoldEnabled
        AutoHoldBtn.Text = _G.AutoHoldEnabled and "[J] AUTO HOLD: ON" or "[J] AUTO HOLD: OFF"
        AutoHoldBtn.BackgroundColor3 = _G.AutoHoldEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35)
        AutoHoldExternalBtn.Visible = _G.AutoHoldEnabled
        
        -- Matikan status aktif dan reset tampilan jika dinonaktifkan di menu
        if not _G.AutoHoldEnabled then
            _G.AutoHoldActive = false
            AutoHoldExternalBtn.Text = "HOLD BOMB"
            AutoHoldExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end

    local function toggleCrosshair()
        _G.CrosshairEnabled = not _G.CrosshairEnabled
        CrosshairBtn.Text = _G.CrosshairEnabled and "[U] CROSSHAIR: ON" or "[U] CROSSHAIR: OFF"
        CrosshairBtn.BackgroundColor3 = _G.CrosshairEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35)
        CrosshairContainer.Visible = _G.CrosshairEnabled
        
        -- Menyembunyikan mouse icon bawaan roblox agar menimpa secara penuh
        pcall(function()
            UserInputService.MouseIconEnabled = not _G.CrosshairEnabled
        end)

        if _G.CrosshairEnabled then
            buildCrosshair(CrosshairContainer, _G.CurrentCrosshairStyle, 1.0)
            -- Paksa langsung icon saat pertama kali diaktifkan
            pcall(function()
                if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
                    Mouse.Icon = TRANSPARENT_ICON
                end
            end)
        else
            pcall(function()
                Mouse.Icon = ""
            end)
        end
    end

    local function toggleResolution()
        _G.ResolutionEnabled = not _G.ResolutionEnabled
        ResBtn.Text = _G.ResolutionEnabled and "[Y] RESOLUTION: ON" or "[Y] RESOLUTION: OFF"
        ResBtn.BackgroundColor3 = _G.ResolutionEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35)
    end

    -- FITUR BARU: TOGGLE AUTO WALK (Mengaktifkan sistem eksternal button)
    local function toggleAutoWalk()
        _G.AutoWalkEnabled = not _G.AutoWalkEnabled
        AutoWalkBtn.Text = _G.AutoWalkEnabled and "[T] AUTO WALK: ON" or "[T] AUTO WALK: OFF"
        AutoWalkBtn.BackgroundColor3 = _G.AutoWalkEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35)
        AutoWalkExternalBtn.Visible = _G.AutoWalkEnabled

        if not _G.AutoWalkEnabled then
            _G.AutoWalkActive = false
            AutoWalkExternalBtn.Text = "AUTO WALK"
            AutoWalkExternalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end

    -- FITUR BARU: TOGGLE AUTO & MANUAL PASS BOMB
    local function toggleAutoPass()
        _G.AutoPassEnabled = not _G.AutoPassEnabled
        AutoPassBtn.Text = _G.AutoPassEnabled and "[P] AUTO PASS: ON" or "[P] AUTO PASS: OFF"
        AutoPassBtn.BackgroundColor3 = _G.AutoPassEnabled and _G.AccentColor or Color3.fromRGB(30, 30, 35)
    end

    local function togglePassMode()
        if _G.PassTargetMode == "Without Bomb" then
            _G.PassTargetMode = "With Bomb"
        else
            _G.PassTargetMode = "Without Bomb"
        end
        PassModeBtn.Text = "TARGET: " .. _G.PassTargetMode:upper()
    end

    -- FUNGSI TOGGLE SHOW EXTERNAL PASS BUTTON
    local function togglePassShow()
        _G.PassExternalVisible = not _G.PassExternalVisible
        PassShowBtn.Text = _G.PassExternalVisible and "SHOW PASS BTN: ON" or "SHOW PASS BTN: OFF"
        PassShowBtn.BackgroundColor3 = _G.PassExternalVisible and _G.AccentColor or Color3.fromRGB(30, 30, 35)
        PassExternalBtn.Visible = _G.PassExternalVisible
    end

    -- [[ BUTTON FUNCTIONALITIES ]]
    ToggleBtn.MouseButton1Click:Connect(toggleFollow)
    FlickBtn.MouseButton1Click:Connect(toggleFlick)
    FOVBtn.MouseButton1Click:Connect(toggleFOV)
    FreezeBtn.MouseButton1Click:Connect(toggleFreeze)
    InfJumpBtn.MouseButton1Click:Connect(toggleInfJump)
    AutoHoldBtn.MouseButton1Click:Connect(toggleAutoHold)
    CrosshairBtn.MouseButton1Click:Connect(toggleCrosshair)
    ResBtn.MouseButton1Click:Connect(toggleResolution)
    AutoWalkBtn.MouseButton1Click:Connect(toggleAutoWalk)
    AutoPassBtn.MouseButton1Click:Connect(toggleAutoPass)
    PassModeBtn.MouseButton1Click:Connect(togglePassMode)
    PassShowBtn.MouseButton1Click:Connect(togglePassShow)

    -- LOCKED PREMIUM FEATURES (Trigger NotifyPremium)
    ModeBtn.MouseButton1Click:Connect(NotifyPremium)
    HJBtn.MouseButton1Click:Connect(NotifyPremium)
    AutoJumpBtn.MouseButton1Click:Connect(NotifyPremium)
    ClassicBtn.MouseButton1Click:Connect(NotifyPremium)
    ProBtn.MouseButton1Click:Connect(NotifyPremium)
    WHNormalBtn.MouseButton1Click:Connect(NotifyPremium)
    WHInstantBtn.MouseButton1Click:Connect(NotifyPremium)
    PotatoToggle.MouseButton1Click:Connect(NotifyPremium)

    LockBtn.MouseButton1Click:Connect(function() isLocked = not isLocked; LockBtn.Text = isLocked and "🔒" or "🔓" end)

    SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            NotifyPremium()
        end
    end)

    -- ==========================================
    -- [[ 6. KEYBIND SYSTEM ]]
    -- ==========================================
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.Q then toggleFollow()
        elseif key == Enum.KeyCode.Z then toggleFlick()
        elseif key == Enum.KeyCode.I then toggleFOV()
        elseif key == Enum.KeyCode.O then toggleFreeze()
        elseif key == Enum.KeyCode.K then toggleInfJump()
        elseif key == Enum.KeyCode.J then toggleAutoHold()
        elseif key == Enum.KeyCode.U then toggleCrosshair()
        elseif key == Enum.KeyCode.Y then toggleResolution()
        elseif key == Enum.KeyCode.T then toggleAutoWalk()
        elseif key == Enum.KeyCode.P then triggerManualPass() -- Keybind P untuk Manual Pass Bomb
        elseif key == Enum.KeyCode.E or key == Enum.KeyCode.X or key == Enum.KeyCode.C or key == Enum.KeyCode.G or key == Enum.KeyCode.H then
            NotifyPremium()
        end
    end)

    -- Dragging Menu Utama
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not isLocked then dragging = true; dragStart = i.Position; startPos = MainFrame.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

    print("Louis Hub FREE V13.5.2: Initialized Successfully with Auto Walk & Auto/Manual Pass Bomb.")
end
