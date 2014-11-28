#extension GL_EXT_gpu_shader4 : enable


#define LAYER_HEIGHT		0.0

uniform mat4 screenToCamera; // screen space to camera space
uniform mat4 cameraToWorld; // camera space to world space
uniform mat4 worldToCamera; // world space to camera space
uniform vec3 worldCamera; // camera position in world space

uniform vec2 gridSize;
uniform float choppy;
uniform vec4 choppy_factor;

uniform sampler2DArray fftWavesSampler;	// ocean surface

uniform vec4 GRID_SIZES;

varying vec2 u;
varying vec2 ux;
varying vec2 uy;

#ifdef _VERTEX_

vec2 oceanPos(vec4 vertex) {
    vec3 cameraDir = normalize((screenToCamera * vertex).xyz);
    vec3 worldDir = (cameraToWorld * vec4(cameraDir, 0.0)).xyz;
    float t = -worldCamera.z / worldDir.z;
    return worldCamera.xy + t * worldDir.xy;
}

void main()
{
    u = oceanPos(gl_Vertex);
    ux = oceanPos(gl_Vertex + vec4(gridSize.x, 0.0, 0.0, 0.0));
    uy = oceanPos(gl_Vertex + vec4(0.0, gridSize.y, 0.0, 0.0));

    vec2 uv = vec2( u.x/gridSize.x , u.y/gridSize.y ) ; // should be between 0 and 1 to project on texture
    gl_Position = vec4(uv, 0.0, 1.0);
}

#endif

#ifdef _FRAGMENT_
void main()
{
    vec2 dux = ux - u;
    vec2 duy = uy - u;

    // sum altitudes (use grad to get correct mipmap level)
    vec3 dP = vec3(0.0);
    dP.z += texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.x, LAYER_HEIGHT), dux / GRID_SIZES.x, duy / GRID_SIZES.x).x;
    dP.z += texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.y, LAYER_HEIGHT), dux / GRID_SIZES.y, duy / GRID_SIZES.y).y;
    dP.z += texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.z, LAYER_HEIGHT), dux / GRID_SIZES.z, duy / GRID_SIZES.z).z;
    dP.z += texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.w, LAYER_HEIGHT), dux / GRID_SIZES.w, duy / GRID_SIZES.w).w;

    // choppy
    if (choppy > 0.0) {

        dP.xy += choppy_factor.x*texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.x, 3.0), dux / GRID_SIZES.x, duy / GRID_SIZES.x).xy;
        dP.xy += choppy_factor.y*texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.y, 3.0), dux / GRID_SIZES.y, duy / GRID_SIZES.y).zw;
        dP.xy += choppy_factor.z*texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.z, 4.0), dux / GRID_SIZES.z, duy / GRID_SIZES.z).xy;
        dP.xy += choppy_factor.w*texture2DArrayGrad(fftWavesSampler, vec3(u / GRID_SIZES.w, 4.0), dux / GRID_SIZES.w, duy / GRID_SIZES.w).zw;
    }
    vec3 P = vec3(u + dP.xy, dP.z);

    gl_FragData[0] = vec4(P,1.0);
}

#endif
