local HttpService = game:GetService("HttpService")

local savePath = "YanzHub/keydata.json"

local validKeys = {
   "YANZ-KEY-OQQ4NM968Y6BRGH02T1PM3ENJWU0FVRGGIQWGUMPM1A79WHNAK",
   "YANZ-KEY-P0R2A31BU2YW0TG99YL4Y1OPIJQ5JLUQ8PPRO5CRINBCO4V7IR"
}

local function saveKey(key)
   local data = {
      key = key,
      timestamp = os.time()
   }
   local json = HttpService:JSONEncode(data)
   writefile(savePath, json)
end

local function checkSavedKey()
   if isfile(savePath) then
      local json = readfile(savePath)
      local success, data = pcall(function()
         return HttpService:JSONDecode(json)
      end)
      if success and data.key and table.find(validKeys, data.key) and (os.time() - data.timestamp) < 86400 then
         return true, data.key
      end
   end
   return false
end

local function loadGameScript()
   local GameScripts = {
      [12331842898] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/+1BlocksEverySecond.lua",
      [121864768012064] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Fickit.lua",
      [9285238704] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Race-Clicker.lua",
      [127742093697776] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/PlantsVsBrainrots.lua",
      [6516141723] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Doors.lua",
      [3956818381] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/Ninja-Legends.lua",
      [537413528] = "https://github.com/lphisv5/rbxScript/raw/refs/heads/main/BuildABoat.lua"
   }
   local url = GameScripts[game.PlaceId]
   if not url then
      error("Game not supported")
   end
   loadstring(game:HttpGet(url))()
   return true
end

local valid, savedKey = checkSavedKey()
if valid then
   local success, err = pcall(loadGameScript)
   if not success then
      warn("Load Error: " .. tostring(err))
   end
   return
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Yanz Hub Key System",
   LoadingTitle = "Loading Yanz Hub",
   LoadingSubtitle = "by Yanz",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "YanzHub",
      FileName = "KeyConfig"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

local Tab = Window:CreateTab("Key", 4483362458)

local enteredKey = ""

local Input = Tab:CreateInput({
   Name = "Enter Key",
   PlaceholderText = "YANZ-KEY-...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      enteredKey = Text
   end,
})

local CheckButton = Tab:CreateButton({
   Name = "Check Key",
   Callback = function()
      if enteredKey == "" then
         Rayfield:Notify({
            Title = "Error",
            Content = "Please enter a key first.",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end
      
      if table.find(validKeys, enteredKey) then
         local success, err = pcall(loadGameScript)
         
         if success then
            saveKey(enteredKey)
            Rayfield:Destroy()
         else
            Rayfield:Notify({
               Title = "Load Error",
               Content = "Failed to load the script: " .. tostring(err),
               Duration = 5,
               Image = 4483362458,
            })
         end
      else
         Rayfield:Notify({
            Title = "Invalid Key",
            Content = "The entered key is invalid.",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local GetButton = Tab:CreateButton({
   Name = "Get Key",
   Callback = function()
      setclipboard("https://lphisv5.github.io/v4/checking.html")
      Rayfield:Notify({
         Title = "Copied to Clipboard",
         Content = "Key page URL has been copied to your clipboard!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})
