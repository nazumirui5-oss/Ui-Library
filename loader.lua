-- Loader Script (Execute this in your Executor)
-- Sourcing the updated UI Library from your raw GitHub link
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- ========================================================
-- [[ USER MEMBERSHIP CONFIGURATION (EASY TRUE/FALSE) ]]
-- ========================================================
-- Change to 'true' for Premium/VIP loaders (instant unlock)
-- Change to 'false' for Free loaders (locked overlay is enabled)
local IS_PREMIUM_USER = false 

-- Initialize Main Window (Set to "Mobile" mode by default)
local Win = Library:CreateWindow("LouisHub", "V2.6", {
    Mode = "Mobile",                   -- Default layout mode set to Mobile layout as requested
    Scale = 1.0,                       -- Sizing Scale multiplier
    TextSizeMultiplier = 1.0,          -- Text Size multiplier
    Font = Enum.Font.GothamMedium,     -- Sourced text font
    BoldFont = Enum.Font.GothamBold    -- Sourced bold text font
})

-- ========================================================
-- [[ CUSTOM CATEGORY & TAB INITIALIZATION ]]
-- ========================================================

-- 1. Free/General Category
Win:CreateCategory("General")

-- Creating a free tab (isPremiumLocked = false)
local MainTab = Win:CreateTab("Main", "user", false)
local MainSection = MainTab:CreateSection("Combat")

-- Add your free features below this line:
-- e.g., MainSection:CreateToggle("Aim Lock", false, "Aim_Key", {}, function(state) end)


-- 2. Premium Category
Win:CreateCategory("Premium Member")

-- Creating a premium tab (isPremiumLocked = not IS_PREMIUM_USER)
-- * If IS_PREMIUM_USER is true -> 'not' turns it false (Tab is created unlocked)
-- * If IS_PREMIUM_USER is false -> 'not' turns it true (Tab is created locked with a 65% transparency shield overlay)
-- * The premium tab button in the sidebar will display a dynamic Lucide "crown" icon, while the overlay uses a "shield" icon.
local PremiumTab = Win:CreateTab("Premium Features", "crown", not IS_PREMIUM_USER) 

local PremiumSection = PremiumTab:CreateSection("Combat Premium")

-- Add your premium features below this line:
-- e.g., PremiumSection:CreateToggle("Silent Aim", false, "Silent_Key", {}, function(state) end)


-- ========================================================
-- [[ TEST EXTERNAL BUTTONS ]]
-- ========================================================
-- Two types of external buttons created directly inside the loader for testing.

-- 1. Toggle Type External Button
local testToggleBtn = Library:CreateExternalButton(
    "Toggle Option (Test)",       -- Button Text
    "Toggle",                     -- Button Type (Toggle)
    "Round",                      -- Corner Shape (Round, Circle, or Sharp)
    "Loader_Test_Toggle",         -- Unique Flag / Save Key
    function(state)               -- Action Callback
        print("External toggle test state:", state)
        Library:CreateNotification("Toggle Callback", "State: " .. tostring(state), 3)
    end
)

-- Configure using the newly supported native methods
testToggleBtn:SetVisible(true)
testToggleBtn:SetSize(UDim2.new(0, 160, 0, 30))
testToggleBtn:SetDragLock(false) -- Allows the button to be dragged on screen

-- 2. Clicker / Action Type External Button
local testClickBtn = Library:CreateExternalButton(
    "Click Option (Test)",        -- Button Text
    "Click",                      -- Button Type (Click)
    "Circle",                     -- Corner Shape
    "Loader_Test_Click",          -- Unique Flag / Save Key
    function()                    -- Action Callback
        print("External clicker button test clicked")
        Library:CreateNotification("Click Callback", "Action successfully executed!", 3)
    end
)

-- Configure using the newly supported native methods
testClickBtn:SetVisible(true)
testClickBtn:SetText("Tap to Execute") -- Modifies text dynamically
testClickBtn:SetSize(UDim2.new(0, 160, 0, 30))
testClickBtn:SetDragLock(false)
