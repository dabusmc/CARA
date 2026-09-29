-- This is the primary Operating System for CARA (Computer-Aided Reliance Assistant)
 
require "cara_generic_api"
require "cara_monitor_api"
 
local ui = require "basil_ui"
local screenManager = require "basil_screen_manager"
 
function startupSequence()
    local opening_text, err = readFileToTable("/cara_opening_text.txt")
    if not opening_text then
        mon_ClearAndPrint(err, 1)
        return false
    end
 
    mon_PrintScrollingTextFromBottom(opening_text, 0.01)
    return true
end
 
local screens = {
    require("screens.cara_primary_screen"),
    require("screens.cara_power_screen")
}
 
local network = {
    interaction_agent = nil
}

function acquireClients()
    local agentResponses = {
        interaction_agent_acquired = "interaction_agent"
    }
    local acquisition_rounds = 4
    local acquisition_timeout = 1
    
    for _ = 1, acquisition_rounds do
        rednet.broadcast("acquire_clients", "cara_send")

        while true do
            local senderID, message, protocol = rednet.receive("cara_receive", acquisition_timeout)

            if senderID == nil then
                break
            end

            local networkField = agentResponses[message]

            if networkField then
                network[networkField] = senderID
            end
        end
    end
end

function processNetworkMessage(sender, message)
    if sender == network.interaction_agent then
        if string.find(message, "switchto") then
            local position = string.find(message, "_")
            if position ~= nil then
                local scene = string.sub(message, position, #message)
                if string.match(scene, "^%d+$") ~= nil then
                    print("Switching to Scene " .. scene)
                    screenManager.switchTo(tonumber(scene))
                else
                    print("Can't switch to Scene " .. scene)
                end
            end
        end
    end
end
 
function main()
    -- Init UI
    ui.setTarget(MONITOR)
    ui.setTextScale(1)
 
    if not startupSequence() then
        rednet.close()
        return
    end

    sleep(0.5)
    MONITOR.clear()
 
    ui.resetStyle()
    ui.setTextScale(1.5)
 
    -- Init Network
    rednet.open("top")
    acquireClients()

    -- Prepare Screens
    for _, screen in ipairs(screens) do
        screen["network"] = network
        screenManager.append(screen)
    end
 
    while true do
        -- Get the current screen
        local current = screenManager.current()
        if current == nil then
            break
        end
        
        -- Redraw UI if necessary
        if ui.isDirty() then
            ui.clear()
            current.draw(ui)
            ui.validate()
        end
 
        -- Process Events
        local event = { os.pullEvent() }
 
        if event[1] == "key" then
            local action = current.key(event[2])
 
            if action then
                if action.type == "quit" then
                    break
                elseif action.type == "close" then
                    rednet.close()
                    os.shutdown()
                elseif action.type == "switch" then
                    if action.screen == "next" then
                        screenManager.next()
                        ui.invalidate()
                    elseif action.screen == "prev" then
                        screenManager.prev()
                        ui.invalidate()
                    elseif type(action.screen) == "number" then
                        screenManager.switchTo(action.screen)
                        ui.invalidate()
                    end
                end
            end
        end

        -- Handle Network Messages
        local senderID, message, protocol = rednet.receive("cara_receive", 0.5)
        if senderID ~= nil then
            processNetworkMessage(senderID, message)
        end
    end
 
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)

    rednet.close()
end
 
main()