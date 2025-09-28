extends TextEdit

func _ready() -> void:
	text_changed.connect(_on_text_changed)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_text_changed() -> void:
	var selected_point: Point = TreeGeneratorGlobals.get_selected_point()
	
	if selected_point:
		var value_int: int = text.to_int()
		selected_point.set_value(value_int)

func _on_point_selected(point: Point) -> void:
	if point:
		text = str(point.get_value())
