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
uniform sampler1D pointsNewPosition;
uniform sampler1D pointsNewVelocity;
uniform float gravity;
uniform float lifeLossStep;
uniform float dt;

uniform sampler2D oceanSurface;	// ocean surface already sampled
uniform sampler2DArray fftWavesSampler;	// ocean surface
uniform vec4 GRID_SIZES;
uniform vec2 gridSize;
uniform float choppy;
uniform vec4 choppy_factor;

void main()
{

    float lifetime = texture1D(pointsLifetime, u).r;
    if(lifetime > 0.0)
    {
        // Particle Position
        vec3 oldPos = texture1D(pointsOldPosition, u).rgb;
        vec3 oldVel = texture1D(pointsOldVelocity, u).rgb;
        vec3 grav = vec3(0.0,0.0,-gravity);
        vec3 newPos = oldPos + oldVel*dt + grav*dt*dt;

        // Ocean Position
        vec2 u = texture2D( oceanSurface, vec2(newPos.x, newPos.y)).xy; //vec3 P = texture2D( oceanSurface, vec2(newPos.x, newPos.y)).xyz;

        // Check State
        if(newPos.z <= 0.0)                                             //(newPos.z <= P.z)
        {
            gl_FragData[0] = vec4(newPos.xy,0.0,1.0);                   //(newPos.xy,P.z,1.0)
            gl_FragData[1] = vec4(vec3(0.0,0.0,0.0), 1.0);
        }
        else
        {
            vec3 newVel = (newPos - oldPos)/dt;
            gl_FragData[0] = vec4(newPos, 1.0);
            gl_FragData[1] = vec4(newVel, 1.0);
        }

        //Lifetime
        lifetime -= lifeLossStep*dt;
        if(lifetime < 0.0) lifetime = 0.0;
        if(lifetime > 1.0) lifetime = 1.0;

        gl_FragData[2] = vec4(lifetime,0.0,0.0,0.0);
    }
    else
    {
        vec3 newPos = texture1D(pointsNewPosition, u).rgb;
        vec3 newVel = texture1D(pointsNewVelocity, u).rgb;
        gl_FragData[0] = vec4(newPos, 1.0);
        gl_FragData[1] = vec4(newVel, 1.0);
        gl_FragData[2] = vec4(1.0,0.0,0.0,0.0);
    }



}

#endif
