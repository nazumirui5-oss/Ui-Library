-- [[ Louis Hub Loader ]]
-- Define the UI library source URL (Replace this with your uploaded raw GitHub link)
local LibrarySourceURL = "https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/tester.lua"

-- Load the UI Library from the link
local Library = loadstring(game:HttpGet(LibrarySourceURL))()

-- Initialize the main window in Mobile mode (Default)
local Window = Library:CreateWindow("Louis Hub", "Script Name", {
    Mode = "Mobile", -- Defaulting layout mode to Mobile
    Scale = 1.0
})

-- ========================================================
-- [[ TEST EXTERNAL BUTTONS ]]
-- ========================================================
-- These are the two types of external buttons created directly inside the loader for testing.

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
