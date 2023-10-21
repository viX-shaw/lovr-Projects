
-- local model = nil
-- function lovr.load()
--     success = lovr.headset.setPassthrough(true)
--     print("ENABLING PASSTHRU..")
--     print(success)

--     model = lovr.graphics.newModel('vippyn.glb')
-- end

-- function lovr.draw(pass)
--     pass:text('hello world', 0, 1.7, -0.5)
--     if model ~= nil then
--         pass:setShader('unlit')
--         pass:draw(model, -0.4, 0, 2.1, 1.2, 1.57)
--     end
-- end

-- local ffi = require('ffi')
-- local vlc = require 'stream'

-- local imageData = nil
local width = nil
local height = nil
-- local pitch = width * 4

local drawImg = nil
local drawTexLeft = nil
local drawTexRight = nil

-- local image = lovr.data.newImage(width, height)
-- local pixels = ffi.cast('uint8_t*', image:getBlob():getPointer())
-- local startTime = nil

-- local media_player = nil
-- local vlc_instance = nil
-- local big_buck_bunny_url = nil
-- local media = nil

-- local stopped = false
local channelName = "q"
local imgDimsChannelName = "r"
local channel = lovr.thread.getChannel(channelName)
local imgDimsChannel = lovr.thread.getChannel(imgDimsChannelName)
-- local lock_callback = ffi.cast("libvlc_video_lock_cb", function(opaque, planes)
-- -- add logic
--     -- planes = ffi.typeof("uint8_t[$][$][$]", width, height, 4)
--     ffi.C.printf("LOCK CB\n")
--     planes[0] = opaque
--     return nil
-- end)
    
-- local unlock_callback = ffi.cast("libvlc_video_unlock_cb", function(opaque, picture, planes)
--     -- add logic
--     -- ffi.C.printf("UNLOCK CB \n")
--     -- pixels = planes
--     channel:push(ffi.string(opaque, 1658880))
-- end)

-- local pic_callback = ffi.cast("libvlc_video_display_cb", function(opaque, picture)
--     -- add logic
--     -- ffi.C.printf("DISPLAY CB \n")
--     -- pixels = planes
--     -- channel:push(ffi.string(opaque))
-- end)

-- local vid_format_cb = ffi.cast("libvlc_video_format_cb", function (opaque, chroma, w, h, pitches, lines)
-- 	-- print the chroma before changing
--     print(" ............. FORMAT CB "..tostring(w[0]).."  "..tostring(h[0]))
--     chroma = ffi.new("const char* ", "RV32")
--     pitches = ffi.new("unsigned[4]", { pitch, pitch, pitch, pitch})
--     lines = ffi.new("unsigned[4]", { height, height, height, height})
--     return ffi.new('unsigned', 4)
-- end)

-- local function retrieve_frame(media_player)
--     print("setting callbacks")
--     vlc.libvlc_video_set_callbacks(media_player, lock_callback, unlock_callback, pic_callback, pixels)
--     -- vlc.libvlc_video_set_format(media_player, "RGBA", ffi.new('unsigned', width), ffi.new('unsigned', height), ffi.new('unsigned', width * 4) );-- pitch = width * BitsPerPixel / 8
--     vlc.libvlc_video_set_format_callbacks(media_player, vid_format_cb, nil)
-- end

-- jit.off(retrieve_frame)

-- function lovr.load()
--     ffi.C.printf("STARTING TO LOAD\n")
--     lovr.graphics.setBackgroundColor(0,0.08,0.1,0)
--     vlc_instance = vlc.libvlc_new(ffi.new('int', 3), ffi.new('const char *const[3]', {"-vvv", "--no-audio", "--no-xlib"}))
--     -- big_buck_bunny_url = "/sdcard/Oculus/VideoShots/org.lovr.app-20230304-225759_123.mp4"
--     -- big_buck_bunny_url = "./org.lovr.app-20230304-225759.mp4"

--     -- local big_buck_bunny_url = "https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov"
--     big_buck_bunny_url = "https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.avi"
--     -- local big_buck_bunny_url = "https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_stereo.avi"
--     -- big_buck_bunny_url = "http://samplelib.com/lib/preview/mp4/sample-5s.mp4"


--     media = vlc.libvlc_media_new_location(vlc_instance, big_buck_bunny_url)
--     -- media = vlc.libvlc_media_new_path(vlc_instance, big_buck_bunny_url)
--     media_player = vlc.libvlc_media_player_new(vlc_instance)
--     vlc.libvlc_media_player_set_media(media_player,media)

--     ffi.C.printf(vlc.libvlc_media_get_mrl(media))
--     retrieve_frame(media_player)
--     vlc.libvlc_media_player_play(media_player)
--     startTime = lovr.timer.getTime()
--     print("LOADINGCOMPLETE")
-- end

function lovr.load()
    -- success = lovr.headset.setPassthrough(true)
    -- print("ENABLING PASSTHRU..")
    -- print(success)
    lovr.graphics.setBackgroundColor(0,0.08,0.1,0)
    stream = lovr.thread.newThread('vlc.lua')
    stream:start(channelName, imgDimsChannelName)
end

function setImgDims(blobsize)
    if height then return end
    local _, present = imgDimsChannel:peek()
    if present then
        width = imgDimsChannel:pop()
        height = blobsize/(width*4)
        print("Setting Width = "..width.." and Height= "..height.." in Main Thread")
        drawTexLeft = lovr.graphics.newTexture(width, height, {mipmaps = false,  usage = {'sample', 'render', 'transfer'}})
        -- drawTexRight = lovr.graphics.newTexture(width-1000, height, { usage = {'sample', 'render', 'transfer'}})
    end
end

function lovr.draw(pass)
    local frame = channel:pop()
    if frame then
        local blob = lovr.data.newBlob(frame)
        if blob:getSize() > 0 then
            -- print("HERE"..blob:getSize())
            -- drawImg = lovr.data.newImage(864, 480, 'rgba8', blob)
            setImgDims(blob:getSize())
            drawImg = lovr.data.newImage(width, height, 'rgba8', blob)
            -- print('IMG DATA')
            -- drawTex = {}
            -- drawTex = lovr.graphics.newTexture(drawImg)
            -- drawTex = lovr.graphics.newTexture(lovr.data.newImage(width, height, 'rgba8', blob))
        end
        frame = {}
    end
    -- pass:plane(0, 1.7, -0.4, 2.560/3, 1.44/3)
    -- if imageData ~= nil then
    -- end
    
    -- if drawImg then
    --     pass:setMaterial(drawTex)
    -- end

    if height then
        drawTexLeft:setPixels(drawImg,0,0,1,1,0,0,1,1,1000,height*0.8)-- dst_w, dst_h, dst_layer, dst_level, src_w, src_h, src_layer, src_level
        -- drawTexRight:setPixels(drawImg,1000,0,1,1,0,0,1,1,width-1000,height*0.8)
        if width > 1000 then
            drawTexLeft:setPixels(drawImg,1000,0,1,1,1000,0,1,1,width-1000,height*0.8)-- dst_w, dst_h, dst_layer, dst_level, src_w, src_h, src_layer, src_level
        end
        drawTexLeft:setPixels(drawImg,0,(height*0.8),1,1,0,(height*0.8),1,1,width,height*0.2)
        pass:setMaterial(drawTexLeft)
        pass:plane(0, 1.7, -1.0, width/1000, height/1000)
        -- pass:setMaterial(drawTexRight)
        -- pass:plane(0+(1000/2000), 1.7, -2, (width-1000)/2000, height/2000)
    else
        pass:plane(0, 1.7, -1.0, 0.864, 0.480) --master
    end
    
    -- local vidFramePass = lovr.graphics.getPass('transfer')
    -- vidFramePass:copy(drawImg, drawTex)
    -- lovr.graphics.submit(vidFramePass, pass) -- if in lovr.draw, submit along with the main pass
end

-- Notes
-- print the chroma before changing - printing just once before all the cb(s)
-- also try with a static image since the Pass is a new thing to work with in 0.16 - working
-- also note when and how many times format callback is being called - just once

