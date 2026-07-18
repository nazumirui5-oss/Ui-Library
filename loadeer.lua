-- Loader Script (Execute this in your Executor)
-- Make sure to replace the URL below with your raw GitHub link hosting the updated UI Library (gg.txt)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- ========================================================
-- [[ USER MEMBERSHIP CONFIGURATION (EASY TRUE/FALSE) ]]
-- ========================================================
-- Change to 'true' for Premium/VIP loaders (instantly accessible Premium Tab)
-- Change to 'false' for Free loaders (Premium Tab is locked under a 65% transparency shield overlay)
local IS_PREMIUM_USER = false 

-- Initialize Main Window
-- (Main UI remains hidden at startup; only the rounded square floating toggle icon is visible)
local Win = Library:CreateWindow("LouisHub", "V2.6", {
    Mode = "PC",                       -- Set "PC" or "Mobile" initial layout responsive modes
    Scale = 1.0,                       -- Sizing Scale multiplier
    TextSizeMultiplier = 1.0,          -- Text Size multiplier
    Font = Enum.Font.GothamMedium,     -- Sourced text font
    BoldFont = Enum.Font.GothamBold    -- Sourced bold text font
})

-- ========================================================
-- [[ CATEGORY 1: FREE / GENERAL FITUR ]]
-- ========================================================
Win:CreateCategory("General")

-- Creating a free tab (isPremiumLocked = false)
local MainTab = Win:CreateTab("Main", "user", false)
local MainSection = MainTab:CreateSection("Combat")

-- 1. Toggle (Featuring dynamic info popup & custom mobile floating toggle pin)
MainSection:CreateToggle("Aim Lock", false, "Aim_Key", { 
    info = "Locks your crosshair onto the nearest enemy automatically. Fully optimized for responsive mobile gameplay!", 
    keybind = "E",
    external = { buttonType = "Toggle" } -- Turn on this pin in the UI to spawn an external dynamic Toggle button on mobile!
}, function(state)
    print("Aim Lock Toggle: ", state)
end)

-- 2. Button (Featuring custom mobile floating clicker pin)
MainSection:CreateButton("Manual Kill All", {
    external = { buttonType = "Click" } -- Turn on this pin in the UI to spawn an external dynamic Clicker button on mobile!
}, function()
    print("Kill All Activated!")
end)


-- ========================================================
-- [[ CATEGORY 2: PREMIUM LOCKED TABS SHOWCASE ]]
-- ========================================================
Win:CreateCategory("Premium Member")

-- Tab button displays a dynamic Lucide "crown" icon.
-- The third argument (isPremiumLocked) uses 'not IS_PREMIUM_USER':
-- * If IS_PREMIUM_USER is true -> 'not' turns it false (Tab is created completely UNLOCKED)
-- * If IS_PREMIUM_USER is false -> 'not' turns it true (Tab is created locked with a 65% transparency shield overlay)
local PremiumTab = Win:CreateTab("Premium Features", "crown", not IS_PREMIUM_USER) 

local PremiumSection = PremiumTab:CreateSection("Combat Premium")

-- Premium Silent Aim toggle (Completely secured under the active lock overlay)
PremiumSection:CreateToggle("Super Silent Aim", false, "Silent_Key", {
    info = "Silently redirects all bullets to the target's head without manual aiming. Highly restricted!"
}, function(state)
    print("Silent Aim Toggle: ", state)
end)
