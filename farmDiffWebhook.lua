if not game:IsLoaded() then
    game.Loaded:Wait()
end
loadstring(game:HttpGet("https://raw.githubusercontent.com/Attypical/nality/refs/heads/main/notif.lua", true))()
wait(2)
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

while loadLabel.Text ~= "LOADED" do
    loadLabel:GetPropertyChangedSignal("Text"):Wait()
end

wait(14)

task.spawn(function()
    while true do
        wait(50 * 60)
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

        while not frame.Visible do
            task.wait(0.1)
        end

        wait(0.3)

        local closeButton = frame:WaitForChild("CloseButton")
        pcall(firesignal, closeButton.MouseButton1Click)
    end)
end)

wait(1)

task.spawn(function()
    local success, err = pcall(function()
        local intro = playerGui:WaitForChild("Intro", 10)
        if not intro then return end

        local frame = intro:WaitForChild("Frame")

        while not frame.Visible do
            task.wait(0.1)
        end

        local buttonsFrame = frame:WaitForChild("ButtonsFrame")

        while not buttonsFrame.Visible do
            task.wait(0.1)
        end

        wait(0.5)

        local playFrame = buttonsFrame:WaitForChild("PlayFrame")
        local button = playFrame:WaitForChild("TextButton")
        pcall(firesignal, button.MouseButton1Click)
    end)
end)

task.spawn(function()
    local success, err = pcall(function()
        local casualWarning = playerGui:WaitForChild("CasualWarningGUI", 10)
        if not casualWarning then return end

        local frame = casualWarning:WaitForChild("Frame")

        while not frame.Visible do
            task.wait(0.1)
        end

        wait(0.3)

        local returnButton = frame:WaitForChild("ReturnButton"):WaitForChild("TextButton")
        pcall(firesignal, returnButton.MouseButton1Click)
    end)
end)


local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- NEW: lets the claim routine pause this spam loop so it can't close/reopen
-- the ATM GUI out from under a click attempt
_G.SuppressAutoInteract = false

task.spawn(function()
    while true do
        if not _G.SuppressAutoInteract then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            wait(1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            wait(1)
        else
            wait(0.2)
        end
    end
end)

-- NEW: presses E once, used deliberately by the claim routine rather than
-- relying on the timing of the background spam loop above
local function pressInteractOnce()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.15)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local replicatedStorage = nil
for _, child in ipairs(game:GetChildren()) do
    if child.Name == "RepIicatedStorage" then
        replicatedStorage = child
        break
    end
end

local allowanceValue = nil

-- NEW: centralized so it can be re-resolved after character/data resets
local function refreshAllowanceValue()
    if not replicatedStorage then
        print("[DEBUG]", "refreshAllowanceValue: replicatedStorage is nil")
        return
    end
    local playerDB = replicatedStorage:FindFirstChild("PlayerbaseData2")
    if not playerDB then
        print("[DEBUG]", "refreshAllowanceValue: PlayerbaseData2 not found")
        return
    end
    local playerData = playerDB:FindFirstChild(localplr.Name)
    if not playerData then
        print("[DEBUG]", "refreshAllowanceValue: playerData not found for", localplr.Name)
        return
    end
    allowanceValue = playerData:FindFirstChild("NextAllowance")
    print("[DEBUG]", "refreshAllowanceValue: NextAllowance =", allowanceValue and allowanceValue.Value or "nil")
end

refreshAllowanceValue()

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
    local args = {true}
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerReset"):FireServer(unpack(args))
end

-- NEW: finds the ATM GUI chain and returns the frame + button ONLY if the
-- frame is actually visible. Returns nil if it isn't open yet, instead of
-- clicking blind.
local function getVisibleClaimButton(timeout)
    local deadline = tick() + (timeout or 5)

    while tick() < deadline do
        local coreGui = playerGui:FindFirstChild("CoreGUI")
        local atmFrame = coreGui and coreGui:FindFirstChild("ATMFrame")
        local innerFrame = atmFrame and atmFrame:FindFirstChild("ATMFrame")
        local allowanceFrame = innerFrame and innerFrame:FindFirstChild("AllowanceFrame")
        local claimButtonHolder = allowanceFrame and allowanceFrame:FindFirstChild("ClaimButton")
        local button = claimButtonHolder and claimButtonHolder:FindFirstChild("TextButton")

        if innerFrame and innerFrame.Visible and button then
            print("[DEBUG]", "getVisibleClaimButton: found visible button")
            return button
        end

        task.wait(0.1)
    end

    print("[DEBUG]", "getVisibleClaimButton: timed out after", timeout, "-- coreGui/frame/button not visible in time")
    return nil
end

-- CHANGED: no longer clicks blind. Waits for the GUI to actually be visible
-- (nudging it open with a real interact press if it isn't), and only then
-- fires the button. Returns false if the GUI never opened.
local function clickAllowanceOnce()
    print("[DEBUG]", "clickAllowanceOnce: looking for claim button")
    local button = getVisibleClaimButton(2)

    if not button then
        print("[DEBUG]", "clickAllowanceOnce: not visible yet, pressing E to open ATM prompt")
        pressInteractOnce()
        button = getVisibleClaimButton(3)
    end

    if not button then
        print("[DEBUG]", "clickAllowanceOnce: gave up, button never became visible")
        return false
    end

    local fired = pcall(firesignal, button.MouseButton1Click)
    print("[DEBUG]", "clickAllowanceOnce: fired MouseButton1Click, success =", fired)
    return fired == true
end

-- NEW: retries the click a few times and confirms allowanceValue actually
-- changed before reporting success. Pauses the background E-spam loop for
-- the duration so it can't close the GUI mid-attempt.
local function attemptClaimAndVerify()
    print("[DEBUG]", "attemptClaimAndVerify: starting, suppressing auto-interact")
    _G.SuppressAutoInteract = true

    local result = false

    for attempt = 1, 3 do
        print("[DEBUG]", "attemptClaimAndVerify: attempt", attempt)
        local clicked = clickAllowanceOnce()

        if clicked then
            task.wait(1)
            refreshAllowanceValue()

            if allowanceValue and allowanceValue.Value > 0 then
                print("[DEBUG]", "attemptClaimAndVerify: value confirmed >0, claim verified on attempt", attempt)
                result = true
                break
            else
                print("[DEBUG]", "attemptClaimAndVerify: clicked but value still 0, will retry")
            end
        else
            _G.notify("> claim button not found/visible, retrying...", 2)
        end

        task.wait(0.5)
    end

    print("[DEBUG]", "attemptClaimAndVerify: finished, result =", result)
    _G.SuppressAutoInteract = false
    return result
end

local function isPlayerStuck(rootPart, lastPosition, threshold)
    if not lastPosition then return false end
    local distance = (rootPart.Position - lastPosition).Magnitude
    return distance < threshold
end

local function checkAndHandleBlacklistedPosition()
    local character = localplr.Character or localplr.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso')

    if not rootPart then
        return false
    end

    while isPositionBlacklisted(rootPart.Position) do
        print("[DEBUG]", "checkAndHandleBlacklistedPosition: spawn is blacklisted at", rootPart.Position)
        _G.notify("> bad spawn detected, resetting...", 2)

        reset()

        repeat task.wait(0.1) until not localplr.Character or not localplr.Character:FindFirstChildWhichIsA("Humanoid") or localplr.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0

        character = localplr.CharacterAdded:Wait()
        task.wait(2)

        rootPart = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso')

        if not rootPart then
            return false
        end
    end

    _G.notify("> spawn position ok, proceeding!", 2)

    return true
end

local function startPathfinding()
    print("[DEBUG]", "startPathfinding: called")

    if not checkAndHandleBlacklistedPosition() then
        print("[DEBUG]", "startPathfinding: aborting, blacklist check failed")
        return false
    end

    local character = localplr.Character or localplr.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local rootPart = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso')

    if not rootPart or not humanoid then
        print("[DEBUG]", "startPathfinding: missing rootPart or humanoid")
        reset()
        _G.notify("> unexpected error occured", 3)
        return false
    end

    local atmFolder = game.Workspace:FindFirstChild("Map")
    if atmFolder then
        atmFolder = atmFolder:FindFirstChild("ATMz")
    end

    if not atmFolder then
        print("[DEBUG]", "startPathfinding: ATMz folder not found")
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
        print("[DEBUG]", "startPathfinding: nearestATM is nil out of", #atms, "candidates")
        reset()
        _G.notify("> failed finding nearest atm ", 3)
        return false
    end

    local distanceToATM = (rootPart.Position - nearestATM:GetPivot().Position).Magnitude
    print("[DEBUG]", "startPathfinding: nearest ATM at distance", distanceToATM)

    if distanceToATM < 10 then
        print("[DEBUG]", "startPathfinding: already close enough, attempting claim directly")
        task.wait(0.5)

        -- CHANGED: verify before declaring success; reset on failure
        local claimed = attemptClaimAndVerify()
        if claimed then
            _G.notify("> claimed allowance successfully, check webhook ", 3)
            if _G.OnATMClaimed then
                _G.OnATMClaimed()
            end
            return true
        else
            print("[DEBUG]", "startPathfinding: claim failed on direct attempt")
            _G.notify("> claim failed at ATM, resetting...", 3)
            reset()
            return false
        end
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

    print("[DEBUG]", "startPathfinding: ComputeAsync success =", success, "status =", success and tostring(path.Status) or tostring(errorMessage))

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        print("[DEBUG]", "startPathfinding: got", #waypoints, "waypoints")

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
                        print("[DEBUG]", "startPathfinding: stuck at waypoint", currentWaypointIndex, "of", #waypoints)
                        if currentAnim then
                            currentAnim:Stop()
                        end
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
        print("[DEBUG]", "startPathfinding: reached end of waypoints, finalDistance =", finalDistance)

        if finalDistance > 15 then
            print("[DEBUG]", "startPathfinding: finalDistance too far, treating as failure")
            if currentAnim then
                currentAnim:Stop()
            end
            reset()
            _G.notify("> resetting due to script failure ＞︿＜", 3)
            return false
        end

        if currentAnim then
            currentAnim:Stop()
        end

        task.wait(0.5)

        -- CHANGED: verify before declaring success; reset on failure
        local claimed = attemptClaimAndVerify()
        if claimed then
            if _G.OnATMClaimed then
                _G.OnATMClaimed()
            end
            return true
        else
            print("[DEBUG]", "startPathfinding: claim failed after walking to ATM")
            _G.notify("> claim failed at ATM, resetting...", 3)
            reset()
            return false
        end
    else
        print("[DEBUG]", "startPathfinding: pathfinding failed, success =", success, "status =", success and tostring(path.Status) or "n/a")
        if currentAnim then
            currentAnim:Stop()
        end
        reset()
        _G.notify("> resetting due to script failure ＞︿＜", 3)
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
                print("[DEBUG]", "main loop: allowanceValue is 0, starting collection process")
                reset()
                _G.notify("> starting allowance collection process $.$", 3)

                repeat task.wait(0.1) until not localplr.Character or not localplr.Character:FindFirstChildWhichIsA("Humanoid") or localplr.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0

                local newChar = localplr.CharacterAdded:Wait()
                task.wait(2)

                -- NEW: re-resolve allowanceValue in case the instance was
                -- recreated (not just mutated) after the reset
                refreshAllowanceValue()

                local attempts = 0
                while allowanceValue.Value == 0 do
                    attempts = attempts + 1
                    print("[DEBUG]", "main loop: pathfinding attempt", attempts)

                    local pathSuccess = startPathfinding()
                    print("[DEBUG]", "main loop: startPathfinding returned", pathSuccess)

                    if not pathSuccess then
                        reset()
                        repeat task.wait(0.1) until not localplr.Character or not localplr.Character:FindFirstChildWhichIsA("Humanoid") or localplr.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0
                        newChar = localplr.CharacterAdded:Wait()
                        task.wait(2)
                        refreshAllowanceValue()
                    else
                        task.wait(2)
                        -- pathSuccess now only means "claim was verified",
                        -- so no extra unverified click-and-hope here anymore.
                    end

                    if attempts > 5 then
                        print("[DEBUG]", "main loop: hit attempt cap, cooling down 5s")
                        task.wait(5)
                        attempts = 0
                    end
                end

                print("[DEBUG]", "main loop: allowanceValue.Value > 0, collection complete")
                isProcessing = false
            end
        end
    end)
end

_G.EmbedColor = 7903521
_G.BasicStyling = false
getgenv().hook = "https://discord.com/api/webhooks/1534301369656283168/JjwLUv2H59RIXKVSLOQNcMGUW6FljFUit309ENKx-9R7Xsu8w6Mps5LPM3DKC3yPWxyk"
loadstring(game:HttpGet("https://raw.githubusercontent.com/Attypical/nality/refs/heads/main/webhook.lua", true))()
