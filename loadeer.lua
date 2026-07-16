-- Memuat UI Library utama dari gg.txt
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- Inisialisasi Window Utama dengan Pengaturan Kustom dari Loader
-- Konfigurasi ini secara dinamis mengisolasi folder penyimpanan file di dalam "Compkiller_Configs/Murder_Mystery_2/"
local Win = Library:CreateWindow("Murder Mystery 2", "V2.5", {
    Mode = "PC",                       -- "PC" atau "Mobile"
    Scale = 1.0,                       -- Skala awal UI (1.0 = normal, 1.2 = besar, 0.8 = kecil)
    TextSizeMultiplier = 1.0,          -- Skala teks
    Font = Enum.Font.GothamMedium,     -- Font utama
    BoldFont = Enum.Font.GothamBold    -- Font tebal
})

-- ============================================
-- [[ PENATAAN KATEGORI & TAB (SIDEBAR) ]]
-- ============================================

-- Kategori: "Game Features"
Win:CreateCategory("Game Features")

-- Membuat Tab Utama "Example" dengan sub-tab terkelompok di dalamnya
local ExampleTab = Win:CreateTab("Example", "apple")

-- Membuat Sub-Tab "Example" di dalam Tab Utama "Example"
local ExampleSubTab = ExampleTab:CreateSubTab("Example")

-- ========================================================================
-- [[ PEMBUATAN FITUR DI DALAM SUB-TAB "EXAMPLE" ]]
-- ========================================================================

-- Pembuatan Section 1
local Sec1 = ExampleSubTab:CreateSection("Section 1")

Sec1:CreateToggle("Toggle Option 1", false, "Toggle1_Sec1", { info = true, keybind = "E" }, function(state)
    print("Toggle 1 (Sec1): ", state)
end)

Sec1:CreateToggle("Toggle Option 2", false, "Toggle2_Sec1", { gear = true }, function(state)
    print("Toggle 2 (Sec1): ", state)
end)

Sec1:CreateKeybind("Keybind Bind", Enum.KeyCode.LeftAlt, "Keybind1_Sec1", function(key)
    print("Keybind (Sec1): ", key.Name)
end)

Sec1:CreateSlider("Slider Bar", 0, 100, 50, "Slider1_Sec1", function(val)
    print("Slider (Sec1): ", val)
end)

-- Pembuatan Section 2
local Sec2 = ExampleSubTab:CreateSection("Section 2")

Sec2:CreateColorPicker("ColorPicker Choice", Color3.fromRGB(0, 240, 130), "Color1_Sec1", function(color)
    print("Color (Sec1): ", color)
end)

Sec2:CreateDropdown("Single Dropdown Choice", {"Head", "Torso", "Left Arm", "Right Arm"}, "Head", "Dropdown1_Sec1", function(opt)
    print("Dropdown (Sec1): ", opt)
end)

Sec2:CreateMultiDropdown("Multi Dropdown Choice", {"Head", "Torso", "Left Arm", "Right Arm"}, {"Head"}, "MultiDropdown1_Sec1", function(opts)
    print("Multi Dropdown (Sec1): ", table.concat(opts, ", "))
end)

Sec2:CreateButton("Button Action", function()
    print("Button 1 Clicked!")
end)

Sec2:CreateParagraph("Paragraph Description", "Very cool paragraph\nAll elements are loaded inside sub-tabs flawlessly!")
