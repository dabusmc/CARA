local ui = require "basil_ui"
 
local ResourcesScreen = {}
ResourcesScreen.selectedButton = 1
 
function ResourcesScreen.incrementSelectedButton()
    if ResourcesScreen.selectedButton < 2 then
        ResourcesScreen.selectedButton = ResourcesScreen.selectedButton + 1
    end
end
 
function ResourcesScreen.decrementSelectedButton()
    if ResourcesScreen.selectedButton > 1 then
        ResourcesScreen.selectedButton = ResourcesScreen.selectedButton - 1
    end
end
 
function ResourcesScreen.draw()
    local panelRect = ui.layout.full()
    local contentArea = ui.widgets.panel(panelRect, "CARA Resources", "center")
 
    local menu = ui.layout.verticalStack(contentArea, 20, 3, 2, 1)
    ui.widgets.button(menu[1], "Power", ResourcesScreen.selectedButton == 1)
    ui.widgets.button(menu[2], "Back", ResourcesScreen.selectedButton == 2)
end
 
function ResourcesScreen.key(key)
    if key == keys.up then
        ResourcesScreen.decrementSelectedButton()
        ui.invalidate()
    elseif key == keys.down then
        ResourcesScreen.incrementSelectedButton()
        ui.invalidate()
    elseif key == keys.enter then
        if ResourcesScreen.selectedButton == 1 then
        elseif ResourcesScreen.selectedButton == 2 then
            return {
                type = "switch",
                screen = "prev"
            }
        end
    end
 
    return nil
end
 
function ResourcesScreen.tick()
end
 
return ResourcesScreen