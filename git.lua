print("Extracting files to root")
print("------------------------------------------")
shell.run("TURTLE/", "..")
shell.run("POCKET/", "..")
shell.run("HUB/", "..")

shell.run("turtles.lua", "..")
shell.run("pockets.lua", "..")
shell.run("clear.lua", "..")

shell.run("delete .")
print("------------------------------------------")
print("Done")
