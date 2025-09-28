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

-- ✅ ใช้ Library.new() แทน NothingLibrary.new()
local ok_window, res_window = pcall(function()
    Window = Library.new({
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

-- ✅ สร้าง Tab และ Section
local Farming = Window:Tab({
    Title = "Main",
})

local Credits = Window:Tab({
    Title = "Credits",
})

local AutoFarm = Farming:Section({
    Title = "Main",
})

local Credit = Credits:Section({
    Title = "Credit:",
})

local Discord = Credits:Section({
    Title = "Discord",
})

AutoFarm:Toggle({
    Title = "Auto Click",
    Description = "Auto CLick for you",
    Callback = function(bool)
        getgenv().aclick = bool
        if bool then
            aclick()
        end
    end,
})

AutoFarm:Toggle({
    Title = "Auto Win",
    Description = "Auto win",
    Callback = function(bool)
        getgenv().awin = bool
        if bool then
            awin()
        end
    end,
})

Credit:Label({
    Title = "Made By lphisv5",
})

Discord:Button({
    Title = "Copy Discord Link",
    Description = "Copy the Arcane Discord URL",
    Callback = function()
        setclipboard("https://discord.gg/DfVuhsZb")
    end,
})
