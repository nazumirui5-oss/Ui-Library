-- Loader Script (Execute this in your Executor)
-- Make sure to replace the URL below with your raw GitHub link hosting the updated UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- Initialize Main Window
-- (Main UI remains hidden at startup; only the rounded square floating toggle icon is visible)
local Win = Library:CreateWindow("Universal Loader", "V2.6", {
    Mode = "PC",                       -- Set "PC" or "Mobile" initial layout responsive modes
    Scale = 1.0,                       -- Sizing Scale multiplier
    TextSizeMultiplier = 1.0,          -- Text Size multiplier
    Font = Enum.Font.GothamMedium,     -- Sourced text font
    BoldFont = Enum.Font.GothamBold    -- Sourced bold text font
})

-- Trigger a premium Toast Notification as a startup diagnostic showcase
Library:CreateNotification("Nexus Diagnostics", "UI System initiated safely. Theme engine connected successfully.", 4)

-- ========================================================
-- [[ BOILERPLATE CATEGORY AND TAB REFERENCE CREATIONS ]]
-- ========================================================
Win:CreateCategory("Boilerplate")

-- Custom Tab featuring dynamic Lucide "apple" icon downloading
local ExampleTab = Win:CreateTab("Feature Tab", "apple")   

-- Section 1: left layout elements
local Sec1 = ExampleTab:CreateSection("Left Section")

-- 1. Toggle Switch
Sec1:CreateToggle("Toggle Switch", false, "Toggle_Key1", { info = true, keybind = "E" }, function(state)
    print("Toggle State: ", state)
end)

-- 2. Bind Button
Sec1:CreateKeybind("Select Keybind", Enum.KeyCode.LeftAlt, "Keybind_Key1", function(key)
    print("Keybind State: ", key.Name)
end)

-- 3. Slider (Supports direct input box typing)
Sec1:CreateSlider("Numeric Slider", 0, 100, 50, "Slider_Key1", function(val)
    print("Slider Value: ", val)
end)

-- 4. Color Picker (Supports hex code entry like #ffffff)
Sec1:CreateColorPicker("Color Selector", Color3.fromRGB(0, 213, 239), "Color_Key1", function(color)
    print("Selected Color (RGB): ", color)
end)


-- Section 2: right layout elements
local Sec2 = ExampleTab:CreateSection("Right Section")

-- 5. Standard Dropdown Menu
Sec2:CreateDropdown("Single Selection", {"Aimbot", "Rage", "Legit"}, "Aimbot", "Dropdown_Key1", function(option)
    print("Dropdown Selected: ", option)
end)

-- 6. Multi Selection Menu
Sec2:CreateMultiDropdown("Multi Selection", {"ESP Boxes", "ESP Lines", "ESP Names"}, {"ESP Boxes"}, "MultiDropdown_Key1", function(options)
    print("Multi-Dropdown Selected: ", table.concat(options, ", "))
end)

-- 7. Standard Text Box (Supports horizontal scrolling & no ellipsis)
Sec2:CreateTextBox("Custom Input Box", "Type something here...", "TextBox_Key1", function(text)
    print("TextBox Submitted: ", text)
end)

-- 8. Command Button
Sec2:CreateButton("Submit Settings", function()
    print("Submit Button Clicked!")
end)

-- 9. Text Paragraph
Sec2:CreateParagraph("Information Box", "This is an example paragraph template. You can write any help descriptions, instructions, or credits here.")
