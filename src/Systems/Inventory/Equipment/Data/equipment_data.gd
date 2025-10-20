class_name EquipmentData
extends RefCounted

signal item_equipped(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData)
signal item_unequipped(slot_type: ItemTags.ITEM_TAGS, item_data: ItemData)

var _equipped_items: Dictionary = {}

func _init() -> void:
	_init_slots()

func can_equip_item(item_data: ItemData, slot_type: ItemTags.ITEM_TAGS) -> bool:
	if not item_data:
		return false
	
	if not item_data.tags.has(slot_type):
		return false
	
	return true

func equip_item(item_data: ItemData, slot_type: ItemTags.ITEM_TAGS) -> bool:
	if not can_equip_item(item_data, slot_type):
		return false
	
	if _equipped_items.has(slot_type) and _equipped_items[slot_type] != null:
		return false
	
	_equipped_items[slot_type] = item_data
	item_equipped.emit(slot_type, item_data)
	Global.equipment_changed()
	return true

func unequip_item(slot_type: ItemTags.ITEM_TAGS) -> ItemData:
	if not _equipped_items.has(slot_type):
		return null
	
	var item_data: ItemData = _equipped_items[slot_type]
	if not item_data:
		return null
	
	_equipped_items[slot_type] = null
	item_unequipped.emit(slot_type, item_data)
	Global.equipment_changed()
	return item_data

func get_equipped_item(slot_type: ItemTags.ITEM_TAGS) -> ItemData:
	if _equipped_items.has(slot_type):
		return _equipped_items[slot_type]
	return null

func get_all_equipped_items() -> Array[ItemData]:
	var items: Array[ItemData] = []
	var keys := _equipped_items.keys()
	for slot_type: ItemTags.ITEM_TAGS in keys:
		var item: ItemData = _equipped_items[slot_type]
		if item:
			items.append(item)
	return items

func clear() -> void:
	_equipped_items.clear()
	_init_slots()

func _init_slots() -> void:
	_equipped_items[ItemTags.ITEM_TAGS.WEAPON] = null
	_equipped_items[ItemTags.ITEM_TAGS.SHIELD] = null
	_equipped_items[ItemTags.ITEM_TAGS.HELMET] = null
	_equipped_items[ItemTags.ITEM_TAGS.BODY_ARMOUR] = null
	_equipped_items[ItemTags.ITEM_TAGS.GLOVES] = null
	_equipped_items[ItemTags.ITEM_TAGS.BOOTS] = null
	_equipped_items[ItemTags.ITEM_TAGS.NECKLACE] = null
	_equipped_items[ItemTags.ITEM_TAGS.EARRING] = null
	_equipped_items[ItemTags.ITEM_TAGS.RING] = null
	_equipped_items[ItemTags.ITEM_TAGS.BELT] = null
