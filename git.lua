print("Extracting files to root")
print("------------------------------------------")
shell.run("cc-tweaked-carpet-bomber/TURTLE", ".")
shell.run("cc-tweaked-carpet-bomber/POCKET", ".")
shell.run("cc-tweaked-carpet-bomber/HUB", ".")

shell.run("cc-tweaked-carpet-bomber/turtles.lua", ".")
shell.run("cc-tweaked-carpet-bomber/pockets.lua", ".")

shell.run("delete cc-tweaked-carpet-bomber/")
print("------------------------------------------")
print("Done")
