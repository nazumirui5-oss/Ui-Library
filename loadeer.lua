-- Memanggil Library (Gunakan baris di bawah ini jika library diletakkan pada script yang sama)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

local Window = Library:CreateWindow("COMPKILLER", "TEST EDITION")

-- ==================== TAB 1: EXAMPLE TAB ====================
local Tab1 = Window:CreateTab("Example Tab", "rbxassetid://10723407389") -- Ikon Home

-- Section Kiri (Akan didistribusikan otomatis ke sebelah Kiri)
local LeftSec = Tab1:CreateSection("Config Enabled Section")

LeftSec:CreateToggle("Aimbot Trigger", false, "Toggle_Aimbot", function(state)
    print("Aimbot State:", state)
end)

LeftSec:CreateKeybind("Aimbot Hotkey", Enum.KeyCode.E, "Keybind_Aimbot", function(key)
    print("Aimbot Bind updated to:", key.Name)
end)

LeftSec:CreateSlider("Smoothness", 1, 100, 50, "Slider_Smoothness", function(value)
    print("Slider Smoothness Value:", value)
end)

LeftSec:CreateColorPicker("Accent Color", Color3.fromRGB(0, 220, 255), "Color_Accent", function(color)
    print("Selected Color:", tostring(color))
end)

LeftSec:CreateDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", "Dropdown_Part", function(selected)
    print("Selected Part:", selected)
end)

-- Section Kanan (Akan didistribusikan otomatis ke sebelah Kanan)
local RightSec = Tab1:CreateSection("Static Actions")

RightSec:CreateMultiDropdown("Whitelist Members", {"Head", "Torso", "Left Arm", "Right Arm"}, {"Head"}, "Multi_Whitelist", function(selectedTable)
    print("Multi-dropdown Selected values:")
    for _, val in ipairs(selectedTable) do
        print("-", val)
    end
end)

RightSec:CreateButton("Apply Changes", function()
    print("Button Clicked: Changes Applied!")
end)

RightSec:CreateParagraph("Important Info", "All changes executed within this specific section are saved dynamically to your config file.")


-- ==================== TAB 2: MISC TAB ====================
local Tab2 = Window:CreateTab("Settings", "rbxassetid://10734950309") -- Ikon Settings

local ThemeSec = Tab2:CreateSection("UI Settings")

ThemeSec:CreateDropdown("Active UI Theme", {"Compkiller", "Nordic Dark"}, "Compkiller", "SelectedTheme", function(themeName)
    Library:SetTheme(themeName)
end)

ThemeSec:CreateParagraph("Credits", "Nexus GUI Engine - Rebuilt Version (2026)")
