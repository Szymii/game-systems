class_name PointSkill
extends Resource

@export var skill: Skill.SKILL = Skill.SKILL.SHADOW_WALK

func _init(_skill: Skill.SKILL = Skill.SKILL.SHADOW_WALK) -> void:
	skill = _skill
