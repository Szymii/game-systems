class_name GameController
extends Node

@export var world: Node2D
@export var gui: Control

var current_word_scene: Node2D
var current_gui_scene: Control

func _ready() -> void:
	Global.game_controller = self
