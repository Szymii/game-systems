extends VBoxContainer

func _ready() -> void:
	visible = false
	TreeGeneratorGlobals.point_selected_signal.connect(_on_selection_change)

func _on_selection_change(point: Point) -> void:
	if point:
		visible = true
	else:
		visible = false
