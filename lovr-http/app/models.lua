local gals = {}
local IDLE, TURNLEFT, TURNRIGHT, WALKFOR, WALKBACK = 1,2,3,5,4 -- Get from Model
local anim_index_playing = 1
local anim_walk_dir = 1
local anim_turn_dir = 1
local sTime = lovr.timer.getTime()
local galPosition = {-1, 0, -2}
local galDirection = 0.0
local action_duration = 3.0
local idle_mix = 0.0
local model = {}
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
            normalMap = false,
            indirectLighting = true,
            occlusion = true,
            emissive = true,
            skipTonemap = false,
            animated = true
          }
    })
    shader:send('lovrLightDirection', { 0, 10, 10 })
    shader:send('lovrExposure', 0.25)
    -- shader:send('lovrLightColor', { .9, .9, .8, 1.0 })
    shader:send('lovrEnvironmentMap', skybox)
    for ind = 1, model:getAnimationCount(), 1 do
        print("ANim name  "..model:getAnimationName(ind))
    end
    sTime = lovr.timer.getTime()
    action_duration = model:getAnimationDuration(TURNLEFT) * 2
end

function gals.draw()
    lovr.graphics.skybox(skybox)
    lovr.graphics.setShader(shader)
    -- model:draw(0, 0, -2, .01)
    -- gals.action()  
    local x, y, z = unpack(galPosition)
    model:draw(x, y, z, 1.0, galDirection)
    model:animate(anim_index_playing, lovr.timer.getTime(), 1.0 - idle_mix)
    model:animate(1, lovr.timer.getTime(), idle_mix)
      
    lovr.graphics.setShader()
end

-- function gals.update(dt)
--     -- print("TUrn right duration"..action_duration)
--     if lovr.timer.getAverageDelta() < 0.05 then
--         if lovr.timer.getTime() - sTime > action_duration then
--             -- local action = lovr.math.random(5)
--             local action = 5 -- walk forward
--             action_duration = lovr.math.random(5)
--             if action == WALKBACK then -- back
--                 anim_walk_dir = -1
--             elseif action == WALKFOR then
--                 anim_walk_dir = 1
--             elseif action == TURNLEFT then
--                 anim_turn_dir = 1
--                 action_duration = math.max(0.3, lovr.math.random())
--             elseif action == TURNRIGHT then
--                 anim_turn_dir = -1
--                 action_duration = math.max(0.3, lovr.math.random())
--             end
--             sTime = lovr.timer.getTime()
--             anim_index_playing = action
--         end
--     else
--         sTime = lovr.timer.getTime()
--     end
-- end

-- function gals.action()
--     -- Figure out how to draw correctly when turn animations finish
--     if lovr.timer.getAverageDelta() < 0.05 then
--         if anim_index_playing == IDLE or anim_index_playing == WALKFOR or anim_index_playing == WALKBACK then
--             local quatobj = lovr.math.newQuat()
--             local walkdir = quatobj:set(galDirection, 0,1,0)
--             -- print(walkdir:direction():unpack()) -- This started needing a negation to behave correctly
--             galPosition = vec3(unpack(galPosition)) + -walkdir:direction() *0.3*lovr.timer.getDelta() --0.3m/s
--             local x, y, z = galPosition:unpack()
--             galPosition = {galPosition:unpack()}
--             idle_mix = 0.1
--             model:draw(x, y, z, 1.0, galDirection)
--         elseif anim_index_playing == TURNLEFT then
--             local x, y, z = unpack(galPosition)
--             galDirection = galDirection + (1.57/model:getAnimationDuration(TURNLEFT))*lovr.timer.getDelta()
--             idle_mix = math.pow(1.0 / 1.57 * ((-0.08 + galDirection) % 1.57), 1.0)
--             model:draw(x, y, z, 1.0, galDirection)
--             print("IDLE_MIX "..idle_mix.." "..galDirection)
--         elseif anim_index_playing == TURNRIGHT then
--             local x, y, z = unpack(galPosition)
--             galDirection = galDirection - (1.57/model:getAnimationDuration(TURNLEFT))*lovr.timer.getDelta()
--             model:draw(x, y, z, 1.0, galDirection)
--         end
--         model:animate(anim_index_playing, lovr.timer.getTime(), 1.0 - idle_mix)
--         model:animate(1, lovr.timer.getTime(), idle_mix)
--     end
-- end

-- Mixing makes it better by stretching across the length of the rotation
-- There is still twitching but still good

--Refactor
    -- No need to be separate for LEFT/RIGHT
    -- foundation for scripting

function syncIdleAnim(action)
    idle_mix = 1.0
end

function syncWalkingAnim(action)
    local quatobj = lovr.math.newQuat()
    local walkdir = quatobj:set(galDirection, 0,1,0)
    -- print(walkdir:direction():unpack()) -- This started needing a negation to behave correctly
    galPosition = vec3(unpack(galPosition)) + -walkdir:direction() *0.3*lovr.timer.getDelta() --0.3m/s
    local x, y, z = galPosition:unpack()
    galPosition = {galPosition:unpack()}
    idle_mix = 0.1
end

function syncTurningAnim(action)
    local turnDir = 1
    if action == TURNRIGHT then
        turnDir = -1
    end
    local x, y, z = unpack(galPosition)
    galDirection = galDirection + turnDir*(1.57/model:getAnimationDuration(action))*lovr.timer.getDelta()
    idle_mix = math.pow(1.0 / 1.57 * ((-turnDir*0.08 + galDirection) % 1.57), 1.0)
    -- print("IDLE_MIX "..idle_mix.." "..galDirection)

end


local actionHandling = {
    syncIdleAnim,
    syncTurningAnim,
    syncTurningAnim,
    syncWalkingAnim,
    syncWalkingAnim
}

local actionQ = {WALKFOR, WALKFOR, WALKFOR, TURNRIGHT, WALKFOR, WALKFOR, WALKFOR, TURNLEFT}
table.insert(gals, actionQ)

function gals.update(dt)
    gals.action()    
end

function gals.action()
    if lovr.timer.getAverageDelta() < 0.04 then -- Time for the FPS to become stable
        if #actionQ > 0 then
            if lovr.timer.getTime() - sTime > action_duration then
                anim_index_playing = table.remove(actionQ)
                print("playing "..anim_index_playing)
                action_duration = model:getAnimationDuration(anim_index_playing)
                sTime = lovr.timer.getTime()
            end
            actionHandling[anim_index_playing](anim_index_playing)
        else
            actionHandling[IDLE](IDLE)
        end
    else
        sTime = lovr.timer.getTime()
    end
end

return gals
