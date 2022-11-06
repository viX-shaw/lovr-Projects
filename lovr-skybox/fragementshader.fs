/* FRAGMENT shader */
#define PI 3.1415926538
in vec4 fragmentView;
in vec2 pos;
uniform vec3 fogColor;
uniform sampler2D material;

uniform float uTime;
uniform vec4 ambience;
uniform vec4 liteColor;
uniform vec3 lightPos;
uniform vec3 viewPos;
uniform float specularStrength;
uniform float metallic;
uniform sampler2D lovrEnvTexture; 

in vec3 Normal;
in vec3 FragmentPos;
in vec3 vN;

const vec2 invAtan = vec2(0.1591, 0.3183);
vec2 SampleSphericalMap(vec3 v)
{
    vec2 uv = vec2(atan(v.z, v.x), asin(v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

float rand(vec2 co){
  return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 hash3( float n )
{
  return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}
vec3 hash3( vec2 p )
{
  vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
          dot(p,vec2(269.5,183.3)), 
          dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453);
}

float noise( in vec2 x, float u, float v )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    float k = 1.0 + 63.0*pow(1.0-v,4.0);
    float va = 0.0;
    float wt = 0.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2  g = vec2( float(i), float(j) );
        vec3  o = hash3( p + g )*vec3(u,u,1.0);
        vec2  r = g - f + o.xy;
        float d = dot(r,r);
        float w = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
        va += w*o.z;
        wt += w;
    }

    return va/wt;
}

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv)
{
  //float fogAmount = atan(length(fragmentView) * 0.1) * 2.0 / PI;
  //vec4 color = vec4(mix(graphicsColor.rgb, fogColor, fogAmount), graphicsColor.a);
  //return color;

  //return graphicsColor * lovrDiffuseColor * lovrVertexColor * texture(image, uv);
  // return texture(material, pos);

  //diffuse
  vec3 norm = normalize(Normal);
  vec3 lightDir = normalize(lightPos - FragmentPos);
  // vec3 lightDir = normalize(lightPos - fragmentView.xyz);
  float diff = max(dot(norm, lightDir), 0.0);
  vec4 diffuse = diff * liteColor;
  
  //specular
  vec3 viewDir = normalize(viewPos - FragmentPos);
  vec3 reflectDir = reflect(-lightDir, norm);
  vec3 halfVec = normalize(viewDir+reflectDir);
  // float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
  float spec = pow(max(dot(viewDir, halfVec), 0.0), metallic);
  vec4 specular = specularStrength * spec * liteColor;

  // vec4 baseColor = graphicsColor * texture(image, uv);
  // vec4 baseColor = texture(image, uv);   
  vec4 baseColor = vec4(0.0, 0.04, 0.08, 1.0);
  
  // vec3 reflectViewDir = reflect(-viewDir, norm);
  // Attenuation
  float light_constant = 1.0;
  float light_linear = 0.014;
  float light_quadratic = 0.0007;
  float distance = length(lightPos - FragmentPos);
  float attenuation = 1.0 / (light_constant + light_linear * distance + light_quadratic * (distance * distance));         
  vec4 ambient = vec4(0.0, 0.0, 0.05, 0.0) * attenuation; 
  // diffuse  *= attenuation;
  // specular *= attenuation;
  // vec2 envPos = vec2(length(vN.yz), vN.x);
  vec2 uv_new = SampleSphericalMap(normalize(vN));
  vec4 fragcol = baseColor + ( diffuse + specular * texture(lovrEnvTexture, uv_new));
  // vec4 fragcol = baseColor + ( diffuse + specular * 0.2* texture(lovrEnvironmentTexture, vec2(vN.x, -vN.y)));
  // vec4 fragcol = 0.2* texture(lovrEnvironmentTexture, vec2(vN.x, -vN.y));
  // vec4 fragcol = baseColor * (ambience + diffuse + specular);

  // float theta = dot(lightDir, normalize(-viewDir));
    
  // if(theta < cos(12.5)) 
  // {       
  //   // do lighting calculations
  //   fragcol = baseColor * ambience;
  // }
  // if (FragmentPos.y > 0.7 - 0.2*abs(sin(FragmentPos.y - 0.2*uTime)) && \
  //  FragmentPos.x > 0.4 - 0.2*abs(sin(FragmentPos.x - 0.2 * uTime))) {
  //   // fragcol = noise(FragmentPos.xy, 1.0, 1.0)>0.5?fragcol:vec4(1.0); //https://iquilezles.org/articles/voronoise/
  //   float voro = noise(48.0*(sin(FragmentPos.xy - 0.1 * uTime)) , 1.0, 1.0);
  //   fragcol.xyz = (voro>0.5 || voro<0.45)?fragcol.xyz:fragcol.xyz + vec3(0.5)*(voro);//*abs(sin(voro));
  // }

  float seethrough = length(fragmentView.xz)/6.0;
  return vec4(fragcol.xyz, seethrough);
  // return vec4(seethrough, 0, 0, 1.0);
  
  // return vec4(fragcol.xyz, 1.0);
  // return fragcol;
}