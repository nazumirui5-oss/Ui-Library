-- Memuat UI Library utama dari file gg.txt Anda
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/test.lua"))()

-- Inisialisasi Window Utama (UI Utama disembunyikan saat startup, hanya ikon floating yang muncul di awal)
local Win = Library:CreateWindow("LouisHub", "V1.0", {
    Mode = "PC",                       -- "PC" atau "Mobile"
    Scale = 1.0,                       -- Skala awal UI (1.0 = normal)
    TextSizeMultiplier = 1.0,          -- Skala font
    Font = Enum.Font.GothamMedium,     -- Font reguler
    BoldFont = Enum.Font.GothamBold    -- Font tebal
})

-- Trigger Toast Notification sebagai demo audit berhasil berjalan
Library:CreateNotification("Nexus Diagnostics", "UI System initiated safely. Theme engine connected successfully.", 4)

-- ========================================================
-- [[ CONTOH TAB UTAMA YANG DIBUAT DI LOADER ]]
-- ========================================================
Win:CreateCategory("Example")

-- Contoh pembuatan Tab baru menggunakan ikon Lucide "apple"
local ExampleTab = Win:CreateTab("Example", "apple")   

-- Pembuatan Section Kiri (Section 1)
local Sec1 = ExampleTab:CreateSection("Left Section")

-- 1. Contoh Toggle
Sec1:CreateToggle("Toggle Switch", false, "Toggle_Key1", { info = true, keybind = "E" }, function(state)
    print("Toggle State: ", state)
end)

-- 2. Contoh Keybind
Sec1:CreateKeybind("Select Keybind", Enum.KeyCode.LeftAlt, "Keybind_Key1", function(key)
    print("Keybind State: ", key.Name)
end)

-- 3. Contoh Slider (Mendukung input manual lewat pengetikan teks angka)
Sec1:CreateSlider("Numeric Slider", 0, 100, 50, "Slider_Key1", function(val)
    print("Slider Value: ", val)
end)

-- 4. Contoh Color Picker (Mendukung input manual lewat kode Hex seperti #ffffff atau ffffff)
Sec1:CreateColorPicker("Color Selector", Color3.fromRGB(0, 213, 239), "Color_Key1", function(color)
    print("Selected Color (RGB): ", color)
end)


-- Pembuatan Section Kanan (Section 2)
local Sec2 = ExampleTab:CreateSection("Right Section")

-- 5. Contoh Dropdown Pilihan Tunggal
Sec2:CreateDropdown("Single Selection", {"Aimbot", "Rage", "Legit"}, "Aimbot", "Dropdown_Key1", function(option)
    print("Dropdown Selected: ", option)
end)

-- 6. Contoh Dropdown Pilihan Ganda (Multi-select)
Sec2:CreateMultiDropdown("Multi Selection", {"ESP Boxes", "ESP Lines", "ESP Names"}, {"ESP Boxes"}, "MultiDropdown_Key1", function(options)
    print("Multi-Dropdown Selected: ", table.concat(options, ", "))
end)

-- 7. Contoh TextBox Input Teks
Sec2:CreateTextBox("Custom Input Box", "Type something here...", "TextBox_Key1", function(text)
    print("TextBox Submitted: ", text)
end)

-- 8. Contoh Tombol (Button)
Sec2:CreateButton("Submit Settings", function()
    print("Submit Button Clicked!")
end)

-- 9. Contoh Paragraf Informasi
Sec2:CreateParagraph("Information Box", "This is an example paragraph template. You can write any help descriptions, instructions, or credits here.")
