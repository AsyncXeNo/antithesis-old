
require "utils"
require "constants"
local concord = require "libs.Concord"
local controls = require "controls"
local logger = require "log"

--[[
    AnimationSystem
]]


--[[
    MovementSystem
]]
MovementSystem = concord.system {
    pool = {
        "Position",
        "Velocity",
        "Controllable"
    }
}


function MovementSystem:update(dt)
    for _,e in ipairs(self.pool) do
        
        -- if isPositive(e.Velocity.x) then
        --     e.Velocity.x = math.max(0, e.Velocity.x - FRICTION)
        -- elseif isNegative(e.Velocity.x) then
        --     e.Velocity.x = math.min(0, e.Velocity.x + FRICTION)
        -- end
        
        -- if isPositive(e.Velocity.y) then
            -- e.Velocity.y = math.max(0, e.Velocity.y - FRICTION)
        -- elseif isNegative(e.Velocity.y) then
            -- e.Velocity.y = math.min(0, e.Velocity.y + FRICTION)
        -- end
        
        for dir, _ in pairs({x = _, y = _}) do
            if sign(e.Velocity[dir] - sign(e.Velocity[dir]) * FRICTION * dt) ~= sign(e.Velocity[dir]) then
                e.Velocity[dir] = 0
                
            else
                e.Velocity[dir] = e.Velocity[dir] - sign(e.Velocity[dir]) * FRICTION * dt
            end
        end
        
        for k,_ in pairs(controls.moveLeft) do if love.keyboard.isDown(k) then e.Velocity.x = math.max(-e.Velocity.maxVel * dt, e.Velocity.x - e.Controllable.acceleration * dt) end end
        for k,_ in pairs(controls.moveRight) do if love.keyboard.isDown(k) then e.Velocity.x = math.min(e.Velocity.maxVel * dt, e.Velocity.x + e.Controllable.acceleration * dt) end end
        for k,_ in pairs(controls.moveUp) do if love.keyboard.isDown(k) then e.Velocity.y = math.max(-e.Velocity.maxVel * dt, e.Velocity.y - e.Controllable.acceleration * dt) end end
        for k,_ in pairs(controls.moveDown) do if love.keyboard.isDown(k) then e.Velocity.y = math.min(e.Velocity.maxVel * dt, e.Velocity.y + e.Controllable.acceleration * dt) end end
        
        e.Position.x = e.Position.x + e.Velocity.x * dt
        e.Position.y = e.Position.y + e.Velocity.y * dt
    end
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
        love.graphics.rectangle(e.BoxRenderer.mode, e.Position.x, e.Position.y, e.BoxRenderer.width, e.BoxRenderer.height)
    end
    for _,e in ipairs(self.circlePool) do
        love.graphics.setColor(unpack(e.CircleRenderer.color))
        love.graphics.circle(e.CircleRenderer.mode, e.Position.x, e.Position.y, e.CircleRenderer.radius)
    end
end
