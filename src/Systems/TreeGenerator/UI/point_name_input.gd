extends TextEdit

func _ready() -> void:
	text_changed.connect(_on_text_changed)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_text_changed() -> void:
	var selected_point: Point = TreeGeneratorGlobals.get_selected_point()
	
	if selected_point:
		selected_point.set_point_name(text)

func _on_point_selected(point: Point) -> void:
	if point:
		text = point.get_point_name()