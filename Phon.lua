-- ================== BIẾN ==================
_G.AutoFarm = false
_G.AutoLevel = false
_G.FastAttack = false

_G.SelectedMob = ""
_G.MobList = {}
_G.NPCList = {}
_G.BossList = {}

-- ================== SERVICES ==================
local TweenService = game:GetService("TweenService")

-- ================== SAFE CHARACTER ==================
function GetChar()
    local player = game.Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

-- ================== CHECK MOB CHUẨN ==================
function IsRealMob(v)
    if not v:IsA("Model") then return false end

    local hum = v:FindFirstChild("Humanoid")
    local root = v:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return false end

    -- ❌ bỏ player
    if game.Players:GetPlayerFromCharacter(v) then return false end

    local name = v.Name:lower()

    -- ❌ bỏ shop / npc bán đồ
    if string.find(name,"shop") or string.find(name,"seller") then
        return false
    end

    -- ❌ bỏ object chết
    if hum.Health <= 0 then return false end

    -- ❌ bỏ npc đứng im (không phải boss)
    if hum.WalkSpeed == 0 and not string.find(name,"boss") then
        return false
    end

    return true
end

-- ================== SCAN MOB ==================
function ScanMobs()
    _G.MobList, _G.NPCList, _G.BossList = {}, {}, {}

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            
            if game.Players:GetPlayerFromCharacter(v) then continue end

            local name = v.Name

            if string.find(name:lower(),"boss") then
                if not table.find(_G.BossList,name) then
                    table.insert(_G.BossList,name)
                end

            elseif v.Humanoid.WalkSpeed == 0 then
                if not string.find(name:lower(),"shop") then
                    if not table.find(_G.NPCList,name) then
                        table.insert(_G.NPCList,name)
                    end
                end

            elseif IsRealMob(v) then
                if not table.find(_G.MobList,name) then
                    table.insert(_G.MobList,name)
                end
            end
        end
    end
end

-- ================== DROPDOWN ==================
function createDropdown(parent, listName, title)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,-10,0,40)
    Btn.Text = title
    Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Btn.TextColor3 = Color3.new(1,1,1)

    local ListFrame = Instance.new("Frame", parent)
    ListFrame.Size = UDim2.new(1,-10,0,120)
    ListFrame.Visible = false
    ListFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Instance.new("UIListLayout", ListFrame)

    Btn.MouseButton1Click:Connect(function()
        ListFrame.Visible = not ListFrame.Visible

        for _,v in pairs(ListFrame:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end

        ScanMobs()

        for _,mob in pairs(_G[listName]) do
            local Item = Instance.new("TextButton", ListFrame)
            Item.Size = UDim2.new(1,0,0,30)
            Item.Text = mob

            Item.MouseButton1Click:Connect(function()
                _G.SelectedMob = mob
                Btn.Text = mob
                ListFrame.Visible = false
            end)
        end
    end)
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
                    if d < dist then
                        dist = d
                        nearest = v
                    end
                end
            end

            if nearest then
                FlyToTargetSmooth(nearest)

                -- 🔥 quay mặt vào quái
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
                    if d < dist then
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
Main.Size = UDim2.new(0, 420, 0, 320)
Main.Position = UDim2.new(0.3, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(0,120,1,0)
Tabs.BackgroundColor3 = Color3.fromRGB(20,20,20)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-120,1,0)
Content.Position = UDim2.new(0,120,0,0)

Instance.new("UIListLayout", Tabs)

function createTab(name)
    local Btn = Instance.new("TextButton", Tabs)
    Btn.Size = UDim2.new(1,0,0,35)
    Btn.Text = name

    local Frame = Instance.new("Frame", Content)
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.Visible = false
    Instance.new("UIListLayout", Frame)

    Btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Content:GetChildren()) do
            v.Visible = false
        end
        Frame.Visible = true
    end)

    return Frame
end

function createToggle(parent, name)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,0,0,40)
    Btn.Text = name.." OFF"

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name.." "..(state and "ON" or "OFF")

        if name == "Auto Farm" then
            _G.AutoFarm = state
            if state then AutoFarmLegit() end

        elseif name == "Auto Level" then
            _G.AutoLevel = state
            if state then AutoLevel() end

        elseif name == "Fast Attack" then
            _G.FastAttack = state
            if state then FastAttack() end
        end
    end)
end

-- ================== MENU ==================
local MainTab = createTab("Main")
local FarmTab = createTab("Farm")
MainTab.Visible = true

createToggle(MainTab,"Fast Attack")
createToggle(FarmTab,"Auto Farm")
createToggle(FarmTab,"Auto Level")

createDropdown(FarmTab,"MobList","Chọn Mob")
createDropdown(FarmTab,"BossList","Chọn Boss")
createDropdown(FarmTab,"NPCList","Chọn NPC")
