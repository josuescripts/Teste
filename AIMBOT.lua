-- AIMBOT PARA DELTA EXECUTOR v2
-- ⚠️ Use APENAS em jogos que você possui autorização!

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Configurações
local AIMBOT_ENABLED = true
local AIM_FOV = 120
local AIM_SMOOTH = 0.25
local AIM_PART = "Head" -- "Head" ou "HumanoidRootPart"

-- Função Delta para checar se o jogo está ativo
local function isGameActive()
    return game:GetService("RunService"):IsRunning()
end

-- Função para pegar inimigos (com suporte Delta)
local function getClosestEnemy()
    local closest = nil
    local closestDist = math.huge
    local players = game.Players:GetPlayers()
    
    for i = 1, #players do
        local v = players[i]
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = v.Character.HumanoidRootPart
            if rootPart and rootPart.Parent then
                local enemyPos = rootPart.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(enemyPos)
                
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist and dist < AIM_FOV then
                        closest = v
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    return closest
end

-- Loop otimizado para Delta
local renderStepped = game:GetService("RunService").RenderStepped
renderStepped:Connect(function()
    if not AIMBOT_ENABLED or not isGameActive() then return end
    
    local target = getClosestEnemy()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(AIM_PART) or target.Character:FindFirstChild("HumanoidRootPart")
        if targetPart and targetPart.Parent then
            -- Offset para mira na cabeça
            local offset = AIM_PART == "Head" and Vector3.new(0, 0.5, 0) or Vector3.new(0, 0, 0)
            local targetPos = targetPart.Position + offset
            
            -- Suavidade com delta
            local currentPos = camera.CFrame.Position
            local lookAt = CFrame.new(currentPos, targetPos)
            camera.CFrame = camera.CFrame:Lerp(lookAt, AIM_SMOOTH)
        end
    end
end)

-- Sistema de toggle (compatível Delta)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        AIMBOT_ENABLED = not AIMBOT_ENABLED
        print("[DELTA] AimBot " .. (AIMBOT_ENABLED and "ATIVADO" or "DESATIVADO"))
    end
    
    -- F2 = FOV aumenta
    if input.KeyCode == Enum.KeyCode.F2 then
        AIM_FOV = math.min(AIM_FOV + 20, 360)
        print("[DELTA] FOV: " .. AIM_FOV)
    end
    
    -- F3 = FOV diminui
    if input.KeyCode == Enum.KeyCode.F3 then
        AIM_FOV = math.max(AIM_FOV - 20, 20)
        print("[DELTA] FOV: " .. AIM_FOV)
    end
end)

print("=====================================")
print("[DELTA] AIMBOT CARREGADO COM SUCESSO!")
print("[DELTA] F1 = Ligar/Desligar")
print("[DELTA] F2 = Aumentar FOV")
print("[DELTA] F3 = Diminuir FOV")
print("=====================================")

-- Previne crash no Delta
local function preventCrash()
    wait(60)
    if not game:IsLoaded() then
        game:Load()
    end
end
spawn(preventCrash)
