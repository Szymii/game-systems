class_name Equipment
extends MarginContainer

@export var inventory_item_scene: PackedScene

@onready var weapon: EquipmentSlot = %Weapon
@onready var earring: EquipmentSlot = %Earring
@onready var body_armour: EquipmentSlot = %BodyArmour
@onready var gloves: EquipmentSlot = %Gloves
@onready var boots: EquipmentSlot = %Boots
@onready var weapon_shield: EquipmentSlot = %WeaponShield
@onready var helmet: EquipmentSlot = %Helmet
@onready var necklace: EquipmentSlot = %Necklace
@onready var right: EquipmentSlot = %Right
@onready var belt: EquipmentSlot = %Belt

var drag_manager: DragDropManager
var _slots: Array[EquipmentSlot] = []
var _equipped_items: Dictionary = {}
var _item_views: Dictionary = {}

func initialize(_drag_manager: DragDropManager) -> void:
	drag_manager = _drag_manager
	_setup_slots()
	_load_equipment()

func get_equipped_items() -> Array[ItemData]:
	var items: Array[ItemData] = []
	for item_data: ItemData in _equipped_items.values():
		items.append(item_data)
	return items

func _setup_slots() -> void:
	_slots = [weapon, earring, body_armour, gloves, boots,
			  weapon_shield, helmet, necklace, right, belt]
	
	for slot in _slots:
		slot.gui_input.connect(func(event: InputEvent) -> void: _on_slot_clicked(event, slot))

func _on_slot_clicked(_event: InputEvent, slot: EquipmentSlot) -> void:
	if Input.is_action_just_pressed("interaction"):
		_handle_slot_click(slot)

func _handle_slot_click(slot: EquipmentSlot) -> void:
	var held_view := drag_manager.get_held_item()

	if held_view:
		var success := EquipmentRules.can_equip(held_view.item_data, slot.slot_type)
		if success:
			_equip_item(slot, held_view)
	else:
		_unequip_item(slot)

func _equip_item(slot: EquipmentSlot, held_view: InventoryItemView) -> void:
	var old_view: InventoryItemView = null
	if _item_views.has(slot):
		old_view = _item_views[slot]
		_item_views.erase(slot)
		_equipped_items.erase(slot)
	
	drag_manager.end_drag()
	save_equipment.call_deferred()
	Global.equipment_changed()
	
	var slot_center := slot.global_position + slot.size / 2
	held_view.set_position_from_slot(slot_center - held_view.size / 2)
	
	_equipped_items[slot] = held_view.item_data
	_item_views[slot] = held_view
	
	if old_view and is_instance_valid(old_view):
		old_view.global_position = get_viewport().get_mouse_position()
		drag_manager.start_drag(old_view)

func _unequip_item(slot: EquipmentSlot) -> void:
	if not _item_views.has(slot):
		return
	
	var item_view: InventoryItemView = _item_views[slot]
	if not item_view or not is_instance_valid(item_view):
		return
	
	_item_views.erase(slot)
	_equipped_items.erase(slot)
	
	drag_manager.start_drag(item_view)
	save_equipment.call_deferred()
	Global.equipment_changed()

func save_equipment() -> void:
	var saved_items: Array[SavedEquipmentItem] = []
	for slot: EquipmentSlot in _equipped_items.keys():
		var saved_item := SavedEquipmentItem.new()
		saved_item.item_data = _equipped_items[slot]
		saved_item.slot_type = slot.slot_type
		saved_items.append(saved_item)
	
	SavesManager.save_equipment(Global.current_character_id, saved_items)

func _load_equipment() -> void:
	var character_data := SavesManager.load_character_data(Global.current_character_id)
	if !character_data or character_data.equipment_items.size() <= 0:
		return

	for saved_item in character_data.equipment_items:
		var target_slot: EquipmentSlot = null
		for slot in _slots:
			if slot.slot_type == saved_item.slot_type:
				target_slot = slot
				break
		
		if target_slot:
			var item_view: InventoryItemView = inventory_item_scene.instantiate()
			item_view.set_item_data(saved_item.item_data)
			target_slot.add_child(item_view)
			
			var slot_center := target_slot.global_position + target_slot.size / 2
			item_view.set_position_from_slot(slot_center - item_view.size / 2)
			
			_equipped_items[target_slot] = saved_item.item_data
			_item_views[target_slot] = item_view
