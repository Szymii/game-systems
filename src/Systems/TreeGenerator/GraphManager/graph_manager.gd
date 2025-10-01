class_name GraphManager
extends Node

@export var starting_point_scene: PackedScene

@onready var graph_layer: Node2D = %GraphLayer
@onready var tree_center: TreeCenter = %TreeCenter

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
	
	# Connect to TreeCenter for starting point management (deferred to ensure proper initialization)
	call_deferred("_connect_to_tree_center")
	call_deferred("_initialize_starting_points")

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

func _connect_to_tree_center() -> void:
	if tree_center and tree_center.has_signal("starting_positions_changed"):
		tree_center.starting_positions_changed.connect(_on_starting_positions_changed)

func _initialize_starting_points() -> void:
	if tree_center and tree_center.has_method("get_starting_positions"):
		var positions: Array[Vector2] = tree_center.get_starting_positions()
		_on_starting_positions_changed(positions)

func _on_starting_positions_changed(positions: Array[Vector2]) -> void:
	_clear_starting_points()
	_create_starting_points(positions)

func _clear_starting_points() -> void:
	var starting_points := get_tree().get_nodes_in_group("GraphStartingPoint")
	for point in starting_points:
		if is_instance_valid(point):
			(point as Point).remove_self()

func _create_starting_points(positions: Array[Vector2]) -> void:
	for position in positions:
		var starting_point: StartingPoint = starting_point_scene.instantiate()
		starting_point.global_position = position
		graph_layer.add_child(starting_point)

func get_starting_points() -> Array[StartingPoint]:
	var starting_points := get_tree().get_nodes_in_group("GraphStartingPoint")
	var typed_points: Array[StartingPoint] = []
	
	for point in starting_points:
		if point is StartingPoint:
			typed_points.append(point as StartingPoint)
	
	return typed_points
