extends Control

@export var empty_slot_scene: PackedScene
const TOTAL_SLOTS = 8

@onready var grid_container: GridContainer = %GridContainer
@onready var character_selection_modal: MarginContainer = %CreateCharacterModal

func _ready() -> void:
	_connect_modal()
	_populate_slots()
	_connect_empty_slots()

func _populate_slots() -> void:
	for i in range(TOTAL_SLOTS):
		var slot: Node = _create_slot(i)
		grid_container.add_child(slot)

func _create_slot(_index: int) -> Node:
	var slot := empty_slot_scene.instantiate()
	return slot

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
