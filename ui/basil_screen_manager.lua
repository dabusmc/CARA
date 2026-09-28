local screenManager = {}
screenManager.screens = {}
screenManager.currentScreen = 0
    
function screenManager.append(screen)
    table.insert(screenManager.screens, #screenManager.screens + 1, screen)
    
    if screenManager.currentScreen == 0 then
        screenManager.currentScreen = 1
    end 
end
    
function screenManager.current()
    if screenManager.currentScreen >= 1 and screenManager.currentScreen <= #screenManager.screens then
        return screenManager.screens[screenManager.currentScreen]
    end
    
    return nil
end
    
function screenManager.next()
    screenManager.switchTo(screenManager.currentScreen + 1)
end
    
function screenManager.prev()
    screenManager.switchTo(screenManager.currentScreen - 1)
end
    
function screenManager.switchTo(index)
    if index >= 1 and index <= #screenManager.screens then
        screenManager.currentScreen = index
    end
end
    
return screenManager