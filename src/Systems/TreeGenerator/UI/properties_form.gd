extends VBoxContainer

func _ready() -> void:
	visible = false
	TreeGeneratorGlobals.point_selected_signal.connect(_on_selection_change)
	TreeGeneratorGlobals.point_deselected_signal.connect(_on_point_deselected)

func _on_selection_change(point: Point) -> void:
	if point:
		visible = true
	else:
		visible = false

func _on_point_deselected() -> void:
	visible = false
