function table.keysExists(t, ...)
    assert(type(t) == "table", "First argument is not a table")
    local args =  {...}
    for _, a in ipairs(args) do
        if t[a] == nil then
            return false, a
        end
    end
    return true
end

function formatLongNumber(number)
    if number < 100000 then return number end
    local steps = {
        {1,""},
        {1e3,"k"},
        {1e6,"m"},
        {1e9,"g"},
        {1e12,"t"},
    }
    for _,b in ipairs(steps) do
        if b[1] <= number+1 then
            steps.use = _
        end
    end
    local result = string.format("%.1f", number / steps[steps.use][1])
    if tonumber(result) >= 1e3 and steps.use < #steps then
        steps.use = steps.use + 1
        result = string.format("%.1f", tonumber(result) / 1e3)
    end
    result = string.sub(result,0,string.sub(result,-1) == "0" and -3 or -1) -- Remove .0 (just if it is zero!)
    return result .. steps[steps.use][2]
end
