extends Control

@export var empty_slot_scene: PackedScene
@export var character_slot_scene: PackedScene
const TOTAL_SLOTS = 8

@onready var grid_container: GridContainer = %GridContainer
@onready var character_selection_modal: MarginContainer = %CreateCharacterModal

func _ready() -> void:
	_connect_modal()
	_populate_slots()
	_connect_empty_slots()

func _populate_slots() -> void:
	var characters := SavesManager.get_characters()
	var filled_slots := characters.size()

	for character in characters:
		_create_character_slot(character)
		

	for i in range(TOTAL_SLOTS - filled_slots):
		_create_empty_slot()

func _create_character_slot(character: SavedCharacter) -> void:
	var slot: CharacterSlot = character_slot_scene.instantiate()
	print(character.character_name)
	grid_container.add_child(slot)
	slot.setup(character.character_name, character.level, character.character_texture_path)

func _create_empty_slot() -> void:
	var slot := empty_slot_scene.instantiate()
	grid_container.add_child(slot)

func _connect_empty_slots() -> void:
	for child in grid_container.get_children():
		if child.has_signal("slot_clicked"):
			child.connect("slot_clicked", _show_create_character_modal)

func _connect_modal() -> void:
	if character_selection_modal.has_signal("modal_closed"):
		character_selection_modal.connect("modal_closed", _hide_create_character_modal)

func _show_create_character_modal() -> void:
	character_selection_modal.visible = true

func _hide_create_character_modal() -> void:
	character_selection_modal.visible = false
