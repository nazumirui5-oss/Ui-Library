-- Memuat UI Library utama dari file gg.txt
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- Inisialisasi Window Utama (Config terisolasi di dalam folder "Compkiller_Configs/Murder_Mystery_2/")
local Win = Library:CreateWindow("Murder Mystery 2", "V2.6", {
    Mode = "PC",                       -- "PC" atau "Mobile" (bisa diubah manual sewaktu-waktu)
    Scale = 1.0,                       -- Skala awal UI (bisa diubah manual sewaktu-waktu)
    TextSizeMultiplier = 1.0,          -- Skala teks
    Font = Enum.Font.GothamMedium,     -- Font utama
    BoldFont = Enum.Font.GothamBold    -- Font tebal
})

-- ============================================
-- [[ PENATAAN KATEGORI & TAB (SIDEBAR) ]]
-- ============================================

-- Kategori: "Example"
Win:CreateCategory("Example")

-- Menggunakan download ikon Lucide otomatis dari repositori GitHub latte-soft
local ExampleTab = Win:CreateTab("Example Tab", "apple")   

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
