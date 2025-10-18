class_name PlayerStatus
extends MarginContainer

@onready var class_texture: TextureRect = %ClassTexture
@onready var life_bar: TextureProgressBar = %LifeBar
@onready var mana_bar: TextureProgressBar = %ManaBar
@onready var life_label: Label = %LifeLabel
@onready var mana_label: Label = %ManaLabel

func initialize(stats_runtime: StatsRuntime, stats_manager: StatsManager, class_art: Texture2D) -> void:
	stats_runtime.hp_changed.connect(_on_hp_changed)
	stats_runtime.mana_changed.connect(_on_mana_changed)
	class_texture.texture = class_art
	
	_on_hp_changed(stats_runtime.current_hp, stats_manager.get_stat("life"))
	_on_mana_changed(stats_runtime.current_mana, stats_manager.get_stat("mana"))

func _on_hp_changed(new_hp: int, max_hp: int) -> void:
	life_bar.max_value = max_hp
	life_bar.value = new_hp
	life_label.text = str(new_hp) + " / " + str(max_hp)

func _on_mana_changed(new_mana: int, max_mana: int) -> void:
	mana_bar.max_value = max_mana
	mana_bar.value = new_mana
	mana_label.text = str(new_mana) + " / " + str(max_mana)
