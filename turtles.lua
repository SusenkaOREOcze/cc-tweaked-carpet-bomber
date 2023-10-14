function findDiskDirectories(path)
    local dirs = fs.list(path)
    local diskDirs = {}

    for _, dir in ipairs(dirs) do
        local fullPath = fs.combine(path, dir)
        if fs.isDir(fullPath) and string.find(dir, "disk") then
            table.insert(diskDirs, fullPath)
        end
    end

    return diskDirs
end

local diskDirs = findDiskDirectories("/")

print("Copying TURTLE/ to all turtles and pockets")
print("------------------------------------------")
for i, value in ipairs(diskDirs) do
    if fs.exists(value .. "/TURTLE") then
        shell.run("delete " .. value .. "/TURTLE")
    end
    shell.run("copy TURTLE/ " .. value)
    print("Copying TURTLE/ to " .. value)
end
print("------------------------------------------")
print("Done")