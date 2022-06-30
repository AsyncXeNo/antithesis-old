
require "utils"
require "constants"
local concord = require "libs.Concord"
local controls = require "controls"
local logger = require "log"

--[[
    AnimationSystem
]]


--[[
    TimelineSystem
]]
TimelineSystem = concord.system {
    pool = {
        "Position",
        "Timeline"
    }
}

function TimelineSystem:update(dt) 
    for _,e in ipairs(self.pool) do
        local action = e.Timeline.actions[e.Timeline.curIndex]        
        if action == nil then
            self:getWorld():removeEntity(e)
        else 
            if action[1] == "move" then
                if math.abs(e.Position.x - lerp(e.Position.x, action[2].x, action[3])) < 1 or math.abs(e.Position.y - lerp(e.Position.y, action[2].y, action[3])) < 1 then
                    e.Timeline.curIndex = e.Timeline.curIndex + 1
                else
                    e.Position.x = lerp(e.Position.x, action[2].x, action[3])
                    e.Position.y = lerp(e.Position.y, action[2].y, action[3])
                end
            elseif action[1] == "shoot" then
                if action[2] == "burst" then
                    local angleOfCone = action[3]
                    local distance = action[4]
                    local numLines = action[5]
                    local interval = action[6]
                    local numBursts = action[7]
                    local sep = angleOfCone / (numLines + 1)

                    e.Timeline.vars.timePassed = (e.Timeline.vars.timePassed or 0) + dt
                    e.Timeline.vars.bursts = e.Timeline.vars.bursts or 0
                    
                    if e.Timeline.vars.timePassed == dt then
                        local speed = action[8].speed
                        for i=1,numLines do
                            local angle = (math.pi/2) + (angleOfCone / 2) - (sep * i)
                            
                            --TODO: Use arg7
                            local bullet = concord.entity(self:getWorld())
                                :give("Position", e.Position.x + math.cos(angle) * distance, e.Position.y + math.sin(angle) * distance)
                                :give("Movable", { x = math.cos(angle) * speed, y = math.sin(angle) * speed})
                                :give("CircleRenderer", 5, {0, 0, 1, 1})
                        end
                        e.Timeline.vars.bursts = e.Timeline.vars.bursts + 1
                    end

                    if e.Timeline.vars.timePassed >= interval then 
                        e.Timeline.vars.timePassed = 0 
                    end

                    
                    if e.Timeline.vars.bursts == numBursts then
                        e.Timeline.vars = {}
                        e.Timeline.curIndex = e.Timeline.curIndex + 1
                    end
                end
                -- if action[2] == "homing" then
                --end
            end
        end
    end
end


--[[
    MovementSystem
]]
MovementSystem = concord.system {
    pool = {
        "Position",
        "Movable"
    },
    secondPool = {
        "Position",
        "Movable",
        "Controllable"
    },
    thirdPool = {
        "Position",
        "Path",
    }
}

function MovementSystem:init(world)
    for _,e in ipairs(self.thirdPool) do
        logger.debug("Creating function")
        e.Path.init_point = e.Position
        e.Path.path_func = function(t) 
            if math.floor(t) == 0 then
                local points = {
                    e.Path.init_point,
                    {
                        x = e.Path.points[1][1].x + e.Path.init_point.x,
                        y = e.Path.points[1][1].y + e.Path.init_point.y
                    },
                    {
                        x = e.Path.points[1][2].x + e.Path.init_point.x,
                        y = e.Path.points[1][2].y + e.Path.init_point.y
                    },
                    {
                        x = e.Path.points[1][3].x + e.Path.init_point.x,
                        y = e.Path.points[1][3].y + e.Path.init_point.y
                    }
                }
                return bezierPoint(points[1],points[2],points[3],points[4], e.Path.t)
            elseif math.floor(t) < #e.Path.points then
                local points = {
                    {
                        x = e.Path.points[math.floor(e.Path.t)][3].x + e.Path.init_point.x,
                        y = e.Path.points[math.floor(e.Path.t)][3].y + e.Path.init_point.y
                    },
                    {
                        x = 2*e.Path.points[math.floor(e.Path.t)][3].x - e.Path.points[math.floor(e.Path.t)][2].x + e.Path.init_point.x,
                        y = 2*e.Path.points[math.floor(e.Path.t)][3].y - e.Path.points[math.floor(e.Path.t)][2].y + e.Path.init_point.y
                    },
                    {
                        x = e.Path.points[math.floor(e.Path.t) + 1][1].x + e.Path.init_point.x,
                        y = e.Path.points[math.floor(e.Path.t) + 1][1].y + e.Path.init_point.y
                    },
                    {
                        x = e.Path.points[math.floor(e.Path.t) + 1][2].x + e.Path.init_point.x,
                        y = e.Path.points[math.floor(e.Path.t) + 1][2].y + e.Path.init_point.y
                    }
                }
                logger.debug('{'..points[1].x..', '..points[1].y..'}, '..'{'..points[2].x..', '..points[2].y..'}, '..'{'..points[3].x..', '..points[3].y..'}, '..'{'..points[4].x..', '..points[4].y..'}, ')
                return bezierPoint(points[1],points[2],points[3],points[4], e.Path.t - math.floor(e.Path.t))
            end
        end
    end
end

function MovementSystem:update(dt)

    -- other entities
    for _,e in ipairs(self.pool) do
        for dir,_ in pairs({x=_, y=_}) do
            if sign(e.Movable.vel[dir] - sign(e.Movable.vel[dir]) * e.Movable.friction[dir] * dt) ~= sign(e.Movable.vel[dir]) then
                e.Movable.vel[dir] = 0
            else
                e.Movable.vel[dir] = e.Movable.vel[dir] - sign(e.Movable.vel[dir]) * e.Movable.friction[dir] * dt
            end
        end

        -- acceleration 
        for dir,_ in pairs({x=_, y=_}) do
            e.Movable.vel[dir] = e.Movable.vel[dir] + e.Movable.acceleration[dir]
        end

        -- movement        
        e.Position.x = e.Position.x + e.Movable.vel.x * dt
        e.Position.y = e.Position.y + e.Movable.vel.y * dt
    end

    -- player movement
    for _,e in ipairs(self.secondPool) do
        -- Set velocity based on inputs

        local movDir = { x = toNumber(e.Controllable.moveRight) - toNumber(e.Controllable.moveLeft), y = toNumber(e.Controllable.moveDown) - toNumber(e.Controllable.moveUp)}
        movDir = normalize(movDir)

        local maxVel = { x = e.Movable.maxVel.x - toNumber(e.Controllable.precision) * (e.Movable.maxVel.x / 2), y = e.Movable.maxVel.y - toNumber(e.Controllable.precision) * (e.Movable.maxVel.y / 2) }

        e.Movable.vel = { x = movDir.x * maxVel.x, y = movDir.y * maxVel.y }
        
        -- Apply dx to position
        e.Position.x = e.Position.x + e.Movable.vel.x * dt
        e.Position.y = e.Position.y + e.Movable.vel.y * dt

        -- for dir,_ in pairs({x=_, y=_}) do
        --     logger.debug(e.Movable.vel[dir])
        --     logger.debug(e.Position[dir])
        -- end
    end

    -- projectile movement
    for _,e in ipairs(self.thirdPool) do
        if e.Path.t >= #e.Path.points then
            self:getWorld():removeEntity(e)
        else
            local dx = (#e.Path.points)/e.Path.duration
            e.Position = e.Path.path_func(e.Path.t)
            logger.debug('t='..e.Path.t..', x='..e.Position.x.. ', y='..e.Position.y)
            e.Path.t = e.Path.t + dx * dt
        end
    end
end

--[[
    InputSystem
]]
InputSystem = concord.system {
    pool = { "Controllable" }
}


function InputSystem:update(dt) 
    for _, e in ipairs(self.pool) do
        for k,v in pairs(controls) do
            local flag = false
            for key,_ in pairs(controls[k]) do
                if love.keyboard.isDown(key) then 
                    flag = true
                    break 
                end
            end
            e.Controllable[k] = flag  
        end
    end
end


--[[
    CollisionSystem
]]
CollisionSystem = concord.system {
    squares = {
        "BoxCollider"
    }, 
    circles = {
        "CircleCollider"
    }
}


function CollisionSystem:update(dt)

end


-- DEBUG

--[[
    DebugRenderSystem
]]
DebugRenderSystem = concord.system {
    boxPool = {"Position", "BoxRenderer"},
    circlePool = {"Position", "CircleRenderer"}
}

function DebugRenderSystem:draw()
    for _,e in ipairs(self.boxPool) do
        love.graphics.setColor(unpack(e.BoxRenderer.color))
        love.graphics.rectangle(e.BoxRenderer.mode, e.Position.x - e.BoxRenderer.width / 2, e.Position.y - e.BoxRenderer.height / 2, e.BoxRenderer.width, e.BoxRenderer.height)
    end
    for _,e in ipairs(self.circlePool) do
        love.graphics.setColor(unpack(e.CircleRenderer.color))
        love.graphics.circle(e.CircleRenderer.mode, e.Position.x, e.Position.y, e.CircleRenderer.radius)
    end
end
