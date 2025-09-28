local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

local WindowTable = Library.new({
    Title = "YANZ HUB",
    Description = "By lphisv5 | Game : Ninja Legends",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = "http://www.roblox.com/asset/?id=18810965406",
    Size = UDim2.new(0.100000001, 445, 0.100000001, 315)
})

local AutoFarmSection = WindowTable:NewSection({
    Position = "Left",
    Title = "Auto Farm",
    Icon = "rbxassetid://4483345998"
})

local autoSwingEnabled = false
local autoSellEnabled = false
local autoRankEnabled = false

-- Auto Swing Toggle
AutoFarmSection:NewToggle({
    Title = "Auto Swing",
    Default = false,
    Callback = function(Value)
        autoSwingEnabled = Value
        if autoSwingEnabled then
            spawn(function()
                while autoSwingEnabled do
                    task.wait(0.1)
                    local args = { [1] = "swingKatana" }
                    -- Safely fire the remote event
                    local ninjaEvent = game.Players.LocalPlayer:WaitForChild("ninjaEvent", 10)
                    if ninjaEvent then
                        ninjaEvent:FireServer(unpack(args))
                    else
                        warn("ninjaEvent RemoteEvent not found!")
                    end
                end
            end)
        end
    end
})

-- Auto Sell Toggle
local position1 = Vector3.new(99, 91246, 111)
local position2 = Vector3.new(76, 91246, 120)
local currentPosition = position1
local teleporting = false

AutoFarmSection:NewToggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(Value)
        autoSellEnabled = Value
        teleporting = Value -- Maintain the old variable name for consistency if other parts rely on it
        if autoSellEnabled then
            spawn(function()
                while autoSellEnabled do
                    task.wait(0.1)
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character:SetPrimaryPartCFrame(CFrame.new(currentPosition))
                        if currentPosition == position1 then
                            currentPosition = position2
                        else
                            currentPosition = position1
                        end
                    else
                        warn("Player character or HumanoidRootPart not found.")
                    end
                end
            end)
        end
    end
})

-- Auto Rank Toggle
local ranks = {
    "Aether Genesis Master Ninja",
    "Ancient Battle Legend",
    "Ancient Battle Master",
    "Apprentice",
    "Assassin",
    "Awakened Scythe Legend",
    "Awakened Scythemaster",
    "Chaos Legend",
    "Chaos Sensei",
    "Comet Strike Lion",
    "Cybernetic Azure Sensei",
    "Cybernetic Electro Legend",
    "Cybernetic Electro Master",
    "Dark Elements Blademaster",
    "Dark Elements Guardian",
    "Dark Sun Samurai Legend",
    "Dragon Evolution Form I",
    "Dragon Evolution Form II",
    "Dragon Evolution Form III",
    "Dragon Evolution Form IV",
    "Dragon Evolution Form V",
    "Dragon Master",
    "Dragon Warrior",
    "Eclipse Series Soul Master",
    "Elemental Legend",
    "Elite Series Master Legend",
    "Eternity Hunter",
    "Evolved Series Master Ninja",
    "Golden Sun Shuriken Legend",
    "Golden Sun Shuriken Master",
    "Grasshopper",
    "Immortal Assassin",
    "Infinity Legend",
    "Infinity Sensei",
    "Infinity Shadows Master",
    "Legendary Shadow Duelist",
    "Legendary Shadowmaster",
    "Lightning Storm Sensei",
    "Master Elemental Hero",
    "Master Legend Assassin",
    "Master Legend Sensei Hunter",
    "Master Legend Zephyr",
    "Master Ninja",
    "Master Of Elements",
    "Master Of Shadows",
    "Master Sensei",
    "Mythic Shadowmaster",
    "Ninja",
    "Ninja Legend",
    "Rising Shadow Eternal Ninja",
    "Rookie",
    "Samurai",
    "Sensei",
    "Shadow",
    "Shadow Chaos Assassin",
    "Shadow Chaos Legend",
    "Shadow Legend",
    "Shadow Storm Sensei",
    "Skyblade Ninja Master",
    "Skystorm Series Samurai Legend",
    "Starstrike Master Sensei",
    "Ultra Genesis Shadow"
}

AutoFarmSection:NewToggle({
    Title = "Auto Rank",
    Default = false,
    Callback = function(Value)
        autoRankEnabled = Value
        if autoRankEnabled then
            spawn(function()
                while autoRankEnabled do -- Use the state variable to check loop condition
                    task.wait(0.1)
                    for _, rank in ipairs(ranks) do
                        if not autoRankEnabled then break end -- Check again inside the loop
                        local args = { [1] = "buyRank", [2] = rank }
                        local ninjaEvent = game.Players.LocalPlayer:WaitForChild("ninjaEvent", 10)
                        if ninjaEvent then
                            ninjaEvent:FireServer(unpack(args))
                        else
                            warn("ninjaEvent RemoteEvent not found!")
                            break -- Exit the rank buying loop if event is missing
                        end
                        task.wait(0.1) -- Small delay between rank purchases if needed
                    end
                end
            end)
        end
    end
})

-- Unlock Every Islands Button
AutoFarmSection:NewButton({
    Title = "Unlock Every Islands",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            warn("Player character or HumanoidRootPart not found.")
            return
        end

        local positions = {
            Vector3.new(80, 766, -188),
            Vector3.new(-128, 39439, 173),
            Vector3.new(183, 46010, 36),
            Vector3.new(188, 59594, 24),
            Vector3.new(166, 52607, 34),
            Vector3.new(180, 33206, 28),
            Vector3.new(80, 766, -118),
            Vector3.new(233, 2013, 331),
            Vector3.new(165, 4047, 51),
            Vector3.new(186, 5656, 76),
            Vector3.new(189, 9284, 31),
            Vector3.new(135, 17686, 61),
            Vector3.new(171, 28255, 39),
            Vector3.new(139, 13680, 74),
            Vector3.new(108, 24069, 84),
            Vector3.new(175, 39317, 25),
            Vector3.new(226, 66669, 15),
            Vector3.new(197, 70271, 7),
            Vector3.new(121, 74461, 88),
            Vector3.new(115, 79762, 61),
            Vector3.new(102, 83199, 150),
            Vector3.new(133, 87050, 72),
            Vector3.new(161, 91244, 39)
        }

        for _, pos in ipairs(positions) do
            if not autoSellEnabled then -- Example condition to potentially stop teleporting
                character:SetPrimaryPartCFrame(CFrame.new(pos))
                task.wait(0.001) -- Minimal delay
            end
        end
    end
})
