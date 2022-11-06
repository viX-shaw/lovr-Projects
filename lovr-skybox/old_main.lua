function lovr.load()
    shader = lovr.graphics.newShader([[
      uniform float u_time;

      vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
        vertex.z = 0.3*sin(vertex.x);
        return projection * transform * vertex;
      }
    ]], [[
        const float gridSize = 25.;
        const float cellSize = .5;
    
        vec4 color(vec4 gcolor, sampler2D image, vec2 uv) {
    
          // Distance-based alpha (1. at the middle, 0. at edges)
          float alpha = 1. - smoothstep(.15, .50, distance(uv, vec2(.5)));
    
          // Grid coordinate
          uv *= gridSize;
          uv /= cellSize;
          vec2 c = abs(fract(uv - .5) - .5) / fwidth(uv);
          float line = clamp(1. - min(c.x, c.y), 0., 1.);
          vec3 value = mix(vec3(.01, .01, .011), (vec3(.04)), line);
    
          return vec4(vec3(value), alpha);
        }
    ]], { flags = { highp = true } })
  
    lovr.graphics.setBackgroundColor(.05, .05, .05)
  end
  
function lovr.draw()
shader:send("u_time", lovr.timer.getTime())
lovr.graphics.setShader(shader)
lovr.graphics.plane('fill', 0, 0, 0, 5, 5, -math.pi / 2, 1, 0, 0)
-- lovr.graphics.plane('fill', 0, 0, -10, 25, 25, -math.pi / 2, 0, 0, 1)
lovr.graphics.setShader()
end

-- const float gridSize = 3.;
--       const float cellSize = .5;
--       const int AMOUNT = 1;
--       uniform float u_time;
--       uniform vec2 u_resolution = vec2(.5,.5);
  
--       vec4 color(vec4 gcolor, sampler2D image, vec2 uv) {
--         /* uv *= gridSize;
--         uv /= cellSize;
--         for (int n = 1; n < 8; n++){
--             float i = float(n);
--             uv += vec2(0.7 / i * sin(i * uv.y + u_time + 0.3 * i) + 0.8, 0.4 / i * sin(uv.x + u_time + 0.3 * i) + 1.6);
--           }
        
--           uv *= vec2(0.7 / sin(uv.y + u_time + 0.3) + 0.8, 0.4 / sin(uv.x + u_time + 0.3) + 1.6);
        
--           vec3 color = vec3(0.5 * sin(uv.x) + 0.5, 0.5 * sin(uv.y) + 0.5, sin(uv.x + uv.y));
        
--           return vec4(color, 1.0); */

--         vec2 coord = 10.0 * (uv - u_resolution / 2.0) / min(u_resolution.y, u_resolution.x);

--         float len;
    
--         for (int i = 0; i < AMOUNT; i++){
--             len = length(vec2(coord.x, coord.y));
    
--             coord.x = coord.x - cos(coord.y + sin(len)) + cos(u_time / 9.0);
--             coord.y = coord.y + sin(coord.x + cos(len)) + sin(u_time / 12.0);
--         }
    
--         return vec4(cos(len*1.5), cos(len), cos(len), 1.0);
--       }