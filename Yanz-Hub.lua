local GameScripts = {
    [12331842898] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/+1BlocksEverySecond.lua",
    [121864768012064] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Fickit.lua",
    [9285238704] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Race-Clicker.lua",
    [127742093697776] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/PlantsVsBrainrots.lua",
    [6516141723] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Doors.lua",
    [3956818381] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Ninja-Legends.lua"
}

local url = GameScripts[game.PlaceId]
if url then
    loadstring(game:HttpGet(url))()
else
    warn("Game not supported")
end
