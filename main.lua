-- RUN THIS: loadstring(game:HttpGet("https://github.com/rynxlol/LoggerPlus/blob/main/main.lua"))()
-- LoggerPlus by Rynx

local runService = game:GetService("RunService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

local player = players.LocalPlayer

local mainInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local minimized = false
local loggedImages = {}
local loggedSounds = {}

local FRAME_DEFAULT_SIZE = UDim2.new(0, 400, 0, 300)
local MAIN_DEFAULT_SIZE = UDim2.new(0.9, 0, 0.9, 0)

local gui = Instance.new("ScreenGui")
gui.Name = "LoggerPlus"
gui.Parent = runService:IsStudio() and player.PlayerGui or game.CoreGui

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
frame.BorderSizePixel = 0
frame.Size = FRAME_DEFAULT_SIZE
frame.Position = UDim2.new(0.5, 0, 0.5, 0)

Instance.new("UICorner", frame)

local BLUR_RADIUS_DEFAULT = UDim.new(0.1, 0)
local TRANSPARENCY_SHADOW_DEFUALT = 0.75

local uiShadow = Instance.new("UIShadow", frame)
uiShadow.BlurRadius = BLUR_RADIUS_DEFAULT
uiShadow.Transparency = TRANSPARENCY_SHADOW_DEFUALT

local tweeningShadow = false

local function tweenShadow(properties)
    if tweeningShadow then return end
    
    local tween = tweenService:Create(uiShadow, mainInfo, properties)
    tween:Play()
    
    tweeningShadow = true
    
    tween.Completed:Wait()
    
    tweeningShadow = false
end

local uiDrag = Instance.new("UIDragDetector", frame)
uiDrag.DragStart:Connect(function()
    tweenShadow({BlurRadius = UDim.new(0.2, 0), Transparency = 0.25})
end)
uiDrag.DragEnd:Connect(function()
    tweenShadow({BlurRadius = BLUR_RADIUS_DEFAULT, Transparency = TRANSPARENCY_SHADOW_DEFUALT})
end)

local function createInstance(className, parent: Instance)
    local guiInstance = Instance.new(className, parent)
    guiInstance.BackgroundTransparency = 1
    guiInstance.BorderSizePixel = 0
    
    if className:find("Text") then
        guiInstance.TextColor3 = Color3.new(1, 1, 1)
        guiInstance.TextSize = 10
        
        if className:find("Box") then
            guiInstance.TextEditable = false
        end
    end
    
    return guiInstance
end

local main = createInstance("Frame", frame)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Name = "Main"
main.Size = MAIN_DEFAULT_SIZE
main.Position = UDim2.new(0.5, 0, 0.5, 0)

-- Contents

local contents = createInstance("Frame", main)
contents.Name = "Contents"
contents.Size = UDim2.new(1, 0, 0.825, 0)
contents.Position = UDim2.new(0, 0, 0.125, 0)

-- Tabs

local tabs = createInstance("Frame", contents)
tabs.AnchorPoint = Vector2.new(0.5, 0)
tabs.BackgroundColor3 = Color3.new(0, 0, 0)
tabs.BackgroundTransparency = 0
tabs.Name = "Tabs"
tabs.Size = UDim2.new(0.9, 0, 0, 30)
tabs.Position = UDim2.new(0.5, 0, 0, 0)

Instance.new("UICorner", tabs)

local tabHighlighter = createInstance("Frame", tabs)
tabHighlighter.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
tabHighlighter.BackgroundTransparency = 0
tabHighlighter.Size = UDim2.new(0.5, 0, 1, 0)

Instance.new("UICorner", tabHighlighter)

local highlighterShadow = Instance.new("UIShadow", tabHighlighter)
highlighterShadow.BlurRadius = UDim.new(0.1, 0)
highlighterShadow.Color = tabHighlighter.BackgroundColor3
highlighterShadow.Transparency = 0.25

local bindedFrames = {}
local highlighterTweening = false

local function tweenShiftHighlight(pos: UDim2)
    if highlighterTweening then return end
    
    local tween = tweenService:Create(tabHighlighter, mainInfo, {Position = pos})
    tween:Play()
    
    highlighterTweening = true
    tween.Completed:Wait()
    highlighterTweening = false
end

local function createTab(tabName: string, bindFrame: Frame)
    local tab = createInstance("TextButton", tabs)
    tab.Size = UDim2.new(0.5, 0, 1, 0)
    tab.Text = tabName
    tab.TextSize = 12
    tab.MouseButton1Click:Connect(function()
        for _, binded in bindedFrames do
            if binded ~= bindFrame then
                binded.Visible = false
            end
        end
        bindFrame.Visible = true
        tweenShiftHighlight(tab.Position)
    end)
    
    table.insert(bindedFrames, bindFrame)
    return tab
end

-- Scrolling Frames

local function createScrollingFrame(frameName: string)
    local scrollingFrame = createInstance("ScrollingFrame", contents)
    scrollingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrollingFrame.BackgroundTransparency = 0
    scrollingFrame.Name = frameName
    scrollingFrame.Size = UDim2.new(1, 0, 0.85, 0)
    scrollingFrame.Position = UDim2.new(0, 0, 0.2, 0)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local uiList = Instance.new("UIListLayout", scrollingFrame)
    uiList.Padding = UDim.new(0, 10)
    uiList.FillDirection = Enum.FillDirection.Horizontal
    uiList.Wraps = true
    
    local uiPadding = Instance.new("UIPadding", scrollingFrame)
    uiPadding.PaddingLeft = UDim.new(0, 8)
    uiPadding.PaddingTop = UDim.new(0, 10)
    
    Instance.new("UICorner", scrollingFrame)
    
    return scrollingFrame
end

local imagesFrame = createScrollingFrame("Images")
local soundsFrame = createScrollingFrame("Sounds")

soundsFrame.Visible = false

createTab("Images", imagesFrame)
createTab("Sounds", soundsFrame).Position = UDim2.new(0.5, 0, 0, 0)

-- Log Functions

local tweeningId = false
local playingSound = false

local loggerPlus = {}

local function tweenId(obj, showId: boolean)
    if tweeningId then return end
    
    local properties = {}
    
    if showId then
        properties.BackgroundTransparency = 0.5
        properties.TextTransparency = 0
    else
        properties.BackgroundTransparency = 1
        properties.TextTransparency = 1
    end
    
    local tween = tweenService:Create(obj, mainInfo, properties)
    tween:Play()
    
    tweeningShadow = true
    
    tween.Completed:Wait()
    
    tweeningShadow = false
end

function loggerPlus:LogImage(id: string)
    if table.find(loggedImages, id) then return end
    
    local numberId = id:split("//")[2]
    
    local IMAGE_HEIGHT = 100
    
    local image = createInstance("ImageLabel", imagesFrame)
    image.BackgroundColor3 = Color3.new(1, 1, 1)
    image.BackgroundTransparency = 0
    image.Name = "Logged_" .. id
    image.Size = UDim2.new(0, 160, 0, IMAGE_HEIGHT)
    image.Image = id
    
    local idDisplay: TextBox = createInstance("TextBox", image)
    idDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
    idDisplay.BackgroundTransparency = 1
    idDisplay.Name = "ID Display"
    idDisplay.Size = UDim2.new(1, 0, 1, 0)
    idDisplay.Text = numberId
    idDisplay.TextTransparency = 1
    
    local images = #imagesFrame:GetChildren() - 3
    local rows = math.ceil(images / 2)
    local canvasHeight = (rows * IMAGE_HEIGHT) + ((rows + 1) * 10)
    
    imagesFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    
    table.insert(loggedImages, id)
    
    image.MouseEnter:Connect(function() tweenId(idDisplay, true) end)
    image.MouseLeave:Connect(function() tweenId(idDisplay, false) end)
end

function loggerPlus:LogSound(id: string)
    if table.find(loggedSounds, id) then return end
    
    local numberId = id:split("//")[2]
    
    local SOUND_HEIGHT = 50
    
    local sound = createInstance("Frame", soundsFrame)
    sound.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    sound.BackgroundTransparency = 0
    sound.Name = "Logged_" .. id
    sound.Size = UDim2.new(0.95, 0, 0, SOUND_HEIGHT)
    
    local playButton = createInstance("TextButton", sound)
    playButton.AnchorPoint = Vector2.new(0, 0.5)
    playButton.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    playButton.BackgroundTransparency = 0
    playButton.Name = "Play"
    playButton.Size = UDim2.new(0, 40, 0, 40)
    playButton.Position = UDim2.new(0, 10, 0.5, 0)
    playButton.Text = ""
    
    local playImage = createInstance("ImageLabel", playButton)
    playImage.AnchorPoint = Vector2.new(0.5, 0.5)
    playImage.Size = UDim2.new(0.6, 0, 0.6, 0)
    playImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    playImage.Image = "rbxassetid://" .. 8517323790 -- Play image
    
    local soundItem = Instance.new("Sound", sound)
    soundItem.SoundId = id
    
    playButton.MouseButton1Click:Connect(function()
        if playingSound then return end
        
        playImage.Image = "rbxassetid://" .. 99514193135085 -- Pause image
        soundItem:Play()
        
        playingSound = true
        
        soundItem.Ended:Wait()
        playImage.Image = "rbxassetid://" .. 8517323790
        
        playingSound = false
    end)
    
    soundItem.Stopped:Connect(function()
        playImage.Image = "rbxassetid://" .. 8517323790
        playingSound = false
    end)
    
    Instance.new("UICorner", playButton).CornerRadius = UDim.new(1, 0)
    
    local idDisplay = createInstance("TextBox", sound)
    idDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
    idDisplay.Name = "ID Display"
    idDisplay.Size = UDim2.new(0.5, 0, 0.9, 0)
    idDisplay.Position = UDim2.new(0.5, 0, 0.5, 0)
    idDisplay.Text = numberId
    idDisplay.TextSize = 18
    
    local sounds = #soundsFrame:GetChildren() - 3
    local rows = math.ceil(sounds / 1)
    local canvasHeight = (rows * SOUND_HEIGHT) + ((rows + 1) * 10)

    soundsFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    
    Instance.new("UICorner", sound)
    
    table.insert(loggedSounds, id)
end

-- Top Bar

local topBar = createInstance("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 20)
topBar.Name = "TopBar"

local titleLabel = createInstance("TextLabel", topBar)
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.Name = "Title"
titleLabel.Text = "LoggerPlus - Rynx"

local sizeTweening = false
local tweeningSizes = 0

local minimizeButton = createInstance("TextButton", topBar)
minimizeButton.Size = UDim2.new(0.1, 0, 1, 0)
minimizeButton.Position = UDim2.new(0.8, 0, 0 ,0)
minimizeButton.Text = "-"
minimizeButton.TextScaled = true
minimizeButton.MouseButton1Click:Connect(function()
    local buttonText = "-"
    
    local function tweenSize(obj, size)
        if sizeTweening and tweeningSizes >= 2 then return end
        
        local tween = tweenService:Create(obj, mainInfo, {Size = size})
        tween:Play()

        sizeTweening = true
        tweeningSizes += 1
        
        tween.Completed:Wait()
        
        sizeTweening = false
        tweeningSizes -= 1
    end
    
    minimized = not minimized
    if minimized then
        contents.Visible = false
        task.spawn(function() tweenSize(frame, UDim2.new(0, 400, 0, 35)) end)
        task.spawn(function() tweenSize(main, UDim2.new(0.9, 0, 0.6, 0)) end)
        buttonText = "+"
    else
        task.spawn(function() tweenSize(frame, FRAME_DEFAULT_SIZE) end)
        task.spawn(function() tweenSize(main, MAIN_DEFAULT_SIZE) end)
        buttonText = "-"
        task.wait(0.25)
        contents.Visible = true
    end
    
    minimizeButton.Text = buttonText
end)

local closeButton = createInstance("TextButton", topBar)
closeButton.Size = UDim2.new(0.1, 0, 1, 0)
closeButton.Position = UDim2.new(0.9, 0, 0, 0)
closeButton.Text = "x"
closeButton.TextScaled = true
closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

return loggerPlus
