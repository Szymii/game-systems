class_name PointSkillsManager
extends RefCounted

var skills: Array[PointSkill] = []

func add_skill(new_skill: PointSkill) -> void:
	skills.append(new_skill)

func remove_skill(index: int) -> void:
	if index >= 0 and index < skills.size():
		skills.remove_at(index)

func update_skill(index: int, new_skill: PointSkill) -> void:
	if index >= 0 and index < skills.size():
		skills[index] = new_skill

func get_skills() -> Array[PointSkill]:
	return skills

func set_skills(new_skills: Array[PointSkill]) -> void:
	skills = new_skills

func clear_skills() -> void:
	skills.clear()
