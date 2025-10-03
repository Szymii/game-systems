extends Node

signal save_tree_signal()
signal load_tree_signal()

signal add_starting_point_signal()
signal remove_starting_point_signal()
signal point_selected_signal(point: Point)
signal point_deselected_signal()
signal register_point_in_graph_signal(point: Point)
signal deregister_point_from_graph_signal(point: Point)
signal connect_points_signal(point_a: Point, point_b: Point)
signal remove_connection_signal(point_a: Point, point_b: Point)
signal spawn_point_requested_signal(position: Vector2)
signal starting_positions_changed_signal(positions: Array[Vector2])
signal point_drag_started_signal(point: Point)
signal point_drag_ended_signal(point: Point, final_position: Vector2)
signal multi_select_toggled_signal(point: Point, is_added: bool)

var selected_point: Point = null
var is_dragging_point: bool = false
var multi_selected_points: Array[Point] = []

func save_tree() -> void:
	save_tree_signal.emit()

func load_tree() -> void:
	load_tree_signal.emit()

func add_starting_point() -> void:
	add_starting_point_signal.emit()

func remove_starting_point() -> void:
	remove_starting_point_signal.emit()

func select_point(point: Point) -> void:
	if selected_point != point:
		selected_point = point
		point_selected_signal.emit(point)

func deselect_point() -> void:
	selected_point = null
	point_deselected_signal.emit()

func register_point_in_graph(point: Point) -> void:
	register_point_in_graph_signal.emit(point)

func deregister_point_from_graph(point: Point) -> void:
	deregister_point_from_graph_signal.emit(point)

func connect_points(point_a: Point, point_b: Point) -> void:
	connect_points_signal.emit(point_a, point_b)

func remove_connection(point_a: Point, point_b: Point) -> void:
	remove_connection_signal.emit(point_a, point_b)

func request_spawn_point(position: Vector2) -> void:
	spawn_point_requested_signal.emit(position)

func notify_starting_positions_changed(positions: Array[Vector2]) -> void:
	starting_positions_changed_signal.emit(positions)

func get_selected_point() -> Point:
	return selected_point

func start_point_drag(point: Point) -> void:
	is_dragging_point = true
	point_drag_started_signal.emit(point)

func end_point_drag(point: Point, final_position: Vector2) -> void:
	is_dragging_point = false
	point_drag_ended_signal.emit(point, final_position)

func toggle_multi_select(point: Point) -> void:
	if point in multi_selected_points:
		multi_selected_points.erase(point)
		multi_select_toggled_signal.emit(point, false)
	else:
		multi_selected_points.append(point)
		multi_select_toggled_signal.emit(point, true)

func clear_multi_selection() -> void:
	for point in multi_selected_points:
		if is_instance_valid(point):
			multi_select_toggled_signal.emit(point, false)
	multi_selected_points.clear()

func get_multi_selected_points() -> Array[Point]:
	return multi_selected_points
