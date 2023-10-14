local turtles_tab = multishell.launch({}, "turtles.lua")
local pockets_tab = multishell.launch({}, "pockets.lua")
local git = multishell.launch({}, "git.lua")

multishell.setTitle(turtles_tab, "Turtles")
multishell.setTitle(pockets_tab, "Pockets")
multishell.setTitle(git, "Git")


