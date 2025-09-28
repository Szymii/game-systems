class_name GraphManager
extends Node

var graph: Graph
# var connection_lines: Dictionary[String, ConnectionLine] = {}

func _ready() -> void:
	graph = Graph.new()

func add_point_to_graph(point: Point) -> void:
	graph.add_point(point)

func remove_point_from_graph(point: Point) -> void:
	# Remove all visual connections for this point
	var connections_to_remove: Array[Point] = graph.get_connections(point)
	for connected_point in connections_to_remove:
		_remove_connection_line(point, connected_point)
	
	# Remove from graph
	graph.remove_point(point)

func try_connect_points(point_a: Point, point_b: Point) -> bool:
	if graph.add_connection(point_a, point_b):
		_create_connection_line(point_a, point_b)
		return true
	return false

func remove_connection(point_a: Point, point_b: Point) -> bool:
	if graph.remove_connection(point_a, point_b):
		_remove_connection_line(point_a, point_b)
		return true
	return false

func _create_connection_line(point_a: Point, point_b: Point) -> void:
	var line := ConnectionLine.new()
	line.setup(point_a, point_b)
	
	add_child(line)

func _remove_connection_line(point_a: Point, point_b: Point) -> void:
	var lines := get_tree().get_nodes_in_group("ConnectionLine") as Array[Node]
	var filtered_lines: Array[Node] = lines.filter(func(line: ConnectionLine) -> bool:
		return (line.point_a == point_a and line.point_b == point_b) or \
			   (line.point_a == point_b and line.point_b == point_a)
	)
	
	if not filtered_lines.is_empty():
		var matching_line: ConnectionLine = filtered_lines.front()
		matching_line.queue_free()

func _get_connection_key(point_a: Point, point_b: Point) -> String:
	var id_a: int = point_a.get_instance_id()
	var id_b: int = point_b.get_instance_id()
	# Always use smaller id first to ensure consistent key
	if id_a < id_b:
		return str(id_a) + "-" + str(id_b)
	else:
		return str(id_b) + "-" + str(id_a)
