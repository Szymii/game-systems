@tool
extends Node2D

# step = 2
@export var n_sides: int = 4:
	set(value):
		if(value % 2 != 0 and n_sides < value):
			n_sides = clamp(value + 1, 4, 12)
		else:
			n_sides = clamp(value - 1, 4, 12)
		queue_redraw()
@export var radius: float = 100.0:
	set(value):
		radius = max(0.1, value)
		queue_redraw()
@export var center: Vector2 = Vector2(0, 0):
	set(value):
		center = value
		queue_redraw()
@export var fill_color: Color = Color(0.173, 0.173, 0.173, 1.0):
	set(value):
		fill_color = value
		queue_redraw()

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
	TreeGeneratorSignals.add_starting_point_signal.connect(_starting_point_added)
	TreeGeneratorSignals.remove_starting_point_signal.connect(_starting_point_removed)

func _starting_point_added() -> void:
	n_sides += 1

func _starting_point_removed() -> void:
	n_sides -= 1
