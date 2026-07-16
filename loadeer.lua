local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- Inisialisasi Window Utama
local Win = Library:CreateWindow("COMPKILLER", "NEVER")

-- ============================================
-- [[ PENATAAN SIDEBAR & DIVIDER OTOMATIS ]]
-- ============================================

-- Kategori 1: "Example"
Win:CreateCategory("Example")

local ExampleTab = Win:CreateTab("Example Tab", "rbxassetid://10734741641")   -- Apple (Aktif/Putih)
local SingleTab = Win:CreateTab("Single Tab", "rbxassetid://10734942250")     -- Loop (Tidak Aktif/Biru Muda)
local ExtractTabs = Win:CreateTab("Extract Tabs", "rbxassetid://10723374112")   -- Profile (Tidak Aktif/Biru Muda)

-- Kategori 2: "Misc" (Garis pembatas biru otomatis akan dibuat tepat di atasnya)
Win:CreateCategory("Misc")
local SettingsTab = Win:CreateTab("Settings", "rbxassetid://10734950309")     -- Settings (Tidak Aktif/Biru Muda)
local ConfigTab = Win:CreateTab("Config", "rbxassetid://10734741211")         -- Config (Tidak Aktif/Biru Muda)


-- ========================================================================
-- [[ KOLOM KIRI (SECTION 1) ]]
-- ========================================================================
local Sec1 = ExampleTab:CreateSection("Section")

Sec1:CreateToggle("Toggle", false, "Toggle1_Sec1", { info = true, keybind = "E" }, function(state)
    print("Toggle 1 (Sec1): ", state)
end)

Sec1:CreateToggle("Toggle", false, "Toggle2_Sec1", { gear = true }, function(state)
    print("Toggle 2 (Sec1): ", state)
end)

Sec1:CreateKeybind("Keybind", Enum.KeyCode.LeftAlt, "Keybind1_Sec1", function(key)
    print("Keybind (Sec1): ", key.Name)
end)

-- Slider dengan textbox input manual angka di sebelah kanan
Sec1:CreateSlider("Slider", 0, 100, 50, "Slider1_Sec1", function(val)
    print("Slider (Sec1): ", val)
end)

Sec1:CreateColorPicker("ColorPicker", Color3.fromRGB(0, 240, 130), "Color1_Sec1", function(color)
    print("Color (Sec1): ", color)
end)

Sec1:CreateDropdown("Single Dropdown", {"Head", "Torso", "Left Arm", "Right Arm"}, "Head", "Dropdown1_Sec1", function(opt)
    print("Dropdown (Sec1): ", opt)
end)

Sec1:CreateMultiDropdown("Multi Dropdown", {"Head", "Torso", "Left Arm", "Right Arm"}, {"Head"}, "MultiDropdown1_Sec1", function(opts)
    print("Multi Dropdown (Sec1): ", table.concat(opts, ", "))
end)

Sec1:CreateButton("Button", function()
    print("Button 1 Clicked!")
end)

Sec1:CreateParagraph("Paragraph", "Very cool paragraph\nAll element in this scrtion\nwill be saved to the config!")


-- ========================================================================
-- [[ KOLOM KANAN (SECTION 2) ]]
-- ========================================================================
local Sec2 = ExampleTab:CreateSection("Section")

Sec2:CreateToggle("Toggle", false, "Toggle1_Sec2", { keybind = "E" }, function(state)
    print("Toggle 1 (Sec2): ", state)
end)

Sec2:CreateToggle("Toggle", false, "Toggle2_Sec2", { gear = true }, function(state)
    print("Toggle 2 (Sec2): ", state)
end)

Sec2:CreateKeybind("Keybind", Enum.KeyCode.LeftAlt, "Keybind1_Sec2", function(key)
    print("Keybind (Sec2): ", key.Name)
end)

-- Slider dengan textbox input manual angka di sebelah kanan
Sec2:CreateSlider("Slider", 0, 100, 50, "Slider1_Sec2", function(val)
    print("Slider (Sec2): ", val)
end)

Sec2:CreateColorPicker("ColorPicker", Color3.fromRGB(0, 240, 130), "Color1_Sec2", function(color)
    print("Color (Sec2): ", color)
end)

Sec2:CreateDropdown("Single Dropdown", {"Head", "Torso", "Left Arm", "Right Arm"}, "Head", "Dropdown1_Sec2", function(opt)
    print("Dropdown (Sec2): ", opt)
end)

Sec2:CreateMultiDropdown("Multi Dropdown", {"Head", "Torso", "Left Arm", "Right Arm"}, {"Head"}, "MultiDropdown1_Sec2", function(opts)
    print("Multi Dropdown (Sec2): ", table.concat(opts, ", "))
end)

Sec2:CreateButton("Button", function()
    print("Button 2 Clicked!")
end)

Sec2:CreateParagraph("Paragraph", "Very cool paragraph\nAll elements in this section\nwill not be save to the config")
