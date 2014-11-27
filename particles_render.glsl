#extension GL_EXT_gpu_shader4 : enable


uniform sampler1D particlesPosition;
uniform mat4 worldToScreen; // world space to screen space


#ifdef _VERTEX_
void main() {
    float u = gl_Vertex.y;
    vec3 P = texture1D(particlesPosition, u).rgb;
    gl_Position = worldToScreen * vec4(P, 1.0);
    //gl_Position = vec4(P, 1.0);
}

#endif

#ifdef _FRAGMENT_
void main()
{
    gl_FragColor = vec4(1.0,0.0,0.0,1.0);
}

#endif
