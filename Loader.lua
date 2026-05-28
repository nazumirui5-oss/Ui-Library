-- ========================================================================
-- [[ SCRIPT UTAMA LOADER - KODE FITUR FUNGSIONAL ]]
-- ========================================================================

-- 1. Load UI Library dari GitHub Anda
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/Ui%20Library.lua"))()

-- 2. Setup Layanan Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 3. Database Status Fitur (Konfigurasi Aktif)
local Features = {
    -- Combat
    AimbotActive = false,
    AimbotRadius = 150,
    
    -- Visuals
    EspActive = false,
    
    -- Movement
    WalkSpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    FlyActive = false,
    FlySpeed = 50
}

-- ========================================================================
-- [[ LOGIKA FITUR 1: CAMERA AIMBOT ]]
-- ========================================================================
local function GetClosestPlayerToCursor()
    local target = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if root and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < Features.AimbotRadius and distance < shortestDistance then
                        shortestDistance = distance
                        target = root
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Features.AimbotActive then
        local targetPart = GetClosestPlayerToCursor()
        if targetPart then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
        end
    end
end)

-- ========================================================
-- [[ LOGIKA FITUR 2: HIGHLIGHT ESP ]]
-- ========================================================
local function ApplyHighlightESP(player)
    if player == LocalPlayer then return end
    
    local function AddHighlight(char)
        if not char then return end
        local highlight = char:FindFirstChild("LouisESPHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "LouisESPHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = char
        end
        highlight.Enabled = Features.EspActive
    end

    if player.Character then
        pcall(AddHighlight, player.Character)
    end
    player.CharacterAdded:Connect(function(char)
        pcall(AddHighlight, char)
    end)
end

-- Terapkan ESP ke pemain yang sudah ada & pemain baru bergabung
for _, player in ipairs(Players:GetPlayers()) do
    ApplyHighlightESP(player)
end
Players.PlayerAdded:Connect(ApplyHighlightESP)

local function UpdateAllESPs()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("LouisESPHighlight")
            if highlight then
                highlight.Enabled = Features.EspActive
            end
        end
    end
end

-- ========================================================
-- [[ LOGIKA FITUR 3: NOCLIP ]]
-- ========================================================
RunService.Stepped:Connect(function()
    if Features.NoclipActive and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ========================================================
-- [[ LOGIKA FITUR 4: FLY HACK ]]
-- ========================================================
local bodyGyro, bodyVelocity

local function StartFlying()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.cframe = root.CFrame
    bodyGyro.Parent = root

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.velocity = Vector3.new(0, 0, 0)
    bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = root

    hum.PlatformStand = true

    task.spawn(function()
        while Features.FlyActive and root and hum do
            local moveDirection = hum.MoveDirection
            local vel = moveDirection * Features.FlySpeed

            -- Navigasi Vertikal (Kompatibel PC & Mobile)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, Features.FlySpeed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vel = vel + Vector3.new(0, -Features.FlySpeed, 0)
            end

            bodyVelocity.velocity = vel
            bodyGyro.cframe = Camera.CFrame
            task.wait()
        end
        
        -- Matikan terbang saat fitur dinonaktifkan
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if hum then hum.PlatformStand = false end
    end)
end

-- ========================================================
-- [[ STRUKTUR ANTARMUKA GUI (MENU ELEMEN) ]]
-- ========================================================

local Window = Library:CreateWindow("LOUIS PREMIUM", "Exploit Hub | MM2 & Generic")
Window:BindToggleKey(Enum.KeyCode.RightControl)

Library:Notify("LOUIS HUB INSTANTIATED", "Press 'RightControl' or floating 'L' button to toggle UI.", 5)

-- [ TAB 1: COMBAT ]
local TabCombat = Window:CreateTab("Combat Settings", "rbxassetid://4483345998")

TabCombat:CreateToggle("Aim Assist Lock", false, function(state)
    Features.AimbotActive = state
end)

TabCombat:CreateSlider("Aimbot Area Limit (FOV)", 50, 400, 150, function(value)
    Features.AimbotRadius = value
end)


-- [ TAB 2: VISUALS ]
local TabVisuals = Window:CreateTab("Visual Hacks", "rbxassetid://4483345998")

TabVisuals:CreateToggle("Player Outline ESP", false, function(state)
    Features.EspActive = state
    UpdateAllESPs()
end)


-- [ TAB 3: MOVEMENT & UTILITY ]
local TabMovement = Window:CreateTab("Utility Movement", "rbxassetid://4483362458")

-- Slider Kecepatan Jalan
TabMovement:CreateSlider("Adjust Walk Speed", 16, 200, 16, function(value)
    Features.WalkSpeedValue = value
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

-- Slider Tinggi Lompatan
TabMovement:CreateSlider("Adjust Jump Power", 50, 300, 50, function(value)
    Features.JumpPowerValue = value
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = value
    end
end)

-- Toggle Menembus Dinding
TabMovement:CreateToggle("Noclip (Pass Walls)", false, function(state)
    Features.NoclipActive = state
end)

-- Toggle Terbang
TabMovement:CreateToggle("Fly Hack Multiplatform", false, function(state)
    Features.FlyActive = state
    if state then
        StartFlying()
    end
end)

-- Slider Kecepatan Terbang
TabMovement:CreateSlider("Fly Velocity Speed", 20, 150, 50, function(value)
    Features.FlySpeed = value
end)

-- ========================================================
-- [[ SISTEM RESPONDERS (MEMPERTAHANKAN CHEAT SELEPAS RESPOND) ]]
-- ========================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    
    task.wait(0.5)
    -- Memasang ulang nilai Walkspeed & Jumppower saat karakter spawn kembali
    humanoid.WalkSpeed = Features.WalkSpeedValue
    humanoid.UseJumpPower = true
    humanoid.JumpPower = Features.JumpPowerValue
    
    -- Memasang ulang fly jika masih berstatus aktif saat respawn
    if Features.FlyActive then
        StartFlying()
    end
end)
