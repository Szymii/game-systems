extends OptionButton

func _ready() -> void:
	for point_size in PointSize.POINT_SIZE.keys() as Array[String]:
		var index:int = PointSize.POINT_SIZE[point_size]
		add_item(point_size, index)
	
	item_selected.connect(_on_option_selected)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_option_selected(index: int) -> void:
	var selected_size: PointSize.POINT_SIZE = PointSize.POINT_SIZE[PointSize.POINT_SIZE.keys()[index]]
	var selected_point := TreeGeneratorGlobals.get_selected_point()
	
	if selected_point:
		selected_point.set_point_size(selected_size)

func _on_point_selected(point: Point) -> void:
	if point:
		select(point.get_point_size())
