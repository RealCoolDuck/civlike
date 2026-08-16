shader_type canvas_item;

uniform float fog_speed = 0.1;

float hex_distance(vec2 p) {
	p = abs(p);

	return max(
		p.y,
		p.x * 0.866025 + p.y * 0.5
	);
}

void fragment() {
	vec2 p = UV - vec2(0.5);
	p.x *= 1.1547;

	float distance = hex_distance(p);

	float fog = smoothstep(
		0.6,
		0.6,
		distance
	);

	COLOR = vec4(0.0, 0.0, 0.0, fog);
}