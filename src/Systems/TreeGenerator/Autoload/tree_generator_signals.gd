extends Node

signal add_starting_point_signal()
signal remove_starting_point_signal()

func add_starting_point() -> void:
	add_starting_point_signal.emit()

func remove_starting_point() -> void:
	remove_starting_point_signal.emit()
