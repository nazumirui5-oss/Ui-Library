-- =============================================================================
-- [[ LOUIS HUB - FULL LOADER & API IMPLEMENTATION SHOWCASE ]]
-- =============================================================================
-- This script serves as both an executable demonstration and a template.
-- You can upload the UI Library code to your preferred host (e.g., GitHub, Pastebin) 
-- and load it dynamically using loadstring() as shown below.

-- 1. LOAD THE UI LIBRARY (Example Host Loading Template)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/tester.lua"))()
-- For direct local execution, ensure the UI Library script is run right before this loader.
local Library = Library or shared.LouisHubLibrary -- Fallback reference if executed in the same environment

-- If you are running this as a single script, you can paste the library code here, 
-- or ensure it is stored globally in the execution registry.
if not Library then
    warn("Louis Hub Library not found! Make sure to run the UI Library script first.")
    return
end

-- =============================================================================
-- [[ 2. WINDOW INITIALIZATION ]]
-- =============================================================================
-- CreateWindow Parameters:
-- 1. Script Name (Sub-Header)
-- 2. User Status/Tag (Displayed inside the sidebar profile card)
-- 3. Custom Preferences Configuration Table
local Window = Library:CreateWindow("Combat & Utility", "PREMIUM USER", {
    Mode = "PC", -- Default layout: "PC" or "Mobile"
    Scale = 1.0, -- Initial UI scaling size multiplier
    Font = Enum.Font.GothamMedium,
    BoldFont = Enum.Font.GothamBold,
    TextSizeMultiplier = 1.0
})

-- =============================================================================
-- [[ 3. "EXAMPLE" CATEGORY SHOWCASE ]]
-- =============================================================================
-- Creating the requested "Example" Category to house our demonstration tabs.
Window:CreateCategory("Example")

-- -----------------------------------------------------------------------------
-- TAB 1: BASIC ELEMENTS SHOWCASE
-- -----------------------------------------------------------------------------
local BasicTab = Window:CreateTab("Basic Elements", "sliders")

-- Let's create a Section inside our Tab
local ToggleSection = BasicTab:CreateSection("Switches & Bindings")

-- A. Toggle Element
-- Parameters: Label Text, Default State, Configuration Flag (for saving/loading), Config Extras Table, Callback
ToggleSection:CreateToggle("Aim Assist", false, "Example_AimAssist", {
    info = "Automatically guides your crosshair towards nearby players.", -- Interactive Info Modal
    keybind = "G", -- Fast PC keyboard trigger shortcut
    external = { buttonType = "Toggle" } -- Spawns a pin-button to tether an external floating widget
}, function(state)
    print("Aim Assist toggled to:", state)
end)

-- B. Keybind Element
-- Parameters: Label Text, Default KeyCode, Configuration Flag, Callback
ToggleSection:CreateKeybind("Trigger Keybind", Enum.KeyCode.F, "Example_TriggerKey", function(keyCode)
    print("Keybind changed or triggered with KeyCode:", keyCode.Name)
end)

local NumberSection = BasicTab:CreateSection("Value adjustments")

-- C. Slider Element
-- Parameters: Label Text, Min Value, Max Value, Default Value, Configuration Flag, Callback
NumberSection:CreateSlider("Field Of View", 30, 120, 70, "Example_FOV", function(value)
    print("FOV updated to:", value)
end)

-- D. Button Element
-- Parameters: Label Text, Optional Configuration, Callback
NumberSection:CreateButton("Reset Settings", {
    external = { buttonType = "Click" } -- Pin to external widget
}, function()
    -- Reset setting values using element registry control methods
    Library.Registry["Example_AimAssist"].Control:Set(false)
    Library.Registry["Example_FOV"].Control:Set(70)
    Library:CreateNotification("System Reset", "All Showcase settings have been restored to default.", 3)
end)

-- -----------------------------------------------------------------------------
-- TAB 2: ADVANCED SELECTIONS SHOWCASE
-- -----------------------------------------------------------------------------
local AdvancedTab = Window:CreateTab("Advanced Selections", "gear")

local SelectionSection = AdvancedTab:CreateSection("Drop-downs & Inputs")

-- E. Single-Selection Dropdown
-- Parameters: Label Text, Options List Table, Default Value, Configuration Flag, Callback
SelectionSection:CreateDropdown("Aimbot Target Part", {"Head", "Torso", "Left Arm", "Right Arm"}, "Head", "Example_Hitbox", function(selectedOption)
    print("Aimbot target updated to:", selectedOption)
end)

-- F. Multi-Selection Dropdown
-- Parameters: Label Text, Options List Table, Default Selected Array Table, Configuration Flag, Callback
SelectionSection:CreateMultiDropdown("Target Priority Filter", {"Friends", "Team", "NPCs", "Enemies"}, {"Enemies"}, "Example_Priority", function(selectedTable)
    print("Priority Filters updated to:", table.concat(selectedTable, ", "))
end)

-- G. Color Picker Element (Hex Code compatible)
-- Parameters: Label Text, Default Color3 Value, Configuration Flag, Callback
SelectionSection:CreateColorPicker("ESP Overlay Color", Color3.fromRGB(0, 213, 239), "Example_Color", function(color)
    print("ESP Color changed to Hex:", Color3ToHex(color))
end)

-- H. TextBox Input (Clips and scales cleanly)
-- Parameters: Label Text, Placeholder text, Configuration Flag, Callback
SelectionSection:CreateTextBox("Webhook Link", "Paste Discord webhook here...", "Example_Webhook", function(text)
    print("TextBox entered text:", text)
end)

-- -----------------------------------------------------------------------------
-- TAB 3: SUB-PAGES SYSTEM DEMONSTRATION
-- -----------------------------------------------------------------------------
-- This tab showcases our upgraded sub-page nested architecture.
local SubPageTab = Window:CreateTab("Nested Pages", "folder")

-- Creating Sub-Pages (Page buttons automatically generate on top of the tab panel)
local PageOne = SubPageTab:CreatePage("Page 1")
local PageTwo = SubPageTab:CreatePage("Page 2")

-- Setting up sections inside Page 1
local PageOneSec = PageOne:CreateSection("Primary Page Configurations")
PageOneSec:CreateParagraph("Sub-Page System Info", "Welcome to the nested page layout. You can divide your features across multiple nested page panels under a single tab scrollbar.")

PageOneSec:CreateToggle("Enable Page 1 Script", false, "Page1_State", {}, function(state)
    print("Page 1 Script state:", state)
end)

-- Setting up sections inside Page 2
local PageTwoSec = PageTwo:CreateSection("Secondary Page Configurations")
PageTwoSec:CreateParagraph("Visual Cleanliness", "Using sub-pages prevents vertical scrolling fatigue inside long menu layouts.")

PageTwoSec:CreateSlider("Walkspeed Multiplier", 16, 150, 16, "Page2_Walkspeed", function(val)
    print("Walkspeed value set to:", val)
end)

-- -----------------------------------------------------------------------------
-- TAB 4: EXTERNAL WIDGET MANIPULATION
-- -----------------------------------------------------------------------------
-- Demonstrates how to create, load, save, and dynamically control external buttons 
-- using the new API method controllers.
local ExtTab = Window:CreateTab("External Controls", "shield")
local ExtSection = ExtTab:CreateSection("Floating Button Controller")

ExtSection:CreateParagraph("External Button API", "This controller demonstrates how you can programmatically resize, rename, show/hide, and lock/unlock external floating action buttons.")

ExtSection:CreateButton("Launch External Widget Controller", function()
    -- Spawn the external button
    -- Parameters: Text, Button Type, Shape, Unique Flag, Callback
    local ExtController = Library:CreateExternalButton("Aim Assist Control", "Toggle", "Round", "External_Demo_Button", function(state)
        print("Floating button clicked! Active State:", state)
    end)

    Library:CreateNotification("External Controller Launched", "Running automated sequence on external button...", 4)
    
    -- Demonstrating programmatical control methods sequentially:
    task.spawn(function()
        task.wait(1.5)
        ExtController:SetText("Scaling Widget...")
        ExtController:SetSize(UDim2.new(0, 160, 0, 40)) -- Dynamic sizing
        
        task.wait(1.5)
        ExtController:SetText("Dragging Locked")
        ExtController:SetDragLock(true) -- Lock position on screen
        
        task.wait(1.5)
        ExtController:SetText("Dragging Unlocked")
        ExtController:SetDragLock(false) -- Unlock drag freedom
        
        task.wait(1.5)
        ExtController:SetText("Hiding Widget...")
        task.wait(0.5)
        ExtController:SetVisible(false) -- Hide from screen
        
        task.wait(1.5)
        ExtController:SetVisible(true) -- Restore visibility
        ExtController:SetText("Widget Controlled!")
        ExtController:SetSize(UDim2.new(0, 120, 0, 30)) -- Standard sizing
        
        Library:CreateNotification("Sequence Finished", "External button has processed all upgraded API methods successfully.", 4)
    end)
end)

-- =============================================================================
-- [[ 4. SCRIPT BOOT COMPLETED ]]
-- =============================================================================
Library:CreateNotification("Louis Hub Loaded", "Developer Example loader initialized successfully. Adjust configs under UI Settings.", 5)
