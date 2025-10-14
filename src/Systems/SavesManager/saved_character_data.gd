class_name SavedCharacterData
extends Resource

@export var character_id: String

@export var basic_character_data: BasicCharacterData
@export var character_stats: StatsTable
# inventory
# equipment
# skill tree

func setup(_character_id: String, _basic_character_data: BasicCharacterData, _character_stats: StatsTable) -> void:
	character_id = _character_id
	basic_character_data = _basic_character_data
	character_stats = _character_stats
