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

uniform sampler2D oceanSurfaceP;	// ocean surface already sampled
uniform mat4 worldToScreen; // world space to screen space
uniform vec3 worldCamera;
uniform float farClipping;

void main()
{
    //Lifetime
    float lifetime = texture1D(pointsLifetime, u).r;
    lifetime -= lifeLossStep*dt;
    if(lifetime > 0.0)  //-- make particle move and age
    {
        // Particle Position
        vec3 oldPos = texture1D(pointsOldPosition, u).rgb;
        vec3 oldVel = texture1D(pointsOldVelocity, u).rgb;
        vec3 grav = vec3(0.0,0.0,-gravity);
        vec3 newPos = oldPos + oldVel*dt + grav*dt*dt;

        // Test far clipping
        vec3 dist = worldCamera-newPos;
        float distnorm2 = dist.x*dist.x + dist.y*dist.y + dist.z*dist.z;
        if(distnorm2 > farClipping*farClipping) //-- Remove because too far
        {
            gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
        }
        else //-- close enough : update
        {
            gl_FragData[2] = vec4(lifetime,0.0,0.0,0.0);

            // Ocean Position
            // TODO : the way I sample the texture right now after only using worldToScreen on newPos is wrong !
            // I need to do u = oceanPos(gl_Vertex) "inverse" to find where to sample in oceanSurfaceU and oceanSurfaceP : gridPos(x,y)
            vec4 test = worldToScreen * vec4(newPos.x, newPos.y,0.0,1.0);
            test /= test.w;
            vec3 dP = texture2D( oceanSurfaceP, vec2(test.x, test.y)).xyz;

            if(newPos.z <= dP.z) //-- under the water : becomes FOAM
            {
                gl_FragData[0] = vec4(newPos.xy,dP.z,1.0); //does not work because... see TODO above
                gl_FragData[1] = vec4(grav, 1.0);
            }
            else //-- above the water : stays SPLASH
            {
                vec3 newVel = (newPos - oldPos)/dt;
                gl_FragData[0] = vec4(newPos, 1.0);
                gl_FragData[1] = vec4(newVel, 1.0);
            }
        }
    }
    else    //-- create new particle instead of dead one
    {
        vec3 newPos = texture1D(pointsNewPosition, u).rgb;
        vec3 newVel = texture1D(pointsNewVelocity, u).rgb;
        // Test far clipping
        vec3 dist = worldCamera-newPos;
        float distnorm2 = dist.x*dist.x + dist.y*dist.y + dist.z*dist.z;
        if(distnorm2 > farClipping*farClipping) //-- Remove because too far
        {
            gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
        }
        else //-- close enough : update
        {
            gl_FragData[0] = vec4(newPos, 1.0);
            gl_FragData[1] = vec4(newVel, 1.0);
            gl_FragData[2] = vec4(1.0, 0.0, 0.0, 1.0);

        }
    }
}

#endif
