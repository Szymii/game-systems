extends Node

signal character_created_signal()
signal game_started_signal(character_id: String)
signal level_change_requested_signal(level_path: String)

signal try_pick_up_item_signal(item_data: ItemData, callback: Callable)
signal equipment_changed_signal()

var game_controller: GameController
var current_character_id: String

func character_created() -> void:
	character_created_signal.emit()

func trigger_game_started(character_id: String) -> void:
	current_character_id = character_id
	game_started_signal.emit(character_id)

func trigger_level_change(level_path: String) -> void:
	level_change_requested_signal.emit(level_path)

func try_pick_up_item(item_data: ItemData, callback: Callable) -> void:
	try_pick_up_item_signal.emit(item_data, callback)

func equipment_changed() -> void:
	equipment_changed_signal.emit()
