shader_type spatial;

uniform vec2 resolution = vec2(600.0, 400.0);
uniform vec3 line_color: source_color = vec3(0.1, 0.4, 0.2);
uniform int octaves: hint_range(1,50,1) = 20;
uniform float zoom_factor: hint_range(1.0, 100.0, 0.1) = 10.0;
uniform float zoom_coef: hint_range(1.0, 5.0, 0.01) = 1.1;
uniform float brightness: hint_range(1.0,100.0,0.1) = 10.0;
uniform float rotation_angle: hint_range(0, 4.0, 0.01) = 0.5;
uniform float time_scale: hint_range(0.0, 10.0, 0.05) = 1.0;
uniform float length_mod: hint_range(-0.3, 0.5, 0.01) = 0.01;
uniform float brightness_mod: hint_range (-1.0, 1.0, 0.1) = 0.01;
uniform float alpha_threshold: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float game_time = -999.0;
uniform bool pause = false;

/**
*BROKEN
*/
uniform float power_scale = 2.0;

mat2 rotate(float angle){
	float sa = sin(angle);
	float ca = cos(angle);
	return mat2(vec2(ca,sa), vec2(-sa, ca));
}

vec2 fractal(vec2 uv, float time){
	vec2 shift = vec2(0.0);
	vec2 warped_uv = vec2(0.0);
	vec2 fbm = vec2(0.0);
	float zoom = zoom_factor;
	mat2 rotation = rotate(rotation_angle);

	for (int i = 0; i < octaves; i++){
		uv *= rotation;
		shift *= rotation;
		warped_uv = uv * zoom + float(i) + shift + time;
		shift += sin(warped_uv);
		fbm += cos(warped_uv) / zoom;
		zoom *= zoom_coef;
	}
	return fbm;
}



void vertex() { // Called for every vertex the material is visible on.

}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;

	vec2 fbm = fractal(uv, TIME * time_scale);

	float fbm_len = max(length(fbm), 0.0001);
	vec3 color = brightness * line_color *
	    pow((fbm.x + fbm.y + brightness_mod) + length_mod / fbm_len, 2.0);

	color = clamp(color, vec3(0.0), vec3(1.0));

	EMISSION = color * 0.5;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
