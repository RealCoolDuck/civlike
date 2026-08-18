shader_type canvas_item;

void fragment() {
    COLOR = texture(TEXTURE, UV);

    // Make everything slightly transparent
	if (COLOR.r < 0.1 && COLOR.g < 0.1 && COLOR.b < 0.1) {
		COLOR.a *= 0.4;
	} else {
    	COLOR.a *= 0.8;
	}
}