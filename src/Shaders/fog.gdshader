shader_type fog;

uniform sampler2D noise_texture:repeat_enable;
uniform float noise_scale = 0.015;
uniform float flatness = 9.155;
uniform float density = 1.87;
uniform sampler2D grad_tex;
uniform float speed = 0.05;

void fog() {
	vec2 move_uv = vec2(speed, 0.0) * TIME;
	float detail_noise = texture(noise_texture, WORLD_POSITION.xy * noise_scale + move_uv * 0.5).r;
	detail_noise *= 0.2;
	float noise = texture(noise_texture, WORLD_POSITION.yz * noise_scale + move_uv + detail_noise).r;
	DENSITY = mix(1.0, noise, UVW.y * flatness);
	DENSITY *= step(0.0, -SDF) * density;
	vec3 col = texture(grad_tex, vec2(DENSITY, 0.5)).rgb;
	ALBEDO = vec3(col);
}
