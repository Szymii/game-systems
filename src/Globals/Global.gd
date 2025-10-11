extends Node

signal character_created_signal(character: SavedCharacter)

var game_controller: GameController

func character_created(character: SavedCharacter) -> void:
	character_created_signal.emit(character)