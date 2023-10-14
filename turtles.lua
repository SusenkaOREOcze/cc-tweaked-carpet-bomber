local turtles = {
    "disk",
    "disk2",
    "disk3",
    "disk4",
    "disk5",
}

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