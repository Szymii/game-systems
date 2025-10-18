class_name Mob
extends CharacterBody2D

@export var mob_data: MobData

@onready var sprite: Sprite2D = %Sprite2D
@onready var hp_bar: TextureProgressBar = %LifeBar

var stats_manager: StatsManager
var runtime_hp: int

func _ready() -> void:
	if mob_data:
		_initialize_from_data()

func _initialize_from_data() -> void:
	sprite.texture = mob_data.mob_texture
	stats_manager = StatsManager.new()
	stats_manager.setup(mob_data.base_stats)
	stats_manager.recalculate_stats()

	runtime_hp = 10
	#runtime_hp = stats_manager.get_stat("life")
	_update_ui()

func apply_damage(amount: int) -> void:
	runtime_hp = max(runtime_hp - amount, 0)
	_update_ui()

	if runtime_hp <= 0:
		_die()

func _update_ui() -> void:
	hp_bar.max_value = stats_manager.get_stat("life")
	hp_bar.value = runtime_hp

func _die() -> void:
	queue_free()
