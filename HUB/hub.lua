os.setComputerLabel('Commnader')

require('hub_files/tool')

-- -- -- --- --
-- CONFIGS

-- rednet setup
local rednet_host_id = os.getComputerID()
-- turtle pairing
local awaiting_turtles = false

-- HUB CONFIG
local hub_position = {
    x = 0,
    y = 0,
    z = 0,
}

-- set hub position
local x, y, z = gps.locate()
hub_position.x = x
hub_position.y = y
hub_position.z = z

local hub_direction = "west"


-- BOMBING CONFIG
-- config for bombing operations
local default_turtle_count = 3
local default_pocket_count = 1
local pocket_delta_count = 0
local turtle_delta_count = 0

local ready_turtles = 0

local awaiting_commands = false

local turtle_list = {}

local target_coords = {
    x = 0,
    y = 0,
    z = 0,
    direction = "west",
}

-- TURTLE HOMES
-- are where turtles should sleep
-- may and min based on position in world (x, y, z)
local turtle_homes = {
    x1 = hub_position.x - 3,
    x2 = hub_position.x - default_turtle_count,
    y1 = hub_position.y - 0,
    y2 = hub_position.y - 0,
    z1 = hub_position.z + 0,
    z2 = hub_position.z + 0,
}


-- POCKETS
-- config for pockets and their behavior
local pocket_list = {}

local awaiting_transfer = false
local awaiting_ready_form_pocket = false



-- -- -- -- --
print('Before running this program or copying TURTLE or POCEKT folders, make sure that the rednet host ID has been properly set.')
print("Press any key to continue...")
io.read()

-- HUB SETUP
-- all necessary information must be gathered before the hub can be used

print("HUB must be facing: " .. hub_direction)
print('Hub position set to: ' .. hub_position.x .. ', ' .. hub_position.y .. ', ' .. hub_position.z)

print('Do you want to set turtle homes? (y/n)')
local turtle_homes_set = io.read()
turtle_homes_set = string.lower(turtle_homes_set)

if turtle_homes_set == 'y' then
    print("Turtle homes are set by the diference in cords")
    print("Set the x1 cord")
    local x1 = io.read()
    print("Set the x2 cord")
    local x2 = io.read()
    print("Set the y1 cord")
    local y1 = io.read()
    print("Set the y2 cord")
    local y2 = io.read()
    print("Set the z1 cord")
    local z1 = io.read()
    print("Set the z2 cord")
    local z2 = io.read()

    turtle_homes.x1 = x1
    turtle_homes.x2 = x2
    turtle_homes.y1 = y1
    turtle_homes.y2 = y2
    turtle_homes.z2 = z2
    turtle_homes.z1 = z1

    print('Turtle homes set to: ')
    print('x1: ' .. turtle_homes.x1 .. ', x2: ' .. turtle_homes.x2 .. ', y1: ' .. turtle_homes.y1 .. ', y2: ' .. turtle_homes.y2 .. ', z1: ' .. turtle_homes.z1 .. ', z2: ' .. turtle_homes.z2)

elseif turtle_homes_set == 'n' then

    print('Turtle homes set to default values')
    print('x1: ' .. turtle_homes.x1 .. ', x2: ' .. turtle_homes.x2 .. ', y1: ' .. turtle_homes.y1 .. ', y2: ' .. turtle_homes.y2 .. ', z1: ' .. turtle_homes.z1 .. ', z2: ' .. turtle_homes.z2)
else
    print('Invalid input')
    print('Exiting...')
    shell.exit()
end



-- HUB SETUP COMPLETE
-- all necessary information has been gathered and set
print('Hub setup complete')
print('Hub is now awaiting turtles and pockets')

peripheral.find("modem", rednet.open)
awaiting_turtles = true

-- GET TURTLE IDs
-- sorts all turtles into a table
while awaiting_turtles do
    if (turtle_delta_count == default_turtle_count and pocket_delta_count == default_pocket_count) then
        print('All turtles have been linked')
        print('Atleast one pocket has been linked')
        
        awaiting_turtles = false
        awaiting_commands = true
    end
    
    -- recieve rednet messages
    local id, message, protocol = rednet.receive()
    
    if protocol == "B-12-TURTLE" then
        print('Recieved message from turtle: ' .. id .. ", designated: " .. tostring(message))
        turtle_delta_count = turtle_delta_count + 1
        turtle_list[tonumber(message)] = id

        rednet.send(id, "paired", "B-12")
        
    elseif protocol == "B-12-POCKET" then
        print('Recieved message from pocket: ' .. id .. ", designated: " .. tostring(message))
        pocket_delta_count = pocket_delta_count + 1
        pocket_list[tonumber(message)] = id

        rednet.send(id, "paired", "B-12")
        
    else
        -- print("Recieved message from restricted device protocol")
    end
end



-- AWAITING COMMANDS
-- start listening for commands
-- command for operation start
while awaiting_commands do
    
    local id, message, protocol = rednet.receive()

    -- recieve target from pocket computer and sending it to all turtles
    if protocol == "B-12-TARGET" then
        print('Recieved message from pocket: ' .. id .. ", designated: " .. tostring(message.x) .. ", " .. tostring(message.y) .. ", " .. tostring(message.z) .. ", " .. tostring(message.direction))

        target_coords = message
        awaiting_commands = false

        rednet.send(id, "target recieved", "B-12")

        local data = {
            home = {
                x = hub_position.x + -3,
                y = hub_position.y + 0,
                z = hub_position.z + 0,
            },
            target = target_coords,
            hub_direction = hub_direction,
            turtle_count = turtle_delta_count,
        }

        print("Recieved target data")
        print("x: " .. data.target.x .. ", y: " .. data.target.y .. ", z: " .. data.target.z .. ", direction: " .. data.target.direction)
        print("Area of effect: " .. (data.target.radius*2)+1)
        print("space betwean turtles: " .. ((data.target.radius*2+1) / default_turtle_count))
        print("-----------------")

        for id, pc in ipairs(turtle_list) do
            rednet.send(pc, data, "B-12-START")
        end

        print('Sent start command to all turtles')
        print("Operation B-12 has begun")
        print("...")
        awaiting_transfer = true
    end
end

-- AWAITING READY FROM TURTLES
-- when turtles are at designated places, they will send a ready singnal
while awaiting_transfer do
    if ready_turtles == turtle_delta_count then
        print("Contacting pockets...")
        
        for id, pc in ipairs(pocket_list) do
            rednet.send(pc, "confirm bomb", "B-12-BOMB")
        end
        print("done")
        awaiting_transfer = false
        awaiting_ready_form_pocket = true
    end

    local id, message, protocol = rednet.receive()
    if protocol == "B-12-READY" then
        print("Recieved ready singnal from turtle: " .. id .. ", designated: " .. tostring(message))
        print("-----------------")

        ready_turtles = ready_turtles + 1
    end
end

-- AWAITING READY FROM POCKET
while awaiting_ready_form_pocket do
    local id, message, protocol = rednet.receive()

    if protocol == "B-12-BOMB" then
        print("Recieved confirmation singnal from pocket: " .. id .. ", designated: " .. tostring(message))
        print("-----------------")

        for id, pc in ipairs(turtle_list) do
            rednet.send(pc, "drop", "B-12-DROP")
        end

        print('Sent drop command to all turtles')
        print("Operation B-12-B has begun")
        print("...")

        awaiting_ready_form_pocket = false
        awaiting_success = true
    end
end

-- AWAITING SUCCESS
turtle_delta_count = 0
while awaiting_success do
    if ready_turtles == turtle_delta_count then

        shell.run("clear")

        print("Operation B-12-B has ended")
        print("-----------------")
        print("We thank you for your service")
        print("...")
        print("Turtles will return to home shortly")

        awaiting_success = false
        
        shell.exit()
    end

    local id, message, protocol = rednet.receive()

    if protocol == "B-12-SUCCESS" then
        print("Recieved success singnal from turtle: " .. id .. ", designated: " .. tostring(message))
        print("-----------------")
        turtle_delta_count = turtle_delta_count + 1
    end
end





