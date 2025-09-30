extends Camera2D

var is_dragging := false
var drag_start_position := Vector2.ZERO
var drag_start_camera_position := Vector2.ZERO
var move_speed := 500.0

func _ready() -> void:
	#set_camera_limits()
	pass

func _process(delta: float) -> void:
	_zoom()
	movement(delta)
	clickAndDrag()

func _zoom() -> void:
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom = zoom * 1.1
	
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom = zoom * 0.9
	
	# Clamp zoom to prevent extreme values
	zoom = clamp(zoom, Vector2(0.5, 0.5), Vector2(2.0, 2.0))
	

func movement(delta: float) -> void:
	var move_direction := Vector2.ZERO
	
	if Input.is_action_pressed("camera_move_up"):
		move_direction.y -= 1
	if Input.is_action_pressed("camera_move_down"):
		move_direction.y += 1
	if Input.is_action_pressed("camera_move_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("camera_move_right"):
		move_direction.x += 1
	
	# Normalize to prevent faster diagonal movement
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
	
	var adjusted_speed := move_speed / zoom.x
	position += move_direction * adjusted_speed * delta

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
