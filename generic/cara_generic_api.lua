function readFileToTable(path)
    if not fs.exists(path) then
        return nil, "File does not exist"
    end
 
    local file = fs.open(path, "r")
    if not file then
        return nil, "Failed to open file"
    end
 
    local lines = {}
 
    while true do
        local line = file.readLine()
        if line == nil then
            break
        end
 
        table.insert(lines, line)
    end
 
    file.close()
 
    return lines
end
 
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
 
    return false
end
 
function printKeys(tab)
    -- Source - https://stackoverflow.com/a/12674376
    -- Posted by lhf
    -- Retrieved 2026-06-11, License - CC BY-SA 3.0
 
    local keyset={}
    local n=0
 
    for k,v in pairs(tab) do
        n=n+1
        keyset[n]=k
    end
 
    print(textutils.serialise(keyset))
end