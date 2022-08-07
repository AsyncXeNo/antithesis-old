
local concord = require "libs.Concord"


--[[
    Position
]]
concord.component("Position", function(component, x, y)
    component.x = x or 0
    component.y = y or 0
end)


--[[
    Movable
]]
concord.component("Movable", function(component, vel, maxVel, acceleration, friction)
    component.vel = vel or { x = 0, y = 0 }
    component.maxVel = maxVel or { x = 3000, y = 3000 }
    component.acceleration = acceleration or { x = 0, y = 0 }
    component.friction = friction or { x = 0, y = 0 }
end)


-- concord.component("MovableAngular", function(component, speed_polar, maxSpeed, acceleration_polar)
--     component.speed_polar = speed_polar or {0, 0}
--     component.maxSpeed = maxSpeed or 3000
--     component.acceleration_polar = acceleration_polar or {0, 0}
-- end)


--[[
    Path
]]
concord.component("Path", function(component, points, duration)
    component.points = points
    component.duration = duration
    component.t = 0
end)
    

--[[
    SpriteRenderer
]]
concord.component("SpriteRenderer", function(component, index)
    component.index = index
    -- component.sprite = nil
    -- component.selection = nil
    -- component.frames = {}
end)


--[[
    Animation
]]
concord.component("Animation", function(component, fps)
    component.fps = fps
    component.time = 0
end)


--[[
    Animator
]]
concord.component("Animator", function(component, states, transitions, variables)
    component.states = states
    component.currentState = states[ENTRY_STATE]
    component.transitions = transitions
    component.variables = variables
end)


-- :addComponent(states, transistions, {name = {"transform", "position"}, name2 = {"abc"}})


-- --[[
--     BoxCollider
-- ]]
-- concord.component("BoxCollider", function(component, width, height, offset)
--     component.width = width or 0
--     component.height = height or 0
--     component.offset = offset or {x = 0, y = 0}
-- end)

--[[
    Collider
]]
concord.component("Collider", function(component, type, values, offset, colliding_func)
    component.type = type
    component.values = values
    component.offset = offset or {x = 0, y = 0}
    component.vars = {}
    component.colliding_func = colliding_func or function() end
end)


-- --[[
--     CircleCollider
-- ]]
-- concord.component("CircleCollider", function(component, radius, offset)
--     component.radius = radius or 0
--     component.offset = offset or {x = 0, y = 0}
-- end)


--[[
    Player
]]
concord.component("Controllable", function(component, hp)
    component.hp = hp or 100
end)


--[[
    Projectile
]]
concord.component("Projectile", function(component, damage, friendly)
    component.damage = damage or 5
    component.friendly = friendly or false   
end)


--[[
    States
]]
concord.component("Timeline", function(component, actions)
    component.actions = actions
    component.curIndex = 1
    component.vars = {}
end)


-- DEBUG

--[[
    BoxRenderer
]]
concord.component("BoxRenderer", function(component, width, height, color, mode)
    component.width = width or 0
    component.height = height or 0
    component.color = color or {1, 0, 0, 1}
    component.mode = mode or "fill"
end)


--[[
    CicleRenderer
]]
concord.component("CircleRenderer", function(component, radius, color, mode)
    component.radius = radius or 0
    component.color = color or {1, 0, 0, 1}
    component.mode = mode or "fill"
end)
