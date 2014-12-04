#extension GL_EXT_gpu_shader4 : enable

varying float u;	// texcoords

#ifdef _VERTEX_
void main() {
    u = gl_Vertex.z;
    gl_Position = vec4(gl_Vertex.xy, 0.0, 1.0);
}

#endif

#ifdef _FRAGMENT_

uniform sampler1D pointsNewPosition;
uniform sampler1D pointsNewVelocity;
uniform vec3 displacement;
uniform float speed;

void main()
{
    vec3 oldPos = texture1D(pointsNewPosition, u).rgb;
    vec3 oldVel = texture1D(pointsNewVelocity, u).rgb;

    vec3 newPos = oldPos + displacement;
    vec3 newVel = oldVel + vec3(speed,speed,speed);

    gl_FragData[0] = vec4(newPos, 1.0);
    gl_FragData[1] = vec4(newVel, 1.0);
}

#endif
