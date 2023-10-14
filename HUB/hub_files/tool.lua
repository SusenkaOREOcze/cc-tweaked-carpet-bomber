function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function isKeyInTable(T, id)
    for key, value in pairs(T) do
        if key == id then
            return true
        end
    end
    return false
end

return {
    tablelength = tablelength,
}