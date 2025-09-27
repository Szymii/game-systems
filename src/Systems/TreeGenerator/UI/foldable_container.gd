extends FoldableContainer


func _on_folding_changed(is_container_folded: bool) -> void:
	if is_container_folded:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP 
