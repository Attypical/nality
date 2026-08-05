if not game:IsLoaded() then
    game.Loaded:Wait()
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Attypical/nality/refs/heads/main/notif.lua", true))()
task.wait(2)
_G.notify("welcome! ヾ(•ω•`)o", 2)

if game.PlaceId == 4588604953 then
    _G.notify("> joining game...", 1)
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Play"):InvokeServer("play", "Casual", nil, 1)
end

local Players = game:GetService("Players")
local localplr = Players.LocalPlayer
local playerGui = localplr:WaitForChild("PlayerGui")
local intro = playerGui:WaitForChild("Intro")
local loadFrame = intro:WaitForChild("LoadFrame")
local loadLabel = loadFrame:WaitForChild("LoadLabel")

-- Wait for LOADED with a safety timeout (30 seconds)
local loadTimeout = 30
while loadLabel.Text ~= "LOADED" and loadTimeout > 0 do
    loadLabel:GetPropertyChangedSignal("Text"):Wait()
    loadTimeout = loadTimeout - 1
end
task.wait(14)

-- Keep server alive (RCTNMEUN remote)
task.spawn(function()
    while true do
        task.wait(50 * 60)
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RCTNMEUN"):InvokeServer()
        end)
    end
end)

-- Close PrimeBuyGUI if it appears
task.spawn(function()
    local primeGui = playerGui:FindFirstChild("PrimeBuyGUI")
    if primeGui then
        local frame = primeGui:FindFirstChild("Frame")
        if frame and frame.Visible then
            task.wait(0.3)
            local closeButton = frame:FindFirstChild("CloseButton")
            if closeButton then
                pcall(firesignal, closeButton.MouseButton1Click)
            end
        end
    end
end)

task.wait(1)

-- Click through Intro and CasualWarningGUI (safely)
task.spawn(function()
    local introGui = playerGui:FindFirstChild("Intro")
    if introGui then
        local frame = introGui:FindFirstChild("Frame")
        if frame and frame.Visible then
            local buttonsFrame = frame:FindFirstChild("ButtonsFrame")
            if buttonsFrame and buttonsFrame.Visible then
                task.wait(0.5)
                local playFrame = buttonsFrame:FindFirstChild("PlayFrame")
                if playFrame then
                    local button = playFrame:FindFirstChild("TextButton")
                    if button then
                        pcall(firesignal, button.MouseButton1Click)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    local casualWarning = playerGui:FindFirstChild("CasualWarningGUI")
    if casualWarning then
        local frame = casualWarning:FindFirstChild("Frame")
        if frame and frame.Visible then
            task.wait(0.3)
            local returnButton = frame:FindFirstChild("ReturnButton")
            if returnButton then
                local textButton = returnButton:FindFirstChild("TextButton")
                if textButton then
                    pcall(firesignal, textButton.MouseButton1Click)
                end
            end
        end
    end
end)

-- Services
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Press E periodically to open ATMs (runs continuously)
task.spawn(function()
    while true do
        task.wait(2)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end)

-- Look up the allowance value using the game's specific folder name "RepIicatedStorage"
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

-- Blacklisted spawn positions (exact coordinates from your script)
local blacklistedPositions = {
    {position = Vector3.new(-4920.67724609375, 1.3235726356506348, -164.5072021484375), radius = 5},
    {position = Vector3.new(-4379.66943359375, 1.9842529296875, -1184.73193359375), radius = 5},
    {position = Vector3.new(-4720.62353515625, 1.0519661903381348, -573.3690185546875), radius = 5},
    {position = Vector3.new(-4519.41845703125, 1.77362060546875, -391.8365783691406), radius = 5},
    {position = Vector3.new(-4310.3740234375, 2.334716796875, -1197.1197509765625), radius = 5},
    {position = Vector3.new(-4434.09912109375, 1.121999979019165, -939.6307983398438), radius = 5},
    {position = Vector3.new(-4310.3740234375, 2.334716796875, -1197.1197509765625), radius = 5},
    {position = Vector3.new(-4816.6298828125, 1.421965479850769, -73.02700805664062), radius = 5},
    {position = Vector3.new(-4735.8798828125, 1.421966791152954, -84.54068756103516), radius = 5},
    {position = Vector3.new(-4065.96484375, 1.0519680976867676, -197.09767150878906), radius = 5},
    {position = Vector3.new(-4847.92333984375, 1.121964454650879, -40.979610443115234), radius = 5},
}

local function isPositionBlacklisted(position)
    for _, blacklisted in ipairs(blacklistedPositions) do
        local distance = (position - blacklisted.position).Magnitude
        if distance <= blacklisted.radius then
            return true
        end
    end
    return false
end

-- Play an animation while walking (optional)
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

-- Reset the player's character
local function reset()
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerReset"):FireServer(true)
end

-- Attempt to click the claim button once (with a 2‑second timeout)
local function clickAllowanceOnce()
    local success = false
    local timeout = 2
    local startTime = tick()

    while tick() - startTime < timeout do
        local coreGUI = playerGui:FindFirstChild("CoreGUI")
        if coreGUI then
            local atmFrame = coreGUI:FindFirstChild("ATMFrame")
            if atmFrame then
                local innerFrame = atmFrame:FindFirstChild("ATMFrame")
                if innerFrame then
                    local allowanceFrame = innerFrame:FindFirstChild("AllowanceFrame")
                    if allowanceFrame then
                        local claimButton = allowanceFrame:FindFirstChild("ClaimButton")
                        if claimButton then
                            local textButton = claimButton:FindFirstChild("TextButton")
                            if textButton and textButton.Visible and textButton.Active then
                                pcall(function()
                                    textButton:Click()
                                end)
                                pcall(function()
                                    firesignal(textButton.MouseButton1Click)
                                end)
                                success = true
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
    return success
end

-- Retry clicking up to 5 times, checking allowance after each attempt
local function claimWithRetry(maxAttempts, delayBetween)
    maxAttempts = maxAttempts or 5
    delayBetween = delayBetween or 0.5

    for attempt = 1, maxAttempts do
        clickAllowanceOnce()
        task.wait(delayBetween)

        if allowanceValue and allowanceValue.Value > 0 then
            _G.notify("> claimed on attempt " .. attempt, 2)
            return true
        end
        _G.notify("> attempt " .. attempt .. " failed, retrying...", 2)
    end
    return false
end

-- Check if the player is stuck (movement < threshold)
local function isPlayerStuck(rootPart, lastPosition, threshold)
    if not lastPosition then return false end
    return (rootPart.Position - lastPosition).Magnitude < threshold
end

-- Handle bad spawn positions by resetting until a safe spot is found
local function checkAndHandleBlacklistedPosition()
    local character = localplr.Character or localplr.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso')
    if not rootPart then return false end

    while isPositionBlacklisted(rootPart.Position) do
        _G.notify("> bad spawn detected, resetting...", 2)
        reset()

        repeat task.wait(0.1) until not localplr.Character or not localplr.Character:FindFirstChildWhichIsA("Humanoid")
        character = localplr.CharacterAdded:Wait()
        task.wait(2)

        rootPart = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso')
        if not rootPart then return false end
    end

    _G.notify("> spawn position ok, proceeding!", 2)
    return true
end

-- Main pathfinding and claiming logic
local function startPathfinding()
    if not checkAndHandleBlacklistedPosition() then
        return false
    end

    local character = localplr.Character or localplr.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local rootPart = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso')
    if not rootPart or not humanoid then
        reset()
        _G.notify("> unexpected error occured", 3)
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

    -- Collect all ATM models
    local atms = {}
    for _, obj in ipairs(atmFolder:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "ATM" then
            table.insert(atms, obj)
        end
    end

    -- Find nearest ATM
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
        _G.notify("> failed finding nearest atm ", 3)
        return false
    end

    -- If already close, try to claim immediately
    local distanceToATM = (rootPart.Position - nearestATM:GetPivot().Position).Magnitude
    if distanceToATM < 10 then
        task.wait(0.5)
        if claimWithRetry() then
            _G.notify("> claimed successfully", 3)
            if _G.OnATMClaimed then _G.OnATMClaimed() end
            return true
        else
            _G.notify("> claim failed after retries, resetting...", 3)
            reset()
            return false
        end
    end

    -- Play running animation
    local currentAnim = playAnimation()

    -- Create path
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
                if currentAnim then currentAnim:Stop() end
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
                    if currentAnim then currentAnim:Stop() end
                    return false
                end

                local currentPos = rootPart.Position
                local distance = (currentPos - waypoint.Position).Magnitude

                if stuckCheckTimer >= 0.7 then
                    if isPlayerStuck(rootPart, lastPosition, 0.5) then
                        if currentAnim then currentAnim:Stop() end
                        reset()
                        _G.notify("> resetting due to obstacle ＞︿＜", 3)
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
            if currentAnim then currentAnim:Stop() end
            reset()
            _G.notify("> resetting due to script failure ＞︿＜", 3)
            return false
        end

        if currentAnim then currentAnim:Stop() end

        -- Try to claim with retries
        task.wait(0.5)
        if claimWithRetry() then
            _G.notify("> claimed successfully", 3)
            if _G.OnATMClaimed then _G.OnATMClaimed() end
            return true
        else
            _G.notify("> claim failed after retries, resetting...", 3)
            reset()
            return false
        end
    else
        if currentAnim then currentAnim:Stop() end
        reset()
        _G.notify("> resetting due to script failure ＞︿＜", 3)
        return false
    end
end

-- Main allowance collection loop
if allowanceValue then
    task.spawn(function()
        local isProcessing = false

        while true do
            task.wait(1)

            if allowanceValue.Value == 0 and not isProcessing then
                isProcessing = true
                _G.notify("> starting allowance collection process $.$", 3)

                -- Reset character to a fresh spawn
                reset()
                repeat task.wait(0.1) until not localplr.Character
                local newChar = localplr.CharacterAdded:Wait()
                task.wait(2)

                local attempts = 0
                while allowanceValue.Value == 0 do
                    attempts = attempts + 1

                    local pathSuccess = startPathfinding()   -- returns true only if claimed

                    if pathSuccess then
                        _G.notify("> allowance claimed, exiting loop", 3)
                        break
                    else
                        _G.notify("> restarting process...", 2)
                        reset()
                        repeat task.wait(0.1) until not localplr.Character
                        newChar = localplr.CharacterAdded:Wait()
                        task.wait(2)
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

-- Webhook setup (your existing one)
_G.EmbedColor = 7903521
_G.BasicStyling = false
getgenv().hook = "https://discord.com/api/webhooks/1534301369656283168/JjwLUv2H59RIXKVSLOQNcMGUW6FljFUit309ENKx-9R7Xsu8w6Mps5LPM3DKC3yPWxyk"
loadstring(game:HttpGet("https://raw.githubusercontent.com/Attypical/nality/refs/heads/main/webhook.lua", true))()
