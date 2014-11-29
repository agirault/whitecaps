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
uniform sampler1D pointsLifetime;
uniform float gravity;
uniform float lifeLossStep;
uniform float dt;

void main()
{
    //Position
    vec3 oldPos = texture1D(pointsOldPosition, u).rgb;
    vec3 oldVel = texture1D(pointsOldVelocity, u).rgb;
    vec3 grav = vec3(0.0,0.0,-gravity);
    vec3 newPos = oldPos + oldVel*dt + grav*dt*dt;
    vec3 newVel = (newPos - oldPos)/dt;

    gl_FragData[0] = vec4(newPos, 1.0);
    gl_FragData[1] = vec4(newVel, 1.0);

    //Lifetime
    float lifetime = texture1D(pointsLifetime, u).r;
    lifetime -= lifeLossStep*dt;
    if(lifetime < 0.0) lifetime = 0.0;
    if(lifetime > 1.0) lifetime = 1.0;

    gl_FragData[2] = vec4(lifetime,0.0,0.0,0.0);

}

#endif
