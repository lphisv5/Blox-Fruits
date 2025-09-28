local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

getgenv().awin = false
getgenv().aclick = false
getgenv().wins_count = 0
getgenv().is_racing = false

function awin()
    spawn(function()
        print("Auto Win started")
        while getgenv().awin do
            wait(0.1)
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "TouchInterest" then
                    if not getgenv().awin then break end
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 0)
                    wait(0.1)
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 1)
                end
            end
        end
        print("Auto Win stopped")
    end)
end

function aclick()
    spawn(function()
        print("=== Searching for 'Click' function ===")
        local click = nil
        for i, v in pairs(getgc()) do
            if type(v) == 'function' then
                local info = debug.getinfo(v)
                if info.name and info.name:lower():find("click") then
                    print("Found function with 'click' in name:", info.name)
                    if info.name == "Click" then
                        click = v
                        print("Found exact 'Click' function!")
                        break
                    end
                end
            end
        end
        if not click then
            warn("Click function not found!")
            return
        end
        print("Auto Click started")
        while getgenv().aclick do
            wait(0.01)
            pcall(click)
        end
        print("Auto Click stopped")
    end)
end

-- ฟังก์ชันใหม่สำหรับการ race mode
function race_mode()
    spawn(function()
        getgenv().is_racing = true
        print("Race mode started")
        
        while getgenv().is_racing do
            -- รอให้เกมเริ่ม (รอ 10 วินาที)
            wait(10)
            
            -- คลิกแบบบ้าคลั่ง 20 วินาที
            for i = 1, 20 do
                if not getgenv().is_racing then break end
                -- ลองหาและคลิก "CLICK" ที่อยู่ในเกม
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Click" then
                        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 0)
                        wait(0.1)
                        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 1)
                    end
                end
                wait(1)
            end
            
            -- รอ 3 วินาที
            wait(3)
            
            -- TP ไปหมายเลขต่อเนื่อง
            local race_number = 1
            while getgenv().is_racing do
                -- หา object ที่มีหมายเลข
                local found_target = false
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Number" .. race_number then
                        -- TP ไปยังตำแหน่งของ object นั้น
                        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                        end
                        found_target = true
                        break
                    end
                end
                
                if not found_target then
                    race_number = race_number + 1
                    if race_number > 100 then -- ถ้าไม่เจอเลขมากกว่า 100 ให้ reset
                        race_number = 1
                    end
                else
                    race_number = race_number + 1
                end
                
                -- ตรวจสอบว่ามีคำว่า "Wins" หรือไม่
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text:lower():find("wins") then
                        getgenv().wins_count = getgenv().wins_count + 1
                        print("Wins count:", getgenv().wins_count)
                        break
                    end
                end
                
                wait(0.5) -- รอเล็กน้อยก่อนไปหมายเลขถัดไป
            end
        end
    end)
end

-- ฟังก์ชันตรวจสอบสถานะ
function check_status()
    spawn(function()
        while true do
            wait(1)
            -- ตรวจสอบคำว่า "Wins" ในเกม
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("TextLabel") and v.Text:lower():find("wins") then
                    getgenv().wins_count = getgenv().wins_count + 1
                    print("Wins count:", getgenv().wins_count)
                    break
                end
            end
        end
    end)
end

-- ✅ สร้าง Window
local ok_window, res_window = pcall(function()
    return Library.new({
        Title = "YANZ HUB | V0.4.9",
        SubTitle = "By lphisv5 | Game : Race Clicker",
        TabSize = 180,
        Keybind = Enum.KeyCode.RightControl
    })
end)

if not ok_window then
    warn("Failed to create window: " .. tostring(res_window))
    return
end

local Window = res_window

-- ✅ สร้าง Tab และ Section
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

-- ✅ สร้าง Toggle และ Button ด้วย method ที่ถูกต้อง
AutoFarm:NewToggle({
    Title = "Auto Click",
    Description = "Auto CLick for you",
    Default = getgenv().aclick or false,
    Callback = function(bool)
        getgenv().aclick = bool
        if bool then
            aclick()
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
            awin()
        end
    end,
})

-- เพิ่ม toggle สำหรับ race mode
AutoFarm:NewToggle({
    Title = "Race Mode",
    Description = "Auto race mode",
    Default = getgenv().is_racing or false,
    Callback = function(bool)
        getgenv().is_racing = bool
        if bool then
            race_mode()
        end
    end,
})

-- สร้าง status label
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

-- สร้าง timer สำหรับอัปเดต status
spawn(function()
    while true do
        wait(1)
        -- ลองหาข้อมูลจาก leaderboard ในเกม
        local rebirths = 0
        local wins = 0
        local highscore = 0
        local topspeed = 0
        
        -- ตัวอย่าง: หาข้อมูลจาก GUI ของเกม
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("TextLabel") then
                if v.Text:lower():find("rebirths") then
                    local num = tonumber(v.Text:match("%d+"))
                    if num then
                        rebirths = num
                    end
                elseif v.Text:lower():find("wins") then
                    local num = tonumber(v.Text:match("%d+"))
                    if num then
                        wins = num
                    end
                elseif v.Text:lower():find("highscore") then
                    local num = tonumber(v.Text:match("%d+"))
                    if num then
                        highscore = num
                    end
                elseif v.Text:lower():find("topspeed") then
                    local num = tonumber(v.Text:match("%d+"))
                    if num then
                        topspeed = num
                    end
                end
            end
        end
        
        -- อัปเดต label
        if RebirthsLabel and RebirthsLabel.SetTitle then
            RebirthsLabel:SetTitle("😇 Rebirths: " .. rebirths)
        end
        
        if WinsLabel and WinsLabel.SetTitle then
            WinsLabel:SetTitle("🏁 Wins: " .. wins)
        end
        
        if HighscoreLabel and HighscoreLabel.SetTitle then
            HighscoreLabel:SetTitle("⭐ Highscore: " .. highscore)
        end
        
        if TopSpeedLabel and TopSpeedLabel.SetTitle then
            TopSpeedLabel:SetTitle("🏃 TopSpeed: " .. topspeed)
        end
    end
end)

-- ✅ ใช้ NewTitle แทน NewLabel
Credit:NewTitle({
    Title = "Made By lphisv5",
})

Discord:NewButton({
    Title = "Copy Discord Link",
    Description = "Copy the Arcane Discord URL",
    Callback = function()
        setclipboard("https://discord.gg/DfVuhsZb")
    end,
})

-- เริ่มตรวจสอบสถานะ
check_status()
