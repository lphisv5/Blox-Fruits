-- =====================
-- YANZ HUB | Advanced V1.0
-- =====================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

-- =====================
-- Global variables
-- =====================
getgenv().awin = false
getgenv().aclick = false
getgenv().is_racing = false
getgenv().wins_count = 0
getgenv().rebirths_count = 0
getgenv().highscore_count = 0
getgenv().topspeed_count = 0
getgenv().hub_running = false

-- =====================
-- Services
-- =====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =====================
-- Helpers
-- =====================
local function get_hrp()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function find_basepart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    local ok, bp = pcall(function() return inst:FindFirstChildWhichIsA("BasePart", true) end)
    if ok and bp then return bp end
    local cur = inst
    while cur and cur.Parent do
        cur = cur.Parent
        if cur:IsA("BasePart") then return cur end
        local ok2, bp2 = pcall(function() return cur:FindFirstChildWhichIsA("BasePart") end)
        if ok2 and bp2 then return bp2 end
    end
    return nil
end

local function safe_touch(part)
    if not part then return end
    local hrp = get_hrp()
    if hrp then
        pcall(function()
            firetouchinterest(hrp, part, 0)
            task.wait(0.06)
            firetouchinterest(hrp, part, 1)
        end)
    end
end

-- =====================
-- Hub Main Thread
-- =====================
local function hub_loop()
    if getgenv().hub_running then return end
    getgenv().hub_running = true

    local click_func = nil
    -- detect click function
    task.spawn(function()
        local ok, gc = pcall(getgc)
        if ok and type(gc) == "table" then
            for _, f in pairs(gc) do
                if type(f) == "function" then
                    local info = pcall(debug.getinfo, f)
                    if info and info.name and tostring(info.name):lower():find("click") then
                        click_func = f
                        print("[Hub] Click function found via getgc:", info.name)
                        break
                    end
                end
            end
        end
        -- fallback RemoteEvent / ClickDetector
        if not click_func then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ClickDetector") then
                    click_func = function() pcall(fireclickdetector, obj) end
                    print("[Hub] Using ClickDetector:", obj:GetFullName())
                    break
                end
            end
        end
    end)

    -- main loop
    task.spawn(function()
        local race_number = 1
        while true do
            task.wait(0.03)

            -- Auto Click
            if getgenv().aclick and click_func then
                pcall(click_func)
            end

            -- Auto Win
            if getgenv().awin then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if tostring(v.Name):lower():find("touchinterest") then
                        local part = find_basepart(v.Parent)
                        if part then safe_touch(part) end
                    end
                    if v:IsA("TextLabel") and v.Text and tostring(v.Text):lower():find("click") then
                        local part = find_basepart(v) or find_basepart(v.Parent)
                        if part then safe_touch(part) end
                    end
                end
            end

            -- Race Mode
            if getgenv().is_racing then
                -- TP to Number
                local found = false
                for _, v in pairs(Workspace:GetDescendants()) do
                    if tostring(v.Name) == ("Number" .. race_number) then
                        local part = find_basepart(v)
                        if part then
                            local hrp = get_hrp()
                            if hrp then hrp.CFrame = part.CFrame + Vector3.new(0,3,0) end
                            found = true
                            break
                        end
                    end
                end
                race_number = found and race_number+1 or race_number+1
                if race_number > 100 then race_number = 1 end
            end
        end
    end)
end

-- =====================
-- Status Updater
-- =====================
local function update_status()
    task.spawn(function()
        while true do
            task.wait(1)
            local rebirths, wins, highscore, topspeed = 0,0,0,0
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("TextLabel") and v.Text then
                    local t = v.Text:lower()
                    local n = tonumber(v.Text:match("%d+"))
                    if n then
                        if t:find("rebirths") then rebirths = n
                        elseif t:find("wins") then wins = n
                        elseif t:find("highscore") then highscore = n
                        elseif t:find("topspeed") then topspeed = n
                        end
                    end
                end
            end
            getgenv().rebirths_count = rebirths
            getgenv().wins_count = wins
            getgenv().highscore_count = highscore
            getgenv().topspeed_count = topspeed
        end
    end)
end

-- =====================
-- GUI Setup
-- =====================
local ok_window, res_window = pcall(function()
    return Library.new({
        Title = "YANZ HUB | V0.5.0",
        SubTitle = "By lphisv5 | Game: 🏆 Race Clicker",
        TabSize = 180,
        Keybind = Enum.KeyCode.RightControl
    })
end)
if not ok_window then
    warn("Failed to create window:", res_window)
    return
end
local Window = res_window

local Farming = Window:NewTab({Title="Main", Description="Main Features", Icon="rbxassetid://7733960981"})
local StatusTab = Window:NewTab({Title="Status", Description="Current Status", Icon="rbxassetid://7733960981"})
local Credits = Window:NewTab({Title="Credits", Description="Credit Information", Icon="rbxassetid://7733960981"})

local AutoFarm = Farming:NewSection({Title="Main", Icon="rbxassetid://7733916988", Position="Left"})
local StatusSection = StatusTab:NewSection({Title="Status Info", Icon="rbxassetid://7733916988", Position="Left"})
local Credit = Credits:NewSection({Title="Credit:", Icon="rbxassetid://7733916988", Position="Left"})
local Discord = Credits:NewSection({Title="Discord", Icon="rbxassetid://7743869054", Position="Right"})

-- =====================
-- Status Labels
-- =====================
local RebirthsLabel = StatusSection:NewTitle({Title="😇 Rebirths: 0"})
local WinsLabel = StatusSection:NewTitle({Title="🏁 Wins: 0"})
local HighscoreLabel = StatusSection:NewTitle({Title="⭐ Highscore: 0"})
local TopSpeedLabel = StatusSection:NewTitle({Title="🏃 TopSpeed: 0"})

task.spawn(function()
    while true do
        task.wait(0.5)
        if RebirthsLabel and RebirthsLabel.SetTitle then RebirthsLabel:SetTitle("😇 Rebirths: "..getgenv().rebirths_count) end
        if WinsLabel and WinsLabel.SetTitle then WinsLabel:SetTitle("🏁 Wins: "..getgenv().wins_count) end
        if HighscoreLabel and HighscoreLabel.SetTitle then HighscoreLabel:SetTitle("⭐ Highscore: "..getgenv().highscore_count) end
        if TopSpeedLabel and TopSpeedLabel.SetTitle then TopSpeedLabel:SetTitle("🏃 TopSpeed: "..getgenv().topspeed_count) end
    end
end)

-- =====================
-- Toggles
-- =====================
AutoFarm:NewToggle({
    Title="Auto Click",
    Description="Auto Click for you",
    Default=false,
    Callback=function(val)
        getgenv().aclick = val
    end
})
AutoFarm:NewToggle({
    Title="Auto Win",
    Description="Auto Win",
    Default=false,
    Callback=function(val)
        getgenv().awin = val
    end
})
AutoFarm:NewToggle({
    Title="Race Mode",
    Description="Auto Race Mode",
    Default=false,
    Callback=function(val)
        getgenv().is_racing = val
    end
})

-- =====================
-- Credits & Discord
-- =====================
Credit:NewTitle({Title="Created by lphisv5"})
Credit:NewTitle({Title="Created by id2_lphisv5"})
Discord:NewButton({
    Title="Join Discord",
    Description="https://discord.gg/DfVuhsZb",
    Callback=function() setclipboard("https://discord.gg/DfVuhsZb") end
})

-- =====================
-- Start Hub
-- =====================
hub_loop()
update_status()
