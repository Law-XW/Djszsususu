local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
        Title = "Rivals",
        Footer = "Xeioa-FreeVersion gg.xeioa",
        Icon = 95816097006870,
        NotifySide = "Right",
        ShowCustomCursor = true,
})

local Tabs = {
        Rage        = Window:AddTab("Rage",        "crosshair"),
        ESP         = Window:AddTab("ESP",         "eye"),
        Visual      = Window:AddTab("Visual",      "star"),
        Gun         = Window:AddTab("Gun",         "zap"),
        Legit       = Window:AddTab("Legit",       "shield"),
        Movement    = Window:AddTab("Movement",    "move"),
        Misc        = Window:AddTab("Misc",        "zap"),
        ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera


local isLeftMouseDown = false
local isRightMouseDown = false
local autoClickConnection = nil

local espCache = {}


local fovCircle = Drawing.new("Circle")
local fovTracerLine = Drawing.new("Line")
fovCircle.Visible = false
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.5
fovCircle.Filled = false

fovTracerLine.Visible = false
fovTracerLine.Thickness = 1
fovTracerLine.Color = Color3.fromRGB(255, 255, 255)
fovTracerLine.Transparency = 0.5


local fovCircleGood = Drawing.new("Circle")
local fovTracerLineGood = Drawing.new("Line")
fovCircleGood.Visible = false
fovCircleGood.Thickness = 1.5
fovCircleGood.Color = Color3.fromRGB(100, 200, 255)
fovCircleGood.Transparency = 0.5
fovCircleGood.Filled = false

fovTracerLineGood.Visible = false
fovTracerLineGood.Thickness = 1
fovTracerLineGood.Color = Color3.fromRGB(100, 200, 255)
fovTracerLineGood.Transparency = 0.5


local fovCircleGood3 = Drawing.new("Circle")
local fovTracerLineGood3 = Drawing.new("Line")
fovCircleGood3.Visible = false
fovCircleGood3.Thickness = 1.5
fovCircleGood3.Color = Color3.fromRGB(80, 255, 120)
fovCircleGood3.Transparency = 0.5
fovCircleGood3.Filled = false

fovTracerLineGood3.Visible = false
fovTracerLineGood3.Thickness = 1
fovTracerLineGood3.Color = Color3.fromRGB(80, 255, 120)
fovTracerLineGood3.Transparency = 0.5


local crosshairDot = Drawing.new("Circle")
crosshairDot.Visible = false
crosshairDot.Filled = true
crosshairDot.Radius = 3
crosshairDot.Color = Color3.fromRGB(255, 255, 255)
crosshairDot.Transparency = 1
crosshairDot.Thickness = 1

local crosshairLines = {}
for i = 1, 4 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1.5
        l.Color = Color3.fromRGB(255, 255, 255)
        l.Transparency = 1
        crosshairLines[i] = l
end

local crosshairLabel = Drawing.new("Text")
crosshairLabel.Visible = false
crosshairLabel.Center = true
crosshairLabel.Outline = true
crosshairLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
crosshairLabel.Color = Color3.fromRGB(255, 255, 255)
crosshairLabel.Size = 14
crosshairLabel.Font = 2
crosshairLabel.Text = "Xeioa"

local crosshairFPS = Drawing.new("Text")
crosshairFPS.Visible = false
crosshairFPS.Center = true
crosshairFPS.Outline = true
crosshairFPS.OutlineColor = Color3.fromRGB(0, 0, 0)
crosshairFPS.Color = Color3.fromRGB(180, 255, 180)
crosshairFPS.Size = 12
crosshairFPS.Font = 2
crosshairFPS.Text = "0 FPS"

local crosshairHue = 0
local fpsTimer = 0
local fpsCount = 0
local currentFPS = 0


local COLOR_MAP = {
        White   = Color3.fromRGB(255, 255, 255),
        Red     = Color3.fromRGB(255,  60,  60),
        Green   = Color3.fromRGB( 60, 255,  60),
        Blue    = Color3.fromRGB( 60, 140, 255),
        Yellow  = Color3.fromRGB(255, 240,  60),
        Cyan    = Color3.fromRGB( 60, 255, 240),
        Magenta = Color3.fromRGB(255,  60, 220),
        Orange  = Color3.fromRGB(255, 160,  40),
        Pink    = Color3.fromRGB(255, 120, 200),
}
local COLOR_VALUES = { "White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Pink" }

local function lerpColor(c1, c2, t)
        return Color3.new(
                c1.R + (c2.R - c1.R) * t,
                c1.G + (c2.G - c1.G) * t,
                c1.B + (c2.B - c1.B) * t
        )
end


local fovFillGui = Instance.new("ScreenGui")
fovFillGui.Name = "FOVGradientFills"
fovFillGui.ResetOnSpawn = false
fovFillGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fovFillGui.IgnoreGuiInset = true
pcall(function() fovFillGui.Parent = game:GetService("CoreGui") end)
if not fovFillGui.Parent then fovFillGui.Parent = localPlayer.PlayerGui end

local function createGradientFillFrame(colorA, colorB)
        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BackgroundTransparency = 0.85
        frame.BorderSizePixel = 0
        frame.Visible = false

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, colorA),
                ColorSequenceKeypoint.new(1, colorB),
        })
        gradient.Rotation = 0
        gradient.Parent = frame

        frame.Parent = fovFillGui
        return frame, gradient
end

local fovFillFrame1, fovFillGrad1 = createGradientFillFrame(
        Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 140, 255))
local fovFillFrame2, fovFillGrad2 = createGradientFillFrame(
        Color3.fromRGB(60, 255, 240), Color3.fromRGB(60, 140, 255))
local fovFillFrame3, fovFillGrad3 = createGradientFillFrame(
        Color3.fromRGB(80, 255, 120), Color3.fromRGB(255, 240, 60))

local function updateGradientFill(frame, gradient, radius, cx, cy, colorA, colorB, animate, animTime)
        frame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
        frame.Position = UDim2.new(0, cx, 0, cy)
        gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, colorA),
                ColorSequenceKeypoint.new(1, colorB),
        })
        if animate then
                gradient.Rotation = (animTime * 80) % 360
                local pulse = math.sin(animTime * 2) * 0.5 + 0.5
                frame.BackgroundTransparency = 0.6 + (1 - pulse) * 0.3
        else
                gradient.Rotation = 0
                frame.BackgroundTransparency = 0.85
        end
        frame.Visible = true
end


local Hitmarker = {}
Hitmarker.__index = Hitmarker

function Hitmarker.new()
        local self = setmetatable({}, Hitmarker)
        self._duration  = 0.5
        self._size      = 36
        self._thickness = 2
        self:_hookDamage()
        return self
end

function Hitmarker:show(screenX, screenY, playerName, damage, isPlayer)
        local cx = screenX or (camera.ViewportSize.X / 2)
        local cy = screenY or (camera.ViewportSize.Y / 2)

        if isPlayer and Toggles.HitNotify and Toggles.HitNotify.Value and playerName and damage then
                Library:Notify("Hit " .. playerName .. " for " .. tostring(math.floor(damage)) .. " damage", 3)
        end

        if Toggles.DamageIndicator and Toggles.DamageIndicator.Value and damage then
                local dmgText = Drawing.new("Text")
                dmgText.Text = "-" .. tostring(math.floor(damage))
                dmgText.Size = 17
                dmgText.Center = true
                dmgText.Outline = true
                dmgText.OutlineColor = Color3.fromRGB(0, 0, 0)
                dmgText.Font = 2
                dmgText.Position = Vector2.new(cx, cy)
                dmgText.Visible = true
                local startT = tick()
                local dur = 1.1
                local colorA = Color3.fromRGB(255, 230, 50)
                local colorB = Color3.fromRGB(255, 40, 40)
                local conn2
                conn2 = RunService.RenderStepped:Connect(function()
                        local e = (tick() - startT) / dur
                        if e >= 1 then
                                dmgText:Remove()
                                conn2:Disconnect()
                                return
                        end
                        dmgText.Color = lerpColor(colorA, colorB, e)
                        dmgText.Transparency = math.max(0, e - 0.4) / 0.6
                        dmgText.Position = Vector2.new(cx, cy - e * 48)
                end)
        end

        if not (Toggles.HitmarkerEnabled and Toggles.HitmarkerEnabled.Value) then return end

        local gap  = 5
        local len  = self._size * 0.5
        local th   = self._thickness
        local dirs = {
                { Vector2.new(cx, cy - gap), Vector2.new(cx, cy - gap - len) },
                { Vector2.new(cx, cy + gap), Vector2.new(cx, cy + gap + len) },
                { Vector2.new(cx - gap, cy), Vector2.new(cx - gap - len, cy) },
                { Vector2.new(cx + gap, cy), Vector2.new(cx + gap + len, cy) },
        }
        local drawnLines = {}
        for _, d in ipairs(dirs) do
                local l = Drawing.new("Line")
                l.From      = d[1]
                l.To        = d[2]
                l.Thickness = th
                l.Color     = Color3.fromRGB(255, 255, 255)
                l.Transparency = 1
                l.Visible   = true
                table.insert(drawnLines, l)
        end

        local startTime = tick()
        local dur = self._duration
        local conn
        conn = RunService.RenderStepped:Connect(function()
                local e = (tick() - startTime) / dur
                if e >= 1 then
                        for _, l in ipairs(drawnLines) do l:Remove() end
                        conn:Disconnect()
                        return
                end
                local alpha = 1 - e
                local spread = e * 4
                local newDirs = {
                        { Vector2.new(cx, cy - gap - spread), Vector2.new(cx, cy - gap - len - spread) },
                        { Vector2.new(cx, cy + gap + spread), Vector2.new(cx, cy + gap + len + spread) },
                        { Vector2.new(cx - gap - spread, cy), Vector2.new(cx - gap - len - spread, cy) },
                        { Vector2.new(cx + gap + spread, cy), Vector2.new(cx + gap + len + spread, cy) },
                }
                for i, l in ipairs(drawnLines) do
                        l.From          = newDirs[i][1]
                        l.To            = newDirs[i][2]
                        l.Transparency  = alpha
                end
        end)
end

function Hitmarker:_hookDamage()
        local lastHealth = {}

        local function findHealth(entity)
                if not entity then return nil end
                if type(entity.GetHealth) == "function" then
                        local ok, val = pcall(function() return entity:GetHealth() end)
                        if ok and type(val) == "number" then return val end
                end
                if entity.Humanoid and type(entity.Humanoid.Health) == "number" then
                        return entity.Humanoid.Health
                end
                if entity.Parent and entity.Parent:FindFirstChild("Humanoid") then
                        return entity.Parent.Humanoid.Health
                end
                return nil
        end

        local function findPosition(entity)
                if not entity then return nil end
                if type(entity.GetPosition) == "function" then
                        local ok, val = pcall(function() return entity:GetPosition() end)
                        if ok and typeof(val) == "Vector3" then return val end
                end
                if entity.HumanoidRootPart and entity.HumanoidRootPart.Position then
                        return entity.HumanoidRootPart.Position
                end
                if entity.Parent and entity.Parent:FindFirstChild("HumanoidRootPart") then
                        return entity.Parent.HumanoidRootPart.Position
                end
                return nil
        end

        local function scan()
                local success, enemyController = pcall(function()
                        return require(localPlayer.PlayerScripts.Controllers.EnemyController)
                end)
                if success and enemyController and enemyController.Objects then
                        for _, enemy in pairs(enemyController.Objects) do
                                local health = findHealth(enemy)
                                if health then
                                        local id = tostring(enemy)
                                        local prev = lastHealth[id]
                                        if prev and health < prev and health > 0 then
                                                local dmg = prev - health
                                                local pos = findPosition(enemy)
                                                local char = localPlayer.Character
                                                if char and char:FindFirstChild("HumanoidRootPart") and pos then
                                                        local dist = (char.HumanoidRootPart.Position - pos).Magnitude
                                                        if dist < 300 then
                                                                local sp, onSc = camera:WorldToViewportPoint(pos)
                                                                local name = (enemy.Name ~= "" and enemy.Name) or "Entity"
                                                                if onSc then self:show(sp.X, sp.Y, name, dmg, false) else self:show(nil, nil, name, dmg, false) end
                                                        end
                                                end
                                        end
                                        lastHealth[id] = health
                                end
                        end
                end
                for _, player in pairs(Players:GetPlayers()) do
                        if player ~= localPlayer then
                                local char = player.Character
                                if char and char:FindFirstChild("Humanoid") then
                                        local id = "Player_" .. player.Name
                                        local prev = lastHealth[id]
                                        local current = char.Humanoid.Health
                                        if prev and current < prev and current > 0 then
                                                local dmg = prev - current
                                                local localChar = localPlayer.Character
                                                if localChar and localChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                                                        local dist = (localChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                                                        if dist < 300 then
                                                                local head = char:FindFirstChild("Head")
                                                                local rootPart = char:FindFirstChild("HumanoidRootPart")
                                                                local trackPart = head or rootPart
                                                                if trackPart then
                                                                        local sp, onSc = camera:WorldToViewportPoint(trackPart.Position)
                                                                        if onSc then self:show(sp.X, sp.Y, player.Name, dmg, true) else self:show(nil, nil, player.Name, dmg, true) end
                                                                else
                                                                        self:show(nil, nil, player.Name, dmg, true)
                                                                end
                                                        end
                                                end
                                        end
                                        lastHealth[id] = current
                                end
                        end
                end
        end

        task.spawn(function()
                while task.wait(0.05) do
                        pcall(scan)
                end
        end)
end

local hitmarker = Hitmarker.new()


local function isLobbyVisible()
        local ok, res = pcall(function()
                return localPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible
        end)
        return ok and res == true
end

local function isFriend(player)
        if not Toggles.SilentAimFriendCheck or not Toggles.SilentAimFriendCheck.Value then return false end
        return localPlayer:IsFriendsWith(player.UserId)
end

local function isWallCheck(target)
        if not Toggles.SilentAimWallCheck or not Toggles.SilentAimWallCheck.Value then return false end
        if not target or not target.Character or not target.Character:FindFirstChild("Head") then return true end
        local targetHead = target.Character.Head
        local origin = camera.CFrame.Position
        local direction = (targetHead.Position - origin)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {localPlayer.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(origin, direction, rayParams)
        if result then return not result.Instance:IsDescendantOf(target.Character) end
        return false
end


local function isWallCheckEntity(entity, wallCheckToggleKey)
        if not Toggles[wallCheckToggleKey] or not Toggles[wallCheckToggleKey].Value then return false end
        if not entity or not entity:FindFirstChild("Head") then return true end
        local targetHead = entity.Head
        local origin = camera.CFrame.Position
        local direction = (targetHead.Position - origin)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {localPlayer.Character, entity}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(origin, direction, rayParams)
        return result ~= nil
end

local function getClosestPlayerToMouse()
        local closestPlayer = nil
        local shortestDistance = math.huge
        local fovRadius = Options.FOVSlider and Options.FOVSlider.Value or 200
        local fovCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local useFOV = Toggles.UseFOV and Toggles.UseFOV.Value
        for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        if isFriend(player) then continue end
                        if isWallCheck(player) then continue end
                        local head = player.Character.Head
                        local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                                local screenPosition = Vector2.new(headPosition.X, headPosition.Y)
                                local distance = (screenPosition - fovCenter).Magnitude
                                if useFOV then
                                        if distance < shortestDistance and distance <= fovRadius then
                                                closestPlayer = player
                                                shortestDistance = distance
                                        end
                                else
                                        if distance < shortestDistance then
                                                closestPlayer = player
                                                shortestDistance = distance
                                        end
                                end
                        end
                end
        end
        return closestPlayer
end

local targetPlayer = nil

local function lockCameraToHead()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                local head = targetPlayer.Character.Head
                local headPosition = camera:WorldToViewportPoint(head.Position)
                if headPosition.Z > 0 then
                        local cameraPosition = camera.CFrame.Position
                        camera.CFrame = CFrame.new(cameraPosition, head.Position)
                end
        end
end

local function autoClick()
        if autoClickConnection then autoClickConnection:Disconnect() end
        autoClickConnection = RunService.Heartbeat:Connect(function()
                if isLeftMouseDown or isRightMouseDown then
                        if not isLobbyVisible() then mouse1click() end
                else
                        autoClickConnection:Disconnect()
                end
        end)
end

UserInputService.InputBegan:Connect(function(input, isProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not isProcessed then
                if not isLeftMouseDown then isLeftMouseDown = true autoClick() end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not isProcessed then
                if not isRightMouseDown then isRightMouseDown = true autoClick() end
        end
end)

UserInputService.InputEnded:Connect(function(input, isProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isLeftMouseDown = false end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end
end)

RunService.Heartbeat:Connect(function()
        if not isLobbyVisible() and Toggles.SilentAim and Toggles.SilentAim.Value then
                targetPlayer = getClosestPlayerToMouse()
                if targetPlayer then lockCameraToHead() end
        end
end)


local rs = game:GetService("ReplicatedStorage")

local goodSATarget = nil
local good3SATarget = nil

local oldRaycast2 = nil
local raycastHooked2 = false

local function fetchEntities()
        local entities = {}
        for _, v in pairs(workspace:GetChildren()) do
                if v:FindFirstChildOfClass("Humanoid") then
                        table.insert(entities, v)
                elseif v.Name == "HurtEffect" then
                        for _, child in pairs(v:GetChildren()) do
                                if child.ClassName ~= "Highlight" then
                                        table.insert(entities, child)
                                end
                        end
                end
        end
        return entities
end


local function fetchNearestGood(fovKey, useFOVKey, wallCheckToggleKey)
        local target, dist = nil, math.huge
        local fovRadius = Options[fovKey] and Options[fovKey].Value or 200
        local useFOV = Toggles[useFOVKey] and Toggles[useFOVKey].Value
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        for _, entity in pairs(fetchEntities()) do
                if entity ~= localPlayer.Character and entity:FindFirstChild("HumanoidRootPart") then
                        if wallCheckToggleKey and isWallCheckEntity(entity, wallCheckToggleKey) then continue end
                        local hitPart = entity:FindFirstChild("Head")
                        if hitPart then
                                local pos, visible = camera:WorldToViewportPoint(hitPart.Position)
                                if visible then
                                        local mag = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                                        if useFOV then
                                                if mag < dist and mag <= fovRadius then target, dist = entity, mag end
                                        else
                                                if mag < dist then target, dist = entity, mag end
                                        end
                                end
                        end
                end
        end
        return target
end

local function hookRaycast2()
        if raycastHooked2 then return end
        local ok, utility = pcall(function() return require(rs.Modules.Utility) end)
        if not ok or not utility then return end
        oldRaycast2 = utility.Raycast
        utility.Raycast = function(...)
                local arguments = {...}
                if Toggles.GoodSilentAim and Toggles.GoodSilentAim.Value and arguments[4] == 999 then
                        local aim = fetchNearestGood("GoodFOVSlider", "GoodUseFOV", "GoodSilentAimWallCheck")
                        local node = aim and aim:FindFirstChild("Head")
                        if node then arguments[3] = node.Position end
                end
                return oldRaycast2(table.unpack(arguments))
        end
        raycastHooked2 = true
end

local function unhookRaycast2()
        if not raycastHooked2 then return end
        local ok, utility = pcall(function() return require(rs.Modules.Utility) end)
        if ok and utility and oldRaycast2 then utility.Raycast = oldRaycast2 end
        raycastHooked2 = false
        oldRaycast2 = nil
end

local oldRaycast3 = nil
local raycastHooked3 = false


local function getClosestByDistance()
        local char = localPlayer.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closest, closestDist = nil, 999999
        for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character then
                        local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if theirRoot then
                                if isWallCheckEntity(p.Character, "Good3SilentAimWallCheck") then continue end
                                local d = (root.Position - theirRoot.Position).Magnitude
                                if d < closestDist then
                                        closestDist = d
                                        closest = p
                                end
                        end
                end
        end
        return closest
end

local function hookRaycast3()
        if raycastHooked3 then return end
        local ok, utility3 = pcall(function() return require(rs.Modules.Utility) end)
        if not ok or not utility3 then return end
        oldRaycast3 = utility3.Raycast
        utility3.Raycast = function(self2, startPos, endPos, maxDist, filterList, filterType, debugMode)
                if not (Toggles.Good3SilentAim and Toggles.Good3SilentAim.Value) then
                        return oldRaycast3(self2, startPos, endPos, maxDist, filterList, filterType, debugMode)
                end
                local target = getClosestByDistance()
                if not target or not target.Character or not target.Character:FindFirstChild("Head") then
                        return oldRaycast3(self2, startPos, endPos, maxDist, filterList, filterType, debugMode)
                end
                local head = target.Character.Head
                local pos = head.Position
                local dir = (pos - startPos).Unit
                local dist = (pos - startPos).Magnitude
                if dist > maxDist then
                        dist = maxDist
                        pos = startPos + dir * maxDist
                end
                return {
                        Position = pos,
                        Distance = dist,
                        Instance = head,
                        Material = head.Material,
                        Normal = -dir,
                }
        end
        raycastHooked3 = true
end

local function unhookRaycast3()
        if not raycastHooked3 then return end
        local ok, utility3 = pcall(function() return require(rs.Modules.Utility) end)
        if ok and utility3 and oldRaycast3 then utility3.Raycast = oldRaycast3 end
        raycastHooked3 = false
        oldRaycast3 = nil
end

RunService.Heartbeat:Connect(function()
        if Toggles.GoodSilentAim and Toggles.GoodSilentAim.Value then
                goodSATarget = fetchNearestGood("GoodFOVSlider", "GoodUseFOV", "GoodSilentAimWallCheck")
        else
                goodSATarget = nil
        end
        if Toggles.Good3SilentAim and Toggles.Good3SilentAim.Value then
                local p3 = getClosestByDistance()
                good3SATarget = p3 and p3.Character or nil
        else
                good3SATarget = nil
        end
end)


local fovAnimTime = 0

RunService.RenderStepped:Connect(function(dt)
        local cx = camera.ViewportSize.X / 2
        local cy = camera.ViewportSize.Y / 2

        fovAnimTime = fovAnimTime + dt


        local sa1radius = Options.FOVSlider and Options.FOVSlider.Value or 200
        local sa1colorA = Options.FOVColorA and Options.FOVColorA.Value or Color3.fromRGB(255, 60, 60)
        local sa1colorB = Options.FOVColorB and Options.FOVColorB.Value or Color3.fromRGB(60, 140, 255)
        local sa1anim   = Toggles.FOVAnimate and Toggles.FOVAnimate.Value
        if Toggles.DrawFOV and Toggles.DrawFOV.Value then
                local outlineCol = sa1anim
                        and lerpColor(sa1colorA, sa1colorB, math.sin(fovAnimTime * 2) * 0.5 + 0.5)
                        or sa1colorA
                fovCircle.Color = outlineCol
                fovCircle.Visible = true
                fovCircle.Position = Vector2.new(cx, cy)
                fovCircle.Radius = sa1radius
        else
                fovCircle.Visible = false
        end
        if Toggles.FOVFill and Toggles.FOVFill.Value then
                updateGradientFill(fovFillFrame1, fovFillGrad1, sa1radius, cx, cy, sa1colorA, sa1colorB, sa1anim, fovAnimTime)
        else
                fovFillFrame1.Visible = false
        end
        if Toggles.FOVTracer and Toggles.FOVTracer.Value and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                local hp, onScreen = camera:WorldToViewportPoint(targetPlayer.Character.Head.Position)
                if onScreen then
                        fovTracerLine.Visible = true
                        fovTracerLine.From = Vector2.new(cx, cy)
                        fovTracerLine.To = Vector2.new(hp.X, hp.Y)
                else fovTracerLine.Visible = false end
        else fovTracerLine.Visible = false end


        local sa2radius = Options.GoodFOVSlider and Options.GoodFOVSlider.Value or 200
        local sa2colorA = Options.GoodFOVColorA and Options.GoodFOVColorA.Value or Color3.fromRGB(60, 255, 240)
        local sa2colorB = Options.GoodFOVColorB and Options.GoodFOVColorB.Value or Color3.fromRGB(60, 140, 255)
        local sa2anim   = Toggles.GoodFOVAnimate and Toggles.GoodFOVAnimate.Value
        if Toggles.GoodDrawFOV and Toggles.GoodDrawFOV.Value then
                local outlineCol2 = sa2anim
                        and lerpColor(sa2colorA, sa2colorB, math.sin(fovAnimTime * 2) * 0.5 + 0.5)
                        or sa2colorA
                fovCircleGood.Color = outlineCol2
                fovCircleGood.Visible = true
                fovCircleGood.Position = Vector2.new(cx, cy)
                fovCircleGood.Radius = sa2radius
        else fovCircleGood.Visible = false end
        if Toggles.GoodFOVFill and Toggles.GoodFOVFill.Value then
                updateGradientFill(fovFillFrame2, fovFillGrad2, sa2radius, cx, cy, sa2colorA, sa2colorB, sa2anim, fovAnimTime)
        else fovFillFrame2.Visible = false end
        if Toggles.GoodFOVTracer and Toggles.GoodFOVTracer.Value and goodSATarget then
                local hp2 = goodSATarget:FindFirstChild("Head")
                if hp2 then
                        local sp, os = camera:WorldToViewportPoint(hp2.Position)
                        if os then
                                fovTracerLineGood.Visible = true
                                fovTracerLineGood.From = Vector2.new(cx, cy)
                                fovTracerLineGood.To = Vector2.new(sp.X, sp.Y)
                        else fovTracerLineGood.Visible = false end
                else fovTracerLineGood.Visible = false end
        else fovTracerLineGood.Visible = false end


        local sa3radius = Options.Good3FOVSlider and Options.Good3FOVSlider.Value or 200
        local sa3colorA = Options.Good3FOVColorA and Options.Good3FOVColorA.Value or Color3.fromRGB(80, 255, 120)
        local sa3colorB = Options.Good3FOVColorB and Options.Good3FOVColorB.Value or Color3.fromRGB(255, 240, 60)
        local sa3anim   = Toggles.Good3FOVAnimate and Toggles.Good3FOVAnimate.Value
        if Toggles.Good3DrawFOV and Toggles.Good3DrawFOV.Value then
                local outlineCol3 = sa3anim
                        and lerpColor(sa3colorA, sa3colorB, math.sin(fovAnimTime * 2) * 0.5 + 0.5)
                        or sa3colorA
                fovCircleGood3.Color = outlineCol3
                fovCircleGood3.Visible = true
                fovCircleGood3.Position = Vector2.new(cx, cy)
                fovCircleGood3.Radius = sa3radius
        else fovCircleGood3.Visible = false end
        if Toggles.Good3FOVFill and Toggles.Good3FOVFill.Value then
                updateGradientFill(fovFillFrame3, fovFillGrad3, sa3radius, cx, cy, sa3colorA, sa3colorB, sa3anim, fovAnimTime)
        else fovFillFrame3.Visible = false end
        if Toggles.Good3FOVTracer and Toggles.Good3FOVTracer.Value and good3SATarget then
                local hp3 = good3SATarget:FindFirstChild("Head")
                if hp3 then
                        local sp3, os3 = camera:WorldToViewportPoint(hp3.Position)
                        if os3 then
                                fovTracerLineGood3.Visible = true
                                fovTracerLineGood3.From = Vector2.new(cx, cy)
                                fovTracerLineGood3.To = Vector2.new(sp3.X, sp3.Y)
                        else fovTracerLineGood3.Visible = false end
                else fovTracerLineGood3.Visible = false end
        else fovTracerLineGood3.Visible = false end


        fpsCount = fpsCount + 1
        fpsTimer = fpsTimer + dt
        if fpsTimer >= 0.5 then
                currentFPS = math.floor(fpsCount / fpsTimer)
                fpsCount = 0
                fpsTimer = 0
        end

        crosshairHue = (crosshairHue + 0.008) % 1


        if Toggles.Crosshair and Toggles.Crosshair.Value then
                local style     = Options.CrosshairStyle and Options.CrosshairStyle.Value or "Spinner"
                local size      = Options.CrosshairSize and Options.CrosshairSize.Value or 14
                local spinSpeed = Options.CrosshairSpinSpeed and Options.CrosshairSpinSpeed.Value or 2
                local useGrad   = Toggles.CrosshairGradient and Toggles.CrosshairGradient.Value
                local colorMap  = {
                        White   = Color3.fromRGB(255, 255, 255),
                        Red     = Color3.fromRGB(255,  60,  60),
                        Green   = Color3.fromRGB( 60, 255,  60),
                        Blue    = Color3.fromRGB( 60, 140, 255),
                        Yellow  = Color3.fromRGB(255, 240,  60),
                        Cyan    = Color3.fromRGB( 60, 255, 240),
                        Magenta = Color3.fromRGB(255,  60, 220),
                        Orange  = Color3.fromRGB(255, 160,  40),
                        Pink    = Color3.fromRGB(255, 120, 200),
                }
                local colorKey  = Options.CrosshairColor and Options.CrosshairColor.Value or "White"
                local baseCol   = colorMap[colorKey] or Color3.fromRGB(255, 255, 255)

                local function lineCol(i)
                        if useGrad then
                                return Color3.fromHSV((crosshairHue + (i - 1) * 0.25) % 1, 1, 1)
                        end
                        return baseCol
                end
                local dotCol = useGrad and Color3.fromHSV(crosshairHue, 1, 1) or baseCol

                if style == "Spinner" then
                        local angle = tick() * spinSpeed
                        local inner = size * 0.4
                        crosshairDot.Visible = true
                        crosshairDot.Position = Vector2.new(cx, cy)
                        crosshairDot.Radius = 2
                        crosshairDot.Color = dotCol
                        crosshairDot.Filled = true
                        crosshairDot.Thickness = 1
                        for i, l in ipairs(crosshairLines) do
                                local a = angle + (i - 1) * (math.pi / 2)
                                local ca, sa = math.cos(a), math.sin(a)
                                l.From = Vector2.new(cx + ca * inner, cy + sa * inner)
                                l.To   = Vector2.new(cx + ca * size,  cy + sa * size)
                                l.Color = lineCol(i)
                                l.Thickness = 2
                                l.Visible = true
                        end
                elseif style == "Dot" then
                        crosshairDot.Visible = true
                        crosshairDot.Position = Vector2.new(cx, cy)
                        crosshairDot.Radius = 2.5
                        crosshairDot.Color = dotCol
                        crosshairDot.Filled = true
                        for _, l in ipairs(crosshairLines) do l.Visible = false end
                elseif style == "Cross" then
                        crosshairDot.Visible = false
                        local gap = 3
                        local angle2 = tick() * spinSpeed
                        for i, l in ipairs(crosshairLines) do
                                local a = angle2 + (i - 1) * (math.pi / 2)
                                local ca, sa = math.cos(a), math.sin(a)
                                l.From = Vector2.new(cx + ca * gap,        cy + sa * gap)
                                l.To   = Vector2.new(cx + ca * (gap+size), cy + sa * (gap+size))
                                l.Color = lineCol(i)
                                l.Thickness = 1.5
                                l.Visible = true
                        end
                elseif style == "Circle" then
                        crosshairDot.Visible = true
                        crosshairDot.Position = Vector2.new(cx, cy)
                        crosshairDot.Radius = size
                        crosshairDot.Color = dotCol
                        crosshairDot.Filled = false
                        crosshairDot.Thickness = 1.5
                        local angle3 = tick() * spinSpeed
                        for i, l in ipairs(crosshairLines) do
                                local a = angle3 + (i - 1) * (math.pi / 2)
                                local aS = a - 0.18
                                local aE = a + 0.18
                                l.From = Vector2.new(cx + math.cos(aS) * size, cy + math.sin(aS) * size)
                                l.To   = Vector2.new(cx + math.cos(aE) * size, cy + math.sin(aE) * size)
                                l.Color = lineCol(i)
                                l.Thickness = 2
                                l.Visible = true
                        end
                end

                local labelY = cy + size + 10

                if Toggles.CrosshairShowFPS and Toggles.CrosshairShowFPS.Value then
                        crosshairFPS.Text = currentFPS .. " FPS"
                        crosshairFPS.Color = useGrad and Color3.fromHSV(crosshairHue, 1, 1) or Color3.fromRGB(180, 255, 180)
                        crosshairFPS.Position = Vector2.new(cx, labelY)
                        crosshairFPS.Visible = true
                        labelY = labelY + 16
                else
                        crosshairFPS.Visible = false
                end

                if Toggles.CrosshairShowLabel and Toggles.CrosshairShowLabel.Value then
                        crosshairLabel.Color = useGrad and Color3.fromHSV((crosshairHue + 0.5) % 1, 1, 1) or baseCol
                        crosshairLabel.Position = Vector2.new(cx, labelY)
                        crosshairLabel.Visible = true
                else
                        crosshairLabel.Visible = false
                end
        else
                crosshairDot.Visible = false
                for _, l in ipairs(crosshairLines) do l.Visible = false end
                crosshairFPS.Visible = false
                crosshairLabel.Visible = false
        end
end)


local RageGroup = Tabs.Rage:AddLeftGroupbox("Silent Aim (Bad Executor)", "crosshair")

RageGroup:AddToggle("SilentAim", {
        Text = "Enable Silent Aim",
        Default = false,
        Tooltip = "Locks camera onto closest player",
        Risky = true,
})

RageGroup:AddToggle("UseFOV", {
        Text = "Use FOV",
        Default = true,
        Tooltip = "Only target players inside FOV radius",
})

RageGroup:AddSlider("FOVSlider", {
        Text = "FOV Radius",
        Default = 200,
        Min = 50,
        Max = 800,
        Rounding = 0,
        Suffix = "px",
        Tooltip = "Detection radius from screen center",
})

RageGroup:AddToggle("DrawFOV", {
        Text = "Draw FOV Circle",
        Default = true,
        Tooltip = "Visualize the aim FOV (white)",
})

RageGroup:AddToggle("FOVFill", {
        Text = "FOV Fill (Gradient)",
        Default = false,
        Tooltip = "Fill the FOV circle with an animated gradient",
})

RageGroup:AddToggle("FOVAnimate", {
        Text = "Animate Gradient",
        Default = false,
        Tooltip = "Rotates gradient and pulses transparency",
})


local fovColorAToggle = RageGroup:AddToggle("FOVColorAEnable", {
        Text = "Color A",
        Default = true,
})
fovColorAToggle:AddColorPicker("FOVColorA", {
        Default = Color3.fromRGB(255, 60, 60),
        Title = "FOV Fill – Color A",
        Transparency = 0,
})


local fovColorBToggle = RageGroup:AddToggle("FOVColorBEnable", {
        Text = "Color B",
        Default = true,
})
fovColorBToggle:AddColorPicker("FOVColorB", {
        Default = Color3.fromRGB(60, 140, 255),
        Title = "FOV Fill – Color B",
        Transparency = 0,
})

RageGroup:AddToggle("FOVTracer", {
        Text = "FOV Tracer",
        Default = false,
        Tooltip = "Line from center to target",
})

RageGroup:AddToggle("SilentAimWallCheck", {
        Text = "Wall Check",
        Default = false,
        Tooltip = "Skip targets behind walls",
})

RageGroup:AddToggle("SilentAimFriendCheck", {
        Text = "Friend Check",
        Default = false,
        Tooltip = "Skip friends",
})


local GoodRageGroup = Tabs.Rage:AddRightGroupbox("Silent Aim 2 (Good Executor)", "zap")

GoodRageGroup:AddToggle("GoodSilentAim", {
        Text = "Enable Silent Aim",
        Default = false,
        Tooltip = "Hooks Utility.Raycast — good executors only",
        Risky = true,
})

GoodRageGroup:AddToggle("GoodUseFOV", {
        Text = "Use FOV",
        Default = true,
        Tooltip = "Only target players inside FOV radius",
})

GoodRageGroup:AddSlider("GoodFOVSlider", {
        Text = "FOV Radius",
        Default = 200,
        Min = 50,
        Max = 800,
        Rounding = 0,
        Suffix = "px",
        Tooltip = "Detection radius from screen center",
})

GoodRageGroup:AddToggle("GoodDrawFOV", {
        Text = "Draw FOV Circle",
        Default = true,
        Tooltip = "Visualize FOV (blue)",
})

GoodRageGroup:AddToggle("GoodFOVFill", {
        Text = "FOV Fill (Gradient)",
        Default = false,
        Tooltip = "Fill the FOV circle with an animated gradient",
})

GoodRageGroup:AddToggle("GoodFOVAnimate", {
        Text = "Animate Gradient",
        Default = false,
        Tooltip = "Rotates gradient and pulses transparency",
})

local goodColorAToggle = GoodRageGroup:AddToggle("GoodFOVColorAEnable", {
        Text = "Color A",
        Default = true,
})
goodColorAToggle:AddColorPicker("GoodFOVColorA", {
        Default = Color3.fromRGB(60, 255, 240),
        Title = "SA2 FOV – Color A",
        Transparency = 0,
})

local goodColorBToggle = GoodRageGroup:AddToggle("GoodFOVColorBEnable", {
        Text = "Color B",
        Default = true,
})
goodColorBToggle:AddColorPicker("GoodFOVColorB", {
        Default = Color3.fromRGB(60, 140, 255),
        Title = "SA2 FOV – Color B",
        Transparency = 0,
})

GoodRageGroup:AddToggle("GoodFOVTracer", {
        Text = "FOV Tracer",
        Default = false,
        Tooltip = "Line from center to target",
})

GoodRageGroup:AddToggle("GoodSilentAimWallCheck", {
        Text = "Wall Check",
        Default = false,
        Tooltip = "Skip targets behind walls (SA2)",
})

GoodRageGroup:AddDivider()
GoodRageGroup:AddLabel("Silent Aim 3 (Good Executor - Alt Hook)")
GoodRageGroup:AddDivider()

GoodRageGroup:AddToggle("Good3SilentAim", {
        Text = "Enable Silent Aim",
        Default = false,
        Tooltip = "Alt Raycast hook with prediction offset",
        Risky = true,
})

GoodRageGroup:AddToggle("Good3UseFOV", {
        Text = "Use FOV",
        Default = true,
        Tooltip = "Only target players inside FOV radius",
})

GoodRageGroup:AddSlider("Good3FOVSlider", {
        Text = "FOV Radius",
        Default = 200,
        Min = 50,
        Max = 800,
        Rounding = 0,
        Suffix = "px",
        Tooltip = "Detection radius from screen center",
})

GoodRageGroup:AddToggle("Good3DrawFOV", {
        Text = "Draw FOV Circle",
        Default = true,
        Tooltip = "Visualize FOV (green)",
})

GoodRageGroup:AddToggle("Good3FOVFill", {
        Text = "FOV Fill (Gradient)",
        Default = false,
        Tooltip = "Fill the FOV circle with an animated gradient",
})

GoodRageGroup:AddToggle("Good3FOVAnimate", {
        Text = "Animate Gradient",
        Default = false,
        Tooltip = "Rotates gradient and pulses transparency",
})

local good3ColorAToggle = GoodRageGroup:AddToggle("Good3FOVColorAEnable", {
        Text = "Color A",
        Default = true,
})
good3ColorAToggle:AddColorPicker("Good3FOVColorA", {
        Default = Color3.fromRGB(80, 255, 120),
        Title = "SA3 FOV – Color A",
        Transparency = 0,
})

local good3ColorBToggle = GoodRageGroup:AddToggle("Good3FOVColorBEnable", {
        Text = "Color B",
        Default = true,
})
good3ColorBToggle:AddColorPicker("Good3FOVColorB", {
        Default = Color3.fromRGB(255, 240, 60),
        Title = "SA3 FOV – Color B",
        Transparency = 0,
})

GoodRageGroup:AddToggle("Good3FOVTracer", {
        Text = "FOV Tracer",
        Default = false,
        Tooltip = "Line from center to target",
})

GoodRageGroup:AddToggle("Good3SilentAimWallCheck", {
        Text = "Wall Check",
        Default = false,
        Tooltip = "Skip targets behind walls (SA3)",
})


Toggles.GoodSilentAim:OnChanged(function()
        if Toggles.GoodSilentAim.Value then
                if Toggles.Good3SilentAim and Toggles.Good3SilentAim.Value then
                        Toggles.Good3SilentAim:SetValue(false)
                        unhookRaycast3()
                        fovTracerLineGood3.Visible = false
                end
                hookRaycast2()
        else
                unhookRaycast2()
                fovTracerLineGood.Visible = false
        end
end)

Toggles.Good3SilentAim:OnChanged(function()
        if Toggles.Good3SilentAim.Value then
                if Toggles.GoodSilentAim and Toggles.GoodSilentAim.Value then
                        Toggles.GoodSilentAim:SetValue(false)
                        unhookRaycast2()
                        fovTracerLineGood.Visible = false
                end
                hookRaycast3()
        else
                unhookRaycast3()
                fovTracerLineGood3.Visible = false
        end
end)


local ESP_COLORS = {
        box       = Color3.fromRGB(255, 255, 255),
        healthHi  = Color3.fromRGB(80, 255, 120),
        healthMid = Color3.fromRGB(255, 210, 50),
        healthLow = Color3.fromRGB(255, 60, 60),
        healthBg  = Color3.fromRGB(20, 20, 20),
        name      = Color3.fromRGB(255, 255, 255),
        distance  = Color3.fromRGB(180, 180, 180),
        skeleton  = Color3.fromRGB(200, 200, 200),
}

local function getHealthColor(hp)
        if hp > 0.6 then return ESP_COLORS.healthHi
        elseif hp > 0.3 then return ESP_COLORS.healthMid
        else return ESP_COLORS.healthLow end
end


local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP", "eye")

ESPGroup:AddToggle("ESPEnabled", {
        Text = "Enable ESP",
        Default = false,
        Tooltip = "Master ESP toggle",
})

ESPGroup:AddToggle("ESPCornerBox", {
        Text = "Corner Box",
        Default = true,
        Tooltip = "2D corner box around players",
})

ESPGroup:AddToggle("ESPFillBox", {
        Text = "Fill Box",
        Default = false,
        Tooltip = "Transparent fill inside the box",
})

ESPGroup:AddToggle("ESPHealthBar", {
        Text = "Health Bar",
        Default = true,
        Tooltip = "Health bar on the left side of box",
})

ESPGroup:AddToggle("ESPName", {
        Text = "Name",
        Default = true,
        Tooltip = "Player name above box",
})

ESPGroup:AddToggle("ESPDistance", {
        Text = "Distance",
        Default = true,
        Tooltip = "Distance below box",
})

ESPGroup:AddToggle("ESPSkeleton", {
        Text = "Skeleton",
        Default = false,
        Tooltip = "Bone lines",
})

ESPGroup:AddToggle("ESPHealthText", {
        Text = "Health Text",
        Default = false,
        Tooltip = "Health % next to bar",
})

ESPGroup:AddToggle("ESPTracers", {
        Text = "Tracers",
        Default = false,
        Tooltip = "Lines from screen edge to players",
})

ESPGroup:AddDropdown("ESPTracerOrigin", {
        Values = { "Bottom", "Center", "Mouse" },
        Default = "Bottom",
        Text = "Tracer Origin",
})

local ESPFiltersGroup = Tabs.ESP:AddRightGroupbox("Filters", "shield")

ESPFiltersGroup:AddToggle("ESPVisibleOnly", {
        Text = "Visible Only",
        Default = false,
        Tooltip = "Only show visible players",
})

ESPFiltersGroup:AddToggle("ESPFriendCheck", {
        Text = "Friend Check",
        Default = false,
        Tooltip = "Hide friends",
})

ESPFiltersGroup:AddToggle("ESPWallCheck", {
        Text = "Wall Check",
        Default = false,
        Tooltip = "Hide players behind walls",
})


local chamCache = {}
local glowCache = {}
local nameTagCache = {}
local headDotCache = {}
local rainbowHue = 0

local function applyChams(player)
        if not player.Character then return end
        if chamCache[player] then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "_Chams"
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = player.Character
        chamCache[player] = highlight
end

local function removeChams(player)
        if chamCache[player] then
                if chamCache[player].Parent then chamCache[player]:Destroy() end
                chamCache[player] = nil
        end
end

local function applyGlow(player)
        if not player.Character then return end
        if glowCache[player] then return end
        glowCache[player] = {}
        for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                        local sel = Instance.new("SelectionBox")
                        sel.Adornee = part
                        sel.Color3 = Color3.fromRGB(255, 100, 0)
                        sel.LineThickness = 0.05
                        sel.SurfaceTransparency = 1
                        sel.Parent = part
                        table.insert(glowCache[player], sel)
                end
        end
end

local function removeGlow(player)
        if glowCache[player] then
                for _, obj in ipairs(glowCache[player]) do
                        if obj and obj.Parent then obj:Destroy() end
                end
                glowCache[player] = nil
        end
end

local function applyRainbowName(player)
        if not player.Character then return end
        if nameTagCache[player] then return end
        local head = player.Character:FindFirstChild("Head")
        if not head then return end
        local bg = Instance.new("BillboardGui")
        bg.Name = "RainbowNameTag"
        bg.Adornee = head
        bg.Size = UDim2.new(0, 200, 0, 30)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.Parent = head
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = player.Name
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.TextStrokeTransparency = 0
        lbl.TextColor3 = Color3.new(1, 0, 0)
        lbl.Parent = bg
        nameTagCache[player] = { gui = bg, label = lbl }
end

local function removeRainbowName(player)
        if nameTagCache[player] then
                if nameTagCache[player].gui and nameTagCache[player].gui.Parent then
                        nameTagCache[player].gui:Destroy()
                end
                nameTagCache[player] = nil
        end
end

local function applyHeadDot(player)
        if not player.Character then return end
        if headDotCache[player] then return end
        local head = player.Character:FindFirstChild("Head")
        if not head then return end
        local att = Instance.new("Attachment")
        att.Position = Vector3.new(0, 0.6, 0)
        att.Parent = head
        local dot = Instance.new("SphereHandleAdornment")
        dot.Adornee = head
        dot.Color3 = Color3.fromRGB(255, 50, 50)
        dot.Radius = 0.12
        dot.AlwaysOnTop = true
        dot.ZIndex = 5
        dot.Parent = head
        headDotCache[player] = { dot = dot, att = att }
end

local function removeHeadDot(player)
        if headDotCache[player] then
                if headDotCache[player].dot and headDotCache[player].dot.Parent then headDotCache[player].dot:Destroy() end
                if headDotCache[player].att and headDotCache[player].att.Parent then headDotCache[player].att:Destroy() end
                headDotCache[player] = nil
        end
end

RunService.Heartbeat:Connect(function()
        rainbowHue = (rainbowHue + 0.005) % 1

        for _, player in ipairs(Players:GetPlayers()) do
                if player == localPlayer then continue end

                if Toggles.ChamEnabled and Toggles.ChamEnabled.Value then
                        if not chamCache[player] then applyChams(player) end
                        local hl = chamCache[player]
                        if hl and hl.Parent then
                                local style = Options.ChamStyle and Options.ChamStyle.Value or "Solid"
                                if style == "Rainbow" then
                                        hl.FillColor = Color3.fromHSV(rainbowHue, 1, 1)
                                        hl.FillTransparency = 0.3
                                        hl.OutlineTransparency = 0
                                elseif style == "Outline Only" then
                                        hl.FillTransparency = 1
                                        hl.OutlineColor = Color3.fromRGB(255, 0, 100)
                                        hl.OutlineTransparency = 0
                                else
                                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                                        hl.FillTransparency = 0.4
                                        hl.OutlineTransparency = 0
                                end
                                hl.DepthMode = (Toggles.ChamWallhack and Toggles.ChamWallhack.Value)
                                        and Enum.HighlightDepthMode.AlwaysOnTop
                                        or Enum.HighlightDepthMode.Occluded
                        end
                else
                        removeChams(player)
                end

                if Toggles.GlowEnabled and Toggles.GlowEnabled.Value then
                        if not glowCache[player] then applyGlow(player) end
                        if glowCache[player] then
                                for _, obj in ipairs(glowCache[player]) do
                                        if obj and obj.Parent then obj.Color3 = Color3.fromHSV(rainbowHue, 1, 1) end
                                end
                        end
                else
                        removeGlow(player)
                end

                if Toggles.RainbowNameEnabled and Toggles.RainbowNameEnabled.Value then
                        if not nameTagCache[player] then applyRainbowName(player) end
                        if nameTagCache[player] and nameTagCache[player].label then
                                nameTagCache[player].label.TextColor3 = Color3.fromHSV(rainbowHue, 1, 1)
                        end
                else
                        removeRainbowName(player)
                end

                if Toggles.HeadDotEnabled and Toggles.HeadDotEnabled.Value then
                        if not headDotCache[player] then applyHeadDot(player) end
                else
                        removeHeadDot(player)
                end
        end
end)

Players.PlayerRemoving:Connect(function(player)
        removeChams(player)
        removeGlow(player)
        removeRainbowName(player)
        removeHeadDot(player)
end)

local function onCharacterAdded(player)
        removeChams(player)
        removeGlow(player)
        removeRainbowName(player)
        removeHeadDot(player)
        removeESP(player)
end

Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
                onCharacterAdded(player)
        end)
end)

for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
                player.CharacterAdded:Connect(function()
                        onCharacterAdded(player)
                end)
        end
end


local function createESP(player)
        if espCache[player] then return end
        local esp = {
                BoxOutline = Drawing.new("Square"),
                Box        = Drawing.new("Square"),
                BoxFill    = Drawing.new("Square"),
                CornerTL_H = Drawing.new("Line"), CornerTL_V = Drawing.new("Line"),
                CornerTR_H = Drawing.new("Line"), CornerTR_V = Drawing.new("Line"),
                CornerBL_H = Drawing.new("Line"), CornerBL_V = Drawing.new("Line"),
                CornerBR_H = Drawing.new("Line"), CornerBR_V = Drawing.new("Line"),
                HealthBarBG      = Drawing.new("Square"),
                HealthBarBGInner = Drawing.new("Square"),
                HealthBar        = Drawing.new("Square"),
                Name       = Drawing.new("Text"),
                Distance   = Drawing.new("Text"),
                HealthText = Drawing.new("Text"),
                Tracer     = Drawing.new("Line"),
                Skeleton   = {},
        }

        esp.BoxOutline.Visible = false
        esp.BoxOutline.Filled = false
        esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        esp.BoxOutline.Thickness = 4
        esp.BoxOutline.Transparency = 0.45

        esp.Box.Visible = false
        esp.Box.Filled = false
        esp.Box.Color = ESP_COLORS.box
        esp.Box.Thickness = 1.5
        esp.Box.Transparency = 1

        esp.BoxFill.Visible = false
        esp.BoxFill.Filled = true
        esp.BoxFill.Color = ESP_COLORS.box
        esp.BoxFill.Thickness = 1
        esp.BoxFill.Transparency = 0.88

        local corners = {esp.CornerTL_H,esp.CornerTL_V,esp.CornerTR_H,esp.CornerTR_V,
                         esp.CornerBL_H,esp.CornerBL_V,esp.CornerBR_H,esp.CornerBR_V}
        for _, l in ipairs(corners) do
                l.Visible = false
                l.Thickness = 2.5
                l.Color = ESP_COLORS.box
                l.Transparency = 1
        end

        esp.HealthBarBG.Visible = false
        esp.HealthBarBG.Filled = true
        esp.HealthBarBG.Color = Color3.fromRGB(0, 0, 0)
        esp.HealthBarBG.Transparency = 0.55

        esp.HealthBarBGInner.Visible = false
        esp.HealthBarBGInner.Filled = true
        esp.HealthBarBGInner.Color = Color3.fromRGB(30, 30, 30)
        esp.HealthBarBGInner.Transparency = 1

        esp.HealthBar.Visible = false
        esp.HealthBar.Filled = true
        esp.HealthBar.Color = ESP_COLORS.healthHi
        esp.HealthBar.Transparency = 1

        esp.Name.Visible = false
        esp.Name.Size = 14
        esp.Name.Center = true
        esp.Name.Outline = true
        esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
        esp.Name.Color = Color3.fromRGB(255, 255, 255)
        esp.Name.Font = 2

        esp.Distance.Visible = false
        esp.Distance.Size = 11
        esp.Distance.Center = true
        esp.Distance.Outline = true
        esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        esp.Distance.Color = Color3.fromRGB(200, 200, 200)
        esp.Distance.Font = 2

        esp.HealthText.Visible = false
        esp.HealthText.Size = 10
        esp.HealthText.Center = false
        esp.HealthText.Outline = true
        esp.HealthText.OutlineColor = Color3.fromRGB(0, 0, 0)
        esp.HealthText.Color = Color3.fromRGB(255, 255, 255)
        esp.HealthText.Font = 2

        esp.Tracer.Visible = false
        esp.Tracer.Thickness = 1
        esp.Tracer.Color = Color3.fromRGB(255, 255, 255)
        esp.Tracer.Transparency = 0.65

        for _, name in ipairs({"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}) do
                local l = Drawing.new("Line")
                l.Visible = false
                l.Thickness = 1.2
                l.Color = ESP_COLORS.skeleton
                l.Transparency = 0.7
                esp.Skeleton[name] = l
        end

        espCache[player] = esp
end

function removeESP(player)
        if not espCache[player] then return end
        local esp = espCache[player]
        esp.BoxOutline:Remove() esp.Box:Remove() esp.BoxFill:Remove()
        esp.CornerTL_H:Remove() esp.CornerTL_V:Remove()
        esp.CornerTR_H:Remove() esp.CornerTR_V:Remove()
        esp.CornerBL_H:Remove() esp.CornerBL_V:Remove()
        esp.CornerBR_H:Remove() esp.CornerBR_V:Remove()
        esp.HealthBarBG:Remove() esp.HealthBarBGInner:Remove() esp.HealthBar:Remove()
        esp.Name:Remove() esp.Distance:Remove() esp.HealthText:Remove() esp.Tracer:Remove()
        for _, l in pairs(esp.Skeleton) do l:Remove() end
        espCache[player] = nil
end

local function hideAllESP(esp)
        esp.BoxOutline.Visible=false esp.Box.Visible=false esp.BoxFill.Visible=false
        esp.CornerTL_H.Visible=false esp.CornerTL_V.Visible=false
        esp.CornerTR_H.Visible=false esp.CornerTR_V.Visible=false
        esp.CornerBL_H.Visible=false esp.CornerBL_V.Visible=false
        esp.CornerBR_H.Visible=false esp.CornerBR_V.Visible=false
        esp.HealthBarBG.Visible=false esp.HealthBarBGInner.Visible=false esp.HealthBar.Visible=false
        esp.Name.Visible=false esp.Distance.Visible=false esp.HealthText.Visible=false esp.Tracer.Visible=false
        for _, l in pairs(esp.Skeleton) do l.Visible=false end
end

local function isESPFriend(player)
        if not Toggles.ESPFriendCheck or not Toggles.ESPFriendCheck.Value then return false end
        return localPlayer:IsFriendsWith(player.UserId)
end

local function isESPWallCheck(player)
        if not Toggles.ESPWallCheck or not Toggles.ESPWallCheck.Value then return false end
        if not player or not player.Character or not player.Character:FindFirstChild("Head") then return true end
        local origin = camera.CFrame.Position
        local direction = player.Character.Head.Position - origin
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {localPlayer.Character, player.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(origin, direction, rayParams)
        return result ~= nil
end

local function updateESP()
        if not Toggles.ESPEnabled or not Toggles.ESPEnabled.Value then
                for _, esp in pairs(espCache) do hideAllESP(esp) end
                return
        end

        for _, player in ipairs(Players:GetPlayers()) do
                if player == localPlayer then continue end
                if not espCache[player] then createESP(player) end
                local esp = espCache[player]
                local character = player.Character
                if not character then hideAllESP(esp) continue end

                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
                if not humanoid or not head or not torso or humanoid.Health <= 0 then hideAllESP(esp) continue end
                if isESPFriend(player) then hideAllESP(esp) continue end
                if isESPWallCheck(player) then hideAllESP(esp) continue end

                local headPos, headVisible = camera:WorldToViewportPoint(head.Position)
                local torsoPos, torsoVisible = camera:WorldToViewportPoint(torso.Position)
                local feetPart = character:FindFirstChild("LeftFoot") or character:FindFirstChild("RightFoot")
                        or character:FindFirstChild("LeftLeg") or character:FindFirstChild("RightLeg")
                local rootPos, _ = camera:WorldToViewportPoint(
                        feetPart and feetPart.Position or (torso.Position - Vector3.new(0, 2.8, 0))
                )
                if not headVisible and not torsoVisible then hideAllESP(esp) continue end

                if Toggles.ESPVisibleOnly and Toggles.ESPVisibleOnly.Value then
                        local rp = RaycastParams.new()
                        rp.FilterDescendantsInstances = {localPlayer.Character, character}
                        rp.FilterType = Enum.RaycastFilterType.Blacklist
                        if workspace:Raycast(camera.CFrame.Position, head.Position - camera.CFrame.Position, rp) then
                                hideAllESP(esp) continue
                        end
                end

                local topY    = (headVisible and headPos.Y or torsoPos.Y) - 6
                local bottomY = rootPos.Y + 4
                local height  = math.max(math.abs(bottomY - topY), 1)
                local width   = height * 0.6
                local centerX = (headVisible and headPos.X or torsoPos.X)
                local boxLeft  = centerX - width / 2
                local boxRight = centerX + width / 2
                local boxTop   = topY
                local boxBot   = bottomY

                local hp = humanoid.Health / humanoid.MaxHealth
                local healthColor = getHealthColor(hp)
                local barH = height * hp
                local barLeft  = boxLeft - 6
                local barRight = barLeft + 4

                esp.BoxOutline.Size     = Vector2.new(width + 2, height + 2)
                esp.BoxOutline.Position = Vector2.new(boxLeft - 1, boxTop - 1)
                esp.BoxOutline.Visible  = Toggles.ESPCornerBox and Toggles.ESPCornerBox.Value

                esp.Box.Size     = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(boxLeft, boxTop)
                esp.Box.Visible  = false

                esp.BoxFill.Size     = Vector2.new(width, height)
                esp.BoxFill.Position = Vector2.new(boxLeft, boxTop)
                esp.BoxFill.Visible  = Toggles.ESPFillBox and Toggles.ESPFillBox.Value

                if Toggles.ESPCornerBox and Toggles.ESPCornerBox.Value then
                        local cLen = width * 0.25
                        local cLenH = height * 0.2
                        esp.CornerTL_H.From=Vector2.new(boxLeft,boxTop)        esp.CornerTL_H.To=Vector2.new(boxLeft+cLen,boxTop)
                        esp.CornerTL_V.From=Vector2.new(boxLeft,boxTop)        esp.CornerTL_V.To=Vector2.new(boxLeft,boxTop+cLenH)
                        esp.CornerTR_H.From=Vector2.new(boxRight,boxTop)       esp.CornerTR_H.To=Vector2.new(boxRight-cLen,boxTop)
                        esp.CornerTR_V.From=Vector2.new(boxRight,boxTop)       esp.CornerTR_V.To=Vector2.new(boxRight,boxTop+cLenH)
                        esp.CornerBL_H.From=Vector2.new(boxLeft,boxBot)        esp.CornerBL_H.To=Vector2.new(boxLeft+cLen,boxBot)
                        esp.CornerBL_V.From=Vector2.new(boxLeft,boxBot)        esp.CornerBL_V.To=Vector2.new(boxLeft,boxBot-cLenH)
                        esp.CornerBR_H.From=Vector2.new(boxRight,boxBot)       esp.CornerBR_H.To=Vector2.new(boxRight-cLen,boxBot)
                        esp.CornerBR_V.From=Vector2.new(boxRight,boxBot)       esp.CornerBR_V.To=Vector2.new(boxRight,boxBot-cLenH)
                        for _, c in ipairs({esp.CornerTL_H,esp.CornerTL_V,esp.CornerTR_H,esp.CornerTR_V,
                                            esp.CornerBL_H,esp.CornerBL_V,esp.CornerBR_H,esp.CornerBR_V}) do
                                c.Visible = true
                        end
                else
                        for _, c in ipairs({esp.CornerTL_H,esp.CornerTL_V,esp.CornerTR_H,esp.CornerTR_V,
                                            esp.CornerBL_H,esp.CornerBL_V,esp.CornerBR_H,esp.CornerBR_V}) do
                                c.Visible = false
                        end
                end

                if Toggles.ESPHealthBar and Toggles.ESPHealthBar.Value then
                        esp.HealthBarBG.Size     = Vector2.new(4, height + 2)
                        esp.HealthBarBG.Position = Vector2.new(barLeft, boxTop - 1)
                        esp.HealthBarBG.Visible  = true
                        esp.HealthBarBGInner.Size     = Vector2.new(2, height)
                        esp.HealthBarBGInner.Position = Vector2.new(barLeft + 1, boxTop)
                        esp.HealthBarBGInner.Visible  = true
                        esp.HealthBar.Size     = Vector2.new(2, barH)
                        esp.HealthBar.Position = Vector2.new(barLeft + 1, boxBot - barH)
                        esp.HealthBar.Color    = healthColor
                        esp.HealthBar.Visible  = true
                else
                        esp.HealthBarBG.Visible=false esp.HealthBarBGInner.Visible=false esp.HealthBar.Visible=false
                end

                if Toggles.ESPName and Toggles.ESPName.Value then
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(centerX, boxTop - 16)
                        esp.Name.Visible = true
                else esp.Name.Visible = false end

                if Toggles.ESPDistance and Toggles.ESPDistance.Value then
                        local myChar = localPlayer.Character
                        local dist = 0
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                dist = math.floor((myChar.HumanoidRootPart.Position - torso.Position).Magnitude)
                        end
                        esp.Distance.Text = dist .. "m"
                        esp.Distance.Position = Vector2.new(centerX, boxBot + 2)
                        esp.Distance.Visible = true
                else esp.Distance.Visible = false end

                if Toggles.ESPHealthText and Toggles.ESPHealthText.Value then
                        esp.HealthText.Text = math.floor(hp * 100) .. "%"
                        esp.HealthText.Color = healthColor
                        esp.HealthText.Position = Vector2.new(boxRight + 4, boxTop)
                        esp.HealthText.Visible = true
                else esp.HealthText.Visible = false end

                if Toggles.ESPTracers and Toggles.ESPTracers.Value then
                        local orig = Options.ESPTracerOrigin and Options.ESPTracerOrigin.Value or "Bottom"
                        local tracerOrigin
                        if orig == "Bottom" then tracerOrigin = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        elseif orig == "Center" then tracerOrigin = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                        else tracerOrigin = UserInputService:GetMouseLocation() end
                        esp.Tracer.From = tracerOrigin
                        esp.Tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                        esp.Tracer.Color = healthColor
                        esp.Tracer.Visible = true
                else esp.Tracer.Visible = false end

                if Toggles.ESPSkeleton and Toggles.ESPSkeleton.Value then
                        local function getBonePos(n)
                                local part = character:FindFirstChild(n)
                                if part then local p,v = camera:WorldToViewportPoint(part.Position) return Vector2.new(p.X,p.Y),v end
                                return nil,false
                        end
                        local hBP,hBV = getBonePos("Head")
                        local tP2,tV2 = getBonePos("HumanoidRootPart")
                        if not tP2 then tP2,tV2 = getBonePos("Torso") end
                        local lAP,lAV = getBonePos("LeftUpperArm") if not lAP then lAP,lAV = getBonePos("Left Arm") end
                        local rAP,rAV = getBonePos("RightUpperArm") if not rAP then rAP,rAV = getBonePos("Right Arm") end
                        local lLP,lLV = getBonePos("LeftUpperLeg") if not lLP then lLP,lLV = getBonePos("Left Leg") end
                        local rLP,rLV = getBonePos("RightUpperLeg") if not rLP then rLP,rLV = getBonePos("Right Leg") end
                        local function setLine(line, from, to, v1, v2)
                                if from and to and v1 and v2 then line.From=from line.To=to line.Visible=true
                                else line.Visible=false end
                        end
                        setLine(esp.Skeleton["Head"],hBP,tP2,hBV,tV2)
                        setLine(esp.Skeleton["Left Arm"],tP2,lAP,tV2,lAV)
                        setLine(esp.Skeleton["Right Arm"],tP2,rAP,tV2,rAV)
                        setLine(esp.Skeleton["Left Leg"],tP2,lLP,tV2,lLV)
                        setLine(esp.Skeleton["Right Leg"],tP2,rLP,tV2,rLV)
                else
                        for _, l in pairs(esp.Skeleton) do l.Visible=false end
                end
        end
end

RunService.RenderStepped:Connect(updateESP)
Players.PlayerRemoving:Connect(removeESP)


local PlayerVisualsGroup = Tabs.Visual:AddLeftGroupbox("Player Visuals", "star")

PlayerVisualsGroup:AddToggle("ChamEnabled", {
        Text = "Chams",
        Default = false,
        Tooltip = "Highlight players with color",
})

PlayerVisualsGroup:AddDropdown("ChamStyle", {
        Values = { "Solid", "Outline Only", "Rainbow" },
        Default = "Solid",
        Text = "Chams Style",
})

PlayerVisualsGroup:AddToggle("ChamWallhack", {
        Text = "Visible Through Walls",
        Default = false,
        Tooltip = "See chams through walls",
})

PlayerVisualsGroup:AddToggle("GlowEnabled", {
        Text = "Glow (SelectionBox)",
        Default = false,
        Tooltip = "Rainbow glow outline",
})

PlayerVisualsGroup:AddToggle("RainbowNameEnabled", {
        Text = "Rainbow Name Tag",
        Default = false,
        Tooltip = "Animated rainbow name overhead",
})

PlayerVisualsGroup:AddToggle("HeadDotEnabled", {
        Text = "Head Dot",
        Default = false,
        Tooltip = "Small dot above enemy head",
})

PlayerVisualsGroup:AddDivider()

PlayerVisualsGroup:AddToggle("Crosshair", {
        Text = "Custom Crosshair",
        Default = false,
        Tooltip = "Draw a custom crosshair on screen",
})

PlayerVisualsGroup:AddDropdown("CrosshairStyle", {
        Values = { "Spinner", "Dot", "Cross", "Circle" },
        Default = "Spinner",
        Text = "Crosshair Style",
})

PlayerVisualsGroup:AddSlider("CrosshairSize", {
        Text = "Crosshair Size",
        Default = 14,
        Min = 5,
        Max = 40,
        Rounding = 0,
        Tooltip = "Radius / length of crosshair",
})

PlayerVisualsGroup:AddSlider("CrosshairSpinSpeed", {
        Text = "Spin Speed",
        Default = 2,
        Min = 0,
        Max = 10,
        Rounding = 1,
        Tooltip = "How fast the crosshair spins (0 = no spin)",
})

PlayerVisualsGroup:AddDropdown("CrosshairColor", {
        Values = { "White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Pink" },
        Default = "White",
        Text = "Crosshair Color",
})

PlayerVisualsGroup:AddToggle("CrosshairGradient", {
        Text = "Rainbow Gradient",
        Default = false,
        Tooltip = "Each arm of the crosshair cycles through rainbow colors",
})

PlayerVisualsGroup:AddToggle("CrosshairShowFPS", {
        Text = "Show FPS Counter",
        Default = false,
        Tooltip = "Displays your current FPS below the crosshair",
})

PlayerVisualsGroup:AddToggle("CrosshairShowLabel", {
        Text = "Show \"Xeioa\" Label",
        Default = false,
        Tooltip = "Displays the text Xeioa below the crosshair",
})


local stretchResConn = nil

RunService.RenderStepped:Connect(function()
        if not Toggles.StretchRes or not Toggles.StretchRes.Value then return end
        local res = (Options.StretchResValue and Options.StretchResValue.Value or 80) / 100
        camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, res, 0, 0, 0, 1)
end)

PlayerVisualsGroup:AddDivider()

PlayerVisualsGroup:AddToggle("StretchRes", {
        Text = "Stretch Resolution",
        Default = false,
        Tooltip = "Squishes vertical FOV for a stretched-res look",
})

PlayerVisualsGroup:AddSlider("StretchResValue", {
        Text = "Stretch Amount",
        Default = 80,
        Min = 30,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
        Tooltip = "100% = normal, lower = more stretched",
})


local HitmarkerGroup = Tabs.Visual:AddRightGroupbox("Hitmarker", "target")

HitmarkerGroup:AddToggle("HitmarkerEnabled", {
        Text = "Enable Hitmarker",
        Default = false,
        Tooltip = "Shows a hitmarker cross when you deal damage",
})

HitmarkerGroup:AddSlider("HitmarkerSize", {
        Text = "Hitmarker Size",
        Default = 36,
        Min = 10,
        Max = 80,
        Rounding = 0,
        Suffix = "px",
        Tooltip = "Size of the hitmarker cross",
        Callback = function(Value) hitmarker._size = Value end,
})

HitmarkerGroup:AddSlider("HitmarkerThickness", {
        Text = "Line Thickness",
        Default = 2,
        Min = 1,
        Max = 6,
        Rounding = 0,
        Suffix = "px",
        Tooltip = "Thickness of each hitmarker line",
        Callback = function(Value) hitmarker._thickness = Value end,
})

HitmarkerGroup:AddSlider("HitmarkerDuration", {
        Text = "Duration",
        Default = 10,
        Min = 2,
        Max = 30,
        Rounding = 0,
        Suffix = "x0.01s",
        Tooltip = "How long the hitmarker stays visible",
        Callback = function(Value) hitmarker._duration = Value * 0.01 end,
})

HitmarkerGroup:AddDivider()

HitmarkerGroup:AddToggle("HitNotify", {
        Text = "Hit Notification",
        Default = false,
        Tooltip = "Shows a notification with player name and damage dealt",
})

HitmarkerGroup:AddToggle("DamageIndicator", {
        Text = "Damage Indicator",
        Default = false,
        Tooltip = "Floating damage number at the hit player position",
})


local MovementGroup = Tabs.Movement:AddLeftGroupbox("Speed", "move")

MovementGroup:AddToggle("CFrameSpeed", {
        Text = "CFrame Speed",
        Default = false,
        Tooltip = "Speed via CFrame (bypasses anti-cheat)",
})

MovementGroup:AddSlider("CFrameSpeedValue", {
        Text = "Speed Value",
        Default = 0.5,
        Min = 0.1,
        Max = 2,
        Rounding = 1,
        Suffix = "",
        Tooltip = "CFrame speed multiplier",
})

local cframeSpeedConnection = nil

local function startCFrameSpeed()
        if cframeSpeedConnection then cframeSpeedConnection:Disconnect() end
        cframeSpeedConnection = RunService.Heartbeat:Connect(function()
                if not Toggles.CFrameSpeed or not Toggles.CFrameSpeed.Value then return end
                local character = localPlayer.Character
                if not character then return end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                if humanoid.MoveDirection.Magnitude > 0 then
                        local speed = Options.CFrameSpeedValue and Options.CFrameSpeedValue.Value or 0.5
                        hrp.CFrame = hrp.CFrame + humanoid.MoveDirection * speed
                end
        end)
end

Toggles.CFrameSpeed:OnChanged(function()
        if Toggles.CFrameSpeed.Value then startCFrameSpeed() end
end)

MovementGroup:AddToggle("InfiniteJump", {
        Text = "Infinite Jump",
        Default = false,
        Tooltip = "Jump infinitely mid-air",
})

UserInputService.JumpRequest:Connect(function()
        if Toggles.InfiniteJump and Toggles.InfiniteJump.Value then
                local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
end)

MovementGroup:AddToggle("NoClip", {
        Text = "NoClip",
        Default = false,
        Tooltip = "Walk through walls",
})

RunService.Stepped:Connect(function()
        if Toggles.NoClip and Toggles.NoClip.Value then
                local character = localPlayer.Character
                if character then
                        for _, v in pairs(character:GetDescendants()) do
                                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                        end
                end
        end
end)

local FlyGroup = Tabs.Movement:AddRightGroupbox("Fly", "plane")

FlyGroup:AddToggle("CFrameFly", {
        Text = "CFrame Fly",
        Default = false,
        Tooltip = "Fly with WASD/Space/Shift (PC) or thumbstick + on-screen buttons (mobile)",
})

FlyGroup:AddSlider("CFrameFlySpeed", {
        Text = "Fly Speed",
        Default = 2,
        Min = 0.5,
        Max = 10,
        Rounding = 1,
        Suffix = "",
        Tooltip = "Fly speed multiplier",
})

local flyConnection = nil

local function stopFly()
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        local character = localPlayer.Character
        if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.PlatformStand = false end
        end
end

local function startCFrameFly()
        stopFly()
        local character = localPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = true end

        flyConnection = RunService.Heartbeat:Connect(function()
                if not Toggles.CFrameFly or not Toggles.CFrameFly.Value then stopFly() return end
                local char = localPlayer.Character
                if not char then return end
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                local speed = Options.CFrameFlySpeed and Options.CFrameFlySpeed.Value or 2
                local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
                local moveDir = Vector3.new(0, 0, 0)

                if isMobile then


                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.MoveDirection.Magnitude > 0 then
                                local md = hum.MoveDirection

                                local flatFwd   = Vector3.new(camera.CFrame.LookVector.X,  0, camera.CFrame.LookVector.Z)
                                local flatRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
                                if flatFwd.Magnitude   > 0.01 then flatFwd   = flatFwd.Unit   end
                                if flatRight.Magnitude > 0.01 then flatRight = flatRight.Unit end

                                local stickFwd   = flatFwd:Dot(md)
                                local stickRight = flatRight:Dot(md)

                                moveDir = camera.CFrame.LookVector * stickFwd
                                        + camera.CFrame.RightVector * stickRight
                        end
                else

                        local camLook  = camera.CFrame.LookVector
                        local camRight = camera.CFrame.RightVector
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camLook end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camLook end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camRight end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camRight end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                end

                if moveDir.Magnitude > 0 then
                        rootPart.CFrame = rootPart.CFrame + moveDir.Unit * speed
                end
                rootPart.Velocity = Vector3.new(0, 0, 0)
        end)
end

Toggles.CFrameFly:OnChanged(function()
        if Toggles.CFrameFly.Value then startCFrameFly() else stopFly() end
end)

localPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if Toggles.CFrameFly and Toggles.CFrameFly.Value then startCFrameFly() end
        if Toggles.CFrameSpeed and Toggles.CFrameSpeed.Value then startCFrameSpeed() end
end)


local MiscGroup = Tabs.Misc:AddLeftGroupbox("Performance", "zap")

local fpsBoostEnabled = false
local originalSettings = {}

MiscGroup:AddToggle("FPSBoost", {
        Text = "FPS Boost",
        Default = false,
        Tooltip = "Disables shadows, effects and lowers quality for more FPS",
        Callback = function(Value)
                fpsBoostEnabled = Value
                if Value then
                        originalSettings.Shadows = Lighting.GlobalShadows
                        originalSettings.Brightness = Lighting.Brightness
                        originalSettings.Fog = Lighting.FogEnd
                        Lighting.GlobalShadows = false
                        Lighting.Brightness = 2
                        Lighting.FogEnd = 100000
                        for _, v in pairs(Workspace:GetDescendants()) do
                                if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                                        if not v:GetAttribute("OriginalMaterial") then v:SetAttribute("OriginalMaterial", v.Material.Name) end
                                        v.Material = Enum.Material.Plastic
                                end
                                if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
                                if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                                        if not v:GetAttribute("OriginalEnabled") then v:SetAttribute("OriginalEnabled", v.Enabled) end
                                        v.Enabled = false
                                end
                        end
                        for _, v in pairs(Lighting:GetChildren()) do
                                if v:IsA("PostEffect") then
                                        if not v:GetAttribute("OriginalEnabled") then v:SetAttribute("OriginalEnabled", v.Enabled) end
                                        v.Enabled = false
                                end
                        end
                        settings().Rendering.QualityLevel = 1
                else
                        Lighting.GlobalShadows = originalSettings.Shadows ~= nil and originalSettings.Shadows or true
                        Lighting.Brightness = originalSettings.Brightness or 1
                        Lighting.FogEnd = originalSettings.Fog or 1000
                        for _, v in pairs(Workspace:GetDescendants()) do
                                if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                                        local mat = v:GetAttribute("OriginalMaterial")
                                        if mat then v.Material = Enum.Material[mat] end
                                end
                                if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
                                if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                                        local en = v:GetAttribute("OriginalEnabled")
                                        if en ~= nil then v.Enabled = en end
                                end
                        end
                        for _, v in pairs(Lighting:GetChildren()) do
                                if v:IsA("PostEffect") then
                                        local en = v:GetAttribute("OriginalEnabled")
                                        if en ~= nil then v.Enabled = en end
                                end
                        end
                end
        end,
})

MiscGroup:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
        Tooltip = "Makes everything bright",
        Callback = function(Value)
                if Value then
                        Lighting.Brightness = 10
                        Lighting.GlobalShadows = false
                else
                        if not fpsBoostEnabled then
                                Lighting.Brightness = 1
                                Lighting.GlobalShadows = true
                        end
                end
        end,
})

MiscGroup:AddToggle("NoFog", {
        Text = "No Fog",
        Default = false,
        Tooltip = "Removes fog",
        Callback = function(Value)
                if Value then Lighting.FogEnd = 100000
                else if not fpsBoostEnabled then Lighting.FogEnd = 1000 end end
        end,
})

MiscGroup:AddToggle("AntiLag", {
        Text = "Anti Lag",
        Default = false,
        Tooltip = "Removes particles, smoke and fire to reduce lag",
        Callback = function(Value)
                if Value then
                        for _, v in pairs(Workspace:GetDescendants()) do
                                if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v:Destroy() end
                        end
                end
        end,
})

MiscGroup:AddSlider("FPSCap", {
        Text = "FPS Cap",
        Default = 60,
        Min = 30,
        Max = 240,
        Rounding = 0,
        Suffix = " FPS",
        Tooltip = "Set maximum FPS",
        Callback = function(Value) setfpscap(Value) end,
})

MiscGroup:AddSlider("CameraFOV", {
        Text = "Camera FOV",
        Default = 70,
        Min = 30,
        Max = 240,
        Rounding = 0,
        Suffix = "°",
        Tooltip = "Change camera field of view",
        Callback = function(Value) camera.FieldOfView = Value end,
})


local MiscGroup2 = Tabs.Misc:AddRightGroupbox("World", "globe")

local skyPresets = {
        ["Default"]    = nil,
        ["Night"]      = { SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454296", SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454286", SkyboxRt = "rbxassetid://159454300", SkyboxUp = "rbxassetid://159454302" },
        ["Bliss"]      = { SkyboxBk = "rbxassetid://1012397662", SkyboxDn = "rbxassetid://1012397662", SkyboxFt = "rbxassetid://1012397662", SkyboxLf = "rbxassetid://1012397662", SkyboxRt = "rbxassetid://1012397662", SkyboxUp = "rbxassetid://1012397662" },
        ["Space"]      = { SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454296", SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454286", SkyboxRt = "rbxassetid://159454300", SkyboxUp = "rbxassetid://159454302" },
        ["Sunset"]     = { SkyboxBk = "rbxassetid://134116399", SkyboxDn = "rbxassetid://134116399", SkyboxFt = "rbxassetid://134116399", SkyboxLf = "rbxassetid://134116399", SkyboxRt = "rbxassetid://134116399", SkyboxUp = "rbxassetid://134116399" },
}

local originalSky = nil

local function applySky(presetName)
        if presetName == "Default" then
                if originalSky then
                        originalSky.Parent = Lighting
                        originalSky = nil
                end
                return
        end
        local preset = skyPresets[presetName]
        if not preset then return end
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if not sky then
                sky = Instance.new("Sky")
                sky.Parent = Lighting
        else
                if not originalSky then
                        originalSky = sky:Clone()
                        originalSky.Parent = nil
                end
        end
        for prop, val in pairs(preset) do
                pcall(function() sky[prop] = val end)
        end
end

MiscGroup2:AddDropdown("SkyPreset", {
        Values = { "Default", "Night", "Bliss", "Space", "Sunset" },
        Default = "Default",
        Text = "Sky Preset",
        Tooltip = "Change the game sky",
        Callback = function(Value) applySky(Value) end,
})

MiscGroup2:AddSlider("TimeOfDay", {
        Text = "Time of Day",
        Default = 14,
        Min = 0,
        Max = 24,
        Rounding = 1,
        Suffix = "h",
        Tooltip = "Set the game time (0 = midnight, 12 = noon)",
        Callback = function(Value)
                Lighting.ClockTime = Value
        end,
})

MiscGroup2:AddToggle("RainbowSky", {
        Text = "Rainbow Lighting",
        Default = false,
        Tooltip = "Ambient and outlines cycle through rainbow colors",
})

local rainbowSkyHue = 0
RunService.Heartbeat:Connect(function()
        if Toggles.RainbowSky and Toggles.RainbowSky.Value then
                rainbowSkyHue = (rainbowSkyHue + 0.002) % 1
                Lighting.Ambient = Color3.fromHSV(rainbowSkyHue, 0.6, 1)
                Lighting.OutdoorAmbient = Color3.fromHSV((rainbowSkyHue + 0.5) % 1, 0.6, 1)
        end
end)

MiscGroup2:AddDivider()

MiscGroup2:AddButton("Rejoin Server", function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, localPlayer)
end)

MiscGroup2:AddButton("Server Hop", function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(req)
        for _, server in pairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                end
        end
        if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], localPlayer)
        end
end)

MiscGroup2:AddButton("Reset Character", function()
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Health = 0 end
end)


local gunHookOld = nil
local gunHookActive = false

local function applyGunHook()
        if gunHookActive then return end
        local ok, clientItemModule = pcall(function()
                return require(
                        Players.LocalPlayer
                        .PlayerScripts
                        .Modules
                        .ClientReplicatedClasses
                        .ClientFighter
                        .ClientItem
                )
        end)
        if not ok or not clientItemModule then return end
        local inputFunc = clientItemModule.Input
        if not inputFunc then return end
        gunHookOld = hookfunction(inputFunc, function(...)
                local args = {...}
                if type(args[1]) == "table" and args[1].Info then
                        if Toggles.GunNoRecoil and Toggles.GunNoRecoil.Value then
                                args[1].Info.ShootRecoil = 0
                        end
                        if Toggles.GunNoSpread and Toggles.GunNoSpread.Value then
                                args[1].Info.ShootSpread = 0
                        end
                        if Toggles.GunInstantProjectile and Toggles.GunInstantProjectile.Value then
                                args[1].Info.ProjectileSpeed = 99999999
                        end
                        if Toggles.GunNoCooldown and Toggles.GunNoCooldown.Value then
                                args[1].Info.ShootCooldown = 0
                                args[1].Info.QuickShotCooldown = 0
                        end
                end
                return gunHookOld(...)
        end)
        gunHookActive = true
end

local function removeGunHook()
        if not gunHookActive or not gunHookOld then return end
        local ok, clientItemModule = pcall(function()
                return require(
                        Players.LocalPlayer
                        .PlayerScripts
                        .Modules
                        .ClientReplicatedClasses
                        .ClientFighter
                        .ClientItem
                )
        end)
        if ok and clientItemModule and clientItemModule.Input then
                hookfunction(clientItemModule.Input, gunHookOld)
        end
        gunHookOld = nil
        gunHookActive = false
end


local GunGroup = Tabs.Gun:AddLeftGroupbox("Gun Mods", "zap")

GunGroup:AddLabel("Requires hookfunction (good executor)")
GunGroup:AddDivider()

GunGroup:AddToggle("GunModsEnabled", {
        Text = "Enable Gun Mods",
        Default = false,
        Tooltip = "Hooks ClientItem.Input to apply all active gun mods",
        Risky = true,
        Callback = function(Value)
                if Value then applyGunHook() else removeGunHook() end
        end,
})

GunGroup:AddDivider()

GunGroup:AddToggle("GunNoRecoil", {
        Text = "No Recoil",
        Default = true,
        Tooltip = "Sets ShootRecoil to 0",
})

GunGroup:AddToggle("GunNoSpread", {
        Text = "No Spread",
        Default = true,
        Tooltip = "Sets ShootSpread to 0",
})

GunGroup:AddToggle("GunInstantProjectile", {
        Text = "Instant Projectile",
        Default = true,
        Tooltip = "Sets ProjectileSpeed to 99999999 (instant hit)",
})

GunGroup:AddToggle("GunNoCooldown", {
        Text = "No Cooldown",
        Default = false,
        Tooltip = "Sets ShootCooldown and QuickShotCooldown to 0",
        Risky = true,
})


local triggerbotActive = false
local triggerbotConnection = nil

local function startTriggerbot()
        if triggerbotConnection then triggerbotConnection:Disconnect() end
        triggerbotConnection = RunService.Heartbeat:Connect(function()
                if not Toggles.Triggerbot or not Toggles.Triggerbot.Value then return end
                local char = localPlayer.Character
                if not char then return end
                local mousePos = UserInputService:GetMouseLocation()
                local unitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, rayParams)
                if result and result.Instance then
                        local hitPart = result.Instance
                        local hitChar = hitPart.Parent
                        local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
                        if hitPlayer and hitPlayer ~= localPlayer then
                                if Toggles.TriggerbotFriendCheck and Toggles.TriggerbotFriendCheck.Value then
                                        if pcall(function() return localPlayer:IsFriendsWith(hitPlayer.UserId) end) then
                                                if localPlayer:IsFriendsWith(hitPlayer.UserId) then return end
                                        end
                                end
                                local partTarget = Options.TriggerbotPart and Options.TriggerbotPart.Value or "Head"
                                local validHit = false
                                if partTarget == "All" then
                                        validHit = true
                                elseif partTarget == "Head" then
                                        validHit = hitPart.Name == "Head"
                                elseif partTarget == "HumanoidRootPart" then
                                        validHit = hitPart.Name == "HumanoidRootPart"
                                end
                                if validHit then
                                        pcall(function() mouse1click() end)
                                end
                        end
                end
        end)
end


local TriggerbotGroup = Tabs.Legit:AddLeftGroupbox("Triggerbot", "target")

TriggerbotGroup:AddToggle("Triggerbot", {
        Text = "Enable Triggerbot",
        Default = false,
        Tooltip = "Auto-clicks when your crosshair is over a player",
        Risky = true,
        Callback = function(Value)
                if Value then startTriggerbot() else
                        if triggerbotConnection then triggerbotConnection:Disconnect() end
                end
        end,
})

TriggerbotGroup:AddDropdown("TriggerbotPart", {
        Values = { "Head", "HumanoidRootPart", "All" },
        Default = "Head",
        Text = "Target Part",
        Tooltip = "Which body part activates the trigger",
})

TriggerbotGroup:AddToggle("TriggerbotFriendCheck", {
        Text = "Friend Check",
        Default = false,
        Tooltip = "Skip friends",
})


local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
        Default = Library.KeybindFrame.Visible,
        Text = "Open Keybind Menu",
        Callback = function(value) Library.KeybindFrame.Visible = value end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor",
        Default = true,
        Callback = function(Value) Library.ShowCustomCursor = Value end,
})

MenuGroup:AddDropdown("NotificationSide", {
        Values = { "Left", "Right" },
        Default = "Right",
        Text = "Notification Side",
        Callback = function(Value) Library:SetNotifySide(Value) end,
})

MenuGroup:AddDropdown("DPIDropdown", {
        Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
        Default = "100%",
        Text = "DPI Scale",
        Callback = function(Value)
                Value = Value:gsub("%%", "")
                Library:SetDPIScale(tonumber(Value))
        end,
})

MenuGroup:AddSlider("UICornerSlider", {
        Text = "Corner Radius",
        Default = Library.CornerRadius,
        Min = 0,
        Max = 20,
        Rounding = 0,
        Callback = function(value) Window:SetCornerRadius(value) end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
        :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddDivider()

MenuGroup:AddToggle("ShowWatermark", {
        Text = "Watermark",
        Default = false,
        Tooltip = "XeioaHub - FreeVersion | FPS | Ping | Username",
        Callback = function(value)
                DraggableLabel:SetVisible(value)
        end,
})

MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/rivals")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()


local DraggableLabel = Library:AddDraggableLabel("XeioaHub - FreeVersion")
DraggableLabel:SetVisible(false)

local wmTimer = tick()
local wmFrameCount = 0
local wmFPS = 60

RunService.RenderStepped:Connect(function()
        wmFrameCount = wmFrameCount + 1
        if (tick() - wmTimer) >= 1 then
                wmFPS = wmFrameCount
                wmTimer = tick()
                wmFrameCount = 0
        end
        if not (Toggles.ShowWatermark and Toggles.ShowWatermark.Value) then return end
        local ping = 0
        pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        DraggableLabel:SetText(
                ("XeioaHub - FreeVersion  |  %d fps  |  %d ms  |  %s"):format(
                        math.floor(wmFPS),
                        ping,
                        localPlayer.Name
                )
        )
end)


Library:OnUnload(function()
        for player, _ in pairs(espCache) do removeESP(player) end
        for player, _ in pairs(chamCache) do removeChams(player) end
        for player, _ in pairs(glowCache) do removeGlow(player) end
        for player, _ in pairs(nameTagCache) do removeRainbowName(player) end
        for player, _ in pairs(headDotCache) do removeHeadDot(player) end
        fovCircle:Remove()
        fovTracerLine:Remove()
        fovCircleGood:Remove()
        fovTracerLineGood:Remove()
        fovCircleGood3:Remove()
        fovTracerLineGood3:Remove()
        crosshairDot:Remove()
        for _, l in ipairs(crosshairLines) do l:Remove() end
        crosshairLabel:Remove()
        crosshairFPS:Remove()
        pcall(function() fovFillGui:Destroy() end)
        unhookRaycast2()
        unhookRaycast3()
        removeGunHook()
        if triggerbotConnection then triggerbotConnection:Disconnect() end
        stopFly()
        if cframeSpeedConnection then cframeSpeedConnection:Disconnect() end
end)
