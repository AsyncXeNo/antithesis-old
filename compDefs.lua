
local concord = require "libs.Concord"


--[[
    Position
]]
concord.component("Position", function(component, x, y)
    component.x = x or 0
    component.y = y or 0
end)

--[[
    Velocity
]]
concord.component("Velocity", function(component, x, y, maxVel)
    component.x = x or 0
    component.y = y or 0
    component.maxVel = maxVel or 50000
end)


--[[
    SpriteRenderer
]]
concord.component("SpriteRenderer", function(component, spritesheet)
    component.spritesheet = spritesheet
    component.sprite = love.graphics.newQuad(0, 0, spritesheet.width, spritesheet.height)
    component.frames = {}
end)


--[[
    Animation
]]
concord.component("Animation", function(component, fps)
    component.fps = assert(fps)
    component.time = 0
end)


--[[
    Animator
]]
concord.component("Animator", function(component, states, transitions, variables)
    component.states = states
    component.transitions = transitions
    component.variables = variables
end)

    
--[[
    BoxCollider
]]
concord.component("BoxCollider", function(component, width, height, offset)
    component.width = width or 0
    component.height = height or 0
    component.offset = offset or {x = 0, y = 0}
end)


--[[
    CircleCollider
]]
concord.component("CircleCollider", function(component, radius, offset)
    component.radius = radius or 0
    component.offset = offset or {x = 0, y = 0}
end)


--[[
    Player
]]
concord.component("Controllable", function(component, acceleration)
    component.acceleration = acceleration
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
