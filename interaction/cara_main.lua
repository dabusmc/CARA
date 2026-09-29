require "cara_generic_api"
local ui = require "basil_ui"
local screenManager = require "basil_screen_manager"
 
local screens = {
    require("screens.cara_startup_screen"),
    require("screens.cara_resources_screen")
}

CARA_MAIN_ID = -1
 
function main()
    -- Init network
    rednet.open("bottom")
    print("Attempting connection to CARA...")
    while true do
        local senderID, message, protocol = rednet.receive("cara_send", 1)

        if senderID ~= nil then
            if message == "acquire_clients" then
                CARA_MAIN_ID = senderID
                rednet.send(senderID, "interaction_agent_acquired", "cara_receive")
                break
            end
        end
    end
    print("Connected to CARA.")

    -- Init UI
    for _, screen in ipairs(screens) do
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
                        ui.invalidate()
                        rednet.send(CARA_MAIN_ID, "switchto_1", "cara_receive")
                    elseif action.screen == "prev" then
                        screenManager.prev()
                        ui.invalidate()
                        rednet.send(CARA_MAIN_ID, "switchto_1", "cara_receive")
                    elseif type(action.screen) == "number" then
                        screenManager.switchTo(action.screen)
                        ui.invalidate()
                        rednet.send(CARA_MAIN_ID, "switchto_1", "cara_receive")
                    end
                elseif action.type == "network" then
                    local msg = action.msg
                    rednet.send(CARA_MAIN_ID, msg, "cara_receive")
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