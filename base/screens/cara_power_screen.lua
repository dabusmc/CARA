local ui = require "cara_ui"
 
local PowerScreen = {}
 
function PowerScreen.draw()
    local panelRect = ui.layout.full()
    local contentArea = ui.widgets.panel(panelRect, "CARA Power Monitor", "center")
end
 
function PowerScreen.key(key)
    if key == keys.q then
        return {
            type = "quit"
        }
    end
 
    return nil
end
 
function PowerScreen.tick()
end
 
return PowerScreen