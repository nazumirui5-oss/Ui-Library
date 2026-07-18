-- Loader Script (Execute this in your Executor)
-- Make sure to replace the URL below with your raw GitHub link hosting the updated UI Library (gg.txt)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- ========================================================
-- [[ USER MEMBERSHIP CONFIGURATION (EASY TRUE/FALSE) ]]
-- ========================================================
-- Change to 'true' for Premium/VIP loaders (instant unlock)
-- Change to 'false' for Free loaders (locked overlay is enabled)
local IS_PREMIUM_USER = false 

-- Initialize Main Window
local Win = Library:CreateWindow("LouisHub", "V2.6", {
    Mode = "PC",                       -- Set "PC" or "Mobile" initial layout responsive modes
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
-- * If IS_PREMIUM_USER is true -> 'not' turns it false (Tab is created unlocked) [1]
-- * If IS_PREMIUM_USER is false -> 'not' turns it true (Tab is created locked with a 65% transparency shield overlay) [1]
-- * The premium tab button in the sidebar will display a dynamic Lucide "crown" icon, while the overlay uses a "shield" icon.
local PremiumTab = Win:CreateTab("Premium Features", "crown", not IS_PREMIUM_USER) 

local PremiumSection = PremiumTab:CreateSection("Combat Premium")

-- Add your premium features below this line:
-- e.g., PremiumSection:CreateToggle("Silent Aim", false, "Silent_Key", {}, function(state) end)
