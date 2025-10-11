extends Node

signal character_created_signal()

var game_controller: GameController

func character_created() -> void:
	character_created_signal.emit()
