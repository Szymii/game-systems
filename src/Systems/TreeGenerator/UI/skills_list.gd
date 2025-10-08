extends VBoxContainer


@onready var add_skill_button: Button = %AddSkillButton
@onready var skills_container: VBoxContainer = %SkillsContainer

var current_point: Point = null

func _ready() -> void:
	TreeGeneratorGlobals.point_selected_signal.connect(_on_point_selected)
	TreeGeneratorGlobals.point_deselected_signal.connect(_on_point_deselected)
	
	if add_skill_button:
		add_skill_button.pressed.connect(_on_add_skill_pressed)

func _on_point_selected(point: Point) -> void:
	current_point = point
	_refresh_skills_list()

func _on_point_deselected() -> void:
	current_point = null
	_clear_skills_list()

func _refresh_skills_list() -> void:
	_clear_skills_list()
	
	if not current_point:
		return
	
	var skills := current_point.get_skills()
	for i in range(skills.size()):
		_create_skill_item(i, skills[i])

func _clear_skills_list() -> void:
	if skills_container:
		for child in skills_container.get_children():
			child.queue_free()

func _create_skill_item(index: int, skill: PointSkill) -> void:
	var skill_item := HBoxContainer.new()
	skills_container.add_child(skill_item)
	
	var skill_label := Label.new()
	skill_label.text = "Skill %d:" % (index + 1)
	skill_label.custom_minimum_size = Vector2(60, 0)
	skill_item.add_child(skill_label)
	
	var skill_select := OptionButton.new()
	skill_select.custom_minimum_size = Vector2(150, 0)
	for skill_type in Skill.SKILL.keys() as Array[String]:
		var skill_id: int = Skill.SKILL[skill_type]
		skill_select.add_item(skill_type, skill_id)
	for i in skill_select.get_item_count():
		if skill_select.get_item_id(i) == int(skill.skill):
			skill_select.select(i)
			break
	skill_select.item_selected.connect(func(idx: int) -> void: _on_skill_changed(index, skill_select.get_item_id(idx)))
	skill_item.add_child(skill_select)
	
	var remove_button := Button.new()
	remove_button.text = "X"
	remove_button.custom_minimum_size = Vector2(30, 0)
	remove_button.pressed.connect(func() -> void: _on_remove_skill_pressed(index))
	skill_item.add_child(remove_button)

func _on_add_skill_pressed() -> void:
	if current_point:
		var new_skill := PointSkill.new(Skill.SKILL.SHADOW_WALK)
		current_point.add_skill(new_skill)
		_refresh_skills_list()

func _on_remove_skill_pressed(index: int) -> void:
	if current_point:
		current_point.remove_skill(index)
		_refresh_skills_list()

func _on_skill_changed(index: int, skill_id: int) -> void:
	if current_point:
		var skills := current_point.get_skills()
		if index >= 0 and index < skills.size():
			skills[index].skill = skill_id as Skill.SKILL