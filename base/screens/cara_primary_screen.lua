local ui = require "basil_ui"
 
local PrimaryScreen = {}
 
function PrimaryScreen.draw()
    local panelRect = ui.layout.full()
    local contentArea = ui.widgets.panel(panelRect, "Computer-Aided Reliance Assistant", "center")
end
 
function PrimaryScreen.key(key)
    if key == keys.q then
        return {
            type = "quit"
        }
    end
 
    return nil
end
 
function PrimaryScreen.tick()
end
 
return PrimaryScreen