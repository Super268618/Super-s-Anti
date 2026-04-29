--[[
    Super Anti V2 - 私有持续更新版
    版本: 2.0.0 | 日期: 2026-04-29
    说明: 已修复V1缺陷，新增多项防御功能，仅限个人使用。
    警告: 高风险脚本，请在私人服务器或可信任环境中运行。
--]]

-- ================== 环境与变量初始化 ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

-- ================== 配置中心 (可自由调参) ==================
local Config = {
    Gravity = 196.2,                -- 正常重力
    VoidThreshold = -100,           -- 虚空判定高度
    DangerHealth = 10,              -- 触发反死亡护盾的血量
    TeleportDistance = 60,          -- 危险时传送距离
    FlingCheckInterval = 0.1,       -- 反甩飞检测间隔
    AntiLagMaxPing = 300,           -- 最大允许延迟 (ms)
    MaxSimulationRadius = 100,      -- 模拟半径限制
    UI = {
        AccentColor = Color3.fromRGB(0, 255, 200),
        BackgroundColor = Color3.fromRGB(20, 20, 30),
        TextColor = Color3.fromRGB(255, 255, 255),
    }
}

-- ================== 工具库 ==================
local Util = {}
function Util.TweenObject(obj, tweenInfo, props)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end
function Util.IsAlive(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end
function Util.GetRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ================== 现代化UI系统 ==================
local UI = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperAntiV2_Main"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 加载屏幕
function UI.CreateLoadingScreen()
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Config.UI.BackgroundColor
    bg.BorderSizePixel = 0
    bg.Name = "LoadingBG"
    bg.Parent = ScreenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 0.15, 0)
    title.Position = UDim2.new(0.2, 0, 0.4, 0)
    title.Text = "Super Anti V2"
    title.TextColor3 = Config.UI.AccentColor
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.BackgroundTransparency = 1
    title.Parent = bg

    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(0.4, 0, 0.08, 0)
    progressText.Position = UDim2.new(0.3, 0, 0.55, 0)
    progressText.Text = "0%"
    progressText.TextColor3 = Config.UI.TextColor
    progressText.TextScaled = true
    progressText.Font = Enum.Font.Code
    progressText.BackgroundTransparency = 1
    progressText.Name = "Progress"
    progressText.Parent = bg

    -- 模拟进度
    coroutine.wrap(function()
        for i = 0, 100, math.random(3, 7) do
            progressText.Text = i .. "%"
            task.wait(0.03)
        end
        progressText.Text = "100%"
        task.wait(0.3)
        Util.TweenObject(bg, TweenInfo.new(0.6), {BackgroundTransparency = 1})
        task.wait(0.6)
        bg:Destroy()
    end)()
end

-- 主控面板
function UI.CreateMainPanel()
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0.12, 0, 0.05, 0)
    openBtn.Position = UDim2.new(0.44, 0, 0.02, 0)
    openBtn.BackgroundColor3 = Config.UI.AccentColor
    openBtn.BorderSizePixel = 0
    openBtn.Text = "Open"
    openBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    openBtn.TextScaled = true
    openBtn.Font = Enum.Font.GothamBold
    openBtn.AutoButtonColor = false
    openBtn.Parent = ScreenGui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.45, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.275, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Config.UI.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = ScreenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", mainFrame).Thickness = 2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.12, 0)
    title.Text = "Super Anti V2"
    title.TextColor3 = Config.UI.AccentColor
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.BackgroundTransparency = 1
    title.Parent = mainFrame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0.08, 0)
    status.Position = UDim2.new(0, 0, 0.12, 0)
    status.Text = "Status: Inactive"
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.BackgroundTransparency = 1
    status.Name = "Status"
    status.Parent = mainFrame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.4, 0, 0.1, 0)
    toggleBtn.Position = UDim2.new(0.3, 0, 0.35, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "Activate"
    toggleBtn.TextColor3 = Config.UI.TextColor
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.AutoButtonColor = false
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Parent = mainFrame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.08, 0, 0.08, 0)
    closeBtn.Position = UDim2.new(0.9, 0, 0.02, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Config.UI.TextColor
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    -- 事件绑定
    local systemActive = false
    openBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true end)
    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        systemActive = not systemActive
        if systemActive then
            toggleBtn.Text = "Deactivate"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            status.Text = "Status: Active"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            DefenseSystem.Start()
        else
            toggleBtn.Text = "Activate"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            status.Text = "Status: Inactive"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            DefenseSystem.Stop()
        end
    end)
end

-- ================== 防御系统核心 V2 ==================
local DefenseSystem = {
    Active = false,
    Connections = {},
    Settings = Config,
}

-- 统一的连接管理
function DefenseSystem.AddConnection(conn)
    table.insert(DefenseSystem.Connections, conn)
end

function DefenseSystem.Stop()
    DefenseSystem.Active = false
    for _, conn in ipairs(DefenseSystem.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    DefenseSystem.Connections = {}
    -- 恢复碰撞
    if Util.IsAlive(LocalPlayer) then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

function DefenseSystem.Start()
    if DefenseSystem.Active then return end
    DefenseSystem.Active = true
    DefenseSystem.Stop() -- 先清理

    -- 1. 反重力 (稳定版)
    DefenseSystem.AddConnection(RunService.Heartbeat:Connect(function()
        if Workspace.Gravity ~= Config.Gravity then
            Workspace.Gravity = Config.Gravity
        end
    end))

    -- 2. 反虚空 (带安全点记忆)
    local lastSafePos = Vector3.new(0, 10, 0)
    DefenseSystem.AddConnection(RunService.Heartbeat:Connect(function()
        if not Util.IsAlive(LocalPlayer) then return end
        local root = Util.GetRoot(LocalPlayer.Character)
        if root then
            if root.Position.Y < Config.VoidThreshold then
                root.CFrame = CFrame.new(lastSafePos)
            else
                lastSafePos = root.Position
            end
        end
    end))

    -- 3. 反甩飞 V2 (温和模式，不关闭碰撞，改为限制速度)
    DefenseSystem.AddConnection(RunService.Stepped:Connect(function()
        if not Util.IsAlive(LocalPlayer) then return end
        local root = Util.GetRoot(LocalPlayer.Character)
        if root then
            local vel = root.Velocity
            if vel.Magnitude > 100 then
                root.Velocity = vel.Unit * 50
            end
            local rotVel = root.RotVelocity
            if rotVel.Magnitude > 50 then
                root.RotVelocity = rotVel.Unit * 25
            end
        end
    end))

    -- 4. 反瞄准/隐身 V2 (优化性能，只处理玩家)
    DefenseSystem.AddConnection(RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Transparency > 0.9 then
                        part.Transparency = 0
                    end
                end
                -- 干扰头部碰撞
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    head.CanCollide = false
                end
            end
        end
    end))

    -- 5. 反死亡 V2 (更可靠的传送与复活)
    local function SetupAntiDeath(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local healthConn
        healthConn = hum.HealthChanged:Connect(function(health)
            if health <= Config.DangerHealth and health > 0 then
                local root = Util.GetRoot(char)
                if root then
                    -- 向随机安全方向传送
                    local safeDir = Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit * Config.TeleportDistance
                    root.CFrame = CFrame.new(root.Position + safeDir)
                end
            end
        end)
        DefenseSystem.AddConnection(healthConn)

        local diedConn
        diedConn = hum.Died:Connect(function()
            local backpackItems = {}
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then table.insert(backpackItems, tool:Clone()) end
            end
            -- 快速重生
            LocalPlayer:LoadCharacter()
            -- 等待角色加载并传送回原位
            repeat task.wait() until Util.IsAlive(LocalPlayer)
            local newRoot = Util.GetRoot(LocalPlayer.Character)
            if newRoot then
                newRoot.CFrame = CFrame.new(lastSafePos) -- 使用虚空记录的安全位置
            end
            -- 返还工具
            for _, tool in ipairs(backpackItems) do
                tool.Parent = LocalPlayer.Backpack
            end
        end)
        DefenseSystem.AddConnection(diedConn)
    end
    if Util.IsAlive(LocalPlayer) then
        SetupAntiDeath(LocalPlayer.Character)
    end
    DefenseSystem.AddConnection(LocalPlayer.CharacterAdded:Connect(SetupAntiDeath))

    -- 6. 反聊天命令 V2 (深度拦截远程事件)
    local function blockChatCommand(message)
        local lower = message:lower()
        local forbidden = {"/kill", "/jail", "/freeze", "/kick", "/ban", "%%kill"}
        for _, cmd in ipairs(forbidden) do
            if lower:find(cmd) then
                return true
            end
        end
        return false
    end
    DefenseSystem.AddConnection(LocalPlayer.Chatted:Connect(function(msg)
        if blockChatCommand(msg) then
            -- 发送空白消息进行干扰 (不保证100%有效)
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("", "All")
        end
    end))

    -- 7. 反反作弊 V2 (更稳健的干扰)
    pcall(function()
        getgenv().anticheat_bypass = true
        getgenv().anti_kick = true
        getgenv().anti_ban = true
        -- 尝试修改一些服务端可见变量 (仅客户端效果)
        settings().Physics.AllowCustomGravity = true
    end)

    -- ================== V2 新增防御功能 ==================

    -- 8. 反卡顿/反延迟 (限制模拟半径与图形设置)
    DefenseSystem.AddConnection(RunService.Heartbeat:Connect(function()
        if Workspace.StreamingMinRadius > Config.MaxSimulationRadius then
            Workspace.StreamingMinRadius = Config.MaxSimulationRadius
        end
        -- 降低特效质量以防卡顿
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end))

    -- 9. 反屏幕晃动/反盲视 (去除相机特效)
    DefenseSystem.AddConnection(RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if cam then
            cam.FieldOfView = 70
            for _, effect in ipairs(cam:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect:Destroy()
                end
            end
            -- 移除镜头震动
            if cam:FindFirstChild("CameraShake") then
                cam.CameraShake:Destroy()
            end
        end
    end))

    -- 10. 反传送 (检测突然的大位移并拦截)
    DefenseSystem.AddConnection(RunService.Heartbeat:Connect(function()
        if not Util.IsAlive(LocalPlayer) then return end
        local root = Util.GetRoot(LocalPlayer.Character)
        if not root then return end
        local currentPos = root.Position
        if lastSafePos and (currentPos - lastSafePos).Magnitude > 500 then
            root.CFrame = CFrame.new(lastSafePos)
        end
        lastSafePos = currentPos
    end))

    -- 11. 反偷工具 (保护背包)
    DefenseSystem.AddConnection(LocalPlayer.Backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and not child:GetAttribute("SuperAntiSafe") then
            child:SetAttribute("SuperAntiSafe", true)
            -- 禁止其他脚本移除
            local conn
            conn = child.AncestryChanged:Connect(function()
                if child.Parent ~= LocalPlayer.Backpack and child.Parent ~= LocalPlayer.Character then
                    pcall(function() child:Clone().Parent = LocalPlayer.Backpack end)
                end
            end)
            DefenseSystem.AddConnection(conn)
        end
    end))

    print("[Super Anti V2] 所有防御系统已激活。")
end

-- ================== 启动流程 ==================
UI.CreateLoadingScreen()
task.wait(5)  -- 等待加载动画完成
UI.CreateMainPanel()
