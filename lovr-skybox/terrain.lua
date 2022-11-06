local terrain, shader

local shaderCode = {[[
/* VERTEX shader */
out vec4 fragmentView;
out vec4 vertice;
out vec3 vNormal;

vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
  fragmentView = projection * transform * vertex;
  vertice = vertex;
  vNormal = lovrNormal;
  return fragmentView;
} ]], [[
/* FRAGMENT shader */
#define PI 3.1415926538
in vec4 vertice;
in vec4 fragmentView;
in vec3 vNormal;
uniform vec3 fogColor;
uniform sampler2D material;

float smin( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

float map( in vec3 p )
{
	float d = length(p-vec3(0.0,1.0,0.0))-1.0;
    d = smin( d, p.y, 1.0 );
    return d;
}

vec3 calcNormal( in vec3 pos, in float eps )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*eps;
    return normalize( e.xyy*map( pos + e.xyy ) + 
					  e.yyx*map( pos + e.yyx ) + 
					  e.yxy*map( pos + e.yxy ) + 
					  e.xxx*map( pos + e.xxx ) );
}

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv)
{
  //Triplanar Mapping
  vec4 x = texture(material, vertice.yz);
  vec4 y = texture(material, vertice.zx);
  vec4 z = texture(material, vertice.xy);
  vec3 w = pow(abs(calcNormal(vertice.xyz, 0.001)), vec3(1.0)); //k=1.0
  vec4 res = (x*w.x + y*w.y + z*w.z) / (w.x + w.y + w.z);

  float fogAmount = atan(length(fragmentView) * 0.1) * 2.0 / PI;
  //graphicsColor = graphicsColor * lovrDiffuseColor * lovrVertexColor * texture(material, vertice.xy);
  graphicsColor = graphicsColor * lovrDiffuseColor * lovrVertexColor * res;
  vec4 color = vec4(mix(graphicsColor.rgb, fogColor, fogAmount), graphicsColor.a);
  return graphicsColor;
}]]}

local terrainScene = {}

local function grid(subdivisions)
  local size = 1 / math.floor(subdivisions or 1)
  local vertices = {}
  local indices  = {}
  for y = -0.5, 0.5, size do
    for x = -0.5, -0.1, size do
      table.insert(vertices, {x, y, 0})
      table.insert(vertices, {x, y + size, 0})
      table.insert(vertices, {x + size, y, 0})
      table.insert(vertices, {x + size, y + size, 0})
      table.insert(indices, #vertices - 3)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices - 1)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices)
      table.insert(indices, #vertices - 1)
    end
  end
  local meshFormat = {{'lovrPosition', 'float', 3}}
  local mesh = lovr.graphics.newMesh(meshFormat, vertices, "triangles", "dynamic", true)
  mesh:setVertexMap(indices)
  return mesh
end

function terrainScene.load()
  local skyColor = {0.208, 0.208, 0.275}
--   lovr.graphics.setBackgroundColor(skyColor)
  lovr.graphics.setLineWidth(5)
  lovr.graphics.setAlphaSampling(true)

  shader = lovr.graphics.newShader(unpack(shaderCode))
  shader:send('fogColor', { lovr.math.gammaToLinear(unpack(skyColor)) })
  shader:send('material', lovr.graphics.newTexture('mountain.jpg'))
  terrain = grid(50)
--   terrain_mat = lovr.graphics.newMaterial(lovr.graphics.newTexture('mt2.jpg'))
--   terrain:setMaterial(terrain_mat)
  local offset = lovr.math.noise(0, 0) -- ensure zero height at origin
  for vi = 1, terrain:getVertexCount() do
    local x,y,z = terrain:getVertex(vi)
    z = (lovr.math.noise(x * 10, y * 10) - offset)
    terrain:setVertex(vi, {x,y,z})
  end
  
end

function terrainScene.draw()
  lovr.graphics.setShader(shader)
  lovr.graphics.push()
  lovr.graphics.rotate(math.pi/2, 1, 0, 0)
  lovr.graphics.scale(100)
  lovr.graphics.setColor(0.565, 0.404, 0.463)
  terrain:draw()
  lovr.graphics.setWireframe(true)
  lovr.graphics.setColor(0.388, 0.302, 0.412, 0.1)
  terrain:draw()
  lovr.graphics.setWireframe(false)
  lovr.graphics.setColor(1.0, 1.0, 1.0, 1.0)
  lovr.graphics.pop()
  lovr.graphics.setShader()
end

return terrainScene