local turtles = {
    "disk",
    "disk2",
    "disk3",
    "disk4",
    "disk5",
}

local pockets = {
    "disk6",
}

local turtles_tab = shell.openTab("turtles")
local pockets_tab = shell.openTab("pockets")
local git = shell.openTab("git")

shell.switchTab(git)
print("Extracting files to root")
print("------------------------------------------")
shell.run("copy cc-tweaked-carpet-bomber/ .")
shell.run("delete cc-tweaked-carpet-bomber/")
print("------------------------------------------")
print("Done")

shell.switchTab(turtles_tab)
print("Copying TURTLE/ to all turtles and pockets")
print("------------------------------------------")
for i, value in ipairs(turtles) do
    if fs.exists(value .. "/TURTLE") then
        shell.run("delete " .. value .. "/TURTLE")
    end
    shell.run("copy TURTLE/ " .. value)
    print("Copying TURTLE/ to " .. value)
end
print("------------------------------------------")
print("Done")

shell.switchTab(pockets_tab)
print("Copying TURTLE/ to all pockets")
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

-- copy disk/TURTLE/ .