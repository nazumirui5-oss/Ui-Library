-- ========================================================================
-- [[ LOUIS HUB - MM2 FUNCTIONAL EDITION (INTEGRATED & OPTIMIZED) ]]
-- ========================================================================

-- 1. LOAD UI LIBRARY FROM YOUR SOURCE
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/Ui%20Library.lua"))()

-- 2. SETUP MAIN ROBLOX SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========================================================
-- [[ INTERNAL STATE & PHYSICS VARIABLES ]]
-- ========================================================
local SavedCFrame = nil
local SelectedPlayer = nil
local originalVelocity = Vector3.new(0, 0, 0)
local originalRotVelocity = Vector3.new(0, 0, 0)
local FlingFailsafeActive = false
local OriginalCFrameBeforeFling = nil
local SafePlatform = nil

-- ========================================================================
-- [[ EXTERNAL BUTTON TEXT CUSTOMIZATION ]]
-- ========================================================================
local ExtButtonTexts = {
    Aimbot = "AIM",
    GrabGun = "GRAB",
    DoubleJump = "JUMP",
    Spin = "SPIN",
    TpSheriff = "SHERIFF",
    TpMurder = "MURDER",
    FlingMurder = "FLING_M",
    FlingSheriff = "FLING_S",
    SavePos = "SAVE_POS",
    LoadPos = "LOAD_POS",
    KillAll = "KILL_ALL",
    Bhop = "BHOP",
    SafeZone = "SAFE_ZONE"
}

-- ========================================================================
-- [[ EXTERNAL UTILITY BUTTONS & SCALE ENGINE ]]
-- ========================================================================
local ExternalButtonsList = {}

local function RegisterExternalButton(btnWrapper)
    table.insert(ExternalButtonsList, btnWrapper)
end

-- Safe function to dynamically change external button sizes
local function SetButtonSize(btnWrapper, scaleValue)
    pcall(function()
        if type(btnWrapper) == "table" then
            if btnWrapper.SetSize then
                btnWrapper:SetSize(44 * scaleValue)
            elseif typeof(btnWrapper.Instance) == "Instance" then
                btnWrapper.Instance.Size = UDim2.new(0, 44 * scaleValue, 0, 44 * scaleValue)
            end
        elseif typeof(btnWrapper) == "Instance" and btnWrapper:IsA("GuiObject") then
            btnWrapper.Size = UDim2.new(0, 44 * scaleValue, 0, 44 * scaleValue)
        end
    end)
end

-- Safe function to lock/unlock dragging of external buttons
local function SetButtonDragLock(btnWrapper, locked)
    pcall(function()
        if type(btnWrapper) == "table" and btnWrapper.SetDragLock then
            btnWrapper:SetDragLock(locked)
        end
    end)
end

local function UpdateAllButtonsDragLock(locked)
    for _, btn in ipairs(ExternalButtonsList) do
        SetButtonDragLock(btn, locked)
    end
end

-- 3. INTERNAL FEATURE CONFIGURATION (MM2 & MOVEMENT)
local Settings = {
    CameraAimbot = false,
    HitboxExpander = false,
    HitboxVisual = true,
    ESP = false,
    TracersESP = false,
    NameESP = false,
    EspInnocent = true,
    EspSheriff = true,
    EspMurderer = true,
    CoinESP = false,
    AutoGrabGun = false, 
    TargetPart = "HumanoidRootPart",
    HitboxSize = 20,
    FOVSize = 150,
    HideFOVCircle = false,
    AutoFlingMurder = false,
    AutoFlingSheriff = false,
    SpeedWalkEnabled = false,
    SpeedWalkValue = 16,
    AimbotExtEnabled = false,
    GrabGunExtEnabled = false,
    CameraFOVEnabled = false,
    CameraFOVValue = 70,
    FlyEnabled = false,
    FlySpeedValue = 50,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    NoclipEnabled = false,
    InvisibleEnabled = false,
    KillAuraEnabled = false,
    KillAuraRadius = 15,
    DoubleJumpEnabled = false,
    DoubleJumpExtEnabled = false,
    DragLocked = false,
    SpinEnabled = false,
    SpinPower = 30,
    SpinExtEnabled = false,
    
    -- Coin Farm Configuration
    CoinFarmEnabled = false,
    CoinFarmTweenSpeed = 120, -- Default kecepatan tween koin

    -- Additional Integration Features (From Louis Lite HUD)
    InfiniteJump = false,
    AntiVoid = false,
    AntiFling = false,
    TouchFling = false,
    FlingPower = 100,
    
    -- Teleport & External Button Configuration
    TpSheriffExtEnabled = false,
    TpMurderExtEnabled = false,
    FlingMurderExtEnabled = false,
    FlingSheriffExtEnabled = false,
    PosExtEnabled = false,

    -- Imported Settings From New Script
    AutoKillAll = false,
    SafeZoneEnabled = false,
    AutoBhopEnabled = false
}

local OriginalFOV = Camera.FieldOfView

-- ========================================================
-- [[ RE-EXECUTION CLEANUP SYSTEM ]]
-- ========================================================
if _G.LouisConnections then
    for _, conn in pairs(_G.LouisConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
end
_G.LouisConnections = {}

local function SafeConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(_G.LouisConnections, conn)
    return conn
end

if _G.LouisDrawings then
    for _, drawing in pairs(_G.LouisDrawings) do
        pcall(function() drawing:Remove() end)
    end
end
_G.LouisDrawings = {}

local function SafeDrawing(className)
    local drawing = Drawing.new(className)
    table.insert(_G.LouisDrawings, drawing)
    return drawing
end

-- Cleaning Billboard Name ESP from previous execution
for _, player in ipairs(Players:GetPlayers()) do
    pcall(function()
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            local billboard = head and head:FindFirstChild("MM2_NameESP")
            if billboard then billboard:Destroy() end
        end
    end)
end

-- ========================================================
-- [[ GRAPHICS FEATURES: POTATO OPTIMIZATION ]]
-- ========================================================
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

-- ========================================================
-- [[ POSITION & SAFE ZONE UTILITIES ]]
-- ========================================================
local function SavePosition()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        SavedCFrame = root.CFrame
    end
end

local function LoadSavedPosition()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and SavedCFrame then
        root.CFrame = SavedCFrame
    end
end

local function ToggleSafeZone(state)
    Settings.SafeZoneEnabled = state
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if state then
        if not SafePlatform then
            SafePlatform = Instance.new("Part")
            SafePlatform.Size = Vector3.new(20, 1, 20)
            SafePlatform.Position = Vector3.new(0, 1000, 0)
            SafePlatform.Anchored = true
            SafePlatform.CanCollide = true
            SafePlatform.Parent = workspace
        end
        if root then
            SavePosition()
            root.CFrame = SafePlatform.CFrame * CFrame.new(0, 3, 0)
        end
    else
        if SafePlatform then
            SafePlatform:Destroy()
            SafePlatform = nil
        end
        if SavedCFrame and root then
            root.CFrame = SavedCFrame
        end
    end
end

-- ========================================================
-- [[ MM2 ROLE DETECTION LOGIC ]]
-- ========================================================
local function GetMM2Role(Player)
    if not Player or not Player.Character then return "Innocent" end
    local Character = Player.Character
    local Backpack = Player:FindFirstChild("Backpack")
    
    if Character:FindFirstChild("Knife") or (Backpack and Backpack:FindFirstChild("Knife")) then
        return "Murderer"
    elseif Character:FindFirstChild("Gun") or (Backpack and Backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function GetTargetByRole(roleName)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and GetMM2Role(p) == roleName then
                return p
            end
        end
    end
    return nil
end

local function GetTargetForMurderer()
    local Target = nil
    local ShortestDistance = math.huge
    local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local Root = v.Character:FindFirstChild("HumanoidRootPart")
            local Hum = v.Character:FindFirstChildOfClass("Humanoid")
            
            if Root and Hum and Hum.Health > 0 then
                local role = GetMM2Role(v)
                if role == "Innocent" or role == "Sheriff" then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    if OnScreen then
                        local Magnitude = (Vector2.new(ScreenPos.X, ScreenPos.Y) - CenterScreen).Magnitude
                        if Magnitude <= Settings.FOVSize and Magnitude < ShortestDistance then
                            ShortestDistance = Magnitude
                            Target = Root
                        end
                    end
                end
            end
        end
    end
    return Target
end

local function GetTargetForInnocentOrSheriff()
    local Target = nil
    local ShortestDistance = math.huge
    local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local Root = v.Character:FindFirstChild("HumanoidRootPart")
            local Hum = v.Character:FindFirstChildOfClass("Humanoid")
            
            if Root and Hum and Hum.Health > 0 then
                local role = GetMM2Role(v)
                if role == "Murderer" then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    if OnScreen then
                        local Magnitude = (Vector2.new(ScreenPos.X, ScreenPos.Y) - CenterScreen).Magnitude
                        if Magnitude <= Settings.FOVSize and Magnitude < ShortestDistance then
                            ShortestDistance = Magnitude
                            Target = Root
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- ========================================================
-- [[ FEATURE 1 LOGIC: CAMERA AIMBOT (PREDICTION ENGINE) ]]
-- ========================================================
local FOVCircle = SafeDrawing("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Settings.FOVSize
FOVCircle.Filled = false
FOVCircle.Visible = false

SafeConnect(RunService.RenderStepped, function()
    if Settings.CameraAimbot and not Settings.HideFOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Settings.FOVSize
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

local function GetPredictedPosition(targetPart)
    if not targetPart then return nil end
    local BulletSpeed = 230
    local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
    local travelTime = distance / BulletSpeed
    local ping = 0.05
    pcall(function() ping = LocalPlayer:GetNetworkPing() end)
    local totalTime = travelTime + ping
    
    local velocity = targetPart.AssemblyLinearVelocity or targetPart.Velocity or Vector3.new()
    local predictedPos = targetPart.Position + (velocity * totalTime)
    return predictedPos
end

-- AIMBOT WORKS WHEN HOLDING KNIFE/GUN OR AS MURDERER
SafeConnect(RunService.RenderStepped, function()
    if Settings.CameraAimbot and LocalPlayer.Character then
        local HoldsGun = LocalPlayer.Character:FindFirstChild("Gun")
        local HoldsKnife = LocalPlayer.Character:FindFirstChild("Knife")
        
        if (HoldsGun and HoldsGun:IsA("Tool")) or (HoldsKnife and HoldsKnife:IsA("Tool")) then
            local MyRole = GetMM2Role(LocalPlayer)
            local TargetPart = (MyRole == "Murderer") and GetTargetForMurderer() or GetTargetForInnocentOrSheriff()
            
            if TargetPart then
                local PredictedPos = GetPredictedPosition(TargetPart)
                if PredictedPos then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, PredictedPos)
                end
            end
        end
    end
end)

-- ========================================================
-- [[ FEATURE 2 LOGIC: DOUBLE JUMP & INFINITE JUMP ]]
-- ========================================================
local HasDoubleJumped = false
local CanDoubleJump = false

local function SetupDoubleJump(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    local stateConn = humanoid.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Landed then
            HasDoubleJumped = false
            CanDoubleJump = false
        elseif new == Enum.HumanoidStateType.Freefall then
            task.wait(0.12)
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                CanDoubleJump = true
            end
        end
    end)
    table.insert(_G.LouisConnections, stateConn)
end

local DoubleJumpReq = UserInputService.JumpRequest:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and Settings.InfiniteJump then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    if humanoid and root and humanoid.Health > 0 and Settings.DoubleJumpEnabled then
        if CanDoubleJump and not HasDoubleJumped then
            HasDoubleJumped = true
            root.Velocity = Vector3.new(root.Velocity.X, humanoid.JumpPower * 1.15, root.Velocity.Z)
        end
    end
end)
table.insert(_G.LouisConnections, DoubleJumpReq)

-- Bunnyhop Logic Loop
SafeConnect(RunService.Heartbeat, function()
    if Settings.AutoBhopEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and root and humanoid.MoveDirection.Magnitude > 0 then
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ========================================================
-- [[ FEATURE 3 LOGIC: GUN GRABBER ENGINE ]]
-- ========================================================
local IsGrabbing = false
local function SafeInstantTween(targetPart)
    if not targetPart or IsGrabbing then return end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if root and humanoid and humanoid.Health > 0 then
        IsGrabbing = true
        local originalCFrame = root.CFrame
        local targetCFrame = targetPart.CFrame + Vector3.new(0, 1.5, 0)
        
        root.CFrame = targetCFrame
        
        local timeout = 0
        while timeout < 1.5 do
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
                break
            end
            root.CFrame = targetCFrame
            task.wait(0.05)
            timeout = timeout + 0.05
        end
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = originalCFrame
        end
        
        task.wait(0.3)
        IsGrabbing = false
    end
end

local function ScanForDroppedGun()
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object.Name == "GunDrop" then
            local targetPart = object:IsA("BasePart") and object or object:FindFirstChildOfClass("BasePart")
            if targetPart then return targetPart end
        end
    end
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("TouchTransmitter") and object.Parent and object.Parent.Name:lower():find("gun") then
            local rootParent = object.Parent
            if not rootParent:FindFirstAncestorOfClass("Model") or not Players:GetPlayerFromCharacter(rootParent:FindFirstAncestorOfClass("Model")) then
                return object.Parent
            end
        end
    end
    return nil
end

local function ApplyGunOutline(gunPart)
    if not gunPart or gunPart:FindFirstChild("LouisGunOutline") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "LouisGunOutline"
    highlight.FillColor = Color3.fromRGB(0, 100, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = gunPart
    highlight.Parent = gunPart
end

local function ClearGunOutlines()
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object.Name == "LouisGunOutline" then object:Destroy() end
    end
end

task.spawn(function()
    while true do
        if Settings.AutoGrabGun or Settings.ESP then
            local activeGun = ScanForDroppedGun()
            if activeGun then
                if Settings.ESP then ApplyGunOutline(activeGun) end
                if Settings.AutoGrabGun then SafeInstantTween(activeGun) end
            end
        else
            ClearGunOutlines()
        end
        task.wait(0.2)
    end
end)

-- ========================================================
-- [[ COIN DETECTION AND FARM ENGINE (RECURSIVE & TWEEN) ]]
-- ========================================================
local CollectedCoins = {}
local ScannedCoins = {}
local lastCoinScan = 0

-- Bersihkan daftar koin yang sudah diambil secara berkala
task.spawn(function()
    while true do
        task.wait(5)
        table.clear(CollectedCoins)
    end
end)

-- Melakukan pencarian koin secara mendalam (rekursif) di seluruh Workspace
local function DeepScanWorkspaceCoins()
    table.clear(ScannedCoins)
    for _, object in ipairs(Workspace:GetDescendants()) do
        local isCoin = false
        local coinPart = nil
        
        -- Deteksi berdasarkan Nama Part
        if object:IsA("BasePart") then
            local nameLower = object.Name:lower()
            if nameLower == "coin" or nameLower == "maincoin" or nameLower == "coin_server" or nameLower:find("coin") then
                isCoin = true
                coinPart = object
            end
        end
        
        -- Deteksi berdasarkan Highlight ESP Koin (Cadangan)
        if not isCoin and object.Name == "LouisCoinESP" and object.Parent and object.Parent:IsA("BasePart") then
            isCoin = true
            coinPart = object.Parent
        end
        
        -- Deteksi berdasarkan CoinContainer
        if not isCoin and object.Name == "CoinContainer" then
            for _, child in ipairs(object:GetDescendants()) do
                if child:IsA("BasePart") then
                    table.insert(ScannedCoins, child)
                end
            end
        end
        
        if isCoin and coinPart then
            table.insert(ScannedCoins, coinPart)
        end
    end
end

local function GetNearestCoin()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    -- Lakukan pemindaian mendalam ke seluruh Workspace setiap 0.5 detik (mencegah lag FPS)
    if os.clock() - lastCoinScan > 0.5 then
        pcall(DeepScanWorkspaceCoins)
        lastCoinScan = os.clock()
    end
    
    local closestCoin = nil
    local shortestDistance = math.huge
    
    for _, coinPart in ipairs(ScannedCoins) do
        if coinPart and coinPart.Parent and not CollectedCoins[coinPart] then
            local distance = (root.Position - coinPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestCoin = coinPart
            end
        end
    end
    
    return closestCoin
end

local currentCoinTween = nil
local function CollectCoin(coinPart)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not coinPart then return end
    
    -- Tandai koin agar tidak diambil berulang kali
    CollectedCoins[coinPart] = true
    if coinPart.Parent then
        CollectedCoins[coinPart.Parent] = true
    end

    -- Hitung jarak dan waktu tween berdasarkan kecepatan slider
    local distance = (root.Position - coinPart.Position).Magnitude
    local speed = Settings.CoinFarmTweenSpeed or 120
    local tweenTime = distance / speed
    
    -- Amankan kecepatan fisik karakter agar gerakan tetap stabil
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    local tweenInfo = TweenInfo.new(
        tweenTime, 
        Enum.EasingStyle.Linear, 
        Enum.EasingDirection.Out
    )
    
    local targetCFrame = coinPart.CFrame * CFrame.new(0, 0.5, 0)
    
    if currentCoinTween then pcall(function() currentCoinTween:Cancel() end) end
    
    -- Eksekusi Tween Pergerakan Meluncur
    currentCoinTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    currentCoinTween:Play()
    
    -- Menunggu tween selesai secara fleksibel atau berhenti jika modul dimatikan
    local completed = false
    local conn
    conn = currentCoinTween.Completed:Connect(function()
        completed = true
        if conn then conn:Disconnect() end
    end)
    
    while not completed and Settings.CoinFarmEnabled and coinPart and coinPart.Parent do
        task.wait()
    end
    
    if conn then conn:Disconnect() end
    if currentCoinTween then currentCoinTween:Cancel() end
    
    -- Jeda jeda instan agar server dapat memproses poin koin masuk
    task.wait(0.1)
end

task.spawn(function()
    while true do
        if Settings.CoinFarmEnabled then
            local nearest = GetNearestCoin()
            if nearest then
                CollectCoin(nearest)
            else
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- ========================================================
-- [[ FEATURE 4 LOGIC: KILL AURA, AUTO KILL ALL, TELEPORT ]]
-- ========================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if Settings.KillAuraEnabled and char and root then
            local knife = char:FindFirstChild("Knife")
            if knife and GetMM2Role(LocalPlayer) == "Murderer" then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local tRoot = p.Character.HumanoidRootPart
                        local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                        
                        if tHum and tHum.Health > 0 then
                            local distance = (root.Position - tRoot.Position).Magnitude
                            if distance <= Settings.KillAuraRadius then
                                pcall(function()
                                    knife:Activate()
                                    firetouchinterest(tRoot, knife.Handle, 0)
                                    firetouchinterest(tRoot, knife.Handle, 1)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO-KILL ALL LOGIC (Murderer Loop)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Settings.AutoKillAll and LocalPlayer.Character and GetMM2Role(LocalPlayer) == "Murderer" then
            local knife = LocalPlayer.Character:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))
            if knife then
                if not LocalPlayer.Character:FindFirstChild("Knife") then
                    knife.Parent = LocalPlayer.Character
                end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local tRoot = p.Character.HumanoidRootPart
                        local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if tHum and tHum.Health > 0 then
                            pcall(function()
                                LocalPlayer.Character.HumanoidRootPart.CFrame = tRoot.CFrame * CFrame.new(0, 0, -1)
                                knife:Activate()
                                firetouchinterest(tRoot, knife.Handle, 0)
                                firetouchinterest(tRoot, knife.Handle, 1)
                            end)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end)

local function TeleportAllPlayersToMe()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not root or GetMM2Role(LocalPlayer) ~= "Murderer" then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = p.Character.HumanoidRootPart
            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
            if tHum and tHum.Health > 0 then
                pcall(function() tRoot.CFrame = root.CFrame * CFrame.new(0, 0, -2) end)
            end
        end
    end
end

-- ========================================================
-- [[ COIN ESP ENGINE (WITH DEEP SCAN ENHANCEMENTS) ]]
-- ========================================================
local function ApplyCoinESP()
    if not Settings.CoinESP then 
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "LouisCoinESP" then v:Destroy() end
        end
        return 
    end
    
    local container = Workspace:FindFirstChild("CoinContainer", true)
    local coinsToHighlight = {}
    
    if container then
        for _, coin in ipairs(container:GetChildren()) do
            table.insert(coinsToHighlight, coin)
        end
    else
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Coin_Server" or v.Name == "Coin" or v.Name == "MainCoin" then
                table.insert(coinsToHighlight, v)
            end
        end
    end

    for _, coin in ipairs(coinsToHighlight) do
        local coinPart = coin:FindFirstChild("MainCoin", true) 
            or coin:FindFirstChild("Coin", true) 
            or coin:FindFirstChildOfClass("BasePart")
            or (coin:IsA("BasePart") and coin)
            
        if coinPart and not coinPart:FindFirstChild("LouisCoinESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "LouisCoinESP"
            highlight.FillColor = Color3.fromRGB(255, 215, 0) -- Gold Color
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Adornee = coinPart
            highlight.Parent = coinPart
        end
    end
end

task.spawn(function()
    while true do
        if Settings.CoinESP then
            pcall(ApplyCoinESP)
        else
            pcall(function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v.Name == "LouisCoinESP" then v:Destroy() end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- ========================================================
-- [[ FEATURE 5 LOGIC: TELEPORTS & TARGET SELECTIONS ]]
-- ========================================================
local function TeleportToSheriff()
    local target = GetTargetByRole("Sheriff")
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end

local function TeleportToMurderer()
    local target = GetTargetByRole("Murderer")
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end

local function TpToPlayer(targetPlayer)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end

-- ========================================================================
-- [[ OPTIMIZED TARGET FLING (LONGER DURATION & PRECISION) ]]
-- ========================================================================
local function FlingPlayer(targetPlayer)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local oldPos = root.CFrame
        local targetRoot = targetPlayer.Character.HumanoidRootPart
        local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        SavePosition()
        local originalFlingState = Settings.TouchFling
        Settings.TouchFling = true
        
        task.spawn(function()
            for i = 1, 150 do
                if not targetRoot or not targetHum or targetHum.Health <= 0 or not root or not char:FindFirstChild("HumanoidRootPart") then
                    break
                end
                root.CFrame = targetRoot.CFrame * CFrame.new(math.random(-1, 1) * 0.1, 0, math.random(-1, 1) * 0.1)
                task.wait(0.02)
            end
            Settings.TouchFling = originalFlingState
            root.CFrame = oldPos
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
    end
end

-- ========================================================================
-- [[ MOBILITY PHYSICS ENGINE (FLY, NOCLIP, SPIN, FLING, SPEED, JUMP) ]]
-- ========================================================================
local SpinVelocity
local FlingVelocity

-- Penanganan Noclip Terpusat
SafeConnect(RunService.Stepped, function()
    if (Settings.NoclipEnabled or Settings.CoinFarmEnabled or IsGrabbing) and LocalPlayer.Character then
        for _, child in ipairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") then child.CanCollide = false end
        end
    end
end)

local function ToggleNoclip(state)
    Settings.NoclipEnabled = state
    if not state and LocalPlayer.Character and not Settings.CoinFarmEnabled then
        for _, child in ipairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") then child.CanCollide = true end
        end
    end
end

-- HEARTBEAT PHYSICS LOOP
SafeConnect(RunService.Heartbeat, function()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if root and humanoid and humanoid.Health > 0 then
        if Settings.SpeedWalkEnabled then 
            humanoid.WalkSpeed = Settings.SpeedWalkValue 
        else
            humanoid.WalkSpeed = 16
        end
        
        if Settings.JumpPowerEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Settings.JumpPowerValue
        else
            humanoid.UseJumpPower = false
            humanoid.JumpPower = 50
        end
        
        if Settings.CameraFOVEnabled then
            Camera.FieldOfView = Settings.CameraFOVValue
        else
            Camera.FieldOfView = OriginalFOV
        end

        if Settings.InvisibleEnabled then
            for _, child in ipairs(character:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("Decal") then
                    if child.Name ~= "HumanoidRootPart" then child.Transparency = 1 end
                end
            end
        end

        if Settings.TouchFling then
            local multiplier = Settings.FlingPower * 1000
            originalVelocity = root.AssemblyLinearVelocity
            originalRotVelocity = root.AssemblyAngularVelocity
            
            root.AssemblyLinearVelocity = Vector3.new(multiplier, multiplier, multiplier)
            root.AssemblyAngularVelocity = Vector3.new(0, multiplier, 0)
        end

        -- Logika Anti-Fling yang dioptimalkan
        if Settings.AntiFling and not Settings.TouchFling then
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            if root.AssemblyLinearVelocity.Magnitude > 75 then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

SafeConnect(RunService.RenderStepped, function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and Settings.TouchFling then
        root.AssemblyLinearVelocity = originalVelocity
        root.AssemblyAngularVelocity = originalRotVelocity
    end
end)

task.spawn(function()
    while true do
        if Settings.AntiVoid and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y < -80 then
                if SavedCFrame then
                    root.CFrame = SavedCFrame
                else
                    local spawns = Workspace:FindFirstChildOfClass("SpawnLocation")
                    if not spawns and Workspace:FindFirstChild("SpawnLocations") then
                        spawns = Workspace.SpawnLocations:FindFirstChildOfClass("SpawnLocation")
                    end
                    if spawns then
                        root.CFrame = spawns.CFrame * CFrame.new(0, 3, 0)
                    end
                end
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
        task.wait(0.5)
    end
end)

-- Mencegah tabrakan fisik lokal saat Anti-Fling menyala
task.spawn(function()
    while true do
        if Settings.AntiFling then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- ========================================================
-- [[ FLY SYSTEM AND INPUT (MOBILE & PC COMPATIBLE) ]]
-- ========================================================
local function GetFlyDirection()
    local direction = Vector3.new(0, 0, 0)
    
    -- PC Keyboard Input
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
    end
    
    -- Mobile Joystick / Dynamic Touch Integration
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.MoveDirection.Magnitude > 0 then
            local camLook = Camera.CFrame.LookVector
            direction = direction + (hum.MoveDirection + Vector3.new(0, camLook.Y * 1.2, 0))
        end
        
        if hum.Jump then
            direction = direction + Vector3.new(0, 1, 0)
        end
    end
    
    if direction.Magnitude > 0 then
        return direction.Unit
    end
    return Vector3.new(0, 0, 0)
end

local FlyConnection
local function UpdateFlyState(state)
    Settings.FlyEnabled = state
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if FlyConnection then FlyConnection:Disconnect() end
    if hum then hum.PlatformStand = false end
    
    if not state then return end
    
    if root and hum then
        hum.PlatformStand = true
        
        FlyConnection = SafeConnect(RunService.RenderStepped, function(dt)
            if not Settings.FlyEnabled or not root or not hum or hum.Health <= 0 then
                if FlyConnection then FlyConnection:Disconnect() end
                hum.PlatformStand = false
                return
            end
            
            root.AssemblyLinearVelocity = Vector3.new(0, 0.05, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            local look = Camera.CFrame.LookVector
            root.CFrame = CFrame.lookAt(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
            
            local dir = GetFlyDirection()
            if dir.Magnitude > 0 then
                root.CFrame = root.CFrame + (dir * (Settings.FlySpeedValue * dt))
            end
        end)
    end
end

-- SPIN SYSTEM (Physical Angular Velocity)
local function UpdateSpinState(state)
    Settings.SpinEnabled = state
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not state then
        if SpinVelocity then SpinVelocity:Destroy() end
        return
    end
    
    if root then
        if SpinVelocity then SpinVelocity:Destroy() end
        SpinVelocity = Instance.new("BodyAngularVelocity")
        SpinVelocity.MaxTorque = Vector3.new(0, 9e9, 0)
        SpinVelocity.AngularVelocity = Vector3.new(0, Settings.SpinPower, 0)
        SpinVelocity.Parent = root
    end
end

-- ========================================================================
-- [[ INSTANT FLING ]]
-- ========================================================================
local function UpdateFlingState(role, state)
    if role == "Murderer" then
        Settings.AutoFlingMurder = state
    elseif role == "Sheriff" then
        Settings.AutoFlingSheriff = state
    end
end

task.spawn(function()
    while true do
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if root and humanoid and humanoid.Health > 0 then
            if Settings.AutoFlingMurder or Settings.AutoFlingSheriff then
                local targetRole = Settings.AutoFlingMurder and "Murderer" or "Sheriff"
                local targetPlayer = GetTargetByRole(targetRole)

                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if not FlingFailsafeActive then
                        FlingFailsafeActive = true
                        OriginalCFrameBeforeFling = root.CFrame
                    end

                    local tRoot = targetPlayer.Character.HumanoidRootPart
                    root.CFrame = tRoot.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                    root.Velocity = Vector3.new(99999, 99999, 99999)
                else
                    if FlingFailsafeActive then
                        Settings.AutoFlingMurder = false
                        Settings.AutoFlingSheriff = false
                        root.Velocity = Vector3.new(0, 0, 0)
                        root.RotVelocity = Vector3.new(0, 0, 0)
                        task.wait(0.1)
                        if OriginalCFrameBeforeFling then
                            root.CFrame = OriginalCFrameBeforeFling
                        end
                        FlingFailsafeActive = false
                        OriginalCFrameBeforeFling = nil
                        
                        if _G.SyncFlingButtons then _G.SyncFlingButtons() end
                    end
                end
            end
        end
        task.wait()
    end
end)

-- ========================================================
-- [[ FEATURE 6 LOGIC: NAME ESP & HIGHLIGHT ESP SYSTEM ]]
-- ========================================================
local function ApplyNameESP(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    
    local billboard = head:FindFirstChild("MM2_NameESP")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "MM2_NameESP"
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        
        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        billboard.Parent = head
    end
    
    local role = GetMM2Role(player)
    local targetColor = Color3.fromRGB(0, 225, 0)
    if role == "Murderer" then targetColor = Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then targetColor = Color3.fromRGB(0, 0, 225) end
    
    local label = billboard:FindFirstChildOfClass("TextLabel")
    if label then
        label.Text = player.Name .. " [" .. role .. "]"
        label.TextColor3 = targetColor
    end
    
    local shouldShow = false
    if Settings.ESP and Settings.NameESP then
        if role == "Murderer" and Settings.EspMurderer then shouldShow = true
        elseif role == "Sheriff" and Settings.EspSheriff then shouldShow = true
        elseif role == "Innocent" and Settings.EspInnocent then shouldShow = true end
    end
    billboard.Enabled = shouldShow
end

-- ========================================================
-- [[ MAIN VISUALS LOOP (HITBOX EXPANDER, ESP & TRACERS) ]]
-- ========================================================
local function ClearNameESP(player)
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        local billboard = head and head:FindFirstChild("MM2_NameESP")
        if billboard then billboard:Destroy() end
    end
end

local ActiveTracers = {}
local function ClearAllTracers()
    for _, tracer in pairs(ActiveTracers) do
        tracer.Visible = false
        tracer:Remove()
    end
    ActiveTracers = {}
end

SafeConnect(RunService.RenderStepped, function()
    if not Settings.TracersESP then ClearAllTracers() end

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            
            if Root and Humanoid and Humanoid.Health > 0 then
                local Role = GetMM2Role(Player)
                local passesFilter = false
                if Role == "Murderer" and Settings.EspMurderer then passesFilter = true
                elseif Role == "Sheriff" and Settings.EspSheriff then passesFilter = true
                elseif Role == "Innocent" and Settings.EspInnocent then passesFilter = true end
                
                -- Hitbox Expander
                if Settings.HitboxExpander then
                    Root.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    if not IsGrabbing and not FlingFailsafeActive then Root.CanCollide = false end
                    if Settings.HitboxVisual then
                        Root.Transparency = 0.7
                        Root.Color = Color3.fromRGB(255, 0, 0)
                        Root.Material = Enum.Material.SmoothPlastic
                    else
                        Root.Transparency = 1
                    end
                else
                    Root.Size = Vector3.new(2, 2, 1)
                    Root.Transparency = 1
                end

                local TargetColor = Color3.fromRGB(0, 225, 0)
                if Role == "Murderer" then TargetColor = Color3.fromRGB(255, 0, 0)
                elseif Role == "Sheriff" then TargetColor = Color3.fromRGB(0, 0, 225) end

                -- ESP Highlight
                local Highlight = Player.Character:FindFirstChild("MM2_ESP")
                if Settings.ESP and passesFilter then
                    if not Highlight then
                        Highlight = Instance.new("Highlight")
                        Highlight.Name = "MM2_ESP"
                        Highlight.Parent = Player.Character
                        Highlight.FillTransparency = 0.6
                        Highlight.OutlineTransparency = 0.1
                    end
                    Highlight.FillColor = TargetColor
                    Highlight.OutlineColor = TargetColor
                else
                    if Highlight then Highlight:Destroy() end
                end

                -- Billboard ESP
                if Settings.ESP and Settings.NameESP and passesFilter then
                    ApplyNameESP(Player)
                else
                    ClearNameESP(Player)
                end

                -- Tracers ESP
                if Settings.TracersESP and passesFilter then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    if OnScreen then
                        local Tracer = ActiveTracers[Player.Name]
                        if not Tracer then
                            Tracer = SafeDrawing("Line")
                            Tracer.Thickness = 1.5
                            Tracer.Transparency = 0.8
                            ActiveTracers[Player.Name] = Tracer
                        end
                        Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                        Tracer.Color = TargetColor
                        Tracer.Visible = true
                    else
                        if ActiveTracers[Player.Name] then ActiveTracers[Player.Name].Visible = false end
                    end
                else
                    if ActiveTracers[Player.Name] then
                        ActiveTracers[Player.Name].Visible = false
                        ActiveTracers[Player.Name]:Remove()
                        ActiveTracers[Player.Name] = nil
                    end
                end
            end
        else
            if Player.Character then
                if Player.Character:FindFirstChild("MM2_ESP") then Player.Character:FindFirstChild("MM2_ESP"):Destroy() end
                ClearNameESP(Player)
            end
            if ActiveTracers[Player.Name] then
                ActiveTracers[Player.Name].Visible = false
                ActiveTracers[Player.Name]:Remove()
                ActiveTracers[Player.Name] = nil
            end
        end
    end
end)

-- ========================================================================
-- [[ EXTERNAL BUTTON INITIALIZATION FROM UI LIBRARY ]]
-- ========================================================================
local ExtAimbotBtn = Library:CreateExternalButton("Aimbot", ExtButtonTexts.Aimbot, UDim2.new(0, 20, 0.5, -55), function()
    Settings.CameraAimbot = not Settings.CameraAimbot
    Library:Notify("Aimbot Toggle", "Status: " .. (Settings.CameraAimbot and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtAimbotBtn)

local ExtGrabBtn = Library:CreateExternalButton("GrabGun", ExtButtonTexts.GrabGun, UDim2.new(0, 20, 0.5, -10), function()
    local activeGun = ScanForDroppedGun()
    if activeGun then
        SafeInstantTween(activeGun)
        Library:Notify("Gun Grabber", "Attempting manual gun snatch!", 2)
    else
        Library:Notify("Gun Grabber", "No dropped gun found on map.", 2)
    end
end)
RegisterExternalButton(ExtGrabBtn)

local ExtDoubleJumpBtn = Library:CreateExternalButton("DoubleJump", ExtButtonTexts.DoubleJump, UDim2.new(0, 20, 0.5, 35), function()
    Settings.DoubleJumpEnabled = not Settings.DoubleJumpEnabled
    Library:Notify("Double Jump", "Status: " .. (Settings.DoubleJumpEnabled and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtDoubleJumpBtn)

local ExtSpinBtn = Library:CreateExternalButton("Spin", ExtButtonTexts.Spin, UDim2.new(0, 20, 0.5, 80), function()
    Settings.SpinEnabled = not Settings.SpinEnabled
    UpdateSpinState(Settings.SpinEnabled)
    Library:Notify("Spin Bot", "Status: " .. (Settings.SpinEnabled and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtSpinBtn)

local ExtTpSheriffBtn = Library:CreateExternalButton("TpSheriff", ExtButtonTexts.TpSheriff, UDim2.new(0, 70, 0.5, -55), function()
    TeleportToSheriff()
    Library:Notify("Teleport", "Teleporting to Sheriff...", 1.5)
end)
RegisterExternalButton(ExtTpSheriffBtn)

local ExtTpMurderBtn = Library:CreateExternalButton("TpMurderer", ExtButtonTexts.TpMurder, UDim2.new(0, 70, 0.5, -10), function()
    TeleportToMurderer()
    Library:Notify("Teleport", "Teleporting to Murderer...", 1.5)
end)
RegisterExternalButton(ExtTpMurderBtn)

local ExtFlingMurderBtn = Library:CreateExternalButton("FlingMurder", ExtButtonTexts.FlingMurder, UDim2.new(0, 70, 0.5, 35), function()
    Settings.AutoFlingMurder = not Settings.AutoFlingMurder
    if Settings.AutoFlingMurder then 
        Settings.AutoFlingSheriff = false 
        UpdateFlingState("Sheriff", false)
    end
    UpdateFlingState("Murderer", Settings.AutoFlingMurder)
    if _G.SyncFlingButtons then _G.SyncFlingButtons() end
    Library:Notify("Fling Hack", "Fling Murderer: " .. (Settings.AutoFlingMurder and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtFlingMurderBtn)

local ExtFlingSheriffBtn = Library:CreateExternalButton("FlingSheriff", ExtButtonTexts.FlingSheriff, UDim2.new(0, 70, 0.5, 80), function()
    Settings.AutoFlingSheriff = not Settings.AutoFlingSheriff
    if Settings.AutoFlingSheriff then 
        Settings.AutoFlingMurder = false 
        UpdateFlingState("Murderer", false)
    end
    UpdateFlingState("Sheriff", Settings.AutoFlingSheriff)
    if _G.SyncFlingButtons then _G.SyncFlingButtons() end
    Library:Notify("Fling Hack", "Fling Sheriff: " .. (Settings.AutoFlingSheriff and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtFlingSheriffBtn)

local ExtSavePosBtn = Library:CreateExternalButton("SavePos", ExtButtonTexts.SavePos, UDim2.new(0, 120, 0.5, -55), function()
    SavePosition()
    Library:Notify("POS Saved", "Saved local coordinates successfully!", 1.5)
end)
RegisterExternalButton(ExtSavePosBtn)

local ExtLoadPosBtn = Library:CreateExternalButton("LoadPos", ExtButtonTexts.LoadPos, UDim2.new(0, 120, 0.5, -10), function()
    if SavedCFrame then
        LoadSavedPosition()
        Library:Notify("POS Loaded", "Teleported to saved coordinate!", 1.5)
    else
        Library:Notify("POS Error", "No saved coordinate. Save position first!", 2)
    end
end)
RegisterExternalButton(ExtLoadPosBtn)

-- External Button Auto Kill All
local ExtKillAllBtn = Library:CreateExternalButton("KillAll", ExtButtonTexts.KillAll, UDim2.new(0, 120, 0.5, 35), function()
    Settings.AutoKillAll = not Settings.AutoKillAll
    Library:Notify("Auto Kill All", "Status: " .. (Settings.AutoKillAll and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtKillAllBtn)

-- External Button Auto Bunnyhop
local ExtBhopBtn = Library:CreateExternalButton("Bhop", ExtButtonTexts.Bhop, UDim2.new(0, 120, 0.5, 80), function()
    Settings.AutoBhopEnabled = not Settings.AutoBhopEnabled
    Library:Notify("Auto Bhop", "Status: " .. (Settings.AutoBhopEnabled and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtBhopBtn)

-- External Button Safe Zone Platform
local ExtSafeZoneBtn = Library:CreateExternalButton("SafeZone", ExtButtonTexts.SafeZone, UDim2.new(0, 170, 0.5, -55), function()
    Settings.SafeZoneEnabled = not Settings.SafeZoneEnabled
    ToggleSafeZone(Settings.SafeZoneEnabled)
    Library:Notify("Safe Zone", "Status: " .. (Settings.SafeZoneEnabled and "ON" or "OFF"), 1.5)
end)
RegisterExternalButton(ExtSafeZoneBtn)

ExtAimbotBtn:SetVisible(false)
ExtGrabBtn:SetVisible(false)
ExtDoubleJumpBtn:SetVisible(false)
ExtSpinBtn:SetVisible(false)
ExtTpSheriffBtn:SetVisible(false)
ExtTpMurderBtn:SetVisible(false)
ExtFlingMurderBtn:SetVisible(false)
ExtFlingSheriffBtn:SetVisible(false)
ExtSavePosBtn:SetVisible(false)
ExtLoadPosBtn:SetVisible(false)
ExtKillAllBtn:SetVisible(false)
ExtBhopBtn:SetVisible(false)
ExtSafeZoneBtn:SetVisible(false)

-- ========================================================================
-- [[ MAIN MENU STRUCTURE ]]
-- ========================================================================
local Window = Library:CreateWindow("LOUIS MM2 EDITION", "discord.gg/P2FEVBz2PG")
Window:BindToggleKey(Enum.KeyCode.RightControl)

Library:Notify("LOUIS HUB INSTANTIATED", "Press RightControl to hide/show Main UI.", 4)

-- --- TAB 1: MAIN INFO ---
local TabMain = Window:CreateTab("Welcome", "rbxassetid://6023426915")
TabMain:CreateParagraph("Welcome!", "Hello " .. LocalPlayer.Name .. "!\nThank you for executing Louis Premium Edition.")
TabMain:CreateParagraph("UI Instructions", "Keybind to open/hide menu: RightControl\nYou can toggle external buttons from the settings.")

TabMain:CreateParagraph("Official Community", "Join our Discord server to get the latest update information, report issues, and interact directly with the developers and the rest of the community!")
TabMain:CreateButton("Copy Discord Server Link", function()
    if setclipboard then
        setclipboard("https://discord.gg/P2FEVBz2PG")
        Library:Notify("Discord Link", "Discord link copied successfully to your clipboard!", 2)
    else
        Library:Notify("Error", "Your exploit does not support clipboard copying.", 2.5)
    end
end)

TabMain:CreateButton("Activate Potato Graphics Optimization", function()
    ApplyPotato()
    Library:Notify("Potato Mode", "Graphics optimized successfully!", 3)
end)

-- --- TAB 2: COMBAT ---
local TabCombat = Window:CreateTab("Combat Settings", "rbxassetid://4483345998")

TabCombat:CreateParagraph("Auto Kill Mechanics", "Fits murderer roles only.")
local KillAuraToggle = TabCombat:CreateToggle("Kill Aura Auto-Slash", false, function(state)
    Settings.KillAuraEnabled = state
end)

TabCombat:CreateSlider("Kill Aura Radius (Studs)", 5, 50, Settings.KillAuraRadius, function(val)
    Settings.KillAuraRadius = val
end)

TabCombat:CreateToggle("Auto-Kill All (Murderer Loop)", false, function(state)
    Settings.AutoKillAll = state
end)

TabCombat:CreateToggle("Show Auto-Kill All Button [KA]", false, function(state)
    ExtKillAllBtn:SetVisible(state)
end)

TabCombat:CreateButton("Teleport & Stack All Players to Me", function()
    TeleportAllPlayersToMe()
    Library:Notify("Combat Teleport", "Stacked all players for ez kill!", 2.5)
end)

TabCombat:CreateParagraph("Touch Fling (Collision System)", "Instant physical rotation style when character touches the enemy.")
TabCombat:CreateToggle("Activate Touch Fling", false, function(state)
    Settings.TouchFling = state
end)

TabCombat:CreateSlider("Fling Velocity Power multiplier", 1, 200, Settings.FlingPower, function(val)
    Settings.FlingPower = val
end)

TabCombat:CreateToggle("Anti Fling (Collision Resistance)", false, function(state)
    Settings.AntiFling = state
end)

TabCombat:CreateParagraph("Aimbot & Prediction", "Aimbot locks to murderer or targets based on role.")
local AimbotToggle = TabCombat:CreateToggle("Aim Assist Lock (Holding Gun/Knife)", false, function(state)
    Settings.CameraAimbot = state
end)

TabCombat:CreateToggle("Show Master Aimbot Button [A]", false, function(state)
    Settings.AimbotExtEnabled = state
    ExtAimbotBtn:SetVisible(state)
end)

TabCombat:CreateSlider("Aimbot FOV Range (Studs)", 50, 400, Settings.FOVSize, function(val)
    Settings.FOVSize = val
end)

TabCombat:CreateToggle("Hide Aimbot FOV Circle", false, function(state)
    Settings.HideFOVCircle = state
end)

TabCombat:CreateToggle("Camera FOV Override", false, function(state)
    Settings.CameraFOVEnabled = state
end)

TabCombat:CreateSlider("Camera Field Of View", 30, 120, Settings.CameraFOVValue, function(val)
    Settings.CameraFOVValue = val
end)

-- --- TAB 3: VISUAL & ESP ---
local TabVisuals = Window:CreateTab("Visual Hacks", "rbxassetid://4483345998")

TabVisuals:CreateToggle("Activate Esp Outline + Drop Gun Outline", false, function(state)
    Settings.ESP = state
    if not state then ClearGunOutlines() end
end)

TabVisuals:CreateToggle("Tracers Lines (To Players)", false, function(state)
    Settings.TracersESP = state
    if not state then ClearAllTracers() end
end)

TabVisuals:CreateToggle("Show Billboard Names + Roles", false, function(state)
    Settings.NameESP = state
end)

TabVisuals:CreateToggle("Coin Highlight ESP", false, function(state)
    Settings.CoinESP = state
    if not state then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "LouisCoinESP" then v:Destroy() end
        end
    end
end)

TabVisuals:CreateParagraph("Filter ESP Targets", "Filter who glows in ESP.")
TabVisuals:CreateToggle("Render Murderer Glow", true, function(state)
    Settings.EspMurderer = state
end)

TabVisuals:CreateToggle("Render Sheriff Glow", true, function(state)
    Settings.EspSheriff = state
end)

TabVisuals:CreateToggle("Render Innocent Glow", true, function(state)
    Settings.EspInnocent = state
end)

TabVisuals:CreateParagraph("Hitbox Scaling", "Increases targets Hitbox.")
TabVisuals:CreateToggle("Expand Player Hitbox", false, function(state)
    Settings.HitboxExpander = state
end)

TabVisuals:CreateToggle("Show Hitbox (Red Box)", true, function(state)
    Settings.HitboxVisual = state
end)

TabVisuals:CreateSlider("Hitbox Size Modifier", 2, 100, Settings.HitboxSize, function(val)
    Settings.HitboxSize = val
end)

-- --- TAB 4: MOVEMENT & UTILITY ---
local TabMovement = Window:CreateTab("Utility Movement", "rbxassetid://4483362458")

TabMovement:CreateParagraph("Speed & Jump Modifiers", "Modify walk speed and jump power.")
TabMovement:CreateToggle("Custom Walk Speed", false, function(state)
    Settings.SpeedWalkEnabled = state
    if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

TabMovement:CreateSlider("Speed Force Value", 16, 120, Settings.SpeedWalkValue, function(val)
    Settings.SpeedWalkValue = val
end)

TabMovement:CreateToggle("Custom Jump Power Force", false, function(state)
    Settings.JumpPowerEnabled = state
    if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        humanoid.UseJumpPower = false
        humanoid.JumpPower = 50
    end
end)

TabMovement:CreateSlider("Jump Power Modifier", 50, 250, Settings.JumpPowerValue, function(val)
    Settings.JumpPowerValue = val
end)

TabMovement:CreateToggle("Double Jump Feature", false, function(state)
    Settings.DoubleJumpEnabled = state
end)

TabMovement:CreateToggle("Show Double Jump Floating Button [DJ]", false, function(state)
    Settings.DoubleJumpExtEnabled = state
    ExtDoubleJumpBtn:SetVisible(state)
end)

TabMovement:CreateToggle("Infinite Jump (Infinite Jumping)", false, function(state)
    Settings.InfiniteJump = state
end)

TabMovement:CreateToggle("Auto Bunnyhop (Bhop)", false, function(state)
    Settings.AutoBhopEnabled = state
end)

TabMovement:CreateToggle("Show Auto Bhop Button [BHOP]", false, function(state)
    ExtBhopBtn:SetVisible(state)
end)

-- INTEGRASI SPIN BOT DI MENU UTAMA
TabMovement:CreateParagraph("Spin Bot System", "Rotate your character physically.")
TabMovement:CreateToggle("Enable Spin Bot", false, function(state)
    UpdateSpinState(state)
end)

TabMovement:CreateSlider("Spin Force / Power", 10, 300, Settings.SpinPower, function(val)
    Settings.SpinPower = val
    if Settings.SpinEnabled and SpinVelocity then
        SpinVelocity.AngularVelocity = Vector3.new(0, val, 0)
    end
end)

TabMovement:CreateToggle("Show Spin External Button [S]", false, function(state)
    Settings.SpinExtEnabled = state
    ExtSpinBtn:SetVisible(state)
end)

TabMovement:CreateParagraph("Flight, Noclip & Safe Teleport", "Movement through spaces.")
TabMovement:CreateToggle("Velocity Fly Hack (Mobile & PC Joystick Integration)", false, function(state)
    UpdateFlyState(state)
end)

TabMovement:CreateSlider("Flight Velocity Speed", 10, 150, Settings.FlySpeedValue, function(val)
    Settings.FlySpeedValue = val
end)

TabMovement:CreateToggle("Noclip (Walk Through Walls)", false, function(state)
    ToggleNoclip(state)
end)

TabMovement:CreateToggle("Safe Zone Teleport (Hide Out)", false, function(state)
    ToggleSafeZone(Settings.SafeZoneEnabled)
end)

TabMovement:CreateToggle("Show Safe Zone Button [SZ]", false, function(state)
    ExtSafeZoneBtn:SetVisible(state)
end)

TabMovement:CreateToggle("Character Invisibility Hack", false, function(state)
    Settings.InvisibleEnabled = state
    if not state and LocalPlayer.Character then
        for _, child in ipairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") or child:IsA("Decal") then
                if child.Name ~= "HumanoidRootPart" then child.Transparency = 0 end
            end
        end
    end
end)

-- --- TAB 5: MM2 SPECIAL UTILITIES ---
local TabSpecial = Window:CreateTab("MM2 Specials", "rbxassetid://4483362458")

TabSpecial:CreateParagraph("Coin Autofarm", "Automatically scan and collect coins on the map.")
TabSpecial:CreateToggle("Activate Auto Farm Coins", false, function(state)
    Settings.CoinFarmEnabled = state
end)

-- SLIDER TWEEN SPEED KHUSUS COIN FARM
TabSpecial:CreateSlider("Coin Farm Tween Speed", 20, 250, Settings.CoinFarmTweenSpeed, function(val)
    Settings.CoinFarmTweenSpeed = val
end)

-- ========================================================================
-- [[ DYNAMIC ACTIVE PLAYER RETRIEVER LOGIC ]]
-- ========================================================================
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

TabSpecial:CreateParagraph("Target Operations", "Dynamically select a target player to launch attacks or teleport.")

local TargetDropdown
TargetDropdown = TabSpecial:CreateDropdown("Select Target Player", GetPlayerNames(), "", function(selectedName)
    local target = Players:FindFirstChild(selectedName)
    if target then
        SelectedPlayer = target
        Library:Notify("Target Selected", SelectedPlayer.DisplayName .. " (@" .. SelectedPlayer.Name .. ")", 2)
    end
end)

TabSpecial:CreateButton("Update Player List (Refresh)", function()
    local currentNames = GetPlayerNames()
    if TargetDropdown then
        if TargetDropdown.Refresh then
            pcall(function() TargetDropdown:Refresh(currentNames) end)
        elseif TargetDropdown.Update then
            pcall(function() TargetDropdown:Update(currentNames) end)
        end
    end
    Library:Notify("Player List", "Player list successfully updated!", 1.5)
end)

SafeConnect(Players.PlayerAdded, function()
    task.wait(1)
    local currentNames = GetPlayerNames()
    if TargetDropdown then
        if TargetDropdown.Refresh then pcall(function() TargetDropdown:Refresh(currentNames) end)
        elseif TargetDropdown.Update then pcall(function() TargetDropdown:Update(currentNames) end) end
    end
end)

SafeConnect(Players.PlayerRemoving, function()
    task.wait(1)
    local currentNames = GetPlayerNames()
    if TargetDropdown then
        if TargetDropdown.Refresh then pcall(function() TargetDropdown:Refresh(currentNames) end)
        elseif TargetDropdown.Update then pcall(function() TargetDropdown:Update(currentNames) end) end
    end
end)

TabSpecial:CreateButton("Launch Fling at Selected Target Character", function()
    if SelectedPlayer then
        Library:Notify("Fling Attack", "Launching physical fling attack at " .. SelectedPlayer.DisplayName, 2)
        FlingPlayer(SelectedPlayer)
    else
        Library:Notify("Error", "Select a target character from the dropdown above first!", 2.5)
    end
end)

TabSpecial:CreateButton("Instant Teleport to Selected Target Character", function()
    if SelectedPlayer then
        TpToPlayer(SelectedPlayer)
        Library:Notify("Instant Teleport", "Arrived at the location of " .. SelectedPlayer.DisplayName, 1.5)
    else
        Library:Notify("Error", "Select a target character from the dropdown above first!", 2.5)
    end
end)

TabSpecial:CreateParagraph("Fling Glitches", "Violent rotation engine designed to push physical targets.")
TabSpecial:CreateButton("Auto Fling Murderer Instance", function()
    Settings.AutoFlingMurder = not Settings.AutoFlingMurder
    if Settings.AutoFlingMurder then 
        Settings.AutoFlingSheriff = false 
        UpdateFlingState("Sheriff", false)
    end
    UpdateFlingState("Murderer", Settings.AutoFlingMurder)
    if _G.SyncFlingButtons then _G.SyncFlingButtons() end
end)

TabSpecial:CreateToggle("Show Fling Murderer Button [FM]", false, function(state)
    Settings.FlingMurderExtEnabled = state
    ExtFlingMurderBtn:SetVisible(state)
end)

TabSpecial:CreateButton("Auto Fling Sheriff Instance", function()
    Settings.AutoFlingSheriff = not Settings.AutoFlingSheriff
    if Settings.AutoFlingSheriff then 
        Settings.AutoFlingMurder = false 
        UpdateFlingState("Murderer", false)
    end
    UpdateFlingState("Sheriff", Settings.AutoFlingSheriff)
    if _G.SyncFlingButtons then _G.SyncFlingButtons() end
end)

TabSpecial:CreateToggle("Show Fling Sheriff Button [FS]", false, function(state)
    Settings.FlingSheriffExtEnabled = state
    ExtFlingSheriffBtn:SetVisible(state)
end)

TabSpecial:CreateParagraph("Grab Dropped Gun", "Teleports to gun then teleports back.")
TabSpecial:CreateToggle("Auto Grab Gun (On Dropped)", false, function(state)
    Settings.AutoGrabGun = state
end)

TabSpecial:CreateToggle("Show Manual Grab Gun Button [G]", false, function(state)
    Settings.GrabGunExtEnabled = state
    ExtGrabBtn:SetVisible(state)
end)

TabSpecial:CreateParagraph("Target Teleports", "Instant teleportation to key characters.")
TabSpecial:CreateButton("Teleport instantly to Sheriff", function()
    TeleportToSheriff()
end)

TabSpecial:CreateToggle("Show Teleport Sheriff Button [TS]", false, function(state)
    Settings.TpSheriffExtEnabled = state
    ExtTpSheriffBtn:SetVisible(state)
end)

TabSpecial:CreateButton("Teleport instantly to Murderer", function()
    TeleportToMurderer()
end)

TabSpecial:CreateToggle("Show Teleport Murderer Button [TM]", false, function(state)
    Settings.TpMurderExtEnabled = state
    ExtTpMurderBtn:SetVisible(state)
end)

TabSpecial:CreateToggle("Show Save/Load Position Buttons [POS]", false, function(state)
    Settings.PosExtEnabled = state
    ExtSavePosBtn:SetVisible(state)
    ExtLoadPosBtn:SetVisible(state)
end)

-- --- TAB 6: CONTROLS & SIZES ---
local TabControls = Window:CreateTab("Button Controls", "rbxassetid://4483362458")

TabControls:CreateParagraph("External Button Scales (%)", "Adjust the scale of each floating button dynamically.")

TabControls:CreateSlider("Aimbot Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtAimbotBtn, val / 100)
end)

TabControls:CreateSlider("Grab Gun Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtGrabBtn, val / 100)
end)

TabControls:CreateSlider("Double Jump Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtDoubleJumpBtn, val / 100)
end)

TabControls:CreateSlider("Spin Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtSpinBtn, val / 100)
end)

TabControls:CreateSlider("Tp Sheriff Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtTpSheriffBtn, val / 100)
end)

TabControls:CreateSlider("Tp Murderer Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtTpMurderBtn, val / 100)
end)

TabControls:CreateSlider("Fling Murderer Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtFlingMurderBtn, val / 100)
end)

TabControls:CreateSlider("Fling Sheriff Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtFlingSheriffBtn, val / 100)
end)

TabControls:CreateSlider("Save Position Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtSavePosBtn, val / 100)
end)

TabControls:CreateSlider("Load Position Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtLoadPosBtn, val / 100)
end)

TabControls:CreateSlider("Auto Kill All Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtKillAllBtn, val / 100)
end)

TabControls:CreateSlider("Bhop Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtBhopBtn, val / 100)
end)

TabControls:CreateSlider("Safe Zone Button Scale", 10, 200, 100, function(val)
    SetButtonSize(ExtSafeZoneBtn, val / 100)
end)

TabControls:CreateParagraph("Window Lock", "Lock window dragging positions.")
TabControls:CreateToggle("Lock Main UI Dragging", false, function(state)
    Window:SetDragLock(state)
    UpdateAllButtonsDragLock(state) -- Automatically sets drag-lock status across all external buttons
end)

-- --- TAB 7: CONFIGURATIONS ---
local TabConfig = Window:CreateTab("Configurations", "rbxassetid://6023426915")

TabConfig:CreateParagraph("Configuration Manager", "Manually save or load your configuration settings at any time.")

TabConfig:CreateButton("Save Config Now", function()
    Library:SaveConfig()
end)

TabConfig:CreateButton("Load Config Now", function()
    Library:LoadConfig()
end)

-- ========================================================================
-- [[ RESPONDERS SYSTEM & EVENT CONNECTIONS (PERSISTENCE) ]]
-- ========================================================================
_G.SyncFlingButtons = function()
    Library:Notify("Fling Update", "States updated.", 1.2)
end

if LocalPlayer.Character then
    pcall(SetupDoubleJump, LocalPlayer.Character)
end

SafeConnect(LocalPlayer.CharacterAdded, function(char)
    pcall(SetupDoubleJump, char)
    
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    
    if Settings.SpeedWalkEnabled then humanoid.WalkSpeed = Settings.SpeedWalkValue end
    if Settings.JumpPowerEnabled then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Settings.JumpPowerValue
    end
    if Settings.FlyEnabled then UpdateFlyState(true) end
    if Settings.SpinEnabled then UpdateSpinState(true) end
end)

-- Keyboard Quick Keybind Connection
SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.Q then
        Settings.CameraAimbot = not Settings.CameraAimbot
        Library:Notify("Aimbot Assist", "Status: " .. (Settings.CameraAimbot and "ON" or "OFF"), 1.5)
    elseif key == Enum.KeyCode.X then
        Settings.ESP = not Settings.ESP
        Library:Notify("Visuals Toggle", "Status: " .. (Settings.ESP and "ON" or "OFF"), 1.5)
        if not Settings.ESP then ClearGunOutlines() end
    elseif key == Enum.KeyCode.C then
        Settings.HitboxExpander = not Settings.HitboxExpander
        Library:Notify("Hitbox Expander", "Status: " .. (Settings.HitboxExpander and "ON" or "OFF"), 1.5)
    elseif key == Enum.KeyCode.H then
        Settings.AutoGrabGun = not Settings.AutoGrabGun
        Library:Notify("Auto Grab Gun", "Status: " .. (Settings.AutoGrabGun and "ON" or "OFF"), 1.5)
    elseif key == Enum.KeyCode.P then
        Settings.HideFOVCircle = not Settings.HideFOVCircle
        Library:Notify("FOV Visibility", "Status: " .. (Settings.HideFOVCircle and "Hidden" or "Visible"), 1.5)
    end
end)

print("[LOUIS HUB]: MM2 Loader Ready to Use.")
