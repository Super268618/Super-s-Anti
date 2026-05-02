--[[
    ====================================================================
    🛡️ Super Anti V2.1 (Delta Executor Edition)
    ====================================================================
    Features: Anti-Kick, Anti-Ban, Anti-Fling, Anti-Aimbot, Anti-Void, 
    Anti-Suck, Fullbright, ESP, State-Locking, and more.
    ====================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ================== 1. System State & Variables ==================
getgenv().AntiSystem = getgenv().AntiSystem or {
    Active = false,
    Connections = {},
    Settings = {
        Gravity = 196.2,
        VoidThreshold = -100,
        DangerHealth = 15,
    }
}

local OriginalLighting = {
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness
}

-- ================== 2. DELTA CORE HOOKS (Anti-Kick / Anti-Ban) ==================
-- This runs immediately but only blocks actions if AntiSystem.Active is true
if not getgenv().SuperAntiHooked then
    getgenv().SuperAntiHooked = true
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if getgenv().AntiSystem.Active and not checkcaller() then
            -- 1. Anti-Kick intercept
            if (method == "Kick" or method == "kick") and self == LocalPlayer then
                warn("🛡️ Super Anti [Delta]: Blocked client-side Kick attempt.")
                return nil
            end
            
            -- 2. Anti-Ban / Malicious Remote intercept
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = string.lower(self.Name)
                if string.find(remoteName, "ban") or string.find(remoteName, "kick") or 
                   string.find(remoteName, "crash") or string.find(remoteName, "punish") or 
                   string.find(remoteName, "log") or string.find(remoteName, "detect") then
                    warn("🛡️ Super Anti [Delta]: Blocked malicious remote ->", self.Name)
                    return nil
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

-- ================== 3. UI Generation ==================
local function CreateMainGUI()
    -- Cleanup old GUI if it exists
    if PlayerGui:FindFirstChild("SuperAnti_Main") then
        PlayerGui.SuperAnti_Main:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SuperAnti_Main"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false

    -- Open Button
    local OpenButton = Instance.new("TextButton")
    OpenButton.Size = UDim2.new(0.15, 0, 0.06, 0)
    OpenButton.Position = UDim2.new(0.425, 0, 0.02, 0)
    OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    OpenButton.Text = "🛡️ Super Anti V2.1"
    OpenButton.TextColor3 = Color3.fromRGB(0, 255, 255)
    OpenButton.TextScaled = true
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.Parent = ScreenGui
    Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", OpenButton).Thickness = 1.5
    Instance.new("UIStroke", OpenButton).Color = Color3.fromRGB(0, 255, 255)

    -- Main Panel
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.35, 0, 0.4, 0)
    MainFrame.Position = UDim2.new(0.325, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", MainFrame).Thickness = 2
    Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 200, 255)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0.2, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "GOD MODE DEFENSE"
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.Parent = MainFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0.15, 0)
    StatusLabel.Position = UDim2.new(0, 0, 0.2, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = getgenv().AntiSystem.Active and "STATUS: ACTIVE" or "STATUS: INACTIVE"
    StatusLabel.TextColor3 = getgenv().AntiSystem.Active and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    StatusLabel.TextScaled = true
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Parent = MainFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.6, 0, 0.2, 0)
    ToggleButton.Position = UDim2.new(0.2, 0, 0.45, 0)
    ToggleButton.BackgroundColor3 = getgenv().AntiSystem.Active and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
    ToggleButton.Text = getgenv().AntiSystem.Active and "DEACTIVATE" or "ACTIVATE"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.GothamBlack
    ToggleButton.Parent = MainFrame
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0.1, 0, 0.15, 0)
    CloseButton.Position = UDim2.new(0.88, 0, 0.02, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = MainFrame

    -- Dragging Logic
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Button Logic
    OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
    CloseButton.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    
    ToggleButton.MouseButton1Click:Connect(function()
        getgenv().AntiSystem.Active = not getgenv().AntiSystem.Active
        if getgenv().AntiSystem.Active then
            ToggleButton.Text = "DEACTIVATE"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            StatusLabel.Text = "STATUS: ACTIVE"
            StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            StartDefenseSystem()
        else
            ToggleButton.Text = "ACTIVATE"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            StatusLabel.Text = "STATUS: INACTIVE"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            StopDefenseSystem()
        end
    end)
end

-- ================== 4. ACTIVE DEFENSE LOOPS ==================
function StartDefenseSystem()
    StopDefenseSystem() -- Clear existing loops

    local conns = getgenv().AntiSystem.Connections

    -- 1. Anti-Gravity & Fullbright
    table.insert(conns, RunService.RenderStepped:Connect(function()
        Workspace.Gravity = getgenv().AntiSystem.Settings.Gravity
        Lighting.ClockTime = 12
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
        Lighting.Brightness = 3
    end))

    -- 2. Anti-Void & Anti-Death
    local lastSafePos = Vector3.new(0, 50, 0)
    table.insert(conns, RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if root and hum then
            -- Anti-Void
            if root.Position.Y < getgenv().AntiSystem.Settings.VoidThreshold then
                root.CFrame = CFrame.new(lastSafePos)
                root.Velocity = Vector3.zero
            else
                lastSafePos = root.Position
            end

            -- Anti-Death (Ghost Escape)
            if hum.Health > 0 and hum.Health <= getgenv().AntiSystem.Settings.DangerHealth then
                root.CFrame = root.CFrame + Vector3.new(0, 200, 0) -- Teleport to sky
                hum.Health = hum.MaxHealth -- Attempt local heal visual
            end
        end
    end))

    -- 3. Physics Protection (Anti-Fling, Trample, Sit, Anchor, Suck, Attach)
    table.insert(conns, RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        -- State Locking (Anti-Sit, Trample, Freeze)
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            if hum.Sit then hum.Sit = false end
            if hum.PlatformStand then hum.PlatformStand = false end
        end

        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                -- Anti-Anchor
                if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                    obj.Anchored = false
                end
                -- Anti-Suck / Anti-Attach
                if obj:IsA("BodyMover") or obj:IsA("LinearVelocity") or obj:IsA("AlignPosition") then
                    obj:Destroy()
                end
                if (obj:IsA("Weld") or obj:IsA("WeldConstraint")) and obj.Part0 and obj.Part1 then
                    if not obj.Part0:IsDescendantOf(char) or not obj.Part1:IsDescendantOf(char) then
                        obj:Destroy()
                    end
                end
            end
        end

        -- Anti-Fling (Disable other players' collisions)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end))

    -- 4. ESP & Anti-Invisibility & Anti-Aimbot (Jitter)
    table.insert(conns, RunService.RenderStepped:Connect(function()
        -- Anti-Aimbot: Tiny Jitter on your Head
        local char = LocalPlayer.Character
        local head = char and char:FindFirstChild("Head")
        if head then
            head.LocalTransparencyModifier = 0
            head.CFrame = head.CFrame * CFrame.new(math.random(-1,1)*0.05, math.random(-1,1)*0.05, math.random(-1,1)*0.05)
        end

        -- ESP / Anti-Invis
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local pChar = player.Character
                for _, part in ipairs(pChar:GetDescendants()) do
                    if part:IsA("BasePart") and part.Transparency > 0.5 then
                        part.Transparency = 0 -- Reveal invisible players
                    end
                end
                -- Apply Highlight
                if not pChar:FindFirstChild("AntiESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "AntiESP"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = pChar
                end
            end
        end
    end))

    -- 5. Anti-Touch (Disable KillBricks locally)
    local function HandleParts(part)
        if part:IsA("BasePart") then
            local name = string.lower(part.Name)
            if string.find(name, "kill") or string.find(name, "lava") or string.find(name, "dead") then
                part.CanTouch = false
            end
        end
    end
    for _, part in ipairs(Workspace:GetDescendants()) do HandleParts(part) end
    table.insert(conns, Workspace.DescendantAdded:Connect(HandleParts))

    -- 6. Spoof Anti-Cheat Global Variables
    pcall(function()
        getgenv().antispeed = false
        getgenv().antitp = false
        getgenv().bypass = true
    end)
    
    StarterGui:SetCore("SendNotification", {
        Title = "Super Anti V2.1",
        Text = "Defense Systems Online.",
        Duration = 3
    })
end

-- ================== 5. STOP SYSTEM ==================
function StopDefenseSystem()
    -- Disconnect all loops
    for _, conn in ipairs(getgenv().AntiSystem.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    getgenv().AntiSystem.Connections = {}
    
    -- Restore Lighting
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.FogEnd = OriginalLighting.FogEnd
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    Lighting.Brightness = OriginalLighting.Brightness

    -- Restore Collisions & Remove ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
            local esp = player.Character:FindFirstChild("AntiESP")
            if esp then esp:Destroy() end
        end
    end
    
    StarterGui:SetCore("SendNotification", {
        Title = "Super Anti V2.1",
        Text = "Defense Systems Offline.",
        Duration = 3
    })
end

-- Initialize GUI
CreateMainGUI()
