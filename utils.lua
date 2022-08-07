require 'constants'
local logger = require 'log'
local inspect = require 'inspect'


function normalize(vec)
    mag = math.sqrt(vec.x*vec.x + vec.y*vec.y)

    vec.x = vec.x / (toBool(mag) and mag or 1)
    vec.y = vec.y / (toBool(mag) and mag or 1)
    
    return vec
end


function bezierValue(b0, b1, b2, b3, t)
    return (1-t)^3*b0     +     3*(1-t)^2*t*b1    +     3*(1-t)*t^2*b2    +    t^3*b3
end


function bezierPoint(p1, p2, p3, p4, t)
    return {x = bezierValue(p1.x,p2.x,p3.x,p4.x,t),
            y = bezierValue(p1.y,p2.y,p3.y,p4.y,t)}
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


function combineLists(t1, t2)
    t3 = {}
    for i=1,#t1 do
        t3[i] = t1[i]
    end
    for i=1,#t2 do
        t3[i] = t2[#t1+i]
    end
    return t3
end


function isInBoundsobj(obj, bounds)
    if obj.Position.x > bounds[1].x and obj.Position.y > bounds[1].y and obj.Position.x < bounds[2].x and obj.Position.y < bounds[2].y then
        if obj.Collider.type == "box" then
            extra = {
                x = obj.Collider.values.width / 2,
                y = obj.Collider.values.height / 2
            }
        elseif obj.Collider.type == "circle" then
            extra = {
                x = obj.Collider.values.r,
                y = obj.Collider.values.r
            }
        end
         
        left = obj.Position.x - extra.x > bounds[1].x
        right = obj.Position.x + extra.x < bounds[2].x
        top = obj.Position.y - extra.y > bounds[1].y 
        bottom = obj.Position.y + extra.y < bounds[2].y 
        
        x_checker = true
        y_checker = true

        shouldLeft = not bounds[1].x == 0
        shouldRight = not bounds[2].x == RESOLUTION.width
        shouldTop = not bounds[1].y == 0
        shouldBottom = not bounds[2].y == RESOLUTION.height

        --[[
        shouldLeft left isInLeft
            T       T       T
            F       T       T
            F       F       T
            T       F       F
            shouldLeft -> left <=> !shouldLeft ∨ left

        ]]
        
        x_checker = (not shouldLeft or left) and (not shouldRight or right)
        y_checker = (not shouldTop or top) and (not shouldBottom or bottom)

        return x_checker and y_checker
    else
        return false
    end
end


function list2Set(list)
    set = {}
    for _,k in ipairs(list) do
        set[k] = true
    end
    return set
end


function len(tab)
    count = 0
    for _, k in pairs(tab) do count = count + 1 end
    return count
end


function statesTable(tab, entryState)
    tab[ENTRY_STATE] = entryState
    return tab
end

function crawl(dir)
    files = love.filesystem.getDirectoryItems( dir )
    for k,v in ipairs(files) do
        if love.filesystem.isDirectory(v) then 
            l = combineLists(l, crawl(dir))
        else
            l[#l+1] = dir .. v
        end 
    end
    return l
end
