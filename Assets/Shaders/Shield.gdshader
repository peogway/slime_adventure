shader_type canvas_item;

uniform float rotation : hint_range(0.0, 1.0);

void fragment() {
    float angle = rotation * 3.14159;
    vec2 uv_centered = UV - vec2(0.5);
    float scale = cos(angle);
    uv_centered.x /= scale;
    vec2 distorted_uv = uv_centered + vec2(0.5);

    if (distorted_uv.x < 0.0 || distorted_uv.x > 1.0) {
        discard;
    }

    COLOR = texture(TEXTURE, distorted_uv) * texture(TEXTURE, UV).a;
}
