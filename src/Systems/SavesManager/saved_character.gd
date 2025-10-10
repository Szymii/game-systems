class_name SavedCharacter
extends Resource

@export var id: String = ""
@export var character_name: String = ""
@export var character_class: CharacterClassList.CHARACTER_CLASS_LIST = CharacterClassList.CHARACTER_CLASS_LIST.SORCERER
@export var slot_index: int = -1
@export var created_timestamp: int = 0
@export var level: int = 1

func _init() -> void:
	if id.is_empty():
		generate_unique_id()
	if created_timestamp == 0:
		created_timestamp = int(Time.get_unix_time_from_system())

func generate_unique_id() -> void:
	id = str(Time.get_ticks_msec()) + "_" + str(randi())
