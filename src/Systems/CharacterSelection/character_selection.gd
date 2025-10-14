extends Control

@export var empty_slot_scene: PackedScene
@export var character_slot_scene: PackedScene
const TOTAL_SLOTS = 8

@onready var grid_container: GridContainer = %GridContainer
@onready var character_selection_modal: MarginContainer = %CreateCharacterModal
@onready var new_game_button: Button = %NewGame

var _selected_character_id: String
var _selected_slot: CharacterSlot = null

func _ready() -> void:
	_connect_modal()
	_populate_slots()
	Global.character_created_signal.connect(_populate_slots)
	new_game_button.pressed.connect(_on_new_game_pressed)

func _populate_slots() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
	var characters := SavesManager.get_characters()
	var filled_slots := characters.size()

	for character in characters:
		_create_character_slot(character)

	for i in range(TOTAL_SLOTS - filled_slots):
		_create_empty_slot()

func _create_character_slot(character: SavedCharacter) -> void:
	var slot: CharacterSlot = character_slot_scene.instantiate()
	grid_container.add_child(slot)
	slot.setup(character.id, character.character_name, character.level, character.class_resource.character_art)
	slot.slot_clicked.connect(_on_character_slot_clicked)

func _create_empty_slot() -> void:
	var slot := empty_slot_scene.instantiate()
	grid_container.add_child(slot)
	_connect_empty_slot(slot)

func _connect_empty_slot(slot: Node) -> void:
	if slot.has_signal("slot_clicked"):
		slot.connect("slot_clicked", _show_create_character_modal)

func _on_character_slot_clicked(slot: CharacterSlot) -> void:
	if _selected_slot != null:
		_selected_slot.set_selected(false)
	
	_selected_slot = slot
	_selected_character_id = slot.character_id
	slot.set_selected(true)

func _connect_modal() -> void:
	if character_selection_modal.has_signal("modal_closed"):
		character_selection_modal.connect("modal_closed", _hide_create_character_modal)

func _show_create_character_modal() -> void:
	character_selection_modal.visible = true

func _hide_create_character_modal() -> void:
	character_selection_modal.visible = false

func _on_new_game_pressed() -> void:
	if _selected_character_id:
		Global.trigger_game_started(_selected_character_id)
