shader_type canvas_item;

uniform float zoom : hint_range(0.0, 1.0) = 1.0;

uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform vec3 static_color_low : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 static_color_high : source_color = vec3(1.0, 1.0, 1.0);
uniform float alpha_threshold : hint_range(0.0, 0.498) = 0.0;

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE * zoom;
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233)) + TIME * speed) * 43758.5453);
    noise = noise * contrast + brightness - contrast * 0.5;
    noise = clamp(noise, 0.0, 1.0);
    vec3 color = mix(static_color_low, static_color_high, noise);
    float alpha = (length(color) / sqrt(3.0)) > alpha_threshold ? 1.0 : 0.0;
    COLOR = vec4(color, alpha);
}
