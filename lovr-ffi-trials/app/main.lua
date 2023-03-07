
local entity = require('entities')
lovr.math.setRandomSeed(42)

function shuffle(tbl)
    for i = #tbl, 2, -1 do
      local j = lovr.math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
  end

function makeCloth(n, rows, cols, points, sticks, stickLength)
    for y = -0.1, -rows*stickLength, -stickLength do
        for x = 0.1, cols*stickLength, stickLength do
            if y == -0.1 and (math.abs(x - 0.1) < 0.001 or math.abs(x - 1.0) < 0.001 or math.abs(x - 0.4) < 0.001) then
                table.insert(points, entity.Point:Create({x, 1.7+y, -2.0}, {x, 1.7+y, -2.0}, true))
            else
                table.insert(points, entity.Point:Create({x, 1.7+y, -2.0}, {x, 1.7+y, -2.0}, false))
            end
        end
    end
    
    print("TEST "..#points)
    for i = 1, rows, 1 do
        for j = 1, cols, 1 do
            local idx = (i-1) * cols + j
            if j ~= cols and idx < n then
                table.insert(sticks, entity.Stick:Create(points[idx], points[idx+1]))
            end
            local next_idx = i * cols + j
            if next_idx <= n then
                table.insert(sticks, entity.Stick:Create(points[idx], points[next_idx]))
            end
            -- print("IDX "..idx)
        end
    end
end

function lovr.load()
-- pass
    -- world = lovr.physics.newWorld()
    -- world:setLinearDamping(.01)
    -- world:setAngularDamping(.005)
    startime = lovr.timer.getTime()
    -- Points
    points = {}
    -- Sticks - made of points
    sticks = {}
    test = entity.Point:Create({0, 1.7, -2.0}, {0, 1.7, -2.0}, true)
    n = 100
    cols = 10
    rows = math.ceil(n/cols)
    stickLength = 0.1
    makeCloth(n, rows, cols, points, sticks, stickLength)
    -- Shuffle to remove jittering
    -- sticks = shuffle(sticks)
end

function simulate(delta)
    for i, point in ipairs(points) do
        if point.locked == false then
            local posBeforeUpdate = point.pos
            point.pos = {(vec3(unpack(point.pos)) + vec3(unpack(point.pos)) - vec3(unpack(point.prevPos))):unpack()}
            point.pos = {(vec3(unpack(point.pos)) + vec3(0.0, -1.0, 0.0) *9.8 * delta * delta):unpack()}
            point.prevPos = posBeforeUpdate 
        end
    end

    numIterations = 5
    for y = 0, numIterations, 1 do
        for i, stick in ipairs(sticks) do
            -- local rand = y
            -- local randidx = i + y - math.floor((i+y)/#sticks) * #sticks + 1
            -- local randidx = (#sticks+y - math.floor((#sticks+y)/#sticks) * #sticks) + 1
            -- print("RAND"..randidx)
            -- stick = sticks[randidx]
            local pA = vec3(unpack(stick.pointA.pos))
            local pB = vec3(unpack(stick.pointB.pos))
            local stickCentre = (pA + pB) / 2
            local stickDir = (pA - pB):normalize()
            local length = pA:distance(pB)

            -- if length - stick.length > 0.001 then
                if stick.pointA.locked == false then
                    stick.pointA.pos = {(stickCentre + stickDir * stick.length / 2):unpack()}
                end
                if stick.pointB.locked == false then
                    stick.pointB.pos = {(stickCentre - stickDir * stick.length / 2):unpack()}
                end
            -- end
        end
        -- lovr.math.drain()
    end
end


function lovr.draw()
-- pass
    lovr.graphics.setColor(1,1,1)
    for _, point in ipairs(points) do
        local pos = point.pos
        lovr.graphics.sphere(pos[1], pos[2], pos[3], 0.02)
    end

    for _, stick in ipairs(sticks) do
        local pos1 = stick.pointA.pos
        local pos2 = stick.pointB.pos
        -- print("POs1")
        -- print(pos1[1])
        -- print("POs2")
        -- print(pos2[1])

        lovr.graphics.line(pos1[1], pos1[2], pos1[3], pos2[1], pos2[2], pos2[3])
    end
end

function lovr.update(dt)
-- pass
    simulate(dt)
    if points[1].locked and lovr.timer.getTime() - startime > 8 then
        points[1].locked = false
    end

    if lovr.timer.getTime() - startime > 8 then
        print("FPS "..lovr.timer.getFPS())
        startime = lovr.timer.getTime()
    end
end
