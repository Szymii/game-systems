class_name Player
extends CharacterBody2D

@export var movement_speed: float = 230.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = %PlayerName
@onready var player_status: PlayerStatus = $PlayerUi/PlayerStatus

var basic_data: BasicCharacterData
var base_stats_table: StatsTable
var equipment_data: EquipmentData
# var skill_tree: SkillTreeData
# var buffs: Array[BuffData] = []

var stats_manager: StatsManager
var stats_runtime: StatsRuntime

func _physics_process(_delta: float) -> void:
	velocity = PlayerMovement.handle_input(movement_speed)
	move_and_slide()

func _ready() -> void:
	if basic_data:
		name_label.text = basic_data.character_name
	if player_status:
		player_status.initialize(stats_runtime, stats_manager, basic_data.class_resource.character_art)

func initialize(data: SavedCharacterData) -> void:
	basic_data = data.basic_character_data
	base_stats_table = data.character_stats
	equipment_data = EquipmentData.new()

	stats_manager = StatsManager.new()
	stats_manager.setup(base_stats_table)

	stats_runtime = StatsRuntime.new()
	add_child(stats_runtime)
	stats_runtime.setup(stats_manager)
