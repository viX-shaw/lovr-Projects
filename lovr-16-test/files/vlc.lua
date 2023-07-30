require 'lovr.filesystem'

local lovr = {
    thread = require 'lovr.thread',
    data = require 'lovr.data',
    timer = require 'lovr.timer'
}
local ffi = require('ffi')
local vlc = require 'stream'

local channelName = ...
local channel = lovr.thread.getChannel(channelName)

local media_player = nil
local vlc_instance = nil
local big_buck_bunny_url = nil
local media = nil

local width = 864
local height = 480
local pitch = width * 4

local ref_image = lovr.data.newImage('mountain.jpg')

local image = lovr.data.newImage(width, height)
image:paste(ref_image, 100,100,0,0,100,100)
local pixels = ffi.cast('uint8_t*', image:getBlob():getPointer())

local startTime = lovr.timer.getTime()

local lock_callback = ffi.cast("libvlc_video_lock_cb", function(opaque, planes)
    -- add logic
    -- planes = ffi.typeof("uint8_t[$][$][$]", width, height, 4)
    ffi.C.printf("LOCK CB\n")
    local p = ffi.cast('uint8_t*', lovr.data.newImage(width, height):getBlob():getPointer())
    planes[0]=p
    return p
    -- planes[0] = opaque
    -- return nil
end)
        
local unlock_callback = ffi.cast("libvlc_video_unlock_cb", function(opaque, picture, planes)
    -- add logic
    -- ffi.C.printf("UNLOCK CB \n")
    -- pixels = planes
    -- channel:push(ffi.string(opaque, 1658880))
    channel:push(ffi.string(picture, 1658880))
    if lovr.timer.getTime() - startTime > 35 then
        print("PLAy ENDED")
        vlc.libvlc_media_release(media)
        -- vlc.libvlc_media_player_stop(media_player)
        vlc.libvlc_media_player_release(media_player)
        vlc.libvlc_release(vlc_instance)
        -- lock_callback:free()
        -- unlock_callback:free()
        print("PLAy ENDED")
        print("PLAy ENDED")
    end
end)

local pic_callback = ffi.cast("libvlc_video_display_cb", function(opaque, picture)
    -- add logic
    -- ffi.C.printf("DISPLAY CB \n")
    -- pixels = planes
    -- channel:push(ffi.string(opaque))
    -- channel:push(ffi.string(opaque, 1658880))
end)

local vid_format_cb = ffi.cast("libvlc_video_format_cb", function (opaque, chroma, w, h, pitches, lines)
    -- print the chroma before changing
    ffi.C.printf("%s \n", chroma)
    print(" ............. FORMAT CB "..tostring(w[0]).."  "..tostring(h[0]))
    -- chroma = ffi.new("const char* ", "RV32")
    ffi.copy(chroma, "RV32", 4)
    -- pitches = ffi.new("unsigned[1]", {pitch})
    -- lines = ffi.new("unsigned[1]", {height})
    pitches[0] = ffi.new("unsigned", 864 * 4)
    lines[0] = ffi.new("unsigned", 480)
    return ffi.new('unsigned', 1)
end)

local function retrieve_frame(media_player)
    print("setting callbacks")
    vlc.libvlc_video_set_callbacks(media_player, lock_callback, unlock_callback, pic_callback, pixels)
    -- vlc.libvlc_video_set_format(media_player, "RGBA", ffi.new('unsigned', width), ffi.new('unsigned', height), ffi.new('unsigned', width * 4) );-- pitch = width * BitsPerPixel / 8
    vlc.libvlc_video_set_format_callbacks(media_player, vid_format_cb, nil)
end

jit.off(retrieve_frame)


ffi.C.printf("STARTING TO LOAD\n")
vlc_instance = vlc.libvlc_new(ffi.new('int', 3), ffi.new('const char *const[4]', {"-v", "2", "--no-audio", "--no-xlib"}))
-- big_buck_bunny_url = "/sdcard/Oculus/VideoShots/org.lovr.app-20230304-225759_123.mp4"
-- big_buck_bunny_url = "./org.lovr.app-20230304-225759.mp4"

-- local big_buck_bunny_url = "https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov"
-- big_buck_bunny_url = "https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.avi"
-- local big_buck_bunny_url = "https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_stereo.avi"
-- big_buck_bunny_url = "http://samplelib.com/lib/preview/mp4/sample-5s.mp4"

big_buck_bunny_url = "http://192.168.1.2:8000/TownCentreXVID.avi"
-- big_buck_bunny_url = "https://youtu.be/yki__2sGHU8"

if vlc_instance ~= nil then
    media = vlc.libvlc_media_new_location(vlc_instance, big_buck_bunny_url)
    -- media = vlc.libvlc_media_new_path(vlc_instance, big_buck_bunny_url)
    media_player = vlc.libvlc_media_player_new(vlc_instance)
    if media_player ~= nil then
        vlc.libvlc_media_player_set_media(media_player,media)
        
        ffi.C.printf(vlc.libvlc_media_get_mrl(media))
        retrieve_frame(media_player)
        local play_status = vlc.libvlc_media_player_play(media_player)
        print("PLAYSTATUS", play_status)
        if play_status == -1 then
            print('Error while starting the media')
            vlc.libvlc_media_release(media)
            vlc.libvlc_release(vlc_instance)
            print('EXIT')
        else
            print("LOADINGCOMPLETE")
        end
    else
        print("Could not create a new media player instance")
        vlc.libvlc_media_release(media)
        vlc.libvlc_release(vlc_instance)
    end
else
    print("Could not create a libvlc instance")
end

-- while 1 do
--     lovr.timer.sleep(10)
-- end
-- stop = false
-- while true and stop == false do
--     if lovr.timer.getTime() - startTime > 10 then
--         vlc.libvlc_media_player_stop(media_player)
--         vlc.libvlc_media_player_release(media_player)
--         vlc.libvlc_release(vlc_instance)
--         lock_callback:free()
--         unlock_callback:free()
--         print("PLAy ENDED")
--         print("PLAy ENDED")
--         print("PLAy ENDED")
--         stop = true
--     end
-- end