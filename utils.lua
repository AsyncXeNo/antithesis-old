function normalize(vec)
    mag = math.sqrt(vec.x*vec.x + vec.y*vec.y)

    vec.x = vec.x / (toBool(mag) and mag or 1)
    vec.y = vec.y / (toBool(mag) and mag or 1)
    
    return vec
end


function lerp(a, b, t)
    return a + (b-a) * t
end


function round(a, n) 
    return (math.floor(a * 10^n + 0.5) / 10^n)
end


function toBool(number)
    if number == 0 then return false else return true end
end


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
