shader_type spatial;
render_mode unshaded;

uniform vec4 colour1 : hint_color = vec4(1,1,1,0);
uniform vec4 colour2 : hint_color = vec4(1,1,1,1);

uniform float cloudThreshold : hint_range(0,1) = 0.428;

uniform sampler2D Base_Albedo : hint_albedo;

void fragment() {
	vec2 _uv = UV;

	float noise_intensity = 50.;
	
	float c1t = cloudThreshold / 2.;
	
	float noise = texture(Base_Albedo, UV).r;
	noise = round(noise * noise_intensity) / noise_intensity;
	vec4 grad1 = mix(colour1, colour2, smoothstep(c1t,c1t,noise));
	
		
	if (noise < c1t){
		ALBEDO = grad1.rgb;
		ALPHA = smoothstep(c1t,c1t,noise);
	}
}
