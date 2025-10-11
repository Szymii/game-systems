extends Node

var current_character: Array[SavedCharacter] = []

func _ready() -> void:
  _load_characters()

func create_and_save(_character_name: String, _character_class: CharacterClassList.CHARACTER_CLASS_LIST, _art_path: String) -> void:
  var new_character := SavedCharacter.new()
  new_character.character_name = _character_name
  new_character.character_class = _character_class
  new_character.character_texture_path = _art_path
  current_character.append(new_character)

  _save_characters()
  Global.character_created()

func get_characters() -> Array[SavedCharacter]:
  return current_character

func _save_characters() -> void:
  var saved_data := SavedCharactersList.new()
  saved_data.characters = current_character
  ResourceSaver.save(saved_data, "user://saved_chars.tres")

func _load_characters() -> void:
 if not FileAccess.file_exists("user://saved_chars.tres"):
  return
  
 var saved_data := load("user://saved_chars.tres") as SavedCharactersList
 if saved_data:
  current_character = saved_data.characters
