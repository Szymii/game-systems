class_name PointStat
extends Resource

@export var stat: Stat.STAT = Stat.STAT.DEX
@export var stat_mode: StatMode.STAT_MODE = StatMode.STAT_MODE.FLAT
@export var value: int = 0

func _init(_stat: Stat.STAT = Stat.STAT.DEX, _stat_mode: StatMode.STAT_MODE = StatMode.STAT_MODE.FLAT, _value: int = 0) -> void:
	stat = _stat
	stat_mode = _stat_mode
	value = _value
