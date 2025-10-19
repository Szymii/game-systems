class_name GameController
extends Node

@export var world: Node2D
@export var gui: Control
@export var player_scene: PackedScene

var current_world_scene: Node2D
var current_gui_scene: Control

func _ready() -> void:
	Global.game_controller = self
	current_gui_scene = %MainMenu
	
	Global.game_started_signal.connect(_on_game_started)
	Global.level_change_requested_signal.connect(_on_level_change_requested)

func change_world_scene(new_scene: String) -> void:
	if current_world_scene:
		world.remove_child(current_world_scene)
		current_world_scene.queue_free()
	
	var packed_scene: PackedScene = load(new_scene) as PackedScene
	var scene: Node = packed_scene.instantiate()
	world.add_child(scene)
	current_world_scene = scene

func change_gui_scene(new_scene: String) -> void:
	if current_gui_scene:
		gui.remove_child(current_gui_scene)
		current_gui_scene.queue_free()
	
	var packed_scene: PackedScene = load(new_scene) as PackedScene
	var scene: Control = packed_scene.instantiate() as Control
	gui.add_child(scene)
	current_gui_scene = scene

func clear_world_scene() -> void:
	if current_world_scene:
		world.remove_child(current_world_scene)
		current_world_scene.queue_free()
		current_world_scene = null

func clear_gui_scene() -> void:
	if current_gui_scene:
		gui.remove_child(current_gui_scene)
		current_gui_scene.queue_free()
		current_gui_scene = null

func _on_game_started(character_id: String) -> void:
	var character_data := SavesManager.load_character_data(character_id)
	if character_data == null:
		push_error("Failed to load character: " + character_id)
		return
	
	var player := _spawn_player(character_data)
	_load_level("res://src/Levels/Level0/Level_0.tscn",player)
	clear_gui_scene()

func _spawn_player(data: SavedCharacterData) -> Player:
	var player := player_scene.instantiate() as Player
	player.initialize(data)
	world.add_child(player)
	
	return player

func _load_level(level_path: String, player: Player) -> void:
	if current_world_scene:
		world.remove_child(current_world_scene)
		current_world_scene.queue_free()
	
	var level_node: PackedScene = load(level_path)
	var level := level_node.instantiate()
	world.add_child(level)
	current_world_scene = level
	_position_player_at_spawn(player)

func _position_player_at_spawn(player: Player) -> void:
	if not player or not current_world_scene:
		return
	
	if current_world_scene.has_method("get_spawn_position"):
		@warning_ignore("unsafe_method_access")
		player.global_position = current_world_scene.get_spawn_position()

func _on_level_change_requested(level_path: String, player: Player) -> void:
	_load_level(level_path, player)
