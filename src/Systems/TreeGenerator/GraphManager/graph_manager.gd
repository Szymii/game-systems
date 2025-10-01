class_name GraphManager
extends Node

@onready var graph_layer: Node2D = %GraphLayer
var graph: Graph

func _ready() -> void:
	graph = Graph.new()
	TreeGeneratorGlobals.register_point_in_graph_signal.connect(_add_point_to_graph)
	TreeGeneratorGlobals.deregister_point_from_graph_signal.connect(_remove_point_from_graph)
	TreeGeneratorGlobals.connect_points_signal.connect(_try_connect_points)
	TreeGeneratorGlobals.remove_connection_signal.connect(_remove_connection)

func _add_point_to_graph(point: Point) -> void:
	graph.add_point(point)

func _remove_point_from_graph(point: Point) -> void:
	# Remove all visual connections for this point
	var connections_to_remove: Array[Point] = graph.get_connections(point)
	for connected_point in connections_to_remove:
		_remove_connection_line(point, connected_point)
	
	graph.remove_point(point)

func _try_connect_points(point_a: Point, point_b: Point) -> bool:
	if graph.add_connection(point_a, point_b):
		_create_connection_line(point_a, point_b)
		return true
	return false

func _remove_connection(point_a: Point, point_b: Point) -> bool:
	if graph.remove_connection(point_a, point_b):
		_remove_connection_line(point_a, point_b)
		return true
	return false

func _create_connection_line(point_a: Point, point_b: Point) -> void:
	var line := ConnectionLine.new()
	line.setup(point_a, point_b)
	
	graph_layer.add_child(line)

func _remove_connection_line(point_a: Point, point_b: Point) -> void:
	var lines := get_tree().get_nodes_in_group("ConnectionLine") as Array[Node]
	var filtered_lines: Array[Node] = lines.filter(func(line: ConnectionLine) -> bool:
		return (line.point_a == point_a and line.point_b == point_b) or \
			   (line.point_a == point_b and line.point_b == point_a)
	)
	
	if not filtered_lines.is_empty():
		var matching_line: ConnectionLine = filtered_lines.front()
		matching_line.queue_free()

func on_tree_save(saved_data: SavedData) -> void:
	var points := get_tree().get_nodes_in_group("GraphPoint") as Array[Node]
	var lines := get_tree().get_nodes_in_group("ConnectionLine") as Array[Node]
	
	for point in points as Array[Point]:
		var point_saved_data := PointSavedData.new()

		point_saved_data.scene_path = point.scene_file_path
		point_saved_data.point_id = point.get_id()
		point_saved_data.position = point.global_position
		point_saved_data.texture_path = point.get_texture_data().path
		point_saved_data.texture_name = point.get_texture_data().texture_name
		point_saved_data.size = point.get_point_size()
		point_saved_data.stat = point.get_stat()
		point_saved_data.stat_mode = point.get_stat_mode()
		point_saved_data.value = point.get_value()

		saved_data.points.append(point_saved_data)

	for line in lines as Array[ConnectionLine]:
		var line_saved_data := ConnectionLineSaveData.new()

		line_saved_data.point_a_id = line.point_a.get_id()
		line_saved_data.point_b_id = line.point_b.get_id()
			
		saved_data.connections.append(line_saved_data)

func on_tree_load(saved_data: SavedData) -> void:
	_clear_existing()
	_load_points(saved_data)
	# _load_connections(saved_data)

func _clear_existing() -> void:
	var existing_points := get_tree().get_nodes_in_group("GraphPoint") as Array[Node]
	for point in existing_points:
		point.queue_free()
	
	var existing_lines := get_tree().get_nodes_in_group("ConnectionLine") as Array[Node]
	for line in existing_lines:
		line.queue_free()

func _load_points(saved_data: SavedData) -> void:
	for point_data in saved_data.points:
		var scene := load(point_data.scene_path) as PackedScene
		var point := scene.instantiate() as Point

		graph_layer.add_child(point)
		
		point.set_id(point_data.point_id)
		point.global_position = point_data.position
		point.set_point_texture(PointTextureData.new(point_data.texture_path, point_data.texture_name))
		point.set_point_size(point_data.size)
		point.set_stat(point_data.stat)
		point.set_stat_mode(point_data.stat_mode)
		point.set_value(point_data.value)

# func _load_connections(saved_data: SavedData) -> void:
# 	for connection_data in saved_data.connections:
# 		var point_a := _find_point_by_id(connection_data.point_a_id)
# 		var point_b := _find_point_by_id(connection_data.point_b_id)
		
# 		if point_a and point_b:
# 			_try_connect_points(point_a, point_b)

# func _find_point_by_id(point_id: int) -> Point:
# 	var points := graph.points
# 	for point in points:
# 		if point.get_id() == point_id:
# 			return point
# 	return null
