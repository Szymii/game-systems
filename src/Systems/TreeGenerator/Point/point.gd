class_name Point
extends Node2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var selection_ring: Sprite2D = %SelectionRing
@onready var collision: CollisionShape2D = %CollisionShape2D

const TEXTURE_DEFAULT_SIZE := 64.0
const DRAG_THRESHOLD := 5.0

var is_selected: bool = false
var is_dragging: bool = false
var is_multi_selected: bool = false
var is_preparing_drag: bool = false
var is_preparing_multi_drag: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var is_drag_follower: bool = false

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
	TreeGeneratorGlobals.multi_select_toggled_signal.connect(_on_multi_select_toggled)

func _process(_delta: float) -> void:
	if is_preparing_drag and Input.is_action_pressed("interaction"):
		var current_mouse_pos := get_global_mouse_position()
		var drag_distance := drag_start_mouse_pos.distance_to(current_mouse_pos)
		
		if drag_distance > DRAG_THRESHOLD:
			if is_preparing_multi_drag:
				_start_multi_drag()
			else:
				_start_drag()
	
	if is_dragging and Input.is_action_pressed("interaction"):
		var new_position := get_global_mouse_position() + drag_offset
		global_position = new_position
	
	if (is_dragging or is_preparing_drag) and Input.is_action_just_released("interaction"):
		if is_dragging:
			_end_drag()
		is_preparing_drag = false
		is_preparing_multi_drag = false

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
			_prepare_drag(was_multi_selected)
	
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

func _prepare_drag(should_multi_drag: bool = false) -> void:
	is_preparing_drag = true
	is_preparing_multi_drag = should_multi_drag
	drag_start_mouse_pos = get_global_mouse_position()

func _start_drag() -> void:
	is_dragging = true
	is_preparing_drag = false
	is_drag_follower = false
	original_position = global_position
	drag_offset = global_position - get_global_mouse_position()
	
	TreeGeneratorGlobals.start_point_drag(self)

func _start_multi_drag() -> void:
	is_dragging = true
	is_preparing_drag = false
	is_drag_follower = false
	original_position = global_position
	drag_offset = global_position - get_global_mouse_position()
	
	TreeGeneratorGlobals.start_point_drag(self)
	
	var multi_selected := TreeGeneratorGlobals.get_multi_selected_points()
	for point in multi_selected:
		if point != self and is_instance_valid(point):
			point._start_drag_follower(get_global_mouse_position())
	
	TreeGeneratorGlobals.clear_multi_selection()

func _start_drag_follower(leader_mouse_pos: Vector2) -> void:
	is_dragging = true
	is_drag_follower = true
	original_position = global_position
	drag_offset = global_position - leader_mouse_pos

func _end_drag() -> void:
	if not is_dragging:
		return
	
	is_dragging = false
	
	var grid_manager: GridManager = get_tree().get_first_node_in_group("GridManager")
	if grid_manager:
		var snapped_pos := grid_manager.snap_to_nearest_grid_intersection(global_position)
		var move_successful := _is_valid_drag_position(snapped_pos, grid_manager)
		
		if move_successful:
			global_position = snapped_pos
			if not is_drag_follower:
				TreeGeneratorGlobals.end_point_drag(self, snapped_pos)
		else:
			global_position = original_position
			if not is_drag_follower:
				TreeGeneratorGlobals.end_point_drag(self, original_position)
	
	is_drag_follower = false

func _is_valid_drag_position(target_pos: Vector2, grid_manager: GridManager) -> bool:
	if target_pos == original_position:
		return true
	
	var gap_bounds := grid_manager._get_center_gap_bounds()
	var offset := grid_manager._get_grid_offset()
	var grid_x := (target_pos.x - offset.x) / grid_manager.cell_size
	var grid_y := (target_pos.y - offset.y) / grid_manager.cell_size
	
	var is_within_bounds := (
		target_pos.x >= offset.x and
		target_pos.x <= offset.x + grid_manager.grid_width * grid_manager.cell_size and
		target_pos.y >= offset.y and
		target_pos.y <= offset.y + grid_manager.grid_height * grid_manager.cell_size
	)
	
	var is_in_gap := (
		grid_x > gap_bounds.left and grid_x < gap_bounds.right and
		grid_y > gap_bounds.top and grid_y < gap_bounds.bottom
	)
	
	if not is_within_bounds or is_in_gap:
		return false
	
	for point in get_tree().get_nodes_in_group("GraphPoint") as Array[Node2D]:
		if point != self and point.global_position.distance_to(target_pos) < grid_manager.cell_size / 2.0:
			return false
	
	return true

func _on_multi_select_toggled(point: Point, is_added: bool) -> void:
	if point == self:
		is_multi_selected = is_added
		_update_selection_visual()
