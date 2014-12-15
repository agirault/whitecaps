#extension GL_EXT_gpu_shader4 : enable


uniform sampler1D pointsPosition;
uniform sampler1D pointsLifetime;
uniform mat4 worldToScreen; // world space to screen space
uniform vec3 worldCamera;
uniform float spriteSize;
uniform vec3 pointsColor;

varying float u;

#ifdef _VERTEX_
void main() {
    u = gl_Vertex.y;
    vec3 P = texture1D(pointsPosition, u).rgb;

    vec3 dist = worldCamera-P;
    float distnorm2 = dist.x*dist.x + dist.y*dist.y + dist.z*dist.z;
    gl_PointSize = (spriteSize)/sqrt(distnorm2);

    gl_Position = worldToScreen * vec4(P, 1.0);
}

#endif

#ifdef _FRAGMENT_
void main()
{
    float lifetime = texture1D(pointsLifetime, u).r;
    gl_FragColor = vec4(pointsColor,lifetime);
}

#endif
