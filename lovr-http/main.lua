local desktop = require 'desktop'
local loco = require 'locomotion'
local locomotion, hands = loco[1], loco[2]
-- local app = require 'app/raymarch'
local app = require 'app/models'
local ui = require 'app/ui'

print(hands)
function lovr.load(arg)
    -- DESKTOP SETUP
    debugScene = false
    errString = nil
    desktop.load()
    -- print("ARG")
    -- print(arg.restart)
    if arg.restart == nil or arg.restart == "RESTART" then
        debugScene = false
    else
        debugScene = true
        errString = arg.restart
    end
    print("DEBUG"..tostring(debugScene))

    -- ACTUAL SCENE RELATED STUFF
    app.load()

end

function lovr.update(dt)
    --
    locomotion.update(dt)
    app.update(dt)
    ui.update(hands, dt)
    desktop.update()
end

function lovr.draw()
    --
    if debugScene then
        lovr.graphics.print(errString, 1, 3, -3, 0.3)
        -- print("DEBUGGING")
    else
        -- lovr.graphics.print(p, 1, 3, -3)
        locomotion.draw()
        app.draw()
        ui.draw(hands)
        lovr.graphics.print("FPS -"..lovr.timer.getFPS(), 1, 3, -3)
    end
    desktop.draw()
end

function lovr.errhand(msg, traceback)
    --
    print("ORIG ERROR===========")
    print(traceback)
    print("=====================")
    return desktop.errhand(msg, traceback)
end

function lovr.restart()
    --
    return desktop.restart()
end

function lovr.quit()
    --
    desktop.quit()
end