extends VBoxContainer


@onready var add_stat_button: Button = %AddStatButton
@onready var stats_container: VBoxContainer = %StatsContainer

var current_point: Point = null

func _ready() -> void:
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)
	TreeGeneratorGlobals.point_deselected_signal.connect(_on_point_deselected)
	
	if add_stat_button:
		add_stat_button.pressed.connect(_on_add_stat_pressed)

func _on_point_selected(point: Point) -> void:
	current_point = point
	_refresh_stats_list()

func _on_point_deselected() -> void:
	current_point = null
	_clear_stats_list()

func _refresh_stats_list() -> void:
	_clear_stats_list()
	
	if not current_point:
		return
	
	var stats := current_point.get_stats()
	for i in range(stats.size()):
		_create_stat_item(i, stats[i])

func _clear_stats_list() -> void:
	if stats_container:
		for child in stats_container.get_children():
			child.queue_free()

func _create_stat_item(index: int, stat: PointStat) -> void:
	var stat_item := VBoxContainer.new()
	stats_container.add_child(stat_item)
	
	var header_row := HBoxContainer.new()
	stat_item.add_child(header_row)
	
	var stat_label := Label.new()
	stat_label.text = "Stat %d:" % (index + 1)
	stat_label.custom_minimum_size = Vector2(60, 0)
	header_row.add_child(stat_label)
	
	var remove_button := Button.new()
	remove_button.text = "X"
	remove_button.custom_minimum_size = Vector2(30, 0)
	remove_button.pressed.connect(func() -> void: _on_remove_stat_pressed(index))
	header_row.add_child(remove_button)
	
	var main_row := HBoxContainer.new()
	stat_item.add_child(main_row)
	
	var stat_select := OptionButton.new()
	stat_select.custom_minimum_size = Vector2(80, 0)
	for stat_type in Stat.STAT.keys() as Array[String]:
		var stat_id: int = Stat.STAT[stat_type]
		stat_select.add_item(stat_type, stat_id)
	for i in stat_select.get_item_count():
		if stat_select.get_item_id(i) == int(stat.stat):
			stat_select.select(i)
			break
	stat_select.item_selected.connect(func(idx: int) -> void: _on_stat_changed(index, stat_select.get_item_id(idx)))
	main_row.add_child(stat_select)
	
	var mode_select := OptionButton.new()
	mode_select.custom_minimum_size = Vector2(120, 0)
	for mode_type in StatMode.STAT_MODE.keys() as Array[String]:
		var mode_id: int = StatMode.STAT_MODE[mode_type]
		mode_select.add_item(mode_type, mode_id)
	for i in mode_select.get_item_count():
		if mode_select.get_item_id(i) == int(stat.stat_mode):
			mode_select.select(i)
			break
	mode_select.item_selected.connect(func(idx: int) -> void: _on_stat_mode_changed(index, mode_select.get_item_id(idx)))
	main_row.add_child(mode_select)
	
	var value_edit := LineEdit.new()
	value_edit.text = str(stat.value)
	value_edit.custom_minimum_size = Vector2(60, 0)
	value_edit.placeholder_text = "Value"
	value_edit.text_submitted.connect(func(_text: String) -> void: _on_value_changed(index, value_edit.text))
	value_edit.focus_exited.connect(func() -> void: _on_value_changed(index, value_edit.text))
	main_row.add_child(value_edit)
	
	var condition_row := HBoxContainer.new()
	stat_item.add_child(condition_row)
	
	var condition_label := Label.new()
	condition_label.text = "Condition:"
	condition_label.custom_minimum_size = Vector2(80, 0)
	condition_row.add_child(condition_label)
	
	var condition_select := OptionButton.new()
	condition_select.custom_minimum_size = Vector2(150, 0)
	for condition_type in StatCondition.CONDITION.keys() as Array[String]:
		var condition_id: int = StatCondition.CONDITION[condition_type]
		condition_select.add_item(condition_type, condition_id)
	for i in condition_select.get_item_count():
		if condition_select.get_item_id(i) == int(stat.condition):
			condition_select.select(i)
			break
	condition_select.item_selected.connect(func(idx: int) -> void: _on_condition_changed(index, condition_select.get_item_id(idx)))
	condition_row.add_child(condition_select)
	
	var separator := HSeparator.new()
	stat_item.add_child(separator)

func _on_add_stat_pressed() -> void:
	if current_point:
		var new_stat := PointStat.new(Stat.STAT.DEX, StatMode.STAT_MODE.FLAT, 0, StatCondition.CONDITION.NONE)
		current_point.add_stat(new_stat)
		_refresh_stats_list()

func _on_remove_stat_pressed(index: int) -> void:
	if current_point:
		current_point.remove_stat(index)
		_refresh_stats_list()

func _on_stat_changed(index: int, stat_id: int) -> void:
	if current_point:
		var stats := current_point.get_stats()
		if index >= 0 and index < stats.size():
			stats[index].stat = stat_id as Stat.STAT

func _on_stat_mode_changed(index: int, mode_id: int) -> void:
	if current_point:
		var stats := current_point.get_stats()
		if index >= 0 and index < stats.size():
			stats[index].stat_mode = mode_id as StatMode.STAT_MODE

func _on_value_changed(index: int, value_text: String) -> void:
	if current_point:
		var value_int: int = int(value_text)
		var stats := current_point.get_stats()
		if index >= 0 and index < stats.size():
			stats[index].value = value_int

func _on_condition_changed(index: int, condition_id: int) -> void:
	if current_point:
		var stats := current_point.get_stats()
		if index >= 0 and index < stats.size():
			stats[index].condition = condition_id as StatCondition.CONDITION
