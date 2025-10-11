extends CharacterBody2D

@export var movement_speed: float = 230.0

@onready var sprite: Sprite2D = $Sprite2D

var _input_vector: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	_handle_input()
	_handle_direction()
	move_and_slide()

func _handle_input() -> void:
	_input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	_input_vector = _input_vector.normalized()
	velocity = _input_vector * movement_speed

func _handle_direction() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var player_position: Vector2 = global_position
	
	# Check if cursor is to the left or right of the player
	if mouse_position.x < player_position.x:
		sprite.flip_h = true # Face left
	else:
		sprite.flip_h = false # Face right
