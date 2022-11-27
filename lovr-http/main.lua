require 'utils'
-- local request = require("luajit-request/luajit-request")
local channel, stream, mat, tex

function lovr.load()
    channelName = "lovr"
    channel = lovr.thread.getChannel(channelName)
    stream = lovr.thread.newThread('stream.lua')
    stream:start(channelName)
    mat = lovr.graphics.newMaterial(lovr.graphics.newTexture(1366, 768, 1, {}))
end

function lovr.update()
    reloadIfChanged()
    local _, present = channel:peek()
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
    lovr.graphics.plane(mat, 0, 0, -2, 1, 1)
    lovr.graphics.print("FPS2 -"..lovr.timer.getFPS(), 1, 2, -3)
end

function lovr.restart()
    print("Restart Event received..")
end

function lovr.errhand(message, traceback)
    traceback = traceback or debug.traceback('', 3)
    print('ohh NOOOO!', message)
    print(traceback)
    return function()
        -- lovr.graphics.print('There was an error', 0, 2, -5)
        -- print("err hand")
        return reloadIfChanged("restart")
    end
end