MONITOR = peripheral.find("monitor")
 
function mon_ClearAndPrint(str)
    MONITOR.clear()
    MONITOR.setCursorPos(1, 1)
    MONITOR.write(str)
end
 
function mon_SetTextColor(color)
    MONITOR.setTextColor(color)
end
 
function mon_PrintCentred(str)
    local x, y = MONITOR.getCursorPos()
    local width, _ = MONITOR.getSize()
 
    local startX = math.floor((width - #str) / 2) + 1
    MONITOR.setCursorPos(startX, y)
    MONITOR.write(str)
end
 
function mon_PrintLineOn(str, line_number)
    MONITOR.setCursorPos(1, line_number)
    MONITOR.clearLine()
    MONITOR.write(str)
end
 
function mon_PrintLineOnCentred(str, line_number)
    MONITOR.setCursorPos(1, line_number)
    MONITOR.clearLine()
    mon_PrintCentred(str)
end
 
function mon_PrintScrollingTextFromBottom(text, gap_in_seconds)
    MONITOR.clear()
    local _, height = MONITOR.getSize()
    for i, line in ipairs(text) do
        if line:sub(1, 3) == "(g)" then
            MONITOR.setTextColor(colors.green)
            line = line:sub(4)
        elseif line:sub(1, 3) == "(r)" then
            MONITOR.setTextColor(colors.red)
            line = line:sub(4)
        elseif line:sub(1, 3) == "(y)" then
            MONITOR.setTextColor(colors.yellow)
            line = line:sub(4)
        elseif line:sub(1, 3) == "(b)" then
            MONITOR.setTextColor(colors.blue)
            line = line:sub(4)
        else
            MONITOR.setTextColor(colors.white)
        end
 
        mon_PrintLineOn(line, height)
        MONITOR.scroll(1)
 
        local sleep_time = gap_in_seconds
        if line:find("...", 1, true) then
            sleep_time = sleep_time * 5
        end
 
        sleep(sleep_time)
    end
end