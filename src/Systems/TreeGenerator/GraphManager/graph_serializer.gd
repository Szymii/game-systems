class_name GraphSerializer
extends RefCounted

func serialize_graph_to_saved_data(saved_data: SavedData, scene_tree: SceneTree) -> void:
	_serialize_points(saved_data, scene_tree)
	_serialize_connections(saved_data, scene_tree)

func deserialize_graph_from_saved_data(saved_data: SavedData, graph_layer: Node2D, visualizer: GraphVisualizer) -> Graph:
	var graph := Graph.new()
	_deserialize_points(saved_data, graph_layer, graph)
	_deserialize_connections(saved_data, graph, visualizer)
	return graph

func _serialize_points(saved_data: SavedData, scene_tree: SceneTree) -> void:
	var points := scene_tree.get_nodes_in_group("GraphPoint")
	
	for point in points as Array[Point]:
		var point_saved_data := PointSavedData.new()
		
		point_saved_data.is_starting_point = point.is_starting_point
		point_saved_data.scene_path = point.scene_file_path
		point_saved_data.point_id = point.get_id()
		point_saved_data.point_name = point.get_point_name()
		point_saved_data.position = point.global_position
		point_saved_data.texture_path = point.get_texture_data().path
		point_saved_data.texture_name = point.get_texture_data().texture_name
		point_saved_data.size = point.get_point_size()
		point_saved_data.stats = point.get_stats().duplicate()
		point_saved_data.rules = point.get_rules().duplicate()
		point_saved_data.skills = point.get_skills().duplicate()
		
		saved_data.points.append(point_saved_data)

func _serialize_connections(saved_data: SavedData, scene_tree: SceneTree) -> void:
	var lines := scene_tree.get_nodes_in_group("ConnectionLine")
	
	for line in lines as Array[ConnectionLine]:
		var line_saved_data := ConnectionLineSaveData.new()
		
		line_saved_data.point_a_id = line.point_a.get_id()
		line_saved_data.point_b_id = line.point_b.get_id()
		
		saved_data.connections.append(line_saved_data)

func _deserialize_points(saved_data: SavedData, graph_layer: Node2D, graph: Graph) -> void:
	for point_data in saved_data.points:
		var scene := load(point_data.scene_path) as PackedScene
		var point := scene.instantiate() as Point
		
		graph_layer.add_child(point)
		
		point.set_id(point_data.point_id)
		point.set_point_name(point_data.point_name)
		point.global_position = point_data.position
		point.set_point_texture(PointTextureData.new(point_data.texture_path, point_data.texture_name))
		point.set_point_size(point_data.size)
		point.set_stats(point_data.stats.duplicate())
		point.set_rules(point_data.rules.duplicate())
		point.set_skills(point_data.skills.duplicate())
		
		graph.add_point(point)

func _deserialize_connections(saved_data: SavedData, graph: Graph, visualizer: GraphVisualizer) -> void:
	for connection_data in saved_data.connections:
		var point_a: Point = graph.find_point_by_id(connection_data.point_a_id)
		var point_b: Point = graph.find_point_by_id(connection_data.point_b_id)
		
		if point_a and point_b:
			graph.add_connection(point_a, point_b)
			if visualizer:
				visualizer.create_connection_line(point_a, point_b)
