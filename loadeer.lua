-- Download the core UI library from gg.txt
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- Initialise the window
-- The system automatically isolates files under "Compkiller_Configs/Murder_Mystery_2/"
local Win = Library:CreateWindow("Murder Mystery 2", "V2.5", {
    Mode = "PC",                       -- "PC" or "Mobile" initial layout mode
    Scale = 1.0,                       -- Scale multiplier (sizes the entire interface)
    TextSizeMultiplier = 1.0,          -- Text size scaling
    Font = Enum.Font.GothamMedium,     -- Regular layout font
    BoldFont = Enum.Font.GothamBold    -- Bold layout font
})

-- ============================================
-- [[ PENATAAN KATEGORI & TAB (SIDEBAR) ]]
-- ============================================

-- Category 1: "Example"
Win:CreateCategory("Example")

-- Download Lucide icons automatically from the latte-soft repository
local ExampleTab = Win:CreateTab("Example Tab", "apple")   

-- ========================================================================
-- [[ LEFT COLUMN (SECTION 1) ]]
-- ========================================================================
local Sec1 = ExampleTab:CreateSection("Section 1")

Sec1:CreateToggle("Toggle Option", false, "Toggle1_Sec1", { info = true, keybind = "E" }, function(state)
    print("Toggle 1 (Sec1): ", state)
end)

Sec1:CreateToggle("Toggle Config", false, "Toggle2_Sec1", { gear = true }, function(state)
    print("Toggle 2 (Sec1): ", state)
end)

Sec1:CreateKeybind("Keybind Shortcut", Enum.KeyCode.LeftAlt, "Keybind1_Sec1", function(key)
    print("Keybind (Sec1): ", key.Name)
end)

Sec1:CreateSlider("Numeric Slider", 0, 100, 50, "Slider1_Sec1", function(val)
    print("Slider (Sec1): ", val)
end)

Sec1:CreateColorPicker("Color Picker", Color3.fromRGB(0, 240, 130), "Color1_Sec1", function(color)
    print("Color (Sec1): ", color)
end)

Sec1:CreateDropdown("Single Choice", {"Head", "Torso", "Left Arm", "Right Arm"}, "Head", "Dropdown1_Sec1", function(opt)
    print("Dropdown (Sec1): ", opt)
end)

Sec1:CreateMultiDropdown("Multi Choice", {"Head", "Torso", "Left Arm", "Right Arm"}, {"Head"}, "MultiDropdown1_Sec1", function(opts)
    print("Multi Dropdown (Sec1): ", table.concat(opts, ", "))
end)

Sec1:CreateButton("Perform Action", function()
    print("Button 1 Clicked!")
end)

Sec1:CreateParagraph("Information", "This layout features dynamic PC & Mobile scaling. Configurations saved here are stored inside isolated game subfolders.")


-- ========================================================================
-- [[ RIGHT COLUMN (SECTION 2) ]]
-- ========================================================================
local Sec2 = ExampleTab:CreateSection("Section 2")

Sec2:CreateToggle("Alternate Toggle", false, "Toggle1_Sec2", { keybind = "E" }, function(state)
    print("Toggle 1 (Sec2): ", state)
end)

Sec2:CreateToggle("Settings Toggle", false, "Toggle2_Sec2", { gear = true }, function(state)
    print("Toggle 2 (Sec2): ", state)
end)

Sec2:CreateKeybind("Alternate Keybind", Enum.KeyCode.LeftAlt, "Keybind1_Sec2", function(key)
    print("Keybind (Sec2): ", key.Name)
end)

Sec2:CreateSlider("Intensity Slider", 0, 100, 50, "Slider1_Sec2", function(val)
    print("Slider (Sec2): ", val)
end)

Sec2:CreateColorPicker("Target Color", Color3.fromRGB(0, 240, 130), "Color1_Sec2", function(color)
    print("Color (Sec2): ", color)
end)

Sec2:CreateDropdown("Target Part", {"Head", "Torso", "Left Arm", "Right Arm"}, "Head", "Dropdown1_Sec2", function(opt)
    print("Dropdown (Sec2): ", opt)
end)

Sec2:CreateMultiDropdown("Selected Zones", {"Head", "Torso", "Left Arm", "Right Arm"}, {"Head"}, "MultiDropdown1_Sec2", function(opts)
    print("Multi Dropdown (Sec2): ", table.concat(opts, ", "))
end)

Sec2:CreateButton("Execute Alternate", function()
    print("Button 2 Clicked!")
end)

Sec2:CreateParagraph("Notes", "Configurations created in the 'Misc' tab can be saved directly in JSON or LUA table formats.")
