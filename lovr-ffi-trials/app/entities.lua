Point = {}
Point.__index = Point

function Point:Create(position, prevPosition, posLocked)
    local this = {
        pos = position, --vec3(0.0, 0.0, 0.0),
        prevPos = prevPosition, --vec3(0.0, 0.0, 0.0)
        locked = posLocked --false
    }
    setmetatable(this, Point)
    return this
end

Stick = {}
Stick.__index = Stick

function Stick:Create(ptA, ptB)
    local this = {
        pointA = ptA,
        pointB = ptB,
        length = vec3(unpack(ptA.pos)):distance(vec3(unpack(ptB.pos)))
    }
    setmetatable(this, Stick)
    return this
end

return {Point = Point, Stick = Stick}


-- -- FFI 
-- local ffi = require("ffi")
-- ffi.cdef[[
--     typedef struct { 
--         float ox, oy, oz, nx, ny, nz;
--         bool locked;
--     } point_t;

--     typedef struct {
--         point_t pointA, pointB;
--     } stick_t;
-- ]]

-- local stick_mt = {
--     __len = function(a) return vec3(a.point_A.nx, a.point_A.ny, a.point_A.nz):distance(vec3(a.point_B.nx, a.point_B.ny, a.point_B.nz))
-- }


-- local stick = ffi.metatype("stick_t", stick_mt)

-- points = ffi.new("point_t[?]", 100)
-- sticks = stick(100)

-- return points, sticks





