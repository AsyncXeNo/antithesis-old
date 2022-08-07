
require "utils"
require "constants"

local concord = require "libs.Concord"
local controls = require "controls"
local logger = require "log"
local inspect = require "inspect"
local sprites_indices = require "res.index"
local spritesheets_catalog = require "res.spriteSheets"

--[[
    ResourceSystem
]]
ResourceSystem = concord.system {
    
}

function ResourceSystem:init ()
    local world = self:getWorld()
    world.atlas = {}
    world.spritesheets = {}

    for k,v in pairs(sprites_indices) do 
        world.atlas[k] = love.graphics.newImage(SPRITES_PATH .. v)
    end

    for k,v in pairs(spritesheets_catalog) do 
        world.spritesheets[k] = {}
        local spritesheet = world.spritesheets[k]
        spritesheet.sprite = love.graphics.newImage(SPRITES_PATH .. v.path)
        spritesheet.perCell = v.perCell
        spritesheet.padding = v.padding
        spritesheet.frameCount = v.frames
        spritesheet.frames = {}

        local framesPerRow = spritesheet.sprite:getWidth() / (spritesheet.perCell.x + 2 * spritesheet.padding.x)

        for i=1,spritesheet.frameCount,1 do
            spritesheet.frames[i] = love.graphics.newQuad(
                spritesheet.padding.x + ((i - 1) % framesPerRow) * (2 * spritesheet.padding.x + spritesheet.perCell.x),
                spritesheet.padding.y + math.floor((i - 1) / framesPerRow) * (2 * spritesheet.padding.y + spritesheet.perCell.y),
                spritesheet.perCell.x,
                spritesheet.perCell.y,
                spritesheet.sprite
            )
        end
    end
end


--[[
    AnimationSystem
]]
AnimationSystem = concord.system {
    normAnims = {
        "Position",
        "SpriteRenderer",
        "Animation",
    },
    customAnims = {
        "Position",
        "SpriteRenderer",
        "Animation",
        "Animator"
    }
}


function AnimationSystem:init()
    for _,e in ipairs(self.customAnims) do
        e.SpriteRenderer.index = e.Animator.states[e.Animator.currentState].spritesheet
        e.Animation.fps = e.Animator.states[e.Animator.currentState].fps
        
        for _,t in ipairs(e.Animator.transitions) do
            if #t.condition % 2 == 0 then
                t.condition[#t.condition] = nil
            end
        end
    end
    for _,e in ipairs(self.normAnims) do
        e.SpriteRenderer.spritesheet = self:getWorld().spritesheets[e.SpriteRenderer.index]
    end
end

function AnimationSystem:getMapping(current, table)
    local value = current
    for k,v in pairs(table) do
        if type(v) == "table" then
            local d = AnimationSystem:getMapping(current, v)
            value = value[d]
        else
            value = value[v]
        end
    end
    return value
end

function AnimationSystem:update (dt)
    for _,e in ipairs(self.customAnims) do
        --Get all values from given mappings
        local vars = {}
        for k,v in pairs(e.Animator.variables) do
            vars[k] = AnimationSystem:getMapping(e, v)
        end

        --Check against all transitions that have from as the current animation
        for k,v in pairs(e.Animator.transitions) do
            if v.from == e.Animator.currentState then
                local str = ""
                for a,c in ipairs(v.condition) do
                    if a % 2 == 0 then
                        if c == "AND" then
                            str = str .. " and "
                        elseif c == "OR" then
                            str = str .. " or "
                        end
                    else
                        local replaced = c
                        for index, var in pairs(vars) do
                            if type(var) == "string" then
                                var = "'" .. var .. "'"
                            end
                            replaced = string.gsub(replaced, index, var)
                        end
                        str = str .. replaced 
                    end
                end
                
                local func = assert(loadstring("return " .. str))
                if func() then 
                    e.Animator.currentState = v.to
                    e.Animation.fps = e.Animator.states[e.Animator.currentState].fps
                    e.SpriteRenderer.index = e.Animator.states[e.Animator.currentState].spritesheet
                    e.SpriteRenderer.spritesheet = self:getWorld().spritesheets[e.SpriteRenderer.index]
                end
            end
        end
    end

    for _,e in ipairs(self.normAnims) do
        e.Animation.time = e.Animation.time + dt
    end

    for _,e in ipairs(self.normAnims) do 
        local frame = (math.floor(e.Animation.time * e.Animation.fps) % e.SpriteRenderer.spritesheet.frameCount) + 1
        e.SpriteRenderer.selection = e.SpriteRenderer.spritesheet.frames[frame]
    end
end


--[[
    DrawSystem
]]
DrawSystem = concord.system {
    pool = {
        "Position",
        "SpriteRenderer"
    }
}

function DrawSystem:init()
    for _, e in ipairs(self.pool) do
        if not e.SpriteRenderer.spritesheet then
            e.SpriteRenderer.spritesheet = {
                sprite = self:getWorld().atlas[e.SpriteRenderer.index]
            }
        end
    end
end

function DrawSystem:draw()
    for _, e in ipairs(self.pool) do

        if e.SpriteRenderer.selection then
            love.graphics.draw(
                e.SpriteRenderer.spritesheet.sprite,
                e.SpriteRenderer.selection,
                e.Position.x - round(e.SpriteRenderer.spritesheet.perCell.x / 2, 1), 
                e.Position.y - round(e.SpriteRenderer.spritesheet.perCell.y / 2, 1)
            )
        else
            love.graphics.draw(
                e.SpriteRenderer.spritesheet.sprite,
                e.Position.x - round(e.SpriteRenderer.spritesheet.sprite:getWidth() / 2, 1), 
                e.Position.y - round(e.SpriteRenderer.spritesheet.sprite:getHeight() / 2, 1)
            )
        end
    end
end


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
            logger.debug("hello")
            e:getWorld():removeEntity(e)
        else 
            if action[1] == "move" then
                if math.abs(e.Position.x - lerp(e.Position.x, action[2].x, action[3])) < 1 and math.abs(e.Position.y - lerp(e.Position.y, action[2].y, action[3])) < 1 then
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
                                :give("Collider", "circle", {r=5})
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
            elseif action[1] == "wait" then 
                e.Timeline.vars.timePassed = (e.Timeline.vars.timePassed or 0) + dt
                if e.Timeline.vars.timePassed > action[2] then
                    e.Timeline.vars = {}
                    e.Timeline.curIndex = e.Timeline.curIndex + 1
                end
            end
        end
        local action = e.Timeline.actions[e.Timeline.curIndex]        
        if action == nil then
            logger.debug("hello")
            e:getWorld():removeEntity(e)
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
            local dx = (#e.Path.points) / e.Path.duration
            e.Position = e.Path.path_func(e.Path.t)
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
    entities = {
        "Position",
        "Collider"
    }
}


function CollisionSystem:update(dt)
    self.quadTree = {
        objs = list2Set(self.entities),
        bounds = {
            {x = 0, y = 0},
            {x = RESOLUTION.width, y=RESOLUTION.height}
        }
    }
    
    for _,e in ipairs(self.entities) do
        e.Collider.vars.node = self.quadTree
    end

    if len(self.quadTree.objs) > MAX_ENTITIES then 
        self.splitNode(self.quadTree)
    end

    for _,e in ipairs(self.entities) do
        colliding = self.checkForCollision(e, e.Collider.vars.node)
        for _,obj in ipairs(colliding) do
            e.Collider.colliding_func(obj, self:getWorld())
        end
    end
end 


function CollisionSystem:draw()
    CollisionSystem.drawNode(self.quadTree)
end


function CollisionSystem.drawNode(node)
    if not node then return end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", node.bounds[1].x, node.bounds[1].y, node.bounds[2].x - node.bounds[1].x, node.bounds[2].y - node.bounds[1].y)

    for i=1,4 do CollisionSystem.drawNode(node[i]) end
end


function CollisionSystem.checkForCollision(obj, node)
    if not node then return {} end

    list = {}
    for e in pairs(node.objs) do
        if obj ~= e then
           if CollisionSystem.isColliding(obj, e) then table.insert(list, #list+1, e) end
        end
    end 

    for i=1,4 do
        combineLists(list, CollisionSystem.checkForCollision(obj, node[i]))
    end

    return list
end


function CollisionSystem.isColliding(obj1, obj2)
    if obj1.Collider.type == "box" then
        if obj2.Collider.type == "circle" then return CollisionSystem.isCollidingBC(obj1, obj2) end
        if obj2.Collider.type == "box" then return CollisionSystem.isCollidingBB(obj1, obj2) end
    elseif obj1.Collider.type == "circle" then
        if obj2.Collider.type == "circle" then return CollisionSystem.isCollidingCC(obj1, obj2) end
        if obj2.Collider.type == "box" then return CollisionSystem.isCollidingBC(obj2, obj1) end
    end
end


function CollisionSystem.isCollidingBC(box, circle)
    distance = {}
    distance.x = math.abs(circle.Position.x - box.Position.x)
    distance.y = math.abs(circle.Position.y - box.Position.y)

    if (distance.x > (box.Collider.values.width / 2 + circle.Collider.values.r)) then return false end
    if (distance.y > (box.Collider.values.height / 2 + circle.Collider.values.r)) then return false end

    if (distance.x <= (box.Collider.values.width / 2)) then return true end 
    if (distance.y <= (box.Collider.values.height / 2)) then return true end

    cornerDistance_sq = (distance.x - box.Collider.values.width/2)^2 +
                         (distance.y - box.Collider.values.height/2)^2

    return (cornerDistance_sq <= (circle.Collider.values.r^2))
end


function CollisionSystem.isCollidingBB(obj1, obj2)
    distance = {}
    distance.x = math.abs(obj1.Position.x - obj2.Position.x)
    distance.y = math.abs(obj1.Position.y - obj2.Position.y)
    
    w1 = obj1.Collider.values.width/2
    w2 = obj2.Collider.values.width/2
    h1 = obj1.Collider.values.height/2
    h2 = obj2.Collider.values.height/2
    
    x_axis = distance.x <= w1+w2
    y_axis = distance.y <= h1+h2
    
    return x_axis and y_axis
end


function CollisionSystem.isCollidingCC(obj1, obj2)
    r1 = obj1.Collider.values.r
    r2 = obj2.Collider.values.r
    distance = math.sqrt((obj1.Position.x - obj2.Position.x)^2 + (obj1.Position.y - obj2.Position.y)^2)
    if distance > r1+r2 then return false end
    return true
end



function CollisionSystem.getChildBounds(node)
    topLeft = {
        x = node.bounds[1].x,
        y = node.bounds[1].y,
    }
    topMiddle = {
        x = (node.bounds[2].x + node.bounds[1].x) / 2,
        y = node.bounds[1].y
    }
    middleLeft = {
        x = node.bounds[1].x,
        y = (node.bounds[2].y + node.bounds[1].y) / 2
    }
    middleMiddle = {
        x = (node.bounds[2].x + node.bounds[1].x) / 2,
        y = (node.bounds[2].y + node.bounds[1].y) / 2
    }
    middleRight = {
        x = node.bounds[2].x,
        y = (node.bounds[2].y + node.bounds[1].y) / 2,
    }
    bottomMiddle = {
        x = (node.bounds[2].x + node.bounds[1].x) / 2,
        y= node.bounds[2].y
    }
    bottomRight = {
        x = node.bounds[2].x,
        y = node.bounds[2].y
    }
    
    quads = {}
    quads[1] = {
        topMiddle,
        middleRight    
    }
    quads[2] = {
        topLeft,
        middleMiddle
    }
    quads[3] = {
        middleLeft,
        bottomMiddle
    }
    quads[4] = {
        middleMiddle,
        bottomRight
    }

    return quads
end



function CollisionSystem.splitNode(node)
    quads = CollisionSystem.getChildBounds(node)

    for i=1,4 do node[i] = { bounds = quads[i], objs = {} } end

    for obj in pairs(node.objs) do
        for i=1,4 do
            if isInBoundsobj(obj, node[i].bounds) then
                node.objs[obj] = nil
                node[i].objs[obj] = true
                obj.Collider.vars.node = node[i]
            end
        end
    end

    for i=1,4 do
        if len(node[i].objs) > MAX_ENTITIES then
            CollisionSystem.splitNode(node[i])
        end
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
        love.graphics.rectangle(e.BoxRenderer.mode, e.Position.x - e.BoxRenderer.width / 2, e.Position.y - e.BoxRenderer.height / 2, e.BoxRenderer.width, e.BoxRenderer.height)
    end
    for _,e in ipairs(self.circlePool) do
        love.graphics.setColor(unpack(e.CircleRenderer.color))
        love.graphics.circle(e.CircleRenderer.mode, e.Position.x, e.Position.y, e.CircleRenderer.radius)
    end
end
