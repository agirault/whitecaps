#extension GL_EXT_gpu_shader4 : enable

varying float u;	// texcoords

#ifdef _VERTEX_
void main() {
    u = gl_Vertex.z;
    gl_Position = vec4(gl_Vertex.xy, 0.0, 1.0);
}

#endif

#ifdef _FRAGMENT_

uniform sampler1D pointsOldPosition;
uniform sampler1D pointsOldVelocity;
uniform float gravity;

void main()
{
    vec3 oldPos = texture1D(pointsOldPosition, u).rgb;
    vec3 oldVel = texture1D(pointsOldVelocity, u).rgb;
    vec3 newPos = oldPos + oldVel + vec3(0.0,0.0,-gravity);
    vec3 newVol = newPos - oldPos;

    gl_FragData[0] = vec4(newPos, 1.0);
    gl_FragData[1] = vec4(newVol, 1.0);
}

#endif
