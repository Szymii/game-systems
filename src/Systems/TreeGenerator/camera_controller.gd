extends Camera2D

var is_dragging := false
var drag_start_position := Vector2.ZERO
var drag_start_camera_position := Vector2.ZERO
var move_speed := 500.0

func _ready() -> void:
	#set_camera_limits()
	pass

func _process(_delta: float) -> void:
	_zoom()
	clickAndDrag()

func _zoom() -> void:
	# Don't zoom if mouse is over UI
	if _is_mouse_over_ui():
		return
	
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom = zoom * 1.1
	
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom = zoom * 0.9
	
	# Clamp zoom to prevent extreme values
	zoom = clamp(zoom, Vector2(0.5, 0.5), Vector2(2.0, 2.0))
	

func clickAndDrag() -> void:
	if Input.is_action_just_pressed("camera_drag"):
		is_dragging = true
		drag_start_position = get_viewport().get_mouse_position()
		drag_start_camera_position = position
	
	if Input.is_action_just_released("camera_drag"):
		is_dragging = false
	
	if is_dragging:
		var current_mouse_position := get_viewport().get_mouse_position()
		var drag_delta := (current_mouse_position - drag_start_position) / zoom
		position = drag_start_camera_position - drag_delta

func _is_mouse_over_ui() -> bool:
	var mouse_pos := get_viewport().get_mouse_position()
	var root := get_tree().root
	
	for child in root.get_children():
		var foldable := _find_foldable_at_position(child, mouse_pos)
		if foldable:
			return true
	
	return false

func _find_foldable_at_position(node: Node, mouse_pos: Vector2) -> Node:
	if node.get_class() == "FoldableContainer":
		var control := node as Control
		if control.visible and control.get_global_rect().has_point(mouse_pos):
			return node
	
	for child in node.get_children():
		var result := _find_foldable_at_position(child, mouse_pos)
		if result:
			return result
	
	return null
