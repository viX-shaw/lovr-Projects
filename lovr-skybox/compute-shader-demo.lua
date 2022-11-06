local steps_per_frame = 10 -- controlled with keys 1 to 5
local texture_size = 128 * 4
local group_size = 16

local diffusion_rate_a = 0.804 -- randomized with space key
local diffusion_rate_b = 0.282
local feed_rate = 0.0718
local kill_rate = 0.0648

local rd_code = string.format([[
layout(local_size_x = %d, local_size_y = %d, local_size_z = 1) in;

layout(rgba16f) uniform readonly highp image2D p_tex;
layout(rgba16f) uniform writeonly highp image2D n_tex;

uniform float diffusion_rate_a;
uniform float diffusion_rate_b;
uniform float feed_rate;
uniform float kill_rate;
float dt = 1.0;

vec3 laplacian(ivec2 coords) {
  vec3 rg = vec3(0.0, 0.0, 0.0);
  rg += imageLoad(p_tex, coords + ivec2(-1, -1)).rgb *  0.05;
  rg += imageLoad(p_tex, coords + ivec2(-0, -1)).rgb *  0.2;
  rg += imageLoad(p_tex, coords + ivec2( 1, -1)).rgb *  0.05;
  rg += imageLoad(p_tex, coords + ivec2(-1,  0)).rgb *  0.2;
  rg += imageLoad(p_tex, coords + ivec2( 0,  0)).rgb * -1.0;
  rg += imageLoad(p_tex, coords + ivec2( 1,  0)).rgb *  0.2;
  rg += imageLoad(p_tex, coords + ivec2(-1,  1)).rgb *  0.05;
  rg += imageLoad(p_tex, coords + ivec2( 0,  1)).rgb *  0.2;
  rg += imageLoad(p_tex, coords + ivec2( 1,  1)).rgb *  0.05;
  return rg;
}

void compute() {
  ivec2 coords =  ivec2(gl_GlobalInvocationID.xy);
  vec4 color = imageLoad(p_tex, coords);
  float a = color.r;
  float b = color.g;
  vec3 lp = laplacian(coords);
  float n_a = a + (diffusion_rate_a * lp.x - a*b*b + feed_rate*(1.0 - a)) * dt;
  float n_b = b + (diffusion_rate_b * lp.y + a*b*b - (kill_rate + feed_rate)*b) * dt;
  imageStore(n_tex, coords, vec4(n_a, n_b, color.b, 1.0));
}
]], group_size, group_size)

local rd_shader = lovr.graphics.newComputeShader(rd_code)
rd_shader:send('diffusion_rate_a', diffusion_rate_a)
rd_shader:send('feed_rate', feed_rate)
rd_shader:send('diffusion_rate_b', diffusion_rate_b)
rd_shader:send('kill_rate', kill_rate)

local texture1 = lovr.graphics.newTexture(texture_size, texture_size, 1, {mipmaps=false, format='rgba16f'})
local texture2 = lovr.graphics.newTexture(texture_size, texture_size, 1, {mipmaps=false, format='rgba16f'})
local material1 = lovr.graphics.newMaterial(texture1)
local material2 = lovr.graphics.newMaterial(texture2)
local canvas = lovr.graphics.newCanvas(texture1)

local odd = false

function initTexture()
  canvas:renderTo(function()
    lovr.graphics.clear()
    lovr.graphics.setViewPose(1, mat4())
    lovr.graphics.setColor(1,1,0) -- infuse both chemical A and B
    lovr.graphics.cylinder(0, 0, -2,  1, 0,1,0,0, 1,1, true, 5)
  end)
end


function lovr.load(dt)
  initTexture()
end


function lovr.update(dt)
  for i=1, steps_per_frame do
    odd = not odd
    if odd then
      rd_shader:send('p_tex', texture1)
      rd_shader:send('n_tex', texture2)
    else
      rd_shader:send('p_tex', texture2)
      rd_shader:send('n_tex', texture1)
    end
    lovr.graphics.compute(rd_shader, texture_size/group_size, texture_size/group_size)
  end
end


function lovr.draw()
  local material = odd and material2 or material1
  lovr.graphics.setColor(0,1,0) -- draw only green component (chemical B)
  lovr.graphics.plane(material, 0, 0, -10, 15, 15, 1.5, -1,0,0)
end


if lovr.headset.getName() == 'Simulator' then
  lovr.headset.renderTo = function(draw_fn)  -- mono view in desktop simulator 
    lovr.graphics.clear(lovr.graphics.getBackgroundColor())
    lovr.graphics.setViewPose(1, lovr.headset.getPose())
    draw_fn()
  end
end


function lovr.keypressed(key)
  if key == '1' then -- control speed
    steps_per_frame = 0
  elseif key == '2' then
    steps_per_frame = 5
  elseif key == '3' then
    steps_per_frame = 10
  elseif key == '4' then
    steps_per_frame = 20
  elseif key == '5' then
    steps_per_frame = 40
  elseif key == 'r' then -- restart to initial pattern
    odd = false
    initTexture()
  elseif key == 'space' then -- shuffle constants
    diffusion_rate_a = lovr.math.randomNormal(0.075, 0.8)
    feed_rate = lovr.math.randomNormal(0.005, 0.07)
    diffusion_rate_b = lovr.math.randomNormal(0.075, 0.2)
    kill_rate = lovr.math.randomNormal(0.005, 0.06)
    rd_shader:send('diffusion_rate_a', diffusion_rate_a)
    rd_shader:send('feed_rate', feed_rate)
    rd_shader:send('diffusion_rate_b', diffusion_rate_b)
    rd_shader:send('kill_rate', kill_rate)
    print('\ndiffusion_rate_a', diffusion_rate_a,
          '\ndiffusion_rate_b', diffusion_rate_b,
          '\nfeed_rate', feed_rate,
          '\nkill_rate', kill_rate)
  end
end