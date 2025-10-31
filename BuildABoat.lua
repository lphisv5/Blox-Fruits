if game.PlaceId ~= 537413528 then
    return
end

local Rayfield
local success

success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
    end)
end

if not success or not Rayfield or not Rayfield.CreateWindow then
    error("Unable to load Rayfield UI Library.")
end

local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local player = game.Players.LocalPlayer
local Nplayer = game.Players.LocalPlayer.Name

local Silent = false
local clockTime = 0
local running = false
local totalGoldGained = 0
local Ftime = 0 
local totalGoldBlock = 0
local GoldPerHour = 0
local lastGoldValue = player.Data.Gold.Value
local IGBLOCK = player.Data.GoldBlock.Value

local Window = Rayfield:CreateWindow({
    Name = "YANZ HUB | Build A Boat For Treasure",
    LoadingTitle = "YANZ HUB",
    LoadingSubtitle = "Made by @lphisv5",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "AutoFarmBABFT"
    },
    Discord = {
        Enabled = true,
        Invite = "zrAB2m5gvz",
        RememberJoins = true
    },
    KeySystem = false
})

-------------------------------------------------
-- 🔹 Global Tab
-------------------------------------------------
local Global = Window:CreateTab("Global", 125428076789049)

-- ฟังก์ชันจัดรูปแบบเวลา
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local sec = seconds % 60
    return string.format("%d hours %d minutes %d seconds", hours, minutes, sec)
end

-- เริ่มนับเวลา
local function startClock()
    if running then return end
    running = true
    while running and getgenv().AF do
        clockTime = clockTime + 1
        task.wait(1)
    end
end

-- Stats Paragraph
local FStats = Global:CreateParagraph({
    Title = "Stats",
    Content = "Elapsed time: -\nGoldBlock Gained: -\nGold Gained: -\nGold per hour: -"
})

task.spawn(function()
    while task.wait(1) do
        local FinalGold = player.Data.Gold.Value
        Ftime = formatTime(clockTime)
        local GoldGained = FinalGold - lastGoldValue
        totalGoldGained = totalGoldGained + GoldGained
        local FGBLOCK = player.Data.GoldBlock.Value
        totalGoldBlock = FGBLOCK - IGBLOCK
        GoldPerHour = clockTime > 0 and (totalGoldGained / clockTime) * 3600 or 0
        FStats:Set({
            Title = "Stats",
            Content = "Elapsed time: " .. Ftime .. "\n" ..
                      "GoldBlock Gained: " .. totalGoldBlock .. "\n" ..
                      "Gold Gained: " .. totalGoldGained .. "\n" ..
                      "Gold per hour: " .. math.floor(GoldPerHour)
        })
        lastGoldValue = FinalGold
    end
end)

-- ฟังก์ชัน Auto Farm
local AutoFarm1 = Global:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "",
    Callback = function(Value)
        getgenv().AF = Value

        local player = game.Players.LocalPlayer
        local isFarming = false

        local function safeFind(obj, path)
            local current = obj
            for _, name in ipairs(path) do
                if current:FindFirstChild(name) then
                    current = current[name]
                else
                    return nil
                end
            end
            return current
        end

        local function startAutoFarm()
            if not Value then return end

            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            local newPart = Instance.new("Part")
            newPart.Size = Vector3.new(5, 1, 5)
            newPart.Transparency = 1
            newPart.CanCollide = true
            newPart.Anchored = true
            newPart.Parent = workspace

            local decal = Instance.new("Decal")
            decal.Texture = "rbxassetid://139953968294114"
            decal.Face = Enum.NormalId.Top 
            decal.Parent = newPart

            local function TPAF(iteration)
                if not Value then return end

                local chestTrigger = safeFind(workspace, {"BoatStages","NormalStages","TheEnd","GoldenChest","Trigger"})

                if iteration == 5 then
                    if chestTrigger then
                        firetouchinterest(humanoidRootPart, chestTrigger, 0)
                        task.delay(0.8, function()
                            workspace.ClaimRiverResultsGold:FireServer()
                        end)
                    else
                        warn("⚠️ GoldenChest not found!")
                        Rayfield:Notify({
                            Title = "Auto Farm Error",
                            Content = "GoldenChest not found, skipping...",
                            Duration = 5,
                            Image = 124144713366592,
                        })
                    end
                    humanoidRootPart.CFrame = CFrame.new(-51, 65, 984 + (iteration - 1) * 770)
                else
                    if iteration == 1 then
                        humanoidRootPart.CFrame = CFrame.new(160.161, 29.59, 973.81)
                    else
                        humanoidRootPart.CFrame = CFrame.new(-51, 65, 984 + (iteration - 1) * 770)
                    end
                end

                newPart.Position = humanoidRootPart.Position - Vector3.new(0, 2, 0)
                task.wait(2.3)
                if iteration ~= 4 then
                    local claim = safeFind(workspace, {"ClaimRiverResultsGold"})
                    if claim and claim.FireServer then
                        claim:FireServer()
                    end
                end
            end

            for i = 1, 10 do
                if not Value then break end
                local ok, err = pcall(function()
                    TPAF(i)
                end)
                if not ok then
                    warn("AutoFarm iteration failed:", err)
                end
            end

            newPart:Destroy()
        end

        -- ฟังก์ชันตอน respawn
        local function onCharacterRespawned()
            if getgenv().AF == true then
                task.wait(2)
                local ok, err = pcall(startAutoFarm)
                if not ok then
                    warn("⚠️ AutoFarm failed:", err)
                end
            end
        end

        -- Toggle ON/OFF
        if Value then
            Rayfield:Notify({
                Title = "Auto Farm - Enabled",
                Content = "Isolation mode and Anti-afk is recommended",
                Duration = 6.5,
                Image = 124144713366592,
             })
            player.Character:BreakJoints()
            task.wait(1)
            player.CharacterAdded:Connect(onCharacterRespawned)
        else
            Rayfield:Notify({
                Title = "Auto Farm - Disabled",
                Content = "Please, wait for the iteration to finish...",
                Duration = 6.5,
                Image = 124144713366592,
             })
        end
    end,
})

Global:CreateToggle({
    Name = "Make it Silent",
    CurrentValue = false,
    Callback = function(Value)
        Silent = Value
    end
})

local connection
local function enableAntiAFK()
    if not connection then
        connection = player.Idled:Connect(function()
            if getgenv().afk6464 then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end
end
local function disableAntiAFK()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

task.spawn(function()
    while task.wait(1) do
        if getgenv().afk6464 then
            enableAntiAFK()
        else
            disableAntiAFK()
        end
    end
end)

Global:CreateToggle({
    Name = "Anti-Afk",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().afk6464 = Value
        if Value then
            Rayfield:Notify({Title="Anti-Afk | ON",Content="You won't get kicked",Duration=6.5})
        else
            Rayfield:Notify({Title="Anti-Afk | OFF",Content="You may get kicked after 20m",Duration=6.5})
        end
    end
})

RunService.Stepped:Connect(function()
    if getgenv().AF and not running then
        startClock()
    end
end)

-------------------------------------------------
-- Server Tab
-------------------------------------------------
local ServerTab = Window:CreateTab("Server", 4483362458)
ServerTab:CreateSection("Server Actions")

ServerTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        Rayfield:Notify({
            Title = "Rejoining",
            Content = "Rejoining the current server...",
            Duration = 3.0,
            Image = 124144713366592
        })
        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        ts:Teleport(game.PlaceId, p)
    end
})

ServerTab:CreateButton({
    Name = "Hop Servers",
    Callback = function()
        Rayfield:Notify({
            Title = "Hopping",
            Content = "Searching new server...",
            Duration = 3.0,
            Image = 124144713366592
        })

        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local Player = game:GetService("Players").LocalPlayer

        local success, servers = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGetAsync("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            )
        end)

        if success and servers and servers.data then
            for _,v in pairs(servers.data) do
                if v.playing < v.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, Player)
                    return
                end
            end
        end

        Rayfield:Notify({
            Title = "Hop Failed",
            Content = "No available servers found!",
            Duration = 5
        })
    end
})
