
require "compDefs"
require "sysDefs"
logger = require "log"
concord = require "libs.Concord"


function love.load()
    love.mouse.setVisible(false)
    
    -- globals
    gameWidth, gameHeight = love.graphics.getDimensions()
    logger.info("Started")
    world = concord.world():addSystem(DebugRenderSystem):addSystem(MovementSystem)
    player = concord.entity(world):give("Position", 100, 100):give("Velocity"):give("BoxRenderer", 50, 50, {1, 0 , 0, 1}):give("Controllable", 10000)
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
