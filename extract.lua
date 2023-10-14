local turtles_tab = multishell.launch({}, "cc-tweaked-carpet-bomber/turtles.lua")
local pockets_tab = multishell.launch({}, "cc-tweaked-carpet-bomber/pockets.lua")
local git = multishell.launch({}, "cc-tweaked-carpet-bomber/git.lua")

multishell.setTitle(turtles_tab, "Turtles")
multishell.setTitle(pockets_tab, "Pockets")
multishell.setTitle(git, "Git")


