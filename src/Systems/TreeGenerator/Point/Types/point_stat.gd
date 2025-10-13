class_name PointStat
extends Resource

@export var stat: Stat.STAT = Stat.STAT.DEX
@export var stat_mode: StatMode.STAT_MODE = StatMode.STAT_MODE.FLAT
@export var value: int = 0
@export var condition: StatCondition.CONDITION = StatCondition.CONDITION.NONE

func _init(_stat: Stat.STAT = Stat.STAT.DEX, _stat_mode: StatMode.STAT_MODE = StatMode.STAT_MODE.FLAT, _value: int = 0, _condition: StatCondition.CONDITION = StatCondition.CONDITION.NONE) -> void:
	stat = _stat
	stat_mode = _stat_mode
	value = _value
	condition = _condition
