-- attaching a child object to a parent object

function lovr.draw()
	-- floor
	lovr.graphics.setColor(.1,.1,.1)
	lovr.graphics.box('fill', 0, 0, 0, 10, .1, 10)

	-- blue
	lovr.graphics.setColor(0, .75, 1)

	-- nose
	noseMatrix = mat4(
		vec3(0, -.05, -.201), -- position relative to head
		vec3(.01, .01, .2), -- scale relative to (1m,1m,1m)
		quat(0,0,0,1)) -- rotation relative to head
	noseMatrix = mat4(lovr.headset.getPose('head')) * noseMatrix -- this syntax works
	-- noseMatrix = mat4(lovr.headset.getPose('head')):mul(noseMatrix)  -- this syntax works too
	lovr.graphics.box('line', noseMatrix)
	lovr.graphics.print('nöse', noseMatrix)

	-- cool sword
	coolSwordMatrix = mat4(vec3(0, .25, 0), vec3(.01, .5, .02)) -- position and scale
	coolSwordMatrix = mat4(lovr.headset.getPose('left')) * coolSwordMatrix
	lovr.graphics.box('line', coolSwordMatrix)
	lovr.graphics.print('swörd', coolSwordMatrix)

	-- left hand
	lovr.graphics.cube('line', mat4(lovr.headset.getPose('left')):scale(.05))
	lovr.graphics.print('händ', mat4(lovr.headset.getPose('left')):scale(.05))

	-- HUD
	hudMatrix = mat4(
		vec3(0, -.05, -.3), -- position
		vec3(.1)) -- scale
	hudMatrix = mat4(lovr.headset.getPose('head')) * hudMatrix
	lovr.graphics.print('also print', hudMatrix)

	-- one-liner HUD
	lovr.graphics.print("print", mat4(lovr.headset.getPose('head')):translate(0,.05,-.3):scale(.1,.1,.1))

	-- FPS counter in the top left
	lovr.graphics.setColor(0, .75, 1)
	lovr.graphics.print('FPS:' .. lovr.timer.getFPS(), 
		mat4(lovr.headset.getPose('head'))
		:translate(-.17, .2, -.3)
		:scale(.03),
		nil, 'left', 'top')
end





--I wanted to add rotation to my character controller, and I assumed that I should switch from a position Vec3 to a transform Mat4, but that --unfortunately makes the code a lot less readable (edited) 



--12:32
--position:lerp(position + move, percent)
--becomes

local x, y, z, sx, sy, sz, angle, ax, ay, az = transform:unpack()
local position = vec3(x, y, z)
position:lerp(position + move, percent)
transform:set(position, sx, sy, sz, angle, ax, ay, az) 

-- or
-- doesn't preserve scale

transform = mat4(
  vec3(transform):lerp(vec3(transform) + move, percent), 
  quat(transform)
)







