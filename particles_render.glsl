#extension GL_EXT_gpu_shader4 : enable


uniform sampler1D pointsPosition;
uniform sampler1D pointsLifetime;
uniform mat4 worldToScreen; // world space to screen space
uniform vec3 worldCamera;
uniform float spriteSize;

varying float u;

#ifdef _VERTEX_
void main() {
    u = gl_Vertex.y;
    vec3 P = texture1D(pointsPosition, u).rgb;

/*  //"Points sprites for particle system", Stackoverflow"
    vec4 eyePos = worldToCamera * vec4(P, 1.0);
    vec4 projVoxel = cameraToScreen * vec4(3.0,3.0,eyePos.z,eyePos.w);
    vec4 projSize = screenSize * projVoxel.xy / projVoxel.w;
    gl_PointSize = 0.25 * (projSize.x+projSize.y);
*/

    vec3 dist = worldCamera-P;
    float distnorm2 = dist.x*dist.x + dist.y*dist.y + dist.z*dist.z;
    gl_PointSize = (spriteSize)/distnorm2;

    gl_Position = worldToScreen * vec4(P, 1.0);
}

#endif

#ifdef _FRAGMENT_
void main()
{
    float lifetime = texture1D(pointsLifetime, u).r;
    gl_FragColor = vec4(lifetime,0.0,0.0,1.0);
}

#endif
