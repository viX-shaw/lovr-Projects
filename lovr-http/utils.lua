local filesState = 0
local sTime = lovr.timer.getTime()

function reloadIfChanged(msg)
    -- print("Reload try")
    if lovr.timer.getTime() - sTime > 1.0 then
        sTime = lovr.timer.getTime()
        newFileState = loadSourceInfo()
        if newFileState ~= filesState then
            filesState = newFileState
            if msg then
                return "restart"
            end
            lovr.event.restart()
        end

    end
end

function loadSourceInfo()
    bytesInfoAllSourceFiles = 0
    for idx, en in ipairs({"main.lua", "NOTES", "stream.lua", "play.lua", "utils.lua"}) do
        if lovr.filesystem.isFile(en) then
            contents, _ = lovr.filesystem.read(en)
            bytesInfoAllSourceFiles = bytesInfoAllSourceFiles + #contents
        end
    end
    return bytesInfoAllSourceFiles
end

filesState = loadSourceInfo()