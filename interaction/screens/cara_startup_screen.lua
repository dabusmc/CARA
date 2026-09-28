local ui = require "cara_ui"
 
local StartupScreen = {}
StartupScreen.selectedButton = 1
 
function StartupScreen.incrementSelectedButton()
    if StartupScreen.selectedButton < 3 then
        StartupScreen.selectedButton = StartupScreen.selectedButton + 1
    end
end
 
function StartupScreen.decrementSelectedButton()
    if StartupScreen.selectedButton > 1 then
        StartupScreen.selectedButton = StartupScreen.selectedButton - 1
    end
end
 
function StartupScreen.draw()
    local panelRect = ui.layout.full()
    local contentArea = ui.widgets.panel(panelRect, "CARA Interaction System", "center")
 
    local menu = ui.layout.verticalStack(contentArea, 20, 3, 3, 1)
    ui.widgets.button(menu[1], "Resources", StartupScreen.selectedButton == 1)
    ui.widgets.button(menu[2], "Maintainence", StartupScreen.selectedButton == 2)
    ui.widgets.button(menu[3], "Shutdown", StartupScreen.selectedButton == 3)
end
 
function StartupScreen.key(key)
    if key == keys.up then
        StartupScreen.decrementSelectedButton()
        ui.invalidate()
    elseif key == keys.down then
        StartupScreen.incrementSelectedButton()
        ui.invalidate()
    elseif key == keys.enter then
        if StartupScreen.selectedButton == 1 then
        elseif StartupScreen.selectedButton == 2 then
            return {
                type = "quit"
            }
        elseif StartupScreen.selectedButton == 3 then
            return {
                type = "close"
            }
        end
    end
 
    return nil
end
 
function StartupScreen.tick()
end
 
return StartupScreen