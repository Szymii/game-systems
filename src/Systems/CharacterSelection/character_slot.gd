class_name CharacterSlot
extends Panel

@onready var character_name: Label = %CharacterName
@onready var character_level: Label = %Level
@onready var character_art: TextureRect = %TextureRect

func setup(_character_name: String, _character_level: int, _character_art: String) -> void:
	character_name.text = _character_name
	character_level.text = str(_character_level)
	character_art.texture = load(_character_art)
