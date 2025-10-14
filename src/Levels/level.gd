class_name Level
extends Node

@onready var spawn_point: Marker2D = %SpawnPoint

func get_spawn_position() -> Vector2:
	if not spawn_point:
		push_error("Spawn point is missing")
	return spawn_point.global_position
