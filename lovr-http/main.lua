local desktop = require 'desktop'

function lovr.load(arg)
    --
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
end

function lovr.update()
    --
    desktop.update()
end

function lovr.draw()
    --
    desktop.draw()
    
    if debugScene then
        lovr.graphics.print(errString, 1, 3, -3, 0.3)
        -- print("DEBUGGING")
    else
        lovr.graphics.print("FPS -"..lovr.timer.getFPS(), 1, 3, -3)
        lovr.graphics.print(p, 1, 3, -3)
    end
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