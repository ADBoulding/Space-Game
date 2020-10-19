shader_type spatial;

uniform vec4 colour1 : hint_color = vec4(0.33,0.45,0.53,1);
uniform vec4 colour2 : hint_color = vec4(0.88,0.91,0.67,1);
uniform vec4 colour3 : hint_color = vec4(0.58,0.88,0.51,1);

uniform float colour1_Threshold : hint_range(0,1) = 0.428; 
uniform float colour2_Threshold : hint_range(0,1) = 0.516;
uniform float colour3_Threshold : hint_range(0,1) = 0.634;

uniform sampler2D Base_Albedo : hint_albedo;

void fragment() {
	vec2 _uv = UV;

	float noise_intensity = 50.;
	
	float c1t = colour1_Threshold / 2.;
	float c2t = colour2_Threshold / 2.;
	float c3t = colour3_Threshold / 2.;
	
	float noise = texture(Base_Albedo, UV).r;
	noise = round(noise * noise_intensity) / noise_intensity;
	vec4 grad1 = mix(colour1, colour2, smoothstep(c1t,c1t,noise));
	vec4 grad2 = mix(grad1, colour3, smoothstep(c2t,c2t,noise));
		
	if (noise < c1t){
		ALBEDO = grad1.rgb;
	} else if (noise < c2t) {
		ALBEDO = grad2.rgb;
	} else {
		ALBEDO = colour3.rgb;
	}
}
//
void light() {
// Output:0

}
