-- -- -- -- --
-- CONFIG

-- rednet setup
local rednet_host_id = 117
local await_reply = true
local await_start = false
local await_fuel = false

local designated_id = 0
local calibrated = false


local hub_direction = "west"
local turtle_direction = nil
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


-- -- -- -- --

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
-- calibrate in home area
function calibrate()
    local x, y, z = gps.locate()
    local x2, y2, z2 = 0, 0, 0

    if turtle.forward() then
        turtle.forward()
        x2, y2, z2 = gps.locate()
        turtle.back()
    elseif turtle.back() then
        turtle.back()
        x2, y2, z2 = gps.locate()
        turtle.forward()
    elseif not turtle.forward() then
        turtle.turnLeft()
        if turtle.forward() then
            turtle.forward()
            x2, y2, z2 = gps.locate()
            turtle.back()
            turtle.turnRight()
        elseif turtle.back() then
            turtle.back()
            x2, y2, z2 = gps.locate()
            turtle.forward()
            turtle.turnRight()
        end
    end

    
    if x2 > x then
        return
    elseif x2 < x then
        turtle.turnRight()
        turtle.turnRight()
    elseif z2 > z then
        turtle.turnLeft()
    elseif z2 < z then
        turtle.turnRight()
    end

    turtle_direction = "east"
end

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
    if target.direction == "west" then
        if target.x == x and target.z == z then
            move_to_target = false
            align_before_bombing = true
        end

        if z < target.z and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'
        elseif z > target.z and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'
        elseif (z < target.z) and turtle_direction == 'south' then
            turtle.forward()
        elseif (z > target.z) and turtle_direction == 'south' then
            turtle.back()
        end

        if x < target.x and turtle_direction == 'south' then
            turtle.turnRight()
            turtle_direction = 'west'
        elseif x > target.x and turtle_direction == 'south' then
            turtle.turnRight()
            turtle_direction = 'west'
        elseif (x < target.x) and turtle_direction == 'west' then
            turtle.forward()
        elseif (x > target.x) and turtle_direction == 'west' then
            turtle.back()
        end
    end


    -- target is east
    if target.direction == "east" then
        if target.x == x and target.z == z then
            move_to_target = false
            align_before_bombing = true
        end

        if z < target.z and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'
        elseif z > target.z and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'
        elseif (z < target.z) and turtle_direction == 'south' then
            turtle.forward()
        elseif (z > target.z) and turtle_direction == 'south' then
            turtle.back()
        end

        if x < target.x and turtle_direction == 'south' then
            turtle.turnLeft()
            turtle_direction = 'east'
        elseif x > target.x and turtle_direction == 'north' then
            turtle.turnRight()
            turtle_direction = 'east'
        elseif (x < target.x) and turtle_direction == 'east' then
            turtle.forward()
        elseif (x > target.x) and turtle_direction == 'east' then
            turtle.forward()
        end
    end


    -- target is south
    if target.direction == "south" then
        if target.x == x and target.z == z then
            move_to_target = false
            align_before_bombing = true
        end

        if x < target.x and turtle_direction == 'east' then
            turtle.forward()
        elseif x > target.x and turtle_direction == 'east' then
            turtlle.back()
        end

        if z < target.z and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'
        elseif z > target.z and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'
        elseif (z < target.z) and turtle_direction == 'south' then
            turtle.forward()
        elseif (z > target.z) and turtle_direction == 'south' then
            turtle.back()
        end
    end

    -- target is north
    if target.direction == "north" then
        if target.x == x and target.z == z then
            move_to_target = false
            align_before_bombing = true
        end

        if x < target.x and turtle_direction == 'east' then
            turtle.forward()
        elseif x > target.x and turtle_direction == 'east' then
            turtlle.back()
        end

        if z < target.z and turtle_direction == 'east' then
            turtle.turnLeft()
            turtle_direction = 'north'
        elseif z > target.z and turtle_direction == 'east' then
            turtle.turnLeft()
            turtle_direction = 'north'
        elseif (z < target.z) and turtle_direction == 'north' then
            turtle.forward()
        elseif (z > target.z) and turtle_direction == 'north' then
            turtle.back()
        end
    end
end




-- ALIGN BEFORE BOMBING
-- align turtles before bombing
local function readyToStart()
    print("Ready to start bombing operations")
    rednet.send(rednet_host_id, designated_id, "B-12-READY")
end


if align_before_bombing then

    if designated_id == 1 then
        align_before_bombing = false
        await_bombing_confirm = true
        readyToStart()
    end

    --gap calculation
    local gap = 0
    if (target.radius*2+1 % turtle_count) > 0 then
        gap = target.radius*2+1 / turtle_count
    else
        gap = target.radius*2/ turtle_count
    end


    if (designated_id % 2) == 0 then
        local position = designated_id / 2
        
        turtle.turnLeft()
        for i = 1, position*gap do
            turtle.forward()
        end
        turtle.turnRight()
        turtle.forward()
        align_before_bombing = false
        await_bombing_confirm = true
        readyToStart()

    else
        local position = (designated_id + 1) / 2

        turtle.turnRight()
        for i = 1, position*gap do
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
while bombing do
    for i = 1, target.length do
        
        -- turtle.placeDown()
        turtle.forward()
    end
    bombing = false
    print("Finished bomb dropping...")
    finished_bombing = true
end