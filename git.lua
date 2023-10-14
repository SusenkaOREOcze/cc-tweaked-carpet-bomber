local function copyFolder(sourcePath, destPath)
    -- create the destination directory if it does not exist
    if not fs.exists(destPath) then
        fs.makeDir(destPath)
    end

    -- list all items in the source directory
    local items = fs.list(sourcePath)
    for _, item in ipairs(items) do
        local fullSourcePath = fs.combine(sourcePath, item)
        local fullDestPath = fs.combine(destPath, item)

        if fs.isDir(fullSourcePath) then
            -- if the item is a directory, copy it recursively
            copyFolder(fullSourcePath, fullDestPath)
        else
            -- if the item is a file, copy it
            fs.copy(fullSourcePath, fullDestPath)
        end
    end
end

print("Extracting files to root")
print("------------------------------------------")
copyFolder("cc-tweaked-carpet-bomber", "/")
shell.run("delete cc-tweaked-carpet-bomber/")
print("------------------------------------------")
print("Done")
