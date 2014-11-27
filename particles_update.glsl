#extension GL_EXT_gpu_shader4 : enable

varying float u;	// texcoords

#ifdef _VERTEX_
void main() {
    u = gl_Vertex.z;
    gl_Position = vec4(gl_Vertex.xy, 0.0, 1.0);
}

#endif

#ifdef _FRAGMENT_

#define LAYER_JACOBIAN_XX 	5.0
#define LAYER_JACOBIAN_YY	6.0
#define LAYER_JACOBIAN_XY	7.0

uniform sampler1D pointsOldPosition;
uniform sampler2DArray fftWavesSampler;
uniform vec4 choppy;
uniform float vary;

void main()
{
    vec3 pos = texture1D(pointsOldPosition, u).rgb;
    pos = pos*vary;
    gl_FragData[0] = vec4(pos.x, pos.y, pos.z, 1.0);
}

#endif
