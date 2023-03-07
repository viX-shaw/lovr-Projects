require 'lovr.filesystem'
local http = require('luajit-request')
http.send("http://192.168.1.4:5006/pythonOSC/1/49/0.4")
local lovr = {thread = require 'lovr.thread'}

local channelName = ...
local channel = lovr.thread.getChannel(channelName)
print("Listening channel "..channelName)
while true do
    local url = 'http://192.168.1.4:5006/pythonOSC/%s/%d/0.4'
    local _, present = channel:peek()
    if present then
        url = string.format(url, channelName, channel:pop())
        http.send(url)
        print("Sending Note ...")
    end
end
