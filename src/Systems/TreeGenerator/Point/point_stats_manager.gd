class_name PointStatsManager
extends RefCounted

var stats: Array[PointStat] = []

func add_stat(new_stat: PointStat) -> void:
	stats.append(new_stat)

func remove_stat(index: int) -> void:
	if index >= 0 and index < stats.size():
		stats.remove_at(index)

func update_stat(index: int, new_stat: PointStat) -> void:
	if index >= 0 and index < stats.size():
		stats[index] = new_stat

func get_stats() -> Array[PointStat]:
	return stats

func set_stats(new_stats: Array[PointStat]) -> void:
	stats = new_stats

func clear_stats() -> void:
	stats.clear()
