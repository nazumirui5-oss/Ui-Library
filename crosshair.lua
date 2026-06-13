-- ========================================================================
-- [[ LOUIS HUB - SEPARATE ADVANCED CROSSHAIR MODULE (v3.2 FINAL CENTERED) ]]
-- ========================================================================

-- Inisialisasi tabel global jika dipanggil secara independen
_G.CrosshairSettings = _G.CrosshairSettings or {
    Enabled = false,
    Style = "Cross", -- "Cross", "T-Shape", "Diamond", "Circle", "Dot", "Image"
    Size = 10,
    Gap = 5,
    Thickness = 1.5,
    Color = Color3.fromRGB(0, 255, 150),
    Rainbow = false,
    ImageId = "6877713475",
    Rotation = 0,
    AutoSpin = false,
    SpinSpeed = 50,
    OnlyShiftLock = false,
    HideDefaultCursor = true
}

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==========================================
-- [[ 1. CLEANUP SYSTEM (PERSISTENCE) ]]
-- ==========================================
-- Hapus GUI lama jika ada dari eksekusi sebelumnya
local OldCrosshairGui = CoreGui:FindFirstChild("Louis_ImageCrosshair")
if OldCrosshairGui then 
    pcall(function() OldCrosshairGui:Destroy() end) 
end

-- Hapus Drawing vector lama jika ada
if _G.LouisCrosshairDrawings then
    for _, obj in pairs(_G.LouisCrosshairDrawings) do
        pcall(function() obj:Remove() end)
    end
end
_G.LouisCrosshairDrawings = {}

-- Kembalikan kursor default & aktifkan kembali mouse icon saat reset
pcall(function() 
    Mouse.Icon = ""
    UserInputService.MouseIconEnabled = true
end)

-- ==========================================
-- [[ 2. INITIALIZE GUI (FOR IMAGE MODE) ]]
-- ==========================================
local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "Louis_ImageCrosshair"
CrosshairGui.DisplayOrder = 10000
CrosshairGui.ResetOnSpawn = false
CrosshairGui.IgnoreGuiInset = true -- Mengabaikan Topbar inset agar posisi gambar benar-benar di pusat layar
CrosshairGui.Parent = CoreGui

local CrosshairImage = Instance.new("ImageLabel")
CrosshairImage.Name = "CrosshairImage"
CrosshairImage.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairImage.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairImage.BackgroundTransparency = 1
CrosshairImage.Visible = false
CrosshairImage.Parent = CrosshairGui

-- ==========================================
-- [[ 3. INITIALIZE DRAWINGS (FOR VECTORS) ]]
-- ==========================================
local function CreateLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Transparency = 1
    table.insert(_G.LouisCrosshairDrawings, line)
    return line
end

local function CreateCircle()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Transparency = 1
    table.insert(_G.LouisCrosshairDrawings, circle)
    return circle
end

local TopLine = CreateLine()
local BottomLine = CreateLine()
local LeftLine = CreateLine()
local RightLine = CreateLine()
local CenterCircle = CreateCircle()

-- ==========================================
-- [[ Helper: Extract Clean ID ]]
-- ==========================================
local function GetCleanImageId(id)
    local str = tostring(id)
    local found = str:match("ID:%s*(%d+)")
    if found then
        return found
    end
    return str:gsub("%D", "")
end

-- ==========================================
-- [[ 4. ROTATION MATRIX MATHEMATICS ]]
-- ==========================================
local function RotatePoint(point, center, angleDegrees)
    local angleRad = math.rad(angleDegrees)
    local cosTheta = math.cos(angleRad)
    local sinTheta = math.sin(angleRad)
    
    local localX = point.X - center.X
    local localY = point.Y - center.Y
    
    local rotatedX = localX * cosTheta - localY * sinTheta
    local rotatedY = localX * sinTheta + localY * cosTheta
    
    return Vector2.new(rotatedX + center.X, rotatedY + center.Y)
end

local function RenderRotatedLine(lineObj, fromOffset, toOffset, center, angle, thickness, color)
    lineObj.From = RotatePoint(center + fromOffset, center, angle)
    lineObj.To = RotatePoint(center + toOffset, center, angle)
    lineObj.Thickness = thickness
    lineObj.Color = color
    lineObj.Visible = true
end

-- ==========================================
-- [[ 5. MAIN RENDERING ENGINE (HEARTBEAT) ]]
-- ==========================================
local RenderConnection
RenderConnection = RunService.RenderStepped:Connect(function()
    local config = _G.CrosshairSettings
    
    local isEnabled = config and config.Enabled
    local isShiftLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter

    -- Sembunyikan jika OnlyShiftLock aktif tapi Shift Lock sedang mati
    if isEnabled and config.OnlyShiftLock and not isShiftLocked then
        isEnabled = false
    end

    -- Sembunyikan kursor sistem & titik putih kursor default Roblox secara mutlak (FE)
    if isEnabled and config.HideDefaultCursor then
        pcall(function()
            UserInputService.MouseIconEnabled = false
        end)
    else
        pcall(function()
            UserInputService.MouseIconEnabled = true
        end)
    end

    -- Matikan semua rendering jika dinonaktifkan
    if not isEnabled then
        TopLine.Visible = false
        BottomLine.Visible = false
        LeftLine.Visible = false
        RightLine.Visible = false
        CenterCircle.Visible = false
        CrosshairImage.Visible = false
        return
    end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local activeColor = config.Rainbow and Color3.fromHSV((os.clock() % 4) / 4, 1, 1) or config.Color
    local style = config.Style or "Cross"
    local size = config.Size or 10
    local gap = config.Gap or 5
    local thickness = config.Thickness or 1.5

    -- Kalkulasi Rotasi Aktif (Manual / Auto-Spin)
    local currentRotation = config.Rotation or 0
    if config.AutoSpin then
        currentRotation = (os.clock() * (config.SpinSpeed or 50)) % 360
    end

    -- Sembunyikan semua elemen sebelum proses render ulang
    TopLine.Visible = false
    BottomLine.Visible = false
    LeftLine.Visible = false
    RightLine.Visible = false
    CenterCircle.Visible = false
    CrosshairImage.Visible = false

    -- [[ STYLE 1: IMAGE / ROBLOX ASSET ID (Dengan protokol rbxthumb) ]]
    if style == "Image" then
        local cleanId = GetCleanImageId(config.ImageId)
        if cleanId ~= "" then
            CrosshairImage.Image = "rbxthumb://type=Asset&id=" .. cleanId .. "&w=420&h=420"
            CrosshairImage.Size = UDim2.new(0, size * 2, 0, size * 2)
            CrosshairImage.ImageColor3 = activeColor 
            CrosshairImage.Rotation = currentRotation
            CrosshairImage.Visible = true
        end

    -- [[ STYLE 2: STANDARD CROSS ]]
    elseif style == "Cross" then
        RenderRotatedLine(TopLine, Vector2.new(0, -gap), Vector2.new(0, -(gap + size)), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(BottomLine, Vector2.new(0, gap), Vector2.new(0, gap + size), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(LeftLine, Vector2.new(-gap, 0), Vector2.new(-(gap + size), 0), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(RightLine, Vector2.new(gap, 0), Vector2.new(gap + size, 0), center, currentRotation, thickness, activeColor)

    -- [[ STYLE 3: T-SHAPE ]]
    elseif style == "T-Shape" then
        RenderRotatedLine(BottomLine, Vector2.new(0, gap), Vector2.new(0, gap + size), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(LeftLine, Vector2.new(-gap, 0), Vector2.new(-(gap + size), 0), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(RightLine, Vector2.new(gap, 0), Vector2.new(gap + size, 0), center, currentRotation, thickness, activeColor)

    -- [[ STYLE 4: DIAMOND ]]
    elseif style == "Diamond" then
        local offset = gap + size
        RenderRotatedLine(TopLine, Vector2.new(-offset, 0), Vector2.new(0, -offset), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(BottomLine, Vector2.new(0, -offset), Vector2.new(offset, 0), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(LeftLine, Vector2.new(offset, 0), Vector2.new(0, offset), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(RightLine, Vector2.new(0, offset), Vector2.new(-offset, 0), center, currentRotation, thickness, activeColor)

    -- [[ STYLE 5: CIRCLE ]]
    elseif style == "Circle" then
        CenterCircle.Position = center
        CenterCircle.Radius = size + gap
        CenterCircle.Thickness = thickness
        CenterCircle.Color = activeColor
        CenterCircle.Filled = false
        CenterCircle.NumSides = 45
        CenterCircle.Visible = true

    -- [[ STYLE 6: DOT ]]
    elseif style == "Dot" then
        CenterCircle.Position = center
        CenterCircle.Radius = math.clamp(thickness * 1.5, 2, 8)
        CenterCircle.Color = activeColor
        CenterCircle.Filled = true
        CenterCircle.NumSides = 24
        CenterCircle.Visible = true
    end
end)

-- Simpan koneksi render ke sistem koneksi global
if _G.LouisConnections then
    table.insert(_G.LouisConnections, RenderConnection)
end

print("[LOUIS HUB]: Separate Crosshair Module (v3.2 Final Centered) Loaded.")
