-- ========================================================================
-- [[ LOUIS HUB - SEPARATE ADVANCED CROSSHAIR MODULE (v2.2 FINAL ROTATION) ]]
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
    SpinSpeed = 50
}

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

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

-- ==========================================
-- [[ 2. INITIALIZE GUI (FOR IMAGE MODE) ]]
-- ==========================================
local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "Louis_ImageCrosshair"
CrosshairGui.DisplayOrder = 10000
CrosshairGui.ResetOnSpawn = false
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
-- [[ 4. ROTATION MATRIX MATHEMATICS ]]
-- ==========================================
-- Memutar koordinat titik (X, Y) di sekitar titik tengah layar berdasarkan sudut derajat
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

-- Render garis vektor yang telah ter-rotasi secara matematis
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
    
    if not config or not config.Enabled then
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

    -- Sembunyikan semua elemen rendering terlebih dahulu sebelum render ulang
    TopLine.Visible = false
    BottomLine.Visible = false
    LeftLine.Visible = false
    RightLine.Visible = false
    CenterCircle.Visible = false
    CrosshairImage.Visible = false

    -- [[ STYLE 1: IMAGE / ROBLOX ASSET ID ]]
    if style == "Image" then
        local cleanId = tostring(config.ImageId):gsub("%D", "")
        if cleanId ~= "" then
            CrosshairImage.Image = "rbxassetid://" .. cleanId
            CrosshairImage.Size = UDim2.new(0, size * 2, 0, size * 2)
            CrosshairImage.ImageColor3 = activeColor 
            CrosshairImage.Rotation = currentRotation -- Mendukung rotasi & putar otomatis
            CrosshairImage.Visible = true
        end

    -- [[ STYLE 2: STANDARD CROSS (TER-ROTASI) ]]
    elseif style == "Cross" then
        RenderRotatedLine(TopLine, Vector2.new(0, -gap), Vector2.new(0, -(gap + size)), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(BottomLine, Vector2.new(0, gap), Vector2.new(0, gap + size), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(LeftLine, Vector2.new(-gap, 0), Vector2.new(-(gap + size), 0), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(RightLine, Vector2.new(gap, 0), Vector2.new(gap + size, 0), center, currentRotation, thickness, activeColor)

    -- [[ STYLE 3: T-SHAPE (TER-ROTASI) ]]
    elseif style == "T-Shape" then
        RenderRotatedLine(BottomLine, Vector2.new(0, gap), Vector2.new(0, gap + size), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(LeftLine, Vector2.new(-gap, 0), Vector2.new(-(gap + size), 0), center, currentRotation, thickness, activeColor)
        RenderRotatedLine(RightLine, Vector2.new(gap, 0), Vector2.new(gap + size, 0), center, currentRotation, thickness, activeColor)

    -- [[ STYLE 4: DIAMOND / BELAH KETUPAT (TER-ROTASI) ]]
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

-- Simpan koneksi ke tabel koneksi global Louis Hub agar aman saat re-execute
if _G.LouisConnections then
    table.insert(_G.LouisConnections, RenderConnection)
end

print("[LOUIS HUB]: Separate Crosshair Module (v2.2 Final) Loaded Successfully.")
