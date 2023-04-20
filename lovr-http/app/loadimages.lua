require 'lovr.filesystem'
local request = require("luajit-request/luajit-request")

local lovr = {
    thread = require 'lovr.thread',
    data = require 'lovr.data',
    timer = require 'lovr.timer'
}

local channelName, imgDims, nImages = ...
local channel = lovr.thread.getChannel(channelName)

function process_response(response)
    if response and response.body ~= "False" and response.code == 200 then
        local img = lovr.data.newImage(lovr.data.newBlob(response.body))
        -- print('THREAD'..img:getHeight().." "..img:getWidth())
        channel:push(img)
        response = {}
    end
end

if channelName == "load-thumbnails" then
    i = 1
    while i <= nImages do
        local response = nil
        response = request.send("http://192.168.1.5:4990/thumbnails/"..imgDims.."/"..i)
        process_response(response)
        i = i + 1
    end
else
    nth_image = nImages
    response = request.send("http://192.168.1.5:4990/fullsize/"..nth_image)
    process_response(response)
end