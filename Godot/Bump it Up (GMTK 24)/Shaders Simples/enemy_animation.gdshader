shader_type canvas_item;

uniform bool on = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(on==true){
		vec4 pixel_color = texture(TEXTURE, UV);
		pixel_color.r = 1.0;
		pixel_color.g = 1.0;
		pixel_color.b = 1.0;

		COLOR = pixel_color;
	}else{COLOR = texture(TEXTURE, UV);}
		// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
