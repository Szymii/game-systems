class_name StatsRuntime
extends Node

var regen_timer: Timer

var current_hp: int
var current_mana: int
var stats_manager: StatsManager


func setup(manager: StatsManager) -> void:
	stats_manager = manager
	current_hp = stats_manager.get_stat("life")
	current_mana = stats_manager.get_stat("mana")

	# setup timer
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_regen_tick)

func _on_regen_tick() -> void:
	var life_regen := stats_manager.get_stat("life_regeneration")
	var mana_regen := stats_manager.get_stat("mana_regeneration")

	if life_regen > 0:
		current_hp = min(current_hp + life_regen, stats_manager.get_stat("life"))

	if mana_regen > 0:
		current_mana = min(current_mana + mana_regen, stats_manager.get_stat("mana"))