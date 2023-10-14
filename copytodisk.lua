local disks = {
    "disk",
    "disk2",
    "disk3",
    "disk4",
    "disk5",
}

for i, value in ipairs(disks) do
    shell.run("delete " .. value .. "/TURTLE")
    shell.run("copy TURTLE/ " .. value .. "/")
end

-- copy disk/TURTLE/ .