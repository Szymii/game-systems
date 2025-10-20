class_name DragDropManager
extends Node

signal item_pickup_started(item_view: InventoryItemView)
signal item_pickup_ended(item_view: InventoryItemView)
signal item_placed(item_view: InventoryItemView, slot_index: int)
signal item_dropped(item_data: ItemData, item_view: InventoryItemView)

var _held_item: InventoryItemView = null
var _is_dragging: bool = false

func _process(_delta: float) -> void:
	if _held_item and _is_dragging:
		_held_item.update_visual_position(get_viewport().get_mouse_position())

func start_drag(item_view: InventoryItemView) -> void:
	if _held_item:
		return
	
	_held_item = item_view
	_is_dragging = true
	item_view.z_index = 10
	item_pickup_started.emit(item_view)

func end_drag() -> void:
	if not _held_item:
		return
	
	_held_item.z_index = 0
	_is_dragging = false
	item_pickup_ended.emit(_held_item)
	_held_item = null

func place_item(slot_index: int) -> void:
	if not _held_item:
		return
	
	item_placed.emit(_held_item, slot_index)

func get_held_item() -> InventoryItemView:
	return _held_item

func is_dragging() -> bool:
	return _is_dragging

func cancel_drag() -> void:
	if _held_item:
		end_drag()

func drop_held_item() -> ItemData:
	if not _held_item:
		return null
	
	var item_data := _held_item.item_data
	var item_view := _held_item
	_held_item = null
	_is_dragging = false
	
	item_dropped.emit(item_data, item_view)
	
	return item_data
