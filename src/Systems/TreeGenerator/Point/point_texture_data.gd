class_name PointTextureData
extends Resource

var path: String
var texture_name: String
var texture: Texture2D

func _init(_path: String, _texture_name: String) -> void:
	path = _path
	texture_name = _texture_name
	if ResourceLoader.exists(_path):
		texture = load(_path) as Texture2D
	else:
		push_error("Failed to load SVG: %s" % _path)
