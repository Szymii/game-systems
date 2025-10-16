class_name SkillList
extends Panel

@onready var item_list: ItemList = %ItemList
@export var skill_list: Array[SkillResource] = []


func _ready() -> void:
	_populate_item_list()

func _populate_item_list() -> void:
	item_list.clear()
	
	for skill in skill_list:
		if skill:
			item_list.add_item(skill.skill_name, skill.skill_icon)

func add_skill(skill: SkillResource) -> void:
	if skill:
		skill_list.append(skill)
		item_list.add_item(skill.skill_name, skill.skill_icon)
