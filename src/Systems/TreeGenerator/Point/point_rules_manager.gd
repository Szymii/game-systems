class_name PointRulesManager
extends RefCounted

var rules: Array[PointRule] = []

func add_rule(new_rule: PointRule) -> void:
	rules.append(new_rule)

func remove_rule(index: int) -> void:
	if index >= 0 and index < rules.size():
		rules.remove_at(index)

func update_rule(index: int, new_rule: PointRule) -> void:
	if index >= 0 and index < rules.size():
		rules[index] = new_rule

func get_rules() -> Array[PointRule]:
	return rules

func set_rules(new_rules: Array[PointRule]) -> void:
	rules = new_rules

func clear_rules() -> void:
	rules.clear()
