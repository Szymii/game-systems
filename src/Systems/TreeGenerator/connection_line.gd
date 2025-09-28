class_name ConnectionLine
extends Line2D

var point_a: Point
var point_b: Point

func _ready() -> void:
	width = 3.0
	default_color = Color(1.0, 1.0, 1.0, 0.7)
	add_to_group("ConnectionLine")

	
func setup(from_point: Point, to_point: Point) -> void:
	point_a = from_point
	point_b = to_point
	
	_update_line_positions()

func _update_line_positions() -> void:
	if point_a and point_b:
		clear_points()
		add_point(point_a.global_position)
		add_point(point_b.global_position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_interaction"): # RMB
		var mouse_pos: Vector2 = get_global_mouse_position()
		if _is_point_on_line(mouse_pos):
			_remove_connection()

func _is_point_on_line(pos: Vector2) -> bool:
	if get_point_count() < 2:
		return false
	
	var line_start: Vector2 = get_point_position(0)
	var line_end: Vector2 = get_point_position(1)
	
	# Check if point is close to the line
	var distance_to_line: float = _distance_to_line_segment(pos, line_start, line_end)
	return distance_to_line <= width + 5.0 # Add some tolerance

func _distance_to_line_segment(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	var line_vec: Vector2 = line_end - line_start
	var point_vec: Vector2 = point - line_start
	
	var line_length_sq: float = line_vec.length_squared()
	if line_length_sq == 0.0:
		return point_vec.length()
	
	var projection: float = point_vec.dot(line_vec) / line_length_sq
	projection = clamp(projection, 0.0, 1.0)
	
	var closest_point: Vector2 = line_start + projection * line_vec
	return (point - closest_point).length()

func _remove_connection() -> void:
	if point_a and point_b:
		GlobalGraphManager.remove_connection(point_a, point_b)
		queue_free()
