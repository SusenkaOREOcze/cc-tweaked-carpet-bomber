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

print("Extracting files to root")
shell.run("cd ..")
shell.run("copy cc-tweaked-carpet-bomber/ .")
shell.run("delete cc-tweaked-carpet-bomber/")
print("Done")
print("------------------------------------------")
print(" ")
print("Copying TURTLE/ to all turtles and pockets")
print("------------------------------------------")
for i, value in ipairs(turtles) do
    shell.run("delete " .. value .. "/TURTLE")
    shell.run("copy TURTLE/ " .. value .. "/")

    print("Copying TURTLE/ to " .. value .. "/TURTLE")
end
print("------------------------------------------")
print(" ")
print("Copying TURTLE/ to all pockets")
print("------------------------------------------")
for i, value in ipairs(pockets) do
    shell.run("delete " .. value .. "/TURTLE")
    shell.run("copy POCKET/ " .. value .. "/")

    print("Copying POCKET/ to " .. value .. "/POCKET")
end
print("------------------------------------------")
print("Done")

-- copy disk/TURTLE/ .