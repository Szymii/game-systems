extends Camera2D

const max_zoom := Vector2(0.6, 0.6)
const min_zoom := Vector2(1.5, 1.5)

func _ready() -> void:
	#set_camera_limits()
	pass

func _process(_delta: float) -> void:
	_zoom()

func _zoom() -> void:
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom = zoom * 1.1
	
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom = zoom * 0.9
	
	# Clamp zoom to prevent extreme values
	zoom = clamp(zoom, max_zoom, min_zoom)
	
