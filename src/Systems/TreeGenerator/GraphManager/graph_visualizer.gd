class_name GraphVisualizer
extends RefCounted

var graph_layer: Node2D

func _init(layer: Node2D) -> void:
	graph_layer = layer

func create_connection_line(point_a: Point, point_b: Point) -> void:
	var line := ConnectionLine.new()
	line.setup(point_a, point_b)
	graph_layer.add_child(line)

func remove_connection_line(point_a: Point, point_b: Point) -> void:
	var lines := _get_all_connection_lines()
	var filtered_lines: Array[ConnectionLine] = lines.filter(func(line: ConnectionLine) -> bool:
		return (line.point_a == point_a and line.point_b == point_b) or \
			   (line.point_a == point_b and line.point_b == point_a)
	)
	
	if not filtered_lines.is_empty():
		var matching_line: ConnectionLine = filtered_lines.front()
		matching_line.queue_free()

func clear_all_visual_elements() -> void:
	var existing_points := _get_all_graph_points()
	for point in existing_points:
		point.queue_free()
	
	var existing_lines := _get_all_connection_lines()
	for line in existing_lines:
		line.queue_free()

func _get_all_connection_lines() -> Array[ConnectionLine]:
	var scene_tree := graph_layer.get_tree()
	var lines := scene_tree.get_nodes_in_group("ConnectionLine")
	var typed_lines: Array[ConnectionLine] = []
	
	for line in lines:
		if line is ConnectionLine:
			typed_lines.append(line as ConnectionLine)
	
	return typed_lines

func _get_all_graph_points() -> Array[Point]:
	var scene_tree := graph_layer.get_tree()
	var points := scene_tree.get_nodes_in_group("GraphPoint")
	var typed_points: Array[Point] = []
	
	for point in points:
		if point is Point:
			typed_points.append(point as Point)
	
	return typed_points as Array[Point]