-- Fetch the UI Library source from your gg.txt file
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- Initialize the Main Window (Hidden on launch, only the rounded floating squircle button appears)
local Win = Library:CreateWindow("Universal Script", "V2.6", {
    Mode = "PC",                       -- Initial mode: "PC" or "Mobile"
    Scale = 1.0,                       -- Initial UI scale (1.0 = standard)
    TextSizeMultiplier = 1.0,          -- Initial text size multiplier
    Font = Enum.Font.GothamMedium,     -- Normal Font
    BoldFont = Enum.Font.GothamBold    -- Bold Font
})

-- ========================================================
-- [[ SIMPLE EXAMPLES (BOILERPLATE TAB) ]]
-- ========================================================
Win:CreateCategory("Features")

-- Create a tab using Lucide "apple" icon
local FeatureTab = Win:CreateTab("Main Hacks", "apple")   

-- Create Section 1 (Left Area)
local LeftSec = FeatureTab:CreateSection("Movement hacks")

-- Toggle example
LeftSec:CreateToggle("WalkSpeed Hack", false, "Toggle_Speed", { info = true, keybind = "X" }, function(state)
    print("WalkSpeed State: ", state)
end)

-- Keybind example
LeftSec:CreateKeybind("Trigger Keybind", Enum.KeyCode.E, "Keybind_Trigger", function(key)
    print("Active Keybind: ", key.Name)
end)

-- Slider example (Supports manual typing values)
LeftSec:CreateSlider("Speed Value", 16, 250, 16, "Slider_SpeedVal", function(val)
    print("New Speed: ", val)
end)

-- Color Picker example (Supports manual Hex code inputs like #ffffff)
LeftSec:CreateColorPicker("ESP Color", Color3.fromRGB(0, 213, 239), "Color_ESP", function(color)
    print("New ESP Color: ", color)
end)


-- Create Section 2 (Right Area)
local RightSec = FeatureTab:CreateSection("Combat Settings")

-- Dropdown example
RightSec:CreateDropdown("Target Selection", {"Nearest", "Lowest HP", "Prioritise Friends"}, "Nearest", "Dropdown_Target", function(choice)
    print("Target Priority: ", choice)
end)

-- Multi-Dropdown example
RightSec:CreateMultiDropdown("ESP Visuals", {"Boxes", "Tracers", "Name Tags"}, {"Boxes"}, "Multi_ESPVisuals", function(options)
    print("Active ESP: ", table.concat(options, ", "))
end)

-- TextBox example
RightSec:CreateTextBox("Target White-List", "Enter username...", "Text_Whitelist", function(input)
    print("Whitelisted Player: ", input)
end)

-- Button example
RightSec:CreateButton("Apply Changes Now", function()
    print("Changes applied!")
end)

-- Info Box Paragraph example
RightSec:CreateParagraph("Status Log", "Use this section to config combat. WalkSpeed hack settings can be modified on the left section.")
