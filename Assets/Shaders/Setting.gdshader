shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5) = 0.0;
const float blur_size = 1.0 / 500.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 sum = vec4(0.0);

	sum += texture(SCREEN_TEXTURE, uv + vec2(-blur_size, -blur_size), lod);
	sum += texture(SCREEN_TEXTURE, uv + vec2(-blur_size, 0.0), lod);
	sum += texture(SCREEN_TEXTURE, uv + vec2(-blur_size, blur_size), lod);
	sum += texture(SCREEN_TEXTURE, uv + vec2(0.0, -blur_size), lod);
	sum += texture(SCREEN_TEXTURE, uv, lod);
	sum += texture(SCREEN_TEXTURE, uv + vec2(0.0, blur_size), lod);
	sum += texture(SCREEN_TEXTURE, uv + vec2(blur_size, -blur_size), lod);
	sum += texture(SCREEN_TEXTURE, uv + vec2(blur_size, 0.0), lod);
	sum += texture(SCREEN_TEXTURE, uv + vec2(blur_size, blur_size), lod);

	COLOR = sum / 9.0;
}
