-- ✅ โหลด Library (ไม่ต้องเปลี่ยน)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

getgenv().awin = false
getgenv().aclick = false

function awin()
    spawn(function()
        while getgenv().awin do
            wait()
            for _, v in pairs(game:GetService("Workspace").Environment:GetDescendants()) do
                if v.Name == "TouchInterest" then
                    if not getgenv().awin then break end
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 0)
                    wait(0.1)
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 1)
                end
            end
        end
    end)
end

function aclick()
    spawn(function()
        local click = nil
        for i, v in pairs(getgc()) do
            if type(v) == 'function' then
                if debug.getinfo(v).name == "Click" then
                    click = v
                end
            end
        end
        while getgenv().aclick do
            wait()
            for i = 1, 1000 do
                if click then
                    pcall(click, UDim2.new(0,0,0), 1)
                else
                    warn("Click function not found!")
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

-- ✅ ตรวจสอบว่า Window มี method NewTab หรือไม่
if not Window.NewTab then
    warn("Window does not have 'NewTab' method! Structure might be different.")
    print("Available methods in Window:")
    for k, v in pairs(Window) do
        if type(v) == "function" then
            print("  - " .. k)
        end
    end
    return
end

-- ✅ สร้าง Tab และ Section ด้วย method ที่ถูกต้อง
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

-- ✅ ตรวจสอบว่า Section มี method NewLabel หรือไม่
if not Credit.NewLabel then
    warn("Credit section does not have 'NewLabel' method!")
    print("Available methods in Credit section:")
    for k, v in pairs(Credit) do
        if type(v) == "function" then
            print("  - " .. k)
        end
    end
    -- ลองใช้ NewTitle แทน
    Credit:NewTitle({
        Title = "Made By lphisv5",
    })
else
    Credit:NewLabel({
        Title = "Made By lphisv5",
    })
end

-- ✅ ตรวจสอบว่า Section มี method NewButton หรือไม่
if not Discord.NewButton then
    warn("Discord section does not have 'NewButton' method!")
    print("Available methods in Discord section:")
    for k, v in pairs(Discord) do
        if type(v) == "function" then
            print("  - " .. k)
        end
    end
    -- ลองใช้ NewTitle แทน
    Discord:NewTitle({
        Title = "Copy Discord Link",
        Callback = function()
            setclipboard("https://discord.gg/DfVuhsZb")
        end,
    })
else
    Discord:NewButton({
        Title = "Copy Discord Link",
        Description = "Copy the Arcane Discord URL",
        Callback = function()
            setclipboard("https://discord.gg/DfVuhsZb")
        end,
    })
end

-- ✅ สร้าง Toggle ด้วย method ที่ถูกต้อง
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
