class_name SkillList
extends ItemList

@export var skill_list: Array[SkillResource] = []

func _ready() -> void:
	_populate_item_list()

func _populate_item_list() -> void:
	clear()
	
	for skill in skill_list:
		if skill:
			add_item(skill.skill_name, skill.skill_icon)

func add_skill(skill: SkillResource) -> void:
	if skill:
		skill_list.append(skill)
		add_item(skill.skill_name, skill.skill_icon)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var selected_items := get_selected_items()
	var item_index: int = selected_items[0]
	
	var selected_item := skill_list[item_index]
	
	var icon := TextureRect.new()
	icon.texture = selected_item.skill_icon
	set_drag_preview(icon)
	
	return selected_item
