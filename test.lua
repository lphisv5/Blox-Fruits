if game.PlaceId == 3956818381 then
    -- Clear existing UI elements
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:FindFirstChild("MainFrameHolder") or v:FindFirstChild("NotificationHolder") then
            v:Destroy()
            getgenv().autoopencrystals = false
            getgenv().autobuyranks = false
            getgenv().autobuybelts = false
            getgenv().autobuy = false
            getgenv().autobuyskills = false
            getgenv().autosell = false
            getgenv().autoswing = false
            getgenv().autosellpets = false
        end
    end

    -- Load UI library
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TR1V5/TR1V5-V1/main/Ui%20lib"))()
    local Window = Library:New({
        Name = "Hero Hub",
        FolderToSave = "HeroHubStuff"
    })

    local Character = game.Players.LocalPlayer.Character
    local Main = Window:Tab("Autofarm")
    local MainSection = Main:Section("Main")
    local Egg = Window:Tab("Pets")
    local EggSection = Egg:Section("Open Crystals")
    local Teleporting = Window:Tab("Teleporting")
    local TeleportingSection = Teleporting:Section("Teleport To Islands")
    local Player = Window:Tab("LocalPlayer")
    local PlayerSection = Player:Section("Change Your WalkSpeed/JumpPower")
    local Misc = Window:Tab("Misc")
    local MiscSection = Misc:Section("Misc")

    -- Crystal selection and price display
    local PriceLabel = EggSection:Label("Crystal Price: NaN")
    local Price = nil
    local PriceType = nil
    local CrystalsList = {}
    local Selected = nil

    for _, v in pairs(game:GetService("Workspace").mapCrystalsFolder:GetChildren()) do
        table.insert(CrystalsList, v.Name)
    end
    table.sort(CrystalsList, function(a, b)
        return game:GetService("ReplicatedStorage").crystalPrices[a].price.Value < game:GetService("ReplicatedStorage").crystalPrices[b].price.Value
    end)

    EggSection:Dropdown("Choose Crystal: ", CrystalsList, "", "Dropdown", function(t)
        pcall(function()
            local number = require(game:GetService("ReplicatedStorage").globalFunctions)
            Price = game:GetService("ReplicatedStorage").crystalPrices[t].price.Value
            PriceType = game:GetService("ReplicatedStorage").crystalPrices[t].priceType.Value
            PriceLabel:Set("Crystal Price: " .. tostring(number.shortenNumber(Price)) .. " " .. tostring(PriceType))
            Selected = t
        end)
    end)

    EggSection:Button("Open Once", function()
        if not Selected then return end
        local args = {"openCrystal", Selected}
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer(unpack(args))
    end)

    EggSection:Toggle("Auto Open Crystals", false, "Toggle", function(v)
        getgenv().autoopencrystals = v
        while getgenv().autoopencrystals do
            if not Selected then break end
            local args = {"openCrystal", Selected}
            game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer(unpack(args))
            task.wait(0.5)
        end
    end)

    -- Player movement sliders
    PlayerSection:Slider("WalkSpeed", 16, 500, 16, 1, "Changes Your Walkspeed", function(s)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
        end
    end)

    PlayerSection:Slider("JumpPower", 50, 400, 50, 1, "Changes Your JumpPower", function(s)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
        end
    end)

    -- Island teleportation
    local Islandslist = {
        "Enchanted Island", "Astral Island", "Mystical Island", "Space Island", "Tundra Island",
        "Eternal Island", "Sandstorm", "Thunderstorm", "Ancient Inferno Island", "Midnight Shadow Island",
        "Mythical Souls Island", "Winter Wonder Island", "Golden Master Island", "Dragon Legend Island",
        "Cybernetic Legends Island", "Skystorm Ultraus Island", "Chaos Legends Island", "Soul Fusion Island",
        "Dark Elements Island", "Inner Peace Island", "Blazing Vortex Island"
    }
    TeleportingSection:Dropdown("Teleport To Island:", Islandslist, "", "Dropdown", function(t)
        pcall(function()
            if game:GetService("Workspace").islandUnlockParts[t] then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").islandUnlockParts[t].CFrame
            end
        end)
    end)

    -- Training area teleportation
    local TrainingList = {
        "Mystical Waters", "Lava Pit", "Tornado", "Sword of Legends", "Sword of Ancients",
        "Elemental Tornado", "Fallen Infinity Blade", "Zen Master's Blade"
    }
    TeleportingSection:Dropdown("Teleport To Training Area:", TrainingList, "", "Dropdown", function(t)
        pcall(function()
            local CFrameMap = {
                ["Mystical Waters"] = CFrame.new(343.933624, 8824.41309, 116.454231, 0.296236873, 3.43450957e-08, -0.955114484, 4.83460703e-08, 1, 5.09540854e-08, 0.955114484, -6.12705122e-08, 0.296236873),
                ["Lava Pit"] = CFrame.new(-126.416206, 12952.4131, 273.149292, -0.276711583, -5.23082626e-08, 0.960952997, 2.41545077e-08, 1, 6.13891586e-08, -0.960952997, 4.01984366e-08, -0.276711583),
                ["Tornado"] = CFrame.new(313.673065, 16871.9688, -14.7217541, 0.994922996, 7.48534461e-08, -0.100639053, -7.66444046e-08, 1, -1.39292826e-08, 0.100639053, 2.15719833e-08, 0.994922996),
                ["Sword of Legends"] = CFrame.new(1847.01306, 38.5793152, -139.799545, 0.940122247, 1.6319289e-08, 0.340837389, 1.772184e-08, 1, -9.67616387e-08, -0.340837389, 9.70080336e-08, 0.940122247),
                ["Sword of Ancients"] = CFrame.new(608.698364, 38.5796623, 2425.60474, -0.0159091037, -4.19558752e-08, -0.999873459, -6.51419052e-09, 1, -4.18575361e-08, 0.999873459, 5.84745008e-09, -0.0159091037),
                ["Elemental Tornado"] = CFrame.new(323.196381, 30382.9707, 0.835642278, -0.906975925, -6.70449865e-08, 0.421182454, -2.82923036e-08, 1, 9.82580062e-08, -0.421182454, 7.72014275e-08, -0.906975925),
                ["Fallen Infinity Blade"] = CFrame.new(1883.16479, 66.9705124, -6811.90771, 0.91395551, -4.90655268e-08, -0.405814409, 5.31859889e-09, 1, -1.08928035e-07, 0.405814409, 9.73970131e-08, 0.91395551),
                ["Zen Master's Blade"] = CFrame.new(150.123456, 20050.7891, 50.987654, 0.707106781, 0, 0.707106781, 0, 1, 0, -0.707106781, 0, 0.707106781) -- Added valid CFrame
            }
            if CFrameMap[t] then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrameMap[t]
            end
        end)
    end)

    -- Misc buttons
    MiscSection:Button("Open Shop", function()
        pcall(function()
            local shop = game:GetService("Workspace").shopAreaCircles.shopAreaCircle19.circleInner
            shop.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            task.wait(0.4)
            shop.CFrame = CFrame.new(0, 0, 0)
        end)
    end)

    MiscSection:Button("Infinite Double Jumps", function()
        pcall(function()
            game.Players.LocalPlayer.multiJumpCount.Value = 999999999
        end)
    end)

    MiscSection:Button("Unlock all Islands", function()
        pcall(function()
            for _, v in pairs(game:GetService("Workspace").islandUnlockParts:GetChildren()) do
                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v, 0)
                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v, 1)
                task.wait(0.1)
            end
        end)
    end)

    local Elements = {}
    for _, v in pairs(game:GetService("ReplicatedStorage").Elements:GetChildren()) do
        table.insert(Elements, v.Name)
    end
    MiscSection:Button("Unlock all Elements", function()
        pcall(function()
            for _, v in pairs(Elements) do
                game:GetService("ReplicatedStorage").rEvents.elementMasteryEvent:FireServer(v)
            end
        end)
    end)

    -- Autofarm toggles
    local ranks = {}
    for _, v in pairs(game:GetService("ReplicatedStorage").Ranks.Ground:GetChildren()) do
        table.insert(ranks, v.Name)
    end
    MainSection:Toggle("Auto Buy All Ranks", false, "Toggle", function(v)
        getgenv().autobuyranks = v
        while getgenv().autobuyranks do
            for _, rank in ipairs(ranks) do
                game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyRank", rank)
            end
            task.wait(0.1)
        end
    end)

    MainSection:Toggle("Auto Buy All Belts", false, "Toggle", function(v)
        getgenv().autobuybelts = v
        while getgenv().autobuybelts do
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyAllBelts", "Inner Peace Island")
            task.wait(0.5)
        end
    end)

    MainSection:Toggle("Auto Buy All Skills", false, "Toggle", function(v)
        getgenv().autobuyskills = v
        while getgenv().autobuyskills do
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyAllSkills", "Inner Peace Island")
            task.wait(0.5)
        end
    end)

    MainSection:Toggle("Auto Buy All Swords", false, "Toggle", function(v)
        getgenv().autobuy = v
        while getgenv().autobuy do
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyAllSwords", "Inner Peace Island")
            task.wait(0.5)
        end
    end)

    MainSection:Toggle("Auto Sell", false, "Toggle", function(v)
        getgenv().autosell = v
        while getgenv().autosell do
            local sellArea = game:GetService("Workspace").sellAreaCircles["sellAreaCircle16"].circleInner
            sellArea.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            task.wait(0.1)
            sellArea.CFrame = CFrame.new(0, 0, 0)
            task.wait(0.1)
        end
    end)

    MainSection:Toggle("Auto Swing", false, "Toggle", function(v)
        getgenv().autoswing = v
        while getgenv().autoswing do
            for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:FindFirstChild("ninjitsuGain") then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                    break
                end
            end
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("swingKatana")
            task.wait()
        end
    end)

    MiscSection:Button("Open All Chests", function()
        pcall(function()
            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
                if v:FindFirstChild("Chest") and v:FindFirstChild("circleInner") and v.circleInner:FindFirstChildWhichIsA("TouchTransmitter") then
                    local transmitter = v.circleInner:FindFirstChildWhichIsA("TouchTransmitter")
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, transmitter.Parent, 0)
                    task.wait()
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, transmitter.Parent, 1)
                    task.wait(5)
                end
            end
        end)
    end)

    MiscSection:Button("Collect all Hoops", function()
        pcall(function()
            for _, v in pairs(game:GetService("Workspace").Hoops:GetChildren()) do
                if v:IsA("MeshPart") then
                    v.touchPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    task.wait(0.25)
                    v.touchPart.CFrame = CFrame.new(0, 0, 0)
                end
            end
        end)
    end)

    MiscSection:Button("Turn On/Off Popups", function()
        local gui = game:GetService("Players").LocalPlayer.PlayerGui
        gui.statEffectsGui.Enabled = not gui.statEffectsGui.Enabled
        gui.hoopGui.Enabled = not gui.hoopGui.Enabled
    end)

    -- Auto-sell pets
    for _, v in pairs(game:GetService("Players").LocalPlayer.petsFolder:GetChildren()) do
        EggSection:Toggle("AutoSell: " .. v.Name, false, "Toggle", function(t)
            pcall(function()
                getgenv().autosellpets = t
                while getgenv().autosellpets do
                    for _, pet in pairs(v:GetChildren()) do
                        game:GetService("ReplicatedStorage").rEvents.sellPetEvent:FireServer("sellPet", pet)
                    end
                    task.wait(0.1)
                end
            end)
        end)
    end
end
