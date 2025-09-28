extends OptionButton

func _ready() -> void:
	add_item("-- Select Stat --", -1)
	add_separator()
	
	for stat_type in Stat.STAT.keys() as Array[String]:
		var index: int = Stat.STAT[stat_type]
		add_item(stat_type, index)
	
	selected = 0 # Select placeholder by default
	item_selected.connect(_on_option_selected)
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)

func _on_option_selected(index: int) -> void:
	# Skip if placeholder is selected
	if get_item_id(index) == -1:
		return
		
	var stat_index: int = get_item_id(index)
	var selected_stat: Stat.STAT = stat_index as Stat.STAT
	var selected_point: Point = TreeGeneratorGlobals.get_selected_point()
	
	if selected_point:
		selected_point.set_stat(selected_stat)

func _on_point_selected(point: Point) -> void:
	if point and point.get_stat() != null:
		# Find the item with matching ID (skip placeholder and separator)
		for i in get_item_count():
			if get_item_id(i) == int(point.get_stat()):
				select(i)
				return
	else:
		# Select placeholder if no stat is set
		select(0)
