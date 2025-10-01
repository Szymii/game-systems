class_name GraphManager
extends Node

@onready var graph_layer: Node2D = %GraphLayer
var graph: Graph
var graph_visualizer: GraphVisualizer
var graph_serializer: GraphSerializer

func _ready() -> void:
	graph = Graph.new()
	graph_visualizer = GraphVisualizer.new(graph_layer)
	graph_serializer = GraphSerializer.new()
	
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
		graph_visualizer.remove_connection_line(point, connected_point)
	
	graph.remove_point(point)

func _try_connect_points(point_a: Point, point_b: Point) -> bool:
	if graph.add_connection(point_a, point_b):
		graph_visualizer.create_connection_line(point_a, point_b)
		return true
	return false

func _remove_connection(point_a: Point, point_b: Point) -> bool:
	if graph.remove_connection(point_a, point_b):
		graph_visualizer.remove_connection_line(point_a, point_b)
		return true
	return false

func on_tree_save(saved_data: SavedData) -> void:
	graph_serializer.serialize_graph_to_saved_data(saved_data, get_tree())

func on_tree_load(saved_data: SavedData) -> void:
	graph_visualizer.clear_all_visual_elements()
	graph = graph_serializer.deserialize_graph_from_saved_data(saved_data, graph_layer, graph_visualizer)
