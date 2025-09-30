@tool
extends Node2D

@export var n_sides: int = 4:
	set(value):
		n_sides = clamp(value, 4, 12)
		queue_redraw()
		_update_starting_points()
@export var radius: float = 100.0:
	set(value):
		radius = max(0.1, value)
		queue_redraw()
		_update_starting_points()
@export var starting_point_scene: PackedScene

var center: Vector2 = Vector2(0, 0)
var fill_color: Color = Color(0.173, 0.173, 0.173, 1.0)

var starting_points: Array[StartingPoint] = []

func _draw() -> void:
	if n_sides < 3:
		return
	
	var points: PackedVector2Array = []
	var angle_step := TAU / n_sides # TAU is 2*PI
	
	for i in range(n_sides):
		var angle := i * angle_step
		var point := center + Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
	
	draw_polygon(points, PackedColorArray([fill_color]))

func _ready() -> void:
	if not Engine.is_editor_hint():
		TreeGeneratorGlobals.add_starting_point_signal.connect(_starting_point_added)
		TreeGeneratorGlobals.remove_starting_point_signal.connect(_starting_point_removed)
		call_deferred("_spawn_starting_points")

func _starting_point_added() -> void:
	n_sides += 2

func _starting_point_removed() -> void:
	n_sides -= 2

func _spawn_starting_points() -> void:
	_clear_starting_points()
	
	var angle_step := TAU / n_sides
	
	for i in range(n_sides):
		var angle := i * angle_step
		var point_position := center + Vector2(cos(angle), sin(angle)) * radius
		
		var starting_point: StartingPoint = starting_point_scene.instantiate()
		starting_point.global_position = point_position
		add_child(starting_point)
		starting_points.append(starting_point)

func _update_starting_points() -> void:
	if Engine.is_editor_hint():
		return
	
	if starting_points.size() != n_sides:
		_spawn_starting_points()

func _clear_starting_points() -> void:
	for point in starting_points:
		if is_instance_valid(point):
			point.remove_self()
	starting_points.clear()

func on_tree_save(saved_data: SavedData) -> void:
	var tree_center_data := TreeCenterSavedData.new()
	tree_center_data.n_sides = n_sides
	tree_center_data.radius = radius
	
	for starting_point in starting_points:
		if is_instance_valid(starting_point):
			var point_data := PointSavedData.new()
			point_data.point_id = starting_point.get_id()
			point_data.position = starting_point.global_position
			point_data.texture_path = starting_point.get_texture_data().path
			point_data.texture_name = starting_point.get_texture_data().texture_name
			point_data.size = starting_point.get_point_size()
			point_data.stat = starting_point.get_stat()
			point_data.stat_mode = starting_point.get_stat_mode()
			point_data.value = starting_point.get_value()
			tree_center_data.starting_points.append(point_data)
	
	saved_data.tree_center = tree_center_data

func on_tree_load(saved_data: SavedData) -> void:
	if not saved_data.tree_center:
		return
	
	var tree_center_data: TreeCenterSavedData = saved_data.tree_center
	
	n_sides = tree_center_data.n_sides
	radius = tree_center_data.radius
	
	_clear_starting_points()
	
	for point_data in tree_center_data.starting_points:
		var starting_point: StartingPoint = starting_point_scene.instantiate()
		starting_point.global_position = point_data.position
		
		# Odtwórz PointTextureData z zapisanych danych
		var texture_data := PointTextureData.new(point_data.texture_path, point_data.texture_name)
		add_child(starting_point)

		starting_point.set_point_texture(texture_data)
		starting_point.set_stat(point_data.stat)
		starting_point.set_stat_mode(point_data.stat_mode)
		starting_point.set_value(point_data.value)
		starting_point.set_point_size(point_data.size)

		starting_points.append(starting_point)
