if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId == 4588604953 then
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Play"):InvokeServer("play", "Casual", nil, 1)
end

local Players = game:GetService("Players")
local localplr = Players.LocalPlayer
local playerGui = localplr:WaitForChild("PlayerGui")
local intro = playerGui:WaitForChild("Intro")
local loadFrame = intro:WaitForChild("LoadFrame")
local loadLabel = loadFrame:WaitForChild("LoadLabel")

while loadLabel.Text ~= "LOADED" do
    loadLabel:GetPropertyChangedSignal("Text"):Wait()
end

wait(10)

task.spawn(function()
    while true do
        wait(70 * 60)
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RCTNMEUN"):InvokeServer()
        end)
    end
end)

task.spawn(function()
    local success, err = pcall(function()
        local primeGui = playerGui:WaitForChild("PrimeBuyGUI", 10)
        if not primeGui then return end
        
        local frame = primeGui:WaitForChild("Frame")
        
        -- Wait for the frame to be visible
        while not frame.Visible do
            task.wait(0.1)
        end
        
        wait(0.3)
        
        local closeButton = frame:WaitForChild("CloseButton")
        
        for _, connection in pairs(getconnections(closeButton.MouseButton1Click)) do
            connection:Fire()
        end
    end)
end)

wait(1)

task.spawn(function()
    local success, err = pcall(function()
        local intro = playerGui:WaitForChild("Intro", 10)
        if not intro then return end
        
        local frame = intro:WaitForChild("Frame")
        
        -- Wait for the frame to be visible
        while not frame.Visible do
            task.wait(0.1)
        end
        
        local buttonsFrame = frame:WaitForChild("ButtonsFrame")
        
        -- Wait for ButtonsFrame to be visible
        while not buttonsFrame.Visible do
            task.wait(0.1)
        end
        
        wait(0.5)
        
        local playFrame = buttonsFrame:WaitForChild("PlayFrame")
        local button = playFrame:WaitForChild("TextButton")
        
        for _, connection in pairs(getconnections(button.MouseButton1Click)) do
            connection:Fire()
        end
    end)
end)

task.spawn(function()
    local success, err = pcall(function()
        local casualWarning = playerGui:WaitForChild("CasualWarningGUI", 10)
        if not casualWarning then return end
        
        local frame = casualWarning:WaitForChild("Frame")
        
        -- Wait for the frame to be visible
        while not frame.Visible do
            task.wait(0.1)
        end
        
        wait(0.3)
        
        local returnButton = frame:WaitForChild("ReturnButton"):WaitForChild("TextButton")
        
        for _, connection in pairs(getconnections(returnButton.MouseButton1Click)) do
            connection:Fire()
        end
    end)
end)


local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")

task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        wait(1)
    end
end)

local replicatedStorage = nil
for _, child in ipairs(game:GetChildren()) do
    if child.Name == "RepIicatedStorage" then
        replicatedStorage = child
        break
    end
end

local allowanceValue = nil
if replicatedStorage then
    local playerDB = replicatedStorage:FindFirstChild("PlayerbaseData2")
    if playerDB then
        local playerData = playerDB:FindFirstChild(localplr.Name)
        if playerData then
            allowanceValue = playerData:FindFirstChild("NextAllowance")
        end
    end
end

local function playAnimation()
    local character = localplr.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end
    
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://14694480722"
    
    local anim = humanoid:LoadAnimation(animation)
    anim.Priority = Enum.AnimationPriority.Movement
    anim:Play()
    
    return anim
end

local function reset()
local args = {
	true
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerReset"):FireServer(unpack(args))
end

local function clickAllowanceOnce()
    pcall(function()
        local claimButton = playerGui:WaitForChild("CoreGUI"):WaitForChild("ATMFrame"):WaitForChild("ATMFrame"):WaitForChild("AllowanceFrame"):WaitForChild("ClaimButton"):WaitForChild("TextButton")
        
        for _, connection in pairs(getconnections(claimButton.MouseButton1Click)) do
            connection:Fire()
        end
    end)
end

local function isPlayerStuck(rootPart, lastPosition, threshold)
    if not lastPosition then return false end
    local distance = (rootPart.Position - lastPosition).Magnitude
    return distance < threshold
end

local function startPathfinding()
    local character = localplr.Character or localplr.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local rootPart = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso')
    
    if not rootPart or not humanoid then
        reset()
        return false
    end
    
    local atmFolder = game.Workspace:FindFirstChild("Map")
    if atmFolder then
        atmFolder = atmFolder:FindFirstChild("ATMz")
    end
    
    if not atmFolder then
        reset()
        return false
    end
    
    local atms = {}
    
    for _, obj in ipairs(atmFolder:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "ATM" then
            table.insert(atms, obj)
        end
    end
    
    local nearestATM = nil
    local shortestDistance = math.huge
    
    for _, atm in ipairs(atms) do
        local atmPos = atm:GetPivot().Position
        local distance = (rootPart.Position - atmPos).Magnitude
        
        if distance < shortestDistance then
            shortestDistance = distance
            nearestATM = atm
        end
    end
    
    if not nearestATM then
        reset()
        return false
    end
    
    local distanceToATM = (rootPart.Position - nearestATM:GetPivot().Position).Magnitude
    if distanceToATM < 10 then
        task.wait(0.5)
        clickAllowanceOnce()
        task.wait(1.5)
        if allowanceValue and allowanceValue.Value > 0 then
            if _G.OnATMClaimed then
                _G.OnATMClaimed()
            end
        end
        return true
    end
    
    local currentAnim = playAnimation()
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false
    })
    
    local targetPosition = nearestATM:GetPivot().Position
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        
        local currentWaypointIndex = 1
        local lastPosition = rootPart.Position
        local stuckCheckTimer = 0
        
        while currentWaypointIndex <= #waypoints do
            if not localplr.Character or not humanoid or humanoid.Health <= 0 then
                if currentAnim then
                    currentAnim:Stop()
                end
                return false
            end
            
            local waypoint = waypoints[currentWaypointIndex]
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            humanoid:MoveTo(waypoint.Position)
            
            local timeout = 0
            local waypointLastPos = rootPart.Position
            
            while timeout < 5 do
                task.wait(0.1)
                timeout = timeout + 0.1
                stuckCheckTimer = stuckCheckTimer + 0.1
                
                if not localplr.Character or not humanoid or humanoid.Health <= 0 then
                    if currentAnim then
                        currentAnim:Stop()
                    end
                    return false
                end
                
                local currentPos = rootPart.Position
                local distance = (currentPos - waypoint.Position).Magnitude
                
                if stuckCheckTimer >= 0.7 then
                    if isPlayerStuck(rootPart, lastPosition, 0.5) then
                        if currentAnim then
                            currentAnim:Stop()
                        end
                        reset()
                        return false
                    end
                    lastPosition = currentPos
                    stuckCheckTimer = 0
                end
                
                if distance < 4 then
                    break
                end
                
                if timeout >= 3 then
                    local waypointDistance = (currentPos - waypointLastPos).Magnitude
                    if waypointDistance < 1 then
                        break
                    end
                end
            end
            
            currentWaypointIndex = currentWaypointIndex + 1
        end
        
        task.wait(0.5)
        local finalDistance = (rootPart.Position - nearestATM:GetPivot().Position).Magnitude
        
        if finalDistance > 15 then
            if currentAnim then
                currentAnim:Stop()
            end
            reset()
            return false
        end
        
        if currentAnim then
            currentAnim:Stop()
        end
        
        task.wait(0.5)
        clickAllowanceOnce()
        task.wait(1.5)
        
        if allowanceValue and allowanceValue.Value > 0 then
            if _G.OnATMClaimed then
                _G.OnATMClaimed()
            end
        end
        
        return true
    else
        if currentAnim then
            currentAnim:Stop()
        end
        reset()
        return false
    end
end

if allowanceValue then
    task.spawn(function()
        local isProcessing = false
        
        while true do
            task.wait(1)
            
            if allowanceValue.Value == 0 and not isProcessing then
                isProcessing = true
                
                reset()
                
                repeat task.wait(0.1) until not localplr.Character or not localplr.Character:FindFirstChildWhichIsA("Humanoid") or localplr.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0
                
                local newChar = localplr.CharacterAdded:Wait()
                task.wait(2)
                
                local attempts = 0
                while allowanceValue.Value == 0 do
                    attempts = attempts + 1
                    
                    local pathSuccess = startPathfinding()
                    
                    if not pathSuccess then
                        reset()
                        repeat task.wait(0.1) until not localplr.Character or not localplr.Character:FindFirstChildWhichIsA("Humanoid") or localplr.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0
                        newChar = localplr.CharacterAdded:Wait()
                        task.wait(2)
                    else
                        task.wait(2)
                        
                        if allowanceValue.Value == 0 then
                            clickAllowanceOnce()
                            task.wait(1)
                        end
                    end
                    
                    if attempts > 5 then
                        task.wait(5)
                        attempts = 0
                    end
                end
                
                isProcessing = false
            end
        end	
    end)
end

_G.EmbedColor = 16764130
_G.BasicStyling = false
getgenv().hook = "https://discord.com/api/webhooks/1459415371374133441/F7tFwiavou6Fe9hcrxRE5TgkH5ma6CeTc4zylE9h4-bwd7PbcefUCgyA6Mqxxr1dPlFR" 
loadstring(game:HttpGet("https://raw.githubusercontent.com/Attypical/nality/refs/heads/main/webhook.lua", true))()
