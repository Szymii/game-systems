class_name Point
extends Node2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var selection_ring: Sprite2D = %SelectionRing
@onready var collision: CollisionShape2D = %CollisionShape2D

const TEXTURE_DEFAULT_SIZE := 64.0

var is_selected: bool = false
var is_multi_selected: bool = false

var point_id: int
var point_name: String = ""
var texture_data: PointTextureData = PointTextureData.new("res://assets/tree/point_textures/empty.svg", "Empty")
var size: PointSize.POINT_SIZE = PointSize.POINT_SIZE.SM

var drag_handler: PointDragHandler
var stats_manager: PointStatsManager

func _ready() -> void:
	point_id = self.get_instance_id()
	drag_handler = PointDragHandler.new(self)
	stats_manager = PointStatsManager.new()
	
	set_point_size(size)
	set_point_texture(texture_data)
	_set_selected(false)
	
	TreeGeneratorGlobals.register_point_in_graph(self)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)
	TreeGeneratorGlobals.multi_select_toggled_signal.connect(_on_multi_select_toggled)

func _process(_delta: float) -> void:
	drag_handler.process(_delta)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interaction"):
		if Input.is_key_pressed(KEY_CTRL):
			TreeGeneratorGlobals.toggle_multi_select(self)
		else:
			var was_multi_selected := is_multi_selected
			if not was_multi_selected:
				TreeGeneratorGlobals.clear_multi_selection()
			TreeGeneratorGlobals.select_point(self)
			_set_selected(true)
			drag_handler.prepare_drag(was_multi_selected)
	
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
	stats_manager.add_stat(new_stat)

func remove_stat(index: int) -> void:
	stats_manager.remove_stat(index)

func update_stat(index: int, new_stat: PointStat) -> void:
	stats_manager.update_stat(index, new_stat)

func get_stats() -> Array[PointStat]:
	return stats_manager.get_stats()

func set_stats(new_stats: Array[PointStat]) -> void:
	stats_manager.set_stats(new_stats)

func clear_stats() -> void:
	stats_manager.clear_stats()

func set_id(new_id: int) -> void:
	point_id = new_id

func set_point_name(new_name: String) -> void:
	point_name = new_name

func get_point_name() -> String:
	return point_name

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
	_update_selection_visual()

func _update_selection_visual() -> void:
	if not selection_ring:
		return
	
	if is_multi_selected:
		selection_ring.visible = true
		selection_ring.modulate = Color.YELLOW
	elif is_selected:
		selection_ring.visible = true
		selection_ring.modulate = Color.WHITE
	else:
		selection_ring.visible = false
		selection_ring.modulate = Color.WHITE

func _on_point_selected(point: Point) -> void:
	if point != self:
		is_selected = false
		_update_selection_visual()

func _is_mouse_over_point(mouse_pos: Vector2) -> bool:
	var distance: float = global_position.distance_to(mouse_pos)
	return distance <= get_collision_radius()

func _on_multi_select_toggled(point: Point, is_added: bool) -> void:
	if point == self:
		is_multi_selected = is_added
		_update_selection_visual()
