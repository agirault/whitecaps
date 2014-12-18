#extension GL_EXT_gpu_shader4 : enable


#define LAYER_HEIGHT		0.0

uniform mat4 screenToCamera; // screen space to camera space
uniform mat4 cameraToWorld; // camera space to world space
uniform vec3 worldCamera; // camera position in world space

uniform float gridXcenter;
uniform float gridXhalflength;
uniform float gridYcenter;
uniform float gridYhalflength;

uniform sampler2DArray fftWavesSampler;	// ocean surface
uniform float choppy;
uniform vec4 choppy_factor;
uniform vec2 gridSize;
uniform vec4 GRID_SIZES;

varying vec2 u;

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

    // writing in FBO. between -1 and 1
    float x = (gl_Vertex.x - gridXcenter)/gridXhalflength;
    float y = (gl_Vertex.y - gridYcenter)/gridYhalflength;
    gl_Position = vec4(x,y,0.0,1.0);
}

#endif

#ifdef _FRAGMENT_
void main()
{
    gl_FragData[0] = vec4(u,0.0,1.0);
}

#endif
