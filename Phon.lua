-- ================== BIẾN ==================
_G.AutoFarm = false
_G.AutoLevel = false
_G.FastAttack = false

_G.SelectedMob = ""

-- ================== SERVICES ==================
local TweenService = game:GetService("TweenService")

-- ================== SAFE CHARACTER ==================
function GetChar()
    local player = game.Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

-- ================== CHECK MOB ==================
function IsRealMob(v)
    if not v:IsA("Model") then return false end

    local hum = v:FindFirstChild("Humanoid")
    local root = v:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return false end

    -- bỏ player
    if game.Players:GetPlayerFromCharacter(v) then return false end

    local name = v.Name:lower()

    -- ❌ bỏ NPC shop / bán kiếm
    if string.find(name,"shop") 
    or string.find(name,"seller") 
    or string.find(name,"weapon") 
    or string.find(name,"sword") 
    or string.find(name,"store") 
    or string.find(name,"blacksmith") then
        return false
    end

    -- ❌ có prompt → thường là NPC
    if v:FindFirstChildOfClass("ProximityPrompt") then
        return false
    end

    if hum.Health <= 0 then return false end
    if hum.WalkSpeed == 0 then return false end

    return true
end

-- ================== BAY MƯỢT ==================
function FlyToTargetSmooth(target)
    local char = GetChar()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetPos = target.HumanoidRootPart.Position + Vector3.new(0, 7, 4)

    local distance = (root.Position - targetPos).Magnitude
    local speed = 100
    local time = distance / speed

    local tween = TweenService:Create(
        root,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPos)}
    )

    tween:Play()
    tween.Completed:Wait()
end

-- ================== AUTO REACT HIT ==================
function AutoReactHit()
    local char = GetChar()
    local hum = char:FindFirstChild("Humanoid")

    if not hum then return end

    hum.HealthChanged:Connect(function()
        if _G.AutoFarm or _G.AutoLevel then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end)
end

AutoReactHit()

-- ================== AUTO FARM ==================
function AutoFarmLegit()
    if _G.RunningFarm then return end
    _G.RunningFarm = true

    spawn(function()
        while _G.AutoFarm do
            task.wait(math.random(4,7)/10)

            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local nearest, dist = nil, math.huge

            for _,v in pairs(workspace:GetDescendants()) do
                if IsRealMob(v) and v.Name == _G.SelectedMob then
                    local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
                    if d < dist and d < 300 then
                        dist = d
                        nearest = v
                    end
                end
            end

            if nearest then
                FlyToTargetSmooth(nearest)

                root.CFrame = CFrame.new(root.Position, nearest.HumanoidRootPart.Position)

                task.wait(0.2)

                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end

        _G.RunningFarm = false
    end)
end

-- ================== AUTO LEVEL ==================
function AutoLevel()
    if _G.RunningLevel then return end
    _G.RunningLevel = true

    spawn(function()
        while _G.AutoLevel do
            task.wait(math.random(4,7)/10)

            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local nearest, dist = nil, math.huge

            for _,v in pairs(workspace:GetDescendants()) do
                if IsRealMob(v) then
                    local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
                    if d < dist and d < 300 then
                        dist = d
                        nearest = v
                    end
                end
            end

            if nearest then
                FlyToTargetSmooth(nearest)

                root.CFrame = CFrame.new(root.Position, nearest.HumanoidRootPart.Position)

                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end

        _G.RunningLevel = false
    end)
end

-- ================== FAST ATTACK ==================
function FastAttack()
    if _G.RunningFast then return end
    _G.RunningFast = true

    spawn(function()
        while _G.FastAttack do
            task.wait(math.random(5,8)/10)

            local char = GetChar()
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end

        _G.RunningFast = false
    end)
end

-- ================== GUI ==================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 300)
Main.Position = UDim2.new(0.3,0,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Draggable = true

local UIList = Instance.new("UIListLayout", Main)

function createToggle(name, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(1,0,0,40)
    Btn.Text = name.." OFF"

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name.." "..(state and "ON" or "OFF")
        callback(state)
    end)
end

createToggle("Auto Farm", function(v)
    _G.AutoFarm = v
    if v then AutoFarmLegit() end
end)

createToggle("Auto Level", function(v)
    _G.AutoLevel = v
    if v then AutoLevel() end
end)

createToggle("Fast Attack", function(v)
    _G.FastAttack = v
    if v then FastAttack() end
end)
