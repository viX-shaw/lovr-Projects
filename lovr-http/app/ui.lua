require 'utils'

local skybox_selector = {
    text = 'Choose Skybox',
    textSize = .1,
    count = 0,
    position = lovr.math.newVec3(-2, 2, -3),
    width = 1.0,
    height = .4,
    hover = false,
    active = false,
    prev_frame_active = false
}

local tips = {}
local pinch_released = {false, false} -- left and right hand pinch {1,3} {5,7}
local thumbnails = {}
local skybox = nil
local temp_skybox = nil
local thumbnails_ui = {}
local show_skybox_thumbnails = false
local skybox_fade_in = false
local old_skybox_fade_in_complete = false
local fade_in_start_time = 0

function load_thumbnails_ui()
    for i = 1,3 do
        table.insert(thumbnails_ui, {
            id = i,
            position = lovr.math.newVec3(-2, 1, -0.4 *i),
            width = 0.3,
            height = 0.3,
            hover = false,
            active = false,
            prev_frame_active = false
        })
    end
    print("THUMBNAIL UIs "..#thumbnails_ui)
end

function start_load_thumbnails()
    local n = 3
    local startTime = lovr.timer.getTime()
    local channelName = 'load-thumbnails'
    local channel = lovr.thread.getChannel(channelName)
    local load_thumbnails_thread = lovr.thread.newThread('app/loadimages.lua')
    load_thumbnails_thread:start(channelName, 150, n)
    -- Below for debugging

    -- lovr.timer.sleep(0.5) -- needed if using isRunning on thread to run the loop
    -- while true and lovr.timer.getTime() - startTime < 10 do
    --     local _, present = channel:peek()
    --     if present then
    --         local img = lovr.graphics.newTexture(channel:pop())
    --         print("IMG  "..img:getHeight())
    --         table.insert(thumbnails, img)
    --         _:release()
    --     end
    --     if #thumbnails == 3 then break end
    -- end
    -- if load_thumbnails_thread:isRunning() == false then
    --     print('LOADING THUMBNAILS COMPLETE! - '..#thumbnails)
    -- end
end

function change_skybox(element)
    -- RESUME
    local channelName = 'load-skybox'
    local channel = lovr.thread.getChannel(channelName)
    local load_thumbnails_thread = lovr.thread.newThread('app/loadimages.lua')
    load_thumbnails_thread:start(channelName, nil, element.id)
end

function do_something(element)
    if element.text == 'Choose Skybox' then
        show_skybox_thumbnails = not show_skybox_thumbnails
        if show_skybox_thumbnails then
            start_load_thumbnails()
        end
    else
        change_skybox(element)
    end
end

function check_hit(hit)
    local inside = false
    for idx, element in ipairs({skybox_selector}) do        
        if hit then
            local bx, by, bw, bh = element.position.x, element.position.y, element.width / 2, element.height / 2
            inside = (hit.x > bx - bw) and (hit.x < bx + bw) and (hit.y > by - bh) and (hit.y < by + bh)
            return inside, element
        end
    end
end

function skybox_selector.update(hands, dt)
    if #hands < 9 then return end
    skybox_selector.prev_frame_active = skybox_selector.active
    skybox_selector.hover , skybox_selector.active = false, false
    pinch_released = {false, false}

    for i, pinch in ipairs({{1, 3}, {6, 8}}) do -- finger indexes from lovr.headset.getSkeleton
        tips[i] = tips[i] or lovr.math.newVec3()

        local rayPosition = vec3(unpack(hands[pinch[1]], 1, 3))
        local rayDirection = vec3(quat(unpack(hands[pinch[1]], 4, 7)):direction())

        local hit = raycast(rayPosition, rayDirection, skybox_selector.position, vec3(0, 0, 1))

        local inside, element = check_hit(hit)
        -- local inside = false
        -- if hit then
        --     local bx, by, bw, bh = skybox_selector.position.x, skybox_selector.position.y, skybox_selector.width / 2, skybox_selector.height / 2
        --     inside = (hit.x > bx - bw) and (hit.x < bx + bw) and (hit.y > by - bh) and (hit.y < by + bh)
        -- end

        if inside then
            if checkPinch(rayPos:unpack(), unpack(hands[pinch[2]], 1, 3), 0.033) then
              skybox_selector.active = true
            else
              skybox_selector.hover = true
              if skybox_selector.prev_frame_active then
                pinch_released[i] = true
              end
            end
      
            if pinch_released[1] or pinch_released[2] then
            --   skybox_selector.count = skybox_selector.count + 1
                do_something(element)
              print('BOOP')
            end
        end
      
          -- Set the end position of the pointer.  If the raycast produced a hit position then use that,
          -- otherwise extend the pointer's ray outwards by 50 meters and use it as the tip.
        tips[i]:set(inside and hit or (rayPosition + rayDirection * 50))
    end
end

function transition_to_new_skybox()
    -- if skybox then
    local s = 0.99
    if skybox_fade_in then
        s = s - 2 * math.sin((lovr.timer.getTime() - fade_in_start_time) * 0.09)
        if s < -0.999 then
            skybox_fade_in = false
        end
        if s < 0.0 then
            old_skybox_fade_in_complete = true
            skybox = temp_skybox
        end
    end
    s = math.abs(s)
    lovr.graphics.setColor(s,s,s)
    -- end
    if s > 0.999 then
        change_skybox({id = lovr.math.random(2, 4) })
    end
end

function draw_selected_skybox()
    channel = lovr.thread.getChannel('load-skybox')
    _, present = channel:peek()
    if present then
        local img = lovr.graphics.newTexture(channel:pop())
        print("IMG  "..img:getHeight())
        fade_in_start_time = lovr.timer.getTime()
        skybox_fade_in = true
        old_skybox_fade_in_complete = false
        temp_skybox = img
        -- lovr.graphics.skybox(img)
        _:release()
    else
        transition_to_new_skybox()
    end
end

function draw_thumbnails()
    local channel = lovr.thread.getChannel('load-thumbnails')
    local _, present = channel:peek()
    if present then
        local img = lovr.graphics.newTexture(channel:pop())
        print("IMG  "..img:getHeight())
        table.insert(thumbnails, img)
        _:release()
    end
    for i, element in ipairs(thumbnails_ui) do
        if element.id <= #thumbnails then
            lovr.graphics.plane(lovr.graphics.newMaterial(thumbnails[element.id]), element.position, element.width, element.height, 1.57, 0,1,0)
        end
    end
end

function skybox_selector.draw(hands)
    -- skybox_selector background
    if skybox_selector.active then
        lovr.graphics.setColor(.4, .4, .4)
    elseif skybox_selector.hover then
        lovr.graphics.setColor(.2, .2, .2)
    else
        lovr.graphics.setColor(.1, .1, .1)
    end
    lovr.graphics.plane('fill', skybox_selector.position, skybox_selector.width, skybox_selector.height)

  -- skybox_selector text (add a small amount to the z to put the text slightly in front of skybox_selector)
    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.print(skybox_selector.text, skybox_selector.position + vec3(0, 0, .001), skybox_selector.textSize)
    lovr.graphics.print('Count: ' .. skybox_selector.count, skybox_selector.position + vec3(0, .5, 0), .1)

    draw_thumbnails()
    draw_selected_skybox()
    if skybox then
        lovr.graphics.skybox(skybox)
    end
  -- Pointers
    if #hands < 9 then return end
    for i, idx in ipairs({1, 6}) do
        local position = vec3(unpack(hands[idx], 1, 3))
        local tip = tips[i]

        -- lovr.graphics.setColor(1, 1, 1)
        -- lovr.graphics.sphere(position, .01)

        if skybox_selector.active then
            lovr.graphics.setColor(0, 1, 0)
        else
            lovr.graphics.setColor(1, 0, 0)
        end
        lovr.graphics.line(position, tip)
        lovr.graphics.setColor(1, 1, 1)
    end
end

start_load_thumbnails()
load_thumbnails_ui()
change_skybox({id = 3 })

return skybox_selector