local hands = {}
local loco = {
  pose = lovr.math.newMat4(),
  turnLeft = false,
  turnRight = false,
  moveForward = false,
  turningSpeed = 2 * math.pi * 1 / 6,
  walkingSpeed = 2
}


function checkPinch(pX, pY, pZ, qX, qY, qZ, threshold)
  if math.abs(qX-pX)+math.abs(qY-pY)+math.abs(qZ-pZ) < threshold then
    return true
  else
    return false
  end
end

function checkEvents()
  if #hands > 9 then
    local x1, y1, z1 = unpack(hands[6], 1, 3) --:getPosition() -- right thumb tip
    local x2, y2, z2 = unpack(hands[7], 1, 3) --:getPosition() -- right index tip
    local x3, y3, z3 = unpack(hands[1], 1, 3) --:getPosition() -- left thumb tip
    local x4, y4, z4 = unpack(hands[5], 1, 3) --:getPosition() -- left pinky tip
    local x5, y5, z5 = unpack(hands[2], 1, 3) --:getPosition() -- left index tip

    local leftPinch = checkPinch(x3,y3,z3,x5,y5,z5,0.033)
    local rightPinch = checkPinch(x1,y1,z1,x2,y2,z2,0.033)

    loco.moveForward = false
    loco.turnLeft = false
    loco.turnRight = false

    -- When both pinched move Forward, 
    if leftPinch then
      loco.turnLeft = true
      if rightPinch then
        loco.moveForward = true
        loco.turnLeft = false
        loco.turnRight = false
      end
    elseif rightPinch then
      loco.turnRight = true
    end
  end
end

function updateFingertips()
  count = 1
  for _, hand in ipairs({'left', 'right'}) do
    for idx, joint in ipairs(lovr.headset.getSkeleton(hand) or {}) do
      if joint ~= nil and idx == 6 or idx == 11 or idx == 16 or idx == 21 or idx == 26 then
        hands[count] = joint
        count = count + 1
      end
    end
  end
end

function loco.update(dt)
  updateFingertips()
  checkEvents()

  local direction = quat(lovr.headset.getOrientation('head')):direction()

  if loco.moveForward then
    -- move forward
    loco.pose:translate(direction * loco.walkingSpeed * dt)
  elseif loco.turnLeft then
    -- turn left
    loco.pose:rotate(loco.turningSpeed * dt, 0, 1, 0)
  elseif loco.turnRight then
    -- turn right
    loco.pose:rotate(-loco.turningSpeed * dt, 0, 1, 0)
  end
end

function loco.draw()
  lovr.graphics.transform(mat4(loco.pose):invert())
  -- Draw fingertips
  for i = 1, #hands do
    -- local x,y,z = unpack(hands[i],1,3)
    -- lovr.graphics.sphere(x,y,z, 0.01)sdfsdf
    local poseRW = mat4(unpack(hands[i]))
    local poseVR = mat4(loco.pose):mul(poseRW)
    poseVR:scale(0.01)
    lovr.graphics.sphere(poseVR)
  end
end

return {loco, hands}