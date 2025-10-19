class_name PlayerMovement

static func handle_input(movement_speed: float) -> Vector2:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_vector = input_vector.normalized()
	return input_vector * movement_speed
