-- Carrega Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Cria janela
local Window = Rayfield:CreateWindow({
    Name = "byby Hub",
    LoadingTitle = "Steal A Brainrot Script",
    LoadingSubtitle = "by edulucas2013",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "SABConfigs",
        FileName = "settings.json"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "",
        Subtitle = "",
        Note = "",
        FileName = "",
        SaveKey = false,
        GrabKeyFromSite = false,
    }
})

-- Cria a aba principal
local MainTab = Window:CreateTab("Main", 4483362458) -- Nome, Icone

-- Mensagem de aviso
MainTab:CreateParagraph({
    Title = "Aviso sobre a velocidade",
    Content = "Evite pular em velocidade máxima, se, mesmo na velocidade máxima, você estiver lento, pule para obter mais velocidade!"
})

-- Variável que vai guardar o valor desejado
local targetSpeed = 16

-- Slider para controle da velocidade dentro da aba Main
MainTab:CreateSlider({
    Name = "Velocidade",
    Range = {16, 75},
    Increment = 0.5,
    Suffix = "studs/s",
    CurrentValue = targetSpeed,
    Flag = "SpeedFlag",
    Callback = function(val)
        targetSpeed = val
    end
})

-- Inf Jump e God Mode
local infJumpEnabled = false
local godModeEnabled = false

MainTab:CreateToggle({
    Name = "Inf Jump (com God Mode)",
    CurrentValue = false,
    Flag = "InfJumpFlag",
    Callback = function(state)
        infJumpEnabled = state
        godModeEnabled = state
    end
})

-- ESP Toggle
local ESP_ENABLED = false
local ESP_COLOR = Color3.new(1,0,0)
local ESP_TRANSPARENCY = 0.6
local ESP_ADORNEES = {}

MainTab:CreateToggle({
    Name = "ESP (Blocos vermelhos nos jogadores)",
    CurrentValue = false,
    Flag = "ESPFlag",
    Callback = function(state)
        ESP_ENABLED = state
        if not ESP_ENABLED then
            -- Remove todos os ESPs
            for char, adorns in pairs(ESP_ADORNEES) do
                for _, adorn in ipairs(adorns) do
                    if adorn and adorn.Parent then
                        pcall(function() adorn:Destroy() end)
                    end
                end
            end
            ESP_ADORNEES = {}
        else
            -- Aplica ESP em todos imediatamente
            applyESPToAll()
        end
    end
})

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Inf Jump handler (pulos infinitos)
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp then
            -- Força o pulo
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            -- Pequena variação na posição Y para despistar
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 50 + math.random(), hrp.Velocity.Z)
            hrp.CFrame = hrp.CFrame + Vector3.new(0, math.random() * 0.05, 0)
        end
    end
end)

-- God Mode agressivo
local function GodMode(humanoid)
    if not humanoid then return end

    local healthConn
    local diedConn
    local stateConn

    healthConn = humanoid.HealthChanged:Connect(function()
        if godModeEnabled and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    diedConn = humanoid.Died:Connect(function()
        if godModeEnabled then
            task.spawn(function()
                for i = 1, 5 do
                    humanoid.Health = humanoid.MaxHealth
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    task.wait()
                end
            end)
        end
    end)

    stateConn = humanoid.StateChanged:Connect(function(_, state)
        if godModeEnabled and state == Enum.HumanoidStateType.Dead then
            task.spawn(function()
                for i = 1, 5 do
                    humanoid.Health = humanoid.MaxHealth
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    task.wait()
                end
            end)
        end
    end)

    local function cleanup()
        if healthConn then pcall(function() healthConn:Disconnect() end) end
        if diedConn then pcall(function() diedConn:Disconnect() end) end
        if stateConn then pcall(function() stateConn:Disconnect() end) end
    end

    humanoid.AncestryChanged:Connect(function(_, parent)
        if not parent then cleanup() end
    end)

    return cleanup
end

local currentCleanup = nil
local function setupGodMode()
    if currentCleanup then currentCleanup() end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and godModeEnabled then
        currentCleanup = GodMode(humanoid)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    setupGodMode()
end)

task.spawn(function()
    while task.wait(0.5) do
        if godModeEnabled then
            setupGodMode()
        elseif currentCleanup then
            currentCleanup()
            currentCleanup = nil
        end
    end
end)

-- Speed handler
task.spawn(function()
    while task.wait() do
        local plr = LocalPlayer
        local char = plr and plr.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and humanoid) then continue end

        -- vetor de movimento desejado
        local moveDir = humanoid.MoveDirection
        local desiredVel = moveDir * targetSpeed

        -- pequena variação randômica para despistar
        local jitter = Vector3.new(
            (math.random() - 0.5) * 0.2,
            0,
            (math.random() - 0.5) * 0.2
        )
        desiredVel = desiredVel + jitter

        -- interpolação suave (0.1 por frame)
        local currentVel = hrp.Velocity
        local newVel = currentVel:Lerp(
            Vector3.new(desiredVel.X, currentVel.Y, desiredVel.Z),
            0.1
        )

        -- aplica só X e Z, mantendo Y intacto
        hrp.Velocity = Vector3.new(newVel.X, currentVel.Y, newVel.Z)
    end
end)

-- ESP Functions
local function addESPToCharacter(char)
    if not char or not char:IsDescendantOf(workspace) then return end
    -- Remove ESP antigo desse char, se existir
    if ESP_ADORNEES[char] then
        for _, adorn in ipairs(ESP_ADORNEES[char]) do
            if adorn and adorn.Parent then
                pcall(function() adorn:Destroy() end)
            end
        end
    end
    ESP_ADORNEES[char] = {}

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local box = Instance.new("BoxHandleAdornment")
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = part.Size
            box.Color3 = ESP_COLOR
            box.Transparency = ESP_TRANSPARENCY
            box.Parent = part
            -- Garante que o ESP fique visível mesmo se a peça ficar invisível
            box.Visible = true
            table.insert(ESP_ADORNEES[char], box)
        end
    end
end

local function removeESPFromCharacter(char)
    if ESP_ADORNEES[char] then
        for _, adorn in ipairs(ESP_ADORNEES[char]) do
            if adorn and adorn.Parent then
                pcall(function() adorn:Destroy() end)
            end
        end
        ESP_ADORNEES[char] = nil
    end
end

function applyESPToAll()
    if not ESP_ENABLED then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                addESPToCharacter(char)
            end
        end
    end
end

-- Quando um novo jogador entra
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if ESP_ENABLED then
            addESPToCharacter(char)
        end
    end)
end)

-- Quando um jogador reseta/renasce
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if ESP_ENABLED then
                addESPToCharacter(char)
            end
        end)
    end
end

-- Atualização periódica para garantir ESP em todos
task.spawn(function()
    while true do
        if ESP_ENABLED then
            applyESPToAll()
        end
        task.wait(5)
    end
end)

-- Remove ESP de quem sair
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeESPFromCharacter(player.Character)
    end
end)

-- ProximityPrompt Min Toggle
local proxMinEnabled = false
local proxConn = nil

MainTab:CreateToggle({
    Name = "ProximityPrompt Min (toggle)",
    CurrentValue = false,
    Flag = "ProxMinFlag",
    Callback = function(state)
        proxMinEnabled = state
        if proxConn then
            proxConn:Disconnect()
            proxConn = nil
        end
        if state then
            -- Função para aplicar o mínimo em todos os prompts existentes
            local function minAllPrompts()
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0.00
                    end
                end
            end
            minAllPrompts()
            -- Sempre que um novo ProximityPrompt aparecer, aplica o mínimo
            proxConn = workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0.00
                end
            end)
        else
            -- Opcional: restaurar para o padrão (não recomendado, pode causar inconsistências)
            if proxConn then proxConn:Disconnect() proxConn = nil end
        end
    end
})

-- Garante que ao renascer, se o toggle estiver ativo, o efeito continua
Players.LocalPlayer.CharacterAdded:Connect(function()
    if proxMinEnabled then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0.00
            end
        end
    end
end)
