-- ========================================================================
-- [[ LOUIS HUB - PREMIUM FUNCTIONAL LOADER (MM2 EDITION) ]]
-- AUTH: Louis | VERSION: 13.5.2 (Unified Logic - No Security)
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
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

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
    FlingSheriff = "FLING_S"
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
    
    -- Konfigurasi Teleport & Tombol Eksternal
    TpSheriffExtEnabled = false,
    TpMurderExtEnabled = false,
    FlingMurderExtEnabled = false,
    FlingSheriffExtEnabled = false
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
    local ping = LocalPlayer:GetNetworkPing()
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
-- [[ LOGIKA FITUR 2: DOUBLE JUMP SYSTEM ]]
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

-- ========================================================================
-- [[ MOBILITY PHYSICS ENGINE (FLY, NOCLIP, SPIN, FLING, SPEED, JUMP) ]]
-- ========================================================================
local FlyVelocity, FlyGyro
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

SafeConnect(RunService.Heartbeat, function()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if root and humanoid and humanoid.Health > 0 then
        -- Enforce Walkspeed & JumpPower
        if Settings.SpeedWalkEnabled then humanoid.WalkSpeed = Settings.SpeedWalkValue end
        if Settings.JumpPowerEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Settings.JumpPowerValue
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
    end
end)

-- SISTEM TERBANG (BodyVelocity & BodyGyro)
local function UpdateFlyState(state)
    Settings.FlyEnabled = state
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not state then
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
        return
    end
    
    if root and hum then
        hum.PlatformStand = true
        
        FlyVelocity = Instance.new("BodyVelocity")
        FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyVelocity.Parent = root
        
        FlyGyro = Instance.new("BodyGyro")
        FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyGyro.CFrame = Camera.CFrame
        FlyGyro.Parent = root
        
        task.spawn(function()
            while Settings.FlyEnabled and root and hum and hum.Health > 0 do
                FlyGyro.CFrame = Camera.CFrame
                local moveDir = hum.MoveDirection
                local velocity = moveDir * Settings.FlySpeedValue
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, Settings.FlySpeedValue, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity + Vector3.new(0, -Settings.FlySpeedValue, 0)
                end
                
                FlyVelocity.Velocity = velocity
                task.wait()
            end
            if hum then hum.PlatformStand = false end
            if FlyVelocity then FlyVelocity:Destroy() end
            if FlyGyro then FlyGyro:Destroy() end
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

ExtAimbotBtn:SetVisible(false)
ExtGrabBtn:SetVisible(false)
ExtDoubleJumpBtn:SetVisible(false)
ExtSpinBtn:SetVisible(false)
ExtTpSheriffBtn:SetVisible(false)
ExtTpMurderBtn:SetVisible(false)
ExtFlingMurderBtn:SetVisible(false)
ExtFlingSheriffBtn:SetVisible(false)

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

TabMovement:CreateParagraph("Speed Hacks", "Changes walkspeeds.")
TabMovement:CreateToggle("Custom Walk Speed", false, function(state)
    Settings.SpeedWalkEnabled = state
    if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

TabMovement:CreateSlider("Speed Force Value", 16, 120, Settings.SpeedWalkValue, function(val)
    Settings.SpeedWalkValue = val
end)

TabMovement:CreateParagraph("Jump Hacks", "Custom jump powers.")
TabMovement:CreateToggle("Custom Jump Power Force", false, function(state)
    Settings.JumpPowerEnabled = state
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

TabMovement:CreateParagraph("Flight & Noclip", "Movement through spaces.")
TabMovement:CreateToggle("Velocity Fly Hack (Space/LShift)", false, function(state)
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

-- --- TAB 5: MM2 SPECIAL UTILITIES ---
local TabSpecial = Window:CreateTab("MM2 Specials", "rbxassetid://4483362458")

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
