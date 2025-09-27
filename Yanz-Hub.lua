local GameScripts = {
    [12331842898] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/+1BlocksEverySecond.lua",
    [121864768012064] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Fickit.lua"
}

local url = GameScripts[game.PlaceId]
if url then
    loadstring(game:HttpGet(url))()
else
    warn("Game not supported")
end
