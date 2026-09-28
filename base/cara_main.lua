-- This is the primary Operating System for CARA (Computer-Aided Reliance Assistant)
 
require "cara_generic_api"
require "cara_monitor_api"
 
local ui = require "cara_ui"
local screenManager = require "cara_screen_manager"
 
function startupSequence()
    local opening_text, err = readFileToTable("/cara_src/cara_opening_text.txt")
    if not opening_text then
        mon_ClearAndPrint(err, 1)
        return
    end
 
    mon_PrintScrollingTextFromBottom(opening_text, 0.01)
end
 
local screens = {
    require("screens.cara_primary_screen"),
    require("screens.cara_power_screen")
}
 
local network = {
    interaction_agent = nil
}
 
function main()
    -- Init Network
    rednet.open("top")
    rednet.broadcast("acquire_clients", "cara_send")
 
    -- Init UI
    ui.setTarget(MONITOR)
    ui.setTextScale(1)
 
    startupSequence()
    sleep(0.5)
    MONITOR.clear()
 
    ui.resetStyle()
    ui.setTextScale(1.5)
 
    for _, screen in ipairs(screens) do
        screen["network"] = network
        screenManager.append(screen)
    end
 
    while true do
        local current = screenManager.current()
        if current == nil then
            break
        end
        
        if ui.isDirty() then
            ui.clear()
            current.draw(ui)
            ui.validate()
        end
 
        local event = { os.pullEvent() }
 
        if event[1] == "key" then
            local action = current.key(event[2])
 
            if action then
                if action.type == "quit" then
                    break
                elseif action.type == "close" then
                    os.shutdown()
                elseif action.type == "switch" then
                    if action.screen == "next" then
                        screenManager.next()
                    elseif action.screen == "prev" then
                        screenManager.prev()
                    elseif type(action.screen) == "number" then
                        screenManager.switchTo(action.screen)
                    end
                end
            end
        end
    end
 
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end
 
main()