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

var controller: EquipmentController
var drag_manager: DragDropManager

var _slots: Dictionary = {}
var _item_views: Dictionary = {}

func initialize(_drag_manager: DragDropManager) -> void:
	drag_manager = _drag_manager
	
	var equipment_data := EquipmentData.new()
	controller = EquipmentController.new(equipment_data, Global.current_character_id)
	
	controller.item_equipped_to_slot.connect(_on_item_equipped)
	controller.item_unequipped_from_slot.connect(_on_item_unequipped)
	
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
	if not held_item or not held_item.item_data:
		return
	
	if not held_item.item_data.tags.has(slot_type):
		return
	
	var existing_item := controller.try_swap_with_slot(held_item.item_data, slot_type)
	
	if existing_item:
		await get_tree().process_frame
		_create_held_item_view_for_swap(existing_item)


func _try_unequip_item(slot_type: ItemTags.ITEM_TAGS) -> void:
	var item_data := controller.get_equipped_item(slot_type)
	if not item_data:
		return
	
	if not _item_views.has(slot_type):
		return
	
	var item_view: InventoryItemView = _item_views[slot_type]
	if not item_view or not is_instance_valid(item_view):
		return
	
	controller.try_unequip_item(slot_type)
	
	drag_manager.start_drag(item_view)

func _on_item_equipped(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData) -> void:
	_create_item_view(slot_type, item_data)

func _on_item_unequipped(slot_type: ItemTags.ITEM_TAGS, _item_data: ItemData) -> void:
	if not _item_views.has(slot_type):
		return
	
	var item_view: InventoryItemView = _item_views[slot_type]
	
	if drag_manager.get_held_item() == item_view:
		_item_views.erase(slot_type)
	else:
		_remove_item_view(slot_type)

func _create_item_view(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData) -> void:
	if not inventory_item_scene:
		return
	
	var held_view := drag_manager.get_held_item()
	if held_view and held_view.item_data == item_data:
		drag_manager.end_drag()
		
		if _slots.has(slot_type):
			var target_slot: ColorRect = _slots[slot_type]
			if target_slot:
				var target_center := target_slot.global_position + target_slot.size / 2
				held_view.set_position_from_slot(target_center - held_view.size / 2)
		
		_item_views[slot_type] = held_view
		return
	
	if _item_views.has(slot_type):
		_remove_item_view(slot_type)
	
	var item_view: InventoryItemView = inventory_item_scene.instantiate()
	item_view.set_item_data(item_data)
	
	if not _slots.has(slot_type):
		return
	
	var slot_node: ColorRect = _slots[slot_type]
	if not slot_node:
		return
	
	get_parent().add_child(item_view)
	
	var slot_center := slot_node.global_position + slot_node.size / 2
	item_view.set_position_from_slot(slot_center - item_view.size / 2)
	
	_item_views[slot_type] = item_view

func _create_held_item_view_for_swap(item_data: ItemData) -> void:
	if not inventory_item_scene:
		return
	
	var item_view: InventoryItemView = inventory_item_scene.instantiate()
	item_view.set_item_data(item_data)
	get_parent().add_child(item_view)
	
	item_view.global_position = get_viewport().get_mouse_position()
	drag_manager.start_drag(item_view)

func _remove_item_view(slot_type: ItemTags.ITEM_TAGS) -> void:
	if not _item_views.has(slot_type):
		_item_views.erase(slot_type)
		return
	
	var item_view: InventoryItemView = _item_views[slot_type]
	if item_view and is_instance_valid(item_view):
		if drag_manager.get_held_item() != item_view:
			item_view.queue_free()
	_item_views.erase(slot_type)
