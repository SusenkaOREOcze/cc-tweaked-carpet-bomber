-- -- -- -- --
-- CONFIG

-- rednet setup
local rednet_host_id = 117
local await_reply = true
local await_start = false
local await_fuel = false

local designated_id = 0
local calibrated = true

local traversal_x = false
local traversal_z = false

local hub_direction = "west"
local turtle_direction = "east"
local home_direction = "east"
local turtle_count = 0

local turtle_first_home = {
    x = 0,
    y = 0,
    z = 0,
} 

-- BOMBING CONFIG
-- config for bombing operations
local target = {
    x = 0,
    y = 0,
    z = 0,
    direction = "west",
}

local move_line = false
local start_rise = false
local move_to_target = false
local align_before_bombing = false
local await_bombing_confirm = false
local bombing = false
local finished_bombing = false
local move_line_down = false

local return_home = false 


-- -- -- -- --

-- TOOLS AND FUNCTIONS
local function traverse(x, z, td, callback)

    if return_home then
        if turtle_direction == 'north' then
            turtle.turnRight()
            turtle_direction = 'east'
        elseif turtle_direction == 'south' then
            turtle.turnLeft()
            turtle_direction = 'east'
        elseif turtle_direction == 'west' then
            turtle.turnRight()
            turtle.turnRight()
            turtle_direction = 'east'
        elseif turtle_direction == 'east' then
            turtle_direction = 'east'
        end

        return_home = false
    end

    if td.direction == "west" then
        traversal_z = true

        if td.x == x and td.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end

        if z == td.z and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'

            traversal_x = true
            traversal_z = false
        end


        if turtle_direction == 'east' and traversal_z then
            turtle.turnRight()
            turtle_direction = 'west'
        end
        if z < td.z and turtle_direction == 'south' and traversal_z then
            turtle.forward()
        elseif z > td.z and turtle_direction == 'south' and traversal_z then
            turtle.back()
        end


        if x < td.x and turtle_direction == 'west' and traversal_x then
            turtle.back()
        elseif x > td.x and turtle_direction == 'west' and traversal_x then
            turtle.forward()
        end
    end


    -- target is east
    if td.direction == "east" then
        traversal_z = true

        if td.x == x and td.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end

    

        if z == td.z then
            if turtle_direction == 'east' then
            elseif turtle_direction == 'west' then
                turtle.turnRight()
                turtle.turnRight()
                turtle_direction = 'east'
            elseif turtle_direction == 'south' then
                turtle.turnLeft()
                turtle_direction = 'east'
            elseif turtle_direction == 'north' then
                turtle.turnLeft()
                turtle_direction = 'east'
            end

            traversal_x = true
            traversal_z = false
        end

        if turtle_direction == 'east' and traversal_z then
            turtle.turnRight()
            turtle_direction = 'south'
        end
        if z < td.z and turtle_direction == 'south' and traversal_z then
            turtle.forward()
        elseif z > td.z and turtle_direction == 'south' and traversal_z then
            turtle.back()
        end

        if x < td.x and turtle_direction == 'east' and traversal_x then
            turtle.forward()
        elseif x > td.x and turtle_direction == 'east' and traversal_x then
            turtle.bback()
        end
    end


    -- target is south
    if td.direction == "south" then

        traversal_x = true
        if td.x == x and td.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end

        

        if x == td.x and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'

            traversal_x = false
            traversal_z = true
        end

        if x < td.x and turtle_direction == 'east' and traversal_x then
            turtle.forward()
        elseif x > td.x and turtle_direction == 'east' and traversal_x then
            turtlle.back()
        end


        if z < td.z and turtle_direction == 'south' and traversal_z then
            turtle.forward()
        elseif z > td.z and turtle_direction == 'south' and traversal_z then
            turtle.back()
        end
    end

    -- target is north
    if td.direction == "north" then

        traversal_x = true
        if td.x == x and td.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end


        
        if x == td.x and turtle_direction == 'east' then
            turtle.turnLeft()
            turtle_direction = 'north'

            traversal_x = false
            traversal_z = true
        end

        if x < td.x and turtle_direction == 'east' and traversal_x then
            turtle.forward()
        elseif x > td.x and turtle_direction == 'east' and traversal_x then
            turtlle.back()
        end

        if z < td.z and turtle_direction == 'north' and traversal_z then
            turtle.back()
        elseif z > td.z and turtle_direction == 'north' and traversal_z then
            turtle.forward()
        end
    end
end



-- PAIR WITH HUB
print("Pairing with hub...")
print("Hub ID: " .. rednet_host_id)
print("Specify turtle ID: (number)")
local number = io.read()

-- get the modem peripheral
peripheral.find("modem", rednet.open)

-- await pair by hub
while await_reply do 
    rednet.send(rednet_host_id, number, "B-12-TURTLE")

    local id, message, protocol = rednet.receive()
    if id == rednet_host_id and protocol == "B-12" and tostring(message) == "paired" then
        print("Paired with hub!")
        designated_id = number
        await_reply = false
        await_start = true
    end
end

-- AWAITING AT HOME/HUB
while await_start do
    local id, message, protocol = rednet.receive()     
    
    if id == rednet_host_id and protocol == "B-12-START" then
        print("Recieved start command from hub")

        turtle_first_home = message.home
        target = message.target
        hub_direction = message.hub_direction
        turtle_count = message.turtle_count

        await_start = false
        await_fuel = true
    end
end


-- AWAITING FUEL
while await_fuel do
    
    -- fuel required calcualtion and refuelin promt
    local fuel_required = ((math.abs(turtle_first_home.x - target.x) + math.abs(turtle_first_home.z - target.z) + math.abs(turtle_first_home.y - target.y)) + target.lenght + target.radius*2)*2
    

    print("Fuel required: " .. fuel_required)
    print("Fuel level: " .. turtle.getFuelLevel())
    print("-----------------")

    if (fuel_required > turtle.getFuelLevel()) then
        print("Not enough fuel, please refuel")
        print("Press enter to continue")
        io.read()

        turtle.refuel()
    else
        print("Fuel is enough, continuing...")
        -- if fuel is enough
        await_fuel = false
        move_line = true
    end
end


-- TRAVERSAL

-- alligning within the turtles home area
while move_line do
    if not calibrated then
        calibrate()
        calibrated = true
    end 

    local x, y, z = gps.locate()
    
    if x == turtle_first_home.x then
        move_line = false
        start_rise = true
    else 
        turtle.forward()
    end
end

-- get to y from home area
while start_rise do
    local x, y, z = gps.locate()
    
    if y == target.y then
        start_rise = false
        move_to_target = true
    else 
        turtle.up()
    end
end

-- get to target
while move_to_target do
    -- print("Moving to target...")
    
    local x, y, z = gps.locate()

    -- based on target direction
    -- move respectivly on x and z

    --target is west
    traverse(x, z, target, function ()
        move_to_target = false
        align_before_bombing = true
    end)
end




-- ALIGN BEFORE BOMBING
-- align turtles before bombing
local function readyToStart()
    print("Ready to start bombing operations")
    rednet.send(rednet_host_id, designated_id, "B-12-READY")
end


if align_before_bombing then

    --gap calculation
    local gap = 0
    if ((target.radius*2+1) % turtle_count) > 0 then
        gap = (target.radius*2+1) / turtle_count
        gap = math.floor(gap) + 1
    else
        gap = target.radius*2 / turtle_count
    end

    if tonumber(designated_id) == 1 then
        turtle.forward()
        align_before_bombing = false
        await_bombing_confirm = true
        readyToStart()
    elseif (designated_id % 2) == 0 then
        local position = designated_id / 2
        
        turtle.turnLeft()
        for i = 1, (position*gap+1), 1 do
            turtle.forward()
        end
        turtle.turnRight()
        turtle.forward()
        align_before_bombing = false
        await_bombing_confirm = true
        readyToStart()

    else
        local position = (designated_id - 1) / 2

        turtle.turnRight()
        for i = 1, (position*gap+1), 1 do
            turtle.forward()
        end
        turtle.turnLeft()
        turtle.forward()
        align_before_bombing = false
        await_bombing_confirm = true
        readyToStart()
    end
end

-- BOMBING
-- start bombing operations
while await_bombing_confirm do
    
    local id, message, protocol = rednet.receive()

    if id == rednet_host_id and protocol == "B-12-DROP" then
        print("Recieved start bombing command from hub")
        await_bombing_confirm = false
        bombing = true
    end
end

-- bombing operations
local function drop(i) 
    if i % 2 == 0 then
        turtle.select(2)
        turtle.placeDown()
        redstone.setOutput("bottom", true)
        sleep(0.5)
        redstone.setOutput("bottom", false)
        turtle.forward()
    end
end

while bombing do
    for i = 1, target.lenght, 1 do
        drop(i)
        turtle.forward()
    end
    bombing = false
    print("Finished bomb dropping...")
    finished_bombing = true
end

-- FINISHED BOMBING
-- return to home
-- technically, this is reversed traversal

return_home = true
while finished_bombing do
    local x, y, z = gps.locate()

    -- home direction is east
    -- turtle_directoin varies based on turtle_direction

    local t = {
        x = turtle_first_home.x,
        y = target.y,
        z = turtle_first_home.z,
        direction = home_direction,
    }

    traverse(x, z, t, function ()
        finished_bombing = false
        move_line_down = true
    end)
end

-- PARKING
while move_line_down do
    local x, y, z = gps.locate()

    if y == turtle_first_home.y then
        -- move further based on number
        for i = 1, designated_id, 1 do
            turtle.back()
        end
    else 
        turtle.down()
    end
end
