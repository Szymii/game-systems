class_name Player
extends CharacterBody2D

@export var movement_speed: float = 230.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = %PlayerName

var basic_data: BasicCharacterData
var stats_table: StatsTable

func _ready() -> void:
	if basic_data:
		name_label.text = basic_data.character_name

func initialize(data: SavedCharacterData) -> void:
	basic_data = data.basic_character_data
	stats_table = data.character_stats

func _physics_process(_delta: float) -> void:
	velocity = PlayerMovement.handle_input(movement_speed)
	PlayerMovement.handle_direction_facing(sprite, get_global_mouse_position(), global_position)
	move_and_slide()
