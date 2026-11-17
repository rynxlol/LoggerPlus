# Make It Work For You!
LoggerPlus is a universal script meant to work with every game, but not all games will work the same.
Fortunately, the script does provide the functions you can use to add the logs.

---

## Loading The Script
Access the main script to use the functions.

```lua
local loggerPlus = loadstring(game:HttpGet("https://github.com/rynxlol/LoggerPlus/blob/main/main.lua"))()
```

---

## Functions
These are your main functions to capture the assets. They both take a string in the argument, not a number.

### Image
```lua
local imageId = "rbxassetid://12345678"
loggerPlus:LogImage(imageId)
```

### Sound
```lua
local soundId = "rbxassetid://12345678"
loggerPlus:LogSound(soundId)
```
