peripheral.find("modem", rednet.open)

-- -- -- -- --
-- CONFIG

-- rednet setup
local rednet_host_id = 117
-- await for hub pair
local await_reply = true
-- awaiting if target has been set for turtles
local await_target_confirmation = false
-- awaiting if bomb has been dropped
local awaiting_drop_confirmation = false
-- mission success?
local awaiting_success = false

-- BOMBING CONFIG
-- config for bombing operations
local target_set = false

local target = {
    x = 0,
    y = 0,
    z = 0,
}


-- -- -- -- --

-- PAIR WITH HUB
print("Pairing with hub...")
print("Hub ID: " .. rednet_host_id)
print("Specify pocket ID: (number)")
local number = io.read()


-- await pair by hub
while await_reply do 
    rednet.send(rednet_host_id, number, "B-12-POCKET")

    local id, message, protocol = rednet.receive()
    if id == rednet_host_id and protocol == "B-12" and tostring(message) == "paired" then
        print("Paired with hub!")
        await_reply = false
    end
end

-- AWAITING TARGET
-- if paired, await for target input

if not await_reply then
    print("Awaiting commands...")
    print("Register new coordinates (x, y, z)")
    local cords = io.read()

    print("Register new direction (north, south, east, west)")
    local direction = io.read()

    print("What should be the radius of bombardment from center position? (number)")
    local radius = io.read()

    print("What should be the lenght of bombardment? (number)")
    local lenght = io.read()


    -- parsing x, y, z coordinates from string
    -- writen like: 0 5 123
    local x, y, z = string.match(cords, "(-?%d+) (-?%d+) (-?%d+)")
    print("x: " .. x .. ", y: " .. y .. ", z: " .. z)
    
    --- parsing direction from string
    print("Direction: " .. direction)

    -- parsing radius from string
    print("Radius: " .. radius)

    -- parsing length from string
    print("Lenght: " .. lenght)

    print("-----------------")

    -- last check
    print("Is this correct? (y/n)")
    print("-----------------")
    local correct = io.read()
    correct = string.lower(correct)

    if correct == 'y' then
        target.x = tonumber(x)
        target.y = tonumber(y)
        target.z = tonumber(z)
        target.direction = direction
        target.radius = tonumber(radius)
        target.lenght = tonumber(lenght)


        print("Target set to: ")
        print("x: " .. target.x .. ", y: " .. target.y .. ", z: " .. target.z)
        print("Direction: " .. target.direction)
        print("Radius: " .. target.radius)
        print("Bomving area lenght: " .. target.lenght)

        print("-----------------")

        print("Transmitting target to hub...")
        rednet.send(rednet_host_id, target, "B-12-TARGET")
        await_target_confirmation = true
        
    elseif correct == 'n' then
        print("Exiting...")
        shell.exit()
    else
        print("Invalid input")
        print("Exiting...")
        shell.exit()
    end
end

-- AWAITING CONFIRMATION
while await_target_confirmation do
    local id, message, protocol = rednet.receive()

    if id == rednet_host_id and protocol == "B-12" and tostring(message) == "target recieved" then
        print("Target recieved by hub")
        await_target_confirmation = false
        target_set = true
    end
end

-- TARGET HAS BEEN CONFIRMED AND SET
while target_set do
    print("-----------------")
    print("Target ahs been set")
    print("Abort of mission not possible")
    print("Ending transmission...")
    print("-----------------")
    target_set = false
    awaiting_drop_confirmation = true
end

-- AWAITING DROP CONFIRMATION
while awaiting_drop_confirmation do
    local id, message, protocol = rednet.receive()

    if id == rednet_host_id and protocol == "B-12-BOMB" and tostring(message) == "confirm bomb" then
        print("Drop confirmation request recieved from hub")
        print("-----------------")
        print("Do you confirm? (y/n)")

        local confirm = io.read()
        confirm = string.lower(confirm)

        if confirm == 'y' then
            rednet.send(rednet_host_id, "confirm", "B-12-BOMB")

            awaiting_drop_confirmation = false
            awaiting_success = true

        elseif confirm == 'n' then
            rednet.send(rednet_host_id, "abort", "B-12-BOMB")
            print("Aborting...")
            shell.exit()
        else
            print("Invalid input")
            print("Aborting...")
            shell.exit()
        end

    end
end

-- AWAITING FOR MISSION COMPLEATION
while awaiting_success do
    local id, message, protocol = rednet.receive()

    if id == rednet_host_id and protocol == "B-12" and tostring(message) == "success" then
        print("Mission successful")
        awaiting_success = false
        shell.exit()
    end
end