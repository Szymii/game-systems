class_name Inventory
extends PanelContainer

@export var inventory_dimensions: Vector2i = Vector2i(10, 6)
@export var inventory_item_scene: PackedScene

@onready var item_grid_ui: ItemGridUI = %ItemGrid

var controller: InventoryController
var drag_manager: DragDropManager

func _ready() -> void:
	_initialize_inventory()
	Global.try_pick_up_item_signal.connect(_try_add_item)

func _initialize_inventory() -> void:
	var inventory_data := InventoryData.new(inventory_dimensions)
	controller = InventoryController.new(inventory_data, Global.current_character_id)
	drag_manager = DragDropManager.new()
	
	add_child(drag_manager)
	
	item_grid_ui.initialize(controller, drag_manager)
	
	controller.load_inventory()

func _try_add_item(item_data: ItemData, callback: Callable) -> void:
	var success := controller.try_add_item(item_data)
	if success:
		callback.call()
