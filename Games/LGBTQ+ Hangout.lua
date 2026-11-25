-- COPY THIS: loadstring(game:HttpGet("https://raw.githubusercontent.com/rynxlol/LoggerPlus/refs/heads/main/Games/LGBTQ%2B%20Hangout.lua"))()
-- LGBTQ+ Hangout Script For Moderators by Rynx

local loggerPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/rynxlol/LoggerPlus/refs/heads/main/main.lua"))()

local players = game:GetService("Players")

for _, player in players:GetPlayers() do
    local char = player.Character or player.CharacterAdded:Wait()
    local flagName = "CustomFlag"
    
    local function logChild(child: Instance)
        -- Logs the main property
        
        -- Image
        if child:IsA("Decal") or child:IsA("Texture") or child.ClassName:find("Image") then
            local imageId = ""
            if child:IsA("Decal") or child:IsA("Texture") then
                imageId = child.Texture
            elseif child.ClassName:find("Image") and child:IsA("GuiObject") then
                imageId = child.ImageContent
            end
            
            loggerPlus:LogImage(imageId)
        end
        
        -- Sound
        if child:IsA("Sound") then
            loggerPlus:LogSound(child.SoundId)
        end
    end
    
    -- Logging images from custom flags
    local customFlag: Tool = player.Backpack:FindFirstChild(flagName) or char:FindFirstChild(flagName)
    if customFlag then
        local customFlagLeft: Decal = customFlag.Flag.CustomFlagLeft
        if customFlagLeft.Texture then logChild(customFlagLeft) end
        
        customFlagLeft.Changed:Connect(function() logChild(customFlagLeft) end)
    end
    
    -- Logging sounds from boomboxes
    local radioMesh: MeshPart = char:FindFirstChild("RadioMesh")
    if radioMesh then
        local sound = radioMesh:FindFirstChildOfClass("Sound")
        if sound then logChild(sound) end
        
        radioMesh.ChildAdded:Connect(logChild)
    end
end
