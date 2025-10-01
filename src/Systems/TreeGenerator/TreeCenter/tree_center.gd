@tool
class_name TreeCenter
extends Node2D

@export var n_sides: int = 4:
	set(value):
		n_sides = clamp(value, 4, 12)
		queue_redraw()
		_emit_positions_changed()
@export var radius: float = 100.0:
	set(value):
		radius = max(0.1, value)
		queue_redraw()
		_emit_positions_changed()
var center: Vector2 = Vector2(0, 0)
var fill_color: Color = Color(0.173, 0.173, 0.173, 1.0)

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
		# Emit initial positions after setup
		call_deferred("_emit_positions_changed")

func _starting_point_added() -> void:
	n_sides += 2

func _starting_point_removed() -> void:
	n_sides -= 2

## Returns positions where starting points should be placed
func get_starting_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var angle_step := TAU / n_sides
	
	for i in range(n_sides):
		var angle := i * angle_step
		var point_position := center + Vector2(cos(angle), sin(angle)) * radius
		positions.append(point_position)
	
	return positions

func _emit_positions_changed() -> void:
	if not Engine.is_editor_hint():
		var positions := get_starting_positions()
		TreeGeneratorGlobals.notify_starting_positions_changed(positions)

func on_tree_save(saved_data: SavedData) -> void:
	var tree_center_data := TreeCenterSavedData.new()
	tree_center_data.n_sides = n_sides
	tree_center_data.radius = radius
	saved_data.tree_center = tree_center_data

func on_tree_load(saved_data: SavedData) -> void:
	if not saved_data.tree_center:
		return
	
	var tree_center_data: TreeCenterSavedData = saved_data.tree_center
	
	n_sides = tree_center_data.n_sides
	radius = tree_center_data.radius
