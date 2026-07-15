-- ========================================================
-- [[ NEXUS COMPKILLER LOADER ]]
-- ========================================================

-- Ganti link di bawah dengan link raw Pastebin atau GitHub Gist berisi kode UI Library Anda
local LibraryURL = "https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua" 

local success, Library = pcall(function()
    return loadstring(game:HttpGet(LibraryURL))()
end)

if not success or not Library then
    warn("Gagal memuat UI Library. Silakan periksa kembali link raw Anda.")
    return
end

-- ========================================================
-- [[ INISIALISASI & CONFIG MENU ]]
-- ========================================================

local Window = Library:CreateWindow("COMPKILLER", "NEVER")

-- Group Kategori Sidebar: Example
Window:CreateCategory("Example")

-- Tab 1
local Tab1 = Window:CreateTab("Example Tab", "rbxassetid://10723407389")

local SecLeft = Tab1:CreateSection("Section")

-- Toggle 1: Dengan Ikon Info dan Keybind inline "E"
SecLeft:CreateToggle("Toggle", false, "Toggle_Info_E", { info = true, keybind = "E" }, function(state)
    print("Toggle State:", state)
end)

-- Toggle 2: Dengan Ikon Gear (Setting) inline
SecLeft:CreateToggle("Toggle", false, "Toggle_Gear", { gear = true }, function(state)
    print("Toggle Gear State:", state)
end)

-- Keybind Standard
SecLeft:CreateKeybind("Keybind", Enum.KeyCode.LAlt, "Bind_LAlt", function(key)
    print("Keybind updated to:", key.Name)
end)

-- Slider Standard (Track gelap, Fill cyan, Handle bulat putih)
SecLeft:CreateSlider("Slider", 1, 100, 50, "Slider_Val", function(v)
    print("Slider updated:", v)
end)

-- ColorPicker (Square rounded preview hijau)
SecLeft:CreateColorPicker("ColorPicker", Color3.fromRGB(0, 255, 120), "CP_Value", function(color)
    print("Color Picker updated:", tostring(color))
end)

-- Single Dropdown (Box ada di bawah label)
SecLeft:CreateDropdown("Single Dropdown", {"Head", "HumanoidRootPart", "Torso"}, "Head", "Dropdown_Part", function(selected)
    print("Dropdown Selected:", selected)
end)

-- Multi Dropdown (Box ada di bawah label)
SecLeft:CreateMultiDropdown("Multi Dropdown", {"Head", "HumanoidRootPart", "Torso"}, {"Head"}, "Multi_Dropdown_Part", function(selectedTable)
    print("Multi Dropdown Updated")
end)

-- Solid Cyan Button
SecLeft:CreateButton("Button", function()
    print("Button clicked!")
end)

-- Paragraph Text
SecLeft:CreateParagraph("Paragraph", "Very cool paragraph\nAll element in this scrtion\nwill be saved to the config!")


-- Section Kanan (Didistribusikan otomatis ke kolom kedua)
local SecRight = Tab1:CreateSection("Section")
SecRight:CreateToggle("Toggle", false, "Toggle_Info_E_Right", { info = true, keybind = "E" })
SecRight:CreateToggle("Toggle", false, "Toggle_Gear_Right", { gear = true })
SecRight:CreateKeybind("Keybind", Enum.KeyCode.LAlt, "Bind_LAlt_Right")
SecRight:CreateSlider("Slider", 1, 100, 50, "Slider_Val_Right")
SecRight:CreateColorPicker("ColorPicker", Color3.fromRGB(0, 255, 120), "CP_Value_Right")
SecRight:CreateDropdown("Single Dropdown", {"Head", "HRP"}, "Head", "Dropdown_Part_Right")
SecRight:CreateMultiDropdown("Multi Dropdown", {"Head", "HRP"}, {"Head"}, "Multi_Dropdown_Part_Right")
SecRight:CreateButton("Button", function() end)
SecRight:CreateParagraph("Paragraph", "Very cool paragraph\nAll elements in this section\nwill not be save to the config")


-- Group Kategori Sidebar: Misc
Window:CreateCategory("Misc")
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://10734950309")
local ConfigTab = Window:CreateTab("Config", "rbxassetid://10734741641")
