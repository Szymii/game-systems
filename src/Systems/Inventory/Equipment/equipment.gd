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
var _slots: Array[ColorRect] = []
var _equipped_items: Dictionary = {}
var _item_views: Dictionary = {}

func initialize(_drag_manager: DragDropManager) -> void:
	drag_manager = _drag_manager
	_setup_slots()

func _setup_slots() -> void:
	_slots = [weapon_slot, earring, body_armour, gloves, boots,
			  weapon_shield_slot, helmet, necklace, ring_right, belt]
	
	for slot in _slots:
		slot.gui_input.connect(func(event: InputEvent) -> void: _on_slot_clicked(event, slot))

func _on_slot_clicked(_event: InputEvent, slot: ColorRect) -> void:
	if Input.is_action_just_pressed("interaction"):
		_handle_slot_click(slot)

func _handle_slot_click(slot: ColorRect) -> void:
	var held_view := drag_manager.get_held_item()
	
	if held_view:
		_equip_item(slot, held_view)
	else:
		_unequip_item(slot)

func _equip_item(slot: ColorRect, held_view: InventoryItemView) -> void:
	var old_view: InventoryItemView = null
	if _item_views.has(slot):
		old_view = _item_views[slot]
		_item_views.erase(slot)
		_equipped_items.erase(slot)
	
	drag_manager.end_drag()
	
	var slot_center := slot.global_position + slot.size / 2
	held_view.set_position_from_slot(slot_center - held_view.size / 2)
	
	_equipped_items[slot] = held_view.item_data
	_item_views[slot] = held_view
	
	if old_view and is_instance_valid(old_view):
		old_view.global_position = get_viewport().get_mouse_position()
		drag_manager.start_drag(old_view)

func _unequip_item(slot: ColorRect) -> void:
	if not _item_views.has(slot):
		return
	
	var item_view: InventoryItemView = _item_views[slot]
	if not item_view or not is_instance_valid(item_view):
		return
	
	_item_views.erase(slot)
	_equipped_items.erase(slot)
	
	drag_manager.start_drag(item_view)
