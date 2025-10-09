class_name GameController
extends Node

@export var world: Node2D
@export var gui: Control

var current_world_scene: Node2D
var current_gui_scene: Control

func _ready() -> void:
	Global.game_controller = self
	current_gui_scene = %MainMenu

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
