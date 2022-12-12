require 'utils'
-- local request = require("luajit-request/luajit-request")
local channel, stream, mat, tex
local sTime = lovr.timer.getTime()

local desktop = {}
local traceback = nil

function desktop.load()
    channelName = "lovr"
    exitChannelName = "lovrEXIT"
    exitLOVR = lovr.thread.getChannel(exitChannelName)
    channel = lovr.thread.getChannel(channelName)
    stream = lovr.thread.newThread('stream.lua')
    stream:start(channelName, exitChannelName)
    mat = lovr.graphics.newMaterial(lovr.graphics.newTexture(1366, 768, 1, {}))
end

function desktop.update()
    reloadIfChanged()
    -- if lovr.timer.getTime() - sTime > 15 then
    --     lovr.event.quit()
    -- end
end

function desktop.draw()
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
    lovr.graphics.plane(mat, 0, 1.6, -1.0, 1.366, 0.728)
end

function desktop.restart()
    if lovr.system.getOS() == "Windows" and stream:isRunning() then
        exitLOVR:push("exit")
        stream:wait()
        print("Stream Closed")
    end
    print("Restart Event received..")
    return "RESTART"
end

function desktop.errhand(message, traceback)
    traceback = traceback or debug.traceback('', 3)
    print('ohh NOOOO!', message)
    print(traceback)
    -- Close the thread
    if lovr.system.getOS() == "Windows" and stream:isRunning() then
        exitLOVR:push("exit")
        stream:wait()
        print("Stream Closed")
    end
    return function()
        lovr.event.pump()
        return 'restart', ""..message.."\n"..tostring(traceback)
    end
end

function desktop.quit()
    if stream:isRunning() then
        exitLOVR:push("exit")
        stream:wait()
        print("Stream Closed")
    end
end

return desktop