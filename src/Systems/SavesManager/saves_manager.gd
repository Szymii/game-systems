extends Node

var current_characters: Array[SavedCharacter] = []

func _ready() -> void:
	_load_characters()

func create_and_save(_character_name: String, _character_class: CharacterClass) -> void:
	var new_character := SavedCharacter.new()
	new_character.character_name = _character_name
	new_character.class_resource = _character_class
	current_characters.append(new_character)

	_save_characters()
	var basic_character_data := BasicCharacterData.new()
	basic_character_data.character_name = _character_name
	basic_character_data.class_resource = _character_class
	_save_character_data(new_character.id, basic_character_data, StatsTable.new())
	Global.character_created()

func get_characters() -> Array[SavedCharacter]:
	return current_characters

func _save_characters() -> void:
	var saved_data := SavedCharactersList.new()
	saved_data.characters = current_characters
	ResourceSaver.save(saved_data, "user://saved_chars.tres")

func _save_character_data(_character_id: String, _basic_character_data: BasicCharacterData, _character_stats_table: StatsTable, _inventory_items: Array[SavedInventoryItem] = []) -> void:
	var character_data := SavedCharacterData.new()
	character_data.setup(_character_id, _basic_character_data, _character_stats_table)
	character_data.inventory_items = _inventory_items
	ResourceSaver.save(character_data, "user://" + _character_id + ".tres")

func _load_characters() -> void:
	if not FileAccess.file_exists("user://saved_chars.tres"):
		return
	
	var saved_data := load("user://saved_chars.tres") as SavedCharactersList
	if saved_data:
		current_characters = saved_data.characters

func load_character_data(character_id: String) -> SavedCharacterData:
	var file_path := "user://" + character_id + ".tres"
	if not FileAccess.file_exists(file_path):
		push_error("Character data not found: " + character_id)
		return null
	
	var character_data := load(file_path) as SavedCharacterData
	return character_data

func save_inventory(_character_id: String, _inventory_items: Array[SavedInventoryItem]) -> void:
	var character_data := load_character_data(_character_id)
	if not character_data:
		push_error("Cannot save inventory: character not found")
		return
	
	character_data.inventory_items = _inventory_items
	ResourceSaver.save(character_data, "user://" + _character_id + ".tres")

func save_equipment(_character_id: String, _equipment_items: Array[SavedEquipmentItem]) -> void:
	var character_data := load_character_data(_character_id)
	if not character_data:
		push_error("Cannot save equipment: character not found")
		return
	
	character_data.equipment_items = _equipment_items
	ResourceSaver.save(character_data, "user://" + _character_id + ".tres")
