-- ================== BIẾN ==================
_G.AutoFarm = false
_G.AutoBoss = false
_G.AutoNPC = false
_G.AutoLevel = false
_G.FastAttack = false

_G.SelectedMob = ""
_G.MobList = {}
_G.NPCList = {}
_G.BossList = {}

-- ================== GUI ==================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 420, 0, 320)
Main.Position = UDim2.new(0.3, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "LEGIT MENU"
Title.BackgroundColor3 = Color3.fromRGB(15,15,15)
Title.TextColor3 = Color3.new(1,1,1)

local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(0,120,1,-35)
Tabs.Position = UDim2.new(0,0,0,35)
Tabs.BackgroundColor3 = Color3.fromRGB(20,20,20)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-120,1,-35)
Content.Position = UDim2.new(0,120,0,35)
Content.BackgroundTransparency = 1

Instance.new("UIListLayout", Tabs).Padding = UDim.new(0,5)

-- ================== TAB ==================
function createTab(name)
    local Btn = Instance.new("TextButton", Tabs)
    Btn.Size = UDim2.new(1,0,0,35)
    Btn.Text = name
    Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Btn)

    local Frame = Instance.new("ScrollingFrame", Content)
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.Visible = false
    Frame.CanvasSize = UDim2.new(0,0,2,0)
    Frame.BackgroundTransparency = 1
    Instance.new("UIListLayout", Frame).Padding = UDim.new(0,5)

    Btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Content:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        Frame.Visible = true
    end)

    return Frame
end

-- ================== SCAN MOB ==================
function ScanMobs()
    _G.MobList, _G.NPCList, _G.BossList = {}, {}, {}

    for _,v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            
            if game.Players:GetPlayerFromCharacter(v) then continue end

            if string.find(v.Name,"Boss") then
                if not table.find(_G.BossList,v.Name) then table.insert(_G.BossList,v.Name) end

            elseif v.Humanoid.WalkSpeed == 0 then
                if not table.find(_G.NPCList,v.Name) then table.insert(_G.NPCList,v.Name) end

            else
                if not table.find(_G.MobList,v.Name) then table.insert(_G.MobList,v.Name) end
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

-- ================== AUTO FARM LEGIT ==================
function AutoFarmLegit()
    spawn(function()
        while _G.AutoFarm do
            task.wait(math.random(4,7)/10)

            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

            local nearest, dist = nil, math.huge

            for _,v in pairs(workspace:GetDescendants()) do
                if v.Name == _G.SelectedMob and v:FindFirstChild("HumanoidRootPart") then
                    if v.Humanoid.Health > 0 then
                        local d = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            dist = d
                            nearest = v
                        end
                    end
                end
            end

            if nearest then
                local offset = math.random(3,6)
                char.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0,0,offset)

                task.wait(math.random(2,4)/10)

                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end)
end

-- ================== AUTO LEVEL ==================
function AutoLevel()
    spawn(function()
        while _G.AutoLevel do
            task.wait(math.random(4,7)/10)

            local char = game.Players.LocalPlayer.Character
            if not char then continue end

            local nearest, dist = nil, math.huge

            for _,v in pairs(workspace:GetDescendants()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if not game.Players:GetPlayerFromCharacter(v) then
                        local d = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            dist = d
                            nearest = v
                        end
                    end
                end
            end

            if nearest then
                char.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end)
end

-- ================== FAST ATTACK LEGIT ==================
function FastAttack()
    spawn(function()
        while _G.FastAttack do
            task.wait(math.random(5,8)/10)

            local char = game.Players.LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")

            if tool then tool:Activate() end
        end
    end)
end

-- ================== TOGGLE ==================
function createToggle(parent, name)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,-10,0,40)
    Btn.Text = name.." OFF"
    Btn.BackgroundColor3 = Color3.fromRGB(50,0,0)

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name.." "..(state and "ON" or "OFF")
        Btn.BackgroundColor3 = state and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,0,0)

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

-- BUTTON TOGGLE UI
local ToggleUI = Instance.new("TextButton", ScreenGui)
ToggleUI.Size = UDim2.new(0,50,0,50)
ToggleUI.Position = UDim2.new(0,10,0.5,0)
ToggleUI.Text = "UI"

ToggleUI.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)
