require 'lovr.filesystem'
local request = require("luajit-request/luajit-request")

local lovr = {
    thread = require 'lovr.thread',
    data = require 'lovr.data',
    timer = require 'lovr.timer'
}

local channelName, exitChannelName = ...
local channel = lovr.thread.getChannel(channelName)
local exitChannel = lovr.thread.getChannel(exitChannelName)

i = 1
while true and exitChannel:pop() ~= "exit" do
    local response = request.send("http://192.168.1.5:4990/stream")
    if response and response.body ~= "False" and response.code == 200 then
        channel:push(lovr.data.newImage(lovr.data.newBlob(response.body)))
        response = {}
    end
    i = i + 1
    if i % 50 == 0 then
        lovr.timer.sleep(0.2)
        -- print("Clear channel")
        channel:clear()
        i = 1
    end
end
