#extension GL_EXT_gpu_shader4 : enable


uniform sampler1D pointsPosition;
uniform sampler1D pointsLifetime;
uniform mat4 worldToScreen; // world space to screen space

varying float u;

#ifdef _VERTEX_
void main() {
    u = gl_Vertex.y;
    vec3 P = texture1D(pointsPosition, u).rgb;
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
