class_name StatsManager
extends Node

var base_stats: StatsTable
var final_stats: StatsTable

func setup(_base_stats: StatsTable) -> void:
	base_stats = _base_stats
	recalculate_stats()

func recalculate_stats() -> void:
	final_stats = base_stats.duplicate()

	# bonus z ekwipunku
	# bonus z drzewka
	# buffy

func get_stat(stat_name: String) -> int:
	return final_stats.get(stat_name)