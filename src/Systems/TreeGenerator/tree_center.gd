@tool
extends Node2D

# step = 2
@export var n_sides: int = 4:
	set(value):
		if (value % 2 != 0 and n_sides < value):
			n_sides = clamp(value + 1, 4, 12)
		else:
			n_sides = clamp(value - 1, 4, 12)
		queue_redraw()
		_update_starting_points()
@export var radius: float = 100.0:
	set(value):
		radius = max(0.1, value)
		queue_redraw()
		_update_starting_points()
@export var center: Vector2 = Vector2(0, 0):
	set(value):
		center = value
		queue_redraw()
		_update_starting_points()
@export var fill_color: Color = Color(0.173, 0.173, 0.173, 1.0):
	set(value):
		fill_color = value
		queue_redraw()
@export var starting_point_scene: PackedScene

var starting_points: Array[Node2D] = []

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
		_spawn_starting_points()

func _starting_point_added() -> void:
	n_sides += 1

func _starting_point_removed() -> void:
	n_sides -= 1

func _spawn_starting_points() -> void:
	if Engine.is_editor_hint() or not starting_point_scene:
		return
	
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
		return
	
	var angle_step := TAU / n_sides
	
	for i in range(min(starting_points.size(), n_sides)):
		var angle := i * angle_step
		var point_position := center + Vector2(cos(angle), sin(angle)) * radius
		starting_points[i].global_position = point_position

func _clear_starting_points() -> void:
	for point: StartingPoint in starting_points:
		if is_instance_valid(point):
			point.remove_self()
	starting_points.clear()
