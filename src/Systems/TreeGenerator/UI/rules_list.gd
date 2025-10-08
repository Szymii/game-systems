extends VBoxContainer


@onready var add_rule_button: Button = %AddRuleButton
@onready var rules_container: VBoxContainer = %RulesContainer

var current_point: Point = null

func _ready() -> void:
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)
	TreeGeneratorGlobals.point_deselected_signal.connect(_on_point_deselected)
	
	if add_rule_button:
		add_rule_button.pressed.connect(_on_add_rule_pressed)

func _on_point_selected(point: Point) -> void:
	current_point = point
	_refresh_rules_list()

func _on_point_deselected() -> void:
	current_point = null
	_clear_rules_list()

func _refresh_rules_list() -> void:
	_clear_rules_list()
	
	if not current_point:
		return
	
	var rules := current_point.get_rules()
	for i in range(rules.size()):
		_create_rule_item(i, rules[i])

func _clear_rules_list() -> void:
	if rules_container:
		for child in rules_container.get_children():
			child.queue_free()

func _create_rule_item(index: int, rule: PointRule) -> void:
	var rule_item := HBoxContainer.new()
	rules_container.add_child(rule_item)
	
	var rule_label := Label.new()
	rule_label.text = "Rule %d:" % (index + 1)
	rule_label.custom_minimum_size = Vector2(60, 0)
	rule_item.add_child(rule_label)
	
	var rule_select := OptionButton.new()
	rule_select.custom_minimum_size = Vector2(200, 0)
	for rule_type in Rule.RULE.keys() as Array[String]:
		var rule_id: int = Rule.RULE[rule_type]
		rule_select.add_item(rule_type, rule_id)
	for i in rule_select.get_item_count():
		if rule_select.get_item_id(i) == int(rule.rule):
			rule_select.select(i)
			break
	rule_select.item_selected.connect(func(idx: int) -> void: _on_rule_changed(index, rule_select.get_item_id(idx)))
	rule_item.add_child(rule_select)
	
	var value_edit := LineEdit.new()
	value_edit.text = str(rule.value)
	value_edit.custom_minimum_size = Vector2(60, 0)
	value_edit.placeholder_text = "Value"
	value_edit.text_submitted.connect(func(_text: String) -> void: _on_value_changed(index, value_edit.text))
	value_edit.focus_exited.connect(func() -> void: _on_value_changed(index, value_edit.text))
	rule_item.add_child(value_edit)
	
	var remove_button := Button.new()
	remove_button.text = "X"
	remove_button.custom_minimum_size = Vector2(30, 0)
	remove_button.pressed.connect(func() -> void: _on_remove_rule_pressed(index))
	rule_item.add_child(remove_button)

func _on_add_rule_pressed() -> void:
	if current_point:
		var new_rule := PointRule.new(Rule.RULE.DAMAGE_TAKEN_AS_MANA, 0)
		current_point.add_rule(new_rule)
		_refresh_rules_list()

func _on_remove_rule_pressed(index: int) -> void:
	if current_point:
		current_point.remove_rule(index)
		_refresh_rules_list()

func _on_rule_changed(index: int, rule_id: int) -> void:
	if current_point:
		var rules := current_point.get_rules()
		if index >= 0 and index < rules.size():
			rules[index].rule = rule_id as Rule.RULE

func _on_value_changed(index: int, value_text: String) -> void:
	if current_point:
		var value_int: int = int(value_text)
		var rules := current_point.get_rules()
		if index >= 0 and index < rules.size():
			rules[index].value = value_int
