local pockets = {
    "disk6",
}

print("Copying POCKET/ to all pockets")
print("------------------------------------------")
for i, value in ipairs(pockets) do
    if fs.exists(value .. "/POCKET") then
        shell.run("delete " .. value .. "/POCKET")
    end
    shell.run("copy POCKET/ " .. value)

    print("Copying POCKET/ to " .. value)
end
print("------------------------------------------")
print("Done")