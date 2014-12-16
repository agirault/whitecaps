#extension GL_EXT_gpu_shader4 : enable


#define LAYER_HEIGHT		0.0

uniform mat4 screenToCamera; // screen space to camera space
uniform mat4 cameraToWorld; // camera space to world space
uniform vec3 worldCamera; // camera position in world space

uniform vec2 gridSize;
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

    gl_Position = gl_Vertex; // writing in texture. gl_Vertex might not be good coordinates
}

#endif

#ifdef _FRAGMENT_
void main()
{
    gl_FragData[0] = vec4(u,0.0,1.0);
    gl_FragData[1] = vec4(ux,0.0,1.0);
    gl_FragData[2] = vec4(uy,0.0,1.0);
}

#endif
