class_name StatsRuntime
extends Node

signal hp_changed(current: int, max: int)
signal mana_changed(current: int, max: int)

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
		var max_hp := stats_manager.get_stat("life")
		current_hp = min(current_hp + life_regen, max_hp)
		hp_changed.emit(current_hp, max_hp)

	if mana_regen > 0:
		var max_mana := stats_manager.get_stat("mana")
		current_mana = min(current_mana + mana_regen, max_mana)
		mana_changed.emit(current_mana, max_mana)
