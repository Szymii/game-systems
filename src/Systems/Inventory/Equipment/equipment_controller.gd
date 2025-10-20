class_name EquipmentController
extends RefCounted

signal item_equipped_to_slot(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData)
signal item_unequipped_from_slot(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData)

var data: EquipmentData
var character_id: String

func _init(_data: EquipmentData, _character_id: String = "") -> void:
	data = _data
	character_id = _character_id
	
	data.item_equipped.connect(_on_item_equipped)
	data.item_unequipped.connect(_on_item_unequipped)

func try_equip_item(item_data: ItemData, slot_type: ItemTags.ITEM_TAGS) -> bool:
	if data.equip_item(item_data, slot_type):
		_auto_save()
		return true
	return false

func try_unequip_item(slot_type: ItemTags.ITEM_TAGS) -> ItemData:
	var item := data.unequip_item(slot_type)
	if item:
		_auto_save()
	return item

func try_swap_with_slot(held_item: ItemData, target_slot: ItemTags.ITEM_TAGS) -> ItemData:
	var existing_item := data.get_equipped_item(target_slot)
	
	if existing_item:
		data.unequip_item(target_slot)
	
	if data.equip_item(held_item, target_slot):
		_auto_save()
		return existing_item
	else:
		if existing_item:
			data.equip_item(existing_item, target_slot)
		return null

func get_equipped_item(slot_type: ItemTags.ITEM_TAGS) -> ItemData:
	return data.get_equipped_item(slot_type)

func save_equipment() -> void:
	if character_id.is_empty():
		return
	
	# TODO: Implementacja save przez SavesManager
	# var equipped_items := data.get_all_equipped_items()
	# SavesManager.save_equipment(character_id, equipped_items)

func load_equipment() -> void:
	if character_id.is_empty():
		return
	
	# TODO: Implementacja load przez SavesManager
	# var character_data := SavesManager.load_character_data(character_id)
	# if character_data and character_data.equipment_items:
	#     # Load equipment

func _auto_save() -> void:
	if not character_id.is_empty():
		save_equipment()

func _on_item_equipped(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData) -> void:
	item_equipped_to_slot.emit(slot_type, item_data)

func _on_item_unequipped(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData) -> void:
	item_unequipped_from_slot.emit(slot_type, item_data)
