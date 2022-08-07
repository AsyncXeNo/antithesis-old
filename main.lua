
require "compDefs"
require "sysDefs"
local inspect = require "inspect"
local logger = require "log"
local concord = require "libs.Concord"
local spriteSheets = require "res.spriteSheets"
local states = require "res.states"
local push = require "push"


print(inspect(spriteSheets))


function love.load()
    love.mouse.setVisible(false)
    
    -- globals
    local gameWidth, gameHeight = love.graphics.getDimensions()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(gameWidth, gameHeight) -- Resizable 1280x720 window
    push.setupScreen(1024, 576, {upscale = "normal"}) -- 800x600 game resolution, upscaled
    logger.info("Started")
    World = concord.world():addSystem(ResourceSystem):addSystem(DebugRenderSystem):addSystem(MovementSystem):addSystem(InputSystem):addSystem(AnimationSystem):addSystem(TimelineSystem):addSystem(CollisionSystem):addSystem(DrawSystem)
    local player = concord.entity(World)
        :give("Position", 50, 400)
        :give("Movable", { x = 0, y = 0 }, { x = 200, y = 200 }, { x = 0, y = 0 }, { x = 0, y = 0 })
        :give("SpriteRenderer", "player")
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
        :give("SpriteRenderer")
        :give("Animation")
        :give(
            "Animator",
            states.enemy1.states,
            states.enemy1.transitions,
            states.enemy1.variables
        )
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
                "wait",
                2
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
    push:start()
    World:emit("draw")
    push:finish()
end
