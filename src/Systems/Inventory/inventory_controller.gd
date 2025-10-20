class_name InventoryController
extends RefCounted

signal item_added_to_inventory(item_data: ItemData, slot_index: int)
signal inventory_loaded()

var data: InventoryData
var character_id: String

func _init(_data: InventoryData, _character_id: String = "") -> void:
	data = _data
	character_id = _character_id
	
	data.inventory_changed.connect(_auto_save)

func try_add_item(item_data: ItemData) -> bool:
	var slot_index := data.add_item(item_data)
	if slot_index >= 0:
		_on_item_added(item_data, slot_index)

	return slot_index >= 0

func try_add_item_at_slot(item_data: ItemData, _slot_index: int) -> bool:
	var slot_index := data.add_item(item_data, _slot_index)
	if slot_index >= 0:
		_on_item_added(item_data, slot_index)

	return slot_index >= 0

func remove_item_at_slot(slot_index: int) -> ItemData:
	var item := data.remove_item_at_slot(slot_index)
	return item

func get_item_at_slot(slot_index: int) -> ItemData:
	return data.get_item_at_slot(slot_index)

func get_items_in_area(slot_index: int, dimensions: Vector2i) -> Array[ItemData]:
	return data.get_items_in_area(slot_index, dimensions)

func load_inventory() -> void:
	if character_id.is_empty():
		return
	
	var character_data := SavesManager.load_character_data(character_id)
	if character_data and character_data.inventory_items.size() > 0:
		data.load_from_save_data(character_data.inventory_items)
		inventory_loaded.emit()

func _on_item_added(item_data: ItemData, slot_index: int) -> void:
	item_added_to_inventory.emit(item_data, slot_index)

func _auto_save() -> void:
	if not character_id.is_empty():
		_save_inventory()

func _save_inventory() -> void:
	var saved_items := data.get_save_data()
	SavesManager.save_inventory(character_id, saved_items)