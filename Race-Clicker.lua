local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

getgenv().awin = false
getgenv().aclick = false

function awin()
    spawn(function()
        print("Auto Win started")
        while getgenv().awin do
            wait(0.1) -- เพิ่ม delay เพื่อไม่ให้หนักเกินไป
            for _, v in pairs(workspace:GetDescendants()) do -- ลองเปลี่ยนจาก Environment เป็น workspace
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
                end
            end
        end
        -- ลองหา Click แบบตรงๆ
        for i, v in pairs(getgc()) do
            if type(v) == 'function' then
                if debug.getinfo(v).name == "Click" then
                    click = v
                    print("Found exact 'Click' function!")
                    break
                end
            end
        end
        if not click then
            warn("Click function not found!")
            return
        end
        print("Auto Click started")
        while getgenv().aclick do
            wait(0.01) -- เพิ่ม delay เพื่อไม่ให้หนักเกินไป
            for i = 1, 100 do -- ลดจำนวน loop เพื่อไม่ให้หนักเกินไป
                if click then
                    pcall(click, UDim2.new(0,0,0), 1)
                else
                    warn("Click function disappeared!")
                    break
                end
            end
        end
        print("Auto Click stopped")
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
