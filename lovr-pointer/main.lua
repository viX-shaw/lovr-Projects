local function raycast(rayPos, rayDir, planePos, planeDir)
    local dot = rayDir:dot(planeDir)
    if (dot < 0.001) then
        return nil
    else
        local distance = (planePos - rayPos):dot(planeDir) / dot
        if (distance > 0) then
            return rayPos + distance * rayDir
        else
            return nil
        end
    end
end

local button = {
    text = "Please click me!!",
    textSize = .1,
    count = 0,
    width = 1.0,
    height = 0.4,
    hover = false,
    active = false,
    position = lovr.math.newVec3(0,1,-3)
}

local tips = {}

function lovr.update()
    button.hover, button.active = false, false

    for i, hand in ipairs(lovr.headset.getHands()) do
        tips[hand] = tips[hand] or lovr.math.newVec3()

        -- Ray info:
        local rayPosition = vec3(lovr.headset.getPosition(hand))
        local rayDirection = vec3(quat(lovr.headset.getOrientation(hand)):direction())

        -- Call the raycast helper to get the position of the beam on the button plane
        local hit = raycast(rayPosition, rayDirection, button.position, vec3(0,0,1))

        local inside = false
        if hit then
            local bx, by, bw, bh = button.position.x, button.position.y, button.width / 2, button.height / 2
            inside = (hit.x > bx - bw) and (hit.x < bx + bw) and (hit.y > by - bh) and (hit.y < by + bh)
        end

        -- If the ray intersects, mark the button as active if
        -- the bounds of the hit is within the button
        if inside then
            if lovr.headset.isDown(hand, 'trigger') then
                button.active = true
            else
                button.hover = true
            end

            if lovr.headset.wasReleased(hand, 'trigger') then
                button.count = button.count + 1
                print('BOOP')
            end
        end

        -- Set the end position the pointer based on the hit,
        -- otherwise extend the pointers ray outward by 50 meters
        tips[hand]:set(inside and hit or (rayPosition + rayDirection * 50))
end

function lovr.draw()
    -- Button backGround
    if button.active then
        lovr.graphics.setColor(.4,.4,.4)
    elseif button.hover then
        lovr.graphics.setColor(.2,.2,.2)
    else
        lovr.graphics.setColor(.1,.1,.1)
    lovr.graphics.plane('fill', button.position, button.width, button.height)

    -- Button text, show in front of background (i.e. add little to z)
    lovr.graphics.setColor(1,1,1)
    lovr.graphics.print(button.text, button.position + vec3(0,0.001), button.textSize)
    lovr.graphics.print('Count:' .. button.count. button.position + vec3(0,.5,0), .1)

    -- Pointers
    for hand, tip in pairs(tips) do
        local position = vec3(lovr.headset.getPosition(hand))

        lovr.graphics.setColor(1,1,1)
        lovr.graphics.sphere(position, .01)

        if button.active then
            lovr.graphics.setColor(0,1,0)
        else
            lovr.graphics.setColor(1,0,0)
        end
        lovr.graphics.line(position, trip)
        lovr.graphics.setColor(1,1,1)
    end
end