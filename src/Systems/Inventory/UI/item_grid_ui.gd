class_name ItemGridUI
extends GridContainer

const SLOT_SIZE: int = 32

@export var inventory_slot_scene: PackedScene
@export var inventory_item_scene: PackedScene

var controller: InventoryController
var drag_manager: DragDropManager
var _item_views: Dictionary = {}
var _held_item_intersects: bool = false

func initialize(_controller: InventoryController, _drag_manager: DragDropManager) -> void:
	controller = _controller
	drag_manager = _drag_manager
	
	controller.item_added_to_inventory.connect(_on_item_added)
	controller.inventory_loaded.connect(_on_inventory_loaded)
	
	drag_manager.item_dropped.connect(_on_item_dropped)
	
	_create_slots()

func _create_slots() -> void:
	columns = controller.data.dimensions.x
	for y in controller.data.dimensions.y:
		for x in controller.data.dimensions.x:
			var inventory_slot := inventory_slot_scene.instantiate()
			add_child(inventory_slot)

func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interaction"):
		_handle_click()
	
	if event is InputEventMouseMotion:
		var held_item := drag_manager.get_held_item()
		if held_item:
			_detect_held_item_intersection(held_item)

func _handle_click() -> void:
	var held_item := drag_manager.get_held_item()
	
	if not held_item:
		_try_pickup_item()
	else:
		_try_place_item(held_item)

func _try_pickup_item() -> void:
	var slot_index := _get_slot_index_from_coords(get_global_mouse_position())
	if slot_index < 0:
		return
	
	var item_data := controller.get_item_at_slot(slot_index)
	if not item_data:
		return
	
	var item_view := _get_item_view_for_data(item_data)
	if not item_view:
		return
	
	controller.remove_item_at_slot(slot_index)
	drag_manager.start_drag(item_view)

func _try_place_item(held_item: InventoryItemView) -> void:
	if not _held_item_intersects:
		return
	
	var offset := Vector2(SLOT_SIZE, SLOT_SIZE) / 2
	var target_slot := _get_slot_index_from_coords(held_item.anchor_point + offset)
	if target_slot < 0:
		return
	
	var items_in_area := controller.get_items_in_area(target_slot, held_item.item_data.dimensions)
	
	if items_in_area.size() == 1:
		_handle_swap(held_item, items_in_area[0], target_slot)
	elif items_in_area.size() == 0:
		_place_item_at_slot(held_item, target_slot)

func _handle_swap(held_item: InventoryItemView, existing_item: ItemData, target_slot: int) -> void:
	var existing_view := _get_item_view_for_data(existing_item)
	if not existing_view:
		return
	
	var existing_slot := _find_item_slot(existing_item)
	
	controller.remove_item_at_slot(existing_slot)
	controller.try_add_item_at_slot(held_item.item_data, target_slot)
	
	drag_manager.end_drag()
	drag_manager.start_drag(existing_view)

func _place_item_at_slot(held_item: InventoryItemView, slot_index: int) -> void:
	if controller.try_add_item_at_slot(held_item.item_data, slot_index):
		drag_manager.end_drag()

func _detect_held_item_intersection(held_item: InventoryItemView) -> void:
	var h_rect := Rect2(held_item.anchor_point, held_item.size)
	var g_rect := Rect2(global_position, size)
	var inter := h_rect.intersection(g_rect).size
	_held_item_intersects = (inter.x * inter.y) / (held_item.size.x * held_item.size.y) > 0.8

func _on_item_added(item_data: ItemData, slot_index: int) -> void:
	var held_view := drag_manager.get_held_item()

	if held_view and held_view.item_data == item_data:
		drag_manager.end_drag()
		if held_view.get_parent() != get_parent():
			held_view.reparent(get_parent())
		var pos := controller.data.get_slot_coords(slot_index, global_position)
		held_view.set_position_from_slot(pos)
		held_view.slot_index = slot_index
		_item_views[item_data] = held_view
	else:
		_create_item_view(item_data, slot_index)

func _on_inventory_loaded() -> void:
	_clear_all_views()
	var saved_items := controller.data.get_save_data()
	for saved_item in saved_items:
		_create_item_view(saved_item.item_data, saved_item.slot_index)

func _create_item_view(item_data: ItemData, slot_index: int) -> void:
	var item_view: InventoryItemView = inventory_item_scene.instantiate()
	item_view.set_item_data(item_data)
	item_view.slot_index = slot_index
	
	get_parent().add_child(item_view)
	
	var pos := controller.data.get_slot_coords(slot_index, global_position)
	item_view.set_position_from_slot(pos)
	
	_item_views[item_data] = item_view

func _clear_all_views() -> void:
	var keys := _item_views.keys()
	for item_data: ItemData in keys:
		var item_view: InventoryItemView = _item_views[item_data]
		if is_instance_valid(item_view):
			item_view.queue_free()
	_item_views.clear()

func _get_item_view_for_data(item_data: ItemData) -> InventoryItemView:
	if _item_views.has(item_data):
		return _item_views[item_data]
	return null

func _find_item_slot(item_data: ItemData) -> int:
	for i in controller.data.dimensions.x * controller.data.dimensions.y:
		if controller.get_item_at_slot(i) == item_data:
			return i
	return -1

func _get_slot_index_from_coords(coords: Vector2) -> int:
	return controller.data.get_slot_from_coords(coords, global_position)

func _on_item_dropped(item_data: ItemData, item_view: InventoryItemView) -> void:
	if _item_views.has(item_data):
		_item_views.erase(item_data)
		item_view.queue_free()
