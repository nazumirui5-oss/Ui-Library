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

-- Publish event to unlock built-in premium elements if user membership is verified
if IS_PREMIUM_USER then
    Library.EventBus:Publish("UnlockPremium")
end

-- ========================================================
-- [[ CUSTOM CATEGORY & TAB INITIALIZATION ]]
-- ========================================================

-- 1. Free/General Category
Win:CreateCategory("General")

-- Creating a free tab (isPremiumLocked = false)
local MainTab = Win:CreateTab("Main", "user", false)
local MainSection = MainTab:CreateSection("Combat")

-- Add your free features below this line:
MainSection:CreateToggle("Aim Assist Mod", false, "Aim_Assist_Extension", {}, function(state)
    pcall(function()
        local registryObj = Library.Registry["Comb_AimAssist"]
        if registryObj then
            registryObj.Control:Set(state)
        end
    end)
end)

MainSection:CreateButton("Clear Floating Emitters", function()
    pcall(function()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
                obj:Destroy()
                count = count + 1
            end
        end
        Library:CreateNotification("Effects Cleaner", "Locally cleared " .. tostring(count) .. " visual emitters.", 4)
    end)
end)

-- 2. Premium Category
Win:CreateCategory("Premium Member")

-- Creating a premium tab (isPremiumLocked = not IS_PREMIUM_USER)
-- * If IS_PREMIUM_USER is true -> 'not' turns it false (Tab is created unlocked)
-- * If IS_PREMIUM_USER is false -> 'not' turns it true (Tab is created locked with a 65% transparency shield overlay)
-- * The premium tab button in the sidebar will display a dynamic Lucide "crown" icon, while the overlay uses a "shield" icon.
local PremiumTab = Win:CreateTab("Premium Features", "crown", not IS_PREMIUM_USER) 

local PremiumSection = PremiumTab:CreateSection("Combat Premium")

-- Add your premium features below this line:
PremiumSection:CreateToggle("Silent Aim Exploit", false, "Silent_Aim_Extension", {}, function(state)
    pcall(function()
        local registryObj = Library.Registry["Comb_SilentAim"]
        if registryObj then
            registryObj.Control:Set(state)
        end
    end)
end)

PremiumSection:CreateSlider("Prediction Strength Override", 1, 100, 10, "Prediction_Strength_Extension", function(val)
    pcall(function()
        local registryObj = Library.Registry["Comb_PredictionStrength"]
        if registryObj then
            registryObj.Control:Set(val)
        end
    end)
end)
