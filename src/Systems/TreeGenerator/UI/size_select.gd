extends OptionButton

func _ready() -> void:
	for point_size in PointSize.POINT_SIZE.keys() as Array[String]:
		var index: int = PointSize.POINT_SIZE[point_size]
		add_item(point_size, index)
	
	item_selected.connect(_on_option_selected)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_option_selected(index: int) -> void:
	var size_index: int = get_item_id(index)
	var selected_size: PointSize.POINT_SIZE = size_index as PointSize.POINT_SIZE
	var selected_point: Point = TreeGeneratorGlobals.get_selected_point()
	
	if selected_point:
		selected_point.set_point_size(selected_size)

func _on_point_selected(point: Point) -> void:
	if point:
		# Find the item with matching ID
		for i in get_item_count():
			if get_item_id(i) == int(point.get_point_size()):
				select(i)
				return
