function traverse(x, z, target, callback)
    
    if target.direction == "west" then
        traversal_z = true

        if target.x == x and target.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end

        if z == target.x and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'

            traversal_x = true
            traversal_z = false
        end

        if turtle_direction == 'east' and traversal_z then
            turtle.turnRight()
            turtle_direction = 'west'
        end
        if z < target.z and turtle_direction == 'south' and traversal_z then
            turtle.forward()
        elseif z > target.z and turtle_direction == 'south' and traversal_z then
            turtle.back()
        end


        if x < target.x and turtle_direction == 'west' and traversal_x then
            turtle.back()
        elseif x > target.x and turtle_direction == 'west' and traversal_x then
            turtle.forward()
        end
    end


    -- target is east
    if target.direction == "east" then
        traversal_z = true

        if target.x == x and target.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end

        if z == target.x and turtle_direction == 'east' then
            turtle.turnLeft()
            turtle_direction = 'east'

            traversal_x = true
            traversal_z = false
        end

        if turtle_direction == 'east' and traversal_z then
            turtle.turnRight()
            turtle_direction = 'south'
        end
        if z < target.z and turtle_direction == 'south' and traversal_z then
            turtle.forward()
        elseif z > target.z and turtle_direction == 'south' and traversal_z then
            turtle.back()
        end

        if x < target.x and turtle_direction == 'east' and traversal_x then
            turtle.forward()
        elseif x > target.x and turtle_direction == 'east' and traversal_x then
            turtle.bback()
        end
    end


    -- target is south
    if target.direction == "south" then

        traversal_x = true
        if target.x == x and target.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end

        if x == target.x and turtle_direction == 'east' then
            turtle.turnRight()
            turtle_direction = 'south'

            traversal_x = false
            traversal_z = true
        end

        if x < target.x and turtle_direction == 'east' and traversal_x then
            turtle.forward()
        elseif x > target.x and turtle_direction == 'east' and traversal_x then
            turtlle.back()
        end


        if z < target.z and turtle_direction == 'south' and traversal_z then
            turtle.forward()
        elseif z > target.z and turtle_direction == 'south' and traversal_z then
            turtle.back()
        end
    end

    -- target is north
    if target.direction == "north" then

        traversal_x = true
        if target.x == x and target.z == z then
            callback()

            traversal_x = false
            traversal_z = false
        end
        
        if x == target.x and turtle_direction == 'east' then
            turtle.turnLeft()
            turtle_direction = 'north'

            traversal_x = false
            traversal_z = true
        end

        if x < target.x and turtle_direction == 'east' and traversal_x then
            turtle.forward()
        elseif x > target.x and turtle_direction == 'east' and traversal_x then
            turtlle.back()
        end

        if z < target.z and turtle_direction == 'north' and traversal_z then
            turtle.back()
        elseif z > target.z and turtle_direction == 'north' and traversal_z then
            turtle.forward()
        end
    end
end

return {
    traverse = traverse,
}