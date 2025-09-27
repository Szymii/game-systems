@tool
class_name GridManager
extends Node2D

var cell_size: float = 60.0
@export var point_scene: PackedScene
@export var grid_width: int = 10:
	set(value):
		grid_width = max(7, value)
		queue_redraw()
@export var grid_height: int = 10:
	set(value):
		grid_height = max(7, value)
		queue_redraw()

func _get_grid_offset() -> Vector2:
	var total_width := grid_width * cell_size
	var total_height := grid_height * cell_size
	return Vector2(-total_width * 0.5, -total_height * 0.5)

## @desc There is 4x4 gap in the center of the grid
func _get_center_gap_bounds() -> Dictionary[String, float]:
	var gap_size := 4.0
	var center_x := grid_width / 2.0
	var center_y := grid_height / 2.0
	
	return {
		"left": center_x - gap_size / 2.0,
		"right": center_x + gap_size / 2.0,
		"top": center_y - gap_size / 2.0,
		"bottom": center_y + gap_size / 2.0
	}

func _draw() -> void:
	const line_color := Color(0.173, 0.173, 0.173, 0.6)
	var gap_bounds := _get_center_gap_bounds()
	var offset := _get_grid_offset()
	
	for x in range(grid_width + 1):
		if x > gap_bounds.left and x < gap_bounds.right:
			if gap_bounds.top >= 0:
				var start := Vector2(x * cell_size, 0) + offset
				var end := Vector2(x * cell_size, gap_bounds.top * cell_size) + offset
				draw_line(start, end, line_color, 1.0, true)
			
			if gap_bounds.bottom < grid_height:
				var start := Vector2(x * cell_size, gap_bounds.bottom * cell_size) + offset
				var end := Vector2(x * cell_size, grid_height * cell_size) + offset
				draw_line(start, end, line_color, 1.0, true)
		else:
			var start := Vector2(x * cell_size, 0) + offset
			var end := Vector2(x * cell_size, grid_height * cell_size) + offset
			draw_line(start, end, line_color, 1.0, true)
	
	for y in range(grid_height + 1):
		if y > gap_bounds.top and y < gap_bounds.bottom:
			if gap_bounds.left > 0:
				var start := Vector2(0, y * cell_size) + offset
				var end := Vector2(gap_bounds.left * cell_size, y * cell_size) + offset
				draw_line(start, end, line_color, 1.0, true)
			
			if gap_bounds.right < grid_width:
				var start := Vector2(gap_bounds.right * cell_size, y * cell_size) + offset
				var end := Vector2(grid_width * cell_size, y * cell_size) + offset
				draw_line(start, end, line_color, 1.0, true)
		else:
			var start := Vector2(0, y * cell_size) + offset
			var end := Vector2(grid_width * cell_size, y * cell_size) + offset
			draw_line(start, end, line_color, 1.0, true)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interaction"):
		var mouse_pos := get_global_mouse_position()
		_try_spawn_point(mouse_pos)

func _snap_to_nearest_grid_intersection(pos: Vector2) -> Vector2:
	var offset := _get_grid_offset()
	var grid_x: float = round((pos.x - offset.x) / cell_size) * cell_size + offset.x
	var grid_y: float = round((pos.y - offset.y) / cell_size) * cell_size + offset.y
	return Vector2(grid_x, grid_y)

func _is_in_center_gap(grid_pos: Vector2) -> bool:
	var gap_bounds := _get_center_gap_bounds()
	var offset := _get_grid_offset()
	var grid_x := (grid_pos.x - offset.x) / cell_size
	var grid_y := (grid_pos.y - offset.y) / cell_size
	return (
		grid_x > gap_bounds.left and grid_x < gap_bounds.right and
		grid_y > gap_bounds.top and grid_y < gap_bounds.bottom
	)

func _is_position_occupied(grid_pos: Vector2) -> bool:
	for point in get_tree().get_nodes_in_group("GraphPoint") as Array[Node2D]:
		if point.global_position.distance_to(grid_pos) < cell_size / 2.0:
			return true
	return false

func _try_spawn_point(pos: Vector2) -> void:
	var grid_pos := _snap_to_nearest_grid_intersection(pos)
	var is_valid := (
		grid_pos.x >= _get_grid_offset().x and 
		grid_pos.x <= _get_grid_offset().x + grid_width * cell_size and 
		grid_pos.y >= _get_grid_offset().y and 
		grid_pos.y <= _get_grid_offset().y + grid_height * cell_size
	)
	
	if is_valid and not _is_in_center_gap(grid_pos) and not _is_position_occupied(grid_pos):
		var point := point_scene.instantiate() as Node2D
		point.global_position = grid_pos
		add_child(point)
