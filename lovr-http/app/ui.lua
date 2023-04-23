require 'app/utils'

local skybox_selector = {
    text = 'Choose Skybox',
    textSize = .1,
    count = 0,
    position = lovr.math.newVec3(-2, 2, -3),
    width = 1.0,
    height = .4,
    hover = false,
    active = false,
    prev_frame_active = false,
    direction = lovr.math.newVec3(0, 0, 1)
}

local tips = {}
local pinch_released = {false, false} -- left and right hand pinch {1,3} {5,7}
local thumbnails = {}
local skybox = nil
local temp_skybox = nil
local thumbnails_ui = {}
local show_skybox_thumbnails = false
local nThumbnailsShown = 3
local active_thumbnail_index = 0
local maxThumbnails = 9
local thumbnails_window_start = 0
local thumbnails_window_end = 0
local lastThumbnailAction = nil
local skybox_fade_in = false
local old_skybox_fade_in_complete = false
local fade_in_start_time = 0
local pointer_action_relax_time = lovr.timer.getTime()

function load_thumbnails_ui()
    for i = -1,3 do
        text = i
        if i == -1 then text = 'prev' elseif i == 3 then text = 'next' end
        table.insert(thumbnails_ui, {
            id = i,
            text = text,
            position = lovr.math.newVec3(-2, 1, -0.4 *i),
            width = 0.3,
            height = 0.3,
            hover = false,
            active = false,
            prev_frame_active = false,
            direction = lovr.math.newVec3(1, 0, 0)
        })
    end
    print("THUMBNAIL UIs "..#thumbnails_ui)
end

function start_load_thumbnails(n)
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
    load_thumbnails_thread:start(channelName, nil, active_thumbnail_index + element.id)
end

function do_something(element)
    if element.text == 'Choose Skybox' then
        show_skybox_thumbnails = not show_skybox_thumbnails
        if show_skybox_thumbnails then --When first loading or when switching it back on
            print('show skybox')
            if #thumbnails <= active_thumbnail_index then -- if already loaded then skip
                print('start load')
                start_load_thumbnails(active_thumbnail_index)
            end
            -- active_thumbnail_index = active_thumbnail_index + nThumbnailsShown
        end
    elseif element.text == 'prev' then
        if show_skybox_thumbnails then
            if active_thumbnail_index > thumbnails_window_start and 
            active_thumbnail_index < thumbnails_window_end then -- this is wrong
                active_thumbnail_index = active_thumbnail_index - nThumbnailsShown
            else
                start_load_thumbnails(active_thumbnail_index)
            end
            lastThumbnailAction = 'prev'
        end
    elseif element.text == 'next' then
        if show_skybox_thumbnails then
            if active_thumbnail_index > thumbnails_window_start and 
            active_thumbnail_index < thumbnails_window_end then
                active_thumbnail_index = active_thumbnail_index + nThumbnailsShown
            else
                start_load_thumbnails(active_thumbnail_index)
            end
            lastThumbnailAction = 'next'
        end
    else
        change_skybox(element)
    end
end

function check_hit(hit, element)
    element.prev_frame_active = element.active
    element.hover , element.active = false, false
    local inside = false
    if hit then
        local bx, by, bw, bh = element.position.x, element.position.y, element.width / 2, element.height / 2
        -- This hit check is only correct for panels facing +z and -z, need to generalize for any direction
        inside = (hit.x > bx - bw) and (hit.x < bx + bw) and (hit.y > by - bh) and (hit.y < by + bh)
        return inside, element
    end
end

function check_pinch_on_element(i, element, pX, pY, pZ, qX, qY, qZ, threshold)
    -- element.prev_frame_active = element.active
    -- element.hover , element.active = false, false
    element.hover = true
    if checkPinch(pX, pY, pZ, qX, qY, qZ, threshold) then  
        element.active = true
    else
        if element.prev_frame_active then
            pinch_released[i] = true
        end
    end
end

function skybox_selector.update(hands, dt)
    if #hands < 9 then return end
    -- skybox_selector.prev_frame_active = skybox_selector.active
    -- skybox_selector.hover , skybox_selector.active = false, false
    pinch_released = {false, false}

    -- for i, pinch in ipairs({{1, 3}, {6, 8}}) do -- finger indexes from lovr.headset.getSkeleton
    for i, pinch in ipairs({{2, 7}}) do -- finger indexes from lovr.headset.getSkeleton
        tips[i] = tips[i] or lovr.math.newVec3()

        local rayPosition = vec3(unpack(hands[pinch[2]], 1, 3))
        local rayDirection = vec3(quat(unpack(hands[pinch[2]], 4, 7)):direction())
        local inside, hit, element = nil, nil, nil
        for idx, entry in ipairs({skybox_selector, unpack(thumbnails_ui)}) do        
            hit = raycast(rayPosition, rayDirection, entry.position, entry.direction)
            inside, element = check_hit(hit, entry)
            if inside then break end
        end

        -- local inside = false
        -- if hit then
        --     local bx, by, bw, bh = skybox_selector.position.x, skybox_selector.position.y, skybox_selector.width / 2, skybox_selector.height / 2
        --     inside = (hit.x > bx - bw) and (hit.x < bx + bw) and (hit.y > by - bh) and (hit.y < by + bh)
        -- end

        if inside then
            local pX, pY, pZ = rayPosition:unpack()
            local qX, qY, qZ = unpack(hands[pinch[1]], 1, 3)
            -- if checkPinch(rayPosition:unpack(), unpack(hands[pinch[2]], 1, 3), 0.013) then
            check_pinch_on_element(i, element, pX, pY, pZ, qX, qY, qZ, 0.033)
            -- if checkPinch(pX, pY, pZ, qX, qY, qZ, 0.033) then  
            --     skybox_selector.active = true
            -- else
            --     skybox_selector.hover = true
            --     if skybox_selector.prev_frame_active then
            --         pinch_released[i] = true
            --     end
            -- end
      
            if (lovr.timer.getTime() - pointer_action_relax_time) > 0.5 and (pinch_released[1] or pinch_released[2]) then
            --   skybox_selector.count = skybox_selector.count + 1
                pointer_action_relax_time = lovr.timer.getTime()
                do_something(element)
                print('BOOP '..element.text)
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
    if s > 0.999 then -- debugging code
        change_skybox({id = lovr.math.random(1, 3) })
        do_something({text = 'next'})
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
    else -- debugging code
        transition_to_new_skybox()
    end
end

function draw_thumbnails()
    local channel = lovr.thread.getChannel('load-thumbnails')
    local _, present = channel:peek()
    if present then
        local img = lovr.graphics.newTexture(channel:pop())
        print("IMG  "..img:getHeight())
        adjust_thumbnail_window_limits()
        table.insert(thumbnails, img)
        _:release()
    end
    for i, element in ipairs(thumbnails_ui) do
        if i == 1 or i == #thumbnails_ui then
            lovr.graphics.setColor(.4, .2, .4)
            if element.hover then
                lovr.graphics.setColor(.4, .2, .1)
            end
            lovr.graphics.plane('fill', element.position, element.width, element.height, 1.57, 0,1,0)
            lovr.graphics.setColor(1, 1, 1)
            lovr.graphics.print(element.text, element.position + vec3(0,0,.001), skybox_selector.textSize, 1.57, 0,1,0)
        else
            if element.hover then
                lovr.graphics.setColor(0.6, 0.6, 0.6)
            end
            -- local idx = thumbnails_window_end - active_thumbnail_index + element.id + 1
            -- if thumbnails_window_end > nThumbnailsShown then idx = idx + nThumbnailsShown
            local idx = #thumbnails - nThumbnailsShown + element.id + 1
            idx = idx - (thumbnails_window_end - active_thumbnail_index)
            -- print(" IDX "..idx.." n = "..#thumbnails)
            if idx > 0 and idx <= #thumbnails then
                lovr.graphics.plane(lovr.graphics.newMaterial(thumbnails[idx]), element.position, element.width, element.height, 1.57, 0,1,0)
            end
            lovr.graphics.setColor(1,1,1)
        end
    end
end

function adjust_thumbnail_window_limits()
    if #thumbnails == maxThumbnails then
        if lastThumbnailAction == 'prev' then
            table.remove(thumbnails)
            if thumbnails_window_start > 0 then
                thumbnails_window_start = thumbnails_window_start - 1
            end
            thumbnails_window_end = thumbnails_window_end - 1
        else
            table.remove(thumbnails, 1)
            thumbnails_window_start = thumbnails_window_start + 1
            if thumbnails_window_end < 24 then
                thumbnails_window_end = thumbnails_window_end + 1
            end
        end
    else
        thumbnails_window_end = thumbnails_window_end + 1
    end

    if lastThumbnailAction == 'prev' then
        if active_thumbnail_index > 0 then
            active_thumbnail_index = active_thumbnail_index - 1
        end
    else
        if active_thumbnail_index < 24 then
            active_thumbnail_index = active_thumbnail_index + 1
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
    -- for i, idx in ipairs({1, 6}) do
    for i, idx in ipairs({7}) do
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

-- do_something({text = 'Choose Skybox'})
load_thumbnails_ui()
-- change_skybox({id = 3 })

return skybox_selector