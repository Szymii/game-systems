class_name Inventory
extends PanelContainer

@export var inventory_dimensions: Vector2i = Vector2i(10, 6)
@export var inventory_item_scene: PackedScene
@export var item_scene: PackedScene

@onready var item_grid_ui: ItemGridUI = %ItemGrid

var controller: InventoryController
var drag_manager: DragDropManager

func get_drag_manager() -> DragDropManager:
	return drag_manager

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

func try_drop_held_item() -> bool:
	if not drag_manager.is_dragging():
		return false
	
	var held_item_data := drag_manager.drop_held_item()
	if not held_item_data:
		return false
	
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		push_warning("No player found to drop item at!")
		return false
	
	_spawn_item_in_world(held_item_data, player.global_position)
	return true

func _try_add_item(item_data: ItemData, callback: Callable) -> void:
	var success := controller.try_add_item(item_data)
	if success:
		callback.call()

func _spawn_item_in_world(item_data: ItemData, world_position: Vector2) -> void:
	if not item_scene:
		push_error("item_scene not set in Inventory!")
		return
	
	var world := Global.game_controller.current_world_scene
	if not world:
		push_error("No current world scene!")
		return
	
	var item: Item = item_scene.instantiate()
	item.item_data = item_data
	item.global_position = world_position
	world.add_child(item)
