class_name Point
extends Node2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var selection_ring: Sprite2D = %SelectionRing
@onready var collision: CollisionShape2D = %CollisionShape2D

const TEXTURE_DEFAULT_SIZE := 64.0
var is_selected: bool = false

var point_id: int
var texture_data: PointTextureData = PointTextureData.new("res://assets/tree/point_textures/empty.svg", "Empty")
var size: PointSize.POINT_SIZE = PointSize.POINT_SIZE.SM
var stats: Array[PointStat] = []

func _ready() -> void:
	point_id = self.get_instance_id()
	set_point_size(size)
	set_point_texture(texture_data)
	_set_selected(false)
	
	TreeGeneratorGlobals.register_point_in_graph(self)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interaction"):
		TreeGeneratorGlobals.select_point(self)
		_set_selected(true)
	if event.is_action_pressed("cancel_interaction"):
		remove_self()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("alt_interaction"): # "F" key
		var selected_point: Point = TreeGeneratorGlobals.get_selected_point()
		if selected_point and selected_point != self:
			var mouse_pos: Vector2 = get_global_mouse_position()
			if _is_mouse_over_point(mouse_pos):
				TreeGeneratorGlobals.connect_points(selected_point, self)
				TreeGeneratorGlobals.select_point(self)
				_set_selected(true)
				get_viewport().set_input_as_handled()

func remove_self() -> void:
	if TreeGeneratorGlobals.get_selected_point() == self:
		TreeGeneratorGlobals.deselect_point()

	TreeGeneratorGlobals.deregister_point_from_graph(self)
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
	
	var ring_scale_factor: float = scale_factor * 1.2
	selection_ring.scale = Vector2(ring_scale_factor, ring_scale_factor)

func set_point_texture(_texture_data: PointTextureData) -> void:
	if _texture_data and sprite:
		sprite.texture = _texture_data.texture
		texture_data = _texture_data

func add_stat(new_stat: PointStat) -> void:
	stats.append(new_stat)

func remove_stat(index: int) -> void:
	if index >= 0 and index < stats.size():
		stats.remove_at(index)

func update_stat(index: int, new_stat: PointStat) -> void:
	if index >= 0 and index < stats.size():
		stats[index] = new_stat

func get_stats() -> Array[PointStat]:
	return stats

func set_stats(new_stats: Array[PointStat]) -> void:
	stats = new_stats

func clear_stats() -> void:
	stats.clear()

func set_id(new_id: int) -> void:
	point_id = new_id

func get_texture_data() -> PointTextureData:
	return texture_data

func get_collision_radius() -> float:
	var shape: CircleShape2D = collision.shape
	return shape.radius

func get_point_size() -> PointSize.POINT_SIZE:
	return size

func get_id() -> int:
	return point_id

func _set_selected(selected: bool) -> void:
	is_selected = selected
	if selection_ring:
		selection_ring.visible = selected

func _on_point_selected(point: Point) -> void:
	if point != self:
		_set_selected(false)

func _is_mouse_over_point(mouse_pos: Vector2) -> bool:
	var distance: float = global_position.distance_to(mouse_pos)
	return distance <= get_collision_radius()
