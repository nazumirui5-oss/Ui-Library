-- ========================================================================
-- [[ LOUIS HUB - PREMIUM FUNCTIONAL LOADER (MM2 EDITION) ]]
-- AUTH: Louis | VERSION: 13.7.1 (Unified Logic with Integrated Lite Features)
-- ========================================================================

-- 1. LOAD UI LIBRARY DARI GITHUB
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/Ui%20Library.lua"))()

-- 2. SETUP LAYANAN ROBLOX UTAMA
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
-- [[ VARIABEL STATE INTERNAL & FISIKA ]]
-- ========================================================
local SavedCFrame = nil
local SelectedPlayer = nil
local originalVelocity = Vector3.new(0, 0, 0)
local originalRotVelocity = Vector3.new(0, 0, 0)

-- ========================================================================
-- [[ KUSTOMISASI TEKS TOMBOL EKSTERNAL ]]
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
    LoadPos = "LOAD_POS"
}

-- 3. KONFIGURASI FITUR INTERNAL (MM2 & MOVEMENT)
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
    
    -- Konfigurasi Coin Farm
    CoinFarmEnabled = false,

    -- Fitur Integrasi Tambahan (Dari Louis Lite HUD)
    InfiniteJump = false,
    AntiVoid = false,
    AntiFling = false,
    TouchFling = false,
    FlingPower = 100,
    
    -- Konfigurasi Teleport & Tombol Eksternal
    TpSheriffExtEnabled = false,
    TpMurderExtEnabled = false,
    FlingMurderExtEnabled = false,
    FlingSheriffExtEnabled = false,
    PosExtEnabled = false
}

local OriginalFOV = Camera.FieldOfView

-- ========================================================
-- [[ SISTEM CLEANUP RE-EXECUTION ]]
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

-- Membersihkan Billboard Name ESP dari eksekusi sebelumnya
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
-- [[ FITUR GRAPHICS: POTATO OPTIMIZATION ]]
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
-- [[ POSITIONS UTILITIES ]]
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

-- ========================================================
-- [[ LOGIKA EMULASI TEKNIS DETEKSI ROLE (MM2) ]]
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
-- [[ LOGIKA FITUR 1: CAMERA AIMBOT (PREDICTION ENGINE) ]]
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

SafeConnect(RunService.RenderStepped, function()
    if Settings.CameraAimbot and LocalPlayer.Character then
        local HoldsGun = LocalPlayer.Character:FindFirstChild("Gun")
        if HoldsGun and HoldsGun:IsA("Tool") then
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
-- [[ LOGIKA FITUR 2: DOUBLE JUMP & INFINITE JUMP ]]
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
    
    -- Infinite Jump (Sistem Lompat Tanpa Batas dari Lite HUD)
    if humanoid and Settings.InfiniteJump then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- Double Jump
    if humanoid and root and humanoid.Health > 0 and Settings.DoubleJumpEnabled then
        if CanDoubleJump and not HasDoubleJumped then
            HasDoubleJumped = true
            root.Velocity = Vector3.new(root.Velocity.X, humanoid.JumpPower * 1.15, root.Velocity.Z)
        end
    end
end)
table.insert(_G.LouisConnections, DoubleJumpReq)

-- ========================================================
-- [[ LOGIKA FITUR 3: GUN GRABBER ENGINE ]]
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
        
        local noclipConnection = SafeConnect(RunService.Stepped, function()
            if character then
                for _, child in ipairs(character:GetDescendants()) do
                    if child:IsA("BasePart") then child.CanCollide = false end
                end
            end
        end)
        
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
        
        if noclipConnection then noclipConnection:Disconnect() end
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
-- [[ LOGIKA DETEKSI DAN FARM COIN (MM2) ]]
-- ========================================================
local function GetPing()
    local ping = 0.05
    pcall(function() ping = LocalPlayer:GetNetworkPing() end)
    return ping
end

local function GetNearestCoin()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local closestCoin = nil
    local shortestDistance = math.huge
    
    -- Pemindaian cepat folder CoinContainer di workspace map aktif
    local coinContainers = {}
    for _, v in ipairs(Workspace:GetChildren()) do
        if v.Name == "CoinContainer" then
            table.insert(coinContainers, v)
        else
            local container = v:FindFirstChild("CoinContainer")
            if container then table.insert(coinContainers, container) end
        end
    end
    
    if #coinContainers > 0 then
        for _, container in ipairs(coinContainers) do
            for _, coin in ipairs(container:GetChildren()) do
                local coinPart = coin:IsA("BasePart") and coin or coin:FindFirstChild("Coin") or coin:FindFirstChild("MainCoin") or coin:FindFirstChildOfClass("BasePart")
                if coinPart then
                    local distance = (root.Position - coinPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestCoin = coinPart
                    end
                end
            end
        end
    else
        -- Metode Fallback: Pemindaian total objek bermana Coin_Server
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Coin_Server" then
                local coinPart = v:IsA("BasePart") and v or v:FindFirstChild("Coin") or v:FindFirstChild("MainCoin") or v:FindFirstChildOfClass("BasePart")
                if coinPart then
                    local distance = (root.Position - coinPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestCoin = coinPart
                    end
                end
            end
        end
    end
    
    return closestCoin
end

local function CollectCoin(coinPart)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not coinPart or not coinPart.Parent then return end
    
    local targetCFrame = coinPart.CFrame
    
    -- Menonaktifkan tabrakan fisik karakter agar tidak tersangkut objek lain
    local originalCollides = {}
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") then
            table.insert(originalCollides, {part = child, oldState = child.CanCollide})
            child.CanCollide = false
        end
    end
    
    -- Teleportasi Instan Terkalibrasi Cooldown (0.9 Detik + Ping Server)
    root.CFrame = targetCFrame
    task.wait(0.9 + GetPing())
    
    -- Mengembalikan kondisi tabrakan fisik karakter
    for _, info in ipairs(originalCollides) do
        if info.part and info.part.Parent then
            info.part.CanCollide = info.oldState
        end
    end
end

task.spawn(function()
    while true do
        if Settings.CoinFarmEnabled then
            local nearest = GetNearestCoin()
            if nearest then
                CollectCoin(nearest)
            else
                task.wait(0.5) -- Menunggu koin baru muncul jika habis
            end
        end
        task.wait(0.1)
    end
end)

-- ========================================================
-- [[ LOGIKA FITUR 4: KILL AURA & TELEPORT ALL ]]
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

local function TeleportAllPlayersToMe()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not root or GetMM2Role(LocalPlayer) ~= "Murderer" then return end
    
    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("BasePart") then child.CanCollide = false end
    end
    
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
-- [[ LOGIKA FITUR 5: TELEPORTS & TARGET SELECTIONS ]]
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

-- Teleport ke pemain target (Lite HUD)
local function TpToPlayer(targetPlayer)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end

-- ========================================================================
-- [[ LITE HUD TARGET OPERATIONS (FLING TARGET SPESIFIK & CYCLE) ]]
-- ========================================================================
local function FlingPlayer(targetPlayer)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local oldPos = root.CFrame
        local targetRoot = targetPlayer.Character.HumanoidRootPart
        
        SavePosition()
        local originalFlingState = Settings.TouchFling
        Settings.TouchFling = true
        
        task.spawn(function()
            for i = 1, 15 do
                if targetRoot and root and char:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0.2)
                end
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
local FlingFailsafeActive = false
local OriginalCFrameBeforeFling = nil

-- Loop Enforcer & Pemantau Konfigurasi Konstan
local NoclipConnection
local function ToggleNoclip(state)
    Settings.NoclipEnabled = state
    if NoclipConnection then NoclipConnection:Disconnect() end
    if state then
        NoclipConnection = SafeConnect(RunService.Stepped, function()
            if LocalPlayer.Character then
                for _, child in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if child:IsA("BasePart") then child.CanCollide = false end
                end
            end
        end)
    else
        if LocalPlayer.Character then
            for _, child in ipairs(LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") then child.CanCollide = true end
            end
        end
    end
end

-- SISTEM LOOP FISIKA JANTUNG (Heartbeat) - Terintegrasi dengan Touch Fling & Anti Fling
SafeConnect(RunService.Heartbeat, function()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if root and humanoid and humanoid.Health > 0 then
        -- Enforce Walkspeed & JumpPower (Bug High Jump and High Speed fix)
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
        
        -- FOV Camera Modifier
        if Settings.CameraFOVEnabled then
            Camera.FieldOfView = Settings.CameraFOVValue
        else
            Camera.FieldOfView = OriginalFOV
        end

        -- Invisibility Hack Loop (Visual Render)
        if Settings.InvisibleEnabled then
            for _, child in ipairs(character:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("Decal") then
                    if child.Name ~= "HumanoidRootPart" then child.Transparency = 1 end
                end
            end
        end

        -- [LITE HUD] SISTEM FISIKA SILENT TOUCH FLING
        if Settings.TouchFling then
            local multiplier = Settings.FlingPower * 1000
            originalVelocity = root.AssemblyLinearVelocity
            originalRotVelocity = root.AssemblyAngularVelocity
            
            root.AssemblyLinearVelocity = Vector3.new(multiplier, multiplier, multiplier)
            root.AssemblyAngularVelocity = Vector3.new(0, multiplier, 0)
            
            for _, child in ipairs(character:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                end
            end
        end

        -- [LITE HUD] SISTEM FISIKA ANTI-FLING 
        if Settings.AntiFling and not Settings.TouchFling then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- [LITE HUD] RenderStepped Synchronization untuk Touch Fling
SafeConnect(RunService.RenderStepped, function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and Settings.TouchFling then
        root.AssemblyLinearVelocity = originalVelocity
        root.AssemblyAngularVelocity = originalRotVelocity
    end
end)

-- [LITE HUD] Loop Deteksi Sistem Anti-Void
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

-- FUNGSI MEMBACA INPUT FLY SECARA VERTIKAL & HORIZONTAL
local function GetFlyDirection()
    local direction = Vector3.new(0, 0, 0)
    if UserInputService:GetFocusedTextBox() then return direction end
    
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
        direction = direction + Vector3.new(0, 1, 0) -- Terbang lurus ke atas
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0) -- Terbang lurus ke bawah
    end
    
    if direction.Magnitude > 0 then
        return direction.Unit
    end
    return Vector3.new(0, 0, 0)
end

-- SISTEM TERBANG (RenderStepped & CFrame Method - 100% Bebas Bug)
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
            
            -- Override physical parameters to completely neutralize gravity
            root.AssemblyLinearVelocity = Vector3.new(0, 0.05, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            -- Lock rotation alignment with camera direction
            local look = Camera.CFrame.LookVector
            root.CFrame = CFrame.lookAt(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
            
            local dir = GetFlyDirection()
            if dir.Magnitude > 0 then
                root.CFrame = root.CFrame + (dir * (Settings.FlySpeedValue * dt))
            end
        end)
    end
end

-- SISTEM SPIN (Physical Angular Velocity)
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

-- SISTEM FLING INSTANT (High Torque Rotator)
local function UpdateFlingState(role, state)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not state then
        if FlingVelocity then FlingVelocity:Destroy() end
        if hum then hum.PlatformStand = false end
        if OriginalCFrameBeforeFling and root then
            root.CFrame = OriginalCFrameBeforeFling
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
        end
        FlingFailsafeActive = false
        OriginalCFrameBeforeFling = nil
        return
    end
    
    if root and hum then
        if not FlingFailsafeActive then
            FlingFailsafeActive = true
            OriginalCFrameBeforeFling = root.CFrame
        end
        
        hum.PlatformStand = true
        
        FlingVelocity = Instance.new("BodyAngularVelocity")
        FlingVelocity.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlingVelocity.AngularVelocity = Vector3.new(0, 15000, 0)
        FlingVelocity.Parent = root
        
        task.spawn(function()
            while (Settings.AutoFlingMurder or Settings.AutoFlingSheriff) and FlingFailsafeActive and root and hum and hum.Health > 0 do
                local targetPlayer = GetTargetByRole(role)
                local tChar = targetPlayer and targetPlayer.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                
                if tRoot and tChar:FindFirstChildOfClass("Humanoid") and tChar:FindFirstChildOfClass("Humanoid").Health > 0 then
                    -- Aktifkan gaya tabrakan fisik agar transfer momentum berjalan
                    for _, child in ipairs(char:GetDescendants()) do
                        if child:IsA("BasePart") then child.CanCollide = true end
                    end
                    root.CFrame = tRoot.CFrame * CFrame.new(math.random(-1, 1) * 0.3, 0, math.random(-1, 1) * 0.3)
                    root.Velocity = Vector3.new(9999, 9999, 9999)
                else
                    task.wait(0.1)
                end
                task.wait()
            end
            UpdateFlingState(role, false)
        end)
    end
end

-- ========================================================
-- [[ LOGIKA FITUR 6: SISTEM NAME ESP & HIGHLIGHT ESP ]]
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

local function ClearNameESP(player)
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        local billboard = head and head:FindFirstChild("MM2_NameESP")
        if billboard then billboard:Destroy() end
    end
end

-- ========================================================
-- [[ LOOP UTAMA VISUALS (HITBOX EXPANDER, ESP & TRACERS) ]]
-- ========================================================
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
                    if not IsGrabbing and not FlingFailsafeActive then Root.CanCollide = true end
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
-- [[ INISIALISASI TOMBOL EKSTERNAL DARI UI LIBRARY ]]
-- ========================================================================
local ExtAimbotBtn = Library:CreateExternalButton("Aimbot", ExtButtonTexts.Aimbot, UDim2.new(0, 20, 0.5, -55), function()
    Settings.CameraAimbot = not Settings.CameraAimbot
    Library:Notify("Aimbot Toggle", "Status: " .. (Settings.CameraAimbot and "ON" or "OFF"), 1.5)
end)

local ExtGrabBtn = Library:CreateExternalButton("GrabGun", ExtButtonTexts.GrabGun, UDim2.new(0, 20, 0.5, -10), function()
    local activeGun = ScanForDroppedGun()
    if activeGun then
        SafeInstantTween(activeGun)
        Library:Notify("Gun Grabber", "Attempting manual gun snatch!", 2)
    else
        Library:Notify("Gun Grabber", "No dropped gun found on map.", 2)
    end
end)

local ExtDoubleJumpBtn = Library:CreateExternalButton("DoubleJump", ExtButtonTexts.DoubleJump, UDim2.new(0, 20, 0.5, 35), function()
    Settings.DoubleJumpEnabled = not Settings.DoubleJumpEnabled
    Library:Notify("Double Jump", "Status: " .. (Settings.DoubleJumpEnabled and "ON" or "OFF"), 1.5)
end)

local ExtSpinBtn = Library:CreateExternalButton("Spin", ExtButtonTexts.Spin, UDim2.new(0, 20, 0.5, 80), function()
    Settings.SpinEnabled = not Settings.SpinEnabled
    UpdateSpinState(Settings.SpinEnabled)
    Library:Notify("Spin Bot", "Status: " .. (Settings.SpinEnabled and "ON" or "OFF"), 1.5)
end)

local ExtTpSheriffBtn = Library:CreateExternalButton("TpSheriff", ExtButtonTexts.TpSheriff, UDim2.new(0, 70, 0.5, -55), function()
    TeleportToSheriff()
    Library:Notify("Teleport", "Teleporting to Sheriff...", 1.5)
end)

local ExtTpMurderBtn = Library:CreateExternalButton("TpMurderer", ExtButtonTexts.TpMurder, UDim2.new(0, 70, 0.5, -10), function()
    TeleportToMurderer()
    Library:Notify("Teleport", "Teleporting to Murderer...", 1.5)
end)

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

-- Tombol Eksternal POS Tambahan (Permintaan User)
local ExtSavePosBtn = Library:CreateExternalButton("SavePos", ExtButtonTexts.SavePos, UDim2.new(0, 120, 0.5, -55), function()
    SavePosition()
    Library:Notify("POS Saved", "Saved local coordinates successfully!", 1.5)
end)

local ExtLoadPosBtn = Library:CreateExternalButton("LoadPos", ExtButtonTexts.LoadPos, UDim2.new(0, 120, 0.5, -10), function()
    if SavedCFrame then
        LoadSavedPosition()
        Library:Notify("POS Loaded", "Teleported to saved coordinate!", 1.5)
    else
        Library:Notify("POS Error", "No saved coordinate. Save position first!", 2)
    end
end)

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

-- ========================================================================
-- [[ STRUKTUR MENU UI ]]
-- ========================================================================
local Window = Library:CreateWindow("LOUIS MM2 EDITION", "Modern generic hub")
Window:BindToggleKey(Enum.KeyCode.RightControl)

Library:Notify("LOUIS HUB INSTANTIATED", "Press RightControl to hide/show Main UI.", 4)

-- --- TAB 1: MAIN INFO ---
local TabMain = Window:CreateTab("Welcome", "rbxassetid://6023426915")
TabMain:CreateParagraph("Welcome!", "Hello " .. LocalPlayer.Name .. "!\nThank you for executing Louis Premium Edition.")
TabMain:CreateParagraph("UI Instructions", "Keybind to open/hide menu: RightControl\nYou can toggle external buttons from the settings.")
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

TabCombat:CreateButton("Teleport & Stack All Players to Me", function()
    TeleportAllPlayersToMe()
    Library:Notify("Combat Teleport", "Stacked all players for ez kill!", 2.5)
end)

-- [LITE HUD INTEGRATION] TOUCH FLING & ANTI-FLING PHYSICS
TabCombat:CreateParagraph("Touch Fling (Sistem Tabrak)", "Gaya rotasi fisik instan saat karakter menyentuh musuh.")
TabCombat:CreateToggle("Activate Touch Fling", false, function(state)
    Settings.TouchFling = state
end)

TabCombat:CreateSlider("Fling Velocity Power multiplier", 1, 200, Settings.FlingPower, function(val)
    Settings.FlingPower = val
end)

TabCombat:CreateToggle("Anti Fling (Resisten Tabrak)", false, function(state)
    Settings.AntiFling = state
end)

TabCombat:CreateParagraph("Aimbot & Prediction", "Aimbot locks to murderer or targets based on role.")
local AimbotToggle = TabCombat:CreateToggle("Aim Assist Lock (Holding Gun)", false, function(state)
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

TabMovement:CreateParagraph("Speed & Jump Modifiers", "Ubah kecepatan jalan dan kekuatan lompatan.")
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

-- [LITE HUD INTEGRATION] INFINITE JUMP
TabMovement:CreateToggle("Infinite Jump (Lompat Tanpa Batas)", false, function(state)
    Settings.InfiniteJump = state
end)

TabMovement:CreateParagraph("Flight & Noclip", "Movement through spaces.")
TabMovement:CreateToggle("Velocity Fly Hack (W/A/S/D + Space/LShift)", false, function(state)
    UpdateFlyState(state)
end)

TabMovement:CreateSlider("Flight Velocity Speed", 10, 150, Settings.FlySpeedValue, function(val)
    Settings.FlySpeedValue = val
end)

TabMovement:CreateToggle("Noclip (Walk Through Walls)", false, function(state)
    ToggleNoclip(state)
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

TabMovement:CreateParagraph("Spin Bot System", "Makes you spin.")
TabMovement:CreateToggle("Activate Spin Bot", false, function(state)
    UpdateSpinState(state)
end)

TabMovement:CreateToggle("Show Spin Bot Button [S]", false, function(state)
    Settings.SpinExtEnabled = state
    ExtSpinBtn:SetVisible(state)
end)

TabMovement:CreateSlider("Spin Speed Rotator", 1, 100, Settings.SpinPower, function(val)
    Settings.SpinPower = val
    if Settings.SpinEnabled then UpdateSpinState(true) end
end)

-- [LITE HUD INTEGRATION] POSITIONS, COORDINATES & ANTI-VOID
TabMovement:CreateParagraph("Positions & Anti-Void", "Simpan posisi koordinat atau amankan karakter dari Void.")
TabMovement:CreateToggle("Activate Anti Void Mode", false, function(state)
    Settings.AntiVoid = state
end)

TabMovement:CreateButton("Simpan Koordinat Karakter (POS)", function()
    SavePosition()
    Library:Notify("Position Saved", "Koordinat CFrame berhasil disimpan secara lokal.", 2)
end)

TabMovement:CreateButton("Teleport ke Koordinat Tersimpan", function()
    if SavedCFrame then
        LoadSavedPosition()
        Library:Notify("Position Loaded", "Karakter berhasil diteleportasikan ke koordinat simpanan.", 2)
    else
        Library:Notify("Error", "Belum ada koordinat tersimpan! Tekan tombol di atas terlebih dahulu.", 2.5)
    end
end)

TabMovement:CreateToggle("Show Save/Load POS Buttons [SP/LP]", false, function(state)
    Settings.PosExtEnabled = state
    ExtSavePosBtn:SetVisible(state)
    ExtLoadPosBtn:SetVisible(state)
end)

-- --- TAB 5: MM2 SPECIAL UTILITIES ---
local TabSpecial = Window:CreateTab("MM2 Specials", "rbxassetid://4483362458")

-- Kategori: Coin Autofarm
TabSpecial:CreateParagraph("Coin Autofarm", "Secara otomatis memindai dan mengambil koin di peta.")

TabSpecial:CreateToggle("Activate Auto Farm Coins", false, function(state)
    Settings.CoinFarmEnabled = state
end)

-- ========================================================================
-- [[ LOGIKA PENGAMBIL PLAYER AKTIF DINAMIS ]]
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

-- [LITE HUD INTEGRATION] TARGET OPERATIONS (DYNAMIC ATTACK & APPROACH)
TabSpecial:CreateParagraph("Target Operations", "Pilih pemain target secara dinamis untuk meluncurkan serangan atau teleport.")

local TargetDropdown
TargetDropdown = TabSpecial:CreateDropdown("Pilih Player Target", GetPlayerNames(), "", function(selectedName)
    local target = Players:FindFirstChild(selectedName)
    if target then
        SelectedPlayer = target
        Library:Notify("Target Selected", SelectedPlayer.DisplayName .. " (@" .. SelectedPlayer.Name .. ")", 2)
    end
end)

TabSpecial:CreateButton("Perbarui Daftar Player (Refresh)", function()
    local currentNames = GetPlayerNames()
    if TargetDropdown then
        if TargetDropdown.Refresh then
            pcall(function() TargetDropdown:Refresh(currentNames) end)
        elseif TargetDropdown.Update then
            pcall(function() TargetDropdown:Update(currentNames) end)
        end
    end
    Library:Notify("Player List", "Daftar pemain berhasil diperbarui!", 1.5)
end)

-- Auto Update Dropdown ketika pemain masuk/keluar
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

TabSpecial:CreateButton("Luncurkan Fling ke Target Karakter Terpilih", function()
    if SelectedPlayer then
        Library:Notify("Fling Attack", "Meluncurkan serangan fisik fling ke " .. SelectedPlayer.DisplayName, 2)
        FlingPlayer(SelectedPlayer)
    else
        Library:Notify("Error", "Pilih target karakter terlebih dahulu pada Dropdown di atas!", 2.5)
    end
end)

TabSpecial:CreateButton("Teleport Instan ke Target Karakter Terpilih", function()
    if SelectedPlayer then
        TpToPlayer(SelectedPlayer)
        Library:Notify("Instant Teleport", "Tiba di lokasi " .. SelectedPlayer.DisplayName, 1.5)
    else
        Library:Notify("Error", "Pilih target karakter terlebih dahulu pada Dropdown di atas!", 2.5)
    end
end)

-- Kategori: Fling Glitches (Dunia MM2)
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

TabSpecial:CreateParagraph("Window Lock", "Lock window dragging positions.")
TabSpecial:CreateToggle("Lock Main UI Dragging", false, function(state)
    Window:SetDragLock(state)
end)

-- ========================================================================
-- [[ SISTEM RESPONDERS & EVENT CONNECTIONS (PERSISTENCE) ]]
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
    
    -- Memulihkan konfigurasi pergerakan fungsional yang aktif sebelum respawn
    if Settings.SpeedWalkEnabled then humanoid.WalkSpeed = Settings.SpeedWalkValue end
    if Settings.JumpPowerEnabled then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Settings.JumpPowerValue
    end
    if Settings.FlyEnabled then UpdateFlyState(true) end
    if Settings.SpinEnabled then UpdateSpinState(true) end
end)

-- Bind Tombol Keybind Cepat Keyboard
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

print("[LOUIS HUB]: Loader Fungsional Utuh Berhasil Diinisialisasi Tanpa Hambatan.")
