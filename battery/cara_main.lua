require "cara_generic_api"

CARA_MAIN_ID = -1
 
function main()
    -- Init network
    rednet.open("top")
    print("Attempting connection to CARA...")
    while true do
        local senderID, message, protocol = rednet.receive("cara_send", 1)

        if senderID ~= nil then
            if message == "acquire_clients" then
                CARA_MAIN_ID = senderID
                rednet.send(senderID, "battery_agent_acquired", "cara_receive")
                break
            end
        end
    end
    print("Connected to CARA.")
 
    while true do
        local event = { os.pullEvent() }
 
        if event[1] == "key" then
            if event[2] == keys.q then
                break
            end
        end
    end
 
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)

    rednet.close()
end
 
main()