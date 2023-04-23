-- Currently while doing vippy
--  Exporting rigged and changed to use blender's default shader
--  models , need to check the tangents box to properly show normal and normal maps
--  for lovr, turn normals to true , set indirect lighting to false
--  and see if sending lovrenvironmentmap to standard shader changes it for better
--  the above three settings need to be more tested.

-- we can use idle_mix or the alpha value in animate call to lock the model in a certain pose

local gals = {}
local IDLE, TURNLEFT, TURNRIGHT, WALKFOR, WALKBACK = 1,2,3,5,4 -- Get from Model
local anim_index_playing = 2
local anim_walk_dir = 1
local anim_turn_dir = 1
local sTime = lovr.timer.getTime()
-- local galPosition = {-1, 0, -2}
local galPosition = {-0.5, 0, -0.5}
local galDirection = 0.0
local action_duration = 3.0
local idle_mix = 0.0
local model = {}
-- Script
    -- Play animation for duration, if duration not specified play it for length of animation

function gals.load()
    skybox = lovr.graphics.newTexture({
        left = 'app/skybox/1/nx.png',
        right = 'app/skybox/1/px.png',
        top = 'app/skybox/1/py.png',
        bottom = 'app/skybox/1/ny.png',
        back = 'app/skybox/1/pz.png',
        front = 'app/skybox/1/nz.png'
      })

    -- model = lovr.graphics.newModel('app/basic.glb')
    model = lovr.graphics.newModel('app/vippyn.glb')
    -- joy_model = lovr.graphics.newModel('app/vippyn.glb')
    shader = lovr.graphics.newShader('standard', {
        flags = {
            normalMap = true,
            indirectLighting = true,
            occlusion = true,
            emissive = true,
            skipTonemap = true,
            animated = true
          }
    })

    joy_shader = lovr.graphics.newShader('standard', {
        flags = {
            normalMap = true,
            indirectLighting = false,
            occlusion = true,
            emissive = false,
            skipTonemap = true,
            animated = true
          }
    })
    -- shader:send('lovrLightDirection', { 0, 10, -10 })
    -- shader:send('lovrExposure', 0.5)
    -- shader:send('lovrLightColor', { .9, .9, .8, 1.0 })
    -- shader:send('lovrEnvironmentMap', skybox)
    
    -- joy_shader:send('lovrLightDirection', { 0, 10, -10 })
    -- joy_shader:send('lovrExposure', 0.1)
    -- joy_shader:send('lovrEnvironmentMap', skybox)

    for ind = 1, model:getAnimationCount(), 1 do
        print("ANim name  "..model:getAnimationName(ind))
    end
    sTime = lovr.timer.getTime()
    action_duration = model:getAnimationDuration(TURNLEFT) * 2
end

function gals.draw()
    lovr.graphics.skybox(skybox)
    -- lovr.graphics.setShader(joy_shader)
    -- joy_model:draw(-0.5, 0, -0.5, 1.0)
-- refreshK
    -- joy_model:animate(2, lovr.timer.getTime())

    lovr.graphics.setShader(shader)
    -- model:draw(0, 0, -2, .01)
    -- gals.action()  
    local x, y, z = unpack(galPosition)
    model:draw(x, y, z, 1.0, galDirection)
    model:animate(anim_index_playing, lovr.timer.getTime(), 1.0)
    -- model:animate(anim_index_playing, lovr.timer.getTime(), 1.0 - idle_mix)
    -- model:animate(1, lovr.timer.getTime(), idle_mix)
    
    lovr.graphics.setShader()
end

function dynamicLightDir()
    local angle, ax, ay, az = lovr.headset.getOrientation('head')
    local dir = lovr.math.newQuat():set(angle, ax, ay, az):direction()*10
    joy_shader:send('lovrLightDirection', { dir:unpack() })


    if counter == nil then
        counter = lovr.timer.getTime()
    elseif lovr.timer.getTime() - counter > 6 then
        print(dir.z)
        counter = lovr.timer.getTime()
    end
end

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
    -- galDirection = galDirection + turnDir*(1.57/model:getAnimationDuration(action))*lovr.timer.getDelta()
    -- idle_mix = math.pow(1.0 / 1.57 * ((-turnDir*0.08 + galDirection) % 1.57), 1.0)
    -- print("IDLE_MIX "..idle_mix.." "..galDirection)
    idle_mix = 0

end


local actionHandling = {
    syncIdleAnim,
    syncTurningAnim,
    syncTurningAnim,
    syncWalkingAnim,
    syncWalkingAnim
}

-- local actionQ = {WALKFOR, WALKFOR, WALKFOR, TURNRIGHT, WALKFOR, WALKFOR, WALKFOR, TURNLEFT}
-- local actionQ = {TURNLEFT, TURNLEFT, TURNLEFT, TURNLEFT, TURNLEFT, TURNLEFT, TURNLEFT}
local actionQ = {}
table.insert(actionQ, lovr.math.random(2, 4))

table.insert(gals, actionQ)

function gals.update(dt)
    gals.action()
end

function gals.action()
    if lovr.timer.getAverageDelta() < 0.04 then -- Time for the FPS to become stable
        if #actionQ > 0 then
            if lovr.timer.getTime() - sTime > action_duration then
                table.insert(actionQ, lovr.math.random(1, 4))
                anim_index_playing = table.remove(actionQ)
                print("playing "..anim_index_playing)
                action_duration = model:getAnimationDuration(anim_index_playing)
                sTime = lovr.timer.getTime()
            end
            -- if lovr.timer.getTime() - sTime + 0.1 > action_duration then
            --     galDirection = galDirection + 1.57
            -- end
            -- actionHandling[anim_index_playing](anim_index_playing)
        else
            actionHandling[IDLE](IDLE)
        end
    else
        sTime = lovr.timer.getTime()
    end
end

return gals
