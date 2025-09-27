class_name Point
extends Node2D

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("cancel_interaction"):
		queue_free()
