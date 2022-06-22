function toNumber(value)
    return value and 1 or 0
end

function sign(value)
    if value > 0 then return 1 end
    if value < 0 then return -1 end
    if value == 0 then return 0 end
end

function isPositive(value)
    return value > 0
end


function isNegative(value)
    return value < 0
end
