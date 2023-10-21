require 'lovr.filesystem'
local request = require("luajit-request/luajit-request")

local lovr = {
    thread = require 'lovr.thread',
    data = require 'lovr.data',
    timer = require 'lovr.timer',
    math = require 'lovr.math'
}

local channelName, imgDims, nImages = ...
local channel = lovr.thread.getChannel(channelName)
local remote_ip = '192.168.1.3:4990'

function process_response(response)
    if response and response.body ~= "False" and response.code == 200 then
        local img = lovr.data.newImage(lovr.data.newBlob(response.body))
        -- print('THREAD'..img:getHeight().." "..img:getWidth())
        channel:push(img)
        response = {}
    end
end

lovr.timer.sleep(lovr.math.random())
if channelName == "load-thumbnails" then
    i = nImages
    while i < (nImages + 3) do
        local response = nil
        response = request.send("http://"..remote_ip.."/thumbnails/"..imgDims.."/"..i)
        process_response(response)
        i = i + 1
    end
else
    nth_image = nImages
    response = request.send("http://"..remote_ip.."/fullsize/"..nth_image)
    process_response(response)
end