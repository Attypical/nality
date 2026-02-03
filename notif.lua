local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up existing GUI if it exists
if playerGui:FindFirstChild("GreentextNotifGui") then
	playerGui:FindFirstChild("GreentextNotifGui"):Destroy()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GreentextNotifGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global  -- Changed to Global
screenGui.DisplayOrder = 999999  -- Added DisplayOrder
screenGui.Parent = playerGui

-- Create Frame
local Frame = Instance.new("Frame")
Frame.Parent = screenGui
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BackgroundTransparency = 1.000
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(0, 2000, 0, 822)
Frame.ZIndex = 99999

-- Create TextLabel
local greenreply = Instance.new("TextLabel")
greenreply.Name = "GreentextLabel"
greenreply.Parent = Frame
greenreply.Active = true
greenreply.BackgroundColor3 = Color3.fromRGB(10, 10, 10)  -- Very dark gray
greenreply.BackgroundTransparency = 0.65  -- Semi-transparent
greenreply.BorderSizePixel = 0
greenreply.Position = UDim2.new(0, -244, 0, -244)
greenreply.Size = UDim2.new(0, 648, 0, 18)
greenreply.ZIndex = 99999
greenreply.Font = Enum.Font.GothamSemibold
greenreply.Text = ""
greenreply.TextColor3 = Color3.fromRGB(120, 153, 33)
greenreply.TextSize = 26.000
greenreply.TextStrokeTransparency = 0.5  -- Moderate stroke
greenreply.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
greenreply.TextWrapped = true
greenreply.TextXAlignment = Enum.TextXAlignment.Left
greenreply.TextYAlignment = Enum.TextYAlignment.Top

-- Add rounded corners for polish
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 4)
uiCorner.Parent = greenreply

-- Add padding
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 10)
uiPadding.PaddingRight = UDim.new(0, 10)
uiPadding.PaddingTop = UDim.new(0, 3)
uiPadding.PaddingBottom = UDim.new(0, 3)
uiPadding.Parent = greenreply

-- Animation positions
local pos1 = UDim2.new(0, -40, 0, 350) 
local pos2 = UDim2.new(0, 30, 0, 350)

-- Track if animation is currently playing
local isAnimating = false
local animationQueue = {}

-- Function to show notification
local function showNotification(text, duration)
	duration = duration or 5
	
	-- Add to queue if already animating
	if isAnimating then
		table.insert(animationQueue, {text = text, duration = duration})
		return
	end
	
	isAnimating = true
	
	-- Set the text
	greenreply.Text = text
	
	-- SET INITIAL POSITION (off screen and invisible)
-- SET INITIAL POSITION (off screen and invisible)
greenreply.Position = pos1
greenreply.TextTransparency = 1
greenreply.BackgroundTransparency = 1  -- Add this
	
	-- Create intro tween (move AND fade in)
	local tweenInfo = TweenInfo.new(
		0.5,                          
		Enum.EasingStyle.Sine,     
		Enum.EasingDirection.InOut,       
		0,                           
		false,        
		0                                 
	)
	
-- In the intro tween
local tweenintro = TweenService:Create(
	greenreply,
	tweenInfo,
	{
		Position = pos2,
		TextTransparency = 0,
		BackgroundTransparency = 0.65  -- Add this
	}
)

-- In the outro tween
	tweenintro:Play()
	tweenintro.Completed:Wait()
	
	-- Wait for display time
	task.wait(duration)
	
	-- Create and play outro tween
	local tweenInfoOutro = TweenInfo.new(
		0.2,                             
		Enum.EasingStyle.Linear,           
		Enum.EasingDirection.InOut,      
		0,                                
		false,                           
		0                                 
	)
	
local tweenoutro = TweenService:Create(
	greenreply,
	tweenInfoOutro,
	{
		TextTransparency = 1,
		BackgroundTransparency = 1  -- Add this
	}
)	
	
	tweenoutro:Play()
	tweenoutro.Completed:Wait()
	
	isAnimating = false
	
	-- Process queue
	if #animationQueue > 0 then
		local nextItem = table.remove(animationQueue, 1)
		showNotification(nextItem.text, nextItem.duration)
	end
end

_G.showNotification = showNotification
_G.notify = showNotification
