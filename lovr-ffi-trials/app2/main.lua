
ens = require('entities')

local points = ens[1]
local sticks = ens[2]
local n_points = 0
local n_sticks = 0

local nudge = 0.01

lovr.math.setRandomSeed(42)

function shuffle(tbl)
    -- for i = #tbl, 2, -1 do
    for i = 179, 2, -1 do
      local j = lovr.math.random(i)
      if i~=j then
        local tmp_a, tmp_b = tbl[i].pointA, tbl[i].pointB
        local tmp2_a, tmp2_b = tbl[j].pointA, tbl[j].pointB
        
        tbl[i].pointA, tbl[i].pointB = tmp2_a, tmp2_b
        tbl[j].pointA, tbl[j].pointB = tmp_a, tmp_b
      end
    end
    return tbl
  end

function makeCloth(n, rows, cols, stickLength)
    for y = -0.1, -rows*stickLength, -stickLength do
        for x = 0.1, cols*stickLength, stickLength do
            points[n_points].ox = x
            points[n_points].oy = 1.7+y
            points[n_points].oz = -2.0
            points[n_points].nx = x
            points[n_points].ny = 1.7+y
            points[n_points].nz = -2.0
            if y == -0.1 and (math.abs(x - 0.1) < 0.001 or math.abs(x - 1.0) < 0.001 or math.abs(x - 0.4) < 0.001) then
                -- table.insert(points, entity.Point:Create({x, 1.7+y, -2.0}, {x, 1.7+y, -2.0}, true))
                points[n_points].locked = true

            else
                -- table.insert(points, entity.Point:Create({x, 1.7+y, -2.0}, {x, 1.7+y, -2.0}, false))
                points[n_points].locked = false
            end
            n_points = n_points + 1
        end
    end
    
    -- print("TEST "..#points)
    for i = 1, rows, 1 do
        for j = 1, cols, 1 do
            local idx = (i-1) * cols + j
            if j ~= cols and idx < n then
                -- table.insert(sticks, entity.Stick:Create(points[idx], points[idx+1]))
                sticks[n_sticks].pointA = points[idx - 1]
                sticks[n_sticks].pointB = points[idx]
                n_sticks = n_sticks + 1
            end
            local next_idx = i * cols + j
            if next_idx <= n then
                -- table.insert(sticks, entity.Stick:Create(points[idx], points[next_idx]))
                sticks[n_sticks].pointA = points[idx - 1]
                sticks[n_sticks].pointB = points[next_idx - 1]
                n_sticks = n_sticks + 1
            end
        end
        -- print("IDX "..n_sticks)
    end
end

function lovr.load()
-- pass
    -- world = lovr.physics.newWorld()
    -- world:setLinearDamping(.01)
    -- world:setAngularDamping(.005)
    startime = lovr.timer.getTime()
    -- Points
    -- points = {}
    -- Sticks - made of points
    -- sticks = {}
    -- test = entity.Point:Create({0, 1.7, -2.0}, {0, 1.7, -2.0}, true)
    n = 100
    cols = 10
    rows = math.ceil(n/cols)
    stickLength = 0.1
    makeCloth(n, rows, cols, stickLength)
    -- Shuffle to remove jittering
end

function simulate(delta)
    -- for idx, point in ipairs(points) do
    for idx=0, 99, 1 do
        local point = points[idx]
        if point.locked == false then
            -- local posBeforeUpdate = point.pos
            -- point.pos = {(vec3(unpack(point.pos)) + vec3(unpack(point.pos)) - vec3(unpack(point.prevPos))):unpack()}
            -- point.pos = {(vec3(unpack(point.pos)) + vec3(0.0, -1.0, 0.0) *9.8 * delta * delta):unpack()}
            -- point.prevPos = posBeforeUpdate 

            local px, py, pz = point.nx, point.ny, point.nz
            local new_p = vec3(point.nx, point.ny, point.nz)
            new_p = new_p *2 - vec3(point.ox, point.oy, point.oz)
            -- point.nx = point.nx + point.nx - point.ox
            -- point.ny = point.ny + point.ny - point.oy
            -- point.nz = point.nz + point.nz - point.oz
            point.nx, point.ny, point.nz = new_p.x, new_p.y, new_p.z
            point.ny = point.ny + 9.8 * delta * delta * -1.0

            point.ox = px
            point.oy = py
            point.oz = pz


        end
    end

    -- print(points[50].nx, points[50].ny, points[50].nz, points[50].ox, points[50].oy, points[50].oz)
    numIterations = 5
    for y = 0, numIterations, 1 do
        -- for i, stick in ipairs(sticks) do
        for i=0, 179, 1 do
            local stick = sticks[i]
            -- local pA = vec3(unpack(stick.pointA.pos))
            -- local pB = vec3(unpack(stick.pointB.pos))
            -- local stickCentre = (pA + pB) / 2
            -- local stickDir = (pA - pB):normalize()
            -- local length = pA:distance(pB)
            local pA = vec3(stick.pointA.nx, stick.pointA.ny, stick.pointA.nz)            
            local pB = vec3(stick.pointB.nx, stick.pointB.ny, stick.pointB.nz)
            local stickCentre = (pA + pB) / 2
            local stickDir = (pA - pB):normalize()
            -- local stick_l = pA:distance(pB)
            -- print(stick_l)
            local diff = (stickDir * 0.05)
            
            -- if length - stick.length > 0.001 then
            if stick.pointA.locked == false then
                -- stick.pointA.pos = {(stickCentre + stickDir * #stick / 2):unpack()}
                -- local res = stickCentre + stickDir * stick_l / 2
                local x, y, z = (stickCentre + diff):unpack() 
                stick.pointA.nx = x
                stick.pointA.ny = y
                stick.pointA.nz = z
            end
            if stick.pointB.locked == false then
                -- stick.pointB.pos = {(stickCentre - stickDir * #stick / 2):unpack()}
                local x, y, z = (stickCentre - diff):unpack() 
                stick.pointB.nx = x
                stick.pointB.ny = y
                stick.pointB.nz = z
            end
            -- end
        end
        -- lovr.math.drain()
    end
end


function lovr.draw()
-- pass
    lovr.graphics.setColor(1,1,1)
    -- for _, point in ipairs(points) do
    for i=0, 99, 1 do
        local point = points[i]
        -- local pos = point.pos
        -- lovr.graphics.sphere(pos[1], pos[2], pos[3], 0.02)
        lovr.graphics.sphere(point.nx, point.ny, point.nz, 0.02)
    end

    -- for _, stick in ipairs(sticks) do
    for i=0, 179, 1 do
        local stick = sticks[i]
        -- local pos1 = stick.pointA.pos
        -- local pos2 = stick.pointB.pos
        local pos1 = stick.pointA
        local pos2 = stick.pointB

        lovr.graphics.line(pos1.nx, pos1.ny, pos1.nz, pos2.nx, pos2.ny, pos2.nz)
    end
end

function lovr.update(dt)
-- pass
    simulate(dt)
    if points[1].locked and lovr.timer.getTime() - startime > 8 then
        points[1].locked = false
    end

    if lovr.timer.getTime() - startime > 4 then
        -- nudge = 0.0
        -- shuffle(sticks)

        print("FPS "..lovr.timer.getFPS())
        startime = lovr.timer.getTime()
    end
end
