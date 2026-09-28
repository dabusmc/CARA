-- This code is a part of generic/cara_generic_api.lua. Gathering that file is too complicated with this setup at this specific point in the process, so we just copy the functions here for now
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
----------------------------------------------------------------------

BASE_URL = "https://raw.githubusercontent.com/dabusmc/CARA/refs/heads/main/"

function download(path, destination)
    local final_path = BASE_URL .. path .. "?cache_bust=" .. os.epoch("utc")

    local allowed, reason = http.checkURL(final_path)
    if not allowed then
        print("URL not allowed for " .. path .. ": " .. reason)
        return false
    end

    local response, err = http.get(final_path)
    if not response then
        print("Download failed: " .. err)
        return false
    end

    local file = fs.open(destination, "w")
    if file == nil then
        print("Failed to open file " .. destination)
        response.close()
        return false
    end

    file.write(response.readAll())
    file.close()

    response.close()

    print("Downloading: " .. path)

    return true
end

function createDirIfNotExist(dir)
    local exists = fs.exists(dir)
    if not exists then
        fs.makeDir(dir)
    end
end

function downloadManifest(manifest, manifest_path, strip_top_path)
    local manifest_files = readFileToTable(manifest_path)
    if manifest_files == nil then
        return
    end

    for i, manifest_file_path in ipairs(manifest_files) do
        -- Strip manifest folder name
        local manifest_folder
        if strip_top_path then
            local position = string.find(manifest_file_path, "/")
            manifest_folder = string.sub(manifest_file_path, 1, position)
        else
            manifest_folder = manifest .. "/"
        end
        local file_path = manifest_file_path:gsub(manifest_folder, "")

        -- Determine if the file is in a subfolder
        if string.find(file_path, "/") then
            local directory = file_path:match("(.+)/[^/]+$")
            createDirIfNotExist("/" .. directory)
        end

        -- Download the file
        print("Downloading " .. file_path .. "...")
        if not download(manifest_file_path, "/" .. file_path) then
            return false
        end
    end

    return true
end

function main(...)
    -- Gather inputted args
    local args = { ... }
    
    if #args ~= 1 then
        print("Usage: cara_initialize <instance>")
        return
    end

    -- Cleanup existing root
    local files = fs.list("/")
    for _, file in ipairs(files) do
        if file ~= "rom" and file ~= "update" and file ~= "cara_initialize.lua" then
            fs.delete("/" .. file)
        end
    end

    -- Download Manifest Files
    createDirIfNotExist("/manifests")
    if not download("manifests/manifests.txt", "/manifests/manifests.txt") then
        return
    end

    local known_manifests = readFileToTable("/manifests/manifests.txt")
    if known_manifests == nil then
        return
    end

    for i, manifest in ipairs(known_manifests) do
        local path = "manifests/" .. manifest
        if not download(path, "/" .. path) then
            return
        end
    end

    print("Downloaded Manifests.")

    -- Download generic files
    print("Downloading generic files...")
    if not downloadManifest("generic", "/manifests/generic.txt", true) then
        return
    end
    print("Downloaded generic files.")

    -- Determine instance manifest
    local instance = args[1]
    if not hasValue(known_manifests, instance .. ".txt") or instance == "generic" then
        print("Instance " .. instance .. " is not recognised.")
        return
    end

    local instance_manifest_filepath = "/manifests/" .. instance .. ".txt"

    -- Download instance files
    print("Downloading files for instance " .. instance .. "...")
    if not downloadManifest(instance, instance_manifest_filepath, false) then
        return
    end
    print("Downloaded files for instance " .. instance .. ".")

    -- Cleanup installer-only state
    fs.delete("/manifests")
end

main(...)