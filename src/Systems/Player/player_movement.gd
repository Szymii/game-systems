class_name PlayerMovement

static func handle_input(movement_speed: float) -> Vector2:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_vector = input_vector.normalized()
	return input_vector * movement_speed

static func handle_direction_facing(sprite: Sprite2D, mouse_position: Vector2, player_position: Vector2) -> void:
	# Check if cursor is to the left or right of the player
	if mouse_position.x < player_position.x:
		sprite.flip_h = true # Face left
	else:
		sprite.flip_h = false # Face right