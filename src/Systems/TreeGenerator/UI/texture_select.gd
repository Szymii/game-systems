extends OptionButton

@export var texture_res: PointTextures

func _ready() -> void:
	if texture_res and texture_res.textures:
		for i in texture_res.textures.size():
			var tex := texture_res.textures[i]
			var texture_name := tex.texture_name if tex.texture_name else "Texture %d" % i
			var scaled_texture := _resize_texture(tex.texture, 16, 16)
			add_icon_item(scaled_texture, texture_name, i)
	item_selected.connect(_on_option_selected)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_option_selected(index: int) -> void:
	var selected_texture_data := texture_res.textures[index]
	var selected_point := TreeGeneratorGlobals.get_selected_point()

	if selected_point:
		selected_point.set_point_texture(selected_texture_data)

func _on_point_selected(point: Point) -> void:
	var point_texture_data := point.get_texture_data()
	
	var index := texture_res.textures.find_custom(
		func(texture_data: PointTextureData) -> bool: return texture_data.texture_name == point_texture_data.texture_name
	)
	
	if index != -1:
		select(index)

func _resize_texture(texture: Texture2D, width: int, height: int) -> ImageTexture:
	if not texture:
		return null
	var image := texture.get_image()
	if not image:
		return null
	image.resize(width, height, Image.INTERPOLATE_BILINEAR)
	var new_texture := ImageTexture.create_from_image(image)
	return new_texture
