class_name PointRule
extends Resource

@export var rule: Rule.RULE = Rule.RULE.DAMAGE_TAKEN_AS_MANA
@export var value: int = 0

func _init(_rule: Rule.RULE = Rule.RULE.DAMAGE_TAKEN_AS_MANA, _value: int = 0) -> void:
	rule = _rule
	value = _value

func duplicate_rule() -> PointRule:
	return PointRule.new(rule, value)
