require 'utils'
-- local request = require("luajit-request/luajit-request")
local channel, stream, mat, tex
local sTime = lovr.timer.getTime()

function lovr.load()
    channelName = "lovr"
    exitChannelName = "lovrEXIT"
    exitLOVR = lovr.thread.getChannel(exitChannelName)
    channel = lovr.thread.getChannel(channelName)
    stream = lovr.thread.newThread('stream.lua')
    stream:start(channelName, exitChannelName)
    mat = lovr.graphics.newMaterial(lovr.graphics.newTexture(1366, 768, 1, {}))
end

function lovr.update()
    reloadIfChanged()
    -- if lovr.timer.getTime() - sTime > 15 then
    --     lovr.event.quit()
    -- end
end

function lovr.draw()
    --
    local _, present = channel:peek()
    if present then
        if tex == nil then
            print("First")
            tex = lovr.graphics.newTexture(channel:pop())
        else
            tex:replacePixels(channel:pop())
        end
        mat:setTexture(tex)
        _:release()
    end
    lovr.graphics.plane(mat, 0, 1.7, -0.8, 1.366, 0.728)
    lovr.graphics.print("FPSSS -"..lovr.timer.getFPS(), 1, 3, -3)
    -- lovr.graphics.print(p, 1, 3, -3)

end

function lovr.restart()
    if stream:isRunning() then
        exitLOVR:push("exit")
        stream:wait()
        print("Stream Closed")
    end
    print("Restart Event received..")
end

function lovr.errhand(message, traceback)
    traceback = traceback or debug.traceback('', 3)
    print('ohh NOOOO!', message)
    print(traceback)
    -- Close the thread
    if stream:isRunning() then
        exitLOVR:push("exit")
        stream:wait()
        print("Stream Closed")
    end
    return function()
        -- lovr.graphics.print('There was an error', 0, 2, -5)
        -- print("err hand")
        return reloadIfChanged("restart")
    end
end

function lovr.quit()
    if stream:isRunning() then
        exitLOVR:push("exit")
        stream:wait()
        print("Stream Closed")
    end
end