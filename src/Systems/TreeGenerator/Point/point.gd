class_name Point
extends Node2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var collision: CollisionShape2D = %CollisionShape2D
const TEXTURE_DEFAULT_SIZE := 64.0
var size: PointSize.POINT_SIZE = PointSize.POINT_SIZE.SM
var texture_data: PointTextureData = PointTextureData.new("res://assets/tree/point_textures/empty.svg", "Empty")

func _ready() -> void:
	set_point_size(size)
	set_point_texture(texture_data)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interaction"):
		TreeGeneratorGlobals.select_point(self)
	if event.is_action_pressed("cancel_interaction"):
		queue_free()

func set_point_size(new_size: PointSize.POINT_SIZE) -> void:
	var shape: CircleShape2D = collision.shape
	size = new_size
	match size:
		PointSize.POINT_SIZE.SM:
			shape.radius = 10
		PointSize.POINT_SIZE.MD:
			shape.radius = 15
		PointSize.POINT_SIZE.LG:
			shape.radius = 25
	
	var target_diameter: float = get_collision_radius() * 2
	var scale_factor: float = target_diameter / TEXTURE_DEFAULT_SIZE
	sprite.scale = Vector2(scale_factor, scale_factor)

func set_point_texture(_texture_data: PointTextureData) -> void:
	if _texture_data and sprite:
		sprite.texture = _texture_data.texture
		texture_data = _texture_data
		
		var target_diameter: float = get_collision_radius() * 2
		var scale_factor: float = target_diameter / TEXTURE_DEFAULT_SIZE
		sprite.scale = Vector2(scale_factor, scale_factor)

func get_texture_data() -> PointTextureData:
	return texture_data

func get_collision_radius() -> float:
	var shape: CircleShape2D = collision.shape
	return shape.radius

func get_point_size() -> PointSize.POINT_SIZE:
	return size
