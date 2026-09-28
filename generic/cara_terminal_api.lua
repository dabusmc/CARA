TERM_WIDTH, TERM_HEIGHT = term.getSize()
 
function term_PrintCentered(y, str)
   local x = math.floor((TERM_WIDTH - string.len(str)) / 2)
   term.setCursorPos(x, y)
   term.clearLine()
   term.write(str)
end
 
function term_PrintThird(y, third, str)
    local third_width = TERM_WIDTH / 3
 
    -- Centre position of the requested third
    local centre_x = (third - 0.5) * third_width
 
    local x = math.floor(centre_x - (#str / 2))
 
    term.setCursorPos(x, y)
    term.write(str)
end