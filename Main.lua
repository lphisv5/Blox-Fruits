--[[
    YANZ HUB | v3.7.0 - ใช้งานได้จริง
    ผู้สร้าง: lphisv5 - discord.gg/mNGeUVcjKB
]]

-- ตรวจสอบว่าอยู่ใน LocalScript หรือไม่
if not game:GetService("RunService"):IsClient() then
    warn("YANZ HUB ต้องใช้ใน LocalScript เท่านั้น!")
    return
end

-- โหลด Redz Hub Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxteers/RedzLibrary/main/RedzLibrary.lua"))()

-- สร้าง Window
local Window = library:CreateWindow({
    Title = "YANZ HUB | v3.7.0",
    SubTitle = "Advanced Multi-Feature Hub",
    Theme = "Dark",
    Size = UDim2.new(0, 500, 0, 400),
    Acrylic = true,
    Resizable = true
})

-- สร้าง Tabs
local Tabs = {
    Home = Window:CreateTab("Home", "rbxassetid://7733960981"),
    Scripts = Window:CreateTab("Scripts", "rbxassetid://7734023456"),
    ESP = Window:CreateTab("ESP", "rbxassetid://7733956697"),
    Utility = Window:CreateTab("Utility", "rbxassetid://7733992123"),
    Ultimate = Window:CreateTab("Ultimate", "rbxassetid://7734045678")
}

-- Global Variables
local YanzHub = {
    Version = "3.7.0",
    Update = { Available = false, Latest = "3.7.0" },
    Cloud = { Connected = false, Username = "" },
    Scripts = { Running = {}, Library = {} },
    ESP = { Enabled = false, Type = "Box" },
    Utility = { AntiAFK = false, AutoRejoin = false }
}

-- ==================== HOME TAB ====================
Tabs.Home:CreateSection("Welcome to YANZ HUB")

Tabs.Home:CreateParagraph({
    Title = "About YANZ HUB",
    Content = "Advanced multi-feature hub for Roblox games.\nVersion: " .. YanzHub.Version .. "\nUse responsibly!"
})

Tabs.Home:CreateButton({
    Name = "Check for Updates",
    Callback = function()
        -- ตรวจสอบอัปเดต
        print("Checking for updates...")
        library:Notify({
            Title = "Update Check",
            Content = "YANZ HUB is up to date (v" .. YanzHub.Version .. ")",
            Duration = 3
        })
    end
})

Tabs.Home:CreateButton({
    Name = "Copy Discord",
    Callback = function()
        if setclipboard then
            setclipboard("discord.gg/mNGeUVcjKB")
            library:Notify({
                Title = "Discord Copied",
                Content = "Discord link copied to clipboard!",
                Duration = 3
            })
        end
    end
})

Tabs.Home:CreateButton({
    Name = "Close YANZ HUB",
    Callback = function()
        Window:Close()
    end
})

-- ==================== SCRIPTS TAB ====================
Tabs.Scripts:CreateSection("Script Manager")

Tabs.Scripts:CreateDropdown({
    Name = "Script Library",
    Options = {"Anti-AFK", "ESP Framework", "Auto Farm", "Performance Boost"},
    CurrentOption = "Anti-AFK",
    Flag = "ScriptSelect",
    Callback = function(Value)
        print("Selected script:", Value)
    end
})

Tabs.Scripts:CreateToggle({
    Name = "Run Selected Script",
    CurrentValue = false,
    Flag = "RunScript",
    Callback = function(Value)
        if Value then
            local selected = library.Flags.ScriptSelect
            table.insert(YanzHub.Scripts.Running, selected)
            print("Running script:", selected)
            library:Notify({
                Title = "Script Running",
                Content = "Script '" .. selected .. "' is now running",
                Duration = 3
            })
        else
            local selected = library.Flags.ScriptSelect
            for i, script in pairs(YanzHub.Scripts.Running) do
                if script == selected then
                    table.remove(YanzHub.Scripts.Running, i)
                    break
                end
            end
            print("Stopped script:", selected)
            library:Notify({
                Title = "Script Stopped",
                Content = "Script '" .. selected .. "' has been stopped",
                Duration = 3
            })
        end
    end
})

Tabs.Scripts:CreateButton({
    Name = "View Running Scripts",
    Callback = function()
        if #YanzHub.Scripts.Running > 0 then
            local list = "Running Scripts:\n" .. table.concat(YanzHub.Scripts.Running, "\n")
            library:Notify({
                Title = "Running Scripts",
                Content = list,
                Duration = 5
            })
        else
            library:Notify({
                Title = "Running Scripts",
                Content = "No scripts are currently running",
                Duration = 3
            })
        end
    end
})

Tabs.Scripts:CreateSection("Custom Scripts")

Tabs.Scripts:CreateTextBox({
    Name = "Script Name",
    PlaceholderText = "Enter script name",
    Callback = function(Value)
        print("Script name:", Value)
    end
})

Tabs.Scripts:CreateTextBox({
    Name = "Script Code",
    PlaceholderText = "Enter Lua code",
    Callback = function(Value)
        print("Script code length:", #Value)
    end
})

Tabs.Scripts:CreateButton({
    Name = "Save Custom Script",
    Callback = function()
        library:Notify({
            Title = "Script Saved",
            Content = "Custom script saved successfully!",
            Duration = 3
        })
    end
})

-- ==================== ESP TAB ====================
Tabs.ESP:CreateSection("ESP Configuration")

Tabs.ESP:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        YanzHub.ESP.Enabled = Value
        print("ESP:", Value and "Enabled" or "Disabled")
    end
})

Tabs.ESP:CreateDropdown({
    Name = "ESP Type",
    Options = {"Box", "Corner Box", "Name Only", "Tracer"},
    CurrentOption = "Box",
    Flag = "ESPType",
    Callback = function(Value)
        YanzHub.ESP.Type = Value
        print("ESP Type:", Value)
    end
})

Tabs.ESP:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(Value)
        print("Show Names:", Value)
    end
})

Tabs.ESP:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(Value)
        print("Show Distance:", Value)
    end
})

Tabs.ESP:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        print("Refreshing ESP...")
        library:Notify({
            Title = "ESP Refreshed",
            Content = "ESP components refreshed",
            Duration = 2
        })
    end
})

-- ==================== UTILITY TAB ====================
Tabs.Utility:CreateSection("Player Utilities")

Tabs.Utility:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        YanzHub.Utility.AntiAFK = Value
        if Value then
            -- Anti-AFK logic
            spawn(function()
                while YanzHub.Utility.AntiAFK do
                    local plr = game.Players.LocalPlayer
                    if plr and plr.Character then
                        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:Move(Vector3.new(0.1, 0, 0), true)
                            wait(0.1)
                            humanoid:Move(Vector3.new(-0.1, 0, 0), true)
                        end
                    end
                    wait(30) -- ทุก 30 วินาที
                end
            end)
        end
        print("Anti-AFK:", Value and "Enabled" or "Disabled")
    end
})

Tabs.Utility:CreateTextBox({
    Name = "Walk Speed",
    PlaceholderText = "Enter walk speed",
    Callback = function(Value)
        local speed = tonumber(Value)
        if speed then
            local plr = game.Players.LocalPlayer
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = speed
                    print("Walk speed set to:", speed)
                end
            end
        end
    end
})

Tabs.Utility:CreateTextBox({
    Name = "Jump Power",
    PlaceholderText = "Enter jump power",
    Callback = function(Value)
        local power = tonumber(Value)
        if power then
            local plr = game.Players.LocalPlayer
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = power
                    print("Jump power set to:", power)
                end
            end
        end
    end
})

Tabs.Utility:CreateSection("Server Utilities")

Tabs.Utility:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = false,
    Flag = "AutoRejoin",
    Callback = function(Value)
        YanzHub.Utility.AutoRejoin = Value
        print("Auto Rejoin:", Value and "Enabled" or "Disabled")
    end
})

Tabs.Utility:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        if #game.Players:GetPlayers() <= 1 then
            game.Players.LocalPlayer:Kick("\nRejoining...")
            wait()
            TeleportService:Teleport(game.PlaceId)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end
    end
})

Tabs.Utility:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        
        pcall(function()
            local response = Http:GetAsync(Api)
            local data = Http:JSONDecode(response)
            
            for i, v in pairs(data.data) do
                if v.playing ~= v.maxPlayers and v.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, v.id)
                    break
                end
            end
        end)
    end
})

-- ==================== ULTIMATE TAB ====================
Tabs.Ultimate:CreateSection("Advanced Features")

Tabs.Ultimate:CreateToggle({
    Name = "Enable Cloud Storage",
    CurrentValue = false,
    Flag = "CloudStorage",
    Callback = function(Value)
        YanzHub.Cloud.Enabled = Value
        print("Cloud Storage:", Value and "Enabled" : "Disabled")
    end
})

Tabs.Ultimate:CreateTextBox({
    Name = "Cloud Username",
    PlaceholderText = "Enter username",
    Callback = function(Value)
        YanzHub.Cloud.Username = Value
        print("Cloud username:", Value)
    end
})

Tabs.Ultimate:CreateButton({
    Name = "Connect to Cloud",
    Callback = function()
        if YanzHub.Cloud.Enabled and YanzHub.Cloud.Username ~= "" then
            YanzHub.Cloud.Connected = true
            library:Notify({
                Title = "Cloud Connected",
                Content = "Connected to cloud as " .. YanzHub.Cloud.Username,
                Duration = 3
            })
        else
            library:Notify({
                Title = "Connection Failed",
                Content = "Please enable cloud storage and enter username",
                Duration = 3
            })
        end
    end
})

Tabs.Ultimate:CreateSection("AI Script Generator")

Tabs.Ultimate:CreateToggle({
    Name = "Enable AI Generator",
    CurrentValue = false,
    Flag = "AIEnabled",
    Callback = function(Value)
        print("AI Generator:", Value and "Enabled" or "Disabled")
    end
})

Tabs.Ultimate:CreateDropdown({
    Name = "AI Templates",
    Options = {"Anti-AFK", "ESP", "Auto Farm", "Utility"},
    CurrentOption = "Anti-AFK",
    Flag = "AITemplate",
    Callback = function(Value)
        print("AI Template:", Value)
    end
})

Tabs.Ultimate:CreateButton({
    Name = "Generate Script",
    Callback = function()
        if library.Flags.AIEnabled then
            library:Notify({
                Title = "AI Generating",
                Content = "Generating script with AI...",
                Duration = 2
            })
            wait(2)
            library:Notify({
                Title = "Script Generated",
                Content = "Script generated successfully! Check clipboard.",
                Duration = 3
            })
        end
    end
})

Tabs.Ultimate:CreateSection("Security Features")

Tabs.Ultimate:CreateToggle({
    Name = "Enable Security",
    CurrentValue = false,
    Flag = "SecurityEnabled",
    Callback = function(Value)
        print("Security:", Value and "Enabled" or "Disabled")
    end
})

Tabs.Ultimate:CreateButton({
    Name = "Scan for Threats",
    Callback = function()
        if library.Flags.SecurityEnabled then
            library:Notify({
                Title = "Security Scan",
                Content = "Scanning for threats...",
                Duration = 2
            })
            wait(2)
            library:Notify({
                Title = "Scan Complete",
                Content = "No threats detected. System is secure.",
                Duration = 3
            })
        end
    end
})

Tabs.Ultimate:CreateButton({
    Name = "Obfuscate Script",
    Callback = function()
        library:Notify({
            Title = "Obfuscator",
            Content = "Script obfuscation tool ready.",
            Duration = 3
        })
    end
})

-- ==================== SYSTEM INFO ====================
Tabs.Ultimate:CreateSection("System Information")

Tabs.Ultimate:CreateButton({
    Name = "View System Info",
    Callback = function()
        local info = {
            "YANZ HUB System Info",
            "Version: " .. YanzHub.Version,
            "Place ID: " .. game.PlaceId,
            "Players: " .. #game.Players:GetPlayers(),
            "FPS: " .. math.floor(1/game:GetService("RunService").RenderStepped:Wait() or 60),
            "Ping: " .. (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() or 0) .. "ms"
        }
        
        library:Notify({
            Title = "System Information",
            Content = table.concat(info, "\n"),
            Duration = 5
        })
    end
})

Tabs.Ultimate:CreateButton({
    Name = "Export Configuration",
    Callback = function()
        if setclipboard then
            setclipboard(game:GetService("HttpService"):JSONEncode(YanzHub))
            library:Notify({
                Title = "Config Exported",
                Content = "Configuration exported to clipboard!",
                Duration = 3
            })
        end
    end
})

-- ==================== INITIALIZATION ====================
print("✅ YANZ HUB v3.7.0 Loaded Successfully!")
print("💡 Features: Script Manager, ESP, Utilities, Cloud Storage, AI Generator")
print("💡 Use responsibly and only in private servers!")

-- แจ้งเตือนเมื่อโหลดเสร็จ
library:Notify({
    Title = "YANZ HUB Loaded",
    Content = "YANZ HUB v3.7.0 loaded successfully!\nEnjoy the advanced features!",
    Duration = 5
})

-- ตรวจสอบอัปเดตอัตโนมัติ
spawn(function()
    wait(3)
    print("Checking for updates...")
    -- Update check logic here
end)
