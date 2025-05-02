local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aimbotActive = false
local espActive = false
local noclipActive = false
local gui
local espBoxes = {}
local noclipConnection

-- Función para obtener el jugador más cercano
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Crear GUI solo si no existe
local function createGui()
    if gui then return end
    gui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 220, 0, 180)
    frame.Position = UDim2.new(0.05, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "By : GlobalScriptsrbx🌎"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14

    local aimbotBtn = Instance.new("TextButton", frame)
    aimbotBtn.Size = UDim2.new(1, 0, 0, 40)
    aimbotBtn.Position = UDim2.new(0, 0, 0, 30)
    aimbotBtn.Text = "Activar Aimbot Cam"
    aimbotBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    aimbotBtn.TextColor3 = Color3.new(1,1,1)
    aimbotBtn.Font = Enum.Font.GothamBold
    aimbotBtn.TextSize = 16

    local espBtn = Instance.new("TextButton", frame)
    espBtn.Size = UDim2.new(1, 0, 0, 40)
    espBtn.Position = UDim2.new(0, 0, 0, 80)
    espBtn.Text = "Activar ESP"
    espBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    espBtn.TextColor3 = Color3.new(1,1,1)
    espBtn.Font = Enum.Font.GothamBold
    espBtn.TextSize = 16

    local noclipBtn = Instance.new("TextButton", frame)
    noclipBtn.Size = UDim2.new(1, 0, 0, 40)
    noclipBtn.Position = UDim2.new(0, 0, 0, 130)
    noclipBtn.Text = "Activar No Clip"
    noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    noclipBtn.TextColor3 = Color3.new(1,1,1)
    noclipBtn.Font = Enum.Font.GothamBold
    noclipBtn.TextSize = 16

    aimbotBtn.MouseButton1Click:Connect(function()
        aimbotActive = not aimbotActive
        aimbotBtn.Text = aimbotActive and "Desactivar Aimbot Cam" or "Activar Aimbot Cam"
    end)

    espBtn.MouseButton1Click:Connect(function()
        espActive = not espActive
        espBtn.Text = espActive and "Desactivar ESP" or "Activar ESP"
    end)

    noclipBtn.MouseButton1Click:Connect(function()
        noclipActive = not noclipActive
        noclipBtn.Text = noclipActive and "Desactivar No Clip" or "Activar No Clip"

        if noclipActive then
            noclipConnection = RunService.Stepped:Connect(function()
                for _, part in pairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        elseif noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end)
end

-- Crear ESP Box
local function createESPBox(player)
    if espBoxes[player] then return end
    local box = Drawing.new("Text")
    box.Text = player.Name
    box.Size = 14
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Center = true
    box.Outline = true
    espBoxes[player] = box
end

local function removeESPBox(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    createGui()

    if aimbotActive then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head.Position
            camera.CFrame = CFrame.new(camera.CFrame.Position, head)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if espActive then
                createESPBox(player)
                local pos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    espBoxes[player].Position = Vector2.new(pos.X, pos.Y - 20)
                    espBoxes[player].Visible = true
                else
                    espBoxes[player].Visible = false
                end
            else
                removeESPBox(player)
            end
        end
    end
end)

localPlayer.CharacterAdded:Connect(function()
    wait(1)
    createGui()
end)
