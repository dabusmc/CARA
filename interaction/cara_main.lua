require "cara_generic_api"
local ui = require "basil_ui"
local screenManager = require "basil_screen_manager"
 
local screens = {
    require("screens.cara_startup_screen")
}
 
function main()
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