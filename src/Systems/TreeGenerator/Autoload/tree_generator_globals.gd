extends Node

signal add_starting_point_signal()
signal remove_starting_point_signal()
signal point_selected_signal(point: Point)

var selected_point: Point = null

func add_starting_point() -> void:
	add_starting_point_signal.emit()

func remove_starting_point() -> void:
	remove_starting_point_signal.emit()

func select_point(point: Point) -> void:
	if selected_point != point:
		selected_point = point
		point_selected_signal.emit(point)

func get_selected_point() -> Point:
	return selected_point
