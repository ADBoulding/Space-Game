shader_type canvas_item;

uniform vec4 starColour : hint_color = vec4(1,1,1,1);
uniform vec2 viewport_size = vec2(640.,360.);
uniform float star_size = 2.;
uniform float flares = 0.;
varying vec2 vtx;

mat2 Rot(float a){
	float s=sin(a); 
	float c=cos(a);
	mat2 matrix = mat2(vec2(c,-s),vec2(s,c));
	return matrix;
}

float Star(vec2 uv, float flare) {
	float d = length(uv);
	float m = 0.1/d;
	
	float rays = max(0., 1.-abs(uv.x*uv.y*1000.));
	m += rays * flare;
	uv *= Rot(3.1415/4.);
	rays = max(0., 1.-abs(uv.x*uv.y*1000.));
	m += rays*0.3*flare;
	
	return m;
}


void fragment()
{
	vec2 uv = abs((UV - 0.5)/-0.5);
		
	vec3 col = vec3(0);
	
	float star = Star(uv, flares);
	col += star * starColour.rgb * star_size;
	
	COLOR = vec4(col, smoothstep(0.75,0.05,length(uv)));
}