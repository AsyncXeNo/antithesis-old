
require "compDefs"
require "sysDefs"
logger = require "log"
concord = require "libs.Concord"


function love.load()
    love.mouse.setVisible(false)
    
    -- globals
    gameWidth, gameHeight = love.graphics.getDimensions()
    logger.info("Started")
    world = concord.world():addSystem(DebugRenderSystem):addSystem(MovementSystem):addSystem(InputSystem):addSystem(TimelineSystem)
    player = concord.entity(world)
        :give("Position", 100, 600)
        :give("Movable", { x = 0, y = 0}, { x = 300, y = 300 }, { x = 0, y = 0 }, { x = 0, y = 0 })
        :give("BoxRenderer", 50, 50, {1, 0 , 0, 1})
        :give("Controllable")

    enemy = concord.entity(world)
        :give("Position", 0, 0)
        :give("CircleRenderer", 25, {0, 1, 0, 1})
        :give("Timeline", {
            {
                "move",
                {x = 650, y = 300},
                0.02
            },
            {
                "shoot",
                "burst",
                math.pi,
                40,
                10,
                0.1,
                20,
                {
                    speed = 300,

                }
            },
            {
                "move",
                {x = 1300, y = -300},
                0.02
            }
        })
end


function love.update(dt)
    world:emit("update", dt)
end


function love.keypressed(key, scancode, isrepeat)
    -- debug
    if key == 'escape' then
        love.event.quit()
    end
end


function love.draw()
    world:emit("draw")
end
