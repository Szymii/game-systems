extends Node

signal character_created_signal()
signal game_started_signal(character_id: String)
signal level_change_requested_signal(level_path: String, )

var game_controller: GameController

func character_created() -> void:
	character_created_signal.emit()

func trigger_game_started(character_id: String) -> void:
	game_started_signal.emit(character_id)

func trigger_level_change(level_path: String) -> void:
	level_change_requested_signal.emit(level_path)
