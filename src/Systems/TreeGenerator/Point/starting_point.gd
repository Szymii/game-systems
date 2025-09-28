class_name StartingPoint
extends Point

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interaction"):
		TreeGeneratorGlobals.select_point(self)
		_set_selected(true)
