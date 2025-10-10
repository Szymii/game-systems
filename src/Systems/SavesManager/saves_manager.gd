extends Node

var current_character: Array[SavedCharacter] = []

func create_and_save(_character_name: String, _character_class: CharacterClassList.CHARACTER_CLASS_LIST) -> void:
  var new_character := SavedCharacter.new()
  new_character.character_name = _character_name
  new_character.character_class = _character_class
  current_character.append(new_character)

  _save_characters()

func _save_characters() -> void:
  print(current_character)