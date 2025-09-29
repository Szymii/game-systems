class_name Graph
extends RefCounted

var points: Array[Point] = []

## Each key is a point's instance ID, each value is an array of connected point IDs.
## @example: {12345: [67890, 11111], 67890: [12345], 11111: [12345]}
var connections: Dictionary[int, Array] = {}

func add_point(point: Point) -> void:
	if point not in points:
		points.append(point)
		connections[point.get_id()] = []

func remove_point(point: Point) -> void:
	var point_id: int = point.get_id()
	if point_id not in connections:
		return
	
	var connected_points: Array = connections[point_id].duplicate()
	for connected_point_id: int in connected_points:
		remove_connection_by_id(point_id, connected_point_id)
	
	points.erase(point)
	connections.erase(point_id)

func add_connection(point_a: Point, point_b: Point) -> bool:
	if not _can_connect(point_a, point_b):
		return false
	
	var id_a: int = point_a.get_id()
	var id_b: int = point_b.get_id()
	
	var connections_a: Array = connections[id_a]
	var connections_b: Array = connections[id_b]
	connections_a.append(id_b)
	connections_b.append(id_a)
	
	return true

func remove_connection(point_a: Point, point_b: Point) -> bool:
	var id_a: int = point_a.get_id()
	var id_b: int = point_b.get_id()
	
	return remove_connection_by_id(id_a, id_b)

func remove_connection_by_id(id_a: int, id_b: int) -> bool:
	if id_a not in connections or id_b not in connections:
		return false
	
	var connections_a: Array = connections[id_a]
	var connections_b: Array = connections[id_b]
	connections_a.erase(id_b)
	connections_b.erase(id_a)
	
	return true

func get_connections(point: Point) -> Array[Point]:
	var point_id: int = point.get_id()
	if point_id not in connections:
		return []
	
	var connected_points: Array[Point] = []
	var point_connections: Array = connections[point_id]
	for connected_id: int in point_connections:
		var connected_point: Point = _find_point_by_id(connected_id)
		if connected_point:
			connected_points.append(connected_point)
	
	return connected_points

func _are_connected(point_a: Point, point_b: Point) -> bool:
	var id_a: int = point_a.get_id()
	var id_b: int = point_b.get_id()
	
	if id_a not in connections:
		return false
	
	var point_connections: Array = connections[id_a]
	return id_b in point_connections

func _can_connect(point_a: Point, point_b: Point) -> bool:
	if point_a == point_b:
		return false
	
	if _are_connected(point_a, point_b):
		return false
	
	var id_a: int = point_a.get_id()
	var id_b: int = point_b.get_id()
	
	return id_a in connections and id_b in connections

func _find_point_by_id(point_id: int) -> Point:
	for point in points:
		if point.get_id() == point_id:
			return point
	return null
