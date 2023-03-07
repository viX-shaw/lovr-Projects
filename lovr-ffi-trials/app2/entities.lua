-- Point = {}
-- Point.__index = Point

-- function Point:Create(position, prevPosition, posLocked)
--     local this = {
--         pos = position, --vec3(0.0, 0.0, 0.0),
--         prevPos = prevPosition, --vec3(0.0, 0.0, 0.0)
--         locked = posLocked --false
--     }
--     setmetatable(this, Point)
--     return this
-- end

-- Stick = {}
-- Stick.__index = Stick

-- function Stick:Create(ptA, ptB)
--     local this = {
--         pointA = ptA,
--         pointB = ptB,
--         length = vec3(unpack(ptA.pos)):distance(vec3(unpack(ptB.pos)))
--     }
--     setmetatable(this, Stick)
--     return this
-- end

-- return {Point = Point, Stick = Stick}


-- FFI 
local ffi = require("ffi")
ffi.cdef[[
    typedef struct { 
        float ox, oy, oz, nx, ny, nz;
        bool locked;
    } point_t;

    typedef struct {
        point_t *pointA, *pointB;
    } stick_t;

    typedef struct { point_t *a; int length; } points_t;
    typedef struct { stick_t *a; int length; } sticks_t;
]]

local common_mt = {
    __len = function(a) return a.length end,
    __index = function(tbl, idx) return tbl.a[idx] end,
    __newindex = function(tbl, idx, val) tbl.a[idx] = val end,
    __ipairs = function(tbl)
        -- print(" Using ipairs")
        local function stateless_iter(tbl, i)
            -- Implement your own index, value selection logic
            local v = tbl.a[i]
            if nil~=v and i < tbl.length then 
                i = i + 1
                return i, v
            end
        end
        
            -- return iterator function, table, and starting point
        return stateless_iter, tbl, 0
    end
}

local stick_mt = {
    __len = function(a) return vec3(a.pointA.nx, a.pointA.ny, a.pointA.nz):distance(vec3(a.pointB.nx, a.pointB.ny, a.pointB.nz)) end
}

local point = ffi.metatype("points_t", common_mt)
local stick = ffi.metatype("sticks_t", common_mt)

ffi.metatype("stick_t", stick_mt)

alloc_points = ffi.new("point_t[?]", 100)
points = ffi.new("points_t", alloc_points)
points.length = 100

alloc_sticks = ffi.new("stick_t[?]", 180)
sticks = ffi.new("sticks_t", alloc_sticks)
sticks.length = 180

-- TESTS

-- for i, point in ipairs(points) do
--     print(tostring(point))
-- end
-- sticks[0] = sticks[1]
-- points[200] = points[1]
-- sticks[101].pointB = points[1]

-- for idx, v, start in ipairs(points) do
--     print(" "..(idx-1).." "..tostring(v))
-- end

-- for idx, v, start in ipairs(sticks) do
--     print(" "..(idx-1).." "..tostring(v))
-- end

-- print(sticks[0])
-- sticks[0].pointA = points[0]
-- points[0].nx = 2.0
-- print("sticks", sticks[0].pointA.nx)
-- sticks[0].pointA.nx = 3.5
-- print("poimt", points[0].nx)

--TESTS
return {alloc_points, alloc_sticks}
-- return {points, sticks}





