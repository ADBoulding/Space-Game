shader_type canvas_item;
// Star Nest by Pablo Roman Andrioli

// This content is under the MIT License.

const int iterations = 17;
const float formuparam = 0.53;

const int  volsteps = 20;
const float stepsize = 0.1;

const float zoom = 0.800;
const float tile =   0.850;
const float speed =  0.010 ;

const float brightness = 0.0015;
const float darkmatter = 0.300;
const float distfading = 0.730;
const float saturation = 0.850;

uniform vec2 viewPort = vec2(640.,360.);

varying vec2 vtx;

uniform vec2 offset = vec2(0.,0.);

void vertex()
{
	vtx = VERTEX + offset;
	vec2 fragCoord = vtx;
	vec2 iResolution = viewPort;//1.0/SCREEN_PIXEL_SIZE;
}

