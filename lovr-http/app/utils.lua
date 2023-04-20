local function raycast(rayPos, rayDir, planePos, planeDir)
    local dot = rayDir:dot(planeDir)
    if math.abs(dot) < .001 then
        return nil
    else
        local distance = (planePos - rayPos):dot(planeDir) / dot
        if distance > 0 then
            return rayPos + rayDir * distance
        else
            return nil
        end
    end
end

function checkPinch(pX, pY, pZ, qX, qY, qZ, threshold)
    if math.abs(qX-pX)+math.abs(qY-pY)+math.abs(qZ-pZ) < threshold then
      return true
    else
      return false
    end
end