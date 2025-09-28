-- YANZ HUB | Robust version
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Global toggles / state (persist across script re-runs because using getgenv)
getgenv().awin = getgenv().awin or false
getgenv().aclick = getgenv().aclick or false
getgenv().wins_count = getgenv().wins_count or 0
getgenv().is_racing = getgenv().is_racing or false

-- internal running flags to avoid launching duplicate threads
getgenv().awin_running = getgenv().awin_running or false
getgenv().aclick_running = getgenv().aclick_running or false
getgenv().race_running = getgenv().race_running or false
getgenv().status_running = getgenv().status_running or false

-- cache for click function (to avoid repeated expensive getgc scans)
getgenv().cached_click_func = getgenv().cached_click_func or nil

-- Helper: safe get HRP
local function get_hrp()
    local pl = Players.LocalPlayer
    if not pl then return nil end
    local char = pl.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- Helper: safe firetouchinterest wrapper
local function safe_fire_touch(part)
    if not part or not part:IsA("BasePart") then return false end
    local hrp = get_hrp()
    if not hrp then return false end
    -- protect against errors
    pcall(function()
        firetouchinterest(hrp, part, 0)
        task.wait(0.05) -- small delay for touch to register
        firetouchinterest(hrp, part, 1)
    end)
    return true
end

-- Find 'click' function via getgc (protected)
local function find_click_function()
    if getgenv().cached_click_func then
        return getgenv().cached_click_func
    end

    local ok, gc = pcall(getgc)
    if not ok or type(gc) ~= "table" then return nil end

    for _, v in pairs(gc) do
        if type(v) == "function" then
            local ok2, info = pcall(debug.getinfo, v)
            if ok2 and info and info.name then
                local nm = tostring(info.name):lower()
                if nm:find("click") then
                    getgenv().cached_click_func = v
                    return v
                end
            end
        end
    end
    return nil
end

-- AWin (auto-touch) - prevents duplicate threads
function start_awin()
    if getgenv().awin_running then
        warn("[start_awin] already running")
        return
    end
    getgenv().awin_running = true
    task.spawn(function()
        print("Auto Win started")
        while getgenv().awin do
            -- getdescendants once per iteration (avoid constant API thrash)
            local descendants = Workspace:GetDescendants()
            for _, v in pairs(descendants) do
                if not getgenv().awin then break end
                -- check name then parent type
                if v.Name == "TouchInterest" then
                    local parent = v.Parent
                    if parent and parent:IsA("BasePart") then
                        safe_fire_touch(parent)
                        -- tiny throttle to avoid spamming too fast
                        task.wait(0.06)
                    end
                end
            end
            -- small pause before scanning again
            task.wait(0.15)
        end
        getgenv().awin_running = false
        print("Auto Win stopped")
    end)
end

-- AClick - find and repeatedly call click function
function start_aclick()
    if getgenv().aclick_running then
        warn("[start_aclick] already running")
        return
    end
    getgenv().aclick_running = true
    task.spawn(function()
        print("=== Searching for 'click' function ===")
        local click = find_click_function()
        if not click then
            warn("Click function not found!")
            getgenv().aclick_running = false
            return
        end

        print("Auto Click started")
        -- loop while toggle is true
        while getgenv().aclick do
            -- pcall the click call to avoid breaking the loop on errors
            local ok, err = pcall(click)
            if not ok then
                warn("Error calling click function:", err)
                -- optionally break or continue; we'll continue but with backoff
                task.wait(0.2)
            else
                -- tiny throttle; use task.wait for better precision
                task.wait(0.03)
            end
        end

        getgenv().aclick_running = false
        print("Auto Click stopped")
    end)
end

-- Race mode (auto sequence + teleport)
function start_race_mode()
    if getgenv().race_running then
        warn("[start_race_mode] already running")
        return
    end
    getgenv().race_running = true
    task.spawn(function()
        print("Race mode started")
        -- wait a bit for character / game readiness
        local waited = 0
        while not get_hrp() and waited < 12 and getgenv().is_racing do
            task.wait(0.5)
            waited = waited + 0.5
        end

        while getgenv().is_racing do
            -- aggressive click phase (20 cycles)
            for i = 1, 20 do
                if not getgenv().is_racing then break end
                -- scan for "Click" parts (throttle GetDescendants)
                for _, v in pairs(Workspace:GetDescendants()) do
                    if not getgenv().is_racing then break end
                    if v.Name == "Click" then
                        local parent = v.Parent
                        if parent and parent:IsA("BasePart") then
                            safe_fire_touch(parent)
                        end
                    end
                end
                task.wait(1)
            end

            task.wait(3) -- cooldown

            -- teleport through numbered targets
            local race_number = 1
            while getgenv().is_racing do
                if not getgenv().is_racing then break end
                local found_target = false
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Number" .. race_number and v:IsA("BasePart") then
                        local hrp = get_hrp()
                        if hrp then
                            pcall(function()
                                -- offset Y to avoid intersection
                                hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                            end)
                        end
                        found_target = true
                        break
                    end
                end

                if not found_target then
                    race_number = race_number + 1
                    if race_number > 100 then
                        race_number = 1 -- reset if nothing found
                        task.wait(0.5)
                    end
                else
                    race_number = race_number + 1
                end

                task.wait(0.45)
            end
        end

        getgenv().race_running = false
        print("Race mode stopped")
    end)
end

-- Status checker (update wins_count based on GUI text)
function check_status()
    if getgenv().status_running then
        warn("[check_status] already running")
        return
    end
    getgenv().status_running = true
    task.spawn(function()
        while true do
            -- if you want to be able to stop status loop later, add a stop flag and check it here
            task.wait(1)
            for _, v in pairs(Workspace:GetDescendants()) do
                -- protect against nil or non-string Text
                if v:IsA("TextLabel") and v.Text then
                    local txt = tostring(v.Text):lower()
                    if txt:find("wins") then
                        -- remove non-digits (handles 1,234 etc.)
                        local digits = tostring(v.Text):gsub("[^%d]", "")
                        local num = tonumber(digits) or 0
                        getgenv().wins_count = num
                        -- print for debug; comment out in production
                        print("Wins count updated:", num)
                        break
                    end
                end
            end
        end
    end)
end

-- ---------- UI Creation (same structure) ----------
local ok_window, res_window = pcall(function()
    return Library.new({
        Title = "YANZ HUB | V0.5.0",
        SubTitle = "By lphisv5 | Game : 🏆 Race Clicker",
        TabSize = 180,
        Keybind = Enum.KeyCode.RightControl
    })
end)

if not ok_window then
    warn("Failed to create window: " .. tostring(res_window))
    return
end

local Window = res_window

local Farming = Window:NewTab({
    Title = "Main",
    Description = "Main Features",
    Icon = "rbxassetid://7733960981"
})

local StatusTab = Window:NewTab({
    Title = "Status",
    Description = "Current Status",
    Icon = "rbxassetid://7733960981"
})

local Credits = Window:NewTab({
    Title = "Credits",
    Description = "Credit Information",
    Icon = "rbxassetid://7733960981"
})

local AutoFarm = Farming:NewSection({
    Title = "Main",
    Icon = "rbxassetid://7733916988",
    Position = "Left"
})

local StatusSection = StatusTab:NewSection({
    Title = "Status Info",
    Icon = "rbxassetid://7733916988",
    Position = "Left"
})

local Credit = Credits:NewSection({
    Title = "Credit:",
    Icon = "rbxassetid://7733916988",
    Position = "Left"
})

local Discord = Credits:NewSection({
    Title = "Discord",
    Icon = "rbxassetid://7743869054",
    Position = "Right"
})

-- Toggles
AutoFarm:NewToggle({
    Title = "Auto Click",
    Description = "Auto Click for you",
    Default = getgenv().aclick or false,
    Callback = function(bool)
        getgenv().aclick = bool
        if bool then
            start_aclick()
        end
    end,
})

AutoFarm:NewToggle({
    Title = "Auto Win",
    Description = "Auto win",
    Default = getgenv().awin or false,
    Callback = function(bool)
        getgenv().awin = bool
        if bool then
            start_awin()
        end
    end,
})

AutoFarm:NewToggle({
    Title = "Race Mode",
    Description = "Auto race mode",
    Default = getgenv().is_racing or false,
    Callback = function(bool)
        getgenv().is_racing = bool
        if bool then
            start_race_mode()
        end
    end,
})

-- Status labels
local RebirthsLabel = StatusSection:NewTitle({
    Title = "😇 Rebirths: Loading..."
})

local WinsLabel = StatusSection:NewTitle({
    Title = "🏁 Wins: Loading..."
})

local HighscoreLabel = StatusSection:NewTitle({
    Title = "⭐ Highscore: Loading..."
})

local TopSpeedLabel = StatusSection:NewTitle({
    Title = "🏃 TopSpeed: Loading..."
})

-- Periodic UI updater (updates the UI labels; robust call with pcall)
task.spawn(function()
    while true do
        task.wait(1)
        -- Scan GUI texts once
        local rebirths = 0
        local wins = 0
        local highscore = 0
        local topspeed = 0

        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text then
                local txt = tostring(v.Text):lower()
                if txt:find("rebirths") then
                    local digits = tostring(v.Text):gsub("[^%d]", "")
                    rebirths = tonumber(digits) or rebirths
                elseif txt:find("wins") then
                    local digits = tostring(v.Text):gsub("[^%d]", "")
                    wins = tonumber(digits) or wins
                elseif txt:find("highscore") then
                    local digits = tostring(v.Text):gsub("[^%d]", "")
                    highscore = tonumber(digits) or highscore
                elseif txt:find("topspeed") then
                    local digits = tostring(v.Text):gsub("[^%d]", "")
                    topspeed = tonumber(digits) or topspeed
                end
            end
        end

        -- Update UI safely (pcall to avoid errors if API differs)
        pcall(function() RebirthsLabel:SetTitle("😇 Rebirths: " .. rebirths) end)
        pcall(function() WinsLabel:SetTitle("🏁 Wins: " .. wins) end)
        pcall(function() HighscoreLabel:SetTitle("⭐ Highscore: " .. highscore) end)
        pcall(function() TopSpeedLabel:SetTitle("🏃 TopSpeed: " .. topspeed) end)
    end
end)

-- Credits / Discord
Credit:NewTitle({ Title = "Created by lphisv5" })
Credit:NewTitle({ Title = "Created by id2_lphisv5" })

Discord:NewButton({
    Title = "Join Discord",
    Description = "https://discord.gg/DfVuhsZb",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/DfVuhsZb") end)
    end,
})

-- Start status checker (if not already)
check_status()
