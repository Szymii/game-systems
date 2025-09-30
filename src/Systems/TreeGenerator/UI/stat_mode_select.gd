extends OptionButton

func _ready() -> void:
	for stat_mode_type in StatMode.STAT_MODE.keys() as Array[String]:
		var index: int = StatMode.STAT_MODE[stat_mode_type]
		add_item(stat_mode_type, index)
	
	item_selected.connect(_on_option_selected)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_option_selected(index: int) -> void:
	var stat_mode_index: int = get_item_id(index)
	var selected_stat_mode: StatMode.STAT_MODE = stat_mode_index as StatMode.STAT_MODE
	var selected_point: Point = TreeGeneratorGlobals.get_selected_point()
	
	if selected_point:
		selected_point.set_stat_mode(selected_stat_mode)

func _on_point_selected(point: Point) -> void:
	if point:
		# Find the item with matching ID
		for i in get_item_count():
			if get_item_id(i) == int(point.get_stat_mode()):
				select(i)
				return
