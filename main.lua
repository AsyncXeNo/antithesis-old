
require "compDefs"
require "sysDefs"
local logger = require "log"
local concord = require "libs.Concord"


function love.load()
    love.mouse.setVisible(false)
    
    -- globals
    local gameWidth, gameHeight = love.graphics.getDimensions()
    logger.info("Started")
    World = concord.world():addSystem(DebugRenderSystem):addSystem(MovementSystem):addSystem(InputSystem):addSystem(TimelineSystem):addSystem(CollisionSystem)
    local player = concord.entity(World)
        :give("Position", 50, 400)
        :give("Movable", { x = 0, y = 0}, { x = 200, y = 200 }, { x = 0, y = 0 }, { x = 0, y = 0 })
        :give("BoxRenderer", 20, 20, {1, 0 , 0, 1})
        :give("Controllable")
        :give("Collider", "box", { width=20, height=20 }, { x = 0, y = 0}, function(obj, world) logger.debug('Collision!!!!!!!!!!') end)

    -- local bullet_test = concord.entity(World)
    --     :give("Position", 960, 0)
    --     :give("CircleRenderer", 10, {0, 0, 1, 1})
    --     :give("Path", {
    --         {
    --             {x=-600,y=270},
    --             {x=180, y=180},
    --             {x=0, y=400}
    --         },
    --         {
    --             {x=750, y=680},
    --             {x=0, y=800}
    --         }
    --     }, 7)

    local enemy = concord.entity(World)
        :give("Position", 30, 30)
        :give("Collider", "circle", {r=10})
        :give("CircleRenderer", 10, {0, 1, 0, 1})
        :give("Timeline", {
            {
                "move",
                {x = 512, y = 50},
                0.01
            },
            {
                "shoot",
                "burst",
                math.pi,
                40,
                10,
                0.2, -- burst time
                20,
                {
                    speed = 300,

                }
            },
            {
                "move",
                {x = 1300, y = -300},
                0.01
            }
        })
        
    World:emit("init", World)
end

function love.update(dt)
    World:emit("update", dt)
end


function love.keypressed(key, scancode, isrepeat)
    -- debug
    if key == 'escape' then
        love.event.quit()
    end
end


function love.draw()
    World:emit("draw")
end
