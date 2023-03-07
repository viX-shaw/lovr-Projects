terrainScene = require('terrain')
local basicLoco = require('locomotion')
local ocean, shader

local shaderCode = {lovr.filesystem.read("vertexshader.vs"), lovr.filesystem.read("fragementshader.fs")}

local function grid(subdivisions)
  local size = 1 / math.floor(subdivisions or 1)
  local vertices = {}
  local indices  = {}
  for y = -1, 1, size do
    for x = -1, 1, size do
      table.insert(vertices, {x, y, 0, 1,-1,-1})
      table.insert(vertices, {x, y + size, 0, 1,-1,-1})
      table.insert(vertices, {x + size, y, 0, 1,-1,-1})
      table.insert(vertices, {x + size, y + size, 0, 1,-1,-1})
      table.insert(indices, #vertices - 3)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices - 1)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices)
      table.insert(indices, #vertices - 1)
    end
  end
  local meshFormat = {{'lovrPosition', 'float', 3},{ 'lovrNormal', 'float', 3 }}
  local mesh = lovr.graphics.newMesh(meshFormat, vertices, "triangles", "dynamic", true)
  mesh:setVertexMap(indices)
  return mesh
end

function lovr.load()
  print(lovr.headset.getDriver())
  local skyColor = {0.208, 0.208, 0.275}
  lovr.graphics.setBackgroundColor(skyColor)
  -- lovr.graphics.setBlendMode()
  lovr.graphics.setLineWidth(5)
  lovr.graphics.setAlphaSampling(true)

  shader = lovr.graphics.newShader(unpack(shaderCode))
  shader:send('fogColor', { lovr.math.gammaToLinear(unpack(skyColor)) })
  shader:send('ambience', { 0.12, 0.28, 0.15, 1.0 })
  -- shader:send('ambience', { 0.95, 0.3, 0.0, 1.0 })
  shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
  -- shader:send('lightPos', {-30.0, -2.0, 50})
  shader:send('lightPos', {0.0, -105.0, 105.0})
  shader:send('specularStrength', 1.0)
  shader:send('metallic', 10.0)
  shader:send('viewPos', {0.0, 0.0, 0.0})
  shader:send('viewPoss', {0.0, 0.0, 0.0})

  shader:send('wvlength', 0.1)
  shader:send('wvSteep', 0.1)
  ocean_insts = 1
  shader:send('ocean_insts', math.floor(math.sqrt(ocean_insts)))
  ocean = grid(100)
  -- shader:send('material', lovr.graphics.newTexture('water-surface-2.jpg'))
  skybox = lovr.graphics.newTexture(
    "OBJ/tuni3.jpg",
    { mipmaps = false })
  -- shader:send('material', skybox)
    
  envMap = lovr.graphics.newTexture("OBJ/tuni3.jpg", {mipmaps=false})
  nMap = lovr.graphics.newTexture("wave.png")
  terrainScene.load()
  shader:send('lovrEnvTexture', envMap)
  shader:send('nMap', nMap)


  -- Models
  hm_model = lovr.graphics.newModel('OBJ/casc_anim.glb')
  -- hm_model = lovr.graphics.newModel('OBJ/F23.glb')
  hm_shader = lovr.graphics.newShader('standard', {flags={animated=true}})
  hm_shader:send('lovrExposure', 2)
  hm_shader:send('lovrEnvironmentMap', skybox)
  -- local animCounts = 
  for i = 1, hm_model:getAnimationCount() do
  print(hm_model:getAnimationCount())
  print(hm_model:getAnimationName(1), hm_model:getAnimationDuration(1))
  end
    -- water_mat = lovr.graphics.newMaterial(lovr.graphics.newTexture('water-surface-2.jpg'))
    -- terrain:setMaterial(water_mat)
    --   local offset = lovr.math.noise(0, 0) -- ensure zero height at origin
    --   for vi = 1, terrain:getVertexCount() do
    --     local x,y,z = terrain:getVertex(vi)
    --     z = (lovr.math.noise(x * 10, y * 10) - offset) / 20
    --     terrain:setVertex(vi, {x,y,z})
    --   end
end

function lovr.draw()
  basicLoco.draw()
  lovr.graphics.skybox(skybox)
  shader:send("uTime", lovr.timer.getTime())
  lovr.graphics.print("FPS "..lovr.timer.getFPS(), 0, 1.8, -1)
  -- model
  -- terrainScene.draw()
  --lovr.graphics.setShader()
  -- For Cascadeur models , rotate 90 x-axis and scale to 100
  lovr.graphics.setColor(0.0, 0.3, 0.763)
  lovr.graphics.cube('fill', -2.0, -2.0, -1.0, 2)
--   lovr.graphics.sphere(0.0, -5.0, 5.0, 0.5)
  lovr.graphics.setColor(1.0, 1.0, 1.0, 1.0)
  lovr.graphics.setShader(shader)
  lovr.graphics.push()
  lovr.graphics.scale(50)
  lovr.graphics.rotate(math.pi/2, 1, 0, 0)
  -- lovr.graphics.setWireframe(true)
  ocean:draw(lovr.math.mat4(), ocean_insts)
  lovr.graphics.pop()
  lovr.graphics.setShader(hm_shader)
  -- hm_model:draw(0,0,-4,0.0125)
  hm_model:draw(0,0,-4,1.0) --, -90*(2*3.14)/360, 1,0,0)
  lovr.graphics.setShader()

  -- lovr.graphics.setColor(0.388, 0.302, 0.412, 0.1)
--   terrain:draw()
  -- lovr.graphics.setWireframe(false)
end

function lovr.update(dT)
  basicLoco.update(dT)

  hm_model:animate(1, lovr.timer.getTime())
  if lovr.headset then 
      hx, hy, hz = lovr.headset.getPosition()
      shader:send('viewPos', { hx, hy, hz } )
      shader:send('viewPoss', { hx, hy, hz } )
      -- print(lovr.headset.getPosition())

      -- shader:send('wvSteep', 0.01*lovr.timer.getTime()%0.2 + 0.07)
      -- shader:send('lightPos', {-3.0, -(lovr.timer.getTime() % 15.0), 5.0})

  end
end


-- l_shader = lovr.graphics.newShader('standard', {
--   flags = {
--     normalMap = false,
--     indirectLighting = true,
--     occlusion = true,
--     emissive = true,
--     skipTonemap = false,
--     animated = true
--   }
-- })

-- l_shader:send('lovrLightDirection', { -1,-1,-1 })
-- l_shader:send('lovrLightColor', { .1, .1, .8, 1.0 })
-- l_shader:send('lovrExposure', 2)
