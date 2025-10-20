class_name Equipment
extends MarginContainer

@export var inventory_item_scene: PackedScene

@onready var weapon_slot: ColorRect = %WeaponSlot
@onready var earring: ColorRect = %Earring
@onready var body_armour: ColorRect = %BodyArmour
@onready var gloves: ColorRect = %Gloves
@onready var boots: ColorRect = %Boots
@onready var weapon_shield_slot: ColorRect = %WeaponShieldSlot
@onready var helmet: ColorRect = %Helmet
@onready var necklace: ColorRect = %Necklace
@onready var ring_right: ColorRect = %RingRight
@onready var belt: ColorRect = %Belt

var drag_manager: DragDropManager

var _slots: Dictionary = {}

func initialize(_drag_manager: DragDropManager) -> void:
	drag_manager = _drag_manager
	
	_setup_slots()

func _setup_slots() -> void:
	_register_slot(weapon_slot, ItemTags.ITEM_TAGS.WEAPON)
	_register_slot(weapon_shield_slot, ItemTags.ITEM_TAGS.SHIELD)
	_register_slot(helmet, ItemTags.ITEM_TAGS.HELMET)
	_register_slot(body_armour, ItemTags.ITEM_TAGS.BODY_ARMOUR)
	_register_slot(gloves, ItemTags.ITEM_TAGS.GLOVES)
	_register_slot(boots, ItemTags.ITEM_TAGS.BOOTS)
	_register_slot(necklace, ItemTags.ITEM_TAGS.NECKLACE)
	_register_slot(earring, ItemTags.ITEM_TAGS.EARRING)
	_register_slot(ring_right, ItemTags.ITEM_TAGS.RING)
	_register_slot(belt, ItemTags.ITEM_TAGS.BELT)

func _register_slot(slot_node: ColorRect, slot_type: ItemTags.ITEM_TAGS) -> void:
	_slots[slot_type] = slot_node
	slot_node.gui_input.connect(func(_event: InputEvent) -> void: _on_slot_input(slot_type))

func _on_slot_input(slot_type: ItemTags.ITEM_TAGS) -> void:
	if Input.is_action_just_pressed("interaction"):
		_handle_slot_click(slot_type)

func _handle_slot_click(slot_type: ItemTags.ITEM_TAGS) -> void:
	var held_item := drag_manager.get_held_item()
	
	if held_item:
		_try_equip_held_item(slot_type)
	else:
		_try_unequip_item(slot_type)

func _try_equip_held_item(slot_type: ItemTags.ITEM_TAGS) -> void:
	var held_item := drag_manager.get_held_item()

	# check if item can be equiped

	# check if this slot has item

	# save item in slot
	# setup view
	# free drag manager
	# emit signal

	pass

func _try_unequip_item(slot_type: ItemTags.ITEM_TAGS) -> void:
	pass
