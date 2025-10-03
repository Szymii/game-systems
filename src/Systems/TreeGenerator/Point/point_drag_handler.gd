class_name PointDragHandler
extends RefCounted

const DRAG_THRESHOLD := 5.0

var point: Point
var grid_manager: GridManager

var is_dragging: bool = false
var is_preparing_drag: bool = false
var is_preparing_multi_drag: bool = false
var is_drag_follower: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

func _init(_point: Point) -> void:
	point = _point

func process(_delta: float) -> void:
	if is_preparing_drag and Input.is_action_pressed("interaction"):
		var current_mouse_pos := point.get_global_mouse_position()
		var drag_distance := drag_start_mouse_pos.distance_to(current_mouse_pos)
		
		if drag_distance > DRAG_THRESHOLD:
			if is_preparing_multi_drag:
				start_multi_drag()
			else:
				start_drag()
	
	if is_dragging and Input.is_action_pressed("interaction"):
		var new_position := point.get_global_mouse_position() + drag_offset
		point.global_position = new_position
	
	if (is_dragging or is_preparing_drag) and Input.is_action_just_released("interaction"):
		if is_dragging:
			end_drag()
		is_preparing_drag = false
		is_preparing_multi_drag = false

func prepare_drag(should_multi_drag: bool = false) -> void:
	is_preparing_drag = true
	is_preparing_multi_drag = should_multi_drag
	drag_start_mouse_pos = point.get_global_mouse_position()

func start_drag() -> void:
	is_dragging = true
	is_preparing_drag = false
	is_drag_follower = false
	original_position = point.global_position
	drag_offset = point.global_position - point.get_global_mouse_position()
	
	TreeGeneratorGlobals.start_point_drag(point)

func start_multi_drag() -> void:
	is_dragging = true
	is_preparing_drag = false
	is_drag_follower = false
	original_position = point.global_position
	drag_offset = point.global_position - point.get_global_mouse_position()
	
	TreeGeneratorGlobals.start_point_drag(point)
	
	var multi_selected := TreeGeneratorGlobals.get_multi_selected_points()
	for selected_point in multi_selected:
		if selected_point != point and is_instance_valid(selected_point) and selected_point.drag_handler:
			selected_point.drag_handler.start_drag_follower(point.get_global_mouse_position())
	
	TreeGeneratorGlobals.clear_multi_selection()

func start_drag_follower(leader_mouse_pos: Vector2) -> void:
	is_dragging = true
	is_drag_follower = true
	original_position = point.global_position
	drag_offset = point.global_position - leader_mouse_pos

func end_drag() -> void:
	if not is_dragging:
		return
	
	is_dragging = false
	
	if not grid_manager:
		grid_manager = point.get_tree().get_first_node_in_group("GridManager") as GridManager
	
	if grid_manager:
		var snapped_pos := grid_manager.snap_to_nearest_grid_intersection(point.global_position)
		var move_successful := _is_valid_drag_position(snapped_pos)
		
		if move_successful:
			point.global_position = snapped_pos
			if not is_drag_follower:
				TreeGeneratorGlobals.end_point_drag(point, snapped_pos)
		else:
			point.global_position = original_position
			if not is_drag_follower:
				TreeGeneratorGlobals.end_point_drag(point, original_position)
	
	is_drag_follower = false

func _is_valid_drag_position(target_pos: Vector2) -> bool:
	if target_pos == original_position:
		return true
	
	if not grid_manager:
		return false
	
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
	
	for other_point in point.get_tree().get_nodes_in_group("GraphPoint") as Array[Node2D]:
		if other_point != point and other_point.global_position.distance_to(target_pos) < grid_manager.cell_size / 2.0:
			return false
	
	return true
