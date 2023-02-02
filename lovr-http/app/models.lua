local gals = {}
local IDLE, TURNLEFT, TURNRIGHT, WALKFOR, WALKBACK = 1,2,3,4,5 -- Get from Model
local anim_index_playing = 2
local anim_walk_dir = 1
local anim_turn_dir = 1
local sTime = lovr.timer.getTime()
local galPosition = {-1, 0, -2}
local galDirection = 0.0
local action_duration = 0.0
local idle_mix = 0.0
-- Script
    -- Play animation for duration, if duration not specified play it for length of animation

function gals.load()
    skybox = lovr.graphics.newTexture({
        left = 'app/skybox/2/nx.png',
        right = 'app/skybox/2/px.png',
        top = 'app/skybox/2/py.png',
        bottom = 'app/skybox/2/ny.png',
        back = 'app/skybox/2/pz.png',
        front = 'app/skybox/2/nz.png'
      })
    -- skybox = lovr.graphics.newTexture('app/sky-15.jpg', {type = 'cube'})
    model = lovr.graphics.newModel('app/basic.glb')
    shader = lovr.graphics.newShader('standard', {
        flags = {
            normalMap = true,
            indirectLighting = true,
            occlusion = true,
            emissive = true,
            skipTonemap = false,
            animated = true
          }
    })
    shader:send('lovrLightDirection', { 0, 1, 1 })
    shader:send('lovrLightColor', { .9, .9, .8, 1.0 })
    shader:send('lovrEnvironmentMap', skybox)
    for ind = 1, model:getAnimationCount(), 1 do
        print("ANim name  "..model:getAnimationName(ind))
    end
    sTime = lovr.timer.getTime()
    action_duration = model:getAnimationDuration(TURNLEFT) * 8
end

function gals.draw()
    lovr.graphics.skybox(skybox)
    lovr.graphics.setShader(shader)
    -- model:draw(0, 0, -2, .01)
    gals.action()    
    lovr.graphics.setShader()
end

function gals.update(dt)
    -- print("TUrn right duration"..action_duration)
    if lovr.timer.getAverageDelta() < 0.05 then
        if lovr.timer.getTime() - sTime > action_duration then
            -- local action = lovr.math.random(5)
            local action = 5 -- walk forward
            action_duration = lovr.math.random(5)
            if action == WALKBACK then -- back
                anim_walk_dir = -1
            elseif action == WALKFOR then
                anim_walk_dir = 1
            elseif action == TURNLEFT then
                anim_turn_dir = 1
                action_duration = math.max(0.3, lovr.math.random())
            elseif action == TURNRIGHT then
                anim_turn_dir = -1
                action_duration = math.max(0.3, lovr.math.random())
            end
            sTime = lovr.timer.getTime()
            anim_index_playing = action
        end
    else
        sTime = lovr.timer.getTime()
    end
end

function gals.action()
    -- Figure out how to draw correctly when turn animations finish
    if lovr.timer.getAverageDelta() < 0.05 then
        if anim_index_playing == IDLE or anim_index_playing == WALKFOR or anim_index_playing == WALKBACK then
            local quatobj = lovr.math.newQuat()
            local walkdir = quatobj:set(galDirection, 0,1,0)
            -- print(walkdir:direction():unpack()) -- This started needing a negation to behave correctly
            galPosition = vec3(unpack(galPosition)) + -walkdir:direction() *0.3*lovr.timer.getDelta() --0.3m/s
            local x, y, z = galPosition:unpack()
            galPosition = {galPosition:unpack()}
            idle_mix = 0.1
            model:draw(x, y, z, 1.0, galDirection)
        elseif anim_index_playing == TURNLEFT then
            local x, y, z = unpack(galPosition)
            galDirection = galDirection + (1.57/model:getAnimationDuration(TURNLEFT))*lovr.timer.getDelta()
            idle_mix = math.pow(1.0 / 1.57 * (galDirection % 1.57), 1.0)
            model:draw(x, y, z, 1.0, galDirection)
            print("IDLE_MIX "..idle_mix.." "..galDirection)
        elseif anim_index_playing == TURNRIGHT then
            local x, y, z = unpack(galPosition)
            galDirection = galDirection - (1.57/model:getAnimationDuration(TURNLEFT))*lovr.timer.getDelta()
            model:draw(x, y, z, 1.0, galDirection)
        end
        model:animate(anim_index_playing, lovr.timer.getTime(), 1.0 - idle_mix)
        model:animate(1, lovr.timer.getTime(), idle_mix)
    end
end

return gals


-- Mixing makes it better by stretching across the length of the rotation
-- There is still twitching but still good

--Refactor
    -- No need to be separate for LEFT/RIGHT
    -- foundation for scripting